# RevStrat Reversals Alerts

- url: https://www.tradingview.com/script/nriJvaTu-RevStrat-Reversals-Alerts/
- type: indicator
- pine_id: PUB;dea256866ab2495d8bedf047602b574d
- version: 4.0

## Description

📊 RevStrat Reversals Alerts
RevStrat Reversals Alerts is a precision tool designed to identify high-probability reversal patterns based on The Strat methodology. It focuses on real-time detection of key multi-bar reversal structures and delivers immediate visual signals and alerts to help traders react as setups develop — not after they complete.
🔍 What This Indicator Does
This script scans price action and automatically detects the following reversal patterns:
3-2 Bearish Reversal
3-2 Bullish Reversal
1-2-2 Bearish RevStrat Reversal
1-2-2 Bullish RevStrat Reversal
2-2 Bearish Reversal
2-2 Bullish Reversal
Each pattern is identified using strict bar structure logic based on:
Inside bars (1)
Directional bars (2 up / 2 down)
Outside bars (3)
Signals are plotted directly on the chart with customizable labels or shapes.
⚡ Real-Time Signal Behavior
Unlike many indicators that wait for candle close, this script is designed for intrabar responsiveness:
Signals trigger as the setup forms, not after confirmation
Alerts can be configured as:
Once Per Bar
Once Per Bar Update
This allows traders to act early during developing reversals
🎯 Alert System
The indicator includes both individual and combined alerts:
Individual Alerts
32 Bearish Reversal
32 Bullish Reversal
122 Bearish RevStrat Reversal
122 Bullish RevStrat Reversal
22 Bearish Reversal
22 Bullish Reversal
Combined Alerts
Any Bullish Reversal
Any Bearish Reversal
Any RevStrat Signal
A dynamic alert message system ensures you know exactly which setup triggered in real time.
🎨 Customization Options
Toggle each pattern on/off individually
Choose shape style:
Labels
Triangles
Select signal location:
Above or below candles
Adjust offset positioning
Option to display only the most recent signal for cleaner charts
Fully customizable bull/bear colors
🧠 How to Use It Effectively
This tool is designed to be used in conjunction with:
Market structure (trend or range context)
Key levels (support/resistance, session highs/lows)
Order flow or volume confirmation
Best practice:
Treat signals as decision points, not automatic entries
Look for alignment with broader context before executing trades
⚠️ Important Notes
This indicator is structure-based, not predictive
Signals can appear during live candles and may change if price action evolves
Always combine with risk management and confirmation tools
🚀 Summary
RevStrat Reversals Alerts gives you:
Clean identification of core Strat reversal patterns
Real-time signal generation
Flexible alerting system
Fully customizable visuals
Built for traders who want speed, clarity, and structure-based execution.

## Source Code

````pine
//@version=5
indicator("RevStrat Reversals + FTFC + 30/60/4H Alignment Alerts", overlay=true, max_labels_count=500, precision=0)

//==================================================
// REVSTRAT INPUTS
//==================================================
groupDisplay = "Display"
show32Bear   = input.bool(true,  "Show 32 Bearish Reversal", group=groupDisplay)
show32Bull   = input.bool(true,  "Show 32 Bullish Reversal", group=groupDisplay)
show122Bear  = input.bool(true,  "Show 122 Bearish RevStrat Reversal", group=groupDisplay)
show122Bull  = input.bool(true,  "Show 122 Bullish RevStrat Reversal", group=groupDisplay)
show22Bear   = input.bool(true,  "Show 22 Bearish Reversal", group=groupDisplay)
show22Bull   = input.bool(true,  "Show 22 Bullish Reversal", group=groupDisplay)
show3Bear    = input.bool(true,  "Show 3 Bearish RevStrat Reversal", group=groupDisplay)
show3Bull    = input.bool(true,  "Show 3 Bullish RevStrat Reversal", group=groupDisplay)

showOnlyLastSignal = input.bool(true, "Show Only Last Signal", group=groupDisplay)
shapeOffset        = input.int(0, "Shape Offset", group=groupDisplay)

groupColors = "Colors"
bullColor = input.color(color.lime, "Bull Color", group=groupColors)
bearColor = input.color(color.red,  "Bear Color", group=groupColors)

//==================================================
// FTFC INPUTS
//==================================================
isFtcActive = input.bool(true, "Full Time Frame Continuity Active?")
enableAlignmentAlerts = input.bool(true, "Enable 30m + 1H + 4H Alignment Alerts?")
ftcVerticalOffsetATR = input.float(1.5, "FTFC Vertical Offset (ATR Multiple)", step=0.1)

//==================================================
// REQUIRED STATIC VARIABLES / CONSTANTS
//==================================================
_bullColor = color.green
_bearColor = color.red
_outsideColor = color.fuchsia
_insideColor = color.new(#F6BE00, 0)
_alignmentColor = color.new(#f7c627, 0)

_bullShape = shape.arrowup
_bearShape = shape.arrowdown

_ftcLocation = location.absolute

_oneMinuteTimeFrame = "1"
_threeMinuteTimeFrame = "3"
_fiveMinuteTimeFrame = "5"
_tenMinuteTimeFrame = "10"
_fifteenMinuteTimeFrame = "15"
_thirtyMinuteTimeFrame = "30"
_fourtyFiveMinuteTimeFrame = "45"
_hourTimeFrame = "60"
_fourHourTimeFrame = "240"
_dayTimeFrame = "D"
_weekTimeFrame = "W"
_monthTimeFrame = "M"
_quarterTimeFrame = "3M"

_ftcBaseOffset = 1
_ftc15Offset = _ftcBaseOffset + 1
_ftc30Offset = _ftcBaseOffset + 2
_ftcHourOffset = _ftcBaseOffset + 3
_ftcFourHourOffset = _ftcBaseOffset + 4
_ftcDayOffset = _ftcBaseOffset + 5
_ftcWeekOffset = _ftcBaseOffset + 6
_ftcMonthOffset = _ftcBaseOffset + 7
_ftcQuarterOffset = _ftcBaseOffset + 8

_ftc15Text = "15"
_ftc30Text = "30"
_ftcHourText = "H"
_ftcFourHourText = "4H"
_ftcDayText = "D"
_ftcWeekText = "W"
_ftcMonthText = "M"
_ftcQuarterText = "Q"
_ftcInsideText = "IN\n"
_ftcOutsideText = "O\n"

//==================================================
// REVSTRAT INTERNAL SETTINGS
//==================================================
firstBarIndex  = 0
secondBarIndex = 1
thirdBarIndex  = 2

showLastValue = showOnlyLastSignal ? 1 : 500

//==================================================
// REVSTRAT BAR TYPE FUNCTIONS
//==================================================
getIndexOneBar(idx) =>
    high[idx] < high[idx + 1] and low[idx] > low[idx + 1]

getIndexTwoUpBar(idx) =>
    high[idx] > high[idx + 1] and low[idx] >= low[idx + 1]

getIndexTwoDownBar(idx) =>
    low[idx] < low[idx + 1] and high[idx] <= high[idx + 1]

getIndexThreeBar(idx) =>
    high[idx] > high[idx + 1] and low[idx] < low[idx + 1]

//==================================================
// FTFC FUNCTIONS
//==================================================
getSecurityByTimeFrame(timeFrame) =>
    request.security(syminfo.tickerid, timeFrame, [open, close, high, low, time])

getOneBarBySeries(highSeries, lowSeries) =>
    highSeries[0] <= highSeries[1] and lowSeries[0] >= lowSeries[1]

getThreeBarBySeries(highSeries, lowSeries) =>
    highSeries[0] > highSeries[1] and lowSeries[0] < lowSeries[1]

//==================================================
// REVSTRAT PATTERN NAMES
//==================================================
txt32Bear  = "32 Bearish\nReversal"
txt32Bull  = "32 Bullish\nReversal"
txt122Bear = "122 Bearish RevStrat\nReversal"
txt122Bull = "122 Bullish RevStrat\nReversal"
txt22Bear  = "22 Bearish\nReversal"
txt22Bull  = "22 Bullish\nReversal"
txt3Bear   = "3 Bearish \nRevStrat Reversal"
txt3Bull   = "3 Bullish \nRevStrat Reversal"

//==================================================
// REVSTRAT RAW PATTERN LOGIC
//==================================================
is32BearishReversal =
     getIndexThreeBar(secondBarIndex) and
     getIndexTwoDownBar(firstBarIndex)

is32BullishReversal =
     getIndexThreeBar(secondBarIndex) and
     getIndexTwoUpBar(firstBarIndex)

is122BearishRevStratReversal =
     getIndexOneBar(thirdBarIndex) and
     getIndexTwoUpBar(secondBarIndex) and
     getIndexTwoDownBar(firstBarIndex)

is122BullishRevStratReversal =
     getIndexOneBar(thirdBarIndex) and
     getIndexTwoDownBar(secondBarIndex) and
     getIndexTwoUpBar(firstBarIndex)

is22BearishReversal =
     getIndexTwoUpBar(secondBarIndex) and
     getIndexTwoDownBar(firstBarIndex)

is22BullishReversal =
     getIndexTwoDownBar(secondBarIndex) and
     getIndexTwoUpBar(firstBarIndex)

is3BearishRevStratReversal =
     getIndexThreeBar(firstBarIndex) and
     close < low[1]

is3BullishRevStratReversal =
     getIndexThreeBar(firstBarIndex) and
     close > high[1]

//==================================================
// REVSTRAT LIVE SIGNALS
//==================================================
sig32Bear  = show32Bear  and is32BearishReversal
sig32Bull  = show32Bull  and is32BullishReversal
sig122Bear = show122Bear and is122BearishRevStratReversal
sig122Bull = show122Bull and is122BullishRevStratReversal
sig22Bear  = show22Bear  and is22BearishReversal
sig22Bull  = show22Bull  and is22BullishReversal
sig3Bear   = show3Bear   and is3BearishRevStratReversal
sig3Bull   = show3Bull   and is3BullishRevStratReversal

//==================================================
// REVSTRAT PLOTS
//==================================================
plotshape(sig32Bear,  title="32 Bearish Reversal", style=shape.arrowdown, color=bearColor, location=location.top, text=txt32Bear, textcolor=bearColor, offset=shapeOffset, show_last=showLastValue)
plotshape(sig32Bull,  title="32 Bullish Reversal", style=shape.arrowup,   color=bullColor, location=location.top, text=txt32Bull, textcolor=bullColor, offset=shapeOffset, show_last=showLastValue)

plotshape(sig122Bear, title="122 Bearish RevStrat Reversal", style=shape.arrowdown, color=bearColor, location=location.top, text=txt122Bear, textcolor=bearColor, offset=shapeOffset, show_last=showLastValue)
plotshape(sig122Bull, title="122 Bullish RevStrat Reversal", style=shape.arrowup,   color=bullColor, location=location.top, text=txt122Bull, textcolor=bullColor, offset=shapeOffset, show_last=showLastValue)

plotshape(sig22Bear,  title="22 Bearish Reversal", style=shape.arrowdown, color=bearColor, location=location.top, text=txt22Bear, textcolor=bearColor, offset=shapeOffset, show_last=showLastValue)
plotshape(sig22Bull,  title="22 Bullish Reversal", style=shape.arrowup,   color=bullColor, location=location.top, text=txt22Bull, textcolor=bullColor, offset=shapeOffset, show_last=showLastValue)

plotshape(sig3Bear,   title="3 Bearish RevStrat Reversal", style=shape.arrowdown, color=bearColor, location=location.top, text=txt3Bear, textcolor=bearColor, offset=shapeOffset, show_last=showLastValue)
plotshape(sig3Bull,   title="3 Bullish RevStrat Reversal", style=shape.arrowup,   color=bullColor, location=location.top, text=txt3Bull, textcolor=bullColor, offset=shapeOffset, show_last=showLastValue)

//==================================================
// GET HIGHER TIMEFRAME DATA
//==================================================
[open15Value, close15Value, high15Value, low15Value, time15Value] = getSecurityByTimeFrame(_fifteenMinuteTimeFrame)
[open30Value, close30Value, high30Value, low30Value, time30Value] = getSecurityByTimeFrame(_thirtyMinuteTimeFrame)
[open60Value, close60Value, highHourValue, lowHourValue, timeHourValue] = getSecurityByTimeFrame(_hourTimeFrame)
[openFourHourValue, closeFourHourValue, highFourHourValue, lowFourHourValue, timeFourHourValue] = getSecurityByTimeFrame(_fourHourTimeFrame)
[openDayValue, closeDayValue, highDayValue, lowDayValue, timeDayValue] = getSecurityByTimeFrame(_dayTimeFrame)
[openWeekValue, closeWeekValue, highWeekValue, lowWeekValue, timeWeekValue] = getSecurityByTimeFrame(_weekTimeFrame)
[openMonthValue, closeMonthValue, highMonthValue, lowMonthValue, timeMonthValue] = getSecurityByTimeFrame(_monthTimeFrame)
[openQuarterValue, closeQuarterValue, highQuarterValue, lowQuarterValue, timeQuarterValue] = getSecurityByTimeFrame(_quarterTimeFrame)

//==================================================
// GREEN / RED STATE
//==================================================
is15FtcGreen = open15Value[0] <= close15Value[0]
is30FtcGreen = open30Value[0] <= close30Value[0]
isHourFtcGreen = open60Value[0] <= close60Value[0]
isFourHourFtcGreen = openFourHourValue[0] <= closeFourHourValue[0]
isDayFtcGreen = openDayValue[0] <= closeDayValue[0]
isWeekFtcGreen = openWeekValue[0] <= closeWeekValue[0]
isMonthFtcGreen = openMonthValue[0] <= closeMonthValue[0]
isQuarterFtcGreen = openQuarterValue[0] <= closeQuarterValue[0]

//==================================================
// INSIDE STATE
//==================================================
is15FtcInside = getOneBarBySeries(high15Value, low15Value)
is30FtcInside = getOneBarBySeries(high30Value, low30Value)
isHourFtcInside = getOneBarBySeries(highHourValue, lowHourValue)
isFourHourFtcInside = getOneBarBySeries(highFourHourValue, lowFourHourValue)
isDayFtcInside = getOneBarBySeries(highDayValue, lowDayValue)
isWeekFtcInside = getOneBarBySeries(highWeekValue, lowWeekValue)
isMonthFtcInside = getOneBarBySeries(highMonthValue, lowMonthValue)
isQuarterFtcInside = getOneBarBySeries(highQuarterValue, lowQuarterValue)

//==================================================
// OUTSIDE STATE
//==================================================
is15FtcOutside = getThreeBarBySeries(high15Value, low15Value)
is30FtcOutside = getThreeBarBySeries(high30Value, low30Value)
isHourFtcOutside = getThreeBarBySeries(highHourValue, lowHourValue)
isFourHourFtcOutside = getThreeBarBySeries(highFourHourValue, lowFourHourValue)
isDayFtcOutside = getThreeBarBySeries(highDayValue, lowDayValue)
isWeekFtcOutside = getThreeBarBySeries(highWeekValue, lowWeekValue)
isMonthFtcOutside = getThreeBarBySeries(highMonthValue, lowMonthValue)
isQuarterFtcOutside = getThreeBarBySeries(highQuarterValue, lowQuarterValue)

//==================================================
// VALID TIMEFRAME LOGIC
//==================================================
is15ValidTimeFrame = timeframe.period == _oneMinuteTimeFrame or timeframe.period == _threeMinuteTimeFrame or timeframe.period == _fiveMinuteTimeFrame or timeframe.period == _tenMinuteTimeFrame or timeframe.period == _fifteenMinuteTimeFrame
is30ValidTimeFrame = is15ValidTimeFrame or timeframe.period == _thirtyMinuteTimeFrame
isHourValidTimeFrame = is30ValidTimeFrame or timeframe.period == _hourTimeFrame or timeframe.period == _fourtyFiveMinuteTimeFrame
isFourHourValidTimeFrame = isHourValidTimeFrame or timeframe.isintraday
isDayValidTimeFrame = isFourHourValidTimeFrame or timeframe.isdaily
isWeekValidTimeFrame = isDayValidTimeFrame or timeframe.period == _weekTimeFrame or timeframe.isintraday
isMonthValidTimeFrame = isWeekValidTimeFrame or timeframe.ismonthly
isQuarterValidTimeFrame = isWeekValidTimeFrame or timeframe.isdwm

//==================================================
// OFFSET LOGIC
//==================================================
int ftcTimeFrameOffset = 0
if (not isQuarterValidTimeFrame)
    ftcTimeFrameOffset := 8
else if (not isMonthValidTimeFrame)
    ftcTimeFrameOffset := 7
else if (not isWeekValidTimeFrame)
    ftcTimeFrameOffset := 6
else if (not isDayValidTimeFrame)
    ftcTimeFrameOffset := 5
else if (not isFourHourValidTimeFrame)
    ftcTimeFrameOffset := 4
else if (not isHourValidTimeFrame)
    ftcTimeFrameOffset := 3
else if (not is30ValidTimeFrame)
    ftcTimeFrameOffset := 2
else if (not is15ValidTimeFrame)
    ftcTimeFrameOffset := 1

//==================================================
// FINAL VALID FLAGS
//==================================================
is15Valid = is15ValidTimeFrame
is30Valid = is30ValidTimeFrame
isHourValid = isHourValidTimeFrame
isFourHourValid = isFourHourValidTimeFrame
isDayValid = isDayValidTimeFrame
isWeekValid = isWeekValidTimeFrame
isMonthValid = isMonthValidTimeFrame
isQuarterValid = isQuarterValidTimeFrame

//==================================================
// PLOT FLAGS
//==================================================
is15FtcGreenPlot = isFtcActive and is15Valid and is15FtcGreen
is15FtcRedPlot = isFtcActive and is15Valid and not is15FtcGreen

is30FtcGreenPlot = isFtcActive and is30Valid and is30FtcGreen
is30FtcRedPlot = isFtcActive and is30Valid and not is30FtcGreen

isHourFtcGreenPlot = isFtcActive and isHourValid and isHourFtcGreen
isHourFtcRedPlot = isFtcActive and isHourValid and not isHourFtcGreen

isFourHourFtcGreenPlot = isFtcActive and isFourHourValid and isFourHourFtcGreen
isFourHourFtcRedPlot = isFtcActive and isFourHourValid and not isFourHourFtcGreen

isDayFtcGreenPlot = isFtcActive and isDayValid and isDayFtcGreen
isDayFtcRedPlot = isFtcActive and isDayValid and not isDayFtcGreen

isWeekFtcGreenPlot = isFtcActive and isWeekValid and isWeekFtcGreen
isWeekFtcRedPlot = isFtcActive and isWeekValid and not isWeekFtcGreen

isMonthFtcGreenPlot = isFtcActive and isMonthValid and isMonthFtcGreen
isMonthFtcRedPlot = isFtcActive and isMonthValid and not isMonthFtcGreen

isQuarterFtcGreenPlot = isFtcActive and isQuarterValid and isQuarterFtcGreen
isQuarterFtcRedPlot = isFtcActive and isQuarterValid and not isQuarterFtcGreen

//==================================================
// 30m + 1H + 4H ALIGNMENT
//==================================================
bullAlignment = isFtcActive and is30Valid and isHourValid and isFourHourValid and is30FtcGreen and isHourFtcGreen and isFourHourFtcGreen
bearAlignment = isFtcActive and is30Valid and isHourValid and isFourHourValid and not is30FtcGreen and not isHourFtcGreen and not isFourHourFtcGreen

newBullAlignment = bullAlignment and not bullAlignment[1]
newBearAlignment = bearAlignment and not bearAlignment[1]

//==================================================
// VERTICAL POSITIONING
//==================================================
ftcBaseY = close + ta.atr(14) * ftcVerticalOffsetATR

//==================================================
// FTFC PLOTS ONLY
// Removed INSIDE/OUTSIDE plotchars to stay under TradingView plot limit
// Original timeframe logic remains unchanged
//==================================================
plotshape(is15FtcGreenPlot ? ftcBaseY : na, title="isFtc15Green", style=_bullShape, text=_ftc15Text, location=_ftcLocation, offset=_ftc15Offset - ftcTimeFrameOffset, color=_bullColor, show_last=1)
plotshape(is15FtcRedPlot ? ftcBaseY : na, title="isFtc15Red", style=_bearShape, text=_ftc15Text, location=_ftcLocation, offset=_ftc15Offset - ftcTimeFrameOffset, color=_bearColor, show_last=1)

plotshape(is30FtcGreenPlot ? ftcBaseY : na, title="isFtc30Green", style=_bullShape, text=_ftc30Text, location=_ftcLocation, offset=_ftc30Offset - ftcTimeFrameOffset, color=bullAlignment ? _alignmentColor : _bullColor, show_last=1)
plotshape(is30FtcRedPlot ? ftcBaseY : na, title="isFtc30Red", style=_bearShape, text=_ftc30Text, location=_ftcLocation, offset=_ftc30Offset - ftcTimeFrameOffset, color=bearAlignment ? _alignmentColor : _bearColor, show_last=1)

plotshape(isHourFtcGreenPlot ? ftcBaseY : na, title="isFtcHourGreen", style=_bullShape, text=_ftcHourText, location=_ftcLocation, offset=_ftcHourOffset - ftcTimeFrameOffset, color=bullAlignment ? _alignmentColor : _bullColor, show_last=1)
plotshape(isHourFtcRedPlot ? ftcBaseY : na, title="isFtcHourRed", style=_bearShape, text=_ftcHourText, location=_ftcLocation, offset=_ftcHourOffset - ftcTimeFrameOffset, color=bearAlignment ? _alignmentColor : _bearColor, show_last=1)

plotshape(isFourHourFtcGreenPlot ? ftcBaseY : na, title="isFtcFourHourGreen", style=_bullShape, text=_ftcFourHourText, location=_ftcLocation, offset=_ftcFourHourOffset - ftcTimeFrameOffset, color=bullAlignment ? _alignmentColor : _bullColor, show_last=1)
plotshape(isFourHourFtcRedPlot ? ftcBaseY : na, title="isFtcFourHourRed", style=_bearShape, text=_ftcFourHourText, location=_ftcLocation, offset=_ftcFourHourOffset - ftcTimeFrameOffset, color=bearAlignment ? _alignmentColor : _bearColor, show_last=1)

plotshape(isDayFtcGreenPlot ? ftcBaseY : na, title="isFtcDayGreen", style=_bullShape, text=_ftcDayText, location=_ftcLocation, offset=_ftcDayOffset - ftcTimeFrameOffset, color=_bullColor, show_last=1)
plotshape(isDayFtcRedPlot ? ftcBaseY : na, title="isFtcDayRed", style=_bearShape, text=_ftcDayText, location=_ftcLocation, offset=_ftcDayOffset - ftcTimeFrameOffset, color=_bearColor, show_last=1)

plotshape(isWeekFtcGreenPlot ? ftcBaseY : na, title="isFtcWeekGreen", style=_bullShape, text=_ftcWeekText, location=_ftcLocation, offset=_ftcWeekOffset - ftcTimeFrameOffset, color=_bullColor, show_last=1)
plotshape(isWeekFtcRedPlot ? ftcBaseY : na, title="isFtcWeekRed", style=_bearShape, text=_ftcWeekText, location=_ftcLocation, offset=_ftcWeekOffset - ftcTimeFrameOffset, color=_bearColor, show_last=1)

plotshape(isMonthFtcGreenPlot ? ftcBaseY : na, title="isFtcMonthGreen", style=_bullShape, text=_ftcMonthText, location=_ftcLocation, offset=_ftcMonthOffset - ftcTimeFrameOffset, color=_bullColor, show_last=1)
plotshape(isMonthFtcRedPlot ? ftcBaseY : na, title="isFtcMonthRed", style=_bearShape, text=_ftcMonthText, location=_ftcLocation, offset=_ftcMonthOffset - ftcTimeFrameOffset, color=_bearColor, show_last=1)

plotshape(isQuarterFtcGreenPlot ? ftcBaseY : na, title="isFtcQuarterGreen", style=_bullShape, text=_ftcQuarterText, location=_ftcLocation, offset=_ftcQuarterOffset - ftcTimeFrameOffset, color=_bullColor, show_last=1)
plotshape(isQuarterFtcRedPlot ? ftcBaseY : na, title="isFtcQuarterRed", style=_bearShape, text=_ftcQuarterText, location=_ftcLocation, offset=_ftcQuarterOffset - ftcTimeFrameOffset, color=_bearColor, show_last=1)

//==================================================
// ALERT CONDITIONS - REVSTRAT
//==================================================
alertcondition(sig32Bear,  title="32 Bearish Reversal", message="32 Bearish Reversal detected on {{ticker}} {{interval}}")
alertcondition(sig32Bull,  title="32 Bullish Reversal", message="32 Bullish Reversal detected on {{ticker}} {{interval}}")
alertcondition(sig122Bear, title="122 Bearish RevStrat Reversal", message="122 Bearish RevStrat Reversal detected on {{ticker}} {{interval}}")
alertcondition(sig122Bull, title="122 Bullish RevStrat Reversal", message="122 Bullish RevStrat Reversal detected on {{ticker}} {{interval}}")
alertcondition(sig22Bear,  title="22 Bearish Reversal", message="22 Bearish Reversal detected on {{ticker}} {{interval}}")
alertcondition(sig22Bull,  title="22 Bullish Reversal", message="22 Bullish Reversal detected on {{ticker}} {{interval}}")
alertcondition(sig3Bear,   title="3 Bearish RevStrat Reversal", message="3 Bearish RevStrat Reversal detected on {{ticker}} {{interval}}")
alertcondition(sig3Bull,   title="3 Bullish RevStrat Reversal", message="3 Bullish RevStrat Reversal detected on {{ticker}} {{interval}}")

//==================================================
// COMBINED ALERTS - REVSTRAT
//==================================================
anyBullish = sig32Bull or sig122Bull or sig22Bull or sig3Bull
anyBearish = sig32Bear or sig122Bear or sig22Bear or sig3Bear
anySignal  = anyBullish or anyBearish

alertcondition(anyBullish, title="Any Bullish Reversal", message="Bullish reversal detected on {{ticker}} {{interval}}")
alertcondition(anyBearish, title="Any Bearish Reversal", message="Bearish reversal detected on {{ticker}} {{interval}}")
alertcondition(anySignal,  title="Any RevStrat Reversal", message="RevStrat reversal detected on {{ticker}} {{interval}}")

//==================================================
// ALERT CONDITIONS - FTFC ALIGNMENT
//==================================================
alertcondition(enableAlignmentAlerts and newBullAlignment, title="30m 1H 4H Bullish Alignment", message="FTFC bullish alignment: 30m, 1H, and 4H are all bullish.")
alertcondition(enableAlignmentAlerts and newBearAlignment, title="30m 1H 4H Bearish Alignment", message="FTFC bearish alignment: 30m, 1H, and 4H are all bearish.")

//==================================================
// OPTIONAL DYNAMIC ALERT()
//==================================================
signalText =
     sig32Bear  ? "32 Bearish Reversal" :
     sig32Bull  ? "32 Bullish Reversal" :
     sig122Bear ? "122 Bearish RevStrat Reversal" :
     sig122Bull ? "122 Bullish RevStrat Reversal" :
     sig22Bear  ? "22 Bearish Reversal" :
     sig22Bull  ? "22 Bullish Reversal" :
     sig3Bear   ? "3 Bearish RevStrat Reversal" :
     sig3Bull   ? "3 Bullish RevStrat Reversal" :
     ""

if signalText != ""
    alert(signalText + " detected on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)
````
