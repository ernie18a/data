# Daily High/Low (by JH-Trades)

- url: https://www.tradingview.com/script/vAqKl4js-Daily-High-Low-by-JH-Trades/
- type: indicator
- pine_id: PUB;fb518e149d4647a2a0e3a81e384e7e62
- version: 1.0

## Description

Shows the highs and lows of the day. 
making it easy to see trending or ranging market

## Source Code

````pine
//@version=6
indicator("Daily High/Low (by JH-Trades)", overlay=true)

// === INPUTS ===
active      = input.bool(true, "Show On Chart")

highColor   = input.color(color.gray, "High Line Color")
lowColor    = input.color(color.gray, "Low Line Color")

lineWidth   = input.int(2, "Line Width", minval=1, maxval=5)
styleInput  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

// === STYLE ===
lineStyle = line.style_solid
if styleInput == "Dashed"
    lineStyle := line.style_dashed
else if styleInput == "Dotted"
    lineStyle := line.style_dotted

// === DAILY HIGH/LOW ===
priceHigh = request.security(syminfo.tickerid, "D", high)
priceLow  = request.security(syminfo.tickerid, "D", low)

// === NIEUWE DAG ===
newDay = ta.change(time("D")) != 0

// === STORAGE ===
var line highLine = na
var line lowLine  = na
var int startBar  = na

// === NIEUWE DAG ===
if newDay
    if not na(highLine)
        line.set_x2(highLine, bar_index - 1)
    if not na(lowLine)
        line.set_x2(lowLine, bar_index - 1)

    if active
        startBar := bar_index
        highLine := line.new(startBar, priceHigh, startBar, priceHigh, color=highColor, width=lineWidth, style=lineStyle)
        lowLine  := line.new(startBar, priceLow,  startBar, priceLow,  color=lowColor,  width=lineWidth, style=lineStyle)

// === UPDATE ===
if active and not na(highLine)
    line.set_xy1(highLine, startBar, priceHigh)
    line.set_xy2(highLine, bar_index, priceHigh)

    line.set_xy1(lowLine, startBar, priceLow)
    line.set_xy2(lowLine, bar_index, priceLow)
````
