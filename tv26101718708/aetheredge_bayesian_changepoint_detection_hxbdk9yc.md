# AetherEdge - Bayesian Changepoint Detection

- url: https://www.tradingview.com/script/HxBDk9yC/
- type: indicator
- pine_id: PUB;adb5a6d8bd7344aeb44481eb71fc10c3
- version: 1.0

## Description

🖊️ Overview

AE-BCP is a Bayesian detector of structural breaks (Adams & MacKay, 2007). Rather than flagging regime shifts with a hard threshold, it maintains a posterior distribution over the run length — the number of bars since the last changepoint — and updates it recursively with every new observation. A Gaussian conjugate predictive (on standardized returns or log-volatility) scores how surprising each bar is under each run-length hypothesis. Beliefs self-evolve recursively, and P(run length = 0) is the live probability that a structural break just occurred. The classic triangular run-length posterior is painted as a heatmap.

🔶 Key Features

BOCPD engine — recursively updates the run-length posterior into growth and changepoint probabilities, outputting structural breaks as a probability.
Self-evolving recursive Bayesian update — each run-length hypothesis's predictive model (sufficient statistics) and the posterior update online with every observation.
Changepoint probability (soft detection) — P(run length = 0) as a continuous 0–1 probability; threshold crossings are marked on price.
Run-length posterior heatmap — the time × run-length × probability triangular heatmap (BOCPD's signature visual), aligned to the price timeline.
Expected run length (regime age) — estimates how many bars the current regime has lasted, collapsing to zero at changepoints (shown as a line).
Volatility or drift — monitor log squared returns to detect volatility-regime changes, or returns to detect drift changes.
Live statistics panel — changepoint probability, regime age, MAP run length, last changepoint, and hazard rate.
Non-repainting design — all updates on confirmed bars only, with no look-ahead.

🧠 Technical Architecture

The monitored feature (Volatility mode = log squared return, Returns mode = return) is standardized over a long window, fixing the predictive variance at ~1. On each confirmed bar, the predictive probability of each run-length hypothesis r is pred(x_t|r) = N(x_t | m_r, σ²(1+1/r)) (m_r = the run's mean). From these, growth P(r_t=r+1) ∝ P(r_{t-1}=r)·pred·(1−H) and changepoint P(r_t=0) ∝ Σ_r P(r_{t-1}=r)·pred·H are computed and normalized. H is the hazard rate (= 1 / mean regime length), the prior probability of a changepoint.
Each run-length's sufficient statistics (sum of the run's observations) update as sum[r+1] = sum[r] + x_t on growth and sum[0] = 0 (prior) on a changepoint. Run length is truncated at Rmax for tractability. Outputs are the changepoint probability P(r_t=0), expected run length E[r]=Σr·P(r), and MAP run length argmax P(r). The posterior is binned into a rolling buffer and, on the last bar, drawn as a heatmap (boxes) aligned to the price timeline.

🎯 Three design choices stand out. First, standardization fixes the predictive variance, allowing a robust Gaussian-conjugate implementation with no gamma functions. Second, monitoring log squared returns turns "variance changes" into "mean changes," so a simple mean-change model captures volatility-regime breaks. Third, confining updates to confirmed bars keeps the historical posterior non-repainting.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): Monitor = Volatility, mean regime length 60, standardization length 200, max run length 100, changepoint threshold 0.30; volatility-regime breaks are clearly marked. For more frequent turns: lower mean regime length toward 30 (higher hazard, more sensitive) and lower the threshold to 0.25. To suppress noise: raise mean regime length to 100 and the threshold to 0.40.
Per parameter: Mean regime length is the key knob (hazard = its reciprocal) — shorter detects changepoints more often, longer is conservative. Monitor selects Volatility (vol breaks) or Returns (drift changes) for your purpose. Standardization length sets the baseline scale window (longer is steadier). Max run length sets how far back regimes are retained. Changepoint threshold sets marker sensitivity.

💡 How to Use in Practice

The core read is changepoint probability × regime age. When the changepoint probability is low and stable and the regime age keeps rising, the current regime (trend or range) is persisting — strategies aligned with that premise tend to work. The moment the changepoint probability spikes above the threshold (diamond marker fires) signals the volatility or drift structure has changed — a point to review existing positions or switch strategy to the new regime. Each time the heatmap triangle resets (run length collapses to zero), you can see the market entering a new phase visually.
For multi-timeframe work, read higher-timeframe changepoints for major structural turns and execute on a lower timeframe. It also serves as a meta-filter to run trend or mean-reversion strategies only while the regime is stable.

⚠️ Important Notes

Nothing displays until the warmup period (default 200 bars) completes. Reloading the indicator rebuilds the posterior from scratch — learning state is not persisted. This is a Gaussian-conjugate model with a known (≈1, via standardization) predictive variance that detects mean changes in the monitored feature (Volatility mode captures volatility changes via the log-squared transform). Run length is truncated at Rmax, so for very long regimes the expected run length saturates near the cap. The changepoint probability is a posterior belief, not a certain verdict, and detection requires evidence to accumulate, so it lags by a few bars. Updates occur on confirmed bars only.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Bayesian Changepoint Detection   ( AE-BCP )
// ----------------------------------------------------------------------------
//  A probabilistic structural-break detector (Adams & MacKay, 2007). Instead of
//  flagging regime shifts with a hard threshold, it maintains a full posterior
//  distribution over the RUN LENGTH r_t - the number of bars since the last
//  changepoint - and updates it online with every new observation:
//      growth :  P(r_t=r+1) ∝ P(r_{t-1}=r) · pred(x_t|r) · (1-H)
//      change :  P(r_t=0)   ∝ Σ_r P(r_{t-1}=r) · pred(x_t|r) · H
//  A Gaussian conjugate predictive (on standardized returns or log-volatility)
//  scores how surprising each new bar is under each run-length hypothesis. The
//  beliefs self-evolve recursively; P(r_t=0) is the live probability that a
//  structural break just happened. The classic triangular run-length posterior
//  is painted as a heatmap. Updates occur on confirmed bars only (no look-ahead).
// ============================================================================
indicator("AetherEdge - Bayesian Changepoint Detection", "AE-BCP", overlay = false, max_boxes_count = 520, max_lines_count = 50, max_labels_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Model ---
var string gM = "Model"
mode    = input.string("Volatility", "Monitor", options = ["Volatility", "Returns"], group = gM, tooltip = "Volatility = detect changes in the volatility regime (via log squared return). Returns = detect changes in drift.")
meanLen = input.float(60, "Mean Regime Length", minval = 5, group = gM, tooltip = "Prior expected bars between changepoints. Hazard rate H = 1 / this. Larger = more conservative (fewer breaks).")
zLen    = input.int(200, "Standardization Length", minval = 20, group = gM, tooltip = "Long window used to standardize the monitored feature to unit scale.")

//  --- Detection ---
var string gT = "Detection"
Rmax    = input.int(100, "Max Run Length", minval = 30, maxval = 200, group = gT, tooltip = "Run-length posterior is truncated here. Larger captures older regimes but is heavier.")
cpThr   = input.float(0.30, "Changepoint Threshold", minval = 0.05, maxval = 0.95, step = 0.05, group = gT, tooltip = "P(changepoint) above this is flagged on price.")

//  --- Heatmap ---
var string gH = "Heatmap"
KrlRows = input.int(16, "Heatmap Rows", minval = 6, maxval = 30, group = gH)
Ktime   = input.int(30, "Heatmap Columns", minval = 5, maxval = 40, group = gH)

//  --- Display ---
var string gD = "Display"
warmup    = input.int(200, "Warmup Bars", minval = 30, group = gD)
calmCol   = input.color(#26ffe6, "Calm", group = gD)
breakCol  = input.color(#ff2e88, "Break", group = gD)
neutCol   = input.color(#8892b0, "Neutral", group = gD)
accent    = input.color(#aeffff, "Accent", group = gD)
showHeat  = input.bool(true,  "Run-Length Heatmap", group = gD)
showMarks = input.bool(true,  "Changepoint Markers (on price)", group = gD)
showTint  = input.bool(true,  "Break Flash (on price)", group = gD)
showDash  = input.bool(true,  "Dashboard", group = gD)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
EPS    = 1e-12
TWO_PI = 2.0 * math.pi
H      = 1.0 / meanLen

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

f_clip(float x, float lo, float hi) => math.max(math.min(x, hi), lo)

f_heat(float t) =>
    float tt = f_clip(t, 0.0, 1.0)
    tt < 0.5 ? color.from_gradient(tt, 0.0, 0.5, #0b0e16, #2a6cf0) : color.from_gradient(tt, 0.5, 1.0, #2a6cf0, #26ffe6)

// ----------------------------------------------------------------------------
//  MONITORED FEATURE  (standardized to unit scale -> predictive variance ~1)
// ----------------------------------------------------------------------------
ret = math.log(close / close[1])
raw = mode == "Volatility" ? math.log(ret * ret + EPS) : ret
obs = f_clip((raw - ta.sma(raw, zLen)) / (ta.stdev(raw, zLen) + EPS), -6.0, 6.0)

ready = bar_index > warmup and not na(obs)

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  (run-length posterior + per-hypothesis sufficient stats)
// ----------------------------------------------------------------------------
var array<float>  rl   = array.new<float>(Rmax + 1, 0.0)   // run-length posterior
var array<float>  sumX = array.new<float>(Rmax + 1, 0.0)   // sum of obs in each run
var matrix<float> RLHist = matrix.new<float>(KrlRows, Ktime, 0.0)
var float cpProb = na
var float expRL  = na
var int   mapRL  = 0
var int   lastCp = na
var bool  built  = false

if not built
    array.set(rl, 0, 1.0)
    built := true

// ----------------------------------------------------------------------------
//  BOCPD RECURSION  (advance once per CLOSED bar)
// ----------------------------------------------------------------------------
if barstate.isconfirmed and ready
    // predictive probability of x_t under each previous run-length hypothesis
    array<float> pp = array.new<float>(Rmax + 1, 0.0)
    for r = 0 to Rmax
        float mu = r == 0 ? 0.0 : array.get(sumX, r) / r
        float pvar = r == 0 ? 2.0 : 1.0 + 1.0 / r       // sigma^2 = 1 (standardized)
        float d = obs - mu
        array.set(pp, r, math.exp(-d * d / (2.0 * pvar)) / math.sqrt(TWO_PI * pvar))
    // changepoint mass (new run length 0)
    float cp = 0.0
    for r = 0 to Rmax
        cp += array.get(rl, r) * array.get(pp, r) * H
    // growth: shift run-lengths up by one (in place, high -> low)
    for r = Rmax - 1 to 0
        array.set(rl, r + 1, array.get(rl, r) * array.get(pp, r) * (1.0 - H))
        array.set(sumX, r + 1, array.get(sumX, r) + obs)
    array.set(rl, 0, cp)
    array.set(sumX, 0, 0.0)
    // normalize posterior
    float Z = EPS
    for r = 0 to Rmax
        Z += array.get(rl, r)
    for r = 0 to Rmax
        array.set(rl, r, array.get(rl, r) / Z)
    // outputs
    cpProb := array.get(rl, 0)
    float er = 0.0
    int   bestR = 0
    float bestV = -1.0
    for r = 0 to Rmax
        float p = array.get(rl, r)
        er += r * p
        if p > bestV
            bestV := p
            bestR := r
    expRL := er
    mapRL := bestR
    if cpProb > cpThr and (na(lastCp) or bar_index - lastCp >= 1)
        lastCp := bar_index
    // push binned posterior into the heatmap buffer (shift columns left)
    for j = 0 to Ktime - 2
        for b = 0 to KrlRows - 1
            matrix.set(RLHist, b, j, matrix.get(RLHist, b, j + 1))
    array<float> binned = array.new<float>(KrlRows, 0.0)
    for r = 0 to Rmax
        int b = math.min(int(r * KrlRows / (Rmax + 1)), KrlRows - 1)
        array.set(binned, b, array.get(binned, b) + array.get(rl, r))
    for b = 0 to KrlRows - 1
        matrix.set(RLHist, b, Ktime - 1, array.get(binned, b))

// ----------------------------------------------------------------------------
//  DERIVED
// ----------------------------------------------------------------------------
active = ready and built and not na(cpProb)
bool isBreak = active and cpProb > cpThr
color riskCol = color.from_gradient(nz(cpProb), 0.0, cpThr, calmCol, breakCol)

// ----------------------------------------------------------------------------
//  PANE : run-length posterior heatmap + expected run length
// ----------------------------------------------------------------------------
plot(active ? expRL : na, "Expected Run Length", color = accent, linewidth = 2)
plot(active ? mapRL : na, "MAP Run Length", color = color.new(neutCol, 40), linewidth = 1)
hline(0, "", color = color.new(neutCol, 80))
hline(Rmax, "", color = color.new(neutCol, 80))

var array<box> bxs = array.new<box>()
if barstate.islast
    if array.size(bxs) > 0
        for bx in bxs
            box.delete(bx)
        array.clear(bxs)
    if active and showHeat
        float maxP = EPS
        for b = 0 to KrlRows - 1
            for j = 0 to Ktime - 1
                maxP := math.max(maxP, matrix.get(RLHist, b, j))
        for b = 0 to KrlRows - 1
            float yb = b * Rmax / KrlRows
            float yt = (b + 1) * Rmax / KrlRows
            for j = 0 to Ktime - 1
                int xl = bar_index - (Ktime - 1) + j
                array.push(bxs, box.new(left = xl, top = yt, right = xl + 1, bottom = yb, border_width = 0, bgcolor = f_heat(matrix.get(RLHist, b, j) / maxP)))

// ----------------------------------------------------------------------------
//  ON-PRICE : changepoint flash + markers  (force_overlay)
// ----------------------------------------------------------------------------
bgcolor(showTint and isBreak ? color.new(breakCol, 80) : na, force_overlay = true)
plotshape(showMarks and isBreak, "Changepoint", shape.diamond, location.top, color = breakCol, size = size.tiny, force_overlay = true)

// ----------------------------------------------------------------------------
//  DASHBOARD  (on price)
// ----------------------------------------------------------------------------
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 8, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(calmCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1, force_overlay = true)

if barstate.islast and showDash and active
    color rowBg = color.new(#11151f, 10)
    color hdrBg = #0b0e16
    string stat = isBreak ? "⚠ BREAK" : "● STABLE"
    color  statCol = isBreak ? breakCol : calmCol
    table.cell(dash, 0, 0, "AE · BCP",    text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, stat,          text_color = statCol, bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
    table.cell(dash, 0, 1, "Changepoint", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 1, str.tostring(cpProb * 100, "#.#") + "%", text_color = riskCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 2, "Regime Age",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(math.round(expRL)) + " bars", text_color = accent, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "MAP Length",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(mapRL) + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 4, "Last Break",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 4, na(lastCp) ? "—" : str.tostring(bar_index - lastCp) + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 5, "Hazard H",    text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(H * 100, "#.##") + "%", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 6, "Monitor",     text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 6, mode,          text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_right)
    table.cell(dash, 0, 7, "Mean Regime", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(meanLen, "#") + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(isBreak and not isBreak[1], "Changepoint detected", "AE-BCP: structural break detected")
````
