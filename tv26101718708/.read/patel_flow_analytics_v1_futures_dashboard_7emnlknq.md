# Patel Flow Analytics V1 - Futures Dashboard

- url: https://www.tradingview.com/script/7EmNLkNQ-Patel-Flow-Analytics-V1-Futures-Dashboard/
- type: indicator
- pine_id: PUB;c990b8e89a1c463681b61497379550f9
- version: 1.0

## Description

Patel Flow Analytics V1 is an intraday futures dashboard designed for NQ and MNQ. It combines price momentum, estimated directional volume, and session reference levels to show whether these measurements align. It uses the chart's OHLCV data and does not require an external options-flow feed.

HOW THE FLOW SCORE WORKS
The score ranges from -100 to +100. Its components are estimated session delta (35%), ATR-normalized fast/slow EMA separation (25%), ATR-normalized distance from session VWAP (25%), and the balance of recent large-volume up/down bars (15%). Combining these measurements places directional volume estimates in the context of trend and price location.

Estimated bar delta is volume multiplied by the close's relative position within the high-low range, mapped from -1 to +1. A zero-range bar contributes zero delta. Estimated buy/sell volume is derived from that calculation; it is not bid/ask execution data. Large-volume bars exceed a configurable multiple of average volume and are classified by candle direction.

DASHBOARD AND LEVELS
The dashboard shows bias, flow score, estimated session delta, estimated buy/sell imbalance, momentum, an absorption estimate, and recent large-volume bar counts. The absorption estimate combines relative volume with a narrow range relative to ATR; it does not confirm actual order absorption.

Chart levels include session VWAP, a developing POC proxy, VWAP plus/minus one volume-weighted standard deviation, opening-range high/low, and previous analysis-session high/low. The POC proxy assigns each bar's entire volume to a rounded typical-price bucket. It is not a true volume-at-price profile. The bands labeled VAH/VAL are standard-deviation proxies, not a conventional 70% volume-profile value area.

SETUP AND USE
Use standard intraday time-based candles with volume data. The illustrated chart is MNQ on 5 minutes. Keep electronic-session bars available so the script can detect transitions into and out of the chosen analysis session. Session calculations also depend on the history loaded on the chart.

The default analysis window is 09:30-16:00 in the symbol's EXCHANGE timezone, not the chart display timezone. Adjust it to your intended session. Other defaults are a 30-minute opening range, 8/21 EMAs, 14-bar ATR, 20-bar volume average, 1.8x large-volume threshold, 10-bar large-volume count window, and a flow threshold of 65. Rolling measurements can include bars outside the analysis window.

Within the selected session, scores of +65 or higher indicate bullish alignment and -65 or lower indicate bearish alignment. Outside the session, bias is neutral. Compare the score with price relative to VWAP, the opening range, and previous-session levels rather than treating one reading as an entry instruction.

SIGNALS AND ALERTS
Markers and alert conditions occur when the score crosses above the positive threshold or below the negative threshold during the analysis session. Values and crossings can change while a live candle is forming. Select Once Per Bar Close when creating alerts if you want signals evaluated at the close.

LIMITATIONS
This is an OHLCV-based analytical indicator. It does not measure genuine options flow, dealer positioning, gamma exposure, dark-pool transactions, or exchange-reported bid/ask delta. It does not place trades or include a strategy backtest. No profitability or predictive accuracy is claimed. Published open-source so users can inspect and adapt the calculations.

## Source Code

````pine
//@version=6
indicator("Patel Flow Analytics V1 [Futures]", shorttitle = "Patel Flow V1", overlay = true, max_labels_count = 100)

// Futures-only chart analytics for NQ/MNQ.
// Delta and large-volume activity are estimates derived from OHLCV data.

// ───────────────────── Inputs ─────────────────────
string groupSession = "Session and levels"

string sessionInput = input.session(
     "0930-1600",
     "Analysis session",
     group = groupSession,
     tooltip = "Uses the symbol's exchange timezone.")

int openingRangeMinutes = input.int(
     30,
     "Opening range minutes",
     minval = 1,
     maxval = 180,
     group = groupSession)

int pocBucketTicks = input.int(
     4,
     "POC bucket size (ticks)",
     minval = 1,
     maxval = 100,
     group = groupSession)

bool showLevels = input.bool(
     true,
     "Show market levels",
     group = groupSession)

string groupScoring = "Flow scoring"

int fastPeriod = input.int(
     8,
     "Fast EMA",
     minval = 2,
     maxval = 100,
     group = groupScoring)

int slowPeriod = input.int(
     21,
     "Slow EMA",
     minval = 3,
     maxval = 200,
     group = groupScoring)

int atrPeriod = input.int(
     14,
     "ATR period",
     minval = 2,
     maxval = 100,
     group = groupScoring)

int volumeLookback = input.int(
     20,
     "Volume lookback",
     minval = 2,
     maxval = 200,
     group = groupScoring)

float largeVolumeMultiple = input.float(
     1.8,
     "Large-volume multiple",
     minval = 1.0,
     maxval = 10.0,
     step = 0.1,
     group = groupScoring)

int largeVolumeLookback = input.int(
     10,
     "Large-volume lookback bars",
     minval = 2,
     maxval = 100,
     group = groupScoring)

string groupDisplay = "Dashboard and alerts"

float alertThreshold = input.float(
     65.0,
     "Strong-flow threshold",
     minval = 20.0,
     maxval = 100.0,
     step = 1.0,
     group = groupDisplay)

bool showDashboard = input.bool(
     true,
     "Show dashboard",
     group = groupDisplay)

bool showSignals = input.bool(
     true,
     "Show threshold signals",
     group = groupDisplay)

bool colorBars = input.bool(
     false,
     "Color bars by strong flow",
     group = groupDisplay)

// Custom gold color
color goldColor = color.rgb(255, 193, 7)

// ───────────────────── Helpers ─────────────────────
clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

fmtPrice(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

fmtNumber(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0")

// ───────────────────── Session state ─────────────────────
bool inSession = not na(time(timeframe.period, sessionInput))
bool newSession = inSession and not inSession[1]

var int sessionStartTime = na
var float sessionVolume = 0.0
var float sessionPriceVolume = 0.0
var float sessionPriceSquaredVolume = 0.0
var float sessionDelta = 0.0
var float sessionBuyVolume = 0.0
var float sessionSellVolume = 0.0
var float sessionHigh = na
var float sessionLow = na
var float previousSessionHigh = na
var float previousSessionLow = na
var float openingRangeHigh = na
var float openingRangeLow = na

var array<int> profileKeys = array.new<int>()
var array<float> profileVolumes = array.new<float>()

if newSession
    if not na(sessionHigh)
        previousSessionHigh := sessionHigh
        previousSessionLow := sessionLow

    sessionStartTime := time
    sessionVolume := 0.0
    sessionPriceVolume := 0.0
    sessionPriceSquaredVolume := 0.0
    sessionDelta := 0.0
    sessionBuyVolume := 0.0
    sessionSellVolume := 0.0
    sessionHigh := high
    sessionLow := low
    openingRangeHigh := high
    openingRangeLow := low

    array.clear(profileKeys)
    array.clear(profileVolumes)

float barRange = high - low

float closeLocation = barRange > 0 ?
     ((close - low) / barRange) * 2.0 - 1.0 : 0.0

float estimatedBarDelta =
     volume * clamp(closeLocation, -1.0, 1.0)

float estimatedBuyVolume =
     math.max(0.0, (volume + estimatedBarDelta) * 0.5)

float estimatedSellVolume =
     math.max(0.0, (volume - estimatedBarDelta) * 0.5)

if inSession
    float sourcePrice = hlc3

    sessionVolume += volume
    sessionPriceVolume += sourcePrice * volume
    sessionPriceSquaredVolume += sourcePrice * sourcePrice * volume
    sessionDelta += estimatedBarDelta
    sessionBuyVolume += estimatedBuyVolume
    sessionSellVolume += estimatedSellVolume

    sessionHigh := na(sessionHigh) ?
         high : math.max(sessionHigh, high)

    sessionLow := na(sessionLow) ?
         low : math.min(sessionLow, low)

    bool inOpeningRange =
         not na(sessionStartTime) and
         time < sessionStartTime + openingRangeMinutes * 60000

    if inOpeningRange
        openingRangeHigh := na(openingRangeHigh) ?
             high : math.max(openingRangeHigh, high)

        openingRangeLow := na(openingRangeLow) ?
             low : math.min(openingRangeLow, low)

    float bucketSize = syminfo.mintick * pocBucketTicks
    int priceKey = int(math.round(sourcePrice / bucketSize))
    int keyIndex = array.indexof(profileKeys, priceKey)

    if keyIndex == -1
        array.push(profileKeys, priceKey)
        array.push(profileVolumes, volume)
    else
        array.set(
             profileVolumes,
             keyIndex,
             array.get(profileVolumes, keyIndex) + volume)

// ───────────────────── Developing levels ─────────────────────
float sessionVwap = sessionVolume > 0 ?
     sessionPriceVolume / sessionVolume : na

float sessionVariance = sessionVolume > 0 ?
     math.max(
         0.0,
         sessionPriceSquaredVolume / sessionVolume -
         sessionVwap * sessionVwap) : na

float sessionDeviation = not na(sessionVariance) ?
     math.sqrt(sessionVariance) : na

float valueAreaHigh = not na(sessionVwap) ?
     sessionVwap + sessionDeviation : na

float valueAreaLow = not na(sessionVwap) ?
     sessionVwap - sessionDeviation : na

float sessionPoc = na

if array.size(profileKeys) > 0
    float maximumBucketVolume = -1.0
    int maximumBucketIndex = 0

    for index = 0 to array.size(profileKeys) - 1
        float bucketVolume = array.get(profileVolumes, index)

        if bucketVolume > maximumBucketVolume
            maximumBucketVolume := bucketVolume
            maximumBucketIndex := index

    float bucketSize = syminfo.mintick * pocBucketTicks

    sessionPoc :=
         array.get(profileKeys, maximumBucketIndex) *
         bucketSize

// ───────────────────── Flow model ─────────────────────
float fastEma = ta.ema(close, fastPeriod)
float slowEma = ta.ema(close, slowPeriod)

float atrValue =
     math.max(syminfo.mintick, ta.atr(atrPeriod))

float averageVolume =
     math.max(
         1.0,
         nz(ta.sma(volume, volumeLookback), volume))

float volumeRatio = volume / averageVolume

float momentumScore = clamp(
     (fastEma - slowEma) / atrValue * 100.0,
     -100.0,
     100.0)

float vwapScore = not na(sessionVwap) ?
     clamp(
         (close - sessionVwap) / atrValue * 65.0,
         -100.0,
         100.0) : 0.0

float deltaScore = sessionVolume > 0 ?
     clamp(
         sessionDelta / sessionVolume * 100.0,
         -100.0,
         100.0) : 0.0

float absorptionScore = clamp(
     volumeRatio *
     math.max(0.0, 1.0 - barRange / atrValue) *
     100.0,
     0.0,
     100.0)

bool largeBuyBar =
     volumeRatio >= largeVolumeMultiple and
     estimatedBarDelta > 0

bool largeSellBar =
     volumeRatio >= largeVolumeMultiple and
     estimatedBarDelta < 0

float largeBuyCount =
     math.sum(
         largeBuyBar ? 1.0 : 0.0,
         largeVolumeLookback)

float largeSellCount =
     math.sum(
         largeSellBar ? 1.0 : 0.0,
         largeVolumeLookback)

float largeVolumeScore = clamp(
     (largeBuyCount - largeSellCount) * 15.0,
     -100.0,
     100.0)

float flowScore = clamp(
     deltaScore * 0.35 +
     momentumScore * 0.25 +
     vwapScore * 0.25 +
     largeVolumeScore * 0.15,
     -100.0,
     100.0)

int bias = inSession ?
     (flowScore >= alertThreshold ? 1 :
     flowScore <= -alertThreshold ? -1 : 0) : 0

string biasText =
     bias == 1 ? "BULLISH" :
     bias == -1 ? "BEARISH" : "NEUTRAL"

color biasColor =
     bias == 1 ? color.lime :
     bias == -1 ? color.rgb(255, 82, 82) :
     goldColor

float imbalance =
     sessionSellVolume > 0 ?
     sessionBuyVolume / sessionSellVolume :
     sessionBuyVolume > 0 ? 99.0 : 1.0

// ───────────────────── Market-level plots ─────────────────────
sessionVwapPlot = plot(
     showLevels and inSession ? sessionVwap : na,
     "Session VWAP",
     color = goldColor,
     linewidth = 2)

sessionPocPlot = plot(
     showLevels and inSession ? sessionPoc : na,
     "Developing POC proxy",
     color = color.orange,
     linewidth = 2,
     style = plot.style_stepline)

vahPlot = plot(
     showLevels and inSession ? valueAreaHigh : na,
     "VWAP value-area high proxy",
     color = color.new(color.blue, 15),
     linewidth = 1)

valPlot = plot(
     showLevels and inSession ? valueAreaLow : na,
     "VWAP value-area low proxy",
     color = color.new(color.blue, 15),
     linewidth = 1)

fill(
     vahPlot,
     valPlot,
     color = color.new(color.blue, 92),
     title = "Value-area proxy")

plot(
     showLevels ? openingRangeHigh : na,
     "Opening range high",
     color = color.new(color.green, 5),
     linewidth = 1,
     style = plot.style_stepline)

plot(
     showLevels ? openingRangeLow : na,
     "Opening range low",
     color = color.new(color.red, 5),
     linewidth = 1,
     style = plot.style_stepline)

plot(
     showLevels ? previousSessionHigh : na,
     "Previous session high",
     color = color.new(color.green, 50),
     linewidth = 1,
     style = plot.style_stepline)

plot(
     showLevels ? previousSessionLow : na,
     "Previous session low",
     color = color.new(color.red, 50),
     linewidth = 1,
     style = plot.style_stepline)

// ───────────────────── Signals ─────────────────────
bool bullishSignal =
     inSession and
     ta.crossover(flowScore, alertThreshold)

bool bearishSignal =
     inSession and
     ta.crossunder(flowScore, -alertThreshold)

plotshape(
     showSignals and bullishSignal,
     title = "Bullish flow signal",
     style = shape.labelup,
     location = location.belowbar,
     color = color.lime,
     text = "FLOW+",
     textcolor = color.black,
     size = size.tiny)

plotshape(
     showSignals and bearishSignal,
     title = "Bearish flow signal",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.red,
     text = "FLOW-",
     textcolor = color.white,
     size = size.tiny)

barcolor(
     colorBars ?
     (bias == 1 ?
         color.new(color.lime, 55) :
      bias == -1 ?
         color.new(color.red, 55) : na) : na)

// ───────────────────── Dashboard ─────────────────────
var table dashboard = table.new(
     position.top_right,
     2,
     11,
     bgcolor = color.new(color.black, 12),
     frame_color = color.new(color.gray, 30),
     frame_width = 1,
     border_width = 1)

if barstate.islast and showDashboard
    table.cell(
         dashboard, 0, 0, "PATEL FLOW V1",
         text_color = color.white,
         bgcolor = color.rgb(30, 30, 35))

    table.cell(
         dashboard, 1, 0, "FUTURES EST.",
         text_color = color.silver,
         bgcolor = color.rgb(30, 30, 35))

    table.cell(
         dashboard, 0, 1, "Bias",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 1, biasText,
         text_color = biasColor)

    table.cell(
         dashboard, 0, 2, "Flow score",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 2,
         fmtNumber(flowScore) + " / 100",
         text_color = biasColor)

    table.cell(
         dashboard, 0, 3, "Est. delta",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 3,
         str.tostring(sessionDelta, format.volume),
         text_color =
             sessionDelta >= 0 ? color.lime : color.red)

    table.cell(
         dashboard, 0, 4, "Imbalance",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 4,
         str.tostring(imbalance, "#.00"),
         text_color =
             imbalance >= 1 ? color.lime : color.red)

    table.cell(
         dashboard, 0, 5, "Momentum",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 5,
         fmtNumber(momentumScore),
         text_color =
             momentumScore >= 0 ? color.lime : color.red)

    table.cell(
         dashboard, 0, 6, "Absorption",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 6,
         fmtNumber(absorptionScore),
         text_color = color.aqua)

    table.cell(
         dashboard, 0, 7, "Large bars B/S",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 7,
         str.tostring(largeBuyCount, "#") +
         " / " +
         str.tostring(largeSellCount, "#"),
         text_color = color.white)

    table.cell(
         dashboard, 0, 8, "VWAP / POC",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 8,
         fmtPrice(sessionVwap) +
         " / " +
         fmtPrice(sessionPoc),
         text_color = goldColor)

    table.cell(
         dashboard, 0, 9, "VAH / VAL proxy",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 9,
         fmtPrice(valueAreaHigh) +
         " / " +
         fmtPrice(valueAreaLow),
         text_color = color.aqua)

    table.cell(
         dashboard, 0, 10, "ORH / ORL",
         text_color = color.silver)

    table.cell(
         dashboard, 1, 10,
         fmtPrice(openingRangeHigh) +
         " / " +
         fmtPrice(openingRangeLow),
         text_color = color.white)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 10)

// ───────────────────── Alert conditions ─────────────────────
alertcondition(
     bullishSignal,
     "Patel Flow Bullish",
     "Patel Flow Analytics crossed into a strong bullish state on {{ticker}} at {{close}}.")

alertcondition(
     bearishSignal,
     "Patel Flow Bearish",
     "Patel Flow Analytics crossed into a strong bearish state on {{ticker}} at {{close}}.")
````
