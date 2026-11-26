# Fixed Range Control Box [AGPro Series]

- url: https://www.tradingview.com/script/sdh6Puw6-Fixed-Range-Control-Box-AGPro-Series/
- type: indicator
- pine_id: PUB;8512696b85ad433a89e2ce28354c191e
- version: 4.0

## Description

Fixed Range Control Box [AGPro Series]

🔹 Overview

Fixed Range Control Box isolates a single high-conviction price range on your chart and classifies who is in control inside it. The tool draws one clean hero box around the most recent structural range, places a volume-weighted Control Line inside it, and tracks state transitions in real time: Inside, Upper, Lower, or Failed. When price structurally breaks the box, the range freezes, locking the reference so you can study the aftermath without visual drift.

Four range-definition modes are available — Pivot, Lookback, Compression, and Manual-Date — so the tool adapts to discretionary range traders, systematic rotation traders, and anyone who wants a fixed reference zone for backtesting or journaling.

🔸 Unique Edge

Most range tools on TradingView draw many boxes and leave the user to guess which one matters. Fixed Range Control Box is built around a different philosophy: one range, one story, one decision. The hero box is the visual focus; historical ranges fade into the background; the Control Line tells you which side of the range is winning the statistical argument.

Three design choices separate this from standard range-box scripts:

- Volume-weighted Control Line. Rather than dropping a midpoint line, the Control Line is computed from the volume-weighted typical price across the life of the range, with an edge-fallback to midpoint if the line drifts too close to either boundary. This produces a structurally meaningful reference instead of a geometric one.
- Retrospective fill on range rebuild. When a new range is committed, the script walks back through the range window and retroactively computes touch count, hold quality, and the Control Line. You see a fully-formed box with accurate statistics the moment it appears, not an empty box that slowly populates.
- Freeze-on-failure. When price closes beyond the range and the state transitions to Failed, the box locks at the break bar. No more drifting endpoints on broken structures — the reference stays where the story ended.

🔷 Methodology

The script cycles through four stages on every bar:

1. Range detection. Depending on the selected mode, the script looks for a qualifying range: confirmed swing pivots (Pivot), rolling highest/lowest (Lookback), short-ATR over long-ATR compression (Compression), or a user-defined date window (Manual). Gating rules — minimum lifespan, minimum width percentage, and a failed-state cooldown — prevent rapid re-triggers on noisy conditions.
2. Commit and retrospective fill. Once a range qualifies, the script snapshots the old range into history, installs the new one, and walks back through the window to compute the Control Line, touch count, and hold quality in a single pass. No warm-up period.
3. State machine. Each confirmed bar feeds the state machine. Strict logic requires bar closes on one side of the Control Line for the configured number of bars before switching to Upper or Lower; a close beyond either range boundary transitions to Failed.
4. Rendering. On the last bar, the hero box, Control Line, origin marker, and state badge are rebuilt from scratch. Historical ranges persist as muted boxes up to a configurable cap.

🔶 Signals & Alerts

Three alert conditions cover the full range lifecycle:

- New Control Box. Fires once per bar close when a new range is committed.
- Line Reclaimed (Bull or Bear). Fires when state transitions into Upper or Lower control, confirming directional bias inside the range.
- Control Failed. Fires once when price closes beyond the range and the box is frozen.

All alerts use alert() calls with once-per-bar-close frequency.

🔹 Key Inputs

- Range Mode — Auto-Pivot, Auto-Lookback, Auto-Compression, or Manual-Date.
- Pivot Length / Lookback Bars / Compression Window — window controls for each detection mode.
- Min Range Lifespan / Min Range Width % — structural filters to suppress micro-ranges.
- Failed Cooldown — bars to wait after a broken range before searching for a new one.
- Strict Control Logic + Reclaim Confirmation — governs how the Control Line state machine transitions.
- Visual controls — fade old boxes, max boxes kept, show state badge, show range origin, future projection bars, panel and label font sizes.

🔸 How to Use

1. Start on your primary timeframe and select the Range Mode that matches your style: Pivot for discretionary swing structures, Lookback for mechanical windows, Compression for auto-locking onto consolidations, Manual-Date for backtesting a specific episode.
2. Tune Min Range Width % and Min Range Lifespan so only structurally meaningful ranges appear.
3. Read the panel top-down: Mode confirms what you are tracking, Control tells you which side of the Control Line is winning, Range Age and Touches describe maturity and confluence, Hold Quality summarizes how cleanly price has respected the range, and State shows the live classification.
4. Use alerts to monitor the range lifecycle without staring at the chart.

🔻 Limitations & Transparency

- This is an analytical tool, not a strategy. It does not generate buy or sell recommendations and does not compute entries, stops, or targets.
- Past range behavior does not forecast future range behavior. Structural breaks can occur at any time.
- In very thin or illiquid markets, the volume-weighted Control Line can drift toward a boundary; the edge-fallback defaults to midpoint to protect against degenerate cases.
- Auto-Compression mode requires sufficient ATR history; expect a warm-up period on very recent symbols.
- The script is overlay-only and does not access other timeframes.

🔶 Risk Disclosure

Nothing in this script constitutes financial advice. Trading involves substantial risk of loss and is not suitable for every investor. Always do your own research and manage risk appropriately.

## Source Code

````pine
// -----------------------------------------------------
// Fixed Range Control Box [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Isolates a single high-conviction price range and classifies who controls it
// through a volume-weighted control line, reclaim logic, range hold quality,
// touch count, failed range freezing, and an owned control-rail price badge.
// Built for fixed range control, range trading context, consolidation review,
// breakout confirmation, and premium single-focus structural mapping.
// -----------------------------------------------------

//@version=6
indicator("Fixed Range Control Box [AGPro Series]",
     shorttitle = "AG Pro FRC",
     overlay = true,
     max_boxes_count = 100,
     max_lines_count = 100,
     max_labels_count = 180,
     max_bars_back = 1000)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
grpRange = "Range Definition"
rangeMode = input.string("Auto - Pivot", "Range Mode", options = ["Auto - Pivot", "Auto - Lookback", "Auto - Compression", "Manual - Date"], group = grpRange,
     tooltip = "Pivot uses the last confirmed swing high and low. Lookback uses a rolling fixed window. Compression locks low-volatility zones. Manual uses a user-defined date window.")
pivotLen = input.int(20, "Pivot Length", minval = 3, maxval = 100, group = grpRange,
     tooltip = "Bars on each side required to qualify a pivot. Higher values produce fewer and more structural ranges.")
lookbackBars = input.int(100, "Lookback Bars", minval = 20, maxval = 500, group = grpRange,
     tooltip = "Window length for Auto - Lookback mode.")
compressionLen = input.int(30, "Compression Window", minval = 10, maxval = 200, group = grpRange,
     tooltip = "Window length for ATR compression detection.")
compressionATR = input.float(0.70, "Compression Ratio", minval = 0.30, maxval = 1.00, step = 0.05, group = grpRange,
     tooltip = "Short ATR divided by long ATR. Lower values require stronger compression before a range is locked.")
minRangeBars = input.int(15, "Min Range Lifespan", minval = 5, maxval = 100, group = grpRange,
     tooltip = "Minimum bars a range must live before it can be replaced.")
minRangePct = input.float(1.5, "Min Range Width %", minval = 0.1, maxval = 20.0, step = 0.1, group = grpRange,
     tooltip = "Minimum range width as a percentage of midpoint. Filters micro-ranges.")
failedCooldown = input.int(5, "Failed Cooldown Bars", minval = 1, maxval = 50, group = grpRange,
     tooltip = "Bars to wait after a Failed state before searching for a new range.")
manualStart = input.time(timestamp("2026-01-01 00:00"), "Manual Start", group = grpRange,
     tooltip = "Start timestamp for Manual - Date mode.")
manualEnd = input.time(timestamp("2026-12-31 00:00"), "Manual End", group = grpRange,
     tooltip = "End timestamp for Manual - Date mode.")

grpCtrl = "Control Line"
showCtrlLine = input.bool(true, "Show Control Line", group = grpCtrl,
     tooltip = "Displays the volume-weighted control line inside the range.")
ctrlStrict = input.bool(true, "Strict Control Logic", group = grpCtrl,
     tooltip = "Strict uses confirmed closes beyond the control line. Loose allows wick pressure.")
reclaimBars = input.int(2, "Reclaim Confirmation", minval = 1, maxval = 10, group = grpCtrl,
     tooltip = "Consecutive bars required on one side of the control line before state switches to Upper or Lower control.")

grpVis = "Visuals"
fadeOldBoxes = input.bool(true, "Fade Old Boxes", group = grpVis,
     tooltip = "Dims historical ranges so the active box remains the visual focus.")
maxActiveBoxes = input.int(0, "Historical Boxes Kept", minval = 0, maxval = 10, group = grpVis,
     tooltip = "Optional historical ranges kept with centered PRIOR RANGE ownership badges. The default 0 preserves a premium single-box view.")
showStateLabel = input.bool(true, "Show Control Rail Badge", group = grpVis,
     tooltip = "Shows a filled right-edge badge with the active control-line price.")
showEdgeBadges = input.bool(true, "Show Range Edge Badges", group = grpVis,
     tooltip = "Shows filled right-edge badges that identify the active range high and range low prices.")
showCenteredBadge = input.bool(true, "Show Centered Box Badge", group = grpVis,
     tooltip = "Shows a separate centered badge inside the active control box.")
showOriginBadge = input.bool(true, "Show Range Origin Badge", group = grpVis,
     tooltip = "Shows a filled RANGE ORIGIN badge at the bar and price that own the active range.")
futureProj = input.int(30, "Future Projection Bars", minval = 10, maxval = 100, group = grpVis,
     tooltip = "How far the active box extends into the future.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVis,
     tooltip = "Font size for chart labels and centered badges.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows or hides the AG Pro status panel.")
panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"],
     group = grpPanel,
     tooltip = "Controls where the panel is anchored.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPanel,
     tooltip = "Controls the panel color theme.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel,
     tooltip = "Font size for the information panel.")

grpAlr = "Alerts"
alertNew = input.bool(true, "Alert: New Control Box", group = grpAlr,
     tooltip = "Fires once per bar close when a new range is established.")
alertReclaim = input.bool(true, "Alert: Line Reclaimed", group = grpAlr,
     tooltip = "Fires once per bar close when state transitions into Upper or Lower control.")
alertFailed = input.bool(true, "Alert: Control Failed", group = grpAlr,
     tooltip = "Fires once per bar close when price closes beyond the range and the box is frozen.")

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
histColor = color.rgb(71, 85, 105)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
f_size(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Large" ? size.large :
     s == "Huge" ? size.huge : size.normal

// Luminance-aware contrast text (target luminance 145)
f_lum(color c)      => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_price(float value) => str.tostring(value, format.mintick)

f_panel_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Center" ? position.bottom_center :
     p == "Bottom Left" ? position.bottom_left : position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_label_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(15, 23, 42)

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_is_valid_range(float hi, float lo) =>
    mid = (hi + lo) / 2.0
    mid > 0 and (hi - lo) / mid * 100.0 >= minRangePct

// -----------------------------------------------------
// State
// -----------------------------------------------------
var float rHigh = na
var float rLow = na
var int rStartBar = na
var float rCtrlLine = na
var int rAge = 0
var bool rFrozen = false
var int rFrozenBar = na

var float prevRHigh = na
var float prevRLow = na
var int prevRStartBar = na
var float prevRCtrlLine = na

var string boxState = "Inside"
var string prevState = "Inside"
var int touchCount = 0
var int barsAbove = 0
var int barsBelow = 0
var int holdBars = 0
var int barsAboveCtrl = 0
var int barsBelowCtrl = 0
var int barsCounted = 0
var int stateBars = 0
var float vwapNum = 0.0
var float vwapDen = 0.0

// -----------------------------------------------------
// Range detection
// -----------------------------------------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
var float lastPH = na
var float lastPL = na
var int lastPHBar = na
var int lastPLBar = na

if not na(ph)
    lastPH := ph
    lastPHBar := bar_index - pivotLen
if not na(pl)
    lastPL := pl
    lastPLBar := bar_index - pivotLen

atrShort = ta.atr(14)
atrLong = ta.atr(compressionLen * 3)
compressed = atrShort / math.max(atrLong, syminfo.mintick) < compressionATR
cooldownOk = not rFrozen or (not na(rFrozenBar) and bar_index - rFrozenBar >= failedCooldown)
lifespanOk = na(rHigh) or rFrozen or (not na(rStartBar) and bar_index - rStartBar >= minRangeBars)
canRebuild = cooldownOk and lifespanOk

bool rebuildRange = false
float newHigh = na
float newLow = na
int newStart = na

if rangeMode == "Auto - Pivot"
    if canRebuild and not na(lastPH) and not na(lastPL)
        newHi = math.max(lastPH, lastPL)
        newLo = math.min(lastPH, lastPL)
        newSt = math.min(lastPHBar, lastPLBar)
        pivotChanged = na(rHigh) or rFrozen or math.abs(newHi - rHigh) > syminfo.mintick * 10 or math.abs(newLo - rLow) > syminfo.mintick * 10
        if pivotChanged and f_is_valid_range(newHi, newLo) and newSt < bar_index
            rebuildRange := true
            newHigh := newHi
            newLow := newLo
            newStart := newSt
else if rangeMode == "Auto - Lookback"
    if canRebuild
        hi = ta.highest(high, lookbackBars)
        lo = ta.lowest(low, lookbackBars)
        if f_is_valid_range(hi, lo)
            rebuildRange := true
            newHigh := hi
            newLow := lo
            newStart := bar_index - lookbackBars + 1
else if rangeMode == "Auto - Compression"
    if canRebuild and compressed
        hi = ta.highest(high, compressionLen)
        lo = ta.lowest(low, compressionLen)
        if f_is_valid_range(hi, lo)
            rebuildRange := true
            newHigh := hi
            newLow := lo
            newStart := bar_index - compressionLen + 1
else
    inWindow = time >= manualStart and time <= manualEnd
    if inWindow and na(rHigh)
        rebuildRange := true
        newHigh := high
        newLow := low
        newStart := bar_index
    else if inWindow and not na(rHigh) and not rFrozen
        rHigh := math.max(rHigh, high)
        rLow := math.min(rLow, low)

// -----------------------------------------------------
// Commit rebuild
// -----------------------------------------------------
if rebuildRange
    prevRHigh := rHigh
    prevRLow := rLow
    prevRStartBar := rStartBar
    prevRCtrlLine := rCtrlLine

    rHigh := newHigh
    rLow := newLow
    rStartBar := newStart
    rAge := 0
    rFrozen := false
    rFrozenBar := na
    boxState := "Inside"
    prevState := "Inside"
    touchCount := 0
    barsAbove := 0
    barsBelow := 0
    holdBars := 0
    barsAboveCtrl := 0
    barsBelowCtrl := 0
    barsCounted := 0
    stateBars := 0
    vwapNum := 0.0
    vwapDen := 0.0

    barsBack = bar_index - newStart
    if barsBack >= 1 and barsBack < 1000
        for i = barsBack to 1
            v = nz(volume[i], 1)
            tp = (high[i] + low[i] + close[i]) / 3.0
            vwapNum += tp * v
            vwapDen += v

    mid = (newHigh + newLow) / 2.0
    edgeBuf = (newHigh - newLow) * 0.10
    cand = vwapDen > 0 ? vwapNum / vwapDen : mid
    if cand < newLow + edgeBuf or cand > newHigh - edgeBuf
        cand := mid
    rCtrlLine := cand

    if barsBack >= 1 and barsBack < 1000
        for i = barsBack to 1
            if low[i] <= rCtrlLine and high[i] >= rCtrlLine
                touchCount += 1
            if close[i] >= newLow and close[i] <= newHigh
                holdBars += 1
            if close[i] > rCtrlLine
                barsAboveCtrl += 1
            else if close[i] < rCtrlLine
                barsBelowCtrl += 1
            barsCounted += 1

// -----------------------------------------------------
// Ongoing update
// -----------------------------------------------------
if not na(rHigh) and not na(rStartBar) and bar_index >= rStartBar and not rFrozen
    if not rebuildRange
        v = nz(volume, 1)
        tp = (high + low + close) / 3.0
        vwapNum += tp * v
        vwapDen += v
        if vwapDen > 0
            mid = (rHigh + rLow) / 2.0
            edgeBuf = (rHigh - rLow) * 0.10
            cand = vwapNum / vwapDen
            if cand < rLow + edgeBuf or cand > rHigh - edgeBuf
                cand := mid
            rCtrlLine := cand
        rAge := bar_index - rStartBar

    if not na(rCtrlLine)
        if low <= rCtrlLine and high >= rCtrlLine
            touchCount += 1
        if close >= rLow and close <= rHigh
            holdBars += 1
        if close > rCtrlLine
            barsAboveCtrl += 1
        else if close < rCtrlLine
            barsBelowCtrl += 1
        barsCounted += 1

    if not rebuildRange and not na(rCtrlLine)
        src = ctrlStrict ? close : close > rCtrlLine ? high : low
        if src > rCtrlLine
            barsAbove += 1
            barsBelow := 0
        else if src < rCtrlLine
            barsBelow += 1
            barsAbove := 0

        prevState := boxState
        newState = boxState
        if close > rHigh or close < rLow
            newState := "Failed"
        else if barsAbove >= reclaimBars
            newState := "Upper"
        else if barsBelow >= reclaimBars
            newState := "Lower"
        else if boxState != "Failed"
            newState := "Inside"
        boxState := newState

        if boxState == "Failed" and prevState != "Failed"
            rFrozen := true
            rFrozenBar := bar_index

        stateBars := boxState == prevState ? stateBars + 1 : 1

dominantBars = boxState == "Upper" ? barsAboveCtrl : boxState == "Lower" ? barsBelowCtrl : math.max(barsAboveCtrl, barsBelowCtrl)
holdQuality = barsCounted > 0 ? math.min(100, math.round(dominantBars * 100.0 / barsCounted)) : 0
stateCol = boxState == "Upper" ? bullColor : boxState == "Lower" ? bearColor : boxState == "Failed" ? bearColor : neutralColor
controlText = boxState == "Upper" ? "Bull" : boxState == "Lower" ? "Bear" : boxState == "Failed" ? "Broken" : "Neutral"

// -----------------------------------------------------
// Rendering
// -----------------------------------------------------
var array<box> histBoxes = array.new<box>()
var array<line> histLines = array.new<line>()
var array<label> histLabels = array.new<label>()
var box activeBox = na
var line activeLine = na
var line highConnector = na
var line lowConnector = na
var label activeLabel = na
var label highBadge = na
var label lowBadge = na
var label centerBadge = na
var label originMarker = na

if not na(activeBox)
    box.delete(activeBox)
if not na(activeLine)
    line.delete(activeLine)
if not na(highConnector)
    line.delete(highConnector)
if not na(lowConnector)
    line.delete(lowConnector)
if not na(activeLabel)
    label.delete(activeLabel)
if not na(highBadge)
    label.delete(highBadge)
if not na(lowBadge)
    label.delete(lowBadge)
if not na(centerBadge)
    label.delete(centerBadge)
if not na(originMarker)
    label.delete(originMarker)

if barstate.islast and not na(rHigh) and not na(rLow) and not na(rStartBar)
    rightBar = rFrozen and not na(rFrozenBar) ? rFrozenBar : bar_index + futureProj
    activeBox := box.new(rStartBar, rHigh, rightBar, rLow, border_color = stateCol, border_width = 3, bgcolor = color.new(stateCol, rFrozen ? 92 : 86), extend = extend.none)

    if showCtrlLine and not na(rCtrlLine) and not rFrozen
        activeLine := line.new(rStartBar, rCtrlLine, rightBar + 2, rCtrlLine, color = accentColor, width = 2, style = line.style_solid)

    if showOriginBadge
        originMarker := label.new(rStartBar, rHigh, "RANGE ORIGIN", style = label.style_label_down, color = accentColor, textcolor = f_text_on(accentColor), size = f_size(labelFontSize), xloc = xloc.bar_index, yloc = yloc.price)

    if showCenteredBadge
        centerX = rStartBar + int(math.round((rightBar - rStartBar) * 0.50))
        centerY = (rHigh + rLow) / 2.0
        centerText = (boxState == "Upper" ? "BULL CONTROL" : boxState == "Lower" ? "BEAR CONTROL" : boxState == "Failed" ? "FAILED CONTROL" : "NEUTRAL CONTROL") + " | Q " + str.tostring(holdQuality)
        centerBadge := label.new(centerX, centerY, centerText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateCol, 0), textcolor = f_text_on(stateCol), size = f_size(labelFontSize))

    if showStateLabel and showCtrlLine and not na(rCtrlLine) and not rFrozen
        activeLabel := label.new(rightBar + 2, rCtrlLine, "CONTROL  " + f_price(rCtrlLine), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = f_size(labelFontSize))

    if showEdgeBadges
        edgeBadgeX = rightBar + 6
        highConnector := line.new(rightBar, rHigh, edgeBadgeX, rHigh, xloc = xloc.bar_index, color = bullColor, width = 1, style = line.style_dotted)
        lowConnector := line.new(rightBar, rLow, edgeBadgeX, rLow, xloc = xloc.bar_index, color = bearColor, width = 1, style = line.style_dotted)
        highBadge := label.new(edgeBadgeX, rHigh, "RANGE HIGH  " + f_price(rHigh), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bullColor, textcolor = f_text_on(bullColor), size = f_size(labelFontSize))
        lowBadge := label.new(edgeBadgeX, rLow, "RANGE LOW  " + f_price(rLow), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bearColor, textcolor = f_text_on(bearColor), size = f_size(labelFontSize))

if rebuildRange and barstate.isconfirmed and not na(prevRHigh) and not na(prevRLow) and not na(prevRStartBar) and maxActiveBoxes > 0
    histEnd = math.min(bar_index - 1, newStart - 1)
    if histEnd > prevRStartBar
        hb = box.new(prevRStartBar, prevRHigh, histEnd, prevRLow, border_color = color.new(histColor, fadeOldBoxes ? 65 : 45), border_width = 1, bgcolor = color.new(histColor, fadeOldBoxes ? 90 : 82), extend = extend.none)
        array.push(histBoxes, hb)
        line hl = na
        if showCtrlLine and not na(prevRCtrlLine)
            hl := line.new(prevRStartBar, prevRCtrlLine, histEnd, prevRCtrlLine, color = color.new(accentColor, 75), width = 1, style = line.style_dotted)
        array.push(histLines, hl)
        histCenterX = prevRStartBar + int(math.round((histEnd - prevRStartBar) * 0.50))
        histCenterY = (prevRHigh + prevRLow) / 2.0
        hBadge = label.new(histCenterX, histCenterY, "PRIOR RANGE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = histColor, textcolor = f_text_on(histColor), size = f_size(labelFontSize))
        array.push(histLabels, hBadge)
        while array.size(histBoxes) > maxActiveBoxes
            oldBox = array.shift(histBoxes)
            oldLine = array.shift(histLines)
            oldLabel = array.shift(histLabels)
            box.delete(oldBox)
            if not na(oldLine)
                line.delete(oldLine)
            label.delete(oldLabel)

if maxActiveBoxes == 0 and barstate.islast
    while array.size(histBoxes) > 0
        box.delete(array.shift(histBoxes))
    while array.size(histLines) > 0
        oldLine = array.shift(histLines)
        if not na(oldLine)
            line.delete(oldLine)
    while array.size(histLabels) > 0
        label.delete(array.shift(histLabels))

// -----------------------------------------------------
// Panel
// -----------------------------------------------------
var table panel = na

f_panel_row(int row, string labelText, string valueText, color valueBg) =>
    table.cell(panel, 0, row, labelText, text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, row, valueText, text_color = valueBg == stateCol ? f_text_on(stateCol) : f_panel_value(), bgcolor = valueBg, text_size = f_size(panelFontSize), text_halign = text.align_right)

if barstate.islast
    if showPanel
        if na(panel)
            panel := table.new(f_panel_pos(panelLocation), 2, 7, border_color = f_panel_border(), border_width = 1, frame_color = f_panel_border(), frame_width = 1, bgcolor = f_panel_bg())
        table.set_position(panel, f_panel_pos(panelLocation))
        table.set_border_color(panel, f_panel_border())
        table.set_frame_color(panel, f_panel_border())
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Fixed Range Control Box", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(1, "Mode", rangeMode, f_panel_bg())
        f_panel_row(2, "Control", controlText, stateCol)
        f_panel_row(3, "Range Age", str.tostring(rAge) + " bars", rAge >= 50 ? color.new(bullColor, 55) : rAge >= 20 ? color.new(neutralColor, 55) : f_panel_bg())
        f_panel_row(4, "Touches", str.tostring(touchCount), touchCount >= 8 ? color.new(bullColor, 55) : touchCount >= 3 ? color.new(neutralColor, 55) : f_panel_bg())
        f_panel_row(5, "Hold Quality", str.tostring(holdQuality) + "%", holdQuality >= 80 ? color.new(bullColor, 55) : holdQuality >= 50 ? color.new(neutralColor, 55) : color.new(bearColor, 55))
        f_panel_row(6, "State", boxState, f_panel_bg())
    else
        if not na(panel)
            table.delete(panel)
            panel := na

// -----------------------------------------------------
// Alerts
// -----------------------------------------------------
if alertNew and rebuildRange and barstate.isconfirmed
    alert("AG Pro FRCB: New control box formed on " + syminfo.ticker, alert.freq_once_per_bar_close)

if alertReclaim and (prevState == "Inside" or prevState == "Lower") and boxState == "Upper" and barstate.isconfirmed
    alert("AG Pro FRCB: Control line reclaimed by bulls on " + syminfo.ticker, alert.freq_once_per_bar_close)

if alertReclaim and (prevState == "Inside" or prevState == "Upper") and boxState == "Lower" and barstate.isconfirmed
    alert("AG Pro FRCB: Control line reclaimed by bears on " + syminfo.ticker, alert.freq_once_per_bar_close)

if alertFailed and prevState != "Failed" and boxState == "Failed" and barstate.isconfirmed
    alert("AG Pro FRCB: Control box failed on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
