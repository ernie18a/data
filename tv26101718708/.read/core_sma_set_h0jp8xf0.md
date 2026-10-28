# Core SMA Set

- url: https://www.tradingview.com/script/H0jP8xF0-Core-SMA-Set/
- type: indicator
- pine_id: PUB;43cea1a0d5964281a5ae4782f0d8acc3
- version: 1.0

## Description

Description:
This indicator automatically plots the most important moving averages onto your chart in a single package. It locks in the exact daily and weekly lines, meaning you can see the larger market trends even when you are zoomed in on a shorter timeframe like a 5-minute or 1-hour chart.

What's Included:

10-Day Average: Blue line

20-Day Average: Yellow line

50-Day Average: Green line

120-Day Average: White dotted line

200-Day Average: Red line

200-Week Average: Thick white line

This setup saves indicator slots and eliminates the need to constantly switch timeframes to check major support and resistance levels. It provides a clear, color-coded view of short, medium, and long-term trends at a glance.

## Source Code

````pine
//@version=6
indicator(title="Custom SMAs", shorttitle="SMAs", overlay=true)

// Calculate SMAs inside the security function to guarantee exact Daily/Weekly values regardless of current chart timeframe
sma10_d  = request.security(syminfo.tickerid, "D", ta.sma(close, 10))
sma20_d  = request.security(syminfo.tickerid, "D", ta.sma(close, 20))
sma50_d  = request.security(syminfo.tickerid, "D", ta.sma(close, 50))
sma120_d = request.security(syminfo.tickerid, "D", ta.sma(close, 120))
sma200_d = request.security(syminfo.tickerid, "D", ta.sma(close, 200))

sma200_w = request.security(syminfo.tickerid, "W", ta.sma(close, 200))

// Plots using Pine Script v6 native linestyle for true dashed lines
plot(sma10_d,  title="10 Day SMA",  color=color.blue,   linewidth=1, linestyle=plot.linestyle_dashed)
plot(sma20_d,  title="20 Day SMA",  color=color.yellow, linewidth=1, linestyle=plot.linestyle_dashed)
plot(sma50_d,  title="50 Day SMA",  color=color.green,  linewidth=1, linestyle=plot.linestyle_dashed)
plot(sma200_d, title="200 Day SMA", color=color.red,    linewidth=1, linestyle=plot.linestyle_dashed)
plot(sma120_d, title="120 Day SMA", color=color.white,  linewidth=1, linestyle=plot.linestyle_dashed)

// Bold solid white line
plot(sma200_w, title="200 Week SMA", color=color.white, linewidth=2)
````
