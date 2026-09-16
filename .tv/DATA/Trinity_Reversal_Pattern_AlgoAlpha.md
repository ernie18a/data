<!-- tradingview-pine-id: PUB;a0d011f28a834808965de1012e2656b5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trinity Reversal Pattern [AlgoAlpha]

Source: https://www.tradingview.com/script/tpwLa60j-Trinity-Reversal-Pattern-AlgoAlpha/

## Description

🟠 OVERVIEW

Trinity Reversal Pattern [AlgoAlpha] identifies three-candle reversal structures and marks the price extreme associated with each detected setup. It is designed to separate structured reversal patterns from isolated bullish or bearish candles.

Each valid pattern receives a strength score based on the signal candle's body relative to the largest candle body within a selected lookback. The resulting reversal level remains active until price returns to it or the level reaches its selected expiry. An optional EMA trend filter can restrict patterns to the current trend direction.

🟠 CONCEPTS

[*] Bullish Trinity Reversal — A three-candle structure that begins with two bearish candles. The middle candle trades below the first candle's low while remaining below its high. The third candle closes bullish and extends above the first candle's high. The lowest price across the three candles becomes the bullish reversal level.

[*] Bearish Trinity Reversal — The inverse structure. It begins with two bullish candles, with the middle candle trading above the first candle's high while remaining above its low. The third candle closes bearish and extends below the first candle's low. The highest price across the three candles becomes the bearish reversal level.

[*] Signal Strength — The absolute body size of the signal candle divided by the largest candle body found within the selected Strength Lookback, expressed as a percentage. A value near 100% means the signal candle is close to the largest recent body. This measures relative candle-body strength, not reversal probability or historical win rate.

[*] Reversal Level — The lowest point of a bullish three-candle pattern or the highest point of a bearish pattern. It marks the price extreme associated with the reversal structure and stays active until touched or expired.

[*] EMA Trend Filter — An optional directional filter based on fast and slow EMAs. A fast EMA cross above the slow EMA establishes the bullish state, while a cross below establishes the bearish state. When enabled, bullish patterns are accepted only during the bullish state and bearish patterns only during the bearish state.

🟠 FEATURES

[*] Trinity Reversal Signals — Bullish and bearish markers identify completed three-candle reversal structures directly on the chart.
[image]https://www.tradingview.com/x/OrjelyQX/[/image]

[*] Reversal Levels — Each detected setup creates a level at its three-candle price extreme. Active levels extend forward and become dotted after they are touched or expire.
[image]https://www.tradingview.com/x/Zfoem497/[/image]

[*] Strength Labels — Active reversal levels can display their fixed signal strength percentage for quick comparison between setups.
[image]https://www.tradingview.com/x/GdqmMEjT/[/image]

[*] EMA Trend Gradient — Optional fast and slow EMA lines display the active trend state with a gradient between them.
[image]https://www.tradingview.com/x/6u5ZyPNy/[/image]

🟠 HOW TO USE

[*] Watch for a bullish marker after a three-candle downside structure or a bearish marker after the corresponding upside structure.

[*] Compare the strength labels between signals. Higher values mean the signal candle has a larger body relative to the recent candle bodies in the selected lookback.

[*] Increase Minimum Signal Strength to remove patterns with weaker signal candles. Lower it to include a broader range of detected structures.

[*] Treat an active reversal level as the price extreme linked to its original setup. A later wick reaching that price counts as a touch and stops the level from remaining active.

[*] Adjust Level Expiry Bars to control how long untouched reversal levels remain active. Shorter values focus on recent setups, while longer values preserve levels for more bars.

[*] Enable the EMA Trend Filter when you want signals aligned with the current EMA state. In a bullish EMA state, only bullish Trinity patterns are accepted. In a bearish EMA state, only bearish patterns are accepted.

[*] Enable Confirm Signals on Close when you want a pattern to be confirmed only after its signal candle closes. Disabling it allows the current candle to produce a signal before the bar is complete, so the signal can change while the candle develops.

[*] Use alerts to track bullish or bearish Trinity signals, touches of active reversal levels, level expirations, and EMA trend crosses without continuously watching the chart.

🟠 CONCLUSION

Trinity Reversal Pattern [AlgoAlpha] combines three-candle reversal structures, relative candle-body strength, persistent reversal levels, and an optional EMA trend filter. It gives traders a structured way to identify reversal setups, compare their relative strength, and track whether their associated price extremes remain active or are revisited.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlgoAlpha

//@version=6
indicator("Trinity Reversal Pattern [AlgoAlpha]", "AlgoAlpha - Trinity Reversal", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// Inputs
calcGR = "Calculation"
strengthLookback = input.int(100, "Strength Lookback", minval = 2, maxval = 5000, tooltip = "Number of recent candle bodies stored in the array, including the current candle. Strength is the signal candle body divided by the largest stored body, multiplied by 100. It is not a win probability.", group = calcGR)
minimumStrength = input.float(0.0, "Minimum Signal Strength (%)", minval = 0.0, maxval = 100.0, step = 1.0, tooltip = "Filters out patterns below this body-strength score. Set to 0 to accept all pattern strengths.", group = calcGR)
expiryInput = input.int(100, "Level Expiry Bars", minval = 1, maxval = 5000, tooltip = "Number of chart bars after the signal candle before an untouched level expires. Expiry occurs at that bar's close. Touch checks start on the candle after the signal.", group = calcGR)
confirmClose = input.bool(true, "Confirm Signals on Close", tooltip = "Waits for the signal candle to close before confirming a pattern. When disabled, signals, levels, and scores can change before the candle closes.", group = calcGR)

trendGR = "Trend Filter"
useTrend = input.bool(false, "Use EMA Trend Filter", tooltip = "Shows the EMA gradient and filters opposing signals. A fast EMA cross above the slow EMA starts a bullish trend. A cross below starts a bearish trend. When disabled, both pattern directions are allowed.", group = trendGR)
fastLength = input.int(21, "Fast EMA", minval = 1, maxval = 500, group = trendGR, inline = "ema")
slowLength = input.int(50, "Slow EMA", minval = 2, maxval = 1000, tooltip = "Lengths of the fast and slow EMAs. The fast length must be less than the slow length when the trend filter is enabled.", group = trendGR, inline = "ema")
trendSource = input.source(close, "EMA Source", tooltip = "Price source used by both trend EMAs.", group = trendGR)

appearanceGR = "Appearance"
showSignals = input.bool(true, "Show Signals", group = appearanceGR, inline = "visuals")
showLevels = input.bool(true, "Show Levels", tooltip = "Shows the signal markers and reversal levels. Hiding these visuals does not disable signal or level-touch alerts.", group = appearanceGR, inline = "visuals")
showStrength = input.bool(true, "Show Strength", group = appearanceGR, inline = "labels")
labelSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], tooltip = "Shows a fixed strength score at the midpoint of each active level. Labels use the chart background color and are deleted when levels are touched or expire.", group = appearanceGR, inline = "labels")
levelExtension = input.int(5, "Active Level Extension", minval = 1, maxval = 100, tooltip = "Number of chart bars to project active levels ahead. Touched or expired lines end at the touch or expiry bar.", group = appearanceGR)
inactiveTransparency = input.int(75, "Inactive Level Transparency", minval = 0, maxval = 100, tooltip = "Transparency of stopped levels. These lines remain on the chart as dotted lines until the storage limit requires removal.", group = appearanceGR)
maxLevels = input.int(500, "Maximum Stored Levels", minval = 10, maxval = 500, tooltip = "Maximum number of active and stopped lines retained. At the limit, the oldest stopped line is removed first. If every stored line is still active, the oldest active line and its label are removed instead.", group = appearanceGR)
showCrosses = input.bool(true, "Show EMA Crosses", tooltip = "Shows a dot when the fast EMA crosses the slow EMA. Requires the EMA trend filter.", group = appearanceGR)
gradientTransparency = input.int(70, "Trend Gradient Transparency", minval = 0, maxval = 100, tooltip = "Transparency at the stronger edge of the EMA gradient. The opposite edge is more transparent.", group = appearanceGR)
bullColor = input.color(#00ffbb, "Bullish Color", group = appearanceGR, inline = "colors")
bearColor = input.color(#ff1100, "", tooltip = "Colors used for bullish and bearish signals, levels, strength text, and the EMA gradient.", group = appearanceGR, inline = "colors")

// Variables and functions
var bodySamples = array.new_float()
var activeLines = array.new_line()
var activeLabels = array.new_label()
var activeDirections = array.new_int()
var activeStartBars = array.new_int()
var inactiveLines = array.new_line()
var trend = 0

sizeFromString(txt) =>
    switch txt
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        => size.large

removeActiveLevel(index) =>
    levelLine = array.remove(activeLines, index)
    label.delete(array.remove(activeLabels, index))
    array.remove(activeDirections, index)
    array.remove(activeStartBars, index)
    levelLine

// Calculations
if barstate.isfirst and useTrend and fastLength >= slowLength
    runtime.error("Fast EMA length must be less than Slow EMA length.")

candleBody = math.abs(close - open)
array.push(bodySamples, candleBody)

if array.size(bodySamples) > strengthLookback
    array.shift(bodySamples)

largestBody = array.max(bodySamples)
strength = largestBody > 0 ? math.min(100.0, candleBody / largestBody * 100.0) : 0.0

fastEMA = ta.ema(trendSource, fastLength)
slowEMA = ta.ema(trendSource, slowLength)
bullCross = ta.crossover(fastEMA, slowEMA)
bearCross = ta.crossunder(fastEMA, slowEMA)

if bullCross
    trend := 1
else if bearCross
    trend := -1
else if trend == 0
    trend := fastEMA > slowEMA ? 1 : fastEMA < slowEMA ? -1 : 0

bull = close > open and high > high[2] and low[1] < low[2] and high[1] < high[2] and close[1] < open[1] and close[2] < open[2]
bear = close < open and low < low[2] and high[1] > high[2] and low[1] > low[2] and close[1] > open[1] and close[2] > open[2]

signalReady = bar_index >= 2 and (not confirmClose or barstate.isconfirmed)
bullSignal = bull and signalReady and strength >= minimumStrength and (not useTrend or trend == 1)
bearSignal = bear and signalReady and strength >= minimumStrength and (not useTrend or trend == -1)

patternLow = math.min(low, low[1], low[2])
patternHigh = math.max(high, high[1], high[2])
lowOffset = low == patternLow ? 0 : low[1] == patternLow ? 1 : 2
highOffset = high == patternHigh ? 0 : high[1] == patternHigh ? 1 : 2

bullLevelTouched = false
bearLevelTouched = false
levelExpired = false

// Visuals
if array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0
        activeLine = array.get(activeLines, i)
        activeLabel = array.get(activeLabels, i)
        direction = array.get(activeDirections, i)
        startBar = array.get(activeStartBars, i)
        level = line.get_y1(activeLine)
        age = bar_index - startBar

        if age > 0
            wickTouch = direction == 1 ? low <= level : high >= level
            expired = age >= expiryInput and barstate.isconfirmed
            endBar = wickTouch or expired ? bar_index : bar_index + levelExtension
            line.set_x2(activeLine, endBar)

            if wickTouch or expired
                levelColor = direction == 1 ? bullColor : bearColor
                line.set_color(activeLine, showLevels ? color.new(levelColor, inactiveTransparency) : na)
                line.set_style(activeLine, line.style_dotted)
                array.push(inactiveLines, removeActiveLevel(i))
                bullLevelTouched := bullLevelTouched or (wickTouch and direction == 1)
                bearLevelTouched := bearLevelTouched or (wickTouch and direction == -1)
                levelExpired := levelExpired or (expired and not wickTouch)
            else if not na(activeLabel)
                midpoint = int(math.floor((line.get_x1(activeLine) + endBar) * 0.5))
                label.set_x(activeLabel, midpoint)

if bullSignal or bearSignal
    while array.size(activeLines) + array.size(inactiveLines) >= maxLevels
        if array.size(inactiveLines) > 0
            line.delete(array.shift(inactiveLines))
        else
            line.delete(removeActiveLevel(0))

    direction = bullSignal ? 1 : -1
    level = bullSignal ? patternLow : patternHigh
    startBar = bar_index - (bullSignal ? lowOffset : highOffset)
    endBar = bar_index + levelExtension
    levelColor = bullSignal ? bullColor : bearColor
    midpoint = int(math.floor((startBar + endBar) * 0.5))
    levelText = str.tostring(strength, "#.#") + "% Strength"

    newLine = line.new(x1 = startBar, y1 = level, x2 = endBar, y2 = level, xloc = xloc.bar_index, extend = extend.none, color = showLevels ? levelColor : na, width = 3)
    newLabel = label(na)

    if showLevels and showStrength
        newLabel := label.new(x = midpoint, y = level, text = levelText, xloc = xloc.bar_index, yloc = yloc.price, color = chart.bg_color, style = label.style_label_center, textcolor = levelColor, size = sizeFromString(labelSizeInput), textalign = text.align_center)

    array.push(activeLines, newLine)
    array.push(activeLabels, newLabel)
    array.push(activeDirections, direction)
    array.push(activeStartBars, bar_index)

trendColor = trend == 1 ? bullColor : trend == -1 ? bearColor : color.gray
trendTop = math.max(fastEMA, slowEMA)
trendBottom = math.min(fastEMA, slowEMA)
fadeTransparency = math.min(100, gradientTransparency + 25)
topColor = trend == 1 ? color.new(trendColor, fadeTransparency) : color.new(trendColor, gradientTransparency)
bottomColor = trend == 1 ? color.new(trendColor, gradientTransparency) : color.new(trendColor, fadeTransparency)

fastPlot = plot(useTrend ? fastEMA : na, title = "Fast Trend EMA", color = color.new(trendColor, 15), linewidth = 2, style = plot.style_linebr)
slowPlot = plot(useTrend ? slowEMA : na, title = "Slow Trend EMA", color = color.new(trendColor, 45), linewidth = 2, style = plot.style_linebr)
fill(fastPlot, slowPlot, trendTop, trendBottom, useTrend ? topColor : na, useTrend ? bottomColor : na, title = "EMA Trend Gradient", fillgaps = false)

plot(useTrend and showCrosses and (bullCross or bearCross) ? slowEMA : na, title = "EMA Cross", color = trendColor, linewidth = 4, style = plot.style_circles)

plotshape(showSignals and bullSignal, title = "Bullish Trinity Reversal", style = shape.labelup, location = location.belowbar, color = bullColor, text = "▲", textcolor = chart.fg_color, size = size.tiny)
plotshape(showSignals and bearSignal, title = "Bearish Trinity Reversal", style = shape.labeldown, location = location.abovebar, color = bearColor, text = "▼", textcolor = chart.fg_color, size = size.tiny)

// Alerts
alertcondition(bullSignal, title = "Bullish Trinity Reversal")
alertcondition(bearSignal, title = "Bearish Trinity Reversal")
alertcondition(bullLevelTouched, title = "Bullish Trinity Level Touched")
alertcondition(bearLevelTouched, title = "Bearish Trinity Level Touched")
alertcondition(levelExpired, title = "Trinity Level Expired")
alertcondition(useTrend and bullCross and signalReady, title = "Bullish EMA Cross")
alertcondition(useTrend and bearCross and signalReady, title = "Bearish EMA Cross")
````
