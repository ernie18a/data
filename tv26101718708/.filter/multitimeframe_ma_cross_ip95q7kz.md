# Multi-Timeframe MA Cross

- url: https://www.tradingview.com/script/IP95Q7KZ-Multi-Timeframe-MA-Cross/
- type: indicator
- pine_id: PUB;3b7a11b2837c48c095fc7fc02bbd79a9
- version: 1.0

## Description

Multi-Timeframe MA Cross (MTFMAC) is a professional-grade trend analysis tool designed for traders who wish to view market structure across multiple timeframes at a glance. It consolidates key exponential moving averages (EMAs) into a single dashboard, helping traders make quick, informed decisions based on price alignment with moving averages.

This indicator provides a clear visual overview of trend direction and alignment from intraday (1-minute) to weekly charts. By highlighting whether price is above or below key EMAs and signalling EMA crossovers, traders can quickly identify bullish or bearish trends, trend strength, and high-probability trade setups.

Key Features

Multi-timeframe EMA dashboard (1 min → 1 week)
Real-time trend alignment for 20, 50, 100, and 200 EMAs
Visual "Above/Below" signals for each EMA
Weekly EMA overlays for higher timeframe context
Alerts for bullish/bearish alignment and EMA crosses
Fully customisable EMA lengths and visual settings
Professional table and chart display, overlaying price

How It Works

Compares the current price to 20, 50, 100, and 200 EMAs across multiple timeframes.
Colours indicate whether price is above (green) or below (red) the EMA.
Weekly EMA lines are plotted as dashed or circle-style overlays for macro trend context.
Alerts notify the trader when:
All EMAs align bullishly or bearishly
20 EMA crosses above or below 50 EMA
Best Use Cases
Trend-following strategies
Multi-timeframe confirmation
Swing and intraday trading
Spotting market bias and trend reversals
High-probability trade filtering

Alerts

Bullish Trend Alignment: All EMAs in ascending order, price above EMAs
Bearish Trend Alignment: All EMAs in descending order, price below EMAs
Bullish EMA Cross: 20 EMA crosses above 50 EMA
Bearish EMA Cross: 20 EMA crosses below 50 EMA


Notes and Disclaimers
This indicator does not repaint; all signals are based on confirmed bar data.
Use as a decision-support tool, not as sole trade advice. Combine with risk management.
Optimised for clear visualisation and multi-timeframe analysis.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator('Multi-Timeframe MA Cross', shorttitle = 'MTFMATABLE', overlay = true)


// =============================
// TABLE SETTINGS
// =============================

textSize = input.string(size.normal, title = 'Table Text Size', options = [size.tiny, size.small, size.normal, size.large, size.auto])


// =============================
// MA TYPE SELECTION
// =============================

maType = input.string('EMA', title = 'Moving Average Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'])


// =============================
// MA ENGINE
// =============================

getMA(src, len) =>

    ma = maType == 'SMA' ? ta.sma(src, len) : maType == 'EMA' ? ta.ema(src, len) : maType == 'WMA' ? ta.wma(src, len) : maType == 'VWMA' ? ta.vwma(src, len) : maType == 'RMA' ? ta.rma(src, len) : ta.hma(src, len)

    ma


// =============================
// ON CHART SETTINGS
// =============================

group_chart = 'On-Chart Moving Averages'

showMA20 = input.bool(true, 'Show 20 MA', group = group_chart)
ma20Length = input.int(20, '20 Length', group = group_chart)

showMA50 = input.bool(true, 'Show 50 MA', group = group_chart)
ma50Length = input.int(50, '50 Length', group = group_chart)

showMA100 = input.bool(false, 'Show 100 MA', group = group_chart)
ma100Length = input.int(100, '100 Length', group = group_chart)

showMA200 = input.bool(false, 'Show 200 MA', group = group_chart)
ma200Length = input.int(200, '200 Length', group = group_chart)


// =============================
// HTF SETTINGS (UPDATED)
// =============================

group_htf = 'Higher Timeframe MAs'

htf_tf = input.timeframe('W', 'Higher Timeframe', group = group_htf)

showHTF20 = input.bool(true, 'Show HTF 20 MA', group = group_htf)
showHTF50 = input.bool(false, 'Show HTF 50 MA', group = group_htf)
showHTF100 = input.bool(false, 'Show HTF 100 MA', group = group_htf)
showHTF200 = input.bool(false, 'Show HTF 200 MA', group = group_htf)


// =============================
// TABLE CONDITION ENGINE
// =============================

calculateCondition(tf, len) =>

    ma = request.security(syminfo.tickerid, tf, getMA(close, len))

    price = request.security(syminfo.tickerid, tf, close)

    col = price > ma ? color.green : color.red

    [str.tostring(ma, format.mintick), col]


// =============================
// TABLE STRUCTURE
// =============================

rows = 8
columns = 5

table tbl = table.new(position.top_right, rows, columns, bgcolor = color.black)


// HEADERS

table.cell(tbl, 0, 0, 'Timeframe', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 1, '20 MA', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 2, '50 MA', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 3, '100 MA', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 4, '200 MA', bgcolor = color.gray, text_color = color.white, text_size = textSize)


// =============================
// ROW FUNCTION
// =============================

fillRow(row, tf, label) =>

    table.cell(tbl, row, 0, label, text_color = color.white, text_size = textSize)

    [c1, col1] = calculateCondition(tf, ma20Length)
    table.cell(tbl, row, 1, c1, bgcolor = col1, text_color = color.white, text_size = textSize)

    [c2, col2] = calculateCondition(tf, ma50Length)
    table.cell(tbl, row, 2, c2, bgcolor = col2, text_color = color.white, text_size = textSize)

    [c3, col3] = calculateCondition(tf, ma100Length)
    table.cell(tbl, row, 3, c3, bgcolor = col3, text_color = color.white, text_size = textSize)

    [c4, col4] = calculateCondition(tf, ma200Length)
    table.cell(tbl, row, 4, c4, bgcolor = col4, text_color = color.white, text_size = textSize)


// =============================
// TABLE DATA
// =============================

fillRow(1, '1', '1 Minute')
fillRow(2, '5', '5 Minute')
fillRow(3, '15', '15 Minute')
fillRow(4, '60', '1 Hour')
fillRow(5, '240', '4 Hour')
fillRow(6, 'D', '1 Day')
fillRow(7, 'W', '1 Week')


// =============================
// ON CHART MA
// =============================

src = close

ma20 = getMA(src, ma20Length)
ma50 = getMA(src, ma50Length)
ma100 = getMA(src, ma100Length)
ma200 = getMA(src, ma200Length)


// =============================
// HTF MA (FULLY UPDATED)
// =============================

ma20_htf = request.security(syminfo.tickerid, htf_tf, getMA(src, ma20Length))
ma50_htf = request.security(syminfo.tickerid, htf_tf, getMA(src, ma50Length))
ma100_htf = request.security(syminfo.tickerid, htf_tf, getMA(src, ma100Length))
ma200_htf = request.security(syminfo.tickerid, htf_tf, getMA(src, ma200Length))


// =============================
// PLOTS
// =============================

plot(showMA20 ? ma20 : na, color = color.rgb(94, 255, 0, 40), linewidth = 2, title = '20 MA')
plot(showMA50 ? ma50 : na, color = #0065fc, linewidth = 2, title = '50 MA')
plot(showMA100 ? ma100 : na, color = color.purple, linewidth = 2, title = '100 MA')
plot(showMA200 ? ma200 : na, color = #ff0000, linewidth = 2, title = '200 MA')

plot(showHTF20 ? ma20_htf : na, color = color.red, style = plot.style_circles, linewidth = 1, title = 'HTF 20 MA')
plot(showHTF50 ? ma50_htf : na, color = color.rgb(0, 101, 252, 43), style = plot.style_circles, linewidth = 1, title = 'HTF 50 MA')
plot(showHTF100 ? ma100_htf : na, color = color.rgb(128, 0, 128, 50), style = plot.style_circles, linewidth = 1, title = 'HTF 100 MA')
plot(showHTF200 ? ma200_htf : na, color = color.orange, style = plot.style_circles, linewidth = 1, title = 'HTF 200 MA')
````
