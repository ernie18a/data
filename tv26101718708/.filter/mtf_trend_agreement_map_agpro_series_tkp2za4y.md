# MTF Trend Agreement Map [AGPro Series]

- url: https://www.tradingview.com/script/TKp2zA4y-MTF-Trend-Agreement-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;6f5fa540ecfa4f62a70b0dda190ddcec
- version: 5.0

## Description

MTF Trend Agreement Map [AGPro Series]

🔹 **Overview**

MTF Trend Agreement Map is a multi-timeframe alignment engine that reads the trend across five timeframes at once and distills the result into a single transparent agreement score. Instead of forcing you to flip between charts, the map tells you, on every bar, how many timeframes agree, which side wins, and whether the market is in a locked regime, a forming trend, or a conflict phase. It is built for swing traders, HTF-bias scalpers, position traders, and anyone who uses top-down analysis as part of their process.

🔸 **What Makes It Different**

Most MTF indicators show a single method (usually a moving-average cross) repeated across timeframes, which means five rows that all agree with each other by construction. This map does something different: for each timeframe it runs three independent methods — an EMA regime filter, a pivot-based market-structure read (HH/HL vs LH/LL), and a normalized momentum slope — and blends their individual votes into the final score. You see not only the agreement across timeframes but also the agreement across methods, which exposes weak or borderline regimes that a single-method tool would quietly hide.

🔺 **Methodology**

• EMA Trend: a timeframe is bullish when EMA50 is above EMA200 and price is above EMA50; bearish on the mirror condition; neutral otherwise.
• Market Structure: confirmed pivots are tracked in real time. A timeframe is bullish while the last two confirmed swings form higher highs and higher lows, bearish on lower highs and lower lows.
• Momentum Slope: the change in linear regression across a configurable lookback, normalized by ATR so that fast and slow assets are comparable.
• Consensus per timeframe: each active method casts a vote; bulls minus bears determines the row's net direction and strength.
• Overall alignment: bull and bear votes are summed across all active timeframes; the dominant side's share defines the agreement percentage.

◆ **Three-State Regime Engine**

• **LOCKED** — agreement above the strong threshold (default 80%). High-conviction regime, continuation-friendly, background tint activates.
• **TRENDING** — agreement between 50% and the strong threshold. Directional bias forming but not yet fully aligned. Trade with reduced size or wait for confirmation.
• **SPLIT** — agreement below 50%. Timeframes are in conflict, no majority side. Classic chop phase, favors mean-reversion strategies or standing aside.

🔔 **Signals & Alerts**

• Regime Lock (Bull or Bear): fires the first bar agreement crosses above the strong threshold while one side dominates. Designed as a continuation trigger, not a reversal signal.
• Chop / Conflict: fires when no side holds the majority, a classic filter for mean-reversion systems or a stand-aside cue for trend traders.
• Both generic and directional alertcondition() hooks are exposed so you can wire the map into automations.

⚙️ **Key Inputs**

• Core Engine: toggle any of the three methods on or off, and tune the pivot length and momentum lookback independently.
• Timeframes: four user-selected timeframes plus an optional Current row that auto-adapts to the chart TF. If the chart TF matches any selected TF, the Current row is hidden automatically to avoid double-counting.
• Panel: six location presets, four text sizes (default Normal), dark or light theme, optional per-method breakdown row.
• Background Tint: enable or disable, set the strong-alignment threshold (50–95%) and control transparency (70–99) to keep the chart premium.

📖 **How to Use**

• Top-down confirmation: take trades on your execution timeframe only when the higher rows in the map agree with your thesis.
• Regime filter: enable Regime Lock alerts to catch moments when the full map snaps into alignment — these are typical continuation windows.
• Conflict filter: when the map prints SPLIT, widen stops, reduce size, or step aside; trend strategies historically underperform during these phases.
• Method debugging: turn on the per-method breakdown to see which methods are driving the score and which are fighting it.

⚠️ **Limitations & Transparency**

• All timeframe values are non-repainting at bar close (lookahead is disabled), but intrabar values can update until the parent bar closes — this is expected MTF behavior.
• Market Structure requires enough history on each timeframe to confirm two swings; on very young assets or short charts the structure vote may be neutral until pivots print.
• The map is a context tool, not a standalone entry system — combine it with your own execution logic, risk management, and bias.

📌 **Risk Disclosure**

This script is provided for educational and analytical purposes only. It does not constitute financial advice, a recommendation, or a solicitation to trade any instrument. Markets involve substantial risk and past behavior does not guarantee future results. Always do your own research and manage risk responsibly.

## Source Code

````pine
// -------------------------------------------------
// MTF Trend Agreement Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// MTF Trend Agreement Map blends EMA regime, Dow-style market structure,
// and momentum slope across multiple timeframes into a transparent trend
// alignment score. It helps identify locked trend regimes, mixed conditions,
// and multi-timeframe conflict by combining timeframe votes, agreement states,
// an on-chart agreement ribbon, live agreement tags, and a compact AG Pro
// panel. V1.7 adds a lock-follow-rate proof that shows how often locked
// regimes historically kept moving in the dominant direction, and improves
// label contrast on the lighter agreement badges. It is an analytical
// visualization tool, not a prediction engine.
// V1.8 refreshes the publication presentation only. Core calculations, alerts,
// inputs and runtime behavior remain unchanged.
// -------------------------------------------------

//@version=6
indicator("MTF Trend Agreement Map [AGPro Series]",
     shorttitle = "AG MTF",
     overlay = true,
     max_labels_count = 180,
     max_lines_count = 80,
     max_boxes_count = 40)

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
gCore   = "Core Engine"
gTF     = "Timeframes"
gVisual = "Visual Layer"
gLabels = "Labels"
gPanel  = "Panel"
gAlerts = "Alerts"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
useEMA = input.bool(true, "EMA Trend Method", group = gCore, tooltip = "Uses EMA 50 versus EMA 200 plus price position relative to EMA 50 as a classic regime vote.")
useBOS = input.bool(true, "Market Structure Method", group = gCore, tooltip = "Uses confirmed swing structure to classify each timeframe as bullish, bearish, or neutral.")
useMom = input.bool(true, "Momentum Slope Method", group = gCore, tooltip = "Uses normalized linear-regression slope to capture acceleration and deceleration.")
pivotLen = input.int(5, "Structure Pivot Length", minval = 2, maxval = 30, group = gCore, tooltip = "Pivot confirmation length used by the market structure method.")
momLen = input.int(20, "Momentum Lookback", minval = 5, maxval = 100, group = gCore, tooltip = "Lookback used by the momentum slope method.")
strongTh = input.int(80, "Strong Alignment Threshold", minval = 55, maxval = 95, group = gCore, tooltip = "Agreement percentage required for a locked regime state.")
chopTh = input.int(50, "Conflict Threshold", minval = 35, maxval = 60, group = gCore, tooltip = "Agreement below this value is treated as split or conflict.")
lockWindow = input.int(20, "Lock Follow Proof Window (bars)", minval = 5, maxval = 200, group = gCore, tooltip = "Number of bars a locked regime has to follow through in the dominant direction within, for the Lock Follow Rate proof. It only measures historical follow-through and is not a forecast.")

tf1 = input.timeframe("15", "Timeframe 1", group = gTF, tooltip = "First tracked timeframe.")
tf2 = input.timeframe("60", "Timeframe 2", group = gTF, tooltip = "Second tracked timeframe.")
tf3 = input.timeframe("240", "Timeframe 3", group = gTF, tooltip = "Third tracked timeframe.")
tf4 = input.timeframe("1D", "Timeframe 4", group = gTF, tooltip = "Fourth tracked timeframe.")
showCurrent = input.bool(true, "Include Current Chart TF", group = gTF, tooltip = "Adds the active chart timeframe unless it duplicates one of the selected rows.")

showRibbon = input.bool(true, "Show Agreement Ribbon", group = gVisual, tooltip = "Displays a price-mapped ribbon that follows the active multi-timeframe regime.")
ribbonBasisLen = input.int(34, "Ribbon Basis Length", minval = 5, maxval = 200, group = gVisual, tooltip = "EMA basis used to map the agreement ribbon onto price.")
ribbonOffsetATR = input.float(0.55, "Ribbon Offset (ATR)", minval = 0.05, maxval = 3.00, step = 0.05, group = gVisual, tooltip = "ATR offset used to separate the agreement ribbon from the chart basis.")
showRibbonFill = input.bool(true, "Show Ribbon Fill", group = gVisual, tooltip = "Fills the space between the ribbon basis and agreement ribbon.")
showLiveTag = input.bool(true, "Show Live Agreement Tag", group = gVisual, tooltip = "Shows a right-edge tag with the current agreement state and score.")
liveTagOffsetBars = input.int(14, "Live Tag Offset (bars)", minval = 3, maxval = 60, group = gVisual, tooltip = "Horizontal offset used to place the live agreement tag to the right of the latest bar.")
showBackground = input.bool(false, "Tint Background by Agreement", group = gVisual, tooltip = "Applies a subtle background tint during aligned trend regimes.")
backgroundTransparency = input.int(94, "Background Transparency", minval = 80, maxval = 99, group = gVisual, tooltip = "Transparency used by the optional background tint.")
showBarTint = input.bool(false, "Tint Bars by Agreement", group = gVisual, tooltip = "Applies a subtle candle tint according to the current multi-timeframe agreement state.")

showRegimeLabels = input.bool(true, "Show Regime Labels", group = gLabels, tooltip = "Prints compact labels when the map enters locked, trending, or split states.")
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels, tooltip = "Controls how many regime labels are retained on the chart.")
labelTextInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels, tooltip = "Text size for chart labels and live agreement tags.")
labelOffsetATR = input.float(0.86, "Label Offset (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = gLabels, tooltip = "ATR-based spacing used for regime labels.")
minLabelBars = input.int(14, "Minimum Bars Between Labels", minval = 1, maxval = 100, group = gLabels, tooltip = "Minimum bar spacing between printed regime labels.")
minLabelGapATR = input.float(1.35, "Minimum Label Price Gap (ATR)", minval = 0.20, maxval = 6.00, step = 0.05, group = gLabels, tooltip = "Minimum vertical distance between regime labels. Higher values reduce label clustering around the same price area.")

showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = "Displays the AG Pro multi-timeframe agreement panel.")
panelPos = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = gPanel, tooltip = "Panel placement on the chart.")
panelTheme = input.string("Auto", "Panel Theme", options = ["Auto", "Dark", "Light"], group = gPanel, tooltip = "Panel theme. Auto adapts to the chart background.")
panelTextInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel, tooltip = "Text size used inside the panel.")
showMethodSummary = input.bool(false, "Show Method Summary", group = gPanel, tooltip = "Adds a compact method vote summary to the panel.")

alertLock = input.bool(true, "Alert: Regime Lock", group = gAlerts, tooltip = "Triggers when agreement enters a locked bull or bear regime.")
alertConflict = input.bool(true, "Alert: Conflict", group = gAlerts, tooltip = "Triggers when agreement enters a split or conflict state.")
alertBiasFlip = input.bool(true, "Alert: Bias Flip", group = gAlerts, tooltip = "Triggers when the dominant multi-timeframe side flips.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
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

f_label_text(color stateCol) =>
    stateCol == neutralColor ? darkText : headerText

f_trim_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        oldItem = array.shift(items)
        if not na(oldItem)
            label.delete(oldItem)

f_tf_label(string tfStr) =>
    string result = tfStr
    if str.contains(tfStr, "D") or str.contains(tfStr, "W") or str.contains(tfStr, "M") or str.contains(tfStr, "S")
        result := tfStr
    else
        numVal = str.tonumber(tfStr)
        if not na(numVal)
            mins = int(math.round(numVal))
            result := mins >= 1440 and mins % 1440 == 0 ? str.tostring(mins / 1440) + "D" : mins >= 60 and mins % 60 == 0 ? str.tostring(mins / 60) + "H" : str.tostring(mins) + "m"
    result

f_side_color(int side) =>
    side > 0 ? bullColor : side < 0 ? bearColor : neutralColor

f_side_text(int side) =>
    side > 0 ? "Bull" : side < 0 ? "Bear" : "Flat"

f_state_text(bool conflict, bool locked, int side) =>
    conflict ? "Split" : locked ? "Locked" : side > 0 ? "Trending" : side < 0 ? "Trending" : "Wait"

f_workflow_text(bool conflict, bool locked, int side) =>
    conflict ? "Review Conflict" : locked ? "Track Locked Trend" : side != 0 ? "Track Alignment" : "Standby"

// -------------------------------------------------
// Trend methods
// -------------------------------------------------
f_ema_trend() =>
    ema50 = ta.ema(close, 50)
    ema200 = ta.ema(close, 200)
    up = ema50 > ema200 and close > ema50
    dn = ema50 < ema200 and close < ema50
    up ? 1 : dn ? -1 : 0

f_struct_trend(int piv) =>
    ph = ta.pivothigh(high, piv, piv)
    pl = ta.pivotlow(low, piv, piv)
    var float lastPH = na
    var float prevPH = na
    var float lastPL = na
    var float prevPL = na
    if not na(ph)
        prevPH := lastPH
        lastPH := ph
    if not na(pl)
        prevPL := lastPL
        lastPL := pl
    hh = not na(lastPH) and not na(prevPH) and lastPH > prevPH
    hl = not na(lastPL) and not na(prevPL) and lastPL > prevPL
    lh = not na(lastPH) and not na(prevPH) and lastPH < prevPH
    ll = not na(lastPL) and not na(prevPL) and lastPL < prevPL
    hh and hl ? 1 : lh and ll ? -1 : 0

f_mom_trend(int len) =>
    slope = ta.linreg(close, len, 0) - ta.linreg(close, len, 1)
    atrLocal = ta.atr(len)
    norm = atrLocal > 0 ? slope / atrLocal : 0.0
    norm > 0.05 ? 1 : norm < -0.05 ? -1 : 0

f_consensus(int emaV, int bosV, int momV) =>
    int bulls = 0
    int bears = 0
    int total = 0
    if useEMA
        total += 1
        bulls += emaV > 0 ? 1 : 0
        bears += emaV < 0 ? 1 : 0
    if useBOS
        total += 1
        bulls += bosV > 0 ? 1 : 0
        bears += bosV < 0 ? 1 : 0
    if useMom
        total += 1
        bulls += momV > 0 ? 1 : 0
        bears += momV < 0 ? 1 : 0
    net = bulls - bears
    [bulls, bears, total, net]

// -------------------------------------------------
// Multi-timeframe requests
// -------------------------------------------------
[e1, s1, m1] = request.security(syminfo.tickerid, tf1, [f_ema_trend(), f_struct_trend(pivotLen), f_mom_trend(momLen)], lookahead = barmerge.lookahead_off)
[e2, s2, m2] = request.security(syminfo.tickerid, tf2, [f_ema_trend(), f_struct_trend(pivotLen), f_mom_trend(momLen)], lookahead = barmerge.lookahead_off)
[e3, s3, m3] = request.security(syminfo.tickerid, tf3, [f_ema_trend(), f_struct_trend(pivotLen), f_mom_trend(momLen)], lookahead = barmerge.lookahead_off)
[e4, s4, m4] = request.security(syminfo.tickerid, tf4, [f_ema_trend(), f_struct_trend(pivotLen), f_mom_trend(momLen)], lookahead = barmerge.lookahead_off)
eC = f_ema_trend()
sC = f_struct_trend(pivotLen)
mC = f_mom_trend(momLen)

[bu1, be1, to1, nd1] = f_consensus(e1, s1, m1)
[bu2, be2, to2, nd2] = f_consensus(e2, s2, m2)
[bu3, be3, to3, nd3] = f_consensus(e3, s3, m3)
[bu4, be4, to4, nd4] = f_consensus(e4, s4, m4)
[buC, beC, toC, ndC] = f_consensus(eC, sC, mC)

currentDup = timeframe.period == tf1 or timeframe.period == tf2 or timeframe.period == tf3 or timeframe.period == tf4
showCurrentRow = showCurrent and not currentDup

totalBulls = bu1 + bu2 + bu3 + bu4 + (showCurrentRow ? buC : 0)
totalBears = be1 + be2 + be3 + be4 + (showCurrentRow ? beC : 0)
totalSlots = to1 + to2 + to3 + to4 + (showCurrentRow ? toC : 0)

dominantVotes = math.max(totalBulls, totalBears)
agreementPct = totalSlots > 0 ? dominantVotes * 100.0 / totalSlots : 0.0
dominantSide = totalBulls > totalBears ? 1 : totalBears > totalBulls ? -1 : 0
isConflict = dominantSide == 0 or agreementPct < chopTh
strongLock = agreementPct >= strongTh and not isConflict
stateText = f_state_text(isConflict, strongLock, dominantSide)
biasText = isConflict ? "Mixed" : dominantSide > 0 ? "Bullish" : "Bearish"
workflowText = f_workflow_text(isConflict, strongLock, dominantSide)
stateColor = isConflict ? neutralColor : dominantSide > 0 ? bullColor : bearColor
stateScore = int(math.round(agreementPct))

// -------------------------------------------------
// Visual layer
// -------------------------------------------------
labelSize = f_size(labelTextInput)
atr = nz(ta.atr(14), syminfo.mintick * 20.0)
basis = ta.ema(close, ribbonBasisLen)
dirOffset = isConflict ? 0.0 : dominantSide * atr * ribbonOffsetATR * (0.35 + agreementPct / 100.0 * 0.65)
ribbon = showRibbon ? basis + dirOffset : na
ribbonTop = showRibbon and not isConflict ? ribbon + atr * 0.10 : na
ribbonBot = showRibbon and not isConflict ? ribbon - atr * 0.10 : na
ribbonAlpha = strongLock ? 8 : isConflict ? 55 : 20
fillAlpha = strongLock ? 84 : isConflict ? 96 : 90

pBasis = plot(showRibbon ? basis : na, "Agreement Basis", color = color.new(panelBorder, 80), linewidth = 1)
pRibbon = plot(ribbon, "Agreement Ribbon", color = color.new(stateColor, ribbonAlpha), linewidth = 3)
pTop = plot(ribbonTop, "Ribbon Upper Edge", color = color.new(stateColor, 100), linewidth = 1)
pBot = plot(ribbonBot, "Ribbon Lower Edge", color = color.new(stateColor, 100), linewidth = 1)
fill(pBasis, pRibbon, color = showRibbon and showRibbonFill ? color.new(stateColor, fillAlpha) : na, title = "Agreement Ribbon Fill")
fill(pTop, pBot, color = showRibbon and showRibbonFill ? color.new(stateColor, 90) : na, title = "Agreement Core Fill")

bgcolor(showBackground and not isConflict ? color.new(stateColor, backgroundTransparency) : na, title = "Agreement Background")
barcolor(showBarTint ? color.new(stateColor, isConflict ? 86 : strongLock ? 72 : 80) : na)

// -------------------------------------------------
// Lock follow-rate proof (Confirm Rate)
// -------------------------------------------------
var int   lockTotal  = 0
var int   lockWon     = 0
var bool  lockPend    = false
var int   lockDir     = 0
var float lockAnchor  = na
var int   lockLeft    = 0
float lockMargin = atr * 0.75
bool prevStrongLockProof = bar_index > 0 ? strongLock[1] : false
bool justLockedProof = strongLock and not prevStrongLockProof

if barstate.isconfirmed
    if lockPend and not na(lockAnchor)
        bool favHit = lockDir == 1 ? close >= lockAnchor + lockMargin : close <= lockAnchor - lockMargin
        bool advHit = lockDir == 1 ? close <= lockAnchor - lockMargin : close >= lockAnchor + lockMargin
        if favHit
            lockTotal += 1
            lockWon += 1
            lockPend := false
        else if advHit
            lockTotal += 1
            lockPend := false
        else
            lockLeft -= 1
            if lockLeft <= 0
                lockTotal += 1
                lockPend := false
    if justLockedProof and dominantSide != 0 and not lockPend
        lockPend := true
        lockDir := dominantSide
        lockAnchor := close
        lockLeft := lockWindow

float lockRate = lockTotal > 0 ? lockWon / lockTotal * 100.0 : na

// -------------------------------------------------
// Regime labels and live tag
// -------------------------------------------------
var label[] regimeLabels = array.new_label()
var int lastLabelBar = na
var float lastLabelY = na
var label liveTag = na
labelKeep = labelDensity == "Detailed" ? 10 : labelDensity == "Balanced" ? 5 : 3
stateKey = isConflict ? 0 : strongLock ? dominantSide * 2 : dominantSide
stateChanged = stateKey != nz(stateKey[1], 999)
labelY = dominantSide >= 0 ? high + atr * labelOffsetATR : low - atr * labelOffsetATR
barsOk = na(lastLabelBar) or bar_index - lastLabelBar >= minLabelBars
priceOk = na(lastLabelY) or math.abs(labelY - lastLabelY) >= atr * minLabelGapATR or bar_index - nz(lastLabelBar, bar_index) > minLabelBars * 3
majorState = strongLock or isConflict or labelDensity == "Detailed"
canPrintLabel = barsOk and priceOk and majorState

if showRegimeLabels and stateChanged and canPrintLabel
    labelStyle = dominantSide >= 0 ? label.style_label_down : label.style_label_up
    labelText = stateText + "\n" + biasText + "\nScore " + str.tostring(stateScore) + "/100"
    lb = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(stateColor, 0), textcolor = f_label_text(stateColor), size = labelSize, textalign = text.align_center)
    array.push(regimeLabels, lb)
    f_trim_labels(regimeLabels, labelKeep)
    lastLabelBar := bar_index
    lastLabelY := labelY

if showLiveTag and barstate.islast
    tagX = bar_index + liveTagOffsetBars
    tagY = isConflict or not showRibbon ? basis : ribbon
    liveText = stateText + " " + biasText + "\nAgreement " + str.tostring(stateScore) + "/100"
    if na(liveTag)
        liveTag := label.new(tagX, tagY, liveText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 0), textcolor = f_label_text(stateColor), size = labelSize, textalign = text.align_center)
    else
        label.set_xy(liveTag, tagX, tagY)
        label.set_text(liveTag, liveText)
        label.set_color(liveTag, color.new(stateColor, 0))
        label.set_textcolor(liveTag, f_label_text(stateColor))
        label.set_size(liveTag, labelSize)
else if not showLiveTag
    if not na(liveTag)
        label.delete(liveTag)
        liveTag := na

// -------------------------------------------------
// Panel helpers
// -------------------------------------------------
f_row_text(int bulls, int bears, int total, int net) =>
    pct = total > 0 ? math.max(bulls, bears) * 100.0 / total : 0.0
    side = f_side_text(net)
    side + " " + (net == 0 ? "N/A" : str.tostring(pct, "#") + "%")

darkPanel = f_dark_mode(panelTheme)
panelFrame = darkPanel ? panelBorder : color.rgb(203, 213, 225)
leftBg = darkPanel ? color.rgb(13, 22, 38) : color.rgb(241, 245, 249)
rightBg = darkPanel ? color.rgb(8, 15, 28) : color.rgb(255, 255, 255)
altBg = darkPanel ? color.rgb(24, 35, 55) : color.rgb(241, 245, 249)
leftTxt = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
rightTxt = darkPanel ? panelValueCol : color.rgb(15, 23, 42)
stateBg = isConflict ? color.new(neutralColor, darkPanel ? 20 : 0) : strongLock ? color.new(accentColor, darkPanel ? 18 : 0) : color.new(stateColor, darkPanel ? 20 : 0)
scoreBg = agreementPct >= strongTh ? color.new(accentColor, darkPanel ? 22 : 0) : agreementPct >= chopTh ? color.new(stateColor, darkPanel ? 24 : 0) : color.new(neutralColor, darkPanel ? 24 : 0)
lockRateBg = na(lockRate) ? altBg : color.new(lockRate >= 60.0 ? bullColor : lockRate >= 45.0 ? neutralColor : bearColor, darkPanel ? 24 : 0)
lockRateText = lockTotal > 0 ? str.tostring(math.round(lockRate)) + "% (" + str.tostring(lockTotal) + ")" : "Building"
panelSize = f_size(panelTextInput)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na
var string lastPanelPos = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false
var bool lastMethodSummary = false

panelRows = 10
panelNeedsReset = na(panel) or panelPos != lastPanelPos or panelTheme != lastPanelTheme or showPanel != lastPanelVisible or showMethodSummary != lastMethodSummary
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    if showPanel
        panel := table.new(f_panel_pos(panelPos), 2, panelRows, frame_color = panelFrame, border_color = panelFrame, border_width = 1)
        table.cell(panel, 0, 0, "AG Pro MTF Trend Agreement Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(panel, 0, 0, 1, 0)
    else
        panel := na
    lastPanelPos := panelPos
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel
    lastMethodSummary := showMethodSummary

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, 9)
    table.cell(panel, 0, 0, "AG Pro MTF Trend Agreement Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 0, 1, "Workflow", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, workflowText, text_color = stateColor, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "State", text_color = leftTxt, bgcolor = altBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, stateText + " / " + biasText, text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Agreement", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(stateScore) + "/100", text_color = f_text_on(scoreBg), bgcolor = scoreBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Lock Follow Rate", text_color = leftTxt, bgcolor = altBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, lockRateText, text_color = na(lockRate) ? rightTxt : f_text_on(lockRateBg), bgcolor = lockRateBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, f_tf_label(tf1) + " / " + f_tf_label(tf2), text_color = leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, f_row_text(bu1, be1, to1, nd1) + " / " + f_row_text(bu2, be2, to2, nd2), text_color = rightTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 6, f_tf_label(tf3) + " / " + f_tf_label(tf4), text_color = leftTxt, bgcolor = altBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, f_row_text(bu3, be3, to3, nd3) + " / " + f_row_text(bu4, be4, to4, nd4), text_color = rightTxt, bgcolor = altBg, text_size = panelSize, text_halign = text.align_right)
    currentText = showCurrentRow ? f_row_text(buC, beC, toC, ndC) : "Skipped Duplicate"
    table.cell(panel, 0, 7, "Current TF", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, currentText, text_color = showCurrentRow ? f_side_color(ndC) : leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 8, "Review", text_color = leftTxt, bgcolor = altBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 8, stateText + "\n" + biasText + " / Score " + str.tostring(stateScore), text_color = stateColor, bgcolor = altBg, text_size = panelSize, text_halign = text.align_right)
    if showMethodSummary
        methodText = (useEMA ? "EMA " : "") + (useBOS ? "Structure " : "") + (useMom ? "Momentum" : "")
        table.cell(panel, 0, 9, "Methods", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 9, methodText, text_color = rightTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
prevStrongLock = bar_index > 0 ? strongLock[1] : false
prevConflict = bar_index > 0 ? isConflict[1] : false
justLocked = strongLock and not prevStrongLock
justConflict = isConflict and not prevConflict
biasFlip = dominantSide != 0 and dominantSide != nz(dominantSide[1], 0)

alertcondition(alertLock and justLocked and dominantSide > 0, "Bull Regime Lock", "MTF Trend Agreement Map: bullish regime lock detected.")
alertcondition(alertLock and justLocked and dominantSide < 0, "Bear Regime Lock", "MTF Trend Agreement Map: bearish regime lock detected.")
alertcondition(alertConflict and justConflict, "MTF Conflict", "MTF Trend Agreement Map: timeframe agreement has entered conflict.")
alertcondition(alertBiasFlip and biasFlip, "MTF Bias Flip", "MTF Trend Agreement Map: dominant multi-timeframe side changed.")

// Hidden reference plot
plot(lockRate, "Lock Follow Rate", display = display.none)
````
