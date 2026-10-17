# Elliott's Quadratic Momentum - Strategy [presentTrading]

- url: https://www.tradingview.com/script/warXbPtA-Elliott-s-Quadratic-Momentum-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;f02a049f8a0a46f58925fa1ee2fcdc41
- version: 2.0

## Description

█ Introduction and How It Is Different

The "Elliott's Quadratic Momentum - Strategy" is a unique and innovative approach in the realm of technical trading. This strategy is a fusion of multiple SuperTrend indicators combined with an Elliott Wave-like pattern analysis, offering a comprehensive and dynamic trading tool. It stands apart from conventional strategies by incorporating multiple layers of trend analysis, thereby providing a more robust and nuanced view of market movements.

*Although the script doesn't explicitly analyze Elliott Wave patterns, it employs a wave-like approach by considering multiple SuperTrend indicators. Elliott Wave theory is based on the premise that markets move in predictable wave patterns. While this script doesn't identify specific Elliott Wave structures like impulsive and corrective waves, the sequential checking of trend conditions across multiple SuperTrend indicators mimics a wave-like progression.

BTC 8hr Long/Short Performance
[image]https://www.tradingview.com/x/TLwmEWnX/[/image]

Local Detail
[image]https://www.tradingview.com/x/z2EoXox4/[/image]

█ Strategy, How It Works: Detailed Explanation

The core of this strategy lies in its multi-tiered approach:

[b]1. Multiple SuperTrend Indicators:[/b]

The strategy employs four different SuperTrend indicators, each with unique ATR lengths and multipliers. These indicators offer various perspectives on market trends, ranging from short to long-term views.
By analyzing the convergence of these indicators, the strategy can pinpoint robust entry signals for both long and short positions.

[b]2. Elliott Wave-like Pattern Recognition:[/b]

While not directly applying Elliott Wave theory, the strategy takes inspiration from its pattern recognition approach. It looks for alignments in market movements that resemble the characteristic waves of Elliott's theory.
This pattern recognition aids in confirming the signals provided by the SuperTrend indicators, adding an extra layer of validation to the trading signals.

[b]3. Comprehensive Market Analysis:[/b]

By combining multiple indicators and pattern analysis, the strategy offers a holistic view of the market. This allows for capturing potential trend reversals and significant market moves early.

█ Trade Direction

The strategy is designed with flexibility in mind, allowing traders to select their preferred trading direction – Long, Short, or Both. This adaptability is key for traders looking to tailor their approach to different market conditions or personal trading styles. The strategy automatically adjusts its logic based on the chosen direction, ensuring that traders are always aligned with their strategic objectives.

█ Usage

To utilize the "Elliott's Quadratic Momentum - Strategy" effectively:
Traders should first determine their trading direction and adjust the SuperTrend settings according to their market analysis and risk appetite.
The strategy is versatile and can be applied across various time frames and asset classes, making it suitable for a wide range of trading scenarios.
It's particularly effective in trending markets, where the alignment of multiple SuperTrend indicators can provide strong trade signals.

█ Default Settings

Trading Direction: Configurable (Long, Short, Both)
SuperTrend Settings:
SuperTrend 1: ATR Length 7, Multiplier 4.0
SuperTrend 2: ATR Length 14, Multiplier 3.618
SuperTrend 3: ATR Length 21, Multiplier 3.5
SuperTrend 4: ATR Length 28, Multiplier 3.382
Additional Settings: Gradient effect for trend visualization, customizable color schemes for upward and downward trends.

## Source Code

````pine
//@version=5
//@presenttrading

//the Elliott's Quadratic Momentum (EQM) strategy stands out as a sophisticated tool for traders. This strategy, unlike traditional methods, 
// combines Elliott Wave theory with advanced SuperTrend indicators. 
// Its unique approach lies in utilizing quadratic momentum calculations, offering a more nuanced and dynamic analysis of market trends.

strategy("Elliott's Quadratic Momentum - Strategy [presentTrading]",shorttitle = "EQM Strategy [presentTrading]", overlay=true, precision=3, default_qty_type=strategy.cash, 
 commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, 
  currency=currency.USD, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, initial_capital= 10000)

// Inputs for selecting trading direction
tradingDirection = input.string("Both", "Select Trading Direction", options=["Long", "Short", "Both"])


// SuperTrend Function
supertrend(src, atrLength, multiplier) =>
    atr = ta.atr(atrLength)
    up = hl2 - (multiplier * atr)
    dn = hl2 + (multiplier * atr)
    trend = 1
    trend := nz(trend[1], 1)
    up := src > nz(up[1], 0) and src[1] > nz(up[1], 0) ?   math.max(up, nz(up[1], 0)) : up
    dn := src < nz(dn[1], 0) and src[1] < nz(dn[1], 0) ? math.min(dn, nz(dn[1], 0)) : dn
    trend := src > nz(dn[1], 0) ?  1 : src < nz(up[1], 0)? -1 : nz(trend[1], 1)
    [up, dn, trend]

// Inputs for SuperTrend settings
atrLength1 = input(7, title="ATR Length for SuperTrend 1")
multiplier1 = input(4.0, title="Multiplier for SuperTrend 1")
atrLength2 = input(14, title="ATR Length for SuperTrend 2")
multiplier2 = input(3.618, title="Multiplier for SuperTrend 2")
atrLength3 = input(21, title="ATR Length for SuperTrend 3")
multiplier3 = input(3.5, title="Multiplier for SuperTrend 3")
atrLength4 = input(28, title="ATR Length for SuperTrend 3")
multiplier4 = input(3.382, title="Multiplier for SuperTrend 3")

// Calculate SuperTrend
[up1, dn1, trend1] = supertrend(close, atrLength1, multiplier1)
[up2, dn2, trend2] = supertrend(close, atrLength2, multiplier2)
[up3, dn3, trend3] = supertrend(close, atrLength3, multiplier3)
[up4, dn4, trend4] = supertrend(close, atrLength4, multiplier4)


// Entry Conditions based on SuperTrend and Elliott Wave-like patterns
longCondition = trend1 == 1 and trend2 == 1 and trend3 == 1 and trend4 == 1
shortCondition = trend1 == -1 and trend2 == -1 and trend3 == -1 and trend4 == - 1


// Exit conditions - Define your own exit strategy
// Example: Exit when any SuperTrend flips
LongExit =  trend1 != trend1[1] or trend2 != trend2[1] or trend3 != trend3[1] or trend4 != trend4[1] 
ShortExit = trend1 != trend1[1] or trend2 != trend2[1] or trend3 != trend3[1] or trend4 != trend4[1] 

if tradingDirection == "Long" or tradingDirection == "Both"
    if longCondition
        strategy.entry("Long Entry", strategy.long)
    if LongExit
        strategy.close("Long Entry")

if tradingDirection == "Short" or tradingDirection == "Both"
    if shortCondition
        strategy.entry("Short Entry", strategy.short)
    if ShortExit
        strategy.close("Short Entry")

// Define entry alert conditions
alertcondition(longCondition, title="Long Entry Alert", message="Long Entry Condition Met")
alertcondition(shortCondition, title="Short Entry Alert", message="Short Entry Condition Met")

// Define exit alert conditions
alertcondition(LongExit, title="Long Exit Alert", message="Long Exit Condition Met")
alertcondition(ShortExit, title="Short Exit Alert", message="Short Exit Condition Met")

// Plotting
// Function to apply gradient effect
gradientColor(baseColor, length, currentBar) =>
    var color res = color.new(baseColor, 100)
    if currentBar <= length
        res := color.new(baseColor, int(100 * currentBar / length))
    res

// Apply gradient effect
color1 = gradientColor(color.blue, atrLength1, bar_index % atrLength1)
color4 = gradientColor(color.blue, atrLength4, bar_index % atrLength3)


// Plot SuperTrend with gradient for upward trend
plot1Up = plot(trend1 == 1 ? up1 : na, color=color1, linewidth=1, title="SuperTrend 1 Up")
plot4Up = plot(trend4 == 1 ? up4 : na, color=color4, linewidth=1, title="SuperTrend 3 Up")

// Plot SuperTrend with gradient for downward trend
plot1Down = plot(trend1 == -1 ? dn1 : na, color=color1, linewidth=1, title="SuperTrend 1 Down")
plot4Down = plot(trend4 == -1 ? dn4 : na, color=color4, linewidth=1, title="SuperTrend 3 Down")

// Filling the area between the first and third SuperTrend lines for upward trend
fill(plot1Up, plot4Up, color=color.new(color.green, 80), title="SuperTrend Upward Band")

// Filling the area between the first and third SuperTrend lines for downward trend
fill(plot1Down, plot4Down, color=color.new(color.red, 80), title="SuperTrend Downward Band")
````
