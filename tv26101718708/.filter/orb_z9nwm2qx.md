# ORB 

- url: https://www.tradingview.com/script/Z9nwM2qx/
- type: indicator
- pine_id: PUB;8da1fbfc4b364b8fb3f7f46be5d1f5a7
- version: 4.0

## Description

ORB V2 plots the Opening Range Breakout for the Asia, London, or New York session, using the high and low of a selectable timeframe candle (1 to 240 min) captured at the exact session open in New York time.
What it draws:

High, midpoint (50%), and low lines of the opening range, extended live for the duration of the session
Color-coded labels showing the exact price of each level
A vertical opening marker at session start

Built-in bias filter:

A configurable EMA (default 20-period on the 1H timeframe, both adjustable) is calculated independently of the chart timeframe via request.security, and compared to price to display a simple Bullish/Bearish bias — useful for filtering ORB breakout trades in the direction of the higher-timeframe trend rather than trading every breakout blindly.
Dashboard:

A bottom-right table shows the total range size and the distance to the 50% level, converted into your choice of units (ticks, pips, or % for crypto), plus the previous day's high and low for additional context, and the current bias reading.
How to use it:

Select your session (Asia / London / NY) and the opening candle timeframe.
Watch for price to break above/below the ORB high/low.
Use the EMA bias reading to favor breakouts aligned with the higher-timeframe trend, and the 50% level as a mid-range reference for partial targets or re-entries.
Use the dashboard to gauge range size in your preferred unit before sizing a trade.

All colors, label sizes, and the dashboard display can be customized from the indicator settings.

## Source Code

````pine
//@version=6
indicator("ORB", overlay=true, max_lines_count=500)

// ─── INPUTS ORB ───────────────────────────────────────────────────────────────
i_tf        = input.timeframe("15",   title="Timeframe vela apertura", options=["1","3","5","15","30","60","240"], group="ORB")
i_session   = input.string("NY",      title="Sesión",                  options=["Asia", "Londres", "NY"],          group="ORB")
i_colorVert = input.color(color.teal,   title="Color línea apertura",  group="ORB")
i_colorHigh = input.color(color.red,    title="Color High",            group="ORB")
i_colorMid  = input.color(color.yellow, title="Color 50%",             group="ORB")
i_colorLow  = input.color(color.green,  title="Color Low",             group="ORB")

// ─── INPUTS BIAS ──────────────────────────────────────────────────────────────
i_emaPeriod  = input.int(20,        title="Periodo EMA",     minval=1,                                         group="BIAS")
i_emaTF      = input.timeframe("60",title="Timeframe EMA",   options=["","1","3","5","15","30","60","240"],     group="BIAS")
i_emaColor   = input.color(color.white, title="Color EMA",                                                      group="BIAS")

// ─── INPUTS DASHBOARD ─────────────────────────────────────────────────────────
i_unit      = input.string("Ticks",   title="Unidad",   options=["Ticks", "Pips", "Puntos", "Crypto"],     group="Dashboard")
i_dashSize  = input.string("normal",  title="Tamaño",   options=["tiny","small","normal","large","huge"],   group="Dashboard")

// NOTA: todas las horas de sesión están definidas en zona horaria de Nueva York
// ("America/New_York"), con ajuste automático de horario de verano (DST).

// ─── HELPERS ──────────────────────────────────────────────────────────────────
toSize(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.huge

c40(c) => color.new(c, 40)

toUnits(points, refPrice) =>
    float result = na
    if i_unit == "Ticks"
        result := points / syminfo.mintick
    else if i_unit == "Pips"
        result := points / syminfo.mintick / 10
    else if i_unit == "Puntos"
        result := points
    else
        result := points / refPrice * 100
    result

// ─── MINUTOS DEL TF ELEGIDO ───────────────────────────────────────────────────
// Necesitamos saber cuántos minutos dura la vela de apertura
tfMinutes =
     i_tf == "1"   ? 1  :
     i_tf == "3"   ? 3  :
     i_tf == "5"   ? 5  :
     i_tf == "15"  ? 15 :
     i_tf == "30"  ? 30 :
     i_tf == "60"  ? 60 : 240

// ─── FIX 1: GUARDA DE TIMEFRAME ───────────────────────────────────────────────
// La captura acumula barras del gráfico dentro de la ventana de apertura.
// Si el TF del gráfico es MAYOR que el TF de apertura, una sola barra "grande"
// cae en la ventana y se capturaría un rango incorrecto de forma silenciosa.
tfChartSec = timeframe.in_seconds(timeframe.period)
tfOrbSec   = tfMinutes * 60
if barstate.islast and tfChartSec > tfOrbSec
    runtime.error("El TF del gráfico (" + timeframe.period + ") debe ser ≤ al TF de apertura (" + i_tf + "m).")

// ─── HORA DE APERTURA Y CIERRE DE SESIÓN ─────────────────────────────────────
openHour   = i_session == "Asia" ? 20 : i_session == "Londres" ? 4 : 9
openMinute = i_session == "NY"   ? 30 : 0

closeHour   = i_session == "Asia" ? 0  : i_session == "Londres" ? 9  : 17
closeMinute = i_session == "Londres" ? 30 : 0

// ─── HORA ACTUAL EN NY ────────────────────────────────────────────────────────
barHour   = hour(time,   "America/New_York")
barMinute = minute(time, "America/New_York")

barTotalMin      = barHour  * 60 + barMinute
openTotalMin     = openHour * 60 + openMinute
closeTotalMin    = closeHour * 60 + closeMinute
closeTotalMinAdj = (i_session == "Asia" and closeTotalMin == 0) ? 1440 : closeTotalMin

isInSession = barTotalMin >= openTotalMin and barTotalMin < closeTotalMinAdj

// ─── FIN DE SESIÓN ────────────────────────────────────────────────────────────
sessionJustEnded = not isInSession and isInSession[1]

// ─── VENTANA DE LA PRIMERA VELA ───────────────────────────────────────────────
// Barras del gráfico que caen dentro del primer intervalo del TF elegido
orbWindowEnd = openTotalMin + tfMinutes   // minuto exclusivo donde ya terminó la vela
isInOrbWindow = barTotalMin >= openTotalMin and barTotalMin < orbWindowEnd

// ─── EMA ─────────────────────────────────────────────────────────────────────
emaValue = request.security(syminfo.tickerid, i_emaTF, ta.ema(close, i_emaPeriod), lookahead=barmerge.lookahead_off)
plot(emaValue, title="EMA Bias", color=i_emaColor, linewidth=2, display=display.none)

// ─── BIAS ─────────────────────────────────────────────────────────────────────
biasStr   = close > emaValue ? "▲ Alcista" : "▼ Bajista"
biasColor = close > emaValue ? color.green  : color.red

// ─── HIGH/LOW DÍA ANTERIOR ────────────────────────────────────────────────────
prevHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

// ─── VARIABLES PERSISTENTES ───────────────────────────────────────────────────
var line  lineVert    = na
var line  lineHigh    = na
var line  lineMid     = na
var line  lineLow     = na
var float orbHigh     = na
var float orbLow      = na
var table dashboard   = na
var bool  orbCaptured = false
var int   openBarIdx  = na

// ─── ACUMULADORES INTRA-VENTANA ───────────────────────────────────────────────
// Se recalculan barra a barra mientras estamos en la ventana ORB
var float runHigh = na
var float runLow  = na

// ─── FIX 2: RESET AL INICIO DE CADA NUEVO DÍA (EN ZONA NY) ────────────────────
// Antes se usaba dayofweek (zona del exchange), que cambia a medianoche del
// exchange y podía caer DENTRO de la sesión Asia (símbolos UTC/cripto),
// reseteando el ORB a mitad de ventana. Ahora el reset es coherente con NY.
nyDay = dayofmonth(time, "America/New_York")
if nyDay != nyDay[1]
    orbCaptured := false
    openBarIdx  := na
    runHigh     := na
    runLow      := na

// ─── ACUMULAR HIGH/LOW BARRA A BARRA DENTRO DE LA VENTANA ────────────────────
if isInOrbWindow and not orbCaptured
    // Guardar el bar_index de la primera barra de la ventana
    if na(openBarIdx)
        openBarIdx := bar_index
    // Acumular high/low reales del gráfico
    runHigh := na(runHigh) ? high : math.max(runHigh, high)
    runLow  := na(runLow)  ? low  : math.min(runLow,  low)

// ─── FIX 3: CAPTURAR ORB AL PASAR EL FIN DE LA VENTANA ───────────────────────
// Antes se dependía del flanco exacto (isInOrbWindow[1]==true). Si por un gap
// no había barra justo antes del cierre, el ORB no se capturaba nunca.
// Ahora se captura en la primera barra pasado el fin de ventana, siempre que
// se haya acumulado al menos una barra dentro (runHigh no es na).
if barTotalMin >= orbWindowEnd and not orbCaptured and not na(runHigh)
    orbCaptured := true
    orbHigh     := runHigh
    orbLow      := runLow
    midPoint     = (orbHigh + orbLow) / 2

    lineVert := line.new(
         x1=openBarIdx, y1=orbHigh, x2=openBarIdx, y2=orbLow,
         color=c40(i_colorVert), width=5, style=line.style_solid, extend=extend.both)

    lineHigh := line.new(
         x1=openBarIdx, y1=orbHigh, x2=bar_index, y2=orbHigh,
         color=c40(i_colorHigh), width=2, style=line.style_solid, extend=extend.right)

    lineMid := line.new(
         x1=openBarIdx, y1=midPoint, x2=bar_index, y2=midPoint,
         color=c40(i_colorMid), width=2, style=line.style_solid, extend=extend.right)

    lineLow := line.new(
         x1=openBarIdx, y1=orbLow, x2=bar_index, y2=orbLow,
         color=c40(i_colorLow), width=2, style=line.style_solid, extend=extend.right)

// ─── AL TERMINAR LA SESIÓN: cortar las líneas ────────────────────────────────
// FIX 5: ahora también se guarda y recorta la línea vertical de apertura.
if sessionJustEnded and not na(lineHigh)
    line.set_extend(lineVert, extend.none)
    line.set_extend(lineHigh, extend.none)
    line.set_extend(lineMid,  extend.none)
    line.set_extend(lineLow,  extend.none)
    line.set_x2(lineHigh, bar_index - 1)
    line.set_x2(lineMid,  bar_index - 1)
    line.set_x2(lineLow,  bar_index - 1)

// ─── DASHBOARD ───────────────────────────────────────────────────────────────
// FIX 4: las celdas se actualizan solo en la última barra (rendimiento).
if not na(orbHigh) and not na(orbLow) and barstate.islast
    totalRange = toUnits(orbHigh - orbLow, orbLow)
    halfRange  = totalRange / 2
    ds         = toSize(i_dashSize)
    fmt        = i_unit == "Crypto" ? "#.###" : i_unit == "Puntos" ? "#.##" : "#.#"
    unitLabel  = i_unit == "Crypto" ? "%" : i_unit

    if na(dashboard)
        dashboard := table.new(
             position=position.bottom_right,
             columns=2, rows=6,
             bgcolor=color.new(color.black, 60),
             border_color=color.new(color.gray, 50),
             border_width=1)

    table.cell(dashboard, 0, 0, "ORB",        text_color=color.white, text_size=ds, bgcolor=color.new(color.teal, 40))
    table.cell(dashboard, 1, 0, unitLabel,     text_color=color.white, text_size=ds, bgcolor=color.new(color.teal, 40))
    table.cell(dashboard, 0, 1, "Rango total", text_color=color.white, text_size=ds)
    table.cell(dashboard, 1, 1, str.tostring(totalRange, fmt), text_color=color.yellow, text_size=ds)
    table.cell(dashboard, 0, 2, "Hasta 50%",   text_color=color.white, text_size=ds)
    table.cell(dashboard, 1, 2, str.tostring(halfRange,  fmt), text_color=color.yellow, text_size=ds)
    table.cell(dashboard, 0, 3, "Prev High",   text_color=color.white, text_size=ds)
    table.cell(dashboard, 1, 3, str.tostring(prevHigh, "#.##"), text_color=color.green,  text_size=ds)
    table.cell(dashboard, 0, 4, "Prev Low",    text_color=color.white, text_size=ds)
    table.cell(dashboard, 1, 4, str.tostring(prevLow,  "#.##"), text_color=color.red,    text_size=ds)
    table.cell(dashboard, 0, 5, "Bias",        text_color=color.white, text_size=ds)
    table.cell(dashboard, 1, 5, biasStr,        text_color=biasColor,   text_size=ds)
````
