Calculation: Positive movement = RMA(max(change(price), 0), lookback)
Calculation: Negative movement = RMA(max(-change(price), 0), lookback)
Calculation: Up index = RMA(Positive movement / (Positive movement + Negative movement), lookback), using zero when the denominator is zero
Calculation: Down index = RMA(Negative movement / (Positive movement + Negative movement), lookback), using zero when the denominator is zero
Calculation: Trend state = up when Up index > direction threshold, down when Down index > direction threshold, otherwise prior state (initially neutral)
Long: Trend state = up
Short: Trend state = down