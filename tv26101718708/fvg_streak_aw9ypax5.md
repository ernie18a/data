# FVG Streak

- url: https://www.tradingview.com/script/aW9yPAx5-FVG-Streak/
- type: indicator
- pine_id: PUB;bfa486246dbb4d58b7a5c59ec1230b57
- version: 1.0

## Description

█ OVERVIEW
FVG Streak is a momentum indicator based on the analysis of consecutive Fair Value Gaps (FVG). Instead of evaluating individual gaps, it measures the number of successive bullish or bearish FVGs, creating a counter (Streak) that shows which side of the market currently holds the advantage.

The core idea of the indicator is that a single Fair Value Gap may represent only a temporary market imbalance, while a series of consecutive FVGs forming in the same direction indicates sustained dominance by buyers or sellers.
The indicator builds a counter of successive FVGs without the appearance of an opposite gap. Each new FVG in the current direction increases the counter value, while the appearance of an opposite FVG immediately resets the previous sequence and starts counting from scratch in the new direction.

Once a defined threshold of consecutive bullish or bearish FVGs is reached, the indicator generates BUY and SELL signals, but only on a candle that matches the direction of the FVG. On a candle of the opposite direction, no signal is generated. Additionally, it can draw all detected Fair Value Gap zones on the chart, automatically remove them after mitigation, color the candles according to the dominant direction, and visualize the strength of market dominance using gradients and a colored indicator line.
The result is a tool that allows assessment not only of the occurrence of Fair Value Gaps, but primarily of the persistence of the imbalance between buyers and sellers. This helps distinguish single impulses from situations in which the market consistently builds a strong trend.

█ CONCEPTS
Fair Value Gap (FVG)
The foundation of the indicator is Fair Value Gaps (FVG) — gaps that form between candles and indicate a temporary imbalance between demand and supply.
A bullish FVG occurs when the low of the current candle is above the high of the candle two periods earlier. This means price moved so dynamically that no full trading occurred between those levels.
Similarly, a bearish FVG appears when the high of the current candle is below the low of the candle two periods earlier, indicating strong selling pressure.
Such areas are often interpreted as imbalance zones to which the market may later return.

Consecutive FVG Counter (FVG Streak)
The most important concept of the indicator is the assumption that repeated Fair Value Gaps in the same direction demonstrate trend strength.
A single FVG can appear in virtually any market and does not necessarily signal the start of a strong move. However, if the market creates successive bullish FVGs without the appearance of bearish gaps, it means buyers are continuously maintaining control and are able to repeatedly generate new price imbalances.
Analogously, a series of consecutive bearish FVGs indicates consistent dominance of supply. Each subsequent gap appearing in the same direction strengthens the conviction that the market is in a strong impulse rather than merely performing a short-lived breakout.
Instead of analyzing individual FVGs independently, the indicator treats them as elements of a single sequence. In this way it measures not only the mere occurrence of an imbalance, but also its durability and continuity over time.
The higher the counter value, the longer one side of the market has maintained dominance.

Sequence Reset
The counter operates only until an FVG of the opposite direction appears.
Each successive FVG in the current direction increases the counter by one. The appearance of an opposite FVG immediately ends the previous sequence and starts counting from the value of 1 for the new direction.
Thanks to this, the indicator always shows the current market dominance rather than the sum of all historical gaps.

Signal Thresholds
The user defines the minimum number of consecutive FVGs required to generate a signal.
After the positive threshold is crossed, the indicator generates a BUY signal. After the negative threshold is crossed, a SELL signal appears.
An additional filter is the direction of the current candle. A buy signal can appear only on a bullish candle, while a sell signal only on a bearish candle, which eliminates some random signals.

Visualization of Market Dominance
The indicator line shows the current value of the consecutive FVG counter.
Positive values indicate dominance of bullish Fair Value Gaps. Negative values indicate dominance of bearish Fair Value Gaps.
The line color automatically changes according to the direction of dominance, and an optional gradient between the line and the zero level allows instant assessment of the strength of the current advantage of one side of the market.

Fair Value Gap Zones
The indicator can simultaneously draw all detected Fair Value Gaps directly on the price chart.
Each gap is presented as a rectangle that extends until it is mitigated or reaches the maximum length specified by the user.
Mitigation can occur after the zone is violated by a candle wick or only after the candle closes beyond its boundary, depending on the selected mode.
This allows simultaneous observation of both the current trend strength and potential price reaction zones resulting from remaining imbalances.

█ FEATURES
Signal Settings
• Buy Signal Threshold – number of consecutive bullish Fair Value Gaps required to generate a BUY signal
• Sell Signal Threshold – number of consecutive bearish Fair Value Gaps required to generate a SELL signal
• Show Signals – displays BUY and SELL signals after the defined thresholds are crossed

Appearance
• Bullish Color – color used for positive indicator values, bullish signals, gradients, and bullish FVGs
• Bearish Color – color used for negative indicator values, bearish signals, gradients, and bearish FVGs
• Neutral / Zero Color – color of the zero level and the indicator line when neither side of the market has dominance
• Gradient Transparency – transparency of the gradient between the indicator line and the zero level
• Threshold Band Transparency – transparency of the bands displayed at the signal threshold levels
• Gradient – Buy Threshold – displays a thickened band visualizing the BUY signal threshold
• Gradient – Sell Threshold – displays a thickened band visualizing the SELL signal threshold
• Gradient → Zero – fills the space between the indicator line and the zero level with a gradient showing current market dominance

Fair Value Gap Zones
• Show FVG Boxes on Chart – draws all detected Fair Value Gaps directly on the price chart
• Box Mitigation Source – determines how FVG zones are closed:
– Wick – the zone is closed after being violated by a candle wick
– Close – the zone is closed only after the candle closes beyond its boundary
• Max Box Length – maximum display length of an unmitigated FVG zone; value 0 means no limit
• Border Color – Bullish FVG – border and fill color of bullish FVG zones
• Border Color – Bearish FVG – border and fill color of bearish FVG zones
• Box Fill Transparency – transparency of the FVG zone fill
• Color Bars by FVG Trend – colors the candles according to the current dominance of bullish or bearish FVGs
• Bar Coloring Transparency – transparency of the candle coloring

ATR Filter
• Filter Small FVGs by ATR – ignores Fair Value Gaps smaller than the specified size expressed as a multiple of ATR
• ATR Length – number of bars used to calculate ATR
• ATR Multiplier – minimum FVG size required for the indicator to take it into account

Alerts
• Alert on BUY signal generation
• Alert on SELL signal generation

█ APPLICATIONS
Assessing Trend Strength
The primary use of the indicator is to assess the strength of the current trend by analyzing the number of consecutive Fair Value Gaps forming in the same direction.

Confirming Momentum
A rising counter value means the market is repeatedly creating new imbalances without the appearance of opposite signals.
This can serve as additional confirmation of momentum and the strength of the impulse observed on the chart.

Generating Signals
Crossing a defined threshold of consecutive FVGs generates a BUY or SELL signal.
Signals should not be treated as automatic entry points. They are best used as confirmation of market analysis performed with other tools such as market structure, support and resistance levels, volume analysis, or Order Flow.

Analysis of Active Fair Value Gaps
The rectangles drawn on the chart allow simultaneous observation of all active price imbalances.
Thanks to automatic mitigation, the user sees only those zones that remain relevant from the market’s perspective.

Eliminating Insignificant FVGs
The optional ATR filter allows ignoring very small Fair Value Gaps that are often merely the result of random price movements.
This helps focus the analysis on larger imbalances that more frequently have practical significance.

Visual Assessment of Market Dominance
The line color, gradient, candle coloring, and counter value allow instant determination of which side of the market currently holds the advantage.
Thanks to this, even without analyzing individual FVGs, one can quickly assess the current state of the market.

█ NOTES
• The indicator analyzes exclusively consecutive Fair Value Gaps occurring without interruption in the same direction.
• The appearance of a Fair Value Gap of the opposite direction immediately ends the previous sequence and starts a new count.
• BUY and SELL signals inform about reaching a defined number of consecutive Fair Value Gaps. They do not constitute automatic entry signals, and before making a decision it is advisable to confirm them with other elements of technical analysis such as market structure, support and resistance, volume, or momentum.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('FVG Streak', 
     overlay = false, 
     max_bars_back = 2000, 
     precision = 0, 
     max_labels_count = 500,
     max_boxes_count = 500)

// SETTINGS

buyThreshold  = input.float(3.0,  title='Buy Signal Threshold (Consecutive Bull FVGs)',      step=0.1, group='Levels',
     tooltip='Number of consecutive bullish FVGs (no interruption by an opposite gap) after which the "streak" counter generates a buy signal (on a bullish candle).')
sellThreshold = input.float(-3.0, title='Sell Signal Threshold (Consecutive Bear FVGs)',  step=0.1, group='Levels',
     tooltip='Number of consecutive bearish FVGs (no interruption by an opposite gap) after which the "streak" counter generates a sell signal (on a bearish candle).')

showObosSignals = input.bool(true, title='Show Signals', group='Signals',
     tooltip='Enables/disables drawing signal dots (buy/sell) on the chart when the streak crosses the buy/sell signal threshold.')

bullColor    = input.color(color.rgb(6, 162, 47), title='Bullish Color',           group='Colors',
     tooltip='Color of the line, gradient, and band for positive values (dominance of bullish FVGs).')
bearColor    = input.color(color.rgb(207, 23, 23), title='Bearish Color',    group='Colors',
     tooltip='Color of the line, gradient, and band for negative values (dominance of bearish FVGs).')
neutralColor = input.color(color.gray,             title='Neutral / Zero Color', group='Colors',
     tooltip='Color of the zero line and the indicator line when streak = 0.')

gradientTransparency = input.int(80, minval=0, maxval=100, title='Gradient Transparency', group='Colors',
     tooltip='Transparency of the fill between the streak line and the zero level (0 = full color, 100 = invisible).')
bandTransparency     = input.int(40, minval=0, maxval=100, title='Threshold Band Transparency', group='Colors',
     tooltip='Transparency of the horizontal bands drawn at the buy/sell signal thresholds.')

showBuyThresholdGradient  = input.bool(true, title='Gradient - Buy Threshold',     group='Colors',
     tooltip='Shows a thickened band at the buy signal threshold.')
showSellThresholdGradient = input.bool(true, title='Gradient - Sell Threshold', group='Colors',
     tooltip='Shows a thickened band at the sell signal threshold.')
showToZeroGradient        = input.bool(true, title='Gradient → Zero',           group='Colors',
     tooltip='Shows a fill gradient between the streak line and the zero level.')

showFvgBoxes = input.bool(true, title='Show FVG Boxes on Chart', group='FVG Boxes',
     tooltip='Draws rectangles (boxes) on the main chart marking detected price gaps (FVG). Boxes disappear/shrink once the gap is mitigated.')
mitigationSource = input.string("Wick", title='Box Mitigation Source', options=['Wick', 'Close'], group='FVG Boxes',
     tooltip='Wick: the box disappears when price breaks through it with a wick (high/low). Close: the box disappears only once a candle closes beyond its edge.')
maxBoxLen    = input.int(500, title='Max Box Length (bars), 0 = no limit', minval=0, group='FVG Boxes',
     tooltip='Maximum number of bars an unmitigated FVG box is drawn for. 0 means no limit (the box grows until the gap is closed).')
bullBoxBorder = input.color(color.rgb(6, 162, 47),  title='Border Color - Bullish FVG',      group='FVG Boxes',
     tooltip='Border and fill color of boxes for bullish FVGs.')
bearBoxBorder = input.color(color.rgb(207, 23, 23), title='Border Color - Bearish FVG', group='FVG Boxes',
     tooltip='Border and fill color of boxes for bearish FVGs.')
boxFillTransparency = input.int(85, minval=0, maxval=100, title='Box Fill Transparency', group='FVG Boxes',
     tooltip='Transparency of the fill inside FVG boxes.')

showBarColoring = input.bool(true, title='Color Bars by FVG Trend', group='FVG Boxes',
     tooltip='Colors the bars on the main chart according to the current streak sign: bullish (positive), bearish (negative), or neutral (zero).')
barColoringTransparency = input.int(0, minval=0, maxval=100, title='Bar Coloring Transparency', group='FVG Boxes',
     tooltip='Transparency of the color applied to the bars (0 = full color).')

useAtrFilter = input.bool(false, title='Filter Small FVGs by ATR', group='ATR Filter',
     tooltip='When enabled, an FVG gap is only counted if its size (in points) is greater than or equal to ATR * multiplier.')
atrLength    = input.int(14, title='ATR Length', minval=1, group='ATR Filter',
     tooltip='Number of bars used to calculate the ATR.')
atrMult      = input.float(0.5, title='ATR Multiplier', step=0.1, minval=0, group='ATR Filter',
     tooltip='Minimum FVG gap size as a multiple of ATR. E.g. 0.5 means the gap must be at least half the ATR.')

// FVG (FAIR VALUE GAP) DETECTION
atrValue = ta.atr(atrLength)

bullGapSize = low - high[2]
bearGapSize = low[2] - high

bfvgRaw = low > high[2]
sfvgRaw = high < low[2]

bfvg = bfvgRaw and (not useAtrFilter or bullGapSize >= atrValue * atrMult)
sfvg = sfvgRaw and (not useAtrFilter or bearGapSize >= atrValue * atrMult)

// STREAK COUNTER OF CONSECUTIVE GAPS IN THE SAME DIRECTION
var float streak = 0.0
if bfvg
    streak := streak >= 0 ? streak + 1 : 1
else if sfvg
    streak := streak <= 0 ? streak - 1 : -1

// Indicator line color depending on streak sign
lineColor = streak > 0 ? bullColor : streak < 0 ? bearColor : neutralColor

// Current candle direction (used to filter signals)
candleBullish = close > open
candleBearish = close < open

// Buy signal: streak just crossed the buy threshold upward, bullish candle
longSignal  = streak >= buyThreshold  and streak[1] < buyThreshold  and candleBullish
// Sell signal: streak just crossed the sell threshold downward, bearish candle
shortSignal = streak <= sellThreshold and streak[1] > sellThreshold and candleBearish

supBuySignal  = showObosSignals and longSignal
supSellSignal = showObosSignals and shortSignal

// DRAWING AND MANAGING FVG BOXES ON THE MAIN CHART

var array<box>   bullBoxes = array.new<box>()
var array<box>   bearBoxes = array.new<box>()

// Create a new box for a freshly detected bullish gap
if showFvgBoxes and bfvg
    newBullBox = box.new(
         left = bar_index - 2,
         top = low,
         bottom = high[2],
         right = bar_index,
         border_color = bullBoxBorder,
         border_width = 1,
         bgcolor = color.new(bullBoxBorder, boxFillTransparency),
         xloc = xloc.bar_index,
         extend = extend.none,
         force_overlay = true)
    array.push(bullBoxes, newBullBox)

// Create a new box for a freshly detected bearish gap
if showFvgBoxes and sfvg
    newBearBox = box.new(
         left = bar_index - 2,
         top = low[2],
         bottom = high,
         right = bar_index,
         border_color = bearBoxBorder,
         border_width = 1,
         bgcolor = color.new(bearBoxBorder, boxFillTransparency),
         xloc = xloc.bar_index,
         extend = extend.none,
         force_overlay = true)
    array.push(bearBoxes, newBearBox)

// Update/remove bullish boxes
if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0
        b   = array.get(bullBoxes, i)
        bot = box.get_bottom(b)
        lft = box.get_left(b)
        mitigated = mitigationSource == 'Wick' ? low <= bot : close <= bot
        if mitigated
            box.set_right(b, bar_index)
            array.remove(bullBoxes, i)
        else
            reachedMax = maxBoxLen != 0 and (bar_index - lft) >= maxBoxLen
            if reachedMax
                box.set_right(b, lft + maxBoxLen)
                array.remove(bullBoxes, i)
            else
                box.set_right(b, bar_index)

// Update/remove bearish boxes
if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0
        b   = array.get(bearBoxes, i)
        top = box.get_top(b)
        lft = box.get_left(b)
        mitigated = mitigationSource == 'Wick' ? high >= top : close >= top
        if mitigated
            box.set_right(b, bar_index)
            array.remove(bearBoxes, i)
        else
            reachedMax = maxBoxLen != 0 and (bar_index - lft) >= maxBoxLen
            if reachedMax
                box.set_right(b, lft + maxBoxLen)
                array.remove(bearBoxes, i)
            else
                box.set_right(b, bar_index)

// BAR COLORING BY FVG TREND (optional)
barcolor(showBarColoring ? color.new(lineColor, barColoringTransparency) : na)


// DRAWING THE INDICATOR IN THE BOTTOM PANE

// Main streak counter line
plot_streak = plot(streak, color = lineColor, linewidth = 3, title = "FVG Streak")

// Zero line (no dominance in either direction)
hline(0, color = neutralColor, linestyle = hline.style_dashed)

// Auxiliary invisible plot at level 0, needed for the fill() function
p0 = plot(0, color = na, display = display.none)

// Gradient color depending on the current streak sign
baseGradientColor = streak >= 0 ? bullColor : bearColor
c_grad_peak = color.new(baseGradientColor, gradientTransparency)
c_grad_zero = color.new(baseGradientColor, 100)

// Gradient fill between the streak line and zero - positive part
fill(plot_streak, p0,
     top_value    = showToZeroGradient and streak >= 0 ? streak : na,
     bottom_value = showToZeroGradient and streak >= 0 ? 0      : na,
     top_color    = showToZeroGradient and streak >= 0 ? c_grad_peak : na,
     bottom_color = showToZeroGradient and streak >= 0 ? c_grad_zero : na)

// Gradient fill between the streak line and zero - negative part
fill(p0, plot_streak,
     top_value    = showToZeroGradient and streak < 0 ? 0      : na,
     bottom_value = showToZeroGradient and streak < 0 ? streak : na,
     top_color    = showToZeroGradient and streak < 0 ? c_grad_zero : na,
     bottom_color = showToZeroGradient and streak < 0 ? c_grad_peak : na)

// Horizontal lines and thickened bands at the buy/sell signal thresholds
hline(buyThreshold, color = bullColor, linestyle = hline.style_dashed)
plot(showBuyThresholdGradient ? buyThreshold : na, color = color.new(bullColor, bandTransparency), linewidth = 10)
hline(sellThreshold, color = bearColor, linestyle = hline.style_dashed)
plot(showSellThresholdGradient ? sellThreshold : na, color = color.new(bearColor, bandTransparency), linewidth = 10)

// VISUAL SIGNALS (DOTS) AND DATA FOR BACKTESTING

// Offset of signal dots from the thresholds so they don't cover the line
dotOffset = math.max((buyThreshold - sellThreshold) * 0.2, 0.15)
plotshape(supBuySignal  ? buyThreshold  + dotOffset : na, location = location.absolute, color = color.new(bullColor, 20), style = shape.circle, size = size.small)
plotshape(supSellSignal ? sellThreshold - dotOffset : na, location = location.absolute, color = color.new(bearColor, 20), style = shape.circle, size = size.small)

// ALERTS
alertcondition(supBuySignal,
     title   = "FVG Consec - Buy Signal",
     message = "FVG Consecutive: buy signal - streak reached the buy signal threshold")

alertcondition(supSellSignal,
     title   = "FVG Consec - Sell Signal",
     message = "FVG Consecutive: sell signal - streak reached the sell signal threshold")
````
