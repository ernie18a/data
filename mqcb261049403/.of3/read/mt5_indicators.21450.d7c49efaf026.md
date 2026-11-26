Calculation: Trend value = (MA(close, shorter lookback, shared smoothing method, shared phase) - MA(close, longer lookback, shared smoothing method, shared phase)) * MA(close, separate lookback, separate smoothing method, separate phase)
Calculation: Trend candle open = Trend value[3] if abs(open - close[1]) is at least the gap threshold; otherwise, the previous trend candle close
Calculation: Trend candle close = Trend value
Long: trend candle close >= trend candle open
Short: trend candle close < trend candle open
Long: trend candle close >= trend candle open using the still-forming T1 bar, sampled on chart bars
Short: trend candle close < trend candle open using the still-forming T1 bar, sampled on chart bars