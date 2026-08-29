<!-- tradingview-pine-id: PUB;5a7a38c0b4cc4bf5b3c72735149cdd6d -->
<!-- tradingviewscripts-format: 1 -->
# Climatic Volume + RSI + Bollinger MULTI-TF (tus valores)

Source: https://www.tradingview.com/script/xIiKD7FZ/

## Description

**Climatic Volume + RSI + Bollinger — Multi-Timeframe (30m / 1h / 4h)**

Indicador de detección de puntos de entrada basado en la combinación de **volumen anómalo**, **momentum de precio (RSI)** y **estructura de rango (Bandas de Bollinger)**, con configuración calibrada de forma independiente para cada uno de tres timeframes: 30 minutos, 1 hora y 4 horas.

**Cómo funciona:**
- Detecta picos de **volumen climático**: momentos donde el volumen supera de forma significativa su promedio reciente, señal de que algo relevante está pasando en el mercado.
- Combina ese pico de volumen con una lectura de **RSI en zona extrema** (sobrecompra/sobreventa) y una condición de **Bandas de Bollinger**, configurable entre tres modos: toque de banda, cierre fuera de la banda, o reingreso tras haberla roto.
- Marca cada señal con una etiqueta y una línea vertical en el gráfico, para ubicar visualmente el momento exacto de la confluencia.
- Detecta automáticamente el timeframe del gráfico y aplica la configuración correspondiente — sin que tengas que ajustar nada manualmente al cambiar de plazo.

**Valores de referencia usados por defecto en cada timeframe:**

| Parámetro | 30 min | 1 hora | 4 horas |
|---|---|---|---|
| RSI Sobrecompra | 66 | 63 | 66 |
| RSI Sobreventa | 34 | 38 | 33 |
| Multiplicador Bandas de Bollinger | 2.5 | 2.5 | 2.4 |
| Longitud Bandas de Bollinger | 6 | 6 | 6 |
| Multiplicador de volumen climático | 2.0 | 2.0 | 2.0 |
| Longitud SMA de volumen | 20 | 20 | 20 |

Todos estos valores son ajustables desde el panel de configuración si quieres experimentar con tus propios criterios.

**Totalmente personalizable:** el modo de Bollinger, los colores de las señales, y la cantidad de líneas históricas visibles también se ajustan desde el panel de configuración.

**Guía rápida para principiantes — cómo leerlo:**

1. **¿Apareció una etiqueta verde con una "C" o roja con una "V"?** Marca el momento en que las tres condiciones (volumen, RSI, Bollinger) coincidieron a la vez — la "C" indica una señal de posible compra, la "V" una de posible venta.
2. **¿Ves una línea vertical junto a la etiqueta?** Es solo una marca visual para ubicar la señal con más claridad en el gráfico, no representa un nivel de precio.
3. **Las bandas de colores** (naranja, teal y gris) son las Bandas de Bollinger tradicionales: la banda superior, inferior y la línea central — te ayudan a ver el contexto de rango del precio en cada momento.
4. **Este indicador solo está calibrado para 30 minutos, 1 hora y 4 horas** — en otros timeframes usa una configuración genérica de respaldo, no una calibrada específicamente.

**Cómo usarlo:** aplica el indicador en cualquiera de los tres timeframes soportados y configura una alarma sobre la señal Long o Short para recibir notificaciones automáticas.

*Este contenido es informativo y educativo, no constituye asesoría financiera ni recomendación de inversión. Los indicadores técnicos no garantizan resultados futuros — usa siempre tu propia gestión de riesgo.*

---

## Source Code

````pine
//@version=6
indicator("Climatic Volume + RSI + Bollinger MULTI-TF (tus valores)", overlay=true, max_labels_count=500)

// ───────── PARÁMETROS FIJOS (iguales en todos los timeframes) ─────────
int    volLength      = 20
float  volMultiplier  = 2.0
int    rsiLength      = 14
int    bbLength       = 6
string bbMode         = "Tocar Banda"

bool   useBB          = true
bool   showSignals    = true
color  longColor      = color.lime
color  shortColor     = color.red
int    maxLines       = 50


// ───────── PARÁMETROS QUE CAMBIAN POR TIMEFRAME ─────────
float bbMult         = 2.5
int   rsiOverbought  = 66
int   rsiOversold    = 34

string tf = timeframe.period

if tf == "30" or tf == "30m"
    rsiOverbought := 66
    rsiOversold   := 34
    bbMult        := 2.5

else if tf == "60" or tf == "1H" or tf == "60m" or tf == "1h"
    rsiOverbought := 63
    rsiOversold   := 38
    bbMult        := 2.5

else if tf == "240" or tf == "4H" or tf == "240m" or tf == "4h"
    rsiOverbought := 66
    rsiOversold   := 33
    bbMult        := 2.4

else
    // fallback (por si usas otro timeframe)
    rsiOverbought := 63
    rsiOversold   := 38
    bbMult        := 2.5


// ───────── CÁLCULOS ─────────
cClose = close[1]
cHigh  = high[1]
cLow   = low[1]
cVol   = volume[1]

// Volumen climático
volSMA    = ta.sma(volume[2], volLength)
climactic = cVol > volSMA * volMultiplier

// RSI (sobre barra cerrada)
rsiValue = ta.rsi(cClose, rsiLength)

// Bollinger Bands
basis = ta.sma(cClose, bbLength)
dev   = ta.stdev(cClose, bbLength) * bbMult
upper = basis + dev
lower = basis - dev


// ───────── LÓGICA BOLLINGER ─────────
bool longBB  = true
bool shortBB = true

if useBB
    switch bbMode
        "Tocar Banda" =>
            longBB  := cLow <= lower
            shortBB := cHigh >= upper
        "Cerrar Fuera" =>
            longBB  := cClose < lower
            shortBB := cClose > upper
        "Reingreso" =>
            longBB  := cClose > lower and close[2] < lower
            shortBB := cClose < upper and close[2] > upper


// ───────── CONDICIONES DE SEÑAL ─────────
bool longCondition  = climactic and rsiValue < rsiOversold and longBB
bool shortCondition = climactic and rsiValue > rsiOverbought and shortBB

bool longSignal  = longCondition and not longCondition[1]
bool shortSignal = shortCondition and not shortCondition[1]


// ───────── LÍNEAS VERTICALES ─────────
var array<line> longLines  = array.new<line>()
var array<line> shortLines = array.new<line>()

if longSignal
    l = line.new(bar_index, low, bar_index, high, color=longColor, width=2)
    array.push(longLines, l)

if shortSignal
    s = line.new(bar_index, low, bar_index, high, color=shortColor, width=2)
    array.push(shortLines, s)

// Limitar cantidad
if array.size(longLines) > maxLines
    line.delete(array.shift(longLines))
if array.size(shortLines) > maxLines
    line.delete(array.shift(shortLines))


// ───────── VISUALIZACIÓN ─────────
plotshape(longSignal and showSignals,  title="Long",  style=shape.labelup,   location=location.belowbar, color=longColor,  text="C", textcolor=color.black,  size=size.small)
plotshape(shortSignal and showSignals, title="Short", style=shape.labeldown, location=location.abovebar, color=shortColor, text="V", textcolor=color.white, size=size.small)

plot(useBB ? upper : na, "BB Upper", color=color.orange, linewidth=1)
plot(useBB ? lower : na, "BB Lower", color=color.teal,   linewidth=1)
plot(useBB ? basis : na, "BB Basis", color=color.gray,   linewidth=1)


// ───────── ALERTAS ─────────
// Corregido: {{timeframe.period}} no es un marcador válido de
// TradingView (no se reemplaza por nada) -- el correcto es {{interval}}.
alertcondition(longSignal,  title="Señal Long",  message="Climatic + RSI + BB → COMPRA {{ticker}} {{interval}}")
alertcondition(shortSignal, title="Señal Short", message="Climatic + RSI + BB → VENTA {{ticker}} {{interval}}")


// ────────────────────────────────────────────────────────────────
// TABLA INFORMATIVA LATERAL - MOVIDA A LA PARTE INFERIOR DERECHA
// ────────────────────────────────────────────────────────────────
var table infoTable = table.new(
     position       = position.bottom_right,
     columns        = 3,
     rows           = 7,
     bgcolor        = color.new(color.black, 80),
     border_width   = 1,
     border_color   = color.new(color.gray, 50),
     frame_width    = 1,
     frame_color    = color.new(color.blue, 80)
     )

if barstate.islast
    // Encabezado
    table.cell(infoTable, column=0, row=0, text="Parámetro",          text_color=color.white, bgcolor=color.new(color.blue, 70), text_size=size.small)
    table.cell(infoTable, column=1, row=0, text="30 min",             text_color=color.white, bgcolor=color.new(color.blue, 70), text_size=size.small)
    table.cell(infoTable, column=2, row=0, text="1 h          4 h",   text_color=color.white, bgcolor=color.new(color.blue, 70), text_size=size.small)

    // Contenido
    table.cell(infoTable, 0, 1, "RSI Overbought", text_color=color.orange, text_size=size.small)
    table.cell(infoTable, 1, 1, "66",             text_color=color.orange, text_size=size.small)
    table.cell(infoTable, 2, 1, "63          66", text_color=color.orange, text_size=size.small)

    table.cell(infoTable, 0, 2, "RSI Oversold",   text_color=color.lime, text_size=size.small)
    table.cell(infoTable, 1, 2, "34",             text_color=color.lime, text_size=size.small)
    table.cell(infoTable, 2, 2, "38          33", text_color=color.lime, text_size=size.small)

    table.cell(infoTable, 0, 3, "BB Multiplier",  text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 1, 3, "2.5",            text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 2, 3, "2.5         2.4", text_color=color.yellow, text_size=size.small)

    table.cell(infoTable, 0, 4, "Vol Climatic Mult", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 4, "2.0",               text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 2, 4, "2.0 (todos)",       text_color=color.gray, text_size=size.small)

    table.cell(infoTable, 0, 5, "BB Length",      text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 5, "6",              text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 2, 5, "6 (todos)",      text_color=color.gray, text_size=size.small)

    table.cell(infoTable, 0, 6, "Vol SMA Length", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 6, "20",             text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 2, 6, "20 (todos)",     text_color=color.gray, text_size=size.small)

// --- fin del script ---
````
