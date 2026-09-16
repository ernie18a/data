<!-- tradingview-pine-id: PUB;fc39012dc9a347abbf6abf6949d0bddc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dominant Cycle Harmonic Lock [FibonacciFlux]

Source: https://www.tradingview.com/script/iCIj2o7H-Dominant-Cycle-Harmonic-Lock-FibonacciFlux/

## Description

An experiment in whether four timeframes agree about the length of the cycle they are looking at. Published with the arithmetic error it was shipped with, and the fix.

WHAT IT DOES

Inside each of four timeframes (15m, 1H, 4H, 1D by default) it detrends price against a 120-bar moving average and runs a causal autocorrelation scan over lags 5 to 60, taking the first local peak above zero as that timeframe's dominant cycle period. The period is smoothed, converted to minutes, and plotted as a log-period line, so four timeframes measured in different units land on one comparable axis. The white line is the weighted mean of those log-periods and the grey band their weighted dispersion.

The lock test asks whether the four periods sit in the expected nested ratios - each timeframe's cycle roughly four, then four, then six times longer in wall-clock than the one below it. Each pair gets an exponential penalty on its log-ratio error, and the three are combined as a geometric mean. When that score clears the threshold and all four cycle phases sit in the same 90-degree quadrant, the pane marks a resonance diamond. The audit table prints every period in bars and in minutes, every phase and quadrant, the autocorrelation clarity behind each estimate, the three realised ratios against the expected ones, and the pair scores.

THE ERROR THIS VERSION FIXES

The lock score could not reach its own threshold. Not rarely - never, on any instrument, on any timeframe.

The three pair tests compared period counts in BARS while the expected ratios 4/4/6 describe wall-clock nesting. Because every leg searches the same 5-to-60 lag window in its own bars, the timeframe scaling silently divided out: the product of the three ratio terms reduced to P_1d / (96 x P_15), which the lag clamp caps at 60 / (96 x 5) = 0.125. That puts a ceiling of exp(-ln 8 / 1.5) = 0.25 on the lock score against a threshold of 0.80. An exhaustive search over all 9,834,496 integer-period combinations the estimator can produce confirms the maximum is exactly 0.2500. Measured on real data the score never got near even that: it peaked at 0.113 on BINANCE:BTCUSDT 15m and 0.200 on ETHUSDT over 6,000 bars each, so the diamond never drew and the alert never fired.

The fix is to compare in minutes, where 4/4/6 means what the header always claimed. With the default timeframes that is algebraically the same as asking whether the four legs agree on a bar count, and it is now satisfiable. The tolerance default also moved from 0.5 to 1.0, because at 0.5 the repaired score reaches 0.99 but never on a bar where all four phases share a quadrant, so the resonance state stayed empty on BTCUSDT.

WHAT IT DOES AFTER THE FIX, MEASURED

Over 5,757 scored bars of BINANCE:BTCUSDT 15m at the new defaults, the lock score has a median of 0.416, a 95th percentile of 0.667 and a maximum of 0.995. Sixty-two bars clear the 0.80 threshold; all four phases share a quadrant on 543 bars; both conditions hold together on 10 bars, which is 0.17% of them. On ETHUSDT over the same window: median 0.434, maximum 0.928, 67 bars over threshold, 1,302 same-quadrant bars, and 55 resonance bars, or 0.96%.

The background shading is also visible now, which it was not before. It is driven by the lock score, and with the score capped at 0.11 the shading sat at 99% transparency on 41% of bars and never got below 92%.

WHAT THE SCALE ACTUALLY SAYS

Worth knowing before reading anything into a lock. Every leg searches the same 5-to-60 lag window in its own bars, so the periods come out near-identical in bar counts across the four timeframes - medians of 14.6, 14.2 and 14.1 bars on BTCUSDT 15m. In minutes that is close to the nested structure the lock test looks for, which means part of the agreement the score rewards is a property of the shared lag window rather than of the market. The estimator also hits its lower bound often enough to matter.

No edge is claimed and none was measured. There is no forward-return figure here and no suggestion that a resonance diamond predicts anything.

HOW THE NUMBERS WERE CHECKED

The whole computation - detrending, the autocorrelation scan with its first-peak rule, the EMA smoothing, the phase estimate, the weighting and the lock score - was reimplemented outside Pine and cross-checked against this chart's Data Window: eight quantities on ten bars, all agreeing to the four decimals TradingView prints, with a worst raw difference of 4.9e-5 which is the display's own rounding floor.

The check discriminates. Changing the period smoothing from 5 to 4 breaks 65 of the 80 values; changing the autocorrelation window from 60 to 59 breaks 64; reading the higher timeframes in developing rather than confirmed mode breaks 35 with errors four orders of magnitude above the tolerance.

One honest limit on that validation: the resonance path could not be verified against TradingView, because at the old defaults it never fired anywhere. The phase, quadrant and lock-score code is implemented directly from the source and produces sane values, but the only live confirmation of the repaired state is on this chart, not from the original capture.

SETTINGS AND WARM-UP

Each leg needs 242 bars of its own timeframe before it returns anything, so the daily leg needs 242 daily bars of history behind the chart. The four higher-timeframe reads use lookahead together with a one-bar shift inside the requested context, which is the non-repainting idiom: what arrives is the last fully closed bar of that timeframe. Switching the HTF data mode to Developing removes that shift and the values then change until the higher-timeframe bar closes.

The four attention weights are normalized, so only their ratios matter - but they own the plotted shape: driving the profile onto a single timeframe moves the weighted centre line by 3.5 log units, a 33-fold change in the implied period.

WHAT ELSE CHANGED IN THIS VERSION

The audit table that the settings already promised did not exist - its five helper functions were written and left unused - and it is now implemented, including a ratio row that shows the realised minute-domain ratios next to the expected ones. An MPL header was added and a leftover compile-sentinel plot removed. An unexplained lineage note in the header was deleted.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("Dominant Cycle Harmonic Lock [FibonacciFlux]", "Harm Lock", overlay = false, precision = 4)
// Standalone oscillator-pane indicator.
// Estimates the dominant cycle period of each timeframe with a causal
// autocorrelation scan, then scores how well the 15m/1H/4H/1D periods lock
// into the expected nested harmonic ratios (geometric-mean fusion).
// Center line: weighted mean of log-periods (minutes). Ribbon: weighted
// standard deviation of those log-periods.
//
// The four higher-timeframe reads use lookahead_on together with a one-bar shift inside the
// requested context. That pairing is the non-repainting idiom: what arrives on a chart bar is
// the last FULLY CLOSED bar of that timeframe, never a value from the future. Switching HTF
// data mode to Developing removes the shift and the higher-timeframe values then change until
// their own bar closes.
//
// Scale, measured rather than assumed: every leg searches the same 5-60 lag window in its own
// bars, so the periods come out near-identical in BARS across the four timeframes (medians
// 14.6 / 14.2 / 14.1 bars on BINANCE:BTCUSDT 15m, 5757 scored bars). In minutes that is close
// to the nested structure the lock test looks for - which is partly a property of the shared
// lag window, not only of the market.

// -----------------------------------------------------------------------------
// 01. Cycle estimation
// -----------------------------------------------------------------------------
string G_CYCLE = "01. Cycle estimation"
int minLag = input.int(5, "Minimum lag (bars of that TF)", minval = 2, maxval = 50, group = G_CYCLE)
int maxLag = input.int(60, "Maximum lag (bars of that TF)", minval = 10, maxval = 120, group = G_CYCLE)
int acWindow = input.int(60, "Autocorrelation window (samples)", minval = 20, maxval = 200, group = G_CYCLE)
int smoothLen = input.int(5, "Period smoothing (EMA bars of that TF)", minval = 1, maxval = 50, group = G_CYCLE)
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Confirmed only", "Developing HTF"], group = G_CYCLE,
     tooltip = "Confirmed only uses the previous completed bar in each requested timeframe. Developing HTF reacts earlier but values change until the open higher-timeframe bar closes.")

// -----------------------------------------------------------------------------
// 02. Timeframes and attention weights
// -----------------------------------------------------------------------------
string G_TF = "02. Timeframes and attention weights"
string tf15 = input.timeframe("15", "Short-term timeframe", group = G_TF)
string tf1h = input.timeframe("60", "Intraday timeframe", group = G_TF)
string tf4h = input.timeframe("240", "Swing timeframe", group = G_TF)
string tf1d = input.timeframe("1D", "Position timeframe", group = G_TF)
float w15Input = input.float(0.10, "Short-term weight", minval = 0.0, step = 0.05, group = G_TF)
float w1hInput = input.float(0.20, "Intraday weight", minval = 0.0, step = 0.05, group = G_TF)
float w4hInput = input.float(0.40, "Swing weight", minval = 0.0, step = 0.05, group = G_TF)
float w1dInput = input.float(0.30, "Position weight", minval = 0.0, step = 0.05, group = G_TF)

// -----------------------------------------------------------------------------
// 03. Harmonic lock
// -----------------------------------------------------------------------------
string G_LOCK = "03. Harmonic lock"
float eRatio1 = input.float(4.0, "Expected ratio short to intraday (wall clock)", minval = 0.5, step = 0.5, group = G_LOCK,
     tooltip = "How many times longer the intraday cycle should be than the short-term one, measured in minutes rather than in bars. The default 4 is the ratio of the default timeframes themselves, which is what nested means here.")
float eRatio2 = input.float(4.0, "Expected ratio intraday to swing (wall clock)", minval = 0.5, step = 0.5, group = G_LOCK)
float eRatio3 = input.float(6.0, "Expected ratio swing to position (wall clock)", minval = 0.5, step = 0.5, group = G_LOCK)
float lockTol = input.float(1.0, "Lock tolerance (log-ratio scale)", minval = 0.05, maxval = 3.0, step = 0.05, group = G_LOCK,
     tooltip = "Width of the exponential penalty on each pair ratio. Measured over 5757 scored bars of BINANCE:BTCUSDT 15m with the minute-domain test: at 0.5 the lock score reaches 0.99 but never on a bar where all four phases share a quadrant, so the resonance state stayed empty; at 1.0 it fires on 10 bars (0.17%) on BTCUSDT and 55 (0.96%) on ETHUSDT. Below about 0.75 expect the resonance marker to be very rare or absent.")
float lockThreshold = input.float(0.8, "Resonance lock threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = G_LOCK)
bool signalOnClose = input.bool(true, "Alerts only on confirmed chart bars", group = G_LOCK)

// -----------------------------------------------------------------------------
// 04. Visuals
// -----------------------------------------------------------------------------
string G_VIS = "04. Visuals"
bool showPeriods = input.bool(true, "Show per-timeframe log-period lines", group = G_VIS)
bool showRibbon = input.bool(true, "Show weighted log-period ribbon", group = G_VIS)
bool shadeBackground = input.bool(true, "Shade background with lock score", group = G_VIS)
bool showTable = input.bool(true, "Show cycle audit table", group = G_VIS)
string tablePos = input.string("Top right", "Audit table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = G_VIS)
string tableSize = input.string("Small", "Audit table text size", options = ["Tiny", "Small", "Normal"], group = G_VIS)

// -----------------------------------------------------------------------------
// Numeric helpers
// -----------------------------------------------------------------------------
float EPS = 1e-10

f_clip(float value, float lower, float upper) => math.max(lower, math.min(upper, value))

// Effective lag bounds (guard against minLag > maxLag input combinations).
int effMinLag = minLag
int effMaxLag = math.max(maxLag, minLag + 2)
int detrendLen = 2 * effMaxLag

// The complete cycle sensor is evaluated inside each requested timeframe.
// Returns [smoothed dominant period (bars of that TF), cycle phase (degrees),
// autocorrelation clarity at the chosen lag, detrended RMS amplitude].
f_cycle() =>
    float baseMa = ta.sma(close, detrendLen)
    float d = close - baseMa
    float rawP = na
    float clarity = na
    float amp = na
    int warmBars = acWindow + 3 * effMaxLag + 2
    if bar_index >= warmBars
        float denom = 0.0
        for i = 0 to acWindow - 1
            float di = d[i]
            denom += di * di
        int bestLag = effMinLag
        float bestAc = -2.0
        bool found = false
        int peakLag = effMinLag
        float peakAc = 0.0
        float acPrev2 = na
        float acPrev1 = na
        for L = effMinLag to effMaxLag
            float num = 0.0
            for i = 0 to acWindow - 1
                num += d[i] * d[i + L]
            float ac = num / math.max(denom, EPS)
            if ac > bestAc
                bestAc := ac
                bestLag := L
            // First local maximum above zero wins (first-peak rule).
            if not found and not na(acPrev2) and acPrev1 > acPrev2 and acPrev1 > ac and acPrev1 > 0.0
                found := true
                peakLag := L - 1
                peakAc := acPrev1
            acPrev2 := acPrev1
            acPrev1 := ac
        rawP := found ? float(peakLag) : float(bestLag)
        clarity := found ? peakAc : bestAc
        amp := math.sqrt(denom / acWindow)
    float P = ta.ema(rawP, smoothLen)
    // Cycle phase: bars since the last confirmed detrended trough over P.
    bool troughNow = d[1] < d and d[1] <= d[2]
    int tauConfirm = ta.barssince(troughNow)
    float phaseTurns = na(P) or na(tauConfirm) or P <= 0.0 ? na : float(tauConfirm + 1) / P
    float thetaDeg = na(phaseTurns) ? na : 360.0 * (phaseTurns - math.floor(phaseTurns))
    [P, thetaDeg, clarity, amp]

f_cycleConfirmed() =>
    [pC, thC, clC, amC] = f_cycle()
    [pC[1], thC[1], clC[1], amC[1]]

[p15Dev, th15Dev, cl15Dev, am15Dev] = request.security(syminfo.tickerid, tf15, f_cycle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[p1hDev, th1hDev, cl1hDev, am1hDev] = request.security(syminfo.tickerid, tf1h, f_cycle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[p4hDev, th4hDev, cl4hDev, am4hDev] = request.security(syminfo.tickerid, tf4h, f_cycle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[p1dDev, th1dDev, cl1dDev, am1dDev] = request.security(syminfo.tickerid, tf1d, f_cycle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[p15Con, th15Con, cl15Con, am15Con] = request.security(syminfo.tickerid, tf15, f_cycleConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[p1hCon, th1hCon, cl1hCon, am1hCon] = request.security(syminfo.tickerid, tf1h, f_cycleConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[p4hCon, th4hCon, cl4hCon, am4hCon] = request.security(syminfo.tickerid, tf4h, f_cycleConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[p1dCon, th1dCon, cl1dCon, am1dCon] = request.security(syminfo.tickerid, tf1d, f_cycleConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

confirmedMode = dataMode == "Confirmed only"
float P_15 = confirmedMode ? p15Con : p15Dev
float P_1h = confirmedMode ? p1hCon : p1hDev
float P_4h = confirmedMode ? p4hCon : p4hDev
float P_1d = confirmedMode ? p1dCon : p1dDev
float th_15 = confirmedMode ? th15Con : th15Dev
float th_1h = confirmedMode ? th1hCon : th1hDev
float th_4h = confirmedMode ? th4hCon : th4hDev
float th_1d = confirmedMode ? th1dCon : th1dDev
float cl_15 = confirmedMode ? cl15Con : cl15Dev
float cl_1h = confirmedMode ? cl1hCon : cl1hDev
float cl_4h = confirmedMode ? cl4hCon : cl4hDev
float cl_1d = confirmedMode ? cl1dCon : cl1dDev

// Normalize attention weights onto a simplex. All-zero input falls back to
// the default 0.10 / 0.20 / 0.40 / 0.30 profile.
float wSum = w15Input + w1hInput + w4hInput + w1dInput
bool wFallback = wSum <= 0.0
float w15 = (wFallback ? 0.10 : w15Input) / (wFallback ? 1.0 : wSum)
float w1h = (wFallback ? 0.20 : w1hInput) / (wFallback ? 1.0 : wSum)
float w4h = (wFallback ? 0.40 : w4hInput) / (wFallback ? 1.0 : wSum)
float w1d = (wFallback ? 0.30 : w1dInput) / (wFallback ? 1.0 : wSum)

// -----------------------------------------------------------------------------
// Log-period space (periods converted to minutes for cross-timeframe scale)
// -----------------------------------------------------------------------------
float tfMin15 = timeframe.in_seconds(tf15) / 60.0
float tfMin1h = timeframe.in_seconds(tf1h) / 60.0
float tfMin4h = timeframe.in_seconds(tf4h) / 60.0
float tfMin1d = timeframe.in_seconds(tf1d) / 60.0

float lp15 = P_15 > 0.0 ? math.log(P_15 * tfMin15) : na
float lp1h = P_1h > 0.0 ? math.log(P_1h * tfMin1h) : na
float lp4h = P_4h > 0.0 ? math.log(P_4h * tfMin4h) : na
float lp1d = P_1d > 0.0 ? math.log(P_1d * tfMin1d) : na

// Weighted log-period center and dispersion ribbon.
float muLp = w15 * lp15 + w1h * lp1h + w4h * lp4h + w1d * lp1d
float varLp = w15 * math.pow(lp15 - muLp, 2) + w1h * math.pow(lp1h - muLp, 2) + w4h * math.pow(lp4h - muLp, 2) + w1d * math.pow(lp1d - muLp, 2)
float sigLp = math.sqrt(math.max(varLp, 0.0))

// -----------------------------------------------------------------------------
// Harmonic lock score (geometric mean of the three pair scores)
// -----------------------------------------------------------------------------
// The three pair tests run in MINUTES, not in bars. Each leg searches the same lag window in
// its own bars, so a comparison of raw bar counts silently divides out the timeframe scaling:
// with the default 15m/1H/4H/1D and ratios 4/4/6 the product r1*r2*r3 reduced to
// P_1d / (96 * P_15), which the [minLag, maxLag] clamp caps at 60 / (96 * 5) = 0.125 - a lock
// score ceiling of exp(-ln(8) / (3 * 0.5)) = 0.25 against a 0.8 threshold, on every chart that
// exists. In minutes the same 4/4/6 asks the question the header always meant to ask: is each
// timeframe's dominant cycle about four (then four, then six) times longer in wall-clock than
// the one below it.
float m15 = P_15 > 0.0 ? P_15 * tfMin15 : na
float m1h = P_1h > 0.0 ? P_1h * tfMin1h : na
float m4h = P_4h > 0.0 ? P_4h * tfMin4h : na
float m1d = P_1d > 0.0 ? P_1d * tfMin1d : na
float r1 = not na(m15) and not na(m1h) ? m1h / (m15 * eRatio1) : na
float r2 = not na(m1h) and not na(m4h) ? m4h / (m1h * eRatio2) : na
float r3 = not na(m4h) and not na(m1d) ? m1d / (m4h * eRatio3) : na
float s1 = not na(r1) and r1 > 0.0 ? math.exp(-math.abs(math.log(r1)) / lockTol) : na
float s2 = not na(r2) and r2 > 0.0 ? math.exp(-math.abs(math.log(r2)) / lockTol) : na
float s3 = not na(r3) and r3 > 0.0 ? math.exp(-math.abs(math.log(r3)) / lockTol) : na
float lockScore = math.pow(s1 * s2 * s3, 1.0 / 3.0)

// Cycle-phase quadrants and the resonance window state.
f_quad(float theta) =>
    na(theta) ? -1 : int(math.floor(theta / 90.0))

int q15 = f_quad(th_15)
int q1h = f_quad(th_1h)
int q4h = f_quad(th_4h)
int q1d = f_quad(th_1d)
bool sameQuad = q15 >= 0 and q15 == q1h and q1h == q4h and q4h == q1d
bool resonance = not na(lockScore) and lockScore >= lockThreshold and sameQuad

// -----------------------------------------------------------------------------
// Oscillator-pane visuals (log-period domain, ln of minutes)
// -----------------------------------------------------------------------------
float lockClipped = f_clip(nz(lockScore, 0.0), 0.0, 1.0)
int ribbonTransp = 100 - int(math.round(70.0 * lockClipped))
color ribbonColor = color.new(color.orange, ribbonTransp)

upperPlot = plot(showRibbon ? muLp + sigLp : na, "Log-period ribbon upper", color = color.new(color.white, 88), linewidth = 1)
lowerPlot = plot(showRibbon ? muLp - sigLp : na, "Log-period ribbon lower", color = color.new(color.white, 88), linewidth = 1)
plot(showRibbon ? muLp : na, "Weighted log-period center", color = color.white, linewidth = 3)
fill(upperPlot, lowerPlot, color = ribbonColor, title = "Weighted log-period dispersion ribbon")

plot(showPeriods ? lp15 : na, "15m log-period", color = color.new(color.aqua, 40), linewidth = 1)
plot(showPeriods ? lp1h : na, "1H log-period", color = color.new(color.blue, 35), linewidth = 1)
plot(showPeriods ? lp4h : na, "4H log-period", color = color.new(color.orange, 30), linewidth = 1)
plot(showPeriods ? lp1d : na, "1D log-period", color = color.new(color.fuchsia, 30), linewidth = 1)

int bgTransp = 100 - int(math.round(85.0 * lockClipped))
bgcolor(shadeBackground ? color.new(color.orange, bgTransp) : na, title = "Harmonic lock intensity")

plotshape(resonance, "Resonance window", shape.diamond, location.bottom, color.new(color.orange, 0), size = size.small)

chartBarGate = not signalOnClose or barstate.isconfirmed
bool resonanceEvent = chartBarGate and resonance and not resonance[1]
alertcondition(resonanceEvent, "Harmonic lock resonance window", "Lock score is at or above the threshold while all timeframe cycle phases sit in the same quadrant.")

// -----------------------------------------------------------------------------
// Cycle audit table
// -----------------------------------------------------------------------------
f_tfName(string tf) =>
    tf == "15" ? "15m" : tf == "60" ? "1H" : tf == "240" ? "4H" : tf == "1D" ? "1D" : tf

f_num(float value) => na(value) ? "-" : str.tostring(value, "#.00")

f_pText(float value) => na(value) ? "-" : str.tostring(value, "#.0")

f_thetaText(float theta) =>
    na(theta) ? "-" : str.tostring(theta, "#.0") + " Q" + str.tostring(f_quad(theta) + 1)

f_clarityColor(float value) =>
    na(value) ? color.new(color.gray, 65) : value >= 0.30 ? color.new(color.lime, 40) : value >= 0.15 ? color.new(color.orange, 40) : color.new(color.red, 40)

f_lockText(float v) => na(v) ? "-" : str.tostring(v, "#.00")

color cPanel = color.rgb(20, 23, 28)
color cLine = color.rgb(58, 63, 71)
color cInk = color.rgb(216, 220, 226)
color cDim = color.rgb(128, 132, 138)

tablePosition = tablePos == "Top left" ? position.top_left : tablePos == "Bottom right" ? position.bottom_right : tablePos == "Bottom left" ? position.bottom_left : position.top_right
tableTextSize = tableSize == "Tiny" ? size.tiny : tableSize == "Normal" ? size.normal : size.small

var table auditTable = table.new(position.top_right, 5, 8, border_color = cLine, border_width = 1, frame_color = cLine, frame_width = 1)

f_head(int col, int row, string txt) =>
    table.cell(auditTable, col, row, txt, text_color = cDim, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_right)

f_cell(int col, int row, string txt, color txtColor) =>
    table.cell(auditTable, col, row, txt, text_color = txtColor, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_right)

f_left(int col, int row, string txt, color txtColor) =>
    table.cell(auditTable, col, row, txt, text_color = txtColor, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)

f_tfRow(int row, string tfName, float P, float tfMinutes, float theta, float clarity) =>
    f_left(0, row, tfName, cInk)
    f_cell(1, row, f_pText(P), cInk)
    f_cell(2, row, na(P) ? "-" : f_pText(P * tfMinutes), cInk)
    f_cell(3, row, f_thetaText(theta), cInk)
    f_cell(4, row, f_num(clarity), f_clarityColor(clarity))

if barstate.islast and showTable
    table.set_position(auditTable, tablePosition)

    f_left(0, 0, "TF", cDim)
    f_head(1, 0, "P bars")
    f_head(2, 0, "P min")
    f_head(3, 0, "phase")
    f_head(4, 0, "clarity")

    f_tfRow(1, f_tfName(tf15), P_15, tfMin15, th_15, cl_15)
    f_tfRow(2, f_tfName(tf1h), P_1h, tfMin1h, th_1h, cl_1h)
    f_tfRow(3, f_tfName(tf4h), P_4h, tfMin4h, th_4h, cl_4h)
    f_tfRow(4, f_tfName(tf1d), P_1d, tfMin1d, th_1d, cl_1d)

    f_left(0, 5, "RATIO", cDim)
    f_cell(1, 5, na(m15) or na(m1h) ? "-" : f_lockText(m1h / m15), cInk)
    f_cell(2, 5, na(m1h) or na(m4h) ? "-" : f_lockText(m4h / m1h), cInk)
    f_cell(3, 5, na(m4h) or na(m1d) ? "-" : f_lockText(m1d / m4h), cInk)
    f_cell(4, 5, "want " + f_lockText(eRatio1) + "/" + f_lockText(eRatio2) + "/" + f_lockText(eRatio3), cDim)

    f_left(0, 6, "PAIR", cDim)
    f_cell(1, 6, f_lockText(s1), cInk)
    f_cell(2, 6, f_lockText(s2), cInk)
    f_cell(3, 6, f_lockText(s3), cInk)
    f_cell(4, 6, "tol " + f_lockText(lockTol), cDim)

    color stateCol = resonance ? color.orange : cDim
    f_left(0, 7, "LOCK", cDim)
    f_cell(1, 7, f_lockText(lockScore), stateCol)
    f_cell(2, 7, "thr " + f_lockText(lockThreshold), cDim)
    f_cell(3, 7, sameQuad ? "same Q" : "split Q", sameQuad ? color.orange : cDim)
    f_cell(4, 7, resonance ? "RESONANCE" : "-", stateCol)
````
