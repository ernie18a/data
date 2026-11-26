# JSS - SMC / ICT Time-Fibs & Liquidity

- url: https://www.tradingview.com/script/4CqUAYUD-JSS-SMC-ICT-Time-Fibs-Liquidity/
- type: indicator
- pine_id: PUB;f46f4149c2a244b0a099ce39f3bc7774
- version: 3.0

## Description

An [i]all-in-one[/i] institutional toolkit designed to trade the New York Session using Time-Based Standard Deviations, Smart Money Concepts (SMC), and algorithmic liquidity targets.
Instead of drawing random Fibonacci retracements, this indicator traps the opening volatility of the market and mathematically projects exactly where the algorithms will exhaust.


[i][b]Core Features[/b][/i]:
[b]The Time-Box Fibs[/b]: Automatically maps the Overnight Macro Range (22:00–11:00) and the New York Open Micro Range (15:00–16:00).

[b]Institutional Liquidity Lines[/b]: Automatically draws your essential daily, weekly, and monthly HTF midpoints (PDH, PDL, PD50, PW50, PM50, and True Daily Open).
[b]Dynamic FVG & IFVG Scanner[/b]: Highlights Fair Value Gaps with dashed equilibrium lines. When an FVG is closed through, it transforms into an Inverted FVG. To keep your chart perfectly clean, the engine tracks all gaps in the background but only highlights the exact IFVG closest to live price.

## Source Code

````pine
//@version=6
indicator("JSS - SMC / ICT Time-Fibs & Liquidity", shorttitle="JSS Time-Fibs", overlay = true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)
// ==============================================================================
// 0. DISCONTINUED
// ==============================================================================
// ==============================================================================
// 1. SETTINGS & UI INPUTS
// ==============================================================================
GRP_FIBS = "=== FIB LEVELS ==="
showMacro   = input.bool(true,  title="Show Fibs 1",   inline="fib1", group=GRP_FIBS) 
showHistory = input.bool(false, title="Show History",  inline="fib1", group=GRP_FIBS)
autoFlipMac = input.bool(true,  title="Auto-Flip",     inline="fib1", group=GRP_FIBS) 
invertMacro = input.bool(false, title="Manual Rev",    inline="fib1", group=GRP_FIBS) 

showMicro   = input.bool(true,  title="Show Fibs 2",   inline="fib2", group=GRP_FIBS)
autoFlipMic = input.bool(true,  title="Auto-Flip",     inline="fib2", group=GRP_FIBS) 
invertMicro = input.bool(false, title="Manual Rev",    inline="fib2", group=GRP_FIBS)

GRP_LIQ = "=== LIQUIDITY LINES ==="
showPDH  = input.bool(true, title="Show PDH",  inline="liq1", group=GRP_LIQ) 
showPDL  = input.bool(true, title="Show PDL",  inline="liq1", group=GRP_LIQ) 
showPD50 = input.bool(true, title="Show PD50", inline="liq1", group=GRP_LIQ) 

showPW50 = input.bool(true, title="Show PW50", inline="liq2", group=GRP_LIQ) 
showPM50 = input.bool(true, title="Show PM50", inline="liq2", group=GRP_LIQ) 

showTDO  = input.bool(true, title="Show TDO",  inline="liq3", group=GRP_LIQ) 
showP50  = input.bool(true, title="Show P50%", inline="liq3", group=GRP_LIQ) 

GRP_FVG = "=== FVG & IFVG SETTINGS ==="
showFVG   = input.bool(false, title="Show FVGs", inline="fvg1", group=GRP_FVG) 
showIFVG  = input.bool(false, title="Show Closest IFVG", inline="fvg1", group=GRP_FVG) 
minGapPct = input.float(30,  title="Min Gap Size (% of ATR)", group=GRP_FVG)
maxGapPct = input.float(200, title="Max Gap Size (% of ATR)", group=GRP_FVG)
hideAtrMult = input.float(10, title="Hide FVGs beyond (ATR Multiplier)", group=GRP_FVG)

// ==============================================================================
// 2. TIMEZONE & SESSION SETTINGS
// ==============================================================================
tz = "Europe/Amsterdam"
isMacroSession  = not na(time(timeframe.period, "0000-1100", tz))
isMicroSession  = not na(time(timeframe.period, "1500-1600", tz))

// Sessions for Algorithmic Bias (Asia vs London)
isAsiaSession   = not na(time(timeframe.period, "0200-0600", tz))
isLondonSession = not na(time(timeframe.period, "0800-1100", tz))

// ==============================================================================
// 3. GLOBAL VARIABLES & ARRAYS
// ==============================================================================
var float macroHigh = na, var float macroLow = na
var float lockedMacroHigh = na, var float lockedMacroLow = na, var int macroStartBar = na 
var float microHigh = na, var float microLow = na
var float lockedMicroHigh = na, var float lockedMicroLow = na, var int microStartBar = na 

color neonBlue = color.rgb(0, 255, 255)
var line[] macroLines = array.new_line()
var label[] macroLabels = array.new_label()
var line[] microLines = array.new_line()
var label[] microLabels = array.new_label()

var float curDayHigh = na,   var float curDayLow = na
var float curWeekHigh = na,  var float curWeekLow = na
var float curMonthHigh = na, var float curMonthLow = na

var float pdh = na, var float pdl = na, var float pd50 = na 
var float pw50 = na, var float pm50 = na, var float tdo = na

var int dayStartBar = na, var int weekStartBar = na, var int monthStartBar = na, var int tdoStartBar = na

lineStyle = line.style_dotted
lineColor = color.gray
textColor = color.gray

var line pdhLine = line.new(na, na, na, na, color=lineColor, style=lineStyle, width=1)
var label pdhLbl = label.new(na, na, "", textcolor=textColor, style=label.style_label_left, size=size.small, color=color.new(color.white, 100))
var line pdlLine = line.new(na, na, na, na, color=lineColor, style=lineStyle, width=1)
var label pdlLbl = label.new(na, na, "", textcolor=textColor, style=label.style_label_left, size=size.small, color=color.new(color.white, 100))
var line pd50Line = line.new(na, na, na, na, color=lineColor, style=lineStyle, width=1)
var label pd50Lbl = label.new(na, na, "", textcolor=textColor, style=label.style_label_left, size=size.small, color=color.new(color.white, 100))
var line pw50Line = line.new(na, na, na, na, color=lineColor, style=lineStyle, width=1)
var label pw50Lbl = label.new(na, na, "", textcolor=textColor, style=label.style_label_left, size=size.small, color=color.new(color.white, 100))
var line pm50Line = line.new(na, na, na, na, color=lineColor, style=lineStyle, width=1)
var label pm50Lbl = label.new(na, na, "", textcolor=textColor, style=label.style_label_left, size=size.small, color=color.new(color.white, 100))
var line tdoLine = line.new(na, na, na, na, color=lineColor, style=lineStyle, width=1)
var label tdoLbl = label.new(na, na, "", textcolor=textColor, style=label.style_label_left, size=size.small, color=color.new(color.white, 100))
var line p50Line = line.new(na, na, na, na, color=lineColor, style=lineStyle, width=1)
var label p50Lbl = label.new(na, na, "", textcolor=textColor, style=label.style_label_left, size=size.small, color=color.new(color.white, 100))

// ==============================================================================
// 4. FIBONACCI DRAWING ENGINE
// ==============================================================================
drawFib(price, c, txt, startBarIndex, lineArr, lblArr) =>
    fullTxt = txt + " (" + str.tostring(price, format.mintick) + ")"
    l = line.new(x1 = startBarIndex, y1 = price, x2 = bar_index, y2 = price, color = c, style = line.style_solid, extend = extend.none)
    lb = label.new(x = bar_index, y = price, text = fullTxt, color = color.new(color.white, 100), textcolor = c, style = label.style_label_left, size = size.small)
    array.push(lineArr, l)
    array.push(lblArr, lb)

calcAndDrawFibs(lLow, lHigh, startBar, lineArr, lblArr, baseColor, isInverted) =>
    rangeSize = lHigh - lLow
    p1     = isInverted ? lHigh - (rangeSize * 1.0)    : lLow + (rangeSize * 1.0)
    p0786  = isInverted ? lHigh - (rangeSize * 0.786)  : lLow + (rangeSize * 0.786)
    p0236  = isInverted ? lHigh - (rangeSize * 0.236)  : lLow + (rangeSize * 0.236)
    p0     = isInverted ? lHigh - (rangeSize * 0.0)    : lLow + (rangeSize * 0.0)
    pm0236 = isInverted ? lHigh - (rangeSize * -0.236) : lLow + (rangeSize * -0.236)
    pm0786 = isInverted ? lHigh - (rangeSize * -0.786) : lLow + (rangeSize * -0.786)
    pm1    = isInverted ? lHigh - (rangeSize * -1.0)   : lLow + (rangeSize * -1.0)

    drawFib(p1, baseColor, "1", startBar, lineArr, lblArr)
    drawFib(p0786, color.orange, "0.786", startBar, lineArr, lblArr)
    drawFib(p0236, baseColor, "0.236", startBar, lineArr, lblArr)
    drawFib(p0, color.red, "0", startBar, lineArr, lblArr)
    drawFib(pm0236, baseColor, "-0.236", startBar, lineArr, lblArr)
    drawFib(pm0786, color.orange, "-0.786", startBar, lineArr, lblArr)
    drawFib(pm1, baseColor, "-1", startBar, lineArr, lblArr)

// ==============================================================================
// 5. ASIA VS LONDON BIAS TRACKER
// ==============================================================================
var float asiaLow = na
var float londonLow = na
var bool isAsiaLower = false

if isAsiaSession
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

if isLondonSession
    londonLow := na(londonLow) ? low : math.min(londonLow, low)

if not na(asiaLow) and not na(londonLow)
    isAsiaLower := asiaLow < londonLow

// ==============================================================================
// 6. TRACKING LIQUIDITY LEVELS
// ==============================================================================
isNewDayAMS   = ta.change(time("D", tz)) > 0
isNewWeekAMS  = ta.change(time("W", tz)) > 0
isNewMonthAMS = ta.change(time("M", tz)) > 0

// Reset Daily Tracking AND Bias variables
if isNewDayAMS
    pdh := curDayHigh, pdl := curDayLow, pd50 := (pdh + pdl) / 2
    curDayHigh := high, curDayLow := low, dayStartBar := bar_index
    asiaLow := na, londonLow := na, isAsiaLower := false
else
    curDayHigh := math.max(nz(curDayHigh, high), high), curDayLow := math.min(nz(curDayLow, low), low)

if isNewWeekAMS
    pw50 := (curWeekHigh + curWeekLow) / 2
    curWeekHigh := high, curWeekLow := low, weekStartBar := bar_index
else
    curWeekHigh := math.max(nz(curWeekHigh, high), high), curWeekLow := math.min(nz(curWeekLow, low), low)

if isNewMonthAMS
    pm50 := (curMonthHigh + curMonthLow) / 2
    curMonthHigh := high, curMonthLow := low, monthStartBar := bar_index
else
    curMonthHigh := math.max(nz(curMonthHigh, high), high), curMonthLow := math.min(nz(curMonthLow, low), low)

isTDO_Trigger = not na(time(timeframe.period, "0600-1400", tz))
if isTDO_Trigger and not isTDO_Trigger[1]
    tdo := open, tdoStartBar := bar_index

float p50_val = (high[1] + low[1]) / 2

manageLiqLine(show, price, txt, lin, lbl, startBar, rightOffset) =>
    if show and not na(price) and not na(startBar)
        safeStart = math.max(startBar, bar_index - 2000)
        line.set_xy1(lin, safeStart, price), line.set_xy2(lin, bar_index + rightOffset, price)
        label.set_xy(lbl, bar_index + rightOffset, price), label.set_text(lbl, txt + " (" + str.tostring(price, format.mintick) + ")")
    else
        line.set_x1(lin, na), label.set_x(lbl, na)

manageLiqLine(showPDH, pdh, "PDH", pdhLine, pdhLbl, dayStartBar, 3)
manageLiqLine(showPDL, pdl, "PDL", pdlLine, pdlLbl, dayStartBar, 3)
manageLiqLine(showPD50, pd50, "PD50", pd50Line, pd50Lbl, dayStartBar, 3)
manageLiqLine(showPW50, pw50, "PW50", pw50Line, pw50Lbl, weekStartBar, 3)
manageLiqLine(showPM50, pm50, "PM50", pm50Line, pm50Lbl, monthStartBar, 3)
manageLiqLine(showTDO, tdo, "TDO", tdoLine, tdoLbl, tdoStartBar, 3)
manageLiqLine(showP50, p50_val, "P50%", p50Line, p50Lbl, bar_index - 5, 3) 

// ==============================================================================
// 7. MACRO & MICRO MAP ENGINE
// ==============================================================================
if isMacroSession and not isMacroSession[1]
    macroHigh := high, macroLow := low, macroStartBar := bar_index
if isMacroSession
    macroHigh := math.max(macroHigh, high), macroLow := math.min(macroLow, low)
if not isMacroSession and isMacroSession[1]
    lockedMacroHigh := macroHigh, lockedMacroLow := macroLow
    if array.size(macroLines) > 0
        if not showHistory
            for i = 0 to array.size(macroLines) - 1
                line.delete(array.get(macroLines, i)), label.delete(array.get(macroLabels, i))
        array.clear(macroLines), array.clear(macroLabels)
    if showMacro
        // THE FIX: Directly check if Asia is lower! No more confusing negative logic.
        bool finalInvertMacro = autoFlipMac ? isAsiaLower : invertMacro
        calcAndDrawFibs(lockedMacroLow, lockedMacroHigh, macroStartBar, macroLines, macroLabels, color.white, finalInvertMacro)

if isMicroSession and not isMicroSession[1]
    microHigh := high, microLow := low, microStartBar := bar_index
if isMicroSession
    microHigh := math.max(microHigh, high), microLow := math.min(microLow, low)
if not isMicroSession and isMicroSession[1]
    lockedMicroHigh := microHigh, lockedMicroLow := microLow
    if array.size(microLines) > 0
        if not showHistory
            for i = 0 to array.size(microLines) - 1
                line.delete(array.get(microLines, i)), label.delete(array.get(microLabels, i))
        array.clear(microLines), array.clear(microLabels)
    if showMicro
        // THE FIX: Directly check if Asia is lower! No more confusing negative logic.
        bool finalInvertMicro = autoFlipMic ? isAsiaLower : invertMicro
        calcAndDrawFibs(lockedMicroLow, lockedMicroHigh, microStartBar, microLines, microLabels, neonBlue, finalInvertMicro)

if array.size(macroLines) > 0
    for i = 0 to array.size(macroLines) - 1
        line.set_x2(array.get(macroLines, i), bar_index), label.set_x(array.get(macroLabels, i), bar_index)
if array.size(microLines) > 0
    for i = 0 to array.size(microLines) - 1
        line.set_x2(array.get(microLines, i), bar_index), label.set_x(array.get(microLabels, i), bar_index)

// ==============================================================================
// 8. FAIR VALUE GAP (FVG) & IFVG ENGINE
// ==============================================================================
type FVG
    float top
    float bot
    int leftBar
    bool isBull
    box bx
    line midLine

type IFVG
    float top
    float bot
    box bx
    line midLine

var FVG[] activeFVGs = array.new<FVG>()
var IFVG[] activeIFVGs = array.new<IFVG>()

color fvgBgColor = color.new(color.gray, 85)
color fvgBorderColor = color.gray
color ifvgBgColor = color.new(color.orange, 85)
color ifvgBorderColor = color.orange

float atr = ta.atr(14)
float minGap = atr * (minGapPct / 100)
float maxGap = atr * (maxGapPct / 100)
float hideDist = atr * hideAtrMult

float bullGapSize = low[0] - high[2]
float bearGapSize = low[2] - high[0]

bool isBullFVG = bullGapSize >= minGap and bullGapSize <= maxGap and high[2] < low[0]
bool isBearFVG = bearGapSize >= minGap and bearGapSize <= maxGap and low[2] > high[0]

if isBullFVG
    float midPrice = (low[0] + high[2]) / 2
    bx = box.new(bar_index - 1, low[0], bar_index, high[2], border_color=na, border_style=line.style_dotted, bgcolor=na, extend=extend.none)
    ln = line.new(bar_index - 1, midPrice, bar_index, midPrice, color=na, style=line.style_dashed, extend=extend.none)
    array.push(activeFVGs, FVG.new(low[0], high[2], bar_index - 1, true, bx, ln))

if isBearFVG
    float midPrice = (low[2] + high[0]) / 2
    bx = box.new(bar_index - 1, low[2], bar_index, high[0], border_color=na, border_style=line.style_dotted, bgcolor=na, extend=extend.none)
    ln = line.new(bar_index - 1, midPrice, bar_index, midPrice, color=na, style=line.style_dashed, extend=extend.none)
    array.push(activeFVGs, FVG.new(low[2], high[0], bar_index - 1, false, bx, ln))

if array.size(activeFVGs) > 0
    for i = array.size(activeFVGs) - 1 to 0
        FVG f = array.get(activeFVGs, i)
        float dist = math.min(math.abs(close - f.top), math.abs(close - f.bot))
        if dist > hideDist
            box.delete(f.bx), line.delete(f.midLine), array.remove(activeFVGs, i)
            continue
        
        box.set_right(f.bx, bar_index), line.set_x2(f.midLine, bar_index)
        box.set_bgcolor(f.bx, showFVG ? fvgBgColor : na), box.set_border_color(f.bx, showFVG ? fvgBorderColor : na), line.set_color(f.midLine, showFVG ? fvgBorderColor : na)

        bool removeMe = false
        if f.isBull and close < f.bot
            float midP = (f.top + f.bot) / 2
            bx = box.new(f.leftBar, f.top, bar_index, f.bot, border_color=na, border_style=line.style_dotted, bgcolor=na, extend=extend.none)
            ln = line.new(f.leftBar, midP, bar_index, midP, color=na, style=line.style_dashed, extend=extend.none)
            array.push(activeIFVGs, IFVG.new(f.top, f.bot, bx, ln))
            removeMe := true
        else if not f.isBull and close > f.top
            float midP = (f.top + f.bot) / 2
            bx = box.new(f.leftBar, f.top, bar_index, f.bot, border_color=na, border_style=line.style_dotted, bgcolor=na, extend=extend.none)
            ln = line.new(f.leftBar, midP, bar_index, midP, color=na, style=line.style_dashed, extend=extend.none)
            array.push(activeIFVGs, IFVG.new(f.top, f.bot, bx, ln))
            removeMe := true
        if removeMe
            box.delete(f.bx), line.delete(f.midLine), array.remove(activeFVGs, i)

int closestIfvgIndex = -1
float minIfvgDist = 9999999.0

if array.size(activeIFVGs) > 0
    for i = array.size(activeIFVGs) - 1 to 0
        IFVG inv = array.get(activeIFVGs, i)
        float distEdge = math.min(math.abs(close - inv.top), math.abs(close - inv.bot))
        if distEdge > hideDist
            box.delete(inv.bx), line.delete(inv.midLine), array.remove(activeIFVGs, i)
            continue
        
        box.set_right(inv.bx, bar_index), line.set_x2(inv.midLine, bar_index)
        float distToMid = math.abs(close - ((inv.top + inv.bot) / 2))
        if distToMid < minIfvgDist
            minIfvgDist := distToMid
            closestIfvgIndex := i

if array.size(activeIFVGs) > 0
    for i = array.size(activeIFVGs) - 1 to 0
        IFVG inv = array.get(activeIFVGs, i)
        if i == closestIfvgIndex and showIFVG
            box.set_bgcolor(inv.bx, ifvgBgColor), box.set_border_color(inv.bx, ifvgBorderColor), line.set_color(inv.midLine, ifvgBorderColor)
        else
            box.set_bgcolor(inv.bx, na), box.set_border_color(inv.bx, na), line.set_color(inv.midLine, na)
````
