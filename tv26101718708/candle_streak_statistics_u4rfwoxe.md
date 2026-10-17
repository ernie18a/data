# Candle Streak Statistics

- url: https://www.tradingview.com/script/u4RfwoxE-Candle-Streak-Statistics/
- type: indicator
- pine_id: PUB;4ea906fd02994ed6b9fcc3b3148d81d1
- version: 1.0

## Description

Candle Streak Statistics
What it does

This indicator counts every consecutive run of up-candles and down-candles in the chart's full history, then tells you how unusual the current run is compared to all the runs that came before it. Think of it as a "thermometer" that shows whether the market is in a perfectly normal streak or in territory it rarely visits.

Why it exists

I often ask myself: "Eight green candles in a row. Is that a lot?"

What you'll see

A compact stats table (position and size are configurable) showing, separately for up-streaks and down-streaks:

n:  how many completed streaks were observed
Current run: length of the streak in progress
Pct rank: where the current run sits in the historical distribution (0% = shorter than everything, 100% = longest ever)
P(+1 more): historical probability that a streak which reached the current length extended by at least one more bar
Mean, Stdev, Median: central-tendency stats
p75 / p90 / p95: upper-percentile streak lengths
Mode: most common streak length (usually 1)
Optionally, a floating label above the last candle draws a 10-segment █/░ bar  (the "thermometer" — for an at-a-glance read on rarity.)

How to read it

Pct rank ≥ 90% with low P(+1 more) → the current streak is in the rare-air zone and historically rarely extends further. Mean-reversion is statistically likely.
Pct rank mid-range with P(+1 more) ≥ 50% → nothing unusual; trend has room to continue.
Up vs. Down asymmetry → on equities, up-streaks typically have longer tails than down-streaks. Watching this gap shift can flag regime changes.
Design choices worth knowing

Doji handling: by default, exactly equal close == open bars are ignored (they don't break a streak). Adjustable via a tolerance input if you want to treat tiny-bodied candles the same way.
The live unfinished streak is excluded from the distribution by default. Including a still-in-progress run biases percentiles downward (it's censored data). A toggle lets you override.
Sample-size warning: if a direction has fewer than N completed streaks (default 20), its column gets a ⚠ marker. Don't trust statistics built on too little data.
Built on confirmed bars only. The distribution doesn't churn on every realtime tick.
Customization

Every visible element has a clearly labeled input: table position (9 anchor points), text size, all colors (text, neutral cell, up/down highlight, header), highlight transparency, and thermometer label colors. Defaults are tuned for light-themed charts.

Alerts

"Up streak ≥ p90": current up-run has entered the top 10% of history
"Down streak ≥ p90": current down-run has entered the top 10% of history
Best paired with

Any trend-following or stop-loss indicator. The combination of "my trailing stop says still hold" + "this streak is at p95 with a 15% continuation probability" is more informative than either signal alone. Use it as a sanity check on overextended moves.

Limitations

Streak-length distributions are roughly geometric. The mode is almost always 1, so I don't even know why I  put it there. Don't lean on it.
Small samples (intraday timeframes on short chart histories) produce noisy upper-percentile estimates. Watch the n column.
Continuation probability is purely historical; it makes no claim about regime stability going forward. Statistics describe the past.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gurple

//@version=6
// =============================================================================
// Candle Streak Statistics (v3 — Pine v6)
// -----------------------------------------------------------------------------
// Builds a full empirical distribution of consecutive up-candle and down-candle
// run lengths from all available history, then frames the CURRENT live streak
// inside that distribution. Decision-useful framing: percentile rank and
// conditional probability of continuation, not just central tendency.
//
// Definitions:
//   * Up candle:   close > open  (with optional doji tolerance epsilon)
//   * Down candle: close < open
//   * Doji:        |close - open| / close <= dojiEps  -> ignored, does NOT
//                                                       break the streak
//   * Streak:      maximal run of same-direction candles
//
// What it computes (per direction, separately):
//   - Mean, median, standard deviation, mode
//   - p75 / p90 / p95 percentiles (linear interpolation)
//   - Percentile rank of the current live streak
//   - P(streak >= N+1 | streak >= N) conditional continuation probability
//   - Sample count n
//
// Statistical honesty notes:
//   * The live (unfinished) streak is EXCLUDED from the distribution by
//     default. Including a truncated sample biases the percentiles
//     downward. Toggle `includeLive` to override.
//   * Streak-length distributions are roughly geometric. Mode is almost
//     always 1; treat it as a sanity check, not a signal. Median and the
//     upper percentiles (p90/p95) are what matter.
//   * Conditional continuation probability is the most actionable number
//     here: given you've already seen N in a row, how often historically
//     did the run extend to N+1?
//
// How to use it (with the VStop workflow):
//   * Current streak in upper percentiles (>=p90) + low continuation prob
//     -> mean-reversion risk dominates; tighten stop multiplier.
//   * Current streak mid-distribution + continuation prob >= 0.5
//     -> no statistical edge to fade; let VStop run.
// =============================================================================

indicator("Candle Streak Statistics", shorttitle="Streak Stats", overlay=false)

// ---- Inputs -----------------------------------------------------------------
gBehavior   = "Behavior"
dojiEps     = input.float(0.0, "Doji tolerance (fraction of close)",
  minval=0.0, step=0.0001, group=gBehavior,
  tooltip="Bars where |close-open|/close <= this are treated as dojis and ignored (do not break the streak). 0 = strict close==open only.")
includeLive = input.bool(false, "Include live unfinished streak in stats",
  group=gBehavior,
  tooltip="Off (default) is statistically correct: an in-progress run is censored data and biases percentiles downward.")
minSampleN  = input.int(20, "Minimum sample size to trust stats", minval=1,
  group=gBehavior,
  tooltip="If fewer than this many completed streaks exist for a direction, that column header shows ⚠ and the n value turns warning-colored.")
showThermo  = input.bool(true, "Show percentile-rank bar above last candle",
  group=gBehavior,
  tooltip="Visual bar shown above the last bar with the current streak's percentile rank (the 'thermometer').")

// ---- Display / Theme --------------------------------------------------------
// Every label below names the specific table region it controls so you can
// see exactly what each color affects without trial and error.
// Defaults are tuned for LIGHT charts (black text on light backgrounds).
gTheme        = "Display — Stats Table"
tablePosStr   = input.string("Top Right", "Stats table position on chart",
  options=["Top Left", "Top Center", "Top Right",
           "Middle Left", "Middle Center", "Middle Right",
           "Bottom Left", "Bottom Center", "Bottom Right"],
  group=gTheme,
  tooltip="Where the stats table is anchored. Change takes effect on the next bar update.")
tableSizeStr  = input.string("Normal", "Stats table text size",
  options=["Tiny", "Small", "Normal", "Large", "Huge"],
  group=gTheme,
  tooltip="Font size for every cell in the stats table.")
textColor     = input.color(color.black, "All table text color", group=gTheme,
  tooltip="Applies to every label and value in the stats table. Use white for dark charts.")
headerBg      = input.color(color.new(#d0d0d0, 0), "Table title cell background (top-left)",
  group=gTheme,
  tooltip="Background color of the top-left header cell that shows 'Streaks (timeframe)'.")
cellBg        = input.color(color.new(#f5f5f5, 0), "Neutral row background (Mean / Median / n / etc.)",
  group=gTheme,
  tooltip="Background for non-highlighted value cells: n, Mean, Stdev, Median, p75, p90, p95, Mode, P(+1 more).")
upTint        = input.color(color.new(#2e7d32, 0), "Up streak highlight color (Up column header, Up current-run cell, Up percentile-rank cell)",
  group=gTheme,
  tooltip="Used in three places: the 'Up' column header, the Current-run cell when an up streak is active, and the Up Pct-rank cell (intensity scales with rank).")
dnTint        = input.color(color.new(#c62828, 0), "Down streak highlight color (Down column header, Down current-run cell, Down percentile-rank cell)",
  group=gTheme,
  tooltip="Same regions as Up highlight, but for the Down column.")
bgTransp      = input.int(70, "Highlight transparency (0 = solid, 100 = invisible)",
  minval=0, maxval=100, group=gTheme,
  tooltip="Applies only to the Up/Down highlight backgrounds (column headers, current-run cells, percentile-rank cells). Higher = more see-through; the Pct-rank cell darkens automatically as rank climbs.")

gThermo       = "Display — Thermometer Label"
thermoBgCol   = input.color(color.new(#ffffff, 10), "Thermometer label background",
  group=gThermo,
  tooltip="Background of the floating label drawn above the last candle when 'Show percentile-rank bar' is enabled.")
thermoTextCol = input.color(color.black, "Thermometer label text color",
  group=gThermo,
  tooltip="Text color of the floating thermometer label above the last candle.")

// ---- Streak Accumulation (per bar) ------------------------------------------
var array<int> upStreaks   = array.new<int>()
var array<int> downStreaks = array.new<int>()
var int currentUp   = 0
var int currentDown = 0

bodyRatio = close == 0 ? 0.0 : math.abs(close - open) / close
isDoji = bodyRatio <= dojiEps
isUp   = not isDoji and close > open
isDown = not isDoji and close < open

// Only mutate accumulators on confirmed bars. Prevents the live bar from
// repeatedly pushing into the distribution every tick.
if barstate.isconfirmed
    if isUp
        if currentDown > 0
            array.push(downStreaks, currentDown)
            currentDown := 0
        currentUp := currentUp + 1
    else if isDown
        if currentUp > 0
            array.push(upStreaks, currentUp)
            currentUp := 0
        currentDown := currentDown + 1
    // doji: no-op, preserve running streak

// ---- Custom helpers (no v6 stdlib equivalent) -------------------------------

// Percentile rank of value v inside arr, returned as 0..100.
// Definition: fraction of samples not greater than v.
f_pct_rank(array<int> arr, int v) =>
    n = array.size(arr)
    if n == 0 or na(v) or v <= 0
        float(na)
    else
        int leq = 0
        for i = 0 to n - 1
            if array.get(arr, i) <= v
                leq += 1
        100.0 * leq / n

// P(streak >= n+1 | streak >= n).
f_cont_prob(array<int> arr, int n) =>
    if array.size(arr) == 0 or na(n) or n <= 0
        float(na)
    else
        int atLeastN     = 0
        int atLeastNplus = 0
        for i = 0 to array.size(arr) - 1
            v = array.get(arr, i)
            if v >= n
                atLeastN += 1
            if v >= n + 1
                atLeastNplus += 1
        atLeastN == 0 ? float(na) : 1.0 * atLeastNplus / atLeastN

// ---- Build a transient distribution snapshot (last bar only) ----------------
var float upMean     = na
var float upMedian   = na
var float upStdev    = na
var float upP75      = na
var float upP90      = na
var float upP95      = na
var float upRank     = na
var float upContProb = na
var int   upN        = 0
var int   upMode     = na

var float dnMean     = na
var float dnMedian   = na
var float dnStdev    = na
var float dnP75      = na
var float dnP90      = na
var float dnP95      = na
var float dnRank     = na
var float dnContProb = na
var int   dnN        = 0
var int   dnMode     = na

if barstate.islast
    upSnap = array.copy(upStreaks)
    dnSnap = array.copy(downStreaks)
    if includeLive
        if currentUp > 0
            array.push(upSnap, currentUp)
        if currentDown > 0
            array.push(dnSnap, currentDown)

    upN := array.size(upSnap)
    dnN := array.size(dnSnap)

    if upN > 0
        upMean   := array.avg(upSnap)
        upMedian := array.median(upSnap)
        upStdev  := upN > 1 ? array.stdev(upSnap) : na
        upP75    := array.percentile_linear_interpolation(upSnap, 75)
        upP90    := array.percentile_linear_interpolation(upSnap, 90)
        upP95    := array.percentile_linear_interpolation(upSnap, 95)
        upMode   := int(array.mode(upSnap))
        if currentUp > 0
            upRank     := f_pct_rank(upSnap, currentUp)
            upContProb := f_cont_prob(upSnap, currentUp)

    if dnN > 0
        dnMean   := array.avg(dnSnap)
        dnMedian := array.median(dnSnap)
        dnStdev  := dnN > 1 ? array.stdev(dnSnap) : na
        dnP75    := array.percentile_linear_interpolation(dnSnap, 75)
        dnP90    := array.percentile_linear_interpolation(dnSnap, 90)
        dnP95    := array.percentile_linear_interpolation(dnSnap, 95)
        dnMode   := int(array.mode(dnSnap))
        if currentDown > 0
            dnRank     := f_pct_rank(dnSnap, currentDown)
            dnContProb := f_cont_prob(dnSnap, currentDown)

// ---- Alerts -----------------------------------------------------------------
upAtP90 = not na(upRank) and upRank >= 90
dnAtP90 = not na(dnRank) and dnRank >= 90
alertcondition(upAtP90, title="Up streak >= p90",
  message="Up streak at or above 90th percentile of history")
alertcondition(dnAtP90, title="Down streak >= p90",
  message="Down streak at or above 90th percentile of history")

// ---- Display helpers --------------------------------------------------------

// Thermometer string: 10-segment bar filled by percentile rank.
f_thermo(float rank) =>
    if na(rank)
        "          "
    else
        filled = math.round(rank / 10.0)
        filled := math.max(0, math.min(10, filled))
        string result = ""
        for i = 0 to 9
            result += i < filled ? "█" : "░"
        result

// Color a percentile rank: intensity scales with rank. Uses user-chosen tint.
f_rank_color(float rank, bool upDirection) =>
    base = upDirection ? upTint : dnTint
    if na(rank)
        cellBg
    else if rank >= 95
        color.new(base, math.max(0, bgTransp - 40))
    else if rank >= 90
        color.new(base, math.max(0, bgTransp - 25))
    else if rank >= 75
        color.new(base, math.max(0, bgTransp - 10))
    else
        color.new(base, bgTransp)

f_fmt_i(int v)                  => na(v) ? "—" : str.tostring(v, "#")
f_fmt_f(float v, string fmt)    => na(v) ? "—" : str.tostring(v, fmt)
f_fmt_pct(float v)              => na(v) ? "—" : str.tostring(v, "#.#") + "%"
f_fmt_prob(float p)             => na(p) ? "—" : str.tostring(p * 100, "#.#") + "%"

// ---- Status Table -----------------------------------------------------------
// Resolve user-friendly strings into Pine constants.
tablePos = switch tablePosStr
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    =>                  position.top_right

tableSize = switch tableSizeStr
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    =>          size.normal

var table tbl = table.new(tablePos, 3, 12, border_width = 1)

if barstate.islast
    upHeaderBg  = color.new(upTint, math.max(0, bgTransp - 30))
    dnHeaderBg  = color.new(dnTint, math.max(0, bgTransp - 30))
    upRunBg     = color.new(upTint, bgTransp)
    dnRunBg     = color.new(dnTint, bgTransp)
    warnColor   = color.orange

    upWarn = upN < minSampleN
    dnWarn = dnN < minSampleN

    // Row 0: Header
    table.cell(tbl, 0, 0, "Streaks (" + timeframe.period + ")",
      bgcolor=headerBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 0, "Up" + (upWarn ? " ⚠" : ""),
      bgcolor=upHeaderBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 0, "Down" + (dnWarn ? " ⚠" : ""),
      bgcolor=dnHeaderBg, text_color=textColor, text_size=tableSize)

    // Row 1: Sample size
    table.cell(tbl, 0, 1, "n", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 1, str.tostring(upN), bgcolor=cellBg,
      text_color=upWarn ? warnColor : textColor, text_size=tableSize)
    table.cell(tbl, 2, 1, str.tostring(dnN), bgcolor=cellBg,
      text_color=dnWarn ? warnColor : textColor, text_size=tableSize)

    // Row 2: Current run
    table.cell(tbl, 0, 2, "Current run", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 2, str.tostring(currentUp),
      bgcolor=currentUp > 0 ? upRunBg : cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 2, str.tostring(currentDown),
      bgcolor=currentDown > 0 ? dnRunBg : cellBg, text_color=textColor, text_size=tableSize)

    // Row 3: Percentile rank
    table.cell(tbl, 0, 3, "Pct rank", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 3, f_fmt_pct(upRank),
      bgcolor=f_rank_color(upRank, true), text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 3, f_fmt_pct(dnRank),
      bgcolor=f_rank_color(dnRank, false), text_color=textColor, text_size=tableSize)

    // Row 4: Continuation probability
    table.cell(tbl, 0, 4, "P(+1 more)", bgcolor=cellBg, text_color=textColor, text_size=tableSize,
      tooltip="Historical probability that a streak which reached the current length extended by at least one more bar.")
    table.cell(tbl, 1, 4, f_fmt_prob(upContProb), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 4, f_fmt_prob(dnContProb), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

    // Row 5: Mean
    table.cell(tbl, 0, 5, "Mean", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 5, f_fmt_f(upMean, "#.##"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 5, f_fmt_f(dnMean, "#.##"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

    // Row 6: Stdev
    table.cell(tbl, 0, 6, "Stdev", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 6, f_fmt_f(upStdev, "#.##"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 6, f_fmt_f(dnStdev, "#.##"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

    // Row 7: Median
    table.cell(tbl, 0, 7, "Median", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 7, f_fmt_f(upMedian, "#.##"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 7, f_fmt_f(dnMedian, "#.##"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

    // Row 8-10: Percentiles
    table.cell(tbl, 0, 8, "p75", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 8, f_fmt_f(upP75, "#.#"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 8, f_fmt_f(dnP75, "#.#"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

    table.cell(tbl, 0, 9, "p90", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 9, f_fmt_f(upP90, "#.#"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 9, f_fmt_f(dnP90, "#.#"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

    table.cell(tbl, 0, 10, "p95", bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 1, 10, f_fmt_f(upP95, "#.#"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 10, f_fmt_f(dnP95, "#.#"), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

    // Row 11: Mode
    table.cell(tbl, 0, 11, "Mode", bgcolor=cellBg, text_color=textColor, text_size=tableSize,
      tooltip="Most common streak length. Geometric-ish distribution means this is usually 1.")
    table.cell(tbl, 1, 11, f_fmt_i(upMode), bgcolor=cellBg, text_color=textColor, text_size=tableSize)
    table.cell(tbl, 2, 11, f_fmt_i(dnMode), bgcolor=cellBg, text_color=textColor, text_size=tableSize)

// ---- Thermometer label above the last bar -----------------------------------
var label thermoLbl = na
if showThermo and barstate.islast
    upBar = f_thermo(upRank)
    dnBar = f_thermo(dnRank)
    txt = "Up   " + upBar + "  " + f_fmt_pct(upRank) + "\n" +
          "Down " + dnBar + "  " + f_fmt_pct(dnRank)
    label.delete(thermoLbl)
    thermoLbl := label.new(bar_index, high, text=txt,
      style=label.style_label_left,
      color=thermoBgCol,
      textcolor=thermoTextCol,
      yloc=yloc.abovebar,
      size=size.small)
````
