# Stock Comparison - Line Chart

- url: https://www.tradingview.com/script/MDPr2IZV-Stock-Comparison-Line-Chart/
- type: indicator
- pine_id: PUB;f10ac0352a7149f58fd01a4c9636c89c
- version: 1.0

## Description

Stock comparison. It gives you the over view on how one stock price behaves and related to another stock price.

## Source Code

````pine
//@version=6
indicator("Stock Comparison - Line Chart", shorttitle="StockCompare", overlay=false)

// ============================================================
// INPUTS
// ============================================================
symbol1     = input.symbol("AAPL", title="Stock 1 Symbol")
symbol2     = input.symbol("MSFT", title="Stock 2 Symbol")

compareMode = input.string("Price Spread (Value)", title="Comparison Mode",
                 options=["Percentage Change", "Raw Price", "Price Spread (Value)"])

spreadColor = input.color(color.new(#26A69A, 0), title="Spread Color")

color1      = input.color(color.new(#2962FF, 0), title="Stock 1 Color")
color2      = input.color(color.new(#FF6D00, 0), title="Stock 2 Color")

lineWidth   = input.int(2, title="Line Width", minval=1, maxval=4)
showTable   = input.bool(true, title="Show Legend Table")

// ============================================================
// DATA
// ============================================================
price1 = request.security(symbol1, timeframe.period, close)
price2 = request.security(symbol2, timeframe.period, close)

// Capture the first available price on the chart as the base for % comparison
var float base1 = na
var float base2 = na

if barstate.isfirst
    base1 := price1
    base2 := price2

pct1 = (price1 - base1) / base1 * 100
pct2 = (price2 - base2) / base2 * 100

// Exact value spread between the two stocks
spread = price1 - price2

isSpreadMode = compareMode == "Price Spread (Value)"

// Choose which series to plot based on selected mode
plotValue1 = compareMode == "Percentage Change" ? pct1 : price1
plotValue2 = compareMode == "Percentage Change" ? pct2 : price2

// ============================================================
// PLOTS
// ============================================================
plot(isSpreadMode ? na : plotValue1, title="Stock 1", color=color1, linewidth=lineWidth)
plot(isSpreadMode ? na : plotValue2, title="Stock 2", color=color2, linewidth=lineWidth)
plot(isSpreadMode ? spread : na, title="Spread (Stock1 - Stock2)", color=spreadColor, linewidth=lineWidth, style=plot.style_line)

hline((compareMode == "Percentage Change" or isSpreadMode) ? 0 : na, title="Zero Line",
     color=color.gray, linestyle=hline.style_dotted)

// ============================================================
// LEGEND TABLE
// ============================================================
if showTable
    var table legend = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 70), border_width=1)
    if barstate.islast
        table.cell(legend, 0, 0, "Symbol", text_color=color.white, bgcolor=color.new(color.black, 50))
        table.cell(legend, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 50))

        table.cell(legend, 0, 1, str.tostring(symbol1), text_color=color1)
        table.cell(legend, 1, 1, str.tostring(price1, format.mintick), text_color=color1)

        table.cell(legend, 0, 2, str.tostring(symbol2), text_color=color2)
        table.cell(legend, 1, 2, str.tostring(price2, format.mintick), text_color=color2)

        table.cell(legend, 0, 3, "Spread", text_color=spreadColor)
        table.cell(legend, 1, 3, str.tostring(spread, format.mintick), text_color=spreadColor)
````
