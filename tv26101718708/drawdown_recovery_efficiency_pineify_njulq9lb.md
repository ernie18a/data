# Drawdown Recovery Efficiency [Pineify]

- url: https://www.tradingview.com/script/NjulQ9lB-Drawdown-Recovery-Efficiency-Pineify/
- type: indicator
- pine_id: PUB;915f9406da554717b658be34cb1f9b1e
- version: 1.0

## Description

[b]Overview[/b]
Drawdown Recovery Efficiency separates distance below a closing peak from the quality of the path back toward it. The underwater field compares rolling and frozen anchors; upper columns show recovery quality from 0 to 100.

[b]Problem Definition[/b]
The same drawdown percentage can describe a quick rebound or a long, indecisive loss. When an old high leaves a rolling window, drawdown can shrink even if price is flat. A depth-only chart can therefore confuse reference expiry with economic recovery. This script requires price to reclaim a retained peak before ending an observed underwater episode.

[b]Design Rationale[/b]
The rolling peak preserves familiar finite-window context, while freezing the episode anchor prevents expiry from manufacturing a recovery. A recent ATR-normalized slope measures speed; net upward movement divided by absolute travel discounts zigzag paths. Reclaimed distance and an age penalty constrain those inputs to the actual loss episode. A sum was rejected because speed could compensate for no progress. Multiplication can suppress slow but valid rebounds. Entry and half-entry exit thresholds reduce phase flicker.

[b]Key Features[/b]
The pane shows episode depth, optional rolling depth and violet expiry gap, recovery columns and an entry threshold. The optional table reports raw loss, age, reclaim, slope and anchor. D, R and P mark confirmed deep loss, recovery entry and peak reclaim.

[b]How It Works[/b]
The reference is the highest close over the peak window. After full valid coverage, the first underwater close freezes it. Confirmed closes update the trough and age; only a close reaching the anchor ends the episode.
Recovery slope is recent net price rise divided by path length and previous-bar ATR. Upward path efficiency is positive net rise divided by summed absolute close changes. Reclaim is distance above the episode trough divided by anchor-to-trough loss. Duration weight is 1 / (1 + underwater bars / duration setting).
Score is 100 times capped positive slope credit, path efficiency, reclaim and age weight. Credit starts only after the full path lies inside the observed episode. New troughs or slope below -0.02 ATR/bar imply declining; sufficient positive score and reclaim imply recovering; other underwater observations imply basing. Rolling-peak expiry never clears the anchor.
Depth lanes are -100 times drawdown divided by the deep threshold, clipped at -100; raw percentages remain in the table and Data Window. Missing or invalid OHLC, nonpositive closes or unusable ATR hide outputs and reset episode memory.

[b]How Multiple Indicators Work Together[/b]
These components describe one recovery process. Depth establishes the loss, the frozen anchor defines genuine progress, slope measures its pace, and path efficiency distinguishes directed advance from churn. Reclaim prevents a fast but tiny bounce from earning full credit; duration reduces credit for prolonged underwater residence. Removing the anchor would reintroduce expiry-based false recovery.

[b]Trading Ideas and Insights[/b]
A rising rolling line beside a flat episode line can indicate reference expiry rather than buying progress. Rising score and a recovering phase identify a stronger observed path, while falling score can expose churn before full depth recovery. Compare these readings with independent market context; a deep-loss event or recovery entry is not a trade instruction.

[b]Unique Aspects[/b]
Relative to a conventional rolling drawdown curve, the structural addition is retained episode memory plus a conjunctive recovery score. A disappearing rolling high can improve the baseline curve while the anchor, age and phase remain unresolved. The ribbon exposes expiry; true reclaim is independent of the rolling denominator.

[b]How to Use[/b]
Use standard OHLC charts, initially on 1H-1W timeframes. Read the lower basin as normalized loss and the upper columns as recovery quality. Check raw percentage and duration in the table before interpreting a clipped basin. The displayed phase is confirmed; live values may differ. Configure the three alerts for once per bar close.

[b]Customization[/b]
Defaults of 252 peak bars, 8 path bars and 14 ATR bars are starting points. Longer peaks retain context; shorter paths react sooner with more noise. Deep-loss threshold controls both the depth alert and lane scaling. The 50-bar duration setting halves age weight at 50 bars. Full-slope credit, entry score and minimum reclaim tune recovery requirements. Rolling comparison, background, markers and table can be switched separately.

[b]Assumptions and Limitations[/b]
This measures instrument price drawdown, not account equity or total return including dividends. It uses closing peaks, so intrabar extremes are excluded. ATR and path windows introduce lag; settings and timeframe change the result. Very old episodes may never reach the recovery entry score before reclaim. After loading or reset, age starts at the first valid observed episode and can understate an existing loss. Raw values and columns change intrabar; memory, phases and alerts update only on confirmed closes. Depth clipping conceals additional visual magnitude, and synthetic charts or adjusted history can alter interpretation.

[b]Conclusion[/b]
Use the retained anchor to distinguish a return toward a peak from rolling-reference expiry. Recovery efficiency summarizes observed pace, direction, progress and time cost; it provides no forecast, execution rule or performance guarantee.

## Source Code

````pine
//@version=6
indicator("Drawdown Recovery Efficiency [Pineify]", shorttitle = "DRE [Pineify]", overlay = false, precision = 1, max_bars_back = 1500)

// Independently implemented. Rolling reference expiry is separated from price recovery.
// Depth below zero and recovery quality above zero use separate, explicitly normalized lanes.
string groupModel = "Recovery model"
int peakLength = input.int(252, "Rolling closing-peak window", minval = 20, maxval = 1000, group = groupModel)
int slopeLength = input.int(8, "Recovery path window", minval = 2, maxval = 50, group = groupModel)
int atrLength = input.int(14, "ATR normalization window", minval = 2, maxval = 100, group = groupModel)
float deepPercent = input.float(8.0, "Deep drawdown threshold (%)", minval = 0.1, maxval = 80.0, step = 0.1, group = groupModel)
int durationScale = input.int(50, "Underwater duration half-weight (bars)", minval = 5, maxval = 500, group = groupModel)
float fullSlope = input.float(0.25, "Full slope credit (ATR per bar)", minval = 0.01, maxval = 5.0, step = 0.01, group = groupModel)
float entryScore = input.float(10.0, "Recovery entry score", minval = 1.0, maxval = 80.0, step = 1.0, group = groupModel)
float minimumReclaim = input.float(0.10, "Minimum trough-to-anchor reclaim", minval = 0.0, maxval = 0.9, step = 0.05, group = groupModel)
string groupVisual = "Visual layers"
bool showRolling = input.bool(true, "Rolling reference and expiry gap", group = groupVisual)
bool showBackground = input.bool(false, "Confirmed phase background", group = groupVisual)
bool showMarkers = input.bool(true, "Confirmed event markers", group = groupVisual)
bool showTable = input.bool(true, "Recovery summary", group = groupVisual)

clamp01(float value) =>
    math.max(0.0, math.min(1.0, value))

phaseName(int value) =>
    switch value
        0 => "At peak"
        1 => "Declining"
        2 => "Basing"
        3 => "Recovering"
        => "Warming / invalid"

color declineColor = #C65332
color baseColor = #6572B8
color recoveryColor = #008F83
color expiryColor = #9965BE
color neutralColor = chart.fg_color
float tolerance = syminfo.mintick * 0.5
float rollingPeak = ta.highest(close, peakLength)
float priorAtr = ta.atr(atrLength)[1]
bool sampleOk = not na(close) and not na(high) and not na(low) and close > 0.0 and high >= low and close >= low and close <= high
int requiredSamples = math.max(peakLength, math.max(atrLength + 1, slopeLength + 1))
float sampleCoverage = math.sum(sampleOk ? 1.0 : 0.0, requiredSamples)
bool dataReady = bar_index >= requiredSamples and sampleCoverage == requiredSamples and not na(priorAtr) and priorAtr > 0.0 and not na(rollingPeak) and rollingPeak > 0.0

// Only confirmed bars write episode memory. A frozen anchor survives rolling-peak expiry.
var bool active = false
var float anchor = na
var float trough = na
var int underwaterBars = 0
var int phase = -1
var bool deepRecorded = false

bool reclaimed = dataReady and active and close >= anchor - tolerance
bool rollingUnderwater = dataReady and close < rollingPeak - tolerance
bool observing = dataReady and not reclaimed and (active or rollingUnderwater)
float viewAnchor = observing and active ? anchor : rollingPeak
float viewTrough = observing ? (active ? math.min(trough, close) : close) : close
int viewAge = observing ? (active ? underwaterBars + 1 : 1) : 0
float rollingDepth = dataReady ? math.max(0.0, 100.0 * (rollingPeak - close) / rollingPeak) : na
float episodeDepth = dataReady ? (observing ? math.max(0.0, 100.0 * (viewAnchor - close) / viewAnchor) : 0.0) : na
float lostDistance = observing ? math.max(viewAnchor - viewTrough, syminfo.mintick) : syminfo.mintick
float reclaimFraction = observing ? clamp01((close - viewTrough) / lostDistance) : 0.0

// A complete short path must fall inside the observed episode before earning recovery credit.
float netMove = close - close[slopeLength]
float absolutePath = math.sum(math.abs(ta.change(close)), slopeLength)
float normalizedSlope = dataReady ? netMove / (slopeLength * priorAtr) : na
float upwardEfficiency = not na(absolutePath) and absolutePath > 0.0 ? clamp01(netMove / absolutePath) : 0.0
float durationWeight = 1.0 / (1.0 + viewAge / float(durationScale))
bool pathMature = observing and viewAge > slopeLength
float slopeCredit = dataReady ? clamp01(normalizedSlope / fullSlope) : 0.0
float recoveryScore = dataReady ? (pathMature ? 100.0 * slopeCredit * upwardEfficiency * reclaimFraction * durationWeight : 0.0) : na
bool newTrough = observing and active and close < trough - tolerance
bool anchorExpired = observing and viewAnchor > rollingPeak + tolerance

int candidatePhase = -1
if dataReady
    if not observing
        candidatePhase := 0
    else if newTrough or normalizedSlope < -0.02
        candidatePhase := 1
    else if pathMature and reclaimFraction >= minimumReclaim and normalizedSlope > 0.0 and recoveryScore >= (phase == 3 ? entryScore * 0.5 : entryScore)
        candidatePhase := 3
    else
        candidatePhase := 2

bool deepEvent = false
bool recoveryEvent = false
bool reclaimEvent = false
if barstate.isconfirmed
    if not dataReady
        active := false
        anchor := na
        trough := na
        underwaterBars := 0
        deepRecorded := false
        phase := -1
    else
        deepEvent := observing and episodeDepth >= deepPercent and not deepRecorded
        recoveryEvent := observing and candidatePhase == 3 and phase != 3
        reclaimEvent := reclaimed
        phase := candidatePhase
        if observing
            active := true
            anchor := viewAnchor
            trough := viewTrough
            underwaterBars := viewAge
            deepRecorded := deepRecorded or deepEvent
        else
            active := false
            anchor := na
            trough := na
            underwaterBars := 0
            deepRecorded := false

// Core visual: a persistent underwater basin, with quality columns rising above equilibrium.
color phaseColor = phase == 1 ? declineColor : phase == 2 ? baseColor : phase == 3 ? recoveryColor : neutralColor
float episodeLane = dataReady ? -100.0 * clamp01(episodeDepth / deepPercent) : na
float rollingLane = dataReady ? -100.0 * clamp01(rollingDepth / deepPercent) : na
zeroPlot = plot(dataReady ? 0.0 : na, "Equilibrium", color = color.new(neutralColor, 55), linewidth = 1)
episodePlot = plot(episodeLane, "Episode depth lane (threshold normalized)", color = phaseColor, linewidth = 3, style = plot.style_linebr)
rollingPlot = plot(showRolling ? rollingLane : na, "Rolling depth lane (threshold normalized)", color = color.new(neutralColor, 35), linewidth = 1, style = plot.style_linebr)
fill(zeroPlot, episodePlot, color = color.new(phaseColor, 86), title = "Underwater depth field", fillgaps = false)
fill(episodePlot, rollingPlot, color = showRolling and anchorExpired ? color.new(expiryColor, 73) : na, title = "Rolling anchor expiry gap", fillgaps = false)
plot(recoveryScore, "Recovery efficiency score (0-100)", color = color.new(recoveryColor, 25), style = plot.style_columns, histbase = 0.0)
hline(-100.0, "Deep threshold / clipped depth", color = color.new(declineColor, 50), linestyle = hline.style_dotted)
hline(100.0, "Recovery score ceiling", color = color.new(neutralColor, 85), linestyle = hline.style_dotted)
plot(dataReady ? entryScore : na, "Recovery entry threshold", color = color.new(recoveryColor, 70), linewidth = 1)
bgcolor(showBackground and observing ? color.new(phaseColor, 94) : na, title = "Confirmed recovery phase")
plotshape(showMarkers and deepEvent, title = "Deep drawdown entered", style = shape.diamond, location = location.bottom, color = declineColor, size = size.tiny, text = "D", textcolor = neutralColor)
plotshape(showMarkers and recoveryEvent, title = "Recovery confirmed", style = shape.triangleup, location = location.top, color = recoveryColor, size = size.tiny, text = "R", textcolor = neutralColor)
plotshape(showMarkers and reclaimEvent, title = "Frozen peak reclaimed", style = shape.circle, location = location.bottom, color = recoveryColor, size = size.tiny, text = "P", textcolor = neutralColor)

// Raw measurements retain their units outside the normalized visual lanes.
plot(dataReady ? -rollingDepth : na, "Rolling drawdown (%)", display = display.data_window)
plot(dataReady ? -episodeDepth : na, "Frozen anchor drawdown (%)", display = display.data_window)
plot(observing ? viewAnchor : na, "Frozen recovery anchor (price)", display = display.data_window)
plot(observing ? viewAge : na, "Episode underwater bars (live preview)", display = display.data_window)
plot(observing ? 100.0 * reclaimFraction : na, "Trough-to-anchor reclaim (%)", display = display.data_window)
plot(normalizedSlope, "Recovery slope (ATR per bar)", display = display.data_window)
plot(dataReady ? 100.0 * upwardEfficiency : na, "Upward path efficiency (%)", display = display.data_window)
plot(dataReady ? 100.0 * durationWeight : na, "Duration weight (%)", display = display.data_window)
plot(dataReady ? (anchorExpired ? 1.0 : 0.0) : na, "Rolling peak below frozen anchor", display = display.data_window)

var table summary = table.new(position.top_right, 2, 8, border_width = 1, border_color = color.new(neutralColor, 75))
if barstate.islast
    if showTable
        color cellBackground = color.new(chart.bg_color, 10)
        table.cell(summary, 0, 0, "DRAWDOWN / RECOVERY", text_color = neutralColor, bgcolor = cellBackground, text_size = size.small)
        table.cell(summary, 1, 0, barstate.isconfirmed ? "Confirmed" : "Live values", text_color = neutralColor, bgcolor = cellBackground, text_size = size.small)
        table.cell(summary, 0, 1, "Confirmed phase", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 1, 1, phaseName(phase), text_color = phaseColor, bgcolor = cellBackground)
        table.cell(summary, 0, 2, "Rolling / episode DD", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 1, 2, dataReady ? str.tostring(-rollingDepth, "#.##") + "% / " + str.tostring(-episodeDepth, "#.##") + "%" : "Waiting for valid bars", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 0, 3, "Observed underwater bars", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 1, 3, dataReady ? str.tostring(viewAge) : "--", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 0, 4, "Reclaim / score", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 1, 4, observing ? str.tostring(100.0 * reclaimFraction, "#.0") + "% / " + str.tostring(recoveryScore, "#.0") : "--", text_color = recoveryColor, bgcolor = cellBackground)
        table.cell(summary, 0, 5, "Slope / path efficiency", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 1, 5, observing ? str.tostring(normalizedSlope, "#.###") + " ATR / " + str.tostring(100.0 * upwardEfficiency, "#.0") + "%" : "--", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 0, 6, "Frozen reference", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 1, 6, observing ? str.tostring(viewAnchor, format.mintick) : "--", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 0, 7, "Reference expiry / path", text_color = neutralColor, bgcolor = cellBackground)
        table.cell(summary, 1, 7, not dataReady ? "Unavailable" : not observing ? "At peak" : anchorExpired ? "Expired peak retained" : pathMature ? "Mature path" : "Building path", text_color = anchorExpired ? expiryColor : neutralColor, bgcolor = cellBackground)
    else
        table.clear(summary, 0, 0, 1, 7)

alertcondition(deepEvent, "Deep drawdown entered", "Drawdown Recovery Efficiency [Pineify]: frozen-anchor drawdown reached the configured deep threshold on a confirmed close.")
alertcondition(recoveryEvent, "Recovery phase confirmed", "Drawdown Recovery Efficiency [Pineify]: a complete positive path, genuine reclaim and duration-adjusted score confirmed the recovery phase.")
alertcondition(reclaimEvent, "Frozen peak reclaimed", "Drawdown Recovery Efficiency [Pineify]: confirmed close reclaimed the frozen episode peak; rolling-window expiry alone cannot trigger this event.")
````
