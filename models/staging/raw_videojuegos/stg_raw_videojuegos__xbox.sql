with source as (

    select * from {{ source('raw_videojuegos', 'raw_xbox') }}

),

renamed as (

    select
    -- Todo análogo al de Play4
        try_to_number(pos)::integer as ranking_pos,
        trim(game)::varchar as game_name,
        'XOne'::varchar as platform,
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

)

select * from renamed