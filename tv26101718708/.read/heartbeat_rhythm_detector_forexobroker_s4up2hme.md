# Heartbeat Rhythm Detector [forexobroker]

- url: https://www.tradingview.com/script/s4UP2hMe-Heartbeat-Rhythm-Detector-forexobroker/
- type: indicator
- pine_id: PUB;af6368c951e84c6ebe00e31bce6c057d
- version: 1.0

## Description

Heartbeat Rhythm Detector tracks the rhythm of bar ranges over a rolling window and fires when the rhythm breaks -- when a single bar's range becomes a statistical outlier (high z-score) with directional close and volume confirmation. A healthy market has a regular heartbeat of similar-sized bars; a broken rhythm marks a real shift.

Built for traders who want to enter when the market's normal volatility cadence abruptly changes, usually at the onset of a new trend leg.

🔶 CONCEPTS

Rhythm is regularity. If the last 20 bars all have similar ranges, the range distribution is tight, and the z-score of any given bar is small. When a single bar prints a range that is two or more standard deviations above the rolling mean, the rhythm has broken -- something out of the ordinary has happened. If the close confirms a direction and volume supports it, the rhythm break is real and tradable. Rising coefficient of variation adds an extra confirm: irregularity was building before the break itself.

🔶 HOW IT WORKS

- Measures current bar range (high - low)
- Computes rolling mean and standard deviation of range over the Rhythm Window
- Calculates range z-score
- Computes coefficient of variation (stddev / mean) of ranges and its change over the window
- Confirms volume exceeds average by the volume multiplier
- Combines z-score magnitude, CV rise, volume excess, and EMA slope into a 0-100 Rhythm Score
- Classifies state as REGULAR, IRREGULAR, SPIKE, or ARRHYTHMIA
- Fires signal on rhythm-break bar with matching directional close and bias

🔶 HOW TO USE

1. Add the indicator -- background tints by rhythm state
2. Watch the dashboard (top-right) for live range z-score, CV, CV change, volume ratio, and break direction
3. Green BUY triangles with "PULSE ↑" label fire on bullish rhythm breaks; pink SELL triangles on bearish
4. The Bias EMA plotted with glow gates signals to macro direction
5. Raise Rhythm Break Z-Score for only extreme outliers; lower it for more frequent signals

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Statistical outlier detection in bar ranges (not just ATR expansion)
- Coefficient-of-variation context that confirms increasing irregularity

🔶 SETTINGS GUIDE

- Rhythm Window -- Bars used to measure range mean, stddev, and CV
- Rhythm Break Z-Score -- Required range z-score to qualify as a rhythm break
- ATR Length -- ATR period (used for label offsets)
- Rising CV Floor -- Minimum CV increase over the window to count as rhythm shift
- Volume Average Length / Volume Multiplier -- Volume confirmation criterion
- Bias EMA Length -- Macro EMA used to gate signals
- Rhythm Score Threshold -- Minimum 0-100 score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- HRD Buy Pulse -- Bullish rhythm break confirmed
- HRD Sell Pulse -- Bearish rhythm break confirmed
- HRD Any Signal -- Any rhythm signal
- HRD Arrhythmia -- Rhythm score reaches 85+
- HRD Up Break -- Bullish rhythm break event
- HRD Down Break -- Bearish rhythm break event
- HRD Range Z-Spike -- Range z-score above threshold (informational)
- HRD Rising CV -- Range coefficient of variation increasing
- HRD Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Z-score normalization adapts to recent rhythm; regime shifts can temporarily mis-scale thresholds.
- News-driven spikes can cause rhythm breaks unrelated to structural change.
- The Rhythm Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Heartbeat Rhythm Detector [forexobroker]", shorttitle="HRD [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_rhythm = "Rhythm Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_rhythmLen = input.int(20, "Rhythm Window", minval=5, maxval=100, group=g_rhythm, tooltip="Bars used to measure rhythm (range variability)")
float  i_breakZ    = input.float(2.0, "Rhythm Break Z-Score", minval=1.0, maxval=4.0, step=0.1, group=g_rhythm, tooltip="Current range z-score required to qualify as a rhythm break")
int    i_atrLen    = input.int(14, "ATR Length", minval=5, maxval=50, group=g_rhythm)
float  i_minCvRise = input.float(0.2, "Rising CV Floor", minval=0.05, maxval=1.0, step=0.05, group=g_rhythm, tooltip="Minimum range coefficient-of-variation increase to count as rhythm shift")
int    i_volLen    = input.int(20, "Volume Average Length", minval=5, maxval=100, group=g_rhythm)
float  i_volMult   = input.float(1.25, "Volume Confirm Multiplier", minval=1.0, maxval=3.0, step=0.05, group=g_rhythm)
int    i_biasLen   = input.int(34, "Bias EMA Length", minval=10, maxval=200, group=g_rhythm)
int    i_scoreThr  = input.int(70, "Rhythm Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown  = input.int(10, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Rhythm Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Rhythm Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showEma   = input.bool(true, "Show Bias EMA Glow", group=g_visual)
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
float rng    = high - low
float rngMean = ta.sma(rng, i_rhythmLen)
float rngStd  = ta.stdev(rng, i_rhythmLen)
float rngCV   = rngMean > 0 ? rngStd / rngMean : 0.0
float rngCVPrev = rngCV[i_rhythmLen]
float cvChange = rngCV - rngCVPrev
float rngZ    = rngStd > 0 ? (rng - rngMean) / rngStd : 0.0

float avgVol = ta.sma(volume, i_volLen)
bool volOk  = volume >= avgVol * i_volMult

float biasEma = ta.ema(close, i_biasLen)
float emaSlope = ta.change(biasEma, 3)

// Rhythm break: current bar range is outlier vs recent rhythm, with directional close
bool rhythmBreakUp = rngZ >= i_breakZ and close > open and close > close[1]
bool rhythmBreakDn = rngZ >= i_breakZ and close < open and close < close[1]
bool risingVol = avgVol > 0 and (volume > avgVol)

// ─── RHYTHM SCORING (0-100) ───────────────────────────────────────────────────
float sZ     = math.min(math.max(rngZ - 1.0, 0.0) * 30.0, 40.0)
float sCV    = math.min(math.max(cvChange, 0.0) * 50.0, 25.0)
float sVol   = math.min(math.max((volume / avgVol - 1.0) * 40.0, 0.0), 20.0)
float sBias  = math.abs(emaSlope) / (atrVal + 0.00001)
sBias := math.min(sBias * 20.0, 15.0)
float rhythmScore = math.round(math.min(sZ + sCV + sVol + sBias, 100.0))

string rhythmState = rhythmScore >= 85 ? "ARRHYTHMIA" : rhythmScore >= 70 ? "SPIKE" : rhythmScore >= 50 ? "IRREGULAR" : "REGULAR"
color  stateCol    = rhythmScore >= 85 ? c_gold : rhythmScore >= 70 ? c_green : rhythmScore >= 50 ? c_cyan : color.gray

// ─── DIRECTIONAL BIAS ──────────────────────────────────────────────────────────
bool bullBias = rhythmBreakUp and volOk and close > biasEma and emaSlope > 0
bool bearBias = rhythmBreakDn and volOk and close < biasEma and emaSlope < 0

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = rhythmScore >= i_scoreThr

bool rawBuy  = bullBias and scoreOk and cooldownOk and confirmed
bool rawSell = bearBias and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Rhythm Background Gradient ───────────────────────────────────────
color rhyBg = na
if i_showBg
    if rhythmScore >= 85
        rhyBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_gold, 90)
    else if rhythmScore >= 70
        rhyBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_cyan, 94)
    else if rhythmScore >= 50
        rhyBg := color.new(c_purple, 96)
bgcolor(rhyBg)

// ─── VISUAL: Bias EMA with 3-Layer Glow ───────────────────────────────────────
plot(i_showEma ? biasEma : na, "EMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(i_showEma ? biasEma : na, "EMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(i_showEma ? biasEma : na, "EMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="PULSE ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="PULSE ↓", textcolor=color.white)

// ─── VISUAL: Rhythm Context Label ─────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "RHYTHM ↑\nScore: " + str.tostring(rhythmScore) + "/100\nZ: " + str.tostring(math.round(rngZ, 2)), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "RHYTHM ↓\nScore: " + str.tostring(rhythmScore) + "/100\nZ: " + str.tostring(math.round(rngZ, 2)), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Heartbeat Dashboard ──────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Heartbeat Rhythm", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Rhythm Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(rhythmScore) + "/100", text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, rhythmState, text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 3, "Range Z", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(rngZ, 2)), text_color=rngZ > i_breakZ ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Range CV", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(math.round(rngCV, 2)), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 5, "CV Change", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(cvChange, 2)), text_color=cvChange > i_minCvRise ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Vol x Avg", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, avgVol > 0 ? str.tostring(math.round(volume / avgVol, 2)) + "x" : "-", text_color=volOk ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Break Direction", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, rhythmBreakUp ? "UP" : rhythmBreakDn ? "DOWN" : "-", text_color=rhythmBreakUp ? c_green : rhythmBreakDn ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"HRD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"rhythm":' + str.tostring(rhythmScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"HRD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"rhythm":' + str.tostring(rhythmScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "HRD Buy Pulse",        "Heartbeat BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "HRD Sell Pulse",       "Heartbeat SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "HRD Any Signal",       "Any rhythm signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(rhythmScore >= 85,                 "HRD Arrhythmia",       "Rhythm score 85+ on {{ticker}} {{interval}}")
alertcondition(rhythmBreakUp,                     "HRD Up Break",         "Bullish rhythm break on {{ticker}} {{interval}}")
alertcondition(rhythmBreakDn,                     "HRD Down Break",       "Bearish rhythm break on {{ticker}} {{interval}}")
alertcondition(rngZ > i_breakZ,                   "HRD Range Z-Spike",    "Range z-score spike on {{ticker}} {{interval}}")
alertcondition(cvChange > i_minCvRise,            "HRD Rising CV",        "Range variability rising on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "HRD Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"HRD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
