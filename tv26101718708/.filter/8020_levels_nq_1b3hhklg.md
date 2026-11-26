# 80-20 Levels (NQ)

- url: https://www.tradingview.com/script/1B3Hhklg-80-20-Levels-NQ/
- type: indicator
- pine_id: PUB;f369037e46194e5da5a915f87e2124a8
- version: 1.0

## Description

80-20 Levels (NQ) plots psychological round-number price levels for Nasdaq futures (NQ) and color-codes them relative to VWAP. The idea: prices ending in .80 and .20 (e.g. 28,780.00, 29,520.00) act as recurring magnet/reaction zones intraday. Pairing them with VWAP gives you instant context on whether each level sits in "premium" (above VWAP) or "discount" (below VWAP) territory.

What it does
80/20 levels — draws horizontal lines at every price ending in .80 and .20, automatically re-centered around live VWAP as price moves.
VWAP-relative coloring — levels above VWAP are red, levels below VWAP are green, so bias is readable at a glance.
VWAP line — standard intraday session VWAP (resets each session), plotted in orange.
Price-axis labels — each level's price prints as a color-matched tag directly on the right-hand price scale.
New York session range box — a table showing the total NY session range (high − low) plus the session high/low, in the corner of your choice.
Settings
Setting	Description
Levels past VWAP (each side)	How many 80/20 levels to show on each side of VWAP. e.g. 4 = 4 green levels below VWAP and 4 red levels above (1–10).
Show VWAP	Show/hide the VWAP line.
Show price-axis labels	Show/hide the per-level price tags on the right axis.
Above VWAP color	Color for levels above VWAP (default red).
Below VWAP color	Color for levels below VWAP (default green).
Level line width	Thickness of the level lines (1–4).
Show NY session range	Show/hide the session-range box.
Range box position	Corner/edge for the box (Top Right, Top Center, Top Left, Middle Right/Left, Bottom Right/Center/Left).
Range box size	Text size: Tiny / Small / Normal / Large / Huge.
New York session	Session window (default 0930-1600).
Session timezone	Default America/New_York.
⚠️ Required setup: enable price-axis labels
The level price tags use Pine's display.price_scale, which only renders if the chart's price scale has value labels enabled. This is a one-time chart setting, not part of the script — so include this in your published description:

Right-click the price scale (the price axis on the right edge of the chart).
Hover Labels in the menu that appears.
Click "Indicators and financials value labels" so it shows a checkmark.
The red/green level tags will appear on the axis immediately. If this option is off, the levels still draw on the chart but the axis price tags won't show.

Notes: this is a per-chart/layout setting and applies to all indicators' value labels, so you'll need to enable it on any new chart where you add the indicator. The indicator's own "Show price-axis labels" toggle controls whether this indicator contributes tags.

Suggested use
Designed for NQ (also works on MNQ / NQ1!). The .80/.20 logic assumes NQ's price magnitude; on very different instruments the spacing won't be meaningful.
Best on intraday timeframes where VWAP and the NY session are relevant.
Watch for reactions as price approaches a level; use the red/green VWAP context to frame whether you're fading into premium or buying discount.

## Source Code

````pine
//@version=6
indicator("80-20 Levels (NQ)", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ================= Inputs =================
pastVwap   = input.int(4, "Levels past VWAP (each side)", minval = 1, maxval = 10, tooltip = "How many 80/20 levels to show on EACH side of VWAP. e.g. 4 = 4 green levels below VWAP and 4 red levels above.")
showVwap   = input.bool(true, "Show VWAP")
showLabels = input.bool(true, "Show price-axis labels")
aboveCol   = input.color(color.new(color.red, 0),   "Above VWAP color")
belowCol   = input.color(color.new(color.green, 0), "Below VWAP color")
lineWidth  = input.int(1, "Level line width", minval = 1, maxval = 4)

// New York session range
showRange  = input.bool(true, "Show NY session range", group = "NY Session Range")
rangePosIn = input.string("Top Right", "Range box position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = "NY Session Range")
rangeSzIn  = input.string("Small", "Range box size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "NY Session Range")
nySession  = input.session("0930-1600", "New York session", group = "NY Session Range")
nyTz       = input.string("America/New_York", "Session timezone", group = "NY Session Range")

// ================= Helpers =================
f_pos(s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        => position.top_right

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

// ================= VWAP =================
vwapVal = ta.vwap(hlc3)
plot(showVwap ? vwapVal : na, "VWAP", color = color.new(color.orange, 0), linewidth = 2)

// ================= Build 80/20 levels around VWAP =================
// aboveArr ascending (nearest above = index 0), belowArr ascending (nearest below = last index)
var float[] aboveArr = array.new_float()
var float[] belowArr = array.new_float()

array.clear(aboveArr)
array.clear(belowArr)

if not na(vwapVal)
    startH = math.floor(vwapVal / 100) * 100 - 12 * 100
    for k = 0 to 24
        h = startH + k * 100
        offs = array.from(20.0, 80.0)
        for off in offs
            lvl = h + off
            if lvl > vwapVal
                array.push(aboveArr, lvl)
            else if lvl < vwapVal
                array.push(belowArr, lvl)

// k-th nearest level past VWAP (1-indexed); na when beyond user count or unavailable
f_above(k) => k <= pastVwap and array.size(aboveArr) >= k ? array.get(aboveArr, k - 1) : na
f_below(k) => k <= pastVwap and array.size(belowArr) >= k ? array.get(belowArr, array.size(belowArr) - k) : na

// ================= Draw level lines on the chart =================
var line[] lvlLines = array.new_line()

if barstate.islast
    for ln in lvlLines
        line.delete(ln)
    array.clear(lvlLines)
    leftX  = bar_index - 300
    rightX = bar_index
    for k = 1 to pastVwap
        a = f_above(k)
        b = f_below(k)
        if not na(a)
            array.push(lvlLines, line.new(leftX, a, rightX, a, xloc = xloc.bar_index, extend = extend.both, color = aboveCol, width = lineWidth))
        if not na(b)
            array.push(lvlLines, line.new(leftX, b, rightX, b, xloc = xloc.bar_index, extend = extend.both, color = belowCol, width = lineWidth))

// ================= Price-axis labels =================
// plots with display.price_scale show ONLY a colored value tag on the right axis (no line in the pane)
psd = showLabels ? display.price_scale : display.none
plot(f_above(1),  "A1",  color = aboveCol, display = psd)
plot(f_above(2),  "A2",  color = aboveCol, display = psd)
plot(f_above(3),  "A3",  color = aboveCol, display = psd)
plot(f_above(4),  "A4",  color = aboveCol, display = psd)
plot(f_above(5),  "A5",  color = aboveCol, display = psd)
plot(f_above(6),  "A6",  color = aboveCol, display = psd)
plot(f_above(7),  "A7",  color = aboveCol, display = psd)
plot(f_above(8),  "A8",  color = aboveCol, display = psd)
plot(f_above(9),  "A9",  color = aboveCol, display = psd)
plot(f_above(10), "A10", color = aboveCol, display = psd)
plot(f_below(1),  "B1",  color = belowCol, display = psd)
plot(f_below(2),  "B2",  color = belowCol, display = psd)
plot(f_below(3),  "B3",  color = belowCol, display = psd)
plot(f_below(4),  "B4",  color = belowCol, display = psd)
plot(f_below(5),  "B5",  color = belowCol, display = psd)
plot(f_below(6),  "B6",  color = belowCol, display = psd)
plot(f_below(7),  "B7",  color = belowCol, display = psd)
plot(f_below(8),  "B8",  color = belowCol, display = psd)
plot(f_below(9),  "B9",  color = belowCol, display = psd)
plot(f_below(10), "B10", color = belowCol, display = psd)

// ================= New York Session Range =================
inNy  = not na(time(timeframe.period, nySession, nyTz))
newNy = inNy and not inNy[1]

var float nyHigh = na
var float nyLow  = na

if newNy
    nyHigh := high
    nyLow  := low
else if inNy
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow, low)

nyRange = nyHigh - nyLow

var table t = table.new(f_pos(rangePosIn), 2, 3, border_width = 1, frame_color = color.new(color.gray, 50), frame_width = 1)

if barstate.islast and showRange
    sz = f_size(rangeSzIn)
    table.cell(t, 0, 0, "NY Session Range", text_color = color.white, bgcolor = color.new(color.blue, 0), text_size = sz)
    table.cell(t, 1, 0, "", bgcolor = color.new(color.blue, 0))
    table.cell(t, 0, 1, "Range (pts)", text_color = color.white, bgcolor = color.new(color.black, 30), text_size = sz)
    table.cell(t, 1, 1, na(nyRange) ? "-" : str.tostring(nyRange, format.mintick), text_color = color.white, bgcolor = color.new(color.black, 30), text_size = sz)
    table.cell(t, 0, 2, "High / Low", text_color = color.white, bgcolor = color.new(color.black, 30), text_size = sz)
    table.cell(t, 1, 2, na(nyHigh) ? "-" : str.tostring(nyHigh, format.mintick) + " / " + str.tostring(nyLow, format.mintick), text_color = color.white, bgcolor = color.new(color.black, 30), text_size = sz)
else if not showRange
    table.clear(t, 0, 0, 1, 2)
````
