Calculation: Smoothed volume = EMA(volume, smoothing lookback) × smoothing lookback
Calculation: Dekidaka-high = max(open, close) + body-size parameter × (Smoothed volume / (Smoothed volume + prior-bar Smoothed volume)) × abs(close − open)
Calculation: Dekidaka-low = min(open, close) − body-size parameter × (Smoothed volume / (Smoothed volume + prior-bar Smoothed volume)) × abs(close − open)
Long: high > Dekidaka-high AND low > Dekidaka-low AND (close > open OR close < open)
Short: high < Dekidaka-high AND low < Dekidaka-low AND (close > open OR close < open)