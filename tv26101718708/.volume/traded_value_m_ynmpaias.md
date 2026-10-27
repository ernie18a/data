# Traded Value ($ M)

- url: https://www.tradingview.com/script/yNMpaiAS-Traded-Value-M/
- type: indicator
- pine_id: PUB;841b04392bb842e786a7f799b315a0ab
- version: 1.0

## Description

This indicator calculates and displays the total traded value for each bar in US Dollars (Millions), giving you a clearer picture of real money flow compared to raw volume alone.

How it works:
It multiplies the closing price by the bar's volume, then divides by 1,000,000 to express the result in Millions of USD.

Traded Value ($M) = (Close Price × Volume) / 1,000,000

Color coding:

🟢 Green bar — Price closed higher than it opened (bullish bar)
🔴 Red bar — Price closed lower than it opened (bearish bar)

Why use this?
Raw volume only tells you how many shares/contracts were traded. Traded Value tells you how much money actually changed hands — making it especially useful for comparing activity across stocks with very different price levels.
Best used on: Stocks, ETFs, and instruments traded in USD.

## Source Code

````pine
//@version=6
indicator("Traded Value ($ M)", overlay=false)

// Get data
price = close
vol = volume

// Calculate traded value in millions USD
tradedValueM = (price * vol) / 1e6

// Green if price up, red if down
barColor = close >= open ? color.green : color.red

// Plot as multicolour bar chart
plot(tradedValueM, style=plot.style_columns, color=barColor, linewidth=2, title="Traded Value ($ M)")
````
