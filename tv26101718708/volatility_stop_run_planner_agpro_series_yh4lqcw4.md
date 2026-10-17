# Volatility Stop Run Planner [AGPro Series]

- url: https://www.tradingview.com/script/yH4lQCW4-Volatility-Stop-Run-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;b639fa96f2084287adfea278f715d8b1
- version: 4.0

## Description

Volatility Stop Run Planner [AGPro Series]

🧠 Core Idea

Is the current volatility spike a stop-run review context, or is it behaving more like real expansion?


📌 Overview / What it does

Volatility Stop Run Planner [AGPro Series] is a chart-first volatility risk and execution-readiness tool designed to evaluate sharp ATR expansion around recent range edges.

The script studies wick expansion, ATR load, close recovery, range-edge penetration, reclaim quality, and early follow-through. It then converts qualified events into a 0-100 planner score, a clear next-action state, reclaim guides, invalidation guides, target-room references, stop-run review zones, expansion review zones, and a clean AGPro planning panel.

It does not predict where price must go next. It does not automate entries or exits. It is built to organize volatile stop-run and expansion contexts so traders can evaluate the event with more structure.


🎯 Purpose & Design Philosophy

This script was built for traders who need a practical decision framework during fast volatility spikes.

Many charts look most confusing exactly when volatility expands: wicks stretch, stops may be triggered, range edges are breached, and the candle can either reclaim or continue. This planner fills that gap by asking whether the spike is showing stop-run characteristics, real expansion behavior, or a cooldown state that still needs confirmation.

The design supports a planning mindset: identify the event, evaluate quality, locate the reclaim level, define invalidation context, estimate target room, and decide what deserves attention next.


⚡ Why This Script Is Different

Most stop-run tools focus on liquidity sweeps, stop-hunt zones, or level raids.

This script does NOT try to become another liquidity grab detector, stop-hunt map, order block map, or generic sweep marker.

Instead, it focuses on the volatility event itself. It evaluates whether a spike around a recent range edge is recovering, rejecting, expanding, or entering a cooldown window. The core output is not a buy or sell signal. It is a planner state that helps the user decide whether the current volatility context deserves review, patience, or no action.


⚙️ Methodology

1. Context Detection
The script measures ATR load, candle range relative to ATR, wick dominance, body efficiency, and recent range-edge interaction.

2. Reference Mapping
It maps the recent high / low reference range, the reclaim level, the spike extreme, the invalidation guide, and the target-room reference.

3. Reaction Evaluation
The model scores stop-run risk, reclaim quality, volatility load, range-edge penetration, and expansion quality. These components are blended into a 0-100 planner score.

4. Visual Output
Qualified events are displayed through stop-run review zones, expansion review zones, reclaim lines, active risk / target guides, optional volatility cooldown boxes, premium labels, alerts, and a compact AGPro panel.


🗺️ How to Read the Chart

Zones = stop-run or expansion review areas created around qualified volatility spike events.

Labels = compact event markers showing the detected context, planner score, score tier, and next-action state.

Colors = bullish reclaim contexts use AGPro teal, bearish reclaim contexts use AGPro pink, and expansion / neutral review contexts use controlled accent tones.

Panel = the panel summarizes Spike State, Planner Score, Stop-Run Risk, Reclaim Quality, Risk / Target, Volatility Load, and Action.


🚦 Signals & States

• Bull Stop-Run → downside spike below the recent range edge followed by reclaim-quality behavior.

• Bear Stop-Run → upside spike above the recent range edge followed by rejection-quality behavior.

• Expansion Up → volatility spike closes cleanly above the recent range edge with stronger body efficiency.

• Expansion Down → volatility spike closes cleanly below the recent range edge with stronger body efficiency.

• Spike Watch → volatility is elevated, but the candle has not yet produced enough reclaim or expansion evidence.

• Normal Load → no qualified volatility event is currently detected.


🔔 Alerts Logic

Alerts trigger when the planner detects a qualified Bull Stop-Run Review, Bear Stop-Run Review, Expansion Up Review, Expansion Down Review, or Spike Watch context.

These alerts are attention markers. They are not trade instructions, entry signals, exit signals, or automated strategy commands.


🧩 Confluence Logic

The strongest planner states appear when multiple conditions align:

ATR spike + wick expansion + range-edge penetration + reclaim quality + clean risk / target context.

When the spike reclaims the reference level with strong wick rejection, the stop-run review context becomes stronger. When the candle closes beyond the range edge with strong body efficiency, the expansion review context becomes stronger.


📊 When to Use

• Around sudden volatility spikes

• Near recent range highs or lows

• During breakout or breakdown attempts

• After large wick candles that need structured interpretation

• When deciding whether a fast move deserves review, patience, or no action


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro-timeframes

• News-driven candles with abnormal gaps

• Markets where ATR is distorted by isolated historical spikes

• Situations where the user expects a simple signal-only entry tool


🎛️ Key Inputs

• Sensitivity → controls how selective the spike and stop-run planner should be.

• Reference Lookback → defines the recent range edge used for spike evaluation.

• ATR Length → normalizes volatility, invalidation, target room, and label spacing.

• Minimum Planner Score → sets the score required before events are drawn.

• Confirmation Mode → controls how strict reclaim or expansion confirmation should be.

• Cooldown Bars → defines the post-spike visual review window.

• Visual settings → control zones, labels, guides, panel theme, panel location, and font sizes.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The panel provides the decision summary. The chart zones show where the volatility event happened. The reclaim line identifies the reference level. The risk / target guides frame the active review context without turning the script into a trade command system.

The visual hierarchy is intentionally compact, premium, and readable.


🧪 Practical Usage Workflow

1. Read the panel to identify the current Spike State and Planner Score.

2. Check whether the chart is showing a stop-run review, expansion review, or spike watch context.

3. Compare the reclaim line with the candle close and wick behavior.

4. Review the invalidation and target-room guides.

5. Interpret the event within broader market structure and volatility conditions.


🔍 Interpretation Guidelines

A high stop-run risk score means the spike has stronger rejection and reclaim characteristics.

A high expansion score means the spike is behaving more like continuation through the range edge.

A cooldown window means the event needs follow-through review rather than immediate interpretation.

No single score should be read in isolation. The strongest use case is to combine the planner state with structure, liquidity, trend, and timeframe context.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto trading system

• Not a guaranteed signal tool

• Not a liquidity grab detector

• Not a stop-hunt zone map

• Not an order block or FVG map


⚠️ Limitations & Transparency

Volatility behavior changes across symbols, sessions, and timeframes.

ATR can expand sharply during news, low-liquidity gaps, or abnormal market conditions.

Some stop-run-looking candles can still continue in the same direction. Some expansion-looking candles can fail quickly. The script provides structured context, not certainty.


🧠 Market Context Notes

Stop-run behavior often appears when price briefly trades through visible reference areas and then reclaims them.

Expansion behavior often appears when price accepts beyond the reference with stronger body efficiency and less rejection.

The planner is designed to help users separate these contexts with a consistent rule-based framework.


🧾 Use Case Examples

When price spikes below a recent low, leaves a large lower wick, and closes back above the reference, the script may classify the event as a Bull Stop-Run Review.

When price expands above a recent high with a strong body close and limited upper rejection, the script may classify the event as Expansion Up.

When volatility spikes but reclaim or expansion evidence is incomplete, the script may show Spike Watch or keep the event in cooldown.


🧱 System Philosophy

Volatility Stop Run Planner follows the AGPro Series decision-engine approach:

Context first.
Risk before reaction.
Reclaim before assumption.
Expansion quality before excitement.
Attention markers instead of promises.


🔐 Non-Promise Statement

No indicator can remove uncertainty.

No state, score, label, alert, line, or zone should be interpreted as guaranteed market direction.


📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own analysis, risk management, and decisions.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

The script is designed to make volatile candles easier to review by separating stop-run behavior, expansion behavior, and cooldown context into a clean visual planning workflow.

## Source Code

````pine
// -----------------------------------------------------
// Volatility Stop Run Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.10
//
// Volatility Stop Run Planner is a chart-first volatility spike and stop-run
// risk planning engine. It studies ATR expansion, wick pressure, reclaim
// quality, range-edge behavior and early follow-through to separate stop-run
// review contexts from cleaner volatility expansion maps. The output is a
// 0-100 planner score, a clear next-action workflow, risk / distance / target
// guides, concept-native zones, a persistent follow-through proof layer and a
// dashboard-style AGPro panel for structured volatility and stop-run review.
// -----------------------------------------------------

//@version=6
indicator("Volatility Stop Run Planner [AGPro Series]",
     shorttitle = "AG Pro VSR",
     overlay = true,
     max_boxes_count = 90,
     max_labels_count = 160,
     max_lines_count = 90)

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
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
dangerColor   = color.rgb(239, 68, 68)
darkText      = color.rgb(17, 24, 39)

// -----------------------------------------------------
// Tooltips
// -----------------------------------------------------
ttSensitivity = "Controls how selective the volatility spike and stop-run planner should be. Aggressive reacts faster, while Conservative requires stronger spike and reclaim evidence."
ttLookback = "Defines the recent high / low reference range used to evaluate whether a volatility spike is occurring around a meaningful range edge."
ttAtr = "Normalizes volatility load, wick size, invalidation distance, target room, right-edge tags, and label spacing."
ttMinScore = "Minimum 0-100 planner score required before a stop-run or expansion context is drawn on the chart."
ttConfirm = "Controls how much reclaim or close-through confirmation is required. Strict mode requires a cleaner close beyond the reference."
ttCooldown = "Number of bars used for the post-spike review window and active visual memory."
ttMaxObjects = "Caps visible historical event zones, lines, and labels to keep the chart readable. Balanced defaults are intentionally selective for publication screenshots."
ttTarget = "Fallback target-room projection used when the opposite range edge is too close to provide a useful reference."
ttMaxTarget = "Caps the projected target room so the target stays a practical distance from price, even when the opposite range edge is far away."
ttInvalid = "ATR buffer added beyond the spike extreme or expansion reference to map a practical invalidation guide."
ttProof = "Number of bars after a qualified planner event within which price must reach the projected target before invalidation to count as a successful follow-through in the proof layer."
ttGuides = "Shows historical active reclaim, invalidation, and target-room guide lines after qualified planner events. Disabled by default for a cleaner publication chart."
ttZones = "Draws concept-native stop-run and expansion review zones for qualified planner events."
ttCooldownBox = "Optionally draws a post-spike cooldown window. Disabled by default because it can clutter compact public screenshots."
ttReclaim = "Draws extra reclaim or expansion reference lines used by the planner. Disabled by default because zones and panel values already carry the main story."
ttLabels = "Shows compact planner labels above or below candles. Labels are ATR-offset to reduce candle overlap."
ttLabelMode = "Controls how much text appears inside event labels. Balanced is the recommended public-release default."
ttLabelDensity = "Controls visual history and detail. Balanced keeps four compact historical zones plus the latest event and active workflow tags for a richer chart story."
ttLabelOffset = "ATR-based vertical offset used to keep event labels away from candle bodies and wicks."
ttProjection = "How far active risk, target, and right-edge tags project to the right."
ttRightTags = "Shows active right-edge tags for workflow, reclaim, invalidation, and target context."
ttLabelFont = "Controls the size of all event labels, right-edge tags, and centered zone text. Normal is the recommended default."
ttPanelShow = "Shows or hides the AGPro planner panel. Enabled by default for public-release clarity."
ttPanelLocation = "Controls where the AGPro planner panel appears on the chart."
ttPanelTheme = "Controls the panel color theme while preserving the AGPro blue merged header row."
ttPanelFont = "Controls the size of panel text. Default is Normal for balanced readability."

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
groupCore = "Core Logic"
sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = groupCore, tooltip = ttSensitivity)
lookback = input.int(34, "Reference Lookback", minval = 12, maxval = 150, group = groupCore, tooltip = ttLookback)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupCore, tooltip = ttAtr)
minScore = input.int(64, "Minimum Planner Score", minval = 35, maxval = 90, group = groupCore, tooltip = ttMinScore)
confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = groupCore, tooltip = ttConfirm)
cooldownBars = input.int(12, "Active Review Window", minval = 3, maxval = 60, group = groupCore, tooltip = ttCooldown)
proofWindow = input.int(20, "Follow-Through Window (Bars)", minval = 5, maxval = 80, group = groupCore, tooltip = ttProof)
maxVisibleObjects = input.int(5, "Max Visible Event Sets", minval = 3, maxval = 20, group = groupCore, tooltip = ttMaxObjects)

groupRisk = "Risk / Target Logic"
targetAtrMult = input.float(1.35, "Target Room ATR Multiple", minval = 0.50, maxval = 4.00, step = 0.05, group = groupRisk, tooltip = ttTarget)
maxTargetAtr = input.float(3.5, "Max Target Room (ATR)", minval = 1.0, maxval = 8.0, step = 0.25, group = groupRisk, tooltip = ttMaxTarget)
invalidAtrBuffer = input.float(0.20, "Invalidation Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.05, group = groupRisk, tooltip = ttInvalid)
showGuides = input.bool(false, "Show Active Risk / Target Guides", group = groupRisk, tooltip = ttGuides)

groupVisual = "Visuals"
showZones = input.bool(true, "Show Stop-Run Zones", group = groupVisual, tooltip = ttZones)
showCooldownWindow = input.bool(false, "Show Cooldown Window Box", group = groupVisual, tooltip = ttCooldownBox)
showReclaimLine = input.bool(false, "Show Reclaim Lines", group = groupVisual, tooltip = ttReclaim)
showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttLabels)
labelMode = input.string("Balanced", "Label Detail", options = ["Compact", "Balanced", "Detailed"], group = groupVisual, tooltip = ttLabelMode)
labelDensity = input.string("Detailed", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = groupVisual, tooltip = ttLabelDensity)
labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = ttLabelOffset)
projectionBars = input.int(34, "Right Projection Bars", minval = 8, maxval = 120, group = groupVisual, tooltip = ttProjection)
showRightEdgeTags = input.bool(true, "Show Right-Edge Tags", group = groupVisual, tooltip = ttRightTags)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = ttLabelFont)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanelShow)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -----------------------------------------------------
// Utility functions
// -----------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_score_text(float value) =>
    str.tostring(math.round(f_clamp(value, 0.0, 100.0))) + "/100"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_size(string selected) =>
    switch selected
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string selected) =>
    switch selected
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_tier(float score) =>
    score >= 78 ? "A" : score >= 66 ? "B" : score >= 54 ? "C" : "D"

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(20, 30, 50) : panelBg)

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_keep_box(array<box> items, box id, int maxCount) =>
    array.push(items, id)
    while array.size(items) > maxCount
        box old = array.shift(items)
        if not na(old)
            box.delete(old)

f_keep_line(array<line> items, line id, int maxCount) =>
    array.push(items, id)
    while array.size(items) > maxCount
        line old = array.shift(items)
        if not na(old)
            line.delete(old)

f_keep_label(array<label> items, label id, int maxCount) =>
    array.push(items, id)
    while array.size(items) > maxCount
        label old = array.shift(items)
        if not na(old)
            label.delete(old)

// -----------------------------------------------------
// Core calculations
// -----------------------------------------------------
atrRaw = ta.atr(atrLen)
atr = math.max(nz(atrRaw, syminfo.mintick), syminfo.mintick)
atrBaseRaw = ta.sma(atr, atrLen * 3)
atrBase = nz(atrBaseRaw, atr)
prevHigh = ta.highest(high[1], lookback)
prevLow = ta.lowest(low[1], lookback)
rangeReady = not na(prevHigh) and not na(prevLow) and atr > 0

candleRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperWickShare = upperWick / candleRange
lowerWickShare = lowerWick / candleRange
bodyShare = body / candleRange
closeRel = (close - low) / candleRange
rangeAtr = candleRange / atr
atrLoad = atrBase > 0 ? atr / atrBase : 1.0

spikeMin = sensitivity == "Aggressive" ? 1.10 : sensitivity == "Conservative" ? 1.55 : 1.30
wickMin = sensitivity == "Aggressive" ? 0.34 : sensitivity == "Conservative" ? 0.48 : 0.40
bodyMin = sensitivity == "Aggressive" ? 0.38 : sensitivity == "Conservative" ? 0.56 : 0.46
loadMin = sensitivity == "Aggressive" ? 48.0 : sensitivity == "Conservative" ? 64.0 : 55.0
reclaimPad = confirmationMode == "Fast" ? -0.04 * atr : confirmationMode == "Strict" ? 0.06 * atr : 0.0
expansionPad = confirmationMode == "Fast" ? 0.0 : confirmationMode == "Strict" ? 0.08 * atr : 0.03 * atr

volatilityLoad = f_clamp((rangeAtr / spikeMin) * 52.0 + (atrLoad - 1.0) * 92.0 + 34.0, 0.0, 100.0)
spikeOK = rangeReady and rangeAtr >= spikeMin and volatilityLoad >= loadMin

lowPenAtr = rangeReady ? math.max(prevLow - low, 0.0) / atr : 0.0
highPenAtr = rangeReady ? math.max(high - prevHigh, 0.0) / atr : 0.0
lowerSweep = rangeReady and low < prevLow and lowPenAtr >= 0.04
upperSweep = rangeReady and high > prevHigh and highPenAtr >= 0.04
lowerReclaim = rangeReady and close >= prevLow + reclaimPad
upperReclaim = rangeReady and close <= prevHigh - reclaimPad

lowerWickScore = f_clamp(lowerWickShare * 170.0, 0.0, 100.0)
upperWickScore = f_clamp(upperWickShare * 170.0, 0.0, 100.0)
lowerReclaimQuality = rangeReady ? f_clamp(40.0 + closeRel * 46.0 + ((close - prevLow) / atr) * 28.0, 0.0, 100.0) : 0.0
upperReclaimQuality = rangeReady ? f_clamp(40.0 + (1.0 - closeRel) * 46.0 + ((prevHigh - close) / atr) * 28.0, 0.0, 100.0) : 0.0
lowerPenQuality = f_clamp(100.0 - math.abs(lowPenAtr - 0.45) * 58.0, 0.0, 100.0)
upperPenQuality = f_clamp(100.0 - math.abs(highPenAtr - 0.45) * 58.0, 0.0, 100.0)

lowerStopScore = f_clamp(volatilityLoad * 0.28 + lowerWickScore * 0.25 + lowerReclaimQuality * 0.26 + lowerPenQuality * 0.13 + (close > open ? 8.0 : 0.0), 0.0, 100.0)
upperStopScore = f_clamp(volatilityLoad * 0.28 + upperWickScore * 0.25 + upperReclaimQuality * 0.26 + upperPenQuality * 0.13 + (close < open ? 8.0 : 0.0), 0.0, 100.0)

emaFast = ta.ema(close, 8)
emaSlow = ta.ema(close, 21)
trendUpScore = emaFast > emaSlow ? 86.0 : 44.0
trendDownScore = emaFast < emaSlow ? 86.0 : 44.0
upBreakQuality = rangeReady ? f_clamp(42.0 + ((close - prevHigh) / atr) * 52.0, 0.0, 100.0) : 0.0
downBreakQuality = rangeReady ? f_clamp(42.0 + ((prevLow - close) / atr) * 52.0, 0.0, 100.0) : 0.0
upExpansionScore = f_clamp(volatilityLoad * 0.30 + f_clamp(bodyShare * 145.0, 0.0, 100.0) * 0.24 + f_clamp(closeRel * 125.0, 0.0, 100.0) * 0.20 + upBreakQuality * 0.16 + trendUpScore * 0.10, 0.0, 100.0)
downExpansionScore = f_clamp(volatilityLoad * 0.30 + f_clamp(bodyShare * 145.0, 0.0, 100.0) * 0.24 + f_clamp((1.0 - closeRel) * 125.0, 0.0, 100.0) * 0.20 + downBreakQuality * 0.16 + trendDownScore * 0.10, 0.0, 100.0)

bullStopCandidate = spikeOK and lowerSweep and lowerReclaim and lowerWickShare >= wickMin
bearStopCandidate = spikeOK and upperSweep and upperReclaim and upperWickShare >= wickMin
upExpansionCandidate = spikeOK and rangeReady and close > prevHigh + expansionPad and closeRel >= 0.62 and bodyShare >= bodyMin
downExpansionCandidate = spikeOK and rangeReady and close < prevLow - expansionPad and closeRel <= 0.38 and bodyShare >= bodyMin

string eventKind = "None"
float eventScore = 0.0
float eventReclaimQuality = 0.0
float eventStopRunRisk = math.max(lowerSweep ? lowerStopScore : 0.0, upperSweep ? upperStopScore : 0.0)
int eventDirection = 0
color eventColor = neutralColor
float reclaimLevel = na
float invalidationLevel = na
float targetLevel = na
float zoneTop = na
float zoneBottom = na

if bullStopCandidate and lowerStopScore > eventScore
    eventKind := "Bull Stop-Run"
    eventScore := lowerStopScore
    eventReclaimQuality := lowerReclaimQuality
    eventDirection := 1
    eventColor := bullColor
    reclaimLevel := prevLow
    invalidationLevel := low - atr * invalidAtrBuffer
    targetLevel := prevHigh > close ? prevHigh : close + atr * targetAtrMult
    zoneTop := prevLow
    zoneBottom := low

if bearStopCandidate and upperStopScore > eventScore
    eventKind := "Bear Stop-Run"
    eventScore := upperStopScore
    eventReclaimQuality := upperReclaimQuality
    eventDirection := -1
    eventColor := bearColor
    reclaimLevel := prevHigh
    invalidationLevel := high + atr * invalidAtrBuffer
    targetLevel := prevLow < close ? prevLow : close - atr * targetAtrMult
    zoneTop := high
    zoneBottom := prevHigh

if upExpansionCandidate and upExpansionScore > eventScore
    eventKind := "Expansion Up"
    eventScore := upExpansionScore
    eventReclaimQuality := upBreakQuality
    eventDirection := 1
    eventColor := accentColor
    reclaimLevel := prevHigh
    invalidationLevel := prevHigh - atr * invalidAtrBuffer
    targetLevel := close + atr * targetAtrMult
    zoneTop := high + atr * 0.20
    zoneBottom := prevHigh

if downExpansionCandidate and downExpansionScore > eventScore
    eventKind := "Expansion Down"
    eventScore := downExpansionScore
    eventReclaimQuality := downBreakQuality
    eventDirection := -1
    eventColor := accentColor
    reclaimLevel := prevLow
    invalidationLevel := prevLow + atr * invalidAtrBuffer
    targetLevel := close - atr * targetAtrMult
    zoneTop := prevLow
    zoneBottom := low - atr * 0.20

// Keep the projected target a practical distance from price
if not na(targetLevel) and eventDirection != 0
    float maxDist = atr * maxTargetAtr
    targetLevel := eventDirection == 1 ? math.min(targetLevel, close + maxDist) : math.max(targetLevel, close - maxDist)

qualifiedEvent = eventKind != "None" and eventScore >= minScore
plannerScore = qualifiedEvent ? eventScore : spikeOK ? volatilityLoad : 0.0
spikeWatch = spikeOK and not qualifiedEvent
watchAction = spikeWatch and (lowerSweep or upperSweep) ? "Wait Reclaim" : spikeWatch ? "Let Spike Settle" : "Standby"
eventAction = eventKind == "Bull Stop-Run" ? "Review Long Reclaim" :
     eventKind == "Bear Stop-Run" ? "Review Short Reclaim" :
     eventKind == "Expansion Up" ? "Track Release Up" :
     eventKind == "Expansion Down" ? "Track Release Down" :
     watchAction

// -----------------------------------------------------
// State memory and visual objects
// -----------------------------------------------------
var array<box> eventBoxes = array.new_box()
var array<box> cooldownBoxes = array.new_box()
var array<line> reclaimLines = array.new_line()
var array<label> eventLabels = array.new_label()

// Follow-through proof layer state
var array<int> proofBar = array.new_int()
var array<int> proofDir = array.new_int()
var array<float> proofTgt = array.new_float()
var array<float> proofInv = array.new_float()
var int proofTotal = 0
var int proofWin = 0

var int lastSignalBar = na
var int activeUntil = na
var float activeReclaim = na
var float activeInvalidation = na
var float activeTarget = na
var float activeScore = na
var float activeReclaimQuality = na
var float activeStopRunRisk = na
var float activeVolatilityLoad = na
var string activeKind = "None"
var string activeAction = "Standby"
var color activeColor = neutralColor

int zoneKeep = labelDensity == "Detailed" ? maxVisibleObjects : labelDensity == "Balanced" ? int(math.min(maxVisibleObjects, 4)) : int(math.min(maxVisibleObjects, 1))
int eventKeep = labelDensity == "Detailed" ? maxVisibleObjects : labelDensity == "Balanced" ? int(math.min(maxVisibleObjects, 1)) : int(math.min(maxVisibleObjects, 1))
int zoneBars = labelDensity == "Detailed" ? projectionBars : labelDensity == "Balanced" ? int(math.min(projectionBars, 18)) : int(math.min(projectionBars, 14))
cooldownReady = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars
newPlannerEvent = barstate.isconfirmed and qualifiedEvent and cooldownReady

if newPlannerEvent
    lastSignalBar := bar_index
    activeUntil := bar_index + cooldownBars
    activeReclaim := reclaimLevel
    activeInvalidation := invalidationLevel
    activeTarget := targetLevel
    activeScore := eventScore
    activeReclaimQuality := eventReclaimQuality
    activeStopRunRisk := eventStopRunRisk
    activeVolatilityLoad := volatilityLoad
    activeKind := eventKind
    activeAction := eventAction
    activeColor := eventColor

    if showZones
        float fixedTop = math.max(zoneTop, zoneBottom)
        float fixedBottom = math.min(zoneTop, zoneBottom)
        string zoneText = "Q " + str.tostring(math.round(eventScore))
        box zone = box.new(left = bar_index, top = fixedTop, right = bar_index + zoneBars, bottom = fixedBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(eventColor, eventKind == "Bull Stop-Run" or eventKind == "Bear Stop-Run" ? 84 : 88),
             border_color = color.new(eventColor, 10),
             border_width = 1,
             text = zoneText,
             text_color = color.new(eventColor, 0),
             text_size = f_size(labelFontSize),
             text_halign = text.align_center,
             text_valign = text.align_center)
        f_keep_box(eventBoxes, zone, zoneKeep)

        if showCooldownWindow
            float windowTop = math.max(high + atr * 0.30, fixedTop)
            float windowBottom = math.min(low - atr * 0.30, fixedBottom)
            box cooldown = box.new(left = bar_index, top = windowTop, right = bar_index + cooldownBars, bottom = windowBottom,
                 xloc = xloc.bar_index,
                 bgcolor = color.new(neutralColor, 94),
                 border_color = color.new(neutralColor, 64),
                 border_width = 1)
            f_keep_box(cooldownBoxes, cooldown, zoneKeep)

    if showReclaimLine and not na(reclaimLevel)
        line reclaim = line.new(x1 = bar_index, y1 = reclaimLevel, x2 = bar_index + zoneBars, y2 = reclaimLevel,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(eventColor, 0),
             style = line.style_dotted,
             width = 2)
        f_keep_line(reclaimLines, reclaim, zoneKeep)

    bool stopRunStory = eventKind == "Bull Stop-Run" or eventKind == "Bear Stop-Run"
    bool printEventLabel = showLabels and (labelDensity == "Detailed" or (labelDensity == "Balanced" and stopRunStory) or (labelDensity == "Minimal" and stopRunStory and eventScore >= 86.0))
    if printEventLabel
        string tierText = f_tier(eventScore)
        string eventShort = eventKind == "Bull Stop-Run" ? "Bull Reclaim" : eventKind == "Bear Stop-Run" ? "Bear Fade" : eventKind == "Expansion Up" ? "Release Up" : eventKind == "Expansion Down" ? "Release Down" : eventKind
        string actionShort = eventKind == "Bull Stop-Run" or eventKind == "Bear Stop-Run" ? "Review Reclaim" : "Track Release"
        string compactText = eventShort + " | Q " + str.tostring(math.round(eventScore))
        string balancedText = eventShort + "\nQ " + str.tostring(math.round(eventScore)) + " | " + tierText
        string detailedText = eventShort + "\nScore " + str.tostring(math.round(eventScore)) + " | " + tierText + "\n" + actionShort + "\nReclaim " + f_price(reclaimLevel) + "\nInvalid " + f_price(invalidationLevel)
        string labelText = labelMode == "Compact" ? compactText : labelMode == "Detailed" ? detailedText : balancedText
        float labelY = eventDirection >= 0 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
        label eventLabel = label.new(x = bar_index, y = labelY, text = labelText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = eventDirection >= 0 ? label.style_label_up : label.style_label_down,
             color = color.new(eventColor, 0),
             textcolor = f_text_on(eventColor),
             size = f_size(labelFontSize),
             textalign = text.align_center)
        f_keep_label(eventLabels, eventLabel, eventKeep)

// Register the event for the follow-through proof layer
if newPlannerEvent
    array.push(proofBar, bar_index)
    array.push(proofDir, eventDirection)
    array.push(proofTgt, targetLevel)
    array.push(proofInv, invalidationLevel)

// Resolve pending proof events (target reached before invalidation)
if barstate.isconfirmed and array.size(proofBar) > 0
    var array<int> proofRemove = array.new_int()
    array.clear(proofRemove)
    for i = 0 to array.size(proofBar) - 1
        pbB = array.get(proofBar, i)
        pdD = array.get(proofDir, i)
        ptT = array.get(proofTgt, i)
        pInv = array.get(proofInv, i)
        el = bar_index - pbB
        bool hitT = na(ptT) ? false : (pdD == 1 ? high >= ptT : low <= ptT)
        bool hitI = na(pInv) ? false : (pdD == 1 ? low <= pInv : high >= pInv)
        if el >= 1 and hitT and hitI
            proofTotal += 1
            array.push(proofRemove, i)
        else if el >= 1 and hitT
            proofTotal += 1
            proofWin += 1
            array.push(proofRemove, i)
        else if el >= 1 and hitI
            proofTotal += 1
            array.push(proofRemove, i)
        else if el >= proofWindow
            proofTotal += 1
            array.push(proofRemove, i)
    while array.size(proofRemove) > 0
        ri = array.pop(proofRemove)
        array.remove(proofBar, ri)
        array.remove(proofDir, ri)
        array.remove(proofTgt, ri)
        array.remove(proofInv, ri)

float followThroughRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na

activeValid = not na(activeUntil) and bar_index <= activeUntil
displayKind = newPlannerEvent ? eventKind : activeValid ? activeKind + " Active" : spikeWatch ? "Spike Watch" : "Normal Load"
displayAction = newPlannerEvent ? eventAction : activeValid ? activeAction : watchAction
displayScore = newPlannerEvent ? eventScore : activeValid ? activeScore : 0.0
displayReclaimQuality = newPlannerEvent ? eventReclaimQuality : activeValid ? activeReclaimQuality : spikeWatch and (lowerSweep or upperSweep) ? math.max(lowerReclaimQuality, upperReclaimQuality) : 0.0
displayStopRisk = newPlannerEvent ? eventStopRunRisk : activeValid ? activeStopRunRisk : eventStopRunRisk
displayVolLoad = newPlannerEvent ? volatilityLoad : activeValid ? activeVolatilityLoad : volatilityLoad
displayColor = newPlannerEvent ? eventColor : activeValid ? activeColor : spikeWatch ? neutralColor : panelValueCol
panelEventContext = newPlannerEvent or activeValid
scoreCellText = panelEventContext ? f_score_text(displayScore) : spikeWatch ? "Watch" : "Waiting"
stopRiskCellText = panelEventContext or lowerSweep or upperSweep ? f_score_text(displayStopRisk) : "Waiting"
reclaimCellText = panelEventContext or (spikeWatch and (lowerSweep or upperSweep)) ? f_score_text(displayReclaimQuality) : "Waiting"
distanceToInvalidAtr = activeValid and not na(activeInvalidation) ? math.abs(close - activeInvalidation) / atr : na
targetRoomAtr = activeValid and not na(activeTarget) ? math.abs(activeTarget - close) / atr : na
distanceText = activeValid ? f_score_text(displayScore) + " / " + str.tostring(distanceToInvalidAtr, "#.##") + " ATR" : spikeWatch ? "Watch / " + str.tostring(displayVolLoad, "#") + " load" : "Waiting"
targetText = activeValid ? str.tostring(targetRoomAtr, "#.##") + " ATR room" : "Waiting"
workflowText = activeValid ? displayAction : spikeWatch ? watchAction : "Standby"
volStateText = displayVolLoad >= 78 ? "Hot Load" : displayVolLoad >= 60 ? "Active Load" : displayVolLoad >= 42 ? "Balanced Load" : "Quiet Load"
riskStateText = activeValid ? (displayStopRisk >= 70 ? "High Review" : displayStopRisk >= 55 ? "Moderate Review" : "Light Review") : spikeWatch ? "Spike Forming" : "No Active Risk"

plot(showGuides and activeValid ? activeReclaim : na, "Active Reclaim", color = color.new(activeColor, 0), linewidth = 2, style = plot.style_linebr)
plot(showGuides and activeValid ? activeInvalidation : na, "Active Invalidation", color = color.new(bearColor, 10), linewidth = 1, style = plot.style_linebr)
plot(showGuides and activeValid ? activeTarget : na, "Active Target Room", color = color.new(bullColor, 10), linewidth = 1, style = plot.style_linebr)

// -----------------------------------------------------
// Right-edge active tags
// -----------------------------------------------------
var label workflowTag = na
var label reclaimTag = na
var label invalidTag = na
var label targetTag = na

if showRightEdgeTags and barstate.islast and (activeValid or spikeWatch)
    int tagX = bar_index + math.min(projectionBars, 8) + 2
    float baseGap = math.max(atr * 0.75, close * 0.004)
    float workflowY = activeValid ? close + (close >= nz(activeReclaim, close) ? baseGap * 1.4 : -baseGap * 1.4) : close + baseGap * 1.3
    string workflowLabel = activeValid ? workflowText + "\n" + f_score_text(displayScore) : "Spike Watch\n" + f_score_text(displayVolLoad)
    if na(workflowTag)
        workflowTag := label.new(tagX, workflowY, workflowLabel, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(displayColor, 0), textcolor = f_text_on(displayColor), size = f_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(workflowTag, tagX, workflowY)
        label.set_text(workflowTag, workflowLabel)
        label.set_color(workflowTag, color.new(displayColor, 0))
        label.set_textcolor(workflowTag, f_text_on(displayColor))
        label.set_size(workflowTag, f_size(labelFontSize))

    if activeValid
        bool showInvalidRightTag = labelDensity == "Detailed" or (labelDensity == "Balanced" and distanceToInvalidAtr <= 0.80)
        bool showTargetRightTag = labelDensity != "Minimal"

        if labelDensity == "Detailed"
            if na(reclaimTag)
                reclaimTag := label.new(tagX - 5, activeReclaim, "Reclaim", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(activeColor, 4), textcolor = f_text_on(activeColor), size = f_size(labelFontSize))
            else
                label.set_xy(reclaimTag, tagX - 5, activeReclaim)
                label.set_text(reclaimTag, "Reclaim")
                label.set_color(reclaimTag, color.new(activeColor, 4))
                label.set_textcolor(reclaimTag, f_text_on(activeColor))
                label.set_size(reclaimTag, f_size(labelFontSize))
        else
            if not na(reclaimTag)
                label.delete(reclaimTag)
                reclaimTag := na

        if showInvalidRightTag and na(invalidTag)
            invalidTag := label.new(tagX + 4, activeInvalidation, "Invalidation\n" + str.tostring(distanceToInvalidAtr, "#.##") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = f_size(labelFontSize), textalign = text.align_center)
        else if showInvalidRightTag
            label.set_xy(invalidTag, tagX + 4, activeInvalidation)
            label.set_text(invalidTag, "Invalidation\n" + str.tostring(distanceToInvalidAtr, "#.##") + " ATR")
            label.set_color(invalidTag, color.new(bearColor, 0))
            label.set_textcolor(invalidTag, f_text_on(bearColor))
            label.set_size(invalidTag, f_size(labelFontSize))
        else
            if not na(invalidTag)
                label.delete(invalidTag)
                invalidTag := na

        if showTargetRightTag and na(targetTag)
            targetTag := label.new(tagX + 7, activeTarget, "Target Room\n" + str.tostring(targetRoomAtr, "#.##") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_size(labelFontSize), textalign = text.align_center)
        else if showTargetRightTag
            label.set_xy(targetTag, tagX + 7, activeTarget)
            label.set_text(targetTag, "Target Room\n" + str.tostring(targetRoomAtr, "#.##") + " ATR")
            label.set_color(targetTag, color.new(accentColor, 0))
            label.set_textcolor(targetTag, f_text_on(accentColor))
            label.set_size(targetTag, f_size(labelFontSize))
        else
            if not na(targetTag)
                label.delete(targetTag)
                targetTag := na
    else
        if not na(reclaimTag)
            label.delete(reclaimTag)
            reclaimTag := na
        if not na(invalidTag)
            label.delete(invalidTag)
            invalidTag := na
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na
else
    if not na(workflowTag)
        label.delete(workflowTag)
        workflowTag := na
    if not na(reclaimTag)
        label.delete(reclaimTag)
        reclaimTag := na
    if not na(invalidTag)
        label.delete(invalidTag)
        invalidTag := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na

// -----------------------------------------------------
// Panel
// -----------------------------------------------------
var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

panelNeedsRebuild = showPanel and (na(panel) or lastPanelLocation != panelLocation or lastPanelTheme != panelTheme)
if panelNeedsRebuild
    if not na(panel)
        table.delete(panel)
    bool isLightPanelInit = panelTheme == "Light"
    panel := table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = f_panel_bg(isLightPanelInit, false), border_color = isLightPanelInit ? color.rgb(203, 213, 225) : panelBorder, border_width = 1, frame_color = isLightPanelInit ? color.rgb(203, 213, 225) : panelBorder, frame_width = 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocation
    lastPanelTheme := panelTheme

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelLocation := ""
    lastPanelTheme := ""

if showPanel and not na(panel) and barstate.islast
    bool lightTheme = panelTheme == "Light"
    color bodyBg = f_panel_bg(lightTheme, false)
    color rowAltBg = f_panel_bg(lightTheme, true)
    color labelCol = f_panel_label(lightTheme)
    color valueCol = f_panel_value(lightTheme)

    string ftTxt = proofTotal > 0 ? str.tostring(math.round(followThroughRate)) + "% (" + str.tostring(proofTotal) + ")" : "Building"
    color ftCol = proofTotal == 0 ? valueCol : followThroughRate >= 55 ? bullColor : followThroughRate >= 40 ? neutralColor : bearColor

    table.set_position(panel, f_panel_pos(panelLocation))
    table.clear(panel, 0, 0, 1, 6)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Volatility Stop Run Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)

    table.cell(panel, 0, 1, "Workflow", text_color = labelCol, bgcolor = bodyBg, text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 1, workflowText, text_color = displayColor, bgcolor = bodyBg, text_size = f_size(panelFontSize), text_halign = text.align_right)

    table.cell(panel, 0, 2, "Volatility State", text_color = labelCol, bgcolor = rowAltBg, text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 2, volStateText + " / " + f_score_text(displayVolLoad), text_color = displayVolLoad >= 78 ? neutralColor : displayVolLoad >= 60 ? accentColor : valueCol, bgcolor = rowAltBg, text_size = f_size(panelFontSize), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Stop-Run State", text_color = labelCol, bgcolor = bodyBg, text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 3, riskStateText + " / " + stopRiskCellText, text_color = displayStopRisk >= 65 ? neutralColor : valueCol, bgcolor = bodyBg, text_size = f_size(panelFontSize), text_halign = text.align_right)

    table.cell(panel, 0, 4, "Risk Distance", text_color = labelCol, bgcolor = rowAltBg, text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 4, distanceText, text_color = activeValid ? displayColor : valueCol, bgcolor = rowAltBg, text_size = f_size(panelFontSize), text_halign = text.align_right)

    table.cell(panel, 0, 5, "Target Room", text_color = labelCol, bgcolor = bodyBg, text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 5, targetText, text_color = activeValid ? accentColor : valueCol, bgcolor = bodyBg, text_size = f_size(panelFontSize), text_halign = text.align_right)

    table.cell(panel, 0, 6, "Follow-Through", text_color = labelCol, bgcolor = rowAltBg, text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 6, ftTxt, text_color = ftCol, bgcolor = rowAltBg, text_size = f_size(panelFontSize), text_halign = text.align_right)

// -----------------------------------------------------
// Alerts
// -----------------------------------------------------
alertcondition(newPlannerEvent and eventKind == "Bull Stop-Run", "Bull Stop-Run Review", "Volatility Stop Run Planner: bullish stop-run review context detected. This is an attention marker, not a trade instruction.")
alertcondition(newPlannerEvent and eventKind == "Bear Stop-Run", "Bear Stop-Run Review", "Volatility Stop Run Planner: bearish stop-run review context detected. This is an attention marker, not a trade instruction.")
alertcondition(newPlannerEvent and eventKind == "Expansion Up", "Expansion Up Review", "Volatility Stop Run Planner: upward volatility expansion context detected. This is an attention marker, not a trade instruction.")
alertcondition(newPlannerEvent and eventKind == "Expansion Down", "Expansion Down Review", "Volatility Stop Run Planner: downward volatility expansion context detected. This is an attention marker, not a trade instruction.")
alertcondition(spikeWatch, "Spike Watch", "Volatility Stop Run Planner: volatility spike detected. Reclaim or expansion confirmation is still incomplete.")

plot(plannerScore, "Planner Score", display = display.data_window)
plot(volatilityLoad, "Volatility Load", display = display.data_window)
plot(displayStopRisk, "Stop-Run Risk", display = display.data_window)
plot(displayReclaimQuality, "Reclaim Quality", display = display.data_window)
````
