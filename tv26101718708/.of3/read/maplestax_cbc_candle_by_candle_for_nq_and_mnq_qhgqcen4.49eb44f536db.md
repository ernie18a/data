Calculation: CBCState = true if close > high[1], false if close < low[1], otherwise CBCState[1]; initially false
Calculation: T1CBCState = CBCState[1] on T1 bars, last completed bar, taken on chart bars
Calculation: OpeningRangeHigh = highest high of chart bars from the open of the session containing the current bar through the earlier of the current bar and that open plus the opening range duration
Calculation: OpeningRangeLow = lowest low of chart bars from the open of the session containing the current bar through the earlier of the current bar and that open plus the opening range duration
Long: CBCState = true
Long: T1CBCState = true
Long: EMA(close, shorter lookback) >= EMA(close, longer lookback)
Long: EMA(close, shorter lookback, T1, bar still forming) >= EMA(close, longer lookback, T1, bar still forming)
Long: close > VWAP(typical price)
Long: close > EMA(close, longest lookback)
Long: close > OpeningRangeHigh
Short: CBCState = false
Short: T1CBCState = false
Short: EMA(close, shorter lookback) < EMA(close, longer lookback)
Short: EMA(close, shorter lookback, T1, bar still forming) < EMA(close, longer lookback, T1, bar still forming)
Short: close <= VWAP(typical price)
Short: close <= EMA(close, longest lookback)
Short: close < OpeningRangeLow