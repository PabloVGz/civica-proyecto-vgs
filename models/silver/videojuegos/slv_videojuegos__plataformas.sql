with all_platforms as (

    select platform as platform_code from {{ ref('stg_raw_videojuegos__vgs_2016') }}
    union
    select platform as platform_code from {{ ref('stg_raw_videojuegos__ps4') }}
    union
    select platform as platform_code from {{ ref('stg_raw_videojuegos__xbox') }}

),

seed_info as (

    select * from {{ ref('seed_plataformas') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['lower(p.platform_code)']) }} as platform_id, --hash
    p.platform_code,
    coalesce(s.platform_name, p.platform_code) as platform_name,
    coalesce(s.manufacturer, 'Unknown') as manufacturer,
    coalesce(s.platform_type, 'Unknown') as platform_type
from all_platforms p
left join seed_info s --por si se añade algo que no está en seed
    on p.platform_code = s.platform_code