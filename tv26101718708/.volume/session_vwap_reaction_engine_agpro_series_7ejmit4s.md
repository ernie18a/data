# Session VWAP Reaction Engine [AGPro Series]

- url: https://www.tradingview.com/script/7EJmiT4S-Session-VWAP-Reaction-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;7dba989c930644d083460ca0045078c9
- version: 6.0

## Description

[b]Session VWAP Reaction Engine [AGPro Series][/b]

Session VWAP Reaction Engine [AGPro Series] builds the active intraday session VWAP as a reaction anchor and classifies confirmed price behaviour around it into three clear event types — Reclaim, Bounce, and Reject — each validated by a configurable confirmation window, a minimum prior-side bar filter, and an optional VWAP slope alignment filter. A volatility-scaled reaction corridor, compact reaction zones, a session box, and a minimal right-side bias panel turn raw session flow into a clean, publication-ready read on acceptance, rejection, and continuation.


🔷 OVERVIEW

Most session VWAP tools simply plot the line. Session VWAP Reaction Engine goes further: it reads how price behaves around the line inside a selected session window (Asia, London, New York, or Custom) and labels that behaviour using three structural event classes:

• Reclaim — a confirmed cross and acceptance on the new side of session VWAP, after price has spent a minimum number of bars on the opposite side.
• Bounce — a test of the reaction corridor edge that closes back on the prevailing side, with body-range and slope alignment quality checks feeding a Strong / Clean / Weak strength read.
• Reject — a wick into session VWAP that fails to accept on the other side, resolving as pressure against the crossing attempt.

Each confirmed event paints a compact rectangular reaction zone, a single label near the zone, and updates a right-side bias panel so the current session's story is always readable at a glance.


🟦 WHAT MAKES IT DIFFERENT

▸ Event classification, not just a line. Reclaim, Bounce, and Reject are treated as distinct structural events — each with its own confirmation path and visual signature — instead of blending into a single "crossed VWAP" signal.

▸ Corridor-based reaction detection. Bounce and Reject use a volatility-scaled ATR corridor around session VWAP rather than a single-pixel touch, which matches how VWAP is typically tested in real intraday flow.

▸ Slope-aware trend filter. Optional VWAP slope alignment biases bounce events toward the prevailing session direction and filters out counter-flow reactions that tend to fail.

▸ Reaction Strength read. Bounces are classified Strong / Clean / Weak using body-to-range ratio, close location in range, and slope alignment — turning every bounce into a quality-graded event.

▸ Active-Only and Publish Focus visual modes. The chart stays clean by surfacing only the latest session and the latest confirmed reaction, with older structure fading or removed. Ideal for decision-making and presentation.


🟣 METHODOLOGY

1) Session anchor. The selected session (Asia / London / New York / Custom) resets a cumulative PV / V VWAP on every new session bar, giving a fresh reaction reference for that window.

2) Prior-side filter. Before any Reclaim or opposite-side reaction can qualify, price must have spent a minimum configurable number of bars on one side of session VWAP. This isolates structural interactions and rejects chop.

3) Reclaim confirmation. A raw cross must be followed by N consecutive confirmed closes on the new side (default 2) before the Reclaim is validated and painted.

4) Corridor reactions. A volatility-scaled corridor (ATR × user multiplier) around session VWAP defines where Bounce and Reject qualify. Bounces require a corridor-edge test plus a close back on the prevailing side with body confirmation; Rejects require a wick into session VWAP that closes on the originating side.

5) Bias and state synthesis. Live Bias (Bullish / Bearish Acceptance or Pressure, or Neutral Rotation) is derived from close position relative to VWAP and corridor. Reaction State reflects the latest confirmed event (Bullish Acceptance, Bearish Acceptance, Bounce Support, Bounce Resistance, Reject Pressure, Reject Lift).

6) Post-session context. After the session ends, the last session VWAP and corridor stay on the chart for a configurable number of bars so recent structure remains visible without polluting older history.


🟢 SIGNALS & ALERTS

Eight alertcondition hooks are provided, all bar-close confirmable:

• Bullish Session VWAP Reclaim Confirmed
• Bearish Session VWAP Reclaim Confirmed
• Bullish Session VWAP Bounce Confirmed
• Bearish Session VWAP Bounce Confirmed
• Bullish Session VWAP Reject Confirmed
• Bearish Session VWAP Reject Confirmed
• Reaction State Shifted Bullish
• Reaction State Shifted Bearish

A "Confirmed Alerts Only" toggle restricts firing to barstate.isconfirmed so alerts will not repaint before close.


🟡 KEY INPUTS

Session Engine
• Selected Session — Asia / London / New York / Custom
• Custom Session — HHmm-HHmm format (used when Custom is selected)
• Session Timezone — Exchange / UTC / London / New York / Singapore

Reaction Engine
• Reclaim Confirm Bars — number of confirmed closes required after a cross (default 2)
• Minimum Prior Side Bars — whipsaw filter on the opposite side before qualifying (default 2)
• Reaction Corridor Width (ATR) — half-width of the ATR corridor around VWAP (default 0.20)
• Reaction Zone Length (Bars) — how far a confirmed zone extends right (default 14)
• Use VWAP Slope Alignment — trend filter for bounce events (default on)
• VWAP Slope Lookback — slope estimation window (default 3)
• Post-Session Context Bars — how long last session structure stays visible (default 18)

Visual Story
• Active-Only Mode, Publish Focus Mode, Show Previous Reaction Ghost
• Show Session Box, Show VWAP Reaction Corridor, Show Confirmed Reaction Zone
• Show Reaction Label, Show Session VWAP, Show Right-Edge SVWAP Tag
• Visible History Bars (default 700), Label Font Size (default Normal)

Panel
• Show Bias Panel (top-right), Panel Font Size (default Normal)

Alerts
• Confirmed Alerts Only (default on)


🟠 HOW TO USE

1) Apply to any intraday timeframe (1m–4h). Session VWAP requires intraday data to anchor the session reference.

2) Choose the session that best fits your market focus — New York for US equities and US-hours crypto, London for FX and European hours, Asia for Asian-session flow, or a Custom window.

3) Watch the corridor as the session develops. Bounce and Reject events inside the corridor describe how the session is defending or failing the VWAP reference.

4) Use Reclaim events as session-context shifts — combine with your own structure (HTF trend, S/R, order flow) rather than treating them as standalone entries.

5) Read the right-side Bias Panel for a compact summary: Session Status, Bias, Last Reaction, Reaction Strength, Signal Age, Reaction State, and Latest Line status.

6) For screenshots and presentation use, keep Publish Focus Mode and Active-Only Mode enabled — older sessions fade and only the latest structure remains dominant.


🟤 LIMITATIONS & TRANSPARENCY

• Intraday-only. Session VWAP is meaningful only on intraday timeframes; on daily and higher, the indicator will remain idle.

• Session VWAP resets at the start of each selected session. Reactions are evaluated within that window only.

• Confirmed events use bar-close logic. Intra-bar touches of the corridor are not counted as events until the bar closes.

• Volume-dependent. Session VWAP uses symbol volume. On symbols without meaningful volume, VWAP accuracy will be limited.

• The Reaction Corridor is a volatility-scaled visual and detection band, not a support/resistance guarantee.


⚠️ RISK DISCLOSURE

This indicator is an analytical and visualisation tool. It is not a trading strategy, does not generate buy/sell recommendations, does not predict future price direction, and does not guarantee any specific outcome. All signals, zones, and panel readings describe past and current price behaviour around session VWAP, not forecasts.

Markets carry risk of loss. Always use independent risk management, position sizing, and your own trading plan. Past behaviour of any signal does not imply future performance.

## Source Code

````pine
// -------------------------------------------------
// Session VWAP Reaction Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 3.2
//
// Builds the active session VWAP as a reaction anchor and classifies confirmed
// price behavior around it through Reclaim, Bounce, and Reject states. The
// engine combines session VWAP, a volatility-scaled corridor, slope alignment,
// prior-side validation, reaction zones, live state tags, a reaction proof that
// records how often confirmed reactions followed through, and a compact panel
// to make session flow easier to read. It is an analytical visualization tool,
// not a prediction engine, not an automated strategy, and not financial advice.
// -------------------------------------------------

//@version=6
indicator("Session VWAP Reaction Engine [AGPro Series]",
     shorttitle       = "AG Pro SVW",
     overlay          = true,
     max_labels_count = 60,
     max_boxes_count  = 12,
     max_lines_count  = 10,
     max_bars_back    = 1000)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpSession = "Session Engine"
sessionChoice = input.string("New York", "Selected Session",
     options = ["Asia", "London", "New York", "Custom"], group = grpSession,
     tooltip = "Choose which intraday session anchors the VWAP reference. Each session resets the VWAP accumulator and creates a clean reaction map for that trading window.")
customSession = input.session("0930-1600", "Custom Session", group = grpSession,
     tooltip = "Custom session window used only when Selected Session is Custom. Format: HHmm-HHmm.")
sessionTimezone = input.string("Exchange", "Session Timezone",
     options = ["Exchange", "Etc/UTC", "Europe/London", "America/New_York", "Asia/Singapore"], group = grpSession,
     tooltip = "Timezone used to interpret the selected session. Exchange keeps the symbol's native timezone.")

grpReaction = "Reaction Engine"
reclaimConfirmBars = input.int(2, "Reclaim Confirm Bars", minval = 1, maxval = 5, group = grpReaction,
     tooltip = "Number of confirmed closes required on the new side of session VWAP after a cross before the reclaim is validated.")
minPriorSideBars = input.int(2, "Minimum Prior Side Bars", minval = 1, maxval = 10, group = grpReaction,
     tooltip = "Minimum bars price must spend on one side of session VWAP before the next reclaim, reject, or bounce can qualify.")
corridorATR = input.float(0.20, "Reaction Corridor Width (ATR)", minval = 0.04, maxval = 1.00, step = 0.01, group = grpReaction,
     tooltip = "Half-width of the reaction corridor around session VWAP, measured in ATR multiples.")
zoneExtendBars = input.int(16, "Reaction Zone Length", minval = 2, maxval = 40, group = grpReaction,
     tooltip = "How many bars a confirmed reaction zone extends to the right. This window is also used to evaluate Reaction Proof follow-through.")
eventCooldownBars = input.int(18, "Reaction Event Cooldown", minval = 1, maxval = 120, group = grpReaction,
     tooltip = "Minimum spacing between confirmed reaction events. This prevents repeated Bounce or Reject zones from stacking around the same VWAP interaction.")
useSlopeFilter = input.bool(true, "Use VWAP Slope Alignment", group = grpReaction,
     tooltip = "When enabled, same-side bounce reactions require alignment with the active session VWAP slope.")
slopeLookback = input.int(3, "VWAP Slope Lookback", minval = 1, maxval = 10, group = grpReaction,
     tooltip = "Bars used to estimate the active session VWAP slope.")
postSessionContextBars = input.int(18, "Post-Session Context Bars", minval = 0, maxval = 80, group = grpReaction,
     tooltip = "Number of bars the last session VWAP and corridor remain visible after the session ends.")

grpVisual = "Visuals"
showSessionVWAP = input.bool(true, "Show Session VWAP", group = grpVisual,
     tooltip = "Plots the selected session VWAP as the main intraday reaction anchor.")
showReactionCorridor = input.bool(true, "Show VWAP Reaction Corridor", group = grpVisual,
     tooltip = "Plots the volatility-scaled corridor around session VWAP.")
showSessionBox = input.bool(false, "Show Session Box", group = grpVisual,
     tooltip = "Optionally draws a labeled box around the active session range. Disabled by default so the VWAP corridor and reaction zones remain visually dominant.")
showReactionZones = input.bool(true, "Show Reaction Zones", group = grpVisual,
     tooltip = "Creates compact reaction zones when Reclaim, Bounce, or Reject behavior is confirmed.")
showZoneLabels = input.bool(true, "Show Zone Labels", group = grpVisual,
     tooltip = "Places a compact label at the right edge of the latest reaction zone.")
showLiveTags = input.bool(false, "Show Live State Tags", group = grpVisual,
     tooltip = "Optional right-edge tags for current session bias and reaction quality score. Disabled by default because the panel already carries this information and chart tags can float into empty space.")
showVWAPTag = input.bool(true, "Show SVWAP Tag", group = grpVisual,
     tooltip = "Shows a compact right-edge tag identifying the latest visible session VWAP line.")
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = grpVisual,
     tooltip = "Controls chart annotation density. Balanced is the default publication preset for intraday screenshots.")
maxReactionZones = input.int(5, "Max Reaction Zones", minval = 2, maxval = 12, group = grpVisual,
     tooltip = "Limits how many recent reaction zones and zone labels remain on the chart. Lower values reduce clutter on intraday views.")
publishFocusMode = input.bool(false, "Publish Focus Mode", group = grpVisual,
     tooltip = "When enabled, keeps only the latest session story visually dominant. Disabled by default so recent reaction history remains visible for richer publication screenshots.")
visibleHistoryBars = input.int(500, "Visible History Bars", minval = 100, maxval = 5000, group = grpVisual,
     tooltip = "Maximum number of recent bars that participate in the visual story.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual,
     tooltip = "Controls on-chart label size.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows the compact panel with session status, action, bias, context score, reaction proof, last reaction, and latest line.")
panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPanel,
     tooltip = "Controls where the panel is anchored on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel,
     tooltip = "Switches panel colors for dark or light chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Controls panel text size.")

grpAlerts = "Alerts"
confirmedAlertsOnly = input.bool(true, "Confirmed Events & Alerts Only", group = grpAlerts,
     tooltip = "Keeps reaction events, chart objects, state updates, and alerts on confirmed bar closes. Disable only when intentional realtime feedback is preferred.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgLight = color.rgb(248, 250, 252)
panelBorderD = color.rgb(51, 65, 85)
panelBorderL = color.rgb(203, 213, 225)
panelLabelD = color.rgb(148, 163, 184)
panelLabelL = color.rgb(71, 85, 105)
panelValueD = color.rgb(226, 232, 240)
panelValueL = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

isLightTheme = panelTheme == "Light"
panelBg = isLightTheme ? panelBgLight : panelBgDark
panelBorder = isLightTheme ? panelBorderL : panelBorderD
panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
panelValueCol = isLightTheme ? panelValueL : panelValueD
panelAltBg = isLightTheme ? color.rgb(226, 232, 240) : color.rgb(30, 41, 59)
darkText = color.rgb(17, 24, 39)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(p) =>
    switch p
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_text_on(_bg) =>
    r = color.r(_bg) / 255.0
    g = color.g(_bg) / 255.0
    b = color.b(_bg) / 255.0
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    luminance > 0.45 ? color.rgb(15, 23, 42) : color.white

f_state_on_panel(_state) =>
    if isLightTheme
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(178, 44, 112) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state
    else
        _state

f_session_string(choice, custom) =>
    switch choice
        "Asia" => "0000-0800"
        "London" => "0700-1600"
        "New York" => "0930-1600"
        => custom

f_session_tz(choice) =>
    choice == "Exchange" ? syminfo.timezone : choice

f_session_code(choice) =>
    switch choice
        "Asia" => "asia"
        "London" => "london"
        "New York" => "ny"
        => "custom"

f_sum_last(src, length) =>
    acc = 0
    for i = 0 to length - 1
        acc += nz(src[i], 0)
    acc

f_clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

f_bias_color(txt) =>
    str.contains(txt, "Bullish") or str.contains(txt, "Support") or str.contains(txt, "Lift") ? bullColor :
     str.contains(txt, "Bearish") or str.contains(txt, "Pressure") or str.contains(txt, "Resistance") ? bearColor :
     neutralColor

f_action_text(bias, score, inSess, allow) =>
    not allow ? "WAIT" :
     not inSess ? "WAIT" :
     str.contains(bias, "Acceptance") and score >= 70 ? "READY" :
     score >= 60 ? "MONITOR" :
     "WAIT"

f_action_color(action, bias) =>
    action == "READY" ? f_bias_color(bias) :
     action == "MONITOR" ? accentColor :
     neutralColor

f_age_text(barId) =>
    na(barId) ? "None" : str.tostring(bar_index - barId) + " bars"

f_trim_zone_pairs(array<box> boxes, array<label> labels, int keep) =>
    while array.size(boxes) > keep
        box oldBox = array.shift(boxes)
        label oldLabel = array.shift(labels)
        if not na(oldBox)
            box.delete(oldBox)
        if not na(oldLabel)
            label.delete(oldLabel)

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)

// -------------------------------------------------
// Core Session State
// -------------------------------------------------
sessionString = f_session_string(sessionChoice, customSession)
sessionTz = f_session_tz(sessionTimezone)
sessionCode = f_session_code(sessionChoice)
allowCalc = timeframe.isintraday
plotWindowOk = bar_index >= last_bar_index - visibleHistoryBars
inSession = allowCalc ? not na(time(timeframe.period, sessionString, sessionTz)) : false
newSession = inSession and not inSession[1]
endedSession = not inSession and inSession[1]

atr = ta.atr(14)
atrSafe = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
sessionVolume = nz(volume, 0.0)

var float cumPV = na
var float cumV = na
var float sessionVWAP = na
var float sessionHigh = na
var float sessionLow = na
var float lastSessionVWAP = na
var float lastSessionCorrUpper = na
var float lastSessionCorrLower = na
var int lastSessionEndBar = na
var float lastTrackedVWAP = na
var int lastTrackedVWAPBar = na
var string lastBiasStored = "Neutral Rotation"
var string lastReactionText = "No reaction yet"
var string lastReactionState = "Idle"
var string lastBounceStrength = "N/A"
var int lastReactionBar = na

if newSession
    cumPV := hlc3 * sessionVolume
    cumV := sessionVolume
    sessionVWAP := cumV > 0.0 ? cumPV / cumV : na
    sessionHigh := high
    sessionLow := low
else if inSession
    cumPV := nz(cumPV) + hlc3 * sessionVolume
    cumV := nz(cumV) + sessionVolume
    sessionVWAP := cumV > 0.0 ? cumPV / cumV : na
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow := math.min(nz(sessionLow, low), low)
else
    cumPV := na
    cumV := na
    sessionVWAP := na
    sessionHigh := na
    sessionLow := na

if endedSession
    lastSessionVWAP := sessionVWAP[1]
    lastSessionCorrUpper := not na(sessionVWAP[1]) ? sessionVWAP[1] + atrSafe[1] * corridorATR : na
    lastSessionCorrLower := not na(sessionVWAP[1]) ? sessionVWAP[1] - atrSafe[1] * corridorATR : na
    lastSessionEndBar := bar_index - 1

postSessionActive = not inSession and not na(lastSessionEndBar) and bar_index - lastSessionEndBar <= postSessionContextBars
corridorHalf = atrSafe * corridorATR
activeContextVWAP = inSession ? sessionVWAP : postSessionActive ? lastSessionVWAP : na
corridorUpper = inSession and not na(sessionVWAP) ? sessionVWAP + corridorHalf : postSessionActive ? lastSessionCorrUpper : na
corridorLower = inSession and not na(sessionVWAP) ? sessionVWAP - corridorHalf : postSessionActive ? lastSessionCorrLower : na

// -------------------------------------------------
// Reaction Engine
// -------------------------------------------------
slopeDelta = not na(sessionVWAP) and not na(sessionVWAP[slopeLookback]) ? sessionVWAP - sessionVWAP[slopeLookback] : na
slopeText = na(slopeDelta) ? "Idle" : slopeDelta > 0 ? "Up" : slopeDelta < 0 ? "Down" : "Flat"
slopeUp = not useSlopeFilter or (not na(slopeDelta) and slopeDelta >= 0.0)
slopeDown = not useSlopeFilter or (not na(slopeDelta) and slopeDelta <= 0.0)

priorBelow = f_sum_last((not na(sessionVWAP[1]) and close[1] < sessionVWAP[1]) ? 1 : 0, minPriorSideBars) == minPriorSideBars
priorAbove = f_sum_last((not na(sessionVWAP[1]) and close[1] > sessionVWAP[1]) ? 1 : 0, minPriorSideBars) == minPriorSideBars

bullReclaimRaw = inSession and not na(sessionVWAP) and ta.crossover(close, sessionVWAP) and priorBelow
bearReclaimRaw = inSession and not na(sessionVWAP) and ta.crossunder(close, sessionVWAP) and priorAbove
bullReclaim = ta.barssince(bullReclaimRaw) == reclaimConfirmBars - 1 and f_sum_last((not na(sessionVWAP) and close > sessionVWAP) ? 1 : 0, reclaimConfirmBars) == reclaimConfirmBars
bearReclaim = ta.barssince(bearReclaimRaw) == reclaimConfirmBars - 1 and f_sum_last((not na(sessionVWAP) and close < sessionVWAP) ? 1 : 0, reclaimConfirmBars) == reclaimConfirmBars

touchLower = inSession and not na(corridorLower) and low <= corridorLower
touchUpper = inSession and not na(corridorUpper) and high >= corridorUpper
bullBounce = inSession and not bullReclaim and priorAbove and touchLower and close > sessionVWAP and close > open and slopeUp
bearBounce = inSession and not bearReclaim and priorBelow and touchUpper and close < sessionVWAP and close < open and slopeDown
bullReject = inSession and not bullReclaim and not bullBounce and priorAbove and low <= sessionVWAP and close > sessionVWAP and close > open
bearReject = inSession and not bearReclaim and not bearBounce and priorBelow and high >= sessionVWAP and close < sessionVWAP and close < open

rawEvent = bullReclaim or bearReclaim or bullBounce or bearBounce or bullReject or bearReject
var int lastAcceptedEventBar = na
newEvent = (confirmedAlertsOnly ? barstate.isconfirmed : true) and rawEvent and (na(lastAcceptedEventBar) or bar_index - lastAcceptedEventBar >= eventCooldownBars)
currentIsBull = bullReclaim or bullBounce or bullReject
currentIsBear = bearReclaim or bearBounce or bearReject
currentEventText = bullReclaim ? "Bullish Reclaim" : bearReclaim ? "Bearish Reclaim" : bullBounce ? "Bullish Bounce" : bearBounce ? "Bearish Bounce" : bullReject ? "Bullish Reject" : bearReject ? "Bearish Reject" : "No reaction yet"
currentEventLabel = bullReclaim ? "Bull Reclaim" : bearReclaim ? "Bear Reclaim" : bullBounce ? "Bull Bounce" : bearBounce ? "Bear Bounce" : bullReject ? "Bull Reject" : bearReject ? "Bear Reject" : "VWAP Watch"

bodyRangeRatio = math.abs(close - open) / math.max(high - low, syminfo.mintick)
closeLoc = (close - low) / math.max(high - low, syminfo.mintick)
bounceScore = (bodyRangeRatio > 0.55 ? 1 : 0) + ((closeLoc > 0.65 or closeLoc < 0.35) ? 1 : 0) + ((bullBounce and slopeUp) or (bearBounce and slopeDown) ? 1 : 0)
currentBounceStrength = bullBounce or bearBounce ? bounceScore >= 3 ? "Strong" : bounceScore == 2 ? "Clean" : "Weak" : "N/A"

currentBias = inSession and not na(sessionVWAP) ? close > corridorUpper ? "Bullish Acceptance" : close < corridorLower ? "Bearish Acceptance" : close > sessionVWAP ? "Bullish Pressure" : close < sessionVWAP ? "Bearish Pressure" : "Neutral Rotation" : lastBiasStored
currentReactionState = bullReclaim ? "Bullish Acceptance" : bearReclaim ? "Bearish Acceptance" : bullBounce ? "Bounce Support" : bearBounce ? "Bounce Resistance" : bullReject ? "Reject Lift" : bearReject ? "Reject Pressure" : lastReactionState

if newEvent
    lastAcceptedEventBar := bar_index
    lastReactionText := currentEventText
    lastReactionBar := bar_index
    lastBiasStored := currentBias
    lastReactionState := currentReactionState
    lastBounceStrength := currentBounceStrength
else if inSession
    lastBiasStored := currentBias

// -------------------------------------------------
// Score
// -------------------------------------------------
vwapDistance = inSession and not na(sessionVWAP) and atrSafe > 0.0 ? math.abs(close - sessionVWAP) / atrSafe : 3.0
distanceScore = f_clamp(1.0 - vwapDistance / 2.0, 0.0, 1.0)
slopeScore = na(slopeDelta) or atrSafe <= 0.0 ? 0.35 : f_clamp(math.abs(slopeDelta) / (atrSafe * math.max(slopeLookback, 1) * 0.12), 0.0, 1.0)
eventScore = newEvent ? 1.0 : not na(lastReactionBar) and bar_index - lastReactionBar <= zoneExtendBars ? 0.75 : 0.35
sessionScore = inSession ? 1.0 : postSessionActive ? 0.50 : 0.10
reactionScore = int(math.round((distanceScore * 0.30 + slopeScore * 0.25 + eventScore * 0.25 + sessionScore * 0.20) * 100.0))
actionText = f_action_text(currentBias, reactionScore, inSession, allowCalc)
actionColor = f_action_color(actionText, currentBias)

// -------------------------------------------------
// Reaction Proof
// -------------------------------------------------
var int   reactTotal  = 0
var int   reactWon    = 0
var bool  rPendActive = false
var int   rPendDir    = 0
var float rPendEntry  = na
var float rPendTarget = na
var int   rPendLeft   = 0

if barstate.isconfirmed
    if rPendActive and not na(rPendEntry) and not na(rPendTarget)
        favHit = rPendDir == 1 ? high >= rPendEntry + rPendTarget : low <= rPendEntry - rPendTarget
        advHit = rPendDir == 1 ? low <= rPendEntry - rPendTarget : high >= rPendEntry + rPendTarget
        if advHit
            reactTotal += 1
            rPendActive := false
        else if favHit
            reactTotal += 1
            reactWon += 1
            rPendActive := false
        else
            rPendLeft -= 1
            if rPendLeft <= 0
                reactTotal += 1
                rPendActive := false
    if newEvent and (currentIsBull or currentIsBear)
        if rPendActive
            reactTotal += 1
            rPendActive := false
        rPendActive := true
        rPendDir := currentIsBull ? 1 : -1
        rPendEntry := close
        rPendTarget := atrSafe * 0.75
        rPendLeft := zoneExtendBars

reactRate = reactTotal > 0 ? reactWon / reactTotal * 100.0 : na

// -------------------------------------------------
// Session Box
// -------------------------------------------------
var box currentSessionBox = na
var label currentSessionLabel = na
var array<box> sessionBoxes = array.new_box()
var array<label> sessionLabels = array.new_label()

if showSessionBox and newSession and plotWindowOk
    if publishFocusMode
        while array.size(sessionBoxes) > 0
            box oldFocusSession = array.shift(sessionBoxes)
            label oldFocusSessionLabel = array.shift(sessionLabels)
            if not na(oldFocusSession)
                box.delete(oldFocusSession)
            if not na(oldFocusSessionLabel)
                label.delete(oldFocusSessionLabel)
    currentSessionBox := box.new(bar_index, high, bar_index, low, xloc = xloc.bar_index, border_color = color.new(headerBg, 48), bgcolor = color.new(headerBg, 90))
    currentSessionLabel := label.new(bar_index, (high + low) * 0.5, str.upper(sessionCode) + " SESSION", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = headerBg, textcolor = f_text_on(headerBg), size = labelSize)
    array.push(sessionBoxes, currentSessionBox)
    array.push(sessionLabels, currentSessionLabel)
    int sessionKeep = publishFocusMode ? 1 : 2
    f_trim_zone_pairs(sessionBoxes, sessionLabels, sessionKeep)

if showSessionBox and inSession and not na(currentSessionBox)
    box.set_right(currentSessionBox, bar_index)
    box.set_top(currentSessionBox, math.max(nz(box.get_top(currentSessionBox), high), high))
    box.set_bottom(currentSessionBox, math.min(nz(box.get_bottom(currentSessionBox), low), low))
    box.set_bgcolor(currentSessionBox, color.new(headerBg, publishFocusMode ? 88 : 90))
    box.set_border_color(currentSessionBox, color.new(headerBg, 48))
    if not na(currentSessionLabel)
        int sessionCenterX = int(math.round((box.get_left(currentSessionBox) + bar_index) * 0.5))
        float sessionCenterY = (box.get_top(currentSessionBox) + box.get_bottom(currentSessionBox)) * 0.5
        label.set_xy(currentSessionLabel, sessionCenterX, sessionCenterY)
        label.set_text(currentSessionLabel, str.upper(sessionCode) + " SESSION")
        label.set_size(currentSessionLabel, labelSize)

// -------------------------------------------------
// VWAP Plots
// -------------------------------------------------
plotColor = inSession ? headerBg : postSessionActive ? color.new(headerBg, 32) : color.new(headerBg, 75)
vwapPlot = plot(showSessionVWAP and plotWindowOk ? activeContextVWAP : na, title = "Session VWAP", color = plotColor, linewidth = publishFocusMode ? 3 : 2, style = plot.style_linebr)
upperPlot = plot(showReactionCorridor and plotWindowOk ? corridorUpper : na, title = "Reaction Corridor Upper", color = color.new(headerBg, postSessionActive ? 55 : 66), linewidth = 1, style = plot.style_linebr)
lowerPlot = plot(showReactionCorridor and plotWindowOk ? corridorLower : na, title = "Reaction Corridor Lower", color = color.new(headerBg, postSessionActive ? 55 : 66), linewidth = 1, style = plot.style_linebr)
fill(upperPlot, lowerPlot, color = showReactionCorridor ? color.new(headerBg, 84) : na, title = "Reaction Corridor")

if plotWindowOk and not na(activeContextVWAP)
    lastTrackedVWAP := activeContextVWAP
    lastTrackedVWAPBar := bar_index

// -------------------------------------------------
// Reaction Zones And Labels
// -------------------------------------------------
var box lastReactionZone = na
var label zoneLabel = na
var label liveBiasTag = na
var label liveScoreTag = na
var label vwapTagLabel = na
var array<box> reactionZones = array.new_box()
var array<label> reactionLabels = array.new_label()

if showReactionZones and newEvent and plotWindowOk and not na(sessionVWAP)
    if publishFocusMode
        while array.size(reactionZones) > 0
            oldFocusZone = array.shift(reactionZones)
            if not na(oldFocusZone)
                box.delete(oldFocusZone)
        while array.size(reactionLabels) > 0
            oldFocusLabel = array.shift(reactionLabels)
            if not na(oldFocusLabel)
                label.delete(oldFocusLabel)
        lastReactionZone := na
        zoneLabel := na

    zoneLeft = bar_index - 1
    zoneRight = bar_index + zoneExtendBars
    zoneTop = nz(corridorUpper, sessionVWAP) + atrSafe * 0.08
    zoneBottom = nz(corridorLower, sessionVWAP) - atrSafe * 0.08
    zoneColor = currentIsBull ? bullColor : currentIsBear ? bearColor : neutralColor
    lastReactionZone := box.new(zoneLeft, zoneTop, zoneRight, zoneBottom, xloc = xloc.bar_index, border_color = color.new(zoneColor, 28), bgcolor = color.new(zoneColor, 86))
    array.push(reactionZones, lastReactionZone)

    label newZoneLabel = na
    if showZoneLabels and labelDensity != "Minimal"
        badgeX = int(math.round((zoneLeft + zoneRight) * 0.5))
        centerY = (zoneTop + zoneBottom) / 2.0
        labelText = currentEventLabel + " | Q " + str.tostring(reactionScore)
        newZoneLabel := label.new(badgeX, centerY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(zoneColor, 4), textcolor = f_text_on(zoneColor), size = labelSize)
        zoneLabel := newZoneLabel
    array.push(reactionLabels, newZoneLabel)
    f_trim_zone_pairs(reactionZones, reactionLabels, maxReactionZones)

// -------------------------------------------------
// Live Right-Edge Tags
// -------------------------------------------------
if showLiveTags and barstate.islast
    if not na(liveBiasTag)
        label.delete(liveBiasTag)
    if not na(liveScoreTag)
        label.delete(liveScoreTag)
    tagX = bar_index + math.max(8, zoneExtendBars + 6)
    tagGap = math.max(atrSafe * 0.95, close * 0.003)
    biasColor = f_bias_color(currentBias)
    biasAbove = close >= nz(activeContextVWAP, close)
    biasY = biasAbove ? close + tagGap : close - tagGap
    scoreY = biasAbove ? biasY + tagGap : biasY - tagGap
    biasStyle = biasAbove ? label.style_label_down : label.style_label_up
    biasSlug = str.contains(currentBias, "Bullish") ? "Bull Flow" : str.contains(currentBias, "Bearish") ? "Bear Flow" : "Neutral Flow"
    liveBiasTag := label.new(tagX, biasY, biasSlug, xloc = xloc.bar_index, yloc = yloc.price, style = biasStyle, color = color.new(biasColor, 0), textcolor = f_text_on(biasColor), size = labelSize)
    liveScoreTag := label.new(tagX + 4, scoreY, "Session Score | " + str.tostring(reactionScore) + "/100", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = labelSize)
else if not showLiveTags
    if not na(liveBiasTag)
        label.delete(liveBiasTag)
        liveBiasTag := na
    if not na(liveScoreTag)
        label.delete(liveScoreTag)
        liveScoreTag := na

if barstate.islast
    if not na(vwapTagLabel)
        label.delete(vwapTagLabel)
    lastLineVisible = not na(lastTrackedVWAP) and not na(lastTrackedVWAPBar) and bar_index - lastTrackedVWAPBar <= visibleHistoryBars
    if showVWAPTag and showSessionVWAP and allowCalc and lastLineVisible
        tagX = bar_index + math.max(18, zoneExtendBars + 14)
        tagY = lastTrackedVWAP
        vwapTagLabel := label.new(tagX, tagY, str.upper(sessionCode) + " SVWAP " + str.tostring(lastTrackedVWAP, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(headerBg), color = headerBg, size = labelSize)

// -------------------------------------------------
// Panel
// -------------------------------------------------
sessionStatus = not allowCalc ? "Use intraday chart" : inSession ? str.upper(sessionCode) + " session live" : postSessionActive ? "Post-session map" : "Waiting next session"
latestLineText = not allowCalc ? "Intraday only" : not na(lastTrackedVWAP) ? str.upper(sessionCode) + " SVWAP | " + (inSession ? slopeText : "Flat") : "Waiting for SVWAP"
reactRateText = reactTotal > 0 ? str.tostring(int(math.round(reactRate))) + "% (" + str.tostring(reactWon) + "/" + str.tostring(reactTotal) + ")" : "Building"
reactRateColor = na(reactRate) ? panelValueCol : reactRate >= 55.0 ? bullColor : reactRate >= 45.0 ? neutralColor : bearColor

var table panel = na

if showPanel and na(panel)
    panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Session VWAP Reaction Engine", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 1, 1, 7)

    table.cell(panel, 0, 1, "Session", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, sessionStatus, text_color = f_state_on_panel(f_bias_color(sessionStatus)), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "Action", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, actionText, text_color = f_text_on(actionColor), bgcolor = actionColor, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 3, "Bias", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, currentBias, text_color = f_state_on_panel(f_bias_color(currentBias)), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "Context Score", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, str.tostring(reactionScore) + " / 100", text_color = panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 5, "Reaction Proof", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, reactRateText, text_color = f_state_on_panel(reactRateColor), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 6, "Last Reaction", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, lastReactionText, text_color = f_state_on_panel(f_bias_color(lastReactionText)), bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 7, "Latest Line", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, latestLineText, text_color = f_state_on_panel(accentColor), bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertBullReclaim = newEvent and bullReclaim and (confirmedAlertsOnly ? barstate.isconfirmed : true)
alertBearReclaim = newEvent and bearReclaim and (confirmedAlertsOnly ? barstate.isconfirmed : true)
alertBullReject = newEvent and bullReject and (confirmedAlertsOnly ? barstate.isconfirmed : true)
alertBearReject = newEvent and bearReject and (confirmedAlertsOnly ? barstate.isconfirmed : true)
alertBullBounce = newEvent and bullBounce and (confirmedAlertsOnly ? barstate.isconfirmed : true)
alertBearBounce = newEvent and bearBounce and (confirmedAlertsOnly ? barstate.isconfirmed : true)
alertBullShift = newEvent and (str.contains(currentReactionState, "Bullish") or str.contains(currentReactionState, "Support") or str.contains(currentReactionState, "Lift")) and (confirmedAlertsOnly ? barstate.isconfirmed : true)
alertBearShift = newEvent and (str.contains(currentReactionState, "Bearish") or str.contains(currentReactionState, "Pressure") or str.contains(currentReactionState, "Resistance")) and (confirmedAlertsOnly ? barstate.isconfirmed : true)

alertcondition(alertBullReclaim, "Bullish Session VWAP Reclaim", "Session VWAP Reaction Engine: bullish reclaim confirmed.")
alertcondition(alertBearReclaim, "Bearish Session VWAP Reclaim", "Session VWAP Reaction Engine: bearish reclaim confirmed.")
alertcondition(alertBullReject, "Bullish Session VWAP Reject", "Session VWAP Reaction Engine: bullish reject confirmed.")
alertcondition(alertBearReject, "Bearish Session VWAP Reject", "Session VWAP Reaction Engine: bearish reject confirmed.")
alertcondition(alertBullBounce, "Bullish Session VWAP Bounce", "Session VWAP Reaction Engine: bullish bounce confirmed.")
alertcondition(alertBearBounce, "Bearish Session VWAP Bounce", "Session VWAP Reaction Engine: bearish bounce confirmed.")
alertcondition(alertBullShift, "Reaction State Shifted Bullish", "Session VWAP Reaction Engine: reaction state shifted bullish.")
alertcondition(alertBearShift, "Reaction State Shifted Bearish", "Session VWAP Reaction Engine: reaction state shifted bearish.")
````
