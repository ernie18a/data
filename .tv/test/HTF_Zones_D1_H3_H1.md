<!-- tradingview-pine-id: PUB;d2b1d25cc63a413ba06e942cf4bd6bd3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HTF Zones D1 H3 H1

Source: https://www.tradingview.com/script/oUeyP8Vi-htf-zones-d1-h3-h1/

## Description

This indicator is designed for multi-timeframe price analysis using D1, H3 and H1 higher-timeframe zones. It identifies and displays important price areas directly on the chart to help traders analyze market context and price behavior. The current version provides the basic HTF zone framework and is intended for further development with balance, order block and confirmation logic. The indicator is designed for Smart Money and Price Action analysis and should be used together with the trader's own market analysis and risk management..

---

## Source Code

````pine
//@version=6
indicator("HTF Zones D1 H3 H1", overlay=true, max_boxes_count=100)

showD1 = input.bool(true, "D1")
showH3 = input.bool(true, "H3")
showH1 = input.bool(true)

extendBars = input.int(100, "Розширення зон", minval=10)

[d1High, d1Low, d1Time] = request.security(
    syminfo.tickerid, "D",
    [high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_on)

[h3High, h3Low, h3Time] = request.security(
    syminfo.tickerid, "180",
    [high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_on)

[h1High, h1Low, h1Time] = request.security(
    syminfo.tickerid, "60",
    [high[1], low[1], time[1]],
    lookahead=barmerge.lookahead_on)

makeZone(float top, float bottom, color borderColor) =>
    box.new(
        left=bar_index,
        top=top,
        right=bar_index + extendBars,
        bottom=bottom,
        border_color=borderColor,
        bgcolor=color.new(borderColor, 90))

var box d1Box = na
var int lastD1 = na

if showD1 and d1Time != lastD1
    if not na(d1Box)
        box.delete(d1Box)
    d1Box := makeZone(d1High, d1Low, color.red)
    lastD1 := d1Time

var box h3Box = na
var int lastH3 = na

if showH3 and h3Time != lastH3
    if not na(h3Box)
        box.delete(h3Box)
    h3Box := makeZone(h3High, h3Low, color.orange)
    lastH3 := h3Time

var box h1Box = na
var int lastH1 = na

if showH1 and h1Time != lastH1
    if not na(h1Box)
        box.delete(h1Box)
    h1Box := makeZone(h1High, h1Low, color.blue)
    lastH1 := h1Time
````
