# RSI Candlestick Trend Suite

- url: https://www.tradingview.com/script/tzijyina/
- type: indicator
- pine_id: PUB;ca181313da56494f824cc9ba648d123d
- version: 2.0

## Description

RSI Candlestick Trend Suite

This indicator presents the Relative Strength Index (RSI) as candlesticks instead of a traditional line, providing a different perspective on momentum behavior and trend development.

The script combines several RSI-based analytical tools into a single oscillator panel:

• RSI Candlestick Visualization

* Displays RSI values as candle structures.
* Highlights momentum expansion and contraction.
* Improves visibility of short-term RSI direction changes.

• Moving Average Overlay

* Supports SMA, EMA, WMA, VWMA, and SMMA (RMA).
* Can be used to identify RSI trend direction and momentum shifts.

• Bollinger Bands on RSI

* Optional Bollinger Bands calculated directly from RSI values.
* Adjustable standard deviation multiplier.
* Optional filled band visualization.

• RSI-Based Supertrend

* Applies a Supertrend calculation to RSI candle data rather than price.
* Helps identify momentum trend changes within the oscillator.
* Customizable ATR length and multiplier settings.

• Buy and Sell Markers

* Optional signals generated when the RSI Supertrend changes direction.

This indicator is designed to assist with momentum analysis, trend identification, and RSI-based market structure observation. It may be used alongside other forms of technical analysis and risk management techniques.

The script is intended for educational and analytical purposes only and should not be considered financial advice.

Short Description
RSI candlestick visualization with moving averages, optional Bollinger Bands, and an RSI-based Supertrend for momentum and trend analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano


//@version=6
indicator(title = 'RSI Candlestick Trend Suite', shorttitle = 'RCTS', timeframe = '', timeframe_gaps = true)

// ─── RSI CANDLE Ayarları ───────────────────────────────────────
candleLength = input.int(14, minval = 1, title = 'RSI Candle Length', group = 'RSI Candle')
candleSource = input.source(close, 'Candle Source', group = 'RSI Candle')

// ─── RSI MA Ayarları ──────────────────────────────────────────
showMA = input.bool(true, 'Show RSI MA', group = 'RSI MA')
maLength = input.int(9, minval = 1, title = 'MA Length', group = 'RSI MA')
maType = input.string('EMA', title = 'MA Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'SMMA (RMA)', 'Bollinger Bands'], group = 'RSI MA')
maColor = input.color(color.new(color.yellow, 0), 'MA Color', group = 'RSI MA')
maWidth = input.int(1, minval = 1, maxval = 5, title = 'MA Width', group = 'RSI MA')

// ─── BOLLINGER BANDS Ayarları ─────────────────────────────────
bbMult = input.float(2.0, minval = 0.1, step = 0.1, title = 'BB StdDev Multiplier', group = 'RSI MA')
bbFillShow = input.bool(true, 'Show BB Fill', group = 'RSI MA')
bbFillColor = input.color(color.new(color.yellow, 85), 'BB Fill Color', group = 'RSI MA')

// ─── SUPERTREND Ayarları ──────────────────────────────────────
showST = input.bool(true, 'Show Supertrend', group = 'Supertrend')
stLength = input.int(10, minval = 1, title = 'ATR Length', group = 'Supertrend')
stFactor = input.float(3.0, minval = 0.1, step = 0.1, title = 'Factor', group = 'Supertrend')
stBullColor = input.color(color.new(color.aqua, 0), 'Bull Color', group = 'Supertrend')
stBearColor = input.color(color.new(color.purple, 0), 'Bear Color', group = 'Supertrend')
showSignals = input.bool(true, 'Show Buy/Sell Signals', group = 'Supertrend')

// ─── RSI CANDLE Hesapla ───────────────────────────────────────
rsiClose = ta.rsi(candleSource, candleLength)
rsiOpen = ta.rsi(candleSource[1], candleLength)
rsiHigh = math.max(rsiClose, rsiOpen)
rsiLow = math.min(rsiClose, rsiOpen)

// ─── SUPERTREND ───────────────────────────────────────────────
rsiHL2 = (rsiHigh + rsiLow) / 2

rsiTR = math.max(rsiHigh - rsiLow, math.max(math.abs(rsiHigh - nz(rsiClose[1])), math.abs(rsiLow - nz(rsiClose[1]))))
rsiATR = ta.rma(rsiTR, stLength)

basicUpper = rsiHL2 + stFactor * rsiATR
basicLower = rsiHL2 - stFactor * rsiATR

var float finalUpper = na
var float finalLower = na
var int trend = 1

finalUpper := basicUpper < nz(finalUpper[1]) or nz(rsiClose[1]) > nz(finalUpper[1]) ? basicUpper : nz(finalUpper[1])
finalLower := basicLower > nz(finalLower[1]) or nz(rsiClose[1]) < nz(finalLower[1]) ? basicLower : nz(finalLower[1])

trend := nz(trend[1], 1)
trend := trend[1] == 1 and rsiClose < finalLower ? -1 : trend[1] == -1 and rsiClose > finalUpper ? 1 : nz(trend[1], 1)

stLine = trend == 1 ? finalLower : finalUpper

buySignal = trend == 1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] == 1

// ─── RSI MA / BB Hesapla ──────────────────────────────────────
ma(source, length, type) =>
    switch type
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'WMA' => ta.wma(source, length)
        'VWMA' => ta.vwma(source, length)
        'SMMA (RMA)' => ta.rma(source, length)
        'Bollinger Bands' => ta.sma(source, length)

rsiMA = ma(rsiClose, maLength, maType)

isBB = maType == 'Bollinger Bands'
bbUpper = isBB ? rsiMA + bbMult * ta.stdev(rsiClose, maLength) : na
bbLower = isBB ? rsiMA - bbMult * ta.stdev(rsiClose, maLength) : na

// ─── PLOT ─────────────────────────────────────────────────────
bullBodyColor = color.new(color.green, 20)
bearBodyColor = color.new(color.red, 20)

bullBorderColor = color.green
bearBorderColor = color.red

bodyColor = rsiClose >= rsiOpen ? bullBodyColor : bearBodyColor
borderColor = rsiClose >= rsiOpen ? bullBorderColor : bearBorderColor

plotcandle(rsiOpen, rsiHigh, rsiLow, rsiClose, title = 'RSI Candle', color = bodyColor, wickcolor = borderColor, bordercolor = borderColor)



plot(showST ? stLine : na, title = 'Supertrend', color = trend == 1 ? stBullColor : stBearColor, linewidth = 2, style = plot.style_stepline)

plotshape(showSignals and buySignal, title = 'Buy', text = 'B', style = shape.labelup, location = location.bottom, color = color.new(color.aqua, 0), textcolor = color.white, size = size.tiny)

plotshape(showSignals and sellSignal, title = 'Sell', text = 'S', style = shape.labeldown, location = location.bottom, color = color.new(color.purple, 0), textcolor = color.white, size = size.tiny)

// MA veya BB orta çizgisi
plot(showMA ? rsiMA : na, title = 'RSI MA / BB Mid', color = maColor, linewidth = math.max(1, maWidth))

// BB Bantları
bbUpperPlot = plot(showMA and isBB ? bbUpper : na, title = 'BB Upper', color = color.new(maColor, 40), linewidth = 1)
bbLowerPlot = plot(showMA and isBB ? bbLower : na, title = 'BB Lower', color = color.new(maColor, 40), linewidth = 1)
fill(bbUpperPlot, bbLowerPlot, color = showMA and isBB and bbFillShow ? bbFillColor : na, title = 'BB Fill')

// ─── Referans Çizgileri ───────────────────────────────────────
hline(70, 'Overbought', color = color.red, linestyle = hline.style_dashed)
hline(50, 'Middle', color = color.gray, linestyle = hline.style_dotted)
hline(30, 'Oversold', color = color.green, linestyle = hline.style_dashed)
````
