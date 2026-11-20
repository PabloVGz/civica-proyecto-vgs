{% set fuentes = ['vgs_2016', 'ps4', 'xbox'] %}

with all_genres as (

    {% for fuente in fuentes %}
    select genre from {{ ref('stg_raw_videojuegos__' ~ fuente) }}
    {% if not loop.last %}union{% endif %}
    {% endfor %}

),

cleaned as (

    select distinct
        coalesce(genre, 'Unknown') as genre_name
    from all_genres

),

categorized as (

    select
        genre_name,
        case --Este case when es necesario para agrupar los macrogeneros dependiendo del genero específico
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
    from cleaned

)

select
    {{ dbt_utils.generate_surrogate_key(['lower(genre_name)']) }} as genre_id,
    {{ dbt_utils.generate_surrogate_key(['lower(macrogenre_name)']) }} as macrogenre_id,
    genre_name
from categorized