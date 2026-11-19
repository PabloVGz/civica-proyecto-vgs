select
    edicion_id,
    game_name,
    release_year,
    decada_lanzamiento,
    rating_code,
    rating_description,
    es_multiplataforma,
    total_plataformas,
    critic_score,
    critic_count,
    user_score,
    user_count
from {{ ref('gold_ediciones__enriched') }}