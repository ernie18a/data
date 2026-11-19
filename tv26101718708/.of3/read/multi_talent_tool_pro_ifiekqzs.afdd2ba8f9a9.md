Calculation: candle body = abs(close - open)
Calculation: upper wick = high - max(close, open)
Calculation: lower wick = min(close, open) - low
Long: lower wick >= candle body * long-wick/body ratio AND upper wick <= candle body * maximum opposite-wick/body ratio AND candle body is nonzero
Short: upper wick >= candle body * long-wick/body ratio AND lower wick <= candle body * maximum opposite-wick/body ratio AND candle body is nonzero
Long: close[1] < open[1] AND close > open AND close >= open[1] AND open <= close[1] AND candle body > candle body[1]
Short: close[1] > open[1] AND close < open AND open >= close[1] AND close <= open[1] AND candle body > candle body[1]
Long: EMA(close, fast EMA lookback) crosses above EMA(close, slow EMA lookback), where the fast EMA lookback is shorter than the slow EMA lookback
Short: EMA(close, fast EMA lookback) crosses below EMA(close, slow EMA lookback), where the fast EMA lookback is shorter than the slow EMA lookback
Long: On chart bars using values from T1 or T2, close(current forming bar) >= open(current forming bar) OR close(last completed bar) >= open(last completed bar) OR close(two bars ago) >= open(two bars ago) OR close(current forming bar) >= open(two bars ago)
Short: On chart bars using values from T1 or T2, close(current forming bar) < open(current forming bar) OR close(last completed bar) < open(last completed bar) OR close(two bars ago) < open(two bars ago) OR close(current forming bar) < open(two bars ago)