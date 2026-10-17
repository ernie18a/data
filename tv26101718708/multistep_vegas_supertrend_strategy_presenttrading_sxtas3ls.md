# Multi-Step Vegas SuperTrend - strategy [presentTrading]

- url: https://www.tradingview.com/script/SXtas3lS-Multi-Step-Vegas-SuperTrend-strategy-presentTrading/
- type: strategy
- pine_id: PUB;443466768b5f4e379b55ea28227b6b66
- version: 2.0

## Description

Long time no see! I am back : ) Please allow me to gain some warm-up.

█ Introduction and How it is Different

The "Vegas SuperTrend Strategy" is an enhanced trading strategy that leverages both the Vegas Channel and SuperTrend indicators to generate buy and sell signals. 

What sets this strategy apart from others is its dynamic adjustment to market volatility and its multi-step take profit mechanism. Unlike traditional single-step profit-taking approaches, this strategy allows traders to systematically scale out of positions at predefined profit levels, thereby optimizing their risk-reward ratio and maximizing potential gains.

BTCUSD 6hr performance
[image]https://www.tradingview.com/x/ifgFWRB6/[/image]

█ Strategy, How it Works: Detailed Explanation

The Vegas SuperTrend Strategy combines the strengths of the Vegas Channel and SuperTrend indicators to identify market trends and generate trade signals. The following subsections delve into the details of how each component works and how they are integrated.

🔶 Vegas Channel Calculation

The Vegas Channel is based on a simple moving average (SMA) and the standard deviation (STD) of the closing prices over a specified period. The channel is defined by upper and lower bounds that are dynamically adjusted based on market volatility.

Simple Moving Average (SMA):
SMA_vegas = (1/N) * Σ(Close_i) for i = 0 to N-1
where N is the length of the Vegas Window.

Standard Deviation (STD):
STD_vegas = sqrt((1/N) * Σ(Close_i - SMA_vegas)^2) for i = 0 to N-1

Vegas Channel Upper and Lower Bounds:
VegasChannelUpper = SMA_vegas + STD_vegas
VegasChannelLower = SMA_vegas - STD_vegas

The details are here:
[url=https://www.tradingview.com/script/ec57c7xL-Vegas-SuperTrend-Enhanced-Strategy-presentTrading/]https://www.tradingview.com/script/ec57c7xL-Vegas-SuperTrend-Enhanced-Strategy-presentTrading/[/url]

🔶 Trend Detection and Trade Signals

The strategy determines the current market trend based on the closing price relative to the SuperTrend bounds:

Market Trend:
MarketTrend = 1 if Close > SuperTrendPrevLower
              -1 if Close < SuperTrendPrevUpper
              Previous Trend otherwise

Trade signals are generated when there is a shift in the market trend:
Bullish Signal: When the market trend shifts from -1 to 1.
Bearish Signal: When the market trend shifts from 1 to -1.

🔶 Multi-Step Take Profit Mechanism

The strategy incorporates a multi-step take profit mechanism that allows for partial exits at predefined profit levels. This helps in locking in profits gradually and reducing exposure to market reversals.

Take Profit Levels:
The take profit levels are calculated as percentages of the entry price:
TakeProfitLevel_i = EntryPrice * (1 + TakeProfitPercent_i/100) for long positions
TakeProfitLevel_i = EntryPrice * (1 - TakeProfitPercent_i/100) for short positions

Multi-steps take profit local picture:
[image]https://www.tradingview.com/x/VMe1nNXu/[/image]

█ Trade Direction

The trade direction can be customized based on the user's preference:
Long: The strategy only takes long positions.
Short: The strategy only takes short positions.
Both: The strategy can take both long and short positions based on the market trend.

█ Usage

To use the Vegas SuperTrend Strategy, follow these steps:

Configure Input Settings:
   - Set the ATR period, Vegas Window length, SuperTrend Multiplier, and Volatility Adjustment Factor.
   - Choose the desired trade direction (Long, Short, Both).
   - Enable or disable the take profit mechanism and set the take profit percentages and amounts for each step.

█ Default Settings

The default settings of the strategy are designed to provide a balanced approach to trading. Below is an explanation of each setting and its effect on the strategy's performance:

ATR Period (10): This setting determines the length of the ATR used in the SuperTrend calculation. A longer period smoothens the ATR, making the SuperTrend less sensitive to short-term volatility. A shorter period makes the SuperTrend more responsive to recent price movements.

Vegas Window Length (100): This setting defines the period for the Vegas Channel's moving average. A longer window provides a broader view of the market trend, while a shorter window makes the channel more responsive to recent price changes.

SuperTrend Multiplier (5): This base multiplier adjusts the sensitivity of the SuperTrend to the ATR. A higher multiplier makes the SuperTrend less sensitive, reducing the frequency of trade signals. A lower multiplier increases sensitivity, generating more signals.

Volatility Adjustment Factor (5): This factor dynamically adjusts the SuperTrend multiplier based on the width of the Vegas Channel. A higher factor increases the sensitivity of the SuperTrend to changes in market volatility, while a lower factor reduces it.

Take Profit Percentages (3.0%, 6.0%, 12.0%, 21.0%): These settings define the profit levels at which portions of the trade are exited. They help in locking in profits progressively as the trade moves in favor.

Take Profit Amounts (25%, 20%, 10%, 15%): These settings determine the percentage of the position to exit at each take profit level. They are distributed to ensure that significant portions of the trade are closed as the price reaches the set levels, reducing exposure to reversals.

Adjusting these settings can significantly impact the strategy's performance. For instance, increasing the ATR period or the SuperTrend multiplier can reduce the number of trades, potentially improving the win rate but also missing out on some profitable opportunities. Conversely, lowering these values can increase trade frequency, capturing more short-term movements but also increasing the risk of false signals.

## Source Code

````pine
//@version=5
strategy("Multi-Step Vegas SuperTrend - strategy [presentTrading]", shorttitle="Multi-Step Vegas SuperTrend - strategy [presentTrading]", overlay=true, precision=3, commission_value=0.1, commission_type=strategy.commission.percent, slippage=1, currency=currency.USD, default_qty_type=strategy.percent_of_equity, default_qty_value=10, initial_capital=10000)

// Input settings allow the user to customize the strategy's parameters.
tradeDirectionChoice = input.string(title="Trade Direction", defval="Both", options=["Long", "Short", "Both"]) // Option to select the trading direction
atrPeriod = input(10, "ATR Period for SuperTrend") // Length of the ATR for volatility measurement
vegasWindow = input(100, "Vegas Window Length") // Length of the moving average for the Vegas Channel
superTrendMultiplier = input(5, "SuperTrend Multiplier Base") // Base multiplier for the SuperTrend calculation
volatilityAdjustment = input.float(5, "Volatility Adjustment Factor") // Factor to adjust the SuperTrend sensitivity to the Vegas Channel width

// Moving Average Selection
maType = input.string(title="Moving Average Type", defval="SMA", options=["SMA", "JMA", "VIDYA"])

// User inputs for take profit settings
useTakeProfit = input.bool(true, title="Use Take Profit", group="Take Profit Settings")
takeProfitPercent1 = input.float(3.0, title="Take Profit % Step 1", group="Take Profit Settings")
takeProfitPercent2 = input.float(6.0, title="Take Profit % Step 2", group="Take Profit Settings")
takeProfitPercent3 = input.float(12.0, title="Take Profit % Step 3", group="Take Profit Settings")
takeProfitPercent4 = input.float(21.0, title="Take Profit % Step 4", group="Take Profit Settings")

takeProfitAmount1 = input.float(25, title="Take Profit Amount % Step 1", group="Take Profit Settings")
takeProfitAmount2 = input.float(20, title="Take Profit Amount % Step 2", group="Take Profit Settings")
takeProfitAmount3 = input.float(10, title="Take Profit Amount % Step 3", group="Take Profit Settings")
takeProfitAmount4 = input.float(15, title="Take Profit Amount % Step 4", group="Take Profit Settings")

numberOfSteps = input.int(4, title="Number of Take Profit Steps", minval=1, maxval=4, group="Take Profit Settings")

// Function to calculate JMA (Jurik Moving Average)
jma(src, length, phase) =>
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5
    beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    alpha = math.pow(beta, phaseRatio)
    jmaVal = 0.0
    e0 = 0.0
    e1 = 0.0
    e2 = 0.0
    e3 = 0.0
    e0 := (1 - alpha) * src + alpha * nz(e0[1])
    e1 := (src - e0) * (1 - beta) + beta * nz(e1[1])
    e2 := (e0 + e1) * (1 - beta) + beta * nz(e2[1])
    e3 := e2
    jmaVal := e3
    jmaVal

// Function to calculate VIDYA (Variable Index Dynamic Average)
vidya(src, length, cmoLength) =>
    change = math.abs(src - src[1])
    momentum = math.sum(change, cmoLength)
    volatility = math.sum(math.abs(src - src[1]), cmoLength)
    CMO = volatility != 0 ? momentum / volatility : 0
    smoothingConstant = 2 / (length + 1)
    scaledSC = smoothingConstant * math.abs(CMO)
    vidyaVal = 0.0
    vidyaVal := scaledSC * src + (1 - scaledSC) * nz(vidyaVal[1], src)
    vidyaVal

// Calculate the selected Moving Average for the Vegas Channel
vegasMovingAverage = switch maType
    "SMA" => ta.sma(close, vegasWindow)
    "JMA" => jma(close, vegasWindow, 0)  // Using phase = 0 for JMA
    "VIDYA" => vidya(close, vegasWindow, 9)  // Using cmoLength = 9 for VIDYA

// Calculate the standard deviation for the Vegas Channel
vegasChannelStdDev = ta.stdev(close, vegasWindow)

// Upper and lower bands of the Vegas Channel
vegasChannelUpper = vegasMovingAverage + vegasChannelStdDev
vegasChannelLower = vegasMovingAverage - vegasChannelStdDev

// Adjust the SuperTrend multiplier based on the width of the Vegas Channel.
channelVolatilityWidth = vegasChannelUpper - vegasChannelLower
adjustedMultiplier = superTrendMultiplier + volatilityAdjustment * (channelVolatilityWidth / vegasMovingAverage)

// Calculate the SuperTrend indicator values.
averageTrueRange = ta.atr(atrPeriod)
superTrendUpper = hlc3 - (adjustedMultiplier * averageTrueRange)
superTrendLower = hlc3 + (adjustedMultiplier * averageTrueRange)
var float superTrendPrevUpper = na
var float superTrendPrevLower = na
var int marketTrend = 1

// Update SuperTrend values and determine the current trend direction.
superTrendPrevUpper := nz(superTrendPrevUpper[1], superTrendUpper)
superTrendPrevLower := nz(superTrendPrevLower[1], superTrendLower)
marketTrend := close > superTrendPrevLower ? 1 : close < superTrendPrevUpper ? -1 : nz(marketTrend[1], 1)
superTrendUpper := marketTrend == 1 ? math.max(superTrendUpper, superTrendPrevUpper) : superTrendUpper
superTrendLower := marketTrend == -1 ? math.min(superTrendLower, superTrendPrevLower) : superTrendLower
superTrendPrevUpper := superTrendUpper
superTrendPrevLower := superTrendLower

// Enhanced Visualization
// Plot the SuperTrend and Vegas Channel for visual analysis.
plot(marketTrend == 1 ? superTrendUpper : na, "SuperTrend Upper", color=color.green, linewidth=2)
plot(marketTrend == -1 ? superTrendLower : na, "SuperTrend Lower", color=color.red, linewidth=2)
plot(vegasChannelUpper, "Vegas Upper", color=color.purple, linewidth=1)
plot(vegasChannelLower, "Vegas Lower", color=color.purple, linewidth=1)

// Apply a color to the price bars based on the current market trend.
barcolor(marketTrend == 1 ? color.new(color.green, 0) : marketTrend == -1 ? color.new(color.red, 0) : na)

// Detect trend direction changes and plot entry/exit signals.
trendShiftToBullish = marketTrend == 1 and marketTrend[1] == -1
trendShiftToBearish = marketTrend == -1 and marketTrend[1] == 1

plotshape(series=trendShiftToBullish, title="Enter Long", location=location.belowbar, color=color.green, style=shape.labelup, text="Buy")
plotshape(series=trendShiftToBearish, title="Enter Short", location=location.abovebar, color=color.red, style=shape.labeldown, text="Sell")

// Define conditions for entering long or short positions, and execute trades based on these conditions.
enterLongCondition = marketTrend == 1
enterShortCondition = marketTrend == -1

// Check trade direction choice before executing trade entries.
if enterLongCondition and (tradeDirectionChoice == "Long" or tradeDirectionChoice == "Both")
    strategy.entry("Long Position", strategy.long)

if enterShortCondition and (tradeDirectionChoice == "Short" or tradeDirectionChoice == "Both")
    strategy.entry("Short Position", strategy.short)

// Close all positions when the market trend changes.
if marketTrend != marketTrend[1]
    strategy.close_all()

// Multi-Stage Take Profit Logic
if (strategy.position_size > 0)
    entryPrice = strategy.opentrades.entry_price(strategy.opentrades - 1)
    if numberOfSteps >= 1
        strategy.exit("Take Profit 1", from_entry="Long Position", qty_percent=takeProfitAmount1, limit=entryPrice * (1 + takeProfitPercent1 / 100))
    if numberOfSteps >= 2
        strategy.exit("Take Profit 2", from_entry="Long Position", qty_percent=takeProfitAmount2, limit=entryPrice * (1 + takeProfitPercent2 / 100))
    if numberOfSteps >= 3
        strategy.exit("Take Profit 3", from_entry="Long Position", qty_percent=takeProfitAmount3, limit=entryPrice * (1 + takeProfitPercent3 / 100))
    if numberOfSteps >= 4
        strategy.exit("Take Profit 4", from_entry="Long Position", qty_percent=takeProfitAmount4, limit=entryPrice * (1 + takeProfitPercent4 / 100))

if (strategy.position_size < 0)
    entryPrice = strategy.opentrades.entry_price(strategy.opentrades - 1)
    if numberOfSteps >= 1
        strategy.exit("Take Profit 1", from_entry="Short Position", qty_percent=takeProfitAmount1, limit=entryPrice * (1 - takeProfitPercent1 / 100))
    if numberOfSteps >= 2
        strategy.exit("Take Profit 2", from_entry="Short Position", qty_percent=takeProfitAmount2, limit=entryPrice * (1 - takeProfitPercent2 / 100))
    if numberOfSteps >= 3
        strategy.exit("Take Profit 3", from_entry="Short Position", qty_percent=takeProfitAmount3, limit=entryPrice * (1 - takeProfitPercent3 / 100))
    if numberOfSteps >= 4
        strategy.exit("Take Profit 4", from_entry="Short Position", qty_percent=takeProfitAmount4, limit=entryPrice * (1 - takeProfitPercent4 / 100))
````
