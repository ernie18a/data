# ABC Breakout

- url: https://www.tradingview.com/script/s2CjjjAn-ABC-Breakout/
- type: indicator
- pine_id: PUB;d0f1c58f62ce414492fd964753330763
- version: 15.0

## Description

ABC Breakout detects bullish and bearish ABC retracement structures using adaptive pivot-based market structure and configurable retracement ratios. The indicator confirms setups only after price closes beyond point B, then automatically plots the entry, stop loss, and TP1 / TP2 / TP3 targets using customizable risk-reward settings.

The main inputs allow you to control pivot sensitivity, valid ABC retracement depth, overlap filtering, trade target ratios, historical pattern visibility, and confirmation display settings. Lower pivot settings produce faster and more frequent setups, while higher settings filter noise and focus on larger structure moves. The ABC ratio inputs help define how shallow or deep the C-point retracement must be before a setup becomes valid.

Use the indicator to trade continuation breakouts after pullbacks during trending conditions. Pending ABC structures can repaint or disappear while pivots are still developing because swing confirmation requires future candles. Once a breakout candle closes and the setup becomes confirmed, the pattern and trade levels are locked and do not repaint. The built-in stats window tracks how often TP1, TP2, and TP3 are reached before stop loss across closed trades, allowing traders to evaluate performance across different markets and timeframes.

## Source Code

````pine
//@version=6
indicator("ABC Breakout Pattern Finder", shorttitle = "ABC Breakout", overlay = true, max_lines_count = 500, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotLeft = input.int(8, "Pivot Bars Left", minval = 1, group = "Zigzag")
pivotRight = input.int(5, "Pivot Bars Right", minval = 1, group = "Zigzag")

minRatio = input.float(0.50, "Min ABC Ratio", minval = 0.1, maxval = 1.0, step = 0.01, group = "Pattern", tooltip = "Minimum BC retracement relative to AB required for a valid ABC pattern.")
maxRatio = input.float(0.80, "Max ABC Ratio", minval = 0.1, maxval = 2.0, step = 0.01, group = "Pattern", tooltip = "Maximum BC retracement relative to AB allowed for a valid ABC pattern.")
minABMultiplier = input.float(5.0, "Min AB Size (ATR Multiple)", minval = 0.5, step = 0.5, group = "Pattern", tooltip = "Minimum size of the AB impulse leg as a multiple of ATR(14). Filters out patterns formed on noise-level moves.")
atrLength = input.int(14, "ATR Length", minval = 1, group = "Pattern", tooltip = "Lookback period for ATR used in the minimum AB size filter.")
disallowOverlap = input.bool(true, "Disallow Pattern Overlap", group = "Pattern", tooltip = "Prevents new confirmed ABC patterns from forming inside the range of previously confirmed patterns.")

invalidatePendingOnCloseBeyondC = input.bool(true, "Invalidate Pending On Close Beyond C", group = "Pattern", tooltip = "Invalidates an unconfirmed ABC setup when price closes beyond the active C pivot before B breakout confirmation. Disabled automatically in FIB mode.")

// ── ATR Mode Targets (active when FIB mode is off) ─────────────────────
tp1Ratio = input.float(1.0, "TP1 Risk Reward Ratio", minval = 0.1, step = 0.1, group = "ATR Mode", tooltip = "Risk reward multiple for TP1. Used in ATR mode only.")
tp2Ratio = input.float(2.0, "TP2 Risk Reward Ratio", minval = 0.1, step = 0.1, group = "ATR Mode", tooltip = "Risk reward multiple for TP2. Used in ATR mode only.")
tp3Ratio = input.float(3.0, "TP3 Risk Reward Ratio", minval = 0.1, step = 0.1, group = "ATR Mode", tooltip = "Risk reward multiple for TP3. Used in ATR mode only.")

// ── FIB Mode Targets (active when FIB mode is on) ──────────────────────
fibMode = input.bool(false, "FIB Mode", group = "FIB Mode", tooltip = "When enabled, trade levels use structural Fibonacci targets.\n\nEntry = close of C bar\nStop = high/low of C bar\nTargets = Fibonacci extensions of AB projected from B.\n\nWhen disabled, the original ATR risk/reward system is used.")
fibTp1Ext = input.float(1.0, "TP1 Fib Extension", minval = 1.0, step = 0.001, group = "FIB Mode", tooltip = "AB extension projected from B for TP1. Default 1.000 = B pivot (100% of AB).")
fibTp2Ext = input.float(1.272, "TP2 Fib Extension", minval = 1.0, step = 0.001, group = "FIB Mode", tooltip = "AB extension projected from B for TP2. Default 1.272 = 127.2% extension.")
fibTp3Ext = input.float(1.618, "TP3 Fib Extension", minval = 1.0, step = 0.001, group = "FIB Mode", tooltip = "AB extension projected from B for TP3. Default 1.618 = 161.8% extension.")

showHistoricalPatterns = input.bool(true, "Show Historical ABC Patterns", group = "Historical Patterns")
historicalLookback = input.int(20, "Historical Closed Lookback", minval = 1, maxval = 100, group = "Historical Patterns", tooltip = "Controls both historical pattern visuals and stat window closed trades.")
historicalColor = input.color(color.purple, "Historical Pattern Color", group = "Historical Patterns")

closedTradeLookback = input.int(0, "Closed Trade Lookback", minval = 0, maxval = 20, group = "Trade Rewind", tooltip = "Visual rewind through closed trades. 0 = most recent open trade. 1 = most recent closed trade.")
closedTradeLookbackColor = input.color(color.red, "Closed Trade Lookback Color", group = "Trade Rewind")

tradeLevelBarsForward = input.int(5, "Trade Display Bars Forward", minval = 1, maxval = 100, group = "Display", tooltip = "Number of bars active trade levels and labels extend beyond the current candle.")

showTradeLevels = input.bool(true, "Show Trade Levels", group = "Display")
showZigzagLines = input.bool(true, "Show ABC Lines", group = "Display")
showABCLabels = input.bool(true, "Show ABC Labels", group = "Display")


pendingPatternColor = input.color(color.yellow, "Pending Pattern Color", group = "Display")
confirmedPatternColor = input.color(color.orange, "Confirmed Pattern Color", group = "Display")
entryColor = input.color(color.blue, "Entry Color", group = "Display")
stopColor = input.color(color.red, "Stop Loss Color", group = "Display")
targetColor = input.color(color.green, "Take Profit Color", group = "Display")

showConfirmationTriangles = input.bool(true, "Show Confirmation Triangles", group = "Display")
bullTriangleColor = input.color(color.green, "Bull Triangle Color", group = "Display")
bearTriangleColor = input.color(color.red, "Bear Triangle Color", group = "Display")
confirmationTriangleSizeInput = input.string("Tiny", "Confirmation Triangle Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Display")

showACLine = input.bool(true, "Show AC Line", group = "AC Line", tooltip = "Draws a straight line from pivot A to pivot C.")
acLineColor = input.color(color.blue, "AC Line Color", group = "AC Line")
acLineWidth = input.int(2, "AC Line Width", minval = 1, maxval = 4, group = "AC Line")
acLineStyleInput = input.string("Dotted", "AC Line Style", options = ["Solid", "Dashed", "Dotted"], group = "AC Line")

showStatsWindow = input.bool(true, "Show Stats Window", group = "Stats Window")
statsPositionInput = input.string("Top Right", "Stats Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = "Stats Window")
statsSizeInput = input.string("Small", "Stats Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Stats Window")
statsExitTarget = input.string("TP1", "P/L Exit Target", options = ["TP1", "TP2", "TP3"], group = "Stats Window", tooltip = "Sets where the whole position exits when the stats window calculates P/L. A trade counts as a win at this target's price if the target was hit before the stop, otherwise a loss at the stop price. Net P/L, Win Rate, Avg Win / Loss, Max Drawdown and Open Trade P/L use this rule. The TP1, TP2 and TP3 hit rates are always shown separately.")
statsBgColor = input.color(color.new(#131722, 10), "Stats Background Color", group = "Stats Window")
statsHeaderColor = input.color(color.new(#3B5B92, 0), "Stats Header Color", group = "Stats Window")
statsTextColor = input.color(color.white, "Stats Text Color", group = "Stats Window")
statsBorderColor = input.color(color.new(color.gray, 40), "Stats Border Color", group = "Stats Window")

transparentColor = color.new(color.white, 100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Types
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

type Trade
    float entry
    float stop
    float target1
    float target2
    float target3
    int direction
    int confirmationIndex = na
    bool active = false
    int status = 0
    bool tp1Hit = false
    bool tp2Hit = false
    bool tp3Hit = false

type PatternDrawing
    line ab
    line bc
    line ac
    line entryLine
    line stopLine
    line target1Line
    line target2Line
    line target3Line
    label aLabel
    label bLabel
    label cLabel
    label entryLabel
    label stopLabel
    label target1Label
    label target2Label
    label target3Label
    label confirmationTriangle

type Pattern
    int aIndex
    int bIndex
    int cIndex
    float aPrice
    float bPrice
    float cPrice
    Trade trade
    PatternDrawing drawing

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<int> pivotIndexes = array.new<int>()
var array<float> pivotPrices = array.new<float>()
var array<int> pivotTypes = array.new<int>()

var Pattern currentPattern = na
var array<Pattern> tradeLookbackPatterns = array.new<Pattern>()

var array<int> confirmedPatternStarts = array.new<int>()
var array<int> confirmedPatternEnds = array.new<int>()

var array<Trade> openTrades = array.new<Trade>()

var array<float> pnlHistory = array.new<float>()   // percent result per closed trade, using the P/L Exit Target rule
var array<float> gaps = array.new<float>()        // milliseconds between consecutive confirmed signals
var int lastSigTime = na
var array<bool> tp1History = array.new<bool>()
var array<bool> tp2History = array.new<bool>()
var array<bool> tp3History = array.new<bool>()

newABCDetectedSignal = false
abcInvalidatedSignal = false
abcBreakoutConfirmedSignal = false

bullishConfirmationSignal = false
bearishConfirmationSignal = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrValue = ta.atr(atrLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getStatsPosition(string pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Top Center" ? position.top_center :
     pos == "Top Right" ? position.top_right :
     pos == "Middle Left" ? position.middle_left :
     pos == "Middle Center" ? position.middle_center :
     pos == "Middle Right" ? position.middle_right :
     pos == "Bottom Left" ? position.bottom_left :
     pos == "Bottom Center" ? position.bottom_center :
     position.bottom_right

getStatsSize(string sz) =>
    sz == "Tiny" ? size.tiny :
     sz == "Small" ? size.small :
     sz == "Normal" ? size.normal :
     sz == "Large" ? size.large :
     size.huge

getTriangleSize(string sz) =>
    sz == "Tiny" ? size.tiny :
     sz == "Small" ? size.small :
     sz == "Normal" ? size.normal :
     size.large

getACLineStyle(string s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted" ? line.style_dotted :
     line.style_solid

countWins(array<bool> history) =>
    wins = 0
    if array.size(history) > 0
        for i = 0 to array.size(history) - 1
            if array.get(history, i)
                wins += 1
    wins

winRate(int wins, int total) =>
    total > 0 ? str.tostring(math.round((wins * 100.0) / total)) + "%" : "N/A"

deleteTradeDrawing(PatternDrawing d) =>
    if not na(d.entryLine)
        line.delete(d.entryLine)
        d.entryLine := na
    if not na(d.stopLine)
        line.delete(d.stopLine)
        d.stopLine := na
    if not na(d.target1Line)
        line.delete(d.target1Line)
        d.target1Line := na
    if not na(d.target2Line)
        line.delete(d.target2Line)
        d.target2Line := na
    if not na(d.target3Line)
        line.delete(d.target3Line)
        d.target3Line := na
    if not na(d.entryLabel)
        label.delete(d.entryLabel)
        d.entryLabel := na
    if not na(d.stopLabel)
        label.delete(d.stopLabel)
        d.stopLabel := na
    if not na(d.target1Label)
        label.delete(d.target1Label)
        d.target1Label := na
    if not na(d.target2Label)
        label.delete(d.target2Label)
        d.target2Label := na
    if not na(d.target3Label)
        label.delete(d.target3Label)
        d.target3Label := na

deleteDrawing(PatternDrawing d) =>
    if not na(d.ab)
        line.delete(d.ab)
        d.ab := na
    if not na(d.bc)
        line.delete(d.bc)
        d.bc := na
    if not na(d.ac)
        line.delete(d.ac)
        d.ac := na

    deleteTradeDrawing(d)

    if not na(d.aLabel)
        label.delete(d.aLabel)
        d.aLabel := na
    if not na(d.bLabel)
        label.delete(d.bLabel)
        d.bLabel := na
    if not na(d.cLabel)
        label.delete(d.cLabel)
        d.cLabel := na
    if not na(d.confirmationTriangle)
        label.delete(d.confirmationTriangle)
        d.confirmationTriangle := na

setDrawingColor(PatternDrawing d, color clr) =>
    if not na(d.ab)
        line.set_color(d.ab, clr)
    if not na(d.bc)
        line.set_color(d.bc, clr)
    if not na(d.aLabel)
        label.set_color(d.aLabel, clr)
    if not na(d.bLabel)
        label.set_color(d.bLabel, clr)
    if not na(d.cLabel)
        label.set_color(d.cLabel, clr)

setDrawingTextColor(PatternDrawing d, color clr) =>
    if not na(d.aLabel)
        label.set_textcolor(d.aLabel, clr)
    if not na(d.bLabel)
        label.set_textcolor(d.bLabel, clr)
    if not na(d.cLabel)
        label.set_textcolor(d.cLabel, clr)

setPatternVisible(PatternDrawing d, bool visible, color clr) =>
    patternClr = visible ? clr : transparentColor
    textClr = visible ? chart.bg_color : transparentColor
    setDrawingColor(d, patternClr)
    setDrawingTextColor(d, textClr)

setTradeDrawingVisible(PatternDrawing d, bool visible) =>
    eClr = visible ? entryColor : color.new(entryColor, 100)
    sClr = visible ? stopColor : color.new(stopColor, 100)
    tClr = visible ? targetColor : color.new(targetColor, 100)
    txtClr = visible ? color.white : transparentColor

    if not na(d.entryLine)
        line.set_color(d.entryLine, eClr)
    if not na(d.stopLine)
        line.set_color(d.stopLine, sClr)
    if not na(d.target1Line)
        line.set_color(d.target1Line, tClr)
    if not na(d.target2Line)
        line.set_color(d.target2Line, tClr)
    if not na(d.target3Line)
        line.set_color(d.target3Line, tClr)

    if not na(d.entryLabel)
        label.set_color(d.entryLabel, eClr)
        label.set_textcolor(d.entryLabel, txtClr)
    if not na(d.stopLabel)
        label.set_color(d.stopLabel, sClr)
        label.set_textcolor(d.stopLabel, txtClr)
    if not na(d.target1Label)
        label.set_color(d.target1Label, tClr)
        label.set_textcolor(d.target1Label, txtClr)
    if not na(d.target2Label)
        label.set_color(d.target2Label, tClr)
        label.set_textcolor(d.target2Label, txtClr)
    if not na(d.target3Label)
        label.set_color(d.target3Label, tClr)
        label.set_textcolor(d.target3Label, txtClr)

    if not na(d.ac)
        line.set_color(d.ac, visible and showACLine ? acLineColor : transparentColor)

setConfirmationTriangleVisible(PatternDrawing d, bool visible, int direction, bool useLookbackColor) =>
    if not na(d.confirmationTriangle)
        normalClr = direction > 0 ? bullTriangleColor : bearTriangleColor
        triClr = visible ? useLookbackColor ? closedTradeLookbackColor : normalClr : transparentColor
        label.set_color(d.confirmationTriangle, triClr)
        label.set_textcolor(d.confirmationTriangle, triClr)

extendTradeDrawing(PatternDrawing d, Trade t, int xEnd) =>
    if not na(d.entryLine)
        line.set_x2(d.entryLine, xEnd)
    if not na(d.stopLine)
        line.set_x2(d.stopLine, xEnd)
    if not na(d.target1Line)
        line.set_x2(d.target1Line, xEnd)
    if not na(d.target2Line)
        line.set_x2(d.target2Line, xEnd)
    if not na(d.target3Line)
        line.set_x2(d.target3Line, xEnd)

    if not na(d.entryLabel)
        label.set_x(d.entryLabel, xEnd)
        label.set_y(d.entryLabel, t.entry)
    if not na(d.stopLabel)
        label.set_x(d.stopLabel, xEnd)
        label.set_y(d.stopLabel, t.stop)
    if not na(d.target1Label)
        label.set_x(d.target1Label, xEnd)
        label.set_y(d.target1Label, t.target1)
    if not na(d.target2Label)
        label.set_x(d.target2Label, xEnd)
        label.set_y(d.target2Label, t.target2)
    if not na(d.target3Label)
        label.set_x(d.target3Label, xEnd)
        label.set_y(d.target3Label, t.target3)

addConfirmedPatternRange(int startIndex, int endIndex) =>
    array.push(confirmedPatternStarts, startIndex)
    array.push(confirmedPatternEnds, endIndex)

    if array.size(confirmedPatternStarts) > 200
        array.shift(confirmedPatternStarts)
        array.shift(confirmedPatternEnds)

startsInsideConfirmedPattern(int startIndex) =>
    inside = false

    if array.size(confirmedPatternStarts) > 0
        for i = 0 to array.size(confirmedPatternStarts) - 1
            confirmedStart = array.get(confirmedPatternStarts, i)
            confirmedEnd = array.get(confirmedPatternEnds, i)

            if startIndex >= confirmedStart and startIndex <= confirmedEnd
                inside := true

    inside

markTradePatternClosed(int confirmationIndex) =>
    if array.size(tradeLookbackPatterns) > 0
        for i = 0 to array.size(tradeLookbackPatterns) - 1
            p = array.get(tradeLookbackPatterns, i)
            if p.trade.confirmationIndex == confirmationIndex
                p.trade.active := false
                p.trade.status := 1
                array.set(tradeLookbackPatterns, i, p)

    if not na(currentPattern) and currentPattern.trade.confirmationIndex == confirmationIndex
        currentPattern.trade.active := false
        currentPattern.trade.status := 1

exitTargetNo = statsExitTarget == "TP1" ? 1 : statsExitTarget == "TP2" ? 2 : 3

// Percent result of a closed trade when the whole position exits at the selected target:
// a win at that target's price if it was hit before the stop, otherwise a loss at the stop price.
tradePnl(Trade tr) =>
    float tgtPx = exitTargetNo == 1 ? tr.target1 : exitTargetNo == 2 ? tr.target2 : tr.target3
    bool hit = exitTargetNo == 1 ? tr.tp1Hit : exitTargetNo == 2 ? tr.tp2Hit : tr.tp3Hit
    float exitPx = hit ? tgtPx : tr.stop
    tr.direction > 0 ? (exitPx - tr.entry) / tr.entry * 100 : (tr.entry - exitPx) / tr.entry * 100

addPivot(int pIndex, float pPrice, int pType) =>
    pivotCount = array.size(pivotIndexes)

    if pivotCount == 0
        array.push(pivotIndexes, pIndex)
        array.push(pivotPrices, pPrice)
        array.push(pivotTypes, pType)
    else
        lastType = array.get(pivotTypes, pivotCount - 1)
        lastPrice = array.get(pivotPrices, pivotCount - 1)

        if pType == lastType
            replacePivot = pType == 1 ? pPrice > lastPrice : pPrice < lastPrice

            if replacePivot
                array.set(pivotIndexes, pivotCount - 1, pIndex)
                array.set(pivotPrices, pivotCount - 1, pPrice)
                array.set(pivotTypes, pivotCount - 1, pType)
        else
            array.push(pivotIndexes, pIndex)
            array.push(pivotPrices, pPrice)
            array.push(pivotTypes, pType)

    if array.size(pivotIndexes) > 20
        array.shift(pivotIndexes)
        array.shift(pivotPrices)
        array.shift(pivotTypes)

drawTradeLine(float price, int x1, int x2, string txt, color clr) =>
    ln = line.new(x1, price, x2, price, color = clr, style = line.style_dashed, width = 2)
    lbl = label.new(x2, price, txt + " - " + str.tostring(price, format.mintick), color = clr, textcolor = color.white, size = size.small, style = label.style_label_left)
    [ln, lbl]

drawPattern(Pattern p) =>
    PatternDrawing d = PatternDrawing.new()

    if showZigzagLines
        d.ab := line.new(p.aIndex, p.aPrice, p.bIndex, p.bPrice, color = pendingPatternColor, width = 2)
        d.bc := line.new(p.bIndex, p.bPrice, p.cIndex, p.cPrice, color = pendingPatternColor, width = 2)

    if showABCLabels
        d.aLabel := label.new(p.aIndex, p.aPrice, "A", color = pendingPatternColor, textcolor = chart.bg_color, style = label.style_label_center)
        d.bLabel := label.new(p.bIndex, p.bPrice, "B", color = pendingPatternColor, textcolor = chart.bg_color, style = label.style_label_center)
        d.cLabel := label.new(p.cIndex, p.cPrice, "C", color = pendingPatternColor, textcolor = chart.bg_color, style = label.style_label_center)

    d

drawConfirmationTriangle(bool bullishSignal, int x) =>
    triangleStyle = bullishSignal ? label.style_triangleup : label.style_triangledown
    triangleColor = bullishSignal ? bullTriangleColor : bearTriangleColor
    triangleYloc = bullishSignal ? yloc.belowbar : yloc.abovebar

    label.new(
         x = x,
         y = na,
         text = "",
         xloc = xloc.bar_index,
         yloc = triangleYloc,
         style = triangleStyle,
         color = triangleColor,
         textcolor = triangleColor,
         size = getTriangleSize(confirmationTriangleSizeInput)
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pivot Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

newPivot = false

if not na(ph)
    addPivot(bar_index - pivotRight, ph, 1)
    newPivot := true

if not na(pl)
    addPivot(bar_index - pivotRight, pl, -1)
    newPivot := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pattern Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newPivot and array.size(pivotIndexes) >= 3
    pivotCount = array.size(pivotIndexes)

    aIndex = array.get(pivotIndexes, pivotCount - 3)
    bIndex = array.get(pivotIndexes, pivotCount - 2)
    cIndex = array.get(pivotIndexes, pivotCount - 1)

    aPrice = array.get(pivotPrices, pivotCount - 3)
    bPrice = array.get(pivotPrices, pivotCount - 2)
    cPrice = array.get(pivotPrices, pivotCount - 1)

    abMove = math.abs(bPrice - aPrice)
    bcMove = math.abs(cPrice - bPrice)

    abcRatio = abMove > 0 ? bcMove / abMove : na
    validRatio = not na(abcRatio) and abcRatio >= minRatio and abcRatio <= maxRatio

    validABSize = not na(atrValue) and abMove >= atrValue * minABMultiplier

    bullishStructure = aPrice < bPrice and cPrice < bPrice and cPrice > aPrice
    bearishStructure = aPrice > bPrice and cPrice > bPrice and cPrice < aPrice

    validStructure = bullishStructure or bearishStructure
    direction = bullishStructure ? 1 : -1

    // ── ATR Mode trade levels ──────────────────────────────────────────────
    // Entry at B, stop at C, targets are R multiples of BC risk
    atrEntryPrice   = bPrice
    atrStopPrice    = cPrice
    atrRisk         = math.abs(atrEntryPrice - atrStopPrice)
    atrTarget1Price = direction > 0 ? atrEntryPrice + atrRisk * tp1Ratio : atrEntryPrice - atrRisk * tp1Ratio
    atrTarget2Price = direction > 0 ? atrEntryPrice + atrRisk * tp2Ratio : atrEntryPrice - atrRisk * tp2Ratio
    atrTarget3Price = direction > 0 ? atrEntryPrice + atrRisk * tp3Ratio : atrEntryPrice - atrRisk * tp3Ratio

    // ── FIB Mode trade levels ──────────────────────────────────────────────
    // Entry = close of C bar (looked up via bar offset since C is a confirmed historical pivot)
    // Stop  = high of C bar (bearish) or low of C bar (bullish)
    // TPs   = AB extensions projected from B in the trade direction
    cOffset       = bar_index - cIndex
    cBarHigh      = high[cOffset]
    cBarLow       = low[cOffset]
    cBarClose     = close[cOffset]
    fibEntryPrice  = cBarClose
    fibStopPrice   = direction > 0 ? cBarLow : cBarHigh
    fibTarget1Price = direction > 0 ? bPrice + abMove * (fibTp1Ext - 1.0) : bPrice - abMove * (fibTp1Ext - 1.0)
    fibTarget2Price = direction > 0 ? bPrice + abMove * (fibTp2Ext - 1.0) : bPrice - abMove * (fibTp2Ext - 1.0)
    fibTarget3Price = direction > 0 ? bPrice + abMove * (fibTp3Ext - 1.0) : bPrice - abMove * (fibTp3Ext - 1.0)

    // ── Select active mode levels ──────────────────────────────────────────
    entryPrice  = fibMode ? fibEntryPrice  : atrEntryPrice
    stopPrice   = fibMode ? fibStopPrice   : atrStopPrice
    target1Price = fibMode ? fibTarget1Price : atrTarget1Price
    target2Price = fibMode ? fibTarget2Price : atrTarget2Price
    target3Price = fibMode ? fibTarget3Price : atrTarget3Price

    validTrade   = direction != 0 and math.abs(entryPrice - stopPrice) > syminfo.mintick
    duplicate    = not na(currentPattern) and currentPattern.cIndex == cIndex
    overlapBlocked = disallowOverlap and startsInsideConfirmedPattern(aIndex)

    if validRatio and validABSize and validTrade and not duplicate and not overlapBlocked
        if not na(currentPattern)
            if currentPattern.trade.status == 0 and not currentPattern.trade.active
                deleteDrawing(currentPattern.drawing)
            else
                setTradeDrawingVisible(currentPattern.drawing, false)
                if showHistoricalPatterns
                    setPatternVisible(currentPattern.drawing, true, historicalColor)
                else
                    setPatternVisible(currentPattern.drawing, false, transparentColor)

        trade = Trade.new(entryPrice, stopPrice, target1Price, target2Price, target3Price, direction)
        Pattern p = Pattern.new(aIndex, bIndex, cIndex, aPrice, bPrice, cPrice, trade, na)
        p.drawing := drawPattern(p)
        currentPattern := p

        newABCDetectedSignal := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIB Mode Confirmation
// Triggered by newABCDetectedSignal — runs immediately
// after pattern detection on the same confirmed bar.
// Pattern formation and confirmation are separate:
// detection only stores the pattern; this block activates it.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if fibMode and newABCDetectedSignal and not na(currentPattern) and barstate.isconfirmed
    bullishConfirmationSignal := currentPattern.trade.direction > 0
    bearishConfirmationSignal := currentPattern.trade.direction < 0

    currentPattern.trade.active := true
    currentPattern.trade.confirmationIndex := bar_index

    trackedTrade = currentPattern.trade
    trackedTrade.active := true
    trackedTrade.confirmationIndex := bar_index
    array.push(openTrades, trackedTrade)

    addConfirmedPatternRange(currentPattern.aIndex, currentPattern.cIndex)

    if showConfirmationTriangles
        currentPattern.drawing.confirmationTriangle := drawConfirmationTriangle(bullishConfirmationSignal, bar_index)

    if showACLine
        currentPattern.drawing.ac := line.new(currentPattern.aIndex, currentPattern.aPrice, currentPattern.cIndex, currentPattern.cPrice, color = acLineColor, width = acLineWidth, style = getACLineStyle(acLineStyleInput), extend = extend.right)

    if showTradeLevels
        xEnd = bar_index + tradeLevelBarsForward

        [eLine, eLabel]   = drawTradeLine(currentPattern.trade.entry,   bar_index, xEnd, "Entry", entryColor)
        [sLine, sLabel]   = drawTradeLine(currentPattern.trade.stop,    bar_index, xEnd, "SL",    stopColor)
        [t1Line, t1Label] = drawTradeLine(currentPattern.trade.target1, bar_index, xEnd, "TP1",   targetColor)
        [t2Line, t2Label] = drawTradeLine(currentPattern.trade.target2, bar_index, xEnd, "TP2",   targetColor)
        [t3Line, t3Label] = drawTradeLine(currentPattern.trade.target3, bar_index, xEnd, "TP3",   targetColor)

        currentPattern.drawing.entryLine   := eLine
        currentPattern.drawing.stopLine    := sLine
        currentPattern.drawing.target1Line := t1Line
        currentPattern.drawing.target2Line := t2Line
        currentPattern.drawing.target3Line := t3Line
        currentPattern.drawing.entryLabel   := eLabel
        currentPattern.drawing.stopLabel    := sLabel
        currentPattern.drawing.target1Label := t1Label
        currentPattern.drawing.target2Label := t2Label
        currentPattern.drawing.target3Label := t3Label

    array.push(tradeLookbackPatterns, currentPattern)

    if array.size(tradeLookbackPatterns) > 200
        oldPattern = array.shift(tradeLookbackPatterns)
        deleteDrawing(oldPattern.drawing)

    abcBreakoutConfirmedSignal := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pending Pattern Invalidation (ATR mode only)
// In FIB mode there is no pending state — the trade
// fires on C detection, so this block is skipped.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not fibMode and invalidatePendingOnCloseBeyondC and not na(currentPattern) and currentPattern.trade.status == 0 and not currentPattern.trade.active and barstate.isconfirmed
    bullishCloseBeyondC = currentPattern.trade.direction > 0 and close < currentPattern.cPrice
    bearishCloseBeyondC = currentPattern.trade.direction < 0 and close > currentPattern.cPrice

    if bullishCloseBeyondC or bearishCloseBeyondC
        deleteDrawing(currentPattern.drawing)
        currentPattern := na
        abcInvalidatedSignal := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR Mode Confirmation
// Fires when price closes beyond B. Skipped in FIB mode.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not fibMode and not na(currentPattern) and currentPattern.trade.status == 0
    bullishCloseEntry = currentPattern.trade.direction > 0 and close > currentPattern.trade.entry
    bearishCloseEntry = currentPattern.trade.direction < 0 and close < currentPattern.trade.entry

    if not currentPattern.trade.active and barstate.isconfirmed and (bullishCloseEntry or bearishCloseEntry)
        bullishConfirmationSignal := bullishCloseEntry
        bearishConfirmationSignal := bearishCloseEntry

        currentPattern.trade.active := true
        currentPattern.trade.confirmationIndex := bar_index

        trackedTrade = currentPattern.trade
        trackedTrade.active := true
        trackedTrade.confirmationIndex := bar_index
        array.push(openTrades, trackedTrade)

        addConfirmedPatternRange(currentPattern.aIndex, currentPattern.cIndex)

        if showConfirmationTriangles
            currentPattern.drawing.confirmationTriangle := drawConfirmationTriangle(bullishConfirmationSignal, bar_index)

        if showACLine
            currentPattern.drawing.ac := line.new(currentPattern.aIndex, currentPattern.aPrice, currentPattern.cIndex, currentPattern.cPrice, color = acLineColor, width = acLineWidth, style = getACLineStyle(acLineStyleInput), extend = extend.right)

        if showTradeLevels
            xEnd = bar_index + tradeLevelBarsForward

            [eLine, eLabel]   = drawTradeLine(currentPattern.trade.entry,   bar_index, xEnd, "Entry", entryColor)
            [sLine, sLabel]   = drawTradeLine(currentPattern.trade.stop,    bar_index, xEnd, "SL",    stopColor)
            [t1Line, t1Label] = drawTradeLine(currentPattern.trade.target1, bar_index, xEnd, "TP1 ",  targetColor)
            [t2Line, t2Label] = drawTradeLine(currentPattern.trade.target2, bar_index, xEnd, "TP2 ",  targetColor)
            [t3Line, t3Label] = drawTradeLine(currentPattern.trade.target3, bar_index, xEnd, "TP3 ",  targetColor)

            currentPattern.drawing.entryLine   := eLine
            currentPattern.drawing.stopLine    := sLine
            currentPattern.drawing.target1Line := t1Line
            currentPattern.drawing.target2Line := t2Line
            currentPattern.drawing.target3Line := t3Line
            currentPattern.drawing.entryLabel   := eLabel
            currentPattern.drawing.stopLabel    := sLabel
            currentPattern.drawing.target1Label := t1Label
            currentPattern.drawing.target2Label := t2Label
            currentPattern.drawing.target3Label := t3Label

        array.push(tradeLookbackPatterns, currentPattern)

        if array.size(tradeLookbackPatterns) > 200
            oldPattern = array.shift(tradeLookbackPatterns)
            deleteDrawing(oldPattern.drawing)

        abcBreakoutConfirmedSignal := true

// Time between confirmed signals (feeds the stats window)
if abcBreakoutConfirmedSignal
    if not na(lastSigTime)
        array.push(gaps, time - lastSigTime)
        while array.size(gaps) > historicalLookback
            array.shift(gaps)
    lastSigTime := time

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trade Lookback Display Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pendingPatternIsNewest = not na(currentPattern) and currentPattern.trade.status == 0 and not currentPattern.trade.active
int selectedTradeIndex = na

if array.size(tradeLookbackPatterns) > 0
    if closedTradeLookback == 0
        for i = array.size(tradeLookbackPatterns) - 1 to 0
            p = array.get(tradeLookbackPatterns, i)
            if p.trade.active and p.trade.status == 0
                selectedTradeIndex := i
                break
    else
        closedCount = 0
        for i = array.size(tradeLookbackPatterns) - 1 to 0
            p = array.get(tradeLookbackPatterns, i)
            if p.trade.status == 1
                closedCount += 1
                if closedCount == closedTradeLookback
                    selectedTradeIndex := i
                    break

if array.size(tradeLookbackPatterns) > 0
    for i = 0 to array.size(tradeLookbackPatterns) - 1
        p = array.get(tradeLookbackPatterns, i)
        isSelected = not na(selectedTradeIndex) and i == selectedTradeIndex
        isOlderThanSelected = not na(selectedTradeIndex) and i < selectedTradeIndex
        isCurrentLiveTrade = not pendingPatternIsNewest and not na(currentPattern) and currentPattern.trade.confirmationIndex == p.trade.confirmationIndex and currentPattern.trade.status == 0

        if closedTradeLookback == 0
            if isCurrentLiveTrade
                setPatternVisible(p.drawing, true, confirmedPatternColor)
                setConfirmationTriangleVisible(p.drawing, true, p.trade.direction, false)

                if showTradeLevels
                    setTradeDrawingVisible(p.drawing, true)
                    extendTradeDrawing(p.drawing, p.trade, bar_index + tradeLevelBarsForward)
                else
                    setTradeDrawingVisible(p.drawing, false)
            else
                if showHistoricalPatterns
                    setPatternVisible(p.drawing, true, historicalColor)
                    setConfirmationTriangleVisible(p.drawing, true, p.trade.direction, false)
                else
                    setPatternVisible(p.drawing, false, transparentColor)
                    setConfirmationTriangleVisible(p.drawing, false, p.trade.direction, false)

                setTradeDrawingVisible(p.drawing, false)
        else
            if isSelected
                setPatternVisible(p.drawing, true, closedTradeLookbackColor)
                setConfirmationTriangleVisible(p.drawing, true, p.trade.direction, true)

                if showTradeLevels
                    setTradeDrawingVisible(p.drawing, true)
                    extendTradeDrawing(p.drawing, p.trade, bar_index + tradeLevelBarsForward)
                else
                    setTradeDrawingVisible(p.drawing, false)
            else if isOlderThanSelected and showHistoricalPatterns
                setPatternVisible(p.drawing, true, historicalColor)
                setConfirmationTriangleVisible(p.drawing, true, p.trade.direction, false)
                setTradeDrawingVisible(p.drawing, false)
            else
                setPatternVisible(p.drawing, false, transparentColor)
                setConfirmationTriangleVisible(p.drawing, false, p.trade.direction, false)
                setTradeDrawingVisible(p.drawing, false)

if pendingPatternIsNewest
    if closedTradeLookback == 0
        setPatternVisible(currentPattern.drawing, true, pendingPatternColor)
    else
        setPatternVisible(currentPattern.drawing, false, transparentColor)
        setTradeDrawingVisible(currentPattern.drawing, false)
else if not na(currentPattern) and closedTradeLookback > 0
    currentIsSelected = not na(selectedTradeIndex) and array.size(tradeLookbackPatterns) > 0 and currentPattern.trade.confirmationIndex == array.get(tradeLookbackPatterns, selectedTradeIndex).trade.confirmationIndex

    if not currentIsSelected
        setPatternVisible(currentPattern.drawing, false, transparentColor)
        setConfirmationTriangleVisible(currentPattern.drawing, false, currentPattern.trade.direction, false)
        setTradeDrawingVisible(currentPattern.drawing, false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Historical TP-Before-SL Stats
// Closed sample is capped by Historical Pattern Lookback.
// Same-bar rule: SL has priority.
// Works identically in both ATR and FIB mode —
// stats are driven purely by stored trade levels.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.isconfirmed and array.size(openTrades) > 0
    tradeCount = array.size(openTrades)

    for offset = 0 to tradeCount - 1
        i = tradeCount - 1 - offset
        tr = array.get(openTrades, i)

        stopHit    = tr.direction > 0 ? low <= tr.stop    : high >= tr.stop
        target1Hit = tr.direction > 0 ? high >= tr.target1 : low <= tr.target1
        target2Hit = tr.direction > 0 ? high >= tr.target2 : low <= tr.target2
        target3Hit = tr.direction > 0 ? high >= tr.target3 : low <= tr.target3

        if stopHit
            array.push(tp1History, tr.tp1Hit)
            array.push(tp2History, tr.tp2Hit)
            array.push(tp3History, tr.tp3Hit)
            array.push(pnlHistory, tradePnl(tr))

            if array.size(tp1History) > historicalLookback
                array.shift(tp1History)
                array.shift(tp2History)
                array.shift(tp3History)
                array.shift(pnlHistory)

            markTradePatternClosed(tr.confirmationIndex)
            array.remove(openTrades, i)
        else
            if target1Hit
                tr.tp1Hit := true
            if target2Hit
                tr.tp2Hit := true
            if target3Hit
                tr.tp3Hit := true

                array.push(tp1History, tr.tp1Hit)
                array.push(tp2History, tr.tp2Hit)
                array.push(tp3History, tr.tp3Hit)
                array.push(pnlHistory, tradePnl(tr))

                if array.size(tp1History) > historicalLookback
                    array.shift(tp1History)
                    array.shift(tp2History)
                    array.shift(tp3History)
                    array.shift(pnlHistory)

                markTradePatternClosed(tr.confirmationIndex)
                array.remove(openTrades, i)
            else
                array.set(openTrades, i, tr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Stats Window
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

statsPos     = getStatsPosition(statsPositionInput)
statsTxtSize = getStatsSize(statsSizeInput)

fmt(float x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "0.00") + "%"

posCol(float x) =>
    na(x) ? statsTextColor : x >= 0 ? color.new(#4CAF50, 0) : color.new(#F23645, 0)

// Formats milliseconds in the largest unit that keeps the number at 1 or more
fmtDur(float ms) =>
    float unitMs = na(ms) ? 1.0 : ms < 60000.0 ? 1000.0 : ms < 3600000.0 ? 60000.0 : ms < 86400000.0 ? 3600000.0 : ms < 604800000.0 ? 86400000.0 : ms < 2629800000.0 ? 604800000.0 : ms < 31557600000.0 ? 2629800000.0 : 31557600000.0
    string unitTxt = na(ms) ? "" : ms < 60000.0 ? "sec" : ms < 3600000.0 ? "min" : ms < 86400000.0 ? "hr" : ms < 604800000.0 ? "days" : ms < 2629800000.0 ? "wks" : ms < 31557600000.0 ? "mo" : "yrs"
    na(ms) ? "n/a" : str.tostring(ms / unitMs, "0.0") + " " + unitTxt

statRow(table t, int r, string lbl, string val, color valClr) =>
    table.cell(t, 0, r, lbl, text_color = statsTextColor, text_halign = text.align_left, text_size = statsTxtSize)
    table.cell(t, 1, r, val, text_color = valClr, text_halign = text.align_right, text_size = statsTxtSize)

tfTxt = timeframe.isseconds ? str.tostring(timeframe.multiplier) + "s" : timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(math.round(timeframe.multiplier / 60)) + "h" : str.tostring(timeframe.multiplier) + "m") : timeframe.isdaily ? (timeframe.multiplier == 1 ? "D" : str.tostring(timeframe.multiplier) + "D") : timeframe.isweekly ? (timeframe.multiplier == 1 ? "W" : str.tostring(timeframe.multiplier) + "W") : (timeframe.multiplier == 1 ? "M" : str.tostring(timeframe.multiplier) + "M")
sessTxt = str.upper(str.substring(syminfo.session, 0, 1)) + str.substring(syminfo.session, 1)
chartType = chart.is_heikinashi ? "Heikin Ashi" : chart.is_renko ? "Renko" : chart.is_kagi ? "Kagi" : chart.is_linebreak ? "Line Break" : chart.is_pnf ? "Point & Figure" : chart.is_range ? "Range" : "Standard"

var table statsTable = table.new(statsPos, 2, 24, bgcolor = statsBgColor, frame_color = statsBorderColor, frame_width = 1, border_color = color.new(statsBorderColor, 60), border_width = 1)

if barstate.isfirst
    table.merge_cells(statsTable, 0, 0, 1, 0)
    table.merge_cells(statsTable, 0, 12, 1, 12)

closedSample = array.size(tp1History)
tp1Wins = countWins(tp1History)
tp2Wins = countWins(tp2History)
tp3Wins = countWins(tp3History)

if barstate.islast
    if showStatsWindow
        int n = array.size(pnlHistory)
        int winCnt = 0
        int lossCnt = 0
        float winSum = 0.0
        float lossSum = 0.0
        float eq = 1.0
        float peak = 1.0
        float maxDD = 0.0

        if n > 0
            for i = 0 to n - 1
                float pn = array.get(pnlHistory, i)
                if pn > 0
                    winCnt += 1
                    winSum += pn
                else if pn < 0
                    lossCnt += 1
                    lossSum += pn
                eq := eq * (1 + pn / 100)
                peak := math.max(peak, eq)
                maxDD := math.min(maxDD, (eq / peak - 1) * 100)

        float netPnl = n > 0 ? (eq - 1) * 100 : na
        float winPct = n > 0 ? winCnt / n * 100 : na
        float avgWin = winCnt > 0 ? winSum / winCnt : na
        float avgLoss = lossCnt > 0 ? lossSum / lossCnt : na

        // Open trade: the most recently confirmed trade that is still live
        float openPnl = na
        if array.size(openTrades) > 0
            Trade lastOpen = array.get(openTrades, array.size(openTrades) - 1)
            openPnl := lastOpen.direction > 0 ? (close - lastOpen.entry) / lastOpen.entry * 100 : (lastOpen.entry - close) / lastOpen.entry * 100

        string targetsTxt = fibMode ? str.tostring(fibTp1Ext, "0.000") + " / " + str.tostring(fibTp2Ext, "0.000") + " / " + str.tostring(fibTp3Ext, "0.000") + " ext" : str.tostring(tp1Ratio, "0.0") + " / " + str.tostring(tp2Ratio, "0.0") + " / " + str.tostring(tp3Ratio, "0.0") + " R"
        string tp1Txt = closedSample > 0 ? winRate(tp1Wins, closedSample) + " (" + str.tostring(tp1Wins) + "/" + str.tostring(closedSample) + ")" : "n/a"
        string tp2Txt = closedSample > 0 ? winRate(tp2Wins, closedSample) + " (" + str.tostring(tp2Wins) + "/" + str.tostring(closedSample) + ")" : "n/a"
        string tp3Txt = closedSample > 0 ? winRate(tp3Wins, closedSample) + " (" + str.tostring(tp3Wins) + "/" + str.tostring(closedSample) + ")" : "n/a"
        float avgMs = array.size(gaps) > 0 ? array.avg(gaps) : na
        float sinceMs = na(lastSigTime) ? na : time - lastSigTime

        table.cell(statsTable, 0, 0, "ABC BREAKOUT", text_color = statsTextColor, bgcolor = statsHeaderColor, text_halign = text.align_center, text_size = statsTxtSize)
        statRow(statsTable, 1, "Chart Type", chartType, chart.is_standard ? statsTextColor : color.new(#F23645, 0))
        statRow(statsTable, 2, "Timeframe / Session", tfTxt + " / " + sessTxt, statsTextColor)
        statRow(statsTable, 3, "Trade Mode", fibMode ? "FIB" : "ATR", statsTextColor)
        statRow(statsTable, 4, "Pivot Bars (L / R)", str.tostring(pivotLeft) + " / " + str.tostring(pivotRight), statsTextColor)
        statRow(statsTable, 5, "ABC Ratio", str.tostring(minRatio, "0.00") + " - " + str.tostring(maxRatio, "0.00"), statsTextColor)
        statRow(statsTable, 6, "Min AB Size", str.tostring(minABMultiplier, "0.0") + "x ATR(" + str.tostring(atrLength) + ")", statsTextColor)
        statRow(statsTable, 7, "Overlap Block", disallowOverlap ? "ON" : "OFF", disallowOverlap ? color.new(#4CAF50, 0) : color.new(#F23645, 0))
        statRow(statsTable, 8, "Entry", fibMode ? "C bar close" : "B pivot", statsTextColor)
        statRow(statsTable, 9, "Stop Loss", fibMode ? "C bar high/low" : "C pivot", statsTextColor)
        statRow(statsTable, 10, "Targets (TP1 / 2 / 3)", targetsTxt, statsTextColor)
        statRow(statsTable, 11, "P/L Exit Target", statsExitTarget, statsTextColor)

        table.cell(statsTable, 0, 12, "LOOKBACK P/L", text_color = statsTextColor, bgcolor = statsHeaderColor, text_halign = text.align_center, text_size = statsTxtSize)
        statRow(statsTable, 13, "Trades Counted", str.tostring(n) + " / " + str.tostring(historicalLookback), statsTextColor)
        statRow(statsTable, 14, "TP1 Hit Rate", tp1Txt, statsTextColor)
        statRow(statsTable, 15, "TP2 Hit Rate", tp2Txt, statsTextColor)
        statRow(statsTable, 16, "TP3 Hit Rate", tp3Txt, statsTextColor)
        statRow(statsTable, 17, "Net P/L", fmt(netPnl), posCol(netPnl))
        statRow(statsTable, 18, "Win Rate", na(winPct) ? "n/a" : str.tostring(winPct, "0") + "% (" + str.tostring(winCnt) + "W/" + str.tostring(lossCnt) + "L)", statsTextColor)
        statRow(statsTable, 19, "Avg Win / Loss", fmt(avgWin) + " / " + fmt(avgLoss), statsTextColor)
        statRow(statsTable, 20, "Max Drawdown", n > 0 ? fmt(maxDD) : "n/a", maxDD < 0 ? color.new(#F23645, 0) : statsTextColor)
        statRow(statsTable, 21, "Open Trade P/L", fmt(openPnl), posCol(openPnl))
        statRow(statsTable, 22, "Avg Time per Signal", fmtDur(avgMs), statsTextColor)
        statRow(statsTable, 23, "Time Since Last Signal", fmtDur(sinceMs), statsTextColor)
    else
        table.clear(statsTable, 0, 0, 1, 23)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Conditions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(newABCDetectedSignal,        title = "New ABC Pattern Detected",  message = "New ABC Pattern Detected")
alertcondition(abcInvalidatedSignal,        title = "ABC Pattern Invalidated",   message = "ABC Pattern Invalidated")
alertcondition(abcBreakoutConfirmedSignal,  title = "ABC Breakout Confirmed",    message = "ABC Breakout Confirmed")
````
