# Market Rotor - Phase-Space Rotation Geometry [FibonacciFlux]

- url: https://www.tradingview.com/script/UvXd7zUx-Market-Rotor-Phase-Space-Rotation-Geometry-FibonacciFlux/
- type: indicator
- pine_id: PUB;435c21302d6f4d97a44423e08e928e34
- version: 1.0

## Description

Third in a series of published experiments. The first script asked whether an observed rotation survives a null. The second asked whether the circulation between price and flow is just the price increment leaking into the flow axis. This one publishes the full phase-space geometry those two were carved out of, and then applies the same treatment to its own headline verdict.

[b]The verdict does not survive. Against a null that breaks only the thing being tested, the orbital-rotation state is not distinguishable from noise on BTCUSDT and is worse than noise on ETHUSDT. The numbers are below and the indicator ships with the state still labelled, because a label you can check is more useful than one quietly removed.[/b]

🔶 USAGE

🔹 What is in the pane

Two dimensionless series share one scale by design. C is the signed rotation consistency - net turning divided by total turning over a window, bounded to [-1, 1]. S* is a spiral index, tanh-compressed to the same range, positive when the trajectory winds outward. The bands behind them are the regime label; the dots along the top are phase slips.

Angular velocity ω is off by default, and that is a units decision rather than a judgement. C and S* are dimensionless; ω is rad/bar and reaches ‖ω‖ of 1.92 on BTCUSDT 1H against 0.597 for C and 0.768 for S*. Sharing an axis, it sets the scale and flattens the two series the pane exists to show. Turn it on and expect the pane to rescale.

🔹 Where the numbers come from

Every figure below comes from a reimplementation of the core outside Pine, cross-checked against the live script on the same bar, and run over 3856 plotted bars of BINANCE:BTCUSDT and BINANCE:ETHUSDT 1H covering 3 March to 17 August 2026. The null draws use a seeded generator, so they reproduce. Warm-up discards the first 144 bars of each 4000-bar series.

🔹 The background will look like a barcode, and that is the result

[b]These are per-bar labels drawn as bands, not regimes.[/b] Over 3856 bars at the defaults the label changes on 34.5% of BTCUSDT 1H bars, with a median unbroken run of 1 bar and a 90th percentile of 6. On ETHUSDT it is 38.0%, again a median run of 1 bar. Nothing here smooths that into looking more stable, because smoothing it would be the lie. The practical reading is blunt: on most bars this tells you nothing. Phase noise alone takes 59.2% of BTCUSDT bars, and the label changes on the next bar about one time in three - the median unbroken run is a single bar because short runs are common, not because most bars are isolated. Use it to look at a stretch of history, not to make a decision on the current bar.

https://www.tradingview.com/x/5ykP8w0r/

BTCUSDT 1H at the shipped defaults, seven weeks. Three things to look at. The background is stripes rather than blocks, which is the 34.5% figure made visible. The C line - green above zero, pink below - stays well inside the two faint threshold lines at ±0.45 for almost the entire span; the handful of touches are some of the 8 episodes counted below. And the amber S* area is far wider than C, which is why the pane scales the way it does and why ω, wider still, is off by default.

What the bars get called, BTCUSDT / ETHUSDT: phase noise 59.2% / 51.7%, outward spiral 15.7% / 18.3%, inward spiral 13.6% / 16.8%, core 8.7% / 11.3%, phase slip 1.2% / 1.7%, orbital rotation 1.5% / 0.1%. Those last two are lower than the raw |C| rates below, because the cascade tests slip, core and spiral before it ever tests |C|.

🔹 The orbital-rotation verdict, and the null that kills it

The obvious null is to shuffle the second axis. That is the wrong null, and it is the mistake this script shipped with. Shuffling destroys y's autocorrelation as well as its alignment with x - lag-1 goes from 0.545 to 0.034 - and a y that jumps every bar inflates the total turning in the denominator, pushing C toward zero for reasons that have nothing to do with the two axes. A circular shift of y keeps the autocorrelation at 0.543 and breaks only the alignment, which is the thing under test.

Rate of the verdict against the p50 of each null over 20 draws, and p = the share of shift-null draws that match or beat the real rate. 3856 bars, both symbols:

[pine]
              BTCUSDT                          ETHUSDT
 W    real   shuffle   shift     p       real   shuffle   shift     p
24   6.52%    2.63%    7.68%   0.76     7.09%    3.14%    8.69%   0.90
48   1.84%    0.16%    1.12%   0.29     0.29%    0.13%    1.63%   1.00
96   0.03%    0.00%    0.00%   0.24     0.00%    0.00%    0.00%   1.00
[/pine]

[b]Read the shuffle and shift columns side by side.[/b] Against the shuffle the verdict looks like it separates at every window. Against the shift it separates at none: on BTCUSDT the real rate sits inside the bulk of its own null, and on ETHUSDT it sits below every draw. At the window this script originally shipped with, W = 24, the real rate is [b]below[/b] the null median on both symbols.

The window was moved from 24 to 48 in an earlier cycle precisely because that drove the shuffle null to zero. What it actually did was widen a gap against a null that had been crippled. It stays at 48 as the more conservative reading, not because it separates anything.

And 71 and 11 are not 71 and 11 independent trials. Adjacent bars share 47 of their 48 turning angles. Counted as contiguous episodes, [b]both symbols enter the state exactly 8 times[/b]; on BTCUSDT a single episode of 30 bars is 42% of every firing bar. The gap between the two symbols is how long one episode lasted.

🔹 Warm-up, alerts and cost

Nothing plots for 3 × the longest window, which now includes the consistency window - 144 bars at the defaults. Four alerts fire on entry into the phase-slip, outward-spiral and orbital-rotation states and on a change of rotation direction; they name the trigger and deliberately say nothing about what price should do next.

Four request.* calls sit at global scope and run every bar whatever the settings say; what is conditional is the timeframe each asks for, so the lower-timeframe pull only requests a real lower timeframe when the order-flow axis is selected. That is not the same as free, and the cost has not been measured. Two chart tabs did go unresponsive on a two-core machine during this work, one of them here during a symbol change - but the order-flow axis was afterwards exercised on 1H without incident and gave genuinely different values from the default. Read those as unexplained, not as a warning about a setting.

On the order-flow axis there is one silent substitution to know about: past the intrabar history limit, or on a plan that cannot serve the chosen lower timeframe, y falls back to the CLV proxy with no visible break, so the plotted history can mix two different second axes.

🔶 DETAILS

🔹 The construction

Both axes are z-scored over a rolling window and passed through a 2×2 whitening Σ^(-1/2), so a merely correlated pair does not draw a tilted ellipse and read as rotation. Turning per bar is the signed angle between successive position vectors, taken from the cross and dot products rather than by differencing φ, and spans inside a central dead zone count as zero turning because the angle there is noise. C is the ratio of the two rolling sums, gated so a window carrying less than π of total turning reports nothing at all.

🔹 The noise floor, measured honestly

[pine]
median |C|   real 0.133   y shuffled 0.097   y circularly shifted 0.123
both null figures are the p50 across 20 draws, not a single draw
[/pine]

Break only the alignment and the level barely moves - and at the window this script originally shipped with, W = 24, it does not move at all: real 0.169 against a shift null of 0.167. Nearly everything you see is the random walk of a partial sum over 48 angles. The earlier "about seventy per cent" reading came from the shuffle column, and was therefore too generous to the indicator.

🔹 Which knobs are load-bearing

[b]One.[/b] The lag on the second axis: with no lag, y is close to the derivative of x, the point circles for that reason alone, and median signed consistency comes back at -0.283 against -0.036 at the shipped lag of one bar. Two that are not: moving the dead zone from 0 to 1.0 moves median |C| from 0.144 to 0.128, and turning whitening off moves it from 0.133 to 0.138. Defensible hygiene, neither load-bearing.

🔹 What is not established

Incremental alpha, none of it - no IC against existing signals, no out-of-sample improvement, no PBO or DSR. This is an observer, and on the evidence above it is an observer of something it has not shown to be there. The experimental signal arrows are off by default and stay in only as a comparison: shuffling the second axis barely dented their performance, which points at the plain |x| threshold rather than at anything rotational.

🔶 SETTINGS

🔹 Axes and normalisation

[list]
[*]Second axis y - five options: deviation × momentum (default), deviation × order flow from lower-timeframe volume delta, deviation × order flow via a CLV × volume proxy, return × volatility change, and deviation × open-interest change. Momentum is close to the derivative of x, so read the default as the control rather than as the best proxy. Every number in this description is measured on that default axis, deliberately - it is the weakest case, and a statistic that cannot beat its null there has not earned a test on a better axis. The order-flow axis was not re-measured.
[*]Lag on the second axis - default 1. The one setting that decides whether the measurement means anything.
[*]Equilibrium EMA 34, z-score length 40, 2×2 whitening on, z clip 4.0, optional anchored normalisation.
[/list]

🔹 Windows

[list]
[*]Consistency window for C - default 48. Read the window sweep above before changing it - no setting of it separates the verdict from the shift null.
[*]Total-turning gate - default π. Below it, C and S* report na rather than a ratio of two small numbers. It is a safeguard that never bound on the data here: total turning had a median of 27.7 rad and a minimum of 12.6 against a gate of 3.14, so it was open on all 3856 bars of both symbols. Expect no gaps from it.
[*]Central dead zone 0.30, winding window 32, loop-area window 24, warm-up multiplier 3.
[/list]

🔹 Regimes and display

[list]
[*]Thresholds for orbital rotation, spiral, core radius and phase-slip hazard.
[*]C, S*, the regime background and the slip markers are on by default; ω, winding number W, loop area A, the Kuramoto multi-timeframe readout and the experimental arrows are off.
[*]The Kuramoto readout R carries the same units caveat as ω: it lives on [0, 1] and is positive only, so switching it on rescales the pane. It is drawn beneath C so it cannot hide it. Its two higher timeframes now default to 4H and 12H - they were 1H and 4H, and on the shipped 1H chart that made two of the three phases identical and put a floor of 1/3 under R. Keep both above your chart timeframe.
[/list]

Radius, raw S*, phase-slip hazard, total turning, raw loop area, both axis positions and the regime number are in the Data Window.

Open source under the Mozilla Public License 2.0. Replications and refutations welcome - particularly a symbol, timeframe or axis pair on which the orbital-rotation state does separate from a shift null. I did not find one.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
// =============================================================================
//  Market Rotor - Phase-Space Rotation Geometry
// -----------------------------------------------------------------------------
//  Third in a series of published experiments. This one is the oldest approach
//  of the three and the only one that measures rotation as an angle.
//
//  Embed the market in a 2-D phase space and measure how its trajectory turns:
//
//    x_t   deviation from equilibrium  (position)
//    y_t   the force driving it        (default: momentum, lagged one bar)
//
//    dtheta = atan2(x_{t-1}*y_t - y_{t-1}*x_t,  x_{t-1}*x_t + y_{t-1}*y_t)
//    r      = sqrt(x^2 + y^2)
//    C      = sum(dtheta) / sum|dtheta|      signed rotation consistency, -1..+1
//    S*     = sum(dln r) / sum|dtheta|       spiral index, dln r per radian
//    W      = sum(dtheta) / 2pi              winding number
//    A      = sum 0.5*(x_i y_{i+1} - y_i x_{i+1})   signed loop area
//    H      = phase-slip hazard
//
//  WHAT MEASUREMENT SAYS ABOUT IT - reimplemented outside Pine, BTCUSDT 1H
//
//  1. |C| IS ALMOST ENTIRELY NOISE FLOOR - AND THE NULL YOU PICK DECIDES HOW BADLY.
//     Shuffling y destroys its autocorrelation (lag-1 0.545 -> 0.034) as well as its
//     alignment with x. A shuffled y jumps every bar, which inflates sum|dtheta| and
//     drives C toward zero for reasons that have nothing to do with the two axes.
//     A circular shift of y keeps the autocorrelation (0.543) and breaks only the
//     alignment, which is the thing being tested.
//
//         median |C|   real 0.133   y shuffled 0.097   y circularly shifted 0.123
//         (both null columns are the p50 across 20 draws, not a single draw)
//
//     Against the honest null the level barely moves. Nearly all of what you see is
//     the random walk of a partial sum over 48 angles.
//
//  2. THE SHIPPED THRESHOLD DOES NOT SEPARATE FROM THE RIGHT NULL, ON EITHER SYMBOL.
//     Fraction of bars classified "orbital rotation" at |C| > 0.45:
//
//         window 48, 3856 bars, 20 draws of each null
//
//         BTCUSDT   real 1.84% (71 bars)   shuffle p50 0.16%   shift p50 1.12%
//         ETHUSDT   real 0.29% (11 bars)   shuffle p50 0.13%   shift p50 1.63%
//
//         draws at or above the real rate, shift null:  BTCUSDT 5 of 20 (p = 0.29)
//                                                        ETHUSDT 20 of 20 (p = 1.00)
//
//     The window was moved from 24 to 48 because that drove the shuffle null to
//     zero and left the real rate standing. That justification was wrong: what
//     the longer window did was widen the gap against a null that had had its
//     autocorrelation destroyed. Against the shift null the real BTCUSDT rate
//     sits inside the bulk of its own null distribution, and the ETHUSDT rate
//     sits below every draw of it.
//
//     Nor is a different window a way out. Real rate against the p50 of the
//     shift null, with the count of 20 null draws matching or beating it:
//
//               BTCUSDT                        ETHUSDT
//       W    real   shift p50    p        real   shift p50    p
//      24   6.52%     7.68%    0.76      7.09%     8.69%    0.90
//      48   1.84%     1.12%    0.29      0.29%     1.63%    1.00
//      96   0.03%     0.00%    0.24      0.00%     0.00%    1.00
//
//     At 24 the real rate is BELOW the null median on both symbols.
//
//     Nor are those percentages 71 and 11 independent trials. Adjacent bars share
//     47 of 48 dtheta terms. Counted as contiguous episodes, both symbols enter
//     the state exactly 8 times; on BTCUSDT one episode of 30 bars is 42% of every
//     firing bar. The difference between the two symbols is how long one episode
//     lasted, not how often the verdict happens.
//
//     The window stays at 48 because a longer window is the more conservative
//     reading, not because it separates anything. It does not.
//
//  3. THE LAG ON y IS THE CORRECTION THAT MATTERS. With no lag, y is essentially
//     the derivative of x, the phase point circles for that reason alone, and C
//     comes back strongly signed: median -0.283 against -0.036 at the default
//     lag of one bar. This is the free parameter that decides whether the
//     measurement means anything.
//
//  4. TWO CORRECTIONS THIS HEADER USED TO BOAST ABOUT DO ALMOST NOTHING. Moving
//     the dead zone from 0 to 1.0 moves median |C| from 0.144 to 0.128. Turning
//     whitening off moves it from 0.133 to 0.138. Both are defensible; neither
//     is load-bearing, and saying so is more useful than listing them as fixes.
//
//  WHAT IS STILL NOT ESTABLISHED
//
//  Incremental alpha. No incremental IC against existing signals, no out-of-
//  sample log-loss improvement, no PBO or DSR. This is an observer, not a
//  strategy. The experimental signal arrows are off by default and stay in only
//  as a comparison: an audit found that shuffling the second axis barely dented
//  their performance, which points at the plain "|x| threshold plus a three-bar
//  return reversal" condition rather than at anything rotational.
//
//  A NOTE ON COST. Four external requests sit at global scope and run on every
//  bar whatever the settings are, because request.* cannot be placed inside a
//  conditional. The timeframe each one asks for CAN be conditional, though, and
//  that is where the cost lives: with the default axis the lower-timeframe pull
//  is pointed at the chart's own timeframe, so it returns one intrabar per bar
//  instead of sixty, and with the Kuramoto readout off the two higher-timeframe
//  phase requests resolve locally. Select the order-flow axis, or switch the
//  readout on, and you are asking for the real thing. The sibling script in this
//  series hung a chart tab on a two-core machine with one such request left at
//  full cost, which is what prompted this.
// =============================================================================

indicator("Market Rotor - Phase-Space Rotation Geometry [FibonacciFlux]", "PhaseRotor", overlay = false, precision = 4)

// -------------------------------------------------------------------- inputs
// group= wants a const string, so these must not be var - var would make them series
G_AX = "1. Phase-space axes"
G_NM = "2. Normalisation"
G_WN = "3. Rotation windows and gate"
G_RG = "4. Regime thresholds"
G_DP = "5. Display"
G_MT = "6. MTF phase sync (Kuramoto)"
G_SG = "7. Experimental signals (unvalidated, off by default)"

// --- 1. axes -----------------------------------------------------------------
axMode = input.string("Deviation x momentum", "Second axis y",
     options = ["Deviation x momentum", "Deviation x order flow (LTF volume delta)",
     "Deviation x order flow (CLV x volume proxy)", "Return x volatility change",
     "Deviation x open-interest change"],
     group = G_AX,
     tooltip = "Momentum is close to the derivative of x, so it is not an independent source. A circle appearing is then unremarkable and is not evidence of predictive content: measured, the signed consistency is -0.283 with no lag against -0.036 at the default lag of one bar. The causally meaningful choices are order flow and open interest.")

yLag     = input.int(1, "Lag on the second axis (bars)", minval = 0, maxval = 10, group = G_AX,
     tooltip = "At 0, y_t carries the same bar as x_t and a contemporaneous relationship is easily mistaken for a predictive one. This is the parameter that decides whether the measurement means anything: median signed consistency is -0.283 at lag 0 and -0.036 at the default lag of 1. The default measures how past flow turns against present position.")
detrendLen = input.int(34, "Equilibrium EMA (detrends x)", minval = 5, group = G_AX)
rvLen      = input.int(12, "Realised volatility window", minval = 3, group = G_AX)
ltfInput   = input.timeframe("", "Lower timeframe for volume delta (blank = auto)", group = G_AX)

// --- 2. normalisation --------------------------------------------------------
zLen     = input.int(40, "Rolling z-score length", minval = 10, group = G_NM)
useWhite = input.bool(true, "Apply 2x2 whitening", group = G_NM,
     tooltip = "Correlated axes make the trajectory a tilted ellipse, so dtheta can look like rotation when nothing is rotating. Whitening sends the covariance to the identity. Measured effect here is small - median |C| 0.133 with it on, 0.138 with it off - so treat it as hygiene, not as what makes the reading work.")
useAnchor  = input.bool(false, "Freeze the normalisation statistics (anchored)", group = G_NM,
     tooltip = "Freezes mu, sigma and the whitening matrix at a chosen bar and never updates them again, so the normalising statistics come from a training span only. Off means rolling, which suits live use but lets the axes stretch over time.")
anchorAfter = input.int(250, "Bars before freezing (after warm-up)", minval = 50, group = G_NM)
clampAbs   = input.float(4.0, "z clip", minval = 2.0, step = 0.5, group = G_NM)

// --- 3. windows and gate -----------------------------------------------------
cohLen   = input.int(48, "Consistency window for C", minval = 5,  group = G_WN,
     tooltip = "48, not the 24 this script originally shipped with - but not for the reason first published. 48 was chosen because it drove a shuffled-y null to zero while the real rate held up. That null also destroyed y's autocorrelation, which by itself pushes C toward zero, so the gap was an artefact of the null rather than a property of the window.\n" +
     "Against a circular shift of y, which keeps the autocorrelation and breaks only the alignment, the real rate is not distinguishable from the null on BTCUSDT and is below it on ETHUSDT. The window stays at 48 as the more conservative reading. It still decides whether the verdict exists at all - at 96 it fires on a single bar out of 3712 on BTCUSDT and on none at all on ETHUSDT - but no setting of it makes the verdict separate from the shift null. At 24 the real rate is below the null median on both symbols.")
windLen  = input.int(32, "Winding window for W", minval = 8,  group = G_WN)
areaLen  = input.int(24, "Loop-area window for A", minval = 8, group = G_WN)
angGate  = input.float(3.14159, "Total-turning gate, sum |dtheta| (rad)", minval = 0.0, step = 0.1, group = G_WN,
     tooltip = "Spans turning less than this report C and S* as undetermined (na). Without it, three angles of 0.001 each still give C = 1. Half a turn, pi, is the default - a safeguard that never bound on the data measured here. Total turning over the 48-bar window had a median of 27.7 rad on BTCUSDT and 26.3 on ETHUSDT, and its smallest value on either symbol was 12.6, four times the gate. Zero bars out of 3856 fell below it.\n" +
     "Relation to the window N: you need mean |dtheta| > pi/N, that is a cycle faster than about 2N bars. At the default N = 48 that resolves cycles up to 96 bars. Raising the gate is more conservative.")
deadZone = input.float(0.30, "Central dead zone (radius)", minval = 0.0, step = 0.05, group = G_WN,
     tooltip = "Near the origin the angle is pure noise, so spans inside this radius count as dtheta = 0. Measured effect is small: moving it from 0 to 1.0 moves median |C| from 0.144 to 0.128.")
omegaLen = input.int(5,  "EMA for angular velocity omega", minval = 1, group = G_WN)
warmMult = input.int(3,  "Warm-up multiplier (x longest window)", minval = 1, maxval = 6, group = G_WN,
     tooltip = "Computing from bar 5 against a z-score length of 40 inflates the radius for lack of sample. The default discards three times the longest window.")

// --- 4. regimes --------------------------------------------------------------
cohTh    = input.float(0.45, "|C| counted as orbital rotation",       minval = 0.0, maxval = 1.0, step = 0.05, group = G_RG,
     tooltip = "Rare, and not established. At the default window this fires on 1.84% of BTCUSDT 1H bars and 0.29% of ETHUSDT bars, in 8 contiguous episodes on each. Against a null that circularly shifts y - preserving its autocorrelation and breaking only its alignment with x - 5 of 20 draws match or beat the BTCUSDT rate, and 20 of 20 beat the ETHUSDT one. Treat the coloured band as a label for a state, not as evidence that the state is real. Phase noise takes 59.2% of BTC bars and 51.7% of ETH bars.")
spiTh    = input.float(0.030, "|S*| counted as a spiral",          minval = 0.0, step = 0.005, group = G_RG)
coreTh   = input.float(0.55, "radius r counted as the core",        minval = 0.0, step = 0.05, group = G_RG)
slipTh   = input.float(2.80, "H counted as a phase slip",          minval = 0.0, step = 0.1,  group = G_RG)

// --- 5. display --------------------------------------------------------------
showC    = input.bool(true,  "Signed consistency C", group = G_DP)
showS    = input.bool(true,  "Spiral index S* (tanh compressed)", group = G_DP)
showW    = input.bool(false, "Winding number W", group = G_DP)
showOm   = input.bool(false, "Angular velocity omega (rad/bar)", group = G_DP,
     tooltip = "Off by default because of units, not usefulness. C and S* are both dimensionless and bounded to [-1, 1] by construction; omega is rad/bar and reaches |1.92| on BTCUSDT 1H against max |C| 0.597 and max |S*| 0.768. On a shared axis omega therefore sets the scale and flattens the two series the pane is about. Turn it on to read turning rate, and expect the pane to rescale.")
showA    = input.bool(false, "Loop area A (normalised)", group = G_DP)
showBg   = input.bool(true,  "Regime background", group = G_DP,
     tooltip = "Expect stripes rather than blocks, and read that as the result. Measured on BTCUSDT 1H at the defaults, the classification changes verdict on 34.5% of bars and the median unbroken run is 1 bar (90th percentile 6 bars). On ETHUSDT it is 38.0%, again a median run of 1 bar. These are per-bar verdicts that happen to be drawn as bands; they are not persistent regimes, and nothing here smooths them into looking like one.")
showSlip = input.bool(true,  "Phase-slip markers", group = G_DP)
sScale   = input.float(0.15, "tanh compression scale for S*", minval = 0.01, step = 0.01, group = G_DP)

// --- 6. MTF ------------------------------------------------------------------
useMTF   = input.bool(false, "Show MTF phase sync R", group = G_MT,
     tooltip = "Kuramoto order parameter R = |sum e^(i theta)| / n over the phase of each timeframe. R near 1 means every timeframe is in phase. Intended as a regime gate for an existing multi-timeframe strategy, not as a signal on its own. The phase is always computed from price x momentum, to avoid nesting requests.\n" +
     "Units, as with omega: R lives on [0, 1] and is positive only, while C and S* are signed on [-1, 1]. Switching it on therefore rescales the pane and compresses the two series it sits beside. It is drawn beneath C so it cannot hide it.")
mtf1     = input.timeframe("240", "Higher timeframe 1", group = G_MT,
     tooltip = "Was 60, which on the shipped 1H chart is the chart timeframe itself - two of the three phases were then identical and R could not fall below 1/3 whatever the market did. Set both of these above your chart timeframe or the same degeneracy returns.")
mtf2     = input.timeframe("720", "Higher timeframe 2", group = G_MT)

// --- 7. experimental signals -------------------------------------------------
showSig  = input.bool(false, "Draw experimental signal arrows", group = G_SG,
     tooltip = "Audit result: shuffling the second axis barely dented the performance of these arrows, which points at the plain condition underneath - an |x| threshold plus a three-bar return reversal - rather than at anything rotational. They remain for comparison only and are not recommended.")
sigEdge  = input.float(0.80, "Reversal: |x| threshold",   step = 0.05, group = G_SG)
sigBrk   = input.float(0.95, "Break: |x| threshold", step = 0.05, group = G_SG)
sigR     = input.float(1.15, "Break: minimum radius r", step = 0.05, group = G_SG)
sigCool  = input.int(8, "Cooldown (bars)", minval = 1, group = G_SG)

// =============================================================================
//  Helpers
// =============================================================================
atan2(float yy, float xx) =>
    float a = 0.0
    if xx > 0
        a := math.atan(yy / xx)
    else if xx < 0
        a := yy >= 0 ? math.atan(yy / xx) + math.pi : math.atan(yy / xx) - math.pi
    else
        a := yy > 0 ? math.pi * 0.5 : yy < 0 ? -math.pi * 0.5 : 0.0
    a

// Freeze a value at anchorIdx. With useAnchor = false the latest value always passes.
// Each call site gets its own var instance.
freeze(float v, bool useAnc, int atIdx) =>
    var float held = na
    if not useAnc
        held := v
    else if na(held) and bar_index >= atIdx and not na(v)
        held := v
    held

autoLTF() =>
    int s = timeframe.in_seconds()
    s <= 60 ? "1S" : s <= 300 ? "5S" : s <= 900 ? "15S" : s <= 3600 ? "1" : s <= 14400 ? "5" : "60"

// Phase used by the MTF calculation - price x momentum only, so no request is nested.
rotorPhase() =>
    float lp_  = math.log(close)
    float dev_ = lp_ - ta.ema(lp_, detrendLen)
    float rr_  = lp_ - nz(lp_[1], lp_)
    float mom_ = ta.ema(rr_, 5) - ta.ema(rr_, 18)
    float zx_  = (dev_ - ta.sma(dev_, zLen)) / math.max(ta.stdev(dev_, zLen), 1e-6)
    float zy_  = (mom_ - ta.sma(mom_, zLen)) / math.max(ta.stdev(mom_, zLen), 1e-6)
    atan2(zy_, zx_)

// =============================================================================
//  External data. request.* must sit at global scope, so all four calls below run
//  on every bar whatever the settings are. What CAN be made conditional is the
//  timeframe each one asks for. So the lower-timeframe pull only asks for a real
//  lower timeframe when the order-flow axis is selected, and the two phase
//  requests only ask for a higher timeframe when the Kuramoto readout is on.
//
//  What that does NOT buy you is a free script. All four calls still execute on
//  every bar, and each phase request re-runs rotorPhase() in its own context
//  even when it is pointed at the chart timeframe. The cost of that has not been
//  measured, so no claim is made about it here. Two chart tabs were observed going
//  unresponsive on a two-core machine during this work: one on the sibling script in
//  this series with a lower-timeframe request running at full cost, and one here
//  during a symbol change. Neither was isolated to the indicator, and machine size
//  could not be separated from load.
// =============================================================================
bool wantLTF = axMode == "Deviation x order flow (LTF volume delta)"
string ltfUse = not wantLTF ? timeframe.period : (ltfInput == "" ? autoLTF() : ltfInput)

// Signed lower-timeframe volume, uptick minus downtick. Empty array when unavailable.
array<float> ltfDelta = request.security_lower_tf(syminfo.tickerid, ltfUse,
     close > close[1] ? volume : close < close[1] ? -volume : 0.0,
     ignore_invalid_symbol = true, ignore_invalid_timeframe = true)

// Open interest, for perpetuals and the like. na where there is none.
float oiRaw = request.security(ticker.new(syminfo.prefix, syminfo.ticker + "_OI"),
     timeframe.period, close, ignore_invalid_symbol = true,
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// The calls themselves always run; with useMTF off they are pointed at the chart
// timeframe, so they resolve to the local phase rather than fetching another one.
string mtf1Use = useMTF ? mtf1 : timeframe.period
string mtf2Use = useMTF ? mtf2 : timeframe.period
float phCur = rotorPhase()
float phH1  = request.security(syminfo.tickerid, mtf1Use, rotorPhase(),
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float phH2  = request.security(syminfo.tickerid, mtf2Use, rotorPhase(),
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// =============================================================================
//  The raw axes (x_raw, y_raw)
// =============================================================================
float logP = math.log(close)
float ret  = logP - nz(logP[1], logP)
float dev  = logP - ta.ema(logP, detrendLen)

float momentum = ta.ema(ret, 5) - ta.ema(ret, 18)

float rv     = math.sqrt(ta.sma(ret * ret, rvLen))
float dRV    = rv - nz(rv[1], rv)

// Lower-timeframe volume delta, normalised by volume into a flow imbalance
// With ignore_invalid_*, an unavailable bar yields an empty array rather than na.
int   ltfN   = array.size(ltfDelta)
float ltfSum = 0.0
if ltfN > 0
    ltfSum := array.sum(ltfDelta)
bool  ltfOK  = ltfN > 0 and volume > 0
float ofiLTF = ltfOK ? ltfSum / math.max(volume, 1e-9) : na

// CLV, the substitute where lower-timeframe data is unavailable. Price-derived, so less independent.
float rangeHL = high - low
float clv     = rangeHL > 0 ? (2.0 * (close - low) / rangeHL - 1.0) : 0.0
float ofiCLV  = clv

float dOI = na(oiRaw) ? na : oiRaw - nz(oiRaw[1], oiRaw)

float xRaw = na
float yRaw = na
if axMode == "Deviation x momentum"
    xRaw := dev
    yRaw := momentum
else if axMode == "Deviation x order flow (LTF volume delta)"
    xRaw := dev
    // Silent substitution. Beyond the intrabar history limit, or on a plan that cannot
    // serve the chosen lower timeframe, this falls back to the CLV proxy with no visible
    // break in the plot. The history you are looking at can therefore be a mixture of two
    // structurally different second axes, and every Data Window figure inherits it. Watch
    // the y axis position for a step change if that matters to you.
    yRaw := na(ofiLTF) ? ofiCLV : ofiLTF
else if axMode == "Deviation x order flow (CLV x volume proxy)"
    xRaw := dev
    yRaw := ofiCLV
else if axMode == "Return x volatility change"
    xRaw := ret
    yRaw := dRV
else
    xRaw := dev
    yRaw := dOI

// Lag on the second axis: pins y_t to past information and breaks the contemporaneous loop.
float yLagged = yRaw[yLag]

// =============================================================================
//  Normalisation, then whitening
// =============================================================================
// Discard warmMult x the longest window. Ternaries keep this int rather than relying on math.max typing.
int longest = zLen > detrendLen ? zLen : detrendLen
longest := windLen > longest ? windLen : longest
longest := areaLen > longest ? areaLen : longest
longest := cohLen > longest ? cohLen : longest   // cohLen is usually the largest of them
int warmBars  = warmMult * longest
int anchorIdx = warmBars + anchorAfter

float muX = freeze(ta.sma(xRaw,    zLen), useAnchor, anchorIdx)
float sdX = freeze(ta.stdev(xRaw,  zLen), useAnchor, anchorIdx)
float muY = freeze(ta.sma(yLagged, zLen), useAnchor, anchorIdx)
float sdY = freeze(ta.stdev(yLagged, zLen), useAnchor, anchorIdx)

float zx = (xRaw    - muX) / math.max(nz(sdX), 1e-6)
float zy = (yLagged - muY) / math.max(nz(sdY), 1e-6)

// Inverse square root of the 2x2 symmetric matrix S:
//   s = sqrt(det S), t = sqrt(tr S + 2s)
//   S^(-1/2) = [[c+s, -b], [-b, a+s]] / (s*t)
// When anchored, this is the covariance of already z-scored coordinates, so it sits close to
// [[1,rho],[rho,1]] and the inconsistency of measuring it as mu and sigma freeze stays small.
float vxx = freeze(ta.variance(zx, zLen), useAnchor, anchorIdx)
float vyy = freeze(ta.variance(zy, zLen), useAnchor, anchorIdx)
float vxy = freeze(ta.sma(zx * zy, zLen) - ta.sma(zx, zLen) * ta.sma(zy, zLen), useAnchor, anchorIdx)

float detS = math.max(nz(vxx) * nz(vyy) - nz(vxy) * nz(vxy), 1e-10)
float sS   = math.sqrt(detS)
float tS   = math.sqrt(math.max(nz(vxx) + nz(vyy) + 2.0 * sS, 1e-10))
float k    = 1.0 / math.max(sS * tS, 1e-10)

float w11 = (nz(vyy) + sS) * k
float w12 = -nz(vxy) * k
float w22 = (nz(vxx) + sS) * k

float xw0 = useWhite ? w11 * zx + w12 * zy : zx
float yw0 = useWhite ? w12 * zx + w22 * zy : zy

float x = math.max(-clampAbs, math.min(clampAbs, xw0))
float y = math.max(-clampAbs, math.min(clampAbs, yw0))

// =============================================================================
//  Rotation geometry
// =============================================================================
float r = math.sqrt(x * x + y * y)

float cross = nz(x[1]) * y - nz(y[1]) * x
float dot   = nz(x[1]) * x + nz(y[1]) * y

// Central dead zone: angles near the origin are noise and are not counted as turning.
// The mask applies identically to dtheta, area and dln r. Masking only one of them creates a
// ratio whose numerator accumulates while its denominator does not, breaking S* and A.
bool  inDead = r < deadZone or nz(r[1], 0.0) < deadZone
bool  skip   = inDead or bar_index < 2
float dth    = skip ? 0.0 : atan2(cross, dot)
float segA   = skip ? 0.0 : 0.5 * cross

float omega = ta.ema(dth, omegaLen)

// --- signed rotation consistency C, with the total-turning gate ---
float sTurn = math.sum(dth, cohLen)
float aTurn = math.sum(math.abs(dth), cohLen)
bool  gateOK = aTurn > angGate
float coh = gateOK ? sTurn / math.max(aTurn, 1e-9) : na

// --- spiral index S*, scale invariant: dln r per radian ---
// The 0.05 stops the log diverging near the origin. With deadZone = 0.30 the spans that
// actually accumulate have r far above 0.05, so the effect on S* is a few per cent.
float lr    = math.log(r + 0.05)
float dlr   = skip ? 0.0 : lr - nz(lr[1], lr)
float sStar = gateOK ? math.sum(dlr, cohLen) / math.max(aTurn, 1e-9) : na

// --- winding number W ---
float wind = math.sum(dth, windLen) / (2.0 * math.pi)

// --- signed loop area A, normalised by swept area into something dimensionless ---
float r2m      = skip ? 0.0 : r * r
float areaRaw  = math.sum(segA, areaLen)
float areaNorm = areaRaw / math.max(0.5 * math.sum(r2m, areaLen), 1e-9)

// --- phase-slip hazard H ---
float omSlow  = ta.ema(dth, 13)
float dthSd   = ta.stdev(dth, 24)
float surprise = math.abs(dth - omSlow) / math.max(dthSd, 0.05)
float cohNow  = nz(coh, 0.0)
float cohPrev = nz(coh[1], 0.0)
float cohDrop = math.max(0.0, math.abs(cohPrev) - math.abs(cohNow)) * 2.5
float flip    = (cohPrev * cohNow < 0 and math.abs(cohPrev) > 0.40) ? 1.5 : 0.0
float hz      = math.max(0.0, math.min(5.0, surprise + cohDrop + flip))

// =============================================================================
//  Warm-up gate
// =============================================================================
bool ready = bar_index >= warmBars and (not useAnchor or bar_index >= anchorIdx)

float R_    = ready ? r        : na
float OM_   = ready ? omega    : na
float C_    = ready ? coh      : na
float S_    = ready ? sStar    : na
float W_    = ready ? wind     : na
float A_    = ready ? areaNorm : na
float H_    = ready ? hz       : na
float TA_   = ready ? aTurn    : na

// =============================================================================
//  Regime classification
// =============================================================================
// 0 undetermined / 1 phase slip / 2 core / 3 too little turning / 4 outward spiral
// 5 inward spiral / 6 orbital rotation / 7 phase noise
int regime = 0
if ready
    if H_ > slipTh
        regime := 1
    else if R_ < coreTh
        regime := 2
    else if na(C_)
        regime := 3
    else if S_ > spiTh
        regime := 4
    else if S_ < -spiTh
        regime := 5
    else if math.abs(C_) > cohTh
        regime := 6
    else
        regime := 7

color cSlip  = color.new(#e8467c, 82)
color cCore  = color.new(#7a7f8c, 90)
color cUnres = color.new(#5a6070, 92)
color cOut   = color.new(#f0a020, 85)
color cIn    = color.new(#3aa0ff, 87)
color cOrb   = color.new(#2ecc71, 87)
color cNoise = color.new(#8a8f9c, 92)

color bgCol = regime == 1 ? cSlip : regime == 2 ? cCore : regime == 3 ? cUnres :
              regime == 4 ? cOut  : regime == 5 ? cIn   : regime == 6 ? cOrb  :
              regime == 7 ? cNoise : na

bgcolor(showBg ? bgCol : na, title = "Regime background")

// =============================================================================
//  MTF phase sync (Kuramoto order parameter)
// =============================================================================
float kuraR = na
if useMTF and not na(phCur)
    float sc = math.cos(phCur)
    float ss = math.sin(phCur)
    int   nn = 1
    if not na(phH1)
        sc := sc + math.cos(phH1)
        ss := ss + math.sin(phH1)
        nn := nn + 1
    if not na(phH2)
        sc := sc + math.cos(phH2)
        ss := ss + math.sin(phH2)
        nn := nn + 1
    kuraR := math.sqrt(sc * sc + ss * ss) / nn

// =============================================================================
//  Plots. No table - the secondary quantities are read in the Data Window.
// =============================================================================
// hline wants an input-qualified price and -cohTh is simple, so it cannot be passed to hline.
// The threshold lines are drawn with plot instead.
hline(0.0, "0", color = color.new(color.gray, 55), linestyle = hline.style_dotted)
plot(cohTh,  "+|C| threshold", color = color.new(color.gray, 55), editable = false)
plot(-cohTh, "-|C| threshold", color = color.new(color.gray, 55), editable = false)

// Pine has no tanh, so it is written out. The argument is clipped to keep exp away from 709.
float sArg  = na(S_) ? na : math.max(-20.0, math.min(20.0, 2.0 * S_ / sScale))
float sExp  = na(sArg) ? na : math.exp(sArg)
float sPlot = na(sExp) ? na : (sExp - 1.0) / (sExp + 1.0)
plot(showS  ? sPlot : na, "S* spiral (tanh compressed)", color = color.new(#f0a020, 30),
     style = plot.style_area, linewidth = 1)

// R is positive-only on [0, 1] and would otherwise draw over C, so it goes first.
plot(useMTF ? kuraR : na, "R phase sync (Kuramoto)", color = color.new(#ffffff, 25), linewidth = 1)

color cohColor = na(C_) ? color.new(color.gray, 60) : C_ >= 0 ? color.new(#2ecc71, 0) : color.new(#e8467c, 0)
plot(showC  ? C_ : na, "C signed consistency", color = cohColor, linewidth = 2)
plot(showOm ? OM_ : na, "omega angular velocity", color = color.new(#3aa0ff, 15), linewidth = 1)
plot(showW  ? W_  : na, "W winding number", color = color.new(#b07cff, 25), linewidth = 1)
plot(showA  ? A_  : na, "A loop area (normalised)", color = color.new(#00d6c2, 30), linewidth = 1)

plotchar(showSlip and ready and H_ > slipTh, "Phase slip", "•", location.top,
     color = color.new(#e8467c, 0), size = size.tiny)

// --- Data Window only, so the raw values are readable without wrecking the pane scale ---
plot(R_,  "r radius",        display = display.data_window)
plot(S_,  "S* raw",       display = display.data_window)
plot(H_,  "H phase-slip hazard",    display = display.data_window)
plot(TA_, "sum |dtheta| total turning", display = display.data_window)
plot(ready ? x : na, "x position", display = display.data_window)
plot(ready ? y : na, "y drive", display = display.data_window)
plot(ready ? areaRaw : na, "A raw loop area", display = display.data_window)
plot(regime, "Regime number", display = display.data_window)

// =============================================================================
//  Experimental signals. Off by default and unvalidated - see the header.
// =============================================================================
float ret3 = logP - nz(logP[3], logP)

var int lastSig = -100000
bool cooled = bar_index - lastSig >= sigCool

bool buyRev = ready and cooled and x < -sigEdge and ret3 > 0 and nz(ret3[1], 0.0) <= 0 and
     not na(C_) and math.abs(C_) > 0.32 and not na(S_) and S_ < spiTh and H_ < 3.2
bool selRev = ready and cooled and x >  sigEdge and ret3 < 0 and nz(ret3[1], 0.0) >= 0 and
     not na(C_) and math.abs(C_) > 0.32 and not na(S_) and S_ < spiTh and H_ < 3.2
bool buyBrk = ready and cooled and nz(x[1]) <= sigBrk and x > sigBrk and ret3 > 0 and
     R_ > sigR and not na(S_) and S_ > spiTh and H_ < 4.2
bool selBrk = ready and cooled and nz(x[1]) >= -sigBrk and x < -sigBrk and ret3 < 0 and
     R_ > sigR and not na(S_) and S_ > spiTh and H_ < 4.2

if buyRev or selRev or buyBrk or selBrk
    lastSig := bar_index

plotshape(showSig and buyRev, "Reversal BUY",  shape.triangleup,   location.belowbar,
     color.new(#2ecc71, 0), size = size.tiny, force_overlay = true)
plotshape(showSig and selRev, "Reversal SELL", shape.triangledown, location.abovebar,
     color.new(#e8467c, 0), size = size.tiny, force_overlay = true)
// Colour carries direction, shape carries type. Both breaks were #f0a020 before,
// which made them indistinguishable from each other and shared S*'s hue.
plotshape(showSig and buyBrk, "Break BUY",  shape.arrowup,   location.belowbar,
     color.new(#2ecc71, 0), size = size.small, force_overlay = true)
plotshape(showSig and selBrk, "Break SELL", shape.arrowdown, location.abovebar,
     color.new(#e8467c, 0), size = size.small, force_overlay = true)

// =============================================================================
//  Alerts
// =============================================================================
alertcondition(ready and regime == 1 and nz(regime[1]) != 1, "Phase slip",
     "Market Rotor: entered the phase-slip state (hazard H above threshold)")
alertcondition(ready and regime == 4 and nz(regime[1]) != 4, "Transition to outward spiral",
     "Market Rotor: entered the outward-spiral state (S* above threshold)")
alertcondition(ready and regime == 6 and nz(regime[1]) != 6, "Transition to orbital rotation",
     "Market Rotor: entered the orbital-rotation state (|C| above threshold; a label, not an established state)")
alertcondition(ready and not na(C_) and not na(C_[1]) and C_ * C_[1] < 0, "Rotation direction flipped",
     "Market Rotor: the direction of rotation flipped")
````
