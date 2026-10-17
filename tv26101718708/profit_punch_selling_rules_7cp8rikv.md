# Profit Punch : Selling Rules

- url: https://www.tradingview.com/script/7CP8rIKv-Profit-Punch-Selling-Rules/
- type: indicator
- pine_id: PUB;58a743be119d42938f2c341aba8a0558
- version: 3.0

## Description

[b]Profit Punch : Selling Rules[/b]
A fully customizable overlay that prints visual signals to remind you when to act on a position and to support risk management. Bullish markers print below the bar, bearish markers print above. Works on any timeframe.

[b]Bullish rules[/b]
[list]
[*]3 Green Days
[*]Violation of the previous 3 Red Days (close above the high of red day 1)
[*]Gap Down Closure (a gap down > 1.5x ATR that gets filled back to the prior close)
[/list]

[b]Bearish rules[/b]
[list]
[*]3 Red Days
[*]Violation of the previous 3 Green Days (close below the low of green day 1)
[*]Gap Up Closure (a gap up > 1.5x ATR that gets filled back to the prior close)
[*]Moving Average respected then broken — applied separately to the 20 and 50 MA
[/list]

[b]Everything is configurable[/b]
[list]
[*]Toggle each rule on or off
[*]Set how many recent signals stay on screen [i]independently per rule[/i]
[*]Edit each rule's name, color (use opacity for translucent markers), and icon (Label, Arrow, Triangle, Flag, Circle, Square, Diamond, Cross, X-Cross)
[/list]

[b]Settings[/b]
[list]
[*]Green/red bar definition: [i]close vs previous close[/i] (default) or traditional [i]close vs open[/i]
[*]3-day sequences: max bars allowed between qualifying days (default 2)
[*]Gaps: lookback (default 60), ATR multiple (default 1.5), ATR length (default 14)
[*]MA rule: EMA or SMA, two lengths (default 20/50), respect window (default 30 bars), optional "wait for a bar below the break-bar's low," and a draw-MAs on/off toggle
[/list]

[b]Notes on signal behavior[/b]
[list]
[*]Signals confirm on bar close to avoid repainting.
[*]3-day sequences slide rather than reset, so overlapping patterns all fire — e.g. 4 qualifying bars in a row produce two signals, not one.
[/list]

[b]Alerts[/b]
Two alert conditions are included: [i]Bullish signal[/i] and [i]Bearish signal[/i], each firing when any enabled rule of that type triggers.

[i]This tool is for chart annotation and personal risk management. It is not financial advice — always do your own analysis.[/i]

## Source Code

````pine
//@version=6
// =============================================================================
//  PROFIT PUNCH : SELLING RULES — visual signals for trade execution & risk mgmt
//  Plots customizable signal markers on the chart for a set of bullish /
//  bearish rules. Everything is editable: per-rule name, color, icon, and how
//  many of the most recent signals stay on screen.
//
//  Bullish markers sit BELOW the bar, bearish markers sit ABOVE the bar.
//  Timeframe = whatever the chart is on.  Gap = open vs prior close.
// =============================================================================
indicator("Profit Punch : Selling Rules", overlay = true, max_labels_count = 500)

// Map an icon name (+ direction) to a Pine label style
f_style(s, isBull) =>
    out = isBull ? label.style_label_up : label.style_label_down
    if s == "Arrow"
        out := isBull ? label.style_arrowup : label.style_arrowdown
    else if s == "Triangle"
        out := isBull ? label.style_triangleup : label.style_triangledown
    else if s == "Flag"
        out := label.style_flag
    else if s == "Circle"
        out := label.style_circle
    else if s == "Square"
        out := label.style_square
    else if s == "Diamond"
        out := label.style_diamond
    else if s == "Cross"
        out := label.style_cross
    else if s == "X-Cross"
        out := label.style_xcross
    out

// Map a size name to a Pine size constant (scales both the icon and its text)
f_size(s) =>
    out = size.normal
    if s == "Tiny"
        out := size.tiny
    else if s == "Small"
        out := size.small
    else if s == "Large"
        out := size.large
    else if s == "Huge"
        out := size.huge
    out

// ----------------------------------------------------------------------------
// GLOBAL SETTINGS
// ----------------------------------------------------------------------------
grpG    = "Global"
txtCol  = input.color(color.white, "Label text color", group = grpG)
tradDef = input.bool(false, "Use traditional green/red bars (close vs open)", group = grpG, tooltip = "Off (default): a green bar closes above the PREVIOUS bar's close (and vice-versa for red) — a bar can be 'green' even if it closed below its own open.\nOn: a green bar simply closes above its own open (candle-body color).")

// Green / red bar definition used by the 3-green / 3-red sequence rules
isGreen = tradDef ? close > open : close > close[1]
isRed   = tradDef ? close < open : close < close[1]

grpSeq     = "Day-sequence settings (3 green / 3 red)"
maxBetween = input.int(2, "Max bars allowed between sequence days", minval = 0, group = grpSeq)
winSize    = maxBetween + 1
qualMode   = input.string("Close", "Day 2/3 must close beyond the prior day's", options = ["Close", "Wick"], group = grpSeq, tooltip = "Close (default): day 2 must close above day 1's CLOSE, day 3 above day 2's close (and the mirror for reds). Fires on clean green/red runs.\nWick: the strict original rule — day 2 must close above day 1's full HIGH (wick included), day 3 above day 2's high (mirror = LOW for reds). Fires rarely after volatile, wicky bars.")
useWick    = qualMode == "Wick"

grpGap   = "Gap settings"
gapLook  = input.int(60,    "Gap lookback (bars)",        minval = 1, group = grpGap)
atrMult  = input.float(1.5, "Gap size, in ATR multiples", minval = 0, group = grpGap)
atrLen   = input.int(14,    "ATR length",                 minval = 1, group = grpGap)

// ----------------------------------------------------------------------------
// PER-RULE SETTINGS  (toggle, name, color, icon, max signals shown)
// ----------------------------------------------------------------------------
// Bullish: 3 Green Days
g1 = "Bullish • 3 Green Days"
b1_on   = input.bool(true,        "Enabled",          group = g1, inline = "a")
b1_name = input.string("3G",      "Name",             group = g1, inline = "a")
b1_col  = input.color(color.green,"Color",            group = g1, inline = "b")
b1_icon = input.string("Label",   "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g1, inline = "b")
b1_max  = input.int(3,            "Max signals shown", minval = 1, group = g1)
b1_size = input.string("Normal",  "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g1)

// Bullish: Violation of previous 3 Red Days
g2 = "Bullish • Violation of prev 3 Red Days"
b2_on   = input.bool(true,        "Enabled",          group = g2, inline = "a")
b2_name = input.string("V3R",     "Name",             group = g2, inline = "a")
b2_col  = input.color(color.green,"Color",            group = g2, inline = "b")
b2_icon = input.string("Label",   "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g2, inline = "b")
b2_max  = input.int(3,            "Max signals shown", minval = 1, group = g2)
b2_size = input.string("Normal",  "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g2)

// Bullish: Gap Down Closure
g3 = "Bullish • Gap Down Closure"
b3_on   = input.bool(true,          "Enabled",        group = g3, inline = "a")
b3_name = input.string("Gap Fill",  "Name",           group = g3, inline = "a")
b3_col  = input.color(color.green,  "Color",          group = g3, inline = "b")
b3_icon = input.string("Label",     "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g3, inline = "b")
b3_max  = input.int(3,              "Max signals shown", minval = 1, group = g3)
b3_size = input.string("Normal",    "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g3)

// Bearish: 3 Red Days
g4 = "Bearish • 3 Red Days"
r1_on   = input.bool(true,        "Enabled",          group = g4, inline = "a")
r1_name = input.string("3R",      "Name",             group = g4, inline = "a")
r1_col  = input.color(color.red,  "Color",            group = g4, inline = "b")
r1_icon = input.string("Label",   "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g4, inline = "b")
r1_max  = input.int(3,            "Max signals shown", minval = 1, group = g4)
r1_size = input.string("Normal",  "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g4)

// Bearish: Violation of previous 3 Green Days
g5 = "Bearish • Violation of prev 3 Green Days"
r2_on   = input.bool(true,        "Enabled",          group = g5, inline = "a")
r2_name = input.string("V3G",     "Name",             group = g5, inline = "a")
r2_col  = input.color(color.red,  "Color",            group = g5, inline = "b")
r2_icon = input.string("Label",   "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g5, inline = "b")
r2_max  = input.int(3,            "Max signals shown", minval = 1, group = g5)
r2_size = input.string("Normal",  "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g5)

// Bearish: Gap Up Closure
g6 = "Bearish • Gap Up Closure"
r3_on   = input.bool(true,         "Enabled",         group = g6, inline = "a")
r3_name = input.string("Gap Fill", "Name",            group = g6, inline = "a")
r3_col  = input.color(color.red,   "Color",           group = g6, inline = "b")
r3_icon = input.string("Label",    "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g6, inline = "b")
r3_max  = input.int(3,             "Max signals shown", minval = 1, group = g6)
r3_size = input.string("Normal",   "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g6)

// Bearish: MA1 respected then broken
g7 = "Bearish • MA1 respected then broken"
m1_on   = input.bool(true,        "Enabled",          group = g7, inline = "a")
m1_name = input.string("20 MA",   "Name",             group = g7, inline = "a")
m1_col  = input.color(color.red,  "Color",            group = g7, inline = "b")
m1_icon = input.string("Label",   "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g7, inline = "b")
m1_max  = input.int(3,            "Max signals shown", minval = 1, group = g7)
m1_size = input.string("Normal",  "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g7)

// Bearish: MA2 respected then broken
g8 = "Bearish • MA2 respected then broken"
m2_on   = input.bool(true,        "Enabled",          group = g8, inline = "a")
m2_name = input.string("50 MA",   "Name",             group = g8, inline = "a")
m2_col  = input.color(color.red,  "Color",            group = g8, inline = "b")
m2_icon = input.string("Label",   "Icon", options = ["Label", "Arrow", "Triangle", "Flag", "Circle", "Square", "Diamond", "Cross", "X-Cross"], group = g8, inline = "b")
m2_max  = input.int(3,            "Max signals shown", minval = 1, group = g8)
m2_size = input.string("Normal",  "Marker size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g8)

// ----------------------------------------------------------------------------
// MA TREND RULE settings
// ----------------------------------------------------------------------------
grpM     = "MA trend rule"
drawMAs  = input.bool(true,    "Draw the moving averages on chart", group = grpM)
maType   = input.string("EMA", "MA type", options = ["EMA","SMA"], group = grpM)
ma1len   = input.int(20, "MA 1 length", minval = 1, group = grpM)
ma2len   = input.int(50, "MA 2 length", minval = 1, group = grpM)
maSrc    = input.source(close, "MA source", group = grpM)
respectN = input.int(30, "Bars the MA must be respected", minval = 1, group = grpM)
waitLow  = input.bool(true, "Wait for a bar below the break-bar's low", group = grpM)
ma1Line  = input.color(color.new(color.blue,   40), "MA1 line color", group = grpM)
ma2Line  = input.color(color.new(color.orange, 40), "MA2 line color", group = grpM)

// ----------------------------------------------------------------------------
// LABEL ARRAYS (one per rule -> each rule keeps only its own last N signals)
// ----------------------------------------------------------------------------
var label[] a_b1 = array.new_label()
var label[] a_b2 = array.new_label()
var label[] a_b3 = array.new_label()
var label[] a_r1 = array.new_label()
var label[] a_r2 = array.new_label()
var label[] a_r3 = array.new_label()
var label[] a_m1 = array.new_label()
var label[] a_m2 = array.new_label()

// Create a marker on signal; keep only the last maxN per rule. Confirmed bars only.
plotSig(cond, isBull, txt, col, iconName, szName, arr, maxN) =>
    if cond and barstate.isconfirmed
        st = f_style(iconName, isBull)
        yl = isBull ? yloc.belowbar : yloc.abovebar
        lb = label.new(bar_index, close, txt, yloc = yl, style = st, color = col, textcolor = txtCol, size = f_size(szName))
        array.push(arr, lb)
        if array.size(arr) > maxN
            label.delete(array.shift(arr))

// ----------------------------------------------------------------------------
// 3 GREEN DAY state machine
//   day1 = any green bar ; day2 = close > high(day1) ; day3 = close > high(day2)
//   each step within winSize bars, else the count restarts
// ----------------------------------------------------------------------------
var int   gState = 0
var float g1h = na, var float g1l = na, var float g1c = na, var int g1i = na
var float g2h = na, var float g2l = na, var float g2c = na, var int g2i = na
var float grnViolLvl = na
var bool  grnViolArm = false
green3 = false

// reference each day must close ABOVE = the prior day's high (Wick) or close
gRef1 = useWick ? g1h : g1c
gRef2 = useWick ? g2h : g2c

if gState == 1 and (bar_index - g1i) > winSize
    gState := 0
if gState == 2 and (bar_index - g2i) > winSize
    gState := 0
if gState == 2
    if close > gRef2
        green3 := true
        grnViolLvl := g1l                 // this sequence's day-1 low (for the violation rule)
        grnViolArm := true
        // slide the window so overlapping sequences fire too:
        // old day2 -> new day1, completing bar -> new day2, keep waiting for next day3
        g1h := g2h
        g1l := g2l
        g1c := g2c
        g1i := g2i
        g2h := high
        g2l := low
        g2c := close
        g2i := bar_index
        gState := 2
if gState == 1 and not green3
    if close > gRef1
        g2h := high
        g2l := low
        g2c := close
        g2i := bar_index
        gState := 2
    else if isGreen
        // Day 1 is ANY green bar -> keep it on the MOST RECENT green bar
        // so a stale Day 1 can't block a valid setup that starts later.
        g1h := high
        g1l := low
        g1c := close
        g1i := bar_index
if gState == 0 and not green3
    if isGreen
        g1h := high
        g1l := low
        g1c := close
        g1i := bar_index
        gState := 1

// Violation of previous 3 GREEN days (bearish): close below low of green day1
v3green = false
if grnViolArm and close < grnViolLvl
    v3green := true
    grnViolArm := false

// ----------------------------------------------------------------------------
// 3 RED DAY state machine
//   day1 = any red bar ; day2 = close < low(day1) ; day3 = close < low(day2)
// ----------------------------------------------------------------------------
var int   rState = 0
var float r1h = na, var float r1l = na, var float r1c = na, var int r1i = na
var float r2h = na, var float r2l = na, var float r2c = na, var int r2i = na
var float redViolLvl = na
var bool  redViolArm = false
red3 = false

// reference each day must close BELOW = the prior day's low (Wick) or close
rRef1 = useWick ? r1l : r1c
rRef2 = useWick ? r2l : r2c

if rState == 1 and (bar_index - r1i) > winSize
    rState := 0
if rState == 2 and (bar_index - r2i) > winSize
    rState := 0
if rState == 2
    if close < rRef2
        red3 := true
        redViolLvl := r1h                 // this sequence's day-1 high (for the violation rule)
        redViolArm := true
        // slide the window so overlapping sequences fire too
        r1h := r2h
        r1l := r2l
        r1c := r2c
        r1i := r2i
        r2h := high
        r2l := low
        r2c := close
        r2i := bar_index
        rState := 2
if rState == 1 and not red3
    if close < rRef1
        r2h := high
        r2l := low
        r2c := close
        r2i := bar_index
        rState := 2
    else if isRed
        // Day 1 is ANY red bar -> keep it on the MOST RECENT red bar
        r1h := high
        r1l := low
        r1c := close
        r1i := bar_index
if rState == 0 and not red3
    if isRed
        r1h := high
        r1l := low
        r1c := close
        r1i := bar_index
        rState := 1

// Violation of previous 3 RED days (bullish): close above high of red day1
v3red = false
if redViolArm and close > redViolLvl
    v3red := true
    redViolArm := false

// ----------------------------------------------------------------------------
// GAPS  (gap = open vs prior close) — fire when the gap is filled back to prior close
// ----------------------------------------------------------------------------
atrv = ta.atr(atrLen)

// Gap UP closure -> bearish
var float guLvl = na
var int   guBar = na
gapUpFill = false
if not na(guLvl) and (bar_index - guBar) > gapLook
    guLvl := na
if not na(guLvl) and low <= guLvl
    gapUpFill := true
    guLvl := na
if open > close[1] and (open - close[1]) > atrMult * atrv
    guLvl := close[1]
    guBar := bar_index

// Gap DOWN closure -> bullish
var float gdLvl = na
var int   gdBar = na
gapDownFill = false
if not na(gdLvl) and (bar_index - gdBar) > gapLook
    gdLvl := na
if not na(gdLvl) and high >= gdLvl
    gapDownFill := true
    gdLvl := na
if open < close[1] and (close[1] - open) > atrMult * atrv
    gdLvl := close[1]
    gdBar := bar_index

// ----------------------------------------------------------------------------
// MA "respected then broken" (bearish), applied separately to MA1 and MA2
// ----------------------------------------------------------------------------
f_maBreak(ma, src, n, wait) =>
    var bool  armed  = false
    var float brkLow = na
    sig = false
    respectedBefore = math.sum(src[1] < ma[1] ? 1 : 0, n) == 0
    firstBreak = src < ma and src[1] >= ma[1] and respectedBefore
    if wait
        if armed and src > ma
            armed := false
        if firstBreak
            armed  := true
            brkLow := low
        if armed and low < brkLow
            sig   := true
            armed := false
    else
        sig := firstBreak
    sig

ma1 = maType == "EMA" ? ta.ema(maSrc, ma1len) : ta.sma(maSrc, ma1len)
ma2 = maType == "EMA" ? ta.ema(maSrc, ma2len) : ta.sma(maSrc, ma2len)
sigMa1 = f_maBreak(ma1, maSrc, respectN, waitLow)
sigMa2 = f_maBreak(ma2, maSrc, respectN, waitLow)

plot(drawMAs ? ma1 : na, "MA1", color = ma1Line)
plot(drawMAs ? ma2 : na, "MA2", color = ma2Line)

// ----------------------------------------------------------------------------
// PLOT SIGNALS
// ----------------------------------------------------------------------------
plotSig(b1_on and green3,      true,  b1_name, b1_col, b1_icon, b1_size, a_b1, b1_max)
plotSig(b2_on and v3red,       true,  b2_name, b2_col, b2_icon, b2_size, a_b2, b2_max)
plotSig(b3_on and gapDownFill, true,  b3_name, b3_col, b3_icon, b3_size, a_b3, b3_max)
plotSig(r1_on and red3,        false, r1_name, r1_col, r1_icon, r1_size, a_r1, r1_max)
plotSig(r2_on and v3green,     false, r2_name, r2_col, r2_icon, r2_size, a_r2, r2_max)
plotSig(r3_on and gapUpFill,   false, r3_name, r3_col, r3_icon, r3_size, a_r3, r3_max)
plotSig(m1_on and sigMa1,      false, m1_name, m1_col, m1_icon, m1_size, a_m1, m1_max)
plotSig(m2_on and sigMa2,      false, m2_name, m2_col, m2_icon, m2_size, a_m2, m2_max)

// ----------------------------------------------------------------------------
// ALERTS
// ----------------------------------------------------------------------------
bullAny = (b1_on and green3) or (b2_on and v3red) or (b3_on and gapDownFill)
bearAny = (r1_on and red3) or (r2_on and v3green) or (r3_on and gapUpFill) or (m1_on and sigMa1) or (m2_on and sigMa2)
alertcondition(bullAny, "Bullish signal", "Selling Rules: bullish signal on {{ticker}}")
alertcondition(bearAny, "Bearish signal", "Selling Rules: bearish signal on {{ticker}}")
````
