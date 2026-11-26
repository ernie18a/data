# Daily Institutional Flow + Gamma Setup Board

- url: https://www.tradingview.com/script/MJu62E4e-Daily-Institutional-Flow-Gamma-Setup-Board/
- type: indicator
- pine_id: PUB;155f6ef2b4964b4fafa0558f6772512f
- version: 46.0

## Description

Institutional Flow + Gamma Setup Board

This indicator is a daily institutional setup board designed to convert options flow, gamma exposure levels, technical structure, and market confirmation into a clean execution map for the next trading session.

The script is not a generic buy/sell indicator. It is a structured execution framework built from pre-market or prior-session research. Each mapped ticker contains manually defined institutional levels, including trigger zones, confirmation levels, invalidation levels, hard fails, GEX magnets, GEX air pockets, and target zones.

The indicator uses several live intraday filters to prevent premature entries:

Price vs. VWAP
9 EMA / 21 EMA alignment
Opening range break confirmation
Relative volume filter, optional
Market confirmation from SPY, QQQ, IWM, SMH, and XLE
Regular trading hours logic
Signal cooldown protection

For bullish setups, the indicator looks for price to reclaim the mapped trigger while also holding above VWAP, confirming above the 9 EMA/21 EMA stack, and breaking the opening range if enabled.

For bearish setups, it looks for price to lose the mapped trigger while trading below VWAP, below the EMA stack, and below the opening range if enabled.

Each ticker map includes:

Primary directional bias
Setup grade
Preferred contract or structure
Flow summary
GEX summary
Entry zone
Trigger level
Confirmation level
Invalidation level
Hard invalidation level
Three target zones
Major and minor GEX levels
Manual flow, GEX, technical, and total setup scores

The chart displays mapped levels as labeled horizontal lines. Major levels include triggers, confirmations, invalidations, hard fails, primary targets, flow strikes, and major GEX walls. Minor levels show secondary GEX magnets, nearby gamma pockets, and contextual support/resistance zones. Users can toggle major-only levels, minor labels, all labels, opening range, EMA/VWAP stack, and dashboards.

The main dashboard shows only the active ticker being viewed. It displays the current setup bias, contract reference, trigger, confirmation, invalidation, targets, flow read, GEX read, filter status, opening range status, signal state, and market confirmation.

A separate watchlist dashboard is also included and can be toggled on or off. This acts as the daily mission board, showing the highest-priority setups, triggers, and directional reads for the session.

The indicator supports alerts for:

Long trigger
Long confirmation
Put trigger
Put confirmation
Invalidation
Hard invalidation
Target hits
Mapped level touches

For best use, update the script each trading day with the latest options flow analysis, GEX heatmap levels, technical trigger levels, and ranked watchlist. The structure is designed to be reused daily by updating the ticker maps, index confirmation thresholds, and watchlist dashboard.

This tool is intended for disciplined execution of a pre-built institutional thesis. It is most effective when used after the opening range is set and when VWAP, EMA structure, market confirmation, and price action all align with the mapped levels.

## Source Code

````pine
//@version=6
indicator("Schmidt Capital 7/20 Native Surface Integrity Highlighter Ripster Engine v49.1", overlay = true, max_lines_count = 260, max_labels_count = 300, max_boxes_count = 80, dynamic_requests = true)

// ============================================================================
// SCHMIDT CAPITAL 7/20 NATIVE SURFACE INTEGRITY HIGHLIGHTER RIPSTER ENGINE v49.1
//
// Session thesis:
// - NQ is resilient, but breadth remains fragile and crude-sensitive. SPY, QQQ,
//   IWM and SMH begin below their major repair shelves inside a negative-gamma complex.
// - Primary gates: SPY 750-752, QQQ 708-710, IWM 297, SMH 585 and VIX 19/20.
// - Default scenario: 45% negative-gamma chop, 35% risk-off unwind, 20% repair.
// - Highest-conviction board: IWM and PLTR downside; UNH and RIVN conditional upside;
//   CRWV only through 74.50; IREN below 32.22 or after a failed rebound.
// - Monday 10:00 ET LEI is the scheduled macro checkpoint. Do not add full size
//   immediately before the release; require cross-asset confirmation afterward.
//
// v49.1 architecture:
// - Retains the clean highlighter UI, adaptive Ripster clouds, full trade lifecycle,
//   event-gap remapping, market internals and direction-consistent execution cards.
// - Adds a fail-closed operational integrity gate inspired by the SCX dual-surface work:
//   source MI, effective MI, internals freshness and map freshness are separated.
// - Adds a lightweight TradingView-native dual-surface lens. The structural surface uses
//   VWAP, EMA structure, range acceptance and relative strength; the hedge-pressure
//   surface uses UVOL/DVOL, TICK, VIX1D/VIX9D, VIX and mapped index gates.
// - The native surface is explicitly synthetic. It does not claim live dealer inventory
//   or a complete options chain. Mapped dossier GEX levels remain the primary levels.
// - Adds level-interaction states: approaching, testing, accepted, rejected and flipped.
// - Preserves the native range envelope and surface-state highlighter. Research-only
//   micro/HTF cloud rendering and hidden diagnostic plots are now logic-only to stay
//   safely below TradingView's 64-plot ceiling without reducing signal quality.
// - Futures continue to use actual futures prices and prior-session ranges, not cash levels.
// - Plot-budget repair: 9 plotting calls removed, eliminating roughly 13 compiled plot counts; expected total is approximately 58, leaving material headroom below 64.
// ============================================================================
// ============================================================================

// ============================================================================
// 01 | WORKSPACE AND DISPLAY
// ============================================================================

groupUI = "01 | Workspace and Display"
workspace = input.string("Institutional Clean", "Workspace Preset", options = ["Institutional Clean", "Retail Guided", "Research", "Split-Screen Compact", "Minimal"], group = groupUI)
showDecisionLevels = input.bool(true, "Show Locked Decision Levels", group = groupUI)
showLevelLabels = input.bool(true, "Show Right-Side Level Labels", group = groupUI)
showActionZones = input.bool(true, "Show Locked Action Zones", group = groupUI)
actionZoneMode = input.string("Auto", "Action Zone Display", options = ["Auto", "Long", "Short", "Both", "Off"], group = groupUI)
showOpeningRange = input.bool(true, "Show Opening Range", group = groupUI)
showStratPDLevels = input.bool(true, "Show Prior-Day Strat Triggers", group = groupUI)
showCurrentDashboard = input.bool(true, "Show Current-Ticker Dashboard", group = groupUI)
showDecisionLadder = input.bool(false, "Show Decision Ladder", group = groupUI)
showFocusBoard = input.bool(false, "Show July 20 Focus Board", group = groupUI)
showSignalLabels = input.bool(true, "Show Entry Signal Labels", group = groupUI)
showTargetLabels = input.bool(true, "Show Lifecycle / Target Labels", group = groupUI)
levelVisibilityMode = input.string("1.5 ATR", "Level Visibility Radius", options = ["Adaptive", "1.5 ATR", "2.5 ATR", "5% of Price", "All"], group = groupUI)
showCompletedLevels = input.bool(false, "Keep Completed Targets on Chart", group = groupUI)
showOnlyNextTarget = input.bool(true, "Show Only the Next Unreached Target", group = groupUI)
inactiveSideMode = input.string("Auto", "Two-Way Inactive-Side Display", options = ["Auto", "Show Both", "Hide Inactive"], group = groupUI)
hideBrokenMapLevels = input.bool(true, "Hide Levels When Map Is Broken", group = groupUI)
showCandleBias = input.bool(false, "Color Candles by Institutional Bias", group = groupUI)
levelAnchorBars = input.int(28, "Level Anchor Lookback", minval = 5, maxval = 300, group = groupUI)
levelLabelOffset = input.int(8, "Right-Side Label Offset", minval = 3, maxval = 20, group = groupUI)
zoneOpacity = input.int(86, "Action-Zone Opacity", minval = 65, maxval = 97, group = groupUI)
levelLineWidth = input.int(2, "Major Level Width", minval = 1, maxval = 4, group = groupUI)
currentDashPos = input.string("Top Right", "Current Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = groupUI)
ladderPos = input.string("Bottom Right", "Decision Ladder Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = groupUI)
focusBoardPos = input.string("Bottom Right", "Focus Board Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = groupUI)
autoPreventDashboardOverlap = input.bool(true, "Automatically Prevent Dashboard Overlap", group = groupUI)
textSizeOpt = input.string("Small", "Table Text Size", options = ["Tiny", "Small", "Normal"], group = groupUI)
showSignalHighlighter = input.bool(true, "Highlight Ready / Fired Signal Bars", group = groupUI)
highlightSetupReady = input.bool(true, "Highlight Setup-Ready Bars", group = groupUI)
highlighterOpacity = input.int(84, "Signal Highlighter Opacity", minval = 70, maxval = 96, group = groupUI)
showSignalArrows = input.bool(true, "Show Clear LONG / SHORT Arrows", group = groupUI)
showInternalsBadge = input.bool(true, "Show Market-Internals Pulse in Dashboard", group = groupUI)

// ============================================================================
// 02 | ADAPTIVE RIPSTER CLOUDS
// ============================================================================

groupCloud = "02 | Adaptive Ripster Clouds"
showRipster = input.bool(true, "Show Adaptive Ripster Clouds", group = groupCloud)
useRipsterInSignals = input.bool(true, "Use Ripster Clouds in Signal Logic", group = groupCloud)
showExecutionCloud = input.bool(true, "Show Execution Cloud", group = groupCloud)
showStructureCloud = input.bool(true, "Show Structure Cloud", group = groupCloud)
useHTF2InLogic = input.bool(true, "Use Second HTF Cloud in Logic", group = groupCloud)
showRipsterLines = input.bool(false, "Show EMA Boundary Lines", group = groupCloud)
ripsterSource = input.source(hl2, "Cloud Source", group = groupCloud)
ripsterLens = input.string("Auto by Chart Timeframe", "Cloud Lens", options = ["Auto by Chart Timeframe", "Scalp", "Intraday", "Swing", "Position"], group = groupCloud)
cloudRequirement = input.string("Execution + Structure + HTF", "Signal Cloud Requirement", options = ["Execution Only", "Execution + Structure", "Execution + Structure + HTF"], group = groupCloud)
microOpacity = input.int(87, "Micro Cloud Opacity", minval = 65, maxval = 97, group = groupCloud)
executionOpacity = input.int(78, "Execution Cloud Opacity", minval = 65, maxval = 97, group = groupCloud)
structureOpacity = input.int(93, "Structure Cloud Opacity", minval = 70, maxval = 98, group = groupCloud)
htfOpacity = input.int(94, "HTF Cloud Opacity", minval = 80, maxval = 98, group = groupCloud)
showVWAP = input.bool(true, "Show Session VWAP", group = groupCloud)
vwapWidth = input.int(2, "VWAP Width", minval = 1, maxval = 4, group = groupCloud)

// ============================================================================
// 03 | PRECISION ENTRY ENGINE
// ============================================================================

groupPrecision = "03 | Precision Entry Engine"
entryStrictness = input.string("Institutional", "Entry Strictness", options = ["Balanced", "Institutional", "Elite"], group = groupPrecision)
rthSession = input.session("0930-1600", "Regular Session", group = groupPrecision)
openingRangeMinutes = input.int(15, "Opening Range Minutes", minval = 5, maxval = 60, group = groupPrecision)
acceptanceBars = input.int(2, "Consecutive Acceptance Closes", minval = 1, maxval = 4, group = groupPrecision)
retestWindowBars = input.int(8, "Retest Window Bars", minval = 2, maxval = 30, group = groupPrecision)
failedReclaimWindowBars = input.int(12, "Failed-Reclaim Validity Bars", minval = 3, maxval = 40, group = groupPrecision)
retestToleranceATR = input.float(0.12, "Retest Tolerance (ATR)", minval = 0.02, maxval = 0.50, step = 0.01, group = groupPrecision)
maxChaseATR = input.float(0.45, "Maximum Chase Distance (ATR)", minval = 0.10, maxval = 1.50, step = 0.05, group = groupPrecision)
minimumExpectedR = input.float(1.25, "Minimum Expected R to TP1", minval = 0.50, maxval = 4.00, step = 0.25, group = groupPrecision)
minimumRVOL = input.float(1.10, "Minimum Trigger-Bar RVOL", minval = 0.50, maxval = 4.00, step = 0.05, group = groupPrecision)
minimumRelativeEdge = input.float(0.10, "Minimum Relative Edge (%)", minval = 0.00, maxval = 2.00, step = 0.05, group = groupPrecision)
minimumImpulseClose = input.float(0.65, "Minimum Impulse Close Location", minval = 0.50, maxval = 0.95, step = 0.05, group = groupPrecision)
allowExpansionWithoutRetest = input.bool(true, "Allow High-RVOL Expansion Without Retest", group = groupPrecision)
expansionRVOL = input.float(1.55, "Expansion RVOL Threshold", minval = 1.00, maxval = 5.00, step = 0.05, group = groupPrecision)
oneSignalPerSide = input.bool(true, "One Entry Per Side Per Session", group = groupPrecision)
signalCooldownBars = input.int(6, "Signal Cooldown Bars", minval = 1, maxval = 50, group = groupPrecision)
requireMarketGate = input.bool(true, "Require Index / Sector Gate", group = groupPrecision)
requireRelativeStrength = input.bool(true, "Require Relative Strength / Weakness", group = groupPrecision)
requireVWAP = input.bool(true, "Require VWAP Alignment", group = groupPrecision)
requireExpectedR = input.bool(true, "Require Expected-R Filter", group = groupPrecision)
requireRVOL = input.bool(true, "Require Trigger-Bar RVOL", group = groupPrecision)

// ============================================================================
// 03B | MARKET INTERNALS, RSI AND EMA MOMENTUM
// ============================================================================

groupInternals = "03B | Market Internals and Momentum"
uvolSymbol = input.symbol("USI:UVOL", "NYSE Up Volume Symbol", group = groupInternals)
dvolSymbol = input.symbol("USI:DVOL", "NYSE Down Volume Symbol", group = groupInternals)
tickSymbol = input.symbol("USI:TICK", "NYSE TICK Symbol", group = groupInternals)
vix1dSymbol = input.symbol("CBOE:VIX1D", "1-Day Volatility Symbol", group = groupInternals)
vix9dSymbol = input.symbol("CBOE:VIX9D", "9-Day Volatility Symbol", group = groupInternals)
useInternalsInSignals = input.bool(true, "Use UVOL/DVOL + TICK + Volatility Curve", group = groupInternals)
useRSIInSignals = input.bool(true, "Use Adaptive RSI Momentum Filter", group = groupInternals)
useEMAMomentumInSignals = input.bool(true, "Use Adaptive EMA Momentum Filter", group = groupInternals)
tickSmoothLength = input.int(3, "TICK Smoothing", minval = 1, maxval = 10, group = groupInternals)
bullUpVolumeShare = input.float(0.58, "Bullish Up-Volume Share", minval = 0.50, maxval = 0.80, step = 0.01, group = groupInternals)
bearUpVolumeShare = input.float(0.42, "Bearish Up-Volume Share", minval = 0.20, maxval = 0.50, step = 0.01, group = groupInternals)
bullTickThreshold = input.int(250, "Bullish Smoothed TICK", minval = 0, maxval = 1000, step = 50, group = groupInternals)
bearTickThreshold = input.int(-250, "Bearish Smoothed TICK", minval = -1000, maxval = 0, step = 50, group = groupInternals)
frontVolStressRatio = input.float(1.05, "VIX1D / VIX9D Stress Ratio", minval = 0.90, maxval = 1.50, step = 0.01, group = groupInternals)
rsiLongFloor = input.float(52.0, "RSI Long Momentum Floor", minval = 45.0, maxval = 65.0, step = 0.5, group = groupInternals)
rsiShortCeiling = input.float(48.0, "RSI Short Momentum Ceiling", minval = 35.0, maxval = 55.0, step = 0.5, group = groupInternals)


// ============================================================================
// 03C | OPERATIONAL INTEGRITY AND NATIVE SURFACE
// ============================================================================

groupSurface = "03C | Operational Integrity and Native Surface"
useOperationalIntegrityGate = input.bool(true, "Fail Closed When Operational Integrity Is Low", group = groupSurface)
useSurfaceDirectionGate = input.bool(true, "Require Native Surface Direction Agreement", group = groupSurface)
minimumOperationalIntegrity = input.float(62.0, "Minimum Effective MI / Integrity", minval = 40.0, maxval = 95.0, step = 1.0, group = groupSurface)
maximumInternalsAgeMinutes = input.int(20, "Maximum RTH Internals Age (Minutes)", minval = 5, maxval = 120, group = groupSurface)
surfaceApproachATR = input.float(0.18, "Level Approach Distance (ATR)", minval = 0.05, maxval = 0.60, step = 0.01, group = groupSurface)
surfaceDirectionThreshold = input.float(0.05, "Minimum Native Surface Direction", minval = 0.0, maxval = 0.50, step = 0.01, group = groupSurface)
showSurfaceStateHighlighter = input.bool(true, "Highlight Native Surface Acceleration", group = groupSurface)
showNativeRangeEnvelope = input.bool(false, "Show Native Session Range Envelope", group = groupSurface)
rangeEnvelopeOpacity = input.int(92, "Range Envelope Opacity", minval = 80, maxval = 98, group = groupSurface)

// ============================================================================
// 04 | THE STRAT CONTEXT
// ============================================================================

groupStrat = "04 | The Strat Context"
useStratConfluence = input.bool(true, "Use Strat Direction as Confluence", group = groupStrat)
enableGenericStratMap = input.bool(true, "Enable Generic Strat Map on Unmapped Tickers", group = groupStrat)
genericInsideDayOnly = input.bool(true, "Generic Signals Only After Prior Inside Day", group = groupStrat)

// ============================================================================
// 05 | MACRO, SESSION AND RISK PROTOCOL
// ============================================================================

groupRisk = "05 | July 20 Macro and Risk"
enforceMapDate = input.bool(true, "Disable Signals Outside 7/20 Map Window", group = groupRisk)
signalSessionMode = input.string("RTH Only", "Signal Session", options = ["RTH Only", "Extended + RTH"], group = groupRisk)
useMacroFreeze = input.bool(true, "Block Signals Around Scheduled 10:00 AM LEI", group = groupRisk)
macroFreezeStart = input.int(595, "Macro Freeze Start (Minutes ET)", minval = 540, maxval = 650, group = groupRisk)
macroFreezeEnd = input.int(610, "Macro Freeze End (Minutes ET)", minval = 550, maxval = 690, group = groupRisk)
enableEventGapRemap = input.bool(true, "Auto-Remap Event Gaps from Opening Range", group = groupRisk)
eventGapATRThreshold = input.float(0.65, "Event Gap Threshold (ATR)", minval = 0.25, maxval = 2.50, step = 0.05, group = groupRisk)
eventGapMoveConsumption = input.float(0.50, "Remap When Gap Consumes This Share of TP1 Move", minval = 0.25, maxval = 1.00, step = 0.05, group = groupRisk)
firstThirtyRisk = input.float(0.50, "First 30-Minute Risk Cap", minval = 0.25, maxval = 1.00, step = 0.25, group = groupRisk)
normalRisk = input.float(1.00, "Normal Risk Unit", minval = 0.25, maxval = 1.50, step = 0.25, group = groupRisk)
stressRisk = input.float(0.50, "VIX > 20 / Front-Vol Stress Risk Cap", minval = 0.25, maxval = 1.00, step = 0.25, group = groupRisk)
lateRisk = input.float(0.75, "After 2:00 PM Risk Cap", minval = 0.25, maxval = 1.00, step = 0.25, group = groupRisk)
noNewRiskHour = input.int(15, "No New Entries Hour ET", minval = 14, maxval = 15, group = groupRisk)
noNewRiskMinute = input.int(15, "No New Entries Minute", minval = 0, maxval = 59, group = groupRisk)
maxCorrelatedTechPositions = input.int(2, "Maximum Correlated Technology Positions", minval = 1, maxval = 4, group = groupRisk)

// ============================================================================
// 06 | MANUAL CURRENT-TICKER MAP
// ============================================================================

groupManual = "06 | Manual Current-Ticker Map"
manualMapEnabled = input.bool(false, "Use Manual Map Instead of Dossier Map", group = groupManual)
manualDirection = input.string("Long", "Manual Direction", options = ["Long", "Short", "Two-Way"], group = groupManual)
manualTrigger = input.float(0.0, "Manual Primary Trigger", minval = 0.0, group = groupManual)
manualConfirm = input.float(0.0, "Manual Confirmation", minval = 0.0, group = groupManual)
manualInvalid = input.float(0.0, "Manual Invalidation", minval = 0.0, group = groupManual)
manualHardInvalid = input.float(0.0, "Manual Hard Invalidation", minval = 0.0, group = groupManual)
manualTarget1 = input.float(0.0, "Manual Target 1", minval = 0.0, group = groupManual)
manualTarget2 = input.float(0.0, "Manual Target 2", minval = 0.0, group = groupManual)
manualTarget3 = input.float(0.0, "Manual Target 3", minval = 0.0, group = groupManual)
manualZoneLow = input.float(0.0, "Manual Action-Zone Low", minval = 0.0, group = groupManual)
manualZoneHigh = input.float(0.0, "Manual Action-Zone High", minval = 0.0, group = groupManual)

// ============================================================================
// 07 | ALERTS
// ============================================================================

groupAlerts = "07 | Alerts"
enableDynamicAlerts = input.bool(true, "Enable Dynamic alert() Messages", group = groupAlerts)
enableLevelTouchAlerts = input.bool(false, "Enable Major-Level Touch Alerts", group = groupAlerts)
alertCooldownBars = input.int(3, "Dynamic Alert Cooldown Bars", minval = 1, maxval = 50, group = groupAlerts)

// ============================================================================
// 08 | INSTITUTIONAL COLOR SYSTEM
// ============================================================================

groupColors = "08 | Institutional Color System"
cLong = input.color(color.rgb(0, 190, 135), "Long / Support", group = groupColors)
cShort = input.color(color.rgb(230, 45, 80), "Short / Resistance", group = groupColors)
cTrigger = input.color(color.rgb(0, 135, 255), "Trigger", group = groupColors)
cConfirm = input.color(color.rgb(0, 205, 135), "Confirmation", group = groupColors)
cTarget = input.color(color.rgb(35, 105, 235), "Target", group = groupColors)
cInvalid = input.color(color.rgb(235, 45, 70), "Invalidation", group = groupColors)
cZoneLong = input.color(color.rgb(28, 120, 100), "Long Action Zone", group = groupColors)
cZoneShort = input.color(color.rgb(165, 55, 65), "Short Supply Zone", group = groupColors)
cNeutral = input.color(color.rgb(46, 53, 66), "Neutral", group = groupColors)
cGold = input.color(color.rgb(235, 170, 35), "Institutional Pivot", group = groupColors)
cVwap = input.color(color.rgb(70, 110, 190), "VWAP", group = groupColors)

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

f_tablePos(string p) =>
    p == "Top Left" ? position.top_left : p == "Top Right" ? position.top_right : p == "Bottom Left" ? position.bottom_left : position.bottom_right

f_nextCorner(string p) =>
    p == "Top Left" ? "Top Right" : p == "Top Right" ? "Bottom Right" : p == "Bottom Right" ? "Bottom Left" : "Top Left"

f_resolveCorner(string desired, string used1, string used2) =>
    string resolved = desired
    if resolved == used1 or resolved == used2
        resolved := f_nextCorner(resolved)
    if resolved == used1 or resolved == used2
        resolved := f_nextCorner(resolved)
    if resolved == used1 or resolved == used2
        resolved := f_nextCorner(resolved)
    resolved

f_textSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

f_fmt(float v) =>
    na(v) ? "N/A" : str.tostring(v, format.mintick)

f_safeRet(float current, float previous) =>
    not na(current) and not na(previous) and previous != 0.0 ? (current / previous - 1.0) * 100.0 : 0.0

f_safeDiv(float n, float d) =>
    not na(n) and not na(d) and d != 0.0 ? n / d : na

f_closeLocation() =>
    float span = math.max(high - low, syminfo.mintick)
    (close - low) / span

f_accepted(bool condition, int barsRequired) =>
    int sinceFalse = nz(ta.barssince(not condition), 100000)
    condition and sinceFalse >= barsRequired - 1

f_inBand(float lo, float hi) =>
    not na(lo) and not na(hi) and high >= math.min(lo, hi) and low <= math.max(lo, hi)

f_distance(float a, float b) =>
    na(a) or na(b) ? na : math.abs(a - b)


// SCX-inspired operational-state constants. These are lightweight and do not
// reproduce the separate project's full strike-surface engine.
const int INT_BLOCKED = 0
const int INT_APPROACHING = 1
const int INT_TESTING = 2
const int INT_ACCEPTED = 3
const int INT_REJECTED = 4
const int INT_FLIPPED = 5
const int INT_DORMANT = 6

f_clamp(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(highValue, value))

f_tanh(float value) =>
    2.0 / (1.0 + math.exp(-2.0 * f_clamp(value, -10.0, 10.0))) - 1.0

f_interactionText(int state) =>
    state == INT_APPROACHING ? "APPROACHING" :
     state == INT_TESTING ? "TESTING" :
     state == INT_ACCEPTED ? "ACCEPTED" :
     state == INT_REJECTED ? "REJECTED" :
     state == INT_FLIPPED ? "FLIPPED" :
     state == INT_DORMANT ? "DORMANT" : "BLOCKED"

f_interactionColor(int state) =>
    state == INT_ACCEPTED or state == INT_FLIPPED ? cLong :
     state == INT_REJECTED ? cShort :
     state == INT_APPROACHING or state == INT_TESTING ? cGold : cNeutral

f_levelInteraction(float trigger, bool longSide, bool accepted, bool operational, float approachDistance) =>
    int state = not operational or na(trigger) ? INT_BLOCKED : INT_DORMANT
    if operational and not na(trigger)
        bool testing = high >= trigger and low <= trigger
        bool approaching = math.abs(close - trigger) <= approachDistance
        bool rejected = longSide ? testing and close < trigger and close < open : testing and close > trigger and close > open
        bool flipped = longSide ? close > trigger and close[1] <= trigger : close < trigger and close[1] >= trigger
        state := accepted ? INT_ACCEPTED : flipped ? INT_FLIPPED : rejected ? INT_REJECTED : testing ? INT_TESTING : approaching ? INT_APPROACHING : INT_DORMANT
    state

f_isIndexFamily(string sym) =>
    sym == "SPX" or sym == "SPXW" or sym == "US500" or sym == "SPX500USD" or sym == "SPY" or sym == "QQQ" or sym == "IWM" or sym == "RUT" or sym == "SMH" or sym == "SOX" or sym == "SOXX" or sym == "VIX" or sym == "VIX1!"

f_isFuturesFamily(string sym) =>
    str.contains(sym, "ES") or str.contains(sym, "MES") or str.contains(sym, "NQ") or str.contains(sym, "MNQ") or str.contains(sym, "RTY") or str.contains(sym, "M2K") or str.contains(sym, "YM") or str.contains(sym, "MYM") or str.contains(sym, "CL")

f_rolePriority(string role) =>
    role == "HARD" ? 7 : role == "INVALID" ? 6 : role == "TRIGGER" ? 5 : role == "CONFIRM" ? 4 : role == "WALL" ? 3 : role == "TARGET" ? 2 : 1

f_roleColor(string role, bool longSide) =>
    role == "HARD" or role == "INVALID" ? cInvalid : role == "TRIGGER" ? cTrigger : role == "CONFIRM" ? cConfirm : role == "TARGET" ? cTarget : role == "WALL" ? cGold : longSide ? cLong : cShort

f_roleStyle(string role) =>
    role == "TRIGGER" or role == "CONFIRM" ? line.style_solid : role == "INVALID" or role == "HARD" ? line.style_solid : line.style_dashed

// ============================================================================
// SESSION, DAILY CONTEXT AND MARKET DATA
// ============================================================================

bool inRTH = not na(time(timeframe.period, rthSession))
bool newRTH = inRTH and not inRTH[1]
bool newCalendarDay = ta.change(time("D")) != 0
int etHour = hour(time, "America/New_York")
int etMinute = minute(time, "America/New_York")
int minuteOfDayET = etHour * 60 + etMinute
int minutesFromOpen = minuteOfDayET - 570
bool openingFreeze = inRTH and minutesFromOpen >= 0 and minutesFromOpen < openingRangeMinutes
bool firstThirty = inRTH and minutesFromOpen >= 0 and minutesFromOpen < 30
bool macroFreeze = useMacroFreeze and minuteOfDayET >= macroFreezeStart and minuteOfDayET < macroFreezeEnd
bool mandatoryRefreshWindow = not inRTH and minuteOfDayET >= 500 and minuteOfDayET <= 555
bool lateRiskWindow = inRTH and minuteOfDayET >= 840
bool noNewRisk = inRTH and minuteOfDayET >= noNewRiskHour * 60 + noNewRiskMinute
bool extendedEligible = signalSessionMode == "Extended + RTH" and (f_isFuturesFamily(str.upper(syminfo.ticker)) or f_isIndexFamily(str.upper(syminfo.ticker)))
bool preOpenExtended = extendedEligible and not inRTH and minuteOfDayET >= 555 and minuteOfDayET < 570

int mapStart = timestamp("America/New_York", 2026, 7, 19, 18, 0)
int mapEnd = timestamp("America/New_York", 2026, 7, 21, 0, 0)
bool mapFresh = not enforceMapDate or (time >= mapStart and time < mapEnd)

[dHigh, dLow, pdh, pdl, pdh2, pdl2, pdc, pdc2, dOpen, dAtr] = request.security(syminfo.tickerid, "D", [high, low, high[1], low[1], high[2], low[2], close[1], close[2], open, ta.atr(14)], ignore_invalid_symbol = true)
float atr = ta.atr(14)
float dailyAtr = nz(dAtr, atr)
float vwapValue = ta.vwap(hlc3)
float volumeAverage = ta.sma(volume, 20)
float rvol = volumeAverage > 0 ? volume / volumeAverage : na
bool unreliableChartVolume = syminfo.type == "index" or syminfo.type == "cfd"
float tickerDayReturn = f_safeRet(close, pdc)

float spyClose = request.security("SPY", timeframe.period, close, ignore_invalid_symbol = true)
float spyPrev = request.security("SPY", "D", close[1], ignore_invalid_symbol = true)
float qqqClose = request.security("QQQ", timeframe.period, close, ignore_invalid_symbol = true)
float qqqPrev = request.security("QQQ", "D", close[1], ignore_invalid_symbol = true)
float iwmClose = request.security("IWM", timeframe.period, close, ignore_invalid_symbol = true)
float iwmPrev = request.security("IWM", "D", close[1], ignore_invalid_symbol = true)
float smhClose = request.security("SMH", timeframe.period, close, ignore_invalid_symbol = true)
float smhPrev = request.security("SMH", "D", close[1], ignore_invalid_symbol = true)
float vixClose = request.security("CBOE:VIX", timeframe.period, close, ignore_invalid_symbol = true)
float vixPrev = request.security("CBOE:VIX", "D", close[1], ignore_invalid_symbol = true)
float crudeClose = request.security("NYMEX:CL1!", timeframe.period, close, ignore_invalid_symbol = true)
float crudePrev = request.security("NYMEX:CL1!", "D", close[1], ignore_invalid_symbol = true)
float spxCash = request.security("SP:SPX", timeframe.period, close, ignore_invalid_symbol = true)
float spxPrev = request.security("SP:SPX", "D", close[1], ignore_invalid_symbol = true)
float xleClose = request.security("XLE", timeframe.period, close, ignore_invalid_symbol = true)
float xlePrev = request.security("XLE", "D", close[1], ignore_invalid_symbol = true)
float xlvClose = request.security("XLV", timeframe.period, close, ignore_invalid_symbol = true)
float xlvPrev = request.security("XLV", "D", close[1], ignore_invalid_symbol = true)
float xlfClose = request.security("XLF", timeframe.period, close, ignore_invalid_symbol = true)
float xlfPrev = request.security("XLF", "D", close[1], ignore_invalid_symbol = true)
float igvClose = request.security("IGV", timeframe.period, close, ignore_invalid_symbol = true)
float igvPrev = request.security("IGV", "D", close[1], ignore_invalid_symbol = true)
float xlyClose = request.security("XLY", timeframe.period, close, ignore_invalid_symbol = true)
float xlyPrev = request.security("XLY", "D", close[1], ignore_invalid_symbol = true)

// Native TradingView market internals. Value and source-bar time are requested
// together so effective MI can discount stale feeds instead of treating repeated
// last values as fresh observations.
[uvolClose, uvolSourceTime] = request.security(uvolSymbol, timeframe.period, [close, time], ignore_invalid_symbol = true)
[dvolClose, dvolSourceTime] = request.security(dvolSymbol, timeframe.period, [close, time], ignore_invalid_symbol = true)
[tickRaw, tickSourceTime] = request.security(tickSymbol, timeframe.period, [close, time], ignore_invalid_symbol = true)
[vix1dClose, vix1dSourceTime] = request.security(vix1dSymbol, timeframe.period, [close, time], ignore_invalid_symbol = true)
[vix9dClose, vix9dSourceTime] = request.security(vix9dSymbol, timeframe.period, [close, time], ignore_invalid_symbol = true)

float spyRet = f_safeRet(spyClose, spyPrev)
float qqqRet = f_safeRet(qqqClose, qqqPrev)
float iwmRet = f_safeRet(iwmClose, iwmPrev)
float smhRet = f_safeRet(smhClose, smhPrev)
float vixRet = f_safeRet(vixClose, vixPrev)
float crudeRet = f_safeRet(crudeClose, crudePrev)
float spxRet = f_safeRet(spxCash, spxPrev)
float xleRet = f_safeRet(xleClose, xlePrev)
float xlvRet = f_safeRet(xlvClose, xlvPrev)
float xlfRet = f_safeRet(xlfClose, xlfPrev)
float igvRet = f_safeRet(igvClose, igvPrev)
float xlyRet = f_safeRet(xlyClose, xlyPrev)

float upVolumeShare = not na(uvolClose) and not na(dvolClose) and uvolClose + dvolClose > 0 ? uvolClose / (uvolClose + dvolClose) : na
float tickSmooth = ta.sma(tickRaw, tickSmoothLength)
float vix1d9dRatio = not na(vix1dClose) and not na(vix9dClose) and vix9dClose > 0 ? vix1dClose / vix9dClose : na
float vix9dVixRatio = not na(vix9dClose) and not na(vixClose) and vixClose > 0 ? vix9dClose / vixClose : na
bool frontVolStress = not na(vix1d9dRatio) and vix1d9dRatio >= frontVolStressRatio
bool frontVolCalm = not na(vix1d9dRatio) and vix1d9dRatio <= 0.95 and (na(vix9dVixRatio) or vix9dVixRatio <= 1.03)
bool breadthBull = not na(upVolumeShare) and upVolumeShare >= bullUpVolumeShare and not na(tickSmooth) and tickSmooth >= bullTickThreshold
bool breadthBear = not na(upVolumeShare) and upVolumeShare <= bearUpVolumeShare and not na(tickSmooth) and tickSmooth <= bearTickThreshold
float upVolScore = na(upVolumeShare) ? 20.0 : f_clamp((upVolumeShare - 0.30) / 0.40 * 40.0, 0.0, 40.0)
float tickScore = na(tickSmooth) ? 15.0 : f_clamp((tickSmooth + 800.0) / 1600.0 * 30.0, 0.0, 30.0)
float curveScore = frontVolCalm ? 20.0 : frontVolStress ? 0.0 : 10.0
float vixScore = vixClose < 18.50 ? 10.0 : vixClose < 19.0 ? 7.0 : vixClose < 20.0 ? 3.0 : 0.0
int internalsScore = int(math.round(f_clamp(upVolScore + tickScore + curveScore + vixScore, 0.0, 100.0)))
bool internalsBull = internalsScore >= 60 or breadthBull
bool internalsBear = internalsScore <= 40 or breadthBear
string internalsText = not inRTH ? "INTERNALS RTH ONLY" : na(upVolumeShare) and na(tickSmooth) ? "INTERNALS N/A" : internalsScore >= 65 ? "BREADTH BULL" : internalsScore <= 35 ? "BREADTH BEAR" : internalsScore >= 55 ? "BREADTH FIRM" : internalsScore <= 45 ? "BREADTH WEAK" : "BREADTH MIXED"
string volCurveText = frontVolStress ? "FRONT VOL STRESS" : frontVolCalm ? "VOL CURVE CALM" : "VOL CURVE MIXED"

// --------------------------------------------------------------------------
// SCX-inspired source/effective MI separation and fail-closed integrity gate.
// Source MI measures data availability. Effective MI discounts stale or
// context-mismatched data. It does not represent predictive probability.
// --------------------------------------------------------------------------
bool uvDvAvailable = not na(uvolClose) and not na(dvolClose)
bool tickAvailable = not na(tickSmooth)
bool frontVolAvailable = not na(vix1dClose) and not na(vix9dClose)
bool coreMarketAvailable = not na(spyClose) and not na(qqqClose) and not na(iwmClose) and not na(smhClose) and not na(vixClose)
bool chartVolumeAvailable = unreliableChartVolume or not na(volume) and volume >= 0
bool internalsTimestampAvailable = not na(uvolSourceTime) and not na(dvolSourceTime) and not na(tickSourceTime) and not na(vix1dSourceTime) and not na(vix9dSourceTime)
int oldestInternalsTimestamp = internalsTimestampAvailable ? math.min(math.min(math.min(uvolSourceTime, dvolSourceTime), math.min(tickSourceTime, vix1dSourceTime)), vix9dSourceTime) : na
float internalsAgeMinutes = internalsTimestampAvailable ? math.max(0.0, (time_close - oldestInternalsTimestamp) / 60000.0) : na
float sourceMIScore =
     (uvDvAvailable ? 24.0 : 0.0) +
     (tickAvailable ? 18.0 : 0.0) +
     (frontVolAvailable ? 18.0 : 0.0) +
     (coreMarketAvailable ? 20.0 : 0.0) +
     (chartVolumeAvailable ? 10.0 : 0.0) +
     (mapFresh ? 10.0 : 0.0)
float stalenessPenalty = not na(internalsAgeMinutes) and internalsAgeMinutes > maximumInternalsAgeMinutes ? math.min(40.0, (internalsAgeMinutes - maximumInternalsAgeMinutes) * 2.0) : internalsTimestampAvailable ? 0.0 : 25.0
float sessionPenalty = timeframe.isintraday ? 0.0 : 10.0
float effectiveMIScore = f_clamp(sourceMIScore - stalenessPenalty - sessionPenalty, 0.0, 100.0)
bool operationalIntegrityReady = not useOperationalIntegrityGate or effectiveMIScore >= minimumOperationalIntegrity
string integrityText = not mapFresh ? "MAP STALE" : not operationalIntegrityReady ? (not inRTH ? "FROZEN / DATA BLOCK" : "INTEGRITY BLOCK") : not inRTH ? "FROZEN / QUALIFIED" : effectiveMIScore >= 85 ? "DATA ELITE" : effectiveMIScore >= 70 ? "DATA GOOD" : "DATA QUALIFIED"

// July 20 negative-gamma index hierarchy.
bool spxRiskBand = spxCash >= 7515 and spxCash <= 7565
bool spyRiskBand = spyClose >= 740 and spyClose <= 752
bool qqqRiskBand = qqqClose >= 691 and qqqClose <= 710
bool smhRiskBand = smhClose >= 550 and smhClose <= 585
bool iwmRiskBand = iwmClose >= 292 and iwmClose <= 297
bool vixRiskBand = vixClose >= 18.50 and vixClose <= 20.0
bool bullPermission = spxCash > 7550 and spyClose > 752 and qqqClose > 710 and iwmClose > 297 and smhClose > 585 and vixClose < 18.50 and (not useInternalsInSignals or internalsBull)
bool bearPermission = spxCash < 7515 and spyClose < 740 and qqqClose < 691 and iwmClose < 292 and smhClose < 550 and vixClose > 20.0 and (not useInternalsInSignals or internalsBear)
bool gammaRepair = spxCash >= 7525 and spyClose >= 750 and qqqClose >= 708 and smhClose >= 585 and iwmClose >= 297 and vixClose < 19.0
bool riskOffPressure = qqqClose < 700 and iwmClose < 297 and smhClose < 585 and vixClose >= 19.0
bool negativeGammaChop = (spyRiskBand or qqqRiskBand or smhRiskBand or iwmRiskBand) and vixClose >= 18.0 and vixClose <= 20.0
bool growthRepair = qqqClose >= 708 and smhClose >= 585 and vixClose < 19.0
bool growthBreakdown = qqqClose < 691 and smhClose < 550
bool breadthRepair = iwmClose >= 297
bool breadthBreakdown = iwmClose < 292
bool energyLeadership = xleRet >= spyRet and crudeClose >= 83.60
bool healthcareLeadership = xlvRet >= spyRet and xlvRet > 0
bool bankLeadership = xlfRet >= spyRet and xlfRet > 0
bool softwareLeadership = igvRet >= qqqRet - 0.10
bool discretionaryWeakness = xlyRet < spyRet

string regimeText = bearPermission ? "RISK-OFF UNWIND" : riskOffPressure ? "FAILED REPAIR / SELL RALLIES" : bullPermission ? "RISK-ON REPAIR" : gammaRepair ? "MULTI-GATE REPAIR" : negativeGammaChop ? "NEG-GAMMA CHOP" : growthBreakdown ? "TECH / BREADTH BREAKDOWN" : "SELECTIVE — WAIT FOR ACCEPTANCE"
color regimeColor = bearPermission or riskOffPressure or growthBreakdown ? cShort : bullPermission or gammaRepair ? cLong : negativeGammaChop ? cGold : cNeutral
// ============================================================================
// ADAPTIVE RIPSTER CLOUD ENGINE
// ============================================================================

f_ripsterLengths() =>
    int sec = timeframe.in_seconds(timeframe.period)
    bool auto = ripsterLens == "Auto by Chart Timeframe"
    bool scalp = ripsterLens == "Scalp" or (auto and sec <= 180)
    bool intraday = ripsterLens == "Intraday" or (auto and sec > 180 and sec <= 900)
    bool swing = ripsterLens == "Swing" or (auto and sec > 900 and sec <= 14400)
    // Lower-timeframe default: 8/21 execution and 21/55 trend.
    // 5/13 remains the fast micro lens; it is visual/early context, not the primary trigger.
    int mFast = scalp ? 5 : intraday ? 8 : swing ? 9 : 21
    int mSlow = scalp ? 13 : intraday ? 21 : swing ? 21 : 50
    int eFast = scalp ? 8 : intraday ? 9 : swing ? 9 : 21
    int eSlow = scalp ? 21 : intraday ? 21 : swing ? 21 : 50
    int sFast = scalp ? 21 : intraday ? 21 : swing ? 21 : 50
    int sSlow = scalp ? 55 : intraday ? 55 : swing ? 55 : 200
    [mFast, mSlow, eFast, eSlow, sFast, sSlow]

f_htf1() =>
    int sec = timeframe.in_seconds(timeframe.period)
    sec <= 60 ? "5" : sec <= 300 ? "15" : sec <= 900 ? "60" : sec <= 3600 ? "240" : "D"

f_htf2() =>
    int sec = timeframe.in_seconds(timeframe.period)
    sec <= 300 ? "60" : sec <= 900 ? "240" : sec <= 14400 ? "D" : "W"

[microFastLen, microSlowLen, execFastLen, execSlowLen, structFastLen, structSlowLen] = f_ripsterLengths()
string htf1 = f_htf1()
string htf2 = f_htf2()

float microFast = ta.ema(ripsterSource, microFastLen)
float microSlow = ta.ema(ripsterSource, microSlowLen)
float execFast = ta.ema(ripsterSource, execFastLen)
float execSlow = ta.ema(ripsterSource, execSlowLen)
float structFast = ta.ema(ripsterSource, structFastLen)
float structSlow = ta.ema(ripsterSource, structSlowLen)
float htfFast = request.security(syminfo.tickerid, htf1, ta.ema(ripsterSource, execFastLen), ignore_invalid_symbol = true)
float htfSlow = request.security(syminfo.tickerid, htf1, ta.ema(ripsterSource, execSlowLen), ignore_invalid_symbol = true)
float htf2Fast = request.security(syminfo.tickerid, htf2, ta.ema(ripsterSource, structFastLen), ignore_invalid_symbol = true)
float htf2Slow = request.security(syminfo.tickerid, htf2, ta.ema(ripsterSource, structSlowLen), ignore_invalid_symbol = true)

bool microBull = microFast > microSlow
bool microBear = microFast < microSlow
bool execBull = execFast > execSlow and close >= math.max(execFast, execSlow)
bool execBear = execFast < execSlow and close <= math.min(execFast, execSlow)
bool structBull = structFast > structSlow and close >= (structFast + structSlow) / 2.0
bool structBear = structFast < structSlow and close <= (structFast + structSlow) / 2.0
bool htfBull = htfFast > htfSlow
bool htfBear = htfFast < htfSlow
bool htf2Bull = htf2Fast > htf2Slow
bool htf2Bear = htf2Fast < htf2Slow
bool htfLongOk = htfBull and (not useHTF2InLogic or htf2Bull)
bool htfShortOk = htfBear and (not useHTF2InLogic or htf2Bear)

bool cloudLongOk = cloudRequirement == "Execution Only" ? execBull : cloudRequirement == "Execution + Structure" ? execBull and structBull : execBull and structBull and htfLongOk
bool cloudShortOk = cloudRequirement == "Execution Only" ? execBear : cloudRequirement == "Execution + Structure" ? execBear and structBear : execBear and structBear and htfShortOk
bool cloudConflict = (execBull and structBear) or (execBear and structBull) or (cloudRequirement == "Execution + Structure + HTF" and ((execBull and not htfLongOk) or (execBear and not htfShortOk)))
string cloudText = cloudLongOk ? "BULL STACK" : cloudShortOk ? "BEAR STACK" : cloudConflict ? "CONFLICT" : "NEUTRAL"

int chartSeconds = timeframe.in_seconds(timeframe.period)
int adaptiveRsiLength = chartSeconds <= 60 ? 7 : chartSeconds <= 300 ? 9 : 14
float rsiValue = ta.rsi(close, adaptiveRsiLength)
bool rsiRising = rsiValue > rsiValue[1]
bool rsiFalling = rsiValue < rsiValue[1]
bool rsiLongOk = rsiValue >= rsiLongFloor and (rsiRising or rsiValue >= 56)
bool rsiShortOk = rsiValue <= rsiShortCeiling and (rsiFalling or rsiValue <= 44)
bool rsiLongExhausted = rsiValue >= 78
bool rsiShortExhausted = rsiValue <= 22

bool emaBullCross = ta.crossover(execFast, execSlow)
bool emaBearCross = ta.crossunder(execFast, execSlow)
int barsSinceBullCross = nz(ta.barssince(emaBullCross), 100000)
int barsSinceBearCross = nz(ta.barssince(emaBearCross), 100000)
bool emaLongMomentum = execFast > execSlow and execFast >= execFast[1] and execSlow >= execSlow[1] and (barsSinceBullCross <= 30 or close > structFast)
bool emaShortMomentum = execFast < execSlow and execFast <= execFast[1] and execSlow <= execSlow[1] and (barsSinceBearCross <= 30 or close < structFast)
string emaText = emaBullCross ? "EMA BULL CROSS" : emaBearCross ? "EMA BEAR CROSS" : emaLongMomentum ? str.tostring(execFastLen) + "/" + str.tostring(execSlowLen) + " BULL" : emaShortMomentum ? str.tostring(execFastLen) + "/" + str.tostring(execSlowLen) + " BEAR" : "EMA MIXED"
string rsiText = "RSI" + str.tostring(adaptiveRsiLength) + " " + str.tostring(rsiValue, "#.0")


// ============================================================================
// NATIVE DUAL-SURFACE LENS
// ============================================================================
// Structural surface: price acceptance relative to VWAP, execution/structure
// EMAs and relative strength. Hedge-pressure surface: internals, front-end vol
// and the mapped index regime. These are native proxies, not actual dealer GEX.
float atrNorm = math.max(dailyAtr, syminfo.mintick * 100.0)
float vwapComponent = f_clamp((close - vwapValue) / atrNorm, -1.50, 1.50) / 1.50
float executionComponent = f_clamp((execFast - execSlow) / atrNorm * 8.0, -1.0, 1.0)
float structureComponent = f_clamp((structFast - structSlow) / atrNorm * 6.0, -1.0, 1.0)
float surfaceRelativeEdge = tickerDayReturn - spyRet
float relativeComponent = f_clamp(surfaceRelativeEdge / 1.50, -1.0, 1.0)
float structuralSurface = f_clamp(vwapComponent * 0.35 + executionComponent * 0.25 + structureComponent * 0.25 + relativeComponent * 0.15, -1.0, 1.0)
float internalsComponent = f_clamp((internalsScore - 50.0) / 50.0, -1.0, 1.0)
float volComponent = frontVolCalm ? 1.0 : frontVolStress ? -1.0 : vixClose < 19.0 ? 0.35 : vixClose > 20.0 ? -0.75 : 0.0
float gateComponent = bullPermission ? 1.0 : bearPermission ? -1.0 : gammaRepair ? 0.45 : riskOffPressure ? -0.45 : 0.0
float hedgePressureSurface = f_clamp(internalsComponent * 0.45 + volComponent * 0.25 + gateComponent * 0.30, -1.0, 1.0)
float compositeSurface = f_clamp(structuralSurface * 0.55 + hedgePressureSurface * 0.45, -1.0, 1.0)
bool surfaceConflict = structuralSurface * hedgePressureSurface < -0.12
string surfaceCoreState = not operationalIntegrityReady ? "SURFACE BLOCKED" : surfaceConflict ? "SURFACE CONFLICT" : compositeSurface >= 0.55 ? "ACCELERATION UP" : compositeSurface <= -0.55 ? "ACCELERATION DOWN" : compositeSurface >= 0.15 ? "STABILIZATION UP" : compositeSurface <= -0.15 ? "STABILIZATION DOWN" : "EQUILIBRIUM"
string surfaceStateText = not inRTH ? "FROZEN | " + surfaceCoreState : surfaceCoreState
color surfaceStateColor = not operationalIntegrityReady ? cNeutral : surfaceConflict ? cGold : compositeSurface >= 0.15 ? cLong : compositeSurface <= -0.15 ? cShort : cNeutral

var float sessionOpenPrice = na
if newRTH
    sessionOpenPrice := open
float envelopeVolScale = not na(vix9dClose) ? f_clamp(vix9dClose / 19.0, 0.70, 1.45) : 1.0
float nativeEnvelopeHalf = dailyAtr * 0.55 * envelopeVolScale
float nativeEnvelopeUpper = not na(sessionOpenPrice) ? sessionOpenPrice + nativeEnvelopeHalf : na
float nativeEnvelopeLower = not na(sessionOpenPrice) ? sessionOpenPrice - nativeEnvelopeHalf : na
plot(showNativeRangeEnvelope and inRTH ? nativeEnvelopeUpper : na, "Native Range Upper", color = color.new(cTarget, rangeEnvelopeOpacity), linewidth = 1, style = plot.style_linebr)
plot(showNativeRangeEnvelope and inRTH ? nativeEnvelopeLower : na, "Native Range Lower", color = color.new(cTarget, rangeEnvelopeOpacity), linewidth = 1, style = plot.style_linebr)

bool minimalUI = workspace == "Minimal"
bool researchUI = workspace == "Research"
bool retailUI = workspace == "Retail Guided"
bool compactUI = workspace == "Split-Screen Compact"
bool effectiveLevelLabels = showLevelLabels and not minimalUI
bool effectiveActionZones = showActionZones and not minimalUI
bool effectiveCurrentDashboard = showCurrentDashboard and not minimalUI
bool effectiveDecisionLadder = showDecisionLadder and not minimalUI
bool effectiveFocusBoard = (showFocusBoard or researchUI) and not compactUI
bool effectiveSignalLabels = showSignalLabels and not minimalUI
bool drawExec = showRipster and showExecutionCloud
bool drawStruct = showRipster and showStructureCloud and not minimalUI and not compactUI

// Micro cloud remains in the signal engine but is not rendered, preserving plot budget.

pExecFast = plot(drawExec ? execFast : na, "Ripster Execution Fast", color = showRipsterLines ? color.new(execBull ? cLong : cShort, 5) : na, linewidth = 1)
pExecSlow = plot(drawExec ? execSlow : na, "Ripster Execution Slow", color = showRipsterLines ? color.new(execBull ? cLong : cShort, 5) : na, linewidth = 2)
fill(pExecFast, pExecSlow, color = drawExec ? color.new(execFast >= execSlow ? cLong : cShort, executionOpacity) : na, title = "Ripster Execution Cloud")

pStructFast = plot(drawStruct ? structFast : na, "Ripster Structure Fast", color = showRipsterLines ? color.new(structBull ? color.rgb(45, 105, 180) : cGold, 10) : na, linewidth = 1)
pStructSlow = plot(drawStruct ? structSlow : na, "Ripster Structure Slow", color = showRipsterLines ? color.new(structBull ? color.rgb(35, 75, 145) : color.rgb(160, 95, 45), 10) : na, linewidth = 2)
fill(pStructFast, pStructSlow, color = drawStruct ? color.new(structFast >= structSlow ? color.rgb(45, 105, 180) : cGold, structureOpacity) : na, title = "Ripster Structure Cloud")

// Higher-timeframe Ripster state remains logic-only to preserve plot headroom.

plot(showVWAP ? vwapValue : na, "Session VWAP", color = cVwap, linewidth = vwapWidth)

// ============================================================================
// THE STRAT CONTEXT
// ============================================================================

bool priorInside = not na(pdh) and not na(pdl) and not na(pdh2) and not na(pdl2) and pdh < pdh2 and pdl > pdl2
bool priorOutside = not na(pdh) and not na(pdl) and not na(pdh2) and not na(pdl2) and pdh > pdh2 and pdl < pdl2
bool currentTwoUp = not na(dHigh) and not na(pdh) and not na(dLow) and not na(pdl) and dHigh > pdh and dLow >= pdl
bool currentTwoDown = not na(dLow) and not na(pdl) and not na(dHigh) and not na(pdh) and dLow < pdl and dHigh <= pdh
bool currentOutside = not na(dHigh) and not na(pdh) and not na(dLow) and not na(pdl) and dHigh > pdh and dLow < pdl
bool currentInside = not na(dHigh) and not na(pdh) and not na(dLow) and not na(pdl) and dHigh < pdh and dLow > pdl
string stratText = currentOutside ? "3 OUTSIDE" : currentTwoUp ? "2U" : currentTwoDown ? "2D" : currentInside ? "1 INSIDE" : priorInside ? "PRIOR 1" : "2 / DEVELOPING"
bool stratLongOk = not useStratConfluence or currentTwoUp or currentOutside or close > pdh
bool stratShortOk = not useStratConfluence or currentTwoDown or currentOutside or close < pdl

// ============================================================================
// SETUP MODEL
// ============================================================================

type ScSetup
    bool active = false
    bool mapped = false
    bool watchOnly = false
    bool eventName = false
    bool hasLong = false
    bool hasShort = false
    string rank = "N/A"
    string grade = "N/A"
    string bucket = "N/A"
    string thesis = "No mapped setup."
    string longMode = "Breakout"
    string shortMode = "Breakdown"
    string longVehicle = "N/A"
    string shortVehicle = "N/A"
    string gateType = "GENERIC"
    float baseScore = 0.0
    float longTrigger = na
    float longConfirm = na
    float longInvalid = na
    float longHardInvalid = na
    float longT1 = na
    float longT2 = na
    float longT3 = na
    float longZoneLo = na
    float longZoneHi = na
    float shortTrigger = na
    float shortConfirm = na
    float shortInvalid = na
    float shortHardInvalid = na
    float shortT1 = na
    float shortT2 = na
    float shortT3 = na
    float shortZoneLo = na
    float shortZoneHi = na

f_base(string rank, string grade, string bucket, string thesis, string gateType, float score) =>
    ScSetup s = ScSetup.new()
    s.active := true
    s.mapped := true
    s.rank := rank
    s.grade := grade
    s.bucket := bucket
    s.thesis := thesis
    s.gateType := gateType
    s.baseScore := score
    s

f_long(ScSetup s, string mode, float trig, float conf, float inv, float hard, float t1, float t2, float t3, float zLo, float zHi, string vehicle) =>
    s.hasLong := true
    s.longMode := mode
    s.longTrigger := trig
    s.longConfirm := conf
    s.longInvalid := inv
    s.longHardInvalid := hard
    s.longT1 := t1
    s.longT2 := t2
    s.longT3 := t3
    s.longZoneLo := zLo
    s.longZoneHi := zHi
    s.longVehicle := vehicle
    s

f_short(ScSetup s, string mode, float trig, float conf, float inv, float hard, float t1, float t2, float t3, float zLo, float zHi, string vehicle) =>
    s.hasShort := true
    s.shortMode := mode
    s.shortTrigger := trig
    s.shortConfirm := conf
    s.shortInvalid := inv
    s.shortHardInvalid := hard
    s.shortT1 := t1
    s.shortT2 := t2
    s.shortT3 := t3
    s.shortZoneLo := zLo
    s.shortZoneHi := zHi
    s.shortVehicle := vehicle
    s

f_loadManualSetup() =>
    ScSetup s = ScSetup.new()
    if manualMapEnabled and manualTrigger > 0 and manualInvalid > 0 and manualTarget1 > 0
        s := f_base("M", "Manual Map", "CUSTOM", "User-defined current-ticker execution map.", "GENERIC", 80)
        if manualDirection == "Long" or manualDirection == "Two-Way"
            s := f_long(s, "Manual", manualTrigger, manualConfirm > 0 ? manualConfirm : manualTrigger, manualInvalid, manualHardInvalid > 0 ? manualHardInvalid : manualInvalid, manualTarget1, manualTarget2 > 0 ? manualTarget2 : manualTarget1, manualTarget3 > 0 ? manualTarget3 : manualTarget2, manualZoneLow > 0 ? manualZoneLow : manualTrigger, manualZoneHigh > 0 ? manualZoneHigh : manualConfirm, "User-selected vehicle")
        if manualDirection == "Short" or manualDirection == "Two-Way"
            s := f_short(s, "Manual", manualTrigger, manualConfirm > 0 ? manualConfirm : manualTrigger, manualInvalid, manualHardInvalid > 0 ? manualHardInvalid : manualInvalid, manualTarget1, manualTarget2 > 0 ? manualTarget2 : manualTarget1, manualTarget3 > 0 ? manualTarget3 : manualTarget2, manualZoneLow > 0 ? manualZoneLow : manualConfirm, manualZoneHigh > 0 ? manualZoneHigh : manualInvalid, "User-selected vehicle")
    s

f_eventRangeSetup(string rank, string grade, string thesis, string gateType, float score) =>
    float hi = nz(pdh, close + dailyAtr * 0.40)
    float lo = nz(pdl, close - dailyAtr * 0.40)
    ScSetup s = f_base(rank, grade, "EVENT — OPENING RANGE", thesis, gateType, score)
    s.eventName := true
    s := f_long(s, "OR Break", hi, hi + dailyAtr * 0.15, lo, lo - dailyAtr * 0.35, hi + dailyAtr * 0.50, hi + dailyAtr, hi + dailyAtr * 1.50, lo, hi, "Defined-risk call spread after OR")
    s := f_short(s, "OR Fail", lo, lo - dailyAtr * 0.15, hi, hi + dailyAtr * 0.35, lo - dailyAtr * 0.50, lo - dailyAtr, lo - dailyAtr * 1.50, lo, hi, "Defined-risk put spread after OR")
    s

f_dynamicDirectionalSetup(string rank, string grade, string bucket, string thesis, string gateType, float score, int bias, bool watchOnly, bool eventName) =>
    float hi = nz(pdh, close + dailyAtr * 0.40)
    float lo = nz(pdl, close - dailyAtr * 0.40)
    float mid = (hi + lo) / 2.0
    ScSetup s = f_base(rank, grade, bucket, thesis, gateType, score)
    s.watchOnly := watchOnly
    s.eventName := eventName
    if bias >= 0
        s := f_long(s, "Range Acceptance", hi, hi + dailyAtr * 0.15, mid, lo, hi + dailyAtr * 0.50, hi + dailyAtr, hi + dailyAtr * 1.50, mid, hi, "Defined-risk call spread or shares after retest")
    if bias <= 0
        s := f_short(s, "Failed Rebound / Range Loss", lo, lo - dailyAtr * 0.15, mid, hi, lo - dailyAtr * 0.50, lo - dailyAtr, lo - dailyAtr * 1.50, lo, mid, "Defined-risk put spread or shares after failed rebound")
    s

f_loadIndexSetup(string sym) =>
    ScSetup s = ScSetup.new()
    if sym == "SPX" or sym == "SPXW" or sym == "US500" or sym == "SPX500USD"
        s := f_base("IDX", "A SPX", "NEGATIVE-GAMMA CONTROL MAP", "Below 7,515 remains unstable. Repair requires 7,525 then 7,550/7,565. SPY is the preferred executable proxy.", "INDEX", 94)
        s := f_long(s, "Repair Acceptance", 7525.0, 7550.0, 7515.0, 7500.0, 7565.0, 7575.0, 7600.0, 7515.0, 7550.0, "0DTE call spread after acceptance and breadth repair")
        s := f_short(s, "Control-Band Failure", 7515.0, 7500.0, 7525.0, 7550.0, 7485.0, 7450.0, 7400.0, 7515.0, 7525.0, "0DTE put spread after failed reclaim")

    if sym == "SPY"
        s := f_base("IDX", "A- SPY", "750-752 REPAIR SHELF", "750-752 is the repair shelf. 754-760 builds positive gamma; 740/736/735 are the downside ladder.", "INDEX", 92)
        s := f_long(s, "Gamma Repair", 750.0, 752.0, 745.0, 740.0, 754.0, 758.0, 760.0, 745.0, 752.0, "SPY call debit spread after 750-752 acceptance")
        s := f_short(s, "740 Failure", 740.0, 736.0, 745.0, 750.0, 736.0, 735.0, 730.0, 740.0, 745.0, "SPY put debit spread after failed 740 reclaim")

    if sym == "QQQ"
        s := f_base("GATE", "A QQQ", "HIGHEST-IMPACT INDEX GATE", "Negative gamma at spot. Repair requires 708-710. Loss of 691/690 exposes 685 and 680.", "INDEX", 96)
        s := f_long(s, "Growth Repair", 708.0, 710.0, 700.0, 695.0, 712.0, 715.0, 720.0, 700.0, 710.0, "QQQ call spread only after 708-710 acceptance")
        s := f_short(s, "691/690 Failure", 691.0, 690.0, 700.0, 708.0, 685.0, 680.0, 675.0, 691.0, 700.0, "QQQ put spread after failed rebound or range loss")

    if sym == "IWM"
        s := f_base("1", "A- IWM SHORT", "PRIMARY BREADTH UNWIND", "$25.34M net put premium and negative-gamma breadth. Exact execution requires five-minute acceptance below 291.64.", "SMALLCAP", 96)
        s := f_long(s, "297 Repair", 297.0, 300.0, 294.25, 291.64, 299.0, 300.0, 303.0, 294.25, 300.0, "IWM call spread only after broad repair")
        s := f_short(s, "291.64 Acceptance", 291.64, 290.68, 294.25, 297.81, 287.50, 285.50, 282.50, 291.64, 294.25, "7/24 292/287.5 put debit spread")

    if sym == "RUT"
        float hi = nz(pdh, close + dailyAtr * 0.50)
        float lo = nz(pdl, close - dailyAtr * 0.50)
        s := f_base("IDX", "RUT Actual-Price Range", "IWM-GATED BREADTH MAP", "Use the actual RUT scale. IWM 297 is the repair gate and 292 the downside acceleration gate.", "SMALLCAP", 82)
        s := f_long(s, "PDH Break", hi, hi + dailyAtr * 0.20, lo, lo - dailyAtr * 0.45, hi + dailyAtr * 0.45, hi + dailyAtr * 0.90, hi + dailyAtr * 1.35, lo, hi, "RUT options or RTY futures with defined risk")
        s := f_short(s, "PDL Break", lo, lo - dailyAtr * 0.20, hi, hi + dailyAtr * 0.45, lo - dailyAtr * 0.45, lo - dailyAtr * 0.90, lo - dailyAtr * 1.35, lo, hi, "RUT options or RTY futures with defined risk")

    if sym == "SMH"
        s := f_base("GATE", "A SMH", "SEMICONDUCTOR BASKET GATE", "585 is the practical repair shelf. 590/600/605 repair; 567.5/562.5/550 remain downside magnets.", "SEMI", 95)
        s := f_long(s, "585 Repair", 585.0, 590.0, 567.50, 550.0, 600.0, 605.0, 610.0, 567.50, 590.0, "SMH call spread after 585/590 acceptance")
        s := f_short(s, "567.5 Failure", 567.50, 562.50, 585.0, 590.0, 550.0, 540.0, 530.0, 567.50, 585.0, "SMH put spread after failed rebound")

    if sym == "VIX" or sym == "VIX1!"
        s := f_base("VOL", "A VIX", "19 PIVOT / 20 WALL", "Below 18.50 suppresses volatility. Above 19 warns; above 20 confirms repricing toward 21-23.", "VOL", 95)
        s := f_long(s, "Risk Expansion", 19.0, 20.0, 18.50, 17.0, 21.0, 23.0, 25.0, 18.50, 20.0, "VIX call spread / reduce equity beta")
        s := f_short(s, "Vol Suppression", 18.50, 18.0, 19.0, 20.0, 17.0, 16.0, 15.50, 18.0, 19.0, "Equity-risk confirmation only")

    if sym == "XLE" or sym == "USO"
        s := f_dynamicDirectionalSetup("ENERGY", "B+ Energy", "CRUDE-SENSITIVE ROTATION", "WTI must hold 83.60 and energy breadth must remain above VWAP. Higher oil that damages QQQ downgrades the trade.", "ENERGY", 82, 1, false, false)
    s

f_loadPrimaryDaySetup(string sym) =>
    ScSetup s = ScSetup.new()
    if sym == "PLTR"
        s := f_base("2", "A- PLTR SHORT", "DARK-POOL PIVOT FAILURE", "Dark-pool pivot 132.38 and $9.90M net put pressure. Require five-minute acceptance below 129.05.", "GROWTH", 94)
        s := f_short(s, "129.05 Acceptance", 129.05, 128.68, 132.38, 134.77, 126.19, 122.64, 120.0, 129.05, 132.38, "7/24 130/125 put debit spread")
    if sym == "UNH"
        s := f_base("3", "B+ UNH LONG", "POST-EVENT INSIDE RANGE", "Liquid chain and favorable volatility. Long only through 437.47 with healthcare and market confirmation.", "DEFENSIVE", 86)
        s := f_long(s, "Inside 2U", 437.47, 440.0, 427.12, 425.10, 449.39, 461.62, 470.0, 427.12, 440.0, "7/24 435/450 call debit spread")
    if sym == "RIVN"
        s := f_base("4", "B+ RIVN LONG", "WEEKLY 3-1", "Clean weekly 3-1. Execute only if IWM/EV/high-beta breadth confirms.", "SMALLCAP", 85)
        s := f_long(s, "Weekly 3-1", 18.79, 19.0, 17.80, 16.49, 20.20, 21.09, 22.0, 17.80, 19.0, "Shares or defined-risk call spread")
    if sym == "CRWV"
        s := f_base("5", "B+ CRWV LONG", "HIGH-IV AI BREAKOUT", "$3.11M net call premium and $450M dark pool. Long only above 74.50 with SMH repair and no opening chase.", "SEMI", 86)
        s := f_long(s, "74.50 Acceptance", 74.50, 75.50, 72.15, 68.51, 78.40, 80.64, 83.31, 72.15, 75.50, "Call vertical; no naked weekly premium")
    if sym == "IREN"
        s := f_base("6", "B+ IREN SHORT", "FAILED-REBOUND CRYPTO BETA", "$3.81M net put premium and $226.8M dark pool. Short below 32.22 or after a failed rebound.", "HIGHBETA", 86)
        s := f_short(s, "32.22 / Failed Rebound", 32.22, 31.50, 34.92, 37.42, 29.50, 27.50, 25.0, 32.22, 34.92, "Put spread or shares on failed bounce")
    s

f_loadGexStockSetup(string sym) =>
    ScSetup s = ScSetup.new()
    if sym == "NVDA"
        s := f_base("G1", "A- NVDA", "CLEANEST STOCK GEX LADDER", "202.5 pivot. Long above 205; below 200 opens 197.5/195. SMH 585 is the basket gate.", "SEMI", 90)
        s := f_long(s, "205 Acceptance", 205.0, 210.0, 202.50, 200.0, 210.0, 212.50, 215.0, 202.50, 205.0, "Call debit spread; vertical preferred")
        s := f_short(s, "200 Failure", 200.0, 197.50, 202.50, 205.0, 197.50, 195.0, 190.0, 200.0, 202.50, "Put debit spread")
    if sym == "AAPL"
        s := f_base("G2", "B+ AAPL", "330 SUPPORT / 335 WALL", "Hold 330 and accept above 335. IV is near the annual high percentile, so verticals are mandatory.", "QUALITY", 84)
        s := f_long(s, "335 Wall Break", 335.0, 340.0, 330.0, 327.50, 340.0, 345.0, 350.0, 330.0, 335.0, "Call debit spread only")
        s := f_short(s, "327.5 Failure", 327.50, 325.0, 330.0, 335.0, 325.0, 320.0, 315.0, 327.50, 330.0, "Put debit spread")
    if sym == "TSLA"
        s := f_base("G3", "EVENT TSLA", "WEDNESDAY EARNINGS POSITIONING", "Monday is an event-positioning session. Repair requires 395/400; below 375/370 reopens downside.", "HIGHBETA", 78)
        s.eventName := true
        s := f_long(s, "Event Repair", 395.0, 400.0, 380.0, 375.0, 405.0, 410.0, 415.0, 380.0, 400.0, "Defined-risk call vertical")
        s := f_short(s, "375 Failure", 375.0, 370.0, 380.0, 395.0, 370.0, 365.0, 360.0, 375.0, 380.0, "Defined-risk put vertical")
    if sym == "META"
        s := f_base("G4", "B META", "NEGATIVE GAMMA AT SPOT", "Repair requires 662.5/665. Below 640 activates 635/630.", "GROWTH", 80)
        s := f_long(s, "662.5 Repair", 662.50, 665.0, 640.0, 635.0, 670.0, 675.0, 680.0, 640.0, 665.0, "Call debit spread")
        s := f_short(s, "640 Failure", 640.0, 635.0, 662.50, 665.0, 635.0, 630.0, 625.0, 640.0, 662.50, "Put debit spread")
    if sym == "MSFT"
        s := f_base("G5", "B+ MSFT", "392.5 PIVOT / 400 WALL", "High-quality wall break only. IV is near the annual maximum.", "GROWTH", 82)
        s := f_long(s, "400 Acceptance", 400.0, 402.50, 392.50, 390.0, 405.0, 410.0, 415.0, 392.50, 400.0, "Call debit spread")
        s := f_short(s, "390 Failure", 390.0, 385.0, 392.50, 400.0, 385.0, 380.0, 375.0, 390.0, 392.50, "Put debit spread")
    if sym == "GOOGL"
        s := f_base("G6", "EVENT GOOGL", "EARNINGS-GATED NEGATIVE GAMMA", "Tactical reclaim above 350; meaningful repair begins above 372.5. Do not override the event gate with flow alone.", "GROWTH", 76)
        s.eventName := true
        s := f_long(s, "Event Repair", 350.0, 372.50, 345.0, 340.0, 375.0, 380.0, 385.0, 345.0, 372.50, "Call vertical after event acceptance")
        s := f_short(s, "345 Failure", 345.0, 340.0, 350.0, 372.50, 340.0, 335.0, 330.0, 345.0, 350.0, "Put vertical")
    if sym == "GOOG"
        s := f_base("G7", "EVENT GOOG", "EARNINGS-GATED NEGATIVE GAMMA", "Repair begins at 352.5/355, then 360/365/370. Use one Alphabet share class, not both.", "GROWTH", 76)
        s.eventName := true
        s := f_long(s, "352.5 Repair", 352.50, 355.0, 345.0, 340.0, 360.0, 365.0, 370.0, 345.0, 355.0, "Call vertical after event acceptance")
        s := f_short(s, "345 Failure", 345.0, 340.0, 352.50, 355.0, 340.0, 335.0, 330.0, 345.0, 352.50, "Put vertical")
    if sym == "CSCO"
        s := f_base("G8", "B CSCO", "110 SUPPORT / 114 REPAIR", "Supportive gamma, but option IV is at its annual high percentile.", "SEMI", 78)
        s := f_long(s, "114 Acceptance", 114.0, 116.0, 110.0, 109.0, 116.0, 118.0, 120.0, 110.0, 114.0, "Call debit spread")
        s := f_short(s, "109 Failure", 109.0, 108.0, 110.0, 114.0, 108.0, 105.0, 102.0, 109.0, 110.0, "Put debit spread")
    if sym == "MRVL"
        s := f_base("G9", "B MRVL", "TWO-SIDED HIGH VOLATILITY", "190 is first repair and 195/200 the positive-gamma shelf. Below 185 opens 180/175.", "SEMI", 80)
        s := f_long(s, "190/195 Repair", 190.0, 195.0, 185.0, 180.0, 200.0, 205.0, 210.0, 185.0, 195.0, "Call debit spread")
        s := f_short(s, "185 Failure", 185.0, 180.0, 190.0, 195.0, 180.0, 175.0, 170.0, 185.0, 190.0, "Put debit spread")
    s

f_loadStratSetup(string sym) =>
    ScSetup s = ScSetup.new()
    if sym == "NOW"
        s := f_base("S1", "B NOW SHORT", "INSIDE + HAMMER/SHOOTER", "Put-only unusual activity and Wednesday earnings. Require 102.64 acceptance and failed rebound.", "SOFTWARE", 82)
        s.eventName := true
        s := f_short(s, "102.64 Acceptance", 102.64, 99.31, 103.24, 105.83, 99.31, 96.95, 94.0, 102.64, 103.24, "Defined-risk put spread")
    if sym == "SHOP"
        s := f_base("S2", "B SHOP LONG", "WEEKLY INSIDE / REJECTION", "Bullish conditional above 124.61; stronger above 127.89. IV is expensive.", "GROWTH", 78)
        s := f_long(s, "124.61 Acceptance", 124.61, 127.89, 121.11, 120.0, 126.11, 127.89, 130.75, 121.11, 127.89, "Call debit spread")
    if sym == "IBM"
        s := f_base("S3", "EVENT IBM", "TWO-SIDED EVENT RANGE", "Pre-final-results event trade, not ordinary inside-bar continuation.", "QUALITY", 75)
        s.eventName := true
        s := f_long(s, "217.17 Break", 217.17, 219.95, 214.05, 210.22, 219.95, 223.82, 228.0, 214.05, 219.95, "Defined-risk call spread")
        s := f_short(s, "210.22 Break", 210.22, 204.44, 214.05, 217.17, 204.44, 200.0, 195.0, 210.22, 214.05, "Defined-risk put spread")
    if sym == "MU"
        s := f_base("S4", "B- MU TWO-WAY", "EXTREME VOLATILITY", "$66.42M gross flow, but net remains put-biased. Avoid correlated semiconductor stacking.", "SEMI", 76)
        s := f_long(s, "903.96 Break", 903.96, 937.0, 864.64, 804.0, 937.0, 978.0, 1000.0, 864.64, 937.0, "Call vertical only")
        s := f_short(s, "804 Failure", 804.0, 795.0, 864.64, 903.96, 795.0, 776.0, 750.0, 804.0, 864.64, "Put vertical only")
    if sym == "PYPL"
        s := f_base("S5", "EVENT PYPL", "TAKEOVER SPECIAL SITUATION", "Headline-driven two-way event. Separate event-risk rules and opening-range remap apply.", "HIGHBETA", 72)
        s.eventName := true
        s := f_long(s, "57.17 Break", 57.17, 58.0, 55.69, 53.44, 60.50, 62.0, 65.0, 55.69, 58.0, "Defined-risk call vertical")
        s := f_short(s, "55.69 Break", 55.69, 53.44, 57.17, 60.50, 53.44, 52.0, 50.0, 55.69, 57.17, "Defined-risk put vertical")
    s

f_loadFlowSetup(string sym) =>
    ScSetup s = ScSetup.new()
    if sym == "SNDK"
        s := f_dynamicDirectionalSetup("F1", "B+ SNDK SHORT", "PUT-IMBALANCE FAILED REBOUND", "Strong put imbalance and downtrend. Prefer a failed rebound, not a late breakdown chase.", "SEMI", 84, -1, false, false)
    if sym == "AVGO"
        s := f_dynamicDirectionalSetup("F2", "B+ AVGO LONG", "BULLISH ACCUMULATION", "$13.98M net call premium. No full-size long until SMH repairs through 585.", "SEMI", 84, 1, false, false)
    if sym == "INTC"
        s := f_dynamicDirectionalSetup("F3", "B INTC REVERSAL", "CALL IMBALANCE / DAMAGED CHART", "Large call imbalance against a damaged chart. Reversal gate only; do not buy flow blindly.", "SEMI", 78, 1, false, false)
    if sym == "NFLX"
        s := f_dynamicDirectionalSetup("F4", "B+ NFLX SHORT", "POST-EVENT PUT PRESSURE", "Put-heavy post-event structure. Trade only after range support fails or a rebound rejects.", "GROWTH", 84, -1, false, true)
    if sym == "LITE" or sym == "ADI" or sym == "ON" or sym == "VRT" or sym == "NET" or sym == "BA"
        string gate = sym == "BA" ? "QUALITY" : sym == "NET" ? "SOFTWARE" : "SEMI"
        s := f_dynamicDirectionalSetup("F5", "B FLOW SHORT", "FLOW-ONLY CONFIRMATION", "Bearish flow requires basket weakness and price acceptance. Failed bounce preferred.", gate, 76, -1, false, false)
    if sym == "RKLB" or sym == "ASTS" or sym == "ADBE"
        string gate = sym == "ADBE" ? "SOFTWARE" : "HIGHBETA"
        s := f_dynamicDirectionalSetup("F6", "B FLOW LONG", "CALL-CONCENTRATION BREAKOUT", "Bullish flow requires range acceptance, volume and no opening chase.", gate, 76, 1, false, false)
    if sym == "XOM"
        s := f_dynamicDirectionalSetup("F7", "B+ XOM LONG", "ENERGY / CRUDE EXPRESSION", "$2.34M net call premium. Valid while WTI holds 83.60 and energy breadth remains above VWAP.", "ENERGY", 82, 1, false, false)
    if sym == "CAT" or sym == "SIMO" or sym == "APH" or sym == "VSH"
        s := f_dynamicDirectionalSetup("FW", "WATCH FLOW", "PRICE CONFIRMATION REQUIRED", "Flow alone is not trade authorization. Auto-entry disabled until a fresh mapped trigger is supplied.", "QUALITY", 64, 1, true, false)
    s

f_loadTradingViewSetup(string sym) =>
    ScSetup s = ScSetup.new()
    if sym == "NBIS"
        s := f_base("T1", "A- NBIS TWO-WAY", "MOVE-READY VOLATILITY", "Negative flow and 154% IV make this a two-sided volatility setup, not a blind long.", "SEMI", 84)
        s := f_long(s, "186.77 Repair", 186.77, 188.0, 178.17, 169.23, 193.10, 199.51, 205.0, 178.17, 188.0, "Call vertical")
        s := f_short(s, "178.17 Failure", 178.17, 175.0, 186.77, 190.0, 169.23, 164.31, 160.0, 178.17, 186.77, "Put vertical")
    if sym == "BE"
        s := f_base("T2", "A- BE TWO-WAY", "PUT-HEAVY MOVE-READY", "$9.21M net put premium and 169% IV. Defined risk or shares only.", "HIGHBETA", 84)
        s := f_long(s, "223.75 Repair", 223.75, 225.0, 215.38, 204.55, 229.98, 239.38, 245.0, 215.38, 225.0, "Call vertical")
        s := f_short(s, "204.55 Failure", 204.55, 200.0, 215.38, 223.75, 194.60, 190.0, 185.0, 204.55, 215.38, "Put vertical")
    if sym == "MSTR"
        s := f_base("T3", "A- MSTR LONG", "CRYPTO MOMENTUM", "$1.78M call-side premium. Crypto gate and no-chase rules required.", "HIGHBETA", 83)
        s := f_long(s, "95.97 Acceptance", 95.97, 97.47, 94.85, 90.06, 97.47, 101.95, 104.78, 94.85, 97.47, "Call debit spread")
    if sym == "WDC"
        s := f_base("T4", "B+ WDC TWO-WAY", "MOVE-READY / PUT-BIASED", "Overnight strength conflicts with put-biased flow. Direction comes from the range break.", "SEMI", 80)
        s := f_long(s, "492.93 Break", 492.93, 498.72, 470.38, 453.94, 498.72, 513.84, 525.0, 470.38, 498.72, "Call vertical")
        s := f_short(s, "470.38 Break", 470.38, 465.0, 492.93, 500.0, 453.94, 430.52, 420.0, 470.38, 492.93, "Put vertical")
    if sym == "GPRE"
        s := f_base("T5", "A- GPRE LONG", "TREND BEGINNING", "RVOL 5.17 and +11.7% day. RSI is extended; no opening chase.", "ENERGY", 82)
        s := f_long(s, "19.65 Break", 19.65, 20.0, 17.40, 16.80, 20.50, 21.0, 22.0, 17.40, 20.0, "Shares or call spread after retest")
    if sym == "BJRI"
        s := f_base("T6", "B+ BJRI LONG", "TREND + CANDLE", "Rising-window signal and RVOL 3.24. Earnings 7/30 caps swing duration.", "QUALITY", 80)
        s := f_long(s, "68.02 Break", 68.02, 69.0, 63.34, 62.0, 70.0, 72.50, 75.0, 63.34, 69.0, "Shares or call spread")
    if sym == "FSLY"
        s := f_base("T7", "B+ FSLY LONG", "TREND BEGINNING", "RVOL 2.89 and $264.7M turnover. Require software breadth.", "SOFTWARE", 82)
        s := f_long(s, "21.93 Break", 21.93, 22.25, 19.37, 18.75, 23.0, 24.50, 26.0, 19.37, 22.25, "Defined-risk call spread")
    if sym == "XMTR"
        s := f_base("T8", "B+ XMTR LONG", "TREND BEGINNING", "Positive call-side sweep and $28M dark pool. Require 102 acceptance.", "QUALITY", 80)
        s := f_long(s, "102 Break", 102.0, 103.0, 98.54, 91.79, 105.0, 110.0, 115.0, 98.54, 103.0, "Shares or call spread")
    if sym == "TRVI"
        s := f_base("T9", "B+ TRVI LONG", "TREND + NIGHTLY", "RVOL 3.08 and +9.85% day. Biotech sizing and gap discipline apply.", "BIOTECH", 78)
        s := f_long(s, "20.22 Break", 20.22, 20.75, 17.23, 16.50, 22.0, 24.0, 26.0, 17.23, 20.75, "Shares or defined-risk calls")
    s

f_loadContextSetup(string sym) =>
    ScSetup s = ScSetup.new()
    bool eventWatch = sym == "AMZN" or sym == "GOOG" or sym == "GOOGL" or sym == "TSLA" or sym == "NOW" or sym == "IBM"
    bool watch = sym == "ACN" or sym == "AMC" or sym == "BABA" or sym == "CRWD" or sym == "DE" or sym == "DKS" or sym == "FDX" or sym == "GM" or sym == "HD" or sym == "LI" or sym == "MDT" or sym == "PDD" or sym == "WYNN" or sym == "Z" or sym == "WULF" or sym == "CIFR" or sym == "APLD"
    if eventWatch
        s := f_dynamicDirectionalSetup("EV", "EVENT WATCH", "OPENING-RANGE / EVENT GATE", "Event or earnings risk requires opening-range remap and live liquidity confirmation.", "GROWTH", 62, 0, true, true)
    if not s.active and watch
        s := f_dynamicDirectionalSetup("W", "WATCH ONLY", "CONDITIONAL SCANNER RANGE", "Scanner overlap exists, but the setup lacks immediate asymmetry. Auto-entry disabled.", "GENERIC", 58, 0, true, false)
    s

f_loadFuturesSetup(string sym) =>
    ScSetup s = ScSetup.new()
    if f_isFuturesFamily(sym)
        float hi = nz(pdh, close + dailyAtr * 0.50)
        float lo = nz(pdl, close - dailyAtr * 0.50)
        string gate = str.contains(sym, "NQ") or str.contains(sym, "MNQ") ? "GROWTH" : str.contains(sym, "RTY") or str.contains(sym, "M2K") ? "SMALLCAP" : str.contains(sym, "CL") ? "ENERGY" : "INDEX"
        string ref = str.contains(sym, "NQ") or str.contains(sym, "MNQ") ? "NQ supplied ref 28,852.25" : str.contains(sym, "RTY") or str.contains(sym, "M2K") ? "RTY supplied ref 2,970.60" : str.contains(sym, "CL") ? "WTI supplied ref 84.36" : "ES supplied ref 7,502.50"
        s := f_base("FUT", "Actual Futures Range", "FUTURES", "Use actual futures prior-day levels and refresh the supplied reference before execution. " + ref, gate, 80)
        s := f_long(s, "PDH Break", hi, hi + dailyAtr * 0.20, lo, lo - dailyAtr * 0.45, hi + dailyAtr * 0.45, hi + dailyAtr * 0.90, hi + dailyAtr * 1.35, lo, hi, "Futures contract with defined stop")
        s := f_short(s, "PDL Break", lo, lo - dailyAtr * 0.20, hi, hi + dailyAtr * 0.45, lo - dailyAtr * 0.45, lo - dailyAtr * 0.90, lo - dailyAtr * 1.35, lo, hi, "Futures contract with defined stop")
    s

f_loadMappedSetup(string sym) =>
    ScSetup s = f_loadIndexSetup(sym)
    if not s.active
        s := f_loadPrimaryDaySetup(sym)
    if not s.active
        s := f_loadGexStockSetup(sym)
    if not s.active
        s := f_loadStratSetup(sym)
    if not s.active
        s := f_loadFlowSetup(sym)
    if not s.active
        s := f_loadTradingViewSetup(sym)
    if not s.active
        s := f_loadContextSetup(sym)
    if not s.active
        s := f_loadFuturesSetup(sym)
    s

f_loadGenericStrat() =>
    ScSetup s = ScSetup.new()
    bool eligible = enableGenericStratMap and not f_isIndexFamily(str.upper(syminfo.ticker)) and not f_isFuturesFamily(str.upper(syminfo.ticker)) and (not genericInsideDayOnly or priorInside)
    if eligible and not na(pdh) and not na(pdl)
        s := f_base("GEN", "Conditional Strat", "GENERIC STRAT", priorInside ? "Prior inside day. Direction comes from the break, not prediction." : "Generic prior-day range map.", "GENERIC", priorInside ? 72 : 62)
        s.mapped := false
        s := f_long(s, "Prior-Day Break", pdh, pdh + dailyAtr * 0.15, pdl, pdl - dailyAtr * 0.40, pdh + dailyAtr * 0.50, pdh + dailyAtr, pdh + dailyAtr * 1.50, pdl, pdh, "Liquid ATM/1-OTM call or shares")
        s := f_short(s, "Prior-Day Break", pdl, pdl - dailyAtr * 0.15, pdh, pdh + dailyAtr * 0.40, pdl - dailyAtr * 0.50, pdl - dailyAtr, pdl - dailyAtr * 1.50, pdl, pdh, "Liquid ATM/1-OTM put or shares")
    s

string sym = str.upper(syminfo.ticker)
ScSetup manualSetup = f_loadManualSetup()
ScSetup setup = manualSetup
if not setup.active
    setup := f_loadMappedSetup(sym)
if not setup.active
    setup := f_loadGenericStrat()

// ============================================================================
// OPENING RANGE, EVENT REMAP AND MARKET GATES
// ============================================================================

var float orHigh = na
var float orLow = na
if newRTH
    orHigh := high
    orLow := low
else if inRTH and minutesFromOpen >= 0 and minutesFromOpen < openingRangeMinutes
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)

bool orReady = inRTH and minutesFromOpen >= openingRangeMinutes and not na(orHigh) and not na(orLow)
float orRange = orReady ? math.max(orHigh - orLow, syminfo.mintick * 10.0) : na
float gapATR = newRTH and dailyAtr > 0 ? math.abs(open - pdc) / dailyAtr : 0.0
bool gapBeyondHard = newRTH and setup.eventName and ((setup.hasLong and not na(setup.longHardInvalid) and open < setup.longHardInvalid) or (setup.hasShort and not na(setup.shortHardInvalid) and open > setup.shortHardInvalid))
float longMoveToT1 = setup.hasLong ? math.abs(setup.longT1 - setup.longTrigger) : na
float shortMoveToT1 = setup.hasShort ? math.abs(setup.shortTrigger - setup.shortT1) : na
bool longGapConsumed = newRTH and setup.eventName and setup.hasLong and not na(longMoveToT1) and longMoveToT1 > 0 and open > setup.longTrigger and open - setup.longTrigger >= longMoveToT1 * eventGapMoveConsumption
bool shortGapConsumed = newRTH and setup.eventName and setup.hasShort and not na(shortMoveToT1) and shortMoveToT1 > 0 and open < setup.shortTrigger and setup.shortTrigger - open >= shortMoveToT1 * eventGapMoveConsumption
var bool eventRemapNeeded = false
if newRTH
    eventRemapNeeded := enableEventGapRemap and setup.eventName and (gapATR >= eventGapATRThreshold or gapBeyondHard or longGapConsumed or shortGapConsumed)

bool eventRemapWaiting = setup.eventName and eventRemapNeeded and not orReady
bool eventRemapActive = setup.eventName and eventRemapNeeded and orReady
if eventRemapActive
    setup.longTrigger := orHigh
    setup.longConfirm := orHigh + orRange * 0.15
    setup.longInvalid := math.min(vwapValue, orHigh)
    setup.longHardInvalid := orLow
    setup.longT1 := orHigh + orRange * 0.50
    setup.longT2 := orHigh + orRange
    setup.longT3 := orHigh + orRange * 1.50
    setup.longZoneLo := math.min(vwapValue, orHigh)
    setup.longZoneHi := orHigh
    setup.longMode := "EVENT OR BREAK"
    setup.shortTrigger := orLow
    setup.shortConfirm := orLow - orRange * 0.15
    setup.shortInvalid := math.max(vwapValue, orLow)
    setup.shortHardInvalid := orHigh
    setup.shortT1 := orLow - orRange * 0.50
    setup.shortT2 := orLow - orRange
    setup.shortT3 := orLow - orRange * 1.50
    setup.shortZoneLo := orLow
    setup.shortZoneHi := math.max(vwapValue, orLow)
    setup.shortMode := "EVENT OR FAIL"

plot(showOpeningRange and not na(orHigh) ? orHigh : na, "Opening Range High", color = color.new(cGold, 25), linewidth = 1, style = plot.style_linebr)
plot(showOpeningRange and not na(orLow) ? orLow : na, "Opening Range Low", color = color.new(cGold, 25), linewidth = 1, style = plot.style_linebr)
plot(showStratPDLevels and priorInside ? pdh : na, "Prior Inside High", color = color.new(cTrigger, 55), linewidth = 1, style = plot.style_linebr)
plot(showStratPDLevels and priorInside ? pdl : na, "Prior Inside Low", color = color.new(cInvalid, 55), linewidth = 1, style = plot.style_linebr)

bool mappedIndex = setup.gateType == "INDEX"
bool mappedSemi = setup.gateType == "SEMI"
bool mappedGrowth = setup.gateType == "GROWTH"
bool mappedSoftware = setup.gateType == "SOFTWARE"
bool mappedHighBeta = setup.gateType == "HIGHBETA"
bool mappedSmallCap = setup.gateType == "SMALLCAP"
bool mappedEnergy = setup.gateType == "ENERGY"
bool mappedBank = setup.gateType == "BANK"
bool mappedDefensive = setup.gateType == "DEFENSIVE"
bool mappedQuality = setup.gateType == "QUALITY"
bool mappedBiotech = setup.gateType == "BIOTECH"
bool mappedVol = setup.gateType == "VOL"

bool bankOpeningReady = not setup.eventName or (inRTH and minutesFromOpen >= openingRangeMinutes and not openingFreeze)

bool marketLongOk = switch setup.gateType
    "INDEX" => gammaRepair or bullPermission
    "SEMI" => qqqClose >= 708 and smhClose >= 585 and vixClose < 19.0
    "GROWTH" => qqqClose >= 708 and vixClose < 19.0
    "SOFTWARE" => qqqClose >= 708 and softwareLeadership and vixClose < 19.0
    "HIGHBETA" => qqqClose >= 700 and vixClose < 19.0
    "SMALLCAP" => iwmClose >= 297 and vixClose < 19.0
    "ENERGY" => energyLeadership and crudeClose >= 83.60
    "BANK" => bankOpeningReady and bankLeadership
    "DEFENSIVE" => healthcareLeadership or spyClose >= 750
    "QUALITY" => spyClose >= 750 and qqqClose >= 700 and vixClose < 19.0
    "BIOTECH" => healthcareLeadership and vixClose < 20.0
    "VOL" => vixClose >= 19.0
    => spyClose >= 750 and vixClose < 19.0

bool marketShortOk = switch setup.gateType
    "INDEX" => riskOffPressure or bearPermission or (spxCash < 7515 and vixClose >= 19.0)
    "SEMI" => smhClose < 585 or qqqClose < 700
    "GROWTH" => qqqClose < 700 or vixClose >= 19.0
    "SOFTWARE" => qqqClose < 700 or not softwareLeadership or vixClose >= 19.0
    "HIGHBETA" => qqqClose < 700 or vixClose >= 19.0
    "SMALLCAP" => iwmClose < 292 or vixClose >= 19.0
    "ENERGY" => crudeClose < 83.60 or crudeRet < -1.0 or xleRet < spyRet - 0.50
    "BANK" => bankOpeningReady and xlfRet < spyRet
    "DEFENSIVE" => spyClose < 740
    "QUALITY" => spyClose < 740 or discretionaryWeakness
    "BIOTECH" => xlvRet < spyRet or vixClose >= 20.0
    "VOL" => vixClose < 18.50
    => spyClose < 740 or vixClose >= 19.0

float benchmarkRet = mappedSemi ? smhRet : mappedGrowth or mappedSoftware or mappedHighBeta ? qqqRet : mappedSmallCap ? iwmRet : mappedEnergy ? xleRet : mappedBank ? xlfRet : mappedDefensive or mappedBiotech ? xlvRet : spyRet
float relativeEdge = tickerDayReturn - benchmarkRet
bool relativeLongOk = relativeEdge >= minimumRelativeEdge
bool relativeShortOk = relativeEdge <= -minimumRelativeEdge

bool factorSensitive = mappedIndex or mappedSemi or mappedGrowth or mappedSoftware or mappedHighBeta or mappedSmallCap
bool internalsUnavailable = na(upVolumeShare) and na(tickSmooth)
bool internalsApplicable = timeframe.isintraday and inRTH
bool longInternalsOk = not useInternalsInSignals or not internalsApplicable or internalsUnavailable or (factorSensitive ? internalsScore >= 52 : internalsScore >= 42)
bool shortInternalsOk = not useInternalsInSignals or not internalsApplicable or internalsUnavailable or (factorSensitive ? internalsScore <= 48 : internalsScore <= 58)
bool longRSIOk = not useRSIInSignals or rsiLongOk and not rsiLongExhausted
bool shortRSIOk = not useRSIInSignals or rsiShortOk and not rsiShortExhausted
bool longEMAOk = not useEMAMomentumInSignals or emaLongMomentum
bool shortEMAOk = not useEMAMomentumInSignals or emaShortMomentum
// ============================================================================
// PRECISION ENTRY AND TRADE-LIFECYCLE ENGINE
// ============================================================================

bool hasLong = setup.active and setup.hasLong
bool hasShort = setup.active and setup.hasShort
float closeLocation = f_closeLocation()
bool longImpulse = closeLocation >= minimumImpulseClose
bool shortImpulse = closeLocation <= 1.0 - minimumImpulseClose

bool longAboveTrigger = hasLong and not na(setup.longTrigger) and close > setup.longTrigger
bool longAboveConfirm = hasLong and not na(setup.longConfirm) and close > setup.longConfirm
bool shortBelowTrigger = hasShort and not na(setup.shortTrigger) and close < setup.shortTrigger
bool shortBelowConfirm = hasShort and not na(setup.shortConfirm) and close < setup.shortConfirm
bool longTwoCloseAcceptance = hasLong and f_accepted(longAboveTrigger, acceptanceBars)
bool shortTwoCloseAcceptance = hasShort and f_accepted(shortBelowTrigger, acceptanceBars)
bool longConfirmAcceptance = hasLong and longAboveConfirm and (unreliableChartVolume or not na(rvol) and rvol >= minimumRVOL) and longImpulse
bool shortConfirmAcceptance = hasShort and shortBelowConfirm and (unreliableChartVolume or not na(rvol) and rvol >= minimumRVOL) and shortImpulse
bool longAccepted = longTwoCloseAcceptance or longConfirmAcceptance
bool shortAccepted = shortTwoCloseAcceptance or shortConfirmAcceptance

bool longTriggerCross = hasLong and ta.crossover(close, setup.longTrigger)
bool shortTriggerCross = hasShort and ta.crossunder(close, setup.shortTrigger)
int barsSinceLongCross = nz(ta.barssince(longTriggerCross), 100000)
int barsSinceShortCross = nz(ta.barssince(shortTriggerCross), 100000)
float retestTol = dailyAtr * retestToleranceATR
bool longRetest = hasLong and barsSinceLongCross <= retestWindowBars and low <= setup.longTrigger + retestTol and close > setup.longTrigger
bool shortRetest = hasShort and barsSinceShortCross <= retestWindowBars and high >= setup.shortTrigger - retestTol and close < setup.shortTrigger

bool longTouchedSupply = hasShort and f_inBand(setup.shortZoneLo, setup.shortZoneHi)
bool shortTouchedDemand = hasLong and f_inBand(setup.longZoneLo, setup.longZoneHi)
var int lastShortSupplyTouch = na
var int lastLongDemandTouch = na
if newRTH
    lastShortSupplyTouch := na
    lastLongDemandTouch := na
if longTouchedSupply
    lastShortSupplyTouch := bar_index
if shortTouchedDemand
    lastLongDemandTouch := bar_index
bool failedReclaimShortReady = hasShort and not na(lastShortSupplyTouch) and bar_index - lastShortSupplyTouch <= failedReclaimWindowBars
bool controlledPullbackLongReady = hasLong and not na(lastLongDemandTouch) and bar_index - lastLongDemandTouch <= retestWindowBars

bool expansionLong = allowExpansionWithoutRetest and not na(rvol) and rvol >= expansionRVOL and longImpulse
bool expansionShort = allowExpansionWithoutRetest and not na(rvol) and rvol >= expansionRVOL and shortImpulse
bool longEntryGeometry = longAccepted and (longRetest or controlledPullbackLongReady or expansionLong or longConfirmAcceptance)
bool shortEntryGeometry = shortAccepted and (shortRetest or failedReclaimShortReady or expansionShort or shortConfirmAcceptance)

bool longVWAPOk = not requireVWAP or close > vwapValue
bool shortVWAPOk = not requireVWAP or close < vwapValue
bool longMarketGateOk = not requireMarketGate or marketLongOk
bool shortMarketGateOk = not requireMarketGate or marketShortOk
bool longRelativeOk = not requireRelativeStrength or relativeLongOk or mappedIndex or mappedVol or setup.eventName
bool shortRelativeOk = not requireRelativeStrength or relativeShortOk or mappedIndex or mappedVol or setup.eventName
bool longRVOLOk = not requireRVOL or unreliableChartVolume or not na(rvol) and rvol >= minimumRVOL
bool shortRVOLOk = not requireRVOL or unreliableChartVolume or not na(rvol) and rvol >= minimumRVOL
bool longCloudGate = not useRipsterInSignals or cloudLongOk
bool shortCloudGate = not useRipsterInSignals or cloudShortOk
bool longMomentumGate = longRSIOk and longEMAOk
bool shortMomentumGate = shortRSIOk and shortEMAOk
bool longStratGate = stratLongOk
bool shortStratGate = stratShortOk

float longRiskDistance = hasLong ? math.abs(setup.longTrigger - setup.longInvalid) : na
float shortRiskDistance = hasShort ? math.abs(setup.shortInvalid - setup.shortTrigger) : na
float longExpectedR = hasLong and longRiskDistance > 0 ? math.abs(setup.longT1 - setup.longTrigger) / longRiskDistance : na
float shortExpectedR = hasShort and shortRiskDistance > 0 ? math.abs(setup.shortTrigger - setup.shortT1) / shortRiskDistance : na
bool indexOrVolMap = f_isIndexFamily(sym)
bool longROk = not requireExpectedR or indexOrVolMap or setup.eventName or not na(longExpectedR) and longExpectedR >= minimumExpectedR
bool shortROk = not requireExpectedR or indexOrVolMap or setup.eventName or not na(shortExpectedR) and shortExpectedR >= minimumExpectedR
bool longNoChase = hasLong and close - setup.longTrigger <= dailyAtr * maxChaseATR
bool shortNoChase = hasShort and setup.shortTrigger - close <= dailyAtr * maxChaseATR

float interactionDistance = dailyAtr * surfaceApproachATR
int longInteractionState = f_levelInteraction(setup.longTrigger, true, longAccepted, operationalIntegrityReady, interactionDistance)
int shortInteractionState = f_levelInteraction(setup.shortTrigger, false, shortAccepted, operationalIntegrityReady, interactionDistance)
bool longSurfaceOk = not useSurfaceDirectionGate or compositeSurface >= surfaceDirectionThreshold and structuralSurface >= -0.05
bool shortSurfaceOk = not useSurfaceDirectionGate or compositeSurface <= -surfaceDirectionThreshold and structuralSurface <= 0.05

var bool mapBrokenSession = false
if newRTH
    mapBrokenSession := false
bool singleLongOnly = hasLong and not hasShort
bool singleShortOnly = hasShort and not hasLong
if inRTH and not openingFreeze and not eventRemapActive
    if singleLongOnly and not na(setup.longHardInvalid) and close < setup.longHardInvalid
        mapBrokenSession := true
    if singleShortOnly and not na(setup.shortHardInvalid) and close > setup.shortHardInvalid
        mapBrokenSession := true

bool hardSessionBlock = not mapFresh or not operationalIntegrityReady or macroFreeze or openingFreeze or noNewRisk or eventRemapWaiting or mapBrokenSession or not bankOpeningReady
bool entryWindowOk = (inRTH or preOpenExtended) and not hardSessionBlock

int longScore = int(math.min(100.0,
     setup.baseScore * 0.18 +
     (longAccepted ? 11 : 0) +
     (longEntryGeometry ? 11 : 0) +
     (longCloudGate ? 9 : 0) +
     (longEMAOk ? 8 : 0) +
     (longRSIOk ? 7 : 0) +
     (longInternalsOk ? 10 : 0) +
     (longVWAPOk ? 7 : 0) +
     (longMarketGateOk ? 10 : 0) +
     (longRelativeOk ? 6 : 0) +
     (longRVOLOk ? 6 : 0) +
     (longROk ? 5 : 0) +
     (longNoChase ? 5 : 0) +
     (longStratGate ? 5 : 0) +
     (longSurfaceOk ? 6 : 0) +
     (operationalIntegrityReady ? 4 : 0)))

int shortScore = int(math.min(100.0,
     setup.baseScore * 0.18 +
     (shortAccepted ? 11 : 0) +
     (shortEntryGeometry ? 11 : 0) +
     (shortCloudGate ? 9 : 0) +
     (shortEMAOk ? 8 : 0) +
     (shortRSIOk ? 7 : 0) +
     (shortInternalsOk ? 10 : 0) +
     (shortVWAPOk ? 7 : 0) +
     (shortMarketGateOk ? 10 : 0) +
     (shortRelativeOk ? 6 : 0) +
     (shortRVOLOk ? 6 : 0) +
     (shortROk ? 5 : 0) +
     (shortNoChase ? 5 : 0) +
     (shortStratGate ? 5 : 0) +
     (shortSurfaceOk ? 6 : 0) +
     (operationalIntegrityReady ? 4 : 0)))

int scoreThreshold = entryStrictness == "Balanced" ? 62 : entryStrictness == "Institutional" ? 74 : 84
bool longHardGates = entryWindowOk and operationalIntegrityReady and longAccepted and longEntryGeometry and longCloudGate and longMomentumGate and longInternalsOk and longVWAPOk and longMarketGateOk and longRelativeOk and longRVOLOk and longROk and longNoChase and longStratGate and longSurfaceOk and not setup.watchOnly
bool shortHardGates = entryWindowOk and operationalIntegrityReady and shortAccepted and shortEntryGeometry and shortCloudGate and shortMomentumGate and shortInternalsOk and shortVWAPOk and shortMarketGateOk and shortRelativeOk and shortRVOLOk and shortROk and shortNoChase and shortStratGate and shortSurfaceOk and not setup.watchOnly

var bool longFiredThisSession = false
var bool shortFiredThisSession = false
var int lastLongSignalBar = na
var int lastShortSignalBar = na
if newRTH
    longFiredThisSession := false
    shortFiredThisSession := false
    lastLongSignalBar := na
    lastShortSignalBar := na

bool longCooldownOk = na(lastLongSignalBar) or bar_index - lastLongSignalBar >= signalCooldownBars
bool shortCooldownOk = na(lastShortSignalBar) or bar_index - lastShortSignalBar >= signalCooldownBars
bool rawLongSignal = longHardGates and longScore >= scoreThreshold and longCooldownOk and (not oneSignalPerSide or not longFiredThisSession)
bool rawShortSignal = shortHardGates and shortScore >= scoreThreshold and shortCooldownOk and (not oneSignalPerSide or not shortFiredThisSession)
bool longSignal = rawLongSignal and (not rawShortSignal or longScore >= shortScore)
bool shortSignal = rawShortSignal and (not rawLongSignal or shortScore > longScore)

if longSignal
    longFiredThisSession := true
    lastLongSignalBar := bar_index
if shortSignal
    shortFiredThisSession := true
    lastShortSignalBar := bar_index

bool longArmed = hasLong and longAccepted and longScore >= scoreThreshold - 12 and not longSignal
bool shortArmed = hasShort and shortAccepted and shortScore >= scoreThreshold - 12 and not shortSignal

bool longReadyHighlight = highlightSetupReady and longArmed and longInternalsOk and longEMAOk and longRSIOk
bool shortReadyHighlight = highlightSetupReady and shortArmed and shortInternalsOk and shortEMAOk and shortRSIOk
color surfaceHighlightColor = showSurfaceStateHighlighter and operationalIntegrityReady and not surfaceConflict ? compositeSurface >= 0.55 ? color.new(cLong, 94) : compositeSurface <= -0.55 ? color.new(cShort, 94) : na : na
color signalHighlightColor = longSignal ? color.new(color.rgb(0, 220, 150), math.max(65, highlighterOpacity - 12)) : shortSignal ? color.new(color.rgb(255, 45, 90), math.max(65, highlighterOpacity - 12)) : longReadyHighlight and not shortReadyHighlight ? color.new(color.rgb(40, 215, 150), highlighterOpacity) : shortReadyHighlight and not longReadyHighlight ? color.new(color.rgb(255, 75, 105), highlighterOpacity) : longReadyHighlight and shortReadyHighlight ? color.new(color.rgb(255, 205, 55), highlighterOpacity) : surfaceHighlightColor
bgcolor(showSignalHighlighter or showSurfaceStateHighlighter ? signalHighlightColor : na, title = "Schmidt Signal / Surface Highlighter")
plotshape(showSignalArrows and longSignal, title = "Clear Long Signal", style = shape.labelup, location = location.belowbar, color = color.rgb(0, 190, 125), text = "LONG", textcolor = color.white, size = size.small)
plotshape(showSignalArrows and shortSignal, title = "Clear Short Signal", style = shape.labeldown, location = location.abovebar, color = color.rgb(225, 45, 75), text = "SHORT", textcolor = color.white, size = size.small)

// Persistent outcome object for the current chart/session.
var int tradeSide = 0
var bool tradeActive = false
var float tradeEntry = na
var float tradeRisk = na
var float tradeMFE = 0.0
var float tradeMAE = 0.0
var bool tradeT1 = false
var bool tradeT2 = false
var bool tradeT3 = false
var bool tradeInvalid = false
var bool tradeBEExit = false
var int tradeT1Bar = na
var int tradeSignalBar = na
bool newT1Event = false
bool newT2Event = false
bool newT3Event = false
bool newInvalidEvent = false
bool newBEEvent = false

if newRTH
    tradeSide := 0
    tradeActive := false
    tradeEntry := na
    tradeRisk := na
    tradeMFE := 0.0
    tradeMAE := 0.0
    tradeT1 := false
    tradeT2 := false
    tradeT3 := false
    tradeInvalid := false
    tradeBEExit := false
    tradeT1Bar := na
    tradeSignalBar := na

if longSignal
    tradeSide := 1
    tradeActive := true
    tradeEntry := close
    tradeRisk := math.max(math.abs(close - setup.longInvalid), syminfo.mintick)
    tradeMFE := 0.0
    tradeMAE := 0.0
    tradeT1 := false
    tradeT2 := false
    tradeT3 := false
    tradeInvalid := false
    tradeBEExit := false
    tradeT1Bar := na
    tradeSignalBar := bar_index

if shortSignal
    tradeSide := -1
    tradeActive := true
    tradeEntry := close
    tradeRisk := math.max(math.abs(setup.shortInvalid - close), syminfo.mintick)
    tradeMFE := 0.0
    tradeMAE := 0.0
    tradeT1 := false
    tradeT2 := false
    tradeT3 := false
    tradeInvalid := false
    tradeBEExit := false
    tradeT1Bar := na
    tradeSignalBar := bar_index

if tradeActive and tradeSide == 1
    tradeMFE := math.max(tradeMFE, high - tradeEntry)
    tradeMAE := math.max(tradeMAE, tradeEntry - low)
    if not tradeT1 and high >= setup.longT1
        tradeT1 := true
        tradeT1Bar := bar_index
        newT1Event := true
    if tradeT1 and not tradeT2 and high >= setup.longT2
        tradeT2 := true
        newT2Event := true
    if tradeT2 and not tradeT3 and high >= setup.longT3
        tradeT3 := true
        tradeActive := false
        newT3Event := true
    if not tradeT1 and low <= setup.longInvalid
        tradeInvalid := true
        tradeActive := false
        newInvalidEvent := true
    if tradeT1 and not tradeT3 and not na(tradeT1Bar) and bar_index > tradeT1Bar and low <= tradeEntry
        tradeBEExit := true
        tradeActive := false
        newBEEvent := true

if tradeActive and tradeSide == -1
    tradeMFE := math.max(tradeMFE, tradeEntry - low)
    tradeMAE := math.max(tradeMAE, high - tradeEntry)
    if not tradeT1 and low <= setup.shortT1
        tradeT1 := true
        tradeT1Bar := bar_index
        newT1Event := true
    if tradeT1 and not tradeT2 and low <= setup.shortT2
        tradeT2 := true
        newT2Event := true
    if tradeT2 and not tradeT3 and low <= setup.shortT3
        tradeT3 := true
        tradeActive := false
        newT3Event := true
    if not tradeT1 and high >= setup.shortInvalid
        tradeInvalid := true
        tradeActive := false
        newInvalidEvent := true
    if tradeT1 and not tradeT3 and not na(tradeT1Bar) and bar_index > tradeT1Bar and high >= tradeEntry
        tradeBEExit := true
        tradeActive := false
        newBEEvent := true

float currentTradeR = tradeSide == 1 and not na(tradeRisk) ? (close - tradeEntry) / tradeRisk : tradeSide == -1 and not na(tradeRisk) ? (tradeEntry - close) / tradeRisk : na
float mfeR = not na(tradeRisk) and tradeRisk > 0 ? tradeMFE / tradeRisk : na
float maeR = not na(tradeRisk) and tradeRisk > 0 ? tradeMAE / tradeRisk : na
bool mapComplete = tradeT3

float riskSize = hardSessionBlock ? 0.0 : preOpenExtended ? firstThirtyRisk : firstThirty ? firstThirtyRisk : vixClose > 20.0 or frontVolStress ? stressRisk : lateRiskWindow ? lateRisk : normalRisk
bool techCluster = mappedSemi or mappedGrowth or mappedSoftware or mappedHighBeta
if techCluster and qqqClose < 708
    riskSize := math.min(riskSize, 0.50)
if mappedSemi and smhClose < 585
    riskSize := math.min(riskSize, 0.50)
if negativeGammaChop
    riskSize := math.min(riskSize, 0.75)
string sizeText = riskSize <= 0 ? "NO TRADE" : str.tostring(riskSize, "#.##") + "R"
string phaseText = macroFreeze ? "LEI FREEZE 9:55-10:10" : mandatoryRefreshWindow ? "REFRESH 8:20-9:15" : preOpenExtended ? "PREOPEN 0.5R" : openingFreeze ? "OPENING RANGE" : eventRemapWaiting ? "EVENT REMAP WAIT" : noNewRisk ? "NO NEW RISK" : firstThirty ? "0.5R ACCEPTANCE TEST" : lateRiskWindow ? "LATE 0.75R" : "NORMAL"

bool longTriggerPending = hasLong and longAboveTrigger and not longAboveConfirm
bool shortTriggerPending = hasShort and shortBelowTrigger and not shortBelowConfirm
string lifecycleText = not mapFresh ? "MAP STALE" : not operationalIntegrityReady ? "DATA QUALITY BLOCK" : eventRemapWaiting ? "MAP BROKEN — WAIT OR" : mapBrokenSession ? "MAP BROKEN — REMAP" : tradeInvalid ? "INVALIDATED" : tradeBEExit ? "BREAKEVEN EXIT" : tradeT3 ? "T3 HIT — NO CHASE" : tradeT2 ? "T2 HIT — TRAIL" : tradeT1 ? "T1 HIT — STOP BE" : tradeActive and tradeSide == 1 ? (bar_index == tradeSignalBar ? "LONG FIRED" : "TRADE LIVE — LONG") : tradeActive and tradeSide == -1 ? (bar_index == tradeSignalBar ? "SHORT FIRED" : "TRADE LIVE — SHORT") : longConfirmAcceptance and not longHardGates ? "LONG CONFIRM — WAIT RETEST" : shortConfirmAcceptance and not shortHardGates ? "SHORT CONFIRM — WAIT RETEST" : longTriggerPending ? "LONG TRIGGER — CONFIRM PENDING" : shortTriggerPending ? "SHORT TRIGGER — CONFIRM PENDING" : longArmed and shortArmed ? "TWO-WAY SETUP FORMING" : longArmed ? "LONG SETUP FORMING" : shortArmed ? "SHORT SETUP FORMING" : setup.watchOnly ? "WATCH ONLY" : hardSessionBlock ? phaseText : "WATCH"
string vixStateText = vixClose < 18.50 ? "VOL SUPPRESSED" : vixClose < 19.0 ? "VOL WARNING" : vixClose < 20.0 ? "RISK REPRICING" : "VOL EXPANSION 20+"
string actionText = mappedVol ? vixStateText : lifecycleText
color actionColor = mappedVol ? (vixClose < 18.50 ? cLong : vixClose >= 20.0 ? cShort : cGold) : tradeT3 or tradeT2 or tradeT1 or tradeActive and tradeSide == 1 or longSignal ? cLong : tradeInvalid or mapBrokenSession or eventRemapWaiting or tradeActive and tradeSide == -1 or shortSignal ? cShort : longArmed or shortArmed or longTriggerPending or shortTriggerPending ? cGold : cNeutral
string outcomeText = tradeInvalid ? "LOSS / INVALID" : tradeBEExit ? "SCRATCH / BE" : tradeT3 ? "MAP COMPLETE" : tradeT2 ? "T2 ACHIEVED" : tradeT1 ? "T1 ACHIEVED" : tradeActive ? "LIVE" : tradeSide != 0 ? "CLOSED" : "NO TRADE"
string nextInstruction = tradeT3 ? "NO CHASE — MAP COMPLETE" : tradeT2 ? "TRAIL REMAINDER" : tradeT1 ? "STOP TO BREAKEVEN" : tradeActive ? "MANAGE TO TP1" : tradeInvalid or mapBrokenSession ? "REMOVE / REMAP" : eventRemapWaiting ? "WAIT FOR OPENING RANGE" : longConfirmAcceptance or shortConfirmAcceptance ? "WAIT FOR RETEST" : longTriggerPending or shortTriggerPending ? "WAIT FOR CONFIRMATION" : retailUI ? "DO NOTHING UNTIL TRIGGER" : "MONITOR CONTROL BAND"
string mapModeText = eventRemapActive ? "EVENT OR MAP" : eventRemapWaiting ? "REMAP WAIT" : setup.mapped ? "DOSSIER" : "GENERIC"
// ============================================================================
// LOCKED LEVELS, ADAPTIVE PRUNING AND ACTION ZONES
// ============================================================================

var array<line> levelLines = array.new_line()
var array<label> levelLabels = array.new_label()
var array<box> zoneBoxes = array.new_box()
var array<float> seenPrices = array.new_float()
var array<int> seenPriority = array.new_int()

f_clearObjects() =>
    if array.size(levelLines) > 0
        for i = 0 to array.size(levelLines) - 1
            line.delete(array.get(levelLines, i))
    if array.size(levelLabels) > 0
        for i = 0 to array.size(levelLabels) - 1
            label.delete(array.get(levelLabels, i))
    if array.size(zoneBoxes) > 0
        for i = 0 to array.size(zoneBoxes) - 1
            box.delete(array.get(zoneBoxes, i))
    array.clear(levelLines)
    array.clear(levelLabels)
    array.clear(zoneBoxes)
    array.clear(seenPrices)
    array.clear(seenPriority)

f_seenPrice(float price, int priority) =>
    bool seen = false
    if array.size(seenPrices) > 0
        for i = 0 to array.size(seenPrices) - 1
            if math.abs(array.get(seenPrices, i) - price) <= syminfo.mintick * 0.50 and array.get(seenPriority, i) >= priority
                seen := true
    seen

float levelRadius = levelVisibilityMode == "1.5 ATR" ? dailyAtr * 1.50 : levelVisibilityMode == "2.5 ATR" ? dailyAtr * 2.50 : levelVisibilityMode == "5% of Price" ? close * 0.05 : levelVisibilityMode == "All" ? 1e20 : math.max(dailyAtr * 2.0, close * 0.025)
f_levelVisible(float price) =>
    not na(price) and (levelVisibilityMode == "All" or math.abs(price - close) <= levelRadius)

f_drawLevel(float price, string badge, string role, bool longSide, bool major, bool completed) =>
    if showDecisionLevels and f_levelVisible(price) and (showCompletedLevels or not completed)
        int priority = f_rolePriority(role)
        if not f_seenPrice(price, priority)
            color clr = f_roleColor(role, longSide)
            int width = major ? levelLineWidth : 1
            int leftBar = math.max(0, bar_index - levelAnchorBars)
            line ln = line.new(leftBar, price, bar_index + levelLabelOffset, price, xloc = xloc.bar_index, extend = extend.none, color = clr, style = f_roleStyle(role), width = width)
            array.push(levelLines, ln)
            array.push(seenPrices, price)
            array.push(seenPriority, priority)
            if effectiveLevelLabels
                string txt = badge + "  " + f_fmt(price)
                label lb = label.new(bar_index + levelLabelOffset, price, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = clr, textcolor = color.white, size = size.tiny)
                array.push(levelLabels, lb)

f_drawZone(float lo, float hi, bool longSide, string txt, bool autoAllowed) =>
    if effectiveActionZones and actionZoneMode != "Off" and not na(lo) and not na(hi) and not mapBrokenSession and not eventRemapWaiting and not mapComplete
        bool allowed = actionZoneMode == "Both" or actionZoneMode == "Auto" and autoAllowed or actionZoneMode == "Long" and longSide or actionZoneMode == "Short" and not longSide
        if allowed and (f_levelVisible(lo) or f_levelVisible(hi))
            color clr = longSide ? cZoneLong : cZoneShort
            int leftBar = math.max(0, bar_index - math.min(levelAnchorBars, 12))
            box bx = box.new(leftBar, math.max(lo, hi), bar_index + levelLabelOffset, math.min(lo, hi), xloc = xloc.bar_index, border_color = color.new(clr, 25), bgcolor = color.new(clr, zoneOpacity), text = retailUI ? txt : "", text_color = color.new(color.white, 10), text_size = size.tiny)
            array.push(zoneBoxes, bx)

float longZoneDistance = hasLong ? math.abs(close - setup.longTrigger) : 1e10
float shortZoneDistance = hasShort ? math.abs(close - setup.shortTrigger) : 1e10
int nearestSide = longZoneDistance <= shortZoneDistance ? 1 : -1
int displaySide = tradeSide != 0 ? tradeSide : longArmed and not shortArmed ? 1 : shortArmed and not longArmed ? -1 : longTriggerPending and not shortTriggerPending ? 1 : shortTriggerPending and not longTriggerPending ? -1 : hasLong and not hasShort ? 1 : hasShort and not hasLong ? -1 : nearestSide
bool autoBothSides = inactiveSideMode == "Show Both" or inactiveSideMode == "Auto" and (mappedIndex or mappedVol)
bool drawLongSide = hasLong and (not hasShort or autoBothSides or inactiveSideMode != "Show Both" and displaySide == 1)
bool drawShortSide = hasShort and (not hasLong or autoBothSides or inactiveSideMode != "Show Both" and displaySide == -1)
bool autoShowLongZone = drawLongSide and (not drawShortSide or displaySide == 1)
bool autoShowShortZone = drawShortSide and (not drawLongSide or displaySide == -1)

float nextLongTarget = not tradeT1 or tradeSide != 1 ? setup.longT1 : not tradeT2 ? setup.longT2 : not tradeT3 ? setup.longT3 : na
float nextShortTarget = not tradeT1 or tradeSide != -1 ? setup.shortT1 : not tradeT2 ? setup.shortT2 : not tradeT3 ? setup.shortT3 : na
bool levelMapAllowed = setup.active and not ((mapBrokenSession or eventRemapWaiting) and hideBrokenMapLevels)

if barstate.islast
    f_clearObjects()
    if levelMapAllowed
        if drawLongSide
            f_drawLevel(setup.longHardInvalid, "FAIL", "HARD", true, true, false)
            f_drawLevel(setup.longInvalid, tradeT1 and tradeSide == 1 ? "BE STOP" : "STOP", "INVALID", true, true, false)
            f_drawLevel(setup.longTrigger, "ENTRY", "TRIGGER", true, true, false)
            f_drawLevel(setup.longConfirm, "GO", "CONFIRM", true, true, false)
            if showOnlyNextTarget
                f_drawLevel(nextLongTarget, tradeT1 and tradeSide == 1 ? (tradeT2 ? "T3" : "T2") : "T1", "TARGET", true, true, false)
            else
                f_drawLevel(setup.longT1, "T1", "TARGET", true, true, tradeT1 and tradeSide == 1)
                f_drawLevel(setup.longT2, "T2", "TARGET", true, false, tradeT2 and tradeSide == 1)
                f_drawLevel(setup.longT3, "T3", "TARGET", true, false, tradeT3 and tradeSide == 1)
            f_drawZone(setup.longZoneLo, setup.longZoneHi, true, "BUY ZONE — WAIT FOR ACCEPTANCE / RETEST", autoShowLongZone)
        if drawShortSide
            f_drawLevel(setup.shortHardInvalid, "FAIL", "HARD", false, true, false)
            f_drawLevel(setup.shortInvalid, tradeT1 and tradeSide == -1 ? "BE STOP" : "STOP", "INVALID", false, true, false)
            f_drawLevel(setup.shortTrigger, "ENTRY", "TRIGGER", false, true, false)
            f_drawLevel(setup.shortConfirm, "GO", "CONFIRM", false, true, false)
            if showOnlyNextTarget
                f_drawLevel(nextShortTarget, tradeT1 and tradeSide == -1 ? (tradeT2 ? "T3" : "T2") : "T1", "TARGET", false, true, false)
            else
                f_drawLevel(setup.shortT1, "T1", "TARGET", false, true, tradeT1 and tradeSide == -1)
                f_drawLevel(setup.shortT2, "T2", "TARGET", false, false, tradeT2 and tradeSide == -1)
                f_drawLevel(setup.shortT3, "T3", "TARGET", false, false, tradeT3 and tradeSide == -1)
            f_drawZone(setup.shortZoneLo, setup.shortZoneHi, false, "SHORT ZONE — FAILED RECLAIM / BREAKDOWN ONLY", autoShowShortZone)
// ============================================================================
// SIGNAL, LIFECYCLE AND OUTCOME MARKERS
// ============================================================================

if effectiveSignalLabels and not showSignalArrows and longSignal
    label.new(bar_index, low, "LONG LIVE\nQ " + str.tostring(longScore), xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up, color = cLong, textcolor = color.white, size = size.tiny)
if effectiveSignalLabels and not showSignalArrows and shortSignal
    label.new(bar_index, high, "SHORT LIVE\nQ " + str.tostring(shortScore), xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = cShort, textcolor = color.white, size = size.tiny)
if showTargetLabels and newT1Event
    label.new(bar_index, tradeSide == 1 ? high : low, "T1 HIT\nSTOP BE", xloc = xloc.bar_index, yloc = yloc.price, style = tradeSide == 1 ? label.style_label_down : label.style_label_up, color = cTarget, textcolor = color.white, size = size.tiny)
if showTargetLabels and newT2Event
    label.new(bar_index, tradeSide == 1 ? high : low, "T2 HIT\nTRAIL", xloc = xloc.bar_index, yloc = yloc.price, style = tradeSide == 1 ? label.style_label_down : label.style_label_up, color = cTarget, textcolor = color.white, size = size.tiny)
if showTargetLabels and newT3Event
    label.new(bar_index, tradeSide == 1 ? high : low, "T3 HIT\nNO CHASE", xloc = xloc.bar_index, yloc = yloc.price, style = tradeSide == 1 ? label.style_label_down : label.style_label_up, color = cTarget, textcolor = color.white, size = size.tiny)
if showTargetLabels and newInvalidEvent
    label.new(bar_index, tradeSide == 1 ? low : high, "INVALIDATED", xloc = xloc.bar_index, yloc = yloc.price, style = tradeSide == 1 ? label.style_label_up : label.style_label_down, color = cInvalid, textcolor = color.white, size = size.tiny)
if showTargetLabels and newBEEvent
    label.new(bar_index, tradeEntry, "BREAKEVEN EXIT", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = cGold, textcolor = color.white, size = size.tiny)
bool mapBrokenEvent = mapBrokenSession and not mapBrokenSession[1]
if showTargetLabels and mapBrokenEvent
    label.new(bar_index, close, "MAP BROKEN\nREMAP REQUIRED", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = cInvalid, textcolor = color.white, size = size.tiny)
if showTargetLabels and newRTH and eventRemapNeeded
    label.new(bar_index, open, "EVENT GAP\nWAIT OPENING RANGE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = cGold, textcolor = color.white, size = size.tiny)

color candleColor = cloudLongOk and close > vwapValue ? color.new(cLong, 0) : cloudShortOk and close < vwapValue ? color.new(cShort, 0) : na
barcolor(showSignalHighlighter and longSignal ? color.rgb(0, 205, 135) : showSignalHighlighter and shortSignal ? color.rgb(235, 45, 75) : showCandleBias ? candleColor : na, title = "Signal / Bias Bar Color")

// ============================================================================
// DIRECTION-CONSISTENT DASHBOARDS
// ============================================================================

var table currentDash = table.new(f_tablePos(currentDashPos), 3, 11, frame_color = color.rgb(8, 12, 18), frame_width = 1, border_color = color.rgb(50, 62, 78), border_width = 1)
var table ladderDash = table.new(f_tablePos(ladderPos), 4, 9, frame_color = color.rgb(8, 12, 18), frame_width = 1, border_color = color.rgb(50, 62, 78), border_width = 1)
var table focusDash = table.new(f_tablePos(focusBoardPos), 3, 12, frame_color = color.rgb(8, 12, 18), frame_width = 1, border_color = color.rgb(50, 62, 78), border_width = 1)

string activeCurrentCorner = effectiveCurrentDashboard and setup.active ? currentDashPos : ""
string resolvedCurrentCorner = currentDashPos
string resolvedLadderCorner = autoPreventDashboardOverlap ? f_resolveCorner(ladderPos, activeCurrentCorner, "") : ladderPos
string activeLadderCorner = effectiveDecisionLadder and setup.active ? resolvedLadderCorner : ""
string resolvedFocusCorner = autoPreventDashboardOverlap ? f_resolveCorner(focusBoardPos, activeCurrentCorner, activeLadderCorner) : focusBoardPos

if barstate.islast
    table.set_position(currentDash, f_tablePos(resolvedCurrentCorner))
    table.set_position(ladderDash, f_tablePos(resolvedLadderCorner))
    table.set_position(focusDash, f_tablePos(resolvedFocusCorner))

color headerBg = color.rgb(9, 17, 29)
color keyBg = color.rgb(20, 30, 44)
color neutralBg = color.rgb(31, 38, 50)
color passBg = color.rgb(17, 83, 68)
color bearBg = color.rgb(112, 33, 43)
color waitBg = color.rgb(103, 72, 24)
color tableText = color.rgb(235, 240, 247)

f_cellCurrent(int c, int r, string txt, color bg, color tx) =>
    table.cell(currentDash, c, r, txt, bgcolor = bg, text_color = tx, text_size = f_textSize(textSizeOpt))

f_cellLadder(int c, int r, string txt, color bg, color tx) =>
    table.cell(ladderDash, c, r, txt, bgcolor = bg, text_color = tx, text_size = f_textSize(textSizeOpt))

f_cellFocus(int c, int r, string txt, color bg, color tx) =>
    table.cell(focusDash, c, r, txt, bgcolor = bg, text_color = tx, text_size = f_textSize(textSizeOpt))

int directionalScore = displaySide == -1 ? shortScore : longScore
string scoreText = str.tostring(directionalScore) + "/100"
string directionText = hasLong and hasShort ? "TWO-WAY" : hasLong ? "LONG" : hasShort ? "SHORT" : "NONE"
string relativeText = str.tostring(relativeEdge, "#.##") + "%"
string rvolText = na(rvol) ? "N/A" : str.tostring(rvol, "#.##")
float selectedExpectedR = displaySide == -1 ? shortExpectedR : longExpectedR
string expectedRText = na(selectedExpectedR) ? "N/A" : str.tostring(selectedExpectedR, "#.##") + "R"
string currentRText = na(currentTradeR) ? "N/A" : str.tostring(currentTradeR, "#.##") + "R"
string mfeText = na(mfeR) ? "N/A" : str.tostring(mfeR, "#.##") + "R"
string maeText = na(maeR) ? "N/A" : str.tostring(maeR, "#.##") + "R"
string gateText = hardSessionBlock ? "BLOCKED" : displaySide == -1 ? marketShortOk ? "SHORT PASS" : "WAIT" : marketLongOk ? "LONG PASS" : "WAIT"
color gateBg = gateText == "LONG PASS" ? passBg : gateText == "SHORT PASS" ? bearBg : gateText == "BLOCKED" ? bearBg : waitBg
color stateBg = actionColor

bool ladderTwoWay = hasLong and hasShort and tradeSide == 0 and not longArmed and not shortArmed and not longTriggerPending and not shortTriggerPending
float sideTrigger = displaySide == -1 ? setup.shortTrigger : setup.longTrigger
float sideConfirm = displaySide == -1 ? setup.shortConfirm : setup.longConfirm
float sideInvalid = displaySide == -1 ? setup.shortInvalid : setup.longInvalid
float sideHard = displaySide == -1 ? setup.shortHardInvalid : setup.longHardInvalid
float sideNextTarget = displaySide == -1 ? nextShortTarget : nextLongTarget
float sideT1 = displaySide == -1 ? setup.shortT1 : setup.longT1
float sideT2 = displaySide == -1 ? setup.shortT2 : setup.longT2
float sideT3 = displaySide == -1 ? setup.shortT3 : setup.longT3
string sideVehicle = displaySide == -1 ? setup.shortVehicle : setup.longVehicle
string sideMode = displaySide == -1 ? setup.shortMode : setup.longMode
string sideLabel = displaySide == -1 ? "SHORT" : "LONG"
int sideInteractionState = displaySide == -1 ? shortInteractionState : longInteractionState
string sideInteractionText = f_interactionText(sideInteractionState)

string qGate = qqqClose >= 710 ? "Q REPAIR+" : qqqClose >= 708 ? "Q REPAIR" : qqqClose < 691 ? "Q FAIL" : "Q 691-708"
string sGate = smhClose >= 590 ? "S REPAIR+" : smhClose >= 585 ? "S REPAIR" : smhClose < 550 ? "S TRAPDOOR" : smhClose < 567.5 ? "S FAIL" : "S 567.5-585"
string iGate = iwmClose >= 300 ? "I REPAIR+" : iwmClose >= 297 ? "I REPAIR" : iwmClose < 292 ? "I FAIL" : "I 292-297"
string vGate = vixClose < 18.50 ? "V CALM" : vixClose < 19.0 ? "V WARN" : vixClose >= 20.0 ? "V ESCALATE" : "V RISK"
string gateStackText = qGate + " | " + sGate + " | " + iGate + " | " + vGate
string internalPulseText = internalsText + " " + str.tostring(internalsScore) + " | UV " + (na(upVolumeShare) ? "N/A" : str.tostring(upVolumeShare * 100.0, "#.0") + "%") + " | TICK " + (na(tickSmooth) ? "N/A" : str.tostring(tickSmooth, "#"))
string volatilityPulseText = volCurveText + " | 1D/9D " + (na(vix1d9dRatio) ? "N/A" : str.tostring(vix1d9dRatio, "#.00"))

string blockerText = not mapFresh ? "MAP EXPIRED" : not operationalIntegrityReady ? "OPERATIONAL INTEGRITY BELOW " + str.tostring(minimumOperationalIntegrity, "#.0") : eventRemapWaiting ? "WAIT FOR OPENING RANGE" : mapBrokenSession ? "STATIC MAP BROKEN" : setup.watchOnly ? "WATCH ONLY — AUTO ENTRY OFF" : hardSessionBlock ? phaseText : displaySide == 1 and not marketLongOk ? "INDEX / SECTOR GATE" : displaySide == -1 and not marketShortOk ? "INDEX / SECTOR GATE" : displaySide == 1 and not longInternalsOk ? "MARKET INTERNALS NOT LONG" : displaySide == -1 and not shortInternalsOk ? "MARKET INTERNALS NOT SHORT" : displaySide == 1 and not longSurfaceOk ? "NATIVE SURFACE NOT LONG" : displaySide == -1 and not shortSurfaceOk ? "NATIVE SURFACE NOT SHORT" : displaySide == 1 and not longEMAOk ? str.tostring(execFastLen) + "/" + str.tostring(execSlowLen) + " EMA NOT LONG" : displaySide == -1 and not shortEMAOk ? str.tostring(execFastLen) + "/" + str.tostring(execSlowLen) + " EMA NOT SHORT" : displaySide == 1 and not longRSIOk ? "RSI MOMENTUM NOT LONG" : displaySide == -1 and not shortRSIOk ? "RSI MOMENTUM NOT SHORT" : displaySide == 1 and not longCloudGate ? "TREND CLOUD NOT ALIGNED" : displaySide == -1 and not shortCloudGate ? "TREND CLOUD NOT ALIGNED" : displaySide == 1 and not longVWAPOk ? "PRICE BELOW VWAP" : displaySide == -1 and not shortVWAPOk ? "PRICE ABOVE VWAP" : displaySide == 1 and not longRelativeOk ? "RELATIVE STRENGTH MISSING" : displaySide == -1 and not shortRelativeOk ? "RELATIVE WEAKNESS MISSING" : displaySide == 1 and not longRVOLOk ? "RVOL BELOW " + str.tostring(minimumRVOL, "#.##") : displaySide == -1 and not shortRVOLOk ? "RVOL BELOW " + str.tostring(minimumRVOL, "#.##") : displaySide == 1 and not longROk ? "TP1 BELOW MINIMUM R" : displaySide == -1 and not shortROk ? "TP1 BELOW MINIMUM R" : displaySide == 1 and not longAccepted ? "TRIGGER NOT ACCEPTED" : displaySide == -1 and not shortAccepted ? "TRIGGER NOT ACCEPTED" : displaySide == 1 and not longEntryGeometry ? "WAIT FOR RETEST / IMPULSE" : displaySide == -1 and not shortEntryGeometry ? "WAIT FOR FAILED RECLAIM" : "ALL REQUIRED GATES READY"

string tradeInstruction = not mapFresh ? "NO TRADE — MAP STALE" : not operationalIntegrityReady ? "NO TRADE — DATA QUALITY" : eventRemapWaiting ? "WAIT — BUILD OPENING RANGE" : mapBrokenSession ? "NO TRADE — REMAP" : tradeInvalid ? "EXIT — SETUP INVALIDATED" : tradeBEExit ? "TRADE CLOSED — BREAKEVEN" : tradeT3 ? "NO CHASE — MAP COMPLETE" : tradeT2 ? "TRAIL RUNNER / NO NEW ENTRY" : tradeT1 ? "TAKE PARTIAL / MOVE STOP BE" : longSignal ? "LONG NOW — USE MAPPED STOP" : shortSignal ? "SHORT NOW — USE MAPPED STOP" : tradeActive and tradeSide == 1 ? "MANAGE LONG TO NEXT TARGET" : tradeActive and tradeSide == -1 ? "MANAGE SHORT TO NEXT TARGET" : longConfirmAcceptance and not longHardGates ? "LONG CONFIRMED — WAIT RETEST" : shortConfirmAcceptance and not shortHardGates ? "SHORT CONFIRMED — WAIT FAILED RECLAIM" : longTriggerPending ? "WAIT FOR LONG CONFIRMATION" : shortTriggerPending ? "WAIT FOR SHORT CONFIRMATION" : longArmed and shortArmed ? "TWO-WAY — WAIT FOR DIRECTION" : longArmed ? "LONG READY — WAIT ENTRY SEQUENCE" : shortArmed ? "SHORT READY — WAIT FAILED RECLAIM" : setup.watchOnly ? "MONITOR ONLY" : hardSessionBlock ? "NO TRADE — " + phaseText : "WAIT FOR MAPPED TRIGGER"

string entryPlanText = sideLabel + " " + f_fmt(sideTrigger) + " → GO " + f_fmt(sideConfirm) + " | " + sideInteractionText
string riskPlanText = "STOP " + f_fmt(sideInvalid) + " | FAIL " + f_fmt(sideHard)
string targetPlanText = "NEXT " + f_fmt(sideNextTarget) + " | T2 " + f_fmt(sideT2)
string trendReadText = cloudText + " | " + (close > vwapValue ? "VWAP+" : "VWAP-")
string tapeReadText = stratText + " | RVOL " + rvolText + " | RS " + relativeText
string qualityText = setup.grade + " | Q " + scoreText + " | ER " + expectedRText
string outcomeReadText = outcomeText + " | R " + currentRText + " | MFE " + mfeText
string momentumReadText = emaText + " | " + rsiText + " | " + cloudText
string vwapReadText = close > vwapValue ? "ABOVE VWAP" : close < vwapValue ? "BELOW VWAP" : "AT VWAP"
string surfaceCompactText = surfaceCoreState == "ACCELERATION UP" ? "ACCEL ↑" : surfaceCoreState == "ACCELERATION DOWN" ? "ACCEL ↓" : surfaceCoreState == "STABILIZATION UP" ? "STABLE ↑" : surfaceCoreState == "STABILIZATION DOWN" ? "STABLE ↓" : surfaceCoreState == "SURFACE CONFLICT" ? "CONFLICT" : surfaceCoreState == "SURFACE BLOCKED" ? "BLOCKED" : "EQUILIBRIUM"
string surfaceReadText = (not inRTH ? "FROZEN | " : "") + surfaceCompactText + " | STRUCT " + str.tostring(structuralSurface, "#.2") + " | HEDGE " + str.tostring(hedgePressureSurface, "#.2")
string integrityReadText = integrityText + " | MI " + str.tostring(effectiveMIScore, "#.0") + "/" + str.tostring(sourceMIScore, "#.0") + (na(internalsAgeMinutes) ? "" : " | AGE " + str.tostring(internalsAgeMinutes, "#.0") + "m")

if barstate.islast and effectiveCurrentDashboard and setup.active
    table.clear(currentDash, 0, 0, 2, 10)
    f_cellCurrent(0, 0, "SCHMIDT v49", headerBg, tableText)
    f_cellCurrent(1, 0, sym + " • " + setup.grade, headerBg, tableText)
    f_cellCurrent(2, 0, actionText, stateBg, color.white)

    f_cellCurrent(0, 1, "DO NOW", keyBg, tableText)
    f_cellCurrent(1, 1, tradeInstruction, stateBg, color.white)
    f_cellCurrent(2, 1, sizeText, riskSize >= 1 ? passBg : riskSize > 0 ? waitBg : bearBg, tableText)

    f_cellCurrent(0, 2, "ENTRY", keyBg, tableText)
    f_cellCurrent(1, 2, entryPlanText, neutralBg, tableText)
    f_cellCurrent(2, 2, sideMode, neutralBg, tableText)

    f_cellCurrent(0, 3, "STOP / TARGET", keyBg, tableText)
    f_cellCurrent(1, 3, riskPlanText, bearBg, tableText)
    f_cellCurrent(2, 3, targetPlanText, passBg, tableText)

    f_cellCurrent(0, 4, "MARKET", keyBg, tableText)
    f_cellCurrent(1, 4, regimeText, regimeColor, tableText)
    f_cellCurrent(2, 4, gateStackText, gateBg, tableText)

    f_cellCurrent(0, 5, "SURFACE", keyBg, tableText)
    f_cellCurrent(1, 5, surfaceReadText, surfaceStateColor, tableText)
    f_cellCurrent(2, 5, integrityReadText, operationalIntegrityReady ? passBg : bearBg, tableText)

    f_cellCurrent(0, 6, "MOMENTUM", keyBg, tableText)
    f_cellCurrent(1, 6, momentumReadText, emaLongMomentum and rsiLongOk ? passBg : emaShortMomentum and rsiShortOk ? bearBg : waitBg, tableText)
    f_cellCurrent(2, 6, showInternalsBadge ? internalPulseText : vwapReadText, internalsScore >= 60 ? passBg : internalsScore <= 40 ? bearBg : waitBg, tableText)

    f_cellCurrent(0, 7, "WHY WAIT", keyBg, tableText)
    f_cellCurrent(1, 7, blockerText, blockerText == "ALL REQUIRED GATES READY" ? passBg : waitBg, tableText)
    f_cellCurrent(2, 7, nextInstruction, stateBg, tableText)

    f_cellCurrent(0, 8, "QUALITY", keyBg, tableText)
    f_cellCurrent(1, 8, qualityText, directionalScore >= scoreThreshold ? passBg : waitBg, tableText)
    f_cellCurrent(2, 8, sideVehicle, neutralBg, tableText)

    if not compactUI
        f_cellCurrent(0, 9, "OUTCOME", keyBg, tableText)
        f_cellCurrent(1, 9, outcomeReadText, tradeInvalid ? bearBg : tradeT1 ? passBg : neutralBg, tableText)
        f_cellCurrent(2, 9, mapModeText, mapFresh ? passBg : bearBg, tableText)
        f_cellCurrent(0, 10, "SESSION", keyBg, tableText)
        f_cellCurrent(1, 10, phaseText, hardSessionBlock ? bearBg : neutralBg, tableText)
        f_cellCurrent(2, 10, "45% CHOP / 35% UNWIND / 20% REPAIR", neutralBg, tableText)
if barstate.islast and (not effectiveCurrentDashboard or not setup.active)
    table.clear(currentDash, 0, 0, 2, 10)

if barstate.islast and effectiveDecisionLadder and setup.active
    table.clear(ladderDash, 0, 0, 3, 8)
    f_cellLadder(0, 0, mappedVol ? "VOLATILITY CARD" : "EXECUTION CARD", headerBg, tableText)
    f_cellLadder(1, 0, sym, headerBg, tableText)
    f_cellLadder(2, 0, ladderTwoWay ? "TWO-WAY" : sideLabel, headerBg, tableText)
    f_cellLadder(3, 0, tradeInstruction, stateBg, color.white)
    if ladderTwoWay
        f_cellLadder(0, 1, "LONG ENTRY", keyBg, tableText)
        f_cellLadder(1, 1, f_fmt(setup.longTrigger), cTrigger, color.white)
        f_cellLadder(2, 1, "SHORT ENTRY", keyBg, tableText)
        f_cellLadder(3, 1, f_fmt(setup.shortTrigger), cTrigger, color.white)
        f_cellLadder(0, 2, "LONG GO", keyBg, tableText)
        f_cellLadder(1, 2, f_fmt(setup.longConfirm), cConfirm, color.white)
        f_cellLadder(2, 2, "SHORT GO", keyBg, tableText)
        f_cellLadder(3, 2, f_fmt(setup.shortConfirm), cConfirm, color.white)
        f_cellLadder(0, 3, "LONG STOP", keyBg, tableText)
        f_cellLadder(1, 3, f_fmt(setup.longInvalid), cInvalid, color.white)
        f_cellLadder(2, 3, "SHORT STOP", keyBg, tableText)
        f_cellLadder(3, 3, f_fmt(setup.shortInvalid), cInvalid, color.white)
        f_cellLadder(0, 4, "LONG T1", keyBg, tableText)
        f_cellLadder(1, 4, f_fmt(setup.longT1), cTarget, color.white)
        f_cellLadder(2, 4, "SHORT T1", keyBg, tableText)
        f_cellLadder(3, 4, f_fmt(setup.shortT1), cTarget, color.white)
    else
        f_cellLadder(0, 1, "ENTRY", keyBg, tableText)
        f_cellLadder(1, 1, f_fmt(sideTrigger), cTrigger, color.white)
        f_cellLadder(2, 1, "GO / CONFIRM", keyBg, tableText)
        f_cellLadder(3, 1, f_fmt(sideConfirm), cConfirm, color.white)
        f_cellLadder(0, 2, "STOP", keyBg, tableText)
        f_cellLadder(1, 2, f_fmt(sideInvalid), cInvalid, color.white)
        f_cellLadder(2, 2, "MAP FAIL", keyBg, tableText)
        f_cellLadder(3, 2, f_fmt(sideHard), bearBg, tableText)
        f_cellLadder(0, 3, "T1 / NEXT", keyBg, tableText)
        f_cellLadder(1, 3, f_fmt(sideNextTarget), cTarget, color.white)
        f_cellLadder(2, 3, "T2", keyBg, tableText)
        f_cellLadder(3, 3, f_fmt(sideT2), cTarget, color.white)
        f_cellLadder(0, 4, "T3", keyBg, tableText)
        f_cellLadder(1, 4, f_fmt(sideT3), cTarget, color.white)
        f_cellLadder(2, 4, "EXPECTED R", keyBg, tableText)
        f_cellLadder(3, 4, expectedRText, directionalScore >= scoreThreshold ? passBg : waitBg, tableText)
    f_cellLadder(0, 5, "QQQ / SMH", keyBg, tableText)
    f_cellLadder(1, 5, f_fmt(qqqClose) + " / " + f_fmt(smhClose), qqqClose >= 708 and smhClose >= 585 ? passBg : qqqClose < 691 or smhClose < 567.5 ? bearBg : waitBg, tableText)
    f_cellLadder(2, 5, "IWM / VIX", keyBg, tableText)
    f_cellLadder(3, 5, f_fmt(iwmClose) + " / " + f_fmt(vixClose), iwmClose >= 297 and vixClose < 19.0 ? passBg : iwmClose < 292 or vixClose >= 20.0 ? bearBg : waitBg, tableText)
    f_cellLadder(0, 6, "GATE STACK", keyBg, tableText)
    f_cellLadder(1, 6, gateStackText, gateBg, tableText)
    f_cellLadder(2, 6, "QUALITY", keyBg, tableText)
    f_cellLadder(3, 6, qualityText, directionalScore >= scoreThreshold ? passBg : waitBg, tableText)
    f_cellLadder(0, 7, "VEHICLE", keyBg, tableText)
    f_cellLadder(1, 7, sideVehicle, neutralBg, tableText)
    f_cellLadder(2, 7, "MAP", keyBg, tableText)
    f_cellLadder(3, 7, mapModeText, eventRemapActive ? waitBg : mapFresh ? passBg : bearBg, tableText)
    f_cellLadder(0, 8, "NO TRADE IF", keyBg, tableText)
    f_cellLadder(1, 8, blockerText, blockerText == "ALL REQUIRED GATES READY" ? passBg : waitBg, tableText)
    f_cellLadder(2, 8, "SCENARIO", keyBg, tableText)
    f_cellLadder(3, 8, "45 CHOP / 35 UNWIND / 20 REPAIR", neutralBg, tableText)

if barstate.islast and (not effectiveDecisionLadder or not setup.active)
    table.clear(ladderDash, 0, 0, 3, 8)

if barstate.islast and effectiveFocusBoard
    table.clear(focusDash, 0, 0, 2, 11)
    f_cellFocus(0, 0, "7/20 FOCUS", headerBg, tableText)
    f_cellFocus(1, 0, "TRIGGER → GO", headerBg, tableText)
    f_cellFocus(2, 0, "LIVE GATE", headerBg, tableText)
    f_cellFocus(0, 1, "IWM", neutralBg, tableText)
    f_cellFocus(1, 1, "<291.64 → 290.68", neutralBg, tableText)
    f_cellFocus(2, 1, iwmClose < 292 ? "BEAR" : iwmClose > 297 ? "REPAIR" : "WAIT", iwmClose < 292 ? bearBg : iwmClose > 297 ? passBg : waitBg, tableText)
    f_cellFocus(0, 2, "PLTR", neutralBg, tableText)
    f_cellFocus(1, 2, "<129.05 → 128.68", neutralBg, tableText)
    f_cellFocus(2, 2, qqqClose < 700 ? "Q WEAK" : "WAIT", qqqClose < 700 ? bearBg : waitBg, tableText)
    f_cellFocus(0, 3, "UNH", neutralBg, tableText)
    f_cellFocus(1, 3, ">437.47 → 440", neutralBg, tableText)
    f_cellFocus(2, 3, healthcareLeadership ? "XLV PASS" : "WAIT", healthcareLeadership ? passBg : waitBg, tableText)
    f_cellFocus(0, 4, "RIVN", neutralBg, tableText)
    f_cellFocus(1, 4, ">18.79 → 19", neutralBg, tableText)
    f_cellFocus(2, 4, iwmClose > 297 ? "IWM PASS" : "WAIT", iwmClose > 297 ? passBg : waitBg, tableText)
    f_cellFocus(0, 5, "CRWV", neutralBg, tableText)
    f_cellFocus(1, 5, ">74.50 → 75.50", neutralBg, tableText)
    f_cellFocus(2, 5, smhClose > 585 ? "SMH PASS" : "WAIT", smhClose > 585 ? passBg : waitBg, tableText)
    f_cellFocus(0, 6, "IREN", neutralBg, tableText)
    f_cellFocus(1, 6, "<32.22 / FAIL REBOUND", neutralBg, tableText)
    f_cellFocus(2, 6, qqqClose < 700 ? "BETA WEAK" : "WAIT", qqqClose < 700 ? bearBg : waitBg, tableText)
    f_cellFocus(0, 7, "QQQ", neutralBg, tableText)
    f_cellFocus(1, 7, "708-710 / 691-690", neutralBg, tableText)
    f_cellFocus(2, 7, qqqClose > 710 ? "REPAIR" : qqqClose < 691 ? "FAIL" : "RANGE", qqqClose > 710 ? passBg : qqqClose < 691 ? bearBg : waitBg, tableText)
    f_cellFocus(0, 8, "SMH", neutralBg, tableText)
    f_cellFocus(1, 8, "585-590 / 567.5-550", neutralBg, tableText)
    f_cellFocus(2, 8, smhClose > 590 ? "REPAIR" : smhClose < 567.5 ? "FAIL" : "RANGE", smhClose > 590 ? passBg : smhClose < 567.5 ? bearBg : waitBg, tableText)
    f_cellFocus(0, 9, "NVDA", neutralBg, tableText)
    f_cellFocus(1, 9, ">205 / <200", neutralBg, tableText)
    f_cellFocus(2, 9, smhClose > 585 ? "SMH PASS" : "WAIT", smhClose > 585 ? passBg : waitBg, tableText)
    f_cellFocus(0, 10, "VIX", neutralBg, tableText)
    f_cellFocus(1, 10, "19 → 20 WALL", neutralBg, tableText)
    f_cellFocus(2, 10, vixStateText, vixClose >= 20 ? bearBg : vixClose < 18.5 ? passBg : waitBg, tableText)
    f_cellFocus(0, 11, "LEI / DATA", neutralBg, tableText)
    f_cellFocus(1, 11, phaseText, neutralBg, tableText)
    f_cellFocus(2, 11, integrityText, operationalIntegrityReady ? passBg : bearBg, tableText)

if barstate.islast and not effectiveFocusBoard
    table.clear(focusDash, 0, 0, 2, 11)
// ============================================================================
// ALERTS
// ============================================================================

bool spxBullGateCross = ta.crossover(spxCash, 7525.0)
bool spxBearGateCross = ta.crossunder(spxCash, 7515.0)
bool qqqBullGateCross = ta.crossover(qqqClose, 708.0)
bool qqqBearGateCross = ta.crossunder(qqqClose, 691.0)
bool smhBullGateCross = ta.crossover(smhClose, 585.0)
bool smhBearGateCross = ta.crossunder(smhClose, 567.50)
bool iwmBullGateCross = ta.crossover(iwmClose, 297.0)
bool iwmBearGateCross = ta.crossunder(iwmClose, 292.0)
bool vixRiskCross = ta.crossover(vixClose, 19.0)
bool vixExpansionCross = ta.crossover(vixClose, 20.0)
bool vixReliefCross = ta.crossunder(vixClose, 18.50)
bool internalsBullCross = ta.crossover(internalsScore, 60)
bool internalsBearCross = ta.crossunder(internalsScore, 40)
bool frontVolStressCross = frontVolStress and not frontVolStress[1]
bool eventRemapReady = eventRemapActive and not eventRemapActive[1]
bool integrityBlockedEvent = not operationalIntegrityReady and operationalIntegrityReady[1]
bool integrityRecoveredEvent = operationalIntegrityReady and not operationalIntegrityReady[1]
bool surfaceAccelerationUpEvent = compositeSurface >= 0.55 and compositeSurface[1] < 0.55 and operationalIntegrityReady
bool surfaceAccelerationDownEvent = compositeSurface <= -0.55 and compositeSurface[1] > -0.55 and operationalIntegrityReady

alertcondition(longSignal, "Schmidt Capital Precision Long", "Schmidt Capital precision LONG signal")
alertcondition(shortSignal, "Schmidt Capital Precision Short", "Schmidt Capital precision SHORT signal")
alertcondition(newT1Event, "Schmidt Capital Target 1", "Schmidt Capital target 1 reached; move stop to breakeven")
alertcondition(newT2Event, "Schmidt Capital Target 2", "Schmidt Capital target 2 reached; trail the runner")
alertcondition(newT3Event, "Schmidt Capital Target 3", "Schmidt Capital target 3 reached; no chase")
alertcondition(newInvalidEvent, "Schmidt Capital Invalidation", "Schmidt Capital setup invalidated")
alertcondition(newBEEvent, "Schmidt Capital Breakeven Exit", "Schmidt Capital breakeven exit after target 1")
alertcondition(mapBrokenEvent, "Schmidt Capital Map Broken", "Schmidt Capital static map broken; remap required")
alertcondition(eventRemapReady, "Schmidt Capital Event Remap Ready", "Schmidt Capital event opening-range remap is ready")
alertcondition(spxBullGateCross, "SC SPX 7525 Repair", "SPX reclaimed 7,525; stronger repair requires 7,550/7,565.")
alertcondition(spxBearGateCross, "SC SPX 7515 Failure", "SPX lost 7,515; negative-gamma downside risk is increasing.")
alertcondition(qqqBullGateCross, "SC QQQ 708 Repair", "QQQ reclaimed 708; durable repair requires 710.")
alertcondition(qqqBearGateCross, "SC QQQ 691 Failure", "QQQ lost 691; 690 then 685/680 are active.")
alertcondition(smhBullGateCross, "SC SMH 585 Repair", "SMH reclaimed 585; stronger semiconductor repair requires 590.")
alertcondition(smhBearGateCross, "SC SMH 567.5 Failure", "SMH lost 567.5; 562.5 then 550 are active.")
alertcondition(iwmBullGateCross, "SC IWM 297 Repair", "IWM reclaimed 297; breadth repair improves above 300.")
alertcondition(iwmBearGateCross, "SC IWM 292 Failure", "IWM lost 292; negative-gamma small-cap acceleration is increasing.")
alertcondition(vixRiskCross, "SC VIX 19 Warning", "VIX crossed above 19; risk repricing is active.")
alertcondition(vixExpansionCross, "SC VIX 20 Expansion", "VIX crossed above 20; negative-gamma unwind confirmation is strengthening.")
alertcondition(vixReliefCross, "SC VIX 18.5 Relief", "VIX crossed below 18.5; equity repair conditions are improving.")
alertcondition(internalsBullCross, "SC Internals Bullish", "UVOL/DVOL, TICK and volatility-curve composite crossed into bullish breadth.")
alertcondition(internalsBearCross, "SC Internals Bearish", "UVOL/DVOL, TICK and volatility-curve composite crossed into bearish breadth.")
alertcondition(frontVolStressCross, "SC Front Volatility Stress", "VIX1D/VIX9D front-end stress threshold triggered.")
alertcondition(integrityBlockedEvent, "SC Operational Integrity Block", "Operational integrity fell below the execution threshold; fail closed.")
alertcondition(integrityRecoveredEvent, "SC Operational Integrity Recovered", "Operational integrity recovered above the execution threshold.")
alertcondition(surfaceAccelerationUpEvent, "SC Native Surface Acceleration Up", "Native structural and hedge-pressure surfaces aligned upward.")
alertcondition(surfaceAccelerationDownEvent, "SC Native Surface Acceleration Down", "Native structural and hedge-pressure surfaces aligned downward.")

var int lastDynamicAlertBar = na
bool dynamicAlertOk = na(lastDynamicAlertBar) or bar_index - lastDynamicAlertBar >= alertCooldownBars
if enableDynamicAlerts and dynamicAlertOk and (longSignal or shortSignal)
    string dir = longSignal ? "LONG" : "SHORT"
    int score = longSignal ? longScore : shortScore
    float inv = longSignal ? setup.longInvalid : setup.shortInvalid
    float tp1 = longSignal ? setup.longT1 : setup.shortT1
    string msg = "SCHMIDT CAPITAL v49.1 | " + sym + " | " + dir + " | SCORE " + str.tostring(score) + " | ENTRY " + f_fmt(close) + " | INV " + f_fmt(inv) + " | TP1 " + f_fmt(tp1) + " | REGIME " + regimeText + " | INTERNALS " + str.tostring(internalsScore) + " | SURFACE " + surfaceStateText + " | MI " + str.tostring(effectiveMIScore, "#.0") + " | EMA " + emaText + " | " + rsiText + " | SIZE " + sizeText + " | MAP " + mapModeText
    alert(msg, alert.freq_once_per_bar_close)
    lastDynamicAlertBar := bar_index

if enableDynamicAlerts and dynamicAlertOk and (newT1Event or newT2Event or newT3Event or newInvalidEvent or newBEEvent or mapBrokenEvent or eventRemapReady)
    string eventText = newT3Event ? "T3 HIT — NO CHASE" : newT2Event ? "T2 HIT — TRAIL" : newT1Event ? "T1 HIT — STOP BE" : newInvalidEvent ? "INVALIDATED" : newBEEvent ? "BREAKEVEN EXIT" : eventRemapReady ? "EVENT REMAP READY" : "MAP BROKEN"
    alert("SCHMIDT CAPITAL v49.1 | " + sym + " | " + eventText + " | MFE " + (na(mfeR) ? "N/A" : str.tostring(mfeR, "#.##") + "R") + " | MAE " + (na(maeR) ? "N/A" : str.tostring(maeR, "#.##") + "R"), alert.freq_once_per_bar_close)
    lastDynamicAlertBar := bar_index

if enableLevelTouchAlerts and setup.active and dynamicAlertOk
    float touchTol = dailyAtr * 0.04
    bool longTouch = hasLong and not na(setup.longTrigger) and math.abs(close - setup.longTrigger) <= touchTol
    bool shortTouch = hasShort and not na(setup.shortTrigger) and math.abs(close - setup.shortTrigger) <= touchTol
    if longTouch or shortTouch
        alert("SCHMIDT CAPITAL v49.1 | " + sym + " | MAJOR LEVEL TOUCH | " + f_fmt(close), alert.freq_once_per_bar_close)
        lastDynamicAlertBar := bar_index
````
