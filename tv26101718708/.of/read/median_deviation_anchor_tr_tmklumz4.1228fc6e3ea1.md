Calculation: MA = moving average of close (short lookback)
Calculation: Median = rolling median (nearest-rank 50th percentile) of MA over a lookback longer than the MA lookback
Calculation: Band = multiplier * ATR
Calculation: UpperATR = Median + Band
Calculation: LowerATR = Median - Band
Calculation: SD = rolling standard deviation of Median over a lookback longer than the MA lookback
Calculation: Raw = if close > LowerATR AND close >= Median + SD then (close - Median) / (Median - LowerATR) * 100; else if close < UpperATR AND close <= Median - SD then (close - Median) / (UpperATR - Median) * 100; else 0
Calculation: Osc = EMA of Raw, clamped to a fixed symmetric range around 0
Calculation: Trend = +1 if Osc > LongThreshold; -1 if Osc < ShortThreshold; otherwise the previous Trend (initially 0). LongThreshold is positive, ShortThreshold is negative
Long: Trend == +1 AND previous-bar Trend == -1
Long: Osc > LongThreshold OR Osc crosses above 0
Short: Trend == -1 AND previous-bar Trend == +1
Short: Osc < ShortThreshold OR Osc crosses below 0
Exit: long, Trend == -1 AND previous-bar Trend == +1
Exit: short, Trend == +1 AND previous-bar Trend == -1