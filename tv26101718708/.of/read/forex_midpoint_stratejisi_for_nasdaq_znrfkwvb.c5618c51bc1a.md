Calculation: Midpoint threshold = ((highest high over the lookback + lowest low over the same lookback) / 2) × (1 + percentage level), shifted back by the specified number of bars
Calculation: Smoothed average = selected moving average (SMA, EMA, RMA, WMA, or VWMA) of the simple moving average of close
Long: Smoothed average crosses above the shifted midpoint threshold (current value > threshold and previous value ≤ threshold)
Short: Shifted midpoint threshold crosses above the smoothed average (current threshold > current average and previous threshold ≤ previous average)