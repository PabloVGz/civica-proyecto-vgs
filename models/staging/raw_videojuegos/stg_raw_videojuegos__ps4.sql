with source as (

    select * from {{ source('raw_videojuegos', 'raw_ps4') }}

),

renamed as (

    select
    --Todo es prácticamente igual al anterior pero debo añadir PS4 a plataforma ya que este archivo solo trata de juegos de PS4 y esa columna se obviaba
        {{ limpiar_nombre_juego('game') }}::varchar as game_name,
        'PS4'::varchar as platform,
        try_to_number(year)::integer as release_year,
        nullif(trim(genre), 'N/A')::varchar as genre,
        nullif(trim(publisher), 'N/A')::varchar as publisher,
        try_to_number(north_america, 10, 2) as na_sales,
        try_to_number(europe, 10, 2) as eu_sales,
        try_to_number(japan, 10, 2) as jp_sales,
        try_to_number(rest_of_world, 10, 2) as other_sales,
        try_to_number(global, 10, 2) as global_sales,
        _loaded_at

    from source
    where game is not null
      and trim(game) != ''
      and (
          coalesce(try_to_number(north_america, 10, 2), 0)
        + coalesce(try_to_number(europe, 10, 2), 0)
        + coalesce(try_to_number(japan, 10, 2), 0)
        + coalesce(try_to_number(rest_of_world, 10, 2), 0)
      ) > 0 -- Descarta fichas de catálogo sin ventas registradas (juegos cancelados o no lanzados)

)

select * from renamed