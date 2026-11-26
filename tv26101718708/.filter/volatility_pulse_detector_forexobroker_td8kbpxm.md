# Volatility Pulse Detector [forexobroker]

- url: https://www.tradingview.com/script/tD8KBpXm-Volatility-Pulse-Detector-forexobroker/
- type: indicator
- pine_id: PUB;00a3d0cea6e649ffaf97f2c1e232ce6b
- version: 1.0

## Description

Volatility Pulse Detector treats market volatility as a heartbeat. It measures a fast ATR against a long-term baseline ATR and classifies each bar into a systole phase (volatility expansion) or a diastole phase (volatility contraction). The chart takes on a rhythmic appearance: pulsing bands around the axis EMA expand during systole and contract during diastole. When a fresh systole begins with a directional close beyond recent structure, BUY or SELL signals fire.

This indicator is designed for traders who want to enter at the beginning of volatility expansions rather than chase price after the move has matured. Visualizing volatility as a pulse makes regime changes obvious at a glance and turns the chart into a living rhythm map.

🔶 CONCEPTS

Volatility is cyclical. Markets inhale (contract, range-bound, low ATR) and exhale (expand, trend, high ATR) in alternating phases. The detrended ATR -- the ratio of a fast ATR to a baseline -- oscillates around zero, crossing into positive territory during expansions (systole) and negative territory during contractions (diastole). The transition from diastole back into systole is where the majority of directional thrust happens. Measuring bar distance between consecutive systole starts gives a rhythm (cycle length) that helps traders anticipate when the next expansion is due.

🔶 HOW IT WORKS

- Computes a Fast ATR and a Baseline ATR; the ratio is detrended so positive = systole, negative = diastole
- Draws upper and lower pulse bands around the axis EMA whose width scales with the Fast ATR and phase
- Tracks cycle length: bars between consecutive systole onsets
- Signal fires when a fresh systole begins with volume confirmation and price closing beyond the prior pivot extreme

🔶 HOW TO USE

1. Add the indicator -- the pulse bands begin expanding and contracting immediately; the phase background tints green (systole) or purple (diastole)
2. Watch the dashboard (top-right) for Pulse Amplitude (0-100% expansion relative to baseline), current phase, phase duration, and last cycle length
3. Green BUY triangles with "PULSE ↑" label fire when a systole begins bullishly above the axis EMA; pink SELL triangles fire when it begins bearishly below
4. Use the cycle length as a rhythm guide: if the last systole lasted N bars, the next is typically due around the same cadence
5. Decrease Baseline ATR Length to make the detector more reactive; increase it for more selective phase detection

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Pulsing volatility bands with live phase color fill
- Live systole/diastole phase background tint across history

🔶 SETTINGS GUIDE

- Fast ATR Length -- Short-term volatility window used for phase classification
- Baseline ATR Length -- Long-term volatility reference; larger values produce slower phase transitions
- Axis EMA Length -- Central EMA around which pulse bands are drawn
- Pivot Length for Signal -- Lookback for the recent extreme that price must close beyond
- Volume SMA Length -- Baseline for volume confirmation
- Pulse Band Multiplier -- Width multiplier of the visual pulse bands
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- VPD Buy Systole -- Bullish systole onset confirmed
- VPD Sell Systole -- Bearish systole onset confirmed
- VPD Any Signal -- Any directional pulse signal
- VPD Systole Start -- Any fresh systole (expansion) begins
- VPD Diastole Start -- Any fresh diastole (contraction) begins
- VPD Strong Pulse -- Pulse amplitude exceeds 60%
- VPD Flat Pulse -- Pulse amplitude falls below 10%
- VPD Bull Expansion -- Active bullish systole above axis
- VPD Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past volatility cycles do not guarantee future price movements.
- Phase transitions are derived from ATR ratios; during regime shifts the baseline re-calibrates over time.
- Cycle length statistics are descriptive, not predictive -- they describe past rhythm, not guaranteed future timing.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Volatility Pulse Detector [forexobroker]", shorttitle="VPD [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_pulse  = "Pulse Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_atrFast    = input.int(10, "Fast ATR Length", minval=3, maxval=30, group=g_pulse, tooltip="Short-term ATR for phase detection")
int    i_atrBase    = input.int(50, "Baseline ATR Length", minval=20, maxval=200, group=g_pulse, tooltip="Long-term ATR baseline")
int    i_emaLen     = input.int(30, "Axis EMA Length", minval=10, maxval=100, group=g_pulse, tooltip="Central axis for pulse bands")
int    i_pivotLen   = input.int(5, "Pivot Length for Signal", minval=2, maxval=20, group=g_pulse)
int    i_volLen     = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_pulse)
float  i_bandMult   = input.float(1.5, "Pulse Band Multiplier", minval=0.5, maxval=4.0, step=0.1, group=g_visual, tooltip="Width multiplier for pulse bands")
int    i_cooldown   = input.int(10, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable  = input.bool(true, "Show Pulse Dashboard", group=g_visual)
bool   i_showBands  = input.bool(true, "Show Pulsing Bands", group=g_visual)
bool   i_showPhaseBg = input.bool(true, "Show Phase Background", group=g_visual)
bool   i_showGlow   = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
color  i_buyColor   = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor  = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrFast   = ta.atr(i_atrFast)
float atrBase   = ta.atr(i_atrBase)
float detrended = atrBase > 0 ? (atrFast - atrBase) / atrBase : 0.0
float emaAxis   = ta.ema(close, i_emaLen)
float volSma    = ta.sma(volume, i_volLen)

// Phases: systole = expansion (detrended > 0), diastole = contraction (detrended < 0)
bool  isSystole  = detrended > 0
bool  isDiastole = detrended < 0
bool  phaseStart = isSystole and not isSystole[1]
bool  phaseEnd   = isDiastole and not isDiastole[1]

// Phase duration counter
var int phaseBars = 0
var bool prevSystole = false
if isSystole != prevSystole
    phaseBars := 0
    prevSystole := isSystole
else
    phaseBars := phaseBars + 1

// BPM: bars between consecutive systole starts
var int lastSystoleBar = 0
var int cycleBars = 0
if phaseStart
    if lastSystoleBar > 0
        cycleBars := bar_index - lastSystoleBar
    lastSystoleBar := bar_index

float bpmRaw = cycleBars > 0 ? 1.0 / float(cycleBars) * 60.0 : 0.0
float pulseAmp = math.abs(detrended) * 100.0
string pulseGrade = pulseAmp >= 60 ? "STRONG" : pulseAmp >= 30 ? "NORMAL" : pulseAmp >= 10 ? "WEAK" : "FLAT"
color  gradeCol = pulseAmp >= 60 ? c_gold : pulseAmp >= 30 ? c_green : pulseAmp >= 10 ? c_cyan : color.gray

// ─── PULSE BANDS ───────────────────────────────────────────────────────────────
float bandWidth = atrFast * i_bandMult * (1.0 + math.max(detrended, -0.5))
float upperBand = emaAxis + bandWidth
float lowerBand = emaAxis - bandWidth

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool volConfirm = volume > volSma
bool confirmed  = barstate.isconfirmed

float recentHigh = ta.highest(high, i_pivotLen)[1]
float recentLow  = ta.lowest(low,  i_pivotLen)[1]

bool rawBuy  = phaseStart and close > emaAxis and close > recentHigh and volConfirm and cooldownOk and confirmed
bool rawSell = phaseStart and close < emaAxis and close < recentLow  and volConfirm and cooldownOk and confirmed

bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Phase Background ──────────────────────────────────────────────────
color phaseBg = na
if i_showPhaseBg
    if isSystole
        phaseBg := color.new(c_green, 93)
    else if isDiastole
        phaseBg := color.new(c_purple, 96)
bgcolor(phaseBg)

// ─── VISUAL: EMA Axis with 3-Layer Glow ───────────────────────────────────────
plot(emaAxis, "Axis Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(emaAxis, "Axis Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(emaAxis, "Axis Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: Pulse Bands (expand/contract with volatility) ────────────────────
p_upper = plot(i_showBands ? upperBand : na, "Upper Pulse", color=color.new(c_cyan, 50), linewidth=2)
p_lower = plot(i_showBands ? lowerBand : na, "Lower Pulse", color=color.new(c_cyan, 50), linewidth=2)
fill(p_upper, p_lower, color=i_showBands ? color.new(isSystole ? c_green : c_purple, 92) : na)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="PULSE ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="PULSE ↓", textcolor=color.white)

// ─── VISUAL: Signal Context Label ──────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrFast * 1.5, "SYSTOLE ↑\nAmp: " + str.tostring(math.round(pulseAmp)) + "\n" + pulseGrade, style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrFast * 1.5, "SYSTOLE ↓\nAmp: " + str.tostring(math.round(pulseAmp)) + "\n" + pulseGrade, style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Pulse Dashboard ───────────────────────────────────────────────────
string phaseStr = isSystole ? "♥ SYSTOLE" : isDiastole ? "◯ DIASTOLE" : "— FLAT"
color  phaseCol = isSystole ? c_green : isDiastole ? c_purple : color.gray

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Volatility Pulse Detector", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, phaseStr, text_color=phaseCol, text_size=size.normal)
    table.cell(dash, 0, 1, "Pulse Amplitude", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(math.round(pulseAmp)) + "%", text_color=gradeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Grade", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, pulseGrade, text_color=gradeCol, text_size=size.small)
    table.cell(dash, 0, 3, "Phase Duration", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(phaseBars) + " bars", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Last Cycle", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(cycleBars) + " bars", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 5, "Fast ATR", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(atrFast, 4)), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Baseline ATR", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(atrBase, 4)), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"VPD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"amp":' + str.tostring(math.round(pulseAmp)) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"VPD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"amp":' + str.tostring(math.round(pulseAmp)) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                "VPD Buy Systole",       "Volatility Pulse BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,               "VPD Sell Systole",      "Volatility Pulse SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,  "VPD Any Signal",        "Any pulse signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(phaseStart,               "VPD Systole Start",     "Systole (expansion) phase started on {{ticker}} {{interval}}")
alertcondition(phaseEnd,                 "VPD Diastole Start",    "Diastole (contraction) phase started on {{ticker}} {{interval}}")
alertcondition(pulseAmp >= 60,           "VPD Strong Pulse",      "Strong pulse amplitude on {{ticker}} {{interval}}")
alertcondition(pulseAmp <= 10,           "VPD Flat Pulse",        "Flat pulse detected on {{ticker}} {{interval}}")
alertcondition(isSystole and close > emaAxis, "VPD Bull Expansion","Bullish systole above axis on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,  "VPD Webhook JSON",      "{\"action\":\"signal\",\"indicator\":\"VPD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
