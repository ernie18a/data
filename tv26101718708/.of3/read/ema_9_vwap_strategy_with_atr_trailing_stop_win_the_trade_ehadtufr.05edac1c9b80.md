Long: EMA(close, lookback) crosses above VWAP
Short: EMA(close, lookback) crosses below VWAP
Exit: long, after the trailing stop activates when high reaches entry price + ATR(lookback) * multiplier, low reaches the highest high since activation - ATR(lookback) * multiplier
Exit: short, after the trailing stop activates when low reaches entry price - ATR(lookback) * multiplier, high reaches the lowest low since activation + ATR(lookback) * multiplier