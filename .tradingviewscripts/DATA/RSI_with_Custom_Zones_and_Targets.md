<!-- tradingview-pine-id: PUB;6a95e27b77144a85a4b1e6661f31be5b -->
<!-- tradingviewscripts-format: 1 -->
# RSI with Custom Zones and Targets

Source: https://www.tradingview.com/script/C8n12Ttx-RSI-with-Custom-Zones-and-Targets/

## Description

levels with support and resistance according to rsi it will be accurate if used with combination of different indicators to determine movement in the direction of rsi

---

## Source Code

````pine
//@version=6
indicator('RSI with Custom Zones and Targets', overlay = false)

// Inputs
rsiLen = input.int(14, title = 'RSI Length')
maLen = input.int(14, title = 'MA Length on RSI')
maType = input.string('EMA', title = 'MA Type', options = ['SMA', 'EMA'])

// Levels
sellHigh = input.float(81.0, title = 'Sell Zone High')
sellLow = input.float(72.0, title = 'Sell Zone Low')
targHigh = input.float(55.0, title = 'Target High / Mid')
targLow = input.float(45.0, title = 'Target Low / Mid')
buyHigh = input.float(27.0, title = 'Buy Zone High')
buyLow = input.float(18.0, title = 'Buy Zone Low')

// Calculations
rsiVal = ta.rsi(close, rsiLen)
maVal = maType == 'SMA' ? ta.sma(rsiVal, maLen) : ta.ema(rsiVal, maLen)

// Plot RSI and MA
pRsi = plot(rsiVal, title = 'RSI', color = color.blue, linewidth = 2)
pMa = plot(maVal, title = 'RSI Base MA', color = color.orange, linewidth = 2)

// Horizontal Reference Levels
h81 = hline(81, 'Sell High', color = color.red, linestyle = hline.style_dashed)
h72 = hline(72, 'Sell Low', color = color.red, linestyle = hline.style_dotted)
h55 = hline(55, 'Target High', color = color.gray)
h45 = hline(45, 'Target Low', color = color.gray)
h27 = hline(27, 'Buy High', color = color.green, linestyle = hline.style_dotted)
h18 = hline(18, 'Buy Low', color = color.green, linestyle = hline.style_dashed)

// Background Fills for Zones
fill(h81, h72, color = color.new(color.red, 85), title = 'Sell Zone Fill')
fill(h27, h18, color = color.new(color.green, 85), title = 'Buy Zone Fill')

// Alerts
buyZoneAlert = rsiVal <= buyHigh
sellZoneAlert = rsiVal >= sellLow

alertcondition(buyZoneAlert, title = 'In Buy Zone', message = 'RSI is inside the Buy Zone!')
alertcondition(sellZoneAlert, title = 'In Sell Zone', message = 'RSI is inside the Sell Zone!')
````
