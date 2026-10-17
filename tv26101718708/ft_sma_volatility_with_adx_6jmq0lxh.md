# FT - SMA volatility with ADX

- url: https://www.tradingview.com/script/6jMq0lxh/
- type: indicator
- pine_id: PUB;602d196a35354b1681b22ffe29bf2436
- version: 2.0

## Description

FT - SMA VOLATILITY WITH ADX

A combined panel indicator that overlays two complementary metrics to provide market context at a glance: a tricolor SMA of the candle range (High - Low) to track volatility direction, and a classic Wilder ADX line to measure trend strength.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IT DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VOLATILITY LINE (tricolor SMA of range)
A simple moving average of (High - Low) that measures the average candle amplitude in points. The line color changes based on its evolution compared to N bars ago:
   • GREEN → volatility rose by at least X points.
   • RED   → volatility fell by at least X points.
   • BLACK → lateral change within the threshold.

ADX LINE (Wilder's classic directional index)
Measures trend strength regardless of direction. Yellow line with dashed reference levels:
   • ADX < 20   → no defined trend (range).
   • ADX 20-25  → incipient trend.
   • ADX > 25   → strong trend.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO READ IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Combining both lines produces four distinct market contexts:

   • Vol RED + ADX LOW   → market calming without direction.
   • Vol RED + ADX HIGH  → trend exhausting, possible reversal.
   • Vol GREEN + ADX HIGH → breakout with sustained trend.
   • Vol GREEN + ADX LOW  → volatility without direction (whipsaws).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT MAKES IT DIFFERENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Most traders use volatility and ADX as two separate indicators on different panels. Reading them together is powerful because they answer different questions:
   - Volatility answers "is the market moving?"
   - ADX answers "is it moving with direction?"
A move can be volatile AND directional (breakout), volatile AND directionless (whipsaw), calm AND directional (quiet trend), or calm AND directionless (dead zone).
This indicator displays both in the same pane with a compact panel, so you can classify the current market context without switching between tools.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   • Configurable volatility average length and comparison lookback.
   • Configurable rise/fall thresholds in points.
   • Standard ADX parameters (DI length, ADX smoothing).
   • Compact metrics panel with adjustable size (Small / Medium / Large) and position.
   • Four built-in alerts: rising volatility, falling volatility, ADX crosses 25, ADX falls below 20.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   • Filter reversals: trade reversals only when volatility is red.
   • Confirm breakouts: require both green volatility and rising ADX above 25.
   • Avoid dead zones: skip trades when ADX stays below 20 for extended periods.
   • Warn about exhaustion: red volatility with high ADX often precedes trend reversals.

This is a context/confluence tool, not a standalone trading system. It works best combined with structural analysis (support/resistance, trend structure) or entry triggers from other tools.

All parameters are fully configurable to adapt to any asset and timeframe.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
// FT - VOLATILIDAD SMA + ADX
// ─────────────────────────────────────────────────────────────────────
// Combina dos métricas en un solo panel:
//
//   1) VOLATILIDAD (rango promedio)
//      Promedio móvil simple del rango (Máximo - Mínimo) en N velas.
//      Línea tricolor:
//        • VERDE → subió al menos X puntos respecto a N velas atrás.
//        • ROJA  → bajó al menos X puntos respecto a N velas atrás.
//        • NEGRA → cambio lateral (dentro del umbral).
//
//   2) ADX (fuerza de tendencia)
//      Índice direccional clásico de Wilder.
//      Línea amarilla con niveles de referencia en 20 y 25.
//        • ADX < 20 → sin tendencia (rango).
//        • ADX 20-25 → tendencia incipiente.
//        • ADX > 25 → tendencia fuerte.
//
// LECTURA COMBINADA:
//   • Vol ROJA + ADX BAJO → mercado calmándose sin dirección.
//   • Vol ROJA + ADX ALTO → tendencia agotándose, posible reversión.
//   • Vol VERDE + ADX ALTO → ruptura con tendencia (evitar reversiones).
//   • Vol VERDE + ADX BAJO → volatilidad sin dirección (whipsaws).
//
// Autor: FrancoTradingFT
// ═══════════════════════════════════════════════════════════════════
indicator("FT - Volatilidad SMA con ADX", shorttitle="FT - Volatilidad SMA & ADX", overlay=false, precision=2)

// ==========================================
// INPUTS
// ==========================================
groupVol = "Volatilidad"
volLen       = input.int(20,  "Longitud del promedio de volatilidad (velas)", minval=1, group=groupVol, tooltip="Cantidad de velas usadas para promediar el rango (Máximo - Mínimo).")
volCompVelas = input.int(10,  "Velas hacia atrás para comparar", minval=2, group=groupVol, tooltip="Compara la volatilidad actual con el valor de N velas atrás.")
volSubePts   = input.float(1.0, "Puntos mínimos de subida (verde)", minval=0.1, step=0.5, group=groupVol)
volBajaPts   = input.float(1.0, "Puntos mínimos de bajada (roja)",  minval=0.1, step=0.5, group=groupVol)
showVolLine  = input.bool(true, "Mostrar línea de volatilidad", group=groupVol)
volWidth     = input.int(2, "Grosor de la línea de volatilidad", minval=1, maxval=5, group=groupVol)

groupADX = "ADX"
diLen       = input.int(14, "Longitud DI",       minval=2, group=groupADX, tooltip="Cantidad de velas usadas para calcular +DI y -DI.")
adxSmooth   = input.int(14, "ADX suavizado",     minval=2, group=groupADX, tooltip="Cantidad de velas para suavizar el ADX final.")
showADX     = input.bool(true, "Mostrar línea ADX", group=groupADX)
adxWidth    = input.int(2, "Grosor de la línea ADX", minval=1, maxval=5, group=groupADX)
showLevels  = input.bool(true, "Mostrar niveles 20/25", group=groupADX)

groupPanel = "Panel"
showPanel = input.bool(true, "Mostrar panel", group=groupPanel)
panelPos  = input.string("Arriba derecha", "Posición del panel", options=["Arriba derecha", "Arriba izquierda", "Abajo derecha", "Abajo izquierda"], group=groupPanel)
panelSize = input.string("Mediano", "Tamaño del panel", options=["Pequeño", "Mediano", "Grande"], group=groupPanel)

// ==========================================
// CÁLCULOS DE VOLATILIDAD
// ==========================================
volRangePts = high - low
volPromPts  = ta.sma(volRangePts, volLen)

volRef = volPromPts[volCompVelas]
diffUp = volPromPts - volRef
diffDn = volRef - volPromPts

isUp   = diffUp >= volSubePts
isDown = diffDn >= volBajaPts

volColor = isUp ? color.new(color.lime, 0) : isDown ? color.new(color.red, 0) : color.new(color.black, 0)

// ==========================================
// CÁLCULOS DE ADX
// ==========================================
[plusDI, minusDI, adxVal] = ta.dmi(diLen, adxSmooth)

// ==========================================
// PLOTS
// ==========================================
plot(showVolLine ? volPromPts : na, title="Volatilidad", color=volColor, linewidth=volWidth)
plot(showADX     ? adxVal     : na, title="ADX",         color=color.new(#FFEB3B, 0), linewidth=adxWidth)

// Niveles ADX
hline(showLevels ? 20 : na, "ADX 20", color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(showLevels ? 25 : na, "ADX 25", color=color.new(color.gray, 20), linestyle=hline.style_dashed)

// ==========================================
// PANEL
// ==========================================
panelPosition = position.top_right
if panelPos == "Arriba izquierda"
    panelPosition := position.top_left
else if panelPos == "Abajo derecha"
    panelPosition := position.bottom_right
else if panelPos == "Abajo izquierda"
    panelPosition := position.bottom_left

var table panel = table.new(panelPosition, 2, 10, border_width=1)

// Tamaño del texto del panel
txtSize = panelSize == "Pequeño" ? size.tiny : panelSize == "Grande" ? size.normal : size.small

// Estado de volatilidad
volStateTxt = isUp ? "SUBIENDO" : isDown ? "BAJANDO" : "LATERAL"
volStateBg  = isUp ? color.new(color.lime, 0) : isDown ? color.new(color.red, 0) : color.new(color.black, 0)
diffActual  = volPromPts - volRef
diffTxt     = (diffActual >= 0 ? "+" : "") + str.tostring(math.round(diffActual, 2)) + " pts"
diffBg      = diffActual > 0 ? color.new(color.green, 30) : diffActual < 0 ? color.new(color.red, 30) : color.new(color.gray, 30)

if showPanel
    int r = 0
    table.cell(panel, 0, r, "Vol actual (" + str.tostring(volLen) + "v)", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(panel, 1, r, str.tostring(math.round(volPromPts, 2)) + " pts", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=txtSize)
    r += 1
    table.cell(panel, 0, r, "Hace " + str.tostring(volCompVelas) + " velas", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(panel, 1, r, str.tostring(math.round(volRef, 2)) + " pts", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=txtSize)
    r += 1
    table.cell(panel, 0, r, "Diferencia", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(panel, 1, r, diffTxt, text_color=color.white, bgcolor=diffBg, text_size=txtSize)
    r += 1
    table.cell(panel, 0, r, "Estado", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(panel, 1, r, volStateTxt, text_color=color.white, bgcolor=volStateBg, text_size=txtSize)
    r += 1

// ==========================================
// ALERTAS
// ==========================================
alertcondition(isUp,                      title="Volatilidad subiendo",   message="Volatilidad subiendo detectada")
alertcondition(isDown,                    title="Volatilidad bajando",    message="Volatilidad bajando detectada")
alertcondition(ta.crossover(adxVal, 25),  title="ADX cruza 25",           message="ADX cruzó por encima de 25 (tendencia fuerte)")
alertcondition(ta.crossunder(adxVal, 20), title="ADX baja de 20",         message="ADX bajó por debajo de 20 (pérdida de tendencia)")
````
