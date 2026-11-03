Calculation: Trend state = bearish if close < smoothed low; otherwise bullish if close > smoothed high; otherwise neutral. Smooth high and low separately with the same selectable moving-average method and parameters.
Long: chart-timeframe trend state = bullish
Short: chart-timeframe trend state = bearish
Long: last completed higher-timeframe trend state = bullish AND preceding higher-timeframe trend state != bullish
Short: last completed higher-timeframe trend state = bearish AND preceding higher-timeframe trend state != bearish
Exit: long, last completed higher-timeframe trend state = bearish OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, last completed higher-timeframe trend state = bullish OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance