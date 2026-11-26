# BTC 200W MA Valuation Bands (v6 stable)

- url: https://www.tradingview.com/script/k6sJMP2D-BTC-200W-MA-Valuation-Bands-v6-stable/
- type: indicator
- pine_id: PUB;3f33da7948e14c999914a90989b83a15
- version: 1.0

## Description

A TradingView Pine Script indicator that overlays Bitcoin’s 200-week moving average with dynamic valuation bands and validates price ranges against expected long-term trend levels. This version includes:

200W MA trend baseline
Upper/lower valuation bands for overbought/oversold zones
Price-range validation to highlight when BTC is trading inside, near, or beyond structural range boundaries
Clean visual display for macro BTC market cycles
Stable v6 implementation for reliability and performance
Use this for macro-level BTC valuation analysis and spotting extended momentum swings with range validation.

## Source Code

````pine
//@version=6
indicator("BTC 200W MA Valuation Bands (v6 stable)", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

//-----------------------------------------------
// Inputs
//-----------------------------------------------
zone_transp = input.int(85, "Zone Transparency (0 = solid, 100 = invisible)", minval=0, maxval=100)
show_zone_names = input.bool(true, "Show Zone Labels")

//-----------------------------------------------
// Weekly 200 MA
//-----------------------------------------------
ma200 = request.security(syminfo.tickerid, "W", ta.sma(close, 200))

lvl0   = ma200
lvl50  = ma200 * 1.50
lvl100 = ma200 * 2.00
lvl150 = ma200 * 2.50
lvlTop = lvl150 * 1.60

//-----------------------------------------------
// Background Zones
//-----------------------------------------------
var box veryCheap = box.new(0, 0, 0, 0)
var box cheap     = box.new(0, 0, 0, 0)
var box fair      = box.new(0, 0, 0, 0)
var box expensive = box.new(0, 0, 0, 0)
var box veryExp   = box.new(0, 0, 0, 0)

if barstate.islast
    left  = bar_index - 5000
    right = bar_index + 1

    box.set_lefttop(veryCheap, left, lvl0)
    box.set_rightbottom(veryCheap, right, 0)
    box.set_bgcolor(veryCheap, color.new(color.rgb(10, 35, 90), zone_transp))

    box.set_lefttop(cheap, left, lvl50)
    box.set_rightbottom(cheap, right, lvl0)
    box.set_bgcolor(cheap, color.new(color.rgb(20, 120, 40), zone_transp))

    box.set_lefttop(fair, left, lvl100)
    box.set_rightbottom(fair, right, lvl50)
    box.set_bgcolor(fair, color.new(color.rgb(160, 140, 20), zone_transp))

    box.set_lefttop(expensive, left, lvl150)
    box.set_rightbottom(expensive, right, lvl100)
    box.set_bgcolor(expensive, color.new(color.rgb(145, 90, 20), zone_transp))

    box.set_lefttop(veryExp, left, lvlTop)
    box.set_rightbottom(veryExp, right, lvl150)
    box.set_bgcolor(veryExp, color.new(color.rgb(110, 0, 0), zone_transp))

//-----------------------------------------------
// Plot Lines
//-----------------------------------------------
plot(lvl0,   "200W MA", color.orange, 2)
plot(lvl50,  "+50%",    color.green)
plot(lvl100, "+100%",   color.blue)
plot(lvl150, "+150%",   color.red)

//-----------------------------------------------
// Price Labels on the right
//-----------------------------------------------
f_right_label(txt, y, col) =>
    label.new(
        x = bar_index + 1,
        y = y,
        text = txt,
        style = label.style_label_right,
        color = col,
        textcolor = color.white,
        size = size.small
    )

if barstate.islast
    f_right_label("200W MA\n" + str.format("{0,number,#,###}", lvl0),   lvl0,   color.orange)
    f_right_label("+50%\n"    + str.format("{0,number,#,###}", lvl50),  lvl50,  color.green)
    f_right_label("+100%\n"   + str.format("{0,number,#,###}", lvl100), lvl100, color.blue)
    f_right_label("+150%\n"   + str.format("{0,number,#,###}", lvl150), lvl150, color.red)

//-----------------------------------------------
// Zone Name Labels (NO MUTATION OF ARGUMENTS)
//-----------------------------------------------
var label nameVeryCheap = na
var label nameCheap     = na
var label nameFair      = na
var label nameExp       = na
var label nameVeryExp   = na

f_zone_label(txt, y, bg) =>
    label.new(
        x = bar_index + 2,
        y = y,
        text = txt,
        xloc = xloc.bar_index,
        style = label.style_label_right,
        color = bg,
        textcolor = color.white,
        size = size.normal
    )

if barstate.islast
    // Delete old labels
    label.delete(nameVeryCheap)
    label.delete(nameCheap)
    label.delete(nameFair)
    label.delete(nameExp)
    label.delete(nameVeryExp)

    if show_zone_names
        nameVeryCheap := f_zone_label("Very Cheap", (0 + lvl0)/2,     color.new(color.rgb(10,35,90), zone_transp))
        nameCheap     := f_zone_label("Cheap",      (lvl0 + lvl50)/2, color.new(color.rgb(20,120,40), zone_transp))
        nameFair      := f_zone_label("Fair Value", (lvl50 + lvl100)/2,color.new(color.rgb(160,140,20),zone_transp))
        nameExp       := f_zone_label("Expensive",  (lvl100+lvl150)/2,color.new(color.rgb(145,90,20), zone_transp))
        nameVeryExp   := f_zone_label("Very Expensive",(lvl150+lvlTop)/2,color.new(color.rgb(110,0,0), zone_transp))
````
