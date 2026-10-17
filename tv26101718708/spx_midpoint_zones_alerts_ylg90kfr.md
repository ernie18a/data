# SPX Midpoint Zones + Alerts

- url: https://www.tradingview.com/script/yLg90kFR-SPX-Midpoint-Zones-Alerts/
- type: indicator
- pine_id: PUB;d315a65034fe4c4d83bc24c913a3d5ae
- version: 1.0

## Description

Updated Script label to ensure the script name and script match

## Source Code

````pine
//@version=6
indicator("SPX Midpoint Zones + Alerts", overlay=true, max_bars_back=300)

extendBars = 300
demandColor = color.green
supplyColor = color.red

// -- Demand Zones (5 pairs) --
d1_low  = input.float(7390, "D1 Low",  group="Demand Zones", inline="D1")
d1_high = input.float(7400, "D1 High", group="Demand Zones", inline="D1")
d2_low  = input.float(7350, "D2 Low",  group="Demand Zones", inline="D2")
d2_high = input.float(7360, "D2 High", group="Demand Zones", inline="D2")
d3_low  = input.float(7325, "D3 Low",  group="Demand Zones", inline="D3")
d3_high = input.float(7335, "D3 High", group="Demand Zones", inline="D3")
d4_low  = input.float(7290, "D4 Low",  group="Demand Zones", inline="D4")
d4_high = input.float(7300, "D4 High", group="Demand Zones", inline="D4")
d5_low  = input.float(7260, "D5 Low",  group="Demand Zones", inline="D5")
d5_high = input.float(7270, "D5 High", group="Demand Zones", inline="D5")

// -- Supply Zones (3 pairs) --
s1_low  = input.float(7415, "S1 Low",  group="Supply Zones", inline="S1")
s1_high = input.float(7425, "S1 High", group="Supply Zones", inline="S1")
s2_low  = input.float(7450, "S2 Low",  group="Supply Zones", inline="S2")
s2_high = input.float(7460, "S2 High", group="Supply Zones", inline="S2")
s3_low  = input.float(7490, "S3 Low",  group="Supply Zones", inline="S3")
s3_high = input.float(7500, "S3 High", group="Supply Zones", inline="S3")

// -- Zone Touch Detection --
demandTouch = ta.crossunder(close, d1_high) or ta.crossunder(close, d2_high) or ta.crossunder(close, d3_high) or ta.crossunder(close, d4_high) or ta.crossunder(close, d5_high)
supplyTouch = ta.crossover(close, s1_low) or ta.crossover(close, s2_low) or ta.crossover(close, s3_low)

alertcondition(demandTouch, title="Demand Zone Touch", message="Price entered a Demand Zone (crossed under zone high)")
alertcondition(supplyTouch, title="Supply Zone Touch", message="Price entered a Supply Zone (crossed over zone low)")

drawMidLine(lowPrice, highPrice, lineColor, zoneType) =>
    mid = (lowPrice + highPrice) / 2
    line.new(x1=bar_index, y1=mid, x2=bar_index + extendBars, y2=mid,
         color=lineColor, width=2, extend=extend.both)
    label.new(x=bar_index, y=mid,
         text=zoneType + " " + str.tostring(lowPrice) + "-" + str.tostring(highPrice),
         style=label.style_label_left, color=lineColor, textcolor=color.white, size=size.small)

if barstate.islast
    drawMidLine(d1_low, d1_high, demandColor, "DEMAND")
    drawMidLine(d2_low, d2_high, demandColor, "DEMAND")
    drawMidLine(d3_low, d3_high, demandColor, "DEMAND")
    drawMidLine(d4_low, d4_high, demandColor, "DEMAND")
    drawMidLine(d5_low, d5_high, demandColor, "DEMAND")
    drawMidLine(s1_low, s1_high, supplyColor, "SUPPLY")
    drawMidLine(s2_low, s2_high, supplyColor, "SUPPLY")
    drawMidLine(s3_low, s3_high, supplyColor, "SUPPLY")
````
