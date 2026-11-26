# Weekly Pivot Range (Mark Fisher)

- url: https://www.tradingview.com/script/weKzatwM-Weekly-Pivot-Range-Mark-Fisher/
- type: indicator
- pine_id: PUB;e8b3bd303b8f404388ee862bdcd667d7
- version: 1.0

## Description

Mark Fisher's classic 3-line pivot range applied to the weekly timeframe, with a soft cloud fill between the top and bottom levels. Clean light-yellow bands and a pink central pivot make the current week's reference levels easy to read at a glance on any intraday chart.

## Source Code

````pine
//@version=5
indicator(title="Weekly Pivot Range (Mark Fisher)", shorttitle="Weekly_PivotR", overlay=true)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
sw         = input.bool(true,  "Show Weekly Pivots?",        group="Display")
showCloud  = input.bool(true,  "Show Cloud Fill (TC ↔ BC)",  group="Display")

pivotColor = input.color(#FF66B2, "Pivot (Middle) Color",    group="Style")
bandColor  = input.color(#FFF59D, "TC / BC (Top & Bottom)",  group="Style")
cloudColor = input.color(color.new(#FFF59D, 80), "Cloud Fill Color", group="Style", tooltip="Lower transparency = more visible. Default 80 is subtle.")
lineWidth  = input.int(2, "Line Width", minval=1, maxval=4,  group="Style")

// ─── PIVOT RANGE CALCULATIONS — Mark Fisher ───────────────────────────────────
pivot = (high + low + close) / 3.0
bc    = (high + low) / 2.0
tc    = (pivot - bc) + pivot

// ─── WEEKLY VALUES (previous completed week) ──────────────────────────────────
w_pivot = request.security(syminfo.tickerid, "W", pivot[1], lookahead=barmerge.lookahead_on)
w_bc    = request.security(syminfo.tickerid, "W", bc[1],    lookahead=barmerge.lookahead_on)
w_tc    = request.security(syminfo.tickerid, "W", tc[1],    lookahead=barmerge.lookahead_on)

// ─── PLOTS ───────────────────────────────────────────────────────────────────
pTC    = plot(sw ? w_tc    : na, title="Weekly TC (Top)",    style=plot.style_line, color=bandColor,  linewidth=lineWidth)
pPivot = plot(sw ? w_pivot : na, title="Weekly Pivot",       style=plot.style_line, color=pivotColor, linewidth=lineWidth)
pBC    = plot(sw ? w_bc    : na, title="Weekly BC (Bottom)", style=plot.style_line, color=bandColor,  linewidth=lineWidth)

// ─── CLOUD FILL ──────────────────────────────────────────────────────────────
fill(pTC, pBC, color = (sw and showCloud) ? cloudColor : na, title="Weekly Pivot Cloud")

// ─── LABELS on last bar ───────────────────────────────────────────────────────
if barstate.islast and sw
    label.new(bar_index + 1, w_pivot, "Pivot " + str.tostring(math.round(w_pivot, 2)), style=label.style_label_left, color=color.new(pivotColor, 80), textcolor=pivotColor, size=size.small)
    label.new(bar_index + 1, w_tc,    "TC "    + str.tostring(math.round(w_tc,    2)), style=label.style_label_left, color=color.new(bandColor,  80), textcolor=bandColor,  size=size.small)
    label.new(bar_index + 1, w_bc,    "BC "    + str.tostring(math.round(w_bc,    2)), style=label.style_label_left, color=color.new(bandColor,  80), textcolor=bandColor,  size=size.small)
````
