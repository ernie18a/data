Calculation: Activity speed = EMA of (bar activity per second divided by its data-lookback SMA), where bar activity is volume or one tick and bar seconds come from the chart timeframe or, if unavailable, elapsed time between bars
Calculation: Price velocity = z-score over the data lookback of (close − prior close) / ATR
Calculation: Activity acceleration = z-score over the data lookback of the EMA-smoothed change in activity speed
Calculation: Activity jerk = z-score over the data lookback of the EMA-smoothed change in activity acceleration before normalization
Calculation: Activity impulse = sum of normalized activity acceleration over the impulse lookback
Long: Price velocity ≥ 3 OR activity acceleration ≥ 3 OR activity jerk ≥ 3 OR activity impulse ≥ 3
Short: Price velocity ≤ −3 OR activity acceleration ≤ −3 OR activity jerk ≤ −3 OR activity impulse ≤ −3