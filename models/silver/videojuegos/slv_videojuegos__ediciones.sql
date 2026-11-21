{% set fuentes = ['vgs_2016', 'ps4', 'xbox'] %}

with unioned as (
    {% for fuente in fuentes %}
    select
        game_name,
        platform,
        {{ limpiar_nombre_entidad('publisher') }} as publisher,
        {% if fuente == 'vgs_2016' %}
        {{ limpiar_nombre_entidad('developer') }} as developer,
        rating,
        release_year,
        critic_score,
        critic_count,
        user_score,
        user_count,
        {% else %}
        cast(null as varchar) as developer,
        cast(null as varchar) as rating,
        release_year,
        cast(null as integer) as critic_score,
        cast(null as integer) as critic_count,
        cast(null as number(10, 2)) as user_score,
        cast(null as integer) as user_count,
        {% endif %}
        {{ loop.index }} as source_priority
    from {{ ref('stg_raw_videojuegos__' ~ fuente) }}
    {% if not loop.last %}
    union all
    {% endif %}
    {% endfor %}
),

con_plataforma_canonica as (
    select
        u.*,
        coalesce(sp.platform_name, trim(u.platform)) as platform_canonica
    from unioned u
    left join {{ ref('seed_plataformas') }} sp
        on lower(trim(u.platform)) = lower(trim(sp.platform_code))
),

deduplicated as (
    -- Agrupa por título y plataforma homologada ('XOne' y 'Xbox One' -> 'Xbox One')
    select
        game_name,
        platform,
        platform_canonica,
        coalesce(nullif(publisher, ''), 'Unknown') as publisher_name,
        coalesce(
            nullif(
                max(developer) over (partition by lower(game_name), lower(platform_canonica)),
                ''
            ),
            'Unknown'
        ) as developer_name,
        coalesce(
            max(rating) over (partition by lower(game_name), lower(platform_canonica)),
            'Unrated'
        ) as rating_code,
        release_year,
        max(critic_score) over (partition by lower(game_name), lower(platform_canonica)) as critic_score,
        max(critic_count) over (partition by lower(game_name), lower(platform_canonica)) as critic_count,
        max(user_score) over (partition by lower(game_name), lower(platform_canonica)) as user_score,
        max(user_count) over (partition by lower(game_name), lower(platform_canonica)) as user_count
    from con_plataforma_canonica
    qualify row_number() over (
        partition by lower(game_name), lower(platform_canonica)
        order by
            case when release_year is not null then 0 else 1 end asc,
            source_priority asc
    ) = 1
)

select
    {{ dbt_utils.generate_surrogate_key(['lower(game_name)', 'lower(platform_canonica)']) }} as edicion_id,
    {{ dbt_utils.generate_surrogate_key(['lower(game_name)']) }} as game_id,
    {{ dbt_utils.generate_surrogate_key(['lower(platform)']) }} as platform_id,
    {{ dbt_utils.generate_surrogate_key(['lower(publisher_name)']) }} as publisher_id,
    {{ dbt_utils.generate_surrogate_key(['lower(developer_name)']) }} as developer_id,
    {{ dbt_utils.generate_surrogate_key(['lower(rating_code)']) }} as rating_id,
    release_year,
    critic_score,
    critic_count,
    user_score,
    user_count
from deduplicated