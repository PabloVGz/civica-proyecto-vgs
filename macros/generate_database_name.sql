{#De manera similar al create schema name, hago una macro para crear el nombre de las bases de datos#}
{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}
    {%- set env_prefix = 'PRO_' if default_database.upper().startswith('PRO_') else 'DEV_' -%}

    {%- if custom_database_name is none -%}
        {{ default_database }}
    {%- else -%}
        {{ env_prefix ~ custom_database_name.strip().upper() }}
    {%- endif -%}
{%- endmacro %}