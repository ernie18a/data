# MTF MA Cross Table Pro

- url: https://www.tradingview.com/script/9XJ6hclY-MTF-MA-Cross-Table-Pro/
- type: indicator
- pine_id: PUB;cfe68586ba554bc5a3bf781abaa46313
- version: 1.0

## Description

**Multi-Timeframe MA Cross**

Multi-Timeframe MA Cross is a moving average dashboard and overlay tool designed to help traders quickly see whether price is trading above or below key exponential moving averages across multiple timeframes.

The indicator displays a table showing the relationship between price and the selected EMA lengths across several major timeframes, including:

* 1 Minute
* 5 Minute
* 15 Minute
* 1 Hour
* 4 Hour
* 1 Day
* 1 Week

Each timeframe is checked against the 20, 50, 100, and 200 EMA.
The table shows whether price is **Above** or **Below** each moving average.

**Table Colour Rules**

* **Green** = price is above the selected EMA
* **Red** = price is below the selected EMA

This gives a quick visual map of trend strength and moving average positioning across multiple timeframes.

**Main Features**

* Multi-timeframe EMA dashboard
* Tracks 20, 50, 100, and 200 EMA conditions
* Green/red table cells for fast trend reading
* Adjustable MA lengths
* Adjustable table text size
* Current timeframe EMA overlays
* Optional 20, 50, 100, and 200 EMA plots
* Optional weekly EMA overlays
* Designed for quick multi-timeframe trend confirmation

**Overlay Moving Averages**

The indicator can also plot moving averages directly on the chart, including:

* Current timeframe 20 EMA
* Current timeframe 50 EMA
* Current timeframe 100 EMA
* Current timeframe 200 EMA
* Weekly 20 EMA
* Weekly 50 EMA
* Weekly 100 EMA

Each moving average can be turned on or off from the settings panel.

**Suggested Use**

This indicator can be used to quickly assess whether price is aligned above or below important moving averages across short-term, intraday, daily, and weekly timeframes.

It may help traders identify broader trend alignment, support and resistance zones, and areas where multiple timeframe moving averages are acting as confirmation.

For example, if price is above the 20, 50, 100, and 200 EMA across multiple higher timeframes, this may suggest stronger bullish trend alignment. If price is below those averages, it may suggest weaker or bearish conditions.

**Disclaimer**

This indicator is designed as a visual trend and moving-average reference tool only. It is not financial advice and should not be used on its own for trade entries or exits. Always combine it with your own analysis, market structure, risk management, and trading plan.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0
// © davidholmes1992

//@version=6
indicator('Multi-Timeframe MA Cross', shorttitle = 'MTFMAC', overlay = true)

// --- Inputs for MA Lengths and Table Appearance ---
ma20Length = input(20, '20 MA Length')
ma50Length = input(50, '50 MA Length')
ma100Length = input(100, '100 MA Length')
ma200Length = input(200, '200 MA Length')

// Table Appearance Input (Adjusting text size affects table size)
textSize = input.string(size.normal, title = 'Table Text Size', options = [size.tiny, size.small, size.normal, size.large, size.auto])

// --- Inputs for MA Visibility Toggles ---
showMA20 = input.bool(true, title = 'Show Current TF 20 MA')
showMA50 = input.bool(true, title = 'Show Current TF 50 MA')
showMA100 = input.bool(false, title = 'Show Current TF 100 MA')
showMA200 = input.bool(false, title = 'Show Current TF 200 MA')
showWeeklyMA20 = input.bool(true, title = 'Show Weekly 20 MA')
showWeeklyMA50 = input.bool(false, title = 'Show Weekly 50 MA')
showWeeklyMA100 = input.bool(false, title = 'Show Weekly 100 MA')


// Function to calculate condition for a given timeframe and MA length
calculateCondition(timeframe, maLength) =>
    ma = request.security(syminfo.tickerid, timeframe, ta.ema(close, maLength))
    openPrice = request.security(syminfo.tickerid, timeframe, open)
    condition = openPrice > ma ? 'Above' : 'Below'
    color = openPrice > ma ? color.green : color.red
    [condition, color]

// Initialize the table
int rows = 8
int columns = 5
table tbl = table.new(position.top_right, rows, columns, bgcolor = color.black)

// Add headers to the table
table.cell(tbl, 0, 0, 'Timeframe', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 1, '20 MA Cross', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 2, '50 MA Cross', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 3, '100 MA Cross', bgcolor = color.gray, text_color = color.white, text_size = textSize)
table.cell(tbl, 0, 4, '200 MA Cross', bgcolor = color.gray, text_color = color.white, text_size = textSize)

// 1 Minute Timeframe for 20, 50, 100 and 200 MA
table.cell(tbl, 1, 0, '1 Minute', text_color = color.white, text_size = textSize)
[condition1Min20MA, color1Min20MA] = calculateCondition('1', ma20Length)
table.cell(tbl, 1, 1, condition1Min20MA, bgcolor = color1Min20MA, text_color = color.white, text_size = textSize)

[condition1Min50MA, color1Min50MA] = calculateCondition('1', ma50Length)
table.cell(tbl, 1, 2, condition1Min50MA, bgcolor = color1Min50MA, text_color = color.white, text_size = textSize)

[condition1Min100MA, color1Min100MA] = calculateCondition('1', ma100Length)
table.cell(tbl, 1, 3, condition1Min100MA, bgcolor = color1Min100MA, text_color = color.white, text_size = textSize)

[condition1Min200MA, color1Min200MA] = calculateCondition('1', ma200Length)
table.cell(tbl, 1, 4, condition1Min200MA, bgcolor = color1Min200MA, text_color = color.white, text_size = textSize)

// 5 Minutes Timeframe for 20, 50, 100 and 200 MA
table.cell(tbl, 2, 0, '5 Minute', text_color = color.white, text_size = textSize)
[condition5Min20MA, color5Min20MA] = calculateCondition('5', ma20Length)
table.cell(tbl, 2, 1, condition5Min20MA, bgcolor = color5Min20MA, text_color = color.white, text_size = textSize)

[condition5Min50MA, color5Min50MA] = calculateCondition('5', ma50Length)
table.cell(tbl, 2, 2, condition5Min50MA, bgcolor = color5Min50MA, text_color = color.white, text_size = textSize)

[condition5Min100MA, color5Min100MA] = calculateCondition('5', ma100Length)
table.cell(tbl, 2, 3, condition5Min100MA, bgcolor = color5Min100MA, text_color = color.white, text_size = textSize)

[condition5Min200MA, color5Min200MA] = calculateCondition('5', ma200Length)
table.cell(tbl, 2, 4, condition5Min200MA, bgcolor = color5Min200MA, text_color = color.white, text_size = textSize)

// 15 Minutes Timeframe for 20, 50, 100 and 200 MA
table.cell(tbl, 3, 0, '15 Minute', text_color = color.white, text_size = textSize)
[condition15Min20MA, color15Min20MA] = calculateCondition('15', ma20Length)
table.cell(tbl, 3, 1, condition15Min20MA, bgcolor = color15Min20MA, text_color = color.white, text_size = textSize)

[condition15Min50MA, color15Min50MA] = calculateCondition('15', ma50Length)
table.cell(tbl, 3, 2, condition15Min50MA, bgcolor = color15Min50MA, text_color = color.white, text_size = textSize)

[condition15Min100MA, color15Min100MA] = calculateCondition('15', ma100Length)
table.cell(tbl, 3, 3, condition15Min100MA, bgcolor = color15Min100MA, text_color = color.white, text_size = textSize)

[condition15Min200MA, color15Min200MA] = calculateCondition('15', ma200Length)
table.cell(tbl, 3, 4, condition15Min200MA, bgcolor = color15Min200MA, text_color = color.white, text_size = textSize)

// 1 Hour Timeframe for 20, 50, 100 and 200 MA
table.cell(tbl, 4, 0, '1 Hour', text_color = color.white, text_size = textSize)
[condition1H20MA, color1H20MA] = calculateCondition('60', ma20Length)
table.cell(tbl, 4, 1, condition1H20MA, bgcolor = color1H20MA, text_color = color.white, text_size = textSize)

[condition1H50MA, color1H50MA] = calculateCondition('60', ma50Length)
table.cell(tbl, 4, 2, condition1H50MA, bgcolor = color1H50MA, text_color = color.white, text_size = textSize)

[condition1H100MA, color1H100MA] = calculateCondition('60', ma100Length)
table.cell(tbl, 4, 3, condition1H100MA, bgcolor = color1H100MA, text_color = color.white, text_size = textSize)

[condition1H200MA, color1H200MA] = calculateCondition('60', ma200Length)
table.cell(tbl, 4, 4, condition1H200MA, bgcolor = color1H200MA, text_color = color.white, text_size = textSize)

// 4 Hours Timeframe for 20, 50, 100 and 200 MA
table.cell(tbl, 5, 0, '4 Hour', text_color = color.white, text_size = textSize)
[condition4H20MA, color4H20MA] = calculateCondition('240', ma20Length)
table.cell(tbl, 5, 1, condition4H20MA, bgcolor = color4H20MA, text_color = color.white, text_size = textSize)

[condition4H50MA, color4H50MA] = calculateCondition('240', ma50Length)
table.cell(tbl, 5, 2, condition4H50MA, bgcolor = color4H50MA, text_color = color.white, text_size = textSize)

[condition4H100MA, color4H100MA] = calculateCondition('240', ma100Length)
table.cell(tbl, 5, 3, condition4H100MA, bgcolor = color4H100MA, text_color = color.white, text_size = textSize)

[condition4H200MA, color4H200MA] = calculateCondition('240', ma200Length)
table.cell(tbl, 5, 4, condition4H200MA, bgcolor = color4H200MA, text_color = color.white, text_size = textSize)

// 1 Day Timeframe for 20, 50, 100 and 200 MA
table.cell(tbl, 6, 0, '1 Day', text_color = color.white, text_size = textSize)
[condition1D20MA, color1D20MA] = calculateCondition('D', ma20Length)
table.cell(tbl, 6, 1, condition1D20MA, bgcolor = color1D20MA, text_color = color.white, text_size = textSize)

[condition1D50MA, color1D50MA] = calculateCondition('D', ma50Length)
table.cell(tbl, 6, 2, condition1D50MA, bgcolor = color1D50MA, text_color = color.white, text_size = textSize)

[condition1D100MA, color1D100MA] = calculateCondition('D', ma100Length)
table.cell(tbl, 6, 3, condition1D100MA, bgcolor = color1D100MA, text_color = color.white, text_size = textSize)

[condition1D200MA, color1D200MA] = calculateCondition('D', ma200Length)
table.cell(tbl, 6, 4, condition1D200MA, bgcolor = color1D200MA, text_color = color.white, text_size = textSize)

// 1 Week Timeframe for 20, 50, 100 and 200 MA
table.cell(tbl, 7, 0, '1 Week', text_color = color.white, text_size = textSize)
[condition1W20MA, color1W20MA] = calculateCondition('W', ma20Length)
table.cell(tbl, 7, 1, condition1W20MA, bgcolor = color1W20MA, text_color = color.white, text_size = textSize)

[condition1W50MA, color1W50MA] = calculateCondition('W', ma50Length)
table.cell(tbl, 7, 2, condition1W50MA, bgcolor = color1W50MA, text_color = color.white, text_size = textSize)

[condition1W100MA, color1W100MA] = calculateCondition('W', ma100Length)
table.cell(tbl, 7, 3, condition1W100MA, bgcolor = color1W100MA, text_color = color.white, text_size = textSize)

[condition1W200MA, color1W200MA] = calculateCondition('W', ma200Length)
table.cell(tbl, 7, 4, condition1W200MA, bgcolor = color1W200MA, text_color = color.white, text_size = textSize)

// Plot the MAs for the current timeframe

//multi timeframe 20 & 50 MA
// Define inputs
src = close
len1 = input.int(20, title = 'MA Length 1')
len2 = input.int(50, title = 'MA Length 2')
len3 = input.int(100, title = 'MA Length 3')
dashedLineStyle = plot.style_circles

// Daily moving averages
ma20_week = request.security(syminfo.tickerid, 'W', ta.ema(src, len1))
ma50_week = request.security(syminfo.tickerid, 'W', ta.ema(src, len2))
ma100_week = request.security(syminfo.tickerid, 'W', ta.ema(src, len3))

// Intraday moving averages
ma20 = ta.ema(src, len1)
ma50 = ta.ema(src, len2)
ma100 = ta.ema(src, len3)
ma200 = ta.ema(close, 200)

// Plot MAs based on new boolean inputs
plot(showMA20 ? ma20 : na, color = color.rgb(94, 255, 0, 40), title = '20MA', linewidth = 2)
plot(showMA50 ? ma50 : na, color = #0065fc, title = '50MA', linewidth = 2)
plot(showMA100 ? ma100 : na, color = color.purple, title = '100MA', linewidth = 2)
plot(showMA200 ? ma200 : na, color = #ff0000, linewidth = 2, title = '200MA')

// Plot multi-timeframe MAs as dashed lines if enabled
// These plots are correctly calculated, but may appear to "move" visually when you scroll the chart due to the chart's price axis auto-scaling.
// To prevent this, you can right-click the price axis on the chart and select "Lock Price to Bar Ratio".
plot(showWeeklyMA20 ? ma20_week : na, color = color.red, style = dashedLineStyle, linewidth = 1, title = 'Daily 20MA')
plot(showWeeklyMA50 ? ma50_week : na, color = color.rgb(0, 101, 252, 43), style = dashedLineStyle, title = 'Daily 50MA')
plot(showWeeklyMA100 ? ma100_week : na, color = color.rgb(128, 0, 128, 50), style = dashedLineStyle, linewidth = 1, title = 'Daily 100MA')
````
