# FinBridge | Business Intelligence Pipeline

## Descripción del proyecto

Este proyecto simula el pipeline de Business Intelligence de **FinBridge**, una billetera digital ficticia que procesa transferencias, pagos, recargas e inversiones de clientes personales y empresariales de distintas regiones de América Latina y el mundo.

El objetivo del proyecto es demostrar el proceso completo de un pipeline BI: desde la ingesta de datos crudos hasta la generación de KPIs listos para consumir, utilizando exclusivamente SQL como herramienta central.

---

## Herramientas utilizadas

- **PostgreSQL 18** — Motor de base de datos
- **DBeaver 26** — Cliente SQL para ejecución y gestión de consultas

---

## Arquitectura del pipeline

El pipeline está organizado en 3 capas, cada una con una responsabilidad específica:

### Capa 1 — RAW
Contiene los datos tal como llegarían de los sistemas de FinBridge, sin ninguna modificación. Incluye errores intencionales que simulan problemas reales de calidad de datos:
- Montos negativos y nulos en transacciones
- Fechas con formato incorrecto en clientes
- Emails nulos

### Capa 2 — Staging
Los datos de la capa RAW son limpiados y transformados:
- Conversión de tipos de datos (VARCHAR → DATE, VARCHAR → DECIMAL, VARCHAR → BOOLEAN)
- Tratamiento de valores nulos con `COALESCE`
- Detección y corrección de formatos incorrectos con expresiones regulares
- Exclusión de registros inválidos que no tienen solución

### Capa 3 — DWH + Analytics
Los datos limpios se organizan en un **modelo estrella** y se crean vistas analíticas que responden las preguntas de negocio definidas.

---

## Modelado de datos

Se utilizó el **modelo estrella**, un tipo de modelado dimensional que organiza los datos en una tabla central rodeada de tablas de contexto, permitiendo que las consultas analíticas sean simples y directas.

### Tabla de hechos
- `fact_transacciones` — Cada fila representa una transacción procesada por FinBridge

### Dimensiones
- `dim_cliente` — Información de cada cliente (perfil, segmento, estado)
- `dim_tiempo` — Descomposición temporal de las fechas (día, mes, trimestre, año)
- `dim_tipo_transaccion` — Tipos de operación disponibles en la plataforma
- `dim_ubicacion` — Información geográfica de los clientes

---

## Preguntas de negocio (KPIs)

### Transacciones
- **¿Cuánto dinero se movió por mes?** — Permite visualizar la evolución del volumen de operaciones a lo largo del tiempo, útil para identificar tendencias de crecimiento o caída en la actividad de la plataforma.
- **¿Cuál es el ticket promedio por transacción?** — Permite entender el valor típico de cada operación, útil para identificar si los clientes realizan muchas transacciones pequeñas o pocas de alto valor.
- **¿Cuáles son los tipos de transacción más usados?** — Permite identificar qué servicios de la plataforma tienen mayor adopción, útil para orientar decisiones de producto y foco comercial.

### Clientes
- **¿Cuántos clientes nuevos se registraron por mes?** — Permite visualizar el crecimiento de la base de clientes a lo largo del tiempo y detectar períodos de mayor o menor incorporación.
- **¿Cuántos clientes están activos vs inactivos?** — Permite identificar qué proporción de la base de clientes opera regularmente en la plataforma y cuál no.
- **¿Qué segmento de cliente mueve más dinero?** — Permite comparar el comportamiento transaccional entre clientes personales y empresariales.

### Geografía
- **¿Desde qué provincias/países operan más los clientes?** — Permite identificar qué regiones y países concentran mayor actividad en la plataforma, útil para entender la distribución geográfica del uso del servicio.

### Calidad de datos
- **¿Existen transacciones con montos negativos o nulos?** — Permite identificar registros inválidos dentro de la capa de transacciones.
- **¿Existen clientes con fechas de registro en formato incorrecto?** — Permite detectar inconsistencias en los datos de alta de clientes.
- **¿Existen clientes con email nulo?** — Permite identificar registros incompletos en la información de contacto.

---

## Estructura del repositorio

```
finbridge-bi-pipeline/
├── 01_raw/
│   ├── 01_crear_tablas.sql
│   └── 02_insertar_datos.sql
├── 02_staging/
│   └── 01_limpiar_datos.sql
├── 03_dwh/
│   └── 01_modelo_estrella.sql
├── 04_analytics/
│   └── 01_vistas_kpi.sql
└── README.md
```

---

## Volumen de datos

| Tabla | Registros |
|---|---|
| raw.clientes | 100 |
| raw.ubicaciones | 100 |
| raw.tipos_transaccion | 5 |
| raw.transacciones | 300 |
| staging.clientes | 100 |
| staging.ubicaciones | 100 |
| staging.tipos_transaccion | 5 |
| staging.transacciones | 297 |
| dwh.dim_cliente | 100 |
| dwh.dim_ubicacion | 100 |
| dwh.dim_tipo_transaccion | 5 |
| dwh.dim_tiempo | 238 |
| dwh.fact_transacciones | 297 |

---

## Decisiones de diseño

**¿Por qué 3 capas en el pipeline?**
Las 3 capas representan el flujo mínimo completo de un pipeline BI: entrada de datos crudos, transformación y salida lista para consumir. Esta estructura permite separar claramente las responsabilidades de cada etapa y hace el proceso reproducible y auditable.

**¿Por qué modelo estrella?**
Se eligió el modelo estrella porque permite estructurar los datos de forma que las consultas analíticas sean simples y directas, separando claramente los eventos que se quieren analizar (transacciones) del contexto que los describe (quién, cuándo, dónde, qué tipo).

**¿Por qué SQL puro como herramienta central?**
Construir los KPIs directamente en la base de datos significa que cualquier herramienta que se conecte, ya sea Power BI, Excel o Tableau, consume la misma lógica sin necesidad de reescribir fórmulas en cada una. Además demuestra que el conocimiento del proceso BI no depende de una herramienta de visualización específica.

**¿Por qué estos KPIs y no otros?**
Las preguntas de negocio fueron seleccionadas porque permiten analizar FinBridge desde los ángulos más relevantes para el negocio (volumen, valor, comportamiento, geografía y calidad de datos) con un dataset que puede respaldar cada respuesta. Se priorizó tener pocos KPIs bien fundamentados sobre muchos KPIs sin sustento.

**¿Por qué datos ficticios generados manualmente?**
Usar datos propios en lugar de un dataset de Kaggle permite controlar la estructura, los errores intencionales y el sentido de negocio de cada campo. Esto hace que el proceso de limpieza en Staging sea real y defendible, no cosmético.

---

## Cómo reproducir el proyecto

1. Instalar **PostgreSQL** y **DBeaver**
2. Crear una base de datos llamada `finbridge_bi`
3. Crear los schemas: `raw`, `staging`, `dwh`
4. Ejecutar los scripts en orden:
   - `01_raw/01_crear_tablas.sql`
   - `01_raw/02_insertar_datos.sql`
   - `02_staging/01_limpiar_datos.sql`
   - `03_dwh/01_modelo_estrella.sql`
   - `04_analytics/01_vistas_kpi.sql`

---

## Autor

Proyecto desarrollado como parte del portfolio personal de Mateo Elías Ibañez.
