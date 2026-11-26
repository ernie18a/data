# Delta Profile  Multi-Anchor , Footprint Imbalance & Whale Tiers

- url: https://www.tradingview.com/script/A60uKbTq-Delta-Profile-Multi-Anchor-Footprint-Imbalance-Whale-Tiers/
- type: indicator
- pine_id: PUB;0d0a9da1461847e3a57abeac71cbf5ed
- version: 7.0

## Description

█ OVERVIEW

Delta Profile draws several order-flow DELTA profiles at once — one per higher-timeframe anchor (session / week / month) — each split buy-vs-sell at every price row, so you can see WHERE aggressive delta transacted across horizons simultaneously and how that footprint is migrating. Where a conventional volume profile is volume-native and shows one anchor at a time, this is delta-native and multi-anchor, and it shows a Delta-POC (where net delta peaks) distinct from the Volume-POC (where volume peaks) — their disagreement locates absorption and trapped flow. It asserts no signal and no win-rate; it is an anatomy view.

█ HOW IT WORKS

Intrabars — one lower-timeframe stream (request.security_lower_tf) supplies intrabar OHLCV for every anchor.
Trade side — each intrabar is split buy vs sell by a selectable classifier: BVC-Normal (normal-CDF of the standardized sub-bar return, default), BVC-Student-t (fatter-tailed, opt-in), Tick (sign of close−open), or Geometry (close position in range). All are OHLCV estimates, not the true tape; the classifier in force is shown.
Concurrent anchors — up to four higher-timeframe anchors each accumulate the same confirmed intrabars into a fixed-tick, price-keyed map (buy / sell / largest-print per level), resetting when their own period rolls. Anchor D can instead anchor once from a date you drag on the chart.
Reads per anchor — Volume-POC and Delta-POC (shown distinctly); the 70% Value Area; HVN / LVN nodes; stacked diagonal-imbalance runs (a row's aggressive buys ≥ R× the resting sells one row below, ≥ N rows stacked); absorption rows (strong volume, near-zero net delta at an extreme); and whale tiers (largest single prints, percentile-ranked 75/90/97, dotted at their row).
Naked Delta-POC magnets — each completed session's Delta-POC is kept until price trades through it; the nearest untested one above and below is drawn on price.
Lean meter, migration, CVD — a per-anchor net-delta lean meter; a migration arrow (is the Delta-POC drifting up or down vs the prior period); an optional session-anchored CVD strip rescaled below price; and CVD pivot-divergence markers (price makes a higher high while CVD makes a lower high = bearish, and the mirror = bullish).
Reject calibration (honesty layer) — naked Delta-POCs are generated from a dedicated Session timeframe (independent of the display anchors). After price tags one, the script forward-tests whether price REJECTS (turns back against the approach by calK·ATR) before CONTINUING through, and compares that to the matched unconditional reject-vs-continue base rate: reject% (n, Wilson 95% lower bound) vs base% → edge. Past-only, non-repaint, no verdict.

█ HOW TO USE

Read the anchors together. Agreement is several horizons showing the same delta colour, the same lean direction and Delta-POC drifting the same way; disagreement between the session and the higher anchor is developing rotation. When the Delta-POC and Volume-POC separate on the same profile, aggressors won at a different price than where the crowd traded — often absorption or a trapped move. Stacked-imbalance zones mark diagonal aggression; naked Delta-POC magnets mark untested levels price may be drawn back to; CVD divergence flags price/flow disagreement at swings. The reaction-calibration line tells you, honestly and past-only, whether naked-dPOC tags have actually preceded larger-than-random moves here — and shows nothing when the sample is small. The dashboard defaults to Compact; switch it to Pro for the per-anchor column detail. This is a study for context and location; it emits no entries.

█ INPUTS

01 · Data & Trade-Side — LTF granularity, classifier, BVC sharpness, ticks-per-level, display rows.
02–05 · Anchors A–D — enable, timeframe, label and Mode for each: HTF (resets each period), Composite (never resets, accumulates over loaded history), or From Date (anchors once at the shared drag timestamp).
06 · Profile — width, gap, offset; POC / Value Area toggle and %, fade-outside-VA, HVN/LVN, lean meter, naked magnets.
07 · Imbalance & Absorption — show, diagonal ratio R, rows-to-stack N, absorption threshold.
08 · Whale Tiers — three percentile thresholds.
09 · Migration & CVD — migration arrow; optional CVD strip and height; CVD pivot-divergence and pivot length.
10 · Microstructure Links (optional) — map an external Toxicity / Fragility export to annotate flow quality (never recomputed).
11 · Display — dashboard detail (Compact default / Pro), position.
12 · Exports — running CVD, POCs, VA, naked levels, migration, reaction edge to the Data Window.
13 · Calibration — reject size (×ATR), horizon, and the Session timeframe that generates naked Delta-POCs (independent of the display anchors).
Style — Auto / Dark / Light theme.

█ HONESTY & LIMITATIONS

Descriptive, not predictive. Profiles summarise where reconstructed aggressive volume transacted on visible history — no execution costs, no backtest, no promise. Trade side is an OHLCV estimate (BVC / tick / geometry), not a Level-2 book; on symbols with no volume it cannot function. The reject calibration is a past-only, first-touch two-barrier (reject-vs-continue) forward test against a matched base rate with a Wilson lower bound; a small sample is discounted automatically and no edge shown means honest, not broken. Non-repaint by construction: intrabars are aggregated only on confirmed bars, profiles are drawn from confirmed history, divergences fire on confirmed pivots, calibration events resolve only after the horizon, and the render recomputes once per confirmed bar. For runtime the script processes the most recent ~5000 bars, and turning off Calibration removes its overhead; very high anchors on a fine lower timeframe (or Composite mode over long history) can still be heavy — raise ticks-per-level, coarsen the LTF granularity, or disable an anchor. It prints no verdict and no win-rate.

█ ORIGINALITY

One coherent object — the aggressive-delta auction viewed across several horizons at once. It is deliberately distinct from a conventional volume profile (this is delta-native and draws multiple anchors concurrently), from a per-bar footprint engine (this is a persistent multi-horizon anatomy that asserts no verdict), and it introduces two reads a plain profile does not: the Delta-POC vs Volume-POC split, and whale-print tiering on the profile. It can optionally consume external toxicity / fragility exports rather than recomputing microstructure, keeping it a single focused tool. Every block was written from scratch; the components feed one view (where did aggressive delta transact, across horizons) rather than being independent indicators stapled together.

█ CREDITS

Market / auction profile (POC / Value Area) — Steidlmayer / Market Profile.
Bulk Volume Classification — Easley, López de Prado & O'Hara.
Trade-side tick rule — Lee & Ready (1991).
Footprint stacked (diagonal) imbalance — order-flow / footprint practice.
Cumulative Volume Delta — order-flow literature.
Wilson score interval — Wilson (1927).
Code written from scratch; no external script reused.

This script is for analysis and education. It is not financial advice.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ═════════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                                  MPL-2.0
//  Multi-Anchor Delta Profile — Stacked-Imbalance, Whale Tiers & Signal Engine
//  shorttitle: MADP                                                Pine Script v6
// -----------------------------------------------------------------------------
//  v2.13 (SAFE-ZONE UX + LIBRARY CONSOLIDATION): a trailing-stop cushion read + marker legend, adapted
//    from RedK's Multi-Modal Trailing Stop, plus a bit-identical library consolidation.
//    (1) SAFE ZONE — a LINE + solid FILL shading the gap between PRICE and the ATR trailing stop,
//    coloured by the CURRENT cushion: 🟢 green = Safe · 🟡 amber = Watch · 🔴 red = Critical (price near the
//    stop). The fill itself tells you the live risk — it is NOT a fixed red band. Measured in ATR so it
//    reads the same on any symbol (group 12b). A "Stop zone" dashboard line (orb + word + X.XXx ATR to the
//    stop, tick-precise) and a "Stop zone CRITICAL" alert.
//    (2) RedK-STYLE FLIP MARKER — the trailing-stop flip prints a trend-coloured ▲/▼ FLIP tag with the
//    conviction number, anchored ON the stop line it belongs to.
//    (3) MARKER LEGEND (KEY) — a compact on-chart key explaining every mark (group 09); table-only, no plots.
//    (4) LIBRARY CONSOLIDATION (no numerical change — each swap verified formula-identical): efficiency
//    ratio → cal.efficiencyRatio; Wilson interval → cal.wilsonHalf; the time-of-day volume baseline →
//    sess.slotRatio. Imports ml_calib/2 · ml_session/2 (no security calls). To keep the 64-plot budget,
//    six low-value EXP exports were trimmed (BuyPress, TotVol, VSABias, Absorb, MTFFlow, FlowSpeed); the
//    core + MADP exports are untouched. The engine math, signals and honest-stats are UNCHANGED.
//    (Deferred: input active=/display gating across all groups for a decluttered settings panel.)
//  v2.12 (SIGNAL-QUALITY REBALANCE): the fused conviction used to MULTIPLY seven quality factors (each
//    < 1), so the product collapsed toward zero and nearly every signal read "weak" even where its
//    forward expectancy was clearly positive. Conviction now combines those factors as a WEIGHTED-
//    AVERAGE penalty (impact & toxicity weigh most) blended with the worst single factor and floored,
//    so a soft penalty no longer annihilates strength while a genuinely bad environment still pulls it
//    down — strength now tracks real edge. Also: (a) Kyle-λ R² is the impact factor by default (the
//    more principled price-impact measure); (b) log-odds gain default 1.0→1.5 so strong ladder
//    alignment reads strong sooner; (c) chart-TF pressure triangles default ON. The direction engine,
//    the forward-test and the honest-stats are unchanged — this fixes how conviction is SCORED, so good
//    setups stop being hidden. (Expectancy stays positive on 2m+; a 39–43% win rate with positive R is
//    normal for a trailing-exit trend read, not a defect.) v2.12.1 — 1m flips now fire by default too
//    (the "Suppress flips on sub-2-minute charts" switch defaults OFF); 1m is noisier, so lean on the
//    higher-conviction flips there and watch the Expectancy row.
// -----------------------------------------------------------------------------
//  v2.11 (PER-RUNG LADDER COLOUR): the FLOW alignment and the MTF stack now render as a compact strip
//    with each rung coloured by its OWN direction (green up / red down / grey neutral) — a single table
//    cell can't hold multiple colours, so a net-red FLOW row used to show an up-rung in red. The main
//    panel keeps every text readout (decision, pro reads, MADP anchors, verdict) in one place; the
//    colour-coded ladder sits in its own small strip (group 13 · "Ladder strip position") so it can be
//    docked next to the panel. No engine/signal math changed — signal conviction reads weak across TFs
//    only because the current tape is TOXIC (toxicity halves conviction), and 1m shows no flip because
//    sub-2-minute flips are suppressed by design (group 13 · "Suppress flips on sub-2-minute charts").
// -----------------------------------------------------------------------------
//  v2.10 (ONE PANEL + cleanup): the four separate floating tables (signal dashboard, MTF-alignment
//    strip, MTF-stack legend, MADP anchor table) are consolidated into a SINGLE panel. Compact (default)
//    shows the decision essentials + the FLOW ladder + the MTF stack + the MADP anchors as folded-in
//    rows; Pro adds every read. The panel renders after the MADP accumulation so the anchor Net-Δ is
//    current (the old separate table lagged one bar on some paths). Dead code removed (two unused
//    position inputs, the MTF-strip/stack/MADP table objects and a helper); one table object instead of
//    four. Position follows the single "Dashboard position" (group 09). No engine/signal math changed.
// -----------------------------------------------------------------------------
//  v2.9 (CLASSIFICATION ACCURACY — research pass): (1) BVC now defaults to a low-df STUDENT-T split
//    (group 01), which classifies fat-tailed index/futures returns more accurately than the Normal
//    (Easley/López de Prado/O'Hara; Panayides/Shohfi/Smith) — Normal still selectable. This does not
//    change the shipped NIFTY output because the default classifier is the Intrabar Tick Rule.
//    (2) OPT-IN true TICK RULE for sub-bar signing (group 01) — the genuine Lee-Ready tick test (sign
//    by the change from the prior sub-bar close, carry on ties) vs the current close-vs-open; default
//    stays close-vs-open so NIFTY is unchanged. (3) Kyle-λ R² (explained price variance) is now shown
//    on the Impact row, and optionally drives conviction (group 16, default OFF → output unchanged).
//    (4) Hurst gets a small-sample / heavy-tail guard (Baruník & Kristoufek): it reads 'warming' until
//    ~2× its window has formed instead of printing an unreliable value. All NIFTY defaults preserved.
// -----------------------------------------------------------------------------
//  v2.8 (ANY ASSET CLASS): a single new "Asset class — volume" switch (group 01, default Chart)
//    makes the whole engine asset-agnostic. Chart = this instrument's own OHLCV (NIFTY-default,
//    unchanged). External (futures) reconstructs the delta spine from a matching futures symbol and
//    overlays the read here — so the delta, CVD, VPIN toxicity, size-split, absorption, MTF flow, the
//    MADP profile wall and the whale prints all keep working on a volume-less or thin chart (a cash
//    index, spot FX, some stocks). Every flow/volume dispatch follows the selected symbol; the price
//    you SEE, the ATR trailing stop and the trade levels always stay on the chart instrument. Every
//    default is set for NIFTY — nothing changes until you switch assets.
// -----------------------------------------------------------------------------
//  WHAT THIS IS  (major upgrade — the original MADP is fully intact, plus a new engine)
//    MADP began as a picture-in-picture WALL of order-flow DELTA profiles: several
//    higher-timeframe anchors (e.g. 1H / 4H / Day) side by side, each reconstructed
//    from lower-timeframe intrabars, with POC / Value Area, stacked diagonal
//    imbalance and whale tiers. That anatomy view — WHERE aggressive flow
//    transacted, across horizons at once — is fully intact and still one click away.
//
//    This version adds an optional SIGNAL ENGINE: the same intrabar delta substrate,
//    now also read as a cross-timeframe conviction with forward self-calibration, a
//    self-muting edge-gate, and a full on-chart trade plan (Trigger / SL / TP1 / TP2)
//    that latches until it resolves. The profile answers WHERE; the engine answers
//    WHICH SIDE and HOW BACKED — from one shared, honest delta reconstruction.
//
//  v2.7 (MTF stack): a new optional overlay (group 20, default OFF) draws each of
//    1 / 2 / 3 / 5 / 15 / 30 / 60m as its OWN ATR trailing stop plus a marker when that
//    timeframe's order flow flips — all on one chart, colour-coded per timeframe. Higher-
//    timeframes-only by construction (a timeframe faster than the chart can't be plotted),
//    so view on 1–5m to see the full stack; faster rungs are skipped. One security call per
//    timeframe (bundled), additive and default-off — the existing engine is untouched.
//
//  v2.6 (HTF-anchored trailing stop): the ATR trailing line can now trail on a HIGHER timeframe (group
//    12 · "Trail ATR timeframe": Chart / 2× / 3× / 5× / Custom) so the stop widens to the timeframe the
//    signal lives on — lower-TF noise no longer knocks you out while the higher-TF structure that made
//    the signal is intact. Still a single line, never a band. The trade-plan SL that rides the trail
//    (group 19) inherits it. Default Chart (unchanged behaviour).
//
//  v2.5 (signal-engine — validated & re-yardsticked): on-chart testing showed the aligned flip is
//    anti-predictive on a fixed 1-ATR target (17–33% hit) but POSITIVE expectancy under the trailing
//    exit it actually ships (+0.10 to +0.21 R on 3m+, negative only on 1m). So EXPECTANCY IN R (trailing
//    exit) is now the primary honesty metric on the dashboard; the misleading 1:1 fixed-target edge is
//    demoted to a context line. The edge-gate keys off average R (not win-rate, since a profitable
//    trend-ride wins < 50%). Flips are suppressed on sub-2-minute charts (group 13). Regime split was
//    inconsistent, so no regime gate was added — the trailing exit is the edge.
//
//  v2.1 (signal-engine bugfix): the edge-gate no longer dead-locks. Its rolling win-rate now learns from
//    the PRE-mute (raw) signal, so a muted side keeps accumulating resolved samples and can recover above
//    the un-mute ceiling — previously a muted side fired nothing, froze its own win-rate and stayed muted
//    forever. The edge-gate is also now OFF by default (opt-in): the engine fires normally and the
//    scoreboard reports; turn the gate on to have it auto-suppress a genuinely underperforming side.
//
//  VIEW MODE (group 00) — one switch decides what draws:
//    • "Both"            → the wall AND the engine together. The DEFAULT — everything on.
//    • "Profile (MADP)"  → the original wall + MADP dashboard ONLY (the pre-upgrade look).
//    • "Signal engine"   → the conviction/plan/calibration view only, on a clean chart.
//    Every sub-feature keeps its own toggle; the mode is just the master gate.
//
//  ═══ SIGNAL ENGINE — build history (the optional layer's evolution) ═════════════
//  The spine is unchanged; read-together layers are added so one script does what a whole
//  footprint suite does — reconstructed honestly from intrabar volume, no tick feed. The design
//  principle is SIGNAL OVER NOISE: a single bar's delta is noise, so the headline read is
//  cross-timeframe AGREEMENT, not per-bar marks.
//    1. MTF ORDER-FLOW ALIGNMENT (headline) — net buying pressure is measured on a FIXED ladder
//       of timeframes (default 1/3/5/15/60/240) and only when enough of them AGREE is the flow
//       meaningful. Shown as a 6-cell strip, a dashboard row, and a sparse on-price "aligned flip"
//       signal. The chart-TF pressure triangles are GATED to print only when the ladder agrees.
//    2. FLOW DRIVER — a fast signal line + slow confirmation line over the pressure-z column;
//       their crossover is the broad shift in control. Impulse dots mark rare delta-accel bursts.
//    3. EXHAUSTION ZONES — the pane background lights when pressure is beyond its own high/low
//       percentile (climactic, not merely strong) — the capitulation / blow-off filter.
//    4. FLOW-vs-PRICE DIVERGENCE (opt-in) — price makes a new extreme the cumulative delta does
//       not confirm → an early-warning marker + dashboard state.
//  Plus a complete trade loop: an ATR trailing stop drawn on price, and a compact honest-stats
//  scoreboard (Wilson-floored hit-rate + edge over base rate, per side) baked into the dashboard.
//  All layers consume the SAME spine — no duplicated delta, no correlated double-counting.
//  (Per-bar delta bubbles were removed in this build — they marked every bar and drowned the read;
//   the MTF alignment strip is the clean replacement.)
//
//  Wave F (this build · v1.3): TWO precision filters fold in the best of the sibling flow scripts —
//    (1) FLOW TOXICITY (VPIN volume-clock, from the VPIN Flow-Toxicity Oscillator): equal-VOLUME
//        buckets grade how one-sided / informed the flow is (0–100); MTF flips are optionally HELD
//        while toxicity is extreme (the whipsaw regime).  (2) CVD STRUCTURE CHANNEL (from
//        Meridian-Flow): a regression channel on the session-anchored cumulative delta with confirmed
//        breakouts; an MTF aligned flip is only shown when the CVD channel ALSO broke in the same
//        direction within a window. Net effect: the headline flip now needs cross-timeframe agreement
//        AND a real break of CVD structure AND non-toxic flow — rarer, and materially more precise.
//        Groups 14 & 15; both can be turned off to reproduce v1.2 behaviour.
//
//  Wave G (this build · v1.4): the decision layer. (1) SELF-VALIDATING SCOREBOARD — the forward
//    calibration now grades the confluence-gated MTF flip actually shown on the chart (group 07 ·
//    "Grade which signal"), so the hit-rate / edge ✓ measure what you trade, with a Wilson ± interval.
//    (2) PRICE IMPACT (Kyle λ, inlined from Volume-Flow Pressure) — flow-move-per-unit read, 0–100.
//    (3) REVERSAL vs CONTINUATION — each flip is tagged fade (into exhaustion / absorbed flow) or
//    trend-follow (flow moving price). (4) REGIME + WHAT-TO-DO — a compact regime read and one
//    plain-language directive (best-practice from the Order-Flow Profile / OFI Regime panels), enough
//    to retire the standalone OFI Regime Engine for daily use. All group 16; dashboard-only (no plots).
//
//  Wave H (this build · v1.5): OVERLAY EDITION. The indicator now draws ON PRICE (overlay = true) —
//    the z-scored pressure oscillator, its signal/confirmation lines and impulse dots (which needed a
//    separate pane) are removed; the pressure read lives on the dashboard and drives the on-price
//    signals. On price: the MTF aligned-flip triangles (the signal), the ATR trailing stop, exhaustion
//    background zones, optional flow bar-colouring — nothing needing a z-axis. And the MTF ladder now
//    ANCHORS to the chart timeframe by default (group 13) so signals are precise to whatever TF you
//    view: chart TF · ×3 · ×5 · ×15 · ×60 · ×240, each snapped to the nearest standard TF, capped at
//    Daily. On a 1m chart this is the classic 1/3/5/15/60/240; on 5m it is 5/15/30/120/D/D; etc. The
//    delta spine, calibration, confluence gate, toxicity and decision layer are unchanged.
//
//  Wave I (this build · v1.6): PRECISION via one FUSED CONVICTION (borrowed from Ctrl+Path & the MTF
//    OrderFlow Cockpit, which both decide act/no-act from a single probability). The aligned flip is
//    now scored 0–100 by a log-odds win-probability from the ladder, PULLED DOWN by effort-vs-result —
//    low price impact (flow not moving price), absorption, toxicity and chop — and only fires when it
//    clears "Min signal CONVICTION %" (default 50). So a big-but-ABSORBED push (strong pressure, no
//    progress) can no longer produce a signal. And the reversal/continuation tag is now trend-coherent:
//    a flip with a trending tape is CONTINUATION (never a "fade"); reversal is reserved for fading an
//    exhaustion extreme in a non-trending tape. Fixes the "TREND-down + FADE-SHORT" contradiction.
//
//  Wave J (this build · v1.7): FREQUENCY + VWAP. Two gates were making signals far too rare — fixed:
//    (1) ARMING now re-arms when the strong-alignment episode ENDS (|align| < threshold), not only on a
//    full flip to the opposite side, so a sustained trend gives one signal per fresh episode instead of
//    one per multi-thousand-bar swing. (2) The CVD-breakout gate is now OFF by default (context, not a
//    hard blocker); re-enable it in group 15 for the rarest signals. Cooldown default 20→10. NEW:
//    MULTI-TIMEFRAME VWAP (Session / Week / Month, group 17) — the institutional cost basis. Its stack
//    (−3..+3) plots on price and folds into conviction: a flip WITH the VWAP stack keeps full conviction,
//    a flip AGAINST it is filtered — accuracy without extra rarity. New "VWAP stack" dashboard row.
//
//  Wave N (this build · v2.2): FLOW-vs-PRICE LEAD (Lévy area). A path-signature read of WHO MOVES
//    FIRST — signed area of the joint (flow, price) path: FLOW leads (participation precedes price,
//    breakouts better backed) vs PRICE leads (flow chasing — squeeze / stop-run). Ported from the
//    Lévy-Area Flow Sequencer; it trims conviction when price is leading. New "Flow lead" row (group
//    18). The anchored ladder is UNIFORM 1×/3×/5× on every timeframe (chart TF + 2 HTFs, 2-of-3).
//    v2.3: a live SIGNAL STRENGTH meter row (the fused conviction 0–100 with a bar gauge and
//    weak/ok/strong/very-strong label) so you can watch strength build toward the fire threshold.
//    v2.4: strength shown ON CHART too — each flip's marker SIZE scales with conviction (very strong /
//    strong / moderate) and the conviction number is stamped on every flip (group 09 toggle).
//    v2.5–2.6: strength shown ON CHART as NUMBER-ONLY labels (no words). Two distinct marker types:
//    the MTF SIGNAL is a solid bull/bear box (number only) above/below the bar; the trailing-line FLIP
//    is a dark box (number only) sitting ON the trailing line — so signal vs flip read separately.
//    Divergence markers default OFF (they crowded the chart).
//    v2.7: the dashboard has a COMPACT / PRO switch (group 09), compact by default — just action,
//    signal strength, last MTF signal, regime and the verdict; Pro shows every read.
//    v2.8: the trailing-line FLIP is now just the strength NUMBER in adaptive yellow on the line (no
//    box/circle); all on-chart accents are background-adaptive; the Lévy loop only runs when enabled
//    (faster load); robustness/perf pass. Built for a 2-second read: the compact panel's ▶ Do verdict.
//
//  Wave O (this build · v3.0): SELF-CORRECTION + A FULL PLAN + LOCATION. (1) EDGE-GATE SELF-MUTING —
//    each side's RECENT forward win-rate (rolling window of resolved samples) is tracked, and that side
//    STOPS firing when its win-rate decays below a floor, un-muting only once it recovers (hysteresis).
//    The honesty scoreboard now ACTS, not just displays. Lagged by construction → never repaints
//    (group 07). (2) TRADE LEVELS & LATCH — every MTF aligned flip draws Trigger / SL / TP1 / TP2,
//    sized off the SAME barriers the scoreboard grades, and the plan is HELD on chart (the live trade)
//    until the Stop or TP2 is hit or a fresh signal replaces it (group 19). (3) VALUE-AREA CONTEXT —
//    a lightweight anchored volume profile (POC / VAH / VAL) adds WHERE flow transacts: a flip AT a
//    node is a defended level, a flip in no-man's-land is trimmed (group 20). New dashboard rows:
//    Edge-gate, Value, Plan. Concepts adapted from the author's DBFC and Multi-Anchor Delta Profile.
//    v3.1: the FULL MULTI-ANCHOR DELTA PROFILE (MADP) is ported in as an optional layer (group 21) —
//    a side-by-side wall of delta-coloured HTF volume profiles with per-anchor POC/Value Area, stacked
//    diagonal imbalance, whale tiers and a net-delta lean meter, plus MADP's EXP_CVD_A/B/C +
//    EXP_WhaleBar exports and whale-print alerts preserved verbatim — so this can publish as an UPDATE
//    to the MADP listing without disappointing its followers (set the layer default-ON there). It is an
//    anatomy view (no verdict); off by default in the Command build. Budget-safe: 44/64 plot units,
//    9/40 request.* calls, boxes/labels/lines pooled under raised caps (500/500/200).
//
//  Wave M (v2.1): ADVANCED FLOW BUNDLE. (1) SIZE-STRATIFIED DELTA — sub-bars split into
//    big-lot (institutional) vs small-lot (retail); their divergence is the "who" tell, and big-lot
//    flow AGAINST a flip gently trims its conviction. (2) FLOW PERSISTENCE — lag-1 autocorrelation of
//    signed delta (self-exciting vs mean-reverting). (3) FLOW HURST — variance-ratio Hurst of the CVD
//    path (>0.55 trending, <0.45 reverting). Persistence + Hurst make the regime read and the
//    reversal/continuation tag FLOW-NATIVE. Three new dashboard rows; all in group 17; all toggleable.
//
//  Wave L (v2.0): VWAP REMOVED — the engine is now purely flow-based (a dedicated
//    flow-based value/reversion reference will be built as its own module). The multi-TF VWAP lines,
//    the VWAP-stack read and the VWAP-agreement conviction factor are all gone; conviction is now
//    flow probability × price impact × regime × toxicity × absorption only. (Removed because the VWAP
//    agreement filter suppressed genuine mean-reversion flips, which point against the VWAP stack.)
//
//  Wave K (v1.8→v1.9): TIGHT LADDER of chart-TF MULTIPLES (1× / 3× / 5×, widenable). Aligning a 1m
//    chart out to 1h/4h was both rare (distant
//    TFs seldom agree at the same instant) and late (by the time they do, the 1m move is over). The
//    ladder is now the chart TF + its next CONSECUTIVE standard higher timeframes — how many is set by
//    "Higher timeframes to align" (group 13, default 3). On 1m that is 1/2/3/5; on 5m 5/10/15/30. The
//    alignment score, flow index, HTF-onside check and threshold all adapt to the active rung count, so
//    signals are more frequent AND more relevant to the timeframe you actually trade.
//
//  Wave D (U9 · VSA taxonomy): an OPTIONAL, additive layer names the current bar's dominant
//    Wyckoff/VSA effort-vs-result event (Upthrust, Shakeout, Stopping Volume, Buying/Selling
//    Climax, No-Demand/Supply) on a new dashboard row, using the shared ml_vsa vocabulary — so the
//    spine's per-bar CHARACTER gets a name. Price markers are OFF by default (the pressure
//    triangles are already dense); toggle them in group 10. Adds EXP_VSABias. The delta spine,
//    signals, regime gate and calibration are unchanged.
//  Wave C: optional shared REGIME GATE (group 08) — a Kaufman efficiency-ratio filter that can
//    restrict the Buy/Sell pressure signals (and their forward scoring) to a chosen regime
//    ("Favor trending" / "Favor reverting"), default "Off". Arming stays on the raw excursion so the
//    once-per-excursion behaviour is preserved; only the actionable events pass through the gate.
//  Wave A: optional robust MAD z-score for the delta standardization (default ON), reversible via
//    "Standardization mode". Delta spikes hard on sweeps; MAD (median / median-absolute-deviation
//    ×1.4826) ignores those outliers so the pressure read stays calibrated. Set it to
//    "Classic (mean/stdev)" for the original output. No state or calibration logic changed.
// ─────────────────────────────────────────────────────────────────────────────
//  WHAT IT IS  (and what this build is)
//    The foundation of a single order-flow engine that reconstructs buy/sell
//    pressure ONCE from intrabar data (the "delta spine") and turns it into a
//    plain-language market STATE, then forward-calibrates whether that state's
//    directional lean actually pays on the chart you are viewing.
//    This build ships the SPINE + the PRESSURE read + the CALIBRATION panel.
//    Further orthogonal reads (persistence, efficiency/impact, toxicity,
//    absorption, price-vs-delta divergence) bolt onto the marked socket below —
//    each earning its place on the same calibration panel before it stays.
//
//  WHY ONE SPINE, NOT A PILE OF INDICATORS  (design rationale)
//    OFI, CVD, delta, burst-flow, ease-of-movement and flow-efficiency are all
//    estimators of ONE latent quantity — net buying pressure. Stacking five of
//    them is not confluence, it is the same bet in five costumes. So this engine
//    reconstructs the latent variable once and exposes only reads that are
//    genuinely independent. Every downstream read consumes the same spine — no
//    duplicated delta, no correlated double-counting.
//
//  HONEST SCOPE  (what a chart platform can and cannot see)
//    A charting platform exposes NO Level-2 order book. True delta/OFI are book
//    quantities; this is a disciplined PROXY from intrabar volume + candle
//    geometry — an approximation, not exchange-grade flow. Intrabar requests
//    update on the live bar; "Confirm on bar close" (default ON) makes plotted
//    signals and calibration evaluate only on closed bars (non-repainting).
//
//  CONCEPT CREDITS (public techniques; independent implementations, no code reused)
//    • Trade classification / tick rule: Lee & Ready (1991).
//    • Bulk Volume Classification: Easley, López de Prado & O'Hara (2012).
//    • Triple-barrier labelling & sample uniqueness: Marcos López de Prado.
//    • Confidence interval for a proportion: Edwin B. Wilson.
//    • Multiple-testing correction: Carlo Bonferroni.
//    Credit to each originator; the spine-and-calibration synthesis is this
//    script's own work.
//
//  DISCLAIMER  Research/education only. NOT financial advice, NOT a signal
//    service, NOT a guarantee. Edge figures are computed on THIS chart's own
//    history with overlapping windows and no costs — context, not a verified
//    backtest, and past behaviour does not predict the future. Markets carry
//    risk of loss; size and manage your own positions.
// ═════════════════════════════════════════════════════════════════════════════
import Market_Logic_India/ml_calib/2   as cal
import Market_Logic_India/ml_session/2 as sess
indicator("Multi-Anchor Delta Profile — Stacked-Imbalance, Whale Tiers & Signal Engine", "MADP", overlay = true, max_bars_back = 5000, max_lines_count = 200, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════════════════════════════════════════════════
// 01 · DATA & SPINE
// ═════════════════════════════════════════════════════════════════════════════
g0 = "00 · View mode"
viewMode   = input.string("Both", "What to draw", options = ["Profile (MADP)", "Signal engine", "Both"], group = g0, tooltip = "MASTER SWITCH. 'Both' (default) shows EVERYTHING — the multi-anchor delta-profile wall AND the full signal engine (signals, trailing stop, dashboard, MTF strip, trade plan). 'Profile (MADP)' shows only the original profile wall + MADP dashboard (the pre-upgrade experience). 'Signal engine' shows only the conviction / trade-plan / calibration view on a clean chart. Every sub-feature still has its own toggle; this only gates which family is drawn.")
bool showProfile = viewMode != "Signal engine"
bool showEngine  = viewMode != "Profile (MADP)"

g1 = "01 · Data & spine"
srcPrice   = input.source(close,  "Price source", group = g1, tooltip = "Price series for the return/impact reads. Default close; works on any symbol.")
srcVol     = input.source(volume, "Volume source", group = g1, tooltip = "Volume for the delta reconstruction. On volumeless symbols the engine falls back to a tick proxy so it still runs.")
volMode    = input.string("Chart", "Asset class — volume", options = ["Chart", "External (futures)"], group = g1, tooltip = "Chart (default): reconstruct the delta spine from THIS chart's own OHLCV — correct for NIFTY futures and any instrument with real volume (unchanged behaviour). External (futures): reconstruct it from a matching futures symbol below and overlay the read here, so the whole engine (delta, CVD, VPIN toxicity, size-split, absorption, MTF flow, the MADP profile wall and whale prints) keeps working on a volume-less or thin chart — a cash index, spot FX, some stocks. Every default is set for NIFTY; change this only for other assets. Price you SEE, the trailing stop and the trade levels always stay on the chart instrument.")
volExtSym  = input.symbol("NSE:NIFTY1!", "External futures (volume source)", group = g1, tooltip = "The futures (or other volume-bearing) symbol whose order flow drives the engine when Asset class = External. Match it to your chart — e.g. NSE:BANKNIFTY1! under a BANKNIFTY spot chart, or the lead contract for an FX/commodity. Ignored when Asset class = Chart.")
classMethod= input.string("Intrabar Tick Rule", "Delta classification", options = ["Intrabar Tick Rule", "Bulk Volume Classification", "Candle Geometry"], group = g1, tooltip = "How each bar's volume is split into buy vs sell. Tick Rule (finest, needs intrabar data) · BVC (probabilistic, bar-aggregated) · Geometry (close position in range).")
ltf        = input.timeframe("1", "Intrabar resolution", group = g1, tooltip = "Sub-bar timeframe for the tick rule. Finer = more faithful, heavier.")
tickBasis  = input.string("Close vs open (candle)", "Tick-rule sub-bar signing", options = ["Close vs open (candle)", "Tick rule (vs prior close)"], group = g1, tooltip = "How each intrabar sub-bar is signed buy/sell (Intrabar Tick Rule only). 'Close vs open (candle)' — the current default; a sub-bar is a buy if it closed above its own open. 'Tick rule (vs prior close)' — the genuine Lee-Ready tick test: sign by the change from the PREVIOUS sub-bar's close, carrying the last sign on an unchanged price. The tick test is the more faithful classifier on fast, liquid tape (Lee & Ready 1991); it is opt-in because it shifts the delta spine from the published NIFTY default.")
bvcDist    = input.string("Student-t (research)", "BVC distribution", options = ["Student-t (research)", "Normal"], group = g1, tooltip = "Distribution used by the Bulk Volume Classification split (BVC method only; does not affect the default Intrabar Tick Rule). Student-t with a low df classifies fat-tailed index/futures returns more accurately than the Normal (Easley, López de Prado & O'Hara; Panayides, Shohfi & Smith) — it stops the Normal from mis-splitting exactly the climactic bars. Default Student-t.")
bvcDf      = input.float(0.25, "  BVC Student-t df", minval = 0.05, maxval = 30.0, step = 0.05, group = g1, tooltip = "Degrees of freedom for the BVC Student-t. The literature uses ≈0.25, and lower (≈0.05–0.1) for very liquid large-caps / index futures; higher df → closer to the Normal. Ignored when BVC distribution = Normal.")
antiRep    = input.bool(true, "Confirm on bar close (non-repainting)", group = g1, tooltip = "ON: plotted signals and calibration resolve only on closed bars. Dashboard still updates live.")

g2 = "02 · Pressure read"
zLen       = input.int(50, "Standardization lookback", minval = 10, maxval = 500, group = g2, tooltip = "Window that standardizes raw delta into a z-score so it compares across symbols and sessions.")
zMode      = input.string("Robust (MAD)", "Standardization mode", options = ["Robust (MAD)","Classic (mean/stdev)"], group = g2, tooltip = "Robust (MAD) standardizes delta with median / median-absolute-deviation (×1.4826), so sweep-driven spikes don't distort the pressure read. Classic reproduces the original mean/stdev z.")
sigThr     = input.float(1.0, "Signal threshold (z)", minval = 0.3, maxval = 3.0, step = 0.1, group = g2, tooltip = "A pressure signal fires when the delta z-score crosses beyond ± this, once per excursion.")
anchorSess = input.bool(true, "Anchor cumulative delta to session", group = g2, tooltip = "Reset the cumulative-delta line at each new day/session (standard for intraday). Off = continuous.")

g7 = "07 · Forward calibration"
useCalib   = input.bool(true, "Forward-calibrate the signal edge", group = g7, tooltip = "Score pressure signals forward with a triple barrier vs a direction-matched base rate. The honesty feature.")
calTarget  = input.string("MTF aligned flip", "Grade which signal (v1.4)", options = ["MTF aligned flip","Pressure signal"], group = g7, tooltip = "Self-validating scoreboard: which signal the forward calibration measures. 'MTF aligned flip' grades the confluence-gated flip actually shown on the chart — the hit-rate/edge then validate what you trade. 'Pressure signal' reproduces the prior behaviour (grades the raw pressure cross). Only takes effect when MTF alignment is on.")
atrLen     = input.int(14, "ATR length", minval = 4, group = g7)
calHorizon = input.int(20, "Horizon (bars)", minval = 3, maxval = 200, group = g7)
calMoveATR = input.float(1.0, "Profit barrier (× ATR)", minval = 0.2, step = 0.1, group = g7)
calStopATR = input.float(1.0, "Stop barrier (× ATR)", minval = 0.2, step = 0.1, group = g7)
calMinN    = input.int(20, "Min samples to trust", minval = 5, maxval = 500, group = g7)
calGap     = input.int(5, "Min bars between samples", minval = 1, group = g7, tooltip = "Uniqueness gap — skip a same-side sample within this many bars to reduce overlap double-counting.")
// ── EDGE-GATE (v3.0) — self-muting: when a side's RECENT forward win-rate decays, that side stops
//    firing until it recovers (hysteresis). Closes the loop from calibration → action: the scoreboard
//    no longer just displays, it acts. Adapted from DBFC. Lagged/non-repainting (set by the outcome
//    tracker, read on the next bar). ──
edgeGate   = input.bool(false, "Edge-gate: mute a side when its recent win-rate decays", group = g7, tooltip = "OFF by default — the engine fires normally and the scoreboard just REPORTS. Turn ON to make it ACT: each side (BUY / SELL) is muted — its flips stop showing — when the win-rate of its last N RESOLVED forward samples falls below the mute floor, and un-mutes once it recovers above the un-mute ceiling (hysteresis). The scoreboard learns from the pre-mute signal, so a muted side keeps accumulating samples and can always recover. Advanced: leave OFF until the hit-rate row shows a real sample count, else it can mute a side before it has enough history. Lagged by design — never repaints.")
edgeWin    = input.int(25, "  Edge-gate rolling window (resolved samples)", minval = 8, maxval = 100, group = g7, tooltip = "Only the most recent N resolved forward samples of each side count toward its win-rate.")
edgeMinN   = input.int(10, "  Min resolved samples before muting", minval = 4, maxval = 60, group = g7, tooltip = "A side can only be muted after it has this many resolved samples — so a cold start never mutes on 1–2 losses.")
edgeMute   = input.float(-0.05, "  Mute below avg R", minval = -1.0, maxval = 0.3, step = 0.01, group = g7, tooltip = "When a side's rolling average trailing-exit R drops below this, it mutes. R (not win-rate) is used because a profitable trend-ride wins < 50% of the time.")
edgeUnmute = input.float(0.05, "  Un-mute above avg R", minval = -0.3, maxval = 1.0, step = 0.01, group = g7, tooltip = "A muted side un-mutes only once its rolling average R recovers above this. Keep it above the mute floor for hysteresis (no flicker).")

g8 = "08 · Regime gate (Wave C)"
regGate  = input.string("Off", "Regime gate", options = ["Off","Favor trending","Favor reverting"], group = g8, tooltip = "Optional Kaufman efficiency-ratio filter on the Buy/Sell pressure signals (and their forward scoring). Off = unchanged. Favor trending = fire pressure signals only when price is actually trending (ER at/above threshold) — a natural fit for a momentum/pressure cross; Favor reverting = only when ranging. Arming is unaffected, so the once-per-excursion behaviour is preserved. Default Off.")
regErLen = input.int(20, "Efficiency-ratio window", minval = 5, maxval = 200, group = g8)
regErThr = input.float(0.40, "Trend threshold", minval = 0.05, maxval = 0.95, step = 0.05, group = g8, tooltip = "ER at or above this = trending; below = ranging.")

g9 = "09 · Dashboard & visuals"
bcOn       = input.bool(false, "Colour bars by flow pressure", group = g9, tooltip = "OFF by default so your own candle colours stay intact. ON tints each bar by decisive net flow (buying / selling bias) — an at-a-glance flow read on price, replacing the old oscillator pane.")
showSig    = input.bool(true, "Plot chart-TF pressure triangles on price", group = g9, tooltip = "ON by default — the chart-timeframe pressure triangles (gated to MTF direction agreement) give a dense read of where buy/sell pressure fired. The number-boxed MTF aligned flip remains the precise, forward-tested signal; turn this off for a cleaner chart that shows only the flips.")
showFlipStr= input.bool(true, "Show MTF signal (strength number)", group = g9, tooltip = "ON (default): each MTF aligned flip prints as a SOLID bull/bear box showing only its fused-conviction number (0–100) — no words. This is the SIGNAL; the trailing-line cross 'flip' (group 12) is a separate, round badge on the line.")
compactDash= input.bool(true, "Compact dashboard (off = Pro / full)", group = g9, tooltip = "ON (default): a small COMPACT dashboard — just the action header, live signal strength, last MTF signal, regime and the What-to-do verdict. OFF: the full PRO panel with every read (pressure, CVD, edge, VSA, absorption, toxicity, impact, big-lot, persistence, Hurst, flow-lead, etc.).")
themeOpt   = input.string("Auto", "Color theme", options = ["Auto", "Dark", "Light"], group = g9, tooltip = "Auto reads the chart background luminance and adapts the table for contrast on dark OR light charts.")
tblPos     = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g9)
bullCol    = input.color(#2ebd85, "Bullish", inline = "c", group = g9)
bearCol    = input.color(#f6465d, "Bearish", inline = "c", group = g9)
midColr    = input.color(#f0b90b, "Neutral", inline = "c", group = g9)
showKeyUX  = input.bool(true, "Show marker legend (key)", group = g9, tooltip = "A small on-chart legend explaining the signal markers — the MTF signal box, the ▲/▼ FLIP tag, the pressure triangles and the trailing-stop safe zone. Costs no plots.")
keyPosUX   = input.string("Bottom Left", "Legend position", options = ["Bottom Left", "Bottom Right", "Top Left", "Middle Left"], group = g9)

g10 = "10 · VSA bar events (Wave D)"
vsaRow   = input.bool(true,  "Show VSA event row on dashboard", group = g10, tooltip = "Names the current bar's dominant Wyckoff/VSA effort-vs-result event (Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax, No-Demand/Supply) using the shared ml_vsa vocabulary. Reads the SAME thing the rest of the suite reads. Purely additive — the delta spine, signals and calibration are unchanged.")
vsaLen   = input.int(50, "VSA history window", minval = 10, maxval = 300, group = g10)
vsaPiv   = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = g10)
vsaTod  = input.bool(true, "Time-of-day volume (Wave D · U11)", group = g10, tooltip = "ON (default): judge volume against the SAME time-of-day slot on prior sessions (ml_session per-slot baseline, inlined) — so a normal-for-the-open bar is not a false climax and a heavy-for-lunch bar is caught. OFF: high volume judged against a flat rolling window (original).")
vsaTodMin = input.int(5,  "  Slot size (minutes)", minval = 1, maxval = 60, group = g10, tooltip = "Time-of-day bucket size for the volume baseline.")
vsaTodSes = input.int(20, "  Session memory", minval = 3, maxval = 200, group = g10, tooltip = "Sessions of memory the per-slot volume baseline keeps.")

g11 = "11 · Absorption consensus (Wave E)"
absOn      = input.bool(true,  "Show absorption consensus row", group = g11, tooltip = "Effort-vs-result ABSORPTION measured four independent ways on the SAME delta spine — (1) OLS residual of Δprice on signed delta, (2) cost-per-tick percentile, (3) dominance−result, (4) qualitative high-effort/narrow-spread — and only called absorption when ≥ N agree. Absorption = large flow that fails to move price (a level defended). Purely additive: the spine, signals and calibration are unchanged.")
absLen     = input.int(50,   "Absorption window", minval = 10, maxval = 300, group = g11)
absZThr    = input.float(2.0,  "Residual-z threshold", minval = 0.5, step = 0.1, group = g11)
absCostThr = input.float(90.0, "Cost-per-tick pct threshold", minval = 50, maxval = 99.9, group = g11)
absDomThr  = input.float(0.30, "Dominance−result threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = g11)
absMinAgree= input.int(3,    "Methods needed to confirm (of 4)", minval = 1, maxval = 4, group = g11)

g12 = "12 · Command Center layers"
cmdDriver  = input.bool(true,  "Flow driver read (dashboard + alerts)", group = g12, tooltip = "A fast signal EMA vs a slow confirmation EMA of the pressure-z; their crossover is the broad shift in control, shown on the dashboard 'Flow driver' row and as an alert. (In this overlay build it is no longer drawn as pane lines.) Also enables the impulse-burst alert on rare delta-acceleration bursts.")
cmdSigLen  = input.int(3,   "  Signal (fast) length",       minval = 1, maxval = 50, group = g12)
cmdConfLen = input.int(12,  "  Confirmation (slow) length", minval = 2, maxval = 100, group = g12)
cmdImpZ    = input.float(2.0, "  Impulse burst threshold (z)", minval = 1.0, maxval = 5.0, step = 0.1, group = g12)
cmdExh     = input.bool(true,  "Exhaustion background zones", group = g12, tooltip = "Light the pane background when the pressure read is beyond its own high/low percentile over the window — climactic order flow (capitulation / blow-off), not merely strong.")
cmdExhLen  = input.int(200, "  Exhaustion window", minval = 30, maxval = 1000, group = g12)
cmdExhPct  = input.float(97.0, "  Exhaustion percentile", minval = 80.0, maxval = 99.9, step = 0.5, group = g12)
cmdDiv     = input.bool(false, "Flow-vs-price divergence markers", group = g12, tooltip = "OFF by default (they crowd the chart). ON marks when price prints a new swing extreme that the cumulative delta does NOT confirm — an early reversal warning. The dashboard 'Divergence' state shows regardless.")
cmdDivPiv  = input.int(5,   "  Divergence pivot length", minval = 2, maxval = 30, group = g12)
cmdTrail   = input.bool(true,  "Auto ATR trailing stop on price", group = g12, tooltip = "A volatility trailing stop drawn on the price chart — the exit/risk reference that completes the trade loop. Flips with price; flip alerts included.")
showTrailStr = input.bool(true, "Show flip (strength number) at trailing-line cross", group = g12, tooltip = "When price crosses the trailing stop, print the current strength number (fused conviction 0–100) in yellow on the trailing line — no box, no words. This 'flip' marker is visually distinct from the solid MTF SIGNAL box, so the two read separately.")
trailKeep    = input.int(6, "  Trailing-cross flips to keep on chart", minval = 1, maxval = 100, group = g12, tooltip = "Only the most recent N trailing-line cross strength numbers are kept, so the trailing line never becomes a field of numbers. Lower on fast (1m/2m) charts.")
cmdTrailMlt= input.float(2.0, "  Trailing stop (× ATR)", minval = 0.5, maxval = 10.0, step = 0.1, group = g12)
cmdTrailLen= input.int(14,  "  Trailing stop ATR length", minval = 3, maxval = 100, group = g12)
cmdTrailTF = input.string("Chart", "  Trail ATR timeframe", options = ["Chart", "2× chart", "3× chart", "5× chart", "Custom"], group = g12, tooltip = "Which timeframe's ATR sets the trailing-stop width. 'Chart' = the classic chart-TF trail. The higher options widen the stop to the timeframe the SIGNAL actually lives on, so ordinary lower-TF noise no longer knocks you out while the higher-TF structure that produced the signal is intact — the exit matches the entry's timeframe. Still a single line, not a band. 'Custom' uses the timeframe below.")
cmdTrailTFc= input.timeframe("15", "  Custom trail timeframe", group = g12, tooltip = "Used when Trail ATR timeframe = Custom.")

// ── TRAILING-STOP SAFE ZONE (v2.13 UX, adapted from RedK MMTStop) — a graded cushion read: the gap
//    between the ATR trailing stop and price is shaded 🟢 Safe / 🟡 Watch / 🔴 Critical, measured in
//    ATR so it reads the same on any symbol. Answers "how much room before my stop" at a glance. ──
gSZ = "12b · Trailing-stop safe zone (v2.13)"
szOn       = input.bool(true, "Show trailing-stop safe zone", group = gSZ, tooltip = "Shades the gap between the ATR trailing stop (group 12) and price as a graded cushion: 🟢 Safe (plenty of room) → 🟡 Watch → 🔴 Critical (price nearly at the stop), measured in ATR. Also adds a 'Stop zone' dashboard line and a Critical-zone alert. Only draws when the trailing stop itself is on.")
szAtrLen   = input.int(14, "Safe-zone ATR length", minval = 1, maxval = 100, group = gSZ, inline = "sz", active = szOn, display = display.none)
szMult     = input.float(2.0, "Safe ≥ (× ATR)", minval = 0.5, maxval = 10.0, step = 0.1, group = gSZ, inline = "sz", active = szOn, display = display.none, tooltip = "Safe = at/above this × ATR of cushion to the stop. Watch = between half and this. Critical = below half. Example: 2.0 → Safe ≥ 2.0× ATR, Watch 1.0–2.0×, Critical < 1.0×.")
szFillTr   = input.int(82, "Cushion fill transparency", minval = 50, maxval = 98, group = gSZ, active = szOn, display = display.none, tooltip = "The cushion fill uses the suite's Safe/Watch/Neutral colours (group 09) so 🟢/🟡/🔴 stays consistent chart-wide; this sets how faint it is.")

// ── MTF STACK (1/2/3/5/15/30/60) ────────────────────────────────────────────
// Draws each timeframe's OWN ATR trailing stop + order-flow-flip signal on one
// chart. Higher-timeframes-only by construction: a timeframe FASTER than the
// chart can't be plotted (Pine returns one value per chart bar, not the intrabar
// history), so those rungs are skipped — view on a 1–5m chart to see all seven.
gMS = "⑳ MTF stack (1/2/3/5/15/30/60)"
msOn      = input.bool(false, "Show MTF stack (per-TF trailing stop + flow signal)", group = gMS, tooltip = "OFF by default. When ON, each timeframe ≥ your chart TF draws its own ATR trailing stop and a marker when that TF's order flow flips. Faster-than-chart timeframes are skipped (they can't be drawn). View on 1–5m to see the full 1/2/3/5/15/30/60 stack.")
msTrails  = input.bool(true,  "  Draw per-TF trailing stops", group = gMS)
msSignals = input.bool(true,  "  Draw per-TF flow-flip signals", group = gMS, tooltip = "A marker (▲/▼ with the TF) at that timeframe's order-flow flip — the per-timeframe directional signal. The full fused aligned-flip can't be computed on another timeframe.")
msSigMode = input.string("Latest per TF", "  Signal display", options = ["Latest per TF", "All flips", "Off"], group = gMS, tooltip = "Latest per TF (default): ONE small marker per timeframe at its MOST RECENT flip — the current MTF signal, uncluttered. All flips: every historical flip (capped, denser). Off: trailing stops only.")
msMlt     = input.float(2.0,  "  Stack trailing stop (× ATR)", minval = 0.5, maxval = 10.0, step = 0.1, group = gMS)
msTrailBars = input.int(60, "  Trailing stop history (bars, 0=all)", minval = 0, maxval = 500, group = gMS, tooltip = "Draw only the most recent N bars of each per-TF trailing stop, so the stops sit as a tidy cluster near price instead of a full-history web. 0 = full history.")
msLegend  = input.bool(true,  "  Show TF colour legend", group = gMS)
ms1  = input.bool(true, "1m",  inline = "ms", group = gMS)
ms2  = input.bool(true, "2m",  inline = "ms", group = gMS)
ms3  = input.bool(true, "3m",  inline = "ms", group = gMS)
ms5  = input.bool(true, "5m",  inline = "ms", group = gMS)
ms15 = input.bool(true, "15m", inline = "ms2", group = gMS)
ms30 = input.bool(true, "30m", inline = "ms2", group = gMS)
ms60 = input.bool(true, "60m", inline = "ms2", group = gMS)
cmdScore   = input.bool(true,  "Honest-stats scoreboard row", group = g12, tooltip = "A compact per-side hit-rate (Wilson-floored) and edge-over-base-rate readout on the dashboard, from the forward calibration.")

g13 = "13 · MTF order-flow alignment"
mtfOn    = input.bool(true, "Multi-timeframe flow alignment", group = g13, tooltip = "The clean, high-signal read: net buying pressure is measured on a ladder of timeframes and only when enough of them AGREE is the flow meaningful. Replaces per-bar noise with cross-timeframe consensus. Shown as a strip, a dashboard row, and a sparse on-price 'aligned flip' signal.")
mtfAnchor = input.bool(true, "Anchor the ladder to the chart timeframe", group = g13, tooltip = "ON (recommended): the ladder is MULTIPLES of the chart timeframe — 1× / 3× / 5× by default (widen below) — a tight, relevant cluster. On 5m: 5 / 15 / 25; on 1m: 1 / 3 / 5. This fires far more often and more accurately than aligning 1m out to 1h/4h. OFF: use the six fixed TF boxes below.")
mtf1     = input.timeframe("1",   "TF 1 (used when anchor is off)", inline = "mt1", group = g13)
mtf2     = input.timeframe("3",   "TF 2", inline = "mt1", group = g13)
mtf3     = input.timeframe("5",   "TF 3", inline = "mt1", group = g13)
mtf4     = input.timeframe("15",  "TF 4", inline = "mt2", group = g13)
mtf5     = input.timeframe("60",  "TF 5", inline = "mt2", group = g13)
mtf6     = input.timeframe("240", "TF 6", inline = "mt2", group = g13)
mtfZlen  = input.int(50, "Flow standardization lookback", minval = 10, maxval = 500, group = g13, tooltip = "Window that standardizes each timeframe's net delta into a comparable z-score.")
mtfNeut  = input.float(0.3, "Neutral band (z)", minval = 0.0, maxval = 2.0, step = 0.1, group = g13, tooltip = "A timeframe counts as buy/sell only when its flow-z is beyond ± this; inside it, that TF is neutral.")
mtfHtfN  = input.int(2, "Higher timeframes to align (above chart)", minval = 1, maxval = 5, group = g13, tooltip = "How many HIGHER timeframes above the chart join the alignment (when anchoring is on). The ladder is UNIFORM chart-TF multiples 3× / 5× / 8× / 13× / 21×. Default 2 → the 1× / 3× / 5× ladder (e.g. 5m → 5/15/25, 1m → 1/3/5). Raise to add 8×, 13×, 21× for a wider stack.")
mtfThr   = input.int(2, "Timeframes aligned for a strong signal", minval = 2, maxval = 6, group = g13, tooltip = "The net alignment (buyers minus sellers across the ACTIVE rungs) must reach ± this for a 'strong aligned' state and an on-price flip. Auto-capped to the number of active rungs. Default 2 — with the 3-rung ladder (chart + 2 HTFs), 2 of 3 must agree. Raise to 3 for the full stack; 2 is the floor.")
mtfGate  = input.bool(true, "Only show price signals when MTF-aligned", group = g13, tooltip = "ON (default): the buy/sell pressure triangles print only when the multi-timeframe flow agrees with them — far fewer, far more meaningful marks. OFF: show every chart-TF pressure signal (dense).")
mtfReqHTF = input.bool(true, "Require the 2 highest TFs onside", group = g13, tooltip = "The biggest precision filter: a BUY only fires if TF 5 & TF 6 (default 60m & 240m) are also buying, a SELL only if they are selling — so you trade WITH the higher-timeframe regime, never against it. Turns 'the fast TFs flickered' into 'the whole stack agrees'.")
mtfCooldown = input.int(10, "Min bars between signals", minval = 0, maxval = 500, group = g13, tooltip = "Hard spacing: no new MTF signal within this many bars of the last one, so signals can't cluster. Raise for fewer, more spaced-out signals.")
mtfUseVel = input.bool(false, "Require flow to be accelerating (speed filter)", group = g13, tooltip = "OFF by default (v1.7.3): this 'finesse' filter only fired when flow was still BUILDING (velocity agreeing) — but in a steady trend the flow isn't accelerating, so it blocked almost every signal except at sharp turns. Off = a flip fires whenever the ladder reaches strong agreement (once per fresh episode), which is the frequency you want. Turn ON only if you want to trade turns/impulses exclusively and accept far fewer signals.")
mtfVelLen = input.int(3,   "  Flow-speed window (bars)", minval = 1, maxval = 50, group = g13)
mtfVelThr = input.float(0.15, "  Min flow speed", minval = 0.0, maxval = 2.0, step = 0.05, group = g13, tooltip = "Minimum rate-of-change of the weighted flow index needed. Higher = only the sharpest accelerations signal (finer, fewer).")
mtfMinConf = input.int(35, "Min signal CONVICTION % to fire", minval = 0, maxval = 95, step = 5, group = g13, tooltip = "THE PRECISION DIAL. Every aligned flip is scored 0–100 by a single FUSED CONVICTION: a log-odds probability from the timeframe ladder, then pulled DOWN by effort-vs-result — low price impact (flow not moving price), absorption, toxicity and chop. A flip only fires when conviction clears this. Default 35 (the score is a product of several sub-1 factors, so realistic good signals sit ~40–65); raise toward 55 for fewer/stronger, lower toward 25 for more.")
flip1mSup  = input.bool(false, "Suppress flips on sub-2-minute charts", group = g13, tooltip = "OFF by default (v2.12.1) so 1m fires like every other timeframe. NOTE: the aligned flip's forward expectancy (trailing exit) tested NEGATIVE on 1m (too noisy) but positive on 2m+ — so on a 1m chart lean on the higher-conviction flips and check the Expectancy row before trading them. Turn this ON to blank the flip signal below 2 minutes (the dashboard reads still populate).")
loGain     = input.float(1.5, "Conviction log-odds gain", minval = 0.3, maxval = 3.0, step = 0.1, group = g13, tooltip = "How sharply the fused flow index converts to a win-probability — the main driver of signal strength. Higher = more decisive (strong ladder alignment reads strong sooner). Default raised to 1.5 in v2.12 so conviction tracks real edge instead of sitting low.")
mtfStrip = input.bool(true, "Show FLOW / MTF-stack ladder strip", group = g13, tooltip = "The compact colour-coded ladder (FLOW alignment, and the MTF stack when that layer is on). Each rung is coloured by its OWN direction — green up / red down — which a single cell in the main panel can't do, so the ladder sits in its own small strip. Turn off to hide it.")
ladderPos = input.string("Bottom Right", "Ladder strip position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g13, tooltip = "Where the colour-coded FLOW / MTF-stack ladder strip sits. Put it next to the main panel to read them as one block.")

g14 = "14 · Flow toxicity (VPIN)"
toxOn      = input.bool(true, "Flow toxicity read (VPIN volume-clock)", group = g14, tooltip = "Equal-VOLUME-bucket VPIN: how one-sided and informed the flow is (adverse selection), self-calibrated 0–100. High = the whipsaw regime. Ported from the VPIN Flow-Toxicity Oscillator.")
toxBktVol  = input.float(1.0, "Bucket size (× avg volume)", minval = 0.2, maxval = 10.0, step = 0.1, group = g14, tooltip = "A toxicity bucket fills after roughly this many average-bars of volume. Larger = smoother, slower toxicity.")
toxNBkt    = input.int(50, "Buckets in the toxicity window", minval = 5, maxval = 500, group = g14)
toxRankLen = input.int(200, "Toxicity percentile window", minval = 20, maxval = 1000, group = g14)
toxSuppress= input.bool(true, "Suppress MTF flips when flow is toxic", group = g14, tooltip = "ON: an MTF aligned flip is HELD while toxicity is in its top percentile (informed one-sided flow = whipsaw risk); it can still fire once toxicity calms within the confluence window. The precision filter for the noisiest regime.")
toxHi      = input.float(80.0, "Toxic percentile", minval = 50.0, maxval = 99.5, step = 0.5, group = g14)

g15 = "15 · CVD structure channel"
cvdChanOn  = input.bool(true, "CVD channel + breakout", group = g15, tooltip = "Fit a regression channel on the session-anchored cumulative delta and detect confirmed breakouts of the band — a structural order-flow event on the CVD itself (regression-channel form of the Meridian-Flow CVD channel).")
cvdChanLen = input.int(100, "Channel regression length", minval = 20, maxval = 500, group = g15)
cvdChanMult= input.float(2.0, "Channel width (× residual σ)", minval = 0.5, maxval = 5.0, step = 0.1, group = g15)
cvdConfirm = input.int(2, "Confirm bars beyond channel", minval = 1, maxval = 20, group = g15, tooltip = "CVD must sit beyond the band this many bars before a breakout is confirmed (non-repainting).")
cvdCooldown= input.int(15, "Min bars between CVD breakouts", minval = 0, maxval = 200, group = g15)
cvdGate    = input.bool(false, "HARD-require CVD breakout to confirm flips", group = g15, tooltip = "OFF by default (v1.7): the CVD channel is a CONTEXT read, not a hard blocker — requiring a CVD break to coincide with every MTF flip made signals far too rare. ON restores the strict v1.6 behaviour (a flip only fires if the CVD channel also broke in the same direction within the window) for the very cleanest, rarest signals.")
cvdGateWin = input.int(10, "CVD-breakout confluence window (bars)", minval = 1, maxval = 100, group = g15, tooltip = "How recently the CVD channel must have broken (same direction) to confirm an MTF flip — and how long a pending flip waits for that break before it lapses.")

g16 = "16 · Impact, regime & verdict (v1.4)"
impOn     = input.bool(true, "Price-impact read (Kyle λ)", group = g16, tooltip = "Rolling regression of price move on signed flow (Kyle's lambda) — price impact per unit of flow, self-calibrated 0–100. High = flow moves price efficiently (participation / trend); low = flow absorbed (reversal / exhaustion). Inlined from Volume-Flow Pressure. Feeds the reversal-vs-continuation label and the verdict.")
impLen    = input.int(50, "Impact regression length", minval = 10, maxval = 300, group = g16)
impUseR2  = input.bool(true, "Use Kyle-λ R² as the impact factor in conviction", group = g16, tooltip = "ON by default (v2.12): conviction's impact factor uses the regression R² — the share of price variance order flow actually explains — which is the more principled price-impact measure (the one the sibling Ctrl+Path / Reversal scripts use, flow.kyleR2). OFF reverts to the λ-slope percentile. The R² readout shows on the Impact row either way.")
verdictOn = input.bool(true, "Regime read + reversal/continuation + What-to-do verdict", group = g16, tooltip = "Adds a compact market-REGIME read (trend / mean-reversion / balance / toxic), tags each shown flip as reversal (fade) or continuation (trend-follow), and synthesises a single plain-language WHAT-TO-DO directive on the dashboard — the decision-layer best-practice from the Order-Flow Profile / OFI Regime panels. Dashboard-only; no chart clutter.")

// (Multi-timeframe VWAP was removed — this engine is purely flow-based.)

g17 = "17 · Advanced flow (v2.1)"
sizeOn     = input.bool(true, "Size-stratified delta (big-lot vs small-lot)", group = g17, tooltip = "Splits each bar's sub-bar volume into BIG lots (institutional footprint) and SMALL lots (retail) and tracks their delta separately. When big-lot flow diverges from small-lot, that's the highest-quality tell in order flow — who is actually doing this. Big-lot = sub-bars above the threshold below.")
sizeMult   = input.float(1.5, "Big-lot threshold (× avg sub-bar volume)", minval = 1.0, maxval = 5.0, step = 0.1, group = g17, tooltip = "A sub-bar counts as a BIG lot when its volume is at least this multiple of the bar's average sub-bar volume. Higher = only the very largest prints count as institutional.")
sizeZLen   = input.int(50, "Big-lot standardization window", minval = 10, maxval = 500, group = g17)
sizeInConv = input.bool(true, "Fold big-lot agreement into conviction", group = g17, tooltip = "ON: a flip is gently down-weighted only when BIG-lot flow is clearly AGAINST it (institutions on the other side). It never penalises a flip that big money supports — so it filters bad trades without cutting signal count.")
persistOn  = input.bool(true, "Flow persistence (self-excitation)", group = g17, tooltip = "Lag-1 autocorrelation of the signed delta: does buying beget buying (self-exciting / trending flow, +) or does it mean-revert (−)? A flow-native regime read — better than a price-based one because it measures the flow's own character.")
persistLen = input.int(50, "Persistence window", minval = 10, maxval = 500, group = g17)
hurstOn    = input.bool(true, "Flow Hurst (variance-ratio)", group = g17, tooltip = "Variance-ratio Hurst exponent of the cumulative-delta path: > 0.5 = trending flow, < 0.5 = mean-reverting, ≈ 0.5 = random walk. The rigorous trend-vs-revert measure on the delta path itself. Feeds the regime read and the reversal/continuation tag.")
hurstLen   = input.int(100, "Hurst window", minval = 20, maxval = 800, group = g17)
hurstLag   = input.int(8, "Hurst lag (q)", minval = 2, maxval = 50, group = g17, tooltip = "The multi-step horizon for the variance ratio. Larger = smoother, slower Hurst.")

g18 = "18 · Flow-vs-price lead (Lévy area, v2.2)"
levyOn     = input.bool(true, "Flow/price lead-lag (Lévy area)", group = g18, tooltip = "Signed (Lévy) area of the joint flow/price path — a path-signature read of WHO MOVES FIRST. A>0 = FLOW leads (participation precedes price; breakouts better backed); A<0 = PRICE leads (flow chasing — squeeze / stop-run, be sceptical of extensions). Ported from the Lévy-Area Flow Sequencer. Sequencing tendency, not causation.")
levyWin    = input.int(50, "Area window (bars)", minval = 10, maxval = 300, group = g18)
levySmooth = input.int(3, "Area smoothing", minval = 1, maxval = 20, group = g18)
levyLook   = input.int(300, "Self-calibration lookback", minval = 50, maxval = 2000, group = g18)
levySigLvl = input.float(75.0, "Lead declared above (|area| pct)", minval = 50.0, maxval = 99.0, step = 1.0, group = g18)
levyInConv = input.bool(true, "Fold lead into signal conviction", group = g18, tooltip = "ON: when PRICE leads (flow chasing) a flip's conviction is gently trimmed; when FLOW leads it keeps full conviction. Filters signals where price is running ahead of participation, without cutting count.")

g19 = "19 · Trade levels & latch (v3.0)"
showLevels = input.bool(true, "Draw Trigger / SL / TP1 / TP2 on the signal", group = g19, tooltip = "Each MTF aligned flip draws a complete trade plan on price — entry Trigger, Stop, and two Targets — sized off the SAME barriers the forward scoreboard grades (group 07), so the plan on the chart matches what's being calibrated. OFF = clean chart, plan still shown in the dashboard.")
latchOn    = input.bool(true, "Latch the plan until SL / TP2 hit or replaced", group = g19, tooltip = "ON: the active signal's levels stay on screen (the live trade) until price reaches the Stop or TP2, or a fresh opposite/stronger signal replaces it — so the chart always shows the trade in progress, not a vanished marker. OFF: levels show only on the signal bar.")
lvlTP2Mult = input.float(2.0, "  TP2 = TP1 distance ×", minval = 1.2, maxval = 4.0, step = 0.1, group = g19)
lvlSLtrail = input.bool(true, "  Use the ATR trailing line as the stop when it's onside", group = g19, tooltip = "ON: if the ATR trailing stop (group 12) sits on the correct side of entry, it is used as the Stop (a structural, moving stop) instead of the fixed ATR-barrier distance. OFF: always use the fixed stop-barrier distance.")

g20 = "20 · Value-area context (v3.0 · POC / VAH / VAL)"
pocOn      = input.bool(true, "Volume value-area context (POC / VAH / VAL)", group = g20, tooltip = "A lightweight anchored volume profile over the last N bars: the POC (highest-volume price), and the Value-Area High/Low that bound the busiest 70%. Adds the WHERE the rest of the engine lacks — a flip AT a high-volume node is a level being defended (higher quality); a flip in no-man's-land is fade-risk. Drawn as a few horizontal lines and read on the dashboard 'Value' row.")
pocLook    = input.int(150, "  Profile lookback (bars)", minval = 30, maxval = 1200, group = g20, tooltip = "How many recent bars build the profile. Larger = more macro value.")
pocBins    = input.int(24, "  Profile bins", minval = 10, maxval = 60, group = g20)
pocVApct   = input.float(70, "  Value-area %", minval = 40, maxval = 95, step = 1, group = g20) / 100.0
pocTol     = input.float(0.35, "  'At level' tolerance (× ATR)", minval = 0.1, maxval = 2.0, step = 0.05, group = g20, tooltip = "Price within this many ATR of POC / VAH / VAL counts as AT that node.")
pocLines   = input.bool(true, "  Draw the POC / VAH / VAL lines", group = g20)
pocInConv  = input.bool(true, "  Fold location into signal conviction", group = g20, tooltip = "ON: a flip AT a value node keeps full conviction; a flip in no-man's-land (no node nearby) is gently trimmed. Filters low-location signals without cutting count.")

g21 = "21 · Multi-anchor delta profile (MADP layer, v3.1)"
madpOn    = input.bool(true, "Multi-anchor delta-profile wall (MADP)", group = g21, tooltip = "The full Multi-Anchor Delta Profile — the original tool, ON by default so it is the tool existing followers know. A side-by-side WALL of delta-coloured volume profiles — several HTF anchors (e.g. 1H / 4H / Day) at once, each reconstructed from intrabars — with per-anchor POC / Value Area, stacked diagonal imbalance, whale tiers and a net-delta lean meter. This is an ANATOMY view (WHERE aggressive flow transacted); it prints no verdict. OFF by default to keep the Command view light; turn ON (and it can be the default when published under the MADP listing).")
mpLtfMode = input.string("Auto", "  LTF granularity", options = ["Auto","1S","1","3","5","15"], group = g21, tooltip = "Intrabar resolution used to reconstruct buy/sell volume. Auto scales it to the chart timeframe.")
mpRows    = input.int(24, "  Profile rows", minval = 8, maxval = 60, group = g21)
mpBufCap  = input.int(3000, "  Max intrabars / anchor", minval = 500, maxval = 6000, step = 500, group = g21)
mpUseA    = input.bool(true,  "Anchor A", inline = "mpa", group = g21)
mpHtfA    = input.timeframe("15", "", inline = "mpa", group = g21)
mpNameA   = input.string("15m", "", inline = "mpa", group = g21)
mpUseB    = input.bool(true,  "Anchor B", inline = "mpb", group = g21)
mpHtfB    = input.timeframe("60", "", inline = "mpb", group = g21)
mpNameB   = input.string("1H", "", inline = "mpb", group = g21)
mpUseC    = input.bool(true,  "Anchor C", inline = "mpc", group = g21)
mpHtfC    = input.timeframe("240", "", inline = "mpc", group = g21)
mpNameC   = input.string("4H", "", inline = "mpc", group = g21)
mpProfW   = input.int(60, "  Profile width (bars)", minval = 15, maxval = 200, group = g21)
mpProfGap = input.int(16, "  Gap between profiles (bars)", minval = 4, maxval = 60, group = g21)
mpBaseOff = input.int(10, "  Offset from last bar (bars)", minval = 2, maxval = 60, group = g21)
mpShowVA  = input.bool(true, "  POC / Value Area per anchor", group = g21)
mpVaPct   = input.float(70, "  Value-area %", minval = 30, maxval = 95, step = 5, group = g21) / 100.0
mpDimNonVA= input.bool(true, "  Fade rows outside Value Area", group = g21)
mpShowMet = input.bool(true, "  Net-delta lean meter", group = g21)
mpShowImb = input.bool(true, "  Stacked diagonal imbalance", group = g21)
mpImbRatio= input.float(3.0, "  Imbalance ratio", minval = 1.5, maxval = 10.0, step = 0.5, group = g21)
mpImbStack= input.int(3, "  Rows to stack", minval = 2, maxval = 8, group = g21)
mpShowWh  = input.bool(true, "  Whale tiers", group = g21)
mpWhT1    = input.float(75, "  Whale tier-1 pct", minval = 50, maxval = 99, group = g21)
mpWhT2    = input.float(90, "  Whale tier-2 pct", minval = 50, maxval = 99, group = g21)
mpWhT3    = input.float(97, "  Whale tier-3 pct", minval = 50, maxval = 99.9, group = g21)
mpDash    = input.bool(true, "  MADP anchor dashboard", group = g21)
mpExpOn   = input.bool(true, "  Export running CVD per anchor + whale-print (Data Window)", group = g21, tooltip = "Preserves MADP's EXP_CVD_A / B / C and EXP_WhaleBar outputs so existing setups that consume them via input.source() keep working.")

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════════════════
f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
squash(float x) => x / (1.0 + math.abs(x))
// standard normal CDF (Abramowitz-Stegun) — for Bulk Volume Classification
ncdf(float x) =>
    float z = x / math.sqrt(2.0)
    float t = 1.0 / (1.0 + 0.3275911 * math.abs(z))
    float y = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-z * z)
    float erf = z >= 0 ? y : -y
    0.5 * (1.0 + erf)
// ── Student-t CDF (for fat-tail-correct Bulk Volume Classification) ──────────────
// log-gamma (Lanczos g=7), regularized incomplete beta (Numerical-Recipes continued fraction),
// then the symmetric t-CDF. Only evaluated when classMethod = BVC and distribution = Student-t.
f_lgamma(float x) =>
    float xx = x - 1.0
    float t  = xx + 7.5
    float a  = 0.99999999999980993
    a += 676.5203681218851     / (xx + 1.0)
    a += -1259.1392167224028   / (xx + 2.0)
    a += 771.32342877765313    / (xx + 3.0)
    a += -176.61502916214059   / (xx + 4.0)
    a += 12.507343278686905    / (xx + 5.0)
    a += -0.13857109526572012  / (xx + 6.0)
    a += 9.9843695780195716e-6 / (xx + 7.0)
    a += 1.5056327351493116e-7 / (xx + 8.0)
    0.5 * math.log(2.0 * math.pi) + (xx + 0.5) * math.log(t) - t + math.log(a)
f_betacf(float a, float b, float x) =>
    float FPMIN = 1e-30
    float qab = a + b
    float qap = a + 1.0
    float qam = a - 1.0
    float c = 1.0
    float d = 1.0 - qab * x / qap
    d := math.abs(d) < FPMIN ? FPMIN : d
    d := 1.0 / d
    float h = d
    bool done = false
    for m = 1 to 200
        if not done
            float m2 = m * 2.0
            float aa1 = m * (b - m) * x / ((qam + m2) * (a + m2))
            d := 1.0 + aa1 * d
            d := math.abs(d) < FPMIN ? FPMIN : d
            c := 1.0 + aa1 / c
            c := math.abs(c) < FPMIN ? FPMIN : c
            d := 1.0 / d
            h := h * d * c
            float aa2 = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
            d := 1.0 + aa2 * d
            d := math.abs(d) < FPMIN ? FPMIN : d
            c := 1.0 + aa2 / c
            c := math.abs(c) < FPMIN ? FPMIN : c
            d := 1.0 / d
            float del = d * c
            h := h * del
            if math.abs(del - 1.0) < 3.0e-7
                done := true
    h
f_betai(float a, float b, float x) =>
    float r = na
    if x <= 0.0
        r := 0.0
    else if x >= 1.0
        r := 1.0
    else
        float bt = math.exp(f_lgamma(a + b) - f_lgamma(a) - f_lgamma(b) + a * math.log(x) + b * math.log(1.0 - x))
        r := x < (a + 1.0) / (a + b + 2.0) ? bt * f_betacf(a, b, x) / a : 1.0 - bt * f_betacf(b, a, 1.0 - x) / b
    r
f_tcdf(float x, float df) =>
    float z  = df / (df + x * x)
    float ib = f_betai(df / 2.0, 0.5, z)
    x >= 0.0 ? 1.0 - 0.5 * ib : 0.5 * ib
// compact volume formatter (k / M / B) — avoids giant raw numbers in the panel
f_vol(float v) =>
    float a = math.abs(v)
    a >= 1e9 ? str.tostring(v / 1e9, "0.0") + "B" : a >= 1e6 ? str.tostring(v / 1e6, "0.0") + "M" : a >= 1e3 ? str.tostring(v / 1e3, "0.0") + "k" : str.tostring(v, "0")
// Wilson score interval half-width is now cal.wilsonHalf at the call sites (v2.13) — identical formula,
// shared suite definition (the library returns a percent, so call sites ÷100 to keep the 0..1 scale).
// tick-precise price with thousands separators (v2.13 UX, from RedK MMTStop) — clean price readouts
f_fixtick(float v) => na(v) ? "—" : str.tostring(math.round_to_mintick(v), "#,###.######")

// Bin index for a price on a [minP, minP + rows*binH) grid (v3.0 · POC/Value-Area context).
f_bin(float price, float minP, float binH, int rows) =>
    binH <= 0 ? 0 : math.max(0, math.min(rows - 1, int(math.floor((price - minP) / binH))))

// ── MADP layer helpers (v3.1 — ported from Multi-Anchor Delta Profile; args + built-ins only) ──
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
// Triangular candle-direction pressure in [-1, 1] (>0 = buy-side): a graded refinement of sign(c-o).
f_side(float o, float h, float l, float c) =>
    float rng = h - l
    float dm  = 0.5
    if rng <= 0
        dm := c > o ? 1.0 : c < o ? 0.0 : 0.5
    else
        float op = math.max(math.min(o, h), l)
        float md = math.max(math.min(c, h), l)
        float cdf = 0.0
        if md == l
            cdf := op <= l ? 0.0 : 1.0 - math.pow((h - op) / rng, 2)
        else if md == h
            cdf := op >= h ? 1.0 : math.pow((op - l) / rng, 2)
        else
            float lw = md - l
            float rw = h - md
            if op <= l
                cdf := 0.0
            else if op <= md
                cdf := math.pow(op - l, 2) / (rng * lw)
            else if op < h
                cdf := 1.0 - math.pow(h - op, 2) / (rng * rw)
            else
                cdf := 1.0
        dm := 1.0 - cdf
    2.0 * dm - 1.0
// nearest-rank percentile of a copied+sorted array (na if empty)
f_pctile(array<float> src, float p) =>
    int n = src.size()
    float res = na
    if n > 0
        array<float> c = src.copy()
        c.sort()
        int idx = math.max(0, math.min(n - 1, int(math.floor(p / 100.0 * (n - 1)))))
        res := c.get(idx)
    res
f_tierSize(int t) => t == 3 ? size.large : t == 2 ? size.normal : size.small
f_signed(float v) => (v >= 0 ? "+" : "") + str.tostring(v, format.volume)
f_arrow(float v) => v > 0 ? "▲" : v < 0 ? "▼" : "▬"

// MADP anchor state: one accumulating delta profile per HTF anchor
type Slot
    array<float> H
    array<float> L
    array<float> VOL
    array<float> DLT
    float        cvd = 0.0
f_newSlot() => Slot.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), 0.0)
// accumulate one bar's confirmed intrabars; reset on HTF roll (args only, no globals)
f_acc(Slot s, bool reset, array<float> h, array<float> l, array<float> vol, array<float> dlt, int cap) =>
    if reset
        s.H.clear(), s.L.clear(), s.VOL.clear(), s.DLT.clear()
        s.cvd := 0.0
    int n = h.size()
    if n > 0
        for i = 0 to n - 1
            s.H.push(h.get(i))
            s.L.push(l.get(i))
            s.VOL.push(nz(vol.get(i)))
            s.DLT.push(dlt.get(i))
            s.cvd := s.cvd + dlt.get(i)
        while s.H.size() > cap
            s.H.shift(), s.L.shift(), s.VOL.shift(), s.DLT.shift()

// MTF flow — a self-contained per-timeframe net-buying-pressure z (candle-geometry delta, robust z),
// so it can be evaluated on any timeframe via request.security without nested intrabar requests.
f_tfFlowZ(simple int len) =>
    float rng = high - low
    float ev  = na(volume) or volume == 0 ? 1.0 : volume
    float d   = rng > 0 ? ev * ((close - low) - (high - close)) / rng : 0.0
    float med = ta.median(d, len)
    float mad = ta.median(math.abs(d - med), len)
    float z   = mad > 1e-10 ? (d - med) / (1.4826 * mad) : 0.0
    math.max(-4.0, math.min(4.0, z))

// Command Center — ATR trailing stop (Chande-style volatility stop), param-based so it stays pure.
// atrVal is passed in (chart or HTF-anchored) so the stop can trail on the timeframe the signal lives on.
f_cmdTrail(float s, float mult, float atrVal) =>
    float d = mult * atrVal
    var float st = na
    var bool  up = true
    if up
        st := math.max(nz(st, s - d), s - d)
    else
        st := math.min(nz(st, s + d), s + d)
    if up and s < st
        up := false
        st := s + d
    else if not up and s > st
        up := true
        st := s - d
    [st, up]

// MTF-STACK pack — computed ON each requested timeframe via request.security. Bundles
// that TF's flow-z (the flip signal) and its own ATR trailing stop into one call, so a
// full rung costs a SINGLE security call. Pure (no nested security) — safe to request.
f_mtfPack(simple int zlen, float mult, simple int atrLenIn) =>
    float z = f_tfFlowZ(zlen)
    [st, up] = f_cmdTrail(close, mult, ta.atr(atrLenIn))
    [z, st, up]

// calibration sample
type Ev
    int   dir
    float entry
    float atr0
    int   bidx
    bool  done
    bool  trend = false
    float ext   = na
    float trl   = na

// ═════════════════════════════════════════════════════════════════════════════
// ASSET-CLASS / VOLUME SOURCE — one switch makes the whole engine asset-agnostic.
// "Chart" = this instrument's own OHLCV (NIFTY-default, unchanged). "External (futures)" routes every
// FLOW/VOLUME read to a matching futures symbol: the per-TF dispatches (spine intrabars, size-split,
// MTF ladder, MADP profile) follow _flowSym; the bar-level reads (BVC Δprice & volume, geometry,
// whale percentile, value-area weight) follow fH/fL/fC/fV. Price drawn on the chart, the trailing
// stop and the trade levels are never changed. _flowSym is a simple string (no security nesting).
// ═════════════════════════════════════════════════════════════════════════════
bool   _extVol  = volMode == "External (futures)"
string _flowSym = _extVol ? volExtSym : syminfo.tickerid
[_efH, _efL, _efC, _efV] = request.security(_flowSym, timeframe.period, [high, low, close, volume], lookahead = barmerge.lookahead_off)
float fH = _extVol ? nz(_efH) : high
float fL = _extVol ? nz(_efL) : low
float fC = _extVol ? nz(_efC) : close
float fV = _extVol ? nz(_efV) : volume

// ═════════════════════════════════════════════════════════════════════════════
// STAGE 0 · DELTA SPINE — reconstruct buy vs sell pressure ONCE
// ═════════════════════════════════════════════════════════════════════════════
float _effRaw = _extVol ? fV : srcVol
float effVol  = na(_effRaw) or _effRaw == 0 ? 1.0 : _effRaw
float _pFlow  = _extVol ? fC : srcPrice
float chg     = _pFlow - _pFlow[1]
float bvcSig  = ta.stdev(chg, zLen)

float buyV  = 0.0
float sellV = 0.0
if classMethod == "Intrabar Tick Rule"
    [aO, aC, aV] = request.security_lower_tf(_flowSym, ltf, [open, close, srcVol])
    if array.size(aC) > 0
        bool  _useTick = tickBasis == "Tick rule (vs prior close)"
        float _prevC   = na
        int   _lastSg  = 1
        for i = 0 to array.size(aC) - 1
            float o = array.get(aO, i)
            float c = array.get(aC, i)
            float v = array.get(aV, i)
            float vv = na(v) or v == 0 ? 1.0 : v
            // signing reference: prior sub-bar close (true tick test) or the sub-bar's own open (candle)
            float refp = _useTick ? (na(_prevC) ? o : _prevC) : o
            int   sg   = c > refp ? 1 : c < refp ? -1 : (_useTick ? _lastSg : 0)
            if sg > 0
                buyV += vv
            else if sg < 0
                sellV += vv
            else
                buyV  += vv * 0.5
                sellV += vv * 0.5
            _lastSg := sg != 0 ? sg : _lastSg
            _prevC  := c
if classMethod == "Bulk Volume Classification"
    float zb = bvcSig > 0 ? chg / bvcSig : 0.0
    float bf = bvcDist == "Student-t (research)" ? f_tcdf(zb, bvcDf) : ncdf(zb)
    buyV  := effVol * bf
    sellV := effVol * (1.0 - bf)
if classMethod == "Candle Geometry" or (buyV + sellV == 0.0)
    float rng0 = fH - fL
    if rng0 > 0
        buyV  := effVol * (fC - fL) / rng0
        sellV := effVol * (fH - fC) / rng0
    else
        buyV  := effVol * 0.5
        sellV := effVol * 0.5

float totV     = buyV + sellV
float rawDelta = buyV - sellV

// ═════════════════════════════════════════════════════════════════════════════
// STAGE 1 · PRESSURE READ — standardized net buying pressure
// ═════════════════════════════════════════════════════════════════════════════
// Wave A: compute classic and robust standardization unconditionally, then select
float dMean  = ta.sma(rawDelta, zLen)
float dSd    = ta.stdev(rawDelta, zLen)
float dMed   = ta.median(rawDelta, zLen)
float dMad   = ta.median(math.abs(rawDelta - dMed), zLen)
float deltaZc = dSd > 0 ? (rawDelta - dMean) / dSd : 0.0
float deltaZr = dMad > 1e-10 ? (rawDelta - dMed) / (1.4826 * dMad) : 0.0
float deltaZ = zMode == "Classic (mean/stdev)" ? deltaZc : deltaZr
deltaZ := math.max(-4.0, math.min(4.0, deltaZ))
float buyPress  = 50.0 * (1.0 + squash(deltaZ * 0.9))
float sellPress = 100.0 - buyPress

// session-anchored cumulative delta (context + divergence-ready export)
// ta.change hoisted to global scope so it evaluates every bar (clears CW10002)
float sessChg = ta.change(time("D"))
bool newSess = anchorSess and nz(sessChg, 0) != 0
var float cvd = 0.0
cvd := (newSess or na(cvd[1])) ? rawDelta : nz(cvd[1]) + rawDelta

// plain-language state from the pressure read
bool strongBuy  = deltaZ >  1.5
bool strongSell = deltaZ < -1.5
bool buyBias    = deltaZ >  0.5
bool sellBias   = deltaZ < -0.5
string stateTxt = strongBuy ? "STRONG BUYING" : strongSell ? "STRONG SELLING" : buyBias ? "BUYING" : sellBias ? "SELLING" : "BALANCED"

// ── VSA BAR EVENTS (Wave D · U9 — ml_vsa effort-vs-result taxonomy, inlined) ──
// Self-contained, non-repainting one-bar classifications; all ta.* evaluated unconditionally.
bool  vsaHasVol = not na(volume) and volume > 0
float vsaSp   = ta.percentrank(high - low, vsaLen)
// U11 (Wave D): optional time-of-day volume baseline (ml_session slotMean, inlined). "Heavy" is
// judged against the same wall-clock slot on prior sessions. State advances every bar (array EMA,
// no ta.*) so the baseline stays warm whether or not the switch is on.
// time-of-day volume baseline is now sess.slotRatio (v2.13) — identical per-slot EMA (same alpha, slot
// map and ratio); one shared suite definition. nz(…,1.0) reproduces the inline 1.0 cold-start fallback.
float vsaVolRatio = nz(sess.slotRatio(volume, sess.slotOf(vsaTodMin), sess.slotCount(vsaTodMin), sess.sessionAlpha(vsaTodSes)), 1.0)
float vsaVolUse   = vsaTod ? vsaVolRatio : volume
float vsaVp   = ta.percentrank(vsaVolUse,     vsaLen)
float vsaVpk  = ta.highest(vsaVolUse, vsaLen)                  // volume peak in the window
float vsaRng  = high - low
float vsaCp   = vsaRng > 0.0 ? (close - low) / vsaRng : 0.5
float vsaPHi  = ta.highest(high, vsaPiv)[1]
float vsaPLo  = ta.lowest(low,  vsaPiv)[1]
bool  vsaUpB  = close > close[1]
bool  vsaDnB  = close < close[1]
bool  vUpthrust = vsaHasVol and (high >= vsaPHi) and vsaCp <= 0.35 and vsaVp >= 60.0
bool  vShakeout = vsaHasVol and (low  <= vsaPLo) and vsaCp >= 0.65 and vsaVp >= 60.0
bool  vStopping = vsaHasVol and vsaDnB and vsaSp >= 60.0 and vsaVp >= 80.0 and vsaCp >= 0.45
bool  vClimaxUp = vsaHasVol and vsaUpB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
bool  vClimaxDn = vsaHasVol and vsaDnB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
bool  vNoDemand = vsaHasVol and vsaUpB and vsaSp <= 35.0 and vsaVp <= 35.0
bool  vNoSupply = vsaHasVol and vsaDnB and vsaSp <= 35.0 and vsaVp <= 35.0
// dominant event (priority: climax > trap > stopping > no-demand/supply) → one label, one marker
string vsaEvt = vClimaxUp ? "Buying climax" : vClimaxDn ? "Selling climax" : vUpthrust ? "Upthrust" : vShakeout ? "Shakeout" : vStopping ? "Stopping volume" : vNoDemand ? "No demand" : vNoSupply ? "No supply" : "—"
int    vsaBiasVal = (vClimaxDn or vShakeout or vStopping or vNoSupply) ? 1 : (vClimaxUp or vUpthrust or vNoDemand) ? -1 : 0
color  vsaEvtCol  = vsaBiasVal > 0 ? bullCol : vsaBiasVal < 0 ? bearCol : midColr

// ── ABSORPTION CONSENSUS (Wave E · U9 — 4-way effort-vs-result, inlined) ──────────
// Bolts onto the read socket: consumes the SAME spine (rawDelta / buyV / sellV) and the
// SAME VSA percentiles (vsaVp / vsaSp). Four independent absorption measures; a bar is only
// "absorption" when >= absMinAgree agree. All ta.* evaluated unconditionally (non-repainting).
// (1) OLS residual z of Δprice regressed on signed delta (flow arrived, price under-moved)
float abMx    = ta.sma(rawDelta, absLen)
float abMy    = ta.sma(chg, absLen)
float abCov   = ta.sma(rawDelta * chg, absLen) - abMx * abMy
float abVx    = ta.sma(rawDelta * rawDelta, absLen) - abMx * abMx
float abB     = abVx > 1e-12 ? abCov / abVx : na
float abA     = na(abB) ? abMy : abMy - abB * abMx
float abResid = (na(abA) or na(abB)) ? na : chg - (abA + abB * rawDelta)
float abRMu   = ta.sma(abResid, absLen)
float abRSd   = ta.stdev(abResid, absLen)
float abResidZ= abRSd > 1e-12 ? (abResid - abRMu) / abRSd : na
// (2) cost-per-tick percentile (|delta| per tick of move — high = absorption)
float abTicks = math.abs(chg) / syminfo.mintick
float abCost  = math.abs(rawDelta) / math.max(abTicks, 1e-9)
float abCostP = ta.percentrank(abCost, absLen)
// (3) dominance − result (a side dominated the flow but price under-delivered)
float abNet   = totV > 0.0 ? (buyV - sellV) / totV : 0.0
float abBuyD  = math.max(abNet, 0.0)
float abSellD = math.max(-abNet, 0.0)
float abRng   = high - low
float abClvU  = abRng > 0.0 ? (close - low) / abRng : 0.5
float abBodU  = abRng > 0.0 ? math.max(close - open, 0.0) / abRng : 0.0
float abBodD  = abRng > 0.0 ? math.max(open - close, 0.0) / abRng : 0.0
float abBuyR  = (abBodU + abClvU) / 2.0
float abSellR = (abBodD + (1.0 - abClvU)) / 2.0
float abBuyA  = abBuyD - abBuyR
float abSellA = abSellD - abSellR
float abDomSc = math.max(abBuyA, abSellA)
int   abSide  = abBuyA >= abSellA ? 1 : -1
// (4) qualitative: high effort, narrow spread (reuses vsaVp / vsaSp)
bool  abQual  = vsaVp >= 70.0 and vsaSp <= 35.0
// consensus
int   abC  = (not na(abResidZ) and math.abs(abResidZ) >= absZThr ? 1 : 0) + (not na(abCostP) and abCostP >= absCostThr ? 1 : 0) + (abDomSc >= absDomThr ? 1 : 0) + (abQual ? 1 : 0)
bool  abIs = abC >= absMinAgree
string absTxt = abIs ? (abSide > 0 ? "BUY absorb (" + str.tostring(abC) + "/4)" : "SELL absorb (" + str.tostring(abC) + "/4)") : abC >= 1 ? "watch (" + str.tostring(abC) + "/4)" : "—"
color  absCol = abIs ? (abSide > 0 ? bullCol : bearCol) : midColr

// ── READ SOCKET ──────────────────────────────────────────────────────────────
// Additional orthogonal reads bolt on here, each consuming the spine above:
//   persistence (Hawkes/autocorr) · efficiency (Kyle λ) · toxicity (VPIN) ·
//   absorption (delta vs stalled range) · divergence (price vs cvd).
// Each adds its own calibrated signal and one dashboard row — nothing else.
// ─────────────────────────────────────────────────────────────────────────────

// ── FLOW TOXICITY (Wave F · VPIN volume-clock; from the VPIN Flow-Toxicity Oscillator) ──
// Equal-VOLUME buckets (not time bars): buy/sell/vol accumulate until a bucket fills, then the
// bucket's |buy−sell|/size imbalance is pushed to a rolling window; toxicity = mean bucket
// imbalance, percentile-ranked 0..100 (self-calibrating). High toxicity = one-sided, informed
// flow (adverse selection) — the whipsaw regime — so MTF flips are OPTIONALLY suppressed there.
float toxTgt = ta.sma(effVol, 50) * toxBktVol
var float toxCuB = 0.0
var float toxCuS = 0.0
var float toxCuV = 0.0
var array<float> toxImb = array.new<float>()
var float toxLevel = na
toxCuB += buyV
toxCuS += sellV
toxCuV += totV
if toxOn and toxTgt > 0.0 and toxCuV >= toxTgt
    array.push(toxImb, math.abs(toxCuB - toxCuS) / toxTgt)
    if array.size(toxImb) > toxNBkt
        array.shift(toxImb)
    toxLevel := array.avg(toxImb)
    toxCuB := 0.0
    toxCuS := 0.0
    toxCuV := 0.0
float toxPct   = ta.percentrank(nz(toxLevel), toxRankLen)
bool  toxReady = array.size(toxImb) >= math.min(toxNBkt, 10)
bool  toxHiNow = toxOn and toxReady and not na(toxLevel) and not na(toxPct) and toxPct >= toxHi
bool  toxOK    = (not toxOn) or (not toxSuppress) or (not toxHiNow)
string toxTxt  = (not toxReady or na(toxPct)) ? "warming" : toxHiNow ? "TOXIC " + str.tostring(toxPct, "0") + "%" : toxPct >= 50.0 ? "elevated " + str.tostring(toxPct, "0") + "%" : "calm " + str.tostring(toxPct, "0") + "%"
color  toxCol  = toxHiNow ? bearCol : (not na(toxPct) and toxPct >= 50.0) ? midColr : bullCol

// ── PRICE IMPACT (Wave G · v1.4 · Kyle's lambda, inlined; from Volume-Flow Pressure) ──
// Rolling regression of |Δprice| on |signed delta| — price move per unit of flow. High percentile =
// flow moves price efficiently (participation / trend); low = flow absorbed (reversal / exhaustion).
float impSv    = math.abs(rawDelta)
float impDp    = math.abs(chg)
float impMx    = ta.sma(impSv, impLen)
float impMy    = ta.sma(impDp, impLen)
float impCov   = ta.sma(impSv * impDp, impLen) - impMx * impMy
float impVar   = ta.sma(impSv * impSv, impLen) - impMx * impMx
float impLam   = impVar > 1e-12 ? impCov / impVar : na
float impPctR  = ta.percentrank(nz(impLam), impLen)
float impPct   = na(impLam) ? na : impPctR
// Kyle-λ R² — share of price variance that order flow actually explains (0..1). A bounded, directly
// interpretable impact measure (cf. flow.kyleR2 in the sibling scripts); shown on the Impact row, and
// optionally the conviction impact factor (group 16 · "Fold Kyle-λ R² into signal conviction").
float impVarY  = ta.sma(impDp * impDp, impLen) - impMy * impMy
float impR2    = (impVar > 1e-12 and impVarY > 1e-12) ? math.max(0.0, math.min(1.0, (impCov * impCov) / (impVar * impVarY))) : na
string impTxt  = na(impPct) ? "warming" : (impPct >= 70.0 ? "efficient " + str.tostring(impPct, "0") + "%" : impPct <= 30.0 ? "absorbed " + str.tostring(impPct, "0") + "%" : "normal " + str.tostring(impPct, "0") + "%") + (na(impR2) ? "" : " · R²" + str.tostring(impR2, "0.00"))
color  impCol  = na(impPct) ? midColr : impPct >= 70.0 ? bullCol : impPct <= 30.0 ? bearCol : midColr

// ── SIZE-STRATIFIED DELTA (Wave M · v2.1) — BIG-lot (institutional) vs SMALL-lot (retail) flow ──
// Split each bar's sub-bars into big/small by volume, sign each by close-vs-open, and accumulate two
// separate deltas. Big-lot flow diverging from small-lot is the "who is doing this" tell.
[ssO, ssC, ssV] = request.security_lower_tf(_flowSym, ltf, [open, close, srcVol])
float bigDelta = 0.0
float smlDelta = 0.0
if sizeOn and array.size(ssV) > 0
    float sAvg = array.avg(ssV)
    float sThr = sAvg * sizeMult
    for i = 0 to array.size(ssV) - 1
        float so = array.get(ssO, i)
        float sc = array.get(ssC, i)
        float sv = array.get(ssV, i)
        float svv = na(sv) ? 0.0 : sv
        float sg  = sc > so ? 1.0 : sc < so ? -1.0 : 0.0
        if svv >= sThr
            bigDelta += sg * svv
        else
            smlDelta += sg * svv
float bigMed = ta.median(bigDelta, sizeZLen)
float bigMad = ta.median(math.abs(bigDelta - bigMed), sizeZLen)
float bigZ   = bigMad > 1e-10 ? (bigDelta - bigMed) / (1.4826 * bigMad) : 0.0
bigZ := math.max(-4.0, math.min(4.0, bigZ))
float smlMed = ta.median(smlDelta, sizeZLen)
float smlMad = ta.median(math.abs(smlDelta - smlMed), sizeZLen)
float smlZ   = smlMad > 1e-10 ? (smlDelta - smlMed) / (1.4826 * smlMad) : 0.0
smlZ := math.max(-4.0, math.min(4.0, smlZ))
bool  sizeDiverge = (bigZ > 0.5 and smlZ < -0.5) or (bigZ < -0.5 and smlZ > 0.5)
string sizeTxt = not sizeOn ? "off" : (bigZ >= 0.5 ? "BIG buying" : bigZ <= -0.5 ? "BIG selling" : "big flat") + (sizeDiverge ? " ⚠vs retail" : "")
color  sizeCol = bigZ >= 0.5 ? bullCol : bigZ <= -0.5 ? bearCol : midColr

// ── FLOW PERSISTENCE (Wave M · v2.1) — lag-1 autocorrelation of signed delta ──
// > 0 self-exciting / trending flow (buying begets buying); < 0 mean-reverting; ≈ 0 random.
float persist = persistOn ? ta.correlation(rawDelta, rawDelta[1], persistLen) : na
string persistTxt = (not persistOn or na(persist)) ? "—" : persist > 0.2 ? "self-exciting " + str.tostring(persist, "0.00") : persist < -0.2 ? "mean-revert " + str.tostring(persist, "0.00") : "random " + str.tostring(persist, "0.00")
color  persistCol = na(persist) ? midColr : persist > 0.2 ? bullCol : persist < -0.2 ? bearCol : midColr

// ── FLOW HURST (Wave M · v2.1) — variance-ratio Hurst of the cumulative-delta path ──
// H = 0.5 + 0.5·log(VR)/log(q), VR = Var(q-step ΔCVD) / (q·Var(1-step ΔCVD)). >0.55 trending, <0.45 revert.
float var1  = ta.variance(rawDelta, hurstLen)
float varQ  = ta.variance(cvd - cvd[hurstLag], hurstLen)
float vr    = (var1 > 1e-12 and hurstLag > 0) ? varQ / (hurstLag * var1) : na
// small-sample / heavy-tail guard — the variance-ratio Hurst is biased until there is enough history
// (Baruník & Kristoufek); hold it as 'warming' until roughly 2× the window has formed.
bool  hurstReady = bar_index >= hurstLen + hurstLag * 2
float hurst = (not hurstOn or not hurstReady or na(vr) or vr <= 0.0) ? na : math.max(0.0, math.min(1.0, 0.5 + 0.5 * math.log(vr) / math.log(hurstLag)))
string hurstTxt = (hurstOn and not hurstReady) ? "warming" : na(hurst) ? "—" : (hurst > 0.55 ? "trending " : hurst < 0.45 ? "mean-revert " : "random ") + str.tostring(hurst, "0.00")
color  hurstCol = na(hurst) ? midColr : hurst > 0.55 ? bullCol : hurst < 0.45 ? bearCol : midColr

// combined flow-regime character (used by the regime read + reversal/continuation tag)
bool flowTrending  = (persistOn and not na(persist) and persist > 0.2) or (hurstOn and not na(hurst) and hurst > 0.55)
bool flowReverting = (persistOn and not na(persist) and persist < -0.2) or (hurstOn and not na(hurst) and hurst < 0.45)

// ── FLOW-vs-PRICE LEAD (Wave N · v2.2 — Lévy-area path-signature, from the Lévy-Area Flow Sequencer) ──
// A = Σ(X·dy − Y·dx) over the window, flow (rawDelta) and price increments each normalized to unit
// scale → dimensionless signed area. A>0 flow leads (participation precedes price); A<0 price leads.
f_emaSeed(float x, simple int len) =>
    var float e = na
    float a = 2.0 / (len + 1)
    e := na(x) ? e : na(e) ? x : e + a * (x - e)
    e
float levyPc  = srcPrice - nz(srcPrice[1], srcPrice)
float levySdx = ta.stdev(rawDelta, levyWin)
float levySdy = ta.stdev(levyPc, levyWin)
f_levyArea() =>
    float a = na
    if bar_index >= levyWin + 2 and levySdx > 0 and levySdy > 0
        float acc = 0.0
        float Xp  = 0.0
        float Yp  = 0.0
        for k = 0 to levyWin - 1
            int off = levyWin - 1 - k
            float dx = nz(rawDelta[off]) / levySdx
            float dy = nz(levyPc[off]) / levySdy
            acc += Xp * dy - Yp * dx
            Xp += dx
            Yp += dy
        a := acc / levyWin
    a
var float levyRaw = na
if levyOn and showEngine and barstate.isconfirmed
    levyRaw := f_levyArea()
float levyArea = levyOn ? f_emaSeed(levyRaw, levySmooth) : na
float levyRank = not na(levyArea) ? ta.percentrank(nz(math.abs(levyArea), 0.0), levyLook) : na
bool  levyReady = levyOn and not na(levyRank) and bar_index > levyWin + levyLook / 2
bool  levySig   = levyReady and levyRank >= levySigLvl
int   leadState = not levyReady ? -9 : levySig ? (levyArea > 0 ? 1 : -1) : 0
string leadTxt  = not levyOn ? "off" : leadState == -9 ? "warming" : leadState == 1 ? "FLOW leads" : leadState == -1 ? "PRICE leads (chasing)" : "balanced"
color  leadCol  = leadState == 1 ? bullCol : leadState == -1 ? bearCol : midColr

// ═════════════════════════════════════════════════════════════════════════════
// STAGE 2 · SIGNALS (once per excursion)
// ═════════════════════════════════════════════════════════════════════════════
bool rawLong  = ta.crossover(deltaZ,  sigThr)
bool rawShort = ta.crossunder(deltaZ, -sigThr)
var bool longArmed  = true
var bool shortArmed = true
bool longRaw  = rawLong  and longArmed
bool shortRaw = rawShort and shortArmed
// arming disarms on the raw excursion event so once-per-excursion behaviour is preserved
longArmed  := longRaw  ? false : (deltaZ <= 0.0 ? true : longArmed)
shortArmed := shortRaw ? false : (deltaZ >= 0.0 ? true : shortArmed)
// REGIME GATE (Wave C) — optional Kaufman efficiency-ratio filter, default Off. Applied to the
// actionable events only; arming above is unaffected.
// efficiency ratio is now cal.efficiencyRatio (v2.13) — identical formula, shared suite definition
float regER     = cal.efficiencyRatio(srcPrice, regErLen)
bool  regTrend  = regER >= regErThr
bool  regOK     = regGate == "Off" ? true : regGate == "Favor trending" ? regTrend : not regTrend
bool longEvt  = longRaw  and regOK
bool shortEvt = shortRaw and regOK

// ═════════════════════════════════════════════════════════════════════════════
// STAGE 3 · FORWARD CALIBRATION — relocated below (after the MTF confluence gate) so it can grade
// the confluence-gated flip actually shown on the chart (v1.4 self-validating scoreboard).
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
// THEME
// ═════════════════════════════════════════════════════════════════════════════
bool dark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_luma(chart.bg_color) < 140
color panelBg = dark ? color.rgb(17, 22, 28)   : color.rgb(244, 246, 248)
color rowAlt  = dark ? color.rgb(25, 31, 39)   : color.rgb(232, 236, 240)
color pTxt    = dark ? color.rgb(154,166,178)  : color.rgb(74, 82, 91)
color pStr    = dark ? color.rgb(236,239,243)  : color.rgb(16, 20, 24)
color frameC  = dark ? color.rgb(58, 70, 84)   : color.rgb(196,204,212)
color gridC   = dark ? color.new(color.gray, 55) : color.new(color.gray, 45)
// adaptive on-chart accent (visible on dark AND light backgrounds): trailing-line flip number
color flipYel = dark ? #ffd24d : #9a6b00

// ═════════════════════════════════════════════════════════════════════════════
// VALUE-AREA CONTEXT (v3.0) — lightweight anchored volume profile: POC / VAH / VAL
// The engine reads flow direction/strength/size/sequencing but had no sense of WHERE on price that
// happens. This adds the location layer: a flip AT a high-volume node is a level being defended
// (higher quality); a flip in no-man's-land is fade-risk. Recomputed once per confirmed bar
// (non-repainting) and cached. Adapted from the Multi-Anchor Delta Profile.
// ═════════════════════════════════════════════════════════════════════════════
var float pocP = na
var float vahP = na
var float valP = na
// range computed unconditionally (ta.* must run every bar for consistent state); binning is gated
float hiP = ta.highest(high, pocLook)
float loP = ta.lowest(low, pocLook)
if pocOn and barstate.isconfirmed
    if not na(hiP) and not na(loP) and hiP > loP
        float bw = (hiP - loP) / pocBins
        array<float> vBin = array.new<float>(pocBins, 0.0)
        for k = 0 to pocLook - 1
            int b0 = f_bin(low[k], loP, bw, pocBins)
            int b1 = f_bin(high[k], loP, bw, pocBins)
            int span = math.max(1, b1 - b0 + 1)
            float vpp = nz(fV[k], 1.0) / span
            for x = b0 to b1
                vBin.set(x, vBin.get(x) + vpp)
        float maxV = vBin.max()
        float tot  = vBin.sum()
        if maxV > 0 and tot > 0
            int pIdx = vBin.indexof(maxV)
            int loI = pIdx
            int hiI = pIdx
            float vaSum = vBin.get(pIdx)
            float target = tot * pocVApct
            while vaSum < target and (loI > 0 or hiI < pocBins - 1)
                float dLo = loI > 0 ? vBin.get(loI - 1) : -1.0
                float dHi = hiI < pocBins - 1 ? vBin.get(hiI + 1) : -1.0
                if dHi >= dLo
                    hiI += 1
                    vaSum += vBin.get(hiI)
                else
                    loI -= 1
                    vaSum += vBin.get(loI)
            pocP := loP + bw * (pIdx + 0.5)
            vahP := loP + bw * (hiI + 1)
            valP := loP + bw * loI
// location read (used by conviction + the dashboard 'Value' row)
float pocTolPx = pocTol * nz(ta.atr(atrLen), 0.0)
bool  atPOC = pocOn and not na(pocP) and math.abs(close - pocP) <= pocTolPx
bool  atVAH = pocOn and not na(vahP) and math.abs(close - vahP) <= pocTolPx
bool  atVAL = pocOn and not na(valP) and math.abs(close - valP) <= pocTolPx
bool  nearNode = atPOC or atVAH or atVAL
string valTxt = not pocOn ? "off" : na(pocP) ? "—" : atPOC ? "at POC" : atVAH ? "at VAH (resist)" : atVAL ? "at VAL (support)" : (not na(vahP) and close > vahP) ? "above value" : (not na(valP) and close < valP) ? "below value" : "mid-value"
color valCol = (not pocOn or na(pocP)) ? midColr : nearNode ? flipYel : pTxt
// location → conviction: a flip in no-man's-land (no node nearby) is gently trimmed; at a node = full
float convLoc = (pocOn and pocInConv and not na(pocP) and not nearNode) ? 0.9 : 1.0

// ═════════════════════════════════════════════════════════════════════════════
// MTF ORDER-FLOW ALIGNMENT — net buying pressure across a timeframe ladder
// The high-signal read: a single bar's delta is noise; agreement ACROSS timeframes is meaning.
// v1.5: the ladder can ANCHOR to the chart timeframe so the signal is precise to whatever TF you view
// (chart TF, ×3, ×5, ×15, ×60, ×240, each snapped to the nearest standard TF and capped at Daily).
// ═════════════════════════════════════════════════════════════════════════════
// TIGHT chart-anchored ladder of chart-TF MULTIPLES (compile-safe simple strings): UNIFORM 1× / 3× / 5×
// on every timeframe (chart TF + 2 HTFs). On 1m: 1/3/5 · on 5m: 5/15/25 · on 15m: 15/45/75, etc.
// f_tfMul(k) returns chart-TF × k as a timeframe string (exact minutes, capped at Daily).
f_tfMul(int mult) =>
    float mm = (timeframe.in_seconds() / 60.0) * mult
    mm >= 1440.0 ? "D" : str.tostring(math.max(1, int(math.round(mm))))
string r1 = mtfAnchor ? timeframe.period : mtf1
string r2 = mtfAnchor ? f_tfMul(3)  : mtf2
string r3 = mtfAnchor ? f_tfMul(5)  : mtf3
string r4 = mtfAnchor ? f_tfMul(8)  : mtf4
string r5 = mtfAnchor ? f_tfMul(13) : mtf5
string r6 = mtfAnchor ? f_tfMul(21) : mtf6
float mz1 = request.security(_flowSym, r1, f_tfFlowZ(mtfZlen), lookahead = barmerge.lookahead_off)
float mz2 = request.security(_flowSym, r2, f_tfFlowZ(mtfZlen), lookahead = barmerge.lookahead_off)
float mz3 = request.security(_flowSym, r3, f_tfFlowZ(mtfZlen), lookahead = barmerge.lookahead_off)
float mz4 = request.security(_flowSym, r4, f_tfFlowZ(mtfZlen), lookahead = barmerge.lookahead_off)
float mz5 = request.security(_flowSym, r5, f_tfFlowZ(mtfZlen), lookahead = barmerge.lookahead_off)
float mz6 = request.security(_flowSym, r6, f_tfFlowZ(mtfZlen), lookahead = barmerge.lookahead_off)
f_mtfSgn(float z) => na(z) ? 0 : z > mtfNeut ? 1 : z < -mtfNeut ? -1 : 0
// ACTIVE rungs — chart TF + the next mtfHtfN higher TFs count when anchored (all 6 when not anchored)
bool a2 = (not mtfAnchor) or mtfHtfN >= 1
bool a3 = (not mtfAnchor) or mtfHtfN >= 2
bool a4 = (not mtfAnchor) or mtfHtfN >= 3
bool a5 = (not mtfAnchor) or mtfHtfN >= 4
bool a6 = (not mtfAnchor) or mtfHtfN >= 5
int mtfAlign = f_mtfSgn(mz1) + (a2 ? f_mtfSgn(mz2) : 0) + (a3 ? f_mtfSgn(mz3) : 0) + (a4 ? f_mtfSgn(mz4) : 0) + (a5 ? f_mtfSgn(mz5) : 0) + (a6 ? f_mtfSgn(mz6) : 0)
int mtfMax = 1 + (a2 ? 1 : 0) + (a3 ? 1 : 0) + (a4 ? 1 : 0) + (a5 ? 1 : 0) + (a6 ? 1 : 0)   // max achievable |align|
int effThr = math.max(2, math.min(mtfThr, mtfMax))                                          // threshold, capped to active count
// WEIGHTED MTF FLOW INDEX over ACTIVE rungs (higher TFs weigh more) + its VELOCITY (speed of flow).
float wAct = 1.0 + (a2 ? 1.2 : 0.0) + (a3 ? 1.5 : 0.0) + (a4 ? 2.0 : 0.0) + (a5 ? 2.6 : 0.0) + (a6 ? 3.2 : 0.0)
float mfi    = (1.0*nz(mz1) + (a2 ? 1.2*nz(mz2) : 0.0) + (a3 ? 1.5*nz(mz3) : 0.0) + (a4 ? 2.0*nz(mz4) : 0.0) + (a5 ? 2.6*nz(mz5) : 0.0) + (a6 ? 3.2*nz(mz6) : 0.0)) / (wAct > 0.0 ? wAct : 1.0)
float mfiVel = mfi - nz(mfi[mtfVelLen])
// FUSED SIGNAL CONVICTION 0..100 (v1.6 — borrowed from Ctrl+Path / MTF OrderFlow Cockpit: ONE
// probability decides act/no-act). Direction+strength come from a weighted-MEAN log-odds of the
// ladder (mfi — higher TFs weigh more, a MEAN so redundant timeframes can't inflate it). That is then
// folded with EFFORT-vs-RESULT: low price impact (strong flow NOT moving price), absorption, toxicity
// and chop each PULL CONVICTION DOWN — so a big-but-absorbed push can no longer look like a precise
// signal. This is the fix for "signals not precise".
float pUp      = 1.0 / (1.0 + math.exp(-loGain * mfi))                          // win-probability from the flow index
float convBase = math.abs(2.0 * pUp - 1.0)                                      // 0 (coin-flip) .. 1 (one-sided)
float convReg  = 0.5 + 0.5 * math.min(1.0, regErThr > 0 ? regER / regErThr : regER)   // trend-quality gate 0.5..1
float convImp  = (impUseR2 and not na(impR2)) ? 0.5 + 0.5 * impR2 : (na(impPct) ? 1.0 : 0.5 + 0.5 * (impPct / 100.0))   // λ R² (opt-in) or λ-slope percentile → low impact pulls toward 0.5
float convTox  = toxHiNow ? 0.5 : (na(toxPct) ? 1.0 : 1.0 - 0.4 * (toxPct / 100.0))   // toxic → down
float convAbs  = abIs ? 0.6 : 1.0                                               // absorption (effort, no result) → down
// v2.1: BIG-LOT agreement — gently down-weight only when institutional (big-lot) flow is clearly
// AGAINST the flip; never penalise a flip big money supports (so it filters, doesn't starve).
bool  bigAgainst = (mtfAlign > 0 and bigZ < -0.3) or (mtfAlign < 0 and bigZ > 0.3)
float convSize = (not (sizeOn and sizeInConv)) ? 1.0 : bigAgainst ? 0.8 : 1.0
// v2.2: LÉVY LEAD — trim conviction when PRICE leads (flow chasing); full when FLOW leads / balanced.
float convLevy = (levyOn and levyInConv and leadState == -1) ? 0.85 : 1.0
// v2.12 — CONVICTION REBALANCE (signal-quality fix). The old build multiplied all seven quality factors
// together; each is < 1, so the product collapsed toward zero and almost every signal read "weak" even
// when its forward expectancy was clearly positive. Instead, combine them as a WEIGHTED-AVERAGE penalty
// (impact & toxicity weigh most) blended with the WORST single factor, floored so one soft penalty can
// no longer annihilate conviction while a genuinely bad environment still pulls it down. convBase (the
// ladder's directional log-odds) remains the primary driver, so strength now tracks real edge.
float _penAvg = 0.25 * (1.0 - convImp) + 0.25 * (1.0 - convTox) + 0.20 * (1.0 - convReg) + 0.12 * (1.0 - convAbs) + 0.08 * (1.0 - convSize) + 0.05 * (1.0 - convLevy) + 0.05 * (1.0 - convLoc)
float _qMin   = math.min(convImp, math.min(convTox, math.min(convReg, math.min(convAbs, math.min(convSize, math.min(convLevy, convLoc))))))
float qMult   = math.max(0.35, 0.65 * (1.0 - _penAvg) + 0.35 * _qMin)
float mtfConf  = 100.0 * convBase * qMult
bool mtfStrongBull = mtfOn and mtfAlign >=  effThr and ((not mtfUseVel) or mfiVel >=  mtfVelThr)
bool mtfStrongBear = mtfOn and mtfAlign <= -effThr and ((not mtfUseVel) or mfiVel <= -mtfVelThr)
// PRECISION STACK: (a) higher-TF regime must agree, (b) once-per-swing arming, (c) hard cooldown.
// A signal survives only if the whole stack agrees, it is the first such bar of the swing, and it is
// spaced from the last one — so clusters cannot form and each mark means "the stack just aligned".
// v1.7.1 — the higher TFs must merely NOT OPPOSE the trade (neutral is fine). Requiring them to
// STRICTLY confirm blocked almost all signals, because the slowest anchored rung (e.g. Daily on a 5m
// chart) sits neutral much of the time. "Don't trade against the HTF" — not "wait for the HTF to lead".
// highest two ACTIVE rungs (the top of whatever ladder width is in use)
float hzTop = a6 ? mz6 : a5 ? mz5 : a4 ? mz4 : a3 ? mz3 : mz2
float hz2nd = a6 ? mz5 : a5 ? mz4 : a4 ? mz3 : a3 ? mz2 : mz1
bool htfBullOK = (not mtfReqHTF) or (f_mtfSgn(hzTop) >= 0 and f_mtfSgn(hz2nd) >= 0)
bool htfBearOK = (not mtfReqHTF) or (f_mtfSgn(hzTop) <= 0 and f_mtfSgn(hz2nd) <= 0)
var bool mtfBullArmed = true
var bool mtfBearArmed = true
var int  lastMtfSigBar = -100000
bool mtfCoolOK = (bar_index - lastMtfSigBar) >= mtfCooldown
bool mtfConfOK = mtfConf >= mtfMinConf
bool mtfFlipBull = mtfStrongBull and mtfBullArmed and htfBullOK and mtfCoolOK and mtfConfOK
bool mtfFlipBear = mtfStrongBear and mtfBearArmed and htfBearOK and mtfCoolOK and mtfConfOK
// v1.7 arming: re-arm when the STRONG-alignment episode ENDS (|align| drops below the threshold), not
// only on a full flip to the opposite side — so a sustained trend gives one signal per fresh strong
// episode instead of one signal per multi-thousand-bar swing (the "3796 bars ago" problem).
mtfBullArmed := mtfFlipBull ? false : (mtfAlign <  effThr ? true : mtfBullArmed)
mtfBearArmed := mtfFlipBear ? false : (mtfAlign > -effThr ? true : mtfBearArmed)
var float lastMtfConf = na
var int   lastMtfDir  = 0
var int   lastMtfBar2 = na
// cooldown spacing tracks the RAW alignment event (arming/spacing unaffected by the confluence gate);
// the displayed-signal memory (dir/confidence/age) is updated later on the CONFLUENCE-gated flip.
if mtfFlipBull or mtfFlipBear
    lastMtfSigBar := bar_index
// gate the chart-TF pressure triangles so only MTF-agreeing signals print
bool mtfBuyOK  = (not mtfOn) or (not mtfGate) or mtfAlign > 0
bool mtfSellOK = (not mtfOn) or (not mtfGate) or mtfAlign < 0
string mtfTxt = mtfStrongBull ? "ALIGNED BUY " + str.tostring(mtfAlign) + "/" + str.tostring(mtfMax) : mtfStrongBear ? "ALIGNED SELL " + str.tostring(mtfAlign) + "/" + str.tostring(mtfMax) : "mixed " + (mtfAlign >= 0 ? "+" : "") + str.tostring(mtfAlign)
color mtfCol = mtfAlign >= effThr ? bullCol : mtfAlign <= -effThr ? bearCol : mtfAlign > 0 ? color.new(bullCol, 45) : mtfAlign < 0 ? color.new(bearCol, 45) : midColr

// ═════════════════════════════════════════════════════════════════════════════
// CVD STRUCTURE CHANNEL + MTF CONFLUENCE (Wave F — from the Meridian-Flow CVD channel)
// The cumulative delta's OWN channel: a regression channel on the session-anchored CVD with a
// confirmed breakout of the band. A CVD-channel break is a structural order-flow event; requiring it
// to CONFIRM an MTF aligned flip (within a window) is the precision gate — the flip must carry both
// cross-timeframe agreement AND a real break of cumulative-delta structure. (Regression-channel form
// chosen for compile-safety; the breakout gate is the substance, not the drawing.)
// ═════════════════════════════════════════════════════════════════════════════
float cvdBasis  = ta.linreg(cvd, cvdChanLen, 0)
float cvdBasis1 = ta.linreg(cvd, cvdChanLen, 1)
float cvdSlope  = cvdBasis - cvdBasis1
float cvdResid  = cvd - cvdBasis
float cvdBandW  = ta.stdev(cvdResid, cvdChanLen) * cvdChanMult
float cvdUpper  = cvdBasis + cvdBandW
float cvdLower  = cvdBasis - cvdBandW
// confirmed breakout of the band (count bars beyond, fire once, re-arm on re-entry, honour cooldown)
bool cvdAbove = cvdChanOn and not na(cvdUpper) and cvd > cvdUpper
bool cvdBelow = cvdChanOn and not na(cvdLower) and cvd < cvdLower
var int  cvdUpCnt = 0
var int  cvdDnCnt = 0
cvdUpCnt := cvdAbove ? cvdUpCnt + 1 : 0
cvdDnCnt := cvdBelow ? cvdDnCnt + 1 : 0
var bool cvdUpBroken = false
var bool cvdDnBroken = false
var int  cvdLastBrkBar = -100000
bool cvdBrkCoolOK = (bar_index - cvdLastBrkBar) >= cvdCooldown
bool cvdBreakUp = false
bool cvdBreakDn = false
if cvdChanOn and (not antiRep or barstate.isconfirmed)
    if cvdUpCnt >= cvdConfirm and not cvdUpBroken and cvdBrkCoolOK
        cvdBreakUp := true
        cvdUpBroken := true
        cvdLastBrkBar := bar_index
    if cvdUpCnt == 0
        cvdUpBroken := false
    if cvdDnCnt >= cvdConfirm and not cvdDnBroken and cvdBrkCoolOK
        cvdBreakDn := true
        cvdDnBroken := true
        cvdLastBrkBar := bar_index
    if cvdDnCnt == 0
        cvdDnBroken := false
var int cvdLastUpBrk = -100000
var int cvdLastDnBrk = -100000
if cvdBreakUp
    cvdLastUpBrk := bar_index
if cvdBreakDn
    cvdLastDnBrk := bar_index
// CVD structure shape from band-width trend (widening = broadening, narrowing = wedge)
bool  cvdWiden  = not na(cvdBandW) and cvdBandW > nz(cvdBandW[20]) * 1.05
bool  cvdNarrow = not na(cvdBandW) and cvdBandW < nz(cvdBandW[20]) * 0.95
string cvdShape = not cvdChanOn ? "off" : cvdWiden ? "broadening" : cvdNarrow ? "wedge" : "parallel"
int   cvdBrkAgeUp = bar_index - cvdLastUpBrk
int   cvdBrkAgeDn = bar_index - cvdLastDnBrk
string cvdTxt = not cvdChanOn ? "off" : (cvdBrkAgeUp <= cvdBrkAgeDn and cvdBrkAgeUp <= cvdGateWin * 3) ? "broke ▲ " + str.tostring(cvdBrkAgeUp) + "b · " + cvdShape : (cvdBrkAgeDn < cvdBrkAgeUp and cvdBrkAgeDn <= cvdGateWin * 3) ? "broke ▼ " + str.tostring(cvdBrkAgeDn) + "b · " + cvdShape : ((not na(cvdUpper) and cvd > cvdUpper) ? "above · " : (not na(cvdLower) and cvd < cvdLower) ? "below · " : "inside · ") + cvdShape
color cvdTxtCol = (not na(cvdUpper) and cvd > cvdUpper) ? bullCol : (not na(cvdLower) and cvd < cvdLower) ? bearCol : (nz(cvdSlope) > 0 ? color.new(bullCol, 40) : nz(cvdSlope) < 0 ? color.new(bearCol, 40) : midColr)

// ── MTF CONFLUENCE GATE — a pending MTF flip fires only when CVD structure AND toxicity confirm ──
// Pending model: a raw MTF alignment sets a pending flip; the DISPLAYED flip fires on the first bar
// within the window where a same-direction CVD breakout is recent and flow is not toxic (same bar if
// both already hold). Gate off / reads off → fires immediately, reproducing v1.2.
bool cvdOKbull = (not cvdChanOn) or (not cvdGate) or ((bar_index - cvdLastUpBrk) <= cvdGateWin)
bool cvdOKbear = (not cvdChanOn) or (not cvdGate) or ((bar_index - cvdLastDnBrk) <= cvdGateWin)
var int mtfPendDir = 0
var int mtfPendBar = -100000
if mtfFlipBull
    mtfPendDir := 1
    mtfPendBar := bar_index
if mtfFlipBear
    mtfPendDir := -1
    mtfPendBar := bar_index
bool pendFresh = mtfPendDir != 0 and (bar_index - mtfPendBar) <= cvdGateWin
// EDGE-GATE (v3.0) — mute flags are maintained by the forward-outcome tracker in STAGE 3 and read HERE
// on the next bar (lagged, non-repainting). A muted side's flip is held until its win-rate recovers.
var bool sideLongMuted  = false
var bool sideShortMuted = false
bool mtfFlipBullShown = false
bool mtfFlipBearShown = false
// RAW confluence-gated flip = BEFORE the edge-gate mute. Calibration + the edge-gate's rolling win-rate
// learn from RAW, so the scoreboard keeps updating EVEN WHILE a side is muted. Otherwise a muted side
// fires nothing → no resolved samples → its win-rate freezes → it can never recover above the un-mute
// ceiling → permanent mute (v3.1.1 deadlock fix). DISPLAY (labels / plan / latch) uses the muted 'Shown'.
bool mtfFlipBullRaw = false
bool mtfFlipBearRaw = false
// 1m soft-suppress: the flip's forward expectancy is negative below 2m (validated), positive on 3m+.
bool tfOKforFlip = (not flip1mSup) or timeframe.in_seconds() >= 120
if pendFresh and mtfPendDir > 0 and cvdOKbull and toxOK
    mtfFlipBullRaw := true
    mtfFlipBullShown := tfOKforFlip and not (edgeGate and sideLongMuted)
    mtfPendDir := 0
if pendFresh and mtfPendDir < 0 and cvdOKbear and toxOK
    mtfFlipBearRaw := true
    mtfFlipBearShown := tfOKforFlip and not (edgeGate and sideShortMuted)
    mtfPendDir := 0
// displayed-signal memory (dashboard) tracks the confluence-gated flip actually shown on the chart
// v1.6: tag each flip TREND-COHERENTLY. Because a shown flip is gated to the higher-TF regime, a flip
// WITH a trending tape is a CONTINUATION, never a "reversal". Reversal (fade) is reserved for a flip
// into an exhaustion extreme while the tape is NOT trending (fading a climax) — so a SELL in a
// downtrend reads "continuation", not "fade". (Impact/absorption now live in CONVICTION, not the tag.)
float exhPr = ta.percentrank(deltaZ, cmdExhLen)
var string lastFlipType = "—"
var bool   lastFlipRev  = false
if mtfFlipBullShown or mtfFlipBearShown
    lastMtfConf := mtfConf
    lastMtfDir  := mtfFlipBullShown ? 1 : -1
    lastMtfBar2 := bar_index
    bool flipExh = (mtfFlipBullShown and exhPr <= (100.0 - cmdExhPct)) or (mtfFlipBearShown and exhPr >= cmdExhPct)
    lastFlipRev  := flipExh and not flowTrending and (regER < regErThr or flowReverting)
    lastFlipType := lastFlipRev ? "reversal (fade)" : "continuation (trend)"

// ═════════════════════════════════════════════════════════════════════════════
// STAGE 3 · FORWARD CALIBRATION (triple-barrier; signal edge vs base rate)
// ═════════════════════════════════════════════════════════════════════════════
float atr = ta.atr(atrLen)
bool  gate = not antiRep or barstate.isconfirmed
// v1.4 SELF-VALIDATING SCOREBOARD — grade the signal ACTUALLY shown on the chart (the confluence-gated
// MTF flip) rather than the raw pressure cross, so the hit-rate / edge measures what you actually trade.
bool calUseFlip  = mtfOn and calTarget == "MTF aligned flip"
bool calSigLong  = calUseFlip ? mtfFlipBullRaw : longEvt
bool calSigShort = calUseFlip ? mtfFlipBearRaw : shortEvt

var array<Ev> pend   = array.new<Ev>()
var array<Ev> bpendL = array.new<Ev>()
var array<Ev> bpendS = array.new<Ev>()
var int sigLwin = 0
var int sigLtot = 0
var int sigSwin = 0
var int sigStot = 0
var int baseLwin = 0
var int baseLtot = 0
var int baseSwin = 0
var int baseStot = 0
var int lastSigBar  = -100000
var int lastBaseBar = -100000
// EDGE-GATE (v2.5) — rolling per-side buffers of the last edgeWin resolved TRAILING-exit R multiples
// (how the signal is actually traded); the self-mute keys off AVERAGE R, not win-rate — a trend-ride is
// profitable at ~40% win, so a win-rate floor would wrongly mute a positive-expectancy side.
var array<float> rollL = array.new<float>()
var array<float> rollS = array.new<float>()
// REGIME-SPLIT diagnostic (v2.1) — did the signal's edge come from TREND bars or RANGE bars? Tag each
// sample with the regime at entry and split the hit-rate, so we can SEE whether a negative overall edge
// is just range chop (fixable by standing aside in range) vs a genuinely weak signal.
var int trendWin = 0
var int trendTot = 0
var int rangeWin = 0
var int rangeTot = 0
// OBJECTIVE TEST BENCH (v2.3) — measure the SAME signals three honest ways so the data picks the fix:
//   (1) TRAILING-EXIT expectancy in R — simulate the ATR trailing stop the engine actually ships (mult =
//       group-12 "Trailing stop × ATR"), let winners run: avg R > 0 means it PAYS as traded, and the
//       fixed 1:1 win-rate was the wrong yardstick.  (2) FADE — would the OPPOSITE side have won the 1:1?
//       (a fade hit-rate well above 50% = the signal's sign is backwards for this instrument).  (3) both
//       split by regime. All read-only; no behaviour change.
var array<Ev> tpend = array.new<Ev>()
var float trSumR    = 0.0
var int   trN       = 0
var int   trWin     = 0
var float trTrendSum= 0.0
var int   trTrendN  = 0
var float trRangeSum= 0.0
var int   trRangeN  = 0
var int   fadeWin   = 0
var int   fadeTot   = 0
int trailCap = math.max(calHorizon * 4, 80)

// enqueue a signal sample
if useCalib and gate and (calSigLong or calSigShort) and not na(atr) and atr > 0.0 and (bar_index - lastSigBar) >= calGap
    lastSigBar := bar_index
    pend.push(Ev.new(calSigLong ? 1 : -1, close, atr, bar_index, false, regTrend))
    tpend.push(Ev.new(calSigLong ? 1 : -1, close, atr, bar_index, false, regTrend))
// enqueue direction-matched base samples (identical barrier procedure)
if useCalib and gate and not na(atr) and atr > 0.0 and (bar_index - lastBaseBar) >= calGap
    lastBaseBar := bar_index
    bpendL.push(Ev.new(1,  close, atr, bar_index, false))
    bpendS.push(Ev.new(-1, close, atr, bar_index, false))

// resolve signal samples
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
                if p.dir > 0
                    sigLtot += 1
                    sigLwin += win ? 1 : 0
                else
                    sigStot += 1
                    sigSwin += win ? 1 : 0
                if p.trend
                    trendTot += 1
                    trendWin += win ? 1 : 0
                else
                    rangeTot += 1
                    rangeWin += win ? 1 : 0
                // FADE: would the OPPOSITE side have won the same 1:1? (stop-first, or negative at timeout)
                bool fadeW = (hitStop and not hitTgt) ? true : (hitTgt and not hitStop) ? false : ((p.dir > 0 ? (close - p.entry) : (p.entry - close)) < 0.0)
                fadeTot += 1
                fadeWin += fadeW ? 1 : 0
                pend.remove(i)
// resolve base-long samples
if useCalib and barstate.isconfirmed and bpendL.size() > 0
    for i = bpendL.size() - 1 to 0
        Ev p = bpendL.get(i)
        if not p.done
            bool hitStop = (p.entry - low)  >= calStopATR * p.atr0
            bool hitTgt  = (high - p.entry) >= calMoveATR * p.atr0
            bool tmOut   = bar_index - p.bidx >= calHorizon
            if hitStop or hitTgt or tmOut
                p.done := true
                bool win = hitStop ? false : hitTgt ? true : ((close - p.entry) >= calMoveATR * p.atr0)
                baseLtot += 1
                baseLwin += win ? 1 : 0
                bpendL.remove(i)
// resolve base-short samples
if useCalib and barstate.isconfirmed and bpendS.size() > 0
    for i = bpendS.size() - 1 to 0
        Ev p = bpendS.get(i)
        if not p.done
            bool hitStop = (high - p.entry) >= calStopATR * p.atr0
            bool hitTgt  = (p.entry - low)  >= calMoveATR * p.atr0
            bool tmOut   = bar_index - p.bidx >= calHorizon
            if hitStop or hitTgt or tmOut
                p.done := true
                bool win = hitStop ? false : hitTgt ? true : ((p.entry - close) >= calMoveATR * p.atr0)
                baseStot += 1
                baseSwin += win ? 1 : 0
                bpendS.remove(i)

// resolve TRAILING-EXIT samples — simulate the shipped ATR trailing stop (mult = cmdTrailMlt) forward
// from entry; exit when close crosses the ratcheting trail or the cap is reached; record R = move / risk.
if useCalib and barstate.isconfirmed and tpend.size() > 0
    for i = tpend.size() - 1 to 0
        Ev p = tpend.get(i)
        if not p.done
            float risk = cmdTrailMlt * p.atr0
            if na(p.ext)
                p.ext := p.dir > 0 ? high : low
                p.trl := p.dir > 0 ? p.entry - risk : p.entry + risk
            else
                p.ext := p.dir > 0 ? math.max(p.ext, high) : math.min(p.ext, low)
                p.trl := p.dir > 0 ? math.max(p.trl, p.ext - risk) : math.min(p.trl, p.ext + risk)
            bool exit = p.dir > 0 ? close <= p.trl : close >= p.trl
            bool tout = bar_index - p.bidx >= trailCap
            if (exit or tout) and risk > 0.0
                p.done := true
                float r = (p.dir > 0 ? (close - p.entry) : (p.entry - close)) / risk
                trSumR += r
                trN    += 1
                trWin  += r > 0.0 ? 1 : 0
                // feed the edge-gate rolling R buffers (mute a side on negative recent expectancy)
                if p.dir > 0
                    rollL.push(r)
                    if rollL.size() > edgeWin
                        rollL.shift()
                else
                    rollS.push(r)
                    if rollS.size() > edgeWin
                        rollS.shift()
                if p.trend
                    trTrendSum += r
                    trTrendN   += 1
                else
                    trRangeSum += r
                    trRangeN   += 1
                tpend.remove(i)

// EDGE-GATE (v2.5) — recompute each side's ROLLING average R and apply the self-mute with hysteresis.
// A side mutes when its recent average trailing-R falls below edgeMute (and it has >= edgeMinN samples),
// and un-mutes only once it recovers above edgeUnmute. Keyed on R, not win-rate, so a profitable
// low-win-rate trend-ride is never muted. Lagged (read at the gate next bar) — never repaints.
float rollLrate = rollL.size() > 0 ? rollL.sum() / float(rollL.size()) : na
float rollSrate = rollS.size() > 0 ? rollS.sum() / float(rollS.size()) : na
if edgeGate
    if rollL.size() >= edgeMinN and not na(rollLrate)
        if rollLrate < edgeMute
            sideLongMuted := true
        else if rollLrate >= edgeUnmute
            sideLongMuted := false
    if rollS.size() >= edgeMinN and not na(rollSrate)
        if rollSrate < edgeMute
            sideShortMuted := true
        else if rollSrate >= edgeUnmute
            sideShortMuted := false
else
    sideLongMuted := false
    sideShortMuted := false

float baseUp  = baseLtot > 0 ? baseLwin / float(baseLtot) * 100.0 : na
float baseDn  = baseStot > 0 ? baseSwin / float(baseStot) * 100.0 : na
float sigLhit = sigLtot > 0 ? sigLwin / float(sigLtot) * 100.0 : na
float sigShit = sigStot > 0 ? sigSwin / float(sigStot) * 100.0 : na
float longEdge  = (not na(sigLhit) and not na(baseUp)) ? sigLhit - baseUp : na
float shortEdge = (not na(sigShit) and not na(baseDn)) ? sigShit - baseDn : na
bool  longSurv  = sigLtot >= calMinN and not na(sigLhit) and not na(baseUp) and (sigLhit / 100.0 - cal.wilsonHalf(sigLwin, sigLtot, 2.24) / 100.0) > baseUp / 100.0
bool  shortSurv = sigStot >= calMinN and not na(sigShit) and not na(baseDn) and (sigShit / 100.0 - cal.wilsonHalf(sigSwin, sigStot, 2.24) / 100.0) > baseDn / 100.0

// last-signal memory (keeps the dashboard informative between fires)
var int lastDir = 0
var int lastAtBar = na
if calSigLong or calSigShort
    lastDir := calSigLong ? 1 : -1
    lastAtBar := bar_index
int  lastAge = na(lastAtBar) ? na : bar_index - lastAtBar
string edgeTxt = lastDir > 0 ? (sigLtot < calMinN ? "learning (" + str.tostring(sigLtot) + ")" : (na(longEdge) ? "—" : (longEdge >= 0 ? "+" : "") + str.tostring(longEdge, "0") + "% vs base (" + str.tostring(sigLtot) + ")" + (longSurv ? " ✓" : ""))) : lastDir < 0 ? (sigStot < calMinN ? "learning (" + str.tostring(sigStot) + ")" : (na(shortEdge) ? "—" : (shortEdge >= 0 ? "+" : "") + str.tostring(shortEdge, "0") + "% vs base (" + str.tostring(sigStot) + ")" + (shortSurv ? " ✓" : ""))) : "no signal yet"

// ═════════════════════════════════════════════════════════════════════════════
// PLOTS — OVERLAY (v1.5): everything draws ON PRICE. The z-scored pressure oscillator, its
// signal/confirmation lines and impulse dots (which needed a separate pane) are gone; the pressure
// read now lives on the DASHBOARD and drives the on-price signals. What's on price: the MTF aligned
// flip triangles (the signal), the ATR trailing stop, exhaustion background zones, and optional
// flow bar-colouring — nothing that needs a z-axis.
// ═════════════════════════════════════════════════════════════════════════════
// optional: colour price bars by decisive flow pressure (off by default — keeps your candles intact)
barcolor(bcOn and showEngine ? (buyBias ? color.new(bullCol, 0) : sellBias ? color.new(bearCol, 0) : na) : na, title = "Flow bar colour")

// chart-TF pressure signals — OFF by default; when on, still gated to MTF agreement
plotshape(showSig and showEngine and longEvt  and mtfBuyOK,  "Buy pressure",  shape.triangleup,   location.belowbar, color.new(bullCol, 0), size = size.tiny, force_overlay = true)
plotshape(showSig and showEngine and shortEvt and mtfSellOK, "Sell pressure", shape.triangledown, location.abovebar, color.new(bearCol, 0), size = size.tiny, force_overlay = true)
// MTF ALIGNED FLIP — the headline SIGNAL. Shown as a SOLID bull/bear box with the strength number
// only (no words). Distinct from the trailing-line FLIP marker below (which is a dark box on the line).
if showFlipStr and showEngine and barstate.isconfirmed and (mtfFlipBullShown or mtfFlipBearShown)
    label.new(bar_index, mtfFlipBullShown ? low : high, str.tostring(mtfConf, "0"), style = mtfFlipBullShown ? label.style_label_up : label.style_label_down, color = color.new(mtfFlipBullShown ? bullCol : bearCol, 0), textcolor = color.white, size = size.tiny)
// (CVD channel breakouts are shown on the dashboard "CVD channel" row + as alerts — no on-price
//  markers, to stay within TradingView's 64-plot budget. The confirmed MTF flip is the precise mark.)

// ═════════════════════════════════════════════════════════════════════════════
// COMMAND CENTER LAYERS — read-together layers + trade loop (all consume the spine)
// (Per-bar delta bubbles were removed — a mark on every bar is noise; the MTF alignment
//  strip above is the clean, high-signal replacement for "where is flow concentrated".)
// ═════════════════════════════════════════════════════════════════════════════

// Layer 2 · FLOW DRIVER — fast signal + slow confirmation of the pressure-z (computed for the
// dashboard "Flow driver" row + alerts; no longer plotted — this is an overlay build, not a pane)
float cmdSig  = ta.ema(deltaZ, cmdSigLen)
float cmdConf = ta.ema(deltaZ, cmdConfLen)
bool  cmdDrvBull = ta.crossover(cmdSig, cmdConf)
bool  cmdDrvBear = ta.crossunder(cmdSig, cmdConf)
// impulse — statistically rare bursts in delta ACCELERATION (robust z), kept for the alert
float cmdAcc    = deltaZ - nz(deltaZ[1])
float cmdAccMed = ta.median(cmdAcc, zLen)
float cmdAccMad = ta.median(math.abs(cmdAcc - cmdAccMed), zLen)
float cmdAccZ   = cmdAccMad > 1e-10 ? (cmdAcc - cmdAccMed) / (1.4826 * cmdAccMad) : 0.0
bool  cmdImp    = cmdDriver and math.abs(cmdAccZ) >= cmdImpZ

// Layer 3 · EXHAUSTION ZONES — pressure beyond its own high/low percentile (climactic)
float cmdPr      = ta.percentrank(deltaZ, cmdExhLen)
bool  cmdExhBuy  = cmdExh and cmdPr >= cmdExhPct
bool  cmdExhSell = cmdExh and cmdPr <= (100.0 - cmdExhPct)
bgcolor(showEngine and cmdExhBuy ? color.new(bullCol, 82) : showEngine and cmdExhSell ? color.new(bearCol, 82) : na, title = "Exhaustion zone")
string cmdExhTxt = cmdExhBuy ? "BUY climax" : cmdExhSell ? "SELL climax" : "—"
color  cmdExhCol = cmdExhBuy ? bullCol : cmdExhSell ? bearCol : midColr

// Layer 4 · FLOW-vs-PRICE DIVERGENCE — price new extreme not confirmed by cumulative delta
float cmdPH = ta.pivothigh(srcPrice, cmdDivPiv, cmdDivPiv)
float cmdPL = ta.pivotlow (srcPrice, cmdDivPiv, cmdDivPiv)
var float dPHp = na
var float dPHc = na
var float dPLp = na
var float dPLc = na
int cmdDivState = 0
if not na(cmdPH)
    float cAtP = nz(cvd[cmdDivPiv])
    if not na(dPHp) and cmdPH > dPHp and cAtP < dPHc
        cmdDivState := -1
    dPHp := cmdPH
    dPHc := cAtP
if not na(cmdPL)
    float cAtP = nz(cvd[cmdDivPiv])
    if not na(dPLp) and cmdPL < dPLp and cAtP > dPLc
        cmdDivState := 1
    dPLp := cmdPL
    dPLc := cAtP
plotshape(cmdDiv and showEngine and cmdDivState > 0, "Bullish divergence", shape.labelup,   location.belowbar, color.new(bullCol, 0), text = "div", textcolor = color.white, size = size.tiny, force_overlay = true)
plotshape(cmdDiv and showEngine and cmdDivState < 0, "Bearish divergence", shape.labeldown, location.abovebar, color.new(bearCol, 0), text = "div", textcolor = color.white, size = size.tiny, force_overlay = true)
string cmdDivTxt = cmdDivState > 0 ? "BULLISH div" : cmdDivState < 0 ? "BEARISH div" : "—"

// TRADE LOOP · ATR trailing stop on price (the exit / risk reference)
// HTF-anchored trail ATR (v2.6) — the stop trails on the timeframe the signal lives on (single line, no
// band), so lower-TF noise can't knock you out while the higher-TF structure that made the signal holds.
string cmdTrailTFs = cmdTrailTF == "2× chart" ? f_tfMul(2) : cmdTrailTF == "3× chart" ? f_tfMul(3) : cmdTrailTF == "5× chart" ? f_tfMul(5) : cmdTrailTF == "Custom" ? cmdTrailTFc : timeframe.period
float cmdChartAtr  = ta.atr(cmdTrailLen)
float cmdHtfAtr    = request.security(syminfo.tickerid, cmdTrailTFs, ta.atr(cmdTrailLen), lookahead = barmerge.lookahead_off)
float cmdTrailAtr  = cmdTrailTF == "Chart" ? cmdChartAtr : nz(cmdHtfAtr, cmdChartAtr)
[cmdTStop, cmdTUp] = f_cmdTrail(srcPrice, cmdTrailMlt, cmdTrailAtr)
pTrail = plot(cmdTrail and showEngine ? cmdTStop : na, "Trailing stop", color = cmdTUp ? color.new(bullCol, 0) : color.new(bearCol, 0), style = plot.style_stepline, linewidth = 2, force_overlay = true)

// ── SAFE ZONE (v2.13 UX) — graded cushion between the trailing stop and price, measured in ATR ──
float szAtr    = ta.atr(szAtrLen)
float szWatchM = szMult / 2.0
float szGap    = (szOn and not na(szAtr) and szAtr > 0.0 and not na(cmdTStop)) ? math.abs(close - cmdTStop) / szAtr : na
string szZone  = na(szGap) ? "safe" : szGap >= szMult ? "safe" : szGap >= szWatchM ? "watch" : "critical"
string szOrb   = szZone == "safe" ? "🟢" : szZone == "watch" ? "🟡" : "🔴"
string szWord  = szZone == "safe" ? "Safe" : szZone == "watch" ? "Watch" : "Critical"
color  szZoneCol = szZone == "safe" ? bullCol : szZone == "watch" ? midColr : bearCol
bool   szDraw  = szOn and showEngine and cmdTrail and not na(cmdTStop) and not na(szAtr)
// LINE + FILL cushion (v2.13): the gap between PRICE and the trailing stop, shaded by the CURRENT zone
// colour — 🟢 green = Safe (plenty of room) · 🟡 amber = Watch · 🔴 red = Critical (price near the stop).
// So the fill itself tells you the live risk (it is NOT a fixed red band). One hidden price-edge plot +
// one solid fill (the stop line is the other anchor) → cheap on the 64-plot budget.
color szHide = color.new(color.gray, 100)
pSZprice = plot(szDraw ? close : na, "SZ price edge", color = szHide, display = display.none, force_overlay = true)
color szFillCol = color.new(szZoneCol, szFillTr)
fill(pTrail, pSZprice, color = szFillCol, title = "Trailing-stop safe zone (cushion)")

// ═════ MTF STACK — per-TF trailing stop + flow-flip signal (1/2/3/5/15/30/60) ═════
// One security call per timeframe (bundled). Faster-than-chart rungs are computed
// but not drawn (a lower TF can't be mapped onto a higher-TF x-axis).
[msZ1, msS1, msU1]  = request.security(syminfo.tickerid, "1",  f_mtfPack(mtfZlen, msMlt, cmdTrailLen), lookahead = barmerge.lookahead_off)
[msZ2, msS2, msU2]  = request.security(syminfo.tickerid, "2",  f_mtfPack(mtfZlen, msMlt, cmdTrailLen), lookahead = barmerge.lookahead_off)
[msZ3, msS3, msU3]  = request.security(syminfo.tickerid, "3",  f_mtfPack(mtfZlen, msMlt, cmdTrailLen), lookahead = barmerge.lookahead_off)
[msZ5, msS5, msU5]  = request.security(syminfo.tickerid, "5",  f_mtfPack(mtfZlen, msMlt, cmdTrailLen), lookahead = barmerge.lookahead_off)
[msZ15, msS15, msU15] = request.security(syminfo.tickerid, "15", f_mtfPack(mtfZlen, msMlt, cmdTrailLen), lookahead = barmerge.lookahead_off)
[msZ30, msS30, msU30] = request.security(syminfo.tickerid, "30", f_mtfPack(mtfZlen, msMlt, cmdTrailLen), lookahead = barmerge.lookahead_off)
[msZ60, msS60, msU60] = request.security(syminfo.tickerid, "60", f_mtfPack(mtfZlen, msMlt, cmdTrailLen), lookahead = barmerge.lookahead_off)
float msChartMin = timeframe.in_seconds() / 60.0
bool msA1  = msOn and showEngine and ms1  and 1.0  >= msChartMin
bool msA2  = msOn and showEngine and ms2  and 2.0  >= msChartMin
bool msA3  = msOn and showEngine and ms3  and 3.0  >= msChartMin
bool msA5  = msOn and showEngine and ms5  and 5.0  >= msChartMin
bool msA15 = msOn and showEngine and ms15 and 15.0 >= msChartMin
bool msA30 = msOn and showEngine and ms30 and 30.0 >= msChartMin
bool msA60 = msOn and showEngine and ms60 and 60.0 >= msChartMin
bool msRecent = msTrailBars <= 0 or (last_bar_index - bar_index) <= msTrailBars   // only the recent window (declutter)
color msC1  = #26C6DA
color msC2  = #42A5F5
color msC3  = #7E57C2
color msC5  = #EC407A
color msC15 = #FFA726
color msC30 = #66BB6A
color msC60 = #EF5350
plot(msTrails and msA1 and msRecent ? msS1  : na, "1m trail",  color = msC1,  style = plot.style_stepline, linewidth = 1, force_overlay = true)
plot(msTrails and msA2 and msRecent ? msS2  : na, "2m trail",  color = msC2,  style = plot.style_stepline, linewidth = 1, force_overlay = true)
plot(msTrails and msA3 and msRecent ? msS3  : na, "3m trail",  color = msC3,  style = plot.style_stepline, linewidth = 2, force_overlay = true)
plot(msTrails and msA5 and msRecent ? msS5  : na, "5m trail",  color = msC5,  style = plot.style_stepline, linewidth = 2, force_overlay = true)
plot(msTrails and msA15 and msRecent ? msS15 : na, "15m trail", color = msC15, style = plot.style_stepline, linewidth = 3, force_overlay = true)
plot(msTrails and msA30 and msRecent ? msS30 : na, "30m trail", color = msC30, style = plot.style_stepline, linewidth = 3, force_overlay = true)
plot(msTrails and msA60 and msRecent ? msS60 : na, "60m trail", color = msC60, style = plot.style_stepline, linewidth = 4, force_overlay = true)

var array<label> msLabs = array.new<label>()
// Per-TF flip marker. Each call site keeps its OWN `lastLbl` (Pine gives every call
// site independent var state), so "Latest per TF" shows exactly ONE marker per
// timeframe — the current signal — instead of the whole flip history.
f_msFlip(bool active, float z, string tf, color col) =>
    var label lastLbl = na
    if msSignals and msSigMode != "Off" and active and barstate.isconfirmed
        int sgn  = z    >  mtfNeut ? 1 : z    < -mtfNeut ? -1 : 0
        int psgn = z[1] >  mtfNeut ? 1 : z[1] < -mtfNeut ? -1 : 0
        if sgn != 0 and sgn != psgn
            bool bull = sgn > 0
            if msSigMode == "Latest per TF" and not na(lastLbl)
                label.delete(lastLbl)
            label lb = label.new(bar_index, bull ? low : high, tf + (bull ? "▲" : "▼"),
                 style = bull ? label.style_label_up : label.style_label_down,
                 color = color.new(col, 25), textcolor = color.white, size = size.tiny,
                 yloc = bull ? yloc.belowbar : yloc.abovebar)
            lastLbl := lb
            if msSigMode == "All flips"
                msLabs.push(lb)
                while msLabs.size() > 60
                    label.delete(msLabs.shift())
f_msFlip(msA1,  msZ1,  "1m",  msC1)
f_msFlip(msA2,  msZ2,  "2m",  msC2)
f_msFlip(msA3,  msZ3,  "3m",  msC3)
f_msFlip(msA5,  msZ5,  "5m",  msC5)
f_msFlip(msA15, msZ15, "15m", msC15)
f_msFlip(msA30, msZ30, "30m", msC30)
f_msFlip(msA60, msZ60, "60m", msC60)

int  cmdTUpI  = cmdTUp ? 1 : 0
bool cmdTflip = cmdTUpI != nz(cmdTUpI[1], cmdTUpI)
// STRENGTH AT THE TRAILING-LINE CROSS — when price crosses the trailing stop (the entry trigger),
// stamp the current signal strength (fused conviction) so you see how backed the cross is.
// TRAILING-LINE CROSS = the "flip" marker. Just the strength NUMBER in yellow on the trailing line —
// and only the MOST RECENT few are kept, so the line never becomes a field of numbers.
// RedK-style flip marker (v2.13): a trend-coloured ▲/▼ FLIP tag with the conviction number, anchored
// ON the trailing-stop (SL) line itself — a long flip tag sits just above the line, a short flip just
// below — so the flip reads right at the stop it belongs to.
var label[] tflipLbls = array.new<label>()
if showTrailStr and showEngine and cmdTrail and cmdTflip and barstate.isconfirmed
    color _fCol = cmdTUp ? bullCol : bearCol
    label lb = label.new(bar_index, cmdTStop, (cmdTUp ? "▲ FLIP " : "▼ FLIP ") + str.tostring(mtfConf, "0"), style = cmdTUp ? label.style_label_up : label.style_label_down, color = color.new(_fCol, 15), textcolor = color.white, size = size.small)
    array.push(tflipLbls, lb)
    if array.size(tflipLbls) > trailKeep
        label.delete(array.shift(tflipLbls))

// ═════════════════════════════════════════════════════════════════════════════
// TRADE LEVELS & LATCH (v3.0) — every MTF aligned flip becomes a full plan (Trigger / SL / TP1 / TP2)
// sized off the SAME barriers the forward scoreboard grades (group 07), and the plan is HELD on screen
// (the live trade) until price reaches the Stop or TP2, or a fresh opposite/stronger signal replaces
// it. So the chart shows the trade in progress, not a vanished marker. Adapted from DBFC.
// ═════════════════════════════════════════════════════════════════════════════
var int   actMode = 0        // 0 = flat, 2 = active plan
var int   actSide = 0        // +1 long, -1 short
var int   actBar  = na
var float actTrig = na
var float actSL   = na
var float actT1   = na
var float actT2   = na
float atrLvl = nz(atr, ta.atr(atrLen))
// close the active latch when the Stop or TP2 is reached (confirmed bars only → non-repaint)
if latchOn and actMode != 0 and barstate.isconfirmed
    bool slHit = actSide > 0 ? low <= actSL  : high >= actSL
    bool t2Hit = actSide > 0 ? high >= actT2 : low  <= actT2
    if slHit or t2Hit
        actMode := 0
        actSide := 0
// a fresh shown flip sets/replaces the plan (newest wins)
bool lvlFire = (mtfFlipBullShown or mtfFlipBearShown) and (not antiRep or barstate.isconfirmed) and not na(atrLvl) and atrLvl > 0.0
if lvlFire
    int   sd     = mtfFlipBullShown ? 1 : -1
    float tpDist = calMoveATR * atrLvl
    float slDist = calStopATR * atrLvl
    float entry  = close
    float sl     = sd > 0 ? entry - slDist : entry + slDist
    // ride the ATR trailing line as the stop when it sits on the correct side of entry
    if lvlSLtrail and cmdTrail and not na(cmdTStop)
        if sd > 0 and cmdTUp and cmdTStop < entry
            sl := cmdTStop
        else if sd < 0 and not cmdTUp and cmdTStop > entry
            sl := cmdTStop
    actMode := 2
    actSide := sd
    actBar  := bar_index
    actTrig := entry
    actSL   := sl
    actT1   := sd > 0 ? entry + tpDist : entry - tpDist
    actT2   := sd > 0 ? entry + tpDist * lvlTP2Mult : entry - tpDist * lvlTP2Mult
// latch off → the plan lives only on the signal bar
if not latchOn and not lvlFire
    actMode := 0
    actSide := 0
bool   planActive = actMode != 0 and actSide != 0 and not na(actTrig)
string planTxt = planActive ? ((actSide > 0 ? "L " : "S ") + str.tostring(actTrig, format.mintick) + " · SL " + str.tostring(actSL, format.mintick) + " · T " + str.tostring(actT1, format.mintick) + "/" + str.tostring(actT2, format.mintick)) : "flat"
color  planCol = planActive ? (actSide > 0 ? bullCol : bearCol) : pTxt

// ── DRAW value-area context + the active plan (one pooled set, redrawn on the last bar) ──
var array<line>  lvLines = array.new<line>()
var array<label> lvLabs  = array.new<label>()
if barstate.islast and showEngine
    for l in lvLines
        l.delete()
    lvLines.clear()
    for lb in lvLabs
        lb.delete()
    lvLabs.clear()
    if pocOn and pocLines and not na(pocP)
        int xa = bar_index - math.min(pocLook, 300)
        int xb = bar_index + 6
        lvLines.push(line.new(xa, pocP, xb, pocP, color = color.new(flipYel, 0), width = 2))
        lvLabs.push(label.new(xb, pocP, "POC", style = label.style_label_left, color = color.new(panelBg, 100), textcolor = flipYel, size = size.tiny))
        if not na(vahP)
            lvLines.push(line.new(xa, vahP, xb, vahP, color = color.new(pTxt, 15), style = line.style_dotted))
            lvLabs.push(label.new(xb, vahP, "VAH", style = label.style_label_left, color = color.new(panelBg, 100), textcolor = pTxt, size = size.tiny))
        if not na(valP)
            lvLines.push(line.new(xa, valP, xb, valP, color = color.new(pTxt, 15), style = line.style_dotted))
            lvLabs.push(label.new(xb, valP, "VAL", style = label.style_label_left, color = color.new(panelBg, 100), textcolor = pTxt, size = size.tiny))
    if showLevels and planActive
        int xt1 = na(actBar) ? bar_index : actBar
        int xt2 = bar_index + 14
        color slC = color.new(bearCol, 0)
        color tpC = color.new(bullCol, 0)
        lvLines.push(line.new(xt1, actTrig, xt2, actTrig, color = color.new(flipYel, 0), width = 2))
        lvLabs.push(label.new(xt2, actTrig, "Trig " + str.tostring(actTrig, format.mintick), style = label.style_label_left, color = color.new(flipYel, 10), textcolor = color.white, size = size.small))
        lvLines.push(line.new(xt1, actSL, xt2, actSL, color = slC, width = 2, style = line.style_dashed))
        lvLabs.push(label.new(xt2, actSL, "SL " + str.tostring(actSL, format.mintick), style = label.style_label_left, color = color.new(slC, 10), textcolor = color.white, size = size.small))
        lvLines.push(line.new(xt1, actT1, xt2, actT1, color = tpC, width = 1))
        lvLabs.push(label.new(xt2, actT1, "TP1 " + str.tostring(actT1, format.mintick), style = label.style_label_left, color = color.new(tpC, 10), textcolor = color.white, size = size.small))
        lvLines.push(line.new(xt1, actT2, xt2, actT2, color = tpC, width = 2))
        lvLabs.push(label.new(xt2, actT2, "TP2 " + str.tostring(actT2, format.mintick), style = label.style_label_left, color = color.new(tpC, 10), textcolor = color.white, size = size.small))

// driver dashboard state
string cmdDrvTxt = cmdDrvBull ? "BULL cross" : cmdDrvBear ? "BEAR cross" : cmdSig >= cmdConf ? "bull" : "bear"
color  cmdDrvCol = (cmdSig >= cmdConf) ? bullCol : bearCol

// ═════════════════════════════════════════════════════════════════════════════
// DECISION LAYER (v1.4) — compact REGIME read + single WHAT-TO-DO verdict
// Best-practice adopted from the Order-Flow Profile / OFI Regime panels: collapse the reads into one
// plain-language directive, with colour doing the work and a neutral "wait" when there is no edge.
// The regime is a lightweight stand-in for the OFI Regime Engine's softmax (trend / mean-reversion /
// balance / toxic) — enough to retire that script for daily use.
// ═════════════════════════════════════════════════════════════════════════════
string regimeTxt = "—"
color  regimeCol = midColr
if toxHiNow
    regimeTxt := "TOXIC / shock"
    regimeCol := bearCol
else if (cmdExhBuy or cmdExhSell) and not flowTrending
    regimeTxt := "MEAN-REVERSION"
    regimeCol := midColr
else if (regER >= regErThr or flowTrending) and math.abs(mtfAlign) >= effThr and not flowReverting
    regimeTxt := "TREND " + (mtfAlign > 0 ? "up" : "down")
    regimeCol := mtfAlign > 0 ? bullCol : bearCol
else if flowReverting
    regimeTxt := "MEAN-REVERSION (flow)"
    regimeCol := midColr
else if regER < regErThr
    regimeTxt := "BALANCE / range"
    regimeCol := midColr
else
    regimeTxt := "transition"
    regimeCol := midColr
// WHAT TO DO — one directive. Fresh confluence-gated flip wins; else exhaustion fade; else MTF bias; else wait.
bool  freshFlip = lastMtfDir != 0 and not na(lastMtfBar2) and (bar_index - lastMtfBar2) <= mtfCooldown
string doTxt = "WAIT — no edge"
color  doCol = midColr
if toxHiNow
    doTxt := "WAIT — toxic flow"
    doCol := midColr
else if freshFlip
    doTxt := (lastFlipRev ? "FADE → " : "TREND-FOLLOW → ") + (lastMtfDir > 0 ? "LONG" : "SHORT") + " · " + (cmdTUp ? "long trail" : "short trail")
    doCol := lastMtfDir > 0 ? bullCol : bearCol
else if cmdExhBuy
    doTxt := "FADE — buy climax"
    doCol := bearCol
else if cmdExhSell
    doTxt := "FADE — sell climax"
    doCol := bullCol
else if math.abs(mtfAlign) >= effThr
    doTxt := mtfAlign > 0 ? "BIAS LONG — await pullback" : "BIAS SHORT — await pullback"
    doCol := mtfAlign > 0 ? bullCol : bearCol
color doTxtC = f_luma(doCol) > 150 ? color.black : color.white

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARD — plain-language, adaptive
// ═════════════════════════════════════════════════════════════════════════════
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right
string action = longEvt ? "BUY PRESSURE FIRED" : shortEvt ? "SELL PRESSURE FIRED" : strongBuy ? "STRONG BUYING" : strongSell ? "STRONG SELLING" : buyBias ? "BUYING BIAS" : sellBias ? "SELLING BIAS" : "BALANCED — WAIT"
color actCol = (longEvt or strongBuy or buyBias) ? bullCol : (shortEvt or strongSell or sellBias) ? bearCol : midColr
color actTxtC = f_luma(actCol) > 150 ? color.black : color.white
bar(float v) => v >= 80 ? "██████" : v >= 65 ? "█████░" : v >= 50 ? "████░░" : v >= 35 ? "███░░░" : v >= 20 ? "██░░░░" : v >= 10 ? "█░░░░░" : "░░░░░░"
// contiguous row renderer (zebra by row index) — lets Compact and Pro share one growing table
f_row(table t, int r, string lbl, string val, color vc) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(t, 0, r, lbl, text_color = pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, r, val, text_color = vc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)

var table dash = table.new(f_pos(tblPos), 2, 44, frame_width = 1, border_width = 1)
// ── ladder arrow glyph — used by the unified FLOW row (rendered in the single dashboard below) ──
f_mtfArr(float z) => f_mtfSgn(z) > 0 ? "▲" : f_mtfSgn(z) < 0 ? "▼" : "•"

// ═════════════════════════════════════════════════════════════════════════════
// EXPORTS (generic Data-Window names) + ALERTS
// ═════════════════════════════════════════════════════════════════════════════
color exC = color.new(color.gray, 100)
// (v2.13) six low-value EXP data-window exports trimmed to free plot budget for the safe-zone fill:
// EXP_BuyPress (derive from EXP_PressureZ), EXP_TotVol, EXP_VSABias, EXP_Absorb, EXP_MTFFlow, EXP_FlowSpeed.
// The core reads kept below (PressureZ, CumDelta, Signal, Long/ShortEdge, MTFAlign) + the MADP CVD/Whale
// exports are untouched, so the common input.source() chains keep working.
plot(deltaZ,        "EXP_PressureZ",  exC, display = display.data_window)
plot(cvd,           "EXP_CumDelta",   exC, display = display.data_window)
plot(longEvt ? 1 : shortEvt ? -1 : 0, "EXP_Signal", exC, display = display.data_window)
plot(na(longEdge) ? na : longEdge,  "EXP_LongEdge",  exC, display = display.data_window)
plot(na(shortEdge) ? na : shortEdge,"EXP_ShortEdge", exC, display = display.data_window)
plot(mtfOn ? mtfAlign : na, "EXP_MTFAlign", exC, display = display.data_window)
// (Toxicity and CVD-breakout values are on the dashboard rows + alerts; their data-window exports were
//  removed to stay within TradingView's 64-plot budget. Other layer states are on the dashboard too.)

// (VSA & absorption PRICE markers removed to stay within the 64-plot budget; both remain on the
//  dashboard rows and as alerts. The Command Center layers on price take their place.)

alertcondition(longEvt,  "Buy pressure",  "MADP: buy-pressure signal")
alertcondition(shortEvt, "Sell pressure", "MADP: sell-pressure signal")
alertcondition(vUpthrust, "VSA Upthrust",       "MADP: Upthrust — new high rejected on volume (bearish).")
alertcondition(vShakeout, "VSA Shakeout",       "MADP: Shakeout — new low reclaimed on volume (bullish).")
alertcondition(vStopping, "VSA Stopping Volume","MADP: Stopping Volume — wide down-bar closing off the low (bullish).")
alertcondition(abIs, "Absorption consensus", "MADP: absorption consensus fired — large flow failing to move price.")

// ── Command Center events (combine any of these in TradingView's alert dialog) ──
alertcondition(cmdDrvBull, "Flow driver bull cross", "MADP: flow driver crossed up — control shifting to buyers.")
alertcondition(cmdDrvBear, "Flow driver bear cross", "MADP: flow driver crossed down — control shifting to sellers.")
alertcondition(cmdExhBuy,  "Buying exhaustion",  "MADP: buying pressure at a climactic extreme — blow-off risk.")
alertcondition(cmdExhSell, "Selling exhaustion", "MADP: selling pressure at a climactic extreme — capitulation risk.")
alertcondition(cmdImp,     "Impulse burst",      "MADP: statistically rare delta-acceleration burst.")
alertcondition(cmdDiv and cmdDivState > 0, "Bullish flow divergence", "MADP: price new low not confirmed by cumulative delta (bullish).")
alertcondition(cmdDiv and cmdDivState < 0, "Bearish flow divergence", "MADP: price new high not confirmed by cumulative delta (bearish).")
alertcondition(cmdTflip and cmdTUp,       "Trailing stop flipped long",  "MADP: ATR trailing stop flipped to long.")
alertcondition(cmdTflip and not cmdTUp,   "Trailing stop flipped short", "MADP: ATR trailing stop flipped to short.")
alertcondition(szOn and szZone == "critical" and szZone[1] != "critical", "Stop zone CRITICAL", "MADP: price entered the trailing-stop CRITICAL zone — cushion under half the safe distance. Consider tightening / managing the trade.")
// high-conviction confluence: a fresh driver cross while price sits in an exhaustion zone
alertcondition((cmdDrvBull and cmdExhSell) or (cmdDrvBear and cmdExhBuy), "Reversal confluence", "MADP: driver cross against a climactic exhaustion extreme — highest-conviction reversal context.")

// ── MTF alignment + confluence (the headline, high-signal events; now CVD- and toxicity-gated) ──
alertcondition(mtfFlipBullShown, "MTF aligned BUY",  "MADP: MTF order flow aligned bullish across the chart-anchored ladder WITH a same-direction CVD-channel break and non-toxic flow — full confluence.")
alertcondition(mtfFlipBearShown, "MTF aligned SELL", "MADP: MTF order flow aligned bearish across the chart-anchored ladder WITH a same-direction CVD-channel break and non-toxic flow — full confluence.")
// ── CVD structure + toxicity (Wave F) ──
alertcondition(cvdBreakUp, "CVD channel breakout up",   "MADP: cumulative delta broke its channel to the upside — structural order-flow shift.")
alertcondition(cvdBreakDn, "CVD channel breakout down", "MADP: cumulative delta broke its channel to the downside — structural order-flow shift.")
alertcondition(toxHiNow,   "Toxic flow",                "MADP: flow toxicity in the top percentile — one-sided informed flow, whipsaw risk.")

// ═════════════════════════════════════════════════════════════════════════════
// MULTI-ANCHOR DELTA PROFILE (MADP layer, v3.1) — ported from the Multi-Anchor Delta Profile so its
// existing followers keep their tool intact. A WALL of delta-coloured HTF volume profiles (per-anchor
// POC / Value Area, stacked diagonal imbalance, whale tiers, net-delta lean meter). An anatomy view —
// it prints NO verdict. Off by default; when published under the MADP listing it is set default-ON.
// Non-repaint: intrabars aggregate on confirmed bars; profiles render once per confirmed bar.
// ═════════════════════════════════════════════════════════════════════════════
// intrabar stream (one lower-tf call; runs always, processed only when the layer is on)
string mpLtf = switch mpLtfMode
    "Auto" => timeframe.isseconds ? "1S" : timeframe.isintraday ? (timeframe.multiplier >= 60 ? "5" : "1") : "60"
    => mpLtfMode
[mpH, mpL, mpO, mpC, mpV] = request.security_lower_tf(_flowSym, mpLtf, [high, low, open, close, volume])
// per-intrabar signed volume via the triangular candle-direction pressure
var array<float> mpDLT = array.new<float>()
mpDLT.clear()
if madpOn and showProfile and mpH.size() > 0
    for i = 0 to mpH.size() - 1
        mpDLT.push(nz(mpV.get(i)) * f_side(mpO.get(i), mpH.get(i), mpL.get(i), mpC.get(i)))
// per-anchor accumulation (confirmed bars → non-repaint); timeframe.change called unconditionally
var Slot mpSlotA = f_newSlot()
var Slot mpSlotB = f_newSlot()
var Slot mpSlotC = f_newSlot()
bool mpResetA = timeframe.change(mpHtfA)
bool mpResetB = timeframe.change(mpHtfB)
bool mpResetC = timeframe.change(mpHtfC)
if madpOn and showProfile and barstate.isconfirmed
    if mpUseA
        f_acc(mpSlotA, mpResetA, mpH, mpL, mpV, mpDLT, mpBufCap)
    if mpUseB
        f_acc(mpSlotB, mpResetB, mpH, mpL, mpV, mpDLT, mpBufCap)
    if mpUseC
        f_acc(mpSlotC, mpResetC, mpH, mpL, mpV, mpDLT, mpBufCap)
// active-anchor registry (built once). An anchor is only valid when it is at/above the chart TF — a
// sub-chart anchor (e.g. a 15m anchor viewed on a 30m chart) can't be reconstructed from this chart's
// bars and would print a degenerate/duplicate row, so it is skipped.
int _mpChartSec = timeframe.in_seconds()
var array<Slot>   mpSL = array.new<Slot>()
var array<string> mpSN = array.new<string>()
if barstate.isfirst
    if mpUseA and timeframe.in_seconds(mpHtfA) >= _mpChartSec
        mpSL.push(mpSlotA), mpSN.push(mpNameA)
    if mpUseB and timeframe.in_seconds(mpHtfB) >= _mpChartSec
        mpSL.push(mpSlotB), mpSN.push(mpNameB)
    if mpUseC and timeframe.in_seconds(mpHtfC) >= _mpChartSec
        mpSL.push(mpSlotC), mpSN.push(mpNameC)
// drawing pools (cleared + rebuilt once per confirmed last bar)
var array<box>   mpBoxes  = array.new<box>()
var array<line>  mpLines2 = array.new<line>()
var array<label> mpLabs2  = array.new<label>()
color mpHdr = color.new(#2962ff, 0)
var int mpDrawn = -1
bool mpDoDraw = madpOn and showProfile and barstate.islast and (bar_index != mpDrawn or barstate.isconfirmed)
if mpDoDraw
    mpDrawn := bar_index
    for b in mpBoxes
        b.delete()
    mpBoxes.clear()
    for l in mpLines2
        l.delete()
    mpLines2.clear()
    for lb in mpLabs2
        lb.delete()
    mpLabs2.clear()
    int xR = bar_index + mpBaseOff + mpProfW
    for k = 0 to mpSL.size() - 1
        if mpSL.size() < 1
            break
        Slot s  = mpSL.get(k)
        string nm = mpSN.get(k)
        int n   = s.H.size()
        if n >= 2
            float minP = s.L.min()
            float maxP = s.H.max()
            if maxP > minP
                float binH = (maxP - minP) / mpRows
                array<float> totBin = array.new<float>(mpRows, 0.0)
                array<float> dltBin = array.new<float>(mpRows, 0.0)
                array<float> whBin  = array.new<float>(mpRows, 0.0)
                for i = 0 to n - 1
                    float hh = s.H.get(i)
                    float ll = s.L.get(i)
                    float vv = s.VOL.get(i)
                    float dd = s.DLT.get(i)
                    int bot = f_bin(ll, minP, binH, mpRows)
                    int top = f_bin(hh, minP, binH, mpRows)
                    int span = math.max(1, top - bot + 1)
                    float vDiv = vv / span
                    float dDiv = dd / span
                    for x = bot to top
                        totBin.set(x, totBin.get(x) + vDiv)
                        dltBin.set(x, dltBin.get(x) + dDiv)
                        if vv > whBin.get(x)
                            whBin.set(x, vv)
                float maxTot = totBin.max()
                float totalAll = totBin.sum()
                float maxAbsD = 1e-9
                for i = 0 to mpRows - 1
                    maxAbsD := math.max(maxAbsD, math.abs(dltBin.get(i)))
                if maxTot > 0
                    int pocIdx = totBin.indexof(maxTot)
                    int loIdx = pocIdx
                    int hiIdx = pocIdx
                    float vaSum = totBin.get(pocIdx)
                    float target = totalAll * mpVaPct
                    while vaSum < target and (loIdx > 0 or hiIdx < mpRows - 1)
                        float dLo = loIdx > 0 ? totBin.get(loIdx - 1) : -1.0
                        float dHi = hiIdx < mpRows - 1 ? totBin.get(hiIdx + 1) : -1.0
                        if dHi >= dLo
                            hiIdx += 1
                            vaSum += totBin.get(hiIdx)
                        else
                            loIdx -= 1
                            vaSum += totBin.get(loIdx)
                    float t1 = f_pctile(s.VOL, mpWhT1)
                    float t2 = f_pctile(s.VOL, mpWhT2)
                    float t3 = f_pctile(s.VOL, mpWhT3)
                    int xL = xR - mpProfW
                    for i = 0 to mpRows - 1
                        float tot = totBin.get(i)
                        if tot > 0
                            float d = dltBin.get(i)
                            float binBot = minP + binH * i
                            float binTop = binBot + binH
                            int lenBars = math.max(1, int(math.round(tot / maxTot * mpProfW)))
                            bool inVA = i >= loIdx and i <= hiIdx
                            color baseC = d >= 0 ? bullCol : bearCol
                            int fadeAdd = (mpDimNonVA and not inVA) ? 40 : 0
                            int tLo = int(math.min(92, 82 + fadeAdd))
                            int tHi = int(math.min(90, 12 + fadeAdd))
                            color gcol = color.from_gradient(math.abs(d), 0, maxAbsD, color.new(baseC, tLo), color.new(baseC, tHi))
                            mpBoxes.push(box.new(xR - lenBars, binTop, xR, binBot, border_color = color.new(baseC, 100), bgcolor = gcol))
                            if mpShowWh
                                float w = whBin.get(i)
                                int tier = not na(t3) and w >= t3 ? 3 : not na(t2) and w >= t2 ? 2 : not na(t1) and w >= t1 ? 1 : 0
                                if tier > 0
                                    mpLabs2.push(label.new(xR + 1, (binBot + binTop) / 2.0, "●", style = label.style_label_left, color = color.new(panelBg, 100), textcolor = color.new(d >= 0 ? bullCol : bearCol, 0), size = f_tierSize(tier)))
                    if mpShowVA
                        float pocP2 = minP + binH * pocIdx + binH / 2.0
                        float vahP2 = minP + binH * (hiIdx + 1)
                        float valP2 = minP + binH * loIdx
                        mpLines2.push(line.new(xL, pocP2, xR, pocP2, color = color.new(flipYel, 0), width = 2))
                        mpLines2.push(line.new(xL, vahP2, xR, vahP2, color = color.new(pTxt, 30), style = line.style_dotted))
                        mpLines2.push(line.new(xL, valP2, xR, valP2, color = color.new(pTxt, 30), style = line.style_dotted))
                        mpLabs2.push(label.new(xR + 3, pocP2, "POC", style = label.style_label_left, color = color.new(panelBg, 100), textcolor = flipYel, size = size.small))
                    if mpShowImb
                        int runStart = -1
                        int runSign  = 0
                        for i = 0 to mpRows - 1
                            float buyI  = (totBin.get(i) + dltBin.get(i)) / 2.0
                            float sellI = (totBin.get(i) - dltBin.get(i)) / 2.0
                            float sellD = i >= 1 ? (totBin.get(i - 1) - dltBin.get(i - 1)) / 2.0 : 0.0
                            float buyU  = i <= mpRows - 2 ? (totBin.get(i + 1) + dltBin.get(i + 1)) / 2.0 : 0.0
                            bool bull = i >= 1 and buyI > 0 and buyI >= mpImbRatio * math.max(sellD, 1e-9)
                            bool bear = i <= mpRows - 2 and sellI > 0 and sellI >= mpImbRatio * math.max(buyU, 1e-9)
                            int curSign = bull ? 1 : bear ? -1 : 0
                            if curSign != runSign or i == mpRows - 1
                                int endI = curSign != runSign ? i - 1 : i
                                if runSign != 0 and runStart >= 0 and (endI - runStart + 1) >= mpImbStack
                                    float zBot = minP + binH * runStart
                                    float zTop = minP + binH * (endI + 1)
                                    color zc = runSign > 0 ? bullCol : bearCol
                                    mpBoxes.push(box.new(xR + 2, zTop, xR + 5, zBot, border_color = color.new(zc, 0), bgcolor = color.new(zc, 55)))
                                    mpLabs2.push(label.new(xR + 6, (zBot + zTop) / 2.0, runSign > 0 ? "⊞" : "⊟", style = label.style_label_left, color = color.new(panelBg, 100), textcolor = zc, size = size.tiny))
                                runStart := curSign != 0 ? i : -1
                                runSign  := curSign
                    if mpShowMet
                        float lean = f_clamp(totalAll > 0 ? s.cvd / totalAll : 0.0, -1.0, 1.0)
                        int mlen = int(math.round(math.abs(lean) * (mpProfW / 2.0)))
                        int xC = xR - int(mpProfW / 2)
                        float yMe = minP - binH * 0.9
                        color mc = s.cvd >= 0 ? bullCol : bearCol
                        int mLeft  = s.cvd >= 0 ? xC : xC - mlen
                        int mRight = s.cvd >= 0 ? xC + mlen : xC
                        mpBoxes.push(box.new(mLeft, yMe + binH * 0.35, mRight, yMe - binH * 0.35, border_color = color.new(mc, 100), bgcolor = color.new(mc, 15)))
                        mpLines2.push(line.new(xC, yMe + binH * 0.45, xC, yMe - binH * 0.45, color = color.new(pTxt, 20)))
                    mpLabs2.push(label.new(int(math.avg(xL, xR)), maxP + binH, nm + " " + f_arrow(s.cvd) + " Δ " + f_signed(s.cvd), style = label.style_label_down, color = color.new(panelBg, 15), textcolor = s.cvd >= 0 ? bullCol : bearCol, size = size.small))
        xR += mpProfW + mpProfGap

// ═══════════════════ UNIFIED DASHBOARD — one panel (engine · FLOW · MTF stack · MADP anchors) ═══════
// Compact (default): decision essentials + FLOW ladder + MTF stack + MADP anchors. Pro adds every read.
// Rendered here, after the MADP accumulation, so the anchor Net-Δ is current (no 1-bar lag). The three
// former side panels (MTF-strip, MTF-stack legend, MADP table) are folded in as rows of this one table.
if barstate.islast and (showEngine or showProfile)
    bool pro = not compactDash
    table.set_frame_color(dash, frameC)
    table.set_border_color(dash, frameC)
    int rr = 0
    table.cell(dash, 0, rr, " MADP · ENGINE v2.13", text_color = pStr, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, rr, (compactDash ? "cmpct " : "pro ") + (classMethod == "Intrabar Tick Rule" ? "tick " + ltf : classMethod == "Bulk Volume Classification" ? "BVC" : "geom"), text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_right)
    rr += 1
    if showEngine
        table.cell(dash, 0, rr, " " + action + " ", text_color = actTxtC, bgcolor = actCol, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, rr, deltaZ >= 0 ? "z +" + str.tostring(deltaZ, "0.0") : "z " + str.tostring(deltaZ, "0.0"), text_color = actTxtC, bgcolor = actCol, text_size = size.small, text_halign = text.align_right)
        rr += 1
        if pro
            f_row(dash, rr, "State", stateTxt, deltaZ >= 0 ? bullCol : bearCol)
            rr += 1
            f_row(dash, rr, "Buy pressure", str.tostring(buyPress, "#") + " " + bar(buyPress), buyPress >= 50 ? bullCol : pTxt)
            rr += 1
            f_row(dash, rr, "Sell pressure", str.tostring(sellPress, "#") + " " + bar(sellPress), sellPress >= 50 ? bearCol : pTxt)
            rr += 1
            f_row(dash, rr, "Cum. delta", (cvd >= 0 ? "+" : "") + f_vol(cvd), cvd >= 0 ? bullCol : bearCol)
            rr += 1
            f_row(dash, rr, "Last signal", lastDir == 0 ? "none yet" : (lastDir > 0 ? "BUY" : "SELL") + " · " + str.tostring(lastAge) + "b ago", lastDir > 0 ? bullCol : lastDir < 0 ? bearCol : pTxt)
            rr += 1
            if vsaRow
                f_row(dash, rr, "VSA event", vsaEvt, vsaEvtCol)
                rr += 1
            if absOn
                f_row(dash, rr, "Absorption", absTxt, absCol)
                rr += 1
            if cmdDriver
                f_row(dash, rr, "Flow driver", cmdDrvTxt, cmdDrvCol)
                rr += 1
            if cmdExh
                f_row(dash, rr, "Exhaustion", cmdExhTxt, cmdExhCol)
                rr += 1
            if cmdDiv
                f_row(dash, rr, "Divergence", cmdDivTxt, cmdDivState > 0 ? bullCol : cmdDivState < 0 ? bearCol : midColr)
                rr += 1
            if cmdScore and useCalib
                float avgRt = trTrendN > 0 ? trTrendSum / float(trTrendN) : na
                float avgRr = trRangeN > 0 ? trRangeSum / float(trRangeN) : na
                string trReg = "trend " + (na(avgRt) ? "—" : "R" + str.tostring(avgRt, "0.00") + "·" + str.tostring(trTrendN)) + "  range " + (na(avgRr) ? "—" : "R" + str.tostring(avgRr, "0.00") + "·" + str.tostring(trRangeN))
                f_row(dash, rr, "Expect·regime", trReg, (na(avgRt) and na(avgRr)) ? pTxt : (nz(avgRt) > 0.0 or nz(avgRr) > 0.0) ? bullCol : bearCol)
                rr += 1
                string sL = na(sigLhit) ? "L —" : "L " + str.tostring(sigLhit, "0") + "%"
                string sS = na(sigShit) ? "S —" : "S " + str.tostring(sigShit, "0") + "%"
                f_row(dash, rr, "1:1 scalp (ctx)", sL + " · " + sS + " · " + str.tostring(sigLtot + sigStot) + "n", pTxt)
                rr += 1
            if edgeGate
                string egTxt = (sideLongMuted or sideShortMuted) ? ((sideLongMuted ? "BUY muted" : "") + (sideLongMuted and sideShortMuted ? " · " : "") + (sideShortMuted ? "SELL muted" : "")) : "both live"
                string egRate = (na(rollLrate) and na(rollSrate)) ? "" : "  L R" + (na(rollLrate) ? "—" : str.tostring(rollLrate, "0.00")) + "/S R" + (na(rollSrate) ? "—" : str.tostring(rollSrate, "0.00"))
                f_row(dash, rr, "Edge-gate", egTxt + egRate, (sideLongMuted or sideShortMuted) ? bearCol : bullCol)
                rr += 1
            if toxOn
                f_row(dash, rr, "Toxicity", toxTxt, toxCol)
                rr += 1
            if cvdChanOn
                f_row(dash, rr, "CVD channel", cvdTxt, cvdTxtCol)
                rr += 1
            if impOn
                f_row(dash, rr, "Impact (λ)", impTxt, impCol)
                rr += 1
            if sizeOn
                f_row(dash, rr, "Big-lot flow", sizeTxt, sizeCol)
                rr += 1
            if persistOn
                f_row(dash, rr, "Flow persist", persistTxt, persistCol)
                rr += 1
            if hurstOn
                f_row(dash, rr, "Flow Hurst", hurstTxt, hurstCol)
                rr += 1
            if levyOn
                f_row(dash, rr, "Flow lead", leadTxt + (levyReady and leadState != -9 ? " p" + str.tostring(math.round(levyRank)) : ""), leadCol)
                rr += 1
        // ── decision essentials (compact + pro) ──
        if mtfOn
            string lmTxt = lastMtfDir == 0 ? "none yet" : (lastMtfDir > 0 ? "BUY " : "SELL ") + str.tostring(lastMtfConf, "0") + (verdictOn ? (lastFlipRev ? " · rev" : " · cont") : "") + " · " + str.tostring(bar_index - lastMtfBar2) + "b ago"
            f_row(dash, rr, "MTF signal", lmTxt, lastMtfDir > 0 ? bullCol : lastMtfDir < 0 ? bearCol : pTxt)
            rr += 1
            string strLbl = mtfConf >= 75 ? " very strong" : mtfConf >= 55 ? " strong" : mtfConf >= mtfMinConf ? " ok" : " weak"
            color  strCol = mtfConf < mtfMinConf ? pTxt : mtfAlign > 0 ? bullCol : mtfAlign < 0 ? bearCol : midColr
            f_row(dash, rr, "Signal str", str.tostring(mtfConf, "0") + " " + bar(mtfConf) + strLbl, strCol)
            rr += 1
        if useCalib
            float expR   = trN > 0 ? trSumR / float(trN) : na
            float expWin = trN > 0 ? float(trWin) / float(trN) * 100.0 : na
            string expTxt = na(expR) ? "learning (" + str.tostring(trN) + ")" : "R " + str.tostring(expR, "0.00") + " · win " + str.tostring(expWin, "0") + "% · " + str.tostring(trN) + "n"
            f_row(dash, rr, "Expectancy", expTxt, na(expR) ? pTxt : expR > 0.03 ? bullCol : expR < -0.03 ? bearCol : midColr)
            rr += 1
        if pocOn
            f_row(dash, rr, "Value", valTxt, valCol)
            rr += 1
        if showLevels or planActive
            f_row(dash, rr, "Plan", planTxt, planCol)
            rr += 1
        if cmdTrail and szOn
            f_row(dash, rr, "Stop zone", szOrb + " " + szWord + " · " + (na(szGap) ? "—" : str.tostring(szGap, "#.00") + "x ATR to " + f_fixtick(cmdTStop)), szZoneCol)
            rr += 1
        if verdictOn
            f_row(dash, rr, "Regime", regimeTxt, regimeCol)
            rr += 1
        // (FLOW ladder + MTF stack render as a per-rung-COLOURED strip below — a single table cell
        //  cannot hold multiple colours, so the colour-coded ladder lives in its own compact strip.)
    // ── MADP anchors (folded in — shows in Profile mode too) ──
    if madpOn and showProfile and mpDash and mpSL.size() > 0
        table.cell(dash, 0, rr, " MADP anchors", text_color = color.white, bgcolor = mpHdr, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dash, 1, rr, "Δ · lean · bars", text_color = color.white, bgcolor = mpHdr, text_size = size.tiny, text_halign = text.align_right)
        rr += 1
        for k = 0 to mpSL.size() - 1
            Slot s = mpSL.get(k)
            f_row(dash, rr, mpSN.get(k), f_arrow(s.cvd) + " " + f_signed(s.cvd) + " · " + (s.cvd > 0 ? "Buy" : s.cvd < 0 ? "Sell" : "—") + " · " + str.tostring(s.H.size()) + "b", s.cvd >= 0 ? bullCol : bearCol)
            rr += 1
    // ── ▶ Do — the headline verdict, last ──
    if showEngine and verdictOn
        table.cell(dash, 0, rr, " ▶ Do", text_color = doTxtC, bgcolor = doCol, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, rr, doTxt + " ", text_color = doTxtC, bgcolor = doCol, text_size = size.small, text_halign = text.align_right)
        rr += 1

// ═══════════════════ LADDER STRIP — FLOW + MTF stack, PER-RUNG trend colour ═════════════════════════
// Each rung is coloured by its OWN direction (green up / red down / grey neutral) — a single cell in
// the main panel can't show per-arrow colours, so the colour-coded ladder lives in this compact strip.
f_mtfC(float z)              => f_mtfSgn(z) > 0 ? bullCol : f_mtfSgn(z) < 0 ? bearCol : midColr
f_stkArr(bool act, bool up) => not act ? "·" : up ? "▲" : "▼"
f_stkC(bool act, bool up)   => not act ? midColr : up ? bullCol : bearCol
var table strip = table.new(f_pos(ladderPos), 8, 6, frame_width = 1, border_width = 1)
if barstate.islast and showEngine and mtfStrip and (mtfOn or (msOn and msLegend))
    table.set_frame_color(strip, frameC)
    table.set_border_color(strip, frameC)
    int sr = 0
    if mtfOn
        // FLOW ladder: TF header row + per-rung coloured arrow row
        table.cell(strip, 0, sr, "FLOW", text_color = pStr, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 1, sr, r1, text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 2, sr, a2 ? r2 : "·", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 3, sr, a3 ? r3 : "·", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 4, sr, a4 ? r4 : "·", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 5, sr, a5 ? r5 : "·", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 6, sr, a6 ? r6 : "·", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 7, sr, "", bgcolor = panelBg)
        sr += 1
        table.cell(strip, 0, sr, (mtfAlign >= 0 ? "+" : "") + str.tostring(mtfAlign), text_color = f_luma(mtfCol) > 150 ? color.black : color.white, bgcolor = mtfCol, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 1, sr, f_mtfArr(mz1), text_color = f_mtfC(mz1), bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 2, sr, a2 ? f_mtfArr(mz2) : "·", text_color = a2 ? f_mtfC(mz2) : midColr, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 3, sr, a3 ? f_mtfArr(mz3) : "·", text_color = a3 ? f_mtfC(mz3) : midColr, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 4, sr, a4 ? f_mtfArr(mz4) : "·", text_color = a4 ? f_mtfC(mz4) : midColr, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 5, sr, a5 ? f_mtfArr(mz5) : "·", text_color = a5 ? f_mtfC(mz5) : midColr, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 6, sr, a6 ? f_mtfArr(mz6) : "·", text_color = a6 ? f_mtfC(mz6) : midColr, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 7, sr, "", bgcolor = rowAlt)
        sr += 1
    if msOn and msLegend
        // MTF stack: TF header row + per-TF direction-coloured arrow row (greyed when faster than chart)
        table.cell(strip, 0, sr, "Stack", text_color = pStr, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 1, sr, "1",  text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 2, sr, "2",  text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 3, sr, "3",  text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 4, sr, "5",  text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 5, sr, "15", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 6, sr, "30", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 7, sr, "60", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_center)
        sr += 1
        table.cell(strip, 0, sr, "", bgcolor = rowAlt)
        table.cell(strip, 1, sr, f_stkArr(msA1,  msU1),  text_color = f_stkC(msA1,  msU1),  bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 2, sr, f_stkArr(msA2,  msU2),  text_color = f_stkC(msA2,  msU2),  bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 3, sr, f_stkArr(msA3,  msU3),  text_color = f_stkC(msA3,  msU3),  bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 4, sr, f_stkArr(msA5,  msU5),  text_color = f_stkC(msA5,  msU5),  bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 5, sr, f_stkArr(msA15, msU15), text_color = f_stkC(msA15, msU15), bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 6, sr, f_stkArr(msA30, msU30), text_color = f_stkC(msA30, msU30), bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        table.cell(strip, 7, sr, f_stkArr(msA60, msU60), text_color = f_stkC(msA60, msU60), bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_center)
        sr += 1

// ═══════════════════ MARKER LEGEND (KEY) — explains the on-chart markers (v2.13 UX) ════════════════
// A compact key, like the sibling scripts: what each mark means, so the chart reads without the manual.
// Table only → no plot budget.
f_posKey(string s) => s == "Bottom Right" ? position.bottom_right : s == "Top Left" ? position.top_left : s == "Middle Left" ? position.middle_left : position.bottom_left
var table keyUX = table.new(f_posKey(keyPosUX), 2, 6, frame_width = 1, border_width = 1, frame_color = frameC)
if showKeyUX and showEngine and barstate.islast
    table.cell(keyUX, 0, 0, "KEY", text_color = color.white, bgcolor = mpHdr, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyUX, 1, 0, "MADP markers", text_color = color.white, bgcolor = mpHdr, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyUX, 0, 1, "▣ 72", text_color = bullCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(keyUX, 1, 1, "MTF signal — box = fused conviction 0–100", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyUX, 0, 2, "▲ FLIP", text_color = bullCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(keyUX, 1, 2, "Trailing-stop flip (+ conviction number)", text_color = pTxt, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyUX, 0, 3, "▲ ▼", text_color = bullCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(keyUX, 1, 3, "Pressure triangles — chart-TF buy/sell flow fired", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyUX, 0, 4, "🔴🟡🟢", text_color = pStr, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(keyUX, 1, 4, "Safe zone — Critical → Watch → Safe cushion to stop", text_color = pTxt, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyUX, 0, 5, "▬", text_color = bullCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(keyUX, 1, 5, "Trailing stop (teal up / orange down) · ░ = exhaustion", text_color = pTxt, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_left)

// MADP exports (Data Window) — preserved verbatim so existing input.source() consumers keep working
plot(mpExpOn ? mpSlotA.cvd : na, "EXP_CVD_A", exC, display = display.data_window)
plot(mpExpOn ? mpSlotB.cvd : na, "EXP_CVD_B", exC, display = display.data_window)
plot(mpExpOn ? mpSlotC.cvd : na, "EXP_CVD_C", exC, display = display.data_window)
float mpWhaleThr = ta.percentile_linear_interpolation(fV, 200, 97)
bool  mpWhaleBar = barstate.isconfirmed and not na(mpWhaleThr) and fV >= mpWhaleThr
plot(mpExpOn ? (mpWhaleBar ? 1 : 0) : na, "EXP_WhaleBar", exC, display = display.data_window)
// MADP whale-print alerts — preserved
alertcondition(mpWhaleBar,                    "Whale print",      "MADP: a >=97th-percentile volume print occurred.")
alertcondition(mpWhaleBar and close >= open,  "Whale buy print",  "MADP: large up-print (aggressive buying).")
alertcondition(mpWhaleBar and close <  open,  "Whale sell print", "MADP: large down-print (aggressive selling).")
````
