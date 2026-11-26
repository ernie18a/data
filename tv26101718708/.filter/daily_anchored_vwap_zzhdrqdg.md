# Daily + Anchored VWAP

- url: https://www.tradingview.com/script/ZZhDrqdG-Daily-Anchored-VWAP/
- type: indicator
- pine_id: PUB;af2b5b1f0ba94fc7a6858c22de463e88
- version: 6.0

## Description

**Daily VWAP + Anchored VWAP (RTH / Full Session Toggle)**

This script provides a clean and reliable implementation of Daily VWAP along with an Anchored VWAP, designed to behave consistently across different session types and chart settings.

The Daily VWAP automatically resets each day based on the selected mode. In RTH mode, it resets on the first regular-session bar and only includes regular trading hours. In Full Session mode, it resets on the first bar of the day and includes all available price data. The calculation uses a proper cumulative price × volume divided by volume approach, ensuring accuracy with no gaps or delayed starts on the opening candle.

The script includes a historical display control that allows switching between showing only the current trading day or displaying a configurable number of previous trading days. The “today only” mode is handled using chart-based date detection, which avoids the common issues seen in other VWAP scripts where the first bars of the session are incorrectly excluded.

An Anchored VWAP is also included, which starts from the first session bar of a user-defined number of trading days back and accumulates forward to the present. This anchored VWAP operates independently from the daily VWAP visibility settings and remains stable regardless of whether historical display is enabled or not.

A session toggle allows switching between RTH-only behavior and full-session behavior. This setting applies consistently to both the Daily VWAP and Anchored VWAP, making it easy to compare how price interacts with VWAP under different session definitions.

This script is designed to avoid common VWAP issues such as incorrect start points, broken “today only” filtering, and inconsistent handling of extended hours. The logic separates reset conditions, accumulation, and display filtering to ensure stable and predictable output.

This tool is useful for intraday trading, tracking institutional positioning, anchoring VWAP to recent sessions, and analyzing price behavior across different session types.

Anchored VWAP requires sufficient historical data on the chart to include the selected anchor start point. Behavior may vary slightly depending on the symbol’s session definition and chart settings.

Built for precision and reliability, with a focus on correct behavior in real trading conditions.

## Source Code

````pine
//@version=6
indicator('Daily VWAP + Anchored VWAP + Daily StdDev Bands', shorttitle = 'Daily VWAP', overlay = true)

//────────────────────────────────────────────────────────────────────
// TOP-LEVEL INPUTS
//────────────────────────────────────────────────────────────────────
useSession  = input.bool(true, 'Use Custom Session')
sessionTime = input.session('0930-1600', 'Session Time')
src = input.source(hlc3, 'Source')

//────────────────────────────────────────────────────────────────────
// DAILY VWAP INPUTS
//────────────────────────────────────────────────────────────────────
showDailyVWAP = input.bool(true, 'Show Daily VWAP')
dailyColor = input.color(color.orange, 'Daily VWAP Color')
dailyWidth = input.int(3, 'Daily VWAP Width', minval = 1, maxval = 5)

showHistoricalLookback = input.bool(true, 'Show Historical Daily VWAP Lookback')
dailyLookbackDays = input.int(10, 'Show Daily VWAP For Last X Trading Days', minval = 1, maxval = 100)

//────────────────────────────────────────────────────────────────────
// ANCHORED VWAP INPUTS
//────────────────────────────────────────────────────────────────────
showAnchoredVWAP = input.bool(false, 'Show Anchored VWAP')
anchorColor = input.color(color.blue, 'Anchored VWAP Color')
anchorWidth = input.int(2, 'Anchored VWAP Width', minval = 1, maxval = 5)

anchorDaysBack = input.int(2, 'Anchor VWAP Starting X Trading Days Back', minval = 1, maxval = 100)

//────────────────────────────────────────────────────────────────────
// DAILY VWAP STDDEV BANDS
//────────────────────────────────────────────────────────────────────
showDailyBands = input.bool(false, 'Show Daily VWAP StdDev Bands', group = 'Daily VWAP StdDev Bands')

// Band 1
showSd1 = input.bool(false, 'Show Band 1', group = 'Daily VWAP StdDev Bands')
sd1Multiplier = input.float(0.5, 'Band 1 StdDev Multiplier', minval = 0.0, step = 0.25, group = 'Daily VWAP StdDev Bands')
sd1Color = input.color(color.new(color.gray, 0), 'Band 1 Color', group = 'Daily VWAP StdDev Bands')
sd1Width = input.int(1, 'Band 1 Width', minval = 1, maxval = 5, group = 'Daily VWAP StdDev Bands')
sd1Style = input.string('Solid', 'Band 1 Style', options = ['Solid', 'Stepline', 'Circles'], group = 'Daily VWAP StdDev Bands')

// Band 2
showSd2 = input.bool(true, 'Show Band 2', group = 'Daily VWAP StdDev Bands')
sd2Multiplier = input.float(1.0, 'Band 2 StdDev Multiplier', minval = 0.0, step = 0.25, group = 'Daily VWAP StdDev Bands')
sd2Color = input.color(color.new(color.green, 20), 'Band 2 Color', group = 'Daily VWAP StdDev Bands')
sd2Width = input.int(1, 'Band 2 Width', minval = 1, maxval = 5, group = 'Daily VWAP StdDev Bands')
sd2Style = input.string('Solid', 'Band 2 Style', options = ['Solid', 'Stepline', 'Circles'], group = 'Daily VWAP StdDev Bands')

// Band 3
showSd3 = input.bool(true, 'Show Band 3', group = 'Daily VWAP StdDev Bands')
sd3Multiplier = input.float(2.0, 'Band 3 StdDev Multiplier', minval = 0.0, step = 0.25, group = 'Daily VWAP StdDev Bands')
sd3Color = input.color(color.new(color.blue, 40), 'Band 3 Color', group = 'Daily VWAP StdDev Bands')
sd3Width = input.int(1, 'Band 3 Width', minval = 1, maxval = 5, group = 'Daily VWAP StdDev Bands')
sd3Style = input.string('Solid', 'Band 3 Style', options = ['Solid', 'Stepline', 'Circles'], group = 'Daily VWAP StdDev Bands')

//────────────────────────────────────────────────────────────────────
// SESSION LOGIC
//────────────────────────────────────────────────────────────────────
inSession  = not na(time(timeframe.period, sessionTime))
newSession = inSession and not inSession[1]
newDay     = ta.change(time('D')) != 0

countBar = useSession ? inSession : true
resetBar = useSession ? newSession : newDay

//────────────────────────────────────────────────────────────────────
// TRADING DAY LOOKBACK
//────────────────────────────────────────────────────────────────────
dailyIndex = request.security(syminfo.tickerid, 'D', bar_index, barmerge.gaps_off, barmerge.lookahead_off)
lastDailyIndex = request.security(syminfo.tickerid, 'D', last_bar_index, barmerge.gaps_off, barmerge.lookahead_off)

tradingDaysBack = lastDailyIndex - dailyIndex

//────────────────────────────────────────────────────────────────────
// CURRENT CHART DATE
//────────────────────────────────────────────────────────────────────
isToday = year(time) == year(last_bar_time) and month(time) == month(last_bar_time) and dayofmonth(time) == dayofmonth(last_bar_time)

//────────────────────────────────────────────────────────────────────
// DAILY VWAP + STDDEV BANDS
//────────────────────────────────────────────────────────────────────
var float dayCumPV = na
var float dayCumVol = na
var float dayCumPV2 = na

if barstate.isfirst or resetBar
    dayCumPV := countBar ? src * volume : na
    dayCumVol := countBar ? volume : na
    dayCumPV2 := countBar ? src * src * volume : na
    dayCumPV2
else if countBar
    dayCumPV := nz(dayCumPV) + src * volume
    dayCumVol := nz(dayCumVol) + volume
    dayCumPV2 := nz(dayCumPV2) + src * src * volume
    dayCumPV2

dailyVWAP = dayCumVol > 0 ? dayCumPV / dayCumVol : na
dailyVar = dayCumVol > 0 ? math.max(dayCumPV2 / dayCumVol - dailyVWAP * dailyVWAP, 0) : na
dailyDev = math.sqrt(dailyVar)

showDailyThisBar = showDailyVWAP and (showHistoricalLookback ? tradingDaysBack >= 0 and tradingDaysBack < dailyLookbackDays : isToday)
plotDailyBar = showDailyThisBar and countBar

sd1Upper = plotDailyBar and showDailyBands and showSd1 ? dailyVWAP + dailyDev * sd1Multiplier : na
sd1Lower = plotDailyBar and showDailyBands and showSd1 ? dailyVWAP - dailyDev * sd1Multiplier : na

sd2Upper = plotDailyBar and showDailyBands and showSd2 ? dailyVWAP + dailyDev * sd2Multiplier : na
sd2Lower = plotDailyBar and showDailyBands and showSd2 ? dailyVWAP - dailyDev * sd2Multiplier : na

sd3Upper = plotDailyBar and showDailyBands and showSd3 ? dailyVWAP + dailyDev * sd3Multiplier : na
sd3Lower = plotDailyBar and showDailyBands and showSd3 ? dailyVWAP - dailyDev * sd3Multiplier : na

plot(plotDailyBar ? dailyVWAP : na, 'Daily VWAP', dailyColor, math.max(1, dailyWidth), plot.style_linebr)

// Band 1
plot(sd1Style == 'Solid' ? sd1Upper : na, 'Band 1 Upper Solid', sd1Color, math.max(1, sd1Width), plot.style_line)
plot(sd1Style == 'Solid' ? sd1Lower : na, 'Band 1 Lower Solid', sd1Color, math.max(1, sd1Width), plot.style_line)

plot(sd1Style == 'Stepline' ? sd1Upper : na, 'Band 1 Upper Stepline', sd1Color, math.max(1, sd1Width), plot.style_stepline)
plot(sd1Style == 'Stepline' ? sd1Lower : na, 'Band 1 Lower Stepline', sd1Color, math.max(1, sd1Width), plot.style_stepline)

plot(sd1Style == 'Circles' ? sd1Upper : na, 'Band 1 Upper Circles', sd1Color, math.max(1, sd1Width), plot.style_circles)
plot(sd1Style == 'Circles' ? sd1Lower : na, 'Band 1 Lower Circles', sd1Color, math.max(1, sd1Width), plot.style_circles)

// Band 2
plot(sd2Style == 'Solid' ? sd2Upper : na, 'Band 2 Upper Solid', sd2Color, math.max(1, sd2Width), plot.style_line)
plot(sd2Style == 'Solid' ? sd2Lower : na, 'Band 2 Lower Solid', sd2Color, math.max(1, sd2Width), plot.style_line)

plot(sd2Style == 'Stepline' ? sd2Upper : na, 'Band 2 Upper Stepline', sd2Color, math.max(1, sd2Width), plot.style_stepline)
plot(sd2Style == 'Stepline' ? sd2Lower : na, 'Band 2 Lower Stepline', sd2Color, math.max(1, sd2Width), plot.style_stepline)

plot(sd2Style == 'Circles' ? sd2Upper : na, 'Band 2 Upper Circles', sd2Color, math.max(1, sd2Width), plot.style_circles)
plot(sd2Style == 'Circles' ? sd2Lower : na, 'Band 2 Lower Circles', sd2Color, math.max(1, sd2Width), plot.style_circles)

// Band 3
plot(sd3Style == 'Solid' ? sd3Upper : na, 'Band 3 Upper Solid', sd3Color, math.max(1, sd3Width), plot.style_line)
plot(sd3Style == 'Solid' ? sd3Lower : na, 'Band 3 Lower Solid', sd3Color, math.max(1, sd3Width), plot.style_line)

plot(sd3Style == 'Stepline' ? sd3Upper : na, 'Band 3 Upper Stepline', sd3Color, math.max(1, sd3Width), plot.style_stepline)
plot(sd3Style == 'Stepline' ? sd3Lower : na, 'Band 3 Lower Stepline', sd3Color, math.max(1, sd3Width), plot.style_stepline)

plot(sd3Style == 'Circles' ? sd3Upper : na, 'Band 3 Upper Circles', sd3Color, math.max(1, sd3Width), plot.style_circles)
plot(sd3Style == 'Circles' ? sd3Lower : na, 'Band 3 Lower Circles', sd3Color, math.max(1, sd3Width), plot.style_circles)

//────────────────────────────────────────────────────────────────────
// ANCHORED VWAP — NO BANDS
//────────────────────────────────────────────────────────────────────
isAnchorDay = tradingDaysBack == anchorDaysBack
anchorStartBar = isAnchorDay and resetBar
anchorWindow = tradingDaysBack >= 0 and tradingDaysBack <= anchorDaysBack

var float anchorCumPV = na
var float anchorCumVol = na
var bool anchorLive = false

if barstate.isfirst
    anchorCumPV := na
    anchorCumVol := na
    anchorLive := false
    anchorLive
else if anchorStartBar and countBar
    anchorCumPV := src * volume
    anchorCumVol := volume
    anchorLive := true
    anchorLive
else if tradingDaysBack > anchorDaysBack
    anchorCumPV := na
    anchorCumVol := na
    anchorLive := false
    anchorLive
else if anchorWindow and anchorLive and countBar
    anchorCumPV := nz(anchorCumPV) + src * volume
    anchorCumVol := nz(anchorCumVol) + volume
    anchorCumVol

anchoredVWAP = anchorLive and anchorCumVol > 0 ? anchorCumPV / anchorCumVol : na
plotAnchorBar = showAnchoredVWAP and anchorWindow and countBar

plot(plotAnchorBar ? anchoredVWAP : na, 'Anchored VWAP', anchorColor, math.max(1, anchorWidth))
````
