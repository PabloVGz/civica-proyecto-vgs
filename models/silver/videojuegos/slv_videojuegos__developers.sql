with all_developers as (

    select distinct
        coalesce(
            nullif({{ limpiar_nombre_entidad('developer') }}, ''), --limpieza por duplicados con distinto nombre
            'Unknown'
        ) as developer_name
    from {{ ref('stg_raw_videojuegos__vgs_2016') }}
    union
    select 'Unknown' as developer_name

)

select
    {{ dbt_utils.generate_surrogate_key(['lower(developer_name)']) }} as developer_id, --hash
    developer_name
from all_developers