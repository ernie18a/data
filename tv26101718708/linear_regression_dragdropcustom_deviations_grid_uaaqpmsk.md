# Linear Regression Drag-Drop,custom deviations & grid

- url: https://www.tradingview.com/script/uAaqPmSK-Linear-Regression-Drag-Drop-custom-deviations-grid/
- type: indicator
- pine_id: PUB;9aad2704eeb44e8187a5ef952238a00b
- version: 3.0

## Description

[b]Overview[/b]

This indicator lets you draw a precise linear regression channel between any two points in time that you choose — simply drag two time anchors onto the chart. Unlike TradingView's built-in regression tool, which is locked to a fixed lookback, this script gives you full manual control over the exact start and end of the regression window, plus a deviation-based channel, an optional mirrored grid, and a live stats table to help you judge the quality of the fit.

[b]How It Works[/b]

Two draggable time anchors. You place a Start Time and an End Time directly on the chart. The script finds the bars closest to each timestamp and runs a least-squares linear regression on price between them.


[i]Deviation channel[/i]. Around the regression line, the script plots four deviation bands (1x–4x). You can choose how the deviation is calculated:
[list=1]
[*][i]StdDev [/i]— the statistical standard error of the residuals (how far price actually strayed from the line).
[*][i]Points (Pips)[/i] — a fixed pip value you define, useful when you want consistent, comparable band widths across different sessions or instruments rather than a value that changes with volatility.
[/list]


Grid. A second set of lines can be drawn as a mirror image of the regression channel, anchored at the end point. You can choose:
[list=1]
[*][i]Mirror Lines [/i]— the mirror slopes in the opposite direction, useful for spotting counter-trend zones.
[*][i]Zero Slope[/i] — the mirror is flattened to horizontal, useful for marking flat reaction levels.
[image]https://www.tradingview.com/x/hsuQC1fF/[/image]
[*][i]None [/i]— hide the mirror set entirely.
[/list]
A vertical shift input lets you offset the whole mirrored grid up or down by a multiple of the deviation, so it doesn't have to originate from the same anchor point as the main channel.

[i]Fill and time markers[/i]. The area between the deviation bands is shaded, and vertical lines mark your two chosen times, so the exact regression window is always visible at a glance.

[i]Stats table.[/i] A table (position and appearance configurable) shows:
[list=1]
[*][i]Slope (%/day)[/i] — the trend's daily rate of change, normalized as a percentage of the starting price, so it's comparable across instruments and timeframes.
[*][i]R² [/i]— how well the straight line actually fits price over that window (color-coded green/yellow/red).
[*][i]Deviation [/i]— shown directly in pips.
[*][i]Bars [/i]— the number of bars in the regression window.
[/list]


[b]How To Use[/b]

Drag the Start Time and End Time anchors onto the swing points, session boundaries, or range you want to analyze. The information table is there to help you judge whether a setup is high-probability before you act on it — not every regression window is worth trading, and the table is your filter:

Deviation tends to fit best on AUD/USD and EUR/USD when the pip size is set to a multiple of 10. Other currency pairs (JPY pairs, for example) will usually need a different pip size to get a well-scaled channel — adjust to taste per instrument.
Slope (%/day) gives you a quick read on trend strength: roughly 0.15% = a slow trend, 0.5% = a moderate trend, 1%+ = a steep trend. Use this as a guide for how aggressively price is moving through the window, not as a hard rule.
R² is helps quality check. A high R² means price tracked the line cleanly (more reliable for directional/continuation reads); a low R² means the window was choppy and the line is describing a range rather than a trend (better suited to mean-reversion reads at the deviation bands).

Grid mode adds a second dimension to your analysis: use Mirror Lines to project counter-trend/reversal zones, and Zero Slope to mark horizontal reaction levels. Combined with the ability to freely drag your time anchors to any two points on the chart, this turns the indicator into a fast, repeatable way to test different swing points and see how price is likely to react at the resulting grid levels.

Like any regression-based tool, its usefulness comes from context and repetition. The more windows and instruments you test it against, the better your feel for which slope/R²/deviation combinations mark genuinely high-probability points versus noise — the power of this indicator unfolds with practice.

Notes

This tool describes historical price behavior over a chosen window; it does not predict future price with certainty. Always combine it with your own risk management and additional confluence.
Deviation bands are descriptive statistics, not guaranteed support/resistance — treat penetrations of the outer bands as information, not automatic signals.

## Source Code

````pine
//@version=6
indicator("Linear Regression Between Two Times", overlay=true, max_lines_count=25, max_labels_count=1)

// ── Inputs ──────────────────────────────────────────────
timeMode  = input.string("Fixed Times", "Time Mode", options=["Fixed Times", "Daily Open to Last Bar"], tooltip="Fixed Times: use the Start/End Time inputs below. Daily Open to Last Bar: start anchors to today's opening bar and end tracks the most recently completed bar, recalculating live as the day progresses.")
t1        = input.time(timestamp("2026-07-01T00:00:00"), "Start Time", confirm=true, group="Fixed Times")
t2        = input.time(timestamp("2026-07-15T00:00:00"), "End Time",   confirm=true, group="Fixed Times")
srcInput  = input.source(close, "Source")
max_bars_back(srcInput, 5000)
lineType  = input.string("Regression", "Line Type", options=["Regression", "Trendline"], tooltip="Regression: statistical best fit through all bars in the window. Trendline: connects the two endpoint prices directly.")
devType   = input.string("StdDev", "Deviation Type", options=["StdDev", "Points (Pips)", "Percentage", "Max Distance/2"])
stdmult   = input.float(1, "Deviation Multiple", step=0.5)
pipsInput = input.float(10, "Deviation (Pips)", tooltip="Used when Deviation Type = Points (Pips)")
pipSize   = input.float(0.0001, "Pip Size", tooltip="e.g. 0.0001 for most FX pairs, 0.01 for JPY pairs — also used to convert the deviation to pips in the table")
pctInput  = input.float(1.0, "Deviation (%)", tooltip="Used when Deviation Type = Percentage — a % of the starting price")
showChan  = input.bool(true, "Show Deviation Lines")
gridMode  = input.string("Mirror Lines", "Grid Lines", options=["Mirror Lines", "Zero Slope", "None"])
mirrorShift = input.float(0, "Mirror Vertical Shift (x StdErr)")
showFill  = input.bool(true, "Fill Between Start/End Time")
showLabel = input.bool(true, "Show Stats Table")
tablePosInput = input.string("Top Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"])

// ── Map input times to bar indices (last bar at/before each time) ──
var int idx1 = na
var int idx2 = na
if time <= t1
    idx1 := bar_index
if time <= t2
    idx2 := bar_index


// ── Daily Open to Last Bar: track today's opening bar index ──
var int dayStartIdx = na
bool isNewDay = ta.change(time("D")) != 0
if isNewDay
    dayStartIdx := bar_index
// Always use bar_index - 1 to stay within buffer limits
int dayEndIdx = bar_index - 1

int startIdx = timeMode == "Daily Open to Last Bar" ? dayStartIdx : (na(idx1) or na(idx2) ? na : math.min(idx1, idx2))
int endIdx   = timeMode == "Daily Open to Last Bar" ? dayEndIdx   : (na(idx1) or na(idx2) ? na : math.max(idx1, idx2))
// ── Incremental running sums for Daily Open mode — avoids re-summing the whole
// day's bars from scratch on every single bar close (the O(n) loop below is fine
// when it only fires occasionally in Fixed Times mode, but is too heavy to run
// every bar all session, which is what caused the line redraw to stutter/drop) ──
var float dSumX  = na
var float dSumY  = na
var float dSumXY = na
var float dSumX2 = na
var float dSumY2 = na
var int   dN     = na
var int   dX     = na

if timeMode == "Daily Open to Last Bar"
    if isNewDay
        dSumX  := 0.0
        dSumY  := 0.0
        dSumXY := 0.0
        dSumX2 := 0.0
        dSumY2 := 0.0
        dN     := 0
        dX     := -1
    if barstate.isconfirmed
        dX     += 1
        dSumX  += dX
        dSumY  += srcInput
        dSumXY += dX * srcInput
        dSumX2 += dX * dX
        dSumY2 += srcInput * srcInput
        dN     += 1

tablePosition = switch tablePosInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right



// ── Draw-or-move helper: creates a line once, then repositions it in place on
// every later update instead of delete+recreate (avoids the flicker/gap that
// causes lines to vanish for a frame on new bar prints) ──
f_line(id, x1, y1, x2, y2, ext, col, sty, wid) =>
    line ln = id
    if na(id)
        ln := line.new(x1, y1, x2, y2, xloc.bar_index, ext, col, sty, wid)
    else
        line.set_xy1(ln, x1, y1)
        line.set_xy2(ln, x2, y2)
    ln

// ── Persistent drawing objects ──
var line     regLine    = na
var line     upper1     = na
var line     lower1     = na
var line     upper2     = na
var line     lower2     = na
var line     upper3     = na
var line     lower3     = na
var line     upper4     = na
var line     lower4     = na
// Mirrored set — anchored at (endIdx, yEnd), slope negated, forms the grid
var line     mRegLine   = na
var line     mUpper1    = na
var line     mLower1    = na
var line     mUpper2    = na
var line     mLower2    = na
var line     mUpper3    = na
var line     mLower3    = na
var line     mUpper4    = na
var line     mLower4    = na
// Non-extended proxy lines (startIdx..endIdx only), used purely to bound the linefill
var line     fUpper1    = na
var line     fLower1    = na
var line     fUpper2    = na
var line     fLower2    = na
var linefill fillInner  = na
var linefill fillUpper  = na
var linefill fillLower  = na
var table    infoTable  = na

var int   prevStart = na
var int   prevEnd   = na
// Only draw/update when we're on a confirmed bar in Daily mode


// ── Regression: only recompute when the window actually changes, not on every tick ──
if barstate.isconfirmed and not na(startIdx) and not na(endIdx) and endIdx > startIdx and (na(prevStart) or startIdx != prevStart or endIdx != prevEnd)

    prevStart := startIdx
    prevEnd   := endIdx
    int n = endIdx - startIdx + 1

    // Fast path: Daily mode + Regression + a deviation type derivable in closed form.
    // Max Distance/2 needs the actual per-bar residuals against the CURRENT line, which
    // changes every bar, so it can't be maintained incrementally — it keeps the loop.
    bool useFastPath = timeMode == "Daily Open to Last Bar" and lineType == "Regression" and devType != "Max Distance/2" and dN == n

    float slope     = na
    float intercept = na
    float sumSqErr  = na
    float Syy       = na
    float maxAbsErr = na

    if useFastPath
        float fdenom = dN * dSumX2 - dSumX * dSumX
        slope     := fdenom != 0 ? (dN * dSumXY - dSumX * dSumY) / fdenom : 0.0
        intercept := (dSumY - slope * dSumX) / dN
        // OLS identity: SSE = Σy² − b0·Σy − b1·Σxy — exact, no residual loop needed
        sumSqErr  := dSumY2 - intercept * dSumY - slope * dSumXY
        Syy       := dSumY2 - dSumY * dSumY / dN
        maxAbsErr := 0.0
    else
        float sumX  = 0.0
        float sumY  = 0.0
        float sumXY = 0.0
        float sumX2 = 0.0
        float sumY2 = 0.0

        for i = 0 to n - 1
            int barsAgo = bar_index - (startIdx + i)
            float y = srcInput[barsAgo]
            float x = i
            sumX  += x
            sumY  += y
            sumXY += x * y
            sumX2 += x * x
            sumY2 += y * y

        float denom     = n * sumX2 - sumX * sumX
        float regSlope     = denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0.0
        float regIntercept = (sumY - regSlope * sumX) / n

        // Trendline: connects the two endpoint prices directly, not a statistical fit
        float trendY1 = srcInput[bar_index - startIdx]
        float trendY2 = srcInput[bar_index - endIdx]
        float trendSlope     = n > 1 ? (trendY2 - trendY1) / (n - 1) : 0.0
        float trendIntercept = trendY1

        slope     := lineType == "Trendline" ? trendSlope     : regSlope
        intercept := lineType == "Trendline" ? trendIntercept : regIntercept

        // Residuals from the ACTIVE line (regression or trendline) — needed generically
        // since the OLS closed-form shortcut only holds when the line is the least-squares fit
        float sse    = 0.0
        float maxErr = 0.0
        for i = 0 to n - 1
            int barsAgo2 = bar_index - (startIdx + i)
            float actual    = srcInput[barsAgo2]
            float predicted = intercept + slope * i
            float err = actual - predicted
            sse += err * err
            maxErr := math.max(maxErr, math.abs(err))
        sumSqErr  := sse
        maxAbsErr := maxErr
        Syy       := sumY2 - sumY * sumY / n

    float yStart = intercept
    float yEnd   = intercept + slope * (n - 1)
    float stdErrRaw = math.sqrt(sumSqErr / n)

    // Deviation: statistical std error, a fixed pip value, a % of the starting price,
    // or half the single largest deviation of price from the line anywhere in the window
    float deviation = devType == "StdDev" ? stdErrRaw * stdmult : devType == "Points (Pips)" ? pipsInput * pipSize * stdmult : devType == "Percentage" ? yStart * (pctInput / 100) * stdmult : (maxAbsErr / 2) * stdmult
    float devPips   = pipSize != 0 ? deviation / pipSize : na
    float devPct    = yStart != 0 ? (deviation / yStart) * 100 : na

    // Slope in %/day, based on the chart's bar interval and starting price
    float secPerBar   = timeframe.in_seconds() > 0 ? timeframe.in_seconds() : na
    float barsPerDay   = not na(secPerBar) and secPerBar != 0 ? 86400.0 / secPerBar : na
    float slopePctDay  = not na(barsPerDay) and yStart != 0 ? (slope * barsPerDay / yStart) * 100 : na

    // Mirror anchor: "Mirror Lines" passes through (endIdx, yEnd) with slope negated,
    // "Zero Slope" is flat at yEnd; mirrorShift offsets the whole set vertically
    float myStart = gridMode == "Mirror Lines" ? yEnd + slope * (n - 1) + deviation * mirrorShift : yEnd + deviation * mirrorShift
    float myEnd   = yEnd + deviation * mirrorShift

    // R² generalized as 1 - SSE/SST — valid for any line, not just the OLS fit
    // (for Regression mode this is identical to the classic formula; for Trendline
    // mode it can go negative if the fixed line explains variance worse than the mean)
    float r2 = Syy != 0 ? 1 - (sumSqErr / Syy) : 0.0

    regLine := f_line(regLine, startIdx, yStart, endIdx, yEnd, extend.both, color.blue, line.style_solid, 2)

    if showChan
        upper1 := f_line(upper1, startIdx, yStart + deviation,     endIdx, yEnd + deviation,     extend.both, color.green, line.style_solid, 1)
        lower1 := f_line(lower1, startIdx, yStart - deviation,     endIdx, yEnd - deviation,     extend.both, color.green, line.style_solid, 1)
        upper2 := f_line(upper2, startIdx, yStart + deviation * 2, endIdx, yEnd + deviation * 2, extend.both, color.red,   line.style_solid, 2)
        lower2 := f_line(lower2, startIdx, yStart - deviation * 2, endIdx, yEnd - deviation * 2, extend.both, color.red,   line.style_solid, 2)
        upper3 := f_line(upper3, startIdx, yStart + deviation * 3, endIdx, yEnd + deviation * 3, extend.both, color.green, line.style_solid, 1)
        lower3 := f_line(lower3, startIdx, yStart - deviation * 3, endIdx, yEnd - deviation * 3, extend.both, color.green, line.style_solid, 1)
        upper4 := f_line(upper4, startIdx, yStart + deviation * 4, endIdx, yEnd + deviation * 4, extend.both, color.blue,  line.style_solid, 1)
        lower4 := f_line(lower4, startIdx, yStart - deviation * 4, endIdx, yEnd - deviation * 4, extend.both, color.blue,  line.style_solid, 1)

    if gridMode != "None"
        mRegLine := f_line(mRegLine, startIdx, myStart, endIdx, myEnd, extend.both, color.blue, line.style_solid, 2)
        mUpper1  := f_line(mUpper1,  startIdx, myStart + deviation,     endIdx, myEnd + deviation,     extend.both, color.green, line.style_solid, 1)
        mLower1  := f_line(mLower1,  startIdx, myStart - deviation,     endIdx, myEnd - deviation,     extend.both, color.green, line.style_solid, 1)
        mUpper2  := f_line(mUpper2,  startIdx, myStart + deviation * 2, endIdx, myEnd + deviation * 2, extend.both, color.red,   line.style_solid, 2)
        mLower2  := f_line(mLower2,  startIdx, myStart - deviation * 2, endIdx, myEnd - deviation * 2, extend.both, color.red,   line.style_solid, 2)
        mUpper3  := f_line(mUpper3,  startIdx, myStart + deviation * 3, endIdx, myEnd + deviation * 3, extend.both, color.green, line.style_solid, 1)
        mLower3  := f_line(mLower3,  startIdx, myStart - deviation * 3, endIdx, myEnd - deviation * 3, extend.both, color.green, line.style_solid, 1)
        mUpper4  := f_line(mUpper4,  startIdx, myStart + deviation * 4, endIdx, myEnd + deviation * 4, extend.both, color.blue,  line.style_solid, 1)
        mLower4  := f_line(mLower4,  startIdx, myStart - deviation * 4, endIdx, myEnd - deviation * 4, extend.both, color.blue,  line.style_solid, 1)

    if showLabel
        if na(infoTable)
            infoTable := table.new(tablePosition, 2, 4, bgcolor=color.white, border_width=1, border_color=color.black, frame_color=color.black, frame_width=1)
        table.cell(infoTable, 0, 0, "Slope (%/day)", text_color=color.black, bgcolor=color.white, text_halign=text.align_left)
        table.cell(infoTable, 1, 0, str.tostring(slopePctDay, "#.####") + "%", text_color=color.black, bgcolor=color.white, text_halign=text.align_right)
        color r2Color = r2 > 0.7 ? color.new(color.green, 55) : r2 > 0.3 ? color.new(color.yellow, 55) : color.new(color.red, 55)
        table.cell(infoTable, 0, 1, "R²",        text_color=color.black, bgcolor=r2Color, text_halign=text.align_left)
        table.cell(infoTable, 1, 1, str.tostring(r2, "#.####"), text_color=color.black, bgcolor=r2Color, text_halign=text.align_right)
        table.cell(infoTable, 0, 2, "Deviation", text_color=color.black, bgcolor=color.white, text_halign=text.align_left)
        table.cell(infoTable, 1, 2, devType == "Points (Pips)" ? str.tostring(devPips, "#.#") + " pips" : str.tostring(devPct, "#.##") + "%", text_color=color.black, bgcolor=color.white, text_halign=text.align_right)
        table.cell(infoTable, 0, 3, "Bars",      text_color=color.black, bgcolor=color.white, text_halign=text.align_left)
        table.cell(infoTable, 1, 3, str.tostring(n), text_color=color.black, bgcolor=color.white, text_halign=text.align_right)
    if showFill
        fUpper1 := f_line(fUpper1, startIdx, yStart + deviation,     endIdx, yEnd + deviation,     extend.none, color(na), line.style_solid, 1)
        fLower1 := f_line(fLower1, startIdx, yStart - deviation,     endIdx, yEnd - deviation,     extend.none, color(na), line.style_solid, 1)
        fUpper2 := f_line(fUpper2, startIdx, yStart + deviation * 2, endIdx, yEnd + deviation * 2, extend.none, color(na), line.style_solid, 1)
        fLower2 := f_line(fLower2, startIdx, yStart - deviation * 2, endIdx, yEnd - deviation * 2, extend.none, color(na), line.style_solid, 1)

        if na(fillInner)
            fillInner := linefill.new(fUpper1, fLower1, color.new(color.green, 85))
            fillUpper := linefill.new(fUpper2, fUpper1, color.new(color.red, 90))
            fillLower := linefill.new(fLower1, fLower2, color.new(color.red, 90))
// ───────────── Vertical Marker (Fixed Times mode only) ─────────────
var line tLine1 = na
var line tLine2 = na
if barstate.islast and timeMode == "Fixed Times"
    if na(tLine1)
        tLine1 := line.new(x1=t1, y1=low, x2=t1, y2=high,
         xloc=xloc.bar_time, extend=extend.both, color=color.blue, style=line.style_solid, width=2)
    else
        line.set_xy1(tLine1, t1, low)
        line.set_xy2(tLine1, t1, high)
    if na(tLine2)
        tLine2 := line.new(x1=t2, y1=low, x2=t2, y2=high,
         xloc=xloc.bar_time, extend=extend.both, color=color.blue, style=line.style_solid, width=2)
    else
        line.set_xy1(tLine2, t2, low)
        line.set_xy2(tLine2, t2, high)
````
