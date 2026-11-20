--Este incremental lo que hace es que si, una vez se ha ejecutado por primera vez, no se detctan juegos posteriores a cuando se actualizo por ultima vez,
--no se actualizan. Sin embargo, si hay uno posterior, se ignoran los anteriores y se añade el nuevo.
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='sale_id'
) }}

with base_sources as (
--primero se unen todas las fuentes
    select
        'VGS_2016' as source_code,
        game_name,
        platform,
        na_sales,
        eu_sales,
        jp_sales,
        other_sales,
        global_sales,
        _loaded_at
    from {{ ref('stg_raw_videojuegos__vgs_2016') }}

    union all

    select
        'PS4' as source_code,
        game_name,
        platform,
        na_sales,
        eu_sales,
        jp_sales,
        other_sales,
        global_sales,
        _loaded_at
    from {{ ref('stg_raw_videojuegos__ps4') }}

    union all

    select
        'XBOX' as source_code,
        game_name,
        platform,
        na_sales,
        eu_sales,
        jp_sales,
        other_sales,
        global_sales,
        _loaded_at
    from {{ ref('stg_raw_videojuegos__xbox') }}

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

    select source_code, game_name, platform, _loaded_at, 'NA' as region_code, na_sales as sales_millions
    from deduplicated_sources
    union all
    select source_code, game_name, platform, _loaded_at, 'EU' as region_code, eu_sales as sales_millions
    from deduplicated_sources
    union all
    select source_code, game_name, platform, _loaded_at, 'JP' as region_code, jp_sales as sales_millions
    from deduplicated_sources
    union all
    select source_code, game_name, platform, _loaded_at, 'OTHER' as region_code, other_sales as sales_millions
    from deduplicated_sources

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