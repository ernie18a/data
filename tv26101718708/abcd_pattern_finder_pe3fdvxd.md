# ABCD Pattern Finder

- url: https://www.tradingview.com/script/pE3fdVxd-ABCD-Pattern-Finder/
- type: indicator
- pine_id: PUB;a9ce13443b064329a59fd1daab2e14f9
- version: 3.0

## Description

**Detailed Indicator Description**

Your indicator is an **ABCD Pattern Finder** for TradingView. It scans price action for swing-based **AB=CD harmonic-style patterns**, confirms whether the pattern meets your rules, then plots the pattern and related trade levels directly on the chart. 

**Core Purpose**

The indicator is designed to find situations where price makes:

**A to B:** an initial impulse move.
**B to C:** a retracement or pullback.
**C to D:** a second move that is approximately equal to the A-to-B move.

When the C-to-D leg completes and passes the filter rules, the indicator treats point **D** as the trade-confirmation area. It then displays an entry reference, stop loss, and three take-profit levels. 

**Bullish and Bearish Logic**

A **bullish setup** is one where the completed pattern suggests a potential long trade after point D.

A **bearish setup** is one where the completed pattern suggests a potential short trade after point D.

The indicator uses the sequence of highs and lows to decide whether the pattern is bullish or bearish. It does not simply mark every four-point swing; the swing sequence must form a valid ABCD structure. 

**Zigzag Inputs**

**Pivot Bars Left** controls how many bars to the left must be considered when confirming a swing high or swing low.

**Pivot Bars Right** controls how many bars to the right must pass before a pivot is confirmed.

Higher values make the indicator less sensitive and produce fewer patterns. Lower values make it more sensitive and produce more patterns, but with more noise.

**Pattern Quality Inputs**

**Min CD/AB Time Ratio** sets the minimum amount of time the CD leg must take compared with the AB leg. This prevents CD from forming too quickly.

**Max CD/AB Time Ratio** sets the maximum amount of time CD can take compared with AB. This prevents slow, dragged-out CD legs from qualifying.

**AB=CD Equality Tolerance** controls how close the CD leg must be to the AB leg in price size. A value of **0.10** means CD can be within plus or minus 10% of AB.

**Min BC Retracement of AB** sets the shallowest acceptable pullback from B to C.

**Max BC Retracement of AB** sets the deepest acceptable pullback from B to C.

**Min AB Size ATR Multiple** requires the AB leg to be large enough compared with ATR. This helps filter out small, low-quality patterns.

**ATR Length** controls the ATR calculation used for volatility-based filtering and stop placement.

**Disallow Pattern Overlap** prevents a new pattern from being confirmed inside the range of an already confirmed pattern. 

**Trade Inputs**

**Stop ATR Buffer Beyond D** places the stop loss beyond point D by a volatility-based buffer. A larger value gives the trade more room, while a smaller value creates a tighter stop.

**TP1 Fibonacci Level** sets the first profit target based on the A-to-D range.

**TP2 Fibonacci Level** sets the second profit target.

**TP3 Fibonacci Level** sets the third profit target.

The default target structure is TP1 at **0.618**, TP2 at **1.0**, and TP3 at **1.382** of the A-to-D range. 

**Display Inputs**

**Trade Display Bars Forward** controls how far the entry, stop, and target lines extend to the right of the current candle.

**Show Trade Levels** turns entry, stop loss, and target lines on or off.

**Show ABCD Lines** turns the A-B, B-C, and C-D pattern lines on or off.

**Show ABCD Labels** turns the A, B, C, and D labels on or off.

You can also customize colors for the confirmed pattern, entry line, stop line, and target lines. 

**Historical Pattern Inputs**

**Show Historical AB=CD Patterns** controls whether older confirmed patterns remain visible.

**Historical Closed Lookback** controls how many recently closed patterns are included in the historical visual/stat window.

**Closed Trade Lookback** lets you visually rewind and highlight a previous closed trade. A value of **0** shows the most recent trade. A value of **1** shows the trade before that.

**Closed Trade Lookback Color** controls the color used when reviewing an older closed trade. 

**Confirmation Triangles**

The indicator can plot a triangle when a pattern is confirmed.

A bullish confirmation uses the bullish triangle color.
A bearish confirmation uses the bearish triangle color.

You can turn these triangles on or off and choose their size: **Tiny, Small, Normal, or Large**. 

**AD Line Inputs**

The indicator can draw a line from point **A** to point **D**, extended to the right.

You can control whether this line appears, plus its color, width, and style: **Solid, Dashed, or Dotted**. 

**Stats Window**

The stats window displays historical performance for TP1, TP2, and TP3.

For each target, it shows:

**Wins:** how many closed trades reached that target.
**Closed:** how many closed trades were evaluated.
**Rate:** the win rate for that target.

The stats are recalculated using your current trade input settings, so changing stop or target values updates the displayed historical results. 

**Alerts**

The indicator includes two alerts:

**New ABCD Pattern Detected** triggers when a valid pattern is found.

**ABCD Pattern Entry at D** triggers when the pattern confirmation/entry condition occurs at point D.

## Source Code

````pine
//@version=6
indicator("ABCD Pattern Finder", shorttitle = "ABCD Pattern", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 2000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotLeft   = input.int(13, "Pivot Bars Left",  minval = 1, group = "Zigzag")
pivotRight  = input.int(5,  "Pivot Bars Right", minval = 1, group = "Zigzag")
searchDepth = input.int(2000, "Search Depth (Bars)", minval = 100, maxval = 5000, step = 100, group = "Zigzag",
     tooltip = "How many bars back the indicator scans for ABCD patterns.")

showHistoricalPatterns   = input.bool(true,  "Show Historical AB=CD Patterns", group = "Historical Patterns")
historicalLookback       = input.int(20,     "Historical Closed Lookback",     minval = 1, maxval = 100, group = "Historical Patterns",
     tooltip = "Controls both historical pattern visuals and stat window closed trades.")
historicalColor          = input.color(color.purple, "Historical Pattern Color", group = "Historical Patterns")
closedTradeLookback      = input.int(0,  "Closed Trade Lookback", minval = 0, maxval = 20, group = "Historical Patterns",
     tooltip = "Visual rewind. 0 = most recent trade. 1 = one before that, etc.")
closedTradeLookbackColor = input.color(color.red, "Closed Trade Lookback Color", group = "Historical Patterns")

minTimeRatio = input.float(0.618, "Min CD/AB Time Ratio", minval = 0.1, maxval = 3.0, step = 0.01, group = "Pattern",
     tooltip = "Minimum ratio of CD bars to AB bars. Ensures CD does not form much faster than AB. 0.618 = CD must take at least 61.8% as many bars as AB.")
maxTimeRatio = input.float(1.618, "Max CD/AB Time Ratio", minval = 0.1, maxval = 5.0, step = 0.01, group = "Pattern",
     tooltip = "Maximum ratio of CD bars to AB bars. Ensures CD does not drag on much longer than AB. 1.618 = CD can take at most 161.8% as many bars as AB.")

equalityTolerance = input.float(0.30, "AB=CD Equality Tolerance", minval = 0.01, maxval = 0.50, step = 0.01, group = "Pattern",
     tooltip = "How close CD must be to AB in price size. 0.10 = CD must be within ±10% of AB.")
minBCRatio = input.float(0.5,  "Min BC Retracement (of AB)", minval = 0.10, maxval = 1.00, step = 0.01, group = "Pattern",
     tooltip = "Minimum BC retracement relative to AB required for a valid AB=CD pattern.")
maxBCRatio = input.float(0.786, "Max BC Retracement (of AB)", minval = 0.10, maxval = 2.00, step = 0.01, group = "Pattern",
     tooltip = "Maximum BC retracement relative to AB allowed for a valid AB=CD pattern.")
minABMultiplier = input.float(5.0, "Min AB Size (ATR Multiple)", minval = 0.1, step = 0.1, group = "Pattern",
     tooltip = "Minimum size of the AB impulse leg as a multiple of ATR(14). Filters noise-level moves.")
atrLength = input.int(14, "ATR Length", minval = 1, group = "Pattern")
disallowOverlap = input.bool(true, "Disallow Pattern Overlap", group = "Pattern",
     tooltip = "Prevents new confirmed AB=CD patterns from forming inside the range of previously confirmed patterns.")

stopATRMultiplier = input.float(1.0, "Stop ATR Buffer (beyond D)", minval = 0.0, step = 0.1, group = "Trade",
     tooltip = "Stop loss placed this many ATRs beyond the D pivot price.")
tp1Fib = input.float(0.618, "TP1 Fibonacci Level", minval = 0.01, maxval = 3.0, step = 0.001, group = "Trade",
     tooltip = "TP1 as a Fibonacci retracement of the AD range.")
tp2Fib = input.float(1.0,   "TP2 Fibonacci Level", minval = 0.01, maxval = 3.0, step = 0.001, group = "Trade",
     tooltip = "TP2 as a Fibonacci retracement of the AD range.")
tp3Fib = input.float(1.382, "TP3 Fibonacci Level", minval = 0.01, maxval = 3.0, step = 0.001, group = "Trade",
     tooltip = "TP3 as a Fibonacci retracement of the AD range.")

tradeLevelBarsForward = input.int(5, "Trade Display Bars Forward", minval = 1, maxval = 100, group = "Display",
     tooltip = "Number of bars active trade levels extend beyond the current candle.")

showTradeLevels = input.bool(true, "Show Trade Levels",  group = "Display")
showZigzagLines = input.bool(true, "Show ABCD Lines",    group = "Display")
showABCDLabels  = input.bool(true, "Show ABCD Labels",   group = "Display")

confirmedPatternColor = input.color(color.orange, "Confirmed Pattern Color", group = "Display")
entryColor            = input.color(color.blue,   "Entry Color",             group = "Display")
stopColor             = input.color(color.red,    "Stop Loss Color",         group = "Display")
targetColor           = input.color(color.green,  "Take Profit Color",       group = "Display")

showConfirmationTriangles     = input.bool(true,   "Show Confirmation Triangles", group = "Display")
bullTriangleColor             = input.color(color.green, "Bull Triangle Color",   group = "Display")
bearTriangleColor             = input.color(color.red,   "Bear Triangle Color",   group = "Display")
confirmationTriangleSizeInput = input.string("Tiny", "Confirmation Triangle Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = "Display")

showADLine       = input.bool(true,        "Show AD Line",  group = "AD Line",
     tooltip = "Draws a line from pivot A to pivot D, extended to the right.")
adLineColor      = input.color(color.blue, "AD Line Color", group = "AD Line")
adLineWidth      = input.int(2,            "AD Line Width", minval = 1, maxval = 4, group = "AD Line")
adLineStyleInput = input.string("Dotted",  "AD Line Style",
     options = ["Solid", "Dashed", "Dotted"], group = "AD Line")

showStatsWindow    = input.bool(true, "Show Stats Window", group = "Stats Window")
statsPositionInput = input.string("Top Right", "Stats Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right",
     "Bottom Left", "Bottom Center", "Bottom Right"], group = "Stats Window")
statsSizeInput   = input.string("Small", "Stats Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = "Stats Window")
statsBgColor     = input.color(color.new(color.black, 15), "Stats Background Color", group = "Stats Window")
statsHeaderColor = input.color(color.new(color.blue, 0),   "Stats Header Color",     group = "Stats Window")
statsTextColor   = input.color(color.white, "Stats Text Color",   group = "Stats Window")
statsBorderColor = input.color(color.gray,  "Stats Border Color", group = "Stats Window")

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
    int   direction
    int   confirmationIndex = na
    bool  active  = false
    int   status  = 0
    bool  tp1Hit  = false
    bool  tp2Hit  = false
    bool  tp3Hit  = false

type PatternDrawing
    line  ab
    line  bc
    line  cd
    line  ad
    line  entryLine
    line  stopLine
    line  target1Line
    line  target2Line
    line  target3Line
    label aLabel
    label bLabel
    label cLabel
    label dLabel
    label entryLabel
    label stopLabel
    label target1Label
    label target2Label
    label target3Label
    label confirmationTriangle

type Pattern
    int   aIndex
    int   bIndex
    int   cIndex
    int   dIndex
    float aPrice
    float bPrice
    float cPrice
    float dPrice
    Trade          trade
    PatternDrawing drawing

type RawPattern
    float aPrice
    float dPrice
    float entryPrice
    float atrAtDetection
    int   direction
    bool  closed
    array<float> highs
    array<float> lows

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<int>        pivotIndexes           = array.new<int>()
var array<float>      pivotPrices            = array.new<float>()
var array<int>        pivotTypes             = array.new<int>()
var Pattern           currentPattern         = na
var array<Pattern>    tradeLookbackPatterns  = array.new<Pattern>()
var array<int>        confirmedPatternStarts = array.new<int>()
var array<int>        confirmedPatternEnds   = array.new<int>()
var array<Trade>      openTrades             = array.new<Trade>()
var array<RawPattern> rawPatterns            = array.new<RawPattern>()
var array<int>        openTradeRawIndex      = array.new<int>()

newABCDDetectedSignal = false
abcdConfirmedSignal   = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrValue = ta.atr(atrLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getStatsPosition(string pos) =>
    pos == "Top Left"       ? position.top_left     :
     pos == "Top Center"    ? position.top_center   :
     pos == "Top Right"     ? position.top_right    :
     pos == "Middle Left"   ? position.middle_left  :
     pos == "Middle Center" ? position.middle_center :
     pos == "Middle Right"  ? position.middle_right :
     pos == "Bottom Left"   ? position.bottom_left  :
     pos == "Bottom Center" ? position.bottom_center :
     position.bottom_right

getStatsSize(string sz) =>
    sz == "Tiny"    ? size.tiny   :
     sz == "Small"  ? size.small  :
     sz == "Normal" ? size.normal :
     size.large

getTriangleSize(string sz) =>
    sz == "Tiny"    ? size.tiny   :
     sz == "Small"  ? size.small  :
     sz == "Normal" ? size.normal :
     size.large

getADLineStyle(string s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted"? line.style_dotted :
     line.style_solid

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
    if not na(d.cd)
        line.delete(d.cd)
        d.cd := na
    if not na(d.ad)
        line.delete(d.ad)
        d.ad := na
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
    if not na(d.dLabel)
        label.delete(d.dLabel)
        d.dLabel := na
    if not na(d.confirmationTriangle)
        label.delete(d.confirmationTriangle)
        d.confirmationTriangle := na

setDrawingColor(PatternDrawing d, color clr) =>
    if not na(d.ab)
        line.set_color(d.ab, clr)
    if not na(d.bc)
        line.set_color(d.bc, clr)
    if not na(d.cd)
        line.set_color(d.cd, clr)
    if not na(d.aLabel)
        label.set_color(d.aLabel, clr)
    if not na(d.bLabel)
        label.set_color(d.bLabel, clr)
    if not na(d.cLabel)
        label.set_color(d.cLabel, clr)
    if not na(d.dLabel)
        label.set_color(d.dLabel, clr)

setDrawingTextColor(PatternDrawing d, color clr) =>
    if not na(d.aLabel)
        label.set_textcolor(d.aLabel, clr)
    if not na(d.bLabel)
        label.set_textcolor(d.bLabel, clr)
    if not na(d.cLabel)
        label.set_textcolor(d.cLabel, clr)
    if not na(d.dLabel)
        label.set_textcolor(d.dLabel, clr)

setPatternVisible(PatternDrawing d, bool visible, color clr) =>
    patternClr = visible ? clr : transparentColor
    textClr    = visible ? chart.bg_color : transparentColor
    setDrawingColor(d, patternClr)
    setDrawingTextColor(d, textClr)

setTradeDrawingVisible(PatternDrawing d, bool visible) =>
    eClr   = visible ? entryColor  : color.new(entryColor,  100)
    sClr   = visible ? stopColor   : color.new(stopColor,   100)
    tClr   = visible ? targetColor : color.new(targetColor, 100)
    txtClr = visible ? color.white : transparentColor
    if not na(d.entryLine)
        line.set_color(d.entryLine,   eClr)
    if not na(d.stopLine)
        line.set_color(d.stopLine,    sClr)
    if not na(d.target1Line)
        line.set_color(d.target1Line, tClr)
    if not na(d.target2Line)
        line.set_color(d.target2Line, tClr)
    if not na(d.target3Line)
        line.set_color(d.target3Line, tClr)
    if not na(d.entryLabel)
        label.set_color(d.entryLabel,     eClr)
        label.set_textcolor(d.entryLabel, txtClr)
    if not na(d.stopLabel)
        label.set_color(d.stopLabel,     sClr)
        label.set_textcolor(d.stopLabel, txtClr)
    if not na(d.target1Label)
        label.set_color(d.target1Label,     tClr)
        label.set_textcolor(d.target1Label, txtClr)
    if not na(d.target2Label)
        label.set_color(d.target2Label,     tClr)
        label.set_textcolor(d.target2Label, txtClr)
    if not na(d.target3Label)
        label.set_color(d.target3Label,     tClr)
        label.set_textcolor(d.target3Label, txtClr)
    if not na(d.ad)
        line.set_color(d.ad, visible and showADLine ? adLineColor : transparentColor)

setConfirmationTriangleVisible(PatternDrawing d, bool visible, int direction, bool useLookbackColor) =>
    if not na(d.confirmationTriangle)
        normalClr = direction > 0 ? bullTriangleColor : bearTriangleColor
        triClr    = visible ? useLookbackColor ? closedTradeLookbackColor : normalClr : transparentColor
        label.set_color(d.confirmationTriangle,     triClr)
        label.set_textcolor(d.confirmationTriangle, triClr)

extendTradeDrawing(PatternDrawing d, Trade t, int xEnd) =>
    if not na(d.entryLine)
        line.set_x2(d.entryLine,   xEnd)
    if not na(d.stopLine)
        line.set_x2(d.stopLine,    xEnd)
    if not na(d.target1Line)
        line.set_x2(d.target1Line, xEnd)
    if not na(d.target2Line)
        line.set_x2(d.target2Line, xEnd)
    if not na(d.target3Line)
        line.set_x2(d.target3Line, xEnd)
    if not na(d.entryLabel)
        label.set_x(d.entryLabel,   xEnd)
        label.set_y(d.entryLabel,   t.entry)
    if not na(d.stopLabel)
        label.set_x(d.stopLabel,    xEnd)
        label.set_y(d.stopLabel,    t.stop)
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
    array.push(confirmedPatternEnds,   endIndex)
    if array.size(confirmedPatternStarts) > 200
        array.shift(confirmedPatternStarts)
        array.shift(confirmedPatternEnds)

startsInsideConfirmedPattern(int startIndex) =>
    inside = false
    if array.size(confirmedPatternStarts) > 0
        for i = 0 to array.size(confirmedPatternStarts) - 1
            if startIndex >= array.get(confirmedPatternStarts, i) and startIndex <= array.get(confirmedPatternEnds, i)
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

addPivot(int pIndex, float pPrice, int pType) =>
    pivotCount = array.size(pivotIndexes)
    if pivotCount == 0
        array.push(pivotIndexes, pIndex)
        array.push(pivotPrices,  pPrice)
        array.push(pivotTypes,   pType)
    else
        lastType  = array.get(pivotTypes,  pivotCount - 1)
        lastPrice = array.get(pivotPrices, pivotCount - 1)
        if pType == lastType
            replacePivot = pType == 1 ? pPrice > lastPrice : pPrice < lastPrice
            if replacePivot
                array.set(pivotIndexes, pivotCount - 1, pIndex)
                array.set(pivotPrices,  pivotCount - 1, pPrice)
                array.set(pivotTypes,   pivotCount - 1, pType)
        else
            array.push(pivotIndexes, pIndex)
            array.push(pivotPrices,  pPrice)
            array.push(pivotTypes,   pType)
    if array.size(pivotIndexes) > 20
        array.shift(pivotIndexes)
        array.shift(pivotPrices)
        array.shift(pivotTypes)

drawTradeLine(float price, int x1, int x2, string txt, color clr) =>
    ln  = line.new(x1, price, x2, price, color = clr, style = line.style_dashed, width = 2)
    lbl = label.new(x2, price, txt + " - " + str.tostring(price, format.mintick),
         color = clr, textcolor = color.white, size = size.small, style = label.style_label_left)
    [ln, lbl]

drawPattern(Pattern p, color clr) =>
    PatternDrawing d = PatternDrawing.new()
    if showZigzagLines
        d.ab := line.new(p.aIndex, p.aPrice, p.bIndex, p.bPrice, color = clr, width = 2)
        d.bc := line.new(p.bIndex, p.bPrice, p.cIndex, p.cPrice, color = clr, width = 2)
        d.cd := line.new(p.cIndex, p.cPrice, p.dIndex, p.dPrice, color = clr, width = 2)
    if showABCDLabels
        d.aLabel := label.new(p.aIndex, p.aPrice, "A", color = clr, textcolor = chart.bg_color, style = label.style_label_center)
        d.bLabel := label.new(p.bIndex, p.bPrice, "B", color = clr, textcolor = chart.bg_color, style = label.style_label_center)
        d.cLabel := label.new(p.cIndex, p.cPrice, "C", color = clr, textcolor = chart.bg_color, style = label.style_label_center)
        d.dLabel := label.new(p.dIndex, p.dPrice, "D", color = clr, textcolor = chart.bg_color, style = label.style_label_center)
    d

drawConfirmationTriangle(bool bullishSignal, int x) =>
    label.new(
         x         = x,
         y         = na,
         text      = "",
         xloc      = xloc.bar_index,
         yloc      = bullishSignal ? yloc.belowbar : yloc.abovebar,
         style     = bullishSignal ? label.style_triangleup : label.style_triangledown,
         color     = bullishSignal ? bullTriangleColor : bearTriangleColor,
         textcolor = bullishSignal ? bullTriangleColor : bearTriangleColor,
         size      = getTriangleSize(confirmationTriangleSizeInput)
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pivot Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low,  pivotLeft, pivotRight)

newPivot = false

if not na(ph)
    addPivot(bar_index - pivotRight, ph, 1)
    newPivot := true

if not na(pl)
    addPivot(bar_index - pivotRight, pl, -1)
    newPivot := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AB=CD Pattern Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newPivot and array.size(pivotIndexes) >= 4
    pivotCount = array.size(pivotIndexes)

    aIndex = array.get(pivotIndexes, pivotCount - 4)
    bIndex = array.get(pivotIndexes, pivotCount - 3)
    cIndex = array.get(pivotIndexes, pivotCount - 2)
    dIndex = array.get(pivotIndexes, pivotCount - 1)

    aPrice = array.get(pivotPrices, pivotCount - 4)
    bPrice = array.get(pivotPrices, pivotCount - 3)
    cPrice = array.get(pivotPrices, pivotCount - 2)
    dPrice = array.get(pivotPrices, pivotCount - 1)

    aType = array.get(pivotTypes, pivotCount - 4)
    bType = array.get(pivotTypes, pivotCount - 3)
    cType = array.get(pivotTypes, pivotCount - 2)
    dType = array.get(pivotTypes, pivotCount - 1)

    abMove = math.abs(bPrice - aPrice)
    bcMove = math.abs(cPrice - bPrice)
    cdMove = math.abs(dPrice - cPrice)

    bcRatio       = abMove > 0 ? bcMove / abMove : na
    validBCRatio  = not na(bcRatio) and bcRatio >= minBCRatio and bcRatio <= maxBCRatio

    cdRatio       = abMove > 0 ? cdMove / abMove : na
    validEquality = not na(cdRatio) and cdRatio >= (1.0 - equalityTolerance) and cdRatio <= (1.0 + equalityTolerance)

    validABSize = not na(atrValue) and abMove >= atrValue * minABMultiplier

    abBars    = bIndex - aIndex
    cdBars    = dIndex - cIndex
    timeRatio = abBars > 0 ? cdBars / abBars : na
    validTimeSymmetry = not na(timeRatio) and timeRatio >= minTimeRatio and timeRatio <= maxTimeRatio

    bullishStructure = aType == -1 and bType == 1 and cType == -1 and dType == 1 and
         bPrice > aPrice and cPrice < bPrice and cPrice > aPrice and dPrice > cPrice

    bearishStructure = aType == 1 and bType == -1 and cType == 1 and dType == -1 and
         bPrice < aPrice and cPrice > bPrice and cPrice < aPrice and dPrice < cPrice

    direction      = bearishStructure ? 1 : bullishStructure ? -1 : 0
    validStructure = direction != 0

    entryPrice   = close
    stopPrice    = direction > 0 ? dPrice - atrValue * stopATRMultiplier : dPrice + atrValue * stopATRMultiplier
    adRange      = math.abs(aPrice - dPrice)
    target1Price = direction > 0 ? dPrice + adRange * tp1Fib : dPrice - adRange * tp1Fib
    target2Price = direction > 0 ? dPrice + adRange * tp2Fib : dPrice - adRange * tp2Fib
    target3Price = direction > 0 ? dPrice + adRange * tp3Fib : dPrice - adRange * tp3Fib

    validTrade        = direction != 0 and math.abs(entryPrice - stopPrice) > syminfo.mintick
    duplicate         = not na(currentPattern) and currentPattern.dIndex == dIndex
    overlapBlocked    = disallowOverlap and startsInsideConfirmedPattern(aIndex)
    withinSearchDepth = (bar_index - aIndex) <= searchDepth

    if validBCRatio and validEquality and validABSize and validTimeSymmetry and validStructure and validTrade and not duplicate and not overlapBlocked and withinSearchDepth
        if not na(currentPattern)
            setTradeDrawingVisible(currentPattern.drawing, false)
            if showHistoricalPatterns
                setPatternVisible(currentPattern.drawing, true, historicalColor)
            else
                setPatternVisible(currentPattern.drawing, false, transparentColor)

        trade = Trade.new(
             entry             = entryPrice,
             stop              = stopPrice,
             target1           = target1Price,
             target2           = target2Price,
             target3           = target3Price,
             direction         = direction,
             confirmationIndex = bar_index,
             active            = true,
             status            = 0,
             tp1Hit            = false,
             tp2Hit            = false,
             tp3Hit            = false
         )

        p = Pattern.new(
             aIndex  = aIndex,
             bIndex  = bIndex,
             cIndex  = cIndex,
             dIndex  = dIndex,
             aPrice  = aPrice,
             bPrice  = bPrice,
             cPrice  = cPrice,
             dPrice  = dPrice,
             trade   = trade,
             drawing = PatternDrawing.new()
         )

        p.drawing := drawPattern(p, confirmedPatternColor)

        if showConfirmationTriangles
            p.drawing.confirmationTriangle := drawConfirmationTriangle(direction > 0, bar_index)

        if showADLine
            p.drawing.ad := line.new(aIndex, aPrice, dIndex, dPrice,
                 color = adLineColor, width = adLineWidth,
                 style = getADLineStyle(adLineStyleInput), extend = extend.right)

        if showTradeLevels
            xEnd = bar_index + tradeLevelBarsForward
            [eLine,  eLabel]  = drawTradeLine(trade.entry,   bar_index, xEnd, "Entry", entryColor)
            [sLine,  sLabel]  = drawTradeLine(trade.stop,    bar_index, xEnd, "SL",    stopColor)
            [t1Line, t1Label] = drawTradeLine(trade.target1, bar_index, xEnd, "TP1 ",  targetColor)
            [t2Line, t2Label] = drawTradeLine(trade.target2, bar_index, xEnd, "TP2 ",  targetColor)
            [t3Line, t3Label] = drawTradeLine(trade.target3, bar_index, xEnd, "TP3 ",  targetColor)
            p.drawing.entryLine    := eLine
            p.drawing.stopLine     := sLine
            p.drawing.target1Line  := t1Line
            p.drawing.target2Line  := t2Line
            p.drawing.target3Line  := t3Line
            p.drawing.entryLabel   := eLabel
            p.drawing.stopLabel    := sLabel
            p.drawing.target1Label := t1Label
            p.drawing.target2Label := t2Label
            p.drawing.target3Label := t3Label

        currentPattern := p
        array.push(openTrades, trade)
        addConfirmedPatternRange(aIndex, dIndex)
        array.push(tradeLookbackPatterns, p)

        rp = RawPattern.new(
             aPrice          = aPrice,
             dPrice          = dPrice,
             entryPrice      = entryPrice,
             atrAtDetection  = atrValue,
             direction       = direction,
             closed          = false,
             highs           = array.new<float>(),
             lows            = array.new<float>()
         )
        array.push(rawPatterns, rp)
        array.push(openTradeRawIndex, array.size(rawPatterns) - 1)

        if array.size(tradeLookbackPatterns) > 200
            oldPattern = array.shift(tradeLookbackPatterns)
            deleteDrawing(oldPattern.drawing)

        newABCDDetectedSignal := true
        abcdConfirmedSignal   := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trade Lookback Display Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int selectedTradeIndex = na

if array.size(tradeLookbackPatterns) > 0
    if closedTradeLookback == 0
        selectedTradeIndex := array.size(tradeLookbackPatterns) - 1
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
        isSelected          = not na(selectedTradeIndex) and i == selectedTradeIndex
        isOlderThanSelected = not na(selectedTradeIndex) and i < selectedTradeIndex

        if isSelected
            isClosed = p.trade.status == 1
            if closedTradeLookback == 0
                if isClosed
                    setPatternVisible(p.drawing, true, historicalColor)
                    setConfirmationTriangleVisible(p.drawing, true, p.trade.direction, false)
                    setTradeDrawingVisible(p.drawing, false)
                else
                    setPatternVisible(p.drawing, true, confirmedPatternColor)
                    setConfirmationTriangleVisible(p.drawing, true, p.trade.direction, false)
                    if showTradeLevels
                        setTradeDrawingVisible(p.drawing, true)
                        extendTradeDrawing(p.drawing, p.trade, bar_index + tradeLevelBarsForward)
                    else
                        setTradeDrawingVisible(p.drawing, false)
            else
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

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OHLC Collection + Live Trade Exit Tracking
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.isconfirmed and array.size(openTrades) > 0
    tradeCount = array.size(openTrades)

    for offset = 0 to tradeCount - 1
        i  = tradeCount - 1 - offset
        tr = array.get(openTrades, i)

        if bar_index > tr.confirmationIndex
            rawIdx = array.get(openTradeRawIndex, i)
            rp     = array.get(rawPatterns, rawIdx)
            array.push(rp.highs, high)
            array.push(rp.lows,  low)
            array.set(rawPatterns, rawIdx, rp)

            stopHit    = tr.direction > 0 ? low  <= tr.stop    : high >= tr.stop
            target1Hit = tr.direction > 0 ? high >= tr.target1 : low  <= tr.target1
            target2Hit = tr.direction > 0 ? high >= tr.target2 : low  <= tr.target2
            target3Hit = tr.direction > 0 ? high >= tr.target3 : low  <= tr.target3

            if stopHit
                rp.closed := true
                array.set(rawPatterns, rawIdx, rp)
                markTradePatternClosed(tr.confirmationIndex)
                array.remove(openTrades, i)
                array.remove(openTradeRawIndex, i)

            else if target3Hit
                tr.tp1Hit := true
                tr.tp2Hit := true
                tr.tp3Hit := true
                rp.closed := true
                array.set(rawPatterns, rawIdx, rp)
                markTradePatternClosed(tr.confirmationIndex)
                array.remove(openTrades, i)
                array.remove(openTradeRawIndex, i)

            else
                if target1Hit
                    tr.tp1Hit := true
                if target2Hit
                    tr.tp2Hit := true
                array.set(openTrades, i, tr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Replay-Based Stats
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int replayTP1Wins = 0
var int replayTP2Wins = 0
var int replayTP3Wins = 0
var int replayClosed  = 0

if barstate.islast
    replayTP1Wins := 0
    replayTP2Wins := 0
    replayTP3Wins := 0
    replayClosed  := 0

    totalRaw    = array.size(rawPatterns)
    closedFound = 0

    if totalRaw > 0
        for i = totalRaw - 1 to 0
            if closedFound >= historicalLookback
                break
            rp = array.get(rawPatterns, i)
            if not rp.closed
                continue

            closedFound  += 1
            replayClosed += 1

            adRange    = math.abs(rp.aPrice - rp.dPrice)
            replayStop = rp.direction > 0
                 ? rp.dPrice - rp.atrAtDetection * stopATRMultiplier
                 : rp.dPrice + rp.atrAtDetection * stopATRMultiplier
            replayTP1  = rp.direction > 0 ? rp.dPrice + adRange * tp1Fib : rp.dPrice - adRange * tp1Fib
            replayTP2  = rp.direction > 0 ? rp.dPrice + adRange * tp2Fib : rp.dPrice - adRange * tp2Fib
            replayTP3  = rp.direction > 0 ? rp.dPrice + adRange * tp3Fib : rp.dPrice - adRange * tp3Fib

            tp1Hit = false
            tp2Hit = false
            tp3Hit = false

            barCount = array.size(rp.highs)
            if barCount > 0
                for b = 0 to barCount - 1
                    h = array.get(rp.highs, b)
                    l = array.get(rp.lows,  b)

                    stopHit = rp.direction > 0 ? l <= replayStop : h >= replayStop

                    if stopHit
                        break

                    if rp.direction > 0
                        if h >= replayTP1
                            tp1Hit := true
                        if h >= replayTP2
                            tp2Hit := true
                        if h >= replayTP3
                            tp3Hit := true
                            break
                    else
                        if l <= replayTP1
                            tp1Hit := true
                        if l <= replayTP2
                            tp2Hit := true
                        if l <= replayTP3
                            tp3Hit := true
                            break

            if tp1Hit
                replayTP1Wins += 1
            if tp2Hit
                replayTP2Wins += 1
            if tp3Hit
                replayTP3Wins += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Stats Window
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

statsPos     = getStatsPosition(statsPositionInput)
statsTxtSize = getStatsSize(statsSizeInput)

var table statsTable = table.new(statsPos, 4, 5, border_width = 1, border_color = statsBorderColor)

if barstate.islast
    if showStatsWindow
        table.cell(statsTable, 0, 0, "ABCD Pattern", text_color = statsTextColor, bgcolor = statsHeaderColor, text_size = statsTxtSize)
        table.merge_cells(statsTable, 0, 0, 3, 0)
        table.cell(statsTable, 0, 1, "TP#",    text_color = statsTextColor, bgcolor = statsHeaderColor, text_size = statsTxtSize)
        table.cell(statsTable, 1, 1, "Wins",   text_color = statsTextColor, bgcolor = statsHeaderColor, text_size = statsTxtSize)
        table.cell(statsTable, 2, 1, "Closed", text_color = statsTextColor, bgcolor = statsHeaderColor, text_size = statsTxtSize)
        table.cell(statsTable, 3, 1, "Rate",   text_color = statsTextColor, bgcolor = statsHeaderColor, text_size = statsTxtSize)
        table.cell(statsTable, 0, 2, "TP1 ", text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 1, 2, str.tostring(replayTP1Wins),          text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 2, 2, str.tostring(replayClosed),           text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 3, 2, winRate(replayTP1Wins, replayClosed), text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 0, 3, "TP2 ", text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 1, 3, str.tostring(replayTP2Wins),          text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 2, 3, str.tostring(replayClosed),           text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 3, 3, winRate(replayTP2Wins, replayClosed), text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 0, 4, "TP3 ", text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 1, 4, str.tostring(replayTP3Wins),          text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 2, 4, str.tostring(replayClosed),           text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
        table.cell(statsTable, 3, 4, winRate(replayTP3Wins, replayClosed), text_color = statsTextColor, bgcolor = statsBgColor, text_size = statsTxtSize)
    else
        table.clear(statsTable, 0, 0, 3, 4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Conditions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(newABCDDetectedSignal, title = "New ABCD Pattern Detected", message = "New ABCD Pattern Detected")
alertcondition(abcdConfirmedSignal,   title = "ABCD Pattern Entry at D",   message = "ABCD Pattern Entry Triggered at D Pivot")
````
