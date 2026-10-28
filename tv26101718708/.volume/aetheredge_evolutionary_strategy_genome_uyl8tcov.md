# AetherEdge - Evolutionary Strategy Genome

- url: https://www.tradingview.com/script/uyl8TCov/
- type: indicator
- pine_id: PUB;500501c80d2d4607a478ae5b9a3055d6
- version: 1.0

## Description

🖊️ Overview

A meta-AI that evolves the strategy itself. Where most tools learn weights inside a fixed model, this engine runs a genetic algorithm over a population of genomes — each a vector encoding how strongly, and in which direction, to read several indicator "genes" (trend, momentum, mean-reversion, volatility, volume). Every genome is a candidate trading strategy. Each generation, genomes are scored by fitness (how well their signal predicted recent forward moves), then evolved by selection (tournament), crossover, and mutation. Over generations the population converges toward strategies that fit the live regime, and the engine proposes the current best genome in real time. Visualization: a text label describing the current best genome (which genes it favors) plus a single forecast line from that evolved strategy.

🔶 Key Features

Strategy evolution — evolves the strategy's composition itself via a genetic algorithm, not just weights (meta-AI)
Genome (strategy DNA) — a vector of five indicator-gene weights and directions
Fitness scoring — tracks how accurately each genome's signal predicted forward moves
Evolution operators — tournament selection, crossover, mutation, and elitism
Real-time best proposal — extracts the current best genome and proposes its strategy
Best-genome label — visualizes which genes the strategy favors and in which direction
Forecast line — a single line projecting the best genome's signal forward
Intelligence panel — best signal, best genome ID and fitness, each gene's weight, generation count, and average fitness

🧠 Technical Architecture

The engine builds five indicator genes: trend (deviation from an MA), momentum (normalized), mean-reversion (negative of stretch from the mean, fading extension), volatility (expansion/contraction regime with a directional sign), and volume (volume-weighted direction). Each gene is a [-1,1] directional reading.
The genome population has popSize individuals, each a five-gene weight vector (the strategy DNA). A genome's signal is tanh(Σ weightₘ · geneₘ), a [-1,1] directional conviction.
Evolution cycle: (1) fitness scoring — the signal each genome emitted fitLook bars ago is scored against the realized forward move as signal × outcome, updating a running fitness via EMA; (2) generation turnover (every evolveEvery bars) — elitism carries the top individuals over unchanged, while the rest are bred via tournament selection (the fitter of two random individuals), crossover (each gene inherited from one parent), and mutation (genes mutate with probability mutRate at scale mutScale). After turnover, fitness is softened and the new individuals are re-evaluated.
For the best-genome proposal, every bar the highest-fitness individual is extracted, and its strategy's signal drives the forecast line and label. The population is sized at MAXPOP(24) and run at popSize(4–24).

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Population 12, Evolve Every 5, Mutation Rate 0.15, Elite 2, Fitness Lookahead 5. Standard settings fit well
ETH (1H–4H): As BTC, with Fitness Memory 50–80
SOL (15m–1H): High volatility favors Mutation Rate 0.2 / Evolve Every 3 to evolve fast and track change nimbly
XRP (1H–4H): Spike-prone; Fitness Decay 0.88 to forget old performance quickly and accelerate adaptation
Population Size: more explores more strategies but adds compute; 10–16 is a practical balance
Evolve Every: smaller evolves often (nimble but less stable); larger is steadier but slower to adapt
Mutation Rate/Scale: higher is exploratory (tries new strategies); lower is stable (refines existing) — tune to market change
Elite Survivors: more preserves good strategies but reduces diversity; 2–3 is practical

💡 How to Use in Practice

Reading the best-genome label: it shows the gene composition of the currently best-performing strategy (e.g. a strong TREND +▮▮▮ means trend-following dominates; MEAN-REV +▮▮▮ means reversion works)
Using the forecast line: a signal-based projection from the evolved best strategy; a steeper slope means stronger directional conviction
Watching gene composition shift: changing gene weights over time signal a regime change and the evolution migrating to a new strategy
Checking generation and fitness: a rising generation count (G#) with rising best fitness means evolution is working and refining; a large gap to average fitness means one strategy stands out
Handling EVOLVING states: when the signal doesn't clear the gate, the strategy lacks conviction — stand aside
Multi-timeframe usage: read the dominant strategy type (gene composition) on the higher timeframe (4H), then time on the forecast on the lower one (15m–1H)

⚠️ Important Notes

Initial evolution period: right after launch the population is randomly initialized and strategies are unevolved; treat signals as low-confidence until enough generations pass (tens of generations = hundreds of bars)
Stochastic evolution: a genetic algorithm is a stochastic search; even the same market can converge to different strategies with a different seed (settings)
Overfitting risk: evolution fits recent conditions, with no guarantee they persist (overfitting to the past); too-short Fitness Memory overfits to recent noise
Learning resets: changing parameters, symbol/timeframe, or recompiling reinitializes the population and fitness, restarting evolution from zero
On look-ahead: fitness uses closed-bar realized moves (a standard training construct); as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation within Pine's compute budget; more population increases compute proportionally

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The genetic algorithm, genome evolution, fitness scoring, best-strategy proposal, and forecast line are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Even an evolved strategy can be wrong. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Evolutionary Strategy Genome
//   AI Drawing Power Series
//
//   A meta-AI that evolves the STRATEGY ITSELF. Where most tools learn weights inside a fixed model,
//   this engine runs a lightweight genetic algorithm over a population of GENOMES — each genome a
//   vector encoding how strongly to weight, and in which direction to read, several indicator "genes"
//   (trend, momentum, mean-reversion, volatility, volume). Every genome is a candidate trading
//   strategy. Each generation, genomes are scored by FITNESS (how well their signal predicted recent
//   forward moves), then evolved by selection (tournament), crossover, and mutation. Over generations
//   the population converges toward strategies that fit the live regime, and the engine proposes the
//   current best genome in real time.
//
//   Visualization: a text label describing the current best genome (which genes it favors) plus a
//   single forecast line produced by that evolved strategy. Evolution of the strategy, not just its
//   parameters.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Evolutionary Strategy Genome", "AE-ES GN", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_EVO   = "◆  EVOLUTION ENGINE"
var string GRP_GENE  = "◆  INDICATOR GENES"
var string GRP_FIT   = "◆  FITNESS"
var string GRP_PRED  = "◆  PREDICTION"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Evolution Engine —
popSize      = input.int(12,   "Population Size", minval = 4, maxval = 24, group = GRP_EVO, tooltip = "Number of candidate genomes (strategies) in the population.")
evolveEvery  = input.int(5,    "Evolve Every (bars)", minval = 1, maxval = 50, group = GRP_EVO, tooltip = "Run one generation of selection/crossover/mutation every N bars.")
mutRate      = input.float(0.15,"Mutation Rate",  minval = 0.0, maxval = 0.8, step = 0.01, group = GRP_EVO, tooltip = "Probability each gene mutates during reproduction.")
mutScale     = input.float(0.30,"Mutation Scale", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_EVO, tooltip = "Magnitude of a mutation when it occurs.")
eliteKeep    = input.int(2,    "Elite Survivors", minval = 1, maxval = 6, group = GRP_EVO, tooltip = "Top genomes carried over unchanged each generation (elitism).")
seedInp      = input.int(67,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_EVO)

// — Indicator Genes —
trendLen     = input.int(30,   "Trend Gene Length", minval = 2, maxval = 200, group = GRP_GENE)
momLen       = input.int(14,   "Momentum Gene Length", minval = 2, maxval = 100, group = GRP_GENE)
mrLen        = input.int(20,   "Mean-Reversion Gene Length", minval = 2, maxval = 100, group = GRP_GENE)
volaLen      = input.int(14,   "Volatility Gene Length", minval = 2, maxval = 100, group = GRP_GENE)
volLen       = input.int(20,   "Volume Gene Length", minval = 2, maxval = 100, group = GRP_GENE)
normLen      = input.int(120,  "Gene Norm Window", minval = 20, maxval = 1000, group = GRP_GENE)

// — Fitness —
fitLook      = input.int(5,    "Fitness Lookahead (bars)", minval = 1, maxval = 20, group = GRP_FIT, tooltip = "Forward window over which a genome's signal is scored for accuracy.")
fitWin       = input.int(50,   "Fitness Memory", minval = 10, maxval = 300, group = GRP_FIT, tooltip = "How many recent evaluations contribute to a genome's running fitness.")
fitDecay     = input.float(0.92,"Fitness Decay", minval = 0.5, maxval = 0.999, step = 0.01, group = GRP_FIT, tooltip = "EMA decay of running fitness — lower forgets old performance faster.")

// — Prediction —
predLook     = input.int(10,   "Forecast Length (bars)", minval = 2, maxval = 40, group = GRP_PRED)
sigGate      = input.float(0.30,"Min Signal to Mark", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_PRED, tooltip = "The best genome's signal must clear this to draw a directional mark.")

// — Aesthetics —
colLong      = input.color(#21d3a3, "Bullish Tone", group = GRP_STYLE, inline = "c1")
colShort     = input.color(#ff5d73, "Bearish Tone", group = GRP_STYLE, inline = "c1")
colMid       = input.color(#5ce1ff, "Forecast Line", group = GRP_STYLE)
showGenome   = input.bool(true, "Best-Genome Label", group = GRP_STYLE)
showPred     = input.bool(true, "Forecast Line", group = GRP_STYLE)
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

var int MAXPOP = 24

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  PRNG
// ────────────────────────────────────────────────────────────────────────────────────────────────

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

f_tanh(float x) =>
    float xc = math.max(-20.0, math.min(20.0, x))
    float e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INDICATOR GENES  — the 5 building blocks a genome can weight (each ∈ [-1,1] directional reading)
// ────────────────────────────────────────────────────────────────────────────────────────────────

atr = ta.atr(14)

f_clip(float v) =>
    math.max(-1.0, math.min(1.0, v))

// gene 0: TREND — slope of a trend MA
geneTrend = f_clip((close - ta.sma(close, trendLen)) / (atr == 0 ? 1.0 : atr) / 3.0)
// gene 1: MOMENTUM — normalized momentum
geneMom = f_clip((close - close[momLen]) / (atr == 0 ? 1.0 : atr) / 3.0)
// gene 2: MEAN-REVERSION — negative of stretch from mean (fades extension)
geneMR = f_clip(-((close - ta.sma(close, mrLen)) / (ta.stdev(close, mrLen) == 0 ? 1.0 : ta.stdev(close, mrLen))) / 2.0)
// gene 3: VOLATILITY — regime sign (expansion vs contraction), signed by recent direction
volaRatio = ta.atr(volaLen) / (ta.sma(ta.atr(volaLen), normLen) == 0 ? 1.0 : ta.sma(ta.atr(volaLen), normLen))
geneVola = f_clip((volaRatio - 1.0) * (close > close[1] ? 1.0 : -1.0))
// gene 4: VOLUME — volume-weighted direction
volRatio = volume / (ta.sma(volume, volLen) == 0 ? 1.0 : ta.sma(volume, volLen))
geneVol = f_clip((volRatio - 1.0) * (close > open ? 1.0 : -1.0))

var int N_GENE = 5

f_geneName(int g) =>
    g == 0 ? "TREND" : g == 1 ? "MOM" : g == 2 ? "MEAN-REV" : g == 3 ? "VOLA" : "VOLUME"

f_geneValue(int g) =>
    g == 0 ? geneTrend : g == 1 ? geneMom : g == 2 ? geneMR : g == 3 ? geneVola : geneVol

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  GENOME POPULATION
//  Each genome = N_GENE weights (the strategy DNA). Signal = tanh(Σ weight_g · gene_g).
//  Stored flat: gene[p*N_GENE + g]. Fitness tracked per genome.
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> genome = na      // [MAXPOP * N_GENE] weights
var array<float> fitness = na     // [MAXPOP] running fitness
var array<float> pendingSig = na  // [MAXPOP] signal emitted fitLook bars ago (awaiting outcome)
var bool popInit = false

f_initPop() =>
    int sd = seedInp * 2654435761
    for i = 0 to MAXPOP * N_GENE - 1
        sd := sd + 40503
        array.set(genome, i, (f_rand(sd) - 0.5) * 2.0)   // weights ∈ [-1,1]
    for p = 0 to MAXPOP - 1
        array.set(fitness, p, 0.0)
        array.set(pendingSig, p, na)

if not popInit
    genome := array.new_float(MAXPOP * N_GENE, 0.0)
    fitness := array.new_float(MAXPOP, 0.0)
    pendingSig := array.new_float(MAXPOP, na)
    f_initPop()
    popInit := true

// genome signal: weighted sum of genes through tanh → directional conviction ∈ [-1,1]
f_genomeSignal(int p, float g0, float g1, float g2, float g3, float g4) =>
    int base = p * N_GENE
    float z = 0.0
    z += array.get(genome, base + 0) * g0
    z += array.get(genome, base + 1) * g1
    z += array.get(genome, base + 2) * g2
    z += array.get(genome, base + 3) * g3
    z += array.get(genome, base + 4) * g4
    f_tanh(z)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  EVOLUTION OPERATORS
// ════════════════════════════════════════════════════════════════════════════════════════════════

// tournament selection: pick the fitter of two random genomes; returns its index
f_tournament(int rngSeed) =>
    int a = int(f_rand(rngSeed) * popSize) % popSize
    int b = int(f_rand(rngSeed * 7919 + 13) * popSize) % popSize
    array.get(fitness, a) >= array.get(fitness, b) ? a : b

// crossover two parents into a child genome written into scratch array at childBase
f_crossover(int pa, int pb, array<float> dst, int childBase, int rngSeed) =>
    int baseA = pa * N_GENE
    int baseB = pb * N_GENE
    for g = 0 to N_GENE - 1
        int rs = rngSeed + g * 131
        float gene = f_rand(rs) < 0.5 ? array.get(genome, baseA + g) : array.get(genome, baseB + g)
        // mutation
        if f_rand(rs * 31 + 7) < mutRate
            gene := gene + (f_rand(rs * 17 + 3) - 0.5) * 2.0 * mutScale
        array.set(dst, childBase + g, math.max(-1.5, math.min(1.5, gene)))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

bool inHorizon = bar_index > 200

var float fwdRetGN = na
fwdRetGN := (close - close[fitLook]) / (atr == 0 ? 1.0 : atr)   // realized forward move (ATR units)

var int bestIdx = 0
var float bestSig = 0.0
var int genCount = 0
var float bestFit = 0.0

var array<float> childBuf = na
if na(childBuf)
    childBuf := array.new_float(MAXPOP * N_GENE, 0.0)

// ---- FITNESS UPDATE (closed bars): score each genome's signal from fitLook bars ago ----
if barstate.isconfirmed and inHorizon
    // the outcome for signals emitted fitLook bars ago is now known (fwdRetGN aligns to that signal)
    float outcome = f_clip(fwdRetGN / 2.0)
    for p = 0 to popSize - 1
        float ps = array.get(pendingSig, p)
        if not na(ps)
            // reward = signal · outcome (correct direction & magnitude → positive)
            float rew = ps * outcome
            array.set(fitness, p, fitDecay * array.get(fitness, p) + (1.0 - fitDecay) * rew)

    // emit fresh signals for this bar (to be scored fitLook bars later)
    for p = 0 to popSize - 1
        float sig = f_genomeSignal(p, geneTrend, geneMom, geneMR, geneVola, geneVol)
        array.set(pendingSig, p, sig)

    // ---- EVOLUTION: every evolveEvery bars, run one generation ----
    if bar_index % evolveEvery == 0
        genCount := genCount + 1

        // find elite (top eliteKeep by fitness) — simple selection sort over a copy of indices
        eliteIdx = array.new_int()
        fitCopy = array.new_float()
        for p = 0 to popSize - 1
            array.push(fitCopy, array.get(fitness, p))
        int kk = math.min(eliteKeep, popSize)
        for e = 0 to kk - 1
            float mx = array.max(fitCopy)
            int mi = array.indexof(fitCopy, mx)
            array.push(eliteIdx, mi)
            array.set(fitCopy, mi, -1e18)

        // build next generation into childBuf
        // 1) copy elites unchanged
        for e = 0 to array.size(eliteIdx) - 1
            int src = array.get(eliteIdx, e) * N_GENE
            int dst = e * N_GENE
            for g = 0 to N_GENE - 1
                array.set(childBuf, dst + g, array.get(genome, src + g))
        // 2) fill the rest via tournament + crossover + mutation
        for c = array.size(eliteIdx) to popSize - 1
            int rs = (bar_index * 104729 + c * 7919 + seedInp + genCount * 31) % 2147483647
            int pa = f_tournament(rs)
            int pb = f_tournament(rs * 13 + 101)
            f_crossover(pa, pb, childBuf, c * N_GENE, rs * 3 + 5)

        // 3) swap childBuf → genome (copy back), inherit a fraction of parent fitness for stability
        for p = 0 to popSize - 1
            int b = p * N_GENE
            for g = 0 to N_GENE - 1
                array.set(genome, b + g, array.get(childBuf, b + g))
        // soften fitness after reshuffle (elites keep more)
        for p = 0 to popSize - 1
            array.set(fitness, p, array.get(fitness, p) * 0.5)

// ---- BEST GENOME EVALUATION (every bar incl. realtime) ----
if inHorizon
    float bf = -1e18
    int bi = 0
    for p = 0 to popSize - 1
        float f = array.get(fitness, p)
        if f > bf
            bf := f
            bi := p
    bestIdx := bi
    bestFit := bf
    bestSig := f_genomeSignal(bestIdx, geneTrend, geneMom, geneMR, geneVola, geneVol)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — best-genome label + single forecast line
// ════════════════════════════════════════════════════════════════════════════════════════════════

float sig = na(bestSig) ? 0.0 : bestSig
int dir = sig > 0.05 ? 1 : sig < -0.05 ? -1 : 0
color dirCol = sig >= 0 ? colLong : colShort
bool gateOk = math.abs(sig) >= sigGate

// directional marks (kept simple)
bool markLong  = inHorizon and barstate.isconfirmed and dir == 1 and gateOk
bool markShort = inHorizon and barstate.isconfirmed and dir == -1 and gateOk

plotshape(markLong and glowFx,  title = "Long Glow",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 72),  size = size.small, force_overlay = true)
plotshape(markShort and glowFx, title = "Short Glow", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 72), size = size.small, force_overlay = true)
plotshape(markLong,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.tiny, force_overlay = true)
plotshape(markShort, title = "Short", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.tiny, force_overlay = true)

// --- single forecast line from the best genome's signal ---
var line predLine = na
var line predGlow = na
if showPred and inHorizon and barstate.islast
    if not na(predLine)
        line.delete(predLine)
    if not na(predGlow)
        line.delete(predGlow)
    float drift = sig * atr * (predLook / 2.0)
    float yEnd = close + drift
    if glowFx
        predGlow := line.new(bar_index, close, bar_index + predLook, yEnd, xloc = xloc.bar_index, color = color.new(colMid, 60), width = 5)
    predLine := line.new(bar_index, close, bar_index + predLook, yEnd, xloc = xloc.bar_index, color = color.new(colMid, 0), width = 2, style = line.style_arrow_right)

// --- best-genome text label: shows the dominant genes of the evolved strategy ---
f_topGeneName(int p) =>
    int base = p * N_GENE
    float mx = -1e18
    int mi = 0
    for g = 0 to N_GENE - 1
        float w = math.abs(array.get(genome, base + g))
        if w > mx
            mx := w
            mi := g
    f_geneName(mi)

f_genomeString(int p) =>
    int base = p * N_GENE
    string s = ""
    for g = 0 to N_GENE - 1
        float w = array.get(genome, base + g)
        string tag = w >= 0 ? "+" : "−"
        int barsN = int(math.round(math.min(1.0, math.abs(w)) * 3))
        string fill = ""
        for k = 1 to 3
            fill := fill + (k <= barsN ? "▮" : "▯")
        s := s + f_geneName(g) + " " + tag + fill + (g < N_GENE - 1 ? "  " : "")
    s

var label genomeLbl = na
if showGenome and inHorizon and barstate.islast
    if not na(genomeLbl)
        label.delete(genomeLbl)
    string dirTxt = dir == 1 ? "▲ LONG" : dir == -1 ? "▼ SHORT" : "■ FLAT"
    string txt = "⟁ BEST GENOME #" + str.tostring(bestIdx) + "   " + dirTxt + "  (" + str.tostring(math.round(sig * 100)) + "%)\n" + f_genomeString(bestIdx)
    genomeLbl := label.new(bar_index, high, txt, xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(THEME_BG, 8), textcolor = dirCol, size = size.normal, force_overlay = true)

// glow accent on strong-signal bars
plot(glowFx and inHorizon and math.abs(sig) > sigGate * 1.3 ? close : na, "Genome Glow", color = color.new(dirCol, 60), linewidth = 3, style = plot.style_circles, force_overlay = true)

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
    int half = 5
    int mag = int(math.round(math.min(1.0, math.abs(b)) * half))
    string s = ""
    for i = 1 to half
        s := s + (b < 0 and i > half - mag ? "█" : "░")
    s := s + "│"
    for i = 1 to half
        s := s + (b > 0 and i <= mag ? "█" : "░")
    s

// average population fitness + diversity (spread of best vs mean) for the panel
f_avgFitness() =>
    float acc = 0.0
    for p = 0 to popSize - 1
        acc += array.get(fitness, p)
    acc / popSize

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    string state = gateOk ? (dir == 1 ? "EVOLVED LONG" : dir == -1 ? "EVOLVED SHORT" : "EVOLVED") : "EVOLVING"
    color stateCol = gateOk ? (dir >= 0 ? colLong : colShort) : THEME_DIM
    float avgFit = f_avgFitness()

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "GENOME", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + state, text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = stateCol)
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Best Signal", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_signedBar(sig), text_color = dirCol, text_size = f_panelSize(), text_halign = text.align_center)
    table.cell(panel, 2, 2, str.tostring(math.round(sig * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Best Genome / Fit", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, "#" + str.tostring(bestIdx), text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(bestFit, "#.###"), text_color = bestFit >= 0 ? colLong : colShort, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "GENE WEIGHTS (best)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 4, 2, 4)

    // show the best genome's 5 gene weights
    for g = 0 to N_GENE - 1
        int rowY = 5 + g
        float w = array.get(genome, bestIdx * N_GENE + g)
        table.cell(panel, 0, rowY, f_geneName(g), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
        table.cell(panel, 1, rowY, f_signedBar(w / 1.5), text_color = w >= 0 ? colLong : colShort, text_size = f_panelSize(), text_halign = text.align_center)
        table.cell(panel, 2, rowY, str.tostring(w, "+#.##;-#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Generation / Avg Fit", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, "G" + str.tostring(genCount), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 10, str.tostring(avgFit, "#.###"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(markLong,  "Genome ▸ LONG",  "AetherEdge Evolutionary Genome: evolved strategy signals LONG.")
alertcondition(markShort, "Genome ▸ SHORT", "AetherEdge Evolutionary Genome: evolved strategy signals SHORT.")
````
