# MARX FVG + IFVG + VWAP + 7 EMAs

- url: https://www.tradingview.com/script/FBCBUv62-MARX-FVG-IFVG-VWAP-7-EMAs/
- type: indicator
- pine_id: PUB;f3a57d608c9d4b11963892a507208855
- version: 1.0

## Description

Combining FVG + IFVG + VWAP + 7 EMAs indicators into one stack.

## Source Code

````pine
//@version=6
indicator("MARX FVG + IFVG + VWAP + 7 EMAs", "MARX FVG/IFVG/VWAP/EMA", overlay = true, max_lines_count = 500, max_boxes_count = 500)

//====================================================================================================
// Visibility
//====================================================================================================
showFVG   = input.bool(true, "Show Base FVG", group = "Visibility")
showIFVG  = input.bool(true, "Show Inversion FVG (IFVG)", group = "Visibility")
showVWAP  = input.bool(true, "Show VWAP", group = "Visibility")
showEMAs  = input.bool(true, "Show EMAs", group = "Visibility")

//====================================================================================================
// Base FVG
//====================================================================================================

// Settings
thresholdPer     = input.float(0.0, "Threshold %", minval = 0.0, maxval = 100.0, step = 0.1, inline = "threshold", group = "FVG Settings")
auto             = input.bool(false, "Auto", inline = "threshold", group = "FVG Settings")
showLast         = input.int(0, "Unmitigated Levels", minval = 0, group = "FVG Settings")
mitigationLevels = input.bool(false, "Mitigation Levels", group = "FVG Settings")
tf               = input.timeframe("", "Timeframe", group = "FVG Settings")

// Style
extend  = input.int(20, "Extend", minval = 0, inline = "extend", group = "FVG Style")
dynamic = input.bool(false, "Dynamic", inline = "extend", group = "FVG Style")
bullCss = input.color(color.new(#089981, 70), "Bullish FVG", group = "FVG Style")
bearCss = input.color(color.new(#f23645, 70), "Bearish FVG", group = "FVG Style")

type BaseFVG
    float top
    float bot
    bool  isBull
    int   t

base_detect() =>
    var float cumFrac = 0.0
    float den = low == 0.0 ? 1e-10 : low
    cumFrac += (high - low) / den

    float autoThr = bar_index > 0 ? cumFrac / bar_index : 0.0
    float thr     = auto ? autoThr : thresholdPer / 100.0

    bool bull = low > high[2] and close[1] > high[2] and (low - high[2]) / high[2] > thr
    bool bear = high < low[2] and close[1] < low[2] and (low[2] - high) / high > thr

    float top = na
    float bot = na
    int   tt  = time
    bool  ok  = false
    bool  isB = false

    if bull
        top := low
        bot := high[2]
        ok  := true
        isB := true
    else if bear
        top := low[2]
        bot := high
        ok  := true
        isB := false

    [ok, isB, top, bot, tt]

// Storage
var BaseFVG[] baseRecs  = array.new<BaseFVG>()
var box[]     baseBoxes = array.new<box>()
var line[]    baseLines = array.new<line>()

var float dynBullTop = na
var float dynBullBot = na
var float dynBearTop = na
var float dynBearBot = na
var int   lastBaseT  = 0

string baseTf = tf == "" ? timeframe.period : tf
[baseOk, baseIsBull, baseTop, baseBot, baseT] = request.security(syminfo.tickerid, baseTf, base_detect())

int n = bar_index

if showFVG
    if baseOk and baseT != lastBaseT
        if dynamic
            if baseIsBull
                dynBullTop := baseTop
                dynBullBot := baseBot
            else
                dynBearTop := baseTop
                dynBearBot := baseBot
        else
            color bg = baseIsBull ? bullCss : bearCss
            array.unshift(baseBoxes, box.new(n - 2, baseTop, n + extend, baseBot, border_color = na, bgcolor = bg))

        array.unshift(baseRecs, BaseFVG.new(baseTop, baseBot, baseIsBull, baseT))
        lastBaseT := baseT

    if dynamic
        if not na(dynBullTop) and not na(dynBullBot)
            dynBullTop := math.max(math.min(close, dynBullTop), dynBullBot)
        if not na(dynBearTop) and not na(dynBearBot)
            dynBearBot := math.min(math.max(close, dynBearBot), dynBearTop)

    int rsz = array.size(baseRecs)
    if rsz > 0
        for i = rsz - 1 to 0
            BaseFVG r = array.get(baseRecs, i)

            if r.isBull
                if close < r.bot
                    if mitigationLevels
                        line.new(r.t, r.bot, time, r.bot, xloc = xloc.bar_time, color = bullCss, style = line.style_dashed)
                    if not dynamic and i < array.size(baseBoxes)
                        box bx = array.remove(baseBoxes, i)
                        bx.delete()
                    array.remove(baseRecs, i)
            else
                if close > r.top
                    if mitigationLevels
                        line.new(r.t, r.top, time, r.top, xloc = xloc.bar_time, color = bearCss, style = line.style_dashed)
                    if not dynamic and i < array.size(baseBoxes)
                        box bx = array.remove(baseBoxes, i)
                        bx.delete()
                    array.remove(baseRecs, i)

    if barstate.islast
        int lsz = array.size(baseLines)
        if lsz > 0
            for j = lsz - 1 to 0
                line ln = array.get(baseLines, j)
                ln.delete()
                array.remove(baseLines, j)

        int cur = array.size(baseRecs)
        if showLast > 0 and cur > 0
            int maxIdx = math.min(showLast - 1, cur - 1)
            for k = 0 to maxIdx
                BaseFVG r = array.get(baseRecs, k)
                float price = r.isBull ? r.bot : r.top
                color col = r.isBull ? bullCss : bearCss
                array.push(baseLines, line.new(r.t, price, time, price, xloc = xloc.bar_time, color = col))
else
    if barstate.islast
        int bsz = array.size(baseBoxes)
        if bsz > 0
            for i = bsz - 1 to 0
                box bx = array.get(baseBoxes, i)
                bx.delete()
                array.remove(baseBoxes, i)

        int lsz = array.size(baseLines)
        if lsz > 0
            for i = lsz - 1 to 0
                line ln = array.get(baseLines, i)
                ln.delete()
                array.remove(baseLines, i)

        array.clear(baseRecs)

bullTopPlot = plot(showFVG and dynamic ? dynBullTop : na, title = "FVG Bull Top", color = color.new(bullCss, 0), linewidth = 1)
bullBotPlot = plot(showFVG and dynamic ? dynBullBot : na, title = "FVG Bull Bottom", color = color.new(bullCss, 0), linewidth = 1)
fill(bullTopPlot, bullBotPlot, title = "FVG Bull Fill", color = bullCss)

bearTopPlot = plot(showFVG and dynamic ? dynBearTop : na, title = "FVG Bear Top", color = color.new(bearCss, 0), linewidth = 1)
bearBotPlot = plot(showFVG and dynamic ? dynBearBot : na, title = "FVG Bear Bottom", color = color.new(bearCss, 0), linewidth = 1)
fill(bearTopPlot, bearBotPlot, title = "FVG Bear Fill", color = bearCss)

//====================================================================================================
// IFVG
//====================================================================================================

ifvg_showLast = input.int(5, maxval = 100, minval = 1, title = "Show Last", group = "IFVG Settings")
ifvg_source   = input.string("Close", title = "Signal Source", options = ["Close", "Wick"], group = "IFVG Settings")
ifvg_atrMult  = input.float(0.25, step = 0.25, minval = 0.0, title = "ATR Multiplier", group = "IFVG Settings")
bool wt = ifvg_source == "Wick"

ifvgBullCol = input.color(color.new(#089981, 80), title = "Bull Color", group = "IFVG Colors")
ifvgBearCol = input.color(color.new(#f23645, 80), title = "Bear Color", group = "IFVG Colors")
ifvgMidCol  = input.color(#787b86, title = "Midline Color", group = "IFVG Colors")
color ifvgInvis = color.rgb(0, 0, 0, 100)

type IFVG
    int   left
    float top
    int   right
    float bot
    float mid
    int   dir
    int   state
    int   x_val

int ifvgBuffer = 100

var IFVG[] bullFvg = array.new<IFVG>()
var IFVG[] bearFvg = array.new<IFVG>()
var IFVG[] bullInv = array.new<IFVG>()
var IFVG[] bearInv = array.new<IFVG>()

var box[]  ifvgBoxes = array.new<box>()
var line[] ifvgLines = array.new<line>()

float c_top = wt ? high : math.max(open, close)
float c_bot = wt ? low  : math.min(open, close)

float cumHL = ta.cum(high - low)
float atrFallback = cumHL / (bar_index + 1)
float atr = nz(ta.atr(200) * ifvg_atrMult, atrFallback)

bool ifvg_up   = low > high[2] and close[1] > high[2]
bool ifvg_down = high < low[2] and close[1] < low[2]

if showIFVG
    if ifvg_up and math.abs(low - high[2]) > atr
        array.push(bullFvg, IFVG.new(time[1], low, time, high[2], math.avg(low, high[2]), 1, 0, na))
    if ifvg_down and math.abs(low[2] - high) > atr
        array.push(bearFvg, IFVG.new(time[1], low[2], time, high, math.avg(high, low[2]), -1, 0, na))

    if array.size(bullFvg) >= ifvgBuffer
        array.shift(bullFvg)
    if array.size(bearFvg) >= ifvgBuffer
        array.shift(bearFvg)

    int bsz = array.size(bullFvg)
    if bsz > 0
        for i = bsz - 1 to 0
            IFVG v = array.get(bullFvg, i)
            if v.dir == 1 and c_bot < v.bot
                v.x_val := time
                array.push(bullInv, v)
                array.remove(bullFvg, i)

    int rsz2 = array.size(bearFvg)
    if rsz2 > 0
        for i = rsz2 - 1 to 0
            IFVG v = array.get(bearFvg, i)
            if v.dir == -1 and c_top > v.top
                v.x_val := time
                array.push(bearInv, v)
                array.remove(bearFvg, i)

    if array.size(bullInv) >= ifvgBuffer
        array.shift(bullInv)
    if array.size(bearInv) >= ifvgBuffer
        array.shift(bearInv)

    int invSz1 = array.size(bullInv)
    if invSz1 > 0
        for i = invSz1 - 1 to 0
            IFVG v = array.get(bullInv, i)
            int dir0 = v.dir
            int st0  = v.state

            if st0 == 0
                v.state := 1
                v.dir   := -dir0

            if st0 >= 1
                v.right := time

            bool kill = st0 >= 1 and ((dir0 == -1 and c_top > v.top) or (dir0 == 1 and c_bot < v.bot))

            if kill
                array.remove(bullInv, i)
            else
                array.set(bullInv, i, v)

    int invSz2 = array.size(bearInv)
    if invSz2 > 0
        for i = invSz2 - 1 to 0
            IFVG v = array.get(bearInv, i)
            int dir0 = v.dir
            int st0  = v.state

            if st0 == 0
                v.state := 1
                v.dir   := -dir0

            if st0 >= 1
                v.right := time

            bool kill = st0 >= 1 and ((dir0 == -1 and c_top > v.top) or (dir0 == 1 and c_bot < v.bot))

            if kill
                array.remove(bearInv, i)
            else
                array.set(bearInv, i, v)

    if barstate.islast
        int db = array.size(ifvgBoxes)
        if db > 0
            for i = db - 1 to 0
                box bx = array.get(ifvgBoxes, i)
                bx.delete()
                array.remove(ifvgBoxes, i)

        int dl = array.size(ifvgLines)
        if dl > 0
            for i = dl - 1 to 0
                line ln = array.get(ifvgLines, i)
                ln.delete()
                array.remove(ifvgLines, i)

        int s1 = array.size(bullInv)
        if s1 > 0
            int last1 = s1 - 1
            for idx = 0 to last1
                IFVG v = array.get(bullInv, idx)
                if idx > last1 - ifvg_showLast and not na(v.x_val)
                    color col  = v.dir == -1 ? ifvgBullCol : ifvgBearCol
                    color ocol = v.dir == -1 ? ifvgBearCol : ifvgBullCol

                    box b1 = box.new(v.left, v.top, v.x_val, v.bot, bgcolor = col, border_color = ifvgInvis, xloc = xloc.bar_time)
                    box b2 = box.new(v.x_val, v.top, time, v.bot, bgcolor = ocol, border_color = ifvgInvis, xloc = xloc.bar_time)
                    line l1 = line.new(v.left, v.mid, time, v.mid, color = ifvgMidCol, style = line.style_dashed, xloc = xloc.bar_time)

                    array.push(ifvgBoxes, b1)
                    array.push(ifvgBoxes, b2)
                    array.push(ifvgLines, l1)

        int s2 = array.size(bearInv)
        if s2 > 0
            int last2 = s2 - 1
            for idx = 0 to last2
                IFVG v = array.get(bearInv, idx)
                if idx > last2 - ifvg_showLast and not na(v.x_val)
                    color col  = v.dir == -1 ? ifvgBullCol : ifvgBearCol
                    color ocol = v.dir == -1 ? ifvgBearCol : ifvgBullCol

                    box b1 = box.new(v.left, v.top, v.x_val, v.bot, bgcolor = col, border_color = ifvgInvis, xloc = xloc.bar_time)
                    box b2 = box.new(v.x_val, v.top, time, v.bot, bgcolor = ocol, border_color = ifvgInvis, xloc = xloc.bar_time)
                    line l1 = line.new(v.left, v.mid, time, v.mid, color = ifvgMidCol, style = line.style_dashed, xloc = xloc.bar_time)

                    array.push(ifvgBoxes, b1)
                    array.push(ifvgBoxes, b2)
                    array.push(ifvgLines, l1)
else
    if barstate.islast
        int db = array.size(ifvgBoxes)
        if db > 0
            for i = db - 1 to 0
                box bx = array.get(ifvgBoxes, i)
                bx.delete()
                array.remove(ifvgBoxes, i)

        int dl = array.size(ifvgLines)
        if dl > 0
            for i = dl - 1 to 0
                line ln = array.get(ifvgLines, i)
                ln.delete()
                array.remove(ifvgLines, i)

//====================================================================================================
// VWAP
//====================================================================================================

hideonDWM = input.bool(false, title="Hide VWAP on 1D or Above", group="VWAP Settings", display = display.none)
var anchor = input.string(defval = "Session", title="Anchor Period",
 options=["Session", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group="VWAP Settings")
src = input.source(hlc3, title = "Source", group="VWAP Settings", display = display.none)
offset = input.int(0, title="Offset", group="VWAP Settings", display = display.none)

BANDS_GROUP = "Bands Settings"
CALC_MODE_TOOLTIP = "Determines the units used to calculate the distance of the bands. When 'Percentage' is selected, a multiplier of 1 means 1%."
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = BANDS_GROUP, tooltip = CALC_MODE_TOOLTIP, display = display.none)
showBand_1 = input.bool(true, title = "Show Band #1", group = BANDS_GROUP, inline = "band_1", display = display.none)
bandMult_1 = input.float(1.0, title = "Bands Multiplier #1", group = BANDS_GROUP, inline = "band_1", step = 0.5, minval=0, display = display.none)
showBand_2 = input.bool(false, title = "Show Band #2", group = BANDS_GROUP, inline = "band_2", display = display.none)
bandMult_2 = input.float(2.0, title = "Bands Multiplier #2", group = BANDS_GROUP, inline = "band_2", step = 0.5, minval=0, display = display.none)
showBand_3 = input.bool(false, title = "Show Band #3", group = BANDS_GROUP, inline = "band_3", display = display.none)
bandMult_3 = input.float(3.0, title = "Bands Multiplier #3", group = BANDS_GROUP, inline = "band_3", step = 0.5, minval=0, display = display.none)

cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

isNewPeriod = switch anchor
    "Earnings" =>
        new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_earnings_actual) or not na(new_earnings_standardized)
    "Dividends" =>
        new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_dividends)
    "Splits" =>
        new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_split)
    "Session" => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    "Quarter" => timeframe.change("3M")
    "Year"    => timeframe.change("12M")
    "Decade"  => timeframe.change("12M") and year % 10 == 0
    "Century" => timeframe.change("12M") and year % 100 == 0
    => false

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(src[1]) and not isEsdAnchor
    isNewPeriod := true

float vwapValue = na
float upperBandValue1 = na
float lowerBandValue1 = na
float upperBandValue2 = na
float lowerBandValue2 = na
float upperBandValue3 = na
float lowerBandValue3 = na

if showVWAP and not (hideonDWM and timeframe.isdwm)
    [_vwap, _stdevUpper, _] = ta.vwap(src, isNewPeriod, 1)
    vwapValue := _vwap
    stdevAbs = _stdevUpper - _vwap
    bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : _vwap * 0.01
    upperBandValue1 := _vwap + bandBasis * bandMult_1
    lowerBandValue1 := _vwap - bandBasis * bandMult_1
    upperBandValue2 := _vwap + bandBasis * bandMult_2
    lowerBandValue2 := _vwap - bandBasis * bandMult_2
    upperBandValue3 := _vwap + bandBasis * bandMult_3
    lowerBandValue3 := _vwap - bandBasis * bandMult_3

plot(showVWAP ? vwapValue : na, title = "VWAP", color = #2962FF, offset = offset)

displayBand1 = showVWAP and showBand_1 ? display.all : display.none
upperBand_1 = plot(upperBandValue1, title="Upper Band #1", color = color.green, offset = offset, display = displayBand1)
lowerBand_1 = plot(lowerBandValue1, title="Lower Band #1", color = color.green, offset = offset, display = displayBand1)
fill(upperBand_1, lowerBand_1, title="Bands Fill #1", color = color.new(color.green, 95), display = displayBand1)

displayBand2 = showVWAP and showBand_2 ? display.all : display.none
upperBand_2 = plot(upperBandValue2, title="Upper Band #2", color = color.olive, offset = offset, display = displayBand2)
lowerBand_2 = plot(lowerBandValue2, title="Lower Band #2", color = color.olive, offset = offset, display = displayBand2)
fill(upperBand_2, lowerBand_2, title="Bands Fill #2", color = color.new(color.olive, 95), display = displayBand2)

displayBand3 = showVWAP and showBand_3 ? display.all : display.none
upperBand_3 = plot(upperBandValue3, title="Upper Band #3", color = color.teal, offset = offset, display = displayBand3)
lowerBand_3 = plot(lowerBandValue3, title="Lower Band #3", color = color.teal, offset = offset, display = displayBand3)
fill(upperBand_3, lowerBand_3, title="Bands Fill #3", color = color.new(color.teal, 95), display = displayBand3)

//====================================================================================================
// 7 EMAs
//====================================================================================================

emaGroup = "EMA Settings"

showEMA1 = input.bool(true,  "Show EMA 1", group = emaGroup, inline = "ema1")
emaLen1  = input.int(9,      "Length", minval = 1, group = emaGroup, inline = "ema1")
emaCol1  = input.color(color.new(#ff6d00, 0), "", group = emaGroup, inline = "ema1")

showEMA2 = input.bool(true,  "Show EMA 2", group = emaGroup, inline = "ema2")
emaLen2  = input.int(20,     "Length", minval = 1, group = emaGroup, inline = "ema2")
emaCol2  = input.color(color.new(#ffd600, 0), "", group = emaGroup, inline = "ema2")

showEMA3 = input.bool(true,  "Show EMA 3", group = emaGroup, inline = "ema3")
emaLen3  = input.int(50,     "Length", minval = 1, group = emaGroup, inline = "ema3")
emaCol3  = input.color(color.new(#00c853, 0), "", group = emaGroup, inline = "ema3")

showEMA4 = input.bool(true,  "Show EMA 4", group = emaGroup, inline = "ema4")
emaLen4  = input.int(100,    "Length", minval = 1, group = emaGroup, inline = "ema4")
emaCol4  = input.color(color.new(#00b0ff, 0), "", group = emaGroup, inline = "ema4")

showEMA5 = input.bool(true,  "Show EMA 5", group = emaGroup, inline = "ema5")
emaLen5  = input.int(200,    "Length", minval = 1, group = emaGroup, inline = "ema5")
emaCol5  = input.color(color.new(#7c4dff, 0), "", group = emaGroup, inline = "ema5")

showEMA6 = input.bool(false, "Show EMA 6", group = emaGroup, inline = "ema6")
emaLen6  = input.int(300,    "Length", minval = 1, group = emaGroup, inline = "ema6")
emaCol6  = input.color(color.new(#d500f9, 0), "", group = emaGroup, inline = "ema6")

showEMA7 = input.bool(false, "Show EMA 7", group = emaGroup, inline = "ema7")
emaLen7  = input.int(400,    "Length", minval = 1, group = emaGroup, inline = "ema7")
emaCol7  = input.color(color.new(#ff1744, 0), "", group = emaGroup, inline = "ema7")

ema1 = ta.ema(close, emaLen1)
ema2 = ta.ema(close, emaLen2)
ema3 = ta.ema(close, emaLen3)
ema4 = ta.ema(close, emaLen4)
ema5 = ta.ema(close, emaLen5)
ema6 = ta.ema(close, emaLen6)
ema7 = ta.ema(close, emaLen7)

plot(showEMAs and showEMA1 ? ema1 : na, title = "EMA 1", color = emaCol1, linewidth = 2)
plot(showEMAs and showEMA2 ? ema2 : na, title = "EMA 2", color = emaCol2, linewidth = 2)
plot(showEMAs and showEMA3 ? ema3 : na, title = "EMA 3", color = emaCol3, linewidth = 2)
plot(showEMAs and showEMA4 ? ema4 : na, title = "EMA 4", color = emaCol4, linewidth = 2)
plot(showEMAs and showEMA5 ? ema5 : na, title = "EMA 5", color = emaCol5, linewidth = 2)
plot(showEMAs and showEMA6 ? ema6 : na, title = "EMA 6", color = emaCol6, linewidth = 2)
plot(showEMAs and showEMA7 ? ema7 : na, title = "EMA 7", color = emaCol7, linewidth = 2)
````
