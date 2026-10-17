# ABW T2 FVG - Tap and Continuation

- url: https://www.tradingview.com/script/MsvlxVrp-ABW-T2-FVG-Tap-and-Continuation/
- type: indicator
- pine_id: PUB;66b08063b37c49b09f5daf3c9f821aa6
- version: 1.0

## Description

ABW T2 FVG - Tap and Continuation

PURPOSE
This overlay highlights Type 2 Fair Value Gaps using an ABW-defined tap-and-continuation model. It separates qualifying T2 gaps from ordinary three-candle gaps so that traders can study how a same-direction sequence develops after an earlier FVG is revisited. Type 2 is the classification used by this script, not a universal industry definition.

HOW A FAIR VALUE GAP IS DETECTED
A bullish FVG forms when the current candle's low is above the high two candles earlier. Its zone runs between those two prices. A bearish FVG forms when the current candle's high is below the low two candles earlier. Strict price separation is required; equality does not create a gap. Detection uses the current chart symbol and timeframe, and only confirmed candles.

TAP AND T2 SEQUENCE
1. The script tracks earlier bullish and bearish FVGs internally.
2. A later candle taps an existing FVG when its high-low range touches or overlaps the zone. The formation candle cannot tap its own new FVG.
3. After the tap, a subsequent same-direction FVG can start a T2 sequence. The new FVG must confirm on a later bar than the tap. No confirmed swing, BOS or MSS condition is required.
4. Once T2 is active, every additional same-direction FVG is also T2. Each continuation does not need another tap.
5. An opposite-direction FVG ends the active T2 sequence. That direction-change gap is not marked T2. A later qualifying tap-and-gap event is needed to activate a new sequence.

For example, after a bearish FVG is tapped, a later bearish gap can start a bearish T2 sequence. Further bearish gaps remain T2 until a bullish FVG appears. The bullish case is the mirror image.

PARENT-ZONE FILTER
Before a parent is used, it is removed if a candle's wick crosses its far boundary: below the bottom of a bullish parent or above the top of a bearish parent. An equal touch is allowed. A candle that crosses that boundary is treated as a breach rather than a valid tap. After a T2 sequence has started, its continuation is controlled by FVG direction, not by further parent taps or breaches.

DISPLAY AND SETTINGS
Only T2 boxes are drawn; the internally tracked parent gaps are not all displayed. Each box spans the actual gap prices, starts two bars before confirmation and ends a fixed number of bars after confirmation. A box is first created at confirmation; its left edge does not mean the signal was known two bars earlier.

Recent T2 boxes: default 10, adjustable from 1 to 50. Older displayed boxes are deleted when this limit is reached.
Box width after confirmation: default 5 bars, adjustable from 0 to 50.
Maximum parent FVGs tracked: default 100, adjustable from 10 to 300. This bounds processing and can affect which older parents remain eligible.
Bullish and bearish colors, transparency and centered English labels are configurable. Labels include the current chart timeframe, for example FVG 4H T2.

Boxes are historical detection markers. They do not extend indefinitely, and they are not automatically removed or relabeled after a later mitigation, target or invalidation. Do not interpret every retained box as a fresh, unmitigated trading opportunity.

ALERTS
Separate Bullish T2 FVG and Bearish T2 FVG alert conditions are provided. Create alerts through TradingView and use Once Per Bar Close. Continuation gaps can each generate their own alert. The script does not automatically create alerts or execute orders.

HOW TO USE
Use standard candlestick charts. Review the preceding FVG and tap, then follow the marked continuation sequence. Change the chart timeframe to study that timeframe's own gaps; this is not a multi-timeframe projection tool. The publication chart is an example of detection behavior, not a trade recommendation or performance result.

SCOPE AND LIMITATIONS
This is an educational indicator, not a strategy or backtest. It provides no entries, stop-losses, targets, position sizing or profitability statistics. No win rate or future performance is claimed. Closed-bar processing avoids provisional intrabar detections, but changing data, timeframe, settings or available history can change results. The distinctive part of this implementation is its persistent tap-triggered T2 sequence and opposite-FVG reset, rather than the standard three-candle FVG formula itself.

## Source Code

````pine
//@version=6
// Copyright (c) Asif Brain Waves
indicator("ABW T2 FVG V1", overlay = true, max_boxes_count = 50)
int keep = input.int(10, "Recent T2 boxes", minval = 1, maxval = 50)
int width = input.int(5, "Box width after confirmation (bars)", minval = 0, maxval = 50)
int parentLimit = input.int(100, "Maximum parent FVGs tracked", minval = 10, maxval = 300)
color bullColor = input.color(#2563EB, "Bullish T2")
color bearColor = input.color(#EF4444, "Bearish T2")
int transparency = input.int(88, "Box transparency", minval = 0, maxval = 100)
bool showText = input.bool(true, "Show centered labels")

type Parent
    float top
    float bottom
    int direction
    int born
    int tapped
var array<Parent> parents = array.new<Parent>()
var array<box> boxes = array.new<box>()
var int activeT2Direction = 0
var int lastFvgDirection = 0
bool bullT2 = false
bool bearT2 = false
string tf = timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(timeframe.multiplier / 60, "#") + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.period

if barstate.isconfirmed
    // A tap is any later candle touching or overlapping the existing zone.
    // A far-boundary breach invalidates a parent; equal touches are allowed.
    if array.size(parents) > 0
        for i = array.size(parents) - 1 to 0
            Parent p = array.get(parents, i)
            bool breached = (p.direction == 1 and low < p.bottom) or (p.direction == -1 and high > p.top)
            if breached
                array.remove(parents, i)
            else if na(p.tapped) and bar_index > p.born and low <= p.top and high >= p.bottom
                p.tapped := bar_index
    int direction = low > high[2] ? 1 : high < low[2] ? -1 : 0
    if direction != 0
        float top = direction == 1 ? low : low[2]
        float bottom = direction == 1 ? high[2] : high
        bool oppositeFvg = lastFvgDirection != 0 and direction != lastFvgDirection
        if oppositeFvg
            activeT2Direction := 0
        bool followsTap = false
        if array.size(parents) > 0
            for i = array.size(parents) - 1 to 0
                Parent p = array.get(parents, i)
                // The new gap must confirm AFTER the tap, not on the tap bar.
                // Consume the tap to start a persistent same-direction T2 sequence.
                if p.direction == direction and not na(p.tapped) and p.tapped < bar_index
                    followsTap := not oppositeFvg
                    array.remove(parents, i)
        // Once a tap starts T2, every same-direction gap remains T2.
        // Only an opposite FVG ends this sequence.
        if followsTap
            activeT2Direction := direction
        bullT2 := direction == 1 and activeT2Direction == 1
        bearT2 := direction == -1 and activeT2Direction == -1
        lastFvgDirection := direction
        if bullT2 or bearT2
            if array.size(boxes) >= keep
                box.delete(array.shift(boxes))
            color zoneColor = bullT2 ? bullColor : bearColor
            box zone = box.new(left = bar_index - 2, top = top, right = bar_index + width, bottom = bottom, border_width = 0, bgcolor = color.new(zoneColor, transparency), text = showText ? "FVG " + tf + " T2" : "", text_color = #0B1F3A, text_size = size.normal, text_halign = text.align_center, text_valign = text.align_center)
            array.push(boxes, zone)
        if array.size(parents) >= parentLimit
            array.shift(parents)
        array.push(parents, Parent.new(top, bottom, direction, bar_index, na))

alertcondition(bullT2, "Bullish T2 FVG", "New confirmed bullish T2 FVG on {{ticker}} {{interval}}")
alertcondition(bearT2, "Bearish T2 FVG", "New confirmed bearish T2 FVG on {{ticker}} {{interval}}")
````
