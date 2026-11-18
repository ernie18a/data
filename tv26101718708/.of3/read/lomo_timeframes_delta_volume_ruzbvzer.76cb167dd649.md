Calculation: Trend(T) = 0 initially; on T bars set to 1 when close crosses above ZLEMA(close, length) + band multiplier × highest(ATR(length), length × window multiplier), set to −1 when close crosses below ZLEMA(close, length) − band multiplier × highest(ATR(length), length × window multiplier), and otherwise retain its prior value; chart bars read the current T-bar value, including while it is forming
Calculation: Volume change percentage = (volume[1] != 0 ? (volume − volume[1]) / volume[1] × 100 : 0)
Long: Trend(T1) = 1
Short: Trend(T1) != 1
Long: Trend(T2) = 1
Short: Trend(T2) != 1
Long: Trend(T3) = 1
Short: Trend(T3) != 1
Long: Trend(T4) = 1
Short: Trend(T4) != 1
Long: Trend(T5) = 1
Short: Trend(T5) != 1
Long: Volume change percentage > threshold
Short: Volume change percentage < −threshold