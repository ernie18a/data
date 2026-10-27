# Breakout Follow-Through Planner [AGPro Series]

- url: https://www.tradingview.com/script/M5fT5KRy-Breakout-Follow-Through-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;ca3a0740df3f41858b3ded68fdcdec4d
- version: 4.0

## Description

Breakout Follow-Through Planner [AGPro Series]

🧠 Core Idea

Did the breakout receive enough follow-through to stay valid?


📌 Overview / What it does

Breakout Follow-Through Planner [AGPro Series] is a chart-first breakout planning tool designed to evaluate what happens after price clears a recent structure edge.

Instead of treating the breakout candle as the full story, the script maps the broken level, creates a follow-through corridor, tracks post-break travel, measures close progress, monitors retest-depth risk, and converts the full sequence into a 0-100 Follow-Through Score.

The script produces a breakout line, follow-through corridor, weak-continuation labels, failure rail, target-room guide, alerts, and a clean AGPro decision panel. It does not predict price, automate trades, or issue entry/exit commands.


🎯 Purpose & Design Philosophy

This script was built for traders who already understand that a breakout is only the first event.

The practical question comes after the break: does price travel away from the level, hold enough distance, and preserve clean room, or does it stall and begin to retest too deeply? This planner turns that post-break phase into a readable decision process.

The design supports a planning mindset: identify the breakout, review follow-through quality, respect the failure rail, measure target room, and decide whether the active context still deserves attention.


⚡ Why This Script Is Different

Most breakout tools focus on the moment price crosses a level.

This script does NOT clone Breakout Volume Quality, Breakout Retest Readiness, Acceptance Breakout Planner, Volume Expansion Breakout Planner, or a generic support/resistance breakout scanner.

Instead, it focuses on post-break travel quality. The key question is not simply "did price break?" or "was volume high?" or "did the retest hold?" The key question is whether the breakout received enough follow-through after the break to remain structurally valid.


⚙️ Methodology

1. Context Detection
The script builds recent upper and lower breakout references from a configurable prior structure window.

2. Reference Mapping
When price closes beyond a reference edge by an ATR-normalized buffer, the planner starts an active breakout follow-through plan.

3. Reaction Evaluation
The model evaluates break candle quality, volume support, follow-through travel, number of closes beyond the breakout close, retest-depth risk, target room, and failure rail behavior.

4. Visual Output
The chart shows the breakout line, active follow-through corridor, failure rail, target-room guide, compact labels, and an AGPro panel summarizing the current decision state.


🗺️ How to Read the Chart

Follow-Through Corridor = the active path from the breakout close toward the target-room guide. Its text is centered inside the corridor.

Breakout Line = the structure edge that was cleared and now anchors the active plan.

Failure Rail = the invalidation reference behind the breakout line. It is an analytical guide, not a stop order.

Target Room = the projected planning guide based on the prior structure height.

Labels = compact markers such as BFT UP, BFT DN, FT READY, WEAK FT, RETEST RISK, FAIL RAIL, ROOM HIT, and TRACK.

Colors = teal supports constructive bullish follow-through, pink supports bearish follow-through, amber marks caution, indigo marks target-room review, and red marks failure rail pressure.

Panel = the main decision interface showing Breakout Side, Follow-Through, Retest Risk, Target Room, and Action.


🚦 Signals & States

• BFT UP → a bullish breakout started a follow-through review.

• BFT DN → a bearish breakout started a follow-through review.

• FT WATCH → follow-through evidence is developing but not complete.

• FT READY → travel, closes, score quality, and retest-depth conditions are constructive.

• WEAK FT → the follow-through window aged without enough progress.

• RETEST RISK → price moved too deeply back toward or through the breakout line.

• FAIL RAIL → price closed through the failure rail after the breakout plan.

• ROOM HIT → price reached the target-room guide and context should be reviewed.


🔔 Alerts Logic

Alerts can trigger when a bullish or bearish breakout plan starts, follow-through reaches the ready state, weak follow-through or retest risk appears, the failure rail is hit, or target-room review is reached.

These alerts are attention markers for chart review. They are not trade instructions, automated strategy rules, or guaranteed outcomes.


🧩 Confluence Logic

The strongest follow-through context usually appears when the breakout candle is clean, price travels away from the breakout close, multiple closes hold beyond the breakout close, retest depth remains controlled, volume support is present, and target room is still readable.

When these conditions weaken, the planner can shift toward FT WATCH, WEAK FT, RETEST RISK, FAILED, or TARGET REVIEW.


📊 When to Use

• Breakout continuation review

• Range exits where post-break travel matters

• Trend continuation attempts after structure breaks

• Breakouts that need a clear failure rail and target-room reference

• Chart review workflows where the trader wants a decision state instead of another raw breakout marker


⚠️ When NOT to Use

• Low-liquidity markets with unreliable candles or volume

• Extremely noisy ranges where every breakout immediately snaps back inside

• Abnormal news spikes where ATR and structure references may distort quickly

• Situations where the user needs full trade management, position sizing, or automation


🎛️ Key Inputs

• Structure Lookback → controls the recent high/low reference used for breakout detection.

• Break Buffer ATR → defines how far price must close beyond the reference edge.

• Minimum Break Quality → filters weaker breakout candles before the planner starts.

• Follow-Through Window → controls the early review period after the breakout.

• Required Travel ATR → defines the preferred post-break travel distance.

• Maximum Clean Retest Depth ATR → controls when retest depth becomes risk.

• Failure Rail ATR → sets the analytical invalidation rail behind the breakout line.

• Target Room Range Multiple → projects the target-room guide from prior structure height.

• Visual and Panel Settings → control corridor visibility, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is intentionally chart-first.

The follow-through corridor carries the main story, while the breakout line, failure rail, and target guide create a clean level-risk-room hierarchy. Labels are compact and controlled by cooldown and maximum-visible settings so the chart remains active without becoming crowded.

The AGPro panel uses a merged blue title row and a compact decision layout for fast review.


🧪 Practical Usage Workflow

1. Read the panel to identify the current breakout side and follow-through state.

2. Check the breakout line and follow-through corridor.

3. Review whether price is traveling away, stalling, retesting too deeply, or reaching target room.

4. Use the failure rail as a structural review reference.

5. Treat the Action row as a planning prompt, not as an instruction.


🔍 Interpretation Guidelines

The Follow-Through Score should be read as context quality, not certainty.

A higher score means the breakout has cleaner post-break travel under the script's rules. A lower score means the breakout may be stalling, losing distance, retesting too deeply, or lacking enough supporting evidence.

The target-room guide does not forecast price. It gives a structured reference for whether the current path still has room to review.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an auto-trading system.

This script does not provide guaranteed signals.

This script is not a generic support/resistance map.

This script is not a Breakout Volume Quality clone.

This script is not a Breakout Retest Readiness clone.


⚠️ Limitations & Transparency

The script is rule-based and depends on the selected lookback, ATR length, timeframe, and symbol behavior.

Different markets can produce different breakout behavior. Lower timeframes may show more noise. Higher timeframes may produce fewer but cleaner events.

Volatility changes can affect corridor size, failure rail distance, target-room projection, and event frequency. Outputs should be interpreted within broader market context.


🧠 Market Context Notes

Breakout follow-through is usually most useful when structure is readable, liquidity is sufficient, and the market has enough room to travel after the break.

Volume can support the score, but the script is not built around volume alone. The central decision layer is post-break price travel and structural validity.


🧾 Use Case Examples

When price breaks above recent structure and immediately travels away with multiple closes beyond the breakout close, the planner can move from FT WATCH toward FT READY.

When price breaks but returns deeply through the breakout line before enough travel appears, the planner can mark RETEST RISK or FAIL RAIL.

When price reaches the projected target-room guide, the planner shifts to ROOM HIT so the context can be reviewed instead of blindly extended.


🧱 System Philosophy

The script is built around the AGPro decision-engine approach: structure first, quality score second, risk and target context always visible, and no promise-based signals.


🔐 Non-Promise Statement

No script can provide certainty.

No output should be treated as a guarantee.

The tool organizes breakout follow-through context so users can review price action with more structure.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions.

This script does not provide financial advice.


📚 Educational Note

Use the planner to study how breakouts behave after the first break. The value is in comparing clean follow-through, weak continuation, deep retests, and failure-rail behavior across many examples.

## Source Code

````pine
// -------------------------------------------------
// Breakout Follow-Through Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Breakout Follow-Through Planner is a chart-first breakout decision engine
// that evaluates what happens after price clears a recent structure edge.
// It maps the breakout line, follow-through corridor, failure rail, target
// room, retest-depth risk, a 0-100 Follow-Through Score, and a measured
// reach rate so traders can judge whether the breakout is traveling,
// stalling, or losing validity.
// -------------------------------------------------

//@version=6
indicator("Breakout Follow-Through Planner [AGPro Series]",
     shorttitle = "AG Pro BFT",
     overlay = true,
     max_boxes_count = 90,
     max_lines_count = 150,
     max_labels_count = 340)

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
color targetBadgeBg = color.rgb(59, 130, 246)
color mutedBadgeBg  = color.rgb(51, 65, 85)

// Luminance-based contrast: dark text on light fills, light text on dark fills
f_text_on(color fill) =>
    float r = color.r(fill)
    float g = color.g(fill)
    float b = color.b(fill)
    (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0 >= 145.0 ? color.rgb(17, 24, 39) : headerText

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects which breakout side the planner can evaluate. Auto allows both bullish and bearish follow-through plans from recent structure edges."
string ttConfirm = "Close Confirmed commits breakout plans, active path metrics, scores, states, labels, and lifecycle alerts only after bar close. Realtime allows the active visual state to update during the current bar."
string ttLookback = "Lookback used to build the recent upper and lower breakout references. The current bar is excluded so the level is based on prior structure."
string ttAtr = "ATR length used for breakout buffers, corridor height, failure rail distance, label offsets, target-room normalization, and retest-depth scoring."
string ttVolume = "Volume baseline used only as supporting evidence. This planner is not a breakout volume clone."
string ttFast = "Fast EMA used for trend-side alignment inside the score. It does not create directional commands."
string ttSlow = "Slow EMA used for broader trend context and slope support."
string ttSlope = "Number of bars used to evaluate whether the slow EMA is supporting the breakout side."
string ttBuffer = "Minimum close distance beyond the structure edge, expressed in ATR, required before a follow-through plan can start."
string ttMinHeight = "Minimum prior structure height measured in ATR. This filters structures that are too flat to create useful follow-through room."
string ttMaxHeight = "Maximum prior structure height measured in ATR. This prevents overly wide structures from dominating the planner."
string ttMinBreak = "Minimum 0-100 Break Quality required before the script can arm a follow-through corridor."
string ttBreakCooldown = "Minimum bars between new breakout plans. Higher values reduce repeated plans around the same structure edge."
string ttPlanner = "Minimum 0-100 Follow-Through Score required for the strongest FT READY state."
string ttWatch = "Minimum 0-100 Follow-Through Score required for FT WATCH while the plan is still developing."
string ttWindow = "Bars used to evaluate the first follow-through phase after the breakout."
string ttTrack = "Maximum bars a breakout plan remains active on the chart and panel."
string ttProgress = "ATR-normalized travel preferred after the breakout close before follow-through can be considered constructive."
string ttCloses = "Minimum number of closes beyond the breakout close preferred before the strongest follow-through state can appear."
string ttRetest = "Maximum clean retest depth behind the breakout line, measured in ATR. Deeper movement increases retest risk."
string ttFailure = "ATR distance behind the breakout line used to draw the failure rail. The rail is an analytical invalidation reference."
string ttTarget = "Multiple of the prior structure height used to project the target-room guide. This is a planning reference only."
string ttVolumeSupport = "Relative volume level that earns full support in the score. Volume is a secondary component, not the core signal."
string ttCorridor = "Shows the active follow-through corridor from the breakout close toward the target-room guide."
string ttBadges = "Shows a centered corridor-state badge plus owned failure-rail and target-room badges. Text is not embedded inside transparent boxes."
string ttAdaptive = "Shortens forward projection on higher timeframes so corridor objects do not dominate the chart."
string ttBadgeAnchor = "Controls where centered corridor badges sit horizontally inside the projected plan."
string ttBreakLine = "Shows the broken structure edge that anchors the current breakout plan."
string ttFailureLine = "Shows the failure rail behind the breakout line. A close through this rail marks the plan as failed."
string ttTargetLine = "Shows the target-room guide used for travel review. It is not a promised target."
string ttRefs = "Shows subtle rolling reference edges before a breakout plan starts."
string ttTint = "Tints active breakout-plan bars lightly so the state is readable without extra labels."
string ttBoxOpacity = "Transparency for the follow-through corridor. Higher values make the corridor lighter."
string ttProjection = "Number of bars projected to the right for corridor, breakout line, failure rail, and target guide."
string ttLabels = "Shows compact breakout, follow-through, weak continuation, retest-risk, failure, and target-review labels."
string ttContext = "Adds sparse context labels during active breakout plans so the chart stays informative without becoming crowded."
string ttLabelScore = "Adds the 0-100 Follow-Through Score to chart labels. Disabled by default for a cleaner publication screenshot."
string ttLabelCooldown = "Minimum bars between major event labels. Higher values reduce label clustering."
string ttContextSpacing = "Minimum bars between sparse context labels while a follow-through plan is active."
string ttMaxLabels = "Maximum number of visible chart labels retained. Older labels are removed first for performance."
string ttLabelOffset = "ATR-based vertical offset used to keep labels away from candle bodies and wicks."
string ttLabelSize = "Font size for all chart labels and centered corridor badges. Normal is the recommended publication default."
string ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
string ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark, slate, and clean light themes."
string ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "1. Breakout Structure"
sideInput = input.string("Auto", "Breakout Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = ttSide)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Realtime"], group = groupEngine, tooltip = ttConfirm)
lookbackInput = input.int(36, "Structure Lookback", minval = 10, maxval = 240, group = groupEngine, tooltip = ttLookback)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
volumeLen = input.int(34, "Volume Baseline Length", minval = 5, maxval = 300, group = groupEngine, tooltip = ttVolume)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = groupEngine, tooltip = ttSlope)

string groupBreak = "2. Breakout Qualification"
breakBufferAtr = input.float(0.18, "Break Buffer ATR", minval = 0.02, maxval = 1.50, step = 0.01, group = groupBreak, tooltip = ttBuffer)
minStructureAtr = input.float(0.75, "Minimum Structure Height ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupBreak, tooltip = ttMinHeight)
maxStructureAtr = input.float(6.50, "Maximum Structure Height ATR", minval = 1.00, maxval = 20.00, step = 0.25, group = groupBreak, tooltip = ttMaxHeight)
minBreakQuality = input.int(56, "Minimum Break Quality", minval = 25, maxval = 95, group = groupBreak, tooltip = ttMinBreak)
newBreakCooldown = input.int(12, "New Breakout Cooldown", minval = 1, maxval = 120, group = groupBreak, tooltip = ttBreakCooldown)

string groupPlanner = "3. Follow-Through Planning"
minPlannerScore = input.int(68, "Minimum Follow-Through Score", minval = 35, maxval = 95, group = groupPlanner, tooltip = ttPlanner)
watchPlannerScore = input.int(52, "Watch Score", minval = 20, maxval = 90, group = groupPlanner, tooltip = ttWatch)
followThroughWindow = input.int(7, "Follow-Through Window", minval = 2, maxval = 40, group = groupPlanner, tooltip = ttWindow)
trackingBars = input.int(28, "Active Tracking Bars", minval = 5, maxval = 120, group = groupPlanner, tooltip = ttTrack)
requiredProgressAtr = input.float(0.75, "Required Travel ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupPlanner, tooltip = ttProgress)
minimumFollowCloses = input.int(2, "Minimum Follow-Through Closes", minval = 1, maxval = 10, group = groupPlanner, tooltip = ttCloses)
maxRetestDepthAtr = input.float(0.85, "Maximum Clean Retest Depth ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupPlanner, tooltip = ttRetest)
failureRailAtr = input.float(0.45, "Failure Rail ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupPlanner, tooltip = ttFailure)
targetRangeMultiple = input.float(0.85, "Target Room Range Multiple", minval = 0.25, maxval = 3.00, step = 0.05, group = groupPlanner, tooltip = ttTarget)
fullVolumeSupport = input.float(1.60, "Full Volume Support Ratio", minval = 0.80, maxval = 5.00, step = 0.05, group = groupPlanner, tooltip = ttVolumeSupport)

string groupVisual = "4. Chart Visuals"
showCorridor = input.bool(true, "Show Follow-Through Corridor", group = groupVisual, tooltip = ttCorridor)
showCorridorBadges = input.bool(true, "Show Centered Corridor Badges", group = groupVisual, tooltip = ttBadges)
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = ttAdaptive)
zoneBadgeAnchor = input.float(0.56, "Zone Badge Anchor", minval = 0.25, maxval = 0.75, step = 0.05, group = groupVisual, tooltip = ttBadgeAnchor)
showBreakoutLine = input.bool(true, "Show Breakout Line", group = groupVisual, tooltip = ttBreakLine)
showFailureRail = input.bool(true, "Show Failure Rail", group = groupVisual, tooltip = ttFailureLine)
showTargetGuide = input.bool(true, "Show Target Room Guide", group = groupVisual, tooltip = ttTargetLine)
showReferenceEdges = input.bool(false, "Show Rolling Reference Edges", group = groupVisual, tooltip = ttRefs)
tintActiveBars = input.bool(true, "Tint Active Plan Bars", group = groupVisual, tooltip = ttTint)
boxOpacity = input.int(90, "Corridor Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttBoxOpacity)
projectionBars = input.int(26, "Forward Render Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttProjection)
showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupVisual, tooltip = ttContext)
showLabelScores = input.bool(false, "Show Label Scores", group = groupVisual, tooltip = ttLabelScore)
labelCooldownBars = input.int(12, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupVisual, tooltip = ttLabelCooldown)
contextSpacingBars = input.int(24, "Context Label Spacing", minval = 4, maxval = 160, group = groupVisual, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(10, "Maximum Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = ttLabelOffset)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = ttLabelSize)

string groupPanel = "5. Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_norm_high_good(float value, float lowValue, float highValue) =>
    highValue == lowValue ? 0.0 : f_clamp((value - lowValue) / (highValue - lowValue), 0.0, 1.0) * 100.0

f_norm_low_good(float value, float lowValue, float highValue) =>
    100.0 - f_norm_high_good(value, lowValue, highValue)

f_label_size(string sizeText) =>
    sizeText == "Tiny" ? size.tiny : sizeText == "Small" ? size.small : sizeText == "Large" ? size.large : sizeText == "Huge" ? size.huge : size.normal

f_badge_size(string sizeText) =>
    f_label_size(sizeText)

f_panel_position(string posText) =>
    posText == "Top Left" ? position.top_left :
     posText == "Top Center" ? position.top_center :
     posText == "Top Right" ? position.top_right :
     posText == "Middle Left" ? position.middle_left :
     posText == "Middle Center" ? position.middle_center :
     posText == "Middle Right" ? position.middle_right :
     posText == "Bottom Left" ? position.bottom_left :
     posText == "Bottom Center" ? position.bottom_center :
     position.bottom_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : theme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

// Guarantees panel value text stays readable on the active theme background:
// brightens too-dark colors on dark themes, darkens too-light colors on light.
f_readable(color c, string theme) =>
    float lum = (color.r(c) * 299.0 + color.g(c) * 587.0 + color.b(c) * 114.0) / 1000.0
    theme == "Clean Light" ? (lum > 140.0 ? color.rgb(15, 23, 42) : c) : (lum < 96.0 ? panelValueCol : c)

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : theme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_score_text(float score) =>
    na(score) ? "n/a" : str.tostring(int(math.round(score)))

f_grade(float score) =>
    na(score) ? "" : score >= 86 ? "A" : score >= 72 ? "B" : score >= 56 ? "C" : "D"

f_atr_text(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + " ATR"

f_score_color(float score, int side) =>
    color baseColor = side == 1 ? bullColor : side == -1 ? bearColor : neutralColor
    na(score) ? panelLabelCol : score >= 82 ? accentColor : score >= 68 ? baseColor : score >= 52 ? neutralColor : color.new(baseColor, 18)

f_direction_color(int side) =>
    side == 1 ? bullColor : side == -1 ? bearColor : neutralColor

f_state_color(string stateText, int side, float score) =>
    stateText == "FAILED" ? dangerColor :
     stateText == "WEAK FT" ? neutralColor :
     stateText == "RETEST RISK" ? neutralColor :
     stateText == "TARGET REVIEW" ? accentColor :
     stateText == "EXPIRED" ? mutedBadgeBg :
     stateText == "FT READY" ? f_score_color(score, side) :
     stateText == "FT WATCH" ? f_score_color(score, side) :
     stateText == "BREAK ARMED" ? f_direction_color(side) :
     panelValueCol

f_side_text(int side) =>
    side == 1 ? "Bull Break" : side == -1 ? "Bear Break" : "No Active"

f_risk_text(float depthAtr) =>
    na(depthAtr) ? "n/a" : depthAtr >= maxRetestDepthAtr ? "High" : depthAtr >= maxRetestDepthAtr * 0.62 ? "Medium" : "Low"

f_badge_bg(string stateText, int side, float score) =>
    stateText == "TARGET REVIEW" ? targetBadgeBg : stateText == "EXPIRED" ? mutedBadgeBg : f_state_color(stateText, side, score)

f_panel_row(table panelId, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(panelId, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(panelId, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_clear_labels(array<label> labels) =>
    while array.size(labels) > 0
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_trim_lines(array<line> lines, int maxCount) =>
    while array.size(lines) > maxCount
        line oldLine = array.shift(lines)
        if not na(oldLine)
            line.delete(oldLine)

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.shift(boxes)
        if not na(oldBox)
            box.delete(oldBox)

f_clear_boxes(array<box> boxes) =>
    while array.size(boxes) > 0
        box oldBox = array.shift(boxes)
        if not na(oldBox)
            box.delete(oldBox)

f_clear_lines(array<line> lines) =>
    while array.size(lines) > 0
        line oldLine = array.shift(lines)
        if not na(oldLine)
            line.delete(oldLine)

f_set_badge(label badge, int xValue, float yValue, string textValue, color badgeColor, string sizeText) =>
    label.set_xy(badge, xValue, yValue)
    label.set_text(badge, textValue)
    label.set_color(badge, badgeColor)
    label.set_textcolor(badge, f_text_on(badgeColor))
    label.set_style(badge, label.style_label_center)
    label.set_size(badge, f_badge_size(sizeText))

f_trend_score(int side, float priceValue, float fastValue, float slowValue, float slopeValue, float atrValue) =>
    float priceScore = side == 1 ? (priceValue >= slowValue ? 36.0 : 12.0) : (priceValue <= slowValue ? 36.0 : 12.0)
    float stackScore = side == 1 ? (fastValue >= slowValue ? 34.0 : 0.0) : (fastValue <= slowValue ? 34.0 : 0.0)
    float slopeAtr = math.abs(slopeValue) / math.max(atrValue, syminfo.mintick)
    float slopeScore = side == 1 ? (slopeValue >= 0.0 ? f_norm_high_good(slopeAtr, 0.01, 0.28) * 0.30 : 0.0) : (slopeValue <= 0.0 ? f_norm_high_good(slopeAtr, 0.01, 0.28) * 0.30 : 0.0)
    f_clamp(priceScore + stackScore + slopeScore, 0.0, 100.0)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyShare = bodySize / barRange
closeLocation = (close - low) / barRange
bullCloseEdge = closeLocation
bearCloseEdge = 1.0 - closeLocation

volumeBase = ta.sma(volume, volumeLen)
relVolume = not na(volumeBase) and volumeBase > 0.0 and not na(volume) ? volume / volumeBase : 1.0
fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)
trendSlope = slowEma - nz(slowEma[slopeBars], slowEma)

upperRef = ta.highest(high[1], lookbackInput)
lowerRef = ta.lowest(low[1], lookbackInput)
structureHeight = upperRef - lowerRef
structureAtr = structureHeight / safeAtr
validStructure = not na(upperRef) and not na(lowerRef) and structureAtr >= minStructureAtr and structureAtr <= maxStructureAtr

confirmedBar = confirmationMode == "Realtime" or barstate.isconfirmed
allowBull = sideInput != "Bearish Only"
allowBear = sideInput != "Bullish Only"
var int lastBreakoutBar = na
cooldownReady = na(lastBreakoutBar) or bar_index - lastBreakoutBar >= newBreakCooldown

breakDistanceBull = (close - upperRef) / safeAtr
breakDistanceBear = (lowerRef - close) / safeAtr
breakDistScoreBull = f_norm_high_good(breakDistanceBull, breakBufferAtr, breakBufferAtr + 0.90)
breakDistScoreBear = f_norm_high_good(breakDistanceBear, breakBufferAtr, breakBufferAtr + 0.90)
bodyScore = f_norm_high_good(bodyShare, 0.28, 0.82)
bullCloseScore = f_norm_high_good(bullCloseEdge, 0.55, 0.95)
bearCloseScore = f_norm_high_good(bearCloseEdge, 0.55, 0.95)
volumeSupportScore = f_norm_high_good(relVolume, 0.75, fullVolumeSupport)
structureScore = structureAtr <= (minStructureAtr + maxStructureAtr) * 0.50 ? f_norm_high_good(structureAtr, minStructureAtr, minStructureAtr + 1.80) : f_norm_low_good(structureAtr, maxStructureAtr - 2.25, maxStructureAtr)
bullTrendScore = f_trend_score(1, close, fastEma, slowEma, trendSlope, safeAtr)
bearTrendScore = f_trend_score(-1, close, fastEma, slowEma, trendSlope, safeAtr)

bullBreakQuality = f_clamp(breakDistScoreBull * 0.20 + bodyScore * 0.18 + bullCloseScore * 0.18 + volumeSupportScore * 0.12 + bullTrendScore * 0.18 + structureScore * 0.14, 0.0, 100.0)
bearBreakQuality = f_clamp(breakDistScoreBear * 0.20 + bodyScore * 0.18 + bearCloseScore * 0.18 + volumeSupportScore * 0.12 + bearTrendScore * 0.18 + structureScore * 0.14, 0.0, 100.0)

bullBreakCandidate = confirmedBar and allowBull and validStructure and cooldownReady and close > upperRef + safeAtr * breakBufferAtr and bullBreakQuality >= minBreakQuality
bearBreakCandidate = confirmedBar and allowBear and validStructure and cooldownReady and close < lowerRef - safeAtr * breakBufferAtr and bearBreakQuality >= minBreakQuality
candidateSide = bullBreakCandidate and (not bearBreakCandidate or bullBreakQuality >= bearBreakQuality) ? 1 : bearBreakCandidate ? -1 : 0
candidateQuality = candidateSide == 1 ? bullBreakQuality : candidateSide == -1 ? bearBreakQuality : na

// -------------------------------------------------
// Active planner state
// -------------------------------------------------
var int activeSide = 0
var int activeStartBar = na
var float activeLevel = na
var float activeBreakClose = na
var float activeBreakQuality = na
var float activeAtr = na
var float activeTarget = na
var float activeFailureRail = na
var float activeBestProgressAtr = 0.0
var float activeDeepestRetestAtr = 0.0
var float activeScore = na
var int activeFollowCloses = 0
var int lastCountedBar = na
var int lastContextLabelBar = na
var int lastMajorLabelBar = na
var string activeState = "WAITING"
var string activeAction = "Wait for qualified breakout"

// Reach-rate proof state
var int   bftWins = 0
var int   bftLoss = 0
var bool  planResolved = false

var box corridorBox = na
var line breakoutLine = na
var line failureLine = na
var line targetLine = na
var label corridorBadge = na
var label targetBadge = na
var label failureBadge = na
var array<label> eventLabels = array.new<label>()
var array<label> planBadges = array.new<label>()
var array<line> guideLines = array.new<line>()
var array<box> corridorBoxes = array.new<box>()

// Shared anti-collision registry for chart event labels
var array<int> lblBars = array.new<int>()
var array<float> lblYs = array.new<float>()

f_lbl_register(int bx, float yy) =>
    array.push(lblBars, bx)
    array.push(lblYs, yy)
    while array.size(lblBars) > 50
        array.shift(lblBars)
        array.shift(lblYs)

f_lbl_resolve(int bx, float baseY, int dirPush) =>
    float y = baseY
    float sep = safeAtr * 0.72
    float maxShift = safeAtr * 0.90
    int barWin = 8
    int guard = 0
    bool clash = true
    while clash and guard < 4
        clash := false
        int n = array.size(lblBars)
        if n > 0
            for i = 0 to n - 1
                if math.abs(bx - array.get(lblBars, i)) <= barWin and math.abs(y - array.get(lblYs, i)) < sep
                    y := f_clamp(y + dirPush * sep, baseY - maxShift, baseY + maxShift)
                    clash := true
        guard += 1
    y

f_event_limit() =>
    int timeframeLimit = timeframe.in_seconds() >= 14400 ? 5 : timeframe.in_seconds() >= 3600 ? 6 : maxVisibleLabels
    math.min(maxVisibleLabels, timeframeLimit)

previousState = activeState
newBreakoutEvent = candidateSide != 0
readyEvent = false
watchEvent = false
weakEvent = false
riskEvent = false
failedEvent = false
targetEvent = false
expiredEvent = false

baseProjection = adaptiveProjection and not timeframe.isintraday ? math.max(10, int(math.round(projectionBars * 0.70))) : projectionBars
activeProjection = math.max(8, baseProjection)

if newBreakoutEvent
    activeSide := candidateSide
    activeStartBar := bar_index
    activeLevel := candidateSide == 1 ? upperRef : lowerRef
    activeBreakClose := close
    activeBreakQuality := candidateQuality
    activeAtr := safeAtr
    activeBestProgressAtr := 0.0
    activeDeepestRetestAtr := 0.0
    activeFollowCloses := 0
    activeScore := candidateQuality
    activeState := "BREAK ARMED"
    activeAction := "Track follow-through"
    planResolved := false
    lastBreakoutBar := bar_index
    lastCountedBar := bar_index
    float targetDistance = math.max(structureHeight * targetRangeMultiple, safeAtr * requiredProgressAtr * 1.50)
    activeTarget := activeBreakClose + activeSide * targetDistance
    activeFailureRail := activeLevel - activeSide * safeAtr * failureRailAtr

    f_clear_boxes(corridorBoxes)
    f_clear_lines(guideLines)
    f_clear_labels(planBadges)
    corridorBox := na
    breakoutLine := na
    failureLine := na
    targetLine := na
    corridorBadge := na
    targetBadge := na
    failureBadge := na

    color planColor = f_direction_color(activeSide)
    int rightEdge = bar_index + activeProjection
    int badgeX = bar_index + int(math.round(activeProjection * zoneBadgeAnchor))
    int targetBadgeX = bar_index + activeProjection
    float corridorTop = activeSide == 1 ? activeTarget : activeBreakClose
    float corridorBottom = activeSide == 1 ? activeBreakClose : activeTarget
    if showCorridor
        corridorBox := box.new(left = activeStartBar, top = corridorTop, right = rightEdge, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(planColor, boxOpacity), border_color = color.new(planColor, 34), border_width = 1)
        array.push(corridorBoxes, corridorBox)
        f_trim_boxes(corridorBoxes, 1)
    if showCorridorBadges
        corridorBadge := label.new(badgeX, (corridorTop + corridorBottom) * 0.5, "BREAK ARMED\nQ " + f_score_text(activeScore) + " | GRADE " + f_grade(activeScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(f_badge_bg(activeState, activeSide, activeScore), 8), textcolor = f_text_on(f_badge_bg(activeState, activeSide, activeScore)), size = f_badge_size(labelSizeInput), textalign = text.align_center)
        array.push(planBadges, corridorBadge)
        f_trim_labels(planBadges, 2)
    if showBreakoutLine
        breakoutLine := line.new(activeStartBar, activeLevel, rightEdge, activeLevel, xloc = xloc.bar_index, color = color.new(planColor, 0), width = 2)
        array.push(guideLines, breakoutLine)
    if showFailureRail
        failureLine := line.new(activeStartBar, activeFailureRail, rightEdge, activeFailureRail, xloc = xloc.bar_index, color = color.new(dangerColor, 0), width = 1, style = line.style_dashed)
        array.push(guideLines, failureLine)
        if showCorridorBadges
            failureBadge := label.new(rightEdge, activeFailureRail, "FAIL RAIL " + str.tostring(activeFailureRail, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 4), textcolor = f_text_on(dangerColor), size = f_badge_size(labelSizeInput))
            array.push(planBadges, failureBadge)
            f_trim_labels(planBadges, 3)
    if showTargetGuide
        targetLine := line.new(activeStartBar, activeTarget, rightEdge, activeTarget, xloc = xloc.bar_index, color = color.new(targetBadgeBg, 0), width = 1, style = line.style_dotted)
        array.push(guideLines, targetLine)
        if showCorridorBadges
            targetBadge := label.new(targetBadgeX, activeTarget, "TARGET ROOM", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(targetBadgeBg, 6), textcolor = f_text_on(targetBadgeBg), size = f_badge_size(labelSizeInput))
            array.push(planBadges, targetBadge)
            f_trim_labels(planBadges, 3)
    f_trim_lines(guideLines, 3)

    if showLabels
        string textValue = activeSide == 1 ? "BFT UP" : "BFT DN"
        textValue += showLabelScores ? "\n" + f_score_text(activeScore) : ""
        float yBase = activeSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        float yValue = f_lbl_resolve(bar_index, yBase, activeSide == 1 ? -1 : 1)
        f_lbl_register(bar_index, yValue)
        styleValue = activeSide == 1 ? label.style_label_up : label.style_label_down
        label eventLabel = label.new(bar_index, yValue, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = styleValue, color = color.new(planColor, 6), textcolor = f_text_on(planColor), size = f_label_size(labelSizeInput), tooltip = "Breakout Follow-Through Planner: a qualified breakout started a follow-through review.")
        array.push(eventLabels, eventLabel)
        f_trim_labels(eventLabels, f_event_limit())
        lastMajorLabelBar := bar_index

// -------------------------------------------------
// Active follow-through evaluation
// -------------------------------------------------
hasActivePlan = activeSide != 0 and not na(activeStartBar)
if hasActivePlan
    int barsActive = bar_index - activeStartBar
    float progressAtr = activeSide == 1 ? (high - activeBreakClose) / activeAtr : (activeBreakClose - low) / activeAtr
    float retestDepthAtr = activeSide == 1 ? math.max(0.0, (activeLevel - low) / activeAtr) : math.max(0.0, (high - activeLevel) / activeAtr)
    if confirmedBar
        activeBestProgressAtr := math.max(activeBestProgressAtr, progressAtr)
        activeDeepestRetestAtr := math.max(activeDeepestRetestAtr, retestDepthAtr)

    if barstate.isconfirmed and bar_index > activeStartBar and bar_index != lastCountedBar
        bool followClose = activeSide == 1 ? close > activeBreakClose : close < activeBreakClose
        if followClose
            activeFollowCloses += 1
        lastCountedBar := bar_index

    bool failureHit = activeSide == 1 ? close < activeFailureRail : close > activeFailureRail
    bool targetReached = activeSide == 1 ? high >= activeTarget : low <= activeTarget
    bool activeWindowMature = barsActive >= followThroughWindow
    bool retestDepthHigh = activeDeepestRetestAtr >= maxRetestDepthAtr

    // Reach-rate proof: count each plan once on confirmed bars.
    // Target reached first = win, failure rail first = loss, expiry = uncounted.
    if barstate.isconfirmed and not planResolved
        if failureHit
            bftLoss += 1
            planResolved := true
        else if targetReached
            bftWins += 1
            planResolved := true
        else if barsActive > trackingBars
            planResolved := true

    float progressScore = f_norm_high_good(activeBestProgressAtr, 0.0, requiredProgressAtr * 1.35)
    float closeCountScore = f_norm_high_good(activeFollowCloses, 0.0, minimumFollowCloses)
    float retestScore = f_norm_low_good(activeDeepestRetestAtr, 0.0, maxRetestDepthAtr)
    float roomRemainingAtr = activeSide == 1 ? (activeTarget - close) / activeAtr : (close - activeTarget) / activeAtr
    float roomScore = targetReached ? 100.0 : f_norm_high_good(roomRemainingAtr, 0.0, requiredProgressAtr * 2.0)
    float liveVolumeScore = f_norm_high_good(relVolume, 0.75, fullVolumeSupport)
    float nextScore = f_clamp(activeBreakQuality * 0.24 + progressScore * 0.26 + closeCountScore * 0.16 + retestScore * 0.18 + roomScore * 0.08 + liveVolumeScore * 0.08, 0.0, 100.0)
    if confirmedBar
        activeScore := nextScore

    string nextState = "FT WATCH"
    string nextAction = "Keep reviewing path"
    if failureHit
        nextState := "FAILED"
        nextAction := "Stop tracking plan"
    else if targetReached
        nextState := "TARGET REVIEW"
        nextAction := "Review target room"
    else if retestDepthHigh
        nextState := "RETEST RISK"
        nextAction := "Watch failure rail"
    else if activeWindowMature and (activeBestProgressAtr < requiredProgressAtr or activeFollowCloses < minimumFollowCloses)
        nextState := "WEAK FT"
        nextAction := "Downgrade continuation"
    else if activeScore >= minPlannerScore and activeBestProgressAtr >= requiredProgressAtr and activeFollowCloses >= minimumFollowCloses
        nextState := "FT READY"
        nextAction := "Validate with context"
    else if activeScore >= watchPlannerScore
        nextState := "FT WATCH"
        nextAction := "Monitor follow-through"
    else
        nextState := "BREAK ARMED"
        nextAction := "Wait for travel"

    if barsActive > trackingBars and not failureHit and not targetReached
        nextState := "EXPIRED"
        nextAction := "Wait for new break"

    if confirmedBar
        activeState := nextState
        activeAction := nextAction

        readyEvent := activeState == "FT READY" and previousState != "FT READY"
        watchEvent := activeState == "FT WATCH" and previousState == "BREAK ARMED"
        weakEvent := activeState == "WEAK FT" and previousState != "WEAK FT"
        riskEvent := activeState == "RETEST RISK" and previousState != "RETEST RISK"
        failedEvent := activeState == "FAILED" and previousState != "FAILED"
        targetEvent := activeState == "TARGET REVIEW" and previousState != "TARGET REVIEW"
        expiredEvent := activeState == "EXPIRED" and previousState != "EXPIRED"

    color activeColor = f_state_color(activeState, activeSide, activeScore)
    int rightEdge = bar_index + activeProjection
    int badgeX = bar_index + int(math.round(activeProjection * zoneBadgeAnchor))
    if not na(corridorBox)
        box.set_right(corridorBox, rightEdge)
        box.set_bgcolor(corridorBox, color.new(activeColor, boxOpacity))
        box.set_border_color(corridorBox, color.new(activeColor, 34))
    if not na(corridorBadge) and showCorridorBadges
        float badgeY = activeSide == 1 ? (math.min(activeTarget, activeBreakClose) + math.max(activeTarget, activeBreakClose)) * 0.5 : (math.min(activeTarget, activeBreakClose) + math.max(activeTarget, activeBreakClose)) * 0.5
        string corridorText = activeState == "RETEST RISK" ? activeState + "\nQ " + f_score_text(activeScore) + " | DEPTH " + f_atr_text(activeDeepestRetestAtr) : activeState + "\nQ " + f_score_text(activeScore) + " | GRADE " + f_grade(activeScore)
        f_set_badge(corridorBadge, badgeX, badgeY, corridorText, color.new(f_badge_bg(activeState, activeSide, activeScore), 8), labelSizeInput)
    if not na(breakoutLine)
        line.set_x2(breakoutLine, rightEdge)
    if not na(failureLine)
        line.set_x2(failureLine, rightEdge)
    if not na(failureBadge)
        label.set_x(failureBadge, rightEdge)
        label.set_y(failureBadge, activeFailureRail)
        label.set_text(failureBadge, "FAIL RAIL " + str.tostring(activeFailureRail, format.mintick))
        label.set_size(failureBadge, f_badge_size(labelSizeInput))
    if not na(targetLine)
        line.set_x2(targetLine, rightEdge)
    if not na(targetBadge)
        label.set_x(targetBadge, rightEdge)
        label.set_y(targetBadge, activeTarget)
        label.set_color(targetBadge, color.new(targetBadgeBg, activeState == "TARGET REVIEW" ? 0 : 6))

    bool criticalEvent = failedEvent or targetEvent
    bool majorAllowed = showLabels and (criticalEvent or na(lastMajorLabelBar) or bar_index - lastMajorLabelBar >= labelCooldownBars)
    string majorText = readyEvent ? "FT READY" : weakEvent ? "WEAK FT" : riskEvent ? "RETEST RISK" : failedEvent ? "BREAK FAILED" : targetEvent ? "ROOM HIT" : expiredEvent ? "EXPIRE" : ""
    bool majorRisk = weakEvent or riskEvent or failedEvent or expiredEvent
    if majorAllowed and majorText != ""
        majorText += showLabelScores and not failedEvent and not expiredEvent ? "\n" + f_score_text(activeScore) : ""
        float yBase = activeSide == 1 ? (majorRisk ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr) : (majorRisk ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr)
        styleValue = activeSide == 1 ? (majorRisk ? label.style_label_down : label.style_label_up) : (majorRisk ? label.style_label_up : label.style_label_down)
        int pushDir = styleValue == label.style_label_down ? 1 : -1
        float yValue = f_lbl_resolve(bar_index, yBase, pushDir)
        f_lbl_register(bar_index, yValue)
        color labelColor = failedEvent ? dangerColor : riskEvent or weakEvent or expiredEvent ? neutralColor : targetEvent ? targetBadgeBg : f_direction_color(activeSide)
        label newLabel = label.new(bar_index, yValue, majorText, xloc = xloc.bar_index, yloc = yloc.price, style = styleValue, color = color.new(labelColor, 7), textcolor = f_text_on(labelColor), size = f_label_size(labelSizeInput), tooltip = "Breakout Follow-Through Planner: " + activeState + " state was reached.")
        array.push(eventLabels, newLabel)
        f_trim_labels(eventLabels, f_event_limit())
        lastMajorLabelBar := bar_index

    bool contextAllowed = showContextLabels and showLabels and activeState != "FAILED" and activeState != "EXPIRED" and barsActive > 1 and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
    if contextAllowed
        string contextText = activeState == "FT READY" ? "PATH OK" : activeState == "TARGET REVIEW" ? "ROOM" : activeState == "RETEST RISK" ? "DEPTH" : "TRACK"
        contextText += showLabelScores ? "\n" + f_score_text(activeScore) : ""
        float contextBase = activeSide == 1 ? low - safeAtr * labelOffsetAtr * 0.72 : high + safeAtr * labelOffsetAtr * 0.72
        float contextY = f_lbl_resolve(bar_index, contextBase, activeSide == 1 ? -1 : 1)
        f_lbl_register(bar_index, contextY)
        contextStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
        label contextLabel = label.new(bar_index, contextY, contextText, xloc = xloc.bar_index, yloc = yloc.price, style = contextStyle, color = color.new(activeColor, 18), textcolor = f_text_on(activeColor), size = f_label_size(labelSizeInput), tooltip = "Sparse follow-through context label.")
        array.push(eventLabels, contextLabel)
        f_trim_labels(eventLabels, f_event_limit())
        lastContextLabelBar := bar_index

// -------------------------------------------------
// Reach-rate readout
// -------------------------------------------------
bftTotal = bftWins + bftLoss
bftRate = bftTotal > 0 ? bftWins / bftTotal * 100.0 : na
bftText = bftTotal == 0 ? "Scanning" : bftTotal < 6 ? "Building (" + str.tostring(bftTotal) + ")" : str.tostring(bftRate, "#") + "% (" + str.tostring(bftTotal) + ")"
bftColor = bftTotal < 6 ? neutralColor : bftRate >= 55.0 ? bullColor : bftRate >= 45.0 ? accentColor : neutralColor

// -------------------------------------------------
// Optional references and bar tint
// -------------------------------------------------
plot(showReferenceEdges ? upperRef : na, "Upper Breakout Reference", color = color.new(bullColor, 62), linewidth = 1, style = plot.style_linebr)
plot(showReferenceEdges ? lowerRef : na, "Lower Breakout Reference", color = color.new(bearColor, 62), linewidth = 1, style = plot.style_linebr)

activeTint = hasActivePlan and activeSide != 0 and tintActiveBars ? color.new(f_state_color(activeState, activeSide, activeScore), 84) : na
barcolor(activeTint)

// -------------------------------------------------
// Panel
// -------------------------------------------------
color panelBgActive = f_panel_bg(panelThemeInput)
color panelBorderActive = f_panel_border(panelThemeInput)
var table panel = table.new(f_panel_position(panelLocationInput), 2, 7, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Breakout Follow-Through Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)

        bool panelActive = hasActivePlan and activeSide != 0
        string sideText = panelActive ? f_side_text(activeSide) : "Scanning"
        string ftText = panelActive and not na(activeScore) ? activeState + " / " + f_score_text(activeScore) + " " + f_grade(activeScore) : "Waiting"
        string riskText = panelActive ? f_risk_text(activeDeepestRetestAtr) + " / " + f_atr_text(activeDeepestRetestAtr) : "n/a"
        float targetRoomAtr = panelActive and not na(activeTarget) ? (activeSide == 1 ? (activeTarget - close) / activeAtr : (close - activeTarget) / activeAtr) : na
        string targetText = activeState == "TARGET REVIEW" ? "Reached" : panelActive ? f_atr_text(math.max(targetRoomAtr, 0.0)) : "n/a"
        string actionText = panelActive ? activeAction : "Wait for qualified break"
        color stateColor = panelActive ? f_state_color(activeState, activeSide, activeScore) : f_panel_value(panelThemeInput)
        color sideColor = panelActive ? f_direction_color(activeSide) : f_panel_value(panelThemeInput)
        color riskColor = activeDeepestRetestAtr >= maxRetestDepthAtr ? dangerColor : activeDeepestRetestAtr >= maxRetestDepthAtr * 0.62 ? neutralColor : bullColor
        color targetColor = activeState == "TARGET REVIEW" ? targetBadgeBg : f_panel_value(panelThemeInput)

        f_panel_row(panel, 1, "Breakout Side", sideText, f_readable(sideColor, panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Follow-Through", ftText, f_readable(stateColor, panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Reach Rate", bftText, f_readable(bftColor, panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Retest Risk", riskText, f_readable(panelActive ? riskColor : f_panel_value(panelThemeInput), panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Target Room", targetText, f_readable(targetColor, panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Action", actionText, f_readable(stateColor, panelThemeInput), panelThemeInput, panelFontSizeInput)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newBreakoutEvent and activeSide == 1, title = "Bullish Breakout Follow-Through Plan", message = "Breakout Follow-Through Planner: a bullish breakout started a follow-through review.")
alertcondition(newBreakoutEvent and activeSide == -1, title = "Bearish Breakout Follow-Through Plan", message = "Breakout Follow-Through Planner: a bearish breakout started a follow-through review.")
alertcondition(readyEvent, title = "Follow-Through Ready", message = "Breakout Follow-Through Planner: follow-through quality reached the FT READY state. This is an attention marker, not a trade instruction.")
alertcondition(riskEvent or weakEvent, title = "Weak Follow-Through Or Retest Risk", message = "Breakout Follow-Through Planner: the active breakout path is showing weak follow-through or elevated retest-depth risk.")
alertcondition(failedEvent, title = "Failure Rail Hit", message = "Breakout Follow-Through Planner: price closed through the failure rail after a breakout plan.")
alertcondition(targetEvent, title = "Target Room Review", message = "Breakout Follow-Through Planner: the active breakout path reached the target-room guide and should be reviewed.")
````
