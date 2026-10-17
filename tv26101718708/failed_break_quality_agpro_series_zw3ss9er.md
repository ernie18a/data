# Failed Break Quality [AGPro Series]

- url: https://www.tradingview.com/script/zW3Ss9eR-Failed-Break-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;80715622836c446799f1133fbd21c977
- version: 3.0

## Description

Failed Break Quality [AGPro Series]

🔹 OVERVIEW

Failed Break Quality is a reversal-focused structure tool that detects failed breakouts (bull traps and bear traps) around confirmed horizontal support and resistance, then grades each reclaim with a transparent 0-100 quality score. Instead of signaling every price wick through a level, it waits for the full sequence — level confirmation, break below or above, decisive reclaim, rejection candle and follow-through — and only prints a label when the event passes a weighted score threshold.

The goal is to give a single-pane view of where the market trapped participants, how clean the reversal was, and whether the reaction carried any real conviction. All components are plotted on the price chart in an event map style: reclaim pockets, focus bands, connector rails, structure tags and a compact summary panel.

🔷 UNIQUE EDGE

What separates Failed Break Quality from generic support-resistance or bull-trap detectors:

• Five-component weighted score (0-100) — each reclaim is rated on Level Integrity, Break Weakness, Reclaim Speed, Rejection Strength and Follow-Through, with user-adjustable weights. No black-box output.

• Auto timeframe profiles — Intraday, H4 and Swing profiles adapt tolerance, break depth, reclaim window, adverse-move limits and family-reset band automatically so the same inputs behave sensibly across timeframes.

• Reclaim Pockets — the actual zone between the break extreme and the reclaim level is drawn as a shaded rectangle, making it easy to see where the trap formed and where the invalidation sits.

• Focus Bands + Event Rails — the latest bull and bear events are highlighted with a forward-extended focus band at the level and a dashed rail connecting break extreme to reclaim point. Older events fade, so the current structural map stays readable.

• Family lock system — once a level produces a graded signal, it will not re-fire on the same level family until a new family forms beyond the configured reset band, preventing signal stacking on the same structure.

• Auto-clean stale event visuals — focus bands, reclaim pockets and event rails are automatically removed when their anchor level drifts, disappears or ages out, so the chart stays clean across regime shifts.

• This script differs from Break-Retest Quality (continuation after a confirmed breakout) by focusing on the opposite case: breakouts that fail and reverse back through the level.

🔸 METHODOLOGY

1. Level Building — Pivot highs and lows are clustered inside an ATR-scaled tolerance band. A level is confirmed only after reaching the required minimum touches and is retired when it exceeds the maximum age in bars. Each confirmed level carries a family ID so nearby re-confirmations do not create duplicate signals.

2. Failed Break Detection — A break is registered when price penetrates a confirmed level by at least the minimum break depth (ATR-based). The script then monitors the reclaim window (capped in bars) and records the break extreme and outside-closes count.

3. Reclaim Confirmation — A reclaim requires close back across the level plus a small ATR buffer. The bar that reclaims is graded for rejection strength using wick, body and close position.

4. Follow-Through Gate — After reclaim, price must extend at least the follow-through ATR in the favorable direction and must not exceed the maximum adverse ATR against the reclaim. Failing either gate cancels the signal.

5. Quality Score — Five sub-scores are combined with user weights to produce the final 0-100 score. Only reclaims at or above the minimum print threshold produce a labeled signal and a reclaim pocket.

🔶 SIGNALS AND ALERTS

• Bullish Reclaim — printed below the reclaim bar with a teal label showing the quality score. Indicates a failed breakdown of support.

• Bearish Reclaim — printed above the reclaim bar with a pink label showing the quality score. Indicates a failed breakout of resistance.

• Panel States — Bull Trap Watch, Bull Reclaim Pending, Bear Trap Watch, Bear Reclaim Pending, Scanning Levels, Building Levels.

• Alert Conditions — Bullish Reclaim and Bearish Reclaim, suitable for standard TradingView alert creation.

🔹 KEY INPUTS

• Levels — Pivot length, ATR length, level match tolerance (ATR), minimum touches, maximum level age.

• Profiles — Toggle for automatic timeframe calibration.

• Failed Break Logic — Minimum break depth, reclaim window, follow-through bars, reclaim buffer, minimum follow-through, maximum adverse move, re-arm distance, family reset band.

• Score — Minimum score to print and individual weights for Level, Break, Speed, Reject and Follow components.

• Visuals — Toggles for confirmed levels, level zones, inner core bands, structure tags, active-zone emphasis, tag connector rails, zone and core half-widths, signal offset, label and tag sizes.

• Event Map — Reclaim pockets, focus bands, event rails, non-focus fade, auto-clean stale event visuals, stale event max bars, pad and extend settings.

• Panel — Visibility, position (Top Right / Top Left / Bottom Right / Bottom Left) and font size.

🔷 HOW TO USE

• Start on the timeframe where the levels look most respected (H1, H4 or Daily). Auto profiles will adjust internal thresholds automatically.

• Treat every signal as contextual evidence, not as a standalone entry. Higher scores indicate cleaner events — a shallow break, a fast reclaim, a strong rejection bar and a clean follow-through all lift the score.

• Use the reclaim pocket as the structural zone: the level marks the invalidation side, and the break extreme marks the maximum trap depth. Both are visible on the chart.

• Combine with your own bias, trend filters, higher-timeframe levels, volume or session structure. The script is designed to sit on top of an existing framework, not replace it.

🔸 LIMITATIONS AND TRANSPARENCY

• This is an indicator, not a strategy. It does not place orders, size positions or calculate profit and loss.

• Signals are evaluated on bar close. Intrabar wicks can temporarily enter trap states without producing a graded event.

• Score thresholds and weights are tunable. Different markets and timeframes benefit from different configurations — the default values are a reasonable starting point, not a universal setting.

• All level, reclaim and pocket logic is purely structural and does not include volume, order flow or derivatives data.

• Repainting note — level confirmation uses pivots with a fixed lookback. The last pivot is locked once the required forward bars have elapsed; earlier plotted structure does not repaint after that point.

🔶 RISK DISCLOSURE

Trading involves substantial risk. This script is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice, investment recommendations or a solicitation to trade. Past performance does not guarantee future results. Always do your own research and apply strict risk management. The author assumes no responsibility for trading decisions made using this script.

Published under Mozilla Public License 2.0 — source is open and available for study, review and non-commercial derivative work under the terms of the license.

## Source Code

````pine
// -----------------------------------------------------
// Failed Break Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.9
//
// Detects failed breaks and reclaims around confirmed horizontal support and
// resistance. Bull traps and bear traps are graded with a transparent quality
// score built from level integrity, break weakness, reclaim speed, rejection
// strength, and follow-through. The planner maps reclaim pockets, focus bands,
// event rails, confirmed zones, a measured-move target, an invalidation edge, a
// clear next action, a stop-aware follow-through proof rate, and a compact AGPro
// summary panel.
// -----------------------------------------------------

//@version=6
indicator("Failed Break Quality [AGPro Series]",
     shorttitle = "AG Pro FBQ",
     overlay = true,
     max_labels_count = 450,
     max_lines_count = 140,
     max_boxes_count = 60)

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
groupLevels = "Levels"
groupProfiles = "Profiles"
groupLogic = "Failed Break Logic"
groupScore = "Score"
groupVisuals = "Visuals"
groupEventMap = "Event Map"
groupPanel = "Panel"

pivotLenBase = input.int(4, "Base Pivot Length", minval = 2, maxval = 20, group = groupLevels)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupLevels)
levelTolATRBase = input.float(0.20, "Base Level Match Tolerance (ATR)", minval = 0.05, maxval = 1.0, step = 0.01, group = groupLevels)
minTouchesBase = input.int(2, "Base Minimum Touches", minval = 2, maxval = 5, group = groupLevels)
maxLevelAgeBase = input.int(220, "Base Maximum Level Age (Bars)", minval = 50, maxval = 1000, group = groupLevels)

useAutoProfiles = input.bool(true, "Use Auto Profiles", group = groupProfiles,
     tooltip = "Automatically adjusts sensitivity for intraday, H4, and swing profiles.")

minBreakATRBase = input.float(0.08, "Base Minimum Break Depth (ATR)", minval = 0.02, maxval = 1.0, step = 0.01, group = groupLogic)
reclaimBarsBase = input.int(6, "Base Maximum Bars Allowed For Reclaim", minval = 1, maxval = 30, group = groupLogic)
followBarsBase = input.int(1, "Base Follow-Through Bars", minval = 0, maxval = 20, group = groupLogic)
reclaimBufferATRBase = input.float(0.01, "Base Reclaim Buffer (ATR)", minval = 0.0, maxval = 0.5, step = 0.01, group = groupLogic)
followThroughATRBase = input.float(0.05, "Base Minimum Follow-Through (ATR)", minval = 0.0, maxval = 1.0, step = 0.01, group = groupLogic)
maxAdverseATRBase = input.float(0.45, "Base Maximum Adverse Move (ATR)", minval = 0.05, maxval = 2.0, step = 0.01, group = groupLogic)
rearmDistanceATRBase = input.float(1.35, "Base Re-arm Distance (ATR)", minval = 0.10, maxval = 5.0, step = 0.05, group = groupLogic)
familyResetATRBase = input.float(0.55, "Base Family Reset Band (ATR)", minval = 0.05, maxval = 3.0, step = 0.05, group = groupLogic)

minScoreToPrintBase = input.int(62, "Base Minimum Score To Print", minval = 0, maxval = 100, group = groupScore)
weightLevel = input.float(0.20, "Weight - Level Integrity", minval = 0.0, maxval = 1.0, step = 0.05, group = groupScore)
weightBreak = input.float(0.20, "Weight - Break Weakness", minval = 0.0, maxval = 1.0, step = 0.05, group = groupScore)
weightSpeed = input.float(0.20, "Weight - Reclaim Speed", minval = 0.0, maxval = 1.0, step = 0.05, group = groupScore)
weightReject = input.float(0.20, "Weight - Rejection Strength", minval = 0.0, maxval = 1.0, step = 0.05, group = groupScore)
weightFollow = input.float(0.20, "Weight - Follow-Through", minval = 0.0, maxval = 1.0, step = 0.05, group = groupScore)
targetRMultiple = input.float(1.5, "Target Projection R Multiple", minval = 0.5, maxval = 6.0, step = 0.1, group = groupScore,
     tooltip = "Projects the measured-move target from the reclaimed level using the trap depth as 1R. The on-chart and panel target is informational, not a trade instruction.")

showSupportResistance = input.bool(true, "Show Confirmed Levels", group = groupVisuals)
showLevelZones = input.bool(true, "Show Level Zones", group = groupVisuals)
showLevelCore = input.bool(true, "Show Inner Core Bands", group = groupVisuals)
showStructureTags = input.bool(false, "Show Structure Tags", group = groupVisuals)
showCenteredZoneBadges = input.bool(true, "Show Centered Zone Badges", group = groupVisuals,
     tooltip = "Adds separate centered badges inside confirmed support and resistance zones.")
showActiveZoneEmphasis = input.bool(true, "Emphasize Nearest Zone", group = groupVisuals)
showTagConnectorRails = input.bool(true, "Show Tag Connector Rails", group = groupVisuals)
showDebugMarkers = input.bool(false, "Show Debug Markers", group = groupVisuals)
labelSizeInput = input.string("Normal", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisuals)
structureTagSizeInput = input.string("Normal", "Structure Tag Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisuals)
structureTagBarsForward = input.int(8, "Structure Tag Bars Forward", minval = 1, maxval = 20, group = groupVisuals)
zoneHalfWidthATR = input.float(0.16, "Zone Half-Width (ATR)", minval = 0.02, maxval = 1.00, step = 0.01, group = groupVisuals)
coreHalfWidthATR = input.float(0.05, "Core Half-Width (ATR)", minval = 0.01, maxval = 0.50, step = 0.01, group = groupVisuals)
signalOffsetATR = input.float(0.16, "Signal Label Offset (ATR)", minval = 0.01, maxval = 2.0, step = 0.01, group = groupVisuals)

showReclaimPockets = input.bool(true, "Show Reclaim Pockets", group = groupEventMap)
showPocketBadges = input.bool(true, "Show Pocket Badges", group = groupEventMap,
     tooltip = "Adds a separate centered badge inside the latest reclaim pocket.")
reclaimPocketExtendBars = input.int(30, "Pocket Extend Bars", minval = 4, maxval = 80, group = groupEventMap)
reclaimPocketPadATR = input.float(0.09, "Pocket Pad (ATR)", minval = 0.00, maxval = 0.50, step = 0.01, group = groupEventMap)
showFocusBands = input.bool(true, "Show Latest Focus Bands", group = groupEventMap)
focusBandExtendBars = input.int(38, "Focus Band Extend Bars", minval = 6, maxval = 120, group = groupEventMap)
focusBandPadATR = input.float(0.05, "Focus Band Pad (ATR)", minval = 0.00, maxval = 0.50, step = 0.01, group = groupEventMap)
showEventRails = input.bool(true, "Show Event Rails", group = groupEventMap)
fadeNonFocusEvents = input.bool(true, "Fade Non-Focus Events", group = groupEventMap)
autoCleanStaleEvents = input.bool(true, "Auto-Clean Stale Event Visuals", group = groupEventMap,
     tooltip = "Removes focus bands, pockets, and rails whose reference level is no longer confirmed or has drifted away.")
staleEventMaxBars = input.int(60, "Stale Event Max Bars", minval = 10, maxval = 400, group = groupEventMap)

showPanel = input.bool(true, "Show Summary Panel", group = groupPanel)
panelPositionInput = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Center", "Bottom Right", "Bottom Center", "Bottom Left"],
     group = groupPanel)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_panel_pos(string pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Top Center" ? position.top_center :
     pos == "Middle Right" ? position.middle_right :
     pos == "Middle Center" ? position.middle_center :
     pos == "Bottom Right" ? position.bottom_right :
     pos == "Bottom Center" ? position.bottom_center :
     pos == "Bottom Left" ? position.bottom_left : position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_label_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(22, 32, 56)

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_line_color(bool isSupport, bool isActive) =>
    isSupport ? color.new(bullColor, isActive ? 0 : 28) : color.new(bearColor, isActive ? 0 : 28)

f_zone_fill(bool isSupport, bool isActive) =>
    isSupport ? color.new(bullColor, isActive ? 78 : 92) : color.new(bearColor, isActive ? 78 : 92)

f_core_fill(bool isSupport, bool isActive) =>
    isSupport ? color.new(bullColor, isActive ? 62 : 85) : color.new(bearColor, isActive ? 62 : 85)

f_signal_bg(bool isBullish) =>
    isBullish ? bullColor : bearColor

f_structure_bg(bool isSupport, bool isActive) =>
    isSupport ? color.new(bullColor, isActive ? 0 : 28) : color.new(bearColor, isActive ? 0 : 28)

f_rail_color(bool isSupport, bool isActive) =>
    isSupport ? color.new(bullColor, isActive ? 0 : 45) : color.new(bearColor, isActive ? 0 : 45)

f_reject_score_bull(float o, float h, float l, float c) =>
    rng = math.max(h - l, syminfo.mintick)
    lowerWick = math.max(math.min(o, c) - l, 0.0)
    closePos = (c - l) / rng
    body = math.abs(c - o) / rng
    f_clamp((lowerWick / rng) * 45.0 + closePos * 35.0 + body * 20.0, 0.0, 100.0)

f_reject_score_bear(float o, float h, float l, float c) =>
    rng = math.max(h - l, syminfo.mintick)
    upperWick = math.max(h - math.max(o, c), 0.0)
    closePos = (h - c) / rng
    body = math.abs(c - o) / rng
    f_clamp((upperWick / rng) * 45.0 + closePos * 35.0 + body * 20.0, 0.0, 100.0)

f_final_score(float s1, float s2, float s3, float s4, float s5, float w1, float w2, float w3, float w4, float w5) =>
    sumW = w1 + w2 + w3 + w4 + w5
    sumW <= 0 ? 0.0 : (s1 * w1 + s2 * w2 + s3 * w3 + s4 * w4 + s5 * w5) / sumW

f_event_fill(bool isBullish, bool isFocus) =>
    isBullish ? color.new(bullColor, isFocus ? 82 : 97) : color.new(bearColor, isFocus ? 82 : 97)

f_event_border(bool isBullish, bool isFocus) =>
    isBullish ? color.new(bullColor, isFocus ? 5 : 88) : color.new(bearColor, isFocus ? 5 : 88)

f_focus_fill(bool isBullish, bool isFocus) =>
    isBullish ? color.new(bullColor, isFocus ? 84 : 98) : color.new(bearColor, isFocus ? 84 : 98)

f_focus_border(bool isBullish, bool isFocus) =>
    isBullish ? color.new(bullColor, isFocus ? 0 : 90) : color.new(bearColor, isFocus ? 0 : 90)

f_event_rail(bool isBullish, bool isFocus) =>
    isBullish ? color.new(bullColor, isFocus ? 0 : 88) : color.new(bearColor, isFocus ? 0 : 88)

f_fmt_price(float v) =>
    na(v) ? "-" : str.tostring(v, format.mintick)

f_fmt_score(float v) =>
    na(v) ? "-" : str.tostring(math.round(v))

// -----------------------------------------------------
// Profile logic
// -----------------------------------------------------
tfMinutes = timeframe.isintraday ? timeframe.multiplier : timeframe.isdaily ? 1440 : timeframe.isweekly ? 10080 : timeframe.ismonthly ? 43200 : 60
isHourlyProfile = tfMinutes <= 90
isH4Profile = tfMinutes > 90 and tfMinutes <= 240
isSwingProfile = tfMinutes > 240

tolMult = useAutoProfiles ? (isHourlyProfile ? 1.08 : isH4Profile ? 1.00 : 1.45) : 1.00
breakMult = useAutoProfiles ? (isHourlyProfile ? 0.88 : isH4Profile ? 1.00 : 1.50) : 1.00
reclaimMult = useAutoProfiles ? (isHourlyProfile ? 1.25 : isH4Profile ? 1.00 : 2.00) : 1.00
followBarsEff = useAutoProfiles ? (isSwingProfile ? math.max(followBarsBase, 2) : followBarsBase) : followBarsBase
bufferMult = useAutoProfiles ? (isHourlyProfile ? 0.82 : isH4Profile ? 1.00 : 1.35) : 1.00
followMult = useAutoProfiles ? (isHourlyProfile ? 0.82 : isH4Profile ? 1.00 : 1.35) : 1.00
adverseMult = useAutoProfiles ? (isHourlyProfile ? 1.12 : isH4Profile ? 1.00 : 1.25) : 1.00
rearmMult = useAutoProfiles ? (isHourlyProfile ? 1.00 : isH4Profile ? 1.00 : 1.45) : 1.00
familyMult = useAutoProfiles ? (isHourlyProfile ? 1.30 : isH4Profile ? 1.00 : 1.45) : 1.00
scoreAdj = useAutoProfiles ? (isHourlyProfile ? -3 : isH4Profile ? 0 : -1) : 0

pivotLen = pivotLenBase
minTouchesEff = minTouchesBase
maxLevelAgeEff = int(math.max(50.0, math.round(maxLevelAgeBase * (useAutoProfiles ? (isSwingProfile ? 1.30 : 1.00) : 1.00))))
levelTolATR = levelTolATRBase * tolMult
minBreakATR = minBreakATRBase * breakMult
reclaimBars = int(math.max(1.0, math.round(reclaimBarsBase * reclaimMult)))
followBars = followBarsEff
reclaimBufferATR = reclaimBufferATRBase * bufferMult
followThroughATR = followThroughATRBase * followMult
maxAdverseATR = maxAdverseATRBase * adverseMult
rearmDistanceATR = rearmDistanceATRBase * rearmMult
familyResetATR = familyResetATRBase * familyMult
minScoreToPrint = minScoreToPrintBase + scoreAdj

// -----------------------------------------------------
// Core series
// -----------------------------------------------------
atr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
levelTol = atr * levelTolATR
breakDepth = atr * minBreakATR
reclaimBuffer = atr * reclaimBufferATR
followReq = atr * followThroughATR
maxAdverseATRValue = maxAdverseATR
familyResetBand = atr * familyResetATR
sigOffset = atr * signalOffsetATR
lblSize = f_size(labelSizeInput)
structureTagSize = f_size(structureTagSizeInput)
zoneHalfWidth = math.max(levelTol * 0.60, atr * zoneHalfWidthATR)
coreHalfWidth = math.min(zoneHalfWidth * 0.60, math.max(levelTol * 0.18, atr * coreHalfWidthATR))

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

// -----------------------------------------------------
// Level building - support
// -----------------------------------------------------
var float supportCandidatePrice = na
var int supportCandidateTouches = 0
var int supportCandidateLastBar = na
var float confirmedSupport = na
var int confirmedSupportTouches = 0
var int confirmedSupportBar = na
var int supportFamilyId = 0

if not na(pl)
    pivotBar = bar_index - pivotLen
    pivotPrice = pl
    if na(supportCandidatePrice) or na(supportCandidateLastBar) or pivotBar - supportCandidateLastBar > maxLevelAgeEff
        supportCandidatePrice := pivotPrice
        supportCandidateTouches := 1
        supportCandidateLastBar := pivotBar
    else if math.abs(pivotPrice - supportCandidatePrice) <= levelTol
        supportCandidatePrice := (supportCandidatePrice * supportCandidateTouches + pivotPrice) / (supportCandidateTouches + 1)
        supportCandidateTouches += 1
        supportCandidateLastBar := pivotBar
    else
        supportCandidatePrice := pivotPrice
        supportCandidateTouches := 1
        supportCandidateLastBar := pivotBar

    if supportCandidateTouches >= minTouchesEff
        isNewFamily = na(confirmedSupport) or math.abs(supportCandidatePrice - confirmedSupport) > familyResetBand
        confirmedSupport := supportCandidatePrice
        confirmedSupportTouches := supportCandidateTouches
        confirmedSupportBar := supportCandidateLastBar
        if isNewFamily
            supportFamilyId += 1

if not na(confirmedSupportBar) and bar_index - confirmedSupportBar > maxLevelAgeEff
    confirmedSupport := na
    confirmedSupportTouches := 0
    confirmedSupportBar := na

// -----------------------------------------------------
// Level building - resistance
// -----------------------------------------------------
var float resistanceCandidatePrice = na
var int resistanceCandidateTouches = 0
var int resistanceCandidateLastBar = na
var float confirmedResistance = na
var int confirmedResistanceTouches = 0
var int confirmedResistanceBar = na
var int resistanceFamilyId = 0

if not na(ph)
    pivotBar = bar_index - pivotLen
    pivotPrice = ph
    if na(resistanceCandidatePrice) or na(resistanceCandidateLastBar) or pivotBar - resistanceCandidateLastBar > maxLevelAgeEff
        resistanceCandidatePrice := pivotPrice
        resistanceCandidateTouches := 1
        resistanceCandidateLastBar := pivotBar
    else if math.abs(pivotPrice - resistanceCandidatePrice) <= levelTol
        resistanceCandidatePrice := (resistanceCandidatePrice * resistanceCandidateTouches + pivotPrice) / (resistanceCandidateTouches + 1)
        resistanceCandidateTouches += 1
        resistanceCandidateLastBar := pivotBar
    else
        resistanceCandidatePrice := pivotPrice
        resistanceCandidateTouches := 1
        resistanceCandidateLastBar := pivotBar

    if resistanceCandidateTouches >= minTouchesEff
        isNewFamily = na(confirmedResistance) or math.abs(resistanceCandidatePrice - confirmedResistance) > familyResetBand
        confirmedResistance := resistanceCandidatePrice
        confirmedResistanceTouches := resistanceCandidateTouches
        confirmedResistanceBar := resistanceCandidateLastBar
        if isNewFamily
            resistanceFamilyId += 1

if not na(confirmedResistanceBar) and bar_index - confirmedResistanceBar > maxLevelAgeEff
    confirmedResistance := na
    confirmedResistanceTouches := 0
    confirmedResistanceBar := na

// -----------------------------------------------------
// Level visuals
// -----------------------------------------------------
var line supportLine = na
var line resistanceLine = na
var line supportRail = na
var line resistanceRail = na
var label supportTag = na
var label resistanceTag = na
var label supportZoneBadge = na
var label resistanceZoneBadge = na

supportDist = not na(confirmedSupport) ? math.abs(close - confirmedSupport) : na
resistanceDist = not na(confirmedResistance) ? math.abs(close - confirmedResistance) : na
supportHighlight = not showActiveZoneEmphasis or (not na(confirmedSupport) and (na(confirmedResistance) or supportDist <= resistanceDist))
resistanceHighlight = not showActiveZoneEmphasis or (not na(confirmedResistance) and (na(confirmedSupport) or resistanceDist < supportDist))

if showSupportResistance
    if not na(confirmedSupport)
        if na(supportLine)
            supportLine := line.new(confirmedSupportBar, confirmedSupport, bar_index + 2, confirmedSupport, extend = extend.right, color = f_line_color(true, supportHighlight), width = supportHighlight ? 3 : 1)
        else
            line.set_xy1(supportLine, confirmedSupportBar, confirmedSupport)
            line.set_xy2(supportLine, bar_index + 2, confirmedSupport)
            line.set_extend(supportLine, extend.right)
            line.set_width(supportLine, supportHighlight ? 3 : 1)
            line.set_color(supportLine, f_line_color(true, supportHighlight))
    else if not na(supportLine)
        line.delete(supportLine)
        supportLine := na

    if not na(confirmedResistance)
        if na(resistanceLine)
            resistanceLine := line.new(confirmedResistanceBar, confirmedResistance, bar_index + 2, confirmedResistance, extend = extend.right, color = f_line_color(false, resistanceHighlight), width = resistanceHighlight ? 3 : 1)
        else
            line.set_xy1(resistanceLine, confirmedResistanceBar, confirmedResistance)
            line.set_xy2(resistanceLine, bar_index + 2, confirmedResistance)
            line.set_extend(resistanceLine, extend.right)
            line.set_width(resistanceLine, resistanceHighlight ? 3 : 1)
            line.set_color(resistanceLine, f_line_color(false, resistanceHighlight))
    else if not na(resistanceLine)
        line.delete(resistanceLine)
        resistanceLine := na
else
    if not na(supportLine)
        line.delete(supportLine)
        supportLine := na
    if not na(resistanceLine)
        line.delete(resistanceLine)
        resistanceLine := na

supportZoneTop = showLevelZones and not na(confirmedSupport) ? confirmedSupport + zoneHalfWidth : na
supportZoneBot = showLevelZones and not na(confirmedSupport) ? confirmedSupport - zoneHalfWidth : na
resZoneTop = showLevelZones and not na(confirmedResistance) ? confirmedResistance + zoneHalfWidth : na
resZoneBot = showLevelZones and not na(confirmedResistance) ? confirmedResistance - zoneHalfWidth : na
supportCoreTop = showLevelZones and showLevelCore and not na(confirmedSupport) ? confirmedSupport + coreHalfWidth : na
supportCoreBot = showLevelZones and showLevelCore and not na(confirmedSupport) ? confirmedSupport - coreHalfWidth : na
resCoreTop = showLevelZones and showLevelCore and not na(confirmedResistance) ? confirmedResistance + coreHalfWidth : na
resCoreBot = showLevelZones and showLevelCore and not na(confirmedResistance) ? confirmedResistance - coreHalfWidth : na

pSupTop = plot(supportZoneTop, color = color.new(bullColor, 100))
pSupBot = plot(supportZoneBot, color = color.new(bullColor, 100))
fill(pSupTop, pSupBot, color = showLevelZones ? f_zone_fill(true, supportHighlight) : color.new(bullColor, 100))
pResTop = plot(resZoneTop, color = color.new(bearColor, 100))
pResBot = plot(resZoneBot, color = color.new(bearColor, 100))
fill(pResTop, pResBot, color = showLevelZones ? f_zone_fill(false, resistanceHighlight) : color.new(bearColor, 100))
pSupCoreTop = plot(supportCoreTop, color = color.new(bullColor, 100))
pSupCoreBot = plot(supportCoreBot, color = color.new(bullColor, 100))
fill(pSupCoreTop, pSupCoreBot, color = showLevelZones and showLevelCore ? f_core_fill(true, supportHighlight) : color.new(bullColor, 100))
pResCoreTop = plot(resCoreTop, color = color.new(bearColor, 100))
pResCoreBot = plot(resCoreBot, color = color.new(bearColor, 100))
fill(pResCoreTop, pResCoreBot, color = showLevelZones and showLevelCore ? f_core_fill(false, resistanceHighlight) : color.new(bearColor, 100))

zonesClose = not na(confirmedSupport) and not na(confirmedResistance) and math.abs(confirmedResistance - confirmedSupport) <= atr * 1.10

if showStructureTags
    railForward = int(math.max(structureTagBarsForward - 1, 1))
    if showTagConnectorRails and not na(confirmedSupport)
        if na(supportRail)
            supportRail := line.new(bar_index + 1, confirmedSupport, bar_index + railForward, confirmedSupport, xloc = xloc.bar_index, extend = extend.none, color = f_rail_color(true, supportHighlight), width = supportHighlight ? 3 : 1)
        else
            line.set_xy1(supportRail, bar_index + 1, confirmedSupport)
            line.set_xy2(supportRail, bar_index + railForward, confirmedSupport)
            line.set_width(supportRail, supportHighlight ? 3 : 1)
            line.set_color(supportRail, f_rail_color(true, supportHighlight))
    else if not na(supportRail)
        line.delete(supportRail)
        supportRail := na

    if showTagConnectorRails and not na(confirmedResistance)
        if na(resistanceRail)
            resistanceRail := line.new(bar_index + 1, confirmedResistance, bar_index + railForward, confirmedResistance, xloc = xloc.bar_index, extend = extend.none, color = f_rail_color(false, resistanceHighlight), width = resistanceHighlight ? 3 : 1)
        else
            line.set_xy1(resistanceRail, bar_index + 1, confirmedResistance)
            line.set_xy2(resistanceRail, bar_index + railForward, confirmedResistance)
            line.set_width(resistanceRail, resistanceHighlight ? 3 : 1)
            line.set_color(resistanceRail, f_rail_color(false, resistanceHighlight))
    else if not na(resistanceRail)
        line.delete(resistanceRail)
        resistanceRail := na

    if not na(confirmedSupport)
        supportTagY = confirmedSupport + (zonesClose ? math.max(zoneHalfWidth * 1.10, atr * 0.45) : math.max(zoneHalfWidth * 0.55, atr * 0.22))
        if na(supportTag)
            supportTag := label.new(bar_index + structureTagBarsForward, supportTagY, "Support Zone", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = f_structure_bg(true, supportHighlight), textcolor = f_text_on(f_structure_bg(true, supportHighlight)), size = structureTagSize)
        else
            label.set_xy(supportTag, bar_index + structureTagBarsForward, supportTagY)
            label.set_text(supportTag, "Support Zone")
            label.set_color(supportTag, f_structure_bg(true, supportHighlight))
            label.set_textcolor(supportTag, f_text_on(f_structure_bg(true, supportHighlight)))
            label.set_size(supportTag, structureTagSize)
    else if not na(supportTag)
        label.delete(supportTag)
        supportTag := na

    if not na(confirmedResistance)
        resistanceTagY = confirmedResistance - (zonesClose ? math.max(zoneHalfWidth * 1.10, atr * 0.45) : math.max(zoneHalfWidth * 0.55, atr * 0.22))
        if na(resistanceTag)
            resistanceTag := label.new(bar_index + structureTagBarsForward, resistanceTagY, "Resistance Zone", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = f_structure_bg(false, resistanceHighlight), textcolor = f_text_on(f_structure_bg(false, resistanceHighlight)), size = structureTagSize)
        else
            label.set_xy(resistanceTag, bar_index + structureTagBarsForward, resistanceTagY)
            label.set_text(resistanceTag, "Resistance Zone")
            label.set_color(resistanceTag, f_structure_bg(false, resistanceHighlight))
            label.set_textcolor(resistanceTag, f_text_on(f_structure_bg(false, resistanceHighlight)))
            label.set_size(resistanceTag, structureTagSize)
    else if not na(resistanceTag)
        label.delete(resistanceTag)
        resistanceTag := na
else
    if not na(supportTag)
        label.delete(supportTag)
        supportTag := na
    if not na(resistanceTag)
        label.delete(resistanceTag)
        resistanceTag := na
    if not na(supportRail)
        line.delete(supportRail)
        supportRail := na
    if not na(resistanceRail)
        line.delete(resistanceRail)
        resistanceRail := na

if barstate.islast
    if not na(supportZoneBadge)
        label.delete(supportZoneBadge)
        supportZoneBadge := na
    if not na(resistanceZoneBadge)
        label.delete(resistanceZoneBadge)
        resistanceZoneBadge := na
    if showCenteredZoneBadges and showLevelZones
        zoneBadgeX = bar_index + int(math.max(2, math.round(structureTagBarsForward * 0.50)))
        if not na(confirmedSupport)
            supportZoneBadge := label.new(zoneBadgeX, confirmedSupport, "SUPPORT\nZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = f_structure_bg(true, supportHighlight), textcolor = f_text_on(f_structure_bg(true, supportHighlight)), size = structureTagSize)
        if not na(confirmedResistance)
            resistanceZoneBadge := label.new(zoneBadgeX, confirmedResistance, "RESISTANCE\nZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = f_structure_bg(false, resistanceHighlight), textcolor = f_text_on(f_structure_bg(false, resistanceHighlight)), size = structureTagSize)

// -----------------------------------------------------
// Event map storage
// -----------------------------------------------------
var float lastBullScore = na
var float lastBearScore = na
var int lastBullSignalBar = na
var int lastBearSignalBar = na
var float lastBullSignalLevel = na
var float lastBearSignalLevel = na
var int lastBullBreakBar = na
var int lastBearBreakBar = na
var float lastBullBreakExtreme = na
var float lastBearBreakExtreme = na
var box bullPocket = na
var box bearPocket = na
var label bullPocketBadge = na
var label bearPocketBadge = na
var box bullFocusBand = na
var box bearFocusBand = na
var line bullEventRail = na
var line bearEventRail = na

// -----------------------------------------------------
// Family locks
// -----------------------------------------------------
var int bullLockedFamilyId = na
var float bullLockedLevel = na
var int bearLockedFamilyId = na
var float bearLockedLevel = na

if not na(bullLockedFamilyId) and supportFamilyId != bullLockedFamilyId
    bullLockedFamilyId := na
    bullLockedLevel := na
if not na(bearLockedFamilyId) and resistanceFamilyId != bearLockedFamilyId
    bearLockedFamilyId := na
    bearLockedLevel := na

// -----------------------------------------------------
// Bullish reclaim state
// -----------------------------------------------------
var int bullState = 0
var float bullLevel = na
var int bullBreakBar = na
var int bullReclaimBar = na
var float bullBreakExtreme = na
var int bullBreakOutsideCloses = 0
var int bullTouchesAtBreak = 0
var float bullATRAtBreak = na
var float bullRejectScore = na
var float bullMaxHighAfterReclaim = na
var float bullMinLowAfterReclaim = na
var float bullReclaimLow = na
var float bullReclaimRange = na
var int bullEventFamilyId = na

canStartBull = not na(confirmedSupport) and bullState == 0 and (na(bullLockedFamilyId) or supportFamilyId != bullLockedFamilyId)
if canStartBull and low < confirmedSupport - breakDepth
    bullState := 1
    bullLevel := confirmedSupport
    bullBreakBar := bar_index
    bullReclaimBar := na
    bullBreakExtreme := low
    bullBreakOutsideCloses := close < confirmedSupport ? 1 : 0
    bullTouchesAtBreak := confirmedSupportTouches
    bullATRAtBreak := atr
    bullRejectScore := na
    bullMaxHighAfterReclaim := na
    bullMinLowAfterReclaim := na
    bullReclaimLow := na
    bullReclaimRange := na
    bullEventFamilyId := supportFamilyId

if bullState == 1
    bullBreakExtreme := math.min(bullBreakExtreme, low)
    bullBreakOutsideCloses += close < bullLevel ? 1 : 0
    timedOut = bar_index - bullBreakBar > reclaimBars
    familyChanged = supportFamilyId != bullEventFamilyId
    reclaimCond = close > bullLevel + reclaimBuffer
    if reclaimCond
        bullState := 2
        bullReclaimBar := bar_index
        bullRejectScore := f_reject_score_bull(open, high, low, close)
        bullMaxHighAfterReclaim := high
        bullMinLowAfterReclaim := low
        bullReclaimLow := low
        bullReclaimRange := high - low
    else if timedOut or familyChanged
        bullState := 0

if bullState == 2
    bullMaxHighAfterReclaim := math.max(bullMaxHighAfterReclaim, high)
    bullMinLowAfterReclaim := math.min(bullMinLowAfterReclaim, low)

// -----------------------------------------------------
// Bearish reclaim state
// -----------------------------------------------------
var int bearState = 0
var float bearLevel = na
var int bearBreakBar = na
var int bearReclaimBar = na
var float bearBreakExtreme = na
var int bearBreakOutsideCloses = 0
var int bearTouchesAtBreak = 0
var float bearATRAtBreak = na
var float bearRejectScore = na
var float bearMaxHighAfterReclaim = na
var float bearMinLowAfterReclaim = na
var float bearReclaimHigh = na
var float bearReclaimRange = na
var int bearEventFamilyId = na

canStartBear = not na(confirmedResistance) and bearState == 0 and (na(bearLockedFamilyId) or resistanceFamilyId != bearLockedFamilyId)
if canStartBear and high > confirmedResistance + breakDepth
    bearState := 1
    bearLevel := confirmedResistance
    bearBreakBar := bar_index
    bearReclaimBar := na
    bearBreakExtreme := high
    bearBreakOutsideCloses := close > confirmedResistance ? 1 : 0
    bearTouchesAtBreak := confirmedResistanceTouches
    bearATRAtBreak := atr
    bearRejectScore := na
    bearMaxHighAfterReclaim := na
    bearMinLowAfterReclaim := na
    bearReclaimHigh := na
    bearReclaimRange := na
    bearEventFamilyId := resistanceFamilyId

if bearState == 1
    bearBreakExtreme := math.max(bearBreakExtreme, high)
    bearBreakOutsideCloses += close > bearLevel ? 1 : 0
    timedOut = bar_index - bearBreakBar > reclaimBars
    familyChanged = resistanceFamilyId != bearEventFamilyId
    reclaimCond = close < bearLevel - reclaimBuffer
    if reclaimCond
        bearState := 2
        bearReclaimBar := bar_index
        bearRejectScore := f_reject_score_bear(open, high, low, close)
        bearMaxHighAfterReclaim := high
        bearMinLowAfterReclaim := low
        bearReclaimHigh := high
        bearReclaimRange := high - low
    else if timedOut or familyChanged
        bearState := 0

if bearState == 2
    bearMaxHighAfterReclaim := math.max(bearMaxHighAfterReclaim, high)
    bearMinLowAfterReclaim := math.min(bearMinLowAfterReclaim, low)

// -----------------------------------------------------
// Score + signals
// -----------------------------------------------------
var bool signalBull = false
var bool signalBear = false
signalBull := false
signalBear := false

if bullState == 2 and not na(bullReclaimBar) and bar_index - bullReclaimBar >= followBars
    bullPenATR = math.abs(bullLevel - bullBreakExtreme) / math.max(bullATRAtBreak, syminfo.mintick)
    bullLevelScore = f_clamp(45 + (bullTouchesAtBreak - minTouchesEff) * 18, 0, 100)
    bullBreakScore = f_clamp(100 - bullPenATR * 45 - (bullBreakOutsideCloses - 1) * 10, 0, 100)
    bullSpeedScore = f_clamp(100 - (bullReclaimBar - bullBreakBar) * (100.0 / math.max(reclaimBars, 1)), 0, 100)
    bullFavATR = (bullMaxHighAfterReclaim - bullLevel) / math.max(bullATRAtBreak, syminfo.mintick)
    bullAdvATR = (bullLevel - bullMinLowAfterReclaim) / math.max(bullATRAtBreak, syminfo.mintick)
    bullFollowScore = f_clamp(55 + bullFavATR * 28 - bullAdvATR * 30, 0, 100)
    bullFollowOk = bullMaxHighAfterReclaim >= bullLevel + followReq and bullAdvATR <= maxAdverseATR
    bullFinalScore = f_final_score(bullLevelScore, bullBreakScore, bullSpeedScore, bullRejectScore, bullFollowScore, weightLevel, weightBreak, weightSpeed, weightReject, weightFollow)
    bullPrint = bullFinalScore >= minScoreToPrint and bullFollowOk
    if bullPrint
        bullDynOffset = math.max(sigOffset, nz(bullReclaimRange, 0.0) * 0.35)
        bullBaseY = math.min(bullReclaimLow, bullLevel - levelTol * 0.35)
        label.new(bullReclaimBar, bullBaseY - bullDynOffset, "Bullish Reclaim\nQ " + str.tostring(math.round(bullFinalScore)), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = f_signal_bg(true), textcolor = f_text_on(f_signal_bg(true)), size = lblSize)
        signalBull := true
        bullLockedFamilyId := bullEventFamilyId
        bullLockedLevel := bullLevel
        lastBullScore := bullFinalScore
        lastBullSignalBar := bullReclaimBar
        lastBullSignalLevel := bullLevel
        lastBullBreakBar := bullBreakBar
        lastBullBreakExtreme := bullBreakExtreme
        if showReclaimPockets
            pad = math.max(nz(bullATRAtBreak, atr) * reclaimPocketPadATR, syminfo.mintick)
            top = bullLevel + pad
            bot = bullBreakExtreme - pad
            if na(bullPocket)
                bullPocket := box.new(bullBreakBar, top, bullReclaimBar + reclaimPocketExtendBars, bot, xloc = xloc.bar_index, border_color = f_event_border(true, true), border_width = 2, bgcolor = f_event_fill(true, true))
            else
                box.set_lefttop(bullPocket, bullBreakBar, top)
                box.set_rightbottom(bullPocket, bullReclaimBar + reclaimPocketExtendBars, bot)
                box.set_border_color(bullPocket, f_event_border(true, true))
                box.set_border_width(bullPocket, 2)
                box.set_bgcolor(bullPocket, f_event_fill(true, true))
    bullState := 0

if bearState == 2 and not na(bearReclaimBar) and bar_index - bearReclaimBar >= followBars
    bearPenATR = math.abs(bearBreakExtreme - bearLevel) / math.max(bearATRAtBreak, syminfo.mintick)
    bearLevelScore = f_clamp(45 + (bearTouchesAtBreak - minTouchesEff) * 18, 0, 100)
    bearBreakScore = f_clamp(100 - bearPenATR * 45 - (bearBreakOutsideCloses - 1) * 10, 0, 100)
    bearSpeedScore = f_clamp(100 - (bearReclaimBar - bearBreakBar) * (100.0 / math.max(reclaimBars, 1)), 0, 100)
    bearFavATR = (bearLevel - bearMinLowAfterReclaim) / math.max(bearATRAtBreak, syminfo.mintick)
    bearAdvATR = (bearMaxHighAfterReclaim - bearLevel) / math.max(bearATRAtBreak, syminfo.mintick)
    bearFollowScore = f_clamp(55 + bearFavATR * 28 - bearAdvATR * 30, 0, 100)
    bearFollowOk = bearMinLowAfterReclaim <= bearLevel - followReq and bearAdvATR <= maxAdverseATR
    bearFinalScore = f_final_score(bearLevelScore, bearBreakScore, bearSpeedScore, bearRejectScore, bearFollowScore, weightLevel, weightBreak, weightSpeed, weightReject, weightFollow)
    bearPrint = bearFinalScore >= minScoreToPrint and bearFollowOk
    if bearPrint
        bearDynOffset = math.max(sigOffset, nz(bearReclaimRange, 0.0) * 0.35)
        bearBaseY = math.max(bearReclaimHigh, bearLevel + levelTol * 0.35)
        label.new(bearReclaimBar, bearBaseY + bearDynOffset, "Bearish Reclaim\nQ " + str.tostring(math.round(bearFinalScore)), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = f_signal_bg(false), textcolor = f_text_on(f_signal_bg(false)), size = lblSize)
        signalBear := true
        bearLockedFamilyId := bearEventFamilyId
        bearLockedLevel := bearLevel
        lastBearScore := bearFinalScore
        lastBearSignalBar := bearReclaimBar
        lastBearSignalLevel := bearLevel
        lastBearBreakBar := bearBreakBar
        lastBearBreakExtreme := bearBreakExtreme
        if showReclaimPockets
            pad = math.max(nz(bearATRAtBreak, atr) * reclaimPocketPadATR, syminfo.mintick)
            top = bearBreakExtreme + pad
            bot = bearLevel - pad
            if na(bearPocket)
                bearPocket := box.new(bearBreakBar, top, bearReclaimBar + reclaimPocketExtendBars, bot, xloc = xloc.bar_index, border_color = f_event_border(false, true), border_width = 2, bgcolor = f_event_fill(false, true))
            else
                box.set_lefttop(bearPocket, bearBreakBar, top)
                box.set_rightbottom(bearPocket, bearReclaimBar + reclaimPocketExtendBars, bot)
                box.set_border_color(bearPocket, f_event_border(false, true))
                box.set_border_width(bearPocket, 2)
                box.set_bgcolor(bearPocket, f_event_fill(false, true))
    bearState := 0

if not showReclaimPockets
    if not na(bullPocket)
        box.delete(bullPocket)
        bullPocket := na
    if not na(bearPocket)
        box.delete(bearPocket)
        bearPocket := na

// -----------------------------------------------------
// Stop-aware Proof — reclaim follow-through
// Measured from the printed-reclaim bar close (the actual decision point), did
// price CLOSE to a 1.5 ATR follow-through before closing 1.0 ATR against it?
// Both sides close-based, resolve-then-open, timeout uncounted, "Building (n)"
// until at least 6 samples.
// -----------------------------------------------------
var float fbqProofTarget = na
var float fbqProofStop   = na
var int   fbqProofDir    = 0
var bool  fbqProofOpen   = false
var int   fbqProofAge    = na
var int   fbqProofWins   = 0
var int   fbqProofLosses = 0
int fbqProofWindow = math.max(focusBandExtendBars, 30)

if signalBull and barstate.isconfirmed and not fbqProofOpen
    fbqProofTarget := close + atr * 1.5
    fbqProofStop   := close - atr * 1.0
    fbqProofDir    := 1
    fbqProofAge    := 0
    fbqProofOpen   := true
else if signalBear and barstate.isconfirmed and not fbqProofOpen
    fbqProofTarget := close - atr * 1.5
    fbqProofStop   := close + atr * 1.0
    fbqProofDir    := -1
    fbqProofAge    := 0
    fbqProofOpen   := true

if fbqProofOpen and barstate.isconfirmed and not na(fbqProofTarget) and not na(fbqProofStop)
    bool proofHitStop   = fbqProofDir == 1 ? close <= fbqProofStop : close >= fbqProofStop
    bool proofHitTarget = fbqProofDir == 1 ? close >= fbqProofTarget : close <= fbqProofTarget
    if proofHitStop
        fbqProofLosses += 1
        fbqProofOpen := false
    else if proofHitTarget
        fbqProofWins += 1
        fbqProofOpen := false
    else
        fbqProofAge := nz(fbqProofAge) + 1
        if fbqProofAge > fbqProofWindow
            fbqProofOpen := false   // timeout — uncounted

int fbqProofTotal = fbqProofWins + fbqProofLosses
float fbqProofRate = fbqProofTotal == 0 ? 0.0 : 100.0 * fbqProofWins / fbqProofTotal
string proofText = fbqProofTotal < 6 ? "Building (" + str.tostring(fbqProofTotal) + ")" : str.tostring(math.round(fbqProofRate)) + "% (" + str.tostring(fbqProofTotal) + ")"
color proofColor = fbqProofTotal < 6 ? f_panel_label() : fbqProofRate >= 55 ? bullColor : fbqProofRate >= 45 ? neutralColor : bearColor

// -----------------------------------------------------
// Stale cleanup
// -----------------------------------------------------
if autoCleanStaleEvents
    bullStale = false
    if not na(lastBullSignalBar)
        bullStale := na(confirmedSupport) or (not na(lastBullSignalLevel) and math.abs(confirmedSupport - lastBullSignalLevel) > familyResetBand) or bar_index - lastBullSignalBar > staleEventMaxBars
    if bullStale
        if not na(bullFocusBand)
            box.delete(bullFocusBand)
            bullFocusBand := na
        if not na(bullPocket)
            box.delete(bullPocket)
            bullPocket := na
        if not na(bullPocketBadge)
            label.delete(bullPocketBadge)
            bullPocketBadge := na
        if not na(bullEventRail)
            line.delete(bullEventRail)
            bullEventRail := na
        lastBullSignalBar := na
        lastBullSignalLevel := na
        lastBullBreakBar := na
        lastBullBreakExtreme := na
        lastBullScore := na

    bearStale = false
    if not na(lastBearSignalBar)
        bearStale := na(confirmedResistance) or (not na(lastBearSignalLevel) and math.abs(confirmedResistance - lastBearSignalLevel) > familyResetBand) or bar_index - lastBearSignalBar > staleEventMaxBars
    if bearStale
        if not na(bearFocusBand)
            box.delete(bearFocusBand)
            bearFocusBand := na
        if not na(bearPocket)
            box.delete(bearPocket)
            bearPocket := na
        if not na(bearPocketBadge)
            label.delete(bearPocketBadge)
            bearPocketBadge := na
        if not na(bearEventRail)
            line.delete(bearEventRail)
            bearEventRail := na
        lastBearSignalBar := na
        lastBearSignalLevel := na
        lastBearBreakBar := na
        lastBearBreakExtreme := na
        lastBearScore := na

// -----------------------------------------------------
// Event focus visuals
// -----------------------------------------------------
latestBullIsFocus = not na(lastBullSignalBar) and (na(lastBearSignalBar) or lastBullSignalBar >= lastBearSignalBar)
latestBearIsFocus = not na(lastBearSignalBar) and (na(lastBullSignalBar) or lastBearSignalBar > lastBullSignalBar)

if fadeNonFocusEvents and showReclaimPockets
    if not na(bullPocket)
        box.set_bgcolor(bullPocket, f_event_fill(true, latestBullIsFocus))
        box.set_border_color(bullPocket, f_event_border(true, latestBullIsFocus))
        box.set_border_width(bullPocket, latestBullIsFocus ? 2 : 1)
    if not na(bearPocket)
        box.set_bgcolor(bearPocket, f_event_fill(false, latestBearIsFocus))
        box.set_border_color(bearPocket, f_event_border(false, latestBearIsFocus))
        box.set_border_width(bearPocket, latestBearIsFocus ? 2 : 1)

if showFocusBands
    if not na(lastBullSignalBar) and not na(lastBullBreakBar) and not na(lastBullSignalLevel)
        pad = math.max(levelTol * 0.45, atr * focusBandPadATR)
        top = lastBullSignalLevel + pad
        bot = lastBullSignalLevel - pad
        if na(bullFocusBand)
            bullFocusBand := box.new(lastBullBreakBar, top, bar_index + focusBandExtendBars, bot, xloc = xloc.bar_index, border_color = f_focus_border(true, latestBullIsFocus), border_width = latestBullIsFocus ? 2 : 1, bgcolor = f_focus_fill(true, latestBullIsFocus))
        else
            box.set_lefttop(bullFocusBand, lastBullBreakBar, top)
            box.set_rightbottom(bullFocusBand, bar_index + focusBandExtendBars, bot)
            box.set_border_color(bullFocusBand, f_focus_border(true, latestBullIsFocus))
            box.set_border_width(bullFocusBand, latestBullIsFocus ? 2 : 1)
            box.set_bgcolor(bullFocusBand, f_focus_fill(true, latestBullIsFocus))
    else if not na(bullFocusBand)
        box.delete(bullFocusBand)
        bullFocusBand := na

    if not na(lastBearSignalBar) and not na(lastBearBreakBar) and not na(lastBearSignalLevel)
        pad = math.max(levelTol * 0.45, atr * focusBandPadATR)
        top = lastBearSignalLevel + pad
        bot = lastBearSignalLevel - pad
        if na(bearFocusBand)
            bearFocusBand := box.new(lastBearBreakBar, top, bar_index + focusBandExtendBars, bot, xloc = xloc.bar_index, border_color = f_focus_border(false, latestBearIsFocus), border_width = latestBearIsFocus ? 2 : 1, bgcolor = f_focus_fill(false, latestBearIsFocus))
        else
            box.set_lefttop(bearFocusBand, lastBearBreakBar, top)
            box.set_rightbottom(bearFocusBand, bar_index + focusBandExtendBars, bot)
            box.set_border_color(bearFocusBand, f_focus_border(false, latestBearIsFocus))
            box.set_border_width(bearFocusBand, latestBearIsFocus ? 2 : 1)
            box.set_bgcolor(bearFocusBand, f_focus_fill(false, latestBearIsFocus))
    else if not na(bearFocusBand)
        box.delete(bearFocusBand)
        bearFocusBand := na
else
    if not na(bullFocusBand)
        box.delete(bullFocusBand)
        bullFocusBand := na
    if not na(bearFocusBand)
        box.delete(bearFocusBand)
        bearFocusBand := na

if showEventRails
    if not na(lastBullBreakBar) and not na(lastBullBreakExtreme) and not na(lastBullSignalBar) and not na(lastBullSignalLevel)
        if na(bullEventRail)
            bullEventRail := line.new(lastBullBreakBar, lastBullBreakExtreme, lastBullSignalBar, lastBullSignalLevel, xloc = xloc.bar_index, extend = extend.none, color = f_event_rail(true, latestBullIsFocus), style = line.style_dashed, width = latestBullIsFocus ? 3 : 1)
        else
            line.set_xy1(bullEventRail, lastBullBreakBar, lastBullBreakExtreme)
            line.set_xy2(bullEventRail, lastBullSignalBar, lastBullSignalLevel)
            line.set_color(bullEventRail, f_event_rail(true, latestBullIsFocus))
            line.set_width(bullEventRail, latestBullIsFocus ? 3 : 1)
    else if not na(bullEventRail)
        line.delete(bullEventRail)
        bullEventRail := na

    if not na(lastBearBreakBar) and not na(lastBearBreakExtreme) and not na(lastBearSignalBar) and not na(lastBearSignalLevel)
        if na(bearEventRail)
            bearEventRail := line.new(lastBearBreakBar, lastBearBreakExtreme, lastBearSignalBar, lastBearSignalLevel, xloc = xloc.bar_index, extend = extend.none, color = f_event_rail(false, latestBearIsFocus), style = line.style_dashed, width = latestBearIsFocus ? 3 : 1)
        else
            line.set_xy1(bearEventRail, lastBearBreakBar, lastBearBreakExtreme)
            line.set_xy2(bearEventRail, lastBearSignalBar, lastBearSignalLevel)
            line.set_color(bearEventRail, f_event_rail(false, latestBearIsFocus))
            line.set_width(bearEventRail, latestBearIsFocus ? 3 : 1)
    else if not na(bearEventRail)
        line.delete(bearEventRail)
        bearEventRail := na
else
    if not na(bullEventRail)
        line.delete(bullEventRail)
        bullEventRail := na
    if not na(bearEventRail)
        line.delete(bearEventRail)
        bearEventRail := na

if barstate.islast
    if not na(bullPocketBadge)
        label.delete(bullPocketBadge)
        bullPocketBadge := na
    if not na(bearPocketBadge)
        label.delete(bearPocketBadge)
        bearPocketBadge := na
    if showPocketBadges and showReclaimPockets
        if not na(bullPocket) and not na(lastBullBreakBar) and not na(lastBullSignalBar) and not na(lastBullSignalLevel)
            bullPocketBadgeX = lastBullBreakBar + int(math.round((lastBullSignalBar + reclaimPocketExtendBars - lastBullBreakBar) * 0.50))
            bullPocketBadge := label.new(bullPocketBadgeX, lastBullSignalLevel, "BULLISH\nRECLAIM", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bullColor, 0), textcolor = f_text_on(bullColor), size = lblSize)
        if not na(bearPocket) and not na(lastBearBreakBar) and not na(lastBearSignalBar) and not na(lastBearSignalLevel)
            bearPocketBadgeX = lastBearBreakBar + int(math.round((lastBearSignalBar + reclaimPocketExtendBars - lastBearBreakBar) * 0.50))
            bearPocketBadge := label.new(bearPocketBadgeX, lastBearSignalLevel, "BEARISH\nRECLAIM", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = lblSize)

// -----------------------------------------------------
// Panel
// -----------------------------------------------------
panelProfileText = useAutoProfiles ? (isHourlyProfile ? "Auto | Intraday" : isH4Profile ? "Auto | H4" : "Auto | Swing") : "Manual"
panelStateText = bullState == 1 ? "Bull Trap Watch" : bullState == 2 ? "Bull Reclaim Pending" : bearState == 1 ? "Bear Trap Watch" : bearState == 2 ? "Bear Reclaim Pending" : (not na(confirmedSupport) or not na(confirmedResistance) ? "Scanning Levels" : "Building Levels")
panelStateBg = bullState > 0 ? color.new(bullColor, 70) : bearState > 0 ? color.new(bearColor, 70) : color.new(neutralColor, 78)
panelStateTextColor = bullState > 0 ? bullColor : bearState > 0 ? bearColor : neutralColor
panelFocusText = na(confirmedSupport) and na(confirmedResistance) ? "No active zone" : supportHighlight and not na(confirmedSupport) ? "Support " + f_fmt_price(confirmedSupport) : not na(confirmedResistance) ? "Resistance " + f_fmt_price(confirmedResistance) : "Support " + f_fmt_price(confirmedSupport)
latestIsBull = not na(lastBullSignalBar) and (na(lastBearSignalBar) or lastBullSignalBar >= lastBearSignalBar)
latestHasSignal = not na(lastBullSignalBar) or not na(lastBearSignalBar)
latestSignalText = not latestHasSignal ? "-" : latestIsBull ? "Bull " + f_fmt_score(lastBullScore) : "Bear " + f_fmt_score(lastBearScore)
latestSignalColor = not latestHasSignal ? f_panel_value() : latestIsBull ? bullColor : bearColor

// Decision layer — measured-move target, invalidation edge, next action
float latestReclaimLevel = latestIsBull ? lastBullSignalLevel : lastBearSignalLevel
float latestBreakExtreme = latestIsBull ? lastBullBreakExtreme : lastBearBreakExtreme
int   latestSignalBarUsed = latestIsBull ? lastBullSignalBar : lastBearSignalBar
float latestTrapDepth = (not na(latestReclaimLevel) and not na(latestBreakExtreme)) ? math.abs(latestReclaimLevel - latestBreakExtreme) : na
float latestTargetPrice = na
float latestInvalPrice = na
if latestHasSignal and not na(latestTrapDepth)
    latestInvalPrice := latestBreakExtreme
    latestTargetPrice := latestIsBull ? latestReclaimLevel + latestTrapDepth * targetRMultiple : latestReclaimLevel - latestTrapDepth * targetRMultiple

string targetText = latestHasSignal and not na(latestTargetPrice) ? f_fmt_price(latestTargetPrice) : "-"
string invalText = latestHasSignal and not na(latestInvalPrice) ? f_fmt_price(latestInvalPrice) : "-"

bool recentSignal = not na(latestSignalBarUsed) and bar_index - latestSignalBarUsed <= focusBandExtendBars
string actionText = bullState == 1 or bearState == 1 ? "Watch trap" :
     bullState == 2 or bearState == 2 ? "Wait reclaim" :
     latestHasSignal and recentSignal ? (latestIsBull ? "Review long" : "Review short") :
     (na(confirmedSupport) and na(confirmedResistance) ? "Build levels" : "Wait setup")
color actionColor = bullState > 0 ? bullColor : bearState > 0 ? bearColor : (latestHasSignal and recentSignal ? (latestIsBull ? bullColor : bearColor) : neutralColor)

var table panel = na

if barstate.islast
    if showPanel
        if na(panel)
            panel := table.new(f_panel_pos(panelPositionInput), 2, 11, bgcolor = f_panel_bg(), frame_color = f_panel_border(), frame_width = 1, border_color = f_panel_border(), border_width = 1)
        table.set_position(panel, f_panel_pos(panelPositionInput))
        table.set_frame_color(panel, f_panel_border())
        table.set_border_color(panel, f_panel_border())
        table.clear(panel, 0, 0, 1, 10)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Failed Break Quality", text_color = headerText, text_size = f_size(panelFontSizeInput), bgcolor = headerBg, text_halign = text.align_center)
        table.cell(panel, 0, 1, "Profile", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 1, panelProfileText, text_color = f_panel_value(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 2, "State", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 2, panelStateText, text_color = panelStateTextColor, text_size = f_size(panelFontSizeInput), bgcolor = panelStateBg)
        table.cell(panel, 0, 3, "Focus", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 3, panelFocusText, text_color = f_panel_value(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 4, "Latest", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 4, latestSignalText, text_color = latestSignalColor, text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 5, "Target", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 5, targetText, text_color = latestHasSignal ? accentColor : f_panel_value(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 6, "Invalidation", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 6, invalText, text_color = latestHasSignal ? neutralColor : f_panel_value(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 7, "Action", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 7, actionText, text_color = actionColor, text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 8, "Bull Q", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 8, f_fmt_score(lastBullScore), text_color = bullColor, text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 9, "Bear Q", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 9, f_fmt_score(lastBearScore), text_color = bearColor, text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
        table.cell(panel, 0, 10, "Proof", text_color = f_panel_label(), text_size = f_size(panelFontSizeInput), bgcolor = f_panel_label_bg())
        table.cell(panel, 1, 10, proofText, text_color = proofColor, text_size = f_size(panelFontSizeInput), bgcolor = f_panel_bg())
    else
        if not na(panel)
            table.delete(panel)
            panel := na

// -----------------------------------------------------
// Debug
// -----------------------------------------------------
plotshape(showDebugMarkers and bullState == 1, title = "Bull Break Seen", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showDebugMarkers and bullState == 2, title = "Bull Reclaim Seen", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showDebugMarkers and bearState == 1, title = "Bear Break Seen", style = shape.circle, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showDebugMarkers and bearState == 2, title = "Bear Reclaim Seen", style = shape.circle, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

// -----------------------------------------------------
// Alerts
// -----------------------------------------------------
alertcondition(signalBull, title = "Bullish Reclaim", message = "Failed Break Quality: Bullish reclaim confirmed.")
alertcondition(signalBear, title = "Bearish Reclaim", message = "Failed Break Quality: Bearish reclaim confirmed.")
````
