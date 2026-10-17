# QuantumPips ReactionTrack

- url: https://www.tradingview.com/script/98WCOctk-QuantumPips-ReactionTrack/
- type: indicator
- pine_id: PUB;08ac055e37a94c06bfeaa9e9740a77c7
- version: 1.0

## Description

QuantumPips ReactionTrack is an indicator that marks the most recent Supply and Demand zones created by strong impulse candles, then waits for a confirmed reaction from those zones before drawing a forward projection path (expected move guide).

[b]What it does (simple overview)[/b]
ReactionTrack follows a clean sequence:
[list=1]
[*]Detect impulse → build zones
[*]Wait for price to return to a zone
[*]Confirm the reaction
[*]Project a forward path only after confirmation
[/list]
It keeps your chart clean by showing only the most recent Supply and Demand zones.

[b]1) Recent Zones (Supply & Demand)[/b]

ReactionTrack identifies impulse candles using:
[list]
[*]Impulse Threshold (ATR x): candle range must be ≥ ATR × threshold
[*]Impulse Min Body %: candle body must be strong (filters wick-heavy candles)
[/list]
When an impulse candle appears, the indicator builds a “recent zone” from the most recent opposite candle within the search window:

[b]Bearish impulse → Recent Supply[/b]
[list]
[*]Finds the most recent bullish candle in the lookback
[*]Builds a supply zone from that candle’s structure
[/list]
[b]Bullish impulse → Recent Demand[/b]
[list]
[*]Finds the most recent bearish candle in the lookback
[*]Builds a demand zone from that candle’s structure
[/list]

[b]Zone Extension [/b]controls how far the zones extend forward on the chart.
Optional zone labels can be shown/hidden.

✅ Only the latest supply zone and latest demand zone are kept (older ones are replaced).

[b]2) Reaction Confirmation (the “go” signal)[/b]

ReactionTrack confirms a reaction only when price is inside a zone and shows directional intent:

[b]Basic confirmation[/b]
[list]
[*]Demand reaction: bullish candle (close > open) while price overlaps demand
[*]Supply reaction: bearish candle (close < open) while price overlaps supply
[/list]

[b]Optional: Close-break confirmation (stricter)[/b]
If enabled (Require Close Break For Confirmation), it also requires:
[list]
[*]Bullish confirmation: close > high[1]
[*]Bearish confirmation: close < low[1]
[/list]

This helps filter weaker reactions and reduces noise.

[b]3) Forward Projection Path (drawn only after confirmation)[/b]

Once a reaction is confirmed, the indicator holds an active context:
[list]
[*]Confirmed at Demand → bullish context
[*]Confirmed at Supply → bearish context
[/list]

Only then it draws a forward path for Projection Length bars:
[list]
[*]Bullish: dashed path toward a projected upper level
[*]Bearish: dashed path toward a projected lower level
[*]Optional Mid projection line
[*]Optional Projection labels (target values)
[/list]

The projection is based on recent volatility (ATR/true range behavior) plus a drift component (trend slope vs ATR). It is meant as an expected-move guide, not a prediction.

[b]On-chart labels (what you’ll see)[/b]
[list]
[*]Recent Supply / Recent Demand (optional)
[*]Waiting for Confirmation (state label)
[*]Confirmed at Demand / Confirmed at Supply (state label)
[/list]
[b]Optional confirmation labels:[/b]
[list]
[*]Bullish Reaction Confirmed
[*]Bearish Reaction Confirmed
[/list]

[b]How to use (simple workflow)[/b]
[list=1]
[*]Let ReactionTrack print the newest Supply/Demand zones.
[*]Wait for price to return into one zone.
[*]Look for a confirmed reaction (stronger when Close Break is ON).
[*]Use the projected path as a planning guide (direction + potential target area), then apply your own entry/stop/TP rules.
[/list]


* This is an indicator for charting and analysis only. It does not execute trades and does not guarantee outcomes. Always use risk management. *

## Source Code

````pine
//@version=6
indicator("QuantumPips ReactionTrack", overlay = true, max_boxes_count = 20, max_labels_count = 50, max_lines_count = 20)

//====================================================
// Inputs
//====================================================
groupZones   = "Recent Zones"
groupPath    = "Forward Path"
groupConfirm = "Reaction Confirmation"

lookbackOppCandle = input.int(6, "Opposite Candle Search", minval = 1, maxval = 20, group = groupZones)
impulseATRMult    = input.float(1.2, "Impulse Threshold (ATR x)", step = 0.1, group = groupZones)
minBodyPercent    = input.float(60.0, "Impulse Min Body %", step = 1.0, group = groupZones)
zoneExtendBars    = input.int(80, "Zone Extension", minval = 10, maxval = 300, group = groupZones)
showZoneLabels    = input.bool(true, "Show Zone Labels", group = groupZones)

atrLen            = input.int(14, "ATR Length", minval = 1, group = groupPath)
projLen           = input.int(25, "Projection Length", minval = 5, maxval = 100, group = groupPath)
volMult           = input.float(1.5, "Expected Move Multiplier", step = 0.1, group = groupPath)
driftLen          = input.int(20, "Trend Lookback", minval = 2, maxval = 100, group = groupPath)
showMidline       = input.bool(true, "Show Mid Projection", group = groupPath)
showTargetLabels  = input.bool(true, "Show Projection Labels", group = groupPath)

confirmWithCloseBreak = input.bool(true, "Require Close Break For Confirmation", group = groupConfirm)
showConfirmLabels     = input.bool(true, "Show Confirmation Labels", group = groupConfirm)

//====================================================
// Core Measures
//====================================================
atr = ta.atr(atrLen)

range_   = high - low
body_    = math.abs(close - open)
bodyPct  = range_ > 0 ? (body_ / range_) * 100 : 0.0

bullImpulse = close > open and range_ >= atr * impulseATRMult and bodyPct >= minBodyPercent
bearImpulse = close < open and range_ >= atr * impulseATRMult and bodyPct >= minBodyPercent

trendBasis    = ta.ema(close, driftLen)
trendSlope    = nz(trendBasis - trendBasis[1], 0.0)
driftStrength = atr > 0 ? trendSlope / atr : 0.0

avgRange      = ta.ema(ta.tr(true), atrLen)
projectedMove = avgRange * math.sqrt(projLen) * volMult
driftOffset   = driftStrength * avgRange * projLen * 0.35

targetMid   = close + driftOffset
targetUpper = targetMid + projectedMove
targetLower = targetMid - projectedMove

//====================================================
// Helpers
//====================================================
findLastBullish(_bars) =>
    int found = na
    for i = 1 to _bars
        if close[i] > open[i]
            found := i
            break
    found

findLastBearish(_bars) =>
    int found = na
    for i = 1 to _bars
        if close[i] < open[i]
            found := i
            break
    found

deleteLine(_l) =>
    if not na(_l)
        line.delete(_l)

deleteLabel(_l) =>
    if not na(_l)
        label.delete(_l)

//====================================================
// Most recent zones only
//====================================================
var box supplyBox = na
var box demandBox = na
var label supplyLabel = na
var label demandLabel = na

if bearImpulse
    idx = findLastBullish(lookbackOppCandle)
    if not na(idx)
        zoneTop   = high[idx]
        zoneBot   = math.min(open[idx], close[idx])
        zoneLeft  = bar_index - idx
        zoneRight = bar_index + zoneExtendBars

        if not na(supplyBox)
            box.delete(supplyBox)
        if not na(supplyLabel)
            label.delete(supplyLabel)

        supplyBox := box.new(left = zoneLeft, top = zoneTop, right = zoneRight, bottom = zoneBot, border_color = color.red, bgcolor = color.new(color.red, 84))

        if showZoneLabels
            supplyLabel := label.new(x = zoneLeft, y = zoneTop, text = "Recent Supply", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.small)

if bullImpulse
    idx = findLastBearish(lookbackOppCandle)
    if not na(idx)
        zoneTop   = math.max(open[idx], close[idx])
        zoneBot   = low[idx]
        zoneLeft  = bar_index - idx
        zoneRight = bar_index + zoneExtendBars

        if not na(demandBox)
            box.delete(demandBox)
        if not na(demandLabel)
            label.delete(demandLabel)

        demandBox := box.new(left = zoneLeft, top = zoneTop, right = zoneRight, bottom = zoneBot, border_color = color.lime, bgcolor = color.new(color.lime, 84))

        if showZoneLabels
            demandLabel := label.new(x = zoneLeft, y = zoneBot, text = "Recent Demand", style = label.style_label_up, color = color.new(color.lime, 0), textcolor = color.white, size = size.small)

if not na(supplyBox)
    box.set_right(supplyBox, bar_index + zoneExtendBars)

if not na(demandBox)
    box.set_right(demandBox, bar_index + zoneExtendBars)

//====================================================
// Zone location
//====================================================
float supplyTop = na
float supplyBot = na
float demandTop = na
float demandBot = na

if not na(supplyBox)
    supplyTop := box.get_top(supplyBox)
    supplyBot := box.get_bottom(supplyBox)

if not na(demandBox)
    demandTop := box.get_top(demandBox)
    demandBot := box.get_bottom(demandBox)

inSupply = not na(supplyTop) and high >= supplyBot and low <= supplyTop
inDemand = not na(demandTop) and high >= demandBot and low <= demandTop

//====================================================
// Reaction confirmation
//====================================================
bullishReactionBasic = inDemand and close > open
bearishReactionBasic = inSupply and close < open

bullishReactionBreak = close > high[1]
bearishReactionBreak = close < low[1]

bullishConfirmed = confirmWithCloseBreak ? (bullishReactionBasic and bullishReactionBreak) : bullishReactionBasic
bearishConfirmed = confirmWithCloseBreak ? (bearishReactionBasic and bearishReactionBreak) : bearishReactionBasic

//====================================================
// Hold active directional state after confirmation
//  1 = bullish from demand
// -1 = bearish from supply
//  0 = none
//====================================================
var int activeContext = 0

// reset context when a brand-new zone is created
if bullImpulse
    activeContext := 0
if bearImpulse
    activeContext := 0

if bullishConfirmed and not bearishConfirmed
    activeContext := 1
else if bearishConfirmed and not bullishConfirmed
    activeContext := -1

// optional reset if price fully breaks through the opposite side of zone
if activeContext == 1 and not na(demandBot) and close < demandBot
    activeContext := 0

if activeContext == -1 and not na(supplyTop) and close > supplyTop
    activeContext := 0

//====================================================
// Draw only active confirmed path
//====================================================
var line upperLine = na
var line lowerLine = na
var line midLine   = na
var label upperLbl = na
var label midLbl   = na
var label lowerLbl = na
var label stateLbl = na
var label confLbl  = na

if barstate.islast
    targetBar = bar_index + projLen

    deleteLine(upperLine)
    deleteLine(lowerLine)
    deleteLine(midLine)
    deleteLabel(upperLbl)
    deleteLabel(midLbl)
    deleteLabel(lowerLbl)
    deleteLabel(stateLbl)
    deleteLabel(confLbl)

    upperLine := na
    lowerLine := na
    midLine   := na
    upperLbl  := na
    midLbl    := na
    lowerLbl  := na
    stateLbl  := na
    confLbl   := na

    if activeContext == 1
        upperLine := line.new(x1 = bar_index, y1 = close, x2 = targetBar, y2 = targetUpper, color = color.lime, width = 2, style = line.style_dashed)

        if showMidline
            midLine := line.new(x1 = bar_index, y1 = close, x2 = targetBar, y2 = targetMid, color = color.silver, width = 2)

        if showTargetLabels
            upperLbl := label.new(x = targetBar, y = targetUpper, text = "Bullish Path: " + str.tostring(targetUpper, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.lime, size = size.small)
            midLbl   := label.new(x = targetBar, y = targetMid, text = "Expected: " + str.tostring(targetMid, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.white, size = size.small)

        stateLbl := label.new(x = bar_index, y = high + atr * 0.6, text = "Confirmed at Demand", style = label.style_label_left, color = color.new(color.lime, 75), textcolor = color.white, size = size.small)

    else if activeContext == -1
        lowerLine := line.new(x1 = bar_index, y1 = close, x2 = targetBar, y2 = targetLower, color = color.red, width = 2, style = line.style_dashed)

        if showMidline
            midLine := line.new(x1 = bar_index, y1 = close, x2 = targetBar, y2 = targetMid, color = color.silver, width = 2)

        if showTargetLabels
            lowerLbl := label.new(x = targetBar, y = targetLower, text = "Bearish Path: " + str.tostring(targetLower, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.red, size = size.small)
            midLbl   := label.new(x = targetBar, y = targetMid, text = "Expected: " + str.tostring(targetMid, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.white, size = size.small)

        stateLbl := label.new(x = bar_index, y = high + atr * 0.6, text = "Confirmed at Supply", style = label.style_label_left, color = color.new(color.red, 75), textcolor = color.white, size = size.small)

    else
        stateLbl := label.new(x = bar_index, y = high + atr * 0.6, text = "Waiting for Confirmation", style = label.style_label_left, color = color.new(color.gray, 75), textcolor = color.white, size = size.small)

    if showConfirmLabels
        if bullishConfirmed
            confLbl := label.new(x = bar_index, y = low - atr * 0.3, text = "Bullish Reaction Confirmed", style = label.style_label_up, color = color.new(color.lime, 0), textcolor = color.white, size = size.small)
        else if bearishConfirmed
            confLbl := label.new(x = bar_index, y = high + atr * 0.3, text = "Bearish Reaction Confirmed", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.small)

//====================================================
// Data Window
//====================================================
plot(targetUpper, "Projected Upper", color = color.new(color.lime, 100), display = display.data_window)
plot(targetMid,   "Projected Mid",   color = color.new(color.white, 100), display = display.data_window)
plot(targetLower, "Projected Lower", color = color.new(color.red, 100), display = display.data_window)
````
