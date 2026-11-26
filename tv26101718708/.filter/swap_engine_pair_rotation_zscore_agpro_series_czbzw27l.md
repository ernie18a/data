# Swap Engine - Pair Rotation (Z-Score) [AGPro Series]

- url: https://www.tradingview.com/script/CZBZw27L-Swap-Engine-Pair-Rotation-Z-Score-AGPro-Series/
- type: indicator
- pine_id: PUB;73fd5b8501b2439c9d8281c565a32059
- version: 6.0

## Description

Swap Engine - Pair Rotation (Z-Score) [AGPro Series]

🔷 OVERVIEW

Swap Engine - Pair Rotation (Z-Score) transforms the log-ratio between two correlated crypto assets into a disciplined tier ladder decision framework. Rather than signalling single-asset direction, the engine measures how stretched one pair has become relative to its rolling mean and proposes rotation between the two assets when the spread reaches statistically meaningful extremes. Every decision is evaluated on confirmed Engine TF bar close, keeping suggestions non-repainting under the configured execution model.

🟣 UNIQUE EDGE

Unlike single-symbol mean-reversion or trend indicators, this engine treats the ratio itself as the tradable variable and pairs it with a full operational stack: a tiered exposure ladder (T0 to T3), an Integrity Gate that blocks entries when the pair relationship deteriorates, a Trend Regime filter that respects persistent one-sided moves, and a confirm-first execution model that converts raw signals into auditable decisions. A dedicated Signal Quality score (Q 0-100) and Integrity Score (IN 0-100) make every suggestion inspectable, not a black box.

🟢 METHODOLOGY

The engine fetches the closing price of Pair A and Pair B on the chosen Engine TF, computes the log-ratio L = ln(A / B), then derives a rolling z-score using user-defined lookback length. Entry thresholds (Z1, Z2, Z3) define the three tiers of exposure; exit thresholds (hysteresis) define when each tier is scaled back. A cost filter requires the expected mean-reversion edge to exceed a configurable multiple of estimated roundtrip cost before any entry is allowed. The Integrity Gate continuously validates rolling return correlation, ratio drift, and spread-volatility expansion, halting new entries when the pair relationship degrades.

🟡 SIGNALS & ALERTS

Each signal renders as a clearly tagged label on chart showing the action type (ENTRY / EXIT), source tier, target tier, direction (A->B or B->A), z-score snapshot, delta %, and Reason Code. Alerts are provided for: entry and exit events per direction, pending lifecycle (created, confirmed, skipped, expired), trend regime activation edges, duplicate suppression, and configuration warnings. All alerts fire on Engine TF bar close to remain consistent with the visible suggestions.

⚙️ KEY INPUTS

Pair A / Pair B: the two assets to rotate between (same quote currency recommended).
Engine TF: timeframe used for all ratio, z-score, and decision logic (240 / 4H default).
Lookback: bars used for rolling mean and standard deviation.
Entry Z1/Z2/Z3, Exit Z1/Z2/Z3: tiered thresholds for scaling in and out.
Tier Sizing (T1 / T2 / T3 %): rotation size per tier as a percentage of the active pool.
Trade Profile: preset gate behavior (Conservative, Balanced, Aggressive, Volatile Alt, High-Cost, Custom).
Integrity Gate: correlation, drift, and volatility expansion filter with configurable minimum score.
Execution Model: ASSUME (auto-advance), CONFIRM (pending + manual commit), or SIGNAL_ONLY (display only).

🔵 HOW TO USE

Start on the default BTCUSDT vs ETHUSDT pair on 4H Engine TF with the Balanced profile. Keep the chart timeframe equal to or lower than the Engine TF (the script warns otherwise). Watch the status panel for the current tier, direction, confidence strip (Q / IN / PH), and next action preview. In CONFIRM mode, a PENDING card appears when a signal fires; increase CONFIRM +1 to commit the rotation state, or SKIP +1 to discard. Use the Trade Profile dropdown to tighten or loosen effective gates without changing your base inputs.

🟠 LIMITATIONS & TRANSPARENCY

This is an indicator, not a strategy; no orders are placed and no backtest statistics are produced. Signals reflect statistical extremes in the pair's log-ratio and do not guarantee mean reversion. Performance depends heavily on pair selection - assets with persistent trends, broken correlation, or structural regime changes can cause extended adverse periods. The Integrity Gate mitigates but does not eliminate this risk. Costs, slippage, tax, and execution details are the user's responsibility; the Min Edge x filter is an estimate, not a realized-cost guarantee. Always validate on your own pair, timeframe, and account conditions before relying on any suggestion.

🔴 RISK DISCLOSURE

Trading and rotating between crypto assets involves substantial risk, including loss of capital. Past or simulated behavior of the ratio does not guarantee future results. This tool is shared for educational and analytical purposes only and does not constitute financial, investment, or trading advice. Users are solely responsible for their own decisions and should consult a qualified professional before committing capital.

## Source Code

````pine
// -------------------------------------------------
// Swap Engine - Pair Rotation (Z-Score) [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Swap Engine - Pair Rotation converts the log-ratio between two selected
// assets into a z-score rotation map. It highlights stretch, deep stretch,
// reversion, and integrity-gated conditions with cleaner chart labels,
// compact live tags, an optional low-noise rotation trail, and a premium
// decision panel for crypto pair rotation, spread analysis, relative value
// monitoring, and mean-reversion workflows. V1.6 corrects multi-bar stretch
// confirmation and adds controlled mean-return context to Balanced charts.
// This is an analytical visualization tool, not a strategy, not automation,
// and not financial advice.
// -------------------------------------------------

//@version=6
indicator("Swap Engine - Pair Rotation (Z-Score) [AGPro Series]",
     shorttitle       = "AG Swap",
     overlay          = true,
     max_labels_count = 260,
     max_lines_count  = 20,
     max_boxes_count  = 20)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgD      = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgL      = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupPair   = "Pair Engine"
groupSignal = "Rotation Logic"
groupVisual = "Visuals"
groupPanel  = "Panel"
groupAlert  = "Alerts"

pairASymbol = input.symbol("BINANCE:BTCUSDT", "Pair A", group = groupPair,
     tooltip = "First asset in the rotation pair. Use instruments with comparable quote currency and market structure for cleaner ratio behavior.")

pairBSymbol = input.symbol("BINANCE:ETHUSDT", "Pair B", group = groupPair,
     tooltip = "Second asset in the rotation pair. The engine compares Pair A versus Pair B through the log-ratio of their prices.")

engineTf = input.timeframe("240", "Engine Timeframe", group = groupPair,
     tooltip = "Timeframe used for the pair ratio and z-score engine. Higher values produce fewer but cleaner rotation events.")

zLength = input.int(180, "Z-Score Lookback", minval = 60, maxval = 500, group = groupPair,
     tooltip = "Lookback used to estimate the ratio mean and standard deviation. Longer values make the model more structural; shorter values react faster.")

entryZ = input.float(1.70, "Stretch Threshold", minval = 0.50, maxval = 5.00, step = 0.05, group = groupSignal,
     tooltip = "Absolute z-score where a pair begins to look stretched. This creates a rotation watch event when quality gates allow it.")

deepZ = input.float(2.40, "Deep Stretch Threshold", minval = 0.80, maxval = 6.00, step = 0.05, group = groupSignal,
     tooltip = "Absolute z-score where the pair is deeply stretched. Deep stretch labels are more selective and visually stronger.")

exitZ = input.float(0.70, "Reversion Threshold", minval = 0.05, maxval = 2.50, step = 0.05, group = groupSignal,
     tooltip = "Absolute z-score where the spread is considered to have rotated back toward its mean.")

confirmBars = input.int(1, "Confirm Bars", minval = 1, maxval = 5, group = groupSignal,
     tooltip = "Number of confirmed engine bars required before a stretch state is treated as active. Higher values reduce noisy first touches.")

revWindowBars = input.int(30, "Reversion Proof Window (bars)", minval = 5, maxval = 200, group = groupSignal,
     tooltip = "Number of evaluated engine bars a stretch has to revert to the mean zone within, for the Revert Rate proof. It only measures historical reversion behavior and is not a forecast.")

minIntegrity = input.float(58.0, "Minimum Integrity Score", minval = 0.0, maxval = 100.0, step = 1.0, group = groupSignal,
     tooltip = "Minimum pair quality required for new stretch labels. The score blends rolling correlation, ratio drift and spread volatility expansion.")

corrLength = input.int(60, "Correlation Lookback", minval = 20, maxval = 250, group = groupSignal,
     tooltip = "Lookback used to estimate return correlation between Pair A and Pair B.")

driftBars = input.int(20, "Drift Lookback", minval = 5, maxval = 120, group = groupSignal,
     tooltip = "Bars used to detect whether the ratio mean is drifting too far from its recent baseline.")

maxDriftZ = input.float(0.45, "Max Mean Drift", minval = 0.05, maxval = 3.00, step = 0.05, group = groupSignal,
     tooltip = "Maximum accepted ratio-mean drift, measured in standard deviation units. Lower values create a stricter integrity gate.")

maxVolExpansion = input.float(1.45, "Max Vol Expansion", minval = 1.00, maxval = 4.00, step = 0.05, group = groupSignal,
     tooltip = "Maximum accepted short-term versus base spread volatility expansion. Higher expansion means the pair may be less stable.")

onlyNewEngineBar = input.bool(true, "Evaluate Only New Engine Bar", group = groupSignal,
     tooltip = "When enabled, new rotation events are evaluated only when a fresh engine-timeframe bar begins. This keeps labels stable.")

showLabels = input.bool(true, "Show Rotation Labels", group = groupVisual,
     tooltip = "Displays compact stretch and deep-stretch labels on the chart. Balanced mode keeps the chart selective by default.")

labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = groupVisual,
     tooltip = "Controls how much chart annotation appears. Minimal shows only deep stretches. Balanced shows high-quality stretch events. Detailed also allows reversion and integrity-block labels.")

minLabelQuality = input.float(70.0, "Minimum Label Quality", minval = 0.0, maxval = 100.0, step = 1.0, group = groupVisual,
     tooltip = "Minimum quality score required for stretch labels in Balanced and Detailed modes. Higher values reduce chart clutter.")

minLabelGapBars = input.int(24, "Minimum Label Gap (bars)", minval = 1, maxval = 120, group = groupVisual,
     tooltip = "Minimum bar distance between two historical rotation labels. This prevents repeated labels from stacking inside the same price area.")

minLabelGapAtr = input.float(1.35, "Minimum Vertical Gap (ATR)", minval = 0.10, maxval = 5.00, step = 0.05, group = groupVisual,
     tooltip = "Minimum vertical spacing between recent labels, measured in ATR. Helps keep labels clear of each other and away from candles.")

labelOffsetAtr = input.float(1.45, "Rotation Label Offset ATR", minval = 0.40, maxval = 3.50, step = 0.05, group = groupVisual,
     tooltip = "ATR-based vertical offset used to keep stretch, deep-stretch, reversion, and integrity labels away from candles.")

showReversionLabels = input.bool(true, "Show Reversion Labels", group = groupVisual,
     tooltip = "Shows confirmed mean-return events with the same spacing and label-cap safeguards used by stretch labels. Enabled by default to complete the rotation story without crowding the chart.")

labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Font size for chart labels and right-edge live tags. Default Normal follows the AGPro Series visual standard.")

showLiveTags = input.bool(true, "Show Live Right-Edge Tags", group = groupVisual,
     tooltip = "Shows the latest pair state, z-score and integrity score on the right side of the chart.")

liveTagMode = input.string("Compact", "Live Tag Mode", options = ["Compact", "Detailed"], group = groupVisual,
     tooltip = "Compact shows one right-edge status tag to avoid overlap. Detailed shows separate state, z-score and integrity tags.")

liveTagOffsetBars = input.int(10, "Live Tag Offset Bars", minval = 4, maxval = 50, group = groupVisual,
     tooltip = "Horizontal projection used to keep live right-edge tags away from candles and nearby labels.")

showStateTint = input.bool(false, "Show State Tint", group = groupVisual,
     tooltip = "Applies a very light chart tint when the pair is stretched, deeply stretched or in a blocked integrity state. Disabled by default for a cleaner publication view.")

showRotationTrail = input.bool(false, "Show Rotation Trail", group = groupVisual,
     tooltip = "Draws a subtle ATR-offset trail around price. Disabled by default for the cleanest publication view, while remaining available for users who prefer continuous rotation context.")

trailOffsetAtr = input.float(0.42, "Trail Offset (ATR)", minval = 0.10, maxval = 2.00, step = 0.05, group = groupVisual,
     tooltip = "Distance between price and the rotation trail, measured in ATR. Higher values give the trail more separation from candles.")

showStateMarkers = input.bool(false, "Show State Markers", group = groupVisual,
     tooltip = "Adds small non-text markers when the pair enters stretch, deep stretch, mean zone, or integrity-block states. Disabled by default for a cleaner publication view.")

maxChartLabels = input.int(14, "Max Chart Labels", minval = 10, maxval = 180, group = groupVisual,
     tooltip = "Maximum number of historical rotation labels kept on the chart. Older labels are removed automatically.")

showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Displays the on-chart status panel with pair state, action, z-score, integrity, quality, and next-step context. Enabled by default.")

panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"],
     group = groupPanel,
     tooltip = "Anchor position for the status panel, including center positions for publication screenshots.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Panel color theme. Dark is the default publication style; Light is useful on bright chart layouts.")

panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Font size used inside the panel.")

enableAlerts = input.bool(true, "Enable Alert Conditions", group = groupAlert,
     tooltip = "Enables TradingView alert conditions for stretch, deep stretch, reversion and integrity-block events.")

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
        "Top Center" => position.top_center
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

f_symbol_core(sym) =>
    parts = str.split(sym, ":")
    raw = array.size(parts) > 1 ? array.get(parts, 1) : sym
    raw := str.endswith(raw, "USDT") ? str.substring(raw, 0, str.length(raw) - 4) : raw
    raw := str.endswith(raw, "USDC") ? str.substring(raw, 0, str.length(raw) - 4) : raw
    raw := str.endswith(raw, "USD") ? str.substring(raw, 0, str.length(raw) - 3) : raw
    raw := str.endswith(raw, "PERP") ? str.substring(raw, 0, str.length(raw) - 4) : raw
    raw

f_quote_hint(sym) =>
    parts = str.split(sym, ":")
    raw = array.size(parts) > 1 ? array.get(parts, 1) : sym
    str.endswith(raw, "USDT") ? "USDT" :
     str.endswith(raw, "USDC") ? "USDC" :
     str.endswith(raw, "USD") ? "USD" :
     str.endswith(raw, "BTC") ? "BTC" :
     str.endswith(raw, "ETH") ? "ETH" :
     "?"

f_meter(v) =>
    v >= 85 ? "A+" :
     v >= 75 ? "A" :
     v >= 65 ? "B" :
     v >= 50 ? "C" :
     v >= 35 ? "D" :
     "E"

f_action_text(stretch, deep, revert, blocked, dirTxt) =>
    blocked ? "INTEGRITY BLOCK" :
     deep ? "DEEP " + dirTxt :
     stretch ? "WATCH " + dirTxt :
     revert ? "MEAN ZONE" :
     "WAIT"

f_panel_bg(isLight, alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : panelBgL) : (alt ? color.rgb(24, 35, 55) : panelBgD)

f_panel_label(isLight) =>
    isLight ? panelLabelL : panelLabelD

f_panel_value(isLight) =>
    isLight ? panelValueL : panelValueD

// -------------------------------------------------
// Pair Ratio Engine
// -------------------------------------------------
pairA = f_symbol_core(pairASymbol)
pairB = f_symbol_core(pairBSymbol)
quoteA = f_quote_hint(pairASymbol)
quoteB = f_quote_hint(pairBSymbol)
quoteMismatch = quoteA != "?" and quoteB != "?" and quoteA != quoteB
samePair = pairASymbol == pairBSymbol

aClose = request.security(pairASymbol, engineTf, close, barmerge.gaps_off, barmerge.lookahead_off)
bClose = request.security(pairBSymbol, engineTf, close, barmerge.gaps_off, barmerge.lookahead_off)

ratio = aClose > 0 and bClose > 0 ? aClose / bClose : na
logRatio = ratio > 0 ? math.log(ratio) : na
ratioMean = ta.sma(logRatio, zLength)
ratioDev = ta.stdev(logRatio, zLength)
zScore = ratioDev > 0 ? (logRatio - ratioMean) / ratioDev : na
absZ = math.abs(zScore)

retA = aClose > 0 and nz(aClose[1], 0.0) > 0 ? math.log(aClose / aClose[1]) : na
retB = bClose > 0 and nz(bClose[1], 0.0) > 0 ? math.log(bClose / bClose[1]) : na
pairCorr = ta.correlation(retA, retB, corrLength)

shortLen = math.max(10, int(math.floor(corrLength / 3)))
volShort = ta.stdev(logRatio, shortLen)
volBase = ta.stdev(logRatio, corrLength)
volExpansion = volBase > 0 ? volShort / volBase : na
meanDrift = ratioDev > 0 and not na(ratioMean[driftBars]) ? math.abs(ratioMean - ratioMean[driftBars]) / ratioDev : na

corrNorm = na(pairCorr) ? 0.0 : f_clamp((pairCorr + 1.0) / 2.0, 0.0, 1.0)
driftNorm = na(meanDrift) ? 0.0 : f_clamp(1.0 - meanDrift / maxDriftZ, 0.0, 1.0)
volNorm = na(volExpansion) ? 0.0 : f_clamp(1.0 - math.max(0.0, volExpansion - 1.0) / math.max(0.01, maxVolExpansion - 1.0), 0.0, 1.0)
integrityScore = f_clamp(100.0 * (0.45 * corrNorm + 0.30 * driftNorm + 0.25 * volNorm), 0.0, 100.0)
integrityOk = integrityScore >= minIntegrity and not quoteMismatch and not samePair

// -------------------------------------------------
// State Detection
// -------------------------------------------------
tfTime = time(engineTf)
newEngineBar = ta.change(tfTime) != 0
evalNow = onlyNewEngineBar ? newEngineBar : true
confirmedNow = barstate.isconfirmed and evalNow and not na(zScore) and ratioDev > 0

dir = zScore > 0 ? 1 : zScore < 0 ? -1 : 0
dirText = dir == 1 ? pairA + " -> " + pairB : dir == -1 ? pairB + " -> " + pairA : "Neutral"
richText = dir == 1 ? pairA + " Rich" : dir == -1 ? pairB + " Rich" : "Balanced"

var int stretchConfirmCount = 0
var bool stretchStateActive = false
var float prevEngineAbsZ = na

bool stretchEvent = false
bool deepEvent = false
bool reversionEvent = false
bool blockedEvent = false

if confirmedNow
    previousBelowEntry = na(prevEngineAbsZ) or prevEngineAbsZ < entryZ
    previousBelowDeep = na(prevEngineAbsZ) or prevEngineAbsZ < deepZ
    previousOutsideMean = not na(prevEngineAbsZ) and prevEngineAbsZ > exitZ

    if absZ >= entryZ
        stretchConfirmCount += 1
    else
        stretchConfirmCount := 0
        stretchStateActive := false

    qualifiedStretch = stretchConfirmCount >= confirmBars
    stretchEvent := qualifiedStretch and integrityOk and not stretchStateActive
    deepEvent := absZ >= deepZ and integrityOk and previousBelowDeep
    reversionEvent := absZ <= exitZ and previousOutsideMean
    blockedEvent := absZ >= entryZ and not integrityOk and previousBelowEntry

    if qualifiedStretch
        stretchStateActive := true

    prevEngineAbsZ := absZ

stateText = samePair ? "Invalid Pair" :
     quoteMismatch ? "Quote Mismatch" :
     absZ >= deepZ ? "Deep Stretch" :
     absZ >= entryZ ? "Stretch" :
     absZ <= exitZ ? "Mean Zone" :
     "Neutral"

stateColor = samePair or quoteMismatch ? bearColor :
     not integrityOk and absZ >= entryZ ? neutralColor :
     dir == 1 and absZ >= entryZ ? bearColor :
     dir == -1 and absZ >= entryZ ? bullColor :
     absZ <= exitZ ? accentColor :
     neutralColor

qualityScore = f_clamp((absZ / math.max(deepZ, 0.01)) * 42.0 + integrityScore * 0.48 + (quoteMismatch or samePair ? -25.0 : 0.0), 0.0, 100.0)
actionText = f_action_text(absZ >= entryZ, absZ >= deepZ, absZ <= exitZ, (not integrityOk and absZ >= entryZ), dirText)
nextText = absZ >= entryZ ? "Mean Zone " + str.tostring(exitZ, "#.##") : "Need |Z| >= " + str.tostring(entryZ, "#.##")
workflowText = not integrityOk and absZ >= entryZ ? "Review Integrity" : absZ >= deepZ ? "Review Deep Stretch" : absZ >= entryZ ? "Track Rotation" : absZ <= exitZ ? "Mean Zone" : "Standby"

// -------------------------------------------------
// Reversion proof (Confirm Rate)
// -------------------------------------------------
var int  revTotal    = 0
var int  revWon       = 0
var bool revPend      = false
var int  revPendLeft  = 0

if confirmedNow
    if revPend
        if absZ <= exitZ
            revTotal += 1
            revWon += 1
            revPend := false
        else
            revPendLeft -= 1
            if revPendLeft <= 0
                revTotal += 1
                revPend := false
    if stretchEvent and not revPend
        revPend := true
        revPendLeft := revWindowBars

float revRate = revTotal > 0 ? revWon / revTotal * 100.0 : na

// -------------------------------------------------
// Chart Labels
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
var array<label> chartLabels = array.new<label>()
var label liveStateTag = na
var label liveScoreTag = na
var label liveIntegrityTag = na
var int lastRotationLabelBar = na
var float lastRotationLabelY = na

f_keep_label(lbl) =>
    array.push(chartLabels, lbl)
    while array.size(chartLabels) > maxChartLabels
        old = array.shift(chartLabels)
        if not na(old)
            label.delete(old)

atr = nz(ta.atr(14), math.max(high - low, syminfo.mintick))

isUp = dir == 1
labelDistance = atr * (deepEvent ? labelOffsetAtr + 0.30 : labelOffsetAtr)
candidateY = isUp ? high + labelDistance : low - labelDistance
barsGapOk = na(lastRotationLabelBar) or (bar_index - lastRotationLabelBar) >= minLabelGapBars
priceGapOk = na(lastRotationLabelY) or math.abs(candidateY - lastRotationLabelY) >= atr * minLabelGapAtr
gapOk = barsGapOk and priceGapOk

densityEventOk = labelDensity == "Minimal" ? (deepEvent and qualityScore >= math.max(minLabelQuality, 78.0)) :
     labelDensity == "Balanced" ? (((deepEvent or stretchEvent) and qualityScore >= minLabelQuality) or (showReversionLabels and reversionEvent)) :
     (((deepEvent or stretchEvent) and qualityScore >= minLabelQuality) or (showReversionLabels and reversionEvent) or blockedEvent)

makeLabel = showLabels and densityEventOk and gapOk
if makeLabel
    y = candidateY
    style = isUp ? label.style_label_down : label.style_label_up
    lblColor = blockedEvent ? neutralColor : deepEvent ? stateColor : stretchEvent ? stateColor : accentColor
    mainTxt = blockedEvent ? "Integrity Block" : deepEvent ? "Deep Stretch" : stretchEvent ? "Stretch" : "Mean Return"
    eventContext = reversionEvent ? pairA + "/" + pairB : dirText
    detailTxt = labelDensity == "Detailed" ? "\n" + eventContext + "\nZ " + str.tostring(zScore, "#.##") + " | Q " + str.tostring(qualityScore, "#") + " | IN " + str.tostring(integrityScore, "#") : "\n" + eventContext + " | Q " + str.tostring(qualityScore, "#")
    newLbl = label.new(bar_index, y, mainTxt + detailTxt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = style,
         color = color.new(lblColor, blockedEvent ? 4 : 0),
         textcolor = headerText,
         size = labelSize,
         tooltip = "Pair rotation label. It marks a z-score stretch, deep stretch, reversion, or integrity-block condition. It is an analytical context marker, not a trade instruction.")
    f_keep_label(newLbl)
    lastRotationLabelBar := bar_index
    lastRotationLabelY := y

if showLiveTags and barstate.islast
    if not na(liveStateTag)
        label.delete(liveStateTag)
    if not na(liveScoreTag)
        label.delete(liveScoreTag)
    if not na(liveIntegrityTag)
        label.delete(liveIntegrityTag)

    tagX = bar_index + liveTagOffsetBars
    tagY1 = close + atr * 1.35
    compactText = pairA + "/" + pairB + "  " + stateText + "  Z " + str.tostring(zScore, "#.##") + "  IN " + str.tostring(integrityScore, "#")
    if liveTagMode == "Compact"
        liveStateTag := label.new(tagX, tagY1, compactText,
             xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left,
             color = color.new(stateColor, 4), textcolor = headerText, size = labelSize)
        liveScoreTag := na
        liveIntegrityTag := na
    else
        tagY2 = tagY1 + atr * 1.05
        tagY3 = tagY2 + atr * 1.05
        liveStateTag := label.new(tagX, tagY1, stateText + " | " + richText,
             xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left,
             color = color.new(stateColor, 4), textcolor = headerText, size = labelSize)
        liveScoreTag := label.new(tagX + 5, tagY2, "Z " + str.tostring(zScore, "#.##") + " | Q " + str.tostring(qualityScore, "#") + "/100",
             xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left,
             color = color.new(accentColor, 4), textcolor = headerText, size = labelSize)
        liveIntegrityTag := label.new(tagX + 10, tagY3, "Integrity " + str.tostring(integrityScore, "#") + "/100",
             xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left,
             color = color.new(integrityOk ? bullColor : neutralColor, 4), textcolor = headerText, size = labelSize)
else if not showLiveTags
    if not na(liveStateTag)
        label.delete(liveStateTag)
        liveStateTag := na
    if not na(liveScoreTag)
        label.delete(liveScoreTag)
        liveScoreTag := na
    if not na(liveIntegrityTag)
        label.delete(liveIntegrityTag)
        liveIntegrityTag := na

tintColor = not integrityOk and absZ >= entryZ ? neutralColor : stateColor
bgcolor(showStateTint and absZ >= entryZ ? color.new(tintColor, 94) : na, title = "Rotation State Tint")

// -------------------------------------------------
// Rotation Trail and Markers
// -------------------------------------------------
trailSide = dir >= 0 ? 1.0 : -1.0
trailY = close + atr * trailOffsetAtr * trailSide
trailColor = not integrityOk and absZ >= entryZ ? color.new(neutralColor, 76) :
     absZ >= deepZ ? color.new(stateColor, 46) :
     absZ >= entryZ ? color.new(stateColor, 62) :
     absZ <= exitZ ? color.new(accentColor, 70) :
     color.new(panelValueD, 86)

plot(showRotationTrail ? trailY : na,
     title = "Rotation Trail",
     color = trailColor,
     linewidth = 1,
     style = plot.style_line)

stateCode = not integrityOk and absZ >= entryZ ? 4 : absZ >= deepZ ? 3 : absZ >= entryZ ? 2 : absZ <= exitZ ? 1 : 0
stateChanged = confirmedNow and stateCode != stateCode[1]

plotshape(showStateMarkers and stateChanged and stateCode == 4,
     title = "Integrity Block Marker",
     style = shape.diamond,
     location = location.abovebar,
     color = color.new(neutralColor, 0),
     size = size.tiny)

plotshape(showStateMarkers and stateChanged and stateCode == 3 and dir >= 0,
     title = "Deep Stretch Rich A",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.new(bearColor, 0),
     size = size.tiny)

plotshape(showStateMarkers and stateChanged and stateCode == 3 and dir < 0,
     title = "Deep Stretch Rich B",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(bullColor, 0),
     size = size.tiny)

plotshape(showStateMarkers and stateChanged and stateCode == 2 and dir >= 0,
     title = "Stretch Rich A",
     style = shape.circle,
     location = location.abovebar,
     color = color.new(bearColor, 0),
     size = size.tiny)

plotshape(showStateMarkers and stateChanged and stateCode == 2 and dir < 0,
     title = "Stretch Rich B",
     style = shape.circle,
     location = location.belowbar,
     color = color.new(bullColor, 0),
     size = size.tiny)

plotshape(showStateMarkers and stateChanged and stateCode == 1,
     title = "Mean Zone Marker",
     style = shape.square,
     location = location.belowbar,
     color = color.new(accentColor, 10),
     size = size.tiny)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelSize = f_size(panelSizeInput)
isLightPanel = panelTheme == "Light"
panelBg = f_panel_bg(isLightPanel, false)
panelAltBg = f_panel_bg(isLightPanel, true)
panelBorder = isLightPanel ? panelBorderL : panelBorderD
panelLabelCol = f_panel_label(isLightPanel)
panelValueCol = f_panel_value(isLightPanel)

var table panel = na
var string lastPanelPosition = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false

panelNeedsRebuild = showPanel and (na(panel) or lastPanelPosition != panelPosition or lastPanelTheme != panelTheme or not lastPanelVisible)

if panelNeedsRebuild
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPosition), 2, 9, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Pair Rotation Z-Score", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelPosition := panelPosition
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 0, 1, 8)
    table.merge_cells(panel, 0, 0, 1, 0)

    actionBg = not integrityOk and absZ >= entryZ ? neutralColor : absZ >= entryZ ? stateColor : panelAltBg
    actionTxtCol = absZ >= entryZ ? headerText : panelValueCol
    revRateText = revTotal > 0 ? str.tostring(int(math.round(revRate))) + "% (" + str.tostring(revTotal) + ")" : "Building"
    revRateCol = na(revRate) ? panelValueCol : revRate >= 60.0 ? bullColor : revRate >= 45.0 ? neutralColor : bearColor

    table.cell(panel, 0, 0, "AG Pro Pair Rotation Z-Score", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)

    table.cell(panel, 0, 1, "Workflow", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, workflowText, text_color = absZ >= entryZ ? stateColor : panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "Pair", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, pairA + " / " + pairB, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 3, "Action", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, actionText, text_color = actionTxtCol, bgcolor = actionBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "Revert Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, revRateText, text_color = revRateCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 5, "Z / Ratio", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, str.tostring(zScore, "#.##") + " / " + str.tostring(ratio, "#.####"), text_color = panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 6, "Integrity", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, str.tostring(integrityScore, "#") + " / 100  " + f_meter(integrityScore), text_color = integrityOk ? bullColor : neutralColor, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 7, "Quality / State", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, str.tostring(qualityScore, "#") + " / " + stateText, text_color = qualityScore >= 70 ? bullColor : qualityScore >= 45 ? neutralColor : bearColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 8, "Next", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 8, nextText, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(enableAlerts and stretchEvent, "Pair Rotation Stretch", "Swap Engine: pair rotation stretch detected. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and deepEvent, "Pair Rotation Deep Stretch", "Swap Engine: deep pair rotation stretch detected. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and reversionEvent, "Pair Rotation Reversion", "Swap Engine: pair ratio reverted toward the mean zone. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and blockedEvent, "Pair Rotation Integrity Block", "Swap Engine: stretch detected but integrity gate blocked the event. This is an attention marker, not a trade instruction.")

// Hidden alert/reference plots
plot(zScore, "Z-Score", display = display.none)
plot(integrityScore, "Integrity Score", display = display.none)
plot(qualityScore, "Quality Score", display = display.none)
plot(ratio, "Pair Ratio", display = display.none)
plot(revRate, "Revert Rate", display = display.none)
````
