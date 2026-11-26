Calculation: buyer candle percentage = 100 × count(close > open over longer lookback) / longer lookback
Calculation: bullish structure = highest(high, shorter lookback) >= highest(high, longer lookback)[shorter lookback] AND lowest(low, shorter lookback) >= lowest(low, longer lookback)[shorter lookback]
Calculation: bearish structure = highest(high, shorter lookback) <= highest(high, longer lookback)[shorter lookback] AND lowest(low, shorter lookback) <= lowest(low, longer lookback)[shorter lookback]
Calculation: volume delta = sum over longer lookback of (((close - low) - (high - close)) / (high - low, or 1 when high = low)) × (volume, or 1 when missing)
Calculation: VWAP distance = 100 × (close - VWAP(close)) / VWAP(close)
Long: on the previous chart bar, close crosses above Supertrend(factor, ATR lookback) AND close > EMA(close, lookback) AND ADX(DI lookback, ADX smoothing) > ADX threshold AND (RSI(close, lookback) > RSI threshold OR RSI filter is disabled)
Short: on the previous chart bar, close crosses below Supertrend(factor, ATR lookback) AND close < EMA(close, lookback) AND ADX(DI lookback, ADX smoothing) > ADX threshold AND (RSI(close, lookback) < RSI threshold OR RSI filter is disabled)
Long: bullish structure = true
Short: bearish structure = true
Long: volume delta > upper volume delta threshold
Short: volume delta < lower volume delta
Long: buyer candle percentage > upper buyer percentage threshold
Short: buyer candle percentage < lower buyer percentage threshold
Long: VWAP distance > upper VWAP distance threshold
Short: VWAP distance < lower VWAP distance threshold