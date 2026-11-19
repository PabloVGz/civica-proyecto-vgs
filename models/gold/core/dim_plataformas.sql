select
    platform_id,
    platform_code,
    platform_name,
    manufacturer,
    platform_type
from {{ ref('slv_videojuegos__plataformas') }}