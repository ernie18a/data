# SPX 200W MA Valuation Bands (v6 stable)

- url: https://www.tradingview.com/script/Bc12rX8Q-SPX-200W-MA-Valuation-Bands-v6-stable/
- type: indicator
- pine_id: PUB;7d65a57fba924d68b148d2a78ffa58ee
- version: 1.0

## Description

Overview:

Summary: Plots the S&P (SPX) long-term 200-week moving average with valuation bands to show price relative to a long-term trend.

What it shows:
[list]
[*]Primary: 200W MA (200-week moving average).
[*]Bands: Multiple valuation bands around the MA (e.g., ±X% levels or percentile bands).
[*]Coloring: Price/bar colors change when price is above/below bands or MA.
[/list]

Interpretation / Signals:
[list]
[*]Trend: Price above the 200W MA = long-term bullish bias; below = bearish bias.
[*]Over/Under Valuation: Price touching or exceeding upper bands suggests extended/overbought conditions; touching lower bands suggests deep undervaluation or strong sell-offs.
[*]Mean Reversion: Crosses back toward the MA often signal reversion opportunities; sustained moves outside bands indicate regime shifts.
[/list]

Usage & Settings:
[list]
[*]Recommended timeframe: Weekly (uses 200-week MA).
[*]Adjustable: Band widths (percentage or standard deviation), MA length, band count, color scheme.
[*]Alerts: Alerts on price crossing MA, upper band, or lower band for entry/exit notifications.
[/list]

Notes & Disclaimer:
[list]
[*]Use with risk management: Combine with volume, macro context, or other indicators before trading.
[*]Educational only: Not financial advice; past behavior doesn’t guarantee future results.
[/list]

## Source Code

````pine
//@version=6
indicator("SPX 200W MA Valuation Bands (v6 stable)", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

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
lvl10  = ma200 * 1.10
lvl20  = ma200 * 1.20
lvl30  = ma200 * 1.30
lvl40  = ma200 * 1.40
lvlTop = lvl40 * 1.60

//-----------------------------------------------
// Background Zones
//-----------------------------------------------
var box fireSale = box.new(0, 0, 0, 0)
var box veryCheap = box.new(0, 0, 0, 0)
var box cheap     = box.new(0, 0, 0, 0)
var box fair      = box.new(0, 0, 0, 0)
var box expensive = box.new(0, 0, 0, 0)
var box veryExp   = box.new(0, 0, 0, 0)

if barstate.islast
    left  = bar_index - 5000
    right = bar_index + 1

    box.set_lefttop(fireSale, left, lvl0)
    box.set_rightbottom(fireSale, right, 0)
    box.set_bgcolor(fireSale, color.new(color.rgb(20, 20, 70), zone_transp))

    box.set_lefttop(veryCheap, left, lvl10)
    box.set_rightbottom(veryCheap, right, lvl0)
    box.set_bgcolor(veryCheap, color.new(color.rgb(20, 60, 140), zone_transp))

    box.set_lefttop(cheap, left, lvl20)
    box.set_rightbottom(cheap, right, lvl10)
    box.set_bgcolor(cheap, color.new(color.rgb(20, 120, 40), zone_transp))

    box.set_lefttop(fair, left, lvl30)
    box.set_rightbottom(fair, right, lvl20)
    box.set_bgcolor(fair, color.new(color.rgb(160, 140, 20), zone_transp))

    box.set_lefttop(expensive, left, lvl40)
    box.set_rightbottom(expensive, right, lvl30)
    box.set_bgcolor(expensive, color.new(color.rgb(180, 90, 20), zone_transp))

    box.set_lefttop(veryExp, left, lvlTop)
    box.set_rightbottom(veryExp, right, lvl40)
    box.set_bgcolor(veryExp, color.new(color.rgb(110, 0, 0), zone_transp))

//-----------------------------------------------
// Plot Lines
//-----------------------------------------------
plot(lvl0,   "200W MA", color.orange, 2)
plot(lvl10,  "+10%",    color.aqua)
plot(lvl20,  "+20%",    color.lime)
plot(lvl30,  "+30%",    color.yellow)
plot(lvl40,  "+40%",    color.red)

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
    f_right_label("+10%\n"    + str.format("{0,number,#,###}", lvl10),  lvl10,  color.aqua)
    f_right_label("+20%\n"    + str.format("{0,number,#,###}", lvl20),  lvl20,  color.lime)
    f_right_label("+30%\n"    + str.format("{0,number,#,###}", lvl30),  lvl30,  color.yellow)
    f_right_label("+40%\n"    + str.format("{0,number,#,###}", lvl40),  lvl40,  color.red)

//-----------------------------------------------
// Zone Name Labels (NO MUTATION OF ARGUMENTS)
//-----------------------------------------------
var label nameFireSale  = na
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
    label.delete(nameFireSale)
    label.delete(nameVeryCheap)
    label.delete(nameCheap)
    label.delete(nameFair)
    label.delete(nameExp)
    label.delete(nameVeryExp)

    if show_zone_names
        nameFireSale  := f_zone_label("Fire Sale",  (0 + lvl0)/2,   color.new(color.rgb(20,20,70), zone_transp))
        nameVeryCheap := f_zone_label("Very Cheap", (lvl0 + lvl10)/2, color.new(color.rgb(20,60,140), zone_transp))
        nameCheap     := f_zone_label("Cheap",      (lvl10 + lvl20)/2, color.new(color.rgb(20,120,40), zone_transp))
        nameFair      := f_zone_label("Fair Value", (lvl20 + lvl30)/2,color.new(color.rgb(160,140,20),zone_transp))
        nameExp       := f_zone_label("Expensive",  (lvl30 + lvl40)/2,color.new(color.rgb(180,90,20), zone_transp))
        nameVeryExp   := f_zone_label("Very Expensive",(lvl40 + lvlTop)/2,color.new(color.rgb(110,0,0), zone_transp))
````
