# NSE Breakout Retest Reclaim v6

- url: https://www.tradingview.com/script/pUT0CHHe-NSE-Breakout-Retest-Reclaim-v6/
- type: indicator
- pine_id: PUB;0e840e1810324006a9677c2eef31634f
- version: 1.0

## Description

NSE Breakout Retest Reclaim v6. The day-pace RVOL is still a practical proxy, using cumulative session volume compared with prior sessions at the same bar count, which is a common Pine workaround for intraday pace analysis. That method is directionally useful, but still depends on stable session structure and consistent chart timeframe

## Source Code

````pine
//@version=6
indicator("NSE Breakout Retest Reclaim v6", shorttitle="NSE BRR v6", overlay=true, max_labels_count=300)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
string sessionInput = input.session("0915-1530", "Session")
int skipBars = input.int(5, "Skip First N Bars", minval=0)

bool usePDH = input.bool(true, "Use Previous Day High")
bool useFirst5 = input.bool(true, "Use First 5 Bars High")
bool useORB15 = input.bool(true, "Use First 15 Bars High")
bool use10D = input.bool(true, "Use 10 Day High")

int barRvolLen = input.int(20, "Bar RVOL Length", minval=2)
float minBarRVOL = input.float(1.5, "Min Breakout Bar RVOL", step=0.1)
float minReclaimRVOL = input.float(1.2, "Min Reclaim Bar RVOL", step=0.1)

bool useDayPace = input.bool(true, "Use Day Pace RVOL")
int dayPaceLookback = input.int(5, "Day Pace Lookback", minval=2, maxval=10)
float minDayPaceRVOL = input.float(1.1, "Min Day Pace RVOL", step=0.1)

int atrLen = input.int(14, "ATR Length", minval=2)
float zoneAtrMult = input.float(0.20, "Zone ATR Buffer", step=0.05)
float maxBreakoutAtrMult = input.float(2.0, "Max Breakout Candle ATR Mult", step=0.1)
int maxRetestBars = input.int(4, "Max Bars After Retest", minval=1)
int maxSetupBars = input.int(8, "Max Bars After Setup Without Retest", minval=1)

float minGapPct = input.float(-3.0, "Min Gap %", step=0.1)
float maxGapPct = input.float(4.0, "Max Gap %", step=0.1)

bool showLabels = input.bool(true, "Show Labels")
bool showDebug = input.bool(false, "Show Debug Markers")

//--------------------------------------------------
// Session / Day handling
//--------------------------------------------------
bool inSession = not na(time(timeframe.period, sessionInput))
bool newDay = ta.change(time("D")) != 0

var int barsToday = 0
if newDay
    barsToday := 1
else
    barsToday += 1

bool sessionReady = inSession and barsToday > skipBars

//--------------------------------------------------
// Daily references
//--------------------------------------------------
float prevClose = request.security(syminfo.tickerid, "D", close[1])
float prevDayHigh = request.security(syminfo.tickerid, "D", high[1])
float high10D = request.security(syminfo.tickerid, "D", ta.highest(high, 10)[1])
float todayOpen = request.security(syminfo.tickerid, "D", open)

float gapPct = not na(prevClose) and prevClose != 0.0 ? ((todayOpen - prevClose) / prevClose) * 100.0 : na
bool gapPass = not na(gapPct) and gapPct >= minGapPct and gapPct <= maxGapPct

//--------------------------------------------------
// Opening range levels
//--------------------------------------------------
var float first5High = na
var float first15High = na

if newDay
    first5High := na
    first15High := na

if inSession and barsToday <= 5
    first5High := na(first5High) ? high : math.max(first5High, high)

if inSession and barsToday <= 15
    first15High := na(first15High) ? high : math.max(first15High, high)

//--------------------------------------------------
// Core calculations
//--------------------------------------------------
float vwapVal = ta.vwap(hlc3)
bool vwapUp = vwapVal > vwapVal[1]
float atrVal = ta.atr(atrLen)

float barRvolBase = ta.sma(volume, barRvolLen)
float barRVOL = not na(barRvolBase) and barRvolBase > 0.0 ? volume / barRvolBase : na

float breakoutRange = high - low
bool oversizedBreakout = breakoutRange > atrVal * maxBreakoutAtrMult

//--------------------------------------------------
// Day pace RVOL via same bar-of-day cumulative volume
//--------------------------------------------------
var float cumVol = 0.0
if newDay
    cumVol := volume
else
    cumVol += volume

float prevCum1 = barsToday > 0 ? nz(cumVol[barsToday], na) : na
float prevCum2 = barsToday > 0 ? nz(cumVol[barsToday * 2], na) : na
float prevCum3 = barsToday > 0 ? nz(cumVol[barsToday * 3], na) : na
float prevCum4 = barsToday > 0 ? nz(cumVol[barsToday * 4], na) : na
float prevCum5 = barsToday > 0 ? nz(cumVol[barsToday * 5], na) : na
float prevCum6 = barsToday > 0 ? nz(cumVol[barsToday * 6], na) : na
float prevCum7 = barsToday > 0 ? nz(cumVol[barsToday * 7], na) : na
float prevCum8 = barsToday > 0 ? nz(cumVol[barsToday * 8], na) : na
float prevCum9 = barsToday > 0 ? nz(cumVol[barsToday * 9], na) : na
float prevCum10 = barsToday > 0 ? nz(cumVol[barsToday * 10], na) : na

float paceSum = 0.0
int paceCount = 0

if dayPaceLookback >= 1 and not na(prevCum1)
    paceSum += prevCum1
    paceCount += 1
if dayPaceLookback >= 2 and not na(prevCum2)
    paceSum += prevCum2
    paceCount += 1
if dayPaceLookback >= 3 and not na(prevCum3)
    paceSum += prevCum3
    paceCount += 1
if dayPaceLookback >= 4 and not na(prevCum4)
    paceSum += prevCum4
    paceCount += 1
if dayPaceLookback >= 5 and not na(prevCum5)
    paceSum += prevCum5
    paceCount += 1
if dayPaceLookback >= 6 and not na(prevCum6)
    paceSum += prevCum6
    paceCount += 1
if dayPaceLookback >= 7 and not na(prevCum7)
    paceSum += prevCum7
    paceCount += 1
if dayPaceLookback >= 8 and not na(prevCum8)
    paceSum += prevCum8
    paceCount += 1
if dayPaceLookback >= 9 and not na(prevCum9)
    paceSum += prevCum9
    paceCount += 1
if dayPaceLookback >= 10 and not na(prevCum10)
    paceSum += prevCum10
    paceCount += 1

float paceAvg = paceCount > 0 ? paceSum / paceCount : na
float dayPaceRVOL = not na(paceAvg) and paceAvg > 0.0 ? cumVol / paceAvg : na
bool dayPacePass = useDayPace ? (not na(dayPaceRVOL) and dayPaceRVOL >= minDayPaceRVOL) : true

//--------------------------------------------------
// Breakout triggers
//--------------------------------------------------
bool crossPDH = usePDH and not na(prevDayHigh) and close > prevDayHigh and close[1] <= prevDayHigh
bool crossF5 = useFirst5 and not na(first5High) and close > first5High and close[1] <= first5High
bool crossORB15 = useORB15 and not na(first15High) and close > first15High and close[1] <= first15High
bool cross10D = use10D and not na(high10D) and close > high10D and close[1] <= high10D

bool breakoutNow = crossPDH or crossF5 or crossORB15 or cross10D

float breakoutLevel = crossPDH ? prevDayHigh : crossF5 ? first5High : crossORB15 ? first15High : cross10D ? high10D : na
string breakoutName = crossPDH ? "PDH" : crossF5 ? "F5" : crossORB15 ? "ORB15" : cross10D ? "10D" : ""

//--------------------------------------------------
// Qualification filters
//--------------------------------------------------
bool trendPass = close > vwapVal and vwapUp
bool breakoutBarRVOLPass = not na(barRVOL) and barRVOL >= minBarRVOL
bool breakoutQualityPass = sessionReady and gapPass and trendPass and breakoutBarRVOLPass and dayPacePass and not oversizedBreakout

//--------------------------------------------------
// Persistent state
//--------------------------------------------------
var bool setupActive = false
var bool retestSeen = false
var int setupBarIndex = na
var int retestBarIndex = na
var float savedBreakoutLevel = na
var string savedBreakoutName = ""
var float zoneLow = na
var float zoneHigh = na
var float retestHigh = na

if newDay
    setupActive := false
    retestSeen := false
    setupBarIndex := na
    retestBarIndex := na
    savedBreakoutLevel := na
    savedBreakoutName := ""
    zoneLow := na
    zoneHigh := na
    retestHigh := na

//--------------------------------------------------
// Setup
//--------------------------------------------------
bool setupSignal = breakoutNow and breakoutQualityPass and not setupActive

if setupSignal
    setupActive := true
    retestSeen := false
    setupBarIndex := bar_index
    retestBarIndex := na
    savedBreakoutLevel := breakoutLevel
    savedBreakoutName := breakoutName
    zoneLow := savedBreakoutLevel - atrVal * zoneAtrMult
    zoneHigh := savedBreakoutLevel + atrVal * zoneAtrMult
    retestHigh := na

//--------------------------------------------------
// Retest
//--------------------------------------------------
bool zoneExists = setupActive and not na(zoneLow) and not na(zoneHigh)
bool touchZone = zoneExists and low <= zoneHigh and high >= zoneLow
bool holdZone = zoneExists and close >= zoneLow
bool holdVWAP = close >= vwapVal
bool retestSignal = setupActive and not retestSeen and touchZone and holdZone and holdVWAP

if retestSignal
    retestSeen := true
    retestBarIndex := bar_index
    retestHigh := high

//--------------------------------------------------
// Reclaim / entry
//--------------------------------------------------
int barsAfterRetest = not na(retestBarIndex) ? bar_index - retestBarIndex : na
bool withinRetestWindow = not na(barsAfterRetest) and barsAfterRetest >= 1 and barsAfterRetest <= maxRetestBars
bool reclaimZone = zoneExists and close > zoneHigh
bool reclaimRetestHigh = not na(retestHigh) and close > retestHigh
bool reclaimRVOLPass = not na(barRVOL) and barRVOL >= minReclaimRVOL

bool entrySignal = setupActive and retestSeen and withinRetestWindow and reclaimZone and reclaimRetestHigh and reclaimRVOLPass and close > vwapVal

if entrySignal
    setupActive := false
    retestSeen := false
    setupBarIndex := na
    retestBarIndex := na
    savedBreakoutLevel := na
    savedBreakoutName := ""
    zoneLow := na
    zoneHigh := na
    retestHigh := na

//--------------------------------------------------
// Invalidation
//--------------------------------------------------
int barsAfterSetup = not na(setupBarIndex) ? bar_index - setupBarIndex : na
bool timeoutBeforeRetest = setupActive and not retestSeen and not na(barsAfterSetup) and barsAfterSetup > maxSetupBars
bool timeoutAfterRetest = setupActive and retestSeen and not na(barsAfterRetest) and barsAfterRetest > maxRetestBars
bool loseZone = zoneExists and close < zoneLow
bool loseVWAP = setupActive and close < vwapVal

bool invalidateSignal = timeoutBeforeRetest or timeoutAfterRetest or loseZone or loseVWAP

if invalidateSignal
    setupActive := false
    retestSeen := false
    setupBarIndex := na
    retestBarIndex := na
    savedBreakoutLevel := na
    savedBreakoutName := ""
    zoneLow := na
    zoneHigh := na
    retestHigh := na

//--------------------------------------------------
// Visuals
//--------------------------------------------------
plot(vwapVal, "VWAP", color=color.aqua, linewidth=2)
plot(usePDH ? prevDayHigh : na, "PDH", color=color.new(color.green, 40), style=plot.style_linebr)
plot(useFirst5 ? first5High : na, "First 5 High", color=color.new(color.orange, 35), style=plot.style_linebr)
plot(useORB15 ? first15High : na, "First 15 High", color=color.new(color.yellow, 35), style=plot.style_linebr)
plot(use10D ? high10D : na, "10D High", color=color.new(color.fuchsia, 35), style=plot.style_linebr)

plotZoneLow = plot(setupActive ? zoneLow : na, "Zone Low", color=color.new(color.teal, 0), style=plot.style_linebr)
plotZoneHigh = plot(setupActive ? zoneHigh : na, "Zone High", color=color.new(color.teal, 0), style=plot.style_linebr)
fill(plotZoneLow, plotZoneHigh, color=color.new(color.teal, 88))

plotshape(setupSignal, title="Setup", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="SET")
plotshape(retestSignal, title="Retest", style=shape.circle, location=location.belowbar, color=color.orange, size=size.tiny, text="RT")
plotshape(entrySignal, title="Entry", style=shape.labelup, location=location.belowbar, color=color.green, size=size.small, text="BUY")

plot(showDebug ? dayPaceRVOL : na, "Day Pace RVOL", color=color.new(color.blue, 0), linewidth=2)

//--------------------------------------------------
// Labels
//--------------------------------------------------
if showLabels and setupSignal
    label.new(bar_index, low, "SETUP " + savedBreakoutName + "\nBar RVOL: " + str.tostring(barRVOL, "#.##") + "\nPace: " + str.tostring(dayPaceRVOL, "#.##"), style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white)

if showLabels and retestSignal
    label.new(bar_index, low, "RETEST\nZone Hold", style=label.style_label_up, color=color.new(color.orange, 0), textcolor=color.white)

if showLabels and entrySignal
    label.new(bar_index, low, "ENTRY\nReclaim", style=label.style_label_up, color=color.new(color.blue, 0), textcolor=color.white)

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(setupSignal, title="Setup Alert", message="SETUP: {{ticker}} breakout with VWAP, RVOL and pace confirmation")
alertcondition(retestSignal, title="Retest Alert", message="RETEST: {{ticker}} pullback into zone and hold")
alertcondition(entrySignal, title="Entry Alert", message="ENTRY: {{ticker}} reclaim above zone and retest high")
````
