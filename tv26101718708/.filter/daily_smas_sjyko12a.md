# Daily SMAs

- url: https://www.tradingview.com/script/SJyko12A-Daily-SMAs/
- type: indicator
- pine_id: PUB;0727218f21734630a2d2c0fbd9d3239d
- version: 1.0

## Description

Tracks the 20, 50 and 200 daily SMA and updates each one in real time as a blue line on your chart

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mottand

//@version=6
indicator("Daily SMAs", overlay=true)

// === FETCH DAILY SMAs ===
sma200 = request.security(syminfo.tickerid, "D", ta.sma(close, 200), lookahead=barmerge.lookahead_on)
sma50  = request.security(syminfo.tickerid, "D", ta.sma(close, 50),  lookahead=barmerge.lookahead_on)
sma20  = request.security(syminfo.tickerid, "D", ta.sma(close, 20),  lookahead=barmerge.lookahead_on)

// === ONLY UPDATE ONCE PER DAY ===
is_new_day = ta.change(time("D")) != 0

// === LINES ===
var line line200 = na
var line line50  = na
var line line20  = na

// === LABELS ===
var label label200 = na
var label label50  = na
var label label20  = na

if is_new_day or barstate.islast
    line.delete(line200)
    line.delete(line50)
    line.delete(line20)
    label.delete(label200)
    label.delete(label50)
    label.delete(label20)

    // Draw lines (width=3 for bolder appearance)
    line200 := line.new(
         x1=bar_index, y1=sma200,
         x2=bar_index + 1, y2=sma200,
         extend=extend.both,
         color=color.new(color.blue, 40),
         style=line.style_dotted,
         width=3)

    line50 := line.new(
         x1=bar_index, y1=sma50,
         x2=bar_index + 1, y2=sma50,
         extend=extend.both,
         color=color.new(color.blue, 40),
         style=line.style_dotted,
         width=3)

    line20 := line.new(
         x1=bar_index, y1=sma20,
         x2=bar_index + 1, y2=sma20,
         extend=extend.both,
         color=color.new(color.blue, 40),
         style=line.style_dotted,
         width=3)

    // Labels with white text, transparent background
    label200 := label.new(
         x=bar_index, y=sma200,
         text="200 SMA: " + str.tostring(sma200, "#.##"),
         color=color.new(color.white, 100),
         textcolor=color.white,
         style=label.style_label_center,
         size=size.small)

    label50 := label.new(
         x=bar_index, y=sma50,
         text="50 SMA: " + str.tostring(sma50, "#.##"),
         color=color.new(color.white, 100),
         textcolor=color.white,
         style=label.style_label_center,
         size=size.small)

    label20 := label.new(
         x=bar_index, y=sma20,
         text="20 SMA: " + str.tostring(sma20, "#.##"),
         color=color.new(color.white, 100),
         textcolor=color.white,
         style=label.style_label_center,
         size=size.small)

// === CROSS ALERTS ===
cross200up   = ta.crossover(close,  sma200)
cross200down = ta.crossunder(close, sma200)
cross50up    = ta.crossover(close,  sma50)
cross50down  = ta.crossunder(close, sma50)
cross20up    = ta.crossover(close,  sma20)
cross20down  = ta.crossunder(close, sma20)

alertcondition(cross200up,   "Price Crossed ABOVE 200 SMA", "{{ticker}} crossed ABOVE the Daily 200 SMA @ {{close}}")
alertcondition(cross200down, "Price Crossed BELOW 200 SMA", "{{ticker}} crossed BELOW the Daily 200 SMA @ {{close}}")
alertcondition(cross50up,    "Price Crossed ABOVE 50 SMA",  "{{ticker}} crossed ABOVE the Daily 50 SMA @ {{close}}")
alertcondition(cross50down,  "Price Crossed BELOW 50 SMA",  "{{ticker}} crossed BELOW the Daily 50 SMA @ {{close}}")
alertcondition(cross20up,    "Price Crossed ABOVE 20 SMA",  "{{ticker}} crossed ABOVE the Daily 20 SMA @ {{close}}")
alertcondition(cross20down,  "Price Crossed BELOW 20 SMA",  "{{ticker}} crossed BELOW the Daily 20 SMA @ {{close}}")
alertcondition(cross200up or cross200down or cross50up or cross50down or cross20up or cross20down,
     "Price Crossed Any Daily SMA", "{{ticker}} crossed a Daily SMA @ {{close}}")
````
