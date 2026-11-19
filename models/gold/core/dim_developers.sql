select
    developer_id,
    developer_name
from {{ ref('slv_videojuegos__developers') }}