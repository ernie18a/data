# Super Chachin  Classic Fibonacci Pivots with Price-Action Sig

- url: https://www.tradingview.com/script/sXOydjD0-Super-Chachin-Classic-Fibonacci-Pivots-with-Price-Action-Sig/
- type: indicator
- pine_id: PUB;13d94cc832044fc9811b48d2cc83cdce
- version: 1.0

## Description

OVERVIEW
Chachin Pivots Pro is an intraday support/resistance tool that plots two complementary families of daily pivot levels — classic floor-trader pivots and Fibonacci pivots — and adds a volatility-filtered price-action layer that highlights reversal candles forming right at those levels. It is built for the 5-minute chart and works on forex, gold and index markets.
WHY THESE COMPONENTS ARE COMBINED (and how they work together)
Most pivot indicators draw a single set of levels and stop there, leaving you to judge by eye whether price is actually reacting. This script combines three elements on purpose, each one covering a weakness of the others:

Classic pivots (PP, R1–R4, S1–S4) come from the standard floor-trader formula and tend to mark the broad reaction zones most intraday traders watch.
Fibonacci pivots (0.382 / 0.618 / 1.000 of the prior day's range) are calculated with a different formula and often land at slightly different prices. They are included alongside the classic levels precisely because of where they disagree: when a classic level and a Fib level cluster together, that confluence marks a stronger zone than either level alone. The two sets are not redundant — their overlap is the information.
Price-action signals are the timing layer. The script flags a bullish engulfing candle near a support level and a bearish rejection candle near a resistance level. A pivot tells you where price might turn; the candle tells you whether it is actually turning there right now.

The piece that binds them into one system is the ATR proximity filter. "Near a level" is defined in volatility-adjusted terms (a multiple of ATR) rather than a fixed distance, so a signal only appears when a reversal candle forms within a meaningful distance of a pivot — and the same settings behave sensibly on a quiet EUR/USD session and a fast XAU/USD session without retuning. This is what makes the three parts act as one tool instead of three scripts stacked on a chart.
HOW THE LEVELS ARE CALCULATED

Central Pivot: PP = (prev High + prev Low + prev Close) / 3
Classic R1 / S1: 2·PP − prev Low and 2·PP − prev High
Classic R2 / S2: PP + range and PP − range  (range = prev High − prev Low)
R3/R4 and S3/S4: further range projections for high-volatility days
Fibonacci pivots: PP ± 0.382·range, PP ± 0.618·range, PP ± 1.000·range (the 0.618 level is usually the most respected)

All levels are built from the previous, already-closed daily candle, so they are fixed for the whole session and do not repaint. Old lines are cleared at the start of each new day to keep the chart clean.
THE PRICE-ACTION SIGNALS

🟢 BULL — a bullish engulfing candle that closes within ATR-proximity of a support pivot (PP / S / FS).
🔴 BEAR — a bearish rejection candle within ATR-proximity of a resistance pivot (PP / R / FR).

Signals are confirmed on bar close and are meant as context, not as automatic buy/sell instructions.
HOW TO USE IT

Add it to a 5-minute chart of a liquid instrument (e.g. XAU/USD, EUR/USD, an index).
Use the Central Pivot (PP) for daily bias: trading above it leans bullish, below it leans bearish.
Watch how price behaves at the pivots, paying special attention to confluence zones where a classic level and a Fibonacci level stack on top of each other.
Treat a BULL/BEAR signal at one of those zones as a heads-up to look for your own entry, using the next pivot as a logical target and the level behind the signal as a logical invalidation point.
Optional alerts are available for PP crosses, key breakouts/breakdowns, and the candle signals.

SETTINGS

Show Classic Pivots / Show Fibonacci Pivots / Show Labels — toggle each layer on or off.
Proximity to level (× ATR) — how close price must be to a level for a signal to fire (higher = more permissive).
Colours for the central pivot, classic levels, Fibonacci levels and signals are fully editable.

INPUT-MENU TRANSLATION (the UI is in Spanish)

"Mostrar Pivots Clásicos" → Show Classic Pivots
"Mostrar Pivots Fibonacci" → Show Fibonacci Pivots
"Mostrar Etiquetas" → Show Labels
"Mostrar Señales" → Show Signals
"Proximidad a nivel (x ATR)" → Proximity to level (× ATR)
"Pivot Central" → Central Pivot · "Niveles Clásicos" → Classic Levels · "Niveles Fibonacci" → Fibonacci Levels

This is an educational tool for identifying support and resistance. It is not financial advice, and the past behaviour of any level does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Super Chachin", shorttitle="ChachinDMZ Pro", overlay=true, max_lines_count=100, max_labels_count=100)

// ============================================
// === INPUTS ===
// ============================================
grpPivot    = "Pivots"
showClassic = input.bool(true,  "Mostrar Pivots Clásicos",   group=grpPivot)
showFib     = input.bool(true,  "Mostrar Pivots Fibonacci",  group=grpPivot)
showLabels  = input.bool(true,  "Mostrar Etiquetas",         group=grpPivot)

grpSignals   = "Señales de Velas"
showSignals  = input.bool(true, "Mostrar Señales",                group=grpSignals)
proximityATR = input.float(1.0, "Proximidad a nivel (x ATR)",     minval=0.1, step=0.1, group=grpSignals, tooltip="Solo muestra señales cuando el precio está cerca de un nivel clave, medido en ATR")

grpColors  = "Colores"
colPP      = input.color(color.blue,                     "Pivot Central",     group=grpColors)
colClassic = input.color(color.new(color.white,  40),    "Niveles Clásicos",  group=grpColors)
colFib     = input.color(color.new(color.yellow, 40),    "Niveles Fibonacci", group=grpColors)
colBull    = input.color(color.lime,                     "Señal Alcista",     group=grpColors)
colBear    = input.color(color.red,                      "Señal Bajista",     group=grpColors)

// ============================================
// === DATOS DEL DÍA ANTERIOR ===
// ============================================
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

// ============================================
// === CÁLCULOS ===
// ============================================
pp  = (prevHigh + prevLow + prevClose) / 3
rng = prevHigh - prevLow

// Pivots Clásicos
R1 = 2 * pp - prevLow
R2 = pp + rng
R3 = R1 + rng
R4 = R2 + rng
S1 = 2 * pp - prevHigh
S2 = pp - rng
S3 = S1 - rng
S4 = S2 - rng

// Pivots Fibonacci (fórmulas correctas)
FR1 = pp + 0.382 * rng
FR2 = pp + 0.618 * rng
FR3 = pp + 1.000 * rng
FS1 = pp - 0.382 * rng
FS2 = pp - 0.618 * rng
FS3 = pp - 1.000 * rng

// ATR para filtrar señales
atrVal = ta.atr(14)

// ============================================
// === GESTIÓN DE LÍNEAS Y LABELS ===
// ============================================
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()

clearAll() =>
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label.delete(array.pop(labels))

drawLevel(price, txt, col, width) =>
    ln = line.new(bar_index, price, bar_index + 1, price, extend=extend.right, color=col, width=width)
    array.push(lines, ln)
    if showLabels
        lb = label.new(bar_index, price, txt + "  " + str.tostring(price, format.mintick), style=label.style_label_left, color=color.new(color.black, 80), textcolor=col, size=size.small)
        array.push(labels, lb)

// Detectar cambio de día
newDay = ta.change(pp) != 0

if newDay
    clearAll()

    // Pivot central (siempre visible)
    drawLevel(pp, "PP", colPP, 2)

    if showClassic
        drawLevel(R1, "R1", colClassic, 1)
        drawLevel(R2, "R2", colClassic, 1)
        drawLevel(R3, "R3", colClassic, 1)
        drawLevel(R4, "R4", colClassic, 1)
        drawLevel(S1, "S1", colClassic, 1)
        drawLevel(S2, "S2", colClassic, 1)
        drawLevel(S3, "S3", colClassic, 1)
        drawLevel(S4, "S4", colClassic, 1)

    if showFib
        drawLevel(FR1, "FR1 (0.382)", colFib, 1)
        drawLevel(FR2, "FR2 (0.618)", colFib, 1)
        drawLevel(FR3, "FR3 (1.000)", colFib, 1)
        drawLevel(FS1, "FS1 (0.382)", colFib, 1)
        drawLevel(FS2, "FS2 (0.618)", colFib, 1)
        drawLevel(FS3, "FS3 (1.000)", colFib, 1)

// ============================================
// === SEÑALES DE VELAS ===
// ============================================
bullishEngulfing = close > open and close[1] < open[1] and open <= close[1] and close >= open[1]
bearishRejection = (high - close) > 2 * (close - low) and high > open and close < open

// ¿Estamos cerca de algún nivel clave?
nearLevel(levels) =>
    found = false
    for lv in levels
        if math.abs(close - lv) <= atrVal * proximityATR
            found := true
    found

levelsArr = array.from(pp, R1, R2, R3, R4, S1, S2, S3, S4, FR1, FR2, FR3, FS1, FS2, FS3)
nearAnyLevel = nearLevel(levelsArr)

bullSignal = showSignals and bullishEngulfing and nearAnyLevel
bearSignal = showSignals and bearishRejection and nearAnyLevel

plotshape(bullSignal, title="Envolvente Alcista", style=shape.triangleup,   location=location.belowbar, color=colBull, size=size.small, text="BULL")
plotshape(bearSignal, title="Rechazo Bajista",    style=shape.triangledown, location=location.abovebar, color=colBear, size=size.small, text="BEAR")

// ============================================
// === ALERTAS ===
// ============================================
// Cruces de niveles clave
alertcondition(ta.cross(close, pp),       title="Cruce PP",        message="Precio cruzó el Pivot Central")
alertcondition(ta.crossover(close, R1),   title="Ruptura R1",      message="Precio rompió R1 al alza")
alertcondition(ta.crossover(close, R2),   title="Ruptura R2",      message="Precio rompió R2 al alza")
alertcondition(ta.crossover(close, FR2),  title="Ruptura FR2",     message="Precio rompió Fib 0.618 al alza")
alertcondition(ta.crossunder(close, S1),  title="Perforación S1",  message="Precio perforó S1 a la baja")
alertcondition(ta.crossunder(close, S2),  title="Perforación S2",  message="Precio perforó S2 a la baja")
alertcondition(ta.crossunder(close, FS2), title="Perforación FS2", message="Precio perforó Fib 0.618 a la baja")

// Señales de velas
alertcondition(bullSignal, title="Señal Alcista", message="Envolvente alcista cerca de nivel clave")
alertcondition(bearSignal, title="Señal Bajista", message="Rechazo bajista cerca de nivel clave")
````
