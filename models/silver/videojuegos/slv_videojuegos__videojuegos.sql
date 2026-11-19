with unioned as (

    select
        game_name,
        genre,
        1 as source_priority
    from {{ ref('stg_raw_videojuegos__vgs_2016') }}

    union all

    select
        game_name,
        genre,
        2 as source_priority
    from {{ ref('stg_raw_videojuegos__ps4') }}

    union all

    select
        game_name,
        genre,
        3 as source_priority
    from {{ ref('stg_raw_videojuegos__xbox') }}

),

deduplicated as (

    select
        game_name,
        coalesce(genre, 'Unknown') as genre_name
    from unioned
    qualify row_number() over (
        partition by lower(game_name)
        order by source_priority asc, game_name asc
    ) = 1

)

select
    {{ dbt_utils.generate_surrogate_key(['lower(game_name)']) }} as game_id,
    game_name,
    {{ dbt_utils.generate_surrogate_key(['lower(genre_name)']) }} as genre_id
from deduplicated