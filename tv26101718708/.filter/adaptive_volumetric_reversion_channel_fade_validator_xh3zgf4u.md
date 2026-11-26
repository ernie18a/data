# Adaptive Volumetric Reversion Channel  Fade Validator

- url: https://www.tradingview.com/script/xH3ZgF4u-Adaptive-Volumetric-Reversion-Channel-Fade-Validator/
- type: indicator
- pine_id: PUB;3e29aa1744f8487698e91b6bdf100ea8
- version: 1.0

## Description

Adaptive Volumetric Reversion Channel — Fade Validator (AVRC)

What it is

AVRC is an anchored, volume-weighted regression channel that frames mean-reversion ("fade") setups and then gates, scores and validates them — so you can see whether fading stretched price actually has an edge on your symbol and timeframe instead of taking it on faith. It is a study / analysis framework, not a strategy and not a signal service.

Why these components are combined (the mashup rationale)

Fading an extreme asks three different questions, and no single classic tool answers all three. AVRC coordinates several non-redundant lenses on one shared geometry (an anchored regression channel) and one shared volatility unit (residual σ), so each lens can check the others rather than echoing it:


WHERE is price stretched? A volume-weighted regression centerline with residual-σ bands is drawn against a slower macro trend-relative volume map — volume binned by σ-distance from a longer regression line. Whether the tactical band sits in a thin (fast-traversed) or thick (heavily-traded) macro node tells you if a fade is likely clean or absorbed. This cross-read is the connective tissue between the two layers.
Is a reversion ACTUALLY firing? Independent "tells" at the band — a close-back rejection, a band-confluent momentum divergence, an equal-high/low liquidity sweep, and the macro-density read. Because these tells are correlated, their agreement is shrunk by a design-effect correction so echoes can't masquerade as independent confirmation.
Is the market in a reverting STATE? A regime gate (variance-ratio test + a reversion-trust correlation) only passes fades when price increments offset rather than compound. An entry-time ride-risk score (macro-trend alignment, the two-centerline spread, an already-walking band, momentum, mean-reversion half-life, and multi-timeframe trend consensus) flags fades likely to be "walked" rather than reverted.


The components share one geometry and one volatility unit, and each can veto the others. The goal is to suppress low-quality fades more than to generate them.

How the validation layer works (what makes this more than a drawing)

Every fade is logged and, a fixed horizon later, resolved: its forward return is measured in ATR units and tabulated Gate ON vs Gate OFF — follow-through %, a Wilson 95% interval, whipsaw %, and mean R per fade. Outcomes are additionally split Reverted vs Rode, by macro node (thin/thick), and by ride-risk (low/high at the running median). The panel's Edge line synthesizes this into a single read: is Gate ON's follow-through interval clearing the ungated baseline with positive mean R and enough samples? Per-fade rows also export to the Data Window for your own analysis. Every filter has to earn its place against the ungated baseline.

How to use it


Set the Price source (top of settings). Defaults are tuned for an intraday index future; the source is user-selectable so the framework runs on any symbol or market. Volume-based parts (heatmap, profile, POC) need a real volume feed.
Read the panel top-down: Now (live setup) → State (regime + spread + compression) → the A/B scoreboard (Gate OFF, Gate ON, Revert, Ride) → Edge verdict.
A fade arms when price tags the outer band and at least one tell prints, then passes only if the regime (and optional ride-risk) gate agrees. Target is the centerline or the nearest untested POC.
If Gate ON does not beat Gate OFF on follow-through and mean R with non-overlapping intervals and enough samples, the edge isn't there on this symbol/timeframe — change them, don't force it. The signal is clearest on higher intraday timeframes; 1-minute is mostly noise.


What is original here

The original work is the coordination: a shared-σ, timeframe-adaptive regression channel used as a reversion frame; a trend-relative volume map cross-read against the band; decorrelated tells fused by a design-effect shrink; a statistical regime gate; an entry-time ride-risk score; and a built-in A/B + forward-return validation harness — combined so each lens can veto the others and the tool reports its own hit rate. It is not a re-skin of any single indicator.

Concept credits (techniques are standard; this implementation is original)

Volume-weighted least-squares & polynomial regression; residual-σ channels; anchored VWAP (all standard); Volume Profile / Value Area / Point of Control — Market Profile (Steidlmayer / CBOT); Variance-Ratio test — Lo & MacKinlay (1988); design effect / effective sample size — Kish (1965); proportion confidence interval — Wilson (1927); mean-reversion half-life — Ornstein–Uhlenbeck process; ATR, RSI, Parabolic SAR — Wilder; Stochastic — Lane; Supertrend (classic, MTF context). Builds on established open-source regression-channel and anchored-VWAP techniques.

Settings (all defaults are on; tuned for an intraday index future)

Data/Source · Volatility unit · Macro volume heatmap · Tactical channel & bands · Interrelation & band-walk · Ride-risk filter · Density cross-read · Reversion tells · Regime gate · POC targets · Fade signal · Validation & export · Dashboard & theme (auto light/dark) · MTF trend context. The two signal-suppression gates (walk-gate, ride-gate) ship off so the indicator shows its signals and lets the validation panel tell you whether enabling them helps.

Disclaimer

For research and education only. NOT financial advice, NOT a recommendation, and NOT a guarantee of future results. All statistics shown are in-sample on loaded history, close-to-close at the horizon, without costs or slippage — a study aid, not a backtest. Mean reversion fails in trends and during regime breaks. Do your own research and manage your own risk.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  ADAPTIVE VOLUMETRIC REVERSION CHANNEL — Fade Validator
// ------------------------------------------------------------------------
//  OVERVIEW
//  An anchored, volume-weighted regression channel that frames mean-reversion
//  ("fade") setups, then GATES, SCORES and—critically—VALIDATES them, so a
//  trader can see whether fading stretched price actually carries an edge on
//  their own symbol and timeframe rather than taking it on faith. It is a
//  study / analysis framework, not a strategy and not a signal service.
//
//  WHY THESE PARTS ARE COMBINED (mashup rationale)
//  Fading an extreme asks three separate questions, and no single classic tool
//  answers all three. This script coordinates several NON-redundant lenses on
//  ONE shared geometry (an anchored regression channel) and ONE shared
//  volatility unit (residual σ), so each lens can check the others:
//    1. WHERE is price stretched?  A volume-weighted regression centerline with
//       residual-σ bands, drawn against a MACRO trend-relative volume map (volume
//       binned by σ-distance from a longer regression line). Where the tactical
//       band sits inside that macro map — a THIN, fast-traversed node vs a THICK,
//       heavily-traded one — tells you if a fade is likely clean or absorbed.
//    2. Is a reversion ACTUALLY firing?  Independent "tells" at the band: a
//       close-back rejection, a band-confluent momentum divergence, an equal-
//       high/low liquidity sweep, and a macro-density read. Correlated tells are
//       shrunk by a design-effect correction so echoes can't pose as confirmation.
//    3. Is the market in a reverting STATE?  A regime gate (variance-ratio test +
//       a reversion-trust correlation) only passes fades when increments offset
//       rather than compound. An entry-time RIDE-RISK score (trend, spread,
//       band-walk, momentum, half-life, multi-timeframe consensus) flags fades
//       likely to be "walked" rather than reverted.
//
//  THE VALIDATION LAYER (what makes this more than a drawing)
//  Every fade is logged and, a fixed horizon later, RESOLVED: forward return in
//  ATR units, tabulated GATE ON vs OFF (follow-through %, Wilson 95% interval,
//  whipsaw %, mean R), and additionally split REVERTED-vs-RODE and by node and by
//  ride-risk. The gate and every filter must EARN their place against the ungated
//  baseline. Per-fade rows export to the Data Window for your own analysis.
//
//  ADAPTIVE TO ANY MARKET / TIMEFRAME
//  Lookbacks are TIME-BASED (minutes → bars via the chart timeframe, then clamped)
//  and every band/bin width is in σ, so the geometry means the same thing on a
//  1-minute and a daily chart. The Price source is user-selectable, so the whole
//  framework runs on any symbol or market. Volume-based parts (heatmap, profile,
//  POC, order-flow) need a real volume feed.
//
//  HOW TO USE
//   • Set the Price source; defaults are tuned for an intraday index future
//     (e.g. NIFTY). Read the panel top-down: NOW (live setup), STATE (regime +
//     spread), then the A/B scoreboard — does GATE ON beat GATE OFF on follow-
//     through AND mean R, and do REVERTED fades beat RODE ones, with enough
//     samples? If the edge isn't there on your symbol/timeframe, change them.
//   • A fade arms when price tags the outer band and at least one tell prints,
//     then passes only if the regime (and optional ride-risk) gate agrees. Target
//     is the centerline or the nearest untested POC.
//
//  ORIGINALITY
//  The original work is the COORDINATION: a shared-σ adaptive regression channel
//  used as a reversion frame, a trend-relative volume map cross-read against the
//  band, decorrelated tells fused by a design-effect shrink, a statistical regime
//  gate, an entry-time ride-risk score, and a built-in A/B + forward-return
//  validation harness — combined so each lens can veto the others and the tool
//  reports its own hit rate. It is not a re-skin of any single indicator.
//
//  CONCEPT CREDITS (techniques are standard; this implementation is original)
//   Linear / volume-weighted least-squares & polynomial regression (standard);
//   residual-σ channel (standard); anchored VWAP (standard); Volume Profile /
//   Value Area / Point of Control — Market Profile (Steidlmayer / CBOT);
//   Variance-Ratio test — Lo & MacKinlay (1988); design effect / effective sample
//   size — Kish (1965); proportion confidence interval — Wilson (1927); mean-
//   reversion half-life — Ornstein–Uhlenbeck process; ATR, RSI, Parabolic SAR —
//   Wilder; Stochastic — Lane; Supertrend (classic, MTF context). Builds on
//   established open-source regression-channel and anchored-VWAP techniques.
//
//  LICENSE  ·  Creative Commons BY-NC-SA 4.0
//  https://creativecommons.org/licenses/by-nc-sa/4.0/
//
//  DISCLAIMER
//  For research and education only. NOT financial advice, NOT a recommendation,
//  and NOT a guarantee of future results. All statistics shown are IN-SAMPLE on
//  loaded history, close-to-close at the horizon, without costs or slippage — a
//  study aid, not a backtest. Mean reversion fails in trends and during regime
//  breaks. Do your own research and manage your own risk.
// ════════════════════════════════════════════════════════════════════════
indicator("Adaptive Volumetric Reversion Channel — Fade Validator", "AVRC", overlay=true, max_bars_back=2000, max_polylines_count=100, max_boxes_count=100, max_labels_count=200, max_lines_count=120, dynamic_requests=true)

// ───────────────────────────── 01 · DATA, SOURCE & FRAME ───────────────
g0 = "01 · Data, Source & Frame"
src        = input.source(hl2, "Price source", group=g0, tooltip="Series the channel and the σ-binned volume map are built from. Works on ANY symbol/market — change it (hl2 / hlc3 / close / another plot) to retarget the framework. Volume-based parts (heatmap, profile, POC) need a real volume feed.")
srcHigh    = input.source(high, "High source", group=g0, tooltip="High series used by the divergence pivots. Defaults to chart high; repoint for non-standard instruments.")
srcLow     = input.source(low,  "Low source",  group=g0, tooltip="Low series, paired with the High source above.")
macroMin   = input.int(6000, "Macro context (minutes)", minval=60, group=g0, tooltip="TIME-based macro window. Converted to bars via the chart timeframe, then clamped to [40 .. 1490]. On low TFs it scales up and hits the ceiling; on high TFs it floors out (e.g. ~40 bars on a daily) — both give a sensible structural frame.")
tacticalMin= input.int(480,  "Tactical rolling fallback (minutes)", minval=10, group=g0, tooltip="Rolling-anchor fallback window for the tactical channel (used when not anchoring to a swing). Same time→bars→clamp logic.")
anchorMode = input.string("Dual (auto)", "Tactical anchor", options=["Rolling","Swing Low","Swing High","Dual (auto)"], group=g0, tooltip="Where the tactical regression starts. Dual re-anchors at whichever swing pivot is most recent.")
pivFib     = input.string("21", "Swing pivot length", options=["8","13","21","34","55","89"], group=g0)
polyDeg    = input.int(1, "Tactical curve degree (0 flat·1 linear·2 quad)", minval=0, maxval=2, group=g0)

// ───────────────────────────── 02 · VOLATILITY UNIT ────────────────────
g1 = "02 · Volatility Unit"
atrLen     = input.int(14, "ATR length", minval=1, group=g1, tooltip="ATR is the validation R-unit and SAR/extension scale. The channel bands and heatmap bins use the regression's own residual / price σ.")
sigRange   = input.float(3.0, "Heatmap σ range (± each side)", minval=1.0, maxval=6.0, step=0.5, group=g1, tooltip="The macro map spans ± this many σ from the centerline, split into the rows below.")

// ───────────────────────────── 03 · HEATMAP (BACKDROP) ─────────────────
g2 = "03 · Macro Volume Heatmap"
showHeat   = input.bool(true, "Show macro volume heatmap", group=g2)
macroDeg   = input.int(1, "Macro curve degree (0 flat·1 linear·2 polynomial)", minval=0, maxval=2, group=g2, tooltip="Shape of the macro centerline the volume is binned around. 0/1 use cheap built-ins. 2 = a VOLUME-WEIGHTED quadratic via the robust normalized solver (no matrix inversion). Linear is usually the more honest reversion baseline — a quadratic can bend toward the very swing you're fading and shrink the σ-stretch. A/B it: flip this and compare the panel's Gate-ON FT% / mean R and the Thin/Thick row. NOTE: degree 2 fits the full macro window every bar — heavier on very low TFs / long windows.")
rowsBase   = input.int(30, "Grid rows each side", minval=5, maxval=45, group=g2, tooltip="Stepped down on very low TFs automatically.")
smoothBase = input.int(4, "Gradient smoothing passes", minval=0, maxval=20, group=g2)
heatLW     = input.int(10, "Heatmap band width", minval=1, maxval=100, group=g2)
projLen    = input.int(30, "Future projection (bars)", minval=0, maxval=200, group=g2)
c1In = input.color(color.new(#000000,100), "Low volume",  inline="hc", group=g2)
c2In = input.color(color.new(#5b9cf6, 95), "·", inline="hc", group=g2)
c3In = input.color(color.new(#089981, 90), "·", inline="hc", group=g2)
c4In = input.color(color.new(#ff9800, 80), "·", inline="hc", group=g2)
c5In = input.color(color.new(#f23645, 60), "High volume", inline="hc", group=g2)

// ───────────────────────────── 04 · TACTICAL BANDS ─────────────────────
g3 = "04 · Tactical Channel & Bands"
mult1   = input.float(1.0, "Inner band (σ)", minval=0.1, step=0.1, group=g3)
mult2   = input.float(2.0, "Outer band — fade trigger (σ)", minval=0.1, step=0.1, group=g3)
fillMode= input.string("Reversion heat", "Channel fill", options=["Reversion heat","Neon glow","Off"], group=g3)
glowOn  = input.bool(true, "Neon glow", group=g3)
lw      = input.int(2, "Line width", minval=1, maxval=6, group=g3)
colUp   = input.color(#21dfac, "Up / support", inline="c", group=g3)
colDn   = input.color(#df216d, "Down / resistance", inline="c", group=g3)

// ───────────────────────── 04b · INTERRELATION & BAND-WALK ─────────────
gIR = "05 · Interrelation & Band-Walk"
showSpread = input.bool(true, "Show centerline spread (tactical vs macro)", group=gIR, tooltip="Shades the gap between the tactical AVWAP mean and the macro regression mean. Wide gap = the fast frame is pulling away from slow fair value; near-zero = the two frames agree. Read it as convergence/divergence of the two means, not a price level.")
showMacroLn= input.bool(true, "Plot macro centerline", group=gIR, tooltip="Draw the macro regression mean as a line so the spread fill has a visible second edge.")
spreadDiv  = input.float(1.5, "Wide-spread threshold (σ)", minval=0.25, step=0.25, group=gIR, tooltip="|tactical − macro| beyond this many macro-σ counts as a wide divergence of the two means.")
walkBars   = input.int(3, "Band-walk streak = RIDE", minval=2, maxval=15, group=gIR, tooltip="Consecutive closes beyond the outer band that count as WALKING the band — continuation (ride), not reversion (fade). This is the split that separates 'tagged and faded' from 'tagged and kept walking' in the panel.")
walkGate   = input.bool(false, "Suppress fades while band is walking (ride)", group=gIR, tooltip="Optional: don't fire a fade while price is actively walking the band on the fade side. Off by default — the panel measures ride vs revert either way, so you can see whether suppressing helps before committing to it.")

// ───────────────────────── 04c · RIDE-RISK FILTER ──────────────────────
gRR = "06 · Ride-Risk Filter"
useRideRisk = input.bool(true, "Compute entry-time ride-risk score", group=gRR, tooltip="Predicts BEFORE entry whether a fade is likely to be walked (ride) rather than revert. Built from independent continuation tells: macro-trend alignment against the fade, the two-centerline spread pushing the fade's way, a trending variance-ratio, an already-walking band, and an OU half-life longer than the follow-through horizon. 0 = clean fade, 100 = likely ride.")
rideThr   = input.int(50, "Gate: suppress at ride-risk ≥", minval=10, maxval=95, group=gRR, tooltip="Threshold for the optional gate below. The panel's Risk lo/hi R diagnostic does NOT use this — it auto-splits fades at the running MEDIAN so the two buckets always stay balanced and comparable. Once that row shows low-risk clearly beating high-risk, set this near the median to gate the worse half.")
rideGate  = input.bool(false, "Suppress high ride-risk fades", group=gRR, tooltip="Gate fades whose ride-risk ≥ threshold. Default OFF — turn on only once the panel's RideRisk lo/hi R row proves low-risk fades beat high-risk ones with enough samples.")
rideConf  = input.bool(true, "Down-weight confidence by ride-risk", group=gRR, tooltip="Scale the displayed fade confidence down as ride-risk rises.")
hlWin     = input.int(50, "OU half-life window", minval=20, maxval=300, group=gRR, tooltip="Window for the AR(1) half-life estimate of the deviation from the tactical mean. Half-life longer than the follow-through horizon means the move can't revert in time — counted as ride-risk.")
momLen    = input.int(5, "Momentum length (ride-risk)", minval=2, maxval=50, group=gRR, tooltip="Lookback for the rate-of-change term in ride-risk. Strong momentum in the fade-against direction at the tag is a leading sign the band will be walked.")
densAdapt = input.bool(true, "Self-correct density polarity", group=gRR, tooltip="The chart can prove thin nodes are NOT the cleaner fades on a given tape (thick may beat thin). With this on, the density tell/gate/confidence follow whichever side the panel's own Thin/Thick stats show is better, instead of assuming thin — so the density layer can't sit backwards. Stays neutral until it has enough samples.")

// ───────────────────────────── 05 · DENSITY CROSS-READ ─────────────────
g4 = "07 · Density Cross-Read"
densMode  = input.string("Confidence modifier", "Density role", options=["Off","Confidence modifier","Extra tell","Hard gate"], group=g4, tooltip="How the macro density at the tagged band feeds the signal. Start as Confidence modifier; promote to Extra tell / Hard gate only after the panel shows THIN beats THICK.")
liveDensMin = input.int(600, "Live density window (minutes)", minval=30, group=g4, tooltip="Rolling window for the LIVE density read at the band (time-based). Smaller/recent acceptance is what actually absorbs a fade now; separate from the deep display map.")
thinPct   = input.float(0.30, "Thin node ≤ (density ratio)", minval=0.0, maxval=1.0, step=0.05, group=g4, tooltip="Band density (0..1 of local max) at or below this = THIN = clean fade.")
thickPct  = input.float(0.65, "Thick node ≥ (density ratio)", minval=0.0, maxval=1.0, step=0.05, group=g4, tooltip="At or above this = THICK = absorption risk.")

// ───────────────────────────── 06 · REVERSION TELLS ────────────────────
g5 = "08 · Reversion Tells"
showDiv  = input.bool(true, "Momentum divergence tell", group=g5)
oscType  = input.string("Stoch RSI", "Divergence oscillator", options=["Stoch RSI","RSI"], group=g5)
rsiLen   = input.int(14, "RSI length", minval=2, group=g5)
stochLen = input.int(14, "Stoch length", minval=2, group=g5)
kSmooth  = input.int(3, "Stoch %K smooth", minval=1, group=g5)
divPiv   = input.int(5, "Divergence pivot length", minval=2, maxval=30, group=g5)
confBand = input.string("1σ", "Divergence must reach band", options=["Off","1σ","2σ"], group=g5)
showDivLine = input.bool(true, "Draw divergence lines", group=g5)
useSweep = input.bool(true, "Liquidity-sweep tell", group=g5)
swPiv    = input.int(8, "Sweep swing pivot length", minval=2, maxval=30, group=g5)
swTolATR = input.float(0.10, "Equal-level tolerance (×ATR)", minval=0.02, maxval=1.0, step=0.02, group=g5)
confWin  = input.int(6, "Tell recency window (bars)", minval=1, maxval=30, group=g5)
corrWin  = input.int(20, "Decorrelation window (Kish)", minval=10, maxval=100, group=g5)

// ───────────────────────────── 07 · REGIME GATE ────────────────────────
g6 = "09 · Regime Gate"
regMode  = input.string("Either", "Gate", options=["VR only","Reversion only","Either","Both","Off"], group=g6, tooltip="VR<1 (Lo-MacKinlay): increments offset. Reversion: prior-deviation→next-return correlation negative.")
vrK      = input.int(5,   "VR horizon k", minval=2, maxval=30, group=g6)
vrLen    = input.int(100, "VR sample window", minval=20, maxval=400, group=g6)
vrBand   = input.float(0.10, "VR neutral band", minval=0.0, maxval=0.9, step=0.05, group=g6)
revMeanLen = input.int(20, "Reversion mean length", minval=5, group=g6)
revWin   = input.int(100, "Reversion corr window", minval=30, maxval=400, group=g6)
revThr   = input.float(0.15, "Reverting above corr", minval=0.0, maxval=0.8, step=0.05, group=g6)

// ───────────────────────────── 08 · POC TARGETS ────────────────────────
g7 = "10 · POC Targets"
showVP   = input.bool(true, "Anchored POC / value area", group=g7)
vaPct    = input.float(70.0, "Value-area %", minval=50, maxval=95, step=1, group=g7) / 100.0
vpBins   = input.int(24, "Profile resolution", minval=8, maxval=60, group=g7)
colPoc   = input.color(#ffa600, "POC / VA color", group=g7)
showNaked= input.bool(true, "Untested prior-session POC magnets", group=g7)
nakedGrid= input.int(10, "Daily map grid (ticks/bin)", minval=1, maxval=200, group=g7)
nakedVa  = input.float(70, "Daily value-area %", minval=50, maxval=95, group=g7)
maxNaked = input.int(15, "Keep last N naked POCs", minval=2, maxval=60, group=g7)
maxMagnetATR = input.float(40, "Magnet max distance (×ATR, 0=off)", minval=0, step=5, group=g7, tooltip="Legacy ATR cap (kept for compatibility). The σ cap below is the primary one.")
magMaxSig = input.float(3.0, "Magnet max distance (×macro σ, 0=off)", minval=0, step=0.5, group=g7, tooltip="The nearest naked POC only counts as the fade's magnet if it's within this many MACRO σ of price — which scales with the instrument and keeps the target inside the channel (bands are ±3σ). Stops a far prior-session POC hundreds of points away from showing as the target.")

// ───────────────────────────── 09 · FADE SIGNAL ────────────────────────
g8 = "11 · Fade Signal & Markers"
fadeGap     = input.int(5, "Min bars between fades", minval=1, maxval=50, group=g8)
showFade    = input.bool(true, "Fade markers (gated)", group=g8)
showUngated = input.bool(false, "Mark ungated-only fades (faint)", group=g8)

// ───────────────────────────── 10 · VALIDATION & EXPORT ────────────────
g9 = "12 · Validation & Export"
horizon  = input.int(10,  "Follow-through horizon (bars)", minval=3, maxval=100, group=g9)
moveATR  = input.float(0.5,"Follow-through size (×ATR)", minval=0.1, maxval=3.0, step=0.1, group=g9)
whipWin  = input.int(10,  "Whipsaw window (bars)", minval=2, maxval=60, group=g9)
logExport= input.bool(true, "Emit per-fade log (Data Window)", group=g9)

// ───────────────────────────── 11 · DASHBOARD ──────────────────────────
g10 = "13 · Dashboard & Theme"
showPanel = input.bool(true, "Show validation panel", group=g10)
panelMode = input.string("Compact", "Detail", options=["Compact","Pro"], group=g10)
panelPos  = input.string("Bottom Left","Position", options=["Bottom Left","Bottom Right","Top Left","Top Right","Middle Left"], group=g10)
themeOpt  = input.string("Auto", "Theme", options=["Auto","Dark","Light"], group=g10)

// ───────────────────────────── 12 · MTF S/R ────────────────────────────
g11 = "14 · MTF Trend Context"
useMtfSR = input.bool(true, "Show MTF S/R lines", group=g11)
mtfFac   = input.float(3.0, "Supertrend factor", minval=0.5, maxval=12.0, step=0.1, group=g11)
mtfAtr   = input.int(10, "Supertrend ATR length", minval=1, maxval=100, group=g11)
mtfLab   = input.bool(true, "Right-edge labels", group=g11)
mtfColUp = input.color(#21dfac, "Support", inline="mc", group=g11)
mtfColDn = input.color(#ff5d73, "Resistance", inline="mc", group=g11)
mtfTf1 = input.timeframe("3",  "TF 1", inline="t1", group=g11)
mtfTf2 = input.timeframe("5",  "TF 2", inline="t1", group=g11)
mtfTf3 = input.timeframe("15", "TF 3", inline="t2", group=g11)
mtfTf4 = input.timeframe("30", "TF 4", inline="t2", group=g11)
mtfTf5 = input.timeframe("60", "TF 5", inline="t3", group=g11)
mtfTf6 = input.timeframe("240","TF 6", inline="t3", group=g11)

// ───────────────────────────── SETUP / HELPERS ─────────────────────────
int pivLen = switch pivFib
    "8"=>8
    "13"=>13
    "21"=>21
    "34"=>34
    "55"=>55
    "89"=>89
    =>21
float vw   = (na(volume) or volume <= 0) ? 1.0 : volume
float atrV = ta.atr(atrLen)
int   secNow = timeframe.in_seconds()

// time(min) → bars, then clamp to Pine-safe range
f_barsFor(int targetMin) =>
    raw = math.round(targetMin * 60.0 / math.max(secNow, 1))
    math.max(40, math.min(raw, 1490))

// TF-stepped chooser for discrete knobs (low / mid / high TF)
f_tfStep(int lo, int mid, int hi) =>
    secNow <= 60 ? lo : secNow <= 300 ? mid : hi

int macroBars = f_barsFor(macroMin)
int tacBars   = f_barsFor(tacticalMin)
int liveBars  = math.min(f_barsFor(liveDensMin), macroBars)
int rows      = f_tfStep(math.max(8, rowsBase - 12), math.max(10, rowsBase - 6), rowsBase)
int smoothN   = f_tfStep(math.min(smoothBase + 2, 20), smoothBase, math.max(0, smoothBase - 1))

// keep history available for deep loops
var float _h1 = src[1490]
var float _h2 = close[1490]
var float _h3 = volume[1490]

// ───────────────────────────── MACRO CENTERLINE + σ ────────────────────
// σ scale stays the raw price stdev (same convention as the source heatmaps) so the
// band scale does NOT collapse when a degree-2 curve bends — extremes stay honest.
float macroSigma = ta.stdev(src, macroBars)
float binWidthSig = macroSigma > 0 ? (sigRange / rows) : na   // σ per bin

// Volume-weighted, normalized (u=pos/100), closed-form quadratic — no matrix.inv.
// pos runs oldest(0) → newest(win-1); robust conditioning via the u-scaling.
f_macroQuad(int win) =>
    float A0=0.0
    float A1=0.0
    float A2=0.0
    float A3=0.0
    float A4=0.0
    float B0=0.0
    float B1=0.0
    float B2=0.0
    int seed = win < 1490 ? win - 1 : 1489
    for i = 0 to seed
        float u  = i / 100.0
        float u2 = u*u
        int   bk = (win - 1) - i
        float wk = nz(vw[bk])
        float yk = src[bk]
        A0 += wk
        A1 += wk*u
        A2 += wk*u2
        A3 += wk*u2*u
        A4 += wk*u2*u2
        B0 += wk*yk
        B1 += wk*u*yk
        B2 += wk*u2*yk
    float c0=na
    float c1=0.0
    float c2=0.0
    if A0 > 0
        float e=A2
        float f=A3
        float h=A3
        float ii=A4
        float det = A0*(e*ii - f*h) - A1*(A1*ii - f*A2) + A2*(A1*h - e*A2)
        if math.abs(det) > 1e-12
            c0 := (B0*(e*ii - f*h) - A1*(B1*ii - f*B2) + A2*(B1*h - e*B2))/det
            c1 := (A0*(B1*ii - f*B2) - B0*(A1*ii - f*A2) + A2*(A1*B2 - B1*A2))/det
            c2 := (A0*(e*B2 - B1*h) - A1*(A1*B2 - B1*A2) + B0*(A1*h - e*A2))/det
        else
            c0 := B0/A0
    [c0, c1, c2]

// Resolve coefficients per degree (cheap built-ins for 0/1; weighted solve only for 2)
// ta.* hoisted so they evaluate every bar regardless of the active degree branch.
float _linNow  = ta.linreg(src, macroBars, 0)
float _linPrev = ta.linreg(src, macroBars, 1)
float _smaV    = ta.sma(src, macroBars)
float mc0 = na
float mc1 = 0.0
float mc2 = 0.0
float macroCenter = na
float macroSlope  = 0.0
if macroDeg == 2
    [q0, q1, q2] = f_macroQuad(macroBars)
    mc0 := q0
    mc1 := q1
    mc2 := q2
    float uNow = (macroBars - 1) / 100.0
    macroCenter := na(q0) ? _linNow : q0 + q1*uNow + q2*uNow*uNow
else if macroDeg == 1
    macroCenter := _linNow
    macroSlope  := _linNow - _linPrev
else
    macroCenter := _smaV
    macroSlope  := 0.0

// Unified centerline value at a window position (0=oldest .. macroBars-1=now; >now projects)
f_macroAtPos(float pos) =>
    macroDeg == 2 ? (mc0 + mc1*(pos/100.0) + mc2*(pos/100.0)*(pos/100.0)) : (macroCenter + macroSlope*(pos - (macroBars - 1)))

// LIVE σ-binned density (rolling, every bar) — used by the cross-read + validation
// Returns density RATIO (0..1 of local max) at a given price level P.
var array<float> liveBinsA = array.new<float>(rows * 2, 0.0)
float liveMax = 0.0
if macroSigma > 0 and not na(binWidthSig) and binWidthSig > 0 and not na(macroCenter)
    for i = 0 to (rows * 2) - 1
        array.set(liveBinsA, i, 0.0)
    for k = 0 to liveBars - 1
        float lineAtK = f_macroAtPos((macroBars - 1) - k)  // current centerline, k bars back
        float devSig  = (src[k] - lineAtK) / macroSigma
        int   bi = int(math.floor(devSig / binWidthSig)) + rows
        if bi >= 0 and bi < rows * 2
            array.set(liveBinsA, bi, array.get(liveBinsA, bi) + nz(vw[k]))
    liveMax := array.max(liveBinsA)

f_densAt(float price) =>
    float r = na
    if macroSigma > 0 and not na(binWidthSig) and binWidthSig > 0 and liveMax > 0
        float devSig = (price - macroCenter) / macroSigma
        int bi = int(math.floor(devSig / binWidthSig)) + rows
        if bi >= 0 and bi < rows * 2
            r := array.get(liveBinsA, bi) / liveMax
    r

// ───────────────────────────── TACTICAL ENGINE (anchored poly-AVWAP) ────
polyAVWAP(int paBar, int deg) =>
    var int anc=na
    var float A0=0.0
    var float A1=0.0
    var float A2=0.0
    var float A3=0.0
    var float A4=0.0
    var float B0=0.0
    var float B1=0.0
    var float B2=0.0
    var float Q=0.0
    float Kp = 100.0
    float center = na
    float sigma  = na
    if not na(paBar)
        int span = bar_index - paBar
        if na(anc) or anc != paBar
            A0:=0.0
            A1:=0.0
            A2:=0.0
            A3:=0.0
            A4:=0.0
            B0:=0.0
            B1:=0.0
            B2:=0.0
            Q:=0.0
            anc := paBar
            int seed = span < 1490 ? span : 1490
            for k = 0 to seed
                float u = (span - k)/Kp
                float u2 = u*u
                float wk = vw[k]
                float yk = src[k]
                A0 += wk
                A1 += wk*u
                A2 += wk*u2
                A3 += wk*u2*u
                A4 += wk*u2*u2
                B0 += wk*yk
                B1 += wk*u*yk
                B2 += wk*u2*yk
                Q  += wk*yk*yk
        else
            float u = span/Kp
            float u2 = u*u
            A0 += vw
            A1 += vw*u
            A2 += vw*u2
            A3 += vw*u2*u
            A4 += vw*u2*u2
            B0 += vw*src
            B1 += vw*u*src
            B2 += vw*u2*src
            Q  += vw*src*src
        if A0 > 0
            float uNow = span/Kp
            float c0=na
            float c1=0.
            float c2=0.
            if deg <= 0
                c0 := B0/A0
            else if deg == 1
                float det = A0*A2 - A1*A1
                c0 := math.abs(det) > 1e-12 ? (B0*A2 - A1*B1)/det : B0/A0
                c1 := math.abs(det) > 1e-12 ? (A0*B1 - A1*B0)/det : 0.0
            else
                float e=A2
                float f=A3
                float h=A3
                float ii=A4
                float det = A0*(e*ii - f*h) - A1*(A1*ii - f*A2) + A2*(A1*h - e*A2)
                if math.abs(det) > 1e-12
                    c0 := (B0*(e*ii - f*h) - A1*(B1*ii - f*B2) + A2*(B1*h - e*B2))/det
                    c1 := (A0*(B1*ii - f*B2) - B0*(A1*ii - f*A2) + A2*(A1*B2 - B1*A2))/det
                    c2 := (A0*(e*B2 - B1*h) - A1*(A1*B2 - B1*A2) + B0*(A1*h - e*A2))/det
                else
                    c0 := B0/A0
            center := c0 + c1*uNow + c2*uNow*uNow
            float sse = Q - (c0*B0 + c1*B1 + c2*B2)
            sigma := math.sqrt(math.max(sse/A0, 0.0))
    [center, sigma]

// anchor selection
pl = ta.pivotlow(low, pivLen, pivLen)
ph = ta.pivothigh(high, pivLen, pivLen)
var int lBar=na
var int hBar=na
if not na(pl)
    lBar := bar_index - pivLen
if not na(ph)
    hBar := bar_index - pivLen
bool dualLowRecent = nz(lBar,-1) >= nz(hBar,-1)
int dualBar = dualLowRecent ? lBar : hBar
int paBar = anchorMode == "Rolling" ? bar_index - (tacBars - 1) : anchorMode == "Swing Low" ? lBar : anchorMode == "Swing High" ? hBar : dualBar
if na(paBar)
    paBar := bar_index - (tacBars - 1)

[pvwap, psd] = polyAVWAP(paBar, polyDeg)

bool  isUp = pvwap >= pvwap[1]
color tCol = isUp ? colUp : colDn
float u1 = pvwap + psd*mult1
float l1 = pvwap - psd*mult1
float u2 = pvwap + psd*mult2
float l2 = pvwap - psd*mult2

plot(glowOn ? pvwap : na, "halo2", color=color.new(tCol,77), linewidth=lw+6)
plot(glowOn ? pvwap : na, "halo1", color=color.new(tCol,49), linewidth=lw+2)
pMid = plot(pvwap, "AVWAP", color=tCol, linewidth=lw)
pU1 = plot(u1, "U1", color=color.new(tCol, glowOn?30:16))
pL1 = plot(l1, "L1", color=color.new(tCol, glowOn?30:16))
pU2 = plot(u2, "U2", color=color.new(tCol, glowOn?38:49))
pL2 = plot(l2, "L2", color=color.new(tCol, glowOn?38:49))

// ── INTERRELATION: spread of the two centerlines (in macro-σ) ───────────
float spreadPx  = pvwap - macroCenter                 // tactical mean − macro mean
float spreadSig = macroSigma > 0 ? spreadPx / macroSigma : na   // in shared σ
float sigRatio  = macroSigma > 0 ? psd / macroSigma : na        // tacticalσ / macroσ (compression)
bool  spreadConv = not na(spreadSig) and math.abs(spreadSig) < math.abs(nz(spreadSig[1], spreadSig))  // narrowing
// macro centerline as a plot so the spread fill has a second edge
pMacro = plot(showMacroLn or showSpread ? macroCenter : na, "Macro mean", color=showMacroLn ? color.new(#9aa3b2, 30) : color.new(#9aa3b2, 100), linewidth=1)
// fill the gap: green when tactical above macro (fast frame leading up), red when below; brighter as it widens
f_spreadFill() =>
    na(spreadSig) or not showSpread ? na : color.new(spreadSig >= 0 ? colUp : colDn, math.max(60, 92 - int(math.min(math.abs(spreadSig), 4.0) * 8)))
fill(pMid, pMacro, f_spreadFill(), title="Centerline spread")
f_fc(int seg, bool up) =>
    fillMode == "Off" ? na : fillMode == "Reversion heat" ? color.new(up?colDn:colUp, 84 - seg*16) : color.new(tCol, glowOn ? math.min(96,82+seg*9) : (seg==0?81:88))
fill(pMid, pU1, f_fc(0,true),  title="Fill 1σ up")
fill(pMid, pL1, f_fc(0,false), title="Fill 1σ dn")
fill(pU1,  pU2, f_fc(1,true),  title="Fill 2σ up")
fill(pL1,  pL2, f_fc(1,false), title="Fill 2σ dn")

// ───────────────────────────── MACRO HEATMAP DISPLAY (last bar) ─────────
get_gradient(float ratio) =>
    float r = math.pow(math.max(0.0, math.min(1.0, ratio)), 0.7)
    r < 0.25 ? color.from_gradient(r,0.0,0.25,c1In,c2In) : r < 0.5 ? color.from_gradient(r,0.25,0.5,c2In,c3In) : r < 0.75 ? color.from_gradient(r,0.5,0.75,c3In,c4In) : color.from_gradient(r,0.75,1.0,c4In,c5In)

var array<polyline> heatLines = array.new<polyline>()
if barstate.islast and showHeat and macroSigma > 0 and not na(binWidthSig) and binWidthSig > 0
    if array.size(heatLines) > 0
        for p in heatLines
            polyline.delete(p)
        array.clear(heatLines)
    // deep display histogram over full macro window
    array<float> dispBins = array.new<float>(rows*2, 0.0)
    for k = 0 to macroBars - 1
        float lineAtK = f_macroAtPos((macroBars - 1) - k)
        float devSig  = (src[k] - lineAtK) / macroSigma
        int bi = int(math.floor(devSig / binWidthSig)) + rows
        if bi >= 0 and bi < rows*2
            array.set(dispBins, bi, array.get(dispBins, bi) + nz(vw[k]))
    // smooth (1-4-6-4-1)
    array<float> sm = array.copy(dispBins)
    if smoothN > 0
        for s = 1 to smoothN
            array<float> tmp = array.copy(sm)
            for i = 0 to (rows*2)-1
                float v  = array.get(tmp,i)
                float l1v= i>0 ? array.get(tmp,i-1) : v
                float r1v= i<(rows*2)-1 ? array.get(tmp,i+1) : v
                float l2v= i>1 ? array.get(tmp,i-2) : l1v
                float r2v= i<(rows*2)-2 ? array.get(tmp,i+2) : r1v
                array.set(sm, i, (l2v + l1v*4.0 + v*6.0 + r1v*4.0 + r2v)/16.0)
    float mx = array.max(sm)
    if mx > 0
        int totalLen = macroBars + projLen
        for step = 0 to (rows*2)-1
            float w = array.get(sm, step)
            float offSig = (step - rows) * binWidthSig + binWidthSig/2.0   // σ offset of bin center
            float offPx  = offSig * macroSigma
            color cb = get_gradient(w / mx)
            array<chart.point> pts = array.new<chart.point>()
            for idx = 0 to totalLen - 1
                int tx = bar_index + idx - macroBars + 1
                float baseP = f_macroAtPos(idx)   // centerline across window + projection (curved if deg 2)
                pts.push(chart.point.from_index(tx, baseP + offPx))
            if array.size(pts) > 1
                array.push(heatLines, polyline.new(pts, line_width=heatLW, line_style=line.style_solid, line_color=cb))

// ───────────────────────────── ANCHORED VOLUME PROFILE (last bar) ───────
var line  pocLn=na
var box   vaBox=na
var label pocLb=na
var label vahLb=na
var label valLb=na
float vpPOC = na
if barstate.islast and showVP
    line.delete(pocLn)
    box.delete(vaBox)
    label.delete(pocLb)
    label.delete(vahLb)
    label.delete(valLb)
    int winLen = math.min(anchorMode == "Rolling" ? tacBars : (bar_index - paBar + 1), 1490)
    if not na(winLen) and winLen > 2
        int xa = math.max(0, bar_index - winLen + 1)
        int xe = bar_index + math.min(math.round(winLen*0.25), 60)
        float hi = high
        float lo = low
        for i = 0 to winLen - 1
            hi := math.max(hi, high[i])
            lo := math.min(lo, low[i])
        float step = (hi - lo) / vpBins
        if step > 0
            array<float> bk = array.new<float>(vpBins, 0.0)
            for i = 0 to winLen - 1
                int idx = math.max(0, math.min(vpBins-1, int(math.floor((src[i]-lo)/step))))
                array.set(bk, idx, array.get(bk, idx) + vw[i])
            int pocBin = array.indexof(bk, array.max(bk))
            vpPOC := lo + (pocBin + 0.5)*step
            float tot = array.sum(bk)
            float vaV = array.get(bk, pocBin)
            int up = pocBin
            int dn = pocBin
            while vaV < tot*vaPct and (up < vpBins-1 or dn > 0)
                float aV = up < vpBins-1 ? array.get(bk, up+1) : -1.0
                float bV = dn > 0 ? array.get(bk, dn-1) : -1.0
                if aV < 0 and bV < 0
                    break
                if aV >= bV
                    up += 1
                    vaV += aV
                else
                    dn -= 1
                    vaV += bV
            float vah = lo + (up+1)*step
            float val = lo + dn*step
            vaBox := box.new(xa, vah, xe, val, border_color=color.new(colPoc,28), border_width=1, bgcolor=color.new(colPoc,86))
            pocLn := line.new(xa, vpPOC, xe, vpPOC, color=colPoc, width=2)
            pocLb := label.new(xe, vpPOC, "POC", style=label.style_label_left, color=color.new(colPoc,10), textcolor=color.white, size=size.small)
            vahLb := label.new(xe, vah, "VAH", style=label.style_label_left, color=color.new(colPoc,15), textcolor=color.white, size=size.tiny)
            valLb := label.new(xe, val, "VAL", style=label.style_label_left, color=color.new(colPoc,15), textcolor=color.white, size=size.tiny)

// ───────────────────────────── DIVERGENCE TELL ─────────────────────────
float rsiV     = ta.rsi(close, rsiLen)
float stochRsi = ta.sma(ta.stoch(rsiV, rsiV, rsiV, stochLen), kSmooth)
float osc      = oscType == "RSI" ? rsiV : stochRsi
phD = ta.pivothigh(srcHigh, divPiv, divPiv)
plD = ta.pivotlow(srcLow, divPiv, divPiv)
var float dLastPH=na
var float dPrevPH=na
var float dLastPHo=na
var float dPrevPHo=na
var int   dLastPHb=na
var int   dPrevPHb=na
var float dLastPL=na
var float dPrevPL=na
var float dLastPLo=na
var float dPrevPLo=na
var int   dLastPLb=na
var int   dPrevPLb=na
bool atUp = confBand == "Off" ? true : confBand == "2σ" ? high[divPiv] >= u2[divPiv] : high[divPiv] >= u1[divPiv]
bool atLo = confBand == "Off" ? true : confBand == "2σ" ? low[divPiv]  <= l2[divPiv] : low[divPiv]  <= l1[divPiv]
bool bearDiv = false
bool bullDiv = false
if not na(phD)
    dPrevPH:=dLastPH
    dPrevPHo:=dLastPHo
    dPrevPHb:=dLastPHb
    dLastPH:=phD
    dLastPHo:=osc[divPiv]
    dLastPHb:=bar_index-divPiv
    if not na(dPrevPH) and not na(dPrevPHo)
        bearDiv := showDiv and dLastPH > dPrevPH and dLastPHo < dPrevPHo and atUp
if not na(plD)
    dPrevPL:=dLastPL
    dPrevPLo:=dLastPLo
    dPrevPLb:=dLastPLb
    dLastPL:=plD
    dLastPLo:=osc[divPiv]
    dLastPLb:=bar_index-divPiv
    if not na(dPrevPL) and not na(dPrevPLo)
        bullDiv := showDiv and dLastPL < dPrevPL and dLastPLo > dPrevPLo and atLo
plotshape(bearDiv ? high[divPiv] : na, "Bear div", shape.diamond, location.absolute, color.new(colDn,0), size=size.tiny, offset=-divPiv)
plotshape(bullDiv ? low[divPiv]  : na, "Bull div", shape.diamond, location.absolute, color.new(colUp,0), size=size.tiny, offset=-divPiv)
var array<line> dLines = array.new<line>()
if showDivLine and bearDiv and not na(dPrevPHb)
    array.push(dLines, line.new(dPrevPHb, dPrevPH, dLastPHb, dLastPH, color=color.new(colDn,0), width=2, style=line.style_dashed))
    while array.size(dLines) > 60
        line.delete(array.shift(dLines))
if showDivLine and bullDiv and not na(dPrevPLb)
    array.push(dLines, line.new(dPrevPLb, dPrevPL, dLastPLb, dLastPL, color=color.new(colUp,0), width=2, style=line.style_dashed))
    while array.size(dLines) > 60
        line.delete(array.shift(dLines))
var int lastBearDivBar=na
var int lastBullDivBar=na
if bearDiv
    lastBearDivBar := bar_index
if bullDiv
    lastBullDivBar := bar_index

// ───────────────────────────── LIQUIDITY SWEEP TELL ────────────────────
phS = ta.pivothigh(swPiv, swPiv)
plS = ta.pivotlow(swPiv, swPiv)
var float lastPH=na
var float prevPH=na
var float lastPL=na
var float prevPL=na
if not na(phS)
    prevPH := lastPH
    lastPH := phS
if not na(plS)
    prevPL := lastPL
    lastPL := plS
float eqDist = swTolATR * atrV
var float eqhLvl=na
var float eqlLvl=na
if not na(phS) and not na(prevPH) and math.abs(lastPH - prevPH) <= eqDist
    eqhLvl := math.max(lastPH, prevPH)
if not na(plS) and not na(prevPL) and math.abs(lastPL - prevPL) <= eqDist
    eqlLvl := math.min(lastPL, prevPL)
bool sweepHigh = useSweep and ((not na(eqhLvl) and high > eqhLvl and close < eqhLvl) or (not na(lastPH) and high > lastPH and close < lastPH and close < open))
bool sweepLow  = useSweep and ((not na(eqlLvl) and low  < eqlLvl and close > eqlLvl) or (not na(lastPL) and low  < lastPL and close > lastPL and close > open))
var int lastSweepHiBar=na
var int lastSweepLoBar=na
if sweepHigh
    lastSweepHiBar := bar_index
if sweepLow
    lastSweepLoBar := bar_index
bool freshSweepHi = not na(lastSweepHiBar) and (bar_index - lastSweepHiBar) <= 3
bool freshSweepLo = not na(lastSweepLoBar) and (bar_index - lastSweepLoBar) <= 3

// ───────────────────────────── REGIME GATE ─────────────────────────────
float ret  = math.log(close / close[1])
float r1v  = ta.variance(ret, vrLen)
float retK = math.log(close / close[vrK])
float rKv  = ta.variance(retK, vrLen)
float vr   = (r1v != 0 and vrK > 0) ? rKv / (vrK * r1v) : 1.0
bool revertVR = vr <= 1.0 - vrBand
bool trendVR  = vr >= 1.0 + vrBand
float revMean = ta.sma(close, revMeanLen)
float revDev  = close - revMean
float revRet  = close - close[1]
float revCorr = ta.correlation(revDev[1], revRet, revWin)
float revScore= not na(revCorr) ? math.max(0.0, -revCorr) : na
bool reverting = not na(revScore) and revScore >= revThr
bool regimeOK = regMode == "Off" ? true : regMode == "VR only" ? revertVR : regMode == "Reversion only" ? reverting : regMode == "Both" ? (revertVR and reverting) : (revertVR or reverting)

// OU half-life of the deviation from the tactical mean (AR(1) autocorrelation → λ).
// Half-life longer than the follow-through horizon = the move can't revert in time.
float ouDev = close - pvwap
float ouB   = ta.correlation(ouDev, ouDev[1], hlWin)            // ≈ AR(1) coefficient
float ouHL  = (not na(ouB) and ouB > 0.0 and ouB < 1.0) ? -math.log(2.0)/math.log(ouB) : na  // bars to half-revert; na = non-reverting
bool  ouSlow = na(ouHL) or ouHL > horizon                       // can't revert within the eval horizon

// MTF supertrend (also drawn as S/R lines later) + trend consensus for ride-risk.
// Computed here so the ride-risk score can read the higher-timeframe agreement.
f_htfst(simple float fac, simple int per) =>
    [stv, d] = ta.supertrend(fac, per)
    [stv[1], d[1]]
[mV1,mD1] = request.security(syminfo.tickerid, mtfTf1, f_htfst(mtfFac,mtfAtr), lookahead=barmerge.lookahead_off)
[mV2,mD2] = request.security(syminfo.tickerid, mtfTf2, f_htfst(mtfFac,mtfAtr), lookahead=barmerge.lookahead_off)
[mV3,mD3] = request.security(syminfo.tickerid, mtfTf3, f_htfst(mtfFac,mtfAtr), lookahead=barmerge.lookahead_off)
[mV4,mD4] = request.security(syminfo.tickerid, mtfTf4, f_htfst(mtfFac,mtfAtr), lookahead=barmerge.lookahead_off)
[mV5,mD5] = request.security(syminfo.tickerid, mtfTf5, f_htfst(mtfFac,mtfAtr), lookahead=barmerge.lookahead_off)
[mV6,mD6] = request.security(syminfo.tickerid, mtfTf6, f_htfst(mtfFac,mtfAtr), lookahead=barmerge.lookahead_off)
int mtfBull = (nz(mD1,1)<0?1:0)+(nz(mD2,1)<0?1:0)+(nz(mD3,1)<0?1:0)+(nz(mD4,1)<0?1:0)+(nz(mD5,1)<0?1:0)+(nz(mD6,1)<0?1:0)  // # of TFs in uptrend (supertrend dir < 0)

// ───────────────────────────── NAKED POC MAGNETS ───────────────────────
float nkStep = syminfo.mintick * nakedGrid
var map<int,float> nkMap = map.new<int,float>()
var array<float> nkPx = array.new<float>(0)
var array<bool> nkLive = array.new<bool>(0)
f_mapVA(m, st, pct) =>
    ks = map.keys(m)
    int nK = array.size(ks)
    float tot=0.
    float bestV=-1.
    int bestK=0
    int minK = nK>0 ? array.get(ks,0):0
    int maxK = nK>0 ? array.get(ks,0):0
    for i = 0 to nK-1
        kk = array.get(ks,i)
        vv = map.get(m,kk)
        tot += vv
        if vv > bestV
            bestV := vv
            bestK := kk
        minK := math.min(minK,kk)
        maxK := math.max(maxK,kk)
    float acc=bestV
    int up=bestK
    int dn=bestK
    float target = tot*pct/100.0
    span = maxK-minK+2
    for n = 0 to span
        if acc >= target
            break
        upCan = up < maxK
        dnCan = dn > minK
        if not upCan and not dnCan
            break
        uV = upCan and map.contains(m,up+1) ? map.get(m,up+1):0.
        dV = dnCan and map.contains(m,dn-1) ? map.get(m,dn-1):0.
        if (uV >= dV and upCan) or not dnCan
            up += 1
            acc += uV
        else
            dn -= 1
            acc += dV
    [(bestK+0.5)*st, (up+1)*st, dn*st]
bool newDay = ta.change(time("D")) != 0
if showNaked and newDay and map.size(nkMap) > 0
    [dP, dH, dL] = f_mapVA(nkMap, nkStep, nakedVa)
    map.clear(nkMap)
    if not na(dP)
        bool straddled = false
        int lbk = math.min(20, bar_index)
        for kk = 0 to lbk
            if low[kk] <= dP and high[kk] >= dP
                straddled := true
                break
        if not straddled
            array.push(nkPx, dP)
            array.push(nkLive, true)
            if array.size(nkPx) > maxNaked
                array.shift(nkPx)
                array.shift(nkLive)
if showNaked and nkStep > 0 and high >= low
    float nRng = high - low
    int nSub = nRng <= 0 ? 1 : int(math.min(16, int(nRng / nkStep) + 1))
    float nVp = vw / nSub
    for s = 0 to nSub - 1
        float nPx = nSub == 1 ? hlc3 : low + nRng * s / (nSub - 1)
        int nK = int(math.floor(nPx / nkStep))
        float pv = map.contains(nkMap, nK) ? map.get(nkMap, nK) : 0.0
        map.put(nkMap, nK, pv + nVp)
if showNaked and array.size(nkPx) > 0
    for i = 0 to array.size(nkPx) - 1
        if array.get(nkLive, i) and low <= array.get(nkPx, i) and high >= array.get(nkPx, i)
            array.set(nkLive, i, false)
float nkMagnet = na
float nkMagD = 1e20
float magCapAtr = maxMagnetATR * nz(atrV, 0)
float magCapSig = magMaxSig * nz(macroSigma, 0)
if array.size(nkPx) > 0
    for i = 0 to array.size(nkPx) - 1
        if array.get(nkLive, i)
            float d = math.abs(array.get(nkPx, i) - close)
            bool okAtr = magCapAtr <= 0 or d <= magCapAtr
            bool okSig = magCapSig <= 0 or d <= magCapSig
            if d < nkMagD and okAtr and okSig
                nkMagD := d
                nkMagnet := array.get(nkPx, i)
var array<line> nkLines = array.new<line>()
if showNaked and barstate.islast
    if array.size(nkLines) > 0
        for ln in nkLines
            line.delete(ln)
        array.clear(nkLines)
    int nlx = bar_index - math.min(200, bar_index)
    int nrx = bar_index + 3
    if array.size(nkPx) > 0
        for i = 0 to array.size(nkPx) - 1
            if array.get(nkLive, i)
                float yv = array.get(nkPx, i)
                bool isMag = not na(nkMagnet) and yv == nkMagnet
                array.push(nkLines, line.new(nlx, yv, nrx, yv, color=color.new(#b39ddb, isMag?0:50), width=isMag?2:1, style=line.style_dashed))

// ───────────────────────────── FADE SIGNAL + DENSITY CROSS-READ ─────────
float z = psd > 0 ? (close - pvwap)/psd : 0.0
bool tagUpper = high >= u2
bool tagLower = low  <= l2
bool rejUpper = tagUpper and close < u2
bool rejLower = tagLower and close > l2
bool recentDivU = not na(lastBearDivBar) and (bar_index - lastBearDivBar) <= confWin
bool recentDivL = not na(lastBullDivBar) and (bar_index - lastBullDivBar) <= confWin

// ── BAND-WALK (ride) detection: consecutive closes beyond the outer band ──
var int walkUpN = 0
var int walkDnN = 0
walkUpN := close > u2 ? walkUpN + 1 : 0
walkDnN := close < l2 ? walkDnN + 1 : 0
bool rideUp = walkUpN >= walkBars   // price walking ABOVE upper band → continuation up (short fade is wrong)
bool rideDn = walkDnN >= walkBars   // price walking BELOW lower band → continuation dn (long fade is wrong)
bool riding = rideUp or rideDn

// density at the tagged band, classified
float densU = f_densAt(u2)
float densL = f_densAt(l2)
bool thinU  = not na(densU) and densU <= thinPct
bool thickU = not na(densU) and densU >= thickPct
bool thinL  = not na(densL) and densL <= thinPct
bool thickL = not na(densL) and densL >= thickPct
// SELF-CORRECTING POLARITY: densFavorThin is set by the harness from the live Thin/Thick
// edge (default thin until enough samples). The density layer follows the proven side, so
// it can't sit backwards on a tape where thick beats thin.
var bool densFavorThin = true
bool favU   = densAdapt ? (densFavorThin ? thinU : thickU) : thinU      // empirically-better node, upper
bool favL   = densAdapt ? (densFavorThin ? thinL : thickL) : thinL
bool unfavU = densAdapt ? (densFavorThin ? thickU : thinU) : thickU     // worse node, upper
bool unfavL = densAdapt ? (densFavorThin ? thickL : thinL) : thickL
bool densTellU = densMode == "Extra tell" and favU
bool densTellL = densMode == "Extra tell" and favL
bool densGateU = densMode != "Hard gate" or favU       // hard gate: require the favored node
bool densGateL = densMode != "Hard gate" or favL

// tells per side (rejection · divergence · sweep · density-as-tell)
int tellsU = (rejUpper?1:0) + (recentDivU?1:0) + (freshSweepHi?1:0) + (densTellU?1:0)
int tellsL = (rejLower?1:0) + (recentDivL?1:0) + (freshSweepLo?1:0) + (densTellL?1:0)
int maxTells = 3 + (densMode == "Extra tell" ? 1 : 0)

// ── RIDE-RISK SCORE (entry-time): predicts a walk BEFORE it happens ──────
// Independent continuation tells, each 0..1, weighted to sum 1:
//   macro-trend (.14) · spread push (.20) · band already walking (.18) ·
//   momentum in the fade-against direction (.16) · OU too slow (.14) · MTF consensus (.18)
float slopeMag = macroSigma > 0 ? math.min(math.abs(macroSlope*macroBars)/macroSigma, 1.0) : 0.0
bool  macroUp  = macroSlope > 0
float spMag    = (not na(spreadSig) and not spreadConv) ? math.min(math.abs(spreadSig)/math.max(spreadDiv,0.1), 1.0) : 0.0
float cOU      = ouSlow ? 1.0 : 0.0
float cMtfS    = mtfBull/6.0           // short ride-risk: HTF consensus UP fights the short
float cMtfL    = (6-mtfBull)/6.0       // long  ride-risk: HTF consensus DOWN fights the long
float rocV     = ta.roc(close, momLen)
float rocStd   = ta.stdev(rocV, 50)
float momMag   = rocStd > 0 ? math.min(math.abs(rocV)/(2.0*rocStd), 1.0) : 0.0
float momUp    = rocV > 0 ? momMag : 0.0    // up-momentum fuels a ride against a short
float momDn    = rocV < 0 ? momMag : 0.0
// short fade (upper): ride = continuation UP
float rrU = 100.0*(0.14*(macroUp ? slopeMag : 0.0) + 0.20*((not na(spreadSig) and spreadSig>0) ? spMag : 0.0) + 0.18*(rideUp?1.0:0.0) + 0.16*momUp + 0.14*cOU + 0.18*cMtfS)
// long fade (lower): ride = continuation DOWN
float rrL = 100.0*(0.14*((not macroUp and macroSlope<0) ? slopeMag : 0.0) + 0.20*((not na(spreadSig) and spreadSig<0) ? spMag : 0.0) + 0.18*(rideDn?1.0:0.0) + 0.16*momDn + 0.14*cOU + 0.18*cMtfL)
int rideRiskU = useRideRisk ? int(math.round(rrU)) : 0
int rideRiskL = useRideRisk ? int(math.round(rrL)) : 0

// Kish design-effect shrink from the continuous tell-drivers
float sStretch = z
float sOsc = osc
float sClv = (high-low) > 0 ? ((close-low)-(high-close))/(high-low) : 0.0
float rA = ta.correlation(sStretch, sOsc, corrWin)
float rB = ta.correlation(sStretch, sClv, corrWin)
float rC = ta.correlation(sOsc, sClv, corrWin)
float rhoBar = (math.abs(nz(rA)) + math.abs(nz(rB)) + math.abs(nz(rC)))/3.0
float nEff = 3.0 / (1.0 + 2.0*rhoBar)
float famShrink = nEff/3.0
f_conf(int tells, bool fav, bool unfav, int risk) =>
    float eff = tells >= 1 ? 1.0 + (tells-1)*famShrink : 0.0
    float base = math.min(100.0, eff / float(maxTells) * 100.0)
    // density modifier follows the favored side; ride-risk down-weights
    float m = densMode == "Confidence modifier" ? (fav ? 1.20 : unfav ? 0.70 : 1.0) : 1.0
    float rk = (rideConf and useRideRisk) ? (1.0 - 0.6*risk/100.0) : 1.0
    math.round(math.min(100.0, base*m*rk))
int confU = f_conf(tellsU, favU, unfavU, rideRiskU)
int confL = f_conf(tellsL, favL, unfavL, rideRiskL)

var int lastFadeBar = na
bool cool = na(lastFadeBar) or (bar_index - lastFadeBar) >= fadeGap
bool shortRaw = tagUpper and tellsU >= 1 and cool
bool longRaw  = tagLower and tellsL >= 1 and cool
if shortRaw or longRaw
    lastFadeBar := bar_index
bool shortGated = shortRaw and regimeOK and densGateU and (not walkGate or not rideUp) and (not rideGate or not useRideRisk or rideRiskU < rideThr)
bool longGated  = longRaw  and regimeOK and densGateL and (not walkGate or not rideDn) and (not rideGate or not useRideRisk or rideRiskL < rideThr)

plotshape(showFade and shortGated ? high : na, "Fade short", shape.triangledown, location.abovebar, color.new(colDn,0), size=size.small)
plotshape(showFade and longGated  ? low  : na, "Fade long",  shape.triangleup,   location.belowbar, color.new(colUp,0), size=size.small)
plotshape(showUngated and shortRaw and not (regimeOK and densGateU) ? high : na, "Fade short ungated", shape.triangledown, location.abovebar, color.new(colDn,70), size=size.tiny)
plotshape(showUngated and longRaw  and not (regimeOK and densGateL) ? low  : na, "Fade long ungated",  shape.triangleup,   location.belowbar, color.new(colUp,70), size=size.tiny)

// ───────────────────────────── VALIDATION HARNESS (A/B + density) ───────
// model 0 = ungated · model 1 = gated. Plus thin/thick split among GATED fades.
var array<int> breaksN = array.new<int>(2, 0)
var array<int> whipN   = array.new<int>(2, 0)
var array<int> whipPB  = array.new<int>(2, -1)
var array<int> whipPD  = array.new<int>(2, 0)
var array<int> calTot  = array.new<int>(2, 0)
var array<int> calHit  = array.new<int>(2, 0)
var array<float> rSum  = array.new<float>(2, 0.0)
var array<int>   rN    = array.new<int>(2, 0)
// thin/thick (gated): idx 0 = thin, 1 = thick
var array<int> ndTot = array.new<int>(2, 0)
var array<int> ndHit = array.new<int>(2, 0)
// ride/revert split among GATED fades: idx 0 = REVERTED (faded), 1 = RODE (walked)
var array<int>   rrTot = array.new<int>(2, 0)
var array<int>   rrHit = array.new<int>(2, 0)
var array<float> rrR   = array.new<float>(2, 0.0)
var array<int>   rrN   = array.new<int>(2, 0)
// ride-risk split among GATED fades: idx 0 = LOW risk, 1 = HIGH risk (split at the running MEDIAN)
var array<int>   rkTot = array.new<int>(2, 0)
var array<int>   rkHit = array.new<int>(2, 0)
var array<float> rkR   = array.new<float>(2, 0.0)
var array<int>   rkN   = array.new<int>(2, 0)
var array<int>   riskHist = array.new<int>(21, 0)  // 5-pt bins of fade ride-risk, for the median
var int          riskMed  = 50                     // running median split (so lo/hi stay balanced)
// pending fades
var array<int>   pBar=array.new<int>(0)
var array<float> pPx =array.new<float>(0)
var array<float> pAtr=array.new<float>(0)
var array<int>   pDir=array.new<int>(0)
var array<bool>  pGat=array.new<bool>(0)
var array<float> pZ  =array.new<float>(0)
var array<int>   pTime=array.new<int>(0)
var array<int>   pNode=array.new<int>(0)   // 0 none ·1 thin ·2 thick
var array<bool>  pRide=array.new<bool>(0)  // did the band walk on the fade side before resolution?
var array<int>   pRisk=array.new<int>(0)   // entry-time ride-risk score

logFade(int dir, bool gated, int node, int risk) =>
    int pb0 = array.get(whipPB,0)
    int pd0 = array.get(whipPD,0)
    if pb0 != -1 and dir != pd0 and (bar_index - pb0) <= whipWin
        array.set(whipN,0, array.get(whipN,0)+1)
    array.set(whipPB,0,bar_index)
    array.set(whipPD,0,dir)
    array.set(breaksN,0, array.get(breaksN,0)+1)
    if gated
        int pb1 = array.get(whipPB,1)
        int pd1 = array.get(whipPD,1)
        if pb1 != -1 and dir != pd1 and (bar_index - pb1) <= whipWin
            array.set(whipN,1, array.get(whipN,1)+1)
        array.set(whipPB,1,bar_index)
        array.set(whipPD,1,dir)
        array.set(breaksN,1, array.get(breaksN,1)+1)
    array.push(pBar,bar_index)
    array.push(pPx,close)
    array.push(pAtr,atrV)
    array.push(pDir,dir)
    array.push(pGat,gated)
    array.push(pZ,z)
    array.push(pTime,time)
    array.push(pNode,node)
    array.push(pRide,false)
    array.push(pRisk,risk)
    int rkBin = math.max(0, math.min(20, int(risk/5)))
    array.set(riskHist, rkBin, array.get(riskHist, rkBin) + 1)

float logTimeX=na
float logDirX=na
float logGatX=na
float logZX=na
float logFwdRX=na
float logRawRX=na
float logWinX=na
float logNodeX=na
float logRideX=na
float logRiskX=na
if barstate.isconfirmed
    if shortRaw
        logFade(-1, regimeOK and densGateU, thinU ? 1 : thickU ? 2 : 0, rideRiskU)
    if longRaw
        logFade(1, regimeOK and densGateL, thinL ? 1 : thickL ? 2 : 0, rideRiskL)
    // mark any pending fade as RODE if the band walked on its fade side after entry
    if array.size(pBar) > 0
        for ri2 = 0 to array.size(pBar) - 1
            if not array.get(pRide, ri2)
                int dd = array.get(pDir, ri2)
                if (dd == -1 and rideUp) or (dd == 1 and rideDn)
                    array.set(pRide, ri2, true)
    // running median of ride-risk scores → adaptive, balanced lo/hi split
    int rmTot = 0
    for b = 0 to 20
        rmTot += array.get(riskHist, b)
    if rmTot >= 20
        int rmCum = 0
        for b = 0 to 20
            rmCum += array.get(riskHist, b)
            if rmCum*2 >= rmTot
                riskMed := b*5 + 2
                break
    int qi = 0
    while qi < array.size(pBar)
        if bar_index - array.get(pBar, qi) >= horizon
            float p0 = array.get(pPx, qi)
            float a0 = array.get(pAtr, qi)
            int   dr = array.get(pDir, qi)
            bool  gt = array.get(pGat, qi)
            int   nd = array.get(pNode, qi)
            bool  rode = array.get(pRide, qi)
            int   rsk  = array.get(pRisk, qi)
            float mv = close - p0
            bool  hit = dr == 1 ? mv >= moveATR*a0 : mv <= -moveATR*a0
            float fwdR = a0 > 0 ? dr*mv/a0 : na
            array.set(calTot,0, array.get(calTot,0)+1)
            if hit
                array.set(calHit,0, array.get(calHit,0)+1)
            if not na(fwdR)
                array.set(rSum,0, array.get(rSum,0)+fwdR)
                array.set(rN,0, array.get(rN,0)+1)
            if gt
                array.set(calTot,1, array.get(calTot,1)+1)
                if hit
                    array.set(calHit,1, array.get(calHit,1)+1)
                if not na(fwdR)
                    array.set(rSum,1, array.get(rSum,1)+fwdR)
                    array.set(rN,1, array.get(rN,1)+1)
                if nd == 1
                    array.set(ndTot,0, array.get(ndTot,0)+1)
                    if hit
                        array.set(ndHit,0, array.get(ndHit,0)+1)
                if nd == 2
                    array.set(ndTot,1, array.get(ndTot,1)+1)
                    if hit
                        array.set(ndHit,1, array.get(ndHit,1)+1)
                // ride/revert split: idx 1 = rode (walked), 0 = reverted (faded)
                int ri3 = rode ? 1 : 0
                array.set(rrTot, ri3, array.get(rrTot, ri3)+1)
                if hit
                    array.set(rrHit, ri3, array.get(rrHit, ri3)+1)
                if not na(fwdR)
                    array.set(rrR, ri3, array.get(rrR, ri3)+fwdR)
                    array.set(rrN, ri3, array.get(rrN, ri3)+1)
                // ride-risk split at the running MEDIAN (keeps lo/hi balanced & evaluable)
                int rk3 = rsk >= riskMed ? 1 : 0
                array.set(rkTot, rk3, array.get(rkTot, rk3)+1)
                if hit
                    array.set(rkHit, rk3, array.get(rkHit, rk3)+1)
                if not na(fwdR)
                    array.set(rkR, rk3, array.get(rkR, rk3)+fwdR)
                    array.set(rkN, rk3, array.get(rkN, rk3)+1)
                // self-correcting density polarity: follow whichever node measures better (≥30 each)
                int _tT2 = array.get(ndTot,0)
                int _kT2 = array.get(ndTot,1)
                if _tT2 >= 30 and _kT2 >= 30
                    float _thinFT  = array.get(ndHit,0)/float(_tT2)
                    float _thickFT = array.get(ndHit,1)/float(_kT2)
                    densFavorThin := _thinFT >= _thickFT
            logTimeX := array.get(pTime, qi)
            logDirX  := dr
            logGatX  := gt ? 1.0 : 0.0
            logZX    := array.get(pZ, qi)
            logFwdRX := fwdR
            logRawRX := a0 > 0 ? mv/a0 : na
            logWinX  := hit ? 1.0 : 0.0
            logNodeX := nd
            logRideX := rode ? 1.0 : 0.0
            logRiskX := rsk
            array.remove(pBar,qi)
            array.remove(pPx,qi)
            array.remove(pAtr,qi)
            array.remove(pDir,qi)
            array.remove(pGat,qi)
            array.remove(pZ,qi)
            array.remove(pTime,qi)
            array.remove(pNode,qi)
            array.remove(pRide,qi)
            array.remove(pRisk,qi)
        else
            qi += 1
    while array.size(pBar) > 500
        array.shift(pBar)
        array.shift(pPx)
        array.shift(pAtr)
        array.shift(pDir)
        array.shift(pGat)
        array.shift(pZ)
        array.shift(pTime)
        array.shift(pNode)
        array.shift(pRide)
        array.shift(pRisk)

// ───────────────────────────── PER-FADE EXPORT ─────────────────────────
plot(logExport and not na(logFwdRX) ? logTimeX : na, "log:txn_time_ms",       display=display.data_window)
plot(logExport and not na(logFwdRX) ? logDirX  : na, "log:dir 1long/-1short", display=display.data_window)
plot(logExport and not na(logFwdRX) ? logGatX  : na, "log:gated 1/0",         display=display.data_window)
plot(logExport and not na(logFwdRX) ? logNodeX : na, "log:node 0none1thin2thick", display=display.data_window)
plot(logExport and not na(logFwdRX) ? logRideX : na, "log:rode 1ride0revert", display=display.data_window)
plot(logExport and not na(logFwdRX) ? logRiskX : na, "log:ride_risk", display=display.data_window)
plot(logExport and not na(logFwdRX) ? logZX    : na, "log:stretch_sigma",     display=display.data_window)
plot(logExport and not na(logFwdRX) ? logFwdRX : na, "log:fwdR_atr",          display=display.data_window)
plot(logExport and not na(logFwdRX) ? logRawRX : na, "log:rawRet_atr_signed", display=display.data_window)
plot(logExport and not na(logFwdRX) ? logWinX  : na, "log:win 1/0",           display=display.data_window)

// ───────────────────────────── PANEL ───────────────────────────────────
f_propCI(int hits, int total) =>
    float lo=na
    float hi=na
    if total >= 5
        float p = hits/float(total)
        float zc = 1.96
        float den = 1.0 + zc*zc/total
        float cen = (p + zc*zc/(2.0*total))/den
        float hw  = zc*math.sqrt(p*(1.0-p)/total + zc*zc/(4.0*total*total))/den
        lo := math.max(0.0, cen-hw)
        hi := math.min(1.0, cen+hw)
    [lo, hi]
bool panelDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (0.299*color.r(chart.bg_color)+0.587*color.g(chart.bg_color)+0.114*color.b(chart.bg_color)) < 128
color cBg     = panelDark ? color.new(#0d1117,8)  : color.new(#ffffff,6)
color cBord   = panelDark ? color.new(#2b3340,0)  : color.new(#c2c8d0,0)
color cTxt    = panelDark ? #c2cbd6 : #3a424e
color cStrong = panelDark ? #f2f4f8 : #10151d
color cMut    = panelDark ? #9aa3b2 : #707a86
color cHdr    = panelDark ? color.new(#161d2b,0) : color.new(#e9edf2,0)
color cAcc    = panelDark ? #79c0ff : #1f6feb
color cAcc2   = panelDark ? #ffd166 : #9a6a00
color cAmber  = panelDark ? #e3b341 : #9a6a00
color cBull   = panelDark ? #2dd4bf : #0e7c5a
color cBear   = panelDark ? #ff6b6b : #c62828
ppMap = panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Top Left" ? position.top_left : panelPos == "Top Right" ? position.top_right : panelPos == "Middle Left" ? position.middle_left : position.bottom_left
var table T = table.new(ppMap, 5, 20, bgcolor=cBg, border_color=cBord, border_width=1)
f_row(tbl, int r, string k, string v, color vc, string x) =>
    table.cell(tbl,0,r,k, text_color=cTxt, text_size=size.small, text_formatting=text.format_bold)
    table.cell(tbl,1,r,v, text_color=vc, text_size=size.small, text_formatting=text.format_bold)
    table.cell(tbl,2,r,x, text_color=cMut, text_size=size.small, text_formatting=text.format_bold)
    table.cell(tbl,3,r,"", text_color=cTxt, text_size=size.small)
    table.cell(tbl,4,r,"", text_color=cTxt, text_size=size.small)
// scoreboard row: label | FT% | mean R | n
f_sb(int r, string lab, float ft, float rr, int n, color labCol) =>
    color ftC = n<5 ? cMut : ft>=50 ? cBull : ft>=42 ? cAmber : cBear
    color rC  = n<5 ? cMut : rr>0.02 ? cBull : rr<-0.02 ? cBear : cAmber
    table.cell(T,0,r, lab, text_color=labCol, text_size=size.small, text_formatting=text.format_bold, text_halign=text.align_left)
    table.cell(T,1,r, n<5?"–":str.tostring(ft,"0")+"%", text_color=ftC, text_size=size.small, text_formatting=text.format_bold)
    table.cell(T,2,r, n<5?"warm":str.tostring(rr,"+0.00;-0.00"), text_color=rC, text_size=size.small, text_formatting=text.format_bold)
    table.cell(T,3,r, str.tostring(n), text_color=cMut, text_size=size.small)
    table.cell(T,4,r, "", text_color=cMut, text_size=size.small)
if showPanel and barstate.islast
    table.clear(T,0,0,4,19)
    bool pro = panelMode == "Pro"
    int ri = 0
    // ── TITLE ──
    table.cell(T,0,ri,"AVRC", text_color=cAcc, bgcolor=cHdr, text_size=size.small, text_formatting=text.format_bold, text_halign=text.align_left)
    table.cell(T,1,ri, timeframe.period, text_color=cMut, bgcolor=cHdr, text_size=size.small)
    table.cell(T,2,ri, pro?"Pro":"", text_color=cMut, bgcolor=cHdr, text_size=size.small)
    table.cell(T,3,ri,"", bgcolor=cHdr)
    table.cell(T,4,ri,"", bgcolor=cHdr)
    ri += 1
    // ── NOW (live setup) ──
    string nodeNow = tagUpper ? (thinU?"thin":thickU?"thick":"mid") : tagLower ? (thinL?"thin":thickL?"thick":"mid") : "—"
    string rideNow = rideUp ? " RIDE↑" : rideDn ? " RIDE↓" : ""
    int    riskNow = tagUpper ? rideRiskU : tagLower ? rideRiskL : 0
    string riskTxt = (useRideRisk and (tagUpper or tagLower)) ? " · risk "+str.tostring(riskNow) : ""
    string magTxt  = (tagUpper or tagLower) and not na(nkMagnet) ? " → "+str.tostring(nkMagnet, format.mintick) : ""
    string fadeNow = shortGated ? "▼ SHORT "+str.tostring(confU)+"%" : longGated ? "▲ LONG "+str.tostring(confL)+"%" : tagUpper ? "at upper" : tagLower ? "at lower" : "flat"
    color  nowCol  = shortGated?cBear: longGated?cBull: (tagUpper or tagLower)?cAmber:cMut
    f_row(T, ri, "Now", fadeNow, nowCol, nodeNow+rideNow+riskTxt+magTxt)
    ri += 1
    // ── STATE (regime + spread) ──
    string stTxt = "VR "+str.tostring(vr,"0.00")+(revertVR?" rev":trendVR?" trend":"")+(na(spreadSig)?"":" · sprd "+str.tostring(spreadSig,"0.00")+"σ"+(spreadConv?" conv":" div"))+(na(sigRatio)?"":" · comp "+str.tostring(sigRatio,"0.00"))
    f_row(T, ri, "State", regimeOK?"gate ON":"gate off", regimeOK?cBull:cMut, stTxt)
    ri += 1
    // ── SCOREBOARD ──
    table.cell(T,0,ri,"A/B", text_color=cTxt, bgcolor=cHdr, text_size=size.small, text_formatting=text.format_bold, text_halign=text.align_left)
    table.cell(T,1,ri,"FT%", text_color=cTxt, bgcolor=cHdr, text_size=size.small, text_formatting=text.format_bold)
    table.cell(T,2,ri,"mean R", text_color=cTxt, bgcolor=cHdr, text_size=size.small, text_formatting=text.format_bold)
    table.cell(T,3,ri,"n", text_color=cTxt, bgcolor=cHdr, text_size=size.small, text_formatting=text.format_bold)
    table.cell(T,4,ri,"", bgcolor=cHdr)
    ri += 1
    int t0=array.get(calTot,0)
    int h0=array.get(calHit,0)
    int t1=array.get(calTot,1)
    int h1=array.get(calHit,1)
    int n0=array.get(rN,0)
    int n1=array.get(rN,1)
    float ft0 = t0>0?h0*100.0/t0:na
    float ft1 = t1>0?h1*100.0/t1:na
    float er0 = n0>0?array.get(rSum,0)/n0:na
    float er1 = n1>0?array.get(rSum,1)/n1:na
    f_sb(ri,"Gate OFF", ft0, er0, t0, cStrong)
    ri += 1
    f_sb(ri,"Gate ON", ft1, er1, t1, cAcc2)
    ri += 1
    int reT=array.get(rrTot,0)
    int rdT=array.get(rrTot,1)
    float reFT = reT>0?array.get(rrHit,0)*100.0/reT:na
    float rdFT = rdT>0?array.get(rrHit,1)*100.0/rdT:na
    int reN2=array.get(rrN,0)
    int rdN2=array.get(rrN,1)
    float reR2 = reN2>0?array.get(rrR,0)/reN2:na
    float rdR2 = rdN2>0?array.get(rrR,1)/rdN2:na
    f_sb(ri,"Revert", reFT, reR2, reT, cBull)
    ri += 1
    f_sb(ri,"Ride", rdFT, rdR2, rdT, cBear)
    ri += 1
    // ── EDGE VERDICT (A/B significance synthesis — the headline read) ──
    [elo0,ehi0] = f_propCI(h0,t0)
    [elo1,ehi1] = f_propCI(h1,t1)
    bool ftSig  = not na(elo1) and not na(ehi0) and elo1 >= ehi0           // ON's FT CI clears OFF's (non-overlap up)
    string edgeTxt = t1<30 ? "warming" : (not na(er1) and er1>0.02 and ftSig) ? "CONFIRMED" : (not na(er1) and not na(er0) and er1>er0 and er1>-0.02) ? "leaning" : "none / neg"
    color edgeCol = t1<30 ? cMut : edgeTxt=="CONFIRMED" ? cBull : edgeTxt=="leaning" ? cAmber : cBear
    string edgeCtx = t1<30 ? "n "+str.tostring(t1)+" (need ≥30)" : (ftSig?"gate CI clears base":"gate CI overlaps base")
    f_row(T, ri, "Edge", edgeTxt, edgeCol, edgeCtx)
    ri += 1
    // ── PRO DIAGNOSTICS ──
    if pro
        int loT=array.get(rkTot,0)
        int hiT=array.get(rkTot,1)
        int loN=array.get(rkN,0)
        int hiN=array.get(rkN,1)
        float loR=loN>0?array.get(rkR,0)/loN:na
        float hiR=hiN>0?array.get(rkR,1)/hiN:na
        string rkTxt=(loN<5?"·":str.tostring(loR,"+0.00;-0.00"))+" / "+(hiN<5?"·":str.tostring(hiR,"+0.00;-0.00"))
        color rkCol=(loN>=5 and hiN>=5)?(loR>hiR?cBull:cBear):cMut
        f_row(T, ri, "Risk lo/hi R", rkTxt, rkCol, "split@med "+str.tostring(riskMed)+" · n "+str.tostring(loT)+"/"+str.tostring(hiT))
        ri += 1
        int tT=array.get(ndTot,0)
        int kT=array.get(ndTot,1)
        string thinT=tT<5?"·":str.tostring(array.get(ndHit,0)*100.0/tT,"0")+"%"
        string thickT=kT<5?"·":str.tostring(array.get(ndHit,1)*100.0/kT,"0")+"%"
        string favTxt=densAdapt?(densFavorThin?"favor thin":"favor thick"):"fixed thin"
        f_row(T, ri, "Thin/Thick FT", thinT+" / "+thickT, cStrong, favTxt+" · n "+str.tostring(tT)+"/"+str.tostring(kT))
        ri += 1
        [clo0,chi0]=f_propCI(h0,t0)
        [clo1,chi1]=f_propCI(h1,t1)
        string ci0=na(clo0)?"–":str.tostring(math.round(clo0*100))+"–"+str.tostring(math.round(chi0*100))
        string ci1=na(clo1)?"–":str.tostring(math.round(clo1*100))+"–"+str.tostring(math.round(chi1*100))
        f_row(T, ri, "95% CI off/on", ci0+" / "+ci1+"%", cStrong, "follow-through band")
        ri += 1
        int br0=array.get(breaksN,0)
        int br1=array.get(breaksN,1)
        int wp0=array.get(whipN,0)
        int wp1=array.get(whipN,1)
        string wpTxt=(br0>0?str.tostring(wp0*100.0/br0,"0"):"–")+" / "+(br1>0?str.tostring(wp1*100.0/br1,"0")+"%":"–")
        f_row(T, ri, "Whip% off/on", wpTxt, cStrong, "lower is better")
        ri += 1
        string ouTxt=na(ouHL)?"non-revert":str.tostring(ouHL,"0.0")+"b"
        f_row(T, ri, "OU half-life", ouTxt, ouSlow?cBear:cBull, ouSlow?"> horizon "+str.tostring(horizon)+" (ride)":"≤ horizon (can revert)")
        ri += 1
        color mtfCol=mtfBull>=5?cBull:mtfBull<=1?cBear:cMut
        f_row(T, ri, "MTF trend", str.tostring(mtfBull)+"/6 up", mtfCol, mtfBull>=5?"HTF up · short=ride":mtfBull<=1?"HTF down · long=ride":"mixed")
        ri += 1
        f_row(T, ri, "Decorr ρ̄", str.tostring(rhoBar,"0.00"), cStrong, "×"+str.tostring(famShrink,"0.00")+" shrink · stretch "+str.tostring(z,"0.00")+"σ")
        ri += 1
        string tU=(rejUpper?"R":"·")+(recentDivU?"D":"·")+(freshSweepHi?"S":"·")+(favU?"M":"·")
        string tL=(rejLower?"R":"·")+(recentDivL?"D":"·")+(freshSweepLo?"S":"·")+(favL?"M":"·")
        f_row(T, ri, "Tells U/L", tU+" / "+tL, cStrong, "R·D·S·dens")
        ri += 1
        f_row(T, ri, "Frame", "macro "+str.tostring(macroBars)+"b d"+str.tostring(macroDeg)+" · "+anchorMode, cStrong, syminfo.ticker)
        ri += 1

// ───────────────────────────── MTF S/R LINES ───────────────────────────
// (MTF supertrend values mV*/dirs mD* + consensus mtfBull are computed earlier,
//  right after the regime gate, so the ride-risk score can use the consensus.)
var line mLn1=na
var line mLn2=na
var line mLn3=na
var line mLn4=na
var line mLn5=na
var line mLn6=na
var label mLb1=na
var label mLb2=na
var label mLb3=na
var label mLb4=na
var label mLb5=na
var label mLb6=na
f_srDraw(line ln, label lb, int xL, int xR, float lvl, bool up, string tf, bool lab, int w) =>
    line.delete(ln)
    label.delete(lb)
    line nl=na
    label nb=na
    if not na(lvl)
        col = up ? mtfColUp : mtfColDn
        nl := line.new(xL, lvl, xR, lvl, xloc=xloc.bar_index, color=color.new(col,0), width=w)
        if lab
            nb := label.new(xR, lvl, tf+" "+(up?"sup":"res"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(col,12), textcolor=color.white, size=size.small)
    [nl, nb]
if useMtfSR and barstate.islast
    int xL = bar_index - 1
    int xR = bar_index + 8
    [a1,c1] = f_srDraw(mLn1,mLb1,xL,xR,mV1,mD1<0,mtfTf1,mtfLab,1)
    [a2,c2] = f_srDraw(mLn2,mLb2,xL,xR,mV2,mD2<0,mtfTf2,mtfLab,1)
    [a3,c3] = f_srDraw(mLn3,mLb3,xL,xR,mV3,mD3<0,mtfTf3,mtfLab,2)
    [a4,c4] = f_srDraw(mLn4,mLb4,xL,xR,mV4,mD4<0,mtfTf4,mtfLab,2)
    [a5,c5] = f_srDraw(mLn5,mLb5,xL,xR,mV5,mD5<0,mtfTf5,mtfLab,3)
    [a6,c6] = f_srDraw(mLn6,mLb6,xL,xR,mV6,mD6<0,mtfTf6,mtfLab,3)
    mLn1:=a1
    mLn2:=a2
    mLn3:=a3
    mLn4:=a4
    mLn5:=a5
    mLn6:=a6
    mLb1:=c1
    mLb2:=c2
    mLb3:=c3
    mLb4:=c4
    mLb5:=c5
    mLb6:=c6

// ───────────────────────────── ALERTS ──────────────────────────────────
alertcondition(shortGated, "Fade SHORT (gated)", "AVRC: gated fade short — outer band tagged, tell present, regime reverting.")
alertcondition(longGated,  "Fade LONG (gated)",  "AVRC: gated fade long — outer band tagged, tell present, regime reverting.")
alertcondition(shortGated and thinU, "Fade SHORT in THIN node", "AVRC: high-quality short fade into a thin macro volume node.")
alertcondition(longGated and thinL,  "Fade LONG in THIN node",  "AVRC: high-quality long fade into a thin macro volume node.")
alertcondition(bearDiv, "Bearish divergence at band", "AVRC: momentum divergence at upper band.")
alertcondition(bullDiv, "Bullish divergence at band", "AVRC: momentum divergence at lower band.")
````
