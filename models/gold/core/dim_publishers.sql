select
    publisher_id,
    publisher_name
from {{ ref('slv_videojuegos__publishers') }}