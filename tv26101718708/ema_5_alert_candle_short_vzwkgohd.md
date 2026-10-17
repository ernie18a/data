# EMA 5 Alert Candle Short

- url: https://www.tradingview.com/script/vZWkGoHd-EMA-5-Alert-Candle-Short/
- type: strategy
- pine_id: PUB;7e8faba0bc2f444894002ac22ab3e522
- version: 2.0

## Description

The 5 EMA (Exponential Moving Average) Strategy is a simple yet effective trading strategy that helps traders identify short-term trends and potential entry and exit points. This strategy is widely used in intraday and swing trading, particularly in forex, stocks, and crypto markets.

Components of the 5 EMA Strategy
5 EMA: A fast-moving average that reacts quickly to price movements.
15-minute or 1-hour timeframe (commonly used, but adaptable to other timeframes).
Candlestick Patterns: To confirm entry signals.
How the 5 EMA Strategy Works
Buy (Long) Setup:
Price Above the 5 EMA: The price should be trading above the 5 EMA.
Pullback to the 5 EMA: A minor retracement or consolidation near the 5 EMA.
Bullish Candlestick Confirmation: A bullish candle (e.g., engulfing or pin bar) forms near the 5 EMA.
Entry: Enter a long trade at the close of the bullish candle.
Stop Loss: Place below the recent swing low or 5-10 pips below the 5 EMA.
Take Profit: Aim for a risk-reward ratio of at least 1:2 or trail the stop using a higher EMA (e.g., 10 or 20 EMA).
Sell (Short) Setup:
Price Below the 5 EMA: The price should be trading below the 5 EMA.
Pullback to the 5 EMA: A small retracement towards the 5 EMA.
Bearish Candlestick Confirmation: A bearish candle (e.g., engulfing or pin bar) near the 5 EMA.
Entry: Enter a short trade at the close of the bearish candle.
Stop Loss: Place above the recent swing high or 5-10 pips above the 5 EMA.
Take Profit: Aim for a 1:2 risk-reward ratio or use a trailing stop.
Additional Filters for Better Accuracy
Higher Timeframe Confirmation: Check the trend on a higher timeframe (e.g., 1-hour or 4-hour).
Volume Confirmation: Enter trades when volume is increasing.
Avoid Sideways Market: Use the strategy only when the market is trending.
Advantages of the 5 EMA Strategy
✔️ Simple and easy to use.
✔️ Works well in trending markets.
✔️ Helps traders capture short-term momentum.

Disadvantages
❌ Less effective in choppy or sideways markets.
❌ Requires discipline in following stop-loss rules.

## Source Code

````pine
//@version=5
strategy("EMA 5 Alert Candle Short", overlay=true)

// Define EMA
emaLength = 5
emaValue = ta.ema(close, emaLength)

// Risk Management Parameters
capital = 1000
riskPerTrade = 2  // Fixed risk per trade in dollars

// Check if previous candles touched EMA, but the current candle is far above EMA
candleTouchesEMA = low <= emaValue
alertCandle = not candleTouchesEMA[0] and candleTouchesEMA[1] and candleTouchesEMA[2] and candleTouchesEMA[3]

// Persistent Variables to Store Alert Levels
varip float validAlertLow = na
varip float validAlertHigh = na
varip bool isAlertActive = false
varip float positionSize = na
varip float capitalUsed = na

// When an alert candle is identified, store its high and low
if alertCandle
    validAlertLow := low
    validAlertHigh := high
    isAlertActive := true

// Calculate Position Sizing
if isAlertActive
    alertCandleRange = validAlertHigh - validAlertLow
    positionSize := riskPerTrade / alertCandleRange  // Shares or contracts
    capitalUsed := positionSize * validAlertLow      // Capital used in dollars

// Check if the next candle breaks the alert candle low (entry condition)
shortTrigger = isAlertActive and low < validAlertLow
if shortTrigger
    shortEntry = validAlertLow
    stopLoss = validAlertHigh
    target = shortEntry - (stopLoss - shortEntry)
    isAlertActive := false  // Disable alert after trade execution

    // Execute trade
    strategy.entry("Short", strategy.short, qty=positionSize, stop=shortEntry)
    strategy.exit("Take Profit", from_entry="Short", limit=target, stop=stopLoss)

    // Plot trade setup with dotted lines
    line.new(x1=bar_index, y1=shortEntry, x2=bar_index+1, y2=shortEntry, color=color.blue, width=2, style=line.style_dotted)
    line.new(x1=bar_index, y1=stopLoss, x2=bar_index+1, y2=stopLoss, color=color.red, width=2, style=line.style_dotted)
    line.new(x1=bar_index, y1=target, x2=bar_index+1, y2=target, color=color.green, width=2, style=line.style_dotted)

    // Display Capital Used on Chart
    label.new(x=bar_index, y=high, text="Capital: $" + str.tostring(capitalUsed, "#.##"), color=color.white, textcolor=color.black, size=size.small, style=label.style_label_down)

// Reset alert candle if next candle does not break low but also does not touch 5EMA
if not shortTrigger and not candleTouchesEMA[0]
    validAlertLow := low
    validAlertHigh := high
    isAlertActive := true

// Plot EMA
plot(emaValue, title="EMA 5", color=color.blue, linewidth=2)

// Mark alert candle
plotshape(alertCandle, location=location.abovebar, color=color.red, style=shape.labeldown, title="Alert Candle")
````
