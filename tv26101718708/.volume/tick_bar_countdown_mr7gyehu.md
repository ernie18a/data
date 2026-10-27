# Tick Bar Countdown

- url: https://www.tradingview.com/script/Mr7gyEhU-Tick-Bar-Countdown/
- type: indicator
- pine_id: PUB;dc00f57c0e1a4bdfa4ab01d56c388ed4
- version: 3.0

## Description

[b]Core problem it solves: [/b]Pine has no native tick-count variable, and counting script recalculations undercounts because TradingView throttles execution — multiple trades can batch into a single recalc, especially in fast markets. So instead of counting recalcs, the script infers tick progress from volume, which accumulates the true traded contract count regardless of how many times the script actually fires.

[b]How to read it[/b]

While a bar is still forming, you'll see three things stack up together above it:

Grey background wash — tells you at a glance "this bar isn't closed yet," independent of anything else.

% label (e.g. 62% (620/1000)) — your best estimate of how many ticks have printed vs. the 1000 needed to close the bar.

Segmented progress bar directly above the label — same information as a visual gauge, filling left to right as ticks accumulate.

[b]Color coding ties it together:[/b]

Grey/aqua — normal, bar still building.
Yellow — crossed your warn threshold (default 80%), bar is getting close.
Lime green — crossed your ready threshold (default 93%), this is your cue to get hands on keys/mouse for the next bar.

Once the bar closes, all of it disappears — grey wash, label, and bar — since barstate.isconfirmed becomes true and those elements only draw on the live/forming bar.

## Source Code

````pine
//@version=6
indicator("Tick Bar Countdown (1000T)", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
ticksPerBar   = input.int(1000, "Ticks Per Bar (chart setting)", minval=1, tooltip="Must match your tick chart interval, e.g. 1000 for a 1000T chart.")
lookback      = input.int(20, "Lookback Bars for Avg Volume/Tick", minval=3, maxval=200)
timeLookback  = input.int(20, "Lookback Bars for Avg Completion Time", minval=2, maxval=200, tooltip="How many recently closed bars to average for the 'Avg Bar Time' readout.")
warnPct       = input.float(80, "Warning Threshold %", minval=1, maxval=99)
readyPct      = input.float(93, "Ready-to-Act Threshold %", minval=1, maxval=99)
showLabel     = input.bool(true, "Show % Label")
labelOffset   = input.float(1.5, "Label Offset (ATR multiples)", minval=0, step=0.25, tooltip="How far above the bar the % label floats. Increase if it's overlapping price.")
showBar       = input.bool(true, "Show Progress Bar")
lockBarToLabel = input.bool(true, "Lock Progress Bar Tight to Label", tooltip="When on, ignores the gap input below and pins the bar just barely above the label so they read as one unit.")
barGapAboveLabel = input.float(0.75, "Progress Bar Gap Above Label (ATR multiples)", minval=0, step=0.25, tooltip="Vertical space between the % label and the progress bar sitting above it. Ignored when 'Lock' is on.")
showBg        = input.bool(true, "Highlight Background Near Close")
showFormingBg = input.bool(true, "Static Grey Highlight While Bar Is Forming")
smoothing     = input.string("SMA", "Volume/Tick Averaging", options=["SMA", "EMA"])
displayMode   = input.string("Above Price", "Display Mode", options=["Above Price", "Fixed Position"], tooltip="'Above Price' follows the forming bar. 'Fixed Position' pins the readout to a screen corner, unaffected by price/zoom.")
fixedPosition = input.string("Top Right", "Fixed Screen Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], tooltip="Only used when Display Mode is 'Fixed Position'.")

// ─────────────────────────────────────────────────────────────
// AVG VOLUME PER TICK (built from CLOSED bars only)
// Each closed bar on a 1000T chart = exactly `ticksPerBar` ticks,
// so closed-bar volume / ticksPerBar = a real sample of vol-per-tick.
// ─────────────────────────────────────────────────────────────
var float[] closedBarVols = array.new_float(0)

if barstate.isconfirmed
    array.push(closedBarVols, volume)
    if array.size(closedBarVols) > lookback
        array.shift(closedBarVols)

avgVolPerTick = float(na)
if array.size(closedBarVols) >= 3
    sumV = array.sum(closedBarVols)
    n    = array.size(closedBarVols)
    avgVolPerTick := smoothing == "SMA" ? (sumV / n) / ticksPerBar : na

// EMA variant of the same underlying series (only computed on confirmed bars)
var float emaVolPerTick = na
if barstate.isconfirmed
    sampleVpt = volume / ticksPerBar
    emaVolPerTick := na(emaVolPerTick) ? sampleVpt : emaVolPerTick + (2.0/(lookback+1)) * (sampleVpt - emaVolPerTick)

vpt = smoothing == "EMA" ? emaVolPerTick : avgVolPerTick

// ─────────────────────────────────────────────────────────────
// AVERAGE BAR COMPLETION TIME
// A bar's duration = time this bar opened minus time the previous bar opened,
// since a new tick-bar opens the instant the prior one closes (no gap).
// Computed once per new bar (not every tick) using a change-in-time guard.
// ─────────────────────────────────────────────────────────────
var float[] barDurationsMs = array.new_float(0)
var int lastSeenTime = na

if na(lastSeenTime) or time != lastSeenTime
    if not na(time[1])
        dur = time - time[1]
        array.push(barDurationsMs, dur)
        if array.size(barDurationsMs) > timeLookback
            array.shift(barDurationsMs)
    lastSeenTime := time

avgDurationMs = array.size(barDurationsMs) > 0 ? array.sum(barDurationsMs) / array.size(barDurationsMs) : float(na)

f_fmtDuration(ms) =>
    totalSec = math.round(ms / 1000)
    mins = int(totalSec / 60)
    secs = int(totalSec % 60)
    str.tostring(mins) + "m " + (secs < 10 ? "0" : "") + str.tostring(secs) + "s"

// ─────────────────────────────────────────────────────────────
// ESTIMATE PROGRESS OF THE CURRENTLY FORMING BAR
// ─────────────────────────────────────────────────────────────
estTicks   = na(vpt) or vpt <= 0 ? na : volume / vpt
progressPct = na(estTicks) ? na : math.min(100.0, (estTicks / ticksPerBar) * 100.0)

isReady = not na(progressPct) and progressPct >= readyPct and not barstate.isconfirmed
isWarn  = not na(progressPct) and progressPct >= warnPct and progressPct < readyPct and not barstate.isconfirmed

// ─────────────────────────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────────────────────────
// Static grey wash for the entire time the current bar is still forming (independent of progress %)
formingBg = (not barstate.isconfirmed) ? color.new(color.gray, 88) : na
bgcolor(showFormingBg ? formingBg : na, title="Forming Bar (static grey)")

// Progress-based highlight layered on top of the static grey
bgColor = isReady ? color.new(color.lime, 82) : isWarn ? color.new(color.yellow, 88) : na
bgcolor(showBg ? bgColor : na, title="Bar-Close Proximity")

// % label at the current bar, floating above the high (only in "Above Price" mode)
var label pctLabel = na
if showLabel and displayMode == "Above Price"
    label.delete(pctLabel)
    txt = na(progressPct) ? "warming up..." : str.tostring(math.round(progressPct)) + "% (" + str.tostring(int(math.round(na(estTicks) ? 0 : estTicks))) + "/" + str.tostring(ticksPerBar) + ")"
    txt := txt + "\nAvg Bar Time: " + (na(avgDurationMs) ? "n/a" : f_fmtDuration(avgDurationMs))
    labelCol = isReady ? color.lime : isWarn ? color.yellow : color.gray
    labelY   = high + (ta.atr(14) * labelOffset)
    pctLabel := label.new(bar_index, labelY, txt, xloc=xloc.bar_index, yloc=yloc.price,
                           style=label.style_label_up, color=color.new(color.black, 0),
                           textcolor=labelCol, size=size.small)
else if not na(pctLabel)
    label.delete(pctLabel)
    pctLabel := na

// progress bar drawn as boxes, stacked directly above the % label, centered on the forming bar (only in "Above Price" mode)
var box[] barBoxes = array.new_box(0)
if showBar and displayMode == "Above Price"
    // clear previous frame's boxes for this bar (redraw each tick)
    if array.size(barBoxes) > 0
        for i = array.size(barBoxes) - 1 to 0
            box.delete(array.get(barBoxes, i))
        array.clear(barBoxes)

    if not na(progressPct)
        segments = 20
        filled   = math.round((progressPct / 100.0) * segments)
        atrNow   = ta.atr(14)
        labelY   = high + (atrNow * labelOffset)
        gapMult  = lockBarToLabel ? 0.15 : barGapAboveLabel
        botRef   = labelY + (atrNow * gapMult)
        segH     = atrNow * 0.25
        halfSeg  = segments / 2
        for i = 0 to segments - 1
            xStart = bar_index - halfSeg + i
            xEnd   = xStart + 1
            segCol = i < filled ? (isReady ? color.lime : isWarn ? color.yellow : color.aqua) : color.new(color.gray, 75)
            b = box.new(xStart, botRef + segH, xEnd, botRef, border_color=color.new(color.black, 60), bgcolor=segCol)
            array.push(barBoxes, b)
else if displayMode != "Above Price" and array.size(barBoxes) > 0
    for i = array.size(barBoxes) - 1 to 0
        box.delete(array.get(barBoxes, i))
    array.clear(barBoxes)

// ─────────────────────────────────────────────────────────────
// FIXED SCREEN POSITION MODE — pinned readout using a table (unaffected by price/zoom/scroll)
// ─────────────────────────────────────────────────────────────
var table statusTable = na
if displayMode == "Fixed Position" and barstate.islast
    table.delete(statusTable)
    segments = 20
    posMap = fixedPosition == "Top Left" ? position.top_left : fixedPosition == "Top Right" ? position.top_right : fixedPosition == "Bottom Left" ? position.bottom_left : position.bottom_right
    statusTable := table.new(posMap, segments, 2, bgcolor=color.new(color.black, 25), border_width=1, border_color=color.new(color.gray, 50), frame_width=1, frame_color=color.new(color.gray, 50))

    if showLabel
        txt = na(progressPct) ? "warming up..." : str.tostring(math.round(progressPct)) + "% (" + str.tostring(int(math.round(na(estTicks) ? 0 : estTicks))) + "/" + str.tostring(ticksPerBar) + ")"
        txt := txt + "\nAvg Bar Time: " + (na(avgDurationMs) ? "n/a" : f_fmtDuration(avgDurationMs))
        labelCol = isReady ? color.lime : isWarn ? color.yellow : color.gray
        table.cell(statusTable, 0, 0, txt, text_color=labelCol, text_size=size.small, text_halign=text.align_left)

    if showBar and not na(progressPct)
        filled = math.round((progressPct / 100.0) * segments)
        for i = 0 to segments - 1
            segCol = i < filled ? (isReady ? color.lime : isWarn ? color.yellow : color.aqua) : color.new(color.gray, 75)
            table.cell(statusTable, i, 1, "", bgcolor=segCol)
else if displayMode != "Fixed Position" and not na(statusTable)
    table.delete(statusTable)
    statusTable := na

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────
alertcondition(isReady, title="Bar Nearing Close", message="1000T bar ~{{plot('progressPct')}}% formed — prepare to act on next bar")
plot(progressPct, title="progressPct", display=display.none)

if isReady and barstate.isrealtime
    alert("Tick bar nearing close — prepare next-candle action", alert.freq_once_per_bar)
````
