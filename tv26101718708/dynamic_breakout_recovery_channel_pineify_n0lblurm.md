# Dynamic Breakout Recovery Channel [Pineify]

- url: https://www.tradingview.com/script/n0LblUrm-Dynamic-Breakout-Recovery-Channel-Pineify/
- type: indicator
- pine_id: PUB;c7a77c8a52e04c6691730bdc3ad71135
- version: 1.0

## Description

[b]Overview[/b]
This Donchian breakout indicator turns each confirmed break into a bounded lifecycle. A state-colored price corridor shows extension, pullback, recovery, failure, or expiry against a frozen event level and ATR.

[b]Problem Definition[/b]
A normal Donchian signal says only that price closed beyond a prior range. It cannot separate useful extension from a marginal break, an orderly retest from churn, or recovery from failure. Because a live channel keeps moving, it also changes the reference used to judge later bars. Similar crossings can therefore hide different paths. This script freezes one baseline and evaluates the sequence after the break.

[b]Design Rationale[/b]
The boundary excludes the current bar, so the breakout cannot raise the level it must cross. ATR is frozen at confirmation; otherwise later volatility would rescale earlier movement. The best confirmed high or low becomes the frontier. Pullback evaluation starts only after minimum extension and retreat, preventing an immediate re-entry from qualifying as recovery. A timer alone was rejected because equal ages can contain direct progress or repeated travel. Time is instead combined with frontier retention, path efficiency, and maximum-retreat resilience.

[b]Key Features[/b]
[list]
[*]Prior-window Donchian breaks filtered by ATR distance.

[*]Frozen boundary and ATR with frontier, retreat, path, and time memory.

[*]Confirmed EXPANSION, PULLBACK, RECOVERED, FAILED, and EXPIRED states.

[*]Optional channel, bar color, markers, and dashboard.
[/list]

[b]How It Works[/b]
The boundaries are the preceding window's highest high and lowest low. After warm-up, a confirmed close must cross by the selected ATR fraction. One lifecycle is active.

Confirmation freezes direction, boundary, ATR, close, and frontier. Later confirmed bars update the frontier and cumulative close travel. Extension is boundary to frontier, retreat is frontier to close, and net distance is boundary to close. All use frozen ATR units. EXPANSION becomes PULLBACK after extension and arm thresholds. An adverse boundary penetration confirms FAILED; a PULLBACK close outside the boundary and near the frontier confirms RECOVERED; maximum age produces EXPIRED.

Expansion opacity follows extension. Pullback opacity blends retained progress, path efficiency, recovery time, and retreat resilience. Terminal states then reset.

[b]How Multiple Indicators Work Together[/b]
The components form one chain. Donchian extremes define the event; frozen ATR supplies one distance unit; the frontier defines achieved progress; retreat and path length describe how progress was surrendered; the clock measures delay. Removing any stage changes the question. The state machine combines them only after prerequisites exist, and the corridor returns the result to price space.

[b]Trading Ideas and Insights[/b]
Use the overlay to compare paths, not as an order instruction. Blue shows confirmed expansion, amber an eligible pullback, teal recovery near the frontier, red failure through the boundary, and purple timeout. Corridor width shows achieved excursion; opacity summarizes path quality. These states can organize continuation, trend-recovery, and failed-breakout review, but do not estimate future return or success probability.

[b]Unique Aspects[/b]
The contribution is event-relative memory. Common breakout channels keep rolling and reduce outcome to above or below a changing band. Here boundary and ATR stay fixed while frontier, deepest confirmed retreat, cumulative path, and recovery duration are retained. Recovery requires an extension-pullback-return sequence. Width, hue, and opacity map to excursion, phase, and quality rather than decoration.

[b]How to Use[/b]
[list=1]
[*]Choose a Donchian lookback matching the structure under review.

[*]Set minimum breakout distance to reject marginal closes.

[*]Tune extension, pullback, recovery, and failure distances together in ATR units across several regimes.

[*]Read the frozen-boundary corridor first; use markers and the dashboard for transition detail.

[*]Configure confirmed breakout, recovery, or failure alerts at the intended frequency.
[/list]

[b]Customization[/b]
Shorter channels create more local events; longer channels select broader breaks. Breakout distance controls initial separation. Extension and pullback-arm settings decide when recovery evaluation begins. Recovery tolerance controls return toward the frontier; failure depth controls boundary penetration. Extension target changes opacity only. Maximum life changes observation scope, while terminal hold changes display duration.

[b]Assumptions and Limitations[/b]
The model assumes OHLC and ATR suit the market and timeframe. It sees bar aggregates, not order flow, liquidity, slippage, or execution. Gaps may cross several thresholds. One event is tracked, so opposite breaks wait for reset. States and alerts confirm at bar close; open-bar dashboard distances and opacity can still vary with the live close.

Donchian and ATR windows add lag and parameter sensitivity. Failure depth may reject normal retests or retain broken structures. Maximum age can expire slow recovery, and low ATR can magnify small moves. States express configured rules, not market truth. No stops, sizing, targets, backtest, profitability evidence, or prediction are supplied.

[b]Conclusion[/b]
A frozen reference makes the post-breakout path auditable. The corridor shows phase, excursion, and recovery quality without claiming predictive performance.

## Source Code

````pine
//@version=6
indicator("Dynamic Breakout Recovery Channel [Pineify]", overlay = true)

string groupDetection = "Breakout Detection"
int channelLengthInput = input.int(20, "Donchian Lookback", minval = 5, maxval = 250, group = groupDetection)
int atrLengthInput = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupDetection)
float minimumBreakoutInput = input.float(0.10, "Minimum Close Beyond Boundary (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = groupDetection)

string groupLifecycle = "Recovery Lifecycle"
float minimumExtensionInput = input.float(0.50, "Minimum Extension Before Recovery (ATR)", minval = 0.10, maxval = 5.0, step = 0.05, group = groupLifecycle)
float pullbackArmInput = input.float(0.45, "Pullback Arm Distance (ATR)", minval = 0.10, maxval = 3.0, step = 0.05, group = groupLifecycle)
float recoveryToleranceInput = input.float(0.18, "Recovery Distance From Frontier (ATR)", minval = 0.0, maxval = 1.5, step = 0.05, group = groupLifecycle)
float failureDepthInput = input.float(0.35, "Failure Depth Through Frozen Boundary (ATR)", minval = 0.05, maxval = 3.0, step = 0.05, group = groupLifecycle)
float extensionTargetInput = input.float(2.0, "Full-Quality Extension (ATR)", minval = 0.25, maxval = 10.0, step = 0.25, group = groupLifecycle)
int maximumLifeInput = input.int(40, "Maximum Lifecycle Bars", minval = 5, maxval = 250, group = groupLifecycle)
int terminalHoldInput = input.int(5, "Terminal State Display Bars", minval = 1, maxval = 25, group = groupLifecycle)

string groupVisuals = "Visual System"
bool showDonchianInput = input.bool(true, "Show Live Donchian Context", group = groupVisuals)
bool showBarColorInput = input.bool(true, "Color Bars During Active Lifecycle", group = groupVisuals)
bool showMarkersInput = input.bool(true, "Show Confirmed Event Markers", group = groupVisuals)
bool showDashboardInput = input.bool(true, "Show Lifecycle Dashboard", group = groupVisuals)

color expansionColor = color.rgb(34, 156, 255)
color pullbackColor = color.rgb(242, 174, 48)
color recoveredColor = color.rgb(0, 181, 148)
color failedColor = color.rgb(235, 82, 93)
color expiredColor = color.rgb(135, 124, 170)
color neutralColor = color.rgb(112, 124, 143)

f_clamp(float value, float lower, float upper) =>
    math.min(math.max(value, lower), upper)

float upperChannel = ta.highest(high, channelLengthInput)[1]
float lowerChannel = ta.lowest(low, channelLengthInput)[1]
float channelMiddle = (upperChannel + lowerChannel) * 0.5
float currentAtr = ta.atr(atrLengthInput)
bool channelReady = not na(upperChannel) and not na(lowerChannel) and not na(currentAtr) and currentAtr > 0.0
bool crossedUpper = channelReady and close > upperChannel and close[1] <= upperChannel[1]
bool crossedLower = channelReady and close < lowerChannel and close[1] >= lowerChannel[1]
bool bullishCandidate = crossedUpper and (close - upperChannel) / currentAtr >= minimumBreakoutInput
bool bearishCandidate = crossedLower and (lowerChannel - close) / currentAtr >= minimumBreakoutInput

var int phase = 0
var int direction = 0
var float frozenBoundary = na
var float frozenAtr = na
var float favorableFrontier = na
var float maximumExtensionAtr = 0.0
var float maximumRetreatAtr = 0.0
var float pathLengthAtr = 0.0
var float previousLifecycleClose = na
var int lifecycleAge = 0
var int pullbackStartAge = na
var int terminalAge = 0

bool breakoutConfirmed = false
bool recoveryConfirmed = false
bool failureConfirmed = false

bool startLifecycle = barstate.isconfirmed and phase == 0 and (bullishCandidate or bearishCandidate)
if startLifecycle
    direction := bullishCandidate ? 1 : -1
    frozenBoundary := direction == 1 ? upperChannel : lowerChannel
    frozenAtr := currentAtr
    favorableFrontier := direction == 1 ? high : low
    maximumExtensionAtr := math.max(direction * (favorableFrontier - frozenBoundary) / frozenAtr, 0.0)
    maximumRetreatAtr := 0.0
    pathLengthAtr := 0.0
    previousLifecycleClose := close
    lifecycleAge := 0
    pullbackStartAge := na
    terminalAge := 0
    phase := 1
    breakoutConfirmed := true
else if barstate.isconfirmed and (phase == 1 or phase == 2)
    lifecycleAge += 1
    pathLengthAtr += math.abs(close - nz(previousLifecycleClose, close)) / frozenAtr
    previousLifecycleClose := close
    favorableFrontier := direction == 1 ? math.max(favorableFrontier, high) : math.min(favorableFrontier, low)
    float extensionNowAtr = math.max(direction * (favorableFrontier - frozenBoundary) / frozenAtr, 0.0)
    float retreatNowAtr = math.max(direction * (favorableFrontier - close) / frozenAtr, 0.0)
    float netNowAtr = direction * (close - frozenBoundary) / frozenAtr
    maximumExtensionAtr := math.max(maximumExtensionAtr, extensionNowAtr)
    maximumRetreatAtr := math.max(maximumRetreatAtr, retreatNowAtr)
    if netNowAtr <= -failureDepthInput
        phase := -1
        terminalAge := 0
        failureConfirmed := true
    else if lifecycleAge >= maximumLifeInput
        phase := 4
        terminalAge := 0
    else if phase == 1 and extensionNowAtr >= minimumExtensionInput and retreatNowAtr >= pullbackArmInput
        phase := 2
        pullbackStartAge := lifecycleAge
    else if phase == 2 and retreatNowAtr <= recoveryToleranceInput and netNowAtr > 0.0
        phase := 3
        terminalAge := 0
        recoveryConfirmed := true
else if barstate.isconfirmed and (phase == 3 or phase == -1 or phase == 4)
    lifecycleAge += 1
    terminalAge += 1
    if terminalAge > terminalHoldInput
        phase := 0
        direction := 0
        frozenBoundary := na
        frozenAtr := na
        favorableFrontier := na
        maximumExtensionAtr := 0.0
        maximumRetreatAtr := 0.0
        pathLengthAtr := 0.0
        previousLifecycleClose := na
        lifecycleAge := 0
        pullbackStartAge := na
        terminalAge := 0

float extensionAtr = phase != 0 and frozenAtr > 0.0 ? math.max(direction * (favorableFrontier - frozenBoundary) / frozenAtr, 0.0) : na
float retreatAtr = phase != 0 and frozenAtr > 0.0 ? math.max(direction * (favorableFrontier - close) / frozenAtr, 0.0) : na
float netDistanceAtr = phase != 0 and frozenAtr > 0.0 ? direction * (close - frozenBoundary) / frozenAtr : na
float pathEfficiency = phase != 0 ? (pathLengthAtr > 0.0 ? math.min(math.abs(netDistanceAtr) / pathLengthAtr, 1.0) : 1.0) : na
float frontierRetention = phase != 0 and maximumExtensionAtr > 0.0 ? f_clamp(netDistanceAtr / maximumExtensionAtr, -1.0, 1.0) : na
float extensionQuality = phase != 0 ? f_clamp(maximumExtensionAtr / extensionTargetInput, 0.0, 1.0) : na
float recoveryAge = phase != 0 and not na(pullbackStartAge) ? float(math.max(lifecycleAge - pullbackStartAge, 0)) : na
float timeQuality = phase != 0 ? 1.0 - f_clamp((na(recoveryAge) ? float(lifecycleAge) : recoveryAge) / float(maximumLifeInput), 0.0, 1.0) : na
float resilienceQuality = phase != 0 and maximumExtensionAtr > 0.0 ? 1.0 - f_clamp(maximumRetreatAtr / (maximumExtensionAtr + failureDepthInput), 0.0, 1.0) : na
float recoveryQuality = phase != 0 ? f_clamp(0.35 * math.max(frontierRetention, 0.0) + 0.25 * pathEfficiency + 0.20 * timeQuality + 0.20 * nz(resilienceQuality, 0.0), 0.0, 1.0) : na
float lifecycleQuality = phase == 1 ? extensionQuality : phase == 2 ? recoveryQuality : phase == 3 ? 1.0 : phase == -1 ? 0.0 : phase == 4 ? 0.25 : 0.0

color phaseColor = phase == 1 ? expansionColor : phase == 2 ? pullbackColor : phase == 3 ? recoveredColor : phase == -1 ? failedColor : phase == 4 ? expiredColor : neutralColor
int corridorTransparency = phase != 0 ? int(math.round(f_clamp(84.0 - 34.0 * lifecycleQuality, 46.0, 86.0))) : 100
float eventBoundaryValue = phase != 0 ? frozenBoundary : na
float eventFrontierValue = phase != 0 ? favorableFrontier : na

plot(showDonchianInput ? upperChannel : na, "Prior Donchian Upper", color = color.new(expansionColor, 72), linewidth = 1)
plot(showDonchianInput ? lowerChannel : na, "Prior Donchian Lower", color = color.new(failedColor, 72), linewidth = 1)
plot(showDonchianInput ? channelMiddle : na, "Prior Donchian Midpoint", color = color.new(neutralColor, 86), linewidth = 1)

eventBoundaryPlot = plot(eventBoundaryValue, "Frozen Breakout Boundary", color = color.new(phaseColor, 8), linewidth = 2, style = plot.style_linebr)
eventFrontierHaloPlot = plot(eventFrontierValue, "Favorable Frontier Halo", color = color.new(phaseColor, 78), linewidth = 7, style = plot.style_linebr)
eventFrontierPlot = plot(eventFrontierValue, "Favorable Frontier", color = phaseColor, linewidth = 2, style = plot.style_linebr)
fill(eventBoundaryPlot, eventFrontierHaloPlot, color = phase != 0 ? color.new(phaseColor, corridorTransparency) : na, title = "Breakout Recovery Corridor")

barcolor(showBarColorInput and phase != 0 ? color.new(phaseColor, 54) : na, title = "Lifecycle Bar Color")

plotshape(showMarkersInput and breakoutConfirmed and direction == 1, title = "Confirmed Bullish Breakout", style = shape.triangleup, location = location.belowbar, color = expansionColor, size = size.tiny, text = "B")
plotshape(showMarkersInput and breakoutConfirmed and direction == -1, title = "Confirmed Bearish Breakout", style = shape.triangledown, location = location.abovebar, color = expansionColor, size = size.tiny, text = "B")
plotshape(showMarkersInput and recoveryConfirmed and direction == 1, title = "Confirmed Bullish Recovery", style = shape.diamond, location = location.belowbar, color = recoveredColor, size = size.tiny, text = "R")
plotshape(showMarkersInput and recoveryConfirmed and direction == -1, title = "Confirmed Bearish Recovery", style = shape.diamond, location = location.abovebar, color = recoveredColor, size = size.tiny, text = "R")
plotshape(showMarkersInput and failureConfirmed and direction == 1, title = "Failed Bullish Breakout", style = shape.xcross, location = location.abovebar, color = failedColor, size = size.tiny, text = "F")
plotshape(showMarkersInput and failureConfirmed and direction == -1, title = "Failed Bearish Breakout", style = shape.xcross, location = location.belowbar, color = failedColor, size = size.tiny, text = "F")

alertcondition(breakoutConfirmed, "Confirmed Channel Breakout", "A close-confirmed Donchian breakout started a new recovery lifecycle on {{ticker}}.")
alertcondition(recoveryConfirmed, "Breakout Recovery Confirmed", "The active breakout recovered to within the configured ATR distance of its favorable frontier on {{ticker}}.")
alertcondition(failureConfirmed, "Breakout Failure Confirmed", "The active breakout closed through its frozen boundary by the configured ATR failure depth on {{ticker}}.")

string phaseName = phase == 1 ? "EXPANSION" : phase == 2 ? "PULLBACK" : phase == 3 ? "RECOVERED" : phase == -1 ? "FAILED" : phase == 4 ? "EXPIRED" : "IDLE"
string directionName = direction == 1 ? "UP" : direction == -1 ? "DOWN" : "--"
f_metric(float value) =>
    na(value) ? "--" : str.tostring(value, "#.00")

var table dashboard = table.new(position.top_right, 2, 7, border_width = 1)
if barstate.islast
    table.clear(dashboard, 0, 0, 1, 6)
    if showDashboardInput
        color headerBackground = color.new(phaseColor, phase == 0 ? 72 : 36)
        color bodyBackground = color.new(chart.bg_color, 8)
        table.cell(dashboard, 0, 0, "RECOVERY CHANNEL", text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(dashboard, 1, 0, phaseName, text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(dashboard, 0, 1, "Direction", text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 1, 1, directionName, text_color = phaseColor, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 0, 2, "Extension ATR", text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 1, 2, f_metric(extensionAtr), text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 0, 3, "Retreat Cur / Max", text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 1, 3, f_metric(retreatAtr) + " / " + f_metric(maximumRetreatAtr), text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 0, 4, "Path Efficiency", text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 1, 4, na(pathEfficiency) ? "--" : str.tostring(pathEfficiency * 100.0, "#") + "%", text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 0, 5, "Age Event / Recovery", text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 1, 5, phase == 0 ? "--" : str.tostring(lifecycleAge) + " / " + (na(recoveryAge) ? "--" : str.tostring(recoveryAge, "#")), text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 0, 6, "Bar State", text_color = chart.fg_color, bgcolor = bodyBackground, text_size = size.tiny)
        table.cell(dashboard, 1, 6, barstate.isconfirmed ? "CLOSED" : "LIVE", text_color = barstate.isconfirmed ? recoveredColor : pullbackColor, bgcolor = bodyBackground, text_size = size.tiny)
````
