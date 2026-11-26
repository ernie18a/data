# Really Moving Averages [BruzX]

- url: https://www.tradingview.com/script/nbM82E00-Really-Moving-Averages-BruzX/
- type: indicator
- pine_id: PUB;20dd99971f7140528f47212c95dc5d19
- version: 2.0

## Description

█ OVERVIEW

This indicator shows the the current values of up to five different moving averages (MA) as horizontal levels. Each moving average can have a different length and timeframe. This enables you to see quickly, easily and minimalistically the current values without having clutter your chart with multiple plots. The levels are displayed in a style which is visually consistent with the other indicators in the free and open-source "Really" series and they look good together. The lines start at the bar where the currently shown value is valid from, i.e. from the starting bar of the chosen timeframe. The averages are shown correctly for timeframes both greater than and less than the current chart timeframe. Note that the indicator uses the same dividends adjustment, back-adjustment  and/or settlement price settings as are used on your charts, so make sure you have the charts set up as intended. 

█ FEATURES
[list]
[*] Shows the currently value of up to five moving averages with freely selectable lengths and timeframes. Add more instances for move that five MAs.
[*] You can choose between Simple Moving Average (SMA), Exponential Moving Average (EMA) or Relative Moving Average (RMA), also known as the Wilder's Moving Average or the Smoothed Moving Average (SMMA). A single MA type is used for all the MAs. To use different MA types, add multiple instances of the indicator. 
[*] For symbols that have Extended Trading Hours (ETH) you can force the indicator to use only bars from Regular Trading Hours (RTH) even when the chart is showing ETH. 
[*] You can choose to include the currently forming bar (which causes repainting) or only bars which are confirmed in the chosen timeframe. 
[*] You can choose a colour, line style and line width. The same is used for all MAs. To use different colours, line styles or widths, add multiple instances of the indicator and configure each one differently. 
[*] Visually similar to other indicators in the free "Really" series (e.g. Really Key Levels).
[/list]
█ RATIONALE

Why does this indicator exist? What does it bring over other MA indicators? Why isn't is part of Really Key Levels?
[list]
[*] A simpler version of this indicator with three fixed lengths and timeframe used to be part of Really Key Levels. It was split out into this separate indicator to allow more options, to not overload Really Key Levels with options and since Really Key Level is not really meant for levels which usually change on every bar (as is the case with moving averages). 
[*] Most other MA indicator use plots, and when you want to monitor multiple MAs in parallel, this will cause the chart to quickly fill with lots of wiggly lines and can overwhelm the chart with clutter. This indicator only shows the current values as a limited length horizontal line.
[*] The indicator is visually consistent with other "Really" indicators and looks good together with them. Users using other "Really" indicators may want to use this one for MAs to have pretty charts. 
[*] Handling data correctly from timeframes which can be either greater than or less that the chart timeframe is not trivial; this indicator does it right.
[*] It was originally created by request from some users of the other "Really" indicators. 
[/list]
█ DISCLAIMER

This indicator is provided for information only and should not be used in isolation without a good understand of what is it showing and without considering other factors. You should not take trades using real money based solely on what this indicator says. Any trades you take are entirely at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BruzX
 
//@version=6
indicator("Really Moving Averages [BruzX]", shorttitle = "RMA", overlay = true)

// ╔───────────────────────────────────────────────────────────────────────────────────╗
// │                                                                                   │
// │ __/\\\\\\\\\\\\\______/\\\\\\\\\______/\\\________/\\\__/\\\\\\\\\\\\\\\_         │
// │  _\/\\\/////////\\\__/\\\///////\\\___\/\\\_______\/\\\_\////////////\\\__        │
// │   _\/\\\_______\/\\\_\/\\\_____\/\\\___\/\\\_______\/\\\___________/\\\/___       │
// │    _\/\\\\\\\\\\\\\\__\/\\\\\\\\\\\/____\/\\\_______\/\\\_________/\\\/_____      │
// │     _\/\\\/////////\\\_\/\\\//////\\\____\/\\\_______\/\\\_______/\\\/_______     │
// │      _\/\\\_______\/\\\_\/\\\____\//\\\___\/\\\_______\/\\\_____/\\\/_________    │
// │       _\/\\\_______\/\\\_\/\\\_____\//\\\__\//\\\______/\\\____/\\\/___________   │
// │        _\/\\\\\\\\\\\\\/__\/\\\______\//\\\__\///\\\\\\\\\/____/\\\\\\\\\\\\\\\_  │
// │         _\/////////////____\///________\///_____\/////////_____\///////////////__ │
// │                                                                                   │
// ╚───────────────────────────────────────────────────────────────────────────────────╝

// ---- Enums and UDTs

//@enum     Helper enum for line styles
enum Style
    solid = "────"
    dashed = "— — —"
    dotted = "·········"

//@enum     Helper enum for line extensions
enum ExtendLR
    none = "None"
    left = "Left"
    right = "Right"
    both = "Both"

enum LabelStyle
    _tag = "Tag"
    _text = "Text"

enum Timeframe
    min1 = "1m"
    min2 = "2m"
    min5 = "5m"
    min15 = "15m"
    min30 = "30m"
    hour1 = "1h"
    hour2 = "2h"
    hour4 = "4h"
    day1 = "1D"
    week1 = "1W"
    month1 = "1M"

enum MAType
    sma = "SMA"
    ema = "EMA"
    rma = "RMA"

// ---- Constants

const bool DEBUG_MODE = false

// ---- Inputs

string g_general = "General"
string g_mas = "Moving Averages"
string g_display = "Display"

float source = input.source(close, "Source", tooltip = "Moving average source series", group = g_general)
MAType maType = input.enum(MAType.sma, "Moving average (MA) type", tooltip = "Moving average type for all MAs. To use various MA types, add multiple instances on this indicator to your chart and confiure each one separately. SMA is the Simple Moving Average. EMA is the Exponential Moving Average. RMA is the Relative Moving Average, also known as the Wilder's Moving Average or SMMA (Smoothed Moving Average).", group = g_general)
bool useRTH = input.bool(false, "RTH session only", tooltip = "The MA levels can either include or exlude bars in the pre-market and post-market from the MA calculation. This setting only affect tickers with different ETH and RTH. Tickers with no formal pre- and post-market (such as futures) always use bars from the entire session and are therefore unaffected by this setting.", group = g_general)
bool waitConfirm = input.bool(false, "Wait for timeframe close", tooltip = "Excludes the last bar from the calculation if it is not confirmed yet on the selected timeframe.", group = g_general)

bool bool_ma1 = input.bool(true,"MA 1      ", inline = "ma1", group = g_mas, display = display.all - display.status_line)
int len_ma1 = input.int(200, "Length", inline = "ma1", group = g_mas, display = display.all - display.status_line)
Timeframe tf_ma1 = input.enum(Timeframe.hour1, "Timeframe", tooltip = "Enable, MA length and timeframe for the 1st configured moving average.", group = g_mas, inline = "ma1", display = display.all - display.status_line)
bool bool_ma2 = input.bool(true,"MA 2      ", inline = "ma2", group = g_mas, display = display.all - display.status_line)
int len_ma2 = input.int(200, "Length", inline = "ma2", group = g_mas, display = display.all - display.status_line)
Timeframe tf_ma2 = input.enum(Timeframe.hour4, "Timeframe", tooltip = "Enable, MA length and timeframe for the 2nd configured moving average.", group = g_mas, inline = "ma2", display = display.all - display.status_line)
bool bool_ma3 = input.bool(true,"MA 3      ", inline = "ma3", group = g_mas, display = display.all - display.status_line)
int len_ma3 = input.int(200, "Length", inline = "ma3", group = g_mas, display = display.all - display.status_line)
Timeframe tf_ma3 = input.enum(Timeframe.day1, "Timeframe", tooltip = "Enable, MA length and timeframe for the 3rd configured moving average.", group = g_mas, inline = "ma3", display = display.all - display.status_line)
bool bool_ma4 = input.bool(false,"MA 4      ", inline = "ma4", group = g_mas, display = display.all - display.status_line)
int len_ma4 = input.int(200, "Length", inline = "ma4", group = g_mas, display = display.all - display.status_line)
Timeframe tf_ma4 = input.enum(Timeframe.day1, "Timeframe", tooltip = "Enable, MA length and timeframe for the 4th configured moving average.", group = g_mas, inline = "ma4", display = display.all - display.status_line)
bool bool_ma5 = input.bool(false,"MA 5      ", inline = "ma5", group = g_mas, display = display.all - display.status_line)
int len_ma5 = input.int(200, "Length", inline = "ma5", group = g_mas, display = display.all - display.status_line)
Timeframe tf_ma5 = input.enum(Timeframe.day1, "Timeframe", tooltip = "Enable, MA length and timeframe for the 5th configured moving average.", group = g_mas, inline = "ma5", display = display.all - display.status_line)

bool showPrices = input.bool(false, "Show prices on labels", group = g_display, display = display.all - display.status_line)
LabelStyle eLabelStyle = input.enum(LabelStyle._tag, "Label style", tooltip = "Tag style looks like a tag. Text style is a simple text label.", group = g_display, display = display.all - display.status_line)
int labelOffset = input.int(10, "Label offset", tooltip = "Number of bars into the future that the labels are shown. Prevents overlaps with other indicator labels.", group = g_display, display = display.all - display.status_line)
ExtendLR extendLR = input.enum(ExtendLR.none, "Extend lines", tooltip = "Extend the lines left and/or right for the current day", group = g_display, display = display.all - display.status_line)
color lineColour = input.color(color.blue, "Colour", inline = "cst", group = g_display, display = display.all - display.status_line)
Style lineStyle = input.enum(Style.solid, "Style", inline = "cst", group = g_display, display = display.all - display.status_line)
int lineThickness = input.int(1, "Thickness", 1, 6, inline = "cst", tooltip = "Line colour, style and thickness for all MAs. To use various lines styles, add multiple instances on this indicator to your chart and confiure each one separately.", group = g_display, display = display.all - display.status_line)

// ---- Functions

//@function             Utility function for debug logging.
//@param logPredicate   Predicate to allow control of which bar the debug function creates output. Setting to true will produce a message on every bar
//@param message        The string to log
//@returns              Nothing
//Dependancy            Global const bool DEBUG_MODE controlling whether this produces any log output
debug(bool logPredicate, string message) =>
    if DEBUG_MODE and logPredicate
        log.info(message)

//@function     Helper function to be used with the Style helper enum. Useful for use with the style parameter of functions like plot, line, label, etc
getStyle(Style style) =>
    switch style
        Style.solid => line.style_solid
        Style.dashed => line.style_dashed
        Style.dotted => line.style_dotted

//@function     Helper function to be used with the ExtendLR helper enum. Useful for use with the extend parameter of functions like plot, line, label, etc
getExtendLR(ExtendLR extendLR) =>
    switch extendLR
        ExtendLR.none => extend.none
        ExtendLR.left => extend.left
        ExtendLR.right => extend.right
        ExtendLR.both => extend.both

//@function         Construct a label text string
//@param labelText  The base text, always shows
//@param _showPrice A bool indicating whether to show the price after the base text
//@param price      The relevant price level
//@returns          White or black,  whichever it the bext text colour
getLabelText(string labelText, bool _showPrice, float price) =>
    labelText + (_showPrice ? ": " + str.tostring(price, "#.00") : na)


//@function         Function to give best text colour given background colour (taking into account transparency and the canvas, assuming lightMode is correctly set)
//@param bgcolour   The background colour of the element on which the text is drawn
//@returns          White or black, whichever is the best text colour
contrastTextColour(color bgColour) =>
    bool lightMode = false
    if eLabelStyle == LabelStyle._text
        bgColour
    else
        transparency = color.t(bgColour) / 100.0
        r = ((1 - transparency) * color.r(bgColour) + (lightMode ? transparency * 255 : 0)) / 255
        g = ((1 - transparency) * color.g(bgColour) + (lightMode ? transparency * 255 : 0)) / 255
        b = ((1 - transparency) * color.b(bgColour) + (lightMode ? transparency * 255 : 0)) / 255
        lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        lum > 0.5 ? color.rgb(0, 0, 0) : color.white

tFEnumtoTFString(Timeframe _timeframe) =>
    switch _timeframe
        Timeframe.min1 => "1"
        Timeframe.min2 => "2"
        Timeframe.min5 => "5"
        Timeframe.min15 => "15"
        Timeframe.min30 => "30"
        Timeframe.hour1 => "60"
        Timeframe.hour2 => "120"
        Timeframe.hour4 => "240"
        Timeframe.day1 => "1D"
        Timeframe.week1 => "1W"
        Timeframe.month1 => "1M"

calcMA(MAType _maType, float _source, int _len_ma) =>
    switch _maType
        MAType.sma => ta.sma(_source, _len_ma)
        MAType.ema => ta.ema(_source, _len_ma)        
        MAType.rma => ta.rma(_source, _len_ma)

ltfCalc(MAType _maType, array<float> _currentArr, int _len_ma, bool _waitConfirm) =>
    var float ma = source
    float pop = na
    if not barstate.isconfirmed and _waitConfirm and array.size(_currentArr) > 0                
        pop := array.pop(_currentArr)                
    switch 
        _maType == MAType.sma =>
            var array<float> sourceArr = array.new<float>()
            array.concat(sourceArr, _currentArr)
            while array.size(sourceArr) > _len_ma
                array.shift(sourceArr)
            ma := array.avg(sourceArr)            
        _maType == MAType.ema or _maType == MAType.rma =>            
            if array.size(_currentArr) > 0
                float alpha = _maType == MAType.ema ? 2 / (_len_ma + 1) : 1 / _len_ma
                for i = 0 to array.size(_currentArr) - 1
                    ma := alpha * array.get(_currentArr, i) + (1 - alpha) * ma         
    ma
    

// ---- Logic

// Get values from daily timeframe

string tfString1 = tFEnumtoTFString(tf_ma1)
string tfString2 = tFEnumtoTFString(tf_ma2)
string tfString3 = tFEnumtoTFString(tf_ma3)
string tfString4 = tFEnumtoTFString(tf_ma4)
string tfString5 = tFEnumtoTFString(tf_ma5)

debug(barstate.islastconfirmedhistory, tfString1)

simple string ticker = useRTH ? ticker.modify(syminfo.main_tickerid, session.regular) : syminfo.main_tickerid
float ma1 = request.security(ticker, tfString1, calcMA(maType, waitConfirm ? source[1] : source, len_ma1))
float ma2 = request.security(ticker, tfString2, calcMA(maType, waitConfirm ? source[1] : source, len_ma2))
float ma3 = request.security(ticker, tfString3, calcMA(maType, waitConfirm ? source[1] : source, len_ma3))
float ma4 = request.security(ticker, tfString4, calcMA(maType, waitConfirm ? source[1] : source, len_ma4))
float ma5 = request.security(ticker, tfString5, calcMA(maType, waitConfirm ? source[1] : source, len_ma5))
array<float> ltf_currentSource1 = request.security_lower_tf(ticker, tfString1, source, ignore_invalid_timeframe = true, calc_bars_count = len_ma1)
array<float> ltf_currentSource2 = request.security_lower_tf(ticker, tfString2, source, ignore_invalid_timeframe = true, calc_bars_count = len_ma2)
array<float> ltf_currentSource3 = request.security_lower_tf(ticker, tfString3, source, ignore_invalid_timeframe = true, calc_bars_count = len_ma3)
array<float> ltf_currentSource4 = request.security_lower_tf(ticker, tfString4, source, ignore_invalid_timeframe = true, calc_bars_count = len_ma4)
array<float> ltf_currentSource5 = request.security_lower_tf(ticker, tfString5, source, ignore_invalid_timeframe = true, calc_bars_count = len_ma5)

ma1 := timeframe.in_seconds() > timeframe.in_seconds(tFEnumtoTFString(tf_ma1)) and bool_ma1 ? ltfCalc(maType, ltf_currentSource1, len_ma1, waitConfirm) : ma1
ma2 := timeframe.in_seconds() > timeframe.in_seconds(tFEnumtoTFString(tf_ma2)) and bool_ma2 ? ltfCalc(maType, ltf_currentSource2, len_ma2, waitConfirm) : ma2
ma3 := timeframe.in_seconds() > timeframe.in_seconds(tFEnumtoTFString(tf_ma3)) and bool_ma3 ? ltfCalc(maType, ltf_currentSource3, len_ma3, waitConfirm) : ma3
ma4 := timeframe.in_seconds() > timeframe.in_seconds(tFEnumtoTFString(tf_ma4)) and bool_ma4 ? ltfCalc(maType, ltf_currentSource4, len_ma4, waitConfirm) : ma4
ma5 := timeframe.in_seconds() > timeframe.in_seconds(tFEnumtoTFString(tf_ma5)) and bool_ma5 ? ltfCalc(maType, ltf_currentSource5, len_ma5, waitConfirm) : ma5

var int bi_ma1Start = na
var int bi_ma2Start = na
var int bi_ma3Start = na
var int bi_ma4Start = na
var int bi_ma5Start = na
bi_ma1Start := timeframe.change(tfString1) ? time : bi_ma1Start
bi_ma2Start := timeframe.change(tfString2) ? time : bi_ma2Start
bi_ma3Start := timeframe.change(tfString3) ? time : bi_ma3Start
bi_ma4Start := timeframe.change(tfString4) ? time : bi_ma4Start
bi_ma5Start := timeframe.change(tfString5) ? time : bi_ma5Start

// ---- Visuals

string labelStyle = switch eLabelStyle
    LabelStyle._tag => label.style_label_left
    LabelStyle._text => label.style_none

string textAlign = text.align_right

int labelOffsetTime = labelOffset * timeframe.in_seconds() * 1000

var line ln_ma1 = bool_ma1 ? line.new(bi_ma1Start, ma1, time, ma1, xloc = xloc.bar_time, extend = getExtendLR(extendLR), color = lineColour, style = getStyle(lineStyle), width = lineThickness) : na
var line ln_ma2 = bool_ma2 ? line.new(bi_ma2Start, ma2, time, ma2, xloc = xloc.bar_time, extend = getExtendLR(extendLR), color = lineColour, style = getStyle(lineStyle), width = lineThickness) : na
var line ln_ma3 = bool_ma3 ? line.new(bi_ma3Start, ma3, time, ma3, xloc = xloc.bar_time, extend = getExtendLR(extendLR), color = lineColour, style = getStyle(lineStyle), width = lineThickness) : na
var line ln_ma4 = bool_ma4 ? line.new(bi_ma4Start, ma4, time, ma4, xloc = xloc.bar_time, extend = getExtendLR(extendLR), color = lineColour, style = getStyle(lineStyle), width = lineThickness) : na
var line ln_ma5 = bool_ma5 ? line.new(bi_ma5Start, ma5, time, ma5, xloc = xloc.bar_time, extend = getExtendLR(extendLR), color = lineColour, style = getStyle(lineStyle), width = lineThickness) : na
var label lb_ma1 = bool_ma1 ? label.new(time + labelOffsetTime, ma1, getLabelText(str.tostring(tf_ma1) + " " + str.tostring(len_ma1) + str.tostring(maType), showPrices, ma1), xloc = xloc.bar_time, color = lineColour, style = labelStyle, textcolor = contrastTextColour(lineColour), textalign = textAlign) : na
var label lb_ma2 = bool_ma2 ? label.new(time + labelOffsetTime, ma2, getLabelText(str.tostring(tf_ma2) + " " + str.tostring(len_ma2) + str.tostring(maType), showPrices, ma2), xloc = xloc.bar_time, color = lineColour, style = labelStyle, textcolor = contrastTextColour(lineColour), textalign = textAlign) : na
var label lb_ma3 = bool_ma3 ? label.new(time + labelOffsetTime, ma3, getLabelText(str.tostring(tf_ma3) + " " + str.tostring(len_ma3) + str.tostring(maType), showPrices, ma3), xloc = xloc.bar_time, color = lineColour, style = labelStyle, textcolor = contrastTextColour(lineColour), textalign = textAlign) : na
var label lb_ma4 = bool_ma4 ? label.new(time + labelOffsetTime, ma4, getLabelText(str.tostring(tf_ma4) + " " + str.tostring(len_ma4) + str.tostring(maType), showPrices, ma4), xloc = xloc.bar_time, color = lineColour, style = labelStyle, textcolor = contrastTextColour(lineColour), textalign = textAlign) : na
var label lb_ma5 = bool_ma5 ? label.new(time + labelOffsetTime, ma5, getLabelText(str.tostring(tf_ma5) + " " + str.tostring(len_ma5) + str.tostring(maType), showPrices, ma5), xloc = xloc.bar_time, color = lineColour, style = labelStyle, textcolor = contrastTextColour(lineColour), textalign = textAlign) : na

// Visual are updated on every last bar
if barstate.islast
    
    ln_ma1.set_xy1(bi_ma1Start, ma1)
    ln_ma2.set_xy1(bi_ma2Start, ma2)
    ln_ma3.set_xy1(bi_ma3Start, ma3)
    ln_ma4.set_xy1(bi_ma4Start, ma4)
    ln_ma5.set_xy1(bi_ma5Start, ma5)

    ln_ma1.set_xy2(time + labelOffsetTime, ma1)
    ln_ma2.set_xy2(time + labelOffsetTime, ma2)
    ln_ma3.set_xy2(time + labelOffsetTime, ma3)
    ln_ma4.set_xy2(time + labelOffsetTime, ma4)
    ln_ma5.set_xy2(time + labelOffsetTime, ma5)

    lb_ma1.set_xy(time + labelOffsetTime, ma1)
    lb_ma2.set_xy(time + labelOffsetTime, ma2)
    lb_ma3.set_xy(time + labelOffsetTime, ma3)
    lb_ma4.set_xy(time + labelOffsetTime, ma4)
    lb_ma5.set_xy(time + labelOffsetTime, ma5)

    lb_ma1.set_text(getLabelText(str.tostring(tf_ma1) + " " + str.tostring(len_ma1) + str.tostring(maType), showPrices, ma1))
    lb_ma2.set_text(getLabelText(str.tostring(tf_ma2) + " " + str.tostring(len_ma2) + str.tostring(maType), showPrices, ma2))
    lb_ma3.set_text(getLabelText(str.tostring(tf_ma3) + " " + str.tostring(len_ma3) + str.tostring(maType), showPrices, ma3))
    lb_ma4.set_text(getLabelText(str.tostring(tf_ma4) + " " + str.tostring(len_ma4) + str.tostring(maType), showPrices, ma4))
    lb_ma5.set_text(getLabelText(str.tostring(tf_ma5) + " " + str.tostring(len_ma5) + str.tostring(maType), showPrices, ma5))

// ---- Alerts

bool ma1Cross = ta.cross(close, ma1) and bool_ma1
bool ma2Cross = ta.cross(close, ma2) and bool_ma2
bool ma3Cross = ta.cross(close, ma3) and bool_ma3
bool ma4Cross = ta.cross(close, ma4) and bool_ma4
bool ma5Cross = ta.cross(close, ma5) and bool_ma5

alertcondition(ma1Cross or ma2Cross or ma3Cross or ma4Cross or ma5Cross, "Price crossing any enabled MA", "{{ticker}} crossed a enabled MA at {{time}}")
````
