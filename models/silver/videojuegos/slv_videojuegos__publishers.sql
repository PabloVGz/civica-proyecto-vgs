with all_publishers as (
--uno los publishers de los raw
    select publisher from {{ ref('stg_raw_videojuegos__vgs_2016') }}
    union
    select publisher from {{ ref('stg_raw_videojuegos__ps4') }}
    union
    select publisher from {{ ref('stg_raw_videojuegos__xbox') }}

),

cleaned as (

    select distinct
        coalesce(publisher, 'Unknown') as publisher_name
    from all_publishers

)
--hash para id
select
    {{ dbt_utils.generate_surrogate_key(['lower(publisher_name)']) }} as publisher_id,
    publisher_name
from cleaned