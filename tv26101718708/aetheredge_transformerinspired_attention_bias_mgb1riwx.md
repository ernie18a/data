# AetherEdge - Transformer-Inspired Attention Bias

- url: https://www.tradingview.com/script/Mgb1RIwX/
- type: indicator
- pine_id: PUB;8180501caed6425090e730c225e2a009
- version: 1.0

## Description

🖊️ Overview
A Transformer-style attention mechanism rendered in Pine — an engine for the selective focus of memory. Just as a Transformer attends selectively to the most relevant elements of a sequence, this engine treats the current bar as a query and every recent bar as a key/value. It scores each past bar's relevance via scaled dot-product (Q·Kᵀ/√d), normalizes the scores with softmax, and forms a weighted blend of those bars' directional signals — automatically focusing on the past patterns that matter most right now to compute the current bias (bullish/bearish). Several heads run in parallel, each learning a different notion of relevance, then merge into one directional bias. Visualization: an Attention Heatbar across the top of the chart (a horizontal strip whose brightness shows how much attention each point in recent time receives) plus one main bias arrow — a Transformer-style "selective focus of memory" in Pine.
🔶 Key Features

Multi-head attention — scaled dot-product attention (Q·Kᵀ/√d → softmax → ·V) reproduced in Pine
Selective focus of memory — automatically focuses on important past bars while suppressing noisy ones
Multiple heads — heads learn different relevance notions in parallel, merging into one bias
Positional encoding — an optional recency signal so the model knows how far back each bar is
Attention Heatbar — visualizes time-axis importance as a horizontal strip above price (brighter = more attention, tinted by bias)
Main bias arrow — the post-attention directional bias shown as one arrow (with glow)
Temperature parameter — softmax temperature tunes between sharp focus on a single bar and diffuse attention
Intelligence panel — attention bias, focus sharpness and distance (how far back focus sits), head count, context length, and more

🧠 Technical Architecture
Each bar is encoded into a small feature "token": momentum, RSI deviation, one-bar return, and range width (all normalized). Each bar is also assigned a directional "value" value = tanh(...) capturing its bullish/bearish lean.
The core is multi-head attention. The current bar's token is projected by Wq into a d-dim query q; each of the past ctxLen bars' tokens is projected by Wk into kᵢ. Attention scores are the scaled dot-product score_i = (q·kᵢ)/√d / temperature, where √d scaling ensures gradient stability. With positional encoding enabled, a recency signal is added to the keys. The scores are normalized by softmax into weights wᵢ, and the past bars' values are blended as Σ wᵢ·valueᵢ — that head's bias. Since each head has distinct projection weights, each captures a different relevance, merged via head output weights Wo.
A key implementation detail: Pine's [] history operator cannot take a loop variable, so past tokens are accumulated into rolling arrays and accessed dynamically via array.get(idx). Attention weights are aggregated into time-axis buckets and shown, normalized, as the Attention Heatbar (a brighter cell = stronger attention to that bar). The final bias is EMA-smoothed, and the main arrow fires when it clears the gate.
⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Context Window 40, Heads 3, Key Dim 4, Temperature 1.0. Standard settings fit well
ETH (1H–4H): As BTC, with Context Window 50 for slightly longer memory
SOL (15m–1H): High volatility favors Temperature ≈ 0.7 for sharp focus, Heads 4 to capture diverse relevance
XRP (1H–4H): Spike-prone; Context Window ≈ 30 to emphasize recency, Position Encoding ON
Context Window: longer references further back but is heavier; 30–60 is practical
Heads: more captures more relevance notions but adds compute; 2–4 is readable
Temperature: low (0.5–0.8) sharply focuses on the single most relevant bar; high (1.5–3) gives diffuse, smooth attention
Min |Bias| to Signal: higher makes arrows more selective — tune to your trade frequency

💡 How to Use in Practice

Reading the Heatbar: a bright cell means that bar strongly drives the current bias. Bright on the right (recent) = short-term pattern leads; bright on the left (older) = a past important moment is recurring
Reacting to the main arrow: the arrow is the verdict where multi-head attention's merged bias clears the gate — a core basis for trend-following entries
Using focus distance: small panel "Focus Distance" = recency-driven; large = attending to far-back patterns, suggesting recurrence of a past analog
Focus sharpness: high = attention concentrated on one point (clear pattern recognition); low = diffuse (ambiguous)
Pairing with temperature: if the heatbar is wide and faint, lower the temperature to sharpen focus and clarify what the engine attends to
Multi-timeframe usage: confirm the big-picture bias on the higher timeframe (4H), then refine timing on arrows on the lower one (15m–1H)

⚠️ Important Notes

Initial context period: attention is incomplete until the context window (ctxLen) fills; treat the bias as low-confidence until enough past bars accumulate
Effect of setting changes: changing parameters, switching symbol/timeframe, or recompiling reinitializes the projection weights and token history
On learning: the projection weights are seed-initialized fixed weights used to compute attention patterns; this tool does not update weights from reward — it focuses on visualizing the attention mechanism itself
Heatbar placement: the heatbar draws above price, so adjust Heatbar Height to avoid overlapping the candles
Adaptive-system nature: historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget; Context × Heads × Key Dim drives compute load, so extreme settings affect performance

🚨 Disclaimer
This indicator is an analytical and educational visualization tool. The attention mechanism, multi-head attention, positional encoding, bias computation, and Attention Heatbar are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Transformer-Inspired Attention Bias
//   AI Drawing Power Series
//
//   A NeuraLib multi-head attention mechanism rendered in Pine. Just as a Transformer attends
//   selectively to the most relevant tokens, this engine treats the CURRENT bar as a query and every
//   recent bar as a key/value. It scores each past bar by relevance (scaled dot-product Q·Kᵀ/√d),
//   normalizes the scores with softmax, and forms a weighted blend of those bars' directional signals
//   — focusing automatically on the past patterns that matter most right now. Several heads run in
//   parallel, each learning a different notion of relevance, then merge into one directional bias.
//
//   Visualization: an Attention Heatbar across the top of the chart (a horizontal strip whose
//   brightness shows how much attention each point in recent time receives) plus one main bias arrow.
//   A Transformer-style "selective focus of memory" — among the first of its kind in Pine.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Transformer-Inspired Attention Bias", "AE-TF AB", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_ATTN  = "◆  MULTI-HEAD ATTENTION (NeuraLib)"
var string GRP_STATE = "◆  TOKEN / FEATURE ENCODER"
var string GRP_BIAS  = "◆  BIAS & SIGNAL"
var string GRP_HEAT  = "◆  ATTENTION HEATBAR"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Attention —
ctxLen       = input.int(40,   "Context Window (past bars)", minval = 5, maxval = 200, group = GRP_ATTN, tooltip = "How many recent bars the current query attends over (the attention sequence length).")
nHeads       = input.int(3,    "Attention Heads", minval = 1, maxval = 6, group = GRP_ATTN, tooltip = "Parallel attention heads; each learns a different notion of relevance.")
dKey         = input.int(4,    "Key/Query Dim (d)", minval = 2, maxval = 8, group = GRP_ATTN, tooltip = "Dimensionality of the query/key projection. Scaling uses 1/√d.")
temperature  = input.float(1.0, "Softmax Temperature", minval = 0.2, maxval = 4.0, step = 0.1, group = GRP_ATTN, tooltip = "Lower = sharper focus on the single most relevant bar; higher = more diffuse attention.")

// — Token Encoder —
fastLen      = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen      = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
rsiLen       = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_STATE)
normLen      = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)
posEncode    = input.bool(true,"Positional Encoding", group = GRP_STATE, tooltip = "Add a recency-based positional signal so the model knows how far back each bar is.")

// — Bias & Signal —
biasSmooth   = input.int(3,    "Bias Smoothing", minval = 1, maxval = 20, group = GRP_BIAS)
sigGate      = input.float(0.30,"Min |Bias| to Signal", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_BIAS, tooltip = "The main arrow fires only when the attention bias magnitude clears this gate.")
oncePerMove  = input.bool(true,"One Arrow per Directional Shift", group = GRP_BIAS)

// — Attention Heatbar —
showHeat     = input.bool(true, "Show Attention Heatbar", group = GRP_HEAT)
heatCells    = input.int(40,   "Heatbar Resolution", minval = 10, maxval = 100, group = GRP_HEAT, tooltip = "Number of cells in the heatbar (time-axis buckets of attention weight).")
heatOffset   = input.float(2.5, "Heatbar Height (ATR x above price)", minval = 0.5, maxval = 10.0, step = 0.5, group = GRP_HEAT)
heatThick    = input.float(0.6, "Heatbar Thickness (ATR x)", minval = 0.1, maxval = 3.0, step = 0.1, group = GRP_HEAT)

// — Aesthetics —
colLong      = input.color(#21d3a3, "Bullish Tone", group = GRP_STYLE, inline = "c1")
colShort     = input.color(#ff5d73, "Bearish Tone", group = GRP_STYLE, inline = "c1")
colHeatLo    = input.color(#10243a, "Heat Low",  group = GRP_STYLE, inline = "c2")
colHeatHi    = input.color(#5ce1ff, "Heat High", group = GRP_STYLE, inline = "c2")
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

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  TOKEN / FEATURE ENCODER  — each bar becomes a small feature "token"
// ────────────────────────────────────────────────────────────────────────────────────────────────

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
rsi     = ta.rsi(close, rsiLen)
atr     = ta.atr(14)

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

rawMom = (emaFast - emaSlow) / (atr == 0 ? 1.0 : atr)
rawRsi = (rsi - 50.0) / 50.0
rawRet = atr == 0 ? 0.0 : (close - close[1]) / atr
rawRng = atr == 0 ? 0.0 : (high - low) / atr - 1.0

// per-bar token features (these are stored historically and attended over)
tok0 = f_znorm(rawMom, ta.sma(rawMom, normLen), ta.stdev(rawMom, normLen))
tok1 = rawRsi
tok2 = math.max(-3.0, math.min(3.0, rawRet))
tok3 = math.max(-3.0, math.min(3.0, rawRng))

// per-bar directional "value" the attention will blend (what each past bar "says")
barValue = f_tanh(0.6 * tok0 + 0.4 * tok2)   // ∈ [-1,1], bullish/bearish lean of that bar

var int N_FEAT = 4

// ── Rolling token history ──
// Pine's [] history operator needs a simple/const offset, so a loop variable can't index it.
// We therefore push each bar's token into rolling arrays and access them with array.get(idx),
// where the index CAN be a series int. Index 0 = oldest retained, last = most recent (current bar).
var array<float> histT0 = array.new_float()
var array<float> histT1 = array.new_float()
var array<float> histT2 = array.new_float()
var array<float> histT3 = array.new_float()
var array<float> histVal = array.new_float()

f_histTrim(array<float> a, int cap) =>
    while array.size(a) > cap
        array.shift(a)

if barstate.isconfirmed
    array.push(histT0, tok0)
    array.push(histT1, tok1)
    array.push(histT2, tok2)
    array.push(histT3, tok3)
    array.push(histVal, barValue)
    int capH = ctxLen + 5
    f_histTrim(histT0, capH)
    f_histTrim(histT1, capH)
    f_histTrim(histT2, capH)
    f_histTrim(histT3, capH)
    f_histTrim(histVal, capH)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  MULTI-HEAD ATTENTION PROJECTIONS  (NeuraLib)
//  Per head: query/key projection matrices Wq, Wk [dKey x N_FEAT], and an output mixing weight wo.
//  Attention(head) = softmax( (q·kᵢ)/√d / temperature ) over context ; output = Σ wᵢ · value(barᵢ).
//  Heads merge by averaging their value-weighted outputs (× learned head weight wo).
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> Wq = na   // [nHeads * dKey * N_FEAT]
var array<float> Wk = na   // [nHeads * dKey * N_FEAT]
var array<float> Wo = na   // [nHeads]  head output mixing weights
var bool projInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not projInit
    Wq := array.new_float(nHeads * dKey * N_FEAT, 0.0)
    Wk := array.new_float(nHeads * dKey * N_FEAT, 0.0)
    Wo := array.new_float(nHeads, 1.0 / nHeads)
    f_initRange(Wq, 1337 * 2654435761, 0.8)
    f_initRange(Wk, 7331 * 40503 + 11, 0.8)
    projInit := true

// project a 4-feature token into a dKey-dim vector for a given head using matrix M (Wq or Wk)
// returns nothing; fills `out` (size dKey)
f_project(array<float> M, int head, float f0, float f1, float f2, float f3, array<float> outv) =>
    array.clear(outv)
    int base = head * dKey * N_FEAT
    for d = 0 to dKey - 1
        float z = 0.0
        z += array.get(M, base + d * N_FEAT + 0) * f0
        z += array.get(M, base + d * N_FEAT + 1) * f1
        z += array.get(M, base + d * N_FEAT + 2) * f2
        z += array.get(M, base + d * N_FEAT + 3) * f3
        array.push(outv, f_tanh(z))

f_dot(array<float> a, array<float> b) =>
    float s = 0.0
    for i = 0 to array.size(a) - 1
        s += array.get(a, i) * array.get(b, i)
    s

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  HISTORICAL TOKEN ACCESS  — we read past tokens directly via the history-referencing operator.
//  Pine lets us reference series[n]; we collect the context window each bar.
// ════════════════════════════════════════════════════════════════════════════════════════════════

// We store the final per-bucket attention weights for the heatbar (averaged across heads).
var array<float> attnHeat = na
if na(attnHeat)
    attnHeat := array.new_float(heatCells, 0.0)

// scratch arrays reused each bar
var array<float> qVec = array.new_float()
var array<float> kVec = array.new_float()
var array<float> attnRaw = array.new_float()   // raw scores over context (size ctxLen)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  COMPUTE ATTENTION  (every bar) — query = current token; keys/values = past ctxLen bars
// ════════════════════════════════════════════════════════════════════════════════════════════════

bool inHorizon = bar_index >= ctxLen

var float liveBias = na
var float biasEma = na
var float focusAge = na      // weighted-average age of attention (how far back focus sits)
var float peakW = 0.0        // peak attention weight (focus sharpness)

if inHorizon
    float invSqrtD = 1.0 / math.sqrt(dKey)
    float blendedBias = 0.0
    float headWsum = 0.0

    // reset heat accumulator
    for c = 0 to heatCells - 1
        array.set(attnHeat, c, 0.0)

    float wAgeSum = 0.0
    float wSum = 0.0
    float maxW = 0.0

    for head = 0 to nHeads - 1
        // query from the CURRENT bar's token
        f_project(Wq, head, tok0, tok1, tok2, tok3, qVec)

        int hsz = array.size(histT0)

        // 1) raw scaled dot-product scores over the context (keys = past bars via array.get)
        array.clear(attnRaw)
        float sMax = -1e18
        for p = 1 to ctxLen
            // index of the p-th most recent stored bar (hsz-1 = most recent confirmed)
            int gi = hsz - p
            float kf0 = gi >= 0 ? array.get(histT0, gi) : 0.0
            float kf1 = gi >= 0 ? array.get(histT1, gi) : 0.0
            float kf2 = gi >= 0 ? array.get(histT2, gi) : 0.0
            float kf3 = gi >= 0 ? array.get(histT3, gi) : 0.0
            // positional encoding: recency signal added to one feature dim
            float posBias = posEncode ? (1.0 - p / ctxLen) * 0.5 : 0.0
            f_project(Wk, head, kf0 + posBias, kf1, kf2, kf3, kVec)
            float score = f_dot(qVec, kVec) * invSqrtD / temperature
            array.push(attnRaw, score)
            sMax := math.max(sMax, score)

        // 2) softmax over context
        float expSum = 0.0
        for p = 0 to ctxLen - 1
            float e = math.exp(array.get(attnRaw, p) - sMax)
            array.set(attnRaw, p, e)
            expSum += e
        if expSum == 0
            expSum := 1.0

        // 3) weighted blend of past bar values + accumulate heat
        float headBias = 0.0
        for p = 0 to ctxLen - 1
            float w = array.get(attnRaw, p) / expSum
            int gi = hsz - 1 - p
            float val = gi >= 0 ? array.get(histVal, gi) : 0.0
            headBias += w * val
            // accumulate into heat buckets (map context position → heat cell)
            int cell = int((p / ctxLen) * (heatCells - 1) + 0.5)
            cell := math.max(0, math.min(heatCells - 1, cell))
            array.set(attnHeat, cell, array.get(attnHeat, cell) + w)
            // focus stats
            wAgeSum += w * (p + 1)
            wSum += w
            maxW := math.max(maxW, w)

        float wo = array.get(Wo, head)
        blendedBias += wo * headBias
        headWsum += wo

    liveBias := headWsum == 0 ? 0.0 : blendedBias / headWsum
    biasEma := na(biasEma) ? liveBias : (liveBias * (2.0 / (biasSmooth + 1)) + biasEma * (1.0 - 2.0 / (biasSmooth + 1)))
    focusAge := wSum == 0 ? na : wAgeSum / wSum
    peakW := maxW / math.max(1, nHeads)

    // normalize heat buckets to [0,1] for display (divide by nHeads since accumulated per head)
    float heatMax = 0.0
    for c = 0 to heatCells - 1
        heatMax := math.max(heatMax, array.get(attnHeat, c))
    if heatMax > 0
        for c = 0 to heatCells - 1
            array.set(attnHeat, c, array.get(attnHeat, c) / heatMax)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION
// ════════════════════════════════════════════════════════════════════════════════════════════════

float bias = na(biasEma) ? 0.0 : biasEma
int chosen = bias > 0.05 ? 1 : bias < -0.05 ? -1 : 0
color biasCol = bias >= 0 ? colLong : colShort

// --- main bias arrow ---
bool gateOk = math.abs(bias) >= sigGate
var int lastSig = na
bool sigChanged = na(lastSig) or chosen != lastSig
bool fireBase = inHorizon and barstate.isconfirmed and chosen != 0 and gateOk
bool fire = oncePerMove ? (fireBase and sigChanged) : fireBase
bool fireLong  = fire and chosen == 1
bool fireShort = fire and chosen == -1

if inHorizon and barstate.isconfirmed and chosen != 0 and gateOk
    lastSig := chosen

plotshape(fireLong and glowFx,  title = "Long Glow",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 72),  size = size.normal, force_overlay = true)
plotshape(fireShort and glowFx, title = "Short Glow", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 72), size = size.normal, force_overlay = true)
plotshape(fireLong,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.small, force_overlay = true)
plotshape(fireShort, title = "Short", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.small, force_overlay = true)

// --- ATTENTION HEATBAR across the top of the chart ---
// One horizontal strip of cells above price. Each cell = a time-axis bucket of recent context;
// brightness/color blends from low to high attention. Newest context on the right, oldest on left.
var array<box> heatBoxes = array.new<box>()

if showHeat and inHorizon and barstate.islast
    // clear previous
    if array.size(heatBoxes) > 0
        for i = 0 to array.size(heatBoxes) - 1
            box.delete(array.get(heatBoxes, i))
        array.clear(heatBoxes)

    float topY = high + heatOffset * atr
    float botY = topY - heatThick * atr
    // span the heatbar across the visible context window ending at the current bar
    int xRight = bar_index
    int xLeft  = bar_index - ctxLen
    int cellW = math.max(1, int((xRight - xLeft) / heatCells))

    for c = 0 to heatCells - 1
        float wv = array.get(attnHeat, c)
        // cell x-range: cell 0 = oldest (left), last = newest (right)
        int cxL = xLeft + c * cellW
        int cxR = c == heatCells - 1 ? xRight : (xLeft + (c + 1) * cellW)
        // color: low→high attention gradient, tinted by current bias direction
        color baseHeat = color.from_gradient(wv, 0.0, 1.0, colHeatLo, colHeatHi)
        // tint toward bias direction for high-attention cells
        color cellCol = color.from_gradient(wv, 0.0, 1.0, baseHeat, color.new(biasCol, 0))
        int trans = int(math.max(10, 80 - wv * 70))
        box bx = box.new(cxL, topY, cxR, botY, xloc = xloc.bar_index,
             border_color = color.new(#0a0d15, 60), border_width = 1,
             bgcolor = color.new(cellCol, trans))
        array.push(heatBoxes, bx)

    // a subtle label marking the heatbar
    // (drawn once; reuse a persistent label)

var label heatLbl = na
if showHeat and inHorizon and barstate.islast
    if not na(heatLbl)
        label.delete(heatLbl)
    heatLbl := label.new(bar_index - ctxLen, high + heatOffset * atr + heatThick * atr * 0.5,
         "ATTENTION  ◂ older   newer ▸", xloc = xloc.bar_index, yloc = yloc.price,
         style = label.style_label_down, color = color.new(THEME_BG, 20), textcolor = THEME_DIM, size = size.small)

// glow accent on strong-bias bars
plot(glowFx and inHorizon and math.abs(bias) > sigGate * 1.4 ? close : na, "Bias Glow", color = color.new(biasCol, 60), linewidth = 3, style = plot.style_circles, force_overlay = true)

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

f_signedBar(float b) =>
    int half = 6
    int mag = int(math.round(math.min(1.0, math.abs(b)) * half))
    string s = ""
    for i = 1 to half
        s := s + (b < 0 and i > half - mag ? "█" : "░")
    s := s + "│"
    for i = 1 to half
        s := s + (b > 0 and i <= mag ? "█" : "░")
    s

f_bar(float v01) =>
    int filled = int(math.round(math.max(0.0, math.min(1.0, v01)) * 12))
    string s = ""
    for i = 1 to 12
        s := s + (i <= filled ? "█" : "░")
    s

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 9, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    string dir = bias > 0.05 ? "BULLISH" : bias < -0.05 ? "BEARISH" : "NEUTRAL"
    color dCol = bias > 0.05 ? colLong : bias < -0.05 ? colShort : THEME_DIM

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "ATTENTION", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + dir + " BIAS", text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(dCol, 0))
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Attention Bias", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_signedBar(bias), text_color = dCol, text_size = f_panelSize(), text_halign = text.align_center)
    table.cell(panel, 2, 2, str.tostring(bias, "+#.##;-#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Focus Sharpness", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, f_bar(math.min(1.0, peakW * ctxLen / 3.0)), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(peakW, "#.###"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "Focus Distance", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, "", text_size = f_panelSize())
    table.cell(panel, 2, 4, na(focusAge) ? "—" : (str.tostring(math.round(focusAge)) + " bars ago"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "ATTENTION CONFIG", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 5, 2, 5)

    table.cell(panel, 0, 6, "Heads / Context", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 6, str.tostring(nHeads) + "H", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 6, str.tostring(ctxLen) + " bars", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 7, "Key Dim / Temp", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, "d=" + str.tostring(dKey), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 7, "τ=" + str.tostring(temperature, "#.#"), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Positional Encoding", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, "", text_size = f_panelSize())
    table.cell(panel, 2, 8, posEncode ? "ON" : "OFF", text_color = posEncode ? colLong : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(fireLong,  "Attention ▸ BULLISH", "AetherEdge Attention: bullish bias signal.")
alertcondition(fireShort, "Attention ▸ BEARISH", "AetherEdge Attention: bearish bias signal.")
````
