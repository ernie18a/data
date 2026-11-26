Calculation: Last swing low = most recent confirmed PivotLow(low, swing lookback, swing lookback)
Calculation: Last swing high = most recent confirmed PivotHigh(high, swing lookback, swing lookback)
Calculation: Filter A = selected by Filter A type from HMA(close, A lookback), EMA(close, A lookback), SMA(close, A lookback), VWAP(hlc3, VWAP anchor), or Off
Calculation: Filter B = selected by Filter B type from HMA(close, B lookback), EMA(close, B lookback), SMA(close, B lookback), VWAP(hlc3, VWAP anchor), or Off
Long: low < Last swing low AND close > Last swing low AND low[1] > Last swing low AND (Filter A is Off OR close > Filter A) AND (Filter B is Off OR close > Filter B)
Short: high > Last swing high AND close < Last swing high AND high[1] < Last swing high AND (Filter A is Off OR close < Filter A) AND (Filter B is Off OR close < Filter B)