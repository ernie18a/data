Calculation: MACD line = MACD(close, fast lookback, slow lookback)
Calculation: MACD signal line = EMA(MACD line, signal lookback)
Calculation: Bullish divergence = low < LOWEST(low, divergence lookback)[1] AND MACD line > LOWEST(MACD line, divergence lookback)[1] AND MACD line < 0
Calculation: Bearish divergence = high > HIGHEST(high, divergence lookback)[1] AND MACD line < HIGHEST(MACD line, divergence lookback)[1] AND MACD line > 0
Calculation: Support level = most recent confirmed PIVOTLOW(low, left lookback, right lookback)
Calculation: Resistance level = most recent confirmed PIVOTHIGH(high, left lookback, right lookback)
Calculation: Near support = ABS(close - support level) / close <= level tolerance
Calculation: Near resistance = ABS(close - resistance level) / close <= level tolerance
Long: MACD line crosses above MACD signal line AND Bullish divergence AND Near support AND volume > SMA(volume, volume lookback)
Long: MACD line crosses above MACD signal line AND volume > SMA(volume, volume lookback) AND NOT (Bullish divergence AND Near support)
Short: MACD line crosses below MACD signal line AND Bearish divergence AND Near resistance AND volume > SMA(volume, volume lookback)
Short: MACD line crosses below MACD signal line AND volume > SMA(volume, volume lookback) AND NOT (Bearish divergence AND Near resistance)