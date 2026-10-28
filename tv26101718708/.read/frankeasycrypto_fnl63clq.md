# Frankeasycrypto

- url: https://www.tradingview.com/script/fNL63clQ-Frankeasycrypto/
- type: indicator
- pine_id: PUB;3f90cd2bb03d4c4ea622d7c9e8867257
- version: 1.0

## Description

It helps to identify the main trend of BTC using the cyclical events of the halving and liquidations

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © frankbchain
//@version=5


indicator('Frankeasycrypto', overlay=true,max_lines_count=500)

length = input(title='ATR Period', defval=22)
mult = input.float(title='ATR Multiplier', step=0.1, defval=3)
src = input(title='Source', defval=hl2)
wicks = input(title='Take Wicks into Account ?', defval=false)
showLabels = input(title='Show Buy/Sell Labels ?', defval=false)
highlightState = input(title='Highlight State ?', defval=false)

atr = mult * ta.atr(length)

highPrice = wicks ? high : close
lowPrice = wicks ? low : close
doji4price = open == close and open == low and open == high

longStop = src - atr
longStopPrev = nz(longStop[1], longStop)

if longStop > 0
    if doji4price
        longStop := longStopPrev
        longStop
    else
        longStop := lowPrice[1] > longStopPrev ? math.max(longStop, longStopPrev) : longStop
        longStop
else
    longStop := longStopPrev
    longStop

shortStop = src + atr
shortStopPrev = nz(shortStop[1], shortStop)

if shortStop > 0
    if doji4price
        shortStop := shortStopPrev
        shortStop
    else
        shortStop := highPrice[1] < shortStopPrev ? math.min(shortStop, shortStopPrev) : shortStop
        shortStop
else
    shortStop := shortStopPrev
    shortStop

var int dir = 1
dir := dir == -1 and highPrice > shortStopPrev ? 1 : dir == 1 and lowPrice < longStopPrev ? -1 : dir

var color longColor = color.green
var color shortColor = color.red

longStopPlot = plot(dir == 1 ? longStop : na, title='Long Stop', style=plot.style_linebr, linewidth=2, color=color.new(longColor, 0))
buySignal = dir == 1 and dir[1] == -1
plotshape(buySignal ? longStop : na, title='Long Stop Start', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(longColor, 0))
plotshape(buySignal and showLabels ? longStop : na, title='Buy Label', text='Buy', location=location.absolute, style=shape.labelup, size=size.tiny, color=color.new(longColor, 0), textcolor=color.new(color.white, 0))

shortStopPlot = plot(dir == 1 ? na : shortStop, title='Short Stop', style=plot.style_linebr, linewidth=2, color=color.new(shortColor, 0))
sellSignal = dir == -1 and dir[1] == 1
plotshape(sellSignal ? shortStop : na, title='Short Stop Start', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(shortColor, 0))
plotshape(sellSignal and showLabels ? shortStop : na, title='Sell Label', text='Sell', location=location.absolute, style=shape.labeldown, size=size.tiny, color=color.new(shortColor, 0), textcolor=color.new(color.white, 0))

midPricePlot = plot(ohlc4, title='', style=plot.style_circles, linewidth=0, display=display.none, editable=false)

longFillColor = highlightState ? dir == 1 ? longColor : na : na
shortFillColor = highlightState ? dir == -1 ? shortColor : na : na
fill(midPricePlot, longStopPlot, title='Long State Filling', color=longFillColor, transp=90)
fill(midPricePlot, shortStopPlot, title='Short State Filling', color=shortFillColor, transp=90)

changeCond = dir != dir[1]
alertcondition(changeCond, title='Alert: SuperTrend Direction Change', message='SuperTrend has changed direction!\nSymbol: {{exchange}}:{{ticker}}\nPrice: {{close}}')
alertcondition(buySignal, title='Alert: SuperTrend Buy', message='SuperTrend Buy!\nSymbol: {{exchange}}:{{ticker}}\nPrice: {{close}}')
alertcondition(sellSignal, title='Alert: SuperTrend Sell', message='SuperTrend Sell!\nSymbol: {{exchange}}:{{ticker}}\nPrice: {{close}}')






// ---------   Inputs
i_showEmas = input(defval=true, title='=========== EMAs ============')
i_maSrc = input(defval=close, title='EMA Source')
i_maFast1 = input(defval=12, title='EMA Fast 1')
i_maFast2 = input(defval=50, title='EMA Fast 2')
i_maLen = input(defval=360, title='SMA Length')
i_rangeLen = input(defval=0.618, title='Range Length')
i_currentT = input(defval=true, title='Use Current Time?')
i_tf = input.timeframe(defval='D', title='Selec Diferent Timeframe')
i_showCh = input(defval=false, title='Show Channel')
i_showbarCol = input(defval=true, title='Show Bar Color')
i_showAlert = input(defval=true, title='Show Alert')

// ---------   Calculations
f_maFast1 = ta.ema(i_maSrc, i_maFast1)
f_maFast2 = ta.ema(i_maSrc, i_maFast2)
f_maTrend = i_currentT ? ta.sma(i_maSrc, i_maLen) : request.security(syminfo.tickerid, i_tf, ta.sma(i_maSrc, i_maLen))
f_chBasis = ta.atr(i_maLen) * i_rangeLen
f_chTop = f_maTrend + f_chBasis
f_chBot = f_maTrend - f_chBasis
f_range = (open <= f_chTop or close <= f_chTop) and (open >= f_chBot or close >= f_chBot)
f_GCross = ta.crossover(f_maFast2, f_maTrend)
f_DCross = ta.crossunder(f_maFast2, f_maTrend)
f_dirTrend = f_range ? 0 : i_maSrc >= f_maTrend ? 1 : -1
// Set initial values
f_condition = 0
f_buyCond = f_dirTrend == 1 and f_maFast1 > f_maFast2
f_sellCond = f_dirTrend == -1 and f_maFast1 < f_maFast2
f_buyCloseCo = f_dirTrend == 1 and f_maFast1 < f_maFast2
f_sellCloseC = f_dirTrend == -1 and f_maFast1 > f_maFast2
f_closeCond = f_buyCloseCo or f_sellCloseC
//Conditions
f_condition := f_condition[1] != 1 and f_buyCond ? 1 : f_condition[1] != -1 and f_sellCond ? -1 : f_condition[1] != 0 and f_closeCond ? 0 : nz(f_condition[1])
f_buy = f_condition == 1 and f_condition[1] != 1
f_sell = f_condition == -1 and f_condition[1] != -1
f_close = f_condition[1] != 0 and f_closeCond

// ---------   Colors
c_orange = #f57f17  //Orange
c_green = #006400  //Green
c_green100 = #006400FF  //Green 100%
c_greenLight = #388e3c  //Green Light
c_red = #8B0000  //Red
c_red100 = #8B0000FF  //Red 100%
c_redLight = #b71c1c  //Red Light
c_white = #ffffff  //White
c_gray = #808080  //Gray

c_maFast = f_range ? c_orange : f_buyCloseCo ? c_orange : f_sellCloseC ? c_orange : f_dirTrend == 1 ? c_green : f_dirTrend == -1 ? c_red : na
c_maTrend = f_dirTrend == 0 ? c_orange : f_dirTrend == 1 ? c_green100 : f_dirTrend == -1 ? c_red100 : na
c_ch = f_dirTrend == 0 ? c_orange : f_dirTrend == 1 ? c_green : f_dirTrend == -1 ? c_red : na
c_barCol = f_dirTrend == 0 ? c_orange : f_dirTrend == 1 and open <= close ? c_green100 : f_dirTrend == 1 and open > close ? c_greenLight : f_dirTrend == -1 and open >= close ? c_red100 : f_dirTrend == -1 and open < close ? c_redLight : na

// ---------   Plots
p_maFast1 = plot(f_maFast1, title='EMA Fast 1', color=c_maFast, linewidth=1)
p_maFast2 = plot(f_maFast2, title='EMA Fast 2', color=c_maFast, linewidth=2)
fill(p_maFast1, p_maFast2, title='EMAs Fill', color=c_maFast, transp=80)
plot(f_maTrend, title='SMA Trend', color=c_maTrend, linewidth=3)
p_chTop = plot(i_showCh ? f_chTop : na, title='Top Channel', color=c_maTrend, linewidth=1)
p_chBot = plot(i_showCh ? f_chBot : na, title='Bottom Channel', color=c_maTrend, linewidth=1)
fill(p_chTop, p_chBot, title='Channel', color=c_ch, transp=90)

// ---------   Alerts
plotshape(i_showAlert and f_close ? close : na, title='Close Label', text='Close', textcolor=color.new(c_orange, 0), color=color.new(c_orange, 0), style=shape.xcross, size=size.small, location=location.absolute)
plotshape(i_showAlert and f_GCross ? f_maTrend : na, title='Golden Cross Label', text='Golden\nCross', textcolor=color.new(c_white, 0), color=color.new(c_orange, 0), style=shape.labelup, size=size.normal, location=location.absolute)
plotshape(i_showAlert and f_DCross ? f_maTrend : na, title='Death Cross Label', text='Death\nCross', textcolor=color.new(c_white, 0), color=color.new(c_orange, 0), style=shape.labeldown, size=size.normal, location=location.absolute)

barcolor(i_showbarCol ? c_barCol : na)

alertcondition(f_buy or f_sell or f_close or f_GCross or f_DCross, title='Alert', message='Alert')
alertcondition(f_buy, title='Buy Alert', message='Buy Alert')
alertcondition(f_sell, title='Sell Alert', message='Sell Alert')
alertcondition(f_close, title='Close Alert', message='Close Alert')
alertcondition(f_GCross, title='Golden Cross Alert', message='Golden Cross Alert')
alertcondition(f_DCross, title='Death Cross Alert', message='Death Cross Alert')


//Stochastic
// study(title="Stochastic", shorttitle="Stoch", format=format.price, precision=2)
periodK = input.int(14, title='%K Length', minval=1)
smoothK = input.int(4, title='%K Smoothing', minval=1)
periodD = input.int(4, title='%D Smoothing', minval=1)
k = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
d = ta.sma(k, periodD)
// plot(k, title="%K", color=#2962FF)
// plot(d, title="%D", color=#FF6D00)
// h0 = hline(80, "Upper Band", color=#787B86)
// h1 = hline(20, "Lower Band", color=#787B86)
// fill(h0, h1, color=color.rgb(33, 150, 243, 90), title="Background")

/////////


//--------------------------------------------------------------------
//                             Constants
//--------------------------------------------------------------------

var HEAD_PADDING        = -2
var HEAD_TRANSP         = 60
var LABEL_SIZE          = size.small
var LABEL_STYLE         = label.style_none
var LINE_STYLE          = line.style_solid
var LINE_WIDTH          = 1
var OFFSET_PADDING      = 4
var TAIL_STYLE          = line.style_dotted

//--------------------------------------------------------------------
//                               Inputs
//--------------------------------------------------------------------

t_tails                 = "Extends last opens on historical bars."
t_heads                 = "Extends previous opens in the future."
t_discoverPrices        = "Discovers the opening prices from the intraday chart.\n\nYou may use this setting when there are discrepancies between the data from intraday and high time frames."
t_extendedHours         = "Discovers the opening prices from the extended trading hours if available."

var i_isDailyEnabled    = input     (true,          "Daily",                                inline="Daily",     group="Opens")
var i_dailyColor        = input     (color.green,   "",                                     inline="Daily",     group="Opens")
var i_dailyLookback     = input.int (1,             "", 1,                                  inline="Daily",     group="Opens")
var i_isWeeklyEnabled   = input     (true,          "Weekly",                               inline="Weekly",    group="Opens")
var i_weeklyColor       = input     (color.orange,  "",                                     inline="Weekly",    group="Opens")
var i_weeklyLookback    = input.int (1,             "", 1,                                  inline="Weekly",    group="Opens")
var i_isMonthlyEnabled  = input     (true,          "Monthly",                              inline="Monthly",   group="Opens")
var i_monthlyColor      = input     (color.red,     "",                                     inline="Monthly",   group="Opens")
var i_monthlyLookback   = input.int (1,             "", 1,                                  inline="Monthly",   group="Opens")
var i_isYearlyEnabled   = input     (true,          "Yearly",                               inline="Yearly",    group="Opens")
var i_yearlyColor       = input     (color.blue,    "",                                     inline="Yearly",    group="Opens")
var i_yearlyLookback    = input.int (1,             "", 1,                                  inline="Yearly",    group="Opens")
var i_rightOffset       = input.int (20,            "Offset", 1,                                                group="Style")
var i_areTailsEnabled   = input     (false,         "Show Tails",       t_tails,                                group="Style")
var i_areHeadsEnabled   = input     (false,         "Show Projections", t_heads,                                group="Style")
var i_discoverPrices    = input     (false,         "Discover Prices",  t_discoverPrices,                       group="Settings")
var i_extendedHours     = input     (false,         "Extended Hours",   t_extendedHours,                        group="Settings")

//--------------------------------------------------------------------
//                        Variables declarations
//--------------------------------------------------------------------

var a_lastOpens             = array.new_float(4)
var canShowDaily            = i_isDailyEnabled and timeframe.isintraday
var canShowWeekly           = i_isWeeklyEnabled and (timeframe.isintraday or timeframe.isdaily)
var canShowMonthly          = i_isMonthlyEnabled and not timeframe.ismonthly
var canShowYearly           = i_isYearlyEnabled and not (timeframe.ismonthly and timeframe.multiplier >= 12)
var hasExtendedHours        = i_extendedHours and syminfo.session == session.extended
var discoverPrices          = i_discoverPrices or hasExtendedHours

[dailyTime, dailyOpen]      = request.security(syminfo.tickerid, 'D',   [time, open], lookahead=barmerge.lookahead_on)
[weeklyTime, weeklyOpen]    = request.security(syminfo.tickerid, 'W',   [time, open], lookahead=barmerge.lookahead_on)
[monthlyTime, monthlyOpen]  = request.security(syminfo.tickerid, 'M',   [time, open], lookahead=barmerge.lookahead_on)
[yearlyTime, yearlyOpen]    = request.security(syminfo.tickerid, '12M', [time, open], lookahead=barmerge.lookahead_on)

hasDailyTimeChanged         = hasExtendedHours ? time_tradingday != time_tradingday[1] : dailyTime != dailyTime[1]
hasWeekklyTimeChanged       = hasExtendedHours ? weekofyear != weekofyear[1] : weeklyTime != weeklyTime[1]
hasMonthlyTimeChanged       = hasExtendedHours ? month != month[1] : monthlyTime != monthlyTime[1]
hasYearlyTimeChanged        = hasExtendedHours ? year != year[1] : yearlyTime != yearlyTime[1]

//--------------------------------------------------------------------
//                              Functions 
//--------------------------------------------------------------------

// If different opens share the same opening prices, their labels will overlap
// Instead, we pad the higher time frame ones for achieving a "separator sheet"
f_getPadding(int _index) =>
    _padding = 0
    // Weekly, monthly, or yearly overlaps the daily open
    if _index > 0 and canShowDaily and array.get(a_lastOpens, 0) == array.get(a_lastOpens, _index)
        _padding += 1
    // Monthly or yearly overlaps the weekly open
    if _index > 1 and canShowWeekly and array.get(a_lastOpens, 1) == array.get(a_lastOpens, _index)
        _padding += 1
    // Yearly overlaps the monthly open
    if _index > 2 and canShowMonthly and array.get(a_lastOpens, 2) == array.get(a_lastOpens, _index)
        _padding += 1
    _padding

f_getRightBarIndex(int _padding) => bar_index + i_rightOffset + _padding * OFFSET_PADDING

// On the weekly time frame, the monthly/yearly open is drawn from the first candle of the month/year
// The first weekly candle is not necessarily containing the first day of the month
// In such case, we visually anchor the open of the previous weekly candle
f_isContainedOnPrevWeekly(int _time) => timeframe.isweekly and dayofmonth(time) > dayofmonth(_time)

// Create and update an open level. An open is composed of a label, a "body" line, and optional "tail" and "head" lines extensions
f_draw(bool _newOpen, float _y, int _lookback, int _padding, color _color, string _text, bool _prevTime=false) =>
    var line _body  = na 
    var _label      = label.new(na, na, _text, style=LABEL_STYLE, textcolor=_color, size=LABEL_SIZE)
    var _tail       = line.new(na, na, na, na, color=_color, style=TAIL_STYLE, width=LINE_WIDTH, extend=extend.left)
    var _bodies     = array.new_line()
    var _heads      = array.new_line()
    _start          = _prevTime ? bar_index - 1 : bar_index
    _end            = f_getRightBarIndex(_padding)

    if _newOpen
        // Label
        label.set_xy(_label, _end, _y)
        label.set_tooltip(_label, str.tostring(_y, format.mintick))

        // Body
        line.set_x2(_body, bar_index)
        _body := line.new(_start, _y, _end, _y, color=_color, style=LINE_STYLE, width=LINE_WIDTH)
        array.push(_bodies, _body)

        // Head
        if i_areHeadsEnabled
            array.push(_heads, line.new(bar_index, _y, bar_index, _y, color=color.new(_color, HEAD_TRANSP), style=LINE_STYLE, width=LINE_WIDTH))

        // Tail
        if i_areTailsEnabled
            line.set_xy1(_tail, _start - 1, _y)
            line.set_xy2(_tail, _start, _y)

        if array.size(_bodies) > _lookback
            line.delete(array.shift(_bodies))
        if array.size(_heads) > _lookback
            line.delete(array.shift(_heads))

    if barstate.islast
        line.set_x2(_body, _end)
        label.set_x(_label, _end)

        if i_areHeadsEnabled and array.size(_heads) > 1
            // Not updating the last open's projection
            for i = 0 to array.size(_heads) - 2
                // Avoid projecting on last opens bodies
                if not array.includes(a_lastOpens, line.get_y1(array.get(_heads, i)))
                    line.set_x2(array.get(_heads, i), f_getRightBarIndex(HEAD_PADDING))

//--------------------------------------------------------------------
//                                Logic
//--------------------------------------------------------------------

if canShowDaily and hasDailyTimeChanged 
    array.set(a_lastOpens, 0, discoverPrices ? open : dailyOpen)

if canShowWeekly and hasWeekklyTimeChanged
    array.set(a_lastOpens, 1, discoverPrices ? open : weeklyOpen)

if canShowMonthly and hasMonthlyTimeChanged
    array.set(a_lastOpens, 2, discoverPrices ? open : monthlyOpen)

if canShowYearly and hasYearlyTimeChanged
    array.set(a_lastOpens, 3, discoverPrices ? open : yearlyOpen)

//--------------------------------------------------------------------
//                          Plotting & styling
//--------------------------------------------------------------------

if canShowYearly
    f_draw(hasYearlyTimeChanged, array.get(a_lastOpens, 3), i_yearlyLookback, f_getPadding(3), i_yearlyColor, "Y   ", f_isContainedOnPrevWeekly(yearlyTime))

if canShowMonthly
    f_draw(hasMonthlyTimeChanged, array.get(a_lastOpens, 2), i_monthlyLookback, f_getPadding(2), i_monthlyColor, "M   ", f_isContainedOnPrevWeekly(monthlyTime))

if canShowWeekly
    f_draw(hasWeekklyTimeChanged, array.get(a_lastOpens, 1), i_weeklyLookback, f_getPadding(1), i_weeklyColor, "W   ")

if canShowDaily
    f_draw(hasDailyTimeChanged, array.get(a_lastOpens, 0), i_dailyLookback, f_getPadding(0), i_dailyColor, "D   ")

// Plot invisible opens for displaying last values in `status line`, `scale`, `data window` as well for providing defaults alert conditions

plot(array.get(a_lastOpens, 0), "D",    color.new(i_dailyColor, 100),   editable=false)
plot(array.get(a_lastOpens, 1), "W",    color.new(i_weeklyColor, 100),  editable=false)
plot(array.get(a_lastOpens, 2), "M",    color.new(i_monthlyColor, 100), editable=false)
plot(array.get(a_lastOpens, 3), "Y",    color.new(i_yearlyColor, 100),  editable=false)
````
