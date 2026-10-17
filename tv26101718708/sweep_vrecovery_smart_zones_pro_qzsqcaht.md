# Sweep V-Recovery Smart Zones Pro

- url: https://www.tradingview.com/script/QZsQCaht-Sweep-V-Recovery-Smart-Zones-Pro/
- type: indicator
- pine_id: PUB;9dbfba67c7594096a20321e0932ec2d3
- version: 1.0

## Description

Sweep V-Recovery Smart Zones Pro is a smart-money style TradingView indicator designed to identify liquidity sweeps, fast V-shape recoveries, and high-quality retests into key zones such as Inversion Fair Value Gaps (IFVGs), Order Blocks (OBs), and Breaker Blocks.

The indicator is built to help traders focus on reversal and continuation setups that begin with a sweep of liquidity, followed by a sharp recovery, and then a retest into a valid bullish or bearish zone. This makes it especially useful for traders looking for structured entries rather than chasing the initial move.

In addition to the core signal logic, the script also maps and manages real-time Fair Value Gaps (FVGs), Inversion Fair Value Gaps (IFVGs), Order Blocks, and Breaker Blocks directly on the chart using customizable live boxes. Zones can be shown or hidden individually, their colors can be fully customized, and invalidated zones can automatically remove themselves to keep the chart cleaner.

A major feature of this indicator is its smart zone behavior. When enabled, broken FVGs can automatically convert into IFVGs, allowing the chart to update as market structure changes. The indicator can also preserve prior-session zones and lets the user define how many days of historical zones should remain visible, making it useful for both intraday and multi-day context.

The script also includes IFVG quality filters to reduce lower-probability signals. Users can require a minimum IFVG size in ticks, limit how far away the original FVG can be before the inversion is considered valid, and optionally block signals when price is trading inside a Balanced Price Range (BPR) or overlapping opposite-gap area.

For traders who want stronger confirmation, the indicator can also print a strong signal when an IFVG overlaps with an Order Block or Breaker Block in the same price area. This helps distinguish standard setups from higher-confluence setups.

What the indicator looks for
Long setup
Price sweeps a prior low
Price forms a V-shape recovery
Price retests a valid bullish IFVG, bullish OB, or bullish Breaker
A long signal appears when confirmation rules are met
Short setup
Price sweeps a prior high
Price forms an inverted V recovery
Price retests a valid bearish IFVG, bearish OB, or bearish Breaker
A short signal appears when confirmation rules are met
Features
Liquidity sweep detection
3-bar V-recovery logic
2-candle snapback recovery logic
Retest signal logic
Real-time FVG, IFVG, Order Block, and Breaker Block boxes
Optional automatic removal of broken zones
Optional FVG to IFVG conversion
Adjustable historical zone lookback
Optional BPR no-signal filter
Optional minimum IFVG size filter
Optional maximum bars from FVG to IFVG filter
Strong confirmation signals when IFVG overlaps OB or Breaker
Fully customizable colors and visibility settings
Built-in alerts
Designed for clean charting and flexible workflows
Recommended settings
These are the settings I found to work best:

Setting	Recommended Value
Zone Lookback Days	20
Minimum IFVG Size	20 ticks
Max Bars From FVG to IFVG	200
Sweep Lookback Bars	30
Recovery Window Bars	2
Retest Window Bars	15
Best use
This indicator is best suited for intraday trading, especially on markets where liquidity sweeps and fast recoveries are common. It works well for traders who want to combine price action, smart-money zone mapping, and clean retest entries into one workflow.

Notes
FVG, IFVG, Order Block, Breaker Block, and BPR logic are rule-based and designed for consistent automation in Pine Script. Because of that, they may not perfectly match every discretionary interpretation, but they provide a practical and structured framework for real-time analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © elsrodriguez1

//@version=6
indicator("Sweep V-Recovery Smart Zones Pro", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)
//====================================================
// INPUTS
//====================================================
groupDisplay = "Display / Timeframe"
showOnlyOnTF = input.bool(false, "Limit display to chart timeframe range", group=groupDisplay)
minChartTFMin = input.int(1, "Min Chart TF (minutes)", minval=1, group=groupDisplay)
maxChartTFMin = input.int(30, "Max Chart TF (minutes)", minval=1, group=groupDisplay)
groupPattern = "Pattern Logic"
sweepLookback = input.int(5, "Sweep Lookback Bars", minval=2, maxval=100, group=groupPattern)
recoveryWindowBars = input.int(3, "Recovery Window Bars", minval=1, maxval=10, group=groupPattern)
retestWindowBars = input.int(10, "Retest Window Bars", minval=1, maxval=50, group=groupPattern)
useThreeBarV = input.bool(true, "Use 3-Bar V Recovery", group=groupPattern)
useTwoBarSnapback = input.bool(true, "Use 2-Bar Snapback Recovery", group=groupPattern)
requireDisplacement = input.bool(true, "Require ATR Displacement On Recovery", group=groupPattern)
atrLen = input.int(14, "ATR Length", minval=1, group=groupPattern)
atrRecoveryMult = input.float(0.20, "Recovery Body ATR Multiplier", minval=0.0, step=0.01, group=groupPattern)
requireBullBearConfirm = input.bool(true, "Require Bull/Bear Confirmation On Retest", group=groupPattern)
allowMultipleLongSignals = input.bool(false, "Allow Multiple Long Signals Per Recovery", group=groupPattern)
allowMultipleShortSignals = input.bool(false, "Allow Multiple Short Signals Per Recovery", group=groupPattern)
groupSignalZones = "Signal Zone Filters"
useIFVGForSignals = input.bool(true, "Use IFVG For Signals", group=groupSignalZones)
useBreakerForSignals = input.bool(true, "Use Breaker For Signals", group=groupSignalZones)
useOBForSignals = input.bool(true, "Use Order Block For Signals", group=groupSignalZones)
groupIFVGFilters = "IFVG Filters"
useMinIFVGSizeFilter = input.bool(true, "Use Minimum IFVG Size Filter", group=groupIFVGFilters)
minIFVGSizeTicks = input.int(20, "Minimum IFVG Size (ticks)", minval=1, group=groupIFVGFilters)
useMaxBarsFromFVGToIFVG = input.bool(true, "Use Max Bars From FVG To IFVG", group=groupIFVGFilters)
maxBarsFromFVGToIFVG = input.int(10, "Max Bars From FVG To IFVG", minval=1, maxval=200, group=groupIFVGFilters)
groupBPR = "BPR Filter"
blockSignalsInBPR = input.bool(true, "Block Signals In BPR", group=groupBPR)
bprOverlapToleranceTicks = input.int(2, "BPR Overlap Tolerance (ticks)", minval=0, group=groupBPR)
groupStrong = "Strong Confirmation Signals"
showStrongSignals = input.bool(true, "Show Strong Signals", group=groupStrong)
requireIFVGOverlapWithOBForStrong = input.bool(true, "Require IFVG + OB Overlap For Strong Signal", group=groupStrong)
requireIFVGOverlapWithBreakerForStrong = input.bool(true, "Require IFVG + Breaker Overlap For Strong Signal", group=groupStrong)
zoneOverlapToleranceTicks = input.int(2, "Zone Overlap Tolerance (ticks)", minval=0, group=groupStrong)
groupConfluence = "Zone Detection"
detectFVG = input.bool(true, "Detect Fair Value Gaps", group=groupConfluence)
detectOB = input.bool(true, "Detect Order Blocks", group=groupConfluence)
detectBreaker = input.bool(true, "Detect Breaker Blocks", group=groupConfluence)
detectIFVG = input.bool(true, "Detect Inversion Fair Value Gaps", group=groupConfluence)
useStrictStructure = input.bool(true, "Use Stricter Structure Rules", group=groupConfluence)
groupStyle = "Signal Style"
showLabels = input.bool(true, "Show Labels", group=groupStyle)
showShapes = input.bool(true, "Show Shapes", group=groupStyle)
labelSizeInput = input.string("small", "Label Size", options=["tiny", "small", "normal"], group=groupStyle)
baseLongColor = input.color(color.new(color.lime, 0), "Base Long Color", group=groupStyle)
baseShortColor = input.color(color.new(color.red, 0), "Base Short Color", group=groupStyle)
ifvgLongColor = input.color(color.new(color.teal, 0), "Long Signal in IFVG", group=groupStyle)
ifvgShortColor = input.color(color.new(color.navy, 0), "Short Signal in IFVG", group=groupStyle)
obLongColor = input.color(color.new(color.orange, 0), "Long Signal in Order Block", group=groupStyle)
obShortColor = input.color(color.new(color.purple, 0), "Short Signal in Order Block", group=groupStyle)
breakerLongColor = input.color(color.new(color.yellow, 0), "Long Signal in Breaker", group=groupStyle)
breakerShortColor = input.color(color.new(color.fuchsia, 0), "Short Signal in Breaker", group=groupStyle)
strongLongColor = input.color(color.new(color.green, 0), "Strong Long Signal", group=groupStyle)
strongShortColor = input.color(color.new(color.maroon, 0), "Strong Short Signal", group=groupStyle)
longTextColor = input.color(color.black, "Long Label Text", group=groupStyle)
shortTextColor = input.color(color.white, "Short Label Text", group=groupStyle)
groupDebug = "Optional Line Plots"
showFVGZones = input.bool(false, "Show FVG Zone Lines", group=groupDebug)
showOBZones = input.bool(false, "Show Order Block Zone Lines", group=groupDebug)
showBreakerZones = input.bool(false, "Show Breaker Zone Lines", group=groupDebug)
showIFVGZones = input.bool(false, "Show IFVG Zone Lines", group=groupDebug)
groupBoxes = "Live Zone Boxes"
showFVGBoxes = input.bool(true, "Show FVG Boxes", group=groupBoxes)
showIFVGBoxes = input.bool(true, "Show IFVG Boxes", group=groupBoxes)
showOBBoxes = input.bool(true, "Show Order Block Boxes", group=groupBoxes)
showBreakerBoxes = input.bool(true, "Show Breaker Boxes", group=groupBoxes)
removeBrokenZones = input.bool(true, "Remove Broken Zones", group=groupBoxes)
convertBrokenFVGToIFVG = input.bool(true, "Convert Broken FVG To IFVG", group=groupBoxes)
keepZonesAcrossDays = input.bool(true, "Keep Zones Across Days", group=groupBoxes)
zoneLookbackDays = input.int(3, "Zone Lookback Days", minval=1, maxval=30, group=groupBoxes)
zoneExtendBars = input.int(25, "Zone Extend Bars", minval=1, maxval=500, group=groupBoxes)
maxZonesToKeep = input.int(20, "Max Zones To Keep Per Type", minval=1, maxval=100, group=groupBoxes)
bullFVGFill = input.color(color.new(color.aqua, 85), "Bull FVG Fill", group=groupBoxes)
bullFVGBorder = input.color(color.aqua, "Bull FVG Border", group=groupBoxes)
bearFVGFill = input.color(color.new(color.blue, 85), "Bear FVG Fill", group=groupBoxes)
bearFVGBorder = input.color(color.blue, "Bear FVG Border", group=groupBoxes)
bullIFVGFill = input.color(color.new(color.teal, 82), "Bull IFVG Fill", group=groupBoxes)
bullIFVGBorder = input.color(color.teal, "Bull IFVG Border", group=groupBoxes)
bearIFVGFill = input.color(color.new(color.navy, 82), "Bear IFVG Fill", group=groupBoxes)
bearIFVGBorder = input.color(color.navy, "Bear IFVG Border", group=groupBoxes)
bullOBFill = input.color(color.new(color.orange, 85), "Bull OB Fill", group=groupBoxes)
bullOBBorder = input.color(color.orange, "Bull OB Border", group=groupBoxes)
bearOBFill = input.color(color.new(color.purple, 85), "Bear OB Fill", group=groupBoxes)
bearOBBorder = input.color(color.purple, "Bear OB Border", group=groupBoxes)
bullBreakerFill = input.color(color.new(color.yellow, 85), "Bull Breaker Fill", group=groupBoxes)
bullBreakerBorder = input.color(color.yellow, "Bull Breaker Border", group=groupBoxes)
bearBreakerFill = input.color(color.new(color.fuchsia, 85), "Bear Breaker Fill", group=groupBoxes)
bearBreakerBorder = input.color(color.fuchsia, "Bear Breaker Border", group=groupBoxes)
//====================================================
// HELPERS
//====================================================
labelSize = labelSizeInput == "tiny" ? size.tiny : labelSizeInput == "normal" ? size.normal : size.small
tickSize = syminfo.mintick
atr = ta.atr(atrLen)
bodySize = math.abs(close - open)
bullBody = close > open
bearBody = close < open
avgBody = ta.sma(math.abs(close - open), 10)
newDay = ta.change(time("D")) != 0
float chartTfMinutes = na
if timeframe.isseconds
    chartTfMinutes := timeframe.multiplier / 60.0
else if timeframe.isminutes
    chartTfMinutes := timeframe.multiplier * 1.0
else if timeframe.isdaily
    chartTfMinutes := 1440.0
else if timeframe.isweekly
    chartTfMinutes := 10080.0
else if timeframe.ismonthly
    chartTfMinutes := 43200.0
else
    chartTfMinutes := na
tfAllowed = not showOnlyOnTF or (not na(chartTfMinutes) and chartTfMinutes >= minChartTFMin and chartTfMinutes <= maxChartTFMin)
zoneAgeMsLimit = zoneLookbackDays * 24 * 60 * 60 * 1000
bprTolerance = bprOverlapToleranceTicks * tickSize
zoneOverlapTolerance = zoneOverlapToleranceTicks * tickSize
minIFVGSize = minIFVGSizeTicks * tickSize
cleanupOldBoxes(box[] bxArr, int keepCount) =>
    while array.size(bxArr) > keepCount
        oldBox = array.shift(bxArr)
        box.delete(oldBox)
clearBoxes(box[] bxArr) =>
    while array.size(bxArr) > 0
        lastBox = array.pop(bxArr)
        box.delete(lastBox)
trimBoxesByTime(box[] bxArr, int[] timeArr, int maxAgeMs) =>
    int idx = array.size(bxArr) - 1
    while idx >= 0
        bxTime = array.get(timeArr, idx)
        if time - bxTime > maxAgeMs
            bx = array.get(bxArr, idx)
            box.delete(bx)
            array.remove(bxArr, idx)
            array.remove(timeArr, idx)
        idx := idx - 1
pushZone(box[] bxArr, int[] timeArr, box bx, int bxTime, int keepCount) =>
    array.push(bxArr, bx)
    array.push(timeArr, bxTime)
    while array.size(bxArr) > keepCount
        oldBox = array.shift(bxArr)
        box.delete(oldBox)
        array.shift(timeArr)
rangesOverlap(float top1, float bot1, float top2, float bot2, float tol) =>
    math.max(bot1, bot2) <= math.min(top1, top2) + tol
//====================================================
// STATE
//====================================================
var float bullFVGTop = na
var float bullFVGBot = na
var int bullFVGBar = na
var float bearFVGTop = na
var float bearFVGBot = na
var int bearFVGBar = na
var float bullIFVGTop = na
var float bullIFVGBot = na
var int bullIFVGBar = na
var int bullIFVGSourceFVGBar = na
var float bearIFVGTop = na
var float bearIFVGBot = na
var int bearIFVGBar = na
var int bearIFVGSourceFVGBar = na
var float bullOBTop = na
var float bullOBBot = na
var int bullOBBar = na
var float bearOBTop = na
var float bearOBBot = na
var int bearOBBar = na
var float bullBreakerTop = na
var float bullBreakerBot = na
var int bullBreakerBar = na
var float bearBreakerTop = na
var float bearBreakerBot = na
var int bearBreakerBar = na
var box[] bullFVGBoxes = array.new_box()
var box[] bearFVGBoxes = array.new_box()
var box[] bullIFVGBoxes = array.new_box()
var box[] bearIFVGBoxes = array.new_box()
var box[] bullOBBoxes = array.new_box()
var box[] bearOBBoxes = array.new_box()
var box[] bullBreakerBoxes = array.new_box()
var box[] bearBreakerBoxes = array.new_box()
var int[] bullFVGTimes = array.new_int()
var int[] bearFVGTimes = array.new_int()
var int[] bullIFVGTimes = array.new_int()
var int[] bearIFVGTimes = array.new_int()
var int[] bullOBTimes = array.new_int()
var int[] bearOBTimes = array.new_int()
var int[] bullBreakerTimes = array.new_int()
var int[] bearBreakerTimes = array.new_int()
var bool longRecoveryActive = false
var bool shortRecoveryActive = false
var int longSweepBar = na
var int shortSweepBar = na
var float longSweepHigh = na
var float longSweepLow = na
var float shortSweepHigh = na
var float shortSweepLow = na
var bool longSignalTriggered = false
var bool shortSignalTriggered = false
//====================================================
// RESET / LOOKBACK
//====================================================
if newDay
    if not keepZonesAcrossDays
        clearBoxes(bullFVGBoxes)
        clearBoxes(bearFVGBoxes)
        clearBoxes(bullIFVGBoxes)
        clearBoxes(bearIFVGBoxes)
        clearBoxes(bullOBBoxes)
        clearBoxes(bearOBBoxes)
        clearBoxes(bullBreakerBoxes)
        clearBoxes(bearBreakerBoxes)
        array.clear(bullFVGTimes)
        array.clear(bearFVGTimes)
        array.clear(bullIFVGTimes)
        array.clear(bearIFVGTimes)
        array.clear(bullOBTimes)
        array.clear(bearOBTimes)
        array.clear(bullBreakerTimes)
        array.clear(bearBreakerTimes)
if keepZonesAcrossDays
    trimBoxesByTime(bullFVGBoxes, bullFVGTimes, zoneAgeMsLimit)
    trimBoxesByTime(bearFVGBoxes, bearFVGTimes, zoneAgeMsLimit)
    trimBoxesByTime(bullIFVGBoxes, bullIFVGTimes, zoneAgeMsLimit)
    trimBoxesByTime(bearIFVGBoxes, bearIFVGTimes, zoneAgeMsLimit)
    trimBoxesByTime(bullOBBoxes, bullOBTimes, zoneAgeMsLimit)
    trimBoxesByTime(bearOBBoxes, bearOBTimes, zoneAgeMsLimit)
    trimBoxesByTime(bullBreakerBoxes, bullBreakerTimes, zoneAgeMsLimit)
    trimBoxesByTime(bearBreakerBoxes, bearBreakerTimes, zoneAgeMsLimit)
//====================================================
// ZONE DETECTION
//====================================================
bullFVG = detectFVG and bar_index >= 2 and low > high[2]
bearFVG = detectFVG and bar_index >= 2 and high < low[2]
if bullFVG
    bullFVGTop := low
    bullFVGBot := high[2]
    bullFVGBar := bar_index
    if showFVGBoxes
        bx = box.new(left=bar_index - 2, right=bar_index + zoneExtendBars, top=low, bottom=high[2], bgcolor=bullFVGFill, border_color=bullFVGBorder)
        pushZone(bullFVGBoxes, bullFVGTimes, bx, time, maxZonesToKeep)
if bearFVG
    bearFVGTop := low[2]
    bearFVGBot := high
    bearFVGBar := bar_index
    if showFVGBoxes
        bx = box.new(left=bar_index - 2, right=bar_index + zoneExtendBars, top=low[2], bottom=high, bgcolor=bearFVGFill, border_color=bearFVGBorder)
        pushZone(bearFVGBoxes, bearFVGTimes, bx, time, maxZonesToKeep)
bullIFVG = detectIFVG and not na(bearFVGTop) and close > bearFVGTop
bearIFVG = detectIFVG and not na(bullFVGBot) and close < bullFVGBot
if bullIFVG
    bullIFVGTop := bearFVGTop
    bullIFVGBot := bearFVGBot
    bullIFVGBar := bar_index
    bullIFVGSourceFVGBar := bearFVGBar
    if showIFVGBoxes
        bx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bullIFVGTop, bottom=bullIFVGBot, bgcolor=bullIFVGFill, border_color=bullIFVGBorder)
        pushZone(bullIFVGBoxes, bullIFVGTimes, bx, time, maxZonesToKeep)
if bearIFVG
    bearIFVGTop := bullFVGTop
    bearIFVGBot := bullFVGBot
    bearIFVGBar := bar_index
    bearIFVGSourceFVGBar := bullFVGBar
    if showIFVGBoxes
        bx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bearIFVGTop, bottom=bearIFVGBot, bgcolor=bearIFVGFill, border_color=bearIFVGBorder)
        pushZone(bearIFVGBoxes, bearIFVGTimes, bx, time, maxZonesToKeep)
bullDisplacement = close > high[1] and bullBody and (not useStrictStructure or bodySize > avgBody)
bearDisplacement = close < low[1] and bearBody and (not useStrictStructure or bodySize > avgBody)
if detectOB and bullDisplacement and close[1] < open[1]
    bullOBTop := open[1]
    bullOBBot := low[1]
    bullOBBar := bar_index
    if showOBBoxes
        bx = box.new(left=bar_index - 1, right=bar_index + zoneExtendBars, top=bullOBTop, bottom=bullOBBot, bgcolor=bullOBFill, border_color=bullOBBorder)
        pushZone(bullOBBoxes, bullOBTimes, bx, time, maxZonesToKeep)
if detectOB and bearDisplacement and close[1] > open[1]
    bearOBTop := high[1]
    bearOBBot := open[1]
    bearOBBar := bar_index
    if showOBBoxes
        bx = box.new(left=bar_index - 1, right=bar_index + zoneExtendBars, top=bearOBTop, bottom=bearOBBot, bgcolor=bearOBFill, border_color=bearOBBorder)
        pushZone(bearOBBoxes, bearOBTimes, bx, time, maxZonesToKeep)
bullBreakerCreated = detectBreaker and not na(bearOBTop) and close > bearOBTop
bearBreakerCreated = detectBreaker and not na(bullOBBot) and close < bullOBBot
if bullBreakerCreated
    bullBreakerTop := bearOBTop
    bullBreakerBot := bearOBBot
    bullBreakerBar := bar_index
    if showBreakerBoxes
        bx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bullBreakerTop, bottom=bullBreakerBot, bgcolor=bullBreakerFill, border_color=bullBreakerBorder)
        pushZone(bullBreakerBoxes, bullBreakerTimes, bx, time, maxZonesToKeep)
if bearBreakerCreated
    bearBreakerTop := bullOBTop
    bearBreakerBot := bullOBBot
    bearBreakerBar := bar_index
    if showBreakerBoxes
        bx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bearBreakerTop, bottom=bearBreakerBot, bgcolor=bearBreakerFill, border_color=bearBreakerBorder)
        pushZone(bearBreakerBoxes, bearBreakerTimes, bx, time, maxZonesToKeep)
//====================================================
// SMART ZONE CLEANUP / FVG -> IFVG
//====================================================
if removeBrokenZones
    int i1 = array.size(bullFVGBoxes) - 1
    while i1 >= 0
        bx = array.get(bullFVGBoxes, i1)
        bxTop = box.get_top(bx)
        bxBot = box.get_bottom(bx)
        if low < bxBot
            if convertBrokenFVGToIFVG and showIFVGBoxes
                newBx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bxTop, bottom=bxBot, bgcolor=bearIFVGFill, border_color=bearIFVGBorder)
                pushZone(bearIFVGBoxes, bearIFVGTimes, newBx, time, maxZonesToKeep)
                bearIFVGTop := bxTop
                bearIFVGBot := bxBot
                bearIFVGBar := bar_index
                bearIFVGSourceFVGBar := na
            box.delete(bx)
            array.remove(bullFVGBoxes, i1)
            array.remove(bullFVGTimes, i1)
        i1 := i1 - 1
    int i2 = array.size(bearFVGBoxes) - 1
    while i2 >= 0
        bx = array.get(bearFVGBoxes, i2)
        bxTop = box.get_top(bx)
        bxBot = box.get_bottom(bx)
        if high > bxTop
            if convertBrokenFVGToIFVG and showIFVGBoxes
                newBx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bxTop, bottom=bxBot, bgcolor=bullIFVGFill, border_color=bullIFVGBorder)
                pushZone(bullIFVGBoxes, bullIFVGTimes, newBx, time, maxZonesToKeep)
                bullIFVGTop := bxTop
                bullIFVGBot := bxBot
                bullIFVGBar := bar_index
                bullIFVGSourceFVGBar := na
            box.delete(bx)
            array.remove(bearFVGBoxes, i2)
            array.remove(bearFVGTimes, i2)
        i2 := i2 - 1
    int i3 = array.size(bullIFVGBoxes) - 1
    while i3 >= 0
        bx = array.get(bullIFVGBoxes, i3)
        bxBot = box.get_bottom(bx)
        if low < bxBot
            box.delete(bx)
            array.remove(bullIFVGBoxes, i3)
            array.remove(bullIFVGTimes, i3)
        i3 := i3 - 1
    int i4 = array.size(bearIFVGBoxes) - 1
    while i4 >= 0
        bx = array.get(bearIFVGBoxes, i4)
        bxTop = box.get_top(bx)
        if high > bxTop
            box.delete(bx)
            array.remove(bearIFVGBoxes, i4)
            array.remove(bearIFVGTimes, i4)
        i4 := i4 - 1
    int i5 = array.size(bullOBBoxes) - 1
    while i5 >= 0
        bx = array.get(bullOBBoxes, i5)
        bxBot = box.get_bottom(bx)
        if low < bxBot
            box.delete(bx)
            array.remove(bullOBBoxes, i5)
            array.remove(bullOBTimes, i5)
        i5 := i5 - 1
    int i6 = array.size(bearOBBoxes) - 1
    while i6 >= 0
        bx = array.get(bearOBBoxes, i6)
        bxTop = box.get_top(bx)
        if high > bxTop
            box.delete(bx)
            array.remove(bearOBBoxes, i6)
            array.remove(bearOBTimes, i6)
        i6 := i6 - 1
    int i7 = array.size(bullBreakerBoxes) - 1
    while i7 >= 0
        bx = array.get(bullBreakerBoxes, i7)
        bxBot = box.get_bottom(bx)
        if low < bxBot
            box.delete(bx)
            array.remove(bullBreakerBoxes, i7)
            array.remove(bullBreakerTimes, i7)
        i7 := i7 - 1
    int i8 = array.size(bearBreakerBoxes) - 1
    while i8 >= 0
        bx = array.get(bearBreakerBoxes, i8)
        bxTop = box.get_top(bx)
        if high > bxTop
            box.delete(bx)
            array.remove(bearBreakerBoxes, i8)
            array.remove(bearBreakerTimes, i8)
        i8 := i8 - 1
//====================================================
// TOGGLE CLEANUP
//====================================================
if not showFVGBoxes
    clearBoxes(bullFVGBoxes)
    clearBoxes(bearFVGBoxes)
    array.clear(bullFVGTimes)
    array.clear(bearFVGTimes)
if not showIFVGBoxes
    clearBoxes(bullIFVGBoxes)
    clearBoxes(bearIFVGBoxes)
    array.clear(bullIFVGTimes)
    array.clear(bearIFVGTimes)
if not showOBBoxes
    clearBoxes(bullOBBoxes)
    clearBoxes(bearOBBoxes)
    array.clear(bullOBTimes)
    array.clear(bearOBTimes)
if not showBreakerBoxes
    clearBoxes(bullBreakerBoxes)
    clearBoxes(bearBreakerBoxes)
    array.clear(bullBreakerTimes)
    array.clear(bearBreakerTimes)
//====================================================
// SWEEP DETECTION
//====================================================
priorLowest = ta.lowest(low, sweepLookback)[1]
priorHighest = ta.highest(high, sweepLookback)[1]
longSweep = bar_index > sweepLookback and low < priorLowest
shortSweep = bar_index > sweepLookback and high > priorHighest
if longSweep
    longSweepBar := bar_index
    longSweepHigh := high
    longSweepLow := low
    longRecoveryActive := false
    longSignalTriggered := false
if shortSweep
    shortSweepBar := bar_index
    shortSweepHigh := high
    shortSweepLow := low
    shortRecoveryActive := false
    shortSignalTriggered := false
//====================================================
// RECOVERY DETECTION
//====================================================
float longSweepMid = na
float shortSweepMid = na
if not na(longSweepHigh) and not na(longSweepLow)
    longSweepMid := (longSweepHigh + longSweepLow) / 2.0
if not na(shortSweepHigh) and not na(shortSweepLow)
    shortSweepMid := (shortSweepHigh + shortSweepLow) / 2.0
longRecoveryThreeBar = useThreeBarV and not na(longSweepBar) and bar_index > longSweepBar and (bar_index - longSweepBar <= recoveryWindowBars) and not na(longSweepMid) and close > longSweepMid and (not requireDisplacement or bodySize >= atr * atrRecoveryMult)
shortRecoveryThreeBar = useThreeBarV and not na(shortSweepBar) and bar_index > shortSweepBar and (bar_index - shortSweepBar <= recoveryWindowBars) and not na(shortSweepMid) and close < shortSweepMid and (not requireDisplacement or bodySize >= atr * atrRecoveryMult)
longRecoveryTwoBar = useTwoBarSnapback and bar_index >= 1 and open[1] > close[1] and close > open and low < low[1] and close > open[1] and (not requireDisplacement or bodySize >= atr * atrRecoveryMult)
shortRecoveryTwoBar = useTwoBarSnapback and bar_index >= 1 and close[1] > open[1] and close < open and high > high[1] and close < open[1] and (not requireDisplacement or bodySize >= atr * atrRecoveryMult)
if longRecoveryThreeBar or (longRecoveryTwoBar and not na(longSweepBar) and (bar_index - longSweepBar <= recoveryWindowBars))
    longRecoveryActive := true
if shortRecoveryThreeBar or (shortRecoveryTwoBar and not na(shortSweepBar) and (bar_index - shortSweepBar <= recoveryWindowBars))
    shortRecoveryActive := true
if not na(longSweepBar) and (bar_index - longSweepBar > recoveryWindowBars) and not longRecoveryActive
    longSweepBar := na
    longSweepHigh := na
    longSweepLow := na
if not na(shortSweepBar) and (bar_index - shortSweepBar > recoveryWindowBars) and not shortRecoveryActive
    shortSweepBar := na
    shortSweepHigh := na
    shortSweepLow := na
//====================================================
// SIGNAL ZONE TOUCH
//====================================================
inBullIFVG = useIFVGForSignals and detectIFVG and not na(bullIFVGTop) and not na(bullIFVGBot) and low <= bullIFVGTop and high >= bullIFVGBot
inBearIFVG = useIFVGForSignals and detectIFVG and not na(bearIFVGTop) and not na(bearIFVGBot) and high >= bearIFVGBot and low <= bearIFVGTop
inBullOB = useOBForSignals and detectOB and not na(bullOBTop) and not na(bullOBBot) and low <= bullOBTop and high >= bullOBBot
inBearOB = useOBForSignals and detectOB and not na(bearOBTop) and not na(bearOBBot) and high >= bearOBBot and low <= bearOBTop
inBullBreaker = useBreakerForSignals and detectBreaker and not na(bullBreakerTop) and not na(bullBreakerBot) and low <= bullBreakerTop and high >= bullBreakerBot
inBearBreaker = useBreakerForSignals and detectBreaker and not na(bearBreakerTop) and not na(bearBreakerBot) and high >= bearBreakerBot and low <= bearBreakerTop
longRetestZone = inBullIFVG or inBullOB or inBullBreaker
shortRetestZone = inBearIFVG or inBearOB or inBearBreaker
longRetestConfirm = requireBullBearConfirm ? close > open : true
shortRetestConfirm = requireBullBearConfirm ? close < open : true
longRecoveryWindowValid = longRecoveryActive and not na(longSweepBar) and (bar_index - longSweepBar <= retestWindowBars + recoveryWindowBars)
shortRecoveryWindowValid = shortRecoveryActive and not na(shortSweepBar) and (bar_index - shortSweepBar <= retestWindowBars + recoveryWindowBars)
//====================================================
// IFVG FILTERS
//====================================================
bullIFVGSize = not na(bullIFVGTop) and not na(bullIFVGBot) ? (bullIFVGTop - bullIFVGBot) : na
bearIFVGSize = not na(bearIFVGTop) and not na(bearIFVGBot) ? (bearIFVGTop - bearIFVGBot) : na
bullIFVGSizePass = not useMinIFVGSizeFilter or (not na(bullIFVGSize) and bullIFVGSize >= minIFVGSize)
bearIFVGSizePass = not useMinIFVGSizeFilter or (not na(bearIFVGSize) and bearIFVGSize >= minIFVGSize)
bullIFVGAgePass = not useMaxBarsFromFVGToIFVG or (not na(bullIFVGSourceFVGBar) and not na(bullIFVGBar) and (bullIFVGBar - bullIFVGSourceFVGBar <= maxBarsFromFVGToIFVG))
bearIFVGAgePass = not useMaxBarsFromFVGToIFVG or (not na(bearIFVGSourceFVGBar) and not na(bearIFVGBar) and (bearIFVGBar - bearIFVGSourceFVGBar <= maxBarsFromFVGToIFVG))
bullIFVGPass = bullIFVGSizePass and bullIFVGAgePass
bearIFVGPass = bearIFVGSizePass and bearIFVGAgePass
longIFVGSignalAllowed = inBullIFVG and bullIFVGPass
shortIFVGSignalAllowed = inBearIFVG and bearIFVGPass
//====================================================
// BPR FILTER
//====================================================
bullBearFVGOverlap = not na(bullFVGTop) and not na(bullFVGBot) and not na(bearFVGTop) and not na(bearFVGBot) and rangesOverlap(bullFVGTop, bullFVGBot, bearFVGTop, bearFVGBot, bprTolerance)
bullBearIFVGOverlap = not na(bullIFVGTop) and not na(bullIFVGBot) and not na(bearIFVGTop) and not na(bearIFVGBot) and rangesOverlap(bullIFVGTop, bullIFVGBot, bearIFVGTop, bearIFVGBot, bprTolerance)
inBPR = bullBearFVGOverlap or bullBearIFVGOverlap
bprPass = not blockSignalsInBPR or not inBPR
//====================================================
// STRONG OVERLAP LOGIC
//====================================================
bullIFVG_OB_Overlap = not na(bullIFVGTop) and not na(bullIFVGBot) and not na(bullOBTop) and not na(bullOBBot) and rangesOverlap(bullIFVGTop, bullIFVGBot, bullOBTop, bullOBBot, zoneOverlapTolerance)
bullIFVG_Breaker_Overlap = not na(bullIFVGTop) and not na(bullIFVGBot) and not na(bullBreakerTop) and not na(bullBreakerBot) and rangesOverlap(bullIFVGTop, bullIFVGBot, bullBreakerTop, bullBreakerBot, zoneOverlapTolerance)
bearIFVG_OB_Overlap = not na(bearIFVGTop) and not na(bearIFVGBot) and not na(bearOBTop) and not na(bearOBBot) and rangesOverlap(bearIFVGTop, bearIFVGBot, bearOBTop, bearOBBot, zoneOverlapTolerance)
bearIFVG_Breaker_Overlap = not na(bearIFVGTop) and not na(bearIFVGBot) and not na(bearBreakerTop) and not na(bearBreakerBot) and rangesOverlap(bearIFVGTop, bearIFVGBot, bearBreakerTop, bearBreakerBot, zoneOverlapTolerance)
longStrongCondition = (requireIFVGOverlapWithOBForStrong and inBullIFVG and inBullOB and bullIFVG_OB_Overlap) or (requireIFVGOverlapWithBreakerForStrong and inBullIFVG and inBullBreaker and bullIFVG_Breaker_Overlap)
shortStrongCondition = (requireIFVGOverlapWithOBForStrong and inBearIFVG and inBearOB and bearIFVG_OB_Overlap) or (requireIFVGOverlapWithBreakerForStrong and inBearIFVG and inBearBreaker and bearIFVG_Breaker_Overlap)
//====================================================
// FINAL SIGNALS
// IFVG filters only apply to IFVG signals, not OB/Breaker signals
//====================================================
longZonePass = longIFVGSignalAllowed or inBullOB or inBullBreaker
shortZonePass = shortIFVGSignalAllowed or inBearOB or inBearBreaker
longBaseSignal = tfAllowed and longRecoveryWindowValid and longRetestZone and longRetestConfirm and longZonePass and bprPass and (allowMultipleLongSignals or not longSignalTriggered)
shortBaseSignal = tfAllowed and shortRecoveryWindowValid and shortRetestZone and shortRetestConfirm and shortZonePass and bprPass and (allowMultipleShortSignals or not shortSignalTriggered)
longStrongSignal = showStrongSignals and longBaseSignal and longStrongCondition
shortStrongSignal = showStrongSignals and shortBaseSignal and shortStrongCondition
longSignalColor = longStrongSignal ? strongLongColor : inBullBreaker ? breakerLongColor : inBullOB ? obLongColor : inBullIFVG ? ifvgLongColor : baseLongColor
shortSignalColor = shortStrongSignal ? strongShortColor : inBearBreaker ? breakerShortColor : inBearOB ? obShortColor : inBearIFVG ? ifvgShortColor : baseShortColor
longText = longStrongSignal ? "STRONG LONG" : inBullBreaker ? "Sweep + V + Breaker" : inBullOB ? "Sweep + V + OB" : inBullIFVG ? "Sweep + V + IFVG" : "Sweep + V Long"
shortText = shortStrongSignal ? "STRONG SHORT" : inBearBreaker ? "Sweep + V + Breaker" : inBearOB ? "Sweep + V + OB" : inBearIFVG ? "Sweep + V + IFVG" : "Sweep + V Short"
//====================================================
// STATE UPDATE
//====================================================
if longBaseSignal
    longSignalTriggered := true
if shortBaseSignal
    shortSignalTriggered := true
if longRecoveryActive and not na(longSweepBar) and (bar_index - longSweepBar > retestWindowBars + recoveryWindowBars)
    longRecoveryActive := false
    longSweepBar := na
    longSweepHigh := na
    longSweepLow := na
    longSignalTriggered := false
if shortRecoveryActive and not na(shortSweepBar) and (bar_index - shortSweepBar > retestWindowBars + recoveryWindowBars)
    shortRecoveryActive := false
    shortSweepBar := na
    shortSweepHigh := na
    shortSweepLow := na
    shortSignalTriggered := false
//====================================================
// OPTIONAL LINE ZONES
//====================================================
plot(showFVGZones and not na(bullFVGTop) ? bullFVGTop : na, title="Bull FVG Top", color=color.new(color.aqua, 75), linewidth=1, style=plot.style_linebr)
plot(showFVGZones and not na(bullFVGBot) ? bullFVGBot : na, title="Bull FVG Bottom", color=color.new(color.aqua, 75), linewidth=1, style=plot.style_linebr)
plot(showFVGZones and not na(bearFVGTop) ? bearFVGTop : na, title="Bear FVG Top", color=color.new(color.blue, 75), linewidth=1, style=plot.style_linebr)
plot(showFVGZones and not na(bearFVGBot) ? bearFVGBot : na, title="Bear FVG Bottom", color=color.new(color.blue, 75), linewidth=1, style=plot.style_linebr)
plot(showIFVGZones and not na(bullIFVGTop) ? bullIFVGTop : na, title="Bull IFVG Top", color=color.new(color.teal, 75), linewidth=1, style=plot.style_linebr)
plot(showIFVGZones and not na(bullIFVGBot) ? bullIFVGBot : na, title="Bull IFVG Bottom", color=color.new(color.teal, 75), linewidth=1, style=plot.style_linebr)
plot(showIFVGZones and not na(bearIFVGTop) ? bearIFVGTop : na, title="Bear IFVG Top", color=color.new(color.navy, 75), linewidth=1, style=plot.style_linebr)
plot(showIFVGZones and not na(bearIFVGBot) ? bearIFVGBot : na, title="Bear IFVG Bottom", color=color.new(color.navy, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and not na(bullOBTop) ? bullOBTop : na, title="Bull OB Top", color=color.new(color.orange, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and not na(bullOBBot) ? bullOBBot : na, title="Bull OB Bottom", color=color.new(color.orange, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and not na(bearOBTop) ? bearOBTop : na, title="Bear OB Top", color=color.new(color.purple, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and not na(bearOBBot) ? bearOBBot : na, title="Bear OB Bottom", color=color.new(color.purple, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and not na(bullBreakerTop) ? bullBreakerTop : na, title="Bull Breaker Top", color=color.new(color.yellow, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and not na(bullBreakerBot) ? bullBreakerBot : na, title="Bull Breaker Bottom", color=color.new(color.yellow, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and not na(bearBreakerTop) ? bearBreakerTop : na, title="Bear Breaker Top", color=color.new(color.fuchsia, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and not na(bearBreakerBot) ? bearBreakerBot : na, title="Bear Breaker Bottom", color=color.new(color.fuchsia, 75), linewidth=1, style=plot.style_linebr)
//====================================================
// SIGNALS
//====================================================
plotshape(showShapes and longBaseSignal and not longStrongSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=longSignalColor, size=size.small, text="L")
plotshape(showShapes and shortBaseSignal and not shortStrongSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=shortSignalColor, size=size.small, text="S")
plotshape(showShapes and longStrongSignal, title="Strong Long Signal", style=shape.labelup, location=location.belowbar, color=strongLongColor, size=size.small, text="STRONG")
plotshape(showShapes and shortStrongSignal, title="Strong Short Signal", style=shape.labeldown, location=location.abovebar, color=strongShortColor, size=size.small, text="STRONG")
if showLabels and longBaseSignal and not longStrongSignal
    label.new(x=bar_index, y=low, text=longText, style=label.style_label_up, color=longSignalColor, textcolor=longTextColor, size=labelSize)
if showLabels and shortBaseSignal and not shortStrongSignal
    label.new(x=bar_index, y=high, text=shortText, style=label.style_label_down, color=shortSignalColor, textcolor=shortTextColor, size=labelSize)
if showLabels and longStrongSignal
    label.new(x=bar_index, y=low, text="STRONG LONG", style=label.style_label_up, color=strongLongColor, textcolor=longTextColor, size=labelSize)
if showLabels and shortStrongSignal
    label.new(x=bar_index, y=high, text="STRONG SHORT", style=label.style_label_down, color=strongShortColor, textcolor=shortTextColor, size=labelSize)
//====================================================
// HIDDEN ANCHOR PLOT
//====================================================
plot(close, title="Anchor Plot", display=display.none)
//====================================================
// ALERTS
//====================================================
alertcondition(longBaseSignal, title="Long Signal", message="Liquidity sweep + V recovery + bullish zone retest")
alertcondition(shortBaseSignal, title="Short Signal", message="Liquidity sweep + V recovery + bearish zone retest")
alertcondition(longStrongSignal, title="Strong Long Signal", message="Strong long: IFVG overlapping OB or Breaker")
alertcondition(shortStrongSignal, title="Strong Short Signal", message="Strong short: IFVG overlapping OB or Breaker")
alertcondition(longBaseSignal and inBullIFVG, title="Long Signal in IFVG", message="Long signal in bullish IFVG")
alertcondition(shortBaseSignal and inBearIFVG, title="Short Signal in IFVG", message="Short signal in bearish IFVG")
alertcondition(longBaseSignal and inBullOB, title="Long Signal in Order Block", message="Long signal in bullish order block")
alertcondition(shortBaseSignal and inBearOB, title="Short Signal in Order Block", message="Short signal in bearish order block")
alertcondition(longBaseSignal and inBullBreaker, title="Long Signal in Breaker", message="Long signal in bullish breaker")
alertcondition(shortBaseSignal and inBearBreaker, title="Short Signal in Breaker", message="Short signal in bearish breaker")
````
