# 4 Simple Moving Averages

- url: https://www.tradingview.com/script/vyd6ZZAx-4-Simple-Moving-Averages/
- type: indicator
- pine_id: PUB;cb26dfd496c240a8bc7df21e33fa0e0b
- version: 2.0

## Description

4 SMAs to indicate market regime.

4 Simple Moving Averages — Plots four SMAs (10, 20, 30, 40) on the chart to gauge trend direction and momentum across short to medium timeframes. The 10 (red) tracks immediate price action, while the 40 (black) reflects the broader trend. When the averages stack in order and fan apart, the trend is strong; when they tangle and cross, the market is ranging or shifting. All four lengths are adjustable in settings.

## Source Code

````pine
//@version=6
indicator("4 Simple Moving Averages", overlay=true)

// Inputs (lengths adjustable from settings)
len1 = input.int(10, "MA 1 Length")
len2 = input.int(20, "MA 2 Length")
len3 = input.int(30, "MA 3 Length")
len4 = input.int(40, "MA 4 Length")

// Simple moving averages
sma1 = ta.sma(close, len1)
sma2 = ta.sma(close, len2)
sma3 = ta.sma(close, len3)
sma4 = ta.sma(close, len4)

// Plots
plot(sma1, "SMA 10", color=color.red,     linewidth=1)
plot(sma2, "SMA 20", color=color.blue,    linewidth=1)
plot(sma3, "SMA 30", color=color.purple, linewidth=1)
plot(sma4, "SMA 40", color=color.black,   linewidth=1)
````
