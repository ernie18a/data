# macro time ranges 

- url: https://www.tradingview.com/script/28NbsmH9-macro-time-ranges/
- type: indicator
- pine_id: PUB;21daf0cc69da46a1ae0b13a7717a4604
- version: 1.0

## Description

This indicator is a professional session-range visualization tool designed for intraday trading. It automatically highlights predefined New York (EST/EDT) institutional time windows using dynamic orange boxes directly on the price chart.

The indicator tracks the high and low formed during each selected session and continuously expands the box as price develops within that time range. A labeled timestamp is displayed beneath every box for quick session identification.

Marked EST trading windows:

* 08:50 – 09:10
* 09:50 – 10:10
* 10:50 – 11:10
* 11:50 – 12:10
* 01:10 – 01:40 PM
* 03:15 – 03:45 PM

Core Features:

* Automatic EST/EDT timezone handling
* Dynamic session high-low range boxes
* Clean orange institutional-style visualization
* Session labels displayed under each range
* Optimized for lower timeframes (1m–15m)
* Useful for ICT, SMC, liquidity sweep, breakout, and killzone trading models

Professional Trading Applications:

* Session range breakout trading
* Liquidity sweep identification
* Intraday volatility analysis
* Institutional timing reference
* Smart Money Concept execution
* News and market open reaction analysis

This tool is especially effective for highly volatile markets such as XAUUSD, NAS100, US30, SPX500, and Bitcoin where timing-based liquidity movements are critical.

## Source Code

````pine
//@version=5
indicator("EST Time Range Boxes With Labels", overlay=true)

// === Timezone ===
tz = "America/New_York"

// === Sessions ===
s1 = "0850-0910"
s2 = "0950-1010"
s3 = "1050-1110"
s4 = "1150-1210"
s5 = "1310-1340"
s6 = "1515-1545"

// === Session Detection ===
in1 = not na(time(timeframe.period, s1, tz))
in2 = not na(time(timeframe.period, s2, tz))
in3 = not na(time(timeframe.period, s3, tz))
in4 = not na(time(timeframe.period, s4, tz))
in5 = not na(time(timeframe.period, s5, tz))
in6 = not na(time(timeframe.period, s6, tz))

// === Colors ===
boxColor = color.orange
bgColor  = color.new(color.orange, 85)
textColor = color.white

// === Variables ===
var box box1 = na
var box box2 = na
var box box3 = na
var box box4 = na
var box box5 = na
var box box6 = na

var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na
var label lbl6 = na

// =====================================================
// SESSION 1
// =====================================================
start1 = in1 and not in1[1]

if start1
    box1 := box.new(bar_index, high, bar_index, low,
         bgcolor = bgColor,
         border_color = boxColor)

    lbl1 := label.new(
         x = bar_index,
         y = low,
         text = "08:50 - 09:10 EST",
         style = label.style_label_up,
         color = boxColor,
         textcolor = textColor,
         size = size.small)

if in1
    box.set_right(box1, bar_index)
    box.set_top(box1, math.max(box.get_top(box1), high))
    box.set_bottom(box1, math.min(box.get_bottom(box1), low))

// =====================================================
// SESSION 2
// =====================================================
start2 = in2 and not in2[1]

if start2
    box2 := box.new(bar_index, high, bar_index, low,
         bgcolor = bgColor,
         border_color = boxColor)

    lbl2 := label.new(
         x = bar_index,
         y = low,
         text = "09:50 - 10:10 EST",
         style = label.style_label_up,
         color = boxColor,
         textcolor = textColor,
         size = size.small)

if in2
    box.set_right(box2, bar_index)
    box.set_top(box2, math.max(box.get_top(box2), high))
    box.set_bottom(box2, math.min(box.get_bottom(box2), low))

// =====================================================
// SESSION 3
// =====================================================
start3 = in3 and not in3[1]

if start3
    box3 := box.new(bar_index, high, bar_index, low,
         bgcolor = bgColor,
         border_color = boxColor)

    lbl3 := label.new(
         x = bar_index,
         y = low,
         text = "10:50 - 11:10 EST",
         style = label.style_label_up,
         color = boxColor,
         textcolor = textColor,
         size = size.small)

if in3
    box.set_right(box3, bar_index)
    box.set_top(box3, math.max(box.get_top(box3), high))
    box.set_bottom(box3, math.min(box.get_bottom(box3), low))

// =====================================================
// SESSION 4
// =====================================================
start4 = in4 and not in4[1]

if start4
    box4 := box.new(bar_index, high, bar_index, low,
         bgcolor = bgColor,
         border_color = boxColor)

    lbl4 := label.new(
         x = bar_index,
         y = low,
         text = "11:50 - 12:10 EST",
         style = label.style_label_up,
         color = boxColor,
         textcolor = textColor,
         size = size.small)

if in4
    box.set_right(box4, bar_index)
    box.set_top(box4, math.max(box.get_top(box4), high))
    box.set_bottom(box4, math.min(box.get_bottom(box4), low))

// =====================================================
// SESSION 5
// =====================================================
start5 = in5 and not in5[1]

if start5
    box5 := box.new(bar_index, high, bar_index, low,
         bgcolor = bgColor,
         border_color = boxColor)

    lbl5 := label.new(
         x = bar_index,
         y = low,
         text = "01:10 - 01:40 EST",
         style = label.style_label_up,
         color = boxColor,
         textcolor = textColor,
         size = size.small)

if in5
    box.set_right(box5, bar_index)
    box.set_top(box5, math.max(box.get_top(box5), high))
    box.set_bottom(box5, math.min(box.get_bottom(box5), low))

// =====================================================
// SESSION 6
// =====================================================
start6 = in6 and not in6[1]

if start6
    box6 := box.new(bar_index, high, bar_index, low,
         bgcolor = bgColor,
         border_color = boxColor)

    lbl6 := label.new(
         x = bar_index,
         y = low,
         text = "03:15 - 03:45 EST",
         style = label.style_label_up,
         color = boxColor,
         textcolor = textColor,
         size = size.small)

if in6
    box.set_right(box6, bar_index)
    box.set_top(box6, math.max(box.get_top(box6), high))
    box.set_bottom(box6, math.min(box.get_bottom(box6), low))
````
