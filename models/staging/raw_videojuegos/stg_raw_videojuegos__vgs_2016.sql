with source as (

    select * from {{ source('raw_videojuegos', 'raw_vgs_2016') }}

),

renamed as (

    select
    -- Los trim son para quitar los espacios y tal, todo más homogeneo así. Aparte de eso pues se quitan nulos (Not Applicable es realmente nulo) y se convierten en números los que deben serlo.
        {{ limpiar_nombre_juego('name') }}::varchar as game_name,
        trim(platform)::varchar as platform,
        case --Hay un único juego cuya fecha de lanzamiento no cuadra: PRISCIPERMISO
            when lower(trim(name)) = 'imagine: makeup artist'
                 and lower(trim(platform)) = 'ds'
                 and try_to_number(year_of_release)::integer = 2020
                then 2008
            when try_to_number(year_of_release)::integer between 1970 and 2016
                then try_to_number(year_of_release)::integer
            else null
        end as release_year,
        nullif(trim(genre), 'N/A')::varchar as genre,
        nullif(trim(publisher), 'N/A')::varchar as publisher,
        nullif(trim(developer), 'N/A')::varchar as developer,
        nullif(trim(rating), 'N/A')::varchar as rating,
        try_to_number(na_sales, 10, 2) as na_sales,
        try_to_number(eu_sales, 10, 2) as eu_sales,
        try_to_number(jp_sales, 10, 2) as jp_sales,
        try_to_number(other_sales, 10, 2) as other_sales,
        try_to_number(global_sales, 10, 2) as global_sales,
        try_to_number(critic_score)::integer as critic_score,
        try_to_number(critic_count)::integer as critic_count,
        try_to_number(user_score, 10, 2) as user_score,
        try_to_number(user_count)::integer as user_count,
        _loaded_at

    from source
    where name is not null
      and trim(name) != '' --Esto último lo pongo porque hay filas que vienen con datos pero sin nombre de juego. Especificamente son 2 filas, así que me las cargo por no poder identificar que son.
      and (
          coalesce(try_to_number(na_sales, 10, 2), 0)
        + coalesce(try_to_number(eu_sales, 10, 2), 0)
        + coalesce(try_to_number(jp_sales, 10, 2), 0)
        + coalesce(try_to_number(other_sales, 10, 2), 0)
      ) > 0 -- Descarta ediciones con 0 ventas en todas las regiones

)

select * from renamed