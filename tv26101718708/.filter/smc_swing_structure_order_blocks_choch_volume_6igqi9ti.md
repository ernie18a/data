# SMC Swing Structure + Order Blocks + CHoCH Volume

- url: https://www.tradingview.com/script/6igqi9Ti-SMC-Swing-Structure-Order-Blocks-CHoCH-Volume/
- type: indicator
- pine_id: PUB;9753bc22dfb1442d87af8bfb2f5630ce
- version: 2.0

## Description

[b]OrderBlock Radar — SMC Swing & Volume CHoCH[/b]

A Smart Money Concepts (SMC) toolkit that maps market structure and order blocks the way institutional order flow is typically read — without drowning your chart in noise from minor pivots.

[b]What it does:[/b]

📊 Swing Structure (BOS / CHoCH) — Tracks the market's real trend using major swing highs and lows, not every small wiggle. A break with the trend is marked BOS (Break of Structure); a break against the trend is marked CHoCH (Change of Character) — the earliest, most reliable signal that momentum may be shifting.

📦 Order Blocks — Automatically plots the last opposing candle before each structural break — the classic "footprint" of where smart money likely entered before the move. Boxes extend forward and auto-delete once price mitigates them, so your chart only shows blocks that are still relevant.

🔊 Volume-Confirmed CHoCH — Not all character changes are equal. This indicator checks volume against its recent average at the moment of a CHoCH — when a break comes with a volume spike, it's tagged separately ("CHoCH ⚡Vol") and fires its own dedicated alert, helping you filter high-conviction reversals from low-volume fakeouts.

🔔 Built-in Alerts — Six alert conditions ready to go: bullish/bearish CHoCH, bullish/bearish CHoCH with volume confirmation, and bullish/bearish BOS. Set them once and get pinged the moment structure shifts.

[b]Customizable settings:[/b]

Swing pivot sensitivity (how "major" a swing needs to be to count)
Optional internal (minor) structure overlay for extra context
Order block count limits, lookback range, and mitigation method (wick vs. close)
Volume average length and spike threshold
Full color and label control

How to use it: Best used as a structural context tool — combine CHoCH signals with your own entry confirmation (order block retest, FVG fill, liquidity sweep, etc.) rather than trading the label in isolation. Works on any timeframe and asset class; higher timeframes and liquid instruments tend to give the cleanest structure.

This is a technical analysis tool, not financial advice — always manage risk and confirm signals with your own strategy.

## Source Code

````pine
//@version=6
indicator("SMC Swing Structure + Order Blocks + FVG + CHoCH Volume", shorttitle="OrderBlock Radar", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================
//  Smart Money Concepts — Swing Structure (BOS/CHoCH)
//  + Order Blocks + Fair Value Gaps + Volume-Confirmed CHoCH
//
//  CHoCH / BOS are based only on the major SWING structure
//  (large pivot length), not every minor internal pivot.
//  An optional faint "internal" structure layer is available
//  for context but does not drive CHoCH/OB/alerts.
// ============================================================

// ---------------- Inputs ----------------
grpSwing   = "Swing Structure (drives CHoCH / BOS / OB)"
swingLen   = input.int(50, "Swing Lookback (pivot strength)", minval=2, group=grpSwing)
showBOS    = input.bool(true, "Show BOS labels", group=grpSwing)
showCHoCH  = input.bool(true, "Show CHoCH labels", group=grpSwing)
showLines  = input.bool(true, "Draw structure break lines", group=grpSwing)
bullColor  = input.color(color.new(color.teal, 0), "Bullish color", group=grpSwing)
bearColor  = input.color(color.new(color.red, 0), "Bearish color", group=grpSwing)

grpInt     = "Internal Structure (optional, cosmetic only)"
showInt    = input.bool(false, "Show internal structure (minor pivots)", group=grpInt)
intLen     = input.int(5, "Internal Lookback (pivot strength)", minval=1, group=grpInt)
intColor   = input.color(color.new(color.gray, 55), "Internal label color", group=grpInt)

grpOB      = "Order Blocks"
showOB     = input.bool(true, "Show Order Blocks", group=grpOB)
obMax      = input.int(15, "Max active OBs per side", minval=1, maxval=50, group=grpOB)
obLookback = input.int(50, "OB search lookback (bars)", minval=5, maxval=200, group=grpOB)
mitigateBy = input.string("Wick", "Mitigation trigger", options=["Wick", "Close"], group=grpOB)
obShowMid  = input.bool(true, "Show OB 50% equilibrium line", group=grpOB)
obBullFill = input.color(color.new(color.teal, 85), "Bullish OB fill", group=grpOB)
obBearFill = input.color(color.new(color.red, 85), "Bearish OB fill", group=grpOB)
obBorder   = input.color(color.new(color.gray, 60), "OB border", group=grpOB)

grpFVG     = "Fair Value Gaps (FVG)"
showFVG    = input.bool(false, "Enable FVG detection", group=grpFVG)
fvgMax     = input.int(30, "Max active FVGs per side", minval=1, maxval=100, group=grpFVG)
fvgExtend  = input.int(20, "Box extend (bars)", minval=1, maxval=200, group=grpFVG)
fvgMinATR  = input.float(0.0, "Min gap size (x ATR, 0 = off)", minval=0.0, step=0.05, group=grpFVG)
fvgMitBy   = input.string("Wick", "Mitigation trigger", options=["Wick", "Close"], group=grpFVG)
fvgFadeOnMit = input.bool(true, "Fade box instead of deleting on partial fill", group=grpFVG)
fvgShowMid = input.bool(true, "Show FVG 50% equilibrium line", group=grpFVG)
fvgOnlyWithTrend = input.bool(false, "Only show FVGs aligned with current swing trend", group=grpFVG)
fvgBullFill = input.color(color.new(color.lime, 82), "Bullish FVG fill", group=grpFVG)
fvgBearFill = input.color(color.new(color.orange, 82), "Bearish FVG fill", group=grpFVG)
fvgBorder  = input.color(color.new(color.gray, 70), "FVG border", group=grpFVG)

grpVol     = "Volume Confirmation"
volLen     = input.int(20, "Volume average length", minval=1, group=grpVol)
volMult    = input.float(1.5, "Spike threshold (x average)", minval=0.1, step=0.1, group=grpVol)

grpInfo    = "Info Table"
showTable  = input.bool(true, "Show status table", group=grpInfo)
tablePos   = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpInfo)

// ============================================================
//  SWING STRUCTURE (major pivots — drives CHoCH / BOS / OB)
// ============================================================
float swPH = ta.pivothigh(high, swingLen, swingLen)
float swPL = ta.pivotlow(low, swingLen, swingLen)

var float swTopY = na
var int   swTopX = na
var bool  swTopCrossed = true

var float swBotY = na
var int   swBotX = na
var bool  swBotCrossed = true

if not na(swPH)
    swTopY := swPH
    swTopX := bar_index - swingLen
    swTopCrossed := false

if not na(swPL)
    swBotY := swPL
    swBotX := bar_index - swingLen
    swBotCrossed := false

var int swTrend = 0   // 1 = bullish swing structure, -1 = bearish

swBullBreak = not na(swTopY) and not swTopCrossed and close > swTopY
swBearBreak = not na(swBotY) and not swBotCrossed and close < swBotY

isCHoCHBull = swBullBreak and swTrend == -1
isBOSBull   = swBullBreak and swTrend != -1
isCHoCHBear = swBearBreak and swTrend == 1
isBOSBear   = swBearBreak and swTrend != 1

// volume confirmation (applies to swing-level CHoCH only)
volAvg   = ta.sma(volume, volLen)
volSpike = volume > volAvg * volMult

// ATR used for FVG min-size filtering
atrVal = ta.atr(14)

// ============================================================
//  INTERNAL STRUCTURE (minor pivots — cosmetic only, optional)
// ============================================================
float inPH = ta.pivothigh(high, intLen, intLen)
float inPL = ta.pivotlow(low, intLen, intLen)

var float inTopY = na
var int   inTopX = na
var bool  inTopCrossed = true

var float inBotY = na
var int   inBotX = na
var bool  inBotCrossed = true

if not na(inPH)
    inTopY := inPH
    inTopX := bar_index - intLen
    inTopCrossed := false

if not na(inPL)
    inBotY := inPL
    inBotX := bar_index - intLen
    inBotCrossed := false

var int inTrend = 0

inBullBreak = not na(inTopY) and not inTopCrossed and close > inTopY
inBearBreak = not na(inBotY) and not inBotCrossed and close < inBotY

if showInt and inBullBreak
    txt = inTrend == -1 ? "choch" : "bos"
    label.new(bar_index, low, txt, style=label.style_label_up, color=intColor, textcolor=color.white, size=size.tiny)

if showInt and inBearBreak
    txt = inTrend == 1 ? "choch" : "bos"
    label.new(bar_index, high, txt, style=label.style_label_down, color=intColor, textcolor=color.white, size=size.tiny)

if inBullBreak
    inTopCrossed := true
    inTrend := 1
if inBearBreak
    inBotCrossed := true
    inTrend := -1

// ============================================================
//  ORDER BLOCKS (created only on swing-structure breaks)
// ============================================================
findLastDown() =>
    float obH = na
    float obL = na
    int   obB = na
    for i = 1 to obLookback
        if close[i] < open[i]
            obH := high[i]
            obL := low[i]
            obB := bar_index - i
            break
    [obH, obL, obB]

findLastUp() =>
    float obH = na
    float obL = na
    int   obB = na
    for i = 1 to obLookback
        if close[i] > open[i]
            obH := high[i]
            obL := low[i]
            obB := bar_index - i
            break
    [obH, obL, obB]

var box[] bullBoxes = array.new<box>()
var box[] bearBoxes = array.new<box>()
var line[] bullMidLines = array.new<line>()
var line[] bearMidLines = array.new<line>()

if showOB and swBullBreak
    [obH, obL, obB] = findLastDown()
    if not na(obH)
        newBox = box.new(left=obB, top=obH, right=bar_index + 20, bottom=obL, border_color=obBorder, bgcolor=obBullFill, extend=extend.none)
        array.push(bullBoxes, newBox)
        if obShowMid
            midY = (obH + obL) / 2
            newMid = line.new(obB, midY, bar_index + 20, midY, color=color.new(obBorder, 30), style=line.style_dotted)
            array.push(bullMidLines, newMid)
        if array.size(bullBoxes) > obMax
            box.delete(array.shift(bullBoxes))
            if obShowMid and array.size(bullMidLines) > 0
                line.delete(array.shift(bullMidLines))

if showOB and swBearBreak
    [obH, obL, obB] = findLastUp()
    if not na(obH)
        newBox = box.new(left=obB, top=obH, right=bar_index + 20, bottom=obL, border_color=obBorder, bgcolor=obBearFill, extend=extend.none)
        array.push(bearBoxes, newBox)
        if obShowMid
            midY = (obH + obL) / 2
            newMid = line.new(obB, midY, bar_index + 20, midY, color=color.new(obBorder, 30), style=line.style_dotted)
            array.push(bearMidLines, newMid)
        if array.size(bearBoxes) > obMax
            box.delete(array.shift(bearBoxes))
            if obShowMid and array.size(bearMidLines) > 0
                line.delete(array.shift(bearMidLines))

if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0
        bx = array.get(bullBoxes, i)
        bot = box.get_bottom(bx)
        mitigated = mitigateBy == "Wick" ? low <= bot : close <= bot
        if mitigated
            box.delete(bx)
            array.remove(bullBoxes, i)
            if obShowMid and array.size(bullMidLines) > i
                line.delete(array.get(bullMidLines, i))
                array.remove(bullMidLines, i)
        else
            box.set_right(bx, bar_index + 20)
            if obShowMid and array.size(bullMidLines) > i
                line.set_x2(array.get(bullMidLines, i), bar_index + 20)

if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0
        bx = array.get(bearBoxes, i)
        top = box.get_top(bx)
        mitigated = mitigateBy == "Wick" ? high >= top : close >= top
        if mitigated
            box.delete(bx)
            array.remove(bearBoxes, i)
            if obShowMid and array.size(bearMidLines) > i
                line.delete(array.get(bearMidLines, i))
                array.remove(bearMidLines, i)
        else
            box.set_right(bx, bar_index + 20)
            if obShowMid and array.size(bearMidLines) > i
                line.set_x2(array.get(bearMidLines, i), bar_index + 20)

// ============================================================
//  FAIR VALUE GAPS (3-candle imbalance, classic ICT definition)
//  Bullish FVG: low[0] > high[2]   -> gap between high[2] and low[0]
//  Bearish FVG: high[0] < low[2]   -> gap between low[2] and high[0]
// ============================================================
var box[]  fvgBullBoxes = array.new<box>()
var box[]  fvgBearBoxes = array.new<box>()
var line[] fvgBullMid   = array.new<line>()
var line[] fvgBearMid   = array.new<line>()
var bool[] fvgBullFaded = array.new<bool>()
var bool[] fvgBearFaded = array.new<bool>()

bullGapUp   = low - high[2]
bearGapDown = low[2] - high

isBullFVG = showFVG and low > high[2] and (fvgMinATR <= 0 or bullGapUp >= atrVal * fvgMinATR)
isBearFVG = showFVG and high < low[2] and (fvgMinATR <= 0 or bearGapDown >= atrVal * fvgMinATR)

bullTrendOK = not fvgOnlyWithTrend or swTrend == 1
bearTrendOK = not fvgOnlyWithTrend or swTrend == -1

if isBullFVG and bullTrendOK
    top = low
    bot = high[2]
    newBox = box.new(left=bar_index - 2, top=top, right=bar_index + fvgExtend, bottom=bot, border_color=fvgBorder, bgcolor=fvgBullFill, extend=extend.none)
    array.push(fvgBullBoxes, newBox)
    array.push(fvgBullFaded, false)
    if fvgShowMid
        midY = (top + bot) / 2
        newMid = line.new(bar_index - 2, midY, bar_index + fvgExtend, midY, color=color.new(fvgBorder, 20), style=line.style_dotted)
        array.push(fvgBullMid, newMid)
    if array.size(fvgBullBoxes) > fvgMax
        box.delete(array.shift(fvgBullBoxes))
        array.shift(fvgBullFaded)
        if fvgShowMid and array.size(fvgBullMid) > 0
            line.delete(array.shift(fvgBullMid))

if isBearFVG and bearTrendOK
    top = low[2]
    bot = high
    newBox = box.new(left=bar_index - 2, top=top, right=bar_index + fvgExtend, bottom=bot, border_color=fvgBorder, bgcolor=fvgBearFill, extend=extend.none)
    array.push(fvgBearBoxes, newBox)
    array.push(fvgBearFaded, false)
    if fvgShowMid
        midY = (top + bot) / 2
        newMid = line.new(bar_index - 2, midY, bar_index + fvgExtend, midY, color=color.new(fvgBorder, 20), style=line.style_dotted)
        array.push(fvgBearMid, newMid)
    if array.size(fvgBearBoxes) > fvgMax
        box.delete(array.shift(fvgBearBoxes))
        array.shift(fvgBearFaded)
        if fvgShowMid and array.size(fvgBearMid) > 0
            line.delete(array.shift(fvgBearMid))

// manage bullish FVGs: fade on partial fill, delete on full fill
fvgBullFilled = false
if array.size(fvgBullBoxes) > 0
    for i = array.size(fvgBullBoxes) - 1 to 0
        bx = array.get(fvgBullBoxes, i)
        top = box.get_top(bx)
        bot = box.get_bottom(bx)
        fullyFilled = fvgMitBy == "Wick" ? low <= bot : close <= bot
        touched    = fvgMitBy == "Wick" ? low <= top : close <= top
        if fullyFilled
            box.delete(bx)
            array.remove(fvgBullBoxes, i)
            array.remove(fvgBullFaded, i)
            if fvgShowMid and array.size(fvgBullMid) > i
                line.delete(array.get(fvgBullMid, i))
                array.remove(fvgBullMid, i)
            fvgBullFilled := true
        else
            box.set_right(bx, bar_index + fvgExtend)
            if fvgShowMid and array.size(fvgBullMid) > i
                line.set_x2(array.get(fvgBullMid, i), bar_index + fvgExtend)
            if touched and fvgFadeOnMit and not array.get(fvgBullFaded, i)
                box.set_bgcolor(bx, color.new(color.gray, 90))
                array.set(fvgBullFaded, i, true)

// manage bearish FVGs
fvgBearFilled = false
if array.size(fvgBearBoxes) > 0
    for i = array.size(fvgBearBoxes) - 1 to 0
        bx = array.get(fvgBearBoxes, i)
        top = box.get_top(bx)
        bot = box.get_bottom(bx)
        fullyFilled = fvgMitBy == "Wick" ? high >= top : close >= top
        touched    = fvgMitBy == "Wick" ? high >= bot : close >= bot
        if fullyFilled
            box.delete(bx)
            array.remove(fvgBearBoxes, i)
            array.remove(fvgBearFaded, i)
            if fvgShowMid and array.size(fvgBearMid) > i
                line.delete(array.get(fvgBearMid, i))
                array.remove(fvgBearMid, i)
            fvgBearFilled := true
        else
            box.set_right(bx, bar_index + fvgExtend)
            if fvgShowMid and array.size(fvgBearMid) > i
                line.set_x2(array.get(fvgBearMid, i), bar_index + fvgExtend)
            if touched and fvgFadeOnMit and not array.get(fvgBearFaded, i)
                box.set_bgcolor(bx, color.new(color.gray, 90))
                array.set(fvgBearFaded, i, true)

// ============================================================
//  SWING STRUCTURE LABELS (the ones that matter)
// ============================================================
if isCHoCHBull and showCHoCH
    txt = volSpike ? "CHoCH  Vol" : "CHoCH"
    label.new(bar_index, low, txt, style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)
    if showLines
        line.new(swTopX, swTopY, bar_index, swTopY, color=bullColor, style=line.style_dashed)

if isBOSBull and showBOS
    label.new(bar_index, low, "BOS", style=label.style_label_up, color=color.new(bullColor, 40), textcolor=color.white, size=size.small)
    if showLines
        line.new(swTopX, swTopY, bar_index, swTopY, color=color.new(bullColor, 40), style=line.style_dotted)

if isCHoCHBear and showCHoCH
    txt = volSpike ? "CHoCH  Vol" : "CHoCH"
    label.new(bar_index, high, txt, style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)
    if showLines
        line.new(swBotX, swBotY, bar_index, swBotY, color=bearColor, style=line.style_dashed)

if isBOSBear and showBOS
    label.new(bar_index, high, "BOS", style=label.style_label_down, color=color.new(bearColor, 40), textcolor=color.white, size=size.small)
    if showLines
        line.new(swBotX, swBotY, bar_index, swBotY, color=color.new(bearColor, 40), style=line.style_dotted)

// consume break / update swing trend
if swBullBreak
    swTopCrossed := true
    swTrend := 1
if swBearBreak
    swBotCrossed := true
    swTrend := -1

// ============================================================
//  STATUS TABLE
// ============================================================
var table infoTable = na
if showTable and barstate.islast
    posMap = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
    if na(infoTable)
        infoTable := table.new(posMap, 2, 5, bgcolor=color.new(color.black, 75), border_width=1, border_color=color.new(color.gray, 50))
    trendTxt = swTrend == 1 ? "Bullish" : swTrend == -1 ? "Bearish" : "Undefined"
    trendCol = swTrend == 1 ? bullColor : swTrend == -1 ? bearColor : color.gray
    table.cell(infoTable, 0, 0, "Swing Trend", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, trendTxt, text_color=trendCol, text_size=size.small)
    table.cell(infoTable, 0, 1, "Active Bull OB", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(array.size(bullBoxes)), text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 0, 2, "Active Bear OB", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(array.size(bearBoxes)), text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 0, 3, "Active Bull FVG", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(array.size(fvgBullBoxes)), text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 0, 4, "Active Bear FVG", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(array.size(fvgBearBoxes)), text_color=color.gray, text_size=size.small)

// ---------------- Alerts ----------------
alertcondition(isCHoCHBull, title="Bullish CHoCH (Swing)", message="Bullish CHoCH on {{ticker}} {{interval}}")
alertcondition(isCHoCHBear, title="Bearish CHoCH (Swing)", message="Bearish CHoCH on {{ticker}} {{interval}}")
alertcondition(isCHoCHBull and volSpike, title="Bullish CHoCH + Volume Spike", message="Bullish CHoCH confirmed with volume spike on {{ticker}} {{interval}}")
alertcondition(isCHoCHBear and volSpike, title="Bearish CHoCH + Volume Spike", message="Bearish CHoCH confirmed with volume spike on {{ticker}} {{interval}}")
alertcondition(isBOSBull, title="Bullish BOS (Swing)", message="Bullish BOS on {{ticker}} {{interval}}")
alertcondition(isBOSBear, title="Bearish BOS (Swing)", message="Bearish BOS on {{ticker}} {{interval}}")
alertcondition(isBullFVG, title="Bullish FVG Formed", message="Bullish FVG formed on {{ticker}} {{interval}}")
alertcondition(isBearFVG, title="Bearish FVG Formed", message="Bearish FVG formed on {{ticker}} {{interval}}")
alertcondition(fvgBullFilled, title="Bullish FVG Filled", message="Bullish FVG fully filled on {{ticker}} {{interval}}")
alertcondition(fvgBearFilled, title="Bearish FVG Filled", message="Bearish FVG fully filled on {{ticker}} {{interval}}")
````
