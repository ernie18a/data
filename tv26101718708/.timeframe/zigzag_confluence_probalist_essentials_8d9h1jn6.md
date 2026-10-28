# ZigZag Confluence [Probalist Essentials]

- url: https://www.tradingview.com/script/8D9h1jn6-ZigZag-Confluence-Probalist-Essentials/
- type: indicator
- pine_id: PUB;aa027bbbaffe4a04a98b3dbbfe16a6c7
- version: 1.0

## Description

ZigZag Confluence draws swing structure with a clear line between what is settled and what is still moving. A confirmed leg is solid and does not redraw once it forms; the developing leg is dashed and labelled, so you can tell the fixed structure from the live edge at a glance. It is non-repainting where it counts: the part that genuinely cannot be final yet is shown as provisional, not dressed up as done. Every confirmed pivot carries a two-line balloon (the signed %-change of the leg and the pivot price) plus a weighted dot sized by how big the completing leg was relative to history. An optional marker shows the bar each pivot actually confirmed, so the confirmation lag — the cost of not repainting — is there to see rather than hidden.

And it keeps score. Over a fixed window after each confirmed pivot it records three things per direction: the favorable run (MFE — how far the move travelled your way), the adverse heat (MAE — how far it went against you first), and the net return at the end of the window. The run and heat percentiles project forward from the live pivot as stop/target rails — the favorable target in the leg's colour, the stop in the opposite — and the favorable-run distribution is drawn as a bell to the right of the chart. The edge verdict is judged separately, on the net follow-through: was it reliably positive on this chart's own history, with a Wilson-bounded win rate? Description, not prediction — and the code is open, so you can count it yourself.

🟡 WHY THIS VERSION

Most ZigZag indicators redraw their last leg silently — they look perfectly timed in hindsight because they were. This one doesn't: confirmed pivots are frozen the moment they form and never move, the developing leg is dashed with the lag spelled out, and an optional ✓ marker shows the exact bar each pivot became actionable. The other thing worth having is that it keeps score where it matters for a swing tool. Instead of a static pivot count, it measures — over a real holding window — how far past legs ran in your favour, how much heat they took first, and whether the net follow-through actually held. You get stop/target rails sized from that history and an honest edge read: a range and a verdict, not a guarantee. And the confirmation timeframes and the HTF overlay derive from your chart, so the multi-timeframe confluence means something on a 5-minute chart as much as on a daily.

🟡 HOW IT WORKS

The pivot detection uses a scale-free ATR threshold: price must reverse from a running extreme by at least k × ATR(14) before the extreme is frozen as a confirmed pivot. A fixed-percentage threshold breaks on low-priced assets and behaves differently in high-volatility regimes; the ATR multiple adjusts naturally. A minimum 'depth' in bars adds a secondary filter so very brief wicks don't confirm pivots on noisy markets.

Once a pivot is confirmed, a solid coloured leg is drawn from the previous pivot (gold for up-legs, blue for down-legs), a two-line balloon labels it, and a weighted dot marks the confirmation bar. The developing leg — from the most recent confirmed pivot to the current running extreme — is drawn dashed and updated every bar. It may extend or be replaced; this is explicitly the confirmation trade-off made visible, not a repaint. The classic ZigZag's flaw is that it draws this same provisional leg as if it were final and then silently redraws it — which is exactly why it looks flawless on historical bars; separating confirmed (solid, frozen) from developing (dashed, labelled) is the honest fix.

It then keeps score over a fixed horizon after each confirmed pivot. For every signal it tracks the running favorable excursion (MFE) and adverse excursion (MAE) from the entry anchor, and the net return once the horizon completes — recorded only on closed bars, non-repainting by construction. A single ZigZag leg is monotonic, so the heat within one leg is near zero; the fixed window is what captures real adverse movement, including pivots that fail and reverse. The run and heat percentiles size the projected stop/target rails — the stop sits at the 90th-percentile heat, because the median heat is ~0 (most entries take no drawdown below them) and the real risk lives in the tail. The edge verdict is judged on the net return: the Wilson-score lower bound of the share of positive-net pivots, with the recent window catching regime shifts faster than the full history. The favorable-run distribution is drawn as a kernel-smoothed bell to the right of the chart. Two anchor modes: Confirmation (the realistic entry, with real heat) and Pivot extreme (the idealized ceiling — anchored at the exact swing, so net is positive by construction and the edge read is suppressed as not meaningful there).

🟡 KEY FEATURES
[list]
[*]Honest two-tone rendering: confirmed legs solid and permanent, the developing leg dashed and labelled — the distinction is explicit, not hidden. An optional marker shows the exact bar each pivot confirmed (the lag = the price of not repainting).
[*]ATR-scaled reversal threshold: scale-free across assets, adjusts to volatility regimes automatically. A depth-in-bars filter rejects brief wicks.
[*]Per-pivot two-line balloon labels: signed %-change on top, pivot price below, leg duration in the hover tooltip.
[*]Weighted signal dots sized by leg-size percentile (self-calibrating 60th/90th tiers), carrying an evidence glyph: ● recent net-backed · ◐ has stats but not backed · ○ gathering. A ◈ prefix marks pivots that land at a prior confirmed pivot level — a fixed, tight invalidation (geometry, not extra probability).
[*]Excursion read per direction: over a fixed horizon after each pivot it measures the favorable run (MFE) and the adverse heat (MAE), projected forward from the live pivot as stop/target rails — favorable target in the leg's colour, the stop (90th-percentile heat) in the opposite. The favorable-run distribution is drawn as a kernel-smoothed bell with the live leg's percentile marked.
[*]Honest net-edge verdict: judged on the net return at the horizon (not the trivially-positive run), with a Wilson-score lower bound, a recent-vs-long-run read and a dual edge-clock. Suppressed under the pivot-extreme anchor, where net is positive by construction and labelled the idealized ceiling, not an edge.
[*]Evidence-gated alerts: standard and net-history-backed variants of bull/bear pivot confirmations, plus BOS/CHoCH and pivot-at-prior-level — all non-repainting (bar-close vs pre-fixed levels).
[*]MTF ✓-badges with auto-derived rungs: the confirmation timeframes come from your chart (the next steps up the ladder 1·5·15·60·240·D·W·M, so a 5m chart checks 15m/1h/4h, not D/W; change the chart TF and the rungs follow). When a higher TF later confirms the same swing, the balloon is stamped (e.g. ✓4h) — confluence shown when it actually exists, never before, since a higher timeframe confirms later by construction.
[*]Ghost pivots: faint ● dots in the accent colours (gold = a would-be swing high, blue = a would-be swing low) at superseded extremes that stood at least the confirmation depth before price pushed through — every spot where a repainting ZigZag would have printed a pivot and silently erased it. The honest counterpart of never repainting.
[*]Market structure layer: every balloon tagged HH/HL/LH/LL, with BOS and CHoCH flagged when a bar closes beyond the last confirmed swing level — the level is fixed before the break, so the call is non-repainting by construction.
[*]Optional HTF ZigZag overlay with the same auto-derived ladder (two rungs up the chart): a thin dotted higher-timeframe structure for context. Display only — it never filters or alters signals.
[/list]

🟡 HOW TO USE
[list]
[*]Use confirmed (solid) legs as your structure reference: they define swing highs and lows that won't move. A sequence of higher lows on solid lines is an uptrend; lower highs is a downtrend.
[*]Treat the dashed developing leg as provisional — its endpoint updates every bar. The 'confirms X' trigger level shows the close that would confirm it; the optional confirmation-bar marker shows, after the fact, how many bars the confirmation lagged the extreme. That lag is the honest cost of non-repainting structure.
[*]Read the stop/target rails on the active developing leg: the favorable target is the median (and 75th-percentile) run past legs made in this direction; the stop rail sits at the 90th-percentile heat — beyond where the normal adverse move stayed on ~90% of past legs. The reward:risk on the label is descriptive of this chart, not a promise.
[*]Use the net-edge read as context, not an entry trigger. A 'net follow-through reliably positive' verdict means past pivots here held up on a Wilson-bounded majority — weigh it against fees, spread and your holding period before acting.
[*]Check the developing leg's percentile in the favorable-run distribution: a leg already at the 85th percentile is well-extended by historical standards and may be closer to a pivot than a fresh one at the 20th.
[*]Costs honesty: pivot signals on low timeframes can show a tiny median net (e.g. +0.10–0.30% over the horizon). On most venues that does not survive round-trip costs — use the read for directional bias and higher-timeframe confluence, not as a standalone scalp entry.
[*]Size alerts around the evidence tier: the 'history-backed' alert variants fire only when the recent net clears the Wilson threshold; standard alerts fire on every confirmation. Use the backed variant for stronger-filter setups.
[*]Anchor choice: keep Confirmation (default) for the tradeable read — the entry you could actually take, with its real heat. Switch to Pivot extreme only to see the idealized ceiling (full run, ~zero heat); the edge verdict is intentionally suppressed there because net is positive by construction.
[*]Enable Show HTF ZigZag for the higher-timeframe structure as a thin dotted overlay (the timeframe auto-derives from your chart). Chart-timeframe pivots that align with an HTF leg in the same direction carry more structural weight — and the MTF ✓-badges quantify exactly that. Display only; it never filters or alters signals.
[/list]

🟡 PAIRS WELL WITH

ZigZag structure tells you where the swings are but not what drives them. A momentum oscillator like RSI or MACD adds a read on whether momentum is confirming the swing — a swing low into an OS zone with divergence is a more complete setup than a pivot alone. A volume indicator helps distinguish pivots that occurred on meaningful participation from low-volume reversals. For trend bias, a moving average or Supertrend on a higher timeframe filters which pivot direction to trade with versus against. Key S/R levels (daily highs/lows, prior swing clusters) give the structural context this tool measures but doesn't assess quality-wise — a confirmed pivot at a prior level is a different read than one in open air.

ZigZag Confluence gives you swing structure you can trust: pivots that don't move after the fact, a developing leg that tells you honestly it's still forming, and an excursion read that shows what this chart has actually done after past pivots — how far they ran, how much heat they took, and whether the net follow-through held — not what a backtest on a different instrument claims. The rails and the distribution are displays, not filters; the trader reads the evidence and decides.

[i]Open source under MPL-2.0. The probability layer describes past signals on your chart — it is a measurement, not a prediction, and nothing here is financial advice.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// ██████╗ ██████╗  ██████╗ ██████╗  █████╗ ██╗     ██╗███████╗████████╗
// ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██║     ██║██╔════╝╚══██╔══╝
// ██████╔╝██████╔╝██║   ██║██████╔╝███████║██║     ██║███████╗   ██║
// ██╔═══╝ ██╔══██╗██║   ██║██╔══██╗██╔══██║██║     ██║╚════██║   ██║
// ██║     ██║  ██║╚██████╔╝██████╔╝██║  ██║███████╗██║███████║   ██║
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝   ╚═╝

// What it shows: A ZigZag built to answer the usual objection. The classic ZigZag repaints —
// it silently redraws its last leg as price moves, so it looks perfectly timed in hindsight.
// This one separates the two states honestly: confirmed legs are frozen and solid (they never
// redraw); the still-forming leg is drawn dashed and labelled "developing", so the live part is
// never mistaken for settled structure. Per-pivot balloons show signed %-change and pivot price.
// Method: ATR-scaled reversal threshold (deviation ≥ k×ATR). A pivot is confirmed and frozen
// once price reverses by the threshold from an extreme; from that bar on it never moves. The
// developing leg may still extend or be replaced — that is the confirmation trade-off made
// visible. Lag = confirmation depth: the price of not repainting.
// How to use:
//   • Solid lines = confirmed structure. Use for S/R, trend bias, measured moves.
//   • Dashed line = still forming — treat as provisional until confirmed.
//   • MFE distribution: where the live leg sits vs the favorable-run history. Gold = up, blue = down.
//   • Pivot confirmation dots = primary signal for the probability read.
//   • Alerts fire on bar close, never in real time. A pivot confirms only AFTER price has already
//     reversed k×ATR from the extreme (and depth bars passed), so an alert can't fire early and
//     then shift — the reversal is a settled fact before it fires. That lag is the cost of not
//     repainting; the dashed developing leg + the "confirms X" trigger preview it live, no signal.

//@version=6
indicator("ZigZag Confluence [Probalist Essentials]", shorttitle = "ZigZag [P]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_polylines_count = 20)

// ══════════════════════════════════════════════════════════
// § INPUTS
// ══════════════════════════════════════════════════════════

// ■ Calculation
i_atrLen     = input.int(14,   "ATR Length",            minval = 2, maxval = 200, group = "■ Calculation", tooltip = "Period for the ATR used to scale the reversal threshold. Longer = smoother pivots, fewer swings.")
i_devMult    = input.float(1.5, "Reversal Multiplier (k×ATR)", minval = 0.1, maxval = 10.0, step = 0.1, group = "■ Calculation", tooltip = "Price must reverse by k×ATR from the last extreme to confirm a new pivot. Higher = fewer, larger swings. Scale-free across assets.")
i_depth      = input.int(5,    "Confirmation Depth (bars)",   minval = 1, maxval = 50, group = "■ Calculation", tooltip = "Minimum bars after an extreme before confirming it as a pivot. Higher = more lag, fewer false pivots. This lag is the cost of never repainting.")

// ■ Signals
i_showLabels = input.bool(true, "Show Pivot Labels",    group = "■ Signals", tooltip = "Show two-line balloon labels on each confirmed pivot: signed %-change on top, pivot price below.")
i_showDots   = input.bool(true, "Show Signal Dots",     group = "■ Signals", tooltip = "Show weighted dots at pivot confirmations — the primary signal for the probability read.")
i_showDev    = input.bool(true, "Show Developing Leg",  group = "■ Signals", tooltip = "Draw the still-forming leg as a dashed line with a Developing label. Toggle off for a clean confirmed-only view.")
i_showConfirm = input.bool(true, "Mark confirmation bar", group = "■ Signals", tooltip = "Each pivot is drawn at its extreme, but only CONFIRMED some bars later — the first bar you could actually act on it. This draws a faint dotted connector from the extreme to that confirmation bar, with the lag in bars. The gap is the confirmation lag (depth + the k×ATR reversal): the visible price of not repainting.")
i_showGhosts = input.bool(true, "Show Ghost Pivots",    group = "■ Signals", tooltip = "Mark superseded extremes with a faint ✕ in the accent colours — BLUE = a swing high that almost confirmed, GOLD = a swing low. Each is a spot where a repainting ZigZag printed a pivot, then erased it when price pushed through. A map of failed reversal attempts.")
i_structOn   = input.bool(true, "Market Structure (BOS/CHoCH)", group = "■ Signals", tooltip = "Tag every pivot balloon with HH/HL/LH/LL and flag Break of Structure / Change of Character when a bar CLOSES beyond the last confirmed swing level. Levels are fixed before the break — non-repainting by construction.")
i_lvlTol     = input.float(0.5, "Level Confluence Tolerance (×ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = "■ Signals", tooltip = "A new pivot landing within this distance of a PRIOR confirmed pivot level gets a ◈ mark on its signal dot: the level gives a fixed, tight invalidation. Geometry, not extra probability — the tooltip says so.")

// ■ Visuals
i_legWidth   = input.int(2,   "Leg Line Width",         minval = 1, maxval = 5, group = "■ Visuals", tooltip = "Stroke width for confirmed ZigZag legs.")
i_devWidth   = input.int(1,   "Developing Line Width",  minval = 1, maxval = 5, group = "■ Visuals", tooltip = "Stroke width for the dashed developing leg.")

// ■ Probalist Theme
i_col_hot    = input.color(color.rgb(249, 115, 22),  "Wave hot (bullish end)",   group = "■ Probalist Theme", tooltip = "Hot end of the heat ramp — bullish / strong readings.")
i_col_cold   = input.color(color.rgb(37,  99,  235),  "Wave cold (bearish end)",  group = "■ Probalist Theme", tooltip = "Cold end of the heat ramp — bearish / weak readings.")
i_dist_gold  = input.color(color.rgb(224, 168,   0),  "Gold accent (bullish)",    group = "■ Probalist Theme", tooltip = "Accent colour for bullish structure: up-leg lines, swing-high labels, bull signal dots.")
i_dist_cold  = input.color(color.rgb(50,  160, 255),  "Blue accent (bearish)",    group = "■ Probalist Theme", tooltip = "Accent colour for bearish structure: down-leg lines, swing-low labels, bear signal dots.")
i_glow       = input.bool(true, "Glow Effect",          group = "■ Probalist Theme", tooltip = "Layered neon glow under the confirmed legs (gold glows gold, blue glows blue) and behind the developing leg. OFF = clean lines only.")

// ■ Higher Timeframe
i_htfOn      = input.bool(false, "Show HTF ZigZag",    group = "■ Higher Timeframe", tooltip = "Overlay the higher-timeframe ZigZag as a thin dotted silver structure — the same ATR-scaled method run on completed HTF bars. Display only — does not filter signals.")
i_htfAuto    = input.bool(true,  "Auto HTF (derive from chart TF)", group = "■ Higher Timeframe", tooltip = "ON (default): the overlay timeframe is derived from the chart — two rungs up the ladder 1·5·15·60·240·D·W·M (e.g. 5m→1h, 15m→4h, 1h→D). Change the chart TF and it follows. OFF: use the fixed timeframe below.")
i_htf        = input.timeframe("D", "HTF Timeframe (manual)",   group = "■ Higher Timeframe", tooltip = "The timeframe for the HTF reference. Used only when Auto HTF is OFF.")

// ■ MTF Confirmation
i_mtfOn      = input.bool(true,  "MTF ✓-badges on pivot labels", group = "■ MTF Confirmation", tooltip = "When a higher timeframe later confirms the SAME swing (same pivot type, price within tolerance), the pivot balloon is stamped with a ✓ badge (e.g. ✓15m ✓1h ✓4h). Badges arrive AFTER the chart pivot by construction — a bigger threshold confirms later. Honest confluence, never an entry trigger.")
i_mtfAuto    = input.bool(true,  "Auto rungs (derive from chart TF)", group = "■ MTF Confirmation", tooltip = "ON (default): the three confirmation timeframes are derived from the chart — the next rungs up the ladder 1 · 5 · 15 · 60 · 240 · D · W · M. On a 5m chart that gives 15m / 1h / 4h, not D/W; change the chart TF and the rungs follow automatically. OFF: use the three fixed timeframes below.")
i_mtf1       = input.timeframe("240", "MTF 1 (manual)", group = "■ MTF Confirmation", tooltip = "First confirmation timeframe. Used only when Auto rungs is OFF. Must be higher than the chart timeframe to mean anything.")
i_mtf2       = input.timeframe("D",   "MTF 2 (manual)", group = "■ MTF Confirmation", tooltip = "Second confirmation timeframe. Used only when Auto rungs is OFF. Must be higher than MTF 1.")
i_mtf3       = input.timeframe("W",   "MTF 3 (manual)", group = "■ MTF Confirmation", tooltip = "Third confirmation timeframe. Used only when Auto rungs is OFF. Must be higher than MTF 2.")

// ■ Probability Read
i_probOn     = input.bool(true,  "Probability Read (master)",         group = "■ Probability Read", tooltip = "Master toggle for all excursion-read layers: recording, stats, readout, stop/target rails, distribution panel, tooltips, evidence-gated alerts. How far past legs ran (and how much heat they took first) on THIS chart — description, not prediction.")
i_anchor     = input.string("Confirmation", "Excursion Anchor", options = ["Confirmation", "Pivot extreme"], group = "■ Probability Read", tooltip = "Where each leg's excursion is measured from. Confirmation (default) = the bar the pivot CONFIRMS — the first price a trader could actually act on, so it shows the real adverse heat you take after entry. Pivot extreme = the idealised swing price itself; the favorable run is the full leg, but adverse heat is ~0 by construction (you cannot buy the exact bottom).")
i_readoutOn  = input.bool(true,  "↳ Readout panel",                   group = "■ Probability Read", tooltip = "Show the mini-readout in the future space: state, MFE/MAE stats, edge clock, and Read sentence.")
i_coneOn     = input.bool(true,  "↳ Stop / Target Rails",             group = "■ Probability Read", tooltip = "Project the favorable (MFE) and adverse (MAE) excursion percentiles forward from the live leg's anchor as horizontal rails — favorable target in the leg's colour, the stop in the opposite colour — plus the empirical reward:risk.")
i_panelOn    = input.bool(true,  "↳ Excursion Distribution",          group = "■ Probability Read", tooltip = "Draw the kernel-smoothed favorable-excursion (MFE) distribution for the active direction to the right of the last bar.")
i_horizon    = input.int(30,    "Excursion Horizon (bars)",   minval = 1, maxval = 200, group = "■ Probability Read", tooltip = "Holding window after each pivot over which the favorable (MFE) and adverse (MAE) excursions are measured — the running best-favorable and worst-adverse move within this many bars. Also the forward length of the stop/target rails. A single leg is monotonic so heat would read ~0; a fixed window captures the real heat, including pivots that fail and reverse.")
i_maxSamp    = input.int(200,   "Max Samples",      minval = 30, maxval = 500, group = "■ Probability Read", tooltip = "Maximum outcome observations to keep. Oldest are dropped when the buffer is full.")
i_minSamp    = input.int(20,    "Min Samples",      minval = 5,  maxval = 100, group = "■ Probability Read", tooltip = "Minimum samples before reporting statistics. Below this, the readout shows 'gathering'.")
i_recWin     = input.int(30,    "Recent Window (outcomes)", minval = 15, maxval = 500, group = "■ Probability Read", tooltip = "Number of most-recent outcomes used for the Recent Form read. Pivot signals are sparse, so keep this window short — shorter windows catch regime shifts faster.")
i_zConf      = input.string("80%", "Evidence Strictness (Wilson)", options = ["80%", "90%", "95%"], group = "■ Probability Read", tooltip = "Confidence level for the Wilson-score lower bound used to judge 'backed'. 80% catches emerging edges earlier; 95% demands stronger evidence.")
i_spacing    = input.int(10,    "Signal Spacing (bars)",  minval = 1, maxval = 100, group = "■ Probability Read", tooltip = "Minimum bars between recorded pivot signals per direction. Prevents overlapping outcome windows from inflating the sample count.")

// ══════════════════════════════════════════════════════════
// § PROBALIST HEAT
// ══════════════════════════════════════════════════════════

normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

heatCol(float pos, float transp, color col_hot, color col_cold) =>
    color col = na
    if pos >= 0.80
        col := color.from_gradient(pos, 0.80, 1.0, color.rgb(245, 158, 11), col_hot)
    else if pos >= 0.62
        col := color.from_gradient(pos, 0.62, 0.80, color.rgb(251, 191, 36), color.rgb(245, 158, 11))
    else if pos >= 0.50
        col := color.from_gradient(pos, 0.50, 0.62, color.rgb(167, 243, 208), color.rgb(251, 191, 36))
    else if pos >= 0.40
        col := color.from_gradient(pos, 0.40, 0.50, color.rgb(56, 189, 248), color.rgb(167, 243, 208))
    else if pos >= 0.22
        col := color.from_gradient(pos, 0.22, 0.40, color.rgb(6, 182, 212), color.rgb(56, 189, 248))
    else
        col := color.from_gradient(pos, 0.0, 0.22, col_cold, color.rgb(6, 182, 212))
    color.new(col, transp)

// ══════════════════════════════════════════════════════════
// § ATR + CORE PIVOT LOGIC
// ══════════════════════════════════════════════════════════

atrVal = ta.atr(i_atrLen)
thresh = i_devMult * atrVal

// 50-bar range for panel/readout geometry — ta.* must run on EVERY bar (never inside barstate.islast)
rngHi50 = ta.highest(50)
rngLo50 = ta.lowest(50)

// Pivot state machine
// direction: 1 = last confirmed pivot was a LOW (up-leg in progress), -1 = was a HIGH
var int   pDir       = 0       // current trend direction
var float pExtreme   = na      // running extreme of the developing leg
var int   pExtremeBar = na     // bar_index of that extreme
var float pPivotPrice = na     // last confirmed pivot price
var int   pPivotBar  = na      // last confirmed pivot bar
// Ghost-pivot tracking — deepest counter-move since the current extreme
var float ghostLow  = na
var float ghostHigh = na
var array<label> ghostLabels = array.new<label>(0)

// Confirmed pivot arrays (price, bar, direction: 1=low -1=high)
var array<float> cPivPx  = array.new<float>(0)
var array<int>   cPivBar = array.new<int>(0)
var array<int>   cPivDir = array.new<int>(0)   // 1=swing low, -1=swing high

// Track when the most recent confirmed pivot leg-line was drawn
// so we can manage drawing objects
var array<line>  legLines  = array.new<line>(0)
var array<line>  legGlow   = array.new<line>(0)
var array<label> pivLabels = array.new<label>(0)
var array<line>  confLines = array.new<line>(0)
var array<label> confMarks = array.new<label>(0)
// Pivot-label registry for retroactive MTF ✓-badges (parallel to pivLabels)
var array<float>  lblPivPx  = array.new<float>(0)
var array<int>    lblPivDir = array.new<int>(0)
var array<string> lblBase   = array.new<string>(0)
var array<bool>   lblM1     = array.new<bool>(0)
var array<bool>   lblM2     = array.new<bool>(0)
var array<bool>   lblM3     = array.new<bool>(0)

// Developing leg drawing objects (single, updated in-place)
var line  devLine  = na
var label devLabel = na
var line  glowLine1 = na
var line  glowLine2 = na
var line  glowLine3 = na
var line  devTail    = na
var line  devTrigLn  = na
var label devTrigLbl = na

// ──────────────────────────────────────────────
// Initialise on first bar
// ──────────────────────────────────────────────
if bar_index == 0
    pDir        := 1
    pExtreme    := low
    pExtremeBar := 0
    pPivotPrice := low
    pPivotBar   := 0
    ghostLow    := low
    ghostHigh   := high

// ──────────────────────────────────────────────
// Helper: add a confirmed pivot
// ──────────────────────────────────────────────
addPivot(float px, int bx, int dir) =>
    array.push(cPivPx,  px)
    array.push(cPivBar, bx)
    array.push(cPivDir, dir)
    // Cap history to avoid unbounded growth
    if array.size(cPivPx) > 300
        array.shift(cPivPx)
        array.shift(cPivBar)
        array.shift(cPivDir)

// ──────────────────────────────────────────────
// State machine: detect new extremes + confirmations
// ──────────────────────────────────────────────
bool newBullPivot = false   // confirmed swing LOW this bar
bool newBearPivot = false   // confirmed swing HIGH this bar
float newPivPx = na
int   newPivBx = na

// Track the extreme for the developing leg each bar
if pDir == 1
    // Tracking an up-move; extreme = highest high
    if high > pExtreme
        // Ghost pivot: a serious candidate — stood ≥ depth bars OR drew a retrace ≥ 50% of the threshold
        ghRetrUp = pExtreme - nz(ghostLow, low)
        ghPctUp  = thresh > 0 ? math.round(ghRetrUp / thresh * 100) : 0
        if i_showGhosts and not na(pExtreme) and ((bar_index - pExtremeBar) >= i_depth or ghRetrUp >= 0.5 * thresh)
            ghUp = label.new(pExtremeBar, pExtreme, "●", style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_gold, 38), size = size.normal, tooltip = "Ghost pivot — stood " + str.tostring(bar_index - pExtremeBar) + " bars as the leg extreme, the retrace reached " + str.tostring(ghPctUp) + "% of the confirmation threshold, then price pushed through. A repainting ZigZag printed a pivot here, then erased it.")
            array.push(ghostLabels, ghUp)
            if array.size(ghostLabels) > 100
                label.delete(array.shift(ghostLabels))
        pExtreme    := high
        pExtremeBar := bar_index
        ghostLow    := low
    else
        ghostLow := math.min(nz(ghostLow, low), low)
    // Check for reversal: if price has fallen thresh below the running high
    if not na(pExtreme) and (pExtreme - close) >= thresh and (bar_index - pExtremeBar) >= i_depth
        // Confirm the high as a swing HIGH pivot
        newBearPivot := true
        newPivPx     := pExtreme
        newPivBx     := pExtremeBar
        addPivot(pExtreme, pExtremeBar, -1)
        pPivotPrice  := pExtreme
        pPivotBar    := pExtremeBar
        pDir         := -1
        pExtreme     := low
        pExtremeBar  := bar_index
        ghostHigh    := high
else
    // Tracking a down-move; extreme = lowest low
    if low < pExtreme
        // Ghost pivot: a serious candidate — stood ≥ depth bars OR drew a retrace ≥ 50% of the threshold
        ghRetrDn = nz(ghostHigh, high) - pExtreme
        ghPctDn  = thresh > 0 ? math.round(ghRetrDn / thresh * 100) : 0
        if i_showGhosts and not na(pExtreme) and ((bar_index - pExtremeBar) >= i_depth or ghRetrDn >= 0.5 * thresh)
            ghDn = label.new(pExtremeBar, pExtreme, "●", style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_cold, 38), size = size.normal, tooltip = "Ghost pivot — stood " + str.tostring(bar_index - pExtremeBar) + " bars as the leg extreme, the retrace reached " + str.tostring(ghPctDn) + "% of the confirmation threshold, then price pushed through. A repainting ZigZag printed a pivot here, then erased it.")
            array.push(ghostLabels, ghDn)
            if array.size(ghostLabels) > 100
                label.delete(array.shift(ghostLabels))
        pExtreme    := low
        pExtremeBar := bar_index
        ghostHigh   := high
    else
        ghostHigh := math.max(nz(ghostHigh, high), high)
    // Check for reversal: if price has risen thresh above the running low
    if not na(pExtreme) and (close - pExtreme) >= thresh and (bar_index - pExtremeBar) >= i_depth
        // Confirm the low as a swing LOW pivot
        newBullPivot := true
        newPivPx     := pExtreme
        newPivBx     := pExtremeBar
        addPivot(pExtreme, pExtremeBar, 1)
        pPivotPrice  := pExtreme
        pPivotBar    := pExtremeBar
        pDir         := 1
        pExtreme     := high
        pExtremeBar  := bar_index
        ghostLow     := low

// ──────────────────────────────────────────────
// Draw confirmed leg when a new pivot is added
// ──────────────────────────────────────────────
nSize = array.size(cPivPx)

if (newBullPivot or newBearPivot) and nSize >= 2
    px2 = array.get(cPivPx,  nSize - 1)
    bx2 = array.get(cPivBar, nSize - 1)
    px1 = array.get(cPivPx,  nSize - 2)
    bx1 = array.get(cPivBar, nSize - 2)
    dir2 = array.get(cPivDir, nSize - 1)
    // Up-leg ends at a swing high (dir2 = -1), so line from low→high = gold
    // Down-leg ends at a swing low (dir2 = 1), so line from high→low = blue
    legCol = dir2 == 1 ? i_dist_cold : i_dist_gold
    newLeg = line.new(bx1, px1, bx2, px2, color = legCol, width = i_legWidth, style = line.style_solid)
    array.push(legLines, newLeg)
    if i_glow
        // Layered neon glow under the leg — wider and more transparent per layer
        glowA = line.new(bx1, px1, bx2, px2, color = color.new(legCol, 58), width = i_legWidth + 5,  style = line.style_solid)
        glowB = line.new(bx1, px1, bx2, px2, color = color.new(legCol, 76), width = i_legWidth + 11, style = line.style_solid)
        glowC = line.new(bx1, px1, bx2, px2, color = color.new(legCol, 89), width = i_legWidth + 18, style = line.style_solid)
        array.push(legGlow, glowA)
        array.push(legGlow, glowB)
        array.push(legGlow, glowC)
        if array.size(legGlow) > 240
            line.delete(array.shift(legGlow))
            line.delete(array.shift(legGlow))
            line.delete(array.shift(legGlow))
    if array.size(legLines) > 200
        line.delete(array.shift(legLines))
    // Per-pivot label on the NEW confirmed pivot
    if i_showLabels
        pctChg = (px2 - px1) / px1 * 100
        sign   = pctChg >= 0 ? "+" : ""
        topTxt = sign + str.tostring(pctChg, "0.00") + "%"
        botTxt = str.tostring(px2, format.mintick)
        // Confirmation delta: where the confirmation close sat vs the pivot extreme — the slippage
        // from the idealized swing price to the first price you could actually have entered at.
        confDelta = px2 != 0 ? (close - px2) / px2 * 100 : 0.0
        confTxt   = i_showConfirm ? " (C" + (confDelta >= 0 ? "+" : "") + str.tostring(confDelta, "0.00") + "%)" : ""
        // HH/HL/LH/LL vs the previous same-type pivot (pivots alternate, so same-type = two back)
        string structTag = ""
        if i_structOn and nSize >= 3
            prevSamePx = array.get(cPivPx, nSize - 3)
            structTag := dir2 == -1 ? (px2 > prevSamePx ? "HH" : "LH") : (px2 > prevSamePx ? "HL" : "LL")
        lblTxt = (structTag != "" ? structTag + " · " : "") + topTxt + "\n" + botTxt + confTxt
        durBars = bx2 - bx1
        tipTxt  = "Leg: " + topTxt + " over " + str.tostring(durBars) + " bars" + (i_showConfirm ? "\nConfirmation entry " + (confDelta >= 0 ? "+" : "") + str.tostring(confDelta, "0.00") + "% from the pivot extreme — the gap between the idealized swing price and the first actionable close. Always ≥ the k×ATR threshold." : "") + (i_mtfOn ? "\nMTF ✓-badges appear when a higher timeframe confirms the same swing — later, by construction (display only)." : "")
        // Gold label on swing HIGH (top), blue on swing LOW — matches the leg colours
        lblBg   = dir2 == 1 ? color.new(i_dist_cold, 20) : color.new(i_dist_gold, 20)
        lblStyle = dir2 == 1 ? label.style_label_up : label.style_label_down
        newLbl  = label.new(bx2, px2, lblTxt, style = lblStyle, color = lblBg, textcolor = color.white, size = size.small, tooltip = tipTxt)
        array.push(pivLabels, newLbl)
        array.push(lblPivPx,  px2)
        array.push(lblPivDir, dir2)
        array.push(lblBase,   lblTxt)
        array.push(lblM1, false)
        array.push(lblM2, false)
        array.push(lblM3, false)
        if array.size(pivLabels) > 200
            label.delete(array.shift(pivLabels))
            array.shift(lblPivPx)
            array.shift(lblPivDir)
            array.shift(lblBase)
            array.shift(lblM1)
            array.shift(lblM2)
            array.shift(lblM3)

// ──────────────────────────────────────────────
// Confirmation-bar marker (optional) — link the extreme to the bar it actually confirmed on
// ──────────────────────────────────────────────
if i_showConfirm and barstate.isconfirmed and (newBullPivot or newBearPivot) and not na(newPivBx) and bar_index > newPivBx
    cCol = newBullPivot ? i_dist_gold : i_dist_cold
    lagB = bar_index - newPivBx
    cLn  = line.new(newPivBx, newPivPx, bar_index, newPivPx, color = color.new(cCol, 55), style = line.style_dotted, width = 1)
    cMk  = label.new(bar_index, newPivPx, "✓ +" + str.tostring(lagB) + "b", style = label.style_label_center, color = color.new(color.black, 70), textcolor = color.new(cCol, 12), size = size.tiny, tooltip = "Confirmed here — " + str.tostring(lagB) + " bars after the pivot extreme. The pivot sits back at " + str.tostring(newPivPx, format.mintick) + "; this is the first bar you could have acted on it. The gap = confirmation lag (depth + the k×ATR reversal). Non-repainting has a price — this shows it.")
    array.push(confLines, cLn)
    array.push(confMarks, cMk)
    if array.size(confLines) > 120
        line.delete(array.shift(confLines))
        label.delete(array.shift(confMarks))

// ──────────────────────────────────────────────
// Developing leg (dashed, updated every bar)
// ──────────────────────────────────────────────
if i_showDev and nSize >= 1 and not na(pExtreme) and not na(pPivotPrice)
    devCol  = pDir == 1 ? i_dist_gold : i_dist_cold
    devCol2 = color.new(devCol, 60)
    // Delete old developing objects
    if not na(devLine)
        line.delete(devLine)
    if not na(devLabel)
        label.delete(devLabel)
    if not na(devTail)
        line.delete(devTail)
    if not na(devTrigLn)
        line.delete(devTrigLn)
    if not na(devTrigLbl)
        label.delete(devTrigLbl)
    if i_glow
        if not na(glowLine1)
            line.delete(glowLine1)
        if not na(glowLine2)
            line.delete(glowLine2)
        if not na(glowLine3)
            line.delete(glowLine3)
    // Draw fresh developing leg from last confirmed pivot to current extreme
    devLine  := line.new(pPivotBar, pPivotPrice, pExtremeBar, pExtreme, color = devCol, width = i_devWidth, style = line.style_dashed)
    devLblTxt = "developing"
    devLblStyle = pDir == 1 ? label.style_label_up : label.style_label_down
    devLabel := label.new(pExtremeBar, pExtreme, devLblTxt, style = devLblStyle, color = color.new(color.black, 55), textcolor = color.new(devCol, 10), size = size.tiny, tooltip = "This leg is still forming. It will extend or be replaced when confirmed. Confirmation costs " + str.tostring(i_depth) + " bars of lag — that is the price of not repainting.")
    // Retrace tail — where price sits NOW vs the candidate pivot (the part still being written)
    if bar_index > pExtremeBar
        devTail := line.new(pExtremeBar, pExtreme, bar_index, close, color = color.new(color.silver, 55), width = 1, style = line.style_dotted)
    // Confirmation trigger — the close that would confirm the candidate pivot (depth permitting)
    trigPx  = pDir == 1 ? pExtreme - thresh : pExtreme + thresh
    trigCol = pDir == 1 ? i_dist_cold : i_dist_gold
    devTrigLn  := line.new(pExtremeBar, trigPx, bar_index + 3, trigPx, color = color.new(trigCol, 55), width = 1, style = line.style_dotted)
    devTrigLbl := label.new(bar_index + 3, trigPx, "confirms " + str.tostring(trigPx, format.mintick), style = label.style_label_left, color = color.new(color.black, 55), textcolor = color.new(trigCol, 20), size = size.tiny, tooltip = "If price closes " + (pDir == 1 ? "below" : "above") + " this level (and the extreme is at least " + str.tostring(i_depth) + " bars old), the candidate pivot confirms and the developing leg flips direction.")
    if i_glow
        glowLine1 := line.new(pPivotBar, pPivotPrice, pExtremeBar, pExtreme, color = color.new(devCol, 65), width = i_devWidth + 3, style = line.style_dashed)
        glowLine2 := line.new(pPivotBar, pPivotPrice, pExtremeBar, pExtreme, color = color.new(devCol, 80), width = i_devWidth + 5, style = line.style_dashed)
        glowLine3 := line.new(pPivotBar, pPivotPrice, pExtremeBar, pExtreme, color = color.new(devCol, 90), width = i_devWidth + 8, style = line.style_dashed)

// ══════════════════════════════════════════════════════════
// § MARKET STRUCTURE — BOS / CHoCH (bar-close vs pre-fixed levels)
// ══════════════════════════════════════════════════════════

// Breaking the last confirmed swing HIGH: continuation (BOS ↑) in an up structure,
// Change of Character (CHoCH ↑) when the structure was down — and mirrored for lows.
// The level is fixed when the pivot confirms; the break is a bar-close event. Non-repainting.

var float lastSH    = na
var int   lastSHBar = na
var bool  shBroken  = false
var float lastSL    = na
var int   lastSLBar = na
var bool  slBroken  = false
var int   structDir = 0
var array<label> structLabels = array.new<label>(0)
var array<line>  structLines  = array.new<line>(0)

if newBearPivot
    lastSH    := newPivPx
    lastSHBar := newPivBx
    shBroken  := false
if newBullPivot
    lastSL    := newPivPx
    lastSLBar := newPivBx
    slBroken  := false

bool bosUpEvt   = false
bool bosDnEvt   = false
bool chochUpEvt = false
bool chochDnEvt = false

if barstate.isconfirmed
    if not na(lastSH) and not shBroken and close > lastSH
        if structDir == -1
            chochUpEvt := true
        else
            bosUpEvt := true
        shBroken  := true
        structDir := 1
        if i_structOn
            sTxtU = chochUpEvt ? "CHoCH ↑" : "BOS ↑"
            sTipU = chochUpEvt ? "Change of Character — close above the last confirmed swing high while the structure was down: potential reversal, flagged earlier than the ZigZag flip itself. Bar-close event against a pre-fixed level — non-repainting." : "Break of Structure — close above the last confirmed swing high in an up structure: continuation. Bar-close event against a pre-fixed level — non-repainting."
            sLnU  = line.new(lastSHBar, lastSH, bar_index, lastSH, color = color.new(i_dist_gold, 45), style = line.style_dotted, width = 1)
            sLbU  = label.new(bar_index, lastSH, sTxtU, style = label.style_label_left, color = color.new(color.black, 45), textcolor = color.new(i_dist_gold, 10), size = size.tiny, tooltip = sTipU)
            array.push(structLines, sLnU)
            array.push(structLabels, sLbU)
            if array.size(structLabels) > 60
                label.delete(array.shift(structLabels))
                line.delete(array.shift(structLines))
    if not na(lastSL) and not slBroken and close < lastSL
        if structDir == 1
            chochDnEvt := true
        else
            bosDnEvt := true
        slBroken  := true
        structDir := -1
        if i_structOn
            sTxtD = chochDnEvt ? "CHoCH ↓" : "BOS ↓"
            sTipD = chochDnEvt ? "Change of Character — close below the last confirmed swing low while the structure was up: potential reversal, flagged earlier than the ZigZag flip itself. Bar-close event against a pre-fixed level — non-repainting." : "Break of Structure — close below the last confirmed swing low in a down structure: continuation. Bar-close event against a pre-fixed level — non-repainting."
            sLnD  = line.new(lastSLBar, lastSL, bar_index, lastSL, color = color.new(i_dist_cold, 45), style = line.style_dotted, width = 1)
            sLbD  = label.new(bar_index, lastSL, sTxtD, style = label.style_label_left, color = color.new(color.black, 45), textcolor = color.new(i_dist_cold, 10), size = size.tiny, tooltip = sTipD)
            array.push(structLines, sLnD)
            array.push(structLabels, sLbD)
            if array.size(structLabels) > 60
                label.delete(array.shift(structLabels))
                line.delete(array.shift(structLines))

// ══════════════════════════════════════════════════════════
// § LEVEL CONFLUENCE — pivot lands at a prior confirmed pivot level
// ══════════════════════════════════════════════════════════

// Prior highs AND lows both count (role reversal: broken resistance acts as support).
// The two newest pivots are excluded — they define the current swing, not a prior level.
bool  atLevel    = false
int   lvlTouches = 0
float lvlPx      = na
if (newBullPivot or newBearPivot) and nSize >= 3
    lvlTol   = i_lvlTol * atrVal
    scanFrom = math.max(0, nSize - 32)
    for li = scanFrom to nSize - 3
        oldPx = array.get(cPivPx, li)
        if math.abs(oldPx - newPivPx) <= lvlTol
            lvlTouches += 1
            lvlPx := oldPx
    atLevel := lvlTouches > 0

// ══════════════════════════════════════════════════════════
// § MTF CONFIRMATION BADGES (display only)
// ══════════════════════════════════════════════════════════

// Three extra ZigZag machines on completed MTF bars. When one confirms the SAME swing
// (same pivot type, price within 0.35×ATR), the chart pivot balloon is stamped (e.g. ✓15m / ✓1h / ✓4h).
// Badges arrive LATER than the chart pivot by construction — honest confluence, never a trigger.

// Auto rungs: the next three steps up the ladder 1·5·15·60·240·D·W·M from the chart TF.
// request.security needs a SIMPLE string — build each via a ternary chain (never := reassignment).
chartSec = timeframe.in_seconds(timeframe.period)
effMtf1 = chartSec < 300 ? "5"  : chartSec < 900 ? "15"  : chartSec < 3600 ? "60"  : chartSec < 14400 ? "240" : chartSec < 86400 ? "D" : chartSec < 604800 ? "W" : "M"
effMtf2 = chartSec < 300 ? "15" : chartSec < 900 ? "60"  : chartSec < 3600 ? "240" : chartSec < 14400 ? "D"   : chartSec < 86400 ? "W" : "M"
effMtf3 = chartSec < 300 ? "60" : chartSec < 900 ? "240" : chartSec < 3600 ? "D"   : chartSec < 14400 ? "W"   : "M"
mtf1 = i_mtfAuto ? effMtf1 : i_mtf1
mtf2 = i_mtfAuto ? effMtf2 : i_mtf2
mtf3 = i_mtfAuto ? effMtf3 : i_mtf3

[m1H, m1L, m1C, m1A] = request.security(syminfo.tickerid, mtf1, [high[1], low[1], close[1], ta.atr(i_atrLen)[1]], lookahead = barmerge.lookahead_off)
[m2H, m2L, m2C, m2A] = request.security(syminfo.tickerid, mtf2, [high[1], low[1], close[1], ta.atr(i_atrLen)[1]], lookahead = barmerge.lookahead_off)
[m3H, m3L, m3C, m3A] = request.security(syminfo.tickerid, mtf3, [high[1], low[1], close[1], ta.atr(i_atrLen)[1]], lookahead = barmerge.lookahead_off)

tfNice(string tf) =>
    float mins = str.tonumber(tf)
    string r = tf
    if not na(mins)
        if mins >= 1440 and mins % 1440 == 0
            r := str.tostring(mins / 1440, "0") + "D"
        else if mins >= 60 and mins % 60 == 0
            r := str.tostring(mins / 60, "0") + "h"
        else
            r := str.tostring(mins, "0") + "m"
    r

tf1N = tfNice(mtf1)
tf2N = tfNice(mtf2)
tf3N = tfNice(mtf3)

// One independent state machine per call site (`var` persists per instance)
mtfZig(float mH, float mL, float mC, float mA) =>
    var int   mDir = 0
    var float mExt = na
    bool  mFired    = false
    float mFiredPx  = na
    int   mFiredDir = 0
    float mTh = i_devMult * mA
    if not na(mA) and not na(mH)
        if mDir == 0
            mDir := 1
            mExt := mH
        if mDir == 1
            if mH > mExt
                mExt := mH
            if (mExt - mC) >= mTh
                mFired    := true
                mFiredPx  := mExt
                mFiredDir := -1
                mDir := -1
                mExt := mL
        else if mDir == -1
            if mL < mExt
                mExt := mL
            if (mC - mExt) >= mTh
                mFired    := true
                mFiredPx  := mExt
                mFiredDir := 1
                mDir := 1
                mExt := mH
    [mFired, mFiredPx, mFiredDir]

applyMtfBadge(bool fired, float fPx, int fDir, array<bool> flagArr) =>
    if i_mtfOn and fired and array.size(pivLabels) > 0
        int nL = array.size(pivLabels)
        int fromIdx = math.max(0, nL - 12)
        for di = nL - 1 to fromIdx
            if array.get(lblPivDir, di) == fDir and math.abs(array.get(lblPivPx, di) - fPx) <= 0.35 * atrVal and not array.get(flagArr, di)
                array.set(flagArr, di, true)
                string badge = ""
                if array.get(lblM1, di)
                    badge := "✓" + tf1N
                if array.get(lblM2, di)
                    badge := badge + (badge == "" ? "" : " ") + "✓" + tf2N
                if array.get(lblM3, di)
                    badge := badge + (badge == "" ? "" : " ") + "✓" + tf3N
                label.set_text(array.get(pivLabels, di), array.get(lblBase, di) + "\n" + badge)
                break

// Chained guards: each rung must be strictly higher than the one below it (and the chart),
// so collapsed rungs on high chart TFs (e.g. D → W, M, M) never double-stamp the same badge.
m1Valid = timeframe.in_seconds(mtf1) > chartSec
m2Valid = timeframe.in_seconds(mtf2) > timeframe.in_seconds(mtf1)
m3Valid = timeframe.in_seconds(mtf3) > timeframe.in_seconds(mtf2)

[m1Fired, m1Px, m1Dir] = mtfZig(m1H, m1L, m1C, m1A)
[m2Fired, m2Px, m2Dir] = mtfZig(m2H, m2L, m2C, m2A)
[m3Fired, m3Px, m3Dir] = mtfZig(m3H, m3L, m3C, m3A)
applyMtfBadge(m1Fired and m1Valid, m1Px, m1Dir, lblM1)
applyMtfBadge(m2Fired and m2Valid, m2Px, m2Dir, lblM2)
applyMtfBadge(m3Fired and m3Valid, m3Px, m3Dir, lblM3)

// ══════════════════════════════════════════════════════════
// § PROBABILITY READ — EXCURSION (MFE/MAE) + NET EDGE
// ══════════════════════════════════════════════════════════

// Over a fixed horizon after each confirmed pivot: favorable run (MFE), adverse heat (MAE), and
// the net return at horizon end. MFE/MAE size the stops/targets; net drives the edge verdict.

// Excursion arrays — parallel per direction (same index = same measured window)
var array<float> mfeBull = array.new<float>(0)   // favorable run of up-legs (%)
var array<float> maeBull = array.new<float>(0)   // adverse heat of up-legs (%)
var array<float> mfeBear = array.new<float>(0)   // favorable run of down-legs (%)
var array<float> maeBear = array.new<float>(0)   // adverse heat of down-legs (%)
var array<float> netBull = array.new<float>(0)   // NET return at horizon end, up-legs (%, signed into direction)
var array<float> netBear = array.new<float>(0)   // NET return at horizon end, down-legs (%)

// Dot label handles — kept only to delete the oldest when the 400-label cap is hit
var array<label> dotLabelsBull = array.new<label>(0)
var array<label> dotLabelsBear = array.new<label>(0)

// Last fire bar for signal spacing
var int lastBullFire = na
var int lastBearFire = na

// Leg-size atlas arrays (% move per confirmed leg)
var array<float> legSizesUp   = array.new<float>(0)
var array<float> legSizesDn   = array.new<float>(0)

// Strength arrays for dot sizing (excursion depth)
var array<float> strArrBull = array.new<float>(0)
var array<float> strArrBear = array.new<float>(0)

// Edge clock — ● backed (Wilson) and ◐ lean (sensitive) per direction
var int edgeTimeBull = na
var int edgeTimeBear = na
var int leanTimeBull = na
var int leanTimeBear = na

// Wilson z-score lookup
wilsonZ = i_zConf == "95%" ? 1.960 : i_zConf == "90%" ? 1.645 : 1.282

// R:R formatter — "—:1" when undefined (e.g. median heat ≈ 0, the pivot-extreme degenerate case)
rrTxt(float r) =>
    na(r) ? "—" : str.tostring(r, "0.0")

// Excursion tracking — one developing leg per direction at a time.
// On a recorded signal we anchor; each confirmed bar extends the running high/low;
// when the OPPOSITE pivot confirms, the leg is done → push MFE/MAE. Non-repainting.
// Excursion tracking — a FIXED horizon after each pivot (a single leg is monotonic → heat ≈ 0;
// a forward window captures real heat, incl. pivots that fail and reverse). Pending queues:
// one entry per recorded signal, running max/min updated each bar until i_horizon bars elapse.
var array<int>   pBullBar  = array.new<int>(0)
var array<float> pBullAnc  = array.new<float>(0)
var array<float> pBullMaxH = array.new<float>(0)
var array<float> pBullMinL = array.new<float>(0)
var array<int>   pBearBar  = array.new<int>(0)
var array<float> pBearAnc  = array.new<float>(0)
var array<float> pBearMaxH = array.new<float>(0)
var array<float> pBearMinL = array.new<float>(0)
// Live developing-leg anchors (for the stop/target rails)
var float liveBullAnchor = na
var float liveBearAnchor = na

// Add leg sizes when a pivot is confirmed
if newBullPivot and nSize >= 2
    px2b = array.get(cPivPx, nSize - 1)
    px1b = array.get(cPivPx, nSize - 2)
    legPct = math.abs((px2b - px1b) / px1b * 100)
    array.push(legSizesUp, legPct)
    if array.size(legSizesUp) > i_maxSamp
        array.shift(legSizesUp)

if newBearPivot and nSize >= 2
    px2b = array.get(cPivPx, nSize - 1)
    px1b = array.get(cPivPx, nSize - 2)
    legPct = math.abs((px2b - px1b) / px1b * 100)
    array.push(legSizesDn, legPct)
    if array.size(legSizesDn) > i_maxSamp
        array.shift(legSizesDn)

// Open a window on each (spacing-respecting) pivot; each bar extend every open window's running
// max/min; when a window reaches i_horizon bars, finalise its MFE/MAE. Non-repainting (confirmed).
if i_probOn and barstate.isconfirmed
    // Open new windows
    if newBullPivot
        spaceOk = na(lastBullFire) or (bar_index - lastBullFire) >= i_spacing
        if spaceOk
            ancB = i_anchor == "Confirmation" ? close : newPivPx
            array.push(pBullBar, bar_index)
            array.push(pBullAnc, ancB)
            array.push(pBullMaxH, high)
            array.push(pBullMinL, low)
            liveBullAnchor := ancB
            lastBullFire   := bar_index
    if newBearPivot
        spaceOk = na(lastBearFire) or (bar_index - lastBearFire) >= i_spacing
        if spaceOk
            ancE = i_anchor == "Confirmation" ? close : newPivPx
            array.push(pBearBar, bar_index)
            array.push(pBearAnc, ancE)
            array.push(pBearMaxH, high)
            array.push(pBearMinL, low)
            liveBearAnchor := ancE
            lastBearFire   := bar_index

    // Extend + finalise bull windows (iterate backwards so removals are safe)
    if array.size(pBullBar) > 0
        for qi = array.size(pBullBar) - 1 to 0
            array.set(pBullMaxH, qi, math.max(array.get(pBullMaxH, qi), high))
            array.set(pBullMinL, qi, math.min(array.get(pBullMinL, qi), low))
            if bar_index - array.get(pBullBar, qi) >= i_horizon
                anc = array.get(pBullAnc, qi)
                if not na(anc) and anc != 0
                    mfeU = math.max(0.0, (array.get(pBullMaxH, qi) - anc) / anc * 100)
                    maeU = math.max(0.0, (anc - array.get(pBullMinL, qi)) / anc * 100)
                    netU = (close - anc) / anc * 100
                    array.push(mfeBull, mfeU)
                    array.push(maeBull, maeU)
                    array.push(netBull, netU)
                    if array.size(mfeBull) > i_maxSamp
                        array.shift(mfeBull)
                        array.shift(maeBull)
                        array.shift(netBull)
                array.remove(pBullBar, qi)
                array.remove(pBullAnc, qi)
                array.remove(pBullMaxH, qi)
                array.remove(pBullMinL, qi)

    // Extend + finalise bear windows
    if array.size(pBearBar) > 0
        for qi = array.size(pBearBar) - 1 to 0
            array.set(pBearMaxH, qi, math.max(array.get(pBearMaxH, qi), high))
            array.set(pBearMinL, qi, math.min(array.get(pBearMinL, qi), low))
            if bar_index - array.get(pBearBar, qi) >= i_horizon
                anc = array.get(pBearAnc, qi)
                if not na(anc) and anc != 0
                    mfeD = math.max(0.0, (anc - array.get(pBearMinL, qi)) / anc * 100)
                    maeD = math.max(0.0, (array.get(pBearMaxH, qi) - anc) / anc * 100)
                    netD = (anc - close) / anc * 100
                    array.push(mfeBear, mfeD)
                    array.push(maeBear, maeD)
                    array.push(netBear, netD)
                    if array.size(mfeBear) > i_maxSamp
                        array.shift(mfeBear)
                        array.shift(maeBear)
                        array.shift(netBear)
                array.remove(pBearBar, qi)
                array.remove(pBearAnc, qi)
                array.remove(pBearMaxH, qi)
                array.remove(pBearMinL, qi)

// Excursion + edge stats over parallel MFE/MAE/NET arrays.
// EDGE is judged on NET return at horizon end ("win" = net > 0) — NOT on MFE>MAE, which is
// degenerate (in a trend, or with the pivot-extreme anchor, heat is structurally ~0 so MFE
// always "wins"). A failed pivot ends with net < 0, so the net win-rate is honest in both anchors.
// R:R pairs the median run against the p75 heat (the stop-relevant percentile; the median heat
// is ~0 because most entries take no drawdown below them — the heat lives in the tail).
excStats(array<float> aMfe, array<float> aMae, array<float> aNet) =>
    float n      = array.size(aMfe)
    float mfeMed = na
    float mfeP75 = na
    float maeP75 = na
    float maeP90 = na
    float rr     = na
    float winR   = na
    float wilsL  = na
    float netMed = na
    if n > 0
        mfeMed := array.median(aMfe)
        mfeP75 := array.percentile_nearest_rank(aMfe, 75)
        maeP75 := array.percentile_nearest_rank(aMae, 75)
        maeP90 := array.percentile_nearest_rank(aMae, 90)
        netMed := array.median(aNet)
        rr     := maeP75 > 0.0001 ? mfeMed / maeP75 : na
        wins = 0
        for k = 0 to array.size(aNet) - 1
            if array.get(aNet, k) > 0
                wins += 1
        winR := wins / n * 100
        p      = wins / n
        z      = wilsonZ
        denom  = 1.0 + z * z / n
        centre = p + z * z / (2 * n)
        margin = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
        wilsL := (centre - margin) / denom * 100
    [n, mfeMed, mfeP75, maeP75, maeP90, rr, winR, wilsL, netMed]

// Recent-window slice (last i_recWin observations)
recSlice(array<float> a) =>
    array.size(a) > 0 ? array.slice(a, math.max(0, array.size(a) - i_recWin), array.size(a)) : array.new<float>(0)

[bN, bMfeMed, bMfeP75, bMaeP75, bMaeP90, bRR, bWin, bWilsL, bNetMed] = excStats(mfeBull, maeBull, netBull)
[eN, eMfeMed, eMfeP75, eMaeP75, eMaeP90, eRR, eWin, eWilsL, eNetMed] = excStats(mfeBear, maeBear, netBear)

[rbN, rbMfeMed, rbMfeP75, rbMaeP75, rbMaeP90, rbRR, rbWin, rbWilsL, rbNetMed] = excStats(recSlice(mfeBull), recSlice(maeBull), recSlice(netBull))
[reN, reMfeMed, reMfeP75, reMaeP75, reMaeP90, reRR, reWin, reWilsL, reNetMed] = excStats(recSlice(mfeBear), recSlice(maeBear), recSlice(netBear))

// Verdict helpers — "backed" = NET return at horizon is reliably positive (Wilson LB of P(net>0) > 50%) with a positive median net.
bullHasStats  = bN  >= i_minSamp
bearHasStats  = eN  >= i_minSamp
bullRecHas    = rbN >= 15
bearRecHas    = reN >= 15

// Pivot-extreme anchors at the exact swing, so net is positive by construction (you "bought the
// bottom") → the edge would be trivially "backed". The edge is only meaningful from Confirmation;
// in pivot-extreme it is suppressed — the run/heat/R:R stay as the descriptive idealized ceiling.
anchorExtreme = i_anchor == "Pivot extreme"

bullRecentBacked = not anchorExtreme and bullRecHas   and rbWilsL > 50 and rbNetMed > 0
bullLongBacked   = not anchorExtreme and bullHasStats and bWilsL  > 50 and bNetMed  > 0
bearRecentBacked = not anchorExtreme and bearRecHas   and reWilsL > 50 and reNetMed > 0
bearLongBacked   = not anchorExtreme and bearHasStats and eWilsL  > 50 and eNetMed  > 0

// Edge clock — lean = recent net positive on a simple majority and a positive median net
bullRecentLean = not anchorExtreme and bullRecHas and rbWin >= 55 and rbNetMed > 0
bearRecentLean = not anchorExtreme and bearRecHas and reWin >= 55 and reNetMed > 0
if barstate.isconfirmed
    if bullRecentBacked
        edgeTimeBull := time
    if bearRecentBacked
        edgeTimeBear := time
    if bullRecentBacked or bullRecentLean
        leanTimeBull := time
    if bearRecentBacked or bearRecentLean
        leanTimeBear := time

// Last signal direction (for active alias)
var int lastSigDir = 0  // 1=bull -1=bear
if newBullPivot
    lastSigDir := 1
if newBearPivot
    lastSigDir := -1
bool lastSigBull = lastSigDir == 1

// ══════════════════════════════════════════════════════════
// § SIGNAL DOTS WITH WEIGHTED SIZING
// ══════════════════════════════════════════════════════════

// Leg-size based strength (relative to rolling distribution)
var float lastLegStrBull = 0.0
var float lastLegStrBear = 0.0

if newBullPivot and array.size(legSizesUp) > 0
    lastLegStrBull := array.get(legSizesUp, array.size(legSizesUp) - 1)
if newBearPivot and array.size(legSizesDn) > 0
    lastLegStrBear := array.get(legSizesDn, array.size(legSizesDn) - 1)

// Self-calibrating tier thresholds
bullP60 = array.size(strArrBull) >= 30 ? array.percentile_nearest_rank(strArrBull, 60) : 0.5
bullP90 = array.size(strArrBull) >= 30 ? array.percentile_nearest_rank(strArrBull, 90) : 2.0
bearP60 = array.size(strArrBear) >= 30 ? array.percentile_nearest_rank(strArrBear, 60) : 0.5
bearP90 = array.size(strArrBear) >= 30 ? array.percentile_nearest_rank(strArrBear, 90) : 2.0

// Push strength on new pivot
if newBullPivot
    array.push(strArrBull, lastLegStrBull)
    if array.size(strArrBull) > 300
        array.shift(strArrBull)
if newBearPivot
    array.push(strArrBear, lastLegStrBear)
    if array.size(strArrBear) > 300
        array.shift(strArrBear)

dotSizeStr(float str_, float p60, float p90) =>
    string sz = size.normal
    if str_ >= p90
        sz := size.huge
    else if str_ >= p60
        sz := size.large
    sz

dotTransp(float str_, float p60, float p90) =>
    float t = 28.0
    if str_ >= p90
        t := 0.0
    else if str_ >= p60
        t := 12.0
    t

// Verdict glyph — ● recent-backed · ◐ has stats but not backed · ○ gathering
verdictGlyph(bool rBacked, bool gathering) =>
    gathering ? "○" : rBacked ? "●" : "◐"

// Build tooltip text at signal time — excursion read of the legs that followed pivots like this
buildTip(string dir, float mfeMed, float maeP75, float rr, float netMed, float winR, float n, bool hasEdge, bool gathering, bool extreme) =>
    string verdict = ""
    if gathering
        verdict := "gathering — n=" + str.tostring(math.round(n))
    else if extreme
        verdict := "idealized anchor (pivot-extreme) — net is positive by construction (you anchored at the swing). The ceiling, not a tradeable edge; switch to Confirmation for the real read."
    else if hasEdge
        verdict := "net follow-through reliably positive over this history"
    else
        verdict := "no reliable net edge — net barely clears zero"
    string edgeLine = extreme ? "" : "\nEdge — net at +horizon: med " + str.tostring(netMed, "+0.00") + "% · " + str.tostring(winR, "0") + "% positive"
    dir + " pivot confirmed\nRun / risk (n=" + str.tostring(math.round(n)) + "): run +" + str.tostring(mfeMed, "0.00") + "% · heat p75 −" + str.tostring(maeP75, "0.00") + "% · R:R " + rrTxt(rr) + ":1" + edgeLine + "\n→ " + verdict

// Draw dots on pivot confirmation bars — clear of the pivot balloons when labels are on
dotOff = (i_showLabels ? 3.4 : 1.4) * atrVal
if i_showDots and i_probOn
    if newBullPivot and not na(newPivBx)
        szBull  = dotSizeStr(lastLegStrBull, bullP60, bullP90)
        trBull  = dotTransp(lastLegStrBull,  bullP60, bullP90)
        glyph   = (atLevel ? "◈" : "") + (anchorExtreme ? "·" : verdictGlyph(bullRecentBacked, not bullHasStats))
        tipStr  = buildTip("Bull", bMfeMed, bMaeP75, bRR, bNetMed, bWin, bN, bullLongBacked, not bullHasStats, anchorExtreme) + (atLevel ? "\n◈ at prior pivot level " + str.tostring(lvlPx, format.mintick) + " (" + str.tostring(lvlTouches) + " prior touch" + (lvlTouches > 1 ? "es" : "") + ") — tight invalidation: the level is fixed in advance. Geometry, not extra probability." : "")
        dotLbl  = label.new(newPivBx, newPivPx - dotOff, glyph, style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_gold, math.round(trBull)), size = szBull, tooltip = tipStr)
        array.push(dotLabelsBull, dotLbl)
        if array.size(dotLabelsBull) > 400
            label.delete(array.shift(dotLabelsBull))
    if newBearPivot and not na(newPivBx)
        szBear  = dotSizeStr(lastLegStrBear, bearP60, bearP90)
        trBear  = dotTransp(lastLegStrBear,  bearP60, bearP90)
        glyph   = (atLevel ? "◈" : "") + (anchorExtreme ? "·" : verdictGlyph(bearRecentBacked, not bearHasStats))
        tipStr  = buildTip("Bear", eMfeMed, eMaeP75, eRR, eNetMed, eWin, eN, bearLongBacked, not bearHasStats, anchorExtreme) + (atLevel ? "\n◈ at prior pivot level " + str.tostring(lvlPx, format.mintick) + " (" + str.tostring(lvlTouches) + " prior touch" + (lvlTouches > 1 ? "es" : "") + ") — tight invalidation: the level is fixed in advance. Geometry, not extra probability." : "")
        dotLbl  = label.new(newPivBx, newPivPx + dotOff, glyph, style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_cold, math.round(trBear)), size = szBear, tooltip = tipStr)
        array.push(dotLabelsBear, dotLbl)
        if array.size(dotLabelsBear) > 400
            label.delete(array.shift(dotLabelsBear))

// ══════════════════════════════════════════════════════════
// § MFE DISTRIBUTION (panel — favorable excursion of past legs)
// ══════════════════════════════════════════════════════════

// Panel parameters
var array<box>      atlasBoxes  = array.new<box>(0)
var polyline        atlasPoly   = na
var label           atlasGathLbl = na
var label           atlasMedLbl  = na
var label           atlasLiveLbl = na
var label           atlasZeroLbl = na
var line            atlasMedLine = na
var line            atlasLiveLine = na
var line            atlasZeroLine = na

// Panel geometry: docked top-right of the future space
// Use the active direction's leg-size array
actArr = lastSigBull ? mfeBull : mfeBear
actN   = array.size(actArr)

// Developing leg current size
devLegPct = not na(pPivotPrice) and pPivotPrice != 0 ? math.abs((pExtreme - pPivotPrice) / pPivotPrice * 100) : 0.0

// Developing leg percentile
devPercentile = 0.0
if actN > 0
    belowDev = 0
    for pi = 0 to actN - 1
        if array.get(actArr, pi) < devLegPct
            belowDev += 1
    devPercentile := belowDev / actN * 100

// Redraw atlas on last bar
if barstate.islast and i_probOn and i_panelOn
    // Cleanup
    if array.size(atlasBoxes) > 0
        for bi = 0 to array.size(atlasBoxes) - 1
            box.delete(array.get(atlasBoxes, bi))
    array.clear(atlasBoxes)
    if not na(atlasPoly)
        polyline.delete(atlasPoly)
        atlasPoly := na
    if not na(atlasGathLbl)
        label.delete(atlasGathLbl)
        atlasGathLbl := na
    if not na(atlasMedLbl)
        label.delete(atlasMedLbl)
        atlasMedLbl := na
    if not na(atlasLiveLbl)
        label.delete(atlasLiveLbl)
        atlasLiveLbl := na
    if not na(atlasZeroLbl)
        label.delete(atlasZeroLbl)
        atlasZeroLbl := na
    if not na(atlasMedLine)
        line.delete(atlasMedLine)
        atlasMedLine := na
    if not na(atlasLiveLine)
        line.delete(atlasLiveLine)
        atlasLiveLine := na
    if not na(atlasZeroLine)
        line.delete(atlasZeroLine)
        atlasZeroLine := na

    panelStartX = bar_index + 8
    nSlices     = 40
    sliceWidth  = 1
    panelBase   = 0.0
    panelHeight = 0.0

    // Determine panel y-scale using recent price range (overlay)
    rangeH   = rngHi50 - rngLo50
    panelBase   := rngHi50 + rangeH * 0.05
    panelHeight := rangeH * 0.45

    if actN < i_minSamp
        dirName = lastSigBull ? "up-legs" : "down-legs"
        atlasGathLbl := label.new(panelStartX + 20, panelBase + panelHeight * 0.5, "MFE · favorable run (" + dirName + ")\ngathering — n=" + str.tostring(actN), style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.silver, size = size.small)
    else
        // Compute KDE domain
        medVal  = array.median(actArr)
        stdVal  = array.stdev(actArr)
        halfBand = math.max(stdVal * 1.0, 0.01)
        // MFE is one-sided (≥0) and right-skewed — a symmetric ±σ window walls the left and clips
        // the long right tail. Give a small left margin and stretch the right to a high percentile.
        p95v    = array.percentile_nearest_rank(actArr, 95)
        domLo   = -0.35 * halfBand
        domHi   = math.max(medVal + 2.0 * halfBand, p95v * 1.10)
        domW    = domHi - domLo
        bw      = math.max(1.06 * nz(stdVal, halfBand) * math.pow(actN, -0.2), domW / nSlices)

        // KDE per slice
        densities = array.new<float>(nSlices, 0.0)
        maxD = 0.0
        for si = 0 to nSlices - 1
            xc = domLo + (si + 0.5) * domW / nSlices
            d  = 0.0
            for ki = 0 to actN - 1
                diff = (xc - array.get(actArr, ki)) / bw
                d += math.exp(-0.5 * diff * diff)
            array.set(densities, si, d)
            if d > maxD
                maxD := d

        // Normalise
        if maxD > 0
            for si = 0 to nSlices - 1
                array.set(densities, si, array.get(densities, si) / maxD)

        // Draw slice boxes
        for si = 0 to nSlices - 1
            normD = array.get(densities, si)
            if normD > 0.02
                xLeft  = panelStartX + si * sliceWidth
                xRight = xLeft + sliceWidth
                sliceH = normD * panelHeight
                // Three-layer vertical fade (strong at top = curve edge)
                heatPos = (si + 0.5) / nSlices
                c0 = heatCol(heatPos, 28, i_col_hot, i_col_cold)
                c1 = heatCol(heatPos, 55, i_col_hot, i_col_cold)
                c2 = heatCol(heatPos, 80, i_col_hot, i_col_cold)
                // Top segment 62–100% of height
                b0 = box.new(xLeft, panelBase + sliceH, xRight, panelBase + sliceH * 0.62, bgcolor = c0, border_color = na)
                // Middle 30–62%
                b1 = box.new(xLeft, panelBase + sliceH * 0.62, xRight, panelBase + sliceH * 0.30, bgcolor = c1, border_color = na)
                // Base 0–30%
                b2 = box.new(xLeft, panelBase + sliceH * 0.30, xRight, panelBase, bgcolor = c2, border_color = na)
                array.push(atlasBoxes, b0)
                array.push(atlasBoxes, b1)
                array.push(atlasBoxes, b2)

        // Gaussian overlay
        avgVal = array.avg(actArr)
        stdG   = nz(array.stdev(actArr), 0.01)
        polyPts = array.new<chart.point>(0)
        for gi = 0 to 24
            xc    = domLo + gi * domW / 24
            xPx   = panelStartX + math.round((xc - domLo) / domW * nSlices)
            gDens = math.exp(-0.5 * math.pow((xc - avgVal) / stdG, 2.0))
            yPx   = panelBase + gDens * panelHeight
            array.push(polyPts, chart.point.from_index(xPx, yPx))
        if array.size(polyPts) > 1
            atlasPoly := polyline.new(polyPts, curved = true, line_color = color.new(color.white, 45), line_width = 1)

        // Median marker
        medX   = panelStartX + math.round((medVal - domLo) / domW * nSlices)
        medLabel = (lastSigBull ? "bull · " : "bear · ") + "med " + str.tostring(medVal, "+0.00") + "%"
        atlasMedLine := line.new(medX, panelBase, medX, panelBase + panelHeight, color = color.new(color.rgb(224, 168, 0), 30), style = line.style_dashed, width = 1)
        atlasMedLbl  := label.new(medX, panelBase + panelHeight * 1.04, medLabel, style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.rgb(224, 168, 0), size = size.tiny)

        // Zero line (left edge if domain starts above 0)
        zeroX = panelStartX + math.round((0.0 - domLo) / domW * nSlices)
        if zeroX >= panelStartX and zeroX <= panelStartX + nSlices
            atlasZeroLine := line.new(zeroX, panelBase, zeroX, panelBase + panelHeight, color = color.new(color.gray, 50), style = line.style_dotted, width = 1)
            atlasZeroLbl  := label.new(zeroX, panelBase - panelHeight * 0.05, "0", style = label.style_label_center, color = color.new(color.black, 80), textcolor = color.silver, size = size.tiny)

        // Live developing-leg marker
        if devLegPct >= domLo and devLegPct <= domHi
            liveX = panelStartX + math.round((devLegPct - domLo) / domW * nSlices)
            atlasLiveLine := line.new(liveX, panelBase, liveX, panelBase + panelHeight * 0.70, color = color.new(color.white, 25), style = line.style_solid, width = 1)
            pctLabel = str.tostring(math.round(devPercentile)) + "th pct"
            atlasLiveLbl := label.new(liveX, panelBase + panelHeight * 0.72, "live " + str.tostring(devLegPct, "0.00") + "% · " + pctLabel, style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.white, size = size.tiny)

// ══════════════════════════════════════════════════════════
// § STOP / TARGET RAILS (excursion percentiles projected forward)
// ══════════════════════════════════════════════════════════

var line  railTgtMed  = na
var line  railTgtP75  = na
var line  railStop    = na
var label railTgtLbl  = na
var label railStopLbl = na

// Anchor reference = the live leg's start (most recent confirmed pivot)
var int   coneSigBar = na
var float coneSigPx  = na
var bool  coneIsBull = true

if newBullPivot
    coneSigBar := newPivBx
    coneSigPx  := newPivPx
    coneIsBull := true
if newBearPivot
    coneSigBar := newPivBx
    coneSigPx  := newPivPx
    coneIsBull := false

if barstate.islast and i_probOn and i_coneOn
    if not na(railTgtMed)
        line.delete(railTgtMed)
        railTgtMed := na
    if not na(railTgtP75)
        line.delete(railTgtP75)
        railTgtP75 := na
    if not na(railStop)
        line.delete(railStop)
        railStop := na
    if not na(railTgtLbl)
        label.delete(railTgtLbl)
        railTgtLbl := na
    if not na(railStopLbl)
        label.delete(railStopLbl)
        railStopLbl := na
    if not na(coneSigBar)
        rN      = coneIsBull ? bN : eN
        rMfeMed = coneIsBull ? bMfeMed : eMfeMed
        rMfeP75 = coneIsBull ? bMfeP75 : eMfeP75
        rMaeP90 = coneIsBull ? bMaeP90 : eMaeP90
        rRRv    = coneIsBull ? bRR : eRR
        if rN >= i_minSamp
            rAnchor    = coneIsBull ? liveBullAnchor : liveBearAnchor
            railAnchor = na(rAnchor) ? coneSigPx : rAnchor
            rX1     = bar_index
            rX2     = bar_index + i_horizon
            favSign = coneIsBull ? 1.0 : -1.0
            yTgtMed = railAnchor * (1 + favSign * rMfeMed / 100)
            yTgtP75 = railAnchor * (1 + favSign * rMfeP75 / 100)
            yStop   = railAnchor * (1 - favSign * rMaeP90 / 100)
            favCol  = coneIsBull ? i_dist_gold : i_dist_cold
            advCol  = coneIsBull ? i_dist_cold : i_dist_gold
            railTgtMed := line.new(rX1, yTgtMed, rX2, yTgtMed, color = color.new(favCol, 15), style = line.style_dashed, width = 1)
            railTgtP75 := line.new(rX1, yTgtP75, rX2, yTgtP75, color = color.new(favCol, 55), style = line.style_dotted, width = 1)
            railStop   := line.new(rX1, yStop,   rX2, yStop,   color = color.new(advCol, 25), style = line.style_dashed, width = 1)
            tgtTxt  = "target med +" + str.tostring(rMfeMed, "0.00") + "%  (p75 +" + str.tostring(rMfeP75, "0.00") + "%)  ·  R:R " + rrTxt(rRRv) + ":1  ·  n=" + str.tostring(math.round(rN))
            stopTxt = "stop p90 −" + str.tostring(rMaeP90, "0.00") + "%"
            railTgtLbl  := label.new(rX2, yTgtMed, tgtTxt, style = label.style_label_left, color = color.new(color.black, 35), textcolor = color.new(favCol, 10), size = size.tiny, tooltip = "Favorable excursion (MFE): how far past legs from this anchor ran in the leg direction. Median + 75th-percentile target. Descriptive of this chart's past legs, not a forecast.")
            railStopLbl := label.new(rX2, yStop, stopTxt, style = label.style_label_left, color = color.new(color.black, 35), textcolor = color.new(advCol, 10), size = size.tiny, tooltip = "Adverse excursion (MAE): how far price moved against the leg after the anchor. This rail is the 90th-percentile heat — a stop beyond it survived the normal adverse move on ~90% of past legs. The MEDIAN heat is ~0 (most entries take no drawdown below them); the real risk lives in this tail. Past legs, not a forecast.")

// ══════════════════════════════════════════════════════════
// § MINI-READOUT (future-space, bottom-right)
// ══════════════════════════════════════════════════════════

var array<label> readoutLabels = array.new<label>(0)

// Format edge clock
edgeClockStr(int t) =>
    string r = "—"
    if not na(t)
        diffMs = timenow - t
        diffMn = math.floor(diffMs / 60000)
        if diffMn < 60
            r := "now"
        else if diffMn < 2880
            r := str.tostring(math.floor(diffMn / 60)) + "h"
        else
            r := str.tostring(math.floor(diffMn / 1440)) + "d"
    r

// Read verdict sentence (5 tiers)
readVerdict(bool rBacked, bool lBacked, bool rHas, float rRR, float rNetMed, float rN) =>
    string v = ""
    if not rHas
        v := "gathering — n=" + str.tostring(math.round(rN))
    else if rBacked and lBacked
        v := "recent + long-run: net follow-through reliably positive (R:R " + rrTxt(rRR) + ":1)"
    else if rBacked and not lBacked
        v := "recent legs back it (R:R " + rrTxt(rRR) + ":1) — long-run mixed"
    else if not rBacked and rNetMed > 0
        v := "recent net leans positive (med " + str.tostring(rNetMed, "+0.00") + "%) — building, not yet evidence"
    else if not rBacked and lBacked
        v := "long-run backed, but recent legs cooled"
    else
        v := "no reliable net edge here — thin"
    v

if barstate.islast and i_probOn and i_readoutOn
    if array.size(readoutLabels) > 0
        for ri = 0 to array.size(readoutLabels) - 1
            label.delete(array.get(readoutLabels, ri))
    array.clear(readoutLabels)

    // Anchor the readout below the atlas panel
    rangeH2   = rngHi50 - rngLo50
    rdBaseY   = rngLo50 - rangeH2 * 0.05
    rdStep    = rangeH2 * 0.12
    rdX       = bar_index + i_horizon + 26

    // Row 0: state
    dirTxt   = pDir == 1 ? "up" : "down"
    structTxt = structDir == 1 ? "structure ↑" : structDir == -1 ? "structure ↓" : "structure —"
    row0Txt  = "ZigZag · " + dirTxt + " leg · " + structTxt
    row0Lbl  = label.new(rdX, rdBaseY, row0Txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.white, size = size.normal)
    array.push(readoutLabels, row0Lbl)

    // Row 1: context
    devPctTxt = str.tostring(devLegPct, "0.00") + "% · " + str.tostring(math.round(devPercentile)) + "th pct of past runs"
    row1Txt  = "Developing leg: " + devPctTxt
    row1Col  = pDir == 1 ? i_dist_gold : i_dist_cold
    row1Lbl  = label.new(rdX, rdBaseY - rdStep, row1Txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(row1Col, 10), size = size.small)
    array.push(readoutLabels, row1Lbl)

    // Row 2: bull stats
    string row2Txt = ""
    if bullHasStats
        row2Txt := "Up-legs (n=" + str.tostring(math.round(bN)) + "):  run +" + str.tostring(bMfeMed, "0.00") + "%  (p75 +" + str.tostring(bMfeP75, "0.00") + "%)  ·  heat p75 −" + str.tostring(bMaeP75, "0.00") + "%  ·  R:R " + rrTxt(bRR) + ":1"
    else
        row2Txt := "Up-legs: gathering — n=" + str.tostring(math.round(bN))
    row2Lbl = label.new(rdX, rdBaseY - rdStep * 2, row2Txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(i_dist_gold, 10), size = size.small)
    array.push(readoutLabels, row2Lbl)

    // Row 3: bear stats
    string row3Txt = ""
    if bearHasStats
        row3Txt := "Down-legs (n=" + str.tostring(math.round(eN)) + "):  run +" + str.tostring(eMfeMed, "0.00") + "%  (p75 +" + str.tostring(eMfeP75, "0.00") + "%)  ·  heat p75 −" + str.tostring(eMaeP75, "0.00") + "%  ·  R:R " + rrTxt(eRR) + ":1"
    else
        row3Txt := "Down-legs: gathering — n=" + str.tostring(math.round(eN))
    row3Lbl = label.new(rdX, rdBaseY - rdStep * 3, row3Txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(i_dist_cold, 10), size = size.small)
    array.push(readoutLabels, row3Lbl)

    // Row 4: Read
    isBull4   = lastSigDir == 1
    rBacked4  = isBull4 ? bullRecentBacked : bearRecentBacked
    lBacked4  = isBull4 ? bullLongBacked   : bearLongBacked
    rHas4     = isBull4 ? bullRecHas       : bearRecHas
    rRR4      = isBull4 ? rbRR     : reRR
    rNetMed4  = isBull4 ? rbNetMed : reNetMed
    rN4       = isBull4 ? rbN      : reN
    verdict4  = anchorExtreme ? "idealized anchor (pivot-extreme) — net is positive by construction; this is the ceiling, not an edge. Switch to Confirmation for the tradeable read." : readVerdict(rBacked4, lBacked4, rHas4, rRR4, rNetMed4, rN4)
    sigAgoTxt = na(coneSigBar) ? "no signal yet" : str.tostring(bar_index - coneSigBar) + "b ago"
    row4Txt   = "Read: pivot " + sigAgoTxt + " — " + verdict4
    row4Col   = isBull4 ? color.new(i_dist_gold, 10) : color.new(i_dist_cold, 10)
    row4Lbl   = label.new(rdX, rdBaseY - rdStep * 4, row4Txt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = row4Col, size = size.small)
    array.push(readoutLabels, row4Lbl)

    // Row 5: edge clock + footer
    eclockTxt = anchorExtreme ? "Edge clock — n/a in pivot-extreme (idealized anchor)" : "Edge last seen — bull ●" + edgeClockStr(edgeTimeBull) + " ◐" + edgeClockStr(leanTimeBull) + " · bear ●" + edgeClockStr(edgeTimeBear) + " ◐" + edgeClockStr(leanTimeBear)
    row5Lbl   = label.new(rdX, rdBaseY - rdStep * 5, eclockTxt, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.silver, size = size.small, tooltip = "● last time recent form was Wilson-backed · ◐ last time it at least leaned (≥55% and median > 0). A fresh ◐ next to an old ● = something building, not yet evidence.")
    array.push(readoutLabels, row5Lbl)

    // Row 6: footer
    row6Lbl = label.new(rdX, rdBaseY - rdStep * 6, "Essentials · past pivots on this chart, not a prediction", style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(color.silver, 40), size = size.tiny)
    array.push(readoutLabels, row6Lbl)

// ══════════════════════════════════════════════════════════
// § HTF ZIGZAG (display only)
// ══════════════════════════════════════════════════════════

// Same ATR-scaled state machine on completed HTF bars ([1] + lookahead_off = non-repainting).
// Thin dotted silver overlay — context only, it never filters signals.
// Auto HTF = two rungs up the ladder (simple-string ternary, like the MTF badges); else manual.
htf = i_htfAuto ? effMtf2 : i_htf
[hHigh, hLow, hClose, hAtr] = request.security(syminfo.tickerid, htf, [high[1], low[1], close[1], ta.atr(i_atrLen)[1]], lookahead = barmerge.lookahead_off)

var int   hDir    = 0
var float hExt    = na
var int   hExtBar = na
var float hPivPx  = na
var int   hPivBar = na
var array<line> htfLegs = array.new<line>(0)
var line  htfDevLine = na
var label htfTagLbl  = na

hThresh = i_devMult * hAtr

if i_htfOn and not na(hAtr) and not na(hHigh)
    if hDir == 0
        hDir    := 1
        hExt    := hHigh
        hExtBar := bar_index
        hPivPx  := hLow
        hPivBar := bar_index
    if hDir == 1
        if hHigh > hExt
            hExt    := hHigh
            hExtBar := bar_index
        if (hExt - hClose) >= hThresh
            hLeg = line.new(hPivBar, hPivPx, hExtBar, hExt, color = color.new(color.silver, 35), width = 2, style = line.style_dotted)
            array.push(htfLegs, hLeg)
            if array.size(htfLegs) > 30
                line.delete(array.shift(htfLegs))
            hPivPx  := hExt
            hPivBar := hExtBar
            hDir    := -1
            hExt    := hLow
            hExtBar := bar_index
    else if hDir == -1
        if hLow < hExt
            hExt    := hLow
            hExtBar := bar_index
        if (hClose - hExt) >= hThresh
            hLeg = line.new(hPivBar, hPivPx, hExtBar, hExt, color = color.new(color.silver, 35), width = 2, style = line.style_dotted)
            array.push(htfLegs, hLeg)
            if array.size(htfLegs) > 30
                line.delete(array.shift(htfLegs))
            hPivPx  := hExt
            hPivBar := hExtBar
            hDir    := 1
            hExt    := hHigh
            hExtBar := bar_index
    // HTF developing leg + timeframe tag
    if barstate.islast
        if not na(htfDevLine)
            line.delete(htfDevLine)
        if not na(htfTagLbl)
            label.delete(htfTagLbl)
        htfDevLine := line.new(hPivBar, hPivPx, hExtBar, hExt, color = color.new(color.silver, 55), width = 1, style = line.style_dotted)
        htfTagLbl  := label.new(hExtBar, hExt, "HTF " + tfNice(htf), style = label.style_label_left, color = color.new(color.black, 60), textcolor = color.new(color.silver, 20), size = size.tiny, tooltip = "Higher-timeframe ZigZag (" + tfNice(htf) + ") — same ATR-scaled method on completed HTF bars. Display only, never filters signals.")

// ══════════════════════════════════════════════════════════
// § ALERTS
// ══════════════════════════════════════════════════════════

bullPivotAlert = newBullPivot and barstate.isconfirmed
bearPivotAlert = newBearPivot and barstate.isconfirmed

bullEvBacked = bullPivotAlert and bullRecentBacked
bearEvBacked = bearPivotAlert and bearRecentBacked

bullStrong   = bullPivotAlert and array.size(strArrBull) >= 30 and lastLegStrBull >= array.percentile_nearest_rank(strArrBull, 90)
bearStrong   = bearPivotAlert and array.size(strArrBear) >= 30 and lastLegStrBear >= array.percentile_nearest_rank(strArrBear, 90)

alertcondition(bullPivotAlert, "ZigZag Confluence: Swing Low Confirmed", "ZigZag Confluence [P]: Swing low pivot confirmed — new up-leg begins. Bar-close signal, non-repainting.")
alertcondition(bearPivotAlert, "ZigZag Confluence: Swing High Confirmed", "ZigZag Confluence [P]: Swing high pivot confirmed — new down-leg begins. Bar-close signal, non-repainting.")
alertcondition(bullEvBacked, "ZigZag Confluence: Bull Pivot (history-backed)", "ZigZag Confluence [P]: Swing low confirmed — recent up-legs reliably ran past their heat (favorable R:R) on this chart. Past legs, not a prediction.")
alertcondition(bearEvBacked, "ZigZag Confluence: Bear Pivot (history-backed)", "ZigZag Confluence [P]: Swing high confirmed — recent down-legs reliably ran past their heat (favorable R:R) on this chart. Past legs, not a prediction.")
alertcondition(bullStrong, "ZigZag Confluence: Strong Swing Low (90th pct leg)", "ZigZag Confluence [P]: Swing low confirmed with a 90th-percentile leg size. Past signals, not a prediction.")
alertcondition(bearStrong, "ZigZag Confluence: Strong Swing High (90th pct leg)", "ZigZag Confluence [P]: Swing high confirmed with a 90th-percentile leg size. Past signals, not a prediction.")
alertcondition(bullEvBacked and bullStrong, "ZigZag Confluence: Strong Bull Pivot (history-backed)", "ZigZag Confluence [P]: Strong swing low, history-backed. Past signals, not a prediction.")
alertcondition(bearEvBacked and bearStrong, "ZigZag Confluence: Strong Bear Pivot (history-backed)", "ZigZag Confluence [P]: Strong swing high, history-backed. Past signals, not a prediction.")
alertcondition(bosUpEvt, "ZigZag Confluence: BOS Up", "ZigZag Confluence [P]: Break of Structure up — close above the last confirmed swing high. Bar-close vs a pre-fixed level, non-repainting.")
alertcondition(bosDnEvt, "ZigZag Confluence: BOS Down", "ZigZag Confluence [P]: Break of Structure down — close below the last confirmed swing low. Bar-close vs a pre-fixed level, non-repainting.")
alertcondition(chochUpEvt, "ZigZag Confluence: CHoCH Up", "ZigZag Confluence [P]: Change of Character up — close above the last lower high while the structure was down. Potential reversal; bar-close vs a pre-fixed level, non-repainting.")
alertcondition(chochDnEvt, "ZigZag Confluence: CHoCH Down", "ZigZag Confluence [P]: Change of Character down — close below the last higher low while the structure was up. Potential reversal; bar-close vs a pre-fixed level, non-repainting.")
pivAtLvlBull = newBullPivot and atLevel and barstate.isconfirmed
pivAtLvlBear = newBearPivot and atLevel and barstate.isconfirmed
alertcondition(pivAtLvlBull, "ZigZag Confluence: Bull Pivot at Prior Level", "ZigZag Confluence [P]: Swing low confirmed at a prior pivot level — tight, pre-fixed invalidation. Geometry, not a prediction.")
alertcondition(pivAtLvlBear, "ZigZag Confluence: Bear Pivot at Prior Level", "ZigZag Confluence [P]: Swing high confirmed at a prior pivot level — tight, pre-fixed invalidation. Geometry, not a prediction.")
````
