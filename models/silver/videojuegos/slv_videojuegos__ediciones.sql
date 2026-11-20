with unioned as (
    -- Se unen y se asignan las prioridades: VGS tiene 1, PS4 2 y Xbox One 3
    select
        game_name,
        platform,
        {{ limpiar_nombre_entidad('publisher') }} as publisher, --Limpieza de publishers y developers 
        {{ limpiar_nombre_entidad('developer') }} as developer,
        rating,
        release_year,
        critic_score,
        critic_count,
        user_score,
        user_count,
        1 as source_priority
    from {{ ref('stg_raw_videojuegos__vgs_2016') }}

    union all

    select
        game_name,
        platform,
        {{ limpiar_nombre_entidad('publisher') }} as publisher,
        cast(null as varchar) as developer,
        cast(null as varchar) as rating,
        release_year,
        cast(null as integer) as critic_score,
        cast(null as integer) as critic_count,
        cast(null as number(10, 2)) as user_score,
        cast(null as integer) as user_count,
        2 as source_priority
    from {{ ref('stg_raw_videojuegos__ps4') }}

    union all

    select
        game_name,
        platform,
        {{ limpiar_nombre_entidad('publisher') }} as publisher,
        cast(null as varchar) as developer,
        cast(null as varchar) as rating,
        release_year,
        cast(null as integer) as critic_score,
        cast(null as integer) as critic_count,
        cast(null as number(10, 2)) as user_score,
        cast(null as integer) as user_count,
        3 as source_priority
    from {{ ref('stg_raw_videojuegos__xbox') }}

),

deduplicated as (
    -- Se agrupa por título y plataforma priorizando filas con año de lanzamiento y fuente VGS
    select
        game_name,
        platform,
        coalesce(nullif(publisher, ''), 'Unknown') as publisher_name,
        coalesce(
            nullif(
                max(developer) over (partition by lower(game_name), lower(platform)),
                ''
            ),
            'Unknown'
        ) as developer_name,
        coalesce(
            max(rating) over (partition by lower(game_name), lower(platform)),
            'Unrated'
        ) as rating_code,
        release_year,
        max(critic_score) over (partition by lower(game_name), lower(platform)) as critic_score,
        max(critic_count) over (partition by lower(game_name), lower(platform)) as critic_count,
        max(user_score) over (partition by lower(game_name), lower(platform)) as user_score,
        max(user_count) over (partition by lower(game_name), lower(platform)) as user_count
    from unioned
    qualify row_number() over (
        partition by lower(game_name), lower(platform)
        order by
            case when release_year is not null then 0 else 1 end asc,
            source_priority asc
    ) = 1

)

select
    {{ dbt_utils.generate_surrogate_key(['lower(game_name)', 'lower(platform)']) }} as edicion_id,
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