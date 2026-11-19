select
    region_id,
    region_code,
    region_name
from {{ ref('slv_videojuegos__regiones') }}