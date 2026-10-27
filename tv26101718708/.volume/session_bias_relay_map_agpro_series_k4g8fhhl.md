# Session Bias Relay Map [AGPro Series]

- url: https://www.tradingview.com/script/K4g8fhHL-Session-Bias-Relay-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;61709761d6ec4acfb55a4812cfb8339a
- version: 4.0

## Description

Session Bias Relay Map [AGPro Series]

🧠 Core Idea

Did Asia, London, and New York pass the same bias forward, or did the next session reject the market narrative?


📌 Overview / What it does

Session Bias Relay Map is an intraday session-structure tool built to visualize how directional bias moves from one major trading session to the next.

The script tracks Asia, London, and New York session ranges, scores each session's directional bias, and classifies whether the active session confirms, conflicts with, or reverses the previous session's narrative.

It does not predict price direction, automate trades, or claim that a session handoff must continue. It is a structured visualization and decision-support map for session bias, market narrative, and intraday context.


🎯 Purpose & Design Philosophy

Many session tools draw boxes, highs, lows, or kill zones.

This script was built to answer a more contextual question:

Did the next major session accept the prior session's directional story, or did it break the handoff?

The design goal is to help traders read sessions as a relay of market intent instead of isolated time windows. It supports discretionary market reading, session review, and intraday structure analysis.


⚡ Why This Script Is Different

Most session indicators focus on time blocks, session highs, and session lows.

This script does NOT stop at drawing session boxes.

Instead, it evaluates how each session behaves relative to the prior session. It scores bias strength, detects handoff confirmation, identifies conflict, and highlights reversal pressure when the active session builds a strong opposite narrative.


⚙️ Methodology

1. Session Detection

The script tracks configurable Asia, London, and New York session windows using the chart symbol's exchange timezone.

2. Session Range Mapping

For each session, it records open, high, low, close, midpoint, bar count, and live range behavior.

3. Bias Scoring

Session bias is scored using body pressure, close location inside the session range, and optional relative volume confirmation.

4. Relay Evaluation

London is compared against the completed Asia bias.

New York is compared against the completed London bias.

5. Visual Output

The chart displays session boxes, midpoint rails, centered session labels, relay event labels, right-side tags, alerts, and a compact AG Pro decision panel.


🗺️ How to Read the Chart

Session Boxes = the active session range built from each configured time window.

Centered Labels = the session name, current bias, relay state, and quality score.

Midpoint Rails = the middle of each session range, useful for reading control and balance.

Relay Event Labels = confirmation, conflict, or reversal events when a later session responds to the prior session.

Right-Side Tags = the current relay state and active session bias.

Panel = summarizes active session, relay state, bias score, prior session, session quality scores, next context, and timeframe scope.


🚦 Signals & States

• RELAY CONFIRMED → the active session supports the previous session's directional bias.

• RELAY REVERSAL → the active session builds strong bias opposite to the previous session.

• BIAS CONFLICT → the active session does not clearly confirm the previous session.

• FIRST LEG → Asia is building the first session bias for the daily relay.

• WAIT HANDOFF → the active handoff does not yet have enough evidence.

• BULLISH → the session is closing with bullish range pressure.

• BEARISH → the session is closing with bearish range pressure.

• NEUTRAL → the session does not have enough directional pressure.


🔔 Alerts Logic

Alerts trigger when a major relay state appears.

• Session Bias Relay Confirmed → the active session confirmed the directional bias passed from the previous session.

• Session Bias Conflict → the active session failed to confirm the previous session and is showing conflict.

• Session Bias Reversal → the active session built strong bias opposite to the previous session.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• The previous session has a clear directional bias
• The active session has enough bars to evaluate
• The active session bias score is above the confirmation threshold
• Price closes with clear range position
• Relative volume supports participation
• The relay label and panel state agree

If these elements do not align, the script avoids forcing a strong directional interpretation.


📊 When to Use

• Intraday session analysis
• Forex, crypto, index futures, and liquid stock index products
• Asia-to-London handoff review
• London-to-New-York handoff review
• Market narrative tracking
• Session range and bias studies
• 15m, 30m, 1H, and 2H charts


⚠️ When NOT to Use

• Daily, weekly, or monthly charts
• Very low-liquidity symbols
• Markets with irregular or meaningless session windows
• Extremely noisy conditions where session closes do not carry useful information
• Situations where a single session should not be over-interpreted
• Symbols where the chart exchange timezone does not match the intended session model


🎛️ Key Inputs

• Asia Session → defines the first session window used to build the initial bias.

• London Session → defines the second session window used to evaluate the Asia handoff.

• New York Session → defines the third session window used to evaluate the London handoff.

• Max Chart TF Minutes → limits the largest timeframe that should build the relay map.

• Bias Confirmation Threshold → controls how strong a session must be before it can confirm a relay.

• Conflict Threshold → controls when a session is treated as weak or conflicted.

• Minimum Handoff Bars → prevents early-session noise from printing premature relay labels.

• Use Volume Confirmation → adds relative volume pressure to the bias score.

• Show Session Boxes → controls the main visual range boxes.

• Show Relay Event Labels → controls confirmation, conflict, and reversal labels.

• Label Font Size → controls chart label and tag text size.

• Panel Font Size → controls panel text size.


🖥️ Interface & Visual Design

The visual hierarchy is built around the session relay story.

Session boxes define the time windows.

Centered labels make each session readable without hunting through the chart.

Relay labels highlight the important handoff moments.

Right-side tags keep the current state visible.

The AG Pro panel summarizes the active session context in a clean, compact format.


🧪 Practical Usage Workflow

1. Choose session windows that match the market being studied.

2. Let Asia build the first bias leg.

3. Watch whether London confirms, conflicts with, or reverses Asia.

4. Watch whether New York confirms, conflicts with, or reverses London.

5. Use the panel to check relay state, active bias, quality score, and timeframe scope.

6. Interpret the result inside broader market structure, liquidity, and volatility context.


🔍 Interpretation Guidelines

A relay confirmation does not guarantee continuation. It means the active session is supporting the prior session's directional bias according to the script's rule set.

A relay reversal does not guarantee a full trend reversal. It means the active session is building strong opposite pressure relative to the previous session.

A bias conflict is not a failure. It is useful information that the market narrative is not clean.

The best use is contextual: combine the relay state with support, resistance, liquidity, volume, and higher-timeframe structure.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a generic session box indicator.

It is not a kill-zone strategy.


⚠️ Limitations & Transparency

Session settings matter. Poorly selected session windows can produce weak or misleading context.

Timeframe differences can affect how session handoffs appear.

Low-liquidity markets can distort bias scores.

Markets with irregular trading hours may need custom session inputs.

Relative volume can help, but it does not guarantee better interpretation in every market.


🧠 Market Context Notes

Session behavior is often shaped by liquidity, regional participation, volatility expansion, and macro timing.

The same relay state can mean different things depending on whether the market is trending, ranging, or reacting to news.

The script is strongest when used as a narrative map, not as a standalone decision machine.


🧾 Use Case Examples

• If Asia builds a bullish range and London also closes with strong bullish pressure, the relay may show confirmation.

• If Asia builds bullish pressure but London quickly forms strong bearish pressure, the relay may show reversal.

• If London begins with weak movement and no clear range pressure, the relay may show conflict or wait for more evidence.


🧱 System Philosophy

Session Bias Relay Map is part of the AGPro Series approach to decision-support tools:

clear structure, premium chart readability, honest interpretation, and no promise of certainty.

The goal is to help traders see market context faster without turning analysis into signal spam.


🔐 Non-Promise Statement

No script can know the future.

No session handoff is guaranteed.

No signal should be interpreted without broader market context.


📉 Risk Disclosure

Trading involves risk.

Markets can move unpredictably.

This script is for educational and analytical purposes only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own decisions.


📚 Educational Note

Use this script to study how market participation changes across sessions.

The value is not only in the label. The value is in learning how the session narrative develops, confirms, conflicts, or reverses over time.

## Source Code

````pine
// --------------------------------------------------
// Session Bias Relay Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Session Bias Relay Map studies whether Asia, London, and New York pass the
// same directional session narrative or break it with conflict and reversal.
// It builds session range boxes, live bias scores, relay handoff labels,
// a relay hit-rate proof readout, right-side tags, alerts, and an AG Pro panel
// for intraday session context and trade decision support.
// --------------------------------------------------

//@version=6
indicator("Session Bias Relay Map [AGPro Series]",
     shorttitle = "AG Pro SBR",
     overlay = true,
     max_labels_count = 120,
     max_lines_count = 40,
     max_boxes_count = 40)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
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
color darkText      = color.rgb(17, 24, 39)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_SESSION = "Session Windows"
string G_ENGINE  = "Relay Engine"
string G_VISUAL  = "Visual Design"
string G_PANEL   = "Panel"
string G_ALERTS  = "Alerts"

string asiaSession = input.session("0000-0600", "Asia Session", group = G_SESSION,
     tooltip = "Defines the Asia session window used to build the first bias range. The chart exchange timezone is used.")
string londonSession = input.session("0700-1100", "London Session", group = G_SESSION,
     tooltip = "Defines the London session window used to evaluate whether Asia bias is relayed, conflicted, or reversed.")
string newYorkSession = input.session("1330-1700", "New York Session", group = G_SESSION,
     tooltip = "Defines the New York session window used to evaluate whether London bias is relayed, conflicted, or reversed.")
int maxChartTfMinutes = input.int(120, "Max Chart TF Minutes", minval = 1, maxval = 240, group = G_SESSION,
     tooltip = "Maximum chart timeframe that should build the relay map. Session handoffs are best read on intraday charts.")
bool showIntradayNotice = input.bool(true, "Show Intraday Notice", group = G_SESSION,
     tooltip = "Shows a panel warning on daily or higher timeframes where session relay behavior cannot be mapped precisely.")

int biasThreshold = input.int(58, "Bias Confirmation Threshold", minval = 40, maxval = 90, group = G_ENGINE,
     tooltip = "Minimum session bias score required before a session can confirm a directional relay.")
int conflictThreshold = input.int(44, "Conflict Threshold", minval = 20, maxval = 70, group = G_ENGINE,
     tooltip = "Below this score, a session is treated as weak or conflicted rather than directional.")
int handoffMinBars = input.int(3, "Minimum Handoff Bars", minval = 1, maxval = 30, group = G_ENGINE,
     tooltip = "Minimum number of bars inside London or New York before a relay state can print an event label.")
int proofWindowBars = input.int(6, "Relay Proof Window", minval = 2, maxval = 50, group = G_ENGINE,
     tooltip = "After a directional relay (Confirm or Reversal), the script waits this many bars and checks whether price actually moved in the relayed direction. Feeds the Relay Hit Rate readout in the panel.")
bool volumeConfirm = input.bool(true, "Use Volume Confirmation", group = G_ENGINE,
     tooltip = "Adds relative volume to the session bias score when volume data is available.")
int volumeLen = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Lookback used to compare current volume with recent activity.")
int atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_ENGINE,
     tooltip = "ATR is used for label spacing and session range normalization.")

bool showSessionBoxes = input.bool(true, "Show Session Boxes", group = G_VISUAL,
     tooltip = "Displays Asia, London, and New York session ranges as projected bias boxes.")
bool showMidlines = input.bool(true, "Show Session Midlines", group = G_VISUAL,
     tooltip = "Displays a dotted midpoint rail inside active session boxes.")
bool showSessionLabels = input.bool(true, "Show Centered Session Labels", group = G_VISUAL,
     tooltip = "Places centered labels inside session boxes so each session story is readable at first glance. Ended sessions fade into a compact archive tag.")
bool showEventLabels = input.bool(true, "Show Relay Event Labels", group = G_VISUAL,
     tooltip = "Prints curated labels when a session confirms, conflicts with, or reverses the previous session bias.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Displays one compact right-side relay badge with the active session, handoff state, and quality score.")
bool showBiasGlow = input.bool(false, "Color Bars by Relay State", group = G_VISUAL,
     tooltip = "Optionally colors bars by the current relay state for stronger visual emphasis.")
int projectionBars = input.int(30, "Right Tag Projection Bars", minval = 8, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how far right-side relay tags are placed from the current bar.")
int labelCooldownBars = input.int(28, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between relay event labels so the chart stays premium and readable.")
int maxEventLabels = input.int(12, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Caps historical event labels for performance and visual clarity.")
float labelOffsetAtr = input.float(0.95, "Label Offset ATR", minval = 0.15, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles so they do not feel buried in price.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls the font size used by event labels, centered session labels, and right-side tags.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro session relay panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between a high-contrast dark AGPro surface and a clean light surface.")
string panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls text size inside the panel.")

bool alertRelayConfirm = input.bool(true, "Alert: Bias Relay Confirmed", group = G_ALERTS,
     tooltip = "Triggers when London or New York confirms the directional bias passed from the previous session.")
bool alertRelayConflict = input.bool(true, "Alert: Bias Conflict", group = G_ALERTS,
     tooltip = "Triggers when the active session fails to confirm the previous session and becomes conflicted.")
bool alertRelayReversal = input.bool(true, "Alert: Bias Reversal", group = G_ALERTS,
     tooltip = "Triggers when the active session builds strong bias opposite to the previous session.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posName) =>
    switch posName
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(int(math.round(value)))

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeName) =>
    themeName == "Light" ? color.rgb(148, 163, 184) : color.rgb(86, 103, 130)

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : color.rgb(190, 202, 220)

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_bias_text(int direction) =>
    direction > 0 ? "Bullish" : direction < 0 ? "Bearish" : "Neutral"

f_bias_color(int direction, float scoreValue) =>
    direction > 0 and scoreValue >= biasThreshold ? bullColor : direction < 0 and scoreValue >= biasThreshold ? bearColor : scoreValue <= conflictThreshold ? neutralColor : accentColor

f_panel_color(color sourceColor, string themeName) =>
    themeName == "Light" ? sourceColor : sourceColor == panelValueCol ? color.rgb(245, 247, 250) : sourceColor

f_set_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeName) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(themeName), bgcolor = rowBg, text_size = f_size(sizeName), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = f_panel_color(rightColor, themeName), bgcolor = rowBg, text_size = f_size(sizeName), text_halign = text.align_right)

f_session_score(float openValue, float highValue, float lowValue, float closeValue, float relVolValue) =>
    float sessionRange = math.max(highValue - lowValue, syminfo.mintick)
    float bodyPressure = math.abs(closeValue - openValue) / sessionRange * 55.0
    float closeLocation = (closeValue - lowValue) / sessionRange * 100.0
    float locationPressure = math.abs(closeLocation - 50.0) * 0.65
    float volumePressure = volumeConfirm ? f_clamp(relVolValue, 0.7, 1.8) * 8.0 : 8.0
    f_clamp(bodyPressure + locationPressure + volumePressure, 0.0, 100.0)

f_session_direction(float openValue, float highValue, float lowValue, float closeValue, float scoreValue) =>
    float sessionRange = math.max(highValue - lowValue, syminfo.mintick)
    float closeLocation = (closeValue - lowValue) / sessionRange * 100.0
    int rawDir = closeValue > openValue and closeLocation >= 52.0 ? 1 : closeValue < openValue and closeLocation <= 48.0 ? -1 : 0
    scoreValue <= conflictThreshold ? 0 : rawDir

f_relay_state(int prevDir, int activeDirValue, float activeScoreValue, int barsInSession) =>
    int state = 0
    if barsInSession >= handoffMinBars and prevDir != 0 and activeDirValue != 0 and activeScoreValue >= biasThreshold
        state := prevDir == activeDirValue ? 1 : -1
    else if barsInSession >= handoffMinBars and prevDir != 0 and activeScoreValue <= conflictThreshold
        state := 2
    state

f_relay_text(int state) =>
    state == 1 ? "Relay Confirmed" : state == -1 ? "Relay Reversal" : state == 2 ? "Bias Conflict" : "Wait Handoff"

f_relay_short(int state) =>
    state == 1 ? "Confirm" : state == -1 ? "Reversal" : state == 2 ? "Conflict" : "Wait"

f_keep_label(array<label> store, label newLabel, int limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_update_box(box targetBox, int leftX, int rightX, float topY, float bottomY, color bgColor, color borderColor, int borderW) =>
    box.set_lefttop(targetBox, leftX, topY)
    box.set_rightbottom(targetBox, rightX, bottomY)
    box.set_bgcolor(targetBox, bgColor)
    box.set_border_color(targetBox, borderColor)
    box.set_border_width(targetBox, borderW)

f_update_line(line targetLine, int leftX, int rightX, float yValue, color lineColor) =>
    line.set_xy1(targetLine, leftX, yValue)
    line.set_xy2(targetLine, rightX, yValue)
    line.set_color(targetLine, lineColor)
    line.set_style(targetLine, line.style_dotted)
    line.set_width(targetLine, 2)

f_update_label(label targetLabel, int xValue, float yValue, string labelText, color bgColor, string sizeName) =>
    label.set_xy(targetLabel, xValue, yValue)
    label.set_text(targetLabel, labelText)
    label.set_color(targetLabel, bgColor)
    label.set_textcolor(targetLabel, f_text_on(bgColor))
    label.set_style(targetLabel, label.style_label_center)
    label.set_size(targetLabel, f_size(sizeName))

// --------------------------------------------------
// Session State Engine
// --------------------------------------------------
bool isIntraday = timeframe.isintraday
int chartTfSec = timeframe.in_seconds(timeframe.period)
bool tfSupported = isIntraday and chartTfSec <= maxChartTfMinutes * 60
string tfScopeText = not isIntraday ? "Intraday required" : tfSupported ? "<= " + str.tostring(maxChartTfMinutes) + "m active" : "<= " + str.tostring(maxChartTfMinutes) + "m required"

bool inAsia = tfSupported and not na(time(timeframe.period, asiaSession))
bool inLondon = tfSupported and not na(time(timeframe.period, londonSession))
bool inNewYork = tfSupported and not na(time(timeframe.period, newYorkSession))

bool asiaStart = inAsia and not inAsia[1]
bool londonStart = inLondon and not inLondon[1]
bool newYorkStart = inNewYork and not inNewYork[1]
bool asiaEnd = not inAsia and inAsia[1]
bool londonEnd = not inLondon and inLondon[1]
bool newYorkEnd = not inNewYork and inNewYork[1]

labelSize = f_size(labelSizeInput)
panelSize = f_size(panelSizeInput)
float atrRaw = ta.atr(atrLen)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float labelOffset = safeAtr * labelOffsetAtr
float volBase = ta.sma(nz(volume, 0.0), volumeLen)
float relVol = not na(volBase) and volBase > 0.0 ? volume / volBase : 1.0

var float asiaOpen = na
var float asiaHigh = na
var float asiaLow = na
var float asiaClose = na
var int asiaStartBar = na
var int asiaBars = 0
var int asiaDir = 0
var float asiaScore = na
var bool asiaReady = false

var float londonOpen = na
var float londonHigh = na
var float londonLow = na
var float londonClose = na
var int londonStartBar = na
var int londonBars = 0
var int londonDir = 0
var float londonScore = na
var bool londonReady = false

var float nyOpen = na
var float nyHigh = na
var float nyLow = na
var float nyClose = na
var int nyStartBar = na
var int nyBars = 0
var int nyDir = 0
var float nyScore = na
var bool nyReady = false

if asiaStart
    asiaOpen := open
    asiaHigh := high
    asiaLow := low
    asiaClose := close
    asiaStartBar := bar_index
    asiaBars := 1
    asiaReady := false

if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)
    asiaClose := close
    asiaBars := asiaStart ? 1 : asiaBars + 1
    asiaScore := f_session_score(asiaOpen, asiaHigh, asiaLow, asiaClose, relVol)
    asiaDir := f_session_direction(asiaOpen, asiaHigh, asiaLow, asiaClose, asiaScore)

if asiaEnd
    asiaReady := true

if londonStart
    londonOpen := open
    londonHigh := high
    londonLow := low
    londonClose := close
    londonStartBar := bar_index
    londonBars := 1
    londonReady := false

if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow := na(londonLow) ? low : math.min(londonLow, low)
    londonClose := close
    londonBars := londonStart ? 1 : londonBars + 1
    londonScore := f_session_score(londonOpen, londonHigh, londonLow, londonClose, relVol)
    londonDir := f_session_direction(londonOpen, londonHigh, londonLow, londonClose, londonScore)

if londonEnd
    londonReady := true

if newYorkStart
    nyOpen := open
    nyHigh := high
    nyLow := low
    nyClose := close
    nyStartBar := bar_index
    nyBars := 1
    nyReady := false

if inNewYork
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow := na(nyLow) ? low : math.min(nyLow, low)
    nyClose := close
    nyBars := newYorkStart ? 1 : nyBars + 1
    nyScore := f_session_score(nyOpen, nyHigh, nyLow, nyClose, relVol)
    nyDir := f_session_direction(nyOpen, nyHigh, nyLow, nyClose, nyScore)

if newYorkEnd
    nyReady := true

int londonRelayState = inLondon and asiaReady ? f_relay_state(asiaDir, londonDir, londonScore, londonBars) : 0
int nyRelayState = inNewYork and londonReady ? f_relay_state(londonDir, nyDir, nyScore, nyBars) : 0
int activeRelayState = inNewYork ? nyRelayState : inLondon ? londonRelayState : 0
string activeSessionName = inAsia ? "Asia" : inLondon ? "London" : inNewYork ? "New York" : "Off Session"
int activeDir = inAsia ? asiaDir : inLondon ? londonDir : inNewYork ? nyDir : 0
float activeScore = inAsia ? asiaScore : inLondon ? londonScore : inNewYork ? nyScore : na
string activeBiasText = f_bias_text(activeDir)
string relayText = activeRelayState == 0 and inAsia ? "First Leg" : f_relay_text(activeRelayState)
color relayColor = activeRelayState == 1 ? bullColor : activeRelayState == -1 ? bearColor : activeRelayState == 2 ? neutralColor : f_bias_color(activeDir, nz(activeScore, 0.0))
string previousSessionText = inLondon ? "Asia" : inNewYork ? "London" : "None"
string nextContext = not isIntraday ? "Use intraday chart" : not tfSupported ? "Lower timeframe" : inAsia ? "Build first bias" : activeRelayState == 1 ? "Bias passed" : activeRelayState == -1 ? "Narrative reversed" : activeRelayState == 2 ? "Conflict active" : inLondon or inNewYork ? "Wait relay" : "Wait session"

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
var box asiaBox = na
var box londonBox = na
var box nyBox = na
var line asiaMid = na
var line londonMid = na
var line nyMid = na
var label asiaCenter = na
var label londonCenter = na
var label nyCenter = na
var label relayTag = na
var color asiaColMemory = na
var color londonColMemory = na
var color nyColMemory = na
var array<label> eventLabels = array.new<label>()

if asiaStart and not na(asiaBox)
    box.delete(asiaBox)
    if not na(asiaMid)
        line.delete(asiaMid)
    if not na(asiaCenter)
        label.delete(asiaCenter)
    asiaBox := na
    asiaMid := na
    asiaCenter := na

if londonStart and not na(londonBox)
    box.delete(londonBox)
    if not na(londonMid)
        line.delete(londonMid)
    if not na(londonCenter)
        label.delete(londonCenter)
    londonBox := na
    londonMid := na
    londonCenter := na

if newYorkStart and not na(nyBox)
    box.delete(nyBox)
    if not na(nyMid)
        line.delete(nyMid)
    if not na(nyCenter)
        label.delete(nyCenter)
    nyBox := na
    nyMid := na
    nyCenter := na

float asiaMidValue = not na(asiaHigh) and not na(asiaLow) ? (asiaHigh + asiaLow) * 0.5 : na
float londonMidValue = not na(londonHigh) and not na(londonLow) ? (londonHigh + londonLow) * 0.5 : na
float nyMidValue = not na(nyHigh) and not na(nyLow) ? (nyHigh + nyLow) * 0.5 : na

if showSessionBoxes and inAsia and not na(asiaHigh) and not na(asiaLow)
    color asiaColor = f_bias_color(asiaDir, nz(asiaScore, 0.0))
    asiaColMemory := asiaColor
    if na(asiaBox)
        asiaBox := box.new(asiaStartBar, asiaHigh, bar_index, asiaLow, xloc = xloc.bar_index, bgcolor = color.new(asiaColor, 84), border_color = color.new(asiaColor, 16), border_width = 2)
    else
        f_update_box(asiaBox, asiaStartBar, bar_index, asiaHigh, asiaLow, color.new(asiaColor, 84), color.new(asiaColor, 16), 2)
    if showMidlines
        if na(asiaMid)
            asiaMid := line.new(asiaStartBar, asiaMidValue, bar_index, asiaMidValue, xloc = xloc.bar_index, color = color.new(asiaColor, 10), style = line.style_dotted, width = 2)
        else
            f_update_line(asiaMid, asiaStartBar, bar_index, asiaMidValue, color.new(asiaColor, 10))
    if showSessionLabels
        int asiaCenterX = int(math.round((asiaStartBar + bar_index) * 0.5))
        string asiaLabelText = "Asia " + f_bias_text(asiaDir) + "\nScore " + f_score(asiaScore)
        if na(asiaCenter)
            asiaCenter := label.new(asiaCenterX, asiaMidValue, asiaLabelText, xloc = xloc.bar_index, style = label.style_label_center, color = color.new(asiaColor, 0), textcolor = f_text_on(asiaColor), size = labelSize, textalign = text.align_center)
        else
            f_update_label(asiaCenter, asiaCenterX, asiaMidValue, asiaLabelText, color.new(asiaColor, 0), labelSizeInput)

if showSessionBoxes and inLondon and not na(londonHigh) and not na(londonLow)
    color londonColor = activeRelayState == 1 ? bullColor : activeRelayState == -1 ? bearColor : activeRelayState == 2 ? neutralColor : f_bias_color(londonDir, nz(londonScore, 0.0))
    londonColMemory := londonColor
    if na(londonBox)
        londonBox := box.new(londonStartBar, londonHigh, bar_index, londonLow, xloc = xloc.bar_index, bgcolor = color.new(londonColor, 84), border_color = color.new(londonColor, 14), border_width = 2)
    else
        f_update_box(londonBox, londonStartBar, bar_index, londonHigh, londonLow, color.new(londonColor, 84), color.new(londonColor, 14), 2)
    if showMidlines
        if na(londonMid)
            londonMid := line.new(londonStartBar, londonMidValue, bar_index, londonMidValue, xloc = xloc.bar_index, color = color.new(londonColor, 10), style = line.style_dotted, width = 2)
        else
            f_update_line(londonMid, londonStartBar, bar_index, londonMidValue, color.new(londonColor, 10))
    if showSessionLabels
        int londonCenterX = int(math.round((londonStartBar + bar_index) * 0.5))
        string londonLabelText = "London " + f_relay_short(londonRelayState) + "\nScore " + f_score(londonScore)
        if na(londonCenter)
            londonCenter := label.new(londonCenterX, londonMidValue, londonLabelText, xloc = xloc.bar_index, style = label.style_label_center, color = color.new(londonColor, 0), textcolor = f_text_on(londonColor), size = labelSize, textalign = text.align_center)
        else
            f_update_label(londonCenter, londonCenterX, londonMidValue, londonLabelText, color.new(londonColor, 0), labelSizeInput)

if showSessionBoxes and inNewYork and not na(nyHigh) and not na(nyLow)
    color nyColor = activeRelayState == 1 ? bullColor : activeRelayState == -1 ? bearColor : activeRelayState == 2 ? neutralColor : f_bias_color(nyDir, nz(nyScore, 0.0))
    nyColMemory := nyColor
    if na(nyBox)
        nyBox := box.new(nyStartBar, nyHigh, bar_index, nyLow, xloc = xloc.bar_index, bgcolor = color.new(nyColor, 84), border_color = color.new(nyColor, 14), border_width = 2)
    else
        f_update_box(nyBox, nyStartBar, bar_index, nyHigh, nyLow, color.new(nyColor, 84), color.new(nyColor, 14), 2)
    if showMidlines
        if na(nyMid)
            nyMid := line.new(nyStartBar, nyMidValue, bar_index, nyMidValue, xloc = xloc.bar_index, color = color.new(nyColor, 10), style = line.style_dotted, width = 2)
        else
            f_update_line(nyMid, nyStartBar, bar_index, nyMidValue, color.new(nyColor, 10))
    if showSessionLabels
        int nyCenterX = int(math.round((nyStartBar + bar_index) * 0.5))
        string nyLabelText = "New York " + f_relay_short(nyRelayState) + "\nScore " + f_score(nyScore)
        if na(nyCenter)
            nyCenter := label.new(nyCenterX, nyMidValue, nyLabelText, xloc = xloc.bar_index, style = label.style_label_center, color = color.new(nyColor, 0), textcolor = f_text_on(nyColor), size = labelSize, textalign = text.align_center)
        else
            f_update_label(nyCenter, nyCenterX, nyMidValue, nyLabelText, color.new(nyColor, 0), labelSizeInput)

// On session end, preserve one compact centered archive badge. Every visible
// session box therefore keeps an explicit identity without adding floating noise.
if asiaEnd and not na(asiaBox)
    color aCol = na(asiaColMemory) ? accentColor : asiaColMemory
    box.set_bgcolor(asiaBox, color.new(aCol, 92))
    box.set_border_color(asiaBox, color.new(aCol, 58))
    box.set_border_width(asiaBox, 1)
    if showSessionLabels and not na(asiaCenter)
        f_update_label(asiaCenter, int(math.round((asiaStartBar + bar_index - 1) * 0.5)), asiaMidValue, "Asia | " + f_bias_text(asiaDir) + " | Q" + f_score(asiaScore), color.new(aCol, 8), labelSizeInput)

if londonEnd and not na(londonBox)
    color lCol = na(londonColMemory) ? accentColor : londonColMemory
    box.set_bgcolor(londonBox, color.new(lCol, 92))
    box.set_border_color(londonBox, color.new(lCol, 58))
    box.set_border_width(londonBox, 1)
    if showSessionLabels and not na(londonCenter)
        f_update_label(londonCenter, int(math.round((londonStartBar + bar_index - 1) * 0.5)), londonMidValue, "London | " + f_relay_short(londonRelayState[1]) + " | Q" + f_score(londonScore), color.new(lCol, 8), labelSizeInput)

if newYorkEnd and not na(nyBox)
    color nCol = na(nyColMemory) ? accentColor : nyColMemory
    box.set_bgcolor(nyBox, color.new(nCol, 92))
    box.set_border_color(nyBox, color.new(nCol, 58))
    box.set_border_width(nyBox, 1)
    if showSessionLabels and not na(nyCenter)
        f_update_label(nyCenter, int(math.round((nyStartBar + bar_index - 1) * 0.5)), nyMidValue, "New York | " + f_relay_short(nyRelayState[1]) + " | Q" + f_score(nyScore), color.new(nCol, 8), labelSizeInput)

// --------------------------------------------------
// Event Labels and Right Tags
// --------------------------------------------------
var int lastEventBar = na
bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
bool londonRelayChanged = bar_index > 0 ? londonRelayState != londonRelayState[1] : false
bool nyRelayChanged = bar_index > 0 ? nyRelayState != nyRelayState[1] : false
bool londonEvent = inLondon and londonBars >= handoffMinBars and londonRelayState != 0 and londonRelayChanged
bool nyEvent = inNewYork and nyBars >= handoffMinBars and nyRelayState != 0 and nyRelayChanged
int eventState = londonEvent ? londonRelayState : nyEvent ? nyRelayState : 0
string eventSession = londonEvent ? "London" : nyEvent ? "New York" : ""
float eventScore = londonEvent ? londonScore : nyEvent ? nyScore : na
int eventDir = londonEvent ? londonDir : nyEvent ? nyDir : 0
string eventText = eventSession + " | " + f_relay_short(eventState) + " | Q" + f_score(eventScore)
color eventColor = eventState == 1 ? bullColor : eventState == -1 ? bearColor : eventState == 2 ? neutralColor : accentColor
// Keep every event label off the candle body: Confirm below, Reversal / Conflict above
float eventY = eventState == 1 ? low - labelOffset : high + labelOffset
eventStyle = eventState == 1 ? label.style_label_up : label.style_label_down

if showEventLabels and (londonEvent or nyEvent) and canPrintEvent and barstate.isconfirmed
    label newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventStyle, textcolor = f_text_on(eventColor), color = color.new(eventColor, 4), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, newEventLabel, maxEventLabels)
    lastEventBar := bar_index

int rightX = bar_index + projectionBars
float relayTagY = close + labelOffset
color biasColor = f_bias_color(activeDir, nz(activeScore, 0.0))
string relayBadgeState = inAsia ? "FIRST LEG" : str.upper(f_relay_short(activeRelayState))
string relayBadgeText = activeSessionName == "Off Session" ? "OFF SESSION | WAIT NEXT" : str.upper(activeSessionName) + " | " + relayBadgeState + " | Q" + f_score(activeScore)

if barstate.islast and showRightTags and tfSupported
    if na(relayTag)
        relayTag := label.new(rightX, relayTagY, relayBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(relayColor, 0), textcolor = f_text_on(relayColor), size = labelSize)
    else
        label.set_xy(relayTag, rightX, relayTagY)
        label.set_text(relayTag, relayBadgeText)
        label.set_color(relayTag, color.new(relayColor, 0))
        label.set_textcolor(relayTag, f_text_on(relayColor))
        label.set_size(relayTag, labelSize)

if barstate.islast and (not showRightTags or not tfSupported)
    if not na(relayTag)
        label.delete(relayTag)
        relayTag := na

color barCol = activeRelayState == 1 ? color.new(bullColor, 62) : activeRelayState == -1 ? color.new(bearColor, 62) : activeRelayState == 2 ? color.new(neutralColor, 65) : na
barcolor(showBiasGlow ? barCol : na)

// --------------------------------------------------
// Relay Hit Rate (Proof Pass)
// --------------------------------------------------
// After a directional relay, wait proofWindowBars and check whether price actually
// followed the relayed direction. Builds an honest, self-measured success rate.
var int relayProofHits = 0
var int relayProofTotal = 0
var bool proofPending = false
var int proofStartBar = na
var float proofEntry = na
var int proofExpectDir = 0

bool directionalRelayEvent = (londonEvent and (londonRelayState == 1 or londonRelayState == -1)) or (nyEvent and (nyRelayState == 1 or nyRelayState == -1))

if barstate.isconfirmed
    if directionalRelayEvent and not proofPending and eventDir != 0
        proofPending := true
        proofStartBar := bar_index
        proofEntry := close
        proofExpectDir := eventDir
    if proofPending and not na(proofStartBar) and bar_index - proofStartBar >= proofWindowBars
        bool proofHit = proofExpectDir > 0 ? close > proofEntry : proofExpectDir < 0 ? close < proofEntry : false
        relayProofTotal += 1
        if proofHit
            relayProofHits += 1
        proofPending := false

float relayProofRate = relayProofTotal > 0 ? relayProofHits / relayProofTotal * 100.0 : na
string proofText = relayProofTotal > 0 ? str.tostring(int(math.round(relayProofRate))) + "% (" + str.tostring(relayProofHits) + "/" + str.tostring(relayProofTotal) + ")" : "Building"
color proofColor = relayProofTotal == 0 ? panelValueCol : relayProofRate >= 60.0 ? bullColor : relayProofRate >= 45.0 ? neutralColor : bearColor

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 9, bgcolor = f_panel_bg(panelThemeInput), frame_color = f_panel_border(panelThemeInput), frame_width = 1, border_color = f_panel_border(panelThemeInput), border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Session Bias Relay Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, 8)
    table.cell(panel, 0, 0, "AG Pro Session Bias Relay Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    f_set_row(panel, 1, "Active Session", activeSessionName, panelValueCol, panelThemeInput, panelSizeInput)
    f_set_row(panel, 2, "Relay State", relayText, relayColor, panelThemeInput, panelSizeInput)
    f_set_row(panel, 3, "Active Bias", activeBiasText + " / " + f_score(activeScore), biasColor, panelThemeInput, panelSizeInput)
    f_set_row(panel, 4, "Previous Session", previousSessionText, panelValueCol, panelThemeInput, panelSizeInput)
    f_set_row(panel, 5, "Session Scores", f_score(asiaScore) + " / " + f_score(londonScore) + " / " + f_score(nyScore), panelValueCol, panelThemeInput, panelSizeInput)
    f_set_row(panel, 6, "Relay Hit Rate", proofText, proofColor, panelThemeInput, panelSizeInput)
    f_set_row(panel, 7, "Next Context", nextContext, relayColor, panelThemeInput, panelSizeInput)
    f_set_row(panel, 8, "TF Scope", showIntradayNotice and not isIntraday ? "Intraday required" : tfScopeText, tfSupported ? panelValueCol : neutralColor, panelThemeInput, panelSizeInput)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
bool relayConfirmEvent = barstate.isconfirmed and ((londonEvent and londonRelayState == 1) or (nyEvent and nyRelayState == 1))
bool relayConflictEvent = barstate.isconfirmed and ((londonEvent and londonRelayState == 2) or (nyEvent and nyRelayState == 2))
bool relayReversalEvent = barstate.isconfirmed and ((londonEvent and londonRelayState == -1) or (nyEvent and nyRelayState == -1))

alertcondition(alertRelayConfirm and relayConfirmEvent, "Session Bias Relay Confirmed", "Session Bias Relay Map: the active session confirmed the directional bias passed from the previous session.")
alertcondition(alertRelayConflict and relayConflictEvent, "Session Bias Conflict", "Session Bias Relay Map: the active session failed to confirm the previous session and is showing conflict.")
alertcondition(alertRelayReversal and relayReversalEvent, "Session Bias Reversal", "Session Bias Relay Map: the active session built strong bias opposite to the previous session.")
````
