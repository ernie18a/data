# Market Rotor - Increment Contamination Test [FibonacciFlux]

- url: https://www.tradingview.com/script/4VU2zVYa-Market-Rotor-Increment-Contamination-Test-FibonacciFlux/
- type: indicator
- pine_id: PUB;ddf0dad2d2d54f9ab6ad308f7f500ebd
- version: 1.0

## Description

Second in a series of published experiments: take a correction that is widely assumed to work, implement it honestly, and find out what it actually does. This one tests the most common way of accidentally manufacturing rotation - putting the same-bar price increment into the second axis and then reading the resulting circulation as structure.

[b]It detects that contamination reliably, though not precisely - the spread is measured below. It cannot do the converse, and the boundary where it starts getting the converse wrong is measured below.[/b]

🔶 USAGE

🔹 What this is for

Any indicator that claims rotation, circulation or lead-lag between price and a flow-like series is reading the antisymmetric part of a lag-1 covariance. Load your two axes here first. If the reading comes back near 1, the circulation that indicator is showing you is the increment leaking into its own second axis, and there is nothing else to interpret.

🔹 Reading the shading

[list]
[*]Red - the ratio sits within 0.25 of 1. An increment-contamination component accounts for the observed circulation.
[*]Grey - anything else. Not classified. This is not evidence that the rotation is genuine.
[/list]

https://www.tradingview.com/x/E2i6dCBj/

BTCUSDT 1H at the defaults. The band is red across effectively the whole span, and that is the finding rather than a rendering quirk: on this data the circulation between price and flow is contamination-shaped nearly all of the time. Note also how much of the pane the amber R_art area occupies relative to the pale R_obs line running through it - the artifact term is routinely larger in magnitude than the thing it is decomposing, which is why the ratio sits above 1 in about two thirds of readings.

There is no green state, for the same reason as in the first script: this test is one-directional. It can find contamination; it cannot certify its absence.

🔹 Reading the plots

The amber filled area is R_art, the circulation Identity I alone accounts for; the pale line inside it is R_obs, the observed circulation; green is R_res, what is left. The verdict band is red rather than amber precisely so that it is not the same colour as the series it is a verdict about.

[b]The ratio is a signed share, not a fraction.[/b] R_res is defined as R_obs - R_art, so the additive identity cannot fail and proves nothing by itself; what justifies the split is that LAMBDA is linear in y, so writing y = beta*dx + e gives R_art and R_res exactly as the circulation contributed by each part. Nothing bounds the ratio to [0, 1], and on real data it usually is not there: on BTCUSDT 1H it exceeds 1 in 66% of readings on the default axis, 79% on the order-flow axis. Read "near 1" as "contamination accounts for it", never as a percentage of it.

The Data Window carries the ratio, beta, corr(y, dx), LAMBDA, T_K and both axes.

🔹 Choosing the second axis

[b]CLV x volume is the default, and deliberately not the best proxy.[/b] Order flow from lower-timeframe volume delta is the better second axis. The original reason for not defaulting to it was that a chart tab hung twice while it was selected, once on a daily chart and once on the 1H default, both on a two-core machine.

[b]That attribution has since weakened and this paragraph is the correction.[/b] Both of those tabs stopped responding during automated testing, not during ordinary use. The same symptom later appeared twice more with no lower-timeframe request involved at all, and the axis has since been selected and exercised on a 1H chart without incident. Nothing here is attributable to the request. The default stays on CLV as the conservative choice rather than as a fix for a diagnosed problem - select order flow deliberately, not nervously.

What the default does buy you is real, and it is a cost rather than a hazard: request.* must sit at global scope, so the call always runs, but the timeframe it asks for is now conditional. On any axis other than order flow it is pointed at the chart's own timeframe and returns one intrabar per bar instead of sixty.

Volume z-score on its own is the useful control: it carries almost no increment at all (beta +0.016, corr +0.009), and its ratio consequently degenerates - a non-verdict, not a clean bill of health. [b]Momentum is a control, not a choice[/b] - it sets y to a difference of return EMAs, which is nearly dx itself. Watch beta when you switch to it, not the ratio: measured on one bar of BTCUSDT 1H the ratio barely moved (1.119 to 1.084) because the default is already saturated near 1, while beta on that same bar jumped from 0.838 to 1.270. The identity is firing; the ratio has no room left to show it.

The four axes disagree, and that is information rather than a defect. On one bar of BTCUSDT 1H: order flow 1.119, CLV x volume 0.965, momentum 1.084 - and volume z-score -2.104, which is not a verdict at all but the signature of a near-zero denominator, discussed below.

🔹 Warm-up and repainting

Nothing plots until 2 x W + z-length + detrend-length bars have elapsed: 574 at the defaults, about 24 days of 1H data.

[b]Two things that will bite you.[/b] First, when R_obs is near zero the ratio is meaningless and still prints to five decimals - on the volume z-score axis this was measured at R_obs 0.013 giving a ratio of -2.10 with beta 0.07, that is, no contamination at all and a nonsense ratio. Read LAMBDA first: if there is no circulation, decomposing it means nothing. Second, if you switch to the order-flow axis, set the lower timeframe explicitly before going above 4H - on a daily chart the warm-up needs roughly 14,000 intrabars.

[b]And one silent substitution.[/b] Where the lower-timeframe request returns nothing - beyond the intrabar history limit, or on a plan that cannot serve the chosen lower timeframe - y falls back to CLV with no visible break. The plotted history can therefore be a mixture of two different second axes with an invisible switchover, and every Data Window statistic inherits it. Watch corr(y, dx) and beta for a step change if that matters to you.

🔶 DETAILS

🔹 The identity being tested

[pine]
R_obs = 2 * LAMBDA,  LAMBDA = 0.5 * mean_W[ x_s*y_{s+1} - y_s*x_{s+1} ]
if y carries the same-bar increment dx with coefficient beta then
Q(w) = -beta * S_xx(w) * sin(w)   appears with no rotation present at all
beta  = cov_W(dx, y) / var_W(dx)
R_art = 2 * beta * 0.5 * mean_W[ x_s*dx_{s+1} - dx_s*x_{s+1} ]
[/pine]

In discrete time x_s(y_{s+1}-y_s) - y_s(x_{s+1}-x_s) collapses exactly to x_s*y_{s+1} - y_s*x_{s+1}, so the circulation needs no angles, no atan2, no origin estimate and no lag operator. An earlier version of this work used atan2 and every one of those was required - each a free parameter able to manufacture the result.

Call it circulation, not a rotation rate: mean[x*ydot - y*xdot] is mean[r^2 * phidot], an areal velocity, and it equals a rotation rate only if the squared radius and the angular velocity are uncorrelated.

🔹 What it detects, and what it does not

Reimplemented outside Pine and swept over synthetic series whose truth is known by construction, 5 seeds, W = 250:

[list]
[*]y = beta*dx + noise, no rotation at all - the ratio has median 0.94 to 0.97 with a 10th-to-90th percentile spread of roughly 0.77 to 1.17. Centred on 1, but not precise, and independent of the sign of beta.
[*]a clean 2-D rotation with no dx in y at all - the ratio reads 0.46 to 0.83, rising with rotation speed. The test therefore cannot certify that a rotation is genuine.
[/list]

The false positive depends on persistence at least as much as on speed. The rotation speed at which a clean, uncontaminated rotation starts reading above 0.75 and is reported as contamination, by the AR persistence rho of the rotating system:

[pine]
rho 0.90    never, up to 1.5 rad/bar
rho 0.95    0.50 - 0.70 rad/bar   (~9-13 bar cycle)
rho 0.98    0.25 - 0.40 rad/bar   (~16-25 bar cycle)
rho 0.995   0.12 - 0.16 rad/bar   (~39-52 bar cycle)
[/pine]

W and the noise level did not move that boundary; persistence moved it by more than 5x.

The sign of beta is deliberately not used for anything. Across more than 50 configurations it tracks the sign of whatever coupling exists, flipping with the direction of a genuine rotation as readily as with the sign of the contamination. Related structural fact, worth checking rather than trusting: LXD is non-positive by construction, so the sign of R_art is fixed by the sign of beta. Measured across synthetic rotation in both directions, synthetic contamination and real data, LXD was positive in 0.0% of readings.

🔹 On real data

Two structurally different flow proxies give the same verdict on 1H crypto, which is the finding worth taking away:

[pine]
                        ratio    beta    corr(y,dx)
CLV x volume  BTCUSDT    1.082   +0.49     +0.30
              ETHUSDT    1.085   +0.58     +0.36
taker flow    BTCUSDT    1.090   +0.79     +0.47
              ETHUSDT    1.052   +0.65     +0.39
volume z      BTCUSDT    0.664   +0.016    +0.009   <- the control
[/pine]

My own earlier work on this data, which this script reimplements, reported 108.3% with corr +0.377 on its own flow proxy, and the live script on lower-timeframe volume delta reads 1.119 with corr +0.533. Four different constructions of the second axis, one answer: the circulation people read between price and flow is the increment leaking into the flow axis.

🔹 Implementation and reproducibility

Covariances are computed from their definition because Pine has no ta.cov. y is never lagged: an earlier cycle established that lagging it manufactures rotation and reverses the sign of the true antisymmetric lag covariance. The x pipeline was verified against an independent reimplementation - identical to five decimal places on the same bar. The synthetic scenarios use a seeded generator, so every number above is reproducible.

🔶 SETTINGS

🔹 Axes

[list]
[*]Second axis y - CLV x volume (default), order flow from lower-timeframe volume delta, volume z, or the momentum control.
[*]Equilibrium EMA - detrends x (default 34).
[*]Z-score length - standardises both axes (default 40).
[*]Lower timeframe for volume delta - blank picks one from the chart timeframe.
[/list]

🔹 Windows

[list]
[*]Rolling window W - LAMBDA, beta and T_K are all estimated over it (default 250, minimum 100; shorter windows make the verdict band fragment into bar-to-bar stripes).
[*]Warm-up multiplier - bars withheld before plotting, as a multiple of W (default 2).
[/list]

🔹 Display

[list]
[*]R_obs, R_art, R_res - the three series.
[*]T_K residual torque - off by default; a volume-weighted detailed-balance statistic that did not survive its own null.
[*]Shade background when contamination is identified - the red band.
[*]T_K display scale - default 30, because T_K is far smaller than the three circulation series and draws as a flat line on zero at 1; 30 is simply what made it readable here.
[/list]

Open source under the Mozilla Public License 2.0. Replications and refutations welcome, particularly a second-axis construction that stays uncontaminated under a test I have not thought of.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
// =============================================================================
//  Market Rotor - Increment Contamination Test
// -----------------------------------------------------------------------------
//  Second in a series of published experiments. The first tested whether
//  heterogeneous autocorrelation could be subtracted out of cross-sectional
//  rotation. This one tests a different and much more common way of accidentally
//  manufacturing rotation: putting the same-bar price increment into the second
//  axis.
//
//  WHAT IS BEING TESTED
//
//  Take two standardised axes, x (detrended log price) and y (order flow, or
//  whatever you chose). The net circulation of the (x, y) point is
//
//      R_obs = 2*LAMBDA,   LAMBDA = 0.5 * mean_W[ x_s*y_{s+1} - y_s*x_{s+1} ]
//
//  because in discrete time x_s(y_{s+1}-y_s) - y_s(x_{s+1}-x_s) collapses
//  exactly to x_s*y_{s+1} - y_s*x_{s+1}. No angles, no atan2, no origin
//  estimate, no dead zone, and no lag operator - an earlier version of this
//  work used atan2 and every one of those was required, each one introducing a
//  free parameter that could manufacture the result.
//
//  Call it circulation rather than a rotation rate: mean[x*ydot - y*xdot] is
//  mean[r^2 * phidot], an areal velocity. It equals a rotation rate only if
//  r^2 and phidot are uncorrelated, which nothing here guarantees.
//
//  IDENTITY I: if y carries the same-bar increment dx with coefficient beta,
//  then Q(w) = -beta * S_xx(w) * sin(w) appears as a mathematical necessity,
//  with no rotation of any kind in the system. The implied artifact is
//
//      beta  = cov_W(dx, y) / var_W(dx)
//      R_art = 2 * beta * 0.5 * mean_W[ x_s*dx_{s+1} - dx_s*x_{s+1} ]
//      R_res = R_obs - R_art
//
//  WHY THE SPLIT IS THE RIGHT ONE. p_xy is linear in y, so LAMBDA is linear in
//  y. Splitting y = beta*dx + e therefore gives R_art = 2*beta*LXD and
//  R_res = 2*LAMBDA(x, e) exactly: R_art really is the rotation contributed by
//  the dx-projection of y, and R_res the rotation contributed by the rest.
//
//  WHAT THE RATIO IS NOT. R_res is *defined* as R_obs - R_art, so the additive
//  identity cannot fail and proves nothing on its own. R_art / R_obs is a
//  signed share, not a fraction: nothing bounds it to [0, 1] and on real data
//  it usually is not. On BTCUSDT 1H it exceeds 1 in 66% of readings on the
//  default axis and 79% on the order-flow axis, meaning R_art overshoots R_obs
//  and R_res comes back with the opposite sign. Read "near 1" as "contamination
//  accounts for it", never as "66% of it was contamination".
//
//  WHAT IT DOES AND DOES NOT DETECT - measured, not asserted
//
//  Independently reimplemented outside Pine and swept over synthetic series
//  whose truth is known by construction, 5 seeds, W = 250:
//
//    y = beta*dx + noise, no rotation at all   ratio median 0.94 to 0.97,
//        p10-p90 about 0.77 to 1.17. The reading does not depend on the sign
//        of beta. It is centred on 1 but it is not precise.
//
//    a clean 2-D rotation, no dx in y at all   ratio 0.46 to 0.83, rising
//        with rotation speed. The test CANNOT certify that an observed
//        rotation is genuine - it only ever detects contamination.
//
//  THE FALSE POSITIVE depends on persistence as much as on speed. The point at
//  which a clean rotation starts reading above 0.75 and gets reported as
//  contamination, by AR persistence rho of the rotating system:
//
//        rho 0.90    never, up to 1.5 rad/bar
//        rho 0.95    0.50 - 0.70 rad/bar   (~9-13 bar cycle)
//        rho 0.98    0.25 - 0.40 rad/bar   (~16-25 bar cycle)
//        rho 0.995   0.12 - 0.16 rad/bar   (~39-52 bar cycle)
//
//    W and noise level did not move it; persistence moved it by more than 5x.
//
//  The SIGN of beta is deliberately unused: over 50 configurations it tracks
//  the sign of whatever coupling exists and flips with the direction of a
//  genuine rotation as readily as with the sign of the contamination.
//
//  A structural fact worth checking rather than trusting: LXD is non-positive
//  by construction, since p_xd collapses to x_{t-2}*x_t - x_{t-1}^2 and
//  Cauchy-Schwarz bounds its mean. Measured over synthetic rotation in both
//  directions, synthetic contamination and real data: LXD > 0 in 0.0% of
//  readings. So sign(R_art) is fixed by -sign(beta).
//
//  ON REAL DATA. Two structurally different flow proxies give the same verdict
//  on 1H crypto, which is the point worth taking away:
//
//    CLV x volume (default)   BTC ratio 1.082, beta +0.49, corr +0.30
//                             ETH ratio 1.085, beta +0.58, corr +0.36
//    taker-flow imbalance     BTC ratio 1.090, beta +0.79, corr +0.47
//                             ETH ratio 1.052, beta +0.65, corr +0.39
//
//  Volume z-score on its own is the control that shows the ratio is not
//  measuring nothing: beta +0.016, corr +0.009 - no increment in that axis at
//  all - and the ratio degenerates to 0.66 with a huge spread, because its
//  denominator is near zero. That is a non-verdict, not a clean bill of health.
//
//  There is no green state anywhere in this script. The RED band means
//  contamination was identified; grey means it was not classified. Neither is
//  an all-clear, because the test is structurally one-directional. The band is
//  red rather than amber so that the verdict is not the same colour as the
//  amber R_art series it is a verdict about.
//
//  TWO THINGS THAT WILL BITE YOU
//
//  1. When R_obs is near zero the ratio is meaningless and still prints to five
//     decimals. On the "Volume z only" axis this was measured at R_obs 0.013
//     giving a ratio of -2.10 with beta 0.07 and corr(y, dx) 0.04 - that is, no
//     contamination at all and a nonsense ratio. Read LAMBDA first; if the
//     circulation is not there, the decomposition of it means nothing.
//
//  2. The order-flow axis is not the default, and the reason is weaker than an
//     earlier version of this header claimed. Two chart tabs stopped responding
//     during automated testing on a two-core machine while that axis was
//     selected, once on a daily chart where the warm-up needs ~14,000 intrabars.
//     The same symptom later appeared twice more with no lower-timeframe request
//     involved at all, and the axis has since run on a 1H chart without incident,
//     so none of it is attributable to the request. CLV stays the default as the
//     conservative choice, not as a fix for a diagnosed problem.
//
//     What the default does buy is a real cost saving, and note it is not the
//     absence of a call: request.* must sit at global scope, so the call always
//     runs. What is conditional is the timeframe it asks for. On any axis other
//     than order flow it asks for the chart's own timeframe and returns one
//     intrabar per bar instead of sixty. Select order flow deliberately, and set
//     the lower timeframe explicitly if you go above 4H.
//
//  A SILENT SUBSTITUTION TO KNOW ABOUT. When request.security_lower_tf returns
//  nothing - beyond the intrabar history limit, or on a plan that cannot serve
//  the chosen lower timeframe - y falls back to CLV without any visible break.
//  The plotted history can therefore be a mixture of two different second axes
//  with an invisible switchover. Check corr(y, dx) and beta for a step change
//  if that matters to you.
// =============================================================================

indicator("Market Rotor - Increment Contamination Test [FibonacciFlux]", "RotorIC", overlay = false, precision = 5)

G_AX = "1. Axes"
G_WN = "2. Windows"
G_DP = "3. Display"

// --- 1. Axes -----------------------------------------------------------------
axMode = input.string("CLV x volume", "Second axis y",
     options = ["CLV x volume", "Order flow (LTF volume delta)", "Volume z only", "Momentum (control)"],
     group = G_AX,
     tooltip = "CLV x volume is the default because it needs no intrabar data: the lower-timeframe request is pointed at the chart timeframe and returns one intrabar per bar. Order flow is the better proxy but pulls real intrabar data, which is the heavier path - select it deliberately. Volume z on its own carries almost no increment (beta about 0.02), so its ratio is a near-zero-denominator artefact rather than a verdict. Momentum sets y close to dx itself: watch beta there, not the ratio.")
detrendLen = input.int(34, "Equilibrium EMA (detrends x)", minval = 5, group = G_AX)
zLen       = input.int(40, "z-score length", minval = 10, group = G_AX)
ltfInput   = input.timeframe("", "Lower timeframe for volume delta (blank = auto)", group = G_AX)

// --- 2. Windows --------------------------------------------------------------
W        = input.int(250, "Rolling window W", minval = 100, group = G_WN,
     tooltip = "LAMBDA, beta and T_K are all estimated over this window. 250 is the value used in my own earlier work on this data, which this script reimplements.")
warmMult = input.int(2, "Warm-up multiplier (x W)", minval = 1, maxval = 5, group = G_WN)

// --- 3. Display --------------------------------------------------------------
showObs  = input.bool(true,  "R_obs circulation", group = G_DP)
showArt  = input.bool(true,  "R_art artifact implied by Identity I", group = G_DP)
showRes  = input.bool(true,  "R_res residual", group = G_DP)
showTK   = input.bool(false, "T_K residual torque", group = G_DP)
showBg   = input.bool(true,  "Shade background when contamination is identified", group = G_DP)
tkScale  = input.float(30.0, "T_K display scale", minval = 0.01, step = 1.0, group = G_DP,
     tooltip = "T_K is two orders of magnitude smaller than the three circulation series. At 1.0 it draws as a flat line on zero.")

// =============================================================================
//  Helpers
// =============================================================================
autoLTF() =>
    int s = timeframe.in_seconds()
    s <= 60 ? "1S" : s <= 300 ? "5S" : s <= 900 ? "15S" : s <= 3600 ? "1" : s <= 14400 ? "5" : "60"

// Pine has no ta.cov, so compute the covariance from its definition.
rcov(float a, float b, int len) =>
    ta.sma(a * b, len) - ta.sma(a, len) * ta.sma(b, len)

// =============================================================================
//  Data (request.* must sit at global scope)
// =============================================================================
// The call below always runs - request.* cannot sit inside a conditional - but the
// timeframe it asks for can. With any axis other than order flow it is pointed at
// the chart's own timeframe, so it returns one intrabar per bar instead of sixty.
// Changing the DEFAULT axis alone would not have removed this cost; this does.
bool wantLTF = axMode == "Order flow (LTF volume delta)"
string ltfUse = not wantLTF ? timeframe.period : (ltfInput == "" ? autoLTF() : ltfInput)

array<float> ltfDelta = request.security_lower_tf(syminfo.tickerid, ltfUse,
     close > close[1] ? volume : close < close[1] ? -volume : 0.0,
     ignore_invalid_symbol = true, ignore_invalid_timeframe = true)

// =============================================================================
//  The axes x and y
// =============================================================================
float logP = math.log(close)
float ret  = logP - nz(logP[1], logP)
float dev  = logP - ta.ema(logP, detrendLen)

int   ltfN   = array.size(ltfDelta)
float ltfSum = 0.0
if ltfN > 0
    ltfSum := array.sum(ltfDelta)
float ofiLTF = (ltfN > 0 and volume > 0) ? ltfSum / math.max(volume, 1e-9) : na

float rangeHL = high - low
float clv     = rangeHL > 0 ? (2.0 * (close - low) / rangeHL - 1.0) : 0.0
// Pine has no math.log1p, so log(1+v) is written out.
float lgv  = math.log(1.0 + math.max(volume, 0.0))
float volZ = (lgv - ta.sma(lgv, 60)) / math.max(ta.stdev(lgv, 60), 1e-6)

float yRaw = na
if axMode == "Order flow (LTF volume delta)"
    yRaw := na(ofiLTF) ? clv : ofiLTF
else if axMode == "CLV x volume"
    yRaw := clv * math.max(-3.0, math.min(3.0, volZ))
else if axMode == "Volume z only"
    yRaw := volZ
else
    yRaw := ta.ema(ret, 5) - ta.ema(ret, 18)

// Standardise. No lag is applied to y: an earlier cycle established that lagging
// y manufactures rotation, flipping the sign of the true antisymmetric lag
// covariance on every asset tested.
float x = math.max(-4.0, math.min(4.0, (dev - ta.sma(dev, zLen)) / math.max(ta.stdev(dev, zLen), 1e-6)))
float y = math.max(-4.0, math.min(4.0, (yRaw - ta.sma(yRaw, zLen)) / math.max(ta.stdev(yRaw, zLen), 1e-6)))
float dx = x - nz(x[1], x)

// =============================================================================
//  LAMBDA and the Identity I decomposition
// =============================================================================
// The pair that closes on this bar is (s, s+1) = (t-1, t). Nothing looks ahead.
float p_xy = nz(x[1]) * y  - nz(y[1]) * x
float p_xd = nz(x[1]) * dx - nz(dx[1]) * x

float LAM = 0.5 * ta.sma(p_xy, W)
float LXD = 0.5 * ta.sma(p_xd, W)

float beta = rcov(dx, y, W) / math.max(ta.variance(dx, W), 1e-12)

float R_obs = 2.0 * LAM
float R_art = 2.0 * beta * LXD
float R_res = R_obs - R_art
float explained = math.abs(R_obs) > 1e-12 ? R_art / R_obs : na
float corr_ydx = ta.correlation(y, dx, W)

// =============================================================================
//  T_K residual torque
// =============================================================================
float br = rcov(ret, y, W) / math.max(ta.variance(ret, W), 1e-12)
float ar = ta.sma(y, W) - br * ta.sma(ret, W)
float e  = y - (ar + br * ret)

float med = ta.median(volume, W)
float m   = math.max(0.0, math.min(50.0, volume / math.max(med, 1e-9)))

float tau = m * (nz(x[1]) * e - nz(e[1]) * x)
float den = m * (x * x + e * e)
float TK  = ta.sma(tau, W) / math.max(ta.sma(den, W), 1e-9)

// =============================================================================
//  Warm-up
// =============================================================================
int  warmBars = warmMult * W + zLen + detrendLen
bool ready = bar_index >= warmBars

float OBS = ready ? R_obs : na
float ART = ready ? R_art : na
float RES = ready ? R_res : na
float TKV = ready ? TK    : na
float EXP = ready ? explained : na

// =============================================================================
//  Plots
// =============================================================================
hline(0.0, "0", color = color.new(color.gray, 55), linestyle = hline.style_dotted)

// Order matters: later plots paint over earlier ones. R_art is a filled area and
// on the default it is larger in magnitude than R_obs and of the same sign, so
// plotting R_obs first buries the headline series inside the fill.
plot(showArt ? ART : na, "R_art artifact", color = color.new(#f0a020, 20),
     style = plot.style_area, linewidth = 1)
plot(showObs ? OBS : na, "R_obs circulation", color = color.new(#d8dde6, 0), linewidth = 1)
plot(showRes ? RES : na, "R_res residual", color = color.new(#2ecc71, 0), linewidth = 2)
plot(showTK  ? TKV * tkScale : na, "T_K residual torque", color = color.new(#3aa0ff, 20), linewidth = 1)

// Two states, and neither is an all-clear. Synthetic contamination reads 1.000
// to 1.007, so the amber band sits around 1. Everything else is "not classified"
// - a clean rotation reads 0.46 to 0.83 and would be wrongly reassuring if it
// were given a colour of its own.
color bgc = not ready or na(EXP) ? na :
     math.abs(EXP - 1.0) < 0.25 ? color.new(#e05252, 88) : color.new(#8a8f9c, 93)
bgcolor(showBg ? bgc : na, title = "Contamination identified")

plot(EXP,                   "explained R_art/R_obs",       display = display.data_window)
plot(ready ? beta : na,     "beta: standardised y on dx",  display = display.data_window)
plot(ready ? corr_ydx : na, "corr(y, dx)",                 display = display.data_window)
plot(ready ? LAM : na,      "LAMBDA antisym lag-1 cov",    display = display.data_window)
plot(TKV,                   "T_K raw",                     display = display.data_window)
plot(ready ? x : na,        "x",                           display = display.data_window)
plot(ready ? y : na,        "y",                           display = display.data_window)

// Diagnostic, not a trading signal. This is a level test, not a crossover: it is
// true for as long as the ratio stays inside the band.
alertcondition(ready and not na(EXP) and math.abs(EXP - 1.0) < 0.25,
     "Observed rotation is contamination-shaped",
     "RotorIC: R_art/R_obs is near 1. This rotation is explained by the same-bar increment leaking into the second axis.")
````
