# Time Stop Planner [AGPro Series]

- url: https://www.tradingview.com/script/lTtT94ps-Time-Stop-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;c81a13eb32234cc5a7775343d483be7a
- version: 9.0

## Description

Time Stop Planner [AGPro Series]

🧠 Core Idea

Has a setup spent too much time without enough progress?


📌 Overview / What it does

Time Stop Planner is a chart-first trade management overlay designed to evaluate the lifecycle of a triggered setup after price breaks from a prior structure. Instead of showing another generic signal, it asks whether the setup is actually making enough progress before the time window starts working against it.

The script builds a forward lifecycle box, maps a trigger reference, an invalidation rail, and a progress target reference, then scores the active setup from 0 to 100 using elapsed bars, distance traveled, follow-through quality, volatility decay, and invalidation proximity.

It does not predict future price movement, automate trade decisions, or promise that a setup will continue. Its purpose is to turn time, progress, and risk context into a cleaner visual decision framework.


🎯 Purpose & Design Philosophy

This script was built for traders who already have a setup idea but need a cleaner way to judge whether that setup is still alive, losing quality, or becoming stale.

Many tools focus on entries or targets. Time Stop Planner focuses on the often-overlooked middle stage: what happens after a setup activates but before the outcome is clear. It supports a disciplined review process by showing whether progress is keeping pace with elapsed time.

The design philosophy is simple: a setup should not remain interesting forever just because it once looked valid. The chart should make lifecycle quality visible.


⚡ Why This Script Is Different

Most tools focus on trigger signals, stop levels, or target projections.

This script does NOT behave like a generic timer dashboard, a stop-loss optimizer, a full position planner, or a profit-target ladder.

Instead, it connects time directly to progress quality. A setup is evaluated through a visible lifecycle window, a progress score, time-risk pressure, invalidation context, and a clear next-action state.


⚙️ Methodology

1. Context Detection
The script detects a directional setup lifecycle when price breaks beyond a prior structure boundary with sufficient candle body strength, close location quality, and optional trend support.

2. Reference Mapping
After activation, the script maps the trigger reference, invalidation rail, and ATR-based progress target reference. These levels create the lifecycle framework used for progress and risk evaluation.

3. Reaction Evaluation
The engine measures elapsed bars, directional travel, close-based follow-through, volatility behavior, and distance from invalidation. These components are converted into a 0-100 quality score and a separate time-risk reading.

4. Visual Output
The chart displays a lifecycle box, rails, checkpoint labels, state labels, and a compact AGPro panel. The active box text is centered inside the lifecycle area for clean chart reading.


🗺️ How to Read the Chart

Zones = the lifecycle box shows the active time window in which the setup should show reasonable progress.

Rails = the trigger reference, progress target reference, and invalidation rail define the active setup map.

Labels = setup, checkpoint, continue, time-risk, expired, and invalidated labels mark important lifecycle events.

Colors = green/teal suggests constructive progress, amber suggests time-risk or expiry pressure, pink suggests invalidation or failed lifecycle context, and indigo marks neutral active structure.

Panel = the panel summarizes Bars Active, Progress Score, Time Risk, Invalidation, and Action.


🚦 Signals & States

• New Time Stop Lifecycle → a new setup lifecycle window has been detected.

• Continue Review → progress and quality are strong enough to keep the lifecycle under constructive review.

• Time Risk → elapsed time is high relative to progress, so the setup deserves closer review.

• Lifecycle Expired → the active lifecycle reached its time boundary without enough progress.

• Lifecycle Invalidated → price closed beyond the invalidation rail.


🔔 Alerts Logic

The script includes alerts for:

• New Time Stop Lifecycle
• Continue Review State
• Time Risk State
• Lifecycle Expired
• Lifecycle Invalidated

These alerts are attention markers. They are not trade instructions, automated orders, or guaranteed outcome signals.


🧩 Confluence Logic

The strongest lifecycle context appears when structure break quality, candle body strength, close location, trend support, progress travel, and invalidation distance align.

When progress improves while time-risk stays low, the active lifecycle becomes more constructive. When elapsed bars increase while progress remains weak, the setup becomes more vulnerable to time-stop review.


📊 When to Use

• After a clean structure break
• During breakout follow-through review
• During trend continuation management
• When a setup is active but progress is unclear
• When you want a rule-based way to identify stale setups


⚠️ When NOT to Use

• Extremely low-liquidity symbols
• Very noisy markets with repeated false breaks
• News-driven spikes where ATR behavior becomes distorted
• Markets where structure boundaries are not meaningful
• As a standalone entry or exit system


🎛️ Key Inputs

• Sensitivity → controls how strict the setup activation logic is.

• Structure Lookback → defines the prior boundary used for lifecycle activation.

• Lifecycle Window Bars → sets how long a setup can remain active before time-risk becomes dominant.

• Minimum Progress % → defines how much progress is expected before expiry pressure matters.

• Progress Target ATR → sets the ATR-based progress reference.

• Invalidation Buffer ATR → controls the distance of the invalidation rail.

• Label Font Size and Panel Font Size → control visual readability.

• Panel Location and Panel Theme → customize the AGPro summary panel.


🖥️ Interface & Visual Design

The interface is built around a clean chart-first workflow. The lifecycle box is the primary visual object, and its centered text summarizes the active state without requiring extra dashboard interpretation.

The panel is compact and uses the AGPro standard first row: one merged blue header row containing only the panel title. The remaining rows focus on time, progress, risk, invalidation, and the next review state.

Labels are limited by cooldown and max-visible controls so the chart remains informative without becoming crowded.


🧪 Practical Usage Workflow

1. Read the panel to identify the current lifecycle state.

2. Check the lifecycle box and rails to understand the active structure.

3. Compare Bars Active with Progress Score.

4. Watch whether Time Risk rises before meaningful progress appears.

5. Use invalidation context to decide whether the setup is still structurally relevant.


🔍 Interpretation Guidelines

A high score does not mean price must continue. It means the active lifecycle is progressing well under the script's rules.

A high time-risk reading does not mean price must reverse. It means time is becoming less favorable relative to progress.

An expired lifecycle does not judge the broader market. It only says the active setup window did not produce enough progress within the configured time boundary.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not auto trading
• Not guaranteed signals
• Not a stop-loss optimizer
• Not a full position planner
• Not a profit-target promise tool


⚠️ Limitations & Transparency

The script uses rule-based structure detection and ATR-based references, so results can vary across symbols, sessions, and timeframes.

Confirmed lifecycle states depend on the selected lookback, sensitivity, ATR settings, and volatility conditions.

During sideways chop, repeated structure breaks may produce lifecycles that expire quickly. During extreme volatility, time and progress readings may change rapidly.


🧠 Market Context Notes

Time is part of risk. A setup that does not progress can become less useful even if it has not technically invalidated.

This script is designed to make that time component visible without turning it into a direct trade command.


🧾 Use Case Examples

When price breaks above a prior structure and the lifecycle box appears, the trader can watch whether progress develops before the time window matures.

When progress remains weak and the Time Risk state appears, the trader can reassess whether the original setup idea still deserves attention.

When price closes beyond the invalidation rail, the lifecycle is marked invalidated and the context resets.


🧱 System Philosophy

Time Stop Planner belongs to the AGPro decision-engine style: it does not simply show data. It organizes setup validity, progress quality, risk context, and next-action state into one readable workflow.


🔐 Non-Promise Statement

This script does not provide certainty.

It does not guarantee continuation, reversal, profit, or protection from loss.


📉 Risk Disclosure

Trading involves risk.

All outputs from this script are educational and analytical only.

Users remain responsible for their own decisions, risk management, and market interpretation.

This script does not provide financial advice.


📚 Educational Note

Use the script as a structured way to study time, progress, and invalidation behavior after a setup activates. The value is in consistent interpretation, not in treating any state as a command.

## Source Code

````pine
// -------------------------------------------------
// Time Stop Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.10
//
// Time Stop Planner is a chart-first trade management overlay that answers a single
// question: is this triggered setup still progressing fast enough to justify holding it,
// or has it stalled into time risk? It maps elapsed bars, follow-through quality,
// volatility decay, invalidation distance, and a 0-100 progress score into a clean
// time-stop decision framework, and adds a confirmation-anchored proof layer
// (Follow, Hold, React, Flip rates) that shows how past lifecycles on this symbol resolved.
// -------------------------------------------------

//@version=6
indicator("Time Stop Planner [AGPro Series]",
     shorttitle       = "AG Pro TSP",
     overlay          = true,
     max_labels_count = 140,
     max_boxes_count  = 30,
     max_lines_count  = 90)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttPreset = "Selects the lifecycle operating profile. Balanced Lifecycle is the publication default. Cleaner Swing reduces label density. Active Intraday reacts faster. Custom uses the raw inputs below."
string ttSensitivity = "Controls how strict the setup activation logic is. Aggressive reacts faster, Conservative requires stronger momentum and cleaner structure."
string ttLookback = "Number of bars used to define the pre-trigger structure boundary. Higher values require a more meaningful breakout from the prior structure."
string ttAtr = "ATR length used for lifecycle sizing, invalidation distance, label offsets, and volatility-normalized scoring."
string ttFast = "Fast trend reference used to avoid activating weak setup lifecycles against immediate directional context."
string ttSlow = "Slow trend reference used with the fast EMA to classify directional support for a new lifecycle."
string ttTrendFilter = "When enabled, upside lifecycles require fast trend support and downside lifecycles require bearish trend support."
string ttBody = "Minimum trigger candle body size relative to ATR. This helps avoid starting a lifecycle after weak, low-information candles."
string ttCloseLocation = "Requires the trigger close to finish in the directional portion of the candle range. Higher values demand cleaner close quality."
string ttWindow = "Maximum number of bars a setup can remain active before time-risk and expiry logic become dominant."
string ttLifecycleCooldown = "Minimum bars to wait after a lifecycle closes before a new lifecycle can arm. Higher values reduce repeated lifecycle clusters."
string ttProgress = "Minimum target-path progress expected before the lifecycle reaches its time-stop boundary."
string ttTarget = "ATR distance used to define the progress target reference for the active lifecycle. This is an analytical target reference, not a promised outcome."
string ttInvalid = "ATR buffer beyond the trigger candle used to create the lifecycle invalidation rail."
string ttTimeRisk = "Time-risk value at which the script marks the setup as needing review because progress is lagging behind elapsed bars."
string ttContinue = "Minimum 0-100 quality score required before the active lifecycle is classified as a constructive continue-review state."
string ttVol = "ATR baseline used to detect volatility decay after a setup has triggered."
string ttBox = "Displays the active setup lifecycle window as a forward box that grows to contain price, with a single status badge centered inside it."
string ttRails = "Shows the trigger reference, progress target reference, and invalidation rail for the active lifecycle."
string ttRailLabels = "Shows compact right-side labels for entry, target, and invalidation rails. Disabled by default for cleaner publication screenshots."
string ttTrendBasis = "Shows the fast and slow EMA references used by the lifecycle trend filter."
string ttLabels = "Displays setup, checkpoint, continue, time-risk, expired, and invalidated labels on the chart."
string ttBoxText = "Controls the lifecycle status badge inside the box. Compact is the clean publication preset; Detailed adds a time-risk line; Hidden removes the badge."
string ttLabelMode = "Focus keeps only major state labels. Balanced adds one late-cycle checkpoint. Full keeps more checkpoint context while still respecting cooldown and max label limits."
string ttCooldown = "Minimum bars between non-critical labels. Lower values increase label density; higher values reduce clutter."
string ttMaxLabels = "Maximum event labels kept on the chart. Older labels are removed first to preserve performance and readability."
string ttObjects = "Maximum historical lifecycle boxes and rail sets retained on the chart. The publication default keeps this at one so the active setup stays crisp; lifecycle history remains visible through event labels."
string ttFont = "Controls the size of all Time Stop Planner labels, including the lifecycle status badge and event labels."
string ttOffset = "ATR-based vertical offset used to keep labels away from candle bodies."
string ttSolidLabels = "Uses solid dark label boxes for the lifecycle status badge and rail labels. This avoids pale text inside transparent boxes on light chart backgrounds."
string ttSmartWidth = "Automatically keeps lifecycle boxes tighter on weekly and monthly charts so publication screenshots stay balanced."
string ttPanel = "Shows or hides the AG Pro summary panel. The panel is visible by default."
string ttProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across all completed lifecycles on the current symbol and timeframe. These are historical outcome rates, not predictions."
string ttReactBars = "Number of bars after a lifecycle arms used to detect an immediate favorable reaction. Lower values require a faster initial push to count as a React."
string ttReactProg = "Minimum progress toward the target, within the reaction window, required to count a lifecycle as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupDetection = "Detection"
string enginePreset = input.string("Balanced Lifecycle", "Engine Preset", options = ["Balanced Lifecycle", "Cleaner Swing", "Active Intraday", "Custom"], group = groupDetection, tooltip = ttPreset)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = groupDetection, tooltip = ttSensitivity)
int detectionLookback = input.int(18, "Structure Lookback", minval = 8, maxval = 80, group = groupDetection, tooltip = ttLookback)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 80, group = groupDetection, tooltip = ttAtr)
int fastTrendLength = input.int(21, "Fast Trend EMA", minval = 5, maxval = 100, group = groupDetection, tooltip = ttFast)
int slowTrendLength = input.int(55, "Slow Trend EMA", minval = 10, maxval = 200, group = groupDetection, tooltip = ttSlow)
bool useTrendFilter = input.bool(true, "Use Trend Filter", group = groupDetection, tooltip = ttTrendFilter)
float minBodyAtr = input.float(0.45, "Minimum Trigger Body ATR", minval = 0.10, maxval = 2.00, step = 0.05, group = groupDetection, tooltip = ttBody)
float minCloseLocation = input.float(0.62, "Minimum Close Location", minval = 0.50, maxval = 0.90, step = 0.01, group = groupDetection, tooltip = ttCloseLocation)

string groupLifecycle = "Lifecycle Logic"
int maxLifecycleBars = input.int(28, "Lifecycle Window Bars", minval = 8, maxval = 120, group = groupLifecycle, tooltip = ttWindow)
int lifecycleCooldownBars = input.int(12, "Lifecycle Cooldown Bars", minval = 0, maxval = 80, group = groupLifecycle, tooltip = ttLifecycleCooldown)
float minimumProgressPct = input.float(38.0, "Minimum Progress %", minval = 10.0, maxval = 85.0, step = 1.0, group = groupLifecycle, tooltip = ttProgress)
float targetAtrMult = input.float(2.20, "Progress Target ATR", minval = 0.60, maxval = 6.00, step = 0.10, group = groupLifecycle, tooltip = ttTarget)
float invalidationAtrMult = input.float(1.15, "Invalidation Buffer ATR", minval = 0.25, maxval = 4.00, step = 0.05, group = groupLifecycle, tooltip = ttInvalid)
float timeRiskThreshold = input.float(58.0, "Time Risk Threshold", minval = 25.0, maxval = 90.0, step = 1.0, group = groupLifecycle, tooltip = ttTimeRisk)
int minimumContinueScore = input.int(62, "Continue Review Score", minval = 30, maxval = 95, group = groupLifecycle, tooltip = ttContinue)
int volatilityLookback = input.int(34, "Volatility Baseline", minval = 10, maxval = 120, group = groupLifecycle, tooltip = ttVol)

string groupVisuals = "Visuals"
bool showLifecycleBox = input.bool(true, "Show Lifecycle Box", group = groupVisuals, tooltip = ttBox)
bool showRails = input.bool(true, "Show Entry / Target / Invalidation Rails", group = groupVisuals, tooltip = ttRails)
bool showRailLabels = input.bool(false, "Show Rail Labels", group = groupVisuals, tooltip = ttRailLabels)
bool showTrendBasis = input.bool(false, "Show Trend Basis", group = groupVisuals, tooltip = ttTrendBasis)
bool showLabels = input.bool(true, "Show Event Labels", group = groupVisuals, tooltip = ttLabels)
string boxTextMode = input.string("Compact", "Status Badge Mode", options = ["Compact", "Detailed", "Hidden"], group = groupVisuals, tooltip = ttBoxText)
string labelMode = input.string("Focus", "Label Mode", options = ["Focus", "Balanced", "Full"], group = groupVisuals, tooltip = ttLabelMode)
int labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 0, maxval = 60, group = groupVisuals, tooltip = ttCooldown)
int maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 3, maxval = 40, group = groupVisuals, tooltip = ttMaxLabels)
int maxVisibleObjects = input.int(1, "Max Visible Lifecycle Objects", minval = 1, maxval = 20, group = groupVisuals, tooltip = ttObjects)
string labelSizeInput = input.string("Large", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisuals, tooltip = ttFont)
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisuals, tooltip = ttOffset)
bool useSolidZoneLabels = input.bool(true, "Use Solid Zone Labels", group = groupVisuals, tooltip = ttSolidLabels)
bool smartLifecycleWidth = input.bool(true, "Smart Higher-Timeframe Width", group = groupVisuals, tooltip = ttSmartWidth)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Selects the panel position on the chart.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Controls the panel color theme while keeping the standard AG Pro blue header row.")
string panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls the font size used in the AG Pro panel.")

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttProof)
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 30, group = groupProof, tooltip = ttReactBars)
float reactProgressPct = input.float(20.0, "Reaction Progress %", minval = 5.0, maxval = 60.0, step = 1.0, group = groupProof, tooltip = ttReactProg)

string groupAlerts = "Alerts"
bool alertLifecycleStart = input.bool(true, "Alert on New Lifecycle", group = groupAlerts, tooltip = "Enables alerts when a new time-stop lifecycle is detected.")
bool alertLifecycleStates = input.bool(true, "Alert on Lifecycle State Changes", group = groupAlerts, tooltip = "Enables alerts for continue, time-risk, expired, and invalidated lifecycle states.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_titlecase(string s) =>
    switch s
        "ARMED" => "Armed"
        "ACTIVE" => "Active"
        "CONTINUE" => "Continue"
        "TIME RISK" => "Time Risk"
        "EXPIRED" => "Expired"
        "INVALIDATED" => "Invalidated"
        "WAITING" => "Waiting"
        => s

f_score_color(float value) =>
    value >= 70 ? bullColor : value >= 45 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 25 ? bullColor : value <= 50 ? neutralColor : bearColor

f_state_label_color(string state) =>
    switch state
        "CONTINUE" => color.rgb(13, 148, 136)
        "TIME RISK" => color.rgb(180, 83, 9)
        "EXPIRED" => color.rgb(180, 83, 9)
        "INVALIDATED" => color.rgb(185, 28, 28)
        "ACTIVE" => color.rgb(79, 70, 229)
        "ARMED" => color.rgb(79, 70, 229)
        => panelBorder

f_status_text(string mode, string state, int score, float progress, int bars, int maxBars, int timeRisk) =>
    string line1 = f_titlecase(state) + " | Q" + str.tostring(score)
    string line2 = "Prog " + f_pct(progress) + " | " + str.tostring(bars) + "/" + str.tostring(maxBars)
    switch mode
        "Hidden" => ""
        "Detailed" => line1 + "\n" + line2 + " bars\nRisk " + str.tostring(timeRisk) + "/100"
        => line1 + "\n" + line2

f_theme_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(20, 31, 52) : panelBg)

f_theme_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_theme_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_theme_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_best_view_text() =>
    timeframe.isintraday ? "15m / 1H / 4H" : timeframe.isdaily ? "Daily chart" : "1H / 4H"

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Presets
// -------------------------------------------------
bool cleanerPreset = enginePreset == "Cleaner Swing"
bool activePreset = enginePreset == "Active Intraday"
int usedLabelCooldown = cleanerPreset ? math.max(labelCooldownBars, 18) : activePreset ? math.min(labelCooldownBars, 8) : labelCooldownBars
int usedMaxLabels = cleanerPreset ? math.min(maxVisibleLabels, 4) : activePreset ? math.min(maxVisibleLabels, 7) : math.min(maxVisibleLabels, 6)
int usedLifecycleBarsRaw = cleanerPreset ? math.max(maxLifecycleBars, 32) : activePreset ? math.max(maxLifecycleBars - 4, 8) : maxLifecycleBars
int usedLifecycleBars = smartLifecycleWidth and (timeframe.isweekly or timeframe.ismonthly) ? math.min(usedLifecycleBarsRaw, 22) : usedLifecycleBarsRaw
int usedLifecycleCooldown = cleanerPreset ? math.max(lifecycleCooldownBars, 18) : activePreset ? math.min(lifecycleCooldownBars, 6) : lifecycleCooldownBars
float usedTimeRiskThreshold = cleanerPreset ? math.max(timeRiskThreshold, 62.0) : activePreset ? math.max(timeRiskThreshold - 5.0, 25.0) : timeRiskThreshold
int usedMinimumContinueScore = cleanerPreset ? math.max(minimumContinueScore, 66) : activePreset ? math.max(minimumContinueScore - 4, 30) : minimumContinueScore
int usedReactBars = math.min(reactBars, usedLifecycleBars)

// -------------------------------------------------
// Storage
// -------------------------------------------------
labelTextSize = f_size(labelSizeInput)
panelTextSize = f_size(panelSizeInput)

var array<label> eventLabels = array.new_label()
var array<box> lifecycleBoxes = array.new_box()
var array<line> lifecycleLines = array.new_line()
var array<label> railLabels = array.new_label()
var array<label> lifecycleBoxLabels = array.new_label()

f_track_label(label item, int limit) =>
    array.push(eventLabels, item)
    while array.size(eventLabels) > limit
        label oldItem = array.shift(eventLabels)
        label.delete(oldItem)

f_track_box(box item, int limit) =>
    array.push(lifecycleBoxes, item)
    while array.size(lifecycleBoxes) > limit
        box oldItem = array.shift(lifecycleBoxes)
        box.delete(oldItem)

f_track_line(line item, int limit) =>
    array.push(lifecycleLines, item)
    while array.size(lifecycleLines) > limit * 3
        line oldItem = array.shift(lifecycleLines)
        line.delete(oldItem)

f_track_rail_label(label item, int limit) =>
    array.push(railLabels, item)
    while array.size(railLabels) > limit * 3
        label oldItem = array.shift(railLabels)
        label.delete(oldItem)

f_track_box_label(label item, int limit) =>
    array.push(lifecycleBoxLabels, item)
    while array.size(lifecycleBoxLabels) > limit
        label oldItem = array.shift(lifecycleBoxLabels)
        label.delete(oldItem)

f_event_label(float y, string textValue, color bgColor, bool abovePrice) =>
    label.new(bar_index, y, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = abovePrice ? label.style_label_down : label.style_label_up, color = bgColor, textcolor = headerText, size = labelTextSize, textalign = text.align_center)

f_panel_row(table panelId, int row, string name, string value, color valueColor, color bg, color labelCol) =>
    table.cell(panelId, 0, row, name, bgcolor = bg, text_color = labelCol, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panelId, 1, row, value, bgcolor = bg, text_color = valueColor, text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
float atr = math.max(nz(ta.atr(atrLength), syminfo.mintick), syminfo.mintick)
float atrBase = nz(ta.sma(atr, volatilityLookback), atr)
float fastTrend = ta.ema(close, fastTrendLength)
float slowTrend = ta.ema(close, slowTrendLength)

float priorHigh = ta.highest(high[1], detectionLookback)
float priorLow = ta.lowest(low[1], detectionLookback)
float candleRange = math.max(high - low, syminfo.mintick)
float bodySize = math.abs(close - open)
float bodyAtr = bodySize / atr
float closeLocation = (close - low) / candleRange

float sensitivityFactor = switch sensitivity
    "Aggressive" => 0.82
    "Conservative" => 1.18
    => 1.00

float effectiveBodyAtr = minBodyAtr * sensitivityFactor
bool trendUp = fastTrend > slowTrend and close > fastTrend
bool trendDown = fastTrend < slowTrend and close < fastTrend
bool hasEnoughHistory = bar_index > detectionLookback + slowTrendLength
bool confirmedBar = barstate.isconfirmed

plot(showTrendBasis ? fastTrend : na, "TSP Fast Trend Basis", color = color.new(accentColor, 10), linewidth = 1)
plot(showTrendBasis ? slowTrend : na, "TSP Slow Trend Basis", color = color.new(neutralColor, 20), linewidth = 1)

// -------------------------------------------------
// Lifecycle State
// -------------------------------------------------
var bool setupActive = false
var int setupDir = 0
var int triggerBar = na
var int lastLabelBar = na
var int lastLifecycleEndBar = na
var int lastCheckpoint = 0
var float triggerPrice = na
var float invalidationPrice = na
var float targetPrice = na
var float riskDistance = na
var float targetDistance = na
var float boxTop = na
var float boxBottom = na
var float bestProgressPct = 0.0
var string priorState = "WAITING"
var box activeBox = na
var label activeBoxLabel = na
var line activeEntryLine = na
var line activeTargetLine = na
var line activeInvalidationLine = na
var label activeEntryTag = na
var label activeTargetTag = na
var label activeInvalidationTag = na

// Confirmation-anchored proof state
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool reactedEarly = false

bool cooldownReadyForLifecycle = na(lastLifecycleEndBar) or bar_index - lastLifecycleEndBar >= usedLifecycleCooldown
bool canStartLifecycle = not setupActive and cooldownReadyForLifecycle and hasEnoughHistory and not na(priorHigh) and not na(priorLow)
bool upsideTrigger = canStartLifecycle and close > priorHigh and close > open and bodyAtr >= effectiveBodyAtr and closeLocation >= minCloseLocation and (not useTrendFilter or trendUp)
bool downsideTrigger = canStartLifecycle and close < priorLow and close < open and bodyAtr >= effectiveBodyAtr and closeLocation <= 1.0 - minCloseLocation and (not useTrendFilter or trendDown)
bool newLifecycle = confirmedBar and (upsideTrigger or downsideTrigger)

if newLifecycle
    setupActive := true
    setupDir := upsideTrigger ? 1 : -1
    triggerBar := bar_index
    triggerPrice := close
    invalidationPrice := setupDir == 1 ? low - atr * invalidationAtrMult : high + atr * invalidationAtrMult
    targetPrice := triggerPrice + setupDir * atr * targetAtrMult
    riskDistance := math.max(math.abs(triggerPrice - invalidationPrice), syminfo.mintick)
    targetDistance := math.max(math.abs(targetPrice - triggerPrice), syminfo.mintick)
    float rawTop = math.max(math.max(high, targetPrice), invalidationPrice)
    float rawBottom = math.min(math.min(low, targetPrice), invalidationPrice)
    boxTop := rawTop + atr * 0.20
    boxBottom := rawBottom - atr * 0.20
    lastCheckpoint := 0
    bestProgressPct := 0.0
    reactedEarly := false
    priorState := "ARMED"

    if showLifecycleBox
        activeBox := box.new(left = triggerBar, top = boxTop, right = triggerBar + usedLifecycleBars, bottom = boxBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 93), border_color = color.new(accentColor, 42), border_width = 1)
        f_track_box(activeBox, maxVisibleObjects)
        if boxTextMode != "Hidden"
            int labelX = triggerBar + int(math.round(usedLifecycleBars * 0.5))
            float labelY = (boxTop + boxBottom) / 2.0
            string initialStatusText = f_status_text(boxTextMode, "ARMED", 0, 0.0, 0, usedLifecycleBars, 0)
            activeBoxLabel := label.new(labelX, labelY, initialStatusText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(useSolidZoneLabels ? f_state_label_color("ARMED") : accentColor, useSolidZoneLabels ? 0 : 8), textcolor = headerText, size = labelTextSize, textalign = text.align_center)
            f_track_box_label(activeBoxLabel, maxVisibleObjects)

    if showRails
        activeEntryLine := line.new(triggerBar, triggerPrice, triggerBar + usedLifecycleBars, triggerPrice, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 1)
        activeTargetLine := line.new(triggerBar, targetPrice, triggerBar + usedLifecycleBars, targetPrice, xloc = xloc.bar_index, color = color.new(bullColor, 12), style = line.style_dashed, width = 1)
        activeInvalidationLine := line.new(triggerBar, invalidationPrice, triggerBar + usedLifecycleBars, invalidationPrice, xloc = xloc.bar_index, color = color.new(dangerColor, 10), style = line.style_solid, width = 1)
        f_track_line(activeEntryLine, maxVisibleObjects)
        f_track_line(activeTargetLine, maxVisibleObjects)
        f_track_line(activeInvalidationLine, maxVisibleObjects)
        if showRailLabels
            int entryRailX = triggerBar + usedLifecycleBars
            int targetRailX = entryRailX + 2
            int invalidationRailX = entryRailX + 4
            activeEntryTag := label.new(entryRailX, triggerPrice, "Entry\n" + f_price(triggerPrice), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = labelTextSize)
            activeTargetTag := label.new(targetRailX, targetPrice, "Target\n" + f_price(targetPrice), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 0), textcolor = headerText, size = labelTextSize)
            activeInvalidationTag := label.new(invalidationRailX, invalidationPrice, "Invalidation\n" + f_price(invalidationPrice), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = headerText, size = labelTextSize)
            f_track_rail_label(activeEntryTag, maxVisibleObjects)
            f_track_rail_label(activeTargetTag, maxVisibleObjects)
            f_track_rail_label(activeInvalidationTag, maxVisibleObjects)

    if showLabels
        float eventY = setupDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
        label eventLabel = f_event_label(eventY, "Armed\n" + (setupDir == 1 ? "Up" : "Down"), setupDir == 1 ? bullColor : bearColor, setupDir == 1)
        f_track_label(eventLabel, usedMaxLabels)
        lastLabelBar := bar_index

// -------------------------------------------------
// Active Lifecycle Scoring
// -------------------------------------------------
int barsActive = setupActive and not na(triggerBar) ? bar_index - triggerBar : 0
float directionalTravel = setupActive ? (setupDir == 1 ? high - triggerPrice : triggerPrice - low) : 0.0
float closeTravel = setupActive ? (setupDir == 1 ? close - triggerPrice : triggerPrice - close) : 0.0
float barProgressPct = setupActive ? f_clamp(directionalTravel / targetDistance * 100.0, 0.0, 100.0) : 0.0
if setupActive
    bestProgressPct := math.max(bestProgressPct, barProgressPct)
float progressPct = setupActive ? bestProgressPct : 0.0
float closeProgressPct = setupActive ? f_clamp(closeTravel / targetDistance * 100.0, 0.0, 100.0) : 0.0
float elapsedPct = setupActive ? f_clamp(barsActive / math.max(usedLifecycleBars, 1) * 100.0, 0.0, 140.0) : 0.0
float expectedProgress = setupActive ? f_clamp(elapsedPct, 0.0, 100.0) : 0.0
float progressLag = setupActive ? math.max(expectedProgress - progressPct, 0.0) : 0.0
float bodyEfficiency = setupActive ? f_clamp(bodyAtr / math.max(effectiveBodyAtr, 0.10) * 55.0, 0.0, 100.0) : 0.0
float volatilityRatio = setupActive ? atr / math.max(atrBase, syminfo.mintick) : 1.0
float volatilityScore = setupActive ? f_clamp(volatilityRatio * 82.0, 0.0, 100.0) : 0.0
float distanceToInvalidation = setupActive ? (setupDir == 1 ? close - invalidationPrice : invalidationPrice - close) : 0.0
float invalidationScore = setupActive ? f_clamp(distanceToInvalidation / riskDistance * 100.0, 0.0, 100.0) : 0.0
float timeBalanceScore = setupActive ? f_clamp(100.0 - progressLag * 1.35, 0.0, 100.0) : 0.0
float followThroughScore = setupActive ? f_clamp(closeProgressPct * 0.70 + bodyEfficiency * 0.30, 0.0, 100.0) : 0.0
float qualityRaw = setupActive ? progressPct * 0.34 + timeBalanceScore * 0.24 + followThroughScore * 0.18 + volatilityScore * 0.10 + invalidationScore * 0.14 : 0.0
int qualityScore = int(math.round(f_clamp(qualityRaw, 0.0, 100.0)))
float timeRiskRaw = setupActive ? f_clamp(progressLag * 1.10 + elapsedPct * 0.28 + (volatilityRatio < 0.82 ? 14.0 : 0.0) + (invalidationScore < 30.0 ? 14.0 : 0.0), 0.0, 100.0) : 0.0
int timeRiskScore = int(math.round(timeRiskRaw))

// Early reaction detection for the proof layer
if setupActive and not reactedEarly and barsActive >= 1 and barsActive <= usedReactBars and progressPct >= reactProgressPct
    reactedEarly := true

bool invalidatedNow = confirmedBar and setupActive and (setupDir == 1 ? close < invalidationPrice : close > invalidationPrice)
bool targetTouchedNow = confirmedBar and setupActive and barsActive > 0 and barProgressPct >= 100.0
bool ambiguousOutcomeNow = invalidatedNow and targetTouchedNow
bool targetReachedNow = targetTouchedNow and not invalidatedNow
bool windowCompleteNow = confirmedBar and setupActive and barsActive >= usedLifecycleBars and progressPct >= minimumProgressPct and not invalidatedNow
bool expiredNow = confirmedBar and setupActive and barsActive >= usedLifecycleBars and progressPct < minimumProgressPct and not invalidatedNow
bool continueNow = setupActive and progressPct >= minimumProgressPct and qualityScore >= usedMinimumContinueScore and not invalidatedNow and not expiredNow
bool timeRiskNow = setupActive and barsActive < usedLifecycleBars and timeRiskScore >= usedTimeRiskThreshold and not continueNow and not invalidatedNow and not expiredNow
bool closeLifecycleNow = confirmedBar and (invalidatedNow or expiredNow or targetReachedNow or windowCompleteNow)

string currentState = setupActive ? invalidatedNow ? "INVALIDATED" : expiredNow ? "EXPIRED" : timeRiskNow ? "TIME RISK" : continueNow ? "CONTINUE" : "ACTIVE" : "WAITING"
string actionText = setupActive ? currentState == "INVALIDATED" ? "Invalidated - Reset" : currentState == "EXPIRED" ? "Time Stop - Reassess" : currentState == "TIME RISK" ? "Reassess Progress" : currentState == "CONTINUE" ? "On Track" : "Monitor Lifecycle" : "Wait For Trigger"
color stateColor = currentState == "CONTINUE" ? bullColor : (currentState == "TIME RISK" or currentState == "EXPIRED") ? neutralColor : currentState == "INVALIDATED" ? dangerColor : accentColor
color stateLabelColor = f_state_label_color(currentState)
color lifecycleBg = currentState == "CONTINUE" ? color.new(bullColor, 92) : currentState == "TIME RISK" ? color.new(neutralColor, 91) : currentState == "EXPIRED" ? color.new(neutralColor, 94) : currentState == "INVALIDATED" ? color.new(bearColor, 92) : color.new(accentColor, 92)
bool stateChanged = confirmedBar and setupActive and currentState != priorState
bool timeRiskEvent = stateChanged and currentState == "TIME RISK"
bool continueEvent = stateChanged and currentState == "CONTINUE"
bool expiredEvent = stateChanged and currentState == "EXPIRED"
bool invalidatedEvent = stateChanged and currentState == "INVALIDATED"

if setupActive and showLifecycleBox and not na(activeBox)
    boxTop := math.max(boxTop, high + atr * 0.20)
    boxBottom := math.min(boxBottom, low - atr * 0.20)
    box.set_top(activeBox, boxTop)
    box.set_bottom(activeBox, boxBottom)
    box.set_bgcolor(activeBox, lifecycleBg)
    box.set_border_color(activeBox, color.new(stateColor, currentState == "CONTINUE" ? 18 : 38))
    box.set_border_width(activeBox, currentState == "CONTINUE" ? 2 : 1)
    if boxTextMode != "Hidden"
        int labelX = triggerBar + int(math.round(usedLifecycleBars * 0.5))
        float labelY = (boxTop + boxBottom) / 2.0
        string statusText = f_status_text(boxTextMode, currentState, qualityScore, progressPct, barsActive, usedLifecycleBars, timeRiskScore)
        if na(activeBoxLabel)
            activeBoxLabel := label.new(labelX, labelY, statusText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(useSolidZoneLabels ? stateLabelColor : stateColor, useSolidZoneLabels ? 0 : 8), textcolor = headerText, size = labelTextSize, textalign = text.align_center)
            f_track_box_label(activeBoxLabel, maxVisibleObjects)
        else
            label.set_x(activeBoxLabel, labelX)
            label.set_y(activeBoxLabel, labelY)
            label.set_text(activeBoxLabel, statusText)
            label.set_style(activeBoxLabel, label.style_label_center)
            label.set_color(activeBoxLabel, color.new(useSolidZoneLabels ? stateLabelColor : stateColor, useSolidZoneLabels ? 0 : 8))
            label.set_textcolor(activeBoxLabel, headerText)
            label.set_size(activeBoxLabel, labelTextSize)
            label.set_textalign(activeBoxLabel, text.align_center)
    else
        f_delete_label(activeBoxLabel)
        activeBoxLabel := na

if setupActive and showRails
    if not na(activeEntryLine)
        line.set_color(activeEntryLine, color.new(accentColor, (currentState == "INVALIDATED" or currentState == "EXPIRED") ? 55 : 0))
    if not na(activeTargetLine)
        line.set_color(activeTargetLine, color.new(bullColor, currentState == "CONTINUE" ? 0 : 20))
    if not na(activeInvalidationLine)
        line.set_color(activeInvalidationLine, color.new(dangerColor, currentState == "INVALIDATED" ? 0 : 15))
    if showRailLabels
        int entryRailX = triggerBar + usedLifecycleBars
        int targetRailX = entryRailX + 2
        int invalidationRailX = entryRailX + 4
        if not na(activeEntryTag)
            label.set_x(activeEntryTag, entryRailX)
            label.set_text(activeEntryTag, "Entry\n" + f_price(triggerPrice))
            label.set_color(activeEntryTag, color.new(accentColor, 0))
            label.set_size(activeEntryTag, labelTextSize)
            label.set_textcolor(activeEntryTag, headerText)
        if not na(activeTargetTag)
            label.set_x(activeTargetTag, targetRailX)
            label.set_text(activeTargetTag, "Target\n" + f_price(targetPrice))
            label.set_color(activeTargetTag, color.new(bullColor, 0))
            label.set_size(activeTargetTag, labelTextSize)
            label.set_textcolor(activeTargetTag, headerText)
        if not na(activeInvalidationTag)
            label.set_x(activeInvalidationTag, invalidationRailX)
            label.set_text(activeInvalidationTag, "Invalidation\n" + f_price(invalidationPrice))
            label.set_color(activeInvalidationTag, color.new(dangerColor, 0))
            label.set_size(activeInvalidationTag, labelTextSize)
            label.set_textcolor(activeInvalidationTag, headerText)
else if setupActive and not showRails
    f_delete_label(activeEntryTag)
    f_delete_label(activeTargetTag)
    f_delete_label(activeInvalidationTag)
    activeEntryTag := na
    activeTargetTag := na
    activeInvalidationTag := na

bool canAddNonCriticalLabel = na(lastLabelBar) or bar_index - lastLabelBar >= usedLabelCooldown
int checkpointOne = int(math.round(usedLifecycleBars * 0.50))
int checkpointTwo = int(math.round(usedLifecycleBars * 0.75))
int checkpointThree = int(math.round(usedLifecycleBars * 0.90))
int checkpointNow = setupActive and barsActive >= checkpointThree ? 3 : setupActive and barsActive >= checkpointTwo ? 2 : setupActive and barsActive >= checkpointOne ? 1 : 0
bool checkpointAllowedByMode = labelMode == "Full" or (labelMode == "Balanced" and checkpointNow >= 2)
bool showCheckpointLabels = showLabels and checkpointAllowedByMode and checkpointNow > lastCheckpoint and canAddNonCriticalLabel and not invalidatedNow and not expiredNow and not continueNow

if showCheckpointLabels
    float checkpointY = setupDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    string checkpointText = "T+" + str.tostring(checkpointNow) + "\n" + f_pct(progressPct)
    label checkpointLabel = f_event_label(checkpointY, checkpointText, color.new(accentColor, 0), setupDir == 1)
    f_track_label(checkpointLabel, usedMaxLabels)
    lastLabelBar := bar_index
    lastCheckpoint := checkpointNow

bool allowStateLabel = invalidatedEvent or expiredEvent or canAddNonCriticalLabel

if showLabels and allowStateLabel and (timeRiskEvent or continueEvent or expiredEvent or invalidatedEvent)
    bool labelAbove = invalidatedEvent ? setupDir == -1 : setupDir == 1
    float stateY = labelAbove ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    string labelText = f_titlecase(currentState) + "\nQ " + str.tostring(qualityScore)
    label stateLabel = f_event_label(stateY, labelText, stateLabelColor, labelAbove)
    f_track_label(stateLabel, usedMaxLabels)
    lastLabelBar := bar_index

if confirmedBar and setupActive
    priorState := currentState

// -------------------------------------------------
// Panel
// -------------------------------------------------
bool panelIsLight = panelTheme == "Light"
color panelBgUsed = f_theme_bg(panelIsLight, false)
color panelAltBg = f_theme_bg(panelIsLight, true)
color panelFrame = f_theme_border(panelIsLight)
color panelLabelUsed = f_theme_label(panelIsLight)
color panelValueUsed = f_theme_value(panelIsLight)
string bestViewText = f_best_view_text()

// Proof rates (confirmation-anchored, cumulative over completed lifecycles)
float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_score_color(followRate) : panelValueUsed
color holdCol = proofTotal > 0 ? f_score_color(holdRate) : panelValueUsed
color reactCol = proofTotal > 0 ? f_score_color(reactRate) : panelValueUsed
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : panelValueUsed
string sampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"

int panelRowCount = showProof ? 13 : 8
var table panel = table.new(position.top_right, 2, panelRowCount, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocation))
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    if showPanel
        bool waiting = currentState == "WAITING"
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Time Stop Planner", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize, text_halign = text.align_center)
        string barsText = waiting ? "Waiting" : str.tostring(barsActive) + " / " + str.tostring(usedLifecycleBars)
        string qualityText = waiting ? "-" : str.tostring(qualityScore) + " / 100"
        string progressText = waiting ? "-" : f_pct(progressPct)
        string riskText = waiting ? "Neutral" : str.tostring(timeRiskScore) + " / 100"
        string invalidationText = waiting ? "n/a" : f_price(invalidationPrice)
        f_panel_row(panel, 1, "Bars Active", barsText, waiting ? panelValueUsed : stateColor, panelBgUsed, panelLabelUsed)
        f_panel_row(panel, 2, "Quality", qualityText, waiting ? panelValueUsed : f_score_color(qualityScore), panelAltBg, panelLabelUsed)
        f_panel_row(panel, 3, "Progress", progressText, waiting ? panelValueUsed : stateColor, panelBgUsed, panelLabelUsed)
        f_panel_row(panel, 4, "Time Risk", riskText, (currentState == "TIME RISK" or currentState == "EXPIRED") ? neutralColor : panelValueUsed, panelAltBg, panelLabelUsed)
        f_panel_row(panel, 5, "Invalidation", invalidationText, currentState == "INVALIDATED" ? dangerColor : panelValueUsed, panelBgUsed, panelLabelUsed)
        f_panel_row(panel, 6, "Next Action", actionText, stateColor, panelAltBg, panelLabelUsed)
        if showProof
            table.cell(panel, 0, 7, "Proof @ Confirm", bgcolor = panelBgUsed, text_color = accentColor, text_size = panelTextSize, text_halign = text.align_left)
            table.cell(panel, 1, 7, sampleText, bgcolor = panelBgUsed, text_color = panelLabelUsed, text_size = panelTextSize, text_halign = text.align_right)
            f_panel_row(panel, 8, "Follow Rate", followText, followCol, panelAltBg, panelLabelUsed)
            f_panel_row(panel, 9, "Hold Rate", holdText, holdCol, panelBgUsed, panelLabelUsed)
            f_panel_row(panel, 10, "React Rate", reactText, reactCol, panelAltBg, panelLabelUsed)
            f_panel_row(panel, 11, "Flip Rate", flipText, flipCol, panelBgUsed, panelLabelUsed)
            f_panel_row(panel, 12, "Best View", bestViewText, accentColor, panelAltBg, panelLabelUsed)
        else
            f_panel_row(panel, 7, "Best View", bestViewText, accentColor, panelBgUsed, panelLabelUsed)

// -------------------------------------------------
// Lifecycle Closeout
// -------------------------------------------------
if closeLifecycleNow
    if ambiguousOutcomeNow
        proofAmbiguous := proofAmbiguous + 1
    else
        proofTotal := proofTotal + 1
        if targetReachedNow
            proofFollow := proofFollow + 1
        if not invalidatedNow
            proofHold := proofHold + 1
        if reactedEarly
            proofReact := proofReact + 1
        if invalidatedNow
            proofFlip := proofFlip + 1
    reactedEarly := false
    bestProgressPct := 0.0
    lastLifecycleEndBar := bar_index
    setupActive := false
    setupDir := 0
    triggerBar := na
    triggerPrice := na
    invalidationPrice := na
    targetPrice := na
    riskDistance := na
    targetDistance := na
    activeBoxLabel := na
    activeEntryTag := na
    activeTargetTag := na
    activeInvalidationTag := na

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertLifecycleStart and newLifecycle, "New Time Stop Lifecycle", "Time Stop Planner: a new setup lifecycle window has been detected.")
alertcondition(alertLifecycleStates and continueEvent, "Continue Review State", "Time Stop Planner: the active lifecycle has reached a constructive continue-review state.")
alertcondition(alertLifecycleStates and timeRiskEvent, "Time Risk State", "Time Stop Planner: elapsed time is high relative to progress. Review the setup lifecycle.")
alertcondition(alertLifecycleStates and expiredEvent, "Lifecycle Expired", "Time Stop Planner: the active lifecycle reached its time-stop boundary without enough progress.")
alertcondition(alertLifecycleStates and invalidatedEvent, "Lifecycle Invalidated", "Time Stop Planner: price closed beyond the lifecycle invalidation rail.")

plot(qualityScore, "TSP Quality Score", display = display.none)
plot(timeRiskScore, "TSP Time Risk Score", display = display.none)
plot(progressPct, "TSP Progress Percent", display = display.none)
plot(followRate, "TSP Follow Rate", display = display.none)
plot(holdRate, "TSP Hold Rate", display = display.none)
plot(reactRate, "TSP React Rate", display = display.none)
plot(flipRate, "TSP Flip Rate", display = display.none)
plot(proofAmbiguous, "TSP Ambiguous Proof Count", display = display.none)
````
