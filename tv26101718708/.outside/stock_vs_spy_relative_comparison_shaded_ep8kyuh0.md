# Stock vs SPY Relative Comparison Shaded

- url: https://www.tradingview.com/script/EP8kYuh0-Stock-vs-SPY-Relative-Comparison-Shaded/
- type: indicator
- pine_id: PUB;ae06e6c177724df9bfc40ff7634c8ef6
- version: 1.0

## Description

Stock vs SPY Relative Comparison Shaded

Gives you a visual in regard to how strong a stock is compared to [symbol="AMEX:SPY"]AMEX:SPY[/symbol]

## Source Code

````pine
//@version=6
indicator("Stock vs SPY Relative Comparison Shaded", shorttitle="RS vs SPY Shade", overlay=false)

// Inputs
benchmarkSymbol   = input.symbol("AMEX:SPY", "Benchmark Symbol")
lookback          = input.int(50, "Rebase Lookback", minval=2)

stockStrongColor  = input.color(color.lime, "Stock Color Above SPY")
stockWeakColor    = input.color(color.red, "Stock Color Below SPY")
spyColor          = input.color(color.white, "SPY Line Color")
baseColor         = input.color(color.gray, "Base 100 Line Color")

bullShadeColor    = input.color(color.new(color.green, 82), "Bullish Shade Color")
bearShadeColor    = input.color(color.new(color.red, 82), "Bearish Shade Color")

stockLineWidth    = input.int(2, "Stock Line Width", minval=1, maxval=5)
spyLineWidth      = input.int(2, "SPY Line Width", minval=1, maxval=5)
showBaseLine      = input.bool(true, "Show 100 Baseline")

// Data
spyClose = request.security(benchmarkSymbol, timeframe.period, close)

// Rebase both series to 100 from the lookback anchor
stockBase = close[lookback - 1]
spyBase   = spyClose[lookback - 1]

stockRebased = not na(stockBase) and stockBase != 0 ? 100 * (close / stockBase) : na
spyRebased   = not na(spyBase) and spyBase != 0 ? 100 * (spyClose / spyBase) : na

// Stock line color
stockColor = stockRebased >= spyRebased ? stockStrongColor : stockWeakColor

// Plot lines
pStock = plot(stockRebased, title="Stock Rebased", color=stockColor, linewidth=stockLineWidth)
pSpy   = plot(spyRebased, title="SPY Rebased", color=spyColor, linewidth=spyLineWidth)

// Optional baseline
hline(showBaseLine ? 100 : na, "Base 100", color=baseColor, linestyle=hline.style_dotted)

// Shading between lines
fill(pStock, pSpy, color = stockRebased >= spyRebased ? bullShadeColor : bearShadeColor, title="Relative Strength Fill")
````
