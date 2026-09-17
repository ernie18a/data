<!-- tradingview-pine-id: PUB;e416f5335f1d428a96d2ae8273a2e467 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Moving Average Candle

Source: https://www.tradingview.com/script/1JV6bQcf/

## Description

Moving Average Candle turns up to three moving averages into full OHLC candles instead of plain lines, so you can read a moving average's shape and momentum the way you'd read a price candle. It's built for anyone who wants to see a moving average's open, high, low and close at a glance — for example to judge a moving average's momentum and turning points the way you would judge price action, or to compare several of these MA candles against each other and against the underlying price on the same chart.

Each of the up to three MA candles can independently be calculated as SMA, EMA, WMA, VWMA, HMA, or RMA — standard formulas from TradingView's own library, with no custom modification.

MA Candle (present three times, MA Candle 1–3, each instance identically structured)

Length:        number of bars the average is calculated over.
MA Type:       calculation method: SMA, EMA, WMA, VWMA, HMA, or RMA.
Candle Style:  Wick or Fill.
Bull / Bear:   two colors: one for when the moving average's close is above its previous value, the other for the opposite case.

https://www.tradingview.com/x/fM4DEH9x/

Each enabled MA candle is built from the moving averages of the bar's open, high, low and close, then colored by whether the moving average's close is rising or falling. The high and low are clamped so they never sit inside the body, which keeps the candle intact even for moving average types like HMA whose weighting can otherwise push a value outside a normal high/low range.

In Wick style, the high and low are drawn as a candle wick, just like a regular price candle. In Fill style, the wick is hidden and the high/low range is shown instead as a shaded band; the candle body stays visible in both styles.

https://de.tradingview.com/x/HWNzWrcj/
https://de.tradingview.com/x/TmyXdUEE/

This indicator is intended solely for market analysis and does not constitute investment advice or a guarantee of success. Use it at your own discretion and risk; past results are not indicative of future performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © graefe
//@version=6
indicator(title = "Moving Average Candle", overlay = true, behind_chart = false)

/////-----CONSTANTS-----/////

// One shared group for all three candles, instances are distinguished only by the visibility input's title
const string con_grpCandle = "MA Candle"

// Transparency of the fill area
const int con_fillTransparency = 80

// Tooltips defined once as constants so they stay identical across all three candles
const string con_styleTooltip = "Visual style for the high and low values.\nWick draws them as candle wicks, Fill shades the range as a band."
const string con_colorTooltip = "Colors follow the direction of the moving average close, not the direction of the candle body."

/////-----FUNCTION-----/////

// Calculates the selected moving average type for a given source/length
f_movingAverage(maType, source, length) =>
    switch maType
        "SMA"  => ta.sma(source, length)
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        "HMA"  => ta.hma(source, length)
        "RMA"  => ta.rma(source, length)
        =>        na

/////-----BLOCK 1-----/////

// The following three blocks are identically structured for MA Candle 1-3: visibility, length, type, style, colors, calculation and drawing
bool   inp_showCandle1  = input.bool(defval = true, title = "MA Candle 1", group = con_grpCandle)
int    inp_length1      = input.int(defval = 21, title = "", minval = 1, maxval = 5000, inline = "candle1_calc", group = con_grpCandle, active = inp_showCandle1)
string inp_maType1      = input.string(defval = "SMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "candle1_calc", group = con_grpCandle, active = inp_showCandle1)
string inp_candleStyle1 = input.string(defval = "Wick", title = "Candle Style", options = ["Wick", "Fill"], tooltip = con_styleTooltip, group = con_grpCandle, active = inp_showCandle1)
color  inp_bullColor1   = input.color(defval = color.new(color.green, 0), title = "Bull / Bear", inline = "candle1_color", group = con_grpCandle, active = inp_showCandle1)
color  inp_bearColor1   = input.color(defval = color.new(color.red, 0), title = "", inline = "candle1_color", group = con_grpCandle, active = inp_showCandle1, tooltip = con_colorTooltip)

bool  cal_isWickStyle1  = inp_candleStyle1 == "Wick"
bool  cal_isFillStyle1  = inp_candleStyle1 == "Fill"

float cal_open1         = inp_showCandle1 ? f_movingAverage(maType = inp_maType1, source = open,  length = inp_length1) : na
float cal_close1        = inp_showCandle1 ? f_movingAverage(maType = inp_maType1, source = close, length = inp_length1) : na
float cal_maHigh1       = inp_showCandle1 ? f_movingAverage(maType = inp_maType1, source = high,  length = inp_length1) : na
float cal_maLow1        = inp_showCandle1 ? f_movingAverage(maType = inp_maType1, source = low,   length = inp_length1) : na

// High/low are clamped against open/close so that e.g. HMA (negative weights) can't produce broken candles
float cal_high1         = math.max(cal_maHigh1, cal_open1, cal_close1)
float cal_low1          = math.min(cal_maLow1,  cal_open1, cal_close1)

color cal_candleColor1  = cal_close1 > cal_close1[1] ? inp_bullColor1 : inp_bearColor1

plotcandle(open = cal_open1, high = cal_high1, low = cal_low1, close = cal_close1, title = "MA Candle 1", color = na, wickcolor = cal_isWickStyle1 ? cal_candleColor1 : na, bordercolor = cal_candleColor1, editable = false)

outp_high1 = plot(series = cal_high1, title = "MA Candle 1 High", color = na, editable = false)
outp_low1  = plot(series = cal_low1,  title = "MA Candle 1 Low",  color = na, editable = false)
fill(plot1 = outp_high1, plot2 = outp_low1, title = "MA Candle 1 Fill", color = cal_isFillStyle1 ? color.new(cal_candleColor1, con_fillTransparency) : na, editable = false)

/////-----BLOCK 2-----/////

bool   inp_showCandle2  = input.bool(defval = false, title = "MA Candle 2", group = con_grpCandle)
int    inp_length2      = input.int(defval = 50, title = "", minval = 1, maxval = 5000, inline = "candle2_calc", group = con_grpCandle, active = inp_showCandle2)
string inp_maType2      = input.string(defval = "EMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "candle2_calc", group = con_grpCandle, active = inp_showCandle2)
string inp_candleStyle2 = input.string(defval = "Fill", title = "Candle Style", options = ["Wick", "Fill"], tooltip = con_styleTooltip, group = con_grpCandle, active = inp_showCandle2)
color  inp_bullColor2   = input.color(defval = color.new(color.blue, 0), title = "Bull / Bear", inline = "candle2_color", group = con_grpCandle, active = inp_showCandle2)
color  inp_bearColor2   = input.color(defval = color.new(color.purple, 0), title = "", inline = "candle2_color", group = con_grpCandle, active = inp_showCandle2, tooltip = con_colorTooltip)

bool  cal_isWickStyle2  = inp_candleStyle2 == "Wick"
bool  cal_isFillStyle2  = inp_candleStyle2 == "Fill"

float cal_open2         = inp_showCandle2 ? f_movingAverage(maType = inp_maType2, source = open,  length = inp_length2) : na
float cal_close2        = inp_showCandle2 ? f_movingAverage(maType = inp_maType2, source = close, length = inp_length2) : na
float cal_maHigh2       = inp_showCandle2 ? f_movingAverage(maType = inp_maType2, source = high,  length = inp_length2) : na
float cal_maLow2        = inp_showCandle2 ? f_movingAverage(maType = inp_maType2, source = low,   length = inp_length2) : na

float cal_high2         = math.max(cal_maHigh2, cal_open2, cal_close2)
float cal_low2          = math.min(cal_maLow2,  cal_open2, cal_close2)

color cal_candleColor2  = cal_close2 > cal_close2[1] ? inp_bullColor2 : inp_bearColor2

plotcandle(open = cal_open2, high = cal_high2, low = cal_low2, close = cal_close2, title = "MA Candle 2", color = na, wickcolor = cal_isWickStyle2 ? cal_candleColor2 : na, bordercolor = cal_candleColor2, editable = false)

outp_high2 = plot(series = cal_high2, title = "MA Candle 2 High", color = na, editable = false)
outp_low2  = plot(series = cal_low2,  title = "MA Candle 2 Low",  color = na, editable = false)
fill(plot1 = outp_high2, plot2 = outp_low2, title = "MA Candle 2 Fill", color = cal_isFillStyle2 ? color.new(cal_candleColor2, con_fillTransparency) : na, editable = false)

/////-----BLOCK 3-----/////

bool   inp_showCandle3  = input.bool(defval = false, title = "MA Candle 3", group = con_grpCandle)
int    inp_length3      = input.int(defval = 8, title = "", minval = 1, maxval = 5000, inline = "candle3_calc", group = con_grpCandle, active = inp_showCandle3)
string inp_maType3      = input.string(defval = "RMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "candle3_calc", group = con_grpCandle, active = inp_showCandle3)
string inp_candleStyle3 = input.string(defval = "Wick", title = "Candle Style", options = ["Wick", "Fill"], tooltip = con_styleTooltip, group = con_grpCandle, active = inp_showCandle3)
color  inp_bullColor3   = input.color(defval = color.new(color.yellow, 0), title = "Bull / Bear", inline = "candle3_color", group = con_grpCandle, active = inp_showCandle3)
color  inp_bearColor3   = input.color(defval = color.new(color.orange, 0), title = "", inline = "candle3_color", group = con_grpCandle, active = inp_showCandle3, tooltip = con_colorTooltip)

bool  cal_isWickStyle3  = inp_candleStyle3 == "Wick"
bool  cal_isFillStyle3  = inp_candleStyle3 == "Fill"

float cal_open3         = inp_showCandle3 ? f_movingAverage(maType = inp_maType3, source = open,  length = inp_length3) : na
float cal_close3        = inp_showCandle3 ? f_movingAverage(maType = inp_maType3, source = close, length = inp_length3) : na
float cal_maHigh3       = inp_showCandle3 ? f_movingAverage(maType = inp_maType3, source = high,  length = inp_length3) : na
float cal_maLow3        = inp_showCandle3 ? f_movingAverage(maType = inp_maType3, source = low,   length = inp_length3) : na

float cal_high3         = math.max(cal_maHigh3, cal_open3, cal_close3)
float cal_low3          = math.min(cal_maLow3,  cal_open3, cal_close3)

color cal_candleColor3  = cal_close3 > cal_close3[1] ? inp_bullColor3 : inp_bearColor3

plotcandle(open = cal_open3, high = cal_high3, low = cal_low3, close = cal_close3, title = "MA Candle 3", color = na, wickcolor = cal_isWickStyle3 ? cal_candleColor3 : na, bordercolor = cal_candleColor3, editable = false)

outp_high3 = plot(series = cal_high3, title = "MA Candle 3 High", color = na, editable = false)
outp_low3  = plot(series = cal_low3,  title = "MA Candle 3 Low",  color = na, editable = false)
fill(plot1 = outp_high3, plot2 = outp_low3, title = "MA Candle 3 Fill", color = cal_isFillStyle3 ? color.new(cal_candleColor3, con_fillTransparency) : na, editable = false)
````
