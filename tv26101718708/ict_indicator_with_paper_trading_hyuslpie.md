# ICT Indicator with Paper Trading

- url: https://www.tradingview.com/script/hYuSLpIe-ICT-Indicator-with-Paper-Trading/
- type: strategy
- pine_id: PUB;80c6dc3e4df841399047b9e1c1994512
- version: 1.0

## Description

The strategy implemented in the provided Pine Script is based on **ICT (Inner Circle Trader)** concepts, particularly focusing on **order blocks** to identify key levels for potential reversals or continuations in the market. Below is a detailed description of the strategy:

### 1. **Order Block Concept**
- **Order blocks** are price levels where large institutional orders accumulate, often leading to a reversal or continuation of price movement.
- In this strategy, **order blocks** are identified when:
  - The high of the current bar crosses above the high of the previous bar (for bullish order blocks).
  - The low of the current bar crosses below the low of the previous bar (for bearish order blocks).

### 2. **Buy and Sell Signal Generation**
The core of the strategy revolves around identifying the **breakout** of order blocks, which is interpreted as a signal to either enter or exit trades:
- **Buy Signal**:
  - Generated when the closing price crosses **above** the last identified bullish order block (i.e., the highest point during the last upward crossover of highs).
  - This signals a potential upward trend, and the strategy enters a long position.
  
- **Sell Signal**:
  - Generated when the closing price crosses **below** the last identified bearish order block (i.e., the lowest point during the last downward crossover of lows).
  - This signals a potential downward trend, and the strategy exits any open long positions.

### 3. **Strategy Execution**
The strategy is executed using the `strategy.entry()` and `strategy.close()` functions:
- **Enter Long Positions**: When a buy signal is generated, the strategy opens a long position (buying).
- **Exit Positions**: When a sell signal is generated, the strategy closes the long position.

### 4. **Visual Indicators on the Chart**
To make the strategy easier to follow visually, buy and sell signals are marked directly on the chart:
- **Buy signals** are indicated with a green upward-facing triangle above the bar where the signal occurred.
- **Sell signals** are indicated with a red downward-facing triangle below the bar where the signal occurred.

### 5. **Key Elements of the Strategy**
- **Trend Continuation and Reversals**: This strategy is attempting to capture trends based on the breakout of important price levels (order blocks). When the price breaks above or below a significant order block, it is expected that the market will continue in that direction.
- **Order Block Strength**: Order blocks are considered strong areas where price action could reverse or accelerate, based on how institutional investors place large orders.
  
### 6. **Paper Trading**
This script uses **paper trading** to simulate trades without actual money being involved. This allows users to backtest the strategy, seeing how it would have performed in historical market conditions.

### 7. **Basic Strategy Flow**
1. **Order Block Identification**: The script constantly monitors price movements to detect bullish and bearish order blocks.
2. **Buy Signal**: If the closing price crosses above the last order block high, the strategy interprets it as a sign of bullish momentum and enters a long position.
3. **Sell Signal**: If the closing price crosses below the last order block low, it signals a bearish momentum, and the strategy closes the long position.
4. **Visual Representation**: Buy and sell signals are displayed on the chart for easy identification.

### **Advantages of the Strategy:**
- **Simple and Clear Rules**: The strategy is based on clearly defined rules for identifying order blocks and trade signals.
- **Effective for Trend Following**: By focusing on breakouts of order blocks, this strategy attempts to capture strong trends in the market.
- **Visual Aids**: The plot of buy/sell signals helps traders to quickly see where trades would have been placed.

### **Limitations:**
- **No Shorting**: This strategy only enters long positions (buying). It does not account for shorting opportunities.
- **No Risk Management**: There are no built-in stop losses, trailing stops, or profit targets, which could expose the strategy to large losses during adverse market conditions.
- **Whipsaws in Range Markets**: The strategy could produce false signals in sideways or choppy markets, where breakouts are short-lived and prices quickly reverse.

### **Overall Strategy Objective:**
The goal of the strategy is to enter into long positions when the price breaks above a significant order block, and exit when it breaks below. The strategy is designed for trend-following, with the assumption that price will continue in the direction of the breakout.

Let me know if you'd like to enhance or modify this strategy further!

## Source Code

````pine
//@version=5
strategy("ICT Indicator with Paper Trading", overlay=true)

// Order Blocks
order_block_high = ta.valuewhen(ta.crossover(high, high[1]), high, 1)
order_block_low = ta.valuewhen(ta.crossover(low, low[1]), low, 1)

// ... (other indicators)

// Buy and Sell Signals
buy_signal = ta.crossover(close, order_block_high)
sell_signal = ta.crossover(order_block_low, close)

// Plot Signals
plotshape(buy_signal, location=location.abovebar, style=shape.triangleup, color=color.lime, size=size.small)
plotshape(sell_signal, location=location.belowbar, style=shape.triangledown, color=color.red, size=size.small)

// Paper Trading
strategy.entry("Buy", strategy.long, when=buy_signal)
strategy.close("Buy", when=sell_signal)
````
