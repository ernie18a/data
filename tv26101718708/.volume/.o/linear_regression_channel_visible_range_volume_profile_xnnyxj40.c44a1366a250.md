Calculation: Regression-smoothed open, high, low, and close = rolling linear-regression values of the corresponding chart-timeframe prices
Calculation: Mean channel = rolling close SMA ± 2 × rolling close standard deviation; its lookback is shared with RSI and the percentile envelope
Calculation: Percentile envelope = mean channel center ± the nearest-rank percentile of absolute close deviations from that center, using the same lookback as the mean channel
Calculation: Oversold RSI threshold = 30 when the mean-channel lookback is below 30 bars, otherwise 40; overbought threshold = 60 when it is above 30 bars, otherwise 70
Calculation: Bollinger %B = (close − lower Bollinger Band) ÷ (upper Bollinger Band − lower Bollinger Band), using a common lookback for the bands and the %B average
Calculation: Momentum percentile input = average of the 10-period DMI difference and the 20-period simple moving average of RSI, divided by 2; momentum percentile = 85th nearest-rank percentile of that input over 10 bars
Long: regression-smoothed close > regression-smoothed open
Long: Bollinger %B < 0 AND RSI < oversold RSI threshold
Long: momentum percentile < 0 AND Bollinger %B < its rolling average AND RSI < oversold RSI threshold
Long: Bollinger %B < 0 AND (close < mean-channel lower band OR RSI < oversold RSI threshold) AND regression-smoothed close < percentile-envelope lower band
Short: regression-smoothed close ≤ regression-smoothed open
Short: Bollinger %B > 1 AND RSI > overbought RSI threshold
Short: Bollinger %B > 1 AND (close > mean-channel upper band OR RSI > overbought RSI threshold) AND regression-smoothed close > percentile-envelope upper band