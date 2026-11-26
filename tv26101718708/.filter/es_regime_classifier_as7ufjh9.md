# ES Regime Classifier

- url: https://www.tradingview.com/script/aS7ufJH9-ES-Regime-Classifier/
- type: indicator
- pine_id: PUB;12f7e19a8a304f3f8bc453635753451a
- version: 2.0

## Description

The ES Regime Classifier is a market-state and participation-quality framework. It does NOT generate trade signals. It classifies volatility-auction conditions so that you can understand which plans perform better or worse under specific market regimes.

## Source Code

````pine
//@version=5
indicator("ES Regime Classifier", overlay=true, max_lines_count=500, max_labels_count=500)

//==============================
// Inputs
//==============================
grpCore = "Core Settings"
atrLen = input.int(14, "ATR Length", group=grpCore)
compressedPct = input.float(0.30, "Compressed Threshold", step=0.05, group=grpCore)
expandedPct = input.float(0.50, "Expanded Threshold", step=0.05, group=grpCore)
stretchedPct = input.float(0.80, "Stretched Threshold", step=0.05, group=grpCore)

grpSessions = "Sessions - New York Time"
dailyIbSession = input.session("0930-1030", "Daily IB Session", group=grpSessions)
globexIbSession = input.session("0400-0930", "Pre-NY IB Session", group=grpSessions)
globexFullSession = input.session("1800-0930", "Full Globex Session", group=grpSessions)

grpDisplay = "Display"
showDaily = input.bool(true, "Show Daily IB", group=grpDisplay)
showGlobex = input.bool(true, "Show Pre-NY IB", group=grpDisplay)
showWeekly = input.bool(false, "Show Weekly IB", group=grpDisplay)
showMidnightOpen = input.bool(true, "Show Midnight Open", group=grpDisplay)
showSettlement = input.bool(true, "Show Settlement", group=grpDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=grpDisplay)

dashboardPositionInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDisplay)

grpStyle = "Styles"
dailyWidth = input.int(2, "Daily IB Thickness", minval=1, maxval=5, group=grpStyle)
globexWidth = input.int(2, "Pre-NY IB Thickness", minval=1, maxval=5, group=grpStyle)
weeklyWidth = input.int(2, "Weekly IB Thickness", minval=1, maxval=5, group=grpStyle)

dailyStyleInput = input.string("Line Break", "Daily IB Style", options=["Line", "Line Break", "Circles"], group=grpStyle)
globexStyleInput = input.string("Circles", "Pre-NY IB Style", options=["Line", "Line Break", "Circles"], group=grpStyle)
weeklyStyleInput = input.string("Line Break", "Weekly IB Style", options=["Line", "Line Break", "Circles"], group=grpStyle)

midnightColor = input.color(color.purple, "Midnight Open Color", group=grpStyle)
midnightWidth = input.int(2, "Midnight Open Thickness", minval=1, maxval=5, group=grpStyle)
midnightLineStyleInput = input.string("Dashed", "Midnight Open Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

settlementColor = input.color(color.blue, "Settlement Color", group=grpStyle)
settlementWidth = input.int(2, "Settlement Thickness", minval=1, maxval=5, group=grpStyle)
settlementLineStyleInput = input.string("Dotted", "Settlement Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

labelTextSizeInput = input.string("Tiny", "Line Label Size", options=["Tiny", "Small", "Normal"], group=grpStyle)

compressedColor = input.color(color.teal, "Compressed Color", group=grpStyle)
balancedColor = input.color(color.gray, "Balanced Color", group=grpStyle)
expandedColor = input.color(color.orange, "Expanded Color", group=grpStyle)
stretchedColor = input.color(color.red, "Stretched Color", group=grpStyle)

//==============================
// Helpers
//==============================
getState(ratio) =>
    na(ratio) ? "N/A" :
     ratio < compressedPct ? "COMPRESSED" :
     ratio < expandedPct ? "BALANCED" :
     ratio < stretchedPct ? "EXPANDED" :
     "STRETCHED"

getColor(state) =>
    state == "COMPRESSED" ? compressedColor :
     state == "BALANCED" ? balancedColor :
     state == "EXPANDED" ? expandedColor :
     state == "STRETCHED" ? stretchedColor :
     color.black

getPlotStyle(styleInput) =>
    styleInput == "Line" ? plot.style_line :
     styleInput == "Circles" ? plot.style_circles :
     plot.style_linebr

getLineStyle(styleInput) =>
    styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted :
     line.style_solid

getLabelSize(sizeInput) =>
    sizeInput == "Small" ? size.small :
     sizeInput == "Normal" ? size.normal :
     size.tiny

dailyPlotStyle = getPlotStyle(dailyStyleInput)
globexPlotStyle = getPlotStyle(globexStyleInput)
weeklyPlotStyle = getPlotStyle(weeklyStyleInput)
midnightLineStyle = getLineStyle(midnightLineStyleInput)
settlementLineStyle = getLineStyle(settlementLineStyleInput)
lineLabelSize = getLabelSize(labelTextSizeInput)

//==============================
// ATR
//==============================
dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(atrLen))
weeklyAtr = request.security(syminfo.tickerid, "W", ta.atr(atrLen))

//==============================
// Time
//==============================
dow = dayofweek
hourNY = hour(time, "America/New_York")
minuteNY = minute(time, "America/New_York")

//==============================
// VIX
//==============================
vix = request.security("TVC:VIX", timeframe.period, close)
vixOpen = request.security("TVC:VIX", "D", open)
vixChange = vixOpen > 0 ? ((vix - vixOpen) / vixOpen) * 100 : na

vixState =
     na(vixChange) ? "N/A" :
     vixChange > 5 ? "VOL SHOCK" :
     vixChange > 2 ? "VOL RISING" :
     vixChange < -3 ? "VOL CRUSH" :
     "VOL STABLE"

vixColor =
     vixState == "VOL SHOCK" ? stretchedColor :
     vixState == "VOL RISING" ? expandedColor :
     vixState == "VOL CRUSH" ? color.green :
     balancedColor

//==============================
// Daily IB
//==============================
inDailyIb = not na(time(timeframe.period, dailyIbSession, "America/New_York"))
newDailyIb = inDailyIb and not inDailyIb[1]

var float dHigh = na
var float dLow = na

if newDailyIb
    dHigh := high
    dLow := low
else if inDailyIb
    dHigh := math.max(nz(dHigh, high), high)
    dLow := math.min(nz(dLow, low), low)

dSize = dHigh - dLow
dRatio = dailyAtr > 0 ? dSize / dailyAtr : na
dState = getState(dRatio)
dColor = getColor(dState)
dFuel = math.max(0, dailyAtr - nz(dSize, 0))

//==============================
// Full Globex ATR Baseline
//==============================
inFullGlobex = not na(time(timeframe.period, globexFullSession, "America/New_York"))
newFullGlobex = inFullGlobex and not inFullGlobex[1]

var float fullHigh = na
var float fullLow = na
var rangeArray = array.new_float()

if newFullGlobex
    if not na(fullHigh) and not na(fullLow)
        array.push(rangeArray, fullHigh - fullLow)
        if array.size(rangeArray) > atrLen
            array.shift(rangeArray)
    fullHigh := high
    fullLow := low
else if inFullGlobex
    fullHigh := math.max(nz(fullHigh, high), high)
    fullLow := math.min(nz(fullLow, low), low)

globexAtr = array.size(rangeArray) > 0 ? array.avg(rangeArray) : dailyAtr * 0.35

//==============================
// Pre-NY IB
//==============================
inGlobexIb = not na(time(timeframe.period, globexIbSession, "America/New_York"))
newGlobexIb = inGlobexIb and not inGlobexIb[1]

var float gHigh = na
var float gLow = na

if newGlobexIb
    gHigh := high
    gLow := low
else if inGlobexIb
    gHigh := math.max(nz(gHigh, high), high)
    gLow := math.min(nz(gLow, low), low)

gSize = gHigh - gLow
gRatio = globexAtr > 0 ? gSize / globexAtr : na
gState = getState(gRatio)
gColor = getColor(gState)
gFuel = math.max(0, globexAtr - nz(gSize, 0))

//==============================
// Weekly IB
//==============================
inWeeklyWindow =
     (dow == dayofweek.sunday and hourNY >= 18) or
     dow == dayofweek.monday or
     (dow == dayofweek.tuesday and hourNY < 16)

newWeeklyWindow = inWeeklyWindow and not inWeeklyWindow[1]

var float wHigh = na
var float wLow = na

if newWeeklyWindow
    wHigh := high
    wLow := low
else if inWeeklyWindow
    wHigh := math.max(nz(wHigh, high), high)
    wLow := math.min(nz(wLow, low), low)

wSize = wHigh - wLow
wRatio = weeklyAtr > 0 ? wSize / weeklyAtr : na
wState = getState(wRatio)
wColor = getColor(wState)
wFuel = math.max(0, weeklyAtr - nz(wSize, 0))

//==============================
// Midnight Open: 00:00 to 16:00 NY
//==============================
var line midnightLine = na
var label midnightLabel = na
var float midnightPrice = na

newMidnight = hourNY == 0 and minuteNY == 0

if newMidnight
    midnightPrice := open
    line.delete(midnightLine)
    label.delete(midnightLabel)

    midnightEndTime = time + (16 * 60 * 60 * 1000)

    if showMidnightOpen
        midnightLine := line.new(
             x1=time,
             y1=midnightPrice,
             x2=midnightEndTime,
             y2=midnightPrice,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=midnightColor,
             width=midnightWidth,
             style=midnightLineStyle
         )

        midnightLabel := label.new(
             x=midnightEndTime,
             y=midnightPrice,
             text="midnight",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=midnightColor,
             color=color.new(color.black, 100),
             size=lineLabelSize
         )

if not showMidnightOpen
    line.delete(midnightLine)
    label.delete(midnightLabel)
    midnightLine := na
    midnightLabel := na

//==============================
// Settlement: captures 16:00 NY close, displays 18:00 to 00:00
//==============================
var line settlementLine = na
var label settlementLabel = na
var float settlementPrice = na

isSettlementBar = hourNY == 16 and minuteNY == 0
isGlobexOpen = hourNY == 18 and minuteNY == 0

if isSettlementBar
    settlementPrice := close

if isGlobexOpen and not na(settlementPrice)
    line.delete(settlementLine)
    label.delete(settlementLabel)

    settlementEndTime = time + (6 * 60 * 60 * 1000)

    if showSettlement
        settlementLine := line.new(
             x1=time,
             y1=settlementPrice,
             x2=settlementEndTime,
             y2=settlementPrice,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=settlementColor,
             width=settlementWidth,
             style=settlementLineStyle
         )

        settlementLabel := label.new(
             x=settlementEndTime,
             y=settlementPrice,
             text="settlement",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=settlementColor,
             color=color.new(color.black, 100),
             size=lineLabelSize
         )

if not showSettlement
    line.delete(settlementLine)
    label.delete(settlementLabel)
    settlementLine := na
    settlementLabel := na

//==============================
// Contextual Regime Summary
//==============================
regimeText =
     wState == "COMPRESSED" and (dState == "EXPANDED" or dState == "STRETCHED") ? "MACRO COILED / LOCAL USED" :
     wState == "COMPRESSED" and dState == "COMPRESSED" ? "MULTI-TF COILED" :
     wState == "BALANCED" and dState == "BALANCED" ? "BALANCED AUCTION" :
     wState == "EXPANDED" and (dState == "EXPANDED" or dState == "STRETCHED") ? "LATE EXPANSION" :
     wState == "STRETCHED" or dState == "STRETCHED" ? "STRETCHED RISK" :
     "MIXED AUCTION"

regimeColor =
     regimeText == "MULTI-TF COILED" ? compressedColor :
     regimeText == "BALANCED AUCTION" ? balancedColor :
     regimeText == "MACRO COILED / LOCAL USED" ? expandedColor :
     regimeText == "LATE EXPANSION" ? stretchedColor :
     regimeText == "STRETCHED RISK" ? stretchedColor :
     expandedColor

//==============================
// Plotting
//==============================
showDailyLine =
     showDaily and
     not inDailyIb and
     hourNY >= 10 and
     hourNY <= 23

plot(showDailyLine ? dHigh : na, "Daily IB High", dColor, dailyWidth, dailyPlotStyle, editable=false)
plot(showDailyLine ? dLow : na, "Daily IB Low", dColor, dailyWidth, dailyPlotStyle, editable=false)

showGlobexLine =
     showGlobex and
     not inGlobexIb and
     (
         hourNY > 9 or
         (hourNY == 9 and minuteNY >= 30)
     ) and
     hourNY < 17

plot(showGlobexLine ? gHigh : na, "Pre-NY IB High", gColor, globexWidth, globexPlotStyle, editable=false)
plot(showGlobexLine ? gLow : na, "Pre-NY IB Low", gColor, globexWidth, globexPlotStyle, editable=false)

plot(showWeekly and not inWeeklyWindow ? wHigh : na, "Weekly IB High", wColor, weeklyWidth, weeklyPlotStyle, editable=false)
plot(showWeekly and not inWeeklyWindow ? wLow : na, "Weekly IB Low", wColor, weeklyWidth, weeklyPlotStyle, editable=false)

//==============================
// Dashboard
//==============================
dashboardPosition =
     dashboardPositionInput == "Top Left" ? position.top_left :
     dashboardPositionInput == "Bottom Right" ? position.bottom_right :
     dashboardPositionInput == "Bottom Left" ? position.bottom_left :
     position.top_right

var table dash = table.new(dashboardPosition, 4, 7, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Layer", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "Ratio", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 2, 0, "Fuel", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 3, 0, "State", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Weekly", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, str.tostring(wRatio, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 1, str.tostring(wFuel, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 1, wState, text_color=color.white, bgcolor=wColor)

    table.cell(dash, 0, 2, "Daily", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, str.tostring(dRatio, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 2, str.tostring(dFuel, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 2, dState, text_color=color.white, bgcolor=dColor)

    table.cell(dash, 0, 3, "Pre-NY", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, str.tostring(gRatio, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 3, str.tostring(gFuel, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 3, gState, text_color=color.white, bgcolor=gColor)

    table.cell(dash, 0, 4, "VIX", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, str.tostring(vix, "#.##"), text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 2, 4, str.tostring(vixChange, "#.##") + "%", text_color=color.white, bgcolor=balancedColor)
    table.cell(dash, 3, 4, vixState, text_color=color.white, bgcolor=vixColor)

    table.cell(dash, 0, 5, "Regime", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, "", bgcolor=color.black)
    table.cell(dash, 2, 5, "", bgcolor=color.black)
    table.cell(dash, 3, 5, regimeText, text_color=color.white, bgcolor=regimeColor)

//==============================
// Alerts
//==============================

//------------------------------
// State Code Helpers
//------------------------------
stateCode(state) =>
    state == "COMPRESSED" ? 1 :
     state == "BALANCED" ? 2 :
     state == "EXPANDED" ? 3 :
     state == "STRETCHED" ? 4 :
     0

vixCode(state) =>
    state == "VOL CRUSH" ? 1 :
     state == "VOL STABLE" ? 2 :
     state == "VOL RISING" ? 3 :
     state == "VOL SHOCK" ? 4 :
     0

//------------------------------
// Composite Regime Code
//------------------------------
// 1 = MULTI-TF COILED
// 2 = BALANCED AUCTION
// 3 = MACRO COILED / LOCAL USED
// 4 = LATE EXPANSION
// 5 = STRETCHED RISK
// 6 = MIXED AUCTION

compositeCode =
     regimeText == "MULTI-TF COILED" ? 1 :
     regimeText == "BALANCED AUCTION" ? 2 :
     regimeText == "MACRO COILED / LOCAL USED" ? 3 :
     regimeText == "LATE EXPANSION" ? 4 :
     regimeText == "STRETCHED RISK" ? 5 :
     regimeText == "MIXED AUCTION" ? 6 :
     0

//------------------------------
// Snapshot Windows
//------------------------------
// Daily IB snapshot window:
// On 30m chart, this usually alerts after the 10:30-11:00 bar closes.
// RTH close snapshot:
// On 30m chart, this usually alerts after the 16:00-16:30 bar closes.

dailyIbSnapshotWindow =
     hourNY == 10 and minuteNY >= 30 and minuteNY < 35

rthCloseSnapshotWindow =
     hourNY == 16 and minuteNY >= 0 and minuteNY < 5

// Pulse only once per snapshot window.
// This prevents duplicate alerts on lower timeframes like 1m or 5m.
dailyIbSnapshot =
     dailyIbSnapshotWindow and (bar_index == 0 or not dailyIbSnapshotWindow[1])

rthCloseSnapshot =
     rthCloseSnapshotWindow and (bar_index == 0 or not rthCloseSnapshotWindow[1])

snapshotTrigger =
     dailyIbSnapshot or rthCloseSnapshot

// 1 = Daily IB Snapshot
// 2 = RTH Close Snapshot
snapshotTypeCode =
     dailyIbSnapshot ? 1 :
     rthCloseSnapshot ? 2 :
     0

//------------------------------
// Hidden Export Plots
//------------------------------
// These hidden plots allow TradingView alert placeholders
// to export numeric values into the alert message.

plot(wRatio, "Weekly Ratio Alert", display=display.none)
plot(dRatio, "Daily Ratio Alert", display=display.none)
plot(gRatio, "PreNY Ratio Alert", display=display.none)
plot(vixChange, "VIX Change Alert", display=display.none)

plot(stateCode(wState), "Weekly State Code", display=display.none)
plot(stateCode(dState), "Daily State Code", display=display.none)
plot(stateCode(gState), "PreNY State Code", display=display.none)
plot(vixCode(vixState), "VIX State Code", display=display.none)

plot(compositeCode, "Composite Regime Code", display=display.none)
plot(snapshotTypeCode, "Snapshot Type Code", display=display.none)

//------------------------------
// Alert Message
//------------------------------
// Pipe-delimited key=value format.
// This is easier to paste here later and convert into CSV / Excel.

alertcondition(
     snapshotTrigger,
     title="ES Regime Snapshot",
     message=
     "ES_REGIME_SNAPSHOT|" +
     "schema=1|" +
     "bar_time_utc={{time}}|" +
     "alert_time_utc={{timenow}}|" +
     "ticker={{ticker}}|" +
     "timeframe={{interval}}|" +
     "close={{close}}|" +
     "snapshot_type={{plot(\"Snapshot Type Code\")}}|" +
     "weekly_state={{plot(\"Weekly State Code\")}}|" +
     "weekly_ratio={{plot(\"Weekly Ratio Alert\")}}|" +
     "daily_state={{plot(\"Daily State Code\")}}|" +
     "daily_ratio={{plot(\"Daily Ratio Alert\")}}|" +
     "preny_state={{plot(\"PreNY State Code\")}}|" +
     "preny_ratio={{plot(\"PreNY Ratio Alert\")}}|" +
     "vix_state={{plot(\"VIX State Code\")}}|" +
     "vix_change={{plot(\"VIX Change Alert\")}}|" +
     "composite_regime={{plot(\"Composite Regime Code\")}}")
````
