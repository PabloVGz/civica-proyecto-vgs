{% macro borrar_juego_prueba() %}
    {% set sql %}
        delete from DEV_BRONZE_DB.RAW_VIDEOJUEGOS.RAW_PS4
        where game = 'Hollow Knight: Silksong';
    {% endset %}
    {% do run_query(sql) %}
    {{ log("Hollow Knight: Silksong eliminado de RAW_PS4", info=True) }}
{% endmacro %}