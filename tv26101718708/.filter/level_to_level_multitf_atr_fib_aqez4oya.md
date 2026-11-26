# Level to Level Multi-TF + ATR + Fib

- url: https://www.tradingview.com/script/AqEZ4oYa/
- type: indicator
- pine_id: PUB;d3eeef04285d491b8eb3895d13c514b5
- version: 2.0

## Description

This indicator plots confirmed fractal-based support and resistance levels across 5 configurable timeframes. Each timeframe can be shown either as zones or as horizontal lines, depending on the selected mode.

The script also includes daily ATR/ADR projections, the daily open, and Fibonacci levels based on the latest confirmed opposite pivot sequence from a selectable timeframe. The Fibonacci module plots the 0, 50, 62.8, 100, 112, 127, and 162.8 levels and allows custom anchor source selection for the 0 and 100 levels.

Main features:
- 5 configurable timeframes
- Zone or line mode
- Fractal-based level mapping
- H1 line-test alerts
- Daily ATR/ADR levels
- Daily open line
- Fibonacci projections from confirmed opposite pivots

This script is designed as a chart analysis tool and should be used together with personal analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Level to Level Multi-TF + ATR + Fib", shorttitle="Level to Level + ATR + Fib", format=format.price, precision=0, overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ==================== TIMEFRAME 1 (Weekly) ====================
group1 = "📊 Timeframe 1 (Weekly)"
enable1        = input.bool(title="Enable TF1",           defval=true,  group=group1)
n1             = input.int(title="Periods",               defval=20, minval=2, group=group1)
fractalTF1     = input.timeframe(title="Timeframe 1",     defval="W",   group=group1)
showShapes1    = input.bool(title="Show Arrows",          defval=true,  group=group1)
displayMode1   = input.string(title="Mode",               defval="Zone", options=["Zone", "Line"], group=group1)
lineWidth1     = input.int(title="Line Width",            defval=2, minval=1, maxval=4, group=group1)
rectTrans1     = input.int(title="Zone Transparency",     defval=80, minval=0, maxval=100, group=group1)
maxRect1       = input.int(title="Max Elements",          defval=2, minval=1, maxval=500, group=group1)
sellColor1     = input.color(title="Sell Color",          defval=#FF9800, group=group1)
buyColor1      = input.color(title="Buy Color",           defval=#FF9800, group=group1)
showExternal1  = input.bool(title="Show External Lines",  defval=true,  group=group1)
showInternal1  = input.bool(title="Show Internal Lines",  defval=true,  group=group1)
internalTrans1 = input.int(title="Internal Transparency", defval=60, minval=0, maxval=100, group=group1)

// ==================== TIMEFRAME 2 (Daily) ====================
group2 = "📊 Timeframe 2 (Daily)"
enable2        = input.bool(title="Enable TF2",           defval=true,  group=group2)
n2             = input.int(title="Periods",               defval=20, minval=2, group=group2)
fractalTF2     = input.timeframe(title="Timeframe 2",     defval="D",   group=group2)
showShapes2    = input.bool(title="Show Arrows",          defval=true,  group=group2)
displayMode2   = input.string(title="Mode",               defval="Zone", options=["Zone", "Line"], group=group2)
lineWidth2     = input.int(title="Line Width",            defval=2, minval=1, maxval=4, group=group2)
rectTrans2     = input.int(title="Zone Transparency",     defval=80, minval=0, maxval=100, group=group2)
maxRect2       = input.int(title="Max Elements",          defval=2, minval=1, maxval=500, group=group2)
sellColor2     = input.color(title="Sell Color",          defval=#2196F3, group=group2)
buyColor2      = input.color(title="Buy Color",           defval=#2196F3, group=group2)
showExternal2  = input.bool(title="Show External Lines",  defval=true,  group=group2)
showInternal2  = input.bool(title="Show Internal Lines",  defval=true,  group=group2)
internalTrans2 = input.int(title="Internal Transparency", defval=60, minval=0, maxval=100, group=group2)

// ==================== TIMEFRAME 3 (H4) ====================
group3 = "📊 Timeframe 3 (H4)"
enable3        = input.bool(title="Enable TF3",           defval=true,  group=group3)
n3             = input.int(title="Periods",               defval=24, minval=2, group=group3)
fractalTF3     = input.timeframe(title="Timeframe 3",     defval="240", group=group3)
showShapes3    = input.bool(title="Show Arrows",          defval=true,  group=group3)
displayMode3   = input.string(title="Mode",               defval="Zone", options=["Zone", "Line"], group=group3)
lineWidth3     = input.int(title="Line Width",            defval=2, minval=1, maxval=4, group=group3)
rectTrans3     = input.int(title="Zone Transparency",     defval=80, minval=0, maxval=100, group=group3)
maxRect3       = input.int(title="Max Elements",          defval=2, minval=1, maxval=500, group=group3)
sellColor3     = input.color(title="Sell Color",          defval=#F44336, group=group3)
buyColor3      = input.color(title="Buy Color",           defval=#F44336, group=group3)
showExternal3  = input.bool(title="Show External Lines",  defval=true,  group=group3)
showInternal3  = input.bool(title="Show Internal Lines",  defval=true,  group=group3)
internalTrans3 = input.int(title="Internal Transparency", defval=60, minval=0, maxval=100, group=group3)

// ==================== TIMEFRAME 4 (H1) ====================
group4 = "📊 Timeframe 4 (H1)"
enable4        = input.bool(title="Enable TF4",           defval=true,  group=group4)
n4             = input.int(title="Periods",               defval=60, minval=2, group=group4)
fractalTF4     = input.timeframe(title="Timeframe 4",     defval="60",  group=group4)
showShapes4    = input.bool(title="Show Arrows",          defval=true,  group=group4)
displayMode4   = input.string(title="Mode",               defval="Zone", options=["Zone", "Line"], group=group4)
lineWidth4     = input.int(title="Line Width",            defval=2, minval=1, maxval=4, group=group4)
rectTrans4     = input.int(title="Zone Transparency",     defval=80, minval=0, maxval=100, group=group4)
maxRect4       = input.int(title="Max Elements",          defval=2, minval=1, maxval=500, group=group4)
sellColor4     = input.color(title="Sell Color",          defval=#4CAF50, group=group4)
buyColor4      = input.color(title="Buy Color",           defval=#4CAF50, group=group4)
showExternal4  = input.bool(title="Show External Lines",  defval=true,  group=group4)
showInternal4  = input.bool(title="Show Internal Lines",  defval=true,  group=group4)
internalTrans4 = input.int(title="Internal Transparency", defval=60, minval=0, maxval=100, group=group4)

// ==================== ALERT TF4 H1 ====================
groupAlert4 = "🔔 H1 Alerts"
enableAlert4 = input.bool(title="Enable H1 Line Test Alert", defval=true, group=groupAlert4)

// ==================== TIMEFRAME 5 (5min) ====================
group5 = "📊 Timeframe 5 (5min)"
enable5         = input.bool(title="Enable TF5",            defval=true,  group=group5)
n5              = input.int(title="Periods",                defval=24, minval=2, group=group5)
fractalTF5      = input.timeframe(title="Timeframe 5",      defval="5",   group=group5)
showShapes5     = input.bool(title="Show Arrows",           defval=true,  group=group5)
displayMode5    = input.string(title="Mode",                defval="Zone", options=["Zone", "Line"], group=group5)
lineWidth5      = input.int(title="Line Width",             defval=2, minval=1, maxval=4, group=group5)
rectTrans5      = input.int(title="Zone Transparency",      defval=80, minval=0, maxval=100, group=group5)
maxRect5        = input.int(title="Max Elements",           defval=2, minval=1, maxval=500, group=group5)
rectColor5      = input.color(title="Zone/Line Color",      defval=#FFEB3B, group=group5)
arrowUpColor5   = input.color(title="Up Arrow Color",       defval=#F44336, group=group5)
arrowDownColor5 = input.color(title="Down Arrow Color",     defval=#4CAF50, group=group5)
showExternal5   = input.bool(title="Show External Lines",   defval=true,  group=group5)
showInternal5   = input.bool(title="Show Internal Lines",   defval=true,  group=group5)
internalTrans5  = input.int(title="Internal Transparency",  defval=60, minval=0, maxval=100, group=group5)

// ==================== ATR SETTINGS ====================
groupATR = "📈 ATR/ADR Daily Progress"
showATR        = input.bool(title="Show ATR Table",                  defval=true, group=groupATR)
showATRLines   = input.bool(title="Show ATR Lines",                  defval=true, group=groupATR)
showADRLines   = input.bool(title="Show ADR Lines",                  defval=true, group=groupATR)
showDailyOpen  = input.bool(title="Show Daily Open Line",            defval=true, group=groupATR)
dailyOpenColor = input.color(title="Daily Open Color",               defval=color.orange, group=groupATR)
atrLen         = input.int(14, "ATR Length (Daily)", group=groupATR)
adrLen         = input.int(20, "ADR Length (Days)", group=groupATR)
usePips        = input.bool(true, "Use Pips (else Points)", group=groupATR)
greenPct       = input.float(60.0, "Green below %", group=groupATR)
yellowPct      = input.float(85.0, "Yellow below %", group=groupATR)

// ==================== FIBONACCI SETTINGS ====================
groupFibExt = "🌀 Fibonacci Last 2 Opposite Pivots"
showFib       = input.bool(title="Show Fibonacci",     defval=true, group=groupFibExt)
fibTF         = input.timeframe(title="Fib Timeframe", defval="D", group=groupFibExt)
fibPeriods    = input.int(title="Fib Periods",         defval=20, minval=2, group=groupFibExt)
fibSource0    = input.string(title="Fib 0 Source",     defval="Current High", options=["Current High", "Current Low", "Previous High", "Previous Low"], group=groupFibExt)
fibSource100  = input.string(title="Fib 100 Source",   defval="Current Low", options=["Current High", "Current Low", "Previous High", "Previous Low"], group=groupFibExt)
fibLineWidth  = input.int(title="Fib Line Width",      defval=2, minval=1, maxval=4, group=groupFibExt)
fibShowLabels = input.bool(title="Show Fib Labels",    defval=true, group=groupFibExt)

showFib0   = input.bool(title="Show 0%",     defval=true, group=groupFibExt)
showFib50  = input.bool(title="Show 50%",    defval=true, group=groupFibExt)
showFib62  = input.bool(title="Show 62.8%",  defval=true, group=groupFibExt)
showFib100 = input.bool(title="Show 100%",   defval=true, group=groupFibExt)
showFib112 = input.bool(title="Show 112%",   defval=true, group=groupFibExt)
showFib127 = input.bool(title="Show 127%",   defval=true, group=groupFibExt)
showFib162 = input.bool(title="Show 162.8%", defval=true, group=groupFibExt)

fibColor0   = input.color(title="0% Color",     defval=color.white, group=groupFibExt)
fibColor50  = input.color(title="50% Color",    defval=color.gray, group=groupFibExt)
fibColor62  = input.color(title="62.8% Color",  defval=color.silver, group=groupFibExt)
fibColor100 = input.color(title="100% Color",   defval=color.aqua, group=groupFibExt)
fibColor112 = input.color(title="112% Color",   defval=color.yellow, group=groupFibExt)
fibColor127 = input.color(title="127% Color",   defval=color.orange, group=groupFibExt)
fibColor162 = input.color(title="162.8% Color", defval=color.red, group=groupFibExt)

// ==================== FRACTAL FUNCTIONS ====================
calcUpFractal(int periods) =>
    bool upflagDownFrontier = true
    bool upflagUpFrontier0 = true
    bool upflagUpFrontier1 = true
    bool upflagUpFrontier2 = true
    bool upflagUpFrontier3 = true
    bool upflagUpFrontier4 = true
    for i = 1 to periods
        upflagDownFrontier := upflagDownFrontier and high[periods-i] < high[periods]
        upflagUpFrontier0  := upflagUpFrontier0 and high[periods+i] < high[periods]
        upflagUpFrontier1  := upflagUpFrontier1 and high[periods+1] <= high[periods] and high[periods+i+1] < high[periods]
        upflagUpFrontier2  := upflagUpFrontier2 and high[periods+1] <= high[periods] and high[periods+2] <= high[periods] and high[periods+i+2] < high[periods]
        upflagUpFrontier3  := upflagUpFrontier3 and high[periods+1] <= high[periods] and high[periods+2] <= high[periods] and high[periods+3] <= high[periods] and high[periods+i+3] < high[periods]
        upflagUpFrontier4  := upflagUpFrontier4 and high[periods+1] <= high[periods] and high[periods+2] <= high[periods] and high[periods+3] <= high[periods] and high[periods+4] <= high[periods] and high[periods+i+4] < high[periods]
    flagUpFrontier = upflagUpFrontier0 or upflagUpFrontier1 or upflagUpFrontier2 or upflagUpFrontier3 or upflagUpFrontier4
    upflagDownFrontier and flagUpFrontier

calcDownFractal(int periods) =>
    bool downflagDownFrontier = true
    bool downflagUpFrontier0 = true
    bool downflagUpFrontier1 = true
    bool downflagUpFrontier2 = true
    bool downflagUpFrontier3 = true
    bool downflagUpFrontier4 = true
    for i = 1 to periods
        downflagDownFrontier := downflagDownFrontier and low[periods-i] > low[periods]
        downflagUpFrontier0  := downflagUpFrontier0 and low[periods+i] > low[periods]
        downflagUpFrontier1  := downflagUpFrontier1 and low[periods+1] >= low[periods] and low[periods+i+1] > low[periods]
        downflagUpFrontier2  := downflagUpFrontier2 and low[periods+1] >= low[periods] and low[periods+2] >= low[periods] and low[periods+i+2] > low[periods]
        downflagUpFrontier3  := downflagUpFrontier3 and low[periods+1] >= low[periods] and low[periods+2] >= low[periods] and low[periods+3] >= low[periods] and low[periods+i+3] > low[periods]
        downflagUpFrontier4  := downflagUpFrontier4 and low[periods+1] >= low[periods] and low[periods+2] >= low[periods] and low[periods+3] >= low[periods] and low[periods+4] >= low[periods] and low[periods+i+4] > low[periods]
    flagDownFrontier = downflagUpFrontier0 or downflagUpFrontier1 or downflagUpFrontier2 or downflagUpFrontier3 or downflagUpFrontier4
    downflagDownFrontier and flagDownFrontier

// ==================== CORE LOGIC ====================
breakLines(line[] lines, float[] levels, bool[] broken, bool isSell, color extColor, color intColor, bool showExt, bool showInt) =>
    sz = math.min(math.min(array.size(lines), array.size(levels)), array.size(broken))
    if sz > 0
        for i = 0 to sz - 1
            if i < array.size(lines) and i < array.size(levels) and i < array.size(broken)
                l = array.get(lines, i)
                lvl = array.get(levels, i)
                alreadyBroken = array.get(broken, i)
                if not alreadyBroken
                    brokenNow = isSell ? close > lvl : close < lvl
                    if brokenNow
                        array.set(broken, i, true)
                        line.set_style(l, line.style_dashed)
                        line.set_color(l, showInt ? intColor : color.new(color.white, 100))
                    else
                        line.set_color(l, showExt ? extColor : color.new(color.white, 100))
                else
                    line.set_color(l, showInt ? intColor : color.new(color.white, 100))

// ==================== ARRAYS ====================
var line[] sellLines1 = array.new_line()
var line[] buyLines1 = array.new_line()
var float[] sellLevels1 = array.new_float()
var float[] buyLevels1 = array.new_float()
var bool[] sellBroken1 = array.new_bool()
var bool[] buyBroken1 = array.new_bool()
var box[] sellBoxes1 = array.new_box()
var box[] buyBoxes1 = array.new_box()
var label[] sellLabels1 = array.new_label()
var label[] buyLabels1 = array.new_label()

var line[] sellLines2 = array.new_line()
var line[] buyLines2 = array.new_line()
var float[] sellLevels2 = array.new_float()
var float[] buyLevels2 = array.new_float()
var bool[] sellBroken2 = array.new_bool()
var bool[] buyBroken2 = array.new_bool()
var box[] sellBoxes2 = array.new_box()
var box[] buyBoxes2 = array.new_box()
var label[] sellLabels2 = array.new_label()
var label[] buyLabels2 = array.new_label()

var line[] sellLines3 = array.new_line()
var line[] buyLines3 = array.new_line()
var float[] sellLevels3 = array.new_float()
var float[] buyLevels3 = array.new_float()
var bool[] sellBroken3 = array.new_bool()
var bool[] buyBroken3 = array.new_bool()
var box[] sellBoxes3 = array.new_box()
var box[] buyBoxes3 = array.new_box()
var label[] sellLabels3 = array.new_label()
var label[] buyLabels3 = array.new_label()

var line[] sellLines4 = array.new_line()
var line[] buyLines4 = array.new_line()
var float[] sellLevels4 = array.new_float()
var float[] buyLevels4 = array.new_float()
var bool[] sellBroken4 = array.new_bool()
var bool[] buyBroken4 = array.new_bool()
var box[] sellBoxes4 = array.new_box()
var box[] buyBoxes4 = array.new_box()
var label[] sellLabels4 = array.new_label()
var label[] buyLabels4 = array.new_label()

var line[] sellLines5 = array.new_line()
var line[] buyLines5 = array.new_line()
var float[] sellLevels5 = array.new_float()
var float[] buyLevels5 = array.new_float()
var bool[] sellBroken5 = array.new_bool()
var bool[] buyBroken5 = array.new_bool()
var box[] sellBoxes5 = array.new_box()
var box[] buyBoxes5 = array.new_box()
var label[] sellLabels5 = array.new_label()
var label[] buyLabels5 = array.new_label()

// ==================== TRACKING ====================
var int lastUpFractalBar1 = -1
var int lastDownFractalBar1 = -1
var int lastUpFractalBar2 = -1
var int lastDownFractalBar2 = -1
var int lastUpFractalBar3 = -1
var int lastDownFractalBar3 = -1
var int lastUpFractalBar4 = -1
var int lastDownFractalBar4 = -1
var int lastUpFractalBar5 = -1
var int lastDownFractalBar5 = -1

// ==================== FIB TRACKING ====================
var int fibLastPivotType = 0
var int fibPrevPivotType = 0
var int fibLastPivotTime = na
var int fibPrevPivotTime = na
var float fibLastPivotHigh = na
var float fibLastPivotLow = na
var float fibPrevPivotHigh = na
var float fibPrevPivotLow = na

var int fibPairType0Prev = 0
var int fibPairType0Last = 0
var int fibPairTime0Prev = na
var int fibPairTime0Last = na
var float fibPairHigh0 = na
var float fibPairLow0 = na
var int fibPairAnchor0 = na

var int fibPairType1Prev = 0
var int fibPairType1Last = 0
var int fibPairTime1Prev = na
var int fibPairTime1Last = na
var float fibPairHigh1 = na
var float fibPairLow1 = na
var int fibPairAnchor1 = na

var line fibLine0 = na
var line fibLine50 = na
var line fibLine62 = na
var line fibLine100 = na
var line fibLine112 = na
var line fibLine127 = na
var line fibLine162 = na

var label fibLbl0 = na
var label fibLbl50 = na
var label fibLbl62 = na
var label fibLbl100 = na
var label fibLbl112 = na
var label fibLbl127 = na
var label fibLbl162 = na

// ==================== HELPERS ====================
newLine(line[] lines, float[] levels, bool[] broken, int maxEl, int x1, float lvl, color lineColor, int lineW) =>
    chartMs = timeframe.in_seconds(timeframe.period) * 1000
    l = line.new(x1=x1, y1=lvl, x2=x1 + chartMs, y2=lvl, extend=extend.right, color=lineColor, width=lineW, style=line.style_solid, xloc=xloc.bar_time)
    array.push(lines, l)
    array.push(levels, lvl)
    array.push(broken, false)
    if array.size(lines) > maxEl
        line.delete(array.shift(lines))
        array.shift(levels)
        array.shift(broken)

processTf(bool enable, string fractalTF, int n, bool showShapes, string displayMode, int lineWidth, int rectTrans, int maxRect, color sellColor, color buyColor, bool showExternal, bool showInternal, int internalTrans, line[] sellLines, line[] buyLines, float[] sellLevels, float[] buyLevels, bool[] sellBroken, bool[] buyBroken, box[] sellBoxes, box[] buyBoxes, label[] sellLabels, label[] buyLabels, int lastUpFractalBar, int lastDownFractalBar, bool isTf5, color rectColor5Arg, color arrowUpColor5Arg, color arrowDownColor5Arg) =>
    useMultiTF = fractalTF != "" and fractalTF != timeframe.period
    upFractal = false
    downFractal = false
    fractalHigh = 0.0
    fractalLow = 0.0
    fractalOpen = 0.0
    fractalClose = 0.0
    fractalTime = 0

    newLastUpFractalBar = lastUpFractalBar
    newLastDownFractalBar = lastDownFractalBar

    if enable
        if useMultiTF
            [upF, downF, htfTimeOffset, htfHigh, htfLow, htfOpen, htfClose] = request.security(
                 syminfo.tickerid,
                 fractalTF,
                 [calcUpFractal(n), calcDownFractal(n), time[n], high[n], low[n], open[n], close[n]],
                 lookahead=barmerge.lookahead_off)

            if upF and htfTimeOffset != newLastUpFractalBar
                upFractal := true
                newLastUpFractalBar := htfTimeOffset
                fractalHigh := htfHigh
                fractalLow := htfLow
                fractalOpen := htfOpen
                fractalClose := htfClose
                fractalTime := htfTimeOffset

            if downF and htfTimeOffset != newLastDownFractalBar
                downFractal := true
                newLastDownFractalBar := htfTimeOffset
                fractalHigh := htfHigh
                fractalLow := htfLow
                fractalOpen := htfOpen
                fractalClose := htfClose
                fractalTime := htfTimeOffset
        else
            upFractal := calcUpFractal(n)
            downFractal := calcDownFractal(n)
            fractalHigh := high[n]
            fractalLow := low[n]
            fractalOpen := open[n]
            fractalClose := close[n]
            fractalTime := time[n]

    if enable and upFractal
        lc = useMultiTF ? fractalTime : time[n]
        bodyTop = math.max(fractalOpen, fractalClose)

        if showShapes
            atrOffset = ta.atr(14) * 0.25
            lb = label.new(x=lc, y=isTf5 ? fractalHigh + atrOffset : fractalHigh, style=label.style_triangledown, color=isTf5 ? arrowUpColor5Arg : sellColor, size=isTf5 ? size.auto : size.tiny, xloc=xloc.bar_time, text="", textcolor=isTf5 ? arrowUpColor5Arg : sellColor)
            array.push(sellLabels, lb)
            if array.size(sellLabels) > maxRect
                label.delete(array.shift(sellLabels))

        if displayMode == "Zone"
            zoneColor = isTf5 ? rectColor5Arg : sellColor
            b = box.new(left=lc, top=fractalHigh, right=lc, bottom=bodyTop, border_color=color.new(zoneColor, rectTrans), bgcolor=color.new(zoneColor, rectTrans), border_width=1, extend=extend.right, xloc=xloc.bar_time)
            array.push(sellBoxes, b)
            if array.size(sellBoxes) > maxRect
                box.delete(array.shift(sellBoxes))
        else
            lineColor = isTf5 ? rectColor5Arg : sellColor
            newLine(sellLines, sellLevels, sellBroken, maxRect, lc, bodyTop, lineColor, lineWidth)

    if enable and downFractal
        lc = useMultiTF ? fractalTime : time[n]
        bodyBottom = math.min(fractalOpen, fractalClose)

        if showShapes
            atrOffset = ta.atr(14) * 0.25
            lb = label.new(x=lc, y=isTf5 ? fractalLow - atrOffset : fractalLow, style=label.style_triangleup, color=isTf5 ? arrowDownColor5Arg : buyColor, size=isTf5 ? size.auto : size.tiny, xloc=xloc.bar_time, text="", textcolor=isTf5 ? arrowDownColor5Arg : buyColor)
            array.push(buyLabels, lb)
            if array.size(buyLabels) > maxRect
                label.delete(array.shift(buyLabels))

        if displayMode == "Zone"
            zoneColor = isTf5 ? rectColor5Arg : buyColor
            b = box.new(left=lc, top=bodyBottom, right=lc, bottom=fractalLow, border_color=color.new(zoneColor, rectTrans), bgcolor=color.new(zoneColor, rectTrans), border_width=1, extend=extend.right, xloc=xloc.bar_time)
            array.push(buyBoxes, b)
            if array.size(buyBoxes) > maxRect
                box.delete(array.shift(buyBoxes))
        else
            lineColor = isTf5 ? rectColor5Arg : buyColor
            newLine(buyLines, buyLevels, buyBroken, maxRect, lc, bodyBottom, lineColor, lineWidth)

    if enable and displayMode == "Line"
        extSell = isTf5 ? rectColor5Arg : sellColor
        extBuy = isTf5 ? rectColor5Arg : buyColor
        intSell = color.new(extSell, internalTrans)
        intBuy = color.new(extBuy, internalTrans)

        breakLines(sellLines, sellLevels, sellBroken, true, extSell, intSell, showExternal, showInternal)
        breakLines(buyLines, buyLevels, buyBroken, false, extBuy, intBuy, showExternal, showInternal)

    [newLastUpFractalBar, newLastDownFractalBar]

// ==================== TF1-5 ====================
[newUp1, newDown1] = processTf(enable1, fractalTF1, n1, showShapes1, displayMode1, lineWidth1, rectTrans1, maxRect1, sellColor1, buyColor1, showExternal1, showInternal1, internalTrans1, sellLines1, buyLines1, sellLevels1, buyLevels1, sellBroken1, buyBroken1, sellBoxes1, buyBoxes1, sellLabels1, buyLabels1, lastUpFractalBar1, lastDownFractalBar1, false, color(na), color(na), color(na))
lastUpFractalBar1 := newUp1
lastDownFractalBar1 := newDown1

[newUp2, newDown2] = processTf(enable2, fractalTF2, n2, showShapes2, displayMode2, lineWidth2, rectTrans2, maxRect2, sellColor2, buyColor2, showExternal2, showInternal2, internalTrans2, sellLines2, buyLines2, sellLevels2, buyLevels2, sellBroken2, buyBroken2, sellBoxes2, buyBoxes2, sellLabels2, buyLabels2, lastUpFractalBar2, lastDownFractalBar2, false, color(na), color(na), color(na))
lastUpFractalBar2 := newUp2
lastDownFractalBar2 := newDown2

[newUp3, newDown3] = processTf(enable3, fractalTF3, n3, showShapes3, displayMode3, lineWidth3, rectTrans3, maxRect3, sellColor3, buyColor3, showExternal3, showInternal3, internalTrans3, sellLines3, buyLines3, sellLevels3, buyLevels3, sellBroken3, buyBroken3, sellBoxes3, buyBoxes3, sellLabels3, buyLabels3, lastUpFractalBar3, lastDownFractalBar3, false, color(na), color(na), color(na))
lastUpFractalBar3 := newUp3
lastDownFractalBar3 := newDown3

[newUp4, newDown4] = processTf(enable4, fractalTF4, n4, showShapes4, displayMode4, lineWidth4, rectTrans4, maxRect4, sellColor4, buyColor4, showExternal4, showInternal4, internalTrans4, sellLines4, buyLines4, sellLevels4, buyLevels4, sellBroken4, buyBroken4, sellBoxes4, buyBoxes4, sellLabels4, buyLabels4, lastUpFractalBar4, lastDownFractalBar4, false, color(na), color(na), color(na))
lastUpFractalBar4 := newUp4
lastDownFractalBar4 := newDown4

[newUp5, newDown5] = processTf(enable5, fractalTF5, n5, showShapes5, displayMode5, lineWidth5, rectTrans5, maxRect5, rectColor5, rectColor5, showExternal5, showInternal5, internalTrans5, sellLines5, buyLines5, sellLevels5, buyLevels5, sellBroken5, buyBroken5, sellBoxes5, buyBoxes5, sellLabels5, buyLabels5, lastUpFractalBar5, lastDownFractalBar5, true, rectColor5, arrowUpColor5, arrowDownColor5)
lastUpFractalBar5 := newUp5
lastDownFractalBar5 := newDown5

// ==================== ALERT TF4 ====================
var bool alertSell4 = false
var bool alertBuy4 = false
var float alertSellLvl4 = 0.0
var float alertBuyLvl4 = 0.0

alertSell4 := false
alertBuy4 := false

if enableAlert4 and enable4 and displayMode4 == "Line" and barstate.isrealtime
    szs = math.min(array.size(sellLevels4), array.size(sellBroken4))
    if szs > 0
        for i = 0 to szs - 1
            if i < array.size(sellLevels4) and i < array.size(sellBroken4)
                lvl = array.get(sellLevels4, i)
                broken = array.get(sellBroken4, i)
                if not broken and low <= lvl and high >= lvl
                    alertSell4 := true
                    alertSellLvl4 := lvl

    szb = math.min(array.size(buyLevels4), array.size(buyBroken4))
    if szb > 0
        for i = 0 to szb - 1
            if i < array.size(buyLevels4) and i < array.size(buyBroken4)
                lvl = array.get(buyLevels4, i)
                broken = array.get(buyBroken4, i)
                if not broken and low <= lvl and high >= lvl
                    alertBuy4 := true
                    alertBuyLvl4 := lvl

alertcondition(alertSell4, title="H1 Sell Resistance Test", message="H1 resistance test: {{ticker}} is testing {{plot_0}}")
alertcondition(alertBuy4, title="H1 Buy Support Test", message="H1 support test: {{ticker}} is testing {{plot_1}}")

plot(alertSell4 ? alertSellLvl4 : na, title="Alert Sell Level", display=display.none)
plot(alertBuy4 ? alertBuyLvl4 : na, title="Alert Buy Level", display=display.none)

// ==================== FIBONACCI LAST 2 OPPOSITE PIVOTS ====================
fibUseMultiTF = fibTF != "" and fibTF != timeframe.period
fibUpFractal = false
fibDownFractal = false
fibFractalHigh = 0.0
fibFractalLow = 0.0
fibFractalTime = 0

if showFib
    if fibUseMultiTF
        [fibUpF, fibDownF, fibHighPivot, fibLowPivot, fibTimePivot] = request.security(
             syminfo.tickerid,
             fibTF,
             [calcUpFractal(fibPeriods), calcDownFractal(fibPeriods), high[fibPeriods], low[fibPeriods], time[fibPeriods]],
             lookahead=barmerge.lookahead_on)

        if fibUpF
            fibUpFractal := true
            fibFractalHigh := fibHighPivot
            fibFractalLow := fibLowPivot
            fibFractalTime := fibTimePivot

        if fibDownF
            fibDownFractal := true
            fibFractalHigh := fibHighPivot
            fibFractalLow := fibLowPivot
            fibFractalTime := fibTimePivot
    else
        fibUpFractal := calcUpFractal(fibPeriods)
        fibDownFractal := calcDownFractal(fibPeriods)
        fibFractalHigh := high[fibPeriods]
        fibFractalLow := low[fibPeriods]
        fibFractalTime := time[fibPeriods]

currPivotType = fibUpFractal ? 1 : fibDownFractal ? -1 : 0

if currPivotType != 0 and not na(fibFractalTime)
    isNewPivot = fibFractalTime != fibLastPivotTime or currPivotType != fibLastPivotType

    if isNewPivot
        if fibLastPivotType != 0 and fibLastPivotType != currPivotType
            fibPrevPivotType := fibLastPivotType
            fibPrevPivotTime := fibLastPivotTime
            fibPrevPivotHigh := fibLastPivotHigh
            fibPrevPivotLow := fibLastPivotLow

            fibLastPivotType := currPivotType
            fibLastPivotTime := fibFractalTime
            fibLastPivotHigh := fibFractalHigh
            fibLastPivotLow := fibFractalLow

            fibPairType1Prev := fibPairType0Prev
            fibPairType1Last := fibPairType0Last
            fibPairTime1Prev := fibPairTime0Prev
            fibPairTime1Last := fibPairTime0Last
            fibPairHigh1 := fibPairHigh0
            fibPairLow1 := fibPairLow0
            fibPairAnchor1 := fibPairAnchor0

            fibPairType0Prev := fibPrevPivotType
            fibPairType0Last := fibLastPivotType
            fibPairTime0Prev := fibPrevPivotTime
            fibPairTime0Last := fibLastPivotTime

            if fibPrevPivotType == -1 and fibLastPivotType == 1
                fibPairHigh0 := fibLastPivotHigh
                fibPairLow0 := fibPrevPivotLow
                fibPairAnchor0 := fibLastPivotTime
            else if fibPrevPivotType == 1 and fibLastPivotType == -1
                fibPairHigh0 := fibPrevPivotHigh
                fibPairLow0 := fibLastPivotLow
                fibPairAnchor0 := fibPrevPivotTime
        else
            fibLastPivotType := currPivotType
            fibLastPivotTime := fibFractalTime
            fibLastPivotHigh := fibFractalHigh
            fibLastPivotLow := fibFractalLow

int fibAnchorTime = na
float fibCurrHigh = fibPairHigh0
float fibCurrLow = fibPairLow0
float fibPrevHigh = fibPairHigh1
float fibPrevLow = fibPairLow1
float fibLevel0Source = na
float fibLevel100Source = na
float fibRange = na

if not na(fibPairAnchor0)
    fibAnchorTime := fibPairAnchor0
else if not na(fibPairAnchor1)
    fibAnchorTime := fibPairAnchor1

if fibSource0 == "Current High"
    fibLevel0Source := fibCurrHigh
else if fibSource0 == "Current Low"
    fibLevel0Source := fibCurrLow
else if fibSource0 == "Previous High"
    fibLevel0Source := fibPrevHigh
else if fibSource0 == "Previous Low"
    fibLevel0Source := fibPrevLow

if fibSource100 == "Current High"
    fibLevel100Source := fibCurrHigh
else if fibSource100 == "Current Low"
    fibLevel100Source := fibCurrLow
else if fibSource100 == "Previous High"
    fibLevel100Source := fibPrevHigh
else if fibSource100 == "Previous Low"
    fibLevel100Source := fibPrevLow

float fib0 = na
float fib50 = na
float fib62 = na
float fib100 = na
float fib112 = na
float fib127 = na
float fib162 = na

if not na(fibLevel0Source) and not na(fibLevel100Source) and fibLevel0Source != fibLevel100Source
    fib0 := fibLevel0Source
    fib100 := fibLevel100Source
    fibRange := fib100 - fib0
    fib50 := fib0 + fibRange * 0.50
    fib62 := fib0 + fibRange * 0.628
    fib112 := fib0 + fibRange * 1.12
    fib127 := fib0 + fibRange * 1.27
    fib162 := fib0 + fibRange * 1.628

if barstate.islast
    line.delete(fibLine0)
    label.delete(fibLbl0)
    line.delete(fibLine50)
    label.delete(fibLbl50)
    line.delete(fibLine62)
    label.delete(fibLbl62)
    line.delete(fibLine100)
    label.delete(fibLbl100)
    line.delete(fibLine112)
    label.delete(fibLbl112)
    line.delete(fibLine127)
    label.delete(fibLbl127)
    line.delete(fibLine162)
    label.delete(fibLbl162)

    chartMsFib = timeframe.in_seconds(timeframe.period) * 1000
    fibLabelX = time + chartMsFib * 6

    if showFib and showFib0 and not na(fibAnchorTime) and not na(fib0)
        fibLine0 := line.new(x1=fibAnchorTime, y1=fib0, x2=fibAnchorTime + chartMsFib, y2=fib0, xloc=xloc.bar_time, extend=extend.right, color=fibColor0, width=fibLineWidth)
        if fibShowLabels
            fibLbl0 := label.new(x=fibLabelX, y=fib0, text="Fib 0%", xloc=xloc.bar_time, style=label.style_label_left, color=fibColor0, textcolor=color.white, size=size.small)

    if showFib and showFib50 and not na(fibAnchorTime) and not na(fib50)
        fibLine50 := line.new(x1=fibAnchorTime, y1=fib50, x2=fibAnchorTime + chartMsFib, y2=fib50, xloc=xloc.bar_time, extend=extend.right, color=fibColor50, width=fibLineWidth)
        if fibShowLabels
            fibLbl50 := label.new(x=fibLabelX, y=fib50, text="Fib 50%", xloc=xloc.bar_time, style=label.style_label_left, color=fibColor50, textcolor=color.white, size=size.small)

    if showFib and showFib62 and not na(fibAnchorTime) and not na(fib62)
        fibLine62 := line.new(x1=fibAnchorTime, y1=fib62, x2=fibAnchorTime + chartMsFib, y2=fib62, xloc=xloc.bar_time, extend=extend.right, color=fibColor62, width=fibLineWidth)
        if fibShowLabels
            fibLbl62 := label.new(x=fibLabelX, y=fib62, text="Fib 62.8%", xloc=xloc.bar_time, style=label.style_label_left, color=fibColor62, textcolor=color.white, size=size.small)

    if showFib and showFib100 and not na(fibAnchorTime) and not na(fib100)
        fibLine100 := line.new(x1=fibAnchorTime, y1=fib100, x2=fibAnchorTime + chartMsFib, y2=fib100, xloc=xloc.bar_time, extend=extend.right, color=fibColor100, width=fibLineWidth)
        if fibShowLabels
            fibLbl100 := label.new(x=fibLabelX, y=fib100, text="Fib 100%", xloc=xloc.bar_time, style=label.style_label_left, color=fibColor100, textcolor=color.white, size=size.small)

    if showFib and showFib112 and not na(fibAnchorTime) and not na(fib112)
        fibLine112 := line.new(x1=fibAnchorTime, y1=fib112, x2=fibAnchorTime + chartMsFib, y2=fib112, xloc=xloc.bar_time, extend=extend.right, color=fibColor112, width=fibLineWidth)
        if fibShowLabels
            fibLbl112 := label.new(x=fibLabelX, y=fib112, text="Fib 112%", xloc=xloc.bar_time, style=label.style_label_left, color=fibColor112, textcolor=color.white, size=size.small)

    if showFib and showFib127 and not na(fibAnchorTime) and not na(fib127)
        fibLine127 := line.new(x1=fibAnchorTime, y1=fib127, x2=fibAnchorTime + chartMsFib, y2=fib127, xloc=xloc.bar_time, extend=extend.right, color=fibColor127, width=fibLineWidth)
        if fibShowLabels
            fibLbl127 := label.new(x=fibLabelX, y=fib127, text="Fib 127%", xloc=xloc.bar_time, style=label.style_label_left, color=fibColor127, textcolor=color.white, size=size.small)

    if showFib and showFib162 and not na(fibAnchorTime) and not na(fib162)
        fibLine162 := line.new(x1=fibAnchorTime, y1=fib162, x2=fibAnchorTime + chartMsFib, y2=fib162, xloc=xloc.bar_time, extend=extend.right, color=fibColor162, width=fibLineWidth)
        if fibShowLabels
            fibLbl162 := label.new(x=fibLabelX, y=fib162, text="Fib 162.8%", xloc=xloc.bar_time, style=label.style_label_left, color=fibColor162, textcolor=color.white, size=size.small)

// ==================== ATR / ADR / DAILY OPEN ====================
dOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
atrD = request.security(syminfo.tickerid, "D", ta.atr(atrLen), lookahead=barmerge.lookahead_on)
dHigh = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
dLow = request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_on)
dayOpenTime = time("D")

dailyRange = request.security(syminfo.tickerid, "D", high - low, lookahead=barmerge.lookahead_off)
adrD = ta.sma(dailyRange, adrLen)

doneRange = dHigh - dLow
atrSafe = math.max(atrD, syminfo.mintick)
adrSafe = math.max(adrD, syminfo.mintick)

usedPctATR = doneRange / atrSafe * 100.0
usedPctADR = doneRange / adrSafe * 100.0
over100ATR = usedPctATR >= 100.0
over100ADR = usedPctADR >= 100.0

leftRangeATR = over100ATR ? 0.0 : math.max(atrSafe - doneRange, 0.0)
leftRangeADR = over100ADR ? 0.0 : math.max(adrSafe - doneRange, 0.0)

pipSize = syminfo.mintick * 10
unitSize = usePips ? pipSize : syminfo.mintick
unitLabel = usePips ? " pips" : " pts"

atrVal = atrD / unitSize
adrVal = adrD / unitSize
doneVal = doneRange / unitSize
leftValATR = leftRangeATR / unitSize
leftValADR = leftRangeADR / unitSize

atrUpper = dOpen + atrD
atrLower = dOpen - atrD
adrUpper = dOpen + adrD
adrLower = dOpen - adrD

statusColorATR = usedPctATR < greenPct ? color.lime : usedPctATR < yellowPct ? color.yellow : color.red
statusColorADR = usedPctADR < greenPct ? color.lime : usedPctADR < yellowPct ? color.yellow : color.red

var line lUpATR = na
var line lDnATR = na
var label lbUATR = na
var label lbDATR = na
var line lUpADR = na
var line lDnADR = na
var label lbUADR = na
var label lbDADR = na
var line lDailyOpen = na
var label lbDailyOpen = na

if showATR and barstate.islast
    if showATRLines
        line.delete(lUpATR)
        line.delete(lDnATR)
        label.delete(lbUATR)
        label.delete(lbDATR)
        lUpATR := line.new(dayOpenTime, atrUpper, time + 1000000, atrUpper, xloc=xloc.bar_time, color=color.new(color.gray, 30), style=line.style_dashed, extend=extend.right)
        lDnATR := line.new(dayOpenTime, atrLower, time + 1000000, atrLower, xloc=xloc.bar_time, color=color.new(color.gray, 30), style=line.style_dashed, extend=extend.right)
        lbUATR := label.new(time, atrUpper, "ATR High " + str.tostring(atrVal, "#.1") + unitLabel, xloc=xloc.bar_time, style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small)
        lbDATR := label.new(time, atrLower, "ATR Low " + str.tostring(atrVal, "#.1") + unitLabel, xloc=xloc.bar_time, style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small)

    if showADRLines
        line.delete(lUpADR)
        line.delete(lDnADR)
        label.delete(lbUADR)
        label.delete(lbDADR)
        lUpADR := line.new(dayOpenTime, adrUpper, time + 1000000, adrUpper, xloc=xloc.bar_time, color=color.new(color.blue, 30), style=line.style_dotted, extend=extend.right)
        lDnADR := line.new(dayOpenTime, adrLower, time + 1000000, adrLower, xloc=xloc.bar_time, color=color.new(color.blue, 30), style=line.style_dotted, extend=extend.right)
        lbUADR := label.new(time, adrUpper, "ADR High " + str.tostring(adrVal, "#.1") + unitLabel, xloc=xloc.bar_time, style=label.style_label_left, color=color.blue, textcolor=color.white, size=size.small)
        lbDADR := label.new(time, adrLower, "ADR Low " + str.tostring(adrVal, "#.1") + unitLabel, xloc=xloc.bar_time, style=label.style_label_left, color=color.blue, textcolor=color.white, size=size.small)

    if showDailyOpen
        line.delete(lDailyOpen)
        label.delete(lbDailyOpen)
        lDailyOpen := line.new(dayOpenTime, dOpen, time + 1000000, dOpen, xloc=xloc.bar_time, color=color.new(dailyOpenColor, 0), style=line.style_solid, width=2, extend=extend.right)
        lbDailyOpen := label.new(time, dOpen, "Daily Open", xloc=xloc.bar_time, style=label.style_label_left, color=dailyOpenColor, textcolor=color.white, size=size.small)

var table t = table.new(position.top_right, 2, 6, border_width=1)

if showATR and barstate.islast
    table.cell(t, 0, 0, "ATR Progress", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    table.cell(t, 1, 0, str.tostring(usedPctATR, "#.1") + "%", text_color=color.black, bgcolor=statusColorATR, text_size=size.normal)

    table.cell(t, 0, 1, "Daily ATR", text_color=color.white, bgcolor=color.gray, text_size=size.normal)
    table.cell(t, 1, 1, str.tostring(atrVal, "#.1") + unitLabel, text_color=color.white, bgcolor=color.gray, text_size=size.normal)

    table.cell(t, 0, 2, "Done", text_color=color.white, bgcolor=color.gray, text_size=size.normal)
    table.cell(t, 1, 2, str.tostring(doneVal, "#.1") + unitLabel, text_color=color.white, bgcolor=color.gray, text_size=size.normal)

    table.cell(t, 0, 3, "Left ATR", text_color=color.white, bgcolor=color.gray, text_size=size.normal)
    table.cell(t, 1, 3, str.tostring(leftValATR, "#.1") + unitLabel, text_color=color.white, bgcolor=color.gray, text_size=size.normal)

    table.cell(t, 0, 4, "ADR Progress", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    table.cell(t, 1, 4, str.tostring(usedPctADR, "#.1") + "%", text_color=color.black, bgcolor=statusColorADR, text_size=size.normal)

    table.cell(t, 0, 5, "Left ADR", text_color=color.white, bgcolor=color.gray, text_size=size.normal)
    table.cell(t, 1, 5, str.tostring(leftValADR, "#.1") + unitLabel, text_color=color.white, bgcolor=color.gray, text_size=size.normal)
````
