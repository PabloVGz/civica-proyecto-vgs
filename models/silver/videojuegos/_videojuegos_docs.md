{% docs rating_code %}
Código oficial de clasificación por edades de la **ESRB** (Entertainment Software Rating Board).

| rating_code | Significado |
|---|---|
| E | Everyone (Todos los públicos) |
| E10+ | Everyone 10 and Older (Mayores de 10 años) |
| T | Teen (Adolescentes, +13 años) |
| M | Mature (Maduro, +17 años) |
| AO | Adults Only (Solo adultos, +18 años) |
| EC | Early Childhood (Primera infancia) |
| K-A | Kids to Adults (Clasificación histórica equivalente a E) |
| RP | Rating Pending (Clasificación pendiente) |
| Unrated | Sin clasificación especificada en la fuente original |
{% enddocs %}

{% docs region_code %}
Código estandarizado de la región comercial donde se registran las ventas.

| region_code | Región |
|---|---|
| NA | Norteamérica (North America) |
| EU | Europa (Europe) |
| JP | Japón (Japan) |
| OTHER | Resto del mundo |
{% enddocs %}

{% docs source_code %}
Identificador del dataset de origen desde el que se ingesta el registro de ventas.

| source_code | Fuente | Cobertura |
|---|---|---|
| vgs_2016 | Video Game Sales with Ratings (2016) | Multiplataforma global con notas de Metacritic |
| ps4 | Catálogo específico PlayStation 4 | Ventas regionales PS4 |
| xbox | Catálogo específico Xbox One | Ventas regionales Xbox One |
{% enddocs %}

{% docs platform_type %}
Categoría de hardware de la plataforma (`Console`, `Handheld`, `PC`, etc.).
{% enddocs %}

{% docs edicion_id %}
Clave subrogada generada que identifica de forma única la combinación de **videojuego + plataforma + publisher**.
{% enddocs %}

{% docs sale_id %}
Clave subrogada generad que identifica de forma única cada registro de ventas por **edición + región + fuente de origen**.
{% enddocs %}

{% docs sales_millions %}
Volumen de copias físicas/digitales vendidas expresado en **millones de unidades**.
{% enddocs %}

{% docs critic_score %}
Puntuación media otorgada por la prensa especializada en Metacritic (escala entera de **0 a 100**).
{% enddocs %}

{% docs user_score %}
Puntuación media otorgada por los usuarios en Metacritic (escala decimal de **0.0 a 10.0**).
{% enddocs %}

{% docs decada_lanzamiento %}
Década de estreno comercial de la edición derivada de `release_year` (`1990s`, `2000s`, `2010s`, o `Unknown`).
{% enddocs %}

{% docs es_multiplataforma %}
Indicador booleano que señala si el videojuego se lanzó en más de una plataforma.
{% enddocs %}

{% docs total_plataformas %}
Número total de plataformas distintas en las que está disponible el videojuego.
{% enddocs %}

{% docs cuota_regional_pct %}
Porcentaje que representan las ventas de esta región sobre el total de ventas de la edición dentro de la misma fuente (source).
{% enddocs %}

{% docs fct_ventas %}
Tabla de hechos central con las ventas regionales de videojuegos en millones de unidades.

### Grano
* **Grano:** 1 fila = 1 edición de videojuego (`game_name` + `platform`) en 1 región comercial (`NA`, `EU`, `JP`, `OTHER`) y 1 fuente de datos (`VGS_2016`, `PS4`, `XBOX`).

### Estrategia incremental en cadena
* **Materialización:** `incremental` con estrategia `merge` sobre `sale_id`, cerrando la cadena incremental desde `slv_videojuegos__ventas_regionales` hasta Gold sin reescribir el histórico completo.
* **Ventana de 1 hora:** Filtra los registros con `_loaded_at >= dateadd(hour, -1, max(_loaded_at))` para absorber cargas más lentas entre fuentes sin generar duplicados.
* **Consistencia de ventana:** Ante cualquier actualización, se reprocesan las 4 regiones completas de las `edicion_id` afectadas para garantizar que `cuota_regional_pct` sume siempre el `100 %`.
{% enddocs %}