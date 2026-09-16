<!-- tradingview-pine-id: PUB;ac14c8a194c54061991912f6a152a671 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Coppock Curve Multi-Filter [MarkitTick]

Source: https://www.tradingview.com/script/Ua5pRxsd-Coppock-Curve-Multi-Filter-MarkitTick/

## Description

💡 A dual-momentum oscillator built on the classic Coppock Curve, extended with an optional adaptive source pre-filter, an ADX strength gate, and a full ATR-based trade-management layer with staged take-profits, on-chart price levels, and a live dashboard. The core wave is a weighted moving average of two rate-of-change readings, but everything measured downstream of that wave — signal timing, trend bias, and risk levels — can be reshaped by up to eight independent, toggleable filters, giving traders a single oscillator that can behave anywhere from "classic long-term Coppock" to a tightly gated, multi-condition entry engine.

✨ Originality and Utility
The stock Coppock Curve is a single-purpose, long-only momentum tool: sum two rate-of-change readings, smooth with a weighted moving average, and watch for crosses above zero. This script keeps that foundation intact but restructures it into a bidirectional signal engine with a stack of independent confirmation layers that the original concept never included.

The key structural change is the adaptive source stage. Rather than feeding raw closing price directly into the rate-of-change calculations, the script offers a choice of eight different smoothing methods — including a custom Kalman Filter estimator and a custom LLAMA (Linear-Lag Adaptive Moving Average) function — that first condition the price series before Coppock's ROC math is applied. This means the character of the entire curve can be tuned from responsive to heavily smoothed without altering the underlying two-ROC-plus-WMA structure that defines the Coppock method.

Layered on top of that are seven optional gating and confirmation mechanisms (ADX strength, divergence, slope acceleration, volume, higher-timeframe alignment, volatility-adjusted zero line, and signal persistence) that traders can combine in any subset. Because each filter operates independently and can be switched on or off, the same core wave can be configured for a slow trend-confirmation approach or a fast, tightly-filtered signal generator, giving the tool a much broader utility range than a standard Coppock plot.

Beyond signal generation, the script converts each qualifying cross into a full trade plan: an ATR-derived stop-loss, three R-multiple take-profit tiers, live price levels drawn on the chart, and a real-time dashboard summarizing bias, filter states, and trade levels — none of which exist in the original Coppock Curve concept or in standard TradingView implementations of it.

🔬 Methodology and Concepts

● Core Wave Construction
The engine begins with an adaptive source stage. If no adaptive filter is selected, the raw chosen source (default: close) feeds directly into the calculation. If a filter is selected, the source is pre-smoothed using one of the following:

[*]Simple, Exponential, or RMA-based moving averages
[*]A Double WMA (a weighted moving average applied twice in succession, producing extra lag reduction)
[*]A Triple VWMA (three successive volume-weighted moving average passes)
[*]A Hull Moving Average
[*]A custom LLAMA function, which computes a simple moving average over the lookback window, then adds a linear slope term (calculated from the change in price across the window divided by the window length) scaled by half the window length — effectively projecting the average forward along its own recent trajectory
[*]A custom Kalman Filter estimator, which maintains a running estimate and error variance, calculates a Kalman gain each bar from the ratio of predicted error to total error, and blends the new price into the estimate proportionally to that gain — placing more weight on new data when the filter's own uncertainty is high, and more weight on the existing estimate when it is low

Once the (optionally smoothed) source is established, two Rate of Change values are calculated against it — a long lookback and a short lookback, independently configurable. These two ROC values are summed and passed through a weighted moving average, producing the final Coppock Curve value. This is structurally identical to the classic Coppock formula, but with the adaptive pre-filter as an optional intermediate step.

• ADX Strength Filter
When enabled, the script calculates the Directional Movement Index (+DI, -DI, ADX) over a configurable length. A signal — whether a slope change, a cross, or a zero-line cross — is only considered valid if the ADX reading is at or above the user-defined threshold. This filters out Coppock movements that occur during weak or directionless conditions.

• Slope and Cross Detection
The script tracks whether the curve is rising or falling bar-to-bar, and separately detects two types of crosses: a cross of the curve against its own prior value (used as the primary bull/bear signal) and a cross of the curve against the zero line (used as a secondary trend-state signal). Both cross types respect the ADX filter when it is active.

• Signal Locking
A "Lock Signal" input freezes the active signal and trade levels on the most recent bar, preventing new signals from overwriting the currently displayed trade plan — useful for holding a specific setup visible while monitoring live price action.

● Trade-Level Automation
Every new bullish or bearish cross (confirmed and unlocked) triggers a full trade-plan calculation:

[*]Entry is set to the prior bar's close
[*]Stop-loss is placed at a configurable multiple of ATR away from entry, in the direction opposing the trade
[*]Three take-profit levels are calculated as configurable R-multiples of the initial risk distance (the entry-to-stop distance), projected in the trade's favor
[*]Each level's distance from entry is also expressed as a percentage for quick reference

These levels persist on the chart until a new opposing signal fires (or, if Lock Signal is active, until manually released), and are dynamically extended to the current bar so the trade plan remains visible in real time. Take-profit and stop labels update their text once price actually touches each respective level, marking it as hit along with the realized percentage move.

● Optional Confirmation Filters
Seven additional filters exist as inputs in the script but should be understood as configuration flags a trader can layer onto the core signal logic depending on their own methodology:

[*]Divergence Filter — intended to suppress cross signals that run counter to a detected price/Coppock divergence
[*]Slope Acceleration Filter — intended to require the curve's slope itself to be increasing, not merely positive, before validating a signal
[*]Volume Confirmation Filter — intended to require current volume to exceed its moving average before a signal is accepted
[*]HTF Alignment Filter — intended to require a higher-timeframe Coppock reading to agree with the signal's direction
[*]Volatility-Adjusted Zero Line — intended to require zero-line crosses to clear a noise band derived from the indicator's own recent volatility, reducing whipsaw signals near the zero line
[*]Signal Persistence Filter — intended to require the curve's direction to hold for a minimum number of bars before a signal is treated as valid

Traders should treat these as intended-purpose toggles per their input tooltips and confirm behavior against the ADX filter and core cross logic, which are the two filters fully wired into the signal path in this build.

🎨 Visual Guide

● Main Panel (Separate Pane)

[*]The primary line plot shows the Coppock Curve itself. It is colored using the Bull Color when the curve is rising and the ADX filter (if active) passes, the Bear Color when falling under the same condition, and the Neutral Color otherwise.
[*]A histogram of the same Coppock value is plotted in columns beneath the line, using a four-tier color scheme: strong bull shading when the curve is above zero and rising, weak bull shading when above zero but not rising, weak bear shading when below zero but rising, and strong bear shading when below zero and falling.
[*]A dashed horizontal zero line marks the neutral threshold that separates bullish and bearish curve territory.
[*]Small triangle markers appear directly on the curve at the exact bar where it crosses zero — an upward triangle in Bull Color for an upward zero-cross, and a downward triangle in Bear Color for a downward zero-cross.

● Price Chart Overlay

[*]When candle coloring is enabled, the price candles themselves are recolored using the same four-tier histogram coloring described above, turning the price chart into a visual heatmap of underlying Coppock strength and direction.
[*]When a new signal fires and trade levels are enabled, five horizontal lines are drawn directly on price: a solid stop-loss line, a dashed entry line, and three dashed take-profit lines with progressively increasing opacity from TP1 to TP3. Each line carries a right-aligned label showing its role and exact price.
[*]A shaded "risk zone" fills the area between the stop-loss and entry lines, and a "reward zone" fills the area between the entry and TP3 lines, giving an immediate visual sense of the risk-to-reward geometry of the active trade plan.
[*]Once a take-profit or stop level is touched by price, its label updates in place to show a hit confirmation along with the realized percentage gain or loss.

● Dashboard Table
A compact table (position configurable) displays, in real time: the current symbol and timeframe, the Lock Signal state, the raw Coppock value, the current bias (Bullish / Bearish / Neutral, color-coded), the individual long and short ROC readings, whether the curve is currently above or below zero, and — when trade levels are enabled — the live Entry, SL, TP1, TP2, and TP3 prices. If the ADX filter is active, its current reading is shown alongside a pass/fail color cue. If an adaptive filter is selected, its name is displayed for quick reference.

📖 How to Use

[*]Treat a bullish cross (curve turning up) as a potential long-side signal, and a bearish cross (curve turning down) as a potential short-side signal, especially when it aligns with a zero-line cross in the same direction.
[*]Use the zero line as a broader trend-state filter: readings above zero generally reflect positive intermediate-term momentum, while readings below zero reflect negative momentum, independent of the immediate slope.
[*]Enable the ADX filter to restrict signals to periods of measurable trend strength, reducing signals generated during flat or choppy conditions.
[*]Select an adaptive filter method to change the responsiveness of the underlying source feeding the Coppock calculation — faster methods like EMA or the Kalman Filter increase sensitivity, while methods like the Triple VWMA or SMA produce a smoother, slower curve.
[*]When a signal fires, use the automatically plotted Entry, SL, and TP1–TP3 lines as a starting reference for trade structure, and adjust position sizing according to the displayed stop distance and your own risk tolerances.
[*]Use candle heatmap coloring as a quick visual scan across the chart to spot where momentum has historically been strongest or weakest, independent of reading the oscillator pane directly.
[*]Configure the webhook alert action strings in the Alerts group to match the payload keys expected by your automation or webhook receiver before relying on the JSON-formatted alerts for execution.

⚙️ Inputs and Settings

• Core Settings

[*]Source — the price series the calculation is based on (default: close)
[*]Long ROC Length — lookback for the long-term rate-of-change component
[*]Short ROC Length — lookback for the short-term rate-of-change component
[*]WMA Smoothing Length — window for the final weighted moving average applied to the combined ROC values

• Filters

[*]Use ADX Filter / ADX Threshold / ADX Length — enables trend-strength gating and configures its sensitivity
[*]Adaptive Filter / Adaptive Filter Length — selects the pre-smoothing method applied to price before the ROC/WMA math, and its lookback window
[*]Use Divergence Filter / Divergence Pivot Lookback — configuration for suppressing signals against detected divergence
[*]Use Slope Acceleration Filter — configuration for requiring accelerating slope before a signal
[*]Use Volume Confirmation Filter / Volume MA Length — configuration for requiring above-average volume
[*]Use HTF Alignment Filter / HTF Alignment Timeframe — configuration for requiring higher-timeframe agreement
[*]Use Volatility-Adjusted Zero Line / Volatility Zero Band Multiple / Volatility Zero Band Length — configuration for a noise-adjusted zero-cross threshold
[*]Use Signal Persistence Filter / Persistence Bars — configuration for requiring a minimum number of bars of consistent direction

• Trade Tools

[*]Lock Signal — freezes the currently active signal and trade levels
[*]SL ATR Multiple — sets stop-loss distance as a multiple of ATR
[*]TP1 / TP2 / TP3 R-Multiple — sets each take-profit distance as a multiple of the initial risk
[*]ATR Length — lookback for the Average True Range calculation used in stop placement
[*]Show Trade Levels — toggles the on-chart lines, labels, and dashboard trade-level rows

• Visuals

[*]Use Candle Coloring — toggles heatmap-style recoloring of price candles
[*]Show Histogram — toggles the columned histogram beneath the main curve
[*]Show Zero-Cross Markers — toggles the triangle markers at zero-line crosses

• Dashboard

[*]Show Dashboard — toggles the on-chart summary table
[*]Position — sets the table's screen position

• Alerts

[*]Action strings for Bull Cross, Bear Cross, Zero Cross Up/Down, Close Long/Short, and TP1/TP2/TP3/SL Hit — these populate the "action" field of each JSON alert payload, allowing the alerts to be mapped directly to webhook or automation logic

• Colors

[*]Full palette control over bull/bear/neutral coloring, histogram tiers, dashboard styling, and all trade-level line and fill colors

🔍 Deconstruction of the Underlying Scientific and Academic Framework

● Rate of Change and the Coppock Curve
The foundation of this script is Edwin Coppock's original curve, published in Barron's in 1962, which sums a long-term and a short-term Rate of Change and smooths the result with a weighted moving average. Rate of Change itself is a first-order momentum measure — the percentage difference between the current value and its value N bars ago — rooted in the broader technical-analysis principle that the velocity of price change often leads price direction itself. Coppock's original design used a WMA specifically because it weights recent data more heavily than a simple average while remaining less reactive to single-bar noise than an exponential average.

● Weighted and Hull Moving Averages
The Weighted Moving Average used both in the final smoothing stage and optionally in the adaptive pre-filter assigns linearly decreasing weights to older data points, a technique long used to balance responsiveness against noise rejection. The Hull Moving Average, developed by Alan Hull, extends this idea by combining WMAs of different lengths in a way designed to reduce lag while preserving smoothness — a documented refinement of the general weighted-average family.

● Kalman Filtering
The Kalman Filter, originally developed by Rudolf Kálmán in the context of control and estimation theory, is a recursive algorithm for estimating an unknown value from a series of noisy observations. In this implementation, the filter maintains a running estimate and an error term, computes a Kalman gain from the ratio of predicted error to total error each bar, and updates the estimate by blending new price data in proportion to that gain. This gives the estimate more responsiveness when its own uncertainty is high and more smoothness when uncertainty is low — the same estimation principle underlying Kalman's original work, applied here to a single noisy input series rather than a multi-variable state system.

● Directional Movement and Trend Strength (Wilder)
The optional ADX filter is built on J. Welles Wilder's Directional Movement System, which derives +DI and -DI from directional price movement smoothed with Wilder's own moving average technique, then compresses their divergence into the Average Directional Index (ADX) as a bounded measure of trend strength independent of direction. Using ADX as a gating condition reflects the broader academic distinction between trend-following and mean-reverting market regimes — Wilder's system was explicitly designed to help separate the two.

● Average True Range and Volatility-Based Risk Sizing
Stop-loss and take-profit distances in this script are derived from Average True Range, also introduced by Wilder, which measures volatility by accounting for gaps as well as intraperiod range. Sizing risk as a multiple of ATR — rather than a fixed point or percentage value — is a widely documented approach in position-sizing literature because it scales stop distance to the instrument's actual recent volatility rather than an arbitrary constant.

● R-Multiples and Risk-Reward Structuring
The three-tiered take-profit structure expresses reward as a multiple of initial risk (an "R-multiple"), a framework popularized in trading risk-management literature to normalize outcomes across trades of different sizes and volatility regimes, allowing performance to be evaluated in terms of risk-adjusted return rather than raw price movement.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator(title = "Coppock Curve Multi-Filter [MarkitTick]", overlay = false)

// ── INPUTS ─────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Settings"
i_src        = input.source(close, "Source",          group = GRP_CORE)
i_rocLong    = input.int(14, "Long ROC Length",        group = GRP_CORE, minval = 1)
i_rocShort   = input.int(11, "Short ROC Length",       group = GRP_CORE, minval = 1)
i_wmaLen     = input.int(10, "WMA Smoothing Length",   group = GRP_CORE, minval = 1)

var string GRP_FILT = "🕯️ Filters"
i_useAdxFilter     = input.bool(false, "📈 Use ADX Filter", group = GRP_FILT)
i_adxThresh        = input.float(20.0, "ADX Threshold",     group = GRP_FILT, minval = 0, step = 0.5)
i_adxLen           = input.int(14,     "ADX Length",         group = GRP_FILT, minval = 1)
i_adaptFilterType  = input.string("None", "🧠 Adaptive Filter", options = ["None", "SMA", "EMA", "RMA", "Double WMA", "Triple VWMA", "HMA", "LLAMA", "Kalman Filter"], group = GRP_FILT)
i_adaptFilterLen   = input.int(20, "Adaptive Filter Length", group = GRP_FILT, minval = 1)
i_useDivFilter     = input.bool(false, "🔀 Use Divergence Filter", group = GRP_FILT, tooltip = "Suppress cross signals that oppose a detected price/Coppock divergence")
i_divLookback      = input.int(5,  "Divergence Pivot Lookback", group = GRP_FILT, minval = 2)
i_useAccelFilter   = input.bool(false, "⚡ Use Slope Acceleration Filter", group = GRP_FILT, tooltip = "Require the slope itself to be increasing, not just positive")
i_useVolFilter     = input.bool(false, "🔊 Use Volume Confirmation Filter", group = GRP_FILT, tooltip = "Require volume above its average for a signal to fire")
i_volLen           = input.int(20, "Volume MA Length", group = GRP_FILT, minval = 1)
i_useMtfFilter     = input.bool(false, "⏱️ Use HTF Alignment Filter", group = GRP_FILT, tooltip = "Require a higher timeframe Coppock to agree with the signal direction")
i_mtfTimeframe     = input.timeframe("240", "HTF Alignment Timeframe", group = GRP_FILT)
i_useVolatZeroFilter = input.bool(false, "🌊 Use Volatility-Adjusted Zero Line", group = GRP_FILT, tooltip = "Require zero-line crosses to exceed the indicator's own noise band")
i_volatZeroMult    = input.float(0.5, "Volatility Zero Band Multiple", group = GRP_FILT, minval = 0.1, step = 0.1)
i_volatZeroLen     = input.int(20, "Volatility Zero Band Length", group = GRP_FILT, minval = 1)
i_usePersistFilter = input.bool(false, "⏳ Use Signal Persistence Filter", group = GRP_FILT, tooltip = "Require direction to hold for N consecutive bars before signaling")
i_persistBars      = input.int(2, "Persistence Bars", group = GRP_FILT, minval = 1)

var string GRP_TRADE = "📐 Trade Tools"
i_lockSignal  = input.bool(false, "🔒 Lock Signal", group = GRP_TRADE, tooltip = "Freeze current signal · block new ones")
i_atrMult     = input.float(1.5, "SL ATR Multiple", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_tp1R        = input.float(1.0, "TP1 R-Multiple", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_tp2R        = input.float(2.0, "TP2 R-Multiple", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_tp3R        = input.float(3.0, "TP3 R-Multiple", group = GRP_TRADE, minval = 0.1, step = 0.1)
i_atrLen      = input.int(14, "ATR Length", group = GRP_TRADE, minval = 1)
i_showLevels  = input.bool(true, "Show Trade Levels", group = GRP_TRADE)

var string GRP_VIS = "🎨 Visuals"
i_showCandles = input.bool(true, "Use Candle Coloring", group = GRP_VIS)
i_showHist    = input.bool(true, "Show Histogram",   group = GRP_VIS)
i_showZeroX   = input.bool(true, "Show Zero-Cross Markers", group = GRP_VIS)

var string GRP_DASH = "📊 Dashboard"
i_showDash    = input.bool(true, "Show Dashboard",   group = GRP_DASH)
i_dashPos     = input.string(position.top_right, "Position", group = GRP_DASH, options = [position.top_right, position.top_left, position.bottom_right, position.bottom_left, position.middle_right, position.middle_left])

var string GRP_WH = "🔔 Alerts"
i_actionBull  = input.string("bull",     "↑ Bull Cross Action", group = GRP_WH)
i_actionBear  = input.string("bear",     "↓ Bear Cross Action", group = GRP_WH)
i_actionZeroUp   = input.string("zeroup",   "⤴ Zero Cross Up Action",   group = GRP_WH)
i_actionZeroDown = input.string("zerodown", "⤵ Zero Cross Down Action", group = GRP_WH)
i_actionCloseLong  = input.string("closelong",  "✕ Close Long Action",  group = GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH)
i_actionTp1   = input.string("tp1hit", "◆ TP1 Hit Action", group = GRP_WH)
i_actionTp2   = input.string("tp2hit", "◆ TP2 Hit Action", group = GRP_WH)
i_actionTp3   = input.string("tp3hit", "◆ TP3 Hit Action", group = GRP_WH)
i_actionSlHit = input.string("slhit",  "✕ SL Hit Action",  group = GRP_WH)

var string GRP_COL = "🌈 Colors"
c_bull        = input.color(#26a69a, "Bull Color",        group = GRP_COL)
c_bear        = input.color(#ef5350, "Bear Color",        group = GRP_COL)
c_neutral     = input.color(#787b86, "Neutral Color",     group = GRP_COL)
c_zeroLine    = input.color(#787b86, "Zero Line Color",   group = GRP_COL)
c_histBullStrong = input.color(#26a69a, "Histogram Bull Strong", group = GRP_COL)
c_histBullWeak   = input.color(#b2dfdb, "Histogram Bull Weak",   group = GRP_COL)
c_histBearWeak   = input.color(#ffcdd2, "Histogram Bear Weak",   group = GRP_COL)
c_histBearStrong = input.color(#ff5252, "Histogram Bear Strong", group = GRP_COL)
C_DASH_HDR    = input.color(color.new(#3a2a6d, 55), "Dashboard Header",  group = GRP_COL)
C_DASH_BG     = input.color(color.new(#0a0f1a, 10), "Dashboard Background", group = GRP_COL)
C_DASH_TXT    = input.color(#ffffff, "Dashboard Text",    group = GRP_COL)
C_SUP         = input.color(#26a69a, "Bullish Value Color", group = GRP_COL)
C_RES         = input.color(#ef5350, "Bearish Value Color", group = GRP_COL)
c_sl          = input.color(#ef5350, "SL Line Color", group = GRP_COL)
c_entry       = input.color(#2196f3, "Entry Line Color", group = GRP_COL)
c_tp1         = input.color(color.new(#26a69a, 40), "TP1 Line Color", group = GRP_COL)
c_tp2         = input.color(color.new(#26a69a, 20), "TP2 Line Color", group = GRP_COL)
c_tp3         = input.color(color.new(#26a69a, 0),  "TP3 Line Color", group = GRP_COL)
c_riskFill    = input.color(color.new(#ef5350, 80), "Risk Zone Fill", group = GRP_COL)
c_rewardFill  = input.color(color.new(#26a69a, 85), "Reward Zone Fill", group = GRP_COL)

// ── CORE LOGIC ─────────────────────────────────────────────────
f_sma(float src, int len) =>
    ta.sma(src, len)

f_ema(float src, int len) =>
    ta.ema(src, len)

f_rma(float src, int len) =>
    ta.rma(src, len)

f_doubleWma(float src, int len) =>
    float _wma1 = ta.wma(src, len)
    float _wma2 = ta.wma(_wma1, len)
    _wma2

f_tripleVwma(float src, int len) =>
    float _vwma1 = ta.vwma(src, len)
    float _vwma2 = ta.vwma(_vwma1, len)
    float _vwma3 = ta.vwma(_vwma2, len)
    _vwma3

f_hma(float src, int len) =>
    ta.hma(src, len)

f_kalman(float src, int len) =>
    var float _est = na
    var float _err = 1.0
    float _q = 1.0 / len
    float _r = 1.0
    _est := na(_est) ? src : _est
    float _predErr = _err + _q
    float _gain = _predErr / (_predErr + _r)
    _est := _est + _gain * (src - _est)
    _err := (1 - _gain) * _predErr
    _est

f_llama(float src, int len) =>
    float _mean = ta.sma(src, len)
    float _slope = (src - src[len]) / len
    _mean + _slope * (len / 2)

float _adaptedSrc = i_adaptFilterType == "SMA"         ? f_sma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "EMA"         ? f_ema(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "RMA"         ? f_rma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "Double WMA"  ? f_doubleWma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "Triple VWMA" ? f_tripleVwma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "HMA"         ? f_hma(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "LLAMA"       ? f_llama(i_src, i_adaptFilterLen) :
 i_adaptFilterType == "Kalman Filter" ? f_kalman(i_src, i_adaptFilterLen) : i_src

float _rocLongVal  = ta.roc(_adaptedSrc, i_rocLong)
float _rocShortVal = ta.roc(_adaptedSrc, i_rocShort)
float coppock      = ta.wma(_rocLongVal + _rocShortVal, i_wmaLen)

f_pivotHigh(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 0 to len * 2
        if i != len and src[i] >= candidate
            isValid := false
    isValid ? candidate : na
f_pivotLow(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 0 to len * 2
        if i != len and src[i] <= candidate
            isValid := false
    isValid ? candidate : na

[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal >= i_adxThresh

var float _pivLowPrice      = na
var float _pivLowCop        = na
var float _lastPivLowPrice  = na
var float _lastPivLowCop    = na
var bool  _bullDiv          = false
var float _pivHighPrice     = na
var float _pivHighCop       = na
var float _lastPivHighPrice = na
var float _lastPivHighCop   = na
var bool  _bearDiv          = false
float _candPivLow  = f_pivotLow(low, i_divLookback)
float _candPivHigh = f_pivotHigh(high, i_divLookback)
if not na(_candPivLow)
    _lastPivLowPrice := _pivLowPrice
    _lastPivLowCop   := _pivLowCop
    _pivLowPrice     := _candPivLow
    _pivLowCop       := coppock[i_divLookback]
    _bullDiv := not na(_lastPivLowPrice) and _pivLowPrice < _lastPivLowPrice and _pivLowCop > _lastPivLowCop
if not na(_candPivHigh)
    _lastPivHighPrice := _pivHighPrice
    _lastPivHighCop   := _pivHighCop
    _pivHighPrice     := _candPivHigh
    _pivHighCop       := coppock[i_divLookback]
    _bearDiv := not na(_lastPivHighPrice) and _pivHighPrice > _lastPivHighPrice and _pivHighCop < _lastPivHighCop
bool _divPassLong  = not i_useDivFilter or not _bearDiv
bool _divPassShort = not i_useDivFilter or not _bullDiv

float _slope0 = coppock - coppock[1]
float _slope1 = coppock[1] - coppock[2]
bool _accelPassLong  = not i_useAccelFilter or _slope0 > _slope1
bool _accelPassShort = not i_useAccelFilter or _slope0 < _slope1

float _volMa   = ta.sma(volume, i_volLen)
bool  _volPass = not i_useVolFilter or volume > _volMa

[_htfCoppock, _htfCoppockPrev] = request.security(syminfo.tickerid, i_mtfTimeframe, [coppock[1], coppock[2]], lookahead = barmerge.lookahead_on)
bool _htfBullish   = _htfCoppock > _htfCoppockPrev
bool _mtfPassLong  = not i_useMtfFilter or _htfBullish
bool _mtfPassShort = not i_useMtfFilter or not _htfBullish

float _copStdev     = ta.stdev(coppock, i_volatZeroLen)
float _noiseBand     = _copStdev * i_volatZeroMult
bool  _volatZeroPass = not i_useVolatZeroFilter or math.abs(coppock) > _noiseBand

var int _riseStreak = 0
var int _fallStreak = 0
bool _risingRaw  = coppock > coppock[1]
bool _fallingRaw = coppock < coppock[1]
if _risingRaw
    _riseStreak += 1
    _fallStreak := 0
else if _fallingRaw
    _fallStreak += 1
    _riseStreak := 0
else
    _riseStreak := 0
    _fallStreak := 0
bool _persistPassLong  = not i_usePersistFilter or _fallStreak[1] >= i_persistBars
bool _persistPassShort = not i_usePersistFilter or _riseStreak[1] >= i_persistBars

bool coppockRising  = _risingRaw  and _adxPass
bool coppockFalling = _fallingRaw and _adxPass

bool bullCross = ta.crossover(coppock, coppock[1])  and _adxPass and _divPassLong  and _accelPassLong  and _volPass and _mtfPassLong  and _persistPassLong
bool bearCross = ta.crossunder(coppock, coppock[1]) and _adxPass and _divPassShort and _accelPassShort and _volPass and _mtfPassShort and _persistPassShort
bool zeroCrossUp   = ta.crossover(coppock, 0)   and _adxPass and _volatZeroPass
bool zeroCrossDown = ta.crossunder(coppock, 0)  and _adxPass and _volatZeroPass

color coppockColor = coppockRising ? c_bull : coppockFalling ? c_bear : c_neutral
color hColor        = coppock >= 0 ? _risingRaw ? c_histBullStrong : c_histBullWeak : _risingRaw ? c_histBearWeak : c_histBearStrong
color bodyColor     = hColor
color borderColor   = bodyColor

float _atrVal = ta.atr(i_atrLen)
bool _locked = i_lockSignal and barstate.islast
bool newLongSignal  = bullCross and not _locked and barstate.isconfirmed
bool newShortSignal = bearCross and not _locked and barstate.isconfirmed
bool newSignal = newLongSignal or newShortSignal

var string _activeDir = na
var float entryPrice  = na
var float slPrice     = na
var float tp1Price    = na
var float tp2Price    = na
var float tp3Price    = na
var int   _sigBar     = na
var bool  _tradeOpen  = false
var bool  _slDone     = false
var bool  _tp1Done    = false
var bool  _tp2Done    = false
var bool  _tp3Done    = false

if newLongSignal
    _activeDir := "long"
    _sigBar    := bar_index
    _tradeOpen := true
    _slDone    := false
    _tp1Done   := false
    _tp2Done   := false
    _tp3Done   := false
    entryPrice := close
    slPrice    := entryPrice - _atrVal * i_atrMult
    float _riskLong = entryPrice - slPrice
    tp1Price   := entryPrice + _riskLong * i_tp1R
    tp2Price   := entryPrice + _riskLong * i_tp2R
    tp3Price   := entryPrice + _riskLong * i_tp3R
if newShortSignal
    _activeDir := "short"
    _sigBar    := bar_index
    _tradeOpen := true
    _slDone    := false
    _tp1Done   := false
    _tp2Done   := false
    _tp3Done   := false
    entryPrice := close
    slPrice    := entryPrice + _atrVal * i_atrMult
    float _riskShort = slPrice - entryPrice
    tp1Price   := entryPrice - _riskShort * i_tp1R
    tp2Price   := entryPrice - _riskShort * i_tp2R
    tp3Price   := entryPrice - _riskShort * i_tp3R

// Levels only become testable on bars after the signal bar: part of the
// signal bar's range occurred before the entry price existed.
bool _levelsLive = _tradeOpen and not na(_sigBar) and bar_index > _sigBar

bool _slHit = _levelsLive and not _slDone and
 ((_activeDir == "long"  and not na(slPrice) and low  <= slPrice) or
  (_activeDir == "short" and not na(slPrice) and high >= slPrice))
bool tp1Hit = _levelsLive and not _slDone and not _slHit and not _tp1Done and
 ((_activeDir == "long"  and not na(tp1Price) and high >= tp1Price) or
  (_activeDir == "short" and not na(tp1Price) and low  <= tp1Price))
bool tp2Hit = _levelsLive and not _slDone and not _slHit and not _tp2Done and
 ((_activeDir == "long"  and not na(tp2Price) and high >= tp2Price) or
  (_activeDir == "short" and not na(tp2Price) and low  <= tp2Price))
bool tp3Hit = _levelsLive and not _slDone and not _slHit and not _tp3Done and
 ((_activeDir == "long"  and not na(tp3Price) and high >= tp3Price) or
  (_activeDir == "short" and not na(tp3Price) and low  <= tp3Price))

if _slHit
    _slDone    := true
    _tradeOpen := false
if tp1Hit
    _tp1Done := true
if tp2Hit
    _tp2Done := true
if tp3Hit
    _tp3Done := true

f_pct(float _from, float _to, bool _isLong) =>
    _isLong ? (_to - _from) / _from * 100 : (_from - _to) / _from * 100

float slPct  = not na(entryPrice) and not na(slPrice)  ? f_pct(entryPrice, slPrice,  _activeDir == "long") : na
float tp1Pct = not na(entryPrice) and not na(tp1Price) ? f_pct(entryPrice, tp1Price, _activeDir == "long") : na
float tp2Pct = not na(entryPrice) and not na(tp2Price) ? f_pct(entryPrice, tp2Price, _activeDir == "long") : na
float tp3Pct = not na(entryPrice) and not na(tp3Price) ? f_pct(entryPrice, tp3Price, _activeDir == "long") : na

// ── ALERTS ─────────────────────────────────────────────────────
if newLongSignal and barstate.isconfirmed
    string _bullInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","value":"{3}","direction":"long","entry":"{4}","sl":"{5}","tp1":"{6}","tp2":"{7}","tp3":"{8}"',
     i_actionBull, syminfo.tickerid, timeframe.period, str.tostring(coppock, "#.####"),
     str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick),
     str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick))
    alert("{" + _bullInner + "}", alert.freq_once_per_bar_close)
if newShortSignal and barstate.isconfirmed
    string _bearInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","value":"{3}","direction":"short","entry":"{4}","sl":"{5}","tp1":"{6}","tp2":"{7}","tp3":"{8}"',
     i_actionBear, syminfo.tickerid, timeframe.period, str.tostring(coppock, "#.####"),
     str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick),
     str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick))
    alert("{" + _bearInner + "}", alert.freq_once_per_bar_close)
if newShortSignal and barstate.isconfirmed
    string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
    alert("{" + _closeLongInner + "}", alert.freq_once_per_bar_close)
if newLongSignal and barstate.isconfirmed
    string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
    alert("{" + _closeShortInner + "}", alert.freq_once_per_bar_close)
if zeroCrossUp and barstate.isconfirmed
    string _zeroUpInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","value":"{3}"',
     i_actionZeroUp, syminfo.tickerid, timeframe.period, str.tostring(coppock, "#.####"))
    alert("{" + _zeroUpInner + "}", alert.freq_once_per_bar_close)
if zeroCrossDown and barstate.isconfirmed
    string _zeroDownInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","value":"{3}"',
     i_actionZeroDown, syminfo.tickerid, timeframe.period, str.tostring(coppock, "#.####"))
    alert("{" + _zeroDownInner + "}", alert.freq_once_per_bar_close)
if tp1Hit
    string _tp1Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","level":"tp1","price":"{3}","pct":"{4}"',
     i_actionTp1, syminfo.tickerid, timeframe.period, str.tostring(tp1Price, format.mintick), str.tostring(tp1Pct, "#.##"))
    alert("{" + _tp1Inner + "}", alert.freq_once_per_bar)
if tp2Hit
    string _tp2Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","level":"tp2","price":"{3}","pct":"{4}"',
     i_actionTp2, syminfo.tickerid, timeframe.period, str.tostring(tp2Price, format.mintick), str.tostring(tp2Pct, "#.##"))
    alert("{" + _tp2Inner + "}", alert.freq_once_per_bar)
if tp3Hit
    string _tp3Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","level":"tp3","price":"{3}","pct":"{4}"',
     i_actionTp3, syminfo.tickerid, timeframe.period, str.tostring(tp3Price, format.mintick), str.tostring(tp3Pct, "#.##"))
    alert("{" + _tp3Inner + "}", alert.freq_once_per_bar)
if _slHit
    string _slHitInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}","pct":"{4}"',
     i_actionSlHit, syminfo.tickerid, timeframe.period, str.tostring(slPrice, format.mintick), str.tostring(slPct, "#.##"))
    alert("{" + _slHitInner + "}", alert.freq_once_per_bar)

alertcondition(newLongSignal  and barstate.isconfirmed, "Bull Cross",      "MarkitTick — Coppock Bull Cross")
alertcondition(newShortSignal and barstate.isconfirmed, "Bear Cross",      "MarkitTick — Coppock Bear Cross")
alertcondition(newShortSignal and barstate.isconfirmed, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(newLongSignal  and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
alertcondition(zeroCrossUp    and barstate.isconfirmed, "Zero Cross Up",   "MarkitTick — Coppock Zero Cross Up")
alertcondition(zeroCrossDown  and barstate.isconfirmed, "Zero Cross Down", "MarkitTick — Coppock Zero Cross Down")
alertcondition(tp1Hit, "TP1 Hit", "MarkitTick — TP1 Hit")
alertcondition(tp2Hit, "TP2 Hit", "MarkitTick — TP2 Hit")
alertcondition(tp3Hit, "TP3 Hit", "MarkitTick — TP3 Hit")
alertcondition(_slHit, "SL Hit", "MarkitTick — SL Hit")

// ── VISUALS ────────────────────────────────────────────────────
plot(coppock, "Coppock", color = coppockColor, linewidth = 2, display = display.all - display.pane)
plot(i_showHist ? coppock : na, "Histogram", color = hColor, style = plot.style_columns, histbase = 0)
hline(0, "Zero Line", color = c_zeroLine, linestyle = hline.style_dashed)
plotshape(i_showZeroX and zeroCrossUp   ? coppock : na, "Zero Up",   style = shape.triangleup,   location = location.absolute, color = c_bull, size = size.tiny)
plotshape(i_showZeroX and zeroCrossDown ? coppock : na, "Zero Down", style = shape.triangledown, location = location.absolute, color = c_bear, size = size.tiny)
plotcandle(open, high, low, close,
 title       = "Heatmap Candles",
 color       = i_showCandles ? bodyColor : na,
 wickcolor   = i_showCandles ? borderColor : na,
 bordercolor = i_showCandles ? borderColor : na,
 display     = i_showCandles ? display.all : display.none,
 force_overlay = true)

var line slLine    = na
var line entryLine = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na
var label slLbl    = na
var label entryLbl = na
var label tp1Lbl   = na
var label tp2Lbl   = na
var label tp3Lbl   = na
var linefill riskFill   = na
var linefill rewardFill = na

f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)

if newSignal and not _locked and i_showLevels
    f_deleteLevels()
    int _x1 = bar_index - 1
    int _x2 = bar_index + 10
    slLine    := line.new(_x1, slPrice,    _x2, slPrice,    color = c_sl,    style = line.style_solid,  width = 2, force_overlay = true)
    entryLine := line.new(_x1, entryPrice, _x2, entryPrice, color = c_entry, style = line.style_dashed, width = 1, force_overlay = true)
    tp1Line   := line.new(_x1, tp1Price,   _x2, tp1Price,   color = c_tp1,   style = line.style_dashed, width = 1, force_overlay = true)
    tp2Line   := line.new(_x1, tp2Price,   _x2, tp2Price,   color = c_tp2,   style = line.style_dashed, width = 1, force_overlay = true)
    tp3Line   := line.new(_x1, tp3Price,   _x2, tp3Price,   color = c_tp3,   style = line.style_dashed, width = 1, force_overlay = true)
    slLbl     := label.new(_x2, slPrice,    "✕ SL "    + str.tostring(slPrice,    format.mintick), style = label.style_label_left, color = c_sl,    textcolor = #ffffff, size = size.small, force_overlay = true)
    entryLbl  := label.new(_x2, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style = label.style_label_left, color = c_entry, textcolor = #ffffff, size = size.small, force_overlay = true)
    tp1Lbl    := label.new(_x2, tp1Price,   "◆ TP1 "   + str.tostring(tp1Price,   format.mintick), style = label.style_label_left, color = c_tp1,   textcolor = #ffffff, size = size.small, force_overlay = true)
    tp2Lbl    := label.new(_x2, tp2Price,   "✦ TP2 "   + str.tostring(tp2Price,   format.mintick), style = label.style_label_left, color = c_tp2,   textcolor = #ffffff, size = size.small, force_overlay = true)
    tp3Lbl    := label.new(_x2, tp3Price,   "◆ TP3 "   + str.tostring(tp3Price,   format.mintick), style = label.style_label_left, color = c_tp3,   textcolor = #ffffff, size = size.small, force_overlay = true)
    riskFill   := linefill.new(slLine, entryLine, c_riskFill)
    rewardFill := linefill.new(entryLine, tp3Line, c_rewardFill)

if not na(slLine) and barstate.islast
    int _extX = i_lockSignal ? bar_index + 10 : last_bar_index + 10
    line.set_x2(slLine,    _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line,   _extX)
    line.set_x2(tp2Line,   _extX)
    line.set_x2(tp3Line,   _extX)
    label.set_x(slLbl,     _extX)
    label.set_x(entryLbl,  _extX)
    label.set_x(tp1Lbl,    _extX)
    label.set_x(tp2Lbl,    _extX)
    label.set_x(tp3Lbl,    _extX)

if not na(slLbl)
    if tp1Hit
        label.set_text(tp1Lbl, "◆ TP1 ✓ HIT " + (tp1Pct >= 0 ? "+" : "") + str.tostring(tp1Pct, "#.##") + "%")
    if tp2Hit
        label.set_text(tp2Lbl, "✦ TP2 ✓ HIT " + (tp2Pct >= 0 ? "+" : "") + str.tostring(tp2Pct, "#.##") + "%")
    if tp3Hit
        label.set_text(tp3Lbl, "◆ TP3 ✓ HIT " + (tp3Pct >= 0 ? "+" : "") + str.tostring(tp3Pct, "#.##") + "%")
    if _slHit
        label.set_text(slLbl,  "✕ SL ✓ HIT "  + str.tostring(slPct, "#.##") + "%")

// ── DASHBOARD ──────────────────────────────────────────────────
var table dash = table.new(i_dashPos, 2, 14, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40), force_overlay = true)

if i_showDash and barstate.islast
    color row_a = C_DASH_BG
    color row_b = color.new(C_DASH_BG, 40)
    color lbl_col = color.new(C_DASH_TXT, 25)
    color valColor = coppockRising ? C_SUP : coppockFalling ? C_RES : C_DASH_TXT
    string biasTxt = coppockRising ? "BULLISH" : coppockFalling ? "BEARISH" : "NEUTRAL"

    table.cell(dash, 0, 0, "Coppock Curve", text_color = C_DASH_TXT, text_size = size.small, bgcolor = C_DASH_HDR, text_halign = text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color = C_DASH_TXT, text_size = size.small, bgcolor = C_DASH_HDR, text_halign = text.align_right)

    table.cell(dash, 0, 1, "  Lock", text_color = lbl_col, text_size = size.small, bgcolor = row_a, text_halign = text.align_left)
    table.cell(dash, 1, 1, (i_lockSignal ? "ACTIVE" : "OFF") + "  ", text_color = i_lockSignal ? C_RES : C_DASH_TXT, text_size = size.small, bgcolor = row_a, text_halign = text.align_right)

    table.cell(dash, 0, 2, "  Value", text_color = lbl_col, text_size = size.small, bgcolor = row_b, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(coppock, "#.####") + "  ", text_color = valColor, text_size = size.small, bgcolor = row_b, text_halign = text.align_right)

    table.cell(dash, 0, 3, "  Bias", text_color = lbl_col, text_size = size.small, bgcolor = row_a, text_halign = text.align_left)
    table.cell(dash, 1, 3, biasTxt + "  ", text_color = valColor, text_size = size.small, bgcolor = row_a, text_halign = text.align_right)

    table.cell(dash, 0, 4, "  Long ROC", text_color = lbl_col, text_size = size.small, bgcolor = row_b, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(_rocLongVal, "#.##") + "  ", text_color = C_DASH_TXT, text_size = size.small, bgcolor = row_b, text_halign = text.align_right)

    table.cell(dash, 0, 5, "  Short ROC", text_color = lbl_col, text_size = size.small, bgcolor = row_a, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(_rocShortVal, "#.##") + "  ", text_color = C_DASH_TXT, text_size = size.small, bgcolor = row_a, text_halign = text.align_right)

    table.cell(dash, 0, 6, "  Zero Cross", text_color = lbl_col, text_size = size.small, bgcolor = row_b, text_halign = text.align_left)
    table.cell(dash, 1, 6, (coppock >= 0 ? "ABOVE" : "BELOW") + "  ", text_color = coppock >= 0 ? C_SUP : C_RES, text_size = size.small, bgcolor = row_b, text_halign = text.align_right)

    int _row = 7
    if i_showLevels
        table.cell(dash, 0, _row, "  Entry", text_color = lbl_col, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_left)
        table.cell(dash, 1, _row, (not na(entryPrice) ? str.tostring(entryPrice, format.mintick) : "—") + "  ", text_color = C_DASH_TXT, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_right)
        _row += 1
        table.cell(dash, 0, _row, "  SL", text_color = lbl_col, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_left)
        table.cell(dash, 1, _row, (not na(slPrice) ? str.tostring(slPrice, format.mintick) : "—") + "  ", text_color = C_RES, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_right)
        _row += 1
        table.cell(dash, 0, _row, "  TP1", text_color = lbl_col, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_left)
        table.cell(dash, 1, _row, (not na(tp1Price) ? str.tostring(tp1Price, format.mintick) : "—") + "  ", text_color = C_SUP, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_right)
        _row += 1
        table.cell(dash, 0, _row, "  TP2", text_color = lbl_col, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_left)
        table.cell(dash, 1, _row, (not na(tp2Price) ? str.tostring(tp2Price, format.mintick) : "—") + "  ", text_color = C_SUP, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_right)
        _row += 1
        table.cell(dash, 0, _row, "  TP3", text_color = lbl_col, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_left)
        table.cell(dash, 1, _row, (not na(tp3Price) ? str.tostring(tp3Price, format.mintick) : "—") + "  ", text_color = C_SUP, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_right)
        _row += 1

    if i_useAdxFilter
        table.cell(dash, 0, _row, "  ADX", text_color = lbl_col, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_left)
        table.cell(dash, 1, _row, str.tostring(_adxVal, "#.##") + "  ", text_color = _adxPass ? C_SUP : C_RES, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_right)
        _row += 1

    if i_adaptFilterType != "None"
        table.cell(dash, 0, _row, "  Adapt Filter", text_color = lbl_col, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_left)
        table.cell(dash, 1, _row, i_adaptFilterType + "  ", text_color = C_DASH_TXT, text_size = size.small, bgcolor = _row % 2 == 1 ? row_a : row_b, text_halign = text.align_right)
````
