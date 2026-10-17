# EMA Ribbon + 5 SMA

- url: https://www.tradingview.com/script/xaSC7Gzq-EMA-Ribbon-5-SMA/
- type: indicator
- pine_id: PUB;645a2be786bb489a8defdfd50a93c859
- version: 1.0

## Description

one indicator that includes 5 sma and 10 to 200 emas

## Source Code

````pine
// © Daksh_Agrawal_2006

//@version=6
indicator(title="EMA Ribbon + 5 SMA", overlay=true)

// Your 5 SMA
fastest = ta.sma(close, 5)

// Your EMAs
shortest = ta.ema(close, 10)
shorter = ta.ema(close, 20)
short = ta.ema(close, 50)
longer = ta.ema(close, 100)
longest = ta.ema(close, 200)

// Plotting the lines
plot(fastest, color = color.white, linewidth = 2) // Thickened for visibility
plot(shortest, color = color.red)
plot(shorter, color = color.yellow)
plot(short, color = color.purple)
plot(longer, color = color.green)
plot(longest, color = color.blue)
````
