# Liquidity Map & Order Blocks [MQLSoftware]

- url: https://www.tradingview.com/script/qBesPbpE-Liquidity-Map-Order-Blocks-MQLSoftware/
- type: indicator
- pine_id: PUB;96513de23f9c402f8a03f34bfc10337a
- version: 1.0

## Description

Liquidity Map & Order Blocks reads swing structure into a density map of where stop-liquidity rests, then projects which pool price is most likely drawn toward next. Equal highs and lows are grouped into bands whose brightness scales with a multi-factor Liquidity Score, sweeps mark where those pools were hunted, and a forward-looking model expresses the most likely draw as a self-calibrating historical hit-rate rather than a fixed number. A compact right-side panel adds chart and higher-timeframe structure, the net liquidity pull, the draw target, and pool counts.

This is a visual analytical tool intended for chart reading and liquidity mapping. It does not execute trades and does not provide financial advice. It does not generate buy or sell signals and makes no claim about profitability or win rate. The draw percentage describes how often similar pools were reached in the past over the loaded data; it is a descriptive statistic, not a prediction, and past behavior does not guarantee future results.

[b]Key Features[/b]
[list]
[*]Resting liquidity drawn as density bands from ATR-normalized clustering of equal highs and lows, so nearby levels merge into one pool instead of a stack of lines
[*]Band brightness driven by a Liquidity Score that blends a saturating touch count, age decay, relative volume at the forming pivots, and rejection-wick depth
[*]Draw on Liquidity projection: a directional arrow to the pool with the strongest modelled pull, muted automatically when the model's confidence is low
[*]Draw percentage shown as a self-calibrating empirical hit-rate — how often pools of a similar profile were actually reached over the loaded history, marked provisional while the sample is thin
[*]Sweep detection when price wicks beyond the last significant swing and closes back within it, with recent sweeps labelled and older ones marked compactly
[*]Protected-swing structure engine marking Break of Structure and Change of Character, with an optional plain-language label mode
[*]Order blocks drawn only when they originate a Break of Structure, plus an optional Fair Value Gap layer; both fade once mitigated
[*]Multi-timeframe panel with chart and higher-timeframe bias, liquidity pull, draw target with its hit-rate, and pool counts, read non-repainting
[/list]

[b]Core Concept[/b]
Most liquidity and order-block tools on TradingView take one of two approaches. They either draw raw equal-high / equal-low lines and mark every order block and gap without ranking them, which clutters the chart and leaves the reader to judge which level matters, or they label structure (swings, breaks of structure) without projecting where liquidity is likely to pull price next. Both stop short of a scored, forward-looking read.

This indicator builds on a different base: cluster swing levels into scored density bands, gate order blocks by structure, and add a model for the next likely draw that is calibrated against realized history. It adds three specific algorithmic elements on top of that base.

[b]1. ATR-Normalized Liquidity Clustering with a Multi-Factor Score.[/b] Swing highs and lows are not drawn as individual lines. They are grouped along the price axis by a clustering pass whose merge distance scales with ATR, so equal-ish levels collapse into a single pool and the behavior stays consistent across instruments. Each pool carries a Liquidity Score built multiplicatively from a saturating touch count, an age-decay term, relative volume at the forming pivots, and rejection-wick depth, so a band's brightness reflects how heavy and how fresh the resting liquidity is rather than only how many times the level was touched.

[b]2. Draw on Liquidity Projection.[/b] Each unmitigated pool is treated as an attractor. Its pull is the product of its Liquidity Score, an exponential proximity kernel in ATR units, a structural prior that favors pools lying in the trend's continuation direction relative to current price, and a path-clearance term that discounts a pool when other strong pools sit between it and price. The strongest-pull pool is projected as the draw target, and the projection is deliberately muted when confidence is low, so a weak draw never reads like a strong one.

[b]3. Self-Calibrating Empirical Hit-Rate.[/b] The draw percentage is not a fixed weight. Each draw is profiled into a bucket defined by Liquidity Score, distance, and structural alignment, and as the chart's history is processed the script records how often pools of that profile were actually reached within a configurable horizon. The displayed figure is the empirical reach frequency of that bucket, smoothed with a weak prior so thin samples are shown as provisional rather than over-read. It calibrates per symbol and timeframe with no fixed accuracy claim attached.

[b]Anatomy of the Display[/b]
[b]Liquidity bands[/b] are the horizontal zones spanning each pool, colored for buy-side (above) and sell-side (below) liquidity; the brighter a band, the higher its Liquidity Score. Swept pools dim to grey so a hunted level is visually retired.

[b]The draw projection[/b] is the arrow from current price to the strongest-pull pool, with a price-side chip and an arrowhead pointing the modelled direction. Its weight scales with the hit-rate: a high-confidence draw is bold, a low-confidence one is thin and faded. The label reads the target level, the hit-rate (shown as a provisional `~NN% (n…)` while its sample is small), and whether the pool is buy-side or sell-side liquidity.

[b]Sweeps[/b] mark a stop-hunt of the last significant swing: a wick beyond it that closes back within. The two most recent are labelled; older ones are compact marks so the chart stays clean.

[b]Structure[/b] is drawn as Break of Structure and Change of Character lines from a protected-swing state machine; a toggle renders these in plain language (Trend break / Reversal) for readers new to the terminology.

[b]Order blocks[/b] are the boxes drawn at the last opposite candle before a Break of Structure, so only structure-originating blocks appear; the optional Fair Value Gap layer marks three-candle imbalances aligned with the break. Both fade once price mitigates them.

[b]The right-side panel[/b] lists chart structure, the net liquidity pull and its strength, the draw target with its hit-rate, pool counts per side, and a per-row higher-timeframe bias scan with a strength bar.

[b]Multi-Timeframe Panel[/b]
The panel reads three higher timeframes of your choice for structural bias and trend strength, using the same protected-swing engine as the chart. Higher-timeframe values are read with `lookahead=barmerge.lookahead_off` and a one-bar offset, which is the standard non-repainting pattern for higher-timeframe context. A divergence between the chart's structure row and the liquidity pull is informative rather than contradictory: structure up while the draw points down with a high hit-rate, for example, frames an expected pullback toward a strong pool below.

[b]Notes on Repainting[/b]
[list]
[*][b]Confirmed liquidity pools, sweeps, structure breaks, and order blocks[/b] do not repaint. They are built from confirmed pivots (`ta.pivothigh` and `ta.pivotlow` with a right-bars parameter), so once committed they stay anchored.
[*][b]Pivot detection has an inherent delay[/b] equal to the right-bars parameter (default 3 bars). The most recent swing is provisional until that many bars close past it. This is a property of all pivot-based indicators, not specific to this script.
[*][b]The draw percentage is a learning statistic.[/b] It updates as the script accumulates observations over the loaded history. This is not a repaint of historical bars; the same bar can show a different figure when the chart is reloaded with a different amount of history, because more or fewer observations are available.
[*][b]Mitigation is one-directional.[/b] Once an order block or gap is mitigated it stays marked as such.
[*][b]Multi-timeframe panel data[/b] uses `lookahead=barmerge.lookahead_off` with a one-bar offset, the canonical non-repainting pattern for higher-timeframe context.
[*][b]Alerts[/b] are gated by `barstate.isconfirmed` and fire once per closed bar, never intra-bar.
[/list]

[b]Typical Analysis Workflow[/b]
A common analytical workflow may include:
[list=1]
[*]Reading the band map to see where the heaviest resting liquidity sits above and below price, with brighter bands as the higher-quality pools
[*]Reading the draw projection as a hypothesis for where liquidity may pull price next, weighting it by its hit-rate and whether it aligns with structure
[*]Noting sweeps as stop-hunts that often precede a move, and watching whether price reclaims or rejects the swept level
[*]Treating order blocks as origin zones for the move that broke structure, and the panel's higher-timeframe rows as top-down context
[*]Reading a structure-versus-pull divergence as a possible pullback rather than a contradiction, then managing any decision with other forms of analysis and risk management
[/list]

[b]Configuration[/b]
[b]Structure Engine[/b] - ATR length, pivot left / right bars, and the swing filter that sets how significant a swing must be. Right Bars also sets the confirmation delay.
[b]Liquidity Pools[/b] - lookback, cluster epsilon (how aggressively levels merge), minimum touches, age half-life, and whether volume contributes to the score.
[b]Draw on Liquidity[/b] - proximity, structural prior strength, path clearance, the empirical-calibration toggle, and the calibration horizon.
[b]Sweeps & Structure[/b] - sweep penetration, show sweeps, show structure, and the plain-language label toggle.
[b]Order Blocks / FVG[/b] - show order blocks, show gaps, the order-block scan window, and the maximum number of boxes.
[b]Visuals[/b] - colors for buy-side and sell-side liquidity, draw target, and structure, plus a minimum band height so pools read as bands rather than threads.
[b]Multi-Timeframe HUD[/b] - show / hide the panel, the three higher timeframes, and panel position.

[b]Markets and Timeframes[/b]
The indicator can be applied across multiple markets and timeframes:
[list]
[*]Cryptocurrencies
[*]Forex
[*]Stocks and Indices
[*]Commodities
[/list]
Because the clustering distance, proximity kernel, and score are all ATR-based, the visual behavior stays consistent across instruments and timeframes. The volume component of the Liquidity Score contributes most on instruments with reliable volume (crypto, futures, equities) and falls back gracefully where volume is thin. The empirical hit-rate reads best on charts with enough history for its buckets to fill.

[b]Alerts[/b]
[list]
[*]Buy-side liquidity swept - fires when a buy-side pool's level is hunted
[*]Sell-side liquidity swept - fires when a sell-side pool's level is hunted
[*]Bullish Break of Structure - fires on a confirmed upside structure break
[*]Bearish Break of Structure - fires on a confirmed downside structure break
[*]All timeframes bullish - fires when every higher-timeframe row is bullish
[*]All timeframes bearish - fires when every higher-timeframe row is bearish
[/list]
All alerts evaluate on confirmed bars to avoid intra-bar oscillation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © MQLSoftware
//
// Liquidity Map & Order Blocks [MQLSoftware]
// ─────────────────────────────────────────────────────────────────────────────
// WHAT IT DOES:
//   • LIQUIDITY MAP  — equal-high/low pivots are grouped into density BANDS via
//     ATR-normalized 1-D clustering. Brightness = Liquidity Score (touches, age,
//     relative volume, rejection wick). A bright band = a fat resting-stop pool.
//   • DRAW ON LIQUIDITY (flagship, predictive) — each unmitigated pool is an
//     attractor; a normalized model predicts which pool price is most drawn
//     toward next (magnitude · proximity kernel · structural prior · path
//     clearance). Output: DRAW target + draw% + Net Liquidity Bias.
//   • SWEEPS — stop-hunts of the last significant swing (wick beyond + close back).
//   • STRUCTURE — BOS / CHoCH from a protected-swing state machine.
//   • ORDER BLOCKS / FVG — drawn only when they originate a Break of Structure
//     (quality gate), so the chart stays free of unfiltered-SMC noise.
//
// Analytical, educational tool. Not a signal generator; no win-rate or R:R.
// NON-REPAINT: confirmed structure/sweeps/pools do not repaint; the last swing
// matures `Pivot Right Bars` after it prints (standard for pivot tools). MTF
// rows use confirmed prior-bar higher-TF values (lookahead off). The draw % is
// an empirical hit-rate that calibrates as observations accumulate over the
// loaded history (a learning statistic, not a repaint of past bars).

//@version=6
indicator("Liquidity Map & Order Blocks [MQLSoftware]", shorttitle="MQLSoftware - Liquidity & Order Blocks", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─── CONSTANTS ───────────────────────────────────────────────────────────────
float EPS    = 1e-9
int   ER_LEN = 20
int   PIVBUF = 80     // pivot buffer cap per side
int   EVTCAP = 8      // structure events kept
int   SWPCAP = 24     // sweep events kept
float DOL_TEMP = 2.2  // softmax temperature for draw share (>1 flattens spikes)
int   CALIB_MIN_N = 8 // observations below which a hit-rate is shown as provisional

// ─── INPUTS ──────────────────────────────────────────────────────────────────
var GRP_S = "Structure Engine"
atrLen      = input.int(14,  "ATR Length",        minval=5,  maxval=50, group=GRP_S)
pivLeft     = input.int(8,   "Pivot Left Bars",   minval=3,  maxval=30, group=GRP_S)
pivRight    = input.int(3,   "Pivot Right Bars",  minval=1,  maxval=10, group=GRP_S)
swingFilter = input.float(0.7,"Swing Filter (ATR)",minval=0.1,maxval=3.0,step=0.1,group=GRP_S)

var GRP_L = "Liquidity Pools"
lookback   = input.int(500, "Lookback Bars",      minval=100, maxval=1000, group=GRP_L)
clusterEps = input.float(0.15,"Cluster Eps (ATR)",minval=0.05,maxval=0.6,step=0.01,group=GRP_L, tooltip="Levels within this ATR fraction are merged into one pool.")
minTouches = input.int(2,   "Min Touches",        minval=2,  maxval=6,  group=GRP_L)
ageHalf    = input.int(200, "Age Half-life (bars)",minval=50, maxval=600, group=GRP_L)
useVolume  = input.bool(true,"Use Volume in Score", group=GRP_L)

var GRP_D = "Draw on Liquidity"
proxLambda = input.float(8.0,"Proximity λ (ATR)",  minval=2.0,maxval=20.0,step=0.5,group=GRP_D)
dirBeta    = input.float(0.5,"Structural Prior",   minval=0.0,maxval=1.0,step=0.05,group=GRP_D)
clearGamma = input.float(0.5,"Path Clearance",     minval=0.0,maxval=1.0,step=0.05,group=GRP_D)
showDraw   = input.bool(true,"Show Draw Target",   group=GRP_D)
useCalib   = input.bool(true,"Empirical Calibration", group=GRP_D, tooltip="Show draw % as the historical hit-rate of pools with a similar profile (self-calibrating over the loaded history), instead of a relative attraction share.")
hitHorizon = input.int(50,   "Calibration Horizon (bars)", minval=10, maxval=300, group=GRP_D)

var GRP_W = "Sweeps & Structure"
sweepPen   = input.float(0.05,"Sweep Penetration (ATR)",minval=0.01,maxval=0.5,step=0.01,group=GRP_W)
showSweeps = input.bool(true,"Show Sweeps",        group=GRP_W, inline="w")
showStruct = input.bool(true,"Show BOS/CHoCH",     group=GRP_W, inline="w")
plainLabels= input.bool(false,"Plain-language labels", group=GRP_W, tooltip="BOS → Trend break, CHoCH → Reversal.")

var GRP_OB = "Order Blocks / FVG"
showOB     = input.bool(true, "Show Order Blocks", group=GRP_OB, inline="o")
showFVG    = input.bool(false,"Show FVG",          group=GRP_OB, inline="o")
obScan     = input.int(40,   "OB Scan Window",     minval=5, maxval=120, group=GRP_OB)
obMaxBoxes = input.int(6,    "Max OB/FVG Boxes",   minval=2, maxval=20, group=GRP_OB)

var GRP_V = "Visuals"
colBSL  = input.color(#00E5CC, "Buy-side Liquidity",  group=GRP_V, inline="v1")
colSSL  = input.color(#FF3B5C, "Sell-side Liquidity", group=GRP_V, inline="v1")
colAmber= input.color(#F5A623, "CHoCH",               group=GRP_V, inline="v2")
colDraw = input.color(#A78BFA, "Draw Target",         group=GRP_V, inline="v2")
minBandATR = input.float(0.35, "Min Band Height (ATR)", minval=0.05, maxval=1.5, step=0.05, group=GRP_V, tooltip="Floor on band thickness so pools read as bands, not threads.")

var GRP_H = "Multi-Timeframe HUD"
showHud = input.bool(true,        "Show HUD", group=GRP_H)
tf1     = input.timeframe("240",  "TF 1",     group=GRP_H)
tf2     = input.timeframe("1D",   "TF 2",     group=GRP_H)
tf3     = input.timeframe("1W",   "TF 3",     group=GRP_H)
hudPos  = input.string("Top Right","Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_H)

// ─── HELPERS ───────────────────────────────────────────────────────────────
posMap(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>               position.bottom_left

biasCol(int d) => d > 0 ? colBSL : d < 0 ? colSSL : color.new(#8888AA, 0)
biasTxt(int d) => d > 0 ? "▲ Bull" : d < 0 ? "▼ Bear" : "— Flat"

strBar(float v) =>
    int f = na(v) ? 0 : int(math.round(math.min(100.0, math.max(0.0, v)) / 20.0))
    string s = ""
    for k = 1 to 5
        s := s + (k <= f ? "▰" : "▱")
    s

lsTransp(float ls) => int(math.round(math.max(32.0, math.min(90.0, 90.0 - ls * 0.58))))

// MTF: protected-swing CHoCH bias + efficiency strength (non-repainting)
htfState() =>
    var int   t  = 0
    var float lh = na
    var float ll = na
    var float pH = na
    var float pL = na
    float h = ta.pivothigh(high, pivLeft, pivRight)
    float l = ta.pivotlow(low,   pivLeft, pivRight)
    if not na(h)
        if t == 1
            if na(lh) or h > lh
                pL := ll
        else
            float ref = t < 0 ? pH : lh
            if not na(ref) and h > ref
                t  := 1
                pL := ll
        lh := h
    if not na(l)
        if t == -1
            if na(ll) or l < ll
                pH := lh
        else
            float ref2 = t > 0 ? pL : ll
            if not na(ref2) and l < ref2
                t  := -1
                pH := lh
        ll := l
    float er = na(close[ER_LEN]) ? 0.0 : math.abs(close - close[ER_LEN]) / math.max(math.sum(math.abs(ta.change(close)), ER_LEN), EPS)
    [t[1], nz(er[1]) * 100.0]

// ─── BASE SERIES ──────────────────────────────────────────────────────────────
float atr     = ta.atr(atrLen)
float volBase = ta.sma(volume, 50)
ph = ta.pivothigh(high, pivLeft, pivRight)
pl = ta.pivotlow(low,   pivLeft, pivRight)
int cBar = bar_index - pivRight

// ─── PIVOT BUFFERS (for clustering) ──────────────────────────────────────────
var float[] phP = array.new_float(0)
var int[]   phB = array.new_int(0)
var float[] phV = array.new_float(0)
var float[] phW = array.new_float(0)
var float[] plP = array.new_float(0)
var int[]   plB = array.new_int(0)
var float[] plV = array.new_float(0)
var float[] plW = array.new_float(0)

pushHi(float p) =>
    float rng = math.max(high[pivRight] - low[pivRight], EPS)
    float wk  = (high[pivRight] - math.max(open[pivRight], close[pivRight])) / rng
    array.push(phP, p)
    array.push(phB, cBar)
    array.push(phV, nz(volume[pivRight]))
    array.push(phW, math.min(1.0, math.max(0.0, wk)))
    if array.size(phP) > PIVBUF
        array.shift(phP)
        array.shift(phB)
        array.shift(phV)
        array.shift(phW)

pushLo(float p) =>
    float rng = math.max(high[pivRight] - low[pivRight], EPS)
    float wk  = (math.min(open[pivRight], close[pivRight]) - low[pivRight]) / rng
    array.push(plP, p)
    array.push(plB, cBar)
    array.push(plV, nz(volume[pivRight]))
    array.push(plW, math.min(1.0, math.max(0.0, wk)))
    if array.size(plP) > PIVBUF
        array.shift(plP)
        array.shift(plB)
        array.shift(plV)
        array.shift(plW)

if not na(ph)
    pushHi(ph)
if not na(pl)
    pushLo(pl)

// ─── STRUCTURE: protected-swing CHoCH + BOS/CHoCH events ──────────────────────
var int   trend = 0
var float lh    = na
var float ll    = na
var float pH    = na
var float pL    = na
// event stores (data → redrawn each render)
var int[]   evtBar  = array.new_int(0)
var float[] evtLvl  = array.new_float(0)
var int[]   evtType = array.new_int(0)   // 0 bosUp 1 bosDn 2 chochUp 3 chochDn
// sweep stores
var int[]   swpBar  = array.new_int(0)
var float[] swpLvl  = array.new_float(0)
var bool[]  swpBuy  = array.new_bool(0)
// OB / FVG stores
var float[] obT = array.new_float(0)
var float[] obB = array.new_float(0)
var int[]   obX = array.new_int(0)
var bool[]  obBull = array.new_bool(0)
var bool[]  obMit  = array.new_bool(0)
var float[] fvT = array.new_float(0)
var float[] fvB = array.new_float(0)
var int[]   fvX = array.new_int(0)
var bool[]  fvBull = array.new_bool(0)
var bool[]  fvMit  = array.new_bool(0)

pushEvt(int b, float lv, int ty) =>
    array.push(evtBar, b)
    array.push(evtLvl, lv)
    array.push(evtType, ty)
    if array.size(evtBar) > EVTCAP
        array.shift(evtBar)
        array.shift(evtLvl)
        array.shift(evtType)

pushSwp(int b, float lv, bool buy) =>
    bool dup = false
    if array.size(swpBar) > 0
        int li = array.size(swpBar) - 1
        if array.get(swpBuy, li) == buy and (b - array.get(swpBar, li)) < pivLeft and math.abs(array.get(swpLvl, li) - lv) < clusterEps * atr
            dup := true
    if not dup
        array.push(swpBar, b)
        array.push(swpLvl, lv)
        array.push(swpBuy, buy)
        if array.size(swpBar) > SWPCAP
            array.shift(swpBar)
            array.shift(swpLvl)
            array.shift(swpBuy)

pushOB(float t, float b, int x, bool bull) =>
    array.push(obT, t)
    array.push(obB, b)
    array.push(obX, x)
    array.push(obBull, bull)
    array.push(obMit, false)
    if array.size(obT) > obMaxBoxes
        array.shift(obT)
        array.shift(obB)
        array.shift(obX)
        array.shift(obBull)
        array.shift(obMit)

pushFVG(float t, float b, int x, bool bull) =>
    array.push(fvT, t)
    array.push(fvB, b)
    array.push(fvX, x)
    array.push(fvBull, bull)
    array.push(fvMit, false)
    if array.size(fvT) > obMaxBoxes
        array.shift(fvT)
        array.shift(fvB)
        array.shift(fvX)
        array.shift(fvBull)
        array.shift(fvMit)

bool evtBosUp = false
bool evtBosDn = false

if barstate.isconfirmed
    if not na(ph)
        if trend == 1
            if na(lh) or ph > lh
                pL := ll
                pushEvt(cBar, na(lh) ? ph : lh, 0)
                evtBosUp := true
        else
            float ref = trend < 0 ? pH : lh
            if not na(ref) and ph > ref
                bool wasDn = trend < 0
                trend := 1
                pL := ll
                pushEvt(cBar, ref, wasDn ? 2 : 0)
                evtBosUp := not wasDn
        lh := ph
    if not na(pl)
        if trend == -1
            if na(ll) or pl < ll
                pH := lh
                pushEvt(cBar, na(ll) ? pl : ll, 1)
                evtBosDn := true
        else
            float ref2 = trend > 0 ? pL : ll
            if not na(ref2) and pl < ref2
                bool wasUp = trend > 0
                trend := -1
                pH := lh
                pushEvt(cBar, ref2, wasUp ? 3 : 1)
                evtBosDn := not wasUp
        ll := pl

    // ── Sweep detection vs the last significant swing ──
    if not na(lh) and high > lh + sweepPen * atr and close < lh
        pushSwp(bar_index, lh, true)
    if not na(ll) and low < ll - sweepPen * atr and close > ll
        pushSwp(bar_index, ll, false)

    // ── Order Blocks: last opposite candle before a BOS ──
    if showOB and (evtBosUp or evtBosDn)
        if evtBosUp
            for k = 1 to obScan
                if close[k] < open[k]
                    pushOB(high[k], low[k], bar_index - k, true)
                    break
        if evtBosDn
            for k = 1 to obScan
                if close[k] > open[k]
                    pushOB(high[k], low[k], bar_index - k, false)
                    break

    // ── FVG: 3-candle imbalance aligned with a BOS ──
    if showFVG and (evtBosUp or evtBosDn)
        if evtBosUp and low > high[2]
            pushFVG(low, high[2], bar_index - 1, true)
        if evtBosDn and high < low[2]
            pushFVG(low[2], high, bar_index - 1, false)

// ── Mitigation updates (every confirmed bar) ──
if barstate.isconfirmed
    if array.size(obT) > 0
        for i = 0 to array.size(obT) - 1
            if not array.get(obMit, i)
                bool bull = array.get(obBull, i)
                float t = array.get(obT, i)
                float b = array.get(obB, i)
                if (bull and low <= t and bar_index > array.get(obX, i)) or (not bull and high >= b and bar_index > array.get(obX, i))
                    array.set(obMit, i, true)
    if array.size(fvT) > 0
        for i = 0 to array.size(fvT) - 1
            if not array.get(fvMit, i)
                bool bull = array.get(fvBull, i)
                if (bull and low <= array.get(fvB, i)) or (not bull and high >= array.get(fvT, i))
                    array.set(fvMit, i, true)

// ─── LIQUIDITY SCORE ──────────────────────────────────────────────────────────
liquidityScore(int touches, int bornBar, float volAvg, float wickAvg) =>
    float wT  = 1.0 - math.exp(-0.5 * touches)
    float age = bar_index - bornBar
    float wA  = math.exp(-0.6931 * age / ageHalf)
    float wV  = useVolume and not na(volAvg) and not na(volBase) and volBase > 0 ? math.min(1.0, math.max(0.3, volAvg / volBase)) : 1.0
    float wR  = math.min(1.0, math.max(0.3, wickAvg))
    100.0 * wT * wA * wV * wR

// ─── DRAW POOLS (rebuilt each render) ────────────────────────────────────────
var box[]   bandBoxes = array.new_box()
var line[]  drawLines = array.new_line()
var label[] drawLabels = array.new_label()
var box[]   obBoxes   = array.new_box()

clearAll() =>
    for b in bandBoxes
        box.delete(b)
    for l in drawLines
        line.delete(l)
    for lb in drawLabels
        label.delete(lb)
    for ob in obBoxes
        box.delete(ob)
    array.clear(bandBoxes)
    array.clear(drawLines)
    array.clear(drawLabels)
    array.clear(obBoxes)

// pool working arrays (rebuilt on render)
var float[] poolP    = array.new_float(0)
var float[] poolThk  = array.new_float(0)
var int[]   poolBorn = array.new_int(0)
var int[]   poolTch  = array.new_int(0)
var float[] poolLS   = array.new_float(0)
var bool[]  poolBuy  = array.new_bool(0)
var bool[]  poolSwept= array.new_bool(0)

// cluster one side into pools
clusterSide(bool isBuy) =>
    int n = isBuy ? array.size(phP) : array.size(plP)
    if n >= minTouches
        // index sort by price ascending
        int[] idx = array.new_int(0)
        for a = 0 to n - 1
            int bb = isBuy ? array.get(phB, a) : array.get(plB, a)
            if bar_index - bb <= lookback
                array.push(idx, a)
        int m = array.size(idx)
        if m >= minTouches
            for a = 0 to m - 2
                int mn = a
                for b = a + 1 to m - 1
                    float pa = isBuy ? array.get(phP, array.get(idx, b)) : array.get(plP, array.get(idx, b))
                    float pb = isBuy ? array.get(phP, array.get(idx, mn)) : array.get(plP, array.get(idx, mn))
                    if pa < pb
                        mn := b
                int tmp = array.get(idx, a)
                array.set(idx, a, array.get(idx, mn))
                array.set(idx, mn, tmp)
            // walk sorted, group within eps*atr
            float eps = clusterEps * atr
            float sumP = 0.0
            float minP = na
            float maxP = na
            float sumV = 0.0
            float sumW = 0.0
            int   cnt   = 0
            int   bornB = na
            float prevP = na
            for a = 0 to m - 1
                int    gi = array.get(idx, a)
                float  pr = isBuy ? array.get(phP, gi) : array.get(plP, gi)
                float  vv = isBuy ? array.get(phV, gi) : array.get(plV, gi)
                float  ww = isBuy ? array.get(phW, gi) : array.get(plW, gi)
                int    bb = isBuy ? array.get(phB, gi) : array.get(plB, gi)
                bool gap = not na(prevP) and (pr - prevP) > eps
                if gap and cnt >= minTouches
                    float ctr = sumP / cnt
                    float ls  = liquidityScore(cnt, bornB, sumV / cnt, sumW / cnt)
                    bool swept = false
                    if array.size(swpLvl) > 0
                        for s = 0 to array.size(swpLvl) - 1
                            if array.get(swpBuy, s) == isBuy and math.abs(array.get(swpLvl, s) - ctr) <= eps and array.get(swpBar, s) > bornB
                                swept := true
                    array.push(poolP, ctr)
                    array.push(poolThk, maxP - minP)
                    array.push(poolBorn, bornB)
                    array.push(poolTch, cnt)
                    array.push(poolLS, ls)
                    array.push(poolBuy, isBuy)
                    array.push(poolSwept, swept)
                if gap
                    sumP := 0.0
                    minP := na
                    maxP := na
                    sumV := 0.0
                    sumW := 0.0
                    cnt  := 0
                    bornB := na
                sumP += pr
                minP := na(minP) ? pr : math.min(minP, pr)
                maxP := na(maxP) ? pr : math.max(maxP, pr)
                sumV += vv
                sumW += ww
                bornB := na(bornB) ? bb : math.min(bornB, bb)
                cnt  += 1
                prevP := pr
            if cnt >= minTouches
                float ctr = sumP / cnt
                float ls  = liquidityScore(cnt, bornB, sumV / cnt, sumW / cnt)
                bool swept = false
                if array.size(swpLvl) > 0
                    for s = 0 to array.size(swpLvl) - 1
                        if array.get(swpBuy, s) == isBuy and math.abs(array.get(swpLvl, s) - ctr) <= eps and array.get(swpBar, s) > bornB
                            swept := true
                array.push(poolP, ctr)
                array.push(poolThk, maxP - minP)
                array.push(poolBorn, bornB)
                array.push(poolTch, cnt)
                array.push(poolLS, ls)
                array.push(poolBuy, isBuy)
                array.push(poolSwept, swept)

// ─── RENDER STATE ─────────────────────────────────────────────────────────────
var int   drawTargetIdx = -1
var float nlb           = na
var float drawProb      = na
var int   chartTrend    = 0

// ── Empirical hit-rate calibration state ──
// 27 buckets = LS(3) × distance(3) × structural-alignment(3)
var int[]   hitC       = array.new_int(27, 0)
var int[]   totC       = array.new_int(27, 0)
var float[] pendLvl    = array.new_float(0)
var bool[]  pendAbove  = array.new_bool(0)
var int[]   pendBucket = array.new_int(0)
var int[]   pendDead   = array.new_int(0)
var float   targetLvl    = na
var int     targetBucket = -1
var float   lastRegLvl   = na

bucketOf(float ls, float dATR, int trnd, bool withDir) =>
    int lsB = ls < 33.0 ? 0 : ls < 66.0 ? 1 : 2
    int dB  = dATR < 3.0 ? 0 : dATR < 8.0 ? 1 : 2
    int aB  = trnd == 0 ? 2 : withDir ? 0 : 1
    lsB * 9 + dB * 3 + aB

// Beta(2,2) prior → weak 50% prior, calibrates as observations accumulate
calibRate(int b) => b < 0 ? na : (array.get(hitC, b) + 2.0) / (array.get(totC, b) + 4.0) * 100.0

bool doRender = (not na(ph) or not na(pl) or barstate.islast)

if doRender
    clearAll()
    array.clear(poolP)
    array.clear(poolThk)
    array.clear(poolBorn)
    array.clear(poolTch)
    array.clear(poolLS)
    array.clear(poolBuy)
    array.clear(poolSwept)
    chartTrend := trend

    clusterSide(true)
    clusterSide(false)
    int np = array.size(poolP)

    // ── Draw-on-Liquidity model ──
    drawTargetIdx := -1
    nlb := na
    drawProb := na
    targetLvl := na
    targetBucket := -1
    if np > 0
        float bestPull = -1.0
        float[] pulls = array.new_float(np, 0.0)
        for i = 0 to np - 1
            if not array.get(poolSwept, i)
                float pp  = array.get(poolP, i)
                bool  buy = array.get(poolBuy, i)
                float d   = math.abs(pp - close) / math.max(atr, EPS)
                float prox = math.exp(-d / proxLambda)
                bool  withDir = (chartTrend < 0 and pp < close) or (chartTrend > 0 and pp > close)
                float dir = chartTrend == 0 ? 1.0 : withDir ? (1.0 + dirBeta) : (1.0 - dirBeta)
                // path clearance: pools strictly between close and pp
                float clr = 1.0
                for j = 0 to np - 1
                    if j != i and not array.get(poolSwept, j)
                        float pj = array.get(poolP, j)
                        bool between = (pj > math.min(close, pp) and pj < math.max(close, pp))
                        if between
                            clr *= (1.0 - clearGamma * array.get(poolLS, j) / 100.0)
                float pull = (array.get(poolLS, i) / 100.0) * prox * dir * clr
                array.set(pulls, i, pull)
                if pull > bestPull
                    bestPull := pull
                    drawTargetIdx := i
        if drawTargetIdx >= 0
            float tpT  = array.get(poolP, drawTargetIdx)
            float ddT  = math.abs(tpT - close) / math.max(atr, EPS)
            bool  wdT  = (chartTrend < 0 and tpT < close) or (chartTrend > 0 and tpT > close)
            targetLvl    := tpT
            targetBucket := bucketOf(array.get(poolLS, drawTargetIdx), ddT, chartTrend, wdT)
            float tShare = 0.0
            for i = 0 to np - 1
                if not array.get(poolSwept, i)
                    tShare += math.pow(math.max(array.get(pulls, i), 0.0), 1.0 / DOL_TEMP)
            float softShare = tShare > EPS ? math.min(85.0, math.pow(math.max(array.get(pulls, drawTargetIdx), 0.0), 1.0 / DOL_TEMP) / tShare * 100.0) : na
            drawProb := useCalib ? calibRate(targetBucket) : softShare
            // NLB = signed confidence toward the draw target (keeps chip/HUD/arrow consistent)
            nlb := (tpT > close ? 1.0 : -1.0) * (na(drawProb) ? 0.0 : drawProb) / 100.0

    // ── Render liquidity bands ──
    if np > 0
        for i = 0 to np - 1
            float pp  = array.get(poolP, i)
            float thk = math.max(array.get(poolThk, i), atr * minBandATR)
            bool  buy = array.get(poolBuy, i)
            bool  sw  = array.get(poolSwept, i)
            int   bb  = array.get(poolBorn, i)
            color base = sw ? color.new(#7A7A8C, 80) : color.new(buy ? colBSL : colSSL, lsTransp(array.get(poolLS, i)))
            box bx = box.new(bb, pp + thk / 2.0, bar_index, pp - thk / 2.0, border_color=color.new(sw ? #7A7A8C : (buy ? colBSL : colSSL), 60), border_width=1, bgcolor=base)
            array.push(bandBoxes, bx)

    // ── Render Draw target (directional hero) ──
    if showDraw and drawTargetIdx >= 0
        float tp  = array.get(poolP, drawTargetIdx)
        bool  buy = array.get(poolBuy, drawTargetIdx)
        bool  up  = tp > close
        float thk = math.max(array.get(poolThk, drawTargetIdx), atr * minBandATR)
        int    tN  = useCalib and targetBucket >= 0 ? array.get(totC, targetBucket) : 999
        bool   prov = useCalib and tN < CALIB_MIN_N
        float  conf = na(drawProb) ? 0.0 : drawProb
        bool   weak = prov or conf < 25.0   // low confidence → muted hero
        // prominence scales with confidence
        int    aw  = weak ? 1 : conf >= 50.0 ? 3 : 2
        int    at  = weak ? 58 : conf >= 50.0 ? 0 : 22
        box bx = box.new(array.get(poolBorn, drawTargetIdx), tp + thk / 2.0, bar_index, tp - thk / 2.0, border_color=color.new(colDraw, weak ? 45 : 0), border_width=weak ? 1 : 2, bgcolor=color.new(colDraw, weak ? 90 : 76))
        array.push(bandBoxes, bx)
        // projection arrow + arrowhead (faded when weak)
        line al = line.new(bar_index, close, bar_index + 14, tp, color=color.new(colDraw, at), width=aw)
        array.push(drawLines, al)
        label ah = label.new(bar_index + 14, tp, up ? "▲" : "▼", color=color.new(#000000, 100), textcolor=color.new(colDraw, at), style=label.style_none, size=size.normal)
        array.push(drawLabels, ah)
        // tag leads with DIRECTION; liquidity type secondary
        string liq = buy ? "buy-side" : "sell-side"
        string pct = na(drawProb) ? "" : "  ·  " + (prov ? "~" : "") + str.tostring(drawProb, "#") + "%" + (prov ? " (n" + str.tostring(tN) + ")" : "")
        string tag = "◎ DRAW " + (up ? "▲ " : "▼ ") + str.tostring(tp, format.mintick) + pct + "   (" + liq + " liq)"
        label dl = label.new(bar_index + 16, tp, tag, color=color.new(colDraw, weak ? 35 : 5), textcolor=weak ? color.new(#150A28, 30) : #150A28, style=label.style_label_left, size=size.small)
        array.push(drawLabels, dl)
        // directional bias chip at price — matches draw direction; hidden when weak
        if not weak
            label bm = label.new(bar_index + 2, close, up ? " ▲ PULL " : " ▼ PULL ", color=color.new(up ? colBSL : colSSL, 12), textcolor=#0A0A0A, style=label.style_label_left, size=size.small)
            array.push(drawLabels, bm)

    // ── Render structure events (last 3 only) ──
    if showStruct and array.size(evtBar) > 0
        int eN = array.size(evtBar)
        int eStart = math.max(0, eN - 3)
        for i = eStart to eN - 1
            int    eb = array.get(evtBar, i)
            float  el = array.get(evtLvl, i)
            int    et = array.get(evtType, i)
            bool   choch = et >= 2
            bool   up = et == 0 or et == 2
            color  lc = choch ? colAmber : (up ? colBSL : colSSL)
            line sl = line.new(eb, el, bar_index, el, color=color.new(lc, 30), width=1, style=choch ? line.style_dashed : line.style_solid)
            array.push(drawLines, sl)
            label sb = label.new(bar_index + 2 + (i - eStart) * 4, el, (choch ? (plainLabels ? "Reversal " : "CHoCH ") : (plainLabels ? "Trend break " : "BOS ")) + (up ? "↑" : "↓"), color=color.new(#000000, 100), textcolor=lc, style=label.style_label_left, size=size.tiny)
            array.push(drawLabels, sb)

    // ── Render sweeps (symbol for history, text on last 2) ──
    if showSweeps and array.size(swpBar) > 0
        int sN = array.size(swpBar)
        for i = 0 to sN - 1
            int   sb = array.get(swpBar, i)
            float sv = array.get(swpLvl, i)
            bool  buy = array.get(swpBuy, i)
            color sc = color.new(buy ? colBSL : colSSL, 0)
            if i >= sN - 2
                label ml = label.new(sb, sv, (buy ? "BSL" : "SSL") + " swept", color=color.new(#000000, 100), textcolor=sc, style=buy ? label.style_label_down : label.style_label_up, size=size.tiny)
                array.push(drawLabels, ml)
            else
                label mk = label.new(sb, sv, "×", color=color.new(#000000, 100), textcolor=color.new(buy ? colBSL : colSSL, 20), style=label.style_none, size=size.tiny)
                array.push(drawLabels, mk)

    // ── Render OB ──
    if showOB and array.size(obT) > 0
        for i = 0 to array.size(obT) - 1
            bool bull = array.get(obBull, i)
            bool mit  = array.get(obMit, i)
            color oc = mit ? color.new(#7A7A8C, 92) : color.new(bull ? colBSL : colSSL, 74)
            box ob = box.new(array.get(obX, i), array.get(obT, i), bar_index, array.get(obB, i), border_color=color.new(mit ? #7A7A8C : (bull ? colBSL : colSSL), mit ? 80 : 40), border_width=1, bgcolor=oc)
            array.push(obBoxes, ob)
            if not mit
                label obl = label.new(array.get(obX, i), bull ? array.get(obB, i) : array.get(obT, i), "OB", color=color.new(#000000, 100), textcolor=color.new(bull ? colBSL : colSSL, 0), style=bull ? label.style_label_up : label.style_label_down, size=size.tiny)
                array.push(drawLabels, obl)

    // ── Render FVG ──
    if showFVG and array.size(fvT) > 0
        for i = 0 to array.size(fvT) - 1
            bool bull = array.get(fvBull, i)
            bool mit  = array.get(fvMit, i)
            color fc = mit ? color.new(#7A7A8C, 88) : color.new(bull ? colBSL : colSSL, 85)
            box fb = box.new(array.get(fvX, i), array.get(fvT, i), bar_index, array.get(fvB, i), border_color=color.new(bull ? colBSL : colSSL, 90), bgcolor=fc)
            array.push(obBoxes, fb)

// ─── EMPIRICAL HIT-RATE TRACKING (every confirmed bar, non-repainting) ────────
if barstate.isconfirmed
    // resolve pending observations against realized highs/lows
    if array.size(pendLvl) > 0
        int i = array.size(pendLvl) - 1
        while i >= 0
            float lv = array.get(pendLvl, i)
            bool  ab = array.get(pendAbove, i)
            int   bk = array.get(pendBucket, i)
            bool reached = (ab and high >= lv) or (not ab and low <= lv)
            bool expired = bar_index >= array.get(pendDead, i)
            if reached or expired
                array.set(totC, bk, array.get(totC, bk) + 1)
                if reached
                    array.set(hitC, bk, array.get(hitC, bk) + 1)
                array.remove(pendLvl, i)
                array.remove(pendAbove, i)
                array.remove(pendBucket, i)
                array.remove(pendDead, i)
            i := i - 1
    // register a new observation when the draw target changes
    if not na(targetLvl) and targetBucket >= 0 and (na(lastRegLvl) or math.abs(targetLvl - lastRegLvl) > EPS)
        array.push(pendLvl, targetLvl)
        array.push(pendAbove, targetLvl > close)
        array.push(pendBucket, targetBucket)
        array.push(pendDead, bar_index + hitHorizon)
        lastRegLvl := targetLvl
        if array.size(pendLvl) > 60
            array.shift(pendLvl)
            array.shift(pendAbove)
            array.shift(pendBucket)
            array.shift(pendDead)

// ─── MTF BIAS (non-repainting) ───────────────────────────────────────────────
[b1, s1] = request.security(syminfo.tickerid, tf1, htfState(), lookahead=barmerge.lookahead_off)
[b2, s2] = request.security(syminfo.tickerid, tf2, htfState(), lookahead=barmerge.lookahead_off)
[b3, s3] = request.security(syminfo.tickerid, tf3, htfState(), lookahead=barmerge.lookahead_off)

// ─── HUD ─────────────────────────────────────────────────────────────────────
var table hud = table.new(posMap(hudPos), 3, 9, bgcolor=color.new(#0B0B18, 8), frame_width=1, frame_color=color.new(#2C2C52, 25), border_width=0)

if showHud and barstate.islast
    color cBase  = color.new(#0B0B18, 8)
    color cZebra = color.new(#15152E, 8)
    color cHead  = color.new(#14142C, 0)
    color cTitle = color.new(#21214A, 0)
    color tHead  = #6E6E9A
    color tTf    = #B8B8DA

    int nlbDir = na(nlb) ? 0 : nlb > 0.05 ? 1 : nlb < -0.05 ? -1 : 0
    int bullN = 0
    int bearN = 0
    int totalP = array.size(poolP)
    if totalP > 0
        for i = 0 to totalP - 1
            if array.get(poolBuy, i)
                bullN += 1
            else
                bearN += 1

    table.cell(hud, 0, 0, "◆  LIQUIDITY MAP", text_color=#D8D8FF, text_size=size.small, bgcolor=cTitle, text_halign=text.align_left)
    table.cell(hud, 1, 0, "", bgcolor=cTitle)
    table.cell(hud, 2, 0, "", bgcolor=cTitle)

    table.cell(hud, 0, 1, " STRUCTURE", text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_left)
    table.cell(hud, 1, 1, " " + biasTxt(chartTrend) + " ", text_color=#FFFFFF, text_size=size.small, bgcolor=color.new(biasCol(chartTrend), 45), text_halign=text.align_center)
    table.cell(hud, 2, 1, " ", text_color=tTf, text_size=size.small, bgcolor=cHead)

    table.cell(hud, 0, 2, " LIQ PULL", text_color=tHead, text_size=size.small, bgcolor=cBase, text_halign=text.align_left)
    table.cell(hud, 1, 2, " " + biasTxt(nlbDir) + " ", text_color=#FFFFFF, text_size=size.small, bgcolor=color.new(biasCol(nlbDir), 45), text_halign=text.align_center)
    table.cell(hud, 2, 2, (na(nlb) ? "—" : (nlb >= 0 ? "+" : "") + str.tostring(nlb, "#.##")) + " ", text_color=biasCol(nlbDir), text_size=size.small, bgcolor=cBase, text_halign=text.align_center)

    bool   drawUp  = drawTargetIdx >= 0 and array.get(poolP, drawTargetIdx) > close
    color  drawAcc = drawTargetIdx < 0 ? color.new(#8888AA, 30) : color.new(drawUp ? colBSL : colSSL, 30)
    string drawTxt = drawTargetIdx >= 0 ? (drawUp ? "▲ " : "▼ ") + str.tostring(array.get(poolP, drawTargetIdx), format.mintick) : "—"
    int    hN   = useCalib and targetBucket >= 0 ? array.get(totC, targetBucket) : 999
    bool   hProv = useCalib and hN < CALIB_MIN_N
    string hPct = na(drawProb) ? "—" : (hProv ? "~" : "") + str.tostring(drawProb, "#") + "%"
    table.cell(hud, 0, 3, " DRAW", text_color=#0A0A0A, text_size=size.small, bgcolor=drawAcc, text_halign=text.align_left)
    table.cell(hud, 1, 3, drawTxt, text_color=#0A0A0A, text_size=size.small, bgcolor=drawAcc, text_halign=text.align_center)
    table.cell(hud, 2, 3, hPct + " ", text_color=hProv ? color.new(#0A0A0A, 45) : #0A0A0A, text_size=size.small, bgcolor=drawAcc, text_halign=text.align_center)

    table.cell(hud, 0, 4, " POOLS", text_color=tHead, text_size=size.small, bgcolor=cBase, text_halign=text.align_left)
    table.cell(hud, 1, 4, str.tostring(bullN) + " BSL ", text_color=colBSL, text_size=size.small, bgcolor=cBase, text_halign=text.align_center)
    table.cell(hud, 2, 4, str.tostring(bearN) + " SSL ", text_color=colSSL, text_size=size.small, bgcolor=cBase, text_halign=text.align_center)

    table.cell(hud, 0, 5, " MTF", text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_left)
    table.cell(hud, 1, 5, "BIAS", text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)
    table.cell(hud, 2, 5, "STR ", text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)

    for i = 0 to 2
        string lbl = i == 0 ? tf1 : i == 1 ? tf2 : tf3
        int    bv  = i == 0 ? b1  : i == 1 ? b2  : b3
        float  sv  = i == 0 ? s1  : i == 1 ? s2  : s3
        color  rowB = i % 2 == 0 ? cZebra : cBase
        table.cell(hud, 0, i + 6, " " + lbl, text_color=tTf, text_size=size.small, bgcolor=rowB, text_halign=text.align_left)
        table.cell(hud, 1, i + 6, " " + biasTxt(bv) + " ", text_color=#FFFFFF, text_size=size.small, bgcolor=color.new(biasCol(bv), 45), text_halign=text.align_center)
        table.cell(hud, 2, i + 6, strBar(sv) + " ", text_color=biasCol(bv), text_size=size.small, bgcolor=rowB, text_halign=text.align_center)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(barstate.isconfirmed and not na(lh) and high > lh + sweepPen * atr and close < lh, "BSL swept", "LMOB: buy-side liquidity swept")
alertcondition(barstate.isconfirmed and not na(ll) and low < ll - sweepPen * atr and close > ll,  "SSL swept", "LMOB: sell-side liquidity swept")
alertcondition(barstate.isconfirmed and evtBosUp, "BOS up",   "LMOB: bullish break of structure")
alertcondition(barstate.isconfirmed and evtBosDn, "BOS down", "LMOB: bearish break of structure")
alertcondition(barstate.isconfirmed and b1 > 0 and b2 > 0 and b3 > 0, "All TF Bullish", "LMOB: all timeframes bullish")
alertcondition(barstate.isconfirmed and b1 < 0 and b2 < 0 and b3 < 0, "All TF Bearish", "LMOB: all timeframes bearish")
````
