# [Bitget] Moving Average Angle Slope

- url: https://www.tradingview.com/script/OQa3eX8O-Bitget-Moving-Average-Angle-Slope/
- type: indicator
- pine_id: PUB;2d96226c0736420cb1f40f68cca9b9bd
- version: 1.0

## Description

[Bitget] Moving Average Angle Slope is a customizable multi-moving-average indicator designed to help traders quickly identify the directional slope of multiple moving averages.

The indicator supports up to 10 independently configurable moving averages. Each moving average can use a different length, type, color, and visibility setting.

A label is displayed beside each enabled moving average on the latest bar. The label shows the MA length, MA type, and a directional arrow to help visually identify whether the moving average is currently rising, falling, or flat.

[b]Features[/b]
Supports up to 10 Moving Averages
Supports SMA, EMA, WMA, and RMA
Independent settings for each Moving Average
Custom MA length and color
Optional MA visibility control
Direction arrows displayed beside each MA label
Adjustable arrow lookback sensitivity
Adjustable minimum movement filter
Adjustable label position offset
Direction Arrows
Each Moving Average label includes one of the following directional arrows:

↑ Up Arrow: The Moving Average is currently trending upward.
↓ Down Arrow: The Moving Average is currently trending downward.
→ Flat Arrow: The Moving Average is relatively flat, or the movement does not exceed the selected minimum threshold.
The arrow direction is based on the current MA position relative to its previous values over the selected lookback period.

[b]How to Use[/b]
This indicator is designed to provide a quick visual overview of moving average direction across short-, medium-, and long-term trend periods.

For example:

When short-term and long-term Moving Averages all display upward arrows, it may indicate broad bullish trend alignment.
When multiple Moving Averages display downward arrows, it may indicate bearish trend alignment.
When short-term MAs point downward while longer-term MAs remain upward, it may indicate a pullback within a broader uptrend.
When MA arrows shift from down to flat to up, it may suggest that downward momentum is weakening and the Moving Average direction is improving.
The indicator can be used on any market and timeframe, including cryptocurrency, stocks, forex, indices, commodities, and futures.

[b]Suggested Use Cases[/b]
Trend Direction Confirmation
Use several Moving Averages with different lengths to quickly identify whether trend direction is aligned.

For example, traders may monitor short-, medium-, and long-term MAs together:

Short-term MA: 10 EMA or 20 EMA
Medium-term MA: 50 SMA
Long-term MA: 100 SMA or 200 SMA
If all selected MAs are showing upward arrows, the market may be in a broader upward trend. If all are showing downward arrows, the market may be in a broader downward trend.

Pullback Analysis
During an established trend, short-term Moving Averages may temporarily turn in the opposite direction while longer-term Moving Averages remain aligned with the primary trend.

For example:

Short-term MA shows a downward arrow.
Long-term MA continues showing an upward arrow.
This may indicate a short-term pullback within a larger uptrend. Traders can use this information alongside price action, support and resistance, volume, or other confirmation tools.

Multi-Timeframe Analysis
The indicator can be applied to different timeframes to help analyze market direction from different perspectives.

Example workflow:

Use higher timeframes to evaluate overall trend direction with longer Moving Averages.
Use lower timeframes to monitor short-term MA direction for potential timing and momentum confirmation.
A trader may look for longer-term Moving Averages to point upward on a higher timeframe, while waiting for short-term Moving Averages to turn upward on a lower timeframe.

[b]Settings[/b]

Source
Selects the price source used for Moving Average calculations.

Common options include Close, Open, High, Low, HL2, HLC3, and OHLC4.

Arrow Direction Lookback Bars
Controls how many previous bars are used to determine the Moving Average direction.

A lower value provides faster and more sensitive arrow changes.

A higher value provides a smoother view of the overall MA direction and can reduce short-term noise.

Suggested values:

1 to 2 bars: More responsive for short-term trading.
3 to 5 bars: Smoother direction reading for swing trading.
5 or more bars: Better for broader trend direction analysis.
Minimum Movement in Ticks
Controls the minimum amount of MA movement required before displaying an upward or downward arrow.

Use a higher value to filter small fluctuations during sideways or low-volatility market conditions.

When the MA movement is below the selected threshold, the indicator displays a flat arrow.

[b]Label Offset to the Right[/b]
Controls the horizontal distance between the latest price bar and the MA labels.

Increase this setting if labels overlap with candles, price scale elements, or other indicators.

[b]Moving Average Types[/b]

SMA — Simple Moving Average
A commonly used Moving Average that provides a smooth view of overall price direction.

Suitable for medium-term and long-term trend analysis.

EMA — Exponential Moving Average
Places more emphasis on recent price movement and reacts faster than SMA.

Commonly used for short-term trend and momentum analysis.

WMA — Weighted Moving Average
Gives greater importance to recent prices and provides a responsive but smooth Moving Average.

RMA — Running Moving Average
A smoother Moving Average often associated with Wilder-style calculations.

May be useful for traders who prefer less reactive MA behavior.

[b]Notes[/b]

This indicator is designed to visualize Moving Average direction, not to generate guaranteed buy or sell signals.
Moving Averages are lagging indicators and are based on historical price data.
Arrow direction can change as new price data becomes available.
Results may vary depending on market, timeframe, MA type, MA length, and selected settings.
This indicator may be more effective when combined with price action, market structure, volume, support and resistance, and risk management.

Disclaimer:

These indicator scripts are sample script templates for information only. Nothing herein shall be construed as financial or investment advice or solicitation to trade or use any service. Bitget does not guarantee the accuracy or completeness of any information provided. 

Cryptocurrencies are subject to high market risks. Investors are strongly advised to conduct their own research and seek independent professional advice before investing at their own risk. Past performance or financial indicators are not reliable predictors of future performance. Bitget has no control over any third-party applications, such as TradingView, and is not responsible for any loss relating to any use of TradingView or these scripts. As a security measure, please use read-only API keys with no trading or withdrawal permissions.

## Source Code

````pine
//@version=6
indicator('[Bitget] Moving Average Angle Slope', overlay = true, max_labels_count = 50)

//────────────────────────────────────
// General Settings
//────────────────────────────────────
src = input.source(close, title = 'Source')

// Label Direction Settings
labelLookback = input.int(1, title = 'Arrow Direction Lookback Bars', minval = 1, group = 'Label Settings')
minMoveTicks = input.int(0, title = 'Minimum Movement in Ticks (0 = Disabled)', minval = 0, group = 'Label Settings')
labelOffset = input.int(2, title = 'Label Offset to the Right (Bars)', minval = 0, group = 'Label Settings')

//────────────────────────────────────
// MA Calculation Function
//────────────────────────────────────
get_ma(_src, _length, _type) =>
    float ma = na

    if _length > 0
        switch _type
            'SMA' => 
        	    ma := ta.sma(_src, _length)
        	    ma
            'EMA' => 
        	    ma := ta.ema(_src, _length)
        	    ma
            'WMA' => 
        	    ma := ta.wma(_src, _length)
        	    ma
            'RMA' => 
        	    ma := ta.rma(_src, _length)
        	    ma

    ma

//────────────────────────────────────
// MA 1
//────────────────────────────────────
show1 = input.bool(true, title = 'Show MA 1', group = 'MA 1', inline = '1')
len1 = input.int(10, title = 'Length', minval = 1, group = 'MA 1', inline = '1')
type1 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 1', inline = '1')
col1 = input.color(#FF0000, title = '', group = 'MA 1', inline = '1')
ma1 = get_ma(src, len1, type1)

//────────────────────────────────────
// MA 2
//────────────────────────────────────
show2 = input.bool(true, title = 'Show MA 2', group = 'MA 2', inline = '2')
len2 = input.int(20, title = 'Length', minval = 1, group = 'MA 2', inline = '2')
type2 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 2', inline = '2')
col2 = input.color(#FF7F00, title = '', group = 'MA 2', inline = '2')
ma2 = get_ma(src, len2, type2)

//────────────────────────────────────
// MA 3
//────────────────────────────────────
show3 = input.bool(true, title = 'Show MA 3', group = 'MA 3', inline = '3')
len3 = input.int(50, title = 'Length', minval = 1, group = 'MA 3', inline = '3')
type3 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 3', inline = '3')
col3 = input.color(#FFFF00, title = '', group = 'MA 3', inline = '3')
ma3 = get_ma(src, len3, type3)

//────────────────────────────────────
// MA 4
//────────────────────────────────────
show4 = input.bool(true, title = 'Show MA 4', group = 'MA 4', inline = '4')
len4 = input.int(100, title = 'Length', minval = 1, group = 'MA 4', inline = '4')
type4 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 4', inline = '4')
col4 = input.color(#00FF00, title = '', group = 'MA 4', inline = '4')
ma4 = get_ma(src, len4, type4)

//────────────────────────────────────
// MA 5
//────────────────────────────────────
show5 = input.bool(true, title = 'Show MA 5', group = 'MA 5', inline = '5')
len5 = input.int(200, title = 'Length', minval = 1, group = 'MA 5', inline = '5')
type5 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 5', inline = '5')
col5 = input.color(#0000FF, title = '', group = 'MA 5', inline = '5')
ma5 = get_ma(src, len5, type5)

//────────────────────────────────────
// MA 6
//────────────────────────────────────
show6 = input.bool(false, title = 'Show MA 6', group = 'MA 6', inline = '6')
len6 = input.int(15, title = 'Length', minval = 1, group = 'MA 6', inline = '6')
type6 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 6', inline = '6')
col6 = input.color(#4B0082, title = '', group = 'MA 6', inline = '6')
ma6 = get_ma(src, len6, type6)

//────────────────────────────────────
// MA 7
//────────────────────────────────────
show7 = input.bool(false, title = 'Show MA 7', group = 'MA 7', inline = '7')
len7 = input.int(30, title = 'Length', minval = 1, group = 'MA 7', inline = '7')
type7 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 7', inline = '7')
col7 = input.color(#9400D3, title = '', group = 'MA 7', inline = '7')
ma7 = get_ma(src, len7, type7)

//────────────────────────────────────
// MA 8
//────────────────────────────────────
show8 = input.bool(false, title = 'Show MA 8', group = 'MA 8', inline = '8')
len8 = input.int(60, title = 'Length', minval = 1, group = 'MA 8', inline = '8')
type8 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 8', inline = '8')
col8 = input.color(#FF1493, title = '', group = 'MA 8', inline = '8')
ma8 = get_ma(src, len8, type8)

//────────────────────────────────────
// MA 9
//────────────────────────────────────
show9 = input.bool(false, title = 'Show MA 9', group = 'MA 9', inline = '9')
len9 = input.int(120, title = 'Length', minval = 1, group = 'MA 9', inline = '9')
type9 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 9', inline = '9')
col9 = input.color(#00CED1, title = '', group = 'MA 9', inline = '9')
ma9 = get_ma(src, len9, type9)

//────────────────────────────────────
// MA 10
//────────────────────────────────────
show10 = input.bool(false, title = 'Show MA 10', group = 'MA 10', inline = '10')
len10 = input.int(250, title = 'Length', minval = 1, group = 'MA 10', inline = '10')
type10 = input.string('EMA', title = 'Type', options = ['SMA', 'EMA', 'WMA', 'RMA'], group = 'MA 10', inline = '10')
col10 = input.color(#8B4513, title = '', group = 'MA 10', inline = '10')
ma10 = get_ma(src, len10, type10)

//────────────────────────────────────
// Plot Moving Averages
//────────────────────────────────────
plot(show1 ? ma1 : na, color = col1, title = 'MA 1', linewidth = 2)
plot(show2 ? ma2 : na, color = col2, title = 'MA 2', linewidth = 2)
plot(show3 ? ma3 : na, color = col3, title = 'MA 3', linewidth = 2)
plot(show4 ? ma4 : na, color = col4, title = 'MA 4', linewidth = 2)
plot(show5 ? ma5 : na, color = col5, title = 'MA 5', linewidth = 2)
plot(show6 ? ma6 : na, color = col6, title = 'MA 6', linewidth = 1)
plot(show7 ? ma7 : na, color = col7, title = 'MA 7', linewidth = 1)
plot(show8 ? ma8 : na, color = col8, title = 'MA 8', linewidth = 1)
plot(show9 ? ma9 : na, color = col9, title = 'MA 9', linewidth = 1)
plot(show10 ? ma10 : na, color = col10, title = 'MA 10', linewidth = 1)

//────────────────────────────────────
// Get MA Direction Arrow
// Compares current MA value with MA value N bars ago
//────────────────────────────────────
get_arrow(_ma, _lookback, _minTicks) =>
    string arrow = '→'

    float minMove = syminfo.mintick * _minTicks
    float diff = _ma - _ma[_lookback]

    if not na(_ma) and not na(_ma[_lookback])
        if diff > minMove
            arrow := '↑'
            arrow
        else if diff < -minMove
            arrow := '↓'
            arrow

    arrow

//────────────────────────────────────
// Create or Update MA Label
//────────────────────────────────────
draw_label(_label, _show, _ma, _len, _type, _color, _arrow) =>
    label result = _label

    if barstate.islast
        if _show and not na(_ma)
            string labelText = str.tostring(_len) + ' ' + _type + ' ' + _arrow

            if na(result)
                result := label.new(x = bar_index + labelOffset, y = _ma, text = labelText, color = color.new(_color, 80), textcolor = _color, style = label.style_label_left, size = size.small)
                result
            else
                label.set_x(result, bar_index + labelOffset)
                label.set_y(result, _ma)
                label.set_text(result, labelText)
                label.set_color(result, color.new(_color, 80))
                label.set_textcolor(result, _color)
                label.set_style(result, label.style_label_left)
                label.set_size(result, size.small)
        else
            if not na(result)
                label.delete(result)
                result := na
                result

    result

//────────────────────────────────────
// Calculate Direction for Each MA
//────────────────────────────────────
arrow1 = get_arrow(ma1, labelLookback, minMoveTicks)
arrow2 = get_arrow(ma2, labelLookback, minMoveTicks)
arrow3 = get_arrow(ma3, labelLookback, minMoveTicks)
arrow4 = get_arrow(ma4, labelLookback, minMoveTicks)
arrow5 = get_arrow(ma5, labelLookback, minMoveTicks)
arrow6 = get_arrow(ma6, labelLookback, minMoveTicks)
arrow7 = get_arrow(ma7, labelLookback, minMoveTicks)
arrow8 = get_arrow(ma8, labelLookback, minMoveTicks)
arrow9 = get_arrow(ma9, labelLookback, minMoveTicks)
arrow10 = get_arrow(ma10, labelLookback, minMoveTicks)

//────────────────────────────────────
// Keep One Label per Moving Average
//────────────────────────────────────
var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na
var label lbl6 = na
var label lbl7 = na
var label lbl8 = na
var label lbl9 = na
var label lbl10 = na

//────────────────────────────────────
// Update Labels on the Last Bar
//────────────────────────────────────
lbl1 := draw_label(lbl1, show1, ma1, len1, type1, col1, arrow1)
lbl2 := draw_label(lbl2, show2, ma2, len2, type2, col2, arrow2)
lbl3 := draw_label(lbl3, show3, ma3, len3, type3, col3, arrow3)
lbl4 := draw_label(lbl4, show4, ma4, len4, type4, col4, arrow4)
lbl5 := draw_label(lbl5, show5, ma5, len5, type5, col5, arrow5)
lbl6 := draw_label(lbl6, show6, ma6, len6, type6, col6, arrow6)
lbl7 := draw_label(lbl7, show7, ma7, len7, type7, col7, arrow7)
lbl8 := draw_label(lbl8, show8, ma8, len8, type8, col8, arrow8)
lbl9 := draw_label(lbl9, show9, ma9, len9, type9, col9, arrow9)
lbl10 := draw_label(lbl10, show10, ma10, len10, type10, col10, arrow10)
````
