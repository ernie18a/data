# Really Initial Balance [BruzX]

- url: https://www.tradingview.com/script/6xpKtmNo-Really-Initial-Balance-BruzX/
- type: indicator
- pine_id: PUB;b72a92086d774c909e22e6e5cc7537a1
- version: 8.0

## Description

█ OVERVIEW

This indicator simply shows the Initial Balance for the current session. The lines point to the bars where the Initial Balance high and low were set. This indicator always shows the correct Initial Balance on all chart timeframes of 1min or greater. This is the case even when bars span across the Initial Balance start and end time boundaries. This feature differentiates from other Initial Balance indicators.

█ FEATURES
[list]
[*] Shows the the Initial Balance for the current session in a visually appealing way
[*] If the Initial Balance time range has not started yet for the current session, nothing is shown. 
[*] Shows the correct Initial Balance on all chart timeframes above 1min
[*] Visually similar to the Really Key Levels indicator.
[/list]
█ CONCEPTS

The Initial Balance (IB) time period is usually considered to be 09:30-10:30 ET for the US stock market. When the current chart timeframe is such that bars do not fall exactly on the IB start and end times, care must be taken to ensure that price action outside the IB time range doesn't "leak" into the shown IB. For example, on an ETH chart with a 1h timeframe the open candle at the open actually starts at 9am and ends at 10am, therefore spanning across the IB start time of 09:30. This indicator internally always queries the 1min timeframe, irrespective of the chart timeframe, and takes care to ensure that only the price action exactly within the IB time range is used.

Though this is visually and conceptually similar to Really Key Levels, it is kept separate since Really Key Levels is intended to be used globally, whereas the concept of an IB from 09:30-10:30 ET is specific to the US stock markets. 

█ LIMITATIONS

Internally the indicator uses the 1min timeframe and assumes the chart timeframe using this this or greater. Therefore it doesn't work properly for seconds or tick-based timeframes. 

█ DISCLAIMER

This indicator is provided for information only and should not be used in isolation without a good understand of the system and without considering other factors. You should not take trades using real money based solely on what this indicator says. Any trades you take are entirely at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BruzX

//@version=6
indicator("Really Initial Balance [BruzX]", shorttitle = "RIB", overlay = true, max_bars_back = 1440)

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

//#region ---- Enums

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
    _none = "None"

enum BoxLocation
    no = "None"
    tl = "Top Left"
    tc = "Top Centre"
    tr = "Top Right"
    ml = "Middle Left"
    mc = "Middle Centre"
    mr = "Middle Right"
    bl = "Bottom Left"
    bc = "Bottom Centre"
    br = "Bottom Right"

//#endregion ---- Enums

//#region ---- UDTs

//#endregion ---- UDTs

//#region ---- Constants

//#endregion ---- Constants

//#region ---- Inputs

string iBSession = input.session("0930-1030", "Initial Balance Session", tooltip = "")
string timezone = input.string("America/New_York", "Timezone", options = ["Exchange", "Pacific/Honolulu", "America/Anchorage", "America/Los_Angeles", "America/Denver", "America/Chicago", "America/New_York", "America/Halifax", "America/Argentina/Buenos_Aires", "Europe/London", "Europe/Berlin", "Europe/Moscow", "Asia/Dubai", "Asia/Karachi", "Asia/Kolkata", "Asia/Bangkok", "Asia/Shanghai", "Asia/Tokyo", "Australia/Brisbane", "Australia/Sydney", "Pacific/Auckland"], tooltip = "Timezone for the Initial Balance. \"Exchange\" uses the timezone of the exchange. They are ordered from largest negative offset from UTC to largest positive offset.", display = display.all - display.status_line)

bool b_ibHigh = input.bool(true, "IB High", inline = "high")
color c_ibHigh = input.color(color.rgb(247, 124, 128), " ", inline = "high")
Style l_ibHigh = input.enum(Style.solid, " ", display =display.all - display.status_line, inline = "high")
int w_ibHigh = input.int(1, "Thickness", 1, 6, display = display.all - display.status_line, inline = "high")

bool b_ibLow = input.bool(true, "IB Low ", inline = "low")
color c_ibLow = input.color(color.rgb(161, 236, 174), " ", inline = "low")
Style l_ibLow = input.enum(Style.solid, " ", display = display.all - display.status_line, inline = "low")
int w_ibLow = input.int(1, "Thickness", 1, 6, display = display.all - display.status_line, inline = "low")

bool showLf = input.bool(false, "Shade", tooltip = "Shade the area between the high and low lines", inline = "shade", display = display.all - display.status_line)
color c_lf = input.color(color.new(color.yellow, 80), "  ", inline = "shade", display = display.all - display.status_line)

bool showPrices = input.bool(false, "Show prices on labels", display = display.all - display.status_line)
bool showPeriod = input.bool(false, "Show period on labels", tooltip = "Controls where to show the time period of the set IB session on the label in minutes.",  display = display.all - display.status_line)
bool showHist = input.bool(false, "Show historical", tooltip = "When set, shows the IB on historic session as far as your TradingView allows. Otherwise shows IB only on the current session.", display = display.all - display.status_line)
bool showLabelsHist = input.bool(false, "Show labels on historical", tooltip = "When historical IBs are enable, this control where to show all labels also on those historical lines.", display = display.all - display.status_line)

LabelStyle eLabelStyle = input.enum(LabelStyle._tag, "Label style", tooltip = "Tag style looks like a tag. Text style is a simple text label.", display = display.all - display.status_line)
int labelOffset = input.int(10, "Label offset", tooltip = "Number of bars into the future that the labels are shown. Prevents overlaps with other indicator labels.", display = display.all - display.status_line)
string suffix = input.string("", "Label suffix", tooltip = "Adds some text as a suffix to each label, which allows disambiguation of multiple instances of the indicator on the chart.", display = display.all - display.status_line)
ExtendLR extendLR = input.enum(ExtendLR.none, "Extend lines", tooltip = "Extend the lines left and/or right for the current day", display = display.all - display.status_line)
BoxLocation boxLocation = input.enum(BoxLocation.no, "Info box location", tooltip = "Show an info box with the IB range to 14-day ATR ratio.", display = display.all - display.status_line)

bool emulateRth = input.bool(true, "Emulate RTH", tooltip = "Used only when showing the info box. Emulates an RTH on futures using the session times set below. The ATR is then calculated using only the true range within this defined regular session. The ATR is only needed for calculating the IB/ATR ratio shown in the info box.", group = "Futures", display = display.all - display.status_line)
string futureRegSess = input.session("0930-1600", "RTH session", tooltip = "Used only when showing the info box. Sets the emulated regular trading hours session used for ATR calculation. No effect if \"Emulate RTH\" is disabled.", group = "Futures", display = display.all - display.status_line)

bool showRetExt = input.bool(false, "Retracement & extention levels", inline = "retext1", group = "Retracements & extensions",  display = display.all - display.status_line)
string retExtLevelString = input.string("25, 50, 150, 200, 250", " ", tooltip = "Specifies levels for retracements and extensions. Values 0-100 are retracements, above 100 are extensions. Even though extensions are specified as values above 100, in the label on the chart they will have 100 substracted. So for example 150 specified here is a 50% extension outside the IB range and will show as 50% on the label. Each line is anchored to either the IB high or low, and when these are both enabled, the specified levels are mirrored on both IB lines. This means that to show retracements of 25% and 75% for example, it's sufficient to specify only 25, since it is mirrored on both IB high and low.", inline = "retext1", group = "Retracements & extensions",  display = display.all - display.status_line)
bool showRetExtLb = input.bool(true, "Show retracement & extension labels", tooltip = "Controls whether to show labels also on the retracement and extension lines.", group = "Retracements & extensions",  display = display.all - display.status_line)
color c_retExt = input.color(color.new(color.yellow, 50), "Lines", group = "Retracements & extensions", inline = "retext2", display = display.all - display.status_line)
Style l_retExt = input.enum(Style.dotted, "", group = "Retracements & extensions", inline = "retext2", display = display.all - display.status_line)
int w_retExt = input.int(1, "Thickness", 1, 6, tooltip = "Controls line colour, stype and with for retracement and extension lines.",  inline = "retext2", group = "Retracements & extensions", display = display.all - display.status_line)

//#endregion ---- Inputs

//#region ---- Functions

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

sessionMinutes(string session) =>
    int startMinutes = int(str.tonumber(str.substring(session, 0, 2))) * 60 + int(str.tonumber(str.substring(session, 2, 4)))
    int endMinutes = int(str.tonumber(str.substring(session, 5, 7))) * 60 + int(str.tonumber(str.substring(session, 7, 9)))
    endMinutes < startMinutes ? endMinutes + 1440 - startMinutes : endMinutes - startMinutes

//@function         Construct a label text string
getLabelText(string labelText, bool _showPeriod, string _iBSession, bool _showPrice, float price, string _suffix) =>
    labelText + " " + suffix + (_showPeriod ? " (" + str.tostring(sessionMinutes(_iBSession)) + "m)" : na) + (_showPrice ? ": " + str.tostring(price, "#.00") : na)

//@function         Function to give best text colour given background colour (taking into account transparency and the canvas, assuming lightMode is correctly set)
contrastTextColour(color bgColour) =>
    bool darkMode = false
    if eLabelStyle == LabelStyle._text
        bgColour
    else
        transparency = color.t(bgColour) / 100.0
        r = ((1 - transparency) * color.r(bgColour) + (darkMode ? 0 : transparency * 255)) / 255
        g = ((1 - transparency) * color.g(bgColour) + (darkMode ? 0 : transparency * 255)) / 255
        b = ((1 - transparency) * color.b(bgColour) + (darkMode ? 0 : transparency * 255)) / 255
        lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        lum > 0.5 ? color.rgb(0, 0, 0) : color.white

//#endregion ---- Functions

//#region ---- Logic

bool isFutures = syminfo.type == "futures"

if timezone == "Exchange"
    timezone := syminfo.timezone

var bool iBSet = false
var float ibHigh = na
var float ibLow = na
var int bi_ibHigh = na
var int bi_ibLow = na

if timeframe.change("1D")
    iBSet := false
    ibHigh := na
    ibLow := na
    bi_ibHigh := na
    bi_ibLow := na

[isIB, highs, lows] = request.security_lower_tf(syminfo.main_tickerid, "1", [not na(time("1", iBSession, timezone)), high, low])//, calc_bars_count = 1440)

float dailyAtr = na

if isFutures and emulateRth
    bool isRth = not na(time(timeframe.period, futureRegSess, timezone))

    // Hacky way to determine if the user has set futures RTH to full time range (i.e. all bars are in RTH). Need to handle this specially since regStartBar and postStarBar would never trigger without it.
    var bool allRth = true
    allRth := isRth and allRth
    bool forceStart = false
    if allRth
        int startHour = int(str.tonumber(str.substring(futureRegSess, 0, 2)))
        int startMinute = int(str.tonumber(str.substring(futureRegSess, 2, 4)))
        int sessionStartTime = timestamp(timezone, year(time, timezone), month(time, timezone), dayofmonth(time, timezone), startHour, startMinute)
        forceStart := time == sessionStartTime

    bool regStartBar = isRth and not isRth[1] or forceStart
    bool postStarBar = not isRth and isRth[1] or forceStart

    float sessionHigh = ta.highest(nz(ta.barssince(regStartBar)) + 1)
    float sessionLow = ta.lowest(nz(ta.barssince(regStartBar)) + 1)

    var float _avgRange = na
    var float _pdc = na

    if postStarBar
        float trueRange = not na(_pdc) ? math.max(sessionHigh[1], _pdc) - math.min(sessionLow[1], _pdc) : sessionHigh - sessionLow
        int atrLength = 14
        _avgRange := na(_avgRange) ? trueRange : (trueRange + _avgRange * (atrLength - 1)) / atrLength 
        _pdc := close[1]

    dailyAtr := _avgRange
else   
    dailyAtr := request.security(syminfo.main_tickerid, "1D", ta.atr(14)[1], lookahead = barmerge.lookahead_on)

bool isOnLastSession = year(time, timezone) == year(last_bar_time, timezone) and month(time, timezone) == month(last_bar_time, timezone) and dayofmonth(time,timezone) == dayofmonth(last_bar_time, timezone)
                   or year(time_tradingday, "UTC") == year(last_bar_time, timezone) and month(time_tradingday, "UTC") == month(last_bar_time, timezone) and dayofmonth(time_tradingday, "UTC") == dayofmonth(last_bar_time, timezone)                   

if (isOnLastSession or showHist) and isIB.size() > 0
    for i = 0 to isIB.size() - 1
        if isIB.get(i)
            if not iBSet
                iBSet := true
                ibHigh := highs.get(i)
                ibLow := lows.get(i)
                bi_ibHigh := bar_index
                bi_ibLow := bar_index                
            if highs.get(i) > ibHigh
                ibHigh := highs.get(i)
                bi_ibHigh := bar_index
            if lows.get(i) < ibLow
                ibLow := lows.get(i)
                bi_ibLow := bar_index

float ibRange = ibHigh - ibLow
float ibAtrRatio = ibRange / dailyAtr

//#endregion ---- Logic

//#region ---- Visuals

var bool setup = false
var line ln_ibHigh = na
var line ln_ibLow = na
var label lb_ibHigh = na
var label lb_ibLow = na
var linefill lf = na
array<string> retExtLevels = str.split(retExtLevelString, ",")
var array<line> retExtLnL = array.new<line>()
var array<line> retExtLnH = array.new<line>()
var array<label> retExtLbL = array.new<label>()
var array<label> retExtLbH = array.new<label>()

if barstate.islast or showHist
    string labelStyle = switch eLabelStyle
        LabelStyle._tag => label.style_label_left
        LabelStyle._text => label.style_none

    string textAlign = text.align_right

    for i = 0 to retExtLevels.size() - 1
        string newString = str.trim(array.get(retExtLevels, i))
        array.set(retExtLevels, i, newString)

    if setup and timeframe.change("1D")
        setup := false
        if not showLabelsHist
            label.delete(lb_ibHigh)
            label.delete(lb_ibLow)
            line.set_x2(ln_ibHigh, bar_index - 1)
            line.set_x2(ln_ibLow, bar_index - 1)
        if not showHist
            line.delete(ln_ibHigh)
            line.delete(ln_ibLow)            
            linefill.delete(lf)
        else 
            line.set_extend(ln_ibHigh, extend = extend.none)
            line.set_extend(ln_ibLow, extend = extend.none)
        if showRetExt
            if not showLabelsHist
                while array.size(retExtLbL) > 0
                    label.delete(array.pop(retExtLbL))
                while array.size(retExtLbH) > 0
                    label.delete(array.pop(retExtLbH))
                if showHist
                    if retExtLnL.size() > 0
                        for i = 0 to retExtLnL.size() - 1                        
                            line.set_x2(retExtLnL.get(i), bar_index - 1)
                    if retExtLnH.size() > 0
                        for i = 0 to retExtLnH.size() - 1                        
                            line.set_x2(retExtLnH.get(i), bar_index - 1)
            if not showHist                            
                while array.size(retExtLnL) > 0
                    line.delete(array.pop(retExtLnL))
                while array.size(retExtLnH) > 0
                    line.delete(array.pop(retExtLnH))
            else
                if retExtLnL.size() > 0
                    for i = 0 to retExtLnL.size() - 1                  
                        line.set_extend(retExtLnL.get(i), extend = extend.none)
                if retExtLnH.size() > 0
                    for i = 0 to retExtLnH.size() - 1                        
                        line.set_extend(retExtLnH.get(i), extend = extend.none)
            retExtLnL := array.new<line>()
            retExtLnH := array.new<line>()
            retExtLbL := array.new<label>()
            retExtLbH := array.new<label>()

    if not setup and iBSet
        setup := true
        ln_ibHigh := b_ibHigh ? line.new(bi_ibHigh, ibHigh, bar_index + labelOffset, ibHigh, extend = getExtendLR(extendLR), color = c_ibHigh, style = getStyle(l_ibHigh), width = w_ibHigh) : na
        ln_ibLow := b_ibLow ? line.new(bi_ibLow, ibLow, bar_index + labelOffset, ibLow, extend = getExtendLR(extendLR), color = c_ibLow, style = getStyle(l_ibLow), width = w_ibLow) : na
        if eLabelStyle != LabelStyle._none
            lb_ibHigh := b_ibHigh ? label.new(bar_index + labelOffset, ibHigh, getLabelText("IB High", showPeriod, iBSession, showPrices, ibHigh, suffix), color = c_ibHigh, style = labelStyle, textcolor = contrastTextColour(c_ibHigh), textalign = textAlign) : na
            lb_ibLow := b_ibLow ? label.new(bar_index + labelOffset, ibLow, getLabelText("IB Low", showPeriod, iBSession, showPrices, ibLow, suffix), color = c_ibLow, style = labelStyle, textcolor = contrastTextColour(c_ibLow), textalign = textAlign) : na
        if showLf
            lf := linefill.new(ln_ibLow, ln_ibHigh, c_lf)
        if showRetExt
            for level in retExtLevels
                float levelNum = str.tonumber(level)
                float valL = levelNum <= 100 ? ibLow + levelNum / 100 * ibRange : ibLow - (levelNum - 100) / 100 * ibRange
                float valH = levelNum <= 100 ? ibHigh - levelNum / 100 * ibRange : ibHigh + (levelNum - 100) / 100 * ibRange

                bool hideH50 = b_ibLow and level == "50"

                int bar = math.min(bi_ibHigh, bi_ibLow)                 
                if b_ibLow
                    array.push(retExtLnL, line.new(bar, valL, bar_index + (showRetExtLb ? labelOffset : 0), valL, extend = getExtendLR(extendLR), color = c_retExt, style = getStyle(l_retExt), width = w_retExt))                
                if b_ibHigh
                    line ln = line.new(bar, valH, bar_index + (showRetExtLb ? labelOffset : 0), valH, extend = getExtendLR(extendLR), color = c_retExt, style = getStyle(l_retExt), width = w_retExt)
                    if hideH50
                        line.set_color(ln, color.new(c_retExt, 100))
                    array.push(retExtLnH, ln)
 
                if showRetExtLb and eLabelStyle != LabelStyle._none
                    string displayLevel = levelNum <= 100 ? level : str.tostring(levelNum - 100)
                    if b_ibLow                        
                        label lb = label.new(bar_index + labelOffset, valL, getLabelText(displayLevel + "%", showPeriod, iBSession, showPrices, valL, suffix), color = c_retExt, style = labelStyle, textcolor = contrastTextColour(c_retExt), textalign = textAlign)
                        array.push(retExtLbL, lb)
                    if b_ibHigh
                        label lb = label.new(bar_index + labelOffset, valH, getLabelText(displayLevel + "%", showPeriod, iBSession, showPrices, valH, suffix), color = c_retExt, style = labelStyle, textcolor = contrastTextColour(c_retExt), textalign = textAlign)
                        if hideH50
                            label.set_textcolor(lb, color.new(c_retExt, 100))
                            label.set_color(lb, color.new(c_retExt, 100))
                        array.push(retExtLbH, lb)
                 
    if setup        
        line.set_xy1(ln_ibHigh, bi_ibHigh, ibHigh)
        line.set_xy2(ln_ibHigh, bar_index + labelOffset, ibHigh)
        line.set_xy1(ln_ibLow, bi_ibLow, ibLow)
        line.set_xy2(ln_ibLow, bar_index + labelOffset, ibLow)
        label.set_xy(lb_ibHigh, bar_index + labelOffset, ibHigh)
        label.set_xy(lb_ibLow, bar_index + labelOffset, ibLow)
        label.set_text(lb_ibHigh, getLabelText("IB High", showPeriod, iBSession, showPrices, ibHigh, suffix))
        label.set_text(lb_ibLow, getLabelText("IB Low", showPeriod, iBSession, showPrices, ibLow, suffix))
        if showRetExt
            if b_ibLow and retExtLnL.size() > 0
                for i = 0 to retExtLnL.size() - 1
                    line lnL = retExtLnL.get(i)
                    float levelNum = str.tonumber(retExtLevels.get(i))             
                    float valL = levelNum <= 100 ? ibLow + levelNum / 100 * ibRange : ibLow - (levelNum - 100) / 100 * ibRange
                    line.set_xy1(lnL, math.min(bi_ibHigh, bi_ibLow), valL)
                    line.set_xy2(lnL, bar_index + labelOffset, valL)                
                    if showRetExtLb and eLabelStyle != LabelStyle._none                        
                        label.set_xy(retExtLbL.get(i), bar_index + labelOffset, valL)
                        string displayLevel = levelNum <= 100 ? retExtLevels.get(i) : str.tostring(levelNum - 100)
                        label.set_text(retExtLbL.get(i), getLabelText(displayLevel + "%", showPeriod, iBSession, showPrices, valL, suffix))
            if b_ibHigh and retExtLnH.size() > 0
                for i = 0 to retExtLnH.size() - 1                
                    line lnH = retExtLnH.get(i)   
                    float levelNum = str.tonumber(retExtLevels.get(i))                                 
                    float valH = levelNum <= 100 ? ibHigh - levelNum / 100 * ibRange : ibHigh + (levelNum - 100) / 100 * ibRange
                    line.set_xy1(lnH, math.min(bi_ibHigh, bi_ibLow), valH)
                    line.set_xy2(lnH, bar_index + labelOffset, valH)            
                    if showRetExtLb and eLabelStyle != LabelStyle._none                        
                        label.set_xy(retExtLbH.get(i), bar_index + labelOffset, valH)
                        string displayLevel = levelNum <= 100 ? retExtLevels.get(i) : str.tostring(levelNum - 100)
                        label.set_text(retExtLbH.get(i), getLabelText(displayLevel + "%", showPeriod, iBSession, showPrices, valH, suffix))

// IB to ATR ratio info box
if barstate.islast and boxLocation != BoxLocation.no
    string _boxLocation = switch boxLocation
        BoxLocation.tl => position.top_left
        BoxLocation.tc => position.top_center
        BoxLocation.tr => position.top_right        
        BoxLocation.ml => position.middle_left
        BoxLocation.mc => position.middle_center
        BoxLocation.mr => position.middle_right
        BoxLocation.bl => position.bottom_left
        BoxLocation.bc => position.bottom_center        
        BoxLocation.br => position.bottom_right

    
    var table infoBox = table.new(_boxLocation, 1, 1, color.black, color.white, 1, color.white, 1)
    string infoText = switch
        ibAtrRatio < 0.5 => " (Narrow)"
        ibAtrRatio >= 0.5 and ibAtrRatio < 1 => " (Normal)"
        ibAtrRatio >= 1 and ibAtrRatio < 1.5 => " (Wide)"
        ibAtrRatio >= 1.5 => " (Extreme)"
    
    if na(ibRange)
        infoText := "Waiting for IB"
    else
        infoText := "IB/ATR: " + str.tostring(ibAtrRatio, "0%") + infoText
    
    infoBox.cell(0, 0, infoText, text_color = color.white)

//#endregion ---- Visuals

//#region ---- Alerts

alertcondition(ta.cross(close, ibHigh), "IB High", "{{ticker}} crossed IB High at {{time}}")
alertcondition(ta.cross(close, ibLow), "IB Low", "{{ticker}} crossed IB Low at {{time}}")

//#endregion ---- Alerts
````
