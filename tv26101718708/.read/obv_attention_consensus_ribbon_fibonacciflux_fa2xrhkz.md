# OBV Attention Consensus Ribbon [FibonacciFlux]

- url: https://www.tradingview.com/script/fA2xRHKZ-OBV-Attention-Consensus-Ribbon-FibonacciFlux/
- type: indicator
- pine_id: PUB;2480ea9a1d1c414fa5c6e1dd2e33464a
- version: 1.0

## Description

An experiment in reading On-Balance Volume across four timeframes at once. Published with what the measurement actually found, including the part that says the previous default could not work.

WHAT IT DOES

Inside each of four timeframes (15m, 1H, 4H, 1D by default) it builds OBV, takes the per-bar slope as the difference of two linear regressions, and standardizes that slope by the rolling standard deviation of OBV over the same timeframe. The result is a z sensor per timeframe. OBV is cumulative, so its level depends on where the chart's history begins - the slope difference and the standard deviation are both invariant to that origin, which is what makes the four timeframes comparable at all.

The white line is the weighted mean of the four z sensors. The ribbon is the weighted dispersion around that mean, so it narrows when the timeframes agree and widens when they do not. Its colour is a geometric mean of three terms: concentration (how tight the dispersion is), side agreement (how much weight sits on one sign), and acceleration agreement (how much weight is moving further in that direction). An audit table prints every sensor's z, its one-bar change, its weight, the consensus, the dispersion, the concentration, both strengths and the current state.

WHAT THE MEASUREMENT FOUND

Two things, both on 6,000 bars of BINANCE:BTCUSDT 15m (5,949 bars after warm-up, 2026-06-17 01:15Z to 2026-08-18 13:00Z), repeated identically on ETHUSDT.

First: the previous default threshold could never be reached. The strength is a geometric mean of three fractions, and the acceleration term keeps it small. Measured over the whole window, the strength peaks at 34.5 on BTCUSDT and 36.0 on ETHUSDT, with a median of 20.1 and a 99th percentile of 31.0. The shipped threshold was 60. So the coloured ribbon never appeared on a single bar, both alerts fired zero times, and the branch that paints the ribbon was unreachable code. That is a calibration error, not a conservative setting, and it is fixed here: the default is now 30, where the coloured state covers 137 of 5,949 bars on BTCUSDT and 173 of 5,949 on ETHUSDT - roughly one bar in forty.

Second: the whole scale is far smaller than the script's own furniture suggested. The consensus never leaves ±0.141 and the dispersion never exceeds 0.132, while the sensor clips at ±3 and the pane drew guide lines at ±1.5. The clip has never once bound. The guides are now at ±0.10, just above the 99th percentile of |consensus| (0.114 on BTCUSDT, 0.116 on ETHUSDT), so they mark something the series actually reaches.

Neither of those is a claim about returns. There is none here: no forward-return figure, no hit rate, no edge. What the indicator offers is a picture of whether four OBV slopes are pointing the same way and how tightly, and the honest reading of the numbers above is that the picture is a low-amplitude one.

HOW THE NUMBERS WERE CHECKED

The whole computation was reimplemented outside Pine and cross-checked against this chart's Data Window: eight quantities on ten bars, with the individual sensors switched on so nothing was left as na. All 80 values round-trip to the exact three decimals TradingView printed. The worst raw disagreement is 4.9e-4, which is the rounding floor of indicator(precision = 3) rather than a modelling error.

That check discriminates. Near-miss variants a careless port would land on fail loudly against the same 80 values: reading the higher timeframes in developing rather than confirmed mode misses 79 of 80, a slope length of 21 instead of 20 misses 73 of 80, and a flipped regression orientation is off by two orders of magnitude more than the tolerance.

SETTINGS

The HTF data mode is the one that changes the meaning rather than the tuning. Confirmed only reads the last closed bar of each requested timeframe, which is why the higher-timeframe sensors are step functions that hold their value across the chart bars inside one higher-timeframe bar. Developing HTF reacts earlier and changes until that bar closes.

The four attention weights are normalized onto a simplex, so only their ratios matter, and an all-zero entry falls back to 0.10 / 0.20 / 0.40 / 0.30.

WHAT CHANGED IN THIS VERSION

The threshold and the guide lines were recalibrated against the measured output range, as described above. The audit table that the settings already promised did not exist in the code - the helper functions for it were written and left unused - and it is now implemented. An MPL header and a leftover compile sentinel plot were added and removed respectively. No computation was changed: every plotted series is identical to the version the 80-value cross-check was run against, which is why the figures above still apply.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("OBV Attention Consensus Ribbon [FibonacciFlux]", "OBV Attn", overlay = false, precision = 3)
// Standalone pane indicator.
// White line: weighted consensus of standardized OBV slope (z) across timeframes.
// Ribbon width: weighted dispersion of the per-timeframe z sensors.
// Ribbon color: geometric fusion of concentration, side agreement, and acceleration agreement.
// Gray line: 1D z sensor drawn as an independent structural reference.
// The 1D reference line is display-only; it adds no extra term to the score.
//
// Scale note, measured rather than assumed: over 5949 ready bars of BTCUSDT 15m the
// consensus never leaves +-0.141 and the dispersion never exceeds 0.132, so the +-3 clip
// inside the sensor never binds and guide lines at +-1.5 would sit ten times outside the
// realised range. The guides are drawn at +-0.10, which is just above the 99th percentile
// of |consensus| (0.114 on BTCUSDT, 0.116 on ETHUSDT).

// -----------------------------------------------------------------------------
// 01. OBV slope sensors
// -----------------------------------------------------------------------------
string G_OBV = "01. OBV slope sensors"
int slopeLength = input.int(20, "OBV regression slope length", minval = 2, group = G_OBV)
int normLength = input.int(50, "OBV normalization length", minval = 2, group = G_OBV)
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Confirmed only", "Developing HTF"], group = G_OBV,
     tooltip = "Confirmed only uses the previous completed bar in each requested timeframe. Developing HTF reacts earlier but changes until the open higher-timeframe bar closes.")

// -----------------------------------------------------------------------------
// 02. Timeframes and attention weights
// -----------------------------------------------------------------------------
string G_TF = "02. Timeframes and attention weights"
string tf15 = input.timeframe("15", "Short-term timeframe", group = G_TF)
string tf1h = input.timeframe("60", "Intraday timeframe", group = G_TF)
string tf4h = input.timeframe("240", "Swing timeframe", group = G_TF)
string tf1d = input.timeframe("1D", "Position timeframe", group = G_TF)
float w15Input = input.float(0.10, "Short-term weight", minval = 0.0, step = 0.05, group = G_TF)
float w1hInput = input.float(0.20, "Intraday weight", minval = 0.0, step = 0.05, group = G_TF)
float w4hInput = input.float(0.40, "Swing weight", minval = 0.0, step = 0.05, group = G_TF)
float w1dInput = input.float(0.30, "Position weight", minval = 0.0, step = 0.05, group = G_TF)

// -----------------------------------------------------------------------------
// 03. Consensus and ribbon
// -----------------------------------------------------------------------------
string G_CONF = "03. Consensus and ribbon"
float sigmaScale = input.float(1.5, "Concentration sigma scale", minval = 0.1, maxval = 6.0, step = 0.1, group = G_CONF)
float accelScale = input.float(0.5, "Acceleration z-change scale", minval = 0.05, maxval = 2.0, step = 0.05, group = G_CONF)
float bandMultiplier = input.float(1.0, "Dispersion band multiplier", minval = 0.0, maxval = 5.0, step = 0.10, group = G_CONF)
float strengthThreshold = input.float(30.0, "Colored-ribbon strength threshold", minval = 0.0, maxval = 100.0, step = 5.0, group = G_CONF,
     tooltip = "The strength is a geometric mean of concentration, side agreement and acceleration agreement, and the acceleration term keeps it small: measured over 5949 ready bars of BTCUSDT 15m it peaks at 34.5, median 20.1, and on ETHUSDT it peaks at 36.0. The original default of 60 was therefore unreachable - the coloured ribbon and both alerts could never fire. At 30 the coloured state covers 137 of 5949 bars on BTCUSDT and 173 of 5949 on ETHUSDT.")
bool signalOnClose = input.bool(true, "Alerts only on confirmed chart bars", group = G_CONF)

// -----------------------------------------------------------------------------
// 04. Visuals
// -----------------------------------------------------------------------------
string G_VIS = "04. Visuals"
bool showZ1d = input.bool(true, "Show 1D z structural reference", group = G_VIS)
bool showSensors = input.bool(false, "Show individual z sensors", group = G_VIS)
bool shadeBackground = input.bool(false, "Shade strong consensus background", group = G_VIS)
bool showTable = input.bool(true, "Show consensus audit table", group = G_VIS)
string tablePos = input.string("Top right", "Audit table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = G_VIS)
string tableSize = input.string("Small", "Audit table text size", options = ["Tiny", "Small", "Normal"], group = G_VIS)

// -----------------------------------------------------------------------------
// Numeric helpers
// -----------------------------------------------------------------------------
float EPS = 1e-10

f_clip(float value, float lower, float upper) => math.max(lower, math.min(upper, value))

// The complete sensor is evaluated inside each requested timeframe.
// OBV is cumulative, so its absolute level differs between the chart context and
// each requested context. Only the standardized slope (z) is compared across
// timeframes, which keeps the cross-timeframe read meaningful.
f_sensor() =>
    float chg = ta.change(close)
    float vol = nz(volume)
    float obv = ta.cum(chg > 0 ? vol : chg < 0 ? -vol : 0.0)
    float slope = ta.linreg(obv, slopeLength, 0) - ta.linreg(obv, slopeLength, 1)
    float norm = ta.stdev(obv, normLength)
    float z = f_clip(slope / math.max(norm, EPS), -3.0, 3.0)
    float dz = z - z[1]
    bool volOk = not na(volume)
    [z, dz, volOk]

f_sensorConfirmed() =>
    [z, dz, volOk] = f_sensor()
    [z[1], dz[1], volOk[1]]

[z15Dev, dz15Dev, volOk15Dev] = request.security(syminfo.tickerid, tf15, f_sensor(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[z1hDev, dz1hDev, volOk1hDev] = request.security(syminfo.tickerid, tf1h, f_sensor(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[z4hDev, dz4hDev, volOk4hDev] = request.security(syminfo.tickerid, tf4h, f_sensor(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[z1dDev, dz1dDev, volOk1dDev] = request.security(syminfo.tickerid, tf1d, f_sensor(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[z15Con, dz15Con, volOk15Con] = request.security(syminfo.tickerid, tf15, f_sensorConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[z1hCon, dz1hCon, volOk1hCon] = request.security(syminfo.tickerid, tf1h, f_sensorConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[z4hCon, dz4hCon, volOk4hCon] = request.security(syminfo.tickerid, tf4h, f_sensorConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[z1dCon, dz1dCon, volOk1dCon] = request.security(syminfo.tickerid, tf1d, f_sensorConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

confirmedMode = dataMode == "Confirmed only"
float z15 = confirmedMode ? z15Con : z15Dev
float z1h = confirmedMode ? z1hCon : z1hDev
float z4h = confirmedMode ? z4hCon : z4hDev
float z1d = confirmedMode ? z1dCon : z1dDev
float dz15 = confirmedMode ? dz15Con : dz15Dev
float dz1h = confirmedMode ? dz1hCon : dz1hDev
float dz4h = confirmedMode ? dz4hCon : dz4hDev
float dz1d = confirmedMode ? dz1dCon : dz1dDev
bool volOk15 = confirmedMode ? volOk15Con : volOk15Dev
bool volOk1h = confirmedMode ? volOk1hCon : volOk1hDev
bool volOk4h = confirmedMode ? volOk4hCon : volOk4hDev
bool volOk1d = confirmedMode ? volOk1dCon : volOk1dDev

// Normalize attention weights onto a simplex.
// If every weight input is zero, fall back to the default 0.10/0.20/0.40/0.30.
float wSumRaw = w15Input + w1hInput + w4hInput + w1dInput
bool wFallback = wSumRaw <= 0.0
float w15 = (wFallback ? 0.10 : w15Input) / (wFallback ? 1.0 : wSumRaw)
float w1h = (wFallback ? 0.20 : w1hInput) / (wFallback ? 1.0 : wSumRaw)
float w4h = (wFallback ? 0.40 : w4hInput) / (wFallback ? 1.0 : wSumRaw)
float w1d = (wFallback ? 0.30 : w1dInput) / (wFallback ? 1.0 : wSumRaw)

// -----------------------------------------------------------------------------
// Attention consensus and z dispersion
// -----------------------------------------------------------------------------
float consensus = w15 * z15 + w1h * z1h + w4h * z4h + w1d * z1d
float zVariance = w15 * math.pow(z15 - consensus, 2) + w1h * math.pow(z1h - consensus, 2) + w4h * math.pow(z4h - consensus, 2) + w1d * math.pow(z1d - consensus, 2)
float zSigma = math.sqrt(math.max(zVariance, 0.0))
float bandUpper = consensus + bandMultiplier * zSigma
float bandLower = consensus - bandMultiplier * zSigma

// -----------------------------------------------------------------------------
// Geometric fusion components (concentration, side, acceleration)
// -----------------------------------------------------------------------------
float conc = 1.0 - f_clip(zSigma / sigmaScale, 0.0, 1.0)

float bullSide = w15 * (z15 > 0.0 ? 1.0 : 0.0) + w1h * (z1h > 0.0 ? 1.0 : 0.0) + w4h * (z4h > 0.0 ? 1.0 : 0.0) + w1d * (z1d > 0.0 ? 1.0 : 0.0)
float bearSide = w15 * (z15 < 0.0 ? 1.0 : 0.0) + w1h * (z1h < 0.0 ? 1.0 : 0.0) + w4h * (z4h < 0.0 ? 1.0 : 0.0) + w1d * (z1d < 0.0 ? 1.0 : 0.0)

float bullAccel = w15 * f_clip(dz15 / accelScale, 0.0, 1.0) + w1h * f_clip(dz1h / accelScale, 0.0, 1.0) + w4h * f_clip(dz4h / accelScale, 0.0, 1.0) + w1d * f_clip(dz1d / accelScale, 0.0, 1.0)
float bearAccel = w15 * f_clip(-dz15 / accelScale, 0.0, 1.0) + w1h * f_clip(-dz1h / accelScale, 0.0, 1.0) + w4h * f_clip(-dz4h / accelScale, 0.0, 1.0) + w1d * f_clip(-dz1d / accelScale, 0.0, 1.0)

float bullStrength = 100.0 * math.pow(math.max(conc * bullSide * bullAccel, 0.0), 1.0 / 3.0)
float bearStrength = 100.0 * math.pow(math.max(conc * bearSide * bearAccel, 0.0), 1.0 / 3.0)
bool bullActive = bullStrength >= strengthThreshold and bullStrength > bearStrength
bool bearActive = bearStrength >= strengthThreshold and bearStrength > bullStrength
float stateStrength = math.max(bullStrength, bearStrength)

// -----------------------------------------------------------------------------
// Pane visuals
// -----------------------------------------------------------------------------
float bullFrac = f_clip(nz(bullStrength, 0.0) / 100.0, 0.0, 1.0)
float bearFrac = f_clip(nz(bearStrength, 0.0) / 100.0, 0.0, 1.0)
int bullTransparency = int(math.round(92.0 - 62.0 * bullFrac))
int bearTransparency = int(math.round(92.0 - 62.0 * bearFrac))
color ribbonColor = bullActive ? color.new(color.lime, bullTransparency) : bearActive ? color.new(color.red, bearTransparency) : color.new(color.gray, 92)

upperPlot = plot(bandUpper, "Z dispersion upper", color = color.new(color.white, 88), linewidth = 1)
lowerPlot = plot(bandLower, "Z dispersion lower", color = color.new(color.white, 88), linewidth = 1)
plot(consensus, "MTF OBV flow consensus", color = color.white, linewidth = 3)
plot(showZ1d ? z1d : na, "1D z structural reference", color = color.new(color.gray, 25), linewidth = 2)
fill(upperPlot, lowerPlot, color = ribbonColor, title = "OBV attention consensus ribbon")

plot(showSensors ? z15 : na, "15m z sensor", color = color.new(color.aqua, 72), linewidth = 1)
plot(showSensors ? z1h : na, "1H z sensor", color = color.new(color.blue, 68), linewidth = 1)
plot(showSensors ? z4h : na, "4H z sensor", color = color.new(color.orange, 62), linewidth = 1)
plot(showSensors ? z1d : na, "1D z sensor", color = color.new(color.fuchsia, 58), linewidth = 1)

hline(0.10, "Upper guide", color = color.new(color.gray, 70), linestyle = hline.style_dotted)
hline(0.0, "Zero line", color = color.new(color.gray, 50), linestyle = hline.style_solid)
hline(-0.10, "Lower guide", color = color.new(color.gray, 70), linestyle = hline.style_dotted)

bgcolor(shadeBackground ? bullActive ? color.new(color.lime, 95) : bearActive ? color.new(color.red, 95) : na : na, title = "Strong OBV flow consensus")

chartBarGate = not signalOnClose or barstate.isconfirmed
bool bullEvent = chartBarGate and bullActive and not bullActive[1]
bool bearEvent = chartBarGate and bearActive and not bearActive[1]
alertcondition(bullEvent, "OBV flow bullish attention consensus", "Standardized OBV slopes aligned bullishly across timeframes with concentrated dispersion and confirming acceleration.")
alertcondition(bearEvent, "OBV flow bearish attention consensus", "Standardized OBV slopes aligned bearishly across timeframes with concentrated dispersion and confirming acceleration.")

// -----------------------------------------------------------------------------
// Consensus audit table
// -----------------------------------------------------------------------------
f_tfName(string tf) =>
    tf == "15" ? "15m" : tf == "60" ? "1H" : tf == "240" ? "4H" : tf == "1D" ? "1D" : tf

f_num(float value) => na(value) ? "-" : str.tostring(value, "#.000")

f_zColor(float value) =>
    na(value) ? color.gray : value >= 0.0 ? color.lime : color.red

f_wPct(float w) => str.tostring(w * 100.0, "0") + "%"

color cPanel = color.rgb(20, 23, 28)
color cLine = color.rgb(58, 63, 71)
color cInk = color.rgb(216, 220, 226)
color cDim = color.rgb(128, 132, 138)

tablePosition = tablePos == "Top left" ? position.top_left : tablePos == "Bottom right" ? position.bottom_right : tablePos == "Bottom left" ? position.bottom_left : position.top_right
tableTextSize = tableSize == "Tiny" ? size.tiny : tableSize == "Normal" ? size.normal : size.small

var table auditTable = table.new(position.top_right, 4, 8, border_color = cLine, border_width = 1, frame_color = cLine, frame_width = 1)

f_head(int col, int row, string txt) =>
    table.cell(auditTable, col, row, txt, text_color = cDim, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_right)

f_cell(int col, int row, string txt, color txtColor) =>
    table.cell(auditTable, col, row, txt, text_color = txtColor, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_right)

f_left(int col, int row, string txt, color txtColor) =>
    table.cell(auditTable, col, row, txt, text_color = txtColor, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)

if barstate.islast and showTable
    table.set_position(auditTable, tablePosition)

    f_left(0, 0, "TF", cDim)
    f_head(1, 0, "z")
    f_head(2, 0, "dz")
    f_head(3, 0, "w")

    f_left(0, 1, f_tfName(tf15), cInk)
    f_cell(1, 1, f_num(z15), f_zColor(z15))
    f_cell(2, 1, f_num(dz15), f_zColor(dz15))
    f_cell(3, 1, f_wPct(w15), cDim)

    f_left(0, 2, f_tfName(tf1h), cInk)
    f_cell(1, 2, f_num(z1h), f_zColor(z1h))
    f_cell(2, 2, f_num(dz1h), f_zColor(dz1h))
    f_cell(3, 2, f_wPct(w1h), cDim)

    f_left(0, 3, f_tfName(tf4h), cInk)
    f_cell(1, 3, f_num(z4h), f_zColor(z4h))
    f_cell(2, 3, f_num(dz4h), f_zColor(dz4h))
    f_cell(3, 3, f_wPct(w4h), cDim)

    f_left(0, 4, f_tfName(tf1d), cInk)
    f_cell(1, 4, f_num(z1d), f_zColor(z1d))
    f_cell(2, 4, f_num(dz1d), f_zColor(dz1d))
    f_cell(3, 4, f_wPct(w1d), cDim)

    f_left(0, 5, "CONS", cDim)
    f_cell(1, 5, f_num(consensus), f_zColor(consensus))
    f_cell(2, 5, "sd " + f_num(zSigma), cInk)
    f_cell(3, 5, "cc " + str.tostring(conc * 100.0, "0") + "%", cInk)

    f_left(0, 6, "STR", cDim)
    f_cell(1, 6, str.tostring(bullStrength, "0.0"), color.lime)
    f_cell(2, 6, str.tostring(bearStrength, "0.0"), color.red)
    f_cell(3, 6, str.tostring(strengthThreshold, "0") + " thr", cDim)

    f_left(0, 7, "STATE", cDim)
    string stateTxt = bullActive ? "BULL" : bearActive ? "BEAR" : "-"
    color stateCol = bullActive ? color.lime : bearActive ? color.red : cDim
    table.cell(auditTable, 1, 7, stateTxt, text_color = stateCol, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_right)
    f_cell(2, 7, str.tostring(stateStrength, "0.0"), stateCol)
    f_cell(3, 7, volOk15 and volOk1h and volOk4h and volOk1d ? "vol ok" : "no vol", volOk15 and volOk1h and volOk4h and volOk1d ? cDim : color.red)
````
