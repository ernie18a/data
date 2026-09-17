<!-- tradingview-pine-id: PUB;e65c8e8a74494058a11f3253febb7011 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Directionforce Index

Source: https://www.tradingview.com/script/E5Ui3ZHK-Directionforce-Index/

## Description

Directionforce Index is an oscillator panel that brings sixteen standard indicators and five freely connectable moving averages together in a single script. It is built for traders who want the classic oscillators available side by side instead of loading each one separately, and who would rather keep their remaining indicator slots free for something else. The principle is a single controller: one selection decides which oscillator the panel displays, while every moving average carries its own connection that determines what it is calculated on. The oscillators follow the established standard formulas — among them Average True Range, Relative Strength Index, Stochastic, Money Flow Index and Ultimate Oscillator — and the averages offer the common smoothing methods. The averages are not bound to the panel: one can just as well run on the chart's own price, and the panel itself can show a second security instead of an oscillator, which makes the script usable in both areas at once.

Controller

Switch Oscillator:   selects which of the sixteen oscillators, or the comparison symbol, the panel displays.

Moving Average (present five times, MA 1–MA 5, each instance identically structured)

MA 1–5:              switches the average on or off.
Length:              number of bars the average is calculated over.
Smoothing Type:      SMA, EMA, WMA, VWMA, HMA or RMA.
Connect:             what the average is calculated on — the main chart or any one of the oscillators.
Source:              the price used, and only available while Connect is set to Main Chart.
Style:               Line, Stepline or Circles.
Width:               thickness of the drawn line.
Color:               color of the line.
https://www.tradingview.com/x/gfk1qsEt/

Comparison Symbol

Symbol Option:       which of the five stored symbols is active.
Symbol 1–5:          five freely assignable securities.
Bull / Bear:         two colors for rising and falling candles of that security.
https://www.tradingview.com/x/GPcbSIx9/

Oscillator settings

Each oscillator has its own settings group carrying the parameters it is normally defined by. Most offer a length and a source; where an oscillator conventionally needs more, those inputs are present as well — a smoothing method for Average True Range, a divisor for Ease of Movement, separate lengths for Stochastic RSI, True Strength Index and Ultimate Oscillator.
https://www.tradingview.com/x/BZT3myQy/

Oscillator Graphic

Oscillator Color:    color of the displayed oscillator.
Show Middleline:     switches the middle line on or off.
Background Color:    color of the area between the two bands.
https://www.tradingview.com/x/TSqly9mO/

The panel shows one oscillator at a time, drawn as a single line in the selected color. Where an oscillator is conventionally read against fixed levels, the corresponding bands are drawn as dashed lines with a shaded area between them, and a middle line is added where one is meaningful — the bands sit at the values established for each oscillator, so they change together with the selection. Oscillators without such levels are drawn without bands.

A moving average appears in the panel only while the oscillator it is connected to is the one currently displayed. Averages connected to Main Chart are independent of this and are always drawn on the main chart itself, on the price rather than on an oscillator. This means the same script can occupy the panel and the main chart at the same time, and switching the oscillator changes what is visible in the panel while the main chart stays as it is.

When Comparison Symbol is selected, the panel shows the candles of the chosen security instead of an oscillator, with a price line marking where it currently trades. The name of whatever is displayed appears in the top right corner of the panel.

Two points worth knowing. The volume-based selections — Ease of Movement, Elder Force Index, Money Flow Index, On Balance Volume, Volume itself, and VWMA as a smoothing method — require a symbol that carries volume data; on symbols without it they stay empty or rest on the zero line. And each average is technically plotted twice, once for the main chart and once for the panel, so both entries remain listed in the data window while only the applicable one carries values.

https://www.tradingview.com/x/Nip5bFZy/

A note from the author: I do not use this indicator for any particular purpose myself. It began as an idea I wanted to see through — partly to develop my programming skills further, partly out of curiosity about how far Pine Script would carry a design like this. It turned out to be the most demanding script I had written up to that point. I hope it proves useful to others, whatever they end up doing with it.

This indicator is intended solely for market analysis and does not constitute investment advice or a guarantee of success. Use it at your own discretion and risk; past results are not indicative of future performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © graefe

//@version=6
indicator(title = "Directionforce Index", overlay = false, behind_chart = false)


// Returns the selected moving average type for any source.
f_movingAverage(maType, source, length) =>
    switch maType
        "SMA"  => ta.sma(source, length)
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        "HMA"  => ta.hma(source, length)
        "RMA"  => ta.rma(source, length)
        =>        na


// The option names exist once as constants and are referenced everywhere,
// so a typo becomes a compile error instead of a silent dead option.
const string dfiCon_optMainChart  = "Main Chart"
const string dfiCon_optComparison = "Comparison Symbol"
const string dfiCon_optAtr        = "Average True Range"
const string dfiCon_optCci        = "Commodity Channel Index"
const string dfiCon_optEom        = "Ease of Movement"
const string dfiCon_optEfi        = "Elder Force Index"
const string dfiCon_optMom        = "Momentum"
const string dfiCon_optMfi        = "Money Flow Index"
const string dfiCon_optObv        = "On Balance Volume"
const string dfiCon_optRoc        = "Rate Of Change"
const string dfiCon_optRsi        = "Relative Strength Index"
const string dfiCon_optRvi        = "Relative Volatility Index"
const string dfiCon_optSto        = "Stochastic"
const string dfiCon_optSrs        = "Stochastic RSI"
const string dfiCon_optTsi        = "True Strength Index"
const string dfiCon_optUos        = "Ultimate Oscillator"
const string dfiCon_optVol        = "Volume"
const string dfiCon_optWpr        = "Williams %R"


// The controller selects what appears in the panel; from it a separate flag is
// derived per oscillator, driving both display and the connection of the averages.
string dfiCon_showIndicatorTooltip = "Selects the oscillator shown in the panel.\n\nA moving average only appears while the oscillator it is connected to is selected here. Averages set to Main Chart are unaffected and always plot on the main chart."
string dfiInp_showOsc = input.string(defval = dfiCon_optRsi, title = "Switch Oscillator", options = [dfiCon_optComparison, dfiCon_optAtr, dfiCon_optCci, dfiCon_optEom, dfiCon_optEfi, dfiCon_optMom, dfiCon_optMfi, dfiCon_optObv, dfiCon_optRoc, dfiCon_optRsi, dfiCon_optRvi, dfiCon_optSto, dfiCon_optSrs, dfiCon_optTsi, dfiCon_optUos, dfiCon_optVol, dfiCon_optWpr], tooltip = dfiCon_showIndicatorTooltip, group = "Controller")
bool dfiCal_showComparison = dfiInp_showOsc == dfiCon_optComparison
bool dfiCal_showAtr        = dfiInp_showOsc == dfiCon_optAtr
bool dfiCal_showCci        = dfiInp_showOsc == dfiCon_optCci
bool dfiCal_showEom        = dfiInp_showOsc == dfiCon_optEom
bool dfiCal_showEfi        = dfiInp_showOsc == dfiCon_optEfi
bool dfiCal_showMom        = dfiInp_showOsc == dfiCon_optMom
bool dfiCal_showMfi        = dfiInp_showOsc == dfiCon_optMfi
bool dfiCal_showObv        = dfiInp_showOsc == dfiCon_optObv
bool dfiCal_showRoc        = dfiInp_showOsc == dfiCon_optRoc
bool dfiCal_showRsi        = dfiInp_showOsc == dfiCon_optRsi
bool dfiCal_showRvi        = dfiInp_showOsc == dfiCon_optRvi
bool dfiCal_showSto        = dfiInp_showOsc == dfiCon_optSto
bool dfiCal_showSrs        = dfiInp_showOsc == dfiCon_optSrs
bool dfiCal_showTsi        = dfiInp_showOsc == dfiCon_optTsi
bool dfiCal_showUos        = dfiInp_showOsc == dfiCon_optUos
bool dfiCal_showVol        = dfiInp_showOsc == dfiCon_optVol
bool dfiCal_showWpr        = dfiInp_showOsc == dfiCon_optWpr


// Five identically built input blocks: on/off, length and smoothing type,
// connection and source, style, width and color.
string maCon_movingAverageTooltip    = "On/Off Switch\nLength and Smoothing Type\nConnect Switch and Source\nStyle and Width and Color\n\nThe connection sets what the average is calculated on and where it is drawn: Main Chart draws it on the main chart, any other connection draws it in the panel — but only while the matching oscillator is selected in the Controller."
string maCon_overlayTrueChartTooltip = "The source input only applies when Main Chart is selected."
string maCon_group                   = "Moving Average"

bool   maInp_showTrendline1       = input.bool(defval = true, title = "MA 1", tooltip = maCon_movingAverageTooltip, inline = "b_ma_1", group = maCon_group)
int    maInp_length1              = input.int(defval = 21, title = "", minval = 1, maxval = 5000, inline = "h_ma_1", group = maCon_group, active = maInp_showTrendline1)
string maInp_smoothingType1       = input.string(defval = "EMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "h_ma_1", group = maCon_group, active = maInp_showTrendline1)
string maInp_indicatorConnection1 = input.string(defval = dfiCon_optMainChart, title = "", options = [dfiCon_optMainChart, dfiCon_optComparison, dfiCon_optAtr, dfiCon_optCci, dfiCon_optEom, dfiCon_optEfi, dfiCon_optMom, dfiCon_optMfi, dfiCon_optObv, dfiCon_optRoc, dfiCon_optRsi, dfiCon_optRvi, dfiCon_optSto, dfiCon_optSrs, dfiCon_optTsi, dfiCon_optUos, dfiCon_optVol, dfiCon_optWpr], inline = "n_ma_1", group = maCon_group, active = maInp_showTrendline1)
bool   maCal_usesMainChart1       = maInp_indicatorConnection1 == dfiCon_optMainChart
float  maInp_source1              = input.source(defval = close, title = "", inline = "n_ma_1", tooltip = maCon_overlayTrueChartTooltip, group = maCon_group, active = maInp_showTrendline1 and maCal_usesMainChart1)
string maInp_styleType1           = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "o_ma_1", group = maCon_group, active = maInp_showTrendline1)
maCal_styleType1           = maInp_styleType1 == "Stepline" ? plot.style_stepline : maInp_styleType1 == "Circles" ? plot.style_circles : plot.style_line
int    maInp_trendlineWidth1      = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "o_ma_1", group = maCon_group, active = maInp_showTrendline1)
color  maInp_color1               = input.color(defval = color.rgb(194, 194, 194), title = "", inline = "o_ma_1", group = maCon_group, active = maInp_showTrendline1)

bool   maInp_showTrendline2       = input.bool(defval = true, title = "MA 2", tooltip = maCon_movingAverageTooltip, inline = "b_ma_2", group = maCon_group)
int    maInp_length2              = input.int(defval = 50, title = "", minval = 1, maxval = 5000, inline = "h_ma_2", group = maCon_group, active = maInp_showTrendline2)
string maInp_smoothingType2       = input.string(defval = "EMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "h_ma_2", group = maCon_group, active = maInp_showTrendline2)
string maInp_indicatorConnection2 = input.string(defval = dfiCon_optMainChart, title = "", options = [dfiCon_optMainChart, dfiCon_optComparison, dfiCon_optAtr, dfiCon_optCci, dfiCon_optEom, dfiCon_optEfi, dfiCon_optMom, dfiCon_optMfi, dfiCon_optObv, dfiCon_optRoc, dfiCon_optRsi, dfiCon_optRvi, dfiCon_optSto, dfiCon_optSrs, dfiCon_optTsi, dfiCon_optUos, dfiCon_optVol, dfiCon_optWpr], inline = "n_ma_2", group = maCon_group, active = maInp_showTrendline2)
bool   maCal_usesMainChart2       = maInp_indicatorConnection2 == dfiCon_optMainChart
float  maInp_source2              = input.source(defval = close, title = "", inline = "n_ma_2", tooltip = maCon_overlayTrueChartTooltip, group = maCon_group, active = maInp_showTrendline2 and maCal_usesMainChart2)
string maInp_styleType2           = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "o_ma_2", group = maCon_group, active = maInp_showTrendline2)
maCal_styleType2           = maInp_styleType2 == "Stepline" ? plot.style_stepline : maInp_styleType2 == "Circles" ? plot.style_circles : plot.style_line
int    maInp_trendlineWidth2      = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "o_ma_2", group = maCon_group, active = maInp_showTrendline2)
color  maInp_color2               = input.color(defval = color.rgb(90, 90, 90), title = "", inline = "o_ma_2", group = maCon_group, active = maInp_showTrendline2)

bool   maInp_showTrendline3       = input.bool(defval = true, title = "MA 3", tooltip = maCon_movingAverageTooltip, inline = "b_ma_3", group = maCon_group)
int    maInp_length3              = input.int(defval = 8, title = "", minval = 1, maxval = 5000, inline = "h_ma_3", group = maCon_group, active = maInp_showTrendline3)
string maInp_smoothingType3       = input.string(defval = "SMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "h_ma_3", group = maCon_group, active = maInp_showTrendline3)
string maInp_indicatorConnection3 = input.string(defval = dfiCon_optRsi, title = "", options = [dfiCon_optMainChart, dfiCon_optComparison, dfiCon_optAtr, dfiCon_optCci, dfiCon_optEom, dfiCon_optEfi, dfiCon_optMom, dfiCon_optMfi, dfiCon_optObv, dfiCon_optRoc, dfiCon_optRsi, dfiCon_optRvi, dfiCon_optSto, dfiCon_optSrs, dfiCon_optTsi, dfiCon_optUos, dfiCon_optVol, dfiCon_optWpr], inline = "n_ma_3", group = maCon_group, active = maInp_showTrendline3)
bool   maCal_usesMainChart3       = maInp_indicatorConnection3 == dfiCon_optMainChart
float  maInp_source3              = input.source(defval = close, title = "", inline = "n_ma_3", tooltip = maCon_overlayTrueChartTooltip, group = maCon_group, active = maInp_showTrendline3 and maCal_usesMainChart3)
string maInp_styleType3           = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "o_ma_3", group = maCon_group, active = maInp_showTrendline3)
maCal_styleType3           = maInp_styleType3 == "Stepline" ? plot.style_stepline : maInp_styleType3 == "Circles" ? plot.style_circles : plot.style_line
int    maInp_trendlineWidth3      = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "o_ma_3", group = maCon_group, active = maInp_showTrendline3)
color  maInp_color3               = input.color(defval = color.rgb(153, 39, 39), title = "", inline = "o_ma_3", group = maCon_group, active = maInp_showTrendline3)

bool   maInp_showTrendline4       = input.bool(defval = true, title = "MA 4", tooltip = maCon_movingAverageTooltip, inline = "b_ma_4", group = maCon_group)
int    maInp_length4              = input.int(defval = 3, title = "", minval = 1, maxval = 5000, inline = "h_ma_4", group = maCon_group, active = maInp_showTrendline4)
string maInp_smoothingType4       = input.string(defval = "SMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "h_ma_4", group = maCon_group, active = maInp_showTrendline4)
string maInp_indicatorConnection4 = input.string(defval = dfiCon_optSto, title = "", options = [dfiCon_optMainChart, dfiCon_optComparison, dfiCon_optAtr, dfiCon_optCci, dfiCon_optEom, dfiCon_optEfi, dfiCon_optMom, dfiCon_optMfi, dfiCon_optObv, dfiCon_optRoc, dfiCon_optRsi, dfiCon_optRvi, dfiCon_optSto, dfiCon_optSrs, dfiCon_optTsi, dfiCon_optUos, dfiCon_optVol, dfiCon_optWpr], inline = "n_ma_4", group = maCon_group, active = maInp_showTrendline4)
bool   maCal_usesMainChart4       = maInp_indicatorConnection4 == dfiCon_optMainChart
float  maInp_source4              = input.source(defval = close, title = "", inline = "n_ma_4", tooltip = maCon_overlayTrueChartTooltip, group = maCon_group, active = maInp_showTrendline4 and maCal_usesMainChart4)
string maInp_styleType4           = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "o_ma_4", group = maCon_group, active = maInp_showTrendline4)
maCal_styleType4           = maInp_styleType4 == "Stepline" ? plot.style_stepline : maInp_styleType4 == "Circles" ? plot.style_circles : plot.style_line
int    maInp_trendlineWidth4      = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "o_ma_4", group = maCon_group, active = maInp_showTrendline4)
color  maInp_color4               = input.color(defval = color.rgb(255, 255, 255), title = "", inline = "o_ma_4", group = maCon_group, active = maInp_showTrendline4)

bool   maInp_showTrendline5       = input.bool(defval = true, title = "MA 5", tooltip = maCon_movingAverageTooltip, inline = "b_ma_5", group = maCon_group)
int    maInp_length5              = input.int(defval = 50, title = "", minval = 1, maxval = 5000, inline = "h_ma_5", group = maCon_group, active = maInp_showTrendline5)
string maInp_smoothingType5       = input.string(defval = "EMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "h_ma_5", group = maCon_group, active = maInp_showTrendline5)
string maInp_indicatorConnection5 = input.string(defval = dfiCon_optEfi, title = "", options = [dfiCon_optMainChart, dfiCon_optComparison, dfiCon_optAtr, dfiCon_optCci, dfiCon_optEom, dfiCon_optEfi, dfiCon_optMom, dfiCon_optMfi, dfiCon_optObv, dfiCon_optRoc, dfiCon_optRsi, dfiCon_optRvi, dfiCon_optSto, dfiCon_optSrs, dfiCon_optTsi, dfiCon_optUos, dfiCon_optVol, dfiCon_optWpr], inline = "n_ma_5", group = maCon_group, active = maInp_showTrendline5)
bool   maCal_usesMainChart5       = maInp_indicatorConnection5 == dfiCon_optMainChart
float  maInp_source5              = input.source(defval = close, title = "", inline = "n_ma_5", tooltip = maCon_overlayTrueChartTooltip, group = maCon_group, active = maInp_showTrendline5 and maCal_usesMainChart5)
string maInp_styleType5           = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "o_ma_5", group = maCon_group, active = maInp_showTrendline5)
maCal_styleType5           = maInp_styleType5 == "Stepline" ? plot.style_stepline : maInp_styleType5 == "Circles" ? plot.style_circles : plot.style_line
int    maInp_trendlineWidth5      = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "o_ma_5", group = maCon_group, active = maInp_showTrendline5)
color  maInp_color5               = input.color(defval = color.rgb(165, 144, 49), title = "", inline = "o_ma_5", group = maCon_group, active = maInp_showTrendline5)


const string csCon_optSymbol1 = "Symbol 1"
const string csCon_optSymbol2 = "Symbol 2"
const string csCon_optSymbol3 = "Symbol 3"
const string csCon_optSymbol4 = "Symbol 4"
const string csCon_optSymbol5 = "Symbol 5"
string csCon_symbolTooltip = "When Comparison Symbol is selected, the available securities are shown here."
string csInp_showSymbol = input.string(defval = csCon_optSymbol1, title = "Symbol Option", options = [csCon_optSymbol1, csCon_optSymbol2, csCon_optSymbol3, csCon_optSymbol4, csCon_optSymbol5], tooltip = csCon_symbolTooltip, group = dfiCon_optComparison, active = dfiCal_showComparison)
string csInp_symbol1 = input.symbol(defval = "INDEX:BTCUSD", title = csCon_optSymbol1, group = dfiCon_optComparison, active = dfiCal_showComparison)
string csInp_symbol2 = input.symbol(defval = "CRYPTOCAP:BTC.D", title = csCon_optSymbol2, group = dfiCon_optComparison, active = dfiCal_showComparison)
string csInp_symbol3 = input.symbol(defval = "TVC:BTCXAU", title = csCon_optSymbol3, group = dfiCon_optComparison, active = dfiCal_showComparison)
string csInp_symbol4 = input.symbol(defval = "BINANCE:SUIUSDT", title = csCon_optSymbol4, group = dfiCon_optComparison, active = dfiCal_showComparison)
string csInp_symbol5 = input.symbol(defval = "TVC:GOLD", title = csCon_optSymbol5, group = dfiCon_optComparison, active = dfiCal_showComparison)
bool csCal_symbol1 = csInp_showSymbol == csCon_optSymbol1
bool csCal_symbol2 = csInp_showSymbol == csCon_optSymbol2
bool csCal_symbol3 = csInp_showSymbol == csCon_optSymbol3
bool csCal_symbol4 = csInp_showSymbol == csCon_optSymbol4
bool csCal_symbol5 = csInp_showSymbol == csCon_optSymbol5
string csCal_switch = 
  csCal_symbol1 ? csInp_symbol1 :
  csCal_symbol2 ? csInp_symbol2 :
  csCal_symbol3 ? csInp_symbol3 :
  csCal_symbol4 ? csInp_symbol4 :
  csCal_symbol5 ? csInp_symbol5 :
  ""
// The external symbol is only requested when it is actually shown; otherwise the
// request points at the chart's own symbol and loads no additional data.
string csCal_requestSymbol = dfiCal_showComparison ? csCal_switch : syminfo.tickerid
[csCal_open, csCal_high, csCal_low, csCal_close] = request.security(csCal_requestSymbol, "", [open, high, low, close])
color csInp_bullColor = input.color(defval = color.rgb(255, 255, 255), title = "Bull", inline = "cs_", group = dfiCon_optComparison, active = dfiCal_showComparison)
color csInp_bearColor = input.color(defval = color.rgb(148, 148, 148), title = "Bear", inline = "cs_", group = dfiCon_optComparison, active = dfiCal_showComparison)
color csCal_candleColor = csCal_close >= csCal_open ? csInp_bullColor : csInp_bearColor
plotcandle(csCal_open, csCal_high, csCal_low, csCal_close, title = "Comparison Symbol", color = na, wickcolor = csCal_candleColor, bordercolor = csCal_candleColor, editable = false, display = dfiCal_showComparison ? display.all : display.none)
plot(series = dfiCal_showComparison ? csCal_close : na, title = "Comparison Symbol Close", color = color.new(chart.fg_color, 0), trackprice = true, editable = false)


// All oscillators keep calculating at all times so their history is complete
// the moment the selection changes.
int    atrInp_length    = input.int(defval = 14, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optAtr, active = dfiCal_showAtr)
string atrInp_smoothing = input.string(defval = "RMA", title = "Smoothing", options = ["RMA", "SMA", "EMA", "WMA"], group = dfiCon_optAtr, active = dfiCal_showAtr)
float atrCal_function   = f_movingAverage(maType = atrInp_smoothing, source = ta.tr(true), length = atrInp_length)

int cciInp_length       = input.int(defval = 20, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optCci, active = dfiCal_showCci)
float cciInp_source     = input.source(defval = hlc3, title = "Source", group = dfiCon_optCci, active = dfiCal_showCci)
float cciCal_ma         = ta.sma(cciInp_source, cciInp_length)
float cciCal_function   = (cciInp_source - cciCal_ma) / (0.015 * ta.dev(cciInp_source, cciInp_length))

int eomInp_length       = input.int(defval = 14, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optEom, active = dfiCal_showEom)
int eomInp_divisor      = input.int(defval = 10000, title = "Divisor", minval = 1, maxval = 1000000000, group = dfiCon_optEom, active = dfiCal_showEom)
float eomCal_function   = ta.sma(eomInp_divisor * ta.change(hl2) * (high - low) / volume, eomInp_length)

int efiInp_length       = input.int(defval = 13, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optEfi, active = dfiCal_showEfi)
float efiInp_source     = input.source(defval = close, title = "Source", group = dfiCon_optEfi, active = dfiCal_showEfi)
float efiCal_function   = ta.ema(ta.change(efiInp_source) * volume, efiInp_length)

int momInp_length       = input.int(defval = 10, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optMom, active = dfiCal_showMom)
float momInp_source     = input.source(defval = close, title = "Source", group = dfiCon_optMom, active = dfiCal_showMom)
float momCal_function   = momInp_source - momInp_source[momInp_length]

int   mfiInp_length     = input.int(defval = 14, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optMfi, active = dfiCal_showMfi)
float mfiInp_source     = input.source(defval = hlc3, title = "Source", group = dfiCon_optMfi, active = dfiCal_showMfi)
float mfiCal_function   = ta.mfi(series = mfiInp_source, length = mfiInp_length)

float obvInp_source     = input.source(defval = close, title = "Source", group = dfiCon_optObv, active = dfiCal_showObv)
float obvCal_function   = ta.cum(math.sign(ta.change(obvInp_source)) * volume)

int rocInp_length       = input.int(defval = 9, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optRoc, active = dfiCal_showRoc)
float rocInp_source     = input.source(defval = close, title = "Source", group = dfiCon_optRoc, active = dfiCal_showRoc)
float rocCal_function   = 100 * (rocInp_source - rocInp_source[rocInp_length]) / rocInp_source[rocInp_length]

int   rsiInp_length     = input.int(defval = 14, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optRsi, active = dfiCal_showRsi)
float rsiInp_source     = input.source(defval = close, title = "Source", group = dfiCon_optRsi, active = dfiCal_showRsi)
float rsiCal_function   = ta.rsi(source = rsiInp_source, length = rsiInp_length)

int rviCon_smoothLength = 14
int rviInp_length       = input.int(defval = 10, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optRvi, active = dfiCal_showRvi)
float rviInp_source     = input.source(defval = close, title = "Source", group = dfiCon_optRvi, active = dfiCal_showRvi)
float rviCal_stddev     = ta.stdev(rviInp_source, rviInp_length)
float rviCal_upper      = ta.ema(ta.change(rviInp_source) <= 0 ? 0 : rviCal_stddev, rviCon_smoothLength)
float rviCal_lower      = ta.ema(ta.change(rviInp_source) > 0 ? 0 : rviCal_stddev, rviCon_smoothLength)
float rviCal_function   = rviCal_upper / (rviCal_upper + rviCal_lower) * 100

int stoInp_length       = input.int(defval = 14, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optSto, active = dfiCal_showSto)
int stoInp_smoothing    = input.int(defval = 1, title = "Smoothing", minval = 1, maxval = 5000, group = dfiCon_optSto, active = dfiCal_showSto)
float stoCal_function   = ta.sma(ta.stoch(close, high, low, stoInp_length), stoInp_smoothing)

int srsInp_smoothing    = input.int(defval = 3, title = "K", minval = 1, maxval = 5000, group = dfiCon_optSrs, active = dfiCal_showSrs)
int srsInp_rsiLength    = input.int(defval = 14, title = "RSI Length", minval = 1, maxval = 5000, group = dfiCon_optSrs, active = dfiCal_showSrs)
int srsInp_stoLength    = input.int(defval = 14, title = "Stochastic Length", minval = 1, maxval = 5000, group = dfiCon_optSrs, active = dfiCal_showSrs)
float srsInp_source     = input.source(defval = close, title = "RSI Source", group = dfiCon_optSrs, active = dfiCal_showSrs)
float srsCal_rsiConnect = ta.rsi(srsInp_source, srsInp_rsiLength)
float srsCal_function   = ta.sma(ta.stoch(srsCal_rsiConnect, srsCal_rsiConnect, srsCal_rsiConnect, srsInp_stoLength), srsInp_smoothing)

f_tsi(source, longLength, shortLength) =>
    firstSmooth = ta.ema(source, longLength)
    ta.ema(firstSmooth, shortLength)
int tsiInp_longLength               = input.int(defval = 25, title = "Long Length", minval = 1, maxval = 5000, group = dfiCon_optTsi, active = dfiCal_showTsi)
int tsiInp_shortLength              = input.int(defval = 13, title = "Short Length", minval = 1, maxval = 5000, group = dfiCon_optTsi, active = dfiCal_showTsi)
float tsiInp_source                 = input.source(defval = close, title = "Source", group = dfiCon_optTsi, active = dfiCal_showTsi)
float tsiCal_price                  = ta.change(tsiInp_source)
float tsiCal_doubleSmoothedPrice    = f_tsi(source = tsiCal_price, longLength = tsiInp_longLength, shortLength = tsiInp_shortLength)
float tsiCal_doubleSmoothedAbsPrice = f_tsi(source = math.abs(tsiCal_price), longLength = tsiInp_longLength, shortLength = tsiInp_shortLength)
float tsiCal_function               = 100 * (tsiCal_doubleSmoothedPrice / tsiCal_doubleSmoothedAbsPrice)

f_average(bp, tr, length) =>
    math.sum(bp, length) / math.sum(tr, length)
int uosInp_fastLength   = input.int(defval = 7, title = "Fast Length", minval = 1, maxval = 5000, group = dfiCon_optUos, active = dfiCal_showUos)
int uosInp_middleLength = input.int(defval = 14, title = "Middle Length", minval = 1, maxval = 5000, group = dfiCon_optUos, active = dfiCal_showUos)
int uosInp_slowLength   = input.int(defval = 28, title = "Slow Length", minval = 1, maxval = 5000, group = dfiCon_optUos, active = dfiCal_showUos)
float uosCal_high       = math.max(high, close[1])
float uosCal_low        = math.min(low, close[1])
float uosCal_bp         = close - uosCal_low
float uosCal_tr         = uosCal_high - uosCal_low
float uosCal_avgFast    = f_average(uosCal_bp, uosCal_tr, uosInp_fastLength)
float uosCal_avgMiddle  = f_average(uosCal_bp, uosCal_tr, uosInp_middleLength)
float uosCal_avgSlow    = f_average(uosCal_bp, uosCal_tr, uosInp_slowLength)
float uosCal_function   = 100 * (4 * uosCal_avgFast + 2 * uosCal_avgMiddle + uosCal_avgSlow) / 7

float volCal_function   = volume

f_wpr(length, source) =>
    highestHigh = ta.highest(length)
    lowestLow   = ta.lowest(length)
    100 * (source - highestHigh) / (highestHigh - lowestLow)
int wprInp_length       = input.int(defval = 14, title = "Length", minval = 1, maxval = 5000, group = dfiCon_optWpr, active = dfiCal_showWpr)
float wprInp_source     = input.source(defval = close, title = "Source", group = dfiCon_optWpr, active = dfiCal_showWpr)
float wprCal_function   = f_wpr(length = wprInp_length, source = wprInp_source)


bool dfiCal_oscillatorColorActive = not dfiCal_showComparison
color dfiInp_oscillatorColor = input.color(defval = color.new(#234ab4, 0), title = "Oscillator Color", group = "Oscillator Graphic", active = dfiCal_oscillatorColorActive)
// Merges the sixteen oscillators into the single series that gets plotted.
float dfiCal_oscFunction = 
  dfiCal_showAtr ? atrCal_function :
  dfiCal_showCci ? cciCal_function :
  dfiCal_showEom ? eomCal_function :
  dfiCal_showEfi ? efiCal_function :
  dfiCal_showMom ? momCal_function :
  dfiCal_showMfi ? mfiCal_function :
  dfiCal_showObv ? obvCal_function :
  dfiCal_showRoc ? rocCal_function :
  dfiCal_showRsi ? rsiCal_function :
  dfiCal_showRvi ? rviCal_function :
  dfiCal_showSto ? stoCal_function :
  dfiCal_showSrs ? srsCal_function :
  dfiCal_showTsi ? tsiCal_function :
  dfiCal_showUos ? uosCal_function :
  dfiCal_showVol ? volCal_function :
  dfiCal_showWpr ? wprCal_function :
  float(na)
dfiCal_oscDisplay = dfiCal_showComparison ? display.none : display.all
plot(series = dfiCal_oscFunction, title = "Oscillator", color = dfiInp_oscillatorColor, editable = false, display = dfiCal_oscDisplay)

bool dfiCal_middlelineActive = not (dfiCal_showComparison or dfiCal_showObv)
bool dfiInp_showMiddleline   = input.bool(defval = true, title = "Show Middleline", group = "Oscillator Graphic", active = dfiCal_middlelineActive)
// Middleline and bands sit at different values per oscillator and are omitted
// where they carry no meaning.
int dfiCal_middlelineSeries = 
  dfiCal_showMfi ?  50 :
  dfiCal_showRsi ?  50 :
  dfiCal_showRvi ?  50 :
  dfiCal_showSto ?  50 :
  dfiCal_showSrs ?  50 :
  dfiCal_showUos ?  50 :
  dfiCal_showWpr ? -50 :
  0
dfiCal_showMiddleline = dfiCal_showComparison or dfiCal_showObv ? display.none : display.all
plot(series = dfiInp_showMiddleline ? dfiCal_middlelineSeries : na, title = "Middleline", color = color.new(chart.fg_color, 75), editable = false, display = dfiCal_showMiddleline)

bool dfiCal_hasBands = dfiCal_showCci or dfiCal_showMfi or dfiCal_showRsi or dfiCal_showRvi or dfiCal_showSto or dfiCal_showSrs or dfiCal_showWpr
color dfiInp_backgroundColor = input.color(defval = color.new(#43137a, 0), title = "Background Color", group = "Oscillator Graphic", active = dfiCal_hasBands)
int dfiCal_fillSeriesUp = 
  dfiCal_showCci ?  100 :
  dfiCal_showMfi ?   80 :
  dfiCal_showRsi ?   70 :
  dfiCal_showRvi ?   80 :
  dfiCal_showSto ?   80 :
  dfiCal_showSrs ?   80 :
  dfiCal_showWpr ?  -20 :
  0
int dfiCal_fillSeriesDown = 
  dfiCal_showCci ? -100 :
  dfiCal_showMfi ?   20 :
  dfiCal_showRsi ?   30 :
  dfiCal_showRvi ?   20 :
  dfiCal_showSto ?   20 :
  dfiCal_showSrs ?   20 :
  dfiCal_showWpr ?  -80 :
  0
dfiCal_showFill = dfiCal_hasBands ? display.all : display.none
dfiOutp_backgroundUp   = plot(series = dfiCal_fillSeriesUp, title = "Upper Band", color = color.new(chart.fg_color, 50), editable = false, display = dfiCal_showFill, linestyle = plot.linestyle_dashed)
dfiOutp_backgroundDown = plot(series = dfiCal_fillSeriesDown, title = "Lower Band", color = color.new(chart.fg_color, 50), editable = false, display = dfiCal_showFill, linestyle = plot.linestyle_dashed)
fill(plot1 = dfiOutp_backgroundUp, plot2 = dfiOutp_backgroundDown, title = "Band Fill", color = color.new(dfiInp_backgroundColor, 85), editable = false, display = dfiCal_showFill)


string dfiCal_oscText = 
  dfiInp_showOsc == dfiCon_optComparison ? csCal_switch         :
  dfiInp_showOsc == dfiCon_optAtr        ? dfiCon_optAtr         :
  dfiInp_showOsc == dfiCon_optCci        ? dfiCon_optCci         :
  dfiInp_showOsc == dfiCon_optEom        ? dfiCon_optEom         :
  dfiInp_showOsc == dfiCon_optEfi        ? dfiCon_optEfi         :
  dfiInp_showOsc == dfiCon_optMom        ? dfiCon_optMom         :
  dfiInp_showOsc == dfiCon_optMfi        ? dfiCon_optMfi         :
  dfiInp_showOsc == dfiCon_optObv        ? dfiCon_optObv         :
  dfiInp_showOsc == dfiCon_optRoc        ? dfiCon_optRoc         :
  dfiInp_showOsc == dfiCon_optRsi        ? dfiCon_optRsi         :
  dfiInp_showOsc == dfiCon_optRvi        ? dfiCon_optRvi         :
  dfiInp_showOsc == dfiCon_optSto        ? dfiCon_optSto         :
  dfiInp_showOsc == dfiCon_optSrs        ? dfiCon_optSrs         :
  dfiInp_showOsc == dfiCon_optTsi        ? dfiCon_optTsi         :
  dfiInp_showOsc == dfiCon_optUos        ? dfiCon_optUos         :
  dfiInp_showOsc == dfiCon_optVol        ? dfiCon_optVol         :
  dfiInp_showOsc == dfiCon_optWpr        ? dfiCon_optWpr         :
  ""
// Shows the name of the displayed oscillator in the top right corner, or the
// symbol itself when Comparison Symbol is selected.
var table tblOutp_main = table.new(position = position.top_right, columns = 1, rows = 1, bgcolor = color.new(chart.bg_color, 100), border_color = color.new(chart.bg_color, 100), border_width = 1)
if barstate.islast
    table.cell(table_id = tblOutp_main, column = 0, row = 0, text = dfiCal_oscText, text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 100), text_size = size.normal, text_halign = text.align_center)


// Five identically built blocks per average: the connection determines the
// calculation source, whether it is drawn, and in which pane.
// The same average is plotted twice — once with force_overlay = true for the main
// chart, once without it for the panel; only the applicable one is ever visible.
float maCal_sourceConnection1 = 
  maInp_indicatorConnection1 == dfiCon_optMainChart  ? maInp_source1   :
  maInp_indicatorConnection1 == dfiCon_optComparison ? csCal_close     :
  maInp_indicatorConnection1 == dfiCon_optAtr        ? atrCal_function :
  maInp_indicatorConnection1 == dfiCon_optCci        ? cciCal_function :
  maInp_indicatorConnection1 == dfiCon_optEom        ? eomCal_function :
  maInp_indicatorConnection1 == dfiCon_optEfi        ? efiCal_function :
  maInp_indicatorConnection1 == dfiCon_optMom        ? momCal_function :
  maInp_indicatorConnection1 == dfiCon_optMfi        ? mfiCal_function :
  maInp_indicatorConnection1 == dfiCon_optObv        ? obvCal_function :
  maInp_indicatorConnection1 == dfiCon_optRoc        ? rocCal_function :
  maInp_indicatorConnection1 == dfiCon_optRsi        ? rsiCal_function :
  maInp_indicatorConnection1 == dfiCon_optRvi        ? rviCal_function :
  maInp_indicatorConnection1 == dfiCon_optSto        ? stoCal_function :
  maInp_indicatorConnection1 == dfiCon_optSrs        ? srsCal_function :
  maInp_indicatorConnection1 == dfiCon_optTsi        ? tsiCal_function :
  maInp_indicatorConnection1 == dfiCon_optUos        ? uosCal_function :
  maInp_indicatorConnection1 == dfiCon_optVol        ? volCal_function :
  maInp_indicatorConnection1 == dfiCon_optWpr        ? wprCal_function :
  float(na)

bool maCal_showOverlayFalse1 = 
  maInp_indicatorConnection1 == dfiCon_optMainChart  ? false                 :
  maInp_indicatorConnection1 == dfiCon_optComparison ? dfiCal_showComparison :
  maInp_indicatorConnection1 == dfiCon_optAtr        ? dfiCal_showAtr        :
  maInp_indicatorConnection1 == dfiCon_optCci        ? dfiCal_showCci        :
  maInp_indicatorConnection1 == dfiCon_optEom        ? dfiCal_showEom        :
  maInp_indicatorConnection1 == dfiCon_optEfi        ? dfiCal_showEfi        :
  maInp_indicatorConnection1 == dfiCon_optMom        ? dfiCal_showMom        :
  maInp_indicatorConnection1 == dfiCon_optMfi        ? dfiCal_showMfi        :
  maInp_indicatorConnection1 == dfiCon_optObv        ? dfiCal_showObv        :
  maInp_indicatorConnection1 == dfiCon_optRoc        ? dfiCal_showRoc        :
  maInp_indicatorConnection1 == dfiCon_optRsi        ? dfiCal_showRsi        :
  maInp_indicatorConnection1 == dfiCon_optRvi        ? dfiCal_showRvi        :
  maInp_indicatorConnection1 == dfiCon_optSto        ? dfiCal_showSto        :
  maInp_indicatorConnection1 == dfiCon_optSrs        ? dfiCal_showSrs        :
  maInp_indicatorConnection1 == dfiCon_optTsi        ? dfiCal_showTsi        :
  maInp_indicatorConnection1 == dfiCon_optUos        ? dfiCal_showUos        :
  maInp_indicatorConnection1 == dfiCon_optVol        ? dfiCal_showVol        :
  maInp_indicatorConnection1 == dfiCon_optWpr        ? dfiCal_showWpr        :
  false
float maCal_ma1 = maInp_showTrendline1 ? f_movingAverage(maType = maInp_smoothingType1, source = maCal_sourceConnection1, length = maInp_length1) : na
plot(series = maCal_usesMainChart1 ? maCal_ma1 : na,  title = "MA 1 (Main Chart)", color = maInp_color1, linewidth = maInp_trendlineWidth1, style = maCal_styleType1, editable = false, force_overlay = true)
plot(series = maCal_showOverlayFalse1 ? maCal_ma1 : na, title = "MA 1", color = maInp_color1, linewidth = maInp_trendlineWidth1, style = maCal_styleType1, editable = false, force_overlay = false)

// Structure and plotting as in MA 1.
float maCal_sourceConnection2 = 
  maInp_indicatorConnection2 == dfiCon_optMainChart  ? maInp_source2   :
  maInp_indicatorConnection2 == dfiCon_optComparison ? csCal_close     :
  maInp_indicatorConnection2 == dfiCon_optAtr        ? atrCal_function :
  maInp_indicatorConnection2 == dfiCon_optCci        ? cciCal_function :
  maInp_indicatorConnection2 == dfiCon_optEom        ? eomCal_function :
  maInp_indicatorConnection2 == dfiCon_optEfi        ? efiCal_function :
  maInp_indicatorConnection2 == dfiCon_optMom        ? momCal_function :
  maInp_indicatorConnection2 == dfiCon_optMfi        ? mfiCal_function :
  maInp_indicatorConnection2 == dfiCon_optObv        ? obvCal_function :
  maInp_indicatorConnection2 == dfiCon_optRoc        ? rocCal_function :
  maInp_indicatorConnection2 == dfiCon_optRsi        ? rsiCal_function :
  maInp_indicatorConnection2 == dfiCon_optRvi        ? rviCal_function :
  maInp_indicatorConnection2 == dfiCon_optSto        ? stoCal_function :
  maInp_indicatorConnection2 == dfiCon_optSrs        ? srsCal_function :
  maInp_indicatorConnection2 == dfiCon_optTsi        ? tsiCal_function :
  maInp_indicatorConnection2 == dfiCon_optUos        ? uosCal_function :
  maInp_indicatorConnection2 == dfiCon_optVol        ? volCal_function :
  maInp_indicatorConnection2 == dfiCon_optWpr        ? wprCal_function :
  float(na)

bool maCal_showOverlayFalse2 = 
  maInp_indicatorConnection2 == dfiCon_optMainChart  ? false                 :
  maInp_indicatorConnection2 == dfiCon_optComparison ? dfiCal_showComparison :
  maInp_indicatorConnection2 == dfiCon_optAtr        ? dfiCal_showAtr        :
  maInp_indicatorConnection2 == dfiCon_optCci        ? dfiCal_showCci        :
  maInp_indicatorConnection2 == dfiCon_optEom        ? dfiCal_showEom        :
  maInp_indicatorConnection2 == dfiCon_optEfi        ? dfiCal_showEfi        :
  maInp_indicatorConnection2 == dfiCon_optMom        ? dfiCal_showMom        :
  maInp_indicatorConnection2 == dfiCon_optMfi        ? dfiCal_showMfi        :
  maInp_indicatorConnection2 == dfiCon_optObv        ? dfiCal_showObv        :
  maInp_indicatorConnection2 == dfiCon_optRoc        ? dfiCal_showRoc        :
  maInp_indicatorConnection2 == dfiCon_optRsi        ? dfiCal_showRsi        :
  maInp_indicatorConnection2 == dfiCon_optRvi        ? dfiCal_showRvi        :
  maInp_indicatorConnection2 == dfiCon_optSto        ? dfiCal_showSto        :
  maInp_indicatorConnection2 == dfiCon_optSrs        ? dfiCal_showSrs        :
  maInp_indicatorConnection2 == dfiCon_optTsi        ? dfiCal_showTsi        :
  maInp_indicatorConnection2 == dfiCon_optUos        ? dfiCal_showUos        :
  maInp_indicatorConnection2 == dfiCon_optVol        ? dfiCal_showVol        :
  maInp_indicatorConnection2 == dfiCon_optWpr        ? dfiCal_showWpr        :
  false
float maCal_ma2 = maInp_showTrendline2 ? f_movingAverage(maType = maInp_smoothingType2, source = maCal_sourceConnection2, length = maInp_length2) : na
plot(series = maCal_usesMainChart2 ? maCal_ma2 : na,  title = "MA 2 (Main Chart)", color = maInp_color2, linewidth = maInp_trendlineWidth2, style = maCal_styleType2, editable = false, force_overlay = true)
plot(series = maCal_showOverlayFalse2 ? maCal_ma2 : na, title = "MA 2", color = maInp_color2, linewidth = maInp_trendlineWidth2, style = maCal_styleType2, editable = false, force_overlay = false)

// Structure and plotting as in MA 1.
float maCal_sourceConnection3 = 
  maInp_indicatorConnection3 == dfiCon_optMainChart  ? maInp_source3   :
  maInp_indicatorConnection3 == dfiCon_optComparison ? csCal_close     :
  maInp_indicatorConnection3 == dfiCon_optAtr        ? atrCal_function :
  maInp_indicatorConnection3 == dfiCon_optCci        ? cciCal_function :
  maInp_indicatorConnection3 == dfiCon_optEom        ? eomCal_function :
  maInp_indicatorConnection3 == dfiCon_optEfi        ? efiCal_function :
  maInp_indicatorConnection3 == dfiCon_optMom        ? momCal_function :
  maInp_indicatorConnection3 == dfiCon_optMfi        ? mfiCal_function :
  maInp_indicatorConnection3 == dfiCon_optObv        ? obvCal_function :
  maInp_indicatorConnection3 == dfiCon_optRoc        ? rocCal_function :
  maInp_indicatorConnection3 == dfiCon_optRsi        ? rsiCal_function :
  maInp_indicatorConnection3 == dfiCon_optRvi        ? rviCal_function :
  maInp_indicatorConnection3 == dfiCon_optSto        ? stoCal_function :
  maInp_indicatorConnection3 == dfiCon_optSrs        ? srsCal_function :
  maInp_indicatorConnection3 == dfiCon_optTsi        ? tsiCal_function :
  maInp_indicatorConnection3 == dfiCon_optUos        ? uosCal_function :
  maInp_indicatorConnection3 == dfiCon_optVol        ? volCal_function :
  maInp_indicatorConnection3 == dfiCon_optWpr        ? wprCal_function :
  float(na)

bool maCal_showOverlayFalse3 = 
  maInp_indicatorConnection3 == dfiCon_optMainChart  ? false                 :
  maInp_indicatorConnection3 == dfiCon_optComparison ? dfiCal_showComparison :
  maInp_indicatorConnection3 == dfiCon_optAtr        ? dfiCal_showAtr        :
  maInp_indicatorConnection3 == dfiCon_optCci        ? dfiCal_showCci        :
  maInp_indicatorConnection3 == dfiCon_optEom        ? dfiCal_showEom        :
  maInp_indicatorConnection3 == dfiCon_optEfi        ? dfiCal_showEfi        :
  maInp_indicatorConnection3 == dfiCon_optMom        ? dfiCal_showMom        :
  maInp_indicatorConnection3 == dfiCon_optMfi        ? dfiCal_showMfi        :
  maInp_indicatorConnection3 == dfiCon_optObv        ? dfiCal_showObv        :
  maInp_indicatorConnection3 == dfiCon_optRoc        ? dfiCal_showRoc        :
  maInp_indicatorConnection3 == dfiCon_optRsi        ? dfiCal_showRsi        :
  maInp_indicatorConnection3 == dfiCon_optRvi        ? dfiCal_showRvi        :
  maInp_indicatorConnection3 == dfiCon_optSto        ? dfiCal_showSto        :
  maInp_indicatorConnection3 == dfiCon_optSrs        ? dfiCal_showSrs        :
  maInp_indicatorConnection3 == dfiCon_optTsi        ? dfiCal_showTsi        :
  maInp_indicatorConnection3 == dfiCon_optUos        ? dfiCal_showUos        :
  maInp_indicatorConnection3 == dfiCon_optVol        ? dfiCal_showVol        :
  maInp_indicatorConnection3 == dfiCon_optWpr        ? dfiCal_showWpr        :
  false
float maCal_ma3 = maInp_showTrendline3 ? f_movingAverage(maType = maInp_smoothingType3, source = maCal_sourceConnection3, length = maInp_length3) : na
plot(series = maCal_usesMainChart3 ? maCal_ma3 : na,  title = "MA 3 (Main Chart)", color = maInp_color3, linewidth = maInp_trendlineWidth3, style = maCal_styleType3, editable = false, force_overlay = true)
plot(series = maCal_showOverlayFalse3 ? maCal_ma3 : na, title = "MA 3", color = maInp_color3, linewidth = maInp_trendlineWidth3, style = maCal_styleType3, editable = false, force_overlay = false)

// Structure and plotting as in MA 1.
float maCal_sourceConnection4 = 
  maInp_indicatorConnection4 == dfiCon_optMainChart  ? maInp_source4   :
  maInp_indicatorConnection4 == dfiCon_optComparison ? csCal_close     :
  maInp_indicatorConnection4 == dfiCon_optAtr        ? atrCal_function :
  maInp_indicatorConnection4 == dfiCon_optCci        ? cciCal_function :
  maInp_indicatorConnection4 == dfiCon_optEom        ? eomCal_function :
  maInp_indicatorConnection4 == dfiCon_optEfi        ? efiCal_function :
  maInp_indicatorConnection4 == dfiCon_optMom        ? momCal_function :
  maInp_indicatorConnection4 == dfiCon_optMfi        ? mfiCal_function :
  maInp_indicatorConnection4 == dfiCon_optObv        ? obvCal_function :
  maInp_indicatorConnection4 == dfiCon_optRoc        ? rocCal_function :
  maInp_indicatorConnection4 == dfiCon_optRsi        ? rsiCal_function :
  maInp_indicatorConnection4 == dfiCon_optRvi        ? rviCal_function :
  maInp_indicatorConnection4 == dfiCon_optSto        ? stoCal_function :
  maInp_indicatorConnection4 == dfiCon_optSrs        ? srsCal_function :
  maInp_indicatorConnection4 == dfiCon_optTsi        ? tsiCal_function :
  maInp_indicatorConnection4 == dfiCon_optUos        ? uosCal_function :
  maInp_indicatorConnection4 == dfiCon_optVol        ? volCal_function :
  maInp_indicatorConnection4 == dfiCon_optWpr        ? wprCal_function :
  float(na)

bool maCal_showOverlayFalse4 = 
  maInp_indicatorConnection4 == dfiCon_optMainChart  ? false                 :
  maInp_indicatorConnection4 == dfiCon_optComparison ? dfiCal_showComparison :
  maInp_indicatorConnection4 == dfiCon_optAtr        ? dfiCal_showAtr        :
  maInp_indicatorConnection4 == dfiCon_optCci        ? dfiCal_showCci        :
  maInp_indicatorConnection4 == dfiCon_optEom        ? dfiCal_showEom        :
  maInp_indicatorConnection4 == dfiCon_optEfi        ? dfiCal_showEfi        :
  maInp_indicatorConnection4 == dfiCon_optMom        ? dfiCal_showMom        :
  maInp_indicatorConnection4 == dfiCon_optMfi        ? dfiCal_showMfi        :
  maInp_indicatorConnection4 == dfiCon_optObv        ? dfiCal_showObv        :
  maInp_indicatorConnection4 == dfiCon_optRoc        ? dfiCal_showRoc        :
  maInp_indicatorConnection4 == dfiCon_optRsi        ? dfiCal_showRsi        :
  maInp_indicatorConnection4 == dfiCon_optRvi        ? dfiCal_showRvi        :
  maInp_indicatorConnection4 == dfiCon_optSto        ? dfiCal_showSto        :
  maInp_indicatorConnection4 == dfiCon_optSrs        ? dfiCal_showSrs        :
  maInp_indicatorConnection4 == dfiCon_optTsi        ? dfiCal_showTsi        :
  maInp_indicatorConnection4 == dfiCon_optUos        ? dfiCal_showUos        :
  maInp_indicatorConnection4 == dfiCon_optVol        ? dfiCal_showVol        :
  maInp_indicatorConnection4 == dfiCon_optWpr        ? dfiCal_showWpr        :
  false
float maCal_ma4 = maInp_showTrendline4 ? f_movingAverage(maType = maInp_smoothingType4, source = maCal_sourceConnection4, length = maInp_length4) : na
plot(series = maCal_usesMainChart4 ? maCal_ma4 : na,  title = "MA 4 (Main Chart)", color = maInp_color4, linewidth = maInp_trendlineWidth4, style = maCal_styleType4, editable = false, force_overlay = true)
plot(series = maCal_showOverlayFalse4 ? maCal_ma4 : na, title = "MA 4", color = maInp_color4, linewidth = maInp_trendlineWidth4, style = maCal_styleType4, editable = false, force_overlay = false)

// Structure and plotting as in MA 1.
float maCal_sourceConnection5 = 
  maInp_indicatorConnection5 == dfiCon_optMainChart  ? maInp_source5   :
  maInp_indicatorConnection5 == dfiCon_optComparison ? csCal_close     :
  maInp_indicatorConnection5 == dfiCon_optAtr        ? atrCal_function :
  maInp_indicatorConnection5 == dfiCon_optCci        ? cciCal_function :
  maInp_indicatorConnection5 == dfiCon_optEom        ? eomCal_function :
  maInp_indicatorConnection5 == dfiCon_optEfi        ? efiCal_function :
  maInp_indicatorConnection5 == dfiCon_optMom        ? momCal_function :
  maInp_indicatorConnection5 == dfiCon_optMfi        ? mfiCal_function :
  maInp_indicatorConnection5 == dfiCon_optObv        ? obvCal_function :
  maInp_indicatorConnection5 == dfiCon_optRoc        ? rocCal_function :
  maInp_indicatorConnection5 == dfiCon_optRsi        ? rsiCal_function :
  maInp_indicatorConnection5 == dfiCon_optRvi        ? rviCal_function :
  maInp_indicatorConnection5 == dfiCon_optSto        ? stoCal_function :
  maInp_indicatorConnection5 == dfiCon_optSrs        ? srsCal_function :
  maInp_indicatorConnection5 == dfiCon_optTsi        ? tsiCal_function :
  maInp_indicatorConnection5 == dfiCon_optUos        ? uosCal_function :
  maInp_indicatorConnection5 == dfiCon_optVol        ? volCal_function :
  maInp_indicatorConnection5 == dfiCon_optWpr        ? wprCal_function :
  float(na)

bool maCal_showOverlayFalse5 = 
  maInp_indicatorConnection5 == dfiCon_optMainChart  ? false                 :
  maInp_indicatorConnection5 == dfiCon_optComparison ? dfiCal_showComparison :
  maInp_indicatorConnection5 == dfiCon_optAtr        ? dfiCal_showAtr        :
  maInp_indicatorConnection5 == dfiCon_optCci        ? dfiCal_showCci        :
  maInp_indicatorConnection5 == dfiCon_optEom        ? dfiCal_showEom        :
  maInp_indicatorConnection5 == dfiCon_optEfi        ? dfiCal_showEfi        :
  maInp_indicatorConnection5 == dfiCon_optMom        ? dfiCal_showMom        :
  maInp_indicatorConnection5 == dfiCon_optMfi        ? dfiCal_showMfi        :
  maInp_indicatorConnection5 == dfiCon_optObv        ? dfiCal_showObv        :
  maInp_indicatorConnection5 == dfiCon_optRoc        ? dfiCal_showRoc        :
  maInp_indicatorConnection5 == dfiCon_optRsi        ? dfiCal_showRsi        :
  maInp_indicatorConnection5 == dfiCon_optRvi        ? dfiCal_showRvi        :
  maInp_indicatorConnection5 == dfiCon_optSto        ? dfiCal_showSto        :
  maInp_indicatorConnection5 == dfiCon_optSrs        ? dfiCal_showSrs        :
  maInp_indicatorConnection5 == dfiCon_optTsi        ? dfiCal_showTsi        :
  maInp_indicatorConnection5 == dfiCon_optUos        ? dfiCal_showUos        :
  maInp_indicatorConnection5 == dfiCon_optVol        ? dfiCal_showVol        :
  maInp_indicatorConnection5 == dfiCon_optWpr        ? dfiCal_showWpr        :
  false
float maCal_ma5 = maInp_showTrendline5 ? f_movingAverage(maType = maInp_smoothingType5, source = maCal_sourceConnection5, length = maInp_length5) : na
plot(series = maCal_usesMainChart5 ? maCal_ma5 : na,  title = "MA 5 (Main Chart)", color = maInp_color5, linewidth = maInp_trendlineWidth5, style = maCal_styleType5, editable = false, force_overlay = true)
plot(series = maCal_showOverlayFalse5 ? maCal_ma5 : na, title = "MA 5", color = maInp_color5, linewidth = maInp_trendlineWidth5, style = maCal_styleType5, editable = false, force_overlay = false)
````
