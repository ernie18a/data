<!-- tradingview-pine-id: PUB;558a7235ecac48be8820effbdd03f069 -->
<!-- tradingviewscripts-format: 1 -->
# BRO Market Structure & Confluence v2

Source: https://www.tradingview.com/script/TBGw3Jjt-BRO-Market-Structure-Confluence/

## Description

BRO Market Structure & Confluence
BRO Market Structure & Confluence is an all-in-one trading indicator designed to help traders identify market direction, important reaction zones, momentum, volume strength, and intraday breakout opportunities without overcrowding the chart.
The indicator combines market structure, liquidity-based support and resistance, fair value gaps, RSI, relative volume, moving averages, VWAP, and the New York opening range into one customizable system.
Main features
Market structure
Identifies bullish and bearish market structure.
Displays major Break of Structure, or BOS, signals.
Displays Change of Character, or CHoCH, signals.
Filters weaker structure breaks using displacement and volume.
Liquidity reaction zones
Detects important support and resistance areas from confirmed swing points.
Uses pivot volume and repeated price interaction to help filter weaker levels.
Merges nearby zones to reduce clutter.
Extends active zones until they are invalidated.
Fair value gaps
Detects bullish and bearish fair value gaps.
Filters gaps using ATR size, volume, and market direction.
Removes filled gaps automatically.
Limits the number of active gaps displayed.
RSI and relative volume panel
Includes an RSI line with customizable 25, 50, and 75 levels.
Displays normalized relative-volume columns.
Helps identify momentum shifts, overextended conditions, and high-participation candles.
Trend tools
Session VWAP.
Optional EMA 20, 50, 100, and 200.
Bullish or bearish EMA trend classification.
Opening Range Breakout
Tracks the customizable New York opening range.
Default range is 9:30–9:45 a.m. New York time.
Displays the opening-range high, low, and midpoint.
Identifies confirmed breakouts and potential retests.
BRO Market Map
A compact dashboard displays:
Current market structure.
RSI condition.
Candle relative volume.
Developing daily volume.
Progress toward average daily volume.
EMA bias.
Opening-range position.
Long and short confluence scores.
Confluence scoring
The indicator evaluates several market conditions and produces separate bullish and bearish confluence scores. These may include:
Market structure.
RSI momentum.
Relative volume.
VWAP position.
EMA alignment.
Opening-range position.
Support, resistance, or FVG proximity.
The score is designed to summarize market conditions, not to guarantee a trade outcome.
Suggested use
This indicator can be used for:
Intraday trend analysis.
Identifying potential support and resistance.
Confirming breakouts.
Finding pullbacks into fair value gaps.
Evaluating opening-range trades.
Comparing price action with RSI and volume.
Building a repeatable confluence-based trading process.
It is especially suited for futures, stocks, ETFs, forex, and other instruments with reliable price and volume data.
Important notice
This indicator is intended for educational and informational purposes only. It does not provide financial advice, guarantee profitable results, or replace independent analysis and risk management. Historical signals and market reactions do not guarantee future performance. DO NOT USE THIS FOR TRADING

---

## Source Code

````pine
//@version=6
indicator(
     "BRO Market Structure & Confluence v2",
     shorttitle = "BRO Confluence v2",
     overlay = false,
     max_boxes_count = 250,
     max_lines_count = 250,
     max_labels_count = 250,
     behind_chart = true)

// ============================================================================
// BRO MARKET STRUCTURE & CONFLUENCE v2
// Original Pine Script v6 indicator.
//
// LOWER PANEL:
//   • RSI with 25 / 50 / 75 levels
//   • Normalized candle relative-volume columns
//
// MAIN CHART:
//   • VWAP
//   • Optional EMA 20 / 50 / 100 / 200
//   • Filtered BOS / CHoCH
//   • Merged volume-qualified liquidity zones
//   • Filtered FVGs
//   • New York opening range, breakout, and one retest per direction
//
// Price drawings use force_overlay=true so they stay attached to price bars,
// while RSI and relative volume remain in the lower pane.
// ============================================================================

// ───────────────────────── 1. GENERAL ───────────────────────────────────────
grpGeneral = "1. General"
showDashboard = input.bool(true, "Show BRO market map", group = grpGeneral)
showConfluenceMarkers = input.bool(false, "Show confluence markers", group = grpGeneral)
minimumConfluence = input.int(5, "Minimum confluence score", minval = 3, maxval = 7, group = grpGeneral)

// ───────────────────────── 2. RSI + VOLUME PANEL ────────────────────────────
grpPanel = "2. RSI + Relative Volume Panel"
rsiLength = input.int(14, "RSI length", minval = 2, group = grpPanel)
rsiLower = input.float(25.0, "RSI lower level", minval = 0, maxval = 49, group = grpPanel)
rsiMid = input.float(50.0, "RSI midpoint", minval = 1, maxval = 99, group = grpPanel)
rsiUpper = input.float(75.0, "RSI upper level", minval = 51, maxval = 100, group = grpPanel)
rsiColor = input.color(color.white, "RSI color", group = grpPanel)
volumeAverageLength = input.int(20, "Candle volume average", minval = 2, group = grpPanel)
rvolPanelMaximum = input.float(3.0, "RVOL represented by full-height column", minval = 1.0, step = 0.25, group = grpPanel)
highRvol = input.float(1.50, "Elevated RVOL", minval = 0.5, step = 0.05, group = grpPanel)
extremeRvol = input.float(2.00, "Extreme RVOL", minval = 1.0, step = 0.05, group = grpPanel)
normalVolumeColor = input.color(color.new(color.silver, 72), "Normal-volume columns", group = grpPanel)
highVolumeColor = input.color(color.new(color.aqua, 45), "Elevated-volume columns", group = grpPanel)
extremeVolumeColor = input.color(color.new(color.fuchsia, 30), "Extreme-volume columns", group = grpPanel)

// ───────────────────────── 3. VWAP + EMA TREND ──────────────────────────────
grpTrend = "3. VWAP + EMA Trend"
showVwap = input.bool(true, "Show session VWAP", group = grpTrend)
vwapColor = input.color(color.white, "VWAP color", group = grpTrend)
showEma20 = input.bool(true, "Show EMA 20", group = grpTrend)
showEma50 = input.bool(true, "Show EMA 50", group = grpTrend)
showEma100 = input.bool(false, "Show EMA 100", group = grpTrend)
showEma200 = input.bool(true, "Show EMA 200", group = grpTrend)
ema20Color = input.color(color.orange, "EMA 20 color", group = grpTrend)
ema50Color = input.color(color.aqua, "EMA 50 color", group = grpTrend)
ema100Color = input.color(color.silver, "EMA 100 color", group = grpTrend)
ema200Color = input.color(color.blue, "EMA 200 color", group = grpTrend)

// ───────────────────────── 4. MARKET STRUCTURE ──────────────────────────────
grpStructure = "4. Market Structure"
showBos = input.bool(true, "Show BOS", group = grpStructure)
showChoch = input.bool(true, "Show CHoCH", group = grpStructure)
structurePivot = input.int(12, "Major swing strength", minval = 3, maxval = 50, group = grpStructure)
structureAtrBuffer = input.float(0.10, "Break buffer (ATR)", minval = 0.0, step = 0.05, group = grpStructure)
structureRequireRvol = input.bool(true, "Require volume confirmation", group = grpStructure)
structureMinRvol = input.float(1.20, "Minimum structure RVOL", minval = 0.0, step = 0.05, group = grpStructure)
maxStructureLabels = input.int(12, "Maximum structure labels", minval = 2, maxval = 50, group = grpStructure)
bullStructureColor = input.color(color.aqua, "Bullish structure color", group = grpStructure)
bearStructureColor = input.color(color.fuchsia, "Bearish structure color", group = grpStructure)

// ───────────────────────── 5. LIQUIDITY ZONES ───────────────────────────────
grpLiquidity = "5. Liquidity Reaction Zones"
showLiquidity = input.bool(true, "Show liquidity zones", group = grpLiquidity)
liqPivot = input.int(14, "Pivot lookback", minval = 3, maxval = 50, group = grpLiquidity)
liqZoneMode = input.string("Wick", "Zone construction", options = ["Wick", "Body", "Full candle"], group = grpLiquidity)
liqMinOriginRvol = input.float(1.10, "Minimum origin RVOL", minval = 0.0, step = 0.05, group = grpLiquidity)
liqMinTouches = input.int(1, "Touches before full visibility", minval = 0, maxval = 10, group = grpLiquidity)
liqTouchToleranceAtr = input.float(0.10, "Touch tolerance (ATR)", minval = 0.0, step = 0.05, group = grpLiquidity)
liqMergeDistanceAtr = input.float(0.20, "Merge nearby zones within (ATR)", minval = 0.0, step = 0.05, group = grpLiquidity)
liqMaxEachSide = input.int(3, "Maximum active zones each side", minval = 1, maxval = 8, group = grpLiquidity)
liqKeepBroken = input.bool(true, "Keep recently broken zones", group = grpLiquidity)
liqMaxBroken = input.int(2, "Maximum broken zones", minval = 0, maxval = 10, group = grpLiquidity)
resistanceFill = input.color(color.new(color.fuchsia, 86), "Resistance fill", group = grpLiquidity)
resistanceBorder = input.color(color.new(color.fuchsia, 15), "Resistance border", group = grpLiquidity)
supportFill = input.color(color.new(color.aqua, 86), "Support fill", group = grpLiquidity)
supportBorder = input.color(color.new(color.aqua, 15), "Support border", group = grpLiquidity)
brokenFill = input.color(color.new(color.gray, 88), "Broken-zone fill", group = grpLiquidity)

// ───────────────────────── 6. FAIR VALUE GAPS ───────────────────────────────
grpFvg = "6. Fair Value Gaps"
showFvg = input.bool(true, "Show filtered FVGs", group = grpFvg)
fvgTf = input.timeframe("15", "FVG source timeframe", group = grpFvg)
fvgMinAtr = input.float(0.25, "Minimum gap size (ATR)", minval = 0.0, step = 0.05, group = grpFvg)
fvgRequireRvol = input.bool(true, "Require source RVOL", group = grpFvg)
fvgMinRvol = input.float(1.20, "Minimum source RVOL", minval = 0.0, step = 0.05, group = grpFvg)
fvgTrendFilter = input.bool(true, "Only show trend-aligned FVGs", group = grpFvg)
fvgMaxEachSide = input.int(3, "Maximum FVGs each side", minval = 1, maxval = 10, group = grpFvg)
fvgDeleteFilled = input.bool(true, "Delete fully filled FVGs", group = grpFvg)
bullFvgColor = input.color(color.new(color.blue, 84), "Bullish FVG color", group = grpFvg)
bearFvgColor = input.color(color.new(color.purple, 84), "Bearish FVG color", group = grpFvg)

// ───────────────────────── 7. OPENING RANGE ─────────────────────────────────
grpOrb = "7. New York Opening Range"
showOrb = input.bool(true, "Show opening range", group = grpOrb)
orbSession = input.session("0930-0945", "Opening-range session", group = grpOrb)
orbTimezone = input.string("America/New_York", "Timezone", group = grpOrb)
showOrbMid = input.bool(true, "Show midpoint", group = grpOrb)
showOrbBreakouts = input.bool(true, "Show first breakout each direction", group = grpOrb)
showOrbRetests = input.bool(true, "Show one retest each direction", group = grpOrb)
orbRetestToleranceAtr = input.float(0.10, "Retest tolerance (ATR)", minval = 0.0, step = 0.05, group = grpOrb)
orbHighColor = input.color(color.yellow, "ORB high color", group = grpOrb)
orbLowColor = input.color(color.orange, "ORB low color", group = grpOrb)
orbMidColor = input.color(color.new(color.silver, 45), "ORB midpoint color", group = grpOrb)
orbBoxColor = input.color(color.new(color.yellow, 92), "ORB box fill", group = grpOrb)

// ───────────────────────── CORE SERIES ──────────────────────────────────────
float atr = ta.atr(14)
float avgVolume = ta.sma(volume, volumeAverageLength)
float candleRvol = avgVolume > 0 ? volume / avgVolume : na
float normalizedRvol = na(candleRvol) ? na : math.min(candleRvol / rvolPanelMaximum * 100.0, 100.0)
float rsiValue = ta.rsi(close, rsiLength)
float ema20 = ta.ema(close, 20)
float ema50 = ta.ema(close, 50)
float ema100 = ta.ema(close, 100)
float ema200 = ta.ema(close, 200)
float vwapValue = ta.vwap(hlc3)
float currentDailyVolume = request.security(syminfo.tickerid, "D", volume, lookahead = barmerge.lookahead_off)
float averageDailyVolume = request.security(syminfo.tickerid, "D", ta.sma(volume[1], 20), lookahead = barmerge.lookahead_on)
float dailyVolumeProgress = averageDailyVolume > 0 ? currentDailyVolume / averageDailyVolume : na

// ───────────────────────── LOWER PANEL ──────────────────────────────────────
color volumeColumnColor = candleRvol >= extremeRvol ? extremeVolumeColor : candleRvol >= highRvol ? highVolumeColor : normalVolumeColor
plot(normalizedRvol, "Normalized candle RVOL", style = plot.style_columns, color = volumeColumnColor, histbase = 0)
plot(rsiValue, "RSI", color = rsiColor, linewidth = 2)
hline(rsiUpper, "RSI upper", color = color.new(color.fuchsia, 35), linestyle = hline.style_dashed)
hline(rsiMid, "RSI midpoint", color = color.new(color.silver, 45), linestyle = hline.style_dotted)
hline(rsiLower, "RSI lower", color = color.new(color.aqua, 35), linestyle = hline.style_dashed)
hline(0, "Panel floor", color = color.new(color.silver, 90))

// ───────────────────────── PRICE TREND PLOTS ────────────────────────────────
plot(showVwap ? vwapValue : na, "VWAP", color = vwapColor, linewidth = 2, force_overlay = true)
plot(showEma20 ? ema20 : na, "EMA 20", color = color.new(ema20Color, 10), linewidth = 1, force_overlay = true)
plot(showEma50 ? ema50 : na, "EMA 50", color = color.new(ema50Color, 10), linewidth = 1, force_overlay = true)
plot(showEma100 ? ema100 : na, "EMA 100", color = color.new(ema100Color, 20), linewidth = 1, force_overlay = true)
plot(showEma200 ? ema200 : na, "EMA 200", color = color.new(ema200Color, 5), linewidth = 2, force_overlay = true)

// ───────────────────────── HELPER FUNCTIONS ─────────────────────────────────
broFormatVolumeV2(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.volume)

broFormatRvolV2(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "x"

broDeleteOldestLabelV2(label[] labels, int maximum) =>
    while array.size(labels) > maximum
        label.delete(array.shift(labels))

// ───────────────────────── MARKET STRUCTURE ─────────────────────────────────
float swingHigh = ta.pivothigh(high, structurePivot, structurePivot)
float swingLow = ta.pivotlow(low, structurePivot, structurePivot)
var float lastSwingHigh = na
var float lastSwingLow = na
var bool highAlreadyBroken = false
var bool lowAlreadyBroken = false
var int structureTrend = 0
var label[] structureLabels = array.new<label>()

if not na(swingHigh)
    lastSwingHigh := swingHigh
    highAlreadyBroken := false

if not na(swingLow)
    lastSwingLow := swingLow
    lowAlreadyBroken := false

bool structureVolumeOk = not structureRequireRvol or candleRvol >= structureMinRvol
bool bullishStructureBreak = not highAlreadyBroken and not na(lastSwingHigh) and close > lastSwingHigh + atr * structureAtrBuffer and close[1] <= lastSwingHigh + atr[1] * structureAtrBuffer and structureVolumeOk
bool bearishStructureBreak = not lowAlreadyBroken and not na(lastSwingLow) and close < lastSwingLow - atr * structureAtrBuffer and close[1] >= lastSwingLow - atr[1] * structureAtrBuffer and structureVolumeOk
bool bullishChoch = bullishStructureBreak and structureTrend == -1
bool bearishChoch = bearishStructureBreak and structureTrend == 1

if bullishStructureBreak
    string txt = bullishChoch ? "CHoCH" : "BOS"
    bool shouldShow = bullishChoch ? showChoch : showBos
    if shouldShow
        label lbl = label.new(bar_index, high, txt, style = label.style_label_down, color = color.new(bullStructureColor, 10), textcolor = color.black, size = size.tiny, force_overlay = true)
        array.push(structureLabels, lbl)
        broDeleteOldestLabelV2(structureLabels, maxStructureLabels)
    structureTrend := 1
    highAlreadyBroken := true

if bearishStructureBreak
    string txt = bearishChoch ? "CHoCH" : "BOS"
    bool shouldShow = bearishChoch ? showChoch : showBos
    if shouldShow
        label lbl = label.new(bar_index, low, txt, style = label.style_label_up, color = color.new(bearStructureColor, 10), textcolor = color.white, size = size.tiny, force_overlay = true)
        array.push(structureLabels, lbl)
        broDeleteOldestLabelV2(structureLabels, maxStructureLabels)
    structureTrend := -1
    lowAlreadyBroken := true

// ───────────────────────── LIQUIDITY ZONES ──────────────────────────────────
var box[] liqBoxes = array.new<box>()
var line[] liqLines = array.new<line>()
var float[] liqTops = array.new<float>()
var float[] liqBottoms = array.new<float>()
var int[] liqSides = array.new<int>()
var int[] liqTouches = array.new<int>()
var bool[] liqInsidePrevious = array.new<bool>()
var bool[] liqActive = array.new<bool>()

broDeleteLiquidityV2(int index) =>
    box.delete(array.get(liqBoxes, index))
    line.delete(array.get(liqLines, index))
    array.remove(liqBoxes, index)
    array.remove(liqLines, index)
    array.remove(liqTops, index)
    array.remove(liqBottoms, index)
    array.remove(liqSides, index)
    array.remove(liqTouches, index)
    array.remove(liqInsidePrevious, index)
    array.remove(liqActive, index)

broCountLiquidityV2(int wantedSide, bool wantedActive) =>
    int count = 0
    if array.size(liqSides) > 0
        for i = 0 to array.size(liqSides) - 1
            if array.get(liqSides, i) == wantedSide and array.get(liqActive, i) == wantedActive
                count += 1
    count

broAddOrMergeLiquidityV2(int side, float top, float bottom, int sourceBar) =>
    float center = (top + bottom) / 2.0
    int mergeIndex = na
    if array.size(liqBoxes) > 0
        for i = 0 to array.size(liqBoxes) - 1
            float oldCenter = (array.get(liqTops, i) + array.get(liqBottoms, i)) / 2.0
            if array.get(liqActive, i) and array.get(liqSides, i) == side and math.abs(center - oldCenter) <= atr * liqMergeDistanceAtr
                mergeIndex := i
                break

    if not na(mergeIndex)
        float mergedTop = math.max(array.get(liqTops, mergeIndex), top)
        float mergedBottom = math.min(array.get(liqBottoms, mergeIndex), bottom)
        array.set(liqTops, mergeIndex, mergedTop)
        array.set(liqBottoms, mergeIndex, mergedBottom)
        array.set(liqTouches, mergeIndex, array.get(liqTouches, mergeIndex) + 1)
        box bx = array.get(liqBoxes, mergeIndex)
        line ln = array.get(liqLines, mergeIndex)
        box.set_top(bx, mergedTop)
        box.set_bottom(bx, mergedBottom)
        line.set_y1(ln, center)
        line.set_y2(ln, center)
    else
        color fillColor = side == 1 ? resistanceFill : supportFill
        color borderColor = side == 1 ? resistanceBorder : supportBorder
        box bx = box.new(sourceBar, top, bar_index, bottom, xloc = xloc.bar_index, extend = extend.right, border_color = borderColor, bgcolor = color.new(fillColor, liqMinTouches > 0 ? 95 : color.t(fillColor)), force_overlay = true)
        line ln = line.new(sourceBar, center, bar_index, center, xloc = xloc.bar_index, extend = extend.right, color = borderColor, width = 1, force_overlay = true)
        array.push(liqBoxes, bx)
        array.push(liqLines, ln)
        array.push(liqTops, top)
        array.push(liqBottoms, bottom)
        array.push(liqSides, side)
        array.push(liqTouches, 0)
        array.push(liqInsidePrevious, false)
        array.push(liqActive, true)

float liquidityHighPivot = ta.pivothigh(high, liqPivot, liqPivot)
float liquidityLowPivot = ta.pivotlow(low, liqPivot, liqPivot)
float pivotAverageVolume = avgVolume[liqPivot]
float pivotRvol = pivotAverageVolume > 0 ? volume[liqPivot] / pivotAverageVolume : na

if showLiquidity and not na(liquidityHighPivot) and (liqMinOriginRvol <= 0 or pivotRvol >= liqMinOriginRvol)
    float zoneTop = high[liqPivot]
    float zoneBottom = liqZoneMode == "Wick" ? math.max(open[liqPivot], close[liqPivot]) : liqZoneMode == "Body" ? math.min(open[liqPivot], close[liqPivot]) : low[liqPivot]
    broAddOrMergeLiquidityV2(1, zoneTop, zoneBottom, bar_index - liqPivot)

if showLiquidity and not na(liquidityLowPivot) and (liqMinOriginRvol <= 0 or pivotRvol >= liqMinOriginRvol)
    float zoneBottom = low[liqPivot]
    float zoneTop = liqZoneMode == "Wick" ? math.min(open[liqPivot], close[liqPivot]) : liqZoneMode == "Body" ? math.max(open[liqPivot], close[liqPivot]) : high[liqPivot]
    broAddOrMergeLiquidityV2(-1, zoneTop, zoneBottom, bar_index - liqPivot)

if array.size(liqBoxes) > 0
    for i = array.size(liqBoxes) - 1 to 0
        bool active = array.get(liqActive, i)
        if active
            float top = array.get(liqTops, i)
            float bottom = array.get(liqBottoms, i)
            int side = array.get(liqSides, i)
            bool insideNow = high >= bottom - atr * liqTouchToleranceAtr and low <= top + atr * liqTouchToleranceAtr
            bool insideBefore = array.get(liqInsidePrevious, i)
            if insideNow and not insideBefore
                int newTouches = array.get(liqTouches, i) + 1
                array.set(liqTouches, i, newTouches)
                if newTouches >= liqMinTouches
                    box.set_bgcolor(array.get(liqBoxes, i), side == 1 ? resistanceFill : supportFill)
            array.set(liqInsidePrevious, i, insideNow)

            bool broken = side == 1 ? close > top : close < bottom
            if broken
                array.set(liqActive, i, false)
                box.set_extend(array.get(liqBoxes, i), extend.none)
                line.set_extend(array.get(liqLines, i), extend.none)
                box.set_right(array.get(liqBoxes, i), bar_index)
                line.set_x2(array.get(liqLines, i), bar_index)
                box.set_bgcolor(array.get(liqBoxes, i), brokenFill)
                line.set_style(array.get(liqLines, i), line.style_dashed)

// Trim active resistance zones.
bool trimResistance = true
while trimResistance and broCountLiquidityV2(1, true) > liqMaxEachSide
    int removeResistance = na
    if array.size(liqSides) > 0
        for i = 0 to array.size(liqSides) - 1
            if array.get(liqSides, i) == 1 and array.get(liqActive, i)
                removeResistance := i
                break
    if na(removeResistance)
        trimResistance := false
    if not na(removeResistance)
        broDeleteLiquidityV2(removeResistance)

// Trim active support zones.
bool trimSupport = true
while trimSupport and broCountLiquidityV2(-1, true) > liqMaxEachSide
    int removeSupport = na
    if array.size(liqSides) > 0
        for i = 0 to array.size(liqSides) - 1
            if array.get(liqSides, i) == -1 and array.get(liqActive, i)
                removeSupport := i
                break
    if na(removeSupport)
        trimSupport := false
    if not na(removeSupport)
        broDeleteLiquidityV2(removeSupport)

int brokenCount = 0
if array.size(liqActive) > 0
    for i = 0 to array.size(liqActive) - 1
        if not array.get(liqActive, i)
            brokenCount += 1

bool trimBroken = true
while trimBroken and brokenCount > (liqKeepBroken ? liqMaxBroken : 0)
    int removeBrokenIndex = na
    if array.size(liqActive) > 0
        for i = 0 to array.size(liqActive) - 1
            if not array.get(liqActive, i)
                removeBrokenIndex := i
                break
    if na(removeBrokenIndex)
        trimBroken := false
    if not na(removeBrokenIndex)
        broDeleteLiquidityV2(removeBrokenIndex)
        brokenCount -= 1

// ───────────────────────── FAIR VALUE GAPS ──────────────────────────────────
broFvgSourceV2() =>
    float srcAtr = ta.atr(14)
    float srcAvgVol = ta.sma(volume, volumeAverageLength)
    float srcRvol = srcAvgVol > 0 ? volume / srcAvgVol : na
    bool bull = low > high[2] and low - high[2] >= srcAtr * fvgMinAtr
    bool bear = high < low[2] and low[2] - high >= srcAtr * fvgMinAtr
    [bull, bear, low, high[2], low[2], high, time, srcRvol]

[bullFvgSignal, bearFvgSignal, bullFvgTop, bullFvgBottom, bearFvgTop, bearFvgBottom, fvgTime, sourceFvgRvol] = request.security(syminfo.tickerid, fvgTf, broFvgSourceV2(), lookahead = barmerge.lookahead_off)
var box[] bullFvgBoxes = array.new<box>()
var box[] bearFvgBoxes = array.new<box>()
var float[] bullFvgBottoms = array.new<float>()
var float[] bearFvgTops = array.new<float>()
var int lastBullFvgTime = na
var int lastBearFvgTime = na

bool bullFvgAllowed = showFvg and bullFvgSignal and (not fvgRequireRvol or sourceFvgRvol >= fvgMinRvol) and (not fvgTrendFilter or structureTrend >= 0)
bool bearFvgAllowed = showFvg and bearFvgSignal and (not fvgRequireRvol or sourceFvgRvol >= fvgMinRvol) and (not fvgTrendFilter or structureTrend <= 0)

if bullFvgAllowed and fvgTime != lastBullFvgTime
    lastBullFvgTime := fvgTime
    box bx = box.new(fvgTime, bullFvgTop, time, bullFvgBottom, xloc = xloc.bar_time, extend = extend.right, border_color = color.new(bullFvgColor, 25), bgcolor = bullFvgColor, force_overlay = true)
    array.push(bullFvgBoxes, bx)
    array.push(bullFvgBottoms, bullFvgBottom)

if bearFvgAllowed and fvgTime != lastBearFvgTime
    lastBearFvgTime := fvgTime
    box bx = box.new(fvgTime, bearFvgTop, time, bearFvgBottom, xloc = xloc.bar_time, extend = extend.right, border_color = color.new(bearFvgColor, 25), bgcolor = bearFvgColor, force_overlay = true)
    array.push(bearFvgBoxes, bx)
    array.push(bearFvgTops, bearFvgTop)

if array.size(bullFvgBoxes) > 0
    for i = array.size(bullFvgBoxes) - 1 to 0
        if low <= array.get(bullFvgBottoms, i)
            if fvgDeleteFilled
                box.delete(array.get(bullFvgBoxes, i))
                array.remove(bullFvgBoxes, i)
                array.remove(bullFvgBottoms, i)
            else
                box.set_extend(array.get(bullFvgBoxes, i), extend.none)
                box.set_right(array.get(bullFvgBoxes, i), time)

if array.size(bearFvgBoxes) > 0
    for i = array.size(bearFvgBoxes) - 1 to 0
        if high >= array.get(bearFvgTops, i)
            if fvgDeleteFilled
                box.delete(array.get(bearFvgBoxes, i))
                array.remove(bearFvgBoxes, i)
                array.remove(bearFvgTops, i)
            else
                box.set_extend(array.get(bearFvgBoxes, i), extend.none)
                box.set_right(array.get(bearFvgBoxes, i), time)

while array.size(bullFvgBoxes) > fvgMaxEachSide
    box.delete(array.shift(bullFvgBoxes))
    array.shift(bullFvgBottoms)
while array.size(bearFvgBoxes) > fvgMaxEachSide
    box.delete(array.shift(bearFvgBoxes))
    array.shift(bearFvgTops)

// ───────────────────────── OPENING RANGE ────────────────────────────────────
bool inOrb = not na(time(timeframe.period, orbSession, orbTimezone))
bool orbStart = inOrb and not inOrb[1]
bool orbEnd = not inOrb and inOrb[1]
bool newNyDay = ta.change(time("D", "0000-2359", orbTimezone)) != 0
var float orbHigh = na
var float orbLow = na
var int orbStartBar = na
var box orbBox = na
var bool longBreakDone = false
var bool shortBreakDone = false
var bool longRetestDone = false
var bool shortRetestDone = false
var int longBreakBar = na
var int shortBreakBar = na

if newNyDay
    orbHigh := na
    orbLow := na
    orbStartBar := na
    longBreakDone := false
    shortBreakDone := false
    longRetestDone := false
    shortRetestDone := false
    longBreakBar := na
    shortBreakBar := na

if showOrb and orbStart
    orbHigh := high
    orbLow := low
    orbStartBar := bar_index
    if not na(orbBox)
        box.delete(orbBox)
    orbBox := box.new(bar_index, orbHigh, bar_index, orbLow, xloc = xloc.bar_index, border_color = color.new(orbHighColor, 25), bgcolor = orbBoxColor, force_overlay = true)

if showOrb and inOrb
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow := math.min(nz(orbLow, low), low)
    if not na(orbBox)
        box.set_top(orbBox, orbHigh)
        box.set_bottom(orbBox, orbLow)
        box.set_right(orbBox, bar_index)

if showOrb and orbEnd and not na(orbBox)
    box.set_extend(orbBox, extend.right)

plot(showOrb and not inOrb ? orbHigh : na, "ORB high", color = orbHighColor, linewidth = 2, style = plot.style_linebr, force_overlay = true)
plot(showOrb and not inOrb ? orbLow : na, "ORB low", color = orbLowColor, linewidth = 2, style = plot.style_linebr, force_overlay = true)
plot(showOrb and showOrbMid and not inOrb and not na(orbHigh) and not na(orbLow) ? (orbHigh + orbLow) / 2.0 : na, "ORB midpoint", color = orbMidColor, linewidth = 1, style = plot.style_linebr, force_overlay = true)

bool orbLongBreak = showOrb and showOrbBreakouts and not inOrb and not longBreakDone and not na(orbHigh) and close > orbHigh and close[1] <= orbHigh
bool orbShortBreak = showOrb and showOrbBreakouts and not inOrb and not shortBreakDone and not na(orbLow) and close < orbLow and close[1] >= orbLow

if orbLongBreak
    label.new(bar_index, low, "ORB LONG", style = label.style_label_up, color = color.new(color.aqua, 10), textcolor = color.black, size = size.tiny, force_overlay = true)
    longBreakDone := true
    longBreakBar := bar_index

if orbShortBreak
    label.new(bar_index, high, "ORB SHORT", style = label.style_label_down, color = color.new(color.fuchsia, 10), textcolor = color.white, size = size.tiny, force_overlay = true)
    shortBreakDone := true
    shortBreakBar := bar_index

bool orbLongRetest = showOrb and showOrbRetests and longBreakDone and not longRetestDone and bar_index > nz(longBreakBar, bar_index) and low <= orbHigh + atr * orbRetestToleranceAtr and close > orbHigh
bool orbShortRetest = showOrb and showOrbRetests and shortBreakDone and not shortRetestDone and bar_index > nz(shortBreakBar, bar_index) and high >= orbLow - atr * orbRetestToleranceAtr and close < orbLow

if orbLongRetest
    label.new(bar_index, low, "ORB RETEST", style = label.style_label_up, color = color.new(color.yellow, 10), textcolor = color.black, size = size.tiny, force_overlay = true)
    longRetestDone := true

if orbShortRetest
    label.new(bar_index, high, "ORB RETEST", style = label.style_label_down, color = color.new(color.orange, 10), textcolor = color.black, size = size.tiny, force_overlay = true)
    shortRetestDone := true

// ───────────────────────── CONFLUENCE ───────────────────────────────────────
bool emaBullish = close > ema20 and ema20 > ema50 and close > ema200
bool emaBearish = close < ema20 and ema20 < ema50 and close < ema200
bool orbBullish = not na(orbHigh) and close > orbHigh
bool orbBearish = not na(orbLow) and close < orbLow
bool volumeBullish = candleRvol >= highRvol
bool priceNearBullFvg = array.size(bullFvgBoxes) > 0
bool priceNearBearFvg = array.size(bearFvgBoxes) > 0

int longScore = 0
longScore += structureTrend == 1 ? 1 : 0
longScore += rsiValue > rsiMid and rsiValue < rsiUpper ? 1 : 0
longScore += volumeBullish ? 1 : 0
longScore += close > vwapValue ? 1 : 0
longScore += emaBullish ? 1 : 0
longScore += orbBullish ? 1 : 0
longScore += priceNearBullFvg ? 1 : 0

int shortScore = 0
shortScore += structureTrend == -1 ? 1 : 0
shortScore += rsiValue < rsiMid and rsiValue > rsiLower ? 1 : 0
shortScore += volumeBullish ? 1 : 0
shortScore += close < vwapValue ? 1 : 0
shortScore += emaBearish ? 1 : 0
shortScore += orbBearish ? 1 : 0
shortScore += priceNearBearFvg ? 1 : 0

bool longConfluence = showConfluenceMarkers and longScore >= minimumConfluence and longScore > shortScore
bool shortConfluence = showConfluenceMarkers and shortScore >= minimumConfluence and shortScore > longScore
plotshape(longConfluence, title = "BRO long confluence", style = shape.triangleup, location = location.belowbar, color = color.aqua, size = size.tiny, text = "BRO", force_overlay = true)
plotshape(shortConfluence, title = "BRO short confluence", style = shape.triangledown, location = location.abovebar, color = color.fuchsia, size = size.tiny, text = "BRO", force_overlay = true)

// ───────────────────────── DASHBOARD ────────────────────────────────────────
var table dashboard = table.new(position.top_right, 2, 9, border_width = 1)
if barstate.islast and showDashboard
    color headerBg = color.new(color.blue, 45)
    color cellBg = color.new(color.black, 25)
    table.cell(dashboard, 0, 0, "BRO MARKET MAP", bgcolor = headerBg, text_color = color.white)
    table.cell(dashboard, 1, 0, syminfo.ticker, bgcolor = headerBg, text_color = color.white)
    table.cell(dashboard, 0, 1, "Structure", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 1, structureTrend == 1 ? "Bullish" : structureTrend == -1 ? "Bearish" : "Neutral", bgcolor = cellBg, text_color = structureTrend == 1 ? color.aqua : structureTrend == -1 ? color.fuchsia : color.silver)
    table.cell(dashboard, 0, 2, "RSI (25/50/75)", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 2, str.tostring(rsiValue, "#.0"), bgcolor = cellBg, text_color = rsiValue > rsiMid ? color.aqua : color.fuchsia)
    table.cell(dashboard, 0, 3, "Candle RVOL", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 3, broFormatRvolV2(candleRvol), bgcolor = cellBg, text_color = candleRvol >= highRvol ? color.aqua : color.white)
    table.cell(dashboard, 0, 4, "Today's volume", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 4, broFormatVolumeV2(currentDailyVolume), bgcolor = cellBg, text_color = color.white)
    table.cell(dashboard, 0, 5, "Daily avg progress", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 5, na(dailyVolumeProgress) ? "n/a" : str.tostring(dailyVolumeProgress * 100.0, "#.0") + "%", bgcolor = cellBg, text_color = color.white)
    table.cell(dashboard, 0, 6, "EMA bias", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 6, emaBullish ? "Bullish" : emaBearish ? "Bearish" : "Mixed", bgcolor = cellBg, text_color = emaBullish ? color.aqua : emaBearish ? color.fuchsia : color.silver)
    table.cell(dashboard, 0, 7, "ORB", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 7, orbBullish ? "Above" : orbBearish ? "Below" : "Inside", bgcolor = cellBg, text_color = orbBullish ? color.aqua : orbBearish ? color.fuchsia : color.silver)
    table.cell(dashboard, 0, 8, "Confluence", bgcolor = cellBg, text_color = color.silver)
    table.cell(dashboard, 1, 8, "L " + str.tostring(longScore) + "/7  S " + str.tostring(shortScore) + "/7", bgcolor = cellBg, text_color = longScore > shortScore ? color.aqua : shortScore > longScore ? color.fuchsia : color.silver)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 8)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(bullishStructureBreak, "BRO bullish structure break", "Bullish BOS or CHoCH on {{ticker}}")
alertcondition(bearishStructureBreak, "BRO bearish structure break", "Bearish BOS or CHoCH on {{ticker}}")
alertcondition(bullFvgAllowed and fvgTime != lastBullFvgTime[1], "BRO bullish FVG", "New bullish FVG on {{ticker}}")
alertcondition(bearFvgAllowed and fvgTime != lastBearFvgTime[1], "BRO bearish FVG", "New bearish FVG on {{ticker}}")
alertcondition(orbLongBreak, "BRO ORB long", "Opening-range long breakout on {{ticker}}")
alertcondition(orbShortBreak, "BRO ORB short", "Opening-range short breakout on {{ticker}}")
alertcondition(longConfluence, "BRO long confluence", "High long confluence on {{ticker}}")
alertcondition(shortConfluence, "BRO short confluence", "High short confluence on {{ticker}}")
````
