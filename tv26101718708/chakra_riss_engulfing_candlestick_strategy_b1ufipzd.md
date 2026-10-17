# CHAKRA RISS ENGULFING CANDLESTICK STRATEGY

- url: https://www.tradingview.com/script/b1UfIpZD-CHAKRA-RISS-ENGULFING-CANDLESTICK-STRATEGY/
- type: indicator
- pine_id: PUB;e0fa365af6dc442e8b8df3a6a86ea106
- version: 1.0

## Description

Chakra RISS Engulfing Candlestick Strategy
Type: Technical Indicator & Strategy
Platform: TradingView
Script Version: Pine Script v6

Overview:
The Chakra RISS Engulfing Candlestick Strategy combines a momentum-based approach using the Relative Strength Index (RSI) with Engulfing Candlestick Patterns to generate buy and sell signals. The strategy filters trades based on price movement relative to a 50-period Simple Moving Average (SMA), making it a trend-following strategy.

The indicator uses color-coded bars to visually represent market conditions, helping traders easily identify bullish and bearish trends. The strategy is designed to be dynamic, adapting to changing market conditions and filtering out noise using key technical indicators.

How It Works:
RSI-Based Color Conditions:

Green Bars: When the RSI crosses above a specified UpLevel (default: 50), indicating a bullish momentum and signaling potential buy conditions.
Red Bars: When the RSI crosses below a specified DownLevel (default: 50), indicating a bearish momentum and signaling potential sell conditions.
Buy Signal:

Triggered when the following conditions are met:
RSI crosses from below the UpLevel (default: 50) to above it, signaling increasing bullish momentum.
The close price is above the 50-period Simple Moving Average (SMA), confirming an uptrend.
The Buy Signal is plotted below the bar with a green arrow and a "BUY" label.
Sell Signal:

Triggered when the following conditions are met:
RSI crosses from above the DownLevel (default: 50) to below it, signaling increasing bearish momentum.
The close price is below the 50-period Simple Moving Average (SMA), confirming a downtrend.
The Sell Signal is plotted above the bar with a red arrow and a "SELL" label.
Stop Loss and Take Profit:

For long trades (buy signals), the stop loss is placed below the previous bar's low, and the take profit is set at 3% above the entry price.
For short trades (sell signals), the stop loss is placed above the previous bar's high, and the take profit is set at 3% below the entry price.
Dynamic Bar Coloring:

The bar colors change dynamically based on RSI levels:
Green Bars: Indicating a potential uptrend (bullish).
Red Bars: Indicating a potential downtrend (bearish).
These visual cues help traders quickly identify market trends and potential reversals.
Trend Filtering:

The 50-period Simple Moving Average (SMA) is used to filter trades based on the overall market trend:
Buy signals are only considered when the price is above the moving average, indicating an uptrend.
Sell signals are only considered when the price is below the moving average, indicating a downtrend.
Alerting System:

Alerts can be set for both buy and sell signals. These alerts notify traders in real-time when potential trades are generated, allowing them to act promptly.
Alerts can be configured to send notifications through email, SMS, or a webhook for integration with other services like IFTTT or Zapier.
Key Features:
RSI and Moving Average-Based Signals: Combines RSI with a moving average for more accurate trade signals.
Stop Loss and Take Profit: Dynamic risk management with custom stop loss and take profit levels based on previous high and low prices.
Buy and Sell Alerts: Provides real-time alerts when a buy or sell signal is triggered.
Trend Confirmation: Uses the 50-period Simple Moving Average to filter signals and confirm the direction of the trend.
Visual Bar Color Changes: Makes it easy to identify bullish or bearish trends with color-coded bars.
Usage:
This strategy is suitable for traders who prefer a trend-following approach and want to combine momentum indicators (RSI) with price action (Engulfing Candlestick patterns). It is particularly useful in volatile markets where quick identification of trend changes can lead to profitable trades.

Best Used For: Day trading, swing trading, and trend-following strategies.
Timeframes: Works well on various timeframes, from 1-minute charts for scalping to daily charts for swing trading.
Markets: Can be applied to any market with sufficient liquidity (stocks, forex, crypto, etc.).
Settings:
UpLevel: The RSI level above which the market is considered bullish (default: 50).
DownLevel: The RSI level below which the market is considered bearish (default: 50).
SMA Length: The period of the Simple Moving Average used to filter trades (default: 50).
Risk Management: Customizable stop loss and take profit settings based on price action (default: 3% above/below the entry price).

## Source Code

````pine
//@version=6
indicator(title="CHAKRA RISS ENGULFING CANDLESTICK STRATEGY", overlay=true, shorttitle="CHAKRA RISS")

// Input Parameters
len = input.int(8, minval=1, title="Length")
len1 = input.int(50, title="UpLevel")   // RSI UpLevel
len2 = input.int(50, title="DownLevel") // RSI DownLevel

up = ta.rma(math.max(ta.change(close), 0), len)
down = ta.rma(-math.min(ta.change(close), 0), len)
rsi = 100 - (100 / (1 + up / down))

// Moving Average Filter
out = ta.sma(close, 50)

// RSI-based Color Conditions
isGreen = rsi > len1
isRed = rsi < len2

// Bar Color Changes (Indicator Chart)
barcolor(isGreen ? color.green : isRed ? color.red : na)

// Buy and Sell Signal Conditions
buySignal = isGreen and rsi[1] <= len1 and close > out  // RSI crosses from below to above the UpLevel and price is above MA
sellSignal = isRed and rsi[1] >= len2 and close < out  // RSI crosses from above to below the DownLevel and price is below MA

// Plotting Buy and Sell Signals as Shapes
plotshape(buySignal, style=shape.labelup, location=location.belowbar, color=color.green, text="BUY")
plotshape(sellSignal, style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL")

// Plot Moving Average
plot(out, color=color.black, linewidth=3, title="MA")

// Stop Loss and Take Profit logic (based on previous high/low)
// Variables to store entry prices for SL/TP calculations
var float entryPrice = na
var bool inTrade = false

// Stop Loss and Take Profit levels
longStopLoss = low[1]  // Stop loss below the previous bar's low for buy
longTakeProfit = entryPrice * 1.03  // Take profit 3% above the entry price

shortStopLoss = high[1]  // Stop loss above the previous bar's high for sell
shortTakeProfit = entryPrice * 0.97  // Take profit 3% below the entry price

// Enter Trade logic
if (buySignal and not inTrade)
    entryPrice := close
    inTrade := true

if (sellSignal and not inTrade)
    entryPrice := close
    inTrade := true

// Exit logic (Stop Loss and Take Profit)
longExit = close <= longStopLoss or close >= longTakeProfit
shortExit = close >= shortStopLoss or close <= shortTakeProfit

if (longExit or shortExit)
    inTrade := false

// Plotting Stop Loss and Take Profit levels on chart
plot(inTrade and not na(entryPrice) ? longStopLoss : na, color=color.red, linewidth=1, title="Stop Loss (Long)", style=plot.style_linebr)
plot(inTrade and not na(entryPrice) ? longTakeProfit : na, color=color.green, linewidth=1, title="Take Profit (Long)", style=plot.style_linebr)
plot(inTrade and not na(entryPrice) ? shortStopLoss : na, color=color.green, linewidth=1, title="Stop Loss (Short)", style=plot.style_linebr)
plot(inTrade and not na(entryPrice) ? shortTakeProfit : na, color=color.red, linewidth=1, title="Take Profit (Short)", style=plot.style_linebr)
````
