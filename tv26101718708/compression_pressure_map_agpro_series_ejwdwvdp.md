# Compression Pressure Map [AGPro Series]

- url: https://www.tradingview.com/script/EJWdWvDp-Compression-Pressure-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;60e6a41d3e6144fbbdaa396b5eae0154
- version: 4.0

## Description

Compression Pressure Map [AGPro Series]

⚡ Overview
────────────────────────────────────────
Compression Pressure Map is a structural context tool that measures how tightly price is compressing against the nearest pivot-based level, and evaluates two behavioral scenarios in parallel: breakout anticipation and reversal watch. The output is a visual map of where pressure is accumulating — rendered as an evolving pressure zone that moves through BUILDING, ARMED and READY states.

This is not a signal engine, not a forecast, and not a trading strategy. It is a visualization layer that answers a single question: where is compression building around the active level, and in which direction is that pressure leaning.


🧭 Unique Edge
────────────────────────────────────────
Most compression indicators reduce behavior to a single direction. CPM separates compression into two parallel scoring engines that run on the same structural core:

🔹 Breakout Anticipation — pressure building for a directional break through the level
🔹 Reversal Watch — pressure building for a rejection at the level

In Auto mode the dominant scenario is rendered on the chart (cleaner visual), while the panel shows both scores side by side for transparency. Power users can lock the engine to a single mode. The active level is stabilized with a clustered pivot refinement and a drift-control lock, so the displayed level stays consistent instead of jumping on every new pivot. A compression gate keeps the pressure score aligned with the compression core: when compression is weak, pressure cannot escalate into high states.


🧪 Methodology
────────────────────────────────────────
The pressure score is a weighted composite of six structural components, measured on the active scenario:

🔹 Range compression (short-window range vs long-window range)
🔹 ATR compression (short-window ATR vs long-window ATR)
🔹 Body tightness (average body size relative to average range)
🔹 Quiet-bar persistence (how many recent bars qualify as calm)
🔹 Proximity to the active level (normalized by ATR)
🔹 Directional posture (slope, close position in bar)

Reversal scoring adds wick-rejection weight at the active level (average lower-wick size for bull reversals, upper-wick size for bear reversals). Breakout scoring adds approach slope weight toward the active level. A shared EMA smoothing step produces calmer state transitions. A dominance margin and cooldown prevent rapid scenario flipping. The final score is driven through a BUILDING → ARMED → READY state machine with hysteresis on the zone visibility to avoid flicker.


🎯 Signals & Alerts
────────────────────────────────────────
The state machine produces four transition alerts plus two pace alerts:

🔹 Pressure Armed Near Level — score crosses the armed threshold with an active scenario
🔹 Ready Zone Reached — score crosses the ready threshold with an active scenario
🔹 Armed Bullish / Bearish Scenario — directional armed transitions
🔹 Ready Bullish / Bearish Scenario — directional ready transitions
🔹 Pressure Rising — score is climbing while the zone is live
🔹 Pressure Released — the active scenario resolves (through the level or by decay)

On the chart, state transitions are marked with discrete A and R markers on the active side. A score label near price always shows the current pressure value, bias and state for quick reading without opening the panel.


⚙️ Key Inputs
────────────────────────────────────────
🔹 Engine Mode — Auto, Breakout Anticipation, or Reversal Watch
🔹 Compression Length — main lookback for range, ATR and body tightening
🔹 Trigger Distance (ATR) — how close price must be to a level to start evaluating
🔹 Hold Distance (ATR) — how far price can drift before the active context is cleared
🔹 Pivot Left/Right and Cluster Tolerance — pivot strength and blending behavior
🔹 Compression Gate and Gate Threshold — compression-first discipline control
🔹 Armed / Ready / Zone On / Zone Off Thresholds — state machine calibration
🔹 Full visual controls — zone width, band extend, line width, label size, panel position and font

All defaults are tuned for mid-volatility crypto pairs on 1H and 4H timeframes, but the engine adapts across symbols and timeframes through its ATR-normalized distance logic.


📘 How to Use
────────────────────────────────────────
🔹 Open the indicator in Auto mode and observe which scenario the panel highlights
🔹 Wait for the pressure zone to appear on the chart (BUILD → LIVE transition)
🔹 Read the state: BUILDING means the setup is forming, ARMED means the setup is mature, READY means compression and proximity are both at peak
🔹 Cross-reference with your own structural read — CPM describes the compression landscape, the decision is yours
🔹 If you prefer one behavioral lens only, lock the engine to Breakout Anticipation or Reversal Watch
🔹 Use the Compression Gate to enforce compression-first discipline — when compression is weak, the pressure score stays in WATCH
🔹 The tool is timeframe-agnostic; try it on 15m, 1H, 4H and 1D to see how compression contexts nest

CPM is designed to sit alongside your strategy, not replace it. It maps the compression field; you read the context.


⚠️ Limitations & Transparency
────────────────────────────────────────
🔹 CPM is a context visualization tool, not a signal generator — it does not issue buy or sell calls
🔹 The pressure score is a structural measurement, not a probability estimate
🔹 State transitions describe the compression field at the moment they print; they do not imply what happens next
🔹 Active level refinement is intentionally conservative — the level may feel slower to update than raw pivots, by design
🔹 Very high volatility regimes may keep the compression score low for extended periods, which is the intended behavior
🔹 The tool is deterministic on closed bars; intrabar values are provisional until bar close

CPM is released as Public, Open-source under MPL 2.0. The source is fully readable and auditable.


🛡️ Risk Disclosure
────────────────────────────────────────
This indicator is published for educational and analytical purposes only. It is not financial advice, not a trading strategy, and not a recommendation to buy or sell any asset. Past behavior of any level or pressure state does not predict future behavior. Markets carry risk of loss; users are solely responsible for their own decisions and risk management. Always do your own research and consider consulting a qualified professional before making trading or investment decisions.

## Source Code

````pine
// -----------------------------------------------------
// Compression Pressure Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 3.6
//
// Measures compression pressure around the nearest pivot-based support or
// resistance level. The engine compares breakout anticipation and reversal
// watch scenarios, then maps the dominant pressure context with a live band,
// centered contest badge, deduplicated owned state lanes, a level-role tag, a
// stop-aware pressure follow-through rate, and a compact AGPro decision panel.
// It is a compression context map, not a forecast or trading strategy.
// -----------------------------------------------------

//@version=6
indicator("Compression Pressure Map [AGPro Series]",
     shorttitle = "AG Pro CPM",
     overlay = true,
     max_labels_count = 40,
     max_lines_count = 40,
     max_boxes_count = 10)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
gEngine = "Engine Mode"
gCore = "Core"
gLevel = "Levels"
gPivot = "Pivot Levels"
gState = "State Logic"
gGate = "Compression Gate"
gVisual = "Visuals"
gPanel = "Panel"
gAlerts = "Thresholds"

engineMode = input.string("Auto", "Engine Mode",
     options = ["Auto", "Breakout Anticipation", "Reversal Watch"],
     group = gEngine,
     tooltip = "Auto evaluates breakout and reversal scenarios in parallel. Breakout Anticipation focuses on pressure before a level break. Reversal Watch focuses on pressure before a rejection.")

compressionLen = input.int(12, "Compression Length", minval = 5, maxval = 80, group = gCore,
     tooltip = "Main lookback used to evaluate range contraction, body tightness, quiet-bar persistence, and pressure behavior.")
scoreSmoothLen = input.int(4, "Score Smoothing", minval = 1, maxval = 20, group = gCore,
     tooltip = "EMA smoothing applied to the pressure score. Higher values produce calmer state changes.")
quietFactor = input.float(0.90, "Quiet Bar Factor", minval = 0.50, maxval = 1.30, step = 0.05, group = gCore,
     tooltip = "Controls how strict the quiet-bar persistence test is. Lower values require tighter candles.")

levelLookback = input.int(80, "Fallback Lookback", minval = 20, maxval = 400, group = gLevel,
     tooltip = "Fallback support/resistance window used when a recent pivot cluster is unavailable.")
nearLevelATR = input.float(0.40, "Trigger Distance (ATR)", minval = 0.05, maxval = 3.00, step = 0.05, group = gLevel,
     tooltip = "How close price must be to a level before a pressure context can become active.")
holdLevelATR = input.float(0.90, "Hold Distance (ATR)", minval = 0.10, maxval = 5.00, step = 0.05, group = gLevel,
     tooltip = "How far price may drift while keeping the active pressure context alive.")
touchATR = input.float(0.20, "Touch Threshold (ATR)", minval = 0.05, maxval = 2.00, step = 0.05, group = gLevel,
     tooltip = "ATR distance used to classify level touches.")
contextBars = input.int(20, "Context Memory Bars", minval = 4, maxval = 200, group = gLevel,
     tooltip = "Grace period allowed after a stale context also moves beyond the Hold Distance. Fresh dominant interactions reset the stale counter; proximity inside the hold area keeps the level context valid.")

pivotLen = input.int(3, "Pivot Left/Right", minval = 1, maxval = 20, group = gPivot,
     tooltip = "Pivot strength used to build support and resistance clusters.")
preferPivots = input.bool(true, "Prefer Recent Pivot Levels", group = gPivot,
     tooltip = "Uses recent pivot clusters first, then falls back to lookback highs and lows.")
clusterATR = input.float(0.35, "Pivot Cluster Tolerance (ATR)", minval = 0.05, maxval = 2.00, step = 0.05, group = gPivot,
     tooltip = "Nearby pivots within this ATR distance are blended into one cleaner active level.")

dominanceMargin = input.float(10.0, "Scenario Dominance Margin", minval = 0.0, maxval = 40.0, step = 0.5, group = gState,
     tooltip = "The winning scenario must exceed the runner-up by this margin before becoming dominant.")
flipCooldownBars = input.int(8, "Scenario Flip Cooldown Bars", minval = 0, maxval = 80, group = gState,
     tooltip = "Prevents rapid scenario switching when breakout and reversal context are close.")
minBiasScore = input.float(24.0, "Minimum Candidate Score", minval = 0.0, maxval = 90.0, step = 0.5, group = gState,
     tooltip = "Weak scenario candidates remain neutral instead of forcing a pressure bias.")
minMapBars = input.int(3, "Minimum Bars Before Live", minval = 1, maxval = 20, group = gState,
     tooltip = "Minimum confirmed context age required before the pressure ribbon can progress from Build to Live.")

armedThreshold = input.float(60.0, "Armed Threshold", minval = 0, maxval = 100, step = 0.5, group = gAlerts,
     tooltip = "Pressure score needed to move from Building to Armed. Invalid threshold ordering is normalized internally without changing valid settings.")
readyThreshold = input.float(75.0, "Primed Threshold", minval = 0, maxval = 100, step = 0.5, group = gAlerts,
     tooltip = "Pressure score needed to classify the active context as Primed. Primed is always normalized above Armed.")
mapOnThreshold = input.float(46.0, "Live State Start Threshold", minval = 0, maxval = 100, step = 0.5, group = gAlerts,
     tooltip = "Pressure score required for the pressure ribbon to progress from Build to Live after the minimum context age. Live Start is normalized above Live Stop.")
mapOffThreshold = input.float(34.0, "Live State Stop Threshold", minval = 0, maxval = 100, step = 0.5, group = gAlerts,
     tooltip = "Pressure score below which the pressure ribbon returns from Live to Build and a resolved context can re-arm. Invalid ordering is normalized internally.")
followWindow = input.int(40, "Release Follow Window", minval = 8, maxval = 300, group = gAlerts,
     tooltip = "Bars allowed for an Armed or Primed context to follow through in its expected direction (counts) or reach the opposite stop (counts as a miss) before timing out uncounted. Used by Pressure FT.")
followTargetAtr = input.float(1.2, "Release Target ATR", minval = 0.2, maxval = 6.0, step = 0.1, group = gAlerts,
     tooltip = "ATR distance price must travel in the expected direction to count as a successful release.")
followStopAtr = input.float(1.2, "Release Stop ATR", minval = 0.2, maxval = 6.0, step = 0.1, group = gAlerts,
     tooltip = "ATR distance price can travel against the expected direction before the sample counts as a miss.")

useCompressionGate = input.bool(true, "Enable Compression Gate", group = gGate,
     tooltip = "Requires compression to reach a minimum level before pressure can progress beyond Gated state.")
gateThreshold = input.float(25.0, "Compression Gate Threshold", minval = 0, maxval = 100, step = 0.5, group = gGate,
     tooltip = "Minimum compression score required to open the pressure gate.")

showOwnedLevel = input.bool(true, "Show Owned Level Rail + Tag", group = gVisual,
     tooltip = "Shows the active-level rail and its filled right-side owner tag as one atomic visual. When no context is active, the same control shows the exact-price watch badge.")
showPressureMap = input.bool(true, "Show Pressure Ribbon + Center Badge", group = gVisual,
     tooltip = "Shows the active pressure ribbon and its filled exact-center contest badge as one atomic visual in both Build and Live phases.")
showScoreLabel = input.bool(false, "Show Score Label", group = gVisual,
     tooltip = "Shows a compact current score badge outside the ribbon. It is automatically suppressed while the centered badge is visible to avoid duplicate context text.")
showStateMarkers = input.bool(true, "Show State Badges", group = gVisual,
     tooltip = "Keeps up to three recent Build, Armed, Primed, or Resolved event badges in owned collision-safe lanes.")
useSmartBadgeLanes = input.bool(true, "Use Smart Badge Lanes", group = gVisual,
     tooltip = "Staggers state badges in three font-aware horizontal and ATR-aware vertical lanes while retaining a connector to each source candle.")
eventLabelOffsetATR = input.float(0.70, "Event Badge Offset (ATR)", minval = 0.20, maxval = 3.00, step = 0.05, group = gVisual,
     tooltip = "Minimum vertical distance between an event badge and its source candle or pressure ribbon.")
maxEventBadges = input.int(3, "Max Event Badges", minval = 3, maxval = 5, group = gVisual,
     tooltip = "Maximum number of recent owned state badges retained on the chart.")
zoneATR = input.float(0.22, "Pressure Zone Width (ATR)", minval = 0.05, maxval = 2.00, step = 0.05, group = gVisual,
     tooltip = "Half-width of the pressure band around the active level.")
bandLeftExtendBars = input.int(24, "Band History Bars", minval = 4, maxval = 160, group = gVisual,
     tooltip = "Maximum number of confirmed active-context bars shown to the left. When the center badge is enabled, visible history is safely capped as needed to keep that exact-center badge beyond current candles.")
bandExtendBars = input.int(28, "Band Right Extend Bars", minval = 4, maxval = 160, group = gVisual,
     tooltip = "How far the pressure band projects to the right of the current bar.")
levelLineWidth = input.int(2, "Level Line Width", minval = 1, maxval = 3, group = gVisual,
     tooltip = "Base width for the owned active-level rail. Build uses a restrained dashed rail; Armed and Primed use progressively stronger solid rails up to three pixels.")
labelSizeStr = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gVisual,
     tooltip = "Controls the size of chart labels and centered zone badges.")

showPanel = input.bool(true, "Show Panel", group = gPanel,
     tooltip = "Shows or hides the AG Pro decision panel. The publication default is visible.")
panelPositionStr = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = gPanel,
     tooltip = "Moves the decision panel to the selected chart location.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = gPanel,
     tooltip = "Switches the panel between two dark premium treatments and a high-contrast light treatment.")
panelFontSizeStr = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gPanel,
     tooltip = "Controls all panel text. Normal is the recommended publication default.")

// Safe effective thresholds preserve all valid user settings while preventing
// contradictory Armed/Primed and Live Start/Stop ordering.
effectiveArmedThreshold = math.min(armedThreshold, 99.5)
effectiveReadyThreshold = math.max(readyThreshold, effectiveArmedThreshold + 0.5)
effectiveMapOnThreshold = math.max(mapOnThreshold, 0.5)
effectiveMapOffThreshold = math.min(mapOffThreshold, effectiveMapOnThreshold - 0.5)

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBorderCol = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
idleColor = color.rgb(100, 116, 139)
inkDark = color.rgb(15, 23, 42)
inkLight = color.rgb(245, 247, 250)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

// Luminance-aware text color: dark ink on bright semantic fills, light ink on
// the darker blue header and dark neutral fills.
f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float lum = 0.299 * r + 0.587 * g + 0.114 * b
    lum > 138 ? inkDark : inkLight

f_norm(float value, float cap) =>
    cap <= 0 ? 0.0 : f_clamp(value / cap * 100.0, 0.0, 100.0)

f_norm_inv(float value, float cap) =>
    cap <= 0 ? 0.0 : f_clamp((1.0 - value / cap) * 100.0, 0.0, 100.0)

f_size(string sizeName) =>
    sizeName == "Tiny" ? size.tiny :
     sizeName == "Small" ? size.small :
     sizeName == "Large" ? size.large :
     sizeName == "Huge" ? size.huge : size.normal

f_font_mult(string sizeName) =>
    sizeName == "Tiny" ? 0.78 :
     sizeName == "Small" ? 0.90 :
     sizeName == "Large" ? 1.28 :
     sizeName == "Huge" ? 1.55 : 1.00

f_lane_x(int lane, string sizeName) =>
    sizeName == "Tiny" ? (lane == 0 ? 2 : lane == 1 ? 4 : 6) :
     sizeName == "Large" ? (lane == 0 ? 4 : lane == 1 ? 7 : 10) :
     sizeName == "Huge" ? (lane == 0 ? 5 : lane == 1 ? 9 : 13) :
     (lane == 0 ? 3 : lane == 1 ? 5 : 7)

f_panel_pos(string posName) =>
    posName == "Top Left" ? position.top_left :
     posName == "Top Center" ? position.top_center :
     posName == "Middle Left" ? position.middle_left :
     posName == "Middle Right" ? position.middle_right :
     posName == "Middle Center" ? position.middle_center :
     posName == "Bottom Left" ? position.bottom_left :
     posName == "Bottom Center" ? position.bottom_center :
     posName == "Bottom Right" ? position.bottom_right : position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_label_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(39, 52, 75) : color.rgb(22, 32, 54)

f_panel_value_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(18, 26, 44)

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorderCol

f_panel_semantic_ink() =>
    panelTheme == "Clean Light" ? inkDark : panelValueCol

f_dir_sign(int code) =>
    code == 1 or code == 2 ? 1 : code == -1 or code == -2 ? -1 : 0

f_is_reversal(int code) =>
    code == 2 or code == -2

f_setup_text(int code) =>
    code == 1 ? "BREAK UP vs RES" :
     code == -1 ? "BREAK DN vs SUP" :
     code == 2 ? "REJECT FROM SUP" :
     code == -2 ? "REJECT FROM RES" : "NEUTRAL"

f_bias_text(int code) =>
    code == 1 ? "BREAK UP" :
     code == -1 ? "BREAK DN" :
     code == 2 ? "REJECT UP" :
     code == -2 ? "REJECT DN" : "NEUTRAL"

f_case_text(int code) =>
    code == 1 or code == -1 ? "BREAK" : code == 2 or code == -2 ? "REJECTION" : "NONE"

f_level_tag(int code) =>
    code == 1 ? "RESISTANCE | BREAK PRESSURE" :
     code == -1 ? "SUPPORT | BREAK PRESSURE" :
     code == 2 ? "SUPPORT | REJECTION PRESSURE" :
     code == -2 ? "RESISTANCE | REJECTION PRESSURE" : "WATCH LEVEL"

f_state_text(float score, bool gated, bool released) =>
    released ? "RESOLVED" :
     gated ? "GATED" :
     score >= effectiveReadyThreshold ? "PRIMED" :
     score >= effectiveArmedThreshold ? "ARMED" :
     score >= 35 ? "BUILDING" : "WATCH"

// -----------------------------------------------------
// Core series
// -----------------------------------------------------
atr = ta.atr(14)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)

shortRange = ta.sma(barRange, compressionLen)
longRange = ta.sma(barRange, compressionLen * 3)
shortATR = ta.sma(atr, compressionLen)
longATR = ta.sma(atr, compressionLen * 3)
shortBody = ta.sma(bodySize, compressionLen)

rangeCompression = na(longRange) or longRange == 0.0 ? 0.0 : f_clamp((1.0 - shortRange / longRange) * 100.0, 0.0, 100.0)
atrCompression = na(longATR) or longATR == 0.0 ? 0.0 : f_clamp((1.0 - shortATR / longATR) * 100.0, 0.0, 100.0)
bodyTightness = na(shortRange) or shortRange == 0.0 ? 0.0 : f_clamp((1.0 - shortBody / shortRange) * 100.0, 0.0, 100.0)
compressionScore = rangeCompression * 0.45 + atrCompression * 0.35 + bodyTightness * 0.20

refRange = ta.sma(barRange, compressionLen * 2)
quietBar = not na(refRange) and barRange <= refRange * quietFactor
persistenceRaw = ta.sma(quietBar ? 1.0 : 0.0, compressionLen) * compressionLen
persistenceScore = f_norm(persistenceRaw, compressionLen)

// -----------------------------------------------------
// Pivot-aware levels
// -----------------------------------------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float clusterRes = na
var float clusterSup = na

if not na(ph)
    resTol = atr * clusterATR
    clusterRes := na(clusterRes) ? ph : math.abs(ph - clusterRes) <= resTol ? (clusterRes * 2.0 + ph) / 3.0 : ph

if not na(pl)
    supTol = atr * clusterATR
    clusterSup := na(clusterSup) ? pl : math.abs(pl - clusterSup) <= supTol ? (clusterSup * 2.0 + pl) / 3.0 : pl

fallbackRes = ta.highest(high, levelLookback)[1]
fallbackSup = ta.lowest(low, levelLookback)[1]
resLevel = preferPivots and not na(clusterRes) ? clusterRes : fallbackRes
supLevel = preferPivots and not na(clusterSup) ? clusterSup : fallbackSup

resDistATR = atr == 0.0 or na(resLevel) ? 10.0 : math.abs(resLevel - close) / atr
supDistATR = atr == 0.0 or na(supLevel) ? 10.0 : math.abs(close - supLevel) / atr
nearResTrigger = not na(resLevel) and resDistATR <= nearLevelATR
nearSupTrigger = not na(supLevel) and supDistATR <= nearLevelATR
watchLevel = na(resLevel) and na(supLevel) ? na : na(resLevel) ? supLevel : na(supLevel) ? resLevel : resDistATR <= supDistATR ? resLevel : supLevel
watchIsRes = na(resLevel) and na(supLevel) ? true : na(resLevel) ? false : na(supLevel) ? true : resDistATR <= supDistATR

// -----------------------------------------------------
// Scenario scoring
// -----------------------------------------------------
slopeRaw = ta.linreg(close, compressionLen, 0) - ta.linreg(close, compressionLen, 1)
slopeATR = atr == 0.0 ? 0.0 : slopeRaw / atr
approachBull = f_clamp(slopeATR * 800.0, 0.0, 100.0)
approachBear = f_clamp(-slopeATR * 800.0, 0.0, 100.0)
closePos = (close - low) / barRange
pushBull = f_clamp(closePos * 100.0, 0.0, 100.0)
pushBear = f_clamp((1.0 - closePos) * 100.0, 0.0, 100.0)

upperWick = math.max(high - math.max(open, close), 0.0)
lowerWick = math.max(math.min(open, close) - low, 0.0)
rejectUpScore = f_clamp(ta.sma(atr == 0.0 ? 0.0 : lowerWick / atr, compressionLen) * 220.0, 0.0, 100.0)
rejectDnScore = f_clamp(ta.sma(atr == 0.0 ? 0.0 : upperWick / atr, compressionLen) * 220.0, 0.0, 100.0)

resTouchNow = not na(resLevel) and math.abs(high - resLevel) <= atr * touchATR
supTouchNow = not na(supLevel) and math.abs(low - supLevel) <= atr * touchATR
maxTouches = math.max(3.0, math.floor(compressionLen * 0.8))
resTouchScore = f_norm(ta.sma(resTouchNow ? 1.0 : 0.0, compressionLen * 2) * compressionLen * 2, maxTouches)
supTouchScore = f_norm(ta.sma(supTouchNow ? 1.0 : 0.0, compressionLen * 2) * compressionLen * 2, maxTouches)

resProxRaw = nearResTrigger ? f_norm_inv(resDistATR, nearLevelATR) : 0.0
supProxRaw = nearSupTrigger ? f_norm_inv(supDistATR, nearLevelATR) : 0.0

breakBullScore = resProxRaw * 0.34 + compressionScore * 0.22 + persistenceScore * 0.14 + approachBull * 0.16 + pushBull * 0.14
breakBearScore = supProxRaw * 0.34 + compressionScore * 0.22 + persistenceScore * 0.14 + approachBear * 0.16 + pushBear * 0.14
revBullScore = supProxRaw * 0.24 + supTouchScore * 0.22 + rejectUpScore * 0.22 + compressionScore * 0.16 + persistenceScore * 0.08 + pushBull * 0.08
revBearScore = resProxRaw * 0.24 + resTouchScore * 0.22 + rejectDnScore * 0.22 + compressionScore * 0.16 + persistenceScore * 0.08 + pushBear * 0.08

isAuto = engineMode == "Auto"
isBreakMode = engineMode == "Breakout Anticipation"
isRevMode = engineMode == "Reversal Watch"

breakBullFinal = (isAuto or isBreakMode) and nearResTrigger ? breakBullScore : 0.0
breakBearFinal = (isAuto or isBreakMode) and nearSupTrigger ? breakBearScore : 0.0
revBullFinal = (isAuto or isRevMode) and nearSupTrigger ? revBullScore : 0.0
revBearFinal = (isAuto or isRevMode) and nearResTrigger ? revBearScore : 0.0

breakBullRaw = isAuto or isBreakMode ? breakBullScore : 0.0
breakBearRaw = isAuto or isBreakMode ? breakBearScore : 0.0
revBullRaw = isAuto or isRevMode ? revBullScore : 0.0
revBearRaw = isAuto or isRevMode ? revBearScore : 0.0

maxScore = math.max(math.max(breakBullFinal, breakBearFinal), math.max(revBullFinal, revBearFinal))
topIsBreakBull = breakBullFinal == maxScore and maxScore > 0.0
topIsBreakBear = breakBearFinal == maxScore and maxScore > 0.0 and not topIsBreakBull
topIsRevBull = revBullFinal == maxScore and maxScore > 0.0 and not topIsBreakBull and not topIsBreakBear
topIsRevBear = revBearFinal == maxScore and maxScore > 0.0 and not topIsBreakBull and not topIsBreakBear and not topIsRevBull
// Exclude only the deterministic winner. Equal leaders therefore remain tied
// through secondScore and cannot pass the dominance margin by accident.
secondScore = topIsBreakBull ? math.max(math.max(breakBearFinal, revBullFinal), revBearFinal) :
     topIsBreakBear ? math.max(math.max(breakBullFinal, revBullFinal), revBearFinal) :
     topIsRevBull ? math.max(math.max(breakBullFinal, breakBearFinal), revBearFinal) :
     topIsRevBear ? math.max(math.max(breakBullFinal, breakBearFinal), revBullFinal) : 0.0
hasDominantWinner = maxScore > secondScore and maxScore - secondScore >= dominanceMargin
candidateCode = maxScore >= minBiasScore and hasDominantWinner ? (topIsBreakBull ? 1 : topIsBreakBear ? -1 : topIsRevBull ? 2 : topIsRevBear ? -2 : 0) : 0
candidateLevel = candidateCode == 1 or candidateCode == -2 ? resLevel : candidateCode == -1 or candidateCode == 2 ? supLevel : na

// -----------------------------------------------------
// State engine
// -----------------------------------------------------
var int activeCode = 0
var float activeLevel = na
var int activeAge = 0
var int staleBars = 0
var int flipCooldown = 0

bool contextStartedNow = false
bool contextRebasedNow = false
bool contextEndedNow = false

if activeCode != 0
    activeAge += 1
    staleBars += 1
if flipCooldown > 0
    flipCooldown -= 1

if activeCode != 0
    activeDistanceNow = na(activeLevel) ? 10.0 : math.abs(close - activeLevel) / safeAtr
    holdOk = not na(activeLevel) and activeDistanceNow <= holdLevelATR
    if not holdOk and staleBars > contextBars
        activeCode := 0
        activeLevel := na
        activeAge := 0
        staleBars := 0
        contextEndedNow := true

if candidateCode != 0
    if activeCode == 0
        activeCode := candidateCode
        activeLevel := candidateLevel
        activeAge := 0
        staleBars := 0
        contextStartedNow := true
    else if candidateCode == activeCode
        staleBars := 0
        refineTol = safeAtr * clusterATR * 0.35
        if not na(candidateLevel)
            if na(activeLevel) or math.abs(candidateLevel - activeLevel) > refineTol
                activeLevel := candidateLevel
                activeAge := 0
                contextRebasedNow := true
            else
                activeLevel := (activeLevel * 4.0 + candidateLevel) / 5.0
    else if flipCooldown == 0
        oldTop = activeCode == 1 ? breakBullFinal : activeCode == -1 ? breakBearFinal : activeCode == 2 ? revBullFinal : activeCode == -2 ? revBearFinal : 0.0
        if maxScore > oldTop + dominanceMargin + 8.0
            activeCode := candidateCode
            activeLevel := candidateLevel
            activeAge := 0
            staleBars := 0
            flipCooldown := flipCooldownBars
            contextStartedNow := true

contextChangedNow = contextStartedNow or contextRebasedNow or contextEndedNow

dirSign = f_dir_sign(activeCode)
isReversalActive = f_is_reversal(activeCode)
levelDistanceATR = activeCode == 0 or na(activeLevel) ? 10.0 : math.abs(close - activeLevel) / safeAtr
proximityScore = activeCode != 0 ? f_norm_inv(levelDistanceATR, holdLevelATR) : 0.0
activeTouch = activeCode == 1 or activeCode == -2 ? math.abs(high - activeLevel) <= safeAtr * touchATR : activeCode == -1 or activeCode == 2 ? math.abs(low - activeLevel) <= safeAtr * touchATR : false
activeTouchAverage = ta.sma(activeTouch ? 1.0 : 0.0, compressionLen * 2)
touchScore = activeCode != 0 ? f_norm(activeTouchAverage * compressionLen * 2, maxTouches) : 0.0
directionalScore = dirSign == 1 ? pushBull : dirSign == -1 ? pushBear : 0.0
approachScore = dirSign == 1 ? approachBull : dirSign == -1 ? approachBear : 0.0
wickScoreActive = activeCode == 2 ? rejectUpScore : activeCode == -2 ? rejectDnScore : 0.0

pressureRaw = proximityScore * 0.24 + compressionScore * 0.24 + persistenceScore * 0.14 + touchScore * 0.14 + directionalScore * 0.10 + (isReversalActive ? wickScoreActive * 0.08 : approachScore * 0.08) + maxScore * 0.06
pressureBase = activeCode != 0 ? pressureRaw : 0.0
emaAlpha = 2.0 / (scoreSmoothLen + 1.0)
var float pressureEma = na
pressureEma := activeCode == 0 ? 0.0 : contextChangedNow or na(pressureEma) ? pressureBase : pressureEma + emaAlpha * (pressureBase - pressureEma)
gateClosed = useCompressionGate and compressionScore < gateThreshold and activeCode != 0
pressureScore = gateClosed ? math.min(pressureEma, math.max(effectiveArmedThreshold - 20.0, 0.0)) : pressureEma

armedNow = pressureScore >= effectiveArmedThreshold and pressureScore < effectiveReadyThreshold and activeCode != 0 and not gateClosed
readyNow = pressureScore >= effectiveReadyThreshold and activeCode != 0 and not gateClosed
qualifiedNow = armedNow or readyNow
sameContextAsPrevious = not contextChangedNow and activeCode != 0 and activeCode == activeCode[1]
qualifiedPrevious = sameContextAsPrevious and pressureScore[1] >= effectiveArmedThreshold and not gateClosed[1]
pressureCooledNow = ta.crossunder(pressureScore, effectiveMapOffThreshold)

// Latch the first confirmed qualified state for the current context. Breakout
// and rejection cases both resolve in their expected directional sign.
var bool qualifiedLatch = false
var bool contextResolved = false
var int qualifiedCode = 0
var int qualifiedDir = 0
var float qualifiedLevel = na
var float qualifiedDistance = na
var int qualifiedBar = na

newQualification = barstate.isconfirmed and qualifiedNow and not qualifiedPrevious and (not contextResolved or contextChangedNow)
bool releasedNow = false
bool qualificationStartNow = false
if barstate.isconfirmed
    if contextChangedNow or activeCode == 0
        qualifiedLatch := false
        contextResolved := false
        qualifiedCode := 0
        qualifiedDir := 0
        qualifiedLevel := na
        qualifiedDistance := na
        qualifiedBar := na
    else if contextResolved and pressureScore < effectiveMapOffThreshold
        contextResolved := false
        qualifiedCode := 0
        qualifiedDir := 0
        qualifiedLevel := na
        qualifiedDistance := na
        qualifiedBar := na
    if newQualification and not qualifiedLatch
        qualifiedLatch := true
        qualificationStartNow := true
        qualifiedCode := activeCode
        qualifiedDir := dirSign
        qualifiedLevel := activeLevel
        qualifiedDistance := safeAtr * touchATR
        qualifiedBar := bar_index
    if qualifiedLatch and not na(qualifiedBar) and bar_index > qualifiedBar
        expectedRelease = qualifiedDir == 1 ? close > qualifiedLevel + qualifiedDistance : qualifiedDir == -1 ? close < qualifiedLevel - qualifiedDistance : false
        if expectedRelease
            releasedNow := true
            qualifiedLatch := false
            contextResolved := true
        else if pressureCooledNow
            qualifiedLatch := false
            qualifiedCode := 0
            qualifiedDir := 0
            qualifiedLevel := na
            qualifiedDistance := na
            qualifiedBar := na

stateText = activeCode == 0 ? "IDLE" : f_state_text(pressureScore, gateClosed, releasedNow or contextResolved)
setupText = stateText == "IDLE" ? "INACTIVE" : f_setup_text(activeCode)
scoreRising = activeCode != 0 and pressureScore > pressureScore[1]

var bool mapLive = false
if activeCode == 0 or contextChangedNow
    mapLive := false
if activeCode != 0
    startMap = pressureScore >= effectiveMapOnThreshold and activeAge >= minMapBars and not gateClosed and not contextResolved
    stopMap = pressureScore < effectiveMapOffThreshold or releasedNow or contextResolved
    mapLive := stopMap ? false : startMap ? true : mapLive

zoneText = stateText == "IDLE" ? "OFF" : mapLive ? "LIVE" : activeCode != 0 ? "BUILD" : "OFF"

var int visualStartBar = na
if activeCode == 0
    visualStartBar := na
else if contextChangedNow or na(visualStartBar)
    visualStartBar := bar_index

displayStartBar = na(visualStartBar) ? bar_index : math.max(0, math.max(visualStartBar, bar_index - bandLeftExtendBars))

// -----------------------------------------------------
// Visuals
// -----------------------------------------------------
activeColor = dirSign == 1 ? bullColor : dirSign == -1 ? bearColor : idleColor
labelSize = f_size(labelSizeStr)
contestIsResistance = activeCode != 0 ? (activeCode == 1 or activeCode == -2) : watchIsRes
contestBreakScore = contestIsResistance ? breakBullRaw : breakBearRaw
contestRejectScore = contestIsResistance ? revBearRaw : revBullRaw
contestBreakSide = contestIsResistance ? "UP" : "DN"
contestRejectSide = contestIsResistance ? "DN" : "UP"
contestLead = contestBreakScore - contestRejectScore
armedBullTrigger = qualificationStartNow and armedNow and dirSign == 1
armedBearTrigger = qualificationStartNow and armedNow and dirSign == -1
readyEntryNow = barstate.isconfirmed and readyNow and not releasedNow and not contextResolved and (not sameContextAsPrevious or not readyNow[1])
readyBullTrigger = readyEntryNow and dirSign == 1
readyBearTrigger = readyEntryNow and dirSign == -1
liveEntryNow = barstate.isconfirmed and mapLive and (contextChangedNow or not mapLive[1])
gatedEntryNow = barstate.isconfirmed and stateText == "GATED" and stateText[1] != "GATED"
contextBuildEntryNow = barstate.isconfirmed and activeCode != 0 and contextStartedNow

// -----------------------------------------------------
// Pressure Follow-Through (stop-aware, confirmed-bar gated, resolve-then-open)
// When a context first reaches Armed or Primed, track whether price follows
// through in the expected direction before reaching the opposite stop. Levels
// are frozen at qualification. Ambiguous same-bar outcomes and timeouts are not
// counted because OHLC data cannot prove their internal event order.
// -----------------------------------------------------
var int releaseWins = 0
var int releaseTotal = 0
var bool releasePending = false
var int releaseDir = 0
var float releaseTarget = na
var float releaseStop = na
var int releaseStartBar = na

if barstate.isconfirmed
    if releasePending
        bool hitTarget = releaseDir == 1 ? high >= releaseTarget : low <= releaseTarget
        bool hitStop = releaseDir == 1 ? low <= releaseStop : high >= releaseStop
        if hitTarget and hitStop
            releasePending := false
        else if hitTarget
            releaseWins += 1
            releaseTotal += 1
            releasePending := false
        else if hitStop
            releaseTotal += 1
            releasePending := false
        else if not na(releaseStartBar) and bar_index - releaseStartBar >= followWindow
            releasePending := false
    if not releasePending and qualificationStartNow
        releaseDir := dirSign
        releaseTarget := releaseDir == 1 ? close + safeAtr * followTargetAtr : close - safeAtr * followTargetAtr
        releaseStop := releaseDir == 1 ? close - safeAtr * followStopAtr : close + safeAtr * followStopAtr
        releaseStartBar := bar_index
        releasePending := true

int releasePct = releaseTotal > 0 ? int(math.round(releaseWins / releaseTotal * 100.0)) : na
bool releaseBuilding = releaseTotal < 6
string releaseText = releaseBuilding ? "Building | n=" + str.tostring(releaseTotal) : str.tostring(releasePct) + "% | n=" + str.tostring(releaseTotal)
color releaseColor = releaseBuilding ? neutralColor : releasePct >= 52 ? bullColor : releasePct >= 44 ? neutralColor : bearColor

bandAlpha = not mapLive ? 87 : readyNow ? 60 : armedNow ? 68 : 76
bandBorderAlpha = not mapLive ? 24 : readyNow ? 0 : armedNow ? 4 : 12
bandMult = isReversalActive ? (readyNow ? 1.20 : armedNow ? 1.05 : 0.92) : (readyNow ? 1.95 : armedNow ? 1.65 : 1.42)

int badgeClearBars = f_lane_x(0, labelSizeStr)
int balancedHistoryCap = math.max(bandExtendBars + 6 - badgeClearBars * 2, 0)
int bandLeft = showPressureMap ? math.max(displayStartBar, bar_index - balancedHistoryCap) : displayStartBar
int bandRight = bar_index + bandExtendBars + 6
float bandTop = not na(activeLevel) ? activeLevel + safeAtr * zoneATR * bandMult : na
float bandBot = not na(activeLevel) ? activeLevel - safeAtr * zoneATR * bandMult : na
bool bandContextVisible = activeCode != 0 and not na(activeLevel) and stateText != "IDLE"
bool bandVisible = showPressureMap and bandContextVisible
bool ownedLevelVisible = showOwnedLevel and bandContextVisible

// Keep only the most recent instance of each case + state + direction event.
// Every filled badge owns one short source-candle connector; badge, connector,
// and event key share one synchronized FIFO for atomic replacement and cleanup.
var array<label> stateBadges = array.new_label()
var array<line> stateConnectors = array.new_line()
var array<string> stateEventKeys = array.new_string()
var int stateEventSequence = 0

recentHigh3 = ta.highest(high, 3)
recentLow3 = ta.lowest(low, 3)
bool stateEventNow = showStateMarkers and (releasedNow or readyEntryNow or armedBullTrigger or armedBearTrigger or gatedEntryNow or liveEntryNow or contextBuildEntryNow)
if stateEventNow
    int eventCode = releasedNow ? qualifiedCode : activeCode
    int eventDir = releasedNow ? qualifiedDir : dirSign
    string eventState = releasedNow ? "RESOLVED" : readyEntryNow ? "PRIMED" : (armedBullTrigger or armedBearTrigger) ? "ARMED" : gatedEntryNow ? "GATED" : liveEntryNow ? "LIVE" : "BUILD"
    string eventText = f_case_text(eventCode) + " " + eventState
    string eventKey = str.tostring(eventCode) + "|" + eventState + "|" + str.tostring(eventDir)
    color eventColor = releasedNow ? accentColor : readyEntryNow ? activeColor : (armedBullTrigger or armedBearTrigger) ? neutralColor : liveEntryNow ? activeColor : accentColor
    int duplicateIndex = na
    if array.size(stateEventKeys) > 0
        for i = 0 to array.size(stateEventKeys) - 1
            if na(duplicateIndex) and array.get(stateEventKeys, i) == eventKey
                duplicateIndex := i
    if not na(duplicateIndex)
        label.delete(array.remove(stateBadges, duplicateIndex))
        line.delete(array.remove(stateConnectors, duplicateIndex))
        array.remove(stateEventKeys, duplicateIndex)
    int lane = stateEventSequence % 3
    int laneX = useSmartBadgeLanes ? f_lane_x(lane, labelSizeStr) : 3
    float laneFactor = useSmartBadgeLanes ? 1.0 + lane * 0.42 : 1.0
    float ownerY = eventDir == 1 ? high : low
    float baseY = eventDir == 1 ? math.max(recentHigh3, nz(bandTop, recentHigh3)) : math.min(recentLow3, nz(bandBot, recentLow3))
    float eventGap = safeAtr * eventLabelOffsetATR * f_font_mult(labelSizeStr) * laneFactor
    float eventY = eventDir == 1 ? baseY + eventGap : baseY - eventGap
    int eventX = bar_index + laneX
    line eventConnector = line.new(bar_index, ownerY, eventX, eventY, xloc = xloc.bar_index, extend = extend.none, color = color.new(eventColor, 38), width = 1)
    label eventBadge = label.new(eventX, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventDir == 1 ? label.style_label_down : label.style_label_up, textcolor = f_text_on(eventColor), color = color.new(eventColor, 0), size = labelSize)
    array.push(stateConnectors, eventConnector)
    array.push(stateBadges, eventBadge)
    array.push(stateEventKeys, eventKey)
    stateEventSequence += 1

while array.size(stateBadges) > (showStateMarkers ? maxEventBadges : 0)
    label.delete(array.shift(stateBadges))
    line.delete(array.shift(stateConnectors))
    array.shift(stateEventKeys)

var box pressureBand = na
var line activeLevelLine = na
var label scoreLabel = na
var label levelTag = na
var label zoneBadge = na

if bandVisible
    if na(pressureBand)
        pressureBand := box.new(bandLeft, bandTop, bandRight, bandBot, xloc = xloc.bar_index, bgcolor = color.new(activeColor, bandAlpha), border_color = color.new(activeColor, bandBorderAlpha), border_width = 2)
    else
        box.set_lefttop(pressureBand, bandLeft, bandTop)
        box.set_rightbottom(pressureBand, bandRight, bandBot)
        box.set_bgcolor(pressureBand, color.new(activeColor, bandAlpha))
        box.set_border_color(pressureBand, color.new(activeColor, bandBorderAlpha))
        box.set_border_width(pressureBand, 2)
else
    if not na(pressureBand)
        box.delete(pressureBand)
        pressureBand := na

if ownedLevelVisible
    lineWidthNow = readyNow ? math.min(3, levelLineWidth + 1) : armedNow ? math.min(2, levelLineWidth) : 1
    lineStyleNow = readyNow or armedNow ? line.style_solid : line.style_dashed
    if na(activeLevelLine)
        activeLevelLine := line.new(bandLeft, activeLevel, bandRight, activeLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(activeColor, readyNow ? 0 : 12), style = lineStyleNow, width = lineWidthNow)
    else
        line.set_xy1(activeLevelLine, bandLeft, activeLevel)
        line.set_xy2(activeLevelLine, bandRight, activeLevel)
        line.set_color(activeLevelLine, color.new(activeColor, readyNow ? 0 : 12))
        line.set_style(activeLevelLine, lineStyleNow)
        line.set_width(activeLevelLine, lineWidthNow)
else
    if not na(activeLevelLine)
        line.delete(activeLevelLine)
        activeLevelLine := na

if barstate.islast
    activeLead = f_is_reversal(activeCode) ? -contestLead : contestLead
    leadText = math.abs(activeLead) < 0.5 ? "TIED 0" : activeLead > 0 ? "LEADS +" + str.tostring(math.round(activeLead)) : "HELD " + str.tostring(math.round(activeLead))
    badgeBg = stateText == "PRIMED" ? activeColor : stateText == "ARMED" ? neutralColor : stateText == "RESOLVED" ? accentColor : accentColor
    bool centeredBadgeVisible = bandVisible

    if centeredBadgeVisible
        badgeX = int(math.round((bandLeft + bandRight) * 0.5))
        badgeY = (bandTop + bandBot) * 0.5
        badgeText = f_case_text(activeCode) + " " + leadText + " | CP " + str.tostring(math.round(pressureScore)) + " | " + stateText
        if na(zoneBadge)
            zoneBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(badgeBg), color = color.new(badgeBg, 0), size = labelSize)
        else
            label.set_xy(zoneBadge, badgeX, badgeY)
            label.set_text(zoneBadge, badgeText)
            label.set_textcolor(zoneBadge, f_text_on(badgeBg))
            label.set_color(zoneBadge, color.new(badgeBg, 0))
            label.set_size(zoneBadge, labelSize)
    else if not na(zoneBadge)
        label.delete(zoneBadge)
        zoneBadge := na

    bool scoreBadgeVisible = showScoreLabel and bandContextVisible and not centeredBadgeVisible
    if scoreBadgeVisible
        scoreBg = stateText == "PRIMED" ? activeColor : stateText == "ARMED" ? neutralColor : stateText == "RESOLVED" ? accentColor : accentColor
        scoreGap = safeAtr * (1.15 + 0.45 * f_font_mult(labelSizeStr))
        scoreY = dirSign == 1 ? recentHigh3 + scoreGap : recentLow3 - scoreGap
        scoreStyle = dirSign == 1 ? label.style_label_down : label.style_label_up
        scoreText = "CP " + str.tostring(math.round(pressureScore)) + " | " + f_bias_text(activeCode) + " | " + stateText
        if na(scoreLabel)
            scoreLabel := label.new(bar_index + 1, scoreY, scoreText, xloc = xloc.bar_index, yloc = yloc.price, style = scoreStyle, textcolor = f_text_on(scoreBg), color = color.new(scoreBg, 0), size = labelSize)
        else
            label.set_xy(scoreLabel, bar_index + 1, scoreY)
            label.set_text(scoreLabel, scoreText)
            label.set_style(scoreLabel, scoreStyle)
            label.set_textcolor(scoreLabel, f_text_on(scoreBg))
            label.set_color(scoreLabel, color.new(scoreBg, 0))
            label.set_size(scoreLabel, labelSize)
    else if not na(scoreLabel)
        label.delete(scoreLabel)
        scoreLabel := na

    bool activeTagVisible = showOwnedLevel and bandContextVisible
    bool watchTagVisible = showOwnedLevel and not activeTagVisible and not na(watchLevel)
    if activeTagVisible
        if na(levelTag)
            levelTag := label.new(bandRight, activeLevel, f_level_tag(activeCode), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(activeColor), color = color.new(activeColor, 0), size = labelSize)
        else
            label.set_xy(levelTag, bandRight, activeLevel)
            label.set_text(levelTag, f_level_tag(activeCode))
            label.set_style(levelTag, label.style_label_left)
            label.set_textcolor(levelTag, f_text_on(activeColor))
            label.set_color(levelTag, color.new(activeColor, 0))
            label.set_size(levelTag, labelSize)
    else if watchTagVisible
        watchText = watchIsRes ? "WATCH RESISTANCE" : "WATCH SUPPORT"
        watchBaseCol = watchIsRes ? bearColor : bullColor
        if na(levelTag)
            levelTag := label.new(bar_index + 1, watchLevel, watchText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(watchBaseCol), color = color.new(watchBaseCol, 0), size = labelSize)
        else
            label.set_xy(levelTag, bar_index + 1, watchLevel)
            label.set_text(levelTag, watchText)
            label.set_style(levelTag, label.style_label_left)
            label.set_textcolor(levelTag, f_text_on(watchBaseCol))
            label.set_color(levelTag, color.new(watchBaseCol, 0))
            label.set_size(levelTag, labelSize)
    else if not na(levelTag)
        label.delete(levelTag)
        levelTag := na

// -----------------------------------------------------
// Panel
// -----------------------------------------------------
var table panel = na
panelTextSize = f_size(panelFontSizeStr)
caseLeadText = isBreakMode ? "BREAK MODE" : isRevMode ? "REJECT MODE" : math.abs(contestLead) < 0.5 ? "TIED 0" : contestLead > 0 ? "BREAK +" + str.tostring(math.round(contestLead)) : "REJECT +" + str.tostring(math.round(math.abs(contestLead)))
breakCaseText = isRevMode ? "OFF" : str.tostring(math.round(contestBreakScore)) + " " + contestBreakSide
rejectCaseText = isBreakMode ? "OFF" : str.tostring(math.round(contestRejectScore)) + " " + contestRejectSide
gateText = not useCompressionGate ? "OFF" : activeCode == 0 ? "STANDBY" : gateClosed ? "BLOCK" : "OPEN"
focusText = stateText == "PRIMED" ? "WATCH REACTION" :
     stateText == "ARMED" ? "WATCH LEVEL" :
     stateText == "RESOLVED" ? "REVIEW MOVE" :
     stateText == "BUILDING" ? "TRACK LEAD" :
     stateText == "GATED" ? "WAIT FOR GATE" : "STAND ASIDE"
focusColor = stateText == "PRIMED" ? activeColor : stateText == "ARMED" ? neutralColor : stateText == "RESOLVED" ? accentColor : (stateText == "BUILDING" or stateText == "GATED") ? accentColor : idleColor

if barstate.islast
    if showPanel
        if na(panel)
            panel := table.new(f_panel_pos(panelPositionStr), 4, 7, border_width = 1, border_color = f_panel_border(), frame_color = f_panel_border(), frame_width = 1, bgcolor = f_panel_bg())
            table.cell(panel, 0, 0, "", bgcolor = headerBg)
            table.cell(panel, 1, 0, "", bgcolor = headerBg)
            table.cell(panel, 2, 0, "", bgcolor = headerBg)
            table.cell(panel, 3, 0, "", bgcolor = headerBg)
            table.merge_cells(panel, 0, 0, 3, 0)
        table.set_position(panel, f_panel_pos(panelPositionStr))
        table.set_border_color(panel, f_panel_border())
        table.set_frame_color(panel, f_panel_border())
        table.set_bgcolor(panel, f_panel_bg())
        table.cell(panel, 0, 0, "AG Pro Compression Pressure Map", text_color = headerText, bgcolor = headerBg, text_halign = text.align_center, text_size = panelTextSize)

        stateBg = stateText == "PRIMED" ? color.new(activeColor, 68) : stateText == "ARMED" ? color.new(neutralColor, 72) : (stateText == "BUILDING" or stateText == "GATED") ? color.new(accentColor, 80) : stateText == "RESOLVED" ? color.new(accentColor, 70) : f_panel_value_bg()
        pressureBg = activeCode == 0 ? f_panel_value_bg() : pressureScore >= effectiveReadyThreshold ? color.new(activeColor, 70) : pressureScore >= effectiveArmedThreshold ? color.new(neutralColor, 74) : color.new(accentColor, 84)
        gateBg = activeCode == 0 or not useCompressionGate ? f_panel_value_bg() : gateClosed ? color.new(neutralColor, 76) : color.new(bullColor, 80)
        zoneBg = mapLive ? color.new(activeColor, 80) : activeCode != 0 ? color.new(accentColor, 84) : f_panel_value_bg()
        leadBg = activeCode != 0 ? color.new(accentColor, 80) : f_panel_value_bg()
        releaseBg = color.new(releaseColor, 86)
        focusBg = activeCode != 0 ? color.new(focusColor, 80) : f_panel_value_bg()

        table.cell(panel, 0, 1, "State", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 1, 1, stateText, text_color = activeCode != 0 ? f_panel_semantic_ink() : f_panel_value(), bgcolor = stateBg, text_halign = text.align_center, text_size = panelTextSize)
        table.cell(panel, 2, 1, "Pressure", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 3, 1, str.tostring(math.round(nz(pressureScore, 0))), text_color = activeCode != 0 ? f_panel_semantic_ink() : f_panel_value(), bgcolor = pressureBg, text_halign = text.align_center, text_size = panelTextSize)

        table.cell(panel, 0, 2, "Setup", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 1, 2, setupText, text_color = f_panel_value(), bgcolor = f_panel_value_bg(), text_halign = text.align_center, text_size = panelTextSize)
        table.cell(panel, 2, 2, "Level", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 3, 2, na(activeLevel) ? "-" : str.tostring(activeLevel, format.mintick), text_color = f_panel_value(), bgcolor = f_panel_value_bg(), text_halign = text.align_center, text_size = panelTextSize)

        table.cell(panel, 0, 3, "Compression", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 1, 3, str.tostring(math.round(compressionScore)), text_color = f_panel_value(), bgcolor = f_panel_value_bg(), text_halign = text.align_center, text_size = panelTextSize)
        table.cell(panel, 2, 3, "Gate", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 3, 3, gateText, text_color = activeCode != 0 and useCompressionGate ? f_panel_semantic_ink() : f_panel_value(), bgcolor = gateBg, text_halign = text.align_center, text_size = panelTextSize)

        table.cell(panel, 0, 4, "Breakout", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 1, 4, breakCaseText, text_color = f_panel_value(), bgcolor = f_panel_value_bg(), text_halign = text.align_center, text_size = panelTextSize)
        table.cell(panel, 2, 4, "Rejection", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 3, 4, rejectCaseText, text_color = f_panel_value(), bgcolor = f_panel_value_bg(), text_halign = text.align_center, text_size = panelTextSize)

        table.cell(panel, 0, 5, "Lead", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 1, 5, caseLeadText, text_color = activeCode != 0 ? f_panel_semantic_ink() : f_panel_value(), bgcolor = leadBg, text_halign = text.align_center, text_size = panelTextSize)
        table.cell(panel, 2, 5, "Zone", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 3, 5, zoneText, text_color = activeCode != 0 ? f_panel_semantic_ink() : f_panel_value(), bgcolor = zoneBg, text_halign = text.align_center, text_size = panelTextSize)

        table.cell(panel, 0, 6, "Pressure FT", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 1, 6, releaseText, text_color = f_panel_value(), bgcolor = releaseBg, text_halign = text.align_center, text_size = panelTextSize)
        table.cell(panel, 2, 6, "Focus", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelTextSize)
        table.cell(panel, 3, 6, focusText, text_color = activeCode != 0 ? f_panel_semantic_ink() : f_panel_value(), bgcolor = focusBg, text_halign = text.align_center, text_size = panelTextSize)
    else
        if not na(panel)
            table.delete(panel)
            panel := na

// -----------------------------------------------------
// Alerts
// -----------------------------------------------------
pressureRisingEntry = barstate.isconfirmed and mapLive and scoreRising and not (mapLive[1] and scoreRising[1])
alertcondition(pressureRisingEntry, title = "Pressure Rising", message = "Compression Pressure Map: Confirmed pressure expansion has started.")
alertcondition(armedBullTrigger or armedBearTrigger, title = "Pressure Armed Near Level", message = "Compression Pressure Map: A confirmed scenario has entered Armed state near the active level.")
alertcondition(readyEntryNow, title = "Primed State Reached", message = "Compression Pressure Map: A confirmed scenario has reached Primed state.")
alertcondition(releasedNow, title = "Pressure Resolved", message = "Compression Pressure Map: The qualified pressure context resolved in its expected direction.")
alertcondition(armedBullTrigger, title = "Armed Bullish Scenario", message = "Compression Pressure Map: Bullish scenario armed.")
alertcondition(armedBearTrigger, title = "Armed Bearish Scenario", message = "Compression Pressure Map: Bearish scenario armed.")
alertcondition(readyBullTrigger, title = "Primed Bullish Scenario", message = "Compression Pressure Map: Bullish scenario primed.")
alertcondition(readyBearTrigger, title = "Primed Bearish Scenario", message = "Compression Pressure Map: Bearish scenario primed.")
````
