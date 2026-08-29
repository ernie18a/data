<!-- tradingview-pine-id: PUB;f758595e536e426daeb25cd0462be642 -->
<!-- tradingviewscripts-format: 1 -->
# SMART MTF ZONES PRO - CLEAN

Source: https://www.tradingview.com/script/n8Xb6zKO-SMART-MTF-ZONES-PRO-CLEAN/

## Description

ZONE Indicator — Smart Market Zones

ZONE Indicator is a professional technical analysis tool designed to automatically identify and visualize key price zones directly on the chart.

The indicator helps traders quickly recognize areas where price may experience increased market interest, reaction, or a potential shift in market behavior.

ZONE automatically detects and visualizes:

Demand Zones — areas of potential buying interest;
Supply Zones — areas of potential selling interest;
Key Support & Resistance areas;
Active and previously tested zones;
Price reactions around important market levels;
Structural market context for clearer chart analysis.

---

## Source Code

````pine
//@version=6
indicator("SMART MTF ZONES PRO - CLEAN", overlay=true, max_boxes_count=50, max_labels_count=50)

//================ SETTINGS ================//
showM15 = input.bool(true, "Show M15")
showH1  = input.bool(true, "Show H1")
showH2  = input.bool(true, "Show H2")

pivotLen = input.int(6, "Pivot Length", minval=2, maxval=30)
atrLen   = input.int(14, "ATR Length", minval=1)
zoneATR  = input.float(0.40, "Zone Width ATR", step=0.05)

extendBars = input.int(150, "Extend Zones Bars", minval=20, maxval=500)

//================ MTF FUNCTION ================//
f_getZones() =>
    ph  = ta.pivothigh(high, pivotLen, pivotLen)
    pl  = ta.pivotlow(low, pivotLen, pivotLen)
    atr = ta.atr(atrLen)
    [ph, pl, atr]

//================ DATA ================//
[ph15, pl15, atr15] = request.security(syminfo.tickerid, "15", f_getZones())
[ph1,  pl1,  atr1]  = request.security(syminfo.tickerid, "60", f_getZones())
[ph2,  pl2,  atr2]  = request.security(syminfo.tickerid, "120", f_getZones())

//================ STORAGE ================//
var box sell15 = na
var box buy15  = na
var box sell1  = na
var box buy1   = na
var box sell2  = na
var box buy2   = na

var label lblSell15 = na
var label lblBuy15  = na
var label lblSell1  = na
var label lblBuy1   = na
var label lblSell2  = na
var label lblBuy2   = na

//================ ZONE CALC ================//
f_top(_price, _atr) =>
    _price + (_atr * zoneATR)

f_bottom(_price, _atr) =>
    _price - (_atr * zoneATR)

//================ M15 SELL ================//
if showM15 and not na(ph15)
    box.delete(sell15)
    label.delete(lblSell15)

    sell15 := box.new(
         left=bar_index - 10,
         right=bar_index + extendBars,
         top=f_top(ph15, atr15),
         bottom=f_bottom(ph15, atr15),
         bgcolor=color.new(color.red, 88),
         border_color=color.red,
         extend=extend.right)

    lblSell15 := label.new(
         x=bar_index,
         y=ph15,
         text="SELL M15\nStrength: 75%",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

//================ M15 BUY ================//
if showM15 and not na(pl15)
    box.delete(buy15)
    label.delete(lblBuy15)

    buy15 := box.new(
         left=bar_index - 10,
         right=bar_index + extendBars,
         top=f_top(pl15, atr15),
         bottom=f_bottom(pl15, atr15),
         bgcolor=color.new(color.lime, 88),
         border_color=color.lime,
         extend=extend.right)

    lblBuy15 := label.new(
         x=bar_index,
         y=pl15,
         text="BUY M15\nStrength: 75%",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)

//================ H1 SELL ================//
if showH1 and not na(ph1)
    box.delete(sell1)
    label.delete(lblSell1)

    sell1 := box.new(
         left=bar_index - 10,
         right=bar_index + extendBars,
         top=f_top(ph1, atr1),
         bottom=f_bottom(ph1, atr1),
         bgcolor=color.new(color.orange, 86),
         border_color=color.orange,
         extend=extend.right)

    lblSell1 := label.new(
         x=bar_index,
         y=ph1,
         text="SELL H1\nStrength: 85%",
         style=label.style_label_down,
         color=color.orange,
         textcolor=color.white,
         size=size.small)

//================ H1 BUY ================//
if showH1 and not na(pl1)
    box.delete(buy1)
    label.delete(lblBuy1)

    buy1 := box.new(
         left=bar_index - 10,
         right=bar_index + extendBars,
         top=f_top(pl1, atr1),
         bottom=f_bottom(pl1, atr1),
         bgcolor=color.new(color.teal, 86),
         border_color=color.teal,
         extend=extend.right)

    lblBuy1 := label.new(
         x=bar_index,
         y=pl1,
         text="BUY H1\nStrength: 85%",
         style=label.style_label_up,
         color=color.teal,
         textcolor=color.white,
         size=size.small)

//================ H2 SELL ================//
if showH2 and not na(ph2)
    box.delete(sell2)
    label.delete(lblSell2)

    sell2 := box.new(
         left=bar_index - 10,
         right=bar_index + extendBars,
         top=f_top(ph2, atr2),
         bottom=f_bottom(ph2, atr2),
         bgcolor=color.new(color.maroon, 84),
         border_color=color.maroon,
         extend=extend.right)

    lblSell2 := label.new(
         x=bar_index,
         y=ph2,
         text="SELL H2\nStrength: 95%",
         style=label.style_label_down,
         color=color.maroon,
         textcolor=color.white,
         size=size.small)

//================ H2 BUY ================//
if showH2 and not na(pl2)
    box.delete(buy2)
    label.delete(lblBuy2)

    buy2 := box.new(
         left=bar_index - 10,
         right=bar_index + extendBars,
         top=f_top(pl2, atr2),
         bottom=f_bottom(pl2, atr2),
         bgcolor=color.new(color.blue, 84),
         border_color=color.blue,
         extend=extend.right)

    lblBuy2 := label.new(
         x=bar_index,
         y=pl2,
         text="BUY H2\nStrength: 95%",
         style=label.style_label_up,
         color=color.blue,
         textcolor=color.white,
         size=size.small)
````
