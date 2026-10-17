# RalisLine Spread

- url: https://www.tradingview.com/script/WsDmJbEH-RalisLine-Spread/
- type: indicator
- pine_id: PUB;0dcb371a3b8141a0be5a6757fef2b8a8
- version: 2.0

## Description

RalisLine Spread is a companion histogram for the RalisLine overlay. It measures the percentage gap between the fastest and slowest smoothed moving averages in a 4-SMMA ribbon, rendering that spread as a color-coded histogram below the chart. Gold bars above zero mean the ribbon is fanned out bullish — all four SMAs aligned with the fast line leading upward. Blue bars below zero mean bearish alignment. Gray bars appear when the ribbon is tangled — the inner lines disagree with the outer lines, indicating a regime transition is in progress.

The indicator uses a 3-state regime classification that goes beyond simple spread direction. It's not enough for the fast SMMA to be above the slow one — the two inner lines must also confirm the alignment. This "inconclusive" detection prevents false regime calls during crossover periods when the ribbon is tangled and direction is genuinely uncertain.

A 9-period EMA signal line (magenta) overlays the histogram. When the spread crosses above its signal line, a green triangle marks the crossover — momentum is building and the regime is strengthening. When it crosses below, a red triangle marks the fading — momentum is weakening. These signal line crossovers typically lead regime flips by several bars, giving you early warning before the RalisLine overlay changes color. A MACD-style fill between the spread and signal line shades green when spread is above signal and red when below, making the momentum relationship visible at a glance.

Bar brightness indicates acceleration. When the spread is growing in its current direction — bullish bars getting taller or bearish bars getting deeper — bars render at full brightness. When the spread is shrinking toward zero (regime fading), bars dim to 50% opacity. This means a bright gold bar is a strengthening bull trend, while a dim gold bar is a bull trend losing steam. The dimming often appears several bars before a regime flip, adding another layer of early warning beyond the signal line crossovers.

An optional percentile reference line (off by default, toggle in settings) ranks the current absolute spread against a 120-bar rolling history using ta.percentrank(). This solves the cross-asset comparison problem — a 2% spread on gold means something very different than 2% on a volatile altcoin. The percentile line turns orange above the 80th percentile (spread is extreme for this asset), blue below the 20th (spread is compressed, transition likely), and white in between. The percentile value is always shown in the info table even when the line is hidden.

The info table displays five fields: Regime (BULLISH/BEARISH/NEUTRAL with color-coded background), Spread (current percentage), Momentum (GROWING or FADING based on acceleration), Percentile (rank against rolling history), and Signal (ABOVE or BELOW the signal line). The table can be toggled off in settings for a cleaner pane.

Six alert conditions are available: Signal Cross Up (spread crossed above signal EMA), Signal Cross Down (spread crossed below), Zero Cross Up (spread turned positive — fast SMMA now leading slow), Zero Cross Down (spread turned negative), Regime to Bullish (ribbon aligned bullish from inconclusive or bearish), and Regime to Bearish (ribbon aligned bearish).

Default SMMA lengths are 8/16/24/32 on HL2, matching the RalisLine overlay for synchronized regime reads. For best results, use both indicators on the same chart — RalisLine shows the structural ribbon directly on price while RalisLine Spread shows the momentum and conviction beneath it. The signal line crossovers on the Spread often fire 3–5 bars before the RalisLine flip dots appear on the overlay, giving you a head start on regime transitions.

Works on any asset and any timeframe. No repainting.

## Source Code

````pine
//@version=6
indicator("RalisLine Spread", shorttitle="RalisSprd", overlay=false)

// ── SETTINGS ──────────────────────────────────────────────────────
groupRibbon = "SMMA Ribbon"
groupSignal = "Signal Line"
groupPctile = "Percentile Reference"
groupVisual = "Visual"
groupTable  = "Table"

i_src       = input.source(hl2, "Source", group=groupRibbon)
i_fastOut   = input.int(8,  "Fast Outer", minval=5, maxval=50, group=groupRibbon)
i_fastIn    = input.int(16, "Fast Inner", minval=5, maxval=50, group=groupRibbon)
i_slowIn    = input.int(24, "Slow Inner", minval=10, maxval=80, group=groupRibbon)
i_slowOut   = input.int(32, "Slow Outer", minval=10, maxval=80, group=groupRibbon)

i_sigLen    = input.int(9, "Signal EMA Length", minval=3, maxval=50, group=groupSignal)
i_sigColor  = input.color(#FF00FF, "Signal Line Color", group=groupSignal)
i_showSigX  = input.bool(true, "Show Crossover Triangles", group=groupSignal)

groupBands  = "Dynamic Bands"
i_showBands  = input.bool(true, "Show Dynamic Bands", group=groupBands)
i_bandLen    = input.int(50, "Band Lookback", minval=20, maxval=1000, step=10, group=groupBands)
i_bandHiPct  = input.float(85, "Upper Percentile", minval=70, maxval=99, step=1, group=groupBands, tooltip="Percentile for upper band — shows where the spread typically peaks.")
i_bandLoPct  = input.float(15, "Lower Percentile", minval=1, maxval=30, step=1, group=groupBands, tooltip="Percentile for lower band — shows where the spread typically troughs.")
i_bandHiClr  = input.color(color.new(#FFD700, 40), "Upper Band Color", group=groupBands)
i_bandLoClr  = input.color(color.new(#1E90FF, 40), "Lower Band Color", group=groupBands)

i_showPctile = input.bool(false, "Show Percentile Reference", group=groupPctile)
i_pctileLen  = input.int(120, "Percentile Lookback", minval=20, maxval=500, group=groupPctile)
i_pctileSmth = input.int(8, "Percentile Smoothing", minval=1, maxval=30, group=groupPctile)
i_pctileHi   = input.color(color.new(#FF6D00, 40), "High Percentile Color", group=groupPctile)
i_pctileLo   = input.color(color.new(#2196F3, 40), "Low Percentile Color", group=groupPctile)

i_bullColor = input.color(#FFD700, "Bullish Bars (Gold)", group=groupVisual)
i_bearColor = input.color(#1E90FF, "Bearish Bars (Blue)", group=groupVisual)
i_neutColor = input.color(#808080, "Neutral Bars (Gray)", group=groupVisual)

tPos = switch input.string("Top Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=groupTable)
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right
i_showTable = input.bool(true, "Show Info Table", group=groupTable)

// ── SMMA — INLINE VAR STATE (fleet standard) ────────────────────
var float v1 = na
var float m1 = na
var float m2 = na
var float v2 = na

v1 := na(v1) ? ta.sma(i_src, i_fastOut) : (v1 * (i_fastOut - 1) + i_src) / i_fastOut
m1 := na(m1) ? ta.sma(i_src, i_fastIn) : (m1 * (i_fastIn - 1) + i_src) / i_fastIn
m2 := na(m2) ? ta.sma(i_src, i_slowIn) : (m2 * (i_slowIn - 1) + i_src) / i_slowIn
v2 := na(v2) ? ta.sma(i_src, i_slowOut) : (v2 * (i_slowOut - 1) + i_src) / i_slowOut

// ── 3-STATE LOGIC (tangle + neutral zone) ──────────────────────
bool tangled = (v1 < m1) != (v1 < v2) or (m2 < v2) != (v1 < v2)
float spread = (v1 - v2) / v2 * 100
bool flat    = math.abs(spread) < 0.34

bool inconclusive = tangled or flat
bool bearish      = not inconclusive and v1 < v2
bool bullish      = not inconclusive and not bearish

// ── SIGNAL LINE ──────────────────────────────────────────────────
float signalLine = ta.ema(spread, i_sigLen)
bool sigCrossUp  = barstate.isconfirmed and ta.crossover(spread, signalLine)
bool sigCrossDn  = barstate.isconfirmed and ta.crossunder(spread, signalLine)

// ── DYNAMIC BANDS — percentile thresholds ───────────────────────
// Upper band = typical bullish spread peak (e.g., 90th percentile)
// Lower band = typical bearish spread trough (e.g., 10th percentile)
// Adapted from Meridian H's ta.percentile_nearest_rank approach
float bandHi = i_showBands ? ta.percentile_nearest_rank(spread, i_bandLen, i_bandHiPct) : na
float bandLo = i_showBands ? ta.percentile_nearest_rank(spread, i_bandLen, i_bandLoPct) : na

// ── SPREAD ACCELERATION COLORING ─────────────────────────────────
float spreadDelta   = spread - spread[1]
bool  spreadGrowing = (spread > 0 and spreadDelta > 0) or (spread < 0 and spreadDelta < 0)
int   dimAlpha      = spreadGrowing ? 0 : 50

color barColor = bullish ? color.new(i_bullColor, dimAlpha) : bearish ? color.new(i_bearColor, dimAlpha) : color.new(i_neutColor, 30)

// ── PERCENTILE REFERENCE (smoothed) ──────────────────────────────
float absSpread   = math.abs(spread)
float pctileRank  = ta.percentrank(absSpread, i_pctileLen)
float spreadHi    = ta.highest(absSpread, i_pctileLen)
float pctileRaw   = (pctileRank / 100) * spreadHi * (spread >= 0 ? 1 : -1)
float pctileSmth  = i_showPctile ? ta.ema(pctileRaw, i_pctileSmth) : na

color pctileColor = pctileRank > 80 ? i_pctileHi : pctileRank < 20 ? i_pctileLo : color.new(color.white, 60)

// ── PLOTS ────────────────────────────────────────────────────────
plot(spread, "Spread", style=plot.style_columns, color=barColor, linewidth=2)
pSig = plot(signalLine, "Signal", color=i_sigColor, linewidth=2)
hline(0, "Zero", color=color.new(color.white, 80), linestyle=hline.style_solid)
plot(pctileSmth, "Percentile Ref", color=pctileColor, linewidth=2)

// Dynamic bands
plot(bandHi, "Upper Band", i_bandHiClr, linewidth=1, style=plot.style_line)
plot(bandLo, "Lower Band", i_bandLoClr, linewidth=1, style=plot.style_line)

// Spread-vs-signal fill — green when spread above signal, red when below
pSpreadLine = plot(spread, "Spread Line", color=color.new(color.white, 100), display=display.none)
fill(pSpreadLine, pSig, color=spread > signalLine ? color.new(#00FF88, 85) : color.new(#FF4444, 85), title="Momentum Fill")

// ── SIGNAL LINE CROSSOVER MARKERS ────────────────────────────────
// Green ▲ = spread crossed ABOVE signal (momentum building)
// Red   ▼ = spread crossed BELOW signal (momentum fading)
plotshape(i_showSigX and sigCrossUp ? signalLine : na, "Sig Cross Up", shape.triangleup, location.absolute, color.new(#00FF88, 20), size=size.tiny)
plotshape(i_showSigX and sigCrossDn ? signalLine : na, "Sig Cross Dn", shape.triangledown, location.absolute, color.new(#FF4444, 20), size=size.tiny)

// ── BAND BREACH DOTS ────────────────────────────────────────────
// Tiny circles when spread crosses the dynamic percentile bands
bool bandBreachHi = barstate.isconfirmed and i_showBands and ta.crossover(spread, bandHi)
bool bandBreachLo = barstate.isconfirmed and i_showBands and ta.crossunder(spread, bandLo)
plotshape(bandBreachHi ? spread : na, "Upper Band Breach", shape.circle, location.absolute, #FFD700, size=size.tiny)
plotshape(bandBreachLo ? spread : na, "Lower Band Breach", shape.circle, location.absolute, #1E90FF, size=size.tiny)

// ── INFO TABLE ───────────────────────────────────────────────────
string regime = bullish ? "BULLISH" : bearish ? "BEARISH" : "NEUTRAL"
string accel  = spreadGrowing ? "GROWING" : "FADING"
color biasCol  = bullish ? i_bullColor : bearish ? i_bearColor : i_neutColor
color accelCol = spreadGrowing ? color.lime : color.orange

var table infoTable = table.new(tPos, 2, 5, border_width=1, bgcolor=color.new(color.black, 80))

if i_showTable and barstate.islast
    table.cell(infoTable, 0, 0, "Regime",    text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.small)
    table.cell(infoTable, 1, 0, regime,       text_color=color.black, bgcolor=biasCol, text_size=size.small)
    table.cell(infoTable, 0, 1, "Spread",     text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(spread, "#.##") + "%", text_color=biasCol, text_size=size.small)
    table.cell(infoTable, 0, 2, "Momentum",   text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 2, accel,        text_color=accelCol, text_size=size.small)
    table.cell(infoTable, 0, 3, "Percentile", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(pctileRank, "#") + "%", text_color=pctileRank > 80 ? #FF6D00 : pctileRank < 20 ? #2196F3 : color.white, text_size=size.small)
    table.cell(infoTable, 0, 4, "Signal",     text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(infoTable, 1, 4, spread > signalLine ? "ABOVE" : "BELOW", text_color=spread > signalLine ? color.lime : #FF4444, text_size=size.small)

// ── ALERTS ───────────────────────────────────────────────────────
// Signal line crossovers
alertcondition(sigCrossUp, title="Signal Cross Up", message="{{ticker}} {{interval}} RalisLine Spread crossed ABOVE signal line — momentum building")
alertcondition(sigCrossDn, title="Signal Cross Dn", message="{{ticker}} {{interval}} RalisLine Spread crossed BELOW signal line — momentum fading")

// Zero line crosses
bool zeroCrossUp = ta.crossover(spread, 0)
bool zeroCrossDn = ta.crossunder(spread, 0)
alertcondition(zeroCrossUp, title="Zero Cross Up", message="{{ticker}} {{interval}} RalisLine Spread crossed ABOVE zero — fast SMMA leading slow")
alertcondition(zeroCrossDn, title="Zero Cross Dn", message="{{ticker}} {{interval}} RalisLine Spread crossed BELOW zero — fast SMMA trailing slow")

// Regime changes
bool regimeToBull = bullish and not bullish[1]
bool regimeToBear = bearish and not bearish[1]
alertcondition(regimeToBull, title="Regime → Bullish", message="{{ticker}} {{interval}} RalisLine Spread regime turned BULLISH")
alertcondition(regimeToBear, title="Regime → Bearish", message="{{ticker}} {{interval}} RalisLine Spread regime turned BEARISH")

// Band breaches
alertcondition(bandBreachHi, title="Upper Band Breach", message="{{ticker}} {{interval}} RalisLine Spread broke above upper dynamic band — extreme bullish spread")
alertcondition(bandBreachLo, title="Lower Band Breach", message="{{ticker}} {{interval}} RalisLine Spread broke below lower dynamic band — extreme bearish spread")
````
