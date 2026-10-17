# ATR %

- url: https://www.tradingview.com/script/8TF4vlNc-ATR/
- type: indicator
- pine_id: PUB;ac00843ebfb247afb246543a0e0f2067
- version: 1.0

## Description

ATR % — Price Scale Label

Displays the Average True Range (ATR) as a percentage of the current price, shown as a static label in the top-right corner of the chart — always visible regardless of scrolling.

Features:

ATR expressed as % of price (ATR / Close × 100) for easy comparison across different assets and timeframes
Fixed position on screen — not tied to price level
Customizable ATR period (default: 14)
Customizable text and background colors
How to use:

Higher % = higher volatility — useful for position sizing and stop placement
Compare ATR % across different assets to normalize volatility
Works on any asset and any timeframe
Settings (Inputs tab):

ATR Length — period for ATR calculation
Text Color — label text color
Background Color — label background color

## Source Code

````pine
//@version=6
indicator("ATR %", overlay=true)
atrLength = input.int(14, "ATR Length", minval=1)
textColor = input.color(color.new(#00BCD4, 0), "Text Color")
bgColor   = input.color(color.new(color.black, 100), "Background Color")
atr    = ta.atr(atrLength)
atrPct = (atr / close) * 100
var table t = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(t, 0, 0,
         text="ATR (" + str.tostring(atrLength) + "): " + str.tostring(atrPct, "#.##") + "%",
         text_color=textColor,
         bgcolor=bgColor,
         text_size=size.normal)
````
