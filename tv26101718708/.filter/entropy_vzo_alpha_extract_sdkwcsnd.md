# Entropy VZO [Alpha Extract]

- url: https://www.tradingview.com/script/SdKwcsNd-Entropy-VZO-Alpha-Extract/
- type: indicator
- pine_id: PUB;69fe94a2f9584899aecc6ed30130e404
- version: 1.0

## Description

A sophisticated volume-flow and market-information oscillator that combines pressure-weighted volume, statistical normalization, directional entropy, fractal efficiency, Gaussian smoothing, and signal-line analysis into one complete momentum framework. Entropy VZO is designed to measure whether bullish or bearish price movement is supported by meaningful volume while adapting its sensitivity to the quality and organization of current market structure.

Unlike a conventional oscillator displayed in a separate pane, Entropy VZO projects its momentum structure directly onto price using an ATR-scaled anchor. This provides a clear overlay of volume momentum, signal direction, histogram expansion, threshold zones, and dynamic pulse activity without separating the analysis from the underlying chart.

🔶 Pressure-Weighted Volume Flow Engine

Calculates directional volume using a blend of candle pressure and source-price direction. Candle pressure measures the relationship between the candle body and its full range, while source direction determines whether price is advancing or declining.

[pine]candlePressure = (close - open) / priceRange
closePressure = ta.change(src) > 0 ? 1.0 : ta.change(src) < 0 ? -1.0 : 0.0
signedPressure = clamp(candlePressure * 0.65 + closePressure * 0.35, -1.0, 1.0)

signedVolume = volume * signedPressure
volumeBase = math.max(ta.ema(volume, vzoLength), 1.0)
vzo = 100.0 * ta.ema(signedVolume, vzoLength) / volumeBase[/pine]

This produces a more detailed estimate of bullish and bearish participation than assigning all volume according to candle direction alone.

🔶 Normalized VZO Framework

Standardizes the raw VZO against its recent average and standard deviation. This allows the indicator to evaluate current volume pressure relative to the instrument’s own recent behaviour.

Positive readings indicate stronger-than-normal bullish volume flow, while negative readings represent stronger bearish pressure. Larger absolute readings show that the current volume imbalance is becoming increasingly unusual relative to its recent history.

🔶 Directional Entropy Analysis

Measures how evenly upward and downward price changes are distributed across the selected lookback period.

Low entropy indicates that price direction is more ordered and consistent. High entropy indicates a less predictable environment where upward and downward movements are more evenly balanced.

This allows the indicator to give greater weight to volume signals occurring during organized directional movement and reduce their influence during noisy or indecisive conditions.

🔶 Fractal Efficiency Framework

Evaluates how efficiently price has travelled between the beginning and end of the selected lookback relative to the total path taken.
High efficiency indicates that price is moving directly with limited back-and-forth movement. Low efficiency indicates a more irregular path with greater noise and weaker directional structure.

🔶 Information-Weighted Momentum Engine

Combines directional entropy and fractal efficiency into a unified information-quality weight. This weight adjusts the normalized VZO according to how organized and efficient the current market environment is.

[pine]informationWeight = clamp((1.0 - entropy) * 0.55 + efficiency * 0.45, 0.05, 1.0)

spectralInput = vzoZ * sensitivity * (0.65 + informationWeight)
fisherCore = tanhSafe(spectralInput) * maxLevel
[/pine]
Volume pressure receives greater emphasis when price movement is both directional and efficient. Signals are moderated when market structure becomes noisy, balanced, or fragmented.

🔶 Bounded Nonlinear Transformation

Applies a protected nonlinear transformation to compress extreme readings into a stable visual range.

This prevents isolated volume spikes from overwhelming the indicator while preserving momentum direction and relative strength. The result is a bounded oscillator centered around zero.

🔶 Gaussian Signal Polishing

Uses custom Gaussian-weighted smoothing to reduce short-term noise while preserving recent momentum information.

Separate smoothing stages are applied to the main oscillator and histogram. Traders can adjust these settings to make the indicator more responsive or more selective depending on their market and timeframe.

🔶 Bullish, Bearish & Neutral Regimes

Classifies the market into three momentum conditions:

• Bullish when the oscillator is above its signal and above zero
• Bearish when the oscillator is below its signal and below zero
• Neutral when momentum direction and zero-line position are not fully aligned  

This dual-confirmation structure helps distinguish established directional momentum from weaker signal-line movements.

🔶 ATR-Scaled Price Projection

Projects the oscillator directly onto the price chart using an EMA-based anchor and an ATR-adjusted visual range.

The projection automatically adapts to current volatility, allowing the indicator to maintain a consistent appearance across different assets, prices, and timeframes. The Visual Height setting controls how widely the oscillator is displayed around its price anchor.

🔶 Soft & Hard Momentum Zones

Displays configurable soft and hard momentum thresholds above and below the central price anchor.

Soft levels highlight developing momentum extremes, while hard levels identify stronger volume-flow displacement. These areas provide context for momentum intensity rather than acting as automatic reversal signals.

🔶 Dynamic Pulse Band
Displays a smoothed measure of absolute oscillator strength around the price anchor.
The pulse band expands as momentum intensity increases and contracts when momentum weakens. Its color follows the active regime, creating a visual representation of both directional bias and momentum amplitude.

🔶 Momentum Histogram

Measures the difference between the main oscillator and its signal line to show whether momentum is expanding or contracting.

Bright bullish readings indicate strengthening positive momentum, while faded bullish readings indicate that positive momentum is slowing. Bright bearish readings represent strengthening negative momentum, while faded bearish readings show bearish pressure losing force.

🔶 Signal Ribbon & Glow Architecture

Plots the main Entropy VZO line with a layered glow and an optional ribbon between the oscillator and signal line.

The ribbon changes color according to the active bullish, bearish, or neutral regime. This makes momentum alignment, crossovers, and transition periods easier to identify while maintaining chart readability.

🔶 Dynamic Candle Coloring

Optionally colors OHLC candles according to the current oscillator regime.
Bullish coloring appears when the oscillator is above both its signal and zero. Bearish coloring appears when it is below both references. Neutral coloring identifies mixed, transitional, or weakly confirmed conditions.

🔶 Real-Time Status Dashboard

Features a compact dashboard displaying the indicator’s most important information:

• Current bullish, bearish, or neutral regime
• Main oscillator value
• Normalized VZO Z-score
• Directional entropy percentage
• Fractal efficiency percentage
• Current volume relative to its EMA baseline  
This provides an immediate overview of momentum direction, volume abnormality, market organization, directional efficiency, and participation strength.

🔶 Comprehensive Alert System

Includes alerts for the indicator’s primary momentum events:
• Entropy VZO Bull Swing
• Entropy VZO Bear Swing
• Entropy VZO Bull Trend
• Entropy VZO Bear Trend  
Swing alerts trigger when the oscillator crosses its signal line. Trend alerts trigger when the oscillator crosses the zero level, allowing traders to monitor both early momentum shifts and broader directional transitions.

🔶 Why Choose Entropy VZO [Alpha Extract]?

Entropy VZO expands traditional volume-flow analysis by combining pressure-weighted volume, statistical normalization, directional entropy, and fractal efficiency within one adaptive momentum framework. Instead of treating every increase in volume equally, the system evaluates whether that participation is occurring inside an organized and efficient market environment.

The oscillator and signal line identify direction, the histogram measures momentum expansion, the pulse band displays intensity, and the soft and hard zones provide context for elevated readings. Its ATR-scaled projection keeps the complete framework connected directly to price, while the live dashboard provides fast insight into volume flow, entropy, efficiency, and the active regime.

Perfect for momentum traders, swing traders, trend-following traders, and systematic analysts who want a cleaner way to determine whether directional price movement is supported by meaningful and structurally efficient volume flow.

## Source Code

````pine
//@version=6
indicator("Entropy VZO [Alpha Extract]", shorttitle = "Entropy VZO", overlay = true, behind_chart = false, max_labels_count = 200)

// INPUTS
grpCore = "Core Engine"
src = input.source(hlc3, "Source", group = grpCore)
vzoLength = input.int(34, "Volume Flow Length", minval = 5, maxval = 200, group = grpCore)
zLength = input.int(55, "Z-Score Length", minval = 10, maxval = 300, group = grpCore)
entropyLength = input.int(30, "Entropy Length", minval = 8, maxval = 100, group = grpCore)
fractalLength = input.int(21, "Fractal Efficiency Length", minval = 5, maxval = 100, group = grpCore)
gaussLength = input.int(9, "Gaussian Polish", minval = 2, maxval = 40, group = grpCore)
histLength = input.int(5, "Histogram Polish", minval = 2, maxval = 40, group = grpCore)
signalLength = input.int(13, "Signal Length", minval = 2, maxval = 80, group = grpCore)
sensitivity = input.float(1.15, "Sensitivity", minval = 0.2, maxval = 4.0, step = 0.05, group = grpCore)

grpLevels = "Levels"
softLevel = input.float(45.0, "Soft Level", minval = 10.0, maxval = 120.0, step = 1.0, group = grpLevels)
hardLevel = input.float(75.0, "Hard Level", minval = 20.0, maxval = 150.0, step = 1.0, group = grpLevels)
maxLevel = input.float(100.0, "Max Visual Level", minval = 50.0, maxval = 200.0, step = 1.0, group = grpLevels)
pulseLength = input.int(34, "Pulse Length", minval = 5, maxval = 150, group = grpLevels)
pulseMult = input.float(0.75, "Pulse Width", minval = 0.1, maxval = 2.5, step = 0.05, group = grpLevels)

grpDisplay = "Display"
showHistogram = input.bool(true, "Show Histogram", group = grpDisplay)
showSignal = input.bool(true, "Show Signal", group = grpDisplay)
showRibbon = input.bool(true, "Show Ribbon Fill", group = grpDisplay)
showPulse = input.bool(true, "Show Pulse Band", group = grpDisplay)
showCandles = input.bool(true, "Color OHLC Candles", group = grpDisplay)
showTable = input.bool(true, "Show Status Table", group = grpDisplay)
anchorLength = input.int(21, "Price Anchor Length", minval = 1, maxval = 200, group = grpDisplay)
visualHeight = input.float(2.0, "Visual Height (ATR)", minval = 0.25, maxval = 10.0, step = 0.25, group = grpDisplay)
bullColor = input.color(color.rgb(46, 230, 166), "Bull Color", group = grpDisplay)
bearColor = input.color(color.rgb(151, 31, 49), "Bear Color", group = grpDisplay)
neutralColor = input.color(color.rgb(190, 196, 205), "Neutral Color", group = grpDisplay)

// FUNCTIONS
clamp(float value, float lo, float hi) =>
    math.max(math.min(value, hi), lo)

tanhSafe(float value) =>
    capped = clamp(value, -12.0, 12.0)
    e2 = math.exp(2.0 * capped)
    (e2 - 1.0) / (e2 + 1.0)

gaussian(series float source, simple int length) =>
    sigma = math.max(length / 3.0, 1.0)
    weighted = 0.0
    weightSum = 0.0
    for i = 0 to length - 1
        x = i / sigma
        w = math.exp(-0.5 * x * x)
        weighted += nz(source[i]) * w
        weightSum += w
    weightSum != 0.0 ? weighted / weightSum : source

fractalEfficiency(series float source, simple int length) =>
    path = 0.0
    for i = 0 to length - 1
        path += math.abs(nz(source[i] - source[i + 1]))
    direct = math.abs(source - source[length])
    path > 0.0 ? clamp(direct / path, 0.0, 1.0) : 0.0

directionEntropy(simple int length) =>
    upCount = 0.0
    downCount = 0.0
    for i = 0 to length - 1
        ch = nz(close[i] - close[i + 1])
        upCount += ch > 0 ? 1.0 : 0.0
        downCount += ch < 0 ? 1.0 : 0.0
    total = upCount + downCount
    if total == 0.0
        1.0
    else
        pUp = upCount / total
        pDn = downCount / total
        hUp = pUp > 0.0 ? -pUp * math.log(pUp) : 0.0
        hDn = pDn > 0.0 ? -pDn * math.log(pDn) : 0.0
        clamp((hUp + hDn) / math.log(2.0), 0.0, 1.0)

// CORE MATH
priceRange = math.max(high - low, syminfo.mintick)
candlePressure = (close - open) / priceRange
closePressure = ta.change(src) > 0 ? 1.0 : ta.change(src) < 0 ? -1.0 : 0.0
signedPressure = clamp(candlePressure * 0.65 + closePressure * 0.35, -1.0, 1.0)

signedVolume = volume * signedPressure
volumeBase = math.max(ta.ema(volume, vzoLength), 1.0)
vzo = 100.0 * ta.ema(signedVolume, vzoLength) / volumeBase

vzoMean = ta.ema(vzo, zLength)
vzoDev = math.max(ta.stdev(vzo, zLength), 1e-6)
vzoZ = (vzo - vzoMean) / vzoDev

efficiency = fractalEfficiency(src, fractalLength)
entropy = directionEntropy(entropyLength)
informationWeight = clamp((1.0 - entropy) * 0.55 + efficiency * 0.45, 0.05, 1.0)

spectralInput = vzoZ * sensitivity * (0.65 + informationWeight)
fisherCore = tanhSafe(spectralInput) * maxLevel
oscRaw = gaussian(fisherCore, gaussLength)
osc = ta.ema(oscRaw, 2)
signal = ta.ema(osc, signalLength)
hist = gaussian(osc - signal, histLength)

regime = osc > signal and osc > 0 ? 1 : osc < signal and osc < 0 ? -1 : 0
trendColor = regime == 1 ? bullColor : regime == -1 ? bearColor : neutralColor
candleCol = showCandles ? trendColor : na

// PRICE-SPACE PROJECTION
priceAnchor = ta.ema(src, anchorLength)
priceUnit = math.max(ta.atr(14), syminfo.mintick * 10.0) * visualHeight
toPrice(float value) =>
    priceAnchor + value / maxLevel * priceUnit

oscPrice = toPrice(osc)
signalPrice = toPrice(signal)
histPrice = toPrice(hist)
softUpperPrice = toPrice(softLevel)
softLowerPrice = toPrice(-softLevel)
hardUpperPrice = toPrice(hardLevel)
hardLowerPrice = toPrice(-hardLevel)

// LEVELS
zero = plot(priceAnchor, "Zero / Price Anchor", color.new(neutralColor, 70), 1)
softU = plot(softUpperPrice, "Soft +", color.new(bullColor, 82), 1)
softL = plot(softLowerPrice, "Soft -", color.new(bearColor, 82), 1)
hardU = plot(hardUpperPrice, "Hard +", color.new(bullColor, 70), 1)
hardL = plot(hardLowerPrice, "Hard -", color.new(bearColor, 70), 1)
fill(softU, hardU, color.new(bullColor, 92), title = "Upper Zone")
fill(softL, hardL, color.new(bearColor, 92), title = "Lower Zone")

// PLOTS
pulse = ta.ema(math.abs(osc), pulseLength) * pulseMult
pulseTop = plot(showPulse ? toPrice(pulse) : na, "Pulse Upper", color.new(neutralColor, 100), display = display.none)
pulseBot = plot(showPulse ? toPrice(-pulse) : na, "Pulse Lower", color.new(neutralColor, 100), display = display.none)
fill(pulseTop, pulseBot, showPulse ? color.new(trendColor, 91) : na, title = "Pulse Band")

histColor = hist >= 0 ? hist > hist[1] ? bullColor : color.new(bullColor, 55) : hist < hist[1] ? bearColor : color.new(bearColor, 55)
histogram = plot(showHistogram ? histPrice : na, "Entropy VZO Histogram", histColor, 2, plot.style_line)
histBase = plot(showHistogram ? priceAnchor : na, "Histogram Base", color.new(neutralColor, 100), display = display.none)
fill(histogram, histBase, showHistogram ? color.new(histColor, 70) : na, title = "Histogram Fill")

base = plot(oscPrice, "Entropy VZO Glow", color.new(trendColor, 82), 8, plot.style_line)
main = plot(oscPrice, "Entropy VZO", trendColor, 2, plot.style_line)
sig = plot(showSignal ? signalPrice : na, "Signal", color.new(neutralColor, 35), 1, plot.style_line)
sigHidden = plot(signalPrice, "Signal Hidden", display = display.none)
fill(main, sigHidden, showRibbon ? color.new(trendColor, 86) : na, title = "Signal Ribbon")

plotcandle(
     showCandles ? open : na,
     showCandles ? high : na,
     showCandles ? low : na,
     showCandles ? close : na,
     title = "Entropy VZO Colored OHLC",
     color = candleCol,
     wickcolor = candleCol,
     bordercolor = candleCol)

// STATUS TABLE
var table status = table.new(position.top_right, 2, 6, frame_color = color.new(neutralColor, 60), frame_width = 1, border_width = 0)
if barstate.islast
    table.clear(status, 0, 0, 1, 5)
    if showTable
        bg = color.new(color.black, 0)
        head = color.new(color.rgb(24, 27, 34), 0)
        table.cell(status, 0, 0, "Entropy VZO", text_color = color.white, bgcolor = head, text_size = size.small)
        table.cell(status, 1, 0, regime == 1 ? "Bull" : regime == -1 ? "Bear" : "Neutral", text_color = trendColor, bgcolor = head, text_size = size.small)
        table.cell(status, 0, 1, "Osc", text_color = neutralColor, bgcolor = bg, text_size = size.small)
        table.cell(status, 1, 1, str.tostring(osc, "#.##"), text_color = trendColor, bgcolor = bg, text_size = size.small)
        table.cell(status, 0, 2, "VZO Z", text_color = neutralColor, bgcolor = bg, text_size = size.small)
        table.cell(status, 1, 2, str.tostring(vzoZ, "#.##"), text_color = color.white, bgcolor = bg, text_size = size.small)
        table.cell(status, 0, 3, "Entropy", text_color = neutralColor, bgcolor = bg, text_size = size.small)
        table.cell(status, 1, 3, str.tostring(entropy * 100.0, "#.0") + "%", text_color = color.white, bgcolor = bg, text_size = size.small)
        table.cell(status, 0, 4, "Efficiency", text_color = neutralColor, bgcolor = bg, text_size = size.small)
        table.cell(status, 1, 4, str.tostring(efficiency * 100.0, "#.0") + "%", text_color = color.white, bgcolor = bg, text_size = size.small)
        table.cell(status, 0, 5, "Volume", text_color = neutralColor, bgcolor = bg, text_size = size.small)
        table.cell(status, 1, 5, str.tostring(volume / volumeBase, "#.##") + "x", text_color = color.white, bgcolor = bg, text_size = size.small)

// ALERTS
bullSwing = ta.crossover(osc, signal)
bearSwing = ta.crossunder(osc, signal)
bullTrend = ta.crossover(osc, 0)
bearTrend = ta.crossunder(osc, 0)
alertcondition(bullSwing, "Entropy VZO Bull Swing", "Entropy VZO: oscillator crossed above signal.")
alertcondition(bearSwing, "Entropy VZO Bear Swing", "Entropy VZO: oscillator crossed below signal.")
alertcondition(bullTrend, "Entropy VZO Bull Trend", "Entropy VZO: oscillator crossed above zero.")
alertcondition(bearTrend, "Entropy VZO Bear Trend", "Entropy VZO: oscillator crossed below zero.")
````
