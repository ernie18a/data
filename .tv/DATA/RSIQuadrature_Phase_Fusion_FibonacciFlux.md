<!-- tradingview-pine-id: PUB;c1fa3531d07e4908a7dc31f7a5e7183a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI-Quadrature Phase Fusion [FibonacciFlux]

Source: https://www.tradingview.com/script/w2Sy6BGX-RSI-Quadrature-Phase-Fusion-FibonacciFlux/

## Description

Two oscillators read as one vector on a plane and four timeframes averaged into one direction, published with the measurement that says the plane is a line, the four quadrants are two, and the number in the middle of it is lower on real data than on a reshuffled copy of the same price path.

WHAT IT COMPUTES

Each of four timeframes (15m, 1H, 4H, 1D by default) contributes two readings. Stochastic %K says where price sits inside its recent range; RSI says how one-sided the recent moves have been. They become the two axes of a plane - x is (%K - 50)/50, y is (RSI - 50)/50 - so each timeframe is one point on it. Both oscillators are computed inside their own timeframe on that timeframe's own bars, and by default the value used is the previous closed higher-timeframe bar, so nothing repaints.

Each point is then normalised to unit length. Only its direction survives; how far from the centre a timeframe sits is thrown away. The four unit vectors are averaged with the fusion weights - 0.10, 0.20, 0.40, 0.30 by default, normalised onto a simplex - into one resultant. The coloured line is 50 plus 50 times that resultant's x component. The filled area under it is the resultant's length on a 0 to 100 scale, and that is what the script calls coherence. The background names the quadrant the resultant occupies, and the table prints both raw sensors, both axes and the quadrant for every timeframe plus the fused row.

THE PLANE IS A DIAGONAL

Stochastic %K and RSI on the same series are close to the same measurement. Over 5,985 scored bars of 15m data from 2026-06-22 to 2026-08-23 they correlate 0.745 to 0.801 inside every one of the four timeframes, on all three instruments tested, and they sit on the same side of 50 on 80.6% to 88.8% of bars.

So the two-axis plane is mostly one axis with scatter around it, and the quadrant map is really two states. The off-diagonal quadrants - HOLLOW (%K high, RSI low) and SETUP (%K low, RSI high) - are occupied on 13.6% of bars on BINANCE:BTCUSDT, 13.3% on ETHUSDT and 18.7% on SOLUSDT. Two genuinely independent axes would put that number near 50% by symmetry, before any simulation.

The leg counts say the same thing from the other side. When the fused vector sits in HOT or SOLD, an average of 2.6 to 2.9 of the four timeframes are in that same quadrant. Off-diagonal, the average is 0.8 to 1.2 of four: the fused vector lands there because the legs cancel, not because any of them points there.

COHERENCE IS LOWER THAN ON A RESHUFFLED COPY OF THE SAME PRICE

Coherence is the length of a weighted mean of four unit vectors. As a statistic it starts high: four independent, uniformly random directions under the default weights give a median of 49.6, clear 60 on 34.5% of draws and clear 87 on 5.1% (eight independent runs of 500,000 draws). That is a property of the scale rather than a null - this indicator cannot produce independent directions, because its four legs are nested aggregations of one price path.

The null that keeps the construction and destroys only the market is to resample the real 15m bars, each keeping its own open-high-low-close geometry, chain them onto a running price, and re-aggregate them into 1H, 4H and 1D exactly as the exchange would. The nesting survives; the order of the market's moves does not. Real data comes out BELOW that null, on every instrument and under both an i.i.d. resample and a one-day block bootstrap (60 draws each). The real figures here differ slightly from the ones above because every draw, and the real series with it, is rebuilt from the same 62 days of 15m bars so that the daily leg warms up on identical history - which leaves 4,575 scored bars rather than 5,985:

    mean coherence   BTCUSDT 59.84 vs 63.28 / 62.51   ETHUSDT 57.36 vs 63.66 / 63.60   SOLUSDT 54.72 vs 62.70 / 62.14
    share above 87   BTCUSDT 23.23 vs 29.18 / 27.28   ETHUSDT 24.24 vs 29.88 / 28.90   SOLUSDT 20.32 vs 28.91 / 26.17

There is no alignment excess to report. A weaker null - rotating the four legs against each other in time - does put real coherence above chance at p = 0.002 to 0.006, and that is the test a description would normally quote. It should not be quoted: a synthetic driftless random walk passes the same test by 5.1 to 7.4 coherence points at p = 0.010 to 0.055. That null destroys the nesting, which is a property of the indicator, not of the market.

THE DEFAULT THRESHOLD IS NOT A FILTER

At 60, the gate passes 44.3% of bars on BTCUSDT, 45.8% on ETHUSDT and 43.4% on SOLUSDT, against 34.5% for four random directions. It is a coin flip sitting about ten points of chance-rate above the floor.

There is also a way to switch it off by accident. Because the other legs can cancel at most one minus the largest normalised weight, coherence has a hard floor of max(0, 2·wmax - 1) × 100. At the defaults the largest weight is 0.40 and the floor is zero. Raise one weight past half the total and the floor rises with it: a position weight of 5 against the other defaults pins coherence at 75.4 or above on every bar, and a single-timeframe configuration pins it at exactly 100. The gate then passes everything, silently. That is in the weights tooltip now.

THE ALERT'S TWO GATES FIGHT EACH OTHER

The one alert that survives here marks a quadrant shift while coherence is above the threshold. The two conditions are close to opposites by construction: coherence is high when the fused vector is holding still, and a quadrant change is what happens when it is not.

Measured, a quadrant-change bar carries a median coherence of 36.6 on BTCUSDT against 54.1 for bars in general. Only 8.1% of the 172 quadrant changes clear 60, against 44.3% of all bars - five times less likely. ETHUSDT gives 5.7% of 315 changes against 45.8%, eight times less likely; SOLUSDT 7.7% of 313 against 43.4%. That is why the alert fires just 14, 18 and 24 times over 62 days. Rare, yes - but rare because the gates disagree, not because something unusual is being caught.

NO STATE CARRIES FORWARD INFORMATION, AND HERE IS WHAT THAT IS WORTH

Testing all eleven states this script draws - both coherence thresholds, the low-coherence state, all four quadrants, quadrant shifts with and without the coherence gate, and both extremes of the wave - at horizons of 4, 16 and 96 bars, in both signed and absolute return, counted as episodes rather than as overlapping bars, against 500 shared circular shifts of the forward-return series: the largest standardised effect anywhere in the family of 66 tests is 2.91 on BTCUSDT, against a family whose own median maximum on a shifted copy is 2.49. The family-wise p is 0.269. ETHUSDT gives 2.17 against 2.51 (p = 0.735) and SOLUSDT 2.30 against 2.49 (p = 0.659).

A negative result is only as good as its power, so: 62 days of 15m bars hold 1,496 non-overlapping one-hour windows, 374 four-hour windows and 62 daily ones. For a state occupying a quarter of them, the smallest mean difference this window could detect at 80% power is 0.066% at one hour, 0.271% at four hours and 1.694% at one day. The one-hour and four-hour results are therefore real tests. The daily one is not: nothing short of an enormous daily edge could have shown up in 62 windows, and the absence of one there means very little.

One member of that family is worth naming, because anyone who tests it on its own will find it. The gated quadrant shift on BTCUSDT is followed by a lower four-hour return than the rest of the sample: 12 of its 14 events are negative, mean -0.569% against an unconditional +0.053%, which taken alone clears p = 0.01. It does not survive contact with anything. It is the maximum of the 66-member family above, whose family-wise p is 0.269. Dropping the single worst event moves the mean to -0.325% and dropping two moves it to -0.188%; the median is -0.252%, not -0.569%. And it does not replicate: ETHUSDT gives 9 of 18 positive with a median of +0.012%, and SOLUSDT 10 of 24 positive with the mean turning positive once two events are dropped. Fourteen events is not a sample.

WHAT CHANGED IN THIS VERSION

A setup-zone alert asked for the SETUP quadrant AND coherence above the threshold at once. Over 5,985 bars it would have fired zero times on BTCUSDT, three on ETHUSDT and four on SOLUSDT. It was not a rare signal, it was the sharpest form of the contradiction above - SETUP is where the legs cancel and coherence measures whether they cancel - so it is gone rather than given a lower threshold that would hide the reason. The remaining alert says in its own text that it describes geometry rather than predicting anything.

The coherence area was declared after the wave, so it was painted over it: the fill sat above the line on 48.2% of bars on BTCUSDT and by more than 10 points on 25.9%, and because the fill's opacity ramps up with coherence, the wave's hue - its only encoding of the regime angle - was washed out hardest on exactly the bars the indicator asks you to trust most. The area is now declared first and takes the wave's own colour, since it is the magnitude of the same vector whose angle sets that colour, and the quadrant shading behind both is a wash rather than a block. The coherence threshold is now drawn as a dotted line so the level the alert uses is visible on the pane.

An MPL header was added, a leftover compile-sentinel plot removed, and the header and three inputs now carry the measurements above in their tooltips. No computation changed: every plotted number is identical to the previous version.

WHAT ACTUALLY MOVES THE OUTPUT

The four fusion weights, by a wide margin. Measured on BTCUSDT 15m against the defaults over 5,700 bars after warm-up, equal weights move the wave by a median of 6.7 points, a short-term-heavy setting by 23.2, and collapsing onto a single timeframe by 28 to 33 with a maximum near 89.

The two sensors are not equal partners. Over a 9-to-21 band the Stochastic %K length moves the wave by a median of up to 4.1 points and a 90th percentile of up to 28.8; the RSI length over the same band moves it by a median of up to 1.3 and a 90th percentile of 3.1. That is a factor of three at the median and nine in the tail. For all the two-sensor framing, this is a Stochastic wave with an RSI trim.

The coherence threshold and both display toggles move the plotted series by exactly zero; the threshold only gates the alert and the dotted line that marks it.

WHAT THE MEASUREMENTS COVER

All of it is 15m data from 2026-06-22 to 2026-08-23, 62 days, on three instruments, in a window where BTCUSDT rose 20.2%, ETHUSDT 39.5% and SOLUSDT 28.4%. Nothing was tested outside that window, in a falling market, or on a non-crypto instrument. Everything is measured on the configuration that was cross-checked: a 15m chart with the default Confirmed-only data mode, where the four requested timeframes are the chart's own and three above it. On a 1H or higher chart the 15m leg becomes a lower-timeframe request and resolves differently. The Developing HTF mode was not measured, because the reimplementation does not model a partially formed higher-timeframe bar faithfully enough to quote - it is the one setting here that lets the displayed value change after the bar it belongs to has opened, and it should be treated as repainting until someone measures it. No figure here covers either case.

HOW THE NUMBERS WERE CHECKED

The whole computation was reimplemented outside Pine and cross-checked against this chart's Data Window: sixteen quantities on ten bars - both plotted series, both raw sensors for all four timeframes, the resultant's two components, its length, its angle, the fused quadrant and the shift flag - with two of the ten bars carrying a quadrant shift so the event path was exercised rather than assumed. All 160 values round to the exact four decimals TradingView prints, with a worst raw difference of 5.0e-5, the display's own rounding floor.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("RSI-Quadrature Phase Fusion [FibonacciFlux]", "RQ Fusion", overlay = false, precision = 4)
// Two-sensor phase-plane fusion.
// Real axis: Stoch %K = range position sensor (outer skin).
// Imaginary axis: RSI = internal momentum sensor (muscle).
// Each timeframe contributes a unit vector on the phase plane; the weighted
// resultant (RX, RY) drives the fused wave, the coherence magnitude, and the
// regime angle.
//
// Three things the measurements say, so they are not read into the picture:
//  * The plane is close to a line. Stoch %K and RSI on the same series correlate 0.745 to
//    0.801 inside every one of the four timeframes across BINANCE:BTCUSDT, ETHUSDT and
//    SOLUSDT 15m, 5985 bars each, and sit on the same side of 50 on 80.6% to 88.8% of bars.
//    The four-quadrant map is really two states; see the shading tooltip.
//  * Coherence has a high floor as a statistic. Four INDEPENDENT random directions under
//    these weights already give a median of 49.6 and clear 60 on 34.5% of draws. See the
//    threshold tooltip.
//  * Coherence is not elevated by anything in this market. Against a null that resamples the
//    real 15m bars, rechains them and re-aggregates the higher timeframes from them -
//    keeping the nesting and destroying only the order of the moves - real mean coherence
//    comes out BELOW the null on all three instruments (59.84 vs 63.28, 57.36 vs 63.66,
//    54.72 vs 62.70; same under a one-day block bootstrap).

// -----------------------------------------------------------------------------
// 01. Dual-sensor inputs
// -----------------------------------------------------------------------------
string G_SRC = "01. Dual-sensor inputs"
int stochLen = input.int(14, "Stochastic %K length", minval = 2, group = G_SRC)
int rsiLen = input.int(14, "RSI length", minval = 2, group = G_SRC)
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Confirmed only", "Developing HTF"], group = G_SRC,
     tooltip = "Confirmed only uses the previous completed bar in each requested timeframe, so a value never changes once its chart bar has opened. Developing HTF REPAINTS: it reads the higher-timeframe bar still forming, so the wave, the coherence and the displayed quadrant all move while that bar is open and settle only when it closes. Everything measured for this publication was measured on Confirmed only; the Developing mode was not measured at all, so treat its readings as provisional.")

// -----------------------------------------------------------------------------
// 02. Timeframes and fusion weights
// -----------------------------------------------------------------------------
string G_TF = "02. Timeframes and fusion weights"
string tf15 = input.timeframe("15", "Short-term timeframe", group = G_TF)
string tf1h = input.timeframe("60", "Intraday timeframe", group = G_TF)
string tf4h = input.timeframe("240", "Swing timeframe", group = G_TF)
string tf1d = input.timeframe("1D", "Position timeframe", group = G_TF)
float w15Input = input.float(0.10, "Short-term weight", minval = 0.0, step = 0.05, group = G_TF,
     tooltip = "The four weights are normalised onto a simplex and they are the load-bearing setting here. Measured on BINANCE:BTCUSDT 15m against the defaults over 5700 bars after warm-up, equal weights move the fused wave by a median of 6.7 points, a short-term-heavy setting by 23.2 and a single-timeframe setting by 28 to 33 with a maximum near 89 - against 4.1 for the Stochastic length and 1.3 for the RSI length over a 9-to-21 band. One trap: because the other legs can cancel at most (1 - wmax) of the largest one, coherence has a hard floor of max(0, 2*wmax - 1) * 100. At the defaults wmax is 0.40 and the floor is 0, but raise one weight past half the total and the floor rises with it - a position weight of 5 against the other defaults pins coherence at 75.4 or above on every bar, and a single-timeframe configuration pins it at exactly 100. The alert gate then passes everything, silently.")
float w1hInput = input.float(0.20, "Intraday weight", minval = 0.0, step = 0.05, group = G_TF)
float w4hInput = input.float(0.40, "Swing weight", minval = 0.0, step = 0.05, group = G_TF)
float w1dInput = input.float(0.30, "Position weight", minval = 0.0, step = 0.05, group = G_TF)

// -----------------------------------------------------------------------------
// 03. Fusion thresholds
// -----------------------------------------------------------------------------
string G_FUSE = "03. Fusion thresholds"
float cohThreshold = input.float(60.0, "Coherence alert threshold", minval = 0.0, maxval = 100.0, step = 5.0, group = G_FUSE,
     tooltip = "60 is not a high-alignment reading, and this gate is not a filter. Coherence is the length of a weighted mean of four UNIT vectors, so the statistic starts high: four independent random directions under the default weights give a median of 49.6, clear 60 on 34.5% of draws and clear 87 on 5.1% (8 x 500,000 draws). Real data sits close to that. Over 5985 scored bars of 15m data from 2026-06-22 to 2026-08-23 the median is 54.1 on BINANCE:BTCUSDT, 52.2 on ETHUSDT and 47.6 on SOLUSDT, and 44.3%, 45.8% and 43.4% of bars clear 60 - a coin flip about ten points of chance-rate above the floor. Nor is the level elevated by this market: against a null that resamples the real 15m bars, rechains them and re-aggregates the higher timeframes from them, real data comes out BELOW the null both on mean coherence and on the share above 87 (23.2% real vs 29.2% null on BTCUSDT, and the same direction on the other two).")
bool signalOnClose = input.bool(true, "Alerts only on confirmed chart bars", group = G_FUSE)

// -----------------------------------------------------------------------------
// 04. Visuals
// -----------------------------------------------------------------------------
string G_VIS = "04. Visuals"
bool shadeQuadrants = input.bool(true, "Shade fused-quadrant background", group = G_VIS,
     tooltip = "This is really a two-state map, because the two axes are close to the same measurement. Stoch %K and RSI correlate 0.745 to 0.801 inside every timeframe on BINANCE:BTCUSDT, ETHUSDT and SOLUSDT 15m over 5985 bars each, and sit on the same side of 50 on 80.6% to 88.8% of bars. So the off-diagonal quadrants - HOLLOW (%K high, RSI low) and SETUP (%K low, RSI high) - are occupied on only 13.6%, 13.3% and 18.7% of bars, where two genuinely independent axes would give about 50% by symmetry. When the fused vector sits in HOT or SOLD, an average of 2.6 to 2.9 of the 4 timeframes are in that same quadrant; off-diagonal the average is 0.8 to 1.2 of 4, so it lands there because the legs cancel rather than because any of them points there. High coherence and the off-diagonal quadrants therefore rarely coincide, though they are not exclusive: HOLLOW never cleared 60 on BTCUSDT (maximum 58.3) but reached 60.1 once on ETHUSDT and 90.4 on SOLUSDT, and up to 3 of the 4 legs can sit off-diagonal at once.")
bool showTable = input.bool(true, "Show sensor audit table", group = G_VIS)

// -----------------------------------------------------------------------------
// Numeric helpers
// -----------------------------------------------------------------------------
float EPS = 1e-10

f_clip(float value, float lower, float upper) => math.max(lower, math.min(upper, value))

// -----------------------------------------------------------------------------
// Dual sensor, evaluated entirely inside each requested timeframe
// -----------------------------------------------------------------------------
f_dual() =>
    float k = ta.stoch(close, high, low, stochLen)
    float r = ta.rsi(close, rsiLen)
    [k, r]

f_dualConfirmed() =>
    [k, r] = f_dual()
    [k[1], r[1]]

[k15Dev, r15Dev] = request.security(syminfo.tickerid, tf15, f_dual(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1hDev, r1hDev] = request.security(syminfo.tickerid, tf1h, f_dual(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k4hDev, r4hDev] = request.security(syminfo.tickerid, tf4h, f_dual(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1dDev, r1dDev] = request.security(syminfo.tickerid, tf1d, f_dual(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// lookahead_on is safe here and only here because f_dualConfirmed() returns [k[1], r[1]] -
// the lookahead is applied to an already-shifted series, so what arrives is the value of the
// higher-timeframe bar that has ALREADY CLOSED, delivered at the boundary instead of one
// chart bar late. This is the standard non-repainting idiom. lookahead_on WITHOUT that [1]
// shift would leak future data, which is why the Developing branch above uses lookahead_off.
[k15Con, r15Con] = request.security(syminfo.tickerid, tf15, f_dualConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1hCon, r1hCon] = request.security(syminfo.tickerid, tf1h, f_dualConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k4hCon, r4hCon] = request.security(syminfo.tickerid, tf4h, f_dualConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1dCon, r1dCon] = request.security(syminfo.tickerid, tf1d, f_dualConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

bool confirmedMode = dataMode == "Confirmed only"
float k15 = confirmedMode ? k15Con : k15Dev
float k1h = confirmedMode ? k1hCon : k1hDev
float k4h = confirmedMode ? k4hCon : k4hDev
float k1d = confirmedMode ? k1dCon : k1dDev
float r15 = confirmedMode ? r15Con : r15Dev
float r1h = confirmedMode ? r1hCon : r1hDev
float r4h = confirmedMode ? r4hCon : r4hDev
float r1d = confirmedMode ? r1dCon : r1dDev

// Normalize fusion weights onto a simplex.
// All-zero input falls back to the 0.10 / 0.20 / 0.40 / 0.30 defaults.
float wRawSum = w15Input + w1hInput + w4hInput + w1dInput
bool weightsValid = wRawSum > 0.0
float n15 = weightsValid ? w15Input : 0.10
float n1h = weightsValid ? w1hInput : 0.20
float n4h = weightsValid ? w4hInput : 0.40
float n1d = weightsValid ? w1dInput : 0.30
float weightSum = n15 + n1h + n4h + n1d
float w15 = n15 / weightSum
float w1h = n1h / weightSum
float w4h = n4h / weightSum
float w1d = n1d / weightSum

// -----------------------------------------------------------------------------
// Per-timeframe phase-plane axes (raw and unit-normalized)
// -----------------------------------------------------------------------------
f_axes(float k, float r) =>
    float x = (k - 50.0) / 50.0
    float y = (r - 50.0) / 50.0
    float m = math.sqrt(x * x + y * y)
    float mSafe = math.max(m, EPS)
    [x, y, x / mSafe, y / mSafe]

[x15, y15, rx15, ry15] = f_axes(k15, r15)
[x1h, y1h, rx1h, ry1h] = f_axes(k1h, r1h)
[x4h, y4h, rx4h, ry4h] = f_axes(k4h, r4h)
[x1d, y1d, rx1d, ry1d] = f_axes(k1d, r1d)

// Quadrant-aware arctangent in (-pi, pi]. Pine v6 has no math.atan2 (only
// single-argument math.atan), so this local version is used.
f_atan2(float y, float x) =>
    float angle = 0.0
    if x > 0.0
        angle := math.atan(y / x)
    else if x < 0.0
        angle := y >= 0.0 ? math.atan(y / x) + math.pi : math.atan(y / x) - math.pi
    else if y > 0.0
        angle := math.pi / 2.0
    else if y < 0.0
        angle := -math.pi / 2.0
    angle

// -----------------------------------------------------------------------------
// MTF fusion on the phase plane
// -----------------------------------------------------------------------------
float RX = w15 * rx15 + w1h * rx1h + w4h * rx4h + w1d * rx1d
float RY = w15 * ry15 + w1h * ry1h + w4h * ry4h + w1d * ry1d
float magR = math.sqrt(RX * RX + RY * RY)
float C = 100.0 * math.min(magR, 1.0)
float Wave = 50.0 + 50.0 * RX
float thetaDeg = (magR > EPS ? f_atan2(RY, RX) : 0.0) * 180.0 / math.pi

// Quadrants from raw axes: 1 = both high (overheat), 2 = Stoch high and RSI low (hollow high),
// 3 = both low (sold out), 4 = Stoch low and RSI high (setup zone). 0 = warmup or undefined.
f_quad(float x, float y) =>
    x >= 0.0 ? (y >= 0.0 ? 1 : 2) : (y >= 0.0 ? 4 : 3)

f_quadName(int q) =>
    q == 1 ? "HOT" : q == 2 ? "HOLLOW" : q == 3 ? "SOLD" : q == 4 ? "SETUP" : "WARM"

int q15 = na(x15) or na(y15) ? 0 : f_quad(x15, y15)
int q1h = na(x1h) or na(y1h) ? 0 : f_quad(x1h, y1h)
int q4h = na(x4h) or na(y4h) ? 0 : f_quad(x4h, y4h)
int q1d = na(x1d) or na(y1d) ? 0 : f_quad(x1d, y1d)
int fusedQuad = na(RX) or na(RY) ? 0 : f_quad(RX, RY)

int prevFusedQuad = nz(fusedQuad[1], 0)
bool quadChanged = fusedQuad != 0 and prevFusedQuad != 0 and fusedQuad != prevFusedQuad

// -----------------------------------------------------------------------------
// Oscillator-pane visuals
// -----------------------------------------------------------------------------
hline(80, "Upper reference", color = color.new(color.gray, 70))
hline(50, "Midline", color = color.new(color.gray, 50))
hline(20, "Lower reference", color = color.new(color.gray, 70))

// The regime angle sets one hue for the whole pane: upper half-plane (RSI above 50) runs
// lime to teal, lower half runs orange to red. Pine has no HSV wheel, so the shift is piecewise.
color waveColor = thetaDeg >= 0.0 ? color.from_gradient(thetaDeg, 0.0, 180.0, color.lime, color.teal) : color.from_gradient(thetaDeg, -180.0, 0.0, color.red, color.orange)

// Coherence is declared FIRST so the wave draws on top of it. In the previous version the
// filled area came after the line and covered it on 48.2% of bars, by more than 10 points
// on 25.9%. The fill takes the wave's own colour because it is the magnitude of the same
// vector whose angle sets that colour.
plot(C, "Phase coherence", color = color.new(waveColor, 88), style = plot.style_area, histbase = 0.0)
hline(cohThreshold, "Coherence alert level", color = color.new(color.gray, 40), linestyle = hline.style_dotted)

plot(Wave, "RQ fused wave", color = waveColor, linewidth = 2)

int bgTrans = int(math.round(99.0 - 8.0 * f_clip(C / 100.0, 0.0, 1.0)))
color bgQ = fusedQuad == 1 ? color.new(color.red, bgTrans) : fusedQuad == 2 ? color.new(color.orange, bgTrans) : fusedQuad == 3 ? color.new(color.fuchsia, bgTrans) : fusedQuad == 4 ? color.new(color.aqua, bgTrans) : na
bgcolor(shadeQuadrants ? bgQ : na, title = "Fused phase quadrant")

// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------
bool chartBarGate = not signalOnClose or barstate.isconfirmed
bool cohOK = C >= cohThreshold
bool shiftEvent = chartBarGate and cohOK and quadChanged
// There is no setup-zone alert here on purpose. Entering the SETUP quadrant WITH coherence
// above the threshold is close to a contradiction - SETUP is where the four sensors cancel
// and coherence measures whether they cancel - and over 5985 bars of 15m data it would have
// fired 0 times on BINANCE:BTCUSDT, 3 on ETHUSDT and 4 on SOLUSDT. The alert that remains
// fires 14, 18 and 24 times over the same window.
alertcondition(shiftEvent, "RQPF quadrant shift with coherence", "The fused phase quadrant changed while coherence was above its threshold. This describes the current geometry and is not a forecast. Its two conditions largely exclude each other: only 8.1% of quadrant changes on BINANCE:BTCUSDT 15m carry coherence above 60, against 44.3% of bars in general, which is why it fires about 14 times in 62 days. Tested at 1, 4 and 24 hours ahead, no state this script draws separated from a circular-shift null; see the description for what that window had the power to detect.")

// -----------------------------------------------------------------------------
// Sensor audit table
// -----------------------------------------------------------------------------
f_tfName(string tf) =>
    tf == "15" ? "15m" : tf == "60" ? "1H" : tf == "240" ? "4H" : tf == "1D" ? "1D" : tf

f_num3(float value) => na(value) ? "-" : str.tostring(value, "#.000")
f_num1(float value) => na(value) ? "-" : str.tostring(value, "#.0")

f_quadBg(int q) =>
    q == 1 ? color.new(color.red, 35) : q == 2 ? color.new(color.orange, 35) : q == 3 ? color.new(color.fuchsia, 35) : q == 4 ? color.new(color.aqua, 35) : color.new(color.gray, 65)

var table audit = table.new(position.top_right, 6, 7, border_width = 1)
if barstate.islast and showTable
    color header = color.rgb(32, 38, 48)
    color body = color.new(color.black, 15)
    table.cell(audit, 0, 0, "TF", bgcolor = header, text_color = color.white)
    table.cell(audit, 1, 0, "StochK", bgcolor = header, text_color = color.white)
    table.cell(audit, 2, 0, "RSI", bgcolor = header, text_color = color.white)
    table.cell(audit, 3, 0, "x", bgcolor = header, text_color = color.white)
    table.cell(audit, 4, 0, "y", bgcolor = header, text_color = color.white)
    table.cell(audit, 5, 0, "Quad", bgcolor = header, text_color = color.white)
    table.cell(audit, 0, 1, f_tfName(tf15), bgcolor = body, text_color = color.aqua)
    table.cell(audit, 1, 1, f_num1(k15), bgcolor = body, text_color = color.white)
    table.cell(audit, 2, 1, f_num1(r15), bgcolor = body, text_color = color.white)
    table.cell(audit, 3, 1, f_num3(x15), bgcolor = body, text_color = color.white)
    table.cell(audit, 4, 1, f_num3(y15), bgcolor = body, text_color = color.white)
    table.cell(audit, 5, 1, f_quadName(q15), bgcolor = f_quadBg(q15), text_color = color.white)
    table.cell(audit, 0, 2, f_tfName(tf1h), bgcolor = body, text_color = color.blue)
    table.cell(audit, 1, 2, f_num1(k1h), bgcolor = body, text_color = color.white)
    table.cell(audit, 2, 2, f_num1(r1h), bgcolor = body, text_color = color.white)
    table.cell(audit, 3, 2, f_num3(x1h), bgcolor = body, text_color = color.white)
    table.cell(audit, 4, 2, f_num3(y1h), bgcolor = body, text_color = color.white)
    table.cell(audit, 5, 2, f_quadName(q1h), bgcolor = f_quadBg(q1h), text_color = color.white)
    table.cell(audit, 0, 3, f_tfName(tf4h), bgcolor = body, text_color = color.orange)
    table.cell(audit, 1, 3, f_num1(k4h), bgcolor = body, text_color = color.white)
    table.cell(audit, 2, 3, f_num1(r4h), bgcolor = body, text_color = color.white)
    table.cell(audit, 3, 3, f_num3(x4h), bgcolor = body, text_color = color.white)
    table.cell(audit, 4, 3, f_num3(y4h), bgcolor = body, text_color = color.white)
    table.cell(audit, 5, 3, f_quadName(q4h), bgcolor = f_quadBg(q4h), text_color = color.white)
    table.cell(audit, 0, 4, f_tfName(tf1d), bgcolor = body, text_color = color.fuchsia)
    table.cell(audit, 1, 4, f_num1(k1d), bgcolor = body, text_color = color.white)
    table.cell(audit, 2, 4, f_num1(r1d), bgcolor = body, text_color = color.white)
    table.cell(audit, 3, 4, f_num3(x1d), bgcolor = body, text_color = color.white)
    table.cell(audit, 4, 4, f_num3(y1d), bgcolor = body, text_color = color.white)
    table.cell(audit, 5, 4, f_quadName(q1d), bgcolor = f_quadBg(q1d), text_color = color.white)
    color aggBg = f_quadBg(fusedQuad)
    table.cell(audit, 0, 5, "FUSED", bgcolor = aggBg, text_color = color.white)
    table.cell(audit, 1, 5, "RX " + f_num3(RX), bgcolor = aggBg, text_color = color.white)
    table.cell(audit, 2, 5, "RY " + f_num3(RY), bgcolor = aggBg, text_color = color.white)
    table.cell(audit, 3, 5, "W " + f_num1(Wave), bgcolor = aggBg, text_color = color.white)
    table.cell(audit, 4, 5, "ang " + f_num1(thetaDeg), bgcolor = aggBg, text_color = color.white)
    table.cell(audit, 5, 5, f_quadName(fusedQuad), bgcolor = aggBg, text_color = color.white)
    table.cell(audit, 0, 6, "State", bgcolor = header, text_color = color.white)
    table.cell(audit, 1, 6, "C " + f_num1(C), bgcolor = header, text_color = color.white)
    table.cell(audit, 2, 6, weightsValid ? "w OK" : "w DEF", bgcolor = header, text_color = color.white)
    table.cell(audit, 3, 6, confirmedMode ? "CONF" : "DEV", bgcolor = header, text_color = color.white)
    table.cell(audit, 4, 6, "C>=" + str.tostring(cohThreshold, "#.0"), bgcolor = header, text_color = color.white)
    table.cell(audit, 5, 6, quadChanged ? "SHIFT" : "-", bgcolor = header, text_color = color.white)
````
