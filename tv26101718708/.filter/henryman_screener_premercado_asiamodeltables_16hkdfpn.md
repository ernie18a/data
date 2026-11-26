# Henryman - Screener Pre-Mercado - Asia-Model+Tables

- url: https://www.tradingview.com/script/16hKdFpn/
- type: indicator
- pine_id: PUB;1e1a4d3b19eb4aabb06e0b89cd5a575c
- version: 1.0

## Description

## ¿Qué es esto?

Es un "panel de control" (un indicador) que se pone encima de un gráfico de precios en TradingView. Te dice de un vistazo, para varios instrumentos a la vez (EUR/USD, oro, NASDAQ, etc.), tres cosas: qué __modelo__ (patrón) se ha formado, cuánto se movió el precio en la __sesión asiática__ de la noche, y qué __probabilidad__ histórica hay de que el precio se mueva a uno o a los dos lados ese día.

## Cómo instalarlo (paso a paso)

1. Entra en __tradingview.com__ y abre cualquier gráfico (arriba pone el nombre del instrumento, p. ej. EURUSD).
2. En la parte de abajo de la pantalla pulsa el botón __"Pine Editor"__ (Editor de Pine). Se abre una ventana de texto.
3. Borra lo que haya y __pega todo el contenido__ del archivo `screener_henryman.txt`.
4. Pulsa __"Add to chart"__ (Añadir al gráfico). Verás aparecer una __tabla__ en una esquina del gráfico.

## Cómo configurarlo

1. Pasa el ratón por el nombre del indicador (arriba a la izquierda del gráfico) y pulsa el icono de __engranaje__ (Ajustes / Settings).
2. __"Instrumentos"__: hay 12 filas. En cada una marcas la casilla para activarla, eliges el símbolo (p. ej. `OANDA:EURUSD`) y el tipo (preset) que le corresponde. Activa solo los que vayas a mirar.
3. __"TF del Modelo"__: aquí eliges en qué velas se busca el patrón. Opciones: `240` = 4 horas, `720` = 12 horas, `D` = diario, `W` = semanal. (Diario es el normal).
4. El resto (colores, posición de la tabla, rango asiático) puedes dejarlo como viene.

## Cómo leer la tabla

Cada fila es un instrumento, y las columnas te dicen:

- __Modelo__: el patrón detectado. Verde = alcista (sugiere subida), rojo/granate = bajista (sugiere bajada), un guion "—" = no hay patrón claro.
- __Rango Asia__: cuántos pips/puntos se movió el precio durante la noche asiática.
- __Día / Doble / 1 lado / Calidad__: estadísticas de qué suele pasar ese día y con ese tamaño de rango.

## Los 3 modelos (en lenguaje normal)

Mira siempre __dos velas seguidas__: la de la izquierda (referencia) y la de la derecha (la que actúa). NO importa el color de las velas, solo la forma:

- __M2__ → la vela derecha primero "engaña" rompiendo un poco por un extremo de la izquierda (manipulación) pero luego vuelve dentro del rango. Es un aviso de posible giro.
- __M3__ → la vela derecha cierra con fuerza al otro lado, fuera del rango de la izquierda, sin haber hecho ese "engaño" previo.
- __M3+__ → el más completo: primero engaña (rompe un extremo) y además cierra con fuerza al otro lado. Es la señal más fuerte.

(En alcista el "engaño" es por abajo y el cierre fuerte por arriba; en bajista es justo al revés).

## Idea clave

El indicador NO opera por ti: es una ayuda visual para detectar rápido en qué instrumentos hay un patrón y con qué probabilidad histórica, para que tú decidas dónde mirar.

## Source Code

````pine
//@version=5
// =============================================================================
//  HENRYMAN — Screener Pre-Mercado (Rango Asiático + Modelo PO3 + Tablas)
// =============================================================================
//  Une en un solo panel:
//    1) Detección automática del Modelo. SOLO existen 3 modelos: M2, M3 y M3+.
//       Se detectan por el PATRÓN (geometría) entre dos velas del TF del modelo
//       (V1 = vela izquierda/referencia, V2 = vela de acción), SIN mirar el
//       color de las velas. Vale tanto para escenario alcista como bajista.
//       TF del modelo configurable: 4h (240), 12h (720), Diario (D) o Semanal (W).
//         M2  = barre el extremo de V1 (manipulación) y recupera el rango (sin
//               cerrar con cuerpo al otro lado).
//         M3  = cierra con cuerpo al otro lado del rango de V1 SIN barrer el
//               extremo opuesto.
//         M3+ = barre el extremo de V1 (manipulación) Y cierra con cuerpo al
//               otro lado del rango.


//    2) Medición del Rango Asiático (sesión 18:00-02:00 NY) en pips/puntos,
//       lógica equivalente a rangoasia.txt.
//    3) Día de la semana (Lunes..Viernes).
//    4) Probabilidad según las tablas estadísticas (tablas_data) por:
//         - Bucket del rango Asia
//         - Día de la semana
//       Mostrando Doble liquidación vs Un solo lado + Calidad/lectura.
//
//  Permite activar hasta 12 instrumentos. Activa solo los que uses.
//  Cada slot tiene: Activar (on/off) + Símbolo + Preset de tabla.
// =============================================================================
indicator("Henryman — Screener Pre-Mercado [Asia+Modelo+Tablas]", overlay=true, max_labels_count=20, max_lines_count=500, max_boxes_count=500)


// =============================================================================
//  CONFIGURACIÓN GENERAL
// =============================================================================
tzInput     = input.string("America/New_York", "Zona horaria sesión", group="General",

                 tooltip="Zona en la que se interpreta la franja asiática para TODOS los instrumentos. " +
                         "Por defecto America/New_York (= UTC-4 en horario de verano, igual que tu gráfico). " +
                         "Si prefieres un offset fijo todo el año, escribe p.ej. GMT-4.")
tfModel     = input.string("D", "TF del Modelo", options=["240","720","D","W"], group="General",
                 tooltip="Velas usadas para detectar el modelo PO3. Opciones: 240=4h, 720=12h, D=Diario, W=Semanal (por defecto Diario).")


// Posición y estilo del panel
tblPos    = input.string("top_right", "Posición tabla",
                 options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group="Tabla")
txtSize   = input.string("normal", "Tamaño texto", options=["tiny","small","normal","large"], group="Tabla")
showHdr   = input.bool(true, "Mostrar cabecera", group="Tabla")

// --- Colores editables de la tabla ---
colText    = input.color(color.white,                 "Color del texto",        group="Colores")
colCellBg  = input.color(color.new(color.black, 0),   "Fondo de celdas",        group="Colores")
colHdrBg   = input.color(color.new(color.navy, 0),    "Fondo de cabecera",      group="Colores")
colHdrTxt  = input.color(color.white,                 "Texto de cabecera",      group="Colores")
colBorder  = input.color(color.new(color.gray, 40),   "Color de bordes",        group="Colores")
colBull    = input.color(color.new(color.green, 0),   "Fondo modelo Alcista",   group="Colores")
colBear    = input.color(color.new(color.maroon, 0),  "Fondo modelo Bajista",   group="Colores")
colNone    = input.color(color.new(color.black, 0),   "Fondo sin modelo",       group="Colores")
colProbHi  = input.color(color.new(color.green, 0),   "Prob. Alta (>=60%)",     group="Colores")
colProbMid = input.color(color.new(color.olive, 0),   "Prob. Media (45-60%)",   group="Colores")
colProbLo  = input.color(color.new(color.maroon, 0),  "Prob. Baja (<45%)",      group="Colores")
useProbCol = input.bool(true, "Colorear probabilidades (semáforo)", group="Colores")

// --- Diagnóstico (depuración del modelo) ---
//  Activa una fila extra de tooltip en la columna "Modelo" mostrando los valores
//  crudos V1 (open/high/low) y V2 (high/low/close) que lee cada símbolo. Útil
//  para verificar en REPLAY y EN VIVO qué velas diarias se están comparando
//  (p.ej. por qué 6B1! da un modelo distinto a 6E1!).
dbgModel = input.bool(false, "Diagnóstico modelo (tooltip V1/V2)", group="General",
             tooltip="Muestra en el tooltip de la celda Modelo los valores diarios V1 y V2 usados. Pasa el ratón por encima de la celda.")


// =============================================================================
//  RANGO ASIÁTICO — VISUAL (dibujo en la gráfica)
// =============================================================================
//  Dibuja en la gráfica la caja del rango asiático (high–low), las líneas de
//  máximo y mínimo y (opcional) la línea media (equilibrium).
//  AUTOMÁTICO POR INSTRUMENTO: el indicador detecta cuál de los 12 slots del
//  screener coincide con el símbolo de la gráfica actual y pinta el rango
//  asiático de ESE instrumento (usando SU sesión configurada). No hay que
//  elegir nada a mano: cambias de símbolo en la gráfica y, si está en el
//  screener, se pinta automáticamente su rango.
//  Réplica EXACTA de rangoasia.txt: niveles High/Low + línea media + caja
//  (borde blanco, relleno aqua translúcido), con extensión de +8h.
drawAsia    = input.bool(true,  "Dibujar Rango Asia en gráfica", group="Rango Asia — Visual")
asiaShowMid = input.bool(true, "Mostrar línea media (MA Level)", group="Rango Asia — Visual")
asiaHistN   = input.int(20, "Sesiones históricas a mostrar", minval=1, maxval=120, group="Rango Asia — Visual", tooltip="Número de sesiones asiáticas pasadas que se mantienen dibujadas en el gráfico. Las más antiguas se eliminan al superar este límite.")

// Como en rangoasia.txt:
asiaLineCol = input.color(color.aqua,                  "Level Color",        group="Rango Asia — Visual")
asiaMidCol  = input.color(color.orange,                "MA Level Color",     group="Rango Asia — Visual")
asiaBgCol   = input.color(color.new(color.aqua, 70),   "Background Color",   group="Rango Asia — Visual")
asiaLineW   = input.int(1, "Level Width", minval=1, maxval=4, group="Rango Asia — Visual")
asiaStyleIn = input.string("solid", "Level Style", options=["solid","dotted","dashed","arrow_both","arrow_left","arrow_right"], group="Rango Asia — Visual")

f_lineStyle() =>
    switch asiaStyleIn
        "dotted"      => line.style_dotted
        "dashed"      => line.style_dashed
        "arrow_both"  => line.style_arrow_both
        "arrow_left"  => line.style_arrow_left
        "arrow_right" => line.style_arrow_right
        => line.style_solid



f_pos() =>
    switch tblPos
        "top_right"     => position.top_right
        "top_left"      => position.top_left
        "bottom_right"  => position.bottom_right
        "bottom_left"   => position.bottom_left
        "middle_right"  => position.middle_right
        => position.middle_left

f_txt() =>
    switch txtSize
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.large

// =============================================================================
//  PRESETS DE TABLA (datos hardcodeados desde tablas_data/*.jpeg)
//  Para cada preset definimos:
//    - unit: divisor para convertir precio->pips/puntos
//    - unitName: "pips" o "pts"
//    - buckets (límites superiores) y prob. de DOBLE liquidación por bucket
//    - prob. DOBLE por día de la semana (Lun..Vie)
//  La prob. "un solo lado" = 100 - doble (aprox.).
// =============================================================================

// ---- Buckets: límite superior de cada tramo (en la unidad del preset) ----

// Devuelve el índice de bucket (0..n) según el valor del rango Asia.
f_bucketIdx(preset, v) =>
    int idx = 0
    if preset == "EURUSD" or preset == "GBPUSD"
        // 0-15,15-25,25-35,35-45,45-60,60-80,+80
        idx := v<=15?0 : v<=25?1 : v<=35?2 : v<=45?3 : v<=60?4 : v<=80?5 : 6
    else if preset == "AUDUSD"
        // 0-15,15-25,25-35,35-45,45-60,60-80,+80
        idx := v<=15?0 : v<=25?1 : v<=35?2 : v<=45?3 : v<=60?4 : v<=80?5 : 6
    else if preset == "USDCAD"
        // 0-15,15-25,25-35,35-45,45-60,60-80,+80
        idx := v<=15?0 : v<=25?1 : v<=35?2 : v<=45?3 : v<=60?4 : v<=80?5 : 6
    else if preset == "XAUUSD"
        // 0-5,5-10,10-15,15-20,20-30,30-40,+40
        idx := v<=5?0 : v<=10?1 : v<=15?2 : v<=20?3 : v<=30?4 : v<=40?5 : 6
    else if preset == "NQ"
        // 0-25,25-50,50-75,75-100,100-150,150-200,200-300,+300
        idx := v<=25?0 : v<=50?1 : v<=75?2 : v<=100?3 : v<=150?4 : v<=200?5 : v<=300?6 : 7
    else if preset == "DAX"
        // 0-40,40-60,60-80,80-110,110-150,150-220,+220
        idx := v<=40?0 : v<=60?1 : v<=80?2 : v<=110?3 : v<=150?4 : v<=220?5 : 6
    else // BRENT(10y): 0-0.15,0.15-0.25,0.25-0.35,0.35-0.45,0.45-0.60,0.60-0.80,+0.80
        idx := v<=0.15?0 : v<=0.25?1 : v<=0.35?2 : v<=0.45?3 : v<=0.60?4 : v<=0.80?5 : 6
    idx

// Etiqueta textual del bucket
f_bucketLabel(preset, i) =>
    string s = ""
    if preset == "EURUSD" or preset == "GBPUSD" or preset == "AUDUSD" or preset == "USDCAD"
        s := i==0?"0-15" : i==1?"15-25" : i==2?"25-35" : i==3?"35-45" : i==4?"45-60" : i==5?"60-80" : "+80"
    else if preset == "XAUUSD"
        s := i==0?"0-5" : i==1?"5-10" : i==2?"10-15" : i==3?"15-20" : i==4?"20-30" : i==5?"30-40" : "+40"
    else if preset == "NQ"
        s := i==0?"0-25" : i==1?"25-50" : i==2?"50-75" : i==3?"75-100" : i==4?"100-150" : i==5?"150-200" : i==6?"200-300" : "+300"
    else if preset == "DAX"
        s := i==0?"0-40" : i==1?"40-60" : i==2?"60-80" : i==3?"80-110" : i==4?"110-150" : i==5?"150-220" : "+220"
    else
        s := i==0?"0-0.15" : i==1?"0.15-0.25" : i==2?"0.25-0.35" : i==3?"0.35-0.45" : i==4?"0.45-0.60" : i==5?"0.60-0.80" : "+0.80"
    s

// Prob. DOBLE liquidación por bucket (%)
f_bucketDoble(preset, i) =>
    float p = na
    if preset == "EURUSD"
        // Ambos lados: 72.84,60.16,47.56,39.29,32.85,21.05,15.79
        p := i==0?72.84 : i==1?60.16 : i==2?47.56 : i==3?39.29 : i==4?32.85 : i==5?21.05 : 15.79
    else if preset == "GBPUSD"
        // Prob. ambos lados: 72.36,63.99,58.93,46.96,40.96,28.57,18.87
        p := i==0?72.36 : i==1?63.99 : i==2?58.93 : i==3?46.96 : i==4?40.96 : i==5?28.57 : 18.87
    else if preset == "AUDUSD"
        // Doble: 50.98,40.26,29.50,24.95,15.31,11.11,3.64
        p := i==0?50.98 : i==1?40.26 : i==2?29.50 : i==3?24.95 : i==4?15.31 : i==5?11.11 : 3.64
    else if preset == "USDCAD"
        // Doble liq: 73.66,61.75,53.94,42.78,30.37,25.24,20.00
        p := i==0?73.66 : i==1?61.75 : i==2?53.94 : i==3?42.78 : i==4?30.37 : i==5?25.24 : 20.00
    else if preset == "XAUUSD"
        // Doble liq: 56.11,46.61,34.09,22.09,28.68,17.19,14.01
        p := i==0?56.11 : i==1?46.61 : i==2?34.09 : i==3?22.09 : i==4?28.68 : i==5?17.19 : 14.01
    else if preset == "NQ"
        // Doble: 65.09,66.34,59.31,59.93,53.62,51.79,30.95,20.00
        p := i==0?65.09 : i==1?66.34 : i==2?59.31 : i==3?59.93 : i==4?53.62 : i==5?51.79 : i==6?30.95 : 20.00
    else if preset == "DAX"
        // Doble: 67.76,60.00,51.70,51.30,40.96,28.41,24.42
        p := i==0?67.76 : i==1?60.00 : i==2?51.70 : i==3?51.30 : i==4?40.96 : i==5?28.41 : 24.42
    else
        // BRENT 10y Doble: 90.24,76.56,71.88,69.88,62.16,58.21,44.96
        p := i==0?90.24 : i==1?76.56 : i==2?71.88 : i==3?69.88 : i==4?62.16 : i==5?58.21 : 44.96
    p

// Calidad / lectura por bucket (texto corto)
f_bucketQuality(preset, i) =>
    string q = ""
    if preset == "EURUSD"
        q := i<=1?"Alta" : i<=4?"Media" : "Baja"
    else if preset == "GBPUSD"
        q := i<=2?"Alta" : i<=4?"Media" : "Baja"
    else if preset == "AUDUSD"
        q := i==0?"Media" : i<=4?"Alta" : i==5?"Media" : "Baja"
    else if preset == "USDCAD"
        q := i<=5?"Alta" : "Media"
    else if preset == "XAUUSD"
        q := i<=2?"Alta" : "Media"
    else if preset == "NQ"
        q := i<=6?"Alta" : "Baja"
    else if preset == "DAX"
        q := i<=3?"Alta" : i<=5?"Media" : "Baja"
    else
        q := i==0?"Media" : "Alta"
    q

// Prob. DOBLE liquidación por DÍA de la semana (%) — Lun=1 .. Vie=5
f_dayDoble(preset, dow) =>
    float p = na
    // dow: dayofweek -> 2=Mon..6=Fri (Pine) ; convertimos a 1..5
    int d = dow == dayofweek.monday?1 : dow==dayofweek.tuesday?2 : dow==dayofweek.wednesday?3 : dow==dayofweek.thursday?4 : dow==dayofweek.friday?5 : 0
    if preset == "EURUSD"
        p := d==1?45.97 : d==2?57.94 : d==3?59.29 : d==4?55.04 : d==5?55.89 : na
    else if preset == "GBPUSD"
        p := d==1?45.91 : d==2?55.39 : d==3?58.47 : d==4?55.39 : d==5?54.65 : na
    else if preset == "AUDUSD"
        p := d==1?24.39 : d==2?28.68 : d==3?33.71 : d==4?26.12 : d==5?33.33 : na
    else if preset == "USDCAD"
        p := d==1?41.09 : d==2?56.42 : d==3?58.13 : d==4?55.12 : d==5?53.54 : na
    else if preset == "XAUUSD"
        p := d==1?28.44 : d==2?43.58 : d==3?50.84 : d==4?42.64 : d==5?44.00 : na
    else if preset == "NQ"
        p := d==1?44.60 : d==2?63.07 : d==3?62.74 : d==4?59.33 : d==5?64.32 : na
    else if preset == "DAX"
        p := d==1?49.39 : d==2?53.53 : d==3?53.27 : d==4?53.25 : d==5?55.64 : na
    else
        // BRENT 10y doble por día: 55.32,63.87,68.54,67.60,63.36
        p := d==1?55.32 : d==2?63.87 : d==3?68.54 : d==4?67.60 : d==5?63.36 : na
    p

// Unidad (divisor de precio -> pips/puntos) y nombre
f_unitDiv(preset) =>
    (preset=="EURUSD" or preset=="GBPUSD" or preset=="AUDUSD" or preset=="USDCAD") ? 0.0001 : 1.0
f_unitName(preset) =>
    (preset=="EURUSD" or preset=="GBPUSD" or preset=="AUDUSD" or preset=="USDCAD") ? "pips" : "pts"

// Mejor día (texto) por preset — para nota informativa
f_bestDay(preset) =>
    preset=="EURUSD"?"Mié" : preset=="GBPUSD"?"Mié" : preset=="AUDUSD"?"Mié" : preset=="USDCAD"?"Mié" :
     preset=="XAUUSD"?"Mié" : preset=="NQ"?"Vie" : preset=="DAX"?"Vie" : "Mié"

// =============================================================================
//  SLOTS DE INSTRUMENTOS (12)
// =============================================================================
// Cada slot tiene su PROPIA sesión asiática (campo "Sesión").
// Defaults: forex/US = 1700-0100 ; DAX = 2230-0830 (en la zona horaria del input tzInput).
en1 = input.bool(true,  "▸ 1", inline="s1", group="Instrumentos")
sy1 = input.symbol("OANDA:EURUSD", "", inline="s1", group="Instrumentos")
pr1 = input.string("EURUSD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s1", group="Instrumentos")
se1 = input.session("1700-0100", "Sesión", inline="s1", group="Instrumentos")

en2 = input.bool(true,  "▸ 2", inline="s2", group="Instrumentos")
sy2 = input.symbol("OANDA:GBPUSD", "", inline="s2", group="Instrumentos")
pr2 = input.string("GBPUSD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s2", group="Instrumentos")
se2 = input.session("1700-0100", "Sesión", inline="s2", group="Instrumentos")

en3 = input.bool(false, "▸ 3", inline="s3", group="Instrumentos")
sy3 = input.symbol("OANDA:AUDUSD", "", inline="s3", group="Instrumentos")
pr3 = input.string("AUDUSD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s3", group="Instrumentos")
se3 = input.session("1700-0100", "Sesión", inline="s3", group="Instrumentos")

en4 = input.bool(false, "▸ 4", inline="s4", group="Instrumentos")
sy4 = input.symbol("OANDA:USDCAD", "", inline="s4", group="Instrumentos")
pr4 = input.string("USDCAD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s4", group="Instrumentos")
se4 = input.session("1700-0100", "Sesión", inline="s4", group="Instrumentos")

en5 = input.bool(false, "▸ 5", inline="s5", group="Instrumentos")
sy5 = input.symbol("OANDA:XAUUSD", "", inline="s5", group="Instrumentos")
pr5 = input.string("XAUUSD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s5", group="Instrumentos")
se5 = input.session("1700-0100", "Sesión", inline="s5", group="Instrumentos")

en6 = input.bool(false, "▸ 6", inline="s6", group="Instrumentos")
sy6 = input.symbol("CME_MINI:NQ1!", "", inline="s6", group="Instrumentos")
pr6 = input.string("NQ", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s6", group="Instrumentos")
se6 = input.session("1700-0100", "Sesión", inline="s6", group="Instrumentos")

en7 = input.bool(false, "▸ 7", inline="s7", group="Instrumentos")
sy7 = input.symbol("FX:GER30", "", inline="s7", group="Instrumentos")
pr7 = input.string("DAX", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s7", group="Instrumentos")
se7 = input.session("2230-0830", "Sesión", inline="s7", group="Instrumentos")

en8 = input.bool(false, "▸ 8", inline="s8", group="Instrumentos")
sy8 = input.symbol("TVC:UKOIL", "", inline="s8", group="Instrumentos")
pr8 = input.string("BRENT(10y)", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s8", group="Instrumentos")
se8 = input.session("1700-0100", "Sesión", inline="s8", group="Instrumentos")

en9 = input.bool(false, "▸ 9", inline="s9", group="Instrumentos")
sy9 = input.symbol("CME:6E1!", "", inline="s9", group="Instrumentos")
pr9 = input.string("EURUSD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s9", group="Instrumentos")
se9 = input.session("1700-0100", "Sesión", inline="s9", group="Instrumentos")

en10 = input.bool(false, "▸ 10", inline="s10", group="Instrumentos")
sy10 = input.symbol("CME:6B1!", "", inline="s10", group="Instrumentos")
pr10 = input.string("GBPUSD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s10", group="Instrumentos")
se10 = input.session("1700-0100", "Sesión", inline="s10", group="Instrumentos")

en11 = input.bool(false, "▸ 11", inline="s11", group="Instrumentos")
sy11 = input.symbol("OANDA:AUDUSD", "", inline="s11", group="Instrumentos")
pr11 = input.string("AUDUSD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s11", group="Instrumentos")
se11 = input.session("1700-0100", "Sesión", inline="s11", group="Instrumentos")

en12 = input.bool(false, "▸ 12", inline="s12", group="Instrumentos")
sy12 = input.symbol("OANDA:USDCAD", "", inline="s12", group="Instrumentos")
pr12 = input.string("USDCAD", "", options=["EURUSD","GBPUSD","AUDUSD","USDCAD","XAUUSD","NQ","DAX","BRENT(10y)"], inline="s12", group="Instrumentos")
se12 = input.session("1700-0100", "Sesión", inline="s12", group="Instrumentos")


// =============================================================================
//  CÁLCULO POR SÍMBOLO
//  - Rango Asia: high/low de la última sesión asiática COMPLETADA.
//  - Modelo: lógica de estrategia0.txt (V1 vs V2 = idx 2 vs idx 1 en D).
// =============================================================================

// --- (A) Rango Asia ---
// ENFOQUE ROBUSTO (Pine v5): traemos el OHLC del símbolo al chart con
// request.security y calculamos el rango asiático LOCALMENTE. Así la sesión y la
// zona horaria (que son del chart) SIEMPRE se respetan por cada slot — evitamos
// el problema de que la sesión no se propague al contexto remoto.
//
// f_inSession devuelve true si la barra ACTUAL del chart cae dentro de _session
// (interpretada en _tz). Se evalúa localmente, por eso es fiable.
f_inSession(_session, _tz) =>
    not na(time(timeframe.period, _session, _tz))

// Calcula el rango de la última sesión asiática COMPLETADA usando high/low del
// símbolo solicitado (_hi/_lo vienen ya traídos por request.security), con la
// pertenencia a sesión calculada localmente (_inAsia).
f_asiaRangeLocal(_hi, _lo, _inAsia) =>
    newAsia = _inAsia and not _inAsia[1]
    var float aHi = na
    var float aLo = na
    var float aHiDone = na
    var float aLoDone = na
    if newAsia
        aHi := _hi
        aLo := _lo
    else if _inAsia
        aHi := math.max(aHi, _hi)
        aLo := math.min(aLo, _lo)
    endAsia = not _inAsia and _inAsia[1]
    if endAsia
        aHiDone := aHi
        aLoDone := aLo
    aHiDone - aLoDone

// Trae high/low del símbolo (UNA sola llamada con tupla) y calcula el rango
// asiático con la sesión local. Usar una tupla en vez de dos request.security
// reduce el nº de "securities" (límite 40 en TradingView).
f_reqAsia(_sym, _session, _tz) =>
    [h, l] = request.security(_sym, timeframe.period, [high, low], ignore_invalid_symbol=true)
    inA = f_inSession(_session, _tz)
    f_asiaRangeLocal(h, l, inA)





// --- (B) Modelo PO3: se calcula en el contexto del símbolo (TF del modelo) ---
// V_ref = vela [2], V_act = vela [1] (vela izquierda vs vela de acción/derecha).
//
//  REPLANTEO DE ESCENARIOS (según las imágenes "MODELOS ALCISTAS/BAJISTAS"):
//  NO se mira el color de las velas, SOLO la geometría del patrón. Solo existen
//  3 modelos: M2, M3 y M3+. Se usan SIEMPRE los cierres con CUERPO (close), no
//  las mechas.
//
//  Definiciones base (ALCISTA; el bajista es simétrico):
//    sweep_bull   = V_act barre (perfora) el LOW de V_ref            -> "Manipulación"
//    break_bull   = V_act CIERRA CON CUERPO por encima del HIGH de V_ref -> "Objetivo"
//    recover_bull = V_act cierra de vuelta DENTRO del rango de V_ref (>= LOW de V_ref)
//                   -> recupera tras el barrido (no se queda fuera por debajo)
//
//  Clasificación (idéntica para alcista/bajista):
//    M3+ : sweep  Y  break          -> barre el extremo y cierra con cuerpo al otro lado
//    M3  : break  Y  NO sweep       -> cierra con cuerpo al otro lado SIN barrer el extremo opuesto
//    M2  : sweep  Y  recover Y NO break -> barre el extremo (manipulación) y recupera
//                                          dentro del rango, sin cerrar al otro lado
//    (un barrido SIN recuperar el rango y SIN break = cierre débil -> NO es modelo)
//
//   model_code: 0=sin modelo, 2=M2, 3=M3, 4=M3+ (alcista positivo, bajista negativo)
//  IMPORTANTE: recibe los valores YA alineados (V1 = [2], V2 = [1]).
//  La obtención de esas velas se hace con request.security usando
//  lookahead=barmerge.lookahead_on para evitar el desfase de una vela.
f_modelCalc(vRef_o, vRef_h, vRef_l, vAct_h, vAct_l, vAct_c) =>
    // --- ALCISTA ---
    sweep_bull   = vAct_l < vRef_l          // barre el LOW de V_ref (manipulación)
    break_bull   = vAct_c > vRef_h          // cierra con CUERPO sobre el HIGH de V_ref (objetivo)
    recover_bull = vAct_c >= vRef_l         // cierre vuelve dentro del rango de V_ref
    // --- BAJISTA (simétrico) ---
    sweep_bear   = vAct_h > vRef_h          // barre el HIGH de V_ref (manipulación)
    break_bear   = vAct_c < vRef_l          // cierra con CUERPO bajo el LOW de V_ref (objetivo)
    recover_bear = vAct_c <= vRef_h         // cierre vuelve dentro del rango de V_ref

    int model = 0
    // ALCISTAS
    if sweep_bull and break_bull
        model := 4                                   // M3+: barre LOW y cierra sobre HIGH
    else if break_bull and not sweep_bull
        model := 3                                   // M3 : cierra sobre HIGH sin barrer LOW
    else if sweep_bull and not break_bull and recover_bull
        model := 2                                   // M2 : barre LOW (manipulación) y recupera
    // BAJISTAS (simétrico)
    if sweep_bear and break_bear
        model := -4                                  // M3+: barre HIGH y cierra bajo LOW
    else if break_bear and not sweep_bear
        model := -3                                  // M3 : cierra bajo LOW sin barrer HIGH
    else if sweep_bear and not break_bear and recover_bear
        model := -2                                  // M2 : barre HIGH (manipulación) y recupera
    model






// Texto del modelo. NO existe M1: cualquier "sweep sin break" se considera M2
// (tanto alcista como bajista). Códigos: 4=M3+, 3=M3, 2=M2 ; negativos=bajista ; 0="—"
f_modelTxt(m) =>
    m==4?"Alcista M3+" : m==3?"Alcista M3" : m==2?"Alcista M2" :
     m==-4?"Bajista M3+" : m==-3?"Bajista M3" : m==-2?"Bajista M2" : "—"


f_modelCol(m) =>
    m>0?colBull : m<0?colBear : colNone


// Color por probabilidad (semáforo). Si useProbCol=false -> fondo de celda normal.
f_probCol(p) =>
    not useProbCol ? colCellBg : na(p)?colCellBg : p>=60?colProbHi : p>=45?colProbMid : colProbLo


// Nombre corto del símbolo (sin exchange)
f_short(sym) =>
    arr = str.split(sym, ":")
    array.size(arr) > 1 ? array.get(arr, 1) : sym

// Día de la semana (texto) — del CHART (mismo día para todos)
dowChart = dayofweek
dayTxt = dowChart==dayofweek.monday?"Lunes" : dowChart==dayofweek.tuesday?"Martes" :
         dowChart==dayofweek.wednesday?"Miércoles" : dowChart==dayofweek.thursday?"Jueves" :
         dowChart==dayofweek.friday?"Viernes" : "Fin de semana"

// =============================================================================
//  EJECUCIÓN: por cada símbolo se hacen request.security:
//    - rango Asia (en el TF del chart, contexto del símbolo)
//    - modelo PO3: se traen las velas V1 (anteayer) y V2 (ayer) con
//      lookahead=barmerge.lookahead_on (IDÉNTICO a estrategia0.txt) y se calcula
//      el modelo con esos valores YA ALINEADOS. Esto evita el desfase de una
//      vela que provocaba que la Libra (y otros) saliera mal clasificada.
//  Se evita el anidamiento de request.security (no permitido en Pine v5).
// =============================================================================
// Modelo PO3 consistente en REPLAY y TIEMPO REAL para TODOS los símbolos.
//
//  Clave: el offset histórico ([1]/[2]) se aplica DENTRO de la expresión de
//  request.security y se usa lookahead=barmerge.lookahead_on. Así TradingView
//  ancla cada vela diaria al TIEMPO de la barra del gráfico (sea la barra del
//  replay o la actual). Esto es EXACTAMENTE lo que hace estrategia0.txt, y hace
//  que el símbolo del propio gráfico (p.ej. 6B1!) y los demás slots (6E1!,
//  EURUSD...) se evalúen todos en el MISMO instante temporal -> resultados
//  coherentes en backtest (replay) y en vivo.
//
//  Para que el modelo del DÍA EN CURSO no aparezca antes de tiempo, el día se
//  "cierra" usando V1 = vela [2] (anteayer, cerrada) y V2 = vela [1] (ayer,
//  cerrada). Con lookahead_on + offset histórico NO hay repintado, porque los
//  índices [1]/[2] siempre apuntan a velas YA cerradas respecto a la barra
//  actual del gráfico.
//  Devuelve [model_code, dbgText] donde dbgText resume las velas V1/V2 leídas
//  (para el tooltip de diagnóstico). El modelo se calcula con esos valores.
f_reqModel(_sym) =>
    [vRo, vRh, vRl, vAh, vAl, vAc] = request.security(_sym, tfModel, [open[2], high[2], low[2], high[1], low[1], close[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    int  m   = na(vRo) or na(vAc) ? 0 : f_modelCalc(vRo, vRh, vRl, vAh, vAl, vAc)
    string dbg = na(vRo) or na(vAc) ? "Sin datos diarios (V1/V2 = na)" :
         "V1(ref): O=" + str.tostring(vRo) + " H=" + str.tostring(vRh) + " L=" + str.tostring(vRl) +
         "\nV2(act): H=" + str.tostring(vAh) + " L=" + str.tostring(vAl) + " C=" + str.tostring(vAc) +
         "\nsweep_bull=" + str.tostring(vAl < vRl) + "  break_bull=" + str.tostring(vAc > vRh) + "  recover_bull=" + str.tostring(vAc >= vRl) +
         "\nsweep_bear=" + str.tostring(vAh > vRh) + "  break_bear=" + str.tostring(vAc < vRl) + "  recover_bear=" + str.tostring(vAc <= vRh)

    [m, dbg]


ar1  = f_reqAsia(sy1,  se1,  tzInput)
[md1, dbg1]   = f_reqModel(sy1)
ar2  = f_reqAsia(sy2,  se2,  tzInput)
[md2, dbg2]   = f_reqModel(sy2)
ar3  = f_reqAsia(sy3,  se3,  tzInput)
[md3, dbg3]   = f_reqModel(sy3)
ar4  = f_reqAsia(sy4,  se4,  tzInput)
[md4, dbg4]   = f_reqModel(sy4)
ar5  = f_reqAsia(sy5,  se5,  tzInput)
[md5, dbg5]   = f_reqModel(sy5)
ar6  = f_reqAsia(sy6,  se6,  tzInput)
[md6, dbg6]   = f_reqModel(sy6)
ar7  = f_reqAsia(sy7,  se7,  tzInput)
[md7, dbg7]   = f_reqModel(sy7)
ar8  = f_reqAsia(sy8,  se8,  tzInput)
[md8, dbg8]   = f_reqModel(sy8)
ar9  = f_reqAsia(sy9,  se9,  tzInput)
[md9, dbg9]   = f_reqModel(sy9)
ar10 = f_reqAsia(sy10, se10, tzInput)
[md10, dbg10] = f_reqModel(sy10)
ar11 = f_reqAsia(sy11, se11, tzInput)
[md11, dbg11] = f_reqModel(sy11)
ar12 = f_reqAsia(sy12, se12, tzInput)
[md12, dbg12] = f_reqModel(sy12)







// =============================================================================
//  TABLA
// =============================================================================
var table t = table.new(f_pos(), 9, 14, border_width=1, border_color=colBorder)

// Pinta una fila del screener (dbg = texto de diagnóstico V1/V2 para el tooltip)
f_row(idx, en, sym, preset, ar, md, dbg) =>
    if en
        // valor del rango en la unidad del preset
        unitV  = ar / f_unitDiv(preset)
        bIdx   = f_bucketIdx(preset, unitV)
        bLbl   = f_bucketLabel(preset, bIdx)
        pDobB  = f_bucketDoble(preset, bIdx)
        qual   = f_bucketQuality(preset, bIdx)
        pDobD  = f_dayDoble(preset, dowChart)
        un     = f_unitName(preset)

        table.cell(t, 0, idx, f_short(sym), text_color=colText, text_size=f_txt(), bgcolor=colCellBg)
        table.cell(t, 1, idx, f_modelTxt(md), text_color=colText, text_size=f_txt(), bgcolor=f_modelCol(md), tooltip=dbgModel ? dbg : "")

        table.cell(t, 2, idx, na(ar)?"—":str.tostring(unitV, "#.##")+" "+un, text_color=colText, text_size=f_txt(), bgcolor=colCellBg)
        table.cell(t, 3, idx, na(ar)?"—":bLbl, text_color=colText, text_size=f_txt(), bgcolor=colCellBg)
        table.cell(t, 4, idx, dayTxt, text_color=colText, text_size=f_txt(), bgcolor=colCellBg)
        table.cell(t, 5, idx, na(pDobB)?"—":str.tostring(pDobB,"#.#")+"%", text_color=colText, text_size=f_txt(), bgcolor=f_probCol(pDobB))
        table.cell(t, 6, idx, na(pDobB)?"—":str.tostring(100-pDobB,"#.#")+"%", text_color=colText, text_size=f_txt(), bgcolor=colCellBg)
        table.cell(t, 7, idx, na(pDobD)?"—":str.tostring(pDobD,"#.#")+"%", text_color=colText, text_size=f_txt(), bgcolor=f_probCol(pDobD))
        table.cell(t, 8, idx, qual, text_color=colText, text_size=f_txt(), bgcolor=colCellBg)

if barstate.islast
    table.clear(t, 0, 0, 8, 13)
    int r = 0
    if showHdr
        table.cell(t, 0, 0, "Instrumento", text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 1, 0, "Modelo",      text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 2, 0, "Rango Asia",  text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 3, 0, "Bucket",      text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 4, 0, "Día",         text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 5, 0, "Doble (bucket)", text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 6, 0, "1 lado",      text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 7, 0, "Doble (día)", text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        table.cell(t, 8, 0, "Calidad",     text_color=colHdrTxt, text_size=f_txt(), bgcolor=colHdrBg)
        r := 1


    f_row(r,      en1,  sy1,  pr1,  ar1,  md1,  dbg1)
    f_row(r+1,    en2,  sy2,  pr2,  ar2,  md2,  dbg2)
    f_row(r+2,    en3,  sy3,  pr3,  ar3,  md3,  dbg3)
    f_row(r+3,    en4,  sy4,  pr4,  ar4,  md4,  dbg4)
    f_row(r+4,    en5,  sy5,  pr5,  ar5,  md5,  dbg5)
    f_row(r+5,    en6,  sy6,  pr6,  ar6,  md6,  dbg6)
    f_row(r+6,    en7,  sy7,  pr7,  ar7,  md7,  dbg7)
    f_row(r+7,    en8,  sy8,  pr8,  ar8,  md8,  dbg8)
    f_row(r+8,    en9,  sy9,  pr9,  ar9,  md9,  dbg9)
    f_row(r+9,    en10, sy10, pr10, ar10, md10, dbg10)
    f_row(r+10,   en11, sy11, pr11, ar11, md11, dbg11)
    f_row(r+11,   en12, sy12, pr12, ar12, md12, dbg12)



// =============================================================================
//  DIBUJO DEL RANGO ASIÁTICO EN LA GRÁFICA (automático por instrumento)
// =============================================================================
//  Detecta automáticamente cuál de los 12 slots del screener coincide con el
//  símbolo de la gráfica ACTUAL y pinta el rango asiático de ESE instrumento,
//  usando SU sesión configurada. No hay que elegir nada a mano: si el símbolo
//  del gráfico está en el screener, se pinta su rango; si no, no se dibuja.
//
//  Usamos el high/low NATIVO del chart (exacto), no request.security, porque
//  solo dibujamos cuando el símbolo del slot coincide con el del gráfico.

// Comparación tolerante: ¿el símbolo del slot apunta al símbolo del gráfico?
// Normalizamos quedándonos con el ticker (parte tras ":") y comparamos contra
// syminfo.ticker (p.ej. "OANDA:EURUSD" -> "EURUSD" == syminfo.ticker "EURUSD").
chartTicker = syminfo.ticker
f_slotMatch(_sym) =>
    s = f_short(_sym)
    s == chartTicker or str.contains(chartTicker, s) or str.contains(_sym, chartTicker)

// Recorremos los slots y elegimos la sesión del PRIMER slot que coincida.
// matchedSes = sesión a usar ; matchedName = nombre para el aviso/etiqueta.
matchedFound = false
string matchedSes  = na
string matchedName = na
if drawAsia
    if not matchedFound and f_slotMatch(sy1)
        matchedSes    := se1
        matchedName   := f_short(sy1)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy2)
        matchedSes    := se2
        matchedName   := f_short(sy2)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy3)
        matchedSes    := se3
        matchedName   := f_short(sy3)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy4)
        matchedSes    := se4
        matchedName   := f_short(sy4)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy5)
        matchedSes    := se5
        matchedName   := f_short(sy5)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy6)
        matchedSes    := se6
        matchedName   := f_short(sy6)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy7)
        matchedSes    := se7
        matchedName   := f_short(sy7)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy8)
        matchedSes    := se8
        matchedName   := f_short(sy8)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy9)
        matchedSes    := se9
        matchedName   := f_short(sy9)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy10)
        matchedSes    := se10
        matchedName   := f_short(sy10)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy11)
        matchedSes    := se11
        matchedName   := f_short(sy11)
        matchedFound  := true
    if not matchedFound and f_slotMatch(sy12)
        matchedSes    := se12
        matchedName   := f_short(sy12)
        matchedFound  := true


symMatch = drawAsia and matchedFound
drawSes  = matchedFound ? matchedSes : "1700-0100"

// =============================================================================
//  RÉPLICA EXACTA DE rangoasia.txt (portada a Pine v5)
// =============================================================================
//  Misma lógica/estética que el indicador "AsiaSessionHighLowMidLines":
//    - timeIsAllowed / newSession sobre la sesión del slot que coincide.
//    - refHigh / refLow = máximo/mínimo acumulados de la sesión EN CURSO.
//    - Durante la sesión: se borran y redibujan las líneas High/Low (l01/l02),
//      la línea media (maLine) y la caja (box1), extendiendo el extremo derecho
//      +8h (time + 8*60*60*1000), igual que el original.
//    - Al terminar la sesión: se "congela" la sesión que cerró (líneas fijas
//      + caja) y se AÑADE al histórico, sin borrar las sesiones anteriores
//      (como en el original, que las acumula). Se limita a "asiaHistN" sesiones.

timeIsAllowed = f_inSession(drawSes, tzInput)
newSession    = timeIsAllowed and not timeIsAllowed[1]

// refHigh / refLow acumulados (idéntico a las dos líneas var float del original)
var float refHigh = na
var float refLow  = na
refHigh := newSession ? high : (timeIsAllowed ? math.max(refHigh, high) : refHigh)
refLow  := newSession ? low  : (timeIsAllowed ? math.min(refLow,  low)  : refLow)

// x = time de inicio de la sesión actual (igual que "var int x" del original)
var int xStart = na
xStart := newSession ? time : xStart

// 8 horas en milisegundos (extensión a derecha, como en rangoasia.txt)
EIGHT_H = 8 * 60 * 60 * 1000

// --- Objetos de dibujo de la SESIÓN EN CURSO (se redibujan en vivo) ---
var line l01 = na          // High de la sesión en curso
var line l02 = na          // Low  de la sesión en curso
var line maLine = na       // línea media de la sesión en curso
var box  box1 = na         // caja de la sesión en curso

// --- HISTÓRICO de sesiones cerradas (acumulado) ---
//  Cada sesión que cierra deja su caja + líneas High/Low + media de forma
//  permanente (como en rangoasia.txt, que nunca borra las anteriores). Para no
//  saturar el gráfico se guardan en arrays y se eliminan las más antiguas
//  cuando se supera "asiaHistN".
var box[]  hBoxes = array.new<box>()
var line[] hHi    = array.new<line>()
var line[] hLo    = array.new<line>()
var line[] hMid   = array.new<line>()

// Recorta los arrays históricos a las últimas N sesiones (borra las antiguas).
f_trimBoxes(_arr, _n) =>
    while array.size(_arr) > _n
        box.delete(array.shift(_arr))
f_trimLines(_arr, _n) =>
    while array.size(_arr) > _n
        line.delete(array.shift(_arr))

if symMatch
    // ---- SESIÓN EN CURSO: redibujar High/Low/Media + caja extendida +8h ----
    if timeIsAllowed
        line.delete(l01)
        line.delete(l02)
        line.delete(maLine)
        box.delete(box1)
        l01 := line.new(xStart, refHigh, time + EIGHT_H, refHigh, xloc=xloc.bar_time, color=asiaLineCol, width=asiaLineW, style=f_lineStyle())
        l02 := line.new(xStart, refLow,  time + EIGHT_H, refLow,  xloc=xloc.bar_time, color=asiaLineCol, width=asiaLineW, style=f_lineStyle())
        if asiaShowMid
            maLine := line.new(xStart, (refHigh + refLow) / 2.0, time + EIGHT_H, (refHigh + refLow) / 2.0, xloc=xloc.bar_time, color=asiaMidCol, width=asiaLineW, style=f_lineStyle())
        box1 := box.new(xStart, refHigh, time, refLow, border_color=color.white, border_width=0, border_style=line.style_solid, extend=extend.none, xloc=xloc.bar_time, bgcolor=asiaBgCol)

    // ---- FIN DE SESIÓN: congelar la sesión que cerró y AÑADIRLA al histórico ----
    if not timeIsAllowed and timeIsAllowed[1]
        // valores de la sesión que acaba de cerrar (en [1])
        float hy = refHigh[1]
        float ly = refLow[1]
        int   x1 = xStart[1]
        int   x2 = time[1]
        // borrar SOLO los dibujos "en curso" (los históricos NO se tocan)
        line.delete(l01)
        line.delete(l02)
        line.delete(maLine)
        box.delete(box1)
        l01 := na
        l02 := na
        maLine := na
        box1 := na
        // crear objetos FIJOS de esta sesión y guardarlos en el histórico
        array.push(hHi,    line.new(x1, hy, x2, hy, xloc=xloc.bar_time, color=asiaLineCol, width=asiaLineW, style=f_lineStyle()))
        array.push(hLo,    line.new(x1, ly, x2, ly, xloc=xloc.bar_time, color=asiaLineCol, width=asiaLineW, style=f_lineStyle()))
        array.push(hBoxes, box.new(x1, hy, x2, ly, border_color=color.white, border_width=0, border_style=line.style_solid, extend=extend.none, xloc=xloc.bar_time, bgcolor=asiaBgCol))
        if asiaShowMid
            array.push(hMid, line.new(x1, (hy + ly) / 2.0, x2, (hy + ly) / 2.0, xloc=xloc.bar_time, color=asiaMidCol, width=asiaLineW, style=f_lineStyle()))
        // limitar a las últimas N sesiones
        f_trimBoxes(hBoxes, asiaHistN)
        f_trimLines(hHi,    asiaHistN)
        f_trimLines(hLo,    asiaHistN)
        f_trimLines(hMid,   asiaHistN)


// --- Aviso si NINGÚN slot del screener coincide con el símbolo del chart ---
var label warnLbl = na
if barstate.islast
    label.delete(warnLbl)
    if drawAsia and not matchedFound
        warnLbl := label.new(bar_index, high, "Rango Asia: el símbolo del gráfico (" + chartTicker + ") no está en el screener.\nAñádelo a un slot para ver su rango asiático dibujado.", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.orange, 10), textcolor=color.white, size=size.small)
````
