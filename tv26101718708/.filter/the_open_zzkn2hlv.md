# The Open

- url: https://www.tradingview.com/script/ZzKN2HLV-The-Open/
- type: indicator
- pine_id: PUB;c28301dadda942a7b9346e0fb610ecc6
- version: 1.0

## Description

Range Strategy For The Boys. Limit it. Its making me type a description before publishing ts

## Source Code

````pine
//@version=5
indicator("MNQ ORB Scalper", overlay=true)

// === SETTINGS ===
pointTarget = input.float(10.0, title="Target Points", step=0.25)
showLabels  = input.bool(true, title="Show Labels")

// === TIME (New York) ===
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

is829 = (nyHour == 9 and nyMinute == 29)
is830 = (nyHour == 9 and nyMinute == 30)

// === VARIABLES ===
var float lockedPrice = na
var bool  locked      = false
var label lbBuy       = na
var label lbSell      = na
var label lbBuyTP     = na
var label lbSellTP    = na

// Reset each new session
if ta.change(time("D"))
    lockedPrice := na
    locked      := false

// === LIVE PRICE DURING 9:29 ===
livePrice = close

buyStop  = livePrice + pointTarget
sellStop = livePrice - pointTarget

// Lock at 9:30
if is830 and not locked
    lockedPrice := close[1]
    locked      := true

finalBuy    = locked ? lockedPrice + pointTarget : buyStop
finalSell   = locked ? lockedPrice - pointTarget : sellStop

// === PLOTS ===
plot((is829 or is830 or locked) ? finalBuy  : na, title="Buy Stop",  color=color.lime,   linewidth=2, style=plot.style_linebr)
plot((is829 or is830 or locked) ? finalSell : na, title="Sell Stop", color=color.red,    linewidth=2, style=plot.style_linebr)

// === LIVE LABELS DURING 9:29 ===
if is829 and showLabels
    if not na(lbBuy)
        label.delete(lbBuy)
    if not na(lbSell)
        label.delete(lbSell)
    lbBuy  := label.new(bar_index, finalBuy,  "BUY: "  + str.tostring(finalBuy,  "#.00"), color=color.lime, textcolor=color.black, style=label.style_label_left, size=size.normal)
    lbSell := label.new(bar_index, finalSell, "SELL: " + str.tostring(finalSell, "#.00"), color=color.red,  textcolor=color.white, style=label.style_label_left, size=size.normal)

// === LOCKED LABELS AT 9:30 ===
if is830 and not na(lockedPrice) and showLabels
    if not na(lbBuy)
        label.delete(lbBuy)
    if not na(lbSell)
        label.delete(lbSell)
    label.new(bar_index, finalBuy,  "BUY: "  + str.tostring(finalBuy,  "#.00"), color=color.lime, textcolor=color.black, style=label.style_label_left, size=size.normal)
    label.new(bar_index, finalSell, "SELL: " + str.tostring(finalSell, "#.00"), color=color.red,  textcolor=color.white, style=label.style_label_left, size=size.normal)
````
