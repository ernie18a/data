# Correlation Exposure Dashboard [Pineify]

- url: https://www.tradingview.com/script/LnbPGdYI-Correlation-Exposure-Dashboard-Pineify/
- type: indicator
- pine_id: PUB;faf49f2457224a48a04aed27663d79cf
- version: 1.0

## Description

[b]Correlation Exposure Dashboard [Pineify][/b]

[b]Overview[/b]
This indicator compares chart returns with up to eight references. It maps rolling relationships into a risk field, correlation spine, exposure line, and heatmap. It describes co-movement only; it cannot read positions or issue trades.

[b]Problem Definition[/b]
Different tickers do not guarantee different risk. During a shared shock, several holdings can move as one cluster. A chart-to-benchmark correlation misses relationships inside the basket, while a raw average can look calm because closed sessions or invalid symbols removed most pairs. The real question is whether enough pairwise relationships show shrinking independent breadth, and whether the chart symbol joins that cluster.

[b]Design Rationale[/b]
Log returns make price levels comparable. References use the chart timeframe with gaps preserved, so a closed market is not treated as new flat data. Each pair uses one window and equal importance. Positive correlation drives concentration; negative correlation is not assumed to be a guaranteed hedge. Effective breadth converts clustering into a 0-100 score. A covariance model was rejected because it needs weights, volatility forecasts, currency conversion, and account data. This model is portable but not portfolio-specific.

[b]Key Features[/b]
[list]
[*]Eight configurable reference symbols.
[*]All enabled pairwise correlations with coverage gating.
[*]Effective breadth and chart-to-basket exposure.
[*]Confirmed hysteretic states and two alerts.
[*]Optional heatmap and layered risk field.
[/list]

[b]How It Works[/b]
The script calculates log(current close / prior close), then rolling Pearson correlation for every enabled reference pair and for the chart against each reference. Unavailable pairs remain missing, not zero.

Pair Coverage is usable pairs divided by expected pairs; no summary appears before its gate. Usable pairs produce signed mean, mean positive, RMS, and maximum absolute correlation. Concentration Pressure is positive mean times 100. Effective Breadth divides enabled count by one plus (count minus one) times positive mean, then normalizes the result as Diversification Score.

The red field is concentration; teal below zero is reserve. Gold is average pair correlation; blue is chart exposure. States confirm at bar close, with a release buffer against one-bar noise. Warm-up or poor coverage is Unavailable, not neutral.

[b]How Multiple Indicators Work Together[/b]
The layers form one chain. Pairwise correlation detects a basket cluster; coverage tests its evidence; effective breadth expresses independent components; chart exposure shows whether the displayed symbol participates. Without pairwise structure, exposure is only a benchmark average. Without coverage, the average can rest on sparse data. Without the chart link, basket concentration says nothing about the current symbol. These are coordinated measurements, not an arbitrary mashup.

[b]Trading Ideas and Insights[/b]
Use the dashboard as risk context, not an entry command. Rising red pressure with weakening teal reserve means references share more directional behavior. High chart absolute exposure adds evidence that the displayed symbol joins the cluster; low exposure means it may remain less connected. A rapid-decline marker flags a path change to compare with actual weights, volatility, liquidity, and event risk.

[b]Unique Aspects[/b]
This is a coverage-gated co-movement ladder, not a renamed correlation oscillator. It evaluates all enabled pairs, separates positive clustering from signed direction, converts clustering into normalized breadth, and keeps chart exposure distinct. Reliability controls availability and opacity. Red/teal fields show concentration versus reserve, while the heatmap retains instrument evidence. No retrieved LuxAlgo implementation informed the script.

[b]How to Use[/b]
[list=1]
[*]Enable two to eight relevant references and avoid accidental duplicates.
[*]Choose a window, then wait for Pair Coverage to pass.
[*]Read the risk field, pairwise spine, and chart exposure in that order.
[*]Inspect heatmap rows when sessions differ or values disappear.
[*]Use confirmed alerts with position limits maintained elsewhere.
[/list]

[b]Customization[/b]
Rolling Window trades responsiveness for stability. Minimum Pair Coverage controls how much of the enabled matrix must exist. Concentration and Severe thresholds set state entry; Release Buffer adds exit hysteresis. Diversification Threshold labels high reserve. Rapid Decline Lookback and Points define a path alert, not a forecast. The field remains usable when the spine, exposure, background, markers, or heatmap are hidden.

[b]Assumptions and Limitations[/b]
Correlation describes linear history; it does not prove causation, tail dependence, hedge effectiveness, or future behavior. Effective breadth assumes equal importance and equicorrelation. It ignores weights, volatility, currency, leverage, options, costs, and nonlinear dependence. Sessions, holidays, illiquidity, permissions, invalid tickers, and gaps can make samples economically uneven after the numerical gate passes. Live values change before close; states and alerts confirm only at close. Input, history, or feed changes recalculate results. Defaults are examples, and the score cannot guarantee diversification or loss protection.

[b]Conclusion[/b]
The dashboard makes clustering, breadth, coverage, and chart participation auditable. It shows no state without enough usable pairs. Treat it as a review aid, not advice or prediction.

## Source Code

````pine
//@version=6
indicator("Correlation Exposure Dashboard [Pineify]", overlay = false)

string groupWindow = "Correlation Model"
int correlationLengthInput = input.int(80, "Rolling Window", minval = 20, maxval = 500, group = groupWindow)
float minimumCoverageInput = input.float(70.0, "Minimum Pair Coverage (%)", minval = 25.0, maxval = 100.0, step = 5.0, group = groupWindow, tooltip = "Required share of enabled pairwise correlations that must be available before the basket summary is considered usable.")
float concentrationThresholdInput = input.float(55.0, "Concentration Threshold", minval = 20.0, maxval = 90.0, step = 1.0, group = groupWindow)
float severeThresholdInput = input.float(72.0, "Severe Concentration Threshold", minval = 30.0, maxval = 98.0, step = 1.0, group = groupWindow)
float diversificationThresholdInput = input.float(62.0, "Diversification Threshold", minval = 20.0, maxval = 95.0, step = 1.0, group = groupWindow)
float releaseBufferInput = input.float(8.0, "State Release Buffer", minval = 1.0, maxval = 25.0, step = 1.0, group = groupWindow)
int declineLookbackInput = input.int(5, "Rapid Decline Lookback", minval = 1, maxval = 30, group = groupWindow)
float declinePointsInput = input.float(12.0, "Rapid Decline Points", minval = 3.0, maxval = 40.0, step = 1.0, group = groupWindow)

string groupAssets = "Reference Basket"
bool use1Input = input.bool(true, "Use 1", inline = "asset1", group = groupAssets)
string symbol1Input = input.symbol("AMEX:SPY", "Symbol 1", inline = "asset1", group = groupAssets)
bool use2Input = input.bool(true, "Use 2", inline = "asset2", group = groupAssets)
string symbol2Input = input.symbol("NASDAQ:QQQ", "Symbol 2", inline = "asset2", group = groupAssets)
bool use3Input = input.bool(true, "Use 3", inline = "asset3", group = groupAssets)
string symbol3Input = input.symbol("NASDAQ:TLT", "Symbol 3", inline = "asset3", group = groupAssets)
bool use4Input = input.bool(true, "Use 4", inline = "asset4", group = groupAssets)
string symbol4Input = input.symbol("AMEX:GLD", "Symbol 4", inline = "asset4", group = groupAssets)
bool use5Input = input.bool(false, "Use 5", inline = "asset5", group = groupAssets)
string symbol5Input = input.symbol("CME_MINI:ES1!", "Symbol 5", inline = "asset5", group = groupAssets)
bool use6Input = input.bool(false, "Use 6", inline = "asset6", group = groupAssets)
string symbol6Input = input.symbol("TVC:DXY", "Symbol 6", inline = "asset6", group = groupAssets)
bool use7Input = input.bool(false, "Use 7", inline = "asset7", group = groupAssets)
string symbol7Input = input.symbol("BINANCE:BTCUSDT", "Symbol 7", inline = "asset7", group = groupAssets)
bool use8Input = input.bool(false, "Use 8", inline = "asset8", group = groupAssets)
string symbol8Input = input.symbol("FX:EURUSD", "Symbol 8", inline = "asset8", group = groupAssets)

string groupVisual = "Visual System"
bool showRiskFieldInput = input.bool(true, "Show Concentration and Diversification Field", group = groupVisual)
bool showCorrelationSpineInput = input.bool(true, "Show Pairwise Correlation Spine", group = groupVisual)
bool showChartExposureInput = input.bool(true, "Show Chart-to-Basket Exposure", group = groupVisual)
bool showBackgroundInput = input.bool(true, "Show Confirmed State Background", group = groupVisual)
bool showMarkersInput = input.bool(true, "Show Confirmed Event Markers", group = groupVisual)
bool showDashboardInput = input.bool(true, "Show Correlation Heatmap", group = groupVisual)

color concentrationColor = color.rgb(239, 91, 89)
color severeColor = color.rgb(196, 52, 82)
color diversificationColor = color.rgb(0, 177, 166)
color exposureColor = color.rgb(80, 145, 255)
color neutralColor = color.rgb(116, 128, 145)
color warningColor = color.rgb(244, 181, 55)

f_logReturn() =>
    close > 0 and close[1] > 0 ? math.log(close / close[1]) : na

f_corrText(bool enabled, float value) =>
    not enabled ? "OFF" : na(value) ? "NA" : str.tostring(value, "#.00")

f_corrColor(bool enabled, float value) =>
    not enabled or na(value) ? color.new(neutralColor, 78) : color.new(color.from_gradient(value, -1.0, 1.0, concentrationColor, diversificationColor), 18)

float chartReturn = f_logReturn()
float return1 = request.security(symbol1Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float return2 = request.security(symbol2Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float return3 = request.security(symbol3Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float return4 = request.security(symbol4Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float return5 = request.security(symbol5Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float return6 = request.security(symbol6Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float return7 = request.security(symbol7Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float return8 = request.security(symbol8Input, timeframe.period, f_logReturn(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

float chartCorr1Raw = ta.correlation(chartReturn, return1, correlationLengthInput)
float chartCorr2Raw = ta.correlation(chartReturn, return2, correlationLengthInput)
float chartCorr3Raw = ta.correlation(chartReturn, return3, correlationLengthInput)
float chartCorr4Raw = ta.correlation(chartReturn, return4, correlationLengthInput)
float chartCorr5Raw = ta.correlation(chartReturn, return5, correlationLengthInput)
float chartCorr6Raw = ta.correlation(chartReturn, return6, correlationLengthInput)
float chartCorr7Raw = ta.correlation(chartReturn, return7, correlationLengthInput)
float chartCorr8Raw = ta.correlation(chartReturn, return8, correlationLengthInput)

float chartCorr1 = use1Input ? chartCorr1Raw : na
float chartCorr2 = use2Input ? chartCorr2Raw : na
float chartCorr3 = use3Input ? chartCorr3Raw : na
float chartCorr4 = use4Input ? chartCorr4Raw : na
float chartCorr5 = use5Input ? chartCorr5Raw : na
float chartCorr6 = use6Input ? chartCorr6Raw : na
float chartCorr7 = use7Input ? chartCorr7Raw : na
float chartCorr8 = use8Input ? chartCorr8Raw : na

float corr12 = ta.correlation(return1, return2, correlationLengthInput)
float corr13 = ta.correlation(return1, return3, correlationLengthInput)
float corr14 = ta.correlation(return1, return4, correlationLengthInput)
float corr15 = ta.correlation(return1, return5, correlationLengthInput)
float corr16 = ta.correlation(return1, return6, correlationLengthInput)
float corr17 = ta.correlation(return1, return7, correlationLengthInput)
float corr18 = ta.correlation(return1, return8, correlationLengthInput)
float corr23 = ta.correlation(return2, return3, correlationLengthInput)
float corr24 = ta.correlation(return2, return4, correlationLengthInput)
float corr25 = ta.correlation(return2, return5, correlationLengthInput)
float corr26 = ta.correlation(return2, return6, correlationLengthInput)
float corr27 = ta.correlation(return2, return7, correlationLengthInput)
float corr28 = ta.correlation(return2, return8, correlationLengthInput)
float corr34 = ta.correlation(return3, return4, correlationLengthInput)
float corr35 = ta.correlation(return3, return5, correlationLengthInput)
float corr36 = ta.correlation(return3, return6, correlationLengthInput)
float corr37 = ta.correlation(return3, return7, correlationLengthInput)
float corr38 = ta.correlation(return3, return8, correlationLengthInput)
float corr45 = ta.correlation(return4, return5, correlationLengthInput)
float corr46 = ta.correlation(return4, return6, correlationLengthInput)
float corr47 = ta.correlation(return4, return7, correlationLengthInput)
float corr48 = ta.correlation(return4, return8, correlationLengthInput)
float corr56 = ta.correlation(return5, return6, correlationLengthInput)
float corr57 = ta.correlation(return5, return7, correlationLengthInput)
float corr58 = ta.correlation(return5, return8, correlationLengthInput)
float corr67 = ta.correlation(return6, return7, correlationLengthInput)
float corr68 = ta.correlation(return6, return8, correlationLengthInput)
float corr78 = ta.correlation(return7, return8, correlationLengthInput)

array<float> pairCorrelations = array.from(corr12, corr13, corr14, corr15, corr16, corr17, corr18, corr23, corr24, corr25, corr26, corr27, corr28, corr34, corr35, corr36, corr37, corr38, corr45, corr46, corr47, corr48, corr56, corr57, corr58, corr67, corr68, corr78)
array<bool> pairSelections = array.from(use1Input and use2Input, use1Input and use3Input, use1Input and use4Input, use1Input and use5Input, use1Input and use6Input, use1Input and use7Input, use1Input and use8Input, use2Input and use3Input, use2Input and use4Input, use2Input and use5Input, use2Input and use6Input, use2Input and use7Input, use2Input and use8Input, use3Input and use4Input, use3Input and use5Input, use3Input and use6Input, use3Input and use7Input, use3Input and use8Input, use4Input and use5Input, use4Input and use6Input, use4Input and use7Input, use4Input and use8Input, use5Input and use6Input, use5Input and use7Input, use5Input and use8Input, use6Input and use7Input, use6Input and use8Input, use7Input and use8Input)

float pairSum = 0.0
float positivePairSum = 0.0
float squaredPairSum = 0.0
float maximumAbsolutePair = 0.0
int validPairCount = 0
for pairIndex = 0 to array.size(pairCorrelations) - 1
    float pairValue = array.get(pairCorrelations, pairIndex)
    bool pairUsable = array.get(pairSelections, pairIndex) and not na(pairValue)
    if pairUsable
        pairSum += pairValue
        positivePairSum += math.max(pairValue, 0.0)
        squaredPairSum += pairValue * pairValue
        maximumAbsolutePair := math.max(maximumAbsolutePair, math.abs(pairValue))
        validPairCount += 1

array<float> chartCorrelations = array.from(chartCorr1, chartCorr2, chartCorr3, chartCorr4, chartCorr5, chartCorr6, chartCorr7, chartCorr8)
float chartCorrelationSum = 0.0
float chartAbsoluteSum = 0.0
int validChartCorrelationCount = 0
for assetIndex = 0 to array.size(chartCorrelations) - 1
    float chartPairValue = array.get(chartCorrelations, assetIndex)
    if not na(chartPairValue)
        chartCorrelationSum += chartPairValue
        chartAbsoluteSum += math.abs(chartPairValue)
        validChartCorrelationCount += 1

int enabledCount = (use1Input ? 1 : 0) + (use2Input ? 1 : 0) + (use3Input ? 1 : 0) + (use4Input ? 1 : 0) + (use5Input ? 1 : 0) + (use6Input ? 1 : 0) + (use7Input ? 1 : 0) + (use8Input ? 1 : 0)
int expectedPairCount = enabledCount * (enabledCount - 1) / 2
int requiredPairCount = int(math.ceil(expectedPairCount * minimumCoverageInput / 100.0))
float pairCoverage = expectedPairCount > 0 ? validPairCount / expectedPairCount : 0.0
bool pairReady = expectedPairCount > 0 and validPairCount >= math.max(requiredPairCount, 1)
float averagePairCorrelation = pairReady ? pairSum / validPairCount : na
float averagePositivePairCorrelation = pairReady ? positivePairSum / validPairCount : na
float rmsPairCorrelation = pairReady ? math.sqrt(squaredPairSum / validPairCount) : na
float effectiveBreadth = pairReady ? enabledCount / (1.0 + (enabledCount - 1.0) * averagePositivePairCorrelation) : na
float diversificationScore = pairReady and enabledCount > 1 ? 100.0 * (effectiveBreadth - 1.0) / (enabledCount - 1.0) : na
float concentrationPressure = pairReady ? 100.0 * averagePositivePairCorrelation : na
float chartSignedExposure = validChartCorrelationCount > 0 ? 100.0 * chartCorrelationSum / validChartCorrelationCount : na
float chartAbsoluteExposure = validChartCorrelationCount > 0 ? 100.0 * chartAbsoluteSum / validChartCorrelationCount : na
float effectiveSevereThreshold = math.max(severeThresholdInput, concentrationThresholdInput + 1.0)

int STATE_UNAVAILABLE = 0
int STATE_BALANCED = 1
int STATE_DIVERSIFIED = 2
int STATE_CONCENTRATED = 3
int STATE_SEVERE = 4
var int confirmedState = STATE_UNAVAILABLE

if barstate.isconfirmed
    if not pairReady
        confirmedState := STATE_UNAVAILABLE
    else if concentrationPressure >= effectiveSevereThreshold
        confirmedState := STATE_SEVERE
    else if concentrationPressure >= concentrationThresholdInput or ((confirmedState == STATE_CONCENTRATED or confirmedState == STATE_SEVERE) and concentrationPressure >= concentrationThresholdInput - releaseBufferInput)
        confirmedState := STATE_CONCENTRATED
    else if diversificationScore >= diversificationThresholdInput
        confirmedState := STATE_DIVERSIFIED
    else
        confirmedState := STATE_BALANCED

bool concentratedNow = confirmedState == STATE_CONCENTRATED or confirmedState == STATE_SEVERE
bool concentratedBefore = confirmedState[1] == STATE_CONCENTRATED or confirmedState[1] == STATE_SEVERE
bool newConcentration = barstate.isconfirmed and concentratedNow and not concentratedBefore
bool rapidDeclineCandidate = pairReady and not na(diversificationScore[declineLookbackInput]) and diversificationScore[declineLookbackInput] - diversificationScore >= declinePointsInput
bool newRapidDecline = barstate.isconfirmed and rapidDeclineCandidate and not rapidDeclineCandidate[1]

color stateColor = confirmedState == STATE_DIVERSIFIED ? diversificationColor : confirmedState == STATE_CONCENTRATED ? concentrationColor : confirmedState == STATE_SEVERE ? severeColor : confirmedState == STATE_BALANCED ? exposureColor : neutralColor
int fieldTransparency = int(math.round(78.0 - 48.0 * math.min(math.max(pairCoverage, 0.0), 1.0)))

hline(0.0, "Balance Axis", color = color.new(neutralColor, 66), linestyle = hline.style_dotted)
hline(concentrationThresholdInput, "Concentration Threshold", color = color.new(concentrationColor, 70), linestyle = hline.style_dashed)
hline(-diversificationThresholdInput, "Diversification Threshold", color = color.new(diversificationColor, 70), linestyle = hline.style_dashed)
plot(showRiskFieldInput and pairReady ? concentrationPressure : na, "Concentration Pressure", color = color.new(concentrationColor, fieldTransparency), style = plot.style_area, histbase = 0.0, linewidth = 2)
plot(showRiskFieldInput and pairReady ? -diversificationScore : na, "Diversification Reserve", color = color.new(diversificationColor, fieldTransparency), style = plot.style_area, histbase = 0.0, linewidth = 2)
plot(showCorrelationSpineInput and pairReady ? averagePairCorrelation * 100.0 : na, "Pairwise Correlation Spine", color = color.new(warningColor, 0), linewidth = 3)
plot(showChartExposureInput ? chartSignedExposure : na, "Chart-to-Basket Signed Exposure", color = color.new(exposureColor, 6), linewidth = 2)
plot(showChartExposureInput ? chartAbsoluteExposure : na, "Chart-to-Basket Absolute Exposure", color = color.new(exposureColor, 65), linewidth = 1)
plotshape(showMarkersInput and newConcentration ? concentrationPressure : na, title = "Concentration Entry", style = shape.diamond, location = location.absolute, color = concentrationColor, size = size.tiny, text = "C", textcolor = color.white)
plotshape(showMarkersInput and newRapidDecline ? -diversificationScore : na, title = "Rapid Diversification Decline", style = shape.triangledown, location = location.absolute, color = warningColor, size = size.tiny, text = "D", textcolor = color.rgb(40, 46, 56))
bgcolor(showBackgroundInput and confirmedState != STATE_UNAVAILABLE ? color.new(stateColor, 92) : na, title = "Confirmed Exposure State")

alertcondition(newConcentration, "Confirmed Correlation Concentration", "The enabled reference basket entered a confirmed high-correlation concentration state.")
alertcondition(newRapidDecline, "Confirmed Diversification Score Decline", "The effective diversification score fell by the configured number of points over the selected lookback on a confirmed bar.")

string stateText = confirmedState == STATE_DIVERSIFIED ? "DIVERSIFIED" : confirmedState == STATE_CONCENTRATED ? "CONCENTRATED" : confirmedState == STATE_SEVERE ? "SEVERE" : confirmedState == STATE_BALANCED ? "BALANCED" : "UNAVAILABLE"
string coverageText = str.tostring(validPairCount) + " / " + str.tostring(expectedPairCount)
string averageText = pairReady ? str.tostring(averagePairCorrelation, "#.00") : "NA"
string scoreText = pairReady ? str.tostring(diversificationScore, "#.0") : "NA"
string rmsText = pairReady ? str.tostring(rmsPairCorrelation, "#.00") : "NA"
string maximumText = pairReady ? str.tostring(maximumAbsolutePair, "#.00") : "NA"

var table dashboard = table.new(position.top_right, 3, 13, frame_color = color.new(neutralColor, 48), frame_width = 1, border_color = color.new(neutralColor, 76), border_width = 1)
if barstate.islast
    if showDashboardInput
        table.cell(dashboard, 0, 0, "CORRELATION", text_color = color.white, bgcolor = color.new(stateColor, 8), text_size = size.small)
        table.cell(dashboard, 1, 0, stateText, text_color = color.white, bgcolor = color.new(stateColor, 8), text_size = size.small)
        table.cell(dashboard, 2, 0, "vs CHART", text_color = color.white, bgcolor = color.new(stateColor, 8), text_size = size.small)
        table.cell(dashboard, 0, 1, symbol1Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 1, use1Input ? "ON" : "OFF", text_color = use1Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 2, 1, f_corrText(use1Input, chartCorr1), text_color = chart.fg_color, bgcolor = f_corrColor(use1Input, chartCorr1), text_size = size.tiny)
        table.cell(dashboard, 0, 2, symbol2Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 2, use2Input ? "ON" : "OFF", text_color = use2Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 2, 2, f_corrText(use2Input, chartCorr2), text_color = chart.fg_color, bgcolor = f_corrColor(use2Input, chartCorr2), text_size = size.tiny)
        table.cell(dashboard, 0, 3, symbol3Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 3, use3Input ? "ON" : "OFF", text_color = use3Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 2, 3, f_corrText(use3Input, chartCorr3), text_color = chart.fg_color, bgcolor = f_corrColor(use3Input, chartCorr3), text_size = size.tiny)
        table.cell(dashboard, 0, 4, symbol4Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 4, use4Input ? "ON" : "OFF", text_color = use4Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 2, 4, f_corrText(use4Input, chartCorr4), text_color = chart.fg_color, bgcolor = f_corrColor(use4Input, chartCorr4), text_size = size.tiny)
        table.cell(dashboard, 0, 5, symbol5Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 5, use5Input ? "ON" : "OFF", text_color = use5Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 2, 5, f_corrText(use5Input, chartCorr5), text_color = chart.fg_color, bgcolor = f_corrColor(use5Input, chartCorr5), text_size = size.tiny)
        table.cell(dashboard, 0, 6, symbol6Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 6, use6Input ? "ON" : "OFF", text_color = use6Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 2, 6, f_corrText(use6Input, chartCorr6), text_color = chart.fg_color, bgcolor = f_corrColor(use6Input, chartCorr6), text_size = size.tiny)
        table.cell(dashboard, 0, 7, symbol7Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 7, use7Input ? "ON" : "OFF", text_color = use7Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 2, 7, f_corrText(use7Input, chartCorr7), text_color = chart.fg_color, bgcolor = f_corrColor(use7Input, chartCorr7), text_size = size.tiny)
        table.cell(dashboard, 0, 8, symbol8Input, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 8, use8Input ? "ON" : "OFF", text_color = use8Input ? chart.fg_color : neutralColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 2, 8, f_corrText(use8Input, chartCorr8), text_color = chart.fg_color, bgcolor = f_corrColor(use8Input, chartCorr8), text_size = size.tiny)
        table.cell(dashboard, 0, 9, "Pair coverage", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 9, coverageText, text_color = pairReady ? chart.fg_color : warningColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 2, 9, averageText, text_color = warningColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 0, 10, "Diversification", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 10, scoreText, text_color = diversificationColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 2, 10, "score", text_color = neutralColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 0, 11, "RMS / Max", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 11, rmsText, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 2, 11, maximumText, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 0, 12, "Chart exposure", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 12, na(chartSignedExposure) ? "NA" : str.tostring(chartSignedExposure, "#.0"), text_color = exposureColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 2, 12, na(chartAbsoluteExposure) ? "NA" : str.tostring(chartAbsoluteExposure, "#.0"), text_color = exposureColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
    else
        table.clear(dashboard, 0, 0, 2, 12)
````
