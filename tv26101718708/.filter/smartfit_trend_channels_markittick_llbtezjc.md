# SmartFit Trend Channels [MarkitTick]

- url: https://www.tradingview.com/script/lLbTezjC-SmartFit-Trend-Channels-MarkitTick/
- type: indicator
- pine_id: PUB;dae7396b9f1e4b56886305e151d17934
- version: 1.0

## Description

💡 This tool builds a linear regression channel that does not sit on a fixed, arbitrary lookback window. Instead, it continuously re-anchors itself at confirmed swing pivots, filters its regression source through a selectable adaptive smoothing stage, validates every channel against a statistical fit-quality test, and optionally gates its breakout signals behind a trend-strength filter. Confirmed breakouts trigger directional alerts (including ready-to-route webhook JSON payloads), while a compact on-chart dashboard keeps the current channel's statistics visible at all times.

[b]✨ Originality and Utility[/b]
Most regression-channel tools on the platform work from a single static bar count chosen by the user, redraw the entire channel on every bar, and offer no way to judge whether the underlying price action is actually behaving linearly enough for a straight-line model to be meaningful. This script addresses all three limitations at once. It measures channel validity using the Pearson correlation coefficient rather than assuming a regression fit is automatically useful, it restarts its lookback window dynamically at the most recent statistically valid swing pivot rather than a fixed period, and it finalizes historical segments as discrete drawn objects instead of continuously repainting a single line across the whole chart.

[b]● Why These Components Are Combined[/b]
The regression engine, the pivot-anchoring logic, the adaptive source filter, the ADX gate, and the merge engine are not stacked together arbitrarily; each solves a specific weakness left open by the others. The adaptive smoothing stage reduces the high-frequency noise that a raw-price regression is otherwise highly sensitive to. The pivot-anchoring logic solves the "where should this channel actually start" problem that fixed-length regression channels never address. The Pearson fit-quality filter prevents the tool from drawing a confident-looking straight line through what is statistically a sideways, non-linear market. The ADX filter exists specifically to reduce breakout signals firing inside genuinely trendless conditions. The merge engine exists to prevent the chart from filling with redundant, near-identical channel segments once the pivot-anchoring logic starts producing frequent restarts on lower timeframes. Together, these form one coherent statistically-aware channel system rather than five unrelated features bundled for the sake of it.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/H3B3zfbw/[/image]
[b]● Regression Engine[/b]
At its core, the script performs an ordinary least-squares linear regression across the bars since the current channel's anchor point, producing a slope and intercept that define the channel's midline. This calculation always runs on confirmed, closed price data, never on the live forming bar.

[b]● Statistical Validity Filter[/b]
Every regression is scored with the Pearson correlation coefficient, which measures how well price actually fits a straight line on a scale of -1 to 1. A minimum bar count and a minimum absolute correlation strength (both user-configurable) must be met before a channel, or a breakout signal derived from it, is considered valid. Channels that fail this test are still drawn, but are visually flagged as low-confidence rather than treated as a directional signal.

[b]● Deviation Bands[/b]
Upper and lower channel boundaries are placed a user-defined number of standard deviations away from the regression midline, based on the vertical dispersion of price around that line. This produces a statistically scaled envelope rather than a fixed-percentage or fixed-tick band.

[b]● Adaptive Source Filter[/b]
Instead of regressing on raw closing price, the script can first pass price through one of several smoothing methods, selectable per chart:
[list]
[*]SMA / EMA / RMA — standard simple, exponential, and Wilder-smoothed moving averages, offered as baseline options with different responsiveness-to-noise tradeoffs.
[*]Double WMA — a weighted moving average smoothed a second time through another weighted pass, trading additional lag for a cleaner underlying line.
[*]Triple VWMA — a volume-weighted moving average smoothed through three successive passes, intended for instruments where volume-weighting the trend estimate is meaningful.
[*]HMA — a low-lag moving average designed to track price more closely than a standard average of the same length.
[*]LLAMA — a proprietary MarkitTick method that blends a simple average baseline with a linear slope term measured across the filter length, effectively projecting the recent directional momentum forward onto the smoothing output rather than only averaging past values.
[*]Kalman Filter — a recursive single-state estimator that continuously balances its own prediction against each new price print, with the filter length controlling how much weight is given to new information versus the existing estimate.
[/list]
Selecting "None" regresses directly on the previous confirmed close.

[b]● Dynamic Pivot Anchoring[/b]
The script tracks confirmed swing highs and swing lows using a symmetric bar-confirmation window (either auto-scaled to the chart's timeframe or manually set). These pivots are only accepted once enough bars have closed on both sides of the candidate bar to confirm it, so no pivot is ever assumed before it is actually confirmable. When a breakout occurs, the script evaluates whether the most recent opposite-type pivot has a strong enough regression fit of its own to serve as a more representative channel origin; if it does, the newly drawn segment is anchored there instead of at the current bar.

[b]● Confirmation Lag Notice[/b]
Because segment anchors are only finalized once a breakout confirms them, a newly drawn historical segment's starting point is placed at a bar in the past, after the fact. This is standard behavior for any pivot-anchored channel tool and does not involve unconfirmed or future data, but it does mean the visual origin of a finalized segment was not known in real time at that bar; it becomes fixed only once the breakout that closes out the prior segment occurs.

[b]● Channel Merge Logic[/b]
When enabled, a newly forming channel is compared against the band edges of the segment it is replacing. If the gap between them falls within a user-selected tolerance (expressed as a multiple of the current standard deviation), no new discrete segment is drawn and the channel is treated as a continuation. This keeps visually similar, closely-spaced channels from cluttering the chart as separate labeled objects.

[b]● ADX Trend Filter[/b]
An optional Average Directional Index filter can require a minimum trend strength reading before a breakout is allowed to register as a directional signal, reducing the number of signals generated while the market is directionless.

[b]● Breakout Signal Logic and Webhook Alerts[/b]
A directional signal fires only on a confirmed bar, only when the minimum bar count and fit-quality thresholds are met, and only once per new breakout (not on every bar the price remains beyond the band). Each signal type — long entry, short entry, and their corresponding opposite-side close — has its own configurable action label, which is packaged into a JSON payload suitable for forwarding to third-party automation or webhook services.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/oKY69nWV/[/image]
The live, currently forming channel is drawn as three connected lines — an upper band, a midline, and a lower band — with the space between the bands filled in a translucent color. Green indicates a bullish-sloped channel, red indicates a bearish-sloped channel, and gray indicates a channel that has not met the minimum fit-quality threshold and should be treated as statistically unreliable. A small label at the live edge of the channel states its bias, its fit percentage (the Pearson correlation expressed as a percentage), and its standard deviation value. When a segment finalizes, its own colored line-and-fill combination plus a labeled marker remain on the chart as a permanent historical record of that channel. An optional setting recolors the chart's candles using the live channel's bias color for an at-a-glance read of current conditions without needing to look at the channel itself. In the corner of the chart (position configurable), a compact dashboard table lists the ticker and timeframe, current bias, a bar-style fit-quality gauge, the standard deviation value, the current upper and lower band prices, the number of bars in the active channel, the pivot length in use, the current breakout/breakdown state, and — only when the relevant filters are enabled — the live ADX reading and the selected adaptive filter type.

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/2tbQTudM/[/image]
Read channel color and the dashboard's Bias row together: a green, high-fit-percentage channel reflects a statistically supported uptrend in the regression sense, while red reflects the equivalent downtrend condition. Treat gray, low-fit-percentage channels as periods where price is not moving in a way a straight line meaningfully describes, and weight any signal generated during those conditions accordingly. A directional signal, visible as a Breakout or Breakdown state on the dashboard and paired with an alert firing, indicates confirmed price has closed beyond the channel's statistical deviation band with sufficient trend history and fit quality behind it — this is a signal generator, not a backtested strategy, so no historical win-rate or equity curve is produced by the script itself. Enabling the ADX filter is most useful on instruments or timeframes prone to frequent whipsaw, where it will suppress breakouts that occur without adequate underlying trend strength. Choosing a smoother adaptive filter (Double WMA, Triple VWMA) will produce fewer but later channel restarts; choosing a more responsive one (HMA, Kalman, LLAMA) will track price more closely at the cost of more frequent re-anchoring. Enable channel merging on lower timeframes or choppier symbols to keep the chart readable; disable it if you want to see every discrete regression segment the script produces. To receive the webhook-ready alerts, create an alert on the script using the "Any alert() function call" option, or select one of the four named alert conditions individually if only a subset of signals is needed.

[b]⚙️ Inputs and Settings[/b]
The Core group controls the statistical backbone of the tool: automatic or manual pivot lookback length, whether nearby channels merge and how strict that merge tolerance is, the minimum Pearson fit strength and minimum bar count required for a channel to be considered valid, and the deviation z-score used to size the bands. The Filters group holds the optional ADX trend gate (toggle, threshold, and length) and the adaptive source filter selection along with its length. The Visuals group controls channel line width and whether chart candles are recolored by the live channel bias. The Dashboard group sets which corner of the chart the statistics table is drawn in. The Alerts group defines the text sent in the "action" field of each of the four webhook JSON payloads (long, short, close-long, close-short), allowing the payload vocabulary to be matched to whatever automation platform is receiving it. The Colors group governs the bullish, bearish, and weak-fit channel colors, the support/resistance accent colors used in the dashboard gauge, and the dashboard's background, header, text, and warning colors.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The regression core is an ordinary least-squares fit — the same slope and intercept formulas taught in introductory statistics, chosen because they minimize the sum of squared vertical distances between the line and each price point in the window. Layered on top of this is the Pearson product-moment correlation coefficient, the standard statistical measure of how strongly two variables are linearly related; applying it to price-versus-time is the same logic underlying R²-based confidence filters used in quantitative trend-following research, here repurposed as a simple accept/reject gate for whether a channel is worth trusting. The deviation bands draw on the same statistical foundation as Bollinger-style envelopes — a mean or trend estimate flanked by a multiple of the underlying standard deviation — except the dispersion here is measured as residual distance from a sloped regression line rather than from a flat moving average, and a z-score of 1.96 specifically corresponds to the approximate 95% interval of a normal distribution, a deliberate nod to standard statistical confidence-interval convention. The pivot-confirmation logic is a symmetric-window fractal test in the tradition of classic swing-high/swing-low detection methods, used here purely as a principled way to choose a channel's starting point rather than as a standalone trading signal. The ADX/DMI component follows Welles Wilder's original directional movement framework for measuring trend strength independent of trend direction. Among the adaptive filters, the Kalman option applies a simplified single-state predict-correct estimator common in signal processing and control theory, while the LLAMA option applies a linear-extrapolation-style adjustment to a moving average — conceptually related to trend-adjusted smoothing methods such as Holt's linear exponential smoothing, which projects recent momentum forward rather than only averaging past observations.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("SmartFit Trend Channels [MarkitTick]", overlay=true, max_lines_count=500, max_boxes_count=500, behind_chart=false)

// ── INPUTS ──────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core"
i_autoPivotLen        = input.bool(true, "Auto Pivot Lookback", group=GRP_CORE, tooltip="When enabled, pivot length is auto-calculated from chart timeframe")
i_manualPivotLen      = input.int(8, "Manual Pivot Lookback", group=GRP_CORE, minval=1, tooltip="Used only when Auto Pivot Lookback above is disabled")
i_enableMerge         = input.bool(false, "Enable Channel Merging", group=GRP_CORE, tooltip="When enabled, nearby channels merge into one; when disabled, each channel draws as a separate segment")
i_mergeMode           = input.string("Normal", "Merge Sensitivity", options=["Strict", "Normal", "Loose", "Custom"], group=GRP_CORE, tooltip="Controls how close two channel edges must be to merge: Strict=tightest, Loose=most permissive")
i_mergeCustomTol      = input.float(0.5, "Custom Tolerance (StdDev)", group=GRP_CORE, minval=0.0, maxval=5.0, step=0.1, tooltip="Used only when Custom is selected in Merge Sensitivity")
i_fitQualityThreshold = input.float(0.5, "Min Fit Quality (|r|)", group=GRP_CORE, minval=0.0, maxval=1.0, step=0.05, tooltip="Minimum |Pearson r| correlation strength for a channel to be considered statistically valid")
i_minFitBars          = input.int(5, "Min Fit Bars", group=GRP_CORE, minval=2, tooltip="Minimum number of bars required for a meaningful correlation coefficient")
i_deviationZScore     = input.float(1.96, "Deviation Z-Score", group=GRP_CORE, minval=0.1, maxval=5.0, step=0.01, tooltip="Number of standard deviations used to draw the upper and lower channel bounds")
var string GRP_FILT = "🕯️ Filters"
i_useAdxFilter        = input.bool(false, "Use ADX Filter", group=GRP_FILT)
i_adxThresh           = input.float(20.0, "ADX Threshold", group=GRP_FILT, minval=0, step=0.5)
i_adxLen              = input.int(14, "ADX Length", group=GRP_FILT, minval=1)
i_adaptFilterType      = input.string("None", "Adaptive Filter", options=["None", "SMA", "EMA", "RMA", "Double WMA", "Triple VWMA", "HMA", "LLAMA", "Kalman Filter"], group=GRP_FILT)
i_adaptFilterLen       = input.int(20, "Adaptive Filter Length", group=GRP_FILT, minval=1)
var string GRP_VIS = "🎨 Visuals"
i_lineWidth           = input.int(1, "Channel Line Width", group=GRP_VIS, minval=1, maxval=10)
i_candleColoring      = input.bool(false, "🕯️ Color Candles by Channel", group=GRP_VIS, tooltip="Colors chart candles using the live channel bias color")
var string GRP_DASH = "📊 Dashboard"
i_dashPos             = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_DASH)
var string GRP_WH = "🔔 Alerts"
i_actionLong          = input.string("long", "Long Action", group=GRP_WH)
i_actionShort         = input.string("short", "Short Action", group=GRP_WH)
i_actionCloseLong     = input.string("closelong", "Close Long Action", group=GRP_WH)
i_actionCloseShort    = input.string("closeshort", "Close Short Action", group=GRP_WH)
var string GRP_COLORS = "🌈 Colors"
colorBull              = input.color(color.new(#00FF00, 85), "Bull Color", group=GRP_COLORS)
colorBear              = input.color(color.new(#FF0000, 85), "Bear Color", group=GRP_COLORS)
colorNeutral           = input.color(color.new(#787b86, 70), "Weak Fit Color", group=GRP_COLORS)
C_SUP                 = input.color(#26a69a, "Bull Color", group=GRP_COLORS)
C_RES                 = input.color(#ef5350, "Bear Color", group=GRP_COLORS)
C_DASH_HDR            = input.color(color.new(#3a2a6d, 55), "Dash Header", group=GRP_COLORS)
C_DASH_BG             = input.color(color.new(#0a0f1a, 10), "Dash BG", group=GRP_COLORS)
C_DASH_TXT            = input.color(#ffffff, "Dash Text", group=GRP_COLORS)
C_DASH_WARN           = input.color(#f9a825, "Dash Warn", group=GRP_COLORS)

// ── CORE LOGIC ──────────────────────────────────────────────
int   tfSeconds               = timeframe.in_seconds()
int   pivotLen                = i_autoPivotLen ? (tfSeconds <= 300 ? 5 : tfSeconds <= 3600 ? 8 : tfSeconds <= 86400 ? 10 : 15) : i_manualPivotLen
float FIT_QUALITY_THRESHOLD   = i_fitQualityThreshold
int   MIN_FIT_BARS            = i_minFitBars
float DEVIATION_ZSCORE        = i_deviationZScore
float MERGE_TOLERANCE_STDEV   = i_mergeMode == "Strict" ? 0.25 : i_mergeMode == "Normal" ? 0.5 : i_mergeMode == "Loose" ? 1.0 : i_mergeCustomTol

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
    var float _est = float(na)
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
calcSlope(series float source, int length) =>
    max_bars_back(source, 5000)
    int len = math.min(length, 5000)
    if len <= 1
        [float(na), float(na), float(na)]
    else
        float sumX    = 0.0
        float sumY    = 0.0
        float sumXSqr = 0.0
        float sumXY   = 0.0
        for i = 0 to len - 1
            val = source[i]
            per = i + 1.0
            sumX    += per
            sumY    += val
            sumXSqr += per * per
            sumXY   += val * per
        float slope     = (len * sumXY - sumX * sumY) / (len * sumXSqr - sumX * sumX)
        float average   = sumY / len
        float intercept = average - slope * sumX / len + slope
        [slope, average, intercept]
calcDev(series float source, series float srcHigh, series float srcLow, int length, float slope, float average, float intercept) =>
    max_bars_back(source,  5000)
    max_bars_back(srcHigh, 5000)
    max_bars_back(srcLow,  5000)
    int len = math.min(length, 5000)
    if len <= 1
        [float(na), float(na), float(na), float(na)]
    else
        float upDev     = 0.0
        float dnDev     = 0.0
        float stdDevAcc = 0.0
        float dsxx      = 0.0
        float dsyy      = 0.0
        float dsxy      = 0.0
        int   periods   = len - 1
        float daY       = intercept + slope * periods / 2
        float val       = intercept
        for j = 0 to periods
            float price = srcHigh[j] - val
            if price > upDev
                upDev := price
            price := val - srcLow[j]
            if price > dnDev
                dnDev := price
            price := source[j]
            float dxt = price - average
            float dyt = val - daY
            price     -= val
            stdDevAcc += price * price
            dsxx      += dxt * dxt
            dsyy      += dyt * dyt
            dsxy      += dxt * dyt
            val       += slope
        float stdDev   = math.sqrt(stdDevAcc / (periods == 0 ? 1 : periods))
        float pearsonR = dsxx == 0.0 or dsyy == 0.0 ? 0.0 : dsxy / math.sqrt(dsxx * dsyy)
        [stdDev, pearsonR, upDev, dnDev]
var int start_index        = 1
var int start_time         = time
var int lastPivotHighIndex = 1
var int lastPivotHighTime  = time
var int lastPivotLowIndex  = 1
var int lastPivotLowTime   = time
float ph = f_pivotHigh(high[1], pivotLen)
float pl = f_pivotLow(low[1],  pivotLen)
if not na(ph)
    lastPivotHighIndex := bar_index - pivotLen - 1
    lastPivotHighTime  := time[pivotLen + 1]
if not na(pl)
    lastPivotLowIndex := bar_index - pivotLen - 1
    lastPivotLowTime  := time[pivotLen + 1]
[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal >= i_adxThresh
float _adaptedSrc = i_adaptFilterType == "SMA"         ? f_sma(close[1], i_adaptFilterLen) :
 i_adaptFilterType == "EMA"         ? f_ema(close[1], i_adaptFilterLen) :
 i_adaptFilterType == "RMA"         ? f_rma(close[1], i_adaptFilterLen) :
 i_adaptFilterType == "Double WMA"  ? f_doubleWma(close[1], i_adaptFilterLen) :
 i_adaptFilterType == "Triple VWMA" ? f_tripleVwma(close[1], i_adaptFilterLen) :
 i_adaptFilterType == "HMA"         ? f_hma(close[1], i_adaptFilterLen) :
 i_adaptFilterType == "LLAMA"       ? f_llama(close[1], i_adaptFilterLen) :
 i_adaptFilterType == "Kalman Filter" ? f_kalman(close[1], i_adaptFilterLen) : close[1]
int lengthInput = bar_index - start_index + 1
[s, a, ic] = calcSlope(_adaptedSrc, lengthInput)
float startPrice = ic + s * (lengthInput - 1)
float endPrice   = ic
[stdDev, pearsonR, upDev, dnDev] = calcDev(_adaptedSrc, high[1], low[1], lengthInput, s, a, ic)
float upperStartPrice = startPrice + DEVIATION_ZSCORE * stdDev
float upperEndPrice   = endPrice   + DEVIATION_ZSCORE * stdDev
float lowerStartPrice = startPrice - DEVIATION_ZSCORE * stdDev
float lowerEndPrice   = endPrice   - DEVIATION_ZSCORE * stdDev
int lowCandLen  = bar_index - lastPivotLowIndex  + 1
int highCandLen = bar_index - lastPivotHighIndex + 1
[lcs, lca, lcic]                      = calcSlope(_adaptedSrc, lowCandLen)
[lcStdDev, lowCandFit,  _lcUp, _lcDn] = calcDev(_adaptedSrc, high[1], low[1], lowCandLen,  lcs, lca, lcic)
[hcs, hca, hcic]                      = calcSlope(_adaptedSrc, highCandLen)
[hcStdDev, highCandFit, _hcUp, _hcDn] = calcDev(_adaptedSrc, high[1], low[1], highCandLen, hcs, hca, hcic)

// ── ALERTS ──────────────────────────────────────────────────────
string _longInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}"',
 i_actionLong, syminfo.tickerid, timeframe.period, str.tostring(close[1], format.mintick))
string longPayload = "{" + _longInner + "}"
string _shortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}"',
 i_actionShort, syminfo.tickerid, timeframe.period, str.tostring(close[1], format.mintick))
string shortPayload = "{" + _shortInner + "}"
string _closeLongInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long"',
 i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"
string _closeShortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short"',
 i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"

// ── VISUALS ───────────────────────────────────────────────
bool  chBullish  = s < 0
bool  chWeakFit  = math.abs(pearsonR) < FIT_QUALITY_THRESHOLD
color liveUpperC = chWeakFit ? colorNeutral : chBullish ? colorBull : colorBear
color liveLowerC = chWeakFit ? colorNeutral : chBullish ? colorBull : colorBear
color liveMidC   = chWeakFit ? colorNeutral : chBullish ? colorBull : colorBear
color bodyColor   = color.new(liveMidC, 0)
color borderColor = color.new(liveMidC, 0)
plotcandle(i_candleColoring ? open : na, i_candleColoring ? high : na, i_candleColoring ? low : na, i_candleColoring ? close : na, title="Channel Bias Candles", color=bodyColor, wickcolor=borderColor, bordercolor=borderColor)
var line baseLine = line.new(na, na, na, na, width=i_lineWidth, color=color.new(colorBull, 0), xloc=xloc.bar_time)
var line upper    = line.new(na, na, na, na, width=i_lineWidth, color=color.new(colorBull, 0), xloc=xloc.bar_time)
var line lower    = line.new(na, na, na, na, width=i_lineWidth, color=color.new(colorBull, 0), xloc=xloc.bar_time)
var linefill lf1  = linefill.new(upper, baseLine, color=colorBull)
var linefill lf2  = linefill.new(baseLine, lower, color=colorBull)
line.set_xy1(baseLine, start_time, startPrice)
line.set_xy2(baseLine, time,       endPrice)
line.set_color(baseLine, color.new(liveMidC, 0))
line.set_xy1(upper,    start_time, upperStartPrice)
line.set_xy2(upper,    time,       upperEndPrice)
line.set_color(upper, color.new(liveUpperC, 0))
line.set_xy1(lower,    start_time, lowerStartPrice)
line.set_xy2(lower,    time,       lowerEndPrice)
line.set_color(lower, color.new(liveLowerC, 0))
linefill.set_color(lf1, liveUpperC)
linefill.set_color(lf2, liveLowerC)
var label chLbl = label.new(na, na, "", style=label.style_label_down, size=size.small)
string chLblTxt = (chWeakFit ? "● Weak Fit Channel" : chBullish ? "▲ Bullish Channel" : "▼ Bearish Channel") + "\nFit " + str.tostring(math.round(math.abs(pearsonR) * 100)) + "%  |  σ " + str.tostring(stdDev, format.mintick)
label.set_xy(chLbl, bar_index, chBullish ? upperEndPrice : lowerEndPrice)
label.set_text(chLbl, chLblTxt)
label.set_style(chLbl, chBullish ? label.style_label_down : label.style_label_up)
label.set_color(chLbl, chWeakFit ? colorNeutral : chBullish ? colorBull : colorBear)
label.set_textcolor(chLbl, chWeakFit ? color.new(#ffffff, 50) : C_DASH_TXT)
bool isBullishBreak = close[1] > upperEndPrice and lengthInput >= MIN_FIT_BARS and math.abs(pearsonR) >= FIT_QUALITY_THRESHOLD
bool isBearishBreak = close[1] < lowerEndPrice and lengthInput >= MIN_FIT_BARS and math.abs(pearsonR) >= FIT_QUALITY_THRESHOLD
bool _prevBullish   = close[2] > upperEndPrice[1] and (bar_index - 1 - start_index + 1) >= MIN_FIT_BARS and math.abs(pearsonR[1]) >= FIT_QUALITY_THRESHOLD
bool _prevBearish   = close[2] < lowerEndPrice[1] and (bar_index - 1 - start_index + 1) >= MIN_FIT_BARS and math.abs(pearsonR[1]) >= FIT_QUALITY_THRESHOLD
bool _breakTriggered = (isBullishBreak and not _prevBullish) or (isBearishBreak and not _prevBearish)
bool longSignal  = isBullishBreak and not _prevBullish and _adxPass
bool shortSignal = isBearishBreak and not _prevBearish and _adxPass
if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
alertcondition(longSignal  and barstate.isconfirmed, "BUY Signal",         "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal",        "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(longSignal  and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
if _breakTriggered
    float candFit       = isBullishBreak ? lowCandFit : highCandFit
    int   candIndex     = isBullishBreak ? lastPivotLowIndex : lastPivotHighIndex
    int   candTime      = isBullishBreak ? lastPivotLowTime  : lastPivotHighTime
    bool  candValid     = not na(candFit) and math.abs(candFit) >= FIT_QUALITY_THRESHOLD and candIndex > start_index and candIndex < bar_index
    int   newStartIndex = candValid ? candIndex : bar_index
    int   newStartTime  = candValid ? candTime  : time
    int   barsAgoTrunc  = bar_index - newStartIndex
    float truncBaseEnd  = endPrice      + s * barsAgoTrunc
    float truncUpperEnd = upperEndPrice + s * barsAgoTrunc
    float truncLowerEnd = lowerEndPrice + s * barsAgoTrunc
    int   candLen        = isBullishBreak ? lowCandLen  : highCandLen
    float candSlope      = isBullishBreak ? lcs         : hcs
    float candIntercept  = isBullishBreak ? lcic         : hcic
    float candOwnStdDev  = isBullishBreak ? lcStdDev     : hcStdDev
    float candStartBase  = candValid ? candIntercept + candSlope * (candLen - 1)             : na
    float candStartUpper = candValid ? candStartBase + DEVIATION_ZSCORE * candOwnStdDev      : na
    float candStartLower = candValid ? candStartBase - DEVIATION_ZSCORE * candOwnStdDev      : na
    float bandGap        = candValid ? math.max(0.0, math.max(truncLowerEnd - candStartUpper, candStartLower - truncUpperEnd)) : na
    bool  mergeWithNext  = i_enableMerge and candValid and not na(bandGap) and bandGap <= MERGE_TOLERANCE_STDEV * stdDev
    if not mergeWithNext
        bool  segBullish = s < 0
        bool  segWeakFit = math.abs(pearsonR) < FIT_QUALITY_THRESHOLD
        color segUpperC  = segWeakFit ? colorNeutral : segBullish ? colorBull : colorBear
        color segLowerC  = segWeakFit ? colorNeutral : segBullish ? colorBull : colorBear
        color segMidC    = segWeakFit ? colorNeutral : segBullish ? colorBull : colorBear
        line _bl = line.new(start_time, startPrice,      newStartTime, truncBaseEnd,  width=i_lineWidth, color=color.new(segMidC, 0), xloc=xloc.bar_time)
        line _up = line.new(start_time, upperStartPrice, newStartTime, truncUpperEnd, width=i_lineWidth, color=color.new(segUpperC, 0), xloc=xloc.bar_time)
        line _lo = line.new(start_time, lowerStartPrice, newStartTime, truncLowerEnd, width=i_lineWidth, color=color.new(segLowerC, 0), xloc=xloc.bar_time)
        linefill.new(_up, _bl, color=segUpperC)
        linefill.new(_bl, _lo, color=segLowerC)
        label.new(newStartIndex, segBullish ? truncUpperEnd : truncLowerEnd, (segWeakFit ? "● Weak Fit Channel" : segBullish ? "▲ Bullish Channel" : "▼ Bearish Channel") + "\nFit " + str.tostring(math.round(math.abs(pearsonR) * 100)) + "%  |  σ " + str.tostring(stdDev, format.mintick), style=segBullish ? label.style_label_down : label.style_label_up, color=segWeakFit ? colorNeutral : segBullish ? colorBull : colorBear, textcolor=segWeakFit ? color.new(#ffffff, 50) : C_DASH_TXT, size=size.small)
        start_index := newStartIndex
        start_time  := newStartTime

// ── DASHBOARD ──────────────────────────────────────────────
f_bar(float val, float maxVal, color clr) =>
    int    filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar    = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"
f_barColor(float pct) =>
    pct >= 0.66 ? C_SUP : pct >= 0.33 ? C_DASH_WARN : C_RES
string dashPosResolved = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(dashPosResolved, 2, 11, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40))
color row_a = C_DASH_BG
color row_b = color.new(C_DASH_BG, 40)
bool  bullBias = s < 0
bool  biasWeakFit = math.abs(pearsonR) < FIT_QUALITY_THRESHOLD
float fitPct = math.min(math.abs(pearsonR), 1.0)
string breakoutState = isBullishBreak ? "▲ Breakout" : isBearishBreak ? "▼ Breakdown" : "— None"
color breakoutColor = isBullishBreak ? C_SUP : isBearishBreak ? C_RES : C_DASH_TXT
table.cell(dash, 0, 0, "RC", text_color=C_DASH_TXT, text_size=size.small, bgcolor=C_DASH_HDR, text_halign=text.align_left)
table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, text_size=size.small, bgcolor=C_DASH_HDR, text_halign=text.align_right)
table.cell(dash, 0, 1, "  Bias", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
table.cell(dash, 1, 1, (biasWeakFit ? "● Weak Fit" : bullBias ? "▲ Bull" : "▼ Bear") + "  ", text_color=biasWeakFit ? color.new(#ffffff, 50) : bullBias ? C_SUP : C_RES, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
table.cell(dash, 0, 2, "  Fit Quality", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
table.cell(dash, 1, 2, f_bar(fitPct, 1.0, f_barColor(fitPct)) + "  ", text_color=f_barColor(fitPct), text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
table.cell(dash, 0, 3, "  Std Dev", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
table.cell(dash, 1, 3, str.tostring(stdDev, format.mintick) + "  ", text_color=C_DASH_TXT, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
table.cell(dash, 0, 4, "  Upper Band", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
table.cell(dash, 1, 4, str.tostring(upperEndPrice, format.mintick) + "  ", text_color=C_DASH_TXT, text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
table.cell(dash, 0, 5, "  Lower Band", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
table.cell(dash, 1, 5, str.tostring(lowerEndPrice, format.mintick) + "  ", text_color=C_DASH_TXT, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
table.cell(dash, 0, 6, "  Channel Bars", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
table.cell(dash, 1, 6, str.tostring(lengthInput) + "  ", text_color=C_DASH_TXT, text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
table.cell(dash, 0, 7, "  Pivot Length", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
table.cell(dash, 1, 7, str.tostring(pivotLen) + "  ", text_color=C_DASH_TXT, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
table.cell(dash, 0, 8, "  Signal", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
table.cell(dash, 1, 8, breakoutState + "  ", text_color=breakoutColor, text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
if i_useAdxFilter
    table.cell(dash, 0, 9, "  ADX", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(_adxVal, "#.##") + "  ", text_color=_adxPass ? C_SUP : C_RES, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
if i_adaptFilterType != "None"
    table.cell(dash, 0, 10, "  Adapt Filter", text_color=color.new(C_DASH_TXT, 25), text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
    table.cell(dash, 1, 10, i_adaptFilterType + "  ", text_color=C_DASH_TXT, text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
````
