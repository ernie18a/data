<!-- tradingview-pine-id: PUB;bf1acce5d1b14190933ddbefa27011fd -->
<!-- tradingviewscripts-format: 1 -->
# 3AM & 11AM Candle Boxes (NY Time)

Source: https://www.tradingview.com/script/qiH3Twzl-2pac-futures-times-3AM-11AM-Candle-Boxes-NY-Time/

## Description

---

**3AM & 11AM Candle Box — New York Time Session Levels**

This indicator marks two of the most-watched clock-time candles on any 5-minute chart: the candle that opens at **3:00 AM New York time** and the one that opens at **11:00 AM New York time**. Each candle's high and low get boxed in — grey for the 3AM candle, blue for the 11AM candle — and the box can stretch forward in real time so that level stays visible as price continues to trade through the day.

Why these two times matter: 3:00 AM NY sits right around the London session ramp-up, often marking the range price consolidates in before the New York session opens. 11:00 AM NY falls in the middle of the NY AM session, a common checkpoint traders use to judge whether the morning's move has real follow-through or is starting to stall. Boxing both gives you two clean, objective reference zones without having to eyeball chart time stamps.

**How to use it for entries**

The most common way to trade off these boxes is a **break and retest**: wait for price to close outside the box (above for a long idea, below for a short), then watch for price to pull back and test that broken edge as new support or resistance before continuing in the breakout direction. A stop typically sits just on the other side of the box; a target is usually the next visible structure, prior high/low, or a fixed risk-multiple.

**Confluence** is what separates a random break from a higher-quality one — look for the retest to line up with other things you already trust: a prior day's high/low, a round number, a VWAP touch, or a higher-timeframe trendline. The more of those stacking at the same retest zone, the more weight that level tends to carry.

Both boxes are fully adjustable — time, color, and whether they extend live or stop at a fixed width — so this works as a standalone session marker or as one more layer of confluence in a broader system.

*Not financial advice — for educational and charting purposes only.*

---

## Source Code

````pine
//@version=6
indicator("3AM & 11AM Candle Boxes (NY Time)", overlay=true, max_boxes_count=500)

tz = "America/New_York"   // NY time — UTC-4 during EDT, UTC-5 during EST (handles DST automatically)

// ============================= 3:00 AM CANDLE BOX (GREY) =============================
grpA       = "3:00 AM Candle Box"
showA      = input.bool(true, "Show 3:00 AM Box", group=grpA)
hhA        = input.int(3, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpA)
mmA        = input.int(0, "Minute", minval=0, maxval=59, group=grpA)
extendA    = input.bool(true, "Extend Box to Current Bar", group=grpA)
fixedExtA  = input.int(20, "Fixed Extension (bars) — used if 'Extend to Current Bar' is off", minval=1, group=grpA)
lookbackA  = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpA)
bgA        = input.color(color.new(#404040, 80), "Fill Color (Dark Grey)", group=grpA)
borderA    = input.color(color.new(#404040, 0),  "Border Color",          group=grpA)
widthA     = input.int(1, "Border Width", minval=1, maxval=4, group=grpA)

// ============================= 11:00 AM CANDLE BOX (BLUE) =============================
grpB       = "11:00 AM Candle Box"
showB      = input.bool(true, "Show 11:00 AM Box", group=grpB)
hhB        = input.int(11, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpB)
mmB        = input.int(0,  "Minute", minval=0, maxval=59, group=grpB)
extendB    = input.bool(true, "Extend Box to Current Bar", group=grpB)
fixedExtB  = input.int(20, "Fixed Extension (bars) — used if 'Extend to Current Bar' is off", minval=1, group=grpB)
lookbackB  = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpB)
bgB        = input.color(color.new(color.blue, 80), "Fill Color (Blue)", group=grpB)
borderB    = input.color(color.new(color.blue, 0),  "Border Color",      group=grpB)
widthB     = input.int(1, "Border Width", minval=1, maxval=4, group=grpB)

// ============================= 3:00 AM BOX LOGIC =============================
isA = showA and hour(time, tz) == hhA and minute(time, tz) == mmA

var box[] boxesA = array.new<box>()
var box   boxA    = na

if isA
    rightA = extendA ? bar_index : bar_index + fixedExtA
    boxA := box.new(bar_index, high, rightA, low, border_color=borderA, bgcolor=bgA, border_width=widthA)
    array.push(boxesA, boxA)
    if array.size(boxesA) > lookbackA
        box.delete(array.shift(boxesA))

if extendA and not na(boxA) and not isA
    box.set_right(boxA, bar_index)

// ============================= 11:00 AM BOX LOGIC =============================
isB = showB and hour(time, tz) == hhB and minute(time, tz) == mmB

var box[] boxesB = array.new<box>()
var box   boxB    = na

if isB
    rightB = extendB ? bar_index : bar_index + fixedExtB
    boxB := box.new(bar_index, high, rightB, low, border_color=borderB, bgcolor=bgB, border_width=widthB)
    array.push(boxesB, boxB)
    if array.size(boxesB) > lookbackB
        box.delete(array.shift(boxesB))

if extendB and not na(boxB) and not isB
    box.set_right(boxB, bar_index)
````
