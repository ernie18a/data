Calculation: Fast and slow moving averages = linear weighted moving averages of (high + low + close) / 3 on a higher timeframe, using its still-forming bar; the fast average has a shorter lookback than the slow average.
Long: fast moving average > slow moving average AND low[2] < high[1] AND |open[0] - close[2]| > retracement distance
Short: fast moving average < slow moving average AND low[1] < high[2] AND |open[0] - close[1]| > retracement distance
Exit: long, price <= entry price - stop-loss distance OR price >= entry price + take-profit distance
Exit: short, price >= entry price + stop-loss distance OR price <= entry price - take-profit distance