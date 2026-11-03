Calculation: Globex VWAP = cumulative sum of ((open + high + low + close) / 4 × volume) divided by cumulative volume, reset at each day boundary
Calculation: RTH VWAP = the same volume-weighted average, reset at the start of the RTH session and available only during that session
Long: close >= Globex VWAP
Long: datetime is within the RTH session AND close >= RTH VWAP
Short: close < Globex VWAP
Short: datetime is within the RTH session AND close < RTH VWAP