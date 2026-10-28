# Opening Drive Quality [AGPro Series]

- url: https://www.tradingview.com/script/6Ybt9Fyd-Opening-Drive-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;5e168fc2d46f4340bbdd8f5071c267ad
- version: 4.0

## Description

Opening Drive Quality [AGPro Series]


🧠 Core Idea

Is the first directional drive of the session strong enough to plan around, or is it already losing execution quality?


📌 Overview / What it does

Opening Drive Quality is a session execution planner that evaluates the first directional drive after the market opens. It studies the opening drive channel, early follow-through, pullback acceptance, risk-line integrity, and target-room structure in one clean decision framework.

The script produces a 0-100 quality score, a clear next-action state, an opening drive channel, a pullback acceptance zone, an invalidation risk line, target guide, compact chart labels, alerts, and a premium AGPro panel.

It does not predict price direction, automate trades, or mark every opening range breakout. Its purpose is to help traders evaluate whether the early session drive has enough structure, acceptance, and risk clarity to deserve attention.


🎯 Purpose & Design Philosophy

The script was built for traders who need more than an opening range box or a simple breakout marker. The first session move often sets the tone, but the useful question is not only whether price moved. The useful question is whether that move produced clean follow-through, controllable risk, and a meaningful pullback area.

Opening Drive Quality fills that gap by turning the opening move into a structured planning map. It supports traders who study session execution, intraday momentum, and pullback planning without relying on generic signals.

The design philosophy is simple: evaluate the quality of the first drive, define the risk line, project the pullback acceptance zone, and make the next state readable at a glance.


⚡ Why This Script Is Different

Most tools focus on opening range breakouts, session boxes, fixed kill zones, or failed-break signals.

This script does NOT try to clone a generic ORB tool, a kill-zone session engine, or an opening range failure map.

Instead, it focuses on the quality of the first directional drive itself. It asks whether the drive has real thrust, whether follow-through appears after the drive locks, whether price accepts a pullback zone, where the risk line sits, and what the next planning state should be.


⚙️ Methodology

1. Context Detection

The script builds the opening drive from either a fixed session window or the first bars of a new day. This keeps the tool useful across regular-market assets and 24/7 markets.

2. Reference Mapping

After the drive locks, the script maps the opening drive channel, pullback acceptance zone, invalidation risk line, and target-room guide. These references come from the opening drive structure, not from generic support and resistance pivots.

3. Reaction Evaluation

The engine scores drive thrust, close location, range expansion, optional relative volume, follow-through distance, pullback behavior, and risk-line integrity.

4. Visual Output

The chart shows the active drive channel, projected pullback zone, risk line, target guide, state labels, and a compact panel with the key planning reads.


🗺️ How to Read the Chart

Opening Drive Channel = the locked first directional drive of the session.

Pullback Acceptance Zone = the area where a controlled pullback can be evaluated after a valid drive.

Risk Line = the invalidation line derived from the drive base, pullback zone, and ATR buffer.

Target Guide = a projected target-room reference based on the opening drive range.

Labels = compact markers for drive lock, follow-through, pullback acceptance, weak drive, risk break, and target check.

Colors = teal for bullish drive context, pink for bearish drive context, amber for review states, and indigo for structural emphasis.

Panel = the decision layer showing Drive Side, Follow-Through, Pullback Quality, Risk Line, and Action.


🚦 Signals & States

• DRIVE Q → the opening drive has locked and received a 0-100 quality score.

• FOLLOW Q → the drive has produced directional follow-through after locking.

• PULLBACK ACCEPTED → price is reacting constructively inside the projected pullback acceptance zone.

• WEAK DRIVE → follow-through has not developed inside the review window.

• RISK BROKEN → the active drive has violated its invalidation line.

• TARGET CHECK → price has reached the projected target-room guide.


🔔 Alerts Logic

The script includes alerts for:

• Opening Drive Quality Locked → a qualified opening drive has completed.

• Drive Follow-Through → directional extension appears after the drive locks.

• Pullback Accepted → price reacts inside the projected pullback acceptance zone.

• Risk Line Broken → price violates the active drive risk line.

• Target Guide Reached → price reaches the projected target-room guide.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when opening drive thrust, close location, session volatility, relative volume, follow-through, and pullback acceptance align.

The context becomes weaker when the opening drive locks with poor thrust, cannot extend, pulls back too deeply, or breaks the risk line.


📊 When to Use

• Intraday session planning.

• Opening-drive analysis after the first market push.

• Markets where the opening session often defines early direction.

• Pullback planning after a strong first drive.

• Session review where risk line and target-room context matter.


⚠️ When NOT to Use

• Very low-liquidity markets.

• Extremely noisy opens with unstable spreads.

• News-driven bars where the first drive is unusually distorted.

• Assets where the selected opening session is not meaningful.

• Higher timeframes where the opening drive window has no practical session context.


🎛️ Key Inputs

• Opening Drive Mode → chooses first bars of day or a fixed session window. First Bars Of Day is the default so the chart loads with visible drive structure across more symbols.

• Opening Drive Session → defines the drive-building window.

• Tracking Session → defines when follow-through and pullback logic remains active.

• Minimum Quality Threshold → controls when stronger planning labels appear.

• Follow-Through ATR → defines the extension needed for follow-through confirmation.

• Pullback Acceptance Depth → controls the projected pullback zone depth.

• Risk Line Buffer ATR → adjusts the invalidation line beyond the drive structure.

• Target Guide Multiple → controls the projected target-room guide.

• Panel / Label Settings → control panel location, theme, font size, label size, visible label count, minimum label quality, label cooldown, and optional compact plot markers.


🖥️ Interface & Visual Design

The interface is built around a clean AGPro panel and chart-first planning visuals. The panel uses a single merged blue header row with only the script name, then five practical rows: Drive Side, Follow-Through, Pullback Quality, Risk Line, and Action.

The chart uses one opening drive channel, one pullback acceptance zone, one risk line, one target guide, and compact labels. The goal is a premium session-planning view without clutter.


🧪 Practical Usage Workflow

1. Read the panel after the opening drive locks.

2. Check whether the drive side and score show a valid planning context.

3. Watch follow-through quality after the drive locks.

4. Evaluate whether price pulls back into the acceptance zone constructively.

5. Use the risk line and target guide as planning references, not automatic decisions.


🔍 Interpretation Guidelines

A strong score means the opening drive has better structure, cleaner close location, stronger volatility context, and better follow-through support.

A pullback acceptance label means price is reacting inside the projected drive-based zone. It does not mean price must continue.

A risk-line break means the original drive plan has lost structural integrity and should be reassessed.

The most useful interpretation comes from combining the panel state with broader market context, liquidity, and timeframe alignment.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not an auto-trading system.

• Not guaranteed signals.

• Not a generic support and resistance mapper.

• Not a clone of an ORB breakout tool.

• Not a kill-zone timing dashboard.

• Not an opening range failure scanner.


⚠️ Limitations & Transparency

Timeframe selection affects the opening drive shape. A 5-minute chart and a 15-minute chart can produce different drive channels.

Volatility changes can expand or compress the pullback zone and risk line.

Session definitions matter. The selected opening window should match the asset being studied.

High-impact news, abnormal spreads, and low liquidity can reduce the reliability of the opening drive map.


🧠 Market Context Notes

Opening drives are most useful when liquidity is active and the first session push creates a clear directional reference. A clean drive does not guarantee continuation, but it can create a structured area for evaluating pullback acceptance and invalidation.

The script intentionally keeps its references tied to the opening drive. It avoids pivot maps, order block language, broad S/R zones, and generic failed-break logic.


🧾 Use Case Examples

When price locks a strong bullish opening drive, extends beyond the channel, and then pulls back into the acceptance zone without breaking the risk line, the panel may shift toward a constructive planning state.

When price locks a drive but cannot create follow-through inside the review window, the script can mark the drive as weak and shift the action state toward bias reduction.

When price violates the risk line, the original opening drive plan is no longer structurally intact inside this model.


🧱 System Philosophy

Opening Drive Quality follows the AGPro decision-engine philosophy: a script should help the trader evaluate validity, strength, risk, target room, and next state instead of only printing another signal.

The tool is designed to make the opening session easier to interpret through structured references and clean visual hierarchy.


🔐 Non-Promise Statement

No script can provide certainty.

No opening drive model can guarantee continuation, reversal, or profitability.

This script provides structured context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use this script as an educational planning and visualization tool. The strongest use comes from reading the opening drive together with broader market structure, liquidity, volatility, and personal risk rules.

## Source Code

````pine
// -------------------------------------------------
// Opening Drive Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.9
//
// Opening Drive Quality evaluates the first directional session drive,
// follow-through strength, pullback acceptance, risk line integrity, and
// target room after the open. It is designed as a session execution planner,
// not a generic opening range breakout marker, kill-zone map, or failed
// breakout scanner. It maps drive quality, follow-through, pullback acceptance,
// risk-line integrity, and action state for structured opening-session planning.
// V1.9 consolidates overlapping active-structure badges and adds explicit
// right-edge identification for the projected target and risk guides while
// preserving the V1.8 scoring and confirmation-anchored proof engine.
// -------------------------------------------------

//@version=6
indicator("Opening Drive Quality [AGPro Series]",
     shorttitle = "AG Pro ODQ",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 100,
     max_lines_count = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupSession = "Session"
driveMode = input.string("First Bars Of Day", "Opening Drive Mode",
     options = ["Session Window", "First Bars Of Day"],
     group = groupSession,
     tooltip = "Controls whether the opening drive is built from a fixed intraday session window or from the first chart bars of each new day.")
driveSession = input.session("0930-1000", "Opening Drive Session",
     group = groupSession,
     tooltip = "Defines the opening drive window when Session Window mode is selected.")
trackingSession = input.session("0930-1600", "Tracking Session",
     group = groupSession,
     tooltip = "Defines when follow-through, pullback acceptance, risk-line checks, and target-room events can be evaluated.")
sessionTimezone = input.string("America/New_York", "Session Timezone",
     options = ["America/New_York", "Etc/UTC", "Europe/London", "Europe/Istanbul", "Asia/Tokyo"],
     group = groupSession,
     tooltip = "Timezone used to interpret the opening drive and tracking sessions.")
firstDriveBars = input.int(1, "First Bars Count", minval = 1, maxval = 24,
     group = groupSession,
     tooltip = "Number of first daily chart bars used to build the opening drive when First Bars Of Day mode is selected.")
driveMemoryBars = input.int(96, "Drive Memory Bars", minval = 10, maxval = 500,
     group = groupSession,
     tooltip = "Maximum bars after the opening drive lock during which planning states remain active.")

groupEngine = "Quality Engine"
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100,
     group = groupEngine,
     tooltip = "ATR length used for drive normalization, label offset, follow-through distance, and risk-line padding.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200,
     group = groupEngine,
     tooltip = "Lookback used to compare opening drive participation against recent volume.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score",
     group = groupEngine,
     tooltip = "Adds relative volume support to the 0-100 opening drive quality score when volume data is available.")
minimumQuality = input.int(52, "Minimum Quality Threshold", minval = 1, maxval = 100,
     group = groupEngine,
     tooltip = "Minimum 0-100 quality score required before stronger planning labels are printed.")
followThroughAtr = input.float(0.40, "Follow-Through ATR", minval = 0.05, maxval = 5.0, step = 0.05,
     group = groupEngine,
     tooltip = "ATR-normalized directional extension required to mark the opening drive as having real follow-through.")
followThroughBars = input.int(8, "Follow-Through Review Bars", minval = 2, maxval = 80,
     group = groupEngine,
     tooltip = "Number of bars after the opening drive lock before weak follow-through is treated as a planning warning.")
pullbackDepthPct = input.float(0.38, "Pullback Acceptance Depth", minval = 0.10, maxval = 0.80, step = 0.01,
     group = groupEngine,
     tooltip = "Portion of the locked opening drive channel used to project the pullback acceptance zone.")
riskBufferAtr = input.float(0.12, "Risk Line Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01,
     group = groupEngine,
     tooltip = "ATR buffer placed beyond the drive base and pullback zone to define the invalidation risk line.")
targetRangeMultiple = input.float(1.25, "Target Guide Multiple", minval = 0.25, maxval = 5.00, step = 0.05,
     group = groupEngine,
     tooltip = "Opening drive range multiple used to project the target-room guide after a valid drive locks.")

groupVisual = "Visuals"
showDriveChannel = input.bool(true, "Show Opening Drive Channel",
     group = groupVisual,
     tooltip = "Displays the locked opening drive channel with a centered state label.")
showPullbackZone = input.bool(true, "Show Pullback Acceptance Zone",
     group = groupVisual,
     tooltip = "Projects a concept-native pullback acceptance zone from the opening drive structure.")
showRiskLine = input.bool(true, "Show Risk Line",
     group = groupVisual,
     tooltip = "Shows the invalidation risk line derived from the drive base, pullback zone, and ATR buffer.")
showTargetGuide = input.bool(true, "Show Target Guide",
     group = groupVisual,
     tooltip = "Shows a projected target-room guide based on the locked opening drive range.")
showDriveLabels = input.bool(true, "Show Drive Labels",
     group = groupVisual,
     tooltip = "Prints compact event labels for drive quality, follow-through, pullback acceptance, risk breaks, and target checks.")
showZoneBadges = input.bool(true, "Show Zone Badges",
     group = groupVisual,
     tooltip = "Shows contrast-safe badges for the opening drive channel and pullback acceptance zone.")
showGuideBadges = input.bool(true, "Show Risk / Target Badges",
     group = groupVisual,
     tooltip = "Shows compact right-edge labels for the active risk line and target guide so projected rails are never left unidentified.")
zoneBadgePlacement = input.string("Centered", "Zone Badge Placement",
     options = ["Centered", "Smart Edge"],
     group = groupVisual,
     tooltip = "Centered places badges inside the channel or zone. Smart Edge moves them toward the projected edge to reduce candle overlap on compressed charts.")
zoneBadgeOffsetAtr = input.float(0.30, "Zone Badge Offset ATR", minval = 0.05, maxval = 2.00, step = 0.05,
     group = groupVisual,
     tooltip = "ATR-based spacing used when Zone Badge Placement is Smart Edge.")
channelExtendBars = input.int(24, "Channel Projection Bars", minval = 10, maxval = 500,
     group = groupVisual,
     tooltip = "Number of bars used to extend the opening drive channel after it locks.")
zoneExtendBars = input.int(24, "Pullback Zone Projection Bars", minval = 10, maxval = 500,
     group = groupVisual,
     tooltip = "Number of bars used to extend the pullback acceptance zone after the opening drive locks.")
maxHistoricalDrives = input.int(1, "Max Historical Drives", minval = 1, maxval = 20,
     group = groupVisual,
     tooltip = "Limits the number of historical drive channels and pullback zones retained on the chart.")
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 60,
     group = groupVisual,
     tooltip = "Limits retained event labels so the chart remains active but not crowded.")
minimumLabelQuality = input.int(72, "Minimum Label Quality", minval = 1, maxval = 100,
     group = groupVisual,
     tooltip = "Minimum quality score required before drive and follow-through labels are printed. This keeps low-value labels from crowding the publication chart.")
labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 0, maxval = 120,
     group = groupVisual,
     tooltip = "Minimum bar spacing between printed event labels. This keeps the chart active without stacking labels on the same area.")
labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.05, maxval = 3.00, step = 0.05,
     group = groupVisual,
     tooltip = "ATR-scaled vertical offset used to keep labels clear of candle bodies and wicks.")
channelOpacity = input.int(92, "Channel Opacity", minval = 70, maxval = 96,
     group = groupVisual,
     tooltip = "Controls the background transparency of the opening drive channel.")
zoneOpacity = input.int(88, "Zone Opacity", minval = 65, maxval = 96,
     group = groupVisual,
     tooltip = "Controls the background transparency of the pullback acceptance zone.")
showCompactMarkers = input.bool(false, "Show Compact Plot Markers",
     group = groupVisual,
     tooltip = "Shows small shape markers for follow-through, pullback, and risk events. It is off by default for a cleaner publication chart.")
labelSizeInput = input.string("Normal", "Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = groupVisual,
     tooltip = "Controls event label font size. Normal is the default for public-chart readability.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel",
     group = groupPanel,
     tooltip = "Displays the AGPro planning panel. The panel is visible by default and can be hidden from settings.")
panelLocationInput = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = groupPanel,
     tooltip = "Controls where the AGPro planning panel is placed on the chart.")
panelThemeInput = input.string("Elite Dark", "Panel Theme",
     options = ["Elite Dark", "Clean Light"],
     group = groupPanel,
     tooltip = "Controls the panel color theme while preserving the AGPro blue merged header row.")
panelFontSizeInput = input.string("Normal", "Panel Font Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = groupPanel,
     tooltip = "Controls panel text size. Normal is the default for balanced publication readability.")

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer",
     group = groupProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across locked opening drives on the current symbol and timeframe. Follow means the drive reached its own projected target guide before its own risk line. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 4, maxval = 300,
     group = groupProof,
     tooltip = "Maximum number of bars each locked drive is tracked for the proof measurement before it resolves at its current outcome.")
proofReactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40,
     group = groupProof,
     tooltip = "Number of bars after a drive locks used to detect an immediate favorable reaction toward the target guide.")
proofReactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0,
     group = groupProof,
     tooltip = "Minimum favorable progress toward the target guide, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeText) =>
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

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    color base = f_panel_bg(theme)
    theme == "Clean Light" ? (row % 2 == 0 ? color.rgb(241, 245, 249) : base) : (row % 2 == 0 ? color.rgb(17, 29, 52) : base)

f_quality_color(float score) =>
    na(score) ? panelLabelCol : score >= 75.0 ? bullColor : score >= 58.0 ? neutralColor : bearColor

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_side_color(int side) =>
    side == 1 ? bullColor : side == -1 ? bearColor : neutralColor

f_side_text(int side) =>
    side == 1 ? "Bull Drive" : side == -1 ? "Bear Drive" : "No Drive"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_trim_boxes(array<box> boxes, int maxCount) =>
    int boxCount = array.size(boxes)
    if boxCount > maxCount
        int removeCount = boxCount - maxCount
        for idx = 0 to removeCount - 1
            box oldBox = array.shift(boxes)
            box.delete(oldBox)

f_trim_lines(array<line> lines, int maxCount) =>
    int lineCount = array.size(lines)
    if lineCount > maxCount
        int removeCount = lineCount - maxCount
        for idx = 0 to removeCount - 1
            line oldLine = array.shift(lines)
            line.delete(oldLine)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_drive_score(int side, float driveOpenValue, float driveCloseValue, float driveHighValue, float driveLowValue, float atrValue, float relVolume, bool includeVolume) =>
    float span = math.max(driveHighValue - driveLowValue, syminfo.mintick)
    float bodyEfficiency = math.abs(driveCloseValue - driveOpenValue) / span
    float closeLocation = side == 1 ? (driveCloseValue - driveLowValue) / span : (driveHighValue - driveCloseValue) / span
    float rangeAtr = atrValue > 0.0 ? span / atrValue : 0.0
    float thrustScore = f_clamp(bodyEfficiency * 125.0, 0.0, 100.0)
    float closeScore = f_clamp(closeLocation * 100.0, 0.0, 100.0)
    float rangeScore = f_clamp(rangeAtr / 1.20 * 100.0, 0.0, 100.0)
    float volumeScore = f_clamp(relVolume / 1.35 * 100.0, 0.0, 100.0)
    float rawScore = includeVolume ? thrustScore * 0.32 + closeScore * 0.28 + rangeScore * 0.25 + volumeScore * 0.15 : thrustScore * 0.40 + closeScore * 0.32 + rangeScore * 0.28
    int(math.round(f_clamp(rawScore, 0.0, 100.0)))

f_add_event_label(array<label> labels, int side, string textValue, color labelColor, float offsetValue, string fontSize, int maxCount) =>
    float yValue = side == 1 ? low - offsetValue : high + offsetValue
    label eventLabel = label.new(x = bar_index, y = yValue, text = textValue, xloc = xloc.bar_index, yloc = yloc.price, style = side == 1 ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 8), textcolor = headerText, size = f_size(fontSize))
    array.push(labels, eventLabel)
    f_trim_labels(labels, maxCount)

f_zone_badge_x(int leftBar, int rightBar) =>
    zoneBadgePlacement == "Smart Edge" ? math.max(bar_index + 8, rightBar - 1) : int(math.round((leftBar + rightBar) * 0.5))

f_zone_badge_y(float topValue, float bottomValue, int side, float offsetValue) =>
    float midValue = (topValue + bottomValue) * 0.5
    zoneBadgePlacement == "Smart Edge" ? (side == 1 ? topValue + offsetValue : bottomValue - offsetValue) : midValue

f_zone_badge_style(int side) =>
    zoneBadgePlacement == "Smart Edge" ? (side == 1 ? label.style_label_down : label.style_label_up) : label.style_label_center

f_set_zone_badge(label badge, int leftBar, int rightBar, float topValue, float bottomValue, int side, string textValue, color badgeColor, float atrValue, string fontSize) =>
    label result = badge
    int badgeX = f_zone_badge_x(leftBar, rightBar)
    float badgeY = f_zone_badge_y(topValue, bottomValue, side, math.max(atrValue * zoneBadgeOffsetAtr, syminfo.mintick * 20.0))
    badgeStyle = f_zone_badge_style(side)
    if na(result)
        result := label.new(badgeX, badgeY, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = badgeStyle, color = color.new(badgeColor, 0), textcolor = headerText, size = f_size(fontSize))
    else
        label.set_x(result, badgeX)
        label.set_y(result, badgeY)
        label.set_text(result, textValue)
        label.set_style(result, badgeStyle)
        label.set_color(result, color.new(badgeColor, 0))
        label.set_textcolor(result, headerText)
        label.set_size(result, f_size(fontSize))
    result

f_set_guide_badge(label badge, int xValue, float yValue, string textValue, color badgeColor, string fontSize) =>
    label result = badge
    if na(result)
        result := label.new(xValue, yValue, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(badgeColor, 0), textcolor = headerText, size = f_size(fontSize))
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, textValue)
        label.set_style(result, label.style_label_left)
        label.set_color(result, color.new(badgeColor, 0))
        label.set_textcolor(result, headerText)
        label.set_size(result, f_size(fontSize))
    result

// -------------------------------------------------
// Session State
// -------------------------------------------------
bool useFirstBarsMode = driveMode == "First Bars Of Day"
bool inDriveSessionRaw = not na(time(timeframe.period, driveSession, sessionTimezone))
bool inTrackingSessionRaw = not na(time(timeframe.period, trackingSession, sessionTimezone))
int dailyStamp = time("D", "0000-2359", sessionTimezone)
bool newDailyDrive = barstate.isfirst or ta.change(dailyStamp) != 0
bool wasInDriveSession = bar_index > 0 ? inDriveSessionRaw[1] : false
bool sessionDriveStarted = not useFirstBarsMode and inDriveSessionRaw and not wasInDriveSession
bool sessionDriveEnded = not useFirstBarsMode and not inDriveSessionRaw and wasInDriveSession

float atrValue = ta.atr(atrLength)
float volumeAverage = ta.sma(volume, volumeLength)

var float driveOpen = na
var float driveHigh = na
var float driveLow = na
var float driveClose = na
var float driveVolume = na
var int driveVolumeBars = 0
var int driveStartBar = na
var int driveEndBar = na
var bool driveLocked = false
var int firstBarsBuilt = 0
var int activeDriveDir = 0
var int activeDriveScore = na
var int activeReadinessScore = na
var float followHigh = na
var float followLow = na
var float activeZoneTop = na
var float activeZoneBottom = na
var float activeRiskLineValue = na
var float activeTargetLineValue = na
var bool followPrinted = false
var bool pullbackPrinted = false
var bool riskPrinted = false
var bool targetPrinted = false
var bool weakPrinted = false

var box activeDriveBox = na
var box activePullbackBox = na
var label activeDriveBadge = na
var label activePullbackBadge = na
var label activeRiskBadge = na
var label activeTargetBadge = na
var line activeRiskLine = na
var line activeTargetLine = na
var int lastEventLabelBar = na
var array<box> driveBoxes = array.new_box()
var array<box> pullbackBoxes = array.new_box()
var array<line> planLines = array.new_line()
var array<label> eventLabels = array.new_label()

bool dailyDriveStarted = useFirstBarsMode and newDailyDrive
int effectiveFirstDriveBars = timeframe.isintraday ? firstDriveBars : 1
int effectiveChannelExtendBars = timeframe.isintraday ? channelExtendBars : math.min(channelExtendBars, 14)
int effectiveZoneExtendBars = timeframe.isintraday ? zoneExtendBars : math.min(zoneExtendBars, 14)
bool dailyDriveContinues = useFirstBarsMode and not dailyDriveStarted and firstBarsBuilt > 0 and firstBarsBuilt < effectiveFirstDriveBars
bool driveStarted = sessionDriveStarted or dailyDriveStarted
bool inDriveWindow = useFirstBarsMode ? (dailyDriveStarted or dailyDriveContinues) : inDriveSessionRaw
bool inTrackingSession = useFirstBarsMode ? true : inTrackingSessionRaw
bool dailyLockNow = false
bool driveLockedEvent = false

// -------------------------------------------------
// Opening Drive Construction
// -------------------------------------------------
if driveStarted
    driveOpen := open
    driveHigh := high
    driveLow := low
    driveClose := close
    driveVolume := 0.0
    driveVolumeBars := 0
    driveStartBar := bar_index
    driveEndBar := na
    driveLocked := false
    firstBarsBuilt := useFirstBarsMode ? 1 : 0
    activeDriveDir := 0
    activeDriveScore := na
    activeReadinessScore := na
    followHigh := na
    followLow := na
    activeZoneTop := na
    activeZoneBottom := na
    activeRiskLineValue := na
    activeTargetLineValue := na
    followPrinted := false
    pullbackPrinted := false
    riskPrinted := false
    targetPrinted := false
    weakPrinted := false
    activeDriveBox := na
    activePullbackBox := na
    if not na(activeDriveBadge)
        label.delete(activeDriveBadge)
        activeDriveBadge := na
    if not na(activePullbackBadge)
        label.delete(activePullbackBadge)
        activePullbackBadge := na
    if not na(activeRiskBadge)
        label.delete(activeRiskBadge)
        activeRiskBadge := na
    if not na(activeTargetBadge)
        label.delete(activeTargetBadge)
        activeTargetBadge := na
    activeRiskLine := na
    activeTargetLine := na
    if showDriveChannel
        activeDriveBox := box.new(left = bar_index, top = high, right = bar_index, bottom = low, xloc = xloc.bar_index, bgcolor = color.new(accentColor, channelOpacity), border_color = color.new(accentColor, 30), border_width = 1)
        array.push(driveBoxes, activeDriveBox)
        f_trim_boxes(driveBoxes, maxHistoricalDrives)
    if showZoneBadges
        activeDriveBadge := f_set_zone_badge(activeDriveBadge, bar_index, bar_index + 1, high, low, 1, "BUILDING DRIVE", accentColor, nz(atrValue, high - low), labelSizeInput)

if inDriveWindow and not driveLocked
    driveHigh := na(driveHigh) ? high : math.max(driveHigh, high)
    driveLow := na(driveLow) ? low : math.min(driveLow, low)
    driveClose := close
    driveVolume += nz(volume, 0.0)
    driveVolumeBars += 1
    if not na(activeDriveBox)
        box.set_right(activeDriveBox, bar_index)
        box.set_top(activeDriveBox, driveHigh)
        box.set_bottom(activeDriveBox, driveLow)
    if useFirstBarsMode and not dailyDriveStarted
        firstBarsBuilt += 1
    dailyLockNow := useFirstBarsMode and firstBarsBuilt >= effectiveFirstDriveBars and not driveLocked

if (sessionDriveEnded or dailyLockNow) and not driveLocked and not na(driveHigh) and not na(driveLow) and not na(driveOpen) and not na(driveClose)
    driveLocked := true
    driveLockedEvent := true
    driveEndBar := useFirstBarsMode ? bar_index : bar_index - 1
    float driveMid = (driveHigh + driveLow) * 0.5
    activeDriveDir := driveClose > driveOpen ? 1 : driveClose < driveOpen ? -1 : driveClose >= driveMid ? 1 : -1
    color driveColor = f_side_color(activeDriveDir)
    float driveSpan = math.max(driveHigh - driveLow, syminfo.mintick)
    bool driveVolumeAvailable = useVolumeScore and not na(volumeAverage) and volumeAverage > 0.0 and driveVolumeBars > 0 and driveVolume > 0.0
    float driveRelativeVolume = driveVolumeAvailable ? (driveVolume / driveVolumeBars) / volumeAverage : 1.0
    activeDriveScore := f_drive_score(activeDriveDir, driveOpen, driveClose, driveHigh, driveLow, atrValue, driveRelativeVolume, driveVolumeAvailable)
    activeReadinessScore := activeDriveScore
    followHigh := driveHigh
    followLow := driveLow
    float zoneDepth = driveSpan * pullbackDepthPct
    activeZoneTop := activeDriveDir == 1 ? driveHigh : driveLow + zoneDepth
    activeZoneBottom := activeDriveDir == 1 ? driveHigh - zoneDepth : driveLow
    activeRiskLineValue := activeDriveDir == 1 ? math.min(driveLow, activeZoneBottom - atrValue * riskBufferAtr) : math.max(driveHigh, activeZoneTop + atrValue * riskBufferAtr)
    activeTargetLineValue := activeDriveDir == 1 ? driveHigh + driveSpan * targetRangeMultiple : driveLow - driveSpan * targetRangeMultiple
    string driveText = "DRIVE | Q " + str.tostring(activeDriveScore)
    if not na(activeDriveBox)
        box.set_right(activeDriveBox, driveEndBar + effectiveChannelExtendBars)
        box.set_top(activeDriveBox, driveHigh)
        box.set_bottom(activeDriveBox, driveLow)
        box.set_bgcolor(activeDriveBox, color.new(driveColor, channelOpacity))
        box.set_border_color(activeDriveBox, color.new(driveColor, 24))
    if showZoneBadges and showDriveChannel and not showPullbackZone
        activeDriveBadge := f_set_zone_badge(activeDriveBadge, driveStartBar, driveEndBar + effectiveChannelExtendBars, driveHigh, driveLow, activeDriveDir, driveText, driveColor, atrValue, labelSizeInput)
    else if not na(activeDriveBadge)
        label.delete(activeDriveBadge)
        activeDriveBadge := na
    if showPullbackZone
        activePullbackBox := box.new(left = driveEndBar, top = activeZoneTop, right = driveEndBar + effectiveZoneExtendBars, bottom = activeZoneBottom, xloc = xloc.bar_index, bgcolor = color.new(driveColor, zoneOpacity), border_color = color.new(driveColor, 28), border_width = 1)
        array.push(pullbackBoxes, activePullbackBox)
        f_trim_boxes(pullbackBoxes, maxHistoricalDrives)
    if showZoneBadges
        string initialPbText = (activeDriveDir == 1 ? "BULL PB" : "BEAR PB") + " | D " + str.tostring(activeDriveScore) + " | Q " + str.tostring(activeReadinessScore)
        activePullbackBadge := f_set_zone_badge(activePullbackBadge, driveEndBar, driveEndBar + effectiveZoneExtendBars, activeZoneTop, activeZoneBottom, activeDriveDir, initialPbText, driveColor, atrValue, labelSizeInput)
    else if not na(activePullbackBadge)
        label.delete(activePullbackBadge)
        activePullbackBadge := na
    if showRiskLine
        activeRiskLine := line.new(driveEndBar, activeRiskLineValue, driveEndBar + effectiveZoneExtendBars, activeRiskLineValue, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 4), style = line.style_dashed, width = 2)
        array.push(planLines, activeRiskLine)
        if showGuideBadges
            activeRiskBadge := f_set_guide_badge(activeRiskBadge, driveEndBar + effectiveZoneExtendBars, activeRiskLineValue, "RISK " + f_price(activeRiskLineValue), bearColor, labelSizeInput)
    if showTargetGuide
        activeTargetLine := line.new(driveEndBar, activeTargetLineValue, driveEndBar + effectiveZoneExtendBars, activeTargetLineValue, xloc = xloc.bar_index, extend = extend.none, color = color.new(driveColor, 0), style = line.style_dotted, width = 2)
        array.push(planLines, activeTargetLine)
        if showGuideBadges
            activeTargetBadge := f_set_guide_badge(activeTargetBadge, driveEndBar + effectiveZoneExtendBars, activeTargetLineValue, "TARGET " + f_price(activeTargetLineValue), driveColor, labelSizeInput)
    f_trim_lines(planLines, maxHistoricalDrives * 2)
    bool canPrintDriveLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
    if showDriveLabels and canPrintDriveLabel and activeDriveScore >= minimumLabelQuality
        f_add_event_label(eventLabels, activeDriveDir, "DRIVE | Q " + str.tostring(activeDriveScore), f_quality_color(activeDriveScore), atrValue * labelOffsetAtr, labelSizeInput, maxVisibleLabels)
        lastEventLabelBar := bar_index

// -------------------------------------------------
// Follow-Through, Pullback, Risk, Target Logic
// -------------------------------------------------
float activeSpan = not na(driveHigh) and not na(driveLow) ? math.max(driveHigh - driveLow, syminfo.mintick) : na
int barsAfterLock = driveLocked and not na(driveEndBar) ? bar_index - driveEndBar : 100000
bool trackingActive = driveLocked and inTrackingSession and not inDriveWindow and barsAfterLock >= 0 and barsAfterLock <= driveMemoryBars

if trackingActive
    followHigh := na(followHigh) ? high : math.max(followHigh, high)
    followLow := na(followLow) ? low : math.min(followLow, low)

float extensionValue = trackingActive and activeDriveDir == 1 ? followHigh - driveHigh : trackingActive and activeDriveDir == -1 ? driveLow - followLow : na
float extensionAtr = not na(extensionValue) and atrValue > 0.0 ? math.max(extensionValue, 0.0) / atrValue : 0.0
int followScore = int(math.round(f_clamp(extensionAtr / followThroughAtr * 100.0, 0.0, 100.0)))
bool followConfirmed = trackingActive and extensionAtr >= followThroughAtr
bool weakFollowThrough = trackingActive and barsAfterLock > followThroughBars and not followConfirmed

bool zoneOverlap = trackingActive and not na(activeZoneTop) and not na(activeZoneBottom) and high >= activeZoneBottom and low <= activeZoneTop
bool riskBroken = trackingActive and not na(activeRiskLineValue) and (activeDriveDir == 1 ? close < activeRiskLineValue : close > activeRiskLineValue)
bool targetHit = trackingActive and not na(activeTargetLineValue) and (activeDriveDir == 1 ? high >= activeTargetLineValue : low <= activeTargetLineValue)
float pullbackDepth = trackingActive and not na(activeSpan) ? (activeDriveDir == 1 ? f_clamp((driveHigh - low) / activeSpan, 0.0, 2.0) : f_clamp((high - driveLow) / activeSpan, 0.0, 2.0)) : 0.0
bool pullbackHeld = zoneOverlap and not riskBroken and (activeDriveDir == 1 ? close >= activeZoneBottom : close <= activeZoneTop)
float pullbackScoreFloat = riskBroken ? 5.0 : pullbackHeld ? f_clamp(100.0 - math.abs(pullbackDepth - pullbackDepthPct * 0.50) / pullbackDepthPct * 35.0, 65.0, 100.0) : zoneOverlap ? 58.0 : followConfirmed ? 62.0 : weakFollowThrough ? 35.0 : 50.0
int pullbackScore = int(math.round(pullbackScoreFloat))

if driveLocked
    float readinessRaw = activeDriveScore * 0.45 + followScore * 0.32 + pullbackScore * 0.23
    activeReadinessScore := int(math.round(f_clamp(readinessRaw, 0.0, 100.0)))

color activeQualityColor = f_quality_color(activeReadinessScore)
color activeSideColor = f_side_color(activeDriveDir)

if driveLocked and not na(driveEndBar)
    int liveRightEdge = math.max(driveEndBar + effectiveChannelExtendBars, bar_index + 8)
    if not na(activeDriveBox)
        box.set_right(activeDriveBox, liveRightEdge)
    if showZoneBadges and showDriveChannel and not showPullbackZone and not na(activeDriveBadge)
        activeDriveBadge := f_set_zone_badge(activeDriveBadge, driveStartBar, liveRightEdge, driveHigh, driveLow, activeDriveDir, "DRIVE | Q " + str.tostring(activeDriveScore), activeSideColor, atrValue, labelSizeInput)
    else if not na(activeDriveBadge)
        label.delete(activeDriveBadge)
        activeDriveBadge := na
    if not na(activePullbackBox)
        box.set_right(activePullbackBox, liveRightEdge)
    if showZoneBadges and not na(activePullbackBadge)
        string pbSideText = activeDriveDir == 1 ? "BULL PB" : "BEAR PB"
        string pbBadgeText = pullbackHeld ? pbSideText + " | HELD | D " + str.tostring(activeDriveScore) + " | Q " + str.tostring(pullbackScore) : zoneOverlap ? pbSideText + " | TEST | D " + str.tostring(activeDriveScore) + " | Q " + str.tostring(pullbackScore) : pbSideText + " | D " + str.tostring(activeDriveScore) + " | Q " + str.tostring(pullbackScore)
        color pbBadgeColor = pullbackHeld ? activeSideColor : zoneOverlap ? neutralColor : activeSideColor
        activePullbackBadge := f_set_zone_badge(activePullbackBadge, driveEndBar, liveRightEdge, activeZoneTop, activeZoneBottom, activeDriveDir, pbBadgeText, pbBadgeColor, atrValue, labelSizeInput)
    else if not showZoneBadges and not na(activePullbackBadge)
        label.delete(activePullbackBadge)
        activePullbackBadge := na
    if not na(activeRiskLine) and not na(activeRiskLineValue)
        line.set_xy2(activeRiskLine, liveRightEdge, activeRiskLineValue)
        if showGuideBadges
            activeRiskBadge := f_set_guide_badge(activeRiskBadge, liveRightEdge, activeRiskLineValue, "RISK " + f_price(activeRiskLineValue), bearColor, labelSizeInput)
    if not na(activeTargetLine) and not na(activeTargetLineValue)
        line.set_xy2(activeTargetLine, liveRightEdge, activeTargetLineValue)
        if showGuideBadges
            activeTargetBadge := f_set_guide_badge(activeTargetBadge, liveRightEdge, activeTargetLineValue, "TARGET " + f_price(activeTargetLineValue), activeSideColor, labelSizeInput)

if trackingActive and not na(activePullbackBox)
    box.set_bgcolor(activePullbackBox, color.new(pullbackHeld ? activeSideColor : zoneOverlap ? neutralColor : activeSideColor, zoneOpacity))
    box.set_border_color(activePullbackBox, color.new(pullbackHeld ? activeSideColor : zoneOverlap ? neutralColor : activeSideColor, 28))

bool followEvent = trackingActive and not followPrinted and followConfirmed and activeReadinessScore >= minimumQuality
bool pullbackEvent = trackingActive and not pullbackPrinted and followConfirmed and pullbackHeld and activeReadinessScore >= minimumQuality
bool riskEvent = trackingActive and not riskPrinted and riskBroken
bool targetEvent = trackingActive and not targetPrinted and targetHit and activeReadinessScore >= minimumQuality
bool weakEvent = trackingActive and not weakPrinted and weakFollowThrough

if followEvent
    followPrinted := true
    bool canPrintFollowLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
    if showDriveLabels and canPrintFollowLabel and activeReadinessScore >= minimumLabelQuality
        f_add_event_label(eventLabels, activeDriveDir, "FOLLOW | Q " + str.tostring(activeReadinessScore), activeQualityColor, atrValue * labelOffsetAtr, labelSizeInput, maxVisibleLabels)
        lastEventLabelBar := bar_index

if pullbackEvent
    pullbackPrinted := true
    bool canPrintPullbackLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
    if showDriveLabels and canPrintPullbackLabel
        f_add_event_label(eventLabels, activeDriveDir, "PB OK", activeSideColor, atrValue * labelOffsetAtr, labelSizeInput, maxVisibleLabels)
        lastEventLabelBar := bar_index

if riskEvent
    riskPrinted := true
    bool canPrintRiskLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
    if showDriveLabels and canPrintRiskLabel
        f_add_event_label(eventLabels, activeDriveDir, "RISK BREAK", bearColor, atrValue * labelOffsetAtr, labelSizeInput, maxVisibleLabels)
        lastEventLabelBar := bar_index

if targetEvent
    targetPrinted := true
    bool canPrintTargetLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
    if showDriveLabels and canPrintTargetLabel
        f_add_event_label(eventLabels, activeDriveDir, "TGT CHECK", activeSideColor, atrValue * labelOffsetAtr, labelSizeInput, maxVisibleLabels)
        lastEventLabelBar := bar_index

if weakEvent
    weakPrinted := true
    bool canPrintWeakLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
    if showDriveLabels and canPrintWeakLabel
        f_add_event_label(eventLabels, activeDriveDir, "WEAK DRIVE", neutralColor, atrValue * labelOffsetAtr, labelSizeInput, maxVisibleLabels)
        lastEventLabelBar := bar_index

plotshape(showCompactMarkers and followEvent and activeDriveDir == 1, title = "Bull Drive Follow-Through", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showCompactMarkers and followEvent and activeDriveDir == -1, title = "Bear Drive Follow-Through", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showCompactMarkers and pullbackEvent and activeDriveDir == 1, title = "Bull Pullback Acceptance", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showCompactMarkers and pullbackEvent and activeDriveDir == -1, title = "Bear Pullback Acceptance", style = shape.circle, location = location.abovebar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showCompactMarkers and riskEvent and activeDriveDir == 1, title = "Bull Risk Line Broken", style = shape.xcross, location = location.belowbar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showCompactMarkers and riskEvent and activeDriveDir == -1, title = "Bear Risk Line Broken", style = shape.xcross, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

// -------------------------------------------------
// Confirmation-anchored proof (locked drives: Follow = target guide reached before risk line)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false
var bool pFlipped = false

int proofWarmup = atrLength + volumeLength + 5
bool driveAnchor = barstate.isconfirmed and driveLockedEvent and activeDriveDir != 0 and not na(activeRiskLineValue) and not na(activeTargetLineValue)
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool stopBreached = pEvalDir == 1 ? low < pEvalStop : high > pEvalStop
        bool hitTarget = heldBars >= 1 and (pEvalDir == 1 ? high >= pEvalTarget : low <= pEvalTarget)
        if heldBars >= 1 and heldBars <= proofReactBars and not stopBreached and favExc >= followDist * proofReactProgressPct / 100.0
            pReacted := true
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not stopBreached and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= proofHorizonBars
        if naturalResolve or driveAnchor
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if not pFlipped
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if pFlipped
                proofFlip := proofFlip + 1
            pEvalActive := false
    if driveAnchor and not pEvalActive
        pEvalActive := true
        pEvalDir := activeDriveDir
        pEvalEntry := close
        pEvalStop := activeRiskLineValue
        pEvalTarget := activeTargetLineValue
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float proofFlipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(activeReadinessScore, title = "Opening Drive Quality Score", color = activeQualityColor, display = display.data_window)
plot(activeDriveScore, title = "Base Drive Score", color = activeSideColor, display = display.data_window)
plot(followScore, title = "Follow-Through Score", color = accentColor, display = display.data_window)
plot(pullbackScore, title = "Pullback Quality Score", color = neutralColor, display = display.data_window)
plot(activeRiskLineValue, title = "Risk Line", color = bearColor, display = display.data_window)
plot(activeTargetLineValue, title = "Target Guide", color = activeSideColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string theme = panelThemeInput
string panelSize = panelFontSizeInput
color dashBg = f_panel_bg(theme)
color frameColor = f_panel_border(theme)

string driveSideRead = driveLocked ? f_side_text(activeDriveDir) + " / Q " + str.tostring(activeReadinessScore) : inDriveWindow ? "Building" : "Waiting"
string followRead = driveLocked ? (followConfirmed ? "Confirmed / " + str.tostring(extensionAtr, "0.00") + " ATR" : weakFollowThrough ? "Weak / " + str.tostring(extensionAtr, "0.00") + " ATR" : "Developing / " + str.tostring(extensionAtr, "0.00") + " ATR") : "No drive"
bool riskInvalidated = riskBroken or riskPrinted
string pullbackRead = driveLocked ? (riskInvalidated ? "Invalidated" : pullbackHeld and followConfirmed ? "Accepted / " + str.tostring(pullbackScore) : zoneOverlap ? "Testing / " + str.tostring(pullbackScore) : followConfirmed ? "Awaiting / " + str.tostring(pullbackScore) : "Pending / " + str.tostring(pullbackScore)) : "No drive"
string riskRead = driveLocked ? (riskInvalidated ? "Broken / " + f_price(activeRiskLineValue) : "Active / " + f_price(activeRiskLineValue)) : "n/a"
string actionRead = "Wait For Drive"
if driveLocked
    actionRead := riskInvalidated ? "Stand Aside" : targetHit or targetPrinted ? "Manage Extension" : pullbackHeld and followConfirmed and activeReadinessScore >= minimumQuality ? "Plan From Pullback" : followConfirmed ? "Wait Pullback" : weakFollowThrough ? "Reduce Bias" : "Review Drive"

color followColor = followConfirmed ? bullColor : weakFollowThrough ? bearColor : neutralColor
color pullbackColor = riskInvalidated ? bearColor : pullbackHeld and followConfirmed ? activeSideColor : zoneOverlap ? neutralColor : panelValueCol
color riskColor = riskInvalidated ? bearColor : neutralColor
color actionColor = actionRead == "Plan From Pullback" or actionRead == "Manage Extension" ? bullColor : actionRead == "Stand Aside" or actionRead == "Reduce Bias" ? bearColor : neutralColor

var table statePanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastPanelVisible = false
var bool lastProofMode = false
int panelRowCount = showProof ? 11 : 6

bool panelNeedsReset = na(statePanel) or panelLocationInput != lastPanelLocation or theme != lastPanelTheme or panelSize != lastPanelFont or showPanel != lastPanelVisible or showProof != lastProofMode
if panelNeedsReset
    if not na(statePanel)
        table.delete(statePanel)
    if showPanel
        statePanel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
        table.cell(statePanel, 0, 0, "AG Pro Opening Drive Quality", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelSize), text_halign = text.align_center)
        table.cell(statePanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelSize))
        table.merge_cells(statePanel, 0, 0, 1, 0)
    else
        statePanel := na
    lastPanelLocation := panelLocationInput
    lastPanelTheme := theme
    lastPanelFont := panelSize
    lastPanelVisible := showPanel
    lastProofMode := showProof

if barstate.islast and showPanel and not na(statePanel)
    table.set_position(statePanel, f_panel_position(panelLocationInput))
    table.clear(statePanel, 0, 1, 1, panelRowCount - 1)
    table.cell(statePanel, 0, 0, "AG Pro Opening Drive Quality", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelSize), text_halign = text.align_center)
    f_set_row(statePanel, 1, "Drive Side", driveSideRead, driveLocked ? activeSideColor : neutralColor, theme, panelSize)
    f_set_row(statePanel, 2, "Follow-Through", followRead, followColor, theme, panelSize)
    f_set_row(statePanel, 3, "Pullback Quality", pullbackRead, pullbackColor, theme, panelSize)
    f_set_row(statePanel, 4, "Risk Line", riskRead, riskColor, theme, panelSize)
    f_set_row(statePanel, 5, "Action", actionRead, actionColor, theme, panelSize)
    if showProof
        color proofHeaderBg = f_row_bg(theme, 6)
        table.cell(statePanel, 0, 6, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeaderBg, text_size = f_size(panelSize))
        table.cell(statePanel, 1, 6, proofSampleText, text_color = f_panel_label(theme), bgcolor = proofHeaderBg, text_size = f_size(panelSize), text_halign = text.align_right)
        f_set_row(statePanel, 7, "Follow Rate", proofTotal > 0 ? f_rate_pct(followRate) : "-", proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(theme), theme, panelSize)
        f_set_row(statePanel, 8, "Hold Rate", proofTotal > 0 ? f_rate_pct(holdRate) : "-", proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(theme), theme, panelSize)
        f_set_row(statePanel, 9, "React Rate", proofTotal > 0 ? f_rate_pct(reactRate) : "-", proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(theme), theme, panelSize)
        f_set_row(statePanel, 10, "Flip Rate", proofTotal > 0 ? f_rate_pct(proofFlipRate) : "-", proofTotal > 0 ? f_flip_color(proofFlipRate) : f_panel_value(theme), theme, panelSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(driveLockedEvent and activeDriveScore >= minimumQuality, title = "Opening Drive Quality Locked", message = "Opening Drive Quality: a qualified opening drive has locked. This is an attention marker, not a trade instruction.")
alertcondition(followEvent, title = "Drive Follow-Through", message = "Opening Drive Quality: directional follow-through is confirmed after the opening drive.")
alertcondition(pullbackEvent, title = "Pullback Accepted", message = "Opening Drive Quality: price is reacting inside the projected pullback acceptance zone.")
alertcondition(riskEvent, title = "Risk Line Broken", message = "Opening Drive Quality: the active drive has violated its risk line.")
alertcondition(targetEvent, title = "Target Guide Reached", message = "Opening Drive Quality: price reached the projected target-room guide.")

// -------------------------------------------------
// Hidden Proof Exports
// -------------------------------------------------
plot(followRate, title = "ODQ Follow Rate", display = display.none)
plot(holdRate, title = "ODQ Hold Rate", display = display.none)
plot(reactRate, title = "ODQ React Rate", display = display.none)
plot(proofFlipRate, title = "ODQ Flip Rate", display = display.none)
````
