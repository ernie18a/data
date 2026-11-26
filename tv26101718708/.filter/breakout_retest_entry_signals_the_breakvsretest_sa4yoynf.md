# Breakout & Retest  Entry Signals & the Break-vs-Retest

- url: https://www.tradingview.com/script/SA4YoyNF-Breakout-Retest-Entry-Signals-the-Break-vs-Retest/
- type: indicator
- pine_id: PUB;3e23400e29684f1c9e86229471f24b87
- version: 2.0

## Description

OVERVIEW
 
"Wait for the retest" is the most repeated piece of advice in breakout trading. It is also, as far as I can tell, completely untested by the people who repeat it.
 
This tool settles it — on your instrument, with your settings — by taking BOTH entries on the SAME breaks and grading them against the same control:
 
     PER-TRADE EDGE                   expectancy      vs control · n
     Break entry                        +0.09R        +0.02R · n=412
       Retest — CLEAN                   +0.31R        +0.02R · n=118
       Retest — DEEP                    -0.04R        +0.02R · n=76
       clean vs deep (t)                 3.41         CLEAN IS BETTER
 
     BUT — HOW OFTEN DO YOU GET IT?
     Breaks that ever retested          47.0%   (194/412)
       after a run of >3 closes         31.2%  vs  55.8% otherwise
     False-break rate                   13.3%
 
     EXPECTED VALUE PER BREAK
     Take every break                   +0.09R   (100% of breaks)
     Wait for the retest                +0.06R   (47% of breaks)
     VERDICT                            NO DIFFERENCE — pick either
 
That last block is the entire point. A better per-trade edge is worthless if you only get the trade half the time — so the WAIT policy is scored as P(retest) x E[R | retest], because on every break that never retests you get NOTHING. The two are then compared with a significance test, and the verdict is allowed to be "no difference".
 
It is a research and framing tool. NOT a strategy, NOT a signal service, NOT a validated edge.
 
 
WHAT IT ALREADY FOUND — measured live on NIFTY futures
 
     timeframe     breaks     retested     false breaks     verdict
     1m              334        49.4%         29.6%         NO DIFFERENCE
     3m              323        53.3%         13.6%         NO DIFFERENCE
     5m              328        53.4%         14.0%         NO DIFFERENCE
     15m             306        51.0%         12.7%         TAKE THE BREAK
     1h              274        50.0%         16.4%         NO DIFFERENCE
 
TWO THINGS JUMP OUT.
 
The retest rate is 50-53% on every timeframe. Bulkowski, measuring throwbacks across 10,348 chart patterns on US daily stocks, found 50-60%. A completely different market, a completely different method, and the same number. That is a real phenomenon, not an artefact of the detector.
 
The false-break rate is 26.5% on the 1m and 13-15% everywhere else. THE ONE-MINUTE BREAK IS TWICE AS LIKELY TO BE A LIE. That is not folklore, it is this instrument's own number, and it is exactly the kind of thing a trader should know before choosing a timeframe.
 
And the verdict, on four of the five: NO DIFFERENCE — pick either. Once the geometry is honest and the test is a real one, the great break-versus-retest argument simply does not resolve on this instrument at most speeds. On the 15m it does resolve — and it says TAKE THE BREAK, which is the opposite of what almost everyone will tell you.
 
That is what a measurement looks like. It disagrees with the folklore on one timeframe, refuses to take a side on four others, and does not care what you were hoping for. No tool that needs to sell you a signal would ever print "NO DIFFERENCE".
 
 
THE ONE THING EVERYONE GETS BACKWARDS
 
Thomas Bulkowski measured throwbacks and pullbacks across 10,348 chart patterns. His finding:
 
  "Do throwbacks hurt performance? YES: 97% of the time chart patterns with upward breakouts
   perform better post-breakout WITHOUT a throwback."
  "Do pullbacks hurt performance? YES: 91% of chart pattern types with downward breakouts
   perform better if a pullback does NOT occur."
 
Read that again. The retest is not a gift. It is a SYMPTOM — evidence that the move is weak, that supply came back, that the break did not have the strength to run.
 
And yet "wait for the retest" is good advice for a completely different reason: it gives you a better price and a tighter stop.
 
BOTH ARE TRUE AT ONCE. They are two opposing effects on the same trade, and they have never been put on one scale and netted out. That is what this script does. The retest may still win — a better entry can outweigh a weaker move — but nobody has ever checked, and the answer is different on every instrument and every timeframe.
 
 
A CLEAN RETEST AND A DEEP ONE ARE NOT THE SAME EVENT
 
Bulkowski again, and this is his sharpest single finding on the subject: during a throwback, if price REMAINS ABOVE the breakout price the subsequent rise averages 40%. If it drops BELOW the breakout price and then recovers, the rise averages 29%. That is 400 samples versus 2,767.
 
Pooling those two throws away the strongest signal in the whole idea. So they are separated:
 
  CLEAN retest — price came back and touched the level, but never CLOSED back through it.
  DEEP retest  — price CLOSED back through the level, then recovered.
 
They are graded separately, tested against each other, and labelled separately on the chart. If clean beats deep on your instrument, then "wait for the retest" is not one rule — it is two, and only one of them works.
 
 
AND CAN YOU SEE IT COMING?
 
The real, unpriced cost of a WAIT policy is that roughly half the time you never get filled. So it matters enormously whether you can predict which breaks will retest.
 
Bulkowski found that if price has more than three consecutively higher closes ending the day before the breakout, the throwback probability drops materially. So the panel reports the retest rate SPLIT BY THAT:
 
     after a run of >3 closes      31.2%  vs  55.8% otherwise
 
If the split is real on your instrument, then after a strong run into the break you should simply TAKE IT — because the retest you are waiting for is probably never coming.
 
 
IS YOUR VOLUME FILTER EARNING ITS KEEP?
 
Every trader is taught that a breakout must be confirmed by volume. Bulkowski's volume study says that after an ABOVE-average-volume breakout, FAILURES DOUBLE and the likelihood of a throwback TRIPLES, while the move itself is barely better.
 
That is testable — but only if the low-volume breaks are allowed into the sample. So VOLUME IS NOT A GATE ON THE RECORD. Every break is recorded; volume gates only the SIGNAL. The panel then reports what your filter is actually worth:
 
     Break ON volume       +0.11R    n=246
     Break OFF volume      +0.06R    n=166
       on vs off (t)        0.82     no difference — it is doing nothing
 
The record is a fact about the market. The filter is a decision about the trade. They are kept apart, and this is what happens when you stop assuming and start measuring.
 
 
IDENTICAL GEOMETRY — and why this is not a detail
 
The target used to be THE NEXT OPPOSING LEVEL. That quietly destroyed the entire experiment.
 
The BREAK entry sits PAST the level (it closed through it). The RETEST entry sits BACK AT the level. So the retest is systematically FARTHER from the next opposing level, and was therefore being handed a BIGGER R:R for the SAME RISK — on every single trade, by construction. Live, that produced an R:R of 5.0 on one timeframe and 0.66 on another, and the on-chart key was cheerfully claiming "identical geometry" while the geometry was tilted toward the retest.
 
The trade now uses a FIXED R multiple, identical for the break, the retest and the control. The next opposing level is still drawn, and still tested — separately, as a descriptive statistic, with its hit rate reported next to its distance in R.
 
 
THE ANTI-BIAS GUARDS
 
ENTRY IS THE CLOSE, for both entries and for the control. Entering the retest AT the level — a better price than the close — while the break enters at its close would hand the retest a free head start on every trade, and settle the oldest argument in trading by rigging it.
 
THE CONTROL IS DIRECTION-MATCHED. Breaks run with the trend, so a direction-skewed event set measured against a symmetric 50/50 control inherits the drift for free and calls it an edge. Longs are compared only with control longs, shorts only with control shorts, and the control is blended back using the events' OWN direction mix.
 
EVERY VERDICT IS A TEST, NOT A COMPARISON. Break-vs-wait, clean-vs-deep, volume-on-vs-off — each is a Welch t-test that has to clear |t| > 1.96 before it is allowed to be a finding. For the wait policy, the variance of P(retest) x E[R|retest] is propagated by the delta method, because it is a product of two estimates and both carry error. A verdict that flips on a tenth of an R is not a verdict, it is noise wearing a costume.
 
Both barriers on one bar: the STOP is assumed first — conservative, and the only assumption that cannot flatter the result. Unresolved trades at the horizon are marked to market, not booked as losses.
 
 
THE LEVELS
 
Levels come from the extrema of a KERNEL-SMOOTHED price series (Nadaraya-Watson) rather than raw pivots, so they track the structure rather than the noise. A break requires a CLOSE beyond the level with displacement, not a wick. A false break is one that closes back inside quickly. All of it is computed on confirmed bars; the kernel is causal and never looks forward.
 
 
NON-REPAINT
 
The kernel confirms an extremum a half-window late, so a level appears some bars AFTER the swing that created it. That lag is the price of not repainting and it is paid deliberately. Levels, breaks, false breaks, retests, signals and every calibration event are computed on CONFIRMED bars only. Nothing is drawn and then moved.
 
 
DATA AND SCOPE
 
Any symbol, any timeframe. ATR-normalised throughout. Volume improves the SIGNAL but is not required, and it never gates the RECORD.
 
 
EXPORTS (Data Window — consume from other scripts via input.source())
 
EXP_Level, EXP_Break, EXP_FalseBreak, EXP_Retest, EXP_Entry, EXP_Stop, EXP_Target, EXP_NextLevel, EXP_WaitEdge
 
 
CONCEPT CREDIT
 
Support/resistance, polarity and the breakout-retest idea are long-standing public trading concepts with no single author; the written tradition runs through Charles Dow, Richard Wyckoff and Edwards & Magee. The formal TRADING-RANGE BREAK was first tested at scale by William Brock, Josef Lakonishok and Blake LeBaron, Journal of Finance 47(5), 1992 — and their results were later shown to be vulnerable to data-snooping (Sullivan, Timmermann and White, 1999), which is exactly why this tool measures the rule on YOUR instrument rather than asserting it.
 
The throwback and pullback statistics that motivate the clean/deep split, the run-length predictor and the volume test are from Thomas Bulkowski ("Encyclopedia of Chart Patterns"; thepatternsite.com). His numbers are measured on US daily stocks. Whether they hold on YOUR instrument is precisely the question this script exists to answer — and it may well answer "no".
 
Nadaraya-Watson kernel regression — Nadaraya and Watson (1964); its use for technical pattern recognition — Lo, Mamaysky and Wang, Journal of Finance 55(4), 2000. Triple-barrier forward labelling — Marcos Lopez de Prado. Welch's t-test — B. L. Welch. ATR — J. Welles Wilder.
 
The break-vs-wait availability weighting, the delta-method significance test, the clean/deep retest split, the volume-filter test and the direction-matched control are the author's own. Clean-room implementation; no third-party Pine code is reused. Not affiliated with, nor endorsed by, any of the above.
 
 
HONESTY AND LIMITATIONS
 
Calibration is IN-SAMPLE, with no costs or slippage, and uses overlapping windows. A proven in-sample edge is NOT a guarantee out-of-sample. Real fills, spreads and commissions will reduce it — and they will hurt the break entry more than the retest entry, because the break enters into momentum.
 
Bulkowski's throwback statistics are measured on US daily stocks over decades. They are the reason the questions are asked. They are NOT the answer, and this tool will tell you so if your instrument disagrees.
 
The verdict is allowed to be "NO DIFFERENCE — pick either", and on many instruments it will be. That is a real result. A tool that cannot report its own failure is an advertisement, not a measurement.
 
Nothing in this script predicts price.
 
 
DISCLAIMER
 
Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee of results. Entry, stop and target output is arithmetic, not advice. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// BREAKOUT & RETEST — ENTRY SIGNALS, TARGETS & THE BREAK-VS-RETEST TEST                      v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Correctness: hoisted stateful ta.* calls out of conditional context so they evaluate on
//        every bar (Pine requires this for series-based functions). ta.sma in the RVOL ternary and
//        the raw-pivot calls behind the kernel/raw toggle now compute unconditionally and are masked
//        afterwards. No behavioural or output change on volume instruments; removes a latent
//        buffer-inconsistency (CW10004) that could surface on symbols with a zero-volume warm-up.
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   "Enter on the break." — "No, wait for the retest."
//   It is the oldest argument in trading, every trader has an opinion, and NOBODY HAS EVER MEASURED
//   IT. This tool ends the argument on YOUR instrument, on YOUR timeframe.
//
//   It finds levels, marks breakouts, tracks the retest that may or may not come — and then runs
//   BOTH ENTRIES ON THE SAME BREAKS, with identical geometry, against the same control. The panel
//   reports which one actually pays here.
//
//   And then it does the thing nobody thinks about, which is the real contribution:
//
//        Breaks that ever retested:   35%
//        Break entry:    +0.04R  ×  100%  =  +0.040R per break
//        Retest entry:   +0.19R  ×   35%  =  +0.067R per break
//        → waiting wins, but ONLY because the retest edge is large enough to survive
//          missing 65% of the breaks.
//
//   A better PER-TRADE edge is worthless if you only get the trade a third of the time. This tool
//   prices that trade-off explicitly. No other script does.
//
//   NOT a strategy, NOT a signal service, NOT a validated edge. A research and framing tool.
//
// WHY THESE PARTS ARE ONE TOOL  (mashup rationale)
//   A breakout without a level is meaningless. A level without a break test is just a line. A retest
//   only exists relative to a break that already happened, so the two entries are physically the same
//   event observed at two moments — you CANNOT compare them in separate scripts, because they must be
//   measured on the SAME breaks or the comparison is worthless. The false-break rate and the retest
//   RATE are what turn two per-trade numbers into an actual decision. And without the calibration,
//   the whole thing is just another opinion. That is why it is one tool.
//
// THE ENGINE
//   • LEVELS. Two sources, and the panel tests which is better. RAW PIVOTS are what every breakout
//     script uses. KERNEL EXTREMA smooth the price first (Nadaraya-Watson) and take the turning
//     points of the SHAPE — the estimator Lo, Mamaysky & Wang used in the Journal of Finance. It is
//     genuinely non-parametric machine learning, and unlike a pivot length its bandwidth means
//     something.
//   • BREAKOUT. A CLOSE beyond the level, with ATR-normalised displacement and volume confirmation.
//     A wick through a level is not a break, and a break on no volume is a rumour.
//   • FALSE BREAK. It breaks, then closes back inside within N bars. Counted and reported — because
//     the false-break rate is the number that decides whether breakouts are worth trading at all.
//   • RETEST. Price returns to the broken level and holds it — polarity: old resistance becomes
//     support. Only counted if it arrives within a window, because a "retest" thirty bars later is a
//     different trade.
//   • TARGET. The next opposing level, capped in R. That is where the move is actually going.
//
// THE CALIBRATION — AND THE TRAPS IT AVOIDS
//   • SIGNAL, NOT FILL. Both entries are taken at the CLOSE of their signal bar. Entering the retest
//     AT the level (a better price than the close) while the break enters at its close would hand the
//     retest a free head start on every trade and settle the argument by rigging it.
//   • THE SAME BREAKS. Retest statistics are computed ONLY on breaks that actually retested, and the
//     break statistics on ALL breaks — then the two are reconciled by the retest RATE. Comparing a
//     filtered sample with an unfiltered one and calling it a fair fight is the exact error this
//     tool exists to correct.
//   • DIRECTIONAL DRIFT. Indices drift up. Longs are compared only with control longs, shorts only
//     with control shorts, and the baseline drift is printed so you can see it.
//   • NO LOOK-AHEAD. A level is only ever broken on a bar AFTER it was confirmed.
//   Expectancy in R, not hit rate. Welch t-test — no "PROVEN" below t = 1.96. Stop assumed first when
//   both barriers touch on one bar. Expired trades marked to market.
//
// HOW TO USE
//   1. Read the BREAK-VS-RETEST table before you do anything else. It is the product.
//   2. Read the RETEST RATE next to it. If only a third of breaks retest, "always wait" means sitting
//      out two-thirds of the moves — and the expected-value row already accounts for that.
//   3. Read the FALSE-BREAK RATE. If half the breaks fail here, breakouts are not your edge.
//   4. Entry / stop / target are drawn for whichever entry is live. Arithmetic, not advice.
//
// DATA / SCOPE
//   Any symbol, any timeframe. ATR-normalised. Volume improves the break filter but is not required —
//   without it the volume condition neutralises and the panel says so.
//
// NON-REPAINT
//   Levels, breaks, false breaks, retests and every calibration event are computed on CONFIRMED bars.
//   Pivots resolve after their confirmation bars; kernel extrema resolve one half-window late. Both
//   lags are the honest cost of not repainting, and both are paid on purpose.
//
// EXPORTS
//   EXP_Level · EXP_Break · EXP_FalseBreak · EXP_Retest · EXP_Entry · EXP_Stop · EXP_Target ·
//   EXP_RR · EXP_RetestRate · EXP_EVWait
//
// CONCEPT CREDIT
//   Breakouts, retests and polarity (old resistance becoming support) are long-standing public
//   trading concepts with no single author; the written tradition runs through Charles Dow, Richard
//   Wyckoff and Edwards & Magee. Kernel-regression location of structural turning points — Andrew W.
//   Lo, Harry Mamaysky and Jiang Wang, "Foundations of Technical Analysis," Journal of Finance 55(4),
//   2000. Nadaraya-Watson estimator — E. A. Nadaraya and G. S. Watson. Triple-barrier forward
//   labelling — Marcos López de Prado. Welch's t-test — B. L. Welch. ATR — J. Welles Wilder.
//   The paired break/retest harness, the retest-rate reconciliation and the expected-value-of-waiting
//   calculation are the author's own. Clean-room implementation; no third-party Pine code is reused.
//
// HONESTY / LIMITATIONS
//   Calibration is IN-SAMPLE, with no costs or slippage, and uses overlapping windows. A proven
//   in-sample edge is NOT a guarantee out-of-sample — and in a break-vs-retest comparison, COSTS
//   MATTER ASYMMETRICALLY: the retest usually offers a tighter stop, so it survives costs better,
//   which this tool does NOT model. Read the result as a lower bound on the retest's advantage.
//   Retest samples are structurally smaller than break samples — only some breaks retest — so the
//   retest's t-statistic will be slower to clear 1.96 even when its edge is real. Be patient with it.
//   The answer will differ by instrument and timeframe. That is not a flaw; it is the finding.
//   Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee
//   of results. Entry/stop/target output is arithmetic, not advice. Trading carries risk of loss.
//   Test out-of-sample and make your own decisions. The author accepts no liability for any use.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Breakout & Retest — Entry Signals, Targets & the Break-vs-Retest Test", "Breakout",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500,
     max_bars_back = 3000)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g1 = "01 · Levels"
g2 = "02 · The breakout"
g3 = "03 · The retest"
g4 = "04 · The trade"
g5 = "05 · Calibration (break or retest?)"
g6 = "06 · Drawing"
g7 = "07 · Dashboard & theme"

srcMode  = input.string("Kernel extrema", "Level source", options = ["Kernel extrema", "Raw pivots"], group = g1, tooltip = "RAW PIVOTS are what every breakout script uses. KERNEL EXTREMA smooth the price first (Nadaraya-Watson) and take the turning points of the SHAPE — the method Lo, Mamaysky & Wang used in the Journal of Finance. Its bandwidth has a principled meaning; a pivot length does not.")
kW       = input.int(16, "Kernel half-window", minval = 4, maxval = 80, group = g1, tooltip = "Also the lag: a kernel extremum cannot be confirmed until the window has passed. The honest cost of not repainting.")
kH       = input.float(7.0, "Kernel bandwidth", minval = 1.0, maxval = 50.0, step = 0.5, group = g1)
pivLen   = input.int(10, "Swing length (raw pivots)", minval = 2, maxval = 60, group = g1)
maxLv    = input.int(12, "Max levels kept", minval = 2, maxval = 40, group = g1)
clusterA = input.float(0.4, "Cluster tolerance (×ATR)", minval = 0.05, maxval = 3.0, step = 0.05, group = g1)

brkDisp  = input.float(0.5, "Break needs displacement (×ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = g2, tooltip = "How far beyond the level the close must be. A close one tick through is not a break.")
brkVol   = input.float(1.2, "SIGNAL needs RVOL above", minval = 0.0, maxval = 5.0, step = 0.1, group = g2, tooltip = "A break on no volume is a rumour. Set to 0 to disable.")
fbBars   = input.int(5, "False break if it closes back inside within (bars)", minval = 1, maxval = 50, group = g2, tooltip = "The false-break rate is the number that decides whether breakouts are worth trading here at all.")

rtBars   = input.int(20, "Retest must arrive within (bars)", minval = 2, maxval = 100, group = g3, tooltip = "A 'retest' thirty bars later is a different trade. This window is what makes the comparison meaningful.")
rtTolA   = input.float(0.3, "Retest tolerance (×ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = g3, tooltip = "How close price must come back to the broken level to count as a retest.")
rtHold   = input.bool(true, "Retest must HOLD (close back on the break side)", group = g3, tooltip = "Polarity: old resistance becomes support. Without this you are marking failures, not retests.")

stopA    = input.float(1.0, "Stop (×ATR)", minval = 0.2, maxval = 6.0, step = 0.1, group = g4, tooltip = "IDENTICAL for both entries, so the comparison is fair. In reality the retest usually allows a tighter stop — which means this test UNDERSTATES the retest's advantage.")
tgtR     = input.float(2.0, "Trade target (R multiple)", minval = 0.5, maxval = 10.0, step = 0.5, group = g4, tooltip = "FIXED, and this is not a detail — it is the whole experiment.\n\nThe target used to be THE NEXT OPPOSING LEVEL. But the BREAK entry sits PAST the level (it closed through it) while the RETEST entry sits BACK AT the level — so the retest is systematically FARTHER from the next opposing level and was being handed a BIGGER R:R for the SAME RISK, on every single trade. Live, that produced an R:R of 5.0 on one timeframe and 0.66 on another.\n\nThe script's entire thesis is 'break vs retest, measured fairly'. The geometry was tilted toward the retest BY CONSTRUCTION. A fixed R multiple, identical for the break, the retest and the control, is the only way the comparison means anything.\n\nThe next opposing level is still drawn, and still tested — separately, as a descriptive statistic.")
showNL   = input.bool(true, "Draw & test the next-level target", group = g4, tooltip = "Where the trade is actually going. Drawn, and its hit rate measured — reported NEXT TO its distance in R, because a hit rate with no distance attached is a fact about the distance, not about the levels.")

calibOn  = input.bool(true, "Run the break-vs-retest test", group = g5)
calHor   = input.int(40, "Grading horizon (bars)", minval = 5, maxval = 300, group = g5)
calMinN  = input.int(15, "Min sample before rating", minval = 5, maxval = 300, group = g5)
ctlEvery = input.int(15, "Control sample every N bars", minval = 3, maxval = 200, group = g5)

showLv   = input.bool(true, "Draw levels", group = g6)
showBrk  = input.bool(true, "Mark breaks / false breaks / retests", group = g6)
mkText   = input.bool(false, "     ...with text labels", group = g6, tooltip = "OFF by default, and that is deliberate. The SHAPES already say it — a triangle is a break, a circle is a retest, and the circle sits ON the level it tested. The level's own chip then says BROKEN or RETESTED (clean). Adding the words BREAK and RETEST on top of that is a third label for a fact already stated twice, and on any busy chart the two words print straight through each other.")
showSetup= input.bool(true, "Draw entry / stop / target", group = g6)
showSm   = input.bool(false, "Plot the kernel smoother", group = g6)
lineW    = input.int(2, "Line width", minval = 1, maxval = 6, group = g6)
colUp    = input.color(#26a69a, "Bullish", inline = "c", group = g6)
colDn    = input.color(#ef5350, "Bearish", inline = "c", group = g6)
colFalse = input.color(#ffa726, "False break", inline = "c", group = g6)
lblSize  = input.string("Small", "Label size", options = ["Tiny","Small","Normal"], group = g6)

showPanel= input.bool(true, "Show dashboard", group = g7)
panelMode= input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g7, tooltip = "Pro shows the expected-value-of-waiting table — the whole point of the tool.")
panelPos = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g7)
legendPos= input.string("Bottom Right", "Legend position", options = ["Bottom Right","Bottom Left","Middle Left","Top Left"], group = g7, tooltip = "TradingView's own watermark sits bottom-LEFT and will clip a legend placed there.")
showLegend=input.bool(false, "Show legend / key", group = g7, tooltip = "OFF by default — you learn the symbols once, and it costs chart space on every bar after that.")
lblNear  = input.int(4, "Label only the N nearest levels", minval = 1, maxval = 20, group = g6, tooltip = "Ten chips stacked at the right edge, overlapping each other and clipped by the key, is not information. The distant levels are still drawn, still tested and still counted — they just stop shouting.")
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g7)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          TYPES
// ═════════════════════════════════════════════════════════════════════════════════════════
type Lvl
    float px
    int   bi
    bool  broken
    int   brkBar
    int   brkDir        // +1 = broken upward · -1 = broken downward
    bool  falsed
    bool  retested
    // ── THE QUALITY OF THE RETEST ──
    // Bulkowski, on 10,348 patterns: during a throwback, if price stays ABOVE the breakout price the
    // subsequent rise averages 40%; if it drops BELOW it, 29% (400 vs 2,767 samples). Those are not
    // the same event, and pooling them throws away the single strongest signal in the whole idea.
    bool  deep          // did price CLOSE back through the level before retesting?
    int   runLen        // consecutive closes in the break direction IMMEDIATELY BEFORE the break.
                        // Bulkowski: >3 of them and the throwback probability drops materially. This
                        // is the only thing that predicts whether you will EVER GET FILLED on a
                        // "wait for the retest" plan — and being unfilled is that plan's real cost.
    bool  volOK         // was the break on above-threshold volume? (recorded, NOT used to gate)
    int   nHit          // candidates merged in — this is what keeps px STABLE (see f_addLvl)
    line  ln
    label lb

type Trade
    int   bi
    float entry
    float stop
    float tgt
    int   dir
    // 1/2 = BREAK L/S · 3/4 = RETEST-CLEAN L/S · 5/6 = RETEST-DEEP L/S · 7/8 = control L/S
    // 9/10 = break on HIGH volume L/S · 11/12 = break on LOW volume L/S
    int   bucket
    float rr

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          THE KERNEL  (Nadaraya-Watson — shared engine)
// ═════════════════════════════════════════════════════════════════════════════════════════
float atr    = ta.atr(14)
bool  hasVol = ta.cum(nz(volume)) > 0
// STATEFUL HOIST: ta.sma is stateful and must run every bar; inside the `hasVol ?` ternary it was
// skipped while cumulative volume was still zero, corrupting the average. Compute unconditionally, then mask.
float volSma = ta.sma(nz(volume), 20)
float rvol   = hasVol ? nz(volume) / math.max(volSma, 1e-9) : 1.0

bool useKer = srcMode == "Kernel extrema"

f_nw() =>
    float num = 0.0
    float den = 0.0
    for j = 0 to 2 * kW
        float z = (j - kW) / kH
        float k = math.exp(-0.5 * z * z)
        num += k * close[j]
        den += k
    den > 0 ? num / den : na

// f_nw() reads history, so it must be called on EVERY bar or its history buffer goes inconsistent.
float smRaw = f_nw()
float sm = (useKer and bar_index >= 2 * kW) ? smRaw : na
bool kMax = not na(sm) and not na(sm[1]) and not na(sm[2]) and sm[1] > sm[2] and sm[1] > sm
bool kMin = not na(sm) and not na(sm[1]) and not na(sm[2]) and sm[1] < sm[2] and sm[1] < sm

// STATEFUL HOIST (defensive): the raw pivots are computed every bar so the buffer stays consistent
// regardless of the kernel/raw toggle. `useKer` is a constant input so this was benign, but hoisting
// clears CW10004 and keeps the script within the house "no conditional ta.*" standard.
float rawPH = ta.pivothigh(high, pivLen, pivLen)
float rawPL = ta.pivotlow(low, pivLen, pivLen)
float ph = useKer ? (kMax ? high[kW + 1] : na) : rawPH
float pl = useKer ? (kMin ? low[kW + 1]  : na) : rawPL

// ═════════════════════════════════════════════════════════════════════════════════════════
//   STATE — arrays are mutated ONLY on confirmed bars (Pine rolls back `var` scalars between
//   intrabar ticks but NOT array contents). And every `for i = 0 to array.size(a)-1` is
//   size-guarded, because on an empty array that becomes `for i = 0 to -1`, which Pine runs
//   DOWNWARD with i = 0 and throws.
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<Lvl>   lvls = array.new<Lvl>()
var array<Trade> pend = array.new<Trade>()
var array<int>   bN  = array.new<int>(13, 0)
var array<float> bR  = array.new<float>(13, 0.0)
var array<float> bR2 = array.new<float>(13, 0.0)
var int nBreaks  = 0        // every confirmed break
var int nFalse   = 0        // ... that closed back inside
var int nRetest  = 0        // ... that produced a retest

f_addLvl(float px) =>
    float tol = clusterA * atr
    // Search ALL levels — broken ones included. A new extremum forming at a price a broken level
    // already occupies is not a NEW level, it IS that level being retested. Only matching unbroken
    // ones spawned a duplicate a few ticks from the original, and the chart then drew both, one on
    // top of the other. (Live: "FALSE BREAK 24086" buried under "RETESTED (clean) 24080.50".)
    int hit = -1
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            if math.abs(array.get(lvls, i).px - px) <= tol
                hit := i
                break
    if hit >= 0
        Lvl l = array.get(lvls, hit)
        // A BROKEN level is FROZEN. Its price is history — the break happened AT that price, and the
        // retest is measured against it. Moving it now would rewrite the event after the fact.
        if not l.broken
            // COUNT-WEIGHTED MEAN, not a halfway split. `px := (px + new)/2` drags the level halfway
            // to every new candidate — and candidates appear near PRICE, so the level slides toward
            // price until it is no longer an anchor but a trailing average. The tenth candidate should
            // move it a tenth of the way, not half. (Also: `bi` is the bar it was BORN on. Overwriting
            // it moved the drawn line's left anchor forward every time the level was touched.)
            l.nHit += 1
            l.px   := l.px + (px - l.px) / l.nHit
    else
        // EXPLICIT DEFAULTS. Inserting `deep`, `runLen` and `volOK` into the type silently re-aimed
        // the two trailing `na`s at them instead of at ln/lb — leaving `deep` as na rather than false.
        // It happened to be harmless (both are written at break time before they are ever read), but
        // it is exactly the kind of quiet mis-mapping that bites on the next edit. Name every field.
        array.push(lvls, Lvl.new(px, bar_index, false, -1, 0, false, false, false, 0, false, 1, na, na))
    // EVICT THE FURTHEST, not the oldest. `array.shift` drops index 0 — and a level does not stop
    // mattering because it is old. What makes a level irrelevant is DISTANCE from where price is now.
    while array.size(lvls) > maxLv
        int   worst = 0
        float wD    = -1.0
        for i = 0 to array.size(lvls) - 1
            float d = math.abs(array.get(lvls, i).px - close)
            if d > wD
                worst := i
                wD    := d
        Lvl o = array.remove(lvls, worst)
        line.delete(o.ln)
        label.delete(o.lb)

if barstate.isconfirmed and atr > 0
    if not na(ph)
        f_addLvl(ph)
    if not na(pl)
        f_addLvl(pl)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   BREAKS · FALSE BREAKS · RETESTS
// ═════════════════════════════════════════════════════════════════════════════════════════
bool brokeNow  = false
bool falsedNow = false
bool retestNow = false
bool rtDeepNow = false
int  evDir = 0
float evLvl = na

// how many consecutive closes ran in the break's direction, immediately before it?
// Bulkowski: more than three of them, and the throwback probability drops materially. It is the only
// thing that predicts whether a "wait for the retest" plan will EVER GET FILLED — and not getting
// filled is that plan's real, unpriced cost.
var int runUp = 0
var int runDn = 0
if barstate.isconfirmed
    runUp := close > close[1] ? runUp + 1 : 0
    runDn := close < close[1] ? runDn + 1 : 0

var int nBrkRun   = 0      // breaks that arrived on a run of >3
var int nRetRun   = 0      // ...of which retested
var int nBrkNoRun = 0
var int nRetNoRun = 0

if barstate.isconfirmed and array.size(lvls) > 0 and atr > 0
    for i = 0 to array.size(lvls) - 1
        Lvl l = array.get(lvls, i)
        // ── THE BREAK: a CLOSE beyond the level, with displacement ──
        // VOLUME IS NOT A GATE ON THE RECORD. It never was allowed to be. Bulkowski's volume study
        // finds that after an above-average-volume breakout, FAILURES DOUBLE and the likelihood of a
        // throwback TRIPLES, while the move itself is barely better — the exact opposite of what
        // every trader is taught. If volume gates DETECTION, the low-volume breaks never enter the
        // sample and that claim can never be tested. So every break is RECORDED; volume gates only
        // the SIGNAL, and the panel then reports whether the filter is earning its keep.
        if not l.broken and bar_index > l.bi
            bool upBrk = close > l.px + brkDisp * atr and close[1] <= l.px
            bool dnBrk = close < l.px - brkDisp * atr and close[1] >= l.px
            if upBrk or dnBrk
                l.broken := true
                l.brkBar := bar_index
                l.brkDir := upBrk ? 1 : -1
                l.volOK  := brkVol <= 0 or not hasVol or rvol >= brkVol
                l.runLen := upBrk ? runUp : runDn
                l.deep   := false
                nBreaks += 1
                brokeNow := true
                evDir := l.brkDir
                evLvl := l.px
                if l.runLen > 3
                    nBrkRun += 1
                else
                    nBrkNoRun += 1
        else if l.broken and not l.falsed and not l.retested
            int age = bar_index - l.brkBar
            bool backThrough = (l.brkDir == 1 and close < l.px) or (l.brkDir == -1 and close > l.px)
            // ── THE FALSE BREAK: it closed back inside, QUICKLY ──
            if age <= fbBars and backThrough
                l.falsed := true
                nFalse += 1
                falsedNow := true
            else
                // ── A DEEP RETEST IN PROGRESS ──
                // Closing back through the level AFTER the false-break window is not a failure. It is
                // a retest that went too far, and Bulkowski's numbers say that is a materially worse
                // animal than one that holds above the line. Remember it, and grade it separately.
                if age > fbBars and backThrough
                    l.deep := true
                bool touchUp = l.brkDir ==  1 and math.abs(low  - l.px) <= rtTolA * atr and (not rtHold or close > l.px)
                bool touchDn = l.brkDir == -1 and math.abs(high - l.px) <= rtTolA * atr and (not rtHold or close < l.px)
                if age >= 1 and age <= rtBars and (touchUp or touchDn)
                    l.retested := true
                    nRetest += 1
                    retestNow := true
                    rtDeepNow := l.deep
                    evDir := l.brkDir
                    evLvl := l.px
                    if l.runLen > 3
                        nRetRun += 1
                    else
                        nRetNoRun += 1

// ═════════════════════════════════════════════════════════════════════════════════════════
//   THE TRADE  —  target is the next opposing level
// ═════════════════════════════════════════════════════════════════════════════════════════
f_nextLvl(int dir, float from) =>
    float best = na
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl l = array.get(lvls, i)
            if not l.broken
                if dir == 1 and l.px > from and (na(best) or l.px < best)
                    best := l.px
                if dir == -1 and l.px < from and (na(best) or l.px > best)
                    best := l.px
    best

var float eEn  = na
var float eSt  = na
var float eTg  = na
var float eNL  = na
var float eNLR = na
var int   eDir = 0
var int   eBar = -1000
var string eSrc = ""
var bool  eOpen = false
var int   eRes  = 0
var array<Trade> pendNL = array.new<Trade>()
// the next-level target, per entry type: reached / attempted / how far away in R.  1 = break · 2 = retest
var array<int>   nlH = array.new<int>(3, 0)
var array<int>   nlN = array.new<int>(3, 0)
var array<float> nlR = array.new<float>(3, 0.0)

if barstate.isconfirmed and (brokeNow or retestNow) and atr > 0
    // ENTRY IS THE CLOSE for BOTH. Entering the retest AT the level (a better price than the close)
    // while the break enters at its close would hand the retest a free head start on every trade —
    // and settle the oldest argument in trading by rigging it.
    float en   = close
    float risk = stopA * atr
    float st   = evDir == 1 ? en - risk : en + risk
    // ══ IDENTICAL GEOMETRY — A FIXED R MULTIPLE, THE SAME ONE THE CONTROL USES ══
    // The target used to be the NEXT OPPOSING LEVEL. But the BREAK entry sits PAST the level and the
    // RETEST entry sits BACK AT it, so the retest was systematically FARTHER from that next level and
    // was handed a BIGGER R:R for the SAME RISK — on every trade, by construction. Live it produced
    // R:R 5.0 on one timeframe and 0.66 on another. The script's whole claim is that the two entries
    // are measured fairly. They were not. They are now.
    float tg = evDir == 1 ? en + tgtR * risk : en - tgtR * risk
    eEn  := en
    eSt  := st
    eTg  := tg
    eDir := evDir
    eBar := bar_index
    eOpen := true
    eRes  := 0
    eSrc := retestNow ? (rtDeepNow ? "Retest (deep)" : "Retest (clean)") : "Break"
    // the NEXT OPPOSING LEVEL is a different question, so it gets its own tracker
    float nl = f_nextLvl(evDir, en)
    eNL  := nl
    eNLR := na(nl) ? na : math.abs(nl - en) / risk
    if calibOn
        int grp = retestNow ? 2 : 1
        // the trade itself, split by direction so the control can be matched to it
        int b = retestNow ? (rtDeepNow ? 5 : 3) : 1
        array.push(pend, Trade.new(bar_index, en, st, tg, evDir, b + (evDir == 1 ? 0 : 1), tgtR))
        // ...and, for a BREAK, a SECOND view of the same trade: was it on volume, or not?
        // This is what makes Bulkowski's volume claim testable instead of assumed.
        if brokeNow
            int vb = (rvol >= brkVol and hasVol) ? 9 : 11
            array.push(pend, Trade.new(bar_index, en, st, tg, evDir, vb + (evDir == 1 ? 0 : 1), tgtR))
        if not na(nl)
            array.push(pendNL, Trade.new(bar_index, en, st, nl, evDir, grp, math.abs(nl - en) / risk))

// the setup is a TRADE, and a trade ENDS. `(bar_index - eBar) < 120` was elapsed time, not a trade.
if barstate.isconfirmed and eOpen and not na(eEn) and bar_index > eBar
    bool tHit = eDir == 1 ? high >= eTg : low  <= eTg
    bool sHit = eDir == 1 ? low  <= eSt : high >= eSt
    if sHit
        eOpen := false
        eRes  := -1
    else if tHit
        eOpen := false
        eRes  := 1
    else if bar_index - eBar >= calHor
        eOpen := false
        eRes  := 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//   CALIBRATION  —  direction-matched control, identical geometry
// ═════════════════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and calibOn and atr > 0 and bar_index % ctlEvery == 0
    float risk = stopA * atr
    array.push(pend, Trade.new(bar_index, close, close - risk, close + tgtR * risk,  1, 7, tgtR))
    array.push(pend, Trade.new(bar_index, close, close + risk, close - tgtR * risk, -1, 8, tgtR))

if barstate.isconfirmed and array.size(pend) > 0
    int i = 0
    while i < array.size(pend)
        Trade t = array.get(pend, i)
        bool hitT = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitT or hitS or expd)
            // both barriers on one bar → the STOP is assumed first: conservative, and the only
            // assumption that cannot flatter the result.
            float risk = math.abs(t.entry - t.stop)
            // expired trades are MARKED TO MARKET — an unresolved trade is neither a win nor a loss.
            float rOut = hitS ? -1.0 : hitT ? t.rr : (risk > 0 ? (close - t.entry) * t.dir / risk : 0.0)
            array.set(bN,  t.bucket, array.get(bN,  t.bucket) + 1)
            array.set(bR,  t.bucket, array.get(bR,  t.bucket) + rOut)
            array.set(bR2, t.bucket, array.get(bR2, t.bucket) + rOut * rOut)
            array.remove(pend, i)
        else
            i += 1

if barstate.isconfirmed and array.size(pendNL) > 0
    int i = 0
    while i < array.size(pendNL)
        Trade t = array.get(pendNL, i)
        bool hitL = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitL or hitS or expd)
            array.set(nlN, t.bucket, array.get(nlN, t.bucket) + 1)
            array.set(nlH, t.bucket, array.get(nlH, t.bucket) + ((hitL and not hitS) ? 1 : 0))
            array.set(nlR, t.bucket, array.get(nlR, t.bucket) + t.rr)
            array.remove(pendNL, i)
        else
            i += 1

f_n(int ix) => array.get(bN, ix)
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

// ── A GROUP vs A CONTROL BLENDED TO MATCH ITS OWN DIRECTION MIX ──
// The control used to be a flat 50/50. But breaks are not 50/50 — in a trend they run with it, so a
// direction-skewed event set measured against a symmetric control inherits the drift for free and
// calls it edge. Longs are compared only with control longs, shorts only with control shorts, and
// the control is then rebuilt to the EVENTS' OWN mix.  Returns [mean, control, n, variance, t].
f_grp(int base) =>
    int nL = f_n(base)
    int nS = f_n(base + 1)
    int nE = nL + nS
    if nE < 2
        [float(na), float(na), nE, float(na), float(na)]
    else
        float sR  = array.get(bR, base)  + array.get(bR, base + 1)
        float sR2 = array.get(bR2, base) + array.get(bR2, base + 1)
        float mE  = sR / nE
        float vE  = math.max(sR2 / nE - mE * mE, 0.0)
        float seE = math.sqrt(vE / nE)
        float wL  = nL / float(nE)
        float wS  = nS / float(nE)
        float mCL = f_exp(7)
        float mCS = f_exp(8)
        float mC  = (na(mCL) ? 0.0 : wL * mCL) + (na(mCS) ? 0.0 : wS * mCS)
        float vCL = f_var(7)
        float vCS = f_var(8)
        int   nCL = f_n(7)
        int   nCS = f_n(8)
        float seC = math.sqrt((nCL > 1 and not na(vCL) ? wL * wL * vCL / nCL : 0.0) + (nCS > 1 and not na(vCS) ? wS * wS * vCS / nCS : 0.0))
        float se  = math.sqrt(seE * seE + seC * seC)
        [mE, mC, nE, vE, se > 0 ? (mE - mC) / se : na]

// pool the two retest kinds into one "any retest" group
f_grpRetest() =>
    int nE = f_n(3) + f_n(4) + f_n(5) + f_n(6)
    if nE < 2
        [float(na), nE, float(na)]
    else
        float sR  = array.get(bR, 3)  + array.get(bR, 4)  + array.get(bR, 5)  + array.get(bR, 6)
        float sR2 = array.get(bR2, 3) + array.get(bR2, 4) + array.get(bR2, 5) + array.get(bR2, 6)
        float mE  = sR / nE
        float vE  = math.max(sR2 / nE - mE * mE, 0.0)
        [mE, nE, vE]

[expBrk,  ctlBrk,  nBrk,  varBrk,  tBrk]  = f_grp(1)
[expRtC,  ctlRtC,  nRtC,  varRtC,  tRtC]  = f_grp(3)    // CLEAN retest
[expRtD,  ctlRtD,  nRtD,  varRtD,  tRtD]  = f_grp(5)    // DEEP  retest
[expVolY, ctlVolY, nVolY, varVolY, tVolY] = f_grp(9)    // break ON volume
[expVolN, ctlVolN, nVolN, varVolN, tVolN] = f_grp(11)   // break OFF volume
[expRt, nRt, varRt] = f_grpRetest()                     // any retest

bool provBrk = not na(tBrk) and nBrk >= calMinN and tBrk > 1.96
float driftL = f_exp(7)
float driftS = f_exp(8)

// ── THE NUMBERS THAT TURN TWO EDGES INTO A DECISION ──
float rtRate = nBreaks > 0 ? nRetest / float(nBreaks) : na
float fbRate = nBreaks > 0 ? nFalse  / float(nBreaks) : na

// ══ BREAK vs WAIT-FOR-THE-RETEST — the whole point of the script ══
// A better PER-TRADE edge is worthless if you only get the trade half the time. If you WAIT, then on
// every break that never retests you get NOTHING — so the honest expectation of the WAIT policy is
//        EV(wait) = P(retest) · E[R | retest]
// and that is what must be compared against E[R | break], which you always get.
//
// AND IT NEEDS A SIGNIFICANCE TEST, not a bare `>`. Live, the verdict flipped across timeframes on
// differences of a tenth of an R — reporting sampling noise as a decision, which is the one sin this
// codebase exists to avoid. The variance of a PRODUCT of two estimates comes from the delta method:
//        Var(p·m) ≈ p²·Var(m) + m²·Var(p),      Var(p) = p(1−p)/n
float evBreak = expBrk
float evWait  = (na(expRt) or na(rtRate)) ? na : expRt * rtRate
float vP      = nBreaks > 1 and not na(rtRate) ? rtRate * (1.0 - rtRate) / nBreaks : na
float vWait   = (na(evWait) or na(varRt) or nRt < 2 or na(vP)) ? na : rtRate * rtRate * (varRt / nRt) + expRt * expRt * vP
float vBreak  = (na(varBrk) or nBrk < 2) ? na : varBrk / nBrk
float seBW    = (na(vWait) or na(vBreak)) ? na : math.sqrt(vWait + vBreak)
float tBW     = (na(seBW) or seBW <= 0 or na(evWait) or na(evBreak)) ? na : (evWait - evBreak) / seBW
bool  warmBW  = nBrk < calMinN or nRt < calMinN
// +1 = WAIT wins · -1 = TAKE THE BREAK · 0 = the data cannot separate them
int   bwV = (warmBW or na(tBW)) ? 0 : tBW > 1.96 ? 1 : tBW < -1.96 ? -1 : 0
string bwTxt = not calibOn ? "off" : warmBW ? "warming (" + str.tostring(math.min(nBrk, nRt)) + "/" + str.tostring(calMinN) + ")" : bwV == 1 ? "WAIT FOR THE RETEST" : bwV == -1 ? "TAKE THE BREAK" : "NO DIFFERENCE — pick either"

// ── CLEAN vs DEEP retest, head to head (Bulkowski's strongest single claim) ──
float seCD = (nRtC > 1 and nRtD > 1 and not na(varRtC) and not na(varRtD)) ? math.sqrt(varRtC / nRtC + varRtD / nRtD) : na
float tCD  = (na(seCD) or seCD <= 0 or na(expRtC) or na(expRtD)) ? na : (expRtC - expRtD) / seCD
// ── DOES THE VOLUME FILTER EARN ITS KEEP? (Bulkowski says it does NOT) ──
float seV  = (nVolY > 1 and nVolN > 1 and not na(varVolY) and not na(varVolN)) ? math.sqrt(varVolY / nVolY + varVolN / nVolN) : na
float tV   = (na(seV) or seV <= 0 or na(expVolY) or na(expVolN)) ? na : (expVolY - expVolN) / seV

// ── WILL IT EVEN RETEST? (Bulkowski: a run of >3 closes into the break makes a throwback rarer) ──
float rtAfterRun = nBrkRun   > 0 ? nRetRun   / float(nBrkRun)   * 100.0 : na
float rtAfterFlat= nBrkNoRun > 0 ? nRetNoRun / float(nBrkNoRun) * 100.0 : na

f_nlRate(int g) =>
    int n = array.get(nlN, g)
    n > 0 ? array.get(nlH, g) / float(n) * 100.0 : na
f_nlDist(int g) =>
    int n = array.get(nlN, g)
    n > 0 ? array.get(nlR, g) / float(n) : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        THEME
// ═════════════════════════════════════════════════════════════════════════════════════════
// Pine's "+#.00" format treats the '+' as a LITERAL character, so -0.25 renders as "-+.25". Sign it
// by hand instead. (A real formatting bug the first live test caught.)
f_R(float v) => na(v) ? "-" : (v >= 0 ? "+" : "") + str.tostring(v, "#.00") + "R"

f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : s == "Middle Left" ? position.middle_left : position.top_right
f_lblSize() => lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small

bool darkUI   = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(showSm and useKer ? sm : na, "Kernel smoother", color.new(#ab47bc, 30), 1, offset = -kW)

plotshape(showBrk and mkText and brokeNow and evDir == 1,  "Break up (text)",   shape.triangleup,   location.belowbar, colUp, text = "BREAK", textcolor = color.white, size = size.tiny)
plotshape(showBrk and mkText and brokeNow and evDir == -1, "Break down (text)", shape.triangledown, location.abovebar, colDn, text = "BREAK", textcolor = color.white, size = size.tiny)
plotshape(showBrk and not mkText and brokeNow and evDir == 1,  "Break up",   shape.triangleup,   location.belowbar, colUp, size = size.tiny)
plotshape(showBrk and not mkText and brokeNow and evDir == -1, "Break down", shape.triangledown, location.abovebar, colDn, size = size.tiny)
// THE RETEST MARKER SITS ON THE LEVEL IT RETESTED, not on the bar. A break of one level and a retest
// of another can land on the SAME bar — and when both were pinned to the bar, their text labels
// printed straight through each other ("BREAK" and "RETEST" overlapping, on every chart). Putting the
// retest at the level's own price both removes the collision and says something true: THAT is the
// price being tested.
plotshape(showBrk and mkText and retestNow and evDir == 1  ? evLvl : na, "Retest up (text)",   shape.circle, location.absolute, colUp, text = "RETEST", textcolor = color.white, size = size.tiny)
plotshape(showBrk and mkText and retestNow and evDir == -1 ? evLvl : na, "Retest down (text)", shape.circle, location.absolute, colDn, text = "RETEST", textcolor = color.white, size = size.tiny)
plotshape(showBrk and not mkText and retestNow and evDir == 1  ? evLvl : na, "Retest up",   shape.circle, location.absolute, colUp, size = size.tiny)
plotshape(showBrk and not mkText and retestNow and evDir == -1 ? evLvl : na, "Retest down", shape.circle, location.absolute, colDn, size = size.tiny)
plotshape(showBrk and falsedNow, "False break", shape.xcross, location.absolute, colFalse, size = size.tiny)

// THE SETUP IS DRAWN WITH LINE OBJECTS, NOT plot().
// A plot whose value JUMPS when a new setup arms draws a vertical connector between the old level and
// the new one, then a long horizontal run of the STALE level across every bar in between.
// plot.style_linebr only breaks where the value is `na` — and a `var` float is never na once it has
// been set, so the break never happens. Those staircase rectangles marching across the chart were not
// levels and not zones. They were artifacts.
bool setupLive = showSetup and eOpen and not na(eEn)
var line sE = na
var line sS = na
var line sT = na
var line sN = na

var label lE = na
var label lS = na
var label lT = na

if barstate.islast
    // ── ONLY THE NEAREST LEVELS GET A LABEL ──
    // Ten chips stacked at the right edge, overlapping each other and clipped by the key, is not
    // information — it is wallpaper. The distant levels are still drawn, still broken, still counted;
    // they simply stop shouting. Find the label cutoff first.
    float cutoff = 1e18
    if array.size(lvls) > lblNear
        array<float> dists = array.new<float>()
        for i = 0 to array.size(lvls) - 1
            array.push(dists, math.abs(array.get(lvls, i).px - close))
        array.sort(dists, order.ascending)
        cutoff := array.get(dists, lblNear - 1)
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl l = array.get(lvls, i)
            line.delete(l.ln)
            label.delete(l.lb)
            if showLv
                color c = l.falsed ? colFalse : l.broken ? (l.brkDir == 1 ? colUp : colDn) : color.new(color.gray, 20)
                l.ln := line.new(l.bi, l.px, bar_index + 4, l.px, xloc = xloc.bar_index, color = color.new(c, l.broken ? 20 : 45), width = lineW, style = l.broken ? line.style_solid : line.style_dashed)
                if math.abs(l.px - close) <= cutoff
                    // ── STAGGER LABELS THAT SIT ON TOP OF EACH OTHER ──
                    // Levels a few points apart put their chips in the same few pixels, and the chips
                    // then print through one another. Count how many OTHER drawn levels sit within
                    // half an ATR ABOVE this one, and step this chip that many columns to the right.
                    // Deterministic, collision-free, and it costs one O(n²) pass on the last bar only.
                    int stag = 0
                    for j = 0 to array.size(lvls) - 1
                        Lvl o = array.get(lvls, j)
                        if j != i and math.abs(o.px - close) <= cutoff and o.px > l.px and (o.px - l.px) < 0.6 * atr
                            stag += 1
                    // SHORT TAGS. "RETESTED (clean) 24060.00" ran off the right margin and got its
                    // price chopped off — a label whose most important word is invisible.
                    string tag = (l.falsed ? "FALSE" : l.retested ? (l.deep ? "RETEST·deep" : "RETEST·clean") : l.broken ? "BROKE" : "level") + "  " + str.tostring(l.px, format.mintick)
                    l.lb := label.new(bar_index + 5 + stag * 22, l.px, tag, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 20), textcolor = color.white, size = f_lblSize())
    label.delete(lE)
    label.delete(lS)
    label.delete(lT)
    line.delete(sE)
    line.delete(sS)
    line.delete(sT)
    line.delete(sN)
    if setupLive
        color cS = eDir == 1 ? colDn : colUp
        color cT = eDir == 1 ? colUp : colDn
        sE := line.new(eBar, eEn, bar_index + 24, eEn, xloc = xloc.bar_index, color = color.new(color.gray, 0), width = lineW)
        sS := line.new(eBar, eSt, bar_index + 24, eSt, xloc = xloc.bar_index, color = color.new(cS, 0), width = lineW)
        sT := line.new(eBar, eTg, bar_index + 24, eTg, xloc = xloc.bar_index, color = color.new(cT, 0), width = lineW)
        int g = eSrc == "Break" ? 1 : 2
        string nlTxt = (not showNL or na(eNL)) ? "" : "   ·   next level " + str.tostring(eNL, format.mintick) + " (" + str.tostring(eNLR, "#.#") + "R" + (na(f_nlRate(g)) ? "" : ", reached " + str.tostring(f_nlRate(g), "#") + "%") + ")"
        if showNL and not na(eNL)
            sN := line.new(eBar, eNL, bar_index + 24, eNL, xloc = xloc.bar_index, color = color.new(cT, 55), width = 1, style = line.style_dashed)
        lE := label.new(bar_index + 24, eEn, "ENTRY  " + str.tostring(eEn, format.mintick) + "   " + eSrc, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.gray, 10), textcolor = color.white, size = f_lblSize())
        lS := label.new(bar_index + 24, eSt, "STOP  " + str.tostring(eSt, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cS, 10), textcolor = color.white, size = f_lblSize())
        lT := label.new(bar_index + 24, eTg, "TARGET  " + str.tostring(eTg, format.mintick) + "   " + str.tostring(tgtR, "#.#") + "R" + nlTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cT, 10), textcolor = color.white, size = f_lblSize())

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
bool isPro = panelMode == "Pro"
var table tb = table.new(f_pos(panelPos), 3, 24, frame_width = 1, border_width = 1)
f_r2(int r, string k, string v, color c, color bg) =>
    table.cell(tb, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left, bgcolor = bg)
    table.cell(tb, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
    table.cell(tb, 2, r, "", bgcolor = bg)
f_r3(int r, string k, string a, string b, color c, color bg) =>
    table.cell(tb, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left, bgcolor = bg)
    table.cell(tb, 1, r, a, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
    table.cell(tb, 2, r, b, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

if showPanel and barstate.islast
    table.set_bgcolor(tb, panelBg)
    table.set_frame_color(tb, frameC)
    table.set_border_color(tb, frameC)
    color hdrC = setupLive ? (eDir == 1 ? colUp : colDn) : color.new(color.gray, 20)
    color hdrT = f_lum(hdrC) > 140 ? color.rgb(10, 10, 10) : color.white

    table.cell(tb, 0, 0, "BREAKOUT & RETEST", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 0, str.tostring(nBreaks) + " breaks", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 2, 0, setupLive ? eSrc : (na(rtRate) ? "-" : str.tostring(rtRate * 100, "#") + "% retest"), text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)

    if isPro
        table.cell(tb, 0, 1, "PER-TRADE EDGE", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 1, "expectancy", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 1, "vs control · n", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        f_r3(2, "Break entry", na(expBrk) ? "-" : f_R(expBrk) + (provBrk ? " ✓" : ""), (na(ctlBrk) ? "-" : f_R(ctlBrk) + " · n=" + str.tostring(nBrk)), provBrk ? colUp : txtMain, rowAlt)
        f_r3(3, "  Retest — CLEAN", na(expRtC) ? "-" : f_R(expRtC), (na(ctlRtC) ? "-" : f_R(ctlRtC) + " · n=" + str.tostring(nRtC)), txtMain, panelBg)
        f_r3(4, "  Retest — DEEP", na(expRtD) ? "-" : f_R(expRtD), (na(ctlRtD) ? "-" : f_R(ctlRtD) + " · n=" + str.tostring(nRtD)), txtMain, rowAlt)
        // Bulkowski's single strongest claim about retests, and it is checkable: a throwback that
        // HOLDS above the level is a different animal from one that dips through and recovers.
        f_r2(5, "  clean vs deep (t)", na(tCD) ? "-" : str.tostring(tCD, "#.2") + (math.abs(nz(tCD, 0.0)) > 1.96 ? "   CLEAN IS BETTER" : "   (needs |t| > 1.96)"), (not na(tCD) and math.abs(tCD) > 1.96) ? colUp : txtMut, panelBg)
        table.cell(tb, 0, 6, "BUT — HOW OFTEN DO YOU GET IT?", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 6, "", bgcolor = frameC)
        table.cell(tb, 2, 6, "", bgcolor = frameC)
        f_r2(7, "Breaks that ever retested", na(rtRate) ? "-" : str.tostring(rtRate * 100, "#.0") + "%   (" + str.tostring(nRetest) + "/" + str.tostring(nBreaks) + ")", txtMain, rowAlt)
        // AND CAN YOU SEE IT COMING? Bulkowski: a run of >3 closes into the break makes a throwback
        // materially rarer. Not getting filled is the entire hidden cost of a "wait" policy.
        f_r2(8, "  after a run of >3 closes", na(rtAfterRun) ? "-" : str.tostring(rtAfterRun, "#.0") + "%  vs  " + (na(rtAfterFlat) ? "-" : str.tostring(rtAfterFlat, "#.0") + "% otherwise"), txtMain, panelBg)
        f_r2(9, "False-break rate", na(fbRate) ? "-" : str.tostring(fbRate * 100, "#.0") + "%   (" + str.tostring(nFalse) + "/" + str.tostring(nBreaks) + ")", na(fbRate) ? txtMut : fbRate > 0.4 ? colFalse : txtMain, rowAlt)
        table.cell(tb, 0, 10, "EXPECTED VALUE PER BREAK", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 10, "", bgcolor = frameC)
        table.cell(tb, 2, 10, "", bgcolor = frameC)
        f_r2(11, "Take every break", na(evBreak) ? "-" : f_R(evBreak) + "   (100% of breaks)", na(evBreak) ? txtMut : bwV == -1 ? colUp : txtMain, panelBg)
        f_r2(12, "Wait for the retest", na(evWait) ? "-" : f_R(evWait) + "   (" + (na(rtRate) ? "-" : str.tostring(rtRate * 100, "#") + "% of breaks)"), na(evWait) ? txtMut : bwV == 1 ? colUp : txtMain, rowAlt)
        f_r2(13, "VERDICT", bwTxt, (not calibOn or warmBW) ? txtMut : bwV == 0 ? colFalse : colUp, panelBg)
        f_r2(14, "  wait vs break (t)", na(tBW) ? "-" : str.tostring(tBW, "#.2") + "   (needs |t| > 1.96)", (not calibOn or warmBW) ? txtMut : bwV == 0 ? colFalse : colUp, rowAlt)
        table.cell(tb, 0, 15, "IS THE VOLUME FILTER EARNING ITS KEEP?", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 15, "", bgcolor = frameC)
        table.cell(tb, 2, 15, "", bgcolor = frameC)
        // Bulkowski, on volume: after an ABOVE-average-volume breakout, failures DOUBLE and the
        // likelihood of a throwback TRIPLES, while the move is barely better. Everyone is taught the
        // opposite. It is testable — so the break RECORD includes low-volume breaks, and volume gates
        // only the SIGNAL. This row is what the filter is actually worth.
        f_r3(16, "Break ON volume", na(expVolY) ? "-" : f_R(expVolY), na(ctlVolY) ? "-" : f_R(ctlVolY) + " · n=" + str.tostring(nVolY), txtMain, panelBg)
        f_r3(17, "Break OFF volume", na(expVolN) ? "-" : f_R(expVolN), na(ctlVolN) ? "-" : f_R(ctlVolN) + " · n=" + str.tostring(nVolN), txtMain, rowAlt)
        f_r2(18, "  on vs off (t)", na(tV) ? "-" : str.tostring(tV, "#.2") + (na(tV) ? "" : tV > 1.96 ? "   the filter HELPS" : tV < -1.96 ? "   the filter HURTS" : "   no difference — it is doing nothing"), (not na(tV) and math.abs(tV) > 1.96) ? colUp : colFalse, panelBg)
        f_r2(19, "Next-level target reached", na(f_nlRate(1)) ? "-" : "break " + str.tostring(f_nlRate(1), "#") + "% @ " + str.tostring(f_nlDist(1), "#.#") + "R  ·  retest " + (na(f_nlRate(2)) ? "-" : str.tostring(f_nlRate(2), "#") + "% @ " + str.tostring(f_nlDist(2), "#.#") + "R"), txtMain, rowAlt)
        f_r2(20, "Baseline drift", (na(driftL) or na(driftS)) ? "-" : "long " + f_R(driftL) + " · short " + f_R(driftS), txtMut, panelBg)
        string setTxt = setupLive ? (eDir == 1 ? "LONG · " : "SHORT · ") + eSrc : na(eEn) ? "none" : eRes == 1 ? "last: target hit" : eRes == -1 ? "last: stopped" : "last: expired"
        f_r2(21, "Live setup", setTxt, setupLive ? (eDir == 1 ? colUp : colDn) : txtMut, rowAlt)
        f_r2(22, "Note", "entry = close · identical geometry · direction-matched control · in-sample · not advice", txtMut, panelBg)
    else
        f_r2(1, "VERDICT", bwTxt, (not calibOn or warmBW) ? txtMut : bwV == 0 ? colFalse : colUp, rowAlt)
        f_r3(2, "Break vs retest", na(expBrk) ? "-" : f_R(expBrk), na(expRt) ? "-" : f_R(expRt), txtMain, panelBg)
        f_r2(3, "Breaks that retested", na(rtRate) ? "-" : str.tostring(rtRate * 100, "#.0") + "%", txtMain, rowAlt)
        f_r2(4, "False breaks", na(fbRate) ? "-" : str.tostring(fbRate * 100, "#.0") + "%", na(fbRate) ? txtMut : fbRate > 0.4 ? colFalse : txtMain, panelBg)
        f_r2(5, "Note", "Pro panel for the full test", txtMut, rowAlt)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       LEGEND / KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
var table lg = table.new(f_pos(legendPos), 2, 8, frame_width = 1, border_width = 1)
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
    f_lg(1, "┈",  txtMut,   "A level. Dashed = intact. Solid = it has been broken")
    f_lg(2, "▲▼", colUp,    "BREAK — a CLOSE through, with displacement and volume")
    f_lg(3, "✕",  colFalse, "FALSE BREAK — it closed back inside. Watch this rate")
    f_lg(4, "●",  colUp,    "RETEST — price came back to the level and HELD it")
    f_lg(5, "━━", txtMain,  "Entry / Stop / Target — target is the next opposing level")
    f_lg(6, "R",  colUp,    "Both entries measured on the SAME breaks, identical geometry")
    f_lg(7, "!",  colFalse, "Only some breaks retest — the panel prices that trade-off")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
color exC = color.new(color.gray, 100)
plot(evLvl,                    "EXP_Level",       exC, display = display.data_window)
plot(brokeNow ? evDir : 0,     "EXP_Break",       exC, display = display.data_window)
plot(falsedNow ? 1 : 0,        "EXP_FalseBreak",  exC, display = display.data_window)
plot(retestNow ? evDir : 0,    "EXP_Retest",      exC, display = display.data_window)
plot(eEn,                      "EXP_Entry",       exC, display = display.data_window)
plot(eSt,                      "EXP_Stop",        exC, display = display.data_window)
plot(eTg,                      "EXP_Target",      exC, display = display.data_window)
plot(eNL,                      "EXP_NextLevel",   exC, display = display.data_window)
plot(na(evWait) or na(evBreak) ? na : evWait - evBreak, "EXP_WaitEdge", exC, display = display.data_window)
plot(rtRate,                   "EXP_RetestRate",  exC, display = display.data_window)
plot(evWait,                   "EXP_EVWait",      exC, display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(brokeNow,  "Breakout",    "Breakout & Retest: a level broke on displacement and volume (context, not advice)")
alertcondition(retestNow, "Retest",      "Breakout & Retest: price came back to a broken level and held it (context, not advice)")
alertcondition(falsedNow, "False break", "Breakout & Retest: the break failed — price closed back inside (context, not advice)")
````
