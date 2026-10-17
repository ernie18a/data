# Fixed RSI Buy Sell Signals

- url: https://www.tradingview.com/script/GfVFlZbX-Fixed-RSI-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;5e4b4ccbc6dd412e8545965ee422731b
- version: 1.0

## Description

1. RSI Buy Signal

The indicator generates a BUY signal when the Relative Strength Index (RSI) crosses above the 30 level.

RSI<30

This condition usually indicates that the stock was previously oversold and may be starting a bullish reversal. A green BUY label appears below the candle to clearly mark the entry opportunity.

2. RSI Sell Signal

The indicator generates a SELL signal when RSI crosses below the 70 level.

RSI>70

This indicates the stock was previously overbought and may begin a bearish correction or reversal. A red SELL label appears above the candle.

3. Trend Detection System

The script uses Exponential Moving Averages (EMA) to determine the overall market trend.

EMA
50
	​

>EMA
200
	​


When the 50 EMA is above the 200 EMA, the indicator identifies an UP TREND.
When the 50 EMA is below the 200 EMA, it identifies a DOWN TREND.

This helps traders avoid taking trades against the dominant trend direction.

4. Dynamic Trend Status Box

A floating trend box is displayed near the latest candle showing:

UP TREND in green
DOWN TREND in red

This gives instant visual confirmation of current market momentum without needing to manually inspect moving averages.

5. EMA Visualization

The indicator also plots:

50 EMA (green)
200 EMA (red)

These moving averages help traders:

Identify long-term trend direction
Detect support and resistance zones
Confirm momentum
Spot potential EMA crossovers
Trading Strategy Idea
Buy Setup

A stronger bullish setup occurs when:

RSI crosses above 30
BUY signal appears
50 EMA is above 200 EMA
Price starts closing above short-term resistance
Sell Setup

A stronger bearish setup occurs when:

RSI crosses below 70
SELL signal appears
50 EMA is below 200 EMA
Price breaks below support
Best Timeframes

This indicator works effectively on:

5-minute chart for intraday trading
15-minute chart for scalping
1-hour chart for swing entries
Daily chart for positional trading
Best Market Conditions

The indicator performs best in:

Trending markets
Momentum breakouts
Swing reversal setups
Stocks respecting EMA support/resistance

It may produce more false signals during highly sideways or consolidating markets.

Suitable For
Swing traders
Intraday traders
Trend-following traders
Beginner traders learning RSI and EMA strategies
Momentum traders
Advantages
Simple visual signals
Easy trend identification
Works on all stocks and crypto charts
Reduces emotional trading
Combines momentum and trend together
Clean chart appearance

## Source Code

````pine
//@version=5
indicator("Fixed RSI Buy Sell Signals", overlay=true)

// RSI Settings
rsiLength = input.int(14, title="RSI Length")
buyLevel  = input.int(30, title="Buy Level")
sellLevel = input.int(70, title="Sell Level")

// RSI Calculation
rsiValue = ta.rsi(close, rsiLength)

// Signals
buySignal  = ta.crossover(rsiValue, buyLevel)
sellSignal = ta.crossunder(rsiValue, sellLevel)

// BUY Signal near candle
plotshape(
     buySignal,
     title="BUY",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY",
     textcolor=color.white,
     size=size.small,
     offset=0)

// SELL Signal near candle
plotshape(
     sellSignal,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL",
     textcolor=color.white,
     size=size.small,
     offset=0)
````
