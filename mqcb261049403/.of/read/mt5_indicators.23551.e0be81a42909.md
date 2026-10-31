Calculation: Smoothed detrended open and close = separately for open and close, subtract a first moving average of that price series from the series, then apply a second moving average with a shorter smoothing length to the difference; each average has a selectable smoothing method and parameters.
Calculation: Indicator open = smoothed detrended open, except use the previous bar's smoothed detrended close when abs(open - close) <= a gap threshold.
Calculation: Indicator close = smoothed detrended close.
Calculation: Indicator trend = indicator close - indicator open.
Long: Indicator trend > 0.
Short: Indicator trend < 0.
Long: Previous indicator close <= 0 AND indicator close > 0.
Long: Previous indicator trend <= 0 AND indicator trend > 0.
Long: Previous indicator close <= upper threshold AND indicator close > upper threshold.
Long: Previous indicator close < lower threshold AND indicator close >= lower threshold.
Short: Previous indicator close >= 0 AND indicator close < 0.
Short: Previous indicator trend >= 0 AND indicator trend < 0.
Short: Previous indicator close >= lower threshold AND indicator close < lower threshold.
Short: Previous indicator close > upper threshold AND indicator close <= upper threshold.
Calculation: For the higher-timeframe version, calculate the indicator from higher-timeframe bars, using the still-forming higher-timeframe bar for the current indicator value and the preceding higher-timeframe bar for previous values; the same long and short conditions apply.