--Comprueba que los valores estén en cierto rango
{% test in_range(model, column_name, min_value, max_value) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} not between {{ min_value }} and {{ max_value }}

{% endtest %}