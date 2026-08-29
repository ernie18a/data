<!-- tradingview-pine-id: PUB;c77d1f014515450d81438f60685866bb -->
<!-- tradingviewscripts-format: 1 -->
# Session Ranges

Source: https://www.tradingview.com/script/dvEBWPWa-Asian-London-and-Newyork-Session-Ranges/

## Description

indicator marks the ASIAN, LONDON , NEWYORK Session  and extends the level .. so you can see where the level is

---

## Source Code

````pine
//@version=6
indicator("Session Ranges", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================================
// INPUTS  (all times are IST — India Standard Time)
// ============================================================================
tz         = input.string("Asia/Kolkata", "Timezone (all sessions)", group="Sessions")
asianSess  = input.session("0530-1330", "Asian Session",     group="Sessions")
londonSess = input.session("1230-2030", "London Session",    group="Sessions")
nySess     = input.session("1730-0130", "New York Session",  group="Sessions")

showBox    = input.bool(true, "Show Range Box",           group="Display")
showLevels = input.bool(true, "Show High/Low Lines",      group="Display")
showLabels = input.bool(true, "Show High/Low Price Labels", group="Display")

asianFill  = input.color(color.new(color.blue, 90),   "Asian Fill",    group="Colors")
asianBord  = input.color(color.blue,                  "Asian Border",  group="Colors")
londonFill = input.color(color.new(color.orange, 90), "London Fill",   group="Colors")
londonBord = input.color(color.orange,                "London Border", group="Colors")
nyFill     = input.color(color.new(color.red, 90),    "NY Fill",       group="Colors")
nyBord     = input.color(color.red,                   "NY Border",     group="Colors")

lineWidth  = input.int(1, "Line Width", minval=1, maxval=5, group="Lines")
styleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Lines")
lineStyleVal = styleInput == "Solid" ? line.style_solid : styleInput == "Dotted" ? line.style_dotted : line.style_dashed

// ============================================================================
// STATE
// ============================================================================
var box   aBox = na
var line  aHi = na
var line  aLo = na
var label aHiLab = na
var label aLoLab = na
var float aHigh = na
var float aLow = na
var int   aStart = na

var box   lBox = na
var line  lHi = na
var line  lLo = na
var label lHiLab = na
var label lLoLab = na
var float lHigh = na
var float lLow = na
var int   lStart = na

var box   nBox = na
var line  nHi = na
var line  nLo = na
var label nHiLab = na
var label nLoLab = na
var float nHigh = na
var float nLow = na
var int   nStart = na

// ============================================================================
// SESSION FLAGS
// ============================================================================
inAsian  = not na(time(timeframe.period, asianSess, tz))
inLondon = not na(time(timeframe.period, londonSess, tz))
inNY     = not na(time(timeframe.period, nySess, tz))

var bool prevAsian  = false
var bool prevLondon = false
var bool prevNY     = false

startAsian  = inAsian  and not prevAsian
startLondon = inLondon and not prevLondon
startNY     = inNY     and not prevNY

prevAsian  := inAsian
prevLondon := inLondon
prevNY     := inNY

// ============================================================================
// ASIAN SESSION
// ============================================================================
if inAsian
    if startAsian
        if not na(aBox)
            box.delete(aBox)
        if not na(aHi)
            line.delete(aHi)
        if not na(aLo)
            line.delete(aLo)
        if not na(aHiLab)
            label.delete(aHiLab)
        if not na(aLoLab)
            label.delete(aLoLab)
        aHigh := high
        aLow := low
        aStart := bar_index
        if showBox
            aBox := box.new(aStart, aHigh, bar_index, aLow, bgcolor=asianFill, border_color=asianBord, border_width=1)
        if showLevels
            aHi := line.new(aStart, aHigh, bar_index, aHigh, color=asianBord, width=lineWidth, style=lineStyleVal)
            aLo := line.new(aStart, aLow, bar_index, aLow, color=asianBord, width=lineWidth, style=lineStyleVal)
        if showLabels
            aHiLab := label.new(bar_index, aHigh, "Asia H " + str.tostring(aHigh, format.mintick), style=label.style_none, textcolor=asianBord, size=size.small)
            aLoLab := label.new(bar_index, aLow, "Asia L " + str.tostring(aLow, format.mintick), style=label.style_none, textcolor=asianBord, size=size.small)
    else
        aHigh := math.max(aHigh, high)
        aLow := math.min(aLow, low)
        if not na(aBox)
            box.set_top(aBox, aHigh)
            box.set_bottom(aBox, aLow)
            box.set_right(aBox, bar_index)
        if not na(aHi)
            line.set_y1(aHi, aHigh)
            line.set_xy2(aHi, bar_index, aHigh)
        if not na(aLo)
            line.set_y1(aLo, aLow)
            line.set_xy2(aLo, bar_index, aLow)
else
    if not na(aHi)
        line.set_extend(aHi, extend.right)
    if not na(aLo)
        line.set_extend(aLo, extend.right)

if not na(aHiLab)
    label.set_xy(aHiLab, bar_index, aHigh)
    label.set_text(aHiLab, "Asia H " + str.tostring(aHigh, format.mintick))
if not na(aLoLab)
    label.set_xy(aLoLab, bar_index, aLow)
    label.set_text(aLoLab, "Asia L " + str.tostring(aLow, format.mintick))

// ============================================================================
// LONDON SESSION
// ============================================================================
if inLondon
    if startLondon
        if not na(lBox)
            box.delete(lBox)
        if not na(lHi)
            line.delete(lHi)
        if not na(lLo)
            line.delete(lLo)
        if not na(lHiLab)
            label.delete(lHiLab)
        if not na(lLoLab)
            label.delete(lLoLab)
        lHigh := high
        lLow := low
        lStart := bar_index
        if showBox
            lBox := box.new(lStart, lHigh, bar_index, lLow, bgcolor=londonFill, border_color=londonBord, border_width=1)
        if showLevels
            lHi := line.new(lStart, lHigh, bar_index, lHigh, color=londonBord, width=lineWidth, style=lineStyleVal)
            lLo := line.new(lStart, lLow, bar_index, lLow, color=londonBord, width=lineWidth, style=lineStyleVal)
        if showLabels
            lHiLab := label.new(bar_index, lHigh, "London H " + str.tostring(lHigh, format.mintick), style=label.style_none, textcolor=londonBord, size=size.small)
            lLoLab := label.new(bar_index, lLow, "London L " + str.tostring(lLow, format.mintick), style=label.style_none, textcolor=londonBord, size=size.small)
    else
        lHigh := math.max(lHigh, high)
        lLow := math.min(lLow, low)
        if not na(lBox)
            box.set_top(lBox, lHigh)
            box.set_bottom(lBox, lLow)
            box.set_right(lBox, bar_index)
        if not na(lHi)
            line.set_y1(lHi, lHigh)
            line.set_xy2(lHi, bar_index, lHigh)
        if not na(lLo)
            line.set_y1(lLo, lLow)
            line.set_xy2(lLo, bar_index, lLow)
else
    if not na(lHi)
        line.set_extend(lHi, extend.right)
    if not na(lLo)
        line.set_extend(lLo, extend.right)

if not na(lHiLab)
    label.set_xy(lHiLab, bar_index, lHigh)
    label.set_text(lHiLab, "London H " + str.tostring(lHigh, format.mintick))
if not na(lLoLab)
    label.set_xy(lLoLab, bar_index, lLow)
    label.set_text(lLoLab, "London L " + str.tostring(lLow, format.mintick))

// ============================================================================
// NEW YORK SESSION
// ============================================================================
if inNY
    if startNY
        if not na(nBox)
            box.delete(nBox)
        if not na(nHi)
            line.delete(nHi)
        if not na(nLo)
            line.delete(nLo)
        if not na(nHiLab)
            label.delete(nHiLab)
        if not na(nLoLab)
            label.delete(nLoLab)
        nHigh := high
        nLow := low
        nStart := bar_index
        if showBox
            nBox := box.new(nStart, nHigh, bar_index, nLow, bgcolor=nyFill, border_color=nyBord, border_width=1)
        if showLevels
            nHi := line.new(nStart, nHigh, bar_index, nHigh, color=nyBord, width=lineWidth, style=lineStyleVal)
            nLo := line.new(nStart, nLow, bar_index, nLow, color=nyBord, width=lineWidth, style=lineStyleVal)
        if showLabels
            nHiLab := label.new(bar_index, nHigh, "NY H " + str.tostring(nHigh, format.mintick), style=label.style_none, textcolor=nyBord, size=size.small)
            nLoLab := label.new(bar_index, nLow, "NY L " + str.tostring(nLow, format.mintick), style=label.style_none, textcolor=nyBord, size=size.small)
    else
        nHigh := math.max(nHigh, high)
        nLow := math.min(nLow, low)
        if not na(nBox)
            box.set_top(nBox, nHigh)
            box.set_bottom(nBox, nLow)
            box.set_right(nBox, bar_index)
        if not na(nHi)
            line.set_y1(nHi, nHigh)
            line.set_xy2(nHi, bar_index, nHigh)
        if not na(nLo)
            line.set_y1(nLo, nLow)
            line.set_xy2(nLo, bar_index, nLow)
else
    if not na(nHi)
        line.set_extend(nHi, extend.right)
    if not na(nLo)
        line.set_extend(nLo, extend.right)

if not na(nHiLab)
    label.set_xy(nHiLab, bar_index, nHigh)
    label.set_text(nHiLab, "NY H " + str.tostring(nHigh, format.mintick))
if not na(nLoLab)
    label.set_xy(nLoLab, bar_index, nLow)
    label.set_text(nLoLab, "NY L " + str.tostring(nLow, format.mintick))
````
