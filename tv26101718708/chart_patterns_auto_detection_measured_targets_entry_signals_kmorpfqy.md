# Chart Patterns  Auto Detection, Measured Targets & Entry Signals

- url: https://www.tradingview.com/script/kMOrpfQy-Chart-Patterns-Auto-Detection-Measured-Targets-Entry-Signals/
- type: indicator
- pine_id: PUB;b6bcf1aa069b4296b1ef3adbed753ab8
- version: 1.0

## Description

CHART PATTERNS — AUTO DETECTION, MEASURED TARGETS & ENTRY SIGNALS

OVERVIEW

Chart patterns are the oldest idea in technical analysis and the least tested. "Head and shoulders works." "The measured move is the target." Everyone repeats it. Nobody checks.

This tool detects seventeen classical patterns using a published, peer-reviewed algorithm — and then forward-tests every one of them separately, on your instrument, and tells you which ones actually carry an edge and which do not.

The panel ends up saying things like:

    Double bottom          +0.31R   n=44   PROVEN
    Head & shoulders       -0.08R   n=19   (not proven)
    Symmetric triangle     -0.15R   n=13   (thin)

That table does not exist anywhere else. It is the entire point of this script.

It is a research and framing tool. It is not a strategy, not a signal service, and not a validated edge.


THE ENGINE (Lo, Mamaysky & Wang, Journal of Finance, 2000)

The problem with pattern detection is stated best by the authors themselves: the presence of geometric shapes in price charts is often in the eyes of the beholder. Their solution, and the one used here:

1. Smooth the price with nonparametric kernel regression (Nadaraya-Watson, Gaussian kernel). This is the crucial step. Raw pivots are noise; the smoothed series is the shape. Every other pattern script hunts pivots on raw price and then argues about the pivot length.
2. Take the local extrema of the smoothed series.
3. Define each pattern as inequality conditions on five consecutive extrema.

Every tolerance is ATR-normalised so the same rule travels across instruments and timeframes. The original paper used fixed percentages tuned to US equities.


THE TAXONOMY IS A PARTITION, NOT A PILE OF RULES

The peaks and the troughs are each classified FLAT / RISING / FALLING — three states, mutually exclusive and exhaustive — and the resulting 3x3 grid names every shape exactly once.

                     troughs FLAT        troughs RISING       troughs FALLING
  peaks FLAT         Rectangle *         Ascending triangle   R-A broadening, desc *
                     (or Triple top)
  peaks RISING       R-A broadening,     Rising wedge /       Broadening formation *
                     asc *               Asc broadening wedge
  peaks FALLING      Descending          Symmetric triangle * Falling wedge /
                     triangle                                 Desc broadening wedge

  * = bilateral (no directional claim)

Convergence versus divergence splits the two same-slope cells. Head-and-shoulders and double tops/bottoms sit outside the grid — they are defined by the EQUALITY of specific extrema, not by the slope of the envelope — so they are tested separately.

This matters more than it sounds. A pile of independent rules leaks. Three level peaks with FALLING troughs is a right-angled descending broadening formation; with no rule to catch it, the shape drops through to the nearest match and gets logged as a TRIPLE TOP, quietly poisoning that pattern's statistics with a different pattern. Bulkowski's own identification quiz for the right-angled broadening formation opens by warning the reader that they may think they are looking at a triple top. Meanwhile a shape with higher highs AND higher lows that is WIDENING matched nothing at all and was thrown away. Both are now named. The grid is the reason the numbers in the panel mean what they say.


DIRECTIONAL VERSUS BILATERAL — WHY FIVE PATTERNS HAVE NO DIRECTION

A head-and-shoulders makes a claim: it breaks down. A symmetric triangle makes no such claim. Nobody, including Bulkowski, says which way it goes; he publishes statistics for BOTH breakout directions.

So a bilateral pattern arms BOTH boundaries and lets price pick the side. The five are: symmetric triangle, rectangle, broadening formation, and the two right-angled broadening formations. They are drawn in amber, and the trigger logic agrees with the paint.

This is not a cosmetic point. Splitting a symmetric triangle into a "triangle top" and a "triangle bottom" — where the only difference is whether the first extremum happened to be a high or a low — and then trading one short and the other long, is trading a phase accident of where the extremum series began. It is not a forecast, and it halves the sample size for nothing.


THE BOUNDARIES ARE TRENDLINES, NOT HORIZONTAL LINES

A triangle's boundary slopes. Testing a break against a horizontal line drawn at the last extremum is a different test — and it is wrong in a DIFFERENT DIRECTION for different patterns. A converging boundary sits below its last extremum, so a horizontal proxy triggers late. A diverging one sits above it, so the proxy triggers early, on breaks that never happened.

Since the entire purpose of this script is to COMPARE patterns against each other, a bias that flips sign depending on which pattern you are looking at is fatal. Every boundary here carries a slope, is projected to the current bar, and the measured move is projected from the boundary AT THE BAR IT BROKE — which is what the textbook actually says.


THE TWO THINGS IT MEASURES (they are different questions, and both are reported)

A. TRADABILITY. From the trigger bar, with identical geometry for every pattern and for the control, what is the expectancy in R? This is the question "does this pattern predict a favourable move?" It is compared against an unconditional, direction-matched control.

B. THE MEASURED MOVE — and, crucially, HOW FAR AWAY IT IS. Does the classical projected target actually get reached before the pattern's own stop? This is the number every pattern trader assumes and nobody has checked. It is a descriptive statistic, clearly labelled as such, with no control.

Mixing these two makes both meaningless, so they are kept apart. The trade uses a fixed R multiple so that every pattern — and the control — is measured on identical geometry. The measured move is drawn and tested separately.


A HIT RATE WITHOUT A DISTANCE IS NOT A FACT ABOUT THE PATTERN

The panel reports the measured-move hit rate NEXT TO the measured move's distance in R, because the first number is uninterpretable without the second.

On NIFTY futures, live:

    Double bottom       MM sits 0.6R away   reached 73% of the time
    Symmetric triangle  MM sits 5.7R away   reached  0% of the time

Those two rows say the SAME thing. A projection sitting half a unit of risk away being reached three times in four is not evidence that double bottoms work; a projection sitting nearly six units of risk away being reached never is not evidence that symmetric triangles fail. Report the hit rate alone and a reader will draw exactly the wrong conclusion from both.

It also explains a result that looks paradoxical at first: a double bottom can reach its textbook target 73% of the time and still LOSE money, because that target is worth about 0.6R and the trade is being held for 2R. The measured move being reached and the trade being profitable are different events. Almost nobody separates them. This script does.


HOW TO USE

1. A pattern is DETECTED when its fifth extremum confirms. It is not a trade yet.
2. It becomes a TRADE only when price TRIGGERS it: a boundary breaks. The engine never front-runs the pattern.
3. Read the per-pattern calibration BEFORE you weight any of it. A pattern with no proven edge on this instrument is a shape, not a probability.
4. Entry, stop, target and the R multiple are drawn. They are arithmetic, not advice.

BANDWIDTH is the one input that matters. Small = many small patterns; large = few large ones. There is no correct value. There is only the one whose patterns the calibration says work.


NON-REPAINT, AND THE HONEST COST OF IT

A centred kernel looks into the future. Lo, Mamaysky and Wang could use one because they were studying history. We cannot. So the smoother is evaluated only where the whole window already exists, which means an extremum is confirmed roughly one half-window AFTER it occurred, and a pattern therefore prints with that lag.

That lag is the price of not repainting, and it is paid deliberately. Any pattern tool that marks a head-and-shoulders the instant the head forms is either repainting or using a shorter window than it admits.

Everything — extrema, patterns, triggers, calibration — is computed on confirmed bars only.


WHAT IS DELIBERATELY ABSENT

FLAGS AND PENNANTS cannot be detected by this engine and are not faked. Their defining feature is a small consolidation after a sharp pole. Bulkowski puts a flag at a few days to three weeks and calls anything longer a rectangle. But the kernel smoother and the ATR prominence filter exist precisely to destroy small wiggles, and a flag's entire body is often under one ATR. To find flags you need pole detection and channel regression on raw price: a different engine. A pennant, in any case, IS a symmetric triangle that happens to follow a pole.

ELLIOTT WAVE is absent because it is not objectively definable. The wave count is degree-dependent and non-unique. Encoding it would test the encoding, not the theory, and reporting "no edge" against a definition its own proponents would disown is a strawman. This script attacks folklore by testing it fairly, or it does not attack it at all.


WHY THESE PARTS ARE ONE TOOL

A pattern without a smoother is a subjective drawing. A smoother without pattern rules is just a moving average. Rules without a measured target give you nothing to trade. A target without an entry, a stop and an R multiple is not a trade. And all of it, without a per-pattern calibration, is exactly the folklore this script was built to test. Remove any one piece and you have another pattern-drawing tool that asserts an edge it has never measured.


DATA AND SCOPE

Any symbol, any timeframe. ATR-normalised throughout. No volume required.


EXPORTS (Data Window — consume from other scripts via input.source())

EXP_Smooth, EXP_Pattern, EXP_Dir, EXP_Trigger, EXP_Entry, EXP_Stop, EXP_Target, EXP_RR, EXP_PatternEdge, EXP_TargetHitRate


CONCEPT CREDIT

The kernel-regression pattern-recognition algorithm and the core pattern definitions are from Andrew W. Lo, Harry Mamaysky and Jiang Wang, "Foundations of Technical Analysis: Computational Algorithms, Statistical Inference, and Empirical Implementation", Journal of Finance 55(4), 2000. The Nadaraya-Watson estimator is due to E. A. Nadaraya and G. S. Watson (1964). The patterns themselves long predate all of us; the modern written tradition runs through Edwards & Magee. The right-angled broadening formations, the broadening wedges, the ascending and descending triangles and the triple tops and bottoms are documented in Thomas Bulkowski, "Encyclopedia of Chart Patterns"; his published success rates are claims measured on US daily stocks, and testing them on YOUR instrument is the purpose of this tool. ATR — J. Welles Wilder. Triple-barrier forward labelling — Marcos Lopez de Prado. Welch's t-test — B. L. Welch.

The exhaustive peak/trough partition, the bilateral trigger, the sloping-boundary trigger, the per-pattern calibration, the measured-move test and the direction-matched control are the author's own. Clean-room implementation; no third-party Pine code is reused. Not affiliated with, nor endorsed by, any of the above.


HONESTY AND LIMITATIONS

Lo, Mamaysky and Wang's own conclusion deserves to be read before anyone trades this: several patterns DO carry incremental information, but patterns that are optimal for detecting statistical anomalies need not be optimal for indicating trading profits, and vice versa. A pattern can be statistically real and still not pay after costs.

Calibration here is IN-SAMPLE, with no costs or slippage, and uses overlapping windows. A proven in-sample edge is NOT a guarantee out-of-sample.

Pattern counts are small by nature. A rare pattern may never reach a usable sample size, and the panel will keep saying so — "thin", "warming" — rather than pretend. Nothing is marked PROVEN below t = 1.96 against the control, and nothing is rated at all below the minimum sample.

Entry is the CLOSE of the trigger bar, for the pattern and for the control alike. Entering at the boundary — a better price — while the control enters at the close would hand every pattern a free head start and manufacture an edge out of nothing.

When both barriers are touched on the same bar, the stop is assumed first. Unresolved trades at the horizon are marked to market rather than counted as wins.

A different bandwidth gives different patterns. If a pattern shows no edge, the honest conclusion is that it has none here. Nothing in this script predicts price.


DISCLAIMER

Research and educational tool only. Not financial advice, not a recommendation, and no guarantee of results. Entry, stop and target output is arithmetic, not advice. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// CHART PATTERNS — AUTO DETECTION, MEASURED TARGETS & ENTRY SIGNALS                          v1.4
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   Chart patterns are the oldest idea in technical analysis and the least tested. "Head and
//   shoulders works." "The measured move is the target." Everyone repeats it. Nobody checks.
//
//   This tool detects SEVENTEEN classical patterns with a published, peer-reviewed algorithm — and then
//   FORWARD-TESTS EVERY ONE OF THEM SEPARATELY, on your instrument, and tells you which ones
//   actually carry an edge and which do not.
//
//   The panel ends up saying things like:
//        Double bottom     +0.31R   n=44   t=2.31   PROVEN
//        Head & shoulders  -0.08R   n=19   t=-0.71  NO EDGE
//   That table does not exist anywhere else. It is the entire point of this script.
//
//   It is a research and framing tool — NOT a strategy, NOT a signal service, NOT a validated edge.
//
// THE ENGINE  (Lo, Mamaysky & Wang, Journal of Finance, 2000)
//   The problem with pattern detection is stated best by the authors themselves: the presence of
//   geometric shapes in price charts is "often in the eyes of the beholder". Their solution, and the
//   one used here:
//     1. SMOOTH the price with NONPARAMETRIC KERNEL REGRESSION (Nadaraya-Watson, Gaussian kernel).
//        This is the crucial step. Raw pivots are noise; the smoothed series is the SHAPE. Every
//        other pattern script hunts pivots on raw price and then argues about the pivot length.
//     2. Take the LOCAL EXTREMA of the SMOOTHED series.
//     3. Define each pattern as INEQUALITY CONDITIONS ON FIVE CONSECUTIVE EXTREMA (E1..E5).
//   Every tolerance is ATR-normalised so it travels across instruments (the paper used fixed
//   percentages tuned to US equities).
//
// THE TAXONOMY IS A PARTITION, NOT A PILE OF RULES
//   The peaks and the troughs are each classified FLAT / RISING / FALLING — three states, exclusive
//   and exhaustive — and the resulting 3×3 grid names every shape EXACTLY ONCE. This matters more
//   than it sounds. A pile of independent rules leaks: three level peaks with FALLING troughs is a
//   right-angled descending broadening formation, and with no such rule to catch it the shape drops
//   through to the nearest match and gets logged as a TRIPLE TOP — quietly poisoning that pattern's
//   statistics with a different pattern. (Bulkowski's own quiz for the right-angled broadening
//   formation opens by warning the reader they may think they are looking at a triple top.) A shape
//   with higher highs AND higher lows that was WIDENING matched nothing at all and was thrown away.
//   Both are now named. The grid is the reason the numbers in the panel mean what they say.
//
// DIRECTIONAL vs BILATERAL  (and why five patterns have no direction)
//   A head-and-shoulders makes a claim: it breaks DOWN. A symmetric triangle makes no such claim —
//   nobody, including Bulkowski, says which way it goes; he publishes statistics for BOTH breakout
//   directions. So a bilateral pattern arms BOTH boundaries and lets PRICE pick the side. The five:
//   symmetric triangle, rectangle, broadening formation, and the two right-angled broadening
//   formations. They are drawn in AMBER, and the trigger logic now agrees with the paint.
//
// WHY THESE PARTS ARE ONE TOOL  (mashup rationale)
//   A pattern without a smoother is a subjective drawing. A smoother without pattern rules is just a
//   moving average. Rules without a measured target give you nothing to trade. A target without an
//   entry, a stop and an R:R is not a trade. And ALL of it, without a per-pattern calibration, is
//   exactly the folklore this script was built to test. Remove any one piece and you have another
//   pattern-drawing tool that asserts an edge it has never measured.
//
// THE TWO THINGS IT MEASURES  (they are different questions, and both are reported)
//   A. TRADABILITY — from the trigger bar, with identical geometry for every pattern and for the
//      control, what is the EXPECTANCY IN R? This is the question "does this pattern predict a
//      favourable move?" It is compared against an unconditional, direction-matched control.
//   B. THE MEASURED MOVE — does the classical projected target actually get REACHED before the
//      pattern's own stop? This is the number every pattern trader assumes and nobody has checked.
//      It is a descriptive statistic, clearly labelled as such, with no control.
//
// HOW TO USE
//   1. A pattern is DETECTED when its fifth extremum confirms — but it is not a trade yet.
//   2. It becomes a TRADE only when price TRIGGERS it: the neckline or boundary breaks. The engine
//      never front-runs the pattern.
//   3. Read the per-pattern calibration BEFORE you weight any of it. A pattern with no proven edge
//      on this instrument is a SHAPE, not a probability.
//   4. Entry / stop / target and the R:R are drawn. They are arithmetic, not advice.
//
// THE BOUNDARIES ARE TRENDLINES, NOT HORIZONTAL LINES
//   A triangle's boundary SLOPES. Testing the break against a horizontal line drawn at the last
//   extremum is a different test — and it is wrong in a DIFFERENT DIRECTION for different patterns.
//   A converging boundary sits BELOW its last extremum, so a horizontal proxy triggers LATE. A
//   diverging one sits ABOVE it, so the proxy triggers EARLY, on breaks that never happened. Since
//   the entire purpose of this script is to COMPARE patterns against each other, a bias that flips
//   sign depending on which pattern you are looking at is fatal. Every boundary here carries a slope,
//   is projected to the current bar, and the measured move is projected from the boundary AT THE BAR
//   IT BROKE — which is what the textbook actually says.
//
// DATA / SCOPE
//   Any symbol, any timeframe. ATR-normalised throughout. No volume required.
//   BANDWIDTH is the one input that matters: small = many small patterns, large = few large ones.
//
// NON-REPAINT  (and the honest cost of it)
//   A CENTRED kernel looks into the future. Lo, Mamaysky and Wang could use one because they were
//   studying history. WE CANNOT. So the smoother is evaluated only where the whole window already
//   exists, which means an extremum is confirmed roughly one half-window AFTER it occurred, and a
//   pattern therefore prints with that lag. THAT LAG IS THE PRICE OF NOT REPAINTING, and it is paid
//   deliberately. Any pattern tool that marks a head-and-shoulders the instant the head forms is
//   either repainting or using a shorter window than it admits.
//   Everything — extrema, patterns, triggers, calibration — is computed on CONFIRMED bars only.
//
// WHAT IS DELIBERATELY ABSENT
//   FLAGS AND PENNANTS cannot be detected by this engine and are not faked. Their defining feature
//   is a SMALL consolidation after a sharp pole — Bulkowski puts a flag at a few days to three weeks
//   and calls anything longer a rectangle. But the kernel smoother plus the ATR prominence filter
//   exist precisely to destroy small wiggles, and a flag's entire body is often under one ATR. To
//   find flags you need pole detection and channel regression on RAW price: a different engine. A
//   pennant, in any case, IS a symmetric triangle that happens to follow a pole.
//   ELLIOTT WAVE is absent because it is not objectively definable — the wave count is degree-
//   dependent and non-unique. Encoding it would test the ENCODING, not the theory, and reporting
//   "no edge" against a definition its own proponents would disown is a strawman. This script
//   attacks folklore by testing it fairly, or it does not attack it at all.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Smooth · EXP_Pattern · EXP_Dir · EXP_Trigger · EXP_Entry · EXP_Stop · EXP_Target ·
//   EXP_RR · EXP_PatternEdge · EXP_TargetHitRate · EXP_TargetDistR
//
// CONCEPT CREDIT
//   The kernel-regression pattern-recognition algorithm and the ten pattern definitions are from
//   Andrew W. Lo, Harry Mamaysky and Jiang Wang, "Foundations of Technical Analysis: Computational
//   Algorithms, Statistical Inference, and Empirical Implementation", Journal of Finance 55(4),
//   2000. The Nadaraya-Watson estimator is due to E. A. Nadaraya and G. S. Watson (1964). The
//   patterns themselves long predate all of us; the modern written tradition runs through Edwards &
//   Magee. The right-angled broadening formations, the broadening wedges, the ascending/descending
//   triangles and the triple tops/bottoms are documented in Thomas Bulkowski, "Encyclopedia of Chart
//   Patterns" — his published success rates are claims measured on US daily stocks, and testing them
//   on YOUR instrument is the entire purpose of this tool. ATR — J. Welles Wilder. Triple-barrier forward labelling — Marcos López de Prado.
//   Welch's t-test — B. L. Welch. The per-pattern calibration, the measured-move test, the
//   direction-matched control and the trigger engine are the author's own. Clean-room
//   implementation; no third-party Pine code is reused. Not affiliated with, nor endorsed by, any
//   of the above.
//
// HONESTY / LIMITATIONS
//   Lo, Mamaysky and Wang's own conclusion deserves to be quoted before anyone trades this: several
//   patterns DO carry incremental information — but "patterns that are optimal for detecting
//   statistical anomalies need not be optimal for indicating trading profits, and vice versa." A
//   pattern can be statistically real and still not pay after costs.
//   Calibration here is IN-SAMPLE, with no costs or slippage, and uses overlapping windows; a proven
//   in-sample edge is NOT a guarantee out-of-sample. Pattern counts are small by nature — a rare
//   pattern may never reach a usable sample size, and the panel will keep saying so rather than
//   pretend. A different bandwidth gives different patterns. If a pattern shows no edge, the honest
//   conclusion is that it has none here. Nothing in this script predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee
//   of results. Entry/stop/target output is arithmetic, not advice. Trading carries risk of loss.
//   Test out-of-sample and make your own decisions. The author accepts no liability for any use.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Chart Patterns — Auto Detection, Measured Targets & Entry Signals", "Patterns",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500,
     max_bars_back = 3000)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g1 = "01 · The kernel smoother (Lo-Mamaysky-Wang)"
g2 = "02 · Pattern rules"
g3 = "03 · Which patterns"
g4 = "04 · The trade"
g5 = "05 · Calibration (which patterns actually work?)"
g6 = "06 · Drawing"
g7 = "07 · Dashboard & theme"

kW       = input.int(12, "Half-window (bars)", minval = 4, maxval = 100, group = g1, tooltip = "The smoother looks kW bars either side of a point. An extremum is therefore confirmed kW bars AFTER it happened — that lag is the honest cost of not repainting. Larger = smoother, slower, bigger patterns.")
kH       = input.float(5.0, "Bandwidth h", minval = 1.0, maxval = 50.0, step = 0.5, group = g1, tooltip = "THE most important input. It sets how much the price is smoothed, and therefore what counts as a 'shape'. Small h = many small patterns; large h = few large ones. There is no correct value — there is only the one whose patterns the calibration says work.")
kSrc     = input.source(close, "Source", group = g1)

tolA     = input.float(0.6, "Equality tolerance (×ATR)", minval = 0.05, maxval = 4.0, step = 0.05, group = g2, tooltip = "How close two extrema must be to count as 'equal' — the shoulders of a head-and-shoulders, the two tops of a double top. Lo-Mamaysky-Wang used a fixed 1.5% (tuned to US equities); ATR-normalising it lets the same rule travel across instruments and timeframes.")
tolR     = input.float(0.35, "Rectangle tolerance (×ATR)", minval = 0.05, maxval = 3.0, step = 0.05, group = g2, tooltip = "Tighter than the general tolerance — a rectangle needs genuinely flat edges. LMW used 0.75%.")
minSep   = input.int(10, "Min bars between the two tops/bottoms", minval = 2, maxval = 200, group = g2, tooltip = "A double top formed over three bars is not a double top.")
dedupeBars= input.int(30, "Dedupe window (bars)", minval = 1, maxval = 300, group = g2, tooltip = "As new extrema arrive, the SAME shape can satisfy the rules on consecutive bars and be detected twice — which is why identical labels were stacking on the chart. A pattern of the same type, at the same level, within this window is treated as the same pattern.")
maxSpan  = input.int(300, "Max pattern span (bars)", minval = 30, maxval = 1000, group = g2)
armBars  = input.int(60, "Bars a pattern stays armed", minval = 5, maxval = 500, group = g2, tooltip = "A pattern that never breaks is not a pattern that is still waiting — it is a pattern that FAILED to break, and its boundaries have long since stopped meaning anything. After this many bars it is retired. Without this, a sloping boundary is extrapolated forever and eventually triggers on a level that has no relationship to the shape that produced it.")
minProm  = input.float(0.5, "Min extremum prominence (×ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = g2, tooltip = "AN EXTREMUM MUST MEAN SOMETHING. In a FLAT stretch the smoother still wiggles by a few ticks, and every one of those wiggles registers as a local max or min. They then fill the five-extremum window with noise and the real shape is never seen. Requiring each extremum to differ from the last by at least this much removes them. On a synthetic head-and-shoulders this cut 23 detected extrema down to the 6 that were actually there.")

// ── DIRECTIONAL patterns: the classical claim names the breakout direction. ──
usHS     = input.bool(true, "Head & shoulders  ·  inverse", group = g3)
usDBL    = input.bool(true, "Double top  ·  double bottom", group = g3)
usTRIP   = input.bool(true, "Triple top  ·  triple bottom", group = g3, tooltip = "Three equal extremes whose opposing swings are neither flat (that is a rectangle), nor sloping one way (an ascending/descending triangle), nor sloping the other (a right-angled broadening formation).")
usASC    = input.bool(true, "Ascending  ·  descending triangle", group = g3, tooltip = "Flat resistance with rising lows (ascending), or flat support with falling highs (descending). Bulkowski documents a directional bias for each; the calibration is what decides whether it pays HERE.")
usWDG    = input.bool(true, "Rising  ·  falling wedge", group = g3, tooltip = "Both boundaries slope the same way and CONVERGE. Rising = bearish, falling = bullish.")
usBWDG   = input.bool(true, "Ascending  ·  descending broadening wedge", group = g3, tooltip = "Both boundaries slope the same way but DIVERGE. Before this existed, a shape with higher highs AND higher lows that was widening matched NOTHING — it fell straight through the taxonomy. Ascending = bearish, descending = bullish.")

// ── BILATERAL patterns: no classical direction. Price picks the side; we do not. ──
usTRI    = input.bool(true, "Symmetric triangle", group = g3, tooltip = "BILATERAL. Converging, with no directional claim. It used to be split into 'triangle top' and 'triangle bottom' — which meant nothing more than whether the first extremum happened to be a high or a low — and then traded SHORT or LONG on that accident. It is now one pattern, triggered by whichever boundary actually breaks.")
usRECT   = input.bool(true, "Rectangle", group = g3, tooltip = "BILATERAL. Flat top, flat bottom, no directional claim.")
usBRD    = input.bool(true, "Broadening formation", group = g3, tooltip = "BILATERAL. Higher highs AND lower lows — diverging. Bulkowski publishes BOTH breakout directions for it.")
usRABF   = input.bool(true, "Right-angled broadening (asc · desc)", group = g3, tooltip = "BILATERAL. One flat boundary, one diverging. Flat bottom with rising highs (ascending, breaks up ~55%); flat top with falling lows (descending, breaks up ~64%). Bulkowski warns these are routinely MISREAD as triple tops/bottoms — and before this existed, that is exactly what this script did with them.")

stopBufA = input.float(0.5, "Stop buffer (×ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = g4)
tgtR     = input.float(2.0, "Trade target (R multiple)", minval = 0.5, maxval = 10.0, step = 0.5, group = g4, tooltip = "The TRADE uses a fixed R multiple so that every pattern — and the control — is measured on IDENTICAL geometry. The classical MEASURED MOVE is drawn and tested separately, because those are two different questions and mixing them makes both meaningless.")
showMM   = input.bool(true, "Draw the classical measured move", group = g4, tooltip = "The projection every textbook gives: neckline minus the head's height, and so on. Drawn as a dotted arrow off the pattern — BOTH ways for a bilateral pattern, because it can go either way. It is drawn AND tested: the hit rate in the Pro panel says how often it has actually been REACHED.")

calibOn  = input.bool(true, "Forward-test every pattern", group = g5, tooltip = "Each pattern type gets its OWN bucket, its own expectancy, and its own significance test — against an unconditional, direction-matched control. This is the reason the script exists.")
calHor   = input.int(60, "Grading horizon (bars)", minval = 5, maxval = 400, group = g5)
calMinN  = input.int(30, "Min sample before rating", minval = 5, maxval = 200, group = g5, tooltip = "Patterns are RARE. A sample of 12 is small; the panel will keep saying 'warming' rather than pretend, and you should treat any rating below ~30 as provisional.")
ctlEvery = input.int(25, "Control sample every N bars", minval = 3, maxval = 300, group = g5, tooltip = "The yardstick: the SAME trade geometry taken on arbitrary bars, one long and one short. If a pattern cannot beat this, it carries no edge.")

showSm   = input.bool(false, "Draw the smoothed price", group = g6, tooltip = "The kernel-smoothed series the patterns are actually found on. Useful for understanding the bandwidth; noisy on a clean chart. Off by default.")
showStats= input.bool(false, "Print the pattern's record on the chart", group = g6, tooltip = "The pattern's own expectancy, sample size and measured-move hit rate, printed next to it. Powerful, but it is a lot of text. The dashboard carries the same numbers, so this is off by default and the chart stays clean.")
showPat  = input.bool(true, "Draw the pattern skeleton", group = g6)
showSetup= input.bool(true, "Draw entry / stop / target", group = g6)
keepPat  = input.int(20, "Patterns kept on chart", minval = 1, maxval = 40, group = g6, tooltip = "Every detected pattern stays drawn — shape, boundaries and all — until it is pushed out by this limit.")
lineW    = input.int(2, "Line width", minval = 1, maxval = 6, group = g6)
gC       = "06b · Pattern colours (one per family)"
cHS      = input.color(#e91e63, "Head & shoulders  ·  inverse", group = gC)
cBroad   = input.color(#ff9800, "Broadening  ·  right-angled broadening", group = gC)
cTri     = input.color(#2196f3, "Triangles (asc · desc · symmetric)", group = gC)
cRect    = input.color(#9c27b0, "Rectangle",                   group = gC)
cDbl     = input.color(#ffc107, "Double  ·  triple top / bottom", group = gC)
cWedge   = input.color(#00bcd4, "Wedges (converging & broadening)", group = gC)
showShape= input.bool(true, "DRAW THE PATTERN SHAPE", group = gC, tooltip = "Connect the extrema the detector actually used, so you can SEE the head-and-shoulders instead of taking its word for it. This is the whole point of a pattern tool and almost none of them do it.")
shapeW   = input.int(2, "Shape line width", minval = 1, maxval = 6, group = gC)
showMode = input.string("Latest only", "Show which patterns", options = ["Latest only", "Untriggered only", "All"], group = gC, tooltip = "LATEST ONLY keeps the chart readable — old patterns leave behind necklines and labels that stack up at the right edge and tell you nothing you can act on. Their statistics are still counted; they simply stop being drawn.")
fillMode = input.string("By direction", "Colour the fill", options = ["By direction", "By pattern family"], group = gC, tooltip = "BY DIRECTION: green = bullish, red = bearish, AMBER = bilateral. Symmetric triangles, rectangles and broadening formations genuinely break either way, so colouring them green or red would be a lie told in paint.")
cNeut    = input.color(#ffb300, "Bilateral (breaks either way)", group = gC)
showBody = input.bool(true, "FILL THE PATTERN BODY", group = gC, tooltip = "Draw the two boundary trendlines and shade between them, so the pattern reads as a SHAPE rather than a horizontal line you have to take on faith.")
bodyTr   = input.int(88, "Body transparency", minval = 50, maxval = 99, group = gC)
bodyW    = input.int(1, "Boundary line width", minval = 1, maxval = 5, group = gC)
tgtOff   = input.int(20, "Target projection offset (bars right)", minval = 3, maxval = 120, group = gC, tooltip = "The target is drawn as a dotted vertical drop from the entry — it shows HOW FAR and WHICH WAY at a glance, instead of yet another horizontal line running back across the chart.")
showName = input.bool(true, "Name the pattern inside its body", group = gC)
extendN  = input.int(15, "Extend a triggered pattern's neckline (bars)", minval = 0, maxval = 200, group = gC)
colBull  = input.color(#26a69a, "Bullish", inline = "c", group = g6)
colBear  = input.color(#ef5350, "Bearish", inline = "c", group = g6)
colSm    = input.color(#ab47bc, "Smoother", inline = "c", group = g6)
lblSize  = input.string("Small", "Label size", options = ["Tiny","Small","Normal"], group = g6)

showPanel= input.bool(true, "Show dashboard", group = g7)
panelMode= input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g7, tooltip = "Pro shows the full per-pattern calibration table — which is the whole point of the tool.")
panelPos = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g7)
legendPos= input.string("Bottom Right", "Legend position", options = ["Bottom Right","Bottom Left","Middle Left","Top Left"], group = g7, tooltip = "TradingView's own watermark sits bottom-LEFT and will clip a legend placed there.")
showLegend=input.bool(false, "Show legend / key", group = g7, tooltip = "A separate table from the dashboard, with its own position. OFF by default — it explains the colours and symbols, which you only need to learn once, and it costs chart space every bar after that.")
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g7)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          TYPES
// ═════════════════════════════════════════════════════════════════════════════════════════
type Ext
    float sm            // the SMOOTHED value — the pattern rules run on this (LMW)
    float raw           // the actual high/low — the levels and targets run on this (tradeable)
    int   bi
    int   kind          // +1 = local max · -1 = local min

type Pat
    int   id            // 0..16, see f_patName
    int   k1            // kind of E1: +1 = the shape starts on a HIGH · -1 = on a LOW
    int   sn            // SERIAL. Several patterns can trigger on the SAME bar; exactly one of them
                        // owns the drawn setup, and this is how we know which.
    bool  bilat         // TRUE = the pattern makes no directional claim; price decides (see below)
    int   dir           // +1 long · -1 short · 0 = undecided (a bilateral pattern before it breaks)
    int   nx            // the extremum the SHAPE is drawn from: 1 normally, 3 for double top/bottom
                        // (a double bottom's E1 is an unrelated low far to the left — drawing the body
                        //  from it turned every double bottom on the chart into a fake triangle)
    // ── TWO BOUNDARIES, NOT ONE ──
    // A directional pattern arms ONE side and leaves the other na. A bilateral pattern arms BOTH and
    // waits. This is the whole point: a symmetric triangle has no direction until it breaks, and
    // pretending otherwise — which is what "triangle top → short" did — is inventing a signal.
    // ── THE BOUNDARIES SLOPE, BECAUSE THE PATTERNS DO ──
    // A triangle's boundary is a TRENDLINE. Testing a break against a HORIZONTAL line drawn at the
    // last extremum is not the same test — and, worse, it is wrong in a DIFFERENT DIRECTION for
    // different patterns. A converging boundary (triangle, wedge) sits below its last extremum, so a
    // horizontal proxy triggers LATE. A diverging one (broadening) sits above it, so the proxy
    // triggers EARLY, on breaks that never happened. Comparing a pattern that triggers late against
    // one that triggers early — which is the ENTIRE POINT of this script — is then meaningless.
    // trig is the level AT bar `abar`; slp is its slope per bar. Flat boundaries simply have slp = 0.
    float trigU         // close ABOVE the projected level → long
    float trigD         // close BELOW the projected level → short
    float slpU
    float slpD
    int   abar          // the bar trigU / trigD are anchored at
    float stopU         // the stop if it breaks up
    float stopD         // the stop if it breaks down
    float mmOffU        // the measured move as a DISTANCE, projected from the boundary at the BREAK
    float mmOffD
    int   bi            // bar it was detected
    int   fb            // bar it FIRED on (-1000 = never) — lets the chart draw the pattern that
                        // actually owns the live entry/stop/target, instead of whatever was detected last
    // ALL FIVE EXTREMA — so the SHAPE itself can be drawn, not just its neckline.
    // (A pattern detector that shows you a horizontal line and calls it a head-and-shoulders is
    //  asking you to take its word for it. You should be able to SEE the shape it found.)
    int   x1
    int   x2
    int   x3
    int   x4
    int   x5
    float y1
    float y2
    float y3
    float y4
    float y5
    bool  fired
    bool  dead
    line  l1            // the zigzag through the extrema
    line  l2
    line  l3
    line  l4
    line  bU            // upper boundary
    line  bD            // lower boundary
    linefill bf         // the pattern BODY, filled between the boundaries
    line  ln            // the trigger level (upper, for a bilateral pattern)
    line  ln2           // the SECOND trigger level — a bilateral pattern has two of them
    line  tgU           // the measured-move arrow, UP
    line  tgD           // the measured-move arrow, DOWN
    label lbU           // its "Target" chip
    label lbD
    label lbC           // the pattern's name, centred inside its own body
    label lb            // the pattern's track record

type Trade
    int   bi
    float entry
    float stop
    float tgt
    int   dir
    int   bucket
    float rr

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    ENGINE PRIMITIVES
// ═════════════════════════════════════════════════════════════════════════════════════════
float atr = ta.atr(14)

// Pine's "+#.00" format treats the '+' as a LITERAL character, so −0.25 renders as "-+.25". Sign it
// by hand instead. (This is why the first live test showed "-+.25R" — a real formatting bug.)
f_R(float v) => na(v) ? "-" : (v >= 0 ? "+" : "") + str.tostring(v, "#.00") + "R"

// Each pattern FAMILY gets its own colour, so the chart reads at a glance instead of being a wall of
// red and green. Bull/bear is still legible from the direction the shape breaks.
f_patCol(int id) => (id == 0 or id == 1) ? cHS : (id >= 2 and id <= 5) ? cDbl : (id == 6 or id == 7 or id == 12) ? cTri : (id >= 8 and id <= 11) ? cWedge : (id == 13) ? cRect : cBroad

// ══ THE SEVENTEEN ══
//   0-11  DIRECTIONAL — the classical claim names a breakout direction, so we trade that direction
//         and let the calibration say whether the claim survives contact with your instrument.
//   12-16 BILATERAL   — no classical direction exists. Both boundaries are armed; PRICE picks the
//         side. These were previously split into "top" and "bottom" variants and traded SHORT or
//         LONG purely on whether the first extremum happened to be a high or a low. That is a phase
//         accident of where the extremum series began, not a forecast — and it halved every sample
//         for nothing. One pattern, one bucket, direction decided by the break.
f_patName(int id) => id == 0 ? "Head & shoulders" : id == 1 ? "Inverse H&S" : id == 2 ? "Double top" : id == 3 ? "Double bottom" : id == 4 ? "Triple top" : id == 5 ? "Triple bottom" : id == 6 ? "Ascending triangle" : id == 7 ? "Descending triangle" : id == 8 ? "Rising wedge" : id == 9 ? "Falling wedge" : id == 10 ? "Asc. broadening wedge" : id == 11 ? "Desc. broadening wedge" : id == 12 ? "Symmetric triangle" : id == 13 ? "Rectangle" : id == 14 ? "Broadening formation" : id == 15 ? "R-A broadening, asc." : "R-A broadening, desc."
f_patShort(int id) => id == 0 ? "H&S" : id == 1 ? "iH&S" : id == 2 ? "DblTop" : id == 3 ? "DblBot" : id == 4 ? "TripTop" : id == 5 ? "TripBot" : id == 6 ? "AscTri" : id == 7 ? "DescTri" : id == 8 ? "RiseWdg" : id == 9 ? "FallWdg" : id == 10 ? "AscBrdWdg" : id == 11 ? "DescBrdWdg" : id == 12 ? "SymTri" : id == 13 ? "Rect" : id == 14 ? "Broad" : id == 15 ? "RABFA" : "RABFD"
// BIAS drives the FILL: green = bullish, red = bearish, AMBER = bilateral (12-16). The amber is not
// decoration — it is the same claim the trigger logic now makes. Previously the fill said "this
// breaks either way" while the code shorted it on sight. The paint and the code finally agree.
f_patBias(int id) => (id == 1 or id == 3 or id == 5 or id == 6 or id == 9 or id == 11) ? 1 : (id == 0 or id == 2 or id == 4 or id == 7 or id == 8 or id == 10) ? -1 : 0
f_patBilat(int id) => id >= 12
f_lblSize() => lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small
f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : s == "Middle Left" ? position.middle_left : position.top_right

bool darkUI   = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color colWarn = color.new(#ffa726, 0)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   A · THE NADARAYA-WATSON KERNEL SMOOTHER
//   m(t) = Σ K((t-i)/h)·P(i) / Σ K((t-i)/h),  with a Gaussian kernel K(z) = exp(-z²/2).
//   Evaluated at bar_index - kW using bars 0..2·kW back — so the whole window is HISTORY. The
//   estimate for a given bar therefore only becomes available kW bars later. That is exactly why
//   this does not repaint, and exactly why the patterns print late.
// ═════════════════════════════════════════════════════════════════════════════════════════
f_nw() =>
    float num = 0.0
    float den = 0.0
    for j = 0 to 2 * kW
        float z = (j - kW) / kH
        float k = math.exp(-0.5 * z * z)
        num += k * kSrc[j]
        den += k
    den > 0 ? num / den : na

// f_nw() reads history (kSrc[j]), so it MUST be called on every bar. Calling it inside a ternary
// leaves its history buffer inconsistent and the smoother can silently return the wrong value —
// which is exactly what CW10004 is warning about. Call it unconditionally, then mask.
float smRaw = f_nw()
float sm = bar_index > 2 * kW ? smRaw : na        // the smoothed value AT bar_index - kW

// ═════════════════════════════════════════════════════════════════════════════════════════
//   B · LOCAL EXTREMA OF THE SMOOTHED SERIES
//   The pattern rules run on the SMOOTHED value (faithful to the paper). The levels, stops and
//   targets run on the ACTUAL high/low at that bar, because that is what you can actually trade.
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<Ext>   exts   = array.new<Ext>()
var array<Pat>   pats   = array.new<Pat>()
var array<Trade> pendT  = array.new<Trade>()      // tradability (fixed geometry, has a control)
var array<Trade> pendM  = array.new<Trade>()      // the measured move (descriptive, no control)

// buckets: pattern p, direction d  →  p*2 + (d==1 ? 0 : 1)   ·  34 = control LONG · 35 = control SHORT
// 17 patterns × 2 directions = 34, plus the two controls = 36.
var array<int>   bN  = array.new<int>(36, 0)
var array<float> bR  = array.new<float>(36, 0.0)
var array<float> bR2 = array.new<float>(36, 0.0)
// THE MEASURED MOVE: hits, attempts, and — the part everyone leaves out — HOW FAR AWAY IT IS.
// A hit rate on its own is not a fact about the pattern, it is a fact about the distance. A double
// bottom's measured move sits ~0.6R from the entry and is reached 73% of the time; a symmetric
// triangle's sits ~5.7R away and is reached 0% of the time. Those two numbers say the SAME thing.
// Reporting the hit rate without the distance invites the reader to conclude the double bottom is
// the better pattern, which does not follow at all. So we report both.
var array<int>   mmH = array.new<int>(17, 0)
var array<int>   mmN = array.new<int>(17, 0)
var array<float> mmR = array.new<float>(17, 0.0)   // Σ (measured-move distance ÷ risk)

bool newExt = false
if barstate.isconfirmed and not na(sm) and not na(sm[2]) and atr > 0
    bool isMax = sm[1] > sm[2] and sm[1] > sm
    bool isMin = sm[1] < sm[2] and sm[1] < sm
    if isMax or isMin
        int   kind = isMax ? 1 : -1
        int   eb   = bar_index - kW - 1
        float raw  = isMax ? high[kW + 1] : low[kW + 1]
        float prom = minProm * atr
        bool  handled = false
        if array.size(exts) > 0
            Ext last = array.get(exts, array.size(exts) - 1)
            bool sameKind = last.kind == kind
            // ── THE PROMINENCE FILTER ──
            // In a FLAT stretch the smoother still wiggles by a few ticks, and every wiggle looks
            // like a local extremum. Left unfiltered they fill the five-extremum window with noise
            // and the real shape is never seen. An extremum must MEAN something.
            bool tooSmall = math.abs(sm[1] - last.sm) < prom
            if sameKind or tooSmall
                handled := true
                // a same-kind (or insignificant) neighbour never becomes a NEW extremum — but if it
                // is more extreme than the one we are holding, it REPLACES it.
                if (isMax and sm[1] > last.sm and last.kind == 1) or (isMin and sm[1] < last.sm and last.kind == -1)
                    array.pop(exts)
                    array.push(exts, Ext.new(sm[1], raw, eb, kind))
                    newExt := true
        if not handled
            array.push(exts, Ext.new(sm[1], raw, eb, kind))
            newExt := true
        while array.size(exts) > 8
            array.shift(exts)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   C · THE PATTERN RULES  (Lo-Mamaysky-Wang grammar, on the last five extrema)
//
//   THE PARTITION IS NOW EXHAUSTIVE. Previously the rules were a pile of independent `if`s, and it
//   showed: three level peaks with FALLING troughs is a right-angled descending broadening formation
//   — the rules had no such pattern, so the shape fell through to the last branch and was logged as a
//   TRIPLE TOP. (Bulkowski's own quiz for that pattern opens by warning the reader: you may think
//   you are looking at a triple top.) Meanwhile a shape with higher highs AND higher lows that was
//   WIDENING matched nothing at all and was silently dropped.
//
//   So the peaks and the troughs are each classified as FLAT / RISING / FALLING — three states,
//   mutually exclusive, exhaustive — and the 3×3 grid names every shape exactly once:
//
//                            troughs FLAT      troughs RISING     troughs FALLING
//        peaks FLAT          Rectangle*        Ascending tri      R-A broadening desc*
//                            (or Triple top)
//        peaks RISING        R-A broad. asc*   Rising wedge  /    Broadening formation*
//                                              Asc. broad. wedge
//        peaks FALLING       Descending tri    Symmetric tri*     Falling wedge /
//                                                                 Desc. broad. wedge
//                                                    * = BILATERAL (no directional claim)
//
//   Converging vs diverging splits the two same-slope cells. Head-and-shoulders and double
//   tops/bottoms sit outside the grid — they are defined by EQUALITY of specific extrema, not by
//   the slope of the envelope — so they are tested separately.
// ═════════════════════════════════════════════════════════════════════════════════════════

// One push for every pattern. A DIRECTIONAL pattern arms one side and leaves the other na; a
// BILATERAL pattern arms both and lets price choose. Every boundary carries a SLOPE.
var array<int> snCtr = array.new<int>(1, 0)
f_push(int id, bool bilat, int dir, int nx, float tU, float tD, float slU, float slD, int abar, float sU, float sD, float oU, float oD, Ext e1, Ext e2, Ext e3, Ext e4, Ext e5) =>
    // DEDUPE. As new extrema arrive the same shape can satisfy the rules on consecutive bars and be
    // pushed twice. Same id, same level, inside the window → same pattern.
    float dl  = na(tU) ? tD + slD * (bar_index - abar) : tU + slU * (bar_index - abar)
    bool  dup = false
    if array.size(pats) > 0
        for i = 0 to array.size(pats) - 1
            Pat o = array.get(pats, i)
            float odl = na(o.trigU) ? o.trigD + o.slpD * (bar_index - o.abar) : o.trigU + o.slpU * (bar_index - o.abar)
            if o.id == id and not o.dead and math.abs(odl - dl) <= tolA * atr and (bar_index - o.bi) <= dedupeBars
                dup := true
                break
    if not dup
        int sn = array.get(snCtr, 0) + 1
        array.set(snCtr, 0, sn)
        array.push(pats, Pat.new(id, e1.kind, sn, bilat, dir, nx, tU, tD, slU, slD, abar, sU, sD, oU, oD, bar_index, -1000,
             e1.bi, e2.bi, e3.bi, e4.bi, e5.bi,
             e1.raw, e2.raw, e3.raw, e4.raw, e5.raw,
             false, false, na, na, na, na, na, na, na, na, na, na, na, na, na, na))
    while array.size(pats) > keepPat
        Pat o = array.shift(pats)
        line.delete(o.l1)
        line.delete(o.l2)
        line.delete(o.l3)
        line.delete(o.l4)
        line.delete(o.bU)
        line.delete(o.bD)
        linefill.delete(o.bf)
        line.delete(o.ln)
        line.delete(o.ln2)
        line.delete(o.tgU)
        line.delete(o.tgD)
        label.delete(o.lbC)
        label.delete(o.lb)
        label.delete(o.lbU)
        label.delete(o.lbD)

if barstate.isconfirmed and newExt and array.size(exts) >= 5 and atr > 0
    int n = array.size(exts)
    Ext e1 = array.get(exts, n - 5)
    Ext e2 = array.get(exts, n - 4)
    Ext e3 = array.get(exts, n - 3)
    Ext e4 = array.get(exts, n - 2)
    Ext e5 = array.get(exts, n - 1)
    float tol   = tolA * atr
    float tolRc = tolR * atr
    float buf   = stopBufA * atr
    bool  spanOK = (e5.bi - e1.bi) <= maxSpan and (e5.bi - e1.bi) >= minSep
    float hi5 = math.max(math.max(math.max(math.max(e1.raw, e2.raw), e3.raw), e4.raw), e5.raw)
    float lo5 = math.min(math.min(math.min(math.min(e1.raw, e2.raw), e3.raw), e4.raw), e5.raw)
    float H   = hi5 - lo5                       // the pattern's height — the classical measured move

    // ── THE TWO TRENDLINES ──
    // The odd extrema (E1,E3,E5) lie on one boundary, the even ones (E2,E4) on the other. Take the
    // slope from the LAST TWO touches of each — that is the line a chartist would actually draw —
    // and anchor both boundaries at E5 so a single anchor bar serves them both.
    int   dOdd = e5.bi - e3.bi
    int   dEvn = e4.bi - e2.bi
    float slOdd = dOdd > 0 ? (e5.raw - e3.raw) / dOdd : 0.0
    float slEvn = dEvn > 0 ? (e4.raw - e2.raw) / dEvn : 0.0
    int   abar  = e5.bi
    float oddAt5 = e5.raw                                          // E1/E3/E5 boundary, at E5
    float evnAt5 = e4.raw + slEvn * (e5.bi - e4.bi)                // E2/E4 boundary, extrapolated to E5

    if spanOK and e1.kind == 1
        // ══ E1,E3,E5 are MAXIMA (the peaks) · E2,E4 are MINIMA (the troughs) ══
        float pHi = math.max(math.max(e1.sm, e3.sm), e5.sm)
        float pLo = math.min(math.min(e1.sm, e3.sm), e5.sm)
        bool  pFlat = (pHi - pLo) <= tolRc
        bool  pRise = not pFlat and e1.sm < e3.sm and e3.sm < e5.sm
        bool  pFall = not pFlat and e1.sm > e3.sm and e3.sm > e5.sm
        bool  tFlat = math.abs(e2.sm - e4.sm) <= tolRc
        bool  tRise = e2.sm < e4.sm - tolRc
        bool  tFall = e2.sm > e4.sm + tolRc
        float pFlatLvl = (e1.raw + e3.raw + e5.raw) / 3.0     // flat resistance
        float tFlatLvl = (e2.raw + e4.raw) / 2.0              // flat support
        // the peaks are the UPPER boundary (odd), the troughs the LOWER (even)
        float uL = oddAt5
        float uS = slOdd
        float dL = evnAt5
        float dS = slEvn
        float stU = evnAt5 - buf                              // break up   → stop under the lower boundary
        float stD = oddAt5 + buf                              // break down → stop over the upper boundary

        // ── PEAKS FLAT ──
        if pFlat and tFlat
            if usRECT and pLo > math.max(e2.sm, e4.sm)
                f_push(13, true, 0, 1, pFlatLvl, tFlatLvl, 0.0, 0.0, abar, tFlatLvl - buf, pFlatLvl + buf, H, H, e1, e2, e3, e4, e5)
            else if usTRIP
                f_push(4, false, -1, 1, na, tFlatLvl, 0.0, 0.0, abar, na, pFlatLvl + buf, na, pFlatLvl - tFlatLvl, e1, e2, e3, e4, e5)
        else if pFlat and tRise and usASC
            // ASCENDING TRIANGLE — flat resistance, rising lows
            f_push(6, false, 1, 1, pFlatLvl, na, 0.0, 0.0, abar, evnAt5 - buf, na, H, na, e1, e2, e3, e4, e5)
        else if pFlat and tFall and usRABF
            // R-A BROADENING, DESCENDING — flat top, falling lows. Used to be logged as a triple top.
            f_push(16, true, 0, 1, pFlatLvl, dL, 0.0, dS, abar, evnAt5 - buf, pFlatLvl + buf, H, H, e1, e2, e3, e4, e5)

        // ── PEAKS RISING ──
        if pRise and tFlat and usRABF
            // R-A BROADENING, ASCENDING — flat bottom, rising highs
            f_push(15, true, 0, 1, uL, tFlatLvl, uS, 0.0, abar, tFlatLvl - buf, stD, H, H, e1, e2, e3, e4, e5)
        else if pRise and tFall and usBRD
            f_push(14, true, 0, 1, uL, dL, uS, dS, abar, stU, stD, H, H, e1, e2, e3, e4, e5)
        else if pRise and tRise
            bool conv = (e5.sm - e4.sm) < (e3.sm - e2.sm) - tolRc
            bool divg = (e5.sm - e4.sm) > (e3.sm - e2.sm) + tolRc
            if conv and usWDG
                f_push(8, false, -1, 1, na, dL, 0.0, dS, abar, na, stD, na, H, e1, e2, e3, e4, e5)   // RISING WEDGE
            else if divg and usBWDG
                f_push(10, false, -1, 1, na, dL, 0.0, dS, abar, na, stD, na, H, e1, e2, e3, e4, e5)  // ASC BROADENING WEDGE

        // ── PEAKS FALLING ──
        if pFall and tFlat and usASC
            f_push(7, false, -1, 1, na, tFlatLvl, 0.0, 0.0, abar, na, oddAt5 + buf, na, H, e1, e2, e3, e4, e5)  // DESCENDING TRIANGLE
        else if pFall and tRise and usTRI
            f_push(12, true, 0, 1, uL, dL, uS, dS, abar, stU, stD, H, H, e1, e2, e3, e4, e5)         // SYMMETRIC TRIANGLE
        else if pFall and tFall
            bool conv = (e5.sm - e4.sm) < (e3.sm - e2.sm) - tolRc
            bool divg = (e5.sm - e4.sm) > (e3.sm - e2.sm) + tolRc
            if conv and usWDG
                f_push(9, false, 1, 1, uL, na, uS, 0.0, abar, stU, na, H, na, e1, e2, e3, e4, e5)    // FALLING WEDGE
            else if divg and usBWDG
                f_push(11, false, 1, 1, uL, na, uS, 0.0, abar, stU, na, H, na, e1, e2, e3, e4, e5)   // DESC BROADENING WEDGE

        // ── OUTSIDE THE GRID: defined by EQUALITY, not by the slope of the envelope ──
        float neck = (e2.raw + e4.raw) / 2.0
        if usHS and e3.sm > e1.sm and e3.sm > e5.sm and math.abs(e1.sm - e5.sm) <= tol and math.abs(e2.sm - e4.sm) <= tol
            f_push(0, false, -1, 1, na, neck, 0.0, 0.0, abar, na, e5.raw + buf, na, e3.raw - neck, e1, e2, e3, e4, e5)
        // DOUBLE TOP — drawn from E3, not E1: E1 is an unrelated peak far to the left, and building
        // the body from it made every double top look like a triangle on the chart.
        if usDBL and not pFlat and math.abs(e3.sm - e5.sm) <= tol and e3.sm > e4.sm and e5.sm > e4.sm and (e5.bi - e3.bi) >= minSep
            f_push(2, false, -1, 3, na, e4.raw, 0.0, 0.0, abar, na, math.max(e3.raw, e5.raw) + buf, na, math.max(e3.raw, e5.raw) - e4.raw, e1, e2, e3, e4, e5)

    if spanOK and e1.kind == -1
        // ══ E1,E3,E5 are MINIMA (the troughs) · E2,E4 are MAXIMA (the peaks) ══  every rule mirrored
        float tHi = math.max(math.max(e1.sm, e3.sm), e5.sm)
        float tLo = math.min(math.min(e1.sm, e3.sm), e5.sm)
        bool  tFlat = (tHi - tLo) <= tolRc
        bool  tRise = not tFlat and e1.sm < e3.sm and e3.sm < e5.sm
        bool  tFall = not tFlat and e1.sm > e3.sm and e3.sm > e5.sm
        bool  pFlat = math.abs(e2.sm - e4.sm) <= tolRc
        bool  pRise = e2.sm < e4.sm - tolRc
        bool  pFall = e2.sm > e4.sm + tolRc
        float tFlatLvl = (e1.raw + e3.raw + e5.raw) / 3.0     // flat support
        float pFlatLvl = (e2.raw + e4.raw) / 2.0              // flat resistance
        // now the TROUGHS are the odd boundary (lower) and the PEAKS are the even one (upper)
        float dL = oddAt5
        float dS = slOdd
        float uL = evnAt5
        float uS = slEvn
        float stU = oddAt5 - buf
        float stD = evnAt5 + buf

        // ── TROUGHS FLAT ──
        if tFlat and pFlat
            if usRECT and math.min(e2.sm, e4.sm) > tHi
                f_push(13, true, 0, 1, pFlatLvl, tFlatLvl, 0.0, 0.0, abar, tFlatLvl - buf, pFlatLvl + buf, H, H, e1, e2, e3, e4, e5)
            else if usTRIP
                f_push(5, false, 1, 1, pFlatLvl, na, 0.0, 0.0, abar, tFlatLvl - buf, na, pFlatLvl - tFlatLvl, na, e1, e2, e3, e4, e5)
        else if tFlat and pFall and usASC
            f_push(7, false, -1, 1, na, tFlatLvl, 0.0, 0.0, abar, na, evnAt5 + buf, na, H, e1, e2, e3, e4, e5)   // DESCENDING TRIANGLE
        else if tFlat and pRise and usRABF
            // R-A BROADENING, ASCENDING — flat bottom, rising highs. Used to be logged as a triple bottom.
            f_push(15, true, 0, 1, uL, tFlatLvl, uS, 0.0, abar, tFlatLvl - buf, stD, H, H, e1, e2, e3, e4, e5)

        // ── TROUGHS RISING ──
        if tRise and pFlat and usASC
            f_push(6, false, 1, 1, pFlatLvl, na, 0.0, 0.0, abar, oddAt5 - buf, na, H, na, e1, e2, e3, e4, e5)    // ASCENDING TRIANGLE
        else if tRise and pFall and usTRI
            f_push(12, true, 0, 1, uL, dL, uS, dS, abar, stU, stD, H, H, e1, e2, e3, e4, e5)                     // SYMMETRIC TRIANGLE
        else if tRise and pRise
            bool conv = (e4.sm - e5.sm) < (e2.sm - e3.sm) - tolRc
            bool divg = (e4.sm - e5.sm) > (e2.sm - e3.sm) + tolRc
            if conv and usWDG
                f_push(8, false, -1, 1, na, dL, 0.0, dS, abar, na, stD, na, H, e1, e2, e3, e4, e5)   // RISING WEDGE
            else if divg and usBWDG
                f_push(10, false, -1, 1, na, dL, 0.0, dS, abar, na, stD, na, H, e1, e2, e3, e4, e5)  // ASC BROADENING WEDGE

        // ── TROUGHS FALLING ──
        if tFall and pFlat and usRABF
            f_push(16, true, 0, 1, pFlatLvl, dL, 0.0, dS, abar, oddAt5 - buf, pFlatLvl + buf, H, H, e1, e2, e3, e4, e5)  // R-A BROADENING, DESC
        else if tFall and pRise and usBRD
            f_push(14, true, 0, 1, uL, dL, uS, dS, abar, stU, stD, H, H, e1, e2, e3, e4, e5)         // BROADENING FORMATION
        else if tFall and pFall
            bool conv = (e4.sm - e5.sm) < (e2.sm - e3.sm) - tolRc
            bool divg = (e4.sm - e5.sm) > (e2.sm - e3.sm) + tolRc
            if conv and usWDG
                f_push(9, false, 1, 1, uL, na, uS, 0.0, abar, stU, na, H, na, e1, e2, e3, e4, e5)    // FALLING WEDGE
            else if divg and usBWDG
                f_push(11, false, 1, 1, uL, na, uS, 0.0, abar, stU, na, H, na, e1, e2, e3, e4, e5)   // DESC BROADENING WEDGE

        // ── OUTSIDE THE GRID ──
        float neck = (e2.raw + e4.raw) / 2.0
        if usHS and e3.sm < e1.sm and e3.sm < e5.sm and math.abs(e1.sm - e5.sm) <= tol and math.abs(e2.sm - e4.sm) <= tol
            f_push(1, false, 1, 1, neck, na, 0.0, 0.0, abar, e5.raw - buf, na, neck - e3.raw, na, e1, e2, e3, e4, e5)
        if usDBL and not tFlat and math.abs(e3.sm - e5.sm) <= tol and e3.sm < e4.sm and e5.sm < e4.sm and (e5.bi - e3.bi) >= minSep
            f_push(3, false, 1, 3, e4.raw, na, 0.0, 0.0, abar, math.min(e3.raw, e5.raw) - buf, na, e4.raw - math.min(e3.raw, e5.raw), na, e1, e2, e3, e4, e5)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   D · THE TRIGGER  —  a pattern is not a trade until a boundary breaks
//   A DIRECTIONAL pattern has one armed boundary; the other is na and can never fire. A BILATERAL
//   pattern has both armed, and WHICHEVER ONE BREAKS decides the direction. The upper boundary is
//   always above the lower, so they cannot both fire on the same close.
// ═════════════════════════════════════════════════════════════════════════════════════════
var float eEn = na
var float eSt = na
var float eTg = na
var int   eDir = 0
var int   eId  = -1
var float eRR  = na
var int   eBar = -1000
var int   eSn  = -1              // WHICH pattern owns the drawn setup. Several can trigger on the SAME
                                 // bar; without a serial they ALL believed they owned it, and drew — so
                                 // two name chips stacked on each other and four target arrows appeared.
bool firedNow = false

if barstate.isconfirmed and array.size(pats) > 0 and atr > 0
    for i = 0 to array.size(pats) - 1
        Pat p = array.get(pats, i)
        // a pattern that never broke is not still waiting — it FAILED to break. Retire it, rather
        // than extrapolate its trendline off into space.
        if not p.fired and not p.dead and bar_index - p.bi > armBars
            p.dead := true
        if not p.fired and not p.dead and bar_index > p.bi
            // THE BOUNDARY IS A MOVING LINE, so the level is evaluated at THIS bar, not at detection.
            float lU = na(p.trigU) ? na : p.trigU + p.slpU * (bar_index - p.abar)
            float lD = na(p.trigD) ? na : p.trigD + p.slpD * (bar_index - p.abar)
            bool tUp = not na(lU) and close > lU
            bool tDn = not na(lD) and close < lD
            // BUST — a DIRECTIONAL pattern can be invalidated before it ever triggers (price goes to
            // where its stop would have been). A BILATERAL pattern cannot: it has no thesis to
            // invalidate. It simply waits for a side.
            bool bust = not p.bilat and (p.dir == 1 ? close < p.stopU : close > p.stopD)
            if bust
                p.dead := true
            else if tUp or tDn
                int   d   = tUp ? 1 : -1
                float stp = tUp ? p.stopU : p.stopD
                // THE MEASURED MOVE IS PROJECTED FROM THE BOUNDARY IT BROKE, at the bar it broke it —
                // which is what the textbook actually says, and what a fixed level computed at
                // detection could not give you once the boundary was allowed to slope.
                float mm  = tUp ? lU + p.mmOffU : lD - p.mmOffD
                // ENTRY IS THE CLOSE — the trigger is a SIGNAL, not a fill. Entering at the boundary
                // (a better price than the close) while the control enters at the close would hand
                // every pattern a free head start and manufacture an edge out of nothing.
                float en   = close
                float risk = math.abs(en - stp)
                if risk > 0
                    p.fired := true
                    p.fb    := bar_index
                    p.dir   := d                     // a bilateral pattern LEARNS its direction here
                    eSn := p.sn
                    eEn := en
                    eSt := stp
                    eTg := d == 1 ? en + tgtR * risk : en - tgtR * risk
                    eDir := d
                    eId := p.id
                    eRR := tgtR
                    eBar := bar_index
                    firedNow := true
                    if calibOn
                        int b = p.id * 2 + (d == 1 ? 0 : 1)
                        array.push(pendT, Trade.new(bar_index, en, stp, eTg, d, b, tgtR))
                        // the MEASURED MOVE is a different question, so it gets its own tracker:
                        // did the classical projection get REACHED before the pattern's own stop?
                        // pendM's `rr` slot carries the MEASURED MOVE'S DISTANCE IN R, so that when
                        // the projection resolves we can report not just whether it was reached but
                        // how far away it was. Without that, the hit rate is uninterpretable.
                        array.push(pendM, Trade.new(bar_index, en, stp, mm, d, p.id, math.abs(mm - en) / risk))

// ─────────────────────────────────────────────────────────────────────────────────────────
//   D2 · THE SETUP IS A TRADE, AND A TRADE ENDS
//   The old rule kept a setup on the chart for 200 bars regardless of what price did. So a trade
//   that hit its stop forty bars ago was still labelled "Live", with its entry, stop and target
//   drawn as though it were open. It was not open. It was over. Resolve it: the moment price
//   touches the target or the stop — or the grading horizon runs out — the setup is closed and
//   comes off the chart. The statistics were always graded honestly; only the DRAWING was lying.
// ─────────────────────────────────────────────────────────────────────────────────────────
var bool eOpen = false
var int  eRes  = 0                       // +1 = target hit · -1 = stopped · 0 = expired / none
if firedNow
    eOpen := true
    eRes  := 0
else if barstate.isconfirmed and eOpen and not na(eEn) and bar_index > eBar
    bool tHit = eDir == 1 ? high >= eTg : low  <= eTg
    bool sHit = eDir == 1 ? low  <= eSt : high >= eSt
    if sHit                              // stop first if both touch on one bar — never flatter the result
        eOpen := false
        eRes  := -1
    else if tHit
        eOpen := false
        eRes  := 1
    else if bar_index - eBar >= calHor
        eOpen := false
        eRes  := 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//   E · CALIBRATION
//   The control is UNCONDITIONAL and DIRECTION-MATCHED: the same geometry on arbitrary bars, one
//   long and one short. Every pattern trade uses IDENTICAL geometry (a fixed R multiple), so the
//   comparison is apples to apples — which is exactly what a pooled control with mismatched R:R
//   would not be.
// ═════════════════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and calibOn and atr > 0 and bar_index % ctlEvery == 0
    float risk = atr
    array.push(pendT, Trade.new(bar_index, close, close - risk, close + tgtR * risk,  1, 34, tgtR))
    array.push(pendT, Trade.new(bar_index, close, close + risk, close - tgtR * risk, -1, 35, tgtR))

if barstate.isconfirmed and array.size(pendT) > 0
    int i = 0
    while i < array.size(pendT)
        Trade t = array.get(pendT, i)
        bool hitT = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitT or hitS or expd)
            // both barriers on one bar → the STOP is assumed first. Conservative, and the only
            // assumption that cannot flatter the result.
            float risk = math.abs(t.entry - t.stop)
            // expired trades are MARKED TO MARKET — an unresolved trade is neither a win nor a loss.
            float rOut = hitS ? -1.0 : hitT ? t.rr : (risk > 0 ? (close - t.entry) * t.dir / risk : 0.0)
            array.set(bN,  t.bucket, array.get(bN,  t.bucket) + 1)
            array.set(bR,  t.bucket, array.get(bR,  t.bucket) + rOut)
            array.set(bR2, t.bucket, array.get(bR2, t.bucket) + rOut * rOut)
            array.remove(pendT, i)
        else
            i += 1

// the measured move: reached, or stopped out / expired trying?
if barstate.isconfirmed and array.size(pendM) > 0
    int i = 0
    while i < array.size(pendM)
        Trade t = array.get(pendM, i)
        bool hitMM = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS  = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd  = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitMM or hitS or expd)
            array.set(mmN, t.bucket, array.get(mmN, t.bucket) + 1)
            array.set(mmH, t.bucket, array.get(mmH, t.bucket) + ((hitMM and not hitS) ? 1 : 0))
            array.set(mmR, t.bucket, array.get(mmR, t.bucket) + t.rr)
            array.remove(pendM, i)
        else
            i += 1

f_n(int ix)  => array.get(bN, ix)
f_exp(int ix) =>
    int n = array.get(bN, ix)
    n > 0 ? array.get(bR, ix) / float(n) : na
f_var(int ix) =>
    int n = array.get(bN, ix)
    if n < 2
        na
    else
        float m = array.get(bR, ix) / n
        math.max(array.get(bR2, ix) / n - m * m, 0.0)

// Combine a pattern's LONG and SHORT buckets, and build the control to MATCH its direction mix.
// Indices drift; a long-biased pattern compared with a 50/50 control would inherit that drift for
// free and call it an edge.
f_patStat(int id) =>
    int iL = id * 2
    int iS = id * 2 + 1
    int nL = f_n(iL)
    int nS = f_n(iS)
    int nE = nL + nS
    if nE < 2
        [float(na), float(na), nE, float(na)]
    else
        float sR  = array.get(bR, iL)  + array.get(bR, iS)
        float sR2 = array.get(bR2, iL) + array.get(bR2, iS)
        float mE  = sR / nE
        float vE  = math.max(sR2 / nE - mE * mE, 0.0)
        float seE = math.sqrt(vE / nE)
        float wL  = nL / float(nE)
        float wS  = nS / float(nE)
        float mCL = f_exp(34)
        float mCS = f_exp(35)
        float mC  = (na(mCL) ? 0.0 : wL * mCL) + (na(mCS) ? 0.0 : wS * mCS)
        float vCL = f_var(34)
        float vCS = f_var(35)
        int   nCL = f_n(34)
        int   nCS = f_n(35)
        float seC = math.sqrt((nCL > 1 and not na(vCL) ? wL * wL * vCL / nCL : 0.0) + (nCS > 1 and not na(vCS) ? wS * wS * vCS / nCS : 0.0))
        float se  = math.sqrt(seE * seE + seC * seC)
        [mE, mC, nE, se > 0 ? (mE - mC) / se : na]

f_mmRate(int id) =>
    int n = array.get(mmN, id)
    n > 0 ? array.get(mmH, id) / float(n) * 100.0 : na
// how far the classical projection actually sits, in units of the pattern's OWN risk
f_mmDist(int id) =>
    int n = array.get(mmN, id)
    n > 0 ? array.get(mmR, id) / float(n) : na

float driftL = f_exp(34)
float driftS = f_exp(35)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        DRAWING
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(showSm ? sm : na, "Smoothed price", color.new(colSm, 20), lineW, offset = -kW)

bool setupLive = showSetup and eOpen and not na(eEn)
// The setup is drawn with LINE OBJECTS, not plots. A plot whose value jumps when a new setup arms
// draws a VERTICAL CONNECTOR between the old level and the new one — that stray vertical line on the
// chart is not a level, it is an artifact, and it has no business being there.
var line sE = na
var line sS = na
var line sT = na

plotshape(firedNow and eDir == 1,  "Bullish pattern triggered", shape.triangleup,   location.belowbar, colBull, size = size.small)
plotshape(firedNow and eDir == -1, "Bearish pattern triggered", shape.triangledown, location.abovebar, colBear, size = size.small)

var label lE = na
var label lS = na
var label lT = na

if barstate.islast
    if array.size(pats) > 0 and array.size(exts) >= 5
        for i = 0 to array.size(pats) - 1
            Pat p = array.get(pats, i)
            line.delete(p.l1)
            line.delete(p.l2)
            line.delete(p.l3)
            line.delete(p.l4)
            line.delete(p.bU)
            line.delete(p.bD)
            linefill.delete(p.bf)
            line.delete(p.ln)
            line.delete(p.ln2)
            line.delete(p.tgU)
            line.delete(p.tgD)
            label.delete(p.lbC)
            label.delete(p.lb)
            label.delete(p.lbU)
            label.delete(p.lbD)
            // LATEST ONLY / UNTRIGGERED ONLY / ALL — old patterns still COUNT, they just stop cluttering.
            // THE PATTERN DRAWN MUST BE THE PATTERN TRADED. "Latest" used to mean "most recently
            // DETECTED", which is not the same thing: a double top detected after a falling wedge had
            // already triggered left the chart showing a RED BEARISH double top wearing the wedge's
            // LONG entry, stop and target. Two different patterns, one set of lines. When a setup is
            // live, draw the pattern that fired it.
            bool ownsSetup = setupLive and p.sn == eSn
            bool showThis = showMode == "All" ? true : showMode == "Untriggered only" ? (not p.fired) : (setupLive ? ownsSetup : i == array.size(pats) - 1)
            if showPat and not p.dead and showThis
                color pc = f_patCol(p.id)                       // the FAMILY colour — outline and name
                // AMBER MEANS UNDECIDED. Once a bilateral pattern breaks, it is no longer undecided,
                // so it takes the colour of the side it broke. Leaving it amber after the fact would
                // keep claiming ambiguity that price has already resolved.
                int   bias = p.fired ? p.dir : f_patBias(p.id)
                // the FILL says what the pattern MEANS: green bullish · red bearish · amber bilateral
                color fc = fillMode == "By pattern family" ? pc : bias == 1 ? colBull : bias == -1 ? colBear : cNeut

                // ── THE PATTERN BODY ──
                // Two boundary trendlines with a LINEFILL between them, so the pattern is a SHAPE you
                // can see rather than a horizontal line you have to take on faith. The boundaries are
                // the actual trendlines the classical pattern is defined by: the highs and the lows.
                // WHICH BOUNDARY IS THE UPPER ONE is decided by whether E1 was a high or a low —
                // NOT by the pattern id. Wedges are detected from both branches, so an id-based
                // list gets them backwards half the time and the linefill inverts.
                bool topFirst = p.k1 == 1
                int   xa = p.nx == 3 ? p.x3 : p.x1
                int   xb = p.x5
                float ya = p.nx == 3 ? p.y3 : p.y1
                float yb = p.y5
                // the OTHER boundary runs through the two opposing extrema, extrapolated across the
                // whole pattern so the fill spans it properly
                int   xm1 = p.nx == 3 ? p.x4 : p.x2
                int   xm2 = p.x4
                float ym1 = p.nx == 3 ? p.y4 : p.y2
                float ym2 = p.y4
                float slope = (xm2 - xm1) != 0 ? (ym2 - ym1) / (xm2 - xm1) : 0.0
                float oa = ym1 + slope * (xa - xm1)
                float ob = ym1 + slope * (xb - xm1)

                if showBody
                    if topFirst
                        p.bU := line.new(xa, ya, xb, yb, xloc = xloc.bar_index, color = color.new(fc, 25), width = bodyW)
                        p.bD := line.new(xa, oa, xb, ob, xloc = xloc.bar_index, color = color.new(fc, 25), width = bodyW)
                    else
                        p.bU := line.new(xa, oa, xb, ob, xloc = xloc.bar_index, color = color.new(fc, 25), width = bodyW)
                        p.bD := line.new(xa, ya, xb, yb, xloc = xloc.bar_index, color = color.new(fc, 25), width = bodyW)
                    p.bf := linefill.new(p.bU, p.bD, color.new(fc, bodyTr))

                // ── THE ZIGZAG ──  the extrema the detector actually used
                if showShape
                    if p.nx == 1
                        p.l1 := line.new(p.x1, p.y1, p.x2, p.y2, xloc = xloc.bar_index, color = pc, width = shapeW)
                        p.l2 := line.new(p.x2, p.y2, p.x3, p.y3, xloc = xloc.bar_index, color = pc, width = shapeW)
                    p.l3 := line.new(p.x3, p.y3, p.x4, p.y4, xloc = xloc.bar_index, color = pc, width = shapeW)
                    p.l4 := line.new(p.x4, p.y4, p.x5, p.y5, xloc = xloc.bar_index, color = pc, width = shapeW)

                // ── THE TRIGGER LEVEL(S) ──  dashed while waiting, SOLID once broken.
                // A BILATERAL pattern draws BOTH of its boundaries as live triggers, because both of
                // them are. Once one breaks, only the one that fired is drawn, and it is drawn solid.
                int lx = p.fired ? math.min(bar_index, xb + extendN) : math.min(bar_index + 10, p.bi + armBars)
                bool drawU = not na(p.trigU) and (not p.fired or p.dir == 1)
                bool drawD = not na(p.trigD) and (not p.fired or p.dir == -1)
                if drawU
                    p.ln  := line.new(xa, p.trigU + p.slpU * (xa - p.abar), lx, p.trigU + p.slpU * (lx - p.abar), xloc = xloc.bar_index, color = color.new(fc, 20), width = lineW, style = p.fired ? line.style_solid : line.style_dashed)
                if drawD
                    p.ln2 := line.new(xa, p.trigD + p.slpD * (xa - p.abar), lx, p.trigD + p.slpD * (lx - p.abar), xloc = xloc.bar_index, color = color.new(fc, 20), width = lineW, style = p.fired ? line.style_solid : line.style_dashed)

                // ── THE MEASURED MOVE, DRAWN AS ARROWS OFF THE PATTERN — BOTH WAYS ──
                // A bilateral pattern has TWO projections, because it has two boundaries and it can
                // break through either. Drawing only one of them would be picking a side, which is the
                // exact thing the amber fill promises we are not doing. A directional pattern leaves
                // the other side na, so only one arrow appears and no special case is needed.
                // ONCE IT HAS BROKEN, ONLY ONE PROJECTION IS STILL ALIVE. A symmetric triangle that
                // has already broken UP does not still have a downside measured move — drawing one
                // was showing the user a target for a trade that no longer exists.
                if showMM
                    int   anb = p.fired ? p.fb : xb + tgtOff         // project from the boundary AT THE BREAK
                    int   ax  = anb + (p.fired ? tgtOff : 0)         // ...and draw the arrow beside it
                    if drawU and not na(p.mmOffU)
                        float bU2 = p.trigU + p.slpU * (anb - p.abar)
                        float mU2 = bU2 + p.mmOffU
                        p.tgU := line.new(ax, bU2, ax, mU2, xloc = xloc.bar_index, color = color.new(colBull, 0), width = 1, style = line.style_dotted)
                        p.lbU := label.new(ax, mU2, "MM  " + str.tostring(mU2, format.mintick), xloc = xloc.bar_index, style = label.style_label_down, color = color.new(colBull, 10), textcolor = color.white, size = f_lblSize())
                    if drawD and not na(p.mmOffD)
                        float bD2 = p.trigD + p.slpD * (anb - p.abar)
                        float mD2 = bD2 - p.mmOffD
                        p.tgD := line.new(ax, bD2, ax, mD2, xloc = xloc.bar_index, color = color.new(colBear, 0), width = 1, style = line.style_dotted)
                        p.lbD := label.new(ax, mD2, "MM  " + str.tostring(mD2, format.mintick), xloc = xloc.bar_index, style = label.style_label_up, color = color.new(colBear, 10), textcolor = color.white, size = f_lblSize())

                // ── THE NAME, CENTRED IN ITS OWN BODY ──
                [pe, pc2, pn, pt] = f_patStat(p.id)
                bool prov = not na(pt) and pn >= calMinN and pt > 1.96
                float mmr = f_mmRate(p.id)
                if showName
                    int   cx = math.round((xa + xb) / 2)
                    // the name chip sits ON the pattern, at its top — compact, no price-axis clutter
                    p.lbC := label.new(cx, math.max(ya, oa, yb, ob), f_patName(p.id), xloc = xloc.bar_index, style = label.style_label_down, color = color.new(fc, 15), textcolor = color.white, size = f_lblSize())

                // ── THE TRACK RECORD, on the pattern itself ──
                string rec = pn < calMinN ? "  n=" + str.tostring(pn) + " (warming)" : "  " + f_R(pe) + " vs " + f_R(pc2) + "  n=" + str.tostring(pn) + (prov ? "  PROVEN" : "  (not proven)")
                string mms = na(mmr) ? "" : "  ·  MM " + str.tostring(mmr, "#") + "%"
                if showStats
                    p.lb := label.new(lx, drawU ? p.trigU + p.slpU * (lx - p.abar) : p.trigD + p.slpD * (lx - p.abar), (p.dir == 1 ? "▲ " : p.dir == -1 ? "▼ " : "◆ ") + f_patShort(p.id) + rec + mms, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(fc, prov ? 5 : 35), textcolor = color.white, size = f_lblSize())

    line.delete(sE)
    line.delete(sS)
    line.delete(sT)
    label.delete(lE)
    label.delete(lS)
    label.delete(lT)
    if setupLive
        sE := line.new(eBar, eEn, bar_index + 3, eEn, xloc = xloc.bar_index, color = color.new(color.gray, 0), width = lineW)
        sS := line.new(eBar, eSt, bar_index + 3, eSt, xloc = xloc.bar_index, color = color.new(eDir == 1 ? colBear : colBull, 0), width = lineW)
        sT := line.new(bar_index + tgtOff, eEn, bar_index + tgtOff, eTg, xloc = xloc.bar_index, color = color.new(eDir == 1 ? colBull : colBear, 0), width = 1, style = line.style_dotted)
        color pcE = eId >= 0 ? f_patCol(eId) : color.gray
        string nmE = eId >= 0 ? f_patName(eId) : ""
        lE := label.new(bar_index + 3, eEn, "▶ " + nmE + "  ENTRY  " + str.tostring(eEn, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(pcE, 75), textcolor = pcE, size = f_lblSize())
        color cS = eDir == 1 ? colBear : colBull
        lS := label.new(bar_index + 3, eSt, "▶ STOP  " + str.tostring(eSt, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cS, 75), textcolor = cS, size = f_lblSize())
        color cT = eDir == 1 ? colBull : colBear
        lT := label.new(bar_index + tgtOff, eTg, "Target " + str.tostring(tgtR, "#.#") + "R  " + str.tostring(eTg, format.mintick), xloc = xloc.bar_index, style = eDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(cT, 10), textcolor = color.white, size = f_lblSize())

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
bool isPro = panelMode == "Pro"
var table tb = table.new(f_pos(panelPos), 4, 23, frame_width = 1, border_width = 1)

if showPanel and barstate.islast
    table.set_bgcolor(tb, panelBg)
    table.set_frame_color(tb, frameC)
    table.set_border_color(tb, frameC)
    color hdrC = setupLive ? (eDir == 1 ? colBull : colBear) : color.new(color.gray, 20)
    color hdrT = f_lum(hdrC) > 140 ? color.rgb(10, 10, 10) : color.white
    table.cell(tb, 0, 0, "CHART PATTERNS", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 0, isPro ? "expectancy" : "pattern", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 2, 0, isPro ? "vs control · n" : "expectancy · n", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 3, 0, isPro ? "MM hit · dist" : "MM hit", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)

    if isPro
        // THE TABLE THAT DOES NOT EXIST ANYWHERE ELSE: every pattern, its own edge, its own sample.
        for id = 0 to 16
            [pe, pc, pn, pt] = f_patStat(id)
            bool prov = not na(pt) and pn >= calMinN and pt > 1.96
            color rc = pn < calMinN ? txtMut : prov ? colBull : (not na(pe) and not na(pc) and pe > pc) ? colWarn : colBear
            color bg = id % 2 == 0 ? rowAlt : panelBg
            table.cell(tb, 0, id + 1, f_patName(id) + (f_patBilat(id) ? " ◆" : ""), text_color = txtSub, text_size = size.small, text_halign = text.align_left, bgcolor = bg)
            table.cell(tb, 1, id + 1, na(pe) ? "-" : f_R(pe), text_color = rc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
            table.cell(tb, 2, id + 1, pn == 0 ? "-" : (na(pc) ? "-" : f_R(pc)) + " · " + str.tostring(pn) + (prov ? " ✓" : ""), text_color = rc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
            table.cell(tb, 3, id + 1, na(f_mmRate(id)) ? "-" : str.tostring(f_mmRate(id), "#") + "% · " + str.tostring(f_mmDist(id), "#.#") + "R", text_color = rc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
        table.cell(tb, 0, 18, "Control (unconditional)", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 18, na(driftL) ? "-" : "L " + f_R(driftL), text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 18, na(driftS) ? "-" : "S " + f_R(driftS), text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 3, 18, str.tostring(f_n(34) + f_n(35)), text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 0, 19, "Live setup", text_color = txtSub, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_left)
        string lastTxt = setupLive ? (eDir == 1 ? "LONG" : "SHORT") : eId < 0 ? "none" : eRes == 1 ? "last: target hit" : eRes == -1 ? "last: stopped" : "last: expired"
        color  lastCol = setupLive ? (eDir == 1 ? colBull : colBear) : eId < 0 ? txtMut : eRes == 1 ? colBull : eRes == -1 ? colBear : txtMut
        table.cell(tb, 1, 19, lastTxt, text_color = lastCol, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 19, eId >= 0 ? f_patShort(eId) : "-", text_color = txtMain, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 3, 19, "", bgcolor = rowAlt)
        table.cell(tb, 0, 20, "◆ = bilateral", text_color = txtMut, bgcolor = panelBg, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 20, "entry = close · in-sample", text_color = txtMut, bgcolor = panelBg, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 20, "MM hit % · its distance in R", text_color = txtMut, bgcolor = panelBg, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 3, 20, "not advice", text_color = txtMut, bgcolor = panelBg, text_size = size.small, text_halign = text.align_right)
    else
        // Compact: the live pattern and its own record, plus the best-performing pattern so far.
        int bestId = -1
        float bestE = -1e9
        for id = 0 to 16
            [pe, pc, pn, pt] = f_patStat(id)
            if pn >= calMinN and not na(pe) and pe > bestE
                bestE := pe
                bestId := id
        // Pine cannot return a tuple from a ternary, so always call with a VALID index and null the
        // results afterwards. (f_patStat indexes arrays — passing -1 would throw.)
        int safeId = eId >= 0 ? eId : 0
        [le0, lc0, ln0, lt0] = f_patStat(safeId)
        float le  = eId >= 0 ? le0 : na
        int   ln_ = eId >= 0 ? ln0 : 0
        table.cell(tb, 0, 1, "Live pattern", text_color = txtSub, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 1, setupLive and eId >= 0 ? f_patName(eId) : "none", text_color = setupLive ? (eDir == 1 ? colBull : colBear) : txtMut, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)
        // gate the stats on setupLive too — otherwise "none" sits next to a stale pattern's numbers
        bool liveOK = setupLive and eId >= 0
        // n=22 quoted as "+.38R" while the row below it says the same pattern is still "warming" is a
        // contradiction the panel should not print. Below the minimum sample, SAY SO — and grey it out.
        bool liveThin = liveOK and ln_ < calMinN
        table.cell(tb, 2, 1, (not liveOK or na(le)) ? "-" : f_R(le) + " · n=" + str.tostring(ln_) + (liveThin ? " (thin)" : ""), text_color = liveThin ? txtMut : txtMain, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 3, 1, (liveOK and not na(f_mmRate(eId))) ? str.tostring(f_mmRate(eId), "#") + "% · " + str.tostring(f_mmDist(eId), "#.#") + "R" : "-", text_color = txtMain, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 0, 2, "Best pattern here", text_color = txtSub, bgcolor = panelBg, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 2, bestId >= 0 ? f_patName(bestId) : "warming", text_color = bestId >= 0 ? colBull : txtMut, bgcolor = panelBg, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 2, bestId >= 0 ? f_R(bestE) : "-", text_color = bestId >= 0 ? colBull : txtMut, bgcolor = panelBg, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 3, 2, "", bgcolor = panelBg)
        table.cell(tb, 0, 3, "Note", text_color = txtMut, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 3, "switch to Pro for the", text_color = txtMut, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 3, "full per-pattern table", text_color = txtMut, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 3, 3, "not advice", text_color = txtMut, bgcolor = rowAlt, text_size = size.small, text_halign = text.align_right)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       LEGEND / KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
var table lg = table.new(f_pos(legendPos), 2, 16, frame_width = 1, border_width = 1)
f_lg(int r, string sw, color c, string txt) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(lg, 0, r, sw,  text_color = c,      bgcolor = bg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(lg, 1, r, txt, text_color = txtSub, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
if showLegend and barstate.islast
    table.set_bgcolor(lg, panelBg)
    table.set_frame_color(lg, frameC)
    table.set_border_color(lg, frameC)
    table.cell(lg, 0, 0, "KEY", text_color = txtMain, bgcolor = frameC, text_size = size.tiny)
    table.cell(lg, 1, 0, "what you're looking at", text_color = txtMain, bgcolor = frameC, text_size = size.tiny, text_halign = text.align_left)
    f_lg(1, "━━", colSm,   "Kernel-smoothed price — patterns are found on THIS, not on raw price")
    f_lg(2, "◆",  cHS,     "Head & shoulders  ·  inverse H&S")
    f_lg(3, "◆",  cDbl,    "Double  ·  triple top / bottom")
    f_lg(4, "◆",  cTri,    "Ascending · descending · SYMMETRIC triangle")
    f_lg(5, "◆",  cWedge,  "Rising · falling wedge  ·  and their BROADENING (diverging) cousins")
    f_lg(6, "◆",  cRect,   "Rectangle")
    f_lg(7, "◆",  cBroad,  "Broadening formation  ·  right-angled broadening (asc / desc)")
    f_lg(8, "▒",  cNeut,   "AMBER = BILATERAL. Both boundaries are armed; the BREAK picks the side")
    f_lg(9, "┈",  colBull, "A boundary. The pattern is not a trade until price closes through one")
    f_lg(10, "▲▼", colBull, "TRIGGERED — entry, stop and target are drawn")
    f_lg(11, "R",  colBull, "The pattern's OWN record: expectancy vs an unconditional control")
    f_lg(12, "MM", colBull, "Measured move — and how often it has ACTUALLY been reached")
    f_lg(13, "✓",  colBull, "Proven: t > 1.96 against the control. Most patterns will not be")
    f_lg(14, "!",  colWarn, "Patterns are rare. Treat any sample below ~30 as provisional")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
// Same rule as above: no tuple out of a ternary. Call with a valid index, then null it out.
int xId = eId >= 0 ? eId : 0
[xe0, xc0, xn0, xt0] = f_patStat(xId)
float xe = eId >= 0 ? xe0 : na
float xc = eId >= 0 ? xc0 : na
int   xn = eId >= 0 ? xn0 : 0
color exC = color.new(color.gray, 100)
plot(sm,                              "EXP_Smooth",         exC, display = display.data_window, offset = -kW)
plot(eId,                             "EXP_Pattern",        exC, display = display.data_window)
plot(eDir,                            "EXP_Dir",            exC, display = display.data_window)
plot(firedNow ? 1 : 0,                "EXP_Trigger",        exC, display = display.data_window)
plot(eEn,                             "EXP_Entry",          exC, display = display.data_window)
plot(eSt,                             "EXP_Stop",           exC, display = display.data_window)
plot(eTg,                             "EXP_Target",         exC, display = display.data_window)
plot(eRR,                             "EXP_RR",             exC, display = display.data_window)
plot(na(xe) or na(xc) ? na : xe - xc, "EXP_PatternEdge",    exC, display = display.data_window)
plot(eId >= 0 ? f_mmRate(eId) : na,   "EXP_TargetHitRate",  exC, display = display.data_window)
plot(eId >= 0 ? f_mmDist(eId) : na,   "EXP_TargetDistR",    exC, display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(firedNow and eDir == 1,  "Bullish pattern triggered", "Chart Patterns: a bullish pattern broke its neckline — entry, stop and target are on the chart (context, not advice)")
alertcondition(firedNow and eDir == -1, "Bearish pattern triggered", "Chart Patterns: a bearish pattern broke its neckline — entry, stop and target are on the chart (context, not advice)")
alertcondition(firedNow, "Any pattern triggered", "Chart Patterns: a pattern triggered (context, not advice)")
````
