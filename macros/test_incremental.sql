--Test hecho para probar la incrementalidad de pruebas regionales. 
--1. Se ejecuta dbt build --select +slv_videojuegos__ventas_regionales --full-refresh para forzar reconstruccion completa.
--2. Se ejecuta dbt build --select slv_videojuegos__ventas_regionales  para ver como se actualizan 0 filas.
--3. Se corre la primera macro dbt run-operation insertar_juego_prueba para insertar el juego.
--4. Se lanza el incremental para ver como se añade solo este sin updatear nada más (dbt build --select +fct_ventas) Aunque falla, si en el pass se va a 
-- slv_videojuegos__ventas_regionales se puede ver [SUCCESS 4 in 3.19s] que son las 4 regiones/filas de Silksong. (el fallo en el comando era porque se actualizan ventas y
--ediciones pero falla relationships por las claves foraneas)
--5. Se borra el dato dbt run-operation borrar_juego_prueba -> dbt build --select +fct_ventas --full-refresh para poder reprobarlo en un futuro.


{% macro insertar_juego_prueba() %}
    {% set sql %}
        insert into DEV_BRONZE_DB.RAW_VIDEOJUEGOS.RAW_PS4
            (game, year, genre, publisher, north_america, europe, japan, rest_of_world, global, _loaded_at)
        values
            ('Hollow Knight: Silksong', 2025, 'Platform', 'Team Cherry', 2.50, 2.00, 0.40, 0.60, 5.50, current_timestamp());
    {% endset %}
    {% do run_query(sql) %}
    {{ log("Hollow Knight: Silksong insertado en RAW_PS4", info=True) }}
{% endmacro %}

{% macro borrar_juego_prueba() %}
    {% set sql %}
        delete from DEV_BRONZE_DB.RAW_VIDEOJUEGOS.RAW_PS4
        where game = 'Hollow Knight: Silksong';
    {% endset %}
    {% do run_query(sql) %}
    {{ log("Hollow Knight: Silksong eliminado de RAW_PS4", info=True) }}
{% endmacro %}