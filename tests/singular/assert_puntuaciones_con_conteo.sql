--No puede ser que la puntuacion sea X si el numero de reseñas es 0
{{ config(
    severity='error',
    warn_if='>0',
    error_if='>10'
) }}
select
    edicion_id,
    critic_score,
    critic_count,
    user_score,
    user_count
from {{ ref('slv_videojuegos__ediciones') }}
where (critic_score is not null and coalesce(critic_count, 0) <= 0)
   or (user_score is not null and coalesce(user_count, 0) <= 0)