--Comprueba que no exista ninguna edición en silver que se haya quedado sin registros de venta asociados.
{{ config(
    severity='error',
    warn_if='>0',
    error_if='>10'
) }}

with ediciones as (

    select * from {{ ref('slv_videojuegos__ediciones') }}

),

ventas as (

    select * from {{ ref('slv_videojuegos__ventas_regionales') }}

)

select
    e.edicion_id,
    e.game_id,
    e.platform_id
from ediciones e
left join ventas v
    on e.edicion_id = v.edicion_id
where v.sale_id is null