Calculation: AMA change(T) = AMA(close, adaptive lookback, faster smoothing lookback, slower smoothing lookback, exponent, T, current bar) - AMA(close, same parameters, T, previous bar)
Calculation: Active trend(T) = bullish when AMA change(T) > dK × standard deviation(AMA change(T), adaptive lookback on T); bearish when AMA change(T) < -dK × standard deviation(AMA change(T), adaptive lookback on T); otherwise previous Active trend(T), initially neutral; for T1 through T7, update on chart bars using each still-forming T bar
Long: AMA change(chart, still-forming bar) > dK × standard deviation(AMA change(chart), same adaptive lookback on chart bars)
Short: AMA change(chart, still-forming bar) < -dK × standard deviation(AMA change(chart), same adaptive lookback on chart bars)
Long: Active trend(T1) = bullish
Short: Active trend(T1) = bearish
Long: Active trend(T2) = bullish
Short: Active trend(T2) = bearish
Long: Active trend(T3) = bullish
Short: Active trend(T3) = bearish
Long: Active trend(T4) = bullish
Short: Active trend(T4) = bearish
Long: Active trend(T5) = bullish
Short: Active trend(T5) = bearish
Long: Active trend(T6) = bullish
Short: Active trend(T6) = bearish
Long: Active trend(T7) = bullish
Short: Active trend(T7) = bearish