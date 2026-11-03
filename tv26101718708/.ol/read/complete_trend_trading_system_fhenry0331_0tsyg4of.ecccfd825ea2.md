Calculation: EMA of low prices = exponential moving average of low
Calculation: Smoothed VWAP = exponential moving average of VWAP
Long: (RSI of close > 55 AND close > EMA of low prices) OR (RSI of close > 50 AND close < Smoothed VWAP AND close > EMA of low prices)
Short: (RSI of close < 45 AND close < EMA of low prices) OR (RSI of close < 50 AND close > Smoothed VWAP AND close < EMA of low prices)
Exit: long, (RSI of close < 50 AND close < EMA of low prices) OR (RSI of close > 75 AND close > EMA of low prices)
Exit: short, (RSI of close > 50 AND close > EMA of low prices) OR (RSI of close < 25 AND close < EMA of low prices)