# Volume Split - Buy vs Sell

- url: https://www.tradingview.com/script/plKaSFkZ-Volume-Split-Buy-vs-Sell/
- type: indicator
- pine_id: PUB;2451c78d2f70466ba0d677ef47f81957
- version: 3.0

## Description

This indicator allows visibility of absorption through viewing as buy and sell side volume.  If each side is matched within a given percentage (you can select via a parameter), then the given volume bar will be highlighted.  Additionally there is an alert on the SMA if the price action crosses the SMA, this is simply something I have been working on in combination.

Constructive thoughts and ideas are welcome.

PSA - AI was utilized in the making of this indicator.

## Source Code

````pine
//@version=6
indicator('Volume Split · Buy vs Sell', 'VolSplit', format = format.volume, overlay = false, max_labels_count = 500)

// ═══════ Inputs ═══════
maLen = input.int(20, 'Volume MA Length')
showMA = input.bool(true, 'Show Volume MA')
smaFast = input.int(5, 'Fast SMA Length')
smaSlow = input.int(20, 'Slow SMA Length')
indecPct = input.float(10.0, 'Indecision Threshold (%)', minval = 0, maxval = 50, step = 0.5)
buyColor = input.color(color.new(color.lime, 0), 'Buy Color')
sellColor = input.color(color.new(color.red, 0), 'Sell Color')
maColor = input.color(color.new(color.white, 50), 'MA Color')
indecColor = input.color(color.new(color.yellow, 50), 'Indecision Highlight')

// ═══════ Calculation (Robust Proxy Method) ═══════
// We use a robust range check to prevent division by zero and handle flat candles.
candleRange = high - low
isFlat = candleRange == 0

// Proxy Logic: 
// If bar has range: buyRatio = (close - low) / range
// If bar is flat (H=L): buyRatio = 0.5 (50/50 split)
buyRatio = isFlat ? 0.5 : (close - low) / candleRange
buyVol   = volume * buyRatio
sellVol  = volume * (1 - buyRatio)

// Indecision Logic
volDiffPct = math.abs(buyVol - sellVol) / volume * 100
volSmaVal  = ta.sma(volume, maLen)
volAboveAvg = volume > volSmaVal
isIndecis = volDiffPct <= indecPct and volAboveAvg

// SMA crossover for the trend line
fastSmaVal = ta.sma(volume, smaFast)
slowSmaVal = ta.sma(volume, smaSlow)
bullish = fastSmaVal > slowSmaVal
smaLine = showMA ? slowSmaVal : na
smaClr = bullish ? color.new(color.lime, 0) : color.new(color.red, 0)

// ═══════ Plot ═══════
// 1. Scale Pivot: -1 forces the y-axis to provide a tiny buffer, 
// making the 0-line sit perfectly on the bottom of the pane.
plot(-1, 'Scale Pivot', display = display.none)

// 2. Stacked Bars using Fill (Invisible Line Technique)
zeroLine  = plot(0, 'Zero Baseline', display = display.none)
buyVolPlot = plot(buyVol, 'Buy Volume Line', display = display.none)
totalPlot  = plot(volume, 'Total Volume Line', display = display.none)

fill(buyVolPlot, zeroLine, color = buyColor, title = 'Buy Fill')
fill(totalPlot, buyVolPlot, color = sellColor, title = 'Sell Fill')

// 3. Volume SMA
plot(smaLine, 'Vol SMA', smaClr, linewidth = 2)

// ═══════ Indecision Highlights ═══════
// Baseline Highlight: Instead of bgColor(), we fill a small slice above 0
// to avoid the "bleeding" color below the 0-line.
indecBottom = plot(0, 'Indec High Bottom', display = display.none)
indecTop    = plot(isIndecis ? volume * 0.05 : 0, 'Indec High Top', display = display.none)
fill(indecTop, indecBottom, color = isIndecis ? indecColor : na, title = 'Indecision Base')

// Diamond Markers: Placed absolute at 0.5% above the volume bar.
plotshape(isIndecis ? volume * 1.005 : na, title = 'Indecision Marker', style = shape.diamond, location = location.absolute, color = color.yellow, size = size.tiny)

// ═══════ Alerts ═══════
alertcondition(isIndecis, title = 'Indecision Detected', message = 'Volume indecision: buy/sell delta within threshold on above-average volume')

// ═══════ Indecision Labels ═══════
if isIndecis
    diffStr = str.tostring(volDiffPct, '#.##') + '%'
    labelText = 'Buy: ' + str.tostring(buyVol, format.volume) + '\nSell: ' + str.tostring(sellVol, format.volume) + '\nΔ: ' + diffStr
    label.new(bar_index, volume, labelText, color = color.new(color.yellow, 60), textcolor = color.white, style = label.style_label_down, size = size.small)
````
