Calculation: Adaptive lookback = base lookback multiplied by long-term ATR divided by short-term ATR, rounded and bounded to its configured range.
Calculation: Regression centerline = linear regression of the selected price source over the adaptive lookback, evaluated across the fitted window.
Calculation: Standard deviation = population standard deviation of the selected price source over the adaptive lookback.
Calculation: Contraction = absolute difference between the regression centerline at the ends of the fitted window < standard deviation × flatness threshold.
Calculation: Signal bands = regression centerline ± standard deviation × signal multiplier.
Long: Contraction AND previous close >= previous lower signal band AND close < lower signal band
Short: Contraction AND previous close <= previous upper signal band AND close > upper signal band