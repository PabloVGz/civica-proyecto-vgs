-- Este incremental comprueba si hay registros con _loaded_at posterior a la última ejecución.
-- si no los hay, procesa 0 filas; si los hay, procesa únicamente los nuevos.
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='sale_id',
    on_schema_change='append_new_columns'
) }}

{% set fuentes = ['vgs_2016', 'ps4', 'xbox'] %}
{% set regiones = ['na', 'eu', 'jp', 'other'] %}

with base_sources as (
    {# Se unen las fuentes asignando prioridad (1: vgs_2016, 2: ps4, 3: xbox) #}
    {% for fuente in fuentes %}
    select
        '{{ fuente | upper }}' as source_code,
        {{ loop.index }} as source_priority,
        game_name,
        platform,
        na_sales,
        eu_sales,
        jp_sales,
        other_sales,
        global_sales,
        _loaded_at
    from {{ ref('stg_raw_videojuegos__' ~ fuente) }}
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
),

filtered_sources as (
    -- Filtro incremental estricto
    select * from base_sources
    {% if is_incremental() %}
        where _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}
),

con_plataforma_canonica as (
    -- Homologación de plataformas antes de deduplicar y generar claves
    select
        f.*,
        coalesce(sp.platform_name, trim(f.platform)) as platform_canonica
    from filtered_sources f
    left join {{ ref('seed_plataformas') }} sp
        on lower(trim(f.platform)) = lower(trim(sp.platform_code))
),

deduplicated_sources as (
    -- Deduplica entre fuentes por juego y plataforma homologada
    select *
    from con_plataforma_canonica
    qualify row_number() over (
        partition by lower(game_name), lower(platform_canonica)
        order by source_priority asc, global_sales desc nulls last
    ) = 1
),

unpivoted as (
    {% for region in regiones %}
    select
        source_code,
        game_name,
        platform_canonica,
        _loaded_at,
        '{{ region | upper }}' as region_code,
        {{ region }}_sales as sales_millions
    from deduplicated_sources
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
)

select
    {{ dbt_utils.generate_surrogate_key([
        'lower(game_name)',
        'lower(platform_canonica)',
        'lower(region_code)'
    ]) }} as sale_id,
    {{ dbt_utils.generate_surrogate_key(['lower(game_name)', 'lower(platform_canonica)']) }} as edicion_id,
    {{ dbt_utils.generate_surrogate_key(['lower(region_code)']) }} as region_id,
    source_code,
    coalesce(sales_millions, 0)::number(10, 2) as sales_millions,
    _loaded_at
from unpivoted