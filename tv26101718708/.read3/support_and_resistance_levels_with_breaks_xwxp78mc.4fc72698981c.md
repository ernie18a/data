Calculation: resistance = most recent non-null ta.pivothigh(max(open, close), left pivot lookback, right pivot lookback)[1] on chart bars
Calculation: support = most recent non-null ta.pivotlow(min(open, close), left pivot lookback, right pivot lookback)[1] on chart bars
Calculation: volume oscillator = 100 * (EMA(volume, shorter volume lookback) - EMA(volume, longer volume lookback)) / EMA(volume, longer volume lookback)
Calculation: active resistance = a newly available resistance level that remains active until close > its level
Calculation: active support = a newly available support level that remains active until close < its level
Long: crossover(close, resistance) AND (close <= open OR volume oscillator > volume threshold) OR active resistance AND close > active resistance level
Short: crossunder(close, support) AND (close >= open OR volume oscillator > volume threshold) OR active support AND close < active support level