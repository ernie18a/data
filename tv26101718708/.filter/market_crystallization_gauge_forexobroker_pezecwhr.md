# Market Crystallization Gauge [forexobroker]

- url: https://www.tradingview.com/script/PEzeCWhR-Market-Crystallization-Gauge-forexobroker/
- type: indicator
- pine_id: PUB;0f646444d10c49c0ab37b31c2c36d782
- version: 1.0

## Description

Market Crystallization Gauge detects the exact moment a market transitions from chaotic noise into structured directional movement. It fuses three independent regime signals -- bar-to-bar return correlation, ADX trend strength and its slope, and standard-deviation contraction of returns -- into a single 0-100 Crystallization Score. When the score breaches the threshold with a clear directional bias (DI+ vs DI- plus price versus regime EMA), the market is classified as CRYSTALLIZED and a signal fires.

This indicator is designed for traders who want to avoid chop and only deploy capital once the market commits to a direction. The regime background gradient makes chaos visually distinct from forming and fully crystallized conditions, turning the chart into a live regime map.

🔶 CONCEPTS

Financial markets oscillate between two states: noise (random, mean-reverting chaos) and trend (structured, persistent movement). The transition between these states is usually sharp and identifiable by three concurrent changes: the autocorrelation of bar-to-bar returns becomes positive (each move tends to continue in the same direction), the ADX rises and accelerates (directional strength compounds), and the volatility of returns contracts relative to baseline (the market stabilizes around its new trajectory). When all three happen together, the market has crystallized.

🔶 HOW IT WORKS

- Computes return autocorrelation across the correlation window (structure indicator)
- Calculates ADX, DI+, DI-, and the 3-bar ADX slope (strength indicator)
- Measures short-term standard deviation of returns versus a longer baseline (contraction indicator)
- Combines the three into a 0-100 Crystallization Score and labels the regime (CHAOS / TRANSITIONING / FORMING / CRYSTALLIZED)
- Signal fires on the bar where the score first crosses above the threshold with matching directional bias

🔶 HOW TO USE

1. Add the indicator -- the regime background gradient tints bars by regime (bright gold for fully crystallized, cyan for forming, purple for transition)
2. Watch the dashboard (top-right) for live Crystallization Score, regime label, directional bias, and component breakdowns
3. Green BUY triangles with "CRYST ↑" label fire on bullish crystallization onsets; pink SELL triangles on bearish
4. The regime EMA plotted with glow defines price-vs-axis bias that gates signals
5. Raise the Crystallization Threshold for only fully crystallized entries; lower it for earlier but less confirmed entries

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Three-factor regime composite (correlation + ADX + std-dev contraction)
- Regime background gradient that visualizes market state across history

🔶 SETTINGS GUIDE

- Correlation Length -- Lookback for bar-to-bar return autocorrelation
- ADX/DMI Length -- Period for Average Directional Index and directional indicators
- StdDev Length -- Short-term return volatility window
- StdDev Baseline Length -- Longer baseline used as the contraction reference
- Volume SMA Length -- Baseline for volume confirmation
- Regime EMA Length -- EMA used for directional bias classification
- Crystallization Threshold -- Minimum 0-100 score to trigger signal
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- MCG Buy Crystallize -- Bullish crystallization transition confirmed
- MCG Sell Crystallize -- Bearish crystallization transition confirmed
- MCG Any Signal -- Any directional crystallization
- MCG Fully Crystallized -- Crystallization score reaches 85+
- MCG Transition -- Score crosses threshold (either direction)
- MCG Strong ADX -- ADX exceeds 30
- MCG StdDev Contraction -- Return volatility contracts below 0.7 of baseline
- MCG Bullish Regime -- Bullish bias with forming or higher regime
- MCG Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past regime transitions do not guarantee future price movements.
- ADX and correlation measurements are lagging by nature; crystallization is confirmed only after the evidence accumulates.
- The Crystallization Score is a composite heuristic, not a statistically calibrated probability of trend persistence.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Market Crystallization Gauge [forexobroker]", shorttitle="MCG [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_crys   = "Crystallization Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_corrLen    = input.int(14, "Correlation Length", minval=5, maxval=50, group=g_crys, tooltip="Lookback for bar-to-bar return correlation")
int    i_adxLen     = input.int(14, "ADX/DMI Length", minval=5, maxval=50, group=g_crys, tooltip="Length for ADX and directional indicators")
int    i_stdLen     = input.int(20, "StdDev Length", minval=5, maxval=100, group=g_crys, tooltip="Lookback for return standard deviation")
int    i_stdSmoothLen = input.int(50, "StdDev Baseline Length", minval=20, maxval=200, group=g_crys)
int    i_volLen     = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_crys)
int    i_emaLen     = input.int(50, "Regime EMA Length", minval=10, maxval=200, group=g_crys)
int    i_crysThresh = input.int(75, "Crystallization Threshold", minval=50, maxval=95, group=g_signal, tooltip="Minimum 0-100 score to trigger signal")
int    i_cooldown   = input.int(15, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable  = input.bool(true, "Show Crystallization Dashboard", group=g_visual)
bool   i_showBg     = input.bool(true, "Show Regime Background Gradient", group=g_visual)
bool   i_showGlow   = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showEma    = input.bool(true, "Show Regime EMA Glow", group=g_visual)
color  i_buyColor   = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor  = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float ret        = ta.change(close)
float retPrev    = ret[1]
float corrRet    = ta.correlation(ret, retPrev, i_corrLen)
[diPlus, diMinus, adxVal] = ta.dmi(i_adxLen, i_adxLen)
float adxSlope   = ta.change(adxVal, 3)
float stdRet     = ta.stdev(ret, i_stdLen)
float stdBase    = ta.sma(stdRet, i_stdSmoothLen)
float stdRatio   = stdBase > 0 ? stdRet / stdBase : 1.0
float emaReg     = ta.ema(close, i_emaLen)
float volSma     = ta.sma(volume, i_volLen)

// ─── CRYSTALLIZATION SCORING (3 components, total 0-100) ──────────────────────
// 1. Persistent directional returns (positive bar-to-bar correlation = structured)
float s_corr = math.max(math.min(corrRet * 60.0 + 30.0, 40.0), 0.0)

// 2. ADX rising (momentum building into direction)
float s_adx = math.max(math.min((adxVal - 15.0) * 1.5 + adxSlope * 3.0, 35.0), 0.0)

// 3. StdDev contraction relative to baseline (chaos shrinking)
float s_std = math.max(math.min((1.2 - stdRatio) * 50.0, 25.0), 0.0)

float crysScore = math.round(s_corr + s_adx + s_std)
bool  isCrystallized = crysScore >= i_crysThresh

// ─── DIRECTIONAL BIAS ──────────────────────────────────────────────────────────
bool  bullBias = diPlus > diMinus and close > emaReg
bool  bearBias = diMinus > diPlus and close < emaReg

// ─── REGIME CLASSIFICATION ─────────────────────────────────────────────────────
string regime = crysScore >= 85 ? "CRYSTALLIZED" : crysScore >= 60 ? "FORMING" : crysScore >= 40 ? "TRANSITIONING" : "CHAOS"
color  regCol = crysScore >= 85 ? c_gold : crysScore >= 60 ? c_green : crysScore >= 40 ? c_cyan : color.gray

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool volConfirm = volume > volSma
bool confirmed  = barstate.isconfirmed
bool justCrystallized = isCrystallized and not isCrystallized[1]

bool rawBuy  = justCrystallized and bullBias and volConfirm and cooldownOk and confirmed
bool rawSell = justCrystallized and bearBias and volConfirm and cooldownOk and confirmed

bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Regime Background Gradient ───────────────────────────────────────
color regBg = na
if i_showBg
    if crysScore >= 85
        regBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_gold, 90)
    else if crysScore >= 60
        regBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_cyan, 94)
    else if crysScore >= 40
        regBg := color.new(c_purple, 96)
bgcolor(regBg)

// ─── VISUAL: Regime EMA with 3-Layer Glow ─────────────────────────────────────
plot(i_showEma ? emaReg : na, "EMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(i_showEma ? emaReg : na, "EMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(i_showEma ? emaReg : na, "EMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CRYST ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CRYST ↓", textcolor=color.white)

// ─── VISUAL: Crystallization Context Label ─────────────────────────────────────
float atrVal = ta.atr(14)
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "CRYSTALLIZED ↑\nScore: " + str.tostring(crysScore) + "/100\nADX: " + str.tostring(math.round(adxVal)), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "CRYSTALLIZED ↓\nScore: " + str.tostring(crysScore) + "/100\nADX: " + str.tostring(math.round(adxVal)), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Crystallization Dashboard ─────────────────────────────────────────
string biasStr = bullBias ? "BULL" : bearBias ? "BEAR" : "NEUTRAL"
color  biasCol = bullBias ? c_green : bearBias ? c_pink : color.gray

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Market Crystallization Gauge", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Crys Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(crysScore) + "/100", text_color=regCol, text_size=size.small)
    table.cell(dash, 0, 2, "Regime", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, regime, text_color=regCol, text_size=size.small)
    table.cell(dash, 0, 3, "Bias", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, biasStr, text_color=biasCol, text_size=size.small)
    table.cell(dash, 0, 4, "Return Corr", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(math.round(corrRet, 2)), text_color=corrRet > 0.2 ? c_green : corrRet < -0.2 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "ADX", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(adxVal, 1)), text_color=adxVal > 25 ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 6, "DI+ / DI-", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(diPlus, 1)) + " / " + str.tostring(math.round(diMinus, 1)), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 7, "StdDev Ratio", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(math.round(stdRatio, 2)) + "x", text_color=stdRatio < 0.8 ? c_green : stdRatio > 1.2 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"MCG","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"cryst":' + str.tostring(crysScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MCG","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"cryst":' + str.tostring(crysScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                     "MCG Buy Crystallize",   "Market Crystallization BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                    "MCG Sell Crystallize",  "Market Crystallization SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,       "MCG Any Signal",        "Any crystallization signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(crysScore >= 85,               "MCG Fully Crystallized","Crystallization score 85+ on {{ticker}} {{interval}}")
alertcondition(justCrystallized,              "MCG Transition",        "Crystallization transition on {{ticker}} {{interval}}")
alertcondition(adxVal > 30,                   "MCG Strong ADX",        "ADX exceeds 30 on {{ticker}} {{interval}}")
alertcondition(stdRatio < 0.7,                "MCG StdDev Contraction","Return volatility contracting on {{ticker}} {{interval}}")
alertcondition(bullBias and crysScore >= 60,  "MCG Bullish Regime",    "Bullish regime forming on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,       "MCG Webhook JSON",      "{\"action\":\"signal\",\"indicator\":\"MCG\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
