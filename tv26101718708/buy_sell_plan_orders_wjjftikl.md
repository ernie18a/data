# BUY SELL PLAN ORDERS

- url: https://www.tradingview.com/script/wJjftIkL-BUY-SELL-PLAN-ORDERS/
- type: indicator
- pine_id: PUB;05ba8a809d7646fca471a22ca2210525
- version: 11.0

## Description

Buy Sell Plan Orders draws a personal trading plan on the chart: your average price, planned buy levels, planned sell levels, and markers for trades you already made. It does not generate signals or analyse price. It only displays the levels you type in.

How it works
The script reads three text inputs and draws each item as a labelled line or marker.

Levels: name|price|kind; where kind is a (average, dashed orange line), b (buy level, dotted blue line) or s (sell level, dotted green line). Example: Avg|128.5|a;Buy 2|115|b;Sell 1|150|s;
Trades: time|price|side; where time is a Unix timestamp in milliseconds and side is b (buy) or s (sell). Each trade shows as a small B or S marker at that price and date.
Lines: time1|price1|time2|price2|kind; where kind is t (trend line), r (ray), h (horizontal price line) or x (box).

Up to 10 levels, 12 trades and 12 lines. Labels sit to the right of the last bar so they don't cover the candles. Empty inputs draw nothing.

Use
Add the indicator, open its settings and fill the inputs. This keeps a plan visible on any symbol and timeframe without redrawing it by hand.

This script is for visualising your own plan only. It is not financial advice.

## Source Code

````pine
//@version=6
// Investing App plan levels; the app fills the inputs. Levels "name|price|kind;" (a avg, b buy, s sell).
// Trades "ms|price|side;" (b, s). Lines (third input) is kept for the app's input order and not drawn.
// Every level is a labelled line (founder 2026-10-02: show them all, even if the chart zooms out to fit them);
// labels are text only in the line's colour, just above it, no box (founder 2026-10-03).
// TradingView's auto-scale always fits every drawn line; the free widget can't change that. Trade marks (B/S)
// are no longer sent by the app. Moving levels is done in the app's "Drag on chart".
indicator("Plan levels", shorttitle = "Plan", overlay = true, max_lines_count = 50, max_labels_count = 100)
L = input.string("", "Levels")
T = input.string("", "Trades")
D = input.string("", "Lines")
// Label text size (founder 2026-10-13: Small too small, Large too big; default Normal, the middle size).
SZ = input.string("Normal", "Label size", options = ["Small", "Normal", "Large", "Huge"])
labelSize = SZ == "Small" ? size.small : SZ == "Normal" ? size.normal : SZ == "Huge" ? size.huge : size.large

cl(string k) => k == "a" ? #f5b942 : k == "b" ? #4f8cff : k == "s" ? #35c98f : #e8ebef
part(string s, int j) =>
    a = str.split(s, "|")
    array.size(a) > j ? array.get(a, j) : ""

// Every level also gets a coloured tag on the price scale (founder 2026-10-12/13): Avg now ("a") yellow, average if
// all buys fill ("f") white, planned buys ("b", up to 6) blue, sells ("s", up to 4) green. A plot with
// display.price_scale shows only that tag; the line itself stays the dashed/dotted one below. Pine needs a fixed
// number of plots, so the n-th level of each kind gets its own plot (na when there is none).
lvl(string k, int n) =>
    float r = na
    int c = 0
    for it in str.split(L, ";")
        if part(it, 2) == k
            if c == n
                r := str.tonumber(part(it, 1))
            c += 1
    r
var float avgNow = lvl("a", 0)
var float avgFill = lvl("f", 0)
var float b0 = lvl("b", 0)
var float b1 = lvl("b", 1)
var float b2 = lvl("b", 2)
var float b3 = lvl("b", 3)
var float b4 = lvl("b", 4)
var float b5 = lvl("b", 5)
var float s0 = lvl("s", 0)
var float s1 = lvl("s", 1)
var float s2 = lvl("s", 2)
var float s3 = lvl("s", 3)
plot(avgNow, "Avg now", color = #f5b942, display = display.price_scale, editable = false)
plot(avgFill, "Avg if all fill", color = #e8ebef, display = display.price_scale, editable = false)
plot(b0, "Buy", color = #4f8cff, display = display.price_scale, editable = false)
plot(b1, "Buy", color = #4f8cff, display = display.price_scale, editable = false)
plot(b2, "Buy", color = #4f8cff, display = display.price_scale, editable = false)
plot(b3, "Buy", color = #4f8cff, display = display.price_scale, editable = false)
plot(b4, "Buy", color = #4f8cff, display = display.price_scale, editable = false)
plot(b5, "Buy", color = #4f8cff, display = display.price_scale, editable = false)
plot(s0, "Sell", color = #35c98f, display = display.price_scale, editable = false)
plot(s1, "Sell", color = #35c98f, display = display.price_scale, editable = false)
plot(s2, "Sell", color = #35c98f, display = display.price_scale, editable = false)
plot(s3, "Sell", color = #35c98f, display = display.price_scale, editable = false)

// High and low of the bars on screen (the script runs again when you scroll or zoom).
inView = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
var float hi = na
var float lo = na
if inView
    hi := na(hi) ? high : math.max(hi, high)
    lo := na(lo) ? low : math.min(lo, low)
h100 = ta.highest(high, 100)
l100 = ta.lowest(low, 100)

var drawnLines = array.new<line>()
var drawnLabels = array.new<label>()

if barstate.islast
    for x in drawnLines
        line.delete(x)
    for x in drawnLabels
        label.delete(x)
    array.clear(drawnLines)
    array.clear(drawnLabels)
    float top = na(hi) ? h100 : hi
    float bot = na(lo) ? l100 : lo
    float pad = (top - bot) * 0.05
    for it in str.split(L, ";")
        float p = str.tonumber(part(it, 1))
        string k = part(it, 2)
        if not na(p)
            array.push(drawnLines, line.new(time, p, time + 1, p, xloc = xloc.bar_time, extend = extend.both, color = cl(k), style = k == "a" ? line.style_dashed : line.style_dotted))
            array.push(drawnLabels, label.new(bar_index + 2, p, part(it, 0), style = label.style_label_lower_left, color = color.new(#000000, 100), textcolor = cl(k), size = labelSize))
    for it in str.split(T, ";")
        float t = str.tonumber(part(it, 0))
        float p = str.tonumber(part(it, 1))
        bool b = part(it, 2) == "b"
        if not na(t) and not na(p) and p <= top + pad and p >= bot - pad
            array.push(drawnLabels, label.new(int(t), p, b ? "B" : "S", xloc = xloc.bar_time, style = b ? label.style_label_up : label.style_label_down, color = b ? #4f8cff : #35c98f, textcolor = color.white, size = size.tiny))
````
