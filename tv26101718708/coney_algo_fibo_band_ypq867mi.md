# Coney Algo - Fibo Band

- url: https://www.tradingview.com/script/YPq867mI-Coney-Algo-Fibo-Band/
- type: indicator
- pine_id: PUB;364783c9799c49d7b265406bed9a1361
- version: 1.0

## Description

Coney Algo - Fibo Band

The concept combine Pivot + Fibo to make a Fibo Band which can see clear maket phase

With 
Support Level at Fibo 0 - 0.236

Resistance Level at Fibo 1 - 0.786

Buy Condition: at Buy Zone Fibo 0 - 0.236, Stoploss Below Fibo 0, Take Profit at Fibo 0.5 - 1

Sell Condition: at Sell Zone Fibo 1 - 0.786, Stoploss Above Fibo 1, Take Profit at Fibo 0.5 - 0

===========================
EA and Pinescript Fulltime Developer
Telegram: @maketradinggreatagain88

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coney Algo - Pivot High/Low Fibonacci Band
// Indicator: Pivot Fibo Band
// Version: 1.0
// Description: Combines ta.pivothigh() and ta.pivotlow() with Fibonacci retracement levels
//              to create dynamic support/resistance bands.

//@version=6
indicator("Coney Algo - Fibo Band", "PFB", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
grp_pivot = "Pivot Settings"
pivotHighLen = input.int(100,  "Pivot High Length", minval=1, group=grp_pivot)
pivotLowLen  = input.int(100,  "Pivot Low Length",  minval=1, group=grp_pivot)

grp_fibo = "Fibonacci Levels"
show_0000 = input.bool(true,  "0.000 (Pivot Low)",   group=grp_fibo)
show_0236 = input.bool(true,  "0.236",                group=grp_fibo)
show_0382 = input.bool(false,  "0.382",                group=grp_fibo)
show_0500 = input.bool(true,  "0.500",                group=grp_fibo)
show_0618 = input.bool(false,  "0.618",                group=grp_fibo)
show_0786 = input.bool(true,  "0.786",                group=grp_fibo)
show_1000 = input.bool(true,  "1.000 (Pivot High)",   group=grp_fibo)

grp_style = "Style"
colorBull     = input.color(color.new(#089981, 0),  "Bull Color (PH)",  group=grp_style)
colorBear     = input.color(color.new(#F23645, 0),  "Bear Color (PL)",  group=grp_style)
colorMid      = input.color(color.new(#d4ff00, 0),  "Mid Color (0.5)",  group=grp_style)
colorFib      = input.color(color.new(#29f1ff, 0),  "Fib Color",        group=grp_style)
lineWidth     = input.int(1, "Line Width", minval=1, maxval=4, group=grp_style)
lineStyle_in  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_style)
showLabels    = input.bool(true, "Show Labels", group=grp_style)
extendLines   = input.bool(true, "Extend Lines Right", group=grp_style)
fillBands     = input.bool(true, "Fill Between Bands", group=grp_style)
fillAlpha     = input.int(90, "Fill Transparency", minval=0, maxval=100, group=grp_style)

// ─── LINE STYLE MAPPING ─────────────────────────────────────────────────────
ls = lineStyle_in == "Dashed" ? line.style_dashed : lineStyle_in == "Dotted" ? line.style_dotted : line.style_solid

// ─── DETECT PIVOTS ───────────────────────────────────────────────────────────
ph = ta.highest(high, pivotHighLen)
pl = ta.lowest(low,   pivotLowLen)

// ─── STATE ───────────────────────────────────────────────────────────────────
var float lastPH = na
var float lastPL = na
var int   phBar  = na
var int   plBar  = na

// Track the latest pivot values
if not na(ph)
    lastPH := ph
    phBar  := bar_index - pivotHighLen

if not na(pl)
    lastPL := pl
    plBar  := bar_index - pivotLowLen

// ─── FIBONACCI CALCULATION ───────────────────────────────────────────────────
// Range = Pivot High - Pivot Low
// Fib level X = Pivot Low + range * X
// So: 0.0 = PL, 0.5 = midpoint, 1.0 = PH

validRange = not na(lastPH) and not na(lastPL) and lastPH > lastPL
rnge      = validRange ? lastPH - lastPL : na

fib_0000 = validRange ? lastPL                     : na  // 0.000
fib_0236 = validRange ? lastPL + rnge * 0.236     : na  // 0.236
fib_0382 = validRange ? lastPL + rnge * 0.382     : na  // 0.382
fib_0500 = validRange ? lastPL + rnge * 0.500     : na  // 0.500
fib_0618 = validRange ? lastPL + rnge * 0.618     : na  // 0.618
fib_0786 = validRange ? lastPL + rnge * 0.786     : na  // 0.786
fib_1000 = validRange ? lastPH                     : na  // 1.000

// ─── PLOTS ───────────────────────────────────────────────────────────────────
p0000 = plot(show_0000 ? fib_0000 : na, "Fib 0.000 (PL)", colorBear,  lineWidth, style=plot.style_line,force_overlay = true)
p0236 = plot(show_0236 ? fib_0236 : na, "Fib 0.236",      colorFib,   lineWidth, style=plot.style_line,force_overlay = true)
p0382 = plot(show_0382 ? fib_0382 : na, "Fib 0.382",      colorFib,   lineWidth, style=plot.style_line,force_overlay = true)
p0500 = plot(show_0500 ? fib_0500 : na, "Fib 0.500",      colorMid,   lineWidth, style=plot.style_line,force_overlay = true)
p0618 = plot(show_0618 ? fib_0618 : na, "Fib 0.618",      colorFib,   lineWidth, style=plot.style_line,force_overlay = true)
p0786 = plot(show_0786 ? fib_0786 : na, "Fib 0.786",      colorFib,   lineWidth, style=plot.style_line,force_overlay = true)
p1000 = plot(show_1000 ? fib_1000 : na, "Fib 1.000 (PH)", colorBull,  lineWidth, style=plot.style_line,force_overlay = true)



// ─── PIVOT MARKERS ───────────────────────────────────────────────────────────
//plotshape(not na(ph), "Pivot High", shape.triangledown, location.abovebar, colorBull, offset=-pivotHighLen, size=size.tiny,force_overlay = true)
//plotshape(not na(pl), "Pivot Low",  shape.triangleup,   location.belowbar, colorBear, offset=-pivotLowLen,  size=size.tiny,force_overlay = true)

// ─── LABELS ON LAST BAR ─────────────────────────────────────────────────────

var label lbl_0000 = na
var label lbl_0236 = na
var label lbl_0382 = na
var label lbl_0500 = na
var label lbl_0618 = na
var label lbl_0786 = na
var label lbl_1000 = na

label.delete(lbl_0000)
label.delete(lbl_0236)
label.delete(lbl_0382)
label.delete(lbl_0500)
label.delete(lbl_0618)
label.delete(lbl_0786)
label.delete(lbl_1000)
if showLabels and barstate.islast and validRange
    labelX = bar_index + 3

    if show_0000
        lbl_0000 := label.new(labelX, fib_0000, "0.000 (" + str.tostring(fib_0000, format.mintick) + ")", color = colorBear, style=label.style_label_left, textcolor=#000000, size=size.small, force_overlay=true)
    if show_0236
        lbl_0236 := label.new(labelX, fib_0236, "0.236 (" + str.tostring(fib_0236, format.mintick) + ")", color = colorFib,  style=label.style_label_left, textcolor=#000000,  size=size.small, force_overlay=true)
    if show_0382
        lbl_0382 := label.new(labelX, fib_0382, "0.382 (" + str.tostring(fib_0382, format.mintick) + ")", color = colorFib,  style=label.style_label_left, textcolor=#000000,  size=size.small, force_overlay=true)
    if show_0500
        lbl_0500 := label.new(labelX, fib_0500, "0.500 (" + str.tostring(fib_0500, format.mintick) + ")", color = colorMid,  style=label.style_label_left, textcolor=#000000,  size=size.small, force_overlay=true)
    if show_0618
        lbl_0618 := label.new(labelX, fib_0618, "0.618 (" + str.tostring(fib_0618, format.mintick) + ")", color = colorFib,  style=label.style_label_left, textcolor=#000000,  size=size.small, force_overlay=true)
    if show_0786
        lbl_0786 := label.new(labelX, fib_0786, "0.786 (" + str.tostring(fib_0786, format.mintick) + ")", color = colorFib,  style=label.style_label_left, textcolor=#000000,  size=size.small, force_overlay=true)
    if show_1000
        lbl_1000 := label.new(labelX, fib_1000, "1.000 (" + str.tostring(fib_1000, format.mintick) + ")", color = colorBull,  style=label.style_label_left, textcolor=#000000, size=size.small, force_overlay=true)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(not na(ph), "New Pivot High", "Pivot High detected at {{close}}")
alertcondition(not na(pl), "New Pivot Low",  "Pivot Low detected at {{close}}")
alertcondition(ta.crossover(close, fib_0500),  "Cross Above 0.5 Fib", "Price crossed above 50% Fib level")
alertcondition(ta.crossunder(close, fib_0500), "Cross Below 0.5 Fib", "Price crossed below 50% Fib level")

var logo = table.new(position.bottom_right, 2, 3, 
     border_color = color.new(color.gray, 50), 
     frame_color = color.new(color.gray, 50), 
     frame_width = 1, 
     border_width = 1)
if barstate.islast
    
    table.cell(logo, 0, 0, "⚡ CONEY ALGO ⚡", 
         bgcolor = #00000000,       
         text_color = #089981,                 
         text_size = size.normal,                   
         text_halign = text.align_center)              
    table.cell(logo, 1, 0, "@maketradinggreatagain88", 
         bgcolor = #00000000,       
         text_color = #089981,                 
         text_size = size.normal,                   
         text_halign = text.align_center)
````
