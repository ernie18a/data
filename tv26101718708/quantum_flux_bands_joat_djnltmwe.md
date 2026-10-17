# Quantum Flux Bands [JOAT]

- url: https://www.tradingview.com/script/djnltMWe-Quantum-Flux-Bands-JOAT/
- type: indicator
- pine_id: PUB;1b108b57212e4f77a627c789f79e7c60
- version: 1.0

## Description

[b]Quantum Flux Bands [JOAT][/b]

Quantum Flux Bands is an institutional-style regime detector. It stationarizes the price series via Fixed-Window Fractional Differentiation (FFD), runs a classical CUSUM change-point test on the stationarized stream, and draws a baseline that snaps to a new price level on every confirmed regime shift. Around the baseline, three percentile envelopes (50%, 68%, 90%) are drawn and modulated by a windowed Shannon entropy estimator so the bands narrow in low-noise regimes and widen in high-noise regimes.

[image]https://www.tradingview.com/x/tDusH2Hr/[/image]

[b]What makes it different[/b]
[list]
[*] Most regime filters hard-code a differentiation order (typically the first difference). FFD takes a real-valued differentiation order [i]d[/i] between 0 and 1, retaining long-memory while making the series statistically stationary. This script chooses [i]d[/i] adaptively from a rolling Hurst estimate so it responds to the market's persistence regime instead of being a fixed magic number.
[*] The CUSUM trigger is fed by FFD-stationarized values, not raw returns. This reduces baseline whipsaws in trending markets that violate stationarity assumptions of classical CUSUM.
[*] The bands are entropy-weighted. When the local windowed Shannon entropy is high (low signal-to-noise) the bands expand. When entropy is low (clean regime) they contract. The bands lock at the moment of a confirmed regime shift so they describe the regime under which the baseline was established.
[/list]

[b]How it works[/b]
[list=1]
[*] A two-point Hurst estimator (rescaled-range over short and long windows) drives an adaptive differentiation order [i]d[/i] in the range 0.30 to 0.90.
[*] FFD weights are recomputed only when [i]d[/i] drifts by more than 0.05 from its cached value. Caching keeps per-bar work near zero.
[*] FFD weights are applied to a sliding window of close prices to produce a stationarized series.
[*] Classical CUSUM tracks cumulative positive and negative deviations of the stationarized series from a running baseline reference, with user-configurable drift and threshold parameters.
[*] When CUSUM exceeds the threshold, the baseline snaps to the current close and the trend state is set to bull or bear.
[*] Inner, mid, and outer envelopes are drawn from percentile_linear_interpolation of the absolute distance between close and baseline, multiplied by an entropy modulator.
[*] A bull probability is computed from the Abramowitz and Stegun standard-normal CDF on the signed band-distance and surfaced as a numeric label.
[/list]

[b]Reading the chart[/b]
[list]
[*] Baseline line tinted purple in bull regimes, cyan in bear regimes, muted in neutral.
[*] Six percentile band lines (upper and lower inner, mid, outer) with three pairs of atmospheric gradient fills calibrated so candles remain readable through every layer.
[*] Optional iridescent candle recolor scales tint by signed regime score.
[*] A probability label at the right edge of the chart shows the live bull probability.
[*] Seven right-edge price labels, one per envelope level plus baseline, each sit at their own price.
[*] Regime-shift timeline labels record every confirmed regime change with its baseline price and bull probability at the time of the shift.
[*] A 21-segment vertical strength gauge at the right edge maps the continuous regime strength score onto a bull / bear / neutral scale, with a dashed sight-line drawing the gauge level back into the chart.
[*] A short forward probability cone: two dashed segments at outer band levels with opacity scaled by class probability.
[/list]

[b]Signals[/b]
[list]
[*] Bull / bear regime entry (CUSUM trigger with direction)
[*] Outer band touch
[*] Outer band rejection (wick pierces the outer band but the body closes back inside)
[*] Baseline reclaim (close re-crosses the baseline)
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references. No lookahead_on.

[b]Inputs[/b]
[list]
[*] [b]Fractional Differentiation[/b]: FFD window length.
[*] [b]CUSUM[/b]: volatility period, drift parameter, threshold parameter.
[*] [b]Regime[/b]: Hurst short / long lookbacks, entropy window / bins / z-score length.
[*] [b]Bands[/b]: percentile lookback.
[*] [b]Visual[/b]: bullish, bearish, quantum purple, quantum cyan colors. Band visibility toggles. Iridescent candles. Regime pulse. Probability label.
[*] [b]Labels[/b]: right-edge level labels, regime timeline (offset off candle wicks by ATR), baseline reclaim markers (direction-sensitive Y offset, configurable minimum-bar spacing), band touch and rejection labels (configurable minimum-bar spacing per type), strength gauge, sight-line needle, probability cone, FFD memory label, entropy state strip.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Mean-reversion fades[/b] from outer-band touches inside a stable regime (Hurst mean-reverting, low entropy z) are statistically supported setups.
[*] [b]Regime-shift entries[/b]: when the baseline snaps and the trend turns, the first inner-band retest is a higher-quality continuation entry than chasing the breakout bar.
[*] [b]Probability filter[/b]: use the bull probability label as a confidence multiplier for other systems. Below 30% or above 70% are the actionable zones.
[*] [b]Entropy context[/b]: high entropy z (band-multiplier expanded) is a low conviction, wider stops warning. Low entropy z (bands tight) is a high conviction, tighter stops green light.
[/list]

[b]Limitations[/b]
[list]
[*] Fractional differentiation is a smoothing and filtering tool. It cannot create information that is not already in the price series.
[*] CUSUM, like any change-point detector, lags real-time tops and bottoms. It is calibrated to balance whipsaw against responsiveness.
[*] The two-point Hurst estimator is a fast approximation. For long-horizon classification it agrees with the full R/S statistic. For very short windows it is noisier.
[*] Past regime persistence does not guarantee future regime persistence.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator. Any symbol, any timeframe (longer timeframes give the FFD window more meaningful history). No external request.security calls. Non-repainting: regime shifts are committed on confirmed bars and baseline values are not retroactively rewritten.

[b]Defaults[/b]
Mint and red bullish / bearish defaults. Purple and cyan quantum accents. Top-right medium dashboard. All on-chart visualizations on. Increase the FFD window for very high timeframes (daily and above) and decrease the percentile lookback for fast intraday charts.

[b]Credits[/b]
[list]
[*] Fractional differentiation methodology popularized by López de Prado, [i]Advances in Financial Machine Learning[/i] (2018).
[*] CUSUM change-point test as published by E. S. Page, [i]Biometrika[/i] (1954).
[*] Standard-normal CDF approximation per Abramowitz and Stegun (1964).
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
// JOAT — Quantum Flux Bands [JOAT]
indicator("Quantum Flux Bands [JOAT]", "QFB [JOAT]", overlay=true, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, behind_chart=false)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_ffd     = "Fractional Diff"
g_cusum   = "CUSUM"
g_regime  = "Regime"
g_bands   = "Bands"
g_visual  = "Visual"
g_dash    = "Dashboard"

ffdLen          = input.int(30,   "FFD Window Length",        minval=5, maxval=200,                  group=g_ffd,    tooltip="Number of historical bars accumulated for the fractional differentiation memory.")

cusumPeriod     = input.int(20,   "CUSUM Volatility Period",  minval=2,                              group=g_cusum,  tooltip="Lookback for the rolling stdev that normalizes CUSUM deviations.")
cusumDrift      = input.float(0.5,"CUSUM Drift (k)",          minval=0.0, maxval=5.0, step=0.1,      group=g_cusum,  tooltip="Drift parameter k to filter out noise.")
cusumThreshold  = input.float(5.0,"CUSUM Threshold (h)",      minval=0.1, maxval=10.0, step=0.1,     group=g_cusum,  tooltip="Threshold h in stdevs. Baseline snaps when crossed.")

hurstShort      = input.int(8,    "Hurst Short Lookback",     minval=4,                              group=g_regime, tooltip="Short window for the two-point R/S Hurst estimator.")
hurstLong       = input.int(32,   "Hurst Long Lookback",      minval=8,                              group=g_regime, tooltip="Long window for the two-point R/S Hurst estimator.")
entropyWindow   = input.int(50,   "Entropy Window",           minval=10,                             group=g_regime, tooltip="Bar window for Shannon entropy estimation.")
entropyBins     = input.int(10,   "Entropy Bins",             minval=4, maxval=32,                   group=g_regime, tooltip="Histogram bins used to approximate the return distribution.")
entropyZLen     = input.int(50,   "Entropy Z Length",         minval=10,                             group=g_regime, tooltip="Lookback used to z-score raw entropy.")

pctLookback     = input.int(100,  "Percentile Lookback",      minval=20, maxval=500,                 group=g_bands,  tooltip="Lookback window for percentile envelopes.")

bullColor       = input.color(#00ffbb, "Bullish",           inline="cBull",                          group=g_visual, tooltip="Primary bullish color.")
bearColor       = input.color(#ff1100, "Bearish",           inline="cBull",                          group=g_visual, tooltip="Primary bearish color.")
quantumBull     = input.color(#bb00ff, "Quantum Bull Accent",inline="cQ",                            group=g_visual, tooltip="Purple accent applied to the baseline during a bullish regime.")
quantumBear     = input.color(#00bbff, "Quantum Bear Accent",inline="cQ",                            group=g_visual, tooltip="Cyan accent applied to the baseline during a bearish regime.")
showInner       = input.bool(true,  "Show Inner Band",                                                group=g_visual, tooltip="Toggle the inner p50 pair.")
showMid         = input.bool(true,  "Show Mid Band",                                                  group=g_visual, tooltip="Toggle the mid p68 pair.")
showOuter       = input.bool(true,  "Show Outer Band",                                                group=g_visual, tooltip="Toggle the outer p90 pair.")
showCandles     = input.bool(true,  "Iridescent Candles",                                             group=g_visual, tooltip="Recolor chart candles by signed distance from the baseline.")
showPulse       = input.bool(true,  "Show Regime Pulse",                                              group=g_visual, tooltip="Toggle the background pulse on baseline snap.")
showProbLabel   = input.bool(true,  "Show Probability Label",                                         group=g_visual, tooltip="Toggle the right-edge P(bull) label.")

g_levels = "Level Labels & Events"
g_gauge  = "Strength Gauge & Cone"
g_memory = "FFD Memory & Entropy"

showLevelLabels    = input.bool(true,  "Right-Edge Level Labels",  group=g_levels, tooltip="Persistent labels at the right edge for all 7 band levels with percentile annotations.")
showRegimeTimeline = input.bool(true,  "Regime-Shift Timeline",    group=g_levels, tooltip="Drops a persistent label at every CUSUM baseline-snap. FIFO-capped at 15.")
showReclaimLabels  = input.bool(true,  "Baseline Reclaim Labels",  group=g_levels, tooltip="Subtle markers when close crosses the baseline. FIFO-capped at 20.")
showBandEvents     = input.bool(true,  "Outer Band Touch/Reject",  group=g_levels, tooltip="Persistent labels for outer-band touches and rejections. FIFO-capped with minimum-bar spacing per type to prevent overlap during rapid repeated touches.")
bandEventGap       = input.int(20,     "Band Event Min Spacing (bars)", minval=1, maxval=500, group=g_levels, tooltip="Minimum bars between successive band events of the same type and direction. Prevents stacked labels during fast pullbacks where price wicks the outer band on consecutive bars.")
reclaimGap         = input.int(20,     "Baseline Reclaim Min Spacing (bars)", minval=1, maxval=500, group=g_levels, tooltip="Minimum bars between successive baseline-reclaim labels. Prevents stacking along the baseline horizontal line during sideways chop.")

showStrengthGauge  = input.bool(true,  "Right-Edge Strength Gauge", group=g_gauge,  tooltip="Vertical 21-segment color band on the right edge.")
showProbCone       = input.bool(true,  "Forward Probability Cone",  group=g_gauge,  tooltip="Two short horizontal segments forward of the bar.")
showSightNeedle    = input.bool(true,  "Strength Sight-Line",       group=g_gauge,  tooltip="Dashed sight-line needle from the strength gauge.")

showFFDMemory      = input.bool(true,  "FFD Memory Label",          group=g_memory, tooltip="Compact label showing FFD value and adaptive d.")
showEntropyStrip   = input.bool(true,  "Entropy State Strip",       group=g_memory, tooltip="Compact cluster showing entropy z and band multiplier.")

showDash        = input.bool(true,  "Show Dashboard",                                                 group=g_dash,   tooltip="Toggle the institutional dashboard panel.")
dashPos         = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize        = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════

posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

// Abramowitz & Stegun normal CDF approximation
norm_cdf(float z) =>
    float t    = 1.0 / (1.0 + 0.2316419 * math.abs(z))
    float d_   = 0.3989423 * math.exp(-0.5 * z * z)
    float poly = t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))))
    float p    = d_ * poly
    z >= 0 ? 1.0 - p : p

// Two-point R/S statistic
f_rs(int n) =>
    r          = math.log(close / nz(close[1], close))
    mean_r     = ta.sma(r, n)
    dev        = r - mean_r
    cum        = ta.cum(dev)
    cumHigh    = ta.highest(cum, n)
    cumLow     = ta.lowest(cum, n)
    rangeCum   = cumHigh - cumLow
    s_         = ta.stdev(r, n)
    s_ > 0 ? rangeCum / math.max(s_, 1e-8) : na

f_hurst(int nShort, int nLong) =>
    rsShort = f_rs(nShort)
    rsLong  = f_rs(nLong)
    float hRaw = na
    if not na(rsShort) and not na(rsLong) and rsShort > 0 and rsLong > 0
        hRaw := math.log(rsLong / math.max(rsShort, 1e-8)) / math.log(nLong / nShort)
    na(hRaw) ? 0.5 : math.max(0.3, math.min(0.7, hRaw))

f_ffd_apply(float src, float[] weights, int length) =>
    float v = 0.0
    for i = 0 to length - 1
        v := v + array.get(weights, i) * nz(src[i], src)
    v

// Shannon entropy on log returns
f_shannon_entropy(int window, int bins) =>
    rLog = math.log(close / nz(close[1], close))
    rMin = ta.lowest(rLog, window)
    rMax = ta.highest(rLog, window)
    float rangeR = rMax - rMin
    float H = na
    if rangeR > 0 and bar_index >= window
        binWidth = rangeR / bins
        int[] counts = array.new<int>(bins, 0)
        for i = 0 to window - 1
            float val = nz(rLog[i], rMin)
            int idx = math.floor((val - rMin) / math.max(binWidth, 1e-12))
            if idx < 0
                idx := 0
            if idx >= bins
                idx := bins - 1
            array.set(counts, idx, array.get(counts, idx) + 1)
        float hSum = 0.0
        float wF = window + 0.0
        for b = 0 to bins - 1
            float p_ = array.get(counts, b) / wF
            if p_ > 0.0
                hSum := hSum - p_ * math.log(p_)
        H := hSum
    H

// ════════════════════════════════════════════════════════════════════
// FFD WEIGHTS — adaptive recompute on |d_adapt - d_cached| > 0.05
// ════════════════════════════════════════════════════════════════════

// Hurst proxy & adaptive d
hurst   = f_hurst(hurstShort, hurstLong)
d_adapt = math.max(0.30, math.min(0.90, 0.30 + 0.50 * hurst))

// FFD weight cache
var float[] ffd_weights     = na
var float   ffd_weights_sum = 0.0
var float   d_cached        = na

if na(ffd_weights) or na(d_cached) or math.abs(d_adapt - d_cached) > 0.05
    ffd_weights := array.new<float>(ffdLen)
    array.set(ffd_weights, 0, 1.0)
    ffd_weights_sum := 1.0
    for k = 1 to ffdLen - 1
        w_prev = array.get(ffd_weights, k - 1)
        coeff  = -w_prev * (d_adapt - k + 1) / k
        array.set(ffd_weights, k, coeff)
        ffd_weights_sum := ffd_weights_sum + coeff
    d_cached := d_adapt

// ════════════════════════════════════════════════════════════════════
// FFD + CUSUM CORE
// ════════════════════════════════════════════════════════════════════

f_calc_ffd_cusum() =>
    ffd_val = f_ffd_apply(close, ffd_weights, ffdLen)
    vol     = ta.stdev(ffd_val - ffd_val[1], cusumPeriod)
    volAdj  = na(vol) or vol == 0.0 ? 1e-8 : vol

    var float s_pos    = 0.0
    var float s_neg    = 0.0
    var float baseline = na
    var int   trend    = 0
    bool      triggered = false

    if na(baseline)
        baseline  := close
        triggered := true

    baseline_ffd = baseline * ffd_weights_sum
    dev_up   = ffd_val - baseline_ffd
    dev_down = baseline_ffd - ffd_val
    z_up     = dev_up   / volAdj
    z_down   = dev_down / volAdj

    if not na(vol)
        s_pos := math.max(0.0, nz(s_pos[1]) + z_up   - cusumDrift)
        s_neg := math.max(0.0, nz(s_neg[1]) + z_down - cusumDrift)
        if s_pos > cusumThreshold
            baseline  := close
            s_pos     := 0.0
            s_neg     := 0.0
            triggered := true
            trend     := 1
        else if s_neg > cusumThreshold
            baseline  := close
            s_pos     := 0.0
            s_neg     := 0.0
            triggered := true
            trend     := -1

    [baseline, triggered, trend, ffd_val]

// ════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ════════════════════════════════════════════════════════════════════

[baseline, triggered, trend, ffd_val] = f_calc_ffd_cusum()

// Shannon entropy + z-score
entropy_h     = f_shannon_entropy(entropyWindow, entropyBins)
entropy_mean  = ta.sma(entropy_h, entropyZLen)
entropy_std   = ta.stdev(entropy_h, entropyZLen)
entropy_z     = na(entropy_h) or na(entropy_mean) ? 0.0 : (entropy_h - entropy_mean) / math.max(entropy_std, 1e-8)

// Distance & percentile envelopes
dist_abs  = math.abs(close - baseline)
inner_raw = ta.percentile_linear_interpolation(dist_abs, pctLookback, 50)
mid_raw   = ta.percentile_linear_interpolation(dist_abs, pctLookback, 68)
outer_raw = ta.percentile_linear_interpolation(dist_abs, pctLookback, 90)

// Entropy modulation
entropy_mult = math.max(0.5, math.min(2.0, 1.0 + 0.3 * entropy_z))

// Lock active band widths on baseline snap
var float active_inner = na
var float active_mid   = na
var float active_outer = na

if triggered or na(active_inner)
    active_inner := inner_raw * entropy_mult
    active_mid   := mid_raw   * entropy_mult
    active_outer := outer_raw * entropy_mult

upper_inner = baseline + active_inner
lower_inner = baseline - active_inner
upper_mid   = baseline + active_mid
lower_mid   = baseline - active_mid
upper_outer = baseline + active_outer
lower_outer = baseline - active_outer

// ATR at top scope (used by probability label, regime label, reclaim label, etc. for vertical offset)
float qfbAtr14 = ta.atr(14)

// Regime-shift pulse decay counter
var int regime_pulse = 0
regime_pulse := math.max(0, regime_pulse - 1)
if triggered
    regime_pulse := 3

// Bars since last snap
var int barsSinceTrigger = 0
barsSinceTrigger := triggered ? 0 : barsSinceTrigger + 1

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE
// ════════════════════════════════════════════════════════════════════
confirmedBar = barstate.isconfirmed or barstate.ishistory

bullRegime = trend ==  1
bearRegime = trend == -1

// Regime strength score in [-1, 1]
sgnDistRaw     = (close - baseline) / math.max(active_outer, syminfo.mintick)
sgnDist        = math.max(-1.5, math.min(1.5, sgnDistRaw))
hurstConv      = (hurst - 0.5) * 2.0
entropyConv    = math.max(-1.0, math.min(1.0, entropy_z * 0.5))
regimeStrength = math.max(-1.0, math.min(1.0, 0.55 * sgnDist + 0.30 * hurstConv + 0.15 * entropyConv))

longShift     = bullRegime and not bullRegime[1] and confirmedBar
shortShift    = bearRegime and not bearRegime[1] and confirmedBar
outerTouch    = (high >= upper_outer or low <= lower_outer) and confirmedBar
meanReclaim   = (ta.crossunder(close, baseline) or ta.crossover(close, baseline)) and confirmedBar
// Outer band rejection
outerRejUp    = high >= upper_outer and close < upper_outer and open < upper_outer and confirmedBar
outerRejDn    = low  <= lower_outer and close > lower_outer and open > lower_outer and confirmedBar
outerReject   = outerRejUp or outerRejDn

// ════════════════════════════════════════════════════════════════════
// VISUALS
// ════════════════════════════════════════════════════════════════════

// Baseline + band state colors
baseColor  = bullRegime ? quantumBull : bearRegime ? quantumBear : color.new(chart.fg_color, 60)
stateColor = bullRegime ? bullColor   : bearRegime ? bearColor   : color.new(chart.fg_color, 60)

baseline_plot = plot(baseline, "Baseline", color=baseColor, linewidth=2)

// Percentile band lines
upper_inner_plot = plot(showInner ? upper_inner : na, "Upper Inner", color=color.new(stateColor, 70), linewidth=1)
lower_inner_plot = plot(showInner ? lower_inner : na, "Lower Inner", color=color.new(stateColor, 70), linewidth=1)
upper_mid_plot   = plot(showMid   ? upper_mid   : na, "Upper Mid",   color=color.new(stateColor, 80), linewidth=1)
lower_mid_plot   = plot(showMid   ? lower_mid   : na, "Lower Mid",   color=color.new(stateColor, 80), linewidth=1)
upper_outer_plot = plot(showOuter ? upper_outer : na, "Upper Outer", color=color.new(stateColor, 88), linewidth=1)
lower_outer_plot = plot(showOuter ? lower_outer : na, "Lower Outer", color=color.new(stateColor, 88), linewidth=1)

// Band fills
fill(upper_inner_plot, baseline_plot, color = color.new(stateColor, 86), title = "Inner Upper Fill")
fill(baseline_plot, lower_inner_plot, color = color.new(stateColor, 86), title = "Inner Lower Fill")
fill(upper_mid_plot,   upper_inner_plot, color = color.new(stateColor, 91), title = "Mid Upper Fill")
fill(lower_inner_plot, lower_mid_plot,   color = color.new(stateColor, 91), title = "Mid Lower Fill")
fill(upper_outer_plot, upper_mid_plot,   color = color.new(stateColor, 94), title = "Outer Upper Fill")
fill(lower_mid_plot,   lower_outer_plot, color = color.new(stateColor, 94), title = "Outer Lower Fill")

// Iridescent candle recolor
candleStateColor = sgnDist >= 0 ? bullColor : bearColor
candleColor      = color.from_gradient(math.abs(sgnDist), 0.0, 1.5, chart.bg_color, candleStateColor)
plotcandle(open, high, low, close, "Quantum Candles",
     color         = showCandles ? candleColor : na,
     wickcolor     = showCandles ? candleColor : na,
     bordercolor   = showCandles ? candleColor : na,
     force_overlay = true)

// Regime-shift pulse background
pulseColor = regime_pulse > 0 and showPulse ? color.new(stateColor, 82 + (3 - regime_pulse) * 4) : na
bgcolor(pulseColor, title="Quantum Pulse")

// Probability label
var label probLabel = na
if barstate.islast and showProbLabel
    if not na(probLabel)
        label.delete(probLabel)
    z      = (close - baseline) / math.max(active_mid, syminfo.mintick)
    p_bull = norm_cdf(z)
    probLabel := label.new(x = bar_index, y = baseline + qfbAtr14 * 0.5, text = "P(bull) " + str.tostring(p_bull * 100, "#.#") + "%", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(stateColor, 75), textcolor = color.white, style = label.style_label_left, size = size.small)

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 11,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

f_regimeText(int t) =>
    t ==  1 ? "BULL" : t == -1 ? "BEAR" : "NEUTRAL"

f_regimeBg(int t) =>
    t ==  1 ? color.new(bullColor, 55) : t == -1 ? color.new(bearColor, 55) : color.new(chart.fg_color, 80)

f_hurstText(float h) =>
    h > 0.55 ? "TRENDING" : h < 0.45 ? "MEAN-REV" : "NEUTRAL"

f_hurstBg(float h) =>
    h > 0.55 ? color.new(bullColor, 60) : h < 0.45 ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_strengthBg(float s) =>
    sAbs    = math.abs(s)
    transp  = math.max(45, 75 - math.round(sAbs * 30))
    sAbs < 0.20 ? color.new(chart.fg_color, 80) : s > 0 ? color.new(bullColor, transp) : color.new(bearColor, transp)

f_strengthLabel(float s) =>
    math.abs(s) < 0.20 ? "NEUTRAL" : math.abs(s) > 0.60 ? (s > 0 ? "STRONG BULL" : "STRONG BEAR") : (s > 0 ? "BULL" : "BEAR")

outerPctRaw = active_outer > 0.0 ? math.abs(close - baseline) / active_outer * 100.0 : 0.0

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 11,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    txtSize = sizeFromString(dashSize)

    // Row 0 — Header
    table.cell(dash, 0, 0, "Quantum Flux Bands [JOAT]", text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 1, 0, "",                          text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    // Row 1 — Regime
    table.cell(dash, 0, 1, "Regime",            text_color=chart.fg_color, bgcolor=#1a1a26,           text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, f_regimeText(trend), text_color=color.white,    bgcolor=f_regimeBg(trend), text_size=txtSize, text_halign=text.align_right)

    // Row 2 — Regime Strength
    table.cell(dash, 0, 2, "Strength",                                                  text_color=chart.fg_color, bgcolor=#1a1a26,                    text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, f_strengthLabel(regimeStrength) + " " + str.tostring(regimeStrength, "0.00"), text_color=color.white, bgcolor=f_strengthBg(regimeStrength), text_size=txtSize, text_halign=text.align_right)

    // Row 3 — Hurst regime
    table.cell(dash, 0, 3, "Hurst",             text_color=chart.fg_color, bgcolor=#1a1a26,          text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, f_hurstText(hurst),  text_color=color.white,    bgcolor=f_hurstBg(hurst), text_size=txtSize, text_halign=text.align_right)

    // Row 4 — Adaptive d
    table.cell(dash, 0, 4, "Adaptive d",                  text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(d_adapt, "0.00"), text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    // Row 5 — FFD Weights Sum
    table.cell(dash, 0, 5, "FFD Sum",                              text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(ffd_weights_sum, "0.000"), text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    // Row 6 — Entropy Z
    table.cell(dash, 0, 6, "Entropy Z",                     text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(entropy_z, "0.00"), text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    // Row 7 — Baseline
    table.cell(dash, 0, 7, "Baseline",                             text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(baseline, format.mintick), text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    // Row 8 — Outer Band %
    table.cell(dash, 0, 8, "Outer Band%",                          text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(outerPctRaw, "#.#") + "%", text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    // Row 9 — Bars since snap
    table.cell(dash, 0, 9, "Bars Since",                   text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(barsSinceTrigger), text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    // Row 10 — Watermark
    table.cell(dash, 0, 10, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 1, 10, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 10, 1, 10)

// ════════════════════════════════════════════════════════════════════
// EXTENDED ON-CHART VISUALIZATION LAYER
// ════════════════════════════════════════════════════════════════════
prob_z      = (close - baseline) / math.max(active_mid, syminfo.mintick)
p_bull_now  = norm_cdf(prob_z)
p_bear_now  = 1.0 - p_bull_now

// Color tints for level label tiers
outerLabelCol = color.new(stateColor, 25)
midLabelCol   = color.new(stateColor, 45)
innerLabelCol = color.new(stateColor, 65)
baseLabelCol  = color.new(baseColor,  20)

// ────────────────────────────────────────────────────────────────────
// A. Right-edge persistent level labels
// ────────────────────────────────────────────────────────────────────
var label lblOuterUp   = na
var label lblMidUp     = na
var label lblInnerUp   = na
var label lblBaseline  = na
var label lblInnerDn   = na
var label lblMidDn     = na
var label lblOuterDn   = na

if barstate.islast and showLevelLabels and confirmedBar
    if not na(lblOuterUp)
        label.delete(lblOuterUp)
    if not na(lblMidUp)
        label.delete(lblMidUp)
    if not na(lblInnerUp)
        label.delete(lblInnerUp)
    if not na(lblBaseline)
        label.delete(lblBaseline)
    if not na(lblInnerDn)
        label.delete(lblInnerDn)
    if not na(lblMidDn)
        label.delete(lblMidDn)
    if not na(lblOuterDn)
        label.delete(lblOuterDn)

    lblOuterUp := label.new(
         x         = bar_index + 30,
         y         = upper_outer,
         text      = "Outer Up  " + str.tostring(upper_outer, format.mintick) + "   90%ile",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = outerLabelCol,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)
    lblMidUp := label.new(
         x         = bar_index + 30,
         y         = upper_mid,
         text      = "Mid Up   " + str.tostring(upper_mid, format.mintick) + "   68%ile",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = midLabelCol,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)
    lblInnerUp := label.new(
         x         = bar_index + 30,
         y         = upper_inner,
         text      = "Inner Up " + str.tostring(upper_inner, format.mintick) + "   50%ile",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = innerLabelCol,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)
    lblBaseline := label.new(
         x         = bar_index + 30,
         y         = baseline,
         text      = "Baseline " + str.tostring(baseline, format.mintick) + "    Phi " + str.tostring(p_bull_now, "0.00"),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = baseLabelCol,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)
    lblInnerDn := label.new(
         x         = bar_index + 30,
         y         = lower_inner,
         text      = "Inner Dn " + str.tostring(lower_inner, format.mintick),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = innerLabelCol,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)
    lblMidDn := label.new(
         x         = bar_index + 30,
         y         = lower_mid,
         text      = "Mid Dn   " + str.tostring(lower_mid, format.mintick),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = midLabelCol,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)
    lblOuterDn := label.new(
         x         = bar_index + 30,
         y         = lower_outer,
         text      = "Outer Dn " + str.tostring(lower_outer, format.mintick),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = outerLabelCol,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)

// ────────────────────────────────────────────────────────────────────
// B. Regime-shift timeline labels (FIFO 15)
// ────────────────────────────────────────────────────────────────────
var array<label> regimeLabels = array.new<label>()

if triggered and confirmedBar and showRegimeTimeline
    regimeName = trend ==  1 ? "bull" : trend == -1 ? "bear" : "flat"
    regimeBg   = trend ==  1 ? color.new(bullColor, 30) : trend == -1 ? color.new(bearColor, 30) : color.new(chart.fg_color, 50)
    regimeStyle = trend == -1 ? label.style_label_down : label.style_label_up
    regimeY    = trend == -1 ? high + qfbAtr14 * 0.75 : low - qfbAtr14 * 0.75
    rl = label.new(x = bar_index, y = regimeY, text = "REGIME " + regimeName + "  " + str.tostring(close, format.mintick) + "  Phi " + str.tostring(p_bull_now, "0.00"), xloc = xloc.bar_index, yloc = yloc.price, color = regimeBg, textcolor = color.white, style = regimeStyle, size = size.small)
    array.push(regimeLabels, rl)
    if array.size(regimeLabels) > 15
        rl_old = array.shift(regimeLabels)
        if not na(rl_old)
            label.delete(rl_old)

// ────────────────────────────────────────────────────────────────────
// C. Baseline reclaim event markers (FIFO 20)
// ────────────────────────────────────────────────────────────────────
var array<label> reclaimLabels = array.new<label>()

var int lastReclaimBar = na
// Distinguish direction so labels sit clear of the baseline line.
reclaimUp = ta.crossover(close, baseline) and confirmedBar
reclaimDn = ta.crossunder(close, baseline) and confirmedBar

if (reclaimUp or reclaimDn) and showReclaimLabels and (na(lastReclaimBar) or bar_index - lastReclaimBar >= reclaimGap)
    lastReclaimBar := bar_index
    float rclY     = reclaimUp ? baseline + qfbAtr14 * 0.4 : baseline - qfbAtr14 * 0.4
    string rclStyle = reclaimUp ? label.style_label_down : label.style_label_up
    rcl = label.new(x = bar_index, y = rclY, text = "Baseline reclaim  " + str.tostring(close, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(baseColor, 65), textcolor = color.new(color.white, 10), style = rclStyle, size = size.tiny)
    array.push(reclaimLabels, rcl)
    if array.size(reclaimLabels) > 8
        rcl_old = array.shift(reclaimLabels)
        if not na(rcl_old)
            label.delete(rcl_old)

// ────────────────────────────────────────────────────────────────────
// D. Outer-band touch / reject event labels (FIFO 25)
// ────────────────────────────────────────────────────────────────────
var array<label> bandEventLabels = array.new<label>()

f_push_band_event(label newLbl) =>
    array.push(bandEventLabels, newLbl)
    if array.size(bandEventLabels) > 25
        l_old = array.shift(bandEventLabels)
        if not na(l_old)
            label.delete(l_old)

var int lastTouchUpBar = na
var int lastTouchDnBar = na
var int lastRejUpBar   = na
var int lastRejDnBar   = na

if showBandEvents and confirmedBar
    touchUp = high >= upper_outer and not outerRejUp
    touchDn = low  <= lower_outer and not outerRejDn
    if touchUp and (na(lastTouchUpBar) or bar_index - lastTouchUpBar >= bandEventGap)
        lastTouchUpBar := bar_index
        tlu = label.new(x = bar_index, y = high, text = "Outer Up touch  " + str.tostring(high, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(stateColor, 78), textcolor = color.new(color.white, 20), style = label.style_label_down, size = size.tiny)
        f_push_band_event(tlu)
    if touchDn and (na(lastTouchDnBar) or bar_index - lastTouchDnBar >= bandEventGap)
        lastTouchDnBar := bar_index
        tld = label.new(x = bar_index, y = low, text = "Outer Dn touch  " + str.tostring(low, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(stateColor, 78), textcolor = color.new(color.white, 20), style = label.style_label_up, size = size.tiny)
        f_push_band_event(tld)
    if outerRejUp and (na(lastRejUpBar) or bar_index - lastRejUpBar >= bandEventGap)
        lastRejUpBar := bar_index
        rju = label.new(x = bar_index, y = high, text = "Outer Up reject  " + str.tostring(high, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(bearColor, 30), textcolor = color.white, style = label.style_label_down, size = size.small)
        f_push_band_event(rju)
    if outerRejDn and (na(lastRejDnBar) or bar_index - lastRejDnBar >= bandEventGap)
        lastRejDnBar := bar_index
        rjd = label.new(x = bar_index, y = low, text = "Outer Dn reject  " + str.tostring(low, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(bullColor, 30), textcolor = color.white, style = label.style_label_up, size = size.small)
        f_push_band_event(rjd)

// ────────────────────────────────────────────────────────────────────
// E. Right-edge regime strength gauge (21 vertical segments)
// ────────────────────────────────────────────────────────────────────
var array<line>  gaugeSegments  = array.new<line>()
var label        gaugePointerLb = na
var line         gaugePointerLn = na

if barstate.islast and showStrengthGauge and confirmedBar
    if array.size(gaugeSegments) > 0
        for i = 0 to array.size(gaugeSegments) - 1
            g_old = array.get(gaugeSegments, i)
            if not na(g_old)
                line.delete(g_old)
        array.clear(gaugeSegments)
    if not na(gaugePointerLb)
        label.delete(gaugePointerLb)
    if not na(gaugePointerLn)
        line.delete(gaugePointerLn)

    int gaugeSeg = 21
    float gaugeTop    = upper_outer + active_outer * 0.35
    float gaugeBot    = lower_outer - active_outer * 0.35
    float gaugeRange  = gaugeTop - gaugeBot
    float segHeight   = gaugeRange / gaugeSeg
    int   gaugeX      = bar_index + 4

    for s = 0 to gaugeSeg - 1
        float ratio  = (s + 0.5) / gaugeSeg
        color segCol = ratio >= 0.5 ? color.from_gradient(ratio, 0.5, 1.0, color.new(chart.fg_color, 70), color.new(bullColor, 25)) : color.from_gradient(ratio, 0.0, 0.5, color.new(bearColor, 25), color.new(chart.fg_color, 70))
        line seg = line.new(
             x1     = gaugeX,
             y1     = gaugeBot + s * segHeight,
             x2     = gaugeX,
             y2     = gaugeBot + (s + 1) * segHeight - segHeight * 0.15,
             xloc   = xloc.bar_index,
             extend = extend.none,
             color  = segCol,
             style  = line.style_solid,
             width  = 6)
        array.push(gaugeSegments, seg)

    // Pointer
    float ptrRatio = (regimeStrength + 1.0) / 2.0
    float ptrY     = gaugeBot + ptrRatio * gaugeRange
    color ptrCol   = regimeStrength >= 0 ? bullColor : bearColor

    gaugePointerLn := line.new(
         x1     = gaugeX - 2,
         y1     = ptrY,
         x2     = gaugeX + 2,
         y2     = ptrY,
         xloc   = xloc.bar_index,
         extend = extend.none,
         color  = ptrCol,
         style  = line.style_solid,
         width  = 3)

    gaugePointerLb := label.new(
         x         = gaugeX + 4,
         y         = ptrY,
         text      = "Strength " + (regimeStrength >= 0 ? "+" : "") + str.tostring(regimeStrength, "0.00"),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(ptrCol, 30),
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small)

// ────────────────────────────────────────────────────────────────────
// G. Sight-line needle from gauge into chart
// ────────────────────────────────────────────────────────────────────
var line strengthNeedle = na

if barstate.islast and showSightNeedle and confirmedBar
    if not na(strengthNeedle)
        line.delete(strengthNeedle)
    float ndlRatio = (regimeStrength + 1.0) / 2.0
    float ndlTop   = upper_outer + active_outer * 0.35
    float ndlBot   = lower_outer - active_outer * 0.35
    float ndlY     = ndlBot + ndlRatio * (ndlTop - ndlBot)
    color ndlCol   = regimeStrength >= 0 ? color.new(bullColor, 35) : color.new(bearColor, 35)
    strengthNeedle := line.new(
         x1     = bar_index - 30,
         y1     = ndlY,
         x2     = bar_index + 4,
         y2     = ndlY,
         xloc   = xloc.bar_index,
         extend = extend.none,
         color  = ndlCol,
         style  = line.style_dashed,
         width  = 1)

// ────────────────────────────────────────────────────────────────────
// F. Forward probability cone
// ────────────────────────────────────────────────────────────────────
var line probConeUp = na
var line probConeDn = na

if barstate.islast and showProbCone and confirmedBar
    if not na(probConeUp)
        line.delete(probConeUp)
    if not na(probConeDn)
        line.delete(probConeDn)
    int upTrans = math.max(55, math.min(85, math.round(90.0 - 35.0 * p_bull_now)))
    int dnTrans = math.max(55, math.min(85, math.round(90.0 - 35.0 * p_bear_now)))
    probConeUp := line.new(
         x1     = bar_index + 6,
         y1     = upper_outer,
         x2     = bar_index + 18,
         y2     = upper_outer,
         xloc   = xloc.bar_index,
         extend = extend.none,
         color  = color.new(bullColor, upTrans),
         style  = line.style_dashed,
         width  = 2)
    probConeDn := line.new(
         x1     = bar_index + 6,
         y1     = lower_outer,
         x2     = bar_index + 18,
         y2     = lower_outer,
         xloc   = xloc.bar_index,
         extend = extend.none,
         color  = color.new(bearColor, dnTrans),
         style  = line.style_dashed,
         width  = 2)

// ────────────────────────────────────────────────────────────────────
// H. FFD memory ribbon
// ────────────────────────────────────────────────────────────────────
var label ffdMemLabel = na

if barstate.islast and showFFDMemory and confirmedBar
    if not na(ffdMemLabel)
        label.delete(ffdMemLabel)
    float ffdY = baseline + active_inner * 0.50
    ffdMemLabel := label.new(
         x         = bar_index + 10,
         y         = ffdY,
         text      = "FFD memory " + str.tostring(ffd_val, "0.00") + "  d=" + str.tostring(d_adapt, "0.00"),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(#1a1a26, 25),
         textcolor = color.new(chart.fg_color, 10),
         style     = label.style_label_left,
         size      = size.tiny)

// ────────────────────────────────────────────────────────────────────
// I. Entropy state strip
// ────────────────────────────────────────────────────────────────────
var label entropyZLabel    = na
var label entropyMultLabel = na

if barstate.islast and showEntropyStrip and confirmedBar
    if not na(entropyZLabel)
        label.delete(entropyZLabel)
    if not na(entropyMultLabel)
        label.delete(entropyMultLabel)
    float entY1 = baseline - active_inner * 0.40
    float entY2 = baseline - active_inner * 0.75
    entropyZLabel := label.new(
         x         = bar_index + 10,
         y         = entY1,
         text      = "Entropy z " + (entropy_z >= 0 ? "+" : "") + str.tostring(entropy_z, "0.00"),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(#1a1a26, 25),
         textcolor = color.new(chart.fg_color, 10),
         style     = label.style_label_left,
         size      = size.tiny)
    entropyMultLabel := label.new(
         x         = bar_index + 10,
         y         = entY2,
         text      = "Bands x" + str.tostring(entropy_mult, "0.00"),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(#1a1a26, 25),
         textcolor = color.new(chart.fg_color, 10),
         style     = label.style_label_left,
         size      = size.tiny)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(longShift,   title="QFB Bull Shift",     message="Quantum Flux Bands [JOAT] — Bull regime shift")
alertcondition(shortShift,  title="QFB Bear Shift",     message="Quantum Flux Bands [JOAT] — Bear regime shift")
alertcondition(outerTouch,  title="QFB Outer Touch",    message="Quantum Flux Bands [JOAT] — Outer band touched")
alertcondition(outerReject, title="QFB Outer Reject",   message="Quantum Flux Bands [JOAT] — Outer band rejection (wick pierced, body closed inside)")
alertcondition(meanReclaim, title="QFB Baseline Cross", message="Quantum Flux Bands [JOAT] — Baseline reclaimed")
````
