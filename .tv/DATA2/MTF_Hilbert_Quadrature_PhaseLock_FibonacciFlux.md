<!-- tradingview-pine-id: PUB;ea79e66f4cce4c5e9f5020b69329a269 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MTF Hilbert Quadrature Phase-Lock [FibonacciFlux]

Source: https://www.tradingview.com/script/LnE2tzl4-MTF-Hilbert-Quadrature-Phase-Lock-FibonacciFlux/

## Description

An experiment in whether four timeframes' cycles line up. The measurement says they do not - and, more interestingly, says why the statistic this script uses could not have seen the structure that is actually there.

WHAT IT COMPUTES

Inside each of four timeframes (15m, 1H, 4H, 1D by default) it detrends price against a weighted moving average and runs a causal six-tap Ehlers-style FIR quadrature pair on the result. That gives an in-phase and a quadrature component, and from them an instantaneous phase and amplitude for that timeframe, computed on that timeframe's own bars rather than resampled from the chart.

Each timeframe's phase is trusted only while its quadrature amplitude is alive: the gate is the amplitude divided by its own 20-bar EMA, capped at 1. The four gated phase vectors are combined with the attention weights into a weighted circular mean. The white line is 50 + 50·cos of that mean phase. The teal area is the phase-locking value: the length of the resultant vector, renormalised by the active weight, on a 0 to 100 scale.

WHAT THE MEASUREMENT FOUND

Real data produces LESS phase clustering than deliberately misaligned data.

On BINANCE:BTCUSDT 15m over 5,836 scored bars (2026-06-22 to 2026-08-22), the mean phase-lock value is 36.76. Against a null that circularly shifts each timeframe's phase series relative to the others - destroying any alignment between them while preserving each series' own distribution - the null's median is 40.12, and the real series sits below it with p = 0.010 over 200 draws. A second 200-draw seed gives 36.53 against 40.37 at p = 0.005, and at 1,000 draws the same direction holds at p = 0.005 in all four instrument-and-timeframe cells tested.

The mechanism is the interesting part. Two of the three adjacent pairs do carry a real relationship: 15m to 1H has a circular coupling of R = 0.115 at an offset of -176 degrees, and 1H to 4H has R = 0.136 at +155 degrees. Both are close to anti-phase. The third pair, 4H to 1D, shows nothing (R = 0.123 against a shift null at p = 0.189). A resultant-length statistic like the phase-lock value adds vectors together, so a pair sitting near 180 degrees apart cancels rather than accumulates. The structure that exists in this data is precisely the structure this statistic is built to erase. The coupling is weak in any case - roughly 1.5% of circular variance - so this is a description of a small effect, not a discovery.

The threshold reflects the same thing. The 70 line is crossed 70 times on real data against a null median of 117 crossings. The trough quadrant is not informative either: it is occupied on 22.65% of bars at the default 45-degree half-width, and the shift null reproduces almost the same figure, 23.13%, at p = 0.612.

There is no edge here. A nominally significant one-day return after a 70 crossing (+0.974%, p = 0.0199) fails on both of the checks that matter: on ETHUSDT over the identical window it gives p = 0.270, and on BTCUSDT 68% of the effect comes from a single calendar day, after whose removal the mean is 0.338% against an unconditional drift of 0.328% over the same window.

WHAT THE SCALE MEANS

The phase-lock value can reach 100, but not often: it is bounded by 100 times the weighted mean gate, which averages 0.766, so a typical bar tops out near 77 even with four identical phases. All four gates saturate at 1 on 2.7% of bars. Decomposed multiplicatively, the coherence term does most of the work: of the variance in the log of the phase-lock value, 88% comes from the resultant length and 12% from the gate.

WHAT CHANGED IN THIS VERSION

The two trough markers are gone. A green up-triangle at the bottom of the pane and a red down-triangle at the top are the universal grammar of buy and sell, and the measurement points the other way: the mean one-day return starting inside the trough quadrant was +0.226% against +0.687% inside the peak quadrant. The state remains as neutral background shading, retitled to say what it is - the mean phase near the minimum of its cosine - and the two alerts built on it are gone. The one remaining alert simply reports the threshold crossing and says in its own message that this is a reading of the statistic rather than a claim of synchronisation.

A phase audit table promised by the settings and by five helper functions did not exist anywhere in the file; the promise was deleted rather than the table built. Four of the six series returned from each timeframe sensor - the raw in-phase and quadrature components, the amplitude and the phase change - were never read by anything, across all eight higher-timeframe calls, and are gone. Three lead/lag series were computed and never rendered, and are gone too. An MPL header was added and a leftover compile-sentinel plot removed. None of that touches a plotted number.

One thing worth knowing before turning knobs: at the default Detrended price signal, the Stochastic length, RSI length, StochRSI length and K smoothing inputs are completely inert - every value produces a bit-identical output. They only matter if the quadrature input signal is changed.

HOW THE NUMBERS WERE CHECKED

The whole computation was reimplemented outside Pine and cross-checked against this chart's Data Window: eight quantities on ten bars, with the per-timeframe phase waves switched on so nothing was left as na. All 80 values round to the exact four decimals TradingView prints, with a worst raw difference of 5.0e-5 - the display's own rounding floor.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("MTF Hilbert Quadrature Phase-Lock [FibonacciFlux]", "HT PLV", overlay = false, precision = 4)
// Standalone oscillator-pane indicator.
// White line: weighted circular mean phase of four timeframes, drawn as 50 + 50 * cos(theta).
// Teal area: phase-locking value (PLV), the gated resultant length of per-timeframe phase vectors.
// Each timeframe runs a causal Ehlers-style FIR quadrature pair on a detrended or centered
// signal inside its own request.security context, so phase, amplitude, and instantaneous
// frequency are all computed on that timeframe's own bars. The FIR pair is a causal
// approximation of a Hilbert quadrature filter, not an exact transform.

// -----------------------------------------------------------------------------
// 01. Quadrature source
// -----------------------------------------------------------------------------
string G_SRC = "01. Quadrature source"
string signalType = input.string("Detrended price", "Quadrature input signal", options = ["Detrended price", "Stoch K", "RSI", "StochRSI K"], group = G_SRC,
     tooltip = "Detrended price applies the FIR pair to close minus its WMA. Oscillator options apply the same pair to the centered oscillator (oscillator minus 50).")
int hpLen = input.int(40, "High-pass detrend WMA length", minval = 2, group = G_SRC)
int stochLen = input.int(14, "Stochastic length", minval = 2, group = G_SRC,
     tooltip = "Only used when the quadrature input signal is Stoch K. At the default Detrended price this input, the RSI length, the StochRSI length and the K smoothing are all inert - every value produces a bit-identical output.")
int rsiLen = input.int(14, "RSI length", minval = 2, group = G_SRC)
int stochRsiLen = input.int(14, "StochRSI length", minval = 2, group = G_SRC)
int smoothK = input.int(3, "StochRSI K smoothing", minval = 1, group = G_SRC)
int gateLen = input.int(20, "Amplitude gate EMA length", minval = 2, group = G_SRC,
     tooltip = "A timeframe's phase is trusted only while its quadrature amplitude is alive: gate = min(1, amplitude / EMA(amplitude, gateLen)).")
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Confirmed only", "Developing HTF"], group = G_SRC,
     tooltip = "Confirmed only uses the previous completed bar in each requested timeframe. Developing HTF reacts earlier but the open higher-timeframe bar keeps changing until it closes.")

// -----------------------------------------------------------------------------
// 02. Timeframes and phase weights
// -----------------------------------------------------------------------------
string G_TF = "02. Timeframes and phase weights"
string tf15 = input.timeframe("15", "Short-term timeframe", group = G_TF)
string tf1h = input.timeframe("60", "Intraday timeframe", group = G_TF)
string tf4h = input.timeframe("240", "Swing timeframe", group = G_TF)
string tf1d = input.timeframe("1D", "Position timeframe", group = G_TF)
float w15Input = input.float(0.10, "Short-term weight", minval = 0.0, step = 0.05, group = G_TF)
float w1hInput = input.float(0.20, "Intraday weight", minval = 0.0, step = 0.05, group = G_TF)
float w4hInput = input.float(0.40, "Swing weight", minval = 0.0, step = 0.05, group = G_TF)
float w1dInput = input.float(0.30, "Position weight", minval = 0.0, step = 0.05, group = G_TF)

// -----------------------------------------------------------------------------
// 03. Phase-lock and alerts
// -----------------------------------------------------------------------------
string G_SYNC = "03. Phase-lock and alerts"
float plvThreshold = input.float(70.0, "PLV alert threshold", minval = 0.0, maxval = 100.0, step = 5.0, group = G_SYNC)
float troughHalfWidth = input.float(45.0, "Trough quadrant half-width (degrees)", minval = 5.0, maxval = 90.0, step = 5.0, group = G_SYNC,
     tooltip = "The mean phase is inside the trough quadrant while it sits within this many degrees of 180 or -180 degrees.")
bool alertsOnConfirmedOnly = input.bool(true, "Alerts only on confirmed chart bars", group = G_SYNC)

// -----------------------------------------------------------------------------
// 04. Visuals
// -----------------------------------------------------------------------------
string G_VIS = "04. Visuals"
bool showPhaseWaves = input.bool(false, "Show per-timeframe phase waves", group = G_VIS)
bool shadeTrough = input.bool(true, "Shade trough quadrant background", group = G_VIS)

// -----------------------------------------------------------------------------
// Numeric helpers
// -----------------------------------------------------------------------------
float EPS = 1e-10

f_clip(float value, float lower, float upper) => math.max(lower, math.min(upper, value))

// Wrap an angle difference into (-pi, pi]. One pass is enough because both operands
// already live in [-pi, pi], so their difference stays inside (-2 * pi, 2 * pi).
f_wrap(float angle) =>
    float wrapped = angle
    wrapped := wrapped > math.pi ? wrapped - 2.0 * math.pi : wrapped
    wrapped := wrapped < -math.pi ? wrapped + 2.0 * math.pi : wrapped
    wrapped

// Quadrant-aware arctangent in (-pi, pi]. Pine v6 has no math.atan2 (only
// single-argument math.atan), so this local version is used. Returns 0.0 at the
// origin, where amplitude is zero and the phase is meaningless anyway.
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

// The complete quadrature sensor is evaluated inside each requested timeframe.
f_htq() =>
    float kStoch = ta.stoch(close, high, low, stochLen)
    float rsiValue = ta.rsi(close, rsiLen)
    float rsiBase = ta.rsi(close, stochRsiLen)
    float kStochRsi = ta.sma(ta.stoch(rsiBase, rsiBase, rsiBase, stochRsiLen), smoothK)
    float d = signalType == "Detrended price" ? close - ta.wma(close, hpLen) :
         signalType == "Stoch K" ? kStoch - 50.0 :
         signalType == "RSI" ? rsiValue - 50.0 :
         kStochRsi - 50.0
    // Causal 6-tap Ehlers-style FIR quadrature pair. Q is the same filter delayed 3 bars.
    float i = 0.0962 * d + 0.5769 * d[2] - 0.5769 * d[4] - 0.0962 * d[6]
    float q = 0.0962 * d[3] + 0.5769 * d[5] - 0.5769 * d[7] - 0.0962 * d[9]
    float amp = math.sqrt(i * i + q * q)
    float phase = f_atan2(q, i)
    float dphi = f_wrap(phase - nz(phase[1], phase))
    float ampEma = ta.ema(amp, gateLen)
    float gate = math.min(1.0, amp / math.max(ampEma, EPS))
    [gate, phase]

f_htqConfirmed() =>
    [gate, phase] = f_htq()
    [gate[1], phase[1]]

[g15Dev, p15Dev] = request.security(syminfo.tickerid, tf15, f_htq(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[g1hDev, p1hDev] = request.security(syminfo.tickerid, tf1h, f_htq(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[g4hDev, p4hDev] = request.security(syminfo.tickerid, tf4h, f_htq(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[g1dDev, p1dDev] = request.security(syminfo.tickerid, tf1d, f_htq(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[g15Con, p15Con] = request.security(syminfo.tickerid, tf15, f_htqConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[g1hCon, p1hCon] = request.security(syminfo.tickerid, tf1h, f_htqConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[g4hCon, p4hCon] = request.security(syminfo.tickerid, tf4h, f_htqConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[g1dCon, p1dCon] = request.security(syminfo.tickerid, tf1d, f_htqConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

confirmedMode = dataMode == "Confirmed only"
float g15 = confirmedMode ? g15Con : g15Dev
float g1h = confirmedMode ? g1hCon : g1hDev
float g4h = confirmedMode ? g4hCon : g4hDev
float g1d = confirmedMode ? g1dCon : g1dDev
float p15 = confirmedMode ? p15Con : p15Dev
float p1h = confirmedMode ? p1hCon : p1hDev
float p4h = confirmedMode ? p4hCon : p4hDev
float p1d = confirmedMode ? p1dCon : p1dDev

// Normalize phase weights onto a simplex; all-zero input falls back to the defaults.
float weightSum = w15Input + w1hInput + w4hInput + w1dInput
bool weightsValid = weightSum > 0.0
float w15 = weightsValid ? w15Input / weightSum : 0.10
float w1h = weightsValid ? w1hInput / weightSum : 0.20
float w4h = weightsValid ? w4hInput / weightSum : 0.40
float w1d = weightsValid ? w1dInput / weightSum : 0.30

// -----------------------------------------------------------------------------
// Weighted circular mean and phase-locking value
// -----------------------------------------------------------------------------
// A timeframe contributes only while its phase and gate are valid. PLV is the
// resultant length renormalized by the active weight, so partial warmup of a
// slow timeframe does not blank the whole indicator.
bool v15 = not na(p15) and not na(g15)
bool v1h = not na(p1h) and not na(g1h)
bool v4h = not na(p4h) and not na(g4h)
bool v1d = not na(p1d) and not na(g1d)
float activeW = (v15 ? w15 : 0.0) + (v1h ? w1h : 0.0) + (v4h ? w4h : 0.0) + (v1d ? w1d : 0.0)
float cSum = (v15 ? w15 * g15 * math.cos(p15) : 0.0) + (v1h ? w1h * g1h * math.cos(p1h) : 0.0)
cSum := cSum + (v4h ? w4h * g4h * math.cos(p4h) : 0.0) + (v1d ? w1d * g1d * math.cos(p1d) : 0.0)
float sSum = (v15 ? w15 * g15 * math.sin(p15) : 0.0) + (v1h ? w1h * g1h * math.sin(p1h) : 0.0)
sSum := sSum + (v4h ? w4h * g4h * math.sin(p4h) : 0.0) + (v1d ? w1d * g1d * math.sin(p1d) : 0.0)
float plv = activeW > 0.0 ? 100.0 * math.sqrt(cSum * cSum + sSum * sSum) / activeW : na
float theta = activeW > 0.0 ? f_atan2(sSum, cSum) : na
float thetaDeg = math.todegrees(theta)
float meanWave = 50.0 + 50.0 * math.cos(theta)


// -----------------------------------------------------------------------------
// Trough quadrant state and alerts
// -----------------------------------------------------------------------------
bool inTrough = not na(thetaDeg) and math.abs(nz(thetaDeg, 0.0)) >= 180.0 - troughHalfWidth
chartBarGate = not alertsOnConfirmedOnly or barstate.isconfirmed
bool plvCrossUpRaw = ta.crossover(plv, plvThreshold)
bool plvCrossUp = chartBarGate and plvCrossUpRaw

alertcondition(plvCrossUp, "HT-PLV crossed the threshold", "The phase-lock value crossed above its threshold. This is a reading of the statistic, not a claim that the timeframes have synchronised - measured against a null that shifts the timeframes apart, real data produces a LOWER phase-lock value than misaligned data.")

// -----------------------------------------------------------------------------
// Oscillator-pane visuals
// -----------------------------------------------------------------------------
hline(100, "Upper bound", color = color.new(color.gray, 70))
hline(50, "Midline", color = color.new(color.gray, 70))
hline(0, "Lower bound", color = color.new(color.gray, 70))

int plvTransp = int(math.round(92.0 - 72.0 * f_clip(nz(plv, 0.0) / 100.0, 0.0, 1.0)))
plot(plv, "Phase-lock value", color = color.new(color.teal, plvTransp), style = plot.style_area)
plot(meanWave, "MTF mean phase wave", color = color.white, linewidth = 2)

float wave15 = v15 ? 50.0 + 50.0 * math.cos(p15) : na
float wave1h = v1h ? 50.0 + 50.0 * math.cos(p1h) : na
float wave4h = v4h ? 50.0 + 50.0 * math.cos(p4h) : na
float wave1d = v1d ? 50.0 + 50.0 * math.cos(p1d) : na
plot(showPhaseWaves ? wave15 : na, "15m phase wave", color = color.new(color.aqua, 45), linewidth = 1)
plot(showPhaseWaves ? wave1h : na, "1H phase wave", color = color.new(color.blue, 45), linewidth = 1)
plot(showPhaseWaves ? wave4h : na, "4H phase wave", color = color.new(color.orange, 45), linewidth = 1)
plot(showPhaseWaves ? wave1d : na, "1D phase wave", color = color.new(color.fuchsia, 45), linewidth = 1)

bgcolor(shadeTrough and inTrough ? color.new(color.orange, 90) : na, title = "Mean phase near the cos(theta) minimum")
// No entry/exit markers here on purpose. The trough quadrant is a cycle position, not a
// direction: measured on BINANCE:BTCUSDT 15m the mean one-day return starting inside it was
// +0.226% against +0.687% inside the peak quadrant, so a green up-triangle would point the
// wrong way while looking like a buy.
````
