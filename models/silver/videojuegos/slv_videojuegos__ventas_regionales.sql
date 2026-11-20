--Este incremental lo que hace es que si, una vez se ha ejecutado por primera vez, no se detctan juegos posteriores a cuando se actualizo por ultima vez,
--no se actualizan. Sin embargo, si hay uno posterior, se ignoran los anteriores y se añade el nuevo.
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='sale_id'
) }}

{% set fuentes = ['vgs_2016', 'ps4', 'xbox'] %}
{% set regiones = ['na', 'eu', 'jp', 'other'] %}

with base_sources as (
{#Se unen las fuentes#}
    {% for fuente in fuentes %}
    select
        '{{ fuente | upper }}' as source_code,
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

filtered_sources as ( --Aquí pongo el incremental, siendo generoso y poniendo 1h de margen por si hay archivos que hubiesen tardado en cargar.

    select *
    from base_sources
    {% if is_incremental() %}
        where _loaded_at >= (select dateadd(hour, -1, max(_loaded_at)) from {{ this }})
    {% endif %}

),

deduplicated_sources as (
--nos quedamos con el registro que más ventas tenga
    select *
    from filtered_sources
    qualify row_number() over (
        partition by lower(source_code), lower(game_name), lower(platform)
        order by global_sales desc nulls last
    ) = 1

),

unpivoted as (
    {% for region in regiones %}
    select
        source_code,
        game_name,
        platform,
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
        'lower(platform)',
        'lower(region_code)',
        'lower(source_code)'
    ]) }} as sale_id,
    {{ dbt_utils.generate_surrogate_key(['lower(game_name)', 'lower(platform)']) }} as edicion_id,
    {{ dbt_utils.generate_surrogate_key(['lower(region_code)']) }} as region_id,
    source_code,
    coalesce(sales_millions, 0)::number(10, 2) as sales_millions,
    _loaded_at
from unpivoted