# AI Regime Detection

- url: https://www.tradingview.com/script/FOGtP1iK-AI-Regime-Detection/
- type: indicator
- pine_id: PUB;f14d48cf22f5488c9ca4cf65515bb0d1
- version: 2.0

## Description

[b]AI Regime Detection[/b]
Markov Regime Switching · 4-State Hidden Markov Model · Online Learning · Pine Script v6
This indicator uses a genuine machine learning model — a 4-state Hidden Markov Model with online learning — to classify the market into one of four regimes in real time: Bull Trend, Bear Trend, Ranging, and High Volatility. Instead of a binary “trend/no-trend” signal, it outputs a full probability distribution over all four regimes every bar, together with a confidence score, a live statistics dashboard, and the learned transition matrix.
Knowing the current regime is arguably the most important context in trading: trend-following systems bleed in ranging markets, mean-reversion systems get destroyed in strong trends, and position sizing should shrink when volatility explodes. This tool answers the question “what kind of market am I in right now — and how sure can I be?” using a probabilistic framework rather than fixed thresholds.
https://www.tradingview.com/x/CDXB2JJe/
[b]How It Works[/b]
The engine is a Markov Regime Switching model processed with Bayesian forward filtering (Hamilton filter) on every bar:
Four bounded, scale-free features are extracted each bar: trend correlation (price vs. time, −1 to +1), RSI-based momentum, volatility percentile rank, and Sharpe-normalized drift. Because all features are bounded and scale-free, the model behaves consistently across any symbol and timeframe — no re-tuning needed between a large-cap stock and a crypto pair.
Each regime is defined by an emission template describing what its features typically look like (e.g. Bull Trend expects positive trend correlation and positive drift; High Volatility expects a top-decile volatility percentile).
Every bar, the model computes the likelihood of the observed features under each regime using a Lorentzian kernel (fat-tailed, robust to outliers — the same distance philosophy popularized by Lorentzian Classification) or a Gaussian kernel, then updates the posterior probabilities through the Markov transition matrix.
Online learning (approximate online EM): the transition matrix and the emission means are continuously updated from the data itself, with a learning-rate control. The model adapts to the statistical personality of each symbol instead of staying frozen at its priors. Regularization (diagonal cap, off-diagonal floor, template anchoring) prevents the two classic HMM failure modes: regime lock-in and label switching.
The regime with the highest posterior probability becomes the detected regime; its probability is the confidence score. The filtering is strictly causal — only past and current bars are used, and regime-change labels are drawn on confirmed bars only, so the tool does not repaint.
The model was validated on Monte Carlo simulations with known ground-truth regimes (drift processes for trends, mean-reverting Ornstein–Uhlenbeck processes for ranges and volatility shocks) before release.
[b]Features[/b]
Real-time regime classification: Bull Trend ▲, Bear Trend ▼, Ranging ◆, High Volatility ⚡
Full posterior probability for all four regimes every bar, not just a single label
Confidence score (0–100%) with visual probability bars
Chart background tinted by regime, opacity scaled by confidence
Non-repainting regime-change labels printed on the price chart
Confidence & probability oscillator pane with reference levels (uniform prior 25%, high-confidence 80%)
Statistics dashboard: current volatility & its percentile, trend correlation, regime age, average regime duration, average return per bar inside the current regime, total regime switches, time distribution across regimes
Live learned transition matrix (4×4) — see the actual switching probabilities the model has learned for your symbol
Next likely regime — the most probable transition out of the current regime
Long-run π — the stationary distribution: the share of time each regime is expected to occupy in the long run
Choice of Lorentzian (robust) or Gaussian emission kernel
5 built-in alerts: any regime change + one per specific regime
[b]Settings[/b]
Model — Markov Regime Switching
Regime persistence (prior): initial probability of staying in the same regime bar-to-bar. Higher = smoother, fewer switches; lower = more reactive.
Learning rate — transition matrix: how fast the switching probabilities adapt to the symbol. 0 disables adaptation.
Learning rate — emission: how fast regime feature profiles adapt. 0 disables adaptation.
Online learning (adaptive): master switch for all learning; off = fixed prior model.
Emission kernel: Lorentzian (robust, default) or Gaussian.
Features
Trend correlation length: window for the price-vs-time correlation trend measure.
RSI momentum length: period of the momentum feature.
Realized volatility length: window for realized volatility.
Volatility percentile window: lookback used to rank current volatility (also the warm-up length).
Drift smoothing length: smoothing window for the normalized drift feature.
Appearance
Toggles for background coloring, dashboard, regime-change labels, and transition matrix rows.
Dashboard position & text size.
Custom colors for each of the four regimes.
[b]Usage[/b]
https://www.tradingview.com/x/QeGjsN7d/
When the model detects a Bull Trend regime with high confidence, the background turns green and a label marks the transition bar. This is the environment where trend-following entries, pyramiding, and letting winners run have a statistical tailwind. The confidence reading matters: an 85% Bull reading and a 45% Bull reading are very different market states — the dashboard’s probability bars show how much weight the competing regimes still hold.
https://www.tradingview.com/x/woSDQCGH/
In a Ranging regime, the probability pane typically shows the blue Ranging line dominating while trend probabilities stay suppressed. This is where breakout trades fail most often and mean-reversion (fading moves back toward the middle of the range) performs best. A falling confidence during a mature trend regime often precedes the transition into Ranging — watch the oscillator pane for the crossover of probability lines.
https://www.tradingview.com/x/ouMzr9dJ/
The High Volatility regime fires when volatility jumps into its top percentiles regardless of direction. This regime is a risk filter first and foremost: reduce position size, widen stops, or stand aside. High Vol regimes frequently appear at capitulation lows and blow-off tops, so their resolution (which regime follows) is informative — the “NEXT LIKELY” row of the dashboard shows the model’s learned expectation.
https://www.tradingview.com/x/i8gAOCEe/
The dashboard is the statistical summary of everything the model knows. The transition matrix rows read left-to-right as “from the row’s regime, probability of moving to ▲ ▼ ◆ ⚡”. A learned matrix with strong diagonals means the symbol has persistent, tradable regimes; weak diagonals mean choppy regime behavior — itself useful information for strategy selection. LONG-RUN π tells you the personality of the instrument (e.g. an index that spends 60% of its time trending vs. a pair that ranges 70% of the time). Ø RET/BAR shows the realized average return per bar inside the current regime on this chart — a quick sanity check that the regime labels align with actual profitability.
https://www.tradingview.com/x/1Hi2maIM/
The lower pane plots confidence as a colored area (colored by the ruling regime) plus all four probability lines. Regime transitions appear as probability crossovers, and the 80% dotted line marks the high-confidence zone. Time spent below ~45% confidence indicates a contested, transitional market — a reasonable filter for standing aside.
Details for the Curious
The Hamilton filter recursion is αₜ(j) ∝ bⱼ(oₜ) · Σᵢ αₜ₋₁(i) · A[i][j], normalized each bar, where bⱼ is the emission likelihood and A the transition matrix.
Transition-matrix learning uses an exponentially weighted update toward the per-bar posterior transition distribution, weighted by the previous state probability — an O(1) approximation of online Baum–Welch.
Emission means are updated toward observed features weighted by the state posterior, with an anchor term pulling back toward the initial templates to keep regime identities stable.
The warm-up period equals the volatility percentile window (default 300 bars). On symbols with short history, reduce this input.
Limitations & Honest Notes
Per-bar classification of noisy financial data has an information-theoretic ceiling; expect occasional flicker near regime boundaries and during genuinely ambiguous markets. The persistence prior and confidence threshold are the tools to manage this.
Probabilities are model outputs, not guarantees. A regime model describes the statistical character of recent price action; it does not predict news, gaps, or structural breaks.
This is a context / filter tool, not a standalone entry-exit system. It is designed to tell you which strategy the current market rewards, not to replace one.
Conclusion
AI Regime Detection brings a real, transparent machine learning pipeline — Hidden Markov Model, Bayesian filtering, Lorentzian likelihoods, and online EM adaptation — natively into Pine Script, with every internal state (probabilities, transition matrix, stationary distribution) exposed on the chart instead of hidden behind a black box. Use it to align your strategy with the market’s current regime and to size risk with the model’s own confidence.

## Source Code

````pine
//@version=6
// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  AI REGIME DETECTION                                                       ║
// ║  Model   : Markov Regime Switching — 4-state HMM                           ║
// ║  Filter  : Bayesian forward filtering (Hamilton filter) every bar          ║
// ║  ML      : Online EM — transition matrix + emissions learn continuously    ║
// ║  Kernel  : Lorentzian (robust, outlier-resistant) or Gaussian              ║
// ║  Features: Trend correlation · RSI momentum · Vol percentile · Drift       ║
// ║            (bounded & scale-free — verified via Monte Carlo simulation)    ║
// ║  Regimes : BULL TREND · BEAR TREND · RANGING · HIGH VOLATILITY             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
indicator("AI Regime Detection", "AI Regime Detection", overlay = false, max_labels_count = 500)

// ─────────────────────────────── INPUTS ─────────────────────────────────────
gM = "🧠 Model — Markov Regime Switching"
pStay    = input.float(0.92, "Regime persistence (prior)", minval = 0.50, maxval = 0.99, step = 0.01, group = gM)
lrA      = input.float(0.010, "Learning rate — transition matrix", minval = 0.0, maxval = 0.10, step = 0.005, group = gM)
lrMu     = input.float(0.010, "Learning rate — emission", minval = 0.0, maxval = 0.10, step = 0.005, group = gM)
adaptOn  = input.bool(true, "Online learning (adaptive)", group = gM)
kernelIn = input.string("Lorentzian (robust)", "Emission kernel", options = ["Lorentzian (robust)", "Gaussian"], group = gM)
switchMargin = input.float(0.05, "Jump penalty — switch margin", minval = 0.0, maxval = 0.5, step = 0.01, group = gM, tooltip = "New regime must beat the current regime's probability by this margin to take over. Higher = fewer, more persistent switches (Statistical Jump Model idea).")
confirmBars  = input.int(1, "Jump penalty — confirm bars", minval = 1, maxval = 10, group = gM, tooltip = "Candidate regime must hold the margin for this many consecutive bars before the switch is accepted.")
tempIn       = input.float(2.0, "Likelihood tempering (τ)", minval = 1.0, maxval = 5.0, step = 0.5, group = gM, tooltip = "Corrects overconfidence caused by correlated features (evidence double-counting). Higher τ = softer, better-calibrated confidence. τ = 1 disables (raw likelihoods).")

gF = "📐 Features"
corrLen  = input.int(50,  "Trend correlation length", minval = 10, group = gF)
rsiLen   = input.int(14,  "RSI momentum length", minval = 2, group = gF)
volLen   = input.int(20,  "Realized volatility length", minval = 5, group = gF)
volPrLen = input.int(300, "Volatility percentile window", minval = 50, group = gF)
driftLen = input.int(14,  "Drift smoothing length", minval = 5, group = gF)

gU = "🎨 Appearance"
showBg   = input.bool(true, "Regime background color", group = gU)
showDash = input.bool(true, "Statistics dashboard", group = gU)
showPane = input.bool(true, "Confidence pane (bottom)", group = gU)
showLbl  = input.bool(true, "Label on regime change", group = gU)
showMtx  = input.bool(true, "Show transition matrix", group = gU)
posIn    = input.string("top_right", "Dashboard position", options = ["top_right", "top_left", "bottom_right", "bottom_left"], group = gU)
sizeIn   = input.string("small", "Text size", options = ["tiny", "small", "normal"], group = gU)
cBull  = input.color(#00E676, "Bull", group = gU, inline = "c1")
cBear  = input.color(#FF1744, "Bear", group = gU, inline = "c1")
cRange = input.color(#448AFF, "Ranging", group = gU, inline = "c2")
cHiVol = input.color(#FFB300, "High Vol", group = gU, inline = "c2")

// theme — dark terminal / AI
color COL_BG  = #0D1117
color COL_BRD = #1F2937
color COL_LAB = #8B949E
color COL_VAL = #E6EDF3
color COL_ACC = #00E5FF
bool  useLor  = kernelIn == "Lorentzian (robust)"

// ─────────────────────────────── HELPERS ────────────────────────────────────
// emission LOG-PDF: Lorentzian (Cauchy, fat tails → robust) or Gaussian
// log-space = immune to numeric underflow (extreme z on low-TF charts would otherwise zero out all likelihoods)
logpdf(float x, float mu, float sd) =>
    z = (x - mu) / sd
    useLor ? -math.log(3.14159265359 * sd * (1.0 + z * z)) : -0.5 * z * z - math.log(sd * 2.50662827463)

regName(int i) => i == 0 ? "BULL TREND" : i == 1 ? "BEAR TREND" : i == 2 ? "RANGING" : "HIGH VOL"
regIcon(int i) => i == 0 ? "▲" : i == 1 ? "▼" : i == 2 ? "◆" : "⚡"
regCol(int i)  => i == 0 ? cBull : i == 1 ? cBear : i == 2 ? cRange : cHiVol

barStr(float p) =>
    n = math.round(p * 10)
    s = ""
    for i = 1 to 10
        s += i <= n ? "▰" : "▱"
    s

// ─────────────────────────────── FEATURES ───────────────────────────────────
// Bounded & scale-free — behave consistently across any symbol / timeframe
ret = math.log(close / close[1])
rv  = ta.stdev(ret, volLen)                                       // realized volatility
fTrend = ta.ema(ta.correlation(close, bar_index, corrLen), 3)     // trend ∈ [-1,+1]
fMom   = ta.ema((ta.rsi(close, rsiLen) - 50) / 25, 3)             // momentum ~ [-2,+2]
volPR  = ta.percentrank(rv, volPrLen)                             // 0..100
fVol   = volPR / 100                                              // vol percentile ∈ [0,1]
emaRet = ta.ema(ret, driftLen)
fDriftRaw = rv > 0 ? 10 * emaRet / rv : 0.0                       // drift (Sharpe-normalized)
fDrift = math.max(-25.0, math.min(25.0, fDriftRaw))               // clamp — bounded like other features

bool valid = bar_index > volPrLen and not na(fTrend) and not na(fVol) and not na(fMom) and not na(fDrift)

// ─────────────────────────── MODEL STATE (persistent) ───────────────────────
var matrix<float> A   = matrix.new<float>(4, 4, 0.0)   // transition matrix (learned online)
var matrix<float> MU  = matrix.new<float>(4, 4, 0.0)   // emission means (learned online)
var matrix<float> MU0 = matrix.new<float>(4, 4, 0.0)   // anchor (prevents label switching)
var matrix<float> SD  = matrix.new<float>(4, 4, 1.0)   // emission scales
var array<float>  alp = array.from(0.25, 0.25, 0.25, 0.25)  // posterior P(regime)

if barstate.isfirst
    for i = 0 to 3
        for j = 0 to 3
            matrix.set(A, i, j, i == j ? pStay : (1.0 - pStay) / 3.0)
    // emission templates:  trend   mom   volPct  drift   (order: Bull, Bear, Range, HighVol)
    muInit = array.from(0.65, 0.35, 0.45, 1.00, -0.65, -0.35, 0.55, -1.00, 0.00, 0.00, 0.25, 0.00, 0.00, 0.00, 0.90, 0.00)
    sdInit = array.from(0.30, 0.50, 0.25, 0.90, 0.30, 0.50, 0.25, 0.90, 0.35, 0.40, 0.20, 0.60, 0.60, 0.80, 0.12, 1.50)
    for i = 0 to 3
        for k = 0 to 3
            matrix.set(MU,  i, k, array.get(muInit, i * 4 + k))
            matrix.set(MU0, i, k, array.get(muInit, i * 4 + k))
            matrix.set(SD,  i, k, array.get(sdInit, i * 4 + k))

// ─────────────────── HAMILTON FILTER + ONLINE LEARNING ──────────────────────
if valid
    feats = array.from(fTrend, fMom, fVol, fDrift)
    // log-likelihood per regime, then normalize by the max (log-sum-exp trick):
    // relative likelihoods are identical, but values stay in [0,1] — underflow-proof
    logb = array.new_float(4, 0.0)
    maxLL = -1.0e308
    for j = 0 to 3
        ll = 0.0
        for k = 0 to 3
            ll += logpdf(array.get(feats, k), matrix.get(MU, j, k), matrix.get(SD, j, k))
        ll /= tempIn   // tempering: corrects evidence double-counting from correlated features
        array.set(logb, j, ll)
        maxLL := math.max(maxLL, ll)
    lik = array.new_float(4, 0.0)
    for j = 0 to 3
        array.set(lik, j, math.max(math.exp(array.get(logb, j) - maxLL), 1e-10))
    // predict + Bayes update:  α_t(j) ∝ b_j(o_t) · Σ_i α_{t-1}(i)·A[i][j]
    prevA = array.copy(alp)
    tot = 0.0
    for j = 0 to 3
        pr = 0.0
        for i = 0 to 3
            pr += array.get(prevA, i) * matrix.get(A, i, j)
        nj = pr * array.get(lik, j)
        array.set(alp, j, nj)
        tot += nj
    if tot > 0
        for j = 0 to 3
            array.set(alp, j, array.get(alp, j) / tot)
    else
        // degenerate state (should never happen now) — reset to uniform instead of locking at zero
        for j = 0 to 3
            array.set(alp, j, 0.25)
    // online EM: transition matrix learns from state-switch posterior
    if adaptOn and lrA > 0
        for i = 0 to 3
            rPost = array.new_float(4, 0.0)
            rTot = 0.0
            for j = 0 to 3
                v = matrix.get(A, i, j) * array.get(lik, j)
                array.set(rPost, j, v)
                rTot += v
            if rTot > 0
                w = lrA * array.get(prevA, i)
                for j = 0 to 3
                    matrix.set(A, i, j, (1.0 - w) * matrix.get(A, i, j) + w * array.get(rPost, j) / rTot)
        // regularization: prevent lock-in (cap diagonal, floor off-diagonal, renormalize)
        for i = 0 to 3
            if matrix.get(A, i, i) > 0.98
                matrix.set(A, i, i, 0.98)
            rSum = 0.0
            for j = 0 to 3
                v = math.max(matrix.get(A, i, j), 0.004)
                matrix.set(A, i, j, v)
                rSum += v
            for j = 0 to 3
                matrix.set(A, i, j, matrix.get(A, i, j) / rSum)
    // online EM: emission means (anchored to templates — prevents label switching)
    if adaptOn and lrMu > 0
        for j = 0 to 3
            g = array.get(alp, j)
            for k = 0 to 3
                mu = matrix.get(MU, j, k)
                mu += lrMu * g * (array.get(feats, k) - mu)
                mu += lrMu * 0.5 * (matrix.get(MU0, j, k) - mu)
                matrix.set(MU, j, k, mu)

// ──────────────── REGIME + CONFIDENCE (jump-penalty decoding) ───────────────
// Statistical Jump Model idea: switching regimes costs a penalty. The raw argmax
// must beat the held regime's probability by `switchMargin` for `confirmBars`
// consecutive bars — removes boundary flicker, keeps episodes persistent.
int rawReg = 0
float rawP = array.get(alp, 0)
for j = 1 to 3
    if array.get(alp, j) > rawP
        rawP := array.get(alp, j)
        rawReg := j

var int regHeld = -1
var int candReg = -1
var int candCnt = 0
if valid
    if regHeld == -1
        regHeld := rawReg
    else if rawReg != regHeld and rawP > array.get(alp, regHeld) + switchMargin
        if rawReg == candReg
            candCnt += 1
        else
            candReg := rawReg
            candCnt := 1
        if candCnt >= confirmBars
            regHeld := rawReg
            candReg := -1
            candCnt := 0
    else
        candReg := -1
        candCnt := 0

int regime = regHeld == -1 ? rawReg : regHeld
float conf = array.get(alp, regime)

// ─────────────────────────────── STATISTICS ─────────────────────────────────
var int  regAge   = 0
var int  switches = 0
var bool started  = false
var array<int>   barsIn = array.new_int(4, 0)
var array<int>   eps    = array.new_int(4, 0)
var array<float> cumRet = array.new_float(4, 0.0)
bool changed = false

if valid
    if not started
        started := true
        array.set(eps, regime, array.get(eps, regime) + 1)
    else if regime != regime[1]
        changed := true
        switches += 1
        regAge := 0
        array.set(eps, regime, array.get(eps, regime) + 1)
    else
        regAge += 1
    array.set(barsIn, regime, array.get(barsIn, regime) + 1)
    if not na(ret)
        array.set(cumRet, regime, array.get(cumRet, regime) + ret)

int totBars = array.get(barsIn, 0) + array.get(barsIn, 1) + array.get(barsIn, 2) + array.get(barsIn, 3)
float avgDur = 1.0 * array.get(barsIn, regime) / math.max(array.get(eps, regime), 1)
float avgBps = array.get(barsIn, regime) > 0 ? array.get(cumRet, regime) / array.get(barsIn, regime) * 10000 : 0.0

// most likely next regime (from the learned transition matrix)
int nlIdx = -1
float nlP = -1.0
for j = 0 to 3
    if j != regime and matrix.get(A, regime, j) > nlP
        nlP := matrix.get(A, regime, j)
        nlIdx := j

// stationary distribution π (power iteration on the learned A)
statPi = array.from(0.25, 0.25, 0.25, 0.25)
if valid and barstate.islast
    for it = 1 to 40
        nxt = array.new_float(4, 0.0)
        for j = 0 to 3
            s = 0.0
            for i = 0 to 3
                s += array.get(statPi, i) * matrix.get(A, i, j)
            array.set(nxt, j, s)
        statPi := nxt

// ─────────────────────────────── VISUALS ────────────────────────────────────
// chart background by regime — opacity scales with confidence
bgcolor(showBg and valid ? color.new(regCol(regime), 94 - int(conf * 19)) : na, force_overlay = true)

// label at regime-change bar (confirmed bars only — no repaint)
if showLbl and changed and barstate.isconfirmed
    bool dwn = regime == 1
    label.new(bar_index, dwn ? low : high, regIcon(regime) + " " + regName(regime) + "  " + str.tostring(conf * 100, "#") + "%", xloc.bar_index, dwn ? yloc.belowbar : yloc.abovebar, color.new(regCol(regime), 15), dwn ? label.style_label_up : label.style_label_down, color.white, size.small, force_overlay = true)

// pane: confidence (area in regime color) + all 4 regime probabilities — full on/off toggle in settings
plot(valid and showPane ? conf * 100 : na, "Confidence", color.new(regCol(regime), 72), 1, plot.style_area)
plot(valid and showPane ? conf * 100 : na, "Confidence line", regCol(regime), 2)
plot(valid and showPane ? array.get(alp, 0) * 100 : na, "P(Bull)", color.new(cBull, 25), 1)
plot(valid and showPane ? array.get(alp, 1) * 100 : na, "P(Bear)", color.new(cBear, 25), 1)
plot(valid and showPane ? array.get(alp, 2) * 100 : na, "P(Ranging)", color.new(cRange, 25), 1)
plot(valid and showPane ? array.get(alp, 3) * 100 : na, "P(HighVol)", color.new(cHiVol, 25), 1)
hline(80, "High confidence", color.new(COL_ACC, 50), hline.style_dotted, display = showPane ? display.all : display.none)
hline(50, "Mid", color.new(color.gray, 60), hline.style_dotted, display = showPane ? display.all : display.none)
hline(25, "Uniform prior", color.new(color.gray, 75), hline.style_dotted, display = showPane ? display.all : display.none)

// ─────────────────────────────── DASHBOARD ──────────────────────────────────
posTbl = posIn == "top_right" ? position.top_right : posIn == "top_left" ? position.top_left : posIn == "bottom_right" ? position.bottom_right : position.bottom_left
tSz  = sizeIn == "tiny" ? size.tiny : sizeIn == "small" ? size.small : size.normal
tSzS = sizeIn == "normal" ? size.small : size.tiny

f_row(table tb, int r, string lab, string val, color vc, string sz, string szs) =>
    table.cell(tb, 0, r, lab, text_color = COL_LAB, text_size = szs, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tb, 1, r, val, text_color = vc, text_size = sz, text_halign = text.align_right, text_font_family = font.family_monospace)

f_sec(table tb, int r, string txt, string szs) =>
    table.cell(tb, 0, r, txt, text_color = color.new(COL_ACC, 35), text_size = szs, text_halign = text.align_center)

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(posTbl, 2, 24, bgcolor = color.new(COL_BG, 8), frame_color = COL_BRD, frame_width = 1, border_color = color.new(COL_BRD, 55), border_width = 1, force_overlay = true)
        table.merge_cells(dash, 0, 0, 1, 0)
        table.merge_cells(dash, 0, 3, 1, 3)
        table.merge_cells(dash, 0, 8, 1, 8)
        table.merge_cells(dash, 0, 18, 1, 18)
        table.merge_cells(dash, 0, 23, 1, 23)
    table.cell(dash, 0, 0, "🤖 AI REGIME DETECTION", text_color = COL_ACC, text_size = tSz, text_halign = text.align_center, bgcolor = color.new(#000000, 25), text_font_family = font.family_monospace)
    table.cell(dash, 0, 1, "REGIME", text_color = COL_LAB, text_size = tSzS, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(dash, 1, 1, regIcon(regime) + " " + regName(regime), text_color = regCol(regime), text_size = tSz, text_halign = text.align_right, bgcolor = color.new(regCol(regime), 86), text_font_family = font.family_monospace)
    f_row(dash, 2, "CONFIDENCE", barStr(conf) + " " + str.tostring(conf * 100, "#") + "%", conf > 0.7 ? #00E676 : conf > 0.45 ? #FFD54F : #FF8A65, tSz, tSzS)
    f_sec(dash, 3, "── PROBABILITIES ──", tSzS)
    for j = 0 to 3
        pj = array.get(alp, j)
        f_row(dash, 4 + j, regIcon(j) + " " + regName(j), barStr(pj) + " " + str.tostring(pj * 100, "#0.0") + "%", j == regime ? regCol(j) : color.new(regCol(j), 45), tSz, tSzS)
    f_sec(dash, 8, "── STATISTICS ──", tSzS)
    f_row(dash, 9,  "VOLATILITY",  str.tostring(rv * 100, "#.##") + "%  P" + str.tostring(volPR, "#"), volPR > 80 ? cHiVol : COL_VAL, tSz, tSzS)
    f_row(dash, 10, "TREND CORR",  (fTrend >= 0 ? "+" : "") + str.tostring(fTrend, "#.##"), fTrend > 0.3 ? cBull : fTrend < -0.3 ? cBear : COL_VAL, tSz, tSzS)
    f_row(dash, 11, "REGIME AGE",  str.tostring(regAge) + " bars", COL_VAL, tSz, tSzS)
    f_row(dash, 12, "Ø DURATION",  str.tostring(avgDur, "#.#") + " bars", COL_VAL, tSz, tSzS)
    f_row(dash, 13, "Ø RET/BAR",   (avgBps >= 0 ? "+" : "") + str.tostring(avgBps, "#.#") + " bps", avgBps >= 0 ? cBull : cBear, tSz, tSzS)
    f_row(dash, 14, "SWITCHES",    str.tostring(switches), COL_VAL, tSz, tSzS)
    f_row(dash, 15, "NEXT LIKELY", nlIdx >= 0 ? regIcon(nlIdx) + " " + regName(nlIdx) + "  " + str.tostring(nlP * 100, "#.#") + "%" : "—", nlIdx >= 0 ? regCol(nlIdx) : COL_VAL, tSz, tSzS)
    distStr = ""
    statStr = ""
    for j = 0 to 3
        distStr += regIcon(j) + str.tostring(totBars > 0 ? 100.0 * array.get(barsIn, j) / totBars : 0, "#") + " "
        statStr += regIcon(j) + str.tostring(array.get(statPi, j) * 100, "#") + " "
    f_row(dash, 16, "TIME DIST",  distStr + "%", COL_VAL, tSzS, tSzS)
    f_row(dash, 17, "LONG-RUN π", statStr + "%", COL_VAL, tSzS, tSzS)
    if showMtx
        f_sec(dash, 18, "── TRANSITION MATRIX ──", tSzS)
        for i = 0 to 3
            rowS = ""
            for j = 0 to 3
                rowS += str.tostring(matrix.get(A, i, j), "0.00") + " "
            f_row(dash, 19 + i, regIcon(i) + "→", rowS, i == regime ? regCol(i) : COL_LAB, tSzS, tSzS)
    table.cell(dash, 0, 23, "MARKOV HMM · " + (useLor ? "LORENTZIAN" : "GAUSSIAN") + " KERNEL · ONLINE EM", text_color = color.new(COL_LAB, 25), text_size = size.tiny, text_halign = text.align_center)

// ─────────────────────────────── ALERTS ─────────────────────────────────────
alertcondition(changed, "Regime Change", "AI Regime Detection: regime changed")
alertcondition(changed and regime == 0, "Bull Trend Regime", "AI Regime: BULL TREND")
alertcondition(changed and regime == 1, "Bear Trend Regime", "AI Regime: BEAR TREND")
alertcondition(changed and regime == 2, "Ranging Regime", "AI Regime: RANGING")
alertcondition(changed and regime == 3, "High Vol Regime", "AI Regime: HIGH VOLATILITY")
````
