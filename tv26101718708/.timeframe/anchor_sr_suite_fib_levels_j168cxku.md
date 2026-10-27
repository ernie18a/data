# Anchor S&R Suite - Fib Levels

- url: https://www.tradingview.com/script/J168cXKu-Anchor-S-R-Suite-Fib-Levels/
- type: indicator
- pine_id: PUB;2cc4b2d7435c43b797714d2776665503
- version: 1.0

## Description

[b]Anchor S&R Suite — Fib Levels
[/b]Anchored Fibonacci retracements & projections that recompute on a higher-time-frame rhythm and never repaint.

Instead of dragging a fib tool by hand between a swing high and a swing low, this indicator measures a reference range automatically — the High/Low (or Open/Close) of one or several CLOSED higher-time-frame (HTF) candles — and plots the full Fibonacci ladder from it, across your entire chart history. The result is a clean, repeatable level grid that updates on a predictable rhythm and never moves under your feet.


[b]WHAT MAKES IT DIFFERENT
[/b]
• Anchored to a time frame, not a manual swing. You choose the cadence (e.g. Weekly); the levels are recomputed once per closed HTF candle and held perfectly flat until the next one closes — clean horizontal steps, not sloping diagonals.

• Zero repaint. The indicator only ever reads candles that have already CLOSED. During the current, still-forming HTF period the levels are based on the previous period and do not move — not on every tick, not on every chart bar. A level you saw an hour ago sits in the exact same place now, so what you backtest by eye is what you would have traded.

• Warm-up, not repaint. The only caveat: the first levels can appear only once enough closed HTF candles exist (exactly like a moving average needs its length in bars). No historical value is ever rewritten — loading more history simply reveals earlier levels.


[b]HOW IT WORKS
[/b]
On the close of every cadence candle, the indicator takes the range of the last closed candle(s) and rebuilds the ladder from it. That ladder stays fixed until the next cadence close, when it jumps to the new values.

• Retracement levels sit INSIDE the range — the pullback / continuation zones you watch while price works within an established range.
• Projection levels sit OUTSIDE the range — measured-move / breakout targets for when price leaves the range.

The deliberate one-bar gap you see at each boundary is intentional: it marks the bar where a new HTF candle closed and the ladder was recomputed. It is the visual signature of a correctly anchored, non-repainting level — not a glitch.


[b]THE CALCULATION
[/b]
Let mergeHi and mergeLo be the high and low of the anchored window, and H = mergeHi − mergeLo its height. For a ratio f, the four directions are:

• Retracement from the high :  mergeHi − f × H   (descends into the range)
• Retracement from the low  :  mergeLo + f × H   (rises into the range)
• Projection above the high :  mergeHi + f × H   (extends upward)
• Projection below the low  :  mergeLo − f × H   (extends downward)

At f = 0 a level sits on its anchor; at f = 1 it reaches the opposite end of the range. So 0 and 1 are the range bounds (the decision zone lives between them, 0.382–0.786). Ratios are not limited to 0–1: a value above 1 (e.g. 1.272, 1.618) projects beyond the range as an extension target.


[b]SETTINGS[/b]

• Cadence TF — the heartbeat. It controls both which range the fibs are measured from and how often they refresh. Higher cadence = fewer, wider, slower levels (a macro map); lower cadence = tighter, more reactive levels. Must be greater than the chart TF.

• Lookback (1–20) — how many closed HTF candles merge into ONE range. 1 = the last period only (maximum reactivity); 4 (default) = the highest high / lowest low of the last four (broader, calmer, anchored to more structure).

• Source — High/Low (full candle range, wicks included; captures the true extremes) or Open/Close (bodies only, ignores wicks; tighter, “accepted-value” levels).

• Fib Mode — Retracement / Projection / Both. It also greys out the inputs of the family it excludes.

• 7 levels — each row gives INDEPENDENT control over its Retracement and its Projection: a toggle plus a fully editable ratio for each family, side by side. So any level can be a retracement, a projection, both, or neither, each with its own value. The classic 0.382 / 0.5 / 0.618 / 0.786 are shown by default; 0 / 0.236 / 1 are available. Edit any value to match your method (an OTE-style 0.705, a 0.65, or a 1.618 extension).

• Display — independent show/hide and colour for the Upper family, the Lower family and the Range lines; level & range line widths; optional per-level ratio labels.

[image]https://www.tradingview.com/x/3TN7wvot/[/image]
Lookback = 1 — the last closed period only (tight, reactive).

[image]https://www.tradingview.com/x/fOjtNxaf/[/image]
Lookback = 4 (default) — a broader, calmer range over four periods.

[image]https://www.tradingview.com/x/3tklbNHW/[/image]
Retracement / Projection / Both.


[b]HOW TO TRADE THE LEVELS
[/b]
The indicator draws the map; you decide. A level is a decision point, not a guarantee.

• Confluence first. A level matters most when several things agree at the same price: a retracement and a projection landing together, a level sitting on a prior swing high/low or a round number. The more overlap, the stronger the reaction tends to be.
• React, don’t predict. Watch HOW price behaves at a level — a rejection wick, a reclaim, a tight consolidation — rather than assuming it must stop there.
• Entries. In a pullback, continuation entries tend to cluster around 0.5 / 0.618 / 0.786; wait for a reaction rather than a blind limit on the line.
• Stops & targets. A stop just beyond the next level (where the idea is invalidated); targets at the opposite retracements, the range bounds, or the projection extensions (0.618 / 1.0 / 1.618).
• Bias from the range. Holding above the 0.5 of the range reads as relative strength; losing the deep 0.786 suggests the pullback is failing.


[b]EXAMPLE SETUPS
[/b]
• Swing (default): chart 1h–4h, Cadence = Weekly, Lookback = 4, Source = High/Low, Mode = Retracement. The multi-week range frames the swing; the internal retracements mark where to add or fade.
• Intraday off the prior day: chart 5–15m, Cadence = Daily, Lookback = 1, Mode = Both. Prior-day range as anchors, internal retracements as pullback zones, projections as breakout targets.
• Macro context: chart Daily, Cadence = Monthly, Lookback = 1. A slow, stable map of monthly value for bias.

Works on any market and any timeframe.

[i]This indicator is a charting / analysis tool. It is not financial advice and does not generate buy or sell signals.[/i]

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
// Anchor S&R Suite — Fib Levels
// ═══════════════════════════════════════════════════════════════════════════
//
// Anchored Fibonacci retracement & projection levels.
//
// Concept: on each CADENCE (HTF) candle close, compute Fibonacci levels from the
// range (High/Low or Open/Close) of the CLOSED HTF candle(s); these are valid
// for the whole NEXT (forming) HTF period.
//
// ── ZERO REPAINT ────────────────────────────────────────────────────────────
//   We never read the in-progress HTF candle. Non-repaint idiom (PineCoders):
//   request.security(..., expr[1], lookahead_on). lookahead_on "sees" the value
//   from the period start (would leak future), and the [1] offset cancels that
//   leak exactly → returns the LAST CLOSED HTF candle, fixed for the whole
//   forming period. NOTE: lookahead_off + [1] double-lags (off by one HTF bar).
//   Warmup (NOT repaint): the first levels need `lookback` CLOSED HTF candles of
//   history before they can appear (like any window-based study). No past value
//   ever changes — loading more history only reveals EARLIER levels.
//
// ── Scope ───────────────────────────────────────────────────────────────────
//   • Cadence TF, Lookback (1..20 HTF candles merged into one range)
//   • Source = High/Low or Open/Close
//   • Fib Mode = Retracement (inside) / Projection (outside) / Both — also GREYS
//     the inputs of the excluded family.
//   • 7 RETRACEMENT + 7 PROJECTION levels, INDEPENDENTLY toggleable & editable.
//     Ratios are NOT limited to 0..1: > 1 (e.g. 1.272, 1.618) extends beyond range.
//
// ── Rendering ───────────────────────────────────────────────────────────────
//   • One plot per level, REUSED: a (series) value updated on each new HTF
//     period → step line over the WHOLE history, no ~500 line/box object cap.
//   • The VALUE is always present (level spans the whole HTF period); segments
//     are cut by COLOR = na on the single boundary bar (idiom
//     "Pivot == Pivot[1] ? col : na"). This hides the diagonal transition
//     segment without leaving a hole in the level.
//   • 7 fib × 4 directions = 28 + 2 range = 30 plots. A plot whose COLOUR is a
//     series counts double in Pine's plot budget → 30 × 2 = 60 ≤ 64.
//   • Fib uses ONLY HTF OHLC → no dependency on LTF data.
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Anchor S&R Suite — Fib Levels", shorttitle = "Anchor SR — Fib",
     overlay = true, max_labels_count = 100)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════

// ── "Cadence" group (shared across the whole suite) ──
gCad = "Cadence"
cadenceTf = input.timeframe("W", "Cadence TF", group = gCad,
     tooltip = "HTF that defines WHEN to recompute the levels. Must be > chart TF.")
lookback = input.int(4, "Lookback (HTF candles)", minval = 1, maxval = 20, group = gCad,
     tooltip = "Number of closed HTF candles merged into ONE range — the highest top and lowest bottom across them, where top/bottom follow the Source setting (High/Low or Open/Close).")

// ── "Fibonacci Levels" group ──
gFib = "Fibonacci Levels"
priceSource = input.string("High/Low", "Source", options = ["High/Low", "Open/Close"], group = gFib,
     tooltip = "Range basis: candle High/Low or Open/Close.")
fibMode = input.string("Retracement", "Fib Mode", options = ["Retracement", "Projection", "Both"], group = gFib,
     tooltip = "Retracement = levels inside the range. Projection = levels outside the range. Both = both families. The mode also GREYS OUT the inputs of the family it excludes.")
doRetr = fibMode == "Retracement" or fibMode == "Both"
doProj = fibMode == "Projection"  or fibMode == "Both"
// Per-level: INDEPENDENT Retracement and Projection control on ONE row — a toggle +
// editable ratio for each family. Empty checkbox labels so the columns align; the
// ratio is the float field's label. Inputs of the family excluded by Fib Mode are
// greyed; a ratio is also greyed when its own level toggle is off.
onRetr00  = input.bool(false, "", inline = "f00", group = gFib, active = doRetr)
vRetr00   = input.float(0.0,   "Retracement 1", inline = "f00", group = gFib, step = 0.001, active = doRetr and onRetr00,
     tooltip = "Fibonacci ratios are fully editable and NOT limited to 0–1. A value above 1 (e.g. 1.272, 1.618) projects the level beyond the range as an extension target.")
onProj00  = input.bool(false, "", inline = "f00", group = gFib, active = doProj)
vProj00   = input.float(0.0,   "Projection 1", inline = "f00", group = gFib, step = 0.001, active = doProj and onProj00,
     tooltip = "Projection ratio — the level is projected OUTSIDE the range (above the high / below the low) by ratio × range. 0.618, 1.0, 1.618 are common extension targets.")
onRetr236 = input.bool(false, "", inline = "f236", group = gFib, active = doRetr)
vRetr236  = input.float(0.236, "Retracement 2", inline = "f236", group = gFib, step = 0.001, active = doRetr and onRetr236)
onProj236 = input.bool(false, "", inline = "f236", group = gFib, active = doProj)
vProj236  = input.float(0.236, "Projection 2", inline = "f236", group = gFib, step = 0.001, active = doProj and onProj236)
onRetr382 = input.bool(true,  "", inline = "f382", group = gFib, active = doRetr)
vRetr382  = input.float(0.382, "Retracement 3", inline = "f382", group = gFib, step = 0.001, active = doRetr and onRetr382)
onProj382 = input.bool(true,  "", inline = "f382", group = gFib, active = doProj)
vProj382  = input.float(0.382, "Projection 3", inline = "f382", group = gFib, step = 0.001, active = doProj and onProj382)
onRetr5   = input.bool(true,  "", inline = "f5", group = gFib, active = doRetr)
vRetr5    = input.float(0.5,   "Retracement 4", inline = "f5", group = gFib, step = 0.001, active = doRetr and onRetr5)
onProj5   = input.bool(true,  "", inline = "f5", group = gFib, active = doProj)
vProj5    = input.float(0.5,   "Projection 4", inline = "f5", group = gFib, step = 0.001, active = doProj and onProj5)
onRetr618 = input.bool(true,  "", inline = "f618", group = gFib, active = doRetr)
vRetr618  = input.float(0.618, "Retracement 5", inline = "f618", group = gFib, step = 0.001, active = doRetr and onRetr618)
onProj618 = input.bool(true,  "", inline = "f618", group = gFib, active = doProj)
vProj618  = input.float(0.618, "Projection 5", inline = "f618", group = gFib, step = 0.001, active = doProj and onProj618)
onRetr786 = input.bool(true,  "", inline = "f786", group = gFib, active = doRetr)
vRetr786  = input.float(0.786, "Retracement 6", inline = "f786", group = gFib, step = 0.001, active = doRetr and onRetr786)
onProj786 = input.bool(true,  "", inline = "f786", group = gFib, active = doProj)
vProj786  = input.float(0.786, "Projection 6", inline = "f786", group = gFib, step = 0.001, active = doProj and onProj786)
onRetr1   = input.bool(false, "", inline = "f1", group = gFib, active = doRetr)
vRetr1    = input.float(1.0,   "Retracement 7", inline = "f1", group = gFib, step = 0.001, active = doRetr and onRetr1)
onProj1   = input.bool(false, "", inline = "f1", group = gFib, active = doProj)
vProj1    = input.float(1.0,   "Projection 7", inline = "f1", group = gFib, step = 0.001, active = doProj and onProj1)

// ── "Display" group ──
gDsp = "Display"
// The three families (Upper / Lower / Range) share ONE row: toggle + colour each.
showUpper  = input.bool(true, "Upper", inline = "disp", group = gDsp,
     tooltip = "Show the HIGH-anchored family: retracements descending from the high and projections above it.")
upperCol   = input.color(color.new(#26a69a, 30), "", inline = "disp", group = gDsp, active = showUpper)
showLower  = input.bool(true, "Lower", inline = "disp", group = gDsp,
     tooltip = "Show the LOW-anchored family: retracements rising from the low and projections below it.")
lowerCol   = input.color(color.new(#ef5350, 30), "", inline = "disp", group = gDsp, active = showLower)
showRange  = input.bool(true, "Range", inline = "disp", group = gDsp,
     tooltip = "Show the two anchor-range bounds (the merged top & bottom the fibs are measured from — i.e. the 0 and 1.0 levels).")
rangeCol   = input.color(color.new(#ff9800, 20), "", inline = "disp", group = gDsp, active = showRange)
lineWidth  = input.int(1, "Levels width", minval = 1, maxval = 4, group = gDsp,
     tooltip = "Line thickness of the fib level plots.")
rangeWidth = input.int(2, "Range width",  minval = 1, maxval = 4, group = gDsp, active = showRange,
     tooltip = "Line thickness of the two range-bound lines.")
showLabels = input.bool(false, "Labels (current period)", group = gDsp,
     tooltip = "Show the fib ratio at the right edge, for the current period only.")

// ═══════════════════════════════════════════════════════════════════════════
// NON-REPAINT HTF ENGINE
// ═══════════════════════════════════════════════════════════════════════════
// Range merged over `lookback` CLOSED HTF candles. ta.highest/lowest run in the
// HTF context; [1] = up to the last closed candle; lookahead_on + [1] = canonical
// non-repaint (returns P-1 fixed for the whole forming period P).
htfHi() =>
    s = priceSource == "High/Low" ? high : math.max(open, close)
    ta.highest(s, lookback)[1]
htfLo() =>
    s = priceSource == "High/Low" ? low : math.min(open, close)
    ta.lowest(s, lookback)[1]

mergeHi = request.security(syminfo.tickerid, cadenceTf, htfHi(), barmerge.gaps_off, barmerge.lookahead_on)
mergeLo = request.security(syminfo.tickerid, cadenceTf, htfLo(), barmerge.gaps_off, barmerge.lookahead_on)

// New HTF period boundary: true on the first chart bar of each HTF period,
// aligned with when mergeHi/mergeLo change → single bar (used to cut segments).
isNew = timeframe.change(cadenceTf)

H        = mergeHi - mergeLo
validCad = timeframe.in_seconds(cadenceTf) > timeframe.in_seconds()
valid    = validCad and not na(H) and H > 0

// ── Level value: always present across the whole period (na = hidden) ────────
// doRetr/doProj come from Fib Mode (defined in the inputs); the `on` flag is the
// per-level toggle of that family.
vRetrHi(float f, bool on) => valid and doRetr and on ? mergeHi - f * H : na  // retracement, High-anchored (↓)
vRetrLo(float f, bool on) => valid and doRetr and on ? mergeLo + f * H : na  // retracement, Low-anchored  (↑)
vProjHi(float f, bool on) => valid and doProj and on ? mergeHi + f * H : na  // projection above (↑)
vProjLo(float f, bool on) => valid and doProj and on ? mergeLo - f * H : na  // projection below (↓)

// Color: na on the boundary bar → hides the diagonal transition segment (×2 plots).
// Also na when the family is hidden (Upper/Lower show toggles) → whole family off.
cUpper = (isNew or not showUpper) ? na : upperCol
cLower = (isNew or not showLower) ? na : lowerCol

// ═══════════════════════════════════════════════════════════════════════════
// PLOTS — 7 fib × 4 directions (continuous value; color = na cut)
// ═══════════════════════════════════════════════════════════════════════════
// fib 0
plot(vRetrHi(vRetr00, onRetr00), "0 Retr↓",  color = cUpper, linewidth = lineWidth)
plot(vRetrLo(vRetr00, onRetr00), "0 Retr↑",  color = cLower, linewidth = lineWidth)
plot(vProjHi(vProj00, onProj00), "0 Proj↑",  color = cUpper, linewidth = lineWidth)
plot(vProjLo(vProj00, onProj00), "0 Proj↓",  color = cLower, linewidth = lineWidth)
// fib 0.236
plot(vRetrHi(vRetr236, onRetr236), "0.236 Retr↓", color = cUpper, linewidth = lineWidth)
plot(vRetrLo(vRetr236, onRetr236), "0.236 Retr↑", color = cLower, linewidth = lineWidth)
plot(vProjHi(vProj236, onProj236), "0.236 Proj↑", color = cUpper, linewidth = lineWidth)
plot(vProjLo(vProj236, onProj236), "0.236 Proj↓", color = cLower, linewidth = lineWidth)
// fib 0.382
plot(vRetrHi(vRetr382, onRetr382), "0.382 Retr↓", color = cUpper, linewidth = lineWidth)
plot(vRetrLo(vRetr382, onRetr382), "0.382 Retr↑", color = cLower, linewidth = lineWidth)
plot(vProjHi(vProj382, onProj382), "0.382 Proj↑", color = cUpper, linewidth = lineWidth)
plot(vProjLo(vProj382, onProj382), "0.382 Proj↓", color = cLower, linewidth = lineWidth)
// fib 0.5
plot(vRetrHi(vRetr5, onRetr5), "0.5 Retr↓", color = cUpper, linewidth = lineWidth)
plot(vRetrLo(vRetr5, onRetr5), "0.5 Retr↑", color = cLower, linewidth = lineWidth)
plot(vProjHi(vProj5, onProj5), "0.5 Proj↑", color = cUpper, linewidth = lineWidth)
plot(vProjLo(vProj5, onProj5), "0.5 Proj↓", color = cLower, linewidth = lineWidth)
// fib 0.618
plot(vRetrHi(vRetr618, onRetr618), "0.618 Retr↓", color = cUpper, linewidth = lineWidth)
plot(vRetrLo(vRetr618, onRetr618), "0.618 Retr↑", color = cLower, linewidth = lineWidth)
plot(vProjHi(vProj618, onProj618), "0.618 Proj↑", color = cUpper, linewidth = lineWidth)
plot(vProjLo(vProj618, onProj618), "0.618 Proj↓", color = cLower, linewidth = lineWidth)
// fib 0.786
plot(vRetrHi(vRetr786, onRetr786), "0.786 Retr↓", color = cUpper, linewidth = lineWidth)
plot(vRetrLo(vRetr786, onRetr786), "0.786 Retr↑", color = cLower, linewidth = lineWidth)
plot(vProjHi(vProj786, onProj786), "0.786 Proj↑", color = cUpper, linewidth = lineWidth)
plot(vProjLo(vProj786, onProj786), "0.786 Proj↓", color = cLower, linewidth = lineWidth)
// fib 1
plot(vRetrHi(vRetr1, onRetr1), "1 Retr↓", color = cUpper, linewidth = lineWidth)
plot(vRetrLo(vRetr1, onRetr1), "1 Retr↑", color = cLower, linewidth = lineWidth)
plot(vProjHi(vProj1, onProj1), "1 Proj↑", color = cUpper, linewidth = lineWidth)
plot(vProjLo(vProj1, onProj1), "1 Proj↓", color = cLower, linewidth = lineWidth)

// ── Range lines (continuous value; color = na cut) ──
cRange = isNew ? na : rangeCol
plot(showRange and valid ? mergeHi : na, "Range High", color = cRange, linewidth = rangeWidth)
plot(showRange and valid ? mergeLo : na, "Range Low",  color = cRange, linewidth = rangeWidth)

// ═══════════════════════════════════════════════════════════════════════════
// LABELS — current period only (optional)
// ═══════════════════════════════════════════════════════════════════════════
var array<label> labs = array.new<label>()

addLabel(float price, string txt, color c) =>
    if not na(price) and price > 0
        array.push(labs, label.new(bar_index, price, txt, style = label.style_label_left,
             color = color.new(c, 70), textcolor = chart.fg_color, size = size.small))

if showLabels and barstate.islast and valid
    for lb in labs
        label.delete(lb)
    array.clear(labs)
    retrF  = array.from(vRetr00, vRetr236, vRetr382, vRetr5, vRetr618, vRetr786, vRetr1)
    retrOn = array.from(onRetr00, onRetr236, onRetr382, onRetr5, onRetr618, onRetr786, onRetr1)
    projF  = array.from(vProj00, vProj236, vProj382, vProj5, vProj618, vProj786, vProj1)
    projOn = array.from(onProj00, onProj236, onProj382, onProj5, onProj618, onProj786, onProj1)
    if doRetr
        for i = 0 to array.size(retrF) - 1
            if array.get(retrOn, i)
                f   = array.get(retrF, i)
                txt = str.tostring(f)
                if showUpper
                    addLabel(mergeHi - f * H, txt, upperCol)
                if showLower
                    addLabel(mergeLo + f * H, txt, lowerCol)
    if doProj
        for i = 0 to array.size(projF) - 1
            if array.get(projOn, i)
                f   = array.get(projF, i)
                txt = str.tostring(f)
                if showUpper
                    addLabel(mergeHi + f * H, txt, upperCol)
                if showLower
                    addLabel(mergeLo - f * H, txt, lowerCol)

// ── Guard: invalid cadence ──
if barstate.islast and not validCad
    label.new(bar_index, high, "⚠ Cadence TF must be > chart TF",
         style = label.style_label_down, color = color.new(color.red, 0),
         textcolor = color.white, size = size.normal)
````
