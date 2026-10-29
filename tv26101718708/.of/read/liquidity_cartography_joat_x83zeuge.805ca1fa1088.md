Calculation: Prior-day high/low = high/low of the last completed daily bar (higher timeframe than the chart timeframe)
Calculation: Prior-week high/low = high/low of the last completed weekly bar (higher timeframe than the chart timeframe)
Calculation: Lower-liquidity sweep = low below a prior-day or prior-week low and close back above that low
Calculation: Upper-liquidity sweep = high above a prior-day or prior-week high and close back below that high
Calculation: Active sweep = most recent lower- or upper-liquidity sweep, valid through the confirmation window after it occurs
Calculation: Bullish structure break = close crosses above the latest confirmed swing high
Calculation: Bearish structure break = close crosses below the latest confirmed swing low
Calculation: Displacement = candle body larger than the average body over a longer lookback multiplied by a threshold, or a gap in the same direction
Calculation: Relative volume = volume divided by its moving average
Calculation: Trend alignment = close above/below both the chart-timeframe EMA and the EMA of the last completed higher-timeframe bar (higher timeframe than the chart timeframe)
Long: Lower-liquidity sweep OR (active sweep is lower-liquidity AND bullish structure break AND bullish displacement AND trend alignment up AND relative volume above threshold AND RSI above its bullish threshold AND datetime within the execution session)
Short: Upper-liquidity sweep OR (active sweep is upper-liquidity AND bearish structure break AND bearish displacement AND trend alignment down AND relative volume above threshold AND RSI below its bearish threshold AND datetime within the execution session)