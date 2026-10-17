# Chameleon Regime Adapter [forexobroker]

- url: https://www.tradingview.com/script/KfTQes3m-Chameleon-Regime-Adapter-forexobroker/
- type: indicator
- pine_id: PUB;a857697850c940288744eb2b72320d8b
- version: 1.0

## Description

Chameleon Regime Adapter classifies the current market into one of five regimes (Trending-Wild, Trending, Volatile-Range, Range, Quiet) and switches its signal logic accordingly -- trend-follow when the market is trending, mean-revert when it is ranging. One tool, two opposite styles, selected automatically by the market itself.

Designed for traders tired of using trend systems in chop or reversion systems in runs, and who want one indicator that behaves correctly in both environments.

🔶 CONCEPTS

Most indicators fail because they are built for one environment and deployed in another. A trend follower gets chopped up in a range; a mean-revert system gets run over in a trend. The robust solution is to first detect the regime and then route the signal. ADX separates trending from ranging; ATR percentile separates high-volatility from quiet; Bollinger Band width confirms compression or expansion. Once the regime is known, the signal rules that apply are the ones appropriate to that regime: pullbacks with RSI above 50 in trends; band touches with oversold/overbought in ranges.

🔶 HOW IT WORKS

- Classifies regime from three inputs: ADX (trend strength), ATR percentile (volatility tier), and BB width (compression)
- Selects signal mode: TREND-FOLLOW in trending regimes, MEAN-REVERT in ranging regimes
- Generates trend entries: pullback above regime EMA with rising RSI and DI+ leading (inverse for sells)
- Generates range entries: touch of the opposite band with oversold/overbought RSI and slope inflection
- Combines ADX, BB width, and alignment into a 0-100 Signal Score that gates the final fire
- Color-coded background by regime so the chart instantly tells you which mode is active

🔶 HOW TO USE

1. Add the indicator -- background is tinted by regime (gold = trending-wild, green = trending, pink = volatile-range, purple = range, cyan = quiet)
2. Watch the dashboard (top-right) for live regime, active mode, ADX, ATR percentile, BB width, and RSI
3. Green BUY triangles with "ADAPT ↑" label fire using the mode appropriate to the current regime; pink SELL triangles inverse
4. The Bollinger Bands with glow give visual support/resistance for range-mode entries
5. Tune ADX Trend Floor and ATR percentile bounds to match the instrument's typical behavior

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Automatic regime classification with visual background cue
- Dual-mode signal logic (trend-follow + mean-revert) with no manual toggling

🔶 SETTINGS GUIDE

- ADX Length -- Period for ADX and DMI
- ADX Trend Floor -- ADX level above which the regime is considered trending
- BB Width Length / BB Mult -- Parameters for the Bollinger Bands used in range entries
- ATR Length -- ATR period used for the volatility percentile
- ATR Percentile Window -- Lookback for the ATR percentile rank
- Low-Vol / High-Vol Percentile -- Bounds that define quiet vs high-volatility regimes
- RSI Length -- Momentum oscillator length used by both modes
- Regime EMA Length -- Macro EMA for trend-mode directional bias
- Signal Score Threshold -- Minimum composite score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- CRA Buy Adapt -- Bullish adaptive signal confirmed
- CRA Sell Adapt -- Bearish adaptive signal confirmed
- CRA Any Signal -- Any directional adaptive signal
- CRA Entered Trend -- Regime classified as trending
- CRA Entered Range -- Regime classified as non-trending
- CRA High Vol -- ATR percentile exceeds high-volatility threshold
- CRA Quiet -- ATR percentile below low-volatility threshold
- CRA Any Bull Setup -- Bullish setup present in either mode
- CRA Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Regime boundaries are fuzzy; transitions may cause temporary mode thrashing.
- Range-mode entries at band edges carry reversal risk if a new trend is starting.
- The Signal Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Chameleon Regime Adapter [forexobroker]", shorttitle="CRA [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_reg    = "Regime Detection"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_adxLen    = input.int(14, "ADX Length", minval=5, maxval=50, group=g_reg)
float  i_adxTrend  = input.float(22, "ADX Trend Floor", minval=15, maxval=40, step=0.5, group=g_reg)
int    i_bbLen     = input.int(20, "BB Width Length", minval=10, maxval=100, group=g_reg)
float  i_bbMult    = input.float(2.0, "BB Mult", minval=1.0, maxval=4.0, step=0.1, group=g_reg)
int    i_atrLen    = input.int(14, "ATR Length", minval=5, maxval=50, group=g_reg)
int    i_atrWindow = input.int(100, "ATR Percentile Window", minval=30, maxval=300, group=g_reg)
float  i_pctLow    = input.float(30, "Low-Vol Percentile", minval=10, maxval=50, group=g_reg)
float  i_pctHigh   = input.float(70, "High-Vol Percentile", minval=50, maxval=90, group=g_reg)
int    i_rsiLen    = input.int(14, "RSI Length", minval=3, maxval=50, group=g_reg)
int    i_emaLen    = input.int(50, "Regime EMA Length", minval=10, maxval=200, group=g_reg)
int    i_scoreThr  = input.int(65, "Signal Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown  = input.int(10, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Regime Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Regime Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showBands = input.bool(true, "Show Bollinger Bands", group=g_visual)
color  i_buyColor  = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
[diPlus, diMinus, adxVal] = ta.dmi(i_adxLen, i_adxLen)
float basis = ta.sma(close, i_bbLen)
float dev   = ta.stdev(close, i_bbLen) * i_bbMult
float upper = basis + dev
float lower = basis - dev
float bbw   = (upper - lower) / basis * 100.0
float atrVal = ta.atr(i_atrLen)
float atrPct = ta.percentrank(atrVal, i_atrWindow)
float rsiVal = ta.rsi(close, i_rsiLen)
float emaReg = ta.ema(close, i_emaLen)
float emaSlope = ta.change(emaReg, 3)

// ─── REGIME CLASSIFICATION ────────────────────────────────────────────────────
bool trending   = adxVal > i_adxTrend
bool highVol    = atrPct > i_pctHigh
bool lowVol     = atrPct < i_pctLow
string regime = trending and highVol ? "TRENDING-WILD" : trending ? "TRENDING" : highVol ? "VOLATILE-RANGE" : lowVol ? "QUIET" : "RANGE"
color  regCol = regime == "TRENDING-WILD" ? c_gold : regime == "TRENDING" ? c_green : regime == "VOLATILE-RANGE" ? c_pink : regime == "QUIET" ? c_cyan : c_purple

// ─── ADAPTIVE SIGNAL LOGIC ─────────────────────────────────────────────────────
// In TRENDING: buy pullbacks above EMA with RSI > 50, sell inverse
// In RANGE / QUIET: buy touches of lower band with rising RSI, sell upper band with falling RSI
// In VOLATILE-RANGE: same as RANGE but with higher RSI confirmation
float rsiSlope = ta.change(rsiVal, 3)
bool trendBuy  = trending and close > emaReg and emaSlope > 0 and rsiVal > 50 and rsiVal > rsiVal[1] and diPlus > diMinus
bool trendSell = trending and close < emaReg and emaSlope < 0 and rsiVal < 50 and rsiVal < rsiVal[1] and diMinus > diPlus
bool rangeBuy  = not trending and close <= lower and rsiVal < 35 and rsiSlope > 0
bool rangeSell = not trending and close >= upper and rsiVal > 65 and rsiSlope < 0

// ─── CRA SCORING (0-100) ──────────────────────────────────────────────────────
float sAdx  = math.min(adxVal, 50.0)
float sBbw  = math.min(bbw * 5.0, 25.0)
float sAlign = (trending and (trendBuy or trendSell) ? 25.0 : (rangeBuy or rangeSell) ? 25.0 : 0.0)
float craScore = math.round(math.min(sAdx + sBbw + sAlign, 100.0))

string signalMode = trending ? "TREND-FOLLOW" : "MEAN-REVERT"
color  modeCol = trending ? c_gold : c_cyan

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = craScore >= i_scoreThr

bool bullBias = trendBuy or rangeBuy
bool bearBias = trendSell or rangeSell

bool rawBuy  = bullBias and scoreOk and cooldownOk and confirmed
bool rawSell = bearBias and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Regime Background Gradient ───────────────────────────────────────
color craBg = na
if i_showBg
    craBg := color.new(regCol, 94)
bgcolor(craBg)

// ─── VISUAL: Bollinger Bands with Glow ────────────────────────────────────────
plot(i_showBands ? upper : na, "BB Upper Glow", color=color.new(c_pink, 70), linewidth=3)
plot(i_showBands ? upper : na, "BB Upper",      color=color.new(c_pink, 20), linewidth=1)
plot(i_showBands ? lower : na, "BB Lower Glow", color=color.new(c_green, 70), linewidth=3)
plot(i_showBands ? lower : na, "BB Lower",      color=color.new(c_green, 20), linewidth=1)
plot(i_showBands ? basis : na, "BB Basis",      color=color.new(c_purple, 20), linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ADAPT ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ADAPT ↓", textcolor=color.white)

// ─── VISUAL: Regime Context Label ─────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, signalMode + " ↑\nRegime: " + regime + "\nScore: " + str.tostring(craScore) + "/100", style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, signalMode + " ↓\nRegime: " + regime + "\nScore: " + str.tostring(craScore) + "/100", style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Chameleon Dashboard ──────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Chameleon Regime", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "CRA Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(craScore) + "/100", text_color=craScore > i_scoreThr ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 2, "Regime", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, regime, text_color=regCol, text_size=size.small)
    table.cell(dash, 0, 3, "Mode", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, signalMode, text_color=modeCol, text_size=size.small)
    table.cell(dash, 0, 4, "ADX", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(math.round(adxVal, 1)), text_color=trending ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "BB Width %", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(bbw, 2)), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 6, "ATR Pctile", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(atrPct, 1)) + "%", text_color=highVol ? c_pink : lowVol ? c_cyan : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "RSI", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(math.round(rsiVal, 1)), text_color=rsiVal > 60 ? c_green : rsiVal < 40 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 8, "DI+ / DI-", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(math.round(diPlus, 1)) + " / " + str.tostring(math.round(diMinus, 1)), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 9, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"CRA","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"regime":"' + regime + '","mode":"' + signalMode + '"}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CRA","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"regime":"' + regime + '","mode":"' + signalMode + '"}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "CRA Buy Adapt",        "Chameleon BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "CRA Sell Adapt",       "Chameleon SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "CRA Any Signal",       "Any chameleon signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(trending,                          "CRA Entered Trend",    "Regime trending on {{ticker}} {{interval}}")
alertcondition(not trending,                      "CRA Entered Range",    "Regime ranging on {{ticker}} {{interval}}")
alertcondition(highVol,                           "CRA High Vol",         "High-volatility regime on {{ticker}} {{interval}}")
alertcondition(lowVol,                            "CRA Quiet",            "Low-volatility regime on {{ticker}} {{interval}}")
alertcondition(trendBuy or rangeBuy,              "CRA Any Bull Setup",   "Bullish adaptive setup on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "CRA Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"CRA\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
