# AI-Powered PDH/PDL Power Ranker [PhenLabs]

- url: https://www.tradingview.com/script/yOOQREkm-AI-Powered-PDH-PDL-Power-Ranker-PhenLabs/
- type: indicator
- pine_id: PUB;01f97e029a1a4b02b40e42c71139d39a
- version: 1.0

## Description

[b]📊 ML-Powered PDH/PDL Power Ranker [PhenLabs][/b]

Version: PineScript™ v6

[b]📌 Description[/b]

ML-Powered PDH/PDL Power Ranker is an adaptive support/resistance indicator that tracks Prior Day High and Prior Day Low levels across a configurable session lookback, then ranks each level on a 0–100 scale based on how strongly price has historically reacted to it.

Instead of treating every PDH and PDL as equally important, this script continuously learns which levels deserve attention. It evaluates live touches, measures the realized rejection after a user-defined confirmation window, and updates each level with either a shared NLMS model or an independent Kalman estimator.

The result is a causal, non-repainting ranking engine that helps traders focus on the strongest daily levels, identify high-confidence reaction zones, and ignore weak or stale liquidity areas.

[b]🚀 Points of Innovation[/b]

[list]
[*]Adaptive level scoring using two genuine learning models: shared NLMS or per-level Kalman filtering
[*]Strictly causal labeling process that waits for confirmed post-touch reaction before updating any score
[*]Feature-based learning framework using wick rejection, relative volume spike, and ATR-normalized approach momentum
[*]Untouched-level score shrinkage logic that prevents zero-evidence levels from outranking proven levels
[*]Session-aware PDH/PDL generation that respects TradingView session boundaries, including extended-hours configurations
[*]Top-ranked dashboard plus high-confidence zone highlighting and touch alerts for fast execution workflow
[/list]

[b]🔧 Core Components[/b]

[list]
[*]PDH/PDL Session Engine: Captures completed-session highs and lows, stores them as active levels, and prunes old levels based on the selected lookback window
[*]ATR Zone Builder: Expands each level into a configurable reaction band using ATR(14), creating realistic touch zones instead of single-price lines
[*]NLMS Learning Model: Uses a normalized least-mean-squares filter to learn a global mapping from touch features to realized reaction quality
[*]Kalman Strength Filter: Maintains an independent latent-strength estimate for each level using scalar Kalman state updates
[*]Causal Touch Resolver: Snapshots features on zone entry, waits a fixed number of bars, then measures realized rejection with no lookahead
[*]Ranking Dashboard: Sorts active levels by display score and shows the strongest zones with age, touch count, and score
[/list]

[b]🔥 Key Features[/b]

[list]
[*]Ranks every active PDH and PDL from 0 to 100 so the best daily levels stand out immediately
[*]Offers two adaptive engines so traders can choose between cross-level learning (NLMS) or level-specific state estimation (Kalman)
[*]Uses entry-based touch detection to avoid overcounting consolidations sitting inside the same zone
[*]Applies ATR-normalized reaction measurement so scoring remains comparable across symbols and volatility regimes
[*]Highlights high-confidence zones directly on the chart when price is trading inside them
[*]Triggers alert conditions when price touches a zone whose score is above the high-confidence threshold
[*]Includes a clean top-5 ranking table so traders can identify the strongest daily levels at a glance
[/list]

[b]🎨 Visualization[/b]

[list]
[*]Dynamic zone boxes show each PDH and PDL as a buffered reaction area rather than a thin horizontal line
[*]Gradient-based score coloring makes weak levels fade cool and strong levels turn hot
[*]On-chart labels display level type, age in sessions, and current score
[*]Optional background highlight marks bars trading inside a high-confidence zone
[*]Ranking dashboard lists the top levels by score along with touch counts and exact price levels
[/list]

[b]📖 Usage Guidelines[/b]

[b]Level Detection[/b]

[list]
[*]Session lookback (days) — Default: 7 — Range: 1 to 15 — Controls how many completed sessions of PDH/PDL levels remain active. Lower values keep the chart cleaner; higher values preserve more historical daily structure.
[*]Zone buffer (× ATR-14) — Default: 0.15 — Range: 0.01 to 2.0 — Sets the half-width of each PDH/PDL zone in ATR units. Increase it for volatile markets; reduce it for tighter precision.
[/list]

[b]Adaptive Model[/b]

[list]
[*]Adaptive model — Default: NLMS — Options: NLMS or Kalman — NLMS learns globally across all resolved touches, while Kalman maintains a separate evolving strength estimate for each level.
[*]Reaction confirmation bars — Default: 6 — Range: 2 to 50 — Defines how long the script waits after a touch before measuring the realized reaction. Larger values emphasize slower reversals; smaller values emphasize immediate rejection.
[*]NLMS step size (μ) — Default: 0.50 — Range: 0.01 to 2.0 — Controls learning speed for the NLMS model. Higher values adapt faster but can be more reactive.
[*]Kalman process noise (Q) — Default: 0.010 — Minimum: 0.0001 — Controls how quickly a level’s true strength is allowed to drift between observations.
[*]Kalman measurement noise (R) — Default: 0.20 — Minimum: 0.001 — Controls how noisy each touch observation is assumed to be. Higher values smooth updates and slow score changes.
[/list]

[b]Display & Alerts[/b]

[list]
[*]Min score to display — Default: 55 — Range: 0 to 100 — Hides weaker levels from the chart while still tracking them internally
[*]High-confidence threshold — Default: 75 — Range: 0 to 100 — Defines which zones qualify for hot-zone highlighting and touch alerts
[*]Show ranking dashboard — Default: true — Toggles the top-ranked PDH/PDL table
[*]Highlight bar inside high-confidence zone — Default: true — Adds background emphasis when price is currently trading inside a strong zone
[/list]

[b]✅ Best Use Cases[/b]

[list]
[*]Intraday trading around prior-day liquidity and reaction zones
[*]Session traders who want objective ranking of PDH/PDL instead of manually judging every level
[*]Futures, indices, forex, and crypto markets where daily highs and lows act as repeat reaction points
[*]Confluence trading alongside structure, liquidity sweeps, VWAP, or order-flow tools
[*]Traders who want non-repainting, evidence-based level scoring instead of static daily levels
[/list]

[b]⚠️ Limitations[/b]

[list]
[*]The model needs resolved touch history before scores become highly informative, so early readings are more neutral
[*]PDH/PDL relevance depends on symbol behavior, session configuration, and timeframe context
[*]Very low-liquidity markets or feeds with weak volume data can reduce the usefulness of the volume-spike feature
[*]This indicator ranks reaction quality at prior-day levels; it does not predict trend direction by itself
[*]Kalman and NLMS may emphasize different behaviors, so traders should test which model best fits their market
[/list]

[b]💡 What Makes This Unique[/b]

[list]
[*]It does not just plot PDH and PDL — it learns which ones actually matter
[*]Its labeling process is fully causal, so model updates occur only after the reaction window has completed
[*]It combines level memory with adaptive inference instead of using a static heuristic score
[*]It prevents untouched levels from dominating the rankings through trust-weighted prior shrinkage
[/list]

[b]🔬 How It Works[/b]

[b]1. Session Level Creation:[/b]

[list]
[*]At each new daily session boundary, the script stores the completed session’s high and low as fresh PDH and PDL levels
[*]Each level is assigned metadata including age, touch count, score state, and pending-observation slots
[/list]

[b]2. Touch Feature Capture:[/b]

[list]
[*]When price enters a zone from outside, the script records three features: wick rejection ratio, relative volume spike, and 3-bar ATR-normalized approach momentum
[*]This entry-only logic prevents repeated relabeling while price chops inside the same zone
[/list]

[b]3. Causal Reaction Resolution:[/b]

[list]
[*]After the selected confirmation window expires, the script measures realized rejection strength in ATR units
[*]That realized move is mapped into a normalized target so the model learns from consistent cross-market observations
[/list]

[b]4. Adaptive Score Update:[/b]

[list]
[*]In NLMS mode, the shared weight vector updates from every resolved observation, then blends the fresh model prediction with that level’s own EMA of realized reactions
[*]In Kalman mode, each level updates its latent strength estimate using scalar predict-and-correct filtering
[/list]

[b]5. Display Ranking and Alerts:[/b]

[list]
[*]The script converts model output into a 0–100 score, ranks active levels, colors zones by strength, and highlights high-confidence areas
[*]An alert condition fires when price touches a zone whose score is already above the selected confidence threshold
[/list]

[i]💡 Note:[/i]
This script is designed to be non-repainting and strictly causal. For best results, use it as a level-prioritization engine inside a broader execution framework that includes market structure, trend context, and risk management.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  AI-Powered PDH/PDL Power Ranker  [PhenLabs]
// ───────────────────────────────────────────────────────────────────────────
//  Tracks Prior Day High / Prior Day Low levels over a configurable session
//  lookback and scores each level 0–100 with a genuinely adaptive model:
//
//    • NLMS  — a shared Normalized Least-Mean-Squares filter learns the
//              mapping  (touch features) → (realized reaction strength)
//              from every resolved touch across all levels. Per-level
//              scores blend the model's prediction with that level's own
//              EMA of realized reactions.
//
//    • Kalman — each level carries an independent scalar Kalman estimator
//              of its "true" reaction strength. Every resolved touch is a
//              noisy measurement; the filter optimally blends it with the
//              prior state given Q (process noise) and R (meas. noise).
//
//  LABELING IS FULLY CAUSAL (non-repainting): when price touches a zone we
//  snapshot features, wait `reactionBars` bars, then measure the realized
//  ATR-normalized rejection and only THEN update the model. No lookahead.
// ═══════════════════════════════════════════════════════════════════════════
indicator("AI-Powered PDH/PDL Power Ranker [PhenLabs]",
     shorttitle      = "PDH/PDL Power Ranker",
     overlay          = true,
     max_lines_count  = 120,
     max_labels_count = 120,
     max_boxes_count  = 120)

// ─────────────────────────────── Inputs ────────────────────────────────────
string GRP_LVL = "Level Detection"
string GRP_MDL = "Adaptive Model"
string GRP_VIS = "Display & Alerts"

int   lookbackDays = input.int(7,     "Session lookback (days)",        minval = 1,    maxval = 15,  group = GRP_LVL,
     tooltip = "How many completed sessions of PDH/PDL levels to keep active.")
float zoneAtrMult  = input.float(0.15,"Zone buffer (× ATR-14)",         minval = 0.01, maxval = 2.0, step = 0.05, group = GRP_LVL,
     tooltip = "Half-width of each zone band, as a multiple of ATR(14).")

string modelType   = input.string("NLMS", "Adaptive model", options = ["NLMS", "Kalman"], group = GRP_MDL)
int   reactionBars = input.int(6,     "Reaction confirmation bars",     minval = 2,    maxval = 50,  group = GRP_MDL,
     tooltip = "Bars to wait after a touch before measuring the realized reaction (keeps labeling causal).")
float nlmsMu       = input.float(0.50,"NLMS step size (μ)",             minval = 0.01, maxval = 2.0, step = 0.05, group = GRP_MDL,
     tooltip = "Adaptation rate. Stable for 0 < μ < 2 thanks to input-power normalization.")
float kalQ         = input.float(0.010,"Kalman process noise (Q)",      minval = 0.0001, step = 0.005, group = GRP_MDL,
     tooltip = "How fast a level's true strength is allowed to drift between touches.")
float kalR         = input.float(0.20, "Kalman measurement noise (R)",  minval = 0.001,  step = 0.01,  group = GRP_MDL,
     tooltip = "How noisy a single touch observation is assumed to be. Higher = slower, smoother updates.")

int   minScore     = input.int(55,    "Min score to display",           minval = 0, maxval = 100, group = GRP_VIS,
     tooltip = "Levels scoring below this are tracked internally but hidden from the chart.")
int   alertScore   = input.int(75,    "High-confidence threshold",      minval = 0, maxval = 100, group = GRP_VIS,
     tooltip = "Used for the background highlight and the touch alert condition.")
bool  showTable    = input.bool(true, "Show ranking dashboard",         group = GRP_VIS)
bool  showBg       = input.bool(true, "Highlight bar inside high-confidence zone", group = GRP_VIS)

// ─────────────── Global series (computed unconditionally) ──────────────────
float atr    = ta.atr(14)          // volatility unit for buffers & reaction normalization
float volSma = ta.sma(volume, 20)  // baseline for the volume-spike feature

// ───────────────────── Persistent level state (parallel arrays) ────────────
// One slot per active level. Oldest level always sits at index 0.
var array<float> lvlPrice  = array.new<float>() // level price
var array<bool>  lvlIsHigh = array.new<bool>()  // true = PDH (resistance), false = PDL (support)
var array<int>   lvlDay    = array.new<int>()   // session index when created (for age / pruning)
var array<int>   lvlTime   = array.new<int>()   // open time (ms) at creation — time anchors have no buffer limit
var array<float> lvlScore  = array.new<float>() // last computed score (0–100)
var array<int>   lvlTouch  = array.new<int>()   // resolved touch count
var array<float> lvlEma    = array.new<float>() // EMA of realized reactions (NLMS blend term)
var array<float> kalX      = array.new<float>() // Kalman state estimate  x̂ (per level)
var array<float> kalP      = array.new<float>() // Kalman error covariance P (per level)
// Pending (unresolved) touch observation, one at a time per level:
var array<bool>  lvlInPrev = array.new<bool>()  // was price inside this zone last bar?
var array<int>   pendBar   = array.new<int>()   // bar of touch, -1 = none pending
var array<float> pendF1    = array.new<float>() // feature: wick rejection ratio
var array<float> pendF2    = array.new<float>() // feature: volume spike
var array<float> pendF3    = array.new<float>() // feature: approach momentum

// Shared NLMS weight vector: [bias, wick, volume, momentum].
// Bias initialized at 0.5 → an untrained model outputs a neutral prior.
var array<float> nlmsW = array.from(0.5, 0.0, 0.0, 0.0)

// Session tracking
var float dHigh    = high
var float dLow     = low
var int   dayCount = 0
var int   totalObs = 0   // total resolved observations (global model sample size)

// ───────────────────────────── Helper functions ────────────────────────────
clamp01(float x) =>
    math.max(0.0, math.min(1.0, x))

// NLMS forward pass: ŷ = w0 + w1·f1 + w2·f2 + w3·f3
nlmsPredict(float f1, float f2, float f3) =>
    array.get(nlmsW, 0) + array.get(nlmsW, 1) * f1 + array.get(nlmsW, 2) * f2 + array.get(nlmsW, 3) * f3

// NLMS weight update:  w ← w + μ · e · x / (ε + ‖x‖²)
// Normalizing by input power makes the step size scale-invariant and keeps
// the filter stable for any 0 < μ < 2 (classic NLMS convergence condition).
nlmsUpdate(float f1, float f2, float f3, float target) =>
    float pred = nlmsPredict(f1, f2, f3)
    float err  = target - pred
    float pwr  = 1.0 + f1 * f1 + f2 * f2 + f3 * f3   // ε folded into bias term (=1)
    float g    = nlmsMu * err / pwr
    array.set(nlmsW, 0, array.get(nlmsW, 0) + g)        // bias input is 1
    array.set(nlmsW, 1, array.get(nlmsW, 1) + g * f1)
    array.set(nlmsW, 2, array.get(nlmsW, 2) + g * f2)
    array.set(nlmsW, 3, array.get(nlmsW, 3) + g * f3)

// Drop the oldest level (index 0) from every parallel array.
removeOldest() =>
    array.shift(lvlPrice)
    array.shift(lvlIsHigh)
    array.shift(lvlDay)
    array.shift(lvlTime)
    array.shift(lvlScore)
    array.shift(lvlTouch)
    array.shift(lvlEma)
    array.shift(kalX)
    array.shift(kalP)
    array.shift(lvlInPrev)
    array.shift(pendBar)
    array.shift(pendF1)
    array.shift(pendF2)
    array.shift(pendF3)

// Register a freshly completed session's high or low as a new level.
pushLevel(float p, bool isH) =>
    array.push(lvlPrice,  p)
    array.push(lvlIsHigh, isH)
    array.push(lvlDay,    dayCount)
    array.push(lvlTime,   time)
    array.push(lvlScore,  50.0)   // neutral until evidence arrives
    array.push(lvlTouch,  0)
    array.push(lvlEma,    float(na))
    array.push(kalX,      0.5)    // Kalman prior: neutral strength
    array.push(kalP,      1.0)    // high initial uncertainty → first touch dominates
    array.push(lvlInPrev, false)
    array.push(pendBar,  -1)
    array.push(pendF1,    0.0)
    array.push(pendF2,    0.0)
    array.push(pendF3,    0.0)

// Score shown to the user.
// Touched levels: the full evidence-based model score.
// Untouched levels: a SHRUNKEN prior. The raw shared NLMS prior would give
// every untouched level the same (potentially inflated) number and let
// zero-evidence levels out-rank levels with real touch history. Instead:
//   1. Pull the model prior toward neutral 50,
//   2. Weight it by how much training data the model has seen (trust),
//   3. Apply a small recency decay so stale untouched levels fade.
// Net effect: untouched levels live in a ~40–62 band and can never beat a
// level that earned a high score through actual reactions.
dispScore(int i) =>
    if array.get(lvlTouch, i) == 0
        float prior = modelType == "NLMS" ? clamp01(nlmsPredict(0.5, 0.5, 0.5)) : clamp01(array.get(kalX, i))
        float trust = math.min(1.0, totalObs / 30.0)            // 0 → 1 over first 30 observations
        float base  = 0.5 + 0.35 * trust * (prior - 0.5)        // shrink toward neutral
        int   age   = dayCount - array.get(lvlDay, i) + 1
        100.0 * clamp01(base - 0.01 * (age - 1))                // mild staleness penalty
    else
        array.get(lvlScore, i)

// Tiered gradient: 0–40 cool blues, 41–70 fading to neutral gray, 71–100 hot.
scoreColor(float s) =>
    s <= 40 ? color.from_gradient(s, 0,  40,  #2962FF, #26C6DA) :
         s <= 70 ? color.from_gradient(s, 40, 70,  #26C6DA, #9598A1) :
         color.from_gradient(s, 70, 100, #FF9800, #F23645)

// ─────────────────────── Session roll: create / prune levels ───────────────
// timeframe.change("1D") respects the symbol's session settings, so charts
// with extended hours enabled roll PDH/PDL at the true session boundary.
bool newSession = timeframe.change("1D")
float buf = nz(atr) * zoneAtrMult   // zone half-width in price units

if newSession
    dayCount += 1
    if bar_index > 0
        // dHigh / dLow still hold the just-completed session's extremes here.
        pushLevel(dHigh, true)    // PDH
        pushLevel(dLow,  false)   // PDL
        // Prune anything older than the lookback window (oldest is index 0).
        while array.size(lvlDay) > 0 and dayCount - array.get(lvlDay, 0) >= lookbackDays
            removeOldest()
    dHigh := high
    dLow  := low
else
    dHigh := math.max(dHigh, high)
    dLow  := math.min(dLow,  low)

// ───────────────────── Adaptive engine: resolve + detect touches ───────────
bool hotTouch  = false   // fresh touch on a high-confidence level this bar
bool inHotZone = false   // price currently inside a high-confidence zone

int nLevels = array.size(lvlPrice)
if not na(atr) and atr > 0 and nLevels > 0
    for i = 0 to nLevels - 1
        float p   = array.get(lvlPrice, i)
        bool  isH = array.get(lvlIsHigh, i)

        // ── 1) Resolve a pending observation once the confirmation window
        //       has elapsed. Only now do we know the realized reaction, so
        //       only now does the model learn — strictly causal.
        int pb = array.get(pendBar, i)
        if pb >= 0 and bar_index - pb >= reactionBars
            // Realized reaction in ATR units, signed in the rejection
            // direction (PDH rewards a move down, PDL a move up).
            float react  = (isH ? (p - close) : (close - p)) / atr
            // Map [-1 ATR … +3 ATR] → [0 … 1]: a clean breakout scores ~0,
            // no reaction ~0.25, a strong 3-ATR rejection scores 1.
            float target = clamp01((react + 1.0) / 4.0)

            float f1 = array.get(pendF1, i)
            float f2 = array.get(pendF2, i)
            float f3 = array.get(pendF3, i)

            if modelType == "NLMS"
                // Learn globally from this (features → outcome) pair…
                nlmsUpdate(f1, f2, f3, target)
                // …then score this level: blend its own reaction memory
                // (EMA) with the freshly-updated model's prediction.
                float emaPrev = array.get(lvlEma, i)
                float emaNew  = na(emaPrev) ? target : 0.7 * emaPrev + 0.3 * target
                array.set(lvlEma, i, emaNew)
                float pred = clamp01(nlmsPredict(f1, f2, f3))
                array.set(lvlScore, i, 100.0 * clamp01(0.55 * emaNew + 0.45 * pred))
            else
                // Scalar Kalman filter on this level's latent strength x:
                //   Predict:  P ← P + Q          (strength may drift)
                //   Gain:     K = P / (P + R)
                //   Update:   x ← x + K·(z − x),  P ← (1 − K)·P
                float P1 = array.get(kalP, i) + kalQ
                float K  = P1 / (P1 + kalR)
                float x1 = array.get(kalX, i) + K * (target - array.get(kalX, i))
                array.set(kalX, i, x1)
                array.set(kalP, i, (1.0 - K) * P1)
                array.set(lvlScore, i, 100.0 * clamp01(x1))

            array.set(lvlTouch, i, array.get(lvlTouch, i) + 1)
            array.set(pendBar, i, -1)   // slot free for the next touch
            totalObs += 1               // grow the global model's trust budget

        // ── 2) Detect a new touch — on zone ENTRY, not occupancy.
        //       Requiring price to have been OUTSIDE the zone on the prior
        //       bar means a consolidation sitting on a level produces one
        //       observation, not one every reactionBars bars. Without this,
        //       chop floods the shared model with a single level's regime
        //       and skews the global prior.
        bool inside = high >= p - buf and low <= p + buf
        bool entry  = inside and not array.get(lvlInPrev, i)
        if array.get(pendBar, i) < 0 and entry
            float rng = high - low
            // f1 — wick rejection: how much of the bar rejected the level.
            float wick = rng > 0 ? (isH ? (high - close) / rng : (close - low) / rng) : 0.5
            // f2 — volume spike vs. 20-bar baseline (0.5 = neutral when
            //      the symbol has no volume data, e.g. some FX/index feeds).
            float vSpk = na(volume) or na(volSma) or volSma <= 0 ? 0.5 : clamp01(volume / volSma / 3.0)
            // f3 — approach momentum: 3-bar displacement in ATR units.
            float mApr = clamp01(math.abs(close - close[3]) / atr / 3.0)
            array.set(pendBar, i, bar_index)
            array.set(pendF1, i, wick)
            array.set(pendF2, i, vSpk)
            array.set(pendF3, i, mApr)
            if dispScore(i) >= alertScore
                hotTouch := true
        array.set(lvlInPrev, i, inside)   // remember occupancy for next bar

        // ── 3) High-confidence zone occupancy (background highlight).
        if dispScore(i) >= alertScore and inside
            inHotZone := true

// ─────────────────────────────── Visuals ───────────────────────────────────
bgcolor(showBg and inHotZone ? color.new(#FF9800, 85) : na, title = "High-confidence zone highlight")

var array<line>  drLines  = array.new<line>()
var array<label> drLabels = array.new<label>()
var array<box>   drBoxes  = array.new<box>()

if barstate.islast and not na(buf)
    // Wipe and redraw only on the last bar — zero historical clutter.
    for ln in drLines
        line.delete(ln)
    for lb in drLabels
        label.delete(lb)
    for bx in drBoxes
        box.delete(bx)
    array.clear(drLines)
    array.clear(drLabels)
    array.clear(drBoxes)

    // All drawings are anchored with xloc.bar_time. Bar-index anchors hit
    // the historical buffer limit (~10k bars historically, far less on
    // realtime bars), which crashes the script on low timeframes / live
    // charts. Time coordinates have no such limit.
    int msPerBar = timeframe.in_seconds() * 1000
    int xRight   = time + 4 * msPerBar   // float labels a little past the last bar

    int n = array.size(lvlPrice)
    if n > 0
        for i = 0 to n - 1
            float s = dispScore(i)
            if s >= minScore   // minimum-score filter keeps the chart clean
                float p   = array.get(lvlPrice, i)
                bool  isH = array.get(lvlIsHigh, i)
                int   age = dayCount - array.get(lvlDay, i) + 1
                color c   = scoreColor(s)
                int   xL  = array.get(lvlTime, i)
                array.push(drBoxes, box.new(xL, p + buf, xRight, p - buf, xloc = xloc.bar_time,
                     border_color = color.new(c, 60), bgcolor = color.new(c, 86)))
                array.push(drLines, line.new(xL, p, xRight, p, xloc = xloc.bar_time,
                     color = c, width = 2))
                array.push(drLabels, label.new(xRight, p,
                     (isH ? "PDH" : "PDL") + " -" + str.tostring(age) + " | Score: " + str.tostring(s, "#"),
                     xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c, 20),
                     textcolor = #FFFFFF, size = size.small))

// ──────────────────────── Ranking dashboard (top 5) ────────────────────────
var table tbl = table.new(position.top_right, 4, 7,
     bgcolor = color.new(#131722, 15), border_width = 1, border_color = color.new(#9598A1, 80))

if barstate.islast
    table.clear(tbl, 0, 0, 3, 6)
    int n = array.size(lvlPrice)
    if showTable and n > 0
        table.cell(tbl, 0, 0, "Rank",  text_color = #9598A1, text_size = size.small)
        table.cell(tbl, 1, 0, "Level", text_color = #9598A1, text_size = size.small)
        table.cell(tbl, 2, 0, "Touches", text_color = #9598A1, text_size = size.small)
        table.cell(tbl, 3, 0, "Score", text_color = #9598A1, text_size = size.small)
        // Snapshot scores, then selection-sort out the top 5.
        array<float> tmp = array.new<float>()
        for i = 0 to n - 1
            array.push(tmp, dispScore(i))
        int rows = math.min(5, n)
        for r = 1 to rows
            int   bestI = -1
            float bestS = -1.0
            for j = 0 to n - 1
                if array.get(tmp, j) > bestS
                    bestS := array.get(tmp, j)
                    bestI := j
            array.set(tmp, bestI, -2.0)   // mark consumed
            bool isH  = array.get(lvlIsHigh, bestI)
            int  age  = dayCount - array.get(lvlDay, bestI) + 1
            color c   = scoreColor(bestS)
            table.cell(tbl, 0, r, "#" + str.tostring(r), text_color = #D1D4DC, text_size = size.small)
            table.cell(tbl, 1, r, (isH ? "PDH" : "PDL") + " -" + str.tostring(age) + "  (" + str.tostring(array.get(lvlPrice, bestI), format.mintick) + ")",
                 text_color = #D1D4DC, text_size = size.small)
            table.cell(tbl, 2, r, str.tostring(array.get(lvlTouch, bestI)), text_color = #D1D4DC, text_size = size.small)
            table.cell(tbl, 3, r, str.tostring(bestS, "#"), text_color = c, text_size = size.small)

// ─────────────────────────────── Alerts ────────────────────────────────────
alertcondition(hotTouch,
     title   = "High-Confidence Zone Touch",
     message = "Price touched a PDH/PDL zone scoring above the high-confidence threshold")
````
