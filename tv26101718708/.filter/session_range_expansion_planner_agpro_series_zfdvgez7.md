# Session Range Expansion Planner [AGPro Series]

- url: https://www.tradingview.com/script/ZfdVGEZ7-Session-Range-Expansion-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;66acf15ef31148eead24c532860ca84d
- version: 5.0

## Description

Session Range Expansion Planner [AGPro Series]

🧠 Core Idea

Is the session expanding from balance into a valid range extension, or is the break still too weak to trust as context?


📌 Overview / What it does

Session Range Expansion Planner is a 1H-focused intraday execution-readiness tool built around one clear workflow: define the early-session balance, track expansion beyond that range, and score whether the move has enough acceptance, volume support, volatility fit, and target room to deserve attention.

The script produces a session range box, accepted target-room bands, acceptance/rejection context, alerts, and a premium AGPro panel with a 0-100 planner score. The default visual preset is optimized for 1H and lower charts. Higher intraday charts such as 4H are intentionally kept clean by default.

It does not predict the next candle, automate entries, or issue buy/sell commands. It organizes session behavior into a structured decision layer so the user can evaluate the setup within their own plan.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between simple session boxes and generic breakout indicators.

Most tools show where the session range is. Fewer tools explain whether the break from that range is actually being accepted, whether participation supports it, and whether there is usable room beyond the range.

Session Range Expansion Planner supports a planning mindset: define balance first, wait for expansion, check acceptance, evaluate room, then decide whether the context is worth further review.


⚡ Why This Script Is Different

Most session tools focus on marking opens, coloring sessions, or printing a breakout label as soon as price crosses a high or low.

This script does NOT act as a generic session high/low map, generic support/resistance tool, or broad session reaction scanner.

Instead, it treats the first part of the session as a balance structure and asks whether the later expansion has enough quality to become actionable context. The decision layer is built around acceptance bars, volume support, ATR regime, obstacle distance, and target-room quality.


⚙️ Methodology

1. Context Detection
The script reads the selected intraday session and builds an initial balance range from the first user-defined number of bars.

2. Reference Mapping
The session balance high and low become the only active expansion boundaries. The tool does not use PDH, PDL, weekly open, order blocks, FVGs, or generic swing zones.

3. Reaction Evaluation
When price breaks beyond the balance range, the engine measures acceptance closes, volume support, ATR regime quality, break distance, and nearby obstacle room.

4. Visual Output
The script displays a centered session range label, directional expansion labels, target-room band, acceptance/rejection labels, alerts, and a premium panel with score and next-action state.


🗺️ How to Read the Chart

Session Range Box = the early-session balance area.

Expansion Labels = the side where price first expands beyond the balance high or low.

Target-Room Band = the projected room beyond the broken boundary after expansion has been accepted, scaled by session range or ATR.

Acceptance Labels = confirmation that price has sustained closes beyond the range for the configured number of bars.

Rejection Labels = warning that price has failed back through the broken boundary.

Colors:
• Teal = upside expansion context
• Pink = downside expansion context
• Amber = neutral, warning, or rejection context
• Indigo = AGPro visual accent and target-room support

Panel = the decision cockpit showing planner score, session range, expansion side, acceptance, room score, and next action.


🚦 Signals & States

• Range Set → the initial balance window has completed.

• Expansion Up → price expanded above the session balance high.

• Expansion Down → price expanded below the session balance low.

• Accepted → the expansion held beyond the range for the required acceptance bars.

• Rejection Risk → price failed back through the broken boundary.

• Room Check Reached → price reached the projected target-room area.


🔔 Alerts Logic

Alerts trigger when:

• Upside range expansion is detected
• Downside range expansion is detected
• Expansion becomes accepted
• Rejection risk appears after expansion

Alerts are attention markers. They are not trade instructions and should be interpreted together with broader market context.


🧩 Confluence Logic

The strongest context appears when expansion direction, sustained acceptance, volume support, balanced ATR regime, and clean target room align at the same time.

When those conditions stack together, the planner score rises and the panel moves toward a review-ready state.


📊 When to Use

• 1H intraday charts with clear session behavior
• Opening balance or early-session range workflows
• Breakout quality review
• Volatility expansion planning
• Session continuation evaluation

The script is most useful when a trader wants to know whether a session range break is actually being accepted, not just whether a line was crossed.


⚠️ When NOT to Use

• Very low-liquidity symbols
• Extremely noisy micro timeframes
• Markets with unreliable volume
• Sessions with irregular trading hours
• News-driven candles where range expansion is disorderly

In weak conditions, reduce sensitivity or require stricter acceptance.


🎛️ Key Inputs

• Session Timezone → defines how the selected session is interpreted.

• Expansion Session → sets the active intraday window. The default full-day session is designed to work cleanly on crypto and other 24-hour symbols.

• Visual Timeframe Preset → controls which intraday timeframes show chart objects. The default is 1H and lower because 4H session expansion charts can become too compressed.

• Balance Window Bars → controls how many early-session bars define the range.

• Acceptance Bars → defines how much sustained closing behavior is required.

• Sensitivity → adjusts how fast the script recognizes expansion.

• Confirmation Mode → controls wick, close, or strict acceptance confirmation.

• Minimum Planner Score → sets the score threshold for review-ready context.

• ATR Length → controls volatility normalization and label spacing.

• Obstacle Lookback → estimates nearby structure that may reduce room quality.

• Target Room Multiplier → controls the projected target-room distance.

• Visual Settings → control range boxes, centered range label limit, rails, accepted target-room band, minimum visual score, optional expansion labels, optional room-check labels, optional range-set labels, label size, and object limits.

• Panel Settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The interface is chart-first. The range box and target-room band carry the main visual story, while labels explain state transitions only when meaningful events occur.

The panel is intentionally compact. It gives a fast read of expansion quality without forcing the user to decode many separate plots.

The first panel row follows the AGPro standard: a single merged blue header row with only the script name.


🧪 Practical Usage Workflow

1. Apply the script to an intraday chart.

2. Confirm the correct session and timezone.

3. Let the initial balance window complete.

4. Watch for expansion beyond the balance high or low.

5. Check whether acceptance bars confirm sustained behavior.

6. Read the planner score and room score.

7. Use the next-action state as context for your own execution plan.


🔍 Interpretation Guidelines

A clean expansion is not just a break beyond the range. It should show acceptance, participation, reasonable volatility, and enough room before nearby obstruction.

Low scores usually mean the break is early, unsupported, too noisy, too extended, or too close to an obstacle.

The best use is comparative: review which sessions and symbols repeatedly produce clean accepted expansions versus weak false breaks.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not auto trading
• Not guaranteed signals
• Not a buy/sell command system
• Not a generic support/resistance map
• Not an order block, FVG, or liquidity sweep scanner


⚠️ Limitations & Transparency

Session behavior can vary across assets, timeframes, exchanges, and trading hours.

ATR regime and volume support are rule-based approximations, not certainty models.

On very low timeframes, labels may appear more frequently. On higher intraday timeframes, fewer but more meaningful events are expected.

Markets can expand cleanly and still reverse later. The tool measures context quality, not future certainty.


🧠 Market Context Notes

Session range expansion often becomes more meaningful when it is read together with broader trend, liquidity, volatility, and higher-timeframe structure.

The script deliberately stays focused on session balance and expansion quality. Users can combine it with their own broader framework without duplicating other AGPro tools.


🧾 Use Case Examples

When price breaks above the session range, holds above the balance high for the required acceptance bars, and room score remains strong, the panel may shift into review-ready continuation context.

When price breaks the range but quickly closes back inside the balance, the script marks rejection risk and the panel moves away from continuation review.


🧱 System Philosophy

AGPro tools are built to help traders organize context into clear decision layers.

Session Range Expansion Planner follows that philosophy by turning a common intraday event into a structured planning process: balance, expansion, acceptance, room, action.


🔐 Non-Promise Statement

No script can guarantee future price movement.

The score is a structured context model, not a certainty model.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and historical session behavior does not guarantee future outcomes.

Users are responsible for their own decisions, risk management, and position sizing.

This script is provided for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the script to study how different markets expand from early-session balance. The most valuable insight is not a single label, but the repeated relationship between range quality, acceptance, room, and market context.

## Source Code

````pine
// -------------------------------------------------
// Session Range Expansion Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Session Range Expansion Planner is an intraday range expansion and
// execution-readiness tool. It builds the initial balance of a selected
// session, tracks whether price expands beyond that range, evaluates
// acceptance, volume support, volatility fit, and target-room quality,
// then converts the result into a 0-100 planner score with focused chart
// zones, premium event badges, and a compact AGPro decision panel. Version
// 1.6 adds an expansion follow-rate proof and contrast-safe badge text.
// Version 1.7 moves the live range map into clean projection space, preserves
// sparse event history, and aligns the panel language with analytical state.
// -------------------------------------------------

//@version=6
indicator("Session Range Expansion Planner [AGPro Series]",
     shorttitle = "AG Pro SR",
     overlay = true,
     max_boxes_count = 90,
     max_labels_count = 150,
     max_lines_count = 140)

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
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupSession = "Session Engine"
sessionTz = input.string("America/New_York", "Session Timezone", group = groupSession, tooltip = "Timezone used to evaluate the expansion session. Match this with the market session you want to study.")
expansionSession = input.session("0000-2359", "Expansion Session", group = groupSession, tooltip = "Main intraday session used by the planner. The first bars of this session define the initial balance range. The default full-day session works cleanly on crypto and 24-hour symbols.")
balanceBars = input.int(4, "Balance Window Bars", minval = 2, maxval = 40, group = groupSession, tooltip = "Number of early-session bars used to define the balance high and balance low. Lower values react faster; higher values create a more stable range.")
acceptanceBars = input.int(3, "Acceptance Bars", minval = 1, maxval = 10, group = groupSession, tooltip = "Number of closes beyond the balance boundary required before the expansion is treated as accepted.")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Early", "Balanced", "Strict"], group = groupSession, tooltip = "Controls how quickly the planner recognizes a range break. Strict requires cleaner closes; Early is more responsive.")
confirmationMode = input.string("Close Acceptance", "Confirmation Mode", options = ["Close Acceptance", "Wick Break + Close", "Strict Acceptance"], group = groupSession, tooltip = "Defines the break confirmation style before the planner starts measuring expansion quality.")
minPlannerScore = input.int(62, "Minimum Planner Score", minval = 1, maxval = 100, group = groupSession, tooltip = "Minimum 0-100 planner score required before the panel shows the expansion as review-ready.")

groupModel = "Score Model"
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupModel, tooltip = "ATR length used for range normalization, label spacing, and volatility fit.")
volLength = input.int(30, "Volume Average Length", minval = 2, maxval = 200, group = groupModel, tooltip = "Average volume length used to evaluate whether the expansion is supported by participation.")
obstacleLookback = input.int(60, "Obstacle Lookback", minval = 10, maxval = 300, group = groupModel, tooltip = "Lookback used to estimate nearby swing obstacles that may reduce target-room quality.")
targetRoomMult = input.float(1.00, "Target Room Range Multiplier", minval = 0.25, maxval = 4.00, step = 0.05, group = groupModel, tooltip = "Projected target-room distance measured from the broken balance boundary. It scales from the larger value of session range or ATR.")
volatilityMin = input.float(0.70, "Minimum ATR Regime", minval = 0.20, maxval = 2.00, step = 0.05, group = groupModel, tooltip = "Lower ATR regime boundary used in the volatility-fit score. Very low values often indicate quiet expansion conditions.")
volatilityMax = input.float(1.90, "Maximum ATR Regime", minval = 0.80, maxval = 5.00, step = 0.05, group = groupModel, tooltip = "Upper ATR regime boundary used in the volatility-fit score. Very high values can indicate noisy or unstable expansion conditions.")
expansionProofWindow = input.int(20, "Expansion Proof Window (bars)", minval = 4, maxval = 200, group = groupModel, tooltip = "Number of bars an accepted expansion has to follow through within, for the Expansion Rate proof. It only measures historical follow-through and is not a forecast.")

groupVisual = "Visuals"
visualTfPreset = input.string("2H and lower", "Visual Timeframe Preset", options = ["1H and lower", "2H and lower", "4H and lower", "All intraday"], group = groupVisual, tooltip = "Controls which intraday timeframes show chart objects. The default focuses on 2H and lower so the public chart stays premium instead of showing too many compressed session boxes.")
showBalanceBox = input.bool(true, "Show Session Range Box", group = groupVisual, tooltip = "Shows the session balance box with a compact centered badge instead of native box text.")
showRangeBadges = input.bool(true, "Show Range Box Badges", group = groupVisual, tooltip = "Keeps every visible session range box labeled with a centered premium badge. This prevents unlabeled zones on higher intraday views.")
showTargetRoom = input.bool(true, "Show Target-Room Band", group = groupVisual, tooltip = "Shows the concept-native target-room band after an accepted expansion is detected.")
showHistoricalZones = input.bool(false, "Show Historical Zones", group = groupVisual, tooltip = "When enabled, prior session range and target-room zones are retained. Disabled by default so public charts focus on the active session plan.")
showBoundaryRails = input.bool(true, "Show Range Rails", group = groupVisual, tooltip = "Shows high and low rails for the session balance range.")
showLabels = input.bool(true, "Show Planner Labels", group = groupVisual, tooltip = "Shows event labels for range completion, expansion, acceptance, rejection, and room checks.")
showExpansionLabels = input.bool(false, "Show Expansion Break Labels", group = groupVisual, tooltip = "Shows the first expansion break label. Disabled by default to keep the public preset cleaner.")
showRoomCheckLabels = input.bool(false, "Show Room Check Labels", group = groupVisual, tooltip = "Shows a label when the projected target-room area is reached. Disabled by default because the target-room band already provides context.")
showRangeSetLabels = input.bool(false, "Show Range Set Labels", group = groupVisual, tooltip = "Shows an extra label when the balance window completes. Disabled by default because the centered range badge already identifies each completed session range.")
minVisualScore = input.int(70, "Minimum Visual Score", minval = 1, maxval = 100, group = groupVisual, tooltip = "Minimum planner score required before accepted expansion, rejection, and target-room visuals are shown in the default publication preset.")
labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls the font size of all on-chart planner labels and zone badges.")
labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.05, maxval = 2.00, step = 0.05, group = groupVisual, tooltip = "ATR-based distance used to keep event labels away from candles.")
labelBgTransp = input.int(8, "Label Background Transparency", minval = 0, maxval = 90, group = groupVisual, tooltip = "Transparency of label backgrounds. Lower values make labels stronger; higher values make them softer.")
targetExtendBars = input.int(18, "Target Band Extension Bars", minval = 4, maxval = 120, group = groupVisual, tooltip = "Number of bars used to project the target-room band forward from the accepted expansion area.")
cooldownBars = input.int(14, "Event Label Cooldown Bars", minval = 1, maxval = 80, group = groupVisual, tooltip = "Minimum spacing between repeated event labels so the chart stays readable.")
maxVisibleObjects = input.int(5, "Max Visible Objects", minval = 3, maxval = 90, group = groupVisual, tooltip = "Maximum stored boxes, labels, and lines per object family. Lower values keep historical charts lighter.")
maxRangeLabels = input.int(3, "Max Range Labels", minval = 1, maxval = 25, group = groupVisual, tooltip = "Maximum number of centered range labels kept on the chart. This keeps higher-timeframe views readable while preserving range boxes.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AGPro decision panel. Enabled by default for public-chart readability.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Controls where the planner panel is anchored on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Controls panel colors. Dark uses the AGPro slate theme; Light uses a clean publication-friendly layout.")
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls the font size used inside the planner panel.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_label_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        => position.top_right

f_score_text(float value) =>
    str.tostring(math.round(value))

f_side_text(int side) =>
    side == 1 ? "Upside" : side == -1 ? "Downside" : "Neutral"

f_side_color(int side) =>
    side == 1 ? bullColor : side == -1 ? bearColor : neutralColor

f_side_text_color(int side) =>
    color bg = f_side_color(side)
    float yiq = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_panel_body_bg(string theme) =>
    theme == "Dark" ? panelBg : color.rgb(248, 250, 252)

f_panel_alt_bg(string theme) =>
    theme == "Dark" ? color.rgb(20, 31, 52) : color.rgb(241, 245, 249)

f_panel_label(string theme) =>
    theme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)

f_panel_value(string theme) =>
    theme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)

var box[] boxStore = array.new_box()
var label[] labelStore = array.new_label()
var label[] eventLabelStore = array.new_label()
var label[] rangeLabelStore = array.new_label()
var line[] lineStore = array.new_line()

f_keep_box(box item) =>
    if not na(item)
        array.push(boxStore, item)
        while array.size(boxStore) > maxVisibleObjects
            box.delete(array.shift(boxStore))

f_keep_label(label item) =>
    if not na(item)
        array.push(labelStore, item)
        while array.size(labelStore) > maxVisibleObjects
            label.delete(array.shift(labelStore))

f_keep_event_label(label item) =>
    if not na(item)
        array.push(eventLabelStore, item)
        while array.size(eventLabelStore) > maxVisibleObjects
            label.delete(array.shift(eventLabelStore))

f_keep_range_label(label item) =>
    if not na(item)
        array.push(rangeLabelStore, item)
        while array.size(rangeLabelStore) > maxRangeLabels
            label.delete(array.shift(rangeLabelStore))

f_keep_line(line item) =>
    if not na(item)
        array.push(lineStore, item)
        while array.size(lineStore) > maxVisibleObjects
            line.delete(array.shift(lineStore))

f_clear_boxes() =>
    while array.size(boxStore) > 0
        box oldBox = array.shift(boxStore)
        if not na(oldBox)
            box.delete(oldBox)

f_clear_labels() =>
    while array.size(labelStore) > 0
        label oldLabel = array.shift(labelStore)
        if not na(oldLabel)
            label.delete(oldLabel)
    while array.size(rangeLabelStore) > 0
        label oldRangeLabel = array.shift(rangeLabelStore)
        if not na(oldRangeLabel)
            label.delete(oldRangeLabel)

f_clear_lines() =>
    while array.size(lineStore) > 0
        line oldLine = array.shift(lineStore)
        if not na(oldLine)
            line.delete(oldLine)

f_mid_bar(int leftBar, int rightBar) =>
    safeLeft = math.max(leftBar, bar_index - 9999)
    int(math.round((safeLeft + rightBar) / 2.0))

// -------------------------------------------------
// Core engine
// -------------------------------------------------
atr = ta.atr(atrLength)
atrUse = math.max(nz(atr, high - low), syminfo.mintick)
atrBase = ta.sma(atr, 100)
volBase = ta.sma(volume, volLength)
isIntraday = timeframe.isintraday
inSession = isIntraday and not na(time(timeframe.period, expansionSession, sessionTz))
visualTfLimit = visualTfPreset == "2H and lower" ? 120 : visualTfPreset == "4H and lower" ? 240 : 60
visualTimeframeOk = isIntraday and (visualTfPreset == "All intraday" or timeframe.isminutes and timeframe.multiplier <= visualTfLimit)
rangeBadgeTimeframeOk = visualTimeframeOk and showRangeBadges
newSessionDay = ta.change(time("D", "0000-2359", sessionTz)) != 0
prevInSession = inSession[1] == true
newSession = inSession and (barstate.isfirst or not prevInSession or newSessionDay)

labelSize = f_label_size(labelFontInput)
panelSize = f_label_size(panelFontInput)

var int sessionStartBar = na
var int barsInSession = 0
var float balanceHigh = na
var float balanceLow = na
var bool balanceReady = false
var int expansionSide = 0
var int expansionStartBar = na
var int acceptCount = 0
var int rejectCount = 0
var bool acceptancePrinted = false
var bool rejectionPrinted = false
var bool targetPrinted = false
var int lastEventLabelBar = na
var box activeBalanceBox = na
var box activeTargetBox = na
var label activeBalanceLabel = na
var label activeTargetLabel = na
var line activeHighRail = na
var line activeLowRail = na

if newSession
    if not showHistoricalZones
        f_clear_boxes()
        f_clear_labels()
        f_clear_lines()
    sessionStartBar := bar_index
    barsInSession := 0
    balanceHigh := high
    balanceLow := low
    balanceReady := false
    expansionSide := 0
    expansionStartBar := na
    acceptCount := 0
    rejectCount := 0
    acceptancePrinted := false
    rejectionPrinted := false
    targetPrinted := false
    lastEventLabelBar := na
    activeBalanceBox := na
    activeTargetBox := na
    activeBalanceLabel := na
    activeTargetLabel := na
    activeHighRail := na
    activeLowRail := na

if inSession
    barsInSession += 1

    if barsInSession <= balanceBars
        balanceHigh := math.max(nz(balanceHigh, high), high)
        balanceLow := math.min(nz(balanceLow, low), low)

    if barsInSession == balanceBars
        balanceReady := true
        if showBalanceBox and visualTimeframeOk
            activeBalanceBox := box.new(bar_index + 1, balanceHigh, bar_index + targetExtendBars, balanceLow, bgcolor = color.new(accentColor, 92), border_color = color.new(accentColor, 35), border_width = 1, text = "")
            f_keep_box(activeBalanceBox)
            if rangeBadgeTimeframeOk
                rangeCenterX = f_mid_bar(bar_index + 1, bar_index + targetExtendBars)
                rangeCenterY = (balanceHigh + balanceLow) / 2.0
                rangeAtrText = str.tostring((balanceHigh - balanceLow) / atrUse, "#.#")
                activeBalanceLabel := label.new(rangeCenterX, rangeCenterY, "RANGE " + rangeAtrText + " ATR", style = label.style_label_center, color = color.new(accentColor, 3), textcolor = f_text_on(accentColor), size = labelSize)
                f_keep_range_label(activeBalanceLabel)

        if showBoundaryRails and visualTimeframeOk
            activeHighRail := line.new(nz(sessionStartBar, bar_index), balanceHigh, bar_index, balanceHigh, color = color.new(accentColor, 10), width = 1, style = line.style_dashed)
            activeLowRail := line.new(nz(sessionStartBar, bar_index), balanceLow, bar_index, balanceLow, color = color.new(accentColor, 10), width = 1, style = line.style_dashed)
            f_keep_line(activeHighRail)
            f_keep_line(activeLowRail)

        if showLabels and showRangeSetLabels and visualTimeframeOk
            rangeLabelY = balanceHigh + atrUse * labelOffsetAtr
            rangeLabel = label.new(bar_index, rangeLabelY, "RANGE SET", style = label.style_label_down, color = color.new(accentColor, labelBgTransp), textcolor = f_text_on(accentColor), size = labelSize)
            f_keep_event_label(rangeLabel)

    if showBalanceBox and visualTimeframeOk and not na(activeBalanceBox)
        box.set_left(activeBalanceBox, bar_index + 1)
        box.set_right(activeBalanceBox, bar_index + targetExtendBars)
        box.set_top(activeBalanceBox, balanceHigh)
        box.set_bottom(activeBalanceBox, balanceLow)
        box.set_text(activeBalanceBox, "")

    if showBalanceBox and visualTimeframeOk and rangeBadgeTimeframeOk and not na(activeBalanceLabel)
        labelCenterX = f_mid_bar(bar_index + 1, bar_index + targetExtendBars)
        labelCenterY = (balanceHigh + balanceLow) / 2.0
        rangeText = "RANGE " + str.tostring((balanceHigh - balanceLow) / atrUse, "#.#") + " ATR"
        label.set_x(activeBalanceLabel, labelCenterX)
        label.set_y(activeBalanceLabel, labelCenterY)
        label.set_text(activeBalanceLabel, rangeText)
        label.set_size(activeBalanceLabel, labelSize)
    else if not rangeBadgeTimeframeOk and not na(activeBalanceLabel)
        label.delete(activeBalanceLabel)
        activeBalanceLabel := na

    if showBoundaryRails and visualTimeframeOk and not na(activeHighRail)
        line.set_x2(activeHighRail, bar_index + targetExtendBars)
        line.set_y1(activeHighRail, balanceHigh)
        line.set_y2(activeHighRail, balanceHigh)

    if showBoundaryRails and visualTimeframeOk and not na(activeLowRail)
        line.set_x2(activeLowRail, bar_index + targetExtendBars)
        line.set_y1(activeLowRail, balanceLow)
        line.set_y2(activeLowRail, balanceLow)

rangeSize = math.max(balanceHigh - balanceLow, syminfo.mintick)
rangeBase = math.max(rangeSize, atrUse)
upperBoundary = balanceHigh
lowerBoundary = balanceLow
midRange = (balanceHigh + balanceLow) / 2.0

breakBuffer = sensitivity == "Early" ? 0.00 : sensitivity == "Balanced" ? atrUse * 0.03 : atrUse * 0.08
upCloseOk = close > upperBoundary + breakBuffer
downCloseOk = close < lowerBoundary - breakBuffer
upWickOk = high > upperBoundary + breakBuffer and close > upperBoundary - rangeSize * 0.10
downWickOk = low < lowerBoundary - breakBuffer and close < lowerBoundary + rangeSize * 0.10
upStrictOk = close > upperBoundary + breakBuffer and close[1] > upperBoundary
downStrictOk = close < lowerBoundary - breakBuffer and close[1] < lowerBoundary

confirmUp = confirmationMode == "Strict Acceptance" ? upStrictOk : confirmationMode == "Wick Break + Close" ? upWickOk : upCloseOk
confirmDown = confirmationMode == "Strict Acceptance" ? downStrictOk : confirmationMode == "Wick Break + Close" ? downWickOk : downCloseOk

newExpansionUp = false
newExpansionDown = false

if inSession and balanceReady and expansionSide == 0 and barsInSession > balanceBars
    if confirmUp and not confirmDown
        expansionSide := 1
        expansionStartBar := bar_index
        newExpansionUp := true
    else if confirmDown and not confirmUp
        expansionSide := -1
        expansionStartBar := bar_index
        newExpansionDown := true
    else if confirmUp and confirmDown
        expansionSide := close >= midRange ? 1 : -1
        expansionStartBar := bar_index
        newExpansionUp := expansionSide == 1
        newExpansionDown := expansionSide == -1

if inSession and balanceReady and expansionSide != 0
    if expansionSide == 1
        acceptCount := close > upperBoundary ? acceptCount + 1 : math.max(0, acceptCount - 1)
        rejectCount := close < upperBoundary ? rejectCount + 1 : 0
    else
        acceptCount := close < lowerBoundary ? acceptCount + 1 : math.max(0, acceptCount - 1)
        rejectCount := close > lowerBoundary ? rejectCount + 1 : 0

accepted = expansionSide != 0 and acceptCount >= acceptanceBars
rejected = expansionSide != 0 and rejectCount >= acceptanceBars

// -------------------------------------------------
// Expansion follow-rate proof (Confirm Rate)
// -------------------------------------------------
// When an expansion is accepted beyond the balance boundary, does price follow
// through 0.75 ATR in the expansion direction before falling back inside the
// range or the window expires? Counted once per accepted expansion. A return
// inside the boundary, or a window expiry with no follow-through, is treated as
// not-followed (conservative).
float exMargin = math.max(nz(atrUse), syminfo.mintick) * 0.75
var int   exTotal = 0
var int   exWon    = 0
var bool  exPend    = false
var int   exDir      = 0
var float exAnchor    = na
var float exRef        = na
var int   exLeft        = 0
bool exFire = accepted and not (bar_index > 0 ? accepted[1] : false) and expansionSide != 0

if barstate.isconfirmed
    if exPend and not na(exAnchor) and not na(exRef)
        bool exFailed = exDir > 0 ? close < exRef : close > exRef
        bool exFollowed = exDir > 0 ? close >= exAnchor + exMargin : close <= exAnchor - exMargin
        if exFailed
            exTotal += 1
            exPend := false
        else if exFollowed
            exTotal += 1
            exWon += 1
            exPend := false
        else
            exLeft -= 1
            if exLeft <= 0
                exTotal += 1
                exPend := false
    if exFire and not exPend
        exDir := expansionSide
        exAnchor := close
        exRef := expansionSide == 1 ? upperBoundary : lowerBoundary
        exLeft := expansionProofWindow
        exPend := true

float exRate = exTotal > 0 ? exWon / exTotal * 100.0 : na
string expansionRateRead = exTotal > 0 ? str.tostring(math.round(exRate)) + "% (" + str.tostring(exTotal) + ")" : "Building"
color expansionRateCol = na(exRate) ? f_panel_value(panelTheme) : exRate >= 60.0 ? bullColor : exRate >= 45.0 ? neutralColor : bearColor

targetDistance = rangeBase * targetRoomMult
targetLevel = expansionSide == 1 ? upperBoundary + targetDistance : expansionSide == -1 ? lowerBoundary - targetDistance : na
targetTop = expansionSide == 1 ? targetLevel : lowerBoundary
targetBottom = expansionSide == 1 ? upperBoundary : targetLevel

recentHigh = ta.highest(high, obstacleLookback)[1]
recentLow = ta.lowest(low, obstacleLookback)[1]
obstacleRoom = expansionSide == 1 ? (recentHigh > close ? recentHigh - close : targetDistance) : expansionSide == -1 ? (recentLow < close ? close - recentLow : targetDistance) : 0.0
roomRatio = targetDistance > 0 ? f_clamp(obstacleRoom / targetDistance, 0.0, 1.0) : 0.0
roomScore = expansionSide == 0 ? 0.0 : roomRatio * 100.0

breakDistance = expansionSide == 1 ? math.max(close - upperBoundary, 0.0) : expansionSide == -1 ? math.max(lowerBoundary - close, 0.0) : 0.0
breakScore = expansionSide == 0 ? 0.0 : f_clamp(breakDistance / atrUse * 22.0, 0.0, 22.0)
acceptanceScore = expansionSide == 0 ? 0.0 : f_clamp(acceptCount / math.max(acceptanceBars, 1) * 25.0, 0.0, 25.0)
volRatio = na(volume) or na(volBase) or volBase == 0.0 ? 1.0 : volume / volBase
volumeScore = f_clamp((volRatio - 0.70) / 0.80 * 15.0, 0.0, 15.0)
atrRatio = na(atrBase) or atrBase == 0.0 ? 1.0 : atrUse / atrBase
volatilityCenter = (volatilityMin + volatilityMax) / 2.0
volatilityWidth = math.max((volatilityMax - volatilityMin) / 2.0, 0.10)
volatilityScore = f_clamp(1.0 - math.abs(atrRatio - volatilityCenter) / volatilityWidth, 0.0, 1.0) * 18.0
roomComponent = roomScore * 0.20
plannerScore = expansionSide == 0 ? 0.0 : f_clamp(breakScore + acceptanceScore + volumeScore + volatilityScore + roomComponent, 0.0, 100.0)
visualQualified = plannerScore >= minVisualScore

atrState = atrRatio < volatilityMin ? "Quiet ATR" : atrRatio > volatilityMax ? "Noisy ATR" : "Balanced ATR"
atrStateColor = atrRatio < volatilityMin ? accentColor : atrRatio > volatilityMax ? neutralColor : bullColor
if showTargetRoom and visualTimeframeOk and inSession and accepted and visualQualified and not na(targetLevel)
    if na(activeTargetBox)
        activeTargetBox := box.new(bar_index + 1, targetTop, bar_index + targetExtendBars, targetBottom, bgcolor = color.new(f_side_color(expansionSide), 90), border_color = color.new(f_side_color(expansionSide), 28), border_width = 1, text = "")
        f_keep_box(activeTargetBox)
        activeTargetLabel := label.new(f_mid_bar(bar_index + 1, bar_index + targetExtendBars), (targetTop + targetBottom) / 2.0, "ROOM " + f_score_text(roomScore) + " | OPEN", style = label.style_label_center, color = color.new(f_side_color(expansionSide), 3), textcolor = f_side_text_color(expansionSide), size = labelSize)
        f_keep_label(activeTargetLabel)
    else
        box.set_left(activeTargetBox, bar_index + 1)
        box.set_right(activeTargetBox, bar_index + targetExtendBars)
        box.set_top(activeTargetBox, targetTop)
        box.set_bottom(activeTargetBox, targetBottom)
        box.set_text(activeTargetBox, "")

    if not na(activeTargetLabel)
        targetLabelX = f_mid_bar(bar_index + 1, bar_index + targetExtendBars)
        targetLabelY = (targetTop + targetBottom) / 2.0
        label.set_x(activeTargetLabel, targetLabelX)
        label.set_y(activeTargetLabel, targetLabelY)
        label.set_text(activeTargetLabel, "ROOM " + f_score_text(roomScore) + " | OPEN")
        label.set_size(activeTargetLabel, labelSize)

targetTouched = expansionSide == 1 ? high >= targetLevel : expansionSide == -1 ? low <= targetLevel : false
canPrintEvent = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= cooldownBars

if showLabels and visualTimeframeOk and showExpansionLabels and (newExpansionUp or newExpansionDown) and canPrintEvent
    eventSide = newExpansionUp ? 1 : -1
    eventY = eventSide == 1 ? high + atrUse * labelOffsetAtr : low - atrUse * labelOffsetAtr
    eventStyle = eventSide == 1 ? label.style_label_down : label.style_label_up
    eventText = (eventSide == 1 ? "TRACK UP" : "TRACK DOWN") + "\n" + f_score_text(plannerScore)
    eventLabel = label.new(bar_index, eventY, eventText, style = eventStyle, color = color.new(f_side_color(eventSide), labelBgTransp), textcolor = f_side_text_color(eventSide), size = labelSize)
    f_keep_event_label(eventLabel)
    lastEventLabelBar := bar_index

if showLabels and visualTimeframeOk and accepted and not acceptancePrinted and visualQualified and canPrintEvent
    acceptY = expansionSide == 1 ? high + atrUse * labelOffsetAtr : low - atrUse * labelOffsetAtr
    acceptStyle = expansionSide == 1 ? label.style_label_down : label.style_label_up
    acceptText = "REVIEW " + f_score_text(plannerScore)
    acceptLabel = label.new(bar_index, acceptY, acceptText, style = acceptStyle, color = color.new(f_side_color(expansionSide), labelBgTransp), textcolor = f_side_text_color(expansionSide), size = labelSize)
    f_keep_event_label(acceptLabel)
    acceptancePrinted := true
    lastEventLabelBar := bar_index

if showLabels and visualTimeframeOk and rejected and not rejectionPrinted and visualQualified and canPrintEvent
    rejectY = expansionSide == 1 ? low - atrUse * labelOffsetAtr : high + atrUse * labelOffsetAtr
    rejectStyle = expansionSide == 1 ? label.style_label_up : label.style_label_down
    rejectLabel = label.new(bar_index, rejectY, "STAND DOWN", style = rejectStyle, color = color.new(neutralColor, labelBgTransp), textcolor = darkText, size = labelSize)
    f_keep_event_label(rejectLabel)
    rejectionPrinted := true
    lastEventLabelBar := bar_index

if showLabels and visualTimeframeOk and showRoomCheckLabels and targetTouched and not targetPrinted and expansionSide != 0
    targetY = expansionSide == 1 ? high + atrUse * labelOffsetAtr : low - atrUse * labelOffsetAtr
    targetStyle = expansionSide == 1 ? label.style_label_down : label.style_label_up
    targetHitLabel = label.new(bar_index, targetY, "ROOM CHECK", style = targetStyle, color = color.new(accentColor, labelBgTransp), textcolor = f_text_on(accentColor), size = labelSize)
    f_keep_event_label(targetHitLabel)
    targetPrinted := true
    lastEventLabelBar := bar_index

timeframeHint = visualTfPreset == "1H and lower" ? "Use 1H or lower" : visualTfPreset == "2H and lower" ? "Use 2H or lower" : visualTfPreset == "4H and lower" ? "Use 4H or lower" : "Use intraday"
sessionRangeText = not isIntraday ? "Intraday only" : not visualTimeframeOk ? "Lower timeframe" : balanceReady ? str.tostring(rangeSize / atrUse, "#.##") + " ATR" : inSession ? "Building" : "Waiting"
acceptanceText = expansionSide == 0 ? "No expansion" : accepted ? str.tostring(math.min(acceptCount, acceptanceBars)) + "/" + str.tostring(acceptanceBars) + " accepted" : rejected ? "Rejected" : str.tostring(math.min(acceptCount, acceptanceBars)) + "/" + str.tostring(acceptanceBars) + " testing"
scoreText = expansionSide == 0 ? "0" : f_score_text(plannerScore)
roomText = expansionSide == 0 ? "0" : f_score_text(roomScore)
workflowText = not isIntraday ? "Intraday Only" : not visualTimeframeOk ? timeframeHint : not inSession ? "Wait Session" : not balanceReady ? "Build Range" : expansionSide == 0 ? "Watch Expansion" : rejected ? "Stand Down" : accepted and plannerScore >= minPlannerScore and roomScore >= 45 ? "Review Expansion" : accepted ? "Check Room" : "Track Acceptance"
reviewText = not isIntraday ? "Switch lower TF" : not visualTimeframeOk ? "Lower TF needed" : atrRatio > volatilityMax ? "Noisy context" : accepted and plannerScore >= minPlannerScore ? "Review context" : rejected ? "Stand down" : expansionSide != 0 ? "Track acceptance" : "Wait setup"
valueTone = rejected ? neutralColor : accepted and plannerScore >= minPlannerScore ? f_side_color(expansionSide) : neutralColor

// -------------------------------------------------
// Premium panel
// -------------------------------------------------
var table plannerPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

f_panel_row(table target, int row, string labelText, string valueText, color valueColor, string theme, string fontSize) =>
    rowBg = row % 2 == 0 ? f_panel_alt_bg(theme) : f_panel_body_bg(theme)
    table.cell(target, 0, row, labelText, bgcolor = rowBg, text_color = f_panel_label(theme), text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, valueText, bgcolor = rowBg, text_color = valueColor, text_size = f_label_size(fontSize), text_halign = text.align_right)

if barstate.islast
    if showPanel
        if na(plannerPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme
            if not na(plannerPanel)
                table.delete(plannerPanel)
            plannerPanel := table.new(f_panel_pos(panelLocation), 2, 9, bgcolor = f_panel_body_bg(panelTheme), border_width = 1, border_color = panelBorder, frame_color = panelBorder, frame_width = 1)
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
        table.clear(plannerPanel, 0, 0, 1, 8)
        table.merge_cells(plannerPanel, 0, 0, 1, 0)
        table.cell(plannerPanel, 0, 0, "AG Pro Session Range Expansion Planner", bgcolor = headerBg, text_color = headerText, text_size = panelSize, text_halign = text.align_center)
        f_panel_row(plannerPanel, 1, "Workflow", workflowText, valueTone, panelTheme, panelFontInput)
        f_panel_row(plannerPanel, 2, "Planner Score", scoreText + "/100", valueTone, panelTheme, panelFontInput)
        f_panel_row(plannerPanel, 3, "Expansion Rate", expansionRateRead, expansionRateCol, panelTheme, panelFontInput)
        f_panel_row(plannerPanel, 4, "Range State", sessionRangeText, f_panel_value(panelTheme), panelTheme, panelFontInput)
        f_panel_row(plannerPanel, 5, "Expansion Side", f_side_text(expansionSide), f_side_color(expansionSide), panelTheme, panelFontInput)
        f_panel_row(plannerPanel, 6, "Acceptance", acceptanceText, accepted ? f_side_color(expansionSide) : neutralColor, panelTheme, panelFontInput)
        f_panel_row(plannerPanel, 7, "ATR Context", atrState + " / " + str.tostring(atrRatio, "#.##") + "x", atrStateColor, panelTheme, panelFontInput)
        f_panel_row(plannerPanel, 8, "Review", reviewText, accepted ? f_side_color(expansionSide) : neutralColor, panelTheme, panelFontInput)
    else if not na(plannerPanel)
        table.delete(plannerPanel)
        plannerPanel := na
        lastPanelLocation := ""
        lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newExpansionUp, "Session Range Expansion Up", "Session Range Expansion Planner detected upside range expansion context. Review acceptance, room score, and broader market conditions.")
alertcondition(newExpansionDown, "Session Range Expansion Down", "Session Range Expansion Planner detected downside range expansion context. Review acceptance, room score, and broader market conditions.")
alertcondition(accepted and accepted[1] == false, "Session Range Expansion Accepted", "Session Range Expansion Planner marked accepted expansion beyond the session range for review.")
alertcondition(rejected and rejected[1] == false, "Session Range Expansion Rejection Risk", "Session Range Expansion Planner marked rejection-risk context after a session range expansion.")

plot(exRate, title = "Expansion Follow Rate", color = bullColor, display = display.data_window)
````
