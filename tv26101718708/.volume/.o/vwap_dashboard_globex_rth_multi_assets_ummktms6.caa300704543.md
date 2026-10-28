Calculation: Globex VWAP = cumulative volume-weighted mean of each bar’s OHLC average, reset at each UTC day boundary
Calculation: RTH VWAP = cumulative volume-weighted mean of each bar’s OHLC average during the New York regular-hours session, reset at session open
Long: close >= Globex VWAP OR RTH session is active AND close >= RTH VWAP
Short: close < Globex VWAP OR RTH session is active AND close < RTH VWAP