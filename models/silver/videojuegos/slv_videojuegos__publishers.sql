{% set fuentes = ['vgs_2016', 'ps4', 'xbox'] %}
{#Se unen los publishers de los raw usando un bucle#}

with all_publishers as (

    {% for fuente in fuentes %}
    select publisher from {{ ref('stg_raw_videojuegos__' ~ fuente) }}
    {% if not loop.last %}union{% endif %}
    {% endfor %}

),

cleaned as (

    select distinct
        coalesce(
            nullif({{ limpiar_nombre_entidad('publisher') }}, ''), --limpieza por duplicados con distinto nombre
            'Unknown'
        ) as publisher_name
    from all_publishers

)
--hash para id
select
    {{ dbt_utils.generate_surrogate_key(['lower(publisher_name)']) }} as publisher_id,
    publisher_name
from cleaned