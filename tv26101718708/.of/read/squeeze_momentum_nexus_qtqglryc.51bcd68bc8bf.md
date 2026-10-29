Calculation: Momentum = EMA of the current endpoint of the least-squares linear regression of close minus the average of (the midpoint of the highest high and lowest low over the momentum lookback) and the simple moving average of close over that same lookback; use a shorter smoothing lookback than the momentum lookback
Calculation: Higher-timeframe momentum = the same momentum calculation on higher-timeframe bars, using the bar still forming
Calculation: Bollinger Bands = simple moving average of close ± a multiplier times the standard deviation of close over the same lookback
Calculation: Keltner Channels = simple moving average of close ± a multiplier times the simple moving average of true range over the same lookback
Calculation: Squeeze released = lower Bollinger Band < lower Keltner Channel AND upper Bollinger Band > upper Keltner Channel
Long: Momentum > 0 OR Higher-timeframe momentum > 0 OR close > EMA(close)
Short: Momentum < 0 OR Higher-timeframe momentum < 0 OR close < EMA(close)