# EMA + SMA Combo

- url: https://www.tradingview.com/script/s3zZRkTf-EMA-SMA-Combo/
- type: indicator
- pine_id: PUB;66766c7fd122480e8420d49de0435f54
- version: 1.0

## Description

EMA + SMA Combo is a clean multi-moving-average overlay for TradingView that combines key exponential and simple moving averages into one script. It includes EMA 9, 20, 50, 100, 200, and 300, along with SMA 5, 10, 20, 50, 100, 200, and 300. Each line can be turned on or off individually, making it easy to customize the chart for scalping, swing trading, or longer-term trend analysis.

This indicator is designed for traders who want a simple way to track short-, medium-, and long-term market structure without loading multiple separate studies. EMAs can help highlight faster price reaction and momentum, while SMAs provide a smoother view of broader trend direction and support/resistance zones.

Features:

* EMA 9, 20, 50, 100, 200, 300
* SMA 5, 10, 20, 50, 100, 200, 300
* Individual on/off toggles for every moving average
* Adjustable line widths for EMA and SMA groups
* Overlay format for direct use on the main price chart

## Source Code

````pine
//@version=6
indicator("EMA + SMA Combo", shorttitle="EMA/SMA Combo", overlay=true)

// ===== EMA TOGGLES =====
showEMA9   = input.bool(true,  "Show EMA 9",   group="EMAs")
showEMA20  = input.bool(true,  "Show EMA 20",  group="EMAs")
showEMA50  = input.bool(true,  "Show EMA 50",  group="EMAs")
showEMA100 = input.bool(true,  "Show EMA 100", group="EMAs")
showEMA200 = input.bool(true,  "Show EMA 200", group="EMAs")
showEMA300 = input.bool(true,  "Show EMA 300", group="EMAs")

// ===== SMA TOGGLES =====
showSMA5   = input.bool(true,  "Show SMA 5",   group="SMAs")
showSMA10  = input.bool(true,  "Show SMA 10",  group="SMAs")
showSMA20  = input.bool(true,  "Show SMA 20",  group="SMAs")
showSMA50  = input.bool(true,  "Show SMA 50",  group="SMAs")
showSMA100 = input.bool(true,  "Show SMA 100", group="SMAs")
showSMA200 = input.bool(true,  "Show SMA 200", group="SMAs")
showSMA300 = input.bool(true,  "Show SMA 300", group="SMAs")

// ===== LINE WIDTHS =====
emaWidth = input.int(2, "EMA Width", minval=1, maxval=5, group="Style")
smaWidth = input.int(2, "SMA Width", minval=1, maxval=5, group="Style")

// ===== EMA VALUES =====
ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)
ema300 = ta.ema(close, 300)

// ===== SMA VALUES =====
sma5   = ta.sma(close, 5)
sma10  = ta.sma(close, 10)
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)
sma300 = ta.sma(close, 300)

// ===== PLOTS: EMAs =====
plot(showEMA9   ? ema9   : na, title="EMA 9",   color=color.fuchsia, linewidth=emaWidth)
plot(showEMA20  ? ema20  : na, title="EMA 20",  color=color.red,     linewidth=emaWidth)
plot(showEMA50  ? ema50  : na, title="EMA 50",  color=color.orange,  linewidth=emaWidth)
plot(showEMA100 ? ema100 : na, title="EMA 100", color=color.aqua,    linewidth=emaWidth)
plot(showEMA200 ? ema200 : na, title="EMA 200", color=color.blue,    linewidth=emaWidth)
plot(showEMA300 ? ema300 : na, title="EMA 300", color=color.purple,  linewidth=emaWidth)

// ===== PLOTS: SMAs =====
plot(showSMA5   ? sma5   : na, title="SMA 5",   color=#FFFFFF, linewidth=smaWidth)
plot(showSMA10  ? sma10  : na, title="SMA 10",  color=#B388FF, linewidth=smaWidth)
plot(showSMA20  ? sma20  : na, title="SMA 20",  color=#00FFFF, linewidth=smaWidth)
plot(showSMA50  ? sma50  : na, title="SMA 50",  color=#00DB00, linewidth=smaWidth)
plot(showSMA100 ? sma100 : na, title="SMA 100", color=#FC8A10, linewidth=smaWidth)
plot(showSMA200 ? sma200 : na, title="SMA 200", color=#FEDA15, linewidth=smaWidth)
plot(showSMA300 ? sma300 : na, title="SMA 300", color=#FF66CC, linewidth=smaWidth)
````
