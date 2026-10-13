<!-- tradingview-pine-id: PUB;7795addc19f8402da283cef87aa29899 -->
<!-- tradingviewscripts-format: 1 -->
# Horizontal Price Grid (Claudia - Tradeify)

Source: https://www.tradingview.com/script/5lojowgl-Horizontal-Price-Grid-Claudia-Tradeify/

## Description

Plots horizontal line every N dollars.

Allows to change color, line type and the tick.

---

## Source Code

````pine
//@version=6
indicator("Horizontal Price Grid (Claudia - Tradeify)", overlay = true, max_lines_count = 500)

float stepSize = input.float(25.0, title="Grid Step ($)")
color lineColor = input.color(color.new(color.gray, 50), title="Line Color")
string lineStyleStr = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"])
int lineWidth = input.int(1, title="Line Width", minval=1)

if barstate.islast
    float currentClose = close
    float lowerBound = math.floor(currentClose / stepSize) * stepSize - (stepSize * 50)
    float upperBound = math.floor(currentClose / stepSize) * stepSize + (stepSize * 50)

    for price = lowerBound to upperBound by stepSize
        string style = lineStyleStr == "Solid" ? line.style_solid : lineStyleStr == "Dotted" ? line.style_dotted : line.style_dashed
        line.new(x1 = bar_index - 300, y1 = price, x2 = bar_index + 50, y2 = price, xloc = xloc.bar_index, extend = extend.none, color = lineColor, style = style, width = lineWidth, force_overlay = true)
````
