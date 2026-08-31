<!-- tradingview-pine-id: PUB;3660a51276184ecaafb032b25c9ebd41 -->
<!-- tradingviewscripts-format: 1 -->
# Leg Anatomy - Measured Retracement and Extension

Source: https://www.tradingview.com/script/3xcJbsWI-Leg-Anatomy-Measured-Retracement-and-Extension/

## Description

Every trader draws the same three numbers on every chart: 38.2, 50 and 61.8. Those numbers were not derived from this market, this timeframe, or this instrument. They were not derived from any market. They are a convention that spread because it spread.

This script measures the real thing instead.

WHAT IT MEASURES

Price is broken into confirmed swing legs. A running extreme is tracked, and when price closes back from that extreme by more than a configurable multiple of ATR, the extreme is confirmed as a swing and a new leg begins.

Every completed leg is measured as a ratio of the leg immediately before it. A leg that travelled 60 percent of the previous leg records 0.60. A leg that went 140 percent past it records 1.40. That single number, the leg-to-leg ratio, is the entire dataset.

From the last N legs on the chart you have open, the panel reports:

The median leg, expressed as a multiple of the one before it.
The interquartile range, the middle half of the distribution.
The share of legs that were shallow, under 0.62.
The share that were deep, between 0.62 and 1.00.
The share that were extensions, past 1.00.

On some symbols and timeframes the conventional levels sit close to the measured centre. On many they do not, and the gap between what a chart actually does and what the convention assumes is visible in one row of the panel.

THE PROJECTION

The distribution is not left as a table. It is applied forward.

The leg currently forming starts from the last confirmed swing, and the leg before it has a known size. Multiplying that size by the measured median, upper quartile and ninetieth percentile gives three projected endpoints, drawn as a shaded zone in front of price with a dashed median line and a price label.

The panel shows how far the forming leg has travelled as a percentage of its median expectation. Below 100 percent the leg is still inside its normal range. Above it, the leg has already outrun the typical case for this chart, which is information whether you are holding it or fading it.

The zone is not a forecast. It is where the middle of the distribution sits, and roughly half of past legs fell short of it.

THE SKELETON

Confirmed legs are drawn as a thick zigzag across the chart, each one labelled with its own ratio, so the distribution in the panel can be read directly off the price action that produced it. Candles are tinted by the direction of the leg currently forming.

Because swings only confirm on closed bars and a confirmed swing is never revisited, the skeleton behind price is final. Only the leg at the right edge is still forming, and the projection zone updates only when a new leg is confirmed.

SETUPS

When a swing confirms, a new leg begins, and the script produces a complete setup at that close.

The stop sits just beyond the swing that was just confirmed, plus an ATR buffer. That swing is the level the leg depends on. If it goes, the leg reading was wrong.

The three targets are the lower quartile, the median and the upper quartile of the measured distribution, projected from the swing. They are not multiples of risk and they are not conventional ratios. They are the shape of this chart's own legs.

Only one setup is tracked at a time. The panel records whether the first target or the stop was reached first, and prints collecting until the sample is large enough to mean anything. That number measures one mechanical rule and is not a backtest.

SETTINGS

Reversal Threshold is the only structural dial. It decides what counts as a leg. A low value produces many small legs and a distribution dominated by noise. A high value produces few large legs and a distribution with a small sample. The default sits between the two, and changing it changes the entire analysis, which is the point: a leg on a scalping horizon is not a leg on a swing horizon, and the measured distribution should differ between them.

Volatility Length sets the ATR lookback used for the reversal threshold and the stop buffer.

Legs Kept In Sample bounds the history, so the distribution tracks the current regime instead of averaging in a market from years ago.

REPAINTING

Swing confirmation, leg measurement, the distribution, setups and alerts all evaluate on confirmed bars. A confirmed swing is never moved and a drawn leg is never redrawn. The projection zone in front of price is recomputed only when a new leg begins. The script requests no higher timeframe data.

HOW TO READ IT

Start with the three share rows. If a chart shows most of its legs under 0.62, it is a market that retraces shallowly and continuation is the base case. If most legs sit between 0.62 and 1.00, it is a market that gives deep pullbacks and entering early is expensive. A high share above 1.00 is a trending regime where each leg outruns the last.

Then look at the forming leg's progress. A leg at 40 percent of median with a distribution that favours extension is a different situation from a leg at 130 percent in a market that rarely extends.

The ratios printed on the skeleton let you check the panel against your own eyes rather than trusting it.

This is an analysis tool, not financial advice, and not a trading system. A measured distribution describes what happened, not what will. Sample sizes are small by the standards of statistics and regimes change. Use it with your own risk management and position sizing.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Leg Anatomy - Measured Retracement and Extension", "Leg Anatomy", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ============================================================================
//  LEG ANATOMY
//
//  Every trader on earth draws the same three numbers: 38.2, 50, 61.8. They
//  were not derived from this market, from this timeframe, or from any market
//  at all. They are a convention.
//
//  This script measures the real thing instead. It breaks price into confirmed
//  swing legs, measures every leg as a ratio of the leg before it, and builds
//  the actual distribution of that ratio on the chart you have open.
//
//  Then it uses that distribution to project where the leg currently forming
//  should end: a median target, an upper quartile target, and a ninetieth
//  percentile target, drawn as a zone in front of price.
//
//  The panel reports what share of legs on this chart retraced less than 61.8
//  percent and what share extended past 100 percent, with the sample size.
//  On some symbols the convention is close. On many it is not.
//
//  Swings confirm on closed bars using an ATR reversal threshold. A confirmed
//  swing is never moved. The projection zone updates only when a new leg
//  begins.
// ============================================================================

// -------------------------------- INPUTS -----------------------------------
G1 = "LEG DETECTION"
G2 = "STATISTICS"
G3 = "PROJECTION"
G4 = "SETUPS"
G5 = "VISUALS"
G6 = "COLORS"

atrLen  = input.int(50, "Volatility Length", minval = 5, maxval = 300, group = G1)
revMult = input.float(2.0, "Reversal Threshold (x ATR)", minval = 0.3, step = 0.1, group = G1, tooltip = "How far price must close back from an extreme before that extreme is confirmed as a swing. This is the only dial that decides what counts as a leg. Larger means fewer and bigger legs.")

maxSamples = input.int(200, "Legs Kept In Sample", minval = 20, maxval = 1000, group = G2)
minSamples = input.int(15, "Minimum Legs Before Projecting", minval = 5, maxval = 200, group = G2)

projBars  = input.int(40, "Projection Width (bars)", minval = 5, maxval = 300, group = G3)
showProj  = input.bool(true, "Show Projection Zone", group = G3)
showMedLine = input.bool(true, "Show Median Target Line", group = G3)

enableSetup = input.bool(true, "Draw Entry, Stop and Targets", group = G4)
stopBuf     = input.float(0.30, "Stop Buffer (x ATR)", minval = 0.0, step = 0.05, group = G4)

showZig    = input.bool(true, "Show Leg Skeleton", group = G5)
zigWidth   = input.int(3, "Skeleton Thickness", minval = 1, maxval = 4, group = G5)
maxDraw    = input.int(30, "Legs Drawn", minval = 5, maxval = 100, group = G5)
showRatios = input.bool(true, "Label Each Leg With Its Ratio", group = G5)
paintBars  = input.bool(true, "Paint Candles by Leg Direction", group = G5)
showPanel  = input.bool(true, "Show Panel", group = G5)
panelPos   = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G5)

cUp   = input.color(#00e08a, "Up Leg", group = G6)
cDn   = input.color(#ff4560, "Down Leg", group = G6)
cProj = input.color(#c9a227, "Projection", group = G6)
cTxt  = input.color(#0b0f18, "Label Text", group = G6)

// ============================================================================
//  1. LEG ENGINE
// ============================================================================
float atrV = ta.atr(atrLen)
float rev  = atrV * revMult

var int   legDir = 0        // direction of the leg currently forming
var float extP   = na       // running extreme of the forming leg
var int   extB   = na
var float swP    = na       // last confirmed swing price
var int   swB    = na
var float prevLeg = na      // size of the last completed leg

var array<float> ratios  = array.new<float>()
var array<line>  zzLines = array.new<line>()
var array<label> zzLabs  = array.new<label>()

bool  newLeg    = false
int   newLegDir = 0
float lastRatio = na

if barstate.isconfirmed and atrV > 0

    if legDir == 0
        legDir := close >= open ? 1 : -1
        extP   := legDir == 1 ? high : low
        extB   := bar_index
        swP    := legDir == 1 ? low : high
        swB    := bar_index

    else
        // extend the running extreme
        if legDir == 1 and high > extP
            extP := high
            extB := bar_index
        if legDir == -1 and low < extP
            extP := low
            extB := bar_index

        bool flip = legDir == 1 ? close < extP - rev : close > extP + rev

        if flip
            float legSize = math.abs(extP - swP)
            float ratio = na(prevLeg) or prevLeg <= 0 ? na : legSize / prevLeg

            if not na(ratio) and ratio > 0
                array.push(ratios, ratio)
                if array.size(ratios) > maxSamples
                    array.shift(ratios)
                lastRatio := ratio

            if showZig and not na(swP)
                line zl = line.new(swB, swP, extB, extP, color = legDir == 1 ? cUp : cDn, width = zigWidth)
                array.push(zzLines, zl)
                if array.size(zzLines) > maxDraw
                    line.delete(array.get(zzLines, 0))
                    array.remove(zzLines, 0)

                if showRatios and not na(ratio)
                    label zb = label.new(extB, extP, str.tostring(ratio, "#.##") + " x", style = legDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(legDir == 1 ? cUp : cDn, 25), textcolor = cTxt, size = size.small)
                    array.push(zzLabs, zb)
                    if array.size(zzLabs) > maxDraw
                        label.delete(array.get(zzLabs, 0))
                        array.remove(zzLabs, 0)

            prevLeg   := legSize
            swP       := extP
            swB       := extB
            legDir    := legDir == 1 ? -1 : 1
            extP      := legDir == 1 ? high : low
            extB      := bar_index
            newLeg    := true
            newLegDir := legDir

// ============================================================================
//  2. DISTRIBUTION
// ============================================================================
int  nLegs = array.size(ratios)
bool hasStats = nLegs >= minSamples

float rMed = hasStats ? array.median(ratios) : na
float rQ1  = hasStats ? array.percentile_nearest_rank(ratios, 25) : na
float rQ3  = hasStats ? array.percentile_nearest_rank(ratios, 75) : na
float rP90 = hasStats ? array.percentile_nearest_rank(ratios, 90) : na

// ============================================================================
//  3. PROJECTION OF THE FORMING LEG
// ============================================================================
bool canProject = hasStats and not na(prevLeg) and prevLeg > 0 and not na(swP) and legDir != 0

float projMed = not canProject ? na : legDir == 1 ? swP + prevLeg * rMed : swP - prevLeg * rMed
float projQ3  = not canProject ? na : legDir == 1 ? swP + prevLeg * rQ3  : swP - prevLeg * rQ3
float projP90 = not canProject ? na : legDir == 1 ? swP + prevLeg * rP90 : swP - prevLeg * rP90

float curSize  = not na(swP) ? math.abs(close - swP) : na
float curRatio = na(prevLeg) or prevLeg <= 0 or na(curSize) ? na : curSize / prevLeg
float progress = na(curRatio) or na(rMed) or rMed <= 0 ? na : 100.0 * curRatio / rMed

var box  projBox = na
var line projLine = na
var label projLab = na

if barstate.islast
    box.delete(projBox)
    line.delete(projLine)
    label.delete(projLab)
    if showProj and canProject
        float top = math.max(projMed, projP90)
        float bot = math.min(projMed, projP90)
        projBox := box.new(bar_index, top, bar_index + projBars, bot, border_color = color.new(cProj, 40), border_width = 1, bgcolor = color.new(cProj, 84))
    if showMedLine and canProject
        projLine := line.new(bar_index - 1, projMed, bar_index + projBars, projMed, color = cProj, width = 2, style = line.style_dashed)
        projLab := label.new(bar_index + projBars, projMed, "median target  " + str.tostring(projMed, format.mintick), style = label.style_label_left, color = color.new(cProj, 10), textcolor = cTxt, size = size.normal)

// ============================================================================
//  4. SETUPS
// ============================================================================
var int   tDir   = 0
var float tEntry = na
var float tStop  = na
var float tT1    = na
var float tT2    = na
var float tT3    = na
var int   wins   = 0
var int   losses = 0

bool sigLong  = false
bool sigShort = false

if barstate.isconfirmed and atrV > 0

    if tDir == 1
        if low <= tStop
            losses += 1
            tDir := 0
        else if high >= tT1
            wins += 1
            tDir := 0
    else if tDir == -1
        if high >= tStop
            losses += 1
            tDir := 0
        else if low <= tT1
            wins += 1
            tDir := 0

    if newLeg and enableSetup and hasStats and tDir == 0 and not na(prevLeg) and prevLeg > 0
        tDir   := newLegDir
        tEntry := close
        tStop  := newLegDir == 1 ? swP - atrV * stopBuf : swP + atrV * stopBuf
        tT1    := newLegDir == 1 ? swP + prevLeg * rQ1  : swP - prevLeg * rQ1
        tT2    := newLegDir == 1 ? swP + prevLeg * rMed : swP - prevLeg * rMed
        tT3    := newLegDir == 1 ? swP + prevLeg * rQ3  : swP - prevLeg * rQ3
        sigLong  := newLegDir == 1
        sigShort := newLegDir == -1

// ============================================================================
//  5. PLOTS
// ============================================================================
color legTint = legDir == 1 ? cUp : legDir == -1 ? cDn : color.gray
plotcandle(paintBars ? open : na, paintBars ? high : na, paintBars ? low : na, paintBars ? close : na, title = "Leg Candles", color = color.new(legTint, 20), wickcolor = color.new(legTint, 20), bordercolor = color.new(legTint, 20))

float plEntry = enableSetup and tDir != 0 ? tEntry : na
float plStop  = enableSetup and tDir != 0 ? tStop  : na
float plT1    = enableSetup and tDir != 0 ? tT1    : na
float plT2    = enableSetup and tDir != 0 ? tT2    : na
float plT3    = enableSetup and tDir != 0 ? tT3    : na

pEn = plot(plEntry, "Entry", color = #ffffff, style = plot.style_linebr, linewidth = 2)
pSt = plot(plStop, "Stop", color = cDn, style = plot.style_linebr, linewidth = 2)
pT3 = plot(plT3, "Target 3", color = cUp, style = plot.style_linebr, linewidth = 2)
plot(plT1, "Target 1", color = color.new(cUp, 40), style = plot.style_linebr, linewidth = 1)
plot(plT2, "Target 2", color = color.new(cUp, 40), style = plot.style_linebr, linewidth = 1)

fill(pEn, pSt, color = color.new(cDn, 88), title = "Risk")
fill(pEn, pT3, color = color.new(cUp, 92), title = "Reward")

if sigLong
    label.new(bar_index, low, "LONG  " + str.tostring(close, format.mintick), style = label.style_label_up, color = color.new(cUp, 0), textcolor = cTxt, size = size.normal)
if sigShort
    label.new(bar_index, high, "SHORT  " + str.tostring(close, format.mintick), style = label.style_label_down, color = color.new(cDn, 0), textcolor = cTxt, size = size.normal)

// ============================================================================
//  6. PANEL
// ============================================================================
f_pos(string s) => s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.middle_right

f_share(float lo, float hi) =>
    int sz = array.size(ratios)
    int c = 0
    if sz > 0
        for i = 0 to sz - 1
            float v = array.get(ratios, i)
            if v >= lo and v < hi
                c += 1
    sz > 0 ? 100.0 * c / sz : na

if barstate.islast and showPanel
    var table p = table.new(f_pos(panelPos), 2, 10, bgcolor = color.new(#0b0f18, 8), border_width = 1, border_color = color.new(#2a2e39, 0), frame_width = 1, frame_color = color.new(#2a2e39, 0))

    table.cell(p, 0, 0, "LEG ANATOMY", text_color = cTxt, text_halign = text.align_center, bgcolor = cProj, text_size = size.normal)
    table.cell(p, 1, 0, syminfo.ticker + "  " + timeframe.period, text_color = cTxt, text_halign = text.align_center, bgcolor = cProj, text_size = size.normal)

    if not hasStats
        table.cell(p, 0, 1, "Status", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 1, "collecting  " + str.tostring(nLegs) + " / " + str.tostring(minSamples), text_color = cProj, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 0, 2, "Hint", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 2, "load more history", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
    else
        table.cell(p, 0, 1, "Legs measured", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 1, str.tostring(nLegs), text_color = #e6eaf2, text_halign = text.align_center, text_size = size.normal)

        table.cell(p, 0, 2, "Median leg", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 2, str.tostring(rMed, "#.##") + " x previous", text_color = cProj, text_halign = text.align_center, text_size = size.normal)

        table.cell(p, 0, 3, "Quartiles", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 3, str.tostring(rQ1, "#.##") + "  to  " + str.tostring(rQ3, "#.##"), text_color = #e6eaf2, text_halign = text.align_center, text_size = size.normal)

        table.cell(p, 0, 4, "Shallow, under 0.62", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 4, str.tostring(f_share(0.0, 0.618), "#.#") + " %", text_color = #e6eaf2, text_halign = text.align_center, text_size = size.normal)

        table.cell(p, 0, 5, "Deep, 0.62 to 1.00", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 5, str.tostring(f_share(0.618, 1.0), "#.#") + " %", text_color = #e6eaf2, text_halign = text.align_center, text_size = size.normal)

        table.cell(p, 0, 6, "Extension, over 1.00", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 6, str.tostring(f_share(1.0, 1000.0), "#.#") + " %", text_color = cUp, text_halign = text.align_center, text_size = size.normal)

        table.cell(p, 0, 7, "Current leg", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 7, (legDir == 1 ? "up  " : "down  ") + (na(curRatio) ? "-" : str.tostring(curRatio, "#.##") + " x"), text_color = legTint, text_halign = text.align_center, text_size = size.normal)

        table.cell(p, 0, 8, "Progress to median", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 8, na(progress) ? "-" : str.tostring(progress, "#") + " %", text_color = na(progress) ? #9aa4b2 : progress >= 100 ? cProj : #e6eaf2, text_halign = text.align_center, text_size = size.normal)

        int settled = wins + losses
        table.cell(p, 0, 9, "Record to T1", text_color = #9aa4b2, text_halign = text.align_center, text_size = size.normal)
        table.cell(p, 1, 9, settled < 10 ? "collecting " + str.tostring(settled) + "/10" : str.tostring(100.0 * wins / settled, "#.#") + " %  (" + str.tostring(settled) + ")", text_color = settled < 10 ? cProj : (wins >= losses ? cUp : cDn), text_halign = text.align_center, text_size = size.normal)

// ============================================================================
//  7. ALERTS
// ============================================================================
alertcondition(sigLong, title = "Long Setup", message = "Leg Anatomy: a new up leg was confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigShort, title = "Short Setup", message = "Leg Anatomy: a new down leg was confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(newLeg, title = "New Leg Confirmed", message = "Leg Anatomy: a swing was confirmed and a new leg began on {{ticker}} {{interval}}")
alertcondition(not na(progress) and progress >= 100 and progress[1] < 100, title = "Median Target Reached", message = "Leg Anatomy: the forming leg reached the median projection on {{ticker}} {{interval}}")

if sigLong
    alert("Leg Anatomy - LONG on " + syminfo.ticker + " " + timeframe.period + " | entry " + str.tostring(tEntry, format.mintick) + " | stop " + str.tostring(tStop, format.mintick) + " | targets " + str.tostring(tT1, format.mintick) + " " + str.tostring(tT2, format.mintick) + " " + str.tostring(tT3, format.mintick), alert.freq_once_per_bar_close)
if sigShort
    alert("Leg Anatomy - SHORT on " + syminfo.ticker + " " + timeframe.period + " | entry " + str.tostring(tEntry, format.mintick) + " | stop " + str.tostring(tStop, format.mintick) + " | targets " + str.tostring(tT1, format.mintick) + " " + str.tostring(tT2, format.mintick) + " " + str.tostring(tT3, format.mintick), alert.freq_once_per_bar_close)
````
