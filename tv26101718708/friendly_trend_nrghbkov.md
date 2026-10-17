# Friendly Trend

- url: https://www.tradingview.com/script/NRGHBkov-Friendly-Trend/
- type: indicator
- pine_id: PUB;7ab3fa39e30d44e6b05b3a9a96be9eb6
- version: 1.0

## Description

Friendly Trend is an adaptive trend-state indicator designed to answer two practical questions:
Is the current market structure in a confirmed bullish or bearish state?
Do the selected timeframes support the same directional bias?
The indicator simplifies trend reading without reducing the analysis to a basic moving-average crossover.
It combines directional efficiency, normalized price impulse, adaptive smoothing, volatility-sensitive boundaries, confirmation rules, and multi-timeframe context into one coordinated trend model.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧩 WHAT MAKES FRIENDLY TREND DIFFERENT
Friendly Trend is not a collection of unrelated indicators placed on the same chart.
Every component is part of one connected trend-state engine and has a specific role:
• Directional efficiency determines whether price is moving cleanly in one direction or following a noisy path.
• Normalized impulse measures the direction and strength of recent price movement.
• Adaptive smoothing changes the response speed of the trend basis according to current market conditions.
• The volatility model determines how far price must move before a change can qualify as meaningful.
• Slope, momentum, reversal-buffer, and consecutive-bar conditions confirm a new trend state.
• The multi-timeframe dashboard applies the same complete trend engine independently to each selected timeframe.
• The Overall result converts the individual timeframe states into a weighted directional score.
The script uses established mathematical building blocks such as exponential smoothing, True Range, and absolute price change.
Its original contribution is the way these measurements are connected into one adaptive trend-state architecture rather than used as separate signals or combined into a simple indicator mashup.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 DIRECTIONAL EFFICIENCY
The model compares:
• the net distance price has moved over the selected Length;
• the total path travelled by price during the same period.
A relatively direct move produces a higher efficiency value.
A market that repeatedly moves up and down while making little net progress produces a lower efficiency value.
This measurement helps the trend basis behave differently during:
• clean directional movement;
• noisy consolidation;
• uncertain or transitional conditions.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ NORMALIZED IMPULSE
The script separately calculates directional impulse by comparing:
• smoothed signed price changes;
• smoothed absolute price changes.
The result is normalized around zero:
• positive values indicate upward directional pressure;
• negative values indicate downward directional pressure;
• values close to zero indicate weak or balanced movement.
Impulse performs two functions inside the model:
It helps determine how quickly the adaptive basis should react.
It filters trend changes that are not supported by sufficient directional strength.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 ADAPTIVE TREND BASIS
Friendly Trend calculates a faster and a slower smoothed price estimate.
It then blends them according to the current combination of:
• directional efficiency;
• absolute normalized impulse.
During clean directional movement, the faster estimate receives more influence, allowing the basis to follow price more closely.
During noisy or indecisive conditions, the slower estimate receives more influence, reducing unnecessary reactions to minor price fluctuations.
The result is a basis that adapts its response speed instead of using one fixed smoothing behavior in every market condition.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌊 ADAPTIVE TREND ZONE
The trend zone is not based on a fixed percentage or a single ATR value.
Its width combines:
• smoothed True Range;
• the mean absolute distance between price and the adaptive basis;
• the relationship between short-term and long-term volatility;
• the user-defined Band Multiplier.
The short-term versus long-term volatility ratio allows the zone to:
• expand when current market activity increases;
• contract when conditions become calmer;
• adjust to changing volatility regimes.
The volatility ratio is limited to prevent a single extreme movement from distorting the zone for an unnecessarily long period.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TREND CONFIRMATION
A new bullish state requires all of the following conditions:
• price closes above the upper adaptive boundary;
• the adaptive basis has a positive slope;
• normalized impulse is above the Momentum Filter;
• price clears the additional Reversal Buffer;
• the complete condition remains valid for the selected number of Confirmation Bars.
A bearish state uses the opposite conditions:
• price closes below the lower adaptive boundary;
• the adaptive basis has a negative slope;
• normalized impulse is below the negative Momentum Filter;
• price clears the Reversal Buffer;
• the condition remains valid for the required number of closed bars.
Once a trend is confirmed, the state remains active until the opposite trend passes the same confirmation process.
This persistence is intentional. The trend does not change merely because price returns inside the adaptive zone.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 HOW TO READ THE CHART
🟢 Green basis and green zone
A bullish trend state has been confirmed.
🔴 Red basis and red zone
A bearish trend state has been confirmed.
⚪ Gray basis
The script does not yet have enough confirmed information to assign a bullish or bearish state.
🏷️ Bullish and Bearish labels
A label marks the bar where a new trend state was confirmed.
Labels are not printed on every bar.
The colored zone visualizes the active trend structure. It is not a profit target, stop-loss level, support level, or resistance level.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🕒 MULTI-TIMEFRAME DASHBOARD
The dashboard calculates the complete Friendly Trend engine independently on four configurable timeframes.
The default timeframes are:
• 15 minutes;
• 1 hour;
• 4 hours;
• 1 day.
Each row can display one of three states:
• Bullish
• Bearish
• Neutral
The dashboard does not copy the state of the chart timeframe into the other rows.
Each selected timeframe performs its own calculation using the same adaptive trend model.
Higher-timeframe rows use the state of the most recently completed higher-timeframe bar.
When a selected timeframe is lower than the chart timeframe, the script uses a previously completed lower-timeframe state. This conservative approach introduces a small delay but avoids presenting an unfinished lower-timeframe candle as a confirmed trend.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚖️ OVERALL TREND
The Overall result is not calculated through a simple majority vote.
Each timeframe state is converted into a numerical value:
• Bullish = +1
• Bearish = −1
• Neutral = 0
The values are then weighted according to timeframe duration.
Larger timeframes receive more influence through logarithmic weighting, while smaller timeframes continue to contribute to the result.
The normalized score is classified as:
• Bullish when it is above the Overall Threshold;
• Bearish when it is below the negative Overall Threshold;
• Mixed when it remains between the two thresholds.
This means that two short-term bullish readings do not automatically override bearish conditions on both the 4-hour and daily timeframes.
A Mixed result indicates disagreement or insufficient directional alignment. It is not a separate market direction.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️ HOW TO USE FRIENDLY TREND
Friendly Trend is designed primarily as a directional filter, not as a complete entry system.
One possible workflow is:
1. Identify the broader bias
Use Overall to understand the weighted multi-timeframe direction.
2. Review timeframe alignment
Check the individual dashboard rows to see where agreement or disagreement occurs.
3. Confirm the local trend
Use the trend state on the chart timeframe as the immediate directional context.
4. Apply an independent entry method
Combine the indicator with your own:
• market-structure setup;
• entry conditions;
• stop placement;
• position-sizing rules;
• exit plan.
5. Treat Mixed conditions cautiously
A Mixed result suggests that directional alignment is weak or divided.
Instead of forcing a bullish or bearish interpretation, traders may choose to reduce directional conviction until the timeframes become more aligned.
For example, a trader may prioritize long setups when both the chart state and Overall are Bullish, while avoiding countertrend setups when the higher timeframes remain strongly Bearish.
This is an example of interpretation, not a trading recommendation.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ MAIN SETTINGS
Length
Controls the main observation window used by:
• the directional-efficiency calculation;
• the slower trend basis;
• the long-term volatility model.
Higher values generally produce:
• smoother behavior;
• fewer reactions to short-term changes;
• greater signal delay.
Lower values generally produce:
• faster reactions;
• greater sensitivity to local movement;
• more potential noise.
Band Multiplier
Controls the visible width of the adaptive trend zone.
Higher values:
• require a larger move before the trend can change;
• reduce sensitivity;
• may produce fewer signals.
Lower values:
• make the model more responsive;
• reduce the distance required for a trend change;
• may increase switching during sideways markets.
Confirmation Bars
Defines how many consecutive closed bars must satisfy all trend-change conditions.
A higher value provides stricter confirmation but also delays the signal.
Reversal Buffer
Adds extra distance beyond the displayed adaptive zone before a new trend can be confirmed.
Its purpose is to reduce rapid Bullish and Bearish changes when price repeatedly tests the zone during consolidation.
Momentum Filter
Defines the minimum normalized impulse required for a new trend.
Increasing this value rejects weaker directional moves.
Setting it too high may cause the indicator to miss gradual trends that develop without strong short-term momentum.
Overall Threshold
Controls how much weighted multi-timeframe agreement is required before Overall becomes Bullish or Bearish.
Higher values:
• require stronger agreement;
• produce more Mixed readings.
Lower values:
• classify directional alignment more easily;
• produce Bullish or Bearish results more frequently.
Time Frame 1–4
Define the four periods calculated in the dashboard.
The timeframes can be adjusted to match the user’s trading horizon.
A logical progression from lower to higher periods generally provides the clearest context.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS
The script includes alert conditions for:
• confirmed bullish trend changes on the chart timeframe;
• confirmed bearish trend changes on the chart timeframe;
• any confirmed chart-timeframe trend change;
• bullish and bearish changes for each dashboard timeframe;
• changes of Overall to Bullish;
• changes of Overall to Bearish.
Chart-timeframe trend alerts are based on confirmed bar-close changes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏱️ REAL-TIME AND CONFIRMED-BAR BEHAVIOR
The adaptive basis and visible zone can move while the current price bar is still open because they reflect live market data.
However:
• the chart trend state changes only after the bar is confirmed;
• Bullish and Bearish labels are generated only on confirmed chart bars;
• chart-timeframe trend alerts are based on confirmed state changes;
• higher-timeframe dashboard states use completed higher-timeframe bars;
• lower-timeframe dashboard states are intentionally delayed to avoid using an unfinished lower-timeframe candle as a confirmed signal.
Users should distinguish between:
• the live movement of the adaptive basis and zone;
• a confirmed change of trend state.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS
Friendly Trend does not predict future prices.
Like any trend-following model, it may react with delay after a sudden reversal.
Confirmation Bars, the Reversal Buffer, and the Momentum Filter intentionally exchange some response speed for greater trend stability.
Sideways markets can still produce alternating trend states, especially when using:
• a short Length;
• a narrow trend zone;
• low confirmation requirements.
The indicator does not guarantee exact entries, exits, profits, or a specific win rate.
It should be used together with independent analysis and appropriate risk-management rules.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Friendly Trend
// Original implementation by MarketStructureLab.
//
// © 2026 MarketStructureLab

//@version=6
indicator("Friendly Trend", shorttitle="Friendly Trend", overlay=true, dynamic_requests=true)

//==== INPUTS ===========================================================
groupCalc   = "Main Calculations"
groupTF     = "Extra Timeframes"
groupVisual = "Appearance"

length = input.int(
     70, "Length", minval=10, group=groupCalc,
     tooltip="Main look-back window. Higher values produce a smoother, slower trend. Lower values react faster.",
     display=display.none)

bandMult = input.float(
     1.20, "Band Multiplier", minval=0.10, step=0.05, group=groupCalc,
     tooltip="Controls the width of the adaptive trend zone. Higher values require a larger move before the trend can change.",
     display=display.none)

confirmBars = input.int(
     2, "Confirmation Bars", minval=1, maxval=3, group=groupCalc,
     tooltip="Number of consecutive closes required beyond the adaptive zone before a new trend is confirmed.",
     display=display.none)

reversalBuffer = input.float(
     1.10, "Reversal Buffer", minval=1.00, maxval=1.50, step=0.05, group=groupCalc,
     tooltip="Adds extra distance beyond the adaptive zone before a new trend can be confirmed. Higher values reduce rapid reversals in sideways markets.",
     display=display.none)

signalSensitivity = input.float(
     0.12, "Momentum Filter", minval=0.00, maxval=0.80, step=0.01, group=groupCalc,
     tooltip="Minimum normalized directional momentum required for a trend change. Raise it to filter weak moves.",
     display=display.none)

t1 = input.timeframe("15",  "Time frame 1", group=groupTF, display=display.none)
t2 = input.timeframe("60",  "Time frame 2", group=groupTF, display=display.none)
t3 = input.timeframe("240", "Time frame 3", group=groupTF, display=display.none)
t4 = input.timeframe("1D",  "Time frame 4", group=groupTF, display=display.none)

overallThreshold = input.float(
     0.25, "Overall Threshold", minval=0.05, maxval=0.75, step=0.05, group=groupTF,
     tooltip="Minimum weighted agreement required for the Overall row. Lower values make Bullish/Bearish easier to reach; higher values produce more Mixed readings.",
     display=display.none)

bullColor = input.color(
     #00ffbb, "Bullish / Bearish", inline="cols", group=groupVisual,
     tooltip="Bullish color used for the basis, band, labels and dashboard.",
     display=display.none)

bearColor = input.color(
     #ff1100, "", inline="cols", group=groupVisual,
     tooltip="Bearish color used for the basis, band, labels and dashboard.",
     display=display.none)

showDashboard = input.bool(
     true, "Show Dashboard", group=groupVisual,
     tooltip="Show the multi-timeframe trend table in the top-right corner.",
     display=display.none)

showTrendLabels = input.bool(
     true, "Show Bullish / Bearish Labels", group=groupVisual,
     tooltip="Print a label only when a new trend is confirmed on a closed chart bar.",
     display=display.none)

labelAtrLen = input.int(
     14, "Label ATR Length", minval=1, group=groupVisual, active=showTrendLabels,
     tooltip="ATR length used only to position labels. It does not affect the trend calculation.",
     display=display.none)

bullLabelOffsetAtr = input.float(
     1.05, "Bull / Bear Label Offset (ATR)", minval=0.0, step=0.05,
     inline="lbloff", group=groupVisual, active=showTrendLabels, display=display.none)

bearLabelOffsetAtr = input.float(
     1.05, "", minval=0.0, step=0.05,
     inline="lbloff", group=groupVisual, active=showTrendLabels, display=display.none)

//==== COLORS ===========================================================
bullBasis    = color.new(bullColor, 70)
bearBasis    = color.new(bearColor, 70)
neutralBasis = color.new(#8B93A1, 65)

bullBandLine = color.new(bullColor, 90)
bearBandLine = color.new(bearColor, 90)

tableBg     = color.new(#0F131A, 5)
headerBg    = color.new(#1A1F2B, 0)
leftColBg   = color.new(#11161D, 0)
borderColor = color.new(color.white, 65)
frameColor  = color.new(color.white, 55)

//==== HELPERS ==========================================================
f_clamp(float value, float floorValue, float ceilingValue) =>
    math.min(ceilingValue, math.max(floorValue, value))

f_tfLabel(string tf) =>
    tf == "15" ? "15m" :
     tf == "60" ? "1H" :
     tf == "240" ? "4H" :
     tf == "1D" ? "1D" : tf

f_stateText(int state) =>
    state == 1 ? "Bullish" : state == -1 ? "Bearish" : "Neutral"

f_stateColor(int state) =>
    state == 1 ? color.new(#00C896, 15) :
     state == -1 ? color.new(#E04B52, 15) :
     color.new(#6B7280, 25)

f_overallColor(string state) =>
    state == "Bullish" ? color.new(#00C896, 5) :
     state == "Bearish" ? color.new(#E04B52, 5) :
     color.new(#6B7280, 15)

//==== ORIGINAL FRIENDLY TREND CORE ====================================
f_core() =>
    float source = hlc3

    int fastLength    = math.max(2, int(math.round(length * 0.35)))
    int impulseLength = math.max(3, int(math.round(length * 0.18)))
    int rangeLength   = math.max(5, int(math.round(length * 0.25)))
    int noiseLength   = math.max(3, int(math.round(rangeLength * 0.50)))
    int slopeLookback = math.max(2, int(math.round(length * 0.06)))

    float priceStep = ta.change(source)
    float pathUnit  = math.abs(priceStep)
    float fullPath  = ta.sma(pathUnit, length) * length

    float efficiency = fullPath > 0 and not na(source[length]) ?
         math.abs(source - source[length]) / fullPath : 0.0

    float grossImpulse = ta.ema(pathUnit, impulseLength)
    float netImpulse   = ta.ema(priceStep, impulseLength)
    float impulse      = grossImpulse > 0 ? netImpulse / grossImpulse : 0.0

    float fastBasis = ta.ema(source, fastLength)
    float slowBasis = ta.ema(source, length)
    float blend     = f_clamp(
         0.60 * efficiency + 0.40 * math.abs(impulse),
         0.0,
         1.0)

    float basis = slowBasis + (fastBasis - slowBasis) * blend

    float trueRange     = ta.tr(true)
    float baseRange     = ta.rma(trueRange, rangeLength)
    float meanDeviation = ta.ema(math.abs(source - basis), rangeLength)
    float shortNoise    = ta.ema(trueRange, noiseLength)
    float longNoise     = ta.ema(trueRange, length)

    float regime = longNoise > 0 ?
         f_clamp(shortNoise / longNoise, 0.75, 1.35) :
         1.0

    float band =
         (0.65 * baseRange + 0.35 * meanDeviation) *
         bandMult *
         regime

    float triggerBand = band * reversalBuffer

    bool slopeUp   = basis > basis[slopeLookback]
    bool slopeDown = basis < basis[slopeLookback]

    bool bullishSetup =
         close > basis + triggerBand and
         impulse > signalSensitivity and
         slopeUp

    bool bearishSetup =
         close < basis - triggerBand and
         impulse < -signalSensitivity and
         slopeDown

    bool bullishConfirmed =
         ta.lowest(bullishSetup ? 1.0 : 0.0, confirmBars) == 1.0

    bool bearishConfirmed =
         ta.lowest(bearishSetup ? 1.0 : 0.0, confirmBars) == 1.0

    bool bullishEvent =
         bullishConfirmed and not bullishConfirmed[1]

    bool bearishEvent =
         bearishConfirmed and not bearishConfirmed[1]

    int barsFromBull = ta.barssince(bullishEvent)
    int barsFromBear = ta.barssince(bearishEvent)

    int state =
         na(barsFromBull) and na(barsFromBear) ? 0 :
         na(barsFromBear) ? 1 :
         na(barsFromBull) ? -1 :
         barsFromBull < barsFromBear ? 1 : -1

    [basis, band, impulse, state]

f_engineState() =>
    [_, _, _, state] = f_core()
    state

//==== CONFIRMED MULTI-TIMEFRAME STATE =================================
f_confirmedMtfState(string tf, int confirmedChartState) =>
    float requestedSeconds = timeframe.in_seconds(tf)
    float chartSeconds     = timeframe.in_seconds()

    int result = na

    if requestedSeconds == chartSeconds
        result := confirmedChartState

    else if requestedSeconds < chartSeconds
        result := request.security(
             syminfo.tickerid,
             tf,
             f_engineState()[1],
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_off)

    else
        result := request.security(
             syminfo.tickerid,
             tf,
             f_engineState()[1],
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_on)

    result

f_weight(float tfSeconds, float minimumSeconds) =>
    math.log(1.0 + tfSeconds / minimumSeconds)

//==== CHART-TIMEFRAME CALCULATION =====================================
[basis, band, impulse, liveState] = f_core()

int trendState =
     barstate.isconfirmed ?
     liveState :
     nz(liveState[1], 0)

bool bullishChange =
     barstate.isconfirmed and
     trendState == 1 and
     nz(trendState[1], 0) != 1

bool bearishChange =
     barstate.isconfirmed and
     trendState == -1 and
     nz(trendState[1], 0) != -1

bool anyTrendChange = bullishChange or bearishChange

//==== MULTI-TIMEFRAME STATE ===========================================
int s1 = f_confirmedMtfState(t1, trendState)
int s2 = f_confirmedMtfState(t2, trendState)
int s3 = f_confirmedMtfState(t3, trendState)
int s4 = f_confirmedMtfState(t4, trendState)

float sec1 = timeframe.in_seconds(t1)
float sec2 = timeframe.in_seconds(t2)
float sec3 = timeframe.in_seconds(t3)
float sec4 = timeframe.in_seconds(t4)

float minSeconds =
     math.min(
         math.min(sec1, sec2),
         math.min(sec3, sec4))

float w1 = f_weight(sec1, minSeconds)
float w2 = f_weight(sec2, minSeconds)
float w3 = f_weight(sec3, minSeconds)
float w4 = f_weight(sec4, minSeconds)

float weightTotal = w1 + w2 + w3 + w4

float weightedScore =
     weightTotal > 0 ?
     (
         nz(s1, 0) * w1 +
         nz(s2, 0) * w2 +
         nz(s3, 0) * w3 +
         nz(s4, 0) * w4
     ) / weightTotal :
     0.0

string overall =
     weightedScore >= overallThreshold ? "Bullish" :
     weightedScore <= -overallThreshold ? "Bearish" :
     "Mixed"

//==== VISUAL STATE ====================================================
color basisColor =
     trendState == 1 ? bullBasis :
     trendState == -1 ? bearBasis :
     neutralBasis

float atrForLabels = ta.atr(labelAtrLen)

float bullishLabelY =
     basis -
     band -
     atrForLabels * bullLabelOffsetAtr

float bearishLabelY =
     basis +
     band +
     atrForLabels * bearLabelOffsetAtr

//==== PLOTS ============================================================
basisPlot = plot(
     basis,
     "Adaptive Basis",
     linewidth=2,
     color=basisColor,
     display=display.all - display.status_line)

upperPlot = plot(
     trendState == -1 ? basis + band : na,
     "Bearish Adaptive Band",
     style=plot.style_linebr,
     color=bearBandLine,
     display=display.all - display.status_line)

lowerPlot = plot(
     trendState == 1 ? basis - band : na,
     "Bullish Adaptive Band",
     style=plot.style_linebr,
     color=bullBandLine,
     display=display.all - display.status_line)

fill(
     basisPlot,
     upperPlot,
     color=color.new(bearColor, 82),
     title="Bearish Trend Zone",
     fillgaps=false)

fill(
     basisPlot,
     lowerPlot,
     color=color.new(bullColor, 82),
     title="Bullish Trend Zone",
     fillgaps=false)

plotshape(
     showTrendLabels and bearishChange ? bearishLabelY : na,
     "Bearish Trend",
     style=shape.labeldown,
     location=location.absolute,
     color=bearColor,
     text="Bearish",
     textcolor=color.white,
     size=size.tiny,
     display=display.all - display.status_line)

plotshape(
     showTrendLabels and bullishChange ? bullishLabelY : na,
     "Bullish Trend",
     style=shape.labelup,
     location=location.absolute,
     color=bullColor,
     text="Bullish",
     textcolor=color.black,
     size=size.tiny,
     display=display.all - display.status_line)

//==== ALERTS ===========================================================
alertcondition(
     bullishChange,
     "Bullish Trend",
     "Friendly Trend confirmed a bullish trend on {{ticker}} {{interval}}.")

alertcondition(
     bearishChange,
     "Bearish Trend",
     "Friendly Trend confirmed a bearish trend on {{ticker}} {{interval}}.")

alertcondition(
     anyTrendChange,
     "Trend Change",
     "Friendly Trend confirmed a trend change on {{ticker}} {{interval}}.")

alertcondition(
     s1 == 1 and nz(s1[1], 0) != 1,
     "Bullish Trend Time Frame 1",
     "Friendly Trend turned bullish on Time Frame 1.")

alertcondition(
     s1 == -1 and nz(s1[1], 0) != -1,
     "Bearish Trend Time Frame 1",
     "Friendly Trend turned bearish on Time Frame 1.")

alertcondition(
     s2 == 1 and nz(s2[1], 0) != 1,
     "Bullish Trend Time Frame 2",
     "Friendly Trend turned bullish on Time Frame 2.")

alertcondition(
     s2 == -1 and nz(s2[1], 0) != -1,
     "Bearish Trend Time Frame 2",
     "Friendly Trend turned bearish on Time Frame 2.")

alertcondition(
     s3 == 1 and nz(s3[1], 0) != 1,
     "Bullish Trend Time Frame 3",
     "Friendly Trend turned bullish on Time Frame 3.")

alertcondition(
     s3 == -1 and nz(s3[1], 0) != -1,
     "Bearish Trend Time Frame 3",
     "Friendly Trend turned bearish on Time Frame 3.")

alertcondition(
     s4 == 1 and nz(s4[1], 0) != 1,
     "Bullish Trend Time Frame 4",
     "Friendly Trend turned bullish on Time Frame 4.")

alertcondition(
     s4 == -1 and nz(s4[1], 0) != -1,
     "Bearish Trend Time Frame 4",
     "Friendly Trend turned bearish on Time Frame 4.")

alertcondition(
     overall == "Bullish" and overall[1] != "Bullish",
     "Overall Bullish",
     "Friendly Trend Overall changed to Bullish.")

alertcondition(
     overall == "Bearish" and overall[1] != "Bearish",
     "Overall Bearish",
     "Friendly Trend Overall changed to Bearish.")

//==== DASHBOARD ========================================================
var table dashboard = table.new(
     position.top_right,
     columns=2,
     rows=6,
     bgcolor=tableBg,
     border_width=1,
     border_color=borderColor,
     frame_color=frameColor,
     frame_width=1)

if barstate.islast
    if showDashboard
        table.cell(
             dashboard, 0, 0, "Time Frame",
             text_color=color.white,
             bgcolor=headerBg,
             text_halign=text.align_center)

        table.cell(
             dashboard, 1, 0, "Trend",
             text_color=color.white,
             bgcolor=headerBg,
             text_halign=text.align_center)

        table.cell(
             dashboard, 0, 1, f_tfLabel(t1),
             text_color=color.white,
             bgcolor=leftColBg,
             text_halign=text.align_center)

        table.cell(
             dashboard, 1, 1, f_stateText(s1),
             text_color=color.white,
             bgcolor=f_stateColor(s1),
             text_halign=text.align_center)

        table.cell(
             dashboard, 0, 2, f_tfLabel(t2),
             text_color=color.white,
             bgcolor=leftColBg,
             text_halign=text.align_center)

        table.cell(
             dashboard, 1, 2, f_stateText(s2),
             text_color=color.white,
             bgcolor=f_stateColor(s2),
             text_halign=text.align_center)

        table.cell(
             dashboard, 0, 3, f_tfLabel(t3),
             text_color=color.white,
             bgcolor=leftColBg,
             text_halign=text.align_center)

        table.cell(
             dashboard, 1, 3, f_stateText(s3),
             text_color=color.white,
             bgcolor=f_stateColor(s3),
             text_halign=text.align_center)

        table.cell(
             dashboard, 0, 4, f_tfLabel(t4),
             text_color=color.white,
             bgcolor=leftColBg,
             text_halign=text.align_center)

        table.cell(
             dashboard, 1, 4, f_stateText(s4),
             text_color=color.white,
             bgcolor=f_stateColor(s4),
             text_halign=text.align_center)

        table.cell(
             dashboard, 0, 5, "Overall",
             text_color=color.white,
             bgcolor=headerBg,
             text_halign=text.align_center)

        table.cell(
             dashboard, 1, 5, overall,
             text_color=color.white,
             bgcolor=f_overallColor(overall),
             text_halign=text.align_center)

    else
        table.clear(dashboard, 0, 0, 1, 5)

//==== USAGE NOTES ======================================================
//
// Friendly Trend uses an original adaptive trend model:
//
// 1. Directional efficiency measures how much net movement occurred relative
//    to the full price path over the selected Length.
//
// 2. Normalized impulse compares directional movement with total movement.
//
// 3. The basis blends a fast and slow price estimate according to the current
//    efficiency and impulse. It reacts faster in clean directional movement
//    and remains smoother when price action is noisy.
//
// 4. The adaptive zone combines smoothed True Range and the mean absolute
//    distance from price to the basis. A short/long volatility ratio expands
//    or contracts the zone as the market regime changes.
//
// 5. A trend changes only after price closes outside the zone, the basis slope
//    agrees with the move, momentum passes the filter, price clears the
//    Reversal Buffer, and the condition lasts for the selected number of
//    Confirmation Bars.
//
// 6. Chart labels and chart-timeframe alerts are confirmed only at bar close.
//    Higher-timeframe dashboard values use the previous completed HTF bar.
//    Lower-timeframe rows use the previous state of the last available
//    intrabar so an unfinished lower-timeframe candle cannot change the table.
//
// 7. Overall is a duration-weighted score. Larger timeframes receive more
//    influence through a logarithmic weight, while Neutral values reduce
//    agreement rather than being counted as bearish.
//
// This indicator is a trend filter, not a complete trading system.
// It does not predict future prices and should be combined with independent
// entry, exit and risk-management rules.
````
