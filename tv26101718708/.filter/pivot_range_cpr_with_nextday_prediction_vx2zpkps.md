# Pivot Range (CPR) with Next-Day Prediction

- url: https://www.tradingview.com/script/Vx2zPKps-Pivot-Range-CPR-with-Next-Day-Prediction/
- type: indicator
- pine_id: PUB;a1d206166d2940938dafea0a1744bcbe
- version: 6.0

## Description

📌 Pivot Range (CPR) with Next-Day Prediction

This indicator plots the Central Pivot Range (CPR) based on Mark Fisher's Pivot Range methodology, with a key enhancement — it previews tomorrow's CPR as soon as the current trading session ends, so you don't have to wait for the next day's first candle.

How it works:

 - During market hours: Displays today's CPR (Pivot, BC, TC) calculated from the previous day's High, Low, and Close.
 - On the last candle of the session: Automatically switches to show tomorrow's CPR using the current day's completed HLC data.

What is CPR?
The Central Pivot Range consists of three levels:

 - Pivot (P) = (High + Low + Close) / 3
 - Bottom Central (BC) = (High + Low) / 2
 - Top Central (TC) = (Pivot − BC) + Pivot

CPR helps identify key support/resistance zones, trend direction, and potential breakout/reversal areas for the upcoming session.

Features:
✅ Next-day CPR prediction right at session close — no waiting until market open
✅ Toggle daily pivots on/off via settings
✅ Works on any intraday timeframe (1m, 5m, 15m, 1H, etc.)
✅ Works on any market/exchange — session detection is automatic
✅ Pine Script v6

Best used on: Intraday timeframes for day trading and swing trading setups.

## Source Code

````pine
//@version=6
indicator(title="Pivot Range", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

string grpC = "Central Pivot Range"
bool showDaily = input.bool(true, title="Show Daily CPR?", group=grpC)

string grpP = "Classic Pivots"
bool cpFiltered = input.bool(false, "Show Filtered Pivots",  group=grpP, tooltip="Original CM filter: picks the R1/S1 formula from the pivot's direction and hides R2/S2. The filter uses a fixed 0.0025 price offset, which is negligible on index-scale instruments.")
bool cpAvg      = input.bool(false, "Show Pivot Average",    group=grpP)
bool cpH1       = input.bool(false, "Show 1 Hour Pivots?",   group=grpP)
bool cpH4       = input.bool(false, "Show 4 Hour Pivots?",   group=grpP)
bool cpD        = input.bool(true,  "Show Daily Pivots?",    group=grpP)
bool cpW        = input.bool(true,  "Show Weekly Pivots?",   group=grpP)
bool cpM        = input.bool(true,  "Show Monthly Pivots?",  group=grpP)
bool cpY        = input.bool(false, "Show Yearly Pivots?",   group=grpP)
bool cpShowR3   = input.bool(false, "Show R3 & S3 Only On 1 Hour & 4 Hour?", group=grpP)

string grpV = "Virgin CPR (VCPR)"
bool   showVcpr      = input.bool(true, "Show Virgin CPR", group=grpV)
int    vcprMaxDays   = input.int(10, "Project Forward (trading days)", minval=0, maxval=60, group=grpV, tooltip="Number of trading days a virgin CPR is carried forward. Set to 0 to keep it until it is tested.")
string vcprTF        = input.timeframe("5", "Pierce-Check Timeframe", group=grpV, tooltip="A CPR is virgin only if no candle on this timeframe CLOSED inside the BC-TC band during its own day. Wicks into the band, and bars that open inside it but reverse away, both leave the CPR virgin. Works on any chart timeframe.")
bool   vcprShowLabel = input.bool(true, "Show Labels", group=grpV)
bool   vcprExtendRight = input.bool(true, "Extend Rectangle Right", group=grpV, tooltip="Project the rectangle past the last bar, so the level stays visible ahead of price for its whole life. Turn off to stop it at the current bar.")
color  vcprBorder    = input.color(#9C27B0, "Border", group=grpV, inline="vc")
color  vcprFill      = input.color(color.new(color.gray, 80), "Fill", group=grpV, inline="vc")

string grpH = "Untested Day High / Low"
bool   showDhl      = input.bool(true, "Show Untested Day High/Low", group=grpH)
int    dhlMaxDays   = input.int(0, "Project Forward (trading days)", minval=0, maxval=250, group=grpH, tooltip="Number of trading days an untested day high/low is carried forward. Set to 0 to keep it until it is tested.")
int    dhlMaxLevels = input.int(200, "Max Levels On Chart", minval=2, maxval=490, group=grpH, tooltip="Safety cap. When exceeded, the oldest untested levels are dropped so the chart stays within TradingView's drawing limits.")
bool   dhlShowLabel = input.bool(true, "Show Labels", group=grpH)
bool   dhlExtendBack = input.bool(true, "Draw Across Origin Day", group=grpH, tooltip="Start each line at the open of the day it came from, so the session that formed the level shows its own range.")
color  dhlHighColor = input.color(#26A69A, "High", group=grpH, inline="dh")
color  dhlLowColor  = input.color(#EF5350, "Low", group=grpH, inline="dh")
int    dhlWidth     = input.int(1, "Width", minval=1, maxval=4, group=grpH, inline="dh")
string dhlStyleIn   = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grpH)

//Pivot Range Calculations - Mark Fisher
float pivot = (high + low + close) / 3.0
float bc = (high + low) / 2.0
float tc = (pivot - bc) + pivot

//Today's CPR (from previous day's HLC)
float dtime_pivot = request.security(syminfo.tickerid, "D", pivot[1], lookahead=barmerge.lookahead_on)
float dtime_bc = request.security(syminfo.tickerid, "D", bc[1], lookahead=barmerge.lookahead_on)
float dtime_tc = request.security(syminfo.tickerid, "D", tc[1], lookahead=barmerge.lookahead_on)

//Tomorrow's CPR (from current day's final HLC via daily bar)
float next_pivot = request.security(syminfo.tickerid, "D", pivot, lookahead=barmerge.lookahead_on)
float next_bc = request.security(syminfo.tickerid, "D", bc, lookahead=barmerge.lookahead_on)
float next_tc = request.security(syminfo.tickerid, "D", tc, lookahead=barmerge.lookahead_on)

//Show tomorrow's CPR on the last bar of the session
float plot_pivot = session.islastbar_regular ? next_pivot : dtime_pivot
float plot_bc = session.islastbar_regular ? next_bc : dtime_bc
float plot_tc = session.islastbar_regular ? next_tc : dtime_tc

plot(showDaily ? plot_pivot : na, title="Daily Pivot", style=plot.style_circles, color=#FF00FF, linewidth=2)
plot(showDaily ? plot_bc : na, title="Daily BC", style=plot.style_circles, color=#0000FF, linewidth=2)
plot(showDaily ? plot_tc : na, title="Daily TC", style=plot.style_circles, color=#0000FF, linewidth=2)

// ══════════════════════════════════════════════════════════════════════════════
// CLASSIC PIVOTS
// Adapted from ChrisMoody's "CM_Pivot Points M-W-D-4H-1H Filtered" (2014),
// itself built with TheLark. Ported to Pine v6: every timeframe is fetched in a
// single tuple request to stay inside the 40 request.*() call limit, and the
// original's 4-Hour S3 toggle bug (gated on the weekly flag) is corrected.
// ══════════════════════════════════════════════════════════════════════════════

float cpPiv = (high + low + close) / 3.0

// Directional filter from the original script
bool cpBull = cpPiv > (cpPiv + cpPiv[1]) / 2 + 0.0025
bool cpBear = cpPiv < (cpPiv + cpPiv[1]) / 2 - 0.0025

float cpR1v = cpFiltered and cpBear ? cpPiv + (cpPiv - low) : cpFiltered and cpBull ? cpPiv + (high - low) : cpPiv + (cpPiv - low)
float cpS1v = cpFiltered and cpBull ? cpPiv - (high - cpPiv) : cpFiltered and cpBear ? cpPiv - (high - low) : cpPiv - (high - cpPiv)
float cpR2v = cpFiltered ? na : cpPiv + (high - low)
float cpS2v = cpFiltered ? na : cpPiv - (high - low)
float cpR3v = cpShowR3 ? cpR1v + (high - low) : na
float cpS3v = cpShowR3 ? cpS1v - (high - low) : na
float cpAvgv = ta.sma(cpPiv, 3)

f_pivotSet(simple string tf) =>
    request.security(syminfo.tickerid, tf, [cpPiv[1], cpAvgv[1], cpR1v[1], cpS1v[1], cpR2v[1], cpS2v[1], cpR3v[1], cpS3v[1]], lookahead=barmerge.lookahead_on)

// R3/S3 exist only on the intraday timeframes, matching the original script
f_pivotSetHTF(simple string tf) =>
    request.security(syminfo.tickerid, tf, [cpPiv[1], cpAvgv[1], cpR1v[1], cpS1v[1], cpR2v[1], cpS2v[1]], lookahead=barmerge.lookahead_on)

[h1P, h1A, h1R1, h1S1, h1R2, h1S2, h1R3, h1S3] = f_pivotSet("60")
[h4P, h4A, h4R1, h4S1, h4R2, h4S2, h4R3, h4S3] = f_pivotSet("240")
[dP, dA, dR1, dS1, dR2, dS2] = f_pivotSetHTF("D")
[wP, wA, wR1, wS1, wR2, wS2] = f_pivotSetHTF("W")
[mP, mA, mR1, mS1, mR2, mS2] = f_pivotSetHTF("M")
[yP, yA, yR1, yS1, yR2, yS2] = f_pivotSetHTF("12M")

// 1 Hour
plot(cpAvg and cpH1 ? h1A : na,  title="Hourly Pivot Average", style=plot.style_cross,   color=color.orange,  linewidth=2)
plot(cpH1 ? h1P  : na,           title="Hourly Pivot",         style=plot.style_circles, color=color.fuchsia, linewidth=2)
plot(cpH1 ? h1R1 : na,           title="Hourly R1",            style=plot.style_circles, color=#DC143C,       linewidth=2)
plot(cpH1 ? h1S1 : na,           title="Hourly S1",            style=plot.style_circles, color=color.lime,    linewidth=2)
plot(cpH1 ? h1R2 : na,           title="Hourly R2",            style=plot.style_circles, color=color.maroon,  linewidth=2)
plot(cpH1 ? h1S2 : na,           title="Hourly S2",            style=plot.style_circles, color=#228B22,       linewidth=2)
plot(cpH1 ? h1R3 : na,           title="Hourly R3",            style=plot.style_circles, color=#FA8072,       linewidth=2)
plot(cpH1 ? h1S3 : na,           title="Hourly S3",            style=plot.style_circles, color=#CD5C5C,       linewidth=2)

// 4 Hour
plot(cpAvg and cpH4 ? h4A : na,  title="4 Hour Pivot Average", style=plot.style_cross,   color=color.orange,  linewidth=2)
plot(cpH4 ? h4P  : na,           title="4 Hour Pivot",         style=plot.style_circles, color=color.fuchsia, linewidth=3)
plot(cpH4 ? h4R1 : na,           title="4 Hour R1",            style=plot.style_circles, color=#DC143C,       linewidth=3)
plot(cpH4 ? h4S1 : na,           title="4 Hour S1",            style=plot.style_circles, color=color.lime,    linewidth=3)
plot(cpH4 ? h4R2 : na,           title="4 Hour R2",            style=plot.style_circles, color=color.maroon,  linewidth=3)
plot(cpH4 ? h4S2 : na,           title="4 Hour S2",            style=plot.style_circles, color=#228B22,       linewidth=3)
plot(cpH4 ? h4R3 : na,           title="4 Hour R3",            style=plot.style_circles, color=#FA8072,       linewidth=3)
plot(cpH4 ? h4S3 : na,           title="4 Hour S3",            style=plot.style_circles, color=#CD5C5C,       linewidth=3)

// Daily
plot(cpAvg and cpD ? dA : na,    title="Daily Pivot Average",  style=plot.style_cross,   color=color.orange,  linewidth=2)
plot(cpD ? dP  : na,             title="Daily Pivot",          style=plot.style_circles, color=#FF00FF,       linewidth=2)
plot(cpD ? dR1 : na,             title="Daily R1",             style=plot.style_circles, color=#EF5350,       linewidth=1)
plot(cpD ? dS1 : na,             title="Daily S1",             style=plot.style_circles, color=#EF5350,       linewidth=1)
plot(cpD ? dR2 : na,             title="Daily R2",             style=plot.style_circles, color=#EF5350,       linewidth=1)
plot(cpD ? dS2 : na,             title="Daily S2",             style=plot.style_circles, color=#EF5350,       linewidth=1)

// Weekly
plot(cpAvg and cpW ? wA : na,    title="Weekly Pivot Average", style=plot.style_cross,   color=color.orange,  linewidth=3)
plot(cpW ? wP  : na,             title="Weekly Pivot",         style=plot.style_circles, color=#388E3C,       linewidth=2)
plot(cpW ? wR1 : na,             title="Weekly R1",            style=plot.style_circles, color=#81C784,       linewidth=1)
plot(cpW ? wS1 : na,             title="Weekly S1",            style=plot.style_circles, color=#81C784,       linewidth=1)
plot(cpW ? wR2 : na,             title="Weekly R2",            style=plot.style_circles, color=#81C784,       linewidth=1)
plot(cpW ? wS2 : na,             title="Weekly S2",            style=plot.style_circles, color=#81C784,       linewidth=1)

// Monthly
plot(cpAvg and cpM ? mA : na,    title="Monthly Pivot Average", style=plot.style_cross,   color=color.orange, linewidth=4)
plot(cpM ? mP  : na,             title="Monthly Pivot",         style=plot.style_circles, color=#1976D2,      linewidth=2)
plot(cpM ? mR1 : na,             title="Monthly R1",            style=plot.style_circles, color=#64B5F6,      linewidth=1)
plot(cpM ? mS1 : na,             title="Monthly S1",            style=plot.style_circles, color=#64B5F6,      linewidth=1)
plot(cpM ? mR2 : na,             title="Monthly R2",            style=plot.style_circles, color=#64B5F6,      linewidth=1)
plot(cpM ? mS2 : na,             title="Monthly S2",            style=plot.style_circles, color=#64B5F6,      linewidth=1)

// Yearly
plot(cpAvg and cpY ? yA : na,    title="Yearly Pivot Average", style=plot.style_cross, color=color.orange,  linewidth=4)
plot(cpY ? yP  : na,             title="Yearly Pivot",         style=plot.style_cross, color=color.fuchsia, linewidth=6)
plot(cpY ? yR1 : na,             title="Yearly R1",            style=plot.style_cross, color=#DC143C,       linewidth=6)
plot(cpY ? yS1 : na,             title="Yearly S1",            style=plot.style_cross, color=color.lime,    linewidth=6)
plot(cpY ? yR2 : na,             title="Yearly R2",            style=plot.style_cross, color=color.maroon,  linewidth=6)
plot(cpY ? yS2 : na,             title="Yearly S2",            style=plot.style_cross, color=#228B22,       linewidth=6)

// ══════════════════════════════════════════════════════════════════════════════
// VIRGIN CPR
// A day's CPR is "virgin" if no pierce-timeframe candle body entered the BC-TC
// band during that same day. Virgin bands are projected forward as rectangles
// for N trading days, or until any wick touches them (kept for the rest of the
// testing day, dropped from the next day onward).
// ══════════════════════════════════════════════════════════════════════════════

type Vcpr
    box   bx
    label lb
    float top
    float bot
    int   age
    bool  tested

var array<Vcpr> vcprs        = array.new<Vcpr>()
var bool        piercedToday = false

// A candle pierces only if it CLOSES inside the band. Wicks are ignored, and so
// is a bar that merely opens beyond an edge before reversing away from it --
// that is the level being defended, not broken.
f_closeHits(float c, float lo, float hi) =>
    c >= lo and c <= hi

f_dropVcpr(Vcpr v) =>
    box.delete(v.bx)
    label.delete(v.lb)

// Band of the CPR currently in force (constant through the day)
float bandHi = math.max(dtime_bc, dtime_tc)
float bandLo = math.min(dtime_bc, dtime_tc)

// Pierce-timeframe candles. Charts coarser than the pierce timeframe read the
// intrabars; charts at or finer than it read the aggregated bar as it closes.
bool   useLtf  = timeframe.in_seconds(vcprTF) < timeframe.in_seconds(timeframe.period)
string ltfSafe = useLtf ? vcprTF : timeframe.period
array<float> ltfC = request.security_lower_tf(syminfo.tickerid, ltfSafe, close)
float        htfC = request.security(syminfo.tickerid, vcprTF, close, gaps=barmerge.gaps_on)

bool isNewDay = timeframe.change("D")

// Native day high/low tracking. request.security("D", high[1]) can lag a day at
// the session boundary, so the day range is accumulated directly from chart bars
// and snapshotted the moment the day rolls over. Must run on every bar.
var float curDayHigh = na
var float curDayLow  = na
var int   curDayTime = na
var int   curDayIdx  = na
float pdHigh = na
float pdLow  = na
int   pdTime = na
int   pdIdx  = na

if isNewDay
    pdHigh     := curDayHigh
    pdLow      := curDayLow
    pdTime     := curDayTime
    pdIdx      := curDayIdx
    curDayHigh := high
    curDayLow  := low
    curDayTime := time
    curDayIdx  := bar_index
else
    curDayHigh := math.max(nz(curDayHigh, high), high)
    curDayLow  := math.min(nz(curDayLow,  low),  low)
    curDayTime := nz(curDayTime, time)
    curDayIdx  := nz(curDayIdx, bar_index)

if not showVcpr
    if vcprs.size() > 0
        for i = vcprs.size() - 1 to 0
            f_dropVcpr(vcprs.remove(i))
else
    // 1. Roll the book over at the day boundary
    if isNewDay
        if vcprs.size() > 0
            for i = vcprs.size() - 1 to 0
                Vcpr v = vcprs.get(i)
                v.age := v.age + 1
                if v.tested or (vcprMaxDays > 0 and v.age > vcprMaxDays)
                    f_dropVcpr(vcprs.remove(i))

        // 2. Promote yesterday's CPR if it survived the whole day untouched
        float prevTop = bandHi[1]
        float prevBot = bandLo[1]
        if not piercedToday and not na(prevTop) and not na(prevBot)
            box bx = box.new(bar_index, prevTop, bar_index, prevBot, border_color=vcprBorder, border_width=1, bgcolor=vcprFill, extend=vcprExtendRight ? extend.right : extend.none)
            label lb = vcprShowLabel ? label.new(bar_index, math.avg(prevTop, prevBot), "VCPR " + str.format_time(time[1], "dd-MMM", syminfo.timezone), style=label.style_label_left, color=color.new(color.white, 100), textcolor=vcprBorder, size=size.small) : na
            vcprs.push(Vcpr.new(bx, lb, prevTop, prevBot, 1, false))

        piercedToday := false

    // 3. Track piercing of today's CPR
    if not na(bandLo) and not na(bandHi) and not piercedToday
        if useLtf
            if array.size(ltfC) > 0
                for i = 0 to array.size(ltfC) - 1
                    if f_closeHits(ltfC.get(i), bandLo, bandHi)
                        piercedToday := true
        else if not na(htfC)
            if f_closeHits(htfC, bandLo, bandHi)
                piercedToday := true

    // 4. Extend live rectangles and flag wick tests
    if vcprs.size() > 0
        for i = 0 to vcprs.size() - 1
            Vcpr v = vcprs.get(i)
            if not vcprExtendRight
                box.set_right(v.bx, bar_index)
            if not na(v.lb)
                label.set_x(v.lb, bar_index)
            if high >= v.bot and low <= v.top
                v.tested := true

// ══════════════════════════════════════════════════════════════════════════════
// UNTESTED DAY HIGH / LOW
// Every completed day contributes its high and its low as a naked level from the
// next day's open. A level survives until any wick trades through it; it stays on
// the chart for the remainder of the testing day, then drops off the next day.
// ══════════════════════════════════════════════════════════════════════════════

type DayLevel
    line  ln
    label lb
    float price
    int   age
    bool  tested

var array<DayLevel> dhlLevels = array.new<DayLevel>()

f_dropLevel(DayLevel v) =>
    line.delete(v.ln)
    label.delete(v.lb)

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

if not showDhl
    if dhlLevels.size() > 0
        for i = dhlLevels.size() - 1 to 0
            f_dropLevel(dhlLevels.remove(i))
else
    if isNewDay
        // Age the book, retiring levels tested yesterday and any past the day cap
        if dhlLevels.size() > 0
            for i = dhlLevels.size() - 1 to 0
                DayLevel v = dhlLevels.get(i)
                v.age := v.age + 1
                if v.tested or (dhlMaxDays > 0 and v.age > dhlMaxDays)
                    f_dropLevel(dhlLevels.remove(i))

        // Publish yesterday's high and low as fresh naked levels
        if not na(pdHigh) and not na(pdLow)
            string dstr    = str.format_time(pdTime, "dd-MMM", syminfo.timezone)
            string lineSty = f_lineStyle(dhlStyleIn)
            int    x1      = dhlExtendBack and not na(pdIdx) ? pdIdx : bar_index

            line  hLn = line.new(x1, pdHigh, x1 + 1, pdHigh, color=dhlHighColor, width=dhlWidth, style=lineSty, extend=extend.right)
            label hLb = dhlShowLabel ? label.new(bar_index, pdHigh, "DH " + dstr, style=label.style_label_left, color=color.new(color.white, 100), textcolor=dhlHighColor, size=size.small) : na
            dhlLevels.push(DayLevel.new(hLn, hLb, pdHigh, 1, false))

            line  lLn = line.new(x1, pdLow, x1 + 1, pdLow, color=dhlLowColor, width=dhlWidth, style=lineSty, extend=extend.right)
            label lLb = dhlShowLabel ? label.new(bar_index, pdLow, "DL " + dstr, style=label.style_label_left, color=color.new(color.white, 100), textcolor=dhlLowColor, size=size.small) : na
            dhlLevels.push(DayLevel.new(lLn, lLb, pdLow, 1, false))

        while dhlLevels.size() > dhlMaxLevels
            f_dropLevel(dhlLevels.remove(0))

    // Keep labels pinned to the right edge and watch for the first wick test
    if dhlLevels.size() > 0
        for i = 0 to dhlLevels.size() - 1
            DayLevel v = dhlLevels.get(i)
            if not na(v.lb)
                label.set_x(v.lb, bar_index)
            if not v.tested and high >= v.price and low <= v.price
                v.tested := true
````
