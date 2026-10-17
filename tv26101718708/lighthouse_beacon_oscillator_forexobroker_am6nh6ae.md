# Lighthouse Beacon Oscillator [forexobroker]

- url: https://www.tradingview.com/script/AM6Nh6aE-Lighthouse-Beacon-Oscillator-forexobroker/
- type: indicator
- pine_id: PUB;e08f407fee7c49178fcd8d0918bafd22
- version: 1.0

## Description

Lighthouse Beacon Oscillator detects multi-scale pivot confluence: when the most recent fast, medium, and slow pivot highs all cluster within an ATR-scaled zone (or the same for pivot lows), the market has built a strong beacon level across three time scales. Breaks away from that level are the signal.

Built for traders who want support/resistance confirmed at multiple pivot granularities rather than just one.

🔶 CONCEPTS

A pivot at one length could be noise; pivots at three lengths landing on the same price are not. Fast pivots capture intraday swings, medium pivots capture session structure, and slow pivots capture trend turning points. When the latest of each cluster within one ATR-scaled zone, that price has been confirmed as a major structural level by three independent timescales at once. A break of that beacon level, therefore, is meaningful because the level mattered at multiple horizons simultaneously. This is stronger evidence than a break of any single pivot.

🔶 HOW IT WORKS

- Detects pivot highs and lows at three different L/R lengths (fast, medium, slow)
- Tracks the most recent pivot of each type
- Computes the spread between the three most recent pivot highs (and separately pivot lows) in ATR units
- Declares "high confluence" when all three pivot highs fit within the Beacon Confluence Zone (ATR)
- Declares "low confluence" when all three pivot lows fit within the same zone
- Averages the three pivots when confluent to form the beacon level
- Detects breaks when close clears the beacon by the Break Margin
- Combines confluence tightness, break event, and bias-EMA slope into a 0-100 Beacon Score
- Classifies state as DARK, FORMING, GLOWING, or LIT

🔶 HOW TO USE

1. Add the indicator -- green line shows low beacon, pink line shows high beacon when confluences exist
2. Watch the dashboard (top-right) for live beacon prices, pivot spreads in ATR, and break state
3. Green BUY triangles with "BEACON ↑" label fire on bullish beacon breaks; pink SELL triangles on bearish
4. The Bias EMA plotted with glow gates breaks to macro direction
5. Narrow the Beacon Confluence Zone to require tighter clustering for more conviction

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Three-scale pivot confluence detection
- ATR-scaled zone so confluence tolerance is instrument-appropriate

🔶 SETTINGS GUIDE

- Fast / Mid / Slow Pivot L/R -- Three different pivot lengths used for confluence
- Beacon Confluence Zone (ATR) -- Max ATR-scaled spread between the three pivots
- ATR Length -- ATR period used for zone and break-margin scaling
- Break Margin (ATR) -- ATR fraction above/below beacon required for a break
- Bias EMA Length -- Macro EMA used to gate breaks
- Beacon Score Threshold -- Minimum 0-100 score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- LBO Buy Beacon -- Bullish beacon break confirmed
- LBO Sell Beacon -- Bearish beacon break confirmed
- LBO Any Signal -- Any beacon signal
- LBO Lit -- Beacon score reaches 85+
- LBO High Confluence -- Pivot-high confluence across three scales
- LBO Low Confluence -- Pivot-low confluence across three scales
- LBO Up Break -- Close broke above beacon high
- LBO Down Break -- Close broke below beacon low
- LBO Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Pivots confirm only after right-side bars print; slow pivots have meaningful lag.
- In strongly trending markets one side of the beacon may rarely form; that's expected behavior.
- The Beacon Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Lighthouse Beacon Oscillator [forexobroker]", shorttitle="LBO [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_beacon = "Beacon Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_piv1      = input.int(3,  "Fast Pivot L/R", minval=1, maxval=10, group=g_beacon)
int    i_piv2      = input.int(6,  "Mid Pivot L/R",  minval=3, maxval=20, group=g_beacon)
int    i_piv3      = input.int(10, "Slow Pivot L/R", minval=5, maxval=30, group=g_beacon)
float  i_zoneAtr   = input.float(0.6, "Beacon Confluence Zone (ATR)", minval=0.2, maxval=2.0, step=0.05, group=g_beacon, tooltip="Pivots from all three scales must fall within this ATR distance")
int    i_atrLen    = input.int(14, "ATR Length", minval=5, maxval=50, group=g_beacon)
float  i_breakAtr  = input.float(0.2, "Break Margin (ATR)", minval=0.05, maxval=1.0, step=0.05, group=g_beacon)
int    i_biasLen   = input.int(50, "Bias EMA Length", minval=10, maxval=200, group=g_beacon)
int    i_scoreThr  = input.int(70, "Beacon Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown  = input.int(12, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Beacon Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Beacon Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showEma   = input.bool(true, "Show Bias EMA Glow", group=g_visual)
bool   i_showLines = input.bool(true, "Show Beacon Lines", group=g_visual)
color  i_buyColor  = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal = ta.atr(i_atrLen)
float biasEma = ta.ema(close, i_biasLen)
float emaSlope = ta.change(biasEma, 3)

float ph1 = ta.pivothigh(high, i_piv1, i_piv1)
float pl1 = ta.pivotlow(low,   i_piv1, i_piv1)
float ph2 = ta.pivothigh(high, i_piv2, i_piv2)
float pl2 = ta.pivotlow(low,   i_piv2, i_piv2)
float ph3 = ta.pivothigh(high, i_piv3, i_piv3)
float pl3 = ta.pivotlow(low,   i_piv3, i_piv3)

var float lastPh1 = na, var float lastPh2 = na, var float lastPh3 = na
var float lastPl1 = na, var float lastPl2 = na, var float lastPl3 = na
if not na(ph1)
    lastPh1 := ph1
if not na(ph2)
    lastPh2 := ph2
if not na(ph3)
    lastPh3 := ph3
if not na(pl1)
    lastPl1 := pl1
if not na(pl2)
    lastPl2 := pl2
if not na(pl3)
    lastPl3 := pl3

bool allPhValid = not na(lastPh1) and not na(lastPh2) and not na(lastPh3)
bool allPlValid = not na(lastPl1) and not na(lastPl2) and not na(lastPl3)

float zoneWidth = atrVal * i_zoneAtr
float phRangeVal = allPhValid ? math.max(lastPh1, math.max(lastPh2, lastPh3)) - math.min(lastPh1, math.min(lastPh2, lastPh3)) : na
float plRangeVal = allPlValid ? math.max(lastPl1, math.max(lastPl2, lastPl3)) - math.min(lastPl1, math.min(lastPl2, lastPl3)) : na

bool phConfluence = allPhValid and not na(phRangeVal) and phRangeVal <= zoneWidth
bool plConfluence = allPlValid and not na(plRangeVal) and plRangeVal <= zoneWidth

float beaconHigh = phConfluence ? (lastPh1 + lastPh2 + lastPh3) / 3.0 : na
float beaconLow  = plConfluence ? (lastPl1 + lastPl2 + lastPl3) / 3.0 : na

bool upBreak = not na(beaconHigh) and close > beaconHigh + atrVal * i_breakAtr and close[1] <= beaconHigh + atrVal * i_breakAtr
bool dnBreak = not na(beaconLow)  and close < beaconLow  - atrVal * i_breakAtr and close[1] >= beaconLow  - atrVal * i_breakAtr

// ─── BEACON SCORING (0-100) ───────────────────────────────────────────────────
float sConfHi = phConfluence ? math.min((zoneWidth - phRangeVal) / zoneWidth * 30.0 + 20.0, 40.0) : 0.0
float sConfLo = plConfluence ? math.min((zoneWidth - plRangeVal) / zoneWidth * 30.0 + 20.0, 40.0) : 0.0
float sBreak  = (upBreak or dnBreak) ? 35.0 : 0.0
float sBias   = math.abs(emaSlope) / (atrVal + 0.00001)
sBias := math.min(sBias * 20.0, 15.0)
float beaconScore = math.round(math.min(math.max(sConfHi, sConfLo) + sBreak + sBias, 100.0))

string beaconState = beaconScore >= 85 ? "LIT" : beaconScore >= 70 ? "GLOWING" : beaconScore >= 50 ? "FORMING" : "DARK"
color  stateCol    = beaconScore >= 85 ? c_gold : beaconScore >= 70 ? c_green : beaconScore >= 50 ? c_cyan : color.gray

// ─── DIRECTIONAL BIAS ──────────────────────────────────────────────────────────
bool bullBias = upBreak and close > biasEma and emaSlope > 0
bool bearBias = dnBreak and close < biasEma and emaSlope < 0

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = beaconScore >= i_scoreThr

bool rawBuy  = bullBias and scoreOk and cooldownOk and confirmed
bool rawSell = bearBias and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Beacon Background Gradient ───────────────────────────────────────
color beaconBg = na
if i_showBg
    if beaconScore >= 85
        beaconBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_gold, 90)
    else if beaconScore >= 70
        beaconBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_cyan, 94)
    else if phConfluence or plConfluence
        beaconBg := color.new(c_purple, 96)
bgcolor(beaconBg)

// ─── VISUAL: Bias EMA with 3-Layer Glow ───────────────────────────────────────
plot(i_showEma ? biasEma : na, "EMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(i_showEma ? biasEma : na, "EMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(i_showEma ? biasEma : na, "EMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: Beacon Lines ─────────────────────────────────────────────────────
var line hiBeaconLine = na
var line loBeaconLine = na
if i_showLines and not na(beaconHigh)
    line.delete(hiBeaconLine)
    hiBeaconLine := line.new(bar_index - 40, beaconHigh, bar_index, beaconHigh, color=color.new(c_pink, 30), width=3)
if i_showLines and not na(beaconLow)
    line.delete(loBeaconLine)
    loBeaconLine := line.new(bar_index - 40, beaconLow, bar_index, beaconLow, color=color.new(c_green, 30), width=3)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="BEACON ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="BEACON ↓", textcolor=color.white)

// ─── VISUAL: Beacon Context Label ─────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "BEACON ↑\nScore: " + str.tostring(beaconScore) + "/100\nTop: " + str.tostring(math.round(beaconHigh, 5)), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "BEACON ↓\nScore: " + str.tostring(beaconScore) + "/100\nBot: " + str.tostring(math.round(beaconLow, 5)), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Beacon Dashboard ─────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Lighthouse Beacon", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Beacon Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(beaconScore) + "/100", text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, beaconState, text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 3, "High Beacon", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, not na(beaconHigh) ? str.tostring(math.round(beaconHigh, 5)) : "-", text_color=phConfluence ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Low Beacon", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, not na(beaconLow) ? str.tostring(math.round(beaconLow, 5)) : "-", text_color=plConfluence ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "PH Spread (ATR)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, not na(phRangeVal) ? str.tostring(math.round(phRangeVal / atrVal, 2)) : "-", text_color=phConfluence ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 6, "PL Spread (ATR)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, not na(plRangeVal) ? str.tostring(math.round(plRangeVal / atrVal, 2)) : "-", text_color=plConfluence ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Break", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, upBreak ? "UP" : dnBreak ? "DOWN" : "-", text_color=upBreak ? c_green : dnBreak ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"LBO","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"beacon":' + str.tostring(beaconScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"LBO","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"beacon":' + str.tostring(beaconScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "LBO Buy Beacon",       "Beacon BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "LBO Sell Beacon",      "Beacon SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "LBO Any Signal",       "Any beacon signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(beaconScore >= 85,                 "LBO Lit",              "Beacon score 85+ on {{ticker}} {{interval}}")
alertcondition(phConfluence,                      "LBO High Confluence",  "Three-scale pivot-high confluence on {{ticker}} {{interval}}")
alertcondition(plConfluence,                      "LBO Low Confluence",   "Three-scale pivot-low confluence on {{ticker}} {{interval}}")
alertcondition(upBreak,                           "LBO Up Break",         "Break above beacon high on {{ticker}} {{interval}}")
alertcondition(dnBreak,                           "LBO Down Break",       "Break below beacon low on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "LBO Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"LBO\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
