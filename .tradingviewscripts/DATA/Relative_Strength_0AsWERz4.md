<!-- tradingview-pine-id: PUB;99d7cdb2bdff4fd4864102204d3889e4 -->
<!-- tradingviewscripts-format: 1 -->
# Relative Strength

Source: https://www.tradingview.com/script/0AsWERz4-Relative-Strength-MA-Power-Volume-RSI/

## Description

this is swing trading script. this shows relative strength ,RSI  .moving average and super Trend .Free-float market cap

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator('Relative Strength', shorttitle='S1-Indresh')

//Input
source = input(title='Source', defval=close)
comparativeTickerId = input.symbol('NSE:NIFTY', title='Comparative Symbol')
length = input.int(123, minval=1, title='Period')
showZeroLine = input(defval=true, title='Show Zero Line')
showRefDateLbl = input(defval=true, title='Show Reference Label')
toggleRSColor = input(defval=true, title='Toggle RS color on crossovers')
showRSTrend = input.bool(defval=false, title='RS Trend,', group='RS Trend', inline='RS Trend')
base = input.int(title='Range', minval=1, defval=5, group='RS Trend', inline='RS Trend')
showMA = input.bool(defval=false, title='', group='RS Mean', inline='RS Mean')
lengthRSMA = input.int(50, minval=1, title='Period', group='RS Mean', inline='RS Mean')
showMAColor = input.bool(defval=true, title='Trend Color', group='RS Mean', inline='RS Mean')
showBubbles = input.bool(defval=true, title='', group='Price Confirmation', inline='Color')
lengthPriceSMA = input.int(50, minval=1, title='Period', group='Price Confirmation', inline='Color')
bullishColor = input.color(color.new(color.green, 85), title='+ve', group='Price Confirmation', inline='Color')
bearishColor = input.color(color.new(color.red, 85), title='-ve', group='Price Confirmation', inline='Color')

//RSI Strength Inputs
showRSI = input.bool(defval=true, title='Show RSI Strength', group='RSI Strength', inline='RSI')
rsiSource = input(defval=close, title='Source', group='RSI Strength', inline='RSI2')
rsiLength = input.int(14, minval=1, title='Period', group='RSI Strength', inline='RSI2')

//EMA Inputs (4 EMAs plotted on price chart via force_overlay)
showEMA1 = input.bool(defval=true, title='EMA 1', group='EMA', inline='EMA1')
emaLength1 = input.int(20, minval=1, title='Length', group='EMA', inline='EMA1')
emaColor1 = input.color(color.blue, title='Color', group='EMA', inline='EMA1')

showEMA2 = input.bool(defval=true, title='EMA 2', group='EMA', inline='EMA2')
emaLength2 = input.int(50, minval=1, title='Length', group='EMA', inline='EMA2')
emaColor2 = input.color(color.orange, title='Color', group='EMA', inline='EMA2')

showEMA3 = input.bool(defval=false, title='EMA 3', group='EMA', inline='EMA3')
emaLength3 = input.int(100, minval=1, title='Length', group='EMA', inline='EMA3')
emaColor3 = input.color(color.purple, title='Color', group='EMA', inline='EMA3')

showEMA4 = input.bool(defval=false, title='EMA 4', group='EMA', inline='EMA4')
emaLength4 = input.int(200, minval=1, title='Length', group='EMA', inline='EMA4')
emaColor4 = input.color(color.yellow, title='Color', group='EMA', inline='EMA4')

//Supertrend Inputs (plotted on price chart via force_overlay)
showSupertrend = input.bool(defval=true, title='Show Supertrend', group='Supertrend', inline='ST')
stFactor = input.float(3.0, minval=0.1, step=0.1, title='Factor', group='Supertrend', inline='ST2')
stAtrPeriod = input.int(10, minval=1, title='ATR Period', group='Supertrend', inline='ST2')

//Supertrend Background Fill Inputs
showSTBg = input.bool(defval=false, title='Show ST Background', group='Supertrend', inline='STBg')
stBullBg = input.color(color.new(color.green, 85), title='Bull', group='Supertrend', inline='STBg')
stBearBg = input.color(color.new(color.red, 85), title='Bear', group='Supertrend', inline='STBg')

//Supertrend Candle Body Color Inputs
showSTBody = input.bool(defval=false, title='Color Candle Body', group='Supertrend', inline='STBody')
stBullBody = input.color(color.green, title='Bull', group='Supertrend', inline='STBody')
stBearBody = input.color(color.red, title='Bear', group='Supertrend', inline='STBody')

//Up-Down Volume Shape Inputs
showUDShapes = input.bool(defval=false, title='Show Up-Down Volume Shapes', group='UpDown Shapes', inline='UD1')
useCombine = input.bool(defval=true, title='Combine Conditions (% + Volume)', group='UpDown Shapes', inline='UD2')
udVolThreshold = input.int(1000000, title='Volume Above', group='UpDown Shapes', inline='UD3')
udPctThreshold = input.float(5.0, title='% Change Above', group='UpDown Shapes', inline='UD3')
udShapeColor = input.color(color.purple, title='Shape Color', group='UpDown Shapes', inline='UD4')

//Quarterly Earnings Table Inputs
string qeGRP1 = "════════ QE Modes ═════════"
showQETable = input.bool(true, "Show Earnings Table", group=qeGRP1)
qeDarkColors = input.bool(false, "Dark Mode", group=qeGRP1, tooltip='Select this if you use a dark color theme')
qeMiniMode = input.bool(false, "Mini Mode", group=qeGRP1, tooltip='Select this to get the Mini mode where values are replaced by traffic lights')
qeDatasize = input.int(4, 'Long Mode ?', minval=4, inline='qeline3', group=qeGRP1, tooltip='Number of previous quarters to display') + 5

string qeGRP2 = "════════ QE Table Options ═════════"
string qeTableSize = input.string("small", "Size", inline="qe21", group=qeGRP2, options=["tiny", "small", "normal", "large", "huge", "auto"])
string qeTablePosY = input.string("bottom", "↕", inline="qe21", group=qeGRP2, options=["top", "middle", "bottom"])
string qeTablePosX = input.string("right", "↔", inline="qe21", group=qeGRP2, options=["left", "center", "right"])

string qeGRP3 = "════════ QE Inputs ═════════"
qePeriod = input.string('FQ', 'Period', options=['FQ', 'FY'], inline='qeline3b', group=qeGRP3, tooltip='Quarterly (FQ) or Yearly (FY)')
qeTopLeft = input.string('FF', 'Top-left cell displays', group=qeGRP3, options=['FF', 'Mcap'], tooltip='Free Float (FF) or Marketcap (Mcap)')

qeFrameCol = qeDarkColors ? color.new(#999999, 50) : color.rgb(241, 241, 241)
qeBorderCol = qeDarkColors ? color.new(#999999, 50) : color.rgb(241, 241, 241)
qeTextColor = qeDarkColors ? color.new(color.white, 0) : color.new(color.black, 0)
qeBGColor = qeDarkColors ? color.new(color.white, 100) : color.new(color.black, 100)
qeHeadColor = qeDarkColors ? color.new(color.white, 100) : color.new(color.black, 100)
qeBodyColor = qeDarkColors ? color.new(color.white, 100) : color.new(color.black, 100)
qeUpColor = qeDarkColors ? color.new(color.lime, 0) : color.new(color.rgb(31, 12, 239, 16), 0)
qeDownColor = qeDarkColors ? color.new(color.red, 0) : color.new(color.rgb(213, 27, 182), 10)
qeUnchangedColor = qeDarkColors ? color.new(color.yellow, 0) : color.new(color.orange, 30)

qeFinancial01 = 'EPS'
qeFinancial02 = 'Sales'
qeFinancial01Id = 'EARNINGS_PER_SHARE_DILUTED'
qeFinancial02Id = 'TOTAL_REVENUE'

qeGetFinFQ(_id, _per) =>
    _financials = request.financial(syminfo.tickerid, _id, _per, barmerge.gaps_on, ignore_invalid_symbol=true)
    if _id == qeFinancial02Id
        _financials := math.round(_financials / 10.0, 2)
    _financials

qeFArray(arrayId, val) =>
    array.unshift(arrayId, val)
    array.pop(arrayId)

qeFinID1 = qeFinancial01
qeFinID2 = qeFinancial02
qeGetFinx(finID) =>
    finx = switch finID
        qeFinancial02 => qeFinancial02Id
        qeFinancial01 => qeFinancial01Id
    finx

qeRev = request.financial(syminfo.tickerid, 'TOTAL_REVENUE', qePeriod, barmerge.gaps_on, ignore_invalid_symbol=true)

qeFinx1 = qeGetFinx(qeFinID1)
qeFinx2 = qeGetFinx(qeFinID2)
qeFinData1 = qeGetFinFQ(qeFinx1, qePeriod)
qeFinData2 = qeGetFinFQ(qeFinx2, qePeriod)

var qeDate = array.new_int(qeDatasize)
var qeArrayFinData1 = array.new_float(qeDatasize)
var qeArrayFinData2 = array.new_float(qeDatasize)

if not na(qeRev)
    qeFArray(qeDate, time)
    qeFArray(qeArrayFinData1, qeFinData1)
    qeFArray(qeArrayFinData2, qeFinData2)

qeFt(_table, _column, _row, _value) =>
    table.cell(table_id=_table, column=_column, row=_row, text=_value, bgcolor=qeHeadColor, text_color=qeTextColor, text_size=qeTableSize)

qeFtDate(_table, _column, _row, _value) =>
    _new_value = str.contains(_value, "70") ? "" : _value
    table.cell(table_id=_table, column=_column, row=_row, text=_new_value, bgcolor=qeBodyColor, text_color=qeTextColor, text_size=qeTableSize, text_halign=text.align_left)

qeFCell(finID, _table, _column, _row, _value, _i) =>
    divider = finID == 'EPS' ? 1 : 1000000
    suffix = finID == 'EPS' or finID == qeFinancial02 ? '' : ' M'
    strFormat = finID == 'EPS' ? '#.#' : finID == qeFinancial02 ? '#,###.#' : '#,##0'
    val = array.get(_value, _i) / divider
    table.cell(table_id=_table, column=_column, row=_row, text=na(val) ? "" : str.tostring(val, strFormat) + suffix, text_color=qeTextColor, text_size=qeTableSize)

qeFYoY(_table, _column, _row, _value, _i, _cmpr) =>
    sym = ""
    dif = 0.0
    if na(_value)
        na
    else
        val1 = array.get(_value, _i)
        val2 = array.get(_value, _i + _cmpr)
        val1 := val1 == 0 ? 1 : val1
        val2 := math.round(val2, 1) == 0 or math.round(val2, 1) == -0 ? 0.1 : val2
        dif := math.round(((val1 - val2) / math.abs(val2)) * 100)
        sym := na(dif) ? "" : dif > 0 ? '+' + str.tostring(dif) + '%' : str.tostring(dif) + '%'
    table.cell(table_id=_table, column=_column, row=_row, text=na(dif) ? "●" : qeMiniMode ? "●" : sym, text_halign=text.align_right, text_color=na(dif) ? qeFrameCol : dif > 0 ? qeUpColor : dif < 0 ? qeDownColor : dif == 0 ? qeUnchangedColor : qeFrameCol, text_size=qeTableSize)

qeFreeFloat = nz(request.financial(syminfo.tickerid, 'FLOAT_SHARES_OUTSTANDING', 'FY'))
qeFF = na(ta.vwap) ? qeFreeFloat / 10000000 : qeFreeFloat * ta.vwap / 10000000
qeValidatedFF = na(qeFF) or nz(qeFF) == 0 ? '' : str.tostring(math.round(qeFF)) + ' Cr'

qeOutstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")
qeMC = qeOutstanding * close / 10000000
qeValidatedMC = na(qeMC) or nz(qeMC) == 0 ? '' : str.tostring(math.round(qeMC, 0)) + ' Cr'

var table qeTable = table.new(qeTablePosY + "_" + qeTablePosX, columns=7, rows=qeDatasize, bgcolor=qeBGColor, frame_color=qeFrameCol, frame_width=1, border_color=qeBorderCol, border_width=1, force_overlay=true)

//Set up
baseSymbol = request.security(syminfo.tickerid, timeframe.period, source)
comparativeSymbol = request.security(comparativeTickerId, timeframe.period, source)

//Calculations
res = baseSymbol / baseSymbol[length] / (comparativeSymbol / comparativeSymbol[length]) - 1
resColor = toggleRSColor ? res > 0 ? color.green : color.red : color.blue
refDay = showRefDateLbl and barstate.islast ? dayofmonth(time[length]) : na
refMonth = showRefDateLbl and barstate.islast ? month(time[length]) : na
refYear = showRefDateLbl and barstate.islast ? year(time[length]) : na
refLabelStyle = res[length] > 0 ? label.style_label_up : label.style_label_down
refDateLabel = showRefDateLbl and barstate.islast ? label.new(bar_index - length, 0, text='RS-' + str.tostring(length) + ' reference, ' + str.tostring(refDay) + '-' + str.tostring(refMonth) + '-' + str.tostring(refYear), color=color.blue, style=refLabelStyle, yloc=yloc.price) : na
y0 = res - res[base]
angle0 = math.atan(y0 / base)
zeroLineColor = showRSTrend ? angle0 > 0.0 ? color.green : color.maroon : color.maroon
sma_res = ta.sma(res, lengthRSMA)
sma_symb = ta.sma(baseSymbol, lengthPriceSMA)
pos_div = ta.rising(sma_symb, 3) and baseSymbol >= sma_symb
neg_div = ta.falling(sma_symb, 3) and baseSymbol < sma_symb
div_started = pos_div or neg_div
div_color = div_started ? pos_div ? bullishColor : neg_div ? bearishColor : na : na
ma_rising = ta.rising(sma_res, 3)
ma_falling = ta.falling(sma_res, 3)
ma_color = showMAColor and ma_rising ? color.green : showMAColor and ma_falling ? color.red : color.gray

//RSI Calculation
rsiValue = ta.rsi(rsiSource, rsiLength)
rsiBgColor = rsiValue > 50 ? color.new(color.green, 70) : color.new(color.gray, 80)
rsiTextColor = rsiValue > 50 ? color.new(color.green, 0) : color.new(color.gray, 30)

//EMA Calculations (4 EMAs)
emaValue1 = ta.ema(close, emaLength1)
emaValue2 = ta.ema(close, emaLength2)
emaValue3 = ta.ema(close, emaLength3)
emaValue4 = ta.ema(close, emaLength4)

//Supertrend Calculation
[stLine, stDirection] = ta.supertrend(stFactor, stAtrPeriod)
stColor = stDirection < 0 ? color.green : color.red
stUp = stDirection < 0 ? stLine : na
stDown = stDirection < 0 ? na : stLine

//Up-Down Volume Shape Calculation
udRoc = ta.roc(close, 1) >= udPctThreshold
udVolCheck = volume >= udVolThreshold
udCondition = useCombine ? udRoc and udVolCheck : udRoc or udVolCheck

//Plot - RS panel (lower)
plot(showZeroLine ? 0 : na, linewidth=2, color=zeroLineColor, title='Zero Line / RS Trend')
plot(res, title='RS', linewidth=3, color=resColor)
plot(showMA ? sma_res : na, color=ma_color, title='MA', linewidth=2)
plot(showBubbles and div_started ? res : na, "Confirmation Bubbles", div_color, 10, plot.style_circles)

//Plot - Price chart overlays (forced onto main chart)
plot(showEMA1 ? emaValue1 : na, title='EMA 1', color=emaColor1, linewidth=2, force_overlay=true)
plot(showEMA2 ? emaValue2 : na, title='EMA 2', color=emaColor2, linewidth=2, force_overlay=true)
plot(showEMA3 ? emaValue3 : na, title='EMA 3', color=emaColor3, linewidth=2, force_overlay=true)
plot(showEMA4 ? emaValue4 : na, title='EMA 4', color=emaColor4, linewidth=2, force_overlay=true)

stUpPlot = plot(showSupertrend ? stUp : na, title='Supertrend Up', color=color.green, linewidth=2, style=plot.style_linebr, force_overlay=true)
stDownPlot = plot(showSupertrend ? stDown : na, title='Supertrend Down', color=color.red, linewidth=2, style=plot.style_linebr, force_overlay=true)
closePlot = plot(showSTBg ? close : na, title='ST Fill Anchor', display=display.none, force_overlay=true)

fill(stUpPlot, closePlot, color=showSTBg and showSupertrend ? stBullBg : na, title='ST Bull Background')
fill(stDownPlot, closePlot, color=showSTBg and showSupertrend ? stBearBg : na, title='ST Bear Background')

//Candle Body Coloring based on Supertrend
barcolor(showSTBody and showSupertrend ? (stDirection < 0 ? stBullBody : stBearBody) : na, title='Supertrend Body Color')

//Plot - Up-Down Volume Shapes (on price chart)
plotshape(showUDShapes and udCondition ? true : false, title='Up-Down Volume Signal', style=shape.circle, color=udShapeColor, location=location.belowbar, force_overlay=true)

//Quarterly Earnings Table (forced onto main chart)
if showQETable and barstate.islast and not qeMiniMode
    qeFt(qeTable, 0, 0, qeTopLeft == 'FF' ? qeValidatedFF : qeTopLeft == 'Mcap' ? qeValidatedMC : '')
    qeFt(qeTable, 1, 0, qeFinID1)
    qeFt(qeTable, 2, 0, qePeriod == 'FY' ? 'YoY' : '%Chg')
    qeFt(qeTable, 3, 0, qeFinID2)
    qeFt(qeTable, 4, 0, qePeriod == 'FY' ? 'YoY' : '%Chg')

if showQETable and barstate.islast
    if not qeMiniMode
        for i = 0 to qeDatasize - 5
            qeFtDate(qeTable, 0, i + 1, str.format('{0, date, MMM-yy}', array.get(qeDate, i)))
            qeFCell(qeFinID1, qeTable, 1, i + 1, qeArrayFinData1, i)
            qeFYoY(qeTable, 2, i + 1, qeArrayFinData1, i, qePeriod == 'FY' ? 1 : 4)
            qeFCell(qeFinID2, qeTable, 3, i + 1, qeArrayFinData2, i)
            qeFYoY(qeTable, 4, i + 1, qeArrayFinData2, i, qePeriod == 'FY' ? 1 : 4)
    else
        for i = 0 to qeDatasize - 5
            qeFtDate(qeTable, 0, i + 1, str.format('{0, date, MMM-yy}', array.get(qeDate, i)))
            qeFYoY(qeTable, 2, i + 1, qeArrayFinData1, i, qePeriod == 'FY' ? 1 : 4)
            qeFYoY(qeTable, 4, i + 1, qeArrayFinData2, i, qePeriod == 'FY' ? 1 : 4)

//RSI Strength Label (shown in this same lower panel)
var table rsiTable = table.new(position.top_right, 1, 1)
if showRSI and barstate.islast
    table.cell(rsiTable, 0, 0, 'RSI ' + str.tostring(rsiValue, '#.##'), bgcolor=rsiBgColor, text_color=rsiTextColor, text_size=size.normal)

//alertconditions
alertcondition(ma_rising, "Rising Strength", "Rising Strength")
alertcondition(ma_falling, "Declining Strength", "Declining Strength")
````
