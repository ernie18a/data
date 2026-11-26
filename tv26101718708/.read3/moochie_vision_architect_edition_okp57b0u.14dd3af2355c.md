Calculation: synthetic velocity = (close - close[1]) * (volume / SMA(volume, volatility lookback))
Long: low <= VWAP - STDEV(close, volatility lookback) * VWAP deviation multiplier AND synthetic velocity < -STDEV(synthetic velocity, velocity lookback) * velocity outlier multiplier
Short: high >= VWAP + STDEV(close, volatility lookback) * VWAP deviation multiplier AND synthetic velocity > STDEV(synthetic velocity, velocity lookback) * velocity outlier multiplier
Long: close > VWAP
Short: close <= VWAP