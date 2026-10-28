Calculation: EMA of session VWAP = exponential moving average of the session’s cumulative volume-weighted average of (high + low + close) / 3
Long: (previous bar RSI > 55 AND previous close > EMA(low) AND high > previous high) OR (previous RSI > 50 AND previous close < EMA of session VWAP AND previous close > EMA(low) AND high > previous high)
Short: (previous RSI < 45 AND previous close < EMA(low) AND low < previous low) OR (previous RSI < 50 AND previous close > EMA of session VWAP AND previous close < EMA(low) AND low < previous low)
Exit: long, RSI < 50 AND close < EMA(low)
Exit: short, RSI > 50 AND close > EMA(low)