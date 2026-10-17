# AG Pro Daily Open Acceptance Map [AGPro Series]

- url: https://www.tradingview.com/script/yYmrm0cK-AG-Pro-Daily-Open-Acceptance-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;69cc9b7e2b0d4dfcac58c5b6f75b3746
- version: 6.0

## Description

AG PRO DAILY OPEN ACCEPTANCE MAP [AGPRO SERIES]

OVERVIEW
AG Pro Daily Open Acceptance Map is an intraday overlay built to track how price behaves around the current daily open and to present that behavior in a clean, rules-based structure. Instead of treating the daily open as a passive reference line, this script evaluates whether price is being accepted above it, accepted below it, or repeatedly failing around it.

The core design goal is clarity. Many traders use the daily open as a contextual anchor, but in practice it is often shown as only a simple line with no structured interpretation. This script is designed to go one step further by turning that level into a mapped decision framework. The result is a chart that helps users read whether the market is holding one side of the daily open with acceptance, drifting into indecision, or failing to maintain directional control.

This tool is intentionally narrow in scope. It is not built as a full market structure engine, a session model, a prior high/low dashboard, a VWAP tool, or a moving average framework. Its role is much more specific: to organize the behavior of price around the daily open and to express that behavior through a compact state model, visual reference lines, and confirmed state transitions.

Because the daily open resets every trading day, the script also produces a recurring intraday reference that can be reused across many symbols and market conditions. This makes it useful for users who prefer repeatable visual anchors instead of highly discretionary chart interpretation.

WHAT IT DOES
This script identifies the current daily open and treats it as the primary intraday reference level. From there, it evaluates whether price is holding above the level, holding below the level, or still testing the area without confirmation. It also tracks the first reclaim event when enabled, allowing users to see whether the market has recovered one side of the level after losing it earlier in the day.

The overlay is structured so the current daily open remains the main visual anchor, while the previous daily open can be shown as a lighter secondary context level. Acceptance areas and state mapping are kept as supporting elements rather than replacing the open itself. This keeps the chart readable while still preserving a visual record of how the market behaved around the level throughout the session.

In practical terms, the script helps answer a simple but important question: is price truly holding one side of the daily open, or is it only rotating around it without meaningful acceptance?

HOW THIS DIFFERS FROM OTHER AG PRO TOOLS
This script is intentionally separated from the logic families used in other AG Pro tools.

It does not rely on VWAP behavior.
It does not build decisions from EMA or moving average relationships.
It does not classify price by prior day or prior week high/low structures.
It does not depend on sweep, stop hunt, liquidity trap, or session-kill-zone logic.
It does not function as a structure label, breakout, or order-flow style engine.

The purpose here is much more focused. AG Pro Daily Open Acceptance Map is a daily-open behavior tool. Its main question is not whether a breakout happened, whether liquidity was taken, or whether a trend indicator flipped. Its main question is whether the market is accepting or rejecting one side of the current daily open.

That narrow positioning is deliberate. It helps keep the chart logic cleaner, the visual language simpler, and the use case easier to understand.

UNIQUE EDGE
The unique edge of this script is not the presence of a daily open line by itself. Many tools can plot a daily open. The distinctive part of this indicator is the state framework built around that line.

Instead of only drawing the level, the script evaluates market behavior around it and converts that into a practical overlay language. The chart can therefore communicate whether the market is in bullish acceptance, bearish acceptance, or unresolved testing, rather than forcing the user to interpret every interaction manually.

The script also separates the current daily open from the previous daily open in a clear visual hierarchy. The current open is treated as the primary live anchor, while the previous open is optional secondary context. This helps users compare the active intraday reference against the prior session without turning the chart into a multi-level dashboard.

Another advantage is that the visual model remains compact. The script is designed to offer information density without becoming visually noisy, which is especially important on publish screenshots and on charts where traders prefer a clean price-first layout.

METHODOLOGY
The script starts by identifying the current daily open and, when enabled, the previous daily open. The current daily open becomes the main reference for all live state calculations.

From there, the script measures whether price is sustaining closes above the level, sustaining closes below the level, or remaining in a testing state around the level. The filter mode can be adjusted to make the interpretation more responsive or more selective. In more permissive settings, state shifts can appear earlier. In stricter settings, price generally needs cleaner confirmation before a state is recognized.

When reclaim logic is enabled, the script also monitors whether one side of the daily open is recovered after being lost earlier in the day. This is not treated as a separate prediction model. It is simply an additional contextual event that can help users understand whether the market is recovering control around the open after temporary failure.

The acceptance area, open zone, and state ribbon are visual support layers. They are not intended to replace price or overwhelm the chart. Their purpose is to make the interpretation easier to read while keeping the current daily open as the main anchor.

SIGNALS AND ALERTS
The script supports confirmed-bar style logic so that state changes can be tracked in a more stable way. Depending on the enabled settings, users can monitor:

Bullish acceptance conditions
Bearish acceptance conditions
Testing or unresolved behavior around the daily open
First reclaim context when enabled
General state transitions when the market changes side or loses control

These alerts and visual states are intended for chart organization and condition awareness. They should not be interpreted as guaranteed trade outcomes, guaranteed continuation signals, or automated execution instructions.

KEY INPUTS
FILTER MODE
Users can switch between stricter and more responsive behavior depending on how selective they want the state model to be.

HOLD / CONFIRMATION SETTINGS
These controls affect how much sustained price behavior is required before the script recognizes an accepted state.

TOLERANCE AND OPEN ZONE SETTINGS
These help define how tightly or loosely the script interprets price behavior around the daily open area.

FIRST RECLAIM SETTINGS
These controls determine whether reclaim events are tracked as part of the daily open behavior model.

DISPLAY SETTINGS
Users can control whether the current daily open, previous daily open, acceptance area, ribbon, labels, and panel elements are shown.

VISUAL SIZE SETTINGS
Panel and label sizing can be adjusted depending on symbol volatility, screen resolution, and chart density preferences.

LIMITATIONS AND TRANSPARENCY
This script is not a forecasting engine. It does not predict where price must go next. It evaluates how price is behaving relative to the current daily open and displays that information in a structured way.

It is also not a substitute for complete market analysis. It does not include broader trend context, liquidity analysis, volume profile logic, macro structure interpretation, news impact, or instrument-specific catalysts unless the user applies those separately.

Different symbols and timeframes can also produce different daily open behavior. In some instruments the daily open may act as a very strong intraday reference, while in others price may rotate around it more loosely. Because of that, the script should be interpreted as a contextual decision aid rather than a universal standalone solution.

The previous daily open is included only as optional secondary context. It does not drive the main state model. The main live logic is built around the current daily open.

RISK DISCLOSURE
This script is provided for market analysis, chart organization, and educational use. It does not provide financial advice, investment advice, or guaranteed trade signals. No indicator can remove market risk, and no visual state model can ensure a profitable result.

Traders should use their own judgment, position sizing rules, and risk management process before making any decision. This tool can help structure chart interpretation, but execution responsibility always remains with the user.

## Source Code

````pine
// -------------------------------------------------
// Daily Open Acceptance Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Daily Open Acceptance Map turns the current session's daily open into a
// decision layer. It scores acceptance readiness 0-100, tracks how price
// accepts, rejects and reclaims the daily open, proves how often confirmed
// acceptances keep holding (Hold Rate), and renders ATR-scaled tolerance,
// hold-bar confirmation, first reclaim detection, acceptance zones, collision-
// safe centered premium zone badges, price-true reference tags and an AG Pro
// panel with a clear next action for intraday daily open control and market
// structure review.
// -------------------------------------------------

//@version=6
indicator("Daily Open Acceptance Map [AGPro Series]",
     shorttitle       = "DOAM",
     overlay          = true,
     max_labels_count = 200,
     max_lines_count  = 120,
     max_boxes_count  = 80)

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
prevOpenColor = color.rgb(148, 163, 184)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_FILTER = "Normal reacts faster to daily-open acceptance shifts. Strict requires stronger hold and distance confirmation before acceptance is confirmed."
const string TT_NORMAL_HOLD = "Number of confirmed bars price must hold above or below the daily open before acceptance is allowed in Normal mode."
const string TT_STRICT_HOLD = "Number of confirmed bars price must hold above or below the daily open before acceptance is allowed in Strict mode."
const string TT_NORMAL_TOL = "ATR-based distance from the daily open required in Normal mode. This helps filter tiny open-line noise."
const string TT_STRICT_TOL = "ATR-based distance from the daily open required in Strict mode. Higher values require clearer separation from the open."
const string TT_REJECT_LOOKBACK = "Lookback used to detect failed probes through the daily open before a reclaim or reject state can be marked."
const string TT_RECLAIM_BONUS = "Allows the first confirmed daily-open reclaim to slightly reduce the hold requirement for the new acceptance side."
const string TT_REJECT_BARS = "Number of bars a rejection state remains active after a confirmed failed move through the daily open."
const string TT_ATR = "ATR length used for tolerance, zones, right-side tags, and event-label spacing."
const string TT_ACCEPT_ZONE = "ATR-scaled depth of the acceptance zone above or below the daily open."
const string TT_OPEN_ZONE = "ATR-scaled width of the micro-zone around the daily open."
const string TT_PROJECTION = "How far current-day open and acceptance structures project to the right."
const string TT_CONFIRM = "Forward window (in bars) used to measure how often a confirmed acceptance keeps holding on its side before price breaks back through the daily open. Feeds the Hold Rate proof and the Readiness score."
const string TT_ACTIVE_ONLY = "Shows only the current-day map by default. This keeps the chart premium and avoids historical step-line clutter."
const string TT_MINIMAL = "Reduces supporting visuals so the daily open and panel remain the main focus."
const string TT_DOPEN = "Displays the current session's daily open as the main acceptance anchor."
const string TT_PREVOPEN = "Displays the previous session's daily open as a secondary reference."
const string TT_OPEN_ZONE_SHOW = "Displays a light contextual zone around the daily open while acceptance is unresolved. Once acceptance confirms, the acceptance zone takes visual priority and the micro-zone is hidden to prevent overlap."
const string TT_ACCEPT_SHOW = "Displays the active acceptance zone when price confirms above or below the daily open."
const string TT_HISTORY = "Adds subtle historical fills for users who want more context. Disabled by default to keep publication screenshots clean."
const string TT_ZONE_TEXT = "Shows readiness detail inside each centered zone badge. When disabled, every visible zone keeps a compact centered identity so no zone is left unlabeled."
const string TT_LIVE_TAGS = "Displays Today D-Open and previous daily open tags on the right side of the chart, anchored directly to their true reference prices."
const string TT_STATE_TAG = "Shows an extra right-side state tag with the readiness score. Disabled by default because the active acceptance zone already carries the current state."
const string TT_EVENTS = "Shows confirmed event labels such as first reclaim, acceptance, and rejection states."
const string TT_CONTEXT = "Adds sparse context labels during active acceptance or reject states so the chart has a readable story without clutter."
const string TT_MARKERS = "Shows compact marker dots for confirmed state changes. Disabled by default because labels and zones already carry the story."
const string TT_DENSITY = "Controls event label retention. Balanced is tuned for publication screenshots with context but without crowding."
const string TT_FONT = "Controls chart label size. Normal is the recommended publication default."
const string TT_OFFSET = "ATR-based vertical spacing used to keep event labels clear of candles."
const string TT_SPACING = "Minimum number of bars between repeated event labels."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro daily open acceptance panel."
const string TT_PANEL_POS = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between AGPro dark and clean light themes."
const string TT_PANEL_FONT = "Controls panel text size. Normal is the recommended publication default."
const string TT_PRIME_ALERT = "Triggers when a confirmed acceptance also reaches the Prime readiness level."
const string TT_PRIME_LEVEL = "Minimum Readiness score required for a Prime Acceptance alert to fire."

// -------------------------------------------------
// Input groups
// -------------------------------------------------
gFilter  = "Filter Mode"
gEngine  = "Engine"
gDisplay = "Display"
gLabels  = "Labels & Tags"
gPanel   = "Panel"
gAlerts  = "Alerts"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
filterMode           = input.string("Normal", "Filter Mode", options = ["Normal", "Strict"], group = gFilter, tooltip = TT_FILTER)
normalHoldBars       = input.int(1, "Normal Hold Bars", minval = 1, maxval = 5, group = gFilter, tooltip = TT_NORMAL_HOLD)
strictHoldBars       = input.int(2, "Strict Hold Bars", minval = 1, maxval = 6, group = gFilter, tooltip = TT_STRICT_HOLD)
normalTolATR         = input.float(0.05, "Normal ATR Tolerance", minval = 0.00, maxval = 0.60, step = 0.01, group = gFilter, tooltip = TT_NORMAL_TOL)
strictTolATR         = input.float(0.10, "Strict ATR Tolerance", minval = 0.00, maxval = 0.80, step = 0.01, group = gFilter, tooltip = TT_STRICT_TOL)
rejectLookbackNormal = input.int(3, "Normal Reject Lookback", minval = 1, maxval = 12, group = gFilter, tooltip = TT_REJECT_LOOKBACK)
rejectLookbackStrict = input.int(4, "Strict Reject Lookback", minval = 1, maxval = 14, group = gFilter, tooltip = TT_REJECT_LOOKBACK)

useFirstReclaimBonus = input.bool(true, "Use First Reclaim Bonus", group = gEngine, tooltip = TT_RECLAIM_BONUS)
rejectStateBars      = input.int(3, "Reject State Hold Bars", minval = 1, maxval = 12, group = gEngine, tooltip = TT_REJECT_BARS)
atrLen               = input.int(14, "ATR Length", minval = 1, maxval = 100, group = gEngine, tooltip = TT_ATR)
acceptBandATR        = input.float(0.22, "Acceptance Zone ATR", minval = 0.05, maxval = 1.50, step = 0.01, group = gEngine, tooltip = TT_ACCEPT_ZONE)
openZoneATR          = input.float(0.08, "Daily Open Zone ATR", minval = 0.02, maxval = 0.80, step = 0.01, group = gEngine, tooltip = TT_OPEN_ZONE)
projectionBars       = input.int(22, "Active Projection Bars", minval = 4, maxval = 120, group = gEngine, tooltip = TT_PROJECTION)
confirmBars          = input.int(10, "Acceptance Confirm Bars", minval = 3, maxval = 60, group = gEngine, tooltip = TT_CONFIRM)

activeOnly           = input.bool(true, "Active-Only View", group = gDisplay, tooltip = TT_ACTIVE_ONLY)
minimalView          = input.bool(false, "Minimal View", group = gDisplay, tooltip = TT_MINIMAL)
showDailyOpen        = input.bool(true, "Show Daily Open", group = gDisplay, tooltip = TT_DOPEN)
showPrevDailyOpen    = input.bool(true, "Show Previous Daily Open", group = gDisplay, tooltip = TT_PREVOPEN)
showOpenZone         = input.bool(true, "Show Daily Open Zone", group = gDisplay, tooltip = TT_OPEN_ZONE_SHOW)
showAcceptanceZone   = input.bool(true, "Show Acceptance Zone", group = gDisplay, tooltip = TT_ACCEPT_SHOW)
showRangeFill        = input.bool(false, "Show Historical Range Fill", group = gDisplay, tooltip = TT_HISTORY)
showZoneText         = input.bool(true, "Show Detailed Zone Text", group = gDisplay, tooltip = TT_ZONE_TEXT)

showLiveTags         = input.bool(true, "Show Live Tags", group = gLabels, tooltip = TT_LIVE_TAGS)
showStateLiveTag     = input.bool(false, "Show State Live Tag", group = gLabels, tooltip = TT_STATE_TAG)
showEventLabels      = input.bool(true, "Show Event Labels", group = gLabels, tooltip = TT_EVENTS)
showContextLabels    = input.bool(false, "Show Sparse Context Labels", group = gLabels, tooltip = TT_CONTEXT)
showSignalMarkers    = input.bool(false, "Show Signal Markers", group = gLabels, tooltip = TT_MARKERS)
labelDensity         = input.string("Detailed", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels, tooltip = TT_DENSITY)
labelTextInput       = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels, tooltip = TT_FONT)
labelOffsetATR       = input.float(0.82, "Event Label Offset ATR", minval = 0.05, maxval = 2.50, step = 0.05, group = gLabels, tooltip = TT_OFFSET)
liveTagOffsetATR     = input.float(0.48, "Live Tag Offset ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = gLabels, tooltip = "ATR-based vertical spacing used for right-side live tags.")
labelSpacingBars     = input.int(40, "Event Label Min Spacing", minval = 1, maxval = 120, group = gLabels, tooltip = TT_SPACING)
contextSpacingBars   = input.int(70, "Context Label Spacing", minval = 8, maxval = 240, group = gLabels, tooltip = "Minimum number of bars between sparse context labels.")

showPanel            = input.bool(true, "Show Panel", group = gPanel, tooltip = TT_PANEL_SHOW)
panelPos             = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel, tooltip = TT_PANEL_POS)
panelTheme           = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = gPanel, tooltip = TT_PANEL_THEME)
panelTextInput       = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel, tooltip = TT_PANEL_FONT)

alertBullAccept      = input.bool(true, "Alert: Bullish Acceptance", group = gAlerts, tooltip = "Triggers when bullish acceptance above the daily open is confirmed.")
alertBearAccept      = input.bool(true, "Alert: Bearish Acceptance", group = gAlerts, tooltip = "Triggers when bearish acceptance below the daily open is confirmed.")
alertFirstReclaim    = input.bool(true, "Alert: First Reclaim", group = gAlerts, tooltip = "Triggers when the first bullish or bearish reclaim of the daily open is confirmed.")
alertStateChange     = input.bool(true, "Alert: State Change", group = gAlerts, tooltip = "Triggers when the daily open state changes.")
alertPrimeSetup      = input.bool(true, "Alert: Prime Acceptance", group = gAlerts, tooltip = TT_PRIME_ALERT)
primeReadyLevel      = input.int(75, "Prime Readiness Level", minval = 50, maxval = 95, group = gAlerts, tooltip = TT_PRIME_LEVEL)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

f_state_text(int stateValue) =>
    switch stateValue
        1  => "Bull Accept"
        -1 => "Bear Accept"
        2  => "Down Reject"
        -2 => "Up Reject"
        => "Open Test"

f_state_color(int stateValue) =>
    switch stateValue
        1  => bullColor
        -1 => bearColor
        2  => neutralColor
        -2 => neutralColor
        => accentColor

f_ready_band(int score) =>
    score >= 75 ? "Prime" : score >= 55 ? "Building" : score >= 35 ? "Forming" : "Weak"

f_next_action(int stateValue, int score, bool intradayOk) =>
    not intradayOk ? "Switch to intraday TF" :
     stateValue == 1 or stateValue == -1 ? (score >= 75 ? "Manage accepted side" : score >= 55 ? "Confirm continuation" : "Wait for stronger hold") :
     stateValue == 2 or stateValue == -2 ? "Watch reclaim / fade" :
     "Wait for acceptance"

f_context_text(int stateValue, bool aboveOpen, bool belowOpen) =>
    stateValue == 1 ? "Above Open" :
     stateValue == -1 ? "Below Open" :
     stateValue == 2 ? "Down Reject" :
     stateValue == -2 ? "Up Reject" :
     aboveOpen ? "Open Support Test" :
     belowOpen ? "Open Resistance Test" :
     "Open Balance"

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(24, 35, 55) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_trim_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        oldItem = array.shift(items)
        if not na(oldItem)
            label.delete(oldItem)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, string fontSize) =>
    rowBg = f_panel_bg(isLight, row % 2 == 0)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

// -------------------------------------------------
// Core data
// -------------------------------------------------
labelSize = f_size(labelTextInput)
panelSize = f_size(panelTextInput)
isIntraday = timeframe.isintraday

dailyOpen = request.security(syminfo.tickerid, "D", open, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
prevDailyOpen = request.security(syminfo.tickerid, "D", open[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
newDay = ta.change(time("D")) != 0

atrValue = math.max(nz(ta.atr(atrLen), syminfo.mintick * 20.0), syminfo.mintick)
holdBars = filterMode == "Strict" ? strictHoldBars : normalHoldBars
tolATR = filterMode == "Strict" ? strictTolATR : normalTolATR
rejectLookback = filterMode == "Strict" ? rejectLookbackStrict : rejectLookbackNormal
tolerance = math.max(syminfo.mintick * 2.0, atrValue * tolATR)
bandSize = math.max(syminfo.mintick * 10.0, atrValue * acceptBandATR)
openZoneSize = math.max(syminfo.mintick * 6.0, atrValue * openZoneATR)
rightEdge = bar_index + projectionBars
distanceATR = atrValue > 0.0 ? (close - dailyOpen) / atrValue : 0.0

// -------------------------------------------------
// Stateful engine
// -------------------------------------------------
var int aboveCount = 0
var int belowCount = 0
var bool seenBelowToday = false
var bool seenAboveToday = false
var bool firstBullReclaimSeen = false
var bool firstBearReclaimSeen = false
var int lastReclaimSide = 0
var int rejectDir = 0
var int rejectBarsLeft = 0
var int state = 0
var int acceptStartBar = na
var int dayStartBar = na
var int lastReclaimBar = na
var int lastAnchorBar = na
var int lastContextBar = na
var int lastEventBar = na
var float lastEventPrice = na

var line dayOpenLine = na
var line prevOpenLine = na
var box openZoneBox = na
var box acceptBox = na
var label openZoneBadge = na
var label acceptZoneBadge = na
var label openTag = na
var label prevOpenTag = na
var label stateTag = na
var array<label> eventLabels = array.new<label>()

if barstate.isfirst
    dayStartBar := bar_index

if newDay
    dayStartBar := bar_index
    aboveCount := 0
    belowCount := 0
    seenBelowToday := false
    seenAboveToday := false
    firstBullReclaimSeen := false
    firstBearReclaimSeen := false
    lastReclaimSide := 0
    rejectDir := 0
    rejectBarsLeft := 0
    acceptStartBar := na
    lastReclaimBar := na
    lastAnchorBar := na
    lastContextBar := na
    if activeOnly
        if not na(openZoneBox)
            box.delete(openZoneBox)
            openZoneBox := na
        if not na(acceptBox)
            box.delete(acceptBox)
            acceptBox := na
        f_delete_label(openZoneBadge)
        f_delete_label(acceptZoneBadge)
        openZoneBadge := na
        acceptZoneBadge := na

aboveCount := isIntraday and close > dailyOpen + tolerance ? aboveCount + 1 : 0
belowCount := isIntraday and close < dailyOpen - tolerance ? belowCount + 1 : 0
seenBelowToday := seenBelowToday or (isIntraday and low < dailyOpen - tolerance * 0.25)
seenAboveToday := seenAboveToday or (isIntraday and high > dailyOpen + tolerance * 0.25)

bullFirstReclaimEvent = barstate.isconfirmed and isIntraday and not firstBullReclaimSeen and seenBelowToday and ta.crossover(close, dailyOpen) and close > dailyOpen + tolerance
bearFirstReclaimEvent = barstate.isconfirmed and isIntraday and not firstBearReclaimSeen and seenAboveToday and ta.crossunder(close, dailyOpen) and close < dailyOpen - tolerance

if bullFirstReclaimEvent
    firstBullReclaimSeen := true
    lastReclaimSide := 1
if bearFirstReclaimEvent
    firstBearReclaimSeen := true
    lastReclaimSide := -1

bullRequiredBars = math.max(1, holdBars - (useFirstReclaimBonus and firstBullReclaimSeen ? 1 : 0))
bearRequiredBars = math.max(1, holdBars - (useFirstReclaimBonus and firstBearReclaimSeen ? 1 : 0))

bullAcceptActive = isIntraday and close > dailyOpen + tolerance and aboveCount >= bullRequiredBars
bearAcceptActive = isIntraday and close < dailyOpen - tolerance and belowCount >= bearRequiredBars

downProbeBars = ta.barssince(low < dailyOpen - tolerance)
upProbeBars = ta.barssince(high > dailyOpen + tolerance)
recentDownProbe = not na(downProbeBars) and downProbeBars <= rejectLookback
recentUpProbe = not na(upProbeBars) and upProbeBars <= rejectLookback

bullRejectEvent = barstate.isconfirmed and isIntraday and ta.crossover(close, dailyOpen) and close > dailyOpen and recentDownProbe and not bullAcceptActive and not bullFirstReclaimEvent
bearRejectEvent = barstate.isconfirmed and isIntraday and ta.crossunder(close, dailyOpen) and close < dailyOpen and recentUpProbe and not bearAcceptActive and not bearFirstReclaimEvent

if bullRejectEvent
    rejectDir := 1
    rejectBarsLeft := rejectStateBars
else if bearRejectEvent
    rejectDir := -1
    rejectBarsLeft := rejectStateBars
else if rejectBarsLeft > 0
    rejectBarsLeft -= 1

prevState = state
state := bullAcceptActive ? 1 : bearAcceptActive ? -1 : rejectBarsLeft > 0 ? (rejectDir == 1 ? 2 : -2) : 0

bullAcceptEvent = barstate.isconfirmed and state == 1 and prevState != 1
bearAcceptEvent = barstate.isconfirmed and state == -1 and prevState != -1
rejectDownStateEvent = barstate.isconfirmed and state == 2 and prevState != 2
rejectUpStateEvent = barstate.isconfirmed and state == -2 and prevState != -2
stateChanged = barstate.isconfirmed and state != prevState

if state == 1 or state == -1
    if prevState != state
        acceptStartBar := bar_index
else if activeOnly
    acceptStartBar := na

// -------------------------------------------------
// Acceptance hold-through proof (Hold Rate)
// -------------------------------------------------
var int proofTotal = 0
var int proofHold  = 0
var int pendSide   = 0
var int pendLeft   = 0

if barstate.isconfirmed
    if pendLeft > 0
        dayRolled = newDay
        brokeBack = (pendSide == 1 and close < dailyOpen - tolerance) or (pendSide == -1 and close > dailyOpen + tolerance)
        if dayRolled
            proofTotal += 1
            proofHold  += 1
            pendSide := 0
            pendLeft := 0
        else if brokeBack
            proofTotal += 1
            pendSide := 0
            pendLeft := 0
        else if pendLeft == 1
            proofTotal += 1
            proofHold  += 1
            pendSide := 0
            pendLeft := 0
        else
            pendLeft -= 1
    if (bullAcceptEvent or bearAcceptEvent) and pendLeft == 0
        pendSide := bullAcceptEvent ? 1 : -1
        pendLeft := confirmBars

acceptHoldRate = proofTotal > 0 ? proofHold / proofTotal * 100.0 : na

// -------------------------------------------------
// Acceptance Readiness Score (0-100)
// -------------------------------------------------
sideNow = isIntraday and close > dailyOpen + tolerance ? 1 : isIntraday and close < dailyOpen - tolerance ? -1 : 0
holdNow = sideNow == 1 ? aboveCount : sideNow == -1 ? belowCount : 0
reqNow  = sideNow == 1 ? bullRequiredBars : sideNow == -1 ? bearRequiredBars : holdBars
absDistATR = math.abs(distanceATR)

sepScore     = math.min(absDistATR / 0.80, 1.0) * 30.0
holdScore    = math.min(holdNow / math.max(reqNow, 1), 1.0) * 25.0
cleanScore   = (state == 1 or state == -1) ? 15.0 : (state == 2 or state == -2) ? 11.0 : 5.0
reclaimAlign = (lastReclaimSide == 1 and sideNow == 1) or (lastReclaimSide == -1 and sideNow == -1)
reclaimScore = lastReclaimSide == 0 ? 9.0 : reclaimAlign ? 15.0 : 5.0
proofRatio   = proofTotal >= 5 ? acceptHoldRate / 100.0 : 0.55
proofScore   = proofRatio * 15.0

readinessRaw = isIntraday ? sepScore + holdScore + cleanScore + reclaimScore + proofScore : 0.0
readiness    = int(math.round(math.min(math.max(readinessRaw, 0.0), 100.0)))
readyBand    = f_ready_band(readiness)
readyColor   = readiness >= 55 ? f_state_color(state) : readiness >= 35 ? neutralColor : panelLabelCol

// -------------------------------------------------
// Optional historical plot layer
// -------------------------------------------------
todayOpenColor = color.new(headerBg, 0)
prevLineColor = color.new(prevOpenColor, 42)
zoneFill = state == 1 ? color.new(bullColor, 94) : state == -1 ? color.new(bearColor, 94) : color.new(accentColor, 96)
acceptFill = state == 1 ? color.new(bullColor, 89) : state == -1 ? color.new(bearColor, 89) : na

histOpen = showRangeFill and showDailyOpen and isIntraday and not activeOnly ? dailyOpen : na
histPrevOpen = showRangeFill and showPrevDailyOpen and isIntraday and not activeOnly and not minimalView ? prevDailyOpen : na
histZoneTop = showRangeFill and showOpenZone and isIntraday and not activeOnly and not minimalView ? dailyOpen + openZoneSize : na
histZoneBot = showRangeFill and showOpenZone and isIntraday and not activeOnly and not minimalView ? dailyOpen - openZoneSize : na
histAcceptTop = showRangeFill and showAcceptanceZone and isIntraday and not activeOnly and not minimalView ? (state == 1 ? dailyOpen + bandSize : state == -1 ? dailyOpen : na) : na
histAcceptBot = showRangeFill and showAcceptanceZone and isIntraday and not activeOnly and not minimalView ? (state == 1 ? dailyOpen : state == -1 ? dailyOpen - bandSize : na) : na

pPrev = plot(histPrevOpen, "Previous Daily Open", color = prevLineColor, linewidth = 1, style = plot.style_linebr)
pOpen = plot(histOpen, "Daily Open", color = todayOpenColor, linewidth = 2, style = plot.style_linebr)
pZoneTop = plot(histZoneTop, "Open Zone Top", color = color.new(accentColor, 100), linewidth = 1, style = plot.style_linebr)
pZoneBot = plot(histZoneBot, "Open Zone Bottom", color = color.new(accentColor, 100), linewidth = 1, style = plot.style_linebr)
pAcceptTop = plot(histAcceptTop, "Acceptance Top", color = color.new(f_state_color(state), 100), linewidth = 1, style = plot.style_linebr)
pAcceptBot = plot(histAcceptBot, "Acceptance Bottom", color = color.new(f_state_color(state), 100), linewidth = 1, style = plot.style_linebr)

fill(pZoneTop, pZoneBot, color = zoneFill, title = "Daily Open Zone Fill")
fill(pAcceptTop, pAcceptBot, color = acceptFill, title = "Acceptance Zone Fill")

// -------------------------------------------------
// Current-day map objects
// -------------------------------------------------
if showDailyOpen and isIntraday
    if na(dayOpenLine)
        dayOpenLine := line.new(dayStartBar, dailyOpen, rightEdge, dailyOpen, xloc = xloc.bar_index, extend = extend.none, color = todayOpenColor, width = 2)
    else
        line.set_xy1(dayOpenLine, dayStartBar, dailyOpen)
        line.set_xy2(dayOpenLine, rightEdge, dailyOpen)
        line.set_color(dayOpenLine, todayOpenColor)
else
    if not na(dayOpenLine)
        line.delete(dayOpenLine)
        dayOpenLine := na

if showPrevDailyOpen and isIntraday and not minimalView
    if na(prevOpenLine)
        prevOpenLine := line.new(dayStartBar, prevDailyOpen, rightEdge, prevDailyOpen, xloc = xloc.bar_index, extend = extend.none, color = prevLineColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(prevOpenLine, dayStartBar, prevDailyOpen)
        line.set_xy2(prevOpenLine, rightEdge, prevDailyOpen)
        line.set_color(prevOpenLine, prevLineColor)
        line.set_style(prevOpenLine, line.style_dashed)
else
    if not na(prevOpenLine)
        line.delete(prevOpenLine)
        prevOpenLine := na

acceptanceConfirmed = state == 1 or state == -1
openZoneActive = showOpenZone and isIntraday and not minimalView and not acceptanceConfirmed
openZoneTop = dailyOpen + openZoneSize
openZoneBot = dailyOpen - openZoneSize
openZoneMidX = int(math.round((dayStartBar + rightEdge) * 0.50))
openZoneColor = f_state_color(state)

if openZoneActive
    if na(openZoneBox)
        openZoneBox := box.new(dayStartBar, openZoneTop, rightEdge, openZoneBot, xloc = xloc.bar_index, bgcolor = color.new(openZoneColor, 92), border_color = color.new(openZoneColor, 52), border_width = 1)
    else
        box.set_lefttop(openZoneBox, dayStartBar, openZoneTop)
        box.set_rightbottom(openZoneBox, rightEdge, openZoneBot)
        box.set_bgcolor(openZoneBox, color.new(openZoneColor, 92))
        box.set_border_color(openZoneBox, color.new(openZoneColor, 52))

    openBadgeText = showZoneText ? (state == 2 or state == -2 ? f_state_text(state) + "\n" + str.tostring(readiness) + " / 100" : "D-Open Test\n" + str.tostring(readiness) + " / 100") : "Daily Open Zone"
    if na(openZoneBadge)
        openZoneBadge := label.new(openZoneMidX, dailyOpen, openBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(openZoneColor, 0), textcolor = f_text_on(openZoneColor), size = labelSize, textalign = text.align_center)
    else
        label.set_xy(openZoneBadge, openZoneMidX, dailyOpen)
        label.set_text(openZoneBadge, openBadgeText)
        label.set_color(openZoneBadge, color.new(openZoneColor, 0))
        label.set_textcolor(openZoneBadge, f_text_on(openZoneColor))
        label.set_size(openZoneBadge, labelSize)
else
    if not na(openZoneBox)
        box.delete(openZoneBox)
        openZoneBox := na
    f_delete_label(openZoneBadge)
    openZoneBadge := na

acceptActive = showAcceptanceZone and isIntraday and not minimalView and acceptanceConfirmed and not na(acceptStartBar)
if acceptActive
    acceptTop = state == 1 ? dailyOpen + bandSize : dailyOpen
    acceptBot = state == 1 ? dailyOpen : dailyOpen - bandSize
    acceptColor = f_state_color(state)
    acceptMidX = int(math.round((acceptStartBar + rightEdge) * 0.50))
    acceptMidY = (acceptTop + acceptBot) * 0.5
    zoneText = (state == 1 ? "Bull Acceptance" : "Bear Acceptance") + (showZoneText ? "\n" + str.tostring(readiness) + " / 100" : "")
    if na(acceptBox)
        acceptBox := box.new(acceptStartBar, acceptTop, rightEdge, acceptBot, xloc = xloc.bar_index, bgcolor = color.new(acceptColor, 84), border_color = color.new(acceptColor, 18), border_width = 1)
    else
        box.set_lefttop(acceptBox, acceptStartBar, acceptTop)
        box.set_rightbottom(acceptBox, rightEdge, acceptBot)
        box.set_bgcolor(acceptBox, color.new(acceptColor, 84))
        box.set_border_color(acceptBox, color.new(acceptColor, 18))

    if na(acceptZoneBadge)
        acceptZoneBadge := label.new(acceptMidX, acceptMidY, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(acceptColor, 0), textcolor = headerText, size = labelSize, textalign = text.align_center)
    else
        label.set_xy(acceptZoneBadge, acceptMidX, acceptMidY)
        label.set_text(acceptZoneBadge, zoneText)
        label.set_color(acceptZoneBadge, color.new(acceptColor, 0))
        label.set_textcolor(acceptZoneBadge, headerText)
        label.set_size(acceptZoneBadge, labelSize)
else
    if not na(acceptBox)
        box.delete(acceptBox)
        acceptBox := na
    f_delete_label(acceptZoneBadge)
    acceptZoneBadge := na

// -------------------------------------------------
// Live right-side tags
// -------------------------------------------------
liveOffset = math.max(syminfo.mintick * 10.0, atrValue * liveTagOffsetATR)
stateColor = f_state_color(state)
stateText = isIntraday ? f_state_text(state) : "Intraday Only"
tagStateText = f_state_text(state) + " " + str.tostring(readiness)

if showLiveTags and isIntraday
    tagX = bar_index + projectionBars + 1
    openTagY = dailyOpen
    prevTagY = prevDailyOpen
    baseStateY = state == 1 ? dailyOpen + math.max(bandSize * 0.78, liveOffset * 1.0) :
         state == -1 ? dailyOpen - math.max(bandSize * 0.78, liveOffset * 1.0) :
         state == 2 ? dailyOpen + openZoneSize + liveOffset * 1.4 :
         state == -2 ? dailyOpen - openZoneSize - liveOffset * 1.4 :
         dailyOpen
    if math.abs(openTagY - baseStateY) < liveOffset * 1.8
        baseStateY := baseStateY - liveOffset * 1.8

    if na(openTag)
        openTag := label.new(tagX, openTagY, "Today D-Open", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = todayOpenColor, textcolor = headerText, size = labelSize)
    else
        label.set_xy(openTag, tagX, openTagY)
        label.set_text(openTag, "Today D-Open")
        label.set_color(openTag, todayOpenColor)
        label.set_textcolor(openTag, headerText)
        label.set_size(openTag, labelSize)

    if showPrevDailyOpen and not minimalView
        if na(prevOpenTag)
            prevOpenTag := label.new(tagX, prevTagY, "Prev D-Open", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(prevOpenColor, 12), textcolor = headerText, size = labelSize)
        else
            label.set_xy(prevOpenTag, tagX, prevTagY)
            label.set_text(prevOpenTag, "Prev D-Open")
            label.set_color(prevOpenTag, color.new(prevOpenColor, 12))
            label.set_textcolor(prevOpenTag, headerText)
            label.set_size(prevOpenTag, labelSize)
    else
        f_delete_label(prevOpenTag)
        prevOpenTag := na

    if showStateLiveTag and state != 0
        if na(stateTag)
            stateTag := label.new(tagX + 2, baseStateY, tagStateText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 0), textcolor = headerText, size = labelSize)
        else
            label.set_xy(stateTag, tagX + 2, baseStateY)
            label.set_text(stateTag, tagStateText)
            label.set_color(stateTag, color.new(stateColor, 0))
            label.set_textcolor(stateTag, headerText)
            label.set_size(stateTag, labelSize)
    else
        f_delete_label(stateTag)
        stateTag := na
else
    f_delete_label(openTag)
    f_delete_label(prevOpenTag)
    f_delete_label(stateTag)
    openTag := na
    prevOpenTag := na
    stateTag := na

// -------------------------------------------------
// Event and context labels
// -------------------------------------------------
eventKeep = labelDensity == "Detailed" ? 8 : labelDensity == "Balanced" ? 4 : 2
eventOffset = math.max(syminfo.mintick * 20.0, atrValue * labelOffsetATR)
globalEventReady = na(lastEventBar) or bar_index - lastEventBar >= labelSpacingBars
eventPriceReady = na(lastEventPrice) or math.abs(close - lastEventPrice) >= atrValue * 1.10
canPlaceReclaim = (na(lastReclaimBar) or bar_index - lastReclaimBar >= labelSpacingBars) and globalEventReady and eventPriceReady
canPlaceAnchor = (na(lastAnchorBar) or bar_index - lastAnchorBar >= labelSpacingBars) and globalEventReady and eventPriceReady
contextReady = na(lastContextBar) or bar_index - lastContextBar >= contextSpacingBars

if showEventLabels and isIntraday and not minimalView
    if bullFirstReclaimEvent and canPlaceReclaim
        lb = label.new(bar_index, low - eventOffset, "First Reclaim", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(accentColor, 0), textcolor = headerText, size = labelSize)
        array.push(eventLabels, lb)
        f_trim_labels(eventLabels, eventKeep)
        lastReclaimBar := bar_index
        lastEventBar := bar_index
        lastEventPrice := close
    if bearFirstReclaimEvent and canPlaceReclaim
        lb = label.new(bar_index, high + eventOffset, "First Reclaim", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(accentColor, 0), textcolor = headerText, size = labelSize)
        array.push(eventLabels, lb)
        f_trim_labels(eventLabels, eventKeep)
        lastReclaimBar := bar_index
        lastEventBar := bar_index
        lastEventPrice := close
    if bullAcceptEvent and canPlaceAnchor
        lb = label.new(bar_index, low - eventOffset, "Accept Above " + str.tostring(readiness), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(bullColor, 0), textcolor = headerText, size = labelSize)
        array.push(eventLabels, lb)
        f_trim_labels(eventLabels, eventKeep)
        lastAnchorBar := bar_index
        lastEventBar := bar_index
        lastEventPrice := close
    if bearAcceptEvent and canPlaceAnchor
        lb = label.new(bar_index, high + eventOffset, "Accept Below " + str.tostring(readiness), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(bearColor, 0), textcolor = headerText, size = labelSize)
        array.push(eventLabels, lb)
        f_trim_labels(eventLabels, eventKeep)
        lastAnchorBar := bar_index
        lastEventBar := bar_index
        lastEventPrice := close
    if rejectDownStateEvent and canPlaceAnchor
        lb = label.new(bar_index, low - eventOffset * 1.35, "Down Reject", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(neutralColor, 0), textcolor = darkText, size = labelSize)
        array.push(eventLabels, lb)
        f_trim_labels(eventLabels, eventKeep)
        lastAnchorBar := bar_index
        lastEventBar := bar_index
        lastEventPrice := close
    if rejectUpStateEvent and canPlaceAnchor
        lb = label.new(bar_index, high + eventOffset * 1.35, "Up Reject", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(neutralColor, 0), textcolor = darkText, size = labelSize)
        array.push(eventLabels, lb)
        f_trim_labels(eventLabels, eventKeep)
        lastAnchorBar := bar_index
        lastEventBar := bar_index
        lastEventPrice := close

periodicContext = showContextLabels and showEventLabels and isIntraday and not minimalView and contextReady and state != 0 and not (bullAcceptEvent or bearAcceptEvent or rejectDownStateEvent or rejectUpStateEvent)
if periodicContext
    contextAbove = close > dailyOpen + tolerance
    contextBelow = close < dailyOpen - tolerance
    contextText = f_context_text(state, contextAbove, contextBelow)
    contextY = state == 1 or state == 2 ? low - eventOffset * 0.86 : high + eventOffset * 0.86
    contextStyle = state == 1 or state == 2 ? label.style_label_up : label.style_label_down
    contextColor = f_state_color(state)
    contextTextColor = state == 2 or state == -2 ? darkText : headerText
    lb = label.new(bar_index, contextY, contextText, xloc = xloc.bar_index, yloc = yloc.price, style = contextStyle, color = color.new(contextColor, 0), textcolor = contextTextColor, size = labelSize)
    array.push(eventLabels, lb)
    f_trim_labels(eventLabels, eventKeep)
    lastContextBar := bar_index

if barstate.islast and not showEventLabels and array.size(eventLabels) > 0
    for i = 0 to array.size(eventLabels) - 1
        label.delete(array.get(eventLabels, i))
    array.clear(eventLabels)

plotshape(showSignalMarkers and isIntraday and bullAcceptEvent, title = "Bull Accept Marker", style = shape.circle, location = location.belowbar, color = bullColor, size = size.tiny)
plotshape(showSignalMarkers and isIntraday and bearAcceptEvent, title = "Bear Accept Marker", style = shape.circle, location = location.abovebar, color = bearColor, size = size.tiny)
plotshape(showSignalMarkers and isIntraday and bullFirstReclaimEvent, title = "First Bull Reclaim Marker", style = shape.diamond, location = location.belowbar, color = accentColor, size = size.tiny)
plotshape(showSignalMarkers and isIntraday and bearFirstReclaimEvent, title = "First Bear Reclaim Marker", style = shape.diamond, location = location.abovebar, color = accentColor, size = size.tiny)
plotshape(showSignalMarkers and isIntraday and rejectDownStateEvent, title = "Down Reject Marker", style = shape.triangleup, location = location.belowbar, color = neutralColor, size = size.tiny)
plotshape(showSignalMarkers and isIntraday and rejectUpStateEvent, title = "Up Reject Marker", style = shape.triangledown, location = location.abovebar, color = neutralColor, size = size.tiny)

// -------------------------------------------------
// Panel
// -------------------------------------------------
sideText = not isIntraday ? "Intraday Only" : close > dailyOpen + tolerance ? "Above Open" : close < dailyOpen - tolerance ? "Below Open" : "Testing Open"
reclaimText = lastReclaimSide == 1 ? "Bull Reclaim" : lastReclaimSide == -1 ? "Bear Reclaim" : "None"
holdProgress = close > dailyOpen + tolerance ? str.tostring(math.min(aboveCount, bullRequiredBars)) + "/" + str.tostring(bullRequiredBars) : close < dailyOpen - tolerance ? str.tostring(math.min(belowCount, bearRequiredBars)) + "/" + str.tostring(bearRequiredBars) : "0/" + str.tostring(holdBars)
distanceText = (distanceATR >= 0 ? "+" : "") + str.tostring(distanceATR, "#.##") + " ATR"
nextActionText = f_next_action(state, readiness, isIntraday)
reviewText = not isIntraday ? "Switch to intraday" : readyBand + " / " + filterMode
holdRateText = not isIntraday ? "Intraday only" : proofTotal > 0 ? str.tostring(int(math.round(acceptHoldRate))) + "% (" + str.tostring(proofTotal) + ")" : "Building"

isLightPanel = panelTheme == "Light"
panelFrame = f_panel_border(isLightPanel)
panelValueText = f_panel_value(isLightPanel)
nextColor = f_state_color(state)
contextColor = close > dailyOpen + tolerance ? bullColor : close < dailyOpen - tolerance ? bearColor : neutralColor
reclaimColor = reclaimText == "None" ? panelValueText : accentColor
holdRateColor = na(acceptHoldRate) ? panelValueText : acceptHoldRate >= 60 ? bullColor : acceptHoldRate >= 45 ? neutralColor : bearColor

var table biasPanel = table.new(f_panel_pos(panelPos), 2, 9, bgcolor = f_panel_bg(isLightPanel, false), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
var bool panelHeaderMerged = false

if not panelHeaderMerged
    table.merge_cells(biasPanel, 0, 0, 1, 0)
    panelHeaderMerged := true

if barstate.islast
    table.set_position(biasPanel, f_panel_pos(panelPos))
    table.set_frame_color(biasPanel, panelFrame)
    table.set_border_color(biasPanel, panelFrame)
    if showPanel
        table.cell(biasPanel, 0, 0, "AG Pro Daily Open Acceptance Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        f_panel_row(biasPanel, 1, "Readiness", str.tostring(readiness) + " / 100", readyColor, isLightPanel, panelTextInput)
        f_panel_row(biasPanel, 2, "Next Action", nextActionText, nextColor, isLightPanel, panelTextInput)
        f_panel_row(biasPanel, 3, "Acceptance State", stateText, f_state_color(state), isLightPanel, panelTextInput)
        f_panel_row(biasPanel, 4, "Open Context", sideText, contextColor, isLightPanel, panelTextInput)
        f_panel_row(biasPanel, 5, "Hold / Distance", holdProgress + " / " + distanceText, panelValueText, isLightPanel, panelTextInput)
        f_panel_row(biasPanel, 6, "Hold Rate", holdRateText, holdRateColor, isLightPanel, panelTextInput)
        f_panel_row(biasPanel, 7, "Reclaim", reclaimText, reclaimColor, isLightPanel, panelTextInput)
        f_panel_row(biasPanel, 8, "Review", reviewText, readyColor, isLightPanel, panelTextInput)
    else
        table.clear(biasPanel, 0, 0, 1, 8)

// -------------------------------------------------
// Alerts and hidden exports
// -------------------------------------------------
primeAcceptEvent = (bullAcceptEvent or bearAcceptEvent) and readiness >= primeReadyLevel

alertcondition(alertBullAccept and bullAcceptEvent, "Bullish Acceptance Confirmed", "Daily Open Acceptance Map: bullish acceptance confirmed above the daily open. This is an attention marker, not a trade instruction.")
alertcondition(alertBearAccept and bearAcceptEvent, "Bearish Acceptance Confirmed", "Daily Open Acceptance Map: bearish acceptance confirmed below the daily open. This is an attention marker, not a trade instruction.")
alertcondition(alertFirstReclaim and bullFirstReclaimEvent, "First Bullish Reclaim Confirmed", "Daily Open Acceptance Map: first bullish reclaim confirmed above the daily open. This is an attention marker, not a trade instruction.")
alertcondition(alertFirstReclaim and bearFirstReclaimEvent, "First Bearish Reclaim Confirmed", "Daily Open Acceptance Map: first bearish reclaim confirmed below the daily open. This is an attention marker, not a trade instruction.")
alertcondition(alertStateChange and stateChanged, "Daily Open State Changed", "Daily Open Acceptance Map: daily open state changed. Review the updated context before acting.")
alertcondition(alertPrimeSetup and primeAcceptEvent, "Prime Acceptance Confirmed", "Daily Open Acceptance Map: a high-readiness acceptance was confirmed at the daily open. This is an attention marker, not a trade instruction.")

plot(state, "DOAM State", display = display.none)
plot(readiness, "DOAM Readiness", display = display.none)
plot(acceptHoldRate, "DOAM Hold Rate", display = display.none)
plot(distanceATR, "DOAM Distance ATR", display = display.none)
plot(aboveCount, "DOAM Above Hold Count", display = display.none)
plot(belowCount, "DOAM Below Hold Count", display = display.none)
````
