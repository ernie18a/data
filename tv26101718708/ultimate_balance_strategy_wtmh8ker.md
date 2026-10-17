# Ultimate Balance Strategy

- url: https://www.tradingview.com/script/WTmh8KER-Ultimate-Balance-Strategy/
- type: strategy
- pine_id: PUB;18e261284988497f86f963fff0d602b9
- version: 4.0

## Description

The Ultimate Balance Oscillator Strategy harnesses the power of the Ultimate Balance Oscillator to deliver a comprehensive and disciplined approach to trading. By combining the insights of the Rate of Change (ROC), Relative Strength Index (RSI), Commodity Channel Index (CCI), Williams Percent Range, and Average Directional Index (ADX) from TradingView, this strategy offers traders a systematic way to navigate the markets with precision.

The core principle of this strategy lies in its ability to identify optimal entry and exit points based on the movement of the Ultimate Balance Oscillator. When the oscillator line crosses below the 0.75 level, a buy signal is generated, indicating a potential opportunity for a bullish trend reversal. Conversely, when the oscillator line crosses above the 0.25 level, it triggers an exit signal, suggesting a possible end to a bullish trend.

Key Features:

1. Objective Market Analysis: The Ultimate Balance Oscillator Strategy provides a disciplined and objective approach to market analysis. By relying on the quantified insights of multiple indicators, it helps traders cut through market noise and focus on key signals, improving decision-making and reducing emotional biases.

2. Enhanced Timing and Precision: This strategy's entry and exit signals are based on the specific thresholds of the Ultimate Balance Oscillator. By waiting for confirmation through the crossing of these levels, traders can potentially enter trades at opportune moments and exit with greater precision, maximizing profit potential and minimizing risk exposure.

3. Customizability and Adaptability: The strategy offers flexibility, allowing traders to customize the parameters to fit their preferred trading style and timeframes. Whether you're a short-term trader or a long-term investor, the Ultimate Balance Oscillator Strategy can be adjusted to suit your specific needs, making it adaptable to various market conditions.

4. Real-time Alerts: Stay informed and never miss a potential trade opportunity with the strategy's built-in alert system. Set personalized alerts for buy and exit signals to receive timely notifications, ensuring you're always aware of the latest developments in the market.

5. Backtesting and Optimization: Before applying the strategy to live trading, it's recommended to conduct thorough backtesting and optimization. By testing the strategy's performance over historical data and fine-tuning the parameters, you can gain insights into its strengths and weaknesses, enabling you to make informed adjustments and increase its effectiveness.

Trading involves risk. Use the Ultimate Balance Oscillator Strategy at your own discretion. Past performance is not indicative of future results.

## Source Code

````pine
// © Julien_Eche

//@version=5
strategy("Ultimate Balance Strategy", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Indicator Weights
weightROC = input.float(2, "Rate of Change (ROC) Weight", group="Weightings")
weightRSI = input.float(0.5, "Relative Strength Index (RSI) Weight", group="Weightings")
weightCCI = input.float(2, "Commodity Channel Index (CCI) Weight", group="Weightings")
weightWilliamsR = input.float(0.5, "Williams %R Weight", group="Weightings")
weightADX = input.float(0.5, "Average Directional Index (ADX) Weight", group="Weightings")

enableShort = input(false, "Enable Short Positions")

// Overbought/Oversold Levels
obLevel = input.float(0.75, "Overbought Level")
osLevel = input.float(0.25, "Oversold Level")

// MA Type
maType = input.string("SMA", "MA Type", options=["SMA", "EMA", "WMA", "DEMA"], group="MA")
maLength = input.int(9, "MA Length", minval=1)

// Calculating the indicators
rocValue = ta.change(close, 20)
rsiValue = ta.rsi(close, 14)
cciValue = (close - ta.sma(close, 20)) / (0.015 * ta.dev(close, 20))
williamsRValue = -100 * (ta.highest(high, 14) - close) / (ta.highest(high, 14) - ta.lowest(low, 14))

dirmov(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    truerange = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
    minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
    [plus, minus]

adx(dilen, adxlen) =>
    [plus, minus] = dirmov(dilen)
    sum = plus + minus
    adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)

adxValue = adx(14, 14)

// Normalizing the values
normalize(value, min, max) =>
    (value - min) / (max - min)

normalizedROC = normalize(rocValue, ta.lowest(rocValue, 20), ta.highest(rocValue, 20))
normalizedRSI = normalize(rsiValue, 0, 100)
normalizedCCI = normalize(cciValue, ta.lowest(cciValue, 20), ta.highest(cciValue, 20))
normalizedWilliamsR = normalize(williamsRValue, ta.lowest(williamsRValue, 14), ta.highest(williamsRValue, 14))
normalizedADX = normalize(adxValue, 0, 50)

// Calculating the combined oscillator line
oscillatorLine = (normalizedROC * weightROC + normalizedRSI * weightRSI + normalizedCCI * weightCCI + normalizedWilliamsR * weightWilliamsR + normalizedADX * weightADX) / (weightROC + weightRSI + weightCCI + weightWilliamsR + weightADX)

// Moving Average
ma = ta.sma(oscillatorLine, maLength)





// Buy and sell conditions
buySignal = ta.crossover(ma, osLevel)
sellSignal = ta.crossunder(ma, obLevel)

// Enter long position
if buySignal
    strategy.entry("Buy", strategy.long)

// Exit long position
if sellSignal
    strategy.close("Buy")

// Enter short position if enabled
if enableShort and sellSignal
    strategy.entry("Sell", strategy.short)

// Exit short position if enabled
if enableShort and buySignal
    strategy.close("Sell")







//  Plotting
plot(oscillatorLine, title="Ultimate Balance Oscillator", color=color.rgb(41, 98, 255))
plot(ma, title="Moving Average", color=color.orange)

hline(obLevel, "Overbought", color=color.gray, linestyle=hline.style_dotted)
hline(osLevel, "Oversold", color=color.gray, linestyle=hline.style_dotted)
````
