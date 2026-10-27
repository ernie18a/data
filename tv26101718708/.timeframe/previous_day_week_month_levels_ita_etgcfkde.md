# Previous Day, Week & Month Levels [ITA]

- url: https://www.tradingview.com/script/ETgcFKDE-Previous-Day-Week-Month-Levels-ITA/
- type: indicator
- pine_id: PUB;f86273175a65457b92c4892ae8abc17d
- version: 1.0

## Description

🟠 OVERVIEW

Previous Day, Week & Month Levels plots the high and low of each completed higher timeframe period and keeps them on the chart until price trades through them. Once a level is taken, it fades to grey instead of disappearing, so the chart separates liquidity that is still resting from liquidity that has already been collected.

The indicator covers daily, weekly and monthly periods independently, with optional midpoints for each range. This lets an intraday trader run daily levels alone, or stack all three groups to see how short-term and higher timeframe references line up.

🟠 CONCEPTS

* Previous Level - The high or low of the last completed daily, weekly or monthly candle, pulled from the higher timeframe regardless of the chart timeframe in use.
* Untaken Level - A level that price has not traded through since its period closed. Drawn at full opacity because the orders resting behind it are still there.
* Taken Level - A level that price has traded through during the current period. Recolored grey to show the liquidity has been collected and the level has lost its role as a target.
* Level Reset - Each group tracks its own taken state and resets when a new period begins. Daily flags clear every session while weekly and monthly flags run on their own cycles.
* Midpoint - The 50% level of a previous range, marking the equilibrium of that period rather than its extremes.

🟠 FEATURES

* Multi-Period Levels - Plots previous day, week and month highs and lows, each group toggleable on its own.
* Taken Level Fading - Automatically recolors any level that price trades through, leaving untouched levels highlighted.
* Optional Midpoints - Adds the 50% level of each enabled range for equilibrium reference.
* Level Labels - Tags each line with its name on the right edge of the chart, with configurable size.
* Level Alerts - Fires when price trades above a previous high or below a previous low.

🟠 HOW TO USE

* Run daily levels alone for intraday work, or enable weekly and monthly for a broader structural view.
* Treat bright levels as unfinished business and faded levels as history. What stays highlighted is where liquidity has not yet been taken.
* Watch for clusters where a daily level sits close to a weekly one. A single move that clears both tends to produce a sharper reaction than clearing either alone.
* Use midpoints as a filter. Price rotating around the midpoint of the previous day often points to balance rather than direction.
* Adjust Extend Right if the levels project too far past the current candle or stop short of it.

🟠 CONCLUSION

Previous Day, Week & Month Levels combines multi-period reference levels with automatic tracking of which levels have already been traded through. Instead of showing every level identically, it separates active liquidity from collected liquidity, giving traders a clear view of which reference points are still relevant to the current session.

## Source Code

````pine
// © ITA Trading Tools - itamardrori_
//@version=6
indicator("Previous Day, Week & Month Levels [ITA]", overlay=true, max_lines_count=100, max_labels_count=100)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
showDay   = input.bool(true,  "Previous Day (PDH / PDL)",   group="Levels")
showWeek  = input.bool(true,  "Previous Week (PWH / PWL)",  group="Levels")
showMonth = input.bool(false, "Previous Month (PMH / PML)", group="Levels")
showMid   = input.bool(false, "Show Midpoints", group="Levels", tooltip="The 50% level of each previous range")

markTaken = input.bool(true, "Fade Levels After They Are Taken", group="Behavior", tooltip="Once price trades through a level, it dims - so untouched liquidity stands out")

dayColor   = input.color(color.new(#2962ff, 0), "Day",   group="Style")
weekColor  = input.color(color.new(#d29922, 0), "Week",  group="Style")
monthColor = input.color(color.new(#9c27b0, 0), "Month", group="Style")
takenColor = input.color(color.new(color.gray, 65), "Taken Level", group="Style")
lineStyleStr = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group="Style")
lineWidth  = input.int(1, "Line Width", minval=1, maxval=4, group="Style")
showLabels = input.bool(true, "Show Labels", group="Style")
lblSizeStr = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large"], group="Style")
extendBars = input.int(15, "Extend Right (bars)", minval=0, maxval=100, group="Style")

lblSize = lblSizeStr == "Tiny" ? size.tiny : lblSizeStr == "Normal" ? size.normal : lblSizeStr == "Large" ? size.large : size.small
lnStyle = lineStyleStr == "Dashed" ? line.style_dashed : lineStyleStr == "Dotted" ? line.style_dotted : line.style_solid

// ─── HIGHER TIMEFRAME DATA ───────────────────────────────────────────────────
[pdh, pdl, pdOpen] = request.security(syminfo.tickerid, "D", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl, pwOpen] = request.security(syminfo.tickerid, "W", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)
[pmh, pml, pmOpen] = request.security(syminfo.tickerid, "M", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

// ─── LEVEL DRAWING ───────────────────────────────────────────────────────────
// Each level: a line + label, redrawn on the last bar. Taken levels fade.
drawLevel(lvl, startTime, txt, col, isTaken) =>
    var line  ln  = na
    var label lbl = na
    if not na(lvl)
        drawCol = (markTaken and isTaken) ? takenColor : col
        if na(ln)
            ln := line.new(startTime, lvl, time + extendBars * (time - time[1]), lvl, xloc=xloc.bar_time, color=drawCol, style=lnStyle, width=lineWidth)
        else
            line.set_xy1(ln, startTime, lvl)
            line.set_xy2(ln, time + extendBars * (time - time[1]), lvl)
            line.set_color(ln, drawCol)
        if showLabels
            if na(lbl)
                lbl := label.new(time + extendBars * (time - time[1]), lvl, txt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(drawCol, 15), textcolor=color.white, size=lblSize)
            else
                label.set_xy(lbl, time + extendBars * (time - time[1]), lvl)
                label.set_text(lbl, txt)
                label.set_color(lbl, color.new(drawCol, 15))
    ln

// track whether each level has been traded through since it formed
var bool pdhTaken = false
var bool pdlTaken = false
var bool pwhTaken = false
var bool pwlTaken = false
var bool pmhTaken = false
var bool pmlTaken = false

newDay   = ta.change(time("D"))   != 0
newWeek  = ta.change(time("W"))   != 0
newMonth = ta.change(time("M"))   != 0

if newDay
    pdhTaken := false
    pdlTaken := false
if newWeek
    pwhTaken := false
    pwlTaken := false
if newMonth
    pmhTaken := false
    pmlTaken := false

if not na(pdh) and high > pdh
    pdhTaken := true
if not na(pdl) and low < pdl
    pdlTaken := true
if not na(pwh) and high > pwh
    pwhTaken := true
if not na(pwl) and low < pwl
    pwlTaken := true
if not na(pmh) and high > pmh
    pmhTaken := true
if not na(pml) and low < pml
    pmlTaken := true

if barstate.islast
    if showDay
        drawLevel(pdh, pdOpen, "PDH", dayColor, pdhTaken)
        drawLevel(pdl, pdOpen, "PDL", dayColor, pdlTaken)
        if showMid
            drawLevel((pdh + pdl) / 2, pdOpen, "PD Mid", dayColor, false)
    if showWeek
        drawLevel(pwh, pwOpen, "PWH", weekColor, pwhTaken)
        drawLevel(pwl, pwOpen, "PWL", weekColor, pwlTaken)
        if showMid
            drawLevel((pwh + pwl) / 2, pwOpen, "PW Mid", weekColor, false)
    if showMonth
        drawLevel(pmh, pmOpen, "PMH", monthColor, pmhTaken)
        drawLevel(pml, pmOpen, "PML", monthColor, pmlTaken)
        if showMid
            drawLevel((pmh + pml) / 2, pmOpen, "PM Mid", monthColor, false)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
pdhBreak = not na(pdh) and ta.crossover(high, pdh)
pdlBreak = not na(pdl) and ta.crossunder(low, pdl)
pwhBreak = not na(pwh) and ta.crossover(high, pwh)
pwlBreak = not na(pwl) and ta.crossunder(low, pwl)

alertcondition(pdhBreak, "Previous Day High Taken",  "Price traded above the previous day high")
alertcondition(pdlBreak, "Previous Day Low Taken",   "Price traded below the previous day low")
alertcondition(pwhBreak, "Previous Week High Taken", "Price traded above the previous week high")
alertcondition(pwlBreak, "Previous Week Low Taken",  "Price traded below the previous week low")
````
