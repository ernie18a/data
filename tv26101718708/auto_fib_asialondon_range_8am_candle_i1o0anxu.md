# Auto Fib - Asia/London Range + 8am Candle

- url: https://www.tradingview.com/script/I1O0ANXu-Auto-Fib-Asia-London-Range-8am-Candle/
- type: indicator
- pine_id: PUB;047467ca689e4997b1e4e69823805e5c
- version: 1.0

## Description

Auto Fib – Asia/London Range + 8am Candle is a TradingView indicator that draws your fib retracements automatically each day, so you don’t place them by hand.

It draws up to three fibs, each with its own on/off toggle at the top of the settings:

Asia/London fib: takes the Asia high and low (17:00–00:00 CT) and the London high and low (2:00–6:00 CT), finds the highest and lowest of the four, and draws the fib across that swing at 6:00 CT.
Previous day fib: draws across the prior trading day’s high and low at the 17:00 CT roll. It can use the full session or RTH only.
8am candle fib: runs from the high to the low of the 8:00 CT 1-hour candle and updates live while the candle forms. It is off by default.

Direction is automatic. The 0 level goes at the end of the move: at the high if the low printed first, at the low if the high printed first. The 8am fib uses the candle’s colour instead (green puts 0 at the high). Each fib has a Reverse switch.

The levels shown by default are 0, 0.236, 0.786 and 1, with four more slots (0.382, 0.5, 0.618, 1.618) switched off. All fibs share the same level list.

Each fib is drawn in a single colour by default (light orange for Asia/London), with level and price labels at the top right of each line. Trend line and background shading are off. Line style, extension, label format, log scale, session times and how many days stay on the chart are all adjustable.

## Source Code

````pine
//@version=6
indicator("Auto Fib - Asia/London Range + 8am Candle", "AutoFib", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────── Inputs ─────────────────────────
gShow = "Show / hide"
showAL = input.bool(true, "Show Asia/London fib", group = gShow)
show8  = input.bool(false,"Show 8am candle fib", group = gShow)
showPD = input.bool(true, "Show previous day high/low fib", group = gShow)
showPrior = input.bool(false, "Show prior days' fibs", group = gShow, tooltip = "Off: only the currently active fibs are on the chart. On: past fibs stay, up to each fib's 'Days to keep on chart'.")

gGen = "General"
tz      = input.string("America/Chicago", "Timezone", group = gGen)
rollHr  = input.int(17, "New trading day starts at (hour)", 0, 23, group = gGen, tooltip = "The previous day and 8am fibs roll over at this hour. 17 = 5pm CT futures reopen. The Asia/London fib stays live until the next one forms at London close.")

gAL = "Asia / London fib"
asiaSess = input.session("1700-0000", "Asia session", group = gAL)
lonSess  = input.session("0100-0600", "London session", group = gAL)
revAL    = input.bool(false, "Reverse", group = gAL, tooltip = "Off: 0 sits at the END of the overnight move (up move = 0 at the high, down move = 0 at the low), same as dragging the TradingView fib from swing start to swing end. On: flipped.")
oneAL    = input.bool(true, "Use one color", inline = "oneAL", group = gAL)
oneALCol = input.color(#ffcc80, "", inline = "oneAL", group = gAL)
histAL   = input.int(3, "Days to keep on chart", 1, 20, group = gAL)

g8 = "8am candle fib"
cHour   = input.int(8, "Candle start hour", 0, 23, group = g8)
cMin    = input.int(0, "Candle start minute", 0, 59, group = g8)
cTf     = input.timeframe("60", "Candle timeframe", group = g8, tooltip = "Which 8am candle to measure. The chart timeframe must be this or lower.")
rev8    = input.bool(false, "Reverse", group = g8, tooltip = "Off: green candle = 0 at the high, red candle = 0 at the low. On: flipped.")
one8    = input.bool(true,"Use one color", inline = "one8", group = g8)
one8Col = input.color(color.aqua, "", inline = "one8", group = g8)
hist8   = input.int(3, "Days to keep on chart", 1, 20, group = g8)

gPD = "Previous day fib"
pdMode   = input.string("Full session", "Previous day range", ["Full session", "RTH only"], group = gPD, tooltip = "Full session = the whole trading day between day rolls (matches the daily candle). RTH only = high/low of the RTH session below.")
rthSess  = input.session("0830-1500", "RTH session", group = gPD)
revPD    = input.bool(false, "Reverse", group = gPD, tooltip = "Off: 0 sits at whichever extreme printed last (low then high = 0 at the high). On: flipped.")
onePD    = input.bool(true,"Use one color", inline = "onePD", group = gPD)
onePDCol = input.color(color.fuchsia, "", inline = "onePD", group = gPD)
histPD   = input.int(3, "Days to keep on chart", 1, 20, group = gPD)

gL = "Levels"
s1 = input.bool(true,  "", inline = "l1", group = gL)
v1 = input.float(0,     "", inline = "l1", group = gL)
c1 = input.color(#787b86, "", inline = "l1", group = gL)
s2 = input.bool(true,  "", inline = "l2", group = gL)
v2 = input.float(0.236, "", inline = "l2", group = gL)
c2 = input.color(#f23645, "", inline = "l2", group = gL)
s3 = input.bool(false, "", inline = "l3", group = gL)
v3 = input.float(0.382, "", inline = "l3", group = gL)
c3 = input.color(#ff9800, "", inline = "l3", group = gL)
s4 = input.bool(false, "", inline = "l4", group = gL)
v4 = input.float(0.5,   "", inline = "l4", group = gL)
c4 = input.color(#4caf50, "", inline = "l4", group = gL)
s5 = input.bool(false, "", inline = "l5", group = gL)
v5 = input.float(0.618, "", inline = "l5", group = gL)
c5 = input.color(#089981, "", inline = "l5", group = gL)
s6 = input.bool(true,  "", inline = "l6", group = gL)
v6 = input.float(0.786, "", inline = "l6", group = gL)
c6 = input.color(#2196f3, "", inline = "l6", group = gL)
s7 = input.bool(true,  "", inline = "l7", group = gL)
v7 = input.float(1,     "", inline = "l7", group = gL)
c7 = input.color(#787b86, "", inline = "l7", group = gL)
s8 = input.bool(false, "", inline = "l8", group = gL)
v8 = input.float(1.618, "", inline = "l8", group = gL)
c8 = input.color(#2962ff, "", inline = "l8", group = gL)

gS = "Style"
showTrend = input.bool(false,"Trend line", inline = "tr", group = gS)
trendCol  = input.color(color.new(#787b86, 30), "", inline = "tr", group = gS)
lineWidth = input.int(1, "Levels line width", 1, 4, group = gS)
styleIn   = input.string("Solid", "Levels line style", ["Solid", "Dashed", "Dotted"], group = gS)
extIn     = input.string("None", "Extend lines", ["None", "Right", "Left", "Both"], group = gS, tooltip = "Applies to the current day's fib only.")
showBg    = input.bool(false,"Background", inline = "bg", group = gS)
bgTransp  = input.int(85, "transparency", 0, 100, inline = "bg", group = gS)
showLvl   = input.bool(true, "Levels", inline = "lab", group = gS)
showPrice = input.bool(true, "Prices", inline = "lab", group = gS)
asPct     = input.bool(false, "Levels as percent", group = gS)
hPos      = input.string("Right","Labels", ["Left", "Center", "Right"], inline = "pos", group = gS)
vPos      = input.string("Top","", ["Top", "Middle", "Bottom"], inline = "pos", group = gS)
labOffset = input.int(15, "Push lines and labels right of price (bars)", 0, 500, group = gS, tooltip = "How many bars past the current candle the live fib lines run. With Labels set to Right, the labels sit at that end, clear of the candles.")
sizeIn    = input.string("Small", "Font size", ["Tiny", "Small", "Normal", "Large"], group = gS)
useLog    = input.bool(false, "Fib levels based on log scale", group = gS)

// ───────────────────────── Style helpers ─────────────────────────
lineStyle = switch styleIn
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

extMode = switch extIn
    "Right" => extend.right
    "Left"  => extend.left
    "Both"  => extend.both
    => extend.none

txtSize = switch sizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

labStyle = switch
    hPos == "Left"   and vPos == "Top"    => label.style_label_lower_right
    hPos == "Left"   and vPos == "Bottom" => label.style_label_upper_right
    hPos == "Left"                        => label.style_label_right
    hPos == "Right"  and vPos == "Top"    => label.style_label_lower_left
    hPos == "Right"  and vPos == "Bottom" => label.style_label_upper_left
    hPos == "Right"                       => label.style_label_left
    vPos == "Top"                         => label.style_label_down
    vPos == "Bottom"                      => label.style_label_up
    => label.style_label_center

// Enabled levels, sorted by value (so background bands stack correctly)
var array<float> lvVals = array.new<float>()
var array<color> lvCols = array.new<color>()
if barstate.isfirst
    array<float> rawV = array.from(v1, v2, v3, v4, v5, v6, v7, v8)
    array<color> rawC = array.from(c1, c2, c3, c4, c5, c6, c7, c8)
    array<bool>  rawS = array.from(s1, s2, s3, s4, s5, s6, s7, s8)
    array<int>   idx  = rawV.sort_indices()
    for i in idx
        if rawS.get(i)
            lvVals.push(rawV.get(i))
            lvCols.push(rawC.get(i))

// ───────────────────────── Fib object ─────────────────────────
type Fib
    array<line>     lines
    array<label>    labels
    array<linefill> fills
    line            trend
    int             x1

labX(int x1, int x2) =>
    hPos == "Left" ? x1 : hPos == "Right" ? x2 : int((x1 + x2) / 2)

// p0 = price of the 0 level, p1 = price of the 1 level
fibPrice(float p0, float p1, float l) =>
    useLog and p0 > 0 and p1 > 0 ? math.exp(math.log(p0) + (math.log(p1) - math.log(p0)) * l) : p0 + (p1 - p0) * l

lvlText(float l, float p) =>
    string a = showLvl ? (asPct ? str.tostring(l * 100, "#.##") + "%" : str.tostring(l, "#.###")) : ""
    string b = showPrice ? (showLvl ? " (" : "") + str.tostring(p, format.mintick) + (showLvl ? ")" : "") : ""
    a + b

// (t1, p1) = swing start = the 1 level.  (t0, p0) = swing end = the 0 level.
makeFib(int x1, int t1, float p1, int t0, float p0, bool useOne, color oneCol) =>
    Fib f = Fib.new(lines = array.new<line>(), labels = array.new<label>(), fills = array.new<linefill>(), trend = na, x1 = x1)
    line prev = na
    for [i, l] in lvVals
        color c = useOne ? oneCol : lvCols.get(i)
        float p = fibPrice(p0, p1, l)
        line ln = line.new(x1 = x1, y1 = p, x2 = time, y2 = p, xloc = xloc.bar_time, extend = extMode, color = c, style = lineStyle, width = lineWidth)
        f.lines.push(ln)
        if showBg and not na(prev)
            f.fills.push(linefill.new(prev, ln, color.new(c, bgTransp)))
        prev := ln
        if showLvl or showPrice
            f.labels.push(label.new(x = labX(x1, time), y = p, text = lvlText(l, p), xloc = xloc.bar_time, yloc = yloc.price, color = color(na), style = labStyle, textcolor = c, size = txtSize))
    if showTrend
        f.trend := line.new(x1 = t1, y1 = p1, x2 = t0, y2 = p0, xloc = xloc.bar_time, extend = extend.none, color = trendCol, style = line.style_dashed, width = 1)
    f

method stretch(Fib f, int t) =>
    for ln in f.lines
        ln.set_x2(t)
    if hPos != "Left"
        for lb in f.labels
            lb.set_x(labX(f.x1, t))

method retire(Fib f) =>
    // pull a finished fib back to the current bar so it doesn't overhang the next day
    f.stretch(time)
    for ln in f.lines
        ln.set_extend(extend.none)

method destroy(Fib f) =>
    for ln in f.lines
        ln.delete()
    for lb in f.labels
        lb.delete()
    for lf in f.fills
        lf.delete()
    f.trend.delete()

addFib(array<Fib> arr, Fib f, int keep) =>
    arr.push(f)
    while arr.size() > (showPrior ? keep : 1)
        Fib old = arr.shift()
        old.destroy()

// Called when a fib's day is over: freeze it as history, or remove it if prior fibs are hidden
endFib(array<Fib> arr) =>
    if arr.size() > 0
        if showPrior
            arr.last().retire()
        else
            Fib old = arr.pop()
            old.destroy()

// ───────────────────────── Trading-day roll ─────────────────────────
int minOfDay = hour(time, tz) * 60 + minute(time, tz)
int shifted  = (minOfDay - rollHr * 60 + 1440) % 1440
bool newDay  = shifted < nz(shifted[1], shifted) or time - nz(time[1], time) > 86400000

var array<Fib> alFibs = array.new<Fib>()
var array<Fib> c8Fibs = array.new<Fib>()
var bool alActive = false
var bool c8Active = false
var array<Fib> pdFibs = array.new<Fib>()
var bool pdActive = false

if newDay
    // Asia/London fib is not ended here: it stays live overnight until the next one forms at London close
    if c8Active
        endFib(c8Fibs)
    if pdActive
        endFib(pdFibs)
    c8Active := false
    pdActive := false

// ───────────────────────── Previous day high/low fib ─────────────────────────
bool inRth = not na(time(timeframe.period, rthSess, tz))
bool pdBar = pdMode == "Full session" or inRth

var float dH = na
var float dL = na
var int   dHt = na
var int   dLt = na

if newDay
    // the day that just ended becomes "previous day"
    if showPD and not na(dH)
        bool up         = dHt >= dLt
        bool zeroAtHigh = up != revPD
        float p0 = zeroAtHigh ? dH : dL
        float p1 = zeroAtHigh ? dL : dH
        int   t0 = zeroAtHigh ? dHt : dLt
        int   t1 = zeroAtHigh ? dLt : dHt
        addFib(pdFibs, makeFib(math.min(dHt, dLt), t1, p1, t0, p0, onePD, onePDCol), histPD)
        pdActive := true
    dH := na
    dL := na

if pdBar
    if na(dH)
        dH  := high
        dL  := low
        dHt := time
        dLt := time
    else
        if high > dH
            dH  := high
            dHt := time
        if low < dL
            dL  := low
            dLt := time

// ───────────────────────── Asia / London fib ─────────────────────────
bool inAsia = not na(time(timeframe.period, asiaSess, tz))
bool inLon  = not na(time(timeframe.period, lonSess, tz))

var float aH = na
var float aL = na
var int   aHt = na
var int   aLt = na
var float lH = na
var float lL = na
var int   lHt = na
var int   lLt = na

if inAsia
    if not inAsia[1]
        aH  := high
        aL  := low
        aHt := time
        aLt := time
        lH  := na
        lL  := na
    else
        if high > aH
            aH  := high
            aHt := time
        if low < aL
            aL  := low
            aLt := time

if inLon
    if not inLon[1]
        lH  := high
        lL  := low
        lHt := time
        lLt := time
    else
        if high > lH
            lH  := high
            lHt := time
        if low < lL
            lL  := low
            lLt := time

bool lonEnd = inLon[1] and not inLon

if lonEnd and showAL and not na(aH) and not na(lH)
    // highest and lowest of the 4 levels (Asia H/L, London H/L)
    float hi  = math.max(aH, lH)
    float lo  = math.min(aL, lL)
    int   hiT = aH >= lH ? aHt : lHt
    int   loT = aL <= lL ? aLt : lLt
    // trend: low printed first then high = up move
    bool up         = hiT >= loT
    bool zeroAtHigh = up != revAL
    float p0 = zeroAtHigh ? hi : lo
    float p1 = zeroAtHigh ? lo : hi
    int   t0 = zeroAtHigh ? hiT : loT
    int   t1 = zeroAtHigh ? loT : hiT
    if alActive and alFibs.size() > 0
        alFibs.last().retire()
    addFib(alFibs, makeFib(math.min(hiT, loT), t1, p1, t0, p0, oneAL, oneALCol), histAL)
    alActive := true

// ───────────────────────── 8am candle fib ─────────────────────────
int cStart = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), cHour, cMin)
int cEnd   = cStart + timeframe.in_seconds(cTf) * 1000
bool inC   = time >= cStart and time < cEnd

var float cO = na
var float cH = na
var float cL = na
var float cC = na
var int   cT = na
var int   cHt = na
var int   cLt = na

if inC
    if not inC[1]
        cO  := open
        cH  := high
        cL  := low
        cT  := time
        cHt := time
        cLt := time
    else
        if high > cH
            cH  := high
            cHt := time
        if low < cL
            cL  := low
            cLt := time
    cC := close

// Drawn from the candle's first bar and rebuilt on every update until it closes
var int c8FibT = na

if inC and show8
    bool up         = cC >= cO
    bool zeroAtHigh = up != rev8
    float p0 = zeroAtHigh ? cH : cL
    float p1 = zeroAtHigh ? cL : cH
    int   t0 = zeroAtHigh ? cHt : cLt
    int   t1 = zeroAtHigh ? cLt : cHt
    if c8Active and c8Fibs.size() > 0
        if c8FibT == cT
            Fib old = c8Fibs.pop()
            old.destroy()
        else
            c8Fibs.last().retire()
    addFib(c8Fibs, makeFib(cT, t1, p1, t0, p0, one8, one8Col), hist8)
    c8Active := true
    c8FibT   := cT

// ───────────────────────── Extend the live fibs ─────────────────────────
int rightEdge = time_close + labOffset * timeframe.in_seconds() * 1000
if alActive and alFibs.size() > 0
    alFibs.last().stretch(rightEdge)
if c8Active and c8Fibs.size() > 0
    c8Fibs.last().stretch(rightEdge)
if pdActive and pdFibs.size() > 0
    pdFibs.last().stretch(rightEdge)
````
