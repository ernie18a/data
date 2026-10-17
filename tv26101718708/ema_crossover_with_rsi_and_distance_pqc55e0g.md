# EMA Crossover with RSI and Distance

- url: https://www.tradingview.com/script/pqC55E0g-EMA-Crossover-with-RSI-and-Distance/
- type: strategy
- pine_id: PUB;5b5a2a26d3ea4058954481a8877bd938
- version: 1.0

## Description

EMA Crossover with RSI and Distance Strategy
This strategy combines Exponential Moving Averages (EMA) with Relative Strength Index (RSI) and distance-based conditions to generate buy, sell, and neutral signals. It is designed to help traders identify entry and exit points based on multiple technical indicators.

Key Components:

Exponential Moving Averages (EMA):
The strategy uses four EMAs: EMA 5, EMA 13, EMA 40, and EMA 55.
A buy signal (long) is triggered when EMA 5 crosses above EMA 13 and EMA 40 crosses above EMA 55.
A sell signal (short) is generated when EMA 55 crosses above EMA 40.
The distance between EMAs (5 and 13) is also important. If the current distance between EMA 5 and EMA 13 is smaller than the average distance over the last 5 candles, a neutral condition is triggered, preventing a signal even if all other conditions are met.
Relative Strength Index (RSI):
The 14-period RSI is used to determine market strength and direction.
The strategy requires RSI to be above 50 and greater than the average RSI (over the past 14 periods) for a buy signal.
If the RSI is above 60, a green signal is given, indicating a strong bullish condition, even if the EMA conditions are not fully met.
If the RSI is below 40, a red signal is given, indicating a strong bearish condition, regardless of the EMA crossover.
Distance Conditions:
The strategy calculates the distance between EMA 5 and EMA 13 on each candle and compares it to the average distance of the last 5 candles.
If the current distance between EMA 5 and EMA 13 is lower than the average of the last 5 candles, a neutral signal is triggered. This helps avoid entering a trade when the market is losing momentum.
Additionally, if the distance between EMA 40 and EMA 13 is greater than the previous distance, the previous signal is kept intact, ensuring that the trend is still strong enough for the signal to remain valid.
Signal Persistence:
Once a buy (green) or sell (red) signal is triggered, it remains intact as long as the price is closing above EMA 5 for long trades or below EMA 55 for short trades.
If the price moves below EMA 5 for long trades or above EMA 55 for short trades, the signal is recalculated based on the most recent conditions.
Signal Display:

Green Signals: Represent a strong buy signal and are shown below the candle when the RSI is above 60.
Red Signals: Represent a strong sell signal and are shown above the candle when the RSI is below 40.
Neutral Signals: Displayed when the conditions for entry are not met, specifically when the EMA distance condition is violated.
Long and Short Signals: Additional signals are shown based on the EMA crossovers and RSI conditions. These signals are plotted below the candle for long positions and above the candle for short positions.
Trade Logic:

Long Entry: Enter a long trade when EMA 5 crosses above EMA 13, EMA 40 crosses above EMA 55, and the RSI is above 50 and greater than the average RSI. Additionally, the current distance between EMA 5 and EMA 13 should be larger than the average distance of the last 5 candles.
Short Entry: Enter a short trade when EMA 55 crosses above EMA 40 and the RSI is below 40.
Neutral Condition: If the distance between EMA 5 and EMA 13 is smaller than the average distance over the last 5 candles, the strategy will not trigger a signal, even if other conditions are met.

## Source Code

````pine
//@version=6
strategy("EMA Crossover Strategy with RSI Average, Distance, and Signal Persistence", overlay=true, fill_orders_on_standard_ohlc=true)

// Define EMAs
ema5 = ta.ema(close, 5)
ema13 = ta.ema(close, 13)
ema40 = ta.ema(close, 40)
ema55 = ta.ema(close, 55)

// Calculate 14-period RSI
rsi = ta.rsi(close, 14)

// Calculate the RSI average
averageRsiLength = 14  // Length for RSI average
averageRsi = ta.sma(rsi, averageRsiLength)

// Define conditions
emaShortTermCondition = ema5 > ema13  // EMA 5 > EMA 13
emaLongTermCondition = ema40 > ema55  // EMA 40 > EMA 55
rsiCondition = rsi > 50 and rsi > averageRsi  // RSI > 50 and RSI > average RSI

// Track the distance between ema5 and ema13 for the last 5 candles
distance = math.abs(ema5 - ema13)
distanceWindow = 5
distances = array.new_float(distanceWindow, 0.0)
array.shift(distances)
array.push(distances, distance)

// Calculate the average distance of the last 5 distances
avgDistance = array.avg(distances)

// Track distance between EMA40 and EMA13 for the last few candles
distance40_13 = math.abs(ema40 - ema13)
distanceWindow40_13 = 5
distances40_13 = array.new_float(distanceWindow40_13, 0.0)
array.shift(distances40_13)
array.push(distances40_13, distance40_13)

// Calculate the average distance for EMA40 and EMA13
avgDistance40_13 = array.avg(distances40_13)

// Neutral condition: if the current distance is lower than the average of the last 5 distances
neutralCondition = distance < avgDistance or ema13 > ema5

// Short signal condition: EMA40 crosses above EMA55
shortCondition = ema40 > ema55

// Conditions for Green and Red signals (based on RSI thresholds)
greenSignalCondition = rsi > 60  // Green if RSI > 60, regardless of EMAs
redSignalCondition = rsi < 40  // Red if RSI < 40, regardless of EMAs

// Combine conditions for a buy signal (Long)
longCondition = emaShortTermCondition and emaLongTermCondition and rsiCondition and not neutralCondition

// Store the last signal (initialized as na)
var string lastSignal = na

// Track previous distance between EMA40 and EMA13
var float prevDistance40_13 = na

// Check if the current distance between EMA40 and EMA13 is greater than the previous
distanceCondition = (not na(prevDistance40_13)) ? (distance40_13 > prevDistance40_13) : true

// Update the lastSignal only if the current candle closes above EMA5, otherwise recalculate it
if (close > ema5)
    if (longCondition and distanceCondition)
        lastSignal := "long"
    else if (shortCondition and distanceCondition)
        lastSignal := "short"
    else if (neutralCondition)
        lastSignal := "neutral"
    // Add green signal based on RSI
    else if (greenSignalCondition)
        lastSignal := "green"
    // Add red signal based on RSI
    else if (redSignalCondition)
        lastSignal := "red"

// If current candle doesn't close above EMA5, recalculate the signal based on current conditions
if (close <= ema5)
    if (longCondition)
        lastSignal := "long"
    else if (shortCondition)
        lastSignal := "short"
    else if (greenSignalCondition)
        lastSignal := "green"
    else if (redSignalCondition)
        lastSignal := "red"
    else
        lastSignal := "neutral"

// Update previous distance for next comparison
prevDistance40_13 := distance40_13

// Set signal conditions based on lastSignal
isLong = lastSignal == "long"
isShort = lastSignal == "short"
isNeutral = lastSignal == "neutral"
isGreen = lastSignal == "green"
isRed = lastSignal == "red"

// Plot signals with preference for long (green) and short (red), no multiple signals per bar
plotshape(isLong, style=shape.circle, color=color.green, location=location.belowbar, size=size.tiny)
plotshape(isShort and not isLong, style=shape.circle, color=color.red, location=location.abovebar, size=size.tiny)
plotshape(isNeutral and not isLong and not isShort, style=shape.circle, color=color.gray, location=location.abovebar, size=size.tiny)
plotshape(isGreen and not isLong and not isShort and not isNeutral, style=shape.circle, color=color.green, location=location.belowbar, size=size.tiny)
plotshape(isRed and not isLong and not isShort and not isNeutral, style=shape.circle, color=color.red, location=location.abovebar, size=size.tiny)

// Plot EMAs for visualization
plot(ema5, color=color.blue, title="EMA 5")
plot(ema13, color=color.orange, title="EMA 13")
plot(ema40, color=color.green, title="EMA 40")
plot(ema55, color=color.red, title="EMA 55")

// Plot RSI average for debugging (optional, remove if not needed)
// plot(averageRsi, title="Average RSI", color=color.orange)
// hline(50, title="RSI 50", color=color.gray)  // Optional: Comment this out too if not needed
````
