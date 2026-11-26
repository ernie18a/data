# *Coinbase HYPE Premium*vF*

- url: https://www.tradingview.com/script/HhkKC6kl-Coinbase-HYPE-Premium-vF/
- type: indicator
- pine_id: PUB;3303766bdde349f3ac48ab8ecfa41cd1
- version: 1.0

## Description

Hyperliquid perp premium on coinbase vs binance (incl usdc/usdt adjustment)

## Source Code

````pine
//@version=6
indicator("*Coinbase HYPE Premium*vF*", overlay=false)

// -- Fetch spot prices --
Coinbase_unadj = request.security("COINBASE:HYPEUSDC.P",  timeframe.period, close)
usdcusdt = request.security("BINANCE:USDCUSDT",  timeframe.period, close)
Binance = request.security("BINANCE:HYPEUSDT.P",  timeframe.period, close)

// -- Convert Coinbase BTCUSD to USDT terms --
Coinbase = Coinbase_unadj * usdcusdt

// -- Calculate premium --
premium = Coinbase - Binance
premium_pct = (premium / Binance) * 100

premium2 = Coinbase_unadj - Binance
premium_pct2 = (premium2 / Binance) * 100

// -- Session highlight: US hours (08:00–20:00 ET) --
hours = hour(time, "Etc/UTC") - 4
activeInUS = (hours >= 8 and hours <= 16)
barColor = activeInUS ? (premium_pct2 < 0 ? color.new(color.red, 50) : color.new(color.lime, 50)) : (premium_pct2 < 0 ?  color.new(color.maroon, 75) : color.new(color.green, 75))
// -- Plot --


// User input for enabling/disabling ribbons
show_ribbons = input.bool(true, title="Show Ribbons")

// User input for moving average lengths
ma_length_short = input.int(21, title="Short MA Length", minval=1, maxval=100)
ma_length_long = input.int(42, title="Long MA Length", minval=1, maxval=100)

// Define the moving averages for the ribbon
ma_short = ta.sma(premium_pct2, ma_length_short)
ma_long = ta.sma(premium_pct2, ma_length_long)

// Plot the moving averages
plot_short = plot(show_ribbons ? ma_short : na, color=color.new(color.green, 100), linewidth=1, title="Short MA")
plot_long = plot(show_ribbons ? ma_long : na, color=color.new(color.red, 100), linewidth=1, title="Long MA")

// Fill the area between the two moving averages
fill(plot_short, plot_long, color=show_ribbons ? (ma_short > ma_long ? color.new(color.green, 30) : color.new(color.red, 30)) : na)
plot(premium_pct2, histbase = 0, color = barColor, style = plot.style_columns)
````
