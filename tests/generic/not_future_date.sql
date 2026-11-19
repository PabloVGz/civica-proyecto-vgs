--Cuida que un registro no se meta con un loaded at posterior a la fecha actual que es realmente por error.
{% test not_future_timestamp(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} > current_timestamp()

{% endtest %}