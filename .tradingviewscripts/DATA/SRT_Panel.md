<!-- tradingview-pine-id: PUB;6034f27063fc4237ae64aef0901449a4 -->
<!-- tradingviewscripts-format: 1 -->
# SRT Panel

Source: https://www.tradingview.com/script/D2a8SFac-SRT-Panel/

## Description

SRT stands for Speculation Ratio Territory. It's a technique used in the stock market to broadly identify the top and bottom of an index or stock, which helps define the buying and selling "Territories".

Here's a short guide on how to use SRT:

Calculation: The SRT value is calculated by dividing the index value (like Nifty) by the 124-day Simple Moving Average (SMA) on a daily chart.
Range: The SRT value typically ranges between 0.6 (bottom) and 1.5 (top)2.

Investment Strategy:
Buying Zone: Ideal entry points are when the SRT value is between 0.6 and 0.8
Hold: Hold the position between 0.9 and 1.3
Selling Zone: It's recommended to start booking profits when the SRT value is above 1.3 and exit completely when it 1.5
This method helps investors make data backed decisions about when to enter, stay or exit the market, aiming for better returns and reduced risks.

---

## Source Code

````pine
//@version=6

// Thanks to Nitish Sir for teaching the concept of SRT for Investments
indicator('SRT Panel', overlay = true)

//====================================================
// INPUT GROUPS
//====================================================

var string GP1 = 'SRT Panel'
var string GP2 = 'Table Colors'

//====================================================
// TABLE POSITION
//====================================================

string tableYposInput = input.string('top', 'SRT Panel Position', inline = '11', options = ['top', 'middle', 'bottom'], group = GP1)

string tableXposInput = input.string('right', '', inline = '11', options = ['left', 'center', 'right'], group = GP1)

//====================================================
// COLUMN 0 COLORS
//====================================================

color col0BgColor = input.color(color.rgb(0, 212, 124), 'Column 0 Background', group = GP2)

color col0FontColor = input.color(color.white, 'Column 0 Font', group = GP2)

//====================================================
// COLUMN 1 COLORS
//====================================================

color col1BgColor = input.color(color.white, 'Column 1 Background', group = GP2)

color col1FontColor = input.color(color.black, 'Column 1 Font', group = GP2)

//====================================================
// TABLE
//====================================================

// IMPORTANT:
// Table background is fully transparent.
// This allows a cell with transparent background
// to reveal the actual chart underneath.
var srtTable = table.new(tableYposInput + '_' + tableXposInput, columns = 2, rows = 4, bgcolor = color.new(color.white, 100), border_width = 1, frame_color = color.gray, frame_width = 2, border_color = color.gray)

//====================================================
// SRT CALCULATIONS
//====================================================

vix = request.security('INDIAVIX', 'D', close)

sma = ta.sma(close, 124)

srt = close / sma

//====================================================
// COLUMN 0
//====================================================

table.cell(table_id = srtTable, column = 0, row = 0, text = 'Current Level', text_color = col0FontColor, bgcolor = col0BgColor)

table.cell(table_id = srtTable, column = 0, row = 1, text = 'SMA 124', text_color = col0FontColor, bgcolor = col0BgColor)

table.cell(table_id = srtTable, column = 0, row = 2, text = 'SRT Value', text_color = col0FontColor, bgcolor = col0BgColor)

table.cell(table_id = srtTable, column = 0, row = 3, text = 'India VIX', text_color = col0FontColor, bgcolor = col0BgColor)

//====================================================
// COLUMN 1
//====================================================

table.cell(table_id = srtTable, column = 1, row = 0, text = str.tostring(close), text_color = col1FontColor, bgcolor = col1BgColor)

table.cell(table_id = srtTable, column = 1, row = 1, text = str.tostring(sma, '#.##'), text_color = col1FontColor, bgcolor = col1BgColor)

table.cell(table_id = srtTable, column = 1, row = 2, text = str.tostring(srt, '#.##'), text_color = col1FontColor, bgcolor = col1BgColor)

table.cell(table_id = srtTable, column = 1, row = 3, text = str.tostring(vix, '#.##'), text_color = col1FontColor, bgcolor = col1BgColor)
````
