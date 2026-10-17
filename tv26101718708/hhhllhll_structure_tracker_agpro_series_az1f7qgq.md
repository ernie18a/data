# HH/HL/LH/LL Structure Tracker [AGPro Series]

- url: https://www.tradingview.com/script/aZ1F7qGQ-HH-HL-LH-LL-Structure-Tracker-AGPro-Series/
- type: indicator
- pine_id: PUB;7550c13ef59e4d17a0707ba93f7dee55
- version: 4.0

## Description

HH/HL/LH/LL Structure Tracker [AGPro Series]

🔹 Overview

HH/HL/LH/LL Structure Tracker automatically classifies every confirmed swing on your chart using pure Dow Theory — the original price-action framework that precedes and underlies every modern market-structure methodology. Each pivot high is labeled as a Higher High (HH) or Lower High (LH), and each pivot low as a Higher Low (HL) or Lower Low (LL). The sequence of the last four swings derives a live trend state: Bullish, Bearish, or Ranging.

No oscillators. No lagging averages. Just the raw geometry of price.


💎 What Makes This Different

While most "market structure" indicators focus on Break-of-Structure or Change-of-Character logic layered with Smart Money terminology, this script returns to the foundation: the four-swing classification that Charles Dow documented over a century ago. The result is an uncluttered, universally readable overlay that communicates structural context at a glance — regardless of which higher-level methodology you apply next (SMC, Wyckoff, Elliott, or classical technical analysis).

Key differentiators versus generic HH/HL scripts on the public library:

• Live structure range zone that dynamically recolors with the trend state (bullish teal, bearish pink, ranging amber).
• Bull Streak and Bear Streak counters — a quantifiable measure of trend persistence (e.g. "3 consecutive HH-HL swings").
• Semantic break classification: the panel distinguishes a continuation break (HH or LL broken in trend direction) from a reversal break (LH or HL broken against the prior structure).
• Progressive label offset algorithm: when several same-type swings cluster without an intervening opposite swing, each subsequent label is offset further from price, eliminating the overlap that plagues most swing scripts on fast-moving charts.
• AGPro design language: premium info panel, adjustable font size and theme, and a disciplined color palette.


🧠 Methodology

1. Pivot detection. A confirmed swing high is a bar whose high exceeds the preceding and following N bars (N = Pivot Length, default 5). Confirmed swing lows mirror the rule. Confirmation occurs N bars after the pivot bar, never repaints.

2. Swing classification. Each new confirmed high is compared to the previous confirmed high. If greater, it is HH; if lesser, LH. Lows are compared to the previous low: greater means HL, lesser means LL.

3. Trend derivation. If the most recent high is HH and the most recent low is HL, the trend state is Bullish. If LH and LL, Bearish. Any mixed sequence (HH + LL, LH + HL) returns Ranging.

4. Structure range zone. A rectangle is drawn between the most recent swing high and most recent swing low. The zone is always current: as new swings confirm, the zone updates in place. Zone color tracks the trend state.

5. Structure break. A close above the most recent swing high (or below the most recent swing low) fires a break event. The type of swing broken is reported — breaking an LH or HL typically precedes a trend reversal; breaking an HH or LL typically signals continuation.


📊 Signals & Alerts

Three optional alert types are available, each using "once per bar close" frequency to prevent intrabar noise:

• New Higher High confirmed — fires when a fresh HH is classified.
• New Lower Low confirmed — fires when a fresh LL is classified.
• Structure break — fires on a close outside the current structure range, labeled as either (reversal signal) or (continuation).

The live info panel reports: Trend state, Bull Streak, Bear Streak, Last High (with type and price), and Last Break (with type and price).


⚙️ Key Inputs

• Pivot Length — sensitivity of swing detection (2 to 50). Lower values capture minor structure; higher values isolate major swings only. Typical: 3–8 intraday, 5–15 swing trading.
• Max Visible Labels — caps the number of historical labels kept on the chart to preserve a premium uncluttered look.
• Label & Panel Font Size — five sizes from Tiny to Huge, default Normal.
• Label Distance from Price (ATR) — base vertical offset of labels from pivot candles.
• Structure Range Zone — toggle, transparency, and border.
• Trend Background Tint — subtle bullish or bearish chart shading.
• Info Panel — toggle, location (six positions), and theme (Dark or Light).
• Alerts — independent toggles for new HH, new LL, and structure break.


🎯 How to Use

Context tool, not a standalone signal generator. Use the trend state to filter entries from your primary methodology: take long setups only while Trend is Bullish and Bull Streak is building, or vice versa. The structure range zone highlights the active battleground between buyers and sellers — trades taken inside the zone are counter-trend by definition, trades taken on a decisive break of the zone align with the emerging new trend.

Reversal breaks (LH or HL broken) are high-information events — they are often the first objective signal that a prevailing trend is losing conviction, ahead of any moving-average cross or momentum divergence. Continuation breaks (HH or LL broken) are confirmation events that validate staying with the trend.

Works on all markets and all timeframes. Particularly effective on liquid instruments with clear structural rhythm: major crypto pairs, FX majors, index futures, and large-cap equities.


⚠️ Limitations & Transparency

• Pivot confirmation requires N bars after the swing; the most recent unconfirmed swing is never labeled.
• In low-volatility sideways regimes, pivot clustering is inevitable — the Pivot Length input should be raised to filter noise on ranging charts.
• The trend state is derived from only the last two swings; it does not account for higher-timeframe context. Pair with a higher-timeframe version of the same script for multi-timeframe confluence.
• Does not provide entry, stop, or target levels. It is a structural framework, not a complete trading system.


📌 Risk Disclosure

This indicator is for educational and analytical purposes only. It does not constitute financial advice, a trading recommendation, or a guarantee of future performance. All trading involves risk of loss. Past structural patterns do not guarantee future outcomes. Always conduct your own due diligence and use appropriate risk management.

## Source Code

````pine
// -------------------------------------------------
// HH/HL/LH/LL Structure Tracker [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// HH/HL/LH/LL Structure Tracker maps confirmed Dow Theory swing structure
// into Higher High, Higher Low, Lower High, and Lower Low states. It tracks
// market structure, swing points, structure breaks, range control, trend
// strength, a self-measured break follow-through rate, and an active structure
// zone. Its owned swing path selectively pairs every visible connector with a
// filled structure badge for a cleaner bullish, bearish, or ranging read.
// -------------------------------------------------

//@version=6
indicator("HH/HL/LH/LL Structure Tracker [AGPro Series]",
     shorttitle = "AG HHLL",
     overlay = true,
     max_labels_count = 220,
     max_lines_count = 220,
     max_boxes_count = 60)

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
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Input groups
// -------------------------------------------------
gCore   = "Structure Detection"
gVisual = "Visual Layer"
gZone   = "Structure Range Zone"
gLabels = "Labels"
gPanel  = "Panel"
gAlerts = "Alerts"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
pivotLen = input.int(5, "Pivot Length", minval = 2, maxval = 50, group = gCore, tooltip = "Lookback/lookforward bars used to confirm swing pivots. Lower values detect faster structure, while higher values isolate major swings.")
atrLen = input.int(14, "ATR Length", minval = 1, maxval = 100, group = gCore, tooltip = "ATR length used for label spacing, zone padding, and structure break labels.")
breakBufferATR = input.float(0.03, "Break Buffer (ATR)", minval = 0.00, maxval = 0.80, step = 0.01, group = gCore, tooltip = "Optional ATR buffer required beyond the last swing high or low before a structure break is confirmed.")
scoreLookback = input.int(8, "Structure Score Lookback", minval = 3, maxval = 30, group = gCore, tooltip = "Number of recent confirmed swings used by the structure quality score.")
proofWindowBars = input.int(6, "Break Proof Window", minval = 2, maxval = 60, group = gCore, tooltip = "After a confirmed structure break, the script waits this many bars and checks whether price continued in the break direction. Feeds the Follow-Through Rate readout in the panel.")

showSwingLabels = input.bool(true, "Show Swing Labels", group = gLabels, tooltip = "Displays HH, HL, LH, and LL labels at confirmed swing points.")
showBreakLabels = input.bool(false, "Show Break Labels", group = gLabels, tooltip = "Displays compact labels when price breaks the latest structure high or low. Disabled by default because the panel already reports the latest break.")
labelDensity = input.string("Minimal", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels, tooltip = "Controls the number of historical structure labels retained on the chart. Minimal is the default publication setting.")
labelTextInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gLabels, tooltip = "Shared text size for every visible chart badge.")
labelOffsetATR = input.float(0.72, "Label Offset (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = gLabels, tooltip = "ATR-based distance between swing labels and pivot candles.")
minLabelBars = input.int(8, "Minimum Bars Between Swing Labels", minval = 1, maxval = 50, group = gLabels, tooltip = "Minimum horizontal spacing between visible swing badges. The structure engine still tracks every confirmed swing.")
minSwingMoveATR = input.float(0.45, "Minimum Visible Swing Move (ATR)", minval = 0.00, maxval = 5.00, step = 0.05, group = gLabels, tooltip = "Filters minor visual swings by requiring an ATR-scaled price move from the last visible swing. Analytical structure tracking remains unchanged.")

showStructureLines = input.bool(true, "Show Owned Swing Path", group = gVisual, tooltip = "Connects only the selectively displayed swing badges. Each visible segment terminates at a filled HH, HL, LH, or LL badge.")
lineWidth = input.int(1, "Structure Line Width", minval = 1, maxval = 4, group = gVisual, tooltip = "Line width used for swing connector lines.")

showZone = input.bool(true, "Show Structure Range Zone", group = gZone, tooltip = "Draws a live zone between the latest confirmed swing high and swing low.")
zoneProjectionBars = input.int(18, "Zone Projection Bars", minval = 2, maxval = 120, group = gZone, tooltip = "How far the active structure range zone projects to the right.")
zoneOpacity = input.int(88, "Zone Transparency", minval = 60, maxval = 96, group = gZone, tooltip = "Transparency used for the structure range zone.")
zonePaddingATR = input.float(0.05, "Zone Padding (ATR)", minval = 0.00, maxval = 0.80, step = 0.01, group = gZone, tooltip = "Small ATR padding added above and below the structure zone.")

showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = "Displays the AG Pro structure summary panel.")
panelPos = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = gPanel, tooltip = "Panel placement on the chart.")
panelTheme = input.string("Auto", "Panel Theme", options = ["Auto", "Dark", "Light"], group = gPanel, tooltip = "Panel theme. Auto adapts to the chart background.")
panelTextInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gPanel, tooltip = "Text size used inside the panel.")

alertNewHH = input.bool(true, "Alert: Higher High", group = gAlerts, tooltip = "Triggers when a confirmed Higher High appears.")
alertNewLL = input.bool(true, "Alert: Lower Low", group = gAlerts, tooltip = "Triggers when a confirmed Lower Low appears.")
alertStructureBreak = input.bool(true, "Alert: Structure Break", group = gAlerts, tooltip = "Triggers when price closes beyond the latest confirmed swing high or swing low.")
alertTrendFlip = input.bool(true, "Alert: Trend State Flip", group = gAlerts, tooltip = "Triggers when the Dow Theory structure state changes between bullish, bearish, and ranging.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left"     => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_dark_mode(string mode) =>
    lum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
    mode == "Dark" ? true : mode == "Light" ? false : lum < 140

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_trim_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        oldItem = array.shift(items)
        if not na(oldItem)
            label.delete(oldItem)

f_trim_swing_pairs(array<label> labels, array<line> lines, int keep) =>
    while array.size(labels) > keep
        oldLabel = array.shift(labels)
        oldLine = array.shift(lines)
        if not na(oldLabel)
            label.delete(oldLabel)
        if not na(oldLine)
            line.delete(oldLine)

f_type_color(string swingType) =>
    swingType == "HH" or swingType == "HL" ? bullColor : swingType == "LH" or swingType == "LL" ? bearColor : neutralColor

f_trend_color(string trend) =>
    trend == "Bullish" ? bullColor : trend == "Bearish" ? bearColor : neutralColor

f_state_text(string trend) =>
    trend == "Bullish" ? "READY" : trend == "Bearish" ? "MONITOR" : "WAIT"

// -------------------------------------------------
// Core data
// -------------------------------------------------
labelSize = f_size(labelTextInput)
panelSize = f_size(panelTextInput)
atr = nz(ta.atr(atrLen), syminfo.mintick * 20.0)
labelKeep = labelDensity == "Detailed" ? 18 : labelDensity == "Balanced" ? 10 : 6
densityBars = labelDensity == "Detailed" ? math.max(1, int(math.round(minLabelBars * 0.50))) : labelDensity == "Balanced" ? math.max(1, int(math.round(minLabelBars * 0.75))) : minLabelBars
densityMoveATR = labelDensity == "Detailed" ? minSwingMoveATR * 0.35 : labelDensity == "Balanced" ? minSwingMoveATR * 0.70 : minSwingMoveATR
fontLaneATR = labelTextInput == "Huge" ? 0.34 : labelTextInput == "Large" ? 0.25 : labelTextInput == "Normal" ? 0.18 : labelTextInput == "Small" ? 0.12 : 0.08

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

newHighConfirmed = not na(ph)
newLowConfirmed = not na(pl)
pivotHighBar = bar_index - pivotLen
pivotLowBar = bar_index - pivotLen

// -------------------------------------------------
// Persistent state
// -------------------------------------------------
var float lastHighPrice = na
var int lastHighBar = na
var float lastLowPrice = na
var int lastLowBar = na
var float prevHighPrice = na
var float prevLowPrice = na
var string lastHighType = "n/a"
var string lastLowType = "n/a"
var string trendState = "Ranging"
var string lastBreak = "None"
var int barsInTrend = 0
var int sameHighStack = 0
var int sameLowStack = 0
var int lastVisibleSwingBar = na
var float lastVisibleSwingPrice = na
var label[] swingLabels = array.new_label()
var label[] breakLabels = array.new_label()
var line[] structureLines = array.new_line()
var int[] recentSwingScores = array.new_int()
var box zoneBox = na
var label zoneBadge = na

// -------------------------------------------------
// Swing classification
// -------------------------------------------------
if newHighConfirmed
    prevHighPrice := lastHighPrice
    highType = na(prevHighPrice) ? "HH" : ph > prevHighPrice ? "HH" : "LH"
    lastHighType := highType
    lastHighPrice := ph
    lastHighBar := pivotHighBar
    sameHighStack += 1
    sameLowStack := 0
    array.push(recentSwingScores, highType == "HH" ? 1 : -1)
    while array.size(recentSwingScores) > scoreLookback
        array.shift(recentSwingScores)

    visualBarsReady = na(lastVisibleSwingBar) or pivotHighBar - lastVisibleSwingBar >= densityBars
    visualMoveReady = na(lastVisibleSwingPrice) or math.abs(ph - lastVisibleSwingPrice) >= atr * densityMoveATR
    if showSwingLabels and visualBarsReady and visualMoveReady
        line incomingLine = na
        if showStructureLines and not na(lastVisibleSwingBar)
            lnColor = highType == "HH" ? color.new(bullColor, 18) : color.new(bearColor, 18)
            incomingLine := line.new(lastVisibleSwingBar, lastVisibleSwingPrice, pivotHighBar, ph, xloc = xloc.bar_index, extend = extend.none, color = lnColor, width = lineWidth)
        offset = atr * (labelOffsetATR + fontLaneATR + math.min(sameHighStack - 1, 3) * 0.28)
        swingCol = f_type_color(highType)
        lb = label.new(pivotHighBar, ph + offset, highType, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = swingCol, textcolor = f_text_on(swingCol), size = labelSize)
        array.push(swingLabels, lb)
        array.push(structureLines, incomingLine)
        f_trim_swing_pairs(swingLabels, structureLines, labelKeep)
        lastVisibleSwingBar := pivotHighBar
        lastVisibleSwingPrice := ph

if newLowConfirmed
    prevLowPrice := lastLowPrice
    lowType = na(prevLowPrice) ? "HL" : pl > prevLowPrice ? "HL" : "LL"
    lastLowType := lowType
    lastLowPrice := pl
    lastLowBar := pivotLowBar
    sameLowStack += 1
    sameHighStack := 0
    array.push(recentSwingScores, lowType == "HL" ? 1 : -1)
    while array.size(recentSwingScores) > scoreLookback
        array.shift(recentSwingScores)

    visualBarsReady = na(lastVisibleSwingBar) or pivotLowBar - lastVisibleSwingBar >= densityBars
    visualMoveReady = na(lastVisibleSwingPrice) or math.abs(pl - lastVisibleSwingPrice) >= atr * densityMoveATR
    if showSwingLabels and visualBarsReady and visualMoveReady
        line incomingLine = na
        if showStructureLines and not na(lastVisibleSwingBar)
            lnColor = lowType == "HL" ? color.new(bullColor, 18) : color.new(bearColor, 18)
            incomingLine := line.new(lastVisibleSwingBar, lastVisibleSwingPrice, pivotLowBar, pl, xloc = xloc.bar_index, extend = extend.none, color = lnColor, width = lineWidth)
        offset = atr * (labelOffsetATR + fontLaneATR + math.min(sameLowStack - 1, 3) * 0.28)
        swingCol = f_type_color(lowType)
        lb = label.new(pivotLowBar, pl - offset, lowType, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = swingCol, textcolor = f_text_on(swingCol), size = labelSize)
        array.push(swingLabels, lb)
        array.push(structureLines, incomingLine)
        f_trim_swing_pairs(swingLabels, structureLines, labelKeep)
        lastVisibleSwingBar := pivotLowBar
        lastVisibleSwingPrice := pl

if not showSwingLabels and array.size(swingLabels) > 0
    while array.size(swingLabels) > 0
        oldLabel = array.pop(swingLabels)
        oldLine = array.pop(structureLines)
        if not na(oldLabel)
            label.delete(oldLabel)
        if not na(oldLine)
            line.delete(oldLine)
    lastVisibleSwingBar := na
    lastVisibleSwingPrice := na

if not showStructureLines and array.size(structureLines) > 0
    for i = 0 to array.size(structureLines) - 1
        oldLine = array.get(structureLines, i)
        if not na(oldLine)
            line.delete(oldLine)
            array.set(structureLines, i, na)

// -------------------------------------------------
// Trend state and score
// -------------------------------------------------
prevTrend = trendState
if lastHighType == "HH" and lastLowType == "HL"
    trendState := "Bullish"
else if lastHighType == "LH" and lastLowType == "LL"
    trendState := "Bearish"
else
    trendState := "Ranging"

barsInTrend := trendState == prevTrend ? barsInTrend + 1 : 1

scoreSum = 0
scoreCount = array.size(recentSwingScores)
if scoreCount > 0
    for i = 0 to scoreCount - 1
        scoreSum += array.get(recentSwingScores, i)

structureScore = scoreCount > 0 ? int(math.round(math.abs(scoreSum) / scoreCount * 100.0)) : 0
stateText = f_state_text(trendState)
trendCol = f_trend_color(trendState)

// -------------------------------------------------
// Structure break detection
// -------------------------------------------------
breakBuffer = atr * breakBufferATR
brokeHigh = not na(lastHighPrice) and close > lastHighPrice + breakBuffer and close[1] <= lastHighPrice + breakBuffer
brokeLow = not na(lastLowPrice) and close < lastLowPrice - breakBuffer and close[1] >= lastLowPrice - breakBuffer
structureBreak = brokeHigh or brokeLow

if brokeHigh
    lastBreak := "Broke " + lastHighType + " @ " + str.tostring(lastHighPrice, format.mintick)
if brokeLow
    lastBreak := "Broke " + lastLowType + " @ " + str.tostring(lastLowPrice, format.mintick)

if showBreakLabels and structureBreak
    bCol = brokeHigh ? bullColor : bearColor
    bText = brokeHigh ? "Break High" : "Break Low"
    bY = brokeHigh ? high + atr * (labelOffsetATR + 0.35) : low - atr * (labelOffsetATR + 0.35)
    bStyle = brokeHigh ? label.style_label_down : label.style_label_up
    bLabel = label.new(bar_index, bY, bText, xloc = xloc.bar_index, yloc = yloc.price, style = bStyle, color = color.new(bCol, 0), textcolor = f_text_on(bCol), size = labelSize)
    array.push(breakLabels, bLabel)
    f_trim_labels(breakLabels, labelDensity == "Detailed" ? 12 : labelDensity == "Balanced" ? 7 : 4)

if not showBreakLabels and array.size(breakLabels) > 0
    while array.size(breakLabels) > 0
        oldBreak = array.pop(breakLabels)
        label.delete(oldBreak)

// -------------------------------------------------
// Break Follow-Through Rate (Proof Pass)
// -------------------------------------------------
// After a confirmed structure break, wait proofWindowBars and check whether price
// continued in the break direction. Builds an honest, self-measured follow-through rate.
var int btProofHits = 0
var int btProofTotal = 0
var bool btProofPending = false
var int btProofStart = na
var float btProofEntry = na
var int btProofDir = 0

if barstate.isconfirmed
    if structureBreak and not btProofPending
        btProofPending := true
        btProofStart := bar_index
        btProofEntry := close
        btProofDir := brokeHigh ? 1 : -1
    if btProofPending and not na(btProofStart) and bar_index - btProofStart >= proofWindowBars
        bool btHit = btProofDir > 0 ? close > btProofEntry : close < btProofEntry
        btProofTotal += 1
        if btHit
            btProofHits += 1
        btProofPending := false

float btProofRate = btProofTotal > 0 ? btProofHits / btProofTotal * 100.0 : na
string followText = btProofTotal > 0 ? str.tostring(int(math.round(btProofRate))) + "% (" + str.tostring(btProofHits) + "/" + str.tostring(btProofTotal) + ")" : "Building"
color followCol = btProofTotal == 0 ? neutralColor : btProofRate >= 60.0 ? bullColor : btProofRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Structure range zone (faint fill) + centered solid badge
// -------------------------------------------------
if showZone and not na(lastHighPrice) and not na(lastLowPrice) and not na(lastHighBar) and not na(lastLowBar)
    leftBar = math.min(lastHighBar, lastLowBar)
    rightBar = bar_index + zoneProjectionBars
    topValue = math.max(lastHighPrice, lastLowPrice) + atr * zonePaddingATR
    bottomValue = math.min(lastHighPrice, lastLowPrice) - atr * zonePaddingATR
    zCol = trendCol
    if na(zoneBox)
        zoneBox := box.new(left = leftBar, top = topValue, right = rightBar, bottom = bottomValue, xloc = xloc.bar_index, bgcolor = color.new(zCol, zoneOpacity), border_color = color.new(zCol, 42), border_width = 1)
    else
        box.set_lefttop(zoneBox, leftBar, topValue)
        box.set_rightbottom(zoneBox, rightBar, bottomValue)
        box.set_bgcolor(zoneBox, color.new(zCol, zoneOpacity))
        box.set_border_color(zoneBox, color.new(zCol, 42))

    int badgeX = int(math.round((leftBar + rightBar) / 2.0))
    float badgeY = (topValue + bottomValue) / 2.0
    string badgeText = stateText + " | " + str.upper(trendState) + " | " + str.tostring(structureScore)
    color badgeBg = color.new(zCol, 0)
    if na(zoneBadge)
        zoneBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = badgeBg, textcolor = f_text_on(badgeBg), size = labelSize, textalign = text.align_center)
    else
        label.set_xy(zoneBadge, badgeX, badgeY)
        label.set_text(zoneBadge, badgeText)
        label.set_color(zoneBadge, badgeBg)
        label.set_textcolor(zoneBadge, f_text_on(badgeBg))
        label.set_size(zoneBadge, labelSize)
else
    if not na(zoneBox)
        box.delete(zoneBox)
        zoneBox := na
    if not na(zoneBadge)
        label.delete(zoneBadge)
        zoneBadge := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
darkPanel = f_dark_mode(panelTheme)
panelFrame = darkPanel ? panelBorder : color.rgb(203, 213, 225)
leftBg = darkPanel ? color.rgb(13, 22, 38) : color.rgb(241, 245, 249)
rightBg = darkPanel ? color.rgb(8, 15, 28) : color.rgb(255, 255, 255)
leftTxt = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
rightTxt = darkPanel ? panelValueCol : color.rgb(15, 23, 42)
stateBg = trendState == "Bullish" ? color.new(bullColor, darkPanel ? 24 : 82) : trendState == "Bearish" ? color.new(bearColor, darkPanel ? 24 : 82) : color.new(neutralColor, darkPanel ? 26 : 82)
scoreBg = structureScore >= 70 ? color.new(trendCol, darkPanel ? 28 : 84) : structureScore >= 40 ? color.new(neutralColor, darkPanel ? 30 : 84) : rightBg
lastHighText = lastHighType == "n/a" or na(lastHighPrice) ? "n/a" : lastHighType + " @ " + str.tostring(lastHighPrice, format.mintick)
lastLowText = lastLowType == "n/a" or na(lastLowPrice) ? "n/a" : lastLowType + " @ " + str.tostring(lastLowPrice, format.mintick)

var table panel = na
var string lastPanelPos = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false

panelNeedsReset = na(panel) or panelPos != lastPanelPos or panelTheme != lastPanelTheme or showPanel != lastPanelVisible
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    if showPanel
        panel := table.new(f_panel_pos(panelPos), 2, 9, frame_color = panelFrame, border_color = panelFrame, border_width = 1)
        table.cell(panel, 0, 0, "AG Pro HH/HL/LH/LL Structure Tracker", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(panel, 0, 0, 1, 0)
    else
        panel := na
    lastPanelPos := panelPos
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, 8)
    table.cell(panel, 0, 0, "AG Pro HH/HL/LH/LL Structure Tracker", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 0, 1, "State", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 1, stateText, text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = panelSize)
    table.cell(panel, 0, 2, "Trend", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 2, trendState, text_color = trendCol, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 3, "Structure Score", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 3, str.tostring(structureScore) + "/100", text_color = structureScore >= 40 ? f_text_on(scoreBg) : rightTxt, bgcolor = scoreBg, text_size = panelSize)
    table.cell(panel, 0, 4, "Follow-Through", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 4, followText, text_color = followCol, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 5, "Bars in State", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 5, str.tostring(barsInTrend), text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 6, "Last High", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 6, lastHighText, text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 7, "Last Low", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 7, lastLowText, text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 8, "Last Break", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 8, lastBreak, text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
newHH = newHighConfirmed and lastHighType == "HH"
newLL = newLowConfirmed and lastLowType == "LL"
trendFlip = trendState != prevTrend

alertcondition(alertNewHH and newHH, "New Higher High", "HH/HL/LH/LL Structure Tracker: a confirmed Higher High has appeared.")
alertcondition(alertNewLL and newLL, "New Lower Low", "HH/HL/LH/LL Structure Tracker: a confirmed Lower Low has appeared.")
alertcondition(alertStructureBreak and structureBreak, "Structure Break", "HH/HL/LH/LL Structure Tracker: price closed beyond the latest confirmed structure boundary.")
alertcondition(alertTrendFlip and trendFlip, "Trend State Flip", "HH/HL/LH/LL Structure Tracker: Dow Theory structure state changed.")
````
