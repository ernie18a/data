# ADX & RSI - 5m BTC Optimized

- url: https://www.tradingview.com/script/6kIpRWk2-ADX-RSI-5m-BTC-Optimized/
- type: indicator
- pine_id: PUB;6208b68f717942ca90e9bf60a1f0df4a
- version: 1.0

## Description

ADX & RSI - Advanced Dashboard for 5m BTC Perpetual

A clean and highly customizable dashboard that combines the most important trend and momentum tools for fast decision-making on 5-minute BTC charts.

Key Features:
• Real-time ADX strength with color coding
• +DI and -DI values with live distance display
• Smart DI Distance system with Strong Bullish, Moderate Bullish, Range, Moderate Bearish, and Strong Bearish states
• EMA 60 vs EMA 200 trend detection with automatic Range recognition
• Fully customizable periods and thresholds
• Movable professional table (9 different positions)

Perfect for scalping and intraday trading on Bitcoin Perpetual. The dashboard helps you quickly identify strong trending conditions versus ranging markets, allowing faster and cleaner entries.

Especially optimized for 5-minute timeframe on BTC.

Settings include:
- ADX & DI Length
- RSI Length
- EMA Fast/Slow Lengths
- EMA Range Threshold
- DI Distance Range Threshold (key for 5m BTC)

Take your 5-minute BTC trading to the next level with this clean, informative, and professional dashboard.
Emin Hasimi

## Source Code

````pine
//@version=5
indicator("ADX & RSI - 5m BTC Optimized", overlay = true, max_bars_back=500)

// ── Inputs ──
adxLength     = input.int(14,   "ADX & DI Length",          minval=1,  maxval=100)
rsiLength     = input.int(14,   "RSI Length",               minval=1,  maxval=100)

showEMATrend  = input.bool(true, "Show EMA Trend", inline="ema")
ema60Length   = input.int(60,   "EMA Fast",  minval=1, maxval=200, inline="ema")
ema200Length  = input.int(200,  "EMA Slow", minval=1, maxval=500, inline="ema")
rangeThresholdEMA = input.float(0.25, "EMA Range Threshold (%)", minval=0.05, maxval=2.0, step=0.05, inline="ema", tooltip="For 5m BTC")

diRangeThreshold = input.float(6.0, "DI Distance Range Threshold", minval=2.0, maxval=20.0, step=0.5, tooltip="برای ۵ دقیقه BTC: ۵ تا ۷ مناسب است")

tablePosition = input.string("top_right", "Table Position", options = ["top_left", "top_right", "bottom_left", "bottom_right", "middle_left", "middle_right", "middle_center", "top_center", "bottom_center"], tooltip = "Select the position of the table")

// ── Calculations ──
[diplus, diminus, adx] = ta.dmi(adxLength, adxLength)
rsi = ta.rsi(close, rsiLength)
ema60  = ta.ema(close, ema60Length)
ema200 = ta.ema(close, ema200Length)

diDistance = diplus - diminus

// ── EMA Trend Logic ──
price = close
diffPercent = math.abs(ema60 - ema200) / price * 100

emaTrendColor = color.gray
emaTrendText  = "Range"

if diffPercent > rangeThresholdEMA
    emaTrendColor := ema60 > ema200 ? color.green : color.red
    emaTrendText  := ema60 > ema200 ? "Uptrend" : "Downtrend"

// ── DI Distance Logic ──
diColor = color.gray
diText  = "Range"

if math.abs(diDistance) > diRangeThreshold
    diColor := diDistance > 0 ? color.lime : color.red
    diText  := diDistance > 0 ? "Strong Bullish" : "Strong Bearish"
else if math.abs(diDistance) > diRangeThreshold * 0.6
    diColor := diDistance > 0 ? color.yellow : color.orange
    diText  := diDistance > 0 ? "Moderate Bullish" : "Moderate Bearish"

// ── Table ──
var table info = table.new(position = tablePosition, columns = 2, rows = showEMATrend ? 6 : 5, 
     bgcolor = color.new(color.black, 85), border_width = 1, border_color = color.gray)

// ── Filling Table ──
table.cell(info, 0, 0, "ADX",       text_color = color.white, bgcolor = color.new(color.gray, 70))
table.cell(info, 1, 0, str.tostring(adx, "#.##"), text_color = adx >= 25 ? color.green : color.red)

table.cell(info, 0, 1, "+DI",       text_color = color.white, bgcolor = color.new(color.gray, 70))
table.cell(info, 1, 1, str.tostring(diplus, "#.##"), text_color = color.lime)

table.cell(info, 0, 2, "-DI",       text_color = color.white, bgcolor = color.new(color.gray, 70))
table.cell(info, 1, 2, str.tostring(diminus, "#.##"), text_color = color.red)

table.cell(info, 0, 3, "DISTANCE",  text_color = color.white, bgcolor = color.new(color.gray, 70))
table.cell(info, 1, 3, str.tostring(diDistance, "#.##") + " (" + diText + ")", text_color = diColor)

table.cell(info, 0, 4, "RSI",       text_color = color.white, bgcolor = color.new(color.gray, 70))
table.cell(info, 1, 4, str.tostring(rsi, "#.##"), text_color = rsi >= 50 ? color.green : color.red)

// EMA Trend Row
if showEMATrend
    table.cell(info, 0, 5, "EMA Trend", text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(info, 1, 5, emaTrendText, text_color = emaTrendColor)
````
