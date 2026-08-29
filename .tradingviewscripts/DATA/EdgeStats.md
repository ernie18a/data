<!-- tradingview-pine-id: PUB;050782bf30134c269373faddb47240d0 -->
<!-- tradingviewscripts-format: 1 -->
# EdgeStats

Source: https://www.tradingview.com/script/SFk1cah2-EdgeStats/

## Description

Library "EdgeStats"

A win rate on its own is not evidence. This library supplies the four things that turn one into a claim you can defend, none of which Pine ships: a base rate to subtract, a sample size corrected for overlapping forward windows, a confidence interval that behaves at small n, and a p-value that knows how many settings you tried before you picked this one.

The argument in three lines, all from the same 60 wins out of 100:

    assess(60, 100, 0.5, horizon = 1)                 p = 0.046   significant
    assess(60, 100, 0.5, horizon = 10)                p = 0.527   not significant
    assess(60, 100, 0.5, horizon = 10, trials = 30)   p = 1.000   nothing at all

Nothing changed about the data. What changed is being honest that ten-bar forward returns sampled every bar are not a hundred independent observations, and that the best of thirty settings is not the same evidence as the only setting you tried.

WHAT THE DEMO SHOWS

Added to a chart directly, the library grades an ordinary signal: close above a 50 EMA, judged on whether price is higher ten bars later, over the last 500 bars. On BTCUSD 1h at the time of writing that is a hit rate of 39.9% against a base rate of 50.4%, an edge of -10.5 percentage points, and a two-sided p of 0.297.

Read that carefully, because it is the whole point. The signal looks bad. It is not reliably bad. Twenty-five independent observations cannot separate -10.5 points from noise, and the interval runs from 23.3% to 59.3%. A tool that says "I cannot tell" when it cannot tell is the only kind worth having.

THREE HONEST CAVEATS

n / horizon is a rough correction, not a theorem. It assumes overlap is the dominant source of dependence between observations. Where returns are autocorrelated beyond the window it is still optimistic. Treat it as a floor on your uncertainty rather than a ceiling.

zFor bisects normCdf, which is itself an approximation, so it inherits that error: zFor(0.95) lands about 1.2e-6 below the textbook 1.9599640. Irrelevant in practice, but it is an approximation of an approximation and you should hear that from me rather than discover it.

roll() uses ta.cum internally, so its call site must execute on every bar. Called inside "if barstate.islast" it has one bar of history and returns nonsense, and no max_bars_back setting repairs that. This is a property of Pine functions rather than of this library, and it is worth knowing generally.

VERIFICATION

Every fixed-input value is plotted to the Data Window and two are printed on the chart, so you can check the arithmetic rather than trust it. Against Python statistics.NormalDist:

    normCdf(1.96)                 0.9750022    true 0.9750021
    normCdf(-1.0)                 0.1586553
    zFor(0.95)                    1.9599628    true 1.9599640
    zFor(0.99)                    2.5758313    true 2.5758293
    wilson(60, 100, 1.96)         [0.5020026, 0.6905987]
    selectionAdjusted(0.05, 30)   0.7853612

Corrections welcome, particularly to the effective sample size treatment, which is the part I would most like to be wrong about.

REFERENCE

normCdf(x)
  Standard normal cumulative distribution. Abramowitz and Stegun 26.2.17, absolute error below 7.5e-8 across the whole real line.
  Parameters:
    x (float): Value to evaluate.
  Returns: Probability that a standard normal variate is at most x.

zFor(conf)
  Two-sided z multiplier for a confidence level. Bisects normCdf, so any level works rather than a lookup of the usual three.
  Parameters:
    conf (float): Confidence level in (0, 1). 0.95 returns 1.9599628.
  Returns: The z for which the central interval of that width has the given coverage.
@remark Converged to float precision against normCdf, which is itself an approximation, so the result inherits its error: zFor(0.95) lands about 1.2e-6 below the textbook 1.9599640. Irrelevant for anything you would do with it, but it is an approximation of an approximation and worth saying so.

nEff(n, horizon)
  Effective independent sample size when observations use overlapping forward windows.
  Parameters:
    n (float): Raw observation count.
    horizon (int): Length in bars of the forward window each observation measures.
  Returns: n divided by the horizon, with the horizon floored at 1.

wilson(hits, n, z)
  Wilson score interval for a proportion. Unlike the normal approximation it stays inside [0, 1] and stays sane when n is small or the rate sits near an edge.
  Parameters:
    hits (float): Successful observations.
    n (float): Total observations. Pass an effective count here, not a raw bar count, when the windows overlap.
    z (float): Multiplier from zFor().
  Returns: A [lower, upper] tuple on the proportion, or [na, na] when there is no sample.

selectionAdjusted(p, trials)
  Sidak correction. If you searched k settings and reported the best one, the p-value you found is not the p-value that best one deserves.
  Parameters:
    p (float): Uncorrected two-sided p-value.
    trials (int): Settings, symbols or variants searched before this one was chosen. Pass 1 if you did not search.
  Returns: Probability of seeing something at least this good in k independent tries.

roll(src, len)
  Rolling window sum valid from the first bar, unlike math.sum which stays na until the window fills. Useful for counting events over a lookback.
  Parameters:
    src (float): Series to accumulate.
    len (simple int): Window length in bars.
  Returns: Sum of the last len values of src.
@remark Uses ta.cum internally, so the CALL SITE must execute on every bar. Called inside `if barstate.islast` it has one bar of history and returns nonsense. That is a property of Pine functions rather than of this library, and no max_bars_back setting repairs it. len is `simple` so Pine can size the history buffer at compile time.

assess(hits, n, base, horizon, conf, trials)
  The whole assessment in one call.
  Parameters:
    hits (float): Observations where the signal was right.
    n (float): Total observations.
    base (float): Rate at which the same outcome occurred unconditionally over the same horizon. This is the number that makes an edge an edge.
    horizon (int): Bars in the forward window. Overlapping windows shrink the effective sample.
    conf (float): Confidence level for the interval, default 0.95.
    trials (int): Settings searched before choosing this one, default 1.
  Returns: A Verdict.

describe(v)
  One line of plain English for a Verdict, sized to drop straight into a table cell.
  Parameters:
    v (Verdict): The Verdict to describe.
  Returns: A human-readable summary, or "no sample" when there is nothing to say.

Verdict
  Everything needed to decide whether a measured hit rate means anything.
  Fields:
    rate (series float): Observed hit rate, 0 to 1.
    base (series float): Base rate the signal is measured against, 0 to 1.
    edge (series float): rate minus base, in percentage points.
    n (series float): Raw observation count as supplied.
    nEff (series float): Observation count after the overlapping-window correction.
    lo (series float): Lower confidence bound on rate, computed on nEff.
    hi (series float): Upper confidence bound on rate, computed on nEff.
    z (series float): Test statistic of rate against base.
    p (series float): Two-sided p-value, already Sidak-adjusted for the trials argument.
    clears (series bool): True when the interval on the rate excludes the base rate.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © harrell.jordon

//@version=6

// =============================================================================
//  EDGESTATS - turning a win rate into a claim you can defend
// -----------------------------------------------------------------------------
//  A signal that wins 60% of the time in a market that rose 60% of the time has
//  no edge. A signal that wins 60% of the time across nine independent events
//  has no evidence. A signal that wins 60% of the time in the best of thirty
//  settings you tried has neither.
//
//  Pine has no shortage of scripts that print a hit rate. It has very little
//  that answers the next question. This library is the next question:
//
//      edge        hit rate minus the base rate over the same horizon
//      nEff        sample size after overlapping forward windows are accounted for
//      wilson      an interval that behaves at small n and near 0 or 1
//      p           two-sided, against the base rate, computed on nEff
//      adjusted    that p after Sidak correction for k settings searched
//
//  None of it is exotic. All of it is missing from Pine, which ships no erf, no
//  inverse normal, and no notion that a thousand overlapping ten-bar returns are
//  not a thousand observations.
//
//  ON OVERLAPPING WINDOWS
//  Sampling every bar with a horizon-bar forward return gives you observations
//  that share most of their price path with their neighbours. n / horizon is the
//  usual rough correction and the one used here. It is an approximation, not a
//  theorem - it assumes overlap is the dominant source of dependence. Where
//  returns are autocorrelated beyond the window it is still optimistic. Treat it
//  as a floor on your uncertainty rather than a ceiling.
//
//  ON THE BASE RATE YOU PASS IN
//  assess() treats `base` as known exactly, which is the one-sample score test.
//  If you estimated it from the same bars that produced your events - as the demo
//  below does - then two things are true and neither is in your favour. Its own
//  sampling error is being discarded, so p is optimistic. And because the event
//  bars are inside the base window, the base is pulled toward the event rate, so
//  the reported edge understates the signal-versus-everything-else difference by
//  roughly the fraction of bars the signal covers. A signal firing on 60% of bars
//  shows you about 40% of the gap. Both effects are small when events are rare
//  and large when they are not. A two-proportion form is the honest fix and is
//  not in this version.
// =============================================================================

//@description Honest statistics for signal evaluation: base-rate subtraction, sample size corrected for overlapping horizons, Wilson intervals, a normal CDF, and selection-bias adjustment.
library("EdgeStats", overlay = true)

// -----------------------------------------------------------------------------
//  Primitives Pine does not ship
// -----------------------------------------------------------------------------

//@function Standard normal cumulative distribution. Abramowitz and Stegun 26.2.17, absolute error below 7.5e-8 across the whole real line.
//@param x Value to evaluate.
//@returns Probability that a standard normal variate is at most x.
export normCdf(float x) =>
    float ax   = math.abs(nz(x))
    float t    = 1.0 / (1.0 + 0.2316419 * ax)
    float dens = 0.3989422804014327 * math.exp(-ax * ax / 2.0)
    float poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    float tail = dens * poly
    na(x) ? na : (x >= 0 ? 1.0 - tail : tail)

//@function Two-sided z multiplier for a confidence level. Bisects normCdf, so any level works rather than a lookup of the usual three.
//@param conf Confidence level in (0, 1). 0.95 returns 1.9599628.
//@returns The z for which the central interval of that width has the given coverage.
//@remark Converged to float precision against normCdf, which is itself an approximation, so the result inherits its error: zFor(0.95) lands about 1.2e-6 below the textbook 1.9599640. Irrelevant for anything you would do with it, but it is an approximation of an approximation and worth saying so.
export zFor(float conf) =>
    float c      = math.max(0.000001, math.min(0.999999, nz(conf, 0.95)))
    float target = (1.0 + c) / 2.0
    float lo     = 0.0
    float hi     = 8.0
    for i = 0 to 39
        float mid = (lo + hi) / 2.0
        if normCdf(mid) < target
            lo := mid
        else
            hi := mid
    (lo + hi) / 2.0

//@function Effective independent sample size when observations use overlapping forward windows.
//@param n Raw observation count. Zero or positive.
//@param horizon Length in bars of the forward window each observation measures. At least 1.
//@returns n / horizon, or na if either argument is missing or out of range.
//@remark A horizon below 1 is rejected rather than clamped to 1. Clamping would answer a nonsense question with the most optimistic possible sample size, which is the exact failure this library exists to prevent.
export nEff(float n, int horizon) =>
    na(n) or n < 0 or na(horizon) or horizon < 1 ? na : n / horizon

//@function Wilson score interval for a proportion. Unlike the normal approximation it stays inside [0, 1] and stays sane when n is small or the rate sits near an edge.
//@param hits Successful observations.
//@param n Total observations. Pass an effective count here, not a raw bar count, when the windows overlap.
//@param z Multiplier from zFor().
//@returns A [lower, upper] tuple on the proportion, or [na, na] when there is no sample.
//@remark z is taken as an absolute value. A negative multiplier would otherwise return the bounds inverted, lower above upper, which reads as a plausible interval and is not one.
export wilson(float hits, float n, float z) =>
    bool  bad    = na(hits) or na(n) or n <= 0
    float nn     = bad ? 1.0 : n
    float p      = bad ? na : math.max(0.0, math.min(1.0, hits / nn))
    float zz     = math.abs(nz(z, 1.959964))
    float z2     = zz * zz
    float denom  = 1.0 + z2 / nn
    float centre = (nz(p) + z2 / (2.0 * nn)) / denom
    float half   = (zz / denom) * math.sqrt(math.max(0.0, nz(p) * (1.0 - nz(p)) / nn + z2 / (4.0 * nn * nn)))
    [bad ? na : math.max(0.0, centre - half), bad ? na : math.min(1.0, centre + half)]

//@function Sidak correction. If you searched k settings and reported the best one, the p-value you found is not the p-value that best one deserves.
//@param p Uncorrected two-sided p-value.
//@param trials Settings, symbols or variants searched before this one was chosen. Pass 1 if you did not search.
//@returns Probability of seeing something at least this good in k independent tries.
export selectionAdjusted(float p, int trials) =>
    float pc = math.max(0.0, math.min(1.0, nz(p, 1.0)))
    int   k  = math.max(1, nz(trials, 1))
    na(p) ? na : 1.0 - math.pow(1.0 - pc, k)

//@function Rolling window sum valid from the first bar, unlike math.sum which stays na until the window fills. Useful for counting events over a lookback.
//@param src Series to accumulate.
//@param len Window length in bars.
//@returns Sum of the last len values of src.
//@remark Uses ta.cum internally, so the CALL SITE must execute on every bar. Called inside `if barstate.islast` it has one bar of history and returns nonsense. That is a property of Pine functions rather than of this library, and no max_bars_back setting repairs it.
//@remark len is `simple` rather than `series`, so the offset is fixed for the whole run. `simple` resolves at the start of the run and not at compile time - only `const` is compile time.
//@remark Version 2 went on from there to warn that a long len could therefore exhaust the history buffer, and told you to raise max_bars_back on your own indicator() call. That was a guess and it does not reproduce. Measured on a 22,683 bar chart with no max_bars_back set anywhere, roll() returned exactly 500, 2000 and 4900 for those lengths - and since Pine caps max_bars_back at 5000, there is no useful length at which the advice would have applied. Removed rather than left standing.
export roll(float src, simple int len) =>
    float c = ta.cum(nz(src))
    c - nz(c[math.max(1, len)])

// -----------------------------------------------------------------------------
//  The verdict
// -----------------------------------------------------------------------------

//@type Everything needed to decide whether a measured hit rate means anything.
//@field rate Observed hit rate, 0 to 1.
//@field base Base rate the signal is measured against, 0 to 1.
//@field edge rate minus base, in percentage points.
//@field n Raw observation count as supplied.
//@field nEff Observation count after the overlapping-window correction.
//@field lo Lower confidence bound on rate, computed on nEff.
//@field hi Upper confidence bound on rate, computed on nEff.
//@field z Test statistic of rate against base.
//@field p Two-sided p-value, already Sidak-adjusted for the trials argument.
//@field clears True when the interval on the rate excludes the base rate.
export type Verdict
    float rate
    float base
    float edge
    float n
    float nEff
    float lo
    float hi
    float z
    float p
    bool  clears

//@function The whole assessment in one call.
//@param hits Observations where the signal was right.
//@param n Total observations.
//@param base Rate at which the same outcome occurred unconditionally over the same horizon. This is the number that makes an edge an edge.
//@param horizon Bars in the forward window. Overlapping windows shrink the effective sample.
//@param conf Confidence level for the interval, default 0.95. Interpreted as family-wise coverage across `trials`.
//@param trials Settings searched before choosing this one, default 1.
//@returns A Verdict.
//@remark The interval and the p-value are both corrected for `trials`, so they cannot disagree. The interval uses a Sidak-adjusted level, conf^(1/trials), which makes `clears` exactly equivalent to `p < 1 - conf`. Correcting only the p-value, as this library did in version 1, allowed describe() to print a p of 0.75 and "clears chance" in the same line.
//@remark Invalid input returns na rather than a number. hits outside [0, n], n <= 0, base outside [0, 1] and horizon < 1 are all rejected. Where base is exactly 0 or 1 the variance is zero and no test exists, so z and p are na while the rate, interval and edge are still reported.
export assess(float hits, float n, float base, int horizon = 1, float conf = 0.95, int trials = 1) =>
    int   k    = na(trials) or trials < 1 ? 1 : trials
    bool  bad  = na(hits) or na(n) or n <= 0 or hits < 0 or hits > n
    bool  badB = na(base) or base < 0.0 or base > 1.0
    bool  degB = badB or base <= 0.0 or base >= 1.0
    float rate = bad ? na : hits / n
    float ne   = nEff(bad ? na : n, horizon)
    float cIn  = math.max(0.000001, math.min(0.999999, nz(conf, 0.95)))
    float zc   = zFor(math.pow(cIn, 1.0 / k))
    [lo, hi]   = wilson(bad or na(ne) ? na : rate * ne, ne, zc)
    float se   = bad or degB or na(ne) or ne <= 0 ? na : math.sqrt(base * (1.0 - base) / ne)
    float zs   = na(rate) or degB or na(se) ? na : (rate - base) / se
    float pRaw = na(zs) ? na : 2.0 * (1.0 - normCdf(math.abs(zs)))
    float pAdj = selectionAdjusted(pRaw, k)
    float edge = na(rate) or badB ? na : (rate - base) * 100.0
    bool  clr  = na(lo) or na(hi) or badB ? false : (lo > base or hi < base)
    Verdict.new(rate, badB ? na : base, edge, bad ? na : n, ne, lo, hi, zs, pAdj, clr)

//@function One line of plain English for a Verdict, sized to drop straight into a table cell.
//@param v The Verdict to describe.
//@returns A human-readable summary, or "no usable sample" when the inputs were missing or invalid.
//@remark A missing base rate is reported as a missing base rate, not as a missing sample. The two send you looking in different places.
export describe(Verdict v) =>
    string outTxt = "no usable sample"
    if not na(v)
        if not na(v.rate)
            string ci   = na(v.lo) or na(v.hi) ? "n/a" : "[" + str.tostring(v.lo * 100, "0.0") + ", " + str.tostring(v.hi * 100, "0.0") + "]%"
            string nTxt = "n=" + str.tostring(v.n, "0") + (na(v.nEff) ? "" : " (~" + str.tostring(v.nEff, "0") + " independent)")
            if na(v.edge)
                outTxt := str.tostring(v.rate * 100, "0.0") + "%    " + nTxt + "    CI " + ci + "    no base rate supplied"
            else
                string sign = v.edge >= 0 ? "+" : ""
                string pTxt = na(v.p) ? "n/a" : (v.p < 0.001 ? "<0.001" : str.tostring(v.p, "0.000"))
                string verd = na(v.p) or na(v.lo) ? "no test possible with these inputs" : v.clears ? "clears chance" : "not distinguishable from chance"
                outTxt := sign + str.tostring(v.edge, "0.0") + " pp    " + nTxt + "    CI " + ci + "    p=" + pTxt + "    " + verd
    outTxt

// =============================================================================
//  DEMONSTRATION
//  Everything below runs only when this library is added to a chart directly.
//  None of it is exported and importers never see it.
// =============================================================================

int H  = 10     // forward horizon in bars
int LB = 500    // lookback for gathering events
int EL = 50     // EMA length for the demonstration signal

// A deliberately ordinary signal, so the numbers are not flattered by cleverness.
bool sig = close > ta.ema(close, EL)

// An event that happened H bars ago has a known outcome now. Fixed offsets only,
// evaluated on every bar, so nothing here peeks forward.
float fwd      = close - close[H]
bool  gradable = bar_index >= H
float wasSig   = nz(gradable and sig[H] ? 1.0 : 0.0)

// roll() must be called on every bar. This is the right place for it.
float evN   = roll(wasSig, LB)
float evHit = roll(wasSig == 1.0 and fwd > 0 ? 1.0 : 0.0, LB)
float allN  = roll(gradable ? 1.0 : 0.0, LB)
float allUp = roll(gradable and fwd > 0 ? 1.0 : 0.0, LB)
float base  = allN > 0 ? allUp / allN : na

// The assessment itself reads no history, so it is cheap to defer to the last bar.
float o_rate = na
float o_base = na
float o_edge = na
float o_n    = na
float o_nEff = na
float o_lo   = na
float o_hi   = na
float o_z    = na
float o_p    = na

// Fixed-input self tests, so anyone can check the arithmetic against a stats package.
// Expected, verified against Python's statistics.NormalDist:
//   normCdf(1.96)                   0.9750022   (true 0.9750021)
//   normCdf(-1.0)                   0.1586553
//   zFor(0.95)                      1.9599628   (true 1.9599640)
//   zFor(0.99)                      2.5758313   (true 2.5758293)
//   wilson(60, 100, 1.9599640)      [0.5020026, 0.6905987]
//   selectionAdjusted(0.05, 30)     0.7853612
//   assess(60,100,.5,h=1)           p 0.0455001,  z 2.0000000
//   assess(60,100,.5,h=10)          p 0.5270891,  z 0.6324555,  CI [0.3126739, 0.8318196]
//   assess(60,100,.5,h=10,k=30)     p 1.0000000
//   assess(60,100,.5,h=1, k=30)     p 0.7526703,  CI [0.4441431, 0.7379410],  clears false
// The middle three are the argument of this whole library in three lines: the same
// 60 wins out of 100 is significant, then not, then hopeless, purely from being
// honest about overlap and about how many settings were tried. The fourth is the
// consistency check - at k=30 the interval widens to a Sidak level too, so p and
// `clears` cannot tell you different stories. In version 1 they could.
float t_ncdf196 = na
float t_ncdfNeg = na
float t_z95     = na
float t_z99     = na
float t_wLo     = na
float t_wHi     = na
float t_sidak   = na
float t_pH1     = na
float t_pH10    = na
float t_loH10   = na
float t_hiH10   = na
float t_pSrch   = na
float t_pK30    = na
float t_loK30   = na
float t_hiK30   = na
float t_clrK30  = na
float t_badBase = na
float t_badHits = na
float t_badHzn  = na

var table tb = table.new(position.top_right,     2, 13, border_width = 0, frame_width = 0)
var table sm = table.new(position.bottom_center, 1, 1,  border_width = 0, frame_width = 0)

// Table helpers live at global scope: Pine does not allow a function declaration
// inside a local block, which is an easy mistake to make when the only caller is
// an `if barstate.islast` body.
lab(table t, int r, string s, color c, color bgc) =>
    table.cell(t, 0, r, s, text_color = c, bgcolor = bgc, text_size = size.small, text_halign = text.align_left)

val(table t, int r, string s, color c, color bgc) =>
    table.cell(t, 1, r, s, text_color = c, bgcolor = bgc, text_size = size.small, text_halign = text.align_right)

if barstate.islast
    Verdict v = assess(evHit, evN, base, H, 0.95, 1)

    o_rate := v.rate
    o_base := v.base
    o_edge := v.edge
    o_n    := v.n
    o_nEff := v.nEff
    o_lo   := v.lo
    o_hi   := v.hi
    o_z    := v.z
    o_p    := v.p

    t_ncdf196 := normCdf(1.96)
    t_ncdfNeg := normCdf(-1.0)
    t_z95     := zFor(0.95)
    t_z99     := zFor(0.99)
    [wl, wh]  = wilson(60, 100, 1.9599640)
    t_wLo     := wl
    t_wHi     := wh
    t_sidak   := selectionAdjusted(0.05, 30)

    Verdict a1  = assess(60, 100, 0.5, 1,  0.95, 1)     // 60/100 vs a coin flip, no overlap
    Verdict a10 = assess(60, 100, 0.5, 10, 0.95, 1)     // same data, 10-bar overlapping windows
    Verdict as30 = assess(60, 100, 0.5, 10, 0.95, 30)   // ...and thirty settings tried first
    t_pH1   := a1.p
    t_pH10  := a10.p
    t_loH10 := a10.lo
    t_hiH10 := a10.hi
    t_pSrch := as30.p

    // The consistency case. In version 1 this returned p = 0.753 and clears = true.
    Verdict k30 = assess(60, 100, 0.5, 1, 0.95, 30)
    t_pK30   := k30.p
    t_loK30  := k30.lo
    t_hiK30  := k30.hi
    t_clrK30 := k30.clears ? 1.0 : 0.0

    // Invalid input must return na rather than a confident number. Each of these
    // produced a significant-looking result in version 1.
    Verdict bB = assess(60, 100, 1.5)         // base out of range
    Verdict bH = assess(150, 100, 0.5)        // more hits than trials
    Verdict bZ = assess(60, 100, 0.5, 0)      // horizon below 1
    t_badBase := nz(bB.p,    -1.0)
    t_badHits := nz(bH.rate, -1.0)
    t_badHzn  := nz(bZ.nEff, -1.0)

    // ------------------------------------------------------------------ tables
    color dim = color.new(chart.fg_color, 45)
    color txt = chart.fg_color
    color bg  = color.new(chart.bg_color, 12)
    color hot = #f7931a
    color up  = #26a69a
    color dn  = #ef5350

    table.clear(tb, 0, 0, 1, 12)
    table.clear(sm, 0, 0, 0, 0)

    // Row 0 is a deliberate blank. TradingView's symbol legend covers the top row
    // of a table in the price pane whatever that row holds, so it gets this one.
    table.cell(tb, 0, 0, " ", text_size = size.small)
    table.cell(tb, 1, 0, " ", text_size = size.small)

    table.cell(tb, 0, 1, "EDGESTATS  demo", text_color = hot, bgcolor = color.new(hot, 88), text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 1, "", bgcolor = color.new(hot, 88), text_size = size.small)

    lab(tb, 2, "Signal", dim, bg)
    val(tb, 2, "close > EMA " + str.tostring(EL) + ",  " + str.tostring(H) + " bars", txt, bg)

    lab(tb, 3, "Hit rate", dim, bg)
    val(tb, 3, na(v.rate) ? "—" : str.tostring(v.rate * 100, "0.0") + "%   n=" + str.tostring(v.n, "0"), txt, bg)

    lab(tb, 4, "Base rate", dim, bg)
    val(tb, 4, na(v.base) ? "—" : str.tostring(v.base * 100, "0.0") + "%", txt, bg)

    lab(tb, 5, "Edge", dim, bg)
    val(tb, 5, na(v.edge) ? "—" : (v.edge >= 0 ? "+" : "") + str.tostring(v.edge, "0.0") + " pp", na(v.edge) ? dim : v.edge >= 0 ? up : dn, bg)

    lab(tb, 6, "Independent n", dim, bg)
    val(tb, 6, na(v.nEff) ? "—" : "~" + str.tostring(v.nEff, "0") + "   of " + str.tostring(v.n, "0"), dim, bg)

    lab(tb, 7, "95% interval", dim, bg)
    val(tb, 7, na(v.lo) ? "—" : "[" + str.tostring(v.lo * 100, "0.0") + ", " + str.tostring(v.hi * 100, "0.0") + "]%", txt, bg)

    lab(tb, 8, "p  two-sided", dim, bg)
    val(tb, 8, na(v.p) ? "—" : (v.p < 0.001 ? "<0.001" : str.tostring(v.p, "0.000")), txt, bg)

    lab(tb, 9, "Reading", dim, bg)
    val(tb, 9, v.clears ? "CLEARS CHANCE" : "NOT DISTINGUISHABLE", v.clears ? up : dim, bg)

    lab(tb, 10, " ", dim, bg)
    val(tb, 10, " ", dim, bg)

    lab(tb, 11, "Self test", dim, bg)
    val(tb, 11, "normCdf(1.96) = " + str.tostring(t_ncdf196, "0.0000000"), dim, bg)

    lab(tb, 12, "Self test", dim, bg)
    val(tb, 12, "zFor(0.95) = " + str.tostring(t_z95, "0.0000000"), dim, bg)

    table.cell(sm, 0, 0, "describe()  ->  " + describe(v), text_color = txt, bgcolor = bg, text_size = size.small)

// ------------------------------------------------- data window: live assessment
plot(o_rate * 100, "Hit %",        display = display.data_window)
plot(o_base * 100, "Base %",       display = display.data_window)
plot(o_edge,       "Edge pp",      display = display.data_window)
plot(o_n,          "n",            display = display.data_window)
plot(o_nEff,       "nEff",         display = display.data_window)
plot(o_lo * 100,   "CI lo %",      display = display.data_window)
plot(o_hi * 100,   "CI hi %",      display = display.data_window)
plot(o_z,          "z",            display = display.data_window)
plot(o_p,          "p",            display = display.data_window)

// ------------------------------------------------- data window: fixed self tests
plot(t_ncdf196,    "T normCdf196", display = display.data_window)
plot(t_ncdfNeg,    "T normCdfNeg", display = display.data_window)
plot(t_z95,        "T zFor95",     display = display.data_window)
plot(t_z99,        "T zFor99",     display = display.data_window)
plot(t_wLo,        "T wilsonLo",   display = display.data_window)
plot(t_wHi,        "T wilsonHi",   display = display.data_window)
plot(t_sidak,      "T sidak",      display = display.data_window)
plot(t_pH1,        "T p h1",       display = display.data_window)
plot(t_pH10,       "T p h10",      display = display.data_window)
plot(t_loH10,      "T lo h10",     display = display.data_window)
plot(t_hiH10,      "T hi h10",     display = display.data_window)
plot(t_pSrch,      "T p searched", display = display.data_window)
plot(t_pK30,       "T p k30",      display = display.data_window)
plot(t_loK30,      "T lo k30",     display = display.data_window)
plot(t_hiK30,      "T hi k30",     display = display.data_window)
plot(t_clrK30,     "T clears k30", display = display.data_window)
plot(t_badBase,    "T bad base",   display = display.data_window)
plot(t_badHits,    "T bad hits",   display = display.data_window)
plot(t_badHzn,     "T bad horizon",display = display.data_window)
````
