<!-- tradingview-pine-id: PUB;7d9f4a293efd49a4a0c0ead2649354bc -->
<!-- tradingviewscripts-format: 1 -->
# Ichimoku TK Cross In-Cloud Scanner

Source: https://www.tradingview.com/script/kNjZpgyA-Ichimoku-TK-Cross-In-Cloud-Scanner/

## Description

On close in the cloud with the proper line cross an arrow will appear and a printed percentage move will display on the chart.

---

## Source Code

````pine
//@version=6
indicator("Ichimoku TK Cross In-Cloud Scanner", overlay = true, max_labels_count = 500)

// Match your chart's settings (18 52 104 26)
tenkanLen  = input.int(18,  "Conversion (Tenkan)")
kijunLen   = input.int(52,  "Base (Kijun)")
senkouBLen = input.int(104, "Leading Span B")
disp       = input.int(26,  "Displacement")
dirOnly    = input.bool(true, "Bull enters from below / Bear enters from above")

// Label appearance
sizeChoice = input.string("Small", "Arrow / text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"])
bullColor  = input.color(color.green, "Bull signal color")
bearColor  = input.color(color.red,   "Bear signal color")

sizeFromString(s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Normal" ? size.normal :
     s == "Large" ? size.large :
     size.huge

labelSize = sizeFromString(sizeChoice)

donchian(len) => math.avg(ta.lowest(len), ta.highest(len))

tenkan  = donchian(tenkanLen)
kijun   = donchian(kijunLen)
senkouA = math.avg(tenkan, kijun)
senkouB = donchian(senkouBLen)

cloudTop    = math.max(senkouA[disp - 1], senkouB[disp - 1])
cloudBottom = math.min(senkouA[disp - 1], senkouB[disp - 1])

inCloud      = close >= cloudBottom and close <= cloudTop
firstInCloud = inCloud and not inCloud[1]

enteredBelow = firstInCloud and close[1] < cloudBottom[1]
enteredAbove = firstInCloud and close[1] > cloudTop[1]

bullCross = ta.crossover(tenkan, kijun)
bearCross = ta.crossunder(tenkan, kijun)

var bool bullArmed = false
var bool bearArmed = false

if bullCross
    bullArmed := true
    bearArmed := false
if bearCross
    bearArmed := true
    bullArmed := false

bullFire = bullArmed and ((firstInCloud and (not dirOnly or enteredBelow)) or (bullCross and inCloud))
bearFire = bearArmed and ((firstInCloud and (not dirOnly or enteredAbove)) or (bearCross and inCloud))

if bullFire
    bullArmed := false
if bearFire
    bearArmed := false

roomToTop    = (cloudTop - close) / close * 100
roomToBottom = (close - cloudBottom) / close * 100

int   direction = 0
float roomPct   = na
int   barsWait  = na

if bullFire
    direction := 1
    roomPct   := roomToTop
    barsWait  := ta.barssince(bullCross)
    label.new(bar_index, low, str.tostring(roomToTop, "#.#") + "%", yloc = yloc.belowbar, style = label.style_arrowup, color = bullColor, textcolor = bullColor, size = labelSize)

if bearFire
    direction := -1
    roomPct   := roomToBottom
    barsWait  := ta.barssince(bearCross)
    label.new(bar_index, high, str.tostring(roomToBottom, "#.#") + "%", yloc = yloc.abovebar, style = label.style_arrowdown, color = bearColor, textcolor = bearColor, size = labelSize)

plot(direction, "Direction (1=Bull, -1=Bear)", display = display.none)
plot(roomPct, "Room to Far Side %", display = display.none)
plot(barsWait, "Bars From Cross to Cloud Entry", display = display.none)
````
