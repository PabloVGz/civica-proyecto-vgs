{% macro limpiar_nombre_juego(columna) %}
case
    when lower(trim(replace(replace(replace({{ columna }}, 'Ê', ''), chr(160), ''), chr(142), 'é'))) = 'mlb 14 the show'
        then 'MLB 14: The Show'
    when lower(trim(replace(replace(replace({{ columna }}, 'Ê', ''), chr(160), ''), chr(142), 'é'))) = 'angry birds star wars'
        then 'Angry Birds: Star Wars'
    when lower(trim(replace(replace(replace({{ columna }}, 'Ê', ''), chr(160), ''), chr(142), 'é'))) = 'plants vs zombies: garden warfare'
        then 'Plants vs. Zombies: Garden Warfare'
    when lower(trim(replace(replace(replace({{ columna }}, 'Ê', ''), chr(160), ''), chr(142), 'é'))) = 'star wars battlefront 2015'
        then 'Star Wars Battlefront (2015)'
    when lower(trim(replace(replace(replace({{ columna }}, 'Ê', ''), chr(160), ''), chr(142), 'é'))) = 'wwe smackdown vs. raw 2006'
        then 'WWE SmackDown! vs. RAW 2006'
    else trim(replace(replace(replace({{ columna }}, 'Ê', ''), chr(160), ''), chr(142), 'é'))
end
{% endmacro %}