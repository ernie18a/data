# 2pac futures times 3AM & 11AM Candle Boxes (NY Time)

- url: https://www.tradingview.com/script/qiH3Twzl-2pac-futures-times-3AM-11AM-Candle-Boxes-NY-Time/
- type: indicator
- pine_id: PUB;bf1acce5d1b14190933ddbefa27011fd
- version: 2.0

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

## Source Code

````pine
//@version=6
indicator("6 Time Candle Boxes (NY Time)", overlay=true, max_boxes_count=500, max_labels_count=500)

tz = "America/New_York"   // NY time — UTC-4 during EDT, UTC-5 during EST (handles DST automatically)

// ============================================================================
//  REUSABLE ENGINE — handles box creation, extension, and label drawing
//  for ONE time slot. Called once per time box below. `var` inside a
//  function keeps its own persistent state per call-site, so each box
//  (A, B, C, D, E, F) tracks its own boxes/labels/lookback independently.
// ============================================================================
f_timeBox(show, hh, mm, sessionName, extend, fixedExt, aheadBars, lookback,
     bgCol, borderCol, borderW,
     showTimeLbl, showSessLbl, lblBgColor, lblTxtColor, lblSizeStr) =>

    var box[]   boxes  = array.new<box>()
    var label[] labels = array.new<label>()
    var box     curBox = na
    var label   curLbl = na

    lblSize = lblSizeStr == "Tiny" ? size.tiny : lblSizeStr == "Big" ? size.large : size.small

    isBar = show and hour(time, tz) == hh and minute(time, tz) == mm

    if isBar
        rightX = extend ? bar_index + aheadBars : bar_index + fixedExt
        curBox := box.new(bar_index, high, rightX, low, border_color=borderCol, bgcolor=bgCol, border_width=borderW)
        midY   = (high + low) / 2
        array.push(boxes, curBox)
        if array.size(boxes) > lookback
            box.delete(array.shift(boxes))

        if showTimeLbl or showSessLbl
            period  = hh < 12 ? "am" : "pm"
            h12     = hh % 12 == 0 ? 12 : hh % 12
            timeTxt = str.format("{0}:{1,number,00} {2}", h12, mm, period)
            txt = showTimeLbl and showSessLbl ? timeTxt + " " + sessionName : showTimeLbl ? timeTxt : sessionName
            // plain single-line label just outside the box's right edge, vertically centered
            curLbl := label.new(rightX, midY, txt, style=label.style_label_left, color=lblBgColor, textcolor=lblTxtColor, size=lblSize)
            array.push(labels, curLbl)
            if array.size(labels) > lookback
                label.delete(array.shift(labels))

    // extend box's right edge a fixed number of bars AHEAD of the live bar
    // (instead of sitting exactly on it), so the label always has clear
    // space in front of live price instead of overlapping the candles.
    // The label's x moves with it so it stays just outside the right edge.
    if extend and not na(curBox) and not isBar
        box.set_right(curBox, bar_index + aheadBars)
        if not na(curLbl)
            label.set_x(curLbl, bar_index + aheadBars)

// ============================= BOX A (ORANGE) =============================
grpA        = "Box A"
showA       = input.bool(true, "Show Box", group=grpA)
hhA         = input.int(3, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpA)
mmA         = input.int(5, "Minute", minval=0, maxval=59, group=grpA)
sessA       = input.string("London", "Session Label Text", group=grpA)
extendA     = input.bool(true, "Extend Box to Current Bar", tooltip="When ON, the box's right edge and its top/bottom keep growing to track new bars and new highs/lows until the next box starts. When OFF, the box is a fixed size using the 'Fixed Extension' bar count below.", group=grpA)
fixedExtA   = input.int(20, "Fixed Extension (bars)", tooltip="Only used when 'Extend Box to Current Bar' is OFF. Sets a fixed width, in bars, for each box.", minval=1, group=grpA)
aheadBarsA   = input.int(15, "Extend Ahead (bars)", tooltip="Only used when 'Extend Box to Current Bar' is ON. Keeps the box's right edge (and its label) this many bars ahead of live price, so the label doesn't sit on top of current candles.", minval=0, maxval=200, group=grpA)
lookbackA   = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpA)
bgA         = input.color(color.new(color.orange, 80), "Box Fill Color", group=grpA)
borderA     = input.color(color.new(color.orange, 0),  "Box Border Color", group=grpA)
widthA      = input.int(1, "Border Width", minval=1, maxval=4, group=grpA)
showTimeA   = input.bool(true, "Show Time Label", group=grpA)
showSessA   = input.bool(true, "Show Session Label", group=grpA)
lblBgA      = input.color(color.new(color.orange, 0), "Label Background Color", group=grpA)
lblTxtA     = input.color(color.white, "Label Text Color", group=grpA)
lblSizeA    = input.string("Small", "Label Size", options=["Tiny", "Small", "Big"], group=grpA)

// ============================= BOX B (GREY) =============================
grpB        = "Box B"
showB       = input.bool(true, "Show Box", group=grpB)
hhB         = input.int(11, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpB)
mmB         = input.int(5, "Minute", minval=0, maxval=59, group=grpB)
sessB       = input.string("New York", "Session Label Text", group=grpB)
extendB     = input.bool(false, "Extend Box to Current Bar", tooltip="When ON, the box's right edge and its top/bottom keep growing to track new bars and new highs/lows until the next box starts. When OFF, the box is a fixed size using the 'Fixed Extension' bar count below.", group=grpB)
fixedExtB   = input.int(120, "Fixed Extension (bars)", tooltip="Only used when 'Extend Box to Current Bar' is OFF. Sets a fixed width, in bars, for each box.", minval=1, group=grpB)
aheadBarsB   = input.int(15, "Extend Ahead (bars)", tooltip="Only used when 'Extend Box to Current Bar' is ON. Keeps the box's right edge (and its label) this many bars ahead of live price, so the label doesn't sit on top of current candles.", minval=0, maxval=200, group=grpB)
lookbackB   = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpB)
bgB         = input.color(color.new(#808080, 80), "Box Fill Color", group=grpB)
borderB     = input.color(color.new(#87CEFA, 0),  "Box Border Color", group=grpB)
widthB      = input.int(1, "Border Width", minval=1, maxval=4, group=grpB)
showTimeB   = input.bool(true, "Show Time Label", group=grpB)
showSessB   = input.bool(true, "Show Session Label", group=grpB)
lblBgB      = input.color(color.new(#808080, 0), "Label Background Color", group=grpB)
lblTxtB     = input.color(color.white, "Label Text Color", group=grpB)
lblSizeB    = input.string("Small", "Label Size", options=["Tiny", "Small", "Big"], group=grpB)

// ============================= BOX C (GREY) =============================
grpC        = "Box C"
showC       = input.bool(true, "Show Box", group=grpC)
hhC         = input.int(9, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpC)
mmC         = input.int(5, "Minute", minval=0, maxval=59, group=grpC)
sessC       = input.string("New York", "Session Label Text", group=grpC)
extendC     = input.bool(true, "Extend Box to Current Bar", tooltip="When ON, the box's right edge and its top/bottom keep growing to track new bars and new highs/lows until the next box starts. When OFF, the box is a fixed size using the 'Fixed Extension' bar count below.", group=grpC)
fixedExtC   = input.int(20, "Fixed Extension (bars)", tooltip="Only used when 'Extend Box to Current Bar' is OFF. Sets a fixed width, in bars, for each box.", minval=1, group=grpC)
aheadBarsC   = input.int(15, "Extend Ahead (bars)", tooltip="Only used when 'Extend Box to Current Bar' is ON. Keeps the box's right edge (and its label) this many bars ahead of live price, so the label doesn't sit on top of current candles.", minval=0, maxval=200, group=grpC)
lookbackC   = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpC)
bgC         = input.color(color.new(#808080, 80), "Box Fill Color", group=grpC)
borderC     = input.color(color.new(#808080, 0),  "Box Border Color", group=grpC)
widthC      = input.int(1, "Border Width", minval=1, maxval=4, group=grpC)
showTimeC   = input.bool(true, "Show Time Label", group=grpC)
showSessC   = input.bool(true, "Show Session Label", group=grpC)
lblBgC      = input.color(color.new(#808080, 0), "Label Background Color", group=grpC)
lblTxtC     = input.color(color.white, "Label Text Color", group=grpC)
lblSizeC    = input.string("Small", "Label Size", options=["Tiny", "Small", "Big"], group=grpC)

// ============================= BOX D (GREY) =============================
grpD        = "Box D"
showD       = input.bool(true, "Show Box", group=grpD)
hhD         = input.int(11, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpD)
mmD         = input.int(0, "Minute", minval=0, maxval=59, group=grpD)
sessD       = input.string("New York", "Session Label Text", group=grpD)
extendD     = input.bool(true, "Extend Box to Current Bar", tooltip="When ON, the box's right edge and its top/bottom keep growing to track new bars and new highs/lows until the next box starts. When OFF, the box is a fixed size using the 'Fixed Extension' bar count below.", group=grpD)
fixedExtD   = input.int(20, "Fixed Extension (bars)", tooltip="Only used when 'Extend Box to Current Bar' is OFF. Sets a fixed width, in bars, for each box.", minval=1, group=grpD)
aheadBarsD   = input.int(15, "Extend Ahead (bars)", tooltip="Only used when 'Extend Box to Current Bar' is ON. Keeps the box's right edge (and its label) this many bars ahead of live price, so the label doesn't sit on top of current candles.", minval=0, maxval=200, group=grpD)
lookbackD   = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpD)
bgD         = input.color(color.new(#808080, 80), "Box Fill Color", group=grpD)
borderD     = input.color(color.new(#808080, 0),  "Box Border Color", group=grpD)
widthD      = input.int(1, "Border Width", minval=1, maxval=4, group=grpD)
showTimeD   = input.bool(true, "Show Time Label", group=grpD)
showSessD   = input.bool(true, "Show Session Label", group=grpD)
lblBgD      = input.color(color.new(#808080, 0), "Label Background Color", group=grpD)
lblTxtD     = input.color(color.white, "Label Text Color", group=grpD)
lblSizeD    = input.string("Small", "Label Size", options=["Tiny", "Small", "Big"], group=grpD)

// ============================= BOX E (GREY) =============================
grpE        = "Box E"
showE       = input.bool(false, "Show Box", group=grpE)
hhE         = input.int(13, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpE)
mmE         = input.int(0, "Minute", minval=0, maxval=59, group=grpE)
sessE       = input.string("New York", "Session Label Text", group=grpE)
extendE     = input.bool(true, "Extend Box to Current Bar", tooltip="When ON, the box's right edge and its top/bottom keep growing to track new bars and new highs/lows until the next box starts. When OFF, the box is a fixed size using the 'Fixed Extension' bar count below.", group=grpE)
fixedExtE   = input.int(20, "Fixed Extension (bars)", tooltip="Only used when 'Extend Box to Current Bar' is OFF. Sets a fixed width, in bars, for each box.", minval=1, group=grpE)
aheadBarsE   = input.int(15, "Extend Ahead (bars)", tooltip="Only used when 'Extend Box to Current Bar' is ON. Keeps the box's right edge (and its label) this many bars ahead of live price, so the label doesn't sit on top of current candles.", minval=0, maxval=200, group=grpE)
lookbackE   = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpE)
bgE         = input.color(color.new(#808080, 80), "Box Fill Color", group=grpE)
borderE     = input.color(color.new(#808080, 0),  "Box Border Color", group=grpE)
widthE      = input.int(1, "Border Width", minval=1, maxval=4, group=grpE)
showTimeE   = input.bool(true, "Show Time Label", group=grpE)
showSessE   = input.bool(true, "Show Session Label", group=grpE)
lblBgE      = input.color(color.new(#808080, 0), "Label Background Color", group=grpE)
lblTxtE     = input.color(color.white, "Label Text Color", group=grpE)
lblSizeE    = input.string("Small", "Label Size", options=["Tiny", "Small", "Big"], group=grpE)

// ============================= BOX F (GREY) =============================
grpF        = "Box F"
showF       = input.bool(false, "Show Box", group=grpF)
hhF         = input.int(15, "Hour (New York time, 24h)", minval=0, maxval=23, group=grpF)
mmF         = input.int(0, "Minute", minval=0, maxval=59, group=grpF)
sessF       = input.string("New York", "Session Label Text", group=grpF)
extendF     = input.bool(true, "Extend Box to Current Bar", tooltip="When ON, the box's right edge and its top/bottom keep growing to track new bars and new highs/lows until the next box starts. When OFF, the box is a fixed size using the 'Fixed Extension' bar count below.", group=grpF)
fixedExtF   = input.int(20, "Fixed Extension (bars)", tooltip="Only used when 'Extend Box to Current Bar' is OFF. Sets a fixed width, in bars, for each box.", minval=1, group=grpF)
aheadBarsF   = input.int(15, "Extend Ahead (bars)", tooltip="Only used when 'Extend Box to Current Bar' is ON. Keeps the box's right edge (and its label) this many bars ahead of live price, so the label doesn't sit on top of current candles.", minval=0, maxval=200, group=grpF)
lookbackF   = input.int(20, "Lookback (days) — how many past boxes to keep on chart", minval=1, maxval=500, group=grpF)
bgF         = input.color(color.new(#808080, 80), "Box Fill Color", group=grpF)
borderF     = input.color(color.new(#808080, 0),  "Box Border Color", group=grpF)
widthF      = input.int(1, "Border Width", minval=1, maxval=4, group=grpF)
showTimeF   = input.bool(true, "Show Time Label", group=grpF)
showSessF   = input.bool(true, "Show Session Label", group=grpF)
lblBgF      = input.color(color.new(#808080, 0), "Label Background Color", group=grpF)
lblTxtF     = input.color(color.white, "Label Text Color", group=grpF)
lblSizeF    = input.string("Small", "Label Size", options=["Tiny", "Small", "Big"], group=grpF)

// ============================= RUN ENGINE FOR EACH BOX =============================
f_timeBox(showA, hhA, mmA, sessA, extendA, fixedExtA, aheadBarsA, lookbackA, bgA, borderA, widthA, showTimeA, showSessA, lblBgA, lblTxtA, lblSizeA)
f_timeBox(showB, hhB, mmB, sessB, extendB, fixedExtB, aheadBarsB, lookbackB, bgB, borderB, widthB, showTimeB, showSessB, lblBgB, lblTxtB, lblSizeB)
f_timeBox(showC, hhC, mmC, sessC, extendC, fixedExtC, aheadBarsC, lookbackC, bgC, borderC, widthC, showTimeC, showSessC, lblBgC, lblTxtC, lblSizeC)
f_timeBox(showD, hhD, mmD, sessD, extendD, fixedExtD, aheadBarsD, lookbackD, bgD, borderD, widthD, showTimeD, showSessD, lblBgD, lblTxtD, lblSizeD)
f_timeBox(showE, hhE, mmE, sessE, extendE, fixedExtE, aheadBarsE, lookbackE, bgE, borderE, widthE, showTimeE, showSessE, lblBgE, lblTxtE, lblSizeE)
f_timeBox(showF, hhF, mmF, sessF, extendF, fixedExtF, aheadBarsF, lookbackF, bgF, borderF, widthF, showTimeF, showSessF, lblBgF, lblTxtF, lblSizeF)
````
