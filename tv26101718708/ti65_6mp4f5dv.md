# TI65

- url: https://www.tradingview.com/script/6mp4f5DV-TI65/
- type: indicator
- pine_id: PUB;87f94d205b8649bd8f85eb9c1fef261d
- version: 1.0

## Description

TI65 by stockbee 
it is value of 7 SMA / value of 65 MA
Higher the value, faster the stock moves

## Source Code

````pine
//@version=6
indicator("TI65", overlay=false)

// Calculate SMAs
sma7 = ta.sma(close, 7)
sma65 = ta.sma(close, 65)

// Ratio
ratio = sma7 / sma65

// Color logic
colorRatio = ratio > 1.05 ? color.green :
             ratio < 0.95 ? color.red :
             color.black

// Plot ratio line
plot(ratio, color=colorRatio, linewidth=2, title="SMA7 / SMA65")

// Reference lines
hline(1.05, "Upper Threshold", color=color.green)
hline(0.95, "Lower Threshold", color=color.red)
hline(1.00, "Baseline", color=color.gray)
````
