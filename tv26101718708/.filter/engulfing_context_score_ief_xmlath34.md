# Engulfing Context Score [IEF]

- url: https://www.tradingview.com/script/xMLAth34-Engulfing-Context-Score-IEF/
- type: indicator
- pine_id: PUB;b90db98489d443d7b1eb9e81b626c579
- version: 2.0

## Description

Engulfing Context Score (ECS) is a candle-event analyzer that ranks two-candle reversal candidates using a configurable 0-100 scoring heuristic. The score measures how closely a candle matches the chosen criteria. The weights and thresholds are design choices, not statistically calibrated estimates. The score has not been validated as a predictor of returns or reversal success.

PATTERN DEFINITION
The base candidate consists of two opposite-color candles, with a minimum previous body relative to the preceding ATR and a minimum current/previous body ratio. Defaults are 0.10 ATR and 1.20 times the previous body. Full body engulfment and a directional close beyond the previous high or low are enabled by default. Disabling full engulfment admits reversal candidates that may not engulf the previous body.

CALCULATION
Six components are normalized to 0-1 and combined by their weights. The final score is 100 times their weighted sum divided by the actual sum of weights, then rounded. At least one weight must be positive.

1. Body expansion: current/previous body ratio minus one, capped between zero and one. A body twice the previous size receives the maximum contribution.
2. Close location: bullish candidates use (close-low)/(high-low); bearish candidates use (high-close)/(high-low). The range denominator has a one-tick floor.
3. Rejection wick: bullish candidates use twice the lower-wick/range ratio; bearish candidates use twice the upper-wick/range ratio, capped at one. This is a geometric description of the wick, not proof of order flow or buyer/seller intent.
4. Participation: current volume divided by its 30-bar simple-average baseline. The normalized contribution is (relative volume-0.75)/1.25, capped between zero and one. If volume or its positive baseline is unavailable, the component receives a neutral 0.5 and the dashboard shows N/A. The script cannot determine whether a feed provides actual traded volume or tick volume.
5. Volatility context: 14-bar ATR divided by its 50-bar simple-average baseline. The contribution rises linearly from zero at 0.60x to one at 1.50x, then declines to zero at 3x. An unavailable or zero ATR baseline uses a 1x fallback. This measures volatility, not liquidity.
6. Confirmed context regime: 20- and 50-period EMAs from the preceding completed bar of the selected context timeframe. Bullish alignment contributes one to bullish candidates; bearish alignment contributes one to bearish candidates. Nonaligned regimes contribute zero.

Default weights are 25, 20, 15, 15, 10 and 15 respectively. They express the author's heuristic priorities and are user-adjustable. The default minimum score is 65.

PURPOSE AND CONTRIBUTION
The underlying engulfing pattern, ATR, relative volume and EMAs are established tools. This implementation's contribution is the transparent event-ranking framework that integrates candle geometry with contextual measurements in a single normalized score. Geometry describes the two-candle event, participation and volatility describe its surrounding conditions, and the completed-bar regime describes directional alignment. This lets users compare candidates under stated criteria rather than simply applying independent indicator gates. It does not claim a uniquely discovered pattern or proven trading advantage.

CONFIRMATION AND TIMEFRAMES
The context timeframe must be equal to or higher than the chart timeframe. A lower selection raises an explanatory error. The default is 60 minutes, so users on charts above 60 minutes must increase it. Equal timeframes use the preceding chart bar. Higher timeframe requests use an expression offset of one bar with lookahead enabled, so historical chart bars do not receive future context values.

Qualified signals and below-threshold markers appear only at chart-bar close. Dashboard readings marked Live are provisional and may change before close. Data-feed revisions can also alter historical calculations.

HOW TO USE
Start with the default settings and study the scored B (bullish) and S (bearish) labels. Increasing the minimum score selects fewer candidates; decreasing it selects more. Scores describe fit to the selected model, not expected profit.

Enable Show confirmed candidates below threshold to see small circles for lower-scoring candidates. These markers do not include candidates suppressed solely by cooldown. The default three-bar cooldown is shared across both directions and skips the next three bars after a qualifying signal.

Adjust weights to test an explicit hypothesis. Set a weight to zero to remove its contribution. Use volume-based criteria only when the instrument's feed is appropriate. Labels can be replaced by triangles, and qualifying-bar coloring is optional. The dashboard shows the current candidate state, relative volume, ATR regime and context direction. Alerts are available for qualifying bullish and bearish events. At most 500 score labels are retained by the script.

LIMITATIONS
A score of 80 does not mean an 80% probability of reversal. Engulfing candidates can fail during persistent trends, gaps, news or thin trading. Results vary with symbol, timeframe, session, feed and settings. There is no strategy backtest, win-rate claim or calibrated probability model. Higher timeframe context is delayed until the relevant bar completes. Conventional time-based candlestick charts are recommended; synthetic chart prices may produce different patterns.

DISCLAIMER
This open-source indicator is for educational and informational purposes only and is not financial, investment, or trading advice. Its scores, markers and alerts are not recommendations to buy or sell. It does not generate orders or calculate position size. Trading involves risk, including loss of capital. Historical observations do not guarantee future results. Users are responsible for their own analysis and decisions.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) IndicatorEliteFlow
//@version=6
indicator("Engulfing Context Score [IEF]", shorttitle="ECS [IEF]", overlay=true, max_labels_count=500)

// Engulfing Context Score does not stack unrelated indicator confirmations.
// It evaluates how convincingly the current candle rejects and displaces the previous candle,
// then places that event in participation, volatility, and confirmed higher-timeframe context.

string G_PATTERN = "Pattern Definition"
string G_SCORE   = "Quality Score"
string G_CONTEXT = "Market Context"
string G_DISPLAY = "Display"

float minBodyAtr       = input.float(0.10, "Minimum previous body / ATR", minval=0.0, step=0.05, group=G_PATTERN)
float minBodyRatio     = input.float(1.20, "Minimum current / previous body ratio", minval=1.0, step=0.05, group=G_PATTERN)
bool requireFullBody   = input.bool(true, "Require full body engulfment", group=G_PATTERN,
     tooltip="When disabled, candidates are opposite-color reversal candles and may not engulf the previous body.")
bool requireCloseBreak = input.bool(true, "Require close beyond previous high/low", group=G_PATTERN,
     tooltip="Adds displacement: bullish candles must close above the previous high; bearish candles below the previous low.")

int minScore           = input.int(65, "Minimum quality score", minval=0, maxval=100, group=G_SCORE)
int cooldownBars       = input.int(3, "Signal cooldown bars", minval=0, maxval=100, group=G_SCORE)
float wExpansion       = input.float(25, "Weight: body expansion", minval=0, maxval=100, group=G_SCORE)
float wCloseLocation   = input.float(20, "Weight: close location", minval=0, maxval=100, group=G_SCORE)
float wRejection       = input.float(15, "Weight: rejection wick", minval=0, maxval=100, group=G_SCORE)
float wParticipation   = input.float(15, "Weight: relative volume", minval=0, maxval=100, group=G_SCORE)
float wVolatility      = input.float(10, "Weight: volatility context", minval=0, maxval=100, group=G_SCORE)
float wRegime          = input.float(15, "Weight: confirmed HTF regime", minval=0, maxval=100, group=G_SCORE)

int atrLength          = input.int(14, "ATR length", minval=2, group=G_CONTEXT)
int volumeLength       = input.int(30, "Relative-volume length", minval=2, group=G_CONTEXT)
int volatilityLength   = input.int(50, "ATR baseline length", minval=5, group=G_CONTEXT)
string regimeTf        = input.timeframe("60", "Higher-timeframe regime", group=G_CONTEXT)
int regimeFast         = input.int(20, "HTF fast EMA", minval=1, group=G_CONTEXT)
int regimeSlow         = input.int(50, "HTF slow EMA", minval=2, group=G_CONTEXT)

bool showRaw           = input.bool(false, "Show confirmed candidates below threshold", group=G_DISPLAY)
bool showScoreLabels   = input.bool(true, "Show score labels", group=G_DISPLAY)
string scoreLabelSize  = input.string("Normal", "Score label size", options=["Small", "Normal", "Large", "Huge"], group=G_DISPLAY)
string signalLabelSize = scoreLabelSize == "Small" ? size.small : scoreLabelSize == "Large" ? size.large : scoreLabelSize == "Huge" ? size.huge : size.normal
bool colorSignalBars   = input.bool(false, "Color qualifying candles", group=G_DISPLAY)
bool showDashboard     = input.bool(true, "Show compact dashboard", group=G_DISPLAY)
color bullColor        = input.color(color.rgb(20, 184, 116), "Bullish color", group=G_DISPLAY)
color bearColor        = input.color(color.rgb(239, 83, 80), "Bearish color", group=G_DISPLAY)

clamp01(float value) => math.min(math.max(value, 0.0), 1.0)

float configuredWeight = wExpansion + wCloseLocation + wRejection + wParticipation + wVolatility + wRegime
if timeframe.in_seconds(regimeTf) < timeframe.in_seconds()
    runtime.error("Context timeframe must be equal to or higher than the chart timeframe. Increase the context timeframe in settings.")
if configuredWeight <= 0
    runtime.error("At least one score weight must be greater than zero.")

float atr = ta.atr(atrLength)
float prevBody = math.abs(close[1] - open[1])
float currBody = math.abs(close - open)
float candleRange = math.max(high - low, syminfo.mintick)

bool prevBear = close[1] < open[1]
bool prevBull = close[1] > open[1]
bool currBull = close > open
bool currBear = close < open
bool bullEngulf = open <= close[1] and close >= open[1]
bool bearEngulf = open >= close[1] and close <= open[1]
bool bodySizeOk = prevBody >= atr[1] * minBodyAtr and currBody >= prevBody * minBodyRatio

bool bullRaw = prevBear and currBull and bodySizeOk and (not requireFullBody or bullEngulf) and
     (not requireCloseBreak or close > high[1])
bool bearRaw = prevBull and currBear and bodySizeOk and (not requireFullBody or bearEngulf) and
     (not requireCloseBreak or close < low[1])

// Each component is normalized to 0..1 before weights are applied.
float expansionScore = math.min(math.max(currBody / math.max(prevBody, syminfo.mintick) - 1.0, 0.0), 1.0)
float bullCloseScore = clamp01((close - low) / candleRange)
float bearCloseScore = clamp01((high - close) / candleRange)
float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)
float bullRejectScore = clamp01(lowerWick / candleRange * 2.0)
float bearRejectScore = clamp01(upperWick / candleRange * 2.0)

float avgVolume = ta.sma(volume, volumeLength)
bool volumeAvailable = not na(volume) and not na(avgVolume) and avgVolume > 0
float relativeVolume = volumeAvailable ? volume / avgVolume : na
float participationScore = volumeAvailable ? clamp01((relativeVolume - 0.75) / 1.25) : 0.5
float atrBaseline = ta.sma(atr, volatilityLength)
float relativeAtr = na(atrBaseline) or atrBaseline == 0 ? 1.0 : atr / atrBaseline
// Reward an active but not extremely stretched regime.
float volatilityScore = relativeAtr <= 1.5 ? clamp01((relativeAtr - 0.60) / 0.90) :
     clamp01(1.0 - (relativeAtr - 1.5) / 1.5)

// [1] is evaluated inside request.security so only the last completed HTF bar is used.
float htfFast = request.security(syminfo.tickerid, regimeTf, ta.ema(close, regimeFast)[1], lookahead=barmerge.lookahead_on)
float htfSlow = request.security(syminfo.tickerid, regimeTf, ta.ema(close, regimeSlow)[1], lookahead=barmerge.lookahead_on)
float bullRegimeScore = htfFast > htfSlow ? 1.0 : 0.0
float bearRegimeScore = htfFast < htfSlow ? 1.0 : 0.0

float totalWeight = configuredWeight > 0 ? configuredWeight : 1.0
float bullScoreRaw = (expansionScore * wExpansion + bullCloseScore * wCloseLocation + bullRejectScore * wRejection +
     participationScore * wParticipation + volatilityScore * wVolatility + bullRegimeScore * wRegime) / totalWeight * 100.0
float bearScoreRaw = (expansionScore * wExpansion + bearCloseScore * wCloseLocation + bearRejectScore * wRejection +
     participationScore * wParticipation + volatilityScore * wVolatility + bearRegimeScore * wRegime) / totalWeight * 100.0
int bullScore = int(math.round(bullScoreRaw))
int bearScore = int(math.round(bearScoreRaw))

var int lastSignalBar = na
bool cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
bool bullSignal = barstate.isconfirmed and bullRaw and bullScore >= minScore and cooldownOk
bool bearSignal = barstate.isconfirmed and bearRaw and bearScore >= minScore and cooldownOk
if bullSignal or bearSignal
    lastSignalBar := bar_index

plotshape(bullSignal and not showScoreLabels, "Qualified bullish engulfing", shape.triangleup, location.belowbar, bullColor, size=size.small)
plotshape(bearSignal and not showScoreLabels, "Qualified bearish engulfing", shape.triangledown, location.abovebar, bearColor, size=size.small)
plotshape(showRaw and barstate.isconfirmed and bullRaw and bullScore < minScore, "Below-threshold bullish candidate", shape.circle, location.belowbar, color.new(bullColor, 70), size=size.tiny)
plotshape(showRaw and barstate.isconfirmed and bearRaw and bearScore < minScore, "Below-threshold bearish candidate", shape.circle, location.abovebar, color.new(bearColor, 70), size=size.tiny)

if bullSignal and showScoreLabels
    label.new(bar_index, low, "B " + str.tostring(bullScore), yloc=yloc.belowbar, style=label.style_label_up, color=bullColor, textcolor=color.white, size=signalLabelSize)
if bearSignal and showScoreLabels
    label.new(bar_index, high, "S " + str.tostring(bearScore), yloc=yloc.abovebar, style=label.style_label_down, color=bearColor, textcolor=color.white, size=signalLabelSize)

barcolor(colorSignalBars ? (bullSignal ? bullColor : bearSignal ? bearColor : na) : na)

var table dashboard = table.new(position.top_right, 2, 4, border_width=1)
if barstate.islast and showDashboard
    string stateText = (barstate.isconfirmed ? "" : "Live: ") + (bullRaw ? "Bull " + str.tostring(bullScore) : bearRaw ? "Bear " + str.tostring(bearScore) : "No pattern")
    color stateColor = bullRaw ? bullColor : bearRaw ? bearColor : color.gray
    table.cell(dashboard, 0, 0, "ECS", text_color=color.white, bgcolor=color.rgb(35, 39, 47))
    table.cell(dashboard, 1, 0, stateText, text_color=color.white, bgcolor=stateColor)
    table.cell(dashboard, 0, 1, "Rel volume", text_color=color.silver)
    table.cell(dashboard, 1, 1, volumeAvailable ? str.tostring(relativeVolume, "#.00") + "x" : "N/A (neutral)", text_color=color.white)
    table.cell(dashboard, 0, 2, "ATR regime", text_color=color.silver)
    table.cell(dashboard, 1, 2, str.tostring(relativeAtr, "#.00") + "x", text_color=color.white)
    table.cell(dashboard, 0, 3, "HTF regime", text_color=color.silver)
    table.cell(dashboard, 1, 3, htfFast > htfSlow ? "Bullish" : htfFast < htfSlow ? "Bearish" : "Neutral", text_color=color.white)
if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 3)

alertcondition(bullSignal, "Qualified Bullish Engulfing", "Bullish engulfing context score qualified on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearSignal, "Qualified Bearish Engulfing", "Bearish engulfing context score qualified on {{ticker}} {{interval}} at {{close}}")
````
