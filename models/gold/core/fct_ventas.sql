with ventas as (

    select * from {{ ref('slv_videojuegos__ventas_regionales') }}

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
    ) as cuota_regional_pct
from ventas v
inner join ediciones e
    on v.edicion_id = e.edicion_id