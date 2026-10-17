# Volume Climax Detector [AGPro Series]

- url: https://www.tradingview.com/script/bV5x4Wxe-Volume-Climax-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;ba31a453857d44debf787f01761da0df
- version: 4.0

## Description

Volume Climax Detector [AGPro Series]

Volume Climax Detector [AGPro Series] is an advanced volume analytics tool that identifies extreme institutional volume events using a three-filter VSA (Volume Spread Analysis) methodology. Rather than triggering on simple volume multiples, the script combines Volume Z-Score statistics, Spread analysis, and Close Location to isolate genuine climax bars — the kind of exhaustion moves Wyckoff and VSA traders look for at trend tops and bottoms.


🔹 OVERVIEW

Volume alone is a noisy signal. A "high volume bar" on one instrument is a quiet bar on another, and most volume-based indicators either miss real climaxes or fire on every uptick. This script takes a statistical approach: it measures how extreme each bar's volume is relative to its own recent history (Z-Score), confirms the bar structure makes sense (Spread and Close Location), and then classifies the event as a Buying Climax or Selling Climax using trend context — the Wyckoff way.

The result is a small number of high-conviction labels at exactly the places where large participants tend to exhaust themselves: panic buys at tops, panic sells at bottoms, and hidden absorption in between.


🔹 WHAT MAKES IT DIFFERENT

Most volume indicators apply a single threshold (e.g. volume > 2× average) and stop there. This script layers three independent VSA filters, each addressing a different failure mode:

• Volume Z-Score — adapts to the instrument's own volume distribution. A 3σ event on BTC is genuinely rare, regardless of session or timeframe.
• Spread filter — requires the bar's range to exceed its recent average. Eliminates the common false positive of a high-volume bar that barely moved (compression).
• Close Location — requires the close to sit in the upper or lower third of the bar. Separates conviction from indecision.

Beyond detection, two analytics layers set it apart from typical volume tools:

• Reversal Success Tracking — every climax is tracked forward for a configurable window, and the script records whether a meaningful counter-move actually materialised (measured in ATR). The panel shows a live Reversal Rate, so users get honest feedback on how well climaxes have worked on the current symbol and timeframe.
• Magnitude Scoring (1–10) — every climax receives a strength score derived from its Z-Score, making it easy to distinguish routine spikes from truly extreme events (marked with ★).


🔹 METHODOLOGY

1. Volume Statistics
   The script computes a rolling mean and standard deviation of volume over a configurable lookback window (default 50 bars). The Z-Score tells how many standard deviations above the mean the current bar is. A reading of 3.0σ or higher (default threshold) corresponds to the top ~0.27% of bars — statistically rare, not just "above average."

2. Triple Filter Gate
   A bar qualifies as a potential climax only when:
   • Z-Score ≥ threshold (volume anomaly)
   • Bar range ≥ spread multiplier × average range (wide spread)
   • Close is in the upper 33% (strength) or lower 33% (weakness) of the bar range

3. Wyckoff Classification
   • Buying Climax — qualifying bar during an established uptrend. Interpretation: buyers are exhausting themselves; potential topping action.
   • Selling Climax — qualifying bar during an established downtrend. Interpretation: sellers are exhausting themselves; potential basing action.
   • When no clear trend exists, classification falls back to close location plus bar direction so that sideways regimes still produce meaningful signals.

4. Confluence Grouping
   When multiple same-direction climaxes occur close together in time or price, the script collapses them into a single label representing the strongest event in the cluster. This keeps charts readable without losing information — the panel still counts every individual climax.

5. Effort vs Result (optional)
   A companion layer flags high-volume bars with unusually narrow spread — the classic VSA "No Demand" and "No Supply" conditions. These often signal hidden absorption ahead of a reversal and are shown as separate labels.


🔹 SIGNALS & ALERTS

Four built-in alert conditions:
• Buying Climax detected
• Selling Climax detected
• Extreme Climax (Z-Score above the extreme threshold, marked with ★)
• No Demand / No Supply divergence

Each alert payload includes the symbol, Z-Score, and magnitude score, ready for automation or review.


🔹 KEY INPUTS

• Volume Lookback (default 50) — rolling window for statistics.
• Z-Score Threshold (default 3.0σ) — minimum statistical extremity. Lower on intraday, higher for premium signals only.
• Extreme Threshold (default 4.0σ) — above this, climaxes are flagged with a ★.
• Spread and Close filters — each can be toggled independently for flexibility across asset classes.
• Trend EMA Length and Sensitivity — control how the script defines uptrend and downtrend, with an ATR-normalised slope check to avoid misclassifying sideways regimes.
• Reversal Window and Threshold — define what counts as a "successful" reversal for the panel statistic.
• Confluence controls — Time-first (default), Price-first, or Strict mode, plus bar and ATR tolerances.
• Climax Zones (optional, default off) — extends each climax bar's range forward as a reaction zone, similar to S/R.


🔹 HOW TO USE

• Start with defaults on any liquid instrument and timeframe. The script adapts to the local volume distribution automatically.
• On highly volatile intraday timeframes, consider raising the Z-Score Threshold to 3.5σ for fewer, cleaner signals. On slower timeframes, the default works well.
• Treat a ★ Extreme Climax as higher-conviction than a plain climax, and pay attention to the Magnitude Score for fine gradation.
• Use the Reversal Rate panel value as a feedback loop — if it is low on your chosen instrument and timeframe, either adjust thresholds or reconsider the setup.
• Combine with your own structural analysis (support/resistance, HTF trend, market structure) for confirmation. The script identifies the event, not the entry.


🔹 LIMITATIONS & TRANSPARENCY

• This is an indicator, not a strategy. It does not generate buy or sell orders and makes no assumption about position sizing or risk management.
• Climaxes are statistical events. They tend to mark inflection points, but no volume pattern resolves into a reversal every time. The built-in Reversal Rate panel value exists precisely to make this honest — users see the actual hit rate on their own chart.
• The script uses publicly available volume data from the chart's exchange. Volume quality varies by venue; results may differ on symbols with thin or unreliable volume reporting.
• Classification depends on trend context. In strongly sideways regimes, the fallback rules may label climaxes differently than a human analyst would; reviewing the Trend EMA and sensitivity inputs helps here.
• Labels are confirmed on bar close (no repaint). Panel counters and the Current Z-Score value update intrabar for live monitoring.


🔹 RISK DISCLOSURE

Trading involves substantial risk of loss. Past behaviour of any signal or statistic does not guarantee future performance. This script is a research and analysis tool — it is not investment advice, a recommendation, or a solicitation to trade. Users are responsible for their own decisions, risk management, and position sizing.

## Source Code

````pine
// -------------------------------------------------
// Volume Climax Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.2
//
// Detects high-volume climax events and evaluates what happens after the
// event: continuation, exhaustion, or failed follow-through. The script uses
// relative volume, spread quality, close location, trend context, and post-event
// progress to build a 0-100 event score, a failure-risk reading, a clean
// follow-through window, and a clear next-action state for volume reaction
// analysis. Version 2.2 preserves the established visual identity while adding
// an outcome-locked event lifecycle, truthful closed-event memory, and stable
// one-shot alerts for decisive post-climax outcomes.
// -------------------------------------------------

//@version=6
indicator("Volume Climax Detector [AGPro Series]",
     shorttitle = "AG Pro VCD",
     overlay = true,
     max_labels_count = 200,
     max_lines_count = 200,
     max_boxes_count = 100)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpCore = "Core Detection"
sensitivity = input.string("Balanced", "Sensitivity",
     options = ["Aggressive", "Balanced", "Strict"], group = grpCore,
     tooltip = "Controls how selective the climax engine is. Aggressive finds more events; Strict requires stronger relative volume and wider spread.")
lookback = input.int(50, "Volume Lookback", minval = 20, maxval = 300, group = grpCore,
     tooltip = "Rolling window used for relative volume, volume Z-score, and average spread calculations.")
minScore = input.int(68, "Minimum Event Score", minval = 30, maxval = 95, group = grpCore,
     tooltip = "Minimum 0-100 event score required before a climax event can be drawn on the chart.")
confirmationMode = input.string("1 Bar", "Confirmation Mode",
     options = ["Immediate", "1 Bar", "2 Bars"], group = grpCore,
     tooltip = "Controls how long the script waits before classifying the post-climax reaction as continuation, exhaustion, or failed event.")
cooldownBars = input.int(22, "Cooldown Bars", minval = 0, maxval = 100, group = grpCore,
     tooltip = "Minimum bars between visible climax events. This keeps the chart readable and avoids stacked event labels.")
trackingBars = input.int(18, "Follow-Through Window", minval = 8, maxval = 80, group = grpCore,
     tooltip = "Number of bars used to evaluate whether the climax produced continuation, exhaustion, or failure.")
zoneExtendBars = input.int(50, "Reaction Zone Extension", minval = 10, maxval = 200, group = grpCore,
     tooltip = "How far each climax reaction zone extends to the right. The default restores the familiar public Volume Climax zone style.")

grpContext = "Context Model"
trendLen = input.int(50, "Trend EMA Length", minval = 10, maxval = 200, group = grpContext,
     tooltip = "EMA used to judge whether the event is aligned with the local trend context.")
trendSlopeAtr = input.float(0.04, "Trend Slope Filter (ATR)", minval = 0.0, maxval = 0.5, step = 0.01, group = grpContext,
     tooltip = "Minimum EMA slope in ATR terms. Higher values require a clearer trend before awarding trend-context score.")
followAtr = input.float(0.35, "Follow-Through Threshold (ATR)", minval = 0.1, maxval = 2.0, step = 0.05, group = grpContext,
     tooltip = "ATR distance beyond the climax range required to confirm directional follow-through.")
targetAtr = input.float(1.25, "Follow-Through Guide (ATR)", minval = 0.5, maxval = 5.0, step = 0.25, group = grpContext,
     tooltip = "Distance used for the visual follow-through guide. It is a context marker, not a price forecast.")

grpVisual = "Visual Design"
visualPreset = input.string("Publication Clean", "Visual Preset",
     options = ["Publication Clean", "Detailed Review"], group = grpVisual,
     tooltip = "Publication Clean keeps the public screenshot premium and uncluttered. Detailed Review shows more diagnostic state changes.")
showBoxes = input.bool(true, "Show Climax Reaction Zones", group = grpVisual,
     tooltip = "Draws the extended high-low reaction zone from each qualified climax event.")
showClosedWindows = input.bool(true, "Keep Historical Climax Zones", group = grpVisual,
     tooltip = "Keeps completed climax reaction zones visible after the follow-through window closes. Default on preserves the popular public version's zone map look.")
showRails = input.bool(false, "Show Failure Rails", group = grpVisual,
     tooltip = "Draws the event failure rail so the user can see where the climax context is weakening.")
showGuide = input.bool(false, "Show Follow-Through Guide", group = grpVisual,
     tooltip = "Draws a projected guide line that frames the continuation path after a climax event.")
showStateLabels = input.bool(false, "Show State Labels", group = grpVisual,
     tooltip = "Adds compact labels when a climax event shifts into continuation, exhaustion, failed event, or expired state.")
maxVisibleObjects = input.int(10, "Max Visible Objects", minval = 6, maxval = 80, group = grpVisual,
     tooltip = "Caps visible labels, boxes, and guide lines to keep the script responsive on long charts.")
zoneTransparency = input.int(88, "Box Transparency", minval = 75, maxval = 95, group = grpVisual,
     tooltip = "Transparency of the follow-through box. Lower values are stronger; higher values are quieter.")
labelSizeInput = input.string("Normal", "Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual,
     tooltip = "Controls every event and state label size.")

grpPanel = "Info Panel"
showPanel = input.bool(true, "Show Info Panel", group = grpPanel,
     tooltip = "Shows or hides the decision panel. Enabled by default for publication-ready first load.")
panelPos = input.string("Top Right", "Panel Position",
     options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = grpPanel,
     tooltip = "Selects where the info panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme",
     options = ["Dark", "Light"], group = grpPanel,
     tooltip = "Switches the panel between dark and light AGPro styles.")
panelSizeInput = input.string("Normal", "Panel Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Controls the panel text size.")

grpAlerts = "Alerts"
alertReady = input.bool(true, "Alert: READY State", group = grpAlerts,
     tooltip = "Triggers when a qualified climax event reaches a READY action state.")
alertStateShift = input.bool(true, "Alert: Confirmed State Shift", group = grpAlerts,
     tooltip = "Triggers when the active climax changes to continuation, exhaustion, failed event, or expired.")
alertInvalidated = input.bool(true, "Alert: Failed / Invalidated Event", group = grpAlerts,
     tooltip = "Triggers when a climax event loses follow-through and becomes invalidated.")
alertMajorFollow = input.bool(true, "Alert: Major Follow-Through", group = grpAlerts,
     tooltip = "Triggers when the event reaches the projected follow-through guide.")

// -------------------------------------------------
// Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = panelTheme == "Dark" ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)
panelBorder = panelTheme == "Dark" ? color.rgb(51, 65, 85) : color.rgb(203, 213, 225)
panelLabelCol = panelTheme == "Dark" ? color.rgb(148, 163, 184) : color.rgb(71, 85, 105)
panelValueCol = panelTheme == "Dark" ? color.rgb(226, 232, 240) : color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.normal

f_panel_pos(p) =>
    switch p
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_score_color(score) =>
    score >= 75 ? bullColor : score >= 58 ? neutralColor : bearColor

f_grade(score) =>
    score >= 88 ? "A+" : score >= 78 ? "A" : score >= 68 ? "B+" : score >= 58 ? "B" : "C"

f_risk_text(risk) =>
    risk >= 70 ? "High " + str.tostring(risk) + "/100" : risk >= 40 ? "Medium " + str.tostring(risk) + "/100" : "Low " + str.tostring(risk) + "/100"

f_state_color(state) =>
    state == "Continuation" ? bullColor :
     state == "Exhaustion" ? neutralColor :
     state == "Failed Event" ? bearColor :
     state == "Expired" ? color.new(panelLabelCol, 0) :
     state == "Confirming" ? accentColor :
     panelValueCol

f_action_color(action) =>
    action == "READY" ? bullColor :
     action == "MONITOR" ? accentColor :
     action == "WAIT" ? neutralColor :
     action == "INVALIDATED" ? bearColor :
     color.new(panelLabelCol, 0)

f_outcome_short(outcome) =>
    outcome == "Continuation" ? "CONT" :
     outcome == "Exhaustion" ? "EXH" :
     outcome == "Failed Event" ? "FAIL" :
     "UNRES"

f_outcome_badge(outcome) =>
    outcome == "Continuation" ? "CONTINUATION" :
     outcome == "Exhaustion" ? "EXHAUSTION" :
     outcome == "Failed Event" ? "FAILED" :
     "UNRESOLVED"

f_text_on(_bg) =>
    brightness = color.r(_bg) + color.g(_bg) + color.b(_bg)
    brightness >= 360 ? color.rgb(15, 23, 42) : color.white

// Object stores.
var array<label> eventLabels = array.new<label>()
var array<box> eventBoxes = array.new<box>()
var array<line> eventLines = array.new<line>()
var array<label> eventBadges = array.new<label>()

f_push_label(id) =>
    array.push(eventLabels, id)
    while array.size(eventLabels) > maxVisibleObjects
        label oldLabel = array.shift(eventLabels)
        label.delete(oldLabel)

f_push_box(id) =>
    array.push(eventBoxes, id)
    while array.size(eventBoxes) > maxVisibleObjects
        box oldBox = array.shift(eventBoxes)
        box.delete(oldBox)

f_push_badge(id) =>
    array.push(eventBadges, id)
    while array.size(eventBadges) > maxVisibleObjects
        label oldBadge = array.shift(eventBadges)
        label.delete(oldBadge)

f_push_line(id) =>
    array.push(eventLines, id)
    while array.size(eventLines) > maxVisibleObjects * 2
        line oldLine = array.shift(eventLines)
        line.delete(oldLine)

lblSize = f_size(labelSizeInput)
pnlSize = f_size(panelSizeInput)
boxTextSize = lblSize
showDiagnosticStateLabels = showStateLabels and visualPreset == "Detailed Review"
confirmBars = confirmationMode == "Immediate" ? 0 : confirmationMode == "1 Bar" ? 1 : 2

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
atr = ta.atr(14)
atrSafe = math.max(nz(atr, syminfo.mintick), syminfo.mintick)

volMean = ta.sma(volume, lookback)
volStd = ta.stdev(volume, lookback)
zScore = volStd > 0 ? (volume - volMean) / volStd : 0.0
rvol = volMean > 0 ? volume / volMean : 0.0

barRange = high - low
rangeMean = ta.sma(barRange, lookback)
spreadRatio = rangeMean > 0 ? barRange / rangeMean : 0.0
closeLoc = barRange > 0 ? (close - low) / barRange : 0.5
bodyPct = barRange > 0 ? math.abs(close - open) / barRange : 0.0

trendEma = ta.ema(close, trendLen)
emaSlope = trendEma - trendEma[5]
slopeNorm = atrSafe > 0 ? emaSlope / atrSafe : 0.0
trendBull = close > trendEma and slopeNorm > trendSlopeAtr
trendBear = close < trendEma and slopeNorm < -trendSlopeAtr

zThreshold = sensitivity == "Strict" ? 2.8 : sensitivity == "Balanced" ? 2.35 : 1.95
rvolThreshold = sensitivity == "Strict" ? 2.3 : sensitivity == "Balanced" ? 1.85 : 1.55
spreadThreshold = sensitivity == "Strict" ? 1.25 : sensitivity == "Balanced" ? 1.15 : 1.05
closeThreshold = sensitivity == "Strict" ? 0.66 : sensitivity == "Balanced" ? 0.62 : 0.58

isHighClose = closeLoc >= closeThreshold
isLowClose = closeLoc <= 1.0 - closeThreshold
isBullBar = close >= open
isBearBar = close < open
volSpike = zScore >= zThreshold or rvol >= rvolThreshold
wideSpread = spreadRatio >= spreadThreshold
shapeQuality = isHighClose or isLowClose or bodyPct >= 0.55
rawClimax = volSpike and wideSpread and shapeQuality

eventSideRaw = isHighClose ? 1 : isLowClose ? -1 : isBullBar ? 1 : -1
trendScore = eventSideRaw == 1 ? (trendBull ? 14.0 : trendBear ? 4.0 : 8.0) : (trendBear ? 14.0 : trendBull ? 4.0 : 8.0)
closeQuality = eventSideRaw == 1 ? closeLoc : 1.0 - closeLoc
rvolScore = f_clamp(rvol / (rvolThreshold * 2.0) * 24.0, 0.0, 24.0)
spreadScore = f_clamp(spreadRatio / (spreadThreshold * 1.8) * 20.0, 0.0, 20.0)
closeScore = f_clamp(closeQuality * 20.0, 0.0, 20.0)
bodyScore = f_clamp(bodyPct * 12.0, 0.0, 12.0)
baseScore = int(math.round(f_clamp(rvolScore + spreadScore + closeScore + trendScore + bodyScore, 0.0, 90.0)))

// -------------------------------------------------
// Active event state
// -------------------------------------------------
var int lastEventBar = na
var int activeSide = 0
var int activeBar = na
var float activeHigh = na
var float activeLow = na
var float activeClose = na
var float activeAtr = na
var float activeRvol = na
var float activeZ = na
var float activeTarget = na
var int activeBaseScore = 0
var bool activeMadeBreak = false
var bool activeOutcomeLocked = false
var string activeOutcome = "Pending"
var int activeOutcomeScore = na
var box activeBox = na
var label activeBadge = na
var line activeRail = na
var line activeGuide = na
var string lastDrawnState = "No Active Event"

cooldownOk = na(lastEventBar) or bar_index - lastEventBar >= cooldownBars
activeWindowBusy = activeSide != 0 and not na(activeBar) and bar_index - activeBar <= trackingBars
newEvent = barstate.isconfirmed and rawClimax and baseScore >= minScore and cooldownOk and not activeWindowBusy

if newEvent
    // Keep only one rich lifecycle badge: the active or most recently closed window.
    if not na(activeBadge)
        if array.size(eventBadges) > 0
            label removedBadge = array.pop(eventBadges)
            label.delete(removedBadge)
        else
            label.delete(activeBadge)

    activeSide := eventSideRaw
    activeBar := bar_index
    activeHigh := high
    activeLow := low
    activeClose := close
    activeAtr := atrSafe
    activeRvol := rvol
    activeZ := zScore
    activeBaseScore := baseScore
    activeMadeBreak := false
    activeOutcomeLocked := false
    activeOutcome := "Pending"
    activeOutcomeScore := na
    activeTarget := activeSide == 1 ? high + atrSafe * targetAtr : low - atrSafe * targetAtr
    lastEventBar := bar_index
    lastDrawnState := "Confirming"

    eventColor = activeSide == 1 ? bearColor : bullColor
    eventName = activeSide == 1 ? "Buy Climax" : "Sell Climax"
    labelScore = int(math.round(f_clamp(baseScore / 10.0, 1.0, 10.0)))
    starText = baseScore >= 85 ? " *" : ""
    labelY = activeSide == 1 ? high + atrSafe * 0.78 : low - atrSafe * 0.78
    labelStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
    label newLabel = label.new(bar_index, labelY,
         eventName + starText + " " + str.tostring(labelScore) + "/10",
         xloc = xloc.bar_index,
         style = labelStyle,
         color = color.new(eventColor, 0),
         textcolor = headerText,
         size = lblSize)
    f_push_label(newLabel)

    if showBoxes
        box newBox = box.new(left = bar_index, top = high, right = bar_index + zoneExtendBars, bottom = low,
             xloc = xloc.bar_index,
             bgcolor = color.new(eventColor, zoneTransparency),
             border_color = color.new(eventColor, 32),
             border_width = 1,
             text = "",
             text_color = color.new(headerText, 18),
             text_size = boxTextSize,
             text_halign = text.align_center,
             text_valign = text.align_center)
        activeBox := newBox
        f_push_box(newBox)
        zoneMidInit = (high + low) * 0.5
        badgeXInit = math.max(bar_index + 4, bar_index + zoneExtendBars - 4)
        label newBadge = label.new(badgeXInit, zoneMidInit, "CLIMAX WINDOW",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = color.new(eventColor, 0),
             textcolor = f_text_on(eventColor),
             size = boxTextSize)
        activeBadge := newBadge
        f_push_badge(newBadge)
    else
        activeBox := na
        activeBadge := na

    if showRails
        railPrice = activeSide == 1 ? low : high
        line newRail = line.new(bar_index, railPrice, bar_index + trackingBars, railPrice,
             xloc = xloc.bar_index,
             color = color.new(eventColor, 5),
             width = 1,
             style = line.style_dashed)
        activeRail := newRail
        f_push_line(newRail)
    else
        activeRail := na

    if showGuide
        line newGuide = line.new(bar_index, activeTarget, bar_index + trackingBars, activeTarget,
             xloc = xloc.bar_index,
             color = color.new(accentColor, 0),
             width = 1,
             style = line.style_dotted)
        activeGuide := newGuide
        f_push_line(newGuide)
    else
        activeGuide := na

// -------------------------------------------------
// Post-event evaluation
// -------------------------------------------------
hasActive = activeSide != 0 and not na(activeBar)
activeAge = hasActive ? bar_index - activeBar : 0
eventAtr = hasActive ? math.max(activeAtr, syminfo.mintick) : atrSafe
windowOpen = hasActive and activeAge <= trackingBars

if windowOpen and barstate.isconfirmed
    activeMadeBreak := activeMadeBreak or (activeSide == 1 ? high > activeHigh + eventAtr * 0.10 : low < activeLow - eventAtr * 0.10)

continuationProgress = windowOpen ? (activeSide == 1 ? (close - activeClose) / eventAtr : (activeClose - close) / eventAtr) : 0.0
exhaustionProgress = windowOpen ? (activeSide == 1 ? (activeClose - close) / eventAtr : (close - activeClose) / eventAtr) : 0.0
continuationBreak = windowOpen and (activeSide == 1 ? close > activeHigh + eventAtr * followAtr : close < activeLow - eventAtr * followAtr)
exhaustionBreak = windowOpen and (activeSide == 1 ? close < activeLow - eventAtr * followAtr : close > activeHigh + eventAtr * followAtr)
failedEventNow = windowOpen and activeMadeBreak and activeAge > confirmBars and not continuationBreak and (activeSide == 1 ? close < activeHigh : close > activeLow)
expiredEvent = hasActive and activeAge > trackingBars

progressScore = windowOpen ? f_clamp(math.max(continuationProgress, exhaustionProgress) / 1.6 * 25.0, 0.0, 25.0) : 0.0
rawEventScore = int(math.round(f_clamp(activeBaseScore + progressScore, 0.0, 100.0)))

if windowOpen and barstate.isconfirmed and activeAge > confirmBars and not activeOutcomeLocked
    if continuationBreak
        activeOutcome := "Continuation"
        activeOutcomeScore := rawEventScore
        activeOutcomeLocked := true
    else if exhaustionBreak
        activeOutcome := "Exhaustion"
        activeOutcomeScore := rawEventScore
        activeOutcomeLocked := true
    else if failedEventNow
        activeOutcome := "Failed Event"
        activeOutcomeScore := math.min(rawEventScore, 55)
        activeOutcomeLocked := true

if expiredEvent and not activeOutcomeLocked
    activeOutcome := "Unresolved"
    activeOutcomeScore := math.min(rawEventScore, 55)
    activeOutcomeLocked := true

eventScore = activeOutcomeLocked ? nz(activeOutcomeScore, rawEventScore) : rawEventScore

eventRange = hasActive ? math.max(activeHigh - activeLow, syminfo.mintick) : syminfo.mintick
insideRisk = windowOpen ? (activeSide == 1 ? f_clamp((activeHigh - close) / eventRange * 60.0, 0.0, 60.0) : f_clamp((close - activeLow) / eventRange * 60.0, 0.0, 60.0)) : 0.0
ageRisk = windowOpen ? f_clamp(activeAge / math.max(trackingBars, 1) * 25.0, 0.0, 25.0) : 0.0
failureRisk = int(math.round(hasActive ? (expiredEvent ? 0.0 : activeOutcomeLocked ? (activeOutcome == "Failed Event" ? 90.0 : activeOutcome == "Exhaustion" ? 28.0 : activeOutcome == "Continuation" ? 18.0 : 45.0) : f_clamp(insideRisk + ageRisk, 0.0, 100.0)) : 0.0))

string followState = "No Active Event"
if hasActive
    followState := expiredEvent ? "Expired" :
         activeAge <= confirmBars ? "Confirming" :
         activeOutcomeLocked ? activeOutcome :
         "Testing"

string actionState = "WAIT"
if hasActive
    actionState := expiredEvent ? "WAIT" :
         activeOutcomeLocked and activeOutcome == "Failed Event" ? "INVALIDATED" :
         (activeOutcomeLocked and (activeOutcome == "Continuation" or activeOutcome == "Exhaustion") and eventScore >= minScore) ? "READY" :
         failureRisk >= 70 ? "WAIT" :
         "MONITOR"

stateChanged = barstate.isconfirmed and hasActive and followState != lastDrawnState

if stateChanged
    if showDiagnosticStateLabels and followState != "Testing" and followState != "Confirming"
        eventColor = f_state_color(followState)
        stateY = activeSide == 1 ? high + atrSafe * 0.85 : low - atrSafe * 0.85
        stateStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
        label stateLabel = label.new(bar_index, stateY,
             followState + " · " + f_grade(eventScore) + " " + str.tostring(eventScore),
             xloc = xloc.bar_index,
             style = stateStyle,
             color = color.new(eventColor, 0),
             textcolor = followState == "Exhaustion" ? color.rgb(15, 23, 42) : headerText,
             size = lblSize)
        f_push_label(stateLabel)
    lastDrawnState := followState

if hasActive and not na(activeBox)
    closedBadgeText = f_outcome_badge(activeOutcome) + " · " + str.tostring(eventScore)
    cleanBoxText = followState == "Testing" ? "TESTING" : followState == "Failed Event" ? "FAILED" : followState == "Expired" ? closedBadgeText : str.upper(followState)
    detailBoxText = followState == "Expired" ? closedBadgeText + " · " + f_grade(eventScore) : followState == "Testing" ? "TESTING FOLLOW-THROUGH" : str.upper(followState) + " " + str.tostring(eventScore) + "/100"
    hideClosedBox = followState == "Expired" and not showClosedWindows
    boxText = hideClosedBox ? "" : (visualPreset == "Publication Clean" ? cleanBoxText : detailBoxText)
    boxStateColor = followState == "Expired" ? (activeSide == 1 ? bearColor : bullColor) : f_state_color(followState)
    badgeStateColor = followState == "Expired" ? (activeOutcome == "Unresolved" ? accentColor : f_state_color(activeOutcome)) : boxStateColor
    box.set_text(activeBox, "")
    box.set_bgcolor(activeBox, color.new(boxStateColor, hideClosedBox ? 100 : zoneTransparency))
    box.set_border_color(activeBox, color.new(boxStateColor, hideClosedBox ? 100 : 35))
    if not na(activeBadge)
        zoneMidLive = (activeHigh + activeLow) * 0.5
        badgeXLive = followState == "Expired" ? activeBar + int(math.round(zoneExtendBars * 0.5)) : math.max(bar_index + 4, activeBar + zoneExtendBars - 4)
        label.set_xy(activeBadge, badgeXLive, zoneMidLive)
        label.set_text(activeBadge, boxText)
        label.set_size(activeBadge, boxTextSize)
        label.set_style(activeBadge, followState == "Expired" ? label.style_label_center : label.style_label_left)
        label.set_color(activeBadge, hideClosedBox or boxText == "" ? color.new(badgeStateColor, 100) : color.new(badgeStateColor, 0))
        label.set_textcolor(activeBadge, hideClosedBox or boxText == "" ? color.new(headerText, 100) : f_text_on(badgeStateColor))

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = table.new(position.top_right, 2, 6,
     bgcolor = panelBg,
     border_color = panelBorder,
     border_width = 1,
     frame_color = panelBorder,
     frame_width = 1)

f_panel_row(row, key, value, valueColor) =>
    table.cell(infoPanel, 0, row, key,
         bgcolor = panelBg,
         text_color = panelLabelCol,
         text_size = pnlSize,
         text_halign = text.align_left)
    table.cell(infoPanel, 1, row, value,
         bgcolor = panelBg,
         text_color = valueColor,
         text_size = pnlSize,
         text_halign = text.align_right)

if barstate.islast and showPanel
    table.set_position(infoPanel, f_panel_pos(panelPos))
    table.set_bgcolor(infoPanel, panelBg)
    table.set_border_color(infoPanel, panelBorder)
    table.set_frame_color(infoPanel, panelBorder)
    table.clear(infoPanel, 0, 0, 1, 5)

    table.cell(infoPanel, 0, 0, "AG Pro Volume Climax Detector",
         bgcolor = headerBg,
         text_color = headerText,
         text_size = pnlSize,
         text_halign = text.align_center,
         text_valign = text.align_center)
    table.cell(infoPanel, 1, 0, "",
         bgcolor = headerBg,
         text_color = headerText,
         text_size = pnlSize)
    table.merge_cells(infoPanel, 0, 0, 1, 0)

    sideText = not hasActive ? "None" : activeSide == 1 ? "Buy Climax" : "Sell Climax"
    sideColor = not hasActive ? panelValueCol : activeSide == 1 ? bearColor : bullColor
    volumeText = not hasActive ? str.tostring(rvol, "#.00") + "x live" : str.tostring(activeRvol, "#.00") + "x | Z " + str.tostring(activeZ, "#.0")
    followText = not hasActive ? "Waiting" : expiredEvent ? "Closed | " + f_outcome_short(activeOutcome) + " " + str.tostring(eventScore) : followState + " | " + str.tostring(eventScore) + "/100"
    riskText = not hasActive ? "No active event" : expiredEvent ? "No live risk" : f_risk_text(failureRisk)
    actionText = not hasActive ? "WAIT" : expiredEvent ? "WAIT | New Event" : actionState + " | " + str.tostring(eventScore) + "/100"
    volumeColor = hasActive ? (activeRvol >= rvolThreshold ? accentColor : panelValueCol) : (rvol >= rvolThreshold ? accentColor : panelValueCol)
    followColor = expiredEvent ? f_state_color(activeOutcome) : f_state_color(followState)

    f_panel_row(1, "Climax Side", sideText, sideColor)
    f_panel_row(2, "Volume Multiple", volumeText, volumeColor)
    f_panel_row(3, "Follow-Through", followText, followColor)
    f_panel_row(4, "Failure Risk", riskText, failureRisk >= 70 ? bearColor : failureRisk >= 40 ? neutralColor : bullColor)
    f_panel_row(5, "Action", actionText, f_action_color(actionState))

if barstate.islast and not showPanel
    table.clear(infoPanel, 0, 0, 1, 5)

// -------------------------------------------------
// Companion plots
// -------------------------------------------------
plot(rvol, "Relative Volume", color = color.new(accentColor, 100), display = display.data_window)
plot(zScore, "Volume Z-Score", color = color.new(accentColor, 100), display = display.data_window)
plot(eventScore, "Active Event Score", color = color.new(f_score_color(eventScore), 100), display = display.data_window)
plot(failureRisk, "Failure Risk", color = color.new(bearColor, 100), display = display.data_window)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
readySignal = alertReady and barstate.isconfirmed and actionState == "READY" and actionState[1] != "READY"
stateShiftSignal = alertStateShift and stateChanged and (followState == "Continuation" or followState == "Exhaustion" or followState == "Failed Event" or followState == "Expired")
invalidatedSignal = alertInvalidated and barstate.isconfirmed and actionState == "INVALIDATED" and actionState[1] != "INVALIDATED"
majorFollowHit = windowOpen and activeOutcomeLocked and activeOutcome == "Continuation" and (activeSide == 1 ? close >= activeTarget : close <= activeTarget)
majorFollowSignal = alertMajorFollow and barstate.isconfirmed and majorFollowHit and not majorFollowHit[1]

alertcondition(readySignal, "VCD READY State", "Volume Climax Detector [AGPro Series]: READY state confirmed.")
alertcondition(stateShiftSignal, "VCD Confirmed State Shift", "Volume Climax Detector [AGPro Series]: climax state changed after confirmation.")
alertcondition(invalidatedSignal, "VCD Failed or Invalidated Event", "Volume Climax Detector [AGPro Series]: active climax event failed or became invalidated.")
alertcondition(majorFollowSignal, "VCD Major Follow-Through", "Volume Climax Detector [AGPro Series]: price reached the follow-through guide after a climax event.")
````
