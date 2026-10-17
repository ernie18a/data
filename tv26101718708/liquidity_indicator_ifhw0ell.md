# Liquidity Indicator 

- url: https://www.tradingview.com/script/IfHw0ell-Liquidity-Indicator/
- type: indicator
- pine_id: PUB;d78537da3e9e4f17926d239e6e2875a6
- version: 1.0

## Description

Liquidity Indicator 

Liquidity Indicator  is a simple yet powerful liquidity measurement tool designed specifically for Indian equity markets. It calculates the average rupee-denominated trading volume (₹ Volume) over a user-defined period using Simple Moving Average, and displays it directly on the price chart as a clean color-coded label.

What it shows:
The label displays the average liquidity of a stock in Crores (Cr), giving traders a quick snapshot of how much money is flowing into the stock on average.

Color Coding:
- 🔴 Red — Below 40 Cr (low liquidity, avoid or trade with caution)
- 🟡 Yellow — 40 to 100 Cr (moderate liquidity)
- 🟢 Green — Above 100 Cr (high liquidity, safe for larger positions)

Smart Averaging:
Works seamlessly on recently listed stocks too. If a stock has fewer candles than the set period, the indicator automatically adjusts and takes average of available candles only.

How to use:
- Use it to filter stocks before taking swing or positional trades
- Avoid entering low liquidity stocks (Red) to reduce slippage and impact cost
- Best used on Daily timeframe for accurate liquidity assessment

Settings:
- Average Period — default 20 days (customizable)
- Text Color — default white
- Label Size — tiny / small / normal / large / huge

## Source Code

````pine
//@version=6
indicator("Liquidity Indicator LR", overlay=true, shorttitle="Liquidity")

// ── Inputs ──────────────────────────────────────────────────
avgPeriod = input.int(20, "Average Period", minval=1)
labelTxtColor = input.color(color.white, "Text Color")
labelSize = input.string("normal", "Label Size", options=["tiny","small","normal","large","huge"])

// ── Calculations ─────────────────────────────────────────────
rupeeVol = close * volume
dynamicPeriod = math.min(avgPeriod, bar_index + 1)
avgRupeeVol = ta.sma(rupeeVol, dynamicPeriod)

// ── Color Logic ───────────────────────────────────────────────
avgCr = avgRupeeVol / 1e7
labelBgColor = avgCr < 40 ? color.red : avgCr < 100 ? color.yellow : color.green

// ── Label ─────────────────────────────────────────────────────
lblSizeMap = labelSize == "tiny"  ? size.tiny  :
             labelSize == "small" ? size.small :
             labelSize == "large" ? size.large :
             labelSize == "huge"  ? size.huge  : size.normal

labelText = str.tostring(math.round(avgCr, 2)) + " Cr"

if barstate.islast
    label.new(bar_index, high,
     text      = labelText,
     color     = labelBgColor,
     textcolor = labelTxtColor,
     style     = label.style_label_left,
     size      = lblSizeMap)
````
