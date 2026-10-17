# ABW T1 FVG - Direction Change

- url: https://www.tradingview.com/script/5ZHOdXdQ-ABW-T1-FVG-Direction-Change/
- type: indicator
- pine_id: PUB;208b874cecbb4542b28e8e6478433031
- version: 1.0

## Description

ABW T1 FVG marks the first confirmed Fair Value Gap after the direction of detected FVGs changes. It is a focused chart-timeframe tool for studying FVG sequences, with a small number of borderless zones and centered timeframe labels.

HOW T1 IS DEFINED
A bullish FVG exists when the third candle's low is above the first candle's high. Its zone is the space between those prices. A bearish FVG exists when the third candle's high is below the first candle's low.

The script remembers the direction of the most recently confirmed FVG:
- After a bearish FVG, the first bullish FVG is bullish T1.
- After a bullish FVG, the first bearish FVG is bearish T1.
- Further FVGs in the same direction are not T1 until the direction changes again.
Bars without an FVG do not reset this sequence. The first detected FVG in the loaded history initializes the sequence and is not labeled T1.

Example: bearish FVG, bearish FVG, bullish FVG (T1), bullish FVG (not T1), bearish FVG (T1).

T1 is the author's sequence-based definition for this tool, not a universal FVG classification. It does not require BOS, MSS, a swing break, or a breach of the previous FVG boundary. The specific purpose is to isolate direction changes in the FVG sequence rather than draw every gap.

CONFIRMATION AND DISPLAY
Detection occurs only when the third candle closes. The box starts at the first candle of the three-candle pattern, two bars before confirmation; this placement shows the gap's origin and is not an earlier signal. The label includes the chart timeframe, for example FVG 1H T1. Bullish zones are blue and bearish zones are red by default.

The default retains only the latest T1 box. Recent T1 boxes can be increased from 1 to 50 for review; older boxes are deleted when the selected limit is reached. Box width is a fixed visual extension of 5 bars beyond confirmation by default, adjustable from 0 to 50. Colors, transparency and label visibility are adjustable. Changing timeframe recalculates the sequence on that chart timeframe.

HOW TO USE
Use standard candlestick charts. Review the labeled zone alongside your own price-action analysis. Keep the default one-box setting for a clean view, or increase retention to inspect sequences. If boxes move separately from candles, pin the indicator to the same price scale as the symbol.

ALERTS
Separate Bullish T1 FVG and Bearish T1 FVG alert conditions are included. Create the desired alert in TradingView and use Once Per Bar Close.

SCOPE AND LIMITATIONS
This version classifies T1 only. It does not calculate T2, T3, T4, higher-timeframe alignment, main-leg probability, entries, stops or targets. It does not track mitigation, invalidation or target completion: a retained box marks a detected pattern, not a claim that the zone is still valid. Retained boxes are removed by the display-count limit, not by subsequent price touches.

The implementation uses chart data without higher-timeframe requests or future-bar lookahead. Available history and data revisions can affect the initial sequence. No win rate, profitability or predictive accuracy is claimed. This is a visual analysis aid, not an automated trading strategy.

## Source Code

````pine
//@version=6
// Copyright (c) Asif Brain Waves
// T1 = first confirmed FVG after the FVG direction changes.
// No structure break or previous-gap boundary break is required.
indicator("ABW T1 FVG V3", overlay = true, max_boxes_count = 50)

int keep = input.int(1, "Recent T1 boxes", minval = 1, maxval = 50)
int width = input.int(5, "Box width after confirmation (bars)", minval = 0, maxval = 50)
color bullColor = input.color(#2563EB, "Bullish T1")
color bearColor = input.color(#EF4444, "Bearish T1")
int transparency = input.int(88, "Box transparency", minval = 0, maxval = 100)
bool showText = input.bool(true, "Show T1 labels")

var int previousFvgDirection = 0
var array<box> boxes = array.new<box>()
bool bullishFvg = low > high[2]
bool bearishFvg = high < low[2]
int direction = bullishFvg ? 1 : bearishFvg ? -1 : 0
bool bullishT1 = false
bool bearishT1 = false
string tf = timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(timeframe.multiplier / 60, "#") + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.period

if barstate.isconfirmed and direction != 0
    bool isT1 = previousFvgDirection != 0 and direction != previousFvgDirection
    if isT1
        bullishT1 := direction == 1
        bearishT1 := direction == -1
        float top = bullishT1 ? low : low[2]
        float bottom = bullishT1 ? high[2] : high
        color zoneColor = bullishT1 ? bullColor : bearColor
        if array.size(boxes) >= keep
            box.delete(array.shift(boxes))
        box zone = box.new(left = bar_index - 2, top = top, right = bar_index + width, bottom = bottom, border_width = 0, bgcolor = color.new(zoneColor, transparency), text = showText ? "FVG " + tf + " T1" : "", text_color = #0B1F3A, text_size = size.normal, text_halign = text.align_center, text_valign = text.align_center)
        array.push(boxes, zone)
    previousFvgDirection := direction

alertcondition(bullishT1, "Bullish T1 FVG", "New confirmed bullish T1 FVG on {{ticker}} {{interval}}")
alertcondition(bearishT1, "Bearish T1 FVG", "New confirmed bearish T1 FVG on {{ticker}} {{interval}}")
````
