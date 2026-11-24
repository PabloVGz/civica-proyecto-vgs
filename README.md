# PROYECTO: Análisis de ventas de videojuegos

Proyecto final del curso de **Data Engineering de Cívica**. Implementa un pipeline con **dbt** y **Snowflake**, transformando tres fuentes históricas de ventas de videojuegos.

---

## Herramientas y plataformas utilizadas
Para la realización del proyecto se han usado las siguientes herramientas:

* **Transformación y Modelado:** dbt Platform
* **Data Warehouse:** Snowflake
* **Paquetes:** `dbt_utils`
* **Control de Versiones:** GitHub
* **Diseño de los diagramas del modelado:** `dbdiagram.io`

---

## Arquitectura utilizada

Los datos se han organizado de la siguiente manera:

1. **Bronze (`RAW_VIDEOJUEGOS`):**
   * `raw_vgs_2016`: Histórico global multiplataforma hasta diciembre de 2016 con puntuaciones de Metacritic y clasificación ESRB.
   * `raw_ps4`: Catálogo y ventas regionales de PlayStation 4 (corte 2020).
   * `raw_xbox`: Catálogo y ventas regionales de Xbox One (corte 2020).
   * Todas las tablas conservan la marca temporal de ingesta `_loaded_at` para el control incremental y de *freshness*.
2. **Seeds (`SEEDS`):**
   * `seed_plataformas`: Catálogo con las **31 plataformas** existentes en los datos, su nombre comercial, fabricante (`manufacturer`) y tipo de hardware (`platform_type`).
3. **Staging (`stg_raw_videojuegos__*` — Vistas):**
   * Establecimiento de los tipos de datos apropiados, limpieza de valores `'N/A'`, filtrado de registros sin título identificable y corrección de errores del año de lanzamiento.
4. **Silver (`slv_videojuegos__*` — Tablas en 3FN):**
   * Modelo relacional normalizado compuesto por **10 tablas**:
     * **Entidades y catálogos:** `videojuegos`, `ediciones`, `generos`, `macrogeneros`, `publishers`, `developers`, `ratings`, `plataformas` y `regiones`.
     * **Hechos desglosados:** `ventas_regionales` despivotando las ventas por región (`NA`, `EU`, `JP`, `OTHER`) con materialización **incremental (`merge`)** filtrada por `_loaded_at`.
5. **Gold Intermediate (`gold_ediciones__enriched` — Vista):**
   * Modelo puente que consolida atributos descriptivos de ediciones, videojuegos y ratings, calculando `decada_lanzamiento`, `total_plataformas` y el indicador `es_multiplataforma`.
6. **Gold Core (`models/gold/core/` — Tablas):**
   * Esquema en estrella de **7 tablas**.

---

## Modelo Dimensional (Capa Gold)

| Tabla | Tipo | Grano y Descripción |
| :--- | :--- | :--- |
| **`fct_ventas`** | Hechos (Incremental) | 1 fila por edición y región comercial (`NA`, `EU`, `JP`, `OTHER`). Calcula la métrica `cuota_regional_pct` sobre el total de cada edición. |
| **`dim_ediciones`** | Dimensión | Edición única (`game_name` + `platform`) con año, década, clasificación ESRB, indicador multiplataforma y puntuaciones de crítica y usuarios (Metacritic). |
| **`dim_plataformas`** | Dimensión |  Consolas y sistemas con fabricante y categoría de hardware. |
| **`dim_generos`** | Dimensión | Géneros de videojuegos vinculados a su agrupación superior (`macrogenre_name`). |
| **`dim_publishers`** | Dimensión | Compañías editoras. |
| **`dim_developers`** | Dimensión | Estudios desarrolladores. |
| **`dim_regiones`** | Dimensión | Regiones geográficas de venta (`NA`, `EU`, `JP`, `OTHER`). |

---

## Calidad y Automatización

* **Calidad de datos (`tests/` y YAML):**
  * Pruebas genéricas de unicidad, no nulidad, valores aceptados (`accepted_values`), rangos numéricos (`dbt_utils.accepted_range`) e integridad referencial (`relationships` con `store_failures: true` hacia las 6 dimensiones).
  * Tests singulares (`assert_ediciones_con_ventas`) y *unit tests* en Silver para validar la lógica de transformación en memoria.
* **Macros (`macros/`):**
  * `limpiar_nombre_entidad`: Estandarización de nombres de *publishers* y *developers*.
  * `generate_schema_name`: Resolución limpia de esquemas por entorno (`dev`, `pre`, `pro`) con salvaguarda para ejecuciones de CI.
  * `insertar_juego_prueba` / `borrar_juego_prueba`: Operaciones auxiliares para validar flujos incrementales .
* **Gobierno y control de acceso:**
  - Definición del dominio `gaming_analytics` en `models/_groups.yml` con responsable asignado y configuración de niveles de visibilidad en `dbt_project.yml`: `access: private` para la vista puente `gold/intermediate` y `access: public` para las 7 tablas finales de `gold/core`.


