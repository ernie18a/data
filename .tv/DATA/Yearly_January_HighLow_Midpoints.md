<!-- tradingview-pine-id: PUB;733829186ea645c9b6a111933497665c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Yearly & January High/Low + Midpoints

Source: https://www.tradingview.com/script/FcIErkXf-Yearly-January-High-Low-Midpoints/

## Description

Yearly & January High/Low + Midpoints

This indicator plots key reference levels for price analysis: the yearly high, low, and midpoint for two configurable years (default 2024 and 2025), plus the high, low, and midpoint of a specific month (default January) across three configurable years (default 2024, 2025, 2026).

What it calculates:

Yearly High/Low — the highest high and lowest low printed within each selected calendar year, tracked bar-by-bar as the year progresses.
Monthly High/Low — same logic, restricted to a single month you choose (defaults to January, but any month works via the settings).
Midpoint — (High + Low) / 2 for each range above, calculated live from the tracked data rather than a fixed number, so it updates automatically if a new extreme prints.

How it's built: the script reads year(time) and month(time) on each bar to detect which calendar year/month it's in, then maintains a running max/min for that period using persistent (var) variables. Once a year or month is fully in the past, its high/low is final; the current year's numbers will keep updating live until that year closes.

On the chart: all levels plot as horizontal reference lines (color-coded per year), and a summary table (position configurable) lays out every High/Low/Mid value in one clean grid so you don't have to trace individual lines across a busy chart.

Settings: Year 1, Year 2, Year 3 (for the month-only row), target month, and toggles to show/hide the yearly lines, monthly lines, midpoints, floating labels, and the table independently.

Best used on: the Daily (1D) timeframe, since yearly/monthly aggregation needs enough historical bars loaded to compute correctly — on very short intraday timeframes it may not have enough chart history loaded to reach back to 2024.

---

## Source Code

````pine
//@version=6
indicator("Yearly & January High/Low + Midpoints", shorttitle="Yr/Jan HL+Mid", overlay=true, max_labels_count=20)

// ============================================================
// SETTINGS
// Apply this on the DAILY (1D) chart for accurate yearly/monthly
// tracking — lower timeframes will still work but recompute more
// often and are slower to load on long history.
// ============================================================
year1        = input.int(2024, "Year 1")
year2        = input.int(2025, "Year 2")
year3        = input.int(2026, "Year 3 (January only)")
targetMonth  = input.int(1, "Month for High/Low (1 = Jan)", minval = 1, maxval = 12)
showYearly   = input.bool(true, "Show yearly high/low")
showMonth    = input.bool(true, "Show month high/low")
showMid      = input.bool(true, "Show midpoints")
showLabels   = input.bool(false, "Show value labels on last bar")
showTable    = input.bool(true, "Show summary table")
tablePos     = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

yr = year(time)
mo = month(time)

tablePosMap(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left

// ============================================================
// RUNNING TRACKERS
// ============================================================
var float y1H = na
var float y1L = na
var float y2H = na
var float y2L = na
var float m1H = na
var float m1L = na
var float m2H = na
var float m2L = na
var float m3H = na
var float m3L = na

if yr == year1
    y1H := na(y1H) ? high : math.max(y1H, high)
    y1L := na(y1L) ? low  : math.min(y1L, low)
    if mo == targetMonth
        m1H := na(m1H) ? high : math.max(m1H, high)
        m1L := na(m1L) ? low  : math.min(m1L, low)

if yr == year2
    y2H := na(y2H) ? high : math.max(y2H, high)
    y2L := na(y2L) ? low  : math.min(y2L, low)
    if mo == targetMonth
        m2H := na(m2H) ? high : math.max(m2H, high)
        m2L := na(m2L) ? low  : math.min(m2L, low)

if yr == year3 and mo == targetMonth
    m3H := na(m3H) ? high : math.max(m3H, high)
    m3L := na(m3L) ? low  : math.min(m3L, low)

// ============================================================
// MIDPOINTS — computed directly from the tracked data above
// ============================================================
midY1 = (na(y1H) or na(y1L)) ? na : (y1H + y1L) / 2
midY2 = (na(y2H) or na(y2L)) ? na : (y2H + y2L) / 2
midM1 = (na(m1H) or na(m1L)) ? na : (m1H + m1L) / 2
midM2 = (na(m2H) or na(m2L)) ? na : (m2H + m2L) / 2
midM3 = (na(m3H) or na(m3L)) ? na : (m3H + m3L) / 2

// ============================================================
// PLOTS
// ============================================================
plot(showYearly ? y1H : na, "Year 1 High", color = color.new(color.red, 0),    linewidth = 1)
plot(showYearly ? y1L : na, "Year 1 Low",  color = color.new(color.green, 0),  linewidth = 1)
plot(showMid    ? midY1 : na, "Year 1 Mid", color = color.new(color.yellow, 0), linewidth = 1, style = plot.style_circles)

plot(showYearly ? y2H : na, "Year 2 High", color = color.new(color.red, 0),   linewidth = 2)
plot(showYearly ? y2L : na, "Year 2 Low",  color = color.new(color.green, 0), linewidth = 2)
plot(showMid    ? midY2 : na, "Year 2 Mid", color = color.new(color.yellow, 0), linewidth = 2, style = plot.style_circles)

plot(showMonth ? m1H : na, "Month High (Year 1)", color = color.new(color.orange, 30), linewidth = 1, style = plot.style_stepline)
plot(showMonth ? m1L : na, "Month Low (Year 1)",  color = color.new(color.blue, 30),   linewidth = 1, style = plot.style_stepline)
plot(showMid   ? midM1 : na, "Month Mid (Year 1)", color = color.new(color.white, 60), linewidth = 1, style = plot.style_circles)

plot(showMonth ? m2H : na, "Month High (Year 2)", color = color.new(color.orange, 0), linewidth = 1, style = plot.style_stepline)
plot(showMonth ? m2L : na, "Month Low (Year 2)",  color = color.new(color.blue, 0),   linewidth = 1, style = plot.style_stepline)
plot(showMid   ? midM2 : na, "Month Mid (Year 2)", color = color.new(color.white, 20), linewidth = 1, style = plot.style_circles)

plot(showMonth ? m3H : na, "Month High (Year 3)", color = color.new(color.fuchsia, 0), linewidth = 1, style = plot.style_stepline)
plot(showMonth ? m3L : na, "Month Low (Year 3)",  color = color.new(color.aqua, 0),    linewidth = 1, style = plot.style_stepline)
plot(showMid   ? midM3 : na, "Month Mid (Year 3)", color = color.new(color.silver, 20), linewidth = 1, style = plot.style_circles)

// ============================================================
// LABELS (last bar only, so the chart stays readable)
// ============================================================
f_label(yVal, txt, col) =>
    if not na(yVal)
        label.new(bar_index + 5, yVal, txt, style = label.style_label_left, color = color.new(col, 85), textcolor = col, size = size.small)

if showLabels and barstate.islast
    if showYearly
        f_label(y1H, str.tostring(year1) + " High " + str.tostring(y1H, "#.##"), color.red)
        f_label(y1L, str.tostring(year1) + " Low "  + str.tostring(y1L, "#.##"), color.green)
        f_label(y2H, str.tostring(year2) + " High " + str.tostring(y2H, "#.##"), color.red)
        f_label(y2L, str.tostring(year2) + " Low "  + str.tostring(y2L, "#.##"), color.green)
    if showMonth
        f_label(m1H, str.tostring(year1) + " Mo.High " + str.tostring(m1H, "#.##"), color.orange)
        f_label(m1L, str.tostring(year1) + " Mo.Low "  + str.tostring(m1L, "#.##"), color.blue)
        f_label(m2H, str.tostring(year2) + " Mo.High " + str.tostring(m2H, "#.##"), color.orange)
        f_label(m2L, str.tostring(year2) + " Mo.Low "  + str.tostring(m2L, "#.##"), color.blue)
        f_label(m3H, str.tostring(year3) + " Mo.High " + str.tostring(m3H, "#.##"), color.fuchsia)
        f_label(m3L, str.tostring(year3) + " Mo.Low "  + str.tostring(m3L, "#.##"), color.aqua)
    if showMid
        f_label(midY1, str.tostring(year1) + " Mid " + str.tostring(midY1, "#.##"), color.yellow)
        f_label(midY2, str.tostring(year2) + " Mid " + str.tostring(midY2, "#.##"), color.yellow)
        f_label(midM1, str.tostring(year1) + " Mo.Mid " + str.tostring(midM1, "#.##"), color.white)
        f_label(midM2, str.tostring(year2) + " Mo.Mid " + str.tostring(midM2, "#.##"), color.white)
        f_label(midM3, str.tostring(year3) + " Mo.Mid " + str.tostring(midM3, "#.##"), color.silver)

// ============================================================
// SUMMARY TABLE — the clean at-a-glance reference
// ============================================================
f_fmt(v) => na(v) ? "—" : str.tostring(v, "#.##")

var table refTable = table.new(tablePosMap(tablePos), 4, 6, border_width = 1, border_color = color.gray, bgcolor = color.new(color.black, 15))

if showTable and barstate.islast
    // header row
    table.cell(refTable, 0, 0, "Level", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    table.cell(refTable, 1, 0, "High",  text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    table.cell(refTable, 2, 0, "Low",   text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    table.cell(refTable, 3, 0, "Mid",   text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)

    // Year 1 yearly row
    table.cell(refTable, 0, 1, str.tostring(year1) + " Year",  text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 1, 1, f_fmt(y1H), text_color = color.red,    bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 2, 1, f_fmt(y1L), text_color = color.green,  bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 3, 1, f_fmt(midY1), text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)

    // Year 2 yearly row
    table.cell(refTable, 0, 2, str.tostring(year2) + " Year",  text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 1, 2, f_fmt(y2H), text_color = color.red,    bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 2, 2, f_fmt(y2L), text_color = color.green,  bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 3, 2, f_fmt(midY2), text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)

    // Year 1 month row
    table.cell(refTable, 0, 3, str.tostring(year1) + " Mo(" + str.tostring(targetMonth) + ")", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 1, 3, f_fmt(m1H), text_color = color.orange, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 2, 3, f_fmt(m1L), text_color = color.blue,   bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 3, 3, f_fmt(midM1), text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)

    // Year 2 month row
    table.cell(refTable, 0, 4, str.tostring(year2) + " Mo(" + str.tostring(targetMonth) + ")", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 1, 4, f_fmt(m2H), text_color = color.orange, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 2, 4, f_fmt(m2L), text_color = color.blue,   bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 3, 4, f_fmt(midM2), text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)

    // Year 3 month row
    table.cell(refTable, 0, 5, str.tostring(year3) + " Mo(" + str.tostring(targetMonth) + ")", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 1, 5, f_fmt(m3H), text_color = color.fuchsia, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 2, 5, f_fmt(m3L), text_color = color.aqua,    bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(refTable, 3, 5, f_fmt(midM3), text_color = color.silver, bgcolor = color.new(color.black, 0), text_size = size.small)
````
