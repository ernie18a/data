# Omega Zones [OmegaTools]

- url: https://www.tradingview.com/script/ZUpopB0f-Omega-Zones-OmegaTools/
- type: indicator
- pine_id: PUB;08eadb943b2340bd8be34d2f129d7999
- version: 1.0

## Description

[b]Omega Zones[/b]

[b]Overview[/b]

Omega Zones is a supply and demand mapping tool that automatically detects, scores, and manages institutional order-block zones directly on the price chart. Rather than treating every swing as equally significant, it identifies the specific candles where meaningful order flow originated, grades each one on a multi-factor confidence scale, and then tracks its entire lifecycle — from untouched, to tested, to broken. The result is a clean, self-maintaining map of the price levels where supply and demand are most likely to react, with the strongest zones visually emphasized and weaker noise filtered out.

The indicator runs as an overlay on any symbol and any timeframe.

[b]How It Works[/b]

Every zone is anchored to a [b]confirmation window[/b] whose length you control through the Confidence Bars input. This is the central design idea of the tool: a zone is only registered once price has had a defined number of bars to validate the move away from its origin. A short window plots zones earlier and closer to real time; a longer window demands more confirmation before committing a level to the chart. This lets you tune the trade-off between recency and reliability instead of being locked into a fixed lookahead.

Within that window, Omega Zones detects order blocks through [b]two independent structural pathways[/b]:

[b]Swing reversal[/b] — a confirmed swing high or low (built from an asymmetric pivot: a longer window on the left, the confirmation window on the right) where price subsequently reclaims back through the pivot's extreme and thrusts away with conviction. The zone is anchored to the true origin candle — the last opposite-colored candle before the move — rather than naively to the pivot bar itself.

[b]Trend pause[/b] — a compact base candle bracketed by directional momentum on both sides (the classic rally-base-rally and drop-base-drop structures). A tight bullish pause inside an advance becomes demand; a tight bearish pause inside a decline becomes supply. The momentum leg leaving the base is measured across the full confirmation window, so longer windows require sustained follow-through.

[b]The Confidence Score[/b]

What separates a high-probability zone from a marginal one is not whether it formed, but how it formed. Each detected zone is graded on a [b]composite strength score[/b] that aggregates several orthogonal pieces of evidence:

[b]Displacement[/b] — how forcefully price left the zone, measured in volatility-adjusted (ATR) units, with additional credit awarded for exceptionally strong departures.

[b]Volume conviction[/b] — the volume on the origin candle expressed as a standardized z-score against its recent distribution, scored on a [b]graduated scale[/b] so that progressively heavier participation earns progressively more confidence. This is the most heavily weighted dimension of the score, reflecting that genuine order blocks are footprinted by abnormal volume.

[b]Fair value gap[/b] — whether the origin produced a three-candle imbalance, a signature of aggressive, one-sided execution.

[b]Liquidity sweep[/b] — whether the origin candle ran a prior high or low before closing back inside, capturing stop-hunt and absorption behavior.

The combined score drives two things: the zone must clear the minimum confidence set by the [b]Filter[/b] input to be drawn at all, and the [b]opacity[/b] of each zone scales with its score, so stronger levels appear bolder and weaker ones fade into the background. Each box is also labeled with its numeric strength for quick reference.

[b]Adaptive Zone Geometry[/b]

When the origin candle is dominated by a rejection wick, Omega Zones intelligently narrows the zone to the candle's [b]body[/b] rather than its full range — marking where the orders actually sit instead of the rejection tail. When the candle is more balanced, the full high-to-low range is used. This produces tighter, more precise zones and cleaner retest behavior.

[b]Zone Lifecycle Management[/b]

Each zone carries a live state that the tool tracks bar by bar:

[b]Virgin[/b] — untested; price has not yet entered the zone.
[b]Touched[/b] — price has tapped the zone and reacted, but has not closed through it.
[b]Broken[/b] — price has decisively closed beyond the zone, invalidating it.

Active zones extend forward automatically until they are broken. How spent zones are handled is governed by the [b]Remove Old Orderblocs[/b] setting, giving you full control over chart cleanliness:

[b]No[/b] — every zone is preserved indefinitely.
[b]Only Broken[/b] — zones are removed the moment they are broken.
[b]Only Virgin[/b] — only untouched zones remain on the chart; once a zone is tapped it is retained briefly, then cleared, isolating the fresh, unmitigated levels.
[b]Yes[/b] — the most aggressive housekeeping, removing zones on break and retiring stale levels by age.

[b]Settings[/b]

[b]Confidence Bars[/b] — the confirmation window; lower values plot zones sooner and closer to price, higher values require more validation.
[b]Filter[/b] — minimum confidence score required to display a zone (Permissive, Normal, or Strict), letting you choose between coverage and selectivity.
[b]Remove Old Orderblocs[/b] — the lifecycle housekeeping mode described above.
[b]Lines[/b] — choose which boundary lines to draw: the proximal edge, the distal edge, both, or none.
[b]Areas[/b] — whether zone boxes extend dynamically to the current bar, stay fixed at their origin, or are hidden.
[b]Bullish / Bearish Colors[/b] — fully customizable color scheme applied across boxes, edge lines, and labels.

[b]How To Use It[/b]

Treat the zones as decision-support context rather than standalone signals. The boldest boxes mark the levels with the most order-flow evidence behind them and deserve the most attention. Reactions at [b]virgin[/b] zones — those being tested for the first time — are generally the highest-quality opportunities, which is precisely what the Only Virgin housekeeping mode is built to surface. Demand zones are natural areas to look for long setups and supply zones for short setups, ideally in alignment with your higher-timeframe bias and confirmed by your own entry method. Raise the Filter to Strict and lengthen Confidence Bars when you want only the most validated levels; loosen both when you want fuller coverage of developing structure.

[b]Notes[/b]

Zones are confirmed using completed pivots and a defined confirmation window, so they finalize after that window elapses; this is intentional confirmation logic, not repainting. The tool combines dual-path detection, a graduated multi-factor confidence model weighted toward volume, adaptive body-versus-range geometry, and a full three-state lifecycle with multiple housekeeping modes into a single self-maintaining framework.

[b]Disclaimer[/b]

This indicator is provided for informational and educational purposes only and does not constitute financial advice. Trading carries substantial risk, and the past behavior of any tool or market is not indicative of future results. Always perform your own analysis and manage risk accordingly.

## Source Code

````pine
// © OmegaTools

//@version=6
indicator('Omega Zones [OmegaTools]', 'Ω Zones', true, max_boxes_count = 500, max_lines_count = 500)

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                   Inputs                                  │
// └───────────────────────────────────────────────────────────────────────────┘

confbars = input.int(3, 'Confidence Bars', group = 'Settings', minval = 1)
thresholdinp = input.string('Normal', 'Filter', ['Strict', 'Normal', 'Permissive'], group = 'Settings')
removeold = input.string('Only Broken', 'Remove Old Orderblocs', ['Only Virgin', 'Yes', 'Only Broken', 'No'], group = 'Settings')

lineinp = input.string('Distal', 'Lines', ['All', 'Proximity', 'Distal', 'None'], group = 'Visual')
zoneinp = input.string('Extended', 'Areas', ['Extended', 'Fixed', 'None'], group = 'Visual')
upc = input.color(#2962ff, 'Bullish', group = 'Visual', inline = 'col')
dnc = input.color(#e91e63, 'Bearish', group = 'Visual', inline = 'col')
midcol = color.new(chart.fg_color, 25)

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                Calculations                               │
// └───────────────────────────────────────────────────────────────────────────┘

type Zone
    int dir
    int broken = 0
    int markedBar = na
    box bx
    line lnTop
    line lnBot

threshold = switch thresholdinp
    'Strict' => 5
    'Normal' => 4
    'Permissive' => 3

zones(int afterbars = 3) =>
    atr = ta.atr(50)
    rngSma = ta.sma(high - low, 100)
    volSma = ta.sma(volume, 50)
    volStd = ta.stdev(volume, 50)
    volz = (volume - volSma) / math.max(volStd, 1.0)
    hh77 = ta.highest(high, 77)
    ll77 = ta.lowest(low, 77)

    isPivH = not na(ta.pivothigh(11, afterbars))
    isPivL = not na(ta.pivotlow(11, afterbars))

    anc = isPivL ? (close[afterbars] < open[afterbars] ? afterbars : afterbars + 1) : isPivH ? (close[afterbars] > open[afterbars] ? afterbars : afterbars + 1) : afterbars
    ancRng = high[anc] - low[anc]
    ancBody = math.abs(close[anc] - open[anc])
    ancFit = ancRng < rngSma * 1.5

    priorHigh = hh77[anc + 1]
    priorLow  = ll77[anc + 1]
    sweepH = high[anc] > priorHigh and close[anc] < priorHigh
    sweepL = low[anc]  < priorLow  and close[anc] > priorLow

    disp  = close - close[anc]
    thrUp = disp >  atr
    thrDn = disp < -atr

    reclaimedUp = false
    reclaimedDn = false
    rallyOut    = true
    dropOut     = true
    for k = 0 to afterbars - 1
        if close[k] > high[afterbars]
            reclaimedUp := true
        if close[k] < low[afterbars]
            reclaimedDn := true
        if close[k] <= close[k + 1]
            rallyOut := false
        if close[k] >= close[k + 1]
            dropOut := false

    reclaimBull = isPivL and reclaimedUp and close[afterbars + 1] < open[afterbars + 1] and thrUp and ancFit
    reclaimBear = isPivH and reclaimedDn and close[afterbars + 1] > open[afterbars + 1] and thrDn and ancFit

    baseTight = (high[afterbars] - low[afterbars]) < rngSma * 0.8
    rallyIn = close[afterbars + 1] > close[afterbars + 2] and close[afterbars + 2] > close[afterbars + 3]
    dropIn  = close[afterbars + 1] < close[afterbars + 2] and close[afterbars + 2] < close[afterbars + 3]
    rbr = rallyIn and close[afterbars] < open[afterbars] and baseTight and rallyOut
    dbd = dropIn  and close[afterbars] > open[afterbars] and baseTight and dropOut

    fvgBull = low[anc - 1] > high[anc + 1]
    fvgBear = high[anc - 1] < low[anc + 1]

    strength = 1
    if math.abs(disp) > atr * 2
        strength += 1
    if math.abs(disp) > atr * 4
        strength += 1
    if volz[anc] > 0.0
        strength += 1
    if volz[anc] > 1.0
        strength += 1
    if volz[anc] > 2.0
        strength += 1
    if volz[anc] > 3.0
        strength += 1
    if fvgBull or fvgBear
        strength += 1
    if sweepH or sweepL
        strength += 1

    int dir = 0
    if (reclaimBull or rbr) and not (reclaimBear or dbd) and close > low[anc]
        dir := 1
    if (reclaimBear or dbd) and not (reclaimBull or rbr) and close < high[anc]
        dir := -1

    Zone z = na
    if dir != 0 and strength >= threshold
        useBody = dir > 0 ? (math.min(open[anc], close[anc]) - low[anc]) > ancRng * 0.5 : (high[anc] - math.max(open[anc], close[anc])) > ancRng * 0.5
        top = dir > 0 ? (useBody ? math.min(open[anc], close[anc]) : high[anc]) : high[anc]
        bot = dir > 0 ? low[anc] : (useBody ? math.max(open[anc], close[anc]) : low[anc])

        color col = color.new(dir > 0 ? upc : dnc, (100 - strength * 10))
        int left = bar_index - anc
        int rgt = bar_index
        string lbl = zoneinp != 'None' ? str.tostring(strength) : ''
        box bx = box.new(left = left, right = zoneinp != 'None' ? rgt : left, top = top, bottom = bot, bgcolor = col, border_color = color.new(col, 100), text = lbl, text_color = midcol, text_halign = text.align_right, text_size = 7)
        line lnT = na
        line lnB = na
        if dir < 0
            lnT := (lineinp == 'Distal'    or lineinp == 'All') ? line.new(x1 = left, y1 = top, x2 = bar_index, y2 = top, color = midcol, width = 1) : na
            lnB := (lineinp == 'Proximity' or lineinp == 'All') ? line.new(x1 = left, y1 = bot, x2 = bar_index, y2 = bot, color = midcol, width = 1) : na
        else
            lnT := (lineinp == 'Proximity' or lineinp == 'All') ? line.new(x1 = left, y1 = top, x2 = bar_index, y2 = top, color = midcol, width = 1) : na
            lnB := (lineinp == 'Distal'    or lineinp == 'All') ? line.new(x1 = left, y1 = bot, x2 = bar_index, y2 = bot, color = midcol, width = 1) : na
        z := Zone.new(dir = dir, bx = bx, lnTop = lnT, lnBot = lnB)

Zone newZone = zones(confbars)

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                  Plotting                                 │
// └───────────────────────────────────────────────────────────────────────────┘

var array<Zone> zoneArr = array.new<Zone>()

if not na(newZone)
    array.push(zoneArr, newZone)

if array.size(zoneArr) > 0
    for i = array.size(zoneArr) - 1 to 0
        Zone z = array.get(zoneArr, i)

        if z.broken < 2
            broke = z.dir > 0 ? close < box.get_bottom(z.bx) : close > box.get_top(z.bx)
            if broke
                if z.broken == 0
                    z.markedBar := bar_index
                z.broken := 2
            else
                touched = z.dir > 0 ? low <= box.get_top(z.bx) : high >= box.get_bottom(z.bx)
                if touched and z.broken == 0
                    z.broken := 1
                    z.markedBar := bar_index

        if z.broken < 2
            line.set_x2(z.lnTop, bar_index)
            line.set_x2(z.lnBot, bar_index)
            if zoneinp == 'Extended'
                box.set_right(z.bx, bar_index)

        del = false
        if removeold == 'Only Broken'
            del := z.broken == 2
        else if removeold == 'Only Virgin'
            del := z.broken > 0 and not na(z.markedBar) and bar_index - z.markedBar >= 11 or box.get_left(z.bx) + 1000 < bar_index
        else if removeold == 'Yes'
            del := z.broken == 2 or box.get_left(z.bx) + 500 < bar_index

        if del
            box.delete(z.bx)
            line.delete(z.lnTop)
            line.delete(z.lnBot)
            array.remove(zoneArr, i)

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                               End of Script                               │
// └───────────────────────────────────────────────────────────────────────────┘
````
