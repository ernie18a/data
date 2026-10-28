# Machine Learning: seMLP Q-Wavelet RL Engine [Jamallo]

- url: https://www.tradingview.com/script/FjgYcb4O-Machine-Learning-seMLP-Q-Wavelet-RL-Engine-Jamallo/
- type: indicator
- pine_id: PUB;9cb2bd420a14430db362cd905c7805b4
- version: 1.0

## Description

Author Note:  I [i][b]always [/b][/i] get asked: "How can I build a Machine Learning or Artificial Intelligence trading system?" I created the study "Machine Learning: seMLP Q-Wavelet RL Engine" to showcase exactly how it can be done in a beginner-friendly manner. We will break down exactly how this AI thinks in plain English, and then show you exactly how the Pine Script code executes it step-by-step.

[b]Introduction: The Institutional Approach to Algorithmic Trading[/b]

Most retail and algorithmic traders spend years searching for the "holy grail" by combining static indicators and hard-coded `IF/THEN` rule sets. They are often unaware that institutional quant desks abandoned those basic, curve-fitted patterns decades ago. Standard algorithmic analysis fails because financial markets are inherently chaotic—a hardcoded strategy that works perfectly in a backtest will systematically break down during a live regime shift.

To acquire a true institutional edge, algorithmic strategies cannot rely on rigid, backwards-looking formulas; they require a system that adapts dynamically in real-time. This script brings that quantitative firepower directly to your chart by constructing a live [b]Self-Teaching AI[/b].

[list]
[*][b]Dynamic Filtering[/b]: It uses advanced frequency mathematics (Wavelets) to separate random market noise from true institutional momentum footprints with near-zero lag.

[*][b]Artificial Brain[/b]: It feeds that data into a neural network—a living matrix of artificial "neurons" that continuously analyze and execute decisions.

[*][b]Self-Correction[/b]: Most importantly, it executes Reinforcement Learning. If a trade fails, the AI actively calculates the error and mathematically rewires its own brain, ensuring it constantly evolves to survive changing market conditions.
[/list]

[i]Ultimately, this serves as a foundational study showing you exactly how to break away from basic scripting and get started in true Quantitative Algorithmic Trading.[/i]

[b]1. The Core Architecture Loop[/b]
Here is the high-level flow of how the AI thinks on every single candle:

[image]https://www.tradingview.com/x/jcdGljIv/[/image]

[b]The Invisible "Burn-In" Phase[/b]
Because the AI starts with a completely randomized, "empty" brain, it will make terrible decisions on the very first few candles. To prevent it from acting prematurely on live data, the script executes an aggressive [b]Burn-In Phase[/b] (e.g., the first 300 bars of the chart). During this period, the indicator is completely invisible. It aggressively executes hundreds of "mock trades" in the background, tracking virtual PnL, taking massive risks, and rapidly rewiring its brain without showing a single signal on your screen. Once the 300 bars are up, the burn-in phase ends. The AI stops acting recklessly and officially enters "Live Trading" mode with a fully trained, highly-intelligent brain.

[b]SECTIONS 2 & 3: Setting Up the Brain[/b]

[image]https://www.tradingview.com/x/VCadOQOB/[/image]

[b]Conceptual Overview[/b]
Imagine the brain as a massive team of financial analysts.

[list]
[*]We have 16 junior analysts looking at chart data.
[*]They report their findings up to 12 senior analysts.
[*]The seniors report to 6 directors.
[*]The 6 directors send their final opinions to 3 executives representing the 3 possible actions: `BUY, SELL, HOLD`. This is called a [b]16 → 12 → 6 → 3[/b] network structure.
[/list]

Before we hand the price data to the junior analysts, we [b]Normalize [/b] it (Z-Score). This just means "leveling the playing field" so a massive $500 candle wick doesn't break the analysts' math compared to a tiny $1 movement.

[b]The Code Breakdown[/b]

[pine]// Section 2: Brain Size Constants
int NI   = 16   // 16 Inputs (Junior analysts)
int NH1  = 12   // 12 Hidden layer 1 nodes
int NH2  = 6    // 6 Hidden layer 2 nodes
int NO   = 3    // 3 Outputs [Buy, Sell, Hold]

// Section 3: Normalization Helper
norm(series float x, simple int win) =>
    float mu = ta.sma(x, win)
    float sg = ta.stdev(x, win)
    float sf = nz(sg) < 1e-10 ? 1.0 : sg
    float res = (x - nz(mu, x)) / sf // Levels out the price data
    na(res) ? 0.0 : res[/pine]

[b]SECTIONS 4 & 5: Giving the AI "Memory"
[/b]

[b]Conceptual Overview[/b]
By default, TradingView indicators suffer from permanent amnesia! Every time a new candle paints, TradingView completely deletes its short-term memory and forgets what happened on the last candle. If we are building an AI for trading that needs to "learn", it must be able to remember its past mathematical mistakes.

To force TradingView to remember, we use special variables called `var` to create "Persistent Memory Matrices" where the AI for trading stores its brain's wiring throughout the entire chart history.

[b]The Code Breakdown[/b]

[pine]// Using 'var' locks the memory so it never resets when a new candle paints
var matrix<float> W1 = matrix.new<float>(NI,  NH1, 0.0) // The connections between neurons
var matrix<float> W2 = matrix.new<float>(NH1, NH2, 0.0)
...
var int pos = 0 // The AI remembers its current position: Long (1), Short (-1), or Flat (0)[/pine]

[b]SECTION 6: Seeing the Market (Wavelets)
[/b]

[b]Conceptual Overview[/b]
If you use a Moving Average, it always "lags" behind the real price. By the time the Moving Average crosses to tell you to buy, the massive breakout has already happened.

To fix this, we teach the AI for trading to see using [b]Haar Wavelets[/b]. A Wavelet is a piece of advanced math that splits the price candle with minimal lag into two things:

[list]
[*][b]The Detail (D)[/b]: The immediate, rapid volatility chop.
[*][b]The Smooth (V)[/b]: The true underlying smooth momentum. By looking at the detail and momentum completely separately, the AI for trading can react to shifts with minimal lag.
[/list]

[b]The Code Breakdown[/b]

[pine]// We take standard features like Open, Close, and Volume:
float f0 = open
float f1 = close...

// We break them into Wavelets using simple math combinations:
float v1_0 = (f0 + nz(f0[1], f0)) / 2.0 // Smooth momentum
float d1_0 = (f0 - nz(f0[1], f0)) / 2.0 // Instant volatility detail
...
// We pack all 16 traits into the 'feat' array to feed the AI for trading's Brain
feat.set(0,  norm(d1_0, i_normWin))
feat.set(14, float(pos))               // Tells the brain its current trade position
feat.set(15, norm(portRet, i_normWin)) // Tells the brain its current open trade return [/pine]

[b]SECTION 7: How the Brain Thinks (seMLP)[/b]

[b]Conceptual Overview[/b]

An "MLP" is just a standard Neural Network (a massive web of variables that pass data to each other). The problem is that if you give TradingView an insanely massive web of math equations, it will crash and throw a compiler timeout error.

So, we use a [b]Self-evolving MLP (seMLP)[/b]. The AI pushes the Wavelet data through its network dynamically. To prevent "dead zones" where a neuron just stops firing in a flat market, it uses a formula called [b]LeakyReLU[/b]. It basically acts as a gatekeeper that tells the neuron: [i]"If this signal is incredibly weak, shrink it down to 1%, but don't explicitly delete it."[/i]

[b]The Code Breakdown[/b]

[pine]// The data enters Hidden Layer 1 (h1)
array<float> h1  = array.new<float>(NH1, 0.0)
for j = 0 to NH1 - 1
    float s = B1.get(j)
    // The inner brain loops through all 16 incoming inputs
    for i = 0 to NI - 1
        s += feat.get(i) * W1.get(i, j) 
    
    // LeakyReLU Formula: f(x) = x if x > 0 else 0.01 * x
    // If the signal 's' is positive, keep it. If 's' is negative, shrink to 1%
    h1.set(j, s > 0 ? s : 0.01 * s) [/pine]

[b]SECTION 8: Taking Action (Exploration vs Exploitation)[/b]

[b]Conceptual Overview[/b]
How does the AI actually press the BUY or SELL button? It calculates a "Confidence Score" (called a Q-Value) for all three options— Buy, Sell, and Hold. The highest score wins and executes the trade.
However, during its invisible "Burn-In Period", the AI uses a variable called [b]Epsilon[/b]. Think of Epsilon as a dice roll. Sometimes, instead of making the smartest, highest-scoring choice, the AI will randomly pick a completely stupid trade just to "experiment" and see if a hidden market pattern exists! This is conceptually how AI for trading discovers new, out-of-the-box strategies. As training goes on, Epsilon gets smaller, and the AI stops experimenting.

[b]The Code Breakdown[/b]

[pine]// Calculate Epsilon: Start at a high 50% and slowly decay to 5% over time
float epsilon = bar_index <= i_burnIn ? math.max(0.05, i_epsStart_val * ...)

// Roll the dice. If the random number is less than epsilon, we experiment randomly!
bool explore = math.random(0.0, 1.0) < epsilon

// Find the AI for trading's highest confidence choice: Q(0) = Buy, Q(1) = Sell, Q(2) = Hold
if Q.get(1) > bestQ // If Sell confidence is higher than current best (Buy)...
    bestQ   := Q.get(1)
    bestAct := 1
if Q.get(2) > bestQ // If Hold is even higher...
    bestQ   := Q.get(2)
    bestAct := 2

// Execute the final action
int act = explore ? math.min(int(math.floor(math.random(0.0, 2.999))), 2) : qArg[/pine]

[b]SECTION 9: Training with Rewards (Reinforcement Learning)[/b]

[b]Conceptual Overview[/b]

[image]https://www.tradingview.com/x/oqFiO7VG/[/image]

This is the heart of Machine Learning. It functions exactly like training a pet. If the AI makes a winning trade that generates cash, we give it a mathematical "treat" (a positive reward). If the AI loses money, we hit it with a brutal negative reward. Over time, the AI autonomously refines its neural weights exclusively to collect the maximum amount of "treats".

[b]The Code Breakdown[/b]

[pine]// Calculate how much money the candle moved
float cRet = nz((close - close[1]) / close[1], 0.0)

// The Reward (R) is a combination of three factors:
// 1. PnL (rPn) - Did we make raw cash profit?
// 2. Trail (rTn) - Did we efficiently track the trend?
// 3. Lee (rLee) - A shaping bonus for correct directional positioning.
float R = i_alphaT * rTn + i_alphaP * rPn + 0.1 * rLee[/pine]

[b]SECTION 10: Learning from Mistakes (Backpropagation)[/b]

[b]Conceptual Overview[/b]

[image]https://www.tradingview.com/x/dSCD0f8P/[/image]

If the AI's trade failed, how does it adjust its internal logic? It uses a process called [b]Backpropagation[/b]. It looks at the Reward it just received, realizes it was horribly wrong, and calculates the "Error Margin" (How far off my prediction was I?). It then mathematically rewrites all of the internal connections `(W1, W2, W3)` in reverse, editing them to be slightly smarter for the next candle!
Because updating a massive brain on every single micro-tick causes chaotic glitches, we "Accumulate" the errors in a batch over several candles, and then update the brain smoothly with the batch average.

[b]The Code Breakdown[/b]

[pine]// Compare the Target Reward vs what the Brain actually Predicted (Temporal Difference Error)
float tgt = R + i_gamma * max_qt 
float td  = tgt - pOut.get(prevAct)

// Accumulate the backwards gradients over multiple bars so we don't glitch 
for j = 0 to NO - 1
    gB3_acc.set(j, gB3_acc.get(j) + g3.get(j))
accumCount += 1

// Once 'i_accumSteps' bars have passed, we apply the compiled batch update to 'Rewire' the Brain weights!
if accumCount >= i_accumSteps
    for i = 0 to NH2 - 1
        for j = 0 to NO - 1
            float dw = gW3_acc.get(i, j) * sc
            W3.set(i, j, W3.get(i, j) + clr * dw - clr * i_l2 * W3.get(i, j))[/pine]

[b]SECTION 11: Link Pruning (Making the Brain Faster)[/b]

[b]Conceptual Overview[/b]

Stage 1: The Initial Brain (Complex & Slow)
[image]https://www.tradingview.com/x/3UpEZeML/[/image] 
Stage 2: The Pruning Decision
[image]https://www.tradingview.com/x/Z2rJ16iK/[/image] 
Stage 3: The Optimized AI for trading (Sleek & Fast)
[image]https://www.tradingview.com/x/i58Ksc2m/[/image] 

As the brain learns, some of the mathematical connections become totally useless. Having a giant Tradingview indicator calculate hundreds of useless math connections will trigger a calculation timeout. At a specific point in training length (defaulting to the end of the 300-bar burn-in period), the script literally pauses and deletes (zeroes out) the weakest neural links. TradingView skips over calculations containing plain zeroes, making your indicator insanely fast and completely lag-proof.

[b]The Code Breakdown[/b]

[pine]if bar_index == i_pruneBar and not pruned
    // Evaluate every single connection weight...
    // Find the bottom weakest percentage (i_prunePct)
    float thr = absW.get(pidx)
    
    // Explicitly set the weakest weights to Zero! 
    for i = 0 to NI - 1
        for j = 0 to NH1 - 1
            if math.abs(W1.get(i, j)) <= thr
                W1.set(i, j, 0.0) // Permanent pruning: weak link removed[/pine]


[b]Important Disclaimer[/b]

This indicator is published strictly for educational and research purposes. It is a conceptual showcase proving that advanced Deep Reinforcement Learning architectures generally reserved for Python/TensorFlow can be natively executed within the TradingView Pine Script environment. Due to Pine Script's structural time-series limitations—specifically the lack of a random-access historical buffer required for true experience replay—this is NOT intended for practical live trading. For production-grade deployment, it is highly recommended to port this mathematical framework to Python.

[b]References [/b]
This indicator's mathematical engine was directly modeled and bridged from the following quantitative research papers:

[list]
[*][LEE] Lee et al. (2021) — "[i]Learning to trade in financial time series using high-frequency through wavelet transformation and deep reinforcement learning[/i]" (Used for the MODWT Wavelet integration & State architecture).
[*][TSA] Tsantekidis et al. (2021) — "[i]Price Trailing for Financial Trading using Deep Reinforcement Learning[/i]" (Used for the dynamic margin-trailing reward system).
[*][SEM] Seow et al. (2021) — "[i]seMLP: Self-evolving Multi-layer Perceptron[/i]" (Used for the 16 → 12 → 6 → 3 sparse Neural Network structure and the automatic Link Pruning logic).
[/list]

## Source Code

````pine
//@version=6
indicator("Machine Learning: seMLP Q-Wavelet RL Engine [Jamallo]", "ML Q-Wavelet [Jamallo]", overlay = true, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════════
// AUTHOR NOTE
// ═══════════════════════════════════════════════════════════════════════════════
// This indicator is published strictly for educational and research purposes.
// It is a conceptual showcase proving that advanced Deep Reinforcement Learning
// architectures generally reserved for Python/TensorFlow can be natively executed 
// within the TradingView Pine Script environment. Due to Pine Script's time-series 
// structural limitations (e.g., lack of experience replay buffers), this is NOT 
// intended for practical live trading. For production-grade deployment, it is 
// highly recommended to port this mathematical framework to Python.
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION NOTES
// ═══════════════════════════════════════════════════════════════════════════════
//
// This script combines three papers exactly as written:
//
// [LEE]  Lee et al. (2021) — "Learning to trade in financial time series using
//        high-frequency through wavelet transformation and deep reinforcement
//        learning"
//        ► Features: 7 base inputs (Open, Close, Volume, MA5/MA10 Close/Vol)
//          decomposed to D(1) and D(2) Haar details → 14 wavelet features
//          + 2 agent-state features = 16 inputs total (Table 3, HW LSTM RL)
//        ► Actions: Buy, Sell, Hold ∈ {1,0,-1} (§4.3.2)
//        ► Reward: shaped immediate+delayed (§4.3.3) — approximated here as
//          a tiered PnL reward since we have no batch buffer in Pine
//        ► Epsilon decay: ε ← ε/(t+1) (Eq. 11)
//        ► Sharpe ratio metric (§3.5, Eq. 28-30)
//
// [SEM]  Seow et al. (2021) — "seMLP: Self-evolving Multi-layer Perceptron"
//        ► Architecture: fixed 16→12→6→3 (approximates GA-found optimal)
//        ► Link pruning: threshold at i_prunePct percentile, W3 stays full
//          (§Link Pruning — "last layer to output not pruned")
//        ► Z-score normalisation on each feature window (§Results setup)
//
// [TSA]  Tsantekidis et al. — "Price Trailing for Financial Trading using DRL"
//        ► Price trailing: pa(t) updated by step υ toward upper/lower margin
//          (Eq. 6); target = close price (§III-D)
//        ► Margin bands: pum = pc*(1+m), plm = pc*(1-m) (Eq. 3-4)
//        ► Trail reward: r_T = 1 - |pa(t) - pc(t)| / (m*pc(t))  (Eq. 5)
//        ► PnL reward: r_PnL = δt * zt  (Eq. 1, where zt = bar return)
//        ► Reward normalisation: r_PnL /= σz; r_T *= μ|z|/σz  (Eq. 7, 9)
//        ► Combined: R = α_trail*r_T + α_pnl*r_PnL  (Eq. 10)
//
// KEY IMPLEMENTATION FEATURES:
//
//  ► Target Network Lag: Decoupled Bellman updates approximating DQN stability
//  ► Gradient Accumulation: Multi-bar accumulation over SGD to combat time-series noise
//  ► Hysteresis Tracking: Q-Margin confidence thresholding
//  ► Epsilon Scheduling: Linear decay exploitation integration
// ═══════════════════════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 1: INPUTS
// ───────────────────────────────────────────────────────────────────────────────

// AI Network  [LEE §4.2, SEM Table 3]
i_lr          = input.float(0.001,  "Learning Rate",          minval=0.0001, maxval=0.01,  step=0.0001, group="AI Network", tooltip="The speed at which the AI learns from its mistakes. Higher = faster but less stable.")
i_lrBoost     = input.float(5.0,    "Burn-in LR Boost",       minval=1.0,    maxval=50.0,  step=1.0,    group="AI Network", tooltip="Multiplier for the Learning Rate during the invisible Burn-in Period to force rapid convergence.")
i_gamma       = input.float(0.99,   "Discount γ [LEE Eq.12]", minval=0.8,    maxval=0.999, step=0.005,  group="AI Network", tooltip="Forces the AI to care about future long-term rewards rather than just immediate next-candle scalps.")
i_burnIn      = input.int(300,      "Burn-in Period (bars)",  minval=0,      maxval=5000,               group="AI Network", tooltip="The number of invisible bars the AI uses to train its brain randomly before it officially starts trading.")
i_normWin     = input.int(50,       "Feature Norm Window",    minval=10,     maxval=200,                group="AI Network", tooltip="Lookback window for normalizing the Wavelet price data (Z-Score) so massive volatility spikes don't break the math.")
i_l2          = input.float(0.0001, "L2 Regularisation",      minval=0.0,    maxval=0.01,  step=0.0001, group="AI Network", tooltip="Mathematical weight penalty to stop the AI's connections from getting infinitely large, preventing crashes.")
i_epsStart_val= input.float(0.5,    "Epsilon Start [LEE Eq.11]",minval=0.01, maxval=1.0,   step=0.05,   group="AI Network", tooltip="Starting chance (1.0 = 100%) that the AI randomly rolls the dice to experiment and discover out-of-the-box strategies during the Burn-in.")
i_targetLag   = input.int(10,       "Target Q Update (bars)", minval=1,      maxval=50,                 group="AI Network", tooltip="How many bars to wait before updating the target Reference Brain. Higher values provide stronger stability and isolate chaotic feedback loops.")
i_accumSteps  = input.int(5,        "Gradient Accum Steps",   minval=1,      maxval=20,                 group="AI Network", tooltip="Number of bars to batch errors together before physically rewiring the Brain. Stops micro-tick glitches from destroying the AI.")

// Link Pruning  [SEM §Link Pruning]
i_pruneBar    = input.int(300,      "Prune After (bars)",     minval=50,     maxval=5000,               group="Link Pruning", tooltip="The exact bar where the AI pauses to delete all useless math connections to make the indicator calculate noticeably faster.")
i_prunePct    = input.float(40.0,   "Prune Percentile %",     minval=10.0,   maxval=90.0,  step=5.0,    group="Link Pruning", tooltip="Percentage of the weakest, least-useful neural connections to permanently delete (zero out).")

// Reward  [TSA §III-D Eq.5,9,10 + LEE §4.3.3]
i_margin      = input.float(0.01,   "Trail Margin m [TSA Eq.3]",   minval=0.001, maxval=0.1,  step=0.001, group="Reward", tooltip="Percentage distance for the profit trailing margin bands.")
i_step        = input.float(0.2,    "Trail Step υ [TSA Eq.6]",     minval=0.01,  maxval=1.0,  step=0.05,  group="Reward", tooltip="Speed at which the trailing price physically tracks toward the margin bands.")
i_alphaT      = input.float(0.0,    "α_trail [TSA Eq.10] (Set 0 for hold)",minval=0.0,   maxval=1.0,  step=0.1,   group="Reward", tooltip="Weight applied to the trailing reward—how much the AI cares about hugging the trend vs making raw profit.")
i_alphaP      = input.float(1.0,    "α_pnl   [TSA Eq.10]",         minval=0.0,   maxval=1.0,  step=0.1,   group="Reward", tooltip="Weight applied to the PnL reward—how much the AI cares about making raw cash profit.")
i_inertia     = input.float(0.05,   "Action Inertia (Q-Margin)",   minval=0.0,   maxval=0.5,  step=0.01,  group="Reward", tooltip="Confidence threshold to flip trades. The AI's alternative decision score must beat its current position's score by exactly this much to execute an exit, stopping micro-scalps.")
i_rewWin      = input.int(50,       "Reward Norm Window [TSA Eq.7]",minval=10,   maxval=200,              group="Reward", tooltip="Lookback window used to mathematically normalize the rewards.")

// Display
i_showSig     = input.bool(true,    "Show Trail Price pa(t)",     group="Display")
i_showBands   = input.bool(false,   "Show Margin Bands",          group="Display")
i_showTrade   = input.bool(true,    "Show Entry/Exit Signals",    group="Display")
i_showTable   = input.bool(true,    "Show Stats Table",           group="Display")
i_debug       = input.bool(true,    "Enable Debug Logging",       group="Display")
i_tblPos      = input.string("Top Right","Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Display")
i_bullCol     = input.color(#05ff9b, "Bull Color", group="Display")
i_bearCol     = input.color(#ff0583, "Bear Color", group="Display")

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 2: CONSTANTS  [LEE Table 3: 16 inputs, SEM: 16→12→6→3]
// ───────────────────────────────────────────────────────────────────────────────

int BUY  = 0
int SELL = 1
int HOLD = 2
int NI   = 16   // 14 wavelet + 2 agent state (LEE Table 3)
int NH1  = 12
int NH2  = 6
int NO   = 3

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 3: HELPER — Z-score normalisation  [SEM §Results preprocessing]
// ───────────────────────────────────────────────────────────────────────────────

norm(series float x, simple int win) =>
    float mu = ta.sma(x, win)
    float sg = ta.stdev(x, win)
    float sf = nz(sg) < 1e-10 ? 1.0 : sg
    float res = (x - nz(mu, x)) / sf
    na(res) ? 0.0 : res

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 4: WEIGHT MATRICES  [SEM 16→12→6→3, Xavier init]
// ───────────────────────────────────────────────────────────────────────────────

var matrix<float> W1 = matrix.new<float>(NI,  NH1, 0.0)
var matrix<float> W2 = matrix.new<float>(NH1, NH2, 0.0)
var matrix<float> W3 = matrix.new<float>(NH2, NO,  0.0)
var array<float>  B1 = array.new<float>(NH1, 0.0)
var array<float>  B2 = array.new<float>(NH2, 0.0)
var array<float>  B3 = array.new<float>(NO,  0.0)

// Target Networks
var matrix<float> W1_t = matrix.new<float>(NI,  NH1, 0.0)
var matrix<float> W2_t = matrix.new<float>(NH1, NH2, 0.0)
var matrix<float> W3_t = matrix.new<float>(NH2, NO,  0.0)
var array<float>  B1_t = array.new<float>(NH1, 0.0)
var array<float>  B2_t = array.new<float>(NH2, 0.0)
var array<float>  B3_t = array.new<float>(NO,  0.0)

if barstate.isfirst
    for i = 0 to NI - 1
        for j = 0 to NH1 - 1
            W1.set(i, j, (math.random(0.0, 1.0) - 0.5) * 2.0 * math.sqrt(2.0 / float(NI + NH1)))
    for i = 0 to NH1 - 1
        for j = 0 to NH2 - 1
            W2.set(i, j, (math.random(0.0, 1.0) - 0.5) * 2.0 * math.sqrt(2.0 / float(NH1 + NH2)))
    for i = 0 to NH2 - 1
        for j = 0 to NO - 1
            W3.set(i, j, (math.random(0.0, 1.0) - 0.5) * 2.0 * math.sqrt(2.0 / float(NH2 + NO)))
    
    W1_t := matrix.copy(W1)
    W2_t := matrix.copy(W2)
    W3_t := matrix.copy(W3)
    B1_t := array.copy(B1)
    B2_t := array.copy(B2)
    B3_t := array.copy(B3)

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 5: PERSISTENT STATE
// ───────────────────────────────────────────────────────────────────────────────

var int   pos       = 0        // current position: 1=long, -1=short, 0=flat
var int   prevPos   = 0
var int   barsHold  = 0        // Tracks how many bars the trade has been open
var float entryPx   = 0.0
var float pa        = na       // agent trailing price [TSA §III-D]
var int   prevAct   = HOLD
var float prevR     = 0.0

// Gradient Accumulators
var matrix<float> gW1_acc = matrix.new<float>(NI,  NH1, 0.0)
var matrix<float> gW2_acc = matrix.new<float>(NH1, NH2, 0.0)
var matrix<float> gW3_acc = matrix.new<float>(NH2, NO,  0.0)
var array<float>  gB1_acc = array.new<float>(NH1, 0.0)
var array<float>  gB2_acc = array.new<float>(NH2, 0.0)
var array<float>  gB3_acc = array.new<float>(NO,  0.0)
var int           accumCount = 0

// Previous-bar activations for backprop
var array<float> pX   = array.new<float>(NI,  0.0)
var array<float> pH1  = array.new<float>(NH1, 0.0)
var array<float> pH1r = array.new<float>(NH1, 0.0)
var array<float> pH2  = array.new<float>(NH2, 0.0)
var array<float> pH2r = array.new<float>(NH2, 0.0)
var array<float> pOut = array.new<float>(NO,  0.0)

// Stats
var int   totTrades = 0
var int   totWins   = 0
var float totPnl    = 0.0
var bool  pruned    = false

if barstate.isfirst
    pa := close

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 6: FEATURE EXTRACTION  [LEE §4.1, §4.3.1, Table 3]
// ───────────────────────────────────────────────────────────────────────────────
//
// Base series (7): Open, Close, Volume, MA5_Close, MA10_Close, MA5_Vol, MA10_Vol
// Haar MODWT level-1 smooth V1(t) = (f(t) + f(t-1)) / 2
// Haar MODWT level-1 detail D1(t) = (f(t) - f(t-1)) / 2  [LEE §3.1, used as input]
// Haar MODWT level-2 detail D2(t) = (V1(t) - V1(t-2)) / 2
// Features [0..6] = D1, features [7..13] = D2  → 14 wavelet features
// Features [14..15] = agent state (Changed Stocks Ratio, Portfolio Return)
// = 16 total  [LEE Table 3, HW LSTM RL column]

float f0 = open
float f1 = close
float f2 = nz(volume, 1.0)
float f3 = ta.sma(close, 5)
float f4 = ta.sma(close, 10)
float f5 = ta.sma(nz(volume, 1.0), 5)
float f6 = ta.sma(nz(volume, 1.0), 10)

// MODWT Haar level-1 smooth
float v1_0 = (f0 + nz(f0[1], f0)) / 2.0
float v1_1 = (f1 + nz(f1[1], f1)) / 2.0
float v1_2 = (f2 + nz(f2[1], f2)) / 2.0
float v1_3 = (f3 + nz(f3[1], f3)) / 2.0
float v1_4 = (f4 + nz(f4[1], f4)) / 2.0
float v1_5 = (f5 + nz(f5[1], f5)) / 2.0
float v1_6 = (f6 + nz(f6[1], f6)) / 2.0

// D1 — level-1 Haar detail (high-frequency component)
float d1_0 = (f0 - nz(f0[1], f0)) / 2.0
float d1_1 = (f1 - nz(f1[1], f1)) / 2.0
float d1_2 = (f2 - nz(f2[1], f2)) / 2.0
float d1_3 = (f3 - nz(f3[1], f3)) / 2.0
float d1_4 = (f4 - nz(f4[1], f4)) / 2.0
float d1_5 = (f5 - nz(f5[1], f5)) / 2.0
float d1_6 = (f6 - nz(f6[1], f6)) / 2.0

// D2 — level-2 Haar detail (detail of the smooth)
float d2_0 = (v1_0 - nz(v1_0[2], v1_0)) / 2.0
float d2_1 = (v1_1 - nz(v1_1[2], v1_1)) / 2.0
float d2_2 = (v1_2 - nz(v1_2[2], v1_2)) / 2.0
float d2_3 = (v1_3 - nz(v1_3[2], v1_3)) / 2.0
float d2_4 = (v1_4 - nz(v1_4[2], v1_4)) / 2.0
float d2_5 = (v1_5 - nz(v1_5[2], v1_5)) / 2.0
float d2_6 = (v1_6 - nz(v1_6[2], v1_6)) / 2.0

// Agent state [LEE Table 3: "Changed Stocks ratio" ≈ pos, "Portfolio return"]
float portRet = pos != 0 and entryPx > 0 ? (close - entryPx) / entryPx * float(pos) : 0.0

// Build 16-dim normalised feature vector
array<float> feat = array.new<float>(NI, 0.0)
feat.set(0,  norm(d1_0, i_normWin))
feat.set(1,  norm(d1_1, i_normWin))
feat.set(2,  norm(d1_2, i_normWin))
feat.set(3,  norm(d1_3, i_normWin))
feat.set(4,  norm(d1_4, i_normWin))
feat.set(5,  norm(d1_5, i_normWin))
feat.set(6,  norm(d1_6, i_normWin))
feat.set(7,  norm(d2_0, i_normWin))
feat.set(8,  norm(d2_1, i_normWin))
feat.set(9,  norm(d2_2, i_normWin))
feat.set(10, norm(d2_3, i_normWin))
feat.set(11, norm(d2_4, i_normWin))
feat.set(12, norm(d2_5, i_normWin))
feat.set(13, norm(d2_6, i_normWin))
feat.set(14, float(pos))                   // agent position state
feat.set(15, norm(portRet, i_normWin))     // portfolio return state

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 7: FORWARD PASS — MLP with Leaky ReLU
// ───────────────────────────────────────────────────────────────────────────────

array<float> h1r = array.new<float>(NH1, 0.0)
array<float> h1  = array.new<float>(NH1, 0.0)
for j = 0 to NH1 - 1
    float s = B1.get(j)
    for i = 0 to NI - 1
        s += feat.get(i) * W1.get(i, j)
    h1r.set(j, s)
    h1r.set(j, s)
    h1.set(j, s > 0 ? s : 0.01 * s)

array<float> h2r = array.new<float>(NH2, 0.0)
array<float> h2  = array.new<float>(NH2, 0.0)
for j = 0 to NH2 - 1
    float s = B2.get(j)
    for i = 0 to NH1 - 1
        s += h1.get(i) * W2.get(i, j)
    h2r.set(j, s)
    h2.set(j, s > 0 ? s : 0.01 * s)

array<float> Q = array.new<float>(NO, 0.0)
for j = 0 to NO - 1
    float s = B3.get(j)
    for i = 0 to NH2 - 1
        s += h2.get(i) * W3.get(i, j)
    Q.set(j, s)

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 8: ACTION SELECTION  [LEE §3.3, Eq. 11]
// ───────────────────────────────────────────────────────────────────────────────

// LEE Eq. 11 adaptation: We linearly decay ε over the burn-in period to guarantee exploration, maintaining a 5% baseline for regime changes.
float epsilon = bar_index <= i_burnIn ? math.max(0.05, i_epsStart_val * (1.0 - (float(bar_index) / float(i_burnIn)))) : 0.05
bool  explore = math.random(0.0, 1.0) < epsilon

// Greedy action with Inertia (Hysteresis) to prevent micro-scalps
int   qArg    = prevAct
float qMx     = Q.get(prevAct)

int   bestAct = 0
float bestQ   = Q.get(0)
if Q.get(1) > bestQ
    bestQ   := Q.get(1)
    bestAct := 1
if Q.get(2) > bestQ
    bestQ   := Q.get(2)
    bestAct := 2

// Only switch state if the alternative Q-value confidently beats the current state's Q-value
if bestQ > Q.get(prevAct) + i_inertia
    qArg := bestAct
    qMx  := bestQ
else
    qArg := prevAct
    qMx  := Q.get(prevAct)

// Action execution
int act    = explore ? math.min(int(math.floor(math.random(0.0, 2.999))), 2) : qArg
int newPos = act == BUY ? 1 : act == SELL ? -1 : 0

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 9: REWARD COMPUTATION  [TSA §III-C,D Eq.1,5,7,9,10 + LEE §4.3.3]
// ───────────────────────────────────────────────────────────────────────────────

float cRet = nz((close - close[1]) / close[1], 0.0)

// --- Margin bands [TSA Eq. 3-4] ---
float pum = close * (1.0 + i_margin)   // upper margin
float plm = close * (1.0 - i_margin)   // lower margin

// --- Trail reward [TSA Eq. 5] ---
float rT = 1.0 - math.abs(nz(pa, close) - close) / (i_margin * close + 1e-10)

// --- Update pa(t) [TSA Eq. 6] — AFTER computing rT ---
// pa moves toward upper or lower margin by step υ depending on action
float paCur = nz(pa, close)
pa := act == BUY  ? paCur + i_step * math.abs(paCur - pum) :
      act == SELL ? paCur - i_step * math.abs(paCur - plm) :
      paCur  // HOLD: pa stays (TSA "stay action")
// Clamp within band
pa := math.max(plm, math.min(pum, pa))

// --- PnL reward [TSA Eq. 1]: r_PnL = δt * zt ---
float rP = float(pos) * cRet

// --- Simplified additive shaping factor based on per-bar direction ---
float leeBonus = 0.0
if pos != 0
    leeBonus := rP > 0 ? 1.0 : rP < 0 ? -1.0 : 0.0

// --- Reward normalisation [TSA Eq. 7, 9] ---
float sZ    = nz(ta.stdev(cRet, i_rewWin), 1.0)
sZ         := sZ < 1e-10 ? 1.0 : sZ
float mAZ   = nz(ta.sma(math.abs(cRet), i_rewWin), 1.0)
mAZ        := mAZ < 1e-10 ? 1.0 : mAZ

float rTn   = rT  * mAZ / sZ    // TSA Eq. 9
float rPn   = rP / sZ           // TSA Eq. 7

// scale down Lee bonus to match approx range of [-1, 1]
float rLee  = leeBonus / 5.0    

// --- Combined reward [TSA Eq. 10] + Lee shaping ---
float R = i_alphaT * rTn + i_alphaP * rPn + 0.1 * rLee

// --- Debug Logging ---
if barstate.islast
    log.info("Bar {0} | POS: {1} | ACT: {2} | Explore: {3}", bar_index, pos, act==0 ? "BUY" : act==1 ? "SELL" : "HOLD", explore)
    log.info("Q-Values  | Q(B): {0} | Q(S): {1} | Q(H): {2}", str.tostring(Q.get(0), "#.###"), str.tostring(Q.get(1), "#.###"), str.tostring(Q.get(2), "#.###"))
    log.info("Rewards   | R(Total): {0} | rP(PnL): {1} | rT(Trail): {2} | rLee: {3}", str.tostring(R, "#.####"), str.tostring(rP, "#.####"), str.tostring(rT, "#.####"), str.tostring(leeBonus, "#.####"))

// Sharpe [LEE §3.5 Eq. 28]
float sRt    = float(pos) * cRet
float sharpe = nz(ta.sma(sRt, 20) / (ta.stdev(sRt, 20) + 1e-10), 0.0)

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 10: BACKPROPAGATION + GRADIENT ACCUMULATION  [LEE Eq.13-15]
// ───────────────────────────────────────────────────────────────────────────────

// Update target network every i_targetLag bars
if bar_index > 0 and bar_index % i_targetLag == 0
    W1_t := matrix.copy(W1)
    W2_t := matrix.copy(W2)
    W3_t := matrix.copy(W3)
    B1_t := array.copy(B1)
    B2_t := array.copy(B2)
    B3_t := array.copy(B3)

// Evaluate next state (feat) on target network
array<float> ht1 = array.new<float>(NH1, 0.0)
for j = 0 to NH1 - 1
    float s = B1_t.get(j)
    for i = 0 to NI - 1
        s += feat.get(i) * W1_t.get(i, j)
    ht1.set(j, s > 0 ? s : 0.01 * s)

array<float> ht2 = array.new<float>(NH2, 0.0)
for j = 0 to NH2 - 1
    float s = B2_t.get(j)
    for i = 0 to NH1 - 1
        s += ht1.get(i) * W2_t.get(i, j)
    ht2.set(j, s > 0 ? s : 0.01 * s)

array<float> Qt = array.new<float>(NO, 0.0)
for j = 0 to NO - 1
    float s = B3_t.get(j)
    for i = 0 to NH2 - 1
        s += ht2.get(i) * W3_t.get(i, j)
    Qt.set(j, s)

float max_qt = math.max(Qt.get(0), math.max(Qt.get(1), Qt.get(2)))

bool canLearn = bar_index > 0 and not na(R)

if canLearn
    // Bellman target uses max Q-value from the target network for decoupling
    float tgt = R + i_gamma * max_qt
    float td  = tgt - pOut.get(prevAct)
    float hg  = math.abs(td) < 1.0 ? td : math.sign(td)  // Huber clip

    // Output gradient — only for taken action
    array<float> g3 = array.new<float>(NO, 0.0)
    g3.set(prevAct, hg)

    // δ2 = (δ3 @ W3ᵀ) ⊙ lrelu'(h2_pre)
    array<float> g2 = array.new<float>(NH2, 0.0)
    for j = 0 to NH2 - 1
        float s = 0.0
        for k = 0 to NO - 1
            s += g3.get(k) * W3.get(j, k)
        g2.set(j, s * (pH2r.get(j) > 0.0 ? 1.0 : 0.01))

    // δ1 = (δ2 @ W2ᵀ) ⊙ lrelu'(h1_pre)
    array<float> g1 = array.new<float>(NH1, 0.0)
    for j = 0 to NH1 - 1
        float s = 0.0
        for k = 0 to NH2 - 1
            s += g2.get(k) * W2.get(j, k)
        g1.set(j, s * (pH1r.get(j) > 0.0 ? 1.0 : 0.01))

    // Accumulate gradients
    for i = 0 to NH2 - 1
        for j = 0 to NO - 1
            gW3_acc.set(i, j, gW3_acc.get(i, j) + pH2.get(i) * g3.get(j))
    for j = 0 to NO - 1
        gB3_acc.set(j, gB3_acc.get(j) + g3.get(j))
    for i = 0 to NH1 - 1
        for j = 0 to NH2 - 1
            gW2_acc.set(i, j, gW2_acc.get(i, j) + pH1.get(i) * g2.get(j))
    for j = 0 to NH2 - 1
        gB2_acc.set(j, gB2_acc.get(j) + g2.get(j))
    for i = 0 to NI - 1
        for j = 0 to NH1 - 1
            gW1_acc.set(i, j, gW1_acc.get(i, j) + pX.get(i) * g1.get(j))
    for j = 0 to NH1 - 1
        gB1_acc.set(j, gB1_acc.get(j) + g1.get(j))

    accumCount += 1

    // Apply averaged update every i_accumSteps bars
    if accumCount >= i_accumSteps
        float sc  = 1.0 / float(accumCount)
        float clr = bar_index <= i_burnIn ? i_lr * i_lrBoost : i_lr

        for i = 0 to NH2 - 1
            for j = 0 to NO - 1
                float dw = gW3_acc.get(i, j) * sc
                W3.set(i, j, W3.get(i, j) + clr * dw - clr * i_l2 * W3.get(i, j))
        for j = 0 to NO - 1
            B3.set(j, B3.get(j) + clr * gB3_acc.get(j) * sc)

        for i = 0 to NH1 - 1
            for j = 0 to NH2 - 1
                float dw = gW2_acc.get(i, j) * sc
                W2.set(i, j, W2.get(i, j) + clr * dw - clr * i_l2 * W2.get(i, j))
        for j = 0 to NH2 - 1
            B2.set(j, B2.get(j) + clr * gB2_acc.get(j) * sc)

        for i = 0 to NI - 1
            for j = 0 to NH1 - 1
                float dw = gW1_acc.get(i, j) * sc
                W1.set(i, j, W1.get(i, j) + clr * dw - clr * i_l2 * W1.get(i, j))
        for j = 0 to NH1 - 1
            B1.set(j, B1.get(j) + clr * gB1_acc.get(j) * sc)

        // Reset accumulators
        gW3_acc  := matrix.new<float>(NH2, NO,  0.0)
        gW2_acc  := matrix.new<float>(NH1, NH2, 0.0)
        gW1_acc  := matrix.new<float>(NI,  NH1, 0.0)
        gB3_acc  := array.new<float>(NO,  0.0)
        gB2_acc  := array.new<float>(NH2, 0.0)
        gB1_acc  := array.new<float>(NH1, 0.0)
        accumCount := 0

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 11: LINK PRUNING  [SEM §Link Pruning — W3 stays full]
// ───────────────────────────────────────────────────────────────────────────────

if bar_index == i_pruneBar and not pruned
    array<float> absW = array.new<float>(0)
    for i = 0 to NI - 1
        for j = 0 to NH1 - 1
            absW.push(math.abs(W1.get(i, j)))
    for i = 0 to NH1 - 1
        for j = 0 to NH2 - 1
            absW.push(math.abs(W2.get(i, j)))
    absW.sort(order.ascending)
    int pidx = math.min(int(math.floor(float(absW.size()) * i_prunePct / 100.0)), absW.size() - 1)
    float thr = absW.get(pidx)
    for i = 0 to NI - 1
        for j = 0 to NH1 - 1
            if math.abs(W1.get(i, j)) <= thr
                W1.set(i, j, 0.0)
    for i = 0 to NH1 - 1
        for j = 0 to NH2 - 1
            if math.abs(W2.get(i, j)) <= thr
                W2.set(i, j, 0.0)
    pruned := true

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 12: STORE STATE FOR NEXT BAR
// ───────────────────────────────────────────────────────────────────────────────

prevR   := R
prevAct := act
pX      := array.copy(feat)
pH1     := array.copy(h1)
pH1r    := array.copy(h1r)
pH2     := array.copy(h2)
pH2r    := array.copy(h2r)
pOut    := array.copy(Q)

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 13: TRADE MANAGEMENT & STATISTICS
// ───────────────────────────────────────────────────────────────────────────────

bool closeTrd = pos != 0 and newPos != pos
bool openTrd  = newPos != 0 and newPos != pos

float tPnl = 0.0
if closeTrd and entryPx > 0
    tPnl      := (close - entryPx) / entryPx * float(pos) * 100.0
    totTrades += 1
    totPnl    += tPnl
    if tPnl > 0.0
        totWins += 1

if openTrd
    entryPx := close

bool buySig  = openTrd  and newPos ==  1
bool sellSig = openTrd  and newPos == -1
bool exitSig = closeTrd and newPos ==  0

prevPos := pos
pos := newPos

if pos != 0 and pos == prevPos
    barsHold += 1
else if pos != prevPos and pos != 0
    barsHold := 1
else
    barsHold := 0

// Reset stats at end of burn-in so table reflects live trading only
if bar_index == i_burnIn
    totTrades := 0
    totWins   := 0
    totPnl    := 0.0

bool showVis = bar_index > i_burnIn

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 14: PLOTS
// ───────────────────────────────────────────────────────────────────────────────

// pa(t) — agent's trailing price [TSA §III-D]
color sigCol = pos == 1 ? i_bullCol : pos == -1 ? i_bearCol : color.gray
plot(i_showSig and showVis ? pa : na, "Trail Price pa(t)", sigCol, 1)

// Margin bands [TSA Eq. 3-4]
plot(i_showBands and showVis ? close * (1.0 + i_margin) : na, "Upper Margin", color.new(i_bullCol, 75), 1)
plot(i_showBands and showVis ? close * (1.0 - i_margin) : na, "Lower Margin", color.new(i_bearCol, 75), 1)

// Entry / exit labels
color xCol = tPnl > 0.0 ? color.green : color.red
plotshape(i_showTrade and showVis and buySig  ? low   : na, "BUY",  shape.triangleup,   location.belowbar, i_bullCol, text="BUY",  textcolor=i_bullCol, size=size.tiny)
plotshape(i_showTrade and showVis and sellSig ? high  : na, "SELL", shape.triangledown, location.abovebar, i_bearCol, text="SELL", textcolor=i_bearCol, size=size.tiny)
plotshape(i_showTrade and showVis and exitSig ? close : na, "EXIT", shape.circle,       location.absolute, xCol,      text="EXIT", textcolor=color.white, size=size.tiny)

// Bar colouring by position
barcolor(showVis and pos == 1 ? color.new(i_bullCol, 80) : showVis and pos == -1 ? color.new(i_bearCol, 80) : na)

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 15: STATS TABLE
// ───────────────────────────────────────────────────────────────────────────────

tP = switch i_tblPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table tbl = table.new(tP, 2, 16, bgcolor=#1a1a2e, border_color=#30305a, border_width=1, frame_color=#30305a, frame_width=2)

if barstate.islast and i_showTable
    tbl.cell(0, 0, "Machine Learning:\nseMLP Q-Wavelet RL Engine\n[Jamallo]", text_color=color.white, text_size=size.small, bgcolor=#16213e)
    tbl.merge_cells(0, 0, 1, 0)

    string posStr = pos == 1 ? "LONG" : pos == -1 ? "SHORT" : "FLAT"
    color  posCol = pos == 1 ? i_bullCol : pos == -1 ? i_bearCol : color.gray
    tbl.cell(0, 1, "Position",    text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 1, posStr,        text_color=posCol,        text_size=size.tiny)

    tbl.cell(0, 2, "Trades",      text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 2, str.tostring(totTrades),                 text_color=color.white, text_size=size.tiny)

    float wr = totTrades > 0 ? float(totWins) / float(totTrades) * 100.0 : 0.0
    tbl.cell(0, 3, "Win Rate",    text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 3, str.tostring(wr, "#.#") + "%",          text_color=wr > 50 ? i_bullCol : i_bearCol, text_size=size.tiny)

    tbl.cell(0, 4, "Total PnL",   text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 4, (totPnl >= 0 ? "+" : "") + str.tostring(totPnl, "#.##") + "%", text_color=totPnl >= 0 ? i_bullCol : i_bearCol, text_size=size.tiny)

    float avgT = totTrades > 0 ? totPnl / float(totTrades) : 0.0
    tbl.cell(0, 5, "Avg Trade",   text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 5, (avgT >= 0 ? "+" : "") + str.tostring(avgT, "#.##") + "%", text_color=avgT >= 0 ? i_bullCol : i_bearCol, text_size=size.tiny)

    tbl.cell(0, 6, "Sharpe",      text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 6, str.tostring(sharpe, "#.##"),            text_color=sharpe > 0 ? i_bullCol : i_bearCol, text_size=size.tiny)

    tbl.cell(0, 7, "ε (epsilon)", text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 7, str.tostring(epsilon, "#.####"),         text_color=color.gray, text_size=size.tiny)

    tbl.cell(0, 8, "rP (PnL Rew)", text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 8, str.tostring(rP, "#.#####"),               text_color=rP > 0 ? i_bullCol : color.white, text_size=size.tiny)

    tbl.cell(0, 9, "Last R",     text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 9, str.tostring(R, "#.#####"),                   text_color=R >= 0 ? i_bullCol : i_bearCol, text_size=size.tiny)

    tbl.cell(0, 10, "Q(B)",       text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 10, str.tostring(Q.get(0), "#.#####"),            text_color=color.white, text_size=size.tiny)

    tbl.cell(0, 11, "Q(S)",       text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 11, str.tostring(Q.get(1), "#.#####"),            text_color=color.white, text_size=size.tiny)

    tbl.cell(0, 12, "Q(H)",       text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 12, str.tostring(Q.get(2), "#.#####"),            text_color=color.white, text_size=size.tiny)

    tbl.cell(0, 13, "Raw Action", text_color=color.gray,   text_size=size.tiny)
    tbl.cell(1, 13, act==0 ? "BUY" : act==1 ? "SELL" : "HOLD",    text_color=color.white, text_size=size.tiny)

// ───────────────────────────────────────────────────────────────────────────────
// SECTION 16: ALERTS
// ───────────────────────────────────────────────────────────────────────────────

alertcondition(buySig,  "ML BUY",  "ML Q-Wavelet RL [Jamallo]: BUY signal")
alertcondition(sellSig, "ML SELL", "ML Q-Wavelet RL [Jamallo]: SELL signal")
alertcondition(exitSig, "ML EXIT", "ML Q-Wavelet RL [Jamallo]: EXIT to flat")
````
