<!-- tradingview-pine-id: PUB;8307f1bdfa3041bf8aafc10279314e2b -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Stress Exhaustion [MarkitTick]

Source: https://www.tradingview.com/script/of3Nu1Lf-Liquidity-Stress-Exhaustion-MarkitTick/

## Description

💡 A market-microstructure stress detector that flags moments of seller or buyer exhaustion by combining an Amihud-style illiquidity z-score with trend regime, a regression-based fair-value channel, and automated ATR trade levels. Rather than reacting to price alone, this script measures how much price is moving relative to the volume behind it, then cross-references that stress reading against trend direction and candle behavior to identify points where aggressive selling or buying is likely running out of steam.

✨ Originality and Utility

Most exhaustion-based tools on TradingView rely on oscillator extremes (RSI, Stochastic) or candlestick pattern recognition in isolation. This script takes a different route: it borrows a concept from academic market-microstructure literature — price impact per unit of volume, i.e., illiquidity — and turns it into a real-time, standardized stress signal. Instead of asking "is price overextended?", it asks "is price moving too much for the volume that's actually trading?" A large true-range on abnormally low volume is treated as a sign of thin, stressed liquidity, and it is this stress, combined with a counter-trend candle, that defines exhaustion here — not price level alone.

This is not a simple mashup of unrelated indicators bolted together for the sake of a new publication. The illiquidity stress engine, the trend filter, the regression channel, and the correlation/ADX filters are all working toward a single, coherent question: is the current directional move statistically and structurally likely to reverse or stall? The z-scored stress reading identifies unusual conditions, the EMA trend filter and candle-close direction confirm which side is under pressure, and the optional Pearson-R and ADX filters exist specifically to suppress signals when the broader price action lacks the statistical structure (trending correlation, directional strength) needed to make the exhaustion reading meaningful. Each component narrows the false-positive rate of the others; removing any one of them would meaningfully change what the tool measures.

The script goes further than a plain signal generator by translating each exhaustion event into a fully computed trade plan — an ATR-derived stop, a dynamically computed R (risk unit), and three R-multiple take-profit targets — visualized directly on the chart and exposed through a structured alert payload designed for automation.

🔬 Methodology and Concepts
[image]https://www.tradingview.com/x/Cg1VUKHd/[/image]
• Illiquidity Stress Engine
The core of the script computes a proxy for market illiquidity on every bar: true range divided by volume (with a safe fallback when volume is zero or unavailable), then compressed with a natural-log transform to tame outliers. This raw illiquidity series is then standardized into a z-score using a rolling mean and standard deviation over the "Stats Lookback" period. A z-score above your chosen "Stress Threshold (σ)" marks the bar as being in a state of high stress — meaning price moved an unusually large amount for the volume that supported it, a hallmark of thin liquidity and potential exhaustion of the prevailing move.

• Trend Regime Filter
Direction is established by comparing price (optionally pre-smoothed by an adaptive filter, see below) against an EMA of configurable length. Price below the EMA defines a downtrend; price above defines an uptrend. Exhaustion signals are only valid when they occur against the backdrop of an established trend in the opposite direction — a seller exhaustion signal requires the prior bar to have closed in a downtrend on a red candle, while buyer exhaustion requires an uptrend and a green candle.

• Adaptive Price Filters (Optional)
Two optional smoothing methods can replace raw closing price throughout the trend calculation:

[*]Kalman Filter: a lightweight recursive estimator that continuously balances trust between the incoming price and its own prior estimate, adapting its responsiveness based on a fixed process/measurement noise ratio derived from your chosen length.
[*]LLAMA (Linear-Lag Adjusted Moving Average): a hybrid that takes a simple moving average and adjusts it by half the recent linear slope, aiming to reduce the lag inherent in plain moving averages.

These exist to give the trend filter a smoother, less noise-reactive input than raw closing price when desired.

• Regression Fair-Value Channel
On the most recent bar, the script performs a least-squares linear regression over a lookback window (either a fixed length, or a dynamic length measured from the most recent qualifying pivot, capped by "Max Lookback Cap") using hlc3 as the source. From this it derives the regression line itself, its standard deviation, and the Pearson correlation coefficient (R), which measures how well price actually fits a straight line over that window. Inner and outer channel bands are plotted at user-defined standard-deviation multiples above and below the regression line, giving a visual statistical envelope for the recent price trend.

• Correlation and ADX Filters
Two independent filters can suppress exhaustion signals when the broader trend lacks structural conviction:

[*]Pearson R Filter: when the absolute value of the regression's correlation coefficient falls below your threshold, the trend is considered statistically weak/directionless, and the channel is recolored neutral to flag this — though note this filter affects only the visual channel coloring, not signal firing.
[*]ADX Filter: when enabled, exhaustion signals are only permitted when ADX is at or above your threshold, filtering out exhaustion calls during periods of weak directional movement.

• Pivot Detection
Standard confirmed pivot highs and lows (requiring the specified number of bars on each side) are tracked internally to support the optional Dynamic Pivot Mode, which — when enabled — sizes the regression lookback to the distance since the most recent confirmed pivot rather than using a fixed length.

• ATR Trade Level Construction
When a qualifying exhaustion signal fires and is confirmed, the script computes a full trade plan: the entry is the closing price of the confirmed exhaustion bar, the stop-loss is placed one ATR-multiple away (your "ATR SL Multiplier" times ATR over "ATR Length"), and the resulting stop distance defines one Risk unit ("R"). Three take-profit levels are then placed at your chosen R-multiples (default 1R, 2R, 3R) from entry. This entire trade plan updates and redraws only when a new, unlocked exhaustion signal fires.

• Lock Signal
Enabling "Lock Signal" freezes the currently displayed trade plan on the chart, preventing new exhaustion events from overwriting the active levels — useful for manually tracking a single trade through to its conclusion without the visual being replaced mid-trade.

🎨 Visual Guide
[image]https://www.tradingview.com/x/X7HKMIkv/[/image]
● Exhaustion Labels

[*]"SE" label below a bar (bullish color by default) marks a confirmed Seller Exhaustion event — sellers pushed price down under stress conditions, and the setup favors a potential upside reaction.
[*]"BE" label above a bar (bearish color by default) marks a confirmed Buyer Exhaustion event — buyers pushed price up under stress conditions, and the setup favors a potential downside reaction.

● Regression Channel

[*]The dashed center line is the linear regression fair-value line over the active lookback window.
[*]The two dotted inner lines mark the "Inner Deviation" band (default 1.0σ).
[*]The two solid outer lines mark the "Outer Deviation" band (default 2.0σ).
[*]The shaded fill between the inner bands is colored by trend direction — bullish or bearish color when the trend is statistically valid, neutral gray when the Pearson R Filter flags the trend as too weak/uncorrelated to trust.
[*]An optional floating "STATS" label above the current bar displays the regression length, Pearson R value, and current stress z-score (σ) numerically, when "Show Metrics Label" is enabled.

● Trade Level Lines
Plotted only after a qualifying exhaustion event, extending toward the current bar:

[*]Red solid line and "✕ SL" label: the calculated stop-loss.
[*]Blue dashed line and "▶ Entry" label: the entry price (signal bar's close).
[*]Three teal dashed lines of increasing opacity/solidity, with "◆ TP1", "✦ TP2", "◆ TP3" labels: the three R-multiple take-profit targets.
[*]A red-tinted fill between the stop and entry lines visualizes the risk zone.
[*]A teal-tinted fill between the entry and TP3 lines visualizes the reward zone.

● Dashboard (Table)
A compact panel, positioned per your "Dashboard Position" setting, reporting in real time: Lock status, current Trend Regime (Bullish/Bearish), Seller Status and Buyer Status (Exhausted/Normal), a visual Channel Width bar-meter (color-graded green/amber/red by relative width), a visual Pearson R bar-meter (same color grading by correlation strength), and — when an exhaustion signal is currently active — the live Entry, Stop Loss, and TP1 price levels. ADX value and Adaptive Filter type are appended as additional rows only when those features are enabled in the inputs.

📖 How to Use
[image]https://www.tradingview.com/x/hgHYmuh8/[/image]

[*]Watch for an "SE" (Seller Exhaustion) label — this suggests a downtrend that produced an unusually large price move for its volume, on a down candle, potentially signaling sellers are running out of conviction and a bounce could follow.
[*]Watch for a "BE" (Buyer Exhaustion) label — the mirror case in an uptrend, potentially signaling an approaching pullback or reversal.
[*]Use the dashboard's Pearson R and Channel Width meters as a quick sanity check on trend quality before acting on a signal — a low R reading (channel shown in neutral gray) suggests the recent price action lacks a clean directional structure.
[*]If ADX filtering is enabled, only signals occurring during sufficiently strong directional movement (per your threshold) will fire, which can help avoid exhaustion calls inside choppy, low-ADX conditions.
[*]Once a signal fires, the plotted SL/Entry/TP1-3 lines and the dashboard's live level readout offer a pre-built framework for position sizing and target-setting — always cross-check these levels against your own risk tolerance before acting on them.
[*]Enable "Lock Signal" if you want to study a single active trade plan without it being replaced by a new signal appearing on a later bar.
[*]All signals, dashboard values, and trade levels are calculated strictly on confirmed, closed bar data — nothing on this chart is repainted or recalculated retroactively into the past.

⚙️ Inputs and Settings
[image]https://www.tradingview.com/x/O4o93HY6/[/image]
● Core Settings

[*]Trend Length: EMA period used for the directional trend filter. Longer values smooth out the trend classification; shorter values make it more reactive.
[*]Stats Lookback: rolling window for the illiquidity mean/standard deviation used to compute the stress z-score.
[*]Stress Threshold (σ): the z-score level that must be exceeded for a bar to be classified as "high stress." Raising this makes exhaustion signals rarer but more extreme.
[*]Dynamic Pivot Mode: when enabled, the regression channel's lookback length is derived from the distance to the most recent confirmed pivot instead of a fixed value.
[*]Fixed Length: the regression lookback used when Dynamic Pivot Mode is off.
[*]Pivot Left / Pivot Right: bars required on each side to confirm a swing high/low for Dynamic Pivot Mode.
[*]Max Lookback Cap: hard ceiling on the regression window length, regardless of pivot distance, to control computation and keep the channel visually relevant.
[*]Inner/Outer Deviation: standard-deviation multiples defining the two channel bands around the regression line.

● Filters

[*]Filter Weak Correlations / Pearson R Threshold: controls the channel's neutral-color flagging when regression fit quality is below this threshold.
[*]Use ADX Filter / ADX Threshold / ADX Length: optional directional-strength gate that must be satisfied for exhaustion signals to fire.
[*]Adaptive Filter (None / Kalman Filter / LLAMA) and its Length: optional pre-smoothing applied to price before the trend/EMA calculation.

● Trade Tools

[*]Lock Signal: freezes the current trade plan against being overwritten by new signals.
[*]ATR SL Multiplier / ATR Length: controls stop-loss distance as a multiple of ATR.
[*]TP1/TP2/TP3 (R Multiple): sets each take-profit target as a multiple of the initial risk (R).

● Visuals

[*]Show Metrics Label: toggles the floating STATS label showing regression length, R, and z-score.
[*]High/Low Volatility Width %: reference thresholds used to color-grade the dashboard's Channel Width meter.
[*]Line Extension: controls whether regression channel lines extend left, right, both, or not at all.

● Dashboard

[*]Dashboard Position: places the summary table in any of the four chart corners.

● Alerts

[*]Six customizable action-tag fields (Seller/Buyer Exhaustion, TP1/TP2/TP3 Hit, SL Hit) let you rename the "action" field inside each alert's JSON payload to match your own automation or webhook naming scheme.

● Colors

[*]Full palette control over bullish/bearish/neutral coloring, text and background colors, dashboard styling, and all trade-level line/fill colors.

🔍 Deconstruction of the Underlying Scientific and Academic Framework

● Illiquidity as a Price-Impact Proxy
The stress engine's core calculation — true range divided by volume — is a simplified, bar-by-bar adaptation of the price-impact style illiquidity measures used in market microstructure research, most notably the Amihud illiquidity ratio, which relates absolute returns to trading volume as a proxy for how much a given amount of volume "costs" in terms of price movement. The underlying academic intuition is that in illiquid or stressed conditions, smaller volumes produce disproportionately larger price swings; the log transform compresses the resulting distribution to reduce the influence of extreme outlier bars before standardization.

● Z-Score Standardization and Statistical Anomaly Detection
Converting the raw illiquidity reading into a z-score against its own rolling mean and standard deviation is a direct application of statistical process control / anomaly-detection theory: rather than using a fixed, market-agnostic threshold, the script defines "abnormal" relative to each instrument's and timeframe's own recent behavior. This adaptive standardization is a common approach in quantitative finance for regime and outlier detection, since raw price-impact values are not comparable across instruments, timeframes, or volatility regimes without normalization.

● Ordinary Least Squares Regression and Goodness-of-Fit
The fair-value channel is constructed using closed-form ordinary least-squares (OLS) regression formulas computed directly from the summary statistics of the price series (sums of x, y, x², xy, y²) rather than an iterative solver — a standard, numerically efficient approach for simple linear regression. The accompanying Pearson correlation coefficient is the classical goodness-of-fit statistic for this regression: it quantifies how well a straight line explains the price action over the lookback window, providing a principled, quantitative basis (rather than visual judgment) for deciding whether "trend" is a statistically meaningful description of recent price behavior.

● Recursive State Estimation (Kalman Filtering)
The optional Kalman Filter smoothing option is a simplified, single-dimension implementation of the classical Kalman filter from control theory and signal processing — a recursive Bayesian estimator that maintains a running estimate of a system's true state (here, price) and continuously updates it by weighting new observations against the model's own uncertainty. This provides a theoretically grounded alternative to fixed-window moving averages for noise reduction.

● Trend-Following Directional Strength (ADX/DMI)
The optional ADX filter draws on Welles Wilder's Directional Movement System, a long-established technical framework for separating trend strength from trend direction. Using it as a gate rather than a signal generator reflects its intended academic role: ADX does not indicate direction, only the strength of whatever directional move is present, making it a natural confluence filter for suppressing signals during structurally weak, low-conviction price action.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Liquidity Stress Exhaustion [MarkitTick]", overlay = true, max_lines_count = 100, max_labels_count = 500, max_bars_back = 5000)

// ── INPUTS ─────────────────────────────────────────────────

var string GRP_CORE = "⚙️ Core Settings"
int   IN_LEN_TREND    = input.int(50, "Trend Length", minval=10, group=GRP_CORE)
int   IN_LEN_STATS    = input.int(20, "Stats Lookback", minval=5, group=GRP_CORE)
float IN_THRESH_SIGMA = input.float(2.0, "Stress Threshold (σ)", step=0.1, group=GRP_CORE)
bool  IN_USE_DYN_LEN  = input.bool(false, "Dynamic Pivot Mode", group=GRP_CORE, tooltip="Adjusts regression length based on recent pivots.")
int   IN_FIX_LEN      = input.int(50, "Fixed Length", minval=5, group=GRP_CORE)
int   IN_PIV_LEFT     = input.int(20, "Pivot Left", minval=2, group=GRP_CORE)
int   IN_PIV_RIGHT    = input.int(20, "Pivot Right", minval=1, group=GRP_CORE)
int   IN_MAX_LOOKBACK = input.int(300, "Max Lookback Cap", minval=50, group=GRP_CORE)
float IN_DEV_IN       = input.float(1.0, "Inner Deviation", step=0.1, group=GRP_CORE)
float IN_DEV_OUT      = input.float(2.0, "Outer Deviation", step=0.1, group=GRP_CORE)

var string GRP_FILT = "🕯️ Filters"
bool  IN_USE_R_FILT   = input.bool(true, "Filter Weak Correlations", group=GRP_FILT)
float IN_R_THRESH     = input.float(0.5, "Pearson R Threshold", step=0.05, group=GRP_FILT)
bool  i_useAdxFilter  = input.bool(false, "📈 Use ADX Filter", group=GRP_FILT)
float i_adxThresh     = input.float(20.0, "ADX Threshold", group=GRP_FILT, minval=0, step=0.5)
int   i_adxLen        = input.int(14, "ADX Length", group=GRP_FILT, minval=1)
string i_adaptFilterType = input.string("None", "🧠 Adaptive Filter", options=["None", "Kalman Filter", "LLAMA"], group=GRP_FILT)
int   i_adaptFilterLen   = input.int(20, "Adaptive Filter Length", group=GRP_FILT, minval=1)

var string GRP_TRADE = "📐 Trade Tools"
bool  i_lockSignal    = input.bool(false, "🔒 Lock Signal", group=GRP_TRADE, tooltip="Freeze current signal · block new ones")
float i_atrMult       = input.float(1.5, "ATR SL Multiplier", minval=0.1, step=0.1, group=GRP_TRADE)
int   i_atrLen        = input.int(14, "ATR Length", minval=1, group=GRP_TRADE)
float i_tp1R          = input.float(1.0, "TP1 (R Multiple)", minval=0.1, step=0.1, group=GRP_TRADE)
float i_tp2R          = input.float(2.0, "TP2 (R Multiple)", minval=0.1, step=0.1, group=GRP_TRADE)
float i_tp3R          = input.float(3.0, "TP3 (R Multiple)", minval=0.1, step=0.1, group=GRP_TRADE)

var string GRP_VIS = "🎨 Visuals"
bool  IN_SHOW_METRICS = input.bool(true, "Show Metrics Label", group=GRP_VIS)
float IN_WIDTH_HIGH   = input.float(3.0, "High Volatility Width %", minval=0.1, step=0.1, group=GRP_VIS)
float IN_WIDTH_LOW    = input.float(1.0, "Low Volatility Width %", minval=0.1, step=0.1, group=GRP_VIS)
string IN_EXT_MODE    = input.string("None", "Line Extension", options=["None", "Left", "Right", "Both"], group=GRP_VIS)

var string GRP_DASH = "📊 Dashboard"
string i_dashPos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_DASH)

var string GRP_WH = "🔔 Alerts"
string i_actionSellerExh = input.string("seller_exhaustion", "Seller Exhaustion Action", group=GRP_WH)
string i_actionBuyerExh  = input.string("buyer_exhaustion",  "Buyer Exhaustion Action",  group=GRP_WH)
string i_actionTp1       = input.string("tp1_hit", "TP1 Hit Action", group=GRP_WH)
string i_actionTp2       = input.string("tp2_hit", "TP2 Hit Action", group=GRP_WH)
string i_actionTp3       = input.string("tp3_hit", "TP3 Hit Action", group=GRP_WH)
string i_actionSlHit     = input.string("sl_hit",  "SL Hit Action",  group=GRP_WH)

var string GRP_STYLE = "🌈 Colors"
color IN_C_BULL   = input.color(#00e5ff, "Bullish / Seller Exhaustion", group=GRP_STYLE)
color IN_C_BEAR   = input.color(#ff2ee6, "Bearish / Buyer Exhaustion", group=GRP_STYLE)
color IN_C_NEUT   = input.color(#7a7fa3, "Neutral / Weak Correlation", group=GRP_STYLE)
color IN_C_TXT    = input.color(#FFFFFF, "Text Color", group=GRP_STYLE)
color IN_C_BG     = input.color(#131722, "Label Background", group=GRP_STYLE)
color C_DASH_HDR  = input.color(color.new(#3a2a6d, 55), "Dashboard Header", group=GRP_STYLE)
color C_DASH_BG   = input.color(color.new(#0a0f1a, 10), "Dashboard Background", group=GRP_STYLE)
color C_DASH_TXT  = input.color(#ffffff, "Dashboard Text", group=GRP_STYLE)
color C_SL        = input.color(#ef5350, "SL Line", group=GRP_STYLE)
color C_ENTRY     = input.color(#2196f3, "Entry Line", group=GRP_STYLE)
color C_TP1       = input.color(color.new(#26a69a, 40), "TP1 Line", group=GRP_STYLE)
color C_TP2       = input.color(color.new(#26a69a, 20), "TP2 Line", group=GRP_STYLE)
color C_TP3       = input.color(color.new(#26a69a, 0), "TP3 Line", group=GRP_STYLE)
color C_RISK_FILL = input.color(color.new(#ef5350, 80), "Risk Zone Fill", group=GRP_STYLE)
color C_REWARD_FILL = input.color(color.new(#26a69a, 85), "Reward Zone Fill", group=GRP_STYLE)

// ── UDTs ───────────────────────────────────────────────────

type StressEngine
    float raw_illiquidity
    float z_score
    bool  is_high_stress

type RegMetrics
    float startPrice
    float endPrice
    float stdDev
    float pearsonR
    bool  isValid
    int   length

type ChannelDrawings
    line     mid
    line     topOut
    line     botOut
    line     topIn
    line     botIn
    linefill fill
    label    stats

type TradeLevels
    line     slLine
    line     entryLine
    line     tp1Line
    line     tp2Line
    line     tp3Line
    label    slLbl
    label    entryLbl
    label    tp1Lbl
    label    tp2Lbl
    label    tp3Lbl
    linefill riskFill
    linefill rewardFill

// ── CORE LOGIC ────────────────────────────────────────────

method update(StressEngine self, int len, float threshold) =>
    float vol_safe = (na(volume) or volume == 0) ? 1.0 : volume
    float impact = ta.tr(true) / vol_safe
    self.raw_illiquidity := math.log(impact + 1)
    float mean = ta.sma(self.raw_illiquidity, len)
    float std  = ta.stdev(self.raw_illiquidity, len)
    self.z_score := (std == 0 or na(std)) ? 0.0 : (self.raw_illiquidity - mean) / std
    self.is_high_stress := (self.z_score > threshold)

get_ext_mode(string s) =>
    switch s
        "Left"  => extend.left
        "Right" => extend.right
        "Both"  => extend.both
        => extend.none

f_pivotHigh(float src, int leftLen, int rightLen) =>
    float pivVal = src[rightLen]
    bool isPivot = true
    if bar_index >= leftLen + rightLen
        for i = 0 to leftLen + rightLen
            if i != leftLen and src[i] > pivVal
                isPivot := false
                break
    else
        isPivot := false
    isPivot ? pivVal : na

f_pivotLow(float src, int leftLen, int rightLen) =>
    float pivVal = src[rightLen]
    bool isPivot = true
    if bar_index >= leftLen + rightLen
        for i = 0 to leftLen + rightLen
            if i != leftLen and src[i] < pivVal
                isPivot := false
                break
    else
        isPivot := false
    isPivot ? pivVal : na

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

calc_regression_metrics(int length) =>
    if length < 2
        RegMetrics.new(na, na, na, na, false, length)
    else
        int actual_len = 0
        for i = 0 to length - 1
            if not na(hlc3[i])
                actual_len := i + 1
            else
                break
        if actual_len < 2
            RegMetrics.new(na, na, na, na, false, 0)
        else
            float n       = float(actual_len)
            float n_minus = n - 1.0
            float sum_x   = (n * n_minus) / 2.0
            float sum_x2  = (n * n_minus * (2.0 * n - 1.0)) / 6.0
            float sum_y   = 0.0
            float sum_xy  = 0.0
            float sum_y2  = 0.0
            for i = 0 to actual_len - 1
                float val   = hlc3[i]
                float x_val = n_minus - float(i)
                if not na(val)
                    sum_y  += val
                    sum_xy += x_val * val
                    sum_y2 += val * val
            float denom = n * sum_x2 - sum_x * sum_x
            float slope = denom != 0 ? (n * sum_xy - sum_x * sum_y) / denom : 0.0
            float inter = (sum_y - slope * sum_x) / n
            float var_val = (sum_y2 - (sum_y * sum_y) / n) / n
            float std_dev = math.sqrt(math.max(0.0, var_val))
            float r_num   = n * sum_xy - sum_x * sum_y
            float r_den_y = n * sum_y2 - sum_y * sum_y
            float r_den   = math.sqrt(math.max(0.0, denom * r_den_y))
            float r_coef  = r_den != 0 ? r_num / r_den : 0.0
            float y_start = inter
            float y_end   = inter + slope * n_minus
            RegMetrics.new(y_start, y_end, std_dev, r_coef, true, actual_len)

var StressEngine stress_eng = StressEngine.new(0.0, 0.0, false)
stress_eng.update(IN_LEN_STATS, IN_THRESH_SIGMA)

float _adaptedClose = i_adaptFilterType == "Kalman Filter" ? f_kalman(close, i_adaptFilterLen) : i_adaptFilterType == "LLAMA" ? f_llama(close, i_adaptFilterLen) : close

float trend_ema = ta.ema(_adaptedClose, IN_LEN_TREND)
bool is_downtrend = _adaptedClose < trend_ema
bool is_uptrend   = _adaptedClose > trend_ema

[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal >= i_adxThresh

StressEngine stressPrev = na(stress_eng[1]) ? StressEngine.new(0.0, 0.0, false) : stress_eng[1]
bool _rawSellerExhaustion = stressPrev.is_high_stress and is_downtrend[1] and (close[1] < open[1])
bool _rawBuyerExhaustion  = stressPrev.is_high_stress and is_uptrend[1] and (close[1] > open[1])

bool seller_exhaustion = _rawSellerExhaustion and _adxPass[1]
bool buyer_exhaustion  = _rawBuyerExhaustion  and _adxPass[1]

float _atr = ta.atr(i_atrLen)

var float slPriceLong    = na
var float entryPriceLong = na
var float tp1PriceLong   = na
var float tp2PriceLong   = na
var float tp3PriceLong   = na
var float slPriceShort    = na
var float entryPriceShort = na
var float tp1PriceShort   = na
var float tp2PriceShort   = na
var float tp3PriceShort   = na

bool _locked = i_lockSignal and barstate.islast
bool _commit = barstate.isconfirmed

if seller_exhaustion and not _locked and _commit
    entryPriceLong := close
    slPriceLong    := entryPriceLong - _atr * i_atrMult
    float _rLong   = entryPriceLong - slPriceLong
    tp1PriceLong   := entryPriceLong + _rLong * i_tp1R
    tp2PriceLong   := entryPriceLong + _rLong * i_tp2R
    tp3PriceLong   := entryPriceLong + _rLong * i_tp3R

if buyer_exhaustion and not _locked and _commit
    entryPriceShort := close
    slPriceShort    := entryPriceShort + _atr * i_atrMult
    float _rShort   = slPriceShort - entryPriceShort
    tp1PriceShort   := entryPriceShort - _rShort * i_tp1R
    tp2PriceShort   := entryPriceShort - _rShort * i_tp2R
    tp3PriceShort   := entryPriceShort - _rShort * i_tp3R

bool _slHitLong    = not na(slPriceLong)  and low  <= slPriceLong
bool _slHitShort   = not na(slPriceShort) and high >= slPriceShort
bool tp1HitLong    = not na(tp1PriceLong)  and high >= tp1PriceLong
bool tp2HitLong    = not na(tp2PriceLong)  and high >= tp2PriceLong
bool tp3HitLong    = not na(tp3PriceLong)  and high >= tp3PriceLong
bool tp1HitShort   = not na(tp1PriceShort) and low  <= tp1PriceShort
bool tp2HitShort   = not na(tp2PriceShort) and low  <= tp2PriceShort
bool tp3HitShort   = not na(tp3PriceShort) and low  <= tp3PriceShort

var string activeDir = na
var float  activeSl   = na
var float  activeEn   = na
var float  activeTp1  = na

if seller_exhaustion and not _locked and _commit
    activeDir := "long"
    activeSl  := slPriceLong
    activeEn  := entryPriceLong
    activeTp1 := tp1PriceLong
if buyer_exhaustion and not _locked and _commit
    activeDir := "short"
    activeSl  := slPriceShort
    activeEn  := entryPriceShort
    activeTp1 := tp1PriceShort

bool _positionClosed = (activeDir == "long"  and (_slHitLong  or tp3HitLong))  or  (activeDir == "short" and (_slHitShort or tp3HitShort))
if _positionClosed
    activeDir := na
    activeSl  := na
    activeEn  := na
    activeTp1 := na

var int piv_idx = na
float ph = f_pivotHigh(high, IN_PIV_LEFT, IN_PIV_RIGHT)
float pl = f_pivotLow(low, IN_PIV_LEFT, IN_PIV_RIGHT)

if not na(ph) or not na(pl)
    piv_idx := bar_index[IN_PIV_RIGHT]

if seller_exhaustion and _commit
    label.new(bar_index, low, text="SE", style=label.style_label_up, color=IN_C_BULL, textcolor=IN_C_TXT, size=size.normal, yloc=yloc.belowbar)
if buyer_exhaustion and _commit
    label.new(bar_index, high, text="BE", style=label.style_label_down, color=IN_C_BEAR, textcolor=IN_C_TXT, size=size.normal, yloc=yloc.abovebar)

// ── ALERTS ────────────────────────────────────────────

string _sellerInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","zscore":"{8}"',
 i_actionSellerExh, syminfo.tickerid, timeframe.period,
 str.tostring(entryPriceLong, format.mintick),
 str.tostring(slPriceLong,    format.mintick),
 str.tostring(tp1PriceLong,   format.mintick),
 str.tostring(tp2PriceLong,   format.mintick),
 str.tostring(tp3PriceLong,   format.mintick),
 str.tostring(stress_eng.z_score, "#.##"))
string sellerPayload = "{" + _sellerInner + "}"

string _buyerInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","zscore":"{8}"',
 i_actionBuyerExh, syminfo.tickerid, timeframe.period,
 str.tostring(entryPriceShort, format.mintick),
 str.tostring(slPriceShort,    format.mintick),
 str.tostring(tp1PriceShort,   format.mintick),
 str.tostring(tp2PriceShort,   format.mintick),
 str.tostring(tp3PriceShort,   format.mintick),
 str.tostring(stress_eng.z_score, "#.##"))
string buyerPayload = "{" + _buyerInner + "}"

string _slInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}"',
 i_actionSlHit, syminfo.tickerid, timeframe.period)
string slPayload = "{" + _slInner + "}"

string _tp1Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}"', i_actionTp1, syminfo.tickerid, timeframe.period)
string tp1Payload = "{" + _tp1Inner + "}"
string _tp2Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}"', i_actionTp2, syminfo.tickerid, timeframe.period)
string tp2Payload = "{" + _tp2Inner + "}"
string _tp3Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}"', i_actionTp3, syminfo.tickerid, timeframe.period)
string tp3Payload = "{" + _tp3Inner + "}"

if seller_exhaustion and barstate.isconfirmed
    alert(sellerPayload, alert.freq_once_per_bar_close)
if buyer_exhaustion and barstate.isconfirmed
    alert(buyerPayload, alert.freq_once_per_bar_close)
if (_slHitLong or _slHitShort) and barstate.isconfirmed
    alert(slPayload, alert.freq_once_per_bar)
if (tp1HitLong or tp1HitShort) and barstate.isconfirmed
    alert(tp1Payload, alert.freq_once_per_bar)
if (tp2HitLong or tp2HitShort) and barstate.isconfirmed
    alert(tp2Payload, alert.freq_once_per_bar)
if (tp3HitLong or tp3HitShort) and barstate.isconfirmed
    alert(tp3Payload, alert.freq_once_per_bar)

alertcondition(seller_exhaustion, "Seller Exhaustion", "MarkitTick — Seller Exhaustion Fired")
alertcondition(buyer_exhaustion,  "Buyer Exhaustion",  "MarkitTick — Buyer Exhaustion Fired")
alertcondition(_slHitLong or _slHitShort, "SL Hit", "MarkitTick — Stop Loss Hit")
alertcondition(tp1HitLong or tp1HitShort, "TP1 Hit", "MarkitTick — TP1 Hit")
alertcondition(tp2HitLong or tp2HitShort, "TP2 Hit", "MarkitTick — TP2 Hit")
alertcondition(tp3HitLong or tp3HitShort, "TP3 Hit", "MarkitTick — TP3 Hit")

// ── VISUALS ───────────────────────────────────────────

var ChannelDrawings draw = ChannelDrawings.new()
var TradeLevels lvl = TradeLevels.new()

f_deleteLevels() =>
    line.delete(lvl.slLine),    line.delete(lvl.entryLine)
    line.delete(lvl.tp1Line),   line.delete(lvl.tp2Line),   line.delete(lvl.tp3Line)
    label.delete(lvl.slLbl),    label.delete(lvl.entryLbl)
    label.delete(lvl.tp1Lbl),   label.delete(lvl.tp2Lbl),   label.delete(lvl.tp3Lbl)
    linefill.delete(lvl.riskFill), linefill.delete(lvl.rewardFill)

if (seller_exhaustion or buyer_exhaustion) and not _locked and _commit
    f_deleteLevels()
    bool _isLong = seller_exhaustion
    float _slP  = _isLong ? slPriceLong  : slPriceShort
    float _enP  = _isLong ? entryPriceLong : entryPriceShort
    float _tp1P = _isLong ? tp1PriceLong : tp1PriceShort
    float _tp2P = _isLong ? tp2PriceLong : tp2PriceShort
    float _tp3P = _isLong ? tp3PriceLong : tp3PriceShort
    color _slC    = C_SL
    color _enC    = C_ENTRY
    color _tp1C   = C_TP1
    color _tp2C   = C_TP2
    color _tp3C   = C_TP3

    lvl.slLine    := line.new(bar_index, _slP,  bar_index, _slP,  color=_slC,  width=2)
    lvl.entryLine := line.new(bar_index, _enP,  bar_index, _enP,  color=_enC,  width=1, style=line.style_dashed)
    lvl.tp1Line   := line.new(bar_index, _tp1P, bar_index, _tp1P, color=_tp1C, width=1, style=line.style_dashed)
    lvl.tp2Line   := line.new(bar_index, _tp2P, bar_index, _tp2P, color=_tp2C, width=1, style=line.style_dashed)
    lvl.tp3Line   := line.new(bar_index, _tp3P, bar_index, _tp3P, color=_tp3C, width=1, style=line.style_dashed)

    lvl.slLbl    := label.new(bar_index, _slP,  "✕ SL "    + str.tostring(_slP,  format.mintick), style=label.style_label_left, color=_slC,  textcolor=IN_C_TXT, size=size.small)
    lvl.entryLbl := label.new(bar_index, _enP,  "▶ Entry " + str.tostring(_enP,  format.mintick), style=label.style_label_left, color=_enC,  textcolor=IN_C_TXT, size=size.small)
    lvl.tp1Lbl   := label.new(bar_index, _tp1P, "◆ TP1 "   + str.tostring(_tp1P, format.mintick), style=label.style_label_left, color=_tp1C, textcolor=IN_C_TXT, size=size.small)
    lvl.tp2Lbl   := label.new(bar_index, _tp2P, "✦ TP2 "   + str.tostring(_tp2P, format.mintick), style=label.style_label_left, color=_tp2C, textcolor=IN_C_TXT, size=size.small)
    lvl.tp3Lbl   := label.new(bar_index, _tp3P, "◆ TP3 "   + str.tostring(_tp3P, format.mintick), style=label.style_label_left, color=_tp3C, textcolor=IN_C_TXT, size=size.small)

    lvl.riskFill   := linefill.new(lvl.slLine, lvl.entryLine, C_RISK_FILL)
    lvl.rewardFill := linefill.new(lvl.entryLine, lvl.tp3Line, C_REWARD_FILL)

if not na(lvl.slLine) and barstate.islast
    int _extX = i_lockSignal ? bar_index + 10 : last_bar_index + 10
    line.set_x2(lvl.slLine,    _extX)
    line.set_x2(lvl.entryLine, _extX)
    line.set_x2(lvl.tp1Line,   _extX)
    line.set_x2(lvl.tp2Line,   _extX)
    line.set_x2(lvl.tp3Line,   _extX)
    label.set_x(lvl.slLbl,     _extX)
    label.set_x(lvl.entryLbl,  _extX)
    label.set_x(lvl.tp1Lbl,    _extX)
    label.set_x(lvl.tp2Lbl,    _extX)
    label.set_x(lvl.tp3Lbl,    _extX)

var string _dashPosMap = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table hud = table.new(_dashPosMap, 2, 12, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40))

f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

var RegMetrics ch_reg = RegMetrics.new(na, na, na, na, false, 0)

if barstate.islast
    int raw_len = (IN_USE_DYN_LEN and not na(piv_idx)) ? (bar_index - piv_idx + 1) : IN_FIX_LEN
    int requested_len = math.min(IN_MAX_LOOKBACK, math.max(5, raw_len))

    ch_reg := calc_regression_metrics(requested_len)

    float abs_r   = math.abs(ch_reg.pearsonR)
    bool is_weak  = IN_USE_R_FILT and (abs_r < IN_R_THRESH)
    float dev_in  = ch_reg.stdDev * IN_DEV_IN
    float dev_out = ch_reg.stdDev * IN_DEV_OUT

    color base_color = is_downtrend ? IN_C_BEAR : IN_C_BULL
    color f_main = is_weak ? IN_C_NEUT : base_color
    color f_fill = is_weak ? color.new(IN_C_NEUT, 90) : color.new(base_color, 92)

    if ch_reg.isValid and ch_reg.length >= 2
        string mode_ext = get_ext_mode(IN_EXT_MODE)
        int x1 = bar_index - ch_reg.length + 1
        int x2 = bar_index
        float y1 = ch_reg.startPrice
        float y2 = ch_reg.endPrice

        if na(draw.mid)
            draw.mid    := line.new(x1, y1, x2, y2, xloc.bar_index, extend=mode_ext, color=f_main, width=2, style=line.style_dashed)
            draw.topOut := line.new(x1, y1 + dev_out, x2, y2 + dev_out, xloc.bar_index, extend=mode_ext, color=f_main, width=2)
            draw.botOut := line.new(x1, y1 - dev_out, x2, y2 - dev_out, xloc.bar_index, extend=mode_ext, color=f_main, width=2)
            draw.topIn  := line.new(x1, y1 + dev_in, x2, y2 + dev_in, xloc.bar_index, extend=mode_ext, color=f_main, width=1, style=line.style_dotted)
            draw.botIn  := line.new(x1, y1 - dev_in, x2, y2 - dev_in, xloc.bar_index, extend=mode_ext, color=f_main, width=1, style=line.style_dotted)
            draw.fill   := linefill.new(draw.topIn, draw.botIn, f_fill)
            if IN_SHOW_METRICS
                draw.stats := label.new(bar_index + 5, high + ta.tr(true), "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=IN_C_BG, textcolor=IN_C_TXT, size=size.normal)
        else
            line.set_xy1(draw.mid, x1, y1), line.set_xy2(draw.mid, x2, y2), line.set_color(draw.mid, f_main), line.set_extend(draw.mid, mode_ext)
            line.set_xy1(draw.topOut, x1, y1 + dev_out), line.set_xy2(draw.topOut, x2, y2 + dev_out), line.set_color(draw.topOut, f_main), line.set_extend(draw.topOut, mode_ext)
            line.set_xy1(draw.botOut, x1, y1 - dev_out), line.set_xy2(draw.botOut, x2, y2 - dev_out), line.set_color(draw.botOut, f_main), line.set_extend(draw.botOut, mode_ext)
            line.set_xy1(draw.topIn, x1, y1 + dev_in), line.set_xy2(draw.topIn, x2, y2 + dev_in), line.set_color(draw.topIn, f_main), line.set_extend(draw.topIn, mode_ext)
            line.set_xy1(draw.botIn, x1, y1 - dev_in), line.set_xy2(draw.botIn, x2, y2 - dev_in), line.set_color(draw.botIn, f_main), line.set_extend(draw.botIn, mode_ext)
            linefill.set_color(draw.fill, f_fill)

        if IN_SHOW_METRICS and not na(draw.stats)
            string txt = "STATS\nLen: " + str.tostring(ch_reg.length) + "\nR: " + str.tostring(ch_reg.pearsonR, "#.###") + "\nσ: " + str.tostring(stress_eng.z_score, "#.##")
            label.set_xy(draw.stats, bar_index + 5, high + ta.tr(true))
            label.set_text(draw.stats, txt)

// ── DASHBOARD ─────────────────────────────────────────

if barstate.islast
    color row_a = C_DASH_BG
    color row_b = color.new(C_DASH_BG, 40)
    color lbl_col = color.new(C_DASH_TXT, 25)

    table.cell(hud, 0, 0, "TREND STRESS QUANT", text_color=C_DASH_TXT, text_size=size.small, text_halign=text.align_left, bgcolor=C_DASH_HDR)
    table.cell(hud, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, text_size=size.small, text_halign=text.align_right, bgcolor=C_DASH_HDR)

    table.cell(hud, 0, 1, "  Lock", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(hud, 1, 1, i_lockSignal ? "ACTIVE  " : "OFF  ", text_color=i_lockSignal ? IN_C_BEAR : C_DASH_TXT, text_halign=text.align_right, text_size=size.small, bgcolor=row_a)

    string regime = is_downtrend ? "Bearish" : "Bullish"
    color regime_col = is_downtrend ? IN_C_BEAR : IN_C_BULL
    table.cell(hud, 0, 2, "  Trend Regime", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(hud, 1, 2, regime + "  ", text_color=regime_col, text_halign=text.align_right, text_size=size.small, bgcolor=row_b)

    string s_status = seller_exhaustion ? "EXHAUSTED" : "Normal"
    color s_col = seller_exhaustion ? IN_C_BULL : C_DASH_TXT
    table.cell(hud, 0, 3, "  Seller Status", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(hud, 1, 3, s_status + "  ", text_color=s_col, text_halign=text.align_right, text_size=size.small, bgcolor=row_a)

    string b_status = buyer_exhaustion ? "EXHAUSTED" : "Normal"
    color b_col = buyer_exhaustion ? IN_C_BEAR : C_DASH_TXT
    table.cell(hud, 0, 4, "  Buyer Status", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(hud, 1, 4, b_status + "  ", text_color=b_col, text_halign=text.align_right, text_size=size.small, bgcolor=row_b)

    float ch_width_raw = ch_reg.stdDev * IN_DEV_OUT * 2
    float ch_width_pct = ch_reg.endPrice != 0 ? (ch_width_raw / ch_reg.endPrice) * 100 : 0

    table.cell(hud, 0, 5, "  Channel Width", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(hud, 1, 5, f_bar(ch_width_pct, IN_WIDTH_HIGH * 2), text_color=f_barColor(math.min(ch_width_pct / (IN_WIDTH_HIGH * 2), 1.0)), text_halign=text.align_right, text_size=size.small, bgcolor=row_a)

    float abs_r_dash = math.abs(ch_reg.pearsonR)
    table.cell(hud, 0, 6, "  Pearson R", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(hud, 1, 6, f_bar(abs_r_dash, 1.0), text_color=f_barColor(abs_r_dash), text_halign=text.align_right, text_size=size.small, bgcolor=row_b)

    table.cell(hud, 0, 7, "  Entry", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(hud, 1, 7, (not na(activeEn) ? str.tostring(activeEn, format.mintick) : "—") + "  ", text_color=C_ENTRY, text_halign=text.align_right, text_size=size.small, bgcolor=row_a)

    table.cell(hud, 0, 8, "  Stop Loss", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(hud, 1, 8, (not na(activeSl) ? str.tostring(activeSl, format.mintick) : "—") + "  ", text_color=C_SL, text_halign=text.align_right, text_size=size.small, bgcolor=row_b)

    table.cell(hud, 0, 9, "  TP1", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(hud, 1, 9, (not na(activeTp1) ? str.tostring(activeTp1, format.mintick) : "—") + "  ", text_color=color.new(C_TP1, 0), text_halign=text.align_right, text_size=size.small, bgcolor=row_a)

    if i_useAdxFilter
        table.cell(hud, 0, 10, "  ADX", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
        table.cell(hud, 1, 10, str.tostring(_adxVal, "#.##") + "  ", text_color=_adxPass ? IN_C_BULL : IN_C_BEAR, text_halign=text.align_right, text_size=size.small, bgcolor=row_b)

    if i_adaptFilterType != "None"
        table.cell(hud, 0, 11, "  Adapt Filter", text_color=lbl_col, text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
        table.cell(hud, 1, 11, i_adaptFilterType + "  ", text_color=C_DASH_TXT, text_halign=text.align_right, text_size=size.small, bgcolor=row_a)
````
