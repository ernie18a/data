# Trend Volatility State Engine [Pineify]

- url: https://www.tradingview.com/script/0DGERJtx-Trend-Volatility-State-Engine-Pineify/
- type: indicator
- pine_id: PUB;a6f33cc3979d448fbd7a1170e86437dd
- version: 1.0

## Description

[b]Overview[/b]
Trend Volatility State Engine keeps direction and volatility on separate axes. Spine, ATR-percentile envelope, quadrants, and age rail describe structure, movement scale, regime, and persistence without forecasting.

[b]Problem Definition[/b]
A trend label cannot separate orderly drift from unstable expansion; volatility alone cannot show whether wide ranges retain direction. Raw slope and ATR thresholds also vary by instrument. Equal trend readings can occur at unlike volatility levels, while equal ATR can represent efficient travel or balanced noise. A blended score hides which input changed, so this indicator preserves both dimensions.

[b]Design Rationale[/b]
Direction uses regression slope normalized by ATR to remove price-scale dependence. Endpoint displacement divided by total close travel reduces the score when a fitted line masks reversals; disagreement between fitted and endpoint direction adds a penalty. Volatility is the percentile rank of ATR as a percentage of price, replacing a universal cutoff with a relative comparison. Entry/release hysteresis explains persistence but delays exits.

[b]Key Features[/b]
[list]
[*]Signed strength joins normalized slope, path efficiency, and direction agreement.
[*]ATR percentile remains an independent axis.
[*]Confirmed hysteresis creates four states and age.
[*]Optional layers encode separate facts.
[/list]

[b]How It Works[/b]
ATR divided by absolute price is ranked inside the selected history; 100 means high relative to that sample. After both windows warm up, adjacent regression estimates produce slope. Slope times window span divided by ATR becomes volatility-unit displacement, then a bounded transform limits extremes. Endpoint displacement divided by summed close travel supplies path efficiency. Bounded slope is weighted by efficiency, with lower weight when slope and endpoint directions disagree.

On confirmed bars, one latch enters trend mode above its entry threshold and exits below its release threshold. A second latch applies the rule to high ATR percentile. Their combinations are Quiet Balance, Quiet Trend, Volatile Balance, and Volatile Trend. Age resets on change, then increments. Spine shows strength, gold envelope shows percentile, background shows state, and the floor rail shows capped age. Spine and envelope can move on an open bar, while state, age, markers, and alerts wait for close.

[b]How Multiple Indicators Work Together[/b]
Regression supplies direction but misses an inefficient zigzag. Path efficiency supplies quality but lacks volatility context. ATR normalization makes slope relative to recent movement; ATR percentile locates that movement in history. Hysteresis converts both axes into states. Omitting one link either overstates noise, removes direction or context, or causes chatter.

[b]Trading Ideas and Insights[/b]
Use the engine as context, not a trade command. Quiet Trend describes controlled travel; Volatile Trend adds wider movement. Volatile Balance marks large movement without retained direction; Quiet Balance marks restrained, inefficient travel. A change can prompt review of risk and setup assumptions. Age measures persistence, not continuation probability.

[b]Unique Aspects[/b]
The contribution is an orthogonal state engine, not a moving average recolored by ATR. Signed regression pressure and relative volatility stay independent, while efficiency and agreement govern trend evidence. Two confirmed latches create an auditable quadrant history plus age. Visual roles follow the model: direction uses the spine, volatility the envelope, quadrant the background, and persistence the rail.

[b]How to Use[/b]
Begin with defaults and observe complete rank windows. Read spine sign and distance from zero, then envelope width and quadrant. Markers show close-confirmed changes. The dashboard reveals whether trend evidence includes path efficiency or mainly fitted slope. Match settings and alerts to the symbol and timeframe.

[b]Customization[/b]
Trend Window controls regression and efficiency; shorter values react faster but admit local reversals. ATR Length sets the movement unit. Rank Lookback sets the comparison sample; shorter samples adapt faster but make ranks less stable. Entry thresholds demand evidence; release thresholds control tolerated weakening, with enforced separation if they conflict. Duration Alert Bars sets the event; Display Scale changes only the rail. Visual switches do not alter logic.

[b]Assumptions and Limitations[/b]
The model needs meaningful OHLC data and sufficient history. ATR percentile is relative to symbol, timeframe, feed, and lookback, not universal risk. Regression can lag turns; close-path efficiency ignores intrabar sequence; gaps can dominate both. The agreement penalty is a design rule, not probability. Hysteresis reduces chatter but delays exits. Raw values can change on the open bar; states and events are confirmed. Context changes recalculate windows. Future bars are not used, but open values are not fixed. Liquidity, volume, costs, fundamentals, expected return, and trade suitability are outside scope.

[b]Conclusion[/b]
The engine separates direction quality, relative volatility, confirmed regime, and persistence so each claim stays inspectable. Use the quadrants as descriptive context and keep risk and execution decisions outside the indicator.

## Source Code

````pine
//@version=6
indicator("Trend Volatility State Engine [Pineify]", overlay = false)

string groupModel = "State Model"
int trendLengthInput = input.int(34, "Trend Window", minval = 10, maxval = 300, group = groupModel)
int atrLengthInput = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupModel)
int volatilityRankLookbackInput = input.int(120, "Volatility Rank Lookback", minval = 40, maxval = 500, group = groupModel)
float trendEnterInput = input.float(30.0, "Trend Entry Strength", minval = 10.0, maxval = 80.0, step = 1.0, group = groupModel)
float trendReleaseInput = input.float(22.0, "Trend Release Strength", minval = 5.0, maxval = 70.0, step = 1.0, group = groupModel)
float volatilityEnterInput = input.float(65.0, "High Volatility Entry Percentile", minval = 40.0, maxval = 95.0, step = 1.0, group = groupModel)
float volatilityReleaseInput = input.float(55.0, "High Volatility Release Percentile", minval = 20.0, maxval = 90.0, step = 1.0, group = groupModel)
int durationAlertBarsInput = input.int(12, "State Duration Alert Bars", minval = 2, maxval = 200, group = groupModel)
int durationScaleInput = input.int(40, "Duration Display Scale", minval = 10, maxval = 200, group = groupModel)

string groupVisual = "Visual System"
bool showEnvelopeInput = input.bool(true, "Show Volatility Energy Envelope", group = groupVisual)
bool showDurationInput = input.bool(true, "Show State Duration Rail", group = groupVisual)
bool showPaneBackgroundInput = input.bool(true, "Show Quadrant Background", group = groupVisual)
bool showChartBackgroundInput = input.bool(false, "Show State Wash on Main Chart", group = groupVisual)
bool showMarkersInput = input.bool(true, "Show Confirmed State Changes", group = groupVisual)
bool showDashboardInput = input.bool(true, "Show State Dashboard", group = groupVisual)

color bullishColor = color.rgb(0, 178, 166)
color bearishColor = color.rgb(238, 86, 92)
color volatilityColor = color.rgb(244, 181, 55)
color quietColor = color.rgb(92, 112, 138)
color balanceColor = color.rgb(91, 143, 249)
color volatileTrendColor = color.rgb(167, 107, 224)
color unavailableColor = color.rgb(118, 126, 140)

f_stateName(int state) =>
    state == 1 ? "Quiet Balance" : state == 2 ? "Quiet Trend" : state == 3 ? "Volatile Balance" : state == 4 ? "Volatile Trend" : "Warming"

float atrValue = ta.atr(atrLengthInput)
float atrPercent = close != 0.0 ? 100.0 * atrValue / math.abs(close) : na
float volatilityRank = ta.percentrank(atrPercent, volatilityRankLookbackInput)

float regressionNow = ta.linreg(close, trendLengthInput, 0)
float regressionPrevious = ta.linreg(close, trendLengthInput, 1)
float regressionSlope = regressionNow - regressionPrevious
float slopeDistanceInAtr = atrValue > 0.0 ? regressionSlope * (trendLengthInput - 1.0) / atrValue : na
float boundedSlope = not na(slopeDistanceInAtr) ? 100.0 * slopeDistanceInAtr / (1.0 + math.abs(slopeDistanceInAtr)) : na

float pathStep = math.abs(close - close[1])
float pathLength = math.sum(pathStep, trendLengthInput)
float netDisplacement = close - close[trendLengthInput]
float directionEfficiency = pathLength > syminfo.mintick ? math.min(math.abs(netDisplacement) / pathLength, 1.0) : na
bool directionAgreement = not na(regressionSlope) and not na(netDisplacement) and math.sign(regressionSlope) == math.sign(netDisplacement)
float agreementWeight = directionAgreement ? 1.0 : 0.45
float trendStrength = not na(boundedSlope) and not na(directionEfficiency) ? boundedSlope * (0.35 + 0.65 * directionEfficiency) * agreementWeight : na
float absoluteTrendStrength = math.abs(trendStrength)

float effectiveTrendEntry = math.max(trendEnterInput, trendReleaseInput + 1.0)
float effectiveVolatilityEntry = math.max(volatilityEnterInput, volatilityReleaseInput + 1.0)
bool sampleReady = not na(trendStrength) and not na(volatilityRank) and pathLength > syminfo.mintick

int STATE_UNAVAILABLE = 0
int STATE_QUIET_BALANCE = 1
int STATE_QUIET_TREND = 2
int STATE_VOLATILE_BALANCE = 3
int STATE_VOLATILE_TREND = 4

var bool confirmedTrendMode = false
var bool confirmedHighVolatilityMode = false
var int confirmedState = STATE_UNAVAILABLE
var int confirmedStateAge = 0

if barstate.isconfirmed
    if not sampleReady
        confirmedTrendMode := false
        confirmedHighVolatilityMode := false
        confirmedState := STATE_UNAVAILABLE
        confirmedStateAge := 0
    else
        confirmedTrendMode := confirmedTrendMode ? absoluteTrendStrength >= trendReleaseInput : absoluteTrendStrength >= effectiveTrendEntry
        confirmedHighVolatilityMode := confirmedHighVolatilityMode ? volatilityRank >= volatilityReleaseInput : volatilityRank >= effectiveVolatilityEntry
        int nextState = confirmedHighVolatilityMode ? (confirmedTrendMode ? STATE_VOLATILE_TREND : STATE_VOLATILE_BALANCE) : (confirmedTrendMode ? STATE_QUIET_TREND : STATE_QUIET_BALANCE)
        confirmedStateAge := nextState == confirmedState ? confirmedStateAge + 1 : 1
        confirmedState := nextState

bool trendQuadrant = confirmedState == STATE_QUIET_TREND or confirmedState == STATE_VOLATILE_TREND
bool highVolatilityQuadrant = confirmedState == STATE_VOLATILE_BALANCE or confirmedState == STATE_VOLATILE_TREND
bool bullishDirection = trendStrength >= 0.0
color directionColor = color.from_gradient(trendStrength, -100.0, 100.0, bearishColor, bullishColor)
color stateColor = confirmedState == STATE_QUIET_BALANCE ? quietColor : confirmedState == STATE_QUIET_TREND ? balanceColor : confirmedState == STATE_VOLATILE_BALANCE ? volatilityColor : confirmedState == STATE_VOLATILE_TREND ? volatileTrendColor : unavailableColor

float envelopeRadius = sampleReady ? 4.0 + 20.0 * volatilityRank / 100.0 : na
float envelopeUpper = sampleReady ? math.min(trendStrength + envelopeRadius, 120.0) : na
float envelopeLower = sampleReady ? math.max(trendStrength - envelopeRadius, -120.0) : na
int envelopeTransparency = sampleReady ? int(math.round(90.0 - 38.0 * volatilityRank / 100.0)) : 90
float durationFraction = math.min(confirmedStateAge / float(durationScaleInput), 1.0)
float durationRail = sampleReady ? -116.0 + 20.0 * durationFraction : na

bool stateChanged = barstate.isconfirmed and sampleReady and confirmedState[1] != STATE_UNAVAILABLE and confirmedState != confirmedState[1]
bool durationReached = barstate.isconfirmed and sampleReady and confirmedStateAge == durationAlertBarsInput

hline(0.0, "Direction Axis", color = color.new(quietColor, 58), linestyle = hline.style_dotted)
hline(100.0, "Upper Bound", color = color.new(quietColor, 82))
hline(-100.0, "Lower Bound", color = color.new(quietColor, 82))
hline(effectiveTrendEntry, "Bull Trend Entry", color = color.new(bullishColor, 76), linestyle = hline.style_dashed)
hline(-effectiveTrendEntry, "Bear Trend Entry", color = color.new(bearishColor, 76), linestyle = hline.style_dashed)

trendPlot = plot(sampleReady ? trendStrength : na, "Directional Strength Spine", color = directionColor, linewidth = 3)
upperEnvelopePlot = plot(showEnvelopeInput ? envelopeUpper : na, "Volatility Envelope Upper", color = color.new(volatilityColor, 82), linewidth = 1)
lowerEnvelopePlot = plot(showEnvelopeInput ? envelopeLower : na, "Volatility Envelope Lower", color = color.new(volatilityColor, 82), linewidth = 1)
fill(upperEnvelopePlot, lowerEnvelopePlot, color = showEnvelopeInput ? color.new(volatilityColor, envelopeTransparency) : na, title = "Volatility Energy Envelope")
plot(showDurationInput ? durationRail : na, "Confirmed State Duration", color = color.new(stateColor, 32), linewidth = 4, style = plot.style_columns, histbase = -116.0)

bgcolor(showPaneBackgroundInput and sampleReady ? color.new(stateColor, 90) : na, title = "Confirmed Quadrant Background")
bgcolor(showChartBackgroundInput and sampleReady ? color.new(stateColor, 94) : na, title = "Main Chart State Wash", force_overlay = true)
plotshape(showMarkersInput and stateChanged and bullishDirection, title = "Confirmed Bullish State Change", style = shape.triangleup, location = location.bottom, color = color.new(bullishColor, 0), size = size.tiny, text = "Q")
plotshape(showMarkersInput and stateChanged and not bullishDirection, title = "Confirmed Bearish State Change", style = shape.triangledown, location = location.top, color = color.new(bearishColor, 0), size = size.tiny, text = "Q")

alertcondition(stateChanged, "Confirmed Quadrant Change", "Trend Volatility State Engine confirmed a new trend-volatility quadrant.")
alertcondition(durationReached, "Confirmed State Duration Reached", "Trend Volatility State Engine confirmed that the current quadrant reached the configured duration.")

var table dashboard = table.new(position.top_right, 2, 6, border_width = 1)
if barstate.islast
    if showDashboardInput
        string directionText = not sampleReady ? "NA" : trendQuadrant ? (bullishDirection ? "Bullish" : "Bearish") : "Balanced"
        string trendText = sampleReady ? str.tostring(trendStrength, "#.0") : "NA"
        string volatilityText = sampleReady ? str.tostring(volatilityRank, "#.0") + "%" : "NA"
        string efficiencyText = sampleReady ? str.tostring(directionEfficiency * 100.0, "#.0") + "%" : "NA"
        table.cell(dashboard, 0, 0, "STATE ENGINE", text_color = chart.fg_color, bgcolor = color.new(stateColor, 42), text_size = size.small)
        table.cell(dashboard, 1, 0, f_stateName(confirmedState), text_color = chart.fg_color, bgcolor = color.new(stateColor, 42), text_size = size.small)
        table.cell(dashboard, 0, 1, "Direction", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 1, directionText, text_color = directionColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 0, 2, "Trend strength", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 2, trendText, text_color = directionColor, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 0, 3, "Volatility rank", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 3, volatilityText, text_color = volatilityColor, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 0, 4, "Efficiency", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 1, 4, efficiencyText, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 16), text_size = size.tiny)
        table.cell(dashboard, 0, 5, "Confirmed age", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(dashboard, 1, 5, sampleReady ? str.tostring(confirmedStateAge) + " bars" : "Warming", text_color = highVolatilityQuadrant ? volatilityColor : chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
    else
        table.clear(dashboard, 0, 0, 1, 5)
````
