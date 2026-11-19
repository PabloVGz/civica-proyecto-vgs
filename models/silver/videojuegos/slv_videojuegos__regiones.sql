select
    {{ dbt_utils.generate_surrogate_key(['lower(region_code)']) }} as region_id,
    region_code,
    region_name
from {{ ref('seed_regiones') }}