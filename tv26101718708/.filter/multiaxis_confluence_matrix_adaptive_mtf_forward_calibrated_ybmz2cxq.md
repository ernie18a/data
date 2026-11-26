# Multi-Axis Confluence Matrix  Adaptive MTF & Forward Calibrated

- url: https://www.tradingview.com/script/YBMZ2CxQ-Multi-Axis-Confluence-Matrix-Adaptive-MTF-Forward-Calibrated/
- type: indicator
- pine_id: PUB;39406186647f41cc9004cdd2f480f44b
- version: 2.0

## Description

Multi-Axis Confluence Matrix — Adaptive MTF & Forward-Calibrated

What it is

A confluence oscillator that scores agreement across five independent information axes, each measured on three adaptively-resolved timeframes, then weights every axis by its own forward-measured edge on the current symbol so the score self-corrects instead of treating all inputs as equally reliable. It separates the two kinds of multi-timeframe agreement that most stacks wrongly merge, gates direction with a higher-timeframe bias, and reports the whole state in one plain-language verdict panel.

The plotted line reads like a conventional oscillator (−100 to +100, with strong-zone bands and price-chart BUY/SELL signals), so a non-technical user can interpret it at a glance — while the engine underneath is doing edge-weighted, multi-timeframe, forward-calibrated confluence.


Why these components are combined (mashup rationale)

Stacking indicators usually produces false confluence: five momentum tools in different clothes vote the same bet five times, and it looks like five confirmations when it is really one. This script is built specifically to avoid that, and every layer removes a distinct failure of naive stacking. They ship as one engine because direction, certainty, and agreement are one decision — splitting them across separate scripts would lose the cross-checks below.

1. Five orthogonal axes, each from a different data source. Agreement only carries information if the axes are independent. Each axis reads a different thing:


Momentum — price (normalized MACD-histogram sign)
Stretch — price vs an adaptive fair value (z-score of the deviation)
Order flow — signed volume (sign of a bounded cumulative volume-delta z-score)
Fear — an implied-volatility index (direction of a negated IV trend)
Cross-market — a correlated leader instrument (signed momentum), off by default


Because no two axes share an input, four of them agreeing is four independent witnesses, not one witness repeated.

2. Vote / gate split. Directional axes vote long or short. Context does not vote — it scales conviction or vetoes. A volatility-regime measure and a trend-efficiency measure only shrink conviction; the higher-timeframe bias only decides which side is allowed. High volatility is neither bullish nor bearish, so folding it into the direction sum would inject bias. Keeping context as a multiplier rather than an addend is the single thing that stops the stack collapsing into "momentum with extra steps."

3. Two separate confluence counts, never summed.


Method confluence = how many independent axes agree on the signal timeframe (the rare, high-information agreement).
Scale confluence = how many timeframes one axis agrees on (robustness/timing only — the same signal at different resolutions, not a new vote).


Merging them lets three timeframes of one axis drown out a contradicting axis. They are reported on separate rows so you can see which kind of agreement you actually have.

4. Adaptive multi-timeframe resolution. The bias / signal / trigger timeframes are derived as multiples of the chart timeframe, clamped and snapped to real frames. The "bias-above, vote-between, trigger-at" relationship is preserved on any chart, instead of fixed frames that are only correct on the one chart they were tuned for.

5. Per-axis forward calibration (the core original component). Each axis is calibrated on each timeframe by a triple-barrier outcome (profit barrier / stop barrier / time horizon), with sample-uniqueness weighting and recency decay, reported as an edge over a barrier-matched base rate with a Wilson confidence interval. Each axis then votes weighted by its own edge lower-bound, so an axis that is not paying on the current symbol contributes little and cannot bias the score merely by being present. A small weight floor keeps the engine responsive (edge tilts the score rather than fully gating it); set the floor to zero for strict gating.

6. Higher-timeframe bias gate. The slow frame sets which side is allowed and does not vote, which blocks the counter-trend entries that punish mean-reversion approaches.

Remove any one layer and the stack loses a check it cannot recover. That is the justification for combining them.


How to use it


The line lives in −100..+100. In the green zone = strong bullish confluence; red zone = strong bearish; mid = no edge. Read it like any oscillator.
BUY / SELL triangles print on the price chart only when the gated, edge-weighted verdict fires (method confluence + conviction + bias gate all pass). Triangles with text = high conviction; without text = weaker. A latch + cooldown gives one clean mark per swing, not a cluster.
Bull / Bear divergence is drawn on the score line, spaced by a cooldown, and suppressed only when it directly contradicts a high-conviction opposite verdict (early-reversal divergences against a weak score are kept).
The verdict panel (top-right, on by default) states the action in plain language: tier, what to do, method/scale confluence, conviction, calibration warm-state, and which side the higher-TF bias allows.
The axis × timeframe matrix is an advanced view, off by default — turn it on to inspect each axis's arrows across timeframes and its measured edge. A Key-info table (Compact by default, Pro for full detail) summarizes the live state on the left.


Any market: the price source, volume source (with a borrow-symbol option for instruments that report no volume), the implied-volatility symbol, and the cross-market leader are all inputs in the settings. Defaults suit a major index future; change the symbols for any market, or clear the fear / cross-market symbols to drop those axes (the score re-weights over the axes that remain).


What makes it original

The multi-axis matrix, the vote/gate split, the dual (method vs scale) confluence accounting, the adaptive timeframe resolution, and the per-axis-per-timeframe forward edge-weighting are this script's own construction. It is not a re-skin of a single classic indicator — it is an engine for organizing several independent reads into one honest, self-correcting confluence score.


Outputs (Data Window)

Generic, identifiable names for use by other scripts: direction, conviction, method confluence, scale confluence, higher-TF bias, regime direction, edge, edge lower-bound, and sample count.


Non-repainting

Every off-chart-timeframe read uses confirmed previous bars with lookahead disabled; votes confirm on bar close; every calibrated statistic is forward-measured at fixed barriers on confirmed bars. The live bar is provisional, as with any indicator.


Concept credits (techniques operationalized here — not third-party code)

MACD: Gerald Appel. Bands / %B style stretch: John Bollinger. Cumulative volume delta and divergence: standard order-flow practice. Implied-volatility index methodology: CBOE. Trade-side from standardized returns (Bulk Volume Classification): Easley, López de Prado & O'Hara. Triple-barrier labeling and sample uniqueness: López de Prado. Wilson score interval: Edwin B. Wilson. Efficiency-ratio regime: Perry Kaufman. The matrix architecture and the calibration/weighting scheme are the author's own.


Disclaimer

Research and education only. This is not financial advice, not a recommendation, and not a guarantee. The axes are deliberately compact reads of their concepts. Calibration is in-sample, forward-measured at fixed barriers, with no costs, slippage, or guaranteed fills. Indicators describe past behavior; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ═════════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                                  MPL-2.0
//  MULTI-AXIS CONFLUENCE MATRIX — Adaptive MTF & Forward-Calibrated
//  shorttitle: Confluence Matrix
// ─────────────────────────────────────────────────────────────────────────────
//  v1.1 — Correctness + licence pass:
//    • Fixed a conditional ta.atr on the fear axis (it sat inside a `not na(...) ?` branch, so it
//      was skipped when the implied-volatility symbol returned no data — CW10004). Now runs every
//      bar; output unchanged when the fear symbol is present.
//    • Hoisted the score-line smoothing ta.ema out of its constant `smoothing>1 ?` guard (benign,
//      clears the warning). Added the MPL-2.0 licence header.
//    • Axes remain self-contained compact reads by DESIGN — each is evaluated on multiple
//      timeframes via request.security, which an external input.source() cannot be. The engine's own
//      EXP_ bus (EXP_Dir, EXP_Conviction, …) is already standardized and unchanged.
// ─────────────────────────────────────────────────────────────────────────────
//  WHAT IT IS
//    A confluence engine that scores agreement across FIVE independent information
//    axes (momentum, stretch, order flow, fear, cross-market) measured on THREE
//    adaptively-resolved timeframes, then weights each axis by its OWN forward-
//    measured edge on this symbol so the score self-corrects instead of treating
//    every input as equally trustworthy. It separates the two kinds of agreement
//    that most stacks wrongly merge, gates direction with a higher-timeframe bias,
//    and reports the whole state in one plain-language verdict.
//
//  WHY THESE PARTS ARE COMBINED  (mashup rationale — read before publishing)
//    Stacking indicators usually produces FALSE confluence: five momentum tools in
//    different clothes vote the same bet five times. This engine is built to avoid
//    exactly that, and each layer removes a specific failure of naive stacking:
//      • FIVE ORTHOGONAL AXES, each from a DIFFERENT data source (price momentum,
//        price-vs-fair-value stretch, signed volume/flow, an implied-volatility
//        fear gauge, a correlated leader symbol). Agreement means something only
//        because no two axes share an input — they are independent witnesses.
//      • VOTE vs GATE SPLIT. Directional axes vote long/short. CONTEXT axes
//        (volatility regime, trend-efficiency) never vote — they SCALE conviction
//        or VETO. High volatility is not bullish or bearish; folding it into the
//        direction sum is how stacks acquire hidden bias, so it is kept out.
//      • TWO SEPARATE CONFLUENCE COUNTS. Method-confluence = how many independent
//        axes agree on the signal timeframe (the real, rare, high-information
//        agreement). Scale-confluence = how many timeframes one axis agrees on
//        (robustness/timing only — the SAME signal at different resolutions, NOT a
//        new vote). Merging them lets three timeframes of one axis drown out a
//        contradicting axis; they are reported on separate ledgers.
//      • ADAPTIVE MTF. The bias / signal / trigger timeframes are derived as
//        multiples of the chart timeframe (clamped and snapped to real frames), so
//        the bias-above / vote-between / trigger-at relationship is preserved on
//        any chart, instead of fixed frames that are wrong off their tuned chart.
//      • PER-CELL FORWARD CALIBRATION. Each axis is calibrated on each timeframe by
//        a triple-barrier outcome (profit/stop/horizon), uniqueness-weighted,
//        recency-decayed, reported as an edge over a base rate with a Wilson
//        interval. Each axis votes weighted by its OWN edge lower-bound on the
//        frame it votes on, so an axis that is not paying here contributes ~0 and
//        cannot bias the score by sheer presence.
//      • HIGHER-TF BIAS GATE. The slow frame sets which side is allowed; it does
//        not vote. This blocks the counter-trend entries that punish reversion.
//    Remove any layer and the stack loses a check it cannot recover; they ship as
//    one engine because direction, certainty and agreement are one decision.
//
//  COMPACT AXES (honest scope)
//    To evaluate every axis on every timeframe within one script, each axis is a
//    COMPACT read of its concept, not the full standalone indicator: momentum = a
//    normalized MACD histogram sign; stretch = z-score of price minus an adaptive
//    fair value; flow = sign of a bounded cumulative signed-volume z; fear =
//    direction of a negated implied-vol series; cross-market = momentum sign of a
//    leader symbol. These are deliberately orthogonal one-line reads; the full
//    family scripts remain the deep tools.
//
//  DATA / ANY MARKET
//    Price source, volume source (with borrow symbol for no-volume instruments),
//    the implied-vol symbol and the leader symbol are all inputs. Defaults target
//    index futures with an implied-volatility index and a correlated leader.
//    Change them for any market;
//    clear the fear / leader symbols to drop those axes (the score re-weights).
//
//  EXPORTS (Data Window · generic names for cross-script consumption)
//    EXP_Dir, EXP_Conviction, EXP_Method, EXP_Scale, EXP_Bias, EXP_Regime,
//    EXP_Edge, EXP_EdgeLB, EXP_N
//
//  NON-REPAINT
//    Every off-chart-timeframe read uses lookahead_off and the previous confirmed
//    bar; votes confirm on bar close; every calibrated statistic resolves on
//    confirmed bars, forward-measured at fixed barriers. The live bar is provisional.
//
//  CONCEPT CREDITS (techniques operationalised here — not third-party code)
//    MACD: Gerald Appel. %B / band stretch: John Bollinger. Cumulative volume delta
//    & divergence: standard order-flow practice. Implied-volatility index: CBOE
//    methodology. Trade-side from standardized returns (Bulk Volume Classification):
//    Easley, López de Prado & O'Hara. Triple-barrier labelling & sample uniqueness:
//    López de Prado. Wilson score interval: Edwin B. Wilson. Efficiency-ratio
//    regime: Perry Kaufman. The multi-axis matrix, the vote/gate split, the dual
//    confluence accounting and the per-cell edge weighting are this script's own.
//
//  DISCLAIMER
//    Research / education only. NOT financial advice, NOT a recommendation, NOT a
//    guarantee. Compact axes are simplified reads; calibration is in-sample,
//    forward-measured at fixed barriers, with no costs / slippage / stops.
//    Indicators describe past behaviour; they do not predict the future. Trading
//    carries risk of loss. Test out-of-sample and make your own decisions.
// ═════════════════════════════════════════════════════════════════════════════
indicator("Multi-Axis Confluence Matrix — Adaptive MTF & Forward-Calibrated", "MACM", overlay = false,
     max_lines_count = 100, max_labels_count = 100, dynamic_requests = true)

// ═════════════════════════════════════════════════════════════════════════════
// 01 · DATA SOURCE
// ═════════════════════════════════════════════════════════════════════════════
g1 = "01 · Data Source"
srcPrice = input.source(close, "Price source", group = g1, display = display.none, tooltip = "Series every price-based axis is built from. Default close; runs on any symbol/timeframe.")
volSrc   = input.source(volume, "Volume source", group = g1, display = display.none, tooltip = "Volume for the order-flow axis. Use the borrow symbol below for instruments that report none.")
volBorrowSym = input.symbol("", "Borrow volume from symbol", group = g1, display = display.none, tooltip = "Supplies volume where the chart symbol reports none (e.g. an index). Blank = use the volume source.")
volSym   = input.symbol("NSE:INDIAVIX", "Implied-volatility (fear) symbol", group = g1, display = display.none, tooltip = "Fear axis gauge — an implied-volatility index for your market (e.g. a VIX-type index). Default suits index futures. Clear to drop the fear axis.")
leadSym  = input.symbol("TVC:DXY", "Cross-market 1 (leader)", group = g1, display = display.none, tooltip = "Cross-market sub-symbol 1: a correlated instrument that tends to lead your symbol. Set its correlation sign below (-1 if inversely correlated). Clear all three to drop the axis.")
leadSym2 = input.symbol("", "Cross-market 2", group = g1, display = display.none, tooltip = "Optional second correlated instrument (blank by default). Add only if it improves results on your symbol.")
leadSym3 = input.symbol("", "Cross-market 3", group = g1, display = display.none, tooltip = "Optional third correlated instrument (blank by default). Add with a low weight and verify it improves results before trusting it.")
xSign1   = input.int(-1, "  CM1 correlation sign", options = [1, -1], group = g1, display = display.none, tooltip = "+1 if the instrument moves WITH your symbol, -1 if it moves INVERSELY. Default -1 suits an inverse leader.")
xSign2   = input.int(1,  "  CM2 correlation sign", options = [1, -1], group = g1, display = display.none)
xSign3   = input.int(1,  "  CM3 correlation sign", options = [1, -1], group = g1, display = display.none)
xW1      = input.float(1.0, "  CM1 weight", minval = 0.0, maxval = 1.0, step = 0.1, group = g1, display = display.none)
xW2      = input.float(0.0, "  CM2 weight", minval = 0.0, maxval = 1.0, step = 0.1, group = g1, display = display.none)
xW3      = input.float(0.0, "  CM3 weight", minval = 0.0, maxval = 1.0, step = 0.1, group = g1, display = display.none)

// ═════════════════════════════════════════════════════════════════════════════
// 02 · TIMEFRAMES (adaptive: multiples of chart TF, clamped & snapped)
// ═════════════════════════════════════════════════════════════════════════════
g2 = "02 · Timeframes"
tfMode    = input.string("Adaptive (× chart)", "Timeframe mode", options = ["Adaptive (× chart)", "Manual"], group = g2, display = display.none, tooltip = "Adaptive derives bias / signal / trigger as multiples of the chart timeframe, snapped to real frames. Manual uses the three frames below.")
multSignal= input.float(3.0, "Signal TF (× chart)", minval = 1.0, step = 0.5, group = g2, display = display.none, tooltip = "Adaptive: the timeframe where axes vote. ~3× chart.")
multBias  = input.float(5.0, "Bias TF (× chart)", minval = 2.0, step = 1.0, group = g2, display = display.none, tooltip = "Adaptive: the higher timeframe that gates which side is allowed. ~4-8× chart.")
mTrig     = input.timeframe("", "Manual trigger TF", group = g2, display = display.none, tooltip = "Manual mode only. Blank = chart timeframe.")
mSig      = input.timeframe("15", "Manual signal TF", group = g2, display = display.none)
mBias     = input.timeframe("60", "Manual bias TF", group = g2, display = display.none)

// ═════════════════════════════════════════════════════════════════════════════
// 03 · AXES (enable / disable — score re-weights over active axes)
// ═════════════════════════════════════════════════════════════════════════════
g3 = "03 · Axes"
useMom  = input.bool(true, "Momentum axis (price)", group = g3, display = display.none)
useStr  = input.bool(true, "Stretch axis (price vs fair value)", group = g3, display = display.none)
useFlow = input.bool(true, "Order-flow axis (signed volume)", group = g3, display = display.none)
useFear = input.bool(true, "Fear axis (implied volatility)", group = g3, display = display.none)
useXmkt = input.bool(false, "Cross-market axis — off by default", group = g3, display = display.none, tooltip = "Cross-market axis using a correlated leader instrument. Off by default because its intraday edge is often marginal. When ON, it participates fully in the score, confluence count and calibration like any other axis.")

// ═════════════════════════════════════════════════════════════════════════════
// 04 · AXIS PARAMETERS
// ═════════════════════════════════════════════════════════════════════════════
g4 = "04 · Axis Parameters"
macdFast = input.int(12, "Momentum fast", minval = 2, inline = "m", group = g4, display = display.none)
macdSlow = input.int(26, "slow", minval = 4, inline = "m", group = g4, display = display.none)
macdSig  = input.int(9,  "signal", minval = 2, inline = "m", group = g4, display = display.none)
fairLen  = input.int(50, "Stretch fair-value length", minval = 5, group = g4, display = display.none)
strZ     = input.int(100, "Stretch z window", minval = 20, group = g4, display = display.none)
flowLen  = input.int(50, "Flow normalize window", minval = 5, group = g4, display = display.none)
bvcLen   = input.int(20, "Flow fallback window", minval = 5, group = g4, display = display.none)
fearLen  = input.int(20, "Fear trend length", minval = 3, group = g4, display = display.none)
leadLen  = input.int(20, "Leader momentum lookback", minval = 2, group = g4, display = display.none)

// ═════════════════════════════════════════════════════════════════════════════
// 05 · GATES (context: scale conviction / veto — never vote)
// ═════════════════════════════════════════════════════════════════════════════
g5 = "05 · Gates (context)"
useBiasGate = input.bool(true, "Higher-TF bias gate (block counter-bias)", group = g5, display = display.none, tooltip = "The bias timeframe sets which side is allowed. It does not add to the score.")
useVolGate  = input.bool(true, "Volatility regime scales conviction", group = g5, display = display.none, tooltip = "High realized-volatility regimes shrink conviction. Volatility never votes on direction.")
volGateLen  = input.int(100, "Volatility regime window", minval = 20, group = g5, display = display.none)
useEffGate  = input.bool(true, "Trend-efficiency scales conviction", group = g5, display = display.none, tooltip = "Low trend-efficiency (chop) shrinks conviction.")
erLen       = input.int(20, "Efficiency window", minval = 3, group = g5, display = display.none)

// ═════════════════════════════════════════════════════════════════════════════
// 06 · CALIBRATION (triple-barrier, per axis × signal-TF)
// ═════════════════════════════════════════════════════════════════════════════
g6 = "06 · Calibration"
useCalib   = input.bool(true, "Weight axes by forward edge (edge lower-bound)", group = g6, display = display.none, tooltip = "Each axis votes weighted by its OWN forward-measured edge lower-bound. An axis not paying here contributes ~0. Off = equal weights.")
atrLen     = input.int(14, "ATR length", minval = 4, group = g6, display = display.none)
calHorizon = input.int(20, "Horizon (bars)", minval = 3, maxval = 100, group = g6, display = display.none)
calMoveATR = input.float(1.0, "Profit barrier (× ATR)", minval = 0.2, step = 0.1, group = g6, display = display.none)
calStopATR = input.float(1.0, "Stop barrier (× ATR)", minval = 0.2, step = 0.1, group = g6, display = display.none)
calMinSamp = input.int(8, "Min samples to trust", minval = 3, maxval = 50, group = g6, display = display.none)
calMinGap  = input.int(5, "Min bars between samples", minval = 1, group = g6, display = display.none)
calDecay   = input.float(0.99, "Recency decay", minval = 0.80, maxval = 1.0, step = 0.005, group = g6, display = display.none)
wFloor     = input.float(0.10, "Min axis weight (edge tilts, not gates)", minval = 0.0, maxval = 1.0, step = 0.05, group = g6, display = display.none, tooltip = "Every active axis contributes at least this weight, so an axis with weak/negative measured edge is DISCOUNTED rather than silenced. Positive-edge axes still count more. Set to 0 for the strict gate (axes with no proven edge contribute nothing — can make the engine stand aside indefinitely).")

// ═════════════════════════════════════════════════════════════════════════════
// 07 · SCORING
// ═════════════════════════════════════════════════════════════════════════════
g7 = "07 · Scoring"
minConv   = input.int(50, "Min conviction to act", minval = 0, maxval = 100, group = g7, display = display.none)
scoreMode = input.string("Graded (breathing line)", "Score line mode", options = ["Graded (breathing line)", "Binary (votes)"], group = g7, display = display.none, tooltip = "Graded = each axis contributes by STRENGTH, so the line moves smoothly through the middle like a conventional oscillator. Binary = each axis is a +1/-1 vote (cruder square-wave, but literally a confluence counter). Signals, gates and the verdict are IDENTICAL in both — only the plotted line changes.")
minMethod = input.int(2, "Min axes agreeing (method confluence)", minval = 1, maxval = 5, group = g7, display = display.none, tooltip = "How many independent axes must agree on the signal timeframe before a verdict fires.")
scoreSmooth = input.int(4, "Score line smoothing", minval = 1, maxval = 10, group = g7, display = display.none, tooltip = "Light smoothing of the plotted confluence line for a cleaner read. Does not affect signals or the verdict.")
sigCooldown = input.int(15, "Min bars between signals", minval = 0, group = g7, display = display.none, tooltip = "After a BUY/SELL, no new same-direction signal for this many bars. Latch + cooldown together give one clean mark per swing instead of a cluster.")
strongConv  = input.int(70, "Strong-signal conviction", minval = 0, maxval = 100, group = g7, display = display.none, tooltip = "Signals at or above this conviction print large with text; below it print as a small dot — so the eye lands on the high-conviction ones.")
divCooldown = input.int(25, "Min bars between divergence labels", minval = 0, group = g7, display = display.none, tooltip = "Stops the same divergence being re-labelled on every pivot. Keeps all genuine divergences, just one label each.")
divNoFight  = input.bool(true, "Hide divergence against a strong verdict", group = g7, display = display.none, tooltip = "Suppresses a Bull/Bear divergence only when it directly contradicts a HIGH-conviction opposite verdict (just noise there). Early-reversal divergences against a weak/neutral score still show.")
showDiv   = input.bool(true, "Draw divergence on the score line", group = g7, display = display.none, tooltip = "Auto bull/bear divergence between price and the confluence score, with labels — read like any oscillator divergence.")
divPivL   = input.int(5, "Divergence pivot left", minval = 2, inline = "dv", group = g7, display = display.none)
divPivR   = input.int(5, "Divergence pivot right", minval = 1, inline = "dv", group = g7, display = display.none)
divMaxGap = input.int(60, "Max bars between pivots", minval = 5, group = g7, display = display.none)

// ═════════════════════════════════════════════════════════════════════════════
// 08 · VISUALS & TABLES
// ═════════════════════════════════════════════════════════════════════════════
g8 = "08 · Visuals & Tables"
themeOpt   = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = g8, display = display.none, tooltip = "Auto reads the chart background and adapts table colours for contrast.")
showVerdict= input.bool(true, "Show verdict panel (what to do)", group = g8, display = display.none, tooltip = "The at-a-glance panel: tier, action, confluence, conviction and bias. The main read for most users.")
showMatrix = input.bool(false, "Show axis × timeframe matrix (advanced)", group = g8, display = display.none, tooltip = "Per-axis detail: each axis's arrows across timeframes plus its measured edge. Advanced — off by default.")
showKey    = input.bool(true, "Show key-info table", group = g8, display = display.none, tooltip = "A summary table of the live state — direction, conviction, confluence and bias. Compact shows the essentials; Pro adds per-axis detail and calibration state.")
keyMode    = input.string("Compact", "Key-info detail", options = ["Compact", "Pro"], group = g8, display = display.none, tooltip = "Compact = the essentials at a glance (default). Pro = full detail including each axis and calibration warm-state.")
showId     = input.bool(true, "Show name tag", group = g8, display = display.none)
showEXP    = input.bool(true, "Publish data-window outputs", group = g8, display = display.none, tooltip = "Exposes the engine's outputs (direction, conviction, confluence, bias, edge) in the Data Window for use by other scripts.")
bullCol    = input.color(#2ebd85, "Bullish", group = g8, display = display.none)
bearCol    = input.color(#f6465d, "Bearish", group = g8, display = display.none)
midColr    = input.color(#f7c948, "Caution", group = g8, display = display.none)

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS  (pure: args + built-ins only)
// ═════════════════════════════════════════════════════════════════════════════
f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_ci(float w, float n, float zc) =>
    float r = na
    if n > 0.0
        float p = w / n
        float z2 = zc * zc
        r := (zc * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / (1.0 + z2 / n)
    r
f_ncdf(float x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float d = 0.3989422804014327 * math.exp(-x * x / 2.0)
    float p = d * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    x >= 0.0 ? 1.0 - p : p
// snap a minute count to a real TF string
f_tf(float mins) =>
    mins <= 1.5 ? "1" : mins <= 2.5 ? "2" : mins <= 4.0 ? "3" : mins <= 7.5 ? "5" : mins <= 12.5 ? "10" : mins <= 22.5 ? "15" : mins <= 37.5 ? "30" : mins <= 52.5 ? "45" : mins <= 90.0 ? "60" : mins <= 150.0 ? "120" : mins <= 210.0 ? "180" : mins <= 480.0 ? "240" : mins <= 2880.0 ? "D" : "W"

// compact axis reads as UDFs (args + built-ins only) so they are callable in request.security
f_momSign(int fl, int sl, int sg) =>
    float m = ta.ema(close, fl) - ta.ema(close, sl)
    float s = ta.ema(m, sg)
    float h = m - s
    h > 0 ? 1 : h < 0 ? -1 : 0
f_strSign(int fl, int zl) =>
    float fair = ta.ema(close, fl)
    float dev  = close - fair
    float sd   = ta.stdev(dev, zl)
    float z    = sd > 0 ? dev / sd : 0.0
    z > 0 ? 1 : z < 0 ? -1 : 0
f_flowSign(int nl, int bl) =>
    float ret = close - nz(close[1], close)
    float sd  = ta.stdev(close - close[1], bl)
    float zz  = sd > 0 ? ret / sd : 0.0
    float bf  = math.max(0.0, math.min(1.0, f_ncdf(zz)))
    float sv  = nz(volume, 0.0) * (2.0 * bf - 1.0)
    float cvd = ta.cum(sv)
    float resid = cvd - ta.ema(cvd, nl)
    float rsd = ta.stdev(resid, nl)
    float nz_ = rsd > 0 ? resid / rsd : 0.0
    nz_ > 0 ? 1 : nz_ < 0 ? -1 : 0
f_leadSign(int ll) =>
    close > nz(close[ll], close) ? 1 : close < nz(close[ll], close) ? -1 : 0

// graded twins: same internal read, returned as a clamped continuous strength in
// [-1,1] instead of collapsed to a sign. Used only for the plotted score line in
// "Graded" mode, so the line breathes through the middle instead of square-waving.
f_momGr(int fl, int sl, int sg) =>
    float m = ta.ema(close, fl) - ta.ema(close, sl)
    float s = ta.ema(m, sg)
    float h = m - s
    float hs = ta.stdev(h, 100)
    float z = hs > 0 ? h / hs : 0.0
    math.max(-1.0, math.min(1.0, z / 2.0))
f_strGr(int fl, int zl) =>
    float fair = ta.ema(close, fl)
    float dev  = close - fair
    float sd   = ta.stdev(dev, zl)
    float z    = sd > 0 ? dev / sd : 0.0
    math.max(-1.0, math.min(1.0, z / 2.0))
f_flowGr(int nl, int bl) =>
    float ret = close - nz(close[1], close)
    float sd  = ta.stdev(close - close[1], bl)
    float zz  = sd > 0 ? ret / sd : 0.0
    float bf  = math.max(0.0, math.min(1.0, f_ncdf(zz)))
    float sv  = nz(volume, 0.0) * (2.0 * bf - 1.0)
    float cvd = ta.cum(sv)
    float resid = cvd - ta.ema(cvd, nl)
    float rsd = ta.stdev(resid, nl)
    float nz_ = rsd > 0 ? resid / rsd : 0.0
    math.max(-1.0, math.min(1.0, nz_ / 2.0))
f_leadGr(int ll) =>
    float ch = close - nz(close[ll], close)
    float sd = ta.stdev(close - nz(close[ll], close), 100)
    float z = sd > 0 ? ch / sd : 0.0
    math.max(-1.0, math.min(1.0, z / 2.0))

// calibration sample object
type Ev
    int   axis
    int   dir
    float entry
    float atr0
    int   bidx
    float uw
    bool  done

// ═════════════════════════════════════════════════════════════════════════════
// VOLUME (source + optional borrow)  — for native chart-TF use only
// ═════════════════════════════════════════════════════════════════════════════
var bool nativeVolSeen = false
if nz(volSrc, 0) > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowRaw = request.security(volBorrowSym, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// ═════════════════════════════════════════════════════════════════════════════
// TIMEFRAME RESOLUTION (adaptive, clamped, snapped — or manual)
// ═════════════════════════════════════════════════════════════════════════════
float chartMin = timeframe.in_seconds() / 60.0
string trigTF = tfMode == "Manual" ? (str.length(mTrig) > 0 ? mTrig : timeframe.period) : timeframe.period
string sigTF  = tfMode == "Manual" ? mSig  : f_tf(chartMin * multSignal)
string biasTF = tfMode == "Manual" ? mBias : f_tf(chartMin * multBias)

// ═════════════════════════════════════════════════════════════════════════════
// AXIS VOTES PER TIMEFRAME (non-repainting; confirmed previous bar)
//   Each axis is read on trigger / signal / bias frames. Votes are computed
//   unconditionally; selection happens later.
// ═════════════════════════════════════════════════════════════════════════════
int momTrig = nz(request.security(syminfo.tickerid, trigTF, f_momSign(macdFast, macdSlow, macdSig)[1], lookahead = barmerge.lookahead_off))
int momSig  = nz(request.security(syminfo.tickerid, sigTF,  f_momSign(macdFast, macdSlow, macdSig)[1], lookahead = barmerge.lookahead_off))
int momBias = nz(request.security(syminfo.tickerid, biasTF, f_momSign(macdFast, macdSlow, macdSig)[1], lookahead = barmerge.lookahead_off))

int strTrig = nz(request.security(syminfo.tickerid, trigTF, f_strSign(fairLen, strZ)[1], lookahead = barmerge.lookahead_off))
int strSig  = nz(request.security(syminfo.tickerid, sigTF,  f_strSign(fairLen, strZ)[1], lookahead = barmerge.lookahead_off))
int strBias = nz(request.security(syminfo.tickerid, biasTF, f_strSign(fairLen, strZ)[1], lookahead = barmerge.lookahead_off))

int flowTrig = nz(request.security(syminfo.tickerid, trigTF, f_flowSign(flowLen, bvcLen)[1], lookahead = barmerge.lookahead_off))
int flowSig  = nz(request.security(syminfo.tickerid, sigTF,  f_flowSign(flowLen, bvcLen)[1], lookahead = barmerge.lookahead_off))
int flowBias = nz(request.security(syminfo.tickerid, biasTF, f_flowSign(flowLen, bvcLen)[1], lookahead = barmerge.lookahead_off))

// fear axis: negated implied-vol trend (price up while fear up = bearish disagreement)
bool fearOK = str.length(volSym) > 0
float ivTrig = request.security(volSym, trigTF, (close - ta.ema(close, fearLen))[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float ivSig  = request.security(volSym, sigTF,  (close - ta.ema(close, fearLen))[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float ivBias = request.security(volSym, biasTF, (close - ta.ema(close, fearLen))[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
int fearTrig = not na(ivTrig) ? (-ivTrig > 0 ? 1 : -ivTrig < 0 ? -1 : 0) : 0
int fearSig  = not na(ivSig)  ? (-ivSig  > 0 ? 1 : -ivSig  < 0 ? -1 : 0) : 0
int fearBias = not na(ivBias) ? (-ivBias > 0 ? 1 : -ivBias < 0 ? -1 : 0) : 0

// cross-market axis: WEIGHTED AVERAGE of up to three correlated symbols, each
// signed by its correlation to the chart symbol. Collapses to ONE axis vote — the rest of
// the script sees a single Cross-mkt signal exactly as before.
bool xmktOK = str.length(leadSym) > 0 or str.length(leadSym2) > 0 or str.length(leadSym3) > 0
float xwTot = (str.length(leadSym) > 0 ? xW1 : 0.0) + (str.length(leadSym2) > 0 ? xW2 : 0.0) + (str.length(leadSym3) > 0 ? xW3 : 0.0)
// per-sub-symbol graded reads per TF (unconditional security calls; signed+weighted)
float x1Trig = str.length(leadSym)  > 0 ? nz(request.security(leadSym,  trigTF, f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x1Sig  = str.length(leadSym)  > 0 ? nz(request.security(leadSym,  sigTF,  f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x1Bias = str.length(leadSym)  > 0 ? nz(request.security(leadSym,  biasTF, f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x2Trig = str.length(leadSym2) > 0 ? nz(request.security(leadSym2, trigTF, f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x2Sig  = str.length(leadSym2) > 0 ? nz(request.security(leadSym2, sigTF,  f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x2Bias = str.length(leadSym2) > 0 ? nz(request.security(leadSym2, biasTF, f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x3Trig = str.length(leadSym3) > 0 ? nz(request.security(leadSym3, trigTF, f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x3Sig  = str.length(leadSym3) > 0 ? nz(request.security(leadSym3, sigTF,  f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float x3Bias = str.length(leadSym3) > 0 ? nz(request.security(leadSym3, biasTF, f_leadGr(leadLen)[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)) : 0.0
float xBlTrig = xwTot > 0 ? (x1Trig * xSign1 * xW1 + x2Trig * xSign2 * xW2 + x3Trig * xSign3 * xW3) / xwTot : 0.0
float xBlSig  = xwTot > 0 ? (x1Sig  * xSign1 * xW1 + x2Sig  * xSign2 * xW2 + x3Sig  * xSign3 * xW3) / xwTot : 0.0
float xBlBias = xwTot > 0 ? (x1Bias * xSign1 * xW1 + x2Bias * xSign2 * xW2 + x3Bias * xSign3 * xW3) / xwTot : 0.0
int xTrigRaw = xBlTrig > 0 ? 1 : xBlTrig < 0 ? -1 : 0
int xSigRaw  = xBlSig  > 0 ? 1 : xBlSig  < 0 ? -1 : 0
int xBiasRaw = xBlBias > 0 ? 1 : xBlBias < 0 ? -1 : 0

// graded signal-TF strengths (only the signal TF feeds the plotted score line)
float momGr  = nz(request.security(syminfo.tickerid, sigTF, f_momGr(macdFast, macdSlow, macdSig)[1], lookahead = barmerge.lookahead_off))
float strGr  = nz(request.security(syminfo.tickerid, sigTF, f_strGr(fairLen, strZ)[1], lookahead = barmerge.lookahead_off))
float flowGr = nz(request.security(syminfo.tickerid, sigTF, f_flowGr(flowLen, bvcLen)[1], lookahead = barmerge.lookahead_off))
float fearGrRaw = request.security(volSym, sigTF, (close - ta.ema(close, fearLen))[1], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float fearAtr = ta.atr(fearLen)   // hoisted: must run every bar (was inside the na-guard ternary)
float fearGr = not na(fearGrRaw) ? math.max(-1.0, math.min(1.0, -fearGrRaw / (fearAtr * 2.0))) : 0.0
float xGr    = math.max(-1.0, math.min(1.0, xBlSig))

// active flags (axis on AND data present)
bool aMom  = useMom
bool aStr  = useStr
bool aFlow = useFlow
bool aFear = useFear and fearOK
bool aXmkt = useXmkt and xmktOK

// ═════════════════════════════════════════════════════════════════════════════
// GATES (context — scale conviction / set allowed side; never vote)
// ═════════════════════════════════════════════════════════════════════════════
float atr = ta.atr(atrLen)
// volatility regime: realized vol percentile (high vol → smaller conviction)
float rv   = ta.stdev(srcPrice - srcPrice[1], volGateLen)
float rvPct= ta.percentrank(rv, volGateLen)
float volScale = useVolGate ? math.max(0.4, 1.0 - 0.6 * (rvPct / 100.0)) : 1.0
// trend-efficiency (chop → smaller conviction)
float erNum = math.abs(srcPrice - srcPrice[erLen])
float erDen = math.sum(math.abs(srcPrice - srcPrice[1]), erLen)
float erVal = erDen > 0 ? erNum / erDen : 0.0
float effScale = useEffGate ? math.max(0.5, math.min(1.0, 0.5 + erVal)) : 1.0
// bias-gate allowed side: net of the bias-TF axis votes
int biasNet = (aMom ? momBias : 0) + (aStr ? strBias : 0) + (aFlow ? flowBias : 0) + (aFear ? fearBias : 0) + (aXmkt ? xBiasRaw : 0)
int allowSide = not useBiasGate ? 0 : biasNet > 0 ? 1 : biasNet < 0 ? -1 : 0

// ═════════════════════════════════════════════════════════════════════════════
// PER-CELL CALIBRATION  (triple-barrier per axis on the SIGNAL TF vote)
//   axis ids: 1 Mom · 2 Str · 3 Flow · 4 Fear · 5 Xmkt
// ═════════════════════════════════════════════════════════════════════════════
int NAX = 5
f_axName(int id) => id == 1 ? "Momentum" : id == 2 ? "Stretch" : id == 3 ? "Flow" : id == 4 ? "Fear" : id == 5 ? "Cross-mkt" : "—"
var array<Ev> pend = array.new<Ev>()
var float[] axNsum = array.new<float>(NAX + 1, 0.0)
var float[] axWsum = array.new<float>(NAX + 1, 0.0)
var float[] axBsum = array.new<float>(NAX + 1, 0.0)
var int[]   axN    = array.new<int>(NAX + 1, 0)
var int[]   axLast = array.new<int>(NAX + 1, -100000)
// zone-matched base: triple-barrier win rate of a DIRECTION-MATCHED random entry,
// measured by the IDENTICAL barrier procedure as the hit (same stop/target/horizon
// /tiebreak), so edge = axis-win-rate − all-bar-win-rate is apples-to-apples.
var array<Ev> bpendL = array.new<Ev>()
var array<Ev> bpendS = array.new<Ev>()
var int baseLwin = 0
var int baseLtot = 0
var int baseSwin = 0
var int baseStot = 0
var int baseLastBar = -100000

f_fire(int axis, int dir) =>
    if useCalib and barstate.isconfirmed and dir != 0 and (bar_index - axLast.get(axis)) >= calMinGap and not na(atr) and atr > 0.0
        axLast.set(axis, bar_index)
        float uw = 1.0 / (1.0 + pend.size())
        pend.push(Ev.new(axis, dir, close, atr, bar_index, uw, false))

if aMom
    f_fire(1, momSig)
if aStr
    f_fire(2, strSig)
if aFlow
    f_fire(3, flowSig)
if aFear
    f_fire(4, fearSig)
if aXmkt
    f_fire(5, xSigRaw)

// base-rate sampling: fire a long-base AND short-base event every calMinGap bars
if useCalib and barstate.isconfirmed and not na(atr) and atr > 0.0 and (bar_index - baseLastBar) >= calMinGap
    baseLastBar := bar_index
    bpendL.push(Ev.new(0, 1, close, atr, bar_index, 1.0, false))
    bpendS.push(Ev.new(0, -1, close, atr, bar_index, 1.0, false))
// resolve long-base queue (same triple-barrier as hit)
if useCalib and barstate.isconfirmed and bpendL.size() > 0
    for i = bpendL.size() - 1 to 0
        Ev p = bpendL.get(i)
        if not p.done
            float favor   = high - p.entry
            float adverse = p.entry - low
            bool hitStop = adverse >= calStopATR * p.atr0
            bool hitTgt  = favor   >= calMoveATR * p.atr0
            bool tmOut   = bar_index - p.bidx >= calHorizon
            if hitStop or hitTgt or tmOut
                p.done := true
                bool win = hitStop ? false : hitTgt ? true : ((close - p.entry) >= calMoveATR * p.atr0)
                baseLtot += 1
                baseLwin += win ? 1 : 0
                bpendL.remove(i)
// resolve short-base queue
if useCalib and barstate.isconfirmed and bpendS.size() > 0
    for i = bpendS.size() - 1 to 0
        Ev p = bpendS.get(i)
        if not p.done
            float favor   = p.entry - low
            float adverse = high - p.entry
            bool hitStop = adverse >= calStopATR * p.atr0
            bool hitTgt  = favor   >= calMoveATR * p.atr0
            bool tmOut   = bar_index - p.bidx >= calHorizon
            if hitStop or hitTgt or tmOut
                p.done := true
                bool win = hitStop ? false : hitTgt ? true : ((p.entry - close) >= calMoveATR * p.atr0)
                baseStot += 1
                baseSwin += win ? 1 : 0
                bpendS.remove(i)

// resolve samples (triple-barrier)
if useCalib and barstate.isconfirmed and pend.size() > 0
    for i = pend.size() - 1 to 0
        Ev p = pend.get(i)
        if not p.done
            float favor   = p.dir > 0 ? (high - p.entry) : (p.entry - low)
            float adverse = p.dir > 0 ? (p.entry - low)  : (high - p.entry)
            bool hitStop = adverse >= calStopATR * p.atr0
            bool hitTgt  = favor   >= calMoveATR * p.atr0
            bool tmOut   = bar_index - p.bidx >= calHorizon
            if hitStop or hitTgt or tmOut
                p.done := true
                bool win = hitStop ? false : hitTgt ? true : ((p.dir > 0 ? (close - p.entry) : (p.entry - close)) >= calMoveATR * p.atr0)
                int a = p.axis
                float w = p.uw
                axN.set(a, axN.get(a) + 1)
                axNsum.set(a, axNsum.get(a) * calDecay + w)
                axWsum.set(a, axWsum.get(a) * calDecay + (win ? w : 0.0))
                float bp = p.dir > 0 ? (baseLtot > 0 ? baseLwin / float(baseLtot) : 0.5) : (baseStot > 0 ? baseSwin / float(baseStot) : 0.5)
                axBsum.set(a, axBsum.get(a) + bp)
                pend.remove(i)

// per-axis edge + edge lower-bound → vote weight
f_edgeLB(int a) =>
    float r = na
    int n = axN.get(a)
    if n >= calMinSamp
        float ns = axNsum.get(a)
        float h  = ns > 0 ? axWsum.get(a) / ns : na
        float bp = axBsum.get(a) / n
        float ci = f_ci(axWsum.get(a), ns, 1.96)
        if not na(h) and not na(ci)
            r := (h - ci) - bp
    r
f_weight(int a) =>
    float e = f_edgeLB(a)
    not useCalib ? 1.0 : (na(e) ? wFloor : wFloor + math.max(0.0, e))

// ═════════════════════════════════════════════════════════════════════════════
// SCORE  (vote on signal TF, weighted by edgeLB; gates scale; bias gate vetoes)
// ═════════════════════════════════════════════════════════════════════════════
f_axVote(int a) => a == 1 ? momSig : a == 2 ? strSig : a == 3 ? flowSig : a == 4 ? fearSig : a == 5 ? xSigRaw : 0
f_axActive(int a) => a == 1 ? aMom : a == 2 ? aStr : a == 3 ? aFlow : a == 4 ? aFear : a == 5 ? aXmkt : false

float wPos = 0.0
float wNeg = 0.0
float wAll = 0.0
int methodBull = 0
int methodBear = 0
for a = 1 to NAX
    if f_axActive(a)
        int v = f_axVote(a)
        float w = f_weight(a)
        wAll += w
        if v > 0
            wPos += w
            methodBull += 1
        if v < 0
            wNeg += w
            methodBear += 1
float rawScore = wAll > 0 ? (wPos - wNeg) / wAll : 0.0
int rawDir = rawScore > 0 ? 1 : rawScore < 0 ? -1 : 0
int methodAgree = rawDir > 0 ? methodBull : rawDir < 0 ? methodBear : 0

// graded score: same edgeLB weights, but each axis contributes its STRENGTH
// (clamped ±1) instead of its sign. Feeds the plotted line in Graded mode so it
// breathes through the middle. Does NOT affect rawDir / signals / verdict.
f_axGr(int a) => a == 1 ? momGr : a == 2 ? strGr : a == 3 ? flowGr : a == 4 ? fearGr : a == 5 ? xGr : 0.0
float gWsum = 0.0
float gWall = 0.0
for a = 1 to NAX
    if f_axActive(a)
        float w = f_weight(a)
        gWsum += w * f_axGr(a)
        gWall += w
float gradedScore = gWall > 0 ? gWsum / gWall : 0.0

// scale-confluence: timeframes agreeing for the LEADING axis (the one with max weight in rawDir)
f_axTrig(int a) => a == 1 ? momTrig : a == 2 ? strTrig : a == 3 ? flowTrig : a == 4 ? fearTrig : a == 5 ? xTrigRaw : 0
f_axBias(int a) => a == 1 ? momBias : a == 2 ? strBias : a == 3 ? flowBias : a == 4 ? fearBias : a == 5 ? xBiasRaw : 0
int leadAxis = 0
float leadW = -1.0
for a = 1 to NAX
    if f_axActive(a) and f_axVote(a) == rawDir and rawDir != 0
        float w = f_weight(a)
        if w > leadW
            leadW := w
            leadAxis := a
int scaleAgree = 0
if leadAxis > 0
    scaleAgree := (f_axTrig(leadAxis) == rawDir ? 1 : 0) + (f_axVote(leadAxis) == rawDir ? 1 : 0) + (f_axBias(leadAxis) == rawDir ? 1 : 0)

// gates
float gateScale = volScale * effScale
float conv0 = math.abs(rawScore) * 100.0 * gateScale
// bias-gate veto: block votes against the allowed side
bool biasBlocked = useBiasGate and allowSide != 0 and rawDir != 0 and rawDir != allowSide
int conv = math.round(conv0)
int dir = rawDir

bool methodOK = methodAgree >= minMethod
bool act = dir != 0 and conv >= minConv and methodOK and not biasBlocked
int verdictDir = act ? dir : 0

// ═════════════════════════════════════════════════════════════════════════════
// VERDICT STRINGS
// ═════════════════════════════════════════════════════════════════════════════
// tier: 0 learning · 1 blocked/flat · 2 unproven-ish · 3 confirmed
bool anyWarm = false
int warmCount = 0
int activeCount = 0
for a = 1 to NAX
    if f_axActive(a)
        activeCount += 1
        if axN.get(a) >= calMinSamp
            anyWarm := true
            warmCount += 1
int tier = not anyWarm and useCalib ? 0 : biasBlocked ? 1 : act ? 3 : 2
string verdict  = tier == 3 ? (dir > 0 ? "✓ LONG CONFLUENCE" : "✓ SHORT CONFLUENCE") : tier == 1 ? "✗ BLOCKED BY BIAS" : tier == 0 ? "… LEARNING" : "• NO CONFLUENCE"
string actShort = tier == 3 ? (dir > 0 ? "Favour longs" : "Favour shorts") : tier == 1 ? "Counter higher-TF" : tier == 0 ? "Gathering data" : "Stand aside"
string biasTxt  = allowSide == 1 ? "Longs only" : allowSide == -1 ? "Shorts only" : "Either side"

// ═════════════════════════════════════════════════════════════════════════════
// THEME
// ═════════════════════════════════════════════════════════════════════════════
bool dark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_luma(chart.bg_color) < 140
color panelBg = dark ? color.rgb(17, 22, 28)  : color.rgb(244, 246, 248)
color rowAlt  = dark ? color.rgb(25, 31, 39)  : color.rgb(232, 236, 240)
color pTxt    = dark ? color.rgb(154,166,178) : color.rgb(74, 82, 91)
color pStr    = dark ? color.white            : color.rgb(16, 20, 24)
color frameC  = dark ? color.rgb(58, 70, 84)  : color.rgb(196,204,212)
color tierCol = tier == 3 ? (dir > 0 ? bullCol : bearCol) : tier == 1 ? bearCol : tier == 0 ? color.gray : midColr
color tierTxt = f_luma(tierCol) > 150 ? color.black : color.white

// ═════════════════════════════════════════════════════════════════════════════
// PLOTS  (conventional oscillator surface: zone bands, score line, signals)
//   Read it like an RSI: line in the GREEN zone = strong bullish confluence,
//   RED zone = strong bearish. Triangles on PRICE = the gated, edge-weighted
//   verdict fired. Divergence is drawn on the line with Bull/Bear labels.
// ═════════════════════════════════════════════════════════════════════════════
float scoreRaw = (scoreMode == "Graded (breathing line)" ? gradedScore : rawScore) * 100.0
float scoreEma  = ta.ema(scoreRaw, scoreSmooth)   // hoisted: runs every bar (guard is a constant input)
float scorePlot = scoreSmooth > 1 ? scoreEma : scoreRaw
color scoreCol = scorePlot > 0 ? bullCol : scorePlot < 0 ? bearCol : color.new(chart.fg_color, 25)

// zone bands (faint guides at ±50 = strong confluence; kept very light so they
// orient the eye without competing with the line)
pHi  = plot(50.0,  "Strong bull zone", color = color.new(bullCol, 82), linewidth = 1, display = display.pane, editable = false)
pHiC = plot(100.0, "caphi", color = color.new(bullCol, 100), display = display.none, editable = false)
pLo  = plot(-50.0, "Strong bear zone", color = color.new(bearCol, 82), linewidth = 1, display = display.pane, editable = false)
pLoC = plot(-100.0,"caplo", color = color.new(bearCol, 100), display = display.none, editable = false)
fill(pHi, pHiC, 100.0, 50.0, color.new(bullCol, 96), color.new(bullCol, 90), title = "Bull zone")
fill(pLo, pLoC, -50.0, -100.0, color.new(bearCol, 90), color.new(bearCol, 96), title = "Bear zone")
hline(0, "Zero", color.new(chart.fg_color, 55))

// score line is the PRIMARY read; the fill is only a light wash to zero so the
// sign is obvious at a glance. Wash stays faint even at the rails (never a slab).
float fillTransp = 96.0 - 8.0 * math.min(math.abs(scorePlot) / 100.0, 1.0)
pScore = plot(scorePlot, "Confluence score", color = scoreCol, linewidth = 3)
pZero  = plot(0.0, "zero ref", color = na, display = display.none, editable = false)
fill(pScore, pZero, color = color.new(scoreCol, int(fillTransp)), title = "Confluence fill")

// ── conventional BUY / SELL triangles on the PRICE chart ──
// State machine: a signal fires once when confluence turns active in a direction,
// then must (a) go flat or flip AND (b) clear a cooldown before re-arming. This
// collapses each swing's cluster into a single clean mark.
var int armedDir = 0          // +1 long-fired, -1 short-fired, 0 ready
var int lastSigBar = -100000
bool cooled = (bar_index - lastSigBar) >= sigCooldown
// re-arm when the verdict leaves the direction it last fired
if armedDir == 1 and dir <= 0
    armedDir := 0
if armedDir == -1 and dir >= 0
    armedDir := 0
bool longFire  = act and dir > 0 and armedDir != 1 and cooled
bool shortFire = act and dir < 0 and armedDir != -1 and cooled
if longFire
    armedDir := 1
    lastSigBar := bar_index
if shortFire
    armedDir := -1
    lastSigBar := bar_index
// strength split: strong = large + text, weak = small dot
bool longStrong  = longFire  and conv >= strongConv
bool longWeak    = longFire  and conv <  strongConv
bool shortStrong = shortFire and conv >= strongConv
bool shortWeak   = shortFire and conv <  strongConv
plotshape(longStrong,  "BUY",       shape.triangleup,   location.belowbar, color.new(bullCol, 0),  size = size.small, text = "BUY",  textcolor = color.white, force_overlay = true)
plotshape(longWeak,    "buy (weak)",shape.triangleup,   location.belowbar, color.new(bullCol, 0),  size = size.small,  force_overlay = true)
plotshape(shortStrong, "SELL",      shape.triangledown, location.abovebar, color.new(bearCol, 0),  size = size.small, text = "SELL", textcolor = color.white, force_overlay = true)
plotshape(shortWeak,   "sell (weak)",shape.triangledown,location.abovebar, color.new(bearCol, 0),  size = size.small,  force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════
// DIVERGENCE  (price vs confluence score, confirmed pivots → non-repainting)
//   Bull = price lower low while the score makes a higher low (and vice versa).
//   Drawn on the score line with a Bull / Bear label, exactly like any oscillator.
// ═════════════════════════════════════════════════════════════════════════════
float dPH = ta.pivothigh(scorePlot, divPivL, divPivR)
float dPL = ta.pivotlow(scorePlot, divPivL, divPivR)
var float pHsc = na
var float pHpr = na
var int   pHbr = na
var float pLsc = na
var float pLpr = na
var int   pLbr = na
var int   lastDivBullBar = -100000
var int   lastDivBearBar = -100000
bool divBull = false
bool divBear = false
if showDiv and not na(dPL)
    float sc = scorePlot[divPivR]
    float pr = srcPrice[divPivR]
    int   bi = bar_index - divPivR
    if not na(pLsc) and (bi - pLbr) <= divMaxGap
        divBull := sc > pLsc and pr < pLpr
        bool bullFights = divNoFight and dir < 0 and conv >= strongConv
        if divBull and not bullFights and (bi - lastDivBullBar) >= divCooldown
            line.new(pLbr, pLsc, bi, sc, color = color.new(bullCol, 0), width = 2)
            label.new(bi, sc, "Bull", yloc = yloc.price, style = label.style_label_up, color = color.new(bullCol, 20), textcolor = color.white, size = size.tiny)
            lastDivBullBar := bi
    pLsc := sc
    pLpr := pr
    pLbr := bi
if showDiv and not na(dPH)
    float sc = scorePlot[divPivR]
    float pr = srcPrice[divPivR]
    int   bi = bar_index - divPivR
    if not na(pHsc) and (bi - pHbr) <= divMaxGap
        divBear := sc < pHsc and pr > pHpr
        bool bearFights = divNoFight and dir > 0 and conv >= strongConv
        if divBear and not bearFights and (bi - lastDivBearBar) >= divCooldown
            line.new(pHbr, pHsc, bi, sc, color = color.new(bearCol, 0), width = 2)
            label.new(bi, sc, "Bear", yloc = yloc.price, style = label.style_label_down, color = color.new(bearCol, 20), textcolor = color.white, size = size.tiny)
            lastDivBearBar := bi
    pHsc := sc
    pHpr := pr
    pHbr := bi

// ═════════════════════════════════════════════════════════════════════════════
// VERDICT PANEL (top-right)
// ═════════════════════════════════════════════════════════════════════════════
var table pan = table.new(position.top_right, 2, 8, frame_width = 1, border_width = 1)
f_pan(int r, string k, string v, color vc, string tip) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(pan, 0, r, k, text_color = pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left, tooltip = tip)
    table.cell(pan, 1, r, v, text_color = vc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right, tooltip = tip)
if barstate.islast and showVerdict
    table.set_frame_color(pan, frameC)
    table.set_border_color(pan, frameC)
    table.cell(pan, 0, 0, "CONFLUENCE", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(pan, 1, 0, verdict, text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_right)
    f_pan(1, "Do this", actShort, tierCol, "The action the confluence supports right now.")
    f_pan(2, "Method confluence", str.tostring(methodAgree) + " of " + str.tostring((aMom?1:0)+(aStr?1:0)+(aFlow?1:0)+(aFear?1:0)+(aXmkt?1:0)) + " axes", methodAgree >= minMethod ? pStr : pTxt, "How many INDEPENDENT axes agree on the signal timeframe. The real confirmation.")
    f_pan(3, "Scale confluence", leadAxis == 0 ? "—" : str.tostring(scaleAgree) + " of 3 TFs", pStr, "How many timeframes the leading axis agrees on. Timing/robustness only — NOT an extra vote.")
    f_pan(4, "Conviction", str.tostring(conv) + " / 100", conv >= minConv ? pStr : pTxt, "Weighted score after volatility and efficiency gates.")
    f_pan(5, "Calibration", useCalib ? (str.tostring(warmCount) + " of " + str.tostring(activeCount) + " cells warm") : "off (equal weights)", warmCount >= activeCount and activeCount > 0 ? pStr : warmCount == 0 ? bearCol : midColr, "How many active axes have enough resolved samples to trust their edge weight. Until cells warm, low conviction means 'still learning', not 'no edge'.")
    f_pan(6, "Higher-TF bias", biasTxt, allowSide == 1 ? bullCol : allowSide == -1 ? bearCol : pTxt, "Which side the bias timeframe allows. Trades against it are blocked.")
    f_pan(7, "Frames", trigTF + " · " + sigTF + " · " + biasTF, pTxt, "Trigger · Signal · Bias timeframes (adaptive to the chart unless Manual).")

// ═════════════════════════════════════════════════════════════════════════════
// MATRIX TABLE (bottom-right) — axes × timeframes + per-axis edge
// ═════════════════════════════════════════════════════════════════════════════
var table mtx = table.new(position.bottom_right, 6, 7, frame_width = 1, border_width = 1)
f_arrow(int v) => v > 0 ? "▲" : v < 0 ? "▼" : "·"
f_acol(int v) => v > 0 ? bullCol : v < 0 ? bearCol : pTxt
f_mrow(int r, int a, string nm) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    bool on = f_axActive(a)
    float e = f_edgeLB(a)
    table.cell(mtx, 0, r, nm, text_color = on ? pStr : pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(mtx, 1, r, on ? f_arrow(f_axTrig(a)) : "—", text_color = on ? f_acol(f_axTrig(a)) : pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(mtx, 2, r, on ? f_arrow(f_axVote(a)) : "—", text_color = on ? f_acol(f_axVote(a)) : pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(mtx, 3, r, on ? f_arrow(f_axBias(a)) : "—", text_color = on ? f_acol(f_axBias(a)) : pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(mtx, 4, r, str.tostring(axN.get(a)), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(mtx, 5, r, na(e) ? "—" : (e >= 0 ? "+" : "") + str.tostring(e * 100, "#.#"), text_color = na(e) ? pTxt : e > 0 ? bullCol : bearCol, bgcolor = bg, text_size = size.tiny)
if barstate.islast and showMatrix
    table.set_frame_color(mtx, frameC)
    table.set_border_color(mtx, frameC)
    table.cell(mtx, 0, 0, "AXIS", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(mtx, 1, 0, "Trig", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(mtx, 2, 0, "Sig", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(mtx, 3, 0, "Bias", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(mtx, 4, 0, "n", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(mtx, 5, 0, "edgeLB", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    f_mrow(1, 1, "Momentum")
    f_mrow(2, 2, "Stretch")
    f_mrow(3, 3, "Flow")
    f_mrow(4, 4, "Fear")
    f_mrow(5, 5, "Cross-mkt")
    table.cell(mtx, 0, 6, "edgeLB weights votes", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(mtx, 1, 6, "", bgcolor = panelBg)
    table.cell(mtx, 2, 6, "", bgcolor = panelBg)
    table.cell(mtx, 3, 6, "", bgcolor = panelBg)
    table.cell(mtx, 4, 6, "", bgcolor = panelBg)
    table.cell(mtx, 5, 6, "", bgcolor = panelBg)

// ═════════════════════════════════════════════════════════════════════════════
// KEY-INFO TABLE  (live state — Compact essentials or Pro full detail)
// ═════════════════════════════════════════════════════════════════════════════
int keyRows = keyMode == "Pro" ? 9 : 5
var table keyT = table.new(position.middle_left, 2, 9, frame_width = 1, border_width = 1)
f_key(int r, string k, string v, color vc) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(keyT, 0, r, k, text_color = pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyT, 1, r, v, text_color = vc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
if barstate.islast and showKey
    table.set_frame_color(keyT, frameC)
    table.set_border_color(keyT, frameC)
    table.cell(keyT, 0, 0, "KEY INFO", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyT, 1, 0, verdict, text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_right)
    f_key(1, "Action", actShort, tierCol)
    f_key(2, "Conviction", str.tostring(conv) + " / 100", conv >= minConv ? pStr : pTxt)
    f_key(3, "Method confluence", str.tostring(methodAgree) + " of " + str.tostring(activeCount), methodAgree >= minMethod ? pStr : pTxt)
    f_key(4, "Higher-TF bias", biasTxt, allowSide == 1 ? bullCol : allowSide == -1 ? bearCol : pTxt)
    if keyMode == "Pro"
        f_key(5, "Scale confluence", leadAxis == 0 ? "—" : str.tostring(scaleAgree) + " of 3 TFs", pStr)
        f_key(6, "Calibration", useCalib ? (str.tostring(warmCount) + " of " + str.tostring(activeCount) + " warm") : "off", warmCount >= activeCount and activeCount > 0 ? pStr : warmCount == 0 ? bearCol : midColr)
        f_key(7, "Leading axis", leadAxis == 0 ? "—" : f_axName(leadAxis), pStr)
        f_key(8, "Frames", trigTF + "·" + sigTF + "·" + biasTF, pTxt)

// ═════════════════════════════════════════════════════════════════════════════
// NAME TAG
// ═════════════════════════════════════════════════════════════════════════════
var table idT = table.new(position.bottom_center, 1, 1)
if barstate.islast and showId
    table.cell(idT, 0, 0, "MACM · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = dark ? color.white : color.black, bgcolor = color.new(dark ? color.black : color.white, 15))

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════
alertcondition(act and dir > 0, "Long confluence", "Confluence Matrix: long confluence confirmed")
alertcondition(act and dir < 0, "Short confluence", "Confluence Matrix: short confluence confirmed")
alertcondition(divBull, "Bullish divergence", "Confluence Matrix: bullish divergence on the score line")
alertcondition(divBear, "Bearish divergence", "Confluence Matrix: bearish divergence on the score line")

// ═════════════════════════════════════════════════════════════════════════════
// EXP_* EXPORTS
// ═════════════════════════════════════════════════════════════════════════════
float bestEdge = na
float bestEdgeLB = na
int totN = 0
for a = 1 to NAX
    if f_axActive(a)
        totN += axN.get(a)
        float e = f_edgeLB(a)
        if not na(e) and (na(bestEdgeLB) or e > bestEdgeLB)
            bestEdgeLB := e
color exC = color.new(color.gray, 100)
plot(showEXP ? verdictDir : na, "EXP_Dir", color = exC, display = display.data_window)
plot(showEXP ? conv : na, "EXP_Conviction", color = exC, display = display.data_window)
plot(showEXP ? methodAgree : na, "EXP_Method", color = exC, display = display.data_window)
plot(showEXP ? scaleAgree : na, "EXP_Scale", color = exC, display = display.data_window)
plot(showEXP ? allowSide : na, "EXP_Bias", color = exC, display = display.data_window)
plot(showEXP ? (rawDir) : na, "EXP_Regime", color = exC, display = display.data_window)
plot(showEXP ? scorePlot : na, "EXP_Edge", color = exC, display = display.data_window)
plot(showEXP ? (na(bestEdgeLB) ? na : bestEdgeLB * 100.0) : na, "EXP_EdgeLB", color = exC, display = display.data_window)
plot(showEXP ? totN : na, "EXP_N", color = exC, display = display.data_window)
````
