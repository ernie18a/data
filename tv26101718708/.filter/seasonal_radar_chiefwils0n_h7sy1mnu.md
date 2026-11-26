# Seasonal Radar (chiefwils0n)

- url: https://www.tradingview.com/script/h7sy1MNU-Seasonal-Radar-chiefwils0n/
- type: indicator
- pine_id: PUB;8a3f0d63af444f6abde72b066c727ea9
- version: 1.0

## Description

[b]⚪️ Seasonal Radar — Monthly / Daily / Hourly[/b]

Three seasonality radars on one pane, each plotting the same metric — [b]the percentage of periods that closed up[/b] — across a different cyclical bucket:

[list]
[*][b]Monthly[/b] — by month of the year (Jan–Dec)
[*][b]Day of week[/b] — by weekday, sized to whatever the symbol actually trades
[*][b]Hour of day[/b] — by hour, pulled from intraday data
[/list]

Reading outward from the center means a bucket closed up more often; a spoke pulled toward the middle means it closed up less often. At a glance you can see which months, weekdays, and hours have historically leaned bullish for the symbol on your chart.

[b]Run this on a Daily chart.[/b] The indicator will prompt you if it's loaded on any other timeframe. The monthly radar samples a monthly context, the day-of-week radar counts the chart's own daily bars, and the hour-of-day radar reads 60-minute bars. Empty buckets — weekends for equities, off-session hours — are dropped automatically, so each radar only shows spokes for periods that have data.

[b]⚪️ Inputs[/b]

[list]
[*][b]Monthly start year[/b] — where the month-of-year count begins. Day and hour radars use all available history (note: TradingView limits how far back intraday history goes).
[*][b]Web width (bars)[/b] — horizontal size of each radar. Pine can't read the pane's pixel aspect ratio, so nudge this until the rings look circular.
[*][b]Axis scaling[/b] — choose how the radial axis is fit:
[list]
[*][b]Auto (per radar)[/b] — each web fits its own data range; best when month, day, and hour sit in different bands.
[*][b]Auto (shared)[/b] — one range across all three so levels are directly comparable side by side.
[*][b]Manual[/b] — fixed min (center) and max (outer ring).
[/list]
[*][b]Ring step %[/b] — spacing of the concentric gridlines.
[*][b]Colors[/b] — plot line, fill, and grid/spokes.
[/list]

[b]⚪️ Notes[/b]

This is a descriptive, historical tool — it summarizes how often price has closed up in each bucket over the available sample. It is not predictive and makes no forward-looking claim. Smaller samples (especially limited intraday history) produce noisier readings, so weight the monthly and daily radars more heavily than the hourly one on symbols with shallow data.

## Source Code

````pine
//@version=6
indicator("Seasonal Radar — Monthly / Daily / Hourly", overlay = false, max_polylines_count = 100, max_lines_count = 300, max_labels_count = 500)

// Run this on a DAILY chart. The three radars all plot the same "occurrences" metric
// (percent of periods that closed up) over different cyclical buckets:
//   • Monthly  — month of year   (request.security "1M")
//   • Daily    — day of week      (the chart's own daily bars)
//   • Hourly   — hour of day       (request.security_lower_tf "60")
// Empty buckets (e.g. weekends for equities, off-session hours) are dropped automatically,
// so the day/hour radars size their spoke count to whatever the symbol actually trades.

//#region ———————————————————— Inputs

string TT_SY = "The year to start the monthly seasonality count. Day/hour radars use all available history (intraday history is limited by TradingView)."
string TT_WB = "Horizontal radius of each web, in bars. Pine can't read the pane's pixel aspect ratio, so nudge this until the rings look circular."
string TT_AS = "How the radial axis is scaled:\n• 'Auto (per radar)' fits each web to its own data range — best when month/day/hour sit in different bands.\n• 'Auto (shared)' uses one range across all three so levels are directly comparable.\n• 'Manual' uses the fixed Min/Max below."
string TT_AX = "Used only in Manual scaling. 'Min' sits at the center, 'Max' at the outer ring."

int    startYearInput = input.int(2010, "Monthly start year", minval = 1800, tooltip = TT_SY, display = display.none)

string GEO_GRP    = "Web geometry"
int    widthBars  = input.int(24, "Web width (bars)", minval = 6, maxval = 200, group = GEO_GRP, tooltip = TT_WB, display = display.none)
string scaleMode  = input.string("Auto (per radar)", "Axis scaling", options = ["Auto (per radar)", "Auto (shared)", "Manual"], group = GEO_GRP, tooltip = TT_AS, display = display.none)
float  tickStep   = input.float(10, "Ring step %", minval = 1, maxval = 50, group = GEO_GRP, display = display.none)
float  axisMinMan = input.float(40, "Manual axis min (center) %", minval = 0, maxval = 100, group = GEO_GRP, tooltip = TT_AX, display = display.none)
float  axisMaxMan = input.float(90, "Manual axis max (outer) %",  minval = 0, maxval = 100, group = GEO_GRP, tooltip = TT_AX, display = display.none)

string COLOR_GRP = "Colors"
color  lineColor = input.color(#7F77DD, "Plot line",  group = COLOR_GRP)
color  fillColor = input.color(color.new(#7F77DD, 80), "Plot fill", group = COLOR_GRP)
color  gridColor = input.color(color.new(color.gray, 55), "Grid / spokes", group = COLOR_GRP)
//#endregion


//#region ———————————————————— Shared geometry

float RY = 100.0     // vertical radius in (arbitrary, hidden) price units
float CY = 0.0       // vertical center
int   RX = widthBars // horizontal radius in bars

// Drawing registries — cleared and rebuilt on every realtime repaint of the last bar.
var array<polyline> polys  = array.new<polyline>()
var array<line>     lines  = array.new<line>()
var array<label>    labels = array.new<label>()

//@function Maps an occurrence value to a 0..1 radius for the given axis bounds.
nrm(float v, float lo, float hi) => na(v) ? na : math.max(0.0, math.min(1.0, (v - lo) / (hi - lo)))

//@function The one-bar change percentage of `source`, in the calling context's timeframe.
changePercent(float source) => 100.0 * (source - source[1]) / math.abs(source[1])

//@function The min and max of the non-na values in `vals` (both na if the array is empty).
f_range(array<float> vals) =>
    float lo = na
    float hi = na
    for v in vals
        if not na(v)
            lo := na(lo) ? v : math.min(lo, v)
            hi := na(hi) ? v : math.max(hi, v)
    [lo, hi]

//@function Snaps a raw data range outward to the nearest tick gridlines, with headroom and clamping.
f_axis(float rawLo, float rawHi) =>
    float lo = na(rawLo) ? axisMinMan : math.floor(rawLo / tickStep) * tickStep
    float hi = na(rawHi) ? axisMaxMan : math.ceil(rawHi / tickStep) * tickStep
    if not na(rawLo) and rawLo <= lo + 0.0001
        lo -= tickStep
    if not na(rawHi) and rawHi >= hi - 0.0001
        hi += tickStep
    lo := math.max(0.0, lo)
    hi := math.min(100.0, hi)
    if hi - lo < tickStep
        hi := math.min(100.0, lo + tickStep)
    [lo, hi]

//@function Keeps only buckets with at least one sample, returning the occurrence % and label for each.
compact(array<int> pos, array<int> tot, array<string> allLabels) =>
    array<float>  vals = array.new<float>()
    array<string> labs = array.new<string>()
    for i = 0 to tot.size() - 1
        if tot.get(i) > 0
            vals.push(100.0 * pos.get(i) / tot.get(i))
            labs.push(allLabels.get(i))
    [vals, labs]

//@function Draws one radar centered at bar index `cx`, with its own axis bounds `axLo`/`axHi`.
drawRadar(int cx, array<float> vals, array<string> labs, string title, float axLo, float axHi) =>
    int n      = vals.size()
    int nRings = int(math.round((axHi - axLo) / tickStep))
    if n >= 3
        // Concentric grid rings.
        for k = 1 to nRings
            float nr = nrm(axLo + k * tickStep, axLo, axHi)
            array<chart.point> ring = array.new<chart.point>()
            for i = 0 to n - 1
                float th = (90.0 - 360.0 / n * i) * math.pi / 180.0
                ring.push(chart.point.from_index(int(cx + RX * nr * math.cos(th)), CY + RY * nr * math.sin(th)))
            polys.push(polyline.new(ring, closed = true, xloc = xloc.bar_index, line_color = gridColor, line_width = 1))
        // Spokes + outer spoke labels.
        for i = 0 to n - 1
            float th = (90.0 - 360.0 / n * i) * math.pi / 180.0
            lines.push(line.new(cx, CY, int(cx + RX * math.cos(th)), CY + RY * math.sin(th), xloc = xloc.bar_index, color = gridColor, width = 1))
            labels.push(label.new(int(cx + RX * 1.18 * math.cos(th)), CY + RY * 1.18 * math.sin(th), labs.get(i), xloc = xloc.bar_index, style = label.style_none, textcolor = color.new(chart.fg_color, 15), size = size.small))
        // Axis tick numbers up the top spoke.
        for k = 1 to nRings
            float tv = axLo + k * tickStep
            labels.push(label.new(cx, CY + RY * nrm(tv, axLo, axHi), str.tostring(tv, "#"), xloc = xloc.bar_index, style = label.style_label_center, textcolor = color.new(chart.fg_color, 25), color = color.new(color.gray, 70), size = size.tiny))
        // Data polygon + vertex dots.
        array<chart.point> web = array.new<chart.point>()
        for i = 0 to n - 1
            float v  = vals.get(i)
            float nr = na(v) ? 0.0 : nrm(v, axLo, axHi)
            float th = (90.0 - 360.0 / n * i) * math.pi / 180.0
            int   x  = int(cx + RX * nr * math.cos(th))
            float y  = CY + RY * nr * math.sin(th)
            web.push(chart.point.from_index(x, y))
            if not na(v)
                labels.push(label.new(x, y, "●", xloc = xloc.bar_index, style = label.style_none, textcolor = lineColor, size = size.tiny))
        polys.push(polyline.new(web, closed = true, xloc = xloc.bar_index, line_color = lineColor, fill_color = fillColor, line_width = 2))
        // Title.
        labels.push(label.new(cx, CY + RY * 1.5, title, xloc = xloc.bar_index, style = label.style_none, textcolor = color.new(chart.fg_color, 0), size = size.normal))
//#endregion


//#region ———————————————————— Occurrence counters

// --- Monthly: counted in the "1M" context, one bucket per month of year. ---
f_occMonth(int startYear) =>
    var array<int> tot = array.new<int>(12, 0)
    var array<int> pos = array.new<int>(12, 0)
    float chg = changePercent(close)
    int   b   = month(time) - 1
    if year(time) >= startYear and not na(chg)
        tot.set(b, tot.get(b) + 1)
        if chg >= 0
            pos.set(b, pos.get(b) + 1)
    [pos, tot]
[posM, totM] = request.security(syminfo.tickerid, "1M", f_occMonth(startYearInput), lookahead = barmerge.lookahead_on)

// --- Daily: counted from the chart's own daily bars, one bucket per weekday (Sun..Sat). ---
var array<int> totD = array.new<int>(7, 0)
var array<int> posD = array.new<int>(7, 0)
float chgD = changePercent(close)
if barstate.isconfirmed and not na(chgD)
    int bD = dayofweek - 1
    totD.set(bD, totD.get(bD) + 1)
    if chgD >= 0
        posD.set(bD, posD.get(bD) + 1)

// --- Hourly: every intraday "60" bar pulled per daily bar, one bucket per hour of day. ---
[hArr, chgArr] = request.security_lower_tf(syminfo.tickerid, "60", [hour(time), changePercent(close)])
var array<int> totH = array.new<int>(24, 0)
var array<int> posH = array.new<int>(24, 0)
if barstate.isconfirmed and hArr.size() > 0
    for [idx, hh] in hArr
        float c = chgArr.get(idx)
        if not na(hh) and not na(c)
            totH.set(hh, totH.get(hh) + 1)
            if c >= 0
                posH.set(hh, posH.get(hh) + 1)
//#endregion


//#region ———————————————————— Layout

var monthLabels = array.from("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
var dowLabels   = array.from("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
var hourLabels  = array.from("0h","1h","2h","3h","4h","5h","6h","7h","8h","9h","10h","11h","12h","13h","14h","15h","16h","17h","18h","19h","20h","21h","22h","23h")

if barstate.islast
    // Clear prior drawings (last bar repaints on every realtime tick).
    for p in polys
        polyline.delete(p)
    for l in lines
        line.delete(l)
    for lb in labels
        label.delete(lb)
    polys.clear()
    lines.clear()
    labels.clear()

    if not timeframe.isdaily
        label.new(bar_index, CY, "Run this indicator on a Daily chart", xloc = xloc.bar_index, style = label.style_label_left, textcolor = chart.bg_color, color = color.new(color.red, 0), size = size.large)
    else
        int spacing = int(widthBars * 2.7)
        int cxR = bar_index - widthBars        // rightmost center; right edge ~ current bar
        int cxM = cxR - spacing
        int cxL = cxM - spacing

        [vM, lM] = compact(posM, totM, monthLabels)
        [vD, lD] = compact(posD, totD, dowLabels)
        [vH, lH] = compact(posH, totH, hourLabels)

        // Per-radar data ranges.
        [rloM, rhiM] = f_range(vM)
        [rloD, rhiD] = f_range(vD)
        [rloH, rhiH] = f_range(vH)

        float loM = na
        float hiM = na
        float loD = na
        float hiD = na
        float loH = na
        float hiH = na
        if scaleMode == "Manual"
            loM := axisMinMan
            hiM := axisMaxMan
            loD := axisMinMan
            hiD := axisMaxMan
            loH := axisMinMan
            hiH := axisMaxMan
        else if scaleMode == "Auto (shared)"
            float sLo = math.min(nz(rloM, 1e9), math.min(nz(rloD, 1e9), nz(rloH, 1e9)))
            float sHi = math.max(nz(rhiM, -1e9), math.max(nz(rhiD, -1e9), nz(rhiH, -1e9)))
            [aLo, aHi] = f_axis(sLo > 1e8 ? na : sLo, sHi < -1e8 ? na : sHi)
            loM := aLo
            hiM := aHi
            loD := aLo
            hiD := aHi
            loH := aLo
            hiH := aHi
        else
            [a1, b1] = f_axis(rloM, rhiM)
            [a2, b2] = f_axis(rloD, rhiD)
            [a3, b3] = f_axis(rloH, rhiH)
            loM := a1
            hiM := b1
            loD := a2
            hiD := b2
            loH := a3
            hiH := b3

        drawRadar(cxL, vM, lM, "Monthly",     loM, hiM)
        drawRadar(cxM, vD, lD, "Day of week", loD, hiD)
        drawRadar(cxR, vH, lH, "Hour of day", loH, hiH)
//#endregion
````
