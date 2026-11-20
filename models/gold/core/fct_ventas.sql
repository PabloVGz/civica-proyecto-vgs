--Se debe porque si no, gold repetía la lectura del histórico, lo que va justo en contra de lo que quiere hacer un incremental
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='sale_id'
) }}

with ventas as (

    select * from {{ ref('slv_videojuegos__ventas_regionales') }}
    {% if is_incremental() %}
        where edicion_id in (
            select distinct edicion_id
            from {{ ref('slv_videojuegos__ventas_regionales') }}
            where _loaded_at > (select max(_loaded_at) from {{ this }})
        )
    {% endif %}

),

ediciones as (

    select * from {{ ref('gold_ediciones__enriched') }}

)

select
    v.sale_id,
    v.edicion_id,
    e.platform_id,
    e.genre_id,
    e.publisher_id,
    e.developer_id,
    v.region_id,
    v.source_code,
    v.sales_millions,
    round(
        coalesce(
            v.sales_millions / nullif(
                sum(v.sales_millions) over (partition by v.edicion_id, v.source_code),
                0
            ) * 100,
            0
        ),
        2
    ) as cuota_regional_pct,
    v._loaded_at
from ventas v
inner join ediciones e
    on v.edicion_id = e.edicion_id