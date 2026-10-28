Calculation: Dekidaka volume weight = (EMA(volume, smoothing length) × smoothing length) / (EMA(volume, smoothing length) × smoothing length + previous bar’s EMA(volume, smoothing length) × smoothing length) × body-size parameter
Calculation: Dekidaka-high = max(open, close) + Dekidaka volume weight × abs(close − open)
Calculation: Dekidaka-low = min(open, close) − Dekidaka volume weight × abs(close − open)
Long: high > Dekidaka-high AND low > Dekidaka-low AND close > open OR high > Dekidaka-high AND low > Dekidaka-low AND close < open
Short: high < Dekidaka-high AND low < Dekidaka-low AND close < open OR high < Dekidaka-high AND low < Dekidaka-low AND close > open