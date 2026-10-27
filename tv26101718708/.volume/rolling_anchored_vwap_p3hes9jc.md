# Rolling Anchored VWAP

- url: https://www.tradingview.com/script/p3HeS9jC-Rolling-Anchored-VWAP/
- type: indicator
- pine_id: PUB;ddc7c1fed0de45429bc76b8d1c71bada
- version: 1.0

## Description

Rolling Anchored VWAP (RAVWAP) plots up to three independent, volume-weighted average price lines that roll forward bar by bar. Unlike session VWAP, which resets at the open, each line uses a moving anchor: at every bar, the window starts exactly N bars ago and runs through the current bar, so you get a continuously updating fair-value reference without session breaks.

Overview
VWAP is widely used by institutions to gauge whether price is trading above or below the volume-weighted average. This indicator extends that idea with rolling anchored windows of any length you choose — useful on any timeframe, including higher timeframes where session VWAP is less relevant.

Each VWAP is fully configurable: enable or disable it, set its own period, color, and line width, and optionally display volume-weighted standard deviation bands at ±1σ, ±2σ, and ±3σ.

How it works
For a given Period setting of N:

The anchor is placed N bars before the current bar
VWAP is calculated from that anchor through the current bar (inclusive)
On each new bar, the anchor advances by one bar
Example with Period = 100:

Bar 100 → VWAP over bars 0 through 100
Bar 101 → VWAP over bars 1 through 101
Bar 102 → VWAP over bars 2 through 102
The calculation uses efficient rolling sums, so it stays responsive even with periods in the hundreds or thousands.

Standard deviation bands use the same volume-weighted formula as TradingView’s built-in VWAP:

σ = √( Σ(V × P²) / Σ(V) − VWAP² )

Band toggles affect display only — they do not change the VWAP value.

Features
3 independent rolling VWAPs with separate periods (defaults: 100, 250, 500)
Individual enable/disable for each VWAP
Custom color and line width per VWAP
Optional ±1σ, ±2σ, ±3σ bands per VWAP
Optional filled band between ±1σ
Configurable source (default: HLC3)
Non-repainting — historical values are fixed after each bar closes
No session resets — continuous rolling windows on any timeframe
Overlay on price — plots directly on the chart scale

## Source Code

````pine
//@version=6
indicator("Rolling Anchored VWAP", shorttitle = "RAVWAP", overlay = true, max_bars_back = 5000)

// Source
src = input.source(hlc3, "Source", group = "Source")
fillBands = input.bool(false, "Fill Between +/-1 SD Bands", group = "Deviation Fill")

// VWAP #1
v1On    = input.bool(true, "Enable", group = "VWAP #1")
v1Per   = input.int(100, "Period", minval = 1, group = "VWAP #1",
     tooltip = "Anchor this many bars ago. VWAP spans anchor bar through current bar.")
v1Col   = input.color(color.new(#2962FF, 0), "Color", group = "VWAP #1")
v1Width = input.int(2, "Line Width", minval = 1, maxval = 4, group = "VWAP #1")
v1S1    = input.bool(false, "Show +/-1 SD", group = "VWAP #1")
v1S2    = input.bool(false, "Show +/-2 SD", group = "VWAP #1")
v1S3    = input.bool(false, "Show +/-3 SD", group = "VWAP #1")

// VWAP #2
v2On    = input.bool(false, "Enable", group = "VWAP #2")
v2Per   = input.int(250, "Period", minval = 1, group = "VWAP #2",
     tooltip = "Anchor this many bars ago. VWAP spans anchor bar through current bar.")
v2Col   = input.color(color.new(#FF6D00, 0), "Color", group = "VWAP #2")
v2Width = input.int(2, "Line Width", minval = 1, maxval = 4, group = "VWAP #2")
v2S1    = input.bool(false, "Show +/-1 SD", group = "VWAP #2")
v2S2    = input.bool(false, "Show +/-2 SD", group = "VWAP #2")
v2S3    = input.bool(false, "Show +/-3 SD", group = "VWAP #2")

// VWAP #3
v3On    = input.bool(false, "Enable", group = "VWAP #3")
v3Per   = input.int(500, "Period", minval = 1, group = "VWAP #3",
     tooltip = "Anchor this many bars ago. VWAP spans anchor bar through current bar.")
v3Col   = input.color(color.new(#AB47BC, 0), "Color", group = "VWAP #3")
v3Width = input.int(2, "Line Width", minval = 1, maxval = 4, group = "VWAP #3")
v3S1    = input.bool(false, "Show +/-1 SD", group = "VWAP #3")
v3S2    = input.bool(false, "Show +/-2 SD", group = "VWAP #3")
v3S3    = input.bool(false, "Show +/-3 SD", group = "VWAP #3")

// Precompute series used by all rolling windows (computed once, on price scale).
pv  = src * volume
p2v = src * src * volume

// Window length: anchor at bar [period], inclusive window = bars [period]..[0] = period + 1 bars.
windowLen(simple int period) =>
    period + 1

// Rolling anchored VWAP — O(1) rolling sums, independent of band settings.
rollingVwap(simple int period) =>
    len = windowLen(period)
    sumV = math.sum(volume, len)
    bar_index >= period and sumV > 0.0 ? math.sum(pv, len) / sumV : na

// Volume-weighted stdev: sqrt( sum(p^2*v)/sum(v) - vwap^2 ), same as TradingView VWAP bands.
rollingStdev(simple int period, series float vwapVal) =>
    len = windowLen(period)
    sumV = math.sum(volume, len)
    if bar_index < period or na(vwapVal) or sumV <= 0.0
        na
    else
        variance = math.sum(p2v, len) / sumV - vwapVal * vwapVal
        variance > 0.0 ? math.sqrt(variance) : 0.0

// Always compute VWAP and stdev separately so toggling bands never changes VWAP math.
vwap1 = rollingVwap(v1Per)
vwap2 = rollingVwap(v2Per)
vwap3 = rollingVwap(v3Per)

sd1 = rollingStdev(v1Per, vwap1)
sd2 = rollingStdev(v2Per, vwap2)
sd3 = rollingStdev(v3Per, vwap3)

ready1 = bar_index >= v1Per
ready2 = bar_index >= v2Per
ready3 = bar_index >= v3Per

showSd1 = v1S1 or v1S2 or v1S3
showSd2 = v2S1 or v2S2 or v2S3
showSd3 = v3S1 or v3S2 or v3S3

// Plots - VWAP lines (price scale)
plot(v1On and ready1 ? vwap1 : na, "VWAP #1", v1Col, v1Width, format = format.price)
plot(v2On and ready2 ? vwap2 : na, "VWAP #2", v2Col, v2Width, format = format.price)
plot(v3On and ready3 ? vwap3 : na, "VWAP #3", v3Col, v3Width, format = format.price)

// Plots - VWAP #1 bands (display only gated; VWAP value unchanged)
p1u = plot(v1On and showSd1 and v1S1 and ready1 ? vwap1 + sd1 : na, "VWAP #1 +1SD", color.new(v1Col, 35), 1, format = format.price)
p1l = plot(v1On and showSd1 and v1S1 and ready1 ? vwap1 - sd1 : na, "VWAP #1 -1SD", color.new(v1Col, 35), 1, format = format.price)
plot(v1On and showSd1 and v1S2 and ready1 ? vwap1 + 2.0 * sd1 : na, "VWAP #1 +2SD", color.new(v1Col, 55), 1, plot.style_circles, format = format.price)
plot(v1On and showSd1 and v1S2 and ready1 ? vwap1 - 2.0 * sd1 : na, "VWAP #1 -2SD", color.new(v1Col, 55), 1, plot.style_circles, format = format.price)
plot(v1On and showSd1 and v1S3 and ready1 ? vwap1 + 3.0 * sd1 : na, "VWAP #1 +3SD", color.new(v1Col, 70), 1, plot.style_cross, format = format.price)
plot(v1On and showSd1 and v1S3 and ready1 ? vwap1 - 3.0 * sd1 : na, "VWAP #1 -3SD", color.new(v1Col, 70), 1, plot.style_cross, format = format.price)
fill(p1u, p1l, v1On and showSd1 and v1S1 and fillBands and ready1 ? color.new(v1Col, 88) : na, "VWAP #1 Fill")

// Plots - VWAP #2 bands
p2u = plot(v2On and showSd2 and v2S1 and ready2 ? vwap2 + sd2 : na, "VWAP #2 +1SD", color.new(v2Col, 35), 1, format = format.price)
p2l = plot(v2On and showSd2 and v2S1 and ready2 ? vwap2 - sd2 : na, "VWAP #2 -1SD", color.new(v2Col, 35), 1, format = format.price)
plot(v2On and showSd2 and v2S2 and ready2 ? vwap2 + 2.0 * sd2 : na, "VWAP #2 +2SD", color.new(v2Col, 55), 1, plot.style_circles, format = format.price)
plot(v2On and showSd2 and v2S2 and ready2 ? vwap2 - 2.0 * sd2 : na, "VWAP #2 -2SD", color.new(v2Col, 55), 1, plot.style_circles, format = format.price)
plot(v2On and showSd2 and v2S3 and ready2 ? vwap2 + 3.0 * sd2 : na, "VWAP #2 +3SD", color.new(v2Col, 70), 1, plot.style_cross, format = format.price)
plot(v2On and showSd2 and v2S3 and ready2 ? vwap2 - 3.0 * sd2 : na, "VWAP #2 -3SD", color.new(v2Col, 70), 1, plot.style_cross, format = format.price)
fill(p2u, p2l, v2On and showSd2 and v2S1 and fillBands and ready2 ? color.new(v2Col, 88) : na, "VWAP #2 Fill")

// Plots - VWAP #3 bands
p3u = plot(v3On and showSd3 and v3S1 and ready3 ? vwap3 + sd3 : na, "VWAP #3 +1SD", color.new(v3Col, 35), 1, format = format.price)
p3l = plot(v3On and showSd3 and v3S1 and ready3 ? vwap3 - sd3 : na, "VWAP #3 -1SD", color.new(v3Col, 35), 1, format = format.price)
plot(v3On and showSd3 and v3S2 and ready3 ? vwap3 + 2.0 * sd3 : na, "VWAP #3 +2SD", color.new(v3Col, 55), 1, plot.style_circles, format = format.price)
plot(v3On and showSd3 and v3S2 and ready3 ? vwap3 - 2.0 * sd3 : na, "VWAP #3 -2SD", color.new(v3Col, 55), 1, plot.style_circles, format = format.price)
plot(v3On and showSd3 and v3S3 and ready3 ? vwap3 + 3.0 * sd3 : na, "VWAP #3 +3SD", color.new(v3Col, 70), 1, plot.style_cross, format = format.price)
plot(v3On and showSd3 and v3S3 and ready3 ? vwap3 - 3.0 * sd3 : na, "VWAP #3 -3SD", color.new(v3Col, 70), 1, plot.style_cross, format = format.price)
fill(p3u, p3l, v3On and showSd3 and v3S1 and fillBands and ready3 ? color.new(v3Col, 88) : na, "VWAP #3 Fill")
````
