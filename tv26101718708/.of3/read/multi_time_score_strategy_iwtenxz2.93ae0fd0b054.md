Calculation: RangeScore(T) = if highest(high, lookback) over T bars ending at the last completed T bar differs from lowest(low, lookback) over T bars ending at the last completed T bar, ((close[1] on chart bars - lowest(low, lookback) over T bars ending at the last completed T bar) / (highest(high, lookback) over T bars ending at the last completed T bar - lowest(low, lookback) over T bars ending at the last completed T bar)) * 100 - 50; otherwise 0
Calculation: WeightedScore = (RangeScore(T1) * W1 + RangeScore(T2) * W2 + RangeScore(T3) * W3 + RangeScore(T4) * W4 + RangeScore(T5) * W5 + RangeScore(T6) * W6) / (W1 + W2 + W3 + W4 + W5 + W6), where each Wi is a separate weight parameter
Long: WeightedScore > sensitivity
Short: WeightedScore < 0
Exit: long, low <= entry price - stop distance OR high >= entry price + take distance
Exit: short, high >= entry price + stop distance OR low <= entry price - take distance