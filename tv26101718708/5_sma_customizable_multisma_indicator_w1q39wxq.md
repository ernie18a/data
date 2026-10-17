# 5 SMA - Customizable Multi-SMA Indicator

- url: https://www.tradingview.com/script/W1q39wxq-5-SMA-Customizable-Multi-SMA-Indicator/
- type: indicator
- pine_id: PUB;95d948c30bb64659a2eacb0568c332b1
- version: 1.0

## Description

[b]5 SMA — Customizable Multi-SMA Indicator[/b]

A clean, all-in-one Simple Moving Average indicator that plots up to 5 SMAs on a single chart, so you don't need to load five separate instances cluttering your indicator list.

[b]Features:[/b]
[list]
[*]5 independent SMAs, each with its own show/hide toggle
[*]Fully customizable length, color, line thickness, and line style (solid/dashed/dotted) per SMA
[*]Shared source and offset inputs
[*]Sensible defaults out of the box: 20, 50, 100, 150, 200
[/list]

[b]Use cases:[/b]
[list]
[*]Trend-following setups using classic MA combinations (e.g. 50/200 golden cross, 20/50 short-term trend)
[*]Multi-timeframe confluence by stacking key MAs
[*]Dynamic support and resistance reference
[/list]

Just open the settings, toggle the SMAs you want, set your lengths, and style them however you like. Defaults can be reused across instruments without reconfiguring each time.

## Source Code

````pine
//@version=6
indicator(title="5 SMA", shorttitle="5 SMA", overlay=true, timeframe="", timeframe_gaps=true)

// Global inputs
src    = input(close, title="Source")
offset = input.int(0, title="Offset", minval=-500, maxval=500)

// SMA 1
g1     = "SMA 1"
show1  = input.bool(true,         "Show",   group=g1, inline="1")
len1   = input.int(20,  minval=1, title="Length", group=g1, inline="1")
col1   = input.color(color.blue,  "Color",  group=g1, inline="1")

// SMA 2
g2     = "SMA 2"
show2  = input.bool(true,           "Show",   group=g2, inline="2")
len2   = input.int(50,  minval=1,   title="Length", group=g2, inline="2")
col2   = input.color(color.orange,  "Color",  group=g2, inline="2")

// SMA 3
g3     = "SMA 3"
show3  = input.bool(true,          "Show",   group=g3, inline="3")
len3   = input.int(100, minval=1,  title="Length", group=g3, inline="3")
col3   = input.color(color.green,  "Color",  group=g3, inline="3")

// SMA 4
g4     = "SMA 4"
show4  = input.bool(true,         "Show",   group=g4, inline="4")
len4   = input.int(150, minval=1, title="Length", group=g4, inline="4")
col4   = input.color(color.red,   "Color",  group=g4, inline="4")

// SMA 5
g5     = "SMA 5"
show5  = input.bool(true,           "Show",   group=g5, inline="5")
len5   = input.int(200, minval=1,   title="Length", group=g5, inline="5")
col5   = input.color(color.purple,  "Color",  group=g5, inline="5")

// Calculations
sma1 = ta.sma(src, len1)
sma2 = ta.sma(src, len2)
sma3 = ta.sma(src, len3)
sma4 = ta.sma(src, len4)
sma5 = ta.sma(src, len5)

// Plots
plot(show1 ? sma1 : na, title="SMA 1", color=col1, offset=offset)
plot(show2 ? sma2 : na, title="SMA 2", color=col2, offset=offset)
plot(show3 ? sma3 : na, title="SMA 3", color=col3, offset=offset)
plot(show4 ? sma4 : na, title="SMA 4", color=col4, offset=offset)
plot(show5 ? sma5 : na, title="SMA 5", color=col5, offset=offset)
````
