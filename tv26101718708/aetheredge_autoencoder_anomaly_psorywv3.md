# AetherEdge - Autoencoder Anomaly

- url: https://www.tradingview.com/script/psorYWV3/
- type: indicator
- pine_id: PUB;7bfe3501db4040b8af759883250cf9b8
- version: 1.0

## Description

🖊️ Overview

AE-ANO is a self-evolving detector of market dislocations. It turns the current bar's state into a feature vector and passes it through a linear autoencoder — compress to a narrow bottleneck, decode back — with weights trained online by gradient descent to minimize reconstruction error on normal structure. Once it has learned the normal manifold, a bar that breaks the usual relationships between features (a flash move, a structure break, a shock) cannot be reconstructed well — a high reconstruction error = an anomaly. The error is standardized into a sigma score, a Mahalanobis-style distance flags magnitude outliers, and the most dislocated feature is named.

🔶 Key Features

Linear autoencoder engine — compresses and reconstructs a 6-dimensional state vector, measuring deviation from normal via reconstruction error.
Self-evolving online learning — encoder/decoder weights learn by gradient descent, continually updating the definition of "normal" to the market.
Reconstruction-error thermometer — the anomaly score (σ) over time as a neon-gradient filled area (calm → hot).
Anomaly pulses — bars whose score exceeds the threshold are marked on price with a glowing marker and background flash (intensity scales with magnitude).
Mahalanobis distance — a Euclidean distance in standardized space flags magnitude outliers (distance from center), complementing the autoencoder.
Feature panel — colors which feature (return/vol/range/body/momentum/trend) is dislocated and names the lead driver.
Live statistics panel — anomaly score, reconstruction error, Mahalanobis distance, lead feature, bottleneck, and last anomaly.
Non-repainting design — learning on confirmed bars only; each bar is judged against what was learned before it, with no look-ahead.

🧠 Technical Architecture

The feature vector is six standardized features — return, volatility (log squared return), range expansion, body/candle character, momentum (RSI), and trend deviation. On each confirmed bar, a forward pass with the current weights (learned through t−1) computes code = We·x (encode), x̂ = Wd·code (decode), and err = x − x̂, giving the reconstruction error ‖err‖. This is standardized by the error's EMA mean and standard deviation into a sigma score (err − mean)/std. After judging, the encoder and decoder weights are updated by backprop SGD (stabilized with weight decay and clipping).
This "judge-then-learn" order flags one-off anomalies before they're absorbed into normal. Yet if an anomaly persists, the weights learn the new structure — adapting to a non-stationary market (the self-evolution). The Mahalanobis-style distance is ‖x‖ in standardized space (distance from the normal center, expected ≈ √D under normality), measuring magnitude outliers to complement the autoencoder (which captures correlation-breaking, structural anomalies). The lead feature is the dimension with the largest reconstruction error — showing what is dislocated now.

🎯 Three design choices stand out. First, the linear autoencoder learns the usual correlations between features and flags bars that break them (e.g., a large move with no accompanying range) as high error. Second, standardizing the error into σ enables an instrument-independent threshold. Third, judging before learning and confining updates to confirmed bars keeps historical anomaly scores non-repainting.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): bottleneck 2, learning rate 0.02, standardization length 100, error window 100, threshold 2.5σ; flash moves and structure breaks are clearly marked. High-volatility names (SOL, XRP): raise the learning rate toward 0.03 for faster adaptation, and the threshold to 3.0σ to catch only genuine anomalies amid normal volatility. For more sensitivity, set the bottleneck to 1 (a tighter normal manifold) and the threshold to 2.0σ.
Per parameter: Bottleneck (k) sets sensitivity — smaller defines "normal" more tightly and is more sensitive to deviation. Learning rate sets adaptation speed (higher is nimbler but too high destabilizes). Standardization length sets the feature baseline. Error window sets the anomaly-score baseline (shorter is more locally adaptive). Threshold (σ) sets pulse sensitivity.

💡 How to Use in Practice

The core read is anomaly score × lead feature. While the score stays calm (NORMAL), the market is within its learned normal structure — existing logic tends to work. The moment the score spikes above the threshold (pulse fires) signals structure has temporarily broken — the start of a breakout, a liquidity shock, a flash move, or a news reaction. The lead feature tells you what is anomalous (e.g., a spike with no volume shows up as Body/Range), helping characterize it. The EXTREME level marks especially strong dislocations — a cue for risk management (revisit stops, cut size).
For multi-timeframe work, read higher-timeframe anomalies for major structure breaks and time execution on a lower timeframe. Because it shows when structure breaks (not direction), pair it with trend or directional signals (e.g., avoid trend-following during anomalies).

⚠️ Important Notes

Nothing displays until the warmup period (default 150 bars) completes. Reloading the indicator retrains the weights from scratch — learning state is not persisted. This is a linear autoencoder and does not fully capture nonlinear normal structure (reconstruction error measures deviation from a linear manifold). If an anomaly persists, it is by design learned as the new "normal" (adaptation to non-stationarity). The Mahalanobis distance is a simplified version assuming diagonal covariance (Euclidean in standardized space). The anomaly score shows no direction, only structural breakage. Judging precedes learning, and updates occur on confirmed bars only.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Autoencoder Anomaly   ( AE-ANO )
// ----------------------------------------------------------------------------
//  A self-evolving dislocation detector. It builds a feature vector of the
//  current bar's state and feeds it through a linear AUTOENCODER - encode to a
//  narrow bottleneck, decode back - trained online by gradient descent to
//  minimize reconstruction error on NORMAL market structure:
//      code = We x ,   x_hat = Wd code ,   loss = || x - x_hat ||^2
//  Once the autoencoder has learned the normal manifold, a bar that breaks the
//  usual relationships between features (a flash move, a structure break, a
//  shock) cannot be reconstructed well -> a high reconstruction error = an
//  ANOMALY. The error is standardized into a sigma score, a Mahalanobis-style
//  distance flags magnitude outliers, and the most dislocated feature is named.
//  Weights self-evolve online; updates occur on confirmed bars only (no
//  look-ahead). The model judges each bar against what it learned BEFORE it.
// ============================================================================
indicator("AetherEdge - Autoencoder Anomaly", "AE-ANO", overlay = false, max_labels_count = 100)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Autoencoder ---
var string gA = "Autoencoder"
kBott  = input.int(2, "Bottleneck (k)", minval = 1, maxval = 4, group = gA, tooltip = "Code dimension. Smaller forces a tighter 'normal' manifold (more sensitive).")
eta    = input.float(0.02, "Learning Rate", minval = 0.001, maxval = 0.2, step = 0.001, group = gA, tooltip = "Online SGD step. Higher adapts faster but is noisier; too high can destabilize.")
wDecay = input.float(0.002, "Weight Decay", minval = 0.0, maxval = 0.05, step = 0.001, group = gA)
clipW  = input.float(5.0, "Weight Clip", minval = 1.0, group = gA, tooltip = "Hard cap on weights for stability.")
seed   = input.int(1337, "Random Seed", minval = 1, group = gA)

//  --- Features ---
var string gF = "Features"
zLen   = input.int(100, "Standardization Length", minval = 20, group = gF)
atrLen = input.int(14,  "ATR Length", minval = 2, group = gF)
rsiLen = input.int(14,  "RSI Length", minval = 2, group = gF)
emaLen = input.int(50,  "Trend EMA Length", minval = 5, group = gF)

//  --- Anomaly ---
var string gN = "Anomaly"
errLen   = input.int(100, "Error Stats Window", minval = 20, group = gN, tooltip = "Window for standardizing the reconstruction error into a sigma score.")
thrSigma = input.float(2.5, "Anomaly Threshold (σ)", minval = 1.0, maxval = 6.0, step = 0.25, group = gN)

//  --- Display ---
var string gD = "Display"
warmup    = input.int(150, "Warmup Bars", minval = 30, group = gD)
calmCol   = input.color(#26ffe6, "Calm", group = gD)
warmCol   = input.color(#ffae57, "Warm", group = gD)
hotCol    = input.color(#ff2e88, "Hot", group = gD)
neutCol   = input.color(#8892b0, "Neutral", group = gD)
showPulse = input.bool(true,  "Anomaly Pulses (on price)", group = gD)
showTint  = input.bool(true,  "Anomaly Flash (on price)", group = gD)
showFeat  = input.bool(true,  "Feature Panel", group = gD)
featPos   = input.string("Bottom Left", "Feature Panel Position", options = ["Bottom Left", "Bottom Right", "Top Left", "Top Right", "Middle Left"], group = gD)
showDash  = input.bool(true,  "Dashboard", group = gD)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
D   = 6
EPS = 1e-12

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Left" ? position.middle_left : s == "Middle Right" ? position.middle_right : position.top_right

f_clip(float x, float lo, float hi) => math.max(math.min(x, hi), lo)

f_heat(float t) =>
    float tt = f_clip(t, 0.0, 1.0)
    tt < 0.5 ? color.from_gradient(tt, 0.0, 0.5, calmCol, warmCol) : color.from_gradient(tt, 0.5, 1.0, warmCol, hotCol)

f_z(float raw) => f_clip((raw - ta.sma(raw, zLen)) / (ta.stdev(raw, zLen) + EPS), -5.0, 5.0)

// ----------------------------------------------------------------------------
//  FEATURE VECTOR  (6 standardized state features)
// ----------------------------------------------------------------------------
ret  = math.log(close / close[1])
atrV = ta.atr(atrLen)
f0 = f_z(ret)                                                  // return / direction
f1 = f_z(math.log(ret * ret + EPS))                            // volatility
f2 = f_z((high - low) / (atrV + EPS))                          // range expansion
f3 = f_z((close - open) / (high - low + EPS))                  // body / candle character
f4 = f_z(ta.rsi(close, rsiLen) - 50.0)                         // momentum
f5 = f_z((close - ta.ema(close, emaLen)) / (atrV + EPS))       // trend deviation

ready = bar_index > warmup and not na(f0) and not na(f2) and not na(f5)

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  (autoencoder weights + error statistics)
// ----------------------------------------------------------------------------
var matrix<float> We = matrix.new<float>(kBott, D, 0.0)   // encoder
var matrix<float> Wd = matrix.new<float>(D, kBott, 0.0)   // decoder
var array<float>  errStore = array.new<float>(D, 0.0)
var float score  = na
var float recErr = na
var float mahala = na
var int   leadFeat = 0
var int   lastAnom = na
var float eM1 = na
var float eM2 = na
var bool  built = false
var array<string> featName = array.from("Ret", "Vol", "Range", "Body", "Mom", "Trend")

if not built
    int rng = seed
    for c = 0 to kBott - 1
        for d = 0 to D - 1
            rng := (rng * 1103515245 + 12345) % 2147483647
            matrix.set(We, c, d, (rng / 2147483647.0 - 0.5) * 0.6)
    for d = 0 to D - 1
        for c = 0 to kBott - 1
            rng := (rng * 1103515245 + 12345) % 2147483647
            matrix.set(Wd, d, c, (rng / 2147483647.0 - 0.5) * 0.6)
    built := true

// ----------------------------------------------------------------------------
//  AUTOENCODER  (forward -> anomaly score -> online SGD ; confirmed bars)
// ----------------------------------------------------------------------------
if barstate.isconfirmed and ready
    array<float> x = array.from(f0, f1, f2, f3, f4, f5)
    // --- forward: encode then decode (judge with weights learned through t-1) ---
    array<float> code = array.new<float>(kBott, 0.0)
    for c = 0 to kBott - 1
        float s = 0.0
        for d = 0 to D - 1
            s += matrix.get(We, c, d) * array.get(x, d)
        array.set(code, c, s)
    array<float> xhat = array.new<float>(D, 0.0)
    for d = 0 to D - 1
        float s = 0.0
        for c = 0 to kBott - 1
            s += matrix.get(Wd, d, c) * array.get(code, c)
        array.set(xhat, d, s)
    array<float> err = array.new<float>(D, 0.0)
    float sse = 0.0
    float mag = 0.0
    for d = 0 to D - 1
        float e = array.get(x, d) - array.get(xhat, d)
        array.set(err, d, e)
        sse += e * e
        mag += array.get(x, d) * array.get(x, d)
    recErr := math.sqrt(sse)
    mahala := math.sqrt(mag)
    // --- standardize error -> sigma score ---
    float aE = 2.0 / (errLen + 1.0)
    eM1 := na(eM1) ? recErr : eM1 * (1.0 - aE) + aE * recErr
    eM2 := na(eM2) ? recErr * recErr : eM2 * (1.0 - aE) + aE * recErr * recErr
    float estd = math.sqrt(math.max(eM2 - eM1 * eM1, EPS))
    score := (recErr - eM1) / (estd + EPS)
    // --- lead (most dislocated) feature + store per-feature error ---
    float bestE = -1.0
    for d = 0 to D - 1
        float ae = math.abs(array.get(err, d))
        array.set(errStore, d, ae)
        if ae > bestE
            bestE := ae
            leadFeat := d
    if score > thrSigma
        lastAnom := bar_index
    // --- online SGD update (backprop through the linear AE) ---
    array<float> dCode = array.new<float>(kBott, 0.0)
    for c = 0 to kBott - 1
        float s = 0.0
        for d = 0 to D - 1
            s += matrix.get(Wd, d, c) * array.get(err, d)
        array.set(dCode, c, s)
    for d = 0 to D - 1
        for c = 0 to kBott - 1
            float w = (1.0 - eta * wDecay) * matrix.get(Wd, d, c) + eta * array.get(err, d) * array.get(code, c)
            matrix.set(Wd, d, c, f_clip(w, -clipW, clipW))
    for c = 0 to kBott - 1
        for d = 0 to D - 1
            float w = (1.0 - eta * wDecay) * matrix.get(We, c, d) + eta * array.get(dCode, c) * array.get(x, d)
            matrix.set(We, c, d, f_clip(w, -clipW, clipW))

// ----------------------------------------------------------------------------
//  DERIVED
// ----------------------------------------------------------------------------
active = ready and built and not na(score)
float extremeLv = thrSigma * 1.6
bool isAnom = active and score > thrSigma
bool isExtreme = active and score > extremeLv
color heatNow = f_heat(nz(score) / extremeLv)
color anomCol = isExtreme ? hotCol : isAnom ? warmCol : neutCol

// ----------------------------------------------------------------------------
//  PANE : reconstruction-error thermometer (anomaly score over time)
// ----------------------------------------------------------------------------
ps = plot(active ? score : na, "Anomaly σ", color = heatNow, linewidth = 2)
pz = plot(active ? 0.0 : na, "", color = na, display = display.none)
fill(ps, pz, color.new(heatNow, 80))
hline(thrSigma, "Anomaly", color = color.new(warmCol, 50), linestyle = hline.style_dashed)
hline(extremeLv, "Extreme", color = color.new(hotCol, 50), linestyle = hline.style_dashed)
hline(0, "", color = color.new(neutCol, 80))

// ----------------------------------------------------------------------------
//  ON-PRICE : anomaly flash + pulses  (force_overlay)
// ----------------------------------------------------------------------------
bgcolor(showTint and isAnom ? color.new(anomCol, 78) : na, force_overlay = true)
plotshape(showPulse and isAnom and not isExtreme, "Anomaly", shape.diamond, location.top, color = warmCol, size = size.tiny, force_overlay = true)
plotshape(showPulse and isExtreme, "Extreme", shape.diamond, location.top, color = hotCol, size = size.small, force_overlay = true)

// ----------------------------------------------------------------------------
//  FEATURE PANEL + DASHBOARD
// ----------------------------------------------------------------------------
var table feat = table.new(position = f_pos(featPos), columns = D, rows = 2, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(calmCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 8, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(calmCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)

if barstate.islast and active
    // ----- feature dislocation panel -----
    if showFeat
        float maxE = EPS
        for d = 0 to D - 1
            maxE := math.max(maxE, array.get(errStore, d))
        for d = 0 to D - 1
            float t = array.get(errStore, d) / maxE
            bool isLead = d == leadFeat
            table.cell(feat, d, 0, array.get(featName, d), text_color = isLead ? hotCol : neutCol, bgcolor = #0b0e16, text_size = size.tiny, text_halign = text.align_center)
            table.cell(feat, d, 1, str.tostring(array.get(errStore, d), "#.#"), text_color = color.rgb(11, 14, 22), bgcolor = f_heat(t), text_size = size.tiny, text_halign = text.align_center)

    // ----- dashboard -----
    if showDash
        color rowBg = color.new(#11151f, 10)
        color hdrBg = #0b0e16
        string stat = isExtreme ? "✸ EXTREME" : isAnom ? "⚠ ANOMALY" : "● NORMAL"
        color  statCol = isExtreme ? hotCol : isAnom ? warmCol : calmCol
        table.cell(dash, 0, 0, "AE · ANO",     text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
        table.cell(dash, 1, 0, stat,           text_color = statCol, bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 1, "Anomaly",      text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 1, str.tostring(score, "#.#") + "σ", text_color = heatNow, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 2, "Reconstruction", text_color = neutCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, 2, str.tostring(recErr, "#.##"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 3, "Mahalanobis",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 3, str.tostring(mahala, "#.#") + " / " + str.tostring(math.sqrt(D), "#.#"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 4, "Lead Feature", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 4, array.get(featName, leadFeat), text_color = hotCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 5, "Bottleneck",   text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 5, str.tostring(kBott) + " / " + str.tostring(D), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 6, "Last Anomaly", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 6, na(lastAnom) ? "—" : str.tostring(bar_index - lastAnom) + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 7, "Learn η",      text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 7, str.tostring(eta, "#.###"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(isAnom and not isAnom[1], "Anomaly detected", "AE-ANO: market dislocation detected")
alertcondition(isExtreme and not isExtreme[1], "Extreme anomaly", "AE-ANO: extreme market dislocation")
````
