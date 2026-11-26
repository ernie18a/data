# ORB Retest Pro v3 + Smart Zones

- url: https://www.tradingview.com/script/HJhWH6CJ-ORB-Retest-Pro-v3-Smart-Zones/
- type: indicator
- pine_id: PUB;617f515b2a574623b19666c09589604d
- version: 2.0

## Description

ORB Retest Pro v3 + Smart Zones is a customizable Opening Range Breakout indicator built for traders who want clean ORB structure, retest-based entries, and real-time smart money confluence on the chart.

The indicator maps the Opening Range High, Low, Mid, and ORB box, then waits for price to break the range and retest it before printing a signal. This helps filter out weaker breakout candles and focuses on more structured continuation setups.

In addition to ORB logic, the script detects and displays real-time Fair Value Gaps (FVGs), Inversion Fair Value Gaps (IFVGs), Order Blocks (OBs), and Breaker Blocks using customizable zone boxes. Zones can be shown or hidden individually, colors can be fully customized, and broken zones can automatically remove themselves from the chart to keep the layout clean.

A key feature of this indicator is its smart zone behavior. When enabled, broken FVGs can automatically convert into IFVGs, allowing the chart to reflect changing market structure instead of leaving outdated zones on screen. You can also keep zones from previous sessions visible and control the number of days to look back, making it useful for both intraday and multi-session analysis.

The indicator is designed to work well on futures and stocks, with adjustable session times, timezone settings, and an optional timeframe filter so the ORB can be tailored to different markets and trading styles.

Features
Custom Opening Range session
Adjustable timezone
ORB high, low, mid, and box
Break + retest signal logic
Optional reclaim / rejection close confirmation
ATR displacement filter
Minimum breakout distance in ticks
Retest must occur within a user-defined number of bars
One signal per side per day or one total signal per day
Real-time FVG, IFVG, OB, and Breaker detection
Fully customizable zone colors and visibility
Optional automatic removal of broken zones
Optional FVG to IFVG conversion
Ability to keep previous-day zones on the chart
Adjustable lookback period
Confluence-based signal coloring
Built-in alerts
Best use
This indicator is best used on intraday charts such as 1m, 3m, 5m, and 15m, especially for traders who want to combine Opening Range Breakout structure with smart money zone confluence.

Notes
FVG, IFVG, Order Block, and Breaker logic are rule-based and designed for consistent automation inside Pine Script. They may not match every discretionary interpretation exactly, but they provide a structured and practical framework for real-time chart analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © elsrodriguez1

//@version=6
indicator("ORB Retest Pro v3.1 + MTF Smart Zones", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)
//====================================================
// INPUTS
//====================================================
groupSession = "Session Settings"
orbSession = input.session("0930-0945", "ORB Session", group=groupSession)
sessionTz = input.string("America/New_York", "Session Timezone", group=groupSession)
showOnlyOnTF = input.bool(false, "Limit ORB display to chart timeframe range", group=groupSession)
minChartTFMin = input.int(1, "Min Chart TF (minutes)", minval=1, group=groupSession)
maxChartTFMin = input.int(30, "Max Chart TF (minutes)", minval=1, group=groupSession)
groupOrbVisuals = "ORB Visuals"
showORBHigh = input.bool(true, "Show ORB High", group=groupOrbVisuals)
showORBLow = input.bool(true, "Show ORB Low", group=groupOrbVisuals)
showORBMid = input.bool(false, "Show ORB Mid", group=groupOrbVisuals)
showORBBox = input.bool(true, "Show ORB Box", group=groupOrbVisuals)
extendLevels = input.bool(true, "Extend ORB Levels Right", group=groupOrbVisuals)
orbHighColor = input.color(color.new(color.lime, 0), "ORB High Color", group=groupOrbVisuals)
orbLowColor = input.color(color.new(color.red, 0), "ORB Low Color", group=groupOrbVisuals)
orbMidColor = input.color(color.new(color.gray, 30), "ORB Mid Color", group=groupOrbVisuals)
orbBoxColor = input.color(color.new(color.silver, 88), "ORB Box Fill", group=groupOrbVisuals)
orbBorderColor = input.color(color.new(color.gray, 65), "ORB Box Border", group=groupOrbVisuals)
orbLineWidth = input.int(2, "ORB Line Width", minval=1, maxval=4, group=groupOrbVisuals)
groupSignal = "Signal Logic"
showLongSignals = input.bool(true, "Show Long Signals", group=groupSignal)
showShortSignals = input.bool(true, "Show Short Signals", group=groupSignal)
oneSignalPerSidePerDay = input.bool(true, "One Signal Per Side Per Day", group=groupSignal)
oneTotalSignalPerDay = input.bool(false, "One Total Signal Per Day", group=groupSignal)
requireCloseConfirmation = input.bool(true, "Require Reclaim/Rejection Close", group=groupSignal)
retestToleranceTicks = input.int(4, "Retest Tolerance (ticks)", minval=1, group=groupSignal)
retestWithinBars = input.int(10, "Retest Must Happen Within X Bars", minval=1, maxval=100, group=groupSignal)
minBreakoutTicks = input.int(2, "Minimum Breakout Beyond ORB (ticks)", minval=0, group=groupSignal)
useATRDisplacement = input.bool(true, "Use ATR Displacement Filter", group=groupSignal)
atrLen = input.int(14, "ATR Length", minval=1, group=groupSignal)
atrBreakoutMult = input.float(0.15, "Minimum Breakout Body as ATR Multiplier", minval=0.0, step=0.01, group=groupSignal)
groupConfluence = "Confluence Filters"
detectFVG = input.bool(true, "Detect Fair Value Gaps", group=groupConfluence)
detectOB = input.bool(true, "Detect Order Blocks", group=groupConfluence)
detectBreaker = input.bool(true, "Detect Breaker Blocks", group=groupConfluence)
detectIFVG = input.bool(true, "Detect Inversion Fair Value Gaps", group=groupConfluence)
requireConfluence = input.bool(false, "Require Confluence For Signal", group=groupConfluence)
confluenceLookback = input.int(30, "Confluence Lookback Bars", minval=5, maxval=200, group=groupConfluence)
useStrictStructure = input.bool(true, "Use Stricter Structure Rules", group=groupConfluence)
groupStyle = "Style"
cleanMode = input.bool(true, "Clean Mode", group=groupStyle)
showLabels = input.bool(true, "Show Labels", group=groupStyle)
showShapes = input.bool(true, "Show Shapes", group=groupStyle)
labelSizeInput = input.string("small", "Label Size", options=["tiny", "small", "normal"], group=groupStyle)
baseLongColor = input.color(color.new(color.lime, 0), "Base Long Color", group=groupStyle)
baseShortColor = input.color(color.new(color.red, 0), "Base Short Color", group=groupStyle)
fvgLongColor = input.color(color.new(color.aqua, 0), "Long Signal in FVG", group=groupStyle)
fvgShortColor = input.color(color.new(color.blue, 0), "Short Signal in FVG", group=groupStyle)
ifvgLongColor = input.color(color.new(color.teal, 0), "Long Signal in IFVG", group=groupStyle)
ifvgShortColor = input.color(color.new(color.navy, 0), "Short Signal in IFVG", group=groupStyle)
obLongColor = input.color(color.new(color.orange, 0), "Long Signal in Order Block", group=groupStyle)
obShortColor = input.color(color.new(color.purple, 0), "Short Signal in Order Block", group=groupStyle)
breakerLongColor = input.color(color.new(color.yellow, 0), "Long Signal in Breaker", group=groupStyle)
breakerShortColor = input.color(color.new(color.fuchsia, 0), "Short Signal in Breaker", group=groupStyle)
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
groupZoneTf = "FVG / IFVG Timeframe Visibility"
zoneTfMode = input.string("Chart + Selected", "Zone Timeframe Mode", options=["Chart + Selected", "Selected Only", "Chart Only"], group=groupZoneTf, tooltip="Chart + Selected shows zones detected on the chart timeframe plus every enabled source below. Selected Only hides chart-timeframe FVG/IFVG zones unless that timeframe is enabled as a source. Chart Only keeps the original behavior. For accurate MTF history, each selected source must be equal to or higher than the chart timeframe.")
enableZoneTf1 = input.bool(true, "Enable Source 1", inline="ztf1", group=groupZoneTf)
zoneTf1 = input.timeframe("5", "Timeframe", inline="ztf1", group=groupZoneTf)
zoneTf1FVG = input.bool(true, "FVG", inline="ztf1_types", group=groupZoneTf)
zoneTf1IFVG = input.bool(true, "IFVG", inline="ztf1_types", group=groupZoneTf)
enableZoneTf2 = input.bool(true, "Enable Source 2", inline="ztf2", group=groupZoneTf)
zoneTf2 = input.timeframe("15", "Timeframe", inline="ztf2", group=groupZoneTf)
zoneTf2FVG = input.bool(true, "FVG", inline="ztf2_types", group=groupZoneTf)
zoneTf2IFVG = input.bool(true, "IFVG", inline="ztf2_types", group=groupZoneTf)
enableZoneTf3 = input.bool(true, "Enable Source 3", inline="ztf3", group=groupZoneTf)
zoneTf3 = input.timeframe("30", "Timeframe", inline="ztf3", group=groupZoneTf)
zoneTf3FVG = input.bool(true, "FVG", inline="ztf3_types", group=groupZoneTf)
zoneTf3IFVG = input.bool(true, "IFVG", inline="ztf3_types", group=groupZoneTf)
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
retestTolerance = retestToleranceTicks * tickSize
minBreakoutDistance = minBreakoutTicks * tickSize
atr = ta.atr(atrLen)
float chartTfMinutes = timeframe.in_seconds() / 60.0
tfAllowed = not showOnlyOnTF or (not na(chartTfMinutes) and chartTfMinutes >= minChartTFMin and chartTfMinutes <= maxChartTFMin)
showChartTfZones = zoneTfMode != "Selected Only"
showSelectedTfZones = zoneTfMode != "Chart Only"
showChartFVGBoxes = showFVGBoxes and showChartTfZones
showChartIFVGBoxes = showIFVGBoxes and showChartTfZones
inSession = not na(time(timeframe.period, orbSession, sessionTz))
sessionStart = inSession and not inSession[1]
sessionEnd = not inSession and inSession[1]
newDay = ta.change(time("D")) != 0
bodySize = math.abs(close - open)
bullBody = close > open
bearBody = close < open
avgBody = ta.sma(math.abs(close - open), 10)
//====================================================
// ZONE HELPERS
//====================================================
zoneAgeMsLimit = zoneLookbackDays * 24 * 60 * 60 * 1000
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
f_mtfZonePacket() =>
    bool rawBullGap = low > high[2]
    bool rawBearGap = high < low[2]
    float lastBullTop = ta.valuewhen(rawBullGap, low, 0)
    float lastBullBot = ta.valuewhen(rawBullGap, high[2], 0)
    int lastBullLeft = ta.valuewhen(rawBullGap, time[2], 0)
    float lastBearTop = ta.valuewhen(rawBearGap, low[2], 0)
    float lastBearBot = ta.valuewhen(rawBearGap, high, 0)
    int lastBearLeft = ta.valuewhen(rawBearGap, time[2], 0)
    bool bullCross = ta.crossover(close, lastBearTop)
    bool bearCross = ta.crossunder(close, lastBullBot)
    bool rawBullInverse = not na(lastBearTop) and bullCross
    bool rawBearInverse = not na(lastBullBot) and bearCross
    bool bullGap = rawBullGap[1]
    bool bearGap = rawBearGap[1]
    bool bullInverse = rawBullInverse[1]
    bool bearInverse = rawBearInverse[1]
    [bullGap ? low[1] : na, bullGap ? high[3] : na, bullGap ? time[3] : na, bullGap ? time_close[1] : na,
     bearGap ? low[3] : na, bearGap ? high[1] : na, bearGap ? time[3] : na, bearGap ? time_close[1] : na,
     bullInverse ? lastBearTop[1] : na, bullInverse ? lastBearBot[1] : na, bullInverse ? lastBearLeft[1] : na, bullInverse ? time_close[1] : na,
     bearInverse ? lastBullTop[1] : na, bearInverse ? lastBullBot[1] : na, bearInverse ? lastBullLeft[1] : na, bearInverse ? time_close[1] : na]
f_sourceUsable(simple string sourceTf) =>
    float sourceSeconds = timeframe.in_seconds(sourceTf)
    float chartSeconds = timeframe.in_seconds()
    sourceSeconds > chartSeconds or (not showChartTfZones and sourceSeconds == chartSeconds)
f_newMtfBox(float zoneTop, float zoneBottom, int leftTime, int eventTime, simple string sourceTf, color fillColor, color borderColor) =>
    int extensionMs = int(timeframe.in_seconds(sourceTf) * 1000 * zoneExtendBars)
    box.new(left=leftTime, right=eventTime + extensionMs, top=zoneTop, bottom=zoneBottom, xloc=xloc.bar_time, bgcolor=fillColor, border_color=borderColor)
//====================================================
// STATE
//====================================================
var float orbHigh = na
var float orbLow = na
var float orbMid = na
var int orbStartBar = na
var int orbEndBar = na
var bool brokeAbove = false
var bool brokeBelow = false
var int brokeAboveBar = na
var int brokeBelowBar = na
var bool longTriggered = false
var bool shortTriggered = false
var bool anyTriggered = false
var line hiLine = na
var line loLine = na
var line midLine = na
var box orbBox = na
var float bullFVGTop = na
var float bullFVGBot = na
var int bullFVGBar = na
var float bearFVGTop = na
var float bearFVGBot = na
var int bearFVGBar = na
var float bullIFVGTop = na
var float bullIFVGBot = na
var int bullIFVGBar = na
var float bearIFVGTop = na
var float bearIFVGBot = na
var int bearIFVGBar = na
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
//====================================================
// RESET
//====================================================
if newDay
    orbHigh := na
    orbLow := na
    orbMid := na
    orbStartBar := na
    orbEndBar := na
    brokeAbove := false
    brokeBelow := false
    brokeAboveBar := na
    brokeBelowBar := na
    longTriggered := false
    shortTriggered := false
    anyTriggered := false
    if not na(hiLine)
        line.delete(hiLine)
        hiLine := na
    if not na(loLine)
        line.delete(loLine)
        loLine := na
    if not na(midLine)
        line.delete(midLine)
        midLine := na
    if not na(orbBox)
        box.delete(orbBox)
        orbBox := na
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
//====================================================
// LOOKBACK TRIM
//====================================================
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
// SELECTED-TIMEFRAME FVG / IFVG ZONES
//====================================================
[tf1BullFVGTop, tf1BullFVGBot, tf1BullFVGLeft, tf1BullFVGTime,
 tf1BearFVGTop, tf1BearFVGBot, tf1BearFVGLeft, tf1BearFVGTime,
 tf1BullIFVGTop, tf1BullIFVGBot, tf1BullIFVGLeft, tf1BullIFVGTime,
 tf1BearIFVGTop, tf1BearIFVGBot, tf1BearIFVGLeft, tf1BearIFVGTime] = request.security(syminfo.tickerid, zoneTf1, f_mtfZonePacket(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
[tf2BullFVGTop, tf2BullFVGBot, tf2BullFVGLeft, tf2BullFVGTime,
 tf2BearFVGTop, tf2BearFVGBot, tf2BearFVGLeft, tf2BearFVGTime,
 tf2BullIFVGTop, tf2BullIFVGBot, tf2BullIFVGLeft, tf2BullIFVGTime,
 tf2BearIFVGTop, tf2BearIFVGBot, tf2BearIFVGLeft, tf2BearIFVGTime] = request.security(syminfo.tickerid, zoneTf2, f_mtfZonePacket(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
[tf3BullFVGTop, tf3BullFVGBot, tf3BullFVGLeft, tf3BullFVGTime,
 tf3BearFVGTop, tf3BearFVGBot, tf3BearFVGLeft, tf3BearFVGTime,
 tf3BullIFVGTop, tf3BullIFVGBot, tf3BullIFVGLeft, tf3BullIFVGTime,
 tf3BearIFVGTop, tf3BearIFVGBot, tf3BearIFVGLeft, tf3BearIFVGTime] = request.security(syminfo.tickerid, zoneTf3, f_mtfZonePacket(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
slot1Usable = showSelectedTfZones and enableZoneTf1 and f_sourceUsable(zoneTf1)
slot2Usable = showSelectedTfZones and enableZoneTf2 and f_sourceUsable(zoneTf2)
slot3Usable = showSelectedTfZones and enableZoneTf3 and f_sourceUsable(zoneTf3)
slot1FVGActive = slot1Usable and zoneTf1FVG and showFVGBoxes and detectFVG
slot1IFVGActive = slot1Usable and zoneTf1IFVG and showIFVGBoxes and detectIFVG
slot2FVGActive = slot2Usable and zoneTf2FVG and showFVGBoxes and detectFVG and not (slot1FVGActive and zoneTf2 == zoneTf1)
slot2IFVGActive = slot2Usable and zoneTf2IFVG and showIFVGBoxes and detectIFVG and not (slot1IFVGActive and zoneTf2 == zoneTf1)
slot3FVGActive = slot3Usable and zoneTf3FVG and showFVGBoxes and detectFVG and not (slot1FVGActive and zoneTf3 == zoneTf1) and not (slot2FVGActive and zoneTf3 == zoneTf2)
slot3IFVGActive = slot3Usable and zoneTf3IFVG and showIFVGBoxes and detectIFVG and not (slot1IFVGActive and zoneTf3 == zoneTf1) and not (slot2IFVGActive and zoneTf3 == zoneTf2)
if slot1FVGActive and not na(tf1BullFVGTop)
    bx = f_newMtfBox(tf1BullFVGTop, tf1BullFVGBot, tf1BullFVGLeft, tf1BullFVGTime, zoneTf1, bullFVGFill, bullFVGBorder)
    pushZone(bullFVGBoxes, bullFVGTimes, bx, tf1BullFVGTime, maxZonesToKeep)
if slot1FVGActive and not na(tf1BearFVGTop)
    bx = f_newMtfBox(tf1BearFVGTop, tf1BearFVGBot, tf1BearFVGLeft, tf1BearFVGTime, zoneTf1, bearFVGFill, bearFVGBorder)
    pushZone(bearFVGBoxes, bearFVGTimes, bx, tf1BearFVGTime, maxZonesToKeep)
if slot1IFVGActive and not na(tf1BullIFVGTop)
    bx = f_newMtfBox(tf1BullIFVGTop, tf1BullIFVGBot, tf1BullIFVGLeft, tf1BullIFVGTime, zoneTf1, bullIFVGFill, bullIFVGBorder)
    pushZone(bullIFVGBoxes, bullIFVGTimes, bx, tf1BullIFVGTime, maxZonesToKeep)
if slot1IFVGActive and not na(tf1BearIFVGTop)
    bx = f_newMtfBox(tf1BearIFVGTop, tf1BearIFVGBot, tf1BearIFVGLeft, tf1BearIFVGTime, zoneTf1, bearIFVGFill, bearIFVGBorder)
    pushZone(bearIFVGBoxes, bearIFVGTimes, bx, tf1BearIFVGTime, maxZonesToKeep)
if slot2FVGActive and not na(tf2BullFVGTop)
    bx = f_newMtfBox(tf2BullFVGTop, tf2BullFVGBot, tf2BullFVGLeft, tf2BullFVGTime, zoneTf2, bullFVGFill, bullFVGBorder)
    pushZone(bullFVGBoxes, bullFVGTimes, bx, tf2BullFVGTime, maxZonesToKeep)
if slot2FVGActive and not na(tf2BearFVGTop)
    bx = f_newMtfBox(tf2BearFVGTop, tf2BearFVGBot, tf2BearFVGLeft, tf2BearFVGTime, zoneTf2, bearFVGFill, bearFVGBorder)
    pushZone(bearFVGBoxes, bearFVGTimes, bx, tf2BearFVGTime, maxZonesToKeep)
if slot2IFVGActive and not na(tf2BullIFVGTop)
    bx = f_newMtfBox(tf2BullIFVGTop, tf2BullIFVGBot, tf2BullIFVGLeft, tf2BullIFVGTime, zoneTf2, bullIFVGFill, bullIFVGBorder)
    pushZone(bullIFVGBoxes, bullIFVGTimes, bx, tf2BullIFVGTime, maxZonesToKeep)
if slot2IFVGActive and not na(tf2BearIFVGTop)
    bx = f_newMtfBox(tf2BearIFVGTop, tf2BearIFVGBot, tf2BearIFVGLeft, tf2BearIFVGTime, zoneTf2, bearIFVGFill, bearIFVGBorder)
    pushZone(bearIFVGBoxes, bearIFVGTimes, bx, tf2BearIFVGTime, maxZonesToKeep)
if slot3FVGActive and not na(tf3BullFVGTop)
    bx = f_newMtfBox(tf3BullFVGTop, tf3BullFVGBot, tf3BullFVGLeft, tf3BullFVGTime, zoneTf3, bullFVGFill, bullFVGBorder)
    pushZone(bullFVGBoxes, bullFVGTimes, bx, tf3BullFVGTime, maxZonesToKeep)
if slot3FVGActive and not na(tf3BearFVGTop)
    bx = f_newMtfBox(tf3BearFVGTop, tf3BearFVGBot, tf3BearFVGLeft, tf3BearFVGTime, zoneTf3, bearFVGFill, bearFVGBorder)
    pushZone(bearFVGBoxes, bearFVGTimes, bx, tf3BearFVGTime, maxZonesToKeep)
if slot3IFVGActive and not na(tf3BullIFVGTop)
    bx = f_newMtfBox(tf3BullIFVGTop, tf3BullIFVGBot, tf3BullIFVGLeft, tf3BullIFVGTime, zoneTf3, bullIFVGFill, bullIFVGBorder)
    pushZone(bullIFVGBoxes, bullIFVGTimes, bx, tf3BullIFVGTime, maxZonesToKeep)
if slot3IFVGActive and not na(tf3BearIFVGTop)
    bx = f_newMtfBox(tf3BearIFVGTop, tf3BearIFVGBot, tf3BearIFVGLeft, tf3BearIFVGTime, zoneTf3, bearIFVGFill, bearIFVGBorder)
    pushZone(bearIFVGBoxes, bearIFVGTimes, bx, tf3BearIFVGTime, maxZonesToKeep)
//====================================================
// BUILD ORB
//====================================================
if sessionStart
    orbHigh := high
    orbLow := low
    orbMid := (orbHigh + orbLow) / 2.0
    orbStartBar := bar_index
    orbEndBar := na
    brokeAbove := false
    brokeBelow := false
    brokeAboveBar := na
    brokeBelowBar := na
    longTriggered := false
    shortTriggered := false
    anyTriggered := false
    if not na(hiLine)
        line.delete(hiLine)
        hiLine := na
    if not na(loLine)
        line.delete(loLine)
        loLine := na
    if not na(midLine)
        line.delete(midLine)
        midLine := na
    if not na(orbBox)
        box.delete(orbBox)
        orbBox := na
if inSession
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)
    orbMid := (orbHigh + orbLow) / 2.0
    if showORBBox and tfAllowed
        if na(orbBox)
            orbBox := box.new(left=bar_index, top=orbHigh, right=bar_index, bottom=orbLow, bgcolor=orbBoxColor, border_color=orbBorderColor)
        else
            box.set_left(orbBox, orbStartBar)
            box.set_right(orbBox, bar_index)
            box.set_top(orbBox, orbHigh)
            box.set_bottom(orbBox, orbLow)
if sessionEnd
    orbEndBar := bar_index
    orbMid := (orbHigh + orbLow) / 2.0
    if tfAllowed
        if showORBHigh
            hiLine := line.new(x1=bar_index, y1=orbHigh, x2=bar_index + 1, y2=orbHigh, extend=extendLevels ? extend.right : extend.none, color=orbHighColor, width=orbLineWidth)
        if showORBLow
            loLine := line.new(x1=bar_index, y1=orbLow, x2=bar_index + 1, y2=orbLow, extend=extendLevels ? extend.right : extend.none, color=orbLowColor, width=orbLineWidth)
        if showORBMid
            midLine := line.new(x1=bar_index, y1=orbMid, x2=bar_index + 1, y2=orbMid, extend=extendLevels ? extend.right : extend.none, color=orbMidColor, width=1, style=line.style_dashed)
//====================================================
// POST ORB
//====================================================
afterORB = not inSession and not na(orbHigh) and not na(orbLow)
longBreakCondition = afterORB and high >= orbHigh + minBreakoutDistance and close > orbHigh and (not useATRDisplacement or bodySize >= atr * atrBreakoutMult)
shortBreakCondition = afterORB and low <= orbLow - minBreakoutDistance and close < orbLow and (not useATRDisplacement or bodySize >= atr * atrBreakoutMult)
if longBreakCondition and not brokeAbove
    brokeAbove := true
    brokeAboveBar := bar_index
if shortBreakCondition and not brokeBelow
    brokeBelow := true
    brokeBelowBar := bar_index
longRetestWindowActive = brokeAbove and not na(brokeAboveBar) and (bar_index - brokeAboveBar <= retestWithinBars)
shortRetestWindowActive = brokeBelow and not na(brokeBelowBar) and (bar_index - brokeBelowBar <= retestWithinBars)
longRetestTouch = afterORB and longRetestWindowActive and low <= orbHigh + retestTolerance and high >= orbHigh - retestTolerance
shortRetestTouch = afterORB and shortRetestWindowActive and high >= orbLow - retestTolerance and low <= orbLow + retestTolerance
longConfirm = requireCloseConfirmation ? close > orbHigh : true
shortConfirm = requireCloseConfirmation ? close < orbLow : true
longSequenceValid = brokeAbove and not na(brokeAboveBar) and bar_index > brokeAboveBar
shortSequenceValid = brokeBelow and not na(brokeBelowBar) and bar_index > brokeBelowBar
//====================================================
// FVG
//====================================================
bullFVG = detectFVG and bar_index >= 2 and low > high[2]
bearFVG = detectFVG and bar_index >= 2 and high < low[2]
if bullFVG
    bullFVGTop := low
    bullFVGBot := high[2]
    bullFVGBar := bar_index
    if showChartFVGBoxes
        bx = box.new(left=bar_index - 2, right=bar_index + zoneExtendBars, top=low, bottom=high[2], bgcolor=bullFVGFill, border_color=bullFVGBorder)
        pushZone(bullFVGBoxes, bullFVGTimes, bx, time, maxZonesToKeep)
if bearFVG
    bearFVGTop := low[2]
    bearFVGBot := high
    bearFVGBar := bar_index
    if showChartFVGBoxes
        bx = box.new(left=bar_index - 2, right=bar_index + zoneExtendBars, top=low[2], bottom=high, bgcolor=bearFVGFill, border_color=bearFVGBorder)
        pushZone(bearFVGBoxes, bearFVGTimes, bx, time, maxZonesToKeep)
inBullFVG = detectFVG and not na(bullFVGBar) and (bar_index - bullFVGBar <= confluenceLookback) and low <= bullFVGTop and high >= bullFVGBot
inBearFVG = detectFVG and not na(bearFVGBar) and (bar_index - bearFVGBar <= confluenceLookback) and high >= bearFVGBot and low <= bearFVGTop
//====================================================
// IFVG
//====================================================
bool bullIFVGCross = ta.crossover(close, bearFVGTop)
bool bearIFVGCross = ta.crossunder(close, bullFVGBot)
bullIFVG = detectIFVG and not na(bearFVGTop) and bullIFVGCross
bearIFVG = detectIFVG and not na(bullFVGBot) and bearIFVGCross
if bullIFVG
    bullIFVGTop := bearFVGTop
    bullIFVGBot := bearFVGBot
    bullIFVGBar := bar_index
    if showChartIFVGBoxes
        bx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bullIFVGTop, bottom=bullIFVGBot, bgcolor=bullIFVGFill, border_color=bullIFVGBorder)
        pushZone(bullIFVGBoxes, bullIFVGTimes, bx, time, maxZonesToKeep)
if bearIFVG
    bearIFVGTop := bullFVGTop
    bearIFVGBot := bullFVGBot
    bearIFVGBar := bar_index
    if showChartIFVGBoxes
        bx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bearIFVGTop, bottom=bearIFVGBot, bgcolor=bearIFVGFill, border_color=bearIFVGBorder)
        pushZone(bearIFVGBoxes, bearIFVGTimes, bx, time, maxZonesToKeep)
inBullIFVG = detectIFVG and not na(bullIFVGBar) and (bar_index - bullIFVGBar <= confluenceLookback) and low <= bullIFVGTop and high >= bullIFVGBot
inBearIFVG = detectIFVG and not na(bearIFVGBar) and (bar_index - bearIFVGBar <= confluenceLookback) and high >= bearIFVGBot and low <= bearIFVGTop
//====================================================
// ORDER BLOCKS
//====================================================
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
inBullOB = detectOB and not na(bullOBBar) and (bar_index - bullOBBar <= confluenceLookback) and low <= bullOBTop and high >= bullOBBot
inBearOB = detectOB and not na(bearOBBar) and (bar_index - bearOBBar <= confluenceLookback) and high >= bearOBBot and low <= bearOBTop
//====================================================
// BREAKERS
//====================================================
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
inBullBreaker = detectBreaker and not na(bullBreakerBar) and (bar_index - bullBreakerBar <= confluenceLookback) and low <= bullBreakerTop and high >= bullBreakerBot
inBearBreaker = detectBreaker and not na(bearBreakerBar) and (bar_index - bearBreakerBar <= confluenceLookback) and high >= bearBreakerBot and low <= bearBreakerTop
//====================================================
// SMART ZONE BEHAVIOR
//====================================================
if removeBrokenZones
    int i1 = array.size(bullFVGBoxes) - 1
    while i1 >= 0
        bx = array.get(bullFVGBoxes, i1)
        bxTop = box.get_top(bx)
        bxBot = box.get_bottom(bx)
        if low < bxBot
            if convertBrokenFVGToIFVG and showChartIFVGBoxes and not showSelectedTfZones
                newBx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bxTop, bottom=bxBot, bgcolor=bearIFVGFill, border_color=bearIFVGBorder)
                pushZone(bearIFVGBoxes, bearIFVGTimes, newBx, time, maxZonesToKeep)
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
            if convertBrokenFVGToIFVG and showChartIFVGBoxes and not showSelectedTfZones
                newBx = box.new(left=bar_index, right=bar_index + zoneExtendBars, top=bxTop, bottom=bxBot, bgcolor=bullIFVGFill, border_color=bullIFVGBorder)
                pushZone(bullIFVGBoxes, bullIFVGTimes, newBx, time, maxZonesToKeep)
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
// CONFLUENCE
//====================================================
longConfluenceBreaker = inBullBreaker
longConfluenceOB = inBullOB
longConfluenceIFVG = inBullIFVG
longConfluenceFVG = inBullFVG
shortConfluenceBreaker = inBearBreaker
shortConfluenceOB = inBearOB
shortConfluenceIFVG = inBearIFVG
shortConfluenceFVG = inBearFVG
longHasConfluence = longConfluenceBreaker or longConfluenceOB or longConfluenceIFVG or longConfluenceFVG
shortHasConfluence = shortConfluenceBreaker or shortConfluenceOB or shortConfluenceIFVG or shortConfluenceFVG
allowLong = requireConfluence ? longHasConfluence : true
allowShort = requireConfluence ? shortHasConfluence : true
//====================================================
// FINAL SIGNALS
//====================================================
longSignal = tfAllowed and showLongSignals and longSequenceValid and longRetestTouch and longConfirm and allowLong and (oneSignalPerSidePerDay ? not longTriggered : true) and (oneTotalSignalPerDay ? not anyTriggered : true)
shortSignal = tfAllowed and showShortSignals and shortSequenceValid and shortRetestTouch and shortConfirm and allowShort and (oneSignalPerSidePerDay ? not shortTriggered : true) and (oneTotalSignalPerDay ? not anyTriggered : true)
//====================================================
// SIGNAL COLORS
//====================================================
longSignalColor = longConfluenceBreaker ? breakerLongColor : longConfluenceOB ? obLongColor : longConfluenceIFVG ? ifvgLongColor : longConfluenceFVG ? fvgLongColor : baseLongColor
shortSignalColor = shortConfluenceBreaker ? breakerShortColor : shortConfluenceOB ? obShortColor : shortConfluenceIFVG ? ifvgShortColor : shortConfluenceFVG ? fvgShortColor : baseShortColor
longText = longConfluenceBreaker ? "ORB Retest + Breaker" : longConfluenceOB ? "ORB Retest + OB" : longConfluenceIFVG ? "ORB Retest + IFVG" : longConfluenceFVG ? "ORB Retest + FVG" : "ORB Retest Long"
shortText = shortConfluenceBreaker ? "ORB Retest + Breaker" : shortConfluenceOB ? "ORB Retest + OB" : shortConfluenceIFVG ? "ORB Retest + IFVG" : shortConfluenceFVG ? "ORB Retest + FVG" : "ORB Retest Short"
//====================================================
// STATE UPDATES
//====================================================
if longSignal
    longTriggered := true
    anyTriggered := true
if shortSignal
    shortTriggered := true
    anyTriggered := true
//====================================================
// CLEAN VISUALS
//====================================================
plot(not cleanMode and tfAllowed and inSession ? orbHigh : na, title="ORB High Building", color=color.new(orbHighColor, 45), linewidth=1)
plot(not cleanMode and tfAllowed and inSession ? orbLow : na, title="ORB Low Building", color=color.new(orbLowColor, 45), linewidth=1)
plot(not cleanMode and tfAllowed and inSession and showORBMid ? orbMid : na, title="ORB Mid Building", color=color.new(orbMidColor, 50), linewidth=1)
//====================================================
// OPTIONAL LINE ZONES
//====================================================
plot(showChartTfZones and showFVGZones and inBullFVG ? bullFVGTop : na, title="Bull FVG Top", color=color.new(color.aqua, 75), linewidth=1, style=plot.style_linebr)
plot(showChartTfZones and showFVGZones and inBullFVG ? bullFVGBot : na, title="Bull FVG Bottom", color=color.new(color.aqua, 75), linewidth=1, style=plot.style_linebr)
plot(showChartTfZones and showFVGZones and inBearFVG ? bearFVGTop : na, title="Bear FVG Top", color=color.new(color.blue, 75), linewidth=1, style=plot.style_linebr)
plot(showChartTfZones and showFVGZones and inBearFVG ? bearFVGBot : na, title="Bear FVG Bottom", color=color.new(color.blue, 75), linewidth=1, style=plot.style_linebr)
plot(showChartTfZones and showIFVGZones and inBullIFVG ? bullIFVGTop : na, title="Bull IFVG Top", color=color.new(color.teal, 75), linewidth=1, style=plot.style_linebr)
plot(showChartTfZones and showIFVGZones and inBullIFVG ? bullIFVGBot : na, title="Bull IFVG Bottom", color=color.new(color.teal, 75), linewidth=1, style=plot.style_linebr)
plot(showChartTfZones and showIFVGZones and inBearIFVG ? bearIFVGTop : na, title="Bear IFVG Top", color=color.new(color.navy, 75), linewidth=1, style=plot.style_linebr)
plot(showChartTfZones and showIFVGZones and inBearIFVG ? bearIFVGBot : na, title="Bear IFVG Bottom", color=color.new(color.navy, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and inBullOB ? bullOBTop : na, title="Bull OB Top", color=color.new(color.orange, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and inBullOB ? bullOBBot : na, title="Bull OB Bottom", color=color.new(color.orange, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and inBearOB ? bearOBTop : na, title="Bear OB Top", color=color.new(color.purple, 75), linewidth=1, style=plot.style_linebr)
plot(showOBZones and inBearOB ? bearOBBot : na, title="Bear OB Bottom", color=color.new(color.purple, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and inBullBreaker ? bullBreakerTop : na, title="Bull Breaker Top", color=color.new(color.yellow, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and inBullBreaker ? bullBreakerBot : na, title="Bull Breaker Bottom", color=color.new(color.yellow, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and inBearBreaker ? bearBreakerTop : na, title="Bear Breaker Top", color=color.new(color.fuchsia, 75), linewidth=1, style=plot.style_linebr)
plot(showBreakerZones and inBearBreaker ? bearBreakerBot : na, title="Bear Breaker Bottom", color=color.new(color.fuchsia, 75), linewidth=1, style=plot.style_linebr)
//====================================================
// SIGNALS
//====================================================
plotshape(showShapes and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=longSignalColor, size=size.small, text="L")
plotshape(showShapes and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=shortSignalColor, size=size.small, text="S")
if showLabels and longSignal
    label.new(x=bar_index, y=low, text=longText, style=label.style_label_up, color=longSignalColor, textcolor=longTextColor, size=labelSize)
if showLabels and shortSignal
    label.new(x=bar_index, y=high, text=shortText, style=label.style_label_down, color=shortSignalColor, textcolor=shortTextColor, size=labelSize)
//====================================================
// HIDDEN ANCHOR PLOTS
//====================================================
plot(orbHigh, title="ORB High Anchor", display=display.none)
plot(orbLow, title="ORB Low Anchor", display=display.none)
//====================================================
// ALERTS
//====================================================
alertcondition(longSignal, title="ORB Retest Long", message="ORB Retest Long")
alertcondition(shortSignal, title="ORB Retest Short", message="ORB Retest Short")
alertcondition(longSignal and longConfluenceFVG, title="ORB Retest Long in FVG", message="ORB Retest Long in Bullish FVG")
alertcondition(shortSignal and shortConfluenceFVG, title="ORB Retest Short in FVG", message="ORB Retest Short in Bearish FVG")
alertcondition(longSignal and longConfluenceIFVG, title="ORB Retest Long in IFVG", message="ORB Retest Long in Bullish IFVG")
alertcondition(shortSignal and shortConfluenceIFVG, title="ORB Retest Short in IFVG", message="ORB Retest Short in Bearish IFVG")
alertcondition(longSignal and longConfluenceOB, title="ORB Retest Long in Order Block", message="ORB Retest Long in Bullish Order Block")
alertcondition(shortSignal and shortConfluenceOB, title="ORB Retest Short in Order Block", message="ORB Retest Short in Bearish Order Block")
alertcondition(longSignal and longConfluenceBreaker, title="ORB Retest Long in Breaker", message="ORB Retest Long in Bullish Breaker")
alertcondition(shortSignal and shortConfluenceBreaker, title="ORB Retest Short in Breaker", message="ORB Retest Short in Bearish Breaker")
````
