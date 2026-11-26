# Quantum VWAP

- url: https://www.tradingview.com/script/uxNkvIMO-Quantum-VWAP/
- type: indicator
- pine_id: PUB;c83291b74f804f3ca0eaf25cab19ae59
- version: 1.0

## Description

Quantum VWAP — Indicator Summary

Quantum VWAP is a multi-module TradingView indicator built around VWAP, liquidity zones, macro timing, Fair Value Gaps, breaker zones, trend structure, support/resistance, volume pressure, and daily market context.

It displays a Global VWAP with configurable bands and forward labels, while avoiding duplicate Global VWAP plots. It also includes a separate NY 09:30 VWAP module and a New York 00:00 horizontal line.

The indicator detects and draws Fair Value Gaps on the current timeframe only when the FVG displacement candle touches the Global VWAP or one of its bands. It also shows 5-minute NFT Fair Value Gaps on lower timeframes when the same VWAP-touch condition is met.

It includes Breaker VWAP zones, drawn from the last opposite candle before the Fair Value Gap, and keeps the setup visible until the entry condition is reached.

The Macro module marks New York macro windows and can detect macro-based Fair Value Gap setups, including current timeframe FVG, breaker zone, and 5-minute macro FVG confirmation.

The indicator also includes entry arrows, colored green for bullish setups and red for bearish setups, positioned away from the candle for better visibility.

Additional modules include:

Daily Bias Table
Trend Bar and Doji coloring
Minervini-style trend lines
Support and resistance lines
Big Trade volume pressure pads
Daily Volume Range
Daily POC
NY 00:00 line

## Source Code

````pine
//@version=6
indicator("Quantum VWAP", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)

//====================================================
// Inputs
//====================================================
groupToggles   = "Toggles"
groupBase      = "Global VWAP"
groupBands     = "Bands"
groupStyle     = "Style"
groupMacro     = "Macro"
groupCurrentFVG = "Fair Value Gap VWAP"
groupMTFFVG     = "NFT 5 минути VWAP"
groupBreaker    = "Breaker VWAP"
groupMacroFVG   = "Fair Value Gap Macro"
groupMacroMTFFVG = "NFT 5 минути Macro"
groupTrendBars = "Trend Bars"
groupDoji      = "Doji"
groupBigTradeMain = "Big Trade Micro Pads / Main"
groupBigTradeCalc = "Big Trade Micro Pads / Calculation"
groupBigTradeBias = "Big Trade Micro Pads / Candle Bias"
groupBigTradeVis  = "Big Trade Micro Pads / Visual"
groupCISD          = "CISD Settings"

showVWAPModule         = input.bool(true,  "Show Global VWAP",      group = groupToggles)
showMacroModule        = input.bool(true,  "Show Macro",            group = groupToggles)
showCurrentFVGModule   = input.bool(true,  "Show Current TF FVG",   group = groupToggles)
showMTFFVGModule       = input.bool(true,  "Show NFT 5m FVG",       group = groupToggles)
showMacroFVGModule     = input.bool(true,  "Show Macro FVG + Breaker", group = groupToggles)
showMacroMTFFVGModule  = input.bool(true,  "Show Macro NFT 5m FVG", group = groupToggles)
showTrendBarsModule = input.bool(true,  "Show Trend Bar",        group = groupToggles)
showDojiModule      = input.bool(true,  "Show Doji",             group = groupToggles)
showMinqTrendLinesModule = input.bool(true,  "Show Trend Lines", group = groupToggles)
showMinqSRModule         = input.bool(true,  "Show Support / Resistance", group = groupToggles)
showBigTradeModule  = input.bool(true,  "Show Big Trade Micro Pads", group = groupToggles)
showNY0000LineModule = input.bool(true,  "Show NY 00:00 Line", group = groupToggles)
showDailyRangeModule = input.bool(true,  "Show Daily Volume Range + POC", group = groupToggles)
showCISDModule = input.bool(true,  "Show CISD", group = groupToggles)

src      = input.source(hlc3, "Source", group = groupBase)
anchorTf = input.timeframe("1D", "VWAP reset timeframe", group = groupBase)

showBand1 = input.bool(true,  "Show Band 1", group = groupBands)
showBand2 = input.bool(true,  "Show Band 2", group = groupBands)
showBand3 = input.bool(false, "Show Band 3", group = groupBands)
multBand1 = input.float(1.0, "Band 1 multiplier", minval = 0.0, step = 0.1, group = groupBands)
multBand2 = input.float(2.0, "Band 2 multiplier", minval = 0.0, step = 0.1, group = groupBands)
multBand3 = input.float(3.0, "Band 3 multiplier", minval = 0.0, step = 0.1, group = groupBands)

vwapColor   = input.color(color.new(color.rgb(255, 220, 0), 25), "VWAP color", group = groupStyle)
upper1Color = input.color(color.new(color.rgb(0, 205, 225), 25), "Upper Band 1 color", group = groupStyle)
upper2Color = input.color(color.new(color.rgb(45, 170, 70), 20), "Upper Band 2 color", group = groupStyle)
upper3Color = input.color(color.new(color.rgb(180, 180, 180), 30), "Upper Band 3 color", group = groupStyle)
lower1Color = input.color(color.new(color.rgb(255, 80, 70), 25), "Lower Band 1 color", group = groupStyle)
lower2Color = input.color(color.new(color.rgb(255, 80, 70), 25), "Lower Band 2 color", group = groupStyle)
lower3Color = input.color(color.new(color.rgb(180, 180, 180), 30), "Lower Band 3 color", group = groupStyle)

upperFill = input.color(color.new(color.rgb(20, 95, 35), 82), "Upper fill color", group = groupStyle)
lowerFill = input.color(color.new(color.rgb(95, 20, 20), 82), "Lower fill color", group = groupStyle)

vwapWidth  = input.int(3, "VWAP width", minval = 1, maxval = 5, group = groupStyle)
band1Width = input.int(2, "Band 1 width", minval = 1, maxval = 5, group = groupStyle)
band2Width = input.int(2, "Band 2 width", minval = 1, maxval = 5, group = groupStyle)
band3Width = input.int(2, "Band 3 width", minval = 1, maxval = 5, group = groupStyle)

macroTimezone   = input.string("America/New_York", "Macro timezone", group = groupMacro)
macroColor      = input.color(color.new(color.rgb(214, 120, 255), 35), "Macro color", group = groupMacro)
macroLineWidth  = input.int(2, "Macro line width", minval = 1, maxval = 5, group = groupMacro)
macroLineStyleS = input.string("Dotted", "Macro line style", options = ["Dotted", "Dashed", "Solid"], group = groupMacro)
macroLabelColor = input.color(color.rgb(255, 215, 255), "Macro text color", group = groupMacro)
macroOffsetAtr  = input.float(0.05, "Macro label offset ATR", minval = 0.0, step = 0.01, group = groupMacro)

currentFvgLengthBars  = input.int(15, "FVG length bars", minval = 1, maxval = 100, group = groupCurrentFVG)
currentFvgBullFill    = input.color(color.new(color.rgb(72, 112, 198), 76), "Bull FVG fill", group = groupCurrentFVG)
currentFvgBullBorder  = input.color(color.new(color.rgb(108, 146, 240), 60), "Bull FVG border", group = groupCurrentFVG)
currentFvgBearFill    = input.color(color.new(color.rgb(205, 92, 92), 76), "Bear FVG fill", group = groupCurrentFVG)
currentFvgBearBorder  = input.color(color.new(color.rgb(240, 120, 112), 60), "Bear FVG border", group = groupCurrentFVG)
currentFvgBorderWidth = input.int(2, "FVG border width", minval = 1, maxval = 5, group = groupCurrentFVG)
currentFvgBorderStyle = input.string("Dotted", "FVG border style", options = ["Solid", "Dashed", "Dotted"], group = groupCurrentFVG)
currentFvgTextColor   = input.color(color.rgb(255, 190, 70), "FVG text color", group = groupCurrentFVG)

mtfFvgTf           = input.timeframe("5", "NFT FVG timeframe", group = groupMTFFVG)
mtfFvgLengthBars   = input.int(15, "NFT FVG length bars", minval = 1, maxval = 300, group = groupMTFFVG)
mtfFvgBullFill     = input.color(color.new(color.rgb(0, 190, 205), 78), "NFT Bull FVG fill", group = groupMTFFVG)
mtfFvgBullBorder   = input.color(color.new(color.rgb(0, 220, 255), 60), "NFT Bull FVG border", group = groupMTFFVG)
mtfFvgBearFill     = input.color(color.new(color.rgb(210, 80, 75), 78), "NFT Bear FVG fill", group = groupMTFFVG)
mtfFvgBearBorder   = input.color(color.new(color.rgb(255, 90, 80), 60), "NFT Bear FVG border", group = groupMTFFVG)
mtfFvgBorderWidth  = input.int(2, "NFT FVG border width", minval = 1, maxval = 5, group = groupMTFFVG)
mtfFvgBorderStyle  = input.string("Dotted", "NFT FVG border style", options = ["Solid", "Dashed", "Dotted"], group = groupMTFFVG)
mtfFvgTextColor    = input.color(color.rgb(255, 190, 70), "NFT FVG text color", group = groupMTFFVG)

breakerFill        = input.color(color.new(color.rgb(165, 165, 165), 78), "Breaker fill", group = groupBreaker)
breakerBorder      = input.color(color.new(color.rgb(145, 145, 145), 100), "Breaker border", group = groupBreaker)
breakerBorderWidth = input.int(1, "Breaker border width", minval = 1, maxval = 5, group = groupBreaker)
breakerBorderStyle = input.string("Solid", "Breaker border style", options = ["Solid", "Dashed", "Dotted"], group = groupBreaker)
breakerTextColor   = input.color(color.rgb(255, 190, 70), "Breaker text color", group = groupBreaker)

trendBarBullColor    = input.color(color.rgb(255, 245, 140), "Bull trend bar color", group = groupTrendBars)
trendBarBearColor    = input.color(color.rgb(196, 150, 0), "Bear trend bar color", group = groupTrendBars)
trendBarMaxWickRatio = input.float(0.20, "Max wick/body ratio", minval = 0.0, step = 0.01, group = groupTrendBars)
trendBarMinSpacing   = input.int(8, "Min bars between trend bars", minval = 0, maxval = 100, group = groupTrendBars)

dojiBullColor     = input.color(color.rgb(255, 170, 0), "Bull doji color", group = groupDoji)
dojiBearColor     = input.color(color.rgb(255, 215, 140), "Bear doji color", group = groupDoji)
dojiMaxBodyRatio  = input.float(0.25, "Max doji body/range ratio", minval = 0.01, maxval = 1.0, step = 0.01, group = groupDoji)
dojiMinVolumeMult = input.float(0.90, "Min doji volume x avg", minval = 0.0, step = 0.05, group = groupDoji)


bt_showBuy             = input.bool(true,  "Show Buy Prints", group = groupBigTradeMain)
bt_showSell            = input.bool(true,  "Show Sell Prints", group = groupBigTradeMain)

bt_useAutoThreshold    = input.bool(true,  "Auto Threshold", group = groupBigTradeMain)
bt_manualThreshold     = input.float(55.0, "Manual Threshold", minval = 1.0, step = 1.0, group = groupBigTradeMain)
bt_autoLen             = input.int(20, "Auto Avg Length", minval = 1, group = groupBigTradeMain)
bt_autoMultiplier      = input.float(0.80, "Auto Multiplier", minval = 0.05, step = 0.01, group = groupBigTradeMain)

bt_calcMode            = input.string("Hybrid", "Pressure Model", options = ["Close In Range", "Body Pressure", "Hybrid"], group = groupBigTradeCalc)
bt_useBarFlowBoost     = input.bool(true, "Use Momentum / Flow Boost", group = groupBigTradeCalc)
bt_minBodyPercent      = input.float(0.0, "Min Body % Filter", minval = 0.0, maxval = 100.0, step = 0.1, group = groupBigTradeCalc)
bt_minDominancePercent = input.float(2.0, "Min Dominance %", minval = 0.0, maxval = 100.0, step = 0.1, group = groupBigTradeCalc)

bt_strictCandleBias    = input.bool(true, "Prefer Candle Direction", group = groupBigTradeBias)
bt_allowCounterPrints  = input.bool(true, "Allow Rare Opposite Prints", group = groupBigTradeBias)
bt_counterMinDominance = input.float(26.0, "Opposite Print Min Dominance %", minval = 0.0, maxval = 100.0, step = 0.1, group = groupBigTradeBias)

bt_maxPrintsPerSide    = input.int(2, "Max Prints Per Side", minval = 1, maxval = 6, group = groupBigTradeVis)
bt_baseChunkFactor     = input.float(1.05, "Chunk Size Factor", minval = 0.3, maxval = 3.0, step = 0.05, group = groupBigTradeVis)
bt_horizontalShiftBars = input.int(0, "Horizontal Shift Bars", minval = -2, maxval = 2, group = groupBigTradeVis)
bt_keepBarsBack        = input.int(450, "Keep Last Labels", minval = 50, maxval = 500, group = groupBigTradeVis)

bt_insideTopPct        = input.float(0.18, "Inside Top Offset %", minval = 0.0, maxval = 0.45, step = 0.01, group = groupBigTradeVis)
bt_insideBotPct        = input.float(0.18, "Inside Bottom Offset %", minval = 0.0, maxval = 0.45, step = 0.01, group = groupBigTradeVis)
bt_stackStepTicks      = input.int(1, "Stack Step Ticks", minval = 0, maxval = 6, group = groupBigTradeVis)
bt_fallbackOffsetTicks = input.int(1, "Fallback Offset Ticks", minval = 0, maxval = 6, group = groupBigTradeVis)

bt_buyPadColor         = input.color(color.rgb(0, 185, 170), "Buy Pad Color", group = groupBigTradeVis)
bt_sellPadColor        = input.color(color.rgb(235, 30, 100), "Sell Pad Color", group = groupBigTradeVis)
bt_buyTextColor        = input.color(color.white, "Buy Text Color", group = groupBigTradeVis)
bt_sellTextColor       = input.color(color.white, "Sell Text Color", group = groupBigTradeVis)
bt_padTransparency     = input.int(40, "Pad Transparency", minval = 0, maxval = 100, group = groupBigTradeVis)

bt_showKFormat         = input.bool(false, "Show K Format", group = groupBigTradeVis)
bt_decimals            = input.int(0, "Decimals", minval = 0, maxval = 2, group = groupBigTradeVis)


// CISD Settings
cisd_showLabels = input.bool(true, "Show Labels", group=groupCISD)
cisd_lineColor = input.color(color.rgb(255, 152, 0), "CISD Line Color", group=groupCISD)
cisd_textColor = input.color(color.rgb(255, 152, 0), "Label Color", group=groupCISD)
cisd_lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group=groupCISD)
cisd_lineStyle = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupCISD)
cisd_lineLength = input.int(15, "Line Extension (bars)", minval=5, maxval=50, group=groupCISD)
cisd_labelSize = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=groupCISD)

//====================================================
// Helpers
//====================================================
f_lineStyle(_style) =>
    _style == "Solid" ? line.style_solid : _style == "Dashed" ? line.style_dashed : line.style_dotted

f_dayTs(_h, _m) =>
    timestamp(macroTimezone, year(time, macroTimezone), month(time, macroTimezone), dayofmonth(time, macroTimezone), _h, _m)

f_midTs(_leftTs, _rightTs) =>
    _leftTs + int(math.floor((_rightTs - _leftTs) / 2))

f_chartMs() =>
    int chartSecRaw = timeframe.in_seconds(timeframe.period)
    int chartSec = na(chartSecRaw) or chartSecRaw <= 0 ? 60 : chartSecRaw
    chartSec * 1000

int chartTfSecForFvg = timeframe.in_seconds(timeframe.period)
int mtfFvgTfSec = timeframe.in_seconds(mtfFvgTf)
bool chartIsMtfFvgTf = not na(chartTfSecForFvg) and not na(mtfFvgTfSec) and chartTfSecForFvg == mtfFvgTfSec


//====================================================
// Global VWAP + volume-weighted standard deviation
//====================================================
anchorTime   = time(anchorTf)
anchorChange = ta.change(anchorTime)
newAnchor    = barstate.isfirst or anchorChange != 0

var float sumPV  = na
var float sumV   = na
var float sumP2V = na

if newAnchor
    sumPV  := src * volume
    sumV   := volume
    sumP2V := src * src * volume
else
    sumPV  += src * volume
    sumV   += volume
    sumP2V += src * src * volume

vwap     = sumV != 0.0 ? sumPV / sumV : na
variance = sumV != 0.0 ? math.max(sumP2V / sumV - vwap * vwap, 0.0) : na
dev      = math.sqrt(variance)
atr14    = ta.atr(14)

upperBand1 = showBand1 and showVWAPModule ? vwap + dev * multBand1 : na
upperBand2 = showBand2 and showVWAPModule ? vwap + dev * multBand2 : na
upperBand3 = showBand3 and showVWAPModule ? vwap + dev * multBand3 : na
lowerBand1 = showBand1 and showVWAPModule ? vwap - dev * multBand1 : na
lowerBand2 = showBand2 and showVWAPModule ? vwap - dev * multBand2 : na
lowerBand3 = showBand3 and showVWAPModule ? vwap - dev * multBand3 : na
plotVWAP   = showVWAPModule ? vwap : na

plotUpper1 = newAnchor ? na : upperBand1
plotUpper2 = newAnchor ? na : upperBand2
plotUpper3 = newAnchor ? na : upperBand3
plotLower1 = newAnchor ? na : lowerBand1
plotLower2 = newAnchor ? na : lowerBand2
plotLower3 = newAnchor ? na : lowerBand3
plotVWAPBr = newAnchor ? na : plotVWAP

//====================================================
// Macro windows
//====================================================
nyHour   = hour(time, macroTimezone)
nyMinute = minute(time, macroTimezone)
nyTotal  = nyHour * 60 + nyMinute

amStartMin = 10 * 60 + 45
amEndMin   = 11 * 60 + 15
pmStartMin = 15 * 60 + 45
pmEndMin   = 16 * 60 + 15

inAM    = nyTotal >= amStartMin and nyTotal < amEndMin
inPM    = nyTotal >= pmStartMin and nyTotal < pmEndMin
inMacro = inAM or inPM

prevInMacro   = barstate.isfirst ? false : inMacro[1]
macroStartBar = inMacro and not prevInMacro
macroEndBar   = not inMacro and prevInMacro

amStartTs = f_dayTs(10, 45)
amEndTs   = f_dayTs(11, 15)
pmStartTs = f_dayTs(15, 45)
pmEndTs   = f_dayTs(16, 15)

currMacroStartTs = inAM ? amStartTs : inPM ? pmStartTs : na
currMacroEndTs   = inAM ? amEndTs   : inPM ? pmEndTs   : na

macroPad = math.max(atr14 * macroOffsetAtr, syminfo.mintick * 10)
dayMs = 24 * 60 * 60 * 1000

var line   activeMacroHighLine = na
var line   activeMacroLowLine  = na
var label  activeMacroLabel    = na
var int    activeMacroStartTs  = na
var int    activeMacroEndTs    = na
var float  activeMacroHigh     = na
var float  activeMacroLow      = na
var line[] macroHighLines      = array.new_line()
var line[] macroLowLines       = array.new_line()
var label[] macroLabels        = array.new_label()
var int[]  macroExpireTs       = array.new_int()

if showMacroModule and macroStartBar
    activeMacroStartTs := currMacroStartTs
    activeMacroEndTs   := currMacroEndTs
    activeMacroHigh    := high
    activeMacroLow     := low

    float macroHighY = activeMacroHigh + macroPad
    float macroLowY  = activeMacroLow - macroPad
    int macroMidTs = f_midTs(activeMacroStartTs, activeMacroEndTs)

    activeMacroHighLine := line.new(x1 = activeMacroStartTs, y1 = macroHighY, x2 = activeMacroEndTs, y2 = macroHighY, xloc = xloc.bar_time, color = macroColor, width = macroLineWidth)
    activeMacroLowLine  := line.new(x1 = activeMacroStartTs, y1 = macroLowY,  x2 = activeMacroEndTs, y2 = macroLowY,  xloc = xloc.bar_time, color = macroColor, width = macroLineWidth)
    line.set_style(activeMacroHighLine, f_lineStyle(macroLineStyleS))
    line.set_style(activeMacroLowLine,  f_lineStyle(macroLineStyleS))

    activeMacroLabel := label.new(x = macroMidTs, y = macroHighY, xloc = xloc.bar_time, text = "MACRO", style = label.style_none, textcolor = macroLabelColor, size = size.tiny)

    array.push(macroHighLines, activeMacroHighLine)
    array.push(macroLowLines, activeMacroLowLine)
    array.push(macroLabels, activeMacroLabel)
    array.push(macroExpireTs, activeMacroEndTs + dayMs)
else if macroStartBar
    activeMacroStartTs := na
    activeMacroEndTs   := na
    activeMacroHigh    := na
    activeMacroLow     := na
    activeMacroHighLine := na
    activeMacroLowLine  := na
    activeMacroLabel    := na

if showMacroModule and inMacro and not na(activeMacroHighLine) and not na(activeMacroLowLine)
    activeMacroHigh := na(activeMacroHigh) ? high : math.max(activeMacroHigh, high)
    activeMacroLow  := na(activeMacroLow)  ? low  : math.min(activeMacroLow, low)
    float macroHighY = activeMacroHigh + macroPad
    float macroLowY  = activeMacroLow - macroPad
    int macroMidTs = f_midTs(activeMacroStartTs, activeMacroEndTs)

    line.set_y1(activeMacroHighLine, macroHighY)
    line.set_y2(activeMacroHighLine, macroHighY)
    line.set_y1(activeMacroLowLine, macroLowY)
    line.set_y2(activeMacroLowLine, macroLowY)
    label.set_x(activeMacroLabel, macroMidTs)
    label.set_y(activeMacroLabel, macroHighY)

if macroEndBar
    activeMacroStartTs := na
    activeMacroEndTs   := na
    activeMacroHigh    := na
    activeMacroLow     := na
    activeMacroHighLine := na
    activeMacroLowLine  := na
    activeMacroLabel    := na

if not showMacroModule and array.size(macroHighLines) > 0
    int macroOffIdx = array.size(macroHighLines) - 1
    while macroOffIdx >= 0
        line.delete(array.get(macroHighLines, macroOffIdx))
        line.delete(array.get(macroLowLines, macroOffIdx))
        label.delete(array.get(macroLabels, macroOffIdx))
        array.remove(macroHighLines, macroOffIdx)
        array.remove(macroLowLines, macroOffIdx)
        array.remove(macroLabels, macroOffIdx)
        array.remove(macroExpireTs, macroOffIdx)
        macroOffIdx -= 1
    activeMacroStartTs := na
    activeMacroEndTs   := na
    activeMacroHigh    := na
    activeMacroLow     := na
    activeMacroHighLine := na
    activeMacroLowLine  := na
    activeMacroLabel    := na

if array.size(macroHighLines) > 0
    int macroIdx = array.size(macroHighLines) - 1
    while macroIdx >= 0
        line mhi = array.get(macroHighLines, macroIdx)
        line mlo = array.get(macroLowLines, macroIdx)
        label ml = array.get(macroLabels, macroIdx)
        int expireTs = array.get(macroExpireTs, macroIdx)
        if time > expireTs
            line.delete(mhi)
            line.delete(mlo)
            label.delete(ml)
            array.remove(macroHighLines, macroIdx)
            array.remove(macroLowLines, macroIdx)
            array.remove(macroLabels, macroIdx)
            array.remove(macroExpireTs, macroIdx)
        macroIdx -= 1

//====================================================
// Plots
//====================================================
pUpper3 = plot(plotUpper3, "Upper Band 3", color = upper3Color, linewidth = band3Width, style = plot.style_linebr)
pUpper2 = plot(plotUpper2, "Upper Band 2", color = upper2Color, linewidth = band2Width, style = plot.style_linebr)
pUpper1 = plot(plotUpper1, "Upper Band 1", color = upper1Color, linewidth = band1Width, style = plot.style_linebr)
pVWAP   = plot(plotVWAPBr, "Global VWAP", color = vwapColor, linewidth = vwapWidth, style = plot.style_linebr)
pLower1 = plot(plotLower1, "Lower Band 1", color = lower1Color, linewidth = band1Width, style = plot.style_linebr)
pLower2 = plot(plotLower2, "Lower Band 2", color = lower2Color, linewidth = band2Width, style = plot.style_linebr)
pLower3 = plot(plotLower3, "Lower Band 3", color = lower3Color, linewidth = band3Width, style = plot.style_linebr)

fill(pUpper2, pUpper1, color = showBand1 and showBand2 and showVWAPModule ? upperFill : na, title = "Upper Fill 1")
fill(pLower1, pLower2, color = showBand1 and showBand2 and showVWAPModule ? lowerFill : na, title = "Lower Fill 1")

//====================================================
// Global VWAP right-side labels
//====================================================
globalRightSideBars = 4
globalRightSideMs = f_chartMs() * globalRightSideBars
f_globalRightLabelX() =>
    time + globalRightSideMs

f_globalSetRightLabel(label _lb, float _y, string _txt, color _txtColor) =>
    label _out = _lb
    if showVWAPModule and not na(_y)
        if na(_out)
            _out := label.new(x = f_globalRightLabelX(), y = _y, xloc = xloc.bar_time, text = _txt, style = label.style_none, textcolor = color.new(_txtColor, 0), size = size.small)
        else
            label.set_x(_out, f_globalRightLabelX())
            label.set_y(_out, _y)
            label.set_text(_out, _txt)
            label.set_textcolor(_out, color.new(_txtColor, 0))
            label.set_textalign(_out, text.align_left)
    else
        if not na(_out)
            label.delete(_out)
        _out := na
    _out

var label lblGlobalVWAP = na
var label lblGlobalU1   = na
var label lblGlobalU2   = na
var label lblGlobalU3   = na
var label lblGlobalL1   = na
var label lblGlobalL2   = na
var label lblGlobalL3   = na

lblGlobalVWAP := f_globalSetRightLabel(lblGlobalVWAP, plotVWAPBr, "GLOBAL VWAP", vwapColor)
lblGlobalU1   := f_globalSetRightLabel(lblGlobalU1, showBand1 ? plotUpper1 : na, "G +1", upper1Color)
lblGlobalU2   := f_globalSetRightLabel(lblGlobalU2, showBand2 ? plotUpper2 : na, "G +2", upper2Color)
lblGlobalU3   := f_globalSetRightLabel(lblGlobalU3, showBand3 ? plotUpper3 : na, "G +3", upper3Color)
lblGlobalL1   := f_globalSetRightLabel(lblGlobalL1, showBand1 ? plotLower1 : na, "G -1", lower1Color)
lblGlobalL2   := f_globalSetRightLabel(lblGlobalL2, showBand2 ? plotLower2 : na, "G -2", lower2Color)
lblGlobalL3   := f_globalSetRightLabel(lblGlobalL3, showBand3 ? plotLower3 : na, "G -3", lower3Color)

//====================================================
// Current TF FVG crossing Global VWAP / Bands
//====================================================
f_currentFvgLineInside(_top, _bot, _line) =>
    float touchPad = syminfo.mintick * 0.5
    not na(_line) and _line <= _top + touchPad and _line >= _bot - touchPad

f_currentFvgSegmentTouches(_top, _bot, _lineA, _lineB) =>
    float touchPad = syminfo.mintick * 0.5
    float segMin = not na(_lineA) and not na(_lineB) ? math.min(_lineA, _lineB) : na
    float segMax = not na(_lineA) and not na(_lineB) ? math.max(_lineA, _lineB) : na
    not na(segMin) and segMax >= _bot - touchPad and segMin <= _top + touchPad

f_currentFvgCandleTouches(_line, _hi, _lo) =>
    float touchPad = syminfo.mintick * 0.5
    not na(_line) and _line <= _hi + touchPad and _line >= _lo - touchPad

f_priceTouchesZone(_hi, _lo, _top, _bot) =>
    float touchPad = syminfo.mintick * 0.5
    _hi >= _bot - touchPad and _lo <= _top + touchPad

f_currentFvgWickTouches(_line0, _line1, _line2) =>
    bool touches = false
    touches := touches or f_currentFvgCandleTouches(_line0, high, low)
    touches

f_currentFvgLineTouches(_top, _bot, _line0, _line1, _line2, _useFvgWicks) =>
    bool touches = false
    touches := _useFvgWicks ? f_currentFvgWickTouches(_line0, _line1, _line2) : false
    touches

f_currentFvgCrossVWAP(_top, _bot, _useFvgWicks) =>
    float upperTouch1_0 = vwap + dev * multBand1
    float upperTouch1_1 = vwap[1] + dev[1] * multBand1
    float upperTouch1_2 = vwap[2] + dev[2] * multBand1
    float upperTouch2_0 = vwap + dev * multBand2
    float upperTouch2_1 = vwap[1] + dev[1] * multBand2
    float upperTouch2_2 = vwap[2] + dev[2] * multBand2
    float upperTouch3_0 = vwap + dev * multBand3
    float upperTouch3_1 = vwap[1] + dev[1] * multBand3
    float upperTouch3_2 = vwap[2] + dev[2] * multBand3
    float lowerTouch1_0 = vwap - dev * multBand1
    float lowerTouch1_1 = vwap[1] - dev[1] * multBand1
    float lowerTouch1_2 = vwap[2] - dev[2] * multBand1
    float lowerTouch2_0 = vwap - dev * multBand2
    float lowerTouch2_1 = vwap[1] - dev[1] * multBand2
    float lowerTouch2_2 = vwap[2] - dev[2] * multBand2
    float lowerTouch3_0 = vwap - dev * multBand3
    float lowerTouch3_1 = vwap[1] - dev[1] * multBand3
    float lowerTouch3_2 = vwap[2] - dev[2] * multBand3
    bool cross = false
    cross := cross or (showVWAPModule and f_currentFvgLineTouches(_top, _bot, vwap, vwap[1], vwap[2], _useFvgWicks))
    cross := cross or (showVWAPModule and showBand1 and f_currentFvgLineTouches(_top, _bot, upperTouch1_0, upperTouch1_1, upperTouch1_2, _useFvgWicks))
    cross := cross or (showVWAPModule and showBand2 and f_currentFvgLineTouches(_top, _bot, upperTouch2_0, upperTouch2_1, upperTouch2_2, _useFvgWicks))
    cross := cross or (showVWAPModule and showBand3 and f_currentFvgLineTouches(_top, _bot, upperTouch3_0, upperTouch3_1, upperTouch3_2, _useFvgWicks))
    cross := cross or (showVWAPModule and showBand1 and f_currentFvgLineTouches(_top, _bot, lowerTouch1_0, lowerTouch1_1, lowerTouch1_2, _useFvgWicks))
    cross := cross or (showVWAPModule and showBand2 and f_currentFvgLineTouches(_top, _bot, lowerTouch2_0, lowerTouch2_1, lowerTouch2_2, _useFvgWicks))
    cross := cross or (showVWAPModule and showBand3 and f_currentFvgLineTouches(_top, _bot, lowerTouch3_0, lowerTouch3_1, lowerTouch3_2, _useFvgWicks))
    cross

f_fvgCreatorTouchesVWAP(_hi, _lo, _vwapValue, _devValue) =>
    float upperTouch1 = _vwapValue + _devValue * multBand1
    float upperTouch2 = _vwapValue + _devValue * multBand2
    float upperTouch3 = _vwapValue + _devValue * multBand3
    float lowerTouch1 = _vwapValue - _devValue * multBand1
    float lowerTouch2 = _vwapValue - _devValue * multBand2
    float lowerTouch3 = _vwapValue - _devValue * multBand3
    bool touches = false
    touches := touches or (showVWAPModule and f_currentFvgCandleTouches(_vwapValue, _hi, _lo))
    touches := touches or (showVWAPModule and showBand1 and f_currentFvgCandleTouches(upperTouch1, _hi, _lo))
    touches := touches or (showVWAPModule and showBand2 and f_currentFvgCandleTouches(upperTouch2, _hi, _lo))
    touches := touches or (showVWAPModule and showBand3 and f_currentFvgCandleTouches(upperTouch3, _hi, _lo))
    touches := touches or (showVWAPModule and showBand1 and f_currentFvgCandleTouches(lowerTouch1, _hi, _lo))
    touches := touches or (showVWAPModule and showBand2 and f_currentFvgCandleTouches(lowerTouch2, _hi, _lo))
    touches := touches or (showVWAPModule and showBand3 and f_currentFvgCandleTouches(lowerTouch3, _hi, _lo))
    touches

f_createCurrentFvgBox(_left, _right, _top, _bot, _isBull, _text) =>
    box newBox = box.new(left = _left, top = _top, right = _right, bottom = _bot, xloc = xloc.bar_index, bgcolor = _isBull ? currentFvgBullFill : currentFvgBearFill, border_color = _isBull ? currentFvgBullBorder : currentFvgBearBorder, border_width = currentFvgBorderWidth)
    box.set_border_style(newBox, f_lineStyle(currentFvgBorderStyle))
    box.set_text(newBox, _text)
    box.set_text_color(newBox, currentFvgTextColor)
    box.set_text_size(newBox, size.tiny)
    box.set_text_halign(newBox, text.align_right)
    box.set_text_valign(newBox, text.align_center)
    newBox

f_createMtfFvgBox(_leftTime, _rightTime, _top, _bot, _isBull) =>
    box newBox = box.new(left = _leftTime, top = _top, right = _rightTime, bottom = _bot, xloc = xloc.bar_time, bgcolor = _isBull ? mtfFvgBullFill : mtfFvgBearFill, border_color = _isBull ? mtfFvgBullBorder : mtfFvgBearBorder, border_width = mtfFvgBorderWidth)
    box.set_border_style(newBox, f_lineStyle(mtfFvgBorderStyle))
    box.set_text(newBox, "FVG 5M VWAP")
    box.set_text_color(newBox, mtfFvgTextColor)
    box.set_text_size(newBox, size.tiny)
    box.set_text_halign(newBox, text.align_right)
    box.set_text_valign(newBox, text.align_center)
    newBox

f_createCurrentBreakerBox(_left, _right, _top, _bot, _isBullFvg) =>
    box newBox = box.new(left = _left, top = _top, right = _right, bottom = _bot, xloc = xloc.bar_index, bgcolor = breakerFill, border_color = breakerBorder, border_width = breakerBorderWidth)
    box.set_border_style(newBox, f_lineStyle(breakerBorderStyle))
    box.set_text(newBox, "Breaker VWAP")
    box.set_text_color(newBox, breakerTextColor)
    box.set_text_size(newBox, size.tiny)
    box.set_text_halign(newBox, text.align_right)
    box.set_text_valign(newBox, text.align_center)
    newBox

f_findCurrentTfBreaker(_isBullFvg) =>
    int foundOffset = na
    float foundTop = na
    float foundBot = na
    for breakerOffset = 2 to 20
        bool isOppositeCandle = _isBullFvg ? close[breakerOffset] < open[breakerOffset] : close[breakerOffset] > open[breakerOffset]
        if na(foundOffset) and isOppositeCandle
            foundOffset := breakerOffset
            foundTop := high[breakerOffset]
            foundBot := low[breakerOffset]
    [foundOffset, foundTop, foundBot]

var box[]   currentFvgBoxes     = array.new_box()
var int[]   currentFvgLeftBars  = array.new_int()
var int[]   currentFvgRightBars = array.new_int()
var float[] currentFvgTops      = array.new_float()
var float[] currentFvgBots      = array.new_float()
var bool[]  currentFvgIsBulls   = array.new_bool()
var box[]   currentBreakerBoxes = array.new_box()

bool currentTfFvgEnabled = showCurrentFVGModule
bool currentBullFVG = currentTfFvgEnabled and bar_index >= 2 and low > high[2]
bool currentBearFVG = currentTfFvgEnabled and bar_index >= 2 and high < low[2]

if currentBullFVG
    float bullFvgTop = low
    float bullFvgBot = high[2]
    int bullFvgLeft = bar_index - 2
    int bullFvgRight = bar_index + currentFvgLengthBars
    if f_fvgCreatorTouchesVWAP(high[1], low[1], vwap[1], dev[1])
        box bullFvgBox = f_createCurrentFvgBox(bullFvgLeft, bullFvgRight, bullFvgTop, bullFvgBot, true, "FVG VWAP")
        [bullBreakerOffset, bullBreakerTop, bullBreakerBot] = f_findCurrentTfBreaker(true)
        int bullBreakerLeft = not na(bullBreakerOffset) ? bar_index - bullBreakerOffset : na
        box bullBreakerBox = not chartIsMtfFvgTf and not na(bullBreakerLeft) ? f_createCurrentBreakerBox(bullBreakerLeft, bullFvgRight, bullBreakerTop, bullBreakerBot, true) : na
        array.push(currentFvgBoxes, bullFvgBox)
        array.push(currentBreakerBoxes, bullBreakerBox)
        array.push(currentFvgLeftBars, bullFvgLeft)
        array.push(currentFvgRightBars, bullFvgRight)
        array.push(currentFvgTops, bullFvgTop)
        array.push(currentFvgBots, bullFvgBot)
        array.push(currentFvgIsBulls, true)

if currentBearFVG
    float bearFvgTop = low[2]
    float bearFvgBot = high
    int bearFvgLeft = bar_index - 2
    int bearFvgRight = bar_index + currentFvgLengthBars
    if f_fvgCreatorTouchesVWAP(high[1], low[1], vwap[1], dev[1])
        box bearFvgBox = f_createCurrentFvgBox(bearFvgLeft, bearFvgRight, bearFvgTop, bearFvgBot, false, "FVG VWAP")
        [bearBreakerOffset, bearBreakerTop, bearBreakerBot] = f_findCurrentTfBreaker(false)
        int bearBreakerLeft = not na(bearBreakerOffset) ? bar_index - bearBreakerOffset : na
        box bearBreakerBox = not chartIsMtfFvgTf and not na(bearBreakerLeft) ? f_createCurrentBreakerBox(bearBreakerLeft, bearFvgRight, bearBreakerTop, bearBreakerBot, false) : na
        array.push(currentFvgBoxes, bearFvgBox)
        array.push(currentBreakerBoxes, bearBreakerBox)
        array.push(currentFvgLeftBars, bearFvgLeft)
        array.push(currentFvgRightBars, bearFvgRight)
        array.push(currentFvgTops, bearFvgTop)
        array.push(currentFvgBots, bearFvgBot)
        array.push(currentFvgIsBulls, false)

if not currentTfFvgEnabled and array.size(currentFvgBoxes) > 0
    int fvgOffIdx = array.size(currentFvgBoxes) - 1
    while fvgOffIdx >= 0
        box offBox = array.get(currentFvgBoxes, fvgOffIdx)
        box offBreakerBox = array.get(currentBreakerBoxes, fvgOffIdx)
        if not na(offBox)
            box.delete(offBox)
        if not na(offBreakerBox)
            box.delete(offBreakerBox)
        array.remove(currentFvgBoxes, fvgOffIdx)
        array.remove(currentBreakerBoxes, fvgOffIdx)
        array.remove(currentFvgLeftBars, fvgOffIdx)
        array.remove(currentFvgRightBars, fvgOffIdx)
        array.remove(currentFvgTops, fvgOffIdx)
        array.remove(currentFvgBots, fvgOffIdx)
        array.remove(currentFvgIsBulls, fvgOffIdx)
        fvgOffIdx -= 1

if currentTfFvgEnabled and array.size(currentFvgBoxes) > 0
    int fvgIdx = array.size(currentFvgBoxes) - 1
    while fvgIdx >= 0
        box storedFvgBox = array.get(currentFvgBoxes, fvgIdx)
        box storedBreakerBox = array.get(currentBreakerBoxes, fvgIdx)
        int fvgLeftBar = array.get(currentFvgLeftBars, fvgIdx)
        int fvgRightBar = array.get(currentFvgRightBars, fvgIdx)
        float fvgTop = array.get(currentFvgTops, fvgIdx)
        float fvgBot = array.get(currentFvgBots, fvgIdx)
        bool fvgIsBull = array.get(currentFvgIsBulls, fvgIdx)
        int fvgNewRightBar = bar_index + currentFvgLengthBars
        bool fvgOverflow = array.size(currentFvgBoxes) > 190
        bool fvgBalanced = fvgIsBull ? low <= fvgBot : high >= fvgTop
        if fvgBalanced or fvgOverflow
            if not na(storedFvgBox)
                box.delete(storedFvgBox)
            if not na(storedBreakerBox)
                box.delete(storedBreakerBox)
            array.remove(currentFvgBoxes, fvgIdx)
            array.remove(currentBreakerBoxes, fvgIdx)
            array.remove(currentFvgLeftBars, fvgIdx)
            array.remove(currentFvgRightBars, fvgIdx)
            array.remove(currentFvgTops, fvgIdx)
            array.remove(currentFvgBots, fvgIdx)
            array.remove(currentFvgIsBulls, fvgIdx)
        else
            if not na(storedFvgBox)
                box.set_right(storedFvgBox, fvgNewRightBar)
            if not na(storedBreakerBox)
                box.set_right(storedBreakerBox, fvgNewRightBar)
            array.set(currentFvgRightBars, fvgIdx, fvgNewRightBar)
        fvgIdx -= 1


//====================================================
// NFT 5 minutes FVG crossing Global VWAP / Bands
//====================================================
[mtfFvgTime, mtfFvgLeftTime, mtfBullOk, mtfBullTop, mtfBullBot, mtfBearOk, mtfBearTop, mtfBearBot] = request.security(syminfo.tickerid, mtfFvgTf, [time, time[2], bar_index >= 2 and low > high[2] and f_fvgCreatorTouchesVWAP(high[1], low[1], vwap[1], dev[1]), low, high[2], bar_index >= 2 and high < low[2] and f_fvgCreatorTouchesVWAP(high[1], low[1], vwap[1], dev[1]), low[2], high], lookahead = barmerge.lookahead_off)

bool mtfFvgNewClosedBar = not na(mtfFvgTime) and not na(mtfFvgLeftTime) and ta.change(mtfFvgTime) != 0
bool showMtfFvgOnChart = showMTFFVGModule and not chartIsMtfFvgTf

var box[]   mtfFvgBoxes    = array.new_box()
var int[]   mtfFvgExpireTs = array.new_int()
var float[] mtfFvgTops     = array.new_float()
var float[] mtfFvgBots     = array.new_float()
var bool[]  mtfFvgIsBulls  = array.new_bool()

if showMtfFvgOnChart and mtfFvgNewClosedBar and mtfBullOk
    int mtfBullRightTime = time + f_chartMs() * mtfFvgLengthBars
    box mtfBullBox = f_createMtfFvgBox(mtfFvgLeftTime, mtfBullRightTime, mtfBullTop, mtfBullBot, true)
    array.push(mtfFvgBoxes, mtfBullBox)
    array.push(mtfFvgExpireTs, mtfBullRightTime)
    array.push(mtfFvgTops, mtfBullTop)
    array.push(mtfFvgBots, mtfBullBot)
    array.push(mtfFvgIsBulls, true)

if showMtfFvgOnChart and mtfFvgNewClosedBar and mtfBearOk
    int mtfBearRightTime = time + f_chartMs() * mtfFvgLengthBars
    box mtfBearBox = f_createMtfFvgBox(mtfFvgLeftTime, mtfBearRightTime, mtfBearTop, mtfBearBot, false)
    array.push(mtfFvgBoxes, mtfBearBox)
    array.push(mtfFvgExpireTs, mtfBearRightTime)
    array.push(mtfFvgTops, mtfBearTop)
    array.push(mtfFvgBots, mtfBearBot)
    array.push(mtfFvgIsBulls, false)

if not showMtfFvgOnChart and array.size(mtfFvgBoxes) > 0
    int mtfOffIdx = array.size(mtfFvgBoxes) - 1
    while mtfOffIdx >= 0
        box mtfOffBox = array.get(mtfFvgBoxes, mtfOffIdx)
        if not na(mtfOffBox)
            box.delete(mtfOffBox)
        array.remove(mtfFvgBoxes, mtfOffIdx)
        array.remove(mtfFvgExpireTs, mtfOffIdx)
        array.remove(mtfFvgTops, mtfOffIdx)
        array.remove(mtfFvgBots, mtfOffIdx)
        array.remove(mtfFvgIsBulls, mtfOffIdx)
        mtfOffIdx -= 1

if showMtfFvgOnChart and array.size(mtfFvgBoxes) > 0
    int mtfIdx = array.size(mtfFvgBoxes) - 1
    while mtfIdx >= 0
        box mtfStoredBox = array.get(mtfFvgBoxes, mtfIdx)
        int mtfExpireTs = array.get(mtfFvgExpireTs, mtfIdx)
        float mtfTop = array.get(mtfFvgTops, mtfIdx)
        float mtfBot = array.get(mtfFvgBots, mtfIdx)
        bool mtfIsBull = array.get(mtfFvgIsBulls, mtfIdx)
        int mtfNewRightTime = time + f_chartMs() * mtfFvgLengthBars
        bool mtfOverflow = array.size(mtfFvgBoxes) > 240
        bool mtfBalanced = mtfIsBull ? low <= mtfBot : high >= mtfTop
        if mtfBalanced or mtfOverflow
            if not na(mtfStoredBox)
                box.delete(mtfStoredBox)
            array.remove(mtfFvgBoxes, mtfIdx)
            array.remove(mtfFvgExpireTs, mtfIdx)
            array.remove(mtfFvgTops, mtfIdx)
            array.remove(mtfFvgBots, mtfIdx)
            array.remove(mtfFvgIsBulls, mtfIdx)
        else
            if not na(mtfStoredBox)
                box.set_right(mtfStoredBox, mtfNewRightTime)
            array.set(mtfFvgExpireTs, mtfIdx, mtfNewRightTime)
        mtfIdx -= 1


//====================================================
// Macro FVG + Breaker + NFT 5 minutes Macro FVG
//====================================================
f_createMacroBreakerBox(_left, _right, _top, _bot) =>
    box newBox = box.new(left = _left, top = _top, right = _right, bottom = _bot, xloc = xloc.bar_index, bgcolor = breakerFill, border_color = breakerBorder, border_width = breakerBorderWidth)
    box.set_border_style(newBox, f_lineStyle(breakerBorderStyle))
    box.set_text(newBox, "Breaker Macro")
    box.set_text_color(newBox, breakerTextColor)
    box.set_text_size(newBox, size.tiny)
    box.set_text_halign(newBox, text.align_right)
    box.set_text_valign(newBox, text.align_center)
    newBox

f_createMacroMtfFvgBox(_leftTime, _rightTime, _top, _bot, _isBull) =>
    box newBox = box.new(left = _leftTime, top = _top, right = _rightTime, bottom = _bot, xloc = xloc.bar_time, bgcolor = _isBull ? mtfFvgBullFill : mtfFvgBearFill, border_color = _isBull ? mtfFvgBullBorder : mtfFvgBearBorder, border_width = mtfFvgBorderWidth)
    box.set_border_style(newBox, f_lineStyle(mtfFvgBorderStyle))
    box.set_text(newBox, "FVG 5M Macro")
    box.set_text_color(newBox, mtfFvgTextColor)
    box.set_text_size(newBox, size.tiny)
    box.set_text_halign(newBox, text.align_right)
    box.set_text_valign(newBox, text.align_center)
    newBox

f_createMacroEntryLabel(_isBullSetup) =>
    float entryY = high + macroPad
    label newLabel = label.new(x = bar_index, y = entryY, xloc = xloc.bar_index, text = "ENTRY", style = _isBullSetup ? label.style_arrowup : label.style_arrowdown, textcolor = color.white, color = color.new(color.green, 0), size = size.tiny)
    newLabel

f_findMacroTfBreaker(_isBullFvg, _macroStartBar) =>
    int foundOffset = na
    float foundTop = na
    float foundBot = na
    for breakerOffset = 2 to 20
        bool breakerInsideMacro = not na(_macroStartBar) and bar_index - breakerOffset >= _macroStartBar
        bool isOppositeCandle = _isBullFvg ? close[breakerOffset] < open[breakerOffset] : close[breakerOffset] > open[breakerOffset]
        if na(foundOffset) and breakerInsideMacro and isOppositeCandle
            foundOffset := breakerOffset
            foundTop := high[breakerOffset]
            foundBot := low[breakerOffset]
    [foundOffset, foundTop, foundBot]

var box[]   macroFvgBoxes       = array.new_box()
var int[]   macroFvgLeftBars    = array.new_int()
var int[]   macroFvgRightBars   = array.new_int()
var float[] macroFvgTops        = array.new_float()
var float[] macroFvgBots        = array.new_float()
var bool[]  macroFvgIsBulls     = array.new_bool()
var bool[]  macroFvgFrozen      = array.new_bool()
var box[]   macroBreakerBoxes   = array.new_box()
var bool    macroCurrentFvgFound = false
var bool    macroMtfFvgFound     = false
var bool    macroSetupReady      = false
var bool    macroSetupCompleted  = false
var int     macroSetupReadyBar   = na
var int     macroCurrentStartBar = na
var label[] macroEntryLabels     = array.new_label()

if macroStartBar
    macroCurrentFvgFound := false
    macroMtfFvgFound     := false
    macroSetupReady      := false
    macroSetupCompleted  := false
    macroSetupReadyBar   := na
    macroCurrentStartBar := bar_index

if macroEndBar
    macroCurrentStartBar := na

bool macroCurrentTfEnabled = showMacroModule and showMacroFVGModule and not chartIsMtfFvgTf
bool macroCurrentTfReady = macroCurrentTfEnabled and inMacro and inMacro[1] and inMacro[2] and not macroCurrentFvgFound and not na(macroCurrentStartBar) and bar_index >= macroCurrentStartBar + 2
bool macroBullFVG = macroCurrentTfReady and low > high[2]
bool macroBearFVG = macroCurrentTfReady and high < low[2]

if macroBullFVG
    float macroBullFvgTop = low
    float macroBullFvgBot = high[2]
    int macroBullFvgLeft = bar_index - 2
    int macroBullFvgRight = bar_index + currentFvgLengthBars
    [macroBullBreakerOffset, macroBullBreakerTop, macroBullBreakerBot] = f_findMacroTfBreaker(true, macroCurrentStartBar)
    int macroBullBreakerLeft = not na(macroBullBreakerOffset) ? bar_index - macroBullBreakerOffset : na
    if not na(macroBullBreakerLeft)
        box macroBullFvgBox = f_createCurrentFvgBox(macroBullFvgLeft, macroBullFvgRight, macroBullFvgTop, macroBullFvgBot, true, "FVG Macro")
        box macroBullBreakerBox = f_createMacroBreakerBox(macroBullBreakerLeft, macroBullFvgRight, macroBullBreakerTop, macroBullBreakerBot)
        array.push(macroFvgBoxes, macroBullFvgBox)
        array.push(macroBreakerBoxes, macroBullBreakerBox)
        array.push(macroFvgFrozen, false)
        array.push(macroFvgLeftBars, macroBullFvgLeft)
        array.push(macroFvgRightBars, macroBullFvgRight)
        array.push(macroFvgTops, macroBullFvgTop)
        array.push(macroFvgBots, macroBullFvgBot)
        array.push(macroFvgIsBulls, true)
        macroCurrentFvgFound := true
        if macroMtfFvgFound and not macroSetupReady
            macroSetupReady := true
            macroSetupReadyBar := bar_index

if macroBearFVG
    float macroBearFvgTop = low[2]
    float macroBearFvgBot = high
    int macroBearFvgLeft = bar_index - 2
    int macroBearFvgRight = bar_index + currentFvgLengthBars
    [macroBearBreakerOffset, macroBearBreakerTop, macroBearBreakerBot] = f_findMacroTfBreaker(false, macroCurrentStartBar)
    int macroBearBreakerLeft = not na(macroBearBreakerOffset) ? bar_index - macroBearBreakerOffset : na
    if not na(macroBearBreakerLeft)
        box macroBearFvgBox = f_createCurrentFvgBox(macroBearFvgLeft, macroBearFvgRight, macroBearFvgTop, macroBearFvgBot, false, "FVG Macro")
        box macroBearBreakerBox = f_createMacroBreakerBox(macroBearBreakerLeft, macroBearFvgRight, macroBearBreakerTop, macroBearBreakerBot)
        array.push(macroFvgBoxes, macroBearFvgBox)
        array.push(macroBreakerBoxes, macroBearBreakerBox)
        array.push(macroFvgFrozen, false)
        array.push(macroFvgLeftBars, macroBearFvgLeft)
        array.push(macroFvgRightBars, macroBearFvgRight)
        array.push(macroFvgTops, macroBearFvgTop)
        array.push(macroFvgBots, macroBearFvgBot)
        array.push(macroFvgIsBulls, false)
        macroCurrentFvgFound := true
        if macroMtfFvgFound and not macroSetupReady
            macroSetupReady := true
            macroSetupReadyBar := bar_index

if not macroCurrentTfEnabled and array.size(macroFvgBoxes) > 0
    int macroOffIdx = array.size(macroFvgBoxes) - 1
    while macroOffIdx >= 0
        box macroOffBox = array.get(macroFvgBoxes, macroOffIdx)
        box macroOffBreakerBox = array.get(macroBreakerBoxes, macroOffIdx)
        if not na(macroOffBox)
            box.delete(macroOffBox)
        if not na(macroOffBreakerBox)
            box.delete(macroOffBreakerBox)
        array.remove(macroFvgBoxes, macroOffIdx)
        array.remove(macroBreakerBoxes, macroOffIdx)
        array.remove(macroFvgFrozen, macroOffIdx)
        array.remove(macroFvgLeftBars, macroOffIdx)
        array.remove(macroFvgRightBars, macroOffIdx)
        array.remove(macroFvgTops, macroOffIdx)
        array.remove(macroFvgBots, macroOffIdx)
        array.remove(macroFvgIsBulls, macroOffIdx)
        macroOffIdx -= 1

if macroCurrentTfEnabled and array.size(macroFvgBoxes) > 0
    int macroIdx = array.size(macroFvgBoxes) - 1
    while macroIdx >= 0
        box macroStoredFvgBox = array.get(macroFvgBoxes, macroIdx)
        box macroStoredBreakerBox = array.get(macroBreakerBoxes, macroIdx)
        bool macroIsFrozen = array.get(macroFvgFrozen, macroIdx)
        int macroNewRightBar = bar_index + currentFvgLengthBars
        bool macroFvgOverflow = array.size(macroFvgBoxes) > 190
        if macroFvgOverflow
            if not na(macroStoredFvgBox)
                box.delete(macroStoredFvgBox)
            if not na(macroStoredBreakerBox)
                box.delete(macroStoredBreakerBox)
            array.remove(macroFvgBoxes, macroIdx)
            array.remove(macroBreakerBoxes, macroIdx)
            array.remove(macroFvgFrozen, macroIdx)
            array.remove(macroFvgLeftBars, macroIdx)
            array.remove(macroFvgRightBars, macroIdx)
            array.remove(macroFvgTops, macroIdx)
            array.remove(macroFvgBots, macroIdx)
            array.remove(macroFvgIsBulls, macroIdx)
        else if not macroIsFrozen
            if not na(macroStoredFvgBox)
                box.set_right(macroStoredFvgBox, macroNewRightBar)
            if not na(macroStoredBreakerBox)
                box.set_right(macroStoredBreakerBox, macroNewRightBar)
            array.set(macroFvgRightBars, macroIdx, macroNewRightBar)
        macroIdx -= 1

[macroMtfFvgTime, macroMtfFvgLeftTime, macroMtfBullOk, macroMtfBullTop, macroMtfBullBot, macroMtfBearOk, macroMtfBearTop, macroMtfBearBot] = request.security(syminfo.tickerid, mtfFvgTf, [time, time[2], inMacro and inMacro[1] and inMacro[2] and bar_index >= 2 and low > high[2], low, high[2], inMacro and inMacro[1] and inMacro[2] and bar_index >= 2 and high < low[2], low[2], high], lookahead = barmerge.lookahead_off)

bool macroMtfFvgNewClosedBar = not na(macroMtfFvgTime) and not na(macroMtfFvgLeftTime) and ta.change(macroMtfFvgTime) != 0
bool showMacroMtfFvgOnChart = showMacroModule and showMacroMTFFVGModule and not chartIsMtfFvgTf

var box[]   macroMtfFvgBoxes    = array.new_box()
var int[]   macroMtfFvgExpireTs = array.new_int()
var float[] macroMtfFvgTops     = array.new_float()
var float[] macroMtfFvgBots     = array.new_float()
var bool[]  macroMtfFvgIsBulls  = array.new_bool()
var bool[]  macroMtfFvgFrozen   = array.new_bool()

if showMacroMtfFvgOnChart and not macroMtfFvgFound and macroMtfFvgNewClosedBar and macroMtfBullOk
    int macroMtfBullRightTime = time + f_chartMs() * mtfFvgLengthBars
    box macroMtfBullBox = f_createMacroMtfFvgBox(macroMtfFvgLeftTime, macroMtfBullRightTime, macroMtfBullTop, macroMtfBullBot, true)
    array.push(macroMtfFvgBoxes, macroMtfBullBox)
    array.push(macroMtfFvgExpireTs, macroMtfBullRightTime)
    array.push(macroMtfFvgFrozen, false)
    array.push(macroMtfFvgTops, macroMtfBullTop)
    array.push(macroMtfFvgBots, macroMtfBullBot)
    array.push(macroMtfFvgIsBulls, true)
    macroMtfFvgFound := true
    if macroCurrentFvgFound and not macroSetupReady
        macroSetupReady := true
        macroSetupReadyBar := bar_index

if showMacroMtfFvgOnChart and not macroMtfFvgFound and macroMtfFvgNewClosedBar and macroMtfBearOk
    int macroMtfBearRightTime = time + f_chartMs() * mtfFvgLengthBars
    box macroMtfBearBox = f_createMacroMtfFvgBox(macroMtfFvgLeftTime, macroMtfBearRightTime, macroMtfBearTop, macroMtfBearBot, false)
    array.push(macroMtfFvgBoxes, macroMtfBearBox)
    array.push(macroMtfFvgExpireTs, macroMtfBearRightTime)
    array.push(macroMtfFvgFrozen, false)
    array.push(macroMtfFvgTops, macroMtfBearTop)
    array.push(macroMtfFvgBots, macroMtfBearBot)
    array.push(macroMtfFvgIsBulls, false)
    macroMtfFvgFound := true
    if macroCurrentFvgFound and not macroSetupReady
        macroSetupReady := true
        macroSetupReadyBar := bar_index

if not showMacroMtfFvgOnChart and array.size(macroMtfFvgBoxes) > 0
    int macroMtfOffIdx = array.size(macroMtfFvgBoxes) - 1
    while macroMtfOffIdx >= 0
        box macroMtfOffBox = array.get(macroMtfFvgBoxes, macroMtfOffIdx)
        if not na(macroMtfOffBox)
            box.delete(macroMtfOffBox)
        array.remove(macroMtfFvgBoxes, macroMtfOffIdx)
        array.remove(macroMtfFvgExpireTs, macroMtfOffIdx)
        array.remove(macroMtfFvgFrozen, macroMtfOffIdx)
        array.remove(macroMtfFvgTops, macroMtfOffIdx)
        array.remove(macroMtfFvgBots, macroMtfOffIdx)
        array.remove(macroMtfFvgIsBulls, macroMtfOffIdx)
        macroMtfOffIdx -= 1

if showMacroMtfFvgOnChart and array.size(macroMtfFvgBoxes) > 0
    int macroMtfIdx = array.size(macroMtfFvgBoxes) - 1
    while macroMtfIdx >= 0
        box macroMtfStoredBox = array.get(macroMtfFvgBoxes, macroMtfIdx)
        bool macroMtfIsFrozen = array.get(macroMtfFvgFrozen, macroMtfIdx)
        int macroMtfNewRightTime = time + f_chartMs() * mtfFvgLengthBars
        bool macroMtfOverflow = array.size(macroMtfFvgBoxes) > 240
        if macroMtfOverflow
            if not na(macroMtfStoredBox)
                box.delete(macroMtfStoredBox)
            array.remove(macroMtfFvgBoxes, macroMtfIdx)
            array.remove(macroMtfFvgExpireTs, macroMtfIdx)
            array.remove(macroMtfFvgFrozen, macroMtfIdx)
            array.remove(macroMtfFvgTops, macroMtfIdx)
            array.remove(macroMtfFvgBots, macroMtfIdx)
            array.remove(macroMtfFvgIsBulls, macroMtfIdx)
        else if not macroMtfIsFrozen
            if not na(macroMtfStoredBox)
                box.set_right(macroMtfStoredBox, macroMtfNewRightTime)
            array.set(macroMtfFvgExpireTs, macroMtfIdx, macroMtfNewRightTime)
        macroMtfIdx -= 1

if showMacroModule and showMacroFVGModule and showMacroMTFFVGModule and macroSetupReady and not macroSetupCompleted and array.size(macroFvgBoxes) > 0 and array.size(macroMtfFvgBoxes) > 0
    int activeMacroIdx = array.size(macroFvgBoxes) - 1
    int activeMacroMtfIdx = array.size(macroMtfFvgBoxes) - 1
    float activeMacroTop = array.get(macroFvgTops, activeMacroIdx)
    float activeMacroBot = array.get(macroFvgBots, activeMacroIdx)
    bool activeMacroBull = array.get(macroFvgIsBulls, activeMacroIdx)
    float activeMacroMtfTop = array.get(macroMtfFvgTops, activeMacroMtfIdx)
    float activeMacroMtfBot = array.get(macroMtfFvgBots, activeMacroMtfIdx)
    bool touchMacroCurrent = f_priceTouchesZone(high, low, activeMacroTop, activeMacroBot)
    bool touchMacroMtf = f_priceTouchesZone(high, low, activeMacroMtfTop, activeMacroMtfBot)
    if touchMacroCurrent or touchMacroMtf
        box activeMacroBox = array.get(macroFvgBoxes, activeMacroIdx)
        box activeMacroBreakerBox = array.get(macroBreakerBoxes, activeMacroIdx)
        box activeMacroMtfBox = array.get(macroMtfFvgBoxes, activeMacroMtfIdx)
        if not na(activeMacroBox)
            box.set_right(activeMacroBox, bar_index)
        if not na(activeMacroBreakerBox)
            box.set_right(activeMacroBreakerBox, bar_index)
        if not na(activeMacroMtfBox)
            box.set_right(activeMacroMtfBox, time)
        array.set(macroFvgRightBars, activeMacroIdx, bar_index)
        array.set(macroMtfFvgExpireTs, activeMacroMtfIdx, time)
        array.set(macroFvgFrozen, activeMacroIdx, true)
        array.set(macroMtfFvgFrozen, activeMacroMtfIdx, true)
        label macroEntryLabel = f_createMacroEntryLabel(activeMacroBull)
        array.push(macroEntryLabels, macroEntryLabel)
        macroSetupCompleted := true


// ======================================================================
// Minervini Current TF SR + Trend
// ======================================================================
minq_groupMain           = "Minervini / Главни чекове"
minq_showPatternMaster   = input.bool(true,  "Патърни", group=minq_groupMain)
minq_showSRMaster        = input.bool(true,  "Support / Resistance", group=minq_groupMain)

minq_groupPattern        = "Minervini / Патърни / Auto Pivot"
minq_tfForLines          = input.timeframe("5", "Таймфрейм за линии", group=minq_groupPattern)
minq_showUpperTrendLine  = input.bool(true,  "Показвай горна trend line", group=minq_groupPattern)
minq_showLowerTrendLine  = input.bool(true,  "Показвай долна trend line", group=minq_groupPattern)
minq_showSupportLine     = input.bool(true,  "Показвай support", group=minq_groupPattern)
minq_showResistanceLine  = input.bool(true,  "Показвай resistance", group=minq_groupPattern)
minq_trendLinePivotSel   = input.int(4, "Pivot за Trend Lines", options=[3, 4, 5, 6], group=minq_groupPattern)
minq_srPivotSel          = input.int(5, "Pivot за Support / Resistance", options=[3, 4, 5, 6], group=minq_groupPattern)
minq_showMinorLines      = input.bool(false, "Показвай и по-малките линии", group=minq_groupPattern)
minq_extendBars          = input.int(25, "Удължи НАЗАД (барове)", minval=0, group=minq_groupPattern)

minq_groupTrendStyle     = "Minervini / Trend Lines — стил"
minq_upperTlColor        = input.color(color.new(color.rgb(70, 160, 80), 0), "Горна trend line цвят", group=minq_groupTrendStyle)
minq_upperTlStyleInp     = input.string("Solid", "Горна trend line стил", options=["Solid", "Dashed", "Dotted"], group=minq_groupTrendStyle)
minq_upperTlWidth        = input.int(1, "Горна trend line дебелина", minval=1, maxval=4, group=minq_groupTrendStyle)
minq_lowerTlColor        = input.color(color.new(color.rgb(225, 145, 145), 0), "Долна trend line цвят", group=minq_groupTrendStyle)
minq_lowerTlStyleInp     = input.string("Solid", "Долна trend line стил", options=["Solid", "Dashed", "Dotted"], group=minq_groupTrendStyle)
minq_lowerTlWidth        = input.int(1, "Долна trend line дебелина", minval=1, maxval=4, group=minq_groupTrendStyle)

minq_groupSRStyle        = "Minervini / Support / Resistance — стил"
minq_supportColor        = input.color(color.new(color.rgb(80, 215, 205), 0), "Support цвят", group=minq_groupSRStyle)
minq_supportStyleInp     = input.string("Solid", "Support стил", options=["Solid", "Dashed", "Dotted"], group=minq_groupSRStyle)
minq_supportWidth        = input.int(1, "Support дебелина", minval=1, maxval=4, group=minq_groupSRStyle)
minq_resistanceColor     = input.color(color.new(color.rgb(245, 205, 215), 0), "Resistance цвят", group=minq_groupSRStyle)
minq_resistanceStyleInp  = input.string("Solid", "Resistance стил", options=["Solid", "Dashed", "Dotted"], group=minq_groupSRStyle)
minq_resistanceWidth     = input.int(1, "Resistance дебелина", minval=1, maxval=4, group=minq_groupSRStyle)

minq_groupBarStyle       = "Minervini / Цветове на лентите"
minq_useBarColors        = input.bool(true, "Оцветявай лентите", group=minq_groupBarStyle)
minq_bullBarColor        = input.color(color.rgb(62, 211, 255), "Bull лента цвят", group=minq_groupBarStyle)
minq_bearBarColor        = input.color(color.rgb(214, 218, 224), "Bear лента цвят", group=minq_groupBarStyle)

minq_upperTrendLineOn = showMinqTrendLinesModule and minq_showPatternMaster and minq_showUpperTrendLine
minq_lowerTrendLineOn = showMinqTrendLinesModule and minq_showPatternMaster and minq_showLowerTrendLine
minq_supportLineOn    = showMinqSRModule and minq_showSRMaster and minq_showSupportLine
minq_resistanceLineOn = showMinqSRModule and minq_showSRMaster and minq_showResistanceLine

minq_f_line_style(string styleInp) =>
    switch styleInp
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

minq_f_y_at(int x1, float y1, int x2, float y2, int x) =>
    float slope = (x2 != x1) ? (y2 - y1) / (x2 - x1) : 0.0
    y1 + slope * (x - x1)

minq_f_tf_text(string tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "10"  => "10m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => tf

minq_f_line_tag(string kind, string tf) =>
    kind + " " + tf

minq_f_get_tf_pivots(int pLen) =>
    _ph = ta.pivothigh(high, pLen, pLen)
    _pl = ta.pivotlow(math.min(open, close), pLen, pLen)

    var int _ph1t = na
    var float _ph1p = na
    var int _ph2t = na
    var float _ph2p = na
    var int _pl1t = na
    var float _pl1p = na
    var int _pl2t = na
    var float _pl2p = na

    if not na(_ph)
        _ph2t := _ph1t
        _ph2p := _ph1p
        _ph1t := time[pLen]
        _ph1p := _ph

    if not na(_pl)
        _pl2t := _pl1t
        _pl2p := _pl1p
        _pl1t := time[pLen]
        _pl1p := _pl

    [_ph1t, _ph1p, _ph2t, _ph2p, _pl1t, _pl1p, _pl2t, _pl2p]

minq_rightBars = 8

minq_tfSecRaw = timeframe.in_seconds(minq_tfForLines)
minq_tfSec    = na(minq_tfSecRaw) ? 300 : int(math.max(minq_tfSecRaw, 1))
minq_tfMs     = minq_tfSec * 1000
minq_rightMs  = minq_tfMs * minq_rightBars
minq_extendMs = minq_tfMs * minq_extendBars

minq_upperStyle      = minq_f_line_style(minq_upperTlStyleInp)
minq_lowerStyle      = minq_f_line_style(minq_lowerTlStyleInp)
minq_supportStyle    = minq_f_line_style(minq_supportStyleInp)
minq_resistanceStyle = minq_f_line_style(minq_resistanceStyleInp)

minq_srcTfText = minq_f_tf_text(minq_tfForLines)

[minq_ph1t3, minq_ph1p3, minq_ph2t3, minq_ph2p3, minq_pl1t3, minq_pl1p3, minq_pl2t3, minq_pl2p3] = request.security(
     syminfo.tickerid,
     minq_tfForLines,
     minq_f_get_tf_pivots(3),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

[minq_ph1t4, minq_ph1p4, minq_ph2t4, minq_ph2p4, minq_pl1t4, minq_pl1p4, minq_pl2t4, minq_pl2p4] = request.security(
     syminfo.tickerid,
     minq_tfForLines,
     minq_f_get_tf_pivots(4),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

[minq_ph1t5, minq_ph1p5, minq_ph2t5, minq_ph2p5, minq_pl1t5, minq_pl1p5, minq_pl2t5, minq_pl2p5] = request.security(
     syminfo.tickerid,
     minq_tfForLines,
     minq_f_get_tf_pivots(5),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

[minq_ph1t6, minq_ph1p6, minq_ph2t6, minq_ph2p6, minq_pl1t6, minq_pl1p6, minq_pl2t6, minq_pl2p6] = request.security(
     syminfo.tickerid,
     minq_tfForLines,
     minq_f_get_tf_pivots(6),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

minq_hasUpper3 = not na(minq_ph1t3) and not na(minq_ph2t3)
minq_hasUpper4 = not na(minq_ph1t4) and not na(minq_ph2t4)
minq_hasUpper5 = not na(minq_ph1t5) and not na(minq_ph2t5)
minq_hasUpper6 = not na(minq_ph1t6) and not na(minq_ph2t6)

minq_hasLower3 = not na(minq_pl1t3) and not na(minq_pl2t3)
minq_hasLower4 = not na(minq_pl1t4) and not na(minq_pl2t4)
minq_hasLower5 = not na(minq_pl1t5) and not na(minq_pl2t5)
minq_hasLower6 = not na(minq_pl1t6) and not na(minq_pl2t6)

minq_hasSup3 = not na(minq_pl1t3) and not na(minq_pl1p3)
minq_hasSup4 = not na(minq_pl1t4) and not na(minq_pl1p4)
minq_hasSup5 = not na(minq_pl1t5) and not na(minq_pl1p5)
minq_hasSup6 = not na(minq_pl1t6) and not na(minq_pl1p6)

minq_hasRes3 = not na(minq_ph1t3) and not na(minq_ph1p3)
minq_hasRes4 = not na(minq_ph1t4) and not na(minq_ph1p4)
minq_hasRes5 = not na(minq_ph1t5) and not na(minq_ph1p5)
minq_hasRes6 = not na(minq_ph1t6) and not na(minq_ph1p6)

minq_showTlSet3 = minq_trendLinePivotSel == 3 or (minq_showMinorLines and minq_trendLinePivotSel > 3)
minq_showTlSet4 = minq_trendLinePivotSel == 4 or (minq_showMinorLines and minq_trendLinePivotSel > 4)
minq_showTlSet5 = minq_trendLinePivotSel == 5 or (minq_showMinorLines and minq_trendLinePivotSel > 5)
minq_showTlSet6 = minq_trendLinePivotSel == 6

minq_showSrSet3 = minq_srPivotSel == 3 or (minq_showMinorLines and minq_srPivotSel > 3)
minq_showSrSet4 = minq_srPivotSel == 4 or (minq_showMinorLines and minq_srPivotSel > 4)
minq_showSrSet5 = minq_srPivotSel == 5 or (minq_showMinorLines and minq_srPivotSel > 5)
minq_showSrSet6 = minq_srPivotSel == 6

var line  minq_lnUpper3 = na
var line  minq_lnLower3 = na
var line  minq_lnSup3   = na
var line  minq_lnRes3   = na
var label minq_lblUpper3 = na
var label minq_lblLower3 = na
var label minq_lblSup3   = na
var label minq_lblRes3   = na

var line  minq_lnUpper4 = na
var line  minq_lnLower4 = na
var line  minq_lnSup4   = na
var line  minq_lnRes4   = na
var label minq_lblUpper4 = na
var label minq_lblLower4 = na
var label minq_lblSup4   = na
var label minq_lblRes4   = na

var line  minq_lnUpper5 = na
var line  minq_lnLower5 = na
var line  minq_lnSup5   = na
var line  minq_lnRes5   = na
var label minq_lblUpper5 = na
var label minq_lblLower5 = na
var label minq_lblSup5   = na
var label minq_lblRes5   = na

var line  minq_lnUpper6 = na
var line  minq_lnLower6 = na
var line  minq_lnSup6   = na
var line  minq_lnRes6   = na
var label minq_lblUpper6 = na
var label minq_lblLower6 = na
var label minq_lblSup6   = na
var label minq_lblRes6   = na

// ======================================================================
// Minervini DRAW SET 3
// ======================================================================
if minq_showTlSet3 and minq_upperTrendLineOn and minq_hasUpper3
    int minq_xL3 = minq_ph2t3 - minq_extendMs
    int minq_xR3 = time + minq_rightMs
    float minq_yL3 = minq_f_y_at(minq_ph2t3, minq_ph2p3, minq_ph1t3, minq_ph1p3, minq_xL3)
    float minq_yR3 = minq_f_y_at(minq_ph2t3, minq_ph2p3, minq_ph1t3, minq_ph1p3, minq_xR3)
    int minq_xTxt3 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxt3 = minq_f_y_at(minq_ph2t3, minq_ph2p3, minq_ph1t3, minq_ph1p3, minq_xTxt3)
    if na(minq_lnUpper3)
        minq_lnUpper3 := line.new(minq_xL3, minq_yL3, minq_xR3, minq_yR3, xloc=xloc.bar_time, extend=extend.none, color=minq_upperTlColor, style=minq_upperStyle, width=minq_upperTlWidth)
    else
        line.set_xy1(minq_lnUpper3, minq_xL3, minq_yL3)
        line.set_xy2(minq_lnUpper3, minq_xR3, minq_yR3)
        line.set_color(minq_lnUpper3, minq_upperTlColor)
        line.set_style(minq_lnUpper3, minq_upperStyle)
        line.set_width(minq_lnUpper3, minq_upperTlWidth)
    if na(minq_lblUpper3)
        minq_lblUpper3 := label.new(minq_xTxt3, minq_yTxt3, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_upperTlColor, size=size.tiny)
    else
        label.set_x(minq_lblUpper3, minq_xTxt3)
        label.set_y(minq_lblUpper3, minq_yTxt3)
        label.set_text(minq_lblUpper3, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblUpper3, minq_upperTlColor)
else
    if not na(minq_lnUpper3)
        line.delete(minq_lnUpper3)
        minq_lnUpper3 := na
    if not na(minq_lblUpper3)
        label.delete(minq_lblUpper3)
        minq_lblUpper3 := na

if minq_showTlSet3 and minq_lowerTrendLineOn and minq_hasLower3
    int minq_xLL3 = minq_pl2t3 - minq_extendMs
    int minq_xRL3 = time + minq_rightMs
    float minq_yLL3 = minq_f_y_at(minq_pl2t3, minq_pl2p3, minq_pl1t3, minq_pl1p3, minq_xLL3)
    float minq_yRL3 = minq_f_y_at(minq_pl2t3, minq_pl2p3, minq_pl1t3, minq_pl1p3, minq_xRL3)
    int minq_xTxtL3 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxtL3 = minq_f_y_at(minq_pl2t3, minq_pl2p3, minq_pl1t3, minq_pl1p3, minq_xTxtL3)
    if na(minq_lnLower3)
        minq_lnLower3 := line.new(minq_xLL3, minq_yLL3, minq_xRL3, minq_yRL3, xloc=xloc.bar_time, extend=extend.none, color=minq_lowerTlColor, style=minq_lowerStyle, width=minq_lowerTlWidth)
    else
        line.set_xy1(minq_lnLower3, minq_xLL3, minq_yLL3)
        line.set_xy2(minq_lnLower3, minq_xRL3, minq_yRL3)
        line.set_color(minq_lnLower3, minq_lowerTlColor)
        line.set_style(minq_lnLower3, minq_lowerStyle)
        line.set_width(minq_lnLower3, minq_lowerTlWidth)
    if na(minq_lblLower3)
        minq_lblLower3 := label.new(minq_xTxtL3, minq_yTxtL3, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_lowerTlColor, size=size.tiny)
    else
        label.set_x(minq_lblLower3, minq_xTxtL3)
        label.set_y(minq_lblLower3, minq_yTxtL3)
        label.set_text(minq_lblLower3, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblLower3, minq_lowerTlColor)
else
    if not na(minq_lnLower3)
        line.delete(minq_lnLower3)
        minq_lnLower3 := na
    if not na(minq_lblLower3)
        label.delete(minq_lblLower3)
        minq_lblLower3 := na

if minq_showSrSet3 and minq_supportLineOn and minq_hasSup3
    int minq_x1s3 = minq_pl1t3 - minq_extendMs
    int minq_x2s3 = time + minq_rightMs
    int minq_xTxtS3 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnSup3)
        minq_lnSup3 := line.new(minq_x1s3, minq_pl1p3, minq_x2s3, minq_pl1p3, xloc=xloc.bar_time, extend=extend.none, color=minq_supportColor, style=minq_supportStyle, width=minq_supportWidth)
    else
        line.set_xy1(minq_lnSup3, minq_x1s3, minq_pl1p3)
        line.set_xy2(minq_lnSup3, minq_x2s3, minq_pl1p3)
        line.set_color(minq_lnSup3, minq_supportColor)
        line.set_style(minq_lnSup3, minq_supportStyle)
        line.set_width(minq_lnSup3, minq_supportWidth)
    if na(minq_lblSup3)
        minq_lblSup3 := label.new(minq_xTxtS3, minq_pl1p3, minq_f_line_tag("Support", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_supportColor, size=size.tiny)
    else
        label.set_x(minq_lblSup3, minq_xTxtS3)
        label.set_y(minq_lblSup3, minq_pl1p3)
        label.set_text(minq_lblSup3, minq_f_line_tag("Support", minq_srcTfText))
        label.set_textcolor(minq_lblSup3, minq_supportColor)
else
    if not na(minq_lnSup3)
        line.delete(minq_lnSup3)
        minq_lnSup3 := na
    if not na(minq_lblSup3)
        label.delete(minq_lblSup3)
        minq_lblSup3 := na

if minq_showSrSet3 and minq_resistanceLineOn and minq_hasRes3
    int minq_x1r3 = minq_ph1t3 - minq_extendMs
    int minq_x2r3 = time + minq_rightMs
    int minq_xTxtR3 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnRes3)
        minq_lnRes3 := line.new(minq_x1r3, minq_ph1p3, minq_x2r3, minq_ph1p3, xloc=xloc.bar_time, extend=extend.none, color=minq_resistanceColor, style=minq_resistanceStyle, width=minq_resistanceWidth)
    else
        line.set_xy1(minq_lnRes3, minq_x1r3, minq_ph1p3)
        line.set_xy2(minq_lnRes3, minq_x2r3, minq_ph1p3)
        line.set_color(minq_lnRes3, minq_resistanceColor)
        line.set_style(minq_lnRes3, minq_resistanceStyle)
        line.set_width(minq_lnRes3, minq_resistanceWidth)
    if na(minq_lblRes3)
        minq_lblRes3 := label.new(minq_xTxtR3, minq_ph1p3, minq_f_line_tag("Resistance", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_resistanceColor, size=size.tiny)
    else
        label.set_x(minq_lblRes3, minq_xTxtR3)
        label.set_y(minq_lblRes3, minq_ph1p3)
        label.set_text(minq_lblRes3, minq_f_line_tag("Resistance", minq_srcTfText))
        label.set_textcolor(minq_lblRes3, minq_resistanceColor)
else
    if not na(minq_lnRes3)
        line.delete(minq_lnRes3)
        minq_lnRes3 := na
    if not na(minq_lblRes3)
        label.delete(minq_lblRes3)
        minq_lblRes3 := na

// ======================================================================
// Minervini DRAW SET 4
// ======================================================================
if minq_showTlSet4 and minq_upperTrendLineOn and minq_hasUpper4
    int minq_xL4 = minq_ph2t4 - minq_extendMs
    int minq_xR4 = time + minq_rightMs
    float minq_yL4 = minq_f_y_at(minq_ph2t4, minq_ph2p4, minq_ph1t4, minq_ph1p4, minq_xL4)
    float minq_yR4 = minq_f_y_at(minq_ph2t4, minq_ph2p4, minq_ph1t4, minq_ph1p4, minq_xR4)
    int minq_xTxt4 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxt4 = minq_f_y_at(minq_ph2t4, minq_ph2p4, minq_ph1t4, minq_ph1p4, minq_xTxt4)
    if na(minq_lnUpper4)
        minq_lnUpper4 := line.new(minq_xL4, minq_yL4, minq_xR4, minq_yR4, xloc=xloc.bar_time, extend=extend.none, color=minq_upperTlColor, style=minq_upperStyle, width=minq_upperTlWidth)
    else
        line.set_xy1(minq_lnUpper4, minq_xL4, minq_yL4)
        line.set_xy2(minq_lnUpper4, minq_xR4, minq_yR4)
        line.set_color(minq_lnUpper4, minq_upperTlColor)
        line.set_style(minq_lnUpper4, minq_upperStyle)
        line.set_width(minq_lnUpper4, minq_upperTlWidth)
    if na(minq_lblUpper4)
        minq_lblUpper4 := label.new(minq_xTxt4, minq_yTxt4, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_upperTlColor, size=size.tiny)
    else
        label.set_x(minq_lblUpper4, minq_xTxt4)
        label.set_y(minq_lblUpper4, minq_yTxt4)
        label.set_text(minq_lblUpper4, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblUpper4, minq_upperTlColor)
else
    if not na(minq_lnUpper4)
        line.delete(minq_lnUpper4)
        minq_lnUpper4 := na
    if not na(minq_lblUpper4)
        label.delete(minq_lblUpper4)
        minq_lblUpper4 := na

if minq_showTlSet4 and minq_lowerTrendLineOn and minq_hasLower4
    int minq_xLL4 = minq_pl2t4 - minq_extendMs
    int minq_xRL4 = time + minq_rightMs
    float minq_yLL4 = minq_f_y_at(minq_pl2t4, minq_pl2p4, minq_pl1t4, minq_pl1p4, minq_xLL4)
    float minq_yRL4 = minq_f_y_at(minq_pl2t4, minq_pl2p4, minq_pl1t4, minq_pl1p4, minq_xRL4)
    int minq_xTxtL4 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxtL4 = minq_f_y_at(minq_pl2t4, minq_pl2p4, minq_pl1t4, minq_pl1p4, minq_xTxtL4)
    if na(minq_lnLower4)
        minq_lnLower4 := line.new(minq_xLL4, minq_yLL4, minq_xRL4, minq_yRL4, xloc=xloc.bar_time, extend=extend.none, color=minq_lowerTlColor, style=minq_lowerStyle, width=minq_lowerTlWidth)
    else
        line.set_xy1(minq_lnLower4, minq_xLL4, minq_yLL4)
        line.set_xy2(minq_lnLower4, minq_xRL4, minq_yRL4)
        line.set_color(minq_lnLower4, minq_lowerTlColor)
        line.set_style(minq_lnLower4, minq_lowerStyle)
        line.set_width(minq_lnLower4, minq_lowerTlWidth)
    if na(minq_lblLower4)
        minq_lblLower4 := label.new(minq_xTxtL4, minq_yTxtL4, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_lowerTlColor, size=size.tiny)
    else
        label.set_x(minq_lblLower4, minq_xTxtL4)
        label.set_y(minq_lblLower4, minq_yTxtL4)
        label.set_text(minq_lblLower4, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblLower4, minq_lowerTlColor)
else
    if not na(minq_lnLower4)
        line.delete(minq_lnLower4)
        minq_lnLower4 := na
    if not na(minq_lblLower4)
        label.delete(minq_lblLower4)
        minq_lblLower4 := na

if minq_showSrSet4 and minq_supportLineOn and minq_hasSup4
    int minq_x1s4 = minq_pl1t4 - minq_extendMs
    int minq_x2s4 = time + minq_rightMs
    int minq_xTxtS4 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnSup4)
        minq_lnSup4 := line.new(minq_x1s4, minq_pl1p4, minq_x2s4, minq_pl1p4, xloc=xloc.bar_time, extend=extend.none, color=minq_supportColor, style=minq_supportStyle, width=minq_supportWidth)
    else
        line.set_xy1(minq_lnSup4, minq_x1s4, minq_pl1p4)
        line.set_xy2(minq_lnSup4, minq_x2s4, minq_pl1p4)
        line.set_color(minq_lnSup4, minq_supportColor)
        line.set_style(minq_lnSup4, minq_supportStyle)
        line.set_width(minq_lnSup4, minq_supportWidth)
    if na(minq_lblSup4)
        minq_lblSup4 := label.new(minq_xTxtS4, minq_pl1p4, minq_f_line_tag("Support", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_supportColor, size=size.tiny)
    else
        label.set_x(minq_lblSup4, minq_xTxtS4)
        label.set_y(minq_lblSup4, minq_pl1p4)
        label.set_text(minq_lblSup4, minq_f_line_tag("Support", minq_srcTfText))
        label.set_textcolor(minq_lblSup4, minq_supportColor)
else
    if not na(minq_lnSup4)
        line.delete(minq_lnSup4)
        minq_lnSup4 := na
    if not na(minq_lblSup4)
        label.delete(minq_lblSup4)
        minq_lblSup4 := na

if minq_showSrSet4 and minq_resistanceLineOn and minq_hasRes4
    int minq_x1r4 = minq_ph1t4 - minq_extendMs
    int minq_x2r4 = time + minq_rightMs
    int minq_xTxtR4 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnRes4)
        minq_lnRes4 := line.new(minq_x1r4, minq_ph1p4, minq_x2r4, minq_ph1p4, xloc=xloc.bar_time, extend=extend.none, color=minq_resistanceColor, style=minq_resistanceStyle, width=minq_resistanceWidth)
    else
        line.set_xy1(minq_lnRes4, minq_x1r4, minq_ph1p4)
        line.set_xy2(minq_lnRes4, minq_x2r4, minq_ph1p4)
        line.set_color(minq_lnRes4, minq_resistanceColor)
        line.set_style(minq_lnRes4, minq_resistanceStyle)
        line.set_width(minq_lnRes4, minq_resistanceWidth)
    if na(minq_lblRes4)
        minq_lblRes4 := label.new(minq_xTxtR4, minq_ph1p4, minq_f_line_tag("Resistance", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_resistanceColor, size=size.tiny)
    else
        label.set_x(minq_lblRes4, minq_xTxtR4)
        label.set_y(minq_lblRes4, minq_ph1p4)
        label.set_text(minq_lblRes4, minq_f_line_tag("Resistance", minq_srcTfText))
        label.set_textcolor(minq_lblRes4, minq_resistanceColor)
else
    if not na(minq_lnRes4)
        line.delete(minq_lnRes4)
        minq_lnRes4 := na
    if not na(minq_lblRes4)
        label.delete(minq_lblRes4)
        minq_lblRes4 := na

// ======================================================================
// Minervini DRAW SET 5
// ======================================================================
if minq_showTlSet5 and minq_upperTrendLineOn and minq_hasUpper5
    int minq_xL5 = minq_ph2t5 - minq_extendMs
    int minq_xR5 = time + minq_rightMs
    float minq_yL5 = minq_f_y_at(minq_ph2t5, minq_ph2p5, minq_ph1t5, minq_ph1p5, minq_xL5)
    float minq_yR5 = minq_f_y_at(minq_ph2t5, minq_ph2p5, minq_ph1t5, minq_ph1p5, minq_xR5)
    int minq_xTxt5 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxt5 = minq_f_y_at(minq_ph2t5, minq_ph2p5, minq_ph1t5, minq_ph1p5, minq_xTxt5)
    if na(minq_lnUpper5)
        minq_lnUpper5 := line.new(minq_xL5, minq_yL5, minq_xR5, minq_yR5, xloc=xloc.bar_time, extend=extend.none, color=minq_upperTlColor, style=minq_upperStyle, width=minq_upperTlWidth)
    else
        line.set_xy1(minq_lnUpper5, minq_xL5, minq_yL5)
        line.set_xy2(minq_lnUpper5, minq_xR5, minq_yR5)
        line.set_color(minq_lnUpper5, minq_upperTlColor)
        line.set_style(minq_lnUpper5, minq_upperStyle)
        line.set_width(minq_lnUpper5, minq_upperTlWidth)
    if na(minq_lblUpper5)
        minq_lblUpper5 := label.new(minq_xTxt5, minq_yTxt5, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_upperTlColor, size=size.tiny)
    else
        label.set_x(minq_lblUpper5, minq_xTxt5)
        label.set_y(minq_lblUpper5, minq_yTxt5)
        label.set_text(minq_lblUpper5, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblUpper5, minq_upperTlColor)
else
    if not na(minq_lnUpper5)
        line.delete(minq_lnUpper5)
        minq_lnUpper5 := na
    if not na(minq_lblUpper5)
        label.delete(minq_lblUpper5)
        minq_lblUpper5 := na

if minq_showTlSet5 and minq_lowerTrendLineOn and minq_hasLower5
    int minq_xLL5 = minq_pl2t5 - minq_extendMs
    int minq_xRL5 = time + minq_rightMs
    float minq_yLL5 = minq_f_y_at(minq_pl2t5, minq_pl2p5, minq_pl1t5, minq_pl1p5, minq_xLL5)
    float minq_yRL5 = minq_f_y_at(minq_pl2t5, minq_pl2p5, minq_pl1t5, minq_pl1p5, minq_xRL5)
    int minq_xTxtL5 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxtL5 = minq_f_y_at(minq_pl2t5, minq_pl2p5, minq_pl1t5, minq_pl1p5, minq_xTxtL5)
    if na(minq_lnLower5)
        minq_lnLower5 := line.new(minq_xLL5, minq_yLL5, minq_xRL5, minq_yRL5, xloc=xloc.bar_time, extend=extend.none, color=minq_lowerTlColor, style=minq_lowerStyle, width=minq_lowerTlWidth)
    else
        line.set_xy1(minq_lnLower5, minq_xLL5, minq_yLL5)
        line.set_xy2(minq_lnLower5, minq_xRL5, minq_yRL5)
        line.set_color(minq_lnLower5, minq_lowerTlColor)
        line.set_style(minq_lnLower5, minq_lowerStyle)
        line.set_width(minq_lnLower5, minq_lowerTlWidth)
    if na(minq_lblLower5)
        minq_lblLower5 := label.new(minq_xTxtL5, minq_yTxtL5, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_lowerTlColor, size=size.tiny)
    else
        label.set_x(minq_lblLower5, minq_xTxtL5)
        label.set_y(minq_lblLower5, minq_yTxtL5)
        label.set_text(minq_lblLower5, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblLower5, minq_lowerTlColor)
else
    if not na(minq_lnLower5)
        line.delete(minq_lnLower5)
        minq_lnLower5 := na
    if not na(minq_lblLower5)
        label.delete(minq_lblLower5)
        minq_lblLower5 := na

if minq_showSrSet5 and minq_supportLineOn and minq_hasSup5
    int minq_x1s5 = minq_pl1t5 - minq_extendMs
    int minq_x2s5 = time + minq_rightMs
    int minq_xTxtS5 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnSup5)
        minq_lnSup5 := line.new(minq_x1s5, minq_pl1p5, minq_x2s5, minq_pl1p5, xloc=xloc.bar_time, extend=extend.none, color=minq_supportColor, style=minq_supportStyle, width=minq_supportWidth)
    else
        line.set_xy1(minq_lnSup5, minq_x1s5, minq_pl1p5)
        line.set_xy2(minq_lnSup5, minq_x2s5, minq_pl1p5)
        line.set_color(minq_lnSup5, minq_supportColor)
        line.set_style(minq_lnSup5, minq_supportStyle)
        line.set_width(minq_lnSup5, minq_supportWidth)
    if na(minq_lblSup5)
        minq_lblSup5 := label.new(minq_xTxtS5, minq_pl1p5, minq_f_line_tag("Support", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_supportColor, size=size.tiny)
    else
        label.set_x(minq_lblSup5, minq_xTxtS5)
        label.set_y(minq_lblSup5, minq_pl1p5)
        label.set_text(minq_lblSup5, minq_f_line_tag("Support", minq_srcTfText))
        label.set_textcolor(minq_lblSup5, minq_supportColor)
else
    if not na(minq_lnSup5)
        line.delete(minq_lnSup5)
        minq_lnSup5 := na
    if not na(minq_lblSup5)
        label.delete(minq_lblSup5)
        minq_lblSup5 := na

if minq_showSrSet5 and minq_resistanceLineOn and minq_hasRes5
    int minq_x1r5 = minq_ph1t5 - minq_extendMs
    int minq_x2r5 = time + minq_rightMs
    int minq_xTxtR5 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnRes5)
        minq_lnRes5 := line.new(minq_x1r5, minq_ph1p5, minq_x2r5, minq_ph1p5, xloc=xloc.bar_time, extend=extend.none, color=minq_resistanceColor, style=minq_resistanceStyle, width=minq_resistanceWidth)
    else
        line.set_xy1(minq_lnRes5, minq_x1r5, minq_ph1p5)
        line.set_xy2(minq_lnRes5, minq_x2r5, minq_ph1p5)
        line.set_color(minq_lnRes5, minq_resistanceColor)
        line.set_style(minq_lnRes5, minq_resistanceStyle)
        line.set_width(minq_lnRes5, minq_resistanceWidth)
    if na(minq_lblRes5)
        minq_lblRes5 := label.new(minq_xTxtR5, minq_ph1p5, minq_f_line_tag("Resistance", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_resistanceColor, size=size.tiny)
    else
        label.set_x(minq_lblRes5, minq_xTxtR5)
        label.set_y(minq_lblRes5, minq_ph1p5)
        label.set_text(minq_lblRes5, minq_f_line_tag("Resistance", minq_srcTfText))
        label.set_textcolor(minq_lblRes5, minq_resistanceColor)
else
    if not na(minq_lnRes5)
        line.delete(minq_lnRes5)
        minq_lnRes5 := na
    if not na(minq_lblRes5)
        label.delete(minq_lblRes5)
        minq_lblRes5 := na

// ======================================================================
// Minervini DRAW SET 6
// ======================================================================
if minq_showTlSet6 and minq_upperTrendLineOn and minq_hasUpper6
    int minq_xL6 = minq_ph2t6 - minq_extendMs
    int minq_xR6 = time + minq_rightMs
    float minq_yL6 = minq_f_y_at(minq_ph2t6, minq_ph2p6, minq_ph1t6, minq_ph1p6, minq_xL6)
    float minq_yR6 = minq_f_y_at(minq_ph2t6, minq_ph2p6, minq_ph1t6, minq_ph1p6, minq_xR6)
    int minq_xTxt6 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxt6 = minq_f_y_at(minq_ph2t6, minq_ph2p6, minq_ph1t6, minq_ph1p6, minq_xTxt6)
    if na(minq_lnUpper6)
        minq_lnUpper6 := line.new(minq_xL6, minq_yL6, minq_xR6, minq_yR6, xloc=xloc.bar_time, extend=extend.none, color=minq_upperTlColor, style=minq_upperStyle, width=minq_upperTlWidth)
    else
        line.set_xy1(minq_lnUpper6, minq_xL6, minq_yL6)
        line.set_xy2(minq_lnUpper6, minq_xR6, minq_yR6)
        line.set_color(minq_lnUpper6, minq_upperTlColor)
        line.set_style(minq_lnUpper6, minq_upperStyle)
        line.set_width(minq_lnUpper6, minq_upperTlWidth)
    if na(minq_lblUpper6)
        minq_lblUpper6 := label.new(minq_xTxt6, minq_yTxt6, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_upperTlColor, size=size.tiny)
    else
        label.set_x(minq_lblUpper6, minq_xTxt6)
        label.set_y(minq_lblUpper6, minq_yTxt6)
        label.set_text(minq_lblUpper6, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblUpper6, minq_upperTlColor)
else
    if not na(minq_lnUpper6)
        line.delete(minq_lnUpper6)
        minq_lnUpper6 := na
    if not na(minq_lblUpper6)
        label.delete(minq_lblUpper6)
        minq_lblUpper6 := na

if minq_showTlSet6 and minq_lowerTrendLineOn and minq_hasLower6
    int minq_xLL6 = minq_pl2t6 - minq_extendMs
    int minq_xRL6 = time + minq_rightMs
    float minq_yLL6 = minq_f_y_at(minq_pl2t6, minq_pl2p6, minq_pl1t6, minq_pl1p6, minq_xLL6)
    float minq_yRL6 = minq_f_y_at(minq_pl2t6, minq_pl2p6, minq_pl1t6, minq_pl1p6, minq_xRL6)
    int minq_xTxtL6 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    float minq_yTxtL6 = minq_f_y_at(minq_pl2t6, minq_pl2p6, minq_pl1t6, minq_pl1p6, minq_xTxtL6)
    if na(minq_lnLower6)
        minq_lnLower6 := line.new(minq_xLL6, minq_yLL6, minq_xRL6, minq_yRL6, xloc=xloc.bar_time, extend=extend.none, color=minq_lowerTlColor, style=minq_lowerStyle, width=minq_lowerTlWidth)
    else
        line.set_xy1(minq_lnLower6, minq_xLL6, minq_yLL6)
        line.set_xy2(minq_lnLower6, minq_xRL6, minq_yRL6)
        line.set_color(minq_lnLower6, minq_lowerTlColor)
        line.set_style(minq_lnLower6, minq_lowerStyle)
        line.set_width(minq_lnLower6, minq_lowerTlWidth)
    if na(minq_lblLower6)
        minq_lblLower6 := label.new(minq_xTxtL6, minq_yTxtL6, minq_f_line_tag("Trend", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_lowerTlColor, size=size.tiny)
    else
        label.set_x(minq_lblLower6, minq_xTxtL6)
        label.set_y(minq_lblLower6, minq_yTxtL6)
        label.set_text(minq_lblLower6, minq_f_line_tag("Trend", minq_srcTfText))
        label.set_textcolor(minq_lblLower6, minq_lowerTlColor)
else
    if not na(minq_lnLower6)
        line.delete(minq_lnLower6)
        minq_lnLower6 := na
    if not na(minq_lblLower6)
        label.delete(minq_lblLower6)
        minq_lblLower6 := na

if minq_showSrSet6 and minq_supportLineOn and minq_hasSup6
    int minq_x1s6 = minq_pl1t6 - minq_extendMs
    int minq_x2s6 = time + minq_rightMs
    int minq_xTxtS6 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnSup6)
        minq_lnSup6 := line.new(minq_x1s6, minq_pl1p6, minq_x2s6, minq_pl1p6, xloc=xloc.bar_time, extend=extend.none, color=minq_supportColor, style=minq_supportStyle, width=minq_supportWidth)
    else
        line.set_xy1(minq_lnSup6, minq_x1s6, minq_pl1p6)
        line.set_xy2(minq_lnSup6, minq_x2s6, minq_pl1p6)
        line.set_color(minq_lnSup6, minq_supportColor)
        line.set_style(minq_lnSup6, minq_supportStyle)
        line.set_width(minq_lnSup6, minq_supportWidth)
    if na(minq_lblSup6)
        minq_lblSup6 := label.new(minq_xTxtS6, minq_pl1p6, minq_f_line_tag("Support", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_supportColor, size=size.tiny)
    else
        label.set_x(minq_lblSup6, minq_xTxtS6)
        label.set_y(minq_lblSup6, minq_pl1p6)
        label.set_text(minq_lblSup6, minq_f_line_tag("Support", minq_srcTfText))
        label.set_textcolor(minq_lblSup6, minq_supportColor)
else
    if not na(minq_lnSup6)
        line.delete(minq_lnSup6)
        minq_lnSup6 := na
    if not na(minq_lblSup6)
        label.delete(minq_lblSup6)
        minq_lblSup6 := na

if minq_showSrSet6 and minq_resistanceLineOn and minq_hasRes6
    int minq_x1r6 = minq_ph1t6 - minq_extendMs
    int minq_x2r6 = time + minq_rightMs
    int minq_xTxtR6 = time + math.max(minq_rightMs - (minq_tfMs * 2), 0)
    if na(minq_lnRes6)
        minq_lnRes6 := line.new(minq_x1r6, minq_ph1p6, minq_x2r6, minq_ph1p6, xloc=xloc.bar_time, extend=extend.none, color=minq_resistanceColor, style=minq_resistanceStyle, width=minq_resistanceWidth)
    else
        line.set_xy1(minq_lnRes6, minq_x1r6, minq_ph1p6)
        line.set_xy2(minq_lnRes6, minq_x2r6, minq_ph1p6)
        line.set_color(minq_lnRes6, minq_resistanceColor)
        line.set_style(minq_lnRes6, minq_resistanceStyle)
        line.set_width(minq_lnRes6, minq_resistanceWidth)
    if na(minq_lblRes6)
        minq_lblRes6 := label.new(minq_xTxtR6, minq_ph1p6, minq_f_line_tag("Resistance", minq_srcTfText), xloc=xloc.bar_time, style=label.style_none, textcolor=minq_resistanceColor, size=size.tiny)
    else
        label.set_x(minq_lblRes6, minq_xTxtR6)
        label.set_y(minq_lblRes6, minq_ph1p6)
        label.set_text(minq_lblRes6, minq_f_line_tag("Resistance", minq_srcTfText))
        label.set_textcolor(minq_lblRes6, minq_resistanceColor)
else
    if not na(minq_lnRes6)
        line.delete(minq_lnRes6)
        minq_lnRes6 := na
    if not na(minq_lblRes6)
        label.delete(minq_lblRes6)
        minq_lblRes6 := na

//====================================================
// Trend Bars on Global VWAP / Bands
//====================================================
trendBody      = math.abs(close - open)
trendRange     = math.max(high - low, syminfo.mintick)
trendBodyRatio = trendRange > 0.0 ? trendBody / trendRange : 0.0
trendUpperWick = high - math.max(open, close)
trendLowerWick = math.min(open, close) - low
trendMaxWick   = math.max(trendUpperWick, trendLowerWick)
trendBodyAvg   = ta.sma(math.abs(close - open), 20)
trendVolAvg    = ta.sma(volume, 20)
trendTouchTol  = math.max(atr14 * 0.12, syminfo.mintick * 8)

trendBodyOk = not na(trendBodyAvg) and trendBody >= trendBodyAvg * 1.10
trendVolOk  = na(trendVolAvg) or trendVolAvg <= 0 ? true : volume >= trendVolAvg * 1.00
trendWickOk = trendBody > syminfo.mintick and trendMaxWick <= trendBody * trendBarMaxWickRatio

dojiBodyOk = trendRange > syminfo.mintick and trendBodyRatio <= dojiMaxBodyRatio
dojiVolOk  = na(trendVolAvg) or trendVolAvg <= 0 ? true : volume >= trendVolAvg * dojiMinVolumeMult

f_lineTouched(_y) =>
    not na(_y) and high >= (_y - trendTouchTol) and low <= (_y + trendTouchTol)

bool touchMainVWAP =
     (showVWAPModule and f_lineTouched(plotVWAPBr)) or
     (showVWAPModule and showBand1 and f_lineTouched(plotUpper1)) or
     (showVWAPModule and showBand2 and f_lineTouched(plotUpper2)) or
     (showVWAPModule and showBand3 and f_lineTouched(plotUpper3)) or
     (showVWAPModule and showBand1 and f_lineTouched(plotLower1)) or
     (showVWAPModule and showBand2 and f_lineTouched(plotLower2)) or
     (showVWAPModule and showBand3 and f_lineTouched(plotLower3))

var int lastTrendBarIndex = na

bool rawTrendBar = showTrendBarsModule and trendBodyOk and trendVolOk and trendWickOk and touchMainVWAP
bool spacingOk = na(lastTrendBarIndex) or (bar_index - lastTrendBarIndex >= trendBarMinSpacing)
bool isTrendBar = rawTrendBar and spacingOk and barstate.isconfirmed

bool isDoji = showDojiModule and dojiBodyOk and dojiVolOk and barstate.isconfirmed

if isTrendBar
    lastTrendBarIndex := bar_index

color signalBarColor = na
if isTrendBar
    signalBarColor := close >= open ? trendBarBullColor : trendBarBearColor
else if isDoji
    signalBarColor := close >= open ? dojiBullColor : dojiBearColor

barcolor(not na(signalBarColor) ? signalBarColor : (minq_useBarColors ? (close >= open ? minq_bullBarColor : minq_bearBarColor) : na))

//====================================================
// Quantum Modules Bias + NY930 HL DailyFVG
//====================================================

//====================================================
// Inputs
//====================================================
q2_groupToggles        = "Toggles"
q2_groupBase           = "VWAP"
q2_groupBands          = "Bands"
q2_groupStyle          = "Style"
q2_groupMoveHL         = "Movement High/Low"
q2_groupNY930VWAP      = "09:30 NY VWAP"
q2_groupDailyBias      = "Daily Bias Table"
q2_groupNYSessionHL    = "NY Session H/L"
q2_groupDailyFVG       = "Daily FVG"
q2_groupDailyWeeklyHL  = "Daily/Weekly H/L"
q2_groupTime           = "Time"

q2_showNY930VWAPModule     = input.bool(true,  "Show 09:30 NY VWAP",    group = q2_groupToggles)
q2_showNYSessionHLModule   = input.bool(true,  "Show NY Session H/L",   group = q2_groupToggles)
q2_showDailyFVGModule      = input.bool(true,  "Show Daily FVG",        group = q2_groupToggles)
q2_showDailyWeeklyHLModule = input.bool(true,  "Show Daily/Weekly H/L", group = q2_groupToggles)
q2_showMoveHLModule        = input.bool(true,  "Show Movement High/Low", group = q2_groupToggles)
q2_showBiasLabelsModule    = input.bool(true,  "Show 3 Bias Labels",     group = q2_groupToggles)
q2_showDailyBiasTableModule = input.bool(true, "Show Daily Bias Table",  group = q2_groupToggles)

q2_dailyBiasTableSizeS   = input.string("Small", "Daily bias table size", options = ["Super Small", "Small", "Normal"], group = q2_groupDailyBias)
q2_rightSideLabelsSizeS  = input.string("Small", "Right-side labels size", options = ["Super Small", "Small", "Normal"], group = q2_groupDailyBias)

q2_src          = src
q2_macroTimezone = input.string("America/New_York", "Macro timezone", group = q2_groupTime)

q2_showBand1    = showBand1
q2_showBand2    = showBand2
q2_showBand3    = showBand3
q2_multBand1    = multBand1
q2_multBand2    = multBand2
q2_multBand3    = multBand3

// Duplicate Global VWAP style inputs removed. The q2 module now uses the main Global VWAP only.

q2_ny930VwapWidth  = input.int(2, "09:30 VWAP width", minval = 1, maxval = 5, group = q2_groupNY930VWAP)
q2_ny930Band1Width = input.int(1, "09:30 Band 1 width", minval = 1, maxval = 5, group = q2_groupNY930VWAP)
q2_ny930Band2Width = input.int(1, "09:30 Band 2 width", minval = 1, maxval = 5, group = q2_groupNY930VWAP)
q2_ny930Band3Width = input.int(1, "09:30 Band 3 width", minval = 1, maxval = 5, group = q2_groupNY930VWAP)

q2_nySessionHLColor  = input.color(color.new(color.rgb(176, 136, 255), 30), "NY Session H/L color", group = q2_groupNYSessionHL)
q2_nySessionHLWidth  = input.int(1, "NY Session H/L width", minval = 1, maxval = 5, group = q2_groupNYSessionHL)
q2_nySessionHLStyleS = input.string("Solid", "NY Session H/L style", options = ["Solid", "Dashed", "Dotted"], group = q2_groupNYSessionHL)

q2_dailyFvgBullFill     = input.color(color.new(color.rgb(120, 145, 180), 30), "Bull daily FVG zone", group = q2_groupDailyFVG)
q2_dailyFvgBullBorder   = input.color(color.new(color.rgb(120, 145, 180), 100), "Bull daily FVG border", group = q2_groupDailyFVG)
q2_dailyFvgBearFill     = input.color(color.new(color.rgb(180, 120, 120), 30), "Bear daily FVG zone", group = q2_groupDailyFVG)
q2_dailyFvgBearBorder   = input.color(color.new(color.rgb(180, 120, 120), 100), "Bear daily FVG border", group = q2_groupDailyFVG)
q2_dailyFvgBorderWidth  = input.int(1, "Daily FVG border width", minval = 1, maxval = 5, group = q2_groupDailyFVG)
q2_dailyFvgBorderStyleS = input.string("Solid", "Daily FVG border style", options = ["Solid", "Dashed", "Dotted"], group = q2_groupDailyFVG)

q2_weeklyHLColor  = input.color(color.new(color.rgb(190, 235, 255), 30), "Weekly H/L color", group = q2_groupDailyWeeklyHL)
q2_weeklyHLWidth  = input.int(1, "Weekly H/L width", minval = 1, maxval = 5, group = q2_groupDailyWeeklyHL)
q2_weeklyHLStyleS = input.string("Solid", "Weekly H/L style", options = ["Solid", "Dashed", "Dotted"], group = q2_groupDailyWeeklyHL)
q2_dailyHLColor   = input.color(color.new(color.rgb(255, 238, 170), 30), "Daily H/L color", group = q2_groupDailyWeeklyHL)
q2_dailyHLWidth   = input.int(1, "Daily H/L width", minval = 1, maxval = 5, group = q2_groupDailyWeeklyHL)
q2_dailyHLStyleS  = input.string("Dotted", "Daily H/L style", options = ["Solid", "Dashed", "Dotted"], group = q2_groupDailyWeeklyHL)

q2_movePivotLen   = input.int(20, "Pivot strength", minval = 1, maxval = 20, group = q2_groupMoveHL)
q2_moveHighColor  = input.color(color.new(color.rgb(185, 235, 255), 30), "High line color", group = q2_groupMoveHL)
q2_moveLowColor   = input.color(color.new(color.rgb(255, 170, 170), 30), "Low line color", group = q2_groupMoveHL)
q2_moveLineWidth  = input.int(1, "Line width", minval = 1, maxval = 5, group = q2_groupMoveHL)
q2_moveLineStyleS = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = q2_groupMoveHL)

//====================================================
// Helpers
//====================================================
q2_f_lineStyle(q2__style) =>
    q2__style == "Solid" ? line.style_solid : q2__style == "Dashed" ? line.style_dashed : line.style_dotted

q2_f_dayTs(q2__h, q2__m) =>
    timestamp(q2_macroTimezone, year(time, q2_macroTimezone), month(time, q2_macroTimezone), dayofmonth(time, q2_macroTimezone), q2__h, q2__m)

q2_f_nextMidnightTs() =>
    timestamp(q2_macroTimezone, year(time, q2_macroTimezone), month(time, q2_macroTimezone), dayofmonth(time, q2_macroTimezone) + 1, 0, 0)

q2_f_midTs(q2__leftTs, q2__rightTs) =>
    q2__leftTs + int(math.floor((q2__rightTs - q2__leftTs) / 2))

q2_f_pct(q2__part, q2__total) =>
    q2__total > 0 ? math.round(q2__part * 100.0 / q2__total) : 0.0

q2_f_tableTextSize(q2__size) =>
    q2__size == "Super Small" ? size.tiny : q2__size == "Normal" ? size.normal : size.small

q2_f_labelTextSize(q2__size) =>
    q2__size == "Super Small" ? size.tiny : q2__size == "Normal" ? size.normal : size.small

q2_rightSideBars = 4
q2_rightSideMs = math.max(1, timeframe.in_seconds()) * 1000 * q2_rightSideBars
q2_f_rightLabelX() =>
    time + q2_rightSideMs

q2_f_biasStateText(q2__dir) =>
    q2__dir == 1 ? "🟩 BIAS BULL" : q2__dir == -1 ? "🟥 BIAS BEAR" : "⚖ BIAS"

q2_f_biasText(q2__title, q2__highPct, q2__midPct, q2__lowPct, q2__dir) =>
    q2__title + "\nH: " + str.tostring(q2__highPct, "#.0") + "%\nM: " + str.tostring(q2__midPct, "#.0") + "%\nL: " + str.tostring(q2__lowPct, "#.0") + "%\n" + q2_f_biasStateText(q2__dir)

q2_rightSideLabelSize = q2_f_labelTextSize(q2_rightSideLabelsSizeS)

//====================================================
// Global VWAP alias for q2 modules
//====================================================
q2_newAnchor = newAnchor
q2_vwap = vwap
q2_dev = dev
q2_atr14 = atr14
q2_upperBand1 = upperBand1
q2_upperBand2 = upperBand2
q2_upperBand3 = upperBand3
q2_lowerBand1 = lowerBand1
q2_lowerBand2 = lowerBand2
q2_lowerBand3 = lowerBand3
q2_plotVWAPBr = plotVWAPBr
q2_plotUpper1 = plotUpper1
q2_plotUpper2 = plotUpper2
q2_plotUpper3 = plotUpper3
q2_plotLower1 = plotLower1
q2_plotLower2 = plotLower2
q2_plotLower3 = plotLower3

//====================================================
// 09:30 NY VWAP + 3 bands
//====================================================
q2_ny930Hour = hour(time, q2_macroTimezone)
q2_ny930Minute = minute(time, q2_macroTimezone)
q2_ny930Total = q2_ny930Hour * 60 + q2_ny930Minute
q2_ny930StartMin = 9 * 60 + 30
q2_inNY930Window = q2_ny930Total >= q2_ny930StartMin
q2_prevNy930Total = barstate.isfirst ? -1 : q2_ny930Total[1]
q2_ny930StartBar = q2_inNY930Window and (barstate.isfirst or q2_prevNy930Total < q2_ny930StartMin)

var float q2_ny930SumPV  = na
var float q2_ny930SumV   = na
var float q2_ny930SumP2V = na

if q2_ny930StartBar
    q2_ny930SumPV  := q2_src * volume
    q2_ny930SumV   := volume
    q2_ny930SumP2V := q2_src * q2_src * volume
else if q2_inNY930Window
    q2_ny930SumPV  += q2_src * volume
    q2_ny930SumV   += volume
    q2_ny930SumP2V += q2_src * q2_src * volume
else
    q2_ny930SumPV  := na
    q2_ny930SumV   := na
    q2_ny930SumP2V := na

q2_ny930Vwap = q2_inNY930Window and not na(q2_ny930SumV) and q2_ny930SumV != 0.0 ? q2_ny930SumPV / q2_ny930SumV : na
q2_ny930Variance = q2_inNY930Window and not na(q2_ny930SumV) and q2_ny930SumV != 0.0 ? math.max(q2_ny930SumP2V / q2_ny930SumV - q2_ny930Vwap * q2_ny930Vwap, 0.0) : na
q2_ny930Dev = math.sqrt(q2_ny930Variance)

q2_ny930Upper1 = q2_showNY930VWAPModule ? q2_ny930Vwap + q2_ny930Dev * q2_multBand1 : na
q2_ny930Upper2 = q2_showNY930VWAPModule ? q2_ny930Vwap + q2_ny930Dev * q2_multBand2 : na
q2_ny930Upper3 = q2_showNY930VWAPModule ? q2_ny930Vwap + q2_ny930Dev * q2_multBand3 : na
q2_ny930Lower1 = q2_showNY930VWAPModule ? q2_ny930Vwap - q2_ny930Dev * q2_multBand1 : na
q2_ny930Lower2 = q2_showNY930VWAPModule ? q2_ny930Vwap - q2_ny930Dev * q2_multBand2 : na
q2_ny930Lower3 = q2_showNY930VWAPModule ? q2_ny930Vwap - q2_ny930Dev * q2_multBand3 : na

q2_plotNy930Vwap   = q2_showNY930VWAPModule and q2_inNY930Window ? q2_ny930Vwap : na
q2_plotNy930Upper1 = q2_showNY930VWAPModule and q2_inNY930Window ? q2_ny930Upper1 : na
q2_plotNy930Upper2 = q2_showNY930VWAPModule and q2_inNY930Window ? q2_ny930Upper2 : na
q2_plotNy930Upper3 = q2_showNY930VWAPModule and q2_inNY930Window ? q2_ny930Upper3 : na
q2_plotNy930Lower1 = q2_showNY930VWAPModule and q2_inNY930Window ? q2_ny930Lower1 : na
q2_plotNy930Lower2 = q2_showNY930VWAPModule and q2_inNY930Window ? q2_ny930Lower2 : na
q2_plotNy930Lower3 = q2_showNY930VWAPModule and q2_inNY930Window ? q2_ny930Lower3 : na

q2_plotNy930VwapBr   = q2_ny930StartBar ? na : q2_plotNy930Vwap
q2_plotNy930Upper1Br = q2_ny930StartBar ? na : q2_plotNy930Upper1
q2_plotNy930Upper2Br = q2_ny930StartBar ? na : q2_plotNy930Upper2
q2_plotNy930Upper3Br = q2_ny930StartBar ? na : q2_plotNy930Upper3
q2_plotNy930Lower1Br = q2_ny930StartBar ? na : q2_plotNy930Lower1
q2_plotNy930Lower2Br = q2_ny930StartBar ? na : q2_plotNy930Lower2
q2_plotNy930Lower3Br = q2_ny930StartBar ? na : q2_plotNy930Lower3

q2_ny930VwapColor   = color.new(color.rgb(230, 160, 0), 30)
q2_ny930Upper1Color = color.new(color.rgb(0, 122, 255), 30)
q2_ny930Upper2Color = color.new(color.rgb(0, 208, 132), 30)
q2_ny930Upper3Color = color.new(color.rgb(215, 215, 215), 30)
q2_ny930Lower1Color = color.new(color.rgb(0, 122, 255), 30)
q2_ny930Lower2Color = color.new(color.rgb(0, 208, 132), 30)
q2_ny930Lower3Color = color.new(color.rgb(215, 215, 215), 30)
q2_ny930UpperFill   = color.new(color.rgb(0, 208, 132), 88)
q2_ny930LowerFill   = color.new(color.rgb(0, 122, 255), 90)

//====================================================
// Daily/Weekly H/L lines
//====================================================
q2_newDayLine = ta.change(time("D")) != 0
q2_newWeekLine = ta.change(time("W")) != 0

q2_weekHighLineVal = request.security(syminfo.tickerid, "W", high, lookahead = barmerge.lookahead_off)
q2_weekLowLineVal  = request.security(syminfo.tickerid, "W", low,  lookahead = barmerge.lookahead_off)

q2_prevDayHighLineVal = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_off)
q2_prevDayLowLineVal  = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_off)

var line q2_weekHighObj = na
var line q2_weekLowObj = na
var line q2_prevDayHighObj = na
var line q2_prevDayLowObj = na
var bool q2_prevDayHighActive = false
var bool q2_prevDayLowActive  = false

if q2_showDailyWeeklyHLModule and (q2_newWeekLine or na(q2_weekHighObj))
    if not na(q2_weekHighObj)
        line.delete(q2_weekHighObj)
    if not na(q2_weekLowObj)
        line.delete(q2_weekLowObj)
    q2_weekHighObj := line.new(x1 = time, y1 = q2_weekHighLineVal, x2 = time, y2 = q2_weekHighLineVal, xloc = xloc.bar_time, color = q2_weeklyHLColor, width = q2_weeklyHLWidth)
    q2_weekLowObj  := line.new(x1 = time, y1 = q2_weekLowLineVal,  x2 = time, y2 = q2_weekLowLineVal,  xloc = xloc.bar_time, color = q2_weeklyHLColor, width = q2_weeklyHLWidth)
    line.set_style(q2_weekHighObj, q2_f_lineStyle(q2_weeklyHLStyleS))
    line.set_style(q2_weekLowObj,  q2_f_lineStyle(q2_weeklyHLStyleS))
else if q2_showDailyWeeklyHLModule and not na(q2_weekHighObj) and not na(q2_weekLowObj)
    line.set_x2(q2_weekHighObj, time)
    line.set_y1(q2_weekHighObj, q2_weekHighLineVal)
    line.set_y2(q2_weekHighObj, q2_weekHighLineVal)
    line.set_color(q2_weekHighObj, q2_weeklyHLColor)
    line.set_width(q2_weekHighObj, q2_weeklyHLWidth)
    line.set_style(q2_weekHighObj, q2_f_lineStyle(q2_weeklyHLStyleS))

    line.set_x2(q2_weekLowObj, time)
    line.set_y1(q2_weekLowObj, q2_weekLowLineVal)
    line.set_y2(q2_weekLowObj, q2_weekLowLineVal)
    line.set_color(q2_weekLowObj, q2_weeklyHLColor)
    line.set_width(q2_weekLowObj, q2_weeklyHLWidth)
    line.set_style(q2_weekLowObj, q2_f_lineStyle(q2_weeklyHLStyleS))
else if not q2_showDailyWeeklyHLModule
    if not na(q2_weekHighObj)
        line.delete(q2_weekHighObj)
        q2_weekHighObj := na
    if not na(q2_weekLowObj)
        line.delete(q2_weekLowObj)
        q2_weekLowObj := na

if q2_showDailyWeeklyHLModule and q2_newDayLine
    q2_prevDayHighActive := not na(q2_prevDayHighLineVal)
    q2_prevDayLowActive := not na(q2_prevDayLowLineVal)

    if not na(q2_prevDayHighObj)
        line.delete(q2_prevDayHighObj)
    if not na(q2_prevDayLowObj)
        line.delete(q2_prevDayLowObj)

    if q2_prevDayHighActive
        q2_prevDayHighObj := line.new(x1 = time, y1 = q2_prevDayHighLineVal, x2 = time, y2 = q2_prevDayHighLineVal, xloc = xloc.bar_time, color = q2_dailyHLColor, width = q2_dailyHLWidth)
        line.set_style(q2_prevDayHighObj, q2_f_lineStyle(q2_dailyHLStyleS))
    else
        q2_prevDayHighObj := na

    if q2_prevDayLowActive
        q2_prevDayLowObj := line.new(x1 = time, y1 = q2_prevDayLowLineVal, x2 = time, y2 = q2_prevDayLowLineVal, xloc = xloc.bar_time, color = q2_dailyHLColor, width = q2_dailyHLWidth)
        line.set_style(q2_prevDayLowObj, q2_f_lineStyle(q2_dailyHLStyleS))
    else
        q2_prevDayLowObj := na

bool q2_prevDayHighTouched = q2_prevDayHighActive and not na(q2_prevDayHighLineVal) and high >= q2_prevDayHighLineVal and low <= q2_prevDayHighLineVal
bool q2_prevDayLowTouched  = q2_prevDayLowActive  and not na(q2_prevDayLowLineVal)  and high >= q2_prevDayLowLineVal  and low <= q2_prevDayLowLineVal

if q2_showDailyWeeklyHLModule and q2_prevDayHighActive and not na(q2_prevDayHighObj)
    line.set_x2(q2_prevDayHighObj, time)
    line.set_y1(q2_prevDayHighObj, q2_prevDayHighLineVal)
    line.set_y2(q2_prevDayHighObj, q2_prevDayHighLineVal)
    line.set_color(q2_prevDayHighObj, q2_dailyHLColor)
    line.set_width(q2_prevDayHighObj, q2_dailyHLWidth)
    line.set_style(q2_prevDayHighObj, q2_f_lineStyle(q2_dailyHLStyleS))
    if q2_prevDayHighTouched
        q2_prevDayHighActive := false

if q2_showDailyWeeklyHLModule and q2_prevDayLowActive and not na(q2_prevDayLowObj)
    line.set_x2(q2_prevDayLowObj, time)
    line.set_y1(q2_prevDayLowObj, q2_prevDayLowLineVal)
    line.set_y2(q2_prevDayLowObj, q2_prevDayLowLineVal)
    line.set_color(q2_prevDayLowObj, q2_dailyHLColor)
    line.set_width(q2_prevDayLowObj, q2_dailyHLWidth)
    line.set_style(q2_prevDayLowObj, q2_f_lineStyle(q2_dailyHLStyleS))
    if q2_prevDayLowTouched
        q2_prevDayLowActive := false

if not q2_showDailyWeeklyHLModule
    if not na(q2_weekHighObj)
        line.delete(q2_weekHighObj)
        q2_weekHighObj := na
    if not na(q2_weekLowObj)
        line.delete(q2_weekLowObj)
        q2_weekLowObj := na
    if not na(q2_prevDayHighObj)
        line.delete(q2_prevDayHighObj)
        q2_prevDayHighObj := na
    if not na(q2_prevDayLowObj)
        line.delete(q2_prevDayLowObj)
        q2_prevDayLowObj := na
    q2_prevDayHighActive := false
    q2_prevDayLowActive := false

//====================================================
// VWAP time-balance labels
//====================================================
q2_statPad = math.max(q2_atr14 * 0.35, syminfo.mintick * 30)
q2_statLabelBg = color.new(color.rgb(55, 60, 70), 10)
q2_statLabelText = color.white

var label q2_biasLabel1 = na
var label q2_biasLabel2 = na
var label q2_biasLabel3 = na
var table q2_dailyBiasTable = table.new(position.top_right, 1, 4, border_width = 1)

var int q2_bias1HighCount = 0
var int q2_bias1MidCount = 0
var int q2_bias1LowCount = 0
var int q2_bias2HighCount = 0
var int q2_bias2MidCount = 0
var int q2_bias2LowCount = 0
var int q2_bias3HighCount = 0
var int q2_bias3MidCount = 0
var int q2_bias3LowCount = 0

var float q2_bias1HighPctLast = 0.0
var float q2_bias1MidPctLast = 0.0
var float q2_bias1LowPctLast = 0.0
var float q2_bias2HighPctLast = 0.0
var float q2_bias2MidPctLast = 0.0
var float q2_bias2LowPctLast = 0.0
var float q2_bias3HighPctLast = 0.0
var float q2_bias3MidPctLast = 0.0
var float q2_bias3LowPctLast = 0.0

var int q2_biasDir1 = 0
var int q2_biasDir2 = 0
var int q2_biasDir3 = 0

var float q2_biasHigh1 = na
var float q2_biasHigh2 = na
var float q2_biasHigh3 = na

q2_nyHour   = hour(time, q2_macroTimezone)
q2_nyMinute = minute(time, q2_macroTimezone)
q2_nyTotal  = q2_nyHour * 60 + q2_nyMinute

q2_bias1StartMin = 9 * 60 + 30
q2_bias1EndMin   = 10 * 60 + 30
q2_bias2StartMin = 10 * 60 + 30
q2_bias2EndMin   = 13 * 60
q2_bias3StartMin = 13 * 60
q2_bias3EndMin   = 16 * 60 + 15

q2_inBias1 = q2_nyTotal >= q2_bias1StartMin and q2_nyTotal < q2_bias1EndMin
q2_inBias2 = q2_nyTotal >= q2_bias2StartMin and q2_nyTotal < q2_bias2EndMin
q2_inBias3 = q2_nyTotal >= q2_bias3StartMin and q2_nyTotal < q2_bias3EndMin

q2_prevInBias1 = barstate.isfirst ? false : q2_inBias1[1]
q2_prevInBias2 = barstate.isfirst ? false : q2_inBias2[1]
q2_prevInBias3 = barstate.isfirst ? false : q2_inBias3[1]

q2_bias1StartBar = q2_inBias1 and not q2_prevInBias1
q2_bias2StartBar = q2_inBias2 and not q2_prevInBias2
q2_bias3StartBar = q2_inBias3 and not q2_prevInBias3

q2_bias1EndTs = q2_f_dayTs(10, 30)
q2_bias2EndTs = q2_f_dayTs(13, 0)
q2_bias3EndTs = q2_f_dayTs(16, 15)

if q2_bias1StartBar
    q2_bias1HighCount := 0
    q2_bias1MidCount := 0
    q2_bias1LowCount := 0
    q2_bias1HighPctLast := 0.0
    q2_bias1MidPctLast := 0.0
    q2_bias1LowPctLast := 0.0
    q2_biasDir1 := 0
    q2_biasHigh1 := high
    if not na(q2_biasLabel1)
        label.delete(q2_biasLabel1)
        q2_biasLabel1 := na

if not na(q2_vwap) and q2_inBias1
    q2_biasHigh1 := na(q2_biasHigh1) ? high : math.max(q2_biasHigh1, high)
    bool q2_bias1HighZone = close > q2_upperBand1
    bool q2_bias1LowZone = close < q2_lowerBand1
    bool q2_bias1MidZone = close <= q2_upperBand1 and close >= q2_lowerBand1
    if q2_bias1HighZone
        q2_bias1HighCount += 1
    else if q2_bias1LowZone
        q2_bias1LowCount += 1
    else if q2_bias1MidZone
        q2_bias1MidCount += 1
    float q2_bias1Total = q2_bias1HighCount + q2_bias1MidCount + q2_bias1LowCount
    q2_bias1HighPctLast := q2_f_pct(q2_bias1HighCount, q2_bias1Total)
    q2_bias1MidPctLast := q2_f_pct(q2_bias1MidCount, q2_bias1Total)
    q2_bias1LowPctLast := q2_f_pct(q2_bias1LowCount, q2_bias1Total)
    q2_biasDir1 := q2_bias1HighPctLast > q2_bias1LowPctLast ? 1 : q2_bias1LowPctLast > q2_bias1HighPctLast ? -1 : 0
    if q2_showBiasLabelsModule
        if na(q2_biasLabel1)
            q2_biasLabel1 := label.new(x = q2_bias1EndTs, y = q2_biasHigh1 + q2_statPad, xloc = xloc.bar_time, text = q2_f_biasText("09:30-10:30 NY", q2_bias1HighPctLast, q2_bias1MidPctLast, q2_bias1LowPctLast, q2_biasDir1), style = label.style_label_down, color = q2_statLabelBg, textcolor = q2_statLabelText, size = size.small)
        else
            label.set_x(q2_biasLabel1, q2_bias1EndTs)
            label.set_y(q2_biasLabel1, q2_biasHigh1 + q2_statPad)
            label.set_text(q2_biasLabel1, q2_f_biasText("09:30-10:30 NY", q2_bias1HighPctLast, q2_bias1MidPctLast, q2_bias1LowPctLast, q2_biasDir1))
    else
        if not na(q2_biasLabel1)
            label.delete(q2_biasLabel1)
            q2_biasLabel1 := na

if q2_bias2StartBar
    q2_bias2HighCount := 0
    q2_bias2MidCount := 0
    q2_bias2LowCount := 0
    q2_bias2HighPctLast := 0.0
    q2_bias2MidPctLast := 0.0
    q2_bias2LowPctLast := 0.0
    q2_biasDir2 := 0
    q2_biasHigh2 := high
    if not na(q2_biasLabel2)
        label.delete(q2_biasLabel2)
        q2_biasLabel2 := na

if not na(q2_vwap) and q2_inBias2
    q2_biasHigh2 := na(q2_biasHigh2) ? high : math.max(q2_biasHigh2, high)
    bool q2_bias2HighZone = close > q2_upperBand1
    bool q2_bias2LowZone = close < q2_lowerBand1
    bool q2_bias2MidZone = close <= q2_upperBand1 and close >= q2_lowerBand1
    if q2_bias2HighZone
        q2_bias2HighCount += 1
    else if q2_bias2LowZone
        q2_bias2LowCount += 1
    else if q2_bias2MidZone
        q2_bias2MidCount += 1
    float q2_bias2Total = q2_bias2HighCount + q2_bias2MidCount + q2_bias2LowCount
    q2_bias2HighPctLast := q2_f_pct(q2_bias2HighCount, q2_bias2Total)
    q2_bias2MidPctLast := q2_f_pct(q2_bias2MidCount, q2_bias2Total)
    q2_bias2LowPctLast := q2_f_pct(q2_bias2LowCount, q2_bias2Total)
    q2_biasDir2 := q2_bias2HighPctLast > q2_bias2LowPctLast ? 1 : q2_bias2LowPctLast > q2_bias2HighPctLast ? -1 : 0
    if q2_showBiasLabelsModule
        if na(q2_biasLabel2)
            q2_biasLabel2 := label.new(x = q2_bias2EndTs, y = q2_biasHigh2 + q2_statPad, xloc = xloc.bar_time, text = q2_f_biasText("10:30-13:00 NY", q2_bias2HighPctLast, q2_bias2MidPctLast, q2_bias2LowPctLast, q2_biasDir2), style = label.style_label_down, color = q2_statLabelBg, textcolor = q2_statLabelText, size = size.small)
        else
            label.set_x(q2_biasLabel2, q2_bias2EndTs)
            label.set_y(q2_biasLabel2, q2_biasHigh2 + q2_statPad)
            label.set_text(q2_biasLabel2, q2_f_biasText("10:30-13:00 NY", q2_bias2HighPctLast, q2_bias2MidPctLast, q2_bias2LowPctLast, q2_biasDir2))
    else
        if not na(q2_biasLabel2)
            label.delete(q2_biasLabel2)
            q2_biasLabel2 := na

if q2_bias3StartBar
    q2_bias3HighCount := 0
    q2_bias3MidCount := 0
    q2_bias3LowCount := 0
    q2_bias3HighPctLast := 0.0
    q2_bias3MidPctLast := 0.0
    q2_bias3LowPctLast := 0.0
    q2_biasDir3 := 0
    q2_biasHigh3 := high
    if not na(q2_biasLabel3)
        label.delete(q2_biasLabel3)
        q2_biasLabel3 := na

if not na(q2_vwap) and q2_inBias3
    q2_biasHigh3 := na(q2_biasHigh3) ? high : math.max(q2_biasHigh3, high)
    bool q2_bias3HighZone = close > q2_upperBand1
    bool q2_bias3LowZone = close < q2_lowerBand1
    bool q2_bias3MidZone = close <= q2_upperBand1 and close >= q2_lowerBand1
    if q2_bias3HighZone
        q2_bias3HighCount += 1
    else if q2_bias3LowZone
        q2_bias3LowCount += 1
    else if q2_bias3MidZone
        q2_bias3MidCount += 1
    float q2_bias3Total = q2_bias3HighCount + q2_bias3MidCount + q2_bias3LowCount
    q2_bias3HighPctLast := q2_f_pct(q2_bias3HighCount, q2_bias3Total)
    q2_bias3MidPctLast := q2_f_pct(q2_bias3MidCount, q2_bias3Total)
    q2_bias3LowPctLast := q2_f_pct(q2_bias3LowCount, q2_bias3Total)
    q2_biasDir3 := q2_bias3HighPctLast > q2_bias3LowPctLast ? 1 : q2_bias3LowPctLast > q2_bias3HighPctLast ? -1 : 0
    if q2_showBiasLabelsModule
        if na(q2_biasLabel3)
            q2_biasLabel3 := label.new(x = q2_bias3EndTs, y = q2_biasHigh3 + q2_statPad, xloc = xloc.bar_time, text = q2_f_biasText("13:00-16:15 NY", q2_bias3HighPctLast, q2_bias3MidPctLast, q2_bias3LowPctLast, q2_biasDir3), style = label.style_label_down, color = q2_statLabelBg, textcolor = q2_statLabelText, size = size.small)
        else
            label.set_x(q2_biasLabel3, q2_bias3EndTs)
            label.set_y(q2_biasLabel3, q2_biasHigh3 + q2_statPad)
            label.set_text(q2_biasLabel3, q2_f_biasText("13:00-16:15 NY", q2_bias3HighPctLast, q2_bias3MidPctLast, q2_bias3LowPctLast, q2_biasDir3))
    else
        if not na(q2_biasLabel3)
            label.delete(q2_biasLabel3)
            q2_biasLabel3 := na

if not q2_showBiasLabelsModule
    if not na(q2_biasLabel1)
        label.delete(q2_biasLabel1)
        q2_biasLabel1 := na
    if not na(q2_biasLabel2)
        label.delete(q2_biasLabel2)
        q2_biasLabel2 := na
    if not na(q2_biasLabel3)
        label.delete(q2_biasLabel3)
        q2_biasLabel3 := na

var int q2_dailyAboveSessionCount = 0
var int q2_dailyBelowSessionCount = 0

if q2_newAnchor
    q2_dailyAboveSessionCount := 0
    q2_dailyBelowSessionCount := 0

if q2_showDailyBiasTableModule and not na(q2_vwap)
    if close >= q2_vwap
        q2_dailyAboveSessionCount += 1
    else
        q2_dailyBelowSessionCount += 1

float q2_dailyTotal = q2_dailyAboveSessionCount + q2_dailyBelowSessionCount
float q2_dailyAbovePct = q2_f_pct(q2_dailyAboveSessionCount, q2_dailyTotal)
float q2_dailyBelowPct = q2_f_pct(q2_dailyBelowSessionCount, q2_dailyTotal)
int q2_dailyBiasDir = q2_dailyAbovePct > q2_dailyBelowPct ? 1 : q2_dailyBelowPct > q2_dailyAbovePct ? -1 : 0
q2_dailyBiasTableTextSize = q2_f_tableTextSize(q2_dailyBiasTableSizeS)

if q2_showDailyBiasTableModule
    table.cell(q2_dailyBiasTable, 0, 0, "DAILY BIAS", text_color = color.white, text_size = q2_dailyBiasTableTextSize, bgcolor = color.new(color.rgb(55, 60, 70), 5))
    table.cell(q2_dailyBiasTable, 0, 1, "🟩 Above VWAP: " + str.tostring(q2_dailyAbovePct, "#.0") + "%", text_color = color.white, text_size = q2_dailyBiasTableTextSize, bgcolor = color.new(color.green, 35))
    table.cell(q2_dailyBiasTable, 0, 2, "🟥 Below VWAP: " + str.tostring(q2_dailyBelowPct, "#.0") + "%", text_color = color.white, text_size = q2_dailyBiasTableTextSize, bgcolor = color.new(color.red, 35))
    table.cell(q2_dailyBiasTable, 0, 3, q2_f_biasStateText(q2_dailyBiasDir), text_color = color.white, text_size = q2_dailyBiasTableTextSize, bgcolor = q2_dailyBiasDir == 1 ? color.new(color.green, 20) : q2_dailyBiasDir == -1 ? color.new(color.red, 20) : color.new(color.gray, 20))
else
    table.clear(q2_dailyBiasTable, 0, 0, 0, 3)

//====================================================
// Latest Daily FVG only
//====================================================
q2_dBullCreateTs = request.security(syminfo.tickerid, "D", ta.valuewhen(low[1] > high[3], time[1], 0), lookahead = barmerge.lookahead_off)
q2_dBullLeftTs   = request.security(syminfo.tickerid, "D", ta.valuewhen(low[1] > high[3], time[3], 0), lookahead = barmerge.lookahead_off)
q2_dBullTop      = request.security(syminfo.tickerid, "D", ta.valuewhen(low[1] > high[3], low[1], 0), lookahead = barmerge.lookahead_off)
q2_dBullBot      = request.security(syminfo.tickerid, "D", ta.valuewhen(low[1] > high[3], high[3], 0), lookahead = barmerge.lookahead_off)

q2_dBearCreateTs = request.security(syminfo.tickerid, "D", ta.valuewhen(high[1] < low[3], time[1], 0), lookahead = barmerge.lookahead_off)
q2_dBearLeftTs   = request.security(syminfo.tickerid, "D", ta.valuewhen(high[1] < low[3], time[3], 0), lookahead = barmerge.lookahead_off)
q2_dBearTop      = request.security(syminfo.tickerid, "D", ta.valuewhen(high[1] < low[3], low[3], 0), lookahead = barmerge.lookahead_off)
q2_dBearBot      = request.security(syminfo.tickerid, "D", ta.valuewhen(high[1] < low[3], high[1], 0), lookahead = barmerge.lookahead_off)

int q2_latestDailyFvgDir = na(q2_dBullCreateTs) and na(q2_dBearCreateTs) ? 0 : na(q2_dBearCreateTs) ? 1 : na(q2_dBullCreateTs) ? -1 : q2_dBullCreateTs >= q2_dBearCreateTs ? 1 : -1
int q2_latestDailyFvgCreateTs = q2_latestDailyFvgDir == 1 ? q2_dBullCreateTs : q2_latestDailyFvgDir == -1 ? q2_dBearCreateTs : na
int q2_latestDailyFvgLeftTs   = q2_latestDailyFvgDir == 1 ? q2_dBullLeftTs   : q2_latestDailyFvgDir == -1 ? q2_dBearLeftTs   : na
float q2_latestDailyFvgTop    = q2_latestDailyFvgDir == 1 ? q2_dBullTop      : q2_latestDailyFvgDir == -1 ? q2_dBearTop      : na
float q2_latestDailyFvgBot    = q2_latestDailyFvgDir == 1 ? q2_dBullBot      : q2_latestDailyFvgDir == -1 ? q2_dBearBot      : na

var box q2_dailyFvgBox = na
var label q2_lblDailyFVG = na
var int q2_dailyFvgLastCreateTs = na

if not q2_showDailyFVGModule
    if not na(q2_dailyFvgBox)
        box.delete(q2_dailyFvgBox)
        q2_dailyFvgBox := na
    q2_dailyFvgLastCreateTs := na
else
    bool q2_dailyFvgChanged = q2_latestDailyFvgDir != 0 and (na(q2_dailyFvgLastCreateTs) or q2_latestDailyFvgCreateTs != q2_dailyFvgLastCreateTs)
    if q2_dailyFvgChanged
        if not na(q2_dailyFvgBox)
            box.delete(q2_dailyFvgBox)
        q2_dailyFvgBox := box.new(left = q2_latestDailyFvgLeftTs, top = q2_latestDailyFvgTop, right = time, bottom = q2_latestDailyFvgBot, xloc = xloc.bar_time, bgcolor = q2_latestDailyFvgDir == 1 ? q2_dailyFvgBullFill : q2_dailyFvgBearFill, border_color = q2_latestDailyFvgDir == 1 ? q2_dailyFvgBullBorder : q2_dailyFvgBearBorder, border_width = q2_dailyFvgBorderWidth)
        box.set_border_style(q2_dailyFvgBox, q2_f_lineStyle(q2_dailyFvgBorderStyleS))
        q2_dailyFvgLastCreateTs := q2_latestDailyFvgCreateTs
    else if not na(q2_dailyFvgBox) and q2_latestDailyFvgDir != 0
        box.set_left(q2_dailyFvgBox, q2_latestDailyFvgLeftTs)
        box.set_right(q2_dailyFvgBox, time)
        box.set_top(q2_dailyFvgBox, q2_latestDailyFvgTop)
        box.set_bottom(q2_dailyFvgBox, q2_latestDailyFvgBot)
        box.set_bgcolor(q2_dailyFvgBox, q2_latestDailyFvgDir == 1 ? q2_dailyFvgBullFill : q2_dailyFvgBearFill)
        box.set_border_color(q2_dailyFvgBox, q2_latestDailyFvgDir == 1 ? q2_dailyFvgBullBorder : q2_dailyFvgBearBorder)
        box.set_border_width(q2_dailyFvgBox, q2_dailyFvgBorderWidth)
        box.set_border_style(q2_dailyFvgBox, q2_f_lineStyle(q2_dailyFvgBorderStyleS))

if q2_showDailyFVGModule and not na(q2_dailyFvgBox) and q2_latestDailyFvgDir != 0
    if na(q2_lblDailyFVG)
        q2_lblDailyFVG := label.new(x = q2_f_rightLabelX(), y = (q2_latestDailyFvgTop + q2_latestDailyFvgBot) * 0.5, xloc = xloc.bar_time, text = "DAILY FVG", style = label.style_none, textcolor = q2_latestDailyFvgDir == 1 ? q2_dailyFvgBullBorder : q2_dailyFvgBearBorder, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblDailyFVG, q2_f_rightLabelX())
        label.set_y(q2_lblDailyFVG, (q2_latestDailyFvgTop + q2_latestDailyFvgBot) * 0.5)
        label.set_text(q2_lblDailyFVG, "DAILY FVG")
        label.set_textcolor(q2_lblDailyFVG, q2_latestDailyFvgDir == 1 ? q2_dailyFvgBullBorder : q2_dailyFvgBearBorder)
        label.set_textalign(q2_lblDailyFVG, text.align_left)
else
    if not na(q2_lblDailyFVG)
        label.delete(q2_lblDailyFVG)
        q2_lblDailyFVG := na

//====================================================
// NY Session H/L (09:30-16:15 NY) visible until 00:00
//====================================================
q2_nySessionStartMin = 9 * 60 + 30
q2_nySessionEndMin   = 16 * 60 + 15

q2_inNYSession = q2_nyTotal >= q2_nySessionStartMin and q2_nyTotal < q2_nySessionEndMin
q2_prevInNYSession = barstate.isfirst ? false : q2_inNYSession[1]
q2_nySessionStartBar = q2_inNYSession and not q2_prevInNYSession
q2_nySessionEndBar   = not q2_inNYSession and q2_prevInNYSession

q2_nySessionStartTs = q2_f_dayTs(9, 30)
q2_nySessionExpireTs = q2_f_nextMidnightTs()

var line q2_activeNySessionHighLine = na
var line q2_activeNySessionLowLine  = na
var float q2_activeNySessionHigh    = na
var float q2_activeNySessionLow     = na
var line[] q2_nySessionHighLines    = array.new_line()
var line[] q2_nySessionLowLines     = array.new_line()
var int[]  q2_nySessionExpireArr    = array.new_int()

if q2_showNYSessionHLModule and q2_nySessionStartBar
    q2_activeNySessionHigh := high
    q2_activeNySessionLow  := low
    q2_activeNySessionHighLine := line.new(x1 = q2_nySessionStartTs, y1 = q2_activeNySessionHigh, x2 = time, y2 = q2_activeNySessionHigh, xloc = xloc.bar_time, color = q2_nySessionHLColor, width = q2_nySessionHLWidth)
    q2_activeNySessionLowLine  := line.new(x1 = q2_nySessionStartTs, y1 = q2_activeNySessionLow,  x2 = time, y2 = q2_activeNySessionLow,  xloc = xloc.bar_time, color = q2_nySessionHLColor, width = q2_nySessionHLWidth)
    line.set_style(q2_activeNySessionHighLine, q2_f_lineStyle(q2_nySessionHLStyleS))
    line.set_style(q2_activeNySessionLowLine,  q2_f_lineStyle(q2_nySessionHLStyleS))
    array.push(q2_nySessionHighLines, q2_activeNySessionHighLine)
    array.push(q2_nySessionLowLines, q2_activeNySessionLowLine)
    array.push(q2_nySessionExpireArr, q2_nySessionExpireTs)
else if q2_nySessionStartBar
    q2_activeNySessionHigh := na
    q2_activeNySessionLow  := na
    q2_activeNySessionHighLine := na
    q2_activeNySessionLowLine  := na

if q2_showNYSessionHLModule and q2_inNYSession and not na(q2_activeNySessionHighLine) and not na(q2_activeNySessionLowLine)
    q2_activeNySessionHigh := na(q2_activeNySessionHigh) ? high : math.max(q2_activeNySessionHigh, high)
    q2_activeNySessionLow  := na(q2_activeNySessionLow)  ? low  : math.min(q2_activeNySessionLow, low)
    line.set_x2(q2_activeNySessionHighLine, time)
    line.set_y1(q2_activeNySessionHighLine, q2_activeNySessionHigh)
    line.set_y2(q2_activeNySessionHighLine, q2_activeNySessionHigh)
    line.set_x2(q2_activeNySessionLowLine, time)
    line.set_y1(q2_activeNySessionLowLine, q2_activeNySessionLow)
    line.set_y2(q2_activeNySessionLowLine, q2_activeNySessionLow)

if q2_nySessionEndBar
    q2_activeNySessionHigh := na
    q2_activeNySessionLow  := na
    q2_activeNySessionHighLine := na
    q2_activeNySessionLowLine  := na

if not q2_showNYSessionHLModule and array.size(q2_nySessionHighLines) > 0
    int q2_nyOffIdx = array.size(q2_nySessionHighLines) - 1
    while q2_nyOffIdx >= 0
        line.delete(array.get(q2_nySessionHighLines, q2_nyOffIdx))
        line.delete(array.get(q2_nySessionLowLines, q2_nyOffIdx))
        array.remove(q2_nySessionHighLines, q2_nyOffIdx)
        array.remove(q2_nySessionLowLines, q2_nyOffIdx)
        array.remove(q2_nySessionExpireArr, q2_nyOffIdx)
        q2_nyOffIdx -= 1
    q2_activeNySessionHigh := na
    q2_activeNySessionLow  := na
    q2_activeNySessionHighLine := na
    q2_activeNySessionLowLine  := na

if array.size(q2_nySessionHighLines) > 0
    int q2_nyIdx = array.size(q2_nySessionHighLines) - 1
    while q2_nyIdx >= 0
        line q2_nyHi = array.get(q2_nySessionHighLines, q2_nyIdx)
        line q2_nyLo = array.get(q2_nySessionLowLines, q2_nyIdx)
        int q2_nyExpire = array.get(q2_nySessionExpireArr, q2_nyIdx)
        if time > q2_nyExpire
            line.delete(q2_nyHi)
            line.delete(q2_nyLo)
            array.remove(q2_nySessionHighLines, q2_nyIdx)
            array.remove(q2_nySessionLowLines, q2_nyIdx)
            array.remove(q2_nySessionExpireArr, q2_nyIdx)
        else
            line.set_x2(q2_nyHi, time)
            line.set_x2(q2_nyLo, time)
            line.set_color(q2_nyHi, q2_nySessionHLColor)
            line.set_color(q2_nyLo, q2_nySessionHLColor)
            line.set_width(q2_nyHi, q2_nySessionHLWidth)
            line.set_width(q2_nyLo, q2_nySessionHLWidth)
            line.set_style(q2_nyHi, q2_f_lineStyle(q2_nySessionHLStyleS))
            line.set_style(q2_nyLo, q2_f_lineStyle(q2_nySessionHLStyleS))
        q2_nyIdx -= 1

//====================================================
// Movement High/Low lines
//====================================================
float q2_pivotHigh = ta.pivothigh(high, q2_movePivotLen, q2_movePivotLen)
float q2_pivotLow = ta.pivotlow(low, q2_movePivotLen, q2_movePivotLen)

var line[]  q2_moveHighLines      = array.new_line()
var line[]  q2_moveLowLines       = array.new_line()
var float[] q2_moveHighPrices     = array.new_float()
var float[] q2_moveLowPrices      = array.new_float()
var int[]   q2_moveHighCreateBars = array.new_int()
var int[]   q2_moveLowCreateBars  = array.new_int()
var bool[]  q2_moveHighActive     = array.new_bool()
var bool[]  q2_moveLowActive      = array.new_bool()

if q2_showMoveHLModule and not na(q2_pivotHigh)
    float q2_phPrice = q2_pivotHigh
    int q2_phTs = time[q2_movePivotLen]
    line q2_hiLine = line.new(x1 = q2_phTs, y1 = q2_phPrice, x2 = time, y2 = q2_phPrice, xloc = xloc.bar_time, color = q2_moveHighColor, width = q2_moveLineWidth)
    line.set_style(q2_hiLine, q2_f_lineStyle(q2_moveLineStyleS))
    array.push(q2_moveHighLines, q2_hiLine)
    array.push(q2_moveHighPrices, q2_phPrice)
    array.push(q2_moveHighCreateBars, bar_index)
    array.push(q2_moveHighActive, true)

if q2_showMoveHLModule and not na(q2_pivotLow)
    float q2_plPrice = q2_pivotLow
    int q2_plTs = time[q2_movePivotLen]
    line q2_loLine = line.new(x1 = q2_plTs, y1 = q2_plPrice, x2 = time, y2 = q2_plPrice, xloc = xloc.bar_time, color = q2_moveLowColor, width = q2_moveLineWidth)
    line.set_style(q2_loLine, q2_f_lineStyle(q2_moveLineStyleS))
    array.push(q2_moveLowLines, q2_loLine)
    array.push(q2_moveLowPrices, q2_plPrice)
    array.push(q2_moveLowCreateBars, bar_index)
    array.push(q2_moveLowActive, true)

if not q2_showMoveHLModule
    if array.size(q2_moveHighLines) > 0
        int q2_hiIdxDel = array.size(q2_moveHighLines) - 1
        while q2_hiIdxDel >= 0
            line.delete(array.get(q2_moveHighLines, q2_hiIdxDel))
            q2_hiIdxDel -= 1
        array.clear(q2_moveHighLines)
        array.clear(q2_moveHighPrices)
        array.clear(q2_moveHighCreateBars)
        array.clear(q2_moveHighActive)
    if array.size(q2_moveLowLines) > 0
        int q2_loIdxDel = array.size(q2_moveLowLines) - 1
        while q2_loIdxDel >= 0
            line.delete(array.get(q2_moveLowLines, q2_loIdxDel))
            q2_loIdxDel -= 1
        array.clear(q2_moveLowLines)
        array.clear(q2_moveLowPrices)
        array.clear(q2_moveLowCreateBars)
        array.clear(q2_moveLowActive)
else
    if array.size(q2_moveHighLines) > 0
        int q2_hiIdx = array.size(q2_moveHighLines) - 1
        while q2_hiIdx >= 0
            line q2_hiLine = array.get(q2_moveHighLines, q2_hiIdx)
            float q2_hiPrice = array.get(q2_moveHighPrices, q2_hiIdx)
            int q2_hiCreateBar = array.get(q2_moveHighCreateBars, q2_hiIdx)
            bool q2_hiIsActive = array.get(q2_moveHighActive, q2_hiIdx)
            if q2_hiIsActive
                bool q2_hiTouched = bar_index > q2_hiCreateBar and high >= q2_hiPrice and low <= q2_hiPrice
                line.set_x2(q2_hiLine, time)
                line.set_y1(q2_hiLine, q2_hiPrice)
                line.set_y2(q2_hiLine, q2_hiPrice)
                line.set_color(q2_hiLine, q2_moveHighColor)
                line.set_width(q2_hiLine, q2_moveLineWidth)
                line.set_style(q2_hiLine, q2_f_lineStyle(q2_moveLineStyleS))
                if q2_hiTouched
                    array.set(q2_moveHighActive, q2_hiIdx, false)
            q2_hiIdx -= 1

    if array.size(q2_moveLowLines) > 0
        int q2_loIdx = array.size(q2_moveLowLines) - 1
        while q2_loIdx >= 0
            line q2_loLine = array.get(q2_moveLowLines, q2_loIdx)
            float q2_loPrice = array.get(q2_moveLowPrices, q2_loIdx)
            int q2_loCreateBar = array.get(q2_moveLowCreateBars, q2_loIdx)
            bool q2_loIsActive = array.get(q2_moveLowActive, q2_loIdx)
            if q2_loIsActive
                bool q2_loTouched = bar_index > q2_loCreateBar and high >= q2_loPrice and low <= q2_loPrice
                line.set_x2(q2_loLine, time)
                line.set_y1(q2_loLine, q2_loPrice)
                line.set_y2(q2_loLine, q2_loPrice)
                line.set_color(q2_loLine, q2_moveLowColor)
                line.set_width(q2_loLine, q2_moveLineWidth)
                line.set_style(q2_loLine, q2_f_lineStyle(q2_moveLineStyleS))
                if q2_loTouched
                    array.set(q2_moveLowActive, q2_loIdx, false)
            q2_loIdx -= 1

//====================================================
// Right-side labels
//====================================================
var label q2_lblNy930VWAP = na
var label q2_lblNy930U1   = na
var label q2_lblNy930U2   = na
var label q2_lblNy930U3   = na
var label q2_lblNy930L1   = na
var label q2_lblNy930L2   = na
var label q2_lblNy930L3   = na
var label q2_lblWeekHigh  = na
var label q2_lblWeekLow   = na
var label q2_lblDayHigh   = na
var label q2_lblDayLow    = na
var label q2_lblNyHigh    = na
var label q2_lblNyLow     = na

if q2_showNY930VWAPModule and q2_inNY930Window and not na(q2_plotNy930Vwap)
    if na(q2_lblNy930VWAP)
        q2_lblNy930VWAP := label.new(x = q2_f_rightLabelX(), y = q2_plotNy930Vwap, xloc = xloc.bar_time, text = "NY VWAP", style = label.style_none, textcolor = q2_ny930VwapColor, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNy930VWAP, q2_f_rightLabelX())
        label.set_y(q2_lblNy930VWAP, q2_plotNy930Vwap)
        label.set_text(q2_lblNy930VWAP, "NY VWAP")
        label.set_textcolor(q2_lblNy930VWAP, q2_ny930VwapColor)
        label.set_textalign(q2_lblNy930VWAP, text.align_left)
else
    if not na(q2_lblNy930VWAP)
        label.delete(q2_lblNy930VWAP)
        q2_lblNy930VWAP := na

if q2_showNY930VWAPModule and q2_inNY930Window and not na(q2_plotNy930Upper1)
    if na(q2_lblNy930U1)
        q2_lblNy930U1 := label.new(x = q2_f_rightLabelX(), y = q2_plotNy930Upper1, xloc = xloc.bar_time, text = "NY +1", style = label.style_none, textcolor = q2_ny930Upper1Color, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNy930U1, q2_f_rightLabelX())
        label.set_y(q2_lblNy930U1, q2_plotNy930Upper1)
        label.set_text(q2_lblNy930U1, "NY +1")
        label.set_textcolor(q2_lblNy930U1, q2_ny930Upper1Color)
        label.set_textalign(q2_lblNy930U1, text.align_left)
else
    if not na(q2_lblNy930U1)
        label.delete(q2_lblNy930U1)
        q2_lblNy930U1 := na

if q2_showNY930VWAPModule and q2_inNY930Window and not na(q2_plotNy930Upper2)
    if na(q2_lblNy930U2)
        q2_lblNy930U2 := label.new(x = q2_f_rightLabelX(), y = q2_plotNy930Upper2, xloc = xloc.bar_time, text = "NY +2", style = label.style_none, textcolor = q2_ny930Upper2Color, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNy930U2, q2_f_rightLabelX())
        label.set_y(q2_lblNy930U2, q2_plotNy930Upper2)
        label.set_text(q2_lblNy930U2, "NY +2")
        label.set_textcolor(q2_lblNy930U2, q2_ny930Upper2Color)
        label.set_textalign(q2_lblNy930U2, text.align_left)
else
    if not na(q2_lblNy930U2)
        label.delete(q2_lblNy930U2)
        q2_lblNy930U2 := na

if q2_showNY930VWAPModule and q2_inNY930Window and not na(q2_plotNy930Upper3)
    if na(q2_lblNy930U3)
        q2_lblNy930U3 := label.new(x = q2_f_rightLabelX(), y = q2_plotNy930Upper3, xloc = xloc.bar_time, text = "NY +3", style = label.style_none, textcolor = q2_ny930Upper3Color, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNy930U3, q2_f_rightLabelX())
        label.set_y(q2_lblNy930U3, q2_plotNy930Upper3)
        label.set_text(q2_lblNy930U3, "NY +3")
        label.set_textcolor(q2_lblNy930U3, q2_ny930Upper3Color)
        label.set_textalign(q2_lblNy930U3, text.align_left)
else
    if not na(q2_lblNy930U3)
        label.delete(q2_lblNy930U3)
        q2_lblNy930U3 := na

if q2_showNY930VWAPModule and q2_inNY930Window and not na(q2_plotNy930Lower1)
    if na(q2_lblNy930L1)
        q2_lblNy930L1 := label.new(x = q2_f_rightLabelX(), y = q2_plotNy930Lower1, xloc = xloc.bar_time, text = "NY -1", style = label.style_none, textcolor = q2_ny930Lower1Color, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNy930L1, q2_f_rightLabelX())
        label.set_y(q2_lblNy930L1, q2_plotNy930Lower1)
        label.set_text(q2_lblNy930L1, "NY -1")
        label.set_textcolor(q2_lblNy930L1, q2_ny930Lower1Color)
        label.set_textalign(q2_lblNy930L1, text.align_left)
else
    if not na(q2_lblNy930L1)
        label.delete(q2_lblNy930L1)
        q2_lblNy930L1 := na

if q2_showNY930VWAPModule and q2_inNY930Window and not na(q2_plotNy930Lower2)
    if na(q2_lblNy930L2)
        q2_lblNy930L2 := label.new(x = q2_f_rightLabelX(), y = q2_plotNy930Lower2, xloc = xloc.bar_time, text = "NY -2", style = label.style_none, textcolor = q2_ny930Lower2Color, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNy930L2, q2_f_rightLabelX())
        label.set_y(q2_lblNy930L2, q2_plotNy930Lower2)
        label.set_text(q2_lblNy930L2, "NY -2")
        label.set_textcolor(q2_lblNy930L2, q2_ny930Lower2Color)
        label.set_textalign(q2_lblNy930L2, text.align_left)
else
    if not na(q2_lblNy930L2)
        label.delete(q2_lblNy930L2)
        q2_lblNy930L2 := na

if q2_showNY930VWAPModule and q2_inNY930Window and not na(q2_plotNy930Lower3)
    if na(q2_lblNy930L3)
        q2_lblNy930L3 := label.new(x = q2_f_rightLabelX(), y = q2_plotNy930Lower3, xloc = xloc.bar_time, text = "NY -3", style = label.style_none, textcolor = q2_ny930Lower3Color, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNy930L3, q2_f_rightLabelX())
        label.set_y(q2_lblNy930L3, q2_plotNy930Lower3)
        label.set_text(q2_lblNy930L3, "NY -3")
        label.set_textcolor(q2_lblNy930L3, q2_ny930Lower3Color)
        label.set_textalign(q2_lblNy930L3, text.align_left)
else
    if not na(q2_lblNy930L3)
        label.delete(q2_lblNy930L3)
        q2_lblNy930L3 := na

if not na(q2_weekHighObj)
    if na(q2_lblWeekHigh)
        q2_lblWeekHigh := label.new(x = q2_f_rightLabelX(), y = q2_weekHighLineVal, xloc = xloc.bar_time, text = "W HIGH", style = label.style_none, textcolor = q2_weeklyHLColor, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblWeekHigh, q2_f_rightLabelX())
        label.set_y(q2_lblWeekHigh, q2_weekHighLineVal)
        label.set_text(q2_lblWeekHigh, "W HIGH")
        label.set_textcolor(q2_lblWeekHigh, q2_weeklyHLColor)
        label.set_textalign(q2_lblWeekHigh, text.align_left)
else
    if not na(q2_lblWeekHigh)
        label.delete(q2_lblWeekHigh)
        q2_lblWeekHigh := na

if not na(q2_weekLowObj)
    if na(q2_lblWeekLow)
        q2_lblWeekLow := label.new(x = q2_f_rightLabelX(), y = q2_weekLowLineVal, xloc = xloc.bar_time, text = "W LOW", style = label.style_none, textcolor = q2_weeklyHLColor, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblWeekLow, q2_f_rightLabelX())
        label.set_y(q2_lblWeekLow, q2_weekLowLineVal)
        label.set_text(q2_lblWeekLow, "W LOW")
        label.set_textcolor(q2_lblWeekLow, q2_weeklyHLColor)
        label.set_textalign(q2_lblWeekLow, text.align_left)
else
    if not na(q2_lblWeekLow)
        label.delete(q2_lblWeekLow)
        q2_lblWeekLow := na

if q2_showDailyWeeklyHLModule and q2_prevDayHighActive and not na(q2_prevDayHighObj)
    if na(q2_lblDayHigh)
        q2_lblDayHigh := label.new(x = q2_f_rightLabelX(), y = q2_prevDayHighLineVal, xloc = xloc.bar_time, text = "D HIGH", style = label.style_none, textcolor = q2_dailyHLColor, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblDayHigh, q2_f_rightLabelX())
        label.set_y(q2_lblDayHigh, q2_prevDayHighLineVal)
        label.set_text(q2_lblDayHigh, "D HIGH")
        label.set_textcolor(q2_lblDayHigh, q2_dailyHLColor)
        label.set_textalign(q2_lblDayHigh, text.align_left)
else
    if not na(q2_lblDayHigh)
        label.delete(q2_lblDayHigh)
        q2_lblDayHigh := na

if q2_showDailyWeeklyHLModule and q2_prevDayLowActive and not na(q2_prevDayLowObj)
    if na(q2_lblDayLow)
        q2_lblDayLow := label.new(x = q2_f_rightLabelX(), y = q2_prevDayLowLineVal, xloc = xloc.bar_time, text = "D LOW", style = label.style_none, textcolor = q2_dailyHLColor, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblDayLow, q2_f_rightLabelX())
        label.set_y(q2_lblDayLow, q2_prevDayLowLineVal)
        label.set_text(q2_lblDayLow, "D LOW")
        label.set_textcolor(q2_lblDayLow, q2_dailyHLColor)
        label.set_textalign(q2_lblDayLow, text.align_left)
else
    if not na(q2_lblDayLow)
        label.delete(q2_lblDayLow)
        q2_lblDayLow := na

if not na(q2_activeNySessionHighLine)
    if na(q2_lblNyHigh)
        q2_lblNyHigh := label.new(x = q2_f_rightLabelX(), y = q2_activeNySessionHigh, xloc = xloc.bar_time, text = "NY HIGH", style = label.style_none, textcolor = q2_nySessionHLColor, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNyHigh, q2_f_rightLabelX())
        label.set_y(q2_lblNyHigh, q2_activeNySessionHigh)
        label.set_text(q2_lblNyHigh, "NY HIGH")
        label.set_textcolor(q2_lblNyHigh, q2_nySessionHLColor)
        label.set_textalign(q2_lblNyHigh, text.align_left)
else
    if not na(q2_lblNyHigh)
        label.delete(q2_lblNyHigh)
        q2_lblNyHigh := na

if not na(q2_activeNySessionLowLine)
    if na(q2_lblNyLow)
        q2_lblNyLow := label.new(x = q2_f_rightLabelX(), y = q2_activeNySessionLow, xloc = xloc.bar_time, text = "NY LOW", style = label.style_none, textcolor = q2_nySessionHLColor, size = q2_rightSideLabelSize)
    else
        label.set_x(q2_lblNyLow, q2_f_rightLabelX())
        label.set_y(q2_lblNyLow, q2_activeNySessionLow)
        label.set_text(q2_lblNyLow, "NY LOW")
        label.set_textcolor(q2_lblNyLow, q2_nySessionHLColor)
        label.set_textalign(q2_lblNyLow, text.align_left)
else
    if not na(q2_lblNyLow)
        label.delete(q2_lblNyLow)
        q2_lblNyLow := na

//====================================================
// Plots
//====================================================
q2_pNy930Upper3 = plot(q2_plotNy930Upper3Br, "09:30 Upper Band 3", color = q2_ny930Upper3Color, linewidth = q2_ny930Band3Width, style = plot.style_linebr)
q2_pNy930Upper2 = plot(q2_plotNy930Upper2Br, "09:30 Upper Band 2", color = q2_ny930Upper2Color, linewidth = q2_ny930Band2Width, style = plot.style_linebr)
q2_pNy930Upper1 = plot(q2_plotNy930Upper1Br, "09:30 Upper Band 1", color = q2_ny930Upper1Color, linewidth = q2_ny930Band1Width, style = plot.style_linebr)
q2_pNy930VWAP   = plot(q2_plotNy930VwapBr,   "09:30 VWAP",         color = q2_ny930VwapColor,  linewidth = q2_ny930VwapWidth,  style = plot.style_linebr)
q2_pNy930Lower1 = plot(q2_plotNy930Lower1Br, "09:30 Lower Band 1", color = q2_ny930Lower1Color, linewidth = q2_ny930Band1Width, style = plot.style_linebr)
q2_pNy930Lower2 = plot(q2_plotNy930Lower2Br, "09:30 Lower Band 2", color = q2_ny930Lower2Color, linewidth = q2_ny930Band2Width, style = plot.style_linebr)
q2_pNy930Lower3 = plot(q2_plotNy930Lower3Br, "09:30 Lower Band 3", color = q2_ny930Lower3Color, linewidth = q2_ny930Band3Width, style = plot.style_linebr)

//====================================================
// Big Trade Micro Pads v2
//====================================================
var label[] bt_allLabels = array.new_label()
var int[]   bt_allBars   = array.new_int()

bt_f_clamp(float v, float mn, float mx) =>
    math.max(mn, math.min(mx, v))

bt_f_round_to(float v, int dec) =>
    float p = math.pow(10.0, dec)
    math.round(v * p) / p

bt_f_fmt(float v, bool useK, int dec) =>
    float av = math.abs(v)
    string out = ""
    if useK and av >= 1000
        out := dec == 0 ? str.tostring(math.round(v / 1000.0)) + "K" : str.tostring(bt_f_round_to(v / 1000.0, dec)) + "K"
    else
        out := dec == 0 ? str.tostring(math.round(v)) : str.tostring(bt_f_round_to(v, dec))
    out

bt_f_addPad(int x, float y, string txt, color bg, color tc) =>
    label lb = label.new(
         x = x,
         y = y,
         text = txt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_center,
         color = color.new(bg, bt_padTransparency),
         textcolor = tc,
         size = size.tiny
     )
    array.push(bt_allLabels, lb)
    array.push(bt_allBars, x)

bt_f_cleanup_by_bar(int currentBar, int barsToKeep) =>
    while array.size(bt_allLabels) > 0 and currentBar - array.get(bt_allBars, 0) > barsToKeep
        label oldLb = array.shift(bt_allLabels)
        array.shift(bt_allBars)
        label.delete(oldLb)

bt_f_cleanup_by_count(int maxCount) =>
    while array.size(bt_allLabels) > maxCount
        label oldLb = array.shift(bt_allLabels)
        array.shift(bt_allBars)
        label.delete(oldLb)

bt_f_delete_all() =>
    while array.size(bt_allLabels) > 0
        label oldLb = array.shift(bt_allLabels)
        array.shift(bt_allBars)
        label.delete(oldLb)

bt_f_inside_anchor(bool isBuy, float o, float c, float h, float l, float topPct, float botPct, float mint, int fallbackTicks) =>
    float bodyTop = math.max(o, c)
    float bodyBot = math.min(o, c)
    float bodyH   = bodyTop - bodyBot
    float result  = na

    if bodyH > mint * 2.0
        result := isBuy ? bodyTop - bodyH * topPct : bodyBot + bodyH * botPct
    else
        result := isBuy ? h + fallbackTicks * mint : l - fallbackTicks * mint

    result

bt_f_print_side(bool isBuy, float sideVol, float firstY, color bgColor, color txtColor, float chunkSize, int maxCount, int shiftBars, int stepTicks, float mint, bool useK, int dec) =>
    int count = int(math.floor(sideVol / chunkSize))
    if count <= 0 and sideVol >= chunkSize * 0.88
        count := 1
    count := math.min(count, maxCount)

    if count > 0
        float remain = sideVol
        for i = 0 to count - 1
            bool isLast = i == count - 1
            float rawChunk = isLast ? remain : math.min(chunkSize, remain)
            remain -= rawChunk

            float y = isBuy ? firstY + i * stepTicks * mint : firstY - i * stepTicks * mint
            bt_f_addPad(bar_index + shiftBars, y, bt_f_fmt(rawChunk, useK, dec), bgColor, txtColor)

float bt_mint = syminfo.mintick
float bt_rng  = math.max(high - low, bt_mint)
float bt_body = math.abs(close - open)
float bt_bodyPct = bt_rng > 0 ? (bt_body / bt_rng) * 100.0 : 0.0

float bt_avgVol = ta.sma(volume, bt_autoLen)
float bt_threshold = bt_useAutoThreshold ? math.max(1.0, bt_avgVol * bt_autoMultiplier) : bt_manualThreshold

float bt_closePos = bt_f_clamp((close - low) / bt_rng, 0.0, 1.0)
float bt_buyVolRange  = volume * bt_closePos
float bt_sellVolRange = volume * (1.0 - bt_closePos)

float bt_bodySigned = bt_f_clamp((close - open) / bt_rng, -1.0, 1.0)
float bt_bodyBias   = bt_f_clamp((bt_bodySigned + 1.0) * 0.5, 0.0, 1.0)
float bt_buyVolBody  = volume * bt_bodyBias
float bt_sellVolBody = volume * (1.0 - bt_bodyBias)

float bt_buyBase  = bt_calcMode == "Close In Range" ? bt_buyVolRange  : bt_calcMode == "Body Pressure" ? bt_buyVolBody  : (bt_buyVolRange  + bt_buyVolBody)  * 0.5
float bt_sellBase = bt_calcMode == "Close In Range" ? bt_sellVolRange : bt_calcMode == "Body Pressure" ? bt_sellVolBody : (bt_sellVolRange + bt_sellVolBody) * 0.5

float bt_prevClose  = nz(close[1], close)
float bt_deltaClose = close - bt_prevClose
float bt_dirBoost   = bt_rng > 0 ? bt_f_clamp(bt_deltaClose / bt_rng, -1.0, 1.0) : 0.0
float bt_wickTop    = high - math.max(open, close)
float bt_wickBot    = math.min(open, close) - low
float bt_wickBias   = bt_rng > 0 ? bt_f_clamp((bt_wickBot - bt_wickTop) / bt_rng, -1.0, 1.0) : 0.0

float bt_flowBiasRaw   = bt_useBarFlowBoost ? bt_f_clamp(bt_dirBoost * 0.65 + bt_wickBias * 0.35, -1.0, 1.0) : 0.0
float bt_flowBuyBoost  = bt_f_clamp((bt_flowBiasRaw + 1.0) * 0.5, 0.0, 1.0)
float bt_flowSellBoost = 1.0 - bt_flowBuyBoost

float bt_buyVol  = bt_useBarFlowBoost ? (bt_buyBase  * 0.78 + volume * bt_flowBuyBoost  * 0.22) : bt_buyBase
float bt_sellVol = bt_useBarFlowBoost ? (bt_sellBase * 0.78 + volume * bt_flowSellBoost * 0.22) : bt_sellBase

float bt_dominance = volume > 0 ? math.abs(bt_buyVol - bt_sellVol) / volume * 100.0 : 0.0
float bt_buyDomPct  = volume > 0 ? bt_buyVol  / volume * 100.0 : 0.0
float bt_sellDomPct = volume > 0 ? bt_sellVol / volume * 100.0 : 0.0

bool bt_isBull = close > open
bool bt_isBear = close < open
bool bt_isDoji = close == open

bool bt_passBody = bt_bodyPct >= bt_minBodyPercent
bool bt_passDom  = bt_dominance >= bt_minDominancePercent

float bt_chunkSize = math.max(1.0, bt_threshold * bt_baseChunkFactor)

float bt_buyY  = bt_f_inside_anchor(true,  open, close, high, low, bt_insideTopPct, bt_insideBotPct, bt_mint, bt_fallbackOffsetTicks)
float bt_sellY = bt_f_inside_anchor(false, open, close, high, low, bt_insideTopPct, bt_insideBotPct, bt_mint, bt_fallbackOffsetTicks)

if not showBigTradeModule
    bt_f_delete_all()

if showBigTradeModule and barstate.isconfirmed
    bt_f_cleanup_by_bar(bar_index, bt_keepBarsBack)

    if bt_passBody and bt_passDom
        bool bt_allowBuyMain  = bt_isBull or bt_isDoji or not bt_strictCandleBias
        bool bt_allowSellMain = bt_isBear or bt_isDoji or not bt_strictCandleBias

        bool bt_buyStrongEnough  = bt_buyVol  >= bt_threshold
        bool bt_sellStrongEnough = bt_sellVol >= bt_threshold

        bool bt_allowBuyCounter  = bt_allowCounterPrints and bt_isBear and bt_buyStrongEnough  and bt_buyDomPct  >= bt_counterMinDominance
        bool bt_allowSellCounter = bt_allowCounterPrints and bt_isBull and bt_sellStrongEnough and bt_sellDomPct >= bt_counterMinDominance

        if bt_showBuy and bt_buyStrongEnough and (bt_allowBuyMain or bt_allowBuyCounter)
            bt_f_print_side(true, bt_buyVol, bt_buyY, bt_buyPadColor, bt_buyTextColor, bt_chunkSize, bt_maxPrintsPerSide, bt_horizontalShiftBars, bt_stackStepTicks, bt_mint, bt_showKFormat, bt_decimals)

        if bt_showSell and bt_sellStrongEnough and (bt_allowSellMain or bt_allowSellCounter)
            bt_f_print_side(false, bt_sellVol, bt_sellY, bt_sellPadColor, bt_sellTextColor, bt_chunkSize, bt_maxPrintsPerSide, bt_horizontalShiftBars, bt_stackStepTicks, bt_mint, bt_showKFormat, bt_decimals)

    bt_f_cleanup_by_count(500)


//====================================================
// NY 00:00 Line + Daily Volume Range + POC
//====================================================
//==================== Inputs ====================
dr_groupNYLine     = "New York 00:00 Line"
dr_groupDailyRange = "Daily Volume Range + POC"

dr_showNY0000Line    = input.bool(true, "Show NY 00:00 Line", group=dr_groupNYLine, inline="nyl0")
dr_ny0000LineColor   = input.color(color.new(#7fd7ff, 0), "Color", group=dr_groupNYLine, inline="nyl1")
dr_ny0000LineWidth   = input.int(1, "Width", minval=1, maxval=5, group=dr_groupNYLine, inline="nyl1")
dr_ny0000LineStyleIn = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=dr_groupNYLine, inline="nyl1")

dr_dailyDaysToShow         = input.int(7, "Days to show", minval=1, maxval=20, group=dr_groupDailyRange)
dr_dailyRows               = input.int(24, "POC row size", minval=5, maxval=100, group=dr_groupDailyRange)
dr_dailyRangeFillColor     = input.color(color.new(#2962ff, 92), "Range fill", group=dr_groupDailyRange, inline="dr1")
dr_dailyRangeBorderColor   = input.color(color.new(#b8bcc6, 0), "Border", group=dr_groupDailyRange, inline="dr1")
dr_dailyRangeBorderWidth   = input.int(1, "Width", minval=0, maxval=5, group=dr_groupDailyRange, inline="dr1")
dr_dailyRangeBorderStyleIn = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=dr_groupDailyRange, inline="dr1")

dr_dailyPocShow       = input.bool(true, "Show daily POC", group=dr_groupDailyRange, inline="drpoc")
dr_dailyPocColor      = input.color(color.new(#ffb74d, 0), "", group=dr_groupDailyRange, inline="drpoc")
dr_dailyPocWidth      = input.int(2, "", minval=1, maxval=5, group=dr_groupDailyRange, inline="drpoc")
dr_dailyPocStyleIn    = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=dr_groupDailyRange, inline="drpoc")
dr_dailyShowPocLabel  = input.bool(false, "POC label", group=dr_groupDailyRange)

//==================== Storage ====================
bool dr_intradayChart = timeframe.isintraday

var line[]  dr_ny0000Lines     = array.new_line()
var int     dr_lastNyLineStart = na

var box[]   dr_dailyDayBoxes   = array.new_box()
var line[]  dr_dailyRangeLines = array.new_line()
var line[]  dr_dailyPocLines   = array.new_line()
var label[] dr_dailyPocLabels  = array.new_label()

//==================== Helpers ====================
dr_borderStyleFromInput(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

dr_dailyGetVol(float y11, float y12, float y21, float y22, float height, float vol) =>
    nz(math.max(math.min(math.max(y11, y12), math.max(y21, y22)) - math.max(math.min(y11, y12), math.min(y21, y22)), 0) * vol / height)

dr_dailyCalcDayPoc(int startOff, int endOff, int cnum) =>
    float top = high[endOff]
    float bot = low[endOff]
    for off = endOff to startOff
        top := math.max(top, high[off])
        bot := math.min(bot, low[off])

    float step = (top - bot) / cnum
    float pocLevel = na

    if step > 0
        array<float> levels = array.new_float(cnum + 1, 0.0)
        for x = 0 to cnum
            array.set(levels, x, bot + step * x)

        array<float> volumes = array.new_float(cnum * 2, 0.0)

        for off = endOff to startOff
            float bodyTop = math.max(close[off], open[off])
            float bodyBot = math.min(close[off], open[off])
            bool isGreen = close[off] >= open[off]

            float topWick = high[off] - bodyTop
            float bottomWick = bodyBot - low[off]
            float bodySize = bodyTop - bodyBot
            float denom = 2.0 * topWick + 2.0 * bottomWick + bodySize
            denom := denom == 0.0 ? 1.0 : denom

            float bodyVol = bodySize * volume[off] / denom
            float topWickVol = 2.0 * topWick * volume[off] / denom
            float bottomWickVol = 2.0 * bottomWick * volume[off] / denom

            for x = 0 to cnum - 1
                float lvlLo = array.get(levels, x)
                float lvlHi = array.get(levels, x + 1)
                float upAdd = (isGreen ? dr_dailyGetVol(lvlLo, lvlHi, bodyBot, bodyTop, bodySize == 0.0 ? 1.0 : bodySize, bodyVol) : 0.0) + dr_dailyGetVol(lvlLo, lvlHi, bodyTop, high[off], topWick == 0.0 ? 1.0 : topWick, topWickVol) / 2.0 + dr_dailyGetVol(lvlLo, lvlHi, bodyBot, low[off], bottomWick == 0.0 ? 1.0 : bottomWick, bottomWickVol) / 2.0
                float dnAdd = (isGreen ? 0.0 : dr_dailyGetVol(lvlLo, lvlHi, bodyBot, bodyTop, bodySize == 0.0 ? 1.0 : bodySize, bodyVol)) + dr_dailyGetVol(lvlLo, lvlHi, bodyTop, high[off], topWick == 0.0 ? 1.0 : topWick, topWickVol) / 2.0 + dr_dailyGetVol(lvlLo, lvlHi, bodyBot, low[off], bottomWick == 0.0 ? 1.0 : bottomWick, bottomWickVol) / 2.0
                array.set(volumes, x, array.get(volumes, x) + upAdd)
                array.set(volumes, x + cnum, array.get(volumes, x + cnum) + dnAdd)

        array<float> totalVols = array.new_float(cnum, 0.0)
        for x = 0 to cnum - 1
            array.set(totalVols, x, array.get(volumes, x) + array.get(volumes, x + cnum))

        int poc = array.indexof(totalVols, array.max(totalVols))
        pocLevel := (array.get(levels, poc) + array.get(levels, poc + 1)) / 2.0

    [top, bot, pocLevel]

dr_dailyClearBoxes(box[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            box.delete(array.get(arr, i))
        array.clear(arr)

dr_dailyClearLines(line[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

dr_dailyClearLabels(label[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.delete(array.get(arr, i))
        array.clear(arr)

//==================== New York 00:00 Line ====================
int dr_ny0000Start = na
float dr_ny0000Price = na
int dr_ny0000End = na

if dr_intradayChart and showNY0000LineModule and dr_showNY0000Line
    bool dr_isNy0000Bar = hour(time, "America/New_York") == 0 and minute(time, "America/New_York") == 0
    dr_ny0000Start := ta.valuewhen(dr_isNy0000Bar, time, 0)
    dr_ny0000Price := ta.valuewhen(dr_isNy0000Bar, open, 0)
    dr_ny0000End := ta.valuewhen(dr_isNy0000Bar, time + 24 * 60 * 60 * 1000, 0)

if dr_intradayChart and showNY0000LineModule and dr_showNY0000Line and not na(dr_ny0000Start) and not na(dr_ny0000Price) and not na(dr_ny0000End)
    if na(dr_lastNyLineStart) or dr_ny0000Start != dr_lastNyLineStart
        line dr_newNyLine = line.new(x1=dr_ny0000Start, y1=dr_ny0000Price, x2=dr_ny0000End, y2=dr_ny0000Price, xloc=xloc.bar_time, extend=extend.none, color=dr_ny0000LineColor, style=dr_borderStyleFromInput(dr_ny0000LineStyleIn), width=dr_ny0000LineWidth)
        array.push(dr_ny0000Lines, dr_newNyLine)
        dr_lastNyLineStart := dr_ny0000Start
        if array.size(dr_ny0000Lines) > 400
            line dr_oldNyLine = array.shift(dr_ny0000Lines)
            line.delete(dr_oldNyLine)

if dr_intradayChart and array.size(dr_ny0000Lines) > 0
    for l = 0 to array.size(dr_ny0000Lines) - 1
        line dr_currNyLine = array.get(dr_ny0000Lines, l)
        line.set_color(dr_currNyLine, showNY0000LineModule and dr_showNY0000Line ? dr_ny0000LineColor : color.new(dr_ny0000LineColor, 100))
        line.set_style(dr_currNyLine, dr_borderStyleFromInput(dr_ny0000LineStyleIn))
        line.set_width(dr_currNyLine, dr_ny0000LineWidth)
else if (not dr_intradayChart or not showNY0000LineModule or not dr_showNY0000Line) and array.size(dr_ny0000Lines) > 0
    for l = array.size(dr_ny0000Lines) - 1 to 0
        line.delete(array.get(dr_ny0000Lines, l))
    array.clear(dr_ny0000Lines)
    dr_lastNyLineStart := na

//==================== Daily Volume Range + POC ====================
string dr_dailyNyTz = "America/New_York"
int dr_dailyDayStamp = time("D", "0000-2359", dr_dailyNyTz)
int dr_oneDayMs = 24 * 60 * 60 * 1000

if barstate.islast and dr_intradayChart and showDailyRangeModule
    dr_dailyClearBoxes(dr_dailyDayBoxes)
    dr_dailyClearLines(dr_dailyRangeLines)
    dr_dailyClearLines(dr_dailyPocLines)
    dr_dailyClearLabels(dr_dailyPocLabels)

    array<int> dr_dailyStartOffsets = array.new_int()
    array<int> dr_dailyEndOffsets = array.new_int()
    array<int> dr_dailyStartTimes = array.new_int()

    int dr_barsPerDayEstimate = math.max(1, int(math.ceil(86400.0 / timeframe.in_seconds())))
    int dr_dailyMaxScan = math.min(bar_index + 1, math.min(3500, dr_dailyDaysToShow * dr_barsPerDayEstimate * 2))
    int dr_currentDailyStamp = na
    int dr_currentDailyStart = na
    int dr_currentDailyEnd = na

    for off = 0 to dr_dailyMaxScan - 1
        int d = dr_dailyDayStamp[off]
        if na(d)
            break

        if na(dr_currentDailyStamp)
            dr_currentDailyStamp := d
            dr_currentDailyStart := off
            dr_currentDailyEnd := off
        else if d == dr_currentDailyStamp
            dr_currentDailyStart := off
        else
            array.push(dr_dailyStartOffsets, dr_currentDailyStart)
            array.push(dr_dailyEndOffsets, dr_currentDailyEnd)
            array.push(dr_dailyStartTimes, dr_currentDailyStamp)
            if array.size(dr_dailyStartOffsets) >= dr_dailyDaysToShow
                break
            dr_currentDailyStamp := d
            dr_currentDailyStart := off
            dr_currentDailyEnd := off

    if not na(dr_currentDailyStamp) and array.size(dr_dailyStartOffsets) < dr_dailyDaysToShow
        array.push(dr_dailyStartOffsets, dr_currentDailyStart)
        array.push(dr_dailyEndOffsets, dr_currentDailyEnd)
        array.push(dr_dailyStartTimes, dr_currentDailyStamp)

    int dr_dailyGroupCount = array.size(dr_dailyStartOffsets)
    if dr_dailyGroupCount > 0
        for gk = 0 to dr_dailyGroupCount - 1
            int gi = dr_dailyGroupCount - 1 - gk
            int startOff = array.get(dr_dailyStartOffsets, gi)
            int endOff = array.get(dr_dailyEndOffsets, gi)
            int dayStartTime = array.get(dr_dailyStartTimes, gi)
            int dayEndTime = dayStartTime + dr_oneDayMs

            [dayHigh, dayLow, dr_dailyPocLevel] = dr_dailyCalcDayPoc(startOff, endOff, dr_dailyRows)

            box dr_dailyBox = box.new(left=dayStartTime, top=dayHigh, right=dayEndTime, bottom=dayLow, xloc=xloc.bar_time, bgcolor=dr_dailyRangeFillColor, border_color=color.new(dr_dailyRangeBorderColor, 100), border_width=0)
            array.push(dr_dailyDayBoxes, dr_dailyBox)

            line dr_dailyHiLine = line.new(x1=dayStartTime, y1=dayHigh, x2=dayEndTime, y2=dayHigh, xloc=xloc.bar_time, extend=extend.none, color=dr_dailyRangeBorderColor, style=dr_borderStyleFromInput(dr_dailyRangeBorderStyleIn), width=dr_dailyRangeBorderWidth)
            line dr_dailyLoLine = line.new(x1=dayStartTime, y1=dayLow, x2=dayEndTime, y2=dayLow, xloc=xloc.bar_time, extend=extend.none, color=dr_dailyRangeBorderColor, style=dr_borderStyleFromInput(dr_dailyRangeBorderStyleIn), width=dr_dailyRangeBorderWidth)
            array.push(dr_dailyRangeLines, dr_dailyHiLine)
            array.push(dr_dailyRangeLines, dr_dailyLoLine)

            if dr_dailyPocShow and not na(dr_dailyPocLevel)
                line dr_dailyPocLine = line.new(x1=dayStartTime, y1=dr_dailyPocLevel, x2=dayEndTime, y2=dr_dailyPocLevel, xloc=xloc.bar_time, extend=extend.none, color=dr_dailyPocColor, style=dr_borderStyleFromInput(dr_dailyPocStyleIn), width=dr_dailyPocWidth)
                array.push(dr_dailyPocLines, dr_dailyPocLine)
                if dr_dailyShowPocLabel
                    label dr_dailyPocLbl = label.new(x=dayEndTime, y=dr_dailyPocLevel, text="POC " + str.tostring(math.round_to_mintick(dr_dailyPocLevel)), xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=dr_dailyPocColor)
                    array.push(dr_dailyPocLabels, dr_dailyPocLbl)


if barstate.islast and (not dr_intradayChart or not showDailyRangeModule)
    dr_dailyClearBoxes(dr_dailyDayBoxes)
    dr_dailyClearLines(dr_dailyRangeLines)
    dr_dailyClearLines(dr_dailyPocLines)
    dr_dailyClearLabels(dr_dailyPocLabels)


//====================================================
// CISD — v6
//====================================================
var line[] cisdLines = array.new_line()
var label[] cisdLabels = array.new_label()

var float cisd_sequenceStartPrice = na
var int cisd_sequenceStartIndex = na
var bool cisd_waitingForDisplacement = false
var float[] cisd_priorBullishOpens = array.new_float()
var float[] cisd_priorBearishOpens = array.new_float()

var cisd_swingStrength = 3
var float[] cisd_bslPrices = array.new_float()
var float[] cisd_sslPrices = array.new_float()
var int[] cisd_bslTimes = array.new_int()
var int[] cisd_sslTimes = array.new_int()

cisd_getLabelSize() =>
    switch cisd_labelSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.small

cisd_manageLiquidityLevels() =>
    float ph = ta.pivothigh(high, cisd_swingStrength, cisd_swingStrength)
    float pl = ta.pivotlow(low, cisd_swingStrength, cisd_swingStrength)
    if not na(ph)
        array.push(cisd_bslPrices, ph)
        array.push(cisd_bslTimes, bar_index[cisd_swingStrength])
    if not na(pl)
        array.push(cisd_sslPrices, pl)
        array.push(cisd_sslTimes, bar_index[cisd_swingStrength])

cisd_checkLiquiditySweep() =>
    bool bslSwept = false
    bool sslSwept = false
    if array.size(cisd_bslPrices) > 0
        for i = array.size(cisd_bslPrices) - 1 to 0
            if high > array.get(cisd_bslPrices, i)
                bslSwept := true
                array.remove(cisd_bslPrices, i)
                array.remove(cisd_bslTimes, i)
                break
    if array.size(cisd_sslPrices) > 0
        for i = array.size(cisd_sslPrices) - 1 to 0
            if low < array.get(cisd_sslPrices, i)
                sslSwept := true
                array.remove(cisd_sslPrices, i)
                array.remove(cisd_sslTimes, i)
                break
    [bslSwept, sslSwept]

cisd_drawCisd(startPrice, startIndex, isBull) =>
    chosenStyle = switch cisd_lineStyle
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid
    int rightX = bar_index + cisd_lineLength
    newLine = line.new(startIndex, startPrice, rightX, startPrice, color=cisd_lineColor, style=chosenStyle, width=cisd_lineWidth, extend=extend.none)
    array.push(cisdLines, newLine)
    if cisd_showLabels
        int labelX = rightX + 2
        newLabel = label.new(labelX, startPrice, text=isBull ? "CISD+" : "CISD-", style=label.style_label_left, textcolor=cisd_textColor, size=cisd_getLabelSize(), textalign=text.align_left, color=na)
        array.push(cisdLabels, newLabel)

cisd_findRecentSequence(bull) =>
    var int count = 0
    var float firstOpen = na
    var int firstIndex = na
    if bull
        if close > open
            if count == 0 or close[1] <= open[1]
                count := 1, firstOpen := open, firstIndex := bar_index
            else
                count += 1
        else
            if count > 0
                firstOpen := na, firstIndex := na
            count := 0
    else
        if close < open
            if count == 0 or close[1] >= open[1]
                count := 1, firstOpen := open, firstIndex := bar_index
            else
                count += 1
        else
            if count > 0
                firstOpen := na, firstIndex := na
            count := 0
    [count, firstOpen, firstIndex]

if showCISDModule and barstate.isconfirmed
    cisd_manageLiquidityLevels()
    [cisd_bslSwept, cisd_sslSwept] = cisd_checkLiquiditySweep()
    bool cisd_bull = close > open
    bool cisd_bear = close < open
    [cisd_bullCount, cisd_bullFirstOpen, cisd_bullFirstIndex] = cisd_findRecentSequence(true)
    [cisd_bearCount, cisd_bearFirstOpen, cisd_bearFirstIndex] = cisd_findRecentSequence(false)
    if cisd_bslSwept and not cisd_waitingForDisplacement
        if not na(cisd_bullFirstOpen)
            cisd_sequenceStartPrice := cisd_bullFirstOpen
            cisd_sequenceStartIndex := cisd_bullFirstIndex
            cisd_waitingForDisplacement := true
            array.clear(cisd_priorBullishOpens)
            array.push(cisd_priorBullishOpens, cisd_bullFirstOpen)
    if cisd_sslSwept and not cisd_waitingForDisplacement
        if not na(cisd_bearFirstOpen)
            cisd_sequenceStartPrice := cisd_bearFirstOpen
            cisd_sequenceStartIndex := cisd_bearFirstIndex
            cisd_waitingForDisplacement := true
            array.clear(cisd_priorBearishOpens)
            array.push(cisd_priorBearishOpens, cisd_bearFirstOpen)
    if cisd_waitingForDisplacement
        if array.size(cisd_priorBullishOpens) > 0 and cisd_bear
            if close < array.get(cisd_priorBullishOpens, 0)
                cisd_drawCisd(cisd_sequenceStartPrice, cisd_sequenceStartIndex, false)
                cisd_waitingForDisplacement := false
                array.clear(cisd_priorBullishOpens)
        if array.size(cisd_priorBearishOpens) > 0 and cisd_bull
            if close > array.get(cisd_priorBearishOpens, 0)
                cisd_drawCisd(cisd_sequenceStartPrice, cisd_sequenceStartIndex, true)
                cisd_waitingForDisplacement := false
                array.clear(cisd_priorBearishOpens)
    if not na(cisd_sequenceStartIndex) and bar_index - cisd_sequenceStartIndex > 20
        cisd_waitingForDisplacement := false
        array.clear(cisd_priorBullishOpens)
        array.clear(cisd_priorBearishOpens)

if showCISDModule and barstate.islast
    if array.size(cisdLines) > 0
        for i = array.size(cisdLines) - 1 to 0
            ln = array.get(cisdLines, i)
            if not na(ln)
                if bar_index - line.get_x1(ln) > 200
                    line.delete(ln)
                    array.remove(cisdLines, i)
                    if i < array.size(cisdLabels)
                        lbDel = array.get(cisdLabels, i)
                        if not na(lbDel)
                            label.delete(lbDel)
                        array.remove(cisdLabels, i)
                else
                    x1 = line.get_x1(ln)
                    y1 = line.get_y1(ln)
                    newX2 = x1 + cisd_lineLength
                    line.set_x2(ln, newX2)
                    if i < array.size(cisdLabels)
                        lb = array.get(cisdLabels, i)
                        if not na(lb)
                            label.set_x(lb, newX2 + 2)
                            label.set_y(lb, y1)
                            label.set_style(lb, label.style_label_left)
                            label.set_color(lb, na)
    if array.size(cisdLabels) > 0
        for j = array.size(cisdLabels) - 1 to 0
            lbl = array.get(cisdLabels, j)
            if not na(lbl)
                if bar_index - label.get_x(lbl) > 220
                    label.delete(lbl)
                    array.remove(cisdLabels, j)
                else
                    lx = label.get_x(lbl)
                    if lx > bar_index + 200
                        label.set_x(lbl, bar_index + 2)
                    label.set_color(lbl, na)

if not showCISDModule
    if array.size(cisdLines) > 0
        for i = array.size(cisdLines) - 1 to 0
            line.delete(array.get(cisdLines, i))
        array.clear(cisdLines)
    if array.size(cisdLabels) > 0
        for i = array.size(cisdLabels) - 1 to 0
            label.delete(array.get(cisdLabels, i))
        array.clear(cisdLabels)
    array.clear(cisd_priorBullishOpens)
    array.clear(cisd_priorBearishOpens)
    cisd_waitingForDisplacement := false
````
