Calculation: Renko open and close = Renko series at the selected resolution; this is the chart timeframe when current resolution is selected, otherwise it may be higher or lower than the chart timeframe. Use the security series with lookahead enabled: the selected resolution’s current bar while it is forming in real time, and the lookahead-mapped series historically.
Calculation: Renko body size = absolute difference between Renko close and Renko open
Calculation: Smoothed stochastic %K = moving average of raw stochastic %K over a shorter lookback
Calculation: Smoothed stochastic %D = moving average of smoothed stochastic %K over a shorter lookback
Long: Renko close crosses above Renko open OR (Renko close > Renko open AND prior smoothed stochastic %K < prior smoothed stochastic %D AND prior smoothed stochastic %K < lower stochastic threshold AND current smoothed stochastic %K > current smoothed stochastic %D)
Short: Renko close crosses below Renko open OR (Renko close < Renko open AND prior smoothed stochastic %K > prior smoothed stochastic %D AND prior smoothed stochastic %K > upper stochastic threshold AND current smoothed stochastic %K < current smoothed stochastic %D)
Exit: long, close < Renko open − half the Renko body size AND Renko close > Renko open
Exit: short, close > Renko open + half the Renko body size AND Renko close < Renko open