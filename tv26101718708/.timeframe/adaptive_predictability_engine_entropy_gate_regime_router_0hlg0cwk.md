# Adaptive Predictability Engine  Entropy Gate, Regime Router

- url: https://www.tradingview.com/script/0HLg0CWk-Adaptive-Predictability-Engine-Entropy-Gate-Regime-Router/
- type: indicator
- pine_id: PUB;703b74347c3141c89261bb96588ae366
- version: 3.0

## Description

Adaptive Predictability Engine — Entropy Gate, Regime Router & Expert Committee

What it is

The Adaptive Predictability Engine is a governed decision framework, not another confluence average. It refuses to treat all market conditions as tradable. It applies a strict hierarchy: first it asks whether price is forecastable at all right now; if it is, it decides whether trend-style or reversion-style logic is appropriate; and only then does a small committee of transparent experts vote — with the committee continuously re-weighting itself toward whichever experts have been correct recently. When the market is unpredictable, the whole engine stands aside and shows nothing to trade.

It plots directly on price: long/short signals, the live entry/target/stop of the active trade, a plain-language dashboard, and an optional self-calibration panel that scores past signals in R-multiple expectancy (not just win rate).

Why these components are combined (mashup justification)

This is a deliberate, dependent stack — each layer conditions the next, so removing any one changes the layer below it. That is the difference between a governed engine and a bag of averaged indicators.


Predictability gate (permutation entropy + structure). Permutation entropy (Bandt–Pompe) measures the ordinal randomness of recent price across three time scales; this is blended with |Hurst − 0.5|, the distance of the market from a random walk, which is high for strong trends and strong mean-reversion. The blended predictability is percentile-ranked so the gate self-tunes per symbol and timeframe. If the tape is unpredictable, nothing downstream may fire. This is the master switch, and it is why the engine spends much of its time deliberately doing nothing.

Regime router (Hurst exponent). When structure exists, the Hurst exponent (generalized, via a structure-function slope) decides whether it is persistent (trend) or anti-persistent (mean-revert), and routes weight toward the appropriate family of experts rather than averaging trend and reversion logic together.

Expert committee (Hedge / multiplicative weights). Six deliberately diverse experts — price trend, volume-weighted price, order-flow delta, momentum exhaustion, volatility extreme, and range extreme — each cast a directional vote. Their weights update every bar by exponential regret (right experts gain influence, wrong ones lose it), with fixed-share regularization so no single expert can dominate and make the vote fragile.

Distribution-shift guard. If the recent return distribution moves materially versus a reference window, the engine freezes learning and cuts conviction until conditions settle, so stale weights don't drive trades through a regime change.


The output is a single decision = the regret-weighted vote of only the currently-appropriate experts, gated to zero whenever the tape is unpredictable.

How to use it


Add it to any liquid symbol and timeframe. Defaults are tuned for index futures (e.g. NIFTY) but every input is adjustable, and the Data source group lets you repoint price and volume for any market.

Watch the dashboard headline: LONG / SHORT / WAIT / STAND ASIDE. When a signal fires, the engine draws the entry, ATR target, and ATR stop so the action is concrete.
Treat the shaded background as a hard "do not trade" — the engine has judged the tape unpredictable.

Open the Edge calibration (advanced) panel to see, per market memory, the past R-expectancy of the engine's own signals versus a direction-matched baseline. Positive expectancy means the sample was profitable before costs; this is descriptive of the past, not a forward guarantee.

Use the Ablation (research) toggles to switch each layer off and see, on your own data, whether it earns its place.


What makes it original

Most published tools average indicators and hope. This one inverts the approach by asking whether to act at all before what to do, using information-theoretic predictability (permutation entropy) as a master gate, a memory estimate (Hurst) as a router, and online regret-minimization (Hedge) to arbitrate a diverse expert set — with built-in R-expectancy self-calibration so users can judge it honestly rather than on a cherry-picked screenshot. The order-flow expert reads finest-available lower-timeframe signed volume with automatic fallback. The coupling and governance order are the contribution; the individual estimators are classical and credited below.

Concept credits

Permutation entropy — Bandt & Pompe. Hurst exponent / long-range dependence — H. E. Hurst; Mandelbrot. Hedge / multiplicative-weights online learning — Freund & Schapire; Littlestone & Warmuth; Vovk. Efficiency/structure framing — Kaufman. Triple-barrier labelling and R-multiple expectancy — M. López de Prado. Wilson score interval — E. B. Wilson. Synthesis, governance design, and implementation are the author's own.

Important disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. No indicator has an inherent edge. The calibration panel is a descriptive summary of past behaviour on the current chart — not a backtest and not a forward prediction. Always validate independently, apply realistic costs and slippage, and manage risk. You are solely responsible for your trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  ADAPTIVE PREDICTABILITY ENGINE                                           v1.1
//  v1.1 — House-standard pass (no engine change): added the MPL-2.0 header, an EXP_ export bus, and a
//         round-trip COST model. The R-expectancy panel now shows NetR = ExpR − cost (and exports it),
//         so the past-performance read is honest about costs. No conditional ta.* — no correctness fix.
//  Entropy Gate · Regime Router · Self-Learning Expert Committee
//  A governed decision engine on the price chart: it decides WHETHER to act,
//  WHICH style fits, and only then WHO to listen to — instead of averaging
//  indicators. Plots signals, live target/stop levels, and a plain-language
//  dashboard directly over price.
// -----------------------------------------------------------------------------
//  ONE-LINE IDEA
//    Most "confluence" tools average many signals and hope. This one imposes a
//    decision HIERARCHY. A predictability gate first asks whether price is even
//    forecastable right now; a memory router then decides whether trend-style or
//    reversion-style logic is appropriate; and only then does a self-learning
//    committee of experts vote — re-weighted every bar toward whoever has been
//    right lately. If the market is unpredictable, the whole stack outputs zero.
//
//  WHY THESE PARTS BELONG TOGETHER (mashup justification)
//    These are not independent indicators stacked for a vote. Each governs the
//    next, so removing any one breaks the layer below it:
//      1. PREDICTABILITY GATE (permutation entropy, Bandt–Pompe). Measures the
//         ordinal randomness of recent price. High entropy = structureless tape
//         = the engine STANDS ASIDE and stops learning from noise. This is the
//         master switch; nothing downstream fires when it is closed.
//      2. MEMORY ROUTER (generalized Hurst exponent). When structure exists, is
//         it persistent (trend) or anti-persistent (mean-revert)? Hurst > 0.5
//         routes weight toward trend-type experts, < 0.5 toward reversion-type,
//         ≈ 0.5 toward neither — so the right family of logic is selected, not
//         averaged with the wrong one.
//      3. EXPERT COMMITTEE (Hedge / multiplicative weights). A set of simple,
//         transparent experts (some trend, some reversion) each cast a vote.
//         Their weights update every bar by exponential regret: experts that
//         were recently right gain influence, those that were wrong lose it —
//         with provable no-regret behaviour and no lookahead.
//      4. SHIFT GUARD (distribution change). If the return distribution shifts
//         materially, learned weights may be stale, so learning freezes and
//         conviction is cut until the new distribution is characterised.
//    The output is one signal = the regret-weighted vote of ONLY the currently
//    appropriate experts, gated to zero whenever the tape is unpredictable.
//
//  ORIGINALITY
//    The novelty is the COUPLING and governance order: entropy gates, Hurst
//    routes, Hedge arbitrates, a shift monitor protects the learner. It also
//    reports WHICH expert currently leads, so the read is interpretable rather
//    than a black box. Every raw input is user-selectable; the engine is
//    market-agnostic. Defaults are set for NIFTY index futures.
//
//  HOW TO READ IT (on the price chart)
//    ▲ below a bar = long signal · ▼ above a bar = short signal · ✕ = exit.
//    While a trade is live its ENTRY, TARGET and STOP levels are drawn.
//    Shaded background = engine is standing aside (tape unpredictable) → no trade.
//    Bars tint green/red when armed long/short, neutral when standing aside.
//    The dashboard states it plainly: LONG / SHORT / WAIT / STAND ASIDE, plus the
//    market mode, which expert is leading, and what to do.
//
//  NON-REPAINT
//    Entropy, Hurst, weight updates, the committee vote and all signals resolve
//    only on CONFIRMED bars; a prediction made on bar t is scored on bar t+1.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Permutation entropy — Bandt & Pompe (2002).
//    • Hurst exponent / long-range dependence — H. E. Hurst; Mandelbrot.
//    • Hedge / multiplicative-weights online learning — Freund & Schapire;
//      Littlestone & Warmuth; Vovk.
//    • Distribution-shift monitoring — change-detection / optimal-transport
//      literature (Kantorovich–Wasserstein).
//    • Triple-barrier labelling & R-multiple expectancy — M. López de Prado.
//    Synthesis, governance design and Pine implementation are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. No indicator has an inherent edge;
//    validate with your own testing, apply realistic costs, and manage risk.
// =============================================================================
indicator("Adaptive Predictability Engine — Entropy Gate, Regime Router & Expert Committee", "Predict-Engine",
     overlay = true, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE (any market) ════════════════════
g0 = "00 · Data source"
srcPrice = input.source(close, "Price source", group = g0,
     tooltip = "Series the engine reads. Default 'close'. Change for spreads, Heikin-Ashi, or custom symbols so the tool works on any market.")
volSrc   = input.source(volume, "Volume source", group = g0,
     tooltip = "Volume series for the order-flow expert. Default built-in volume. Point at an alternative feed where needed.")
useLtf   = input.bool(true, "Order flow from lower-timeframe volume", group = g0,
     tooltip = "ON = build the order-flow expert's delta from finer intrabar candles (signed volume), a truer read than single-bar shape. Falls back to bar-shape automatically if intrabar data is unavailable on your plan/symbol.")
ltfPick  = input.string("Auto (finest)", "Lower timeframe for delta",
     options = ["Auto (finest)", "1 second", "5 seconds", "1 minute"], group = g0,
     tooltip = "AUTO tries 1-second intrabars first and automatically falls back to 1-minute when your plan/symbol has no seconds data, then to single-bar shape if neither is available. (True tick data isn't accessible to a Pine indicator, so 1 second is the finest resolution.) Finer = more faithful order flow.")

// ═════════════════════════ 01 · PREDICTABILITY GATE ═════════════════════════
g1 = "01 · Predictability gate"
peDelay  = input.int(1, "Base ordinal delay τ", minval = 1, maxval = 10, group = g1,
     tooltip = "Base spacing of the samples that form each ordinal pattern. Entropy is read at MULTIPLE scales (τ, 2τ, 4τ) so structure at any of them registers.")
peWin    = input.int(80, "Entropy window", minval = 20, maxval = 500, group = g1,
     tooltip = "How many recent ordinal patterns define the entropy estimate at each scale. Shorter = more reactive.")
peWeight = input.float(0.5, "Entropy vs structure blend", minval = 0.0, maxval = 1.0, step = 0.1, group = g1,
     tooltip = "Predictability blends permutation entropy with STRUCTURE = |Hurst − 0.5| (distance from a random walk — high for strong trends AND strong mean-reversion, so the gate is not trend-biased). 1 = entropy only, 0 = structure only, 0.5 = equal. Each is percentile-ranked so both get a fair voice.")
gatePctile = input.float(60.0, "Adaptive gate — open above percentile", minval = 0.0, maxval = 100.0, step = 5.0, group = g1,
     tooltip = "THE MAIN GATE KNOB. The engine acts when composite predictability ranks above this percentile of its own recent history, so it self-tunes per symbol / timeframe. 60 opens on the most-structured ~40% of bars. Lower = more signals.")
gateLook = input.int(300, "Adaptive gate lookback", minval = 50, maxval = 2000, group = g1,
     tooltip = "How far back the percentile rank is measured.")
predGate = input.float(0.0, "Absolute floor (0 = off)", minval = 0.0, maxval = 1.0, step = 0.02, group = g1,
     tooltip = "Optional hard floor on composite predictability, on top of the adaptive gate. Leave 0 unless you want an absolute minimum too.")

// ═════════════════════════ 02 · MEMORY ROUTER (HURST) ═══════════════════════
g2 = "02 · Memory router (Hurst)"
hurstWin = input.int(100, "Hurst window", minval = 30, maxval = 500, group = g2,
     tooltip = "Lookback for the generalized Hurst exponent (structure-function slope). Longer = smoother memory read.")
hTrendCut  = input.float(0.52, "Trend label cutoff  (H >)", minval = 0.5, maxval = 0.9, step = 0.01, group = g2)
hRevertCut = input.float(0.48, "Revert label cutoff  (H <)", minval = 0.1, maxval = 0.5, step = 0.01, group = g2)

// ═════════════════════════ 03 · EXPERT COMMITTEE ════════════════════════════
g3 = "03 · Expert committee (Hedge)"
eta      = input.float(0.60, "Learning rate η", minval = 0.05, maxval = 3.0, step = 0.05, group = g3,
     tooltip = "How fast weights chase recent accuracy. Higher = faster adaptation, more variance.")
wShrink  = input.float(0.10, "Weight diversification (0 = pure winner-take-all)", minval = 0.0, maxval = 0.5, step = 0.05, group = g3,
     tooltip = "Pulls each update back toward equal weights so no single expert can dominate (fixed-share regularisation). 0 lets one expert reach ~100% — which we observed making the committee fragile and sign-flip across timeframes. 0.10 keeps it diversified and stable.")
emaFast  = input.int(9,  "Expert · EMA fast", minval = 2, group = g3, inline = "e1")
emaSlow  = input.int(21, "slow",              minval = 3, group = g3, inline = "e1")
rocLen   = input.int(10, "Expert · Order-flow smoothing", minval = 2, group = g3)
donLen   = input.int(20, "Expert · Range length", minval = 3, group = g3)
rsiLen   = input.int(14, "Expert · RSI length",      minval = 2, group = g3)
bbLen    = input.int(20, "Expert · Band length",     minval = 3, group = g3)

// ═════════════════════════ 04 · SHIFT GUARD ═════════════════════════════════
g4 = "04 · Distribution-shift guard"
shiftOn   = input.bool(true, "Freeze learning on distribution shift", group = g4,
     tooltip = "If the recent return distribution moves materially versus a reference window, weight learning freezes and conviction is cut until it settles.")
shiftShort = input.int(20,  "Recent window", minval = 5, group = g4)
shiftLong  = input.int(100, "Reference window", minval = 20, group = g4)
shiftThr   = input.float(0.60, "Shift sensitivity", minval = 0.1, maxval = 3.0, step = 0.05, group = g4)

// ═════════════════════════ 05 · SIGNALS ═════════════════════════════════════
g5 = "05 · Signals"
entryThr   = input.float(0.35, "Conviction to arm a signal", minval = 0.05, maxval = 1.0, step = 0.05, group = g5,
     tooltip = "Committee conviction (absolute) needed to fire, with the gate open. Higher = fewer, stronger signals.")
showTrades = input.bool(true, "Show entry / exit markers", group = g5)
showLevels = input.bool(true, "Show active trade levels (entry / target / stop)", group = g5,
     tooltip = "While a signal is live, draws its entry, ATR profit-target and ATR stop on the chart so the action is concrete, not just a marker.")
colorBars  = input.bool(true, "Colour bars by bias", group = g5,
     tooltip = "Tints price bars green/red when the engine is armed long/short, and leaves them neutral when standing aside.")

// ═════════════════════════ 06 · EXTERNAL EXPERTS (optional) ═════════════════
g6 = "06 · External experts (optional)"
extOn1 = input.bool(false, "Enable external expert 1", group = g6, inline = "x1")
extSrc1 = input.source(close, "src", group = g6, inline = "x1")
extTy1  = input.string("Auto", "type", options = ["Trend", "Revert", "Auto"], group = g6, inline = "x1")
extOn2 = input.bool(false, "Enable external expert 2", group = g6, inline = "x2")
extSrc2 = input.source(close, "src", group = g6, inline = "x2")
extTy2  = input.string("Auto", "type", options = ["Trend", "Revert", "Auto"], group = g6, inline = "x2")
extOn3 = input.bool(false, "Enable external expert 3", group = g6, inline = "x3")
extSrc3 = input.source(close, "src", group = g6, inline = "x3")
extTy3  = input.string("Auto", "type", options = ["Trend", "Revert", "Auto"], group = g6, inline = "x3")
extScale = input.float(10.0, "External full-scale (±)", minval = 0.1, step = 0.5, group = g6,
     tooltip = "Value at which a connected external score is treated as fully directional. Bias-score exports often saturate at ±10.")

// ═════════════════════════ 07 · DASHBOARD & THEME ═══════════════════════════
g7 = "07 · Dashboard & theme"
showDash = input.bool(true, "Show decision dashboard", group = g7)
showKey  = input.bool(false, "Show key-info panel", group = g7)
dashPos  = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g7)
keyPos   = input.string("Top Left", "Key-info position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g7)
themeOpt = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g7,
     tooltip = "Auto reads the chart background so panels stay readable on any colour scheme.")

// ═════════════════════════ 08 · EDGE CALIBRATION (advanced) ═════════════════
g8 = "08 · Edge calibration (advanced)"
calEnable    = input.bool(true, "Log signals for calibration", group = g8,
     tooltip = "Scores each past signal after a horizon versus a style-matched base rate. Descriptive of the PAST on this symbol — NOT a backtest or forward prediction.")
calShowPanel = input.bool(false, "Show calibration panel (advanced)", group = g8)
calPanelPos  = input.string("Bottom Left", "Panel position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g8)
calMaxBars   = input.int(20, "Time barrier (bars)", minval = 3, maxval = 200, group = g8,
     tooltip = "The vertical barrier: max bars a trade is held before exiting at market.")
calTP        = input.float(1.5, "Profit target (× ATR)", minval = 0.2, maxval = 10.0, step = 0.1, group = g8,
     tooltip = "Upper barrier. If hit first, outcome = +target/stop in R (e.g. 1.5/1.0 = +1.5R).")
calSL        = input.float(1.0, "Stop (× ATR)", minval = 0.2, maxval = 10.0, step = 0.1, group = g8,
     tooltip = "Lower barrier = 1R of risk. If hit first, outcome = −1R. EXPECTANCY = average R across all signals — the metric that reflects tradeability. A 35% win rate at +1.5R target is profitable; hit-rate alone is not.")
costR        = input.float(0.30, "Round-trip cost (R) — subtracted for NetR", minval = 0.0, maxval = 3.0, step = 0.05, group = g8,
     tooltip = "Round-trip trading cost (brokerage + STT + slippage + optimistic fill) expressed in R — as a fraction of the 1R risk (Stop × ATR). NetR = ExpR − cost, shown in the R-expectancy panel and exported. A signal set with positive ExpR but negative NetR is not tradeable once costs are paid. Default 0.30 suits 1m NIFTY futures; lower it on cheaper instruments / higher timeframes.")

// ═════════════════════════ 09 · ABLATION (research toggles) ═════════════════
// Turn ONE layer off, read the calibration EDGE, turn it back on. If EDGE is
// unchanged with a layer off, that layer is not earning its place ON YOUR DATA.
g9 = "09 · Ablation (research)"
ablGate  = input.bool(true, "Layer 1 · use predictability gate", group = g9,
     tooltip = "OFF = the engine acts every bar (no entropy/structure filter). Compare the EDGE with this on vs off: if it barely moves, the gate is not helping on this symbol.")
ablRoute = input.bool(true, "Layer 2 · use Hurst routing", group = g9,
     tooltip = "OFF = every expert gets equal say regardless of trend/revert memory. If EDGE is unchanged, the router is decoration here.")
ablHedge = input.bool(true, "Layer 3 · use Hedge learning", group = g9,
     tooltip = "OFF = experts keep equal weights (no regret-based learning). If equal weights match or beat learning, the learner is not justified on this data.")

// ───────────────────────── PALETTE / THEME (adaptive) ───────────────────────
var color COL_BULL = #2ebd85
var color COL_BEAR = #f6465d
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 128

bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
color txtCol  = isDark ? color.new(#e8e8ea, 0) : color.new(#1a1a1a, 0)
color dimCol  = isDark ? color.new(#9aa0aa, 0) : color.new(#5a5f66, 0)
color zebraA  = isDark ? color.new(#1c2030, 18) : color.new(#eef1f6, 18)
color zebraB  = isDark ? color.new(#141826, 18) : color.new(#f8fafc, 18)
color frameCl = isDark ? color.new(#2a3142, 0)  : color.new(#c8cdd6, 0)

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_meter(float v) =>
    int filled = int(math.round(math.max(0.0, math.min(1.0, v)) * 10))
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

f_txtOn(color bg) =>
    f_lumaDark(bg) ? color.new(#f5f7fa, 0) : color.new(#0d1117, 0)

// ordinal pattern index (0..5) of three samples a(oldest) b c(newest)
f_patt(float a, float b, float c) =>
    int p = 0
    if a <= b
        p := b <= c ? 0 : (a <= c ? 1 : 2)
    else
        p := a <= c ? 3 : (b <= c ? 4 : 5)
    p

// normalised Shannon entropy (0..1) of a 6-bin ordinal histogram
f_entropy6(int[] cnt) =>
    float tot = 0.0
    for i = 0 to 5
        tot += array.get(cnt, i)
    float h = 0.0
    if tot > 0
        for i = 0 to 5
            float pi = array.get(cnt, i) / tot
            if pi > 0
                h -= pi * math.log(pi)
    tot > 0 ? h / math.log(6) : 1.0

// ───────────────────────── LAYER 1 · PREDICTABILITY (entropy) ────────────────
// Bandt–Pompe permutation entropy, read at THREE scales (τ, 2τ, 4τ). The most-
// structured scale drives predictability, so trend/structure at any horizon can
// open the gate — single-scale price entropy saturates near 1 on intraday noise.
int sc1 = peDelay
int sc2 = 2 * peDelay
int sc4 = 4 * peDelay
int patt1 = f_patt(srcPrice[2 * sc1], srcPrice[sc1], srcPrice)
int patt2 = f_patt(srcPrice[2 * sc2], srcPrice[sc2], srcPrice)
int patt4 = f_patt(srcPrice[2 * sc4], srcPrice[sc4], srcPrice)

var int[] pc1 = array.new_int(6, 0)
var int[] pc2 = array.new_int(6, 0)
var int[] pc4 = array.new_int(6, 0)
var int pfilled = 0
if barstate.isconfirmed and not na(srcPrice[2 * sc4])
    array.set(pc1, patt1, array.get(pc1, patt1) + 1)
    array.set(pc2, patt2, array.get(pc2, patt2) + 1)
    array.set(pc4, patt4, array.get(pc4, patt4) + 1)
    pfilled += 1
    if pfilled > peWin
        int o1 = patt1[peWin]
        int o2 = patt2[peWin]
        int o4 = patt4[peWin]
        array.set(pc1, o1, array.get(pc1, o1) - 1)
        array.set(pc2, o2, array.get(pc2, o2) - 1)
        array.set(pc4, o4, array.get(pc4, o4) - 1)
        pfilled -= 1

float H1 = f_entropy6(pc1)
float H2 = f_entropy6(pc2)
float H4 = f_entropy6(pc4)
float peH = math.min(H1, math.min(H2, H4))     // most-structured scale
float peP = na(peH) ? 0.0 : 1.0 - peH          // entropy predictability (small range)

// ── MEMORY (Hurst) — computed here because it also feeds the gate below ──
// Generalized Hurst via structure-function slope over lags {1,2,4,8,16}.
float sf1  = ta.sma(math.abs(srcPrice - srcPrice[1]),  hurstWin)
float sf2  = ta.sma(math.abs(srcPrice - srcPrice[2]),  hurstWin)
float sf4  = ta.sma(math.abs(srcPrice - srcPrice[4]),  hurstWin)
float sf8  = ta.sma(math.abs(srcPrice - srcPrice[8]),  hurstWin)
float sf16 = ta.sma(math.abs(srcPrice - srcPrice[16]), hurstWin)
var float HX0 = 0.0
var float HX1 = 0.6931
var float HX2 = 1.3863
var float HX3 = 2.0794
var float HX4 = 2.7726
var float HSUMX = 6.9315
var float HDEN  = 5.0 * 14.4136 - 6.9315 * 6.9315
float hurst = na
if sf1 > 0 and sf2 > 0 and sf4 > 0 and sf8 > 0 and sf16 > 0
    float y0 = math.log(sf1)
    float y1 = math.log(sf2)
    float y2 = math.log(sf4)
    float y3 = math.log(sf8)
    float y4 = math.log(sf16)
    float sumY  = y0 + y1 + y2 + y3 + y4
    float sumXY = HX0 * y0 + HX1 * y1 + HX2 * y2 + HX3 * y3 + HX4 * y4
    float slope = (5.0 * sumXY - HSUMX * sumY) / HDEN
    hurst := math.max(0.0, math.min(1.0, slope))
float Hval = na(hurst) ? 0.5 : hurst
float trendiness  = math.max(0.0, math.min(1.0, (Hval - 0.5) / 0.5))
float revertiness = math.max(0.0, math.min(1.0, (0.5 - Hval) / 0.5))

// ── COMPOSITE PREDICTABILITY: entropy + DIRECTION-NEUTRAL structure ──
// Structure = distance of Hurst from a random walk (2·|H−0.5|). High for BOTH
// strong trends AND strong mean-reversion, so the gate is not trend-biased —
// mean-reversion is just as forecastable and must not be starved of signals.
float hStruct = math.max(trendiness, revertiness)
float peRank = ta.percentrank(peP, gateLook)
float hsRank = ta.percentrank(hStruct, gateLook)
float predRank = peWeight * peRank + (1.0 - peWeight) * hsRank
float predictability = peWeight * peP + (1.0 - peWeight) * hStruct
bool  warm = pfilled >= math.min(peWin, 20)
bool  gateOpen = warm and (not ablGate or (predRank >= gatePctile and predictability >= predGate))

// rolling gate-open fraction (so the user can see it is alive and tune it)
var int gateHits = 0
var int gateSeen = 0
if barstate.isconfirmed and warm
    gateSeen += 1
    if gateOpen
        gateHits += 1
float gateFrac = gateSeen > 0 ? gateHits / float(gateSeen) : 0.0

// ───────────────────────── LAYER 4 · SHIFT GUARD ────────────────────────────
float ret     = srcPrice - srcPrice[1]
float muS     = ta.sma(ret, shiftShort)
float muL     = ta.sma(ret, shiftLong)
float sdL     = ta.stdev(ret, shiftLong)
float sdS     = ta.stdev(ret, shiftShort)
float shiftScore = sdL > 0 ? (math.abs(muS - muL) + math.abs(sdS - sdL)) / sdL : 0.0
bool  shifted = shiftOn and shiftScore > shiftThr

// ───────────────────────── LAYER 3 · EXPERT SIGNALS ─────────────────────────
// Six DISTINCT information sources so the committee has diverse raw material:
// price trend, volume-weighted price, order flow, momentum, volatility, range.
// Order-flow delta is built from the finest available intrabar volume (signed
// by intrabar direction) — a truer read than single-bar shape, with fallback.
// Order-flow intrabar resolution. AUTO cascade: prefer the finest available —
// 1-second intrabars — and if the plan/symbol returns none, fall back to
// 1-minute; if neither is available (or LTF is off) the engine uses bar-shape.
// Both requests are issued UNCONDITIONALLY because Pine forbids request.*()
// inside a condition; the per-bar choice is only WHICH result to read. Note:
// true tick data cannot be requested from a Pine indicator, so 1 second is the
// finest reachable rung of the cascade.
f_signedVol() => math.sign(close - close[1]) * volume
string ltfPrimary = ltfPick == "5 seconds" ? "5S" : ltfPick == "1 minute" ? "1" : "1S"
bool   autoLtf    = ltfPick == "Auto (finest)"
float[] ltfSec = request.security_lower_tf(syminfo.tickerid, ltfPrimary, f_signedVol())
float[] ltfMin = request.security_lower_tf(syminfo.tickerid, "1",        f_signedVol())
bool    secOk  = array.size(ltfSec) > 0
float[] ltfArr = secOk ? ltfSec : (autoLtf ? ltfMin : ltfSec)
string  usedTf = secOk ? ltfPrimary : (autoLtf and array.size(ltfMin) > 0 ? "1" : ltfPrimary)
float ltfSum = 0.0
if array.size(ltfArr) > 0
    for v in ltfArr
        ltfSum += nz(v)
bool ltfOk = useLtf and array.size(ltfArr) > 0
string deltaMode = not useLtf ? "bar-shape (off)" : ltfOk ? ("LTF " + usedTf) : "bar-shape"

float efast = ta.ema(srcPrice, emaFast)
float eslow = ta.ema(srcPrice, emaSlow)
float vwapV = ta.vwap(hlc3)
float barShape = (high - low) > 0 ? volSrc * ((close - low) - (high - close)) / (high - low) : 0.0
float ofRaw = ltfOk ? ltfSum : barShape
float ofSm  = ta.ema(ofRaw, rocLen)
float rngHi = ta.highest(high, donLen)
float rngLo = ta.lowest(low, donLen)
float rngPos = (rngHi - rngLo) > 0 ? (srcPrice - rngLo) / (rngHi - rngLo) : 0.5
float rsiV  = ta.rsi(srcPrice, rsiLen)
float bbMid = ta.sma(srcPrice, bbLen)
float bbSd  = ta.stdev(srcPrice, bbLen)
float bbZ   = bbSd > 0 ? (srcPrice - bbMid) / bbSd : 0.0
float atrV  = ta.atr(14)

// expert votes  (0-2 trend-type · 3-5 revert-type)
float sEma = math.sign(efast - eslow)                          // price trend
float sVwp = math.sign(srcPrice - vwapV)                       // vs session VWAP
float sOfl = math.sign(ofSm)                                   // order-flow delta
float sRsi = rsiV > 70 ? -1.0 : rsiV < 30 ? 1.0 : 0.0          // momentum exhaustion
float sBnd = bbZ > 1 ? -1.0 : bbZ < -1 ? 1.0 : 0.0             // volatility extreme
float sRng = rngPos > 0.8 ? -1.0 : rngPos < 0.2 ? 1.0 : 0.0    // range extreme
f_extVote(bool on, float src, float scale) =>
    on ? math.max(-1.0, math.min(1.0, src / scale)) : 0.0
float sX1 = f_extVote(extOn1, extSrc1, extScale)
float sX2 = f_extVote(extOn2, extSrc2, extScale)
float sX3 = f_extVote(extOn3, extSrc3, extScale)

// expert registry (index): 0 EMA,1 Mom,2 Brk (trend) · 3 RSI,4 Band,5 VWAP (revert) · 6-8 external
int NE = 9
f_extType(string t) =>
    t == "Trend" ? 1 : t == "Revert" ? 0 : 2
var int[] etype = array.new_int(NE, 0)
var bool[] eact = array.new_bool(NE, false)
var int nActive = 0
var string[] enames = array.new_string(NE, "")
var float[] w = array.new_float(NE, 0.0)
var float[] prevSig = array.new_float(NE, 0.0)
var float[] curSig  = array.new_float(NE, 0.0)
if barstate.isfirst
    array.set(etype, 0, 1)
    array.set(etype, 1, 1)
    array.set(etype, 2, 1)
    array.set(etype, 3, 0)
    array.set(etype, 4, 0)
    array.set(etype, 5, 0)
    array.set(etype, 6, f_extType(extTy1))
    array.set(etype, 7, f_extType(extTy2))
    array.set(etype, 8, f_extType(extTy3))
    array.set(eact, 0, true)
    array.set(eact, 1, true)
    array.set(eact, 2, true)
    array.set(eact, 3, true)
    array.set(eact, 4, true)
    array.set(eact, 5, true)
    array.set(eact, 6, extOn1)
    array.set(eact, 7, extOn2)
    array.set(eact, 8, extOn3)
    array.set(enames, 0, "EMA cross")
    array.set(enames, 1, "VWAP position")
    array.set(enames, 2, "Order flow")
    array.set(enames, 3, "RSI fade")
    array.set(enames, 4, "Band fade")
    array.set(enames, 5, "Range fade")
    array.set(enames, 6, "External 1")
    array.set(enames, 7, "External 2")
    array.set(enames, 8, "External 3")
    int nAct = 0
    for i = 0 to NE - 1
        if array.get(eact, i)
            nAct += 1
    nActive := nAct
    float w0 = nAct > 0 ? 1.0 / nAct : 0.0
    for i = 0 to NE - 1
        array.set(w, i, array.get(eact, i) ? w0 : 0.0)

// ───────────────────────── COMMITTEE (confirmed-bar, non-repaint) ────────────
var float committee = 0.0
var int   topExpert = -1
var bool inLong  = false
var bool inShort = false
var float entryPx = na
var float tgtPx   = na
var float stpPx   = na
bool entLong  = false
bool entShort = false
bool exitSig  = false

f_aff(int ty, float tn, float rv) =>
    ty == 1 ? tn : ty == 0 ? rv : math.max(tn, rv)

if barstate.isconfirmed
    // 1) score previous votes and update weights (unless gate closed / shifted)
    float rSign = math.sign(srcPrice - srcPrice[1])
    bool learn = gateOpen and not shifted and ablHedge
    if learn
        for i = 0 to NE - 1
            if array.get(eact, i)
                float ps = array.get(prevSig, i)
                float loss = ps == 0 ? 0.5 : (math.sign(ps) == rSign ? 0.0 : 1.0)
                array.set(w, i, array.get(w, i) * math.exp(-eta * loss))
        float sw = 0.0
        for i = 0 to NE - 1
            if array.get(eact, i)
                sw += array.get(w, i)
        if sw > 0
            for i = 0 to NE - 1
                if array.get(eact, i)
                    array.set(w, i, array.get(w, i) / sw)
        // fixed-share shrinkage toward uniform — prevents single-expert lock-in
        // (the failure mode where one expert holds ~100% and the vote sign-flips)
        if wShrink > 0 and nActive > 0
            float wu = 1.0 / nActive
            for i = 0 to NE - 1
                if array.get(eact, i)
                    array.set(w, i, (1.0 - wShrink) * array.get(w, i) + wShrink * wu)

    // 2) load current votes  (nz-guarded so a single na vote — e.g. warmup or a
    //    volume-less symbol whose order-flow read is na — can never null the
    //    whole committee and blank every output)
    array.set(curSig, 0, nz(sEma))
    array.set(curSig, 1, nz(sVwp))
    array.set(curSig, 2, nz(sOfl))
    array.set(curSig, 3, nz(sRsi))
    array.set(curSig, 4, nz(sBnd))
    array.set(curSig, 5, nz(sRng))
    array.set(curSig, 6, nz(sX1))
    array.set(curSig, 7, nz(sX2))
    array.set(curSig, 8, nz(sX3))

    // 3) routed, weighted committee vote
    float num = 0.0
    float den = 0.0
    float wmax = -1.0
    int   wtop = -1
    for i = 0 to NE - 1
        if array.get(eact, i)
            float aff = ablRoute ? f_aff(array.get(etype, i), trendiness, revertiness) : 1.0
            float wi  = ablHedge ? array.get(w, i) : 1.0
            num += wi * aff * array.get(curSig, i)
            den += wi * aff
            if wi > wmax
                wmax := wi
                wtop := i
    float raw = den > 0 ? num / den : 0.0
    if shifted
        raw *= 0.4
    committee := gateOpen ? raw : 0.0
    topExpert := wtop

    // 4) persist current votes for next-bar scoring
    for i = 0 to NE - 1
        array.set(prevSig, i, array.get(curSig, i))

    // 5) position state machine
    bool longOK  = committee >=  entryThr and gateOpen
    bool shortOK = committee <= -entryThr and gateOpen
    if not inLong and not inShort
        if longOK
            inLong := true
            entLong := true
        else if shortOK
            inShort := true
            entShort := true
    else if inLong
        if committee <= 0.0 or not gateOpen or shortOK
            inLong := false
            exitSig := true
            if shortOK
                inShort := true
                entShort := true
    else if inShort
        if committee >= 0.0 or not gateOpen or longOK
            inShort := false
            exitSig := true
            if longOK
                inLong := true
                entLong := true
    // set actionable levels when a new trade opens
    if entLong
        entryPx := close
        tgtPx   := close + calTP * atrV
        stpPx   := close - calSL * atrV
    if entShort
        entryPx := close
        tgtPx   := close - calTP * atrV
        stpPx   := close + calSL * atrV
    if not inLong and not inShort
        entryPx := na
        tgtPx   := na
        stpPx   := na

float conviction = math.abs(committee)

// ───────────────────────── CALIBRATION · R-EXPECTANCY (triple-barrier) ───────
// Each signal gets a profit target, a stop (= 1R), and a time limit. Whichever
// is hit first sets the outcome in R units. EXPECTANCY = average R. This is the
// tradeable metric — direction hit-rate is not. bucket 0 = Trend, 1 = Revert.
f_barrier(float p0, float a0, int dir, float hi, float lo, float cl, int age, int maxb, float tp, float sl) =>
    float risk = sl * a0
    float R = na
    bool done = false
    if age >= 1 and risk > 0
        if dir == 1
            float tpL = p0 + tp * a0
            float slL = p0 - risk
            if lo <= slL
                R := -1.0
                done := true
            else if hi >= tpL
                R := tp / sl
                done := true
            else if age >= maxb
                R := (cl - p0) / risk
                done := true
        else
            float tpL = p0 - tp * a0
            float slL = p0 + risk
            if hi >= slL
                R := -1.0
                done := true
            else if lo <= tpL
                R := tp / sl
                done := true
            else if age >= maxb
                R := (p0 - cl) / risk
                done := true
    [done, R]

var float[] sN    = array.new_float(2, 0.0)   // signal count
var float[] sWin  = array.new_float(2, 0.0)   // wins (R>0)
var float[] sSumR = array.new_float(2, 0.0)   // sum of R
var float[] sUp   = array.new_float(2, 0.0)   // long signals
var float[] sDn   = array.new_float(2, 0.0)   // short signals
var float[] blN   = array.new_float(2, 0.0)   // base-long count / sumR
var float[] blSum = array.new_float(2, 0.0)
var float[] bsN   = array.new_float(2, 0.0)   // base-short count / sumR
var float[] bsSum = array.new_float(2, 0.0)
var int[]   pgBar = array.new_int(0)
var float[] pgPx  = array.new_float(0)
var float[] pgAtr = array.new_float(0)
var int[]   pgDir = array.new_int(0)
var int[]   pgBkt = array.new_int(0)
var int[]   qlBar = array.new_int(0)
var float[] qlPx  = array.new_float(0)
var float[] qlAtr = array.new_float(0)
var int[]   qlBkt = array.new_int(0)
var int[]   qsBar = array.new_int(0)
var float[] qsPx  = array.new_float(0)
var float[] qsAtr = array.new_float(0)
var int[]   qsBkt = array.new_int(0)

if calEnable and barstate.isconfirmed and not na(atrV) and atrV > 0
    int fireBkt = Hval >= 0.5 ? 0 : 1
    if entLong
        array.push(pgBar, bar_index)
        array.push(pgPx, close)
        array.push(pgAtr, atrV)
        array.push(pgDir, 1)
        array.push(pgBkt, fireBkt)
    if entShort
        array.push(pgBar, bar_index)
        array.push(pgPx, close)
        array.push(pgAtr, atrV)
        array.push(pgDir, -1)
        array.push(pgBkt, fireBkt)
    // unconditional base samples (one long, one short every bar)
    array.push(qlBar, bar_index)
    array.push(qlPx, close)
    array.push(qlAtr, atrV)
    array.push(qlBkt, fireBkt)
    array.push(qsBar, bar_index)
    array.push(qsPx, close)
    array.push(qsAtr, atrV)
    array.push(qsBkt, fireBkt)

    // resolve pending signals
    if array.size(pgBar) > 0
        int i = 0
        while i < array.size(pgBar)
            int age = bar_index - array.get(pgBar, i)
            [done, R] = f_barrier(array.get(pgPx, i), array.get(pgAtr, i), array.get(pgDir, i), high, low, close, age, calMaxBars, calTP, calSL)
            if done
                int bk = array.get(pgBkt, i)
                array.set(sN, bk, array.get(sN, bk) + 1)
                array.set(sSumR, bk, array.get(sSumR, bk) + R)
                if R > 0
                    array.set(sWin, bk, array.get(sWin, bk) + 1)
                if array.get(pgDir, i) == 1
                    array.set(sUp, bk, array.get(sUp, bk) + 1)
                else
                    array.set(sDn, bk, array.get(sDn, bk) + 1)
                array.remove(pgBar, i)
                array.remove(pgPx, i)
                array.remove(pgAtr, i)
                array.remove(pgDir, i)
                array.remove(pgBkt, i)
            else
                i += 1
    // resolve base-long
    if array.size(qlBar) > 0
        int i = 0
        while i < array.size(qlBar)
            int age = bar_index - array.get(qlBar, i)
            [done, R] = f_barrier(array.get(qlPx, i), array.get(qlAtr, i), 1, high, low, close, age, calMaxBars, calTP, calSL)
            if done
                int bk = array.get(qlBkt, i)
                array.set(blN, bk, array.get(blN, bk) + 1)
                array.set(blSum, bk, array.get(blSum, bk) + R)
                array.remove(qlBar, i)
                array.remove(qlPx, i)
                array.remove(qlAtr, i)
                array.remove(qlBkt, i)
            else
                i += 1
    // resolve base-short
    if array.size(qsBar) > 0
        int i = 0
        while i < array.size(qsBar)
            int age = bar_index - array.get(qsBar, i)
            [done, R] = f_barrier(array.get(qsPx, i), array.get(qsAtr, i), -1, high, low, close, age, calMaxBars, calTP, calSL)
            if done
                int bk = array.get(qsBkt, i)
                array.set(bsN, bk, array.get(bsN, bk) + 1)
                array.set(bsSum, bk, array.get(bsSum, bk) + R)
                array.remove(qsBar, i)
                array.remove(qsPx, i)
                array.remove(qsAtr, i)
                array.remove(qsBkt, i)
            else
                i += 1
    // bound memory
    while array.size(pgBar) > 400
        array.shift(pgBar)
        array.shift(pgPx)
        array.shift(pgAtr)
        array.shift(pgDir)
        array.shift(pgBkt)
    while array.size(qlBar) > 400
        array.shift(qlBar)
        array.shift(qlPx)
        array.shift(qlAtr)
        array.shift(qlBkt)
    while array.size(qsBar) > 400
        array.shift(qsBar)
        array.shift(qsPx)
        array.shift(qsAtr)
        array.shift(qsBkt)

// ───────────────────────── NET-OF-COST EXPECTANCY (All buckets, for export) ──
// ExpR minus the round-trip cost in R. Descriptive read of the past, cost-aware.
float calAllN    = array.get(sN, 0) + array.get(sN, 1)
float calAllSumR = array.get(sSumR, 0) + array.get(sSumR, 1)
float expRAll    = calAllN > 0 ? calAllSumR / calAllN : na
float netRAll    = na(expRAll) ? na : expRAll - costR

// ───────────────────────── PLOTS (price overlay) ────────────────────────────
// On the price chart: ▲ below a bar = long signal, ▼ above = short, ✕ = exit.
// While a trade is live, its entry / target / stop levels are drawn. A shaded
// background means the engine is standing aside (tape unpredictable) — no trade.
plotshape(showTrades and entLong,  "Long signal",  style = shape.triangleup,   location = location.belowbar, color = COL_BULL, size = size.small)
plotshape(showTrades and entShort, "Short signal", style = shape.triangledown, location = location.abovebar, color = COL_BEAR, size = size.small)
plotshape(showTrades and exitSig,  "Exit",         style = shape.xcross,       location = location.abovebar, color = color.new(COL_MID, 0), size = size.tiny)

bool inTrade = inLong or inShort
plot(showLevels and inTrade ? entryPx : na, "Entry level",  color = color.new(COL_INFO, 0),  linewidth = 1, style = plot.style_linebr)
plot(showLevels and inTrade ? tgtPx   : na, "Target level", color = color.new(COL_BULL, 0),  linewidth = 1, style = plot.style_linebr)
plot(showLevels and inTrade ? stpPx   : na, "Stop level",   color = color.new(COL_BEAR, 0),  linewidth = 1, style = plot.style_linebr)

barcolor(colorBars ? (not gateOpen ? na : committee >= entryThr ? COL_BULL : committee <= -entryThr ? COL_BEAR : na) : na, title = "Bias bar-color")
bgcolor(not gateOpen ? color.new(#7a828c, 90) : na, title = "Stand aside (unpredictable)")
bgcolor(shifted ? color.new(COL_MID, 90) : na, title = "Distribution shifting")

// ───────────────────────── DASHBOARD (adaptive) ─────────────────────────────
f_regTxt(float h) =>
    h > hTrendCut ? "TREND memory" : h < hRevertCut ? "REVERT memory" : "RANDOM walk"
f_regCol(float h) =>
    h > hTrendCut ? COL_BULL : h < hRevertCut ? COL_BEAR : dimCol

f_action(bool gate, bool sh, float com, float thr) =>
    string t = ""
    color  c = na
    if not gate
        t := "STAND ASIDE  ·  market unpredictable"
        c := color.new(#9aa0aa, 0)
    else if sh
        t := "CAUTION  ·  distribution shifting"
        c := COL_MID
    else if com >= thr
        t := "LONG  ·  committee agrees"
        c := COL_BULL
    else if com <= -thr
        t := "SHORT  ·  committee agrees"
        c := COL_BEAR
    else
        t := "WAIT  ·  no consensus yet"
        c := dimCol
    [t, c]

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, 10, border_width = 1, frame_color = frameCl, frame_width = 1)
    [actTxt, actCol] = f_action(gateOpen, shifted, committee, entryThr)
    string biasTxt = (gateOpen and committee >= entryThr) ? "LONG" : (gateOpen and committee <= -entryThr) ? "SHORT" : "WAIT"
    color  biasCol = biasTxt == "LONG" ? COL_BULL : biasTxt == "SHORT" ? COL_BEAR : dimCol
    string topTxt  = topExpert >= 0 ? array.get(enames, topExpert) + "  " + str.tostring(math.round(array.get(w, topExpert) * 100)) + "%" : "—"

    bool ablFull = ablGate and ablRoute and ablHedge
    table.cell(dash, 0, 0, "PREDICTABILITY ROUTER", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(dash, 1, 0, ablFull ? (gateOpen ? "LIVE" : "IDLE") : "◆ ABLATION", text_color = ablFull ? color.new(color.white, 10) : COL_MID, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))

    table.cell(dash, 0, 1, "ACTION", text_color = f_txtOn(actCol), text_size = size.small, bgcolor = color.new(actCol, 8))
    table.cell(dash, 1, 1, actTxt,   text_color = f_txtOn(actCol), text_size = size.small, bgcolor = color.new(actCol, 8))

    table.cell(dash, 0, 2, "Bias", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 2, biasTxt + "   " + str.tostring(math.round(conviction * 100)) + "% conv", text_color = biasCol, text_size = size.tiny, bgcolor = zebraA)

    table.cell(dash, 0, 3, "Predictability", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 3, f_meter(predictability) + " rank " + str.tostring(math.round(predRank)), text_color = gateOpen ? COL_BULL : dimCol, text_size = size.tiny, bgcolor = zebraB)

    table.cell(dash, 0, 4, "Gate open", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 4, (gateOpen ? "● now  " : "○ idle  ") + str.tostring(math.round(gateFrac * 100)) + "% of bars", text_color = gateOpen ? COL_BULL : dimCol, text_size = size.tiny, bgcolor = zebraA)

    table.cell(dash, 0, 5, "Market mode", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 5, f_regTxt(Hval) + "  (H=" + str.tostring(Hval, "#.##") + ")", text_color = f_regCol(Hval), text_size = size.tiny, bgcolor = zebraB)

    table.cell(dash, 0, 6, "Net signal", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 6, (committee >= 0 ? "+" : "") + str.tostring(committee, "#.##"), text_color = committee > 0 ? COL_BULL : committee < 0 ? COL_BEAR : dimCol, text_size = size.tiny, bgcolor = zebraA)

    table.cell(dash, 0, 7, "Driven by", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 7, topTxt, text_color = COL_INFO, text_size = size.tiny, bgcolor = zebraB)

    table.cell(dash, 0, 8, "Conditions", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 8, shifted ? "shifting" : "stable", text_color = shifted ? COL_MID : dimCol, text_size = size.tiny, bgcolor = zebraA)

    table.cell(dash, 0, 9, "What to do", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 9, not gateOpen ? "no trade" : committee >= entryThr ? "follow long" : committee <= -entryThr ? "follow short" : "wait for consensus", text_color = f_regCol(Hval), text_size = size.tiny, bgcolor = zebraB)

// ───────────────────────── KEY-INFO PANEL ───────────────────────────────────
var table keyT = na
if showKey and barstate.islast
    if na(keyT)
        keyT := table.new(f_pos(keyPos), 2, 9, border_width = 1, frame_color = frameCl, frame_width = 1)
    int nAct = 0
    for i = 0 to NE - 1
        if array.get(eact, i)
            nAct += 1
    table.cell(keyT, 0, 0, "KEY INFO", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_left)
    table.cell(keyT, 1, 0, syminfo.ticker, text_color = color.new(color.white, 10), text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_right)
    table.cell(keyT, 0, 1, "Timeframe", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 1, timeframe.period, text_color = txtCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 0, 2, "Entropy (norm)", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 2, str.tostring(peH, "#.##"), text_color = txtCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 0, 3, "Structure |H-.5|", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 3, str.tostring(hStruct, "#.##"), text_color = hStruct > 0.4 ? COL_BULL : dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 0, 4, "Hurst", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 4, str.tostring(Hval, "#.##"), text_color = txtCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 0, 5, "Shift score", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 5, str.tostring(shiftScore, "#.##"), text_color = shifted ? COL_MID : txtCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 0, 6, "Learning rate η", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 6, str.tostring(eta, "#.##"), text_color = txtCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 0, 7, "Experts active", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 7, str.tostring(nAct), text_color = txtCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 0, 8, "Order-flow src", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 8, deltaMode, text_color = ltfOk ? COL_BULL : COL_MID, text_size = size.tiny, bgcolor = zebraB)

// ───────────────────────── CALIBRATION PANEL (R-expectancy) ──────────────────
var table calT = na
if calEnable and calShowPanel and barstate.islast
    if na(calT)
        calT := table.new(f_pos(calPanelPos), 6, 5, border_width = 1, frame_color = frameCl, frame_width = 1)
    string tip = "Past-only, descriptive — NOT a backtest. Each signal exits at whichever comes first: +" + str.tostring(calTP) + "×ATR target, −" + str.tostring(calSL) + "×ATR stop (=1R), or a " + str.tostring(calMaxBars) + "-bar time limit. ExpR = average R per signal (positive = profitable BEFORE costs). NetR = ExpR − round-trip cost (" + str.tostring(costR, "#.##") + "R) — profitable AFTER costs when > 0. EdgeR = ExpR minus a direction-matched unconditional baseline in the same regime. Win = share of signals with R>0."
    table.cell(calT, 0, 0, "R-expectancy (past)", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_left, tooltip = tip)
    table.cell(calT, 1, 0, "N",     text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 2, 0, "Win",   text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 3, 0, "ExpR",  text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 4, 0, "EdgeR", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 5, 0, "NetR", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_right)
    for r = 0 to 2
        float n    = 0.0
        float win  = 0.0
        float sumR = 0.0
        float up   = 0.0
        float dn   = 0.0
        float bln  = 0.0
        float bls  = 0.0
        float bsn  = 0.0
        float bss  = 0.0
        if r < 2
            n    := array.get(sN, r)
            win  := array.get(sWin, r)
            sumR := array.get(sSumR, r)
            up   := array.get(sUp, r)
            dn   := array.get(sDn, r)
            bln  := array.get(blN, r)
            bls  := array.get(blSum, r)
            bsn  := array.get(bsN, r)
            bss  := array.get(bsSum, r)
        else
            n    := array.get(sN, 0) + array.get(sN, 1)
            win  := array.get(sWin, 0) + array.get(sWin, 1)
            sumR := array.get(sSumR, 0) + array.get(sSumR, 1)
            up   := array.get(sUp, 0) + array.get(sUp, 1)
            dn   := array.get(sDn, 0) + array.get(sDn, 1)
            bln  := array.get(blN, 0) + array.get(blN, 1)
            bls  := array.get(blSum, 0) + array.get(blSum, 1)
            bsn  := array.get(bsN, 0) + array.get(bsN, 1)
            bss  := array.get(bsSum, 0) + array.get(bsSum, 1)
        float expR  = n > 0 ? sumR / n : na
        float winR  = n > 0 ? win / n : na
        float blE   = bln > 0 ? bls / bln : na
        float bsE   = bsn > 0 ? bss / bsn : na
        float mBase = ((up + dn) > 0 and not na(blE) and not na(bsE)) ? (up * blE + dn * bsE) / (up + dn) : na
        float edgeR = (na(expR) or na(mBase)) ? na : expR - mBase
        string lbl  = r == 0 ? "Trend" : r == 1 ? "Revert" : "All"
        string nTxt = str.tostring(int(n))
        string wTxt = n < 5 ? "warm" : str.tostring(math.round(winR * 100)) + "%"
        string eTxt = (na(expR) or n < 5) ? "—" : (expR >= 0 ? "+" : "") + str.tostring(expR, "#.##")
        string dTxt = (na(edgeR) or n < 5) ? "—" : (edgeR >= 0 ? "+" : "") + str.tostring(edgeR, "#.##")
        color eCol  = na(expR) ? dimCol : expR > 0 ? COL_BULL : expR < 0 ? COL_BEAR : COL_MID
        color dCol  = na(edgeR) ? dimCol : edgeR > 0 ? COL_BULL : edgeR < 0 ? COL_BEAR : COL_MID
        float netR  = na(expR) ? na : expR - costR
        string ntTxt = (na(netR) or n < 5) ? "—" : (netR >= 0 ? "+" : "") + str.tostring(netR, "#.##")
        color ntCol  = na(netR) ? dimCol : netR > 0 ? COL_BULL : netR < 0 ? COL_BEAR : COL_MID
        color rbg   = r % 2 == 0 ? zebraA : zebraB
        table.cell(calT, 0, r + 1, lbl,  text_color = dimCol, text_size = size.tiny, bgcolor = rbg, text_halign = text.align_left)
        table.cell(calT, 1, r + 1, nTxt, text_color = txtCol, text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 2, r + 1, wTxt, text_color = n < 5 ? dimCol : txtCol, text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 3, r + 1, eTxt, text_color = eCol, text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 4, r + 1, dTxt, text_color = dCol, text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 5, r + 1, ntTxt, text_color = ntCol, text_size = size.tiny, bgcolor = rbg, text_halign = text.align_right)
    int pend = array.size(pgBar)
    table.cell(calT, 0, 4, pend > 0 ? str.tostring(pend) + " open · NetR>0 = profitable after cost" : "NetR = ExpR − " + str.tostring(costR, "#.##") + "R cost", text_color = dimCol, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_left)
    table.cell(calT, 1, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 2, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 3, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 4, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 5, 4, "", bgcolor = color.new(COL_INFO, 10))

// ───────────────────────── EXPORTED OUTPUTS ─────────────────────────────────
plot(committee * 10.0,     "EXP_BiasScore",      display = display.data_window)
plot(committee,            "EXP_CommitteeVote",  display = display.data_window)
plot(predictability,       "EXP_PredictabilityLevel",  display = display.data_window)
plot(Hval,                 "EXP_Hurst",           display = display.data_window)
plot(peH,                  "EXP_Entropy",         display = display.data_window)
plot(gateOpen ? 1 : 0,     "EXP_GateOpen",       display = display.data_window)
plot(predRank,             "EXP_PredictRank",    display = display.data_window)
plot(gateFrac * 100,       "EXP_GateOpenPct",   display = display.data_window)
plot(shifted ? 1 : 0,      "EXP_ShiftFlag",      display = display.data_window)
plot(topExpert,            "EXP_LeadExpertId",  display = display.data_window)
plot(expRAll,              "EXP_ExpR",          display = display.data_window)
plot(netRAll,              "EXP_NetR",          display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(entLong,  "Long signal",  "P-Router: long — predictable, committee agrees")
alertcondition(entShort, "Short signal", "P-Router: short — predictable, committee agrees")
alertcondition(exitSig,  "Exit",         "P-Router: exit / consensus lost")
````
