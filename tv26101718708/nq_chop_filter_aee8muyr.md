# NQ Chop Filter

- url: https://www.tradingview.com/script/aeE8MUyR-NQ-Chop-Filter/
- type: indicator
- pine_id: PUB;b57358f5373d483aac127e15e7b3d166
- version: 2.0

## Description

NQ Chop Filter is a volatility and trade-confidence meter built for short-term NQ trading, especially on the 30-second chart.

This indicator is not a buy/sell signal and it is not meant to replace a trading strategy. It is designed to help judge whether current market conditions are strong, normal, cautious, or dangerous before managing risk.

The meter studies recent candle range, fast range expansion/compression, net price movement, directional efficiency, and wider trend/grind movement.

The dashboard gives a simple reading:

HIGH
Strong volatility and movement. Full confidence conditions. Larger targets are more reasonable.

NORMAL
Conditions are acceptable. Trading is still okay, but avoid sizing up blindly.

CAUTION
Market is less clean. Trade smaller, be more selective, and manage risk tighter.

DANGER
Weak movement or poor follow-through. Reduce size or wait.

How to use:

1. Add the indicator to an NQ chart.
2. Best used on the 15-second to 2-minute timeframe. Best on 30s.
3. Watch the dashboard before taking a trade.
4. Use HIGH and NORMAL as cleaner environments.
5. Use CAUTION and DANGER as risk warnings, not automatic signals.
6. Do not use this indicator by itself for entries.
7. Combine it with your own entry model, stop loss, take profit, and daily risk rules.

The main purpose is to avoid blindly trading the same size in all market conditions. It helps identify when the market is moving cleanly versus when price is slow, compressed, or choppy.

This script is for educational and informational purposes only. It is not financial advice.

## Source Code

````pine
//@version=6
indicator("NQ Chop Filter v3", shorttitle="NQ Chop Filter v3", overlay=false, max_labels_count=50)

//====================================================
// INPUTS
//====================================================
groupSession = "Session"
useNySession      = input.bool(true, "Use NY Session Logic", group=groupSession)
nySession         = input.session("0930-1600", "NY Session", group=groupSession)
ignoreOpenMinutes = input.int(5, "Opening Wait Minutes", minval=0, maxval=60, group=groupSession)

groupCore = "Core Measurements"
mainLen  = input.int(10, "Main Candle Average", minval=2, maxval=100, group=groupCore)
fastLen  = input.int(5, "Fast Candle Average", minval=1, maxval=20, group=groupCore)
trendLen = input.int(40, "Trend / Grind Lookback", minval=10, maxval=200, group=groupCore)

groupThresholds = "Thresholds"
provenStrongRange = input.int(135, "Proven Strong Avg Range", minval=1, group=groupThresholds)
goodRange         = input.int(100, "Good Avg Range", minval=1, group=groupThresholds)
cautionRange      = input.int(75, "Caution Avg Range", minval=1, group=groupThresholds)

minNetMove       = input.int(30, "Minimum Net Move", minval=0, group=groupThresholds)
goodNetMove      = input.int(60, "Good Net Move", minval=0, group=groupThresholds)
minEfficiencyPct = input.int(6, "Minimum Efficiency %", minval=0, maxval=100, group=groupThresholds)

grindTravel = input.int(260, "Grind Travel Threshold", minval=1, group=groupThresholds)
grindEfficiencyPctInput = input.int(8, "Grind Efficiency %", minval=0, maxval=100, group=groupThresholds)

fastExpansionRatio   = input.float(1.10, "Fast Expansion Ratio", minval=0.1, step=0.05, group=groupThresholds)
fastCompressionRatio = input.float(0.75, "Fast Compression Ratio", minval=0.1, step=0.05, group=groupThresholds)

groupLogic = "Logic"
downgradeCompression = input.bool(true, "Downgrade Compression", group=groupLogic)

groupDisplay = "Display"
showDashboard      = input.bool(true, "Show Simple Dashboard", group=groupDisplay)
showBackground     = input.bool(true, "Color Background", group=groupDisplay)
showConfidenceLine = input.bool(true, "Show Confidence Line", group=groupDisplay)
showRangeBars      = input.bool(true, "Show Candle Range Bars", group=groupDisplay)
showAvgRange       = input.bool(true, "Show Avg Range Line", group=groupDisplay)
showNetMove        = input.bool(false, "Show Net Move Line", group=groupDisplay)

dashPositionInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDisplay)
textSizeInput     = input.string("Large", "Dashboard Text Size", options=["Small", "Normal", "Large", "Huge"], group=groupDisplay)

groupColors = "Colors"
strongColor   = input.color(color.lime, "Strong Color", group=groupColors)
normalColor   = input.color(color.aqua, "Normal Color", group=groupColors)
cautionColor  = input.color(color.orange, "Caution Color", group=groupColors)
dangerColor   = input.color(color.red, "Danger Color", group=groupColors)
textColor     = input.color(color.white, "Text Color", group=groupColors)
rangeBarColor = input.color(color.gray, "Range Bar Color", group=groupColors)

//====================================================
// HELPERS
//====================================================
tickSize = syminfo.mintick

safeDiv(_a, _b) =>
    _b == 0.0 ? 0.0 : _a / _b

dashPosition(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Bottom Right" ? position.bottom_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.top_right

dashTextSize(_size) =>
    _size == "Small" ? size.small :
     _size == "Normal" ? size.normal :
     _size == "Huge" ? size.huge :
     size.large

//====================================================
// SESSION LOGIC
//====================================================
inNySession = not na(time(timeframe.period, nySession, "America/New_York"))
newNySession = inNySession and not inNySession[1]

var int nyOpenBar = na
if newNySession
    nyOpenBar := bar_index

barsSinceNyOpen = not na(nyOpenBar) ? bar_index - nyOpenBar : na
secPerBar = timeframe.in_seconds(timeframe.period)
ignoreBars = math.ceil(ignoreOpenMinutes * 60 / secPerBar)

inOpeningWindow = useNySession and inNySession and not na(barsSinceNyOpen) and barsSinceNyOpen < ignoreBars
validSession = not useNySession or inNySession

//====================================================
// MEASUREMENTS
//====================================================
candleRangeTicks = (high - low) / tickSize

avgRange = ta.sma(candleRangeTicks, mainLen)
fastRange = ta.sma(candleRangeTicks, fastLen)
fastRatio = safeDiv(fastRange, avgRange)

netMove = math.abs(close - close[mainLen]) / tickSize

totalMove = 0.0
for i = 0 to mainLen - 1
    totalMove += math.abs(close[i] - close[i + 1]) / tickSize

efficiencyPct = safeDiv(netMove, totalMove) * 100.0

trendTravel = math.abs(close - close[trendLen]) / tickSize

trendTotalMove = 0.0
for i = 0 to trendLen - 1
    trendTotalMove += math.abs(close[i] - close[i + 1]) / tickSize

trendEfficiencyPct = safeDiv(trendTravel, trendTotalMove) * 100.0

//====================================================
// LOGIC
//====================================================
hasMovement = netMove >= minNetMove and efficiencyPct >= minEfficiencyPct
hasGoodMovement = netMove >= goodNetMove and efficiencyPct >= minEfficiencyPct
fastExpanding = fastRatio >= fastExpansionRatio
fastCompressing = fastRatio <= fastCompressionRatio
grindOk = trendTravel >= grindTravel and trendEfficiencyPct >= grindEfficiencyPctInput

strongRaw =
     avgRange >= provenStrongRange and
     (
         hasGoodMovement or
         grindOk or
         (hasMovement and fastExpanding)
     )

normalRaw =
     not strongRaw and
     (
         (avgRange >= goodRange and (hasMovement or fastExpanding)) or
         (avgRange >= cautionRange and grindOk)
     )

cautionRaw =
     not strongRaw and
     not normalRaw and
     (
         avgRange >= cautionRange or
         hasMovement or
         grindOk
     )

compressionWarning = fastCompressing and avgRange < goodRange and not grindOk

strongMode = validSession and not inOpeningWindow and strongRaw and not (downgradeCompression and compressionWarning)
normalMode = validSession and not inOpeningWindow and not strongMode and normalRaw and not (downgradeCompression and compressionWarning)
cautionMode = validSession and (inOpeningWindow or ((not strongMode and not normalMode) and (cautionRaw or (downgradeCompression and compressionWarning))))
dangerMode = not validSession or (not strongMode and not normalMode and not cautionMode)

//====================================================
// OUTPUT
//====================================================
confidenceText =
     inOpeningWindow ? "OPEN WAIT" :
     strongMode ? "HIGH" :
     normalMode ? "NORMAL" :
     cautionMode ? "CAUTION" :
     "DANGER"

actionText =
     inOpeningWindow ? "Opening wait / let it prove" :
     strongMode ? "340 OK / full confidence" :
     normalMode ? "340 OK / no size-up" :
     cautionMode ? "Trade smaller / be careful" :
     "Reduce size or wait"

if compressionWarning and not dangerMode and not inOpeningWindow
    actionText := "Compression / no size-up"

modeColor =
     strongMode ? strongColor :
     normalMode ? normalColor :
     cautionMode ? cautionColor :
     dangerColor

confidenceScore =
     strongMode ? 90.0 :
     normalMode ? 65.0 :
     cautionMode ? 40.0 :
     15.0

//====================================================
// PLOTS
//====================================================
hline(provenStrongRange, "Proven Strong Range", color=color.new(strongColor, 55), linestyle=hline.style_dashed)
hline(goodRange, "Good Range", color=color.new(normalColor, 65), linestyle=hline.style_dashed)
hline(cautionRange, "Caution Range", color=color.new(cautionColor, 65), linestyle=hline.style_dashed)

plot(showRangeBars ? candleRangeTicks : na, title="Candle Range Ticks", style=plot.style_columns, color=color.new(rangeBarColor, 75))
plot(showAvgRange ? avgRange : na, title="Average Range", color=modeColor, linewidth=3)
plot(showNetMove ? netMove : na, title="Net Move", color=color.new(normalColor, 0), linewidth=2)
plot(showConfidenceLine ? confidenceScore : na, title="Confidence Score", color=modeColor, linewidth=2)

bgcolor(showBackground ? color.new(modeColor, 88) : na)

//====================================================
// DASHBOARD
//====================================================
var table dash = table.new(dashPosition(dashPositionInput), 2, 3, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Confidence", text_color=textColor, bgcolor=color.new(color.black, 0), text_size=dashTextSize(textSizeInput))
    table.cell(dash, 1, 0, confidenceText, text_color=textColor, bgcolor=color.new(modeColor, 0), text_size=dashTextSize(textSizeInput))

    table.cell(dash, 0, 1, "Action", text_color=textColor, bgcolor=color.new(color.black, 0), text_size=dashTextSize(textSizeInput))
    table.cell(dash, 1, 1, actionText, text_color=textColor, bgcolor=color.new(modeColor, 20), text_size=dashTextSize(textSizeInput))

    table.cell(dash, 0, 2, "Avg / Eff", text_color=textColor, bgcolor=color.new(color.black, 0), text_size=dashTextSize(textSizeInput))
    table.cell(dash, 1, 2, str.tostring(avgRange, "#") + "t / " + str.tostring(efficiencyPct, "#") + "%", text_color=textColor, bgcolor=color.new(modeColor, 35), text_size=dashTextSize(textSizeInput))

//====================================================
// ALERTS
//====================================================
alertcondition(strongMode and not strongMode[1], title="NQ Chop Filter HIGH", message="NQ Chop Filter: HIGH confidence / 340 OK.")
alertcondition(normalMode and not normalMode[1], title="NQ Chop Filter NORMAL", message="NQ Chop Filter: NORMAL / 340 OK but no size-up.")
alertcondition(cautionMode and not cautionMode[1], title="NQ Chop Filter CAUTION", message="NQ Chop Filter: CAUTION / trade smaller.")
alertcondition(dangerMode and not dangerMode[1], title="NQ Chop Filter DANGER", message="NQ Chop Filter: DANGER / reduce size or wait.")
````
