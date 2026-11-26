# Market Rotor - Rotation Artifact Null Test [FibonacciFlux]

- url: https://www.tradingview.com/script/avR8fxIw-Market-Rotor-Rotation-Artifact-Null-Test-FibonacciFlux/
- type: indicator
- pine_id: PUB;27d5e330521f477b83e9e6612f0ac42f
- version: 1.0

## Description

Market Rotor is the first of a series of published experiments: take a correction that is widely assumed to work, implement it honestly, and find out what it actually does. This one tests the standard artifact correction for cross-sectional rotation - the claim that you can estimate each asset's own autocorrelation, subtract the rotation that autocorrelation implies, and treat whatever is left as genuine lead-lag.

[b]Implemented and measured, it does not do that. The script is published so the test can be repeated and the result attacked.[/b]

🔶 USAGE

🔹 What this is for

Before you build on, or believe, a rotation or lead-lag indicator, load your basket here. If an artifact component is identified, an artifact component is present in the rotation this basket produces at this window - which is reason to check whether the indicator you were about to trust is reading the same thing. If nothing is resolved, you have learned that this particular correction cannot tell you either way - which is worth knowing, because the correction is usually assumed to work rather than checked.

🔹 Reading the shading

The background has two states and neither of them is an all-clear:

[list]
[*]Amber - R-squared above zero. An artifact component was identified inside the rotation you are looking at.
[*]Grey - R-squared at or below zero. Nothing was resolved. This is not evidence that the rotation is genuine.
[/list]

https://www.tradingview.com/x/DUEgvW8a/

Two months of BINANCE:BTCUSDT 1H at the defaults. The two states alternate throughout - there is no long stretch where the correction cleanly resolves anything.

There is deliberately no green state anywhere in this script. A reassuring colour would be the most misleading thing it could draw, because the test is structurally incapable of certifying that an observed rotation is real.

🔹 Reading the plots

Three Frobenius norms share the pane. Grey is the observed rotation, the amber filled area is the artifact estimate, green is the residual. [b]These are matrix norms, not components: they do not sum, and the residual can and often does exceed the observed norm.[/b] When it does, subtracting the artifact estimate has added variance rather than removed it - see the noise floor below.

The Data Window carries the quantities that actually matter: R-squared, the residual share, the direction agreement cos(Ω, Ω_art), the mean off-diagonal of G0, the four estimated AR(1) coefficients, the effective sample count, and the legacy statistic from the first version of this script, kept only for comparison.

🔹 Choosing the symbol set

The artifact term is proportional to contemporaneous co-movement. If your four assets barely co-move, or their bars do not align - mixing a stock with 24/7 crypto is the common case - the artifact estimate collapses toward zero for reasons that have nothing to do with lead-lag, and the test silently becomes vacuous. Watch the mean off-diagonal of G0 in the Data Window: if it is small, the reading means nothing.

https://www.tradingview.com/x/BcxozXyN/

The same script on NASDAQ:AAPL daily with the three Binance defaults left in place - the first thing most readers will try. Nothing warns you. On the bar shown, the mean off-diagonal of G0 falls from 0.87 to 0.34, the artifact estimate collapses with it to 0.016 against an observed norm of 0.081, cos(Ω, Ω_art) reads -0.85, and the residual ends up larger than the observed rotation it came from. Note what the old v1 statistic does here: 0.20, which under that version's bands was its most reassuring possible reading. The tool's least trustworthy configuration was the one it praised.

Requests use gaps_on, so a symbol with a missing bar yields na and that bar is skipped rather than having a stale return carried into the estimate.

🔹 Warm-up and repainting

Nothing plots until the window is full and W + z-score-length bars have elapsed: 500 bars at the defaults, roughly three weeks of 1H data, but around two years on a daily chart. If the pane is empty, that is why. The accumulator only advances on confirmed bars, so historical values do not repaint.

🔶 DETAILS

🔹 The identity being tested

Let each asset follow its own AR(1) with coefficient phi_i, and let the true cross-asset lead/lag be identically zero:

[pine]
r[i,t]  = phi_i * r[i,t-1] + e[i,t]
G1[i,j] = E[ r[i,t] * r[j,t+1] ] = phi_j * G0[i,j]
G0 is symmetric, therefore
Om[i,j] = 0.5 * (phi_j - phi_i) * G0[i,j]
[/pine]

Exact in population. The proposal it suggests - estimate phi from each asset's own autocorrelation, form the implied artifact, subtract it, call the remainder genuine lead-lag - is what this script implements so that it can be tested rather than assumed.

🔹 Where the numbers come from

The core was reimplemented outside Pine and agrees with this script to five decimal places on the same bar; every figure below comes from that reimplementation. Figures labelled synthetic are generated with a seeded generator and known ground truth, so they reproduce exactly. Real-data figures name the symbol, timeframe and window they were taken on, and the two single-bar readings are marked as such.

🔹 Result 1: the correction is not identified

phi_i estimated from asset i's own autocorrelation cannot distinguish "asset i is autocorrelated" from "asset i is led by asset j", because the second necessarily produces the first. On synthetic data where a genuine lead-lag is injected, the artifact model fits [b]better[/b], not worse: R-squared rises to +0.40 and cos(Ω, Ω_art) to +0.74 at W=250. The correction absorbs precisely the thing it is meant to leave behind.

🔹 Result 2: the subtraction is noise-dominated

Ω is estimated from the off-diagonal of G1; the artifact term from the diagonal of G1 plus G0. Under the null these estimate the same population quantity. [b]If[/b] their errors are of comparable size and not strongly correlated, Var(Ω_res) = Var(Ω) + Var(Ω_art) and the residual share tends to sqrt(2) = 1.414 when noise dominates. Both of those are assumptions rather than results - the two estimators are built from the same return pairs over the same window, and the null identity ties them together - so read the measured spread as the test of them, not as a confirmation of the algebra. On synthetic all-artifact data it lands between 1.10 and 1.88, straddling that value, and the finding that survives either way is that the residual is larger than the quantity it was subtracted from. On BINANCE:BTCUSDT 1H with the default basket at W=250, the median R-squared is about -0.7 - near the noise floor of -1.

🔹 What the first version of this script got wrong

Version 1 shaded on ‖Ω_art‖ / ‖Ω‖. That statistic compares magnitudes only and is not a fraction-explained, because the artifact and residual matrices are not orthogonal. It read 0.96 - "almost entirely artifact" - on data whose true explained share was 0.41, while the residual line sat at 77% of the observed line directly beside it. It also produced its most reassuring readings on baskets that barely co-move. Both statistics are exposed in the Data Window now - R-squared and the v1 ratio side by side - so the discrepancy can be inspected rather than taken on trust.

🔹 Implementation and reproducibility

N is fixed at four because the external series are requested at global scope. G0 and G1 are uncentred second moments, not covariances; centring them inside the window was tested and moved R-squared by less than 0.02, so the extra accumulators are not carried. Rolling sums of the sixteen products are maintained by hand in a circular buffer, because built-in series functions keep per-call-site state and return wrong values inside loops. The core was independently reimplemented outside Pine and agrees with this script to five decimal places on the same bar; the synthetic scenarios use a seeded generator so the numbers above are reproducible.

🔶 SETTINGS

🔹 Symbols

[list]
[*]Symbol 2, Symbol 3, Symbol 4 - the three series joined to the chart symbol, which is always the first. Defaults are ETHUSDT, SOLUSDT and XRPUSDT on Binance.
[/list]

🔹 Windows

[list]
[*]Rolling window W - length of the moment window, default 250, minimum 100, maximum 1000. Below about 100 the estimates are pure noise and the shading strobes, which is why the minimum is not lower.
[*]Return z-score length - lookback used to standardise each return series, default 250.
[/list]

🔹 Display

[list]
[*]Show ‖Ω‖, ‖Ω_art‖, ‖Ω_res‖ - the three norms.
[*]Shade background when an artifact component is identified - the amber/grey band.
[*]Show residual signal for the chart symbol - off by default, and drawn for inspection only. It is signed and lives on a different scale to the three norms. Result 2 above is the reason not to trade it: this residual is noise-dominated and routinely larger than the observed norm it came from.
[*]Signal display scale - default 0.2. Raising it flattens everything else in the pane.
[/list]

Open source under the Mozilla Public License 2.0. Replications and refutations are welcome, particularly from anyone who can construct an estimator of the artifact term that stays identified when a genuine lead-lag is present.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
// =============================================================================
//  Market Rotor - Rotation Artifact Null Test
// -----------------------------------------------------------------------------
//  This is a null test, not a signal. Its result is negative, and the negative
//  result is the point.
//
//  WHAT IS BEING TESTED
//
//  Rotation and lead-lag indicators all reduce to one object: the antisymmetric
//  part of the lag-1 cross-covariance matrix,
//
//      Om = 0.5 * (G1 - G1')      where G1[i,j] = E[ r[i,t] * r[j,t+1] ]
//
//  Om is non-zero even when no asset leads any other. If each asset merely
//  carries its own AR(1) coefficient phi_i and the true cross-lag is
//  identically zero, then
//
//      G1[i,j] = phi_j * G0[i,j],  G0 symmetric
//      =>  Om[i,j] = 0.5 * (phi_j - phi_i) * G0[i,j]
//
//  That identity is exact in population. The proposal it suggests - estimate
//  phi from each asset's own autocorrelation, form the implied artifact matrix,
//  subtract it, and call the remainder genuine lead-lag - is what this script
//  implements so that it can be tested.
//
//  IT DOES NOT WORK. TWO SEPARATE REASONS, BOTH MEASURED.
//
//  1. NOT IDENTIFIED. phi_i estimated from asset i's own autocorrelation cannot
//     distinguish "asset i is autocorrelated" from "asset i is led by asset j",
//     because the second necessarily produces the first. Injecting a genuine
//     lead-lag into synthetic data RAISES the fit of the artifact model
//     (R2 +0.40, cos +0.74) - the correction absorbs the very thing it is meant
//     to leave behind.
//
//  2. NOISE DOMINATES THE SUBTRACTION. Om is estimated from the off-diagonal of
//     G1; the artifact term from the diagonal of G1 plus the off-diagonal of G0.
//     Under the null these estimate the same population quantity. IF their errors
//     are of comparable size and not strongly correlated - two assumptions, not
//     results, since both are computed from the same return pairs over the same
//     window and the null identity G1[i,j] = phi_j * G0[i,j] ties them together -
//     then
//
//         Var(Ω_res) = Var(Ω_hat) + Var(Ω_art_hat)
//         =>  ‖Ω_res‖ / ‖Ω‖  ->  sqrt(2) = 1.414  when noise dominates
//
//     Measured on synthetic all-artifact data: 1.10 to 1.88, straddling 1.414.
//     Read that spread as the test of those two assumptions rather than as a
//     confirmation of the algebra; the finding that survives either way is that
//     the residual is larger than the quantity it was subtracted from.
//     Subtracting the estimated artifact makes the residual LARGER than the
//     quantity it was subtracted from. On BINANCE:BTCUSDT 1h with the default
//     basket at W=250 the median R2 is about -0.7, i.e. near the noise floor.
//
//  HOW TO READ THE RESULT
//
//      R2 = 1 - ‖Ω_res‖^2 / ‖Ω‖^2
//
//  The two boundaries are derived, not chosen:
//      R2 > 0    the artifact model explains part of the observed rotation
//      R2 = 0    it explains exactly nothing
//      R2 ~ -1   the noise floor implied by ‖Ω_res‖/‖Ω‖ = sqrt(2)
//
//  Note what this can and cannot conclude. R2 > 0 says an artifact component is
//  present in what you are looking at. R2 <= 0 says the test resolved nothing -
//  which is NOT evidence that the rotation is genuine. There is therefore no
//  "all clear" state and no green shading anywhere in this script, by design.
//
//  v1 of this script shaded on ‖Ω_art‖/‖Ω‖ instead. That statistic compares
//  magnitudes only and is not a fraction-explained, because art and res are not
//  orthogonal. It read 0.96 ("almost all artifact") on data where the true
//  explained share was 0.41. It is kept in the Data Window as the entry named
//  "‖Ω_art‖/‖Ω‖ v1 (NOT a share)", purely so the discrepancy can be
//  inspected. Do not read it as a share.
//
//  IMPLEMENTATION NOTES
//    G0 and G1 are UNCENTRED second moments, not covariances. Centring them
//    inside the window was tested and moved R2 by less than 0.02, so the extra
//    accumulators are not carried.
//    Rolling sums of the N^2 products are maintained by hand in a circular
//    buffer: ta.* functions keep per-call-site state and are wrong inside loops.
//    Requests use gaps_on so that a symbol with missing bars yields na and the
//    bar is skipped, rather than silently carrying a stale value forward - a
//    carried value inflates the estimated phi and manufactures an artifact
//    reading.
// =============================================================================

indicator("Market Rotor - Rotation Artifact Null Test [FibonacciFlux]", "MarketRotor", overlay = false, precision = 5)

G_SY = "1. Symbols (chart symbol + 3)"
G_WN = "2. Windows"
G_DP = "3. Display"

sym1 = input.symbol("BINANCE:ETHUSDT", "Symbol 2", group = G_SY)
sym2 = input.symbol("BINANCE:SOLUSDT", "Symbol 3", group = G_SY)
sym3 = input.symbol("BINANCE:XRPUSDT", "Symbol 4", group = G_SY)

W    = input.int(250, "Rolling window W", minval = 100, maxval = 1000, group = G_WN,
     tooltip = "Below about 100 the estimates are pure noise and the shading strobes. Minimum is 100 for that reason.")
zLen = input.int(250, "Return z-score length", minval = 20, group = G_WN)

showOm   = input.bool(true,  "Show ‖Ω‖ (observed)", group = G_DP)
showArt  = input.bool(true,  "Show ‖Ω_art‖ (artifact estimate)", group = G_DP)
showRes  = input.bool(true,  "Show ‖Ω_res‖ (residual)", group = G_DP)
showBand = input.bool(true,  "Shade background when an artifact component is identified", group = G_DP)
showSig  = input.bool(false, "Show residual signal for the chart symbol", group = G_DP)
sigScale = input.float(0.2,  "Signal display scale", minval = 0.01, step = 0.05, group = G_DP,
     tooltip = "The residual signal is signed and lives on a different scale to the three norms, so raising this flattens everything else in the pane. It is drawn for inspection only. Result 2 above shows this residual is noise-dominated and routinely larger than the observed norm it came from - do not read it as a trading signal.")

int N = 4

// =============================================================================
//  Standardised log returns, evaluated in each symbol's own context
// =============================================================================
zret() =>
    float lp = math.log(close)
    float r  = lp - nz(lp[1], lp)
    (r - ta.sma(r, zLen)) / math.max(ta.stdev(r, zLen), 1e-9)

float r0 = zret()
float r1 = request.security(sym1, timeframe.period, zret(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off)
float r2 = request.security(sym2, timeframe.period, zret(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off)
float r3 = request.security(sym3, timeframe.period, zret(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off)

// With gaps_on a missing bar yields na, the guard below skips it, and no stale
// return is ever paired across a gap. No carry-forward layer is needed.

// =============================================================================
//  Rolling second moments in an explicit circular buffer
// =============================================================================
int NN   = N * N
int NBUF = 2 * NN

var array<float> ring  = array.new_float(NBUF * W, 0.0)
var array<float> sums  = array.new_float(NBUF, 0.0)
var int ptr   = 0
var int nfill = 0

array<float> rv = array.new_float(N, na)
array.set(rv, 0, r0)
array.set(rv, 1, r1)
array.set(rv, 2, r2)
array.set(rv, 3, r3)

array<float> rp = array.new_float(N, na)
array.set(rp, 0, nz(r0[1], na))
array.set(rp, 1, r1[1])
array.set(rp, 2, r2[1])
array.set(rp, 3, r3[1])

bool allok = true
for i = 0 to N - 1
    if na(array.get(rv, i)) or na(array.get(rp, i))
        allok := false

if allok and barstate.isconfirmed
    array<float> prod = array.new_float(NBUF, 0.0)
    for i = 0 to N - 1
        for j = 0 to N - 1
            array.set(prod, i * N + j, array.get(rv, i) * array.get(rv, j))
            array.set(prod, NN + i * N + j, array.get(rp, i) * array.get(rv, j))
    for k = 0 to NBUF - 1
        int   pos  = k * W + ptr
        float oldv = array.get(ring, pos)
        float newv = array.get(prod, k)
        array.set(ring, pos, newv)
        array.set(sums, k, array.get(sums, k) - oldv + newv)
    ptr   := (ptr + 1) % W
    nfill := math.min(nfill + 1, W)

float cnt = math.max(nfill, 1)

// =============================================================================
//  Ω, the identity artifact, the residual, and the fit statistics
// =============================================================================
array<float> phi = array.new_float(N, 0.0)
for i = 0 to N - 1
    float g0ii = array.get(sums, i * N + i) / cnt
    float g1ii = array.get(sums, NN + i * N + i) / cnt
    array.set(phi, i, g1ii / math.max(g0ii, 1e-12))

float sqOm   = 0.0
float sqArt  = 0.0
float sqRes  = 0.0
float dotOA  = 0.0
float absG0o = 0.0
float sig    = 0.0

for i = 0 to N - 1
    for j = 0 to N - 1
        float g0ij = array.get(sums, i * N + j) / cnt
        float g1ij = array.get(sums, NN + i * N + j) / cnt
        float g1ji = array.get(sums, NN + j * N + i) / cnt
        float om   = 0.5 * (g1ij - g1ji)
        float art  = 0.5 * (array.get(phi, j) - array.get(phi, i)) * g0ij
        float res  = om - art
        sqOm  := sqOm  + om * om
        sqArt := sqArt + art * art
        sqRes := sqRes + res * res
        dotOA := dotOA + om * art
        if i != j
            absG0o := absG0o + math.abs(g0ij)
        if i == 0
            sig := sig + res * array.get(rv, j)

float normOm  = math.sqrt(sqOm)
float normArt = math.sqrt(sqArt)
float normRes = math.sqrt(sqRes)

bool ready = nfill >= W and bar_index >= W + zLen
bool live  = ready and normOm > 1e-12

float OM  = ready ? normOm  : na
float ART = ready ? normArt : na
float RES = ready ? normRes : na
float SIG = ready ? sig     : na

float R2      = live ? 1.0 - sqRes / sqOm                              : na
float RESSH   = live ? normRes / normOm                                : na
float COS     = live and normArt > 1e-12 ? dotOA / (normOm * normArt)  : na
float G0OFF   = ready ? absG0o / (NN - N)                              : na
float RATLEG  = live ? normArt / normOm                                : na

// =============================================================================
//  Plots. The three norms share an axis. Everything else is Data Window only,
//  because it lives on a different scale and would flatten them.
// =============================================================================
hline(0.0, "0", color = color.new(color.gray, 55), linestyle = hline.style_dotted)

plot(showOm  ? OM  : na, "‖Ω‖ observed",     color = color.new(#8a8f9c, 0), linewidth = 1)
plot(showArt ? ART : na, "‖Ω_art‖ artifact", color = color.new(#f0a020, 25), style = plot.style_area, linewidth = 1)
plot(showRes ? RES : na, "‖Ω_res‖ residual", color = color.new(#2ecc71, 0), linewidth = 2)
plot(showSig ? SIG * sigScale : na, "Residual signal (chart symbol)", color = color.new(#3aa0ff, 20), linewidth = 1)

// Two states, and neither of them is "clean". This test can report that an
// artifact component was identified, or that it could not tell. It can never
// certify that an observed rotation is genuine, so there is deliberately no
// green state - a reassuring colour here would be the single most misleading
// thing the script could draw.
//   amber : R2 > 0, an artifact component was identified in what you are seeing
//   grey  : R2 <= 0, nothing was resolved; near -1 is the sqrt(2) noise floor
color bgc = not showBand or not live or na(R2) ? na :
     R2 > 0.0 ? color.new(#f0a020, 88) : color.new(#8a8f9c, 92)
bgcolor(bgc, title = "Artifact component identified")

plot(R2,     "R2 explained share",        display = display.data_window)
plot(RESSH,  "‖Ω_res‖/‖Ω‖",            display = display.data_window)
plot(COS,    "cos(Ω, Ω_art)",              display = display.data_window)
plot(G0OFF,  "mean |G0 off-diag|",        display = display.data_window)
plot(RATLEG, "‖Ω_art‖/‖Ω‖ v1 (NOT a share)",  display = display.data_window)
plot(ready ? array.get(phi, 0) : na, "φ chart symbol", display = display.data_window)
plot(ready ? array.get(phi, 1) : na, "φ Symbol 2",     display = display.data_window)
plot(ready ? array.get(phi, 2) : na, "φ Symbol 3",     display = display.data_window)
plot(ready ? array.get(phi, 3) : na, "φ Symbol 4",     display = display.data_window)
plot(ready ? nfill : na, "Effective sample count", display = display.data_window)
````
