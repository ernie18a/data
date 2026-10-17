# Body Close Break Planner [AGPro Series]

- url: https://www.tradingview.com/script/tmdIvrfu-Body-Close-Break-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;9c832f15f7b344fbad4f352a7e76b2ed
- version: 5.0

## Description

TITLE

Body Close Break Planner [AGPro Series]


🧠 Core Idea

Did price break structure with real body-close acceptance, or was the move only a wick event with weak commitment?


📌 Overview / What it does

Body Close Break Planner [AGPro Series] is built to evaluate whether a structure break is being accepted with real candle-body commitment. Instead of reacting to every wick beyond a prior high or low, the script focuses on closes that actually establish acceptance beyond the rail.

The script maps the body break rail, an acceptance pocket, a retest shelf, a failure rail, and a first target-room reference. It also adds event labels, right-side tags, and a compact AG Pro panel that summarizes the quality of the active break with a 0-100 Body Break Score.

This script does not predict trend continuation, automate entries, or treat every breakout as valid. It is a rule-based analytical and visualization tool that helps users separate real body-close structure acceptance from weaker noise-driven break attempts.


🎯 Purpose & Design Philosophy

This script was built to solve a very common structural problem: many breakout candles look convincing in the moment, but the move fails because the market never achieved real closing acceptance beyond the level.

The tool was designed for traders who want to evaluate whether a break has genuine body-based commitment, whether the first retest is constructive, and where the structure fails if acceptance is lost.

The mindset behind the script is selective, disciplined, and evidence-based. It supports traders who want to read acceptance quality rather than react to every temporary excursion beyond a level.


⚡ Why This Script Is Different

Most breakout tools focus on level crossing, wick penetration, or generic break-and-retest behavior.

This script does NOT treat every breach of structure as a meaningful breakout.

Instead, it asks whether the move closed through structure with enough body commitment, whether price is still being accepted beyond the rail, whether the retest shelf improves the setup, and whether the move still has room before it becomes extended or fails.


⚙️ Methodology

1. Context Detection
The script maps recent structure highs and lows, then checks whether price closes beyond them with enough candle-body commitment and range expansion.

2. Reference Mapping
Once a valid body-close break is confirmed, the script locks the broken rail, builds an acceptance pocket, marks a retest shelf, and defines a failure line plus a first target-room reference.

3. Reaction Evaluation
Price is then reviewed against the body-break rail and the retest shelf. The script checks whether the move is still accepted, whether the retest improves the structure, or whether the breakout falls back through the failure boundary.

4. Visual Output
The final output includes the acceptance pocket, body-break rail, retest shelf, failure rail, room line, event labels, right-side tags, and dashboard panel.


🗺️ How to Read the Chart

Zones:
The acceptance pocket represents the active post-break area where structure acceptance is being judged.

Labels:
Labels identify new bullish or bearish body-close breaks, accepted structure, retest-ready behavior, target review, and failed breaks.

Colors:
Teal represents stronger constructive break behavior.
Pink represents bearish or failed context.
Gold represents review areas such as target-room interaction.
Indigo represents the main body-break rail.

Panel:
The panel summarizes the active break type, the Body Break Score, current acceptance quality, available room, and the current action state.


🚦 Signals & States

• Bull Break → A bullish body-close structure break has been detected.
• Bear Break → A bearish body-close structure break has been detected.
• Body Accepted → Price is still being accepted beyond the broken structure rail.
• Retest Ready → Price interacted with the retest shelf constructively and the setup quality improved.
• Target Review → The first projected room reference has been reached and context should be reassessed.
• Failed → Price moved back through the failure boundary and the break is no longer structurally clean.
• Wait Break → No valid active body-close break exists.
• Expired → The break is too old to remain active within the current framework.


🔔 Alerts Logic

Alerts can trigger when a new bullish or bearish body-close break is detected, when structure remains accepted, when a retest shelf strengthens the setup, when target room is reached, or when the break fails.

Alerts are attention markers only. They highlight structural events inside the script logic. They are not trade instructions, automated entries, or guarantees of follow-through.


🧩 Confluence Logic

The context becomes stronger when multiple conditions align together.

For example, a structure break with a strong body ratio, clean range expansion, stable hold beyond the break rail, and a constructive retest shelf interaction is much stronger than a shallow close that immediately falls back into the old range.

When body commitment, breakout range, retest quality, and available room align together, the context becomes structurally more reliable.


📊 When to Use

• Breakout or breakdown environments where close quality matters
• Markets with clean price structure and readable swing levels
• Crypto, forex, indices, and liquid stocks
• 1H, 4H, and 1D chart review
• Situations where wick-only breaks create repeated false positives


⚠️ When NOT to Use

• Illiquid markets with distorted price prints
• Extremely noisy sessions with poor candle quality
• Very low-range environments where closes carry little structural information
• Symbols dominated by gaps or erratic price jumps
• Conditions where the market repeatedly overshoots levels without clean follow-through


🎛️ Key Inputs

• Structure Lookback → Controls how recent highs and lows are mapped
• Minimum Range Ratio → Controls how much expansion is required before a break qualifies
• Minimum Body / Range → Filters out weak closes and wick-dominant candles
• Close Buffer ATR → Controls how far beyond structure the close must finish
• Acceptance Pocket ATR → Controls the depth of the post-break pocket
• Retest Shelf Buffer → Controls how shelf interactions are interpreted
• Failure Buffer ATR → Controls where the active break becomes invalid
• Visual Settings → Control labels, panel location, theme, font size, and optional chart styling


🖥️ Interface & Visual Design

The interface is designed to answer one question quickly: is this break actually being accepted?

The panel creates a clean information hierarchy so the user can understand break state, score, room, and current action without reading every chart element manually. The chart layer keeps the acceptance pocket, body-break rail, failure line, and room reference readable without overwhelming candles.

The visual intent is professional, premium, and publication-friendly rather than decorative.


🧪 Practical Usage Workflow

1. Read the panel to confirm whether a valid body-close break is active
2. Check the body-break rail and acceptance pocket
3. Evaluate whether price is simply holding or whether the retest shelf improved the structure
4. Review room to the target reference and distance to failure
5. Use labels and tags as context markers, not as direct commands


🔍 Interpretation Guidelines

A stronger score suggests better body commitment, healthier range expansion, and more reliable post-break structure.

A Body Accepted state means price is still holding beyond the broken rail, but it does not automatically mean the move is early or low-risk.

A Retest Ready state suggests the market pulled back in a controlled way and defended the structure more convincingly.

A Target Review state suggests that the first projected room objective has already been reached and the context should be reassessed rather than assumed to continue indefinitely.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an automated trading system.

This script does not place orders.

This script does not guarantee continuation, retest success, target reach, or profitability.


⚠️ Limitations & Transparency

This script is rule-based and depends on the quality of the underlying market structure.

Different timeframes can produce very different break quality profiles. In high-volatility or low-liquidity conditions, candle closes may appear meaningful while still failing quickly. In some markets, wick behavior may remain important even when the body-close break model is intentionally strict.

Outputs should always be interpreted within broader market context rather than in isolation.


🧠 Market Context Notes

Body-close acceptance often matters most around obvious swing highs, swing lows, range edges, and post-compression expansion points.

A wick beyond structure can attract attention, but a true close beyond structure often tells a more reliable story about commitment. Even so, not every accepted break becomes a trend. Some become retest traps, and some run directly into higher-timeframe resistance or support.


🧾 Use Case Examples

Example 1:
Price closes above a well-defined swing high with a strong body and good expansion. The script marks a bull break, builds the acceptance pocket, and later upgrades the context when the retest shelf holds.

Example 2:
Price breaks below a swing low with body commitment, but then quickly closes back through the failure boundary. The script marks the break as failed, signaling that the downside acceptance did not hold.

Example 3:
A strong body-close break remains accepted and quickly reaches the first target-room line. The script marks target review, reminding the user to reassess efficiency and extension.


🧱 System Philosophy

AGPro Series tools are built as decision-support frameworks, not generic signal generators.

The philosophy here is to reward quality over noise: stronger closes, cleaner acceptance, clearer structure, and more readable post-break behavior.


🔐 Non-Promise Statement

This script does not promise certainty.

It does not promise that a body-close break will continue, hold, retest cleanly, or reach its projected room. It only organizes the structure so the user can evaluate the break with more discipline and clarity.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly, and any analytical tool can become less reliable under shifting volatility, liquidity, or structural conditions. Users remain fully responsible for their own decisions, execution, and risk management.

This script is for educational and analytical purposes only. It does not provide financial advice.


📚 Educational Note

This tool is most effective when combined with broader market structure, liquidity awareness, and disciplined trade management.

It is designed to improve interpretation quality, not to replace critical thinking.

## Source Code

````pine
// --------------------------------------------------
// Body Close Break Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Body Close Break Planner measures whether price breaks structure with real
// body-close acceptance instead of wick-only noise, maps the acceptance pocket,
// tracks retest quality, failure risk and first target room, organizes body
// commitment, breakout strength and post-break behavior into a 0-100 score, and
// adds a persistent hold-rate proof layer tracking how often a body-close break
// survives without invalidating, for structured price-action and
// break-and-retest review.
// --------------------------------------------------

//@version=6
indicator("Body Close Break Planner [AGPro Series]",
     shorttitle = "AG Pro BCB",
     overlay = true,
     max_boxes_count = 40,
     max_lines_count = 120,
     max_labels_count = 180)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_BREAK = "Break Engine"
string G_ACCEPT = "Acceptance Logic"
string G_PROOF = "Confirm-Rate Proof"
string G_VISUAL = "Visual Design"
string G_PANEL = "Panel"
string G_ALERTS = "Alerts"

int atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_BREAK,
     tooltip = "ATR length used to normalize breakout buffers, pocket depth, failure shelves, labels, and room calculations.")
int swingLookback = input.int(20, "Structure Lookback", minval = 5, maxval = 300, group = G_BREAK,
     tooltip = "Lookback used to map the structure high or low that must be broken with a real body close.")
int rangeLength = input.int(20, "Break Range Length", minval = 5, maxval = 300, group = G_BREAK,
     tooltip = "Lookback used to compare the breakout candle range against recent average range.")
float minRangeRatio = input.float(1.10, "Minimum Range Ratio", minval = 0.50, maxval = 10.0, step = 0.05, group = G_BREAK,
     tooltip = "Minimum current range divided by average range required before a structure break can qualify as meaningful.")
float minBodyRatio = input.float(0.55, "Minimum Body / Range", minval = 0.10, maxval = 0.95, step = 0.01, group = G_BREAK,
     tooltip = "Minimum body-to-range ratio required to classify the break as a true body-close event instead of wick noise.")
float closeBufferAtr = input.float(0.05, "Close Buffer ATR", minval = 0.00, maxval = 1.0, step = 0.01, group = G_BREAK,
     tooltip = "ATR buffer required beyond the structure rail before the breakout close is accepted.")

int minReadyScore = input.int(67, "Minimum Ready Score", minval = 1, maxval = 100, group = G_ACCEPT,
     tooltip = "Minimum 0-100 score required before the post-break retest becomes ready.")
float acceptancePocketAtr = input.float(0.42, "Acceptance Pocket ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_ACCEPT,
     tooltip = "ATR depth used to build the post-break acceptance pocket beyond the structure rail.")
float retestBufferAtr = input.float(0.08, "Retest Shelf Buffer ATR", minval = 0.00, maxval = 1.0, step = 0.01, group = G_ACCEPT,
     tooltip = "ATR buffer around the retest shelf used to confirm a meaningful pullback into the acceptance pocket.")
float failureBufferAtr = input.float(0.18, "Failure Buffer ATR", minval = 0.00, maxval = 2.0, step = 0.01, group = G_ACCEPT,
     tooltip = "ATR shelf beyond the opposite side of the structure rail where the active body-break idea fails.")
float targetRoomAtr = input.float(0.90, "Target Room ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_ACCEPT,
     tooltip = "ATR distance beyond the breakout extreme used to estimate the first target-room review area.")
int roomLookback = input.int(72, "Room Lookback", minval = 10, maxval = 500, group = G_ACCEPT,
     tooltip = "Lookback used to compare the active target-room reference against nearby structure.")
int maxBreakAge = input.int(96, "Maximum Break Age", minval = 5, maxval = 600, group = G_ACCEPT,
     tooltip = "Maximum bars a body-close break can remain active before it expires.")

int proofHoldWindow = input.int(8, "Proof Hold Window Bars", minval = 3, maxval = 120, group = G_PROOF,
     tooltip = "Bars a body-close break must survive without closing back beyond its origin breakout candle to be counted as a held break in the Hold Rate proof statistic.")

bool showAcceptancePocket = input.bool(true, "Show Acceptance Pocket", group = G_VISUAL,
     tooltip = "Shows the post-break acceptance pocket used to judge whether price is holding the body-close break.")
bool showPocketHalo = input.bool(true, "Show Pocket Halo", group = G_VISUAL,
     tooltip = "Adds a soft outer halo around the active acceptance pocket for better first-glance visibility.")
bool showPocketLabel = input.bool(true, "Show Centered Pocket Badge", group = G_VISUAL,
     tooltip = "Shows a centered premium badge inside the acceptance pocket.")
bool showBreakRail = input.bool(true, "Show Body Break Rail", group = G_VISUAL,
     tooltip = "Shows the main structure rail that was broken with body-close acceptance.")
bool showRetestShelf = input.bool(true, "Show Retest Shelf", group = G_VISUAL,
     tooltip = "Shows the first shelf inside the pocket where retest quality improves.")
bool showFailureRail = input.bool(true, "Show Failure Rail", group = G_VISUAL,
     tooltip = "Shows where the active body-close break context fails.")
bool showRoomRail = input.bool(true, "Show Target-Room Rail", group = G_VISUAL,
     tooltip = "Shows the first target-room review reference after the break.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows breakout, retest, target-review, and failed-break labels on the chart.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for the body rail, failure rail, and target-room reference.")
bool showBarColors = input.bool(false, "Color Bars by State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the active body-close break state.")
string activeMapLayout = input.string("Forward Plan", "Active Map Layout", options = ["Forward Plan", "From Break"], group = G_VISUAL,
     tooltip = "Forward Plan places the active pocket and its references in clean chart space to the right of price. From Break preserves the historical pocket from the originating break candle.")
int pocketHistoryBars = input.int(28, "Pocket History Bars", minval = 8, maxval = 180, group = G_VISUAL,
     tooltip = "Controls historical pocket length when Active Map Layout is set to From Break.")
int projectionBars = input.int(16, "Pocket Projection Bars", minval = 8, maxval = 120, group = G_VISUAL,
     tooltip = "Number of bars used to project the active acceptance pocket. Smaller values keep the pocket compact and prevent right tags from sitting inside the zone.")
int tagOffsetBars = input.int(13, "Right Tag Offset", minval = 5, maxval = 80, group = G_VISUAL,
     tooltip = "Horizontal distance from the latest bar used for right-side tags. The default places tags just outside the compact pocket.")
int labelCooldownBars = input.int(26, "Label Cooldown Bars", minval = 1, maxval = 120, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
int maxEventLabels = input.int(4, "Maximum Event Labels", minval = 3, maxval = 30, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
int eventMemoryBars = input.int(120, "Event Label Memory Bars", minval = 20, maxval = 1000, group = G_VISUAL,
     tooltip = "Maximum age of historical event labels. Older labels are removed so stale break events do not dominate the current chart.")
float labelOffsetAtr = input.float(0.64, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels remain readable above or below candles.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label, pocket badge, and right-side tag font size.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light", "Slate"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

bool alertBreak = input.bool(true, "Alert: New Break", group = G_ALERTS,
     tooltip = "Enables alerts when a new body-close structure break is detected.")
bool alertAccepted = input.bool(true, "Alert: Body Accepted", group = G_ALERTS,
     tooltip = "Enables alerts when the active structure break continues to hold with body acceptance.")
bool alertRetest = input.bool(true, "Alert: Retest Ready", group = G_ALERTS,
     tooltip = "Enables alerts when a retest shelf interaction strengthens the active break.")
bool alertTarget = input.bool(false, "Alert: Target Review", group = G_ALERTS,
     tooltip = "Enables alerts when price reaches the target-room review reference.")
bool alertFailed = input.bool(true, "Alert: Failed Break", group = G_ALERTS,
     tooltip = "Enables alerts when the active body-close break context fails.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBg = color.rgb(15, 23, 42)
color panelBorder = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score_int(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_score_text(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_score_grade_text(int score) =>
    str.tostring(score) + " " + f_grade(score)

f_size(string sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     sizeInput == "Large" ? size.large :
     sizeInput == "Huge" ? size.huge : size.normal

f_panel_pos(string posInput) =>
    posInput == "Top Left" ? position.top_left :
     posInput == "Top Center" ? position.top_center :
     posInput == "Middle Right" ? position.middle_right :
     posInput == "Middle Left" ? position.middle_left :
     posInput == "Middle Center" ? position.middle_center :
     posInput == "Bottom Right" ? position.bottom_right :
     posInput == "Bottom Left" ? position.bottom_left :
     posInput == "Bottom Center" ? position.bottom_center : position.top_right

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? color.rgb(15, 23, 42) : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : themeName == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : themeName == "Slate" ? color.rgb(203, 213, 225) : panelLabelCol

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else if themeName == "Slate"
        evenRow ? color.rgb(51, 65, 85) : color.rgb(30, 41, 59)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_set_line(line lineRef, int x1, float y1, int x2, float y2, color lineColor, bool dotted, int widthValue) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, lineColor)
    line.set_style(lineRef, dotted ? line.style_dotted : line.style_solid)
    line.set_width(lineRef, widthValue)

f_set_tag(label tag, int x, float y, string labelText, color bg, string textSize) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, labelText)
    label.set_color(tag, color.new(bg, 3))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, label.style_label_left)
    label.set_size(tag, f_size(textSize))

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, bgcolor = rowBg, text_color = f_panel_label(themeName), text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, bgcolor = rowBg, text_color = rightColor, text_size = f_size(sizeInput), text_halign = text.align_right)

// --------------------------------------------------
// Core calculations
// --------------------------------------------------
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float barRange = math.max(high - low, syminfo.mintick)
float avgRange = ta.sma(barRange, rangeLength)
float rangeRatio = avgRange > 0.0 ? barRange / avgRange : 1.0
float bodyRatio = math.abs(close - open) / barRange
float closeLocation = (close - low) / barRange

float priorHigh = ta.highest(high[1], swingLookback)
float priorLow = ta.lowest(low[1], swingLookback)
float recentHigh = ta.highest(high[1], roomLookback)
float recentLow = ta.lowest(low[1], roomLookback)

bool bullBreakRaw = close > priorHigh + atr * closeBufferAtr and close[1] <= priorHigh and close > open and bodyRatio >= minBodyRatio and rangeRatio >= minRangeRatio and closeLocation >= 0.62
bool bearBreakRaw = close < priorLow - atr * closeBufferAtr and close[1] >= priorLow and close < open and bodyRatio >= minBodyRatio and rangeRatio >= minRangeRatio and closeLocation <= 0.38
bool newBreak = barstate.isconfirmed and (bullBreakRaw or bearBreakRaw)
float evalClose = barstate.isconfirmed or bar_index == 0 ? close : close[1]
float evalHigh = barstate.isconfirmed or bar_index == 0 ? high : high[1]
float evalLow = barstate.isconfirmed or bar_index == 0 ? low : low[1]

// --------------------------------------------------
// Active break state
// --------------------------------------------------
var bool hasBreak = false
var int activeDir = 0
var int breakBar = na
var float breakHigh = na
var float breakLow = na
var float breakRail = na
var float pocketTop = na
var float pocketBottom = na
var float pocketMid = na
var float retestShelf = na
var float failureRail = na
var float roomRail = na
var float breakRangeRatio = na
var float breakBodyRatio = na
var bool targetReached = false
var bool failed = false
var bool retestReady = false
var int lastLabelBar = na

// Hold-rate proof layer (did the break survive without invalidating?)
var bool proofPending = false
var int proofDir = 0
var float proofInvalid = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if newBreak
    // An unresolved previous break leaves the proof sample on replacement
    proofPending := false
    hasBreak := true
    activeDir := bullBreakRaw ? 1 : -1
    breakBar := bar_index
    breakHigh := high
    breakLow := low
    breakRail := bullBreakRaw ? priorHigh : priorLow
    float pocketDepth = atr * acceptancePocketAtr
    pocketTop := bullBreakRaw ? breakRail + pocketDepth : breakRail
    pocketBottom := bullBreakRaw ? breakRail : breakRail - pocketDepth
    pocketMid := (pocketTop + pocketBottom) * 0.5
    retestShelf := bullBreakRaw ? breakRail + pocketDepth * 0.55 : breakRail - pocketDepth * 0.55
    failureRail := bullBreakRaw ? breakRail - atr * failureBufferAtr : breakRail + atr * failureBufferAtr
    float roomCandidate = bullBreakRaw ? math.max(high + atr * targetRoomAtr, recentHigh) : math.min(low - atr * targetRoomAtr, recentLow)
    roomRail := roomCandidate
    breakRangeRatio := rangeRatio
    breakBodyRatio := bodyRatio
    targetReached := false
    failed := false
    retestReady := false
    proofPending := true
    proofDir := activeDir
    proofInvalid := bullBreakRaw ? breakLow : breakHigh
    proofStartBar := bar_index

int breakAge = hasBreak and not na(breakBar) ? bar_index - breakBar : na
bool expired = hasBreak and breakAge > maxBreakAge
bool bodyAccepted = hasBreak and not expired and not failed and (activeDir == 1 ? evalClose >= breakRail : evalClose <= breakRail)
bool retestTouch = hasBreak and not expired and not failed and (activeDir == 1 ? evalLow <= retestShelf + atr * retestBufferAtr and evalLow >= failureRail : evalHigh >= retestShelf - atr * retestBufferAtr and evalHigh <= failureRail)

if barstate.isconfirmed and hasBreak and not expired and not failed
    if activeDir == 1 and evalClose < failureRail
        failed := true
    if activeDir == -1 and evalClose > failureRail
        failed := true
    if activeDir == 1 and evalHigh >= roomRail
        targetReached := true
    if activeDir == -1 and evalLow <= roomRail
        targetReached := true
    if activeDir == 1 and retestTouch and evalClose >= retestShelf and evalClose >= breakRail
        retestReady := true
    if activeDir == -1 and retestTouch and evalClose <= retestShelf and evalClose <= breakRail
        retestReady := true

bool activeBreak = hasBreak and not expired and not failed

// Resolve the hold proof: a break that closes back beyond its origin candle
// within the window is a non-hold; surviving the window counts as held.
if proofPending and barstate.isconfirmed and bar_index > proofStartBar and not newBreak
    bool proofFail = proofDir == 1 ? close < proofInvalid : close > proofInvalid
    bool proofHeld = bar_index - proofStartBar >= proofHoldWindow
    if proofFail
        proofTotal += 1
        proofPending := false
    else if proofHeld
        proofTotal += 1
        proofWin += 1
        proofPending := false

int historicalLeft = hasBreak and not na(breakBar) ? math.max(breakBar, bar_index - pocketHistoryBars) : bar_index
int visualLeft = activeMapLayout == "Forward Plan" ? bar_index + 2 : historicalLeft
int visualRight = bar_index + projectionBars
int tagRight = math.max(bar_index + tagOffsetBars, visualRight + 4)
int rightEdge = visualRight

// --------------------------------------------------
// Score and states
// --------------------------------------------------
float bodyScorePart = hasBreak ? f_clamp(breakBodyRatio / math.max(minBodyRatio, 0.01) * 24.0, 0.0, 24.0) : 0.0
float rangeScorePart = hasBreak ? f_clamp(breakRangeRatio / math.max(minRangeRatio, 0.01) * 18.0, 0.0, 18.0) : 0.0
float closeStrength = hasBreak ? activeDir == 1 ? f_clamp((evalClose - breakRail) / atr * 16.0, 0.0, 16.0) : f_clamp((breakRail - evalClose) / atr * 16.0, 0.0, 16.0) : 0.0
float holdScorePart = hasBreak ? activeDir == 1 ? f_clamp((evalClose - failureRail) / math.max(roomRail - failureRail, syminfo.mintick) * 18.0, 0.0, 18.0) : f_clamp((failureRail - evalClose) / math.max(failureRail - roomRail, syminfo.mintick) * 18.0, 0.0, 18.0) : 0.0
float retestScorePart = retestReady ? 18.0 : retestTouch ? 9.0 : bodyAccepted ? 6.0 : 0.0
float roomScorePart = hasBreak ? activeDir == 1 ? f_clamp((roomRail - evalClose) / atr * 3.0, 0.0, 12.0) : f_clamp((evalClose - roomRail) / atr * 3.0, 0.0, 12.0) : 0.0
float agePenalty = hasBreak ? f_clamp(breakAge / math.max(maxBreakAge, 1) * 8.0, 0.0, 8.0) : 0.0
float failurePenalty = failed ? 20.0 : 0.0
float rawScore = bodyScorePart + rangeScorePart + closeStrength + holdScorePart + retestScorePart + roomScorePart - agePenalty - failurePenalty
int bodyBreakScore = hasBreak and not expired ? f_score_int(rawScore) : 0
string grade = f_grade(bodyBreakScore)

string breakState = not hasBreak ? "No Break" : expired ? "Expired" : failed ? "Failed" : activeDir == 1 ? "Bull Body Break" : "Bear Body Break"
string acceptanceText = hasBreak and not expired ? activeDir == 1 ? "Above / " + str.tostring((evalClose - breakRail) / atr, "0.00") + " ATR" : "Below / " + str.tostring((breakRail - evalClose) / atr, "0.00") + " ATR" : "n/a"
string roomText = hasBreak and not expired ? str.tostring(math.abs(roomRail - evalClose) / atr, "0.00") + " ATR" : "n/a"
bool readyState = activeBreak and retestReady and bodyBreakScore >= minReadyScore and not targetReached

string actionState = "Wait Break"
if expired
    actionState := "Expired"
else if failed
    actionState := "Failed"
else if targetReached
    actionState := "Target Review"
else if readyState
    actionState := "Retest Ready"
else if bodyAccepted
    actionState := "Body Accepted"

color stateColor = not hasBreak or expired ? neutralColor : failed ? bearColor : readyState ? bullColor : bodyAccepted ? accentColor : activeDir == 1 ? bullColor : bearColor
color actionColor = actionState == "Retest Ready" ? bullColor : actionState == "Failed" ? bearColor : actionState == "Target Review" ? neutralColor : actionState == "Body Accepted" ? accentColor : neutralColor
string scoreText = hasBreak and not expired ? f_score_grade_text(bodyBreakScore) : "n/a"
string panelBreakText = not hasBreak ? "No Break" : expired ? "Expired" : failed ? "Failed" : activeDir == 1 ? "Bull Break" : "Bear Break"

float ftRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na
string ftText = na(ftRate) ? "Building" : str.tostring(math.round(ftRate)) + "% (" + str.tostring(proofTotal) + ")"
color ftColor = na(ftRate) ? f_panel_value(panelThemeInput) : ftRate >= 55.0 ? bullColor : ftRate >= 40.0 ? neutralColor : bearColor

bool breakPrev = bar_index > 0 ? hasBreak[1] : false
bool acceptedPrev = bar_index > 0 ? bodyAccepted[1] : false
bool retestPrev = bar_index > 0 ? retestReady[1] : false
bool targetPrev = bar_index > 0 ? targetReached[1] : false
bool failedPrev = bar_index > 0 ? failed[1] : false

bool breakEvent = newBreak
bool acceptedEvent = barstate.isconfirmed and bodyAccepted and not acceptedPrev and not newBreak
bool retestEvent = barstate.isconfirmed and retestReady and not retestPrev
bool targetEvent = barstate.isconfirmed and targetReached and not targetPrev
bool failedEvent = barstate.isconfirmed and failed and not failedPrev

// --------------------------------------------------
// Drawings
// --------------------------------------------------
color hiddenColor = color.new(color.black, 100)
var box pocketHalo = na
var box pocketBox = na
var line breakLine = na
var line midLine = na
var line shelfLine = na
var line failLine = na
var line roomLine = na
var label pocketBadge = na

if activeBreak and showAcceptancePocket
    float haloPad = math.max(atr * 0.10, math.abs(pocketTop - pocketBottom) * 0.30)
    if showPocketHalo
        if na(pocketHalo)
            pocketHalo := box.new(visualLeft, pocketTop + haloPad, visualRight, pocketBottom - haloPad, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 93), border_color = color.new(stateColor, 58), border_width = 1)
        else
            box.set_lefttop(pocketHalo, visualLeft, pocketTop + haloPad)
            box.set_rightbottom(pocketHalo, visualRight, pocketBottom - haloPad)
            box.set_bgcolor(pocketHalo, color.new(stateColor, 93))
            box.set_border_color(pocketHalo, color.new(stateColor, 58))
    else
        if not na(pocketHalo)
            box.delete(pocketHalo)
            pocketHalo := na
    if na(pocketBox)
        pocketBox := box.new(visualLeft, pocketTop, visualRight, pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 76), border_color = color.new(stateColor, 0), border_width = 3)
    else
        box.set_lefttop(pocketBox, visualLeft, pocketTop)
        box.set_rightbottom(pocketBox, visualRight, pocketBottom)
        box.set_bgcolor(pocketBox, color.new(stateColor, 76))
        box.set_border_color(pocketBox, color.new(stateColor, 0))
        box.set_border_width(pocketBox, 3)
    if showPocketLabel
        int badgeX = int(math.round((visualLeft + visualRight) * 0.5))
        string sideText = activeDir == 1 ? "Bull" : "Bear"
        string badgeTitle = readyState ? sideText + " Retest Ready" : targetReached ? sideText + " Target Review" : bodyAccepted ? sideText + " Acceptance" : sideText + " Break Pocket"
        string badgeText = badgeTitle + "\nQ " + str.tostring(bodyBreakScore) + " | " + grade
        if na(pocketBadge)
            pocketBadge := label.new(badgeX, pocketMid, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 3), textcolor = f_text_on(stateColor), size = f_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_x(pocketBadge, badgeX)
            label.set_y(pocketBadge, pocketMid)
            label.set_text(pocketBadge, badgeText)
            label.set_color(pocketBadge, color.new(stateColor, 3))
            label.set_textcolor(pocketBadge, f_text_on(stateColor))
            label.set_size(pocketBadge, f_size(labelSizeInput))
    else
        if not na(pocketBadge)
            label.delete(pocketBadge)
            pocketBadge := na
else
    if not na(pocketHalo)
        box.delete(pocketHalo)
        pocketHalo := na
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na

if activeBreak and showBreakRail
    if na(breakLine)
        breakLine := line.new(visualLeft, breakRail, visualRight, breakRail, xloc = xloc.bar_index, extend = extend.none, color = accentColor, width = 3)
    else
        f_set_line(breakLine, visualLeft, breakRail, visualRight, breakRail, accentColor, false, 3)
else
    if not na(breakLine)
        line.delete(breakLine)
        breakLine := na

if activeBreak and showRetestShelf
    if na(midLine)
        midLine := line.new(visualLeft, pocketMid, visualRight, pocketMid, xloc = xloc.bar_index, color = color.new(stateColor, 5), width = 2, style = line.style_dotted)
    else
        f_set_line(midLine, visualLeft, pocketMid, visualRight, pocketMid, color.new(stateColor, 5), true, 2)
    if na(shelfLine)
        shelfLine := line.new(visualLeft, retestShelf, visualRight, retestShelf, xloc = xloc.bar_index, extend = extend.none, color = stateColor, width = 2)
    else
        f_set_line(shelfLine, visualLeft, retestShelf, visualRight, retestShelf, stateColor, false, 2)
else
    if not na(midLine)
        line.delete(midLine)
        midLine := na
    if not na(shelfLine)
        line.delete(shelfLine)
        shelfLine := na

if activeBreak and showFailureRail
    if na(failLine)
        failLine := line.new(visualLeft, failureRail, visualRight, failureRail, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 2, style = line.style_dashed)
    else
        f_set_line(failLine, visualLeft, failureRail, visualRight, failureRail, bearColor, true, 2)
        line.set_style(failLine, line.style_dashed)
else
    if not na(failLine)
        line.delete(failLine)
        failLine := na

if activeBreak and showRoomRail
    if na(roomLine)
        roomLine := line.new(visualLeft, roomRail, visualRight, roomRail, xloc = xloc.bar_index, extend = extend.none, color = neutralColor, width = 2)
    else
        f_set_line(roomLine, visualLeft, roomRail, visualRight, roomRail, neutralColor, false, 2)
else
    if not na(roomLine)
        line.delete(roomLine)
        roomLine := na

// --------------------------------------------------
// Labels
// --------------------------------------------------
float labelOffset = atr * labelOffsetAtr
var array<label> eventLabels = array.new<label>()

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if array.size(eventLabels) > 0
    int cleanupIdx = array.size(eventLabels) - 1
    while cleanupIdx >= 0
        label oldLabel = array.get(eventLabels, cleanupIdx)
        int oldX = label.get_x(oldLabel)
        float oldY = label.get_y(oldLabel)
        bool staleLabel = bar_index - oldX > eventMemoryBars
        bool pocketCollision = activeBreak and showAcceptancePocket and oldX >= visualLeft - 2 and oldX <= visualRight + 2 and oldY >= pocketBottom - atr * 0.75 and oldY <= pocketTop + atr * 0.75
        if staleLabel or pocketCollision
            label.delete(oldLabel)
            array.remove(eventLabels, cleanupIdx)
        cleanupIdx -= 1

f_new_event_label(int x, float y, string txt, color bg, bool upward) =>
    label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, color = color.new(bg, 4), textcolor = f_text_on(bg), size = f_size(labelSizeInput), textalign = text.align_center)

if showEventLabels and newBreak and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = bullBreakRaw
    label newLabel = f_new_event_label(bar_index, bullEvent ? low - labelOffset : high + labelOffset, (bullEvent ? "Bull Break\n" : "Bear Break\n") + f_score_grade_text(bodyBreakScore), bullEvent ? bullColor : bearColor, bullEvent)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and acceptedEvent and not newBreak and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    label newLabel = f_new_event_label(bar_index, bullEvent ? low - labelOffset : high + labelOffset, "Accepted\n" + f_score_grade_text(bodyBreakScore), accentColor, bullEvent)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and retestEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    label newLabel = f_new_event_label(bar_index, bullEvent ? low - labelOffset : high + labelOffset, "Retest Ready\n" + f_score_grade_text(bodyBreakScore), stateColor, bullEvent)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and targetEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    label newLabel = f_new_event_label(bar_index, bullEvent ? high + labelOffset : low - labelOffset, "Target Room\n" + f_score_grade_text(bodyBreakScore), neutralColor, not bullEvent)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and failedEvent and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
    bool bullEvent = activeDir == 1
    label newLabel = f_new_event_label(bar_index, bullEvent ? low - labelOffset : high + labelOffset, "Failed Break\n" + f_score_grade_text(bodyBreakScore), bearColor, bullEvent)
    f_push_label(newLabel)
    lastLabelBar := bar_index

// --------------------------------------------------
// Right-side tags
// --------------------------------------------------
var label railTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
var label failTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
var label roomTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)

if showRightTags and activeBreak
    float tagGap = atr * 0.52
    float railTagY = breakRail
    float failTagY = activeDir == 1 ? math.min(failureRail, railTagY - tagGap) : math.max(failureRail, railTagY + tagGap)
    float roomTagY = activeDir == 1 ? math.max(roomRail, railTagY + tagGap) : math.min(roomRail, railTagY - tagGap)
    f_set_tag(railTag, tagRight, railTagY, "Break Rail " + f_price(breakRail), accentColor, labelSizeInput)
    f_set_tag(failTag, tagRight, failTagY, "Failure " + f_price(failureRail), bearColor, labelSizeInput)
    f_set_tag(roomTag, tagRight, roomTagY, "Target " + f_price(roomRail), neutralColor, labelSizeInput)
else
    label.set_text(railTag, "")
    label.set_text(failTag, "")
    label.set_text(roomTag, "")
    label.set_color(railTag, hiddenColor)
    label.set_color(failTag, hiddenColor)
    label.set_color(roomTag, hiddenColor)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 7, bgcolor = f_panel_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if barstate.islast
    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Body Close Break Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Break", panelBreakText, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Score", scoreText, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Acceptance", acceptanceText, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Room", roomText, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Action", actionState, actionColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Hold Rate", ftText, ftColor, panelThemeInput, panelFontSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelPosMemory := ""
            panelThemeMemory := ""

color barStateColor = actionState == "Retest Ready" ? color.new(stateColor, 72) : actionState == "Body Accepted" ? color.new(accentColor, 76) : actionState == "Failed" ? color.new(bearColor, 70) : actionState == "Target Review" ? color.new(neutralColor, 78) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertBreak and breakEvent and activeDir == 1, "Body Close Break | Bull Break", "A bullish body-close structure break has been detected.")
alertcondition(alertBreak and breakEvent and activeDir == -1, "Body Close Break | Bear Break", "A bearish body-close structure break has been detected.")
alertcondition(alertAccepted and acceptedEvent, "Body Close Break | Body Accepted", "The active body-close break is still being accepted beyond the structure rail.")
alertcondition(alertRetest and retestEvent, "Body Close Break | Retest Ready", "The active body-close break defended the retest shelf and is ready.")
alertcondition(alertTarget and targetEvent, "Body Close Break | Target Review", "Price reached the active target-room review area.")
alertcondition(alertFailed and failedEvent, "Body Close Break | Failed", "The active body-close break context has failed.")
````
