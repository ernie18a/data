# Thrust Counter Higherhighs Lowerlows with SR references

- url: https://www.tradingview.com/script/72g0uZiT-Thrust-Counter-Higherhighs-Lowerlows-with-SR-references/
- type: indicator
- pine_id: PUB;d8d2e837bc184c498f82d3e84ac4bf66
- version: 1.0

## Description

This is a take I have on somethig I read about Larry Williams where I believe he said that after 30 years the only thing you can count is on peaks of highs or peaks of lows being at counts of 3, where they may represent potential reversal areas. nothing else comes close to that. If you see something moving further. well you have a trend friend. this was coded with claude after a bunch of trial and errors. and I added potential lines of support and resistance where they can be read even at lower time frames. for recreational purposes only.

## Source Code

````pine
//@version=6
// =====================================================================
//  Thrust Counter ZigZag Semafor
// ---------------------------------------------------------------------
//  Built from "[RS] 3 Level ZigZag Semafor" swing-detection logic.
//
//  WHAT IT DOES
//  ------------
//  It follows the thrusts (swing peaks) detected by the zigzag and keeps
//  a running count:
//
//    UP-COUNT  (printed ABOVE the bar, green)
//      * every NEW HIGHER HIGH advances the count: +1, +2, +3 ...
//      * a lower-high or flat high prints nothing (count is held)
//
//    DOWN-COUNT (printed BELOW the bar, red)
//      * every NEW LOWER LOW advances the count: -1, -2, -3 ...
//      * a higher-low or flat low prints nothing (count is held)
//
//  The two counters run independently, exactly mirroring each other.
//  Numbers are drawn as solid high-contrast labels so they pop on the
//  chart.
// =====================================================================

indicator(title="Thrust Counter ZigZag Semafor", shorttitle="ThrustCount",
     overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=1000)

// ─── Inputs ──────────────────────────────────────────────────────────
showZigZag  = input.bool(false, title="Show ZigZag line")
zzColor     = input.color(color.new(color.gray, 0), title="ZigZag line color")
resetOnFail = input.bool(true,  title="Reset count on a failed thrust (keeps numbers small: +1,+2,+3…)")
labelSize   = input.string("large", title="Label size", options=["small","normal","large","huge"])
numStyle    = input.string("Circle", title="Number style", options=["Circle","Box"])

// ─── Support / Resistance from pivots (Higher High / Lower Low) ──────
showsupres   = input.bool(true,  title="Show Support/Resistance", group="Support/Resistance")
lb           = input.int(3,      title="Left Bars",  minval=1, group="Support/Resistance")
rb           = input.int(3,      title="Right Bars", minval=1, group="Support/Resistance")
supcol       = input.color(color.blue,    title="Support color",    group="Support/Resistance")
rescol       = input.color(#ff8c00,       title="Resistance color", group="Support/Resistance")
srStyleIn    = input.string("Solid", title="Line Style", options=["Solid","Dashed","Dotted"], group="Support/Resistance")
srlinestyle  = srStyleIn == "Solid" ? line.style_solid : srStyleIn == "Dashed" ? line.style_dashed : line.style_dotted
srlinewidth  = input.int(3,      title="Line Width", minval=1, maxval=5, group="Support/Resistance")
showHLlabels = input.bool(true,  title="Show HH/HL/LH/LL labels", group="Support/Resistance")

posBg  = input.color(color.new(#00b140, 0), title="Up-count  background")
posTxt = input.color(color.white,           title="Up-count  text")
negBg  = input.color(color.new(#e10600, 0), title="Down-count background")
negTxt = input.color(color.white,           title="Down-count text")

szSel = labelSize == "small" ? size.small : labelSize == "normal" ? size.normal : labelSize == "huge" ? size.huge : size.large

// ─── ZigZag swing detection (original reversal logic) ────────────────
isUp   = close >= open
isDown = close <= open

// direction: -1 after an up→down flip, +1 after a down→up flip
var int direction = 0
direction := isUp[1] and isDown ? -1 : isDown[1] and isUp ? 1 : direction

// A swing HIGH = previous bar up, this bar down (and we weren't already down)
// A swing LOW  = previous bar down, this bar up  (and we weren't already up)
swingHigh = isUp[1]   and isDown and direction[1] != -1 ? high : na
swingLow  = isDown[1] and isUp   and direction[1] !=  1 ? low  : na

// ─── Thrust counting ─────────────────────────────────────────────────
var float lastHigh = na     // most recent swing-high price (reference)
var float lastLow  = na     // most recent swing-low  price (reference)
var int   posCount = 0      // running up-count
var int   negCount = 0      // running down-count

showPos = false
showNeg = false

// ---- UP side : count higher highs ----
if not na(swingHigh)
    if na(lastHigh)
        posCount := 1                 // first swing high starts the sequence
        showPos  := true
    else if swingHigh > lastHigh
        posCount += 1                 // a genuine HIGHER HIGH -> advance
        showPos  := true
    else
        if resetOnFail
            posCount := 0             // failed thrust -> optional reset
        // (otherwise: count nothing, hold the value)
    lastHigh := swingHigh             // reference is always the latest peak

// ---- DOWN side : count lower lows ----
if not na(swingLow)
    if na(lastLow)
        negCount := -1                // first swing low starts the sequence
        showNeg  := true
    else if swingLow < lastLow
        negCount -= 1                 // a genuine LOWER LOW -> advance
        showNeg  := true
    else
        if resetOnFail
            negCount := 0             // failed thrust -> optional reset
        // (otherwise: count nothing, hold the value)
    lastLow := swingLow

// ─── Helper: circled-number glyph (digit sits INSIDE the circle) ─────
circleGlyph(int n) =>
    a = math.abs(n)
    switch a
        1  => "①"
        2  => "②"
        3  => "③"
        4  => "④"
        5  => "⑤"
        6  => "⑥"
        7  => "⑦"
        8  => "⑧"
        9  => "⑨"
        10 => "⑩"
        11 => "⑪"
        12 => "⑫"
        13 => "⑬"
        14 => "⑭"
        15 => "⑮"
        16 => "⑯"
        17 => "⑰"
        18 => "⑱"
        19 => "⑲"
        20 => "⑳"
        => str.tostring(a)     // 21+ : plain number fallback

// ─── Labels (bold, high-contrast) ────────────────────────────────────
useCircle = numStyle == "Circle"

if showPos
    label.new(bar_index, high,
         text     = useCircle ? circleGlyph(posCount) : "+" + str.tostring(posCount),
         yloc     = yloc.abovebar,
         style    = useCircle ? label.style_none : label.style_label_down,
         color    = useCircle ? color.new(color.white, 100) : posBg,
         textcolor= useCircle ? posBg : posTxt,
         size     = szSel)

if showNeg
    label.new(bar_index, low,
         text     = useCircle ? circleGlyph(negCount) : str.tostring(negCount),
         yloc     = yloc.belowbar,
         style    = useCircle ? label.style_none : label.style_label_up,
         color    = useCircle ? color.new(color.white, 100) : negBg,
         textcolor= useCircle ? negBg : negTxt,
         size     = szSel)

// ─── ZigZag connecting line (optional) ───────────────────────────────
var int   prevBar = na
var float prevPx  = na
newSwing = not na(swingHigh) or not na(swingLow)
curPx    = not na(swingHigh) ? swingHigh : swingLow

if newSwing
    if showZigZag and not na(prevBar)
        line.new(prevBar, prevPx, bar_index, curPx, color=zzColor, width=2)
    prevBar := bar_index
    prevPx  := curPx

// ─── Support / Resistance via pivots (Higher High / Lower Low) ───────
ph = ta.pivothigh(lb, rb)
pl = ta.pivotlow(lb, rb)

hl = not na(ph) ? 1 : not na(pl) ? -1 : na          // trend direction at the pivot
zz = not na(ph) ? ph : not na(pl) ? pl : na         // zigzag-style point (may have repeats)
zz := not na(pl) and hl == -1 and ta.valuewhen(not na(hl), hl, 1) == -1 and pl > ta.valuewhen(not na(zz), zz, 1) ? na : zz
zz := not na(ph) and hl == 1  and ta.valuewhen(not na(hl), hl, 1) == 1  and ph < ta.valuewhen(not na(zz), zz, 1) ? na : zz

hl := hl == -1 and ta.valuewhen(not na(hl), hl, 1) == 1  and zz > ta.valuewhen(not na(zz), zz, 1) ? na : hl
hl := hl == 1  and ta.valuewhen(not na(hl), hl, 1) == -1 and zz < ta.valuewhen(not na(zz), zz, 1) ? na : hl
zz := na(hl) ? na : zz

findprevious() =>     // finds the previous four pivot points (loc1..loc4)
    ehl = hl == 1 ? -1 : 1
    float loc1 = 0.0
    float loc2 = 0.0
    float loc3 = 0.0
    float loc4 = 0.0
    int xx = 0
    for x = 1 to 1000
        if hl[x] == ehl and not na(zz[x])
            loc1 := zz[x]
            xx := x + 1
            break
    ehl := hl
    for x = xx to 1000
        if hl[x] == ehl and not na(zz[x])
            loc2 := zz[x]
            xx := x + 1
            break
    ehl := hl == 1 ? -1 : 1
    for x = xx to 1000
        if hl[x] == ehl and not na(zz[x])
            loc3 := zz[x]
            xx := x + 1
            break
    ehl := hl
    for x = xx to 1000
        if hl[x] == ehl and not na(zz[x])
            loc4 := zz[x]
            break
    [loc1, loc2, loc3, loc4]

float a = na
float b = na
float c = na
float d = na
float e = na
if not na(hl)
    [loc1, loc2, loc3, loc4] = findprevious()
    a := zz
    b := loc1
    c := loc2
    d := loc3
    e := loc4

_hh = not na(zz) and (a > b and a > c and c > b and c > d)
_ll = not na(zz) and (a < b and a < c and c < b and c < d)
_hl = not na(zz) and ((a >= c and (b > c and b > d and d > c and d > e)) or (a < b and a > c and b < d))
_lh = not na(zz) and ((a <= c and (b < c and b < d and d < c and d < e)) or (a > b and a < c and b > d))

plotshape(showHLlabels and _hl, text="HL", title="Higher Low",  style=shape.labelup,   color=color.lime, textcolor=color.black, location=location.belowbar, offset=-rb)
plotshape(showHLlabels and _hh, text="HH", title="Higher High", style=shape.labeldown, color=color.lime, textcolor=color.black, location=location.abovebar, offset=-rb)
plotshape(showHLlabels and _ll, text="LL", title="Lower Low",   style=shape.labelup,   color=color.red,  textcolor=color.white, location=location.belowbar, offset=-rb)
plotshape(showHLlabels and _lh, text="LH", title="Lower High",  style=shape.labeldown, color=color.red,  textcolor=color.white, location=location.abovebar, offset=-rb)

float res = na
float sup = na
res := _lh ? zz : res[1]
sup := _hl ? zz : sup[1]

int trend = na
trend := close > res ? 1 : close < sup ? -1 : nz(trend[1])

res := (trend == 1 and _hh) or (trend == -1 and _lh) ? zz : res
sup := (trend == 1 and _hl) or (trend == -1 and _ll) ? zz : sup
rechange = res != res[1]
suchange = sup != sup[1]

var line resline = na
var line supline = na
if showsupres
    if rechange
        if not na(resline)
            line.set_x2(resline, bar_index)
            line.set_extend(resline, extend.none)
        resline := line.new(bar_index - rb, res, bar_index, res, color=rescol, extend=extend.right, style=srlinestyle, width=srlinewidth)
    if suchange
        if not na(supline)
            line.set_x2(supline, bar_index)
            line.set_extend(supline, extend.none)
        supline := line.new(bar_index - rb, sup, bar_index, sup, color=supcol, extend=extend.right, style=srlinestyle, width=srlinewidth)

// ─── Alerts ──────────────────────────────────────────────────────────
alertcondition(showPos, title="New up-thrust (higher high)", message="New higher-high thrust counted")
alertcondition(showNeg, title="New down-thrust (lower low)", message="New lower-low thrust counted")
````
