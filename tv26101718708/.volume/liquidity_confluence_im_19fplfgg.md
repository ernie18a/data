# Liquidity Confluence [I.M]

- url: https://www.tradingview.com/script/19FplFGg/
- type: indicator
- pine_id: PUB;5c379aeaa79b4145b2ed09095f9ab1e8
- version: 1.0

## Description

Liquidity Confluence [I.M]

A confluence indicator that combines Smart Money Concepts (Fair Value Gaps and Break of Structure) with a rolling Volume Profile. Instead of treating SMC and volume analysis as separate tools, this indicator uses Volume Profile as a filter — only highlighting SMC events that occur inside high-volume zones (Value Area), where institutional liquidity is concentrated.

▶ WHY COMBINE SMC WITH VOLUME PROFILE?

SMC indicators alone produce many signals — most of them irrelevant noise. Volume Profile alone shows where liquidity sits but says nothing about direction. Combined, they answer the question every trader needs: "Is this structural break happening at a price level the market actually cares about?"

▶ COMPONENTS

1. ROLLING VOLUME PROFILE
A histogram of volume distributed across price rows, recalculated on every bar over the last N candles (default 150). Three key levels are derived:
- POC (Point of Control): the price with highest traded volume
- VAH (Value Area High): upper bound of the volume zone
- VAL (Value Area Low): lower bound of the volume zone

The histogram is rendered on the right side with a clean visual hierarchy:
- POC bar in solid yellow (the magnet level)
- VAH/VAL bars in violet (the boundary edges)
- Value Area bars in blue (the fair value zone)
- Out-of-VA bars in gray (low-interest zones)

2. FAIR VALUE GAPS (FVG)
3-candle imbalances where price moved too fast to fill. By default, only FVGs whose midpoint falls inside the Value Area are displayed — these are the high-probability gaps backed by real liquidity. Mitigated FVGs are automatically removed when price closes through them, keeping the chart clean.

3. BREAK OF STRUCTURE (BOS)
Detected when price closes beyond a recent swing high (bullish BOS) or swing low (bearish BOS). A BOS that breaks BEYOND the POC is marked as a strong signal (BOS ⬆ / BOS ⬇ with thicker line). A BOS that doesn't break the POC is considered weak — useful information rather than a tradeable signal.

▶ HOW TO TRADE WITH IT

The indicator is designed to filter, not predict. Use it as a confluence layer on top of your existing setup:

LONG SETUP:
- Price below POC, sweeps liquidity (low) and reclaims VAL
- Bullish FVG forms inside Value Area
- BOS ⬆ above POC confirms institutional commitment

SHORT SETUP:
- Price above POC, sweeps liquidity (high) and rejects VAH
- Bearish FVG forms inside Value Area
- BOS ⬇ below POC confirms institutional distribution

KEY LEVELS TO WATCH:
- Reaction at POC: strong magnet level, expect rejection or continuation
- Break of VAH/VAL: signals trend acceleration outside fair value
- Price returning to POC after breakout: classic retest opportunity

▶ SETTINGS

Volume Profile:
- Lookback: how many bars the profile considers (default 150)
- Profile Rows: vertical resolution of the histogram (default 60)
- Value Area %: percentage of volume defining the VA (default 70%)
- Histogram Width: visual width of the bars

SMC:
- Show FVGs / Only show FVGs inside Value Area
- Remove mitigated FVGs (cleaner chart)
- Max FVGs to display
- BOS Pivot Length (higher = only major swings)
- Only show BOS that breaks POC (extra filter)

Visual:
- Fully customizable colors for POC, Value Area, VA edges (VAH/VAL), histogram, bullish and bearish elements
- Optional info panel showing current levels and price location

▶ ALERTS INCLUDED

- Cross above/below POC
- Break above/below Value Area
- Bullish / Bearish BOS

▶ NOTES

This is a confluence tool, not a signal generator. It works best on liquid instruments with reliable volume data (futures, crypto, major forex pairs). On low-volume tickers, the profile may be noisy.

The unilateral filtering philosophy is intentional: most SMC signals fail because they ignore liquidity context. By gating events through the Value Area, the indicator forces traders to wait for confluence rather than chasing every gap or break.

Open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=6
indicator("Liquidity Confluence [I.M]", shorttitle="LiqConf [I.M]", overlay=true, max_bars_back=500, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═════════════════════════════════════════════════════════════════════════════
//                          LIQUIDITY CONFLUENCE [I.M]
// ─────────────────────────────────────────────────────────────────────────────
// A confluence indicator combining Smart Money Concepts (Fair Value Gaps and
// Break of Structure) with a rolling Volume Profile. Only highlights SMC events
// occurring inside high-volume zones (Value Area), filtering noise from
// liquidity-backed structure.
//
// @author  igormena
// @version 1.0
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const int    HIST_RIGHT_OFFSET   = 5
const int    LABEL_RIGHT_PADDING = 2
const int    FVG_LEFT_OFFSET     = 2
const int    BOS_LABEL_OFFSET    = 2

// ─────────────────────────────────────────────────────────────────────────────
// USER-DEFINED TYPES
// ─────────────────────────────────────────────────────────────────────────────

type FVG
    box   visual
    float top
    float bottom
    bool  isBullish

type VolumeProfile
    float poc
    float vah
    float val
    int   pocRow
    int   vaHighRow
    int   vaLowRow
    float maxVolume
    float rangeLow
    float rangeHigh

type StructureState
    float swingHigh   = na
    float swingLow    = na
    int   swingHighBar = na
    int   swingLowBar  = na
    bool  upFired     = false
    bool  downFired   = false

// ─────────────────────────────────────────────────────────────────────────────
// METHODS — FVG
// ─────────────────────────────────────────────────────────────────────────────
method isMitigated(FVG self, float price) =>
    self.isBullish ? price < self.bottom : price > self.top

method destroy(FVG self) =>
    box.delete(self.visual)

// ─────────────────────────────────────────────────────────────────────────────
// METHODS — VolumeProfile
// ─────────────────────────────────────────────────────────────────────────────
method containsPrice(VolumeProfile self, float price) =>
    price >= self.val and price <= self.vah

method locationLabel(VolumeProfile self, float price) =>
    price > self.vah ? "ABOVE VA" : price < self.val ? "BELOW VA" : "INSIDE VA"

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
g1 = "── Volume Profile ──"
vpLookback  = input.int(150,  "Lookback (bars)",       minval=20, maxval=500, group=g1)
vpRows      = input.int(60,   "Profile Rows",          minval=20, maxval=100, group=g1)
vaPercent   = input.float(70.0, "Value Area %",        minval=50.0, maxval=90.0, step=5.0, group=g1)
showHist    = input.bool(true,  "Show Histogram",      group=g1)
histWidth   = input.int(25,   "Histogram Width (bars)", minval=10, maxval=200, group=g1)

g2 = "── SMC: Fair Value Gaps ──"
showFVG     = input.bool(true,  "Show FVGs",           group=g2)
onlyVAFvg   = input.bool(true,  "Only show FVGs inside Value Area", group=g2)
mitigateFVG = input.bool(true,  "Remove mitigated FVGs", group=g2)
fvgLookback = input.int(15,   "Max FVGs to display",   minval=3, maxval=50, group=g2)
fvgExtend   = input.int(15,   "FVG Extension (bars)",  minval=5, maxval=100, group=g2)

g3 = "── SMC: Break of Structure ──"
showBOS       = input.bool(true,  "Show BOS",          group=g3)
bosPivotLen   = input.int(10,   "Pivot Length",        minval=2, maxval=30, group=g3)
onlyStrongBOS = input.bool(false, "Only show BOS that breaks POC", group=g3)

g4 = "── Visual ──"
pocColor   = input.color(color.rgb(255, 193, 7),    "POC Color",         group=g4)
vaColor    = input.color(color.rgb(33, 150, 243),   "Value Area Color",  group=g4)
vaEdgeColor = input.color(color.rgb(129, 212, 250), "VAH/VAL Edge Color", group=g4, tooltip="Color for the boundary rows of the Value Area (VAH and VAL)")
histColor  = input.color(color.rgb(140, 155, 170),  "Histogram Color",   group=g4)
bullColor  = input.color(color.rgb(38, 166, 154),   "Bullish Color",     group=g4)
bearColor  = input.color(color.rgb(239, 83, 80),    "Bearish Color",     group=g4)
showPanel  = input.bool(true,  "Show Info Panel",     group=g4)

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTIONS — Volume Profile Calculation
// ─────────────────────────────────────────────────────────────────────────────
buildVolumeDistribution(int lookback, int rows, float rangeLow, float rangeHigh) =>
    distribution = array.new<float>(rows, 0.0)
    rowHeight = (rangeHigh - rangeLow) / rows

    if rowHeight > 0
        for i = 0 to lookback - 1
            barHigh = high[i]
            barLow  = low[i]
            barVol  = volume[i]
            if not na(barHigh) and not na(barLow) and not na(barVol)
                lowRow  = math.max(0, math.floor((barLow  - rangeLow) / rowHeight))
                highRow = math.min(rows - 1, math.floor((barHigh - rangeLow) / rowHeight))
                rowsSpanned = math.max(1, highRow - lowRow + 1)
                volPerRow = barVol / rowsSpanned
                for r = lowRow to highRow
                    array.set(distribution, r, array.get(distribution, r) + volPerRow)
    distribution

findPOC(array<float> distribution) =>
    pocRow = 0
    maxVol = 0.0
    totalVol = 0.0
    n = array.size(distribution)
    for r = 0 to n - 1
        v = array.get(distribution, r)
        totalVol += v
        if v > maxVol
            maxVol := v
            pocRow := r
    [pocRow, maxVol, totalVol]

calculateValueArea(array<float> distribution, int pocRow, float targetVol, float startVol) =>
    n = array.size(distribution)
    vaVol = startVol
    vaHighRow = pocRow
    vaLowRow  = pocRow

    while vaVol < targetVol and (vaHighRow < n - 1 or vaLowRow > 0)
        volAbove = vaHighRow < n - 1 ? array.get(distribution, vaHighRow + 1) : 0.0
        volBelow = vaLowRow  > 0     ? array.get(distribution, vaLowRow  - 1) : 0.0
        if volAbove >= volBelow and vaHighRow < n - 1
            vaHighRow += 1
            vaVol += volAbove
        else if vaLowRow > 0
            vaLowRow -= 1
            vaVol += volBelow
        else
            break
    [vaLowRow, vaHighRow]

computeVolumeProfile() =>
    rangeHigh = ta.highest(high, vpLookback)
    rangeLow  = ta.lowest(low,   vpLookback)
    rowHeight = (rangeHigh - rangeLow) / vpRows

    distribution = buildVolumeDistribution(vpLookback, vpRows, rangeLow, rangeHigh)
    [pocRow, maxVol, totalVol] = findPOC(distribution)

    targetVol = totalVol * vaPercent / 100.0
    [vaLowRow, vaHighRow] = calculateValueArea(distribution, pocRow, targetVol, maxVol)

    poc = rangeLow + (pocRow + 0.5) * rowHeight
    vah = rangeLow + (vaHighRow + 1) * rowHeight
    val = rangeLow + vaLowRow * rowHeight

    VolumeProfile.new(poc, vah, val, pocRow, vaHighRow, vaLowRow, maxVol, rangeLow, rangeHigh)

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTIONS — Rendering
// ─────────────────────────────────────────────────────────────────────────────
renderHistogram(VolumeProfile vp, array<box> histBoxes) =>
    if array.size(histBoxes) > 0
        for i = 0 to array.size(histBoxes) - 1
            box.delete(array.get(histBoxes, i))
        array.clear(histBoxes)

    if showHist and vp.maxVolume > 0
        rightAnchor = bar_index + HIST_RIGHT_OFFSET
        rowHeight = (vp.rangeHigh - vp.rangeLow) / vpRows
        distribution = buildVolumeDistribution(vpLookback, vpRows, vp.rangeLow, vp.rangeHigh)

        for r = 0 to vpRows - 1
            v = array.get(distribution, r)
            if v > 0
                rowLow  = vp.rangeLow + r * rowHeight
                rowHigh = rowLow + rowHeight
                barLen  = math.round((v / vp.maxVolume) * histWidth)
                isInVA  = r >= vp.vaLowRow and r <= vp.vaHighRow
                isPOC   = r == vp.pocRow
                isEdge  = r == vp.vaHighRow or r == vp.vaLowRow

                col = isPOC  ? color.new(pocColor, 0)
                     : isEdge ? color.new(vaEdgeColor, 20)
                     : isInVA ? color.new(vaColor, 50)
                     : color.new(histColor, 30)

                b = box.new(left=rightAnchor, top=rowHigh, right=rightAnchor + barLen, bottom=rowLow,
                           bgcolor=col, border_color=col, border_width=0)
                array.push(histBoxes, b)

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT STATE
// ─────────────────────────────────────────────────────────────────────────────
var box[] histBoxes = array.new<box>()
var FVG[] fvgs      = array.new<FVG>()
var StructureState structure = StructureState.new()

var line  pocLine  = na
var line  vahLine  = na
var line  valLine  = na
var label pocLabel = na
var label vahLabel = na
var label valLabel = na

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Volume Profile
// ─────────────────────────────────────────────────────────────────────────────
vp = computeVolumeProfile()

if barstate.islast
    renderHistogram(vp, histBoxes)

    line.delete(pocLine), line.delete(vahLine), line.delete(valLine)
    label.delete(pocLabel), label.delete(vahLabel), label.delete(valLabel)

    leftAnchor  = bar_index - vpLookback
    rightAnchor = bar_index + HIST_RIGHT_OFFSET
    labelX      = rightAnchor + histWidth + LABEL_RIGHT_PADDING

    pocLine := line.new(leftAnchor, vp.poc, rightAnchor, vp.poc,
                       color=color.new(pocColor, 20), width=1, style=line.style_solid)
    vahLine := line.new(leftAnchor, vp.vah, rightAnchor, vp.vah,
                       color=color.new(vaEdgeColor, 30), width=1, style=line.style_dotted)
    valLine := line.new(leftAnchor, vp.val, rightAnchor, vp.val,
                       color=color.new(vaEdgeColor, 30), width=1, style=line.style_dotted)

    pocLabel := label.new(labelX, vp.poc, "POC",
                         color=color.new(color.black, 100), textcolor=pocColor,
                         style=label.style_label_left, size=size.tiny)
    vahLabel := label.new(labelX, vp.vah, "VAH",
                         color=color.new(color.black, 100), textcolor=vaEdgeColor,
                         style=label.style_label_left, size=size.tiny)
    valLabel := label.new(labelX, vp.val, "VAL",
                         color=color.new(color.black, 100), textcolor=vaEdgeColor,
                         style=label.style_label_left, size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Fair Value Gaps with Mitigation
// ─────────────────────────────────────────────────────────────────────────────
if mitigateFVG and array.size(fvgs) > 0
    i = array.size(fvgs) - 1
    while i >= 0
        f = array.get(fvgs, i)
        if f.isMitigated(close)
            f.destroy()
            array.remove(fvgs, i)
        i -= 1

if showFVG
    bullFVG = low > high[2]
    bearFVG = high < low[2]

    if bullFVG
        gapTop = low
        gapBot = high[2]
        gapMid = (gapTop + gapBot) / 2
        inVA = vp.containsPrice(gapMid)
        if inVA or not onlyVAFvg
            col = inVA ? color.new(bullColor, 75) : color.new(bullColor, 92)
            borderCol = inVA ? color.new(bullColor, 60) : color.new(bullColor, 88)
            visual = box.new(left=bar_index - FVG_LEFT_OFFSET, top=gapTop,
                           right=bar_index + fvgExtend, bottom=gapBot,
                           bgcolor=col, border_color=borderCol, border_width=1)
            newFVG = FVG.new(visual, gapTop, gapBot, true)
            array.push(fvgs, newFVG)
            if array.size(fvgs) > fvgLookback
                old = array.shift(fvgs)
                old.destroy()

    if bearFVG
        gapTop = low[2]
        gapBot = high
        gapMid = (gapTop + gapBot) / 2
        inVA = vp.containsPrice(gapMid)
        if inVA or not onlyVAFvg
            col = inVA ? color.new(bearColor, 75) : color.new(bearColor, 92)
            borderCol = inVA ? color.new(bearColor, 60) : color.new(bearColor, 88)
            visual = box.new(left=bar_index - FVG_LEFT_OFFSET, top=gapTop,
                           right=bar_index + fvgExtend, bottom=gapBot,
                           bgcolor=col, border_color=borderCol, border_width=1)
            newFVG = FVG.new(visual, gapTop, gapBot, false)
            array.push(fvgs, newFVG)
            if array.size(fvgs) > fvgLookback
                old = array.shift(fvgs)
                old.destroy()

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Break of Structure
// ─────────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(high, bosPivotLen, bosPivotLen)
pl = ta.pivotlow(low,   bosPivotLen, bosPivotLen)

if not na(ph)
    structure.swingHigh    := ph
    structure.swingHighBar := bar_index - bosPivotLen
    structure.upFired      := false

if not na(pl)
    structure.swingLow    := pl
    structure.swingLowBar := bar_index - bosPivotLen
    structure.downFired   := false

bosUp = showBOS and not na(structure.swingHigh) and close > structure.swingHigh and not structure.upFired
if bosUp
    structure.upFired := true
    isStrong = close > vp.poc
    if isStrong or not onlyStrongBOS
        lineCol = isStrong ? bullColor : color.new(bullColor, 60)
        line.new(structure.swingHighBar, structure.swingHigh, bar_index, structure.swingHigh,
                color=lineCol, width=isStrong ? 2 : 1, style=line.style_dashed)
        label.new(bar_index + BOS_LABEL_OFFSET, structure.swingHigh,
                 isStrong ? "BOS ⬆" : "BOS",
                 color=color.new(bullColor, 70), textcolor=color.white,
                 style=label.style_label_left, size=size.normal)

bosDown = showBOS and not na(structure.swingLow) and close < structure.swingLow and not structure.downFired
if bosDown
    structure.downFired := true
    isStrong = close < vp.poc
    if isStrong or not onlyStrongBOS
        lineCol = isStrong ? bearColor : color.new(bearColor, 60)
        line.new(structure.swingLowBar, structure.swingLow, bar_index, structure.swingLow,
                color=lineCol, width=isStrong ? 2 : 1, style=line.style_dashed)
        label.new(bar_index + BOS_LABEL_OFFSET, structure.swingLow,
                 isStrong ? "BOS ⬇" : "BOS",
                 color=color.new(bearColor, 70), textcolor=color.white,
                 style=label.style_label_left, size=size.normal)

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Info Panel
// ─────────────────────────────────────────────────────────────────────────────
if showPanel and barstate.islast
    var table panel = table.new(position.top_right, 2, 5,
                               bgcolor=color.new(color.black, 70),
                               border_width=1, border_color=color.new(color.gray, 70))

    locTxt = vp.locationLabel(close)
    locCol = close > vp.vah ? bullColor : close < vp.val ? bearColor : vaColor
    vaRange = (vp.vah - vp.val) / vp.val * 100

    table.cell(panel, 0, 0, "POC",      text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 0, str.tostring(vp.poc, format.mintick), text_color=pocColor, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 1, "VAH",      text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 1, str.tostring(vp.vah, format.mintick), text_color=vaEdgeColor, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 2, "VAL",      text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 2, str.tostring(vp.val, format.mintick), text_color=vaEdgeColor, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 3, "Price",    text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 3, locTxt,     text_color=locCol,      text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 4, "VA Range", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 4, str.tostring(vaRange, "#.##") + " %", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 50))

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(close,  vp.poc), title="Cross Above POC", message="Liquidity Confluence: Price crossed ABOVE POC")
alertcondition(ta.crossunder(close, vp.poc), title="Cross Below POC", message="Liquidity Confluence: Price crossed BELOW POC")
alertcondition(ta.crossover(close,  vp.vah), title="Break Above VA",  message="Liquidity Confluence: Price broke ABOVE Value Area")
alertcondition(ta.crossunder(close, vp.val), title="Break Below VA",  message="Liquidity Confluence: Price broke BELOW Value Area")
alertcondition(bosUp,   title="BOS Bullish", message="Liquidity Confluence: Bullish Break of Structure")
alertcondition(bosDown, title="BOS Bearish", message="Liquidity Confluence: Bearish Break of Structure")
````
