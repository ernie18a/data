<!-- tradingview-pine-id: PUB;a21c5d12c4c847b68f29e2e99aeba83a -->
<!-- tradingviewscripts-format: 1 -->
# BTC1! Futures Volume

Source: https://www.tradingview.com/script/MniwyvYG-BTC1-Futures-Volume/

## Description

//@version=6
indicator("BTC1! Futures Volume", shorttitle="BTC1 Vol", overlay=false)

// Inputs
btcSymbol = input.symbol("CME:BTC1!", "BTC1! Futures Symbol")
maLength  = input.int(20, "Volume MA", minval=1)
highMult  = input.float(1.5, "High Volume Multiplier")
ultraMult = input.float(2.5, "Ultra Volume Multiplier")
lowMult   = input.float(0.5, "Low Volume Multiplier")

// Get BTC1! Futures Volume
btcVol = request.security(btcSymbol, timeframe.period, volume)

// Moving Average
volMA = ta.sma(btcVol, maLength)

// Conditions
isUltra = btcVol >= volMA * ultraMult
isHigh  = btcVol >= volMA * highMult and not isUltra
isLow   = btcVol <= volMA * lowMult

// Original Volume Colors
volColor = close >= open ? color.green : color.red

// Plots
plot(btcVol, title="BTC1! Volume", style=plot.style_columns, color=volColor)
plot(volMA, title="Volume MA", color=color.orange, linewidth=2)

plotshape(isUltra ? btcVol : na,
     title="Ultra High",
     style=shape.triangleup,
     location=location.absolute,
     color=color.orange,
     size=size.small)

plotshape(isHigh ? btcVol : na,
     title="High",
     style=shape.circle,
     location=location.absolute,
     color=color.yellow,
     size=size.tiny)

plotshape(isLow ? btcVol : na,
     title="Low",
     style=shape.triangledown,
     location=location.absolute,
     color=color.gray,
     size=size.tiny)

// Alerts
alertcondition(isUltra, title="Ultra High Volume", message="BTC1! Ultra High Volume")
alertcondition(isHigh, title="High Volume", message="BTC1! High Volume")
alertcondition(isLow, title="Low Volume", message="BTC1! Low Volume")

---

## Source Code

````pine
//@version=6
indicator("BTC1! Futures Volume", shorttitle="BTC1 Vol", overlay=false)

// Inputs
btcSymbol = input.symbol("CME:BTC1!", "BTC1! Futures Symbol")
maLength  = input.int(20, "Volume MA", minval=1)
highMult  = input.float(1.5, "High Volume Multiplier")
ultraMult = input.float(2.5, "Ultra Volume Multiplier")
lowMult   = input.float(0.5, "Low Volume Multiplier")

// Get BTC1! Futures Volume
btcVol = request.security(btcSymbol, timeframe.period, volume)

// Moving Average
volMA = ta.sma(btcVol, maLength)

// Conditions
isUltra = btcVol >= volMA * ultraMult
isHigh  = btcVol >= volMA * highMult and not isUltra
isLow   = btcVol <= volMA * lowMult

// Original Volume Colors
volColor = close >= open ? color.green : color.red

// Plots
plot(btcVol, title="BTC1! Volume", style=plot.style_columns, color=volColor)
plot(volMA, title="Volume MA", color=color.orange, linewidth=2)

plotshape(isUltra ? btcVol : na,
     title="Ultra High",
     style=shape.triangleup,
     location=location.absolute,
     color=color.orange,
     size=size.small)

plotshape(isHigh ? btcVol : na,
     title="High",
     style=shape.circle,
     location=location.absolute,
     color=color.yellow,
     size=size.tiny)

plotshape(isLow ? btcVol : na,
     title="Low",
     style=shape.triangledown,
     location=location.absolute,
     color=color.gray,
     size=size.tiny)

// Alerts
alertcondition(isUltra, title="Ultra High Volume", message="BTC1! Ultra High Volume")
alertcondition(isHigh, title="High Volume", message="BTC1! High Volume")
alertcondition(isLow, title="Low Volume", message="BTC1! Low Volume")
````
