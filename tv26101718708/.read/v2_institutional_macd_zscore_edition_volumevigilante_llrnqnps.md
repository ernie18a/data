# V2 Institutional MACD (Z-Score Edition) [VolumeVigilante]

- url: https://www.tradingview.com/script/LLRnqNps-V2-Institutional-MACD-Z-Score-Edition-VolumeVigilante/
- type: indicator
- pine_id: PUB;bdd20542abc247e5b499d8eda1754d68
- version: 1.0

## Description

all the credit goes to [VolumeVigilante]. I just added an automation for the scanning of higher timeframes. See https://www.tradingview.com/script/LeQQ4Y8W-Institutional-MACD-Z-Score-Edition-VolumeVigilante/#chart-view-comment-form for the original

## Source Code

````pine
// ==============================================================================
// 🔍 Institutional MACD (Z-Score Edition)
// — Classic MACD reengineered with full z-score normalization
// — Highlights statistically significant momentum and divergence
// — Designed for professional-grade breakout detection
// © VolumeVigilante | Trade Smart. Trade Vigilantly.
// ==============================================================================

//@version=6
indicator("V2 Institutional MACD (Z-Score Edition) [VolumeVigilante]", overlay=false)

// === 📥 INPUTS =================================================================
fastLength       = input.int(12, title="MACD Fast Length", tooltip="Fast EMA length for MACD calculation (default: 12)")
slowLength       = input.int(26, title="MACD Slow Length", tooltip="Slow EMA length for MACD calculation (default: 26)")
signalLength     = input.int(9,  title="Signal Smoothing Length", tooltip="EMA smoothing length for the MACD signal line (default: 9)")
src              = input.source(close, title="Source", tooltip="Input source for MACD (typically close price)")

zScoreLength     = input.int(50, title="Z-Score Lookback Length", tooltip="Number of bars to look back for Z-Score normalization")
zScoreThreshold  = input.float(1.0, minval=0.1, step=0.1, title="Z-Score Threshold Level", tooltip="Custom threshold for overbought/oversold zones and alert triggers")

showZHistogram   = input.bool(true, title="Show Z-Scored Histogram", tooltip="Toggle display of the z-score normalized histogram (MACD - Signal)")
showZLines       = input.bool(true, title="Show Z-Scored MACD Lines", tooltip="Toggle display of the z-score normalized MACD and Signal lines")
showZBands       = input.bool(true, title="Show ±Z Threshold Bands", tooltip="Toggle display of Z-Score threshold bands")

// === ⚙️ MACD CORE ==============================================================
fastMA     = ta.ema(src, fastLength)
slowMA     = ta.ema(src, slowLength)
macdLine   = fastMA - slowMA
signalLine = ta.ema(macdLine, signalLength)
hist       = macdLine - signalLine

// === 🧠 Z-SCORE TRANSFORMATION =================================================
zHist    = (hist       - ta.sma(hist,       zScoreLength)) / ta.stdev(hist,       zScoreLength)
macdZ    = (macdLine   - ta.sma(macdLine,   zScoreLength)) / ta.stdev(macdLine,   zScoreLength)
signalZ  = (signalLine - ta.sma(signalLine, zScoreLength)) / ta.stdev(signalLine, zScoreLength)

// === 🎨 VISUAL LOGIC: HISTOGRAM COLORING ======================================
isRising  = zHist > zHist[1]
histColor = zHist >= 0 ? (isRising ? #26A69A : #B2DFDB) : (isRising ? #FFCDD2 : #FF5252)

// === 📊 PLOTS ==================================================================
plot(showZHistogram ? zHist : na, title="Z-Score Histogram", style=plot.style_columns, color=histColor, linewidth=1)
plot(showZLines ? macdZ : na,    title="Z-MACD Line",        color=#2962FF, linewidth=1)
plot(showZLines ? signalZ : na,  title="Z-Signal Line",      color=#FF6D00, linewidth=1)

// === 📈 REFERENCE LINES ========================================================
hline(0, "Zero", color=color.new(#787B86, 50))
plot(showZBands ? zScoreThreshold : na,  title="+Z Threshold", color=#26A69A, linewidth=1, style=plot.style_line)
plot(showZBands ? -zScoreThreshold : na, title="-Z Threshold", color=#FF5252, linewidth=1, style=plot.style_line)

// === 🚨 ALERTS ==================================================================
alertcondition(zHist > zScoreThreshold,               title="Z-Score > Threshold",  message="Z-Score is above threshold (Overbought)")
alertcondition(zHist < -zScoreThreshold,              title="Z-Score < Threshold",  message="Z-Score is below threshold (Oversold)")
alertcondition(ta.crossover(zHist, 0),                title="Z-Score Bull Cross",   message="Z-Score crossed above 0")
alertcondition(ta.crossunder(zHist, 0),               title="Z-Score Bear Cross",   message="Z-Score crossed below 0")

// === 🌐 BI-DIRECTIONAL MTF RESONANCE ENGINE (Pro-Edition mit Panel & Alerts) ==
calc_native_z_hist(_f, _s, _sig, _len) =>
    _raw_fast   = ta.ema(close, _f)
    _raw_slow   = ta.ema(close, _s)
    _raw_macd   = _raw_fast - _raw_slow
    _raw_signal = ta.ema(_raw_macd, _sig)
    _raw_hist   = _raw_macd - _raw_signal
    (_raw_hist - ta.sma(_raw_hist, _len)) / ta.stdev(_raw_hist, _len)

// Absolute Verankerung
z_3M = request.security(syminfo.tickerid, "3M", calc_native_z_hist(fastLength, slowLength, signalLength, zScoreLength)[1], barmerge.gaps_off)
z_1M = request.security(syminfo.tickerid, "1M", calc_native_z_hist(fastLength, slowLength, signalLength, zScoreLength)[1], barmerge.gaps_off)
z_2W = request.security(syminfo.tickerid, "2W", calc_native_z_hist(fastLength, slowLength, signalLength, zScoreLength)[1], barmerge.gaps_off)
z_1W = request.security(syminfo.tickerid, "1W", calc_native_z_hist(fastLength, slowLength, signalLength, zScoreLength)[1], barmerge.gaps_off)
z_3D = request.security(syminfo.tickerid, "3D", calc_native_z_hist(fastLength, slowLength, signalLength, zScoreLength)[1], barmerge.gaps_off)
z_1D = request.security(syminfo.tickerid, "1D", calc_native_z_hist(fastLength, slowLength, signalLength, zScoreLength)[1], barmerge.gaps_off)

// 🧠 3-PHASEN VEKTOR-SPEICHER
var int st_3M = 0
var int st_1M = 0
var int st_2W = 0
var int st_1W = 0
var int st_3D = 0
var int st_1D = 0

// Logik 3M
if z_3M < -zScoreThreshold and z_3M > z_3M[1]
    st_3M := 1
if st_3M == 1 and (z_3M > 0 or z_3M < z_3M[1])
    st_3M := 0
if z_3M > zScoreThreshold and z_3M < z_3M[1]
    st_3M := -1
if st_3M == -1 and (z_3M < 0 or z_3M > z_3M[1])
    st_3M := 0

// Logik 1M
if z_1M < -zScoreThreshold and z_1M > z_1M[1]
    st_1M := 1
if st_1M == 1 and (z_1M > 0 or z_1M < z_1M[1])
    st_1M := 0
if z_1M > zScoreThreshold and z_1M < z_1M[1]
    st_1M := -1
if st_1M == -1 and (z_1M < 0 or z_1M > z_1M[1])
    st_1M := 0

// Logik 2W
if z_2W < -zScoreThreshold and z_2W > z_2W[1]
    st_2W := 1
if st_2W == 1 and (z_2W > 0 or z_2W < z_2W[1])
    st_2W := 0
if z_2W > zScoreThreshold and z_2W < z_2W[1]
    st_2W := -1
if st_2W == -1 and (z_2W < 0 or z_2W > z_2W[1])
    st_2W := 0

// Logik 1W
if z_1W < -zScoreThreshold and z_1W > z_1W[1]
    st_1W := 1
if st_1W == 1 and (z_1W > 0 or z_1W < z_1W[1])
    st_1W := 0
if z_1W > zScoreThreshold and z_1W < z_1W[1]
    st_1W := -1
if st_1W == -1 and (z_1W < 0 or z_1W > z_1W[1])
    st_1W := 0

// Logik 3D
if z_3D < -zScoreThreshold and z_3D > z_3D[1]
    st_3D := 1
if st_3D == 1 and (z_3D > 0 or z_3D < z_3D[1])
    st_3D := 0
if z_3D > zScoreThreshold and z_3D < z_3D[1]
    st_3D := -1
if st_3D == -1 and (z_3D < 0 or z_3D > z_3D[1])
    st_3D := 0

// Logik 1D
if z_1D < -zScoreThreshold and z_1D > z_1D[1]
    st_1D := 1
if st_1D == 1 and (z_1D > 0 or z_1D < z_1D[1])
    st_1D := 0
if z_1D > zScoreThreshold and z_1D < z_1D[1]
    st_1D := -1
if st_1D == -1 and (z_1D < 0 or z_1D > z_1D[1])
    st_1D := 0

// Arrays für die dynamische IPO-Schleife
g_tf_states    = array.new_int(6, 0)
g_tf_weights   = array.new_int(6, 0)
g_tf_available = array.new_bool(6, false)

array.set(g_tf_weights, 0, 40), array.set(g_tf_weights, 1, 25), array.set(g_tf_weights, 2, 15)
array.set(g_tf_weights, 3, 10), array.set(g_tf_weights, 4, 6),  array.set(g_tf_weights, 5, 4)

array.set(g_tf_available, 0, not na(z_3M)), array.set(g_tf_states, 0, st_3M)
array.set(g_tf_available, 1, not na(z_1M)), array.set(g_tf_states, 1, st_1M)
array.set(g_tf_available, 2, not na(z_2W)), array.set(g_tf_states, 2, st_2W)
array.set(g_tf_available, 3, not na(z_1W)), array.set(g_tf_states, 3, st_1W)
array.set(g_tf_available, 4, not na(z_3D)), array.set(g_tf_states, 4, st_3D)
array.set(g_tf_available, 5, not na(z_1D)), array.set(g_tf_states, 5, st_1D)

int g_net_score = 0
int g_max_possible_weight = 0

for i = 0 to 5
    if array.get(g_tf_available, i)
        g_max_possible_weight := g_max_possible_weight + array.get(g_tf_weights, i)
        g_net_score := g_net_score + (array.get(g_tf_weights, i) * array.get(g_tf_states, i))

// V6 Fix: Reine Berechnung ohne Inline-Zuweisung
float global_resonance_score = g_max_possible_weight > 0 ? (float(g_net_score) / float(g_max_possible_weight)) * 100.0 : 0.0
float quantized_score = math.round(global_resonance_score / 5.0) * 5.0

// === 🎨 ERGONOMISCHE FARBMATRIX (Aufgehelltes Schieferblau/Graublau als Basis) ==
int r = 69, int g = 90, int b = 100

if quantized_score > 0
    float t = quantized_score / 100.0
    r := int(69 + (0 - 69) * t)
    g := int(90 + (230 - 90) * t)
    b := int(100 + (118 - 100) * t)
else if quantized_score < 0
    float t = math.abs(quantized_score) / 100.0
    r := int(69 + (255 - 69) * t)
    g := int(90 + (23 - 90) * t)
    b := int(100 + (68 - 100) * t)

color global_gradient = color.rgb(r, g, b)
plot(-3.5, title="Bi-Directional MTF Ribbon", color=global_gradient, linewidth=8, style=plot.style_line)

// === 🚨 ALERTS SYSTEM =========================================================
alert_threshold = input.float(70.0, title="Resonance Alert Trigger Level")
momentum_speed  = input.float(30.0, title="Momentum Fast Shift Spike")

bull_trigger   = ta.crossover(global_resonance_score, alert_threshold)
bear_trigger   = ta.crossunder(global_resonance_score, -alert_threshold)
momentum_spike = math.abs(global_resonance_score - global_resonance_score[1]) >= momentum_speed

alertcondition(bull_trigger,   title="Vector BUY Resonance!", message="Mustergültige BUY-Resonanz erreicht: {{ticker}} Net Score ist über {{value}}%")
alertcondition(bear_trigger,   title="Vector SELL Resonance!", message="Mustergültige SELL-Resonanz erreicht: {{ticker}} Net Score ist unter -{{value}}%")
alertcondition(momentum_spike, title="Momentum Spike Alert!",  message="Achtung: Aggressiver Kapital-Spike bei {{ticker}}! Verschiebung um {{plot_0}}% innerhalb einer Periode.")

// === 📊 DATA WINDOW & ERGONOMISCHES DASHBOARD-PANEL (Unten Rechts) ============
plot(global_resonance_score, title="Net Resonance Vector %", color=global_gradient, display=display.data_window)

var table panel = table.new(position.bottom_right, 2, 1, bgcolor=color.new(#151924, 20), border_color=color.new(#363a45, 50), border_width=1)
if barstate.islast
    string score_text = (global_resonance_score >= 0 ? "+" : "") + str.tostring(math.round(global_resonance_score)) + "%"
    color text_color  = global_resonance_score > 0 ? #00E676 : (global_resonance_score < 0 ? #FF1744 : #90A4AE)
    
    table.cell(panel, 0, 0, "Resonanz-Score:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 0, score_text, text_color=text_color, text_size=size.small)
````
