# Trade Management Map [AGPro Series]

- url: https://www.tradingview.com/script/uPPCeW03-Trade-Management-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;aa9ef31e65464ec881617ce8fec6abcf
- version: 4.0

## Description

Trade Management Map [AGPro Series]

🧠 Core Idea

What is the current management state of the active move: hold context, review protection, watch target pressure, or reset the plan?


📌 Overview / What it does

Trade Management Map [AGPro Series] is an active move management overlay designed to help traders review what is happening after a move becomes active.

Instead of printing generic buy or sell signals, the script builds a management corridor between an invalidation reference and a target edge, then scores the active move using progress quality, pullback pressure, target room, trend defense, and volatility state.

The script produces management rails, compact state labels, optional management corridor visuals, alerts, and a clean AGPro panel. It does not predict price movement, automate execution, or guarantee that a move will continue.


🎯 Purpose & Design Philosophy

This script was built for traders who already understand that the entry is only one part of the process.

Many traders can identify a move, but struggle with the next question: should the setup still be monitored, is protection review becoming relevant, is target room getting thin, or has the original context failed?

Trade Management Map fills that gap by acting as a public-free active management layer. It supports a disciplined review mindset without becoming a full trading suite, target ladder, stop-loss optimizer, or automated strategy.


⚡ Why This Script Is Different

Most tools focus on entries, exits, stop-loss levels, or take-profit ladders as separate features.

This script does NOT try to replace a full trade plan, position sizing model, stop optimizer, or profit-taking system.

Instead, it maps the current management condition of an already active move. The main output is a 0-100 management quality score and a clear attention state, not a trade command.


⚙️ Methodology

1. Context Detection
The script detects a fresh active move using recent structure, trend context, and optional volume confirmation.

2. Reference Mapping
When a new map starts, it defines an anchor price, invalidation reference, protection-review rail, and target edge.

3. Reaction Evaluation
The active move is continuously evaluated through Current R, best excursion, pullback pressure, target room, trend defense, and volatility stability.

4. Visual Output
The result is shown as a management corridor, compact rails, state labels, alert conditions, and a clean AGPro panel.


🗺️ How to Read the Chart

Management Corridor = an optional active review area between invalidation and target edge.

Centered Corridor Label = the current management state and 0-100 score when the optional corridor is enabled.

Rails = anchor, invalidation, protection review, and target edge references.

Labels = compact state changes such as ACTIVE, HOLD CONTEXT, PROTECT REVIEW, CAUTION REVIEW, TARGET REVIEW, or INVALIDATED.

Colors = AGPro green for healthy context, indigo for protection review, amber for caution or target review, and pink for invalidation pressure.

Panel = the simplified management dashboard showing state, Current R, risk shift, target room, and action context.


🚦 Signals & States

• ACTIVE → a new management context has started.

• HOLD CONTEXT → the move still has acceptable progress and defense.

• PROTECT REVIEW → the move has progressed enough to review risk shift context.

• CAUTION REVIEW → pullback pressure or score deterioration requires attention.

• TARGET REVIEW → the move is near the target edge or target room is thin.

• INVALIDATED → the active invalidation reference was crossed.


🔔 Alerts Logic

Alerts trigger when a new management map starts or when the state changes into HOLD CONTEXT, PROTECT REVIEW, CAUTION REVIEW, TARGET REVIEW, or INVALIDATED.

These alerts are attention markers only. They are not trade instructions, automated strategy commands, or execution signals.


🧩 Confluence Logic

The strongest management condition appears when several factors align:

Current R progress + controlled pullback pressure + open target room + trend defense + stable volatility.

When these factors stay aligned, the map can remain in HOLD CONTEXT or PROTECT REVIEW. If pullback pressure rises or target room disappears, the state can downgrade.


📊 When to Use

• After a breakout, continuation, or discretionary setup becomes active.

• During an open move where Current R and target room need structure.

• When reviewing whether a move is still healthy or becoming fragile.

• Around target approach zones where target room may be getting thin.

• When comparing whether the current move still deserves attention.


⚠️ When NOT to Use

• Extremely low-liquidity symbols.

• Very noisy micro-timeframes with unstable wicks.

• News-driven volatility spikes.

• Markets where recent structure is too distorted to define invalidation.

• Situations where the user expects automatic entries or exits.


🎛️ Key Inputs

• Management Side → controls Auto, Long Context, or Short Context evaluation.

• Activation Confirmation → controls how strict the active-move start condition should be.

• Activation Lookback → defines the structure window used to start a map.

• Invalidation Lookback → controls the reference used for active invalidation.

• Target Edge R → defines the projected target edge in R units.

• Protection Review R → controls when protection review becomes visible.

• Label and Panel Settings → control visibility, location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is intentionally chart-first.

Management rails and compact labels are the primary default visuals. The optional corridor can be enabled when the user wants a larger management zone, with centered state text inside the zone. Labels are moderated by cooldown and maximum-visible settings.

The AGPro panel uses a single merged blue header row and keeps the decision layer readable without turning the chart into a crowded dashboard.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check Current R and risk shift.

3. Review whether target room remains open.

4. Watch the management corridor and rails.

5. Interpret state changes inside broader market context.


🔍 Interpretation Guidelines

Use the script as a review framework, not a command system.

HOLD CONTEXT means the active move still has structural support.

PROTECT REVIEW means progress has reached a level where risk shift deserves attention.

CAUTION REVIEW means pullback pressure, trend defense, or score quality has weakened.

TARGET REVIEW means the map is approaching its target edge or target room has become limited.


🚫 What This Script Is NOT

This is not a prediction engine.

This is not financial advice.

This is not an auto-trading system.

This is not a guaranteed signal generator.

This is not a full paid trade management suite.


⚠️ Limitations & Transparency

The script is rule-based and depends on the loaded chart data.

Timeframe changes can alter activation points, invalidation references, and target room readings.

Volatility spikes, low-liquidity candles, and distorted structure can reduce the usefulness of the management map.

Outputs should always be interpreted with broader market context and the user's own risk process.


🧠 Market Context Notes

Trade management quality is not only about price moving in the desired direction.

A move can progress while becoming fragile if pullback pressure rises, target room narrows, or trend defense weakens.

This script focuses on that middle layer: the quality of managing an active move after the initial activation.


🧾 Use Case Examples

When price starts a fresh continuation move and the corridor remains supported, HOLD CONTEXT may appear.

When Current R improves but pullback pressure begins rising, PROTECT REVIEW or CAUTION REVIEW can help focus attention.

When price approaches the target edge, TARGET REVIEW highlights that target room may be limited.


🧱 System Philosophy

AGPro tools are designed to turn chart information into structured decision context.

Trade Management Map follows that philosophy by reducing management ambiguity into a readable state, score, and risk map.


🔐 Non-Promise Statement

No script can remove uncertainty.

No state, score, label, rail, or alert guarantees a future market outcome.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, position sizing, risk controls, and execution decisions.

Nothing in this script is financial advice.


📚 Educational Note

This script is designed for educational and analytical review. It helps users think more clearly about active trade management, but final interpretation remains the user's responsibility.

## Source Code

````pine
// -------------------------------------------------
// Trade Management Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Trade Management Map is a chart-first active move management planner that
// evaluates whether a tracked move is healthy, fragile, close to target pressure,
// or drifting toward invalidation. It converts progress quality, pullback pressure,
// target room, trend defense, and volatility state into a 0-100 management score
// with clear review states for discretionary trade-management context.
// -------------------------------------------------

//@version=6
indicator("Trade Management Map [AGPro Series]",
     shorttitle = "AG Pro TMM",
     overlay = true,
     max_labels_count = 220,
     max_boxes_count = 40,
     max_lines_count = 100)

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
color monitorColor  = color.rgb(71, 85, 105)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects how the map decides the active management side. Auto uses trend direction and recent break structure. Manual modes force long-context or short-context management only."
string ttActivation = "Defines how strict a new active move must be before the management map starts tracking it. Stronger modes reduce noise but create fewer maps."
string ttAtrLen = "ATR length used to normalize progress, pullback pressure, label offsets, corridor thickness, and volatility state."
string ttSetupLen = "Lookback used to detect a fresh active move through recent structure. This is not an entry signal; it only starts a management context."
string ttInvalidLen = "Lookback used to locate the active invalidation reference when a new management map starts."
string ttObstacleLen = "Lookback used to estimate the nearest target obstruction or target edge in the active direction."
string ttFastLen = "Fast EMA used for trend-defense scoring. It helps classify whether the active move is still supported."
string ttSlowLen = "Slow EMA used as the main trend baseline for management-state evaluation."
string ttVolLen = "Lookback used to compare current volume against recent participation. If volume data is unavailable, this component becomes neutral."
string ttVolumeMult = "Minimum relative volume used by confirmation modes that require participation. Higher values make activation more selective."
string ttTargetR = "Projected target edge in R units from the activation anchor. The map may also respect a nearer recent obstruction."
string ttProtectR = "Current R level where the map begins highlighting protection review. This is an attention marker, not an instruction."
string ttCautionPullback = "Pullback depth, measured in R from the best excursion, that can push the map into caution review."
string ttMinScore = "Minimum management quality score required for Hold Context. Lower scores can remain in monitor or caution states."
string ttMapCooldown = "Minimum bars between new management maps. Higher values reduce repeated activations during choppy moves."
string ttShowBox = "Shows the active management corridor between invalidation and target edge. The state badge is kept centered as a separate filled label for stronger readability."
string ttShowRails = "Shows compact entry, protection, target, and invalidation rails for the active management map."
string ttShowTags = "Shows right-side tags for the active rail values so the chart can be read without opening the panel."
string ttTagDensity = "Essential keeps the anchor, invalidation, and target references visible while revealing protection review only when it becomes relevant. All keeps every active reference visible."
string ttBoxProjection = "Number of bars the management corridor and rail guides project to the right."
string ttBoxOpacity = "Transparency for the active management corridor. Higher values make the corridor lighter."
string ttShowLabels = "Shows premium state labels for activation, hold context, protection review, caution, target review, and invalidation."
string ttShowContextLabels = "Adds sparse context labels during active management so the chart does not look empty on longer moves."
string ttShowMarkers = "Shows small diamond markers for map starts and caution events. Disabled by default because labels carry the public-release visual story."
string ttLabelCooldown = "Minimum bars between labels. Higher values reduce clutter."
string ttContextSpacing = "Minimum bars between sparse context labels while the same management state remains active."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first for performance."
string ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
string ttShowLabelScore = "Adds the 0-100 management score to labels while keeping the label text compact."
string ttLabelSize = "Font size for chart labels, state badge, and right-side tags. Normal is the recommended publication default."
string ttShowPanel = "Shows or hides the compact AG Pro management panel. It is enabled by default for public readability."
string ttPanelLocation = "Moves the management panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark theme and a clean light theme."
string ttPanelFont = "Font size for the management panel. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Management Engine"
string sideMode = input.string("Auto", "Management Side", options = ["Auto", "Long Context", "Short Context"], group = groupEngine, tooltip = ttSide)
string activationMode = input.string("Close + Trend", "Activation Confirmation", options = ["Close Only", "Close + Trend", "Close + Trend + Volume"], group = groupEngine, tooltip = ttActivation)
int atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
int setupLen = input.int(28, "Activation Lookback", minval = 8, maxval = 250, group = groupEngine, tooltip = ttSetupLen)
int invalidLen = input.int(18, "Invalidation Lookback", minval = 3, maxval = 160, group = groupEngine, tooltip = ttInvalidLen)
int obstacleLen = input.int(72, "Target Obstruction Lookback", minval = 12, maxval = 300, group = groupEngine, tooltip = ttObstacleLen)
int fastLen = input.int(21, "Fast Trend EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFastLen)
int slowLen = input.int(55, "Slow Trend EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlowLen)
int volumeLen = input.int(30, "Volume Baseline", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolLen)
float volumeMult = input.float(1.05, "Relative Volume Filter", minval = 0.10, maxval = 5.00, step = 0.05, group = groupEngine, tooltip = ttVolumeMult)

string groupScoring = "Management Scoring"
float targetR = input.float(2.00, "Target Edge R", minval = 0.50, maxval = 8.00, step = 0.25, group = groupScoring, tooltip = ttTargetR)
float protectReviewR = input.float(0.85, "Protection Review R", minval = 0.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttProtectR)
float cautionPullbackR = input.float(0.70, "Caution Pullback R", minval = 0.10, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = ttCautionPullback)
float holdThreshold = input.float(68.0, "Hold Context Threshold", minval = 35.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttMinScore)
int mapCooldownBars = input.int(22, "Map Cooldown Bars", minval = 1, maxval = 220, group = groupScoring, tooltip = ttMapCooldown)
int holdProofWindow = input.int(14, "Hold Proof Window", minval = 3, maxval = 80, group = groupScoring, tooltip = "After a new map activates, the script waits this many bars (or until invalidation) and checks whether the move followed through in the map direction. Feeds the self-measured Hold Rate.")

string groupVisual = "Map Visuals"
bool showManagementBox = input.bool(true, "Show Management Corridor", group = groupVisual, tooltip = ttShowBox)
bool showManagementRails = input.bool(true, "Show Management Rails", group = groupVisual, tooltip = ttShowRails)
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttShowTags)
string referenceTagDensity = input.string("Essential", "Reference Tag Density", options = ["Essential", "All"], group = groupVisual, tooltip = ttTagDensity)
int boxProjectionBars = input.int(34, "Corridor Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttBoxProjection)
int corridorTransparency = input.int(90, "Corridor Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = ttBoxOpacity)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttShowLabels)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttShowContextLabels)
bool showEventMarkers = input.bool(false, "Show Event Markers", group = groupLabels, tooltip = ttShowMarkers)
int labelCooldownBars = input.int(16, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttLabelCooldown)
int contextSpacingBars = input.int(54, "Context Label Spacing", minval = 12, maxval = 220, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(13, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttShowLabelScore)
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_state_color(int code, int side, string theme) =>
    if theme == "Light"
        switch code
            2 => side == 1 ? bullColor : bearColor
            3 => accentColor
            4 => neutralColor
            5 => accentColor
            6 => dangerColor
            1 => monitorColor
            => panelLabelCol
    else
        switch code
            1 => panelValueCol
            2 => side == 1 ? bullColor : bearColor
            3 => accentColor
            4 => neutralColor
            5 => accentColor
            6 => dangerColor
            => panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_state_text(int code) =>
    switch code
        1 => "Monitor"
        2 => "Hold Context"
        3 => "Protect Review"
        4 => "Caution Review"
        5 => "Target Review"
        6 => "Invalidated"
        => "Standby"

f_state_color(int code, int side) =>
    switch code
        2 => side == 1 ? bullColor : bearColor
        3 => accentColor
        4 => neutralColor
        5 => accentColor
        6 => dangerColor
        1 => monitorColor
        => panelLabelCol

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    bright >= 145.0 ? color.rgb(17, 24, 39) : headerText

f_grade(float score) =>
    score >= 84.0 ? "A" : score >= 72.0 ? "B" : score >= 58.0 ? "C" : score >= 42.0 ? "D" : "E"

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.00")

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_set_tag(label tag, int x, float y, string textValue, color bg, string sizeText) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, textValue)
    label.set_color(tag, color.new(bg, 0))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_size(tag, f_text_size(sizeText))
    label.set_style(tag, label.style_label_left)

f_hide_tag(label tag) =>
    label.set_text(tag, "")
    label.set_style(tag, label.style_none)
    label.set_color(tag, color.new(panelBg, 100))
    label.set_textcolor(tag, color.new(headerText, 100))

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float emaFast = ta.ema(close, fastLen)
float emaSlow = ta.ema(close, slowLen)
float emaSlope = emaSlow - nz(emaSlow[5], emaSlow)
float priorHigh = nz(ta.highest(high, setupLen)[1], high)
float priorLow = nz(ta.lowest(low, setupLen)[1], low)
float obstacleHigh = nz(ta.highest(high[1], obstacleLen), high)
float obstacleLow = nz(ta.lowest(low[1], obstacleLen), low)
float volBase = ta.sma(nz(volume, 0.0), volumeLen)
float longInvalidCandidate = ta.lowest(low, invalidLen)
float shortInvalidCandidate = ta.highest(high, invalidLen)
bool volumeAvailable = not na(volume) and volume > 0.0 and volBase > 0.0
bool volumeOk = not volumeAvailable or volume >= volBase * volumeMult
bool trendLong = emaFast > emaSlow and emaSlope >= -safeAtr * 0.05
bool trendShort = emaFast < emaSlow and emaSlope <= safeAtr * 0.05
int autoDir = trendLong and not trendShort ? 1 : trendShort and not trendLong ? -1 : close >= emaSlow ? 1 : -1
int preferredDir = sideMode == "Long Context" ? 1 : sideMode == "Short Context" ? -1 : autoDir
bool longAllowed = sideMode != "Short Context"
bool shortAllowed = sideMode != "Long Context"
bool longBreak = bar_index > setupLen and longAllowed and close > priorHigh
bool shortBreak = bar_index > setupLen and shortAllowed and close < priorLow
bool longConfirm = activationMode == "Close Only" ? true : activationMode == "Close + Trend" ? trendLong : trendLong and volumeOk
bool shortConfirm = activationMode == "Close Only" ? true : activationMode == "Close + Trend" ? trendShort : trendShort and volumeOk

// -------------------------------------------------
// Active management map state
// -------------------------------------------------
var bool hasMap = false
var bool mapActive = false
var bool mapInvalidated = false
var int activeSide = 0
var int anchorBar = na
var float anchorPrice = na
var float invalidationRef = na
var float targetRef = na
var float riskShiftRef = na
var float activeBest = na

bool canStartMap = not hasMap or not mapActive or bar_index - anchorBar >= mapCooldownBars
bool startLong = canStartMap and longBreak and longConfirm and preferredDir == 1
bool startShort = canStartMap and shortBreak and shortConfirm and preferredDir == -1
bool newMap = barstate.isconfirmed and (startLong or startShort)

if newMap
    activeSide := startLong ? 1 : -1
    anchorBar := bar_index
    anchorPrice := close
    float rawInvalidation = activeSide == 1 ? longInvalidCandidate : shortInvalidCandidate
    float fallbackRisk = safeAtr * 1.05
    invalidationRef := activeSide == 1 ? math.min(rawInvalidation, anchorPrice - fallbackRisk * 0.35) : math.max(rawInvalidation, anchorPrice + fallbackRisk * 0.35)
    float riskUnitOnStart = math.max(math.abs(anchorPrice - invalidationRef), safeAtr * 0.35)
    float projectedTarget = anchorPrice + activeSide * riskUnitOnStart * targetR
    bool hasNearObstacle = activeSide == 1 ? obstacleHigh > anchorPrice and obstacleHigh < projectedTarget : obstacleLow < anchorPrice and obstacleLow > projectedTarget
    targetRef := hasNearObstacle ? (activeSide == 1 ? obstacleHigh : obstacleLow) : projectedTarget
    riskShiftRef := anchorPrice + activeSide * riskUnitOnStart * protectReviewR
    activeBest := close
    hasMap := true
    mapActive := true
    mapInvalidated := false

if hasMap and mapActive
    activeBest := activeSide == 1 ? math.max(nz(activeBest, high), high) : math.min(nz(activeBest, low), low)

float riskUnit = hasMap ? math.max(math.abs(anchorPrice - invalidationRef), safeAtr * 0.35) : na
float currentR = hasMap and riskUnit > 0.0 ? activeSide * (close - anchorPrice) / riskUnit : na
float bestR = hasMap and riskUnit > 0.0 ? activeSide * (activeBest - anchorPrice) / riskUnit : na
float pullbackR = hasMap and riskUnit > 0.0 ? math.max(bestR - currentR, 0.0) : na
float targetRoomR = hasMap and riskUnit > 0.0 ? activeSide * (targetRef - close) / riskUnit : na
bool invalidatedNow = barstate.isconfirmed and hasMap and mapActive and ((activeSide == 1 and close < invalidationRef) or (activeSide == -1 and close > invalidationRef))

if invalidatedNow
    mapActive := false
    mapInvalidated := true

float progressScore = hasMap ? f_clamp(currentR / math.max(targetR, 0.10) * 100.0, 0.0, 100.0) : na
float pullbackScore = hasMap ? f_norm_low_good(pullbackR, 0.10, math.max(cautionPullbackR * 1.35, 0.20)) : na
float targetRoomScore = hasMap ? (targetRoomR <= 0.0 ? 10.0 : f_norm_high_good(targetRoomR, 0.15, math.max(targetR * 0.65, 0.40))) : na
float longDefenseScore = (close >= emaFast ? 42.0 : 20.0) + (emaFast >= emaSlow ? 38.0 : 14.0) + f_norm_high_good(emaSlope / safeAtr, -0.10, 0.18) * 0.20
float shortDefenseScore = (close <= emaFast ? 42.0 : 20.0) + (emaFast <= emaSlow ? 38.0 : 14.0) + f_norm_high_good(-emaSlope / safeAtr, -0.10, 0.18) * 0.20
float trendDefenseScore = hasMap ? (activeSide == 1 ? longDefenseScore : shortDefenseScore) : na
float atrBase = ta.sma(atr, math.max(atrLen * 4, 20))
float atrRatio = atrBase > 0.0 ? atr / atrBase : 1.0
float volatilityScore = f_clamp(f_norm_low_good(math.abs(atrRatio - 1.0), 0.05, 0.75), 0.0, 100.0)
float managementScore = hasMap ? f_clamp(progressScore * 0.28 + pullbackScore * 0.24 + targetRoomScore * 0.18 + trendDefenseScore * 0.20 + volatilityScore * 0.10, 0.0, 100.0) : na

int stateCode = 0
if hasMap
    if mapInvalidated
        stateCode := 6
    else if targetRoomR <= 0.15 or currentR >= targetR * 0.92
        stateCode := 5
    else if pullbackR >= cautionPullbackR or managementScore < 42.0
        stateCode := 4
    else if currentR >= protectReviewR and pullbackR < cautionPullbackR
        stateCode := 3
    else if managementScore >= holdThreshold and currentR > 0.0
        stateCode := 2
    else
        stateCode := 1

string stateText = f_state_text(stateCode)
color stateColor = f_state_color(stateCode, activeSide)
string sideText = activeSide == 1 ? "Long Context" : activeSide == -1 ? "Short Context" : "No Map"
string roomText = not hasMap ? "No map" : targetRoomR <= 0.0 ? "Reached edge" : targetRoomR <= 0.35 ? "Thin room" : targetRoomR <= 0.85 ? "Limited room" : "Open room"
string riskShiftText = not hasMap ? "No map" : currentR < 0.0 ? "Under pressure" : currentR < protectReviewR ? "Pre-protect" : pullbackR >= cautionPullbackR ? "Risk rising" : "Protection review"
string actionText = stateCode == 0 ? "Standby" : stateCode == 1 ? "Monitor" : stateCode == 2 ? "Hold context" : stateCode == 3 ? "Review protection" : stateCode == 4 ? "Caution review" : stateCode == 5 ? "Target review" : "Reset context"

// -------------------------------------------------
// Hold Rate (Proof Pass)
// -------------------------------------------------
// On each new map, the break direction is armed with the map invalidation as a
// reference. The setup resolves as a miss if price closes back through the
// invalidation first, or as a hit when the move has followed through in the map
// direction after the proof window. Timeouts are not counted as losses. This is
// a transparent, self-measured follow-through statistic for activated maps.
var int mhHits = 0
var int mhTotal = 0
var bool mhPending = false
var int mhStart = na
var int mhDir = 0
var float mhEntry = na
var float mhInval = na

if barstate.isconfirmed
    if newMap and not mhPending
        mhPending := true
        mhStart := bar_index
        mhDir := activeSide
        mhEntry := anchorPrice
        mhInval := invalidationRef
    if mhPending and not na(mhStart) and bar_index > mhStart
        bool mhStop = mhDir == 1 ? close < mhInval : close > mhInval
        if mhStop
            mhTotal += 1
            mhPending := false
        else if bar_index - mhStart >= holdProofWindow
            bool mhFollowed = mhDir == 1 ? close > mhEntry : close < mhEntry
            mhTotal += 1
            if mhFollowed
                mhHits += 1
            mhPending := false

float mhRate = mhTotal > 0 ? mhHits / mhTotal * 100.0 : na
string holdRateText = mhTotal > 0 ? str.tostring(int(math.round(mhRate))) + "% (" + str.tostring(mhHits) + "/" + str.tostring(mhTotal) + ")" : "Building"
color holdRateColor = mhTotal == 0 ? neutralColor : mhRate >= 60.0 ? bullColor : mhRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Visual objects
// -------------------------------------------------
int rightEdge = bar_index + boxProjectionBars
float corridorTop = hasMap ? math.max(targetRef, invalidationRef) : na
float corridorBottom = hasMap ? math.min(targetRef, invalidationRef) : na
float badgeY = hasMap ? (corridorTop + corridorBottom) * 0.5 : na
int badgeX = hasMap ? int(math.round((anchorBar + rightEdge) / 2.0)) : bar_index
string badgeText = hasMap ? stateText + "\nScore " + str.tostring(math.round(nz(managementScore, 0.0))) : ""

var box managementBox = na
var label corridorBadge = na

if showManagementBox and hasMap and mapActive
    color boxBg = color.new(stateColor, corridorTransparency)
    color boxBorder = color.new(stateColor, stateCode == 6 ? 20 : 36)
    if na(managementBox)
        managementBox := box.new(left = anchorBar, top = corridorTop, right = rightEdge, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = boxBg, border_color = boxBorder, border_width = 1)
    else
        box.set_left(managementBox, anchorBar)
        box.set_right(managementBox, rightEdge)
        box.set_top(managementBox, corridorTop)
        box.set_bottom(managementBox, corridorBottom)
        box.set_bgcolor(managementBox, boxBg)
        box.set_border_color(managementBox, boxBorder)
    if na(corridorBadge)
        corridorBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 4), textcolor = f_text_on(stateColor), size = f_text_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_xy(corridorBadge, badgeX, badgeY)
        label.set_text(corridorBadge, badgeText)
        label.set_color(corridorBadge, color.new(stateColor, 4))
        label.set_textcolor(corridorBadge, f_text_on(stateColor))
        label.set_size(corridorBadge, f_text_size(labelSizeInput))
else
    if not na(managementBox)
        box.delete(managementBox)
        managementBox := na
    if not na(corridorBadge)
        label.delete(corridorBadge)
        corridorBadge := na

var line anchorLine = na
var line invalidationLine = na
var line targetLine = na
var line protectLine = na
var label anchorTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_none, color = color.new(panelBorder, 100), textcolor = color.new(headerText, 100), size = size.normal)
var label invalidationTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_none, color = color.new(dangerColor, 100), textcolor = color.new(headerText, 100), size = size.normal)
var label targetTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_none, color = color.new(bullColor, 100), textcolor = color.new(headerText, 100), size = size.normal)
var label protectTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_none, color = color.new(accentColor, 100), textcolor = color.new(headerText, 100), size = size.normal)

if showManagementRails and hasMap and mapActive
    color sideColor = activeSide == 1 ? bullColor : bearColor
    color anchorColor = color.new(panelValueCol, 10)
    color invalidColor = color.new(dangerColor, 0)
    color targetColor = color.new(sideColor, 0)
    color protectColor = color.new(accentColor, 0)
    if na(anchorLine)
        anchorLine := line.new(anchorBar, anchorPrice, rightEdge, anchorPrice, xloc = xloc.bar_index, color = anchorColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(anchorLine, anchorBar, anchorPrice)
        line.set_xy2(anchorLine, rightEdge, anchorPrice)
        line.set_color(anchorLine, anchorColor)
    if na(invalidationLine)
        invalidationLine := line.new(anchorBar, invalidationRef, rightEdge, invalidationRef, xloc = xloc.bar_index, color = invalidColor, width = 2, style = line.style_solid)
    else
        line.set_xy1(invalidationLine, anchorBar, invalidationRef)
        line.set_xy2(invalidationLine, rightEdge, invalidationRef)
        line.set_color(invalidationLine, invalidColor)
    if na(targetLine)
        targetLine := line.new(anchorBar, targetRef, rightEdge, targetRef, xloc = xloc.bar_index, color = targetColor, width = 2, style = line.style_dotted)
    else
        line.set_xy1(targetLine, anchorBar, targetRef)
        line.set_xy2(targetLine, rightEdge, targetRef)
        line.set_color(targetLine, targetColor)
    if na(protectLine)
        protectLine := line.new(anchorBar, riskShiftRef, rightEdge, riskShiftRef, xloc = xloc.bar_index, color = protectColor, width = 1, style = line.style_dotted)
    else
        line.set_xy1(protectLine, anchorBar, riskShiftRef)
        line.set_xy2(protectLine, rightEdge, riskShiftRef)
        line.set_color(protectLine, protectColor)
    if showRightTags
        bool showProtectTag = referenceTagDensity == "All" or currentR >= protectReviewR * 0.60 or stateCode == 3
        f_set_tag(anchorTag, rightEdge, anchorPrice, "MAP ANCHOR  " + f_price(anchorPrice), panelBorder, labelSizeInput)
        f_set_tag(invalidationTag, rightEdge, invalidationRef, "INVALIDATION  " + f_price(invalidationRef), dangerColor, labelSizeInput)
        f_set_tag(targetTag, rightEdge, targetRef, "TARGET EDGE  " + f_price(targetRef), sideColor, labelSizeInput)
        if showProtectTag
            f_set_tag(protectTag, rightEdge, riskShiftRef, "PROTECT REVIEW  " + f_price(riskShiftRef), accentColor, labelSizeInput)
        else
            f_hide_tag(protectTag)
    else
        f_hide_tag(anchorTag)
        f_hide_tag(invalidationTag)
        f_hide_tag(targetTag)
        f_hide_tag(protectTag)
else
    if not na(anchorLine)
        line.delete(anchorLine)
        anchorLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(protectLine)
        line.delete(protectLine)
        protectLine := na
    f_hide_tag(anchorTag)
    f_hide_tag(invalidationTag)
    f_hide_tag(targetTag)
    f_hide_tag(protectTag)

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var int lastContextLabelBar = na
var int previousStateCode = 0
var array<label> eventLabels = array.new_label()

bool stateChanged = barstate.isconfirmed and hasMap and stateCode != previousStateCode
bool labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
bool contextReady = showContextLabels and hasMap and mapActive and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars) and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
bool shouldDrawLabel = showEventLabels and labelCooldownReady and (newMap or invalidatedNow or stateChanged or contextReady)

if shouldDrawLabel
    string labelText = newMap ? (activeSide == 1 ? "Long Map" : "Short Map") : stateText
    color labelColor = newMap ? accentColor : stateColor
    if invalidatedNow
        labelText := "INVALIDATED\nReset context"
        labelColor := dangerColor
    else if contextReady and not stateChanged and not newMap
        labelText := stateText
    if showLabelScore and hasMap and not invalidatedNow
        labelText += "\nScore " + str.tostring(math.round(nz(managementScore, 0.0)))
    float labelY = activeSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = activeSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 8), textcolor = f_text_on(labelColor), size = f_text_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index
    if contextReady
        lastContextLabelBar := bar_index

plotshape(showEventMarkers and newMap, title = "New Management Map", style = shape.diamond, location = location.belowbar, color = color.new(accentColor, 0), size = size.tiny)
plotshape(showEventMarkers and (invalidatedNow or stateCode == 4 and stateChanged), title = "Management Caution", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(managementScore, title = "Management Quality Score", color = stateColor, display = display.data_window)
plot(currentR, title = "Current R", color = accentColor, display = display.data_window)
plot(progressScore, title = "Progress Quality", color = bullColor, display = display.data_window)
plot(pullbackScore, title = "Pullback Risk Score", color = neutralColor, display = display.data_window)
plot(targetRoomScore, title = "Target Room Score", color = panelValueCol, display = display.data_window)
plot(trendDefenseScore, title = "Trend Defense Score", color = bearColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string theme = panelThemeInput
string panelSize = panelFontSizeInput
color dashBg = f_panel_bg(theme)
color frameColor = f_panel_border(theme)
color valueText = f_panel_value(theme)
string currentRRead = hasMap ? f_fmt(currentR) + "R" : "No map"
string scoreRead = hasMap ? str.tostring(math.round(nz(managementScore, 0.0))) + " / " + f_grade(nz(managementScore, 0.0)) : "No map"
string roomRead = hasMap ? roomText + " / " + f_fmt(targetRoomR) + "R" : roomText
string actionRead = actionText + " | " + sideText
string anchorRead = hasMap ? str.tostring(bar_index - anchorBar) + " bars ago" : "Waiting"
color panelStateColor = f_panel_state_color(stateCode, activeSide, theme)
color panelActionColor = stateCode == 1 ? valueText : panelStateColor
color panelRiskColor = stateCode == 3 ? accentColor : stateCode == 4 ? neutralColor : valueText

var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if showPanel and (na(panel) or panelLocationCache != panelLocationInput or panelThemeCache != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, 8, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
    panelLocationCache := panelLocationInput
    panelThemeCache := panelThemeInput

if barstate.islast
    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Trade Management Map", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Management State", stateText + " | " + scoreRead, panelStateColor, theme, panelSize)
        f_set_row(panel, 2, "Current R", currentRRead, hasMap and currentR >= 0.0 ? bullColor : hasMap ? bearColor : valueText, theme, panelSize)
        f_set_row(panel, 3, "Risk Shift", riskShiftText, panelRiskColor, theme, panelSize)
        f_set_row(panel, 4, "Target Room", roomRead, hasMap and targetRoomR > 0.85 ? bullColor : hasMap and targetRoomR > 0.15 ? neutralColor : bearColor, theme, panelSize)
        f_set_row(panel, 5, "Action", actionRead, panelActionColor, theme, panelSize)
        f_set_row(panel, 6, "Hold Rate", holdRateText, holdRateColor, theme, panelSize)
        f_set_row(panel, 7, "Map Anchor", anchorRead, valueText, theme, panelSize)
    else if not showPanel and not na(panel)
        table.delete(panel)
        panel := na
        panelLocationCache := ""
        panelThemeCache := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newMap, title = "Trade Management Map Active", message = "Trade Management Map: a new active management context has started. This is an attention marker, not a trade instruction.")
alertcondition(stateChanged and stateCode == 2, title = "Trade Management Hold Context", message = "Trade Management Map: Hold Context state is active.")
alertcondition(stateChanged and stateCode == 3, title = "Trade Management Protection Review", message = "Trade Management Map: protection review state is active.")
alertcondition(stateChanged and stateCode == 4, title = "Trade Management Caution Review", message = "Trade Management Map: caution review state is active.")
alertcondition(stateChanged and stateCode == 5, title = "Trade Management Target Review", message = "Trade Management Map: target review state is active.")
alertcondition(invalidatedNow, title = "Trade Management Invalidation", message = "Trade Management Map: the active invalidation reference was crossed.")

if barstate.isconfirmed
    previousStateCode := stateCode
````
