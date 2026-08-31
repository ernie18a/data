<!-- tradingview-pine-id: PUB;df8e6b92496648f5a7d455a67f20a26f -->
<!-- tradingviewscripts-format: 1 -->
# ETH1! Futures Volume

Source: https://www.tradingview.com/script/KzGP1J3D-ETH1-Futures-Volume/

## Description

//@version=6
indicator("ETH1! Futures Volume", shorttitle="ETH1 Vol", overlay=false)

// Inputs
ethSymbol = input.symbol("CME:ETH1!", "ETH1! Futures Symbol")
maLength  = input.int(20, "Volume MA", minval=1)
highMult  = input.float(1.5, "High Volume Multiplier")
ultraMult = input.float(2.5, "Ultra Volume Multiplier")
lowMult   = input.float(0.5, "Low Volume Multiplier")

// Get ETH1! Futures Volume
ethVol = request.security(ethSymbol, timeframe.period, volume)

// Moving Average
volMA = ta.sma(ethVol, maLength)

// Conditions
isUltra = ethVol >= volMA * ultraMult
isHigh  = ethVol >= volMA * highMult and not isUltra
isLow   = ethVol <= volMA * lowMult

// Original TradingView volume colors
volColor = close >= open ? color.green : color.red

// Plots
plot(ethVol, title="ETH1! Volume", style=plot.style_columns, color=volColor)
plot(volMA, title="Volume MA", color=color.orange, linewidth=2)

plotshape(isUltra ? ethVol : na,
     title="Ultra High",
     style=shape.triangleup,
     location=location.absolute,
     color=color.orange,
     size=size.small)

plotshape(isHigh ? ethVol : na,
     title="High",
     style=shape.circle,
     location=location.absolute,
     color=color.yellow,
     size=size.tiny)

plotshape(isLow ? ethVol : na,
     title="Low",
     style=shape.triangledown,
     location=location.absolute,
     color=color.gray,
     size=size.tiny)

// Alerts
alertcondition(isUltra, title="Ultra High Volume", message="ETH1! Ultra High Volume")
alertcondition(isHigh, title="High Volume", message="ETH1! High Volume")
alertcondition(isLow, title="Low Volume", message="ETH1! Low Volume")

---

## Source Code

````pine
//@version=6
indicator("ETH1! Futures Volume", shorttitle="ETH1 Vol", overlay=false)

// Inputs
ethSymbol = input.symbol("CME:ETH1!", "ETH1! Futures Symbol")
maLength  = input.int(20, "Volume MA", minval=1)
highMult  = input.float(1.5, "High Volume Multiplier")
ultraMult = input.float(2.5, "Ultra Volume Multiplier")
lowMult   = input.float(0.5, "Low Volume Multiplier")

// Get ETH1! Futures Volume
ethVol = request.security(ethSymbol, timeframe.period, volume)

// Moving Average
volMA = ta.sma(ethVol, maLength)

// Conditions
isUltra = ethVol >= volMA * ultraMult
isHigh  = ethVol >= volMA * highMult and not isUltra
isLow   = ethVol <= volMA * lowMult

// Original TradingView volume colors
volColor = close >= open ? color.green : color.red

// Plots
plot(ethVol, title="ETH1! Volume", style=plot.style_columns, color=volColor)
plot(volMA, title="Volume MA", color=color.orange, linewidth=2)

plotshape(isUltra ? ethVol : na,
     title="Ultra High",
     style=shape.triangleup,
     location=location.absolute,
     color=color.orange,
     size=size.small)

plotshape(isHigh ? ethVol : na,
     title="High",
     style=shape.circle,
     location=location.absolute,
     color=color.yellow,
     size=size.tiny)

plotshape(isLow ? ethVol : na,
     title="Low",
     style=shape.triangledown,
     location=location.absolute,
     color=color.gray,
     size=size.tiny)

// Alerts
alertcondition(isUltra, title="Ultra High Volume", message="ETH1! Ultra High Volume")
alertcondition(isHigh, title="High Volume", message="ETH1! High Volume")
alertcondition(isLow, title="Low Volume", message="ETH1! Low Volume")
````
