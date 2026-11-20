{% macro limpiar_nombre_entidad(columna) %}
    case
        when trim(regexp_replace({{ columna }}, '[\\x00-\\x1F\\x7F-\\xFF]', '')) in ('Big Ben Interactive', 'Bigben Interactive')
            then 'Bigben Interactive'
        when trim(regexp_replace({{ columna }}, '[\\x00-\\x1F\\x7F-\\xFF]', '')) in ('Milestone S.r.l', 'Milestone S.r.l.')
            then 'Milestone S.r.l.'
        else trim(regexp_replace({{ columna }}, '[\\x00-\\x1F\\x7F-\\xFF]', ''))
    end
{% endmacro %}