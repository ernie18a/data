Calculation: Bullish trend = close > EMA(close, longest trend lookback) AND EMA(close, shortest trend lookback) > EMA(close, intermediate trend lookback)
Calculation: Bearish trend = close < EMA(close, longest trend lookback) AND EMA(close, shortest trend lookback) < EMA(close, intermediate trend lookback)
Calculation: Normalized momentum = 2 * Stochastic((EMA(close, shorter momentum lookback) - EMA(close, longer momentum lookback)) / EMA(close, longer momentum lookback) * 100, momentum range lookback) / 100 - 1, or 0 when its range is zero
Calculation: Bullish momentum = normalized momentum > 0 AND normalized momentum > EMA(normalized momentum, momentum smoothing lookback)
Calculation: Bearish momentum = normalized momentum < 0 AND normalized momentum < EMA(normalized momentum, momentum smoothing lookback)
Calculation: Bullish volume surge = volume >= SMA(volume, volume average lookback) * volume surge multiplier AND close > open
Calculation: Bearish volume surge = volume >= SMA(volume, volume average lookback) * volume surge multiplier AND close < open
Long: Bullish trend
Short: Bearish trend
Long: Bullish momentum
Short: Bearish momentum
Long: Bullish volume surge
Short: Bearish volume surge
Long: Bullish trend AND Bullish momentum AND normalized momentum < overbought level AND (volume filter disabled OR Bullish volume surge) AND position side is not long
Short: Bearish trend AND Bearish momentum AND normalized momentum > oversold level AND (volume filter disabled OR Bearish volume surge) AND position side is not short