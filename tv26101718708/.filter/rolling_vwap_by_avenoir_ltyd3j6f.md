# Rolling VWAP by Avenoir

- url: https://www.tradingview.com/script/ltyD3J6F-Rolling-VWAP-by-Avenoir/
- type: indicator
- pine_id: PUB;8f28bed3cd3e4580bddc74675eba2de8
- version: 1.0

## Description

Rolling VWAP by Avenoir
Plots up to five rolling VWAPs (7D, 30D, 90D, 180D, 365D) as dotted historical traces, with clean text labels on the right edge of the chart.
Features

Five toggleable lookbacks: 7, 30, 90, 180, and 365 days
Two calculation modes:

Daily Based — pulls daily data via request.security, so the VWAPs stay consistent regardless of your chart timeframe
Current Timeframe — calculates from the active chart timeframe using fixed bar lengths


Minimal styling: single line color, adjustable dot size, and label offset/nudge controls so the labels sit cleanly above each line
Labels redraw only on the last bar to keep the chart uncluttered

Use case
Useful for spotting where price sits relative to medium- and long-term volume-weighted averages — a quick read on whether an asset is trading above or below its rolling fair value across multiple horizons.

## Source Code

````pine
//@version=6
indicator("Rolling VWAP by Avenoir", shorttitle="Rolling VWAP by Avenoir", overlay=true, max_labels_count=50)

// === INPUT SETTINGS ===
grpTf = "Timeframes"
show_7d   = input.bool(true,  "Show 7D VWAP",   group=grpTf)
show_30d  = input.bool(true,  "Show 30D VWAP",  group=grpTf)
show_90d  = input.bool(true,  "Show 90D VWAP",  group=grpTf)
show_180d = input.bool(true,  "Show 180D VWAP", group=grpTf)
show_365d = input.bool(true,  "Show 365D VWAP", group=grpTf)

grpStyle = "Style"
lineCol     = input.color(color.new(#888888, 0), "Line color (all)", group=grpStyle)
textCol     = input.color(color.black,           "Label text color", group=grpStyle)
dotWidth    = input.int(1, "Dot size",    minval=1, maxval=3, group=grpStyle)
labelOffset = input.int(30, "Label offset (bars right)", minval=5, maxval=100, group=grpStyle)
labelYNudge = input.float(0.15, "Label vertical nudge (%)", minval=0.0, maxval=2.0, step=0.05, group=grpStyle, tooltip="How far above the line the text sits, as % of price")

grpMethod = "Method"
calc_method = input.string("Daily Based", "Calculation Method",
     options=["Current Timeframe", "Daily Based"],
     tooltip="Current Timeframe: Adapts to chart timeframe\nDaily Based: Always uses daily data",
     group=grpMethod)

// === CALCULATION FUNCTIONS ===
simple_vwap(length) =>
    ta.vwma(hlc3, length)

daily_vwap(days) =>
    request.security(syminfo.tickerid, "1D", ta.vwma(hlc3, days))

// === CALCULATE VWAP VALUES ===
ct_7d   = simple_vwap(50)
ct_30d  = simple_vwap(100)
ct_90d  = simple_vwap(200)
ct_180d = simple_vwap(300)
ct_365d = simple_vwap(500)

db_7d   = daily_vwap(7)
db_30d  = daily_vwap(30)
db_90d  = daily_vwap(90)
db_180d = daily_vwap(180)
db_365d = daily_vwap(365)

vwap_7d   = calc_method == "Daily Based" ? (show_7d   ? db_7d   : na) : (show_7d   ? ct_7d   : na)
vwap_30d  = calc_method == "Daily Based" ? (show_30d  ? db_30d  : na) : (show_30d  ? ct_30d  : na)
vwap_90d  = calc_method == "Daily Based" ? (show_90d  ? db_90d  : na) : (show_90d  ? ct_90d  : na)
vwap_180d = calc_method == "Daily Based" ? (show_180d ? db_180d : na) : (show_180d ? ct_180d : na)
vwap_365d = calc_method == "Daily Based" ? (show_365d ? db_365d : na) : (show_365d ? ct_365d : na)

// === PLOTTING — dotted historical trace (like C2M's 30day/90day curves) ===
plot(vwap_7d,   "7D",   color=lineCol, linewidth=dotWidth, style=plot.style_circles, editable=false)
plot(vwap_30d,  "30D",  color=lineCol, linewidth=dotWidth, style=plot.style_circles, editable=false)
plot(vwap_90d,  "90D",  color=lineCol, linewidth=dotWidth, style=plot.style_circles, editable=false)
plot(vwap_180d, "180D", color=lineCol, linewidth=dotWidth, style=plot.style_circles, editable=false)
plot(vwap_365d, "365D", color=lineCol, linewidth=dotWidth, style=plot.style_circles, editable=false)

// === CLEAN LABELS ON LAST BAR ===
var label[] labels = array.new_label()

f_addLabel(_price, _txt) =>
    if not na(_price)
        yOffset = _price * (labelYNudge / 100.0)
        array.push(labels, label.new(x=bar_index + labelOffset, y=_price + yOffset, text=_txt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=textCol, style=label.style_none, size=size.small))

if barstate.islast
    while array.size(labels) > 0
        label.delete(array.shift(labels))

    f_addLabel(vwap_7d,   "7day")
    f_addLabel(vwap_30d,  "30day")
    f_addLabel(vwap_90d,  "90day")
    f_addLabel(vwap_180d, "180day")
    f_addLabel(vwap_365d, "365day")
````
