with generos as (

    select * from {{ ref('slv_videojuegos__generos') }}

),

macrogeneros as (

    select * from {{ ref('slv_videojuegos__macrogeneros') }}

)

select
    g.genre_id,
    g.genre_name,
    coalesce(m.macrogenre_name, 'Unknown') as macrogenre_name
from generos g
left join macrogeneros m
    on g.macrogenre_id = m.macrogenre_id