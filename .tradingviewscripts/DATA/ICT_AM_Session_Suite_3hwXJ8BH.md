<!-- tradingview-pine-id: PUB;aaea0585531c451fa89d68eb6b027396 -->
<!-- tradingviewscripts-format: 1 -->
# ICT AM Session Suite

Source: https://www.tradingview.com/script/3hwXJ8BH-bmsAMict/

## Description

my am ict model with daily set ups its still a work in progress but i wil keep updating as it goes on

---

## Source Code

````pine
//@version=6
indicator("ICT AM Session Suite", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// =====================================================================================
// INPUTS
// =====================================================================================
grp1 = "Vertical Time Lines (1:30, 2:00, 9:30, 10:00 NY)"
showVertLines = input.bool(true, "Show Vertical Lines", group=grp1)
vlineColor    = input.color(color.gray, "Vertical Line Color", group=grp1)

grp2 = "True Opens"
showTrueOpens = input.bool(true, "Show True Opens", group=grp2)
colDayOpen    = input.color(color.white,  "True Day Open (00:00) Color",    group=grp2)
colAsiaOpen   = input.color(color.yellow, "True Asia Open (19:30) Color",   group=grp2)
colLondonOpen = input.color(color.blue,   "True London Open (01:30) Color",group=grp2)
colNYOpen     = input.color(color.orange, "True NY Open (07:30) Color",     group=grp2)

grp3 = "Macro Windows"
showMacros  = input.bool(true, "Show Macro Boxes (9:45-10:15 / 10:45-11:15)", group=grp3)
macroColor  = input.color(color.new(color.purple, 85), "Macro Box Color", group=grp3)
macroBorder = input.color(color.purple, "Macro Border Color", group=grp3)

grp4 = "Swing Highs / Lows (Liquidity)"
swingLookback = input.int(3, "Swing Pivot Lookback (bars each side)", minval=1, group=grp4)
swingColor    = input.color(color.red, "Swing Line Color", group=grp4)
sweptColor    = input.color(color.gray, "Swept Level Color", group=grp4)

grp4b = "Choose Which Previous Swings to Show (applies to both highs & lows)"
show1  = input.bool(true,  "Show 1st Previous", group=grp4b)
show2  = input.bool(false, "Show 2nd Previous", group=grp4b)
show3  = input.bool(false, "Show 3rd Previous", group=grp4b)
show4  = input.bool(false, "Show 4th Previous", group=grp4b)
show5  = input.bool(false, "Show 5th Previous", group=grp4b)
show6  = input.bool(false, "Show 6th Previous", group=grp4b)
show7  = input.bool(false, "Show 7th Previous", group=grp4b)
show8  = input.bool(false, "Show 8th Previous", group=grp4b)
show9  = input.bool(false, "Show 9th Previous", group=grp4b)
show10 = input.bool(false, "Show 10th Previous", group=grp4b)
showSwingArr = array.from(show1, show2, show3, show4, show5, show6, show7, show8, show9, show10)
MAXTRACK = 10

grp5 = "Liquidity Sweep + First FVG (per session)"
showFVG      = input.bool(true, "Show First FVG After Sweep (1:30am & 9:30am sessions)", group=grp5)
fvgBullColor = input.color(color.new(color.green, 70), "Bullish FVG Color", group=grp5)
fvgBearColor = input.color(color.new(color.red, 70),   "Bearish FVG Color", group=grp5)
fvgExtendBars= input.int(15, "Extend FVG Box Right (bars)", minval=0, group=grp5)

grp6 = "Equal Highs / Lows (Body-Based)"
showEQ      = input.bool(true, "Show Equal Highs/Lows", group=grp6)
eqTolerance = input.float(2, "Equal H/L Tolerance (ticks)", minval=0, group=grp6)
eqColor     = input.color(color.aqua, "Equal H/L Color", group=grp6)

// =====================================================================================
// NY TIME (auto DST via America/New_York)
// =====================================================================================
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
nyDay    = dayofmonth(time, "America/New_York")
nyMonth  = month(time, "America/New_York")
nyYear   = year(time, "America/New_York")

newDay = ta.change(nyDay) != 0

f_todayTime(h, m) =>
    timestamp("America/New_York", nyYear, nyMonth, nyDay, h, m, 0)

// =====================================================================================
// VERTICAL LINES — pre-drawn at the start of each NY day so they're visible in advance
// =====================================================================================
if showVertLines and newDay
    t130  = f_todayTime(1, 30)
    t200  = f_todayTime(2, 0)
    t930  = f_todayTime(9, 30)
    t1000 = f_todayTime(10, 0)
    line.new(t130,  low, t130,  high, xloc=xloc.bar_time, extend=extend.both, color=vlineColor, style=line.style_dashed)
    line.new(t200,  low, t200,  high, xloc=xloc.bar_time, extend=extend.both, color=vlineColor, style=line.style_dashed)
    line.new(t930,  low, t930,  high, xloc=xloc.bar_time, extend=extend.both, color=vlineColor, style=line.style_dashed)
    line.new(t1000, low, t1000, high, xloc=xloc.bar_time, extend=extend.both, color=vlineColor, style=line.style_dashed)

// =====================================================================================
// TRUE OPENS — captured live at the exact NY time, drawn forward from that point
// =====================================================================================
var line dayOpenLine    = na
var line asiaOpenLine   = na
var line londonOpenLine = na
var line nyOpenLine     = na

// Crossing-based trigger — fires on the first bar that reaches/passes the target time,
// so it works correctly on ANY timeframe (1m, 5m, 8m, 15m, etc.), not just exact-minute matches.
f_crossedTime(h, m) =>
    target = f_todayTime(h, m)
    time >= target and time[1] < target

dayOpenTrig    = f_crossedTime(0, 0)
asiaOpenTrig   = f_crossedTime(19, 30)
londonOpenTrig = f_crossedTime(1, 30)
nyOpenTrig     = f_crossedTime(7, 30)
session2Start  = f_crossedTime(9, 30)

if showTrueOpens and dayOpenTrig
    if not na(dayOpenLine)
        line.delete(dayOpenLine)
    dayOpenLine := line.new(bar_index - 1, open, bar_index, open, xloc=xloc.bar_index, extend=extend.right, color=colDayOpen, width=2)

if showTrueOpens and asiaOpenTrig
    if not na(asiaOpenLine)
        line.delete(asiaOpenLine)
    asiaOpenLine := line.new(bar_index - 1, open, bar_index, open, xloc=xloc.bar_index, extend=extend.right, color=colAsiaOpen, width=2)

if showTrueOpens and londonOpenTrig
    if not na(londonOpenLine)
        line.delete(londonOpenLine)
    londonOpenLine := line.new(bar_index - 1, open, bar_index, open, xloc=xloc.bar_index, extend=extend.right, color=colLondonOpen, width=2)

if showTrueOpens and nyOpenTrig
    if not na(nyOpenLine)
        line.delete(nyOpenLine)
    nyOpenLine := line.new(bar_index - 1, open, bar_index, open, xloc=xloc.bar_index, extend=extend.right, color=colNYOpen, width=2)

// =====================================================================================
// MACRO WINDOWS — 9:45-10:15 and 10:45-11:15, box tracks the range traded during window
// =====================================================================================
inMacro1 = (nyHour == 9  and nyMinute >= 45) or (nyHour == 10 and nyMinute <= 15)
inMacro2 = (nyHour == 10 and nyMinute >= 45) or (nyHour == 11 and nyMinute <= 15)

var box   m1Box = na
var float m1Top = na
var float m1Bot = na
m1Start = inMacro1 and not inMacro1[1]
if showMacros and m1Start
    m1Top := high
    m1Bot := low
    m1Box := box.new(time, m1Top, time, m1Bot, xloc=xloc.bar_time, bgcolor=macroColor, border_color=macroBorder)
if showMacros and inMacro1 and not na(m1Box)
    m1Top := math.max(m1Top, high)
    m1Bot := math.min(m1Bot, low)
    box.set_top(m1Box, m1Top)
    box.set_bottom(m1Box, m1Bot)
    box.set_right(m1Box, time)

var box   m2Box = na
var float m2Top = na
var float m2Bot = na
m2Start = inMacro2 and not inMacro2[1]
if showMacros and m2Start
    m2Top := high
    m2Bot := low
    m2Box := box.new(time, m2Top, time, m2Bot, xloc=xloc.bar_time, bgcolor=macroColor, border_color=macroBorder)
if showMacros and inMacro2 and not na(m2Box)
    m2Top := math.max(m2Top, high)
    m2Bot := math.min(m2Bot, low)
    box.set_top(m2Box, m2Top)
    box.set_bottom(m2Box, m2Bot)
    box.set_right(m2Box, time)

// =====================================================================================
// SWING HIGHS / LOWS — pivot-based; choose exactly which Nth-previous swings to display
// =====================================================================================
ph = ta.pivothigh(high, swingLookback, swingLookback)
pl = ta.pivotlow(low, swingLookback, swingLookback)

var array<float> swHighPrices  = array.new_float(0)
var array<int>   swHighBars    = array.new_int(0)
var array<bool>  swHighSwept   = array.new_bool(0)
var array<line>  swHighLineObj = array.new_line(0)   // na entry = currently not displayed

var array<float> swLowPrices  = array.new_float(0)
var array<int>   swLowBars    = array.new_int(0)
var array<bool>  swLowSwept   = array.new_bool(0)
var array<line>  swLowLineObj = array.new_line(0)

// recompute which stored pivots should currently be visible, based on the checkboxes.
// Nth-most-recent = 1 for the newest pivot, 2 for the one before that, etc.
f_recomputeDisplay(pricesArr, barsArr, sweptArr, lineArr) =>
    n = array.size(pricesArr)
    for idx = 0 to n - 1
        nth = n - idx
        wantShow = nth <= MAXTRACK and array.get(showSwingArr, nth - 1)
        existingLine = array.get(lineArr, idx)
        if wantShow and na(existingLine)
            pBar = array.get(barsArr, idx)
            pPrice = array.get(pricesArr, idx)
            swept = array.get(sweptArr, idx)
            newLn = line.new(pBar, pPrice, bar_index, pPrice, xloc=xloc.bar_index, color=swept ? sweptColor : swingColor, extend=swept ? extend.none : extend.right, width=1)
            array.set(lineArr, idx, newLn)
        if not wantShow and not na(existingLine)
            line.delete(existingLine)
            array.set(lineArr, idx, na)

if not na(ph)
    pivotBar = bar_index - swingLookback
    array.push(swHighPrices, ph)
    array.push(swHighBars, pivotBar)
    array.push(swHighSwept, false)
    array.push(swHighLineObj, na)
    if array.size(swHighPrices) > MAXTRACK
        removedLine = array.shift(swHighLineObj)
        if not na(removedLine)
            line.delete(removedLine)
        array.shift(swHighPrices)
        array.shift(swHighBars)
        array.shift(swHighSwept)
    f_recomputeDisplay(swHighPrices, swHighBars, swHighSwept, swHighLineObj)

if not na(pl)
    pivotBar = bar_index - swingLookback
    array.push(swLowPrices, pl)
    array.push(swLowBars, pivotBar)
    array.push(swLowSwept, false)
    array.push(swLowLineObj, na)
    if array.size(swLowPrices) > MAXTRACK
        removedLine = array.shift(swLowLineObj)
        if not na(removedLine)
            line.delete(removedLine)
        array.shift(swLowPrices)
        array.shift(swLowBars)
        array.shift(swLowSwept)
    f_recomputeDisplay(swLowPrices, swLowBars, swLowSwept, swLowLineObj)

// mark swept levels (wick pierces then closes back inside) — freeze + recolor the line if visible
if array.size(swHighPrices) > 0
    for i = array.size(swHighPrices) - 1 to 0
        already = array.get(swHighSwept, i)
        lvl = array.get(swHighPrices, i)
        if not already and high > lvl and close < lvl
            array.set(swHighSwept, i, true)
            ln = array.get(swHighLineObj, i)
            if not na(ln)
                line.set_extend(ln, extend.none)
                line.set_x2(ln, bar_index)
                line.set_color(ln, sweptColor)

if array.size(swLowPrices) > 0
    for i = array.size(swLowPrices) - 1 to 0
        already = array.get(swLowSwept, i)
        lvl = array.get(swLowPrices, i)
        if not already and low < lvl and close > lvl
            array.set(swLowSwept, i, true)
            ln = array.get(swLowLineObj, i)
            if not na(ln)
                line.set_extend(ln, extend.none)
                line.set_x2(ln, bar_index)
                line.set_color(ln, sweptColor)

// =====================================================================================
// LIQUIDITY SWEEP + FIRST FVG — tracked separately for the 1:30am and 9:30am sessions
// =====================================================================================
var bool session1Active    = false
var bool session1SweepDone = false
var bool session1FVGDone   = false

var bool session2Active    = false
var bool session2SweepDone = false
var bool session2FVGDone   = false

if londonOpenTrig
    session1Active    := true
    session1SweepDone := false
    session1FVGDone   := false

if session2Start
    session2Active    := true
    session2SweepDone := false
    session2FVGDone   := false

f_sweepHigh() =>
    result = false
    if array.size(swHighPrices) > 0
        for i = array.size(swHighPrices) - 1 to 0
            lvl = array.get(swHighPrices, i)
            if high > lvl and close < lvl
                result := true
                break
    result

f_sweepLow() =>
    result = false
    if array.size(swLowPrices) > 0
        for i = array.size(swLowPrices) - 1 to 0
            lvl = array.get(swLowPrices, i)
            if low < lvl and close > lvl
                result := true
                break
    result

bullFVG = low > high[2]
bearFVG = high < low[2]

// Session 1 (after 1:30am)
if showFVG and session1Active and not session1SweepDone
    if f_sweepHigh() or f_sweepLow()
        session1SweepDone := true

if showFVG and session1Active and session1SweepDone and not session1FVGDone
    if bullFVG or bearFVG
        topV = bullFVG ? low : low[2]
        botV = bullFVG ? high[2] : high
        col  = bullFVG ? fvgBullColor : fvgBearColor
        box.new(bar_index[2], topV, bar_index + fvgExtendBars, botV, bgcolor=col, border_color=color.new(col, 0), xloc=xloc.bar_index)
        session1FVGDone := true

// Session 2 (after 9:30am)
if showFVG and session2Active and not session2SweepDone
    if f_sweepHigh() or f_sweepLow()
        session2SweepDone := true

if showFVG and session2Active and session2SweepDone and not session2FVGDone
    if bullFVG or bearFVG
        topV = bullFVG ? low : low[2]
        botV = bullFVG ? high[2] : high
        col  = bullFVG ? fvgBullColor : fvgBearColor
        box.new(bar_index[2], topV, bar_index + fvgExtendBars, botV, bgcolor=col, border_color=color.new(col, 0), xloc=xloc.bar_index)
        session2FVGDone := true

// =====================================================================================
// EQUAL HIGHS / LOWS — body-based (open/close), configurable tick tolerance, marked only
// =====================================================================================
bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

pbh = ta.pivothigh(bodyHigh, swingLookback, swingLookback)
pbl = ta.pivotlow(bodyLow, swingLookback, swingLookback)

tol = eqTolerance * syminfo.mintick

var array<float> eqHighPrices = array.new_float(0)
var array<int>   eqHighBars   = array.new_int(0)
var array<float> eqLowPrices  = array.new_float(0)
var array<int>   eqLowBars    = array.new_int(0)

if showEQ and not na(pbh)
    newBar = bar_index - swingLookback
    if array.size(eqHighPrices) > 0
        for i = array.size(eqHighPrices) - 1 to 0
            prevPrice = array.get(eqHighPrices, i)
            if math.abs(pbh - prevPrice) <= tol
                prevBar = array.get(eqHighBars, i)
                line.new(prevBar, prevPrice, newBar, pbh, xloc=xloc.bar_index, color=eqColor, width=2, style=line.style_dashed)
                label.new(newBar, pbh, "EQH", style=label.style_label_down, color=color.new(eqColor, 100), textcolor=eqColor, size=size.small)
                break
    array.push(eqHighPrices, pbh)
    array.push(eqHighBars, newBar)
    if array.size(eqHighPrices) > 5
        array.shift(eqHighPrices)
        array.shift(eqHighBars)

if showEQ and not na(pbl)
    newBar = bar_index - swingLookback
    if array.size(eqLowPrices) > 0
        for i = array.size(eqLowPrices) - 1 to 0
            prevPrice = array.get(eqLowPrices, i)
            if math.abs(pbl - prevPrice) <= tol
                prevBar = array.get(eqLowBars, i)
                line.new(prevBar, prevPrice, newBar, pbl, xloc=xloc.bar_index, color=eqColor, width=2, style=line.style_dashed)
                label.new(newBar, pbl, "EQL", style=label.style_label_up, color=color.new(eqColor, 100), textcolor=eqColor, size=size.small)
                break
    array.push(eqLowPrices, pbl)
    array.push(eqLowBars, newBar)
    if array.size(eqLowPrices) > 5
        array.shift(eqLowPrices)
        array.shift(eqLowBars)
````
