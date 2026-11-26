Calculation: VWAP delta close = HMA(close - session VWAP, smoothing lookback) when smoothing is enabled; otherwise close - session VWAP
Calculation: VWAP delta open = HMA(open - session VWAP, smoothing lookback) when smoothing is enabled; otherwise open - session VWAP
Long: (Area style AND VWAP delta close > EMA(VWAP delta close, baseline lookback)) OR (Candle style AND VWAP delta close > VWAP delta open)
Short: (Area style AND VWAP delta close <= EMA(VWAP delta close, baseline lookback)) OR (Candle style AND VWAP delta close <= VWAP delta open)