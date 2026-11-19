with all_ratings as (

    select distinct
        coalesce(rating, 'Unrated') as rating_code
    from {{ ref('stg_raw_videojuegos__vgs_2016') }} --los otros no tienen ratings
    union
    select 'Unrated' as rating_code

)

select
    {{ dbt_utils.generate_surrogate_key(['lower(rating_code)']) }} as rating_id, --hash
    rating_code,
    case rating_code
        when 'E'       then 'Everyone (All ages)'
        when 'E10+'    then 'Everyone 10 and Older'
        when 'T'       then 'Teen (Ages 13 and Older)'
        when 'M'       then 'Mature (Ages 17 and Older)'
        when 'AO'      then 'Adults Only (Ages 18 and Older)'
        when 'EC'      then 'Early Childhood'
        when 'K-A'     then 'Kids to Adults (Legacy Everyone)'
        when 'RP'      then 'Rating Pending'
        when 'Unrated' then 'Unrated / Not Specified'
        else 'Unknown'
    end as rating_description
from all_ratings