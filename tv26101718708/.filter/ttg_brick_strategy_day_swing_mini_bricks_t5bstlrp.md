# TTG Brick Strategy Day Swing Mini Bricks

- url: https://www.tradingview.com/script/T5bstLRP-TTG-Brick-Strategy-Day-Swing-Mini-Bricks/
- type: indicator
- pine_id: PUB;171acbc689934acca23caec4a5f4af79
- version: 2.0

## Description

## TTG Brick Strategy — Dual Adjustable Dashed Levels

This updated **TTG Brick Strategy** adds two customizable internal levels to each brick, creating a clearer roadmap of how price is progressing through the Bull, Center, and Bear zones.

Each brick can now be divided into **four sections** rather than relying only on the traditional 50% midpoint.

For example, with the secondary level set to **25%**, each brick becomes:

**Brick Top**  
**75% — Upper Dashed Line**  
**50% — Main Midline**  
**25% — Lower Dashed Line**  
**Brick Bottom**

### Three Internal Price Levels

**Main Midline — 50%**  
The original solid midline remains the center of each brick.

**Lower Secondary Level — adjustable**  
A dashed line that can be positioned anywhere within the lower half of the brick.

**Upper Secondary Level — mirrored**  
A second dashed line on the upper side of the brick. It mirrors the lower setting. For example:

- 20% → upper line at 80%
- 25% → upper line at 75%
- 30% → upper line at 70%
- 40% → upper line at 60%

This creates symmetrical internal price zones.

### Independent Toggles

The secondary levels can be controlled independently:

**Show Secondary Dashed Line**  
Turns the lower dashed level on/off.

**Show Upper Secondary Dashed Line**  
Turns the upper mirrored level on/off.

This means you can display **both dashed levels, only the upper, only the lower, or neither** while keeping the original 50% midline.

### Applies to the Entire Brick System

The additional levels are incorporated into:

**Bull Bricks** — bullish expansion zones  
**Center Bricks** — primary decision/range zones  
**Bear Bricks** — bearish expansion zones  
**Continuation Bricks** — additional bricks created as price expands

And they work across all four TTG structures:

**Overnight • RTH • Weekly • Monthly**

### How to Read It

Instead of seeing a brick as one large price area, you can now read price progression as:

**0% → 25% → 50% → 75% → 100%**

That can make it easier to see whether price is merely entering a brick, reaching equilibrium, or progressing toward the opposite boundary.

For a bullish move, for example:

**Brick Bottom → 25% → 50% → 75% → Brick Top**

gives you a structured way to monitor the move through the entire brick rather than treating the brick as a single zone.

## Source Code

````pine
//@version=6
indicator("TTG Brick Strategy Progressive Bricks Level 1 Oct 26", overlay=true, max_boxes_count=500, max_lines_count=500)

string TZ = "America/New_York"
groupRanges = "1. RANGE SETTINGS"
showON = input.bool(true, "After-hours + Premarket (4PM–9:30AM)", group=groupRanges)
showRTH = input.bool(false, "Regular session (9:30AM–4PM)", group=groupRanges)
showWeekly = input.bool(false, "Previous Week Swing", group=groupRanges)
showMonthly = input.bool(false, "Previous Month Swing", group=groupRanges)
maxContinuationBricks = input.int(6, "Max Bricks Per Side", minval=1, maxval=12, group=groupRanges)

groupBox = "2. BOX APPEARANCE"
centerColor = input.color(color.rgb(205,235,245), "Center Rectangle", group=groupBox)
upperActiveColor = input.color(color.green, "Bull Brick Color", group=groupBox)
lowerActiveColor = input.color(color.red, "Bear Brick Color", group=groupBox)
boxTransparency = input.int(78, "Center Transparency", minval=0, maxval=100, group=groupBox)
activeTransparency = input.int(68, "Bull/Bear Transparency", minval=0, maxval=100, group=groupBox)
borderColor = input.color(color.black, "Border Color", group=groupBox)
borderWidth = input.int(2, "Border Width", minval=1, maxval=5, group=groupBox)

groupMid = "3. HORIZONTAL BRICK LINES"
showMidline = input.bool(true, "Show Center Line (50%)", group=groupMid)
midlineColor = input.color(color.red, "Center Line Color", group=groupMid)
midlineTicks = input.int(3, "Center Line Width", minval=1, maxval=4, group=groupMid)
midlineStyle = input.string("Solid", "Center Line Style", options=["Solid", "Dashed"], group=groupMid)
showSecondaryLine = input.bool(true, "Show Lower Line (25%)", group=groupMid)
showUpperSecondaryLine = input.bool(true, "Show Upper Line (75%)", group=groupMid)
secondaryLinePercent = input.float(25, "Outer Line Offset %", minval=1, maxval=49, group=groupMid)
secondaryLineColor = input.color(color.rgb(156,39,176), "Outer Lines Color", group=groupMid)
secondaryLineWidth = input.int(2, "Outer Lines Width", minval=1, maxval=4, group=groupMid)
secondaryLineStyle = input.string("Dashed", "Outer Lines Style", options=["Solid", "Dashed"], group=groupMid)
centerStyle = midlineStyle == "Dashed" ? line.style_dashed : line.style_solid
outerStyle = secondaryLineStyle == "Dashed" ? line.style_dashed : line.style_solid

groupAlerts = "4. ALERT SETTINGS"
enableAlerts = input.bool(true, "Enable Alerts", group=groupAlerts)
alertOnClose = input.bool(true, "Require Candle Close", group=groupAlerts)

// A brick is created only when both OPEN and CLOSE are within its price band.
// Levels are computed invisibly. The actual box and its midlines are born on the qualifying bar.
// Each horizontal line spans one bar initially, then extends to the right.
// Never use identical x-coordinates for both endpoints: that caused vertical lines.
f_make_brick(array<box> boxes, array<line> mids, array<line> lowerLines, array<line> upperLines, int leftTime, float bottom, float height, color brickColor) =>
    float top = bottom + height
    box b = box.new(left=leftTime, top=top, right=time, bottom=bottom, xloc=xloc.bar_time, extend=extend.right, border_color=borderColor, border_width=borderWidth, bgcolor=color.new(brickColor, brickColor == centerColor ? boxTransparency : activeTransparency))
    array.push(boxes, b)
    if showMidline
        float y = bottom + height * 0.5
        array.push(mids, line.new(bar_index, y, bar_index + 1, y, xloc=xloc.bar_index, extend=extend.right, color=midlineColor, style=centerStyle, width=midlineTicks))
    if showSecondaryLine
        float y = bottom + height * secondaryLinePercent / 100.0
        array.push(lowerLines, line.new(bar_index, y, bar_index + 1, y, xloc=xloc.bar_index, extend=extend.right, color=secondaryLineColor, style=outerStyle, width=secondaryLineWidth))
    if showUpperSecondaryLine
        float y = bottom + height * (1.0 - secondaryLinePercent / 100.0)
        array.push(upperLines, line.new(bar_index, y, bar_index + 1, y, xloc=xloc.bar_index, extend=extend.right, color=secondaryLineColor, style=outerStyle, width=secondaryLineWidth))

f_clear(array<box> boxes, array<line> mids, array<line> lowers, array<line> uppers) =>
    for b in boxes
        box.delete(b)
    for l in mids
        line.delete(l)
    for l in lowers
        line.delete(l)
    for l in uppers
        line.delete(l)
    array.clear(boxes)
    array.clear(mids)
    array.clear(lowers)
    array.clear(uppers)

f_inside(float bottom, float height) =>
    open >= bottom and open <= bottom + height and close >= bottom and close <= bottom + height

// Each structure has an independent center, upper count and lower count.
// New bricks extend from the activation candle, not backward into history.
var array<box> onBoxes = array.new<box>()
var array<line> onMids = array.new<line>()
var array<line> onLowerLines = array.new<line>()
var array<line> onUpperLines = array.new<line>()
var array<box> rthBoxes = array.new<box>()
var array<line> rthMids = array.new<line>()
var array<line> rthLowerLines = array.new<line>()
var array<line> rthUpperLines = array.new<line>()
var array<box> weekBoxes = array.new<box>()
var array<line> weekMids = array.new<line>()
var array<line> weekLowerLines = array.new<line>()
var array<line> weekUpperLines = array.new<line>()
var array<box> monthBoxes = array.new<box>()
var array<line> monthMids = array.new<line>()
var array<line> monthLowerLines = array.new<line>()
var array<line> monthUpperLines = array.new<line>()

int hh = hour(time,TZ)
int mm = minute(time,TZ)
bool inON = hh >= 16 or hh < 9 or (hh == 9 and mm < 30)
bool inRTH = (hh > 9 or (hh == 9 and mm >= 30)) and hh < 16
bool newON = inON and (not inON[1])
bool newRTH = inRTH and (not inRTH[1])

var float onHigh = na
var float onLow = na
var float rthHigh = na
var float rthLow = na
var int onLeft = na
var int rthLeft = na
var int onUp = 0
var int onDown = 0
var int rthUp = 0
var int rthDown = 0

if newON
    f_clear(onBoxes,onMids,onLowerLines,onUpperLines)
    onHigh := high
    onLow := low
    onLeft := time
    onUp := 0
    onDown := 0
if inON
    onHigh := na(onHigh) ? high : math.max(onHigh,high)
    onLow := na(onLow) ? low : math.min(onLow,low)
    if na(onLeft)
        onLeft := time
if newRTH
    f_clear(rthBoxes,rthMids,rthLowerLines,rthUpperLines)
    rthHigh := high
    rthLow := low
    rthLeft := time
    rthUp := 0
    rthDown := 0
if inRTH
    rthHigh := na(rthHigh) ? high : math.max(rthHigh,high)
    rthLow := na(rthLow) ? low : math.min(rthLow,low)
    if na(rthLeft)
        rthLeft := time

// During the measuring session, only the center rectangle exists and grows.
// It is updated, not recreated, until the range is locked.
if showON and not na(onHigh) and onHigh > onLow
    float h = onHigh-onLow
    if array.size(onBoxes)==0
        f_make_brick(onBoxes,onMids,onLowerLines,onUpperLines,onLeft,onLow,h,centerColor)
    if inON
        box.set_top(array.get(onBoxes,0),onHigh)
        box.set_bottom(array.get(onBoxes,0),onLow)
        if showMidline and array.size(onMids)>0
            float m = (onHigh+onLow)/2
            line.set_y1(array.get(onMids,0),m)
            line.set_y2(array.get(onMids,0),m)
        if showSecondaryLine and array.size(onLowerLines)>0
            float y = onLow+h*secondaryLinePercent/100
            line.set_y1(array.get(onLowerLines,0),y)
            line.set_y2(array.get(onLowerLines,0),y)
        if showUpperSecondaryLine and array.size(onUpperLines)>0
            float y = onHigh-h*secondaryLinePercent/100
            line.set_y1(array.get(onUpperLines,0),y)
            line.set_y2(array.get(onUpperLines,0),y)
    if not inON and barstate.isconfirmed
        if onUp < maxContinuationBricks and f_inside(onHigh+h*onUp,h)
            f_make_brick(onBoxes,onMids,onLowerLines,onUpperLines,time,onHigh+h*onUp,h,upperActiveColor)
            onUp += 1
        if onDown < maxContinuationBricks and f_inside(onLow-h*(onDown+1),h)
            f_make_brick(onBoxes,onMids,onLowerLines,onUpperLines,time,onLow-h*(onDown+1),h,lowerActiveColor)
            onDown += 1

if showRTH and not na(rthHigh) and rthHigh > rthLow
    float h = rthHigh-rthLow
    if array.size(rthBoxes)==0
        f_make_brick(rthBoxes,rthMids,rthLowerLines,rthUpperLines,rthLeft,rthLow,h,centerColor)
    if inRTH
        box.set_top(array.get(rthBoxes,0),rthHigh)
        box.set_bottom(array.get(rthBoxes,0),rthLow)
        if showMidline and array.size(rthMids)>0
            float m = (rthHigh+rthLow)/2
            line.set_y1(array.get(rthMids,0),m)
            line.set_y2(array.get(rthMids,0),m)
        if showSecondaryLine and array.size(rthLowerLines)>0
            float y = rthLow+h*secondaryLinePercent/100
            line.set_y1(array.get(rthLowerLines,0),y)
            line.set_y2(array.get(rthLowerLines,0),y)
        if showUpperSecondaryLine and array.size(rthUpperLines)>0
            float y = rthHigh-h*secondaryLinePercent/100
            line.set_y1(array.get(rthUpperLines,0),y)
            line.set_y2(array.get(rthUpperLines,0),y)
    if not inRTH and hh>=16 and barstate.isconfirmed
        if rthUp < maxContinuationBricks and f_inside(rthHigh+h*rthUp,h)
            f_make_brick(rthBoxes,rthMids,rthLowerLines,rthUpperLines,time,rthHigh+h*rthUp,h,upperActiveColor)
            rthUp += 1
        if rthDown < maxContinuationBricks and f_inside(rthLow-h*(rthDown+1),h)
            f_make_brick(rthBoxes,rthMids,rthLowerLines,rthUpperLines,time,rthLow-h*(rthDown+1),h,lowerActiveColor)
            rthDown += 1

float prevWeekHigh = request.security(syminfo.tickerid,"W",high[1],lookahead=barmerge.lookahead_on)
float prevWeekLow = request.security(syminfo.tickerid,"W",low[1],lookahead=barmerge.lookahead_on)
float prevMonthHigh = request.security(syminfo.tickerid,"M",high[1],lookahead=barmerge.lookahead_on)
float prevMonthLow = request.security(syminfo.tickerid,"M",low[1],lookahead=barmerge.lookahead_on)
int weekStart = time("W")
int monthStart = time("M")
var int storedWeek = na
var int storedMonth = na
var int weekUp = 0
var int weekDown = 0
var int monthUp = 0
var int monthDown = 0
if na(storedWeek) or weekStart != storedWeek
    f_clear(weekBoxes,weekMids,weekLowerLines,weekUpperLines)
    storedWeek := weekStart
    weekUp := 0
    weekDown := 0
if na(storedMonth) or monthStart != storedMonth
    f_clear(monthBoxes,monthMids,monthLowerLines,monthUpperLines)
    storedMonth := monthStart
    monthUp := 0
    monthDown := 0

if showWeekly and not na(prevWeekHigh) and not na(prevWeekLow) and prevWeekHigh > prevWeekLow
    float h = prevWeekHigh-prevWeekLow
    if array.size(weekBoxes)==0
        f_make_brick(weekBoxes,weekMids,weekLowerLines,weekUpperLines,weekStart,prevWeekLow,h,centerColor)
    if barstate.isconfirmed
        if weekUp < maxContinuationBricks and f_inside(prevWeekHigh+h*weekUp,h)
            f_make_brick(weekBoxes,weekMids,weekLowerLines,weekUpperLines,time,prevWeekHigh+h*weekUp,h,upperActiveColor)
            weekUp += 1
        if weekDown < maxContinuationBricks and f_inside(prevWeekLow-h*(weekDown+1),h)
            f_make_brick(weekBoxes,weekMids,weekLowerLines,weekUpperLines,time,prevWeekLow-h*(weekDown+1),h,lowerActiveColor)
            weekDown += 1
if showMonthly and not na(prevMonthHigh) and not na(prevMonthLow) and prevMonthHigh > prevMonthLow
    float h = prevMonthHigh-prevMonthLow
    if array.size(monthBoxes)==0
        f_make_brick(monthBoxes,monthMids,monthLowerLines,monthUpperLines,monthStart,prevMonthLow,h,centerColor)
    if barstate.isconfirmed
        if monthUp < maxContinuationBricks and f_inside(prevMonthHigh+h*monthUp,h)
            f_make_brick(monthBoxes,monthMids,monthLowerLines,monthUpperLines,time,prevMonthHigh+h*monthUp,h,upperActiveColor)
            monthUp += 1
        if monthDown < maxContinuationBricks and f_inside(prevMonthLow-h*(monthDown+1),h)
            f_make_brick(monthBoxes,monthMids,monthLowerLines,monthUpperLines,time,prevMonthLow-h*(monthDown+1),h,lowerActiveColor)
            monthDown += 1

// Preserve the nine named alert types. An alert level is eligible only after
// the corresponding brick has actually been printed (no future brick alerts).
f_cross(float y) =>
    not na(y) and (alertOnClose ? barstate.isconfirmed : true) and ta.cross(close,y)

// Collect events from the visible bricks, including continuation bricks.
// Array order: center first, then bricks in activation order.
f_alerts(array<box> boxes, float centerLow, float centerHigh) =>
    bool bullMid = false
    bool centerMid = false
    bool bearMid = false
    bool centerTop = false
    bool centerBottom = false
    bool bullTop = false
    bool bullBottom = false
    bool bearTop = false
    bool bearBottom = false
    int n=array.size(boxes)
    if n>0
        for i=0 to n-1
            box b=array.get(boxes,i)
            float top=box.get_top(b)
            float bottom=box.get_bottom(b)
            float mid=(top+bottom)/2
            bool isCenter=i==0
            bool isBull=not isCenter and bottom>=centerHigh
            bool isBear=not isCenter and top<=centerLow
            // Evaluate cross without relying on the mutable box state of previous bars.
            bool crossMid=ta.cross(close,mid)
            bool crossTop=ta.cross(close,top)
            bool crossBottom=ta.cross(close,bottom)
            if isCenter
                centerMid:=centerMid or crossMid
                centerTop:=centerTop or crossTop
                centerBottom:=centerBottom or crossBottom
            if isBull
                bullMid:=bullMid or crossMid
                bullTop:=bullTop or crossTop
                bullBottom:=bullBottom or crossBottom
            if isBear
                bearMid:=bearMid or crossMid
                bearTop:=bearTop or crossTop
                bearBottom:=bearBottom or crossBottom
    [bullMid,centerMid,bearMid,centerTop,centerBottom,bullTop,bullBottom,bearTop,bearBottom]

[a1,a2,a3,a4,a5,a6,a7,a8,a9]=f_alerts(onBoxes,onLow,onHigh)
[b1,b2,b3,b4,b5,b6,b7,b8,b9]=f_alerts(rthBoxes,rthLow,rthHigh)
[c1,c2,c3,c4,c5,c6,c7,c8,c9]=f_alerts(weekBoxes,prevWeekLow,prevWeekHigh)
[d1,d2,d3,d4,d5,d6,d7,d8,d9]=f_alerts(monthBoxes,prevMonthLow,prevMonthHigh)
// Alerts are emitted only for enabled structures and respect candle-close setting.
bool ready=enableAlerts and (not alertOnClose or barstate.isconfirmed)
alertcondition(ready and ((showON and a1) or (showRTH and b1) or (showWeekly and c1) or (showMonthly and d1)),"bull brick midline","bull brick midline")
alertcondition(ready and ((showON and a2) or (showRTH and b2) or (showWeekly and c2) or (showMonthly and d2)),"center brick midline","center brick midline")
alertcondition(ready and ((showON and a3) or (showRTH and b3) or (showWeekly and c3) or (showMonthly and d3)),"bear brick midline","bear brick midline")
alertcondition(ready and ((showON and a4) or (showRTH and b4) or (showWeekly and c4) or (showMonthly and d4)),"center brick top","center brick top")
alertcondition(ready and ((showON and a5) or (showRTH and b5) or (showWeekly and c5) or (showMonthly and d5)),"center brick bottom","center brick bottom")
alertcondition(ready and ((showON and a6) or (showRTH and b6) or (showWeekly and c6) or (showMonthly and d6)),"bull brick top","bull brick top")
alertcondition(ready and ((showON and a7) or (showRTH and b7) or (showWeekly and c7) or (showMonthly and d7)),"bull brick bottom","bull brick bottom")
alertcondition(ready and ((showON and a8) or (showRTH and b8) or (showWeekly and c8) or (showMonthly and d8)),"bear brick top","bear brick top")
alertcondition(ready and ((showON and a9) or (showRTH and b9) or (showWeekly and c9) or (showMonthly and d9)),"bear brick bottom","bear brick bottom")
````
