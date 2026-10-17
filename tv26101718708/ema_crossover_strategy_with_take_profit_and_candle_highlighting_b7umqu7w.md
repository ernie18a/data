# EMA Crossover Strategy with Take Profit and Candle Highlighting

- url: https://www.tradingview.com/script/B7umqU7W-EMA-Crossover-Strategy-with-Take-Profit-and-Candle-Highlighting/
- type: strategy
- pine_id: PUB;c2749707a8a8470086fc5aaab9d7ac26
- version: 1.0

## Description

Strategy Overview:
This strategy is based on the Exponential Moving Averages (EMA), specifically the EMA 20 and EMA 50. It takes advantage of EMA crossovers to identify potential trend reversals and uses multiple take-profit levels and a stop-loss for risk management.

Key Components:
EMA Crossover Signals:

Buy Signal (Uptrend): A buy signal is generated when the EMA 20 crosses above the EMA 50, signaling the start of a potential uptrend.
Sell Signal (Downtrend): A sell signal is generated when the EMA 20 crosses below the EMA 50, signaling the start of a potential downtrend.
Take Profit Levels:

Once a buy or sell signal is triggered, the strategy calculates multiple take-profit levels based on the range of the previous candle. The user can define multipliers for each take-profit level.
Take Profit 1 (TP1): 50% of the previous candle's range above or below the entry price.
Take Profit 2 (TP2): 100% of the previous candle's range above or below the entry price.
Take Profit 3 (TP3): 150% of the previous candle's range above or below the entry price.
Take Profit 4 (TP4): 200% of the previous candle's range above or below the entry price.
These levels are adjusted dynamically based on the previous candle's high and low, so they adapt to changing market conditions.
Stop Loss:

A stop-loss is set to manage risk. The default stop-loss is 3% from the entry price, but this can be adjusted in the settings. The stop-loss is triggered if the price moves against the position by this amount.
Trend Direction Highlighting:

The strategy highlights the bars (candles) with colors:
Green bars indicate an uptrend (when EMA 20 crosses above EMA 50).
Red bars indicate a downtrend (when EMA 20 crosses below EMA 50).
These visual cues help users easily identify the market direction.
Strategy Entries and Exits:

Entries: The strategy enters a long (buy) position when the EMA 20 crosses above the EMA 50 and a short (sell) position when the EMA 20 crosses below the EMA 50.
Exits: The strategy exits the positions at any of the defined take-profit levels or the stop-loss. Multiple exit levels provide opportunities to take profit progressively as the price moves in the favorable direction.
Entry and Exit Conditions in Detail:
Buy Entry Condition (Uptrend):

A buy position is opened when EMA 20 crosses above EMA 50, signaling the start of an uptrend.
The strategy calculates take-profit levels above the entry price based on the previous bar's range (high-low) and the multipliers for TP1, TP2, TP3, and TP4.
Sell Entry Condition (Downtrend):

A sell position is opened when EMA 20 crosses below EMA 50, signaling the start of a downtrend.
The strategy calculates take-profit levels below the entry price, similarly based on the previous bar's range.
Exit Conditions:

Take Profit: The strategy attempts to exit the position at one of the take-profit levels (TP1, TP2, TP3, or TP4). If the price reaches any of these levels, the position is closed.
Stop Loss: The strategy also has a stop-loss set at a default value (3% below the entry for long trades, and 3% above for short trades). The stop-loss helps to protect the position from significant losses.
Backtesting and Performance Metrics:
The strategy can be backtested using TradingView's Strategy Tester. The results will show how the strategy would have performed historically, including key metrics like:
Net Profit
Max Drawdown
Win Rate
Profit Factor
Average Trade Duration
These performance metrics can help users assess the strategy's effectiveness over historical periods and optimize the input parameters (e.g., multipliers, stop-loss level).
Customization:
The strategy allows for the adjustment of several key input values via the settings panel:
Take Profit Multipliers: Users can customize the multipliers for each take-profit level (TP1, TP2, TP3, TP4).
Stop Loss Percentage: The user can also adjust the stop-loss percentage to a custom value.
EMA Periods: The default periods for the EMA 50 and EMA 20 are fixed, but they can be adjusted for different market conditions.
Pros of the Strategy:
EMA Crossover Strategy: A classic and well-known strategy used by traders to identify the start of new trends.
Multiple Take Profit Levels: By taking profits progressively at different levels, the strategy locks in gains as the price moves in favor of the position.
Clear Trend Identification: The use of green and red bars makes it visually easier to follow the market's direction.
Risk Management: The stop-loss and take-profit features help to manage risk and optimize profit-taking.
Cons of the Strategy:
Lagging Indicators: The strategy relies on EMAs, which are lagging indicators. This means that the strategy might enter trades after the trend has already started, leading to missed opportunities or less-than-ideal entry prices.
No Confirmation Indicators: The strategy purely depends on the crossover of two EMAs and does not use other confirming indicators (e.g., RSI, MACD), which might lead to false signals in volatile markets.
How to Use in Real-Time Trading:
Use for Backtesting: Initially, use this strategy in backtest mode to understand how it would have performed historically with your preferred settings.
Paper Trading: Once comfortable, you can use paper trading to test the strategy in real-time market conditions without risking real money.
Live Trading: After testing and optimizing the strategy, you can consider using it for live trading with proper risk management in place (e.g., starting with a small position size and adjusting parameters as needed).
Summary:
This strategy is designed to identify trend reversals using EMA crossovers, with customizable take-profit levels and a stop-loss to manage risk. It's well-suited for traders looking for a systematic way to enter and exit trades based on clear market signals, while also providing flexibility to adjust for different risk profiles and trading styles.

## Source Code

````pine
//@version=5
strategy("EMA Crossover Strategy with Take Profit and Candle Highlighting", overlay=true)

// Define the EMAs
ema200 = ta.ema(close, 200)
ema50 = ta.ema(close, 50)
ema20 = ta.ema(close, 20)

// Plot the EMAs
plot(ema200, color=#c204898e, title="EMA 200", linewidth=2)
plot(ema50, color=color.blue, title="EMA 50", linewidth=2)
plot(ema20, color=color.orange, title="EMA 20", linewidth=2)

// Define Buy and Sell conditions based on EMA crossover
buySignal = ta.crossover(ema20, ema50)  // EMA 20 crosses above EMA 50 (Bullish)
sellSignal = ta.crossunder(ema20, ema50) // EMA 20 crosses below EMA 50 (Bearish)

// Define input values for Take Profit multipliers
tp1_multiplier = input.float(0.5, title="TP1 Multiplier", minval=0.1, maxval=5.0, step=0.1)
tp2_multiplier = input.float(1.0, title="TP2 Multiplier", minval=0.1, maxval=5.0, step=0.1)
tp3_multiplier = input.float(1.5, title="TP3 Multiplier", minval=0.1, maxval=5.0, step=0.1)
tp4_multiplier = input.float(2.0, title="TP4 Multiplier", minval=0.1, maxval=5.0, step=0.1)

// Define Take Profit Levels as float variables initialized with na
var float takeProfit1 = na
var float takeProfit2 = na
var float takeProfit3 = na
var float takeProfit4 = na

// Calculate take profit levels based on the multipliers
if buySignal
    takeProfit1 := high + (high - low) * tp1_multiplier  // TP1: Set TP at multiplier of previous range above the high
    takeProfit2 := high + (high - low) * tp2_multiplier  // TP2: Set TP at multiplier of previous range above the high
    takeProfit3 := high + (high - low) * tp3_multiplier  // TP3: Set TP at multiplier of previous range above the high
    takeProfit4 := high + (high - low) * tp4_multiplier  // TP4: Set TP at multiplier of previous range above the high

if sellSignal
    takeProfit1 := low - (high - low) * tp1_multiplier  // TP1: Set TP at multiplier of previous range below the low
    takeProfit2 := low - (high - low) * tp2_multiplier  // TP2: Set TP at multiplier of previous range below the low
    takeProfit3 := low - (high - low) * tp3_multiplier  // TP3: Set TP at multiplier of previous range below the low
    takeProfit4 := low - (high - low) * tp4_multiplier  // TP4: Set TP at multiplier of previous range below the low

// Plot Take Profit Levels on the chart
plot(takeProfit1, color=#b4b4b8, style=plot.style_line, linewidth=1, title="Take Profit 1")
plot(takeProfit2, color=#b4b4b8, style=plot.style_line, linewidth=1, title="Take Profit 2")
plot(takeProfit3, color=#b4b4b8, style=plot.style_line, linewidth=1, title="Take Profit 3")
plot(takeProfit4, color=#b4b4b8, style=plot.style_line, linewidth=1, title="Take Profit 4")

// Create buy and sell signals on the chart
plotshape(series=buySignal, location=location.belowbar, color=color.green, style=shape.labelup, title="Buy Signal", text="BUY")
plotshape(series=sellSignal, location=location.abovebar, color=color.red, style=shape.labeldown, title="Sell Signal", text="SELL")

// Highlight the candles based on trend direction
uptrend = ta.crossover(ema20, ema50)  // EMA 20 crosses above EMA 50 (Bullish)
downtrend = ta.crossunder(ema20, ema50)  // EMA 20 crosses below EMA 50 (Bearish)

// Highlighting candles based on trend
bgcolor(color = ema20 > ema50 ? color.new(color.green, 80) : ema20 < ema50 ? color.new(color.red, 80) : na)

// Execute buy and sell orders on the chart
strategy.entry("Buy", strategy.long, when=buySignal)
strategy.entry("Sell", strategy.short, when=sellSignal)

// Exit conditions based on Take Profit levels
strategy.exit("Take Profit 1", "Buy", limit=takeProfit1)
strategy.exit("Take Profit 2", "Buy", limit=takeProfit2)
strategy.exit("Take Profit 3", "Buy", limit=takeProfit3)
strategy.exit("Take Profit 4", "Buy", limit=takeProfit4)

strategy.exit("Take Profit 1", "Sell", limit=takeProfit1)
strategy.exit("Take Profit 2", "Sell", limit=takeProfit2)
strategy.exit("Take Profit 3", "Sell", limit=takeProfit3)
strategy.exit("Take Profit 4", "Sell", limit=takeProfit4)

// Optionally, add a stop loss
stopLoss = 0.03  // Example: 3% stop loss
strategy.exit("Stop Loss", "Buy", stop=close * (1 - stopLoss))
strategy.exit("Stop Loss", "Sell", stop=close * (1 + stopLoss))
````
