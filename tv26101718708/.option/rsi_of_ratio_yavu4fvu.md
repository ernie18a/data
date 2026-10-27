# RSI of Ratio

- url: https://www.tradingview.com/script/yAVU4Fvu-RSI-of-Ratio/
- type: indicator
- pine_id: PUB;14c697f73bf94d4488b4cc594ae37d6c
- version: 1.0

## Description

What it does:
Calculates RSI on the ratio of current symbol vs a user-selected compare symbol 
(default: NSE:NIFTY). This shows whether the stock is strong or weak relative 
to the index.

How to use:
- RSI above 60 → stock outperforming the index (gray dark fill)
- RSI 50–60 → mildly outperforming
- RSI 40–50 → mildly underperforming  
- RSI below 40 → stock underperforming the index (gray dark fill)

Settings:
- RSI Length: default 30
- Compare Symbol: any TradingView symbol (Nifty, BTC, SPX, Gold etc)
- All levels adjustable: 70/60/50/40/30

## Source Code

````pine
//@version=5
indicator("RSI of Ratio", shorttitle="RSI Ratio", format=format.price, precision=2, overlay=false)

// Inputs
rsi_length   = input.int(30, title="RSI Length", minval=1)
compare_sym  = input.symbol("NSE:NIFTY", title="Compare Symbol")  // ← search any symbol

// Level inputs
level_ob  = input.int(60, title="Overbought",   minval=1, maxval=100)
level_os  = input.int(40, title="Oversold",     minval=1, maxval=100)
level_mid = input.int(50, title="Midline",      minval=1, maxval=100)
level_top = input.int(70, title="Top Level",    minval=1, maxval=100)
level_bot = input.int(30, title="Bottom Level", minval=1, maxval=100)

// Fetch compare symbol running price
compare_close = request.security(compare_sym, timeframe.period, close)

// Ratio and RSI
ratio     = close / compare_close
rsi_value = ta.rsi(ratio, rsi_length)

// RSI line
rsiline = plot(rsi_value, "RSI", color=#7E57C2, linewidth=2)

// Invisible anchor plots at 60 and 40 (used for fill only)
w = plot(level_ob, color=color.new(color.white, 100))
e = plot(level_os, color=color.new(color.white, 100))

// Solid hlines — 60 / 40
band_ob = hline(level_ob, "Overbought", color=#787B86, linestyle=hline.style_solid)
band_os = hline(level_os, "Oversold",   color=#787B86, linestyle=hline.style_solid)

// Dashed hlines — 70 / 50 / 30
hline(level_top, "Top",     color=#787B86,                linestyle=hline.style_dashed)
hline(level_mid, "Midline", color=color.new(#787B86, 50), linestyle=hline.style_dashed)
hline(level_bot, "Bottom",  color=#787B86,                linestyle=hline.style_dashed)

// Always-on purple fill between 40 and 60
fill(band_ob, band_os, color=color.rgb(126, 87, 194, 90), title="Middle Zone")

// Dark fill above 60 / below 40
col_above = rsi_value > level_ob ? color.new(color.black, 85) : color.new(color.white, 100)
col_below = rsi_value < level_os ? color.new(color.black, 85) : color.new(color.white, 100)

fill(rsiline, w, color=col_above)
fill(rsiline, e, color=col_below)
````
