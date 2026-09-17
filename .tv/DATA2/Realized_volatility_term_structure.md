<!-- tradingview-pine-id: PUB;d3b8c6158bcf416aa6a2852e18b624a9 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Realized volatility term structure

Source: https://www.tradingview.com/script/S5b6jujU-Realized-volatility-term-structure/

## Description

Volatility has a curve too. See whether the short end is screaming or sleeping.

Description

Measures realized volatility of bar returns over five horizons at once, from short to long, and draws the resulting curve at the right edge of the pane so you can see its shape rather than a single number.

How it calculates

Realized volatility at each horizon is the population standard deviation of log returns over that many bars, scaled by the square root of the number of bars in a year for the current timeframe, shown as a percentage. The plotted history is horizon one divided by horizon five. The curve is drawn as four connected segments through five points placed just past the last bar, each point's height equal to that horizon's volatility divided by the longest horizon's.

How to read it

Above 1.0 the short end is running hotter than the long end, which is what a fresh shock looks like. Below 1.0 the short end is quieter than the long end, which is what compression looks like. The pane shades amber while the short end is elevated. The curve at the right edge is normalized to the longest horizon so its shape is comparable across instruments and timeframes. Each point is labeled with its horizon in bars and its annualized value.

Repainting

Closed bars do not repaint. The live bar updates until it closes. The curve at the right edge is redrawn on the last bar only.

Originality and attribution

Realized volatility over a window is standard. What is original here is presenting it as a term structure: five horizons measured together, the short-to-long ratio tracked through time, and the live curve drawn on the chart as connected points. This is not derived from and does not reuse code from any existing published script.

Honest limitations

Realized volatility is backward looking by construction. The short end reacts within a few bars. The long end takes as many bars as its horizon to fully reflect a change.
Annualization is a display convention. The trading-minutes-per-day and days-per-year inputs only scale the percentages shown.
On timeframes above daily the annualization assumes 52 weekly or 12 monthly bars per year.
The elevated and subdued thresholds are conventions, not calibrations.
Five horizons is a choice. The curve between them is a straight line.
Nothing here is a signal. An elevated short end is not a direction.

---

## Source Code

````pine
//@version=6
// =====================================================================
// Realized volatility term structure
//
// What this does
// Measures realized volatility of bar returns over five horizons at
// once, from short to long, and draws the resulting curve at the right
// edge of the pane so you can see its shape rather than one number.
//
// The plotted history is the ratio of the shortest horizon to the
// longest. Above 1.0 the short end is running hotter than the long end,
// which is what a fresh shock looks like. Below 1.0 the short end is
// quieter than the long end, which is what compression looks like. The
// curve at the right edge is normalized to the longest horizon so its
// shape is directly comparable across instruments and timeframes, and
// each point is labeled with its annualized value.
//
// Repainting
// Closed bars do not repaint. The live bar updates until it closes.
// The curve at the right edge is redrawn on the last bar only.
//
// Originality and attribution
// Realized volatility over a window is standard. What is original here
// is presenting it as a term structure: five horizons measured together,
// the short-to-long ratio tracked through time, and the live curve
// itself drawn on the chart as connected points. This is not derived
// from and does not reuse code from any existing published script.
//
// Timeframe requirements
// Any timeframe, intraday or higher. Annualization adapts: intraday uses the
// trading-minutes-per-day and days-per-year inputs, daily uses days-per-year,
// weekly assumes 52 and monthly assumes 12. The inputs scale the displayed
// percentages only; they do not affect the ratio or the curve shape.
//
// Honest limitations
// - Realized volatility is backward looking by construction. The short
//   end reacts within a few bars. The long end takes as many bars as
//   its horizon to fully reflect a change.
// - Annualization is a display convention. The trading-minutes-per-day
//   and days-per-year inputs only scale the percentages shown. They do
//   not affect the ratio or the curve shape.
// - On timeframes above daily the annualization assumes 52 weekly or 12
//   monthly bars per year.
// - The elevated and subdued thresholds are conventions exposed as
//   inputs, not calibrations.
// - Five horizons is a choice. The curve between them is a straight
//   line, not an interpolation of anything real.
// - Nothing here is a signal. An elevated short end is not a direction.
// =====================================================================

indicator("Realized volatility term structure", shorttitle = "RV Curve", overlay = false, precision = 2, max_lines_count = 10, max_labels_count = 10)

// ---------------------------------------------------------------------
// Palette. Shared by every free script so they read as one family.
// Green is the label voice. Amber is attention. Red is reserved for the
// state where there is nothing to work with. Grey is absence.
// ---------------------------------------------------------------------
color MZ_GREEN = #54c98a
color MZ_AMBER = #d98a2b
color MZ_LIT = #f5f4f0
color MZ_LIT2 = #b9b8b2
color MZ_MUTE = #8b8983
color MZ_INK = #16181c

tblLabel(table t, int row, string s) =>
    table.cell(t, 0, row, s, text_size = size.small, text_color = MZ_GREEN, bgcolor = color.new(MZ_INK, 0))

tblValue(table t, int row, string s) =>
    table.cell(t, 1, row, s, text_size = size.small, text_color = MZ_LIT, bgcolor = color.new(MZ_INK, 0))


// ---------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------
h1 = input.int(10, "Horizon 1 (bars)", minval = 2, maxval = 5000)
h2 = input.int(30, "Horizon 2 (bars)", minval = 3, maxval = 5000)
h3 = input.int(60, "Horizon 3 (bars)", minval = 4, maxval = 5000)
h4 = input.int(120, "Horizon 4 (bars)", minval = 5, maxval = 5000)
h5 = input.int(240, "Horizon 5 (bars)", minval = 6, maxval = 5000)
minsPerDay = input.int(1380, "Trading minutes per day", minval = 60, maxval = 1440, tooltip = "Only affects the annualized percentages shown. 1380 for a 23 hour futures session, 390 for a 6.5 hour equity session.")
daysPerYear = input.int(252, "Trading days per year", minval = 200, maxval = 365)
elevated = input.float(1.10, "Short end elevated at or above", minval = 1.0, maxval = 3.0, step = 0.05)
subdued = input.float(0.90, "Short end subdued at or below", minval = 0.1, maxval = 1.0, step = 0.05)
showCurve = input.bool(true, "Draw the curve at the right edge")
shadeShift = input.bool(true, "Shade the pane while the short end is elevated")
showTable = input.bool(true, "Show detail")

if barstate.isfirst
    if not (h1 < h2 and h2 < h3 and h3 < h4 and h4 < h5)
        runtime.error("Horizons must be strictly increasing from 1 to 5.")
    if subdued >= elevated
        runtime.error("The subdued threshold must be below the elevated threshold.")

// ---------------------------------------------------------------------
// Annualization factor
// ---------------------------------------------------------------------
tfSec = timeframe.in_seconds()
float barsPerYear = 12.0
if timeframe.isintraday
    barsPerYear := (minsPerDay * 60.0 / tfSec) * daysPerYear
else if timeframe.isdaily
    barsPerYear := daysPerYear
else if timeframe.isweekly
    barsPerYear := 52.0
float annFactor = math.sqrt(barsPerYear)

// ---------------------------------------------------------------------
// Realized vol at five horizons, annualized, in percent.
// Population standard deviation of log returns.
// ---------------------------------------------------------------------
float r = math.log(close / close[1])
float rv1 = ta.stdev(r, h1, true) * annFactor * 100.0
float rv2 = ta.stdev(r, h2, true) * annFactor * 100.0
float rv3 = ta.stdev(r, h3, true) * annFactor * 100.0
float rv4 = ta.stdev(r, h4, true) * annFactor * 100.0
float rv5 = ta.stdev(r, h5, true) * annFactor * 100.0

float ratio = na
if not na(rv5) and rv5 > 0 and not na(rv1)
    ratio := rv1 / rv5

string shape = "warming"
if not na(ratio)
    if ratio >= elevated
        shape := "short end elevated"
    else if ratio <= subdued
        shape := "short end subdued"
    else
        shape := "flat"

// ---------------------------------------------------------------------
// Plot
// ---------------------------------------------------------------------
color rColor = color.new(MZ_LIT2, 0)
if na(ratio)
    rColor := color.new(MZ_MUTE, 100)
else if ratio >= elevated
    rColor := color.new(MZ_AMBER, 0)
else if ratio <= subdued
    rColor := color.new(MZ_GREEN, 0)

bgcolor(shadeShift and shape == "short end elevated" ? color.new(MZ_AMBER, 92) : na, title = "Elevated shading")

plot(ratio, "Short to long realized vol ratio", color = rColor, linewidth = 2)

hline(1.0, "Flat", color = color.new(MZ_MUTE, 50), linestyle = hline.style_solid)
hline(elevated, "Elevated", color = color.new(MZ_AMBER, 60), linestyle = hline.style_dashed)
hline(subdued, "Subdued", color = color.new(MZ_GREEN, 60), linestyle = hline.style_dashed)

// ---------------------------------------------------------------------
// Live curve at the right edge, normalized to the longest horizon.
// Objects are created once on the last bar and updated in place.
// ---------------------------------------------------------------------
var array<line> segs = array.new<line>(0)
var array<label> labs = array.new<label>(0)

if showCurve and barstate.islast and not na(ratio)
    if array.size(segs) == 0
        for i = 0 to 3
            array.push(segs, line.new(bar_index, 1.0, bar_index, 1.0, xloc = xloc.bar_index, color = color.new(MZ_LIT2, 0), width = 2))
        for i = 0 to 4
            array.push(labs, label.new(bar_index, 1.0, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(MZ_MUTE, 100), textcolor = MZ_LIT, size = size.small))
    xs = array.from(bar_index + 4, bar_index + 8, bar_index + 12, bar_index + 16, bar_index + 20)
    ys = array.from(rv1 / rv5, rv2 / rv5, rv3 / rv5, rv4 / rv5, 1.0)
    hs = array.from(h1, h2, h3, h4, h5)
    vs = array.from(rv1, rv2, rv3, rv4, rv5)
    for i = 0 to 3
        line.set_xy1(array.get(segs, i), array.get(xs, i), array.get(ys, i))
        line.set_xy2(array.get(segs, i), array.get(xs, i + 1), array.get(ys, i + 1))
    for i = 0 to 4
        lb = array.get(labs, i)
        label.set_xy(lb, array.get(xs, i), array.get(ys, i))
        label.set_text(lb, str.tostring(array.get(hs, i)) + "b  " + str.tostring(array.get(vs, i), "0.#") + "%")

// ---------------------------------------------------------------------
// Detail
// ---------------------------------------------------------------------
var table info = table.new(position.top_right, 2, 7, border_width = 1, frame_width = 1, frame_color = color.new(MZ_MUTE, 60), border_color = color.new(MZ_MUTE, 70))

if showTable and barstate.islast
    txt = color.new(MZ_MUTE, 0)
    bg = color.new(MZ_MUTE, 90)
    string rTxt = na(ratio) ? "-" : str.tostring(ratio, "0.00")
    tblLabel(info, 0, "Shape")
    tblValue(info, 0, shape)
    tblLabel(info, 1, "Short / long")
    tblValue(info, 1, rTxt)
    tblLabel(info, 2, str.tostring(h1) + " bars")
    tblValue(info, 2, na(rv1) ? "-" : str.tostring(rv1, "0.#") + "%")
    tblLabel(info, 3, str.tostring(h2) + " bars")
    tblValue(info, 3, na(rv2) ? "-" : str.tostring(rv2, "0.#") + "%")
    tblLabel(info, 4, str.tostring(h3) + " bars")
    tblValue(info, 4, na(rv3) ? "-" : str.tostring(rv3, "0.#") + "%")
    tblLabel(info, 5, str.tostring(h4) + " bars")
    tblValue(info, 5, na(rv4) ? "-" : str.tostring(rv4, "0.#") + "%")
    tblLabel(info, 6, str.tostring(h5) + " bars")
    tblValue(info, 6, na(rv5) ? "-" : str.tostring(rv5, "0.#") + "%")
````
