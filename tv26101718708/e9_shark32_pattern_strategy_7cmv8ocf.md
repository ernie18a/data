# E9 Shark-32 Pattern Strategy 

- url: https://www.tradingview.com/script/7cMV8ocF-E9-Shark-32-Pattern-Strategy/
- type: strategy
- pine_id: PUB;606217d6597d431fb820e171661ba2aa
- version: 1.0

## Description

The E9 Shark-32 Pattern is a powerful trading tool designed to capitalize on the Shark-32 pattern—a specific Candlestick pattern. 

[b]The Shark-32 Pattern: What Is It?[/b]
The Shark-32 pattern is a technical formation that occurs when the following conditions are met:

Higher Highs and Lower Lows: The low of two bars ago is lower than the previous bar, and the previous bar's low is lower than the current bar. At the same time, the high of two bars ago is higher than the previous bar, and the previous bar’s high is higher than the current bar.
This unique setup forms the "Shark-32" pattern, which signals potential volume squeezes and trend changes in the market.

[b]How Does the Strategy Work?[/b]
The E9 Shark-32 Pattern Strategy builds upon this pattern by defining clear entry and exit rules based on the pattern's confirmation. Here's a breakdown of how the strategy operates:

[b]1. Identifying the Shark-32 Pattern[/b]
When the Shark-32 pattern is confirmed, the strategy "locks" the high and low prices from the initial bar of the pattern. These locked prices serve as key levels for future trade entries and exits.

[b]2. Entry Conditions[/b]
The strategy waits for the price to cross the pattern's locked high or low, signaling potential market direction.

Long Entry: A long trade is triggered when the closing price crosses above the locked pattern high (green line).
Short Entry: A short trade is triggered when the closing price crosses below the locked pattern low (red line).
The strategy ensures that only one trade is taken for each Shark-32 pattern, preventing overtrading and allowing traders to focus on high-probability setups.

[b]3. Stop Loss and Take Profit Levels[/b]
The strategy has built-in risk management through stop-loss and take-profit levels, which are visually represented by the lines on the chart:

Stop Loss:
Stop loss can be adjusted in settings.
Take Profit:
For long trades: The take-profit target is set at the upper white dotted line, which is projected above the pattern high.
For short trades: The take-profit target is set at the lower white dotted line, which is projected below the pattern low.
These clearly defined levels help traders to manage risk effectively while maximizing potential returns.

[b]4. Visual Cues[/b]
To make trading decisions even easier, the strategy provides helpful visual cues:
Green Line (Pattern High): This line represents the high of the Shark-32 pattern and serves as a resistance level and short entry signal.
Red Line (Pattern Low): This line represents the low of the Shark-32 pattern and serves as a support level and long entry signal.
White Dotted Lines: These lines represent potential profit targets, projected both above and below the pattern. They help traders define where the market might go next.
Additionally, the strategy highlights the pattern formation with color-coded bars and background shading to draw attention to the Shark-32 pattern when it is confirmed. This adds a layer of visual confirmation, making it easier to spot opportunities in real-time.

5. No Repeated Trades
An important aspect of the strategy is that once a trade is taken (either long or short), no additional trades are executed until a new Shark-32 pattern is identified. This ensures that only valid and confirmed setups are acted upon.

## Source Code

````pine
//╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
//║                                                                                                             ║
//║ ░▒▓████████▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░   ░▒▓████████▓▒░▒▓██████▓▒░  ║
//║    ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒   ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░ ║
//║    ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒.  ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░ ║
//║    ░▒▓█▓▒░   ░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░.  ░▒▓██████▓▒░ ░▒▓███████▓▒░ ║
//║    ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒.  ░▒▓█▓▒░            ░▒▓█▓▒░ ║
//║    ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒.  ░▒▓█▓▒░            ░▒▓█▓▒░ ║
//║    ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒.  ░▒▓████████▓▒░▒▓██████▓▒░  ║
//║                                                                                                             ║
//╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

//@version=5
strategy("E9 Shark-32 Pattern Strategy with Target Lines", shorttitle="E9 Shark-32 Strategy", overlay=true)

// Inputs for background color settings
bgcolorEnabled = input(true, title="Enable Background Color")
bgcolorColor = input.color(color.new(color.blue, 90), title="Background Color")

// Inputs for bar color settings
barcolorEnabled = input(true, title="Enable Bar Color")
barcolorColor = input.color(color.rgb(240, 241, 154), title="Bar Color")

// Inputs for target lines settings
targetLinesEnabled = input(true, title="Enable Target Lines")
targetLineColor = input.color(color.white, title="Target Line Color")
targetLineThickness = input.int(1, title="Target Line Thickness", minval=1, maxval=5)

// Define Shark-32 Pattern
shark32 = low[2] < low[1] and low[1] < low and high[2] > high[1] and high[1] > high

// Initialize color variables for bars
var color barColorCurrent = na
var color barColor1 = na
var color barColor2 = na

// Update color variables based on Shark-32 pattern
barColorCurrent := barcolorEnabled and (shark32 or shark32[1] or shark32[2]) ? barcolorColor : na
barColor1 := barcolorEnabled and (shark32[1] or shark32[2]) ? barcolorColor : na
barColor2 := barcolorEnabled and shark32[2] ? barcolorColor : na

// Apply the bar colors to the chart
barcolor(barColorCurrent, offset=-2, title="Shark-32 Confirmed Current")
barcolor(barColor1, offset=-3, title="Shark-32 Confirmed Previous Bar 1")
barcolor(barColor2, offset=-4, title="Shark-32 Confirmed Previous Bar 2")

// Variables for locking the high and low of confirmed Shark-32
var float patternHigh = na
var float patternLow = na
var float upperTarget = na
var float lowerTarget = na

// Once Shark-32 pattern is confirmed, lock the patternHigh, patternLow, and target lines
if shark32
    patternHigh := high[2]  // The high of the first bar in Shark-32 pattern
    patternLow := low[2]    // The low of the first bar in Shark-32 pattern

    // Calculate the upper and lower white target lines
    upperTarget := patternHigh + (patternHigh - patternLow)  // Dotted white line above
    lowerTarget := patternLow - (patternHigh - patternLow)   // Dotted white line below

// Initialize variables for the lines
var line greenLine = na
var line redLine = na
var line upperTargetLine = na
var line lowerTargetLine = na

// Draw the lines based on the locked patternHigh, patternLow, and target lines
if shark32
    future_bar_index_lines = bar_index + 10

    // Draw lines based on locked patternHigh and patternLow
    greenLine := line.new(x1=bar_index[2], y1=patternHigh, x2=future_bar_index_lines, y2=patternHigh, color=color.green, width=2, extend=extend.none)
    redLine := line.new(x1=bar_index[2], y1=patternLow, x2=future_bar_index_lines, y2=patternLow, color=color.red, width=2, extend=extend.none)

    // Draw dotted white lines if targetLinesEnabled is true
    if targetLinesEnabled
        upperTargetLine := line.new(x1=bar_index[2], y1=upperTarget, x2=future_bar_index_lines, y2=upperTarget, color=targetLineColor, width=targetLineThickness, style=line.style_dotted, extend=extend.none)
        lowerTargetLine := line.new(x1=bar_index[2], y1=lowerTarget, x2=future_bar_index_lines, y2=lowerTarget, color=targetLineColor, width=targetLineThickness, style=line.style_dotted, extend=extend.none)

    // Create a box to fill the background between the red and green lines
    if bgcolorEnabled
        box.new(left=bar_index[2], top=patternHigh, right=future_bar_index_lines, bottom=patternLow, bgcolor=bgcolorColor)

// -------------------------------------------------------------------------
// Strategy Entry and Exit Parameters
// -------------------------------------------------------------------------

// Input parameters for stop loss
longStopLoss = input.float(1.0, title="Long Stop Loss (%)", minval=0.1)  // Percentage-based stop loss for long
shortStopLoss = input.float(1.0, title="Short Stop Loss (%)", minval=0.1)  // Percentage-based stop loss for short

// Variable to track if a trade has been taken
var bool tradeTaken = false

// Reset the flag when a new Shark-32 pattern is confirmed
if shark32
    tradeTaken := false

// Entry conditions only trigger after the Shark-32 is confirmed
longCondition = ta.crossover(close, patternHigh) and not tradeTaken  // Long entry when close crosses above locked patternHigh
shortCondition = ta.crossunder(close, patternLow) and not tradeTaken  // Short entry when close crosses below locked patternLow

// Trigger long and short trades based on the crossover conditions
if (longCondition)
    label.new(bar_index, high, "Long Trigger", style=label.style_label_down, color=color.green, textcolor=color.white, size=size.small)
    strategy.entry("Shark-32 Long", strategy.long)
    tradeTaken := true  // Set the flag to true after a trade is taken

if (shortCondition)
    label.new(bar_index, low, "Short Trigger", style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)
    strategy.entry("Shark-32 Short", strategy.short)
    tradeTaken := true  // Set the flag to true after a trade is taken

// Exit long trade based on the upper target line (upper white dotted line) as take profit
if strategy.position_size > 0
    strategy.exit("Take Profit Long", "Shark-32 Long", limit=upperTarget, stop=close * (1 - longStopLoss / 100))

// Exit short trade based on the lower target line (lower white dotted line) as take profit
if strategy.position_size < 0
    strategy.exit("Take Profit Short", "Shark-32 Short", limit=lowerTarget, stop=close * (1 + shortStopLoss / 100))
````
