Calculation: lower band = EMA(LOWEST(price source, long lookback), band EMA lookback) on chart bars
Calculation: center EMA = EMA(last completed T1 close - (last completed T1 high - last completed T1 low) * center factor, shared pivot EMA lookback) on chart bars
Calculation: R4 EMA = EMA(last completed T1 close + (last completed T1 high - last completed T1 low) * shared range multiplier / R4 divisor, shared pivot EMA lookback) on chart bars
Calculation: S3 EMA = EMA(last completed T1 close - (last completed T1 high - last completed T1 low) * shared range multiplier / S3 divisor, shared pivot EMA lookback) on chart bars
Long: crossover(center EMA, lower band) AND at least one close in the immediately preceding entry confirmation lookback chart bars is below the current lower band
Exit: long, crossunder(close, R4 EMA)
Exit: long, crossunder(close, S3 EMA)