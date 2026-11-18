Calculation: candle body = abs(close - open)
Calculation: close position = (high > low ? (close - low) / (high - low) : 0.5)
Long: EMA(close, EMA length) crosses above VWAP(hlc3) AND (PA confirmation is disabled OR (candle body >= ATR(ATR period) * minimum body in ATRs AND close position >= minimum bullish close position))
Short: EMA(close, EMA length) crosses below VWAP(hlc3) AND (PA confirmation is disabled OR (candle body >= ATR(ATR period) * minimum body in ATRs AND close position <= maximum bearish close position))