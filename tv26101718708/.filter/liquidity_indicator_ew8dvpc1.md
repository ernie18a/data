# Liquidity indicator

- url: https://www.tradingview.com/script/ew8DvPC1-Liquidity-indicator/
- type: indicator
- pine_id: PUB;98e8e13895f14abd80118957c6131381
- version: 1.0

## Description

Liquidity Indicator LR
Liquidity Indicator LR is a simple yet powerful liquidity measurement indicator designed for Indian equity markets. It calculates the average rupee-denominated trading volume (₹ Volume) over a user-defined period using a Simple Moving Average, and displays it directly on the price chart as a clean label.
What it shows:
The label displays the 20-day average liquidity of a stock in Crores (Cr), giving traders a quick snapshot of how much money is flowing into the stock on average.
How to use:
Higher the value, more liquid the stock — suitable for larger position sizes
Low liquidity stocks (e.g. below 5 Cr) carry higher impact cost and slippage risk
Use it to filter stocks before taking swing or positional trades
Settings:
Average Period — default 20 days (customizable)
Label Background Color — default blue

## Source Code

````pine
//@version=6
indicator("Liquid Rush 2.0", overlay=true, shorttitle="LR2")

// ── Inputs ──────────────────────────────────────────────────
avgPeriod = input.int(20, "Average Period", minval=1)
labelBgColor = input.color(color.blue, "Label Background Color")
labelTxtColor = input.color(color.white, "Text Color")
labelSize = input.string("normal", "Label Size", options=["tiny","small","normal","large","huge"])

// ── Calculations ─────────────────────────────────────────────
rupeeVol = close * volume
avgRupeeVol = ta.sma(rupeeVol, avgPeriod)

// ── Label ─────────────────────────────────────────────────────
lblSizeMap = labelSize == "tiny"  ? size.tiny  :
             labelSize == "small" ? size.small :
             labelSize == "large" ? size.large :
             labelSize == "huge"  ? size.huge  : size.normal

avgCr = avgRupeeVol / 1e7
labelText = str.tostring(math.round(avgCr, 2)) + " Cr"

if barstate.islast
    label.new(bar_index, high,
     text      = labelText,
     color     = labelBgColor,
     textcolor = labelTxtColor,
     style     = label.style_label_left,
     size      = lblSizeMap)
````
