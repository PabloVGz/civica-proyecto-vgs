with generos as (

    select
        genre_name,
        case
            when genre_name in ('Action', 'Action-Adventure', 'Adventure', 'Platform', 'Fighting', 'Sandbox')
                then 'Action & Adventure'
            when genre_name = 'Shooter'
                then 'Shooter'
            when genre_name in ('Sports', 'Racing')
                then 'Sports & Racing'
            when genre_name in ('Role-Playing', 'Strategy', 'MMO')
                then 'Role-Playing & Strategy'
            when genre_name = 'Simulation'
                then 'Simulation'
            when genre_name in ('Misc', 'Puzzle', 'Music', 'Party', 'Visual Novel', 'Board Game', 'Education')
                then 'Casual, Puzzle & Misc'
            else 'Unknown'
        end as macrogenre_name
    from {{ ref('slv_videojuegos__generos') }}

)

select distinct
    {{ dbt_utils.generate_surrogate_key(['lower(macrogenre_name)']) }} as macrogenre_id,
    macrogenre_name
from generos