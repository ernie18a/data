<!-- tradingview-pine-id: PUB;fc021aff57464b7197bd94641584fced -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MTF Stochastic Phase Fusion [FibonacciFlux]

Source: https://www.tradingview.com/script/5rWFHKdo-MTF-Stochastic-Phase-Fusion-FibonacciFlux/

## Description

Six Stochastic timeframes fused into a tactical and a structural wave, with a decaying pulse on their crossings - published with a re-run of the backtest the pulse is built on, which finds no edge, a move that is over before the marker prints, and a holdout that was searched.

WHAT IT DRAWS

Stochastic %K is computed inside each of six timeframes (15m, 1H, 4H, 1D, 1W, 1M). Four of them are weighted into a tactical wave, three into a structural wave, and the spread between the two is the thing the indicator is about. A phase-plane term treats centred %K as a real axis and scaled %K velocity as a quadrature axis; the length of the weighted unit-vector sum becomes the tactical coherence area behind the waves. On the price pane, a golden or dead cross of tactical over structural drops a GC or DC label with a Type letter, and that pulse decays over a symbol-specific life - 120 minutes on BTC, 60 on ETH - fading out as it expires. If the adverse excursion since the cross passes a threshold, a TAIL marker appears.

THE PULSE'S EVIDENCE, RE-RUN

This is the first script I have published where the original backtest could actually be repeated. It was run on BTCUSDT and ETHUSDT 15m, train 2024-07 to 2025-12 and a one-shot holdout 2026-01 to 2026-07, and Binance serves that whole span, so it was re-run on 84,426 bars per symbol rather than taken on trust. Four things came out, and none of them supports the claim.

NO EDGE SURVIVES A PROPER NULL

Across 236 (cell, statistic, threshold) tests on two instruments and two chart timeframes, against a circular-shift null of 200 to 400 draws, ZERO reach p <= 0.05 - where about 12 would be expected by chance alone. The median p is 0.632. Nothing passes a multiple-testing correction because nothing passes without one.

The single result that once looked significant, a BTCUSDT mean of +4.98bp at p = 0.049, was a draw-count artifact. At 40 draws the achievable p values are multiples of 1/41, so 0.049 is literally one draw away from nothing; re-run at 1000 draws under three seeds the same test gives 0.055, 0.069 and 0.065, and it vanishes at every neighbouring horizon.

THE MOVE IS OVER BEFORE THE MARKER PRINTS

This is the part that replicates in every cell tested, and it is the honest description of the thing. Measuring the same horizon ending at the cross against the one starting at it:

    BTCUSDT golden   +31.03bp before   +4.09bp after    88.4% already spent
    BTCUSDT dead     +29.80bp before   -1.73bp after    94.5% already spent
    ETHUSDT golden   +36.72bp before   -2.02bp after    94.8% already spent
    ETHUSDT dead     +44.40bp before   -2.34bp after    95.0% already spent

Between 88% and 95% of the round trip associated with a crossing has already happened when the marker appears. Note the dead crosses too: on both symbols price has risen roughly 30 to 44bp into a dead cross. That is what a crossover of two smoothed multi-timeframe stochastics does - it reports, it does not anticipate.

THE HOLDOUT WAS SEARCHED

The quoted "~58% holdout win rate" is 54.63% in the shipped configuration. 58% appears only as one cell of a 56-cell grid of pulse life against coherence gate, evaluated on the holdout itself, whose maximum is 77.42%. A holdout you search is a second training set, and that is the finding most damaging to the original methodology - more so than any single number in it.

Two related corrections. The header said the losing side's adverse excursion grew from about 0.7% to about 1.1%; measured it goes 0.668% to 0.773%. And it said the holdout mean "flipped negative"; in the shipped configuration the BTCUSDT holdout mean is +3.72bp, positive.

THE PULSE-LIFE DEFAULTS ARE NOT MEASURED OPTIMA

The 60-minute ETH pulse life returns -1.58bp at exactly that horizon - a loss - ranking fifth of the ten horizons swept in its own cell, where the best is +6.91bp at 480 minutes. The 120-minute BTC life ranks fourth of ten. And which horizon looks best is uncorrelated between the two symbols, Spearman -0.03, so the horizon profile describes this sample rather than the indicator. Both defaults are kept so the chart matches the research it came from, and both tooltips now say this.

WHAT ABOUT THE TAIL MARKER

It is a description of drawdown that has already happened, not a warning about drawdown to come. TAIL-flagged pulses average -140.32bp, and randomly placed pulses carrying the same flag average -144.04bp, p = 0.634. Conditioning on a large adverse excursion selects losing trades by arithmetic; the flag adds nothing. Worse for the threshold's stated justification, on BTCUSDT - the instrument it was calibrated from - real pulses have a THINNER left tail than the null at every level tested.

WHAT THE PULSE ACTUALLY DOES ON A CHART

Over 84,155 scored bars of BTCUSDT 15m at the shipped defaults there are 639 golden and 638 dead crosses. A long pulse is running on 5.1% of bars and a short pulse on 5.1%, so some pulse is live on 8.1% of bars - and on 2.1% of bars a long pulse and a short pulse are running at the same time, because they are independent state machines and neither cancels the other. ETHUSDT gives 821 and 820 crosses, 6.3% pulse-active, 0.9% overlapping. The TAIL state, the one the header calls the failure mode, is on for 0.2% of bars on BTCUSDT and 0.1% on ETHUSDT.

The alert floor of 65 on tactical coherence is not a tight filter: coherence sits above it on 31.7% of BTCUSDT bars and 29.2% of ETHUSDT bars, with a median of 49.2 and 47.7 respectively.

WHAT CHANGED IN THIS VERSION

The largest dead-code removal in this series of publications, none of which touches a plotted value.

A settings toggle promised a "state table" that did not exist anywhere in the file - no table, no cell - and the three helper functions written for it were the last three lines of the script. Gone.

Every %D value was unused. Both state functions returned a %D line, all twelve request.security calls carried it, and not one of the twelve was ever read. That made the "%D smoothing" input completely inert: swept from 1 to 30 across 420,775 bar comparisons on two symbols it changed no plotted series by any amount at all and left the pulse count identical. The input and the twelve unread series are gone, which also takes a third series off each of twelve higher-timeframe requests.

Three more computed-and-never-used values went with them: the structural coherence, the wave spread, and the maximum favourable excursion tracked for both pulse sides. Maximum ADVERSE excursion stays, because the caution and TAIL states read it.

The Type A to B upgrade markers and their two alerts are gone, because they cannot fire. An upgrade needs the structural wave to cross 50 while a pulse is still alive - but the structural wave is built from 1D, 1W and 1M legs and a pulse lives eight bars on BTC or four on ETH, so its median change over an entire pulse life is exactly 0.000 on both symbols. Measured: 0 upgrades in 1,070 BTCUSDT pulses, of which 546 started as Type A, and 1 upgrade in 1,518 ETHUSDT pulses. Two plotshapes, two alert conditions and a documented taxonomy for an event that fires once in 2,588 pulses. The Type letter on the GC/DC label is reachable and stays.

The HTF data mode defaulted to "Developing HTF", the repainting one. With six requested timeframes reaching up to 1M, an open monthly bar keeps moving the structural wave for weeks. The default is Confirmed only now, and the tooltip says the word repaints. One thing worth knowing: on historical bars the two modes differ only in the 15m leg, because that is the chart timeframe - the higher-timeframe legs resolve to the same completed bar either way.

924 box-drawing characters, a Unicode minus and three arrow glyphs became ASCII, an MPL header was added, and the title dropped its version suffix for the handle.

WHAT THE MEASUREMENTS COVER

BTCUSDT and ETHUSDT 15m from Binance, 2024-04 to 2026-08, 84,426 bars per symbol, which spans the original train and holdout windows entirely. No other instrument, no other timeframe, no transaction costs. The pulse-life defaults of 120 and 60 minutes came from the original screen; the 90-minute fallback for every other symbol did not, and its tooltip says so.

One warm-up note that bites on real charts: the structural wave needs 16 monthly bars before it exists, so this indicator plots nothing at all on any symbol with less than about sixteen months of monthly history, however much intraday history the chart has.

HOW THE NUMBERS WERE CHECKED

The whole computation was reimplemented outside Pine and cross-checked against this chart's Data Window: 24 quantities on 10 bars, 240 values - both waves, tactical coherence, all six raw sensors, three velocities, both cross flags, both pulse-active flags, both adverse-excursion trackers and both decay intensities. The captured bars include a golden cross, a dead cross and several bars inside a live pulse, so the pulse state machine and the MAE tracking were exercised rather than assumed. All 240 values round to the exact two decimals TradingView prints, worst raw difference 4.9e-3.

That check earned its keep. A first version of the reimplementation was wrong in a way that is invisible almost everywhere: a higher-timeframe request updates on the chart bar that closes WITH the higher-timeframe bar, not one period later. Using "always the previous closed bar" is correct on three of every four 15-minute bars against a 1H leg and wrong on the fourth. It produced a 9.09-point error on the 1H sensor at 22:45 and exactly zero error at 22:30, and only the live comparison caught it.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("MTF Stochastic Phase Fusion [FibonacciFlux]", "MTF Stoch Phase Fusion (Pulse)", overlay = false, precision = 2, max_labels_count = 500)

// This indicator treats each timeframe as a nonlinear state sensor, not as an
// orthogonal Fourier band. The phase-plane approximation combines centered
// STOCH position (real axis) and STOCH velocity (quadrature axis).
//
// GC/DC PULSE MODEL, AND THE RE-RUN THAT DOES NOT SUPPORT IT
//
// A backtest screen on BTCUSDT/ETHUSDT 15m (train 2024-07 to 2025-12, one-shot holdout
// 2026-01 to 2026-07) reported that tacticalWave crossing structuralWave carries a
// short-lived asymmetric edge. That screen has now been re-run on the same data -
// 84,426 bars per symbol - and it does not hold up. This block records what was found,
// because the pulse is still drawn and a reader is entitled to know what it is worth.
//
// 1. NO EDGE SURVIVES A PROPER NULL. Across 236 (cell, statistic, threshold) tests on
//    two instruments and two chart timeframes against a circular-shift null, ZERO reach
//    p <= 0.05 where about 12 would be expected by chance alone, and the median p is
//    0.632. The one result that once looked significant (BTCUSDT +4.98bp, p = 0.049) was
//    a draw-count artifact: at 40 draws the p grid is 1/41, and at 1000 draws the same
//    test gives 0.055 to 0.069.
//
// 2. THE MOVE IS OVER BEFORE THE CROSS PRINTS. Measuring the same horizon ending at the
//    cross against the one starting at it: BTCUSDT golden crosses run +31.03bp BEFORE and
//    +4.09bp after, dead crosses +29.80bp before and -1.73bp after; ETHUSDT golden +36.72
//    before and -2.02 after, dead +44.40 and -2.34. Between 88% and 95% of the round trip
//    is already spent when the marker appears. This replicates in every cell tested and is
//    the honest description of what a moving-average-style crossover of two smoothed
//    multi-timeframe stochastics does.
//
// 3. THE HOLDOUT WAS SEARCHED. The quoted "~58% holdout win rate" is 54.63% in the
//    shipped configuration; 58% appears only as one cell of a 56-cell (pulse life x
//    coherence gate) grid evaluated on the holdout itself, whose maximum is 77.42%. A
//    holdout you search is a second training set. Related: the header used to say the
//    losing side's MAE grew from ~0.7% to ~1.1%; measured it goes 0.668% to 0.773%.
//
// 4. THE PULSE-LIFE DEFAULTS ARE NOT MEASURED OPTIMA. The 60-minute ETH life returns
//    -1.58bp at exactly that horizon, ranking 5th of 10 in its own sweep; the 120-minute
//    BTC life ranks 4th of 10. Which horizon "works" is also uncorrelated between the two
//    symbols (Spearman -0.03), so it is a property of the sample, not of the indicator.
//
// The pulse is therefore a decaying annotation of a crossing that has already happened.
// It is drawn with an expiry so it cannot be read as a standing signal, and it is not a
// forecast of anything.

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
string GROUP_STOCH = "01. Stochastic"
int kLength = input.int(14, "%K length", minval = 2, group = GROUP_STOCH)
int kSmooth = input.int(3, "%K smoothing", minval = 1, group = GROUP_STOCH)
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Developing HTF", "Confirmed only"], group = GROUP_STOCH,
     tooltip = "Confirmed only reads the last completed bar of each requested timeframe, so a value never changes once its chart bar has opened. Developing HTF REPAINTS: with six requested timeframes up to 1M, an open monthly bar keeps moving the structural wave for weeks. The default was Developing in the previous version; it is Confirmed now. Note that on historical bars the two modes differ only in the 15m leg, because that is the chart timeframe - the higher-timeframe legs resolve to the same completed bar either way.")

string GROUP_OUTPUT = "02. Fusion"
string waveMode = input.string("Weighted STOCH", "Wave definition", options = ["Weighted STOCH", "Phase-vector wave"], group = GROUP_OUTPUT,
     tooltip = "Read this before trusting the GC/DC numbers in the header. Those figures were produced on the PHASE-VECTOR WAVE and on long crosses only; this input ships on Weighted STOCH and the chart draws both directions. Re-running the same screen on the shipped default gives BTCUSDT holdout win 52.1% and mean +0.0086% instead of 57.8% and -0.0166%. The default is left alone rather than quietly retuned to match the evidence, because changing it would change what every existing chart shows - but the mismatch is real and it is yours to resolve.")
float velocityGain = input.float(2.0, "Phase velocity gain", minval = 0.1, maxval = 10.0, step = 0.1, group = GROUP_OUTPUT)
float minCoherence = input.float(65.0, "Minimum coherence for alerts", minval = 0.0, maxval = 100.0, step = 1.0, group = GROUP_OUTPUT)
bool showCoherence = input.bool(true, "Show tactical coherence area", group = GROUP_OUTPUT)
bool showRawSensors = input.bool(false, "Show all six STOCH sensors", group = GROUP_OUTPUT)

string GROUP_TACTICAL = "03. Tactical weights"
float wt15Input = input.float(0.10, "15m", minval = 0.0, step = 0.05, group = GROUP_TACTICAL)
float wt1hInput = input.float(0.20, "1H", minval = 0.0, step = 0.05, group = GROUP_TACTICAL)
float wt4hInput = input.float(0.40, "4H", minval = 0.0, step = 0.05, group = GROUP_TACTICAL)
float wt1dInput = input.float(0.30, "1D", minval = 0.0, step = 0.05, group = GROUP_TACTICAL)

string GROUP_STRUCTURAL = "04. Structural weights"
float ws1dInput = input.float(0.25, "1D", minval = 0.0, step = 0.05, group = GROUP_STRUCTURAL)
float ws1wInput = input.float(0.45, "1W", minval = 0.0, step = 0.05, group = GROUP_STRUCTURAL)
float ws1mInput = input.float(0.30, "1M", minval = 0.0, step = 0.05, group = GROUP_STRUCTURAL)

string GROUP_VISUAL = "05. Visuals"
color tacticalColor = input.color(color.rgb(0, 220, 220), "Tactical", group = GROUP_VISUAL)
color structuralColor = input.color(color.rgb(230, 70, 220), "Structural", group = GROUP_VISUAL)
color coherenceColor = input.color(color.rgb(35, 110, 255), "Coherence", group = GROUP_VISUAL)

string GROUP_PULSE = "06. GC/DC Pulse"
float pulseLifeBTCInput = input.float(120.0, "BTC pulse life (minutes)", minval = 1.0, group = GROUP_PULSE,
     tooltip = "From the original screen, but not an optimum and not an edge. Swept over ten wall-clock horizons on BTCUSDT 15m this ranks 4th (+4.98bp against a best of +19.00bp at 1440min), and none of the horizons separates from a circular-shift null. Which horizon looks best is also uncorrelated between BTCUSDT and ETHUSDT (Spearman -0.03), so it describes this sample rather than the indicator.")
float pulseLifeETHInput = input.float(60.0, "ETH pulse life (minutes)", minval = 1.0, group = GROUP_PULSE,
     tooltip = "From the original screen, and it loses money in its own sweep: at exactly this horizon ETHUSDT 15m golden crosses return -1.58bp, ranking 5th of the ten horizons tested (best +6.91bp at 480min). It is kept as the shipped value so the chart matches the research it came from, not because it was found to work.")
float pulseLifeDefaultInput = input.float(90.0, "Other symbols pulse life (minutes)", minval = 1.0, group = GROUP_PULSE,
     tooltip = "BTC/ETH values came from a real-data screen on BTCUSDT/ETHUSDT 15m bars. This fallback for any other symbol is NOT independently validated -- treat it as a placeholder, not a measured edge.")
float decayFractionInput = input.float(0.35, "Pulse decay tau (fraction of life)", minval = 0.05, maxval = 1.0, step = 0.05, group = GROUP_PULSE,
     tooltip = "Intensity = exp(-elapsed/tau), tau = pulse_life_bars * this fraction. Smaller = faster visual fade.")
float cautionMaeInput = input.float(1.0, "Caution MAE threshold (%)", minval = 0.0, step = 0.1, group = GROUP_PULSE)
float tailMaeInput = input.float(1.5, "TAIL warning MAE threshold (%)", minval = 0.0, step = 0.1, group = GROUP_PULSE,
     tooltip = "This marker is a description of drawdown that has already happened, not a warning about drawdown to come. Two measurements say so. First, conditioning on a large adverse excursion selects losing trades by arithmetic: TAIL-flagged pulses average -140.32bp, and randomly placed pulses carrying the same flag average -144.04bp (p = 0.634), so the flag adds nothing to the selection. Second, the threshold was calibrated on BTCUSDT and on that very instrument real pulses have a THINNER left tail than a circular-shift null at every level tested. The original 1.5% was justified by a claimed MAE growth from ~0.7% to ~1.1%; the measured growth is 0.668% to 0.773% and never approaches 1.1%.")
bool showPulseOnChart = input.bool(true, "Force-show GC/DC/TAIL markers on the price chart", group = GROUP_PULSE)
bool showPulseAlerts = input.bool(true, "Enable GC/DC/TAIL alerts", group = GROUP_PULSE)

// -----------------------------------------------------------------------------
// STOCH state calculated inside each requested timeframe
// -----------------------------------------------------------------------------
f_k() =>
    float raw = ta.stoch(close, high, low, kLength)
    ta.sma(raw, kSmooth)

// Each requested timeframe returns only what is read. The previous version also returned a
// %D line from all twelve request.security calls and never used any of them, which made the
// "%D smoothing" input inert: swept from 1 to 30 across 420,775 bar comparisons on BTCUSDT
// and ETHUSDT it changed no plotted series by any amount at all and left the pulse count
// identical. The input and the twelve unread series are gone.
f_state() =>
    float k = f_k()
    [k, k - k[1]]

f_stateConfirmed() =>
    float k = f_k()
    [k[1], k[1] - k[2]]

// Developing requests: no future leak, but open HTF values can change.
[k15Dev, v15Dev] = request.security(syminfo.tickerid, "15", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1hDev, v1hDev] = request.security(syminfo.tickerid, "60", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k4hDev, v4hDev] = request.security(syminfo.tickerid, "240", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1dDev, v1dDev] = request.security(syminfo.tickerid, "1D", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1wDev, v1wDev] = request.security(syminfo.tickerid, "1W", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1mDev, v1mDev] = request.security(syminfo.tickerid, "1M", f_state(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Confirmed requests use the previous completed bar in each requested context.
[k15Con, v15Con] = request.security(syminfo.tickerid, "15", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1hCon, v1hCon] = request.security(syminfo.tickerid, "60", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k4hCon, v4hCon] = request.security(syminfo.tickerid, "240", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1dCon, v1dCon] = request.security(syminfo.tickerid, "1D", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1wCon, v1wCon] = request.security(syminfo.tickerid, "1W", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1mCon, v1mCon] = request.security(syminfo.tickerid, "1M", f_stateConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

bool confirmedMode = dataMode == "Confirmed only"
float k15 = confirmedMode ? k15Con : k15Dev
float k1h = confirmedMode ? k1hCon : k1hDev
float k4h = confirmedMode ? k4hCon : k4hDev
float k1d = confirmedMode ? k1dCon : k1dDev
float k1w = confirmedMode ? k1wCon : k1wDev
float k1m = confirmedMode ? k1mCon : k1mDev
float v15 = confirmedMode ? v15Con : v15Dev
float v1h = confirmedMode ? v1hCon : v1hDev
float v4h = confirmedMode ? v4hCon : v4hDev
float v1d = confirmedMode ? v1dCon : v1dDev
float v1w = confirmedMode ? v1wCon : v1wDev
float v1m = confirmedMode ? v1mCon : v1mDev

// -----------------------------------------------------------------------------
// Normalized weights
// -----------------------------------------------------------------------------
float EPS = 1e-10
float wtSum = math.max(wt15Input + wt1hInput + wt4hInput + wt1dInput, EPS)
float wt15 = wt15Input / wtSum
float wt1h = wt1hInput / wtSum
float wt4h = wt4hInput / wtSum
float wt1d = wt1dInput / wtSum

float wsSum = math.max(ws1dInput + ws1wInput + ws1mInput, EPS)
float ws1d = ws1dInput / wsSum
float ws1w = ws1wInput / wsSum
float ws1m = ws1mInput / wsSum

// Unit phase vector. Position is the real axis; scaled STOCH velocity is the
// causal quadrature approximation. This is intentionally not called an exact
// Hilbert transform.
f_phaseReal(float k, float velocity) =>
    float x = (k - 50.0) / 50.0
    float q = velocityGain * velocity / 50.0
    float magnitude = math.sqrt(x * x + q * q)
    magnitude > EPS ? x / magnitude : 0.0

f_phaseImag(float k, float velocity) =>
    float x = (k - 50.0) / 50.0
    float q = velocityGain * velocity / 50.0
    float magnitude = math.sqrt(x * x + q * q)
    magnitude > EPS ? q / magnitude : 0.0

float r15 = f_phaseReal(k15, v15)
float r1h = f_phaseReal(k1h, v1h)
float r4h = f_phaseReal(k4h, v4h)
float r1d = f_phaseReal(k1d, v1d)
float r1w = f_phaseReal(k1w, v1w)
float r1m = f_phaseReal(k1m, v1m)
float q15 = f_phaseImag(k15, v15)
float q1h = f_phaseImag(k1h, v1h)
float q4h = f_phaseImag(k4h, v4h)
float q1d = f_phaseImag(k1d, v1d)
float q1w = f_phaseImag(k1w, v1w)
float q1m = f_phaseImag(k1m, v1m)

float tacticalRaw = wt15 * k15 + wt1h * k1h + wt4h * k4h + wt1d * k1d
float structuralRaw = ws1d * k1d + ws1w * k1w + ws1m * k1m

float tacticalReal = wt15 * r15 + wt1h * r1h + wt4h * r4h + wt1d * r1d
float tacticalImag = wt15 * q15 + wt1h * q1h + wt4h * q4h + wt1d * q1d
float structuralReal = ws1d * r1d + ws1w * r1w + ws1m * r1m
float structuralImag = ws1d * q1d + ws1w * q1w + ws1m * q1m

float tacticalCoherence = 100.0 * math.min(1.0, math.sqrt(tacticalReal * tacticalReal + tacticalImag * tacticalImag))
float tacticalPhaseWave = 50.0 + 50.0 * tacticalReal
float structuralPhaseWave = 50.0 + 50.0 * structuralReal

float tacticalWave = waveMode == "Weighted STOCH" ? tacticalRaw : tacticalPhaseWave
float structuralWave = waveMode == "Weighted STOCH" ? structuralRaw : structuralPhaseWave
float tacticalVelocity = tacticalWave - tacticalWave[1]
float structuralVelocity = structuralWave - structuralWave[1]

// -----------------------------------------------------------------------------
// GC/DC Pulse: symbol-specific life, exponential decay, causal MAE,
// Type A / B / A->B classification, TAIL risk warning.
//
// "Causal" means the entry bar's own high/low never contributes to that
// pulse's MAE -- tracking starts strictly on the NEXT bar after the
// cross, matching how the original backtest computed forward returns
// (close[i] as entry, high/low over [i+1, i+horizon] only).
// -----------------------------------------------------------------------------
string tickerUpper = str.upper(syminfo.tickerid)
bool isBTCSymbol = str.contains(tickerUpper, "BTC")
bool isETHSymbol = not isBTCSymbol and str.contains(tickerUpper, "ETH")
float pulseLifeMinutes = isBTCSymbol ? pulseLifeBTCInput : isETHSymbol ? pulseLifeETHInput : pulseLifeDefaultInput
float chartMinutesPerBar = timeframe.in_seconds() / 60.0
int pulseLifeBars = math.max(1, int(math.round(pulseLifeMinutes / math.max(chartMinutesPerBar, EPS))))

bool goldenCross = ta.crossover(tacticalWave, structuralWave)
bool deadCross = ta.crossunder(tacticalWave, structuralWave)

// --- Long pulse (GC) ---
var int longBarsLeft = 0
var int longLifeBars = 1
var float longEntryPrice = na
var float longMAE = 0.0
var string longType = na
var bool longUpgraded = false
bool justStartedLong = false

if goldenCross and longBarsLeft <= 0
    longLifeBars := pulseLifeBars
    longBarsLeft := pulseLifeBars
    longEntryPrice := close
    longMAE := 0.0
    longType := structuralWave < 50.0 ? "A" : "B"
    longUpgraded := false
    justStartedLong := true

if longBarsLeft > 0 and not justStartedLong
    longMAE := math.max(longMAE, (longEntryPrice - low) / longEntryPrice * 100.0)
    if longType == "A" and structuralWave >= 50.0
        longType := "B"
        longUpgraded := true
    longBarsLeft := longBarsLeft - 1

float longElapsed = longLifeBars - longBarsLeft
float longTau = math.max(longLifeBars * decayFractionInput, 0.1)
float longIntensity = longBarsLeft > 0 ? math.exp(-longElapsed / longTau) : 0.0
bool longActive = longBarsLeft > 0
bool longCaution = longActive and longMAE >= cautionMaeInput and longMAE < tailMaeInput
bool longTail = longActive and longMAE >= tailMaeInput

// --- Short pulse (DC) ---
var int shortBarsLeft = 0
var int shortLifeBars = 1
var float shortEntryPrice = na
var float shortMAE = 0.0
var string shortType = na
var bool shortUpgraded = false
bool justStartedShort = false

if deadCross and shortBarsLeft <= 0
    shortLifeBars := pulseLifeBars
    shortBarsLeft := pulseLifeBars
    shortEntryPrice := close
    shortMAE := 0.0
    shortType := structuralWave > 50.0 ? "A" : "B"
    shortUpgraded := false
    justStartedShort := true

if shortBarsLeft > 0 and not justStartedShort
    shortMAE := math.max(shortMAE, (high - shortEntryPrice) / shortEntryPrice * 100.0)
    if shortType == "A" and structuralWave <= 50.0
        shortType := "B"
        shortUpgraded := true
    shortBarsLeft := shortBarsLeft - 1

float shortElapsed = shortLifeBars - shortBarsLeft
float shortTau = math.max(shortLifeBars * decayFractionInput, 0.1)
float shortIntensity = shortBarsLeft > 0 ? math.exp(-shortElapsed / shortTau) : 0.0
bool shortActive = shortBarsLeft > 0
bool shortCaution = shortActive and shortMAE >= cautionMaeInput and shortMAE < tailMaeInput
bool shortTail = shortActive and shortMAE >= tailMaeInput

// -----------------------------------------------------------------------------
// Visuals
// -----------------------------------------------------------------------------
hline(80.0, "Overbought", color = color.new(color.red, 35), linestyle = hline.style_dashed)
hline(50.0, "Equilibrium", color = color.new(color.gray, 65), linestyle = hline.style_dotted)
hline(20.0, "Oversold", color = color.new(color.lime, 35), linestyle = hline.style_dashed)

plot(showCoherence ? tacticalCoherence : na, "Tactical phase coherence", color = color.new(coherenceColor, 84), style = plot.style_area, linewidth = 1)
plot(tacticalWave, "Tactical wave", color = tacticalColor, linewidth = 3)
plot(structuralWave, "Structural wave", color = structuralColor, linewidth = 4)

// Pulse intensity overlay on the oscillator pane: fades out via transparency
// as the pulse decays, disappears once the pulse expires.
plot(longActive ? tacticalWave : na, "Long pulse intensity", color = longTail ? color.fuchsia : longCaution ? color.orange : color.new(color.lime, int(100 * (1 - longIntensity))), style = plot.style_circles, linewidth = 3)
plot(shortActive ? tacticalWave : na, "Short pulse intensity", color = shortTail ? color.fuchsia : shortCaution ? color.orange : color.new(color.red, int(100 * (1 - shortIntensity))), style = plot.style_circles, linewidth = 3)

plot(showRawSensors ? k15 : na, "15m sensor", color = color.new(color.aqua, 25), linewidth = 1)
plot(showRawSensors ? k1h : na, "1H sensor", color = color.new(color.blue, 20), linewidth = 1)
plot(showRawSensors ? k4h : na, "4H sensor", color = color.new(color.orange, 15), linewidth = 2)
plot(showRawSensors ? k1d : na, "1D sensor", color = color.new(color.yellow, 20), linewidth = 2)
plot(showRawSensors ? k1w : na, "1W sensor", color = color.new(color.fuchsia, 25), linewidth = 2)
plot(showRawSensors ? k1m : na, "1M sensor", color = color.new(color.purple, 15), linewidth = 3)

bool synchronizedBull = tacticalWave > 50 and structuralWave > 50 and tacticalVelocity > 0 and structuralVelocity >= 0 and tacticalCoherence >= minCoherence
bool synchronizedBear = tacticalWave < 50 and structuralWave < 50 and tacticalVelocity < 0 and structuralVelocity <= 0 and tacticalCoherence >= minCoherence
bgcolor(synchronizedBull ? color.new(color.lime, 91) : synchronizedBear ? color.new(color.red, 91) : na, title = "Synchronized regime")

bool tacticalBullTurn = ta.crossover(tacticalWave, 20.0) and structuralWave >= 50.0 and tacticalCoherence >= minCoherence
bool tacticalBearTurn = ta.crossunder(tacticalWave, 80.0) and structuralWave <= 50.0 and tacticalCoherence >= minCoherence
plotshape(tacticalBullTurn, "Bullish tactical turn", shape.triangleup, location.bottom, color = color.lime, size = size.tiny, text = "T+")
plotshape(tacticalBearTurn, "Bearish tactical turn", shape.triangledown, location.top, color = color.red, size = size.tiny, text = "T-")

// --- GC/DC/TAIL forced onto the price chart. Labels say "GC"/"DC"/"TAIL",
// never "BUY"/"SELL": the backtest found a short-lived pulse with real tail
// risk, not a directional forecast. ---
// plotshape's text argument requires a const string; it cannot take "GC " +
// longType (a series string, since longType changes at runtime). label.new
// accepts series string text, so the two dynamic labels use it instead.
if showPulseOnChart and justStartedLong
    label.new(bar_index, low, "GC " + longType, style = label.style_label_up,
         color = color.new(color.lime, 0), textcolor = color.black, size = size.tiny, force_overlay = true)

if showPulseOnChart and justStartedShort
    label.new(bar_index, high, "DC " + shortType, style = label.style_label_down,
         color = color.new(color.red, 0), textcolor = color.white, size = size.tiny, force_overlay = true)

// The Type A -> B upgrade markers are gone. The upgrade needs the structural wave to cross
// 50 while a pulse is still alive, but the structural wave is built from 1D/1W/1M legs and a
// pulse lives 8 bars on BTC or 4 on ETH - its median change over an entire pulse life is
// EXACTLY 0.000 on both symbols. Measured: 0 upgrades in 1,070 BTCUSDT pulses (546 of which
// started as Type A) and 1 in 1,518 ETHUSDT pulses. The Type letter on the GC/DC label is
// reachable and stays; the upgrade markers and their two alerts were unreachable and do not.
plotshape(showPulseOnChart and longTail and not longTail[1], "Long TAIL warning (chart)", shape.xcross, location.belowbar,
     color = color.fuchsia, size = size.small, text = "TAIL", force_overlay = true)
plotshape(showPulseOnChart and shortTail and not shortTail[1], "Short TAIL warning (chart)", shape.xcross, location.abovebar,
     color = color.fuchsia, size = size.small, text = "TAIL", force_overlay = true)

alertcondition(tacticalBullTurn, "MTF tactical bullish turn", "Tactical MTF wave turned up from oversold while the structural wave and phase coherence passed their filters.")
alertcondition(tacticalBearTurn, "MTF tactical bearish turn", "Tactical MTF wave turned down from overbought while the structural wave and phase coherence passed their filters.")
alertcondition(synchronizedBull and not synchronizedBull[1], "MTF bullish synchronization", "Tactical and structural MTF waves entered bullish synchronization.")
alertcondition(synchronizedBear and not synchronizedBear[1], "MTF bearish synchronization", "Tactical and structural MTF waves entered bearish synchronization.")

alertcondition(showPulseAlerts and justStartedLong, "GC Pulse started", "Tactical wave crossed above structural wave. This is not a buy signal and not a forecast: re-running the screen behind it, no test of this crossing separates from a circular-shift null, and 88% of the associated move is already complete when the cross prints.")
alertcondition(showPulseAlerts and justStartedShort, "DC Pulse started", "Tactical wave crossed below structural wave. This is not a sell signal and not a forecast: re-running the screen behind it, no test of this crossing separates from a circular-shift null, and 95% of the associated move is already complete when the cross prints.")
alertcondition(showPulseAlerts and longTail and not longTail[1], "Long pulse TAIL warning", "Active long pulse's MAE crossed the TAIL threshold -- matches the BTCUSDT holdout failure mode where win rate held but the losing side's drawdown grew past 1.5%. Treat as elevated downside tail risk, not a reason to add to the position.")
alertcondition(showPulseAlerts and shortTail and not shortTail[1], "Short pulse TAIL warning", "Active short pulse's MAE crossed the TAIL threshold -- elevated adverse-excursion risk on the short side.")
````
