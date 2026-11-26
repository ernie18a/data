# Roy EMA Multi Time Frame

- url: https://www.tradingview.com/script/P1GCat9U/
- type: indicator
- pine_id: PUB;22479434d4d44dfd87135b1c5653f50a
- version: 1.0

## Description

Roy EMA Multi Timeframe is a simple multi-timeframe EMA trend dashboard.

This indicator displays bullish or bearish trend conditions across multiple timeframes based on price position relative to the selected EMA.

If price is above EMA, the trend is shown as BULLISH.
If price is below EMA, the trend is shown as BEARISH.

Users can customize the EMA length based on their own trading style, such as EMA 20, EMA 50, EMA 100, EMA 200 or any preferred value.

This tool is designed to help traders quickly identify trend alignment across multiple timeframes.
Best used together with support/resistance, market structure, candlestick confirmation and proper risk management.

## Source Code

````pine
//@version=5
indicator("Roy EMA 50 MTF Trend Box", overlay=true)

// ==========================
// INPUT SETTING
// ==========================
emaLength = input.int(50, "EMA Length", minval=1)

tf1 = input.timeframe("1", "Timeframe 1")
tf2 = input.timeframe("5", "Timeframe 2")
tf3 = input.timeframe("15", "Timeframe 3")
tf4 = input.timeframe("30", "Timeframe 4")
tf5 = input.timeframe("60", "Timeframe 5")
tf6 = input.timeframe("240", "Timeframe 6")
tf7 = input.timeframe("D", "Timeframe 7")
tf8 = input.timeframe("W", "Timeframe 8")

showEMA = input.bool(true, "Show EMA 50 Current TF")
tablePos = input.string("Top Right", "Table Position", 
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

bullColor = input.color(color.blue, "Bullish Color")
bearColor = input.color(color.red, "Bearish Color")
headerColor = input.color(color.orange, "Header Color")
textColor = input.color(color.white, "Text Color")

// ==========================
// EMA CURRENT CHART
// ==========================
ema50 = ta.ema(close, emaLength)
plot(showEMA ? ema50 : na, title="EMA 50", color=color.yellow, linewidth=2)

// ==========================
// FUNCTION TREND MTF
// ==========================
f_trend(_tf) =>
    mtfClose = request.security(syminfo.tickerid, _tf, close)
    mtfEma   = request.security(syminfo.tickerid, _tf, ta.ema(close, emaLength))
    isBull = mtfClose > mtfEma
    trendText = isBull ? "BULLISH" : "BEARISH"
    trendColor = isBull ? bullColor : bearColor
    [trendText, trendColor]

// ==========================
// GET TREND EACH TIMEFRAME
// ==========================
[t1, c1] = f_trend(tf1)
[t2, c2] = f_trend(tf2)
[t3, c3] = f_trend(tf3)
[t4, c4] = f_trend(tf4)
[t5, c5] = f_trend(tf5)
[t6, c6] = f_trend(tf6)
[t7, c7] = f_trend(tf7)
[t8, c8] = f_trend(tf8)

// ==========================
// TABLE POSITION
// ==========================
pos = tablePos == "Top Right" ? position.top_right :
      tablePos == "Top Left" ? position.top_left :
      tablePos == "Bottom Right" ? position.bottom_right :
      position.bottom_left

// ==========================
// CREATE TABLE
// ==========================
var table emaTable = table.new(pos, 2, 9, border_width=1, frame_color=color.black, border_color=color.black)

// ==========================
// FUNCTION ROW
// ==========================
f_row(_row, _tfName, _trend, _bgColor) =>
    table.cell(emaTable, 0, _row, _tfName, bgcolor=color.white, text_color=color.black, text_size=size.small)
    table.cell(emaTable, 1, _row, _trend, bgcolor=_bgColor, text_color=textColor, text_size=size.small)

// ==========================
// DRAW TABLE
// ==========================
if barstate.islast
    table.cell(emaTable, 0, 0, "TF", bgcolor=headerColor, text_color=color.black, text_size=size.small)
    table.cell(emaTable, 1, 0, "TREND", bgcolor=headerColor, text_color=color.black, text_size=size.small)

    f_row(1, "M1",  t1, c1)
    f_row(2, "M5",  t2, c2)
    f_row(3, "M15", t3, c3)
    f_row(4, "M30", t4, c4)
    f_row(5, "1H",  t5, c5)
    f_row(6, "4H",  t6, c6)
    f_row(7, "D",   t7, c7)
    f_row(8, "W",   t8, c8)
````
