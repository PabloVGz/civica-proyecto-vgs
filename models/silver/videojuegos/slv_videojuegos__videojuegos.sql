{% set fuentes = ['vgs_2016', 'ps4', 'xbox'] %}
{#Con un bucle queda bastante más limpio#}
with unioned as (

    {% for fuente in fuentes %}
    select
        game_name,
        genre,
        {{ loop.index }} as source_priority
    from {{ ref('stg_raw_videojuegos__' ~ fuente) }}
    {% if not loop.last %}union all{% endif %}
    {% endfor %}

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