Calculation: TrendLine = EMA(raw, smoothing), calculated on T1 bars and read by chart bars from the current T1 bar while it is forming, where upper = EMA(close, length) + ATR(length) × multiplier, lower = EMA(close, length) − ATR(length) × multiplier, and raw = lower when close > upper, upper when close < lower, otherwise prior raw (initially close).
Calculation: Trend state = up when close > TrendLine AND SAR(close, start, acceleration, maximum) <= close; down when close <= TrendLine AND SAR(close, start, acceleration, maximum) >= close; neutral otherwise.
Calculation: SAR direction = SAR(close, start, acceleration, maximum) < close on chart bars.
Long: position side is not long AND confirmed chart bar AND Trend state is up AND close > open
Short: position side is not short AND confirmed chart bar AND Trend state is down AND close < open
Exit: long, confirmed chart bar AND (Trend state is not up OR SAR direction differs from its value on the prior chart bar)
Exit: short, confirmed chart bar AND (Trend state is not down OR SAR direction differs from its value on the prior chart bar)