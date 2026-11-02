Calculation: Mean channel = SMA(close) plus or minus a standard-deviation multiple of close over the same lookback.
Calculation: Bollinger %B = (close - lower Bollinger band) / (upper Bollinger band - lower Bollinger band); use 0.5 when the bands are equal. The Bollinger lookback is longer than the mean-channel lookback; the SMA of %B uses the Bollinger lookback.
Calculation: RSI thresholds = select the overbought threshold from two parameter values according to whether the mean-channel lookback is above a cutoff; select the oversold threshold from two parameter values according to whether that lookback is below the cutoff. RSI uses the mean-channel lookback.
Calculation: Percentile bands = mean-channel SMA plus or minus the nearest-rank percentile of abs(close - mean-channel SMA), using the mean-channel lookback.
Calculation: Regression candle = independently apply rolling linear regression at zero offset to open, high, low, and close using the same lookback. Its body is abs(regression close - regression open), its range is regression high - regression low, and its upper and lower wicks are regression high - max(regression open, regression close) and min(regression open, regression close) - regression low. A doji has range > 0 AND body <= a sensitivity parameter times range AND both wicks > body.
Calculation: Upper extreme = Bollinger %B > its upper boundary AND (close > mean-channel upper band OR RSI > overbought threshold) AND regression close > upper percentile band. Lower extreme = Bollinger %B < its lower boundary AND (close < mean-channel lower band OR RSI < oversold threshold) AND regression close < lower percentile band.
Calculation: Directional-momentum percentile = nearest-rank percentile over a lookback of (scaled DMI positive line - scaled DMI negative line + SMA(RSI)) / 4. Both DMI lines use the same smoothing lookback and scaling factor; the RSI SMA uses a shorter lookback than the RSI.
Long: Bollinger %B < its lower boundary AND RSI < oversold threshold.
Short: Bollinger %B > its upper boundary AND RSI > overbought threshold.
Long: Directional-momentum percentile < 0 AND Bollinger %B < SMA(Bollinger %B) AND RSI < oversold threshold.
Long: close > mean-channel SMA AND Bollinger %B > SMA(Bollinger %B) AND Bollinger %B >= its lower boundary AND Bollinger %B <= its upper boundary.
Short: (close <= mean-channel SMA OR Bollinger %B <= SMA(Bollinger %B)) AND Bollinger %B >= its lower boundary AND Bollinger %B <= its upper boundary.
Long: regression close > regression open AND regression close <= mean-channel upper band AND doji = false AND upper extreme = false AND lower extreme = false.
Short: regression close <= regression open AND regression close >= mean-channel lower band AND doji = false AND upper extreme = false AND lower extreme = false.
Long: RSI < oversold threshold.
Short: RSI > overbought threshold.