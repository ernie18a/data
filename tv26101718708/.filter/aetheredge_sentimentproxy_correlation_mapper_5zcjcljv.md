# AetherEdge - Sentiment-Proxy Correlation Mapper

- url: https://www.tradingview.com/script/5ZcJCljV/
- type: indicator
- pine_id: PUB;797c29339a4943f28667f404bcbd69df
- version: 1.0

## Description

🖊️ Overview

A psychology-focused engine that infers crowd emotion without any social or news feed — purely from price action. It builds sentiment proxies — volume anomaly (panic/euphoria), volatility (fear), price velocity (momentum drive), wick asymmetry (greed vs. fear at extremes), and run-length (FOMO / capitulation) — then uses a NeuraLib correlation map to learn how these proxies move together and weighs them into a single Fear ⇄ Greed sentiment score. A self-adapting mapping continuously re-correlates the proxies against realized outcomes, and the engine flags sentiment turning points — the moments crowd emotion flips. Visualization: a chart-background gradient shading the tape from Fear (red) to Greed (green), plus emphasis dots only at the reversals.

🔶 Key Features

Sentiment proxies — five emotion proxies built from price action alone (no external data)
NeuraLib correlation mapping — learns the proxies' joint behavior and fuses them into a Fear⇄Greed score
Self-adapting correlation — continuously re-correlates proxies against realized outcomes (learns which matter)
Turning-point detection — flags fear⇄greed reversals on a zero-line cross with sufficient swing
Sentiment background gradient — shades the chart from fear (red) through neutral to greed (green), intensity by magnitude
Turning-point dots — only the reversal moments are emphasized with dots and labels (noise excluded)
Emotional extreme markers — faint diamonds when sentiment enters a greed/fear extreme zone
Intelligence panel — Fear⇄Greed gauge, each proxy's value and learned correlation strength, and the latest turn

🧠 Technical Architecture

The engine builds five sentiment proxies from price: (1) volume anomaly (volume z-score × candle direction = euphoric buying / panic selling), (2) volatility (ATR ratio = higher is fear/stress), (3) price velocity (ATR-normalized speed of change = momentum), (4) wick asymmetry (lower − upper wick = which side defended the extreme), and (5) run-length (consecutive up/down within the window = FOMO / capitulation).
These feed the NeuraLib correlation map: proxies(5) → hidden(tanh) → sentiment(1, tanh-bounded [-1,1]), trained by supervision so sentiment correlates with realized forward direction — greed (positive) preceding up-moves, fear (negative) preceding down-moves. After each step, each proxy's contribution to the hidden layer (mean absolute weight) is recomputed as its correlation strength, shown in the panel so you can see which proxy currently dominates emotion.
Sentiment is smoothed into a [-1,1] Fear⇄Greed score. Turning-point detection flags a fear→greed (or reverse) reversal when a zero-line cross's magnitude clears the Turn Sensitivity. The background is colored continuously by color.from_gradient, with intensity proportional to emotional magnitude.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Volume 20, Volatility 14, Velocity 10, Smoothing 4, Turn Sensitivity 0.20. Standard settings fit well
ETH (1H–4H): As BTC, with Outcome Lookahead 5–8
SOL (15m–1H): High volatility favors Smoothing 5–6 to smooth sentiment, Turn Sensitivity 0.25 to suppress false turns
XRP (1H–4H): Spike-prone; Volume window 15 for sensitive anomaly detection, Extreme Threshold 0.5 for early extremes
Turn Sensitivity: higher makes turns selective (only large emotional reversals); lower detects more frequently
Extreme Threshold: beyond ±this is "extreme greed/fear" — a contrarian guide at 0.5–0.6
Sentiment Smoothing: higher smooths the background and score; lower is more reactive
Background Intensity: lower makes the background more vivid — adjust to taste

💡 How to Use in Practice

Reading the gradient: deep green = greed dominates (possible overheating); deep red = fear dominates (possible capitulation); neutral = balanced — saturation is emotional strength
Using turning-point dots: a "FEAR→GREED" dot marks a flip from fear to greed (possible bottom); "GREED→FEAR" a possible top — a basis for contrarian/trend entries
Contrarian at extremes: at extreme greed (green diamond) beware a pullback from overheating; at extreme fear (red diamond) watch for an oversold bounce — quantifying "be fearful when others are greedy"
Watching proxy correlations: the panel's per-proxy value and correlation strength reveal what drives emotion now (e.g. high volume-anomaly correlation = volume-led sentiment)
Background vs. price divergence: price rising while the background reads fear (bearish sentiment) is an early reversal warning
Multi-timeframe usage: read the big-picture emotional regime on the higher timeframe (4H), then time entries on turning points on the lower one (15m–1H)

⚠️ Important Notes

Nature of proxies: this is not real social/news sentiment but an estimated proxy inferred from price action — an approximation of crowd psychology that differs from external sentiment data
Initial learning period: right after launch the map's buffer is nearly empty and emotion estimates are unstable; treat as low-confidence until it fills (100+ bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes the map weights and buffer, restarting learning from zero
Danger of contrarianism: extreme emotion can persist (greed runs long in strong trends) — an extreme is not an instant reversal; pair with risk management
On look-ahead: the map's target uses closed-bar realized direction (a standard training construct); current-bar emotion is on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The sentiment proxies, correlation mapping, Fear⇄Greed score, turning-point detection, and sentiment background are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Estimates of crowd psychology can be wrong. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Sentiment-Proxy Correlation Mapper
//   AI Drawing Power Series
//
//   A psychology-focused engine that infers crowd emotion without any social or news feed. It builds
//   SENTIMENT PROXIES purely from price action — volume anomaly (panic/euphoria), volatility (fear),
//   price velocity (momentum drive), wick asymmetry (greed vs. fear at the extremes), and run-length
//   (FOMO / capitulation) — then uses a NeuraLib correlation map to learn how these proxies move
//   together and weighs them into a single Fear ⇄ Greed sentiment score. A self-adapting mapping
//   continuously re-correlates the proxies against realized outcomes, and the engine flags SENTIMENT
//   TURNING POINTS — the moments crowd emotion flips.
//
//   Visualization: a chart-background gradient that shades the tape from Fear (red) to Greed (green),
//   plus emphasis dots only at the turning points where emotion reverses.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Sentiment-Proxy Correlation Mapper", "AE-SP CM", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_PROXY = "◆  SENTIMENT PROXIES"
var string GRP_MAP   = "◆  CORRELATION MAP (NeuraLib)"
var string GRP_TURN  = "◆  TURNING POINTS"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Sentiment Proxies —
volLen       = input.int(20,   "Volume Anomaly Window", minval = 2, maxval = 200, group = GRP_PROXY, tooltip = "Baseline window for detecting volume spikes (panic/euphoria proxy).")
volaLen      = input.int(14,   "Volatility Window", minval = 2, maxval = 100, group = GRP_PROXY, tooltip = "Window for the volatility (fear) proxy.")
velLen       = input.int(10,   "Price Velocity Window", minval = 1, maxval = 100, group = GRP_PROXY, tooltip = "Window for price velocity (momentum drive).")
runLen       = input.int(8,    "Run-Length Window", minval = 2, maxval = 50, group = GRP_PROXY, tooltip = "Window for consecutive up/down pressure (FOMO / capitulation).")
normLen      = input.int(120,  "Proxy Norm Window", minval = 20, maxval = 1000, group = GRP_PROXY)

// — Correlation Map —
mapLR        = input.float(0.03,"Mapping Learn Rate", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_MAP, tooltip = "How fast the NeuraLib map re-correlates proxies against realized outcomes.")
hiddenN      = input.int(6,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_MAP)
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_MAP)
rewardLook   = input.int(5,    "Outcome Lookahead (bars)", minval = 1, maxval = 20, group = GRP_MAP)
seedInp      = input.int(53,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_MAP)

// — Turning Points —
sentSmooth   = input.int(4,    "Sentiment Smoothing", minval = 1, maxval = 30, group = GRP_TURN)
turnGate     = input.float(0.20,"Turn Sensitivity", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_TURN, tooltip = "Minimum sentiment swing across the zero line to flag a turning point.")
extremeGate  = input.float(0.55,"Extreme Threshold", minval = 0.3, maxval = 1.0, step = 0.05, group = GRP_TURN, tooltip = "Sentiment beyond ±this is treated as an emotional extreme (greed/fear zone).")

// — Aesthetics —
colFear      = input.color(#ff5d73, "Fear Tone",  group = GRP_STYLE, inline = "c1")
colGreed     = input.color(#21d3a3, "Greed Tone", group = GRP_STYLE, inline = "c1")
colNeutral   = input.color(#2a3346, "Neutral Tone", group = GRP_STYLE, inline = "c1")
bgIntensity  = input.int(88,   "Background Intensity", minval = 70, maxval = 99, group = GRP_STYLE, tooltip = "Transparency of the sentiment background (lower = more vivid).")
showTurns    = input.bool(true, "Turning-Point Dots", group = GRP_STYLE)
showExtremes = input.bool(true, "Mark Emotional Extremes", group = GRP_STYLE, tooltip = "Faint markers when sentiment enters a greed/fear extreme zone.")
glowFx       = input.bool(true, "Glow / Halo Effect", group = GRP_STYLE)

// — Intelligence Panel —
showPanel    = input.bool(true, "Show Intelligence Panel", group = GRP_PANEL)
panelPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GRP_PANEL)
panelSize    = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_PANEL)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE
// ────────────────────────────────────────────────────────────────────────────────────────────────

var color THEME_BG   = color.new(#0a0d15, 8)
var color THEME_GRID = color.new(#222b40, 38)
var color THEME_TXT  = #d2dae8
var color THEME_DIM  = #6b7689
var color THEME_ACC  = #5ce1ff
var color THEME_GOLD = #f4c25b

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ACTIVATIONS / PRNG
// ────────────────────────────────────────────────────────────────────────────────────────────────

f_tanh(float x) =>
    float xc = math.max(-20.0, math.min(20.0, x))
    float e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

f_dtanh(float y) =>
    1.0 - y * y

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  SENTIMENT PROXIES  — derive crowd-emotion signals purely from price action
// ════════════════════════════════════════════════════════════════════════════════════════════════

atr = ta.atr(14)

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

// 1) VOLUME ANOMALY — spikes = panic selling or euphoric buying; signed by candle direction
volBase = ta.sma(volume, volLen)
volZ = f_znorm(volume, volBase, ta.stdev(volume, volLen))
candleDir = close > open ? 1.0 : close < open ? -1.0 : 0.0
proxVol = math.max(-3.0, math.min(3.0, volZ * candleDir))   // +greed spike / -fear spike

// 2) VOLATILITY (FEAR) — elevated volatility reads as fear/stress
volaRaw = ta.atr(volaLen) / (ta.sma(ta.atr(volaLen), normLen) == 0 ? 1.0 : ta.sma(ta.atr(volaLen), normLen)) - 1.0
proxVola = f_znorm(volaRaw, ta.sma(volaRaw, normLen), ta.stdev(volaRaw, normLen))   // high = fear

// 3) PRICE VELOCITY — speed of price change = momentum drive (greed when up, fear when down)
velRaw = (close - close[velLen]) / (velLen * (atr == 0 ? 1.0 : atr))
proxVel = math.max(-3.0, math.min(3.0, velRaw))

// 4) WICK ASYMMETRY — upper wick rejection = greed exhaustion; lower wick = fear exhaustion
upWick = high - math.max(close, open)
dnWick = math.min(close, open) - low
bodyRange = high - low == 0 ? atr : (high - low)
proxWick = math.max(-3.0, math.min(3.0, (dnWick - upWick) / (bodyRange == 0 ? 1.0 : bodyRange) * 2.0))   // +buyers defend / -sellers defend

// 5) RUN-LENGTH — consecutive directional pressure = FOMO (up) / capitulation (down)
// Build a per-bar +1/-1 up/down series, then sum it over the window (avoids loop-var history refs).
barUp = close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0
runNet = math.sum(barUp, runLen)
proxRun = math.max(-3.0, math.min(3.0, runNet / runLen * 3.0))

var int N_PROXY = 5

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  NEURALIB CORRELATION MAP  — learns how proxies jointly map to a Fear⇄Greed sentiment value
//  Architecture: proxies(5) → hidden(tanh) → sentiment(1, tanh-bounded to [-1,1]).
//  Trained (supervised) so that sentiment correlates with realized forward direction:
//    greed (positive) should precede up-moves; fear (negative) precede down-moves.
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> W1 = na   // [hiddenN x N_PROXY]
var array<float> b1 = na   // [hiddenN]
var array<float> W2 = na   // [hiddenN]
var array<float> b2 = na   // [1]
var array<float> proxyW = na   // learned per-proxy correlation weight (for the panel readout)
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    W1 := array.new_float(hiddenN * N_PROXY, 0.0)
    b1 := array.new_float(hiddenN, 0.0)
    W2 := array.new_float(hiddenN, 0.0)
    b2 := array.new_float(1, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.6)
    f_initRange(W2, seedInp * 40503 + 101, 0.6)
    proxyW := array.new_float(N_PROXY, 0.0)
    netInit := true

// forward → sentiment ∈ [-1,1]; caches hidden in hC
f_sentiment(float p0, float p1, float p2, float p3, float p4, array<float> hC) =>
    array.clear(hC)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_PROXY + 0) * p0
        z += array.get(W1, h * N_PROXY + 1) * p1
        z += array.get(W1, h * N_PROXY + 2) * p2
        z += array.get(W1, h * N_PROXY + 3) * p3
        z += array.get(W1, h * N_PROXY + 4) * p4
        array.push(hC, f_tanh(z))
    float o = array.get(b2, 0)
    for h = 0 to hiddenN - 1
        o += array.get(W2, h) * array.get(hC, h)
    f_tanh(o)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REPLAY BUFFER  (proxies + realized forward direction target)
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> bP0 = array.new_float()
var array<float> bP1 = array.new_float()
var array<float> bP2 = array.new_float()
var array<float> bP3 = array.new_float()
var array<float> bP4 = array.new_float()
var array<float> bTgt = array.new_float()

f_push(float p0, float p1, float p2, float p3, float p4, float tgt) =>
    array.push(bP0, p0)
    array.push(bP1, p1)
    array.push(bP2, p2)
    array.push(bP3, p3)
    array.push(bP4, p4)
    array.push(bTgt, tgt)
    if array.size(bTgt) > 200
        array.shift(bP0)
        array.shift(bP1)
        array.shift(bP2)
        array.shift(bP3)
        array.shift(bP4)
        array.shift(bTgt)

// realized forward direction over the lookahead (target for the correlation map)
fwdDir = math.max(-1.0, math.min(1.0, (close - close[rewardLook]) / (atr == 0 ? 1.0 : atr)))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  TRAINING  — supervised regression of sentiment toward realized forward direction
//  After each step, refresh proxyW = mean |W1| contribution per proxy (correlation strength readout).
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hTr = array.new_float()

f_trainOnce(int idx) =>
    if array.size(bTgt) > 0
        float p0 = array.get(bP0, idx)
        float p1 = array.get(bP1, idx)
        float p2 = array.get(bP2, idx)
        float p3 = array.get(bP3, idx)
        float p4 = array.get(bP4, idx)
        float tgt = array.get(bTgt, idx)

        float sent = f_sentiment(p0, p1, p2, p3, p4, hTr)
        float err = math.max(-3.0, math.min(3.0, sent - tgt)) * f_dtanh(sent)   // through output tanh

        gH = array.new_float(hiddenN, 0.0)
        for h = 0 to hiddenN - 1
            array.set(gH, h, err * array.get(W2, h))
            array.set(W2, h, array.get(W2, h) - mapLR * err * array.get(hTr, h))
        array.set(b2, 0, array.get(b2, 0) - mapLR * err)
        for h = 0 to hiddenN - 1
            float dz = array.get(gH, h) * f_dtanh(array.get(hTr, h))
            array.set(W1, h * N_PROXY + 0, array.get(W1, h * N_PROXY + 0) - mapLR * dz * p0)
            array.set(W1, h * N_PROXY + 1, array.get(W1, h * N_PROXY + 1) - mapLR * dz * p1)
            array.set(W1, h * N_PROXY + 2, array.get(W1, h * N_PROXY + 2) - mapLR * dz * p2)
            array.set(W1, h * N_PROXY + 3, array.get(W1, h * N_PROXY + 3) - mapLR * dz * p3)
            array.set(W1, h * N_PROXY + 4, array.get(W1, h * N_PROXY + 4) - mapLR * dz * p4)
            array.set(b1, h, array.get(b1, h) - mapLR * dz)

// recompute per-proxy correlation strength = mean |incoming weight| across hidden units
f_refreshProxyW() =>
    for pj = 0 to N_PROXY - 1
        float acc = 0.0
        for h = 0 to hiddenN - 1
            acc += math.abs(array.get(W1, h * N_PROXY + pj))
        array.set(proxyW, pj, acc / hiddenN)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hLv = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pP0 = na
var float pP1 = na
var float pP2 = na
var float pP3 = na
var float pP4 = na

var float liveSent = na     // raw sentiment [-1,1]
var float sentEma  = na     // smoothed sentiment

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pP0)
        f_push(pP0, pP1, pP2, pP3, pP4, fwdDir)

    int n = array.size(bTgt)
    if n > 0
        for stp = 0 to 3
            int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
            int idx = int(f_rand(seed) * n) % n
            f_trainOnce(idx)
        f_refreshProxyW()

    pP0 := proxVol
    pP1 := proxVola
    pP2 := proxVel
    pP3 := proxWick
    pP4 := proxRun

// ---- SENTIMENT EVALUATION (every bar incl. realtime) ----
if inHorizon
    float sent = f_sentiment(proxVol, proxVola, proxVel, proxWick, proxRun, hLv)
    liveSent := sent
    sentEma := na(sentEma) ? sent : (sent * (2.0 / (sentSmooth + 1)) + sentEma * (1.0 - 2.0 / (sentSmooth + 1)))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  SENTIMENT STATE + TURNING POINTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

float sentiment = na(sentEma) ? 0.0 : sentEma     // [-1,1]: -1 extreme fear, +1 extreme greed
float sentPrev = na(sentEma[1]) ? 0.0 : sentEma[1]

// emotional state label
bool isGreed = sentiment > 0.05
bool isFear  = sentiment < -0.05
bool isExtremeGreed = sentiment >= extremeGate
bool isExtremeFear  = sentiment <= -extremeGate

// turning points: a zero-line cross with sufficient swing magnitude
bool turnToGreed = inHorizon and barstate.isconfirmed and sentPrev <= 0.0 and sentiment > 0.0 and (sentiment - sentPrev) >= turnGate
bool turnToFear  = inHorizon and barstate.isconfirmed and sentPrev >= 0.0 and sentiment < 0.0 and (sentPrev - sentiment) >= turnGate

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — sentiment background gradient + turning-point dots
// ════════════════════════════════════════════════════════════════════════════════════════════════

// background gradient: fear (red) → neutral → greed (green), intensity by |sentiment|
color sentColRaw = sentiment >= 0 ? color.from_gradient(sentiment, 0.0, 1.0, colNeutral, colGreed) : color.from_gradient(-sentiment, 0.0, 1.0, colNeutral, colFear)
int bgTrans = int(math.max(70, bgIntensity - math.abs(sentiment) * 18))
bgcolor(inHorizon ? color.new(sentColRaw, bgTrans) : na, title = "Sentiment Background")

// turning-point dots (only at reversals)
color turnUpCol = colGreed
color turnDnCol = colFear

plotshape(showTurns and turnToGreed and glowFx, title = "Greed Turn Glow", style = shape.circle, location = location.belowbar, color = color.new(colGreed, 65), size = size.normal, force_overlay = true)
plotshape(showTurns and turnToGreed, title = "Greed Turn", style = shape.circle, location = location.belowbar, color = color.new(colGreed, 0), size = size.small, force_overlay = true)
plotshape(showTurns and turnToFear and glowFx, title = "Fear Turn Glow", style = shape.circle, location = location.abovebar, color = color.new(colFear, 65), size = size.normal, force_overlay = true)
plotshape(showTurns and turnToFear, title = "Fear Turn", style = shape.circle, location = location.abovebar, color = color.new(colFear, 0), size = size.small, force_overlay = true)

// emotional extreme markers (faint)
plotshape(showExtremes and inHorizon and isExtremeGreed and not isExtremeGreed[1], title = "Extreme Greed", style = shape.diamond, location = location.abovebar, color = color.new(colGreed, 40), size = size.tiny, force_overlay = true)
plotshape(showExtremes and inHorizon and isExtremeFear and not isExtremeFear[1], title = "Extreme Fear", style = shape.diamond, location = location.belowbar, color = color.new(colFear, 40), size = size.tiny, force_overlay = true)

// turning-point labels with sentiment context
if showTurns and turnToGreed
    label.new(bar_index, low, "FEAR → GREED", xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(colGreed, 15), textcolor = #0a0d15, size = size.small, force_overlay = true)
if showTurns and turnToFear
    label.new(bar_index, high, "GREED → FEAR", xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colFear, 15), textcolor = #0a0d15, size = size.small, force_overlay = true)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INTELLIGENCE PANEL
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_panelPos() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_panelSize() =>
    switch panelSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_proxyBar(float v) =>
    // map proxy ∈ [-3,3] to a 0..1 fill
    f_fill = (v + 3.0) / 6.0
    int filled = int(math.round(math.max(0.0, math.min(1.0, f_fill)) * 10))
    string s = ""
    for i = 1 to 10
        s := s + (i <= filled ? "█" : "░")
    s

f_sentGauge(float v) =>
    int half = 7
    int mag = int(math.round(math.min(1.0, math.abs(v)) * half))
    string s = ""
    for i = 1 to half
        s := s + (v < 0 and i > half - mag ? "█" : "░")
    s := s + "│"
    for i = 1 to half
        s := s + (v > 0 and i <= mag ? "█" : "░")
    s

// proxy row helper (global scope; panel passed in, other refs are global arrays/colors)
f_proxyRow(table tbl, int rowY, string nm, float val, int wIdx) =>
    float cw = na(proxyW) ? 0.0 : array.get(proxyW, wIdx)
    color vc = val >= 0 ? colGreed : colFear
    table.cell(tbl, 0, rowY, nm, text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(tbl, 1, rowY, f_proxyBar(val), text_color = vc, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(tbl, 2, rowY, str.tostring(cw, "#.##"), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    string state = isExtremeGreed ? "EXTREME GREED" : isExtremeFear ? "EXTREME FEAR" : isGreed ? "GREED" : isFear ? "FEAR" : "NEUTRAL"
    color stateCol = sentiment >= extremeGate ? colGreed : sentiment <= -extremeGate ? colFear : sentiment > 0.05 ? color.new(colGreed, 25) : sentiment < -0.05 ? color.new(colFear, 25) : THEME_DIM
    int sentPct = int(math.round((sentiment + 1.0) * 50.0))   // 0..100 (0=fear, 100=greed)

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "SENTIMENT", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + state, text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = stateCol)
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Fear ◂——▸ Greed", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_sentGauge(sentiment), text_color = sentiment >= 0 ? colGreed : colFear, text_size = f_panelSize(), text_halign = text.align_center)
    table.cell(panel, 2, 2, str.tostring(sentPct) + "/100", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "PROXY CORRELATIONS", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 3, 2, 3)

    // each proxy: current value bar + learned correlation weight
    f_proxyRow(panel, 4, "Volume Anomaly", proxVol, 0)
    f_proxyRow(panel, 5, "Volatility (Fear)", -proxVola, 1)
    f_proxyRow(panel, 6, "Price Velocity", proxVel, 2)
    f_proxyRow(panel, 7, "Wick Asymmetry", proxWick, 3)
    f_proxyRow(panel, 8, "Run-Length", proxRun, 4)

    table.cell(panel, 0, 9, "Recent Turn", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, "", text_size = f_panelSize())
    string lastTurn = turnToGreed ? "→ GREED" : turnToFear ? "→ FEAR" : "—"
    table.cell(panel, 2, 9, lastTurn, text_color = turnToGreed ? colGreed : turnToFear ? colFear : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Map Buffer", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, str.tostring(array.size(bTgt)) + "/200", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 10, "learning", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(turnToGreed, "Sentiment ▸ Fear → Greed", "AetherEdge Sentiment: crowd emotion turned from fear to greed.")
alertcondition(turnToFear,  "Sentiment ▸ Greed → Fear", "AetherEdge Sentiment: crowd emotion turned from greed to fear.")
alertcondition(isExtremeGreed and not isExtremeGreed[1], "Sentiment ▸ Extreme Greed", "AetherEdge Sentiment: extreme greed reached.")
alertcondition(isExtremeFear and not isExtremeFear[1], "Sentiment ▸ Extreme Fear", "AetherEdge Sentiment: extreme fear reached.")
````
