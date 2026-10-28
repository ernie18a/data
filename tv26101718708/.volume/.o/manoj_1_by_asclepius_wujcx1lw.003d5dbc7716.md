Calculation: EMA of high = exponential moving average of high over a lookback
Calculation: EMA of low = exponential moving average of low over the same lookback
Calculation: Absolute candle body = abs(close - open)
Long: open < EMA of high AND close > EMA of high AND (VWAP <= close OR (VWAP >= open AND VWAP <= open + Absolute candle body × configured touch fraction)
Short: open > EMA of low AND close < EMA of low AND (VWAP >= close OR (VWAP <= open AND VWAP >= open - Absolute candle body × configured touch fraction)
Exit: Long, low <= low of the long signal candle OR (high has reached entry price + trailing activation distance AND low <= highest high since activation - trailing offset) OR bars since entry >= configured duration
Exit: Short, high >= high of the short signal candle OR (low has reached entry price - trailing activation distance AND high >= lowest low since activation + trailing offset) OR bars since entry >= configured duration