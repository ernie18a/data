Calculation: Upper Bollinger rail = SMA(high, lookback) + standard deviation(high, lookback) × multiplier
Calculation: Lower Bollinger rail = SMA(low, lookback) − standard deviation(low, lookback) × multiplier
Calculation: Super Bollinger Trend baseline = start at 0; each bar, if either rail is unavailable use 0, otherwise if close is above the prior baseline use the greater of that baseline and the current lower rail; if close is below the prior baseline use the lesser of that baseline and the current upper rail; otherwise use 0. If close crosses above this updated baseline, replace it with the current lower rail; if close crosses below it, replace it with the current upper rail.
Calculation: MACD line = EMA(close, the difference between the longer and shorter lookbacks)
Calculation: MACD signal line = SMA(MACD line, lookback)
Calculation: MACD overlay average = SMA(close, lookback)
Long: close crosses above the Super Bollinger Trend baseline OR MACD line > MACD signal line OR MACD line > its prior-bar value OR MACD signal line > its prior-bar value OR MACD overlay average > its prior-bar value
Short: close crosses below the Super Bollinger Trend baseline OR MACD line < MACD signal line OR MACD line < its prior-bar value OR MACD signal line < its prior-bar value OR MACD overlay average < its prior-bar value