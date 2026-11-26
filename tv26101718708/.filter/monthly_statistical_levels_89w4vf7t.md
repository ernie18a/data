# Monthly Statistical Levels

- url: https://www.tradingview.com/script/89W4VF7T/
- type: indicator
- pine_id: PUB;48ad651ed7594e3e8a734c5936ec1648
- version: 4.0

## Description

Monthly Statistical Levels is an open-source indicator that plots monthly reference levels based on historical monthly price extensions from the monthly open.

The goal of the script is to provide a clean statistical map for the current and recent months. It is designed as a market structure and reference-level tool, not as a buy/sell signal system.

How it works

The script uses completed monthly candles from TradingView data.

For each completed month, it calculates two historical extensions:

High extension:
Monthly High minus Monthly Open, divided by Monthly Open.

Low extension:
Monthly Open minus Monthly Low, divided by Monthly Open.

These historical extensions are stored separately for upside and downside movement.

At the start of each new month, the script uses the current monthly open and projects five reference levels:

Strong High
Avg High
Open
Avg Low
Strong Low

Avg High is based on the historical average upside extension from the monthly open.

Avg Low is based on the historical average downside extension from the monthly open.

Strong High uses the average upside extension plus a configurable standard deviation multiplier.

Strong Low uses the average downside extension plus a configurable standard deviation multiplier.

By default, the strong multiplier is set to 1.0, meaning strong levels use the historical average extension plus one standard deviation.

Lookback options

Users can choose the statistical lookback used for the calculations:

24 months
36 months
60 months
120 months
All available history

Using all available history can make the levels more stable, but it may also mix different market regimes. This is especially important for assets with structural changes, short trading histories, or very different behavior across cycles.

No lookahead logic

The indicator uses completed monthly candles to build the historical sample.

Each month keeps the levels calculated with the information available at the start of that month. The current month is used only for its monthly open, which is known once the month begins.

This means the levels are not recalculated using future monthly highs or lows.

How to use it

The levels can be used as a visual reference for monthly range structure.

Possible uses include:

Identifying where price is trading relative to its monthly statistical range.
Comparing the current month with recent monthly behavior.
Observing when price reaches average or stronger historical extension zones.
Keeping a cleaner chart with only the most recent visible months.

Main settings

Visible months:
Controls how many recent months are displayed. The default is 6 and the maximum is 12 to keep the chart readable.

Statistical lookback:
Controls the historical sample used to calculate average and strong levels.

Minimum closed months:
Defines the minimum number of completed monthly candles required before plotting levels.

Strong multiplier:
Controls how far strong levels are placed from average extension levels using standard deviation.

Labels:
Users can show labels only for the current month, for all visible months, or turn labels off.

Alerts

The script includes optional alert conditions for touches of:

Strong High
Avg High
Open
Avg Low
Strong Low

Limitations

This indicator does not predict future price movement.

It does not identify support or resistance with certainty.

It does not generate buy or sell signals.

It does not evaluate trend, fundamentals, macro conditions, liquidity, positioning, or news.

The levels depend on the TradingView symbol selected, the available historical data, and the chosen lookback window.

Why it may be useful

Many traders look at monthly opens, monthly ranges, and volatility-based zones separately. This script combines those ideas into one clean open-source tool: monthly open-based statistical levels built from completed historical monthly extensions.

It helps traders visualize where price is trading relative to its own historical monthly behavior, while keeping the chart simple and readable.

## Source Code

````pine
//@version=6
indicator(
     "MonLevels",
     shorttitle = "MonLevels",
     overlay = true,
     max_lines_count = 100,
     max_labels_count = 100
)

//──────────────────────────────────────────────────────────────────────────────
// Source validity gates: bar types with synthetic OHLC and charts above 1M
// cannot produce a faithful display of the native monthly reference levels.
if not chart.is_standard
    runtime.error("MonLevels requires standard price candles/bars (not synthetic charts).")
if timeframe.in_seconds(timeframe.period) > timeframe.in_seconds("1M")
    runtime.error("MonLevels requires timeframe 1M or lower for monthly levels.")

//──────────────────────────────────────────────────────────────────────────────
// Monthly Statistical Levels
//
// Method:
// - Uses completed monthly candles only.
// - Seasonal levels require at least seven completed same-calendar-month samples.
// - Optional non-seasonal model uses trailing completed months.
// - Motor 3 estimates per-symbol paired OOS model evidence in Pine.
// - R2.3.1 stabilizes descriptive Welch arithmetic and All recency checks.
// - M4 adds audited reaction events and paired OOS Base-vs-Sim evidence.
// - M4 R3 separates unavailable and degenerate levels, and audits paired
//   High-vs-Low frequencies on a common month cohort without replacing Base.
//   Descriptive rates are NOT calibrated trading signals.
// - Evidence intervals remain APPROXIMATE, not profit probabilities.
// - M5.2 EXPERIMENTAL: eight prequential context-ablation estimators run only
//   when enabled in Quant/Custom. They do NOT replace Base, Sim, or any level.
// - M5.2 shows comparative observed Brier, NOT an approved model winner.
// - M5.3 opt-in: paired Bonferroni-HAC, split/LOO and exact B+C
//   sensitivity reforecasts. Statuses are research screens, NOT signals.
// - M5.4 R3 RESEARCH: paired local-episode outcome comparison with
//   ATH-derived vs Local-derived PRE-EPISODE P75 predictions, separate
//   99% approximate HAC, temporal split, and leave-one-out screens.
//   ZERO promotion authority: experiments cannot enable Pullback alerts.
// - M5.4.6 CANDIDATE: independent daily pullback episodes, 21/63/126-session
//   horizon samples, prequential P75 checks. Provisional quality gates must be
//   calibrated before release. Daily data are requested as CONFIRMED snapshots.
//   Experimental P75 is descriptive; alert events require evidence admission.
// - M5.4 R5 RESEARCH: exogenous quarterly forecast origins and 63-session
//   forward drawdown target. Matched ATH, Local, prior-calendar benchmark.
//   New estimand, NOT comparable to episode-depth coverage; no release.
// - M5.4 R5.3 TRANSPORT REPAIR: stabilize daily source and snapshot delivery.
//   Intraday extended-hour charts request the standard REGULAR 1D session.
//   Retain the latest available confirmed 1D audit through chart-bar changes;
//   explicitly mark cached/unavailable daily delivery in Origins research.
//   Episode/origin estimators and all monthly engines remain unchanged.
// - Seasonal mode estimates each calendar month exclusively from earlier
//   occurrences of that same month; nonseasonal mode uses trailing months.
// - Projects current/visible monthly levels from each month open.
// - Avg levels = historical mean extension.
// - Strong levels = historical mean extension + standard deviation multiplier.
// - Each month keeps the levels calculated with the information available
//   at the start of that month. No lookahead.
//
// Reaction dashboard:
// - Studies what happened historically after each monthly statistical level
//   was touched.
// - Touch = month reached the level.
// - Base = full historical touch rate for the selected symbol.
// - Sim = touch rate in months with a similar historical context.
// - Sim N = number of similar-context historical months used.
// - Contained = month stayed between Avg High and Avg Low without touching either level.
// - Beyond = month closed beyond the touched level.
// - Between = month closed between the monthly open and the touched level.
// - Revert = month closed back toward or beyond the monthly open.
//
// This is a statistical reference tool, not a prediction model or signal system.
//──────────────────────────────────────────────────────────────────────────────

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────

// Single product; progressive controls. Pine can dim, group and compact inputs,
// but cannot conditionally remove them from the Settings / Inputs tab.
// The core monthly model never changes automatically when switching display modes.
groupStart = "01 · START HERE"
displayModeInput = input.string("Clean", "Display mode", options = ["Clean", "Pro", "Quant", "Custom"], group = groupStart,
     tooltip = "Clean: monthly levels. Pro: appearance and monthly alerts. Quant: descriptive statistics and optional research. Custom: manual chart display and research. Same level-model calculations in all modes.", display = display.none)
visibleMonths = input.int(6, "Visible months", minval = 1, maxval = 12, group = groupStart,
     tooltip = "Months of historical levels visible on the chart (1–12).", display = display.none)

// Controls stay in the saved configuration while the current mode determines
// which ones can be adjusted. No false claims of dynamically collapsed panels.
bool proInputMode = displayModeInput != "Clean"
bool advancedInputMode = displayModeInput == "Quant" or displayModeInput == "Custom"
bool customInputMode = displayModeInput == "Custom"
bool proOrCustomInputMode = displayModeInput == "Pro" or displayModeInput == "Custom"

groupCalc = "02 · PRO · LEVELS"
lookbackInput = input.string("60", "History", options = ["24", "36", "60", "All"], group = groupCalc,
     active = proInputMode, display = display.none,
     tooltip = "Seasonal: previous occurrences of the SAME calendar month. Non-seasonal: preceding consecutive months. 'All' uses available history. Actual N may be lower; no automatic model change.")
modelInput = input.string("Seasonal", "Level model", options = ["Seasonal", "Non-seasonal"], group = groupCalc,
     active = proInputMode, display = display.none,
     tooltip = "Seasonal by default. A separate OOS comparison can favor an alternative, but never changes the selected model automatically.")
// Technical eligibility for seasonal levels, not a sample-size guarantee.
int minClosedMonths = 7
strongMult = input.float(1.0, "Strong multiplier", minval = 0.0, step = 0.25, group = groupCalc,
     active = proInputMode, display = display.none,
     tooltip = "Average extension + this multiplier × historical standard deviation.")

groupVisual = "03 · PRO · APPEARANCE"
showOpen = input.bool(true, "Show monthly Open", group = groupVisual,
     active = proOrCustomInputMode, tooltip = "Clean and Quant show Open. Pro and Custom can turn it off.")
lineLabelSizeInput = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = groupVisual,
     active = proInputMode, display = display.none)
lineStyleInput = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = groupVisual,
     active = proInputMode, display = display.none)
lineWidth = input.int(1, "Line width", minval = 1, maxval = 3, group = groupVisual,
     active = proInputMode, display = display.none)
minimumCurrentLineBars = input.int(5, "Minimum current-line bars", minval = 1, maxval = 30, group = groupVisual,
     active = proInputMode, display = display.none,
     tooltip = "Minimum visual length of current-month lines, particularly near the beginning of a month.")
strongHighColor = input.color(color.new(color.teal, 45), "Strong High", group = groupVisual,
     inline = "hi", active = proInputMode)
avgHighColor = input.color(color.new(color.teal, 70), "Avg High", group = groupVisual,
     inline = "hi", active = proInputMode)
openColor = input.color(color.new(color.gray, 65), "Open", group = groupVisual,
     active = proInputMode)
avgLowColor = input.color(color.new(color.maroon, 70), "Avg Low", group = groupVisual,
     inline = "lo", active = proInputMode)
strongLowColor = input.color(color.new(color.maroon, 45), "Strong Low", group = groupVisual,
     inline = "lo", active = proInputMode)

groupAlerts = "04 · PRO · MONTHLY ALERTS"
enableAlerts = input.bool(true, "Enable monthly alerts", group = groupAlerts,
     active = proInputMode, tooltip = "Allows monthly level alert conditions. You must still create an alert in TradingView; enabling this option does not create one.")
alertStrongHigh = input.bool(true, "Strong High", group = groupAlerts,
     inline = "alHigh", active = proInputMode and enableAlerts)
alertAvgHigh = input.bool(true, "Avg High", group = groupAlerts,
     inline = "alHigh", active = proInputMode and enableAlerts)
alertOpen = input.bool(false, "Open", group = groupAlerts,
     active = proInputMode and enableAlerts)
alertAvgLow = input.bool(true, "Avg Low", group = groupAlerts,
     inline = "alLow", active = proInputMode and enableAlerts)
alertStrongLow = input.bool(true, "Strong Low", group = groupAlerts,
     inline = "alLow", active = proInputMode and enableAlerts)
alertEngineInput = input.string("Legacy alertconditions", "Advanced alert format",
     options = ["Legacy alertconditions", "Dynamic alert()", "Both"], group = groupAlerts,
     active = advancedInputMode and enableAlerts, display = display.none,
     tooltip = "Legacy provides individual TradingView alert conditions; Dynamic uses Any alert() function call. Both options remain available. Monthly alerts are independent of Pullback research.")

groupEvidence = "05 · QUANT · MODEL EVIDENCE"
wfWindowInput = input.string("360", "Walk-forward OOS window", options = ["120", "240", "360", "All"], group = groupEvidence,
     active = advancedInputMode, display = display.none,
     tooltip = "Completed monthly evaluation observations, not the level calculation lookback. 'All' uses the available OOS period.")
// Original numeric HAC admission floors are unchanged.
int minWfGlobal = 3 * (12 + 1)
int minWfCalendar = 3 * (1 + 1)
minWfImprovement = input.float(3.0, "Minimum MAE improvement (%)", minval = 0.0, maxval = 30.0,
     step = 0.5, group = groupEvidence, active = advancedInputMode, display = display.none,
     tooltip = "Minimum practical OOS MAE advantage for a model preference; does not weaken evidence admission and never switches the selected model.")
showM3EvidenceTable = input.bool(false, "Show M3 comparison (Custom)", group = groupEvidence,
     active = customInputMode, tooltip = "Quant displays M3 evidence by default. Custom lets you choose whether to show that table.")
m3TablePositionInput = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"],
     group = groupEvidence, active = advancedInputMode, display = display.none)
m3TableSizeInput = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"],
     group = groupEvidence, active = advancedInputMode, display = display.none)

groupDashboard = "06 · QUANT · REACTIONS"
dashboardModeInput = input.string("Off", "Dashboard (Custom)", options = ["Off", "Nearest", "Full"], group = groupDashboard,
     active = customInputMode, display = display.none,
     tooltip = "Clean: Off; Pro: Nearest; Quant: Full. Custom allows a manual choice. Reaction rates are descriptive, not trading signals.")
dashboardPositionInput = input.string("Bottom right", "Dashboard position", options = ["Top right", "Top left", "Bottom right", "Bottom left"],
     group = groupDashboard, active = proInputMode, display = display.none)
dashboardSizeInput = input.string("Small", "Dashboard text size", options = ["Tiny", "Small", "Normal"],
     group = groupDashboard, active = proInputMode, display = display.none)

groupM5 = "07 · QUANT · CONTEXT STUDIES (EXPERIMENTAL)"
m5StudySetting = input.bool(false, "Run M5.2 context study", group = groupM5,
     active = advancedInputMode, tooltip = "Eight prequential context-ablation models. OFF by default; research only, never an operational selection.")
m5ShowTableSetting = input.bool(false, "Show M5 study table", group = groupM5,
     active = advancedInputMode and m5StudySetting)
m5InferenceSetting = input.bool(false, "Run M5.3 robustness", group = groupM5,
     active = advancedInputMode and m5StudySetting,
     tooltip = "Paired HAC/Bonferroni, chronological halves, influence, and B+C perturbation screens. Research only.")
m5TablePositionInput = input.string("Bottom left", "Study table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"],
     group = groupM5, active = advancedInputMode and m5StudySetting and m5ShowTableSetting, display = display.none)
m5TableSizeInput = input.string("Tiny", "Study table text size", options = ["Tiny", "Small", "Normal"],
     group = groupM5, active = advancedInputMode and m5StudySetting and m5ShowTableSetting, display = display.none)

groupPullback = "08 · QUANT · PULLBACK (EXPERIMENTAL)"
showPullbackSetting = input.bool(false, "Show Pullback Map", group = groupPullback,
     active = advancedInputMode,
     tooltip = "P75 from CONFIRMED 1D CLOSE-based drawdown episodes, not a validated intraday touch probability. Statistical target is up to 63 sessions including onset, or recovery. No buy/sell signal.")
pbQuantPreviewSetting = input.bool(false, "Preview P75 closes · experimental †", group = groupPullback,
     active = advancedInputMode and showPullbackSetting,
     tooltip = "Experimental dotted CLOSE-based P75. Frozen after the initial declining daily close; an open episode may visually persist after the assessed 63 sessions. No Pullback alerts.")
pbQuantResearchSetting = input.bool(false, "Show research details", group = groupPullback,
     active = advancedInputMode and showPullbackSetting,
     tooltip = "Optional historical OOS, uncertainty and episode/origin comparisons; all strictly investigative.")
pbResearchView = input.string("Episodes", "Research view", options = ["Episodes", "Comparison", "Origins"], group = groupPullback,
     active = advancedInputMode and showPullbackSetting and pbQuantResearchSetting, display = display.none)
pbTablePositionInput = input.string("Bottom right", "Research table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"],
     group = groupPullback, active = advancedInputMode and showPullbackSetting and pbQuantResearchSetting, display = display.none)
pbTableSizeInput = input.string("Tiny", "Pullback table size", options = ["Tiny", "Small", "Normal"],
     group = groupPullback, active = advancedInputMode and showPullbackSetting and pbQuantResearchSetting, display = display.none,
     tooltip = "Text size for the Pullback research table (Episodes, Comparison and Origins). The table adapts automatically. Tiny preserves the previous layout.")
pbAlertEnabled = input.bool(false, "Pullback alerts · BLOCKED", group = groupPullback,
     active = false, tooltip = "Unavailable. CLOSE-based P75 is not validated for contacts or gap bypasses. pbReleaseAdmitted remains hardcoded false; monthly alerts are unaffected.")
pbAlertKind = input.string("Touch", "Pullback event · BLOCKED", options = ["Touch", "Cross"],
     group = groupPullback, active = false, display = display.none)

groupCustom = "09 · CUSTOM · MANUAL DISPLAY"
customShowLevels = input.bool(true, "Show statistical levels", group = groupCustom,
     active = customInputMode)
customShowStrong = input.bool(true, "Strong levels", group = groupCustom,
     inline = "levelTypes", active = customInputMode and customShowLevels)
customShowAvg = input.bool(true, "Average levels", group = groupCustom,
     inline = "levelTypes", active = customInputMode and customShowLevels)
customShowPrices = input.bool(false, "Level prices on price scale", group = groupCustom,
     active = customInputMode, tooltip = "Price scale series; enable price labels in TradingView chart settings to see the values.")
labelMode = input.string("Current month only", "Labels", options = ["Off", "Current month only", "All visible months"], group = groupCustom,
     active = customInputMode, display = display.none)
showDistanceInLabels = input.bool(true, "Show distance in labels", group = groupCustom,
     active = customInputMode)

// Optional research runs only in Quant/Custom. Switching to Clean/Pro stops
// optional heavy research without resetting saved study configurations.
// This gating does NOT change the monthly engine formulas or model selection.
bool m5StudyEnabled = advancedInputMode and m5StudySetting
bool m5ShowTable = m5StudyEnabled and m5ShowTableSetting
bool m5InferenceEnabled = m5StudyEnabled and m5InferenceSetting
bool showPullbackMap = advancedInputMode and showPullbackSetting
bool pbQuantPreview = showPullbackMap and pbQuantPreviewSetting
bool pbQuantResearch = showPullbackMap and pbQuantResearchSetting

//──────────────────────────────────────────────────────────────────────────────
// Input processing
//──────────────────────────────────────────────────────────────────────────────

int seasonalLookbackObservations = switch lookbackInput
    "24" => 24
    "36" => 36
    "60" => 60
    => 0
// The context range reference is a separate trailing-calendar-month baseline.
// Its methodology remains unchanged in this bounded seasonal-level repair.
int contextRangeLookbackMonths = seasonalLookbackObservations == 0 ? 0 : seasonalLookbackObservations * 12

lineStyle = switch lineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

dashboardPosition = switch dashboardPositionInput
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right

dashboardTextSize = switch dashboardSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

m3TablePosition = switch m3TablePositionInput
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right

m3TableTextSize = switch m3TableSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

m5TablePosition = switch m5TablePositionInput
    "Top left" => position.top_left
    "Top right" => position.top_right
    "Bottom right" => position.bottom_right
    => position.bottom_left

m5TableTextSize = switch m5TableSizeInput
    "Small" => size.small
    "Normal" => size.normal
    => size.tiny

lineLabelTextSize = switch lineLabelSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

bool customMode = displayModeInput == "Custom"
bool quantMode = displayModeInput == "Quant"
bool proMode = displayModeInput == "Pro"
bool proLabelsActive = proMode or quantMode or (customMode and labelMode != "Off")
string effectiveDashboardMode = displayModeInput == "Clean" ? "Off" : proMode ? "Nearest" : quantMode ? "Full" : dashboardModeInput
bool dashboardActive = effectiveDashboardMode != "Off"
bool nearestDashboardActive = effectiveDashboardMode == "Nearest"
bool fullDashboardActive = effectiveDashboardMode == "Full"
bool effectiveM3Table = quantMode or (customMode and showM3EvidenceTable)
bool effectiveM5Table = m5StudyEnabled and m5ShowTable and (quantMode or customMode)
bool effectiveShowOpen = (not customMode and not proMode) or showOpen
bool effectivePullbackMap = showPullbackMap
bool effectiveShowAvg = not customMode or (customShowLevels and customShowAvg)
bool effectiveShowStrong = not customMode or (customShowLevels and customShowStrong)
string effectiveLabelMode = customMode ? labelMode : "Current month only"

pbTablePosition = switch pbTablePositionInput
    "Top right" => position.top_right
    "Top left" => position.top_left
    "Bottom left" => position.bottom_left
    => position.bottom_right
// One size for both columns, shared by all three Pullback research views.
pbTableTextSize = switch pbTableSizeInput
    "Small" => size.small
    "Normal" => size.normal
    => size.tiny
bool pbRunEngine = effectivePullbackMap or pbQuantResearch or pbAlertEnabled

int wfWindow = switch wfWindowInput
    "120" => 120
    "240" => 240
    "360" => 360
    => 0

string scriptVersion = "2026-10-15-MonLevels-RC4.1"
bool legacyAlertsActive = alertEngineInput == "Legacy alertconditions" or alertEngineInput == "Both"
bool dynamicAlertsActive = alertEngineInput == "Dynamic alert()" or alertEngineInput == "Both"

//──────────────────────────────────────────────────────────────────────────────
// M5.4.6 CANDIDATE — Daily episode P75 research. Intentionally independent of
// f_monthly_engine() and all M1–M5.3 counters.
// The outcome at horizons 21/63/126 is frozen at horizon completion or recovery.
// No episode is evaluated or added to training at onset.
//──────────────────────────────────────────────────────────────────────────────
type PbDailySnapshot
    float admittedLevel
    float previewLevel
    float currentP75
    float legacyBarP75
    float completeEpisodeP75
    int legacyBarN
    float allP75
    float trendP75
    float percentileCiLo
    float percentileCiHi
    int episodes63
    int bullishEpisodes63
    int completedEpisodes
    int openEpisodes
    int oosGeneral
    int oosPaired
    float coverageGeneral
    float pinballGeneral
    float pinballTrend
    float pairedDelta
    float pairedHacLower
    int selectedMethod
    int qualityState
    int regimeAtPeak
    int daysOpen
    float horizon21Delta
    float horizon126Delta
    int touchSerial
    int crossSerial
    float touchPrice
    float crossPrice
    int touchDate
    int crossDate
    // M5.4 R2 -- evaluation diagnostics (not production evidence).
    int timedOutEpisodes
    int informativePaired63
    int paired21N
    int paired126N
    int general21N
    int general126N
    float general21P75
    float general126P75
    // M5.4 R3 -- paired reference-method research, local episodes only.
    int methodPairedN
    int methodInformativeN
    float methodAthLoss
    float methodLocalLoss
    float methodAthCoverage
    float methodLocalCoverage
    float methodMeanDelta
    float methodHacLo
    float methodHacHi
    int methodScreenCode
    int methodHalvesPass
    int methodLooPass

// Research target with exogenous QUARTERLY forecast origins:
// maximum future decline from the close at the origin over NEXT 63 valid daily
// sessions. It is DIFFERENT from depth measured from an episode peak.
// No forecasted reference from this study can trigger charts or alerts.
type PbOriginAudit
    int completedTargets
    int pairedN
    int tripleN
    int informativeN
    int overlapSkips
    int badWindows
    int priorCalendarN
    float pairedAthLoss
    float pairedLocalLoss
    float pairedAthCoverage
    float pairedLocalCoverage
    float tripleAthLoss
    float tripleLocalLoss
    float tripleCalLoss
    float tripleAthCoverage
    float tripleLocalCoverage
    float tripleCalCoverage
    float pairedHacStressLow
    float pairedHacStressHigh
    int liveOrigin

// Daily audit returned as a single UDT. Does NOT add to the monthly 125-field tuple.
type PbDailyAudit
    PbDailySnapshot anchor
    PbDailySnapshot local
    PbOriginAudit origins

// Common table presentation helpers: each cell keeps identical data,
// colors, sizes, background and explanatory tooltip. Computation is untouched.
f_m5_table_cell(table tab, int column, int row, string value, color ink, string fontSize, string tip = "", color cellBg = na) =>
    table.cell(tab, column, row, value, text_color = ink, text_size = fontSize, tooltip = tip, bgcolor = cellBg)

f_m5_pb_row(table tab, int row, string labelValue, string dataValue, color ink, string dataTip = "") =>
    table.cell(tab, 0, row, labelValue, text_color = ink, text_size = pbTableTextSize)
    table.cell(tab, 1, row, dataValue, text_color = ink, text_size = pbTableTextSize, tooltip = dataTip)

f_pb_quantile(array<float> values) =>
    array.size(values) > 0 ? array.percentile_nearest_rank(values, 75.0) : na

f_pb_pinball(float observed, float forecast) =>
    float miss = observed - forecast
    miss >= 0 ? 0.75 * miss : -0.25 * miss

f_pb_wilson_bounds(int successes, int n) =>
    float lower = na
    float upper = na
    if n > 0
        float p = successes * 1.0 / n
        float z = 1.95996398454
        float zz = z * z
        float den = 1.0 + zz / n
        float center = (p + zz / (2.0 * n)) / den
        float half = z * math.sqrt(p * (1.0 - p) / n + zz / (4.0 * n * n)) / den
        lower := math.max(0.0, center - half)
        upper := math.min(1.0, center + half)
    [lower, upper]

// Approximate 95% nonparametric percentile rank interval. This is NOT a
// predictive price interval, and its coverage can degrade under dependence.
f_pb_rank_bounds(array<float> values) =>
    float lower = na
    float upper = na
    int n = array.size(values)
    if n >= 14
        array<float> sorted = array.copy(values)
        array.sort(sorted, order.ascending)
        float mu = (n + 1) * 0.75
        float spread = 1.96 * math.sqrt(n * 0.75 * 0.25)
        int leftIndex = math.max(0, int(math.floor(mu - spread)) - 1)
        int rightIndex = math.min(n - 1, int(math.ceil(mu + spread)) - 1)
        lower := array.get(sorted, leftIndex)
        upper := array.get(sorted, rightIndex)
    [lower, upper]

// HAC lower confidence boundary for the paired difference in 63-day pinball
// loss (general minus trend). Bartlett lag <=3, conservative ~99% screen.
f_pb_hac_lower(array<float> differences) =>
    int n = array.size(differences)
    float meanDiff = na
    float lower = na
    if n >= 12
        float total = 0.0
        for i = 0 to n - 1
            total += array.get(differences, i)
        meanDiff := total / n
        float lrv = 0.0
        for i = 0 to n - 1
            float d = array.get(differences, i) - meanDiff
            lrv += d * d / n
        for lag = 1 to 3
            if lag < n
                float covariance = 0.0
                for i = lag to n - 1
                    covariance += (array.get(differences, i) - meanDiff) * (array.get(differences, i - lag) - meanDiff) / n
                lrv += 2.0 * (1.0 - lag / 4.0) * covariance
        lower := meanDiff - 2.75 * math.sqrt(math.max(lrv, 0.0) / n)
    [meanDiff, lower]

// R3: symmetric approximate Bartlett-HAC 99% CI for ATH-minus-LOCAL
// pinball differences on MATCHED local episodes. Descriptive only; no
// universal Type-I-error or dependence calibration is claimed.
f_pb_paired_hac99(array<float> differences) =>
    int n = array.size(differences)
    float avg = na
    float ciLo = na
    float ciHi = na
    if n >= 14
        // Scale to percentage points to avoid Pine's 9-decimal comparison
        // rounding from erasing tiny squared return differences.
        float total = array.sum(differences) * 100.0
        avg := total / n
        float longRunVar = 0.0
        for i = 0 to n - 1
            float residual = array.get(differences, i) * 100.0 - avg
            longRunVar += residual * residual / n
        for lag = 1 to 3
            if lag < n
                float cov = 0.0
                for i = lag to n - 1
                    cov += (array.get(differences, i) * 100.0 - avg) * (array.get(differences, i - lag) * 100.0 - avg) / n
                longRunVar += 2.0 * (1.0 - lag / 4.0) * cov
        // Constant differences have no estimable long-run variation; do not
        // certify a winner from an artificially zero-width interval.
        if longRunVar > 0.0
            float width = 2.75 * math.sqrt(longRunVar / n)
            ciLo := (avg - width) / 100.0
            ciHi := (avg + width) / 100.0
        avg := avg / 100.0
    [avg, ciLo, ciHi]

// This function executes in the native DAILY context. Pine rolls back changes
// on the realtime unconfirmed daily bar; the caller requests only [1] snapshots.
f_pb_daily_engine(int peakMode, float athReferenceP75, int athReferenceN) =>
    float ma200 = ta.sma(close, 200)
    float ma50 = ta.sma(close, 50)
    // Previous 20 CONFIRMED closes define the alternative local-breakout peak.
    // No future pivot is inspected. Local episodes are non-overlapping and
    // expire at 126 valid daily sessions when the previous peak is unrecovered.
    float prior20High = ta.highest(close, 20)[1]
    bool regimeKnown = not na(ma200[20]) and not na(ma50) and not na(close[63])
    int trendScore = (not na(ma200) and close > ma200 ? 1 : 0) + (not na(ma200[20]) and ma200 > ma200[20] ? 1 : 0) + (not na(ma50) and close > ma50 ? 1 : 0) + (not na(close[63]) and close > close[63] ? 1 : 0)
    int todayRegime = regimeKnown and trendScore >= 3 ? 1 : 0

    var array<float> general21 = array.new_float()
    var array<float> general63 = array.new_float()
    var array<float> general126 = array.new_float()
    var array<float> trend21 = array.new_float()
    var array<float> trend63 = array.new_float()
    var array<float> trend126 = array.new_float()
    var array<float> completeAll = array.new_float()
    var array<float> legacyBars = array.new_float()
    var float latestLegacyP75 = na
    var float latestCompleteP75 = na
    var array<float> pairDiff21 = array.new_float()
    var array<float> pairDiff63 = array.new_float()
    var array<float> pairDiff126 = array.new_float()
    var array<float> referenceMethodDiff63 = array.new_float()
    var float epFrozenAthP75 = na
    var int methodPairedN = 0
    var int methodInformativeN = 0
    var int methodAthHits = 0
    var int methodLocalHits = 0
    var float methodAthTotalLoss = 0.0
    var float methodLocalTotalLoss = 0.0
    var float methodMean = na
    var float methodHacLo = na
    var float methodHacHi = na
    var int methodScreen = 0
    var int methodHalvesPass = 0
    var int methodLooPass = 0

    var float latestPeak = na
    var int peakRegime = 0
    var bool episodeActive = false
    var float epPeak = na
    var int epRegime = 0
    var int epAge = 0
    var float epDepth = 0.0
    var bool matured21 = false
    var bool matured63 = false
    var bool matured126 = false
    var float epGeneral21 = na
    var float epTrend21 = na
    var float epGeneral63 = na
    var float epTrend63 = na
    var float epGeneral126 = na
    var float epTrend126 = na
    var float epReference = na
    var float epPreview = na
    var bool epAdmitted = false
    var bool epTouched = false
    var bool epCrossed = false
    // Event validity begins on the NEXT confirmed daily bar: the first down
    // bar establishes the reference only at its CLOSE, so its intraday high/low
    // cannot legitimately trigger contact/cross alerts on that same bar.
    var int epReferenceActivationBar = na
    var int completedN = 0
    var int timedOutN = 0
    var int informativeN63 = 0
    var int generalOosN = 0
    var int generalOosHits = 0
    var float generalOosPinball = 0.0
    var int pairedOosN = 0
    var int pairedOosHits = 0
    var float trendOosPinball = 0.0
    var int touchSequence = 0
    var int crossSequence = 0
    var float touchAt = na
    var float crossAt = na
    var int touchOn = na
    var int crossOn = na
    var float q21C = na
    var float q63C = na
    var float q126C = na
    var float q21D = na
    var float q63D = na
    var float q126D = na
    var float quantLower = na
    var float quantUpper = na
    var float avgPairDelta = na
    var float lowPairDelta = na
    var int bestMethod = 0
    var int quality = 0

    // Benchmark A: original rolling 30-d close-peak depth in trend bars.
    // It is DESCRIPTIVE and NOT scored as a 63-day episode forecast.
    float barPeak30 = ta.highest(close, 30)
    bool validDay = bar_index >= 260 and not na(open) and not na(close) and open > 0 and close > 0 and not na(low) and not na(high) and low > 0 and low <= math.min(open, close) and high >= math.max(open, close)
    if peakMode == 0 and pbQuantResearch and validDay and todayRegime == 1 and not na(barPeak30) and barPeak30 > 0
        array.push(legacyBars, math.max((barPeak30 - close) / barPeak30, 0.0))
        if array.size(legacyBars) > 756
            array.shift(legacyBars)
        latestLegacyP75 := f_pb_quantile(legacyBars)
    if validDay
        if na(latestPeak)
            // Anchor baseline starts from first valid close. Local candidate
            // waits for a close that breaks above its previous 20-day closes.
            if peakMode == 0 or (not na(prior20High) and close >= prior20High)
                latestPeak := close
                peakRegime := todayRegime
        else if not episodeActive
            if close >= latestPeak
                latestPeak := close
                peakRegime := todayRegime
            else
                // Forecasts freeze at the first confirmed down day, before
                // the subsequent maximum episode depth is known.
                episodeActive := true
                epPeak := latestPeak
                epRegime := peakRegime
                epAge := 1
                epDepth := math.max((epPeak - close) / epPeak, 0.0)
                matured21 := false
                matured63 := false
                matured126 := false
                // Forecast admission: the first 14 completed training episodes
                // support an estimable nonparametric rank interval. Predictions
                // before that point remain descriptive, never enter OOS scores.
                // N=14 is the existing rank-bound technical floor, NOT a
                // claim that 14 observations are universally sufficient.
                epGeneral21 := array.size(general21) >= 14 ? q21C : na
                epTrend21 := array.size(trend21) >= 14 ? q21D : na
                epGeneral63 := array.size(general63) >= 14 ? q63C : na
                // Two FORECASTS of exactly the SAME local-episode target:
                // each frozen at this episode's onset, without future bars.
                // ATH cohort estimator comes from today's independent anchor
                // daily engine, BEFORE the future local outcome can mature.
                epFrozenAthP75 := peakMode == 1 and athReferenceN >= 14 ? athReferenceP75 : na
                epTrend63 := array.size(trend63) >= 14 ? q63D : na
                epGeneral126 := array.size(general126) >= 14 ? q126C : na
                epTrend126 := array.size(trend126) >= 14 ? q126D : na
                epAdmitted := quality == 1 and bestMethod > 0
                float episodeP75 = bestMethod == 2 and not na(q63D) ? q63D : q63C
                epReference := epAdmitted and not na(episodeP75) ? epPeak * (1.0 - episodeP75) : na
                epPreview := not na(episodeP75) ? epPeak * (1.0 - episodeP75) : na
                epTouched := false
                epCrossed := false
                epReferenceActivationBar := bar_index
        else
            epAge += 1
            epDepth := math.max(epDepth, math.max((epPeak - close) / epPeak, 0.0))

        if episodeActive
            bool recovered = close >= epPeak
            bool timedOut = peakMode == 1 and epAge >= 126 and not recovered
            bool changedSamples = false
            if not matured21 and (epAge >= 21 or recovered)
                array.push(general21, epDepth)
                if epRegime == 1
                    array.push(trend21, epDepth)
                    if not na(epGeneral21) and not na(epTrend21)
                        array.push(pairDiff21, f_pb_pinball(epDepth, epGeneral21) - f_pb_pinball(epDepth, epTrend21))
                matured21 := true
                changedSamples := true
            if not matured63 and (epAge >= 63 or recovered)
                array.push(general63, epDepth)
                if not na(epGeneral63)
                    generalOosN += 1
                    generalOosPinball += f_pb_pinball(epDepth, epGeneral63)
                    if epDepth <= epGeneral63
                        generalOosHits += 1
                if epRegime == 1
                    array.push(trend63, epDepth)
                    if not na(epGeneral63) and not na(epTrend63)
                        array.push(pairDiff63, f_pb_pinball(epDepth, epGeneral63) - f_pb_pinball(epDepth, epTrend63))
                        pairedOosN += 1
                        if math.abs(epGeneral63 - epTrend63) > 1e-8
                            informativeN63 += 1
                        if epDepth <= epTrend63
                            pairedOosHits += 1
                        trendOosPinball += f_pb_pinball(epDepth, epTrend63)
                // Paired ATH-vs-local forecast evaluation on the SAME local
                // 63-session outcome and onset. Do not compare their raw OOS
                // coverages, which come from different episode populations.
                if peakMode == 1 and not na(epGeneral63) and not na(epFrozenAthP75)
                    float lossAth = f_pb_pinball(epDepth, epFrozenAthP75)
                    float lossLocal = f_pb_pinball(epDepth, epGeneral63)
                    float pairedDifference = lossAth - lossLocal
                    methodPairedN += 1
                    methodAthTotalLoss += lossAth
                    methodLocalTotalLoss += lossLocal
                    if epDepth <= epFrozenAthP75
                        methodAthHits += 1
                    if epDepth <= epGeneral63
                        methodLocalHits += 1
                    if math.abs(epFrozenAthP75 - epGeneral63) > 1e-8
                        methodInformativeN += 1
                    array.push(referenceMethodDiff63, pairedDifference)
                    [mMean, mLo, mHi] = f_pb_paired_hac99(referenceMethodDiff63)
                    methodMean := mMean
                    methodHacLo := mLo
                    methodHacHi := mHi
                    // Screen is INVESTIGATIVE ONLY. Inadequate sample or
                    // invariant forecasts cannot create a model preference.
                    methodScreen := methodInformativeN == 0 ? 4 : methodPairedN < 30 or methodInformativeN < 14 ? 5 : na(mLo) or na(mHi) ? 6 : 1
                    methodHalvesPass := 0
                    methodLooPass := 0
                    if methodScreen == 1
                        float firstSum = 0.0
                        float secondSum = 0.0
                        float largest = na
                        float smallest = na
                        float allSum = 0.0
                        int splitAt = int(math.floor(methodPairedN / 2.0))
                        for j = 0 to methodPairedN - 1
                            float diff = array.get(referenceMethodDiff63, j)
                            allSum += diff
                            largest := na(largest) ? diff : math.max(largest, diff)
                            smallest := na(smallest) ? diff : math.min(smallest, diff)
                            if j < splitAt
                                firstSum += diff
                            else
                                secondSum += diff
                        bool localHalves = firstSum > 0 and secondSum > 0
                        bool athHalves = firstSum < 0 and secondSum < 0
                        bool localLoo = allSum - largest > 0
                        bool athLoo = allSum - smallest < 0
                        methodHalvesPass := (localHalves or athHalves) ? 1 : 0
                        methodLooPass := (localLoo or athLoo) ? 1 : 0
                        if mLo > 0 and localHalves and localLoo
                            methodScreen := 2  // LOCAL observed advantage only
                        else if mHi < 0 and athHalves and athLoo
                            methodScreen := 3  // ATH observed advantage only
                matured63 := true
                changedSamples := true
            if not matured126 and (epAge >= 126 or recovered)
                array.push(general126, epDepth)
                if epRegime == 1
                    array.push(trend126, epDepth)
                    if not na(epGeneral126) and not na(epTrend126)
                        array.push(pairDiff126, f_pb_pinball(epDepth, epGeneral126) - f_pb_pinball(epDepth, epTrend126))
                matured126 := true
                changedSamples := true

            // Daily events use the frozen level of the episode. No live-day data
            // is exposed to the outer chart because the UDT is offset by 1.
            if epAdmitted and not na(epReference) and not na(epReferenceActivationBar) and bar_index > epReferenceActivationBar
                if not epTouched and low <= epReference and high >= epReference
                    touchSequence += 1
                    touchAt := epReference
                    touchOn := time
                    epTouched := true
                if not epCrossed and ((close[1] > epReference and close <= epReference) or (close[1] < epReference and close >= epReference))
                    crossSequence += 1
                    crossAt := epReference
                    crossOn := time
                    epCrossed := true

            if recovered or timedOut
                if recovered
                    completedN += 1
                    array.push(completeAll, epDepth)
                    latestCompleteP75 := f_pb_quantile(completeAll)
                else
                    // Local benchmark ends at the predeclared 126-session
                    // horizon, NOT as a recovered episode. Its maximum depth
                    // has matured but its full-recovery outcome is censored.
                    timedOutN += 1
                episodeActive := false
                latestPeak := recovered ? close : na
                peakRegime := todayRegime
                epReference := na
                epPreview := na
                epAdmitted := false
                epReferenceActivationBar := na
            if changedSamples
                q21C := f_pb_quantile(general21)
                q63C := f_pb_quantile(general63)
                q126C := f_pb_quantile(general126)
                q21D := f_pb_quantile(trend21)
                q63D := f_pb_quantile(trend63)
                q126D := f_pb_quantile(trend126)
                [ciL, ciH] = f_pb_rank_bounds(general63)
                quantLower := ciL
                quantUpper := ciH
                [dMean, dLower] = f_pb_hac_lower(pairDiff63)
                avgPairDelta := dMean
                lowPairDelta := dLower
                // Evidence screen is intentionally conservative and provisional:
                // Wilson coverage must include 75%, interval <= 30 pp, and
                // the P75 rank range may not exceed its own magnitude.
                [wLo, wHi] = f_pb_wilson_bounds(generalOosHits, generalOosN)
                bool baseCalibrated = not na(wLo) and wLo <= 0.75 and wHi >= 0.75 and wHi - wLo <= 0.30 and not na(quantLower) and not na(quantUpper) and not na(q63C) and quantUpper - quantLower <= q63C
                // D cannot win solely because it has lower observed loss.
                [trendWLo, trendWHi] = f_pb_wilson_bounds(pairedOosHits, pairedOosN)
                [trendRankLo, trendRankHi] = f_pb_rank_bounds(trend63)
                bool trendCalibrated = not na(trendWLo) and trendWLo <= 0.75 and trendWHi >= 0.75 and trendWHi - trendWLo <= 0.30 and not na(trendRankLo) and not na(trendRankHi) and not na(q63D) and trendRankHi - trendRankLo <= q63D
                bool distinctTrainingCohorts = array.size(trend63) < array.size(general63)
                bool informativeForecasts = informativeN63 > 0
                bool trendBeatsGeneral = trendCalibrated and distinctTrainingCohorts and informativeForecasts and not na(lowPairDelta) and lowPairDelta > 0
                int pn = array.size(pairDiff63)
                if trendBeatsGeneral and pn >= 12
                    float fullSum = 0.0
                    float mostPositive = na
                    float early = 0.0
                    float late = 0.0
                    for i = 0 to pn - 1
                        float delta = array.get(pairDiff63, i)
                        fullSum += delta
                        mostPositive := na(mostPositive) ? delta : math.max(mostPositive, delta)
                        if i < int(math.floor(pn / 2.0))
                            early += delta
                        else
                            late += delta
                    bool influencePass = fullSum - mostPositive > 0
                    bool halvesPass = early > 0 and late > 0
                    float h21sum = 0.0
                    float h126sum = 0.0
                    if array.size(pairDiff21) > 0
                        for i = 0 to array.size(pairDiff21) - 1
                            h21sum += array.get(pairDiff21, i)
                    if array.size(pairDiff126) > 0
                        for i = 0 to array.size(pairDiff126) - 1
                            h126sum += array.get(pairDiff126, i)
                    bool horizonsPass = array.size(pairDiff21) > 0 and array.size(pairDiff126) > 0 and h21sum >= 0 and h126sum >= 0
                    trendBeatsGeneral := influencePass and halvesPass and horizonsPass
                else
                    trendBeatsGeneral := false
                if baseCalibrated
                    bestMethod := trendBeatsGeneral ? 2 : 1
                    quality := 1
                else
                    bestMethod := 0
                    quality := 0

    float selectedP75 = bestMethod == 2 and not na(q63D) ? q63D : q63C
    // The currently displayed episode reference is frozen at its START,
    // even if historical cohort estimates update at 63 sessions.
    if episodeActive and not na(epPeak) and epPeak > 0
        if not na(epReference)
            selectedP75 := (epPeak - epReference) / epPeak
        else if not na(epPreview)
            selectedP75 := (epPeak - epPreview) / epPeak
    float reference = episodeActive ? epReference : quality == 1 and not na(latestPeak) and not na(selectedP75) ? latestPeak * (1.0 - selectedP75) : na
    float researchReference = episodeActive ? epPreview : not na(latestPeak) and not na(selectedP75) ? latestPeak * (1.0 - selectedP75) : na
    float observedCoverage = generalOosN > 0 ? generalOosHits * 1.0 / generalOosN : na
    float meanGeneralLoss = generalOosN > 0 ? generalOosPinball / generalOosN : na
    float meanTrendLoss = pairedOosN > 0 ? trendOosPinball / pairedOosN : na
    float stress21 = array.size(pairDiff21) > 0 ? array.sum(pairDiff21) / array.size(pairDiff21) : na
    float stress126 = array.size(pairDiff126) > 0 ? array.sum(pairDiff126) / array.size(pairDiff126) : na
    PbDailySnapshot.new(reference, researchReference, selectedP75, latestLegacyP75, latestCompleteP75, array.size(legacyBars), q63C, q63D, quantLower, quantUpper, array.size(general63), array.size(trend63), completedN, episodeActive ? 1 : 0, generalOosN, pairedOosN, observedCoverage, meanGeneralLoss, meanTrendLoss, avgPairDelta, lowPairDelta, bestMethod, episodeActive and epAdmitted ? 1 : quality, episodeActive ? epRegime : peakRegime, episodeActive ? epAge : 0, stress21, stress126, touchSequence, crossSequence, touchAt, crossAt, touchOn, crossOn,
         timedOutN, informativeN63, array.size(pairDiff21), array.size(pairDiff126),
         array.size(general21), array.size(general126), q21C, q126C,
         methodPairedN, methodInformativeN,
         methodPairedN > 0 ? methodAthTotalLoss / methodPairedN : na,
         methodPairedN > 0 ? methodLocalTotalLoss / methodPairedN : na,
         methodPairedN > 0 ? methodAthHits * 1.0 / methodPairedN : na,
         methodPairedN > 0 ? methodLocalHits * 1.0 / methodPairedN : na,
         methodMean, methodHacLo, methodHacHi, methodScreen, methodHalvesPass, methodLooPass)

// CONSIDERATIONS: This approximate HAC is a predeclared sensitivity screen,
// NOT a calibrated significance test. Quarterly origins reduce mechanical
// outcome overlap, but residual dependence is possible. Never release on it.
f_pb_origin_hac_stress(array<float> differences) =>
    int n = array.size(differences)
    float ciLo = na
    float ciHi = na
    if n >= 32
        float avg = array.sum(differences) / n
        float v0 = 0.0
        for i = 0 to n - 1
            float z = array.get(differences, i) - avg
            v0 += z * z / n
        float largestSE = 0.0
        for test = 0 to 4
            int maxLag = test == 0 ? 0 : test == 1 ? 1 : test == 2 ? 3 : test == 3 ? 6 : 12
            float lrv = v0
            if maxLag > 0
                for lag = 1 to maxLag
                    if lag < n
                        float cov = 0.0
                        for i = lag to n - 1
                            cov += (array.get(differences, i) - avg) * (array.get(differences, i - lag) - avg) / n
                        lrv += 2.0 * (1.0 - lag * 1.0 / (maxLag + 1.0)) * cov
            largestSE := math.max(largestSE, math.sqrt(math.max(0.0, lrv) / n))
        ciLo := avg - 2.75 * largestSE
        ciHi := avg + 2.75 * largestSE
    [ciLo, ciHi]

// FROZEN, CALENDAR-ORIGIN experiment. One possible origin per quarter,
// selected BEFORE the next 63 daily outcomes; skipped if another is pending.
// Forecasts and calendar baseline are all frozen at the origin's CLOSE.
// The target starts on the NEXT daily bar: no same-day target leakage.
// The benchmark uses prior matured outcomes of THIS target, never episodes.
f_pb_calendar_origins(PbDailySnapshot ath, PbDailySnapshot local) =>
    var array<float> maturedCalendarTargets = array.new_float()
    var array<float> pairedLossDiff = array.new_float()
    var int completedTargets = 0
    var int pairedN = 0
    var int tripleN = 0
    var int informativeN = 0
    var int overlapSkips = 0
    var int badWindows = 0
    var int athHits = 0
    var int localHits = 0
    var int tripleAthHits = 0
    var int tripleLocalHits = 0
    var int tripleCalHits = 0
    var float pairedAthTotal = 0.0
    var float pairedLocalTotal = 0.0
    var float tripleAthTotal = 0.0
    var float tripleLocalTotal = 0.0
    var float tripleCalTotal = 0.0
    var float stressLo = na
    var float stressHi = na
    bool newPairScore = false
    var bool activeOrigin = false
    var bool badOrigin = false
    var int futureAge = 0
    var float originClose = na
    var float maxFutureDecline = 0.0
    var float athFrozen = na
    var float localFrozen = na
    var float calFrozen = na

    bool validDaily = not na(open) and not na(high) and not na(low) and not na(close) and open > 0 and close > 0 and low > 0 and low <= math.min(open, close) and high >= math.max(open, close)
    bool newCalendarQuarter = timeframe.change("3M")
    // Score PRIOR origin first. Only after scoring can this day's close be
    // used to issue a NEW forecast, with a future non-overlapping target.
    if activeOrigin
        if not validDaily
            badOrigin := true
        else
            futureAge += 1
            maxFutureDecline := math.max(maxFutureDecline, math.max((originClose - close) / originClose, 0.0))
            if futureAge >= 63
                if badOrigin
                    badWindows += 1
                else
                    completedTargets += 1
                    if not na(athFrozen) and not na(localFrozen)
                        pairedN += 1
                        float athLoss = f_pb_pinball(maxFutureDecline, athFrozen)
                        float localLoss = f_pb_pinball(maxFutureDecline, localFrozen)
                        pairedAthTotal += athLoss
                        pairedLocalTotal += localLoss
                        array.push(pairedLossDiff, athLoss - localLoss)
                        newPairScore := true
                        if math.abs(athFrozen - localFrozen) > 0.00000001
                            informativeN += 1
                        if maxFutureDecline <= athFrozen
                            athHits += 1
                        if maxFutureDecline <= localFrozen
                            localHits += 1
                        if not na(calFrozen)
                            tripleN += 1
                            tripleAthTotal += athLoss
                            tripleLocalTotal += localLoss
                            tripleCalTotal += f_pb_pinball(maxFutureDecline, calFrozen)
                            if maxFutureDecline <= athFrozen
                                tripleAthHits += 1
                            if maxFutureDecline <= localFrozen
                                tripleLocalHits += 1
                            if maxFutureDecline <= calFrozen
                                tripleCalHits += 1
                    // Update baseline ONLY AFTER all forecasts are scored.
                    array.push(maturedCalendarTargets, maxFutureDecline)
                activeOrigin := false
                badOrigin := false
                futureAge := 0
                originClose := na
    if newCalendarQuarter and validDaily
        if activeOrigin
            overlapSkips += 1
        else if bar_index >= 260
            activeOrigin := true
            badOrigin := false
            futureAge := 0
            maxFutureDecline := 0.0
            originClose := close
            athFrozen := ath.allP75
            localFrozen := local.allP75
            calFrozen := array.size(maturedCalendarTargets) >= 14 ? f_pb_quantile(maturedCalendarTargets) : na

    // HAC is recomputed only when one new 63-session OUTCOME matures.
    // Avoid O(N) work repeated on every daily bar.
    if newPairScore
        [nextLo, nextHi] = f_pb_origin_hac_stress(pairedLossDiff)
        stressLo := nextLo
        stressHi := nextHi
    PbOriginAudit.new(completedTargets, pairedN, tripleN, informativeN,
         overlapSkips, badWindows, array.size(maturedCalendarTargets),
         pairedN > 0 ? pairedAthTotal / pairedN : na,
         pairedN > 0 ? pairedLocalTotal / pairedN : na,
         pairedN > 0 ? athHits * 1.0 / pairedN : na,
         pairedN > 0 ? localHits * 1.0 / pairedN : na,
         tripleN > 0 ? tripleAthTotal / tripleN : na,
         tripleN > 0 ? tripleLocalTotal / tripleN : na,
         tripleN > 0 ? tripleCalTotal / tripleN : na,
         tripleN > 0 ? tripleAthHits * 1.0 / tripleN : na,
         tripleN > 0 ? tripleLocalHits * 1.0 / tripleN : na,
         tripleN > 0 ? tripleCalHits * 1.0 / tripleN : na,
         stressLo, stressHi, activeOrigin ? 1 : 0)

// R5.2: run unchanged daily engines only when their outputs are needed.
// An input/view change reloads Pine history, including all OOS observations.
// Never export UDTs not consumed by the active view: requested objects have
// a substantial per-bar memory cost. The 1D forecast offsets stay intact.
f_pb_closed_daily() =>
    PbDailySnapshot anchor = f_pb_daily_engine(0, na, 0)
    PbDailySnapshot local = na
    PbOriginAudit origins = na
    if pbQuantResearch
        local := f_pb_daily_engine(1, anchor.allP75, anchor.episodes63)
        if pbResearchView == "Origins"
            origins := f_pb_calendar_origins(anchor, local)
    // Production P75/alerts remain hard-blocked below; while blocked, an
    // unpreviewed map does not need a historical anchor UDT on the chart.
    // Revisit this delivery gate together with any future release approval.
    bool sendAnchor = (pbQuantResearch and pbResearchView == "Episodes") or pbQuantPreview or pbAlertEnabled
    bool sendLocal = pbQuantResearch and pbResearchView != "Origins"
    bool sendOrigins = pbQuantResearch and pbResearchView == "Origins"
    PbDailyAudit.new(sendAnchor ? anchor[1] : na, sendLocal ? local[1] : na, sendOrigins ? origins[1] : na)

//──────────────────────────────────────────────────────────────────────────────
// Monthly data from TradingView
//──────────────────────────────────────────────────────────────────────────────

int monthStartTime = time("M")

//──────────────────────────────────────────────────────────────────────────────
// Arrays and active state
//──────────────────────────────────────────────────────────────────────────────

var bool strongHighTouched = false
var bool avgHighTouched = false
var bool openTouched = false
var bool avgLowTouched = false
var bool strongLowTouched = false

var array<line> strongHighLines = array.new_line()
var array<line> avgHighLines    = array.new_line()
var array<line> openLines       = array.new_line()
var array<line> avgLowLines     = array.new_line()
var array<line> strongLowLines  = array.new_line()

var array<label> levelLabels = array.new_label()

var line pullbackDeepLine = na
var label pullbackNoteLabel = na

//──────────────────────────────────────────────────────────────────────────────
// Helper functions
//──────────────────────────────────────────────────────────────────────────────

f_count_last(array<float> values, int lookback) =>
    int n = array.size(values)
    int count = lookback == 0 ? n : math.min(n, lookback)
    count

// Same-calendar-month selection, newest observations first.
// The input arrays contain only completed months, in chronological order.
f_season_count(array<int> calendarMonths, int targetMonth, int maxYears) =>
    int n = array.size(calendarMonths)
    int found = 0
    if n > 0
        for offset = 0 to n - 1
            int i = n - 1 - offset
            if array.get(calendarMonths, i) == targetMonth
                found += 1
                if maxYears > 0 and found >= maxYears
                    break
    found

f_season_mean(array<float> values, array<int> calendarMonths, int targetMonth, int maxYears) =>
    int n = array.size(values)
    int found = 0
    float total = 0.0
    if n > 0
        for offset = 0 to n - 1
            int i = n - 1 - offset
            if array.get(calendarMonths, i) == targetMonth
                total += array.get(values, i)
                found += 1
                if maxYears > 0 and found >= maxYears
                    break
    found > 0 ? total / found : na

f_season_stdev(array<float> values, array<int> calendarMonths, int targetMonth, int maxYears, float meanValue) =>
    int n = array.size(values)
    int found = 0
    float sumSq = 0.0
    if n > 0 and not na(meanValue)
        for offset = 0 to n - 1
            int i = n - 1 - offset
            if array.get(calendarMonths, i) == targetMonth
                float delta = array.get(values, i) - meanValue
                sumSq += delta * delta
                found += 1
                if maxYears > 0 and found >= maxYears
                    break
    found > 0 ? math.sqrt(sumSq / found) : na

f_mean_last(array<float> values, int lookback) =>
    int n = array.size(values)
    int count = f_count_last(values, lookback)
    float result = na

    if count > 0
        float sum = 0.0
        for i = 0 to count - 1
            sum += array.get(values, n - 1 - i)
        result := sum / count

    result

f_stdev_last(array<float> values, int lookback) =>
    int n = array.size(values)
    int count = f_count_last(values, lookback)
    float result = na

    if count > 1
        float mean = f_mean_last(values, lookback)
        float sumSq = 0.0

        for i = 0 to count - 1
            float value = array.get(values, n - 1 - i)
            sumSq += math.pow(value - mean, 2)

        result := math.sqrt(sumSq / count)
    else if count == 1
        result := 0.0

    result

f_rate(int numerator, int denominator) =>
    denominator > 0 ? 100.0 * numerator / denominator : na

f_pct(int numerator, int denominator) =>
    denominator > 0 ? str.tostring(100.0 * numerator / denominator, "#.0") + "%" : "N/A"

f_compact_pct(int numerator, int denominator) =>
    denominator > 0 ? str.tostring(100.0 * numerator / denominator, "#") + "%" : "N/A"

f_percentile_last(array<float> values, int lookback, float percentile) =>
    int n = array.size(values)
    int count = lookback == 0 ? n : math.min(n, lookback)
    float result = na

    if count > 0
        array<float> sample = array.new_float()

        for i = 0 to count - 1
            array.push(sample, array.get(values, n - 1 - i))

        array.sort(sample, order.ascending)

        int index = int(math.ceil(count * percentile / 100.0)) - 1
        index := math.max(0, math.min(index, count - 1))

        result := array.get(sample, index)

    result

f_distance_text(float levelValue) =>
    string result = "N/A"

    if not na(levelValue) and close > 0
        float distancePct = 100.0 * (levelValue - close) / close
        string signText = distancePct >= 0 ? "+" : ""
        result := signText + str.tostring(distancePct, "#.0") + "%"

    result

f_price_text(float value) =>
    not na(value) ? str.tostring(value, format.mintick) : "N/A"

f_dynamic_alert_message(string versionText, string levelName, float levelValue, string simText, string baseText, string distanceText, string beyondText, string revertText, string contextText, string lookbackText) =>
    "MonLevels " + versionText +
     " | " + syminfo.ticker + " " + timeframe.period +
     " | " + levelName + " touched" +
     " | Level " + f_price_text(levelValue) +
     " | Close " + f_price_text(close) +
     " | Sim " + simText +
     " | Base " + baseText +
     " | Distance " + distanceText +
     " | Beyond " + beyondText +
     " | Rev " + revertText +
     " | Context " + contextText +
     " | Lookback " + lookbackText +
     " | Historical reference, not a signal."

f_label_pretouch(string levelName, string histTouchText, string contextTouchText, string distanceText, bool showDistance) =>
    showDistance ? levelName + "\nSim " + contextTouchText + " | Base " + histTouchText + " | " + distanceText : levelName + "\nSim " + contextTouchText + " | Base " + histTouchText

f_adaptive_label(string levelName, bool levelTouched, string histTouchText, string contextTouchText, string beyondText, string revertText, string distanceText, bool advanced, bool showDistance) =>
    string labelText = levelName

    if advanced
        if levelTouched
            labelText := levelName + " touched\nBeyond " + beyondText + " | Rev " + revertText
        else
            labelText := f_label_pretouch(levelName, histTouchText, contextTouchText, distanceText, showDistance)

    labelText

f_array_inc(array<int> values, int index) =>
    int currentValue = array.get(values, index)
    array.set(values, index, currentValue + 1)

f_context_bucket(bool previousMonthUp, bool previousRangeHigh, bool openAbovePreviousClose) =>
    int bucket = 0

    if previousMonthUp
        bucket += 1

    if previousRangeHigh
        bucket += 2

    if openAbovePreviousClose
        bucket += 4

    bucket

f_context_label(int bucket) =>
    bool previousMonthUp = bucket == 1 or bucket == 3 or bucket == 5 or bucket == 7
    bool previousRangeHigh = bucket == 2 or bucket == 3 or bucket == 6 or bucket == 7
    bool openAbovePreviousClose = bucket >= 4

    string directionText = previousMonthUp ? "Up" : "Down"
    string rangeText = previousRangeHigh ? "High" : "Normal"
    string openText = openAbovePreviousClose ? "O+" : "O-"

    directionText + " " + rangeText + " " + openText

f_trim_lines(array<line> lines, int maxSize) =>
    while array.size(lines) > maxSize
        line oldLine = array.shift(lines)
        line.delete(oldLine)

f_update_last_x2(array<line> lines, int x2) =>
    int n = array.size(lines)

    if n > 0
        line lastLine = array.get(lines, n - 1)
        line.set_x2(lastLine, x2)

f_current_line_x2(int monthStart, int fallbackTime, int minimumBars) =>
    int secondsPerBar = timeframe.in_seconds(timeframe.period)
    int minimumEndTime = monthStart

    if not na(secondsPerBar) and secondsPerBar > 0
        minimumEndTime := monthStart + minimumBars * secondsPerBar * 1000

    math.max(fallbackTime, minimumEndTime)

f_clear_labels(array<label> labels) =>
    while array.size(labels) > 0
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_add_label(array<label> labels, line levelLine, string labelText, color labelColor) =>
    label newLabel = label.new(
         x = line.get_x2(levelLine),
         y = line.get_y1(levelLine),
         text = labelText,
         xloc = xloc.bar_time,
         style = label.style_label_left,
         textcolor = color.new(labelColor, 20),
         color = color.new(color.white, 100),
         size = lineLabelTextSize,
         tooltip = "† Descriptive history (not a validated probability). ‡ Robust aggregate OOS Base-vs-Sim advantage, not level-specific calibration. Beyond/Between/Revert describe monthly CLOSE after a touch, not trade outcomes."
    )

    array.push(labels, newLabel)

//──────────────────────────────────────────────────────────────────────────────
// Motor 3. Statistical research primitives, computed inside Pine only.
// These intervals are asymptotic/descriptive. A small N is NOT significant.
//──────────────────────────────────────────────────────────────────────────────

f_tcrit_approx(int df) =>
    float z = 1.95996398454005
    float nu = math.max(df, 1)
    z + (z * z * z + z) / (4.0 * nu) + (5.0 * math.pow(z, 5) + 16.0 * z * z * z + 3.0 * z) / (96.0 * nu * nu)

// Bonferroni-corrected Student t quantiles, rounded UP by using the
// largest tabulated degrees of freedom <= estimated df. 13 tests for the
// OOS global/month family; 24 tests for the descriptive calendar side tests.
// The table contains distribution constants, NOT precomputed symbol results.
// For HAC, block df are a conservative finite-sample approximation, NOT an
// exact HAC pivotal law. Stronger dependence requires additional caution.
f_m3_tcrit_bonf(float df, bool family24) =>
    float crit = na
    if df >= 400
        crit := family24 ? 3.09836069 : 2.90750391
    else if df >= 240
        crit := family24 ? 3.11201178 : 2.91893482
    else if df >= 120
        crit := family24 ? 3.14662282 : 2.94787647
    else if df >= 90
        crit := family24 ? 3.17008650 : 2.96746421
    else if df >= 60
        crit := family24 ? 3.21797061 : 3.00735828
    else if df >= 40
        crit := family24 ? 3.29226246 : 3.06904590
    else if df >= 30
        crit := family24 ? 3.36963531 : 3.13303185
    else if df >= 24
        crit := family24 ? 3.45023222 : 3.19941237
    else if df >= 20
        crit := family24 ? 3.53420271 : 3.26828758
    else if df >= 18
        crit := family24 ? 3.59213408 : 3.31564160
    else if df >= 16
        crit := family24 ? 3.66682744 : 3.37650694
    else if df >= 15
        crit := family24 ? 3.71289610 : 3.41394289
    else if df >= 14
        crit := family24 ? 3.76672979 : 3.45759082
    else if df >= 13
        crit := family24 ? 3.83045597 : 3.50912620
    else if df >= 12
        crit := family24 ? 3.90705039 : 3.57088209
    else if df >= 11
        crit := family24 ? 4.00080252 : 3.64620418
    else if df >= 10
        crit := family24 ? 4.11812187 : 3.74006159
    else if df >= 9
        crit := family24 ? 4.26901332 : 3.86015544
    else if df >= 8
        crit := family24 ? 4.46996296 : 4.01906664
    else if df >= 7
        crit := family24 ? 4.75007434 : 4.23877020
    else if df >= 6
        crit := family24 ? 5.16559719 : 4.56117170
    else if df >= 5
        crit := family24 ? 5.83966120 : 5.07639832
    else if df >= 4
        crit := family24 ? 7.09565006 : 6.01542938
    else if df >= 3
        crit := family24 ? 10.07329613 : 8.16245127
    else if df >= 2
        crit := family24 ? 21.87465477 : 16.07796515
    crit


// Jackknife standard error for mean + k*population_stdev, and worst
// leave-one-out influence. The underlying level formulas are unchanged.
f_estimator_uncertainty(array<float> values, array<int> months, int calendarMonth, int maxLookback, bool seasonal, int nEffective, float mu, float sigma, float mult) =>
    float avgHalf = na
    float strongHalf = na
    float looShift = na
    if nEffective >= 7 and not na(mu) and not na(sigma)
        avgHalf := f_tcrit_approx(nEffective - 1) * sigma / math.sqrt(nEffective - 1)
        float total = nEffective * mu
        float sqTotal = nEffective * (sigma * sigma + mu * mu)
        float referenceStrong = mu + mult * sigma
        float meanJ = 0.0
        float m2J = 0.0
        float maxShift = 0.0
        int seen = 0
        int nSource = array.size(values)
        if nSource > 0
            for offset = 0 to nSource - 1
                int ix = nSource - 1 - offset
                if not seasonal or array.get(months, ix) == calendarMonth
                    float x = array.get(values, ix)
                    float looMean = (total - x) / (nEffective - 1)
                    float looVariance = math.max((sqTotal - x * x) / (nEffective - 1) - looMean * looMean, 0.0)
                    float looEstimate = looMean + mult * math.sqrt(looVariance)
                    seen += 1
                    float delta = looEstimate - meanJ
                    meanJ += delta / seen
                    m2J += delta * (looEstimate - meanJ)
                    maxShift := math.max(maxShift, math.abs(looEstimate - referenceStrong))
                    if maxLookback > 0 and seen >= maxLookback
                        break
        if seen == nEffective
            // Descriptive jackknife approximation; not a calibrated small-N guarantee.
            // This uncertainty belongs to the currently selected levels, not the OOS model test.
            strongHalf := 1.96 * math.sqrt(math.max((seen - 1.0) / seen * m2J, 0.0))
            looShift := maxShift / math.max(math.abs(referenceStrong), 0.001)
    [avgHalf, strongHalf, looShift]

// Paired strictly OOS monthly loss comparison: d = loss(NS) - loss(S).
// 13-test Bonferroni family (global + 12 calendar months). This returns an
// APPROXIMATE conservative HAC interval, not a calibrated guaranteed coverage.
// R2.3 adds Bartlett bandwidth sensitivity, positive-autocorrelation envelope,
// finite-sample block-t cutoff and exhaustive single-deletion sign robustness.
// First/second-half, both-direction and historical-window checks remain.
// For All, the recent-half benchmark overlaps the full-history data: it is
// a recency sensitivity test, NOT an independent sample or matched horizon.
f_paired_model_evidence(array<float> diffs, array<float> upDiffs, array<float> downDiffs, array<float> horizonDiffs, array<float> seasonLosses, array<float> generalLosses, array<float> seasonHighLosses, array<float> generalHighLosses, array<float> seasonLowLosses, array<float> generalLowLosses, array<int> months, int filterMonth, int maxEvaluations, int minEvaluations, int maxLag, float minImprovementPct) =>
    int nSource = array.size(diffs)
    array<float> included = array.new_float()
    int n = 0
    float sumD = 0.0
    float sumUp = 0.0
    float sumDown = 0.0
    float sumH = 0.0
    float sumS = 0.0
    float sumG = 0.0
    float sumSeasonHigh = 0.0
    float sumGeneralHigh = 0.0
    float sumSeasonLow = 0.0
    float sumGeneralLow = 0.0
    float maxD = na
    float minD = na
    if nSource > 0
        for offset = 0 to nSource - 1
            int ix = nSource - 1 - offset
            if filterMonth == 0 or array.get(months, ix) == filterMonth
                float d = array.get(diffs, ix)
                array.push(included, d)
                n += 1
                sumD += d
                sumUp += array.get(upDiffs, ix)
                sumDown += array.get(downDiffs, ix)
                sumH += array.get(horizonDiffs, ix)
                sumS += array.get(seasonLosses, ix)
                sumG += array.get(generalLosses, ix)
                sumSeasonHigh += array.get(seasonHighLosses, ix)
                sumGeneralHigh += array.get(generalHighLosses, ix)
                sumSeasonLow += array.get(seasonLowLosses, ix)
                sumGeneralLow += array.get(generalLowLosses, ix)
                maxD := na(maxD) ? d : math.max(maxD, d)
                minD := na(minD) ? d : math.min(minD, d)
                if maxEvaluations > 0 and n >= maxEvaluations
                    break
    int winner = 0
    float gainPct = na
    float ciLo = na
    float ciHi = na
    float seasonalMae = na
    float generalMae = na
    float horizonMean = na
    float advantageHigh = na
    float advantageLow = na
    float seasonHighMae = na
    float generalHighMae = na
    float seasonLowMae = na
    float generalLowMae = na
    // Reason codes: 0 winner, 1 not enough bandwidth blocks, 2 CI crosses 0,
    // 3 sides disagree, 4 temporal halves disagree, 5 exhaustive LOO unstable,
    // 6 historical-window sensitivity disagrees; 7 advantage too small; 8 variance invalid.
    int evidenceReason = 1
    // Longer lag for year-to-year month comparisons as N grows; keeps the
    // HAC window responsive to serial dependence rather than always using 1.
    int lagCount = filterMonth == 0 ? math.min(maxLag, math.max(0, n - 1)) : math.min(math.min(maxLag, int(math.floor(math.pow(math.max(n, 1), 1.0 / 3.0)))), math.max(0, n - 1))
    int effectiveMinN = math.max(minEvaluations, 3 * (lagCount + 1))
    if n >= effectiveMinN and lagCount >= 1
        float mu = sumD / n
        seasonalMae := sumS / n
        generalMae := sumG / n
        horizonMean := sumH / n
        advantageHigh := sumUp / n
        advantageLow := sumDown / n
        seasonHighMae := sumSeasonHigh / n
        generalHighMae := sumGeneralHigh / n
        seasonLowMae := sumSeasonLow / n
        generalLowMae := sumGeneralLow / n
        gainPct := 100.0 * mu / math.max(generalMae, 0.0000001)
        float gamma0Sum = 0.0
        float firstHalf = 0.0
        float secondHalf = 0.0
        int halfCount = int(math.floor(n / 2.0))
        for j = 0 to n - 1
            float d = array.get(included, j)
            gamma0Sum += math.pow(d - mu, 2)
            if j < halfCount
                firstHalf += d
            else
                secondHalf += d
        float gamma0 = gamma0Sum / n
        float varianceFull = gamma0
        float varianceHalf = gamma0
        float varianceQuarter = gamma0
        float gamma1 = 0.0
        int halfLag = math.max(1, int(math.floor(lagCount / 2.0)))
        int quarterLag = math.max(1, int(math.floor(lagCount / 4.0)))
        for k = 1 to lagCount
            float cross = 0.0
            for j = k to n - 1
                cross += (array.get(included, j) - mu) * (array.get(included, j - k) - mu)
            float gammaK = cross / n
            if k == 1
                gamma1 := gammaK
            varianceFull += 2.0 * (1.0 - k / (lagCount + 1.0)) * gammaK
            if k <= halfLag
                varianceHalf += 2.0 * (1.0 - k / (halfLag + 1.0)) * gammaK
            if k <= quarterLag
                varianceQuarter += 2.0 * (1.0 - k / (quarterLag + 1.0)) * gammaK
        // Conservative AR(1)-style positive-persistence sensitivity envelope.
        // This is an additional guard, NOT proof that the process is AR(1).
        float rho1 = gamma0 > 0.000000000001 ? math.max(0.0, math.min(0.85, gamma1 / gamma0)) : 0.0
        float varianceAr1 = gamma0 * (1.0 + rho1) / (1.0 - rho1)
        float robustVariance = math.max(math.max(varianceFull, varianceHalf), math.max(varianceQuarter, varianceAr1))
        float varianceInflation = n > lagCount + 1 ? n / (n - lagCount - 1.0) : na
        float se = robustVariance > 0.0 and not na(varianceInflation) ? math.sqrt(robustVariance * varianceInflation / n) : na
        // At least three effectively independent Bartlett-width blocks.
        float blockDf = math.floor(n / (lagCount + 1.0)) - 1.0
        float cutoff = f_m3_tcrit_bonf(blockDf, false)
        bool reliableVariance = not na(se) and se > 0.0000000001 and not na(cutoff)
        if reliableVariance
            ciLo := mu - cutoff * se
            ciHi := mu + cutoff * se
        int ciDirection = reliableVariance ? (ciLo > 0 ? 1 : ciHi < 0 ? -1 : 0) : 0
        bool halvesAgree = ciDirection == 1 ? (firstHalf > 0 and secondHalf > 0) : ciDirection == -1 ? (firstHalf < 0 and secondHalf < 0) : false
        // Exact all-single-deletions sign criterion in O(N): for positive sum,
        // the worst deletion removes MAX(d); for negative sum, removes MIN(d).
        bool looAgrees = ciDirection == 1 ? sumD - maxD > 0 : ciDirection == -1 ? sumD - minD < 0 : false
        bool horizonAgrees = ciDirection == 1 ? horizonMean > 0 : ciDirection == -1 ? horizonMean < 0 : false
        bool sidesAgree = ciDirection == 1 ? (advantageHigh >= 0 and advantageLow >= 0) : ciDirection == -1 ? (advantageHigh <= 0 and advantageLow <= 0) : false
        bool materialGain = not na(gainPct) and math.abs(gainPct) >= minImprovementPct
        if not reliableVariance
            evidenceReason := 8
        else if ciDirection == 0
            evidenceReason := 2
        else if not sidesAgree
            evidenceReason := 3
        else if not halvesAgree
            evidenceReason := 4
        else if not looAgrees
            evidenceReason := 5
        else if not horizonAgrees
            evidenceReason := 6
        else if not materialGain
            evidenceReason := 7
        else
            winner := ciDirection
            evidenceReason := 0
    [winner, n, gainPct, ciLo, ciHi, seasonalMae, generalMae, horizonMean, advantageHigh, advantageLow, seasonHighMae, generalHighMae, seasonLowMae, generalLowMae, evidenceReason]

// Welch-Satterthwaite comparison: same calendar month vs OTHER months.
// Uses independent-sample t approximation (descriptive; monthly dependence
// can violate that assumption). Bonferroni correction over 12 x 2 = 24 tests.
// Returns signed t/t_critical.  |value| > 1 passes the nominal corrected test.
// This is NOT an input to the OOS model recommendation.
// Numerically use percentage-point units inside this test only: Pine float
// comparisons round operands to 9 decimals; tiny squared mean-variance
// denominators in fractional units could compare equal to zero. Scaling both
// samples by 100 leaves Welch t and its degrees of freedom unchanged.
f_seasonal_effect_t_ratio(array<float> values, array<int> months, int currentMonth, int trailingCalendarMonths) =>
    float ratio = na
    int nSource = array.size(values)
    int n1 = 0
    int n2 = 0
    float s1 = 0.0
    float s2 = 0.0
    float q1 = 0.0
    float q2 = 0.0
    int seen = 0
    if nSource > 0
        for off = 0 to nSource - 1
            int ix = nSource - 1 - off
            float x = array.get(values, ix) * 100.0
            if array.get(months, ix) == currentMonth
                n1 += 1
                s1 += x
                q1 += x * x
            else
                n2 += 1
                s2 += x
                q2 += x * x
            seen += 1
            if trailingCalendarMonths > 0 and seen >= trailingCalendarMonths
                break
    if n1 >= 7 and n2 >= 7
        float m1 = s1 / n1
        float m2 = s2 / n2
        float v1 = math.max((q1 - s1 * s1 / n1) / (n1 - 1.0), 0.0)
        float v2 = math.max((q2 - s2 * s2 / n2) / (n2 - 1.0), 0.0)
        float a = v1 / n1
        float b = v2 / n2
        float varianceMeanDiff = a + b
        float dfDenominator = a * a / (n1 - 1.0) + b * b / (n2 - 1.0)
        float dfWelch = dfDenominator > 0 ? math.pow(varianceMeanDiff, 2) / dfDenominator : na
        float critical = f_m3_tcrit_bonf(dfWelch, true)
        float se = varianceMeanDiff > 0 ? math.sqrt(varianceMeanDiff) : na
        ratio := not na(critical) and not na(se) ? (m1 - m2) / (se * critical) : na
    ratio

// Explain model selection without converting descriptive measures into a signal.
f_m3_reason_text(int reasonCode, bool usingAll) =>
    switch reasonCode
        0 => "Evidence passed"
        1 => "OOS N insufficient"
        2 => "HAC includes zero"
        3 => "High / low disagree"
        4 => "Not stable over time"
        5 => "Single month influence"
        6 => usingAll ? "Recent-half check fails" : "Horizon check fails"
        7 => "Improvement too small"
        8 => "HAC variance invalid"
        9 => "Month contradicts global"
        10 => "Monthly source conflict"
        => "No robust winner"

// Green/red are deliberately muted. Neutral results are uncolored/gray.
f_m3_cell_text_color(int leader, int side) =>
    leader == 0 ? color.new(chart.fg_color, 45) : leader == side ? color.new(color.teal, 18) : color.new(color.maroon, 36)

f_m3_cell_background(int leader, int side) =>
    leader == 0 ? color.new(chart.bg_color, 100) : leader == side ? color.new(color.teal, 93) : color.new(color.maroon, 95)

f_m3_direction_from_ci(float lo, float hi) =>
    na(lo) or na(hi) ? 0 : lo > 0 ? 1 : hi < 0 ? -1 : 0

f_m3_delta_text(float val) =>
    na(val) ? "N/A" : (val >= 0 ? "+" : "") + str.tostring(val, "#.##")

f_m3_ci_text(float lo, float hi) =>
    na(lo) or na(hi) ? "N/A" : "[" + f_m3_delta_text(lo * 100.0) + "; " + f_m3_delta_text(hi * 100.0) + "]"

//──────────────────────────────────────────────────────────────────────────────
// Motor 4: quality-aware, PREQUENTIAL reaction observations.
// Proportions are descriptive; Wilson intervals assume approx. independence.
// The OOS comparison is a conservative, approximate paired HAC screening test,
// not a guaranteed calibration of either forecasting probability.
//──────────────────────────────────────────────────────────────────────────────
f_m4_wilson_half(int count, int total) =>
    float half = na
    if total > 0
        float z = 1.95996398454005
        float phat = count / float(total)
        float zsq = z * z
        half := z * math.sqrt(phat * (1.0 - phat) / total + zsq / (4.0 * total * total)) / (1.0 + zsq / total)
    half

f_m4_wilson_bounds(int count, int total) =>
    float lo = na
    float hi = na
    if total > 0
        float zsq = 1.95996398454005 * 1.95996398454005
        float phat = count / float(total)
        float center = (phat + zsq / (2.0 * total)) / (1.0 + zsq / total)
        float half = f_m4_wilson_half(count, total)
        lo := math.max(0.0, center - half)
        hi := math.min(1.0, center + half)
    [lo, hi]

f_m4_rate_tooltip(int hits, int trials, string title) =>
    [lowBound, highBound] = f_m4_wilson_bounds(hits, trials)
    trials <= 0 ? title + ": N unavailable" : title + " · " + str.tostring(hits) + "/" + str.tostring(trials) + " · Wilson 95% [" + str.tostring(lowBound * 100.0, "#.0") + "% ; " + str.tostring(highBound * 100.0, "#.0") + "%] · Descriptive, approximately independent observations assumed."

// Per-level Base and Sim frequencies are DESCRIPTIVE. Global paired OOS
// support never validates an individual row.  Only aggregate decisions use ‡.
f_m4_pro_text(int hits, int trials, bool deep, int favored, int side) =>
    trials <= 0 ? "N insuf." : deep ? f_compact_pct(hits, trials) + "†" : "Evid. insuf."

// D = Brier(Base) - Brier(Sim); D > 0 favors Sim. One observation is ONE
// monthly mean over available levels, NOT four independent observations.
f_m4_evidence(array<float> differences, array<float> baseLosses, array<float> simLosses, array<float> upsideDiffs, array<float> downsideDiffs, array<float> baseResiduals, array<float> simResiduals, int maxWindow) =>
    int total = array.size(differences)
    int n = maxWindow == 0 ? total : math.min(total, maxWindow)
    float baseBrier = na
    float simBrier = na
    float m4CiLower = na
    float m4CiUpper = na
    float baseCalibrationGap = na
    float simCalibrationGap = na
    int favored = 0
    int reason = 1 // 1 insufficient; 2 CI includes 0; 3 halves; 4 LOO; 5 high/low disagree; 6 variance invalid
    if n > 0
        float sumD = 0.0
        float sumBase = 0.0
        float sumSim = 0.0
        float sumHigh = 0.0
        float sumLow = 0.0
        float sumBaseResidual = 0.0
        float sumSimResidual = 0.0
        float minDiff = 1e20
        float maxDiff = -1e20
        float firstHalf = 0.0
        float secondHalf = 0.0
        int halfN = int(math.floor(n / 2.0))
        for j = 0 to n - 1
            int ix = total - n + j
            float d = array.get(differences, ix)
            sumD += d
            sumBase += array.get(baseLosses, ix)
            sumSim += array.get(simLosses, ix)
            sumHigh += array.get(upsideDiffs, ix)
            sumLow += array.get(downsideDiffs, ix)
            sumBaseResidual += array.get(baseResiduals, ix)
            sumSimResidual += array.get(simResiduals, ix)
            minDiff := math.min(minDiff, d)
            maxDiff := math.max(maxDiff, d)
            if j < halfN
                firstHalf += d
            else
                secondHalf += d
        float mu = sumD / n
        baseBrier := sumBase / n
        simBrier := sumSim / n
        baseCalibrationGap := math.abs(sumBaseResidual / n)
        simCalibrationGap := math.abs(sumSimResidual / n)
        int lags = math.min(6, math.max(1, int(math.floor(math.pow(n, 1.0 / 3.0)))))
        float blockDf = math.floor(n / (lags + 1.0)) - 1.0
        float critical = f_m3_tcrit_bonf(blockDf, false)
        if n >= 3 * (lags + 1) and not na(critical)
            float gamma0Sum = 0.0
            for j = 0 to n - 1
                float centered = array.get(differences, total - n + j) - mu
                gamma0Sum += centered * centered
            float gamma0 = gamma0Sum / n
            float longVariance = gamma0
            float gamma1 = 0.0
            for k = 1 to lags
                float cross = 0.0
                for j = k to n - 1
                    cross += (array.get(differences, total - n + j) - mu) * (array.get(differences, total - n + j - k) - mu)
                float gammaK = cross / n
                longVariance += 2.0 * (1.0 - k / (lags + 1.0)) * gammaK
                if k == 1
                    gamma1 := gammaK
            float rho = gamma0 > 0.000000001 ? math.max(0.0, math.min(0.85, gamma1 / gamma0)) : 0.0
            float robustVar = math.max(math.max(gamma0, longVariance), gamma0 * (1.0 + rho) / (1.0 - rho))
            float correction = n > lags + 1 ? n / (n - lags - 1.0) : na
            float se = robustVar > 0.000000001 and not na(correction) ? math.sqrt(robustVar * correction / n) : na
            if not na(se)
                m4CiLower := mu - critical * se
                m4CiUpper := mu + critical * se
                int direction = m4CiLower > 0 ? 1 : m4CiUpper < 0 ? -1 : 0
                bool halves = direction == 1 ? firstHalf > 0 and secondHalf > 0 : direction == -1 ? firstHalf < 0 and secondHalf < 0 : false
                bool loo = direction == 1 ? sumD - maxDiff > 0 : direction == -1 ? sumD - minDiff < 0 : false
                bool sides = direction == 1 ? (sumHigh >= 0 and sumLow >= 0) : direction == -1 ? (sumHigh <= 0 and sumLow <= 0) : false
                reason := direction == 0 ? 2 : not halves ? 3 : not loo ? 4 : not sides ? 5 : 0
                favored := reason == 0 ? direction : 0
            else
                reason := 6
    [n, baseBrier, simBrier, m4CiLower, m4CiUpper, favored, reason, baseCalibrationGap, simCalibrationGap]

f_m4_reason_text(int code) =>
    switch code
        0 => "Robust OOS evidence"
        1 => "OOS N insuf."
        2 => "HAC inconclusive"
        3 => "Half-period mismatch"
        4 => "Single-month sensitivity"
        5 => "High/Low conflict"
        6 => "Variance unavailable"
        7 => "Monthly source conflict"
        8 => "Invalid monthly OHLC: M4 evidence blocked"
        => "No validated preference"

//──────────────────────────────────────────────────────────────────────────────
// M5.2. EXPERIMENTAL context ablation, independent of operating M4.
// A: previous-month direction; B: previous range versus its pre-month mean;
// C: current-month open relative to previous close. A/B/C have neutral states.
// A neutral or unsupported requested factor => explicit Base fallback, NOT Up.
// Integer arithmetic rather than Pine bitwise operators for masks 0..7.
// The 8 masks enumerate Base, A, B, C, A+B, A+C, B+C, A+B+C.
//──────────────────────────────────────────────────────────────────────────────
f_m5_subset(int requiredMask, int validMask) =>
    (requiredMask % 2 == 0 or validMask % 2 == 1) and (requiredMask % 4 < 2 or validMask % 4 >= 2) and (requiredMask < 4 or validMask >= 4)

f_m5_pattern(int mask, int positiveBits) =>
    (mask % 2 == 1 and positiveBits % 2 == 1 ? 1 : 0) + (mask % 4 >= 2 and positiveBits % 4 >= 2 ? 2 : 0) + (mask >= 4 and positiveBits >= 4 ? 4 : 0)

f_m5_bin(int mask, int positiveBits) =>
    mask * 8 + f_m5_pattern(mask, positiveBits)

f_m5_support(array<int> counts, int mask, int positiveBits, int validMask) =>
    f_m5_subset(mask, validMask) ? array.get(counts, f_m5_bin(mask, positiveBits)) : 0

// Same Jeffreys half-count smoothing for ALL eight alternatives, including
// Base, so tiny conditional samples cannot silently imply 0% or 100% certainty.
// Model with neutral/unavailable features or zero eligible history falls back
// to Base on THAT monthly forecast; no OOS event is removed post-outcome.
f_m5_forecast(array<int> counts, array<int> ah, array<int> sh, array<int> al, array<int> sl, int mask, int positiveBits, int validMask, int levelIndex) =>
    int index = f_m5_bin(mask, positiveBits)
    if not f_m5_subset(mask, validMask) or array.get(counts, index) <= 0
        index := 0
    int n = array.get(counts, index)
    int hits = levelIndex == 0 ? array.get(ah, index) : levelIndex == 1 ? array.get(sh, index) : levelIndex == 2 ? array.get(al, index) : array.get(sl, index)
    n > 0 ? (hits + 0.5) / (n + 1.0) : na

// A label is a MODEL, not an independently validated effect.
f_m5_model_label(int mask) =>
    switch mask
        0 => "Base"
        1 => "A · Direction"
        2 => "B · Range"
        3 => "A+B"
        4 => "C · Open"
        5 => "A+C"
        6 => "B+C"
        => "A+B+C"

// ── M5.3 statistical SCREEN. The seven models compete with the SAME Base
// on the SAME completed months. Returns a status, not an operational winner.
// 0=N not adequate for an approximate dependence CI; 1=CI includes zero;
// 2=temporal halves disagree; 3=any one-deletion overturns the sign;
// 4=additional B/C perturbation not passed or not yet assessed;
// 5=positive core screen (NOT an approved context recommendation).
// The cutoff is the existing 13-test Bonferroni t-table, intentionally more
// conservative than the seven comparisons made here. HAC block degrees of
// freedom are approximate; the CI is not guaranteed coverage.
f_m5_screen(array<float> diffRing, array<float> sums, array<float> squares, array<float> rawLag, int ever, int window, int mask, float baseBrier, float candidateBrier, array<float> altBriers) =>
    int n = window > 0 ? math.min(ever, window) : ever
    int status = 0
    float ciLo = na
    float ciHi = na
    int L = math.min(12, n - 1)
    if n >= 3 * (L + 1) and L >= 1 and not na(baseBrier) and not na(candidateBrier)
        float total = array.get(sums, mask)
        float mu = total / n
        float variance0 = math.max(array.get(squares, mask) / n - mu * mu, 0.0)
        float vFull = variance0
        float vHalf = variance0
        float vQuarter = variance0
        float gamma1 = 0.0
        int hLag = math.max(1, int(math.floor(L / 2.0)))
        int qLag = math.max(1, int(math.floor(L / 4.0)))
        // Raw cross-products are incrementally maintained only when a fully
        // confirmed monthly outcome is scored. Edge terms center gamma(k).
        for k = 1 to L
            float firstK = 0.0
            float lastK = 0.0
            for edge = 0 to k - 1
                int ixFirst = ever - n + edge
                int ixLast = ever - 1 - edge
                int firstSlot = window > 0 ? (ixFirst % window) * 8 + mask : ixFirst * 8 + mask
                int lastSlot = window > 0 ? (ixLast % window) * 8 + mask : ixLast * 8 + mask
                firstK += array.get(diffRing, firstSlot)
                lastK += array.get(diffRing, lastSlot)
            float centeredCross = array.get(rawLag, mask * 13 + k) - mu * (2.0 * total - firstK - lastK) + (n - k) * mu * mu
            float gamma = centeredCross / n
            if k == 1
                gamma1 := gamma
            vFull += 2.0 * (1.0 - k / (L + 1.0)) * gamma
            if k <= hLag
                vHalf += 2.0 * (1.0 - k / (hLag + 1.0)) * gamma
            if k <= qLag
                vQuarter += 2.0 * (1.0 - k / (qLag + 1.0)) * gamma
        float rho = variance0 > 0.000000000001 ? math.max(0.0, math.min(0.85, gamma1 / variance0)) : 0.0
        float vAr = variance0 * (1.0 + rho) / (1.0 - rho)
        float vRobust = math.max(math.max(vFull, vHalf), math.max(vQuarter, vAr))
        float inflate = n > L + 1 ? n / (n - L - 1.0) : na
        float se = not na(inflate) and vRobust > 0 ? math.sqrt(vRobust * inflate / n) : na
        float dfBlock = math.floor(n / (L + 1.0)) - 1.0
        float critical = f_m3_tcrit_bonf(dfBlock, false)
        if not na(se) and se > 0.0000000001 and not na(critical)
            ciLo := mu - critical * se
            ciHi := mu + critical * se
            status := 1
            if ciLo > 0
                float early = 0.0
                float late = 0.0
                float maxD = na
                int nEarly = int(math.floor(n / 2.0))
                for j = 0 to n - 1
                    int ix = ever - n + j
                    int slot = window > 0 ? (ix % window) * 8 + mask : ix * 8 + mask
                    float d = array.get(diffRing, slot)
                    if j < nEarly
                        early += d
                    else
                        late += d
                    maxD := na(maxD) ? d : math.max(maxD, d)
                status := early > 0 and late > 0 ? 3 : 2
                if status == 3 and total - maxD > 0
                    status := 5
                    // Only B+C has *actual* C/B stress forecasts in this
                    // scope. Other B/C combinations remain unverified, so
                    // none can be misrepresented as fully robust.
                    if mask == 6
                        for variant = 0 to 3
                            float perturbed = array.get(altBriers, variant)
                            if na(perturbed) or perturbed >= baseBrier
                                status := 4
                    else if mask % 4 >= 2 or mask >= 4
                        status := 4
    [status, ciLo, ciHi]

// Four predeclared B+C shadow specifications: gap C neutral at 1/5 bp,
// and factor B using trailing 120/360 months. They forecast on the exact
// same monthly dates, with no current-month outcome in their estimates.
f_m5_alt_bin(int variant, int positiveBits) =>
    variant * 4 + (positiveBits % 4 >= 2 ? 1 : 0) + (positiveBits >= 4 ? 2 : 0)

f_m5_alt_probability(array<int> nBin, array<int> ahBin, array<int> shBin, array<int> alBin, array<int> slBin, int variant, int positiveBits, int validBits, int level, float basePrediction) =>
    int bin = f_m5_alt_bin(variant, positiveBits)
    if not f_m5_subset(6, validBits) or array.get(nBin, bin) <= 0
        basePrediction
    else
        int n = array.get(nBin, bin)
        int h = level == 0 ? array.get(ahBin, bin) : level == 1 ? array.get(shBin, bin) : level == 2 ? array.get(alBin, bin) : array.get(slBin, bin)
        (h + 0.5) / (n + 1.0)

// Motor 2 verified monthly anchor; Motor 3 adds side-by-side forecasting.
// Monthly-only statistical engine, evaluated in monthly context by request.security().
// All counters and historical arrays belong to the requested MONTHLY context.
// Chart timeframes cannot truncate this engine to their intraday bar history.
f_monthly_engine() =>
    var array<float> highExtensions = array.new_float()
    var array<float> lowExtensions = array.new_float()
    var array<float> rangeExtensions = array.new_float()
    var array<int> extensionCalendarMonths = array.new_int()
    var array<int> extensionCalendarYears = array.new_int()
    var int identicalDuplicateRows = 0
    var int conflictingDuplicateRows = 0

    // Forecasts fixed at the beginning of the month being evaluated.
    var float forecastSeasonUp = na
    var float forecastSeasonDown = na
    var float forecastGeneralUp = na
    var float forecastGeneralDown = na
    var float forecastHorizonUp = na
    var float forecastHorizonDown = na
    var array<float> wfPairedDiff = array.new_float()
    var array<float> wfUpDiff = array.new_float()
    var array<float> wfDownDiff = array.new_float()
    var array<float> wfMatchedHorizonDiff = array.new_float()
    var array<float> wfSeasonLoss = array.new_float()
    var array<float> wfGeneralLoss = array.new_float()
    var array<float> wfSeasonHighLoss = array.new_float()
    var array<float> wfGeneralHighLoss = array.new_float()
    var array<float> wfSeasonLowLoss = array.new_float()
    var array<float> wfGeneralLowLoss = array.new_float()
    var array<int> wfCalendarMonth = array.new_int()
    // M4: distinct eligibility denominators, quality counters, and causal OOS.
    var int eligibleAH = 0
    var int eligibleSH = 0
    var int eligibleAL = 0
    var int eligibleSL = 0
    var int flatMonthsM4 = 0
    var int invalidMonthsM4 = 0
    var int degenerateLevelsM4 = 0
    var int unavailableLevelsM4 = 0
    // Same-cohort diagnostic only: months where ALL four level directions
    // were valid. Does not modify Base or Sim denominators / evidence.
    var int commonEligibleM4 = 0
    var int commonTouchAHM4 = 0
    var int commonTouchSHM4 = 0
    var int commonTouchALM4 = 0
    var int commonTouchSLM4 = 0
    // Ex-post FLAT sensitivity: never used for forecasts or eligibility.
    var int m4NonflatAH = 0
    var int m4NonflatSH = 0
    var int m4NonflatAL = 0
    var int m4NonflatSL = 0
    var int m4NonflatTouchesAH = 0
    var int m4NonflatTouchesSH = 0
    var int m4NonflatTouchesAL = 0
    var int m4NonflatTouchesSL = 0
    var array<int> contextEligibleAH = array.new_int(8, 0)
    var array<int> contextEligibleSH = array.new_int(8, 0)
    var array<int> contextEligibleAL = array.new_int(8, 0)
    var array<int> contextEligibleSL = array.new_int(8, 0)
    var array<int> contextContainedEligible = array.new_int(8, 0)
    var float m4ForecastBaseAH = na
    var float m4ForecastBaseSH = na
    var float m4ForecastBaseAL = na
    var float m4ForecastBaseSL = na
    var float m4ForecastSimAH = na
    var float m4ForecastSimSH = na
    var float m4ForecastSimAL = na
    var float m4ForecastSimSL = na
    var bool m4ForecastReady = false
    var array<float> m4LossDiff = array.new_float()
    var array<float> m4BaseLoss = array.new_float()
    var array<float> m4SimLoss = array.new_float()
    var array<float> m4HighDiff = array.new_float()
    var array<float> m4LowDiff = array.new_float()
    var array<float> m4BaseResidual = array.new_float()
    var array<float> m4SimResidual = array.new_float()
    var array<int> contextEligible = array.new_int(8, 0)
    var array<int> contextContainedMonths = array.new_int(8, 0)
    var array<int> contextAvgHighTouches = array.new_int(8, 0)
    var array<int> contextStrongHighTouches = array.new_int(8, 0)
    var array<int> contextAvgLowTouches = array.new_int(8, 0)
    var array<int> contextStrongLowTouches = array.new_int(8, 0)
    var float activeStrongHighLevel = na
    var float activeAvgHighLevel = na
    var float activeOpenLevel = na
    var float activeAvgLowLevel = na
    var float activeStrongLowLevel = na
    var int eligibleMonths = 0
    var int containedMonths = 0
    var int avgHighTouches = 0
    var int avgHighCloseBeyond = 0
    var int avgHighBetween = 0
    var int avgHighRevertOpen = 0
    var int strongHighTouches = 0
    var int strongHighCloseBeyond = 0
    var int strongHighBetween = 0
    var int strongHighRevertOpen = 0
    var int avgLowTouches = 0
    var int avgLowCloseBeyond = 0
    var int avgLowBetween = 0
    var int avgLowRevertOpen = 0
    var int strongLowTouches = 0
    var int strongLowCloseBeyond = 0
    var int strongLowBetween = 0
    var int strongLowRevertOpen = 0
    // M5.2 RESEARCH ONLY. Separate incremental counts on a common valid-four-
    // level training cohort. No change to existing M4 context or denominators.
    var array<int> m5BinN = array.new_int(64, 0)
    var array<int> m5BinAH = array.new_int(64, 0)
    var array<int> m5BinSH = array.new_int(64, 0)
    var array<int> m5BinAL = array.new_int(64, 0)
    var array<int> m5BinSL = array.new_int(64, 0)
    var array<float> m5Pred = array.new_float(32, na)
    var array<float> m5LossSum = array.new_float(8, 0.0)
    var array<float> m5LossRing = array.new_float()
    var int m5EvaluationsEver = 0
    var int m5TrainingMonths = 0
    var int m5NeutralTrainingMonths = 0
    var int m5FrozenPositive = 0
    var int m5FrozenValid = 0
    var bool m5ForecastReady = false
    // M5.3 scratch/moments are isolated from all operating motors. They are
    // dormant unless both research switches are enabled. Differentials are
    // Base Brier minus candidate Brier; positive favors the candidate.
    var array<float> m5DifferenceRing = array.new_float()
    var array<float> m5DifferenceSum = array.new_float(8, 0.0)
    var array<float> m5DifferenceSq = array.new_float(8, 0.0)
    var array<float> m5RawLag = array.new_float(8 * 13, 0.0)
    // Actual paired OOS refits for four B+C perturbations. 4 variants x
    // 4 possible two-bit classifications, not 64 bins per variant.
    var array<int> m5AltN = array.new_int(16, 0)
    var array<int> m5AltAH = array.new_int(16, 0)
    var array<int> m5AltSH = array.new_int(16, 0)
    var array<int> m5AltAL = array.new_int(16, 0)
    var array<int> m5AltSL = array.new_int(16, 0)
    var array<float> m5AltForecasts = array.new_float(16, na)
    var array<float> m5AltSums = array.new_float(4, 0.0)
    var array<float> m5AltLossRing = array.new_float()
    var array<int> m5AltFrozenBits = array.new_int(4, 0)
    var array<int> m5AltFrozenValid = array.new_int(4, 0)
    // MONTHLY SOURCE NORMALIZATION.
    // A monthly source bar is assigned to its REPRESENTED calendar month via
    // time_close - 1 ms, not the calendar month of its opening timestamp.
    // Consolidate only genuinely same-period source bars, if any.
    // No current-month high/low/close is used to calculate current-month levels.
    var int aggregateYear = na
    var int aggregateMonth = na
    var int aggregateStartTime = na
    var float aggregateOpen = na
    var float aggregateHigh = na
    var float aggregateLow = na
    var float aggregateClose = na
    var int aggregateFragments = 0
    var int sourceFragmentsMerged = 0
    var int finalizedMonths = 0
    var float lastFinalizedOpen = na
    var float lastFinalizedHigh = na
    var float lastFinalizedLow = na
    var float lastFinalizedClose = na
    var int lastFinalizedMonth = na
    var int lastFinalizedYear = na

    // Native represented monthly identity. Verified against September-November 2023.
    int closeAnchorYear = not na(time_close) ? year(time_close - 1, syminfo.timezone) : year(time, syminfo.timezone)
    int closeAnchorMonth = not na(time_close) ? month(time_close - 1, syminfo.timezone) : month(time, syminfo.timezone)
    int incomingYear = closeAnchorYear
    int incomingMonth = closeAnchorMonth
    bool newCalendarMonth = na(aggregateYear) or incomingYear != aggregateYear or incomingMonth != aggregateMonth
    if newCalendarMonth
        // The month we just left is closed. Finalize it before computing the
        // new month's levels; all incoming data was already available.
        bool finishedValid = not na(aggregateYear) and not na(aggregateOpen) and not na(aggregateHigh) and not na(aggregateLow) and not na(aggregateClose) and aggregateOpen > 0
        // When a completed monthly source bar cannot even be formed,
        // M4 must record the bad input. Motor 2/3 ingestion remains frozen.
        if not na(aggregateYear) and not finishedValid
            invalidMonthsM4 += 1
        if finishedValid
            float finishedOpen = aggregateOpen
            float finishedHigh = aggregateHigh
            float finishedLow = aggregateLow
            float finishedClose = aggregateClose
            int finishedYear = aggregateYear
            int finishedMonth = aggregateMonth
            float realizedHighExtension = math.max((finishedHigh - finishedOpen) / finishedOpen, 0.0)
            float realizedLowExtension = math.max((finishedOpen - finishedLow) / finishedOpen, 0.0)
            bool canScoreBoth = not na(forecastSeasonUp) and not na(forecastSeasonDown) and not na(forecastGeneralUp) and not na(forecastGeneralDown) and not na(forecastHorizonUp) and not na(forecastHorizonDown)
            // ── M4: Score PREVIOUS monthly forecasts BEFORE updating Base/Sim.
            // Forecasts and levels were frozen at the start of the finished month.
            bool m4ValidOHLC = finishedOpen > 0 and finishedClose > 0 and finishedHigh >= math.max(finishedOpen, finishedClose) and finishedLow <= math.min(finishedOpen, finishedClose) and finishedHigh >= finishedLow
            int m4HistoryN = array.size(extensionCalendarYears)
            bool m4Ordered = true
            if m4HistoryN > 0
                int lastM4Year = array.get(extensionCalendarYears, m4HistoryN - 1)
                int lastM4Month = array.get(extensionCalendarMonths, m4HistoryN - 1)
                m4Ordered := finishedYear > lastM4Year or (finishedYear == lastM4Year and finishedMonth > lastM4Month)
            if not m4ValidOHLC
                invalidMonthsM4 += 1
            else
                if m4Ordered and finishedHigh == finishedLow and finishedOpen == finishedClose and finishedOpen == finishedHigh
                    flatMonthsM4 += 1
            bool m4ValidAH = not na(activeAvgHighLevel) and not na(activeOpenLevel) and activeAvgHighLevel > activeOpenLevel + syminfo.mintick * 0.25
            bool m4ValidSH = not na(activeStrongHighLevel) and not na(activeOpenLevel) and activeStrongHighLevel > activeOpenLevel + syminfo.mintick * 0.25
            bool m4ValidAL = not na(activeAvgLowLevel) and not na(activeOpenLevel) and activeAvgLowLevel < activeOpenLevel - syminfo.mintick * 0.25
            bool m4ValidSL = not na(activeStrongLowLevel) and not na(activeOpenLevel) and activeStrongLowLevel < activeOpenLevel - syminfo.mintick * 0.25
            bool m4CanScore = m4Ordered and m4ValidOHLC and m4ValidAH and m4ValidSH and m4ValidAL and m4ValidSL and m4ForecastReady
            if m4CanScore
                float yah = finishedHigh >= activeAvgHighLevel ? 1.0 : 0.0
                float ysh = finishedHigh >= activeStrongHighLevel ? 1.0 : 0.0
                float yal = finishedLow <= activeAvgLowLevel ? 1.0 : 0.0
                float ysl = finishedLow <= activeStrongLowLevel ? 1.0 : 0.0
                float baseHigh = (math.pow(m4ForecastBaseAH - yah, 2) + math.pow(m4ForecastBaseSH - ysh, 2)) / 2.0
                float simHigh = (math.pow(m4ForecastSimAH - yah, 2) + math.pow(m4ForecastSimSH - ysh, 2)) / 2.0
                float baseLow = (math.pow(m4ForecastBaseAL - yal, 2) + math.pow(m4ForecastBaseSL - ysl, 2)) / 2.0
                float simLow = (math.pow(m4ForecastSimAL - yal, 2) + math.pow(m4ForecastSimSL - ysl, 2)) / 2.0
                float baseLoss = (baseHigh + baseLow) / 2.0
                float simLoss = (simHigh + simLow) / 2.0
                array.push(m4LossDiff, baseLoss - simLoss)
                array.push(m4BaseLoss, baseLoss)
                array.push(m4SimLoss, simLoss)
                array.push(m4HighDiff, baseHigh - simHigh)
                array.push(m4LowDiff, baseLow - simLow)
                array.push(m4BaseResidual, ((yah + ysh + yal + ysl) - (m4ForecastBaseAH + m4ForecastBaseSH + m4ForecastBaseAL + m4ForecastBaseSL)) / 4.0)
                array.push(m4SimResidual, ((yah + ysh + yal + ysl) - (m4ForecastSimAH + m4ForecastSimSH + m4ForecastSimAL + m4ForecastSimSL)) / 4.0)
            // ── M5.2: strictly prequential scoring against the SAME realized
            // four contact events. The forecasts came from pre-month history.
            // All eight models are evaluated on IDENTICAL finalized months;
            // neutral/unobserved factor states use the Base prediction.
            if m5StudyEnabled and m4Ordered and m4ValidOHLC and m4ValidAH and m4ValidSH and m4ValidAL and m4ValidSL and m5ForecastReady
                float m5Y0 = finishedHigh >= activeAvgHighLevel ? 1.0 : 0.0
                float m5Y1 = finishedHigh >= activeStrongHighLevel ? 1.0 : 0.0
                float m5Y2 = finishedLow <= activeAvgLowLevel ? 1.0 : 0.0
                float m5Y3 = finishedLow <= activeStrongLowLevel ? 1.0 : 0.0
                if wfWindow > 0 and array.size(m5LossRing) == 0
                    for init = 0 to wfWindow * 8 - 1
                        array.push(m5LossRing, na)
                array<float> m5LatestLosses = array.new_float(8, na)
                for candidate = 0 to 7
                    float p0 = array.get(m5Pred, candidate * 4)
                    float p1 = array.get(m5Pred, candidate * 4 + 1)
                    float p2 = array.get(m5Pred, candidate * 4 + 2)
                    float p3 = array.get(m5Pred, candidate * 4 + 3)
                    float loss = (math.pow(p0 - m5Y0, 2) + math.pow(p1 - m5Y1, 2) + math.pow(p2 - m5Y2, 2) + math.pow(p3 - m5Y3, 2)) / 4.0
                    array.set(m5LatestLosses, candidate, loss)
                    float oldSum = array.get(m5LossSum, candidate)
                    if wfWindow > 0
                        int slot = (m5EvaluationsEver % wfWindow) * 8 + candidate
                        float outgoing = array.get(m5LossRing, slot)
                        if m5EvaluationsEver >= wfWindow and not na(outgoing)
                            oldSum -= outgoing
                        array.set(m5LossRing, slot, loss)
                    array.set(m5LossSum, candidate, oldSum + loss)
                // M5.3: incremental exactly-windowed mean/lag products. This
                // avoids an O(N * lag) scan on every monthly source bar.
                if m5InferenceEnabled
                    if wfWindow > 0 and array.size(m5DifferenceRing) == 0
                        for init = 0 to wfWindow * 8 - 1
                            array.push(m5DifferenceRing, na)
                        for init = 0 to wfWindow * 4 - 1
                            array.push(m5AltLossRing, na)
                    float m5BaseLossNow = array.get(m5LatestLosses, 0)
                    int m5PreviousN = wfWindow > 0 ? math.min(m5EvaluationsEver, wfWindow) : m5EvaluationsEver
                    for candidate = 1 to 7
                        float diff = m5BaseLossNow - array.get(m5LatestLosses, candidate)
                        float totalD = array.get(m5DifferenceSum, candidate)
                        float totalSq = array.get(m5DifferenceSq, candidate)
                        if wfWindow > 0 and m5PreviousN >= wfWindow
                            int oldestSlot = (m5EvaluationsEver % wfWindow) * 8 + candidate
                            float outgoing = array.get(m5DifferenceRing, oldestSlot)
                            totalD -= outgoing
                            totalSq -= outgoing * outgoing
                            for lag = 1 to math.min(12, wfWindow - 1)
                                int nextSlot = ((m5EvaluationsEver + lag) % wfWindow) * 8 + candidate
                                int rawIx = candidate * 13 + lag
                                array.set(m5RawLag, rawIx, array.get(m5RawLag, rawIx) - outgoing * array.get(m5DifferenceRing, nextSlot))
                        if m5PreviousN > 0
                            for lag = 1 to math.min(12, m5PreviousN)
                                int priorTime = m5EvaluationsEver - lag
                                int prevSlot = wfWindow > 0 ? (priorTime % wfWindow) * 8 + candidate : priorTime * 8 + candidate
                                int rawIx = candidate * 13 + lag
                                array.set(m5RawLag, rawIx, array.get(m5RawLag, rawIx) + diff * array.get(m5DifferenceRing, prevSlot))
                        array.set(m5DifferenceSum, candidate, totalD + diff)
                        array.set(m5DifferenceSq, candidate, totalSq + diff * diff)
                        if wfWindow > 0
                            array.set(m5DifferenceRing, (m5EvaluationsEver % wfWindow) * 8 + candidate, diff)
                        else
                            // Preserve fixed eight-column indexing in All mode.
                            // Eight slots per observation, index 0 unused.
                            // The first candidate creates the current row.
                            if candidate == 1
                                for pad = 0 to 7
                                    array.push(m5DifferenceRing, na)
                            array.set(m5DifferenceRing, m5EvaluationsEver * 8 + candidate, diff)
                    // Shadow-model scores are on the *same* four outcomes.
                    for variant = 0 to 3
                        float q0 = array.get(m5AltForecasts, variant * 4)
                        float q1 = array.get(m5AltForecasts, variant * 4 + 1)
                        float q2 = array.get(m5AltForecasts, variant * 4 + 2)
                        float q3 = array.get(m5AltForecasts, variant * 4 + 3)
                        float altLoss = (math.pow(q0 - m5Y0, 2) + math.pow(q1 - m5Y1, 2) + math.pow(q2 - m5Y2, 2) + math.pow(q3 - m5Y3, 2)) / 4.0
                        float altSum = array.get(m5AltSums, variant)
                        if wfWindow > 0
                            int aSlot = (m5EvaluationsEver % wfWindow) * 4 + variant
                            float altOld = array.get(m5AltLossRing, aSlot)
                            if m5EvaluationsEver >= wfWindow and not na(altOld)
                                altSum -= altOld
                            array.set(m5AltLossRing, aSlot, altLoss)
                        array.set(m5AltSums, variant, altSum + altLoss)
                m5EvaluationsEver += 1
            // ── M5.2: TRAIN ONLY AFTER scoring the completed month's outcome.
            // Unavailable feature bits are never relabeled positive. The Base
            // mask 0 remains eligible, and partial masks require valid factors.
            if m5StudyEnabled and m4Ordered and m4ValidOHLC and m4ValidAH and m4ValidSH and m4ValidAL and m4ValidSL
                int m5Hit0 = finishedHigh >= activeAvgHighLevel ? 1 : 0
                int m5Hit1 = finishedHigh >= activeStrongHighLevel ? 1 : 0
                int m5Hit2 = finishedLow <= activeAvgLowLevel ? 1 : 0
                int m5Hit3 = finishedLow <= activeStrongLowLevel ? 1 : 0
                for candidate = 0 to 7
                    if f_m5_subset(candidate, m5FrozenValid)
                        int ix = f_m5_bin(candidate, m5FrozenPositive)
                        array.set(m5BinN, ix, array.get(m5BinN, ix) + 1)
                        array.set(m5BinAH, ix, array.get(m5BinAH, ix) + m5Hit0)
                        array.set(m5BinSH, ix, array.get(m5BinSH, ix) + m5Hit1)
                        array.set(m5BinAL, ix, array.get(m5BinAL, ix) + m5Hit2)
                        array.set(m5BinSL, ix, array.get(m5BinSL, ix) + m5Hit3)
                m5TrainingMonths += 1
                if m5FrozenValid != 7
                    m5NeutralTrainingMonths += 1
                // M5.3 perturbation training occurs strictly AFTER the
                // previous month's outcome is scored. No ex-post relabeling.
                if m5InferenceEnabled
                    for variant = 0 to 3
                        int bits = array.get(m5AltFrozenBits, variant)
                        int valid = array.get(m5AltFrozenValid, variant)
                        if f_m5_subset(6, valid)
                            int ix = f_m5_alt_bin(variant, bits)
                            array.set(m5AltN, ix, array.get(m5AltN, ix) + 1)
                            array.set(m5AltAH, ix, array.get(m5AltAH, ix) + m5Hit0)
                            array.set(m5AltSH, ix, array.get(m5AltSH, ix) + m5Hit1)
                            array.set(m5AltAL, ix, array.get(m5AltAL, ix) + m5Hit2)
                            array.set(m5AltSL, ix, array.get(m5AltSL, ix) + m5Hit3)
            // ── M4: descriptive counts; keep flat but VALID months (no ex-post
            // conditioning on realized outcomes). Exclude ONLY invalid OHLC and
            // levels degenerate at OPEN, with PER-LEVEL denominators.
            bool canEvaluatePreviousMonth = m4Ordered and m4ValidOHLC and not na(activeOpenLevel)
            if canEvaluatePreviousMonth
                // Separate UNAVAILABLE estimates from calculated-but-
                // NONDIRECTIONAL estimates. In particular, early N<7
                // must not be mislabeled as a degenerate calculation.
                int unavailableThisMonth = (na(activeAvgHighLevel) ? 1 : 0) + (na(activeStrongHighLevel) ? 1 : 0) + (na(activeAvgLowLevel) ? 1 : 0) + (na(activeStrongLowLevel) ? 1 : 0)
                int calculatedDegenerateThisMonth = (not na(activeAvgHighLevel) and not m4ValidAH ? 1 : 0) + (not na(activeStrongHighLevel) and not m4ValidSH ? 1 : 0) + (not na(activeAvgLowLevel) and not m4ValidAL ? 1 : 0) + (not na(activeStrongLowLevel) and not m4ValidSL ? 1 : 0)
                unavailableLevelsM4 += unavailableThisMonth
                degenerateLevelsM4 += calculatedDegenerateThisMonth
                // Common historical sample for High vs Low comparisons.
                // Validity is established BEFORE inspecting the outcome.
                if m4ValidAH and m4ValidSH and m4ValidAL and m4ValidSL
                    commonEligibleM4 += 1
                    if finishedHigh >= activeAvgHighLevel
                        commonTouchAHM4 += 1
                    if finishedHigh >= activeStrongHighLevel
                        commonTouchSHM4 += 1
                    if finishedLow <= activeAvgLowLevel
                        commonTouchALM4 += 1
                    if finishedLow <= activeStrongLowLevel
                        commonTouchSLM4 += 1
                bool touchedAvgHighHistorical = m4ValidAH and finishedHigh >= activeAvgHighLevel
                bool touchedStrongHighHistorical = m4ValidSH and finishedHigh >= activeStrongHighLevel
                bool touchedAvgLowHistorical = m4ValidAL and finishedLow <= activeAvgLowLevel
                bool touchedStrongLowHistorical = m4ValidSL and finishedLow <= activeStrongLowLevel
                // Historical-data sensitivity diagnostic only. No filtering
                // on future outcomes in the walk-forward training/test split.
                bool m4NonFlatOutcome = not (finishedHigh == finishedLow and finishedOpen == finishedClose and finishedOpen == finishedHigh)
                if m4NonFlatOutcome
                    if m4ValidAH
                        m4NonflatAH += 1
                        if touchedAvgHighHistorical
                            m4NonflatTouchesAH += 1
                    if m4ValidSH
                        m4NonflatSH += 1
                        if touchedStrongHighHistorical
                            m4NonflatTouchesSH += 1
                    if m4ValidAL
                        m4NonflatAL += 1
                        if touchedAvgLowHistorical
                            m4NonflatTouchesAL += 1
                    if m4ValidSL
                        m4NonflatSL += 1
                        if touchedStrongLowHistorical
                            m4NonflatTouchesSL += 1
                bool containedEligible = m4ValidAH and m4ValidAL
                bool containedHistorical = containedEligible and finishedHigh < activeAvgHighLevel and finishedLow > activeAvgLowLevel
                if m4ValidAH
                    eligibleAH += 1
                if m4ValidSH
                    eligibleSH += 1
                if m4ValidAL
                    eligibleAL += 1
                if m4ValidSL
                    eligibleSL += 1
                if containedEligible
                    eligibleMonths += 1
                    if containedHistorical
                        containedMonths += 1
                bool canEvaluateContext = not na(lastFinalizedOpen) and not na(lastFinalizedHigh) and not na(lastFinalizedLow) and not na(lastFinalizedClose) and lastFinalizedOpen > 0 and lastFinalizedClose > 0 and array.size(rangeExtensions) > 0
                int historicalContextBucket = na
                if canEvaluateContext
                    float priorMonthRange = math.max((lastFinalizedHigh - lastFinalizedLow) / lastFinalizedOpen, 0.0)
                    float averageRangeForContext = f_mean_last(rangeExtensions, contextRangeLookbackMonths)
                    historicalContextBucket := f_context_bucket(lastFinalizedClose >= lastFinalizedOpen, not na(averageRangeForContext) and priorMonthRange >= averageRangeForContext, finishedOpen >= lastFinalizedClose)
                    if containedEligible
                        f_array_inc(contextEligible, historicalContextBucket)
                        f_array_inc(contextContainedEligible, historicalContextBucket)
                        if containedHistorical
                            f_array_inc(contextContainedMonths, historicalContextBucket)
                    if m4ValidAH
                        f_array_inc(contextEligibleAH, historicalContextBucket)
                    if m4ValidSH
                        f_array_inc(contextEligibleSH, historicalContextBucket)
                    if m4ValidAL
                        f_array_inc(contextEligibleAL, historicalContextBucket)
                    if m4ValidSL
                        f_array_inc(contextEligibleSL, historicalContextBucket)
                if touchedAvgHighHistorical
                    avgHighTouches += 1
                    if canEvaluateContext
                        f_array_inc(contextAvgHighTouches, historicalContextBucket)
                    if finishedClose > activeAvgHighLevel
                        avgHighCloseBeyond += 1
                    else if finishedClose <= activeOpenLevel
                        avgHighRevertOpen += 1
                    else
                        avgHighBetween += 1
                if touchedStrongHighHistorical
                    strongHighTouches += 1
                    if canEvaluateContext
                        f_array_inc(contextStrongHighTouches, historicalContextBucket)
                    if finishedClose > activeStrongHighLevel
                        strongHighCloseBeyond += 1
                    else if finishedClose <= activeOpenLevel
                        strongHighRevertOpen += 1
                    else
                        strongHighBetween += 1
                if touchedAvgLowHistorical
                    avgLowTouches += 1
                    if canEvaluateContext
                        f_array_inc(contextAvgLowTouches, historicalContextBucket)
                    if finishedClose < activeAvgLowLevel
                        avgLowCloseBeyond += 1
                    else if finishedClose >= activeOpenLevel
                        avgLowRevertOpen += 1
                    else
                        avgLowBetween += 1
                if touchedStrongLowHistorical
                    strongLowTouches += 1
                    if canEvaluateContext
                        f_array_inc(contextStrongLowTouches, historicalContextBucket)
                    if finishedClose < activeStrongLowLevel
                        strongLowCloseBeyond += 1
                    else if finishedClose >= activeOpenLevel
                        strongLowRevertOpen += 1
                    else
                        strongLowBetween += 1
            // Fail closed if the source revisits a completed calendar month out of order.
            int previousFinalizedCount = array.size(extensionCalendarYears)
            bool outOfOrderMonth = previousFinalizedCount > 0 and (finishedYear < array.get(extensionCalendarYears, previousFinalizedCount - 1) or (finishedYear == array.get(extensionCalendarYears, previousFinalizedCount - 1) and finishedMonth <= array.get(extensionCalendarMonths, previousFinalizedCount - 1)))
            if outOfOrderMonth
                conflictingDuplicateRows += 1
            // Evaluate both models once per uniquely finalized month.
            if not outOfOrderMonth and canScoreBoth
                float lossSUp = math.abs(realizedHighExtension - forecastSeasonUp)
                float lossSDown = math.abs(realizedLowExtension - forecastSeasonDown)
                float lossGUp = math.abs(realizedHighExtension - forecastGeneralUp)
                float lossGDown = math.abs(realizedLowExtension - forecastGeneralDown)
                float lossS = (lossSUp + lossSDown) / 2.0
                float lossG = (lossGUp + lossGDown) / 2.0
                float lossH = (math.abs(realizedHighExtension - forecastHorizonUp) + math.abs(realizedLowExtension - forecastHorizonDown)) / 2.0
                array.push(wfPairedDiff, lossG - lossS)
                array.push(wfUpDiff, math.abs(realizedHighExtension - forecastGeneralUp) - math.abs(realizedHighExtension - forecastSeasonUp))
                array.push(wfDownDiff, math.abs(realizedLowExtension - forecastGeneralDown) - math.abs(realizedLowExtension - forecastSeasonDown))
                array.push(wfMatchedHorizonDiff, lossH - lossS)
                array.push(wfSeasonLoss, lossS)
                array.push(wfGeneralLoss, lossG)
                array.push(wfSeasonHighLoss, lossSUp)
                array.push(wfGeneralHighLoss, lossGUp)
                array.push(wfSeasonLowLoss, lossSDown)
                array.push(wfGeneralLowLoss, lossGDown)
                array.push(wfCalendarMonth, finishedMonth)
            // Insert exactly one observation for a completed calendar month.
            if not outOfOrderMonth
                array.push(highExtensions, math.max((finishedHigh - finishedOpen) / finishedOpen, 0.0))
                array.push(lowExtensions, math.max((finishedOpen - finishedLow) / finishedOpen, 0.0))
                array.push(rangeExtensions, math.max((finishedHigh - finishedLow) / finishedOpen, 0.0))
                array.push(extensionCalendarMonths, finishedMonth)
                array.push(extensionCalendarYears, finishedYear)
                finalizedMonths += 1
                lastFinalizedOpen := finishedOpen
                lastFinalizedHigh := finishedHigh
                lastFinalizedLow := finishedLow
                lastFinalizedClose := finishedClose
                lastFinalizedYear := finishedYear
                lastFinalizedMonth := finishedMonth
        aggregateYear := incomingYear
        aggregateMonth := incomingMonth
        aggregateStartTime := time
        aggregateOpen := open
        aggregateHigh := high
        aggregateLow := low
        aggregateClose := close
        aggregateFragments := 1
    else
        // Extra source bars WITHIN the same calendar month are fragments, not
        // additional months. Consolidate their OHLC without changing prior data.
        aggregateHigh := math.max(aggregateHigh, high)
        aggregateLow := math.min(aggregateLow, low)
        aggregateClose := close
        aggregateFragments += 1
        sourceFragmentsMerged += 1
        identicalDuplicateRows += 1

    // All forecasts share this same CONFIRMED monthly source history.
    int targetCalendarMonth = aggregateMonth
    int seasonalN = f_season_count(extensionCalendarMonths, targetCalendarMonth, seasonalLookbackObservations)
    float seasonalMuUp = f_season_mean(highExtensions, extensionCalendarMonths, targetCalendarMonth, seasonalLookbackObservations)
    float seasonalMuDown = f_season_mean(lowExtensions, extensionCalendarMonths, targetCalendarMonth, seasonalLookbackObservations)
    float seasonalSdUp = f_season_stdev(highExtensions, extensionCalendarMonths, targetCalendarMonth, seasonalLookbackObservations, seasonalMuUp)
    float seasonalSdDown = f_season_stdev(lowExtensions, extensionCalendarMonths, targetCalendarMonth, seasonalLookbackObservations, seasonalMuDown)
    int generalN = f_count_last(highExtensions, seasonalLookbackObservations)
    float generalMuUp = f_mean_last(highExtensions, seasonalLookbackObservations)
    float generalMuDown = f_mean_last(lowExtensions, seasonalLookbackObservations)
    float generalSdUp = f_stdev_last(highExtensions, seasonalLookbackObservations)
    float generalSdDown = f_stdev_last(lowExtensions, seasonalLookbackObservations)
    // Historical-window robustness: fixed lookbacks compare to up to 12 x
    // calendar years. When All is selected, All would duplicate the general
    // model. Instead compare against the recent HALF of confirmed history.
    // This is a CAUSAL RECENCY SENSITIVITY check (overlapping data), NOT an
    // independent sample or an equal-horizon benchmark.
    int confirmedHistoryN = array.size(highExtensions)
    int benchmarkHorizon = seasonalLookbackObservations == 0 ? int(math.floor(confirmedHistoryN / 2.0)) : seasonalLookbackObservations * 12
    float horizonMuUp = benchmarkHorizon >= minClosedMonths ? f_mean_last(highExtensions, benchmarkHorizon) : na
    float horizonMuDown = benchmarkHorizon >= minClosedMonths ? f_mean_last(lowExtensions, benchmarkHorizon) : na
    // Forecast values are determined BEFORE the present month closes.
    forecastSeasonUp := seasonalN >= minClosedMonths ? seasonalMuUp : na
    forecastSeasonDown := seasonalN >= minClosedMonths ? seasonalMuDown : na
    forecastGeneralUp := generalN >= minClosedMonths ? generalMuUp : na
    forecastGeneralDown := generalN >= minClosedMonths ? generalMuDown : na
    forecastHorizonUp := generalN >= minClosedMonths and not na(horizonMuUp) ? horizonMuUp : na
    forecastHorizonDown := generalN >= minClosedMonths and not na(horizonMuDown) ? horizonMuDown : na

    bool useSeasonal = modelInput == "Seasonal"
    int sampleCount = useSeasonal ? seasonalN : generalN
    float avgHighExtension = useSeasonal ? seasonalMuUp : generalMuUp
    float avgLowExtension = useSeasonal ? seasonalMuDown : generalMuDown
    float highStdev = useSeasonal ? seasonalSdUp : generalSdUp
    float lowStdev = useSeasonal ? seasonalSdDown : generalSdDown
    bool canDraw = conflictingDuplicateRows == 0 and sampleCount >= minClosedMonths and not na(aggregateOpen) and not na(avgHighExtension) and not na(avgLowExtension) and not na(highStdev) and not na(lowStdev)
    activeOpenLevel := aggregateOpen
    activeStrongHighLevel := canDraw ? aggregateOpen * (1.0 + avgHighExtension + strongMult * highStdev) : na
    activeAvgHighLevel := canDraw ? aggregateOpen * (1.0 + avgHighExtension) : na
    activeAvgLowLevel := canDraw ? math.max(aggregateOpen * (1.0 - avgLowExtension), syminfo.mintick) : na
    activeStrongLowLevel := canDraw ? math.max(aggregateOpen * (1.0 - avgLowExtension - strongMult * lowStdev), syminfo.mintick) : na

    // Within-Pine inferential diagnostics for the selected model.
    [avgUpHalf, strongUpHalf, influenceUp] = f_estimator_uncertainty(highExtensions, extensionCalendarMonths, targetCalendarMonth, seasonalLookbackObservations, useSeasonal, sampleCount, avgHighExtension, highStdev, strongMult)
    [avgDownHalf, strongDownHalf, influenceDown] = f_estimator_uncertainty(lowExtensions, extensionCalendarMonths, targetCalendarMonth, seasonalLookbackObservations, useSeasonal, sampleCount, avgLowExtension, lowStdev, strongMult)
    // The Welch descriptive study keeps the user's full lookback when All is
    // selected; the recent-half window is ONLY the All recency sensitivity check.
    int welchWindow = seasonalLookbackObservations == 0 ? 0 : seasonalLookbackObservations * 12
    float zSeasonUp = f_seasonal_effect_t_ratio(highExtensions, extensionCalendarMonths, targetCalendarMonth, welchWindow)
    float zSeasonDown = f_seasonal_effect_t_ratio(lowExtensions, extensionCalendarMonths, targetCalendarMonth, welchWindow)
    // Paired OOS sample is identical across the two competing models.
    // Joint Bonferroni family: twelve calendar tests + one global (13 tests).
    [winnerGlobal, wfN, advantageGlobal, ciGlobalLow, ciGlobalHigh, wfSeasonMae, wfGeneralMae, wfHorizonMean, advantageUpGlobal, advantageDownGlobal, seasonHighMaeGlobal, generalHighMaeGlobal, seasonLowMaeGlobal, generalLowMaeGlobal, reasonGlobal] = f_paired_model_evidence(wfPairedDiff, wfUpDiff, wfDownDiff, wfMatchedHorizonDiff, wfSeasonLoss, wfGeneralLoss, wfSeasonHighLoss, wfGeneralHighLoss, wfSeasonLowLoss, wfGeneralLowLoss, wfCalendarMonth, 0, wfWindow, minWfGlobal, 12, minWfImprovement)
    [winnerCalendar, wfCalendarN, advantageCalendar, ciCalendarLow, ciCalendarHigh, calSeasonMae, calGeneralMae, calHorizonMean, advantageUpCalendar, advantageDownCalendar, calSeasonHighMae, calGeneralHighMae, calSeasonLowMae, calGeneralLowMae, reasonCalendar] = f_paired_model_evidence(wfPairedDiff, wfUpDiff, wfDownDiff, wfMatchedHorizonDiff, wfSeasonLoss, wfGeneralLoss, wfSeasonHighLoss, wfGeneralHighLoss, wfSeasonLowLoss, wfGeneralLowLoss, wfCalendarMonth, targetCalendarMonth, wfWindow == 0 ? 0 : int(math.ceil(wfWindow / 12.0)), minWfCalendar, 6, minWfImprovement)
    // Level-estimator uncertainty remains DESCRIPTIVE. It cannot veto a valid OOS
    // comparison solely because an asset has fewer than 20 same-month years.
    // Contradiction only when the month-specific confidence evidence opposes a
    // global winner, not just when a noisy monthly point estimate has another sign.
    bool monthContradictsGlobal = winnerGlobal != 0 and wfCalendarN >= minWfCalendar and not na(ciCalendarLow) and not na(ciCalendarHigh) and (winnerGlobal == 1 ? ciCalendarHigh < 0 : ciCalendarLow > 0)
    bool winnerConflict = winnerGlobal != 0 and winnerCalendar != 0 and winnerGlobal != winnerCalendar
    int recommendedModel = winnerConflict or monthContradictsGlobal ? 0 : winnerCalendar != 0 ? winnerCalendar : winnerGlobal
    int recommendationScope = recommendedModel == 0 ? 0 : winnerCalendar != 0 ? 2 : 1
    int abstentionReason = recommendedModel != 0 ? 0 : conflictingDuplicateRows > 0 ? 10 : winnerConflict or monthContradictsGlobal ? 9 : reasonGlobal != 1 ? reasonGlobal : reasonCalendar
    if conflictingDuplicateRows > 0
        recommendedModel := 0
        recommendationScope := 0
        abstentionReason := 10

    int currentContextBucket = na
    if not na(lastFinalizedOpen) and not na(lastFinalizedHigh) and not na(lastFinalizedLow) and not na(lastFinalizedClose) and lastFinalizedOpen > 0 and lastFinalizedClose > 0 and array.size(rangeExtensions) > 0
        float currentPriorRange = math.max((lastFinalizedHigh - lastFinalizedLow) / lastFinalizedOpen, 0.0)
        float currentAverageRange = f_mean_last(rangeExtensions, contextRangeLookbackMonths)
        currentContextBucket := f_context_bucket(lastFinalizedClose >= lastFinalizedOpen, not na(currentAverageRange) and currentPriorRange >= currentAverageRange, aggregateOpen >= lastFinalizedClose)
    int selectedContextEligible = na(currentContextBucket) ? 0 : array.get(contextEligible, currentContextBucket)
    int selectedContextContained = na(currentContextBucket) ? 0 : array.get(contextContainedMonths, currentContextBucket)
    int selectedContextAvgHighTouches = na(currentContextBucket) ? 0 : array.get(contextAvgHighTouches, currentContextBucket)
    int selectedContextStrongHighTouches = na(currentContextBucket) ? 0 : array.get(contextStrongHighTouches, currentContextBucket)
    int selectedContextAvgLowTouches = na(currentContextBucket) ? 0 : array.get(contextAvgLowTouches, currentContextBucket)
    int selectedContextStrongLowTouches = na(currentContextBucket) ? 0 : array.get(contextStrongLowTouches, currentContextBucket)
    // M4 forecasts set AFTER closing/recounting the previous month, before
    // the active month's close. No current high/low/close enters forecasts.
    int selEligibleAH = na(currentContextBucket) ? 0 : array.get(contextEligibleAH, currentContextBucket)
    int selEligibleSH = na(currentContextBucket) ? 0 : array.get(contextEligibleSH, currentContextBucket)
    int selEligibleAL = na(currentContextBucket) ? 0 : array.get(contextEligibleAL, currentContextBucket)
    int selEligibleSL = na(currentContextBucket) ? 0 : array.get(contextEligibleSL, currentContextBucket)
    bool m4ReadyContext = canDraw and not na(currentContextBucket) and eligibleAH > 0 and eligibleSH > 0 and eligibleAL > 0 and eligibleSL > 0 and selEligibleAH > 0 and selEligibleSH > 0 and selEligibleAL > 0 and selEligibleSL > 0
    m4ForecastBaseAH := m4ReadyContext ? avgHighTouches / float(eligibleAH) : na
    m4ForecastBaseSH := m4ReadyContext ? strongHighTouches / float(eligibleSH) : na
    m4ForecastBaseAL := m4ReadyContext ? avgLowTouches / float(eligibleAL) : na
    m4ForecastBaseSL := m4ReadyContext ? strongLowTouches / float(eligibleSL) : na
    m4ForecastSimAH := m4ReadyContext ? array.get(contextAvgHighTouches, currentContextBucket) / float(selEligibleAH) : na
    m4ForecastSimSH := m4ReadyContext ? array.get(contextStrongHighTouches, currentContextBucket) / float(selEligibleSH) : na
    m4ForecastSimAL := m4ReadyContext ? array.get(contextAvgLowTouches, currentContextBucket) / float(selEligibleAL) : na
    m4ForecastSimSL := m4ReadyContext ? array.get(contextStrongLowTouches, currentContextBucket) / float(selEligibleSL) : na
    m4ForecastReady := m4ReadyContext
    [m4OosN, m4BrierBase, m4BrierSim, m4CiLow, m4CiHigh, m4Winner, m4Reason, m4CalibrationBase, m4CalibrationSim] = f_m4_evidence(m4LossDiff, m4BaseLoss, m4SimLoss, m4HighDiff, m4LowDiff, m4BaseResidual, m4SimResidual, wfWindow)
    if invalidMonthsM4 > 0
        m4Winner := 0
        m4Reason := 8 // M4 only: invalid monthly source, refuse inference
    if conflictingDuplicateRows > 0
        m4Winner := 0
        m4Reason := 7 // fail closed: source conflict
    // ── M5.2: freeze factor identities and eight forecasts at THIS month's
    // opening. Direction/range come from finalized prior-month data; C uses
    // only the current monthly OPEN. A neutral sign stays unavailable, not Up.
    // The same-level, same-date OOS design and the M1-M4 outputs are untouched.
    int m5CurrentPositive = 0
    int m5CurrentValid = 0
    bool m5ConsecutiveMonths = not na(lastFinalizedYear) and not na(lastFinalizedMonth) and (aggregateYear * 12 + aggregateMonth) - (lastFinalizedYear * 12 + lastFinalizedMonth) == 1
    bool m5CanClassify = m5ConsecutiveMonths and not na(lastFinalizedOpen) and not na(lastFinalizedHigh) and not na(lastFinalizedLow) and not na(lastFinalizedClose) and lastFinalizedOpen > 0 and lastFinalizedClose > 0 and not na(aggregateOpen) and aggregateOpen > 0 and array.size(rangeExtensions) > 0
    if m5StudyEnabled and m5CanClassify
        float tolPrice = syminfo.mintick * 0.25
        float directionDifference = lastFinalizedClose - lastFinalizedOpen
        if math.abs(directionDifference) > tolPrice
            m5CurrentValid += 1
            if directionDifference > 0
                m5CurrentPositive += 1
        float priorRange = math.max((lastFinalizedHigh - lastFinalizedLow) / lastFinalizedOpen, 0.0)
        float referenceRange = f_mean_last(rangeExtensions, contextRangeLookbackMonths)
        if not na(referenceRange) and math.abs(priorRange - referenceRange) > 0.000000001
            m5CurrentValid += 2
            if priorRange > referenceRange
                m5CurrentPositive += 2
        float openingDifference = aggregateOpen - lastFinalizedClose
        if math.abs(openingDifference) > tolPrice
            m5CurrentValid += 4
            if openingDifference > 0
                m5CurrentPositive += 4
    // The previous context is FROZEN before the present monthly outcome.
    m5FrozenPositive := m5CurrentPositive
    m5FrozenValid := m5CurrentValid
    // M5.3 shadows use only information available at the current opening.
    // C=1bp/5bp neutral-gap stress; B=120/360 month range-reference stress.
    if m5StudyEnabled and m5InferenceEnabled
        for variant = 0 to 3
            int bits = m5CurrentPositive
            int valid = m5CurrentValid
            if m5CanClassify
                if variant <= 1
                    float thresholdBp = variant == 0 ? 1.0 : 5.0
                    float gapBp = math.abs(aggregateOpen / lastFinalizedClose - 1.0) * 10000.0
                    if gapBp <= thresholdBp
                        valid := valid >= 4 ? valid - 4 : valid
                        bits := bits >= 4 ? bits - 4 : bits
                else
                    // Replace B's current 720-month reference with a genuine
                    // alternative recent mean, not a changed OOS target.
                    float refRange = f_mean_last(rangeExtensions, variant == 2 ? 120 : 360)
                    float priorRange = math.max((lastFinalizedHigh - lastFinalizedLow) / lastFinalizedOpen, 0.0)
                    if valid % 4 >= 2
                        valid -= 2
                    if bits % 4 >= 2
                        bits -= 2
                    if not na(refRange) and math.abs(priorRange - refRange) > 0.000000001
                        valid += 2
                        if priorRange > refRange
                            bits += 2
            array.set(m5AltFrozenBits, variant, bits)
            array.set(m5AltFrozenValid, variant, valid)
    int m5BaseHistoryN = array.get(m5BinN, 0)
    m5ForecastReady := m5StudyEnabled and canDraw and m5BaseHistoryN > 0 and m5CanClassify and conflictingDuplicateRows == 0
    if m5StudyEnabled and m5ForecastReady
        for candidate = 0 to 7
            for levelIndex = 0 to 3
                array.set(m5Pred, candidate * 4 + levelIndex, f_m5_forecast(m5BinN, m5BinAH, m5BinSH, m5BinAL, m5BinSL, candidate, m5CurrentPositive, m5CurrentValid, levelIndex))
        if m5InferenceEnabled
            for variant = 0 to 3
                for levelIndex = 0 to 3
                    float baseForecast = array.get(m5Pred, levelIndex)
                    array.set(m5AltForecasts, variant * 4 + levelIndex, f_m5_alt_probability(m5AltN, m5AltAH, m5AltSH, m5AltAL, m5AltSL, variant, array.get(m5AltFrozenBits, variant), array.get(m5AltFrozenValid, variant), levelIndex, baseForecast))
    int m5OosN = m5StudyEnabled ? (wfWindow == 0 ? m5EvaluationsEver : math.min(m5EvaluationsEver, wfWindow)) : 0
    float m5Score0 = m5OosN > 0 ? array.get(m5LossSum, 0) / m5OosN : na
    float m5Score1 = m5OosN > 0 ? array.get(m5LossSum, 1) / m5OosN : na
    float m5Score2 = m5OosN > 0 ? array.get(m5LossSum, 2) / m5OosN : na
    float m5Score3 = m5OosN > 0 ? array.get(m5LossSum, 3) / m5OosN : na
    float m5Score4 = m5OosN > 0 ? array.get(m5LossSum, 4) / m5OosN : na
    float m5Score5 = m5OosN > 0 ? array.get(m5LossSum, 5) / m5OosN : na
    float m5Score6 = m5OosN > 0 ? array.get(m5LossSum, 6) / m5OosN : na
    float m5Score7 = m5OosN > 0 ? array.get(m5LossSum, 7) / m5OosN : na
    int m5Support0 = m5StudyEnabled ? f_m5_support(m5BinN, 0, m5CurrentPositive, m5CurrentValid) : 0
    int m5Support1 = m5StudyEnabled ? f_m5_support(m5BinN, 1, m5CurrentPositive, m5CurrentValid) : 0
    int m5Support2 = m5StudyEnabled ? f_m5_support(m5BinN, 2, m5CurrentPositive, m5CurrentValid) : 0
    int m5Support3 = m5StudyEnabled ? f_m5_support(m5BinN, 3, m5CurrentPositive, m5CurrentValid) : 0
    int m5Support4 = m5StudyEnabled ? f_m5_support(m5BinN, 4, m5CurrentPositive, m5CurrentValid) : 0
    int m5Support5 = m5StudyEnabled ? f_m5_support(m5BinN, 5, m5CurrentPositive, m5CurrentValid) : 0
    int m5Support6 = m5StudyEnabled ? f_m5_support(m5BinN, 6, m5CurrentPositive, m5CurrentValid) : 0
    int m5Support7 = m5StudyEnabled ? f_m5_support(m5BinN, 7, m5CurrentPositive, m5CurrentValid) : 0
    // M5.3 research screens: 7 paired comparisons with 13-family
    // conservative multiplicity control, no executable model switch.
    array<float> m5AltBriersNow = array.new_float(4, na)
    if m5StudyEnabled and m5InferenceEnabled and m5OosN > 0
        for variant = 0 to 3
            array.set(m5AltBriersNow, variant, array.get(m5AltSums, variant) / m5OosN)
    array<int> m5ScreenNow = array.new_int(8, 0)
    float m5BCciLo = na
    float m5BCciHi = na
    int m5ScreenCount = 0
    if m5StudyEnabled and m5InferenceEnabled and m5OosN > 0 and conflictingDuplicateRows == 0 and invalidMonthsM4 == 0
        array<float> candidateScores = array.from(m5Score0, m5Score1, m5Score2, m5Score3, m5Score4, m5Score5, m5Score6, m5Score7)
        for candidate = 1 to 7
            [screen, boundLo, boundHi] = f_m5_screen(m5DifferenceRing, m5DifferenceSum, m5DifferenceSq, m5RawLag, m5EvaluationsEver, wfWindow, candidate, m5Score0, array.get(candidateScores, candidate), m5AltBriersNow)
            array.set(m5ScreenNow, candidate, screen)
            if candidate == 6
                m5BCciLo := boundLo
                m5BCciHi := boundHi
            if screen == 5
                m5ScreenCount += 1
    int m5Screen1 = array.get(m5ScreenNow, 1)
    int m5Screen2 = array.get(m5ScreenNow, 2)
    int m5Screen3 = array.get(m5ScreenNow, 3)
    int m5Screen4 = array.get(m5ScreenNow, 4)
    int m5Screen5 = array.get(m5ScreenNow, 5)
    int m5Screen6 = array.get(m5ScreenNow, 6)
    int m5Screen7 = array.get(m5ScreenNow, 7)
    float m5AltC1 = array.get(m5AltBriersNow, 0)
    float m5AltC5 = array.get(m5AltBriersNow, 1)
    float m5AltB120 = array.get(m5AltBriersNow, 2)
    float m5AltB360 = array.get(m5AltBriersNow, 3)
    // Ex-post regime-quality sensitivity: largest observed change in Base
    // rates when removing flat MONTHLY outcomes. NEVER used for model selection
    // or to change the per-level Base/Sim training/evaluation denominators.
    float m4FlatMaxShift = na
    if eligibleAH > 0 and m4NonflatAH > 0
        m4FlatMaxShift := na(m4FlatMaxShift) ? math.abs(avgHighTouches / float(eligibleAH) - m4NonflatTouchesAH / float(m4NonflatAH)) * 100.0 : math.max(m4FlatMaxShift, math.abs(avgHighTouches / float(eligibleAH) - m4NonflatTouchesAH / float(m4NonflatAH)) * 100.0)
    if eligibleSH > 0 and m4NonflatSH > 0
        m4FlatMaxShift := na(m4FlatMaxShift) ? math.abs(strongHighTouches / float(eligibleSH) - m4NonflatTouchesSH / float(m4NonflatSH)) * 100.0 : math.max(m4FlatMaxShift, math.abs(strongHighTouches / float(eligibleSH) - m4NonflatTouchesSH / float(m4NonflatSH)) * 100.0)
    if eligibleAL > 0 and m4NonflatAL > 0
        m4FlatMaxShift := na(m4FlatMaxShift) ? math.abs(avgLowTouches / float(eligibleAL) - m4NonflatTouchesAL / float(m4NonflatAL)) * 100.0 : math.max(m4FlatMaxShift, math.abs(avgLowTouches / float(eligibleAL) - m4NonflatTouchesAL / float(m4NonflatAL)) * 100.0)
    if eligibleSL > 0 and m4NonflatSL > 0
        m4FlatMaxShift := na(m4FlatMaxShift) ? math.abs(strongLowTouches / float(eligibleSL) - m4NonflatTouchesSL / float(m4NonflatSL)) * 100.0 : math.max(m4FlatMaxShift, math.abs(strongLowTouches / float(eligibleSL) - m4NonflatTouchesSL / float(m4NonflatSL)) * 100.0)
    [activeStrongHighLevel, activeAvgHighLevel, activeOpenLevel, activeAvgLowLevel, activeStrongLowLevel, sampleCount, eligibleMonths, containedMonths, avgHighTouches, avgHighCloseBeyond, avgHighBetween, avgHighRevertOpen, strongHighTouches, strongHighCloseBeyond, strongHighBetween, strongHighRevertOpen, avgLowTouches, avgLowCloseBeyond, avgLowBetween, avgLowRevertOpen, strongLowTouches, strongLowCloseBeyond, strongLowBetween, strongLowRevertOpen, currentContextBucket, selectedContextEligible, selectedContextContained, selectedContextAvgHighTouches, selectedContextStrongHighTouches, selectedContextAvgLowTouches, selectedContextStrongLowTouches, conflictingDuplicateRows, seasonalN, generalN, wfN, wfCalendarN, winnerGlobal, winnerCalendar, recommendedModel, recommendationScope, advantageGlobal, advantageCalendar, advantageUpGlobal, advantageDownGlobal, ciGlobalLow, ciGlobalHigh, ciCalendarLow, ciCalendarHigh, wfSeasonMae, wfGeneralMae, avgUpHalf, avgDownHalf, strongUpHalf, strongDownHalf, influenceUp, influenceDown, zSeasonUp, zSeasonDown, seasonHighMaeGlobal, generalHighMaeGlobal, seasonLowMaeGlobal, generalLowMaeGlobal, abstentionReason, reasonGlobal, reasonCalendar, eligibleAH, eligibleSH, eligibleAL, eligibleSL, selEligibleAH, selEligibleSH, selEligibleAL, selEligibleSL, flatMonthsM4, invalidMonthsM4, degenerateLevelsM4, m4OosN, m4BrierBase, m4BrierSim, m4CiLow, m4CiHigh, m4Winner, m4Reason, m4CalibrationBase, m4CalibrationSim, m4FlatMaxShift, unavailableLevelsM4, commonEligibleM4, commonTouchAHM4, commonTouchSHM4, commonTouchALM4, commonTouchSLM4, m5OosN, m5Score0, m5Score1, m5Score2, m5Score3, m5Score4, m5Score5, m5Score6, m5Score7, m5Support0, m5Support1, m5Support2, m5Support3, m5Support4, m5Support5, m5Support6, m5Support7, m5TrainingMonths, m5NeutralTrainingMonths, m5Screen1, m5Screen2, m5Screen3, m5Screen4, m5Screen5, m5Screen6, m5Screen7, m5BCciLo, m5BCciHi, m5AltC1, m5AltC5, m5AltB120, m5AltB360, m5ScreenCount]

// All Motor 3 research runs in monthly context, independent of chart TF.
[activeStrongHighLevel, activeAvgHighLevel, activeOpenLevel, activeAvgLowLevel, activeStrongLowLevel, sampleCount, eligibleMonths, containedMonths, avgHighTouches, avgHighCloseBeyond, avgHighBetween, avgHighRevertOpen, strongHighTouches, strongHighCloseBeyond, strongHighBetween, strongHighRevertOpen, avgLowTouches, avgLowCloseBeyond, avgLowBetween, avgLowRevertOpen, strongLowTouches, strongLowCloseBeyond, strongLowBetween, strongLowRevertOpen, currentContextBucket, selectedContextEligible, selectedContextContained, selectedContextAvgHighTouches, selectedContextStrongHighTouches, selectedContextAvgLowTouches, selectedContextStrongLowTouches, conflictingDuplicateRows, seasonalN, generalN, wfN, wfCalendarN, winnerGlobal, winnerCalendar, recommendedModel, recommendationScope, advantageGlobal, advantageCalendar, advantageUpGlobal, advantageDownGlobal, ciGlobalLow, ciGlobalHigh, ciCalendarLow, ciCalendarHigh, wfSeasonMae, wfGeneralMae, avgUpHalf, avgDownHalf, strongUpHalf, strongDownHalf, influenceUp, influenceDown, zSeasonUp, zSeasonDown, seasonHighMaeGlobal, generalHighMaeGlobal, seasonLowMaeGlobal, generalLowMaeGlobal, abstentionReason, reasonGlobal, reasonCalendar, eligibleAH, eligibleSH, eligibleAL, eligibleSL, selEligibleAH, selEligibleSH, selEligibleAL, selEligibleSL, flatMonthsM4, invalidMonthsM4, degenerateLevelsM4, m4OosN, m4BrierBase, m4BrierSim, m4CiLow, m4CiHigh, m4Winner, m4Reason, m4CalibrationBase, m4CalibrationSim, m4FlatMaxShift, unavailableLevelsM4, commonEligibleM4, commonTouchAHM4, commonTouchSHM4, commonTouchALM4, commonTouchSLM4, m5OosN, m5Score0, m5Score1, m5Score2, m5Score3, m5Score4, m5Score5, m5Score6, m5Score7, m5Support0, m5Support1, m5Support2, m5Support3, m5Support4, m5Support5, m5Support6, m5Support7, m5TrainingMonths, m5NeutralTrainingMonths, m5Screen1, m5Screen2, m5Screen3, m5Screen4, m5Screen5, m5Screen6, m5Screen7, m5BCciLo, m5BCciHi, m5AltC1, m5AltC5, m5AltB120, m5AltB360, m5ScreenCount] = request.security(syminfo.tickerid, "M", f_monthly_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
// Clean Data Window diagnostics. Nothing is added to the price scale.
plot(activeStrongHighLevel, "AUDIT Strong High", display = display.data_window, format = format.price, precision = 3, editable = false)
plot(activeAvgHighLevel, "AUDIT Avg High", display = display.data_window, format = format.price, precision = 3, editable = false)
plot(activeOpenLevel, "AUDIT Open", display = display.data_window, format = format.price, precision = 3, editable = false)
plot(activeAvgLowLevel, "AUDIT Avg Low", display = display.data_window, format = format.price, precision = 3, editable = false)
plot(activeStrongLowLevel, "AUDIT Strong Low", display = display.data_window, format = format.price, precision = 3, editable = false)
plot(float(seasonalN), "M3 Seasonal N", display = display.data_window, precision = 0, editable = false)
plot(float(generalN), "M3 Nonseasonal N", display = display.data_window, precision = 0, editable = false)
plot(float(wfN), "M3 Paired OOS N", display = display.data_window, precision = 0, editable = false)
plot(float(wfCalendarN), "M3 Same-Month OOS N", display = display.data_window, precision = 0, editable = false)
plot(advantageGlobal, "M3 Global MAE Advantage % (+ Seasonal)", display = display.data_window, precision = 3, editable = false)
plot(advantageCalendar, "M3 Month MAE Advantage % (+ Seasonal)", display = display.data_window, precision = 3, editable = false)
plot(ciGlobalLow, "M3 HAC Global Difference CI Low", display = display.data_window, precision = 6, editable = false)
plot(ciGlobalHigh, "M3 HAC Global Difference CI High", display = display.data_window, precision = 6, editable = false)
plot(float(recommendedModel), "M3 Recommendation (+1 S / -1 NS / 0 I)", display = display.data_window, precision = 0, editable = false)
plot(float(recommendationScope), "M3 Evidence Scope (2 Month / 1 Global)", display = display.data_window, precision = 0, editable = false)
plot(ciCalendarLow, "M3 HAC Month Difference CI Low", display = display.data_window, precision = 6, editable = false)
plot(ciCalendarHigh, "M3 HAC Month Difference CI High", display = display.data_window, precision = 6, editable = false)
plot(seasonHighMaeGlobal * 100.0, "M3 Seasonal High OOS MAE (pp)", display = display.data_window, precision = 3, editable = false)
plot(generalHighMaeGlobal * 100.0, "M3 Nonseasonal High OOS MAE (pp)", display = display.data_window, precision = 3, editable = false)
plot(seasonLowMaeGlobal * 100.0, "M3 Seasonal Low OOS MAE (pp)", display = display.data_window, precision = 3, editable = false)
plot(generalLowMaeGlobal * 100.0, "M3 Nonseasonal Low OOS MAE (pp)", display = display.data_window, precision = 3, editable = false)
plot(float(abstentionReason), "M3 Decision / Abstention reason (code)", display = display.data_window, precision = 0, editable = false)
plot(float(reasonGlobal), "M3 Global filter reason (code)", display = display.data_window, precision = 0, editable = false)
plot(float(reasonCalendar), "M3 Calendar filter reason (code)", display = display.data_window, precision = 0, editable = false)
plot(avgUpHalf * 100.0, "M3 Avg High CI95 Halfwidth (pct-points)", display = display.data_window, precision = 3, editable = false)
plot(avgDownHalf * 100.0, "M3 Avg Low CI95 Halfwidth (pct-points)", display = display.data_window, precision = 3, editable = false)
plot(strongUpHalf * 100.0, "M3 Strong High Jackknife CI95 Halfwidth", display = display.data_window, precision = 3, editable = false)
plot(strongDownHalf * 100.0, "M3 Strong Low Jackknife CI95 Halfwidth", display = display.data_window, precision = 3, editable = false)
plot(zSeasonUp, "M3 Welch t / crit High (Bonferroni 24)", display = display.data_window, precision = 3, editable = false)
plot(zSeasonDown, "M3 Welch t / crit Low (Bonferroni 24)", display = display.data_window, precision = 3, editable = false)
// M4: each upper/lower level owns its own eligible denominator.
plot(float(eligibleAH), "M4 Avg High eligible N", display = display.data_window, precision = 0, editable = false)
plot(float(eligibleSH), "M4 Strong High eligible N", display = display.data_window, precision = 0, editable = false)
plot(float(eligibleAL), "M4 Avg Low eligible N", display = display.data_window, precision = 0, editable = false)
plot(float(eligibleSL), "M4 Strong Low eligible N", display = display.data_window, precision = 0, editable = false)
plot(float(m4OosN), "M4 Base/Sim paired OOS months", display = display.data_window, precision = 0, editable = false)
plot(m4BrierBase, "M4 Base Brier (lower better)", display = display.data_window, precision = 5, editable = false)
plot(m4BrierSim, "M4 Sim Brier (lower better)", display = display.data_window, precision = 5, editable = false)
plot(m4CiLow, "M4 Paired HAC Delta Low (Base-Sim)", display = display.data_window, precision = 6, editable = false)
plot(m4CiHigh, "M4 Paired HAC Delta High (Base-Sim)", display = display.data_window, precision = 6, editable = false)
plot(float(m4Winner), "M4 Robust favored (+1 Sim / -1 Base / 0 INC)", display = display.data_window, precision = 0, editable = false)
plot(float(m4Reason), "M4 Evidence reason code", display = display.data_window, precision = 0, editable = false)
plot(m4CalibrationBase, "M4 Base aggregate calibration gap", display = display.data_window, precision = 5, editable = false)
plot(m4CalibrationSim, "M4 Sim aggregate calibration gap", display = display.data_window, precision = 5, editable = false)
plot(float(flatMonthsM4), "M4 Historical flat months (quality)", display = display.data_window, precision = 0, editable = false)
plot(float(invalidMonthsM4), "M4 Invalid monthly OHLC", display = display.data_window, precision = 0, editable = false)
plot(float(degenerateLevelsM4), "M4 Calculated degenerate levels", display = display.data_window, precision = 0, editable = false)
plot(float(unavailableLevelsM4), "M4 Unavailable levels (history/data)", display = display.data_window, precision = 0, editable = false)
plot(m4FlatMaxShift, "M4 Max Base shift removing flat months (pp, ex-post)", display = display.data_window, precision = 2, editable = false)

// Opt-in price labels on right axis. No chart line is plotted.
plot(customMode and customShowPrices and effectiveShowStrong ? activeStrongHighLevel : na, "Strong High price", color = strongHighColor, display = display.price_scale, format = format.price, editable = false)
plot(customMode and customShowPrices and effectiveShowAvg ? activeAvgHighLevel : na, "Avg High price", color = avgHighColor, display = display.price_scale, format = format.price, editable = false)
plot(customMode and customShowPrices and effectiveShowOpen ? activeOpenLevel : na, "Open price", color = openColor, display = display.price_scale, format = format.price, editable = false)
plot(customMode and customShowPrices and effectiveShowAvg ? activeAvgLowLevel : na, "Avg Low price", color = avgLowColor, display = display.price_scale, format = format.price, editable = false)
plot(customMode and customShowPrices and effectiveShowStrong ? activeStrongLowLevel : na, "Strong Low price", color = strongLowColor, display = display.price_scale, format = format.price, editable = false)
bool activeSeasonValid = not na(activeStrongHighLevel) and not na(activeAvgHighLevel) and not na(activeAvgLowLevel) and not na(activeStrongLowLevel)
string monthTag = switch month(monthStartTime)
    1 => "Jan"
    2 => "Feb"
    3 => "Mar"
    4 => "Apr"
    5 => "May"
    6 => "Jun"
    7 => "Jul"
    8 => "Aug"
    9 => "Sep"
    10 => "Oct"
    11 => "Nov"
    => "Dec"
string seasonalNotice = conflictingDuplicateRows > 0 ? "Datos mensuales conflictivos · Sin niveles" : not activeSeasonValid ? monthTag + ": N=" + str.tostring(sampleCount) + "/7 · Insuficiente" : seasonalLookbackObservations > 0 and sampleCount < seasonalLookbackObservations ? monthTag + ": N=" + str.tostring(sampleCount) + "/" + lookbackInput + " · Historial limitado" : ""
string recommendedSwitchNotice = recommendedModel == 1 and modelInput == "Non-seasonal" ? (recommendationScope == 2 ? "Estacional: mejor OOS este mes · Ajustes" : "Estacional: mejor OOS global · Ajustes") : recommendedModel == -1 and modelInput == "Seasonal" ? (recommendationScope == 2 ? "No estacional: mejor OOS este mes · Ajustes" : "No estacional: mejor OOS global · Ajustes") : ""
// Only emit a model-switch message if the user is not already using it.
string userNotice = seasonalNotice + (recommendedSwitchNotice != "" ? (seasonalNotice != "" ? "\n" : "") + recommendedSwitchNotice : "")
bool canDraw = activeSeasonValid
bool hasMonthOpen = not na(activeOpenLevel)
float monthOpen = activeOpenLevel

// Visual layer: the chart timeframe only draws already-computed monthly results.
var int lastMonthStartTime = na
bool isNewMonth = na(lastMonthStartTime) or monthStartTime != lastMonthStartTime
if isNewMonth
    strongHighTouched := false
    avgHighTouched := false
    openTouched := false
    avgLowTouched := false
    strongLowTouched := false
    if not na(lastMonthStartTime)
        f_update_last_x2(strongHighLines, monthStartTime)
        f_update_last_x2(avgHighLines, monthStartTime)
        f_update_last_x2(openLines, monthStartTime)
        f_update_last_x2(avgLowLines, monthStartTime)
        f_update_last_x2(strongLowLines, monthStartTime)
    if canDraw
        float strongHighLevel = activeStrongHighLevel
        float avgHighLevel = activeAvgHighLevel
        float avgLowLevel = activeAvgLowLevel
        float strongLowLevel = activeStrongLowLevel
        if effectiveShowStrong
            array.push(
                 strongHighLines,
                 line.new(
                     x1 = monthStartTime,
                     y1 = strongHighLevel,
                     x2 = time,
                     y2 = strongHighLevel,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = strongHighColor,
                     width = lineWidth,
                     style = lineStyle
                 )
            )

        if effectiveShowAvg
            array.push(
                 avgHighLines,
                 line.new(
                     x1 = monthStartTime,
                     y1 = avgHighLevel,
                     x2 = time,
                     y2 = avgHighLevel,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = avgHighColor,
                     width = lineWidth,
                     style = lineStyle
                 )
            )

        if effectiveShowOpen
            array.push(
                 openLines,
                 line.new(
                     x1 = monthStartTime,
                     y1 = monthOpen,
                     x2 = time,
                     y2 = monthOpen,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = openColor,
                     width = lineWidth,
                     style = lineStyle
                 )
            )

        if effectiveShowAvg
            array.push(
                 avgLowLines,
                 line.new(
                     x1 = monthStartTime,
                     y1 = avgLowLevel,
                     x2 = time,
                     y2 = avgLowLevel,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = avgLowColor,
                     width = lineWidth,
                     style = lineStyle
                 )
            )

        if effectiveShowStrong
            array.push(
                 strongLowLines,
                 line.new(
                     x1 = monthStartTime,
                     y1 = strongLowLevel,
                     x2 = time,
                     y2 = strongLowLevel,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = strongLowColor,
                     width = lineWidth,
                     style = lineStyle
                 )
            )

    if not canDraw and effectiveShowOpen and hasMonthOpen
        array.push(openLines, line.new(x1 = monthStartTime, y1 = monthOpen, x2 = time, y2 = monthOpen, xloc = xloc.bar_time, extend = extend.none, color = openColor, width = lineWidth, style = lineStyle))

    lastMonthStartTime := monthStartTime

// Extend current month lines to the latest available bar.
// During the first bars of a new month, keep a minimum visual length so the
// current month levels do not look collapsed.
int currentLineEndTime = f_current_line_x2(monthStartTime, time, minimumCurrentLineBars)

f_update_last_x2(strongHighLines, currentLineEndTime)
f_update_last_x2(avgHighLines, currentLineEndTime)
f_update_last_x2(openLines, currentLineEndTime)
f_update_last_x2(avgLowLines, currentLineEndTime)
f_update_last_x2(strongLowLines, currentLineEndTime)

// Keep only the requested number of visible months.
f_trim_lines(strongHighLines, visibleMonths)
f_trim_lines(avgHighLines, visibleMonths)
f_trim_lines(openLines, visibleMonths)
f_trim_lines(avgLowLines, visibleMonths)
f_trim_lines(strongLowLines, visibleMonths)

//──────────────────────────────────────────────────────────────────────────────
// M5.4.6 Pullback Map — independently evaluated daily episodes.
// No dependency on activeSeasonValid; no M2 or M3 arithmetic is modified.
// request.security() returns the previous CONFIRMED daily snapshot. For an
// intraday chart lookahead_on is safe only because of the [1] offset. For
// weekly/monthly (daily is LTF) lookahead_off selects the last daily intrabar;
// a higher-timeframe chart can lag daily events and cannot promise each alert.
//──────────────────────────────────────────────────────────────────────────────
// R5.3: confirmed DAILY model data must not inherit extended-hours chart
// session behavior. A daily equity candle is a regular-session observation,
// even when the user is viewing pre/postmarket 4H candles. Keep other symbol
// modifiers (e.g., adjustments) intact with ticker.modify().
string pbDailyTicker = syminfo.session == session.extended and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("1D") ? ticker.modify(syminfo.tickerid, session = session.regular) : syminfo.tickerid

// A security request can be unavailable on the latest intraday chart bar
// (notably before a regular-market daily candle exists). Do not discard a
// previously confirmed daily audit on the next chart execution. Persist only
// ONE latest snapshot per view, not a history of UDT copies.
var PbDailySnapshot pbDaily = na
var PbDailySnapshot pbLocal = na
var PbOriginAudit pbOrigins = na
var bool pbLatestRequestValid = false
// Prime the 1D request on the last CONFIRMED historical bar and update on the
// last chart bar (historical or realtime); do not transport UDTs on every bar.
if pbRunEngine and (barstate.islastconfirmedhistory or barstate.islast)
    PbDailyAudit snapshots = request.security(pbDailyTicker, "1D", f_pb_closed_daily(),
         lookahead = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("1D") ? barmerge.lookahead_on : barmerge.lookahead_off)
    bool viewPayloadAvailable = false
    if not na(snapshots)
        if not na(snapshots.anchor)
            pbDaily := snapshots.anchor
        if not na(snapshots.local)
            pbLocal := snapshots.local
        if not na(snapshots.origins)
            pbOrigins := snapshots.origins
        viewPayloadAvailable := pbQuantResearch and pbResearchView == "Origins" ? not na(snapshots.origins) : pbQuantResearch and pbResearchView == "Comparison" ? not na(snapshots.local) : not na(snapshots.anchor)
    pbLatestRequestValid := viewPayloadAvailable

// Production admission is deliberately CLOSED until the independent 5.4.6
// calibration, multi-asset review, and daily alert regression are complete.
// Provisional OOS criteria alone do NOT constitute release approval.
bool pbReleaseAdmitted = false
bool pbEvidenceReady = pbReleaseAdmitted and not na(pbDaily) and pbDaily.qualityState == 1 and not na(pbDaily.admittedLevel)
bool pbResearchAllowed = pbQuantPreview and (quantMode or customMode)
// Cached research observations may be displayed with an explicit warning,
// but stale snapshots must never masquerade as a live preview reference.
bool pbPreviewReady = pbLatestRequestValid and not na(pbDaily) and not na(pbDaily.previewLevel)
bool showPullbackOverlay = effectivePullbackMap and (pbEvidenceReady or (pbResearchAllowed and pbPreviewReady))
float deepPullbackLevel = showPullbackOverlay ? (pbEvidenceReady ? pbDaily.admittedLevel : pbDaily.previewLevel) : na
bool pbIsPreview = showPullbackOverlay and not pbEvidenceReady

if barstate.islast
    if not na(pullbackDeepLine)
        line.delete(pullbackDeepLine)
        pullbackDeepLine := na
    if not na(pullbackNoteLabel)
        label.delete(pullbackNoteLabel)
        pullbackNoteLabel := na
    if showPullbackOverlay and not na(deepPullbackLevel)
        int pbLineStart = math.max(bar_index - minimumCurrentLineBars + 1, 0)
        int pbLineEnd = bar_index + minimumCurrentLineBars
        pullbackDeepLine := line.new(pbLineStart, deepPullbackLevel, pbLineEnd, deepPullbackLevel,
             xloc = xloc.bar_index, color = color.new(color.gray, pbIsPreview ? 84 : 68),
             width = 1, style = line.style_dotted)
        string pbName = pbIsPreview ? "P75 1D · cierres · experimental †" : "P75 1D"
        string pbLevelNote = "EXPERIMENTAL daily CLOSE-based P75, not a validated probability of HIGH/LOW contact. Forecast is frozen at the close of the initial declining session during an episode; without an episode the preview is a training estimate. 63-session outcome counts the onset as session 1. The preview can remain visible after that horizon while the episode is open. No Pullback alerts."
        pullbackNoteLabel := label.new(pbLineEnd, deepPullbackLevel, pbName,
             xloc = xloc.bar_index, style = label.style_label_left,
             textcolor = color.new(chart.fg_color, pbIsPreview ? 60 : 38),
             color = color.new(chart.bg_color, 100), size = size.tiny,
             tooltip = pbLevelNote)
    if effectivePullbackMap and not showPullbackOverlay and not na(activeOpenLevel)
        string pbIdleText = pbQuantPreview and (quantMode or customMode) ? "P75 cierres 1D · sin nivel †" : "P75 cierres 1D · preview OFF"
        pullbackNoteLabel := label.new(bar_index + minimumCurrentLineBars * 2, activeOpenLevel,
             pbIdleText, xloc = xloc.bar_index, style = label.style_label_left,
             textcolor = color.new(chart.fg_color, 62),
             color = color.new(chart.bg_color, 100), size = size.tiny,
             tooltip = "Research-only CLOSE-based 1D P75. Preview is opt-in in Quant/Custom. No validated intraday contact probabilities; Pullback release/alerts remain blocked.")

// Never send historical backfill on alert creation. On the next confirmed
// daily event, its monotonically increasing sequence changes exactly once.
var int pbSeenTouchSequence = 0
var int pbSeenCrossSequence = 0
if not na(pbDaily)
    bool pbAlertChartSupported = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("1D")
    if barstate.isrealtime and pbReleaseAdmitted and enableAlerts and pbAlertEnabled and pbAlertChartSupported
        if pbAlertKind == "Touch" and pbDaily.touchSerial > pbSeenTouchSequence
            alert("MonLevels | " + syminfo.ticker + " | Pullback 1D touched | " + str.tostring(pbDaily.touchPrice, format.mintick) + " | Confirmed daily event; statistical reference, NOT a trading signal.", alert.freq_once_per_bar)
        if pbAlertKind == "Cross" and pbDaily.crossSerial > pbSeenCrossSequence
            alert("MonLevels | " + syminfo.ticker + " | Pullback 1D crossed | " + str.tostring(pbDaily.crossPrice, format.mintick) + " | Confirmed daily event; statistical reference, NOT a trading signal.", alert.freq_once_per_bar)
    pbSeenTouchSequence := pbDaily.touchSerial
    pbSeenCrossSequence := pbDaily.crossSerial

// Independent, optional evidence display; no plot counts added.
var table pbEvidenceTable = table.new(pbTablePosition, 2, 20, bgcolor = color.new(chart.bg_color, 10))
if barstate.islast
    table.clear(pbEvidenceTable, 0, 0, 1, 19)
    if pbQuantResearch and (quantMode or customMode)
        color pbInk = color.new(chart.fg_color, 42)
        color pbHead = color.new(chart.fg_color, 25)
        string pbStatus = na(pbDaily) ? "No data" : pbDaily.qualityState == 1 ? "Prelim. †" : "Inconclusive †"
        string pbMethod = na(pbDaily) ? "N/A" : pbDaily.selectedMethod == 2 ? "Trend · ATH" : pbDaily.selectedMethod == 1 ? "General · ATH" : "General · ATH †"
        if pbResearchView == "Episodes"
            
            f_m5_pb_row(pbEvidenceTable, 0, "Pullback 1D · cierres", pbStatus, pbHead, "Experimental CLOSE-based episode-depth quantiles. The 75% coverage target refers to closes, NOT intraday touches. No statistical certification or approved Pullback alerts.")
            
            f_m5_pb_row(pbEvidenceTable, 1, "Model", pbMethod, pbInk)
            
            bool pbEpisodeP75Frozen = not na(pbDaily) and pbDaily.openEpisodes > 0 and not na(pbDaily.previewLevel)
            string pbCurrentP75Text = na(pbDaily) or na(pbDaily.currentP75) ? "N/A" : str.tostring(pbDaily.currentP75 * 100.0, "#.##") + (pbEpisodeP75Frozen ? "% · fijado" : "% · entrenam.")
            f_m5_pb_row(pbEvidenceTable, 2, "P75 cierres · 63 ses.", pbCurrentP75Text, pbInk, "When an active episode has a valid preview, the selected P75 is FROZEN at the CLOSE of the first down session. Otherwise it is the currently selected training estimate (General or Trend). Statistical outcome through recovery or session 63, counting the initial down session as 1. It is NOT a P75 of intraday LOW/touch; alerts are blocked.")

            f_m5_pb_row(pbEvidenceTable, 3, "P75 bruto C · 63 ses.", na(pbDaily) or na(pbDaily.allP75) ? "N/A" : str.tostring(pbDaily.allP75 * 100.0, "#.##") + "%", pbInk, "Current raw training P75 from matured 63-session GENERAL close-based episode depths (C), regardless of any reference frozen for the live episode. It is not an approved intraday contact quantile. The selected live method can also be Trend, so raw General may differ even without an episode.")
            
            f_m5_pb_row(pbEvidenceTable, 4, "Episodes C/D", na(pbDaily) ? "N/A" : str.tostring(pbDaily.episodes63) + "/" + str.tostring(pbDaily.bullishEpisodes63), pbInk)
            
            f_m5_pb_row(pbEvidenceTable, 5, "OOS / paired", na(pbDaily) ? "N/A" : str.tostring(pbDaily.oosGeneral) + "/" + str.tostring(pbDaily.oosPaired), pbInk)
            
            f_m5_pb_row(pbEvidenceTable, 6, "Cover cierres / 75%", na(pbDaily) or na(pbDaily.coverageGeneral) ? "N/A" : str.tostring(pbDaily.coverageGeneral * 100.0, "#.0") + "%", pbInk, "Historical out-of-sample CLOSE-based episode depth coverage against the pre-episode P75. 75% is a nominal target, NOT an intraday LOW/touch probability or a validated contact rate.")
            
            f_m5_pb_row(pbEvidenceTable, 7, "Pinball C/D", na(pbDaily) or na(pbDaily.pinballGeneral) ? "N/A" : str.tostring(pbDaily.pinballGeneral * 100.0, "#.###") + "/" + (na(pbDaily.pinballTrend) ? "N/A" : str.tostring(pbDaily.pinballTrend * 100.0, "#.###")), pbInk, "Smaller quantile loss is better, but the samples differ here. The paired HAC comparison is used for selection.")
            
            f_m5_pb_row(pbEvidenceTable, 8, "Paired HAC lower", na(pbDaily) or na(pbDaily.pairedHacLower) ? "N/A" : str.tostring(pbDaily.pairedHacLower * 100.0, "#.###"), pbInk, "Paired general-minus-trend 63-session pinball loss, conservative HAC lower bound. Positive favors trend, conditional on robustness checks.")
            
            f_m5_pb_row(pbEvidenceTable, 9, "General rank CI", na(pbDaily) or na(pbDaily.percentileCiLo) ? "N/A" : str.tostring(pbDaily.percentileCiLo * 100.0, "#.0") + "–" + str.tostring(pbDaily.percentileCiHi * 100.0, "#.0") + "%", pbInk, "Approximate nonparametric 95% interval, descriptive only. † indicates not admitted for alerts.")
            
            f_m5_pb_row(pbEvidenceTable, 10, "Closed / open", na(pbDaily) ? "N/A" : str.tostring(pbDaily.completedEpisodes) + "/" + str.tostring(pbDaily.openEpisodes), pbInk, "Fully recovered episodes vs current incomplete episode. The 63-session horizon can mature while a drawdown stays open; such episodes are not counted as recovered.")
            
            f_m5_pb_row(pbEvidenceTable, 11, "Legacy A · bars", na(pbDaily) or na(pbDaily.legacyBarP75) ? "N/A" : str.tostring(pbDaily.legacyBarP75 * 100.0, "#.##") + "%", pbInk, "Original 30-bar rolling-close drawdowns, last 756 qualifying trend bars; duration-weighted, not independent episodes. Descriptive comparison only.")
            
            f_m5_pb_row(pbEvidenceTable, 12, "Complete B · episodes", na(pbDaily) or na(pbDaily.completeEpisodeP75) ? "N/A" : str.tostring(pbDaily.completeEpisodeP75 * 100.0, "#.##") + "%", pbInk, "P75 of depth until recovery for COMPLETE independent episodes. Open unrecovered episodes are excluded: survivor bias risk. Descriptive, not directly comparable to C/D.")
            
            string horizon21 = na(pbDaily) or na(pbDaily.horizon21Delta) ? "N/A" : str.tostring(pbDaily.horizon21Delta * 100.0, "#.###")
            string horizon126 = na(pbDaily) or na(pbDaily.horizon126Delta) ? "N/A" : str.tostring(pbDaily.horizon126Delta * 100.0, "#.###")
            string horizonSamples = na(pbDaily) ? "" : "  (" + str.tostring(pbDaily.paired21N) + "/" + str.tostring(pbDaily.paired126N) + ")"
            f_m5_pb_row(pbEvidenceTable, 13, "21 / 126d · Δ & N", horizon21 + "/" + horizon126 + horizonSamples, pbInk, "Paired 21/126-session mean pinball advantage in percentage points, with paired OOS sample N. ZERO is an equal forecast/error, NOT missing observations.")
            
            string sameForecasts = na(pbDaily) ? "N/A" : str.tostring(pbDaily.informativePaired63) + "/" + str.tostring(pbDaily.oosPaired)
            f_m5_pb_row(pbEvidenceTable, 14, "C/D informative 63d", sameForecasts, pbInk, "Number of paired OOS episodes where C and D had DIFFERENT pre-episode P75 forecasts. 0 means there is no informative superiority comparison even if total OOS N is large.")
            
            string q21 = na(pbDaily) or na(pbDaily.general21P75) ? "N/A" : str.tostring(pbDaily.general21P75 * 100.0, "#.##") + "%"
            string q126 = na(pbDaily) or na(pbDaily.general126P75) ? "N/A" : str.tostring(pbDaily.general126P75 * 100.0, "#.##") + "%"
            string qNs = na(pbDaily) ? "" : " N=" + str.tostring(pbDaily.general21N) + "/" + str.tostring(pbDaily.general126N)
            f_m5_pb_row(pbEvidenceTable, 15, "General P75 21 / 126d", q21 + " / " + q126 + qNs, pbInk, "Sensitivity horizons with one observation per matured independent episode. N describes matured training outcomes, not all are qualified OOS forecasts.")
            
            f_m5_pb_row(pbEvidenceTable, 16, "Local 20d C / D N", na(pbLocal) ? "N/A" : str.tostring(pbLocal.episodes63) + "/" + str.tostring(pbLocal.bullishEpisodes63), pbInk, "ALTERNATIVE benchmark: a local breakout above 20 previous daily closes anchors each episode; it expires after 126 valid sessions if not recovered. No overlapping episodes, no lookahead, research only.")
            
            string localQ = na(pbLocal) or na(pbLocal.allP75) ? "N/A" : str.tostring(pbLocal.allP75 * 100.0, "#.##") + "%"
            string localCi = na(pbLocal) or na(pbLocal.percentileCiLo) ? "N/A" : str.tostring(pbLocal.percentileCiLo * 100.0, "#.0") + "–" + str.tostring(pbLocal.percentileCiHi * 100.0, "#.0") + "%"
            f_m5_pb_row(pbEvidenceTable, 17, "Local P75 63d / CI", localQ + " [" + localCi + "]", pbInk, "Quantile and approximate rank CI for LOCAL episode definition. Its outcomes are not paired with the ATH benchmark: no direct Brier winner can be declared from these columns.")
            
            string localCoverage = na(pbLocal) or na(pbLocal.coverageGeneral) ? "N/A" : str.tostring(pbLocal.coverageGeneral * 100.0, "#.0") + "%"
            f_m5_pb_row(pbEvidenceTable, 18, "Local OOS / cover", na(pbLocal) ? "N/A" : str.tostring(pbLocal.oosGeneral) + " / " + localCoverage, pbInk, "Only forecasts frozen with at least 14 prior matured episodes enter OOS scoring. Coverage of local outcomes is descriptive and cannot be compared directly with ATH episode outcomes.")
            
            f_m5_pb_row(pbEvidenceTable, 19, "Local expired / open", na(pbLocal) ? "N/A" : str.tostring(pbLocal.timedOutEpisodes) + " / " + str.tostring(pbLocal.openEpisodes), pbInk, "Expired (not recovered) episodes at 126 sessions are NOT called recovered. They contribute known fixed-horizon outcomes but not complete-episode depth. Main ATH method never expires.")

        else if pbResearchView == "Comparison"
            // SAME forecast origin and SAME 63-session local-episode outcome.
            // Two candidate estimators are frozen BEFORE the future outcome.
            // No winner is allowed to drive user-visible levels or alerts.
            
            f_m5_pb_row(pbEvidenceTable, 0, "Pullback · paired", "Research †", pbHead, "Only local episodes define the common future target. ATH and Local P75 are each frozen at that same local onset. No release authority.")
            
            f_m5_pb_row(pbEvidenceTable, 1, "Local General/Trend", na(pbLocal) ? "N/A" : str.tostring(pbLocal.informativePaired63) + "/" + str.tostring(pbLocal.oosPaired), pbInk, "Count of INFORMATIVE General-vs-Trend forecast pairs in the Local method, over all locally paired OOS episodes. 0 means identical P75s.")
            
            f_m5_pb_row(pbEvidenceTable, 2, "Local C/D HAC lower", na(pbLocal) or na(pbLocal.pairedHacLower) ? "N/A" : str.tostring(pbLocal.pairedHacLower * 100.0, "#.###") + " pp", pbInk, "Approximate lower bound: General-minus-Trend Pinball in the LOCAL sample. Positive would favor Trend; not a stand-alone recommendation.")
            
            f_m5_pb_row(pbEvidenceTable, 3, "ATH / Local matched N", na(pbLocal) ? "N/A" : str.tostring(pbLocal.methodPairedN) + " (" + str.tostring(pbLocal.methodInformativeN) + " diff)", pbInk, "Each matched sample is ONE local episode. Both estimates are frozen at local onset. 'diff' counts distinct forecasts. No retrospective month or unmatched event is used.")
            
            string athLoss = na(pbLocal) or na(pbLocal.methodAthLoss) ? "N/A" : str.tostring(pbLocal.methodAthLoss * 100.0, "#.###")
            string localLoss = na(pbLocal) or na(pbLocal.methodLocalLoss) ? "N/A" : str.tostring(pbLocal.methodLocalLoss * 100.0, "#.###")
            f_m5_pb_row(pbEvidenceTable, 4, "ATH / Local Pinball", athLoss + "/" + localLoss + " pp", pbInk, "BOTH pinball losses are evaluated on identical local-episode 63-session depths. Lower is better. Differences are descriptive, and the methods use different historical training cohorts.")
            
            string athCov = na(pbLocal) or na(pbLocal.methodAthCoverage) ? "N/A" : str.tostring(pbLocal.methodAthCoverage * 100.0, "#.0")
            string localCov = na(pbLocal) or na(pbLocal.methodLocalCoverage) ? "N/A" : str.tostring(pbLocal.methodLocalCoverage * 100.0, "#.0")
            f_m5_pb_row(pbEvidenceTable, 5, "ATH / Local coverage", athCov + "/" + localCov + "%", pbInk, "Fraction of exactly the same future local-episode outcomes with depth at or below each pre-episode P75; 75% is nominal.")
            
            string methodLo = na(pbLocal) or na(pbLocal.methodHacLo) ? "N/A" : str.tostring(pbLocal.methodHacLo * 100.0, "#.###")
            string methodHi = na(pbLocal) or na(pbLocal.methodHacHi) ? "N/A" : str.tostring(pbLocal.methodHacHi * 100.0, "#.###")
            f_m5_pb_row(pbEvidenceTable, 6, "ATH−Local HAC99", "[" + methodLo + ";" + methodHi + "]", pbInk, "Approximate two-sided 99% Bartlett-HAC confidence interval, in percentage points of paired ATH-minus-Local pinball LOSS. Positive favors Local. Small samples and dependence may distort coverage; this is not release evidence.")
            
            f_m5_pb_row(pbEvidenceTable, 7, "Temporal / LOO", na(pbLocal) ? "N/A" : (pbLocal.methodHalvesPass == 1 ? "Pass" : "No") + " / " + (pbLocal.methodLooPass == 1 ? "Pass" : "No"), pbInk, "Same-direction advantage in both chronological halves, and stability after exhaustive deletion of any ONE paired episode. Merely passing does not certify statistical validity.")
            
            string methodVerdict = na(pbLocal) ? "No data" : pbLocal.methodScreenCode == 0 ? "No pair" : pbLocal.methodScreenCode == 4 ? "Identical" : pbLocal.methodScreenCode == 5 ? "N insuff." : pbLocal.methodScreenCode == 6 ? "HAC N/A" : pbLocal.methodScreenCode == 2 ? "Local + †" : pbLocal.methodScreenCode == 3 ? "ATH + †" : "Inconclusive"
            f_m5_pb_row(pbEvidenceTable, 8, "Research conclusion", methodVerdict, pbInk, "Exploratory screen only (not independent calibration, not a publish gate). No automatic model selection or alert activation is connected to this result.")
            
            f_m5_pb_row(pbEvidenceTable, 9, "Forecast freeze", "Local onset · 1D", pbInk, "Both quantiles are available from daily history before the outcome of the NEW local episode. The comparison target is local-episode maximum close-to-close drawdown through recovery or 63 days.")
            
            f_m5_pb_row(pbEvidenceTable, 10, "Release / alerts", "BLOCKED", pbInk, "Release remains hardcoded false. Preliminary comparison does not authorize a production P75 line or event alerts.")
        else
            // Exogenous origins, independent of both ATH and Local episodes.
            // DIFFERENT prospective target: future 63-session fall from origin close.
            // Forecasts are taken at the quarterly origin CLOSE and target
            // evaluation starts NEXT day. Never connected to release gates.
            
            f_m5_pb_row(pbEvidenceTable, 0, "Pullback · calendar", "Independent origins †", pbHead, "First confirmed session of each calendar quarter. A new origin is skipped when the previous 63-session outcome is still open. New prospective target, NOT episode peak-to-trough depth.")
            
            f_m5_pb_row(pbEvidenceTable, 1, "Matured / active", na(pbOrigins) ? "N/A" : str.tostring(pbOrigins.completedTargets) + "/" + str.tostring(pbOrigins.liveOrigin), pbInk)
            
            f_m5_pb_row(pbEvidenceTable, 2, "ATH/Local matched", na(pbOrigins) ? "N/A" : str.tostring(pbOrigins.pairedN) + " (" + str.tostring(pbOrigins.informativeN) + " diff)", pbInk, "Both candidate models evaluated on the SAME 63 future daily closes, with forecasts frozen at the quarterly close.")
            
            string calA = na(pbOrigins) or na(pbOrigins.pairedAthLoss) ? "N/A" : str.tostring(pbOrigins.pairedAthLoss * 100.0, "#.###")
            string calL = na(pbOrigins) or na(pbOrigins.pairedLocalLoss) ? "N/A" : str.tostring(pbOrigins.pairedLocalLoss * 100.0, "#.###")
            f_m5_pb_row(pbEvidenceTable, 3, "ATH / Local pinball", calA + "/" + calL + " pp", pbInk)
            
            string calACov = na(pbOrigins) or na(pbOrigins.pairedAthCoverage) ? "N/A" : str.tostring(pbOrigins.pairedAthCoverage * 100.0, "#.0")
            string calLCov = na(pbOrigins) or na(pbOrigins.pairedLocalCoverage) ? "N/A" : str.tostring(pbOrigins.pairedLocalCoverage * 100.0, "#.0")
            f_m5_pb_row(pbEvidenceTable, 4, "ATH / Local cover", calACov + "/" + calLCov + "%", pbInk)
            
            f_m5_pb_row(pbEvidenceTable, 5, "Matched vs calendar", na(pbOrigins) ? "N/A" : str.tostring(pbOrigins.tripleN) + " quarterly outcomes", pbInk, "All THREE forecasts scored on exactly the same future outcome. Calendar baseline trained ONLY on earlier matured quarter-origin outcomes. Requires 14 such outcomes before scoring.")
            
            string triA = na(pbOrigins) or na(pbOrigins.tripleAthLoss) ? "N/A" : str.tostring(pbOrigins.tripleAthLoss * 100.0, "#.###")
            string triL = na(pbOrigins) or na(pbOrigins.tripleLocalLoss) ? "N/A" : str.tostring(pbOrigins.tripleLocalLoss * 100.0, "#.###")
            string triC = na(pbOrigins) or na(pbOrigins.tripleCalLoss) ? "N/A" : str.tostring(pbOrigins.tripleCalLoss * 100.0, "#.###")
            f_m5_pb_row(pbEvidenceTable, 6, "ATH / Local / Cal", triA + "/" + triL + "/" + triC + " pp", pbInk, "Paired Pinball loss for a DIFFERENT target: maximum downward move over NEXT 63 daily closes relative to the origin CLOSE, not peak-to-trough episode depth. Lower is better.")
            
            string cvA = na(pbOrigins) or na(pbOrigins.tripleAthCoverage) ? "N/A" : str.tostring(pbOrigins.tripleAthCoverage * 100.0, "#.0")
            string cvL = na(pbOrigins) or na(pbOrigins.tripleLocalCoverage) ? "N/A" : str.tostring(pbOrigins.tripleLocalCoverage * 100.0, "#.0")
            string cvC = na(pbOrigins) or na(pbOrigins.tripleCalCoverage) ? "N/A" : str.tostring(pbOrigins.tripleCalCoverage * 100.0, "#.0")
            f_m5_pb_row(pbEvidenceTable, 7, "Cover A / L / Cal", cvA + "/" + cvL + "/" + cvC + "%", pbInk)
            
            string stLo = na(pbOrigins) or na(pbOrigins.pairedHacStressLow) ? "N/A" : str.tostring(pbOrigins.pairedHacStressLow * 100.0, "#.###")
            string stHi = na(pbOrigins) or na(pbOrigins.pairedHacStressHigh) ? "N/A" : str.tostring(pbOrigins.pairedHacStressHigh * 100.0, "#.###")
            f_m5_pb_row(pbEvidenceTable, 8, "HAC stress (A−L)", "[" + stLo + ";" + stHi + "]", pbInk, "Exploratory envelope of HAC 99% intervals with Bartlett lags predeclared 0/1/3/6/12, N>=32. Dependence not calibrated; NOT a selection gate.")
            
            f_m5_pb_row(pbEvidenceTable, 9, "Overlap / bad windows", na(pbOrigins) ? "N/A" : str.tostring(pbOrigins.overlapSkips) + "/" + str.tostring(pbOrigins.badWindows), pbInk)
            
            f_m5_pb_row(pbEvidenceTable, 10, "Release / alerts", "BLOCKED", pbInk, "No model winner. A fixed-calendar target is NOT interchangeable with drawdown-episode depth. P75 production and alerts remain blocked.")
            f_m5_pb_row(pbEvidenceTable, 11, "1D delivery", na(pbOrigins) ? "UNAVAILABLE" : pbLatestRequestValid ? "Confirmed" : "Cached · stale", pbInk, "The Pullback study uses regular-session 1D candles on extended-hours charts. Confirmed means the latest daily snapshot was delivered; Cached means this chart bar returned no usable daily object. Cached research is NOT eligible for previews or alerts.")

//──────────────────────────────────────────────────────────────────────────────
// Touch detection and legacy alert events
//──────────────────────────────────────────────────────────────────────────────

bool eventStrongHigh = not strongHighTouched and not na(activeStrongHighLevel) and high >= activeStrongHighLevel
bool eventAvgHigh    = not avgHighTouched and not na(activeAvgHighLevel) and high >= activeAvgHighLevel
bool eventOpen       = not openTouched and not na(activeOpenLevel) and low <= activeOpenLevel and high >= activeOpenLevel
bool eventAvgLow     = not avgLowTouched and not na(activeAvgLowLevel) and low <= activeAvgLowLevel
bool eventStrongLow  = not strongLowTouched and not na(activeStrongLowLevel) and low <= activeStrongLowLevel

bool touchStrongHigh = enableAlerts and legacyAlertsActive and alertStrongHigh and eventStrongHigh
bool touchAvgHigh    = enableAlerts and legacyAlertsActive and alertAvgHigh and eventAvgHigh
bool touchOpen       = enableAlerts and legacyAlertsActive and alertOpen and eventOpen
bool touchAvgLow     = enableAlerts and legacyAlertsActive and alertAvgLow and eventAvgLow
bool touchStrongLow  = enableAlerts and legacyAlertsActive and alertStrongLow and eventStrongLow

if eventStrongHigh
    strongHighTouched := true

if eventAvgHigh
    avgHighTouched := true

if eventOpen
    openTouched := true

if eventAvgLow
    avgLowTouched := true

if eventStrongLow
    strongLowTouched := true

//──────────────────────────────────────────────────────────────────────────────
// Current context, reading and label statistics
//──────────────────────────────────────────────────────────────────────────────

bool canCurrentContext = not na(currentContextBucket)
string contextLabel = canCurrentContext ? f_context_label(currentContextBucket) : "Context unavailable"
bool deepReactionDisplay = quantMode or (customMode and fullDashboardActive)
int contextSamples = selectedContextEligible
// Every per-level Base / Sim rate is DESCRIPTIVE (†). The paired OOS
// robust winner belongs to the AGGREGATE only (‡) and is never a per-row stamp.
string avgHighContextTouch = f_m4_pro_text(selectedContextAvgHighTouches, selEligibleAH, deepReactionDisplay, m4Winner, 1)
string strongHighContextTouch = f_m4_pro_text(selectedContextStrongHighTouches, selEligibleSH, deepReactionDisplay, m4Winner, 1)
string avgLowContextTouch = f_m4_pro_text(selectedContextAvgLowTouches, selEligibleAL, deepReactionDisplay, m4Winner, 1)
string strongLowContextTouch = f_m4_pro_text(selectedContextStrongLowTouches, selEligibleSL, deepReactionDisplay, m4Winner, 1)
string avgHighHistTouch = f_m4_pro_text(avgHighTouches, eligibleAH, deepReactionDisplay, m4Winner, -1)
string strongHighHistTouch = f_m4_pro_text(strongHighTouches, eligibleSH, deepReactionDisplay, m4Winner, -1)
string avgLowHistTouch = f_m4_pro_text(avgLowTouches, eligibleAL, deepReactionDisplay, m4Winner, -1)
string strongLowHistTouch = f_m4_pro_text(strongLowTouches, eligibleSL, deepReactionDisplay, m4Winner, -1)
string containedContextText = deepReactionDisplay ? f_m4_pro_text(selectedContextContained, selectedContextEligible, true, 0, 1) : "Evid. insuf."
string containedHistText = deepReactionDisplay ? f_m4_pro_text(containedMonths, eligibleMonths, true, 0, -1) : "Evid. insuf."
string openTopLine = "Open"
string openLabelText = proLabelsActive and activeSeasonValid and deepReactionDisplay ? openTopLine + "\nCont. Sim " + containedContextText + " | Base " + containedHistText : "Open"

// Conditional CLOSE distribution. † means DESCRIPTIVE, not forecast quality.
string avgHighBeyondText = f_compact_pct(avgHighCloseBeyond, avgHighTouches) + "†"
string strongHighBeyondText = f_compact_pct(strongHighCloseBeyond, strongHighTouches) + "†"
string avgLowBeyondText = f_compact_pct(avgLowCloseBeyond, avgLowTouches) + "†"
string strongLowBeyondText = f_compact_pct(strongLowCloseBeyond, strongLowTouches) + "†"
string avgHighRevertText = f_compact_pct(avgHighRevertOpen, avgHighTouches) + "†"
string strongHighRevertText = f_compact_pct(strongHighRevertOpen, strongHighTouches) + "†"
string avgLowRevertText = f_compact_pct(avgLowRevertOpen, avgLowTouches) + "†"
string strongLowRevertText = f_compact_pct(strongLowRevertOpen, strongLowTouches) + "†"

string strongHighDistanceText = f_distance_text(activeStrongHighLevel)
string avgHighDistanceText = f_distance_text(activeAvgHighLevel)
string avgLowDistanceText = f_distance_text(activeAvgLowLevel)
string strongLowDistanceText = f_distance_text(activeStrongLowLevel)
bool showDistance = proMode or quantMode or (customMode and showDistanceInLabels)
// In Pro we deliberately NEVER print an unvalidated contact percentage.
string strongHighLabelText = proMode ? "Strong High" + (strongHighTouched ? " touched" : "") + "\nSim " + strongHighContextTouch + " | Base " + strongHighHistTouch + (showDistance ? " | " + strongHighDistanceText : "") : f_adaptive_label("Strong High", strongHighTouched, strongHighHistTouch, strongHighContextTouch, strongHighBeyondText, strongHighRevertText, strongHighDistanceText, proLabelsActive, showDistance)
string avgHighLabelText = proMode ? "Avg High" + (avgHighTouched ? " touched" : "") + "\nSim " + avgHighContextTouch + " | Base " + avgHighHistTouch + (showDistance ? " | " + avgHighDistanceText : "") : f_adaptive_label("Avg High", avgHighTouched, avgHighHistTouch, avgHighContextTouch, avgHighBeyondText, avgHighRevertText, avgHighDistanceText, proLabelsActive, showDistance)
string avgLowLabelText = proMode ? "Avg Low" + (avgLowTouched ? " touched" : "") + "\nSim " + avgLowContextTouch + " | Base " + avgLowHistTouch + (showDistance ? " | " + avgLowDistanceText : "") : f_adaptive_label("Avg Low", avgLowTouched, avgLowHistTouch, avgLowContextTouch, avgLowBeyondText, avgLowRevertText, avgLowDistanceText, proLabelsActive, showDistance)
string strongLowLabelText = proMode ? "Strong Low" + (strongLowTouched ? " touched" : "") + "\nSim " + strongLowContextTouch + " | Base " + strongLowHistTouch + (showDistance ? " | " + strongLowDistanceText : "") : f_adaptive_label("Strong Low", strongLowTouched, strongLowHistTouch, strongLowContextTouch, strongLowBeyondText, strongLowRevertText, strongLowDistanceText, proLabelsActive, showDistance)

// Directional "Monthly Reading" is intentionally NOT used as a signal:
// its old context skew lacked evidence of predicting directional returns.
string monthlyReading = m4Winner == 1 ? "Sim lower OOS Brier‡" : m4Winner == -1 ? "Base lower OOS Brier‡" : "No robust preference"
string nearestUpName = "None"
string nearestUpDistance = "N/A"
string nearestUpSim = "N/A"
string nearestUpBase = "N/A"
int nearestUpTouch = 0
int nearestUpEligible = 0
int nearestUpContextTouch = 0
int nearestUpContextEligible = 0
float nearestUpDistanceRaw = na
if not na(activeAvgHighLevel) and close > 0 and activeAvgHighLevel >= close
    nearestUpName := "Avg High"
    nearestUpDistance := avgHighDistanceText
    nearestUpSim := avgHighContextTouch
    nearestUpBase := avgHighHistTouch
    nearestUpTouch := avgHighTouches
    nearestUpEligible := eligibleAH
    nearestUpContextTouch := selectedContextAvgHighTouches
    nearestUpContextEligible := selEligibleAH
    nearestUpDistanceRaw := activeAvgHighLevel - close
if not na(activeStrongHighLevel) and close > 0 and activeStrongHighLevel >= close
    float candidateDistance = activeStrongHighLevel - close
    if na(nearestUpDistanceRaw) or candidateDistance < nearestUpDistanceRaw
        nearestUpName := "Strong High"
        nearestUpDistance := strongHighDistanceText
        nearestUpSim := strongHighContextTouch
        nearestUpBase := strongHighHistTouch
        nearestUpTouch := strongHighTouches
        nearestUpEligible := eligibleSH
        nearestUpContextTouch := selectedContextStrongHighTouches
        nearestUpContextEligible := selEligibleSH
        nearestUpDistanceRaw := candidateDistance
string nearestDownName = "None"
string nearestDownDistance = "N/A"
string nearestDownSim = "N/A"
string nearestDownBase = "N/A"
int nearestDownTouch = 0
int nearestDownEligible = 0
int nearestDownContextTouch = 0
int nearestDownContextEligible = 0
float nearestDownDistanceRaw = na
if not na(activeAvgLowLevel) and close > 0 and activeAvgLowLevel <= close
    nearestDownName := "Avg Low"
    nearestDownDistance := avgLowDistanceText
    nearestDownSim := avgLowContextTouch
    nearestDownBase := avgLowHistTouch
    nearestDownTouch := avgLowTouches
    nearestDownEligible := eligibleAL
    nearestDownContextTouch := selectedContextAvgLowTouches
    nearestDownContextEligible := selEligibleAL
    nearestDownDistanceRaw := close - activeAvgLowLevel
if not na(activeStrongLowLevel) and close > 0 and activeStrongLowLevel <= close
    float candidateDistance = close - activeStrongLowLevel
    if na(nearestDownDistanceRaw) or candidateDistance < nearestDownDistanceRaw
        nearestDownName := "Strong Low"
        nearestDownDistance := strongLowDistanceText
        nearestDownSim := strongLowContextTouch
        nearestDownBase := strongLowHistTouch
        nearestDownTouch := strongLowTouches
        nearestDownEligible := eligibleSL
        nearestDownContextTouch := selectedContextStrongLowTouches
        nearestDownContextEligible := selEligibleSL
        nearestDownDistanceRaw := close - activeStrongLowLevel

//──────────────────────────────────────────────────────────────────────────────
// Dynamic alert() engine
//──────────────────────────────────────────────────────────────────────────────

if enableAlerts and dynamicAlertsActive and alertStrongHigh and eventStrongHigh
    alert(f_dynamic_alert_message(scriptVersion, "Strong High", activeStrongHighLevel, strongHighContextTouch, strongHighHistTouch, strongHighDistanceText, strongHighBeyondText, strongHighRevertText, contextLabel, lookbackInput), alert.freq_once_per_bar)

if enableAlerts and dynamicAlertsActive and alertAvgHigh and eventAvgHigh
    alert(f_dynamic_alert_message(scriptVersion, "Avg High", activeAvgHighLevel, avgHighContextTouch, avgHighHistTouch, avgHighDistanceText, avgHighBeyondText, avgHighRevertText, contextLabel, lookbackInput), alert.freq_once_per_bar)

if enableAlerts and dynamicAlertsActive and alertOpen and eventOpen
    alert("MonLevels " + scriptVersion + " | " + syminfo.ticker + " " + timeframe.period + " | Monthly Open touched | Open " + f_price_text(activeOpenLevel) + " | Close " + f_price_text(close) + " | Contained Sim " + containedContextText + " | Contained Base " + containedHistText + " | Context " + contextLabel + " | Lookback " + lookbackInput + " | Historical reference, not a signal.", alert.freq_once_per_bar)

if enableAlerts and dynamicAlertsActive and alertAvgLow and eventAvgLow
    alert(f_dynamic_alert_message(scriptVersion, "Avg Low", activeAvgLowLevel, avgLowContextTouch, avgLowHistTouch, avgLowDistanceText, avgLowBeyondText, avgLowRevertText, contextLabel, lookbackInput), alert.freq_once_per_bar)

if enableAlerts and dynamicAlertsActive and alertStrongLow and eventStrongLow
    alert(f_dynamic_alert_message(scriptVersion, "Strong Low", activeStrongLowLevel, strongLowContextTouch, strongLowHistTouch, strongLowDistanceText, strongLowBeyondText, strongLowRevertText, contextLabel, lookbackInput), alert.freq_once_per_bar)

//──────────────────────────────────────────────────────────────────────────────
// Labels
//──────────────────────────────────────────────────────────────────────────────

if barstate.islast
    f_clear_labels(levelLabels)
    if effectiveLabelMode != "Off"
        if effectiveLabelMode == "Current month only"
            if effectiveShowStrong and activeSeasonValid and array.size(strongHighLines) > 0
                f_add_label(levelLabels, array.get(strongHighLines, array.size(strongHighLines) - 1), strongHighLabelText, strongHighColor)
            if effectiveShowAvg and activeSeasonValid and array.size(avgHighLines) > 0
                f_add_label(levelLabels, array.get(avgHighLines, array.size(avgHighLines) - 1), avgHighLabelText, avgHighColor)
            if effectiveShowOpen and array.size(openLines) > 0
                f_add_label(levelLabels, array.get(openLines, array.size(openLines) - 1), openLabelText, openColor)
            if effectiveShowAvg and activeSeasonValid and array.size(avgLowLines) > 0
                f_add_label(levelLabels, array.get(avgLowLines, array.size(avgLowLines) - 1), avgLowLabelText, avgLowColor)
            if effectiveShowStrong and activeSeasonValid and array.size(strongLowLines) > 0
                f_add_label(levelLabels, array.get(strongLowLines, array.size(strongLowLines) - 1), strongLowLabelText, strongLowColor)
        else
            int nsh = array.size(strongHighLines)
            if effectiveShowStrong and nsh > 0
                for j = 0 to nsh - 1
                    line l = array.get(strongHighLines, j)
                    f_add_label(levelLabels, l, line.get_x1(l) == monthStartTime ? strongHighLabelText : "Strong High", strongHighColor)
            int nah = array.size(avgHighLines)
            if effectiveShowAvg and nah > 0
                for j = 0 to nah - 1
                    line l = array.get(avgHighLines, j)
                    f_add_label(levelLabels, l, line.get_x1(l) == monthStartTime ? avgHighLabelText : "Avg High", avgHighColor)
            int no = array.size(openLines)
            if effectiveShowOpen and no > 0
                for j = 0 to no - 1
                    line l = array.get(openLines, j)
                    f_add_label(levelLabels, l, line.get_x1(l) == monthStartTime ? openLabelText : "Open", openColor)
            int nal = array.size(avgLowLines)
            if effectiveShowAvg and nal > 0
                for j = 0 to nal - 1
                    line l = array.get(avgLowLines, j)
                    f_add_label(levelLabels, l, line.get_x1(l) == monthStartTime ? avgLowLabelText : "Avg Low", avgLowColor)
            int nsl = array.size(strongLowLines)
            if effectiveShowStrong and nsl > 0
                for j = 0 to nsl - 1
                    line l = array.get(strongLowLines, j)
                    f_add_label(levelLabels, l, line.get_x1(l) == monthStartTime ? strongLowLabelText : "Strong Low", strongLowColor)

// Keep notices separated from the Open label to avoid visual overlap.
var label seasonalNoticeLabel = na
var label modelNoticeLabel = na
if barstate.islast
    if not na(seasonalNoticeLabel)
        label.delete(seasonalNoticeLabel)
        seasonalNoticeLabel := na
    if not na(modelNoticeLabel)
        label.delete(modelNoticeLabel)
        modelNoticeLabel := na
    if not na(activeOpenLevel)
        float noticeStep = not na(activeAvgHighLevel) and not na(activeAvgLowLevel) ? math.max(math.abs(activeAvgHighLevel - activeAvgLowLevel) * 0.18, syminfo.mintick * 20.0) : math.max(activeOpenLevel * 0.01, syminfo.mintick * 20.0)
        if seasonalNotice != ""
            seasonalNoticeLabel := label.new(x = currentLineEndTime, y = activeOpenLevel + noticeStep, text = seasonalNotice, xloc = xloc.bar_time, style = label.style_label_left, textcolor = color.new(color.gray, 25), color = color.new(color.white, 100), size = size.tiny)
        if recommendedSwitchNotice != ""
            modelNoticeLabel := label.new(x = currentLineEndTime, y = activeOpenLevel + noticeStep * 1.9, text = recommendedSwitchNotice, xloc = xloc.bar_time, style = label.style_label_left, textcolor = color.new(color.gray, 25), color = color.new(color.white, 100), size = size.tiny)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────

var table reactionDashboard = table.new(dashboardPosition, 8, 10)
if barstate.islast
    table.clear(reactionDashboard, 0, 0, 7, 9)
    if dashboardActive and activeSeasonValid
        color headerBg = color.new(color.gray, 83)
        color headerText = color.new(chart.fg_color, 20)
        color normalText = color.new(chart.fg_color, 36)
        string rateTooltip = "† Descriptive historical frequency, NOT a calibrated forecast. ‡ Aggregate paired Brier evidence supports Base or Sim as a GROUP, never a per-level validation. High/Low rates with different denominators are NOT directly comparable."
        if nearestDashboardActive
            f_m5_table_cell(reactionDashboard, 0, 0, "Monthly", headerText, dashboardTextSize, "", headerBg)
            f_m5_table_cell(reactionDashboard, 1, 0, "Nearest", headerText, dashboardTextSize, "", headerBg)
            f_m5_table_cell(reactionDashboard, 0, 1, "Up", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 1, 1, nearestUpName, normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 2, 1, nearestUpDistance, normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 3, 1, "Base", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 4, 1, nearestUpBase, normalText, dashboardTextSize, f_m4_rate_tooltip(nearestUpTouch, nearestUpEligible, "Base Up"))
            f_m5_table_cell(reactionDashboard, 5, 1, "Sim", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 6, 1, nearestUpSim, normalText, dashboardTextSize, f_m4_rate_tooltip(nearestUpContextTouch, nearestUpContextEligible, "Sim Up"))
            f_m5_table_cell(reactionDashboard, 0, 2, "Down", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 1, 2, nearestDownName, normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 2, 2, nearestDownDistance, normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 3, 2, "Base", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 4, 2, nearestDownBase, normalText, dashboardTextSize, f_m4_rate_tooltip(nearestDownTouch, nearestDownEligible, "Base Down"))
            f_m5_table_cell(reactionDashboard, 5, 2, "Sim", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 6, 2, nearestDownSim, normalText, dashboardTextSize, f_m4_rate_tooltip(nearestDownContextTouch, nearestDownContextEligible, "Sim Down"))
            f_m5_table_cell(reactionDashboard, 0, 3, "Evidence", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 1, 3, m4Winner == 1 ? "Sim‡" : m4Winner == -1 ? "Base‡" : "Evid. insuf.", normalText, dashboardTextSize, "Paired Brier Base vs Sim; global four-level aggregate only. " + f_m4_reason_text(m4Reason))
            f_m5_table_cell(reactionDashboard, 3, 3, "OOS N", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 4, 3, str.tostring(m4OosN), normalText, dashboardTextSize)
        if fullDashboardActive
            f_m5_table_cell(reactionDashboard, 0, 0, "Monthly", headerText, dashboardTextSize, "", headerBg)
            f_m5_table_cell(reactionDashboard, 1, 0, "Reactions†", headerText, dashboardTextSize, rateTooltip, headerBg)
            for col = 0 to 7
                string columnLabel = switch col
                    0 => "Level"
                    1 => "Base"
                    2 => "Sim"
                    3 => "Sim N"
                    4 => "Beyond†"
                    5 => "Between†"
                    6 => "Revert†"
                    => "Touches"
                f_m5_table_cell(reactionDashboard, col, 1, columnLabel, normalText, dashboardTextSize)
            // Four independently eligible denominators. Close categories
            // partition valid contacts and sum to 100% up to rounding.
            for row = 2 to 5
                string nm = row == 2 ? "Avg High" : row == 3 ? "Strong High" : row == 4 ? "Avg Low" : "Strong Low"
                int h = row == 2 ? avgHighTouches : row == 3 ? strongHighTouches : row == 4 ? avgLowTouches : strongLowTouches
                int elig = row == 2 ? eligibleAH : row == 3 ? eligibleSH : row == 4 ? eligibleAL : eligibleSL
                int sh = row == 2 ? selectedContextAvgHighTouches : row == 3 ? selectedContextStrongHighTouches : row == 4 ? selectedContextAvgLowTouches : selectedContextStrongLowTouches
                int sn = row == 2 ? selEligibleAH : row == 3 ? selEligibleSH : row == 4 ? selEligibleAL : selEligibleSL
                int beyond = row == 2 ? avgHighCloseBeyond : row == 3 ? strongHighCloseBeyond : row == 4 ? avgLowCloseBeyond : strongLowCloseBeyond
                int between = row == 2 ? avgHighBetween : row == 3 ? strongHighBetween : row == 4 ? avgLowBetween : strongLowBetween
                int reverted = row == 2 ? avgHighRevertOpen : row == 3 ? strongHighRevertOpen : row == 4 ? avgLowRevertOpen : strongLowRevertOpen
                color rowColor = row <= 3 ? color.new(color.teal, 40) : color.new(color.maroon, 45)
                f_m5_table_cell(reactionDashboard, 0, row, nm, rowColor, dashboardTextSize)
                f_m5_table_cell(reactionDashboard, 1, row, f_m4_pro_text(h, elig, true, m4Winner, -1), normalText, dashboardTextSize, f_m4_rate_tooltip(h, elig, "Base"))
                f_m5_table_cell(reactionDashboard, 2, row, f_m4_pro_text(sh, sn, true, m4Winner, 1), normalText, dashboardTextSize, f_m4_rate_tooltip(sh, sn, "Sim"))
                f_m5_table_cell(reactionDashboard, 3, row, str.tostring(sn), normalText, dashboardTextSize)
                f_m5_table_cell(reactionDashboard, 4, row, f_compact_pct(beyond, h) + "†", normalText, dashboardTextSize, f_m4_rate_tooltip(beyond, h, "Close Beyond GIVEN contact"))
                f_m5_table_cell(reactionDashboard, 5, row, f_compact_pct(between, h) + "†", normalText, dashboardTextSize, f_m4_rate_tooltip(between, h, "Close Between GIVEN contact"))
                f_m5_table_cell(reactionDashboard, 6, row, f_compact_pct(reverted, h) + "†", normalText, dashboardTextSize, f_m4_rate_tooltip(reverted, h, "Close Revert GIVEN contact"))
                f_m5_table_cell(reactionDashboard, 7, row, str.tostring(h), normalText, dashboardTextSize, "Base eligible months N=" + str.tostring(elig) + "; contact events=" + str.tostring(h))
            f_m5_table_cell(reactionDashboard, 0, 6, "OOS Base/Sim", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 1, 6, "Brier", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 2, 6, na(m4BrierBase) ? "N/A" : str.tostring(m4BrierBase, "#.###"), normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 3, 6, na(m4BrierSim) ? "N/A" : str.tostring(m4BrierSim, "#.###"), normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 4, 6, "N=" + str.tostring(m4OosN), normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 5, 6, m4Winner == 1 ? "Sim‡" : m4Winner == -1 ? "Base‡" : "Inconcluso", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 0, 7, "Context", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 1, 7, contextLabel, normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 3, 7, "Flat", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 4, 7, str.tostring(flatMonthsM4), normalText, dashboardTextSize, "Historical full-OHLC flat bars are counted transparently, not removed after seeing the outcome. They may reflect a different regime/source.")
            f_m5_table_cell(reactionDashboard, 5, 7, "Flat shift", normalText, dashboardTextSize, "EX-POST sensitivity only; never removes months from the OOS target sample or chooses a winning model.")
            f_m5_table_cell(reactionDashboard, 6, 7, (na(m4FlatMaxShift) ? "N/A" : str.tostring(m4FlatMaxShift, "#.0") + "pp"), normalText, dashboardTextSize)
            string commonCohortTooltip = "Same-cohort diagnostic ONLY: " + str.tostring(commonEligibleM4) + " completed months with all four directional levels valid; AH " + str.tostring(commonTouchAHM4) + ", SH " + str.tostring(commonTouchSHM4) + ", AL " + str.tostring(commonTouchALM4) + ", SL " + str.tostring(commonTouchSLM4) + ". High-minus-Low deltas here compare the SAME months, without changing the original per-level Base denominators. Descriptive, NOT a trading signal."
            f_m5_table_cell(reactionDashboard, 7, 7, "Joint N=" + str.tostring(commonEligibleM4), normalText, dashboardTextSize, commonCohortTooltip)
            f_m5_table_cell(reactionDashboard, 0, 8, "Evidence", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 1, 8, f_m4_reason_text(m4Reason), normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 4, 8, "Cal gap", normalText, dashboardTextSize)
            f_m5_table_cell(reactionDashboard, 5, 8, na(m4CalibrationBase) ? "N/A" : str.tostring(m4CalibrationBase, "#.###"), normalText, dashboardTextSize, "Base aggregate mean observed-minus-forecast gap magnitude. Not a complete reliability curve.")
            f_m5_table_cell(reactionDashboard, 6, 8, na(m4CalibrationSim) ? "N/A" : str.tostring(m4CalibrationSim, "#.###"), normalText, dashboardTextSize, "Sim aggregate mean observed-minus-forecast gap magnitude. Not a complete reliability curve.")
            float commonAvgDeltaRaw = commonEligibleM4 > 0 ? (commonTouchAHM4 - commonTouchALM4) * 100.0 / commonEligibleM4 : na
            float commonStrongDeltaRaw = commonEligibleM4 > 0 ? (commonTouchSHM4 - commonTouchSLM4) * 100.0 / commonEligibleM4 : na
            string commonAvgDelta = na(commonAvgDeltaRaw) ? "N/A" : (commonAvgDeltaRaw > 0 ? "+" : "") + str.tostring(commonAvgDeltaRaw, "#.0") + "pp"
            string commonStrongDelta = na(commonStrongDeltaRaw) ? "N/A" : (commonStrongDeltaRaw > 0 ? "+" : "") + str.tostring(commonStrongDeltaRaw, "#.0") + "pp"
            f_m5_table_cell(reactionDashboard, 7, 8, "A " + commonAvgDelta + " · S " + commonStrongDelta, normalText, dashboardTextSize, commonCohortTooltip + " Δ Avg and Δ Strong = High touch rate minus Low touch rate (percentage points) within same cohort.")
            f_m5_table_cell(reactionDashboard, 0, 9, "† Descriptive", normalText, dashboardTextSize, rateTooltip)
            f_m5_table_cell(reactionDashboard, 1, 9, "‡ Aggregate OOS", normalText, dashboardTextSize, rateTooltip)
            f_m5_table_cell(reactionDashboard, 4, 9, "Not a signal", normalText, dashboardTextSize)
//──────────────────────────────────────────────────────────────────────────────
// Model comparison: separate, compact opt-in table (Off by default).
// Global/Month HAC represents ONE PAIRED difference G - S, not two tests.
// The identical interval is repeated verbatim in S and NS columns.
// Colors indicate its favored side only when it excludes zero.
// Raw per-side MAE is descriptive; the final winner uses all robust gates.
//──────────────────────────────────────────────────────────────────────────────
// M5.2 EXPERIMENTAL -- optional side-by-side ablation. No plot budget used.
// Ranks are OBSERVED Brier only; significance, multiplicity, stability and
// additional out-of-sample verification belong to 5.3. No operational switch.
var table m5AblationTable = table.new(m5TablePosition, 5, 14, bgcolor = color.new(chart.bg_color, 10))
if barstate.islast and effectiveM5Table
    color m5Text = color.new(chart.fg_color, 30)
    color m5Header = color.new(chart.fg_color, 50)
    color m5HeaderBg = color.new(chart.fg_color, 93)
    string m5Tip = "EXPERIMENTAL M5.2: eight same-cohort, prequential monthly forecasts. Average four binary level-contact Brier losses. A = prior direction; B = prior range; C = opening gap. Neutral factors or empty cells fall back to Base. All models use identical scored months, Jeffreys half-count smoothing, and the selected level model. No statistically validated winner yet."
    f_m5_table_cell(m5AblationTable, 0, 0, "M5 Study", m5Header, m5TableTextSize, m5Tip, m5HeaderBg)
    f_m5_table_cell(m5AblationTable, 1, 0, "Brier ↓", m5Header, m5TableTextSize, m5Tip, m5HeaderBg)
    f_m5_table_cell(m5AblationTable, 2, 0, "vs Base", m5Header, m5TableTextSize, m5Tip, m5HeaderBg)
    f_m5_table_cell(m5AblationTable, 3, 0, "Ctx N", m5Header, m5TableTextSize, "Current context support. N=0 implies neutral/missing context or no historical observations, and then Base fallback is used.", m5HeaderBg)
    f_m5_table_cell(m5AblationTable, 4, 0, "5.3 screen", m5Header, m5TableTextSize, "Research screen only: paired HAC with conservative 13-test Bonferroni, temporal halves and exact worst single deletion. C/B stress is fully tested for B+C only; no model promotion or operational switching.", m5HeaderBg)
    array<int> m5ScreensDisplay = array.from(0, m5Screen1, m5Screen2, m5Screen3, m5Screen4, m5Screen5, m5Screen6, m5Screen7)
    array<float> m5ScoresNow = array.from(m5Score0, m5Score1, m5Score2, m5Score3, m5Score4, m5Score5, m5Score6, m5Score7)
    array<int> m5SupportsNow = array.from(m5Support0, m5Support1, m5Support2, m5Support3, m5Support4, m5Support5, m5Support6, m5Support7)
    float m5BaseScore = m5Score0
    for mask = 0 to 7
        int row = mask + 1
        float value = array.get(m5ScoresNow, mask)
        float relativeImprovement = not na(value) and not na(m5BaseScore) and m5BaseScore > 0 ? 100.0 * (m5BaseScore - value) / m5BaseScore : na
        string scoreText = na(value) ? "N/A" : str.tostring(value, "#.####")
        string deltaText = mask == 0 ? "ref" : na(relativeImprovement) ? "N/A" : (relativeImprovement >= 0 ? "+" : "") + str.tostring(relativeImprovement, "#.0") + "%"
        f_m5_table_cell(m5AblationTable, 0, row, f_m5_model_label(mask), m5Text, m5TableTextSize, m5Tip)
        f_m5_table_cell(m5AblationTable, 1, row, scoreText, m5Text, m5TableTextSize, "Mean paired OOS Brier (lower = better), UNVALIDATED exploratory comparison.")
        f_m5_table_cell(m5AblationTable, 2, row, deltaText, m5Text, m5TableTextSize, "Descriptive relative change versus smoothed Base on the SAME eval months. Does not establish statistical superiority.")
        f_m5_table_cell(m5AblationTable, 3, row, str.tostring(array.get(m5SupportsNow, mask)), m5Text, m5TableTextSize, "Historical support for the CURRENT month's requested context. Zero means neutral/missing or empty bin, so Base fallback is used.")
        int status = array.get(m5ScreensDisplay, mask)
        string gate = not m5InferenceEnabled ? "off" : mask == 0 ? "ref" : status == 0 ? "N/SE" : status == 1 ? "CI=0" : status == 2 ? "Halves" : status == 3 ? "LOO" : status == 4 ? "Stress?" : "Screen+"
        f_m5_table_cell(m5AblationTable, 4, row, gate, status == 5 ? color.new(color.teal, 30) : m5Text, m5TableTextSize, "Screen+: preliminary positive paired-HAC, temporal halves, worst single deletion and (for B+C only) 4 OOS stress alternatives. It is NOT an independently validated model winner. Stress? indicates additional B/C validation missing or failed. CI=0 includes zero.")
    f_m5_table_cell(m5AblationTable, 0, 9, "OOS", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 1, 9, "N=" + str.tostring(m5OosN), m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 2, 9, "Training", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 3, 9, str.tostring(m5TrainingMonths), m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 0, 10, "Exploratory", m5Header, m5TableTextSize, "No model winner authorized before 5.3: paired inference and multiple-testing correction pending.")
    f_m5_table_cell(m5AblationTable, 1, 10, "No winner", m5Header, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 2, 10, "Neutral", m5Header, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 3, 10, str.tostring(m5NeutralTrainingMonths), m5Header, m5TableTextSize, "Training months where at least one of A/B/C is neutral or unavailable. No forced-positive classification.")
    f_m5_table_cell(m5AblationTable, 4, 10, m5InferenceEnabled ? "Screen+ " + str.tostring(m5ScreenCount) : "5.3 off", m5Header, m5TableTextSize, "No operational winner is authorized in M5.3 even if a candidate passes preliminary screens. The 5.5 product decision is separate.")
    f_m5_table_cell(m5AblationTable, 0, 11, "B+C HAC", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 1, 11, m5InferenceEnabled and not na(m5BCciLo) ? str.tostring(m5BCciLo, "#.####") : "N/A", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 2, 11, m5InferenceEnabled and not na(m5BCciHi) ? str.tostring(m5BCciHi, "#.####") : "N/A", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 3, 11, "Bonf 13", m5Text, m5TableTextSize, "Conservative 13-family critical value applied to seven positive candidate-vs-Base HAC comparisons. Approximate finite-sample inference.")
    f_m5_table_cell(m5AblationTable, 4, 11, "NOT a signal", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 0, 12, "B+C C gap", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 1, 12, na(m5AltC1) ? "N/A" : str.tostring(m5AltC1, "#.####"), m5Text, m5TableTextSize, "OOS Brier when C is neutral within 1bp of the previous close, same scored months.")
    f_m5_table_cell(m5AblationTable, 2, 12, na(m5AltC5) ? "N/A" : str.tostring(m5AltC5, "#.####"), m5Text, m5TableTextSize, "OOS Brier when C is neutral within 5bp of the previous close, same scored months.")
    f_m5_table_cell(m5AblationTable, 3, 12, "1bp/5bp", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 4, 12, "stress", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 0, 13, "B+C B range", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 1, 13, na(m5AltB120) ? "N/A" : str.tostring(m5AltB120, "#.####"), m5Text, m5TableTextSize, "OOS Brier with a 120-month range reference for B, not a change to lookback levels.")
    f_m5_table_cell(m5AblationTable, 2, 13, na(m5AltB360) ? "N/A" : str.tostring(m5AltB360, "#.####"), m5Text, m5TableTextSize, "OOS Brier with a 360-month range reference for B, not a change to lookback levels.")
    f_m5_table_cell(m5AblationTable, 3, 13, "120/360m", m5Text, m5TableTextSize)
    f_m5_table_cell(m5AblationTable, 4, 13, "stress", m5Text, m5TableTextSize)

var table m3EvidenceTable = table.new(m3TablePosition, 4, 8, bgcolor = color.new(chart.bg_color, 15))
if barstate.islast and effectiveM3Table
    color neutralText = color.new(chart.fg_color, 42)
    color mutedHeader = color.new(chart.fg_color, 28)
    color mutedHeaderBg = color.new(chart.fg_color, 93)
    string globalCiDisplay = conflictingDuplicateRows > 0 ? "N/A" : f_m3_ci_text(ciGlobalLow, ciGlobalHigh)
    string monthCiDisplay = conflictingDuplicateRows > 0 ? "N/A" : f_m3_ci_text(ciCalendarLow, ciCalendarHigh)
    int globalCiFavored = conflictingDuplicateRows > 0 ? 0 : f_m3_direction_from_ci(ciGlobalLow, ciGlobalHigh)
    int monthCiFavored = conflictingDuplicateRows > 0 ? 0 : f_m3_direction_from_ci(ciCalendarLow, ciCalendarHigh)
    int highMaeFavored = na(seasonHighMaeGlobal) or na(generalHighMaeGlobal) ? 0 : seasonHighMaeGlobal < generalHighMaeGlobal - 0.0000000001 ? 1 : generalHighMaeGlobal < seasonHighMaeGlobal - 0.0000000001 ? -1 : 0
    int lowMaeFavored = na(seasonLowMaeGlobal) or na(generalLowMaeGlobal) ? 0 : seasonLowMaeGlobal < generalLowMaeGlobal - 0.0000000001 ? 1 : generalLowMaeGlobal < seasonLowMaeGlobal - 0.0000000001 ? -1 : 0
    string scopeLabel = recommendationScope == 2 ? "Month" : recommendationScope == 1 ? "Global" : "None"
    string formalWinnerText = recommendedModel == 1 ? "Seasonal" : recommendedModel == -1 ? "Nonseasonal" : "Inconclusive"
    string reasonText = recommendedModel == 0 ? f_m3_reason_text(abstentionReason, seasonalLookbackObservations == 0) : recommendationScope == 1 ? "Global robustness passed" : recommendationScope == 2 ? "Month robustness passed" : "Robustness passed"
    string hacTooltip = "ONE paired OOS HAC interval, G minus S, repeated in both columns. Above 0 favors Seasonal; below 0 favors Nonseasonal. Finite-sample block-t guard + lag/positive-dependence envelope, 13-comparison Bonferroni. Approximate inference, NOT exact coverage. Units: percentage points of extension error."
    f_m5_table_cell(m3EvidenceTable, 0, 0, "Evidence", mutedHeader, m3TableTextSize, "", mutedHeaderBg)
    f_m5_table_cell(m3EvidenceTable, 1, 0, "Seasonal", mutedHeader, m3TableTextSize, "", mutedHeaderBg)
    f_m5_table_cell(m3EvidenceTable, 2, 0, "Nonseasonal", mutedHeader, m3TableTextSize, "", mutedHeaderBg)
    f_m5_table_cell(m3EvidenceTable, 3, 0, "Result", mutedHeader, m3TableTextSize, "", mutedHeaderBg)
    f_m5_table_cell(m3EvidenceTable, 0, 1, "Global HAC (pp)", neutralText, m3TableTextSize, hacTooltip)
    f_m5_table_cell(m3EvidenceTable, 1, 1, globalCiDisplay, f_m3_cell_text_color(globalCiFavored, 1), m3TableTextSize, hacTooltip, f_m3_cell_background(globalCiFavored, 1))
    f_m5_table_cell(m3EvidenceTable, 2, 1, globalCiDisplay, f_m3_cell_text_color(globalCiFavored, -1), m3TableTextSize, hacTooltip, f_m3_cell_background(globalCiFavored, -1))
    f_m5_table_cell(m3EvidenceTable, 3, 1, globalCiFavored == 1 ? "S" : globalCiFavored == -1 ? "NS" : "INC", neutralText, m3TableTextSize)
    f_m5_table_cell(m3EvidenceTable, 0, 2, "Month HAC (pp)", neutralText, m3TableTextSize, hacTooltip)
    f_m5_table_cell(m3EvidenceTable, 1, 2, monthCiDisplay, f_m3_cell_text_color(monthCiFavored, 1), m3TableTextSize, hacTooltip, f_m3_cell_background(monthCiFavored, 1))
    f_m5_table_cell(m3EvidenceTable, 2, 2, monthCiDisplay, f_m3_cell_text_color(monthCiFavored, -1), m3TableTextSize, hacTooltip, f_m3_cell_background(monthCiFavored, -1))
    f_m5_table_cell(m3EvidenceTable, 3, 2, monthCiFavored == 1 ? "S" : monthCiFavored == -1 ? "NS" : "INC", neutralText, m3TableTextSize)
    string maeTooltip = "Paired global OOS mean absolute error of monthly high/low extension, in percentage points. Smaller means lower measured error but not necessarily robust significance."
    f_m5_table_cell(m3EvidenceTable, 0, 3, "High OOS MAE", neutralText, m3TableTextSize, maeTooltip)
    f_m5_table_cell(m3EvidenceTable, 1, 3, na(seasonHighMaeGlobal) ? "N/A" : str.tostring(seasonHighMaeGlobal * 100.0, "#.##") + "pp", f_m3_cell_text_color(highMaeFavored, 1), m3TableTextSize, maeTooltip, f_m3_cell_background(highMaeFavored, 1))
    f_m5_table_cell(m3EvidenceTable, 2, 3, na(generalHighMaeGlobal) ? "N/A" : str.tostring(generalHighMaeGlobal * 100.0, "#.##") + "pp", f_m3_cell_text_color(highMaeFavored, -1), m3TableTextSize, maeTooltip, f_m3_cell_background(highMaeFavored, -1))
    f_m5_table_cell(m3EvidenceTable, 3, 3, highMaeFavored == 1 ? "S" : highMaeFavored == -1 ? "NS" : "INC", neutralText, m3TableTextSize)
    f_m5_table_cell(m3EvidenceTable, 0, 4, "Low OOS MAE", neutralText, m3TableTextSize, maeTooltip)
    f_m5_table_cell(m3EvidenceTable, 1, 4, na(seasonLowMaeGlobal) ? "N/A" : str.tostring(seasonLowMaeGlobal * 100.0, "#.##") + "pp", f_m3_cell_text_color(lowMaeFavored, 1), m3TableTextSize, maeTooltip, f_m3_cell_background(lowMaeFavored, 1))
    f_m5_table_cell(m3EvidenceTable, 2, 4, na(generalLowMaeGlobal) ? "N/A" : str.tostring(generalLowMaeGlobal * 100.0, "#.##") + "pp", f_m3_cell_text_color(lowMaeFavored, -1), m3TableTextSize, maeTooltip, f_m3_cell_background(lowMaeFavored, -1))
    f_m5_table_cell(m3EvidenceTable, 3, 4, lowMaeFavored == 1 ? "S" : lowMaeFavored == -1 ? "NS" : "INC", neutralText, m3TableTextSize)
    string pairedSampleLabel = str.tostring(wfN) + "/" + str.tostring(wfCalendarN)
    string pairedSampleTooltip = "Paired OOS observation counts: global/month. Both models are scored on the SAME observations; these are not separate model samples."
    f_m5_table_cell(m3EvidenceTable, 0, 5, "OOS N (G/M)", neutralText, m3TableTextSize, pairedSampleTooltip)
    f_m5_table_cell(m3EvidenceTable, 1, 5, pairedSampleLabel, neutralText, m3TableTextSize, pairedSampleTooltip)
    f_m5_table_cell(m3EvidenceTable, 2, 5, pairedSampleLabel, neutralText, m3TableTextSize, pairedSampleTooltip)
    f_m5_table_cell(m3EvidenceTable, 3, 5, scopeLabel, neutralText, m3TableTextSize, pairedSampleTooltip)
    f_m5_table_cell(m3EvidenceTable, 0, 6, "Favored model", mutedHeader, m3TableTextSize, "", mutedHeaderBg)
    f_m5_table_cell(m3EvidenceTable, 1, 6, recommendedModel == 1 ? "FAVORED" : recommendedModel == -1 ? "Other" : "—", f_m3_cell_text_color(recommendedModel, 1), m3TableTextSize, "", f_m3_cell_background(recommendedModel, 1))
    f_m5_table_cell(m3EvidenceTable, 2, 6, recommendedModel == -1 ? "FAVORED" : recommendedModel == 1 ? "Other" : "—", f_m3_cell_text_color(recommendedModel, -1), m3TableTextSize, "", f_m3_cell_background(recommendedModel, -1))
    f_m5_table_cell(m3EvidenceTable, 3, 6, formalWinnerText, f_m3_cell_text_color(recommendedModel, recommendedModel), m3TableTextSize)
    f_m5_table_cell(m3EvidenceTable, 0, 7, "Decision", neutralText, m3TableTextSize)
    table.cell(m3EvidenceTable, 1, 7, "", text_size = m3TableTextSize)
    table.cell(m3EvidenceTable, 2, 7, "", text_size = m3TableTextSize)
    f_m5_table_cell(m3EvidenceTable, 3, 7, reasonText, neutralText, m3TableTextSize, "Decision requires HAC CI, direction, temporal stability, influence and historical-window checks. With All, the window check uses the recent half of confirmed history (overlapping data, NOT an independent or horizon-matched sample).")
if barstate.islast and not effectiveM3Table
    table.clear(m3EvidenceTable, 0, 0, 3, 7)

//──────────────────────────────────────────────────────────────────────────────
// Alertcondition declarations
//──────────────────────────────────────────────────────────────────────────────

alertcondition(touchStrongHigh, "Strong High touched", "Strong High monthly statistical level touched.")
alertcondition(touchAvgHigh, "Avg High touched", "Avg High monthly statistical level touched.")
alertcondition(touchOpen, "Open touched", "Monthly open touched.")
alertcondition(touchAvgLow, "Avg Low touched", "Avg Low monthly statistical level touched.")
alertcondition(touchStrongLow, "Strong Low touched", "Strong Low monthly statistical level touched.")
````
