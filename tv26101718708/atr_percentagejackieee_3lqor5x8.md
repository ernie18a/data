# ATR Percentage[jackieee]

- url: https://www.tradingview.com/script/3lQor5X8-ATR-Percentage-jackieee/
- type: indicator
- pine_id: PUB;9f36d9c423394eefb6b37bd50a163c2e
- version: 1.0

## Description

Description

This indicator displays ATR as a percentage of price and adds Bollinger Bands around it to help visualize changes in market volatility. It can be used to identify relative volatility expansion, compression, and extreme conditions in a simple and clean way.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//@version=6
indicator('ATR Percentage[jackieee]')
useAtrAsPercent = input(true)
ATRPeriods = input.int(20, step = 5)
showBollingerBands = input(true)
BBPeriods = input.int(20, step = 10)
StdDev = input.float(2, step = 0.5)
atr = ta.atr(ATRPeriods)
atrPercent = atr / close * 100
[middle, top, bottom] = ta.bb(useAtrAsPercent ? atrPercent : atr, BBPeriods, StdDev)
plot(useAtrAsPercent ? atrPercent : atr, title = 'ATR/Percent', color = color.new(#962424, 0), linewidth = 2)

BBup = plot(showBollingerBands ? top : na, title = 'Top', color = color.new(#000000, 50), linewidth = 1, style = plot.style_linebr)
BBdown = plot(showBollingerBands ? bottom : na, title = 'Bottom', color = color.new(#000000, 50), linewidth = 1, style = plot.style_linebr)
BBmid = plot(showBollingerBands ? middle : na, title = 'Middle', color = color.new(#000000, 50), linewidth = 1, style = plot.style_linebr)
fill(BBup, BBmid, title = 'High Volatility Zone', color = color.new(#66ff52, 90))
fill(BBdown, BBmid, title = 'Low Volatility Zone', color = color.new(#313832, 90))
````
