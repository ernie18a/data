Calculation: Smoothed close and volume = Gaussian-filtered median close and volume; use a short median window and a short Gaussian smoothing window.
Calculation: Liquidity stress = ((smoothed close − previous smoothed close) ÷ (smoothed close × smoothed volume) − its moving average over the calculation window) ÷ its standard deviation over the same window; use 0 when a denominator is 0.
Calculation: Momentum divergence = rate of change of smoothed close over the calculation window − rate of change of the moving average of smoothed volume over the calculation window.
Calculation: Composite pressure = liquidity stress × momentum divergence, divided by its standard deviation over twice the calculation window; use 1 for a zero standard deviation.
Calculation: ALEX score = 100 × tanh((200 × (median of the Gaussian-smoothed composite pressure over the signal-smoothing window − its lowest value over the scaling lookback) ÷ (its highest value over the scaling lookback − its lowest value over the scaling lookback) − 100) ÷ 100); use 0 when the highest and lowest values are equal.
Calculation: Upper extreme = the lower of 90 and 50 plus half the standard deviation of ALEX score over the scaling lookback multiplied by volatility sensitivity.
Calculation: Lower extreme = the higher of −90 and −50 minus half the standard deviation of ALEX score over the scaling lookback multiplied by volatility sensitivity.
Long: ALEX score < lower extreme
Short: ALEX score > upper extreme