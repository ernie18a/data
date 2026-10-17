# Probability Staircase Trend Engine [PhenLabs]

- url: https://www.tradingview.com/script/zhLCfyu1-Probability-Staircase-Trend-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;0300e18685034499bcec3d5ce9040e59
- version: 1.0

## Description

📊 Probability Staircase Trend Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
Most trend tools print an arrow and then place targets at fixed 1R, 2R and 3R. They do that no matter how the trend has actually behaved on the symbol and timeframe in front of you. Probability Staircase Trend Engine does something different. It records what happened after every previous trend flip on your chart. Then it places each new target where past flips really got to, and shows how long they took.

Every confirmed flip becomes a tracked shadow trade with a structural stop. The engine measures how far each one ran in your favor before it was stopped, reversed, or timed out. When a new flip prints, it reads that record for similar flips and draws a staircase of three target boxes. T1 is the furthest level most past flips reached. T2 and T3 are progressively less likely extensions. Each box ends at the typical number of bars it took to get there.

It also gives a plain TAKE or SKIP verdict based on whether a simple "take profit at T1" plan has made money on this chart historically. The trader decision it answers: is this trend flip worth taking, where are the realistic targets, and how long should I give them.

🚀 Points of Innovation
[list]
[*]Targets come from an excursion survival curve. Each target is the furthest R-level a chosen share of similar past flips actually reached. Fixed R multiples are not used.
[*]Time-to-target projection: each target box ends at the median number of bars past flips needed to reach that level. The plan shows where and roughly when.
[*]Path-dependent, stop-first accounting: if a bar touches the stop, that bar's favorable move is never credited. Ambiguous bars are counted and shown openly.
[*]A TAKE or SKIP verdict based on the realized expectancy of the T1 plan, including every trade that was stopped, reversed, or timed out.
[*]Context-aware evidence: clean-trend and choppy-trend flips are measured separately. Thin samples fall back to broader pools automatically.
[*]Self-calibrating on any symbol and timeframe. The same settings adapt to crypto, indices, FX, or stocks because the evidence comes from the chart itself.
[/list]

🔧 Core Components
[list]
[*]Efficiency-Adaptive Trend Trail: a Kaufman-efficiency adaptive baseline with an ATR trailing band that ratchets in the trend direction. A close through the trail on a confirmed bar is the flip.
[*]Shadow-Trade Tracker: every flip, taken or skipped, opens a hypothetical trade with a swing-based stop clamped between 0.5 and 3 ATR. It is tracked bar by bar until it is stopped, reversed, or reaches the horizon.
[*]Outcome Ring Buffer: the last 300 resolved flips are stored with direction, trend context, maximum favorable excursion in R, exit result, and the bar count at which each R-level was first reached.
[*]Survival Ladder: at each new flip, the share of similar past flips that reached 0.5R, 1R, 1.5R, 2R, 2.5R, 3R, 4R and 5R is computed. T1, T2 and T3 are read off that curve at the chosen probability thresholds.
[*]Verdict Engine: the average result of "exit at T1, otherwise whatever the trade did" decides TAKE or SKIP. Flips with too little evidence are marked as calibrating.
[/list]

🔥 Key Features
[list]
[*]One clean trade plan per flip: entry, stop zone and three probability-weighted targets, with nothing else on price.
[*]Every target label shows its R-multiple, how often similar flips reached it, and the typical bars needed.
[*]Resolved plans freeze at their exit bar with a check mark on every target that was hit, so the chart keeps an honest visual record.
[*]Three ladder presets (Conservative, Balanced, Aggressive) change how demanding the target probabilities are.
[*]Non-repainting: signals, plans and statistics only update on closed bars.
[*]Works fully on every TradingView plan. It uses only closed-bar OHLC data, with no lower-timeframe or tick requirements.
[*]Four alerts and five Pine Screener columns.
[/list]

🎨 Visualization
[list]
[*]Trend Trail: a single cyan (bull) or pink (bear) line with a soft fill toward price. It breaks cleanly on each flip.
[*]Probability Staircase: up to three translucent boxes stepping away from the entry. Fainter boxes mean lower reach probability. Box length is the typical time to reach that level.
[*]Stop Zone: a grey box from entry to the stop with a dashed border. Its label carries the verdict (TAKE, SKIP or calibrating).
[*]Signal Markers: small triangles offset from the candles for TAKE flips, grey crosses for SKIP flips, and faded triangles while the engine is still calibrating.
[*]Past Plans: previous plans fade and stay frozen at their exit bar, with a check mark on reached targets and a cross on stopped plans.
[*]Dashboard: trend state and context, last flip and verdict, the evidence pool and its size, T1 to T3 with probability and time, edge per trade, live plan progress, record size with stop-first tie count, and the active data mode.
[/list]

📖 Usage Guidelines
Trend Engine
[list]
[*][b]Trend Sensitivity[/b] — Default: Balanced — Options: Fast, Balanced, Slow — Controls the adaptive baseline and the ATR band width. Fast flips more often and suits intraday charts. Slow produces fewer, longer trends.
[*][b]Stop Swing Lookback[/b] — Default: 10 — Range: 3-50 — Bars used to find the swing extreme for the stop. Risk is always clamped between 0.5 and 3 ATR.
[*][b]Plan Horizon (bars)[/b] — Default: 60 — Range: 10-300 — A shadow trade still open after this many bars is closed at the bar's close and recorded.
[/list]
Calibration
[list]
[*][b]Minimum Sample[/b] — Default: 20 — Range: 8-150 — Resolved flips required before a pool is trusted. Higher values give steadier statistics but need more chart history.
[*][b]Target Ladder[/b] — Default: Balanced (60 / 40 / 20%) — Options: Conservative (70 / 50 / 30%), Aggressive (50 / 30 / 15%) — Reach probabilities used to place T1, T2 and T3.
[*][b]Split by Trend Efficiency[/b] — Default: On — Measures clean-trend and choppy-trend flips separately. Turn it off on short histories to pool more evidence.
[/list]
Visuals
[list]
[*][b]Show Probability Staircase[/b] — Default: On — Draws the trade plan boxes and labels.
[*][b]Past Plans Kept[/b] — Default: 2 — Range: 0-5 — Frozen plans kept for context. Active only when the staircase is on.
[*][b]Show SKIP Flips[/b] — Default: On — Grey markers for flips whose evidence was negative.
[*][b]Bull / Bear colors[/b] — Default: cyan / pink — Chosen to read on both dark and light themes.
[*][b]Show Dashboard[/b] and [b]Table Size[/b] — Default: On / Small — Table Size is active only when the dashboard is on.
[/list]

✅ Best Use Cases
[list]
[*]Trend traders who want targets grounded in how their market actually trends, not fixed multiples.
[*]Deciding whether to take or skip a fresh trend flip on a symbol you have not traded before.
[*]Setting realistic time expectations: exiting a trade that has run far past the typical time to T1.
[*]Screening a watchlist for fresh TAKE flips with a positive edge.
[*]Comparing how the same rule behaves across timeframes by switching the chart timeframe and reading the dashboard.
[/list]

⚠️ Limitations
[list]
[*]Statistics are computed from the history loaded on your chart. They describe how this rule behaved in the past on this symbol and timeframe, and they are not a forecast.
[*]Plans only appear after enough flips have resolved. Short histories or very high Minimum Sample values keep the engine in calibrating mode for longer.
[*]OHLC bars do not reveal the order of the high and the low. When a bar touches the stop, the engine assumes the stop came first. This is conservative and can understate results. The dashboard counts how often it happened.
[*]The shadow trades use the flip close as entry and ignore spreads, commissions and slippage.
[*]Because the trend engine flips on closed bars, entries are one bar after the move began. The indicator trades early entries for non-repainting signals.
[/list]

💡 What Makes This Unique
[list]
[*]Measured targets: every target is a probability you can read, taken from the survival curve of past flips on your chart.
[*]Time dimension: target boxes show how long each level usually takes, which few trade-plan tools attempt.
[*]Honest bookkeeping: stop-first handling, full inclusion of losing and timed-out trades, and a visible tie counter.
[*]A verdict with evidence: TAKE or SKIP always comes with the pool it was based on and its sample size.
[/list]

⚙️ Under the Hood
[list]
[*][b]Excursion survival inversion[/b]: each resolved shadow trade stores its maximum favorable excursion in R, measured only on bars before the stop. At a new flip the engine computes S(g), the share of matching past trades whose excursion reached each grid level g. T1, T2 and T3 are the largest g where S(g) meets the ladder thresholds. This replaces arbitrary target spacing with the instrument's own measured behavior.
[*][b]User-defined-type outcome ring buffer[/b]: resolved trades live in an array of Outcome objects capped at 300 entries (oldest evicted first). Each holds direction, context bucket, excursion, exit result and first-reach bar counts for eight R-levels. A method with a switch reads the reach time for any level.
[*][b]Hierarchical evidence pools[/b]: the engine uses the most specific pool with enough samples (same direction and trend context, then same direction, then all flips). The dashboard always shows which pool was used and its size.
[*][b]Median time-to-target projection[/b]: for each chosen target, array.median over the reach times of trades that got there sets the box's right edge. Boxes are drawn with xloc.bar_index into future bars, capped inside TradingView's 500-bar limit.
[*][b]Efficiency-adaptive trail[/b]: a Kaufman efficiency ratio drives the baseline speed, and an ATR band ratchets only in the trend direction. The same ratio, compared with its 200-bar median, labels each flip as clean or choppy.
[*][b]Plan lifecycle objects[/b]: each drawn plan is stored as a Plan object holding its boxes, labels and line. At resolution it is frozen to the exit bar and marked. It is faded when the next plan starts and pruned beyond the kept-plan limit, so object counts stay capped.
[*][b]Data mode / plan note[/b]: no plan-gated features are used. Everything runs on closed-bar OHLC on every TradingView plan, and the dashboard row reads "ALL PLANS · closed-bar OHLC".
[*][b]Screener & alerts[/b]: Pine Screener columns are Signal (+1 long TAKE, -1 short TAKE, ±0.5 other flips), Trend State, Edge at T1 (R per trade), T1 Reach Probability (%), and Bars Since Flip. A useful filter is Signal = 1 and Edge at T1 > 0.2. Alerts: Long TAKE, Short TAKE, Long Flip (any verdict), Short Flip (any verdict).
[/list]

🔬 How It Works
[list=1]
[*]Detect the flip: on each closed bar the adaptive trail ratchets with the trend. A close through it flips direction and creates a signal.
[*]Size the risk: the stop goes beyond the recent swing extreme and is clamped between 0.5 and 3 ATR, defining 1R for the plan.
[*]Read the evidence: the engine selects the most specific pool of similar past flips with enough samples and computes how often each R-level was reached.
[*]Build the staircase: T1, T2 and T3 are placed on the survival curve. Each box ends at the typical bars-to-reach, and fainter boxes mean lower probability.
[*]Issue the verdict: if exiting at T1 has had positive average results in this pool, the flip is TAKE. Otherwise it is SKIP.
[*]Record the outcome: the new flip is tracked as a shadow trade. When it resolves, its result joins the record and the next plan learns from it.
[/list]

[quote]💡 Note:
Give the engine enough history. A few hundred bars with 40 or more resolved flips is a good start, and the dashboard shows exactly how much evidence each plan used. Start with the Balanced presets. Treat SKIP as “this rule has not paid on this chart lately,” not as a signal to trade the other way. Probabilities are descriptive statistics of past behavior on your chart and carry no guarantee. This indicator is an analytical aid for education and research, not financial advice.[/quote]

## Source Code

````pine
//@version=6
// Probability Staircase Trend Engine [PhenLabs]
// Every confirmed trend flip is tracked as a shadow trade. Its path-dependent maximum favorable
// excursion (in R, measured before the stop, the horizon, or the next flip) is written to an
// outcome ring buffer. The next flip reads the survival curve of similar past flips and places
// T1/T2/T3 at the furthest R-levels that were reached by at least 60/40/20% of them (Balanced
// ladder), each box ending at the median bar count it took to get there. A TAKE/SKIP verdict comes
// from the realized expectancy of the "exit at T1" plan on the same evidence pool.
// All-plan: closed-bar OHLC only. No lower-timeframe data, no lookahead, no repainting.
indicator("Probability Staircase Trend Engine [PhenLabs]", shorttitle = "PSTE [PhenLabs]", overlay = true, max_boxes_count = 40, max_labels_count = 40, max_lines_count = 20)

// ───────────────────────────── Enums ─────────────────────────────
enum Sensitivity
    fast     = "Fast"
    balanced = "Balanced"
    slow     = "Slow"

enum Ladder
    conservative = "Conservative (70 / 50 / 30%)"
    balanced     = "Balanced (60 / 40 / 20%)"
    aggressive   = "Aggressive (50 / 30 / 15%)"

enum TableSize
    tiny   = "Tiny"
    small  = "Small"
    normal = "Normal"

// ───────────────────────────── Inputs (13) ─────────────────────────────
const string G1 = "Trend Engine"
const string G2 = "Calibration"
const string G3 = "Visuals"

Sensitivity sensIn = input.enum(Sensitivity.balanced, "Trend Sensitivity", group = G1, tooltip = "Preset for the efficiency-adaptive baseline and its ATR trailing band. Fast = more flips, Slow = fewer, longer trends.")
int stopLen        = input.int(10, "Stop Swing Lookback", minval = 3, maxval = 50, group = G1, tooltip = "Bars used to find the structural swing extreme for the stop. Risk (1R) is clamped between 0.5 and 3 ATR.")
int horizon        = input.int(60, "Plan Horizon (bars)", minval = 10, maxval = 300, group = G1, tooltip = "A shadow trade that has not been stopped or reversed after this many bars is closed and recorded.")
int minN           = input.int(20, "Minimum Sample", minval = 8, maxval = 150, group = G2, tooltip = "Resolved flips required before a pool is trusted. Pools fall back: same direction + context, then same direction, then all flips.")
Ladder ladderIn    = input.enum(Ladder.balanced, "Target Ladder", group = G2, tooltip = "Reach probabilities used to place T1 / T2 / T3 on the survival curve.")
bool useCtx        = input.bool(true, "Split by Trend Efficiency", group = G2, tooltip = "Separate evidence for flips that happen in clean (efficient) vs choppy conditions.")
bool showPlan      = input.bool(true, "Show Probability Staircase", group = G3)
int keepPlans      = input.int(2, "Past Plans Kept", minval = 0, maxval = 5, group = G3, active = showPlan, tooltip = "Resolved plans stay on the chart, frozen at their exit bar, with a check mark on every target that was reached.")
bool showSkip      = input.bool(true, "Show SKIP Flips", group = G3, tooltip = "Grey markers for flips whose evidence says the T1 plan had negative expectancy.")
color bullCol      = input.color(#00A8C6, "Bull", inline = "col", group = G3)
color bearCol      = input.color(#F0457A, "Bear", inline = "col", group = G3)
bool showDash      = input.bool(true, "Show Dashboard", group = G3)
TableSize tblIn    = input.enum(TableSize.small, "Table Size", group = G3, active = showDash)

// ───────────────────────────── Constants ─────────────────────────────
const int   MAX_STORE = 300
const color NEUTRAL   = #8A93A6
const color CLEAR     = #00000000
const color DASH_BG   = #0F131C
const color DASH_TXT  = #D6DAE3

int   erLen   = sensIn == Sensitivity.fast ? 8 : sensIn == Sensitivity.slow ? 14 : 10
int   slowLen = sensIn == Sensitivity.fast ? 20 : sensIn == Sensitivity.slow ? 40 : 30
float bandK   = sensIn == Sensitivity.fast ? 1.0 : sensIn == Sensitivity.slow ? 2.0 : 1.5

float p1 = ladderIn == Ladder.conservative ? 0.70 : ladderIn == Ladder.aggressive ? 0.50 : 0.60
float p2 = ladderIn == Ladder.conservative ? 0.50 : ladderIn == Ladder.aggressive ? 0.30 : 0.40
float p3 = ladderIn == Ladder.conservative ? 0.30 : ladderIn == Ladder.aggressive ? 0.15 : 0.20

string tSz = tblIn == TableSize.tiny ? size.tiny : tblIn == TableSize.normal ? size.normal : size.small

// ───────────────────────────── Types ─────────────────────────────
// One resolved shadow trade. rN = bars from entry until grid level N was first reached (-1 = never).
type Outcome
    int   bucket
    int   dir
    float mfeR
    float exitR
    int   r0 = -1
    int   r1 = -1
    int   r2 = -1
    int   r3 = -1
    int   r4 = -1
    int   r5 = -1
    int   r6 = -1
    int   r7 = -1

// Drawing handles for one plan, so it can be frozen, faded, and pruned as a unit.
type Plan
    box   zStop
    box   z1
    box   z2
    box   z3
    label l1
    label l2
    label l3
    label lS
    line  ent
    int   g1 = -1
    int   g2 = -1
    int   g3 = -1
    color col
    bool  live = true

method reachAt(Outcome this, int g) =>
    int v = switch g
        0 => this.r0
        1 => this.r1
        2 => this.r2
        3 => this.r3
        4 => this.r4
        5 => this.r5
        6 => this.r6
        => this.r7
    v

// ───────────────────────────── Pure helpers ─────────────────────────────
f_inPool(Outcome o, int lvl, int bucket, int dirIdx) =>
    lvl == 0 ? o.bucket == bucket : lvl == 1 ? o.dir == dirIdx : true

// Survival curve, ladder targets and T1-plan expectancy from resolved outcomes only.
f_stats(array<Outcome> store, array<float> grid, int bucket, int dirIdx, int minCount, float q1, float q2, float q3) =>
    int nB = 0
    int nD = 0
    int nA = store.size()
    for o in store
        if o.bucket == bucket
            nB += 1
        if o.dir == dirIdx
            nD += 1
    int lvl = nB >= minCount ? 0 : nD >= minCount ? 1 : nA >= minCount ? 2 : 3
    int n   = lvl == 0 ? nB : lvl == 1 ? nD : nA
    int g1 = -1
    int g2 = -1
    int g3 = -1
    float s1 = na
    float s2 = na
    float s3 = na
    float edge = na
    if lvl < 3 and n > 0
        array<float> surv = array.new<float>(8, 0.0)
        for o in store
            if f_inPool(o, lvl, bucket, dirIdx)
                for g = 0 to 7
                    if o.mfeR >= grid.get(g)
                        surv.set(g, surv.get(g) + 1.0)
        for g = 0 to 7
            surv.set(g, surv.get(g) / n)
        for g = 0 to 7
            float sv = surv.get(g)
            if sv >= q1
                g1 := g
            if sv >= q2
                g2 := g
            if sv >= q3
                g3 := g
        if g2 == g1
            g2 := -1
        int prevG = g2 >= 0 ? g2 : g1
        if g3 == prevG
            g3 := -1
        s1 := g1 >= 0 ? surv.get(math.max(g1, 0)) : na
        s2 := g2 >= 0 ? surv.get(math.max(g2, 0)) : na
        s3 := g3 >= 0 ? surv.get(math.max(g3, 0)) : na
        // Realized expectancy of "take profit at T1 (or 0.5R if no T1), otherwise whatever the trade did".
        float tgt = grid.get(math.max(g1, 0))
        float acc = 0.0
        for o in store
            if f_inPool(o, lvl, bucket, dirIdx)
                acc += o.mfeR >= tgt ? tgt : o.exitR
        edge := acc / n
    [lvl, n, g1, g2, g3, s1, s2, s3, edge]

// Median bars-to-reach for grid level g inside the chosen pool.
f_medBars(array<Outcome> store, int lvl, int bucket, int dirIdx, int g) =>
    float med = na
    if g >= 0 and lvl < 3
        array<int> tmp = array.new<int>()
        for o in store
            int rb = o.reachAt(g)
            if f_inPool(o, lvl, bucket, dirIdx) and rb >= 0
                tmp.push(rb)
        if tmp.size() > 0
            med := tmp.median()
    med

f_rTxt(float r) =>
    str.tostring(r, "#.#") + "R"

f_pctTxt(float s) =>
    na(s) ? "n/a" : str.tostring(math.round(s * 100)) + "%"

f_freezeBox(box b, int atBar) =>
    if not na(b)
        box.set_right(b, math.min(box.get_right(b), atBar))

f_freezeLabel(label l, int atBar, bool mark, string suffix) =>
    if not na(l)
        label.set_x(l, math.min(label.get_x(l), atBar))
        if mark
            label.set_text(l, label.get_text(l) + suffix)

f_fadeBox(box b, color c, int bgT, int bdT) =>
    if not na(b)
        box.set_bgcolor(b, color.new(c, bgT))
        box.set_border_color(b, color.new(c, bdT))

f_fadeLabel(label l, color c) =>
    if not na(l)
        label.set_textcolor(l, color.new(c, 45))

f_eraseBox(box b) =>
    if not na(b)
        box.delete(b)

f_eraseLabel(label l) =>
    if not na(l)
        label.delete(l)

f_drawTarget(int x0, int x1, float yFrom, float yTo, color c, float prob, string txt, string tip) =>
    int bgT = na(prob) ? 88 : math.round(88 - prob * 20)
    box b = box.new(x0, math.max(yFrom, yTo), x1, math.min(yFrom, yTo), border_color = color.new(c, 55), border_width = 1, bgcolor = color.new(c, bgT), xloc = xloc.bar_index)
    label l = label.new(x1, yTo, txt, xloc = xloc.bar_index, yloc = yloc.price, color = CLEAR, style = label.style_label_left, textcolor = c, size = size.small, tooltip = tip)
    [b, l]

// ───────────────────────────── Trend engine (efficiency-adaptive trail) ─────────────────────────────
float atr     = ta.atr(14)
float netMove = math.abs(close - close[erLen])
float pathLen = math.sum(math.abs(ta.change(close)), erLen)
float er      = na(netMove) or na(pathLen) or pathLen <= 0 ? 0.0 : netMove / pathLen
float erMed   = ta.percentile_linear_interpolation(er, 200, 50)
bool cleanCtx = na(erMed) ? er >= 0.30 : er >= erMed

float fastSC = 2.0 / 3.0
float slowSC = 2.0 / (slowLen + 1)
float sc     = math.pow(er * (fastSC - slowSC) + slowSC, 2)
var float kama = na
kama := na(kama) ? close : kama + sc * (close - kama)

float swingLo = ta.lowest(low, stopLen)
float swingHi = ta.highest(high, stopLen)

var float trail = na
var int   trend = 0
bool flipUp = false
bool flipDn = false
if not na(atr)
    float upTrail = kama - bandK * atr
    float dnTrail = kama + bandK * atr
    if trend == 0
        trend := close >= kama ? 1 : -1
        trail := trend == 1 ? upTrail : dnTrail
    else if trend == 1
        trail := math.max(trail, upTrail)
        if close < trail
            trend  := -1
            trail  := dnTrail
            flipDn := true
    else
        trail := math.min(trail, dnTrail)
        if close > trail
            trend  := 1
            trail  := upTrail
            flipUp := true

// Signals exist only on closed bars.
bool sigUp = flipUp and barstate.isconfirmed
bool sigDn = flipDn and barstate.isconfirmed

// ───────────────────────────── Shadow-trade state ─────────────────────────────
var array<float>   grid  = array.from(0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0)
var array<Outcome> store = array.new<Outcome>()
var array<Plan>    plans = array.new<Plan>()
var array<int>     tReach = array.new<int>(8, -1)

var bool  tOpen     = false
var int   tDir      = 0
var int   tBucket   = 0
var int   tStartBar = na
var float tEntry    = na
var float tRisk     = na
var float tStop     = na
var float tMfe      = 0.0
var int   ties      = 0
var int   resolved  = 0
var string lastExit = "—"

// Last plan snapshot for the dashboard and screener columns.
var int   lastDir     = 0
var int   lastVerdict = -1   // 1 TAKE · 0 SKIP · 2 CALIBRATING
var int   lastSigBar  = na
var int   pLvl  = 3
var int   pN    = 0
var int   pG1   = -1
var int   pG2   = -1
var int   pG3   = -1
var float pS1   = na
var float pS2   = na
var float pS3   = na
var float pM1   = na
var float pM2   = na
var float pM3   = na
var float pEdge = na
var bool  pCtxClean = true

// 1) Advance the open shadow trade on the closed bar (stop-first on ambiguous bars).
bool   resolveNow = false
bool   stopped    = false
if barstate.isconfirmed and tOpen and bar_index > tStartBar and tRisk > 0
    bool  stopHit = tDir == 1 ? low <= tStop : high >= tStop
    float barMfe  = tDir == 1 ? (high - tEntry) / tRisk : (tEntry - low) / tRisk
    if stopHit
        bool wouldReach = false
        for g = 0 to 7
            if tReach.get(g) < 0 and barMfe >= grid.get(g)
                wouldReach := true
        if wouldReach
            ties += 1
        resolveNow := true
        stopped    := true
    else
        if barMfe > tMfe
            tMfe := barMfe
            for g = 0 to 7
                if tReach.get(g) < 0 and tMfe >= grid.get(g)
                    tReach.set(g, bar_index - tStartBar)
        if bar_index - tStartBar >= horizon
            resolveNow := true
    if sigUp or sigDn
        resolveNow := true

if resolveNow
    float exitR = stopped ? -1.0 : tDir * (close - tEntry) / tRisk
    Outcome o = Outcome.new(bucket = tBucket, dir = tDir == 1 ? 0 : 1, mfeR = math.max(tMfe, 0.0), exitR = exitR, r0 = tReach.get(0), r1 = tReach.get(1), r2 = tReach.get(2), r3 = tReach.get(3), r4 = tReach.get(4), r5 = tReach.get(5), r6 = tReach.get(6), r7 = tReach.get(7))
    store.push(o)
    if store.size() > MAX_STORE
        store.shift()
    resolved += 1
    lastExit := stopped ? "stopped" : (sigUp or sigDn) ? "reversed" : "horizon"
    tOpen := false
    if plans.size() > 0
        Plan lp = plans.last()
        if lp.live
            f_freezeBox(lp.zStop, bar_index)
            f_freezeBox(lp.z1, bar_index)
            f_freezeBox(lp.z2, bar_index)
            f_freezeBox(lp.z3, bar_index)
            f_freezeLabel(lp.l1, bar_index, lp.g1 >= 0 and tReach.get(math.max(lp.g1, 0)) >= 0, " ✓")
            f_freezeLabel(lp.l2, bar_index, lp.g2 >= 0 and tReach.get(math.max(lp.g2, 0)) >= 0, " ✓")
            f_freezeLabel(lp.l3, bar_index, lp.g3 >= 0 and tReach.get(math.max(lp.g3, 0)) >= 0, " ✓")
            f_freezeLabel(lp.lS, bar_index, stopped, " ✕")
            if not na(lp.ent)
                line.set_x2(lp.ent, math.min(line.get_x2(lp.ent), bar_index))
            lp.live := false

// 2) A new flip: read the evidence, issue the verdict, open the next shadow trade, draw the staircase.
if (sigUp or sigDn) and not na(atr) and atr > 0
    int   dirSign = sigUp ? 1 : -1
    int   dirIdx  = sigUp ? 0 : 1
    float entry   = close
    float swing   = sigUp ? swingLo : swingHi
    float riskRaw = na(swing) ? atr : dirSign == 1 ? entry - swing : swing - entry
    float risk    = math.max(0.5 * atr, math.min(3.0 * atr, riskRaw))
    int   ctxIdx  = useCtx ? (cleanCtx ? 0 : 1) : 0
    int   bucket  = dirIdx * 2 + ctxIdx

    [sLvl, sN, sG1, sG2, sG3, sS1, sS2, sS3, sEdge] = f_stats(store, grid, bucket, dirIdx, minN, p1, p2, p3)
    float m1 = f_medBars(store, sLvl, bucket, dirIdx, sG1)
    float m2 = f_medBars(store, sLvl, bucket, dirIdx, sG2)
    float m3 = f_medBars(store, sLvl, bucket, dirIdx, sG3)
    int verdict = sLvl == 3 ? 2 : (sG1 >= 0 and sEdge > 0 ? 1 : 0)

    tOpen     := true
    tDir      := dirSign
    tBucket   := bucket
    tStartBar := bar_index
    tEntry    := entry
    tRisk     := risk
    tStop     := entry - dirSign * risk
    tMfe      := 0.0
    tReach.fill(-1)

    lastDir     := dirSign
    lastVerdict := verdict
    lastSigBar  := bar_index
    pLvl  := sLvl
    pN    := sN
    pG1   := sG1
    pG2   := sG2
    pG3   := sG3
    pS1   := sS1
    pS2   := sS2
    pS3   := sS3
    pM1   := m1
    pM2   := m2
    pM3   := m3
    pEdge := sEdge
    pCtxClean := cleanCtx

    if showPlan
        if plans.size() > 0
            Plan prev = plans.last()
            f_fadeBox(prev.z1, prev.col, 93, 82)
            f_fadeBox(prev.z2, prev.col, 94, 84)
            f_fadeBox(prev.z3, prev.col, 95, 86)
            f_fadeBox(prev.zStop, NEUTRAL, 94, 86)
            f_fadeLabel(prev.l1, prev.col)
            f_fadeLabel(prev.l2, prev.col)
            f_fadeLabel(prev.l3, prev.col)
            f_fadeLabel(prev.lS, NEUTRAL)
        bool  calib = verdict == 2
        color c     = verdict == 0 ? NEUTRAL : dirSign == 1 ? bullCol : bearCol
        color opp   = dirSign == 1 ? bearCol : bullCol
        // Calibrating plans show plain 1R / 2R / 3R references until the sample is large enough.
        int dg1 = calib ? 1 : sG1
        int dg2 = calib ? 3 : sG2
        int dg3 = calib ? 5 : sG3
        int w1 = calib ? math.round(horizon * 0.25) : na(m1) ? math.round(horizon * 0.5) : math.round(m1)
        int w2 = calib ? math.round(horizon * 0.50) : na(m2) ? math.round(horizon * 0.5) : math.round(m2)
        int w3 = calib ? math.round(horizon * 0.75) : na(m3) ? math.round(horizon * 0.5) : math.round(m3)
        w1 := math.max(2, math.min(w1, 480))
        w2 := math.max(2, math.min(w2, 480))
        w3 := math.max(2, math.min(w3, 480))
        string poolTxt = sLvl == 0 ? "same direction + context" : sLvl == 1 ? "same direction" : sLvl == 2 ? "all flips" : "calibrating"
        string tipBase = "Evidence: " + poolTxt + " (n=" + str.tostring(sN) + ")"
        Plan pl = Plan.new(col = c, g1 = dg1, g2 = dg2, g3 = dg3)
        float lastLvl = entry
        int   xMax    = bar_index + 2
        if dg1 >= 0
            float y1 = entry + dirSign * grid.get(dg1) * risk
            string t1 = "T1 +" + f_rTxt(grid.get(dg1)) + (calib ? "" : "  " + f_pctTxt(sS1) + "  ~" + str.tostring(w1) + " bars")
            [b1, lb1] = f_drawTarget(bar_index, bar_index + w1, lastLvl, y1, c, calib ? na : sS1, t1, tipBase)
            pl.z1 := b1
            pl.l1 := lb1
            lastLvl := y1
            xMax := math.max(xMax, bar_index + w1)
        if dg2 >= 0
            float y2 = entry + dirSign * grid.get(dg2) * risk
            string t2 = "T2 +" + f_rTxt(grid.get(dg2)) + (calib ? "" : "  " + f_pctTxt(sS2) + "  ~" + str.tostring(w2) + " bars")
            [b2, lb2] = f_drawTarget(bar_index, bar_index + w2, lastLvl, y2, c, calib ? na : sS2, t2, tipBase)
            pl.z2 := b2
            pl.l2 := lb2
            lastLvl := y2
            xMax := math.max(xMax, bar_index + w2)
        if dg3 >= 0
            float y3 = entry + dirSign * grid.get(dg3) * risk
            string t3 = "T3 +" + f_rTxt(grid.get(dg3)) + (calib ? "" : "  " + f_pctTxt(sS3) + "  ~" + str.tostring(w3) + " bars")
            [b3, lb3] = f_drawTarget(bar_index, bar_index + w3, lastLvl, y3, c, calib ? na : sS3, t3, tipBase)
            pl.z3 := b3
            pl.l3 := lb3
            xMax := math.max(xMax, bar_index + w3)
        float yS = tStop
        pl.zStop := box.new(bar_index, math.max(entry, yS), xMax, math.min(entry, yS), border_color = color.new(opp, 60), border_width = 1, border_style = line.style_dashed, bgcolor = color.new(NEUTRAL, 88), xloc = xloc.bar_index)
        string stopTxt = "Stop −1R · " + (verdict == 0 ? "SKIP" : verdict == 2 ? "calibrating" : "TAKE")
        pl.lS  := label.new(xMax, yS, stopTxt, xloc = xloc.bar_index, yloc = yloc.price, color = CLEAR, style = label.style_label_left, textcolor = NEUTRAL, size = size.small, tooltip = tipBase)
        pl.ent := line.new(bar_index, entry, xMax, entry, xloc = xloc.bar_index, color = color.new(NEUTRAL, 35), style = line.style_dotted, width = 1)
        plans.push(pl)
        while plans.size() > keepPlans + 1
            Plan old = plans.shift()
            f_eraseBox(old.z1)
            f_eraseBox(old.z2)
            f_eraseBox(old.z3)
            f_eraseBox(old.zStop)
            f_eraseLabel(old.l1)
            f_eraseLabel(old.l2)
            f_eraseLabel(old.l3)
            f_eraseLabel(old.lS)
            if not na(old.ent)
                line.delete(old.ent)

// ───────────────────────────── Plots ─────────────────────────────
color trendCol = trend == 1 ? bullCol : trend == -1 ? bearCol : NEUTRAL
pTrail = plot(trend != trend[1] ? na : trail, "Trend Trail", trendCol, 2, plot.style_linebr)
pMid   = plot(hl2, "Mid", display = display.none, editable = false)
fill(pTrail, pMid, color.new(trendCol, 90), "Trend Fill")

bool takeUp = sigUp and lastVerdict == 1
bool takeDn = sigDn and lastVerdict == 1
bool skipUp = sigUp and lastVerdict == 0
bool skipDn = sigDn and lastVerdict == 0
bool calUp  = sigUp and lastVerdict == 2
bool calDn  = sigDn and lastVerdict == 2

float offs = na(atr) ? 0.0 : 0.35 * atr
float yTakeUp = takeUp ? low - offs : na
float yTakeDn = takeDn ? high + offs : na
float ySkipUp = skipUp and showSkip ? low - offs : na
float ySkipDn = skipDn and showSkip ? high + offs : na
float yCalUp  = calUp ? low - offs : na
float yCalDn  = calDn ? high + offs : na
plotshape(yTakeUp, "Long TAKE",  shape.triangleup,   location.absolute, bullCol, size = size.small)
plotshape(yTakeDn, "Short TAKE", shape.triangledown, location.absolute, bearCol, size = size.small)
plotshape(ySkipUp, "Long SKIP",  shape.xcross, location.absolute, color.new(NEUTRAL, 20), size = size.tiny)
plotshape(ySkipDn, "Short SKIP", shape.xcross, location.absolute, color.new(NEUTRAL, 20), size = size.tiny)
plotshape(yCalUp,  "Long flip (calibrating)",  shape.triangleup,   location.absolute, color.new(bullCol, 55), size = size.tiny)
plotshape(yCalDn,  "Short flip (calibrating)", shape.triangledown, location.absolute, color.new(bearCol, 55), size = size.tiny)

// Defensive price-scale anchors (invisible, pane only).
plot(high, "Scale Anchor High", CLEAR, display = display.pane, editable = false)
plot(low,  "Scale Anchor Low",  CLEAR, display = display.pane, editable = false)

// Pine Screener columns.
float sigCode = sigUp ? (lastVerdict == 1 ? 1.0 : 0.5) : sigDn ? (lastVerdict == 1 ? -1.0 : -0.5) : 0.0
plot(sigCode, "Signal (+1 long TAKE, -1 short TAKE, ±0.5 other flip)", display = display.data_window)
plot(trend, "Trend State (+1 / -1)", display = display.data_window)
plot(pEdge, "Edge at T1 (R per trade)", display = display.data_window)
plot(na(pS1) ? na : pS1 * 100, "T1 Reach Probability (%)", display = display.data_window)
plot(na(lastSigBar) ? na : bar_index - lastSigBar, "Bars Since Flip", display = display.data_window)

// ───────────────────────────── Alerts ─────────────────────────────
alertcondition(takeUp, "PSTE Long TAKE", "PSTE: long flip with positive T1 evidence on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(takeDn, "PSTE Short TAKE", "PSTE: short flip with positive T1 evidence on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(sigUp, "PSTE Long Flip (any verdict)", "PSTE: bullish trend flip on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(sigDn, "PSTE Short Flip (any verdict)", "PSTE: bearish trend flip on {{ticker}} ({{interval}}) at {{close}}")

// ───────────────────────────── Dashboard ─────────────────────────────
var table dash = table.new(position.top_right, 2, 10, bgcolor = color.new(DASH_BG, 8), frame_color = color.new(NEUTRAL, 60), frame_width = 1, border_color = color.new(NEUTRAL, 85), border_width = 1)

f_row(table t, int r, string k, string v, color vc, string sz) =>
    table.cell(t, 0, r, k, text_color = color.new(DASH_TXT, 30), text_halign = text.align_left, text_size = sz)
    table.cell(t, 1, r, v, text_color = vc, text_halign = text.align_right, text_size = sz)

if barstate.islast and showDash
    color dirC = lastDir == 1 ? bullCol : lastDir == -1 ? bearCol : NEUTRAL
    string trendTxt = (trend == 1 ? "▲ BULL" : trend == -1 ? "▼ BEAR" : "—") + (cleanCtx ? " · clean" : " · choppy")
    string verdTxt = lastVerdict == 1 ? "TAKE" : lastVerdict == 0 ? "SKIP" : lastVerdict == 2 ? "CALIBRATING" : "—"
    color verdC = lastVerdict == 1 ? dirC : NEUTRAL
    string flipTxt = na(lastSigBar) ? "—" : (lastDir == 1 ? "LONG · " : "SHORT · ") + verdTxt + " · " + str.tostring(bar_index - lastSigBar) + " bars ago"
    string poolTxt = pLvl == 0 ? "Direction + context" : pLvl == 1 ? "Direction pool" : pLvl == 2 ? "All flips" : "Calibrating"
    string evTxt = pLvl == 3 ? poolTxt + " " + str.tostring(store.size()) + "/" + str.tostring(minN) : poolTxt + " · n=" + str.tostring(pN)
    string t1Txt = pLvl == 3 or pG1 < 0 ? "none ≥ " + str.tostring(math.round(p1 * 100)) + "%" : "+" + f_rTxt(grid.get(pG1)) + " · " + f_pctTxt(pS1) + " · ~" + str.tostring(pM1, "#") + " bars"
    string t2Txt = pLvl == 3 or pG2 < 0 ? "—" : "+" + f_rTxt(grid.get(pG2)) + " · " + f_pctTxt(pS2) + " · ~" + str.tostring(pM2, "#") + " bars"
    string t3Txt = pLvl == 3 or pG3 < 0 ? "—" : "+" + f_rTxt(grid.get(pG3)) + " · " + f_pctTxt(pS3) + " · ~" + str.tostring(pM3, "#") + " bars"
    string edgeTxt = na(pEdge) ? "—" : (pEdge >= 0 ? "+" : "") + str.tostring(pEdge, "#.00") + "R / trade"
    color edgeC = na(pEdge) ? NEUTRAL : pEdge > 0 ? bullCol : bearCol
    string liveTxt = tOpen ? "Open · MFE +" + str.tostring(tMfe, "#.0") + "R · " + str.tostring(bar_index - tStartBar) + "/" + str.tostring(horizon) : na(lastSigBar) ? "—" : "Closed · " + lastExit
    table.cell(dash, 0, 0, "PSTE", text_color = DASH_TXT, text_halign = text.align_left, text_size = tSz, text_formatting = text.format_bold)
    table.cell(dash, 1, 0, trendTxt, text_color = trendCol, text_halign = text.align_right, text_size = tSz, text_formatting = text.format_bold)
    f_row(dash, 1, "Last flip", flipTxt, verdC, tSz)
    f_row(dash, 2, "Evidence", evTxt, DASH_TXT, tSz)
    f_row(dash, 3, "T1", t1Txt, dirC, tSz)
    f_row(dash, 4, "T2", t2Txt, dirC, tSz)
    f_row(dash, 5, "T3", t3Txt, dirC, tSz)
    f_row(dash, 6, "Edge at T1", edgeTxt, edgeC, tSz)
    f_row(dash, 7, "Live plan", liveTxt, DASH_TXT, tSz)
    f_row(dash, 8, "Record", str.tostring(resolved) + " resolved · " + str.tostring(ties) + " stop-first ties", color.new(DASH_TXT, 25), tSz)
    f_row(dash, 9, "Data mode", "ALL PLANS · closed-bar OHLC", color.new(DASH_TXT, 25), tSz)
````
