# CLBS Reaction Zones

- url: https://www.tradingview.com/script/TWI1CL8W-CLBS-Reaction-Zones/
- type: indicator
- pine_id: PUB;ae78d933fbb2427ca548c066ca83c6ed
- version: 1.0

## Description

CLBS Reaction Zones is an educational market-structure indicator designed to map important reaction areas on the chart.

CLBS stands for Context, Levels, Behavior and Strategy.

This script combines multiple market reference concepts into one structured visual map. The purpose is not to generate buy or sell signals, but to help traders observe where price may react, accept, reject, rotate or expand.

Main components:

• Developing day levels
• Previous day levels
• Developing week levels
• Previous week levels
• Developing month levels
• Previous month levels
• Initial Balance High and Initial Balance Low
• Initial Balance range projection
• Developing day Point of Control, Value Area High and Value Area Low
• Daily, Weekly, Monthly, Quarterly and Yearly VWAP
• Optional VWAP bands
• Fair Value Gap zones using three-candle imbalance logic

VWAP logic:

The VWAP hierarchy uses anchored VWAP calculations for different periods. Daily VWAP resets at the start of each new day. Weekly VWAP resets at the start of each new week. Monthly VWAP resets at the start of each new month. Quarterly VWAP resets every three months. Yearly VWAP resets at the start of each new year.

VWAP is calculated using cumulative price multiplied by volume divided by cumulative volume for the selected period.

Value area logic:

The developing day value area uses a simple volume distribution model. Price is divided into buckets, volume is accumulated inside those buckets, and the highest-volume bucket becomes the developing Point of Control. Value Area High and Value Area Low are calculated around the Point of Control using the selected value area percentage.

Fair Value Gap logic:

Fair Value Gap zones are based on a three-candle imbalance model. A bullish gap is detected when the high from two candles back is below the current low. A bearish gap is detected when the low from two candles back is above the current high. Filled gaps can be removed automatically.

How to use:

Use this indicator as a market reading map. Watch how price behaves around VWAP, Initial Balance, previous session references, value area levels and fair value gaps. Reaction, acceptance and rejection around these levels can help traders build context.

This script is for educational and analytical use only. It does not provide financial advice, investment advice, trading recommendations, buy signals or sell signals. Traders should use their own analysis, risk management and decision-making.

## Source Code

````pine
//@version=5
indicator("CLBS Reaction Zones", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMain = "Display"
shortLabels    = input.bool(true, "Short Labels", group=groupMain)
showWatermark  = input.bool(false, "Show Watermark", group=groupMain)
labelOffset    = input.int(10, "Label Offset", minval=1, maxval=100, group=groupMain)
lineLeftBars   = input.int(350, "Line Left Length", minval=50, maxval=2000, group=groupMain)
showNearbyOnly = input.bool(false, "Show Nearby Levels Only", group=groupMain)
nearbyRange    = input.float(1200, "Nearby Range Points", minval=50, step=50, group=groupMain)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALENDAR LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCalendar = "Calendar Reaction Levels"
showDayLevels   = input.bool(true, "Show Developing Day Levels", group=groupCalendar)
showPrevDay     = input.bool(true, "Show Previous Day Levels", group=groupCalendar)
showWeekLevels  = input.bool(true, "Show Developing Week Levels", group=groupCalendar)
showPrevWeek    = input.bool(true, "Show Previous Week Levels", group=groupCalendar)
showMonthLevels = input.bool(true, "Show Developing Month Levels", group=groupCalendar)
showPrevMonth   = input.bool(true, "Show Previous Month Levels", group=groupCalendar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE PRECISION LAYER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore = "Core Precision Layer"
showIB   = input.bool(true, "Show Initial Balance", group=groupCore)
showIBR  = input.bool(true, "Show IB Range Projection", group=groupCore)
ibMin    = input.int(60, "Initial Balance Minutes", minval=5, maxval=180, group=groupCore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VALUE AREA LAYER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupVP = "Value Area Layer"
showDayProfile = input.bool(true, "Show Day POC / VAH / VAL", group=groupVP)
vaLineOpacity   = input.int(40, "DVAH / DVAL Line Opacity", minval=0, maxval=90, group=groupVP)
vaLineWidth     = input.int(1, "DVAH / DVAL Line Width", minval=1, maxval=3, group=groupVP)
bucketStep      = input.float(5.0, "Bucket Step Points", minval=0.05, step=0.05, group=groupVP)
bucketCount     = input.int(160, "Number of Buckets", minval=30, maxval=300, group=groupVP)
valueAreaPct    = input.float(0.682, "Value Area Fraction", minval=0.10, maxval=0.99, step=0.01, group=groupVP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP HIERARCHY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupVWAP = "VWAP Hierarchy"

showDailyVWAP     = input.bool(true, "Show Daily VWAP", group=groupVWAP)
showWeeklyVWAP    = input.bool(true, "Show Weekly VWAP", group=groupVWAP)
showMonthlyVWAP   = input.bool(true, "Show Monthly VWAP", group=groupVWAP)
showQuarterlyVWAP = input.bool(true, "Show Quarterly VWAP", group=groupVWAP)
showYearlyVWAP    = input.bool(true, "Show Yearly VWAP", group=groupVWAP)

vwapSource = input.source(hlc3, "VWAP Source", group=groupVWAP)
showVWAPLabels = input.bool(true, "Show VWAP Labels", group=groupVWAP)

showDailyVWAPBands     = input.bool(false, "Show Daily VWAP Bands", group=groupVWAP)
showWeeklyVWAPBands    = input.bool(false, "Show Weekly VWAP Bands", group=groupVWAP)
showMonthlyVWAPBands   = input.bool(false, "Show Monthly VWAP Bands", group=groupVWAP)
showQuarterlyVWAPBands = input.bool(false, "Show Quarterly VWAP Bands", group=groupVWAP)
showYearlyVWAPBands    = input.bool(false, "Show Yearly VWAP Bands", group=groupVWAP)

dailyBandMult     = input.float(1.0, "Daily Band Multiplier", minval=0.1, step=0.1, group=groupVWAP)
weeklyBandMult    = input.float(1.0, "Weekly Band Multiplier", minval=0.1, step=0.1, group=groupVWAP)
monthlyBandMult   = input.float(1.0, "Monthly Band Multiplier", minval=0.1, step=0.1, group=groupVWAP)
quarterlyBandMult = input.float(1.0, "Quarterly Band Multiplier", minval=0.1, step=0.1, group=groupVWAP)
yearlyBandMult    = input.float(1.0, "Yearly Band Multiplier", minval=0.1, step=0.1, group=groupVWAP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FAIR VALUE GAP ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupFVG = "Fair Value Gap Zones"

showFVG = input.bool(true, "Show Fair Value Gap Zones", group=groupFVG)
showBullishFVG = input.bool(true, "Show Bullish FVG", group=groupFVG)
showBearishFVG = input.bool(true, "Show Bearish FVG", group=groupFVG)
removeFilledFVG = input.bool(true, "Remove Filled FVG", group=groupFVG)
maxFVGZones = input.int(5, "Maximum FVG Zones", minval=1, maxval=30, group=groupFVG)
minFVGSize = input.float(0.0, "Minimum FVG Size Points", minval=0.0, step=0.05, group=groupFVG)
showFVGLabels = input.bool(true, "Show FVG Labels", group=groupFVG)

cBullFVG = input.color(color.new(color.rgb(0, 180, 120), 84), "Bullish FVG Fill", group=groupFVG)
cBearFVG = input.color(color.new(color.rgb(220, 70, 70), 84), "Bearish FVG Fill", group=groupFVG)
cBullFVGBorder = input.color(color.new(color.rgb(0, 150, 100), 40), "Bullish FVG Border", group=groupFVG)
cBearFVGBorder = input.color(color.new(color.rgb(200, 50, 50), 40), "Bearish FVG Border", group=groupFVG)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cHigh  = color.rgb(20, 130, 75)
cLow   = color.rgb(120, 25, 20)
cOpen  = color.rgb(35, 90, 230)
cClose = color.rgb(0, 130, 150)
cHalf  = color.rgb(130, 70, 220)

cDailyVWAP     = color.rgb(255, 145, 0)
cWeeklyVWAP    = color.rgb(140, 90, 255)
cMonthlyVWAP   = color.rgb(40, 165, 255)
cQuarterlyVWAP = color.rgb(0, 175, 135)
cYearlyVWAP    = color.rgb(255, 70, 160)

cVWAPBand = color.rgb(255, 190, 70)

cPOC   = color.rgb(255, 190, 0)
cVAH   = color.rgb(95, 95, 95)
cVAL   = color.rgb(95, 95, 95)
cIB    = color.rgb(255, 120, 0)
cIBR   = color.rgb(0, 180, 220)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECT CONTROL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[] lines = array.new_line()
var label[] labels = array.new_label()

clearAll() =>
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label.delete(array.pop(labels))

canShow(level) =>
    not na(level) and (not showNearbyOnly or math.abs(close - level) <= nearbyRange)

makeTip(fullTxt, level) =>
    fullTxt + "\nPrice: " + str.tostring(level, format.mintick)

drawLevel(level, shortTxt, fullTxt, col, width, transp, stagger) =>
    if canShow(level)
        ln = line.new(bar_index - lineLeftBars, level, bar_index + labelOffset, level, xloc=xloc.bar_index, extend=extend.right, color=color.new(col, transp), width=width)
        array.push(lines, ln)
        y = level + stagger * syminfo.mintick * 22
        lb = label.new(bar_index + labelOffset, y, shortLabels ? shortTxt : fullTxt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(col, math.min(transp, 60)), size=size.small, tooltip=makeTip(fullTxt, level))
        array.push(labels, lb)

drawProjection(level, shortTxt, fullTxt, col, stagger) =>
    if canShow(level)
        ln = line.new(bar_index - lineLeftBars, level, bar_index + labelOffset, level, xloc=xloc.bar_index, extend=extend.right, color=color.new(col, 25), width=1, style=line.style_dotted)
        array.push(lines, ln)
        y = level + stagger * syminfo.mintick * 22
        lb = label.new(bar_index + labelOffset, y, shortLabels ? shortTxt : fullTxt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(col, 20), size=size.small, tooltip=makeTip(fullTxt, level))
        array.push(labels, lb)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newDay   = ta.change(time("D")) != 0
newWeek  = ta.change(time("W")) != 0
newMonth = ta.change(time("M")) != 0

currentQuarter = int(math.ceil(month(time) / 3.0))
previousQuarter = na(time[1]) ? currentQuarter : int(math.ceil(month(time[1]) / 3.0))
previousYear = na(time[1]) ? year(time) : year(time[1])
newQuarter = currentQuarter != previousQuarter or year(time) != previousYear
newYear = year(time) != previousYear

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVIOUS LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pdo = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
pdhb = (pdh + pdl) / 2

pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
pwc = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
pwhb = (pwh + pwl) / 2

pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)
pmhb = (pmh + pml) / 2

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DEVELOPING LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float ddh = na
var float ddl = na
var float ddo = na

if newDay or na(ddh)
    ddh := high
    ddl := low
    ddo := open
else
    ddh := math.max(ddh, high)
    ddl := math.min(ddl, low)

ddhb = (ddh + ddl) / 2

var float dwh = na
var float dwl = na
var float dwo = na

if newWeek or na(dwh)
    dwh := high
    dwl := low
    dwo := open
else
    dwh := math.max(dwh, high)
    dwl := math.min(dwl, low)

dwhb = (dwh + dwl) / 2

var float dmh = na
var float dml = na
var float dmo = na

if newMonth or na(dmh)
    dmh := high
    dml := low
    dmo := open
else
    dmh := math.max(dmh, high)
    dml := math.min(dml, low)

dmhb = (dmh + dml) / 2

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INITIAL BALANCE + IBR PROJECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float ibh = na
var float ibl = na
var int dayStart = na
var bool ibReady = false

if newDay or na(dayStart)
    dayStart := time
    ibh := high
    ibl := low
    ibReady := false
else
    inIB = time <= dayStart + ibMin * 60 * 1000
    if inIB
        ibh := math.max(ibh, high)
        ibl := math.min(ibl, low)
    else
        ibReady := true

ibRange = ibh - ibl
ibrHigh = ibh + ibRange
ibrLow  = ibl - ibRange

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ANCHORED VWAP ENGINE
// Formula: VWAP = Σ(price × volume) / Σ(volume)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float dVol = 0.0
var float dPV = 0.0
var float dP2V = 0.0

if newDay
    dVol := 0.0
    dPV := 0.0
    dP2V := 0.0

dVol += volume
dPV += vwapSource * volume
dP2V += vwapSource * vwapSource * volume

dailyVWAP = dVol > 0 ? dPV / dVol : na
dailyVar = dVol > 0 ? math.max(dP2V / dVol - dailyVWAP * dailyVWAP, 0.0) : na
dailyDev = math.sqrt(dailyVar)

var float wVol = 0.0
var float wPV = 0.0
var float wP2V = 0.0

if newWeek
    wVol := 0.0
    wPV := 0.0
    wP2V := 0.0

wVol += volume
wPV += vwapSource * volume
wP2V += vwapSource * vwapSource * volume

weeklyVWAP = wVol > 0 ? wPV / wVol : na
weeklyVar = wVol > 0 ? math.max(wP2V / wVol - weeklyVWAP * weeklyVWAP, 0.0) : na
weeklyDev = math.sqrt(weeklyVar)

var float mVol = 0.0
var float mPV = 0.0
var float mP2V = 0.0

if newMonth
    mVol := 0.0
    mPV := 0.0
    mP2V := 0.0

mVol += volume
mPV += vwapSource * volume
mP2V += vwapSource * vwapSource * volume

monthlyVWAP = mVol > 0 ? mPV / mVol : na
monthlyVar = mVol > 0 ? math.max(mP2V / mVol - monthlyVWAP * monthlyVWAP, 0.0) : na
monthlyDev = math.sqrt(monthlyVar)

var float qVol = 0.0
var float qPV = 0.0
var float qP2V = 0.0

if newQuarter
    qVol := 0.0
    qPV := 0.0
    qP2V := 0.0

qVol += volume
qPV += vwapSource * volume
qP2V += vwapSource * vwapSource * volume

quarterlyVWAP = qVol > 0 ? qPV / qVol : na
quarterlyVar = qVol > 0 ? math.max(qP2V / qVol - quarterlyVWAP * quarterlyVWAP, 0.0) : na
quarterlyDev = math.sqrt(quarterlyVar)

var float yVol = 0.0
var float yPV = 0.0
var float yP2V = 0.0

if newYear
    yVol := 0.0
    yPV := 0.0
    yP2V := 0.0

yVol += volume
yPV += vwapSource * volume
yP2V += vwapSource * vwapSource * volume

yearlyVWAP = yVol > 0 ? yPV / yVol : na
yearlyVar = yVol > 0 ? math.max(yP2V / yVol - yearlyVWAP * yearlyVWAP, 0.0) : na
yearlyDev = math.sqrt(yearlyVar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showDailyVWAP ? dailyVWAP : na, "Daily VWAP", color=cDailyVWAP, linewidth=2)
plot(showWeeklyVWAP ? weeklyVWAP : na, "Weekly VWAP", color=cWeeklyVWAP, linewidth=2)
plot(showMonthlyVWAP ? monthlyVWAP : na, "Monthly VWAP", color=cMonthlyVWAP, linewidth=2)
plot(showQuarterlyVWAP ? quarterlyVWAP : na, "Quarterly VWAP", color=cQuarterlyVWAP, linewidth=2)
plot(showYearlyVWAP ? yearlyVWAP : na, "Yearly VWAP", color=cYearlyVWAP, linewidth=2)

plot(showDailyVWAP and showDailyVWAPBands ? dailyVWAP + dailyDev * dailyBandMult : na, "Daily VWAP Upper Band", color=color.new(cVWAPBand, 20), linewidth=1)
plot(showDailyVWAP and showDailyVWAPBands ? dailyVWAP - dailyDev * dailyBandMult : na, "Daily VWAP Lower Band", color=color.new(cVWAPBand, 20), linewidth=1)

plot(showWeeklyVWAP and showWeeklyVWAPBands ? weeklyVWAP + weeklyDev * weeklyBandMult : na, "Weekly VWAP Upper Band", color=color.new(cWeeklyVWAP, 50), linewidth=1)
plot(showWeeklyVWAP and showWeeklyVWAPBands ? weeklyVWAP - weeklyDev * weeklyBandMult : na, "Weekly VWAP Lower Band", color=color.new(cWeeklyVWAP, 50), linewidth=1)

plot(showMonthlyVWAP and showMonthlyVWAPBands ? monthlyVWAP + monthlyDev * monthlyBandMult : na, "Monthly VWAP Upper Band", color=color.new(cMonthlyVWAP, 50), linewidth=1)
plot(showMonthlyVWAP and showMonthlyVWAPBands ? monthlyVWAP - monthlyDev * monthlyBandMult : na, "Monthly VWAP Lower Band", color=color.new(cMonthlyVWAP, 50), linewidth=1)

plot(showQuarterlyVWAP and showQuarterlyVWAPBands ? quarterlyVWAP + quarterlyDev * quarterlyBandMult : na, "Quarterly VWAP Upper Band", color=color.new(cQuarterlyVWAP, 50), linewidth=1)
plot(showQuarterlyVWAP and showQuarterlyVWAPBands ? quarterlyVWAP - quarterlyDev * quarterlyBandMult : na, "Quarterly VWAP Lower Band", color=color.new(cQuarterlyVWAP, 50), linewidth=1)

plot(showYearlyVWAP and showYearlyVWAPBands ? yearlyVWAP + yearlyDev * yearlyBandMult : na, "Yearly VWAP Upper Band", color=color.new(cYearlyVWAP, 50), linewidth=1)
plot(showYearlyVWAP and showYearlyVWAPBands ? yearlyVWAP - yearlyDev * yearlyBandMult : na, "Yearly VWAP Lower Band", color=color.new(cYearlyVWAP, 50), linewidth=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DEVELOPING DAY VALUE AREA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float[] prices = array.new_float()
var float[] vols = array.new_float()

if newDay
    array.clear(prices)
    array.clear(vols)

array.push(prices, hlc3)
array.push(vols, volume)

calcProfile(_prices, _vols) =>
    float poc = na
    float vah = na
    float val = na

    if array.size(_prices) > 5
        lo = array.min(_prices)
        hi = array.max(_prices)
        step = bucketStep
        buckets = math.min(bucketCount, math.max(20, int(math.ceil((hi - lo) / step)) + 1))
        float[] bVols = array.new_float(buckets, 0.0)

        for i = 0 to array.size(_prices) - 1
            p = array.get(_prices, i)
            v = array.get(_vols, i)
            idx = int(math.floor((p - lo) / step))
            idx := math.max(0, math.min(buckets - 1, idx))
            array.set(bVols, idx, array.get(bVols, idx) + v)

        maxVol = array.max(bVols)
        pocIdx = array.indexof(bVols, maxVol)
        poc := lo + pocIdx * step

        totalVol = array.sum(bVols)
        targetVol = totalVol * valueAreaPct
        accVol = array.get(bVols, pocIdx)

        left = pocIdx
        right = pocIdx

        while accVol < targetVol and (left > 0 or right < buckets - 1)
            leftVol = left > 0 ? array.get(bVols, left - 1) : -1.0
            rightVol = right < buckets - 1 ? array.get(bVols, right + 1) : -1.0

            if rightVol >= leftVol
                right += 1
                accVol += math.max(rightVol, 0)
            else
                left -= 1
                accVol += math.max(leftVol, 0)

        val := lo + left * step
        vah := lo + right * step

    [poc, vah, val]

[dayPOC, dayVAH, dayVAL] = calcProfile(prices, vols)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FAIR VALUE GAP ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] fvgBoxes = array.new_box()
var label[] fvgLabels = array.new_label()
var float[] fvgTops = array.new_float()
var float[] fvgBottoms = array.new_float()
var bool[] fvgIsBullish = array.new_bool()

fvgSize(top, bottom) =>
    math.abs(top - bottom)

deleteFVG(idx) =>
    if idx >= 0 and idx < array.size(fvgBoxes)
        bx = array.get(fvgBoxes, idx)
        box.delete(bx)
        lb = array.get(fvgLabels, idx)
        label.delete(lb)
        array.remove(fvgBoxes, idx)
        array.remove(fvgLabels, idx)
        array.remove(fvgTops, idx)
        array.remove(fvgBottoms, idx)
        array.remove(fvgIsBullish, idx)

addFVG(top, bottom, isBullish) =>
    if showFVG and fvgSize(top, bottom) >= minFVGSize
        fillColor = isBullish ? cBullFVG : cBearFVG
        borderColor = isBullish ? cBullFVGBorder : cBearFVGBorder
        txt = isBullish ? "Bullish FVG" : "Bearish FVG"
        mid = (top + bottom) / 2.0
        bx = box.new(bar_index - 2, top, bar_index + labelOffset, bottom, xloc=xloc.bar_index, extend=extend.right, bgcolor=fillColor, border_color=borderColor)
        lb = label.new(bar_index + labelOffset, mid, showFVGLabels ? txt : "", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(isBullish ? color.rgb(0, 150, 100) : color.rgb(200, 50, 50), 20), size=size.tiny, tooltip=txt + "\nTop: " + str.tostring(top, format.mintick) + "\nBottom: " + str.tostring(bottom, format.mintick))
        array.push(fvgBoxes, bx)
        array.push(fvgLabels, lb)
        array.push(fvgTops, top)
        array.push(fvgBottoms, bottom)
        array.push(fvgIsBullish, isBullish)
        while array.size(fvgBoxes) > maxFVGZones
            deleteFVG(0)

bullishFVG = showBullishFVG and high[2] < low
bearishFVG = showBearishFVG and low[2] > high

if bullishFVG
    addFVG(low, high[2], true)

if bearishFVG
    addFVG(low[2], high, false)

if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        top = array.get(fvgTops, i)
        bottom = array.get(fvgBottoms, i)
        isBull = array.get(fvgIsBullish, i)
        bx = array.get(fvgBoxes, i)
        lb = array.get(fvgLabels, i)

        box.set_right(bx, bar_index + labelOffset)
        label.set_x(lb, bar_index + labelOffset)
        label.set_y(lb, (top + bottom) / 2.0)

        bullFilled = isBull and low <= bottom
        bearFilled = not isBull and high >= top

        if removeFilledFVG and (bullFilled or bearFilled)
            deleteFVG(i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    clearAll()

    if showVWAPLabels
        if showDailyVWAP
            drawLevel(dailyVWAP, "VWAP", "Daily VWAP", cDailyVWAP, 2, 0, 0)
        if showWeeklyVWAP
            drawLevel(weeklyVWAP, "WVAP", "Weekly VWAP", cWeeklyVWAP, 2, 0, 1)
        if showMonthlyVWAP
            drawLevel(monthlyVWAP, "MVAP", "Monthly VWAP", cMonthlyVWAP, 2, 0, -1)
        if showQuarterlyVWAP
            drawLevel(quarterlyVWAP, "QVAP", "Quarterly VWAP", cQuarterlyVWAP, 2, 0, 2)
        if showYearlyVWAP
            drawLevel(yearlyVWAP, "YVAP", "Yearly VWAP", cYearlyVWAP, 2, 0, -2)

    if showIB and ibReady
        drawLevel(ibh, "IBH", "Initial Balance High", cIB, 2, 0, 1)
        drawLevel(ibl, "IBL", "Initial Balance Low", cIB, 2, 0, -1)

    if showIBR and ibReady
        drawProjection(ibrHigh, "IBRH", "Initial Balance Range High Projection", cIBR, 2)
        drawProjection(ibrLow, "IBRL", "Initial Balance Range Low Projection", cIBR, -2)

    if showDayProfile
        drawLevel(dayPOC, "DPOC", "Developing Day Point of Control", cPOC, 2, 5, 3)
        drawLevel(dayVAH, "DVAH", "Developing Day Value Area High", cVAH, vaLineWidth, vaLineOpacity, 4)
        drawLevel(dayVAL, "DVAL", "Developing Day Value Area Low", cVAL, vaLineWidth, vaLineOpacity, -4)

    if showDayLevels
        drawLevel(ddh, "DDH", "Developing Day High", cHigh, 1, 35, 5)
        drawLevel(ddl, "DDL", "Developing Day Low", cLow, 1, 35, -5)
        drawLevel(ddo, "DDO", "Developing Day Open", cOpen, 1, 45, 6)
        drawLevel(ddhb, "DHB", "Developing Day Halfback", cHalf, 1, 50, -6)

    if showPrevDay
        drawLevel(pdh, "PDH", "Previous Day High", cHigh, 2, 0, 7)
        drawLevel(pdl, "PDL", "Previous Day Low", cLow, 2, 0, -7)
        drawLevel(pdo, "PDO", "Previous Day Open", cOpen, 1, 45, 8)
        drawLevel(pdc, "PDC", "Previous Day Close", cClose, 1, 35, -8)
        drawLevel(pdhb, "PHB", "Previous Day Halfback", cHalf, 1, 55, 9)

    if showWeekLevels
        drawLevel(dwh, "DWH", "Developing Week High", cHigh, 1, 50, 10)
        drawLevel(dwl, "DWL", "Developing Week Low", cLow, 1, 50, -10)
        drawLevel(dwo, "WO", "Weekly Open", cOpen, 1, 35, 11)
        drawLevel(dwhb, "WHB", "Week Halfback", cHalf, 1, 60, -11)

    if showPrevWeek
        drawLevel(pwh, "PWH", "Previous Week High", cHigh, 1, 35, 12)
        drawLevel(pwl, "PWL", "Previous Week Low", cLow, 1, 35, -12)
        drawLevel(pwc, "PWC", "Previous Week Close", cClose, 1, 45, 13)
        drawLevel(pwhb, "PWHB", "Previous Week Halfback", cHalf, 1, 60, -13)

    if showMonthLevels
        drawLevel(dmh, "DMH", "Developing Month High", cHigh, 1, 60, 14)
        drawLevel(dml, "DML", "Developing Month Low", cLow, 1, 60, -14)
        drawLevel(dmo, "MO", "Monthly Open", cOpen, 1, 55, 15)
        drawLevel(dmhb, "MHB", "Month Halfback", cHalf, 1, 65, -15)

    if showPrevMonth
        drawLevel(pmh, "PMH", "Previous Month High", cHigh, 2, 20, 16)
        drawLevel(pml, "PML", "Previous Month Low", cLow, 2, 20, -16)
        drawLevel(pmhb, "PMHB", "Previous Month Halfback", cHalf, 1, 65, 17)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WATERMARK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table wm = table.new(position.bottom_right, 1, 1)

if barstate.islast
    if showWatermark
        table.cell(wm, 0, 0, "CLBS Reaction Zones", text_color=color.new(color.gray, 45), text_size=size.small)
    else
        table.cell(wm, 0, 0, "")
````
