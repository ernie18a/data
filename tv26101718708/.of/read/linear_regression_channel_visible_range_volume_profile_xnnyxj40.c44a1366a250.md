Calculation: LinReg-smoothed open, high, low, close = rolling linear regression of the respective OHLC field over the same lookback
Calculation: Doji = LinReg-smoothed range > 0 AND absolute(LinReg-smoothed close − LinReg-smoothed open) ≤ 0.08 × LinReg-smoothed range AND upper wick > body AND lower wick > body
Calculation: Bollinger %B = (close − lower Bollinger Band) / (upper Bollinger Band − lower Bollinger Band), using a 200-bar SMA basis and bands 2 standard deviations above and below it
Calculation: PNR upper/lower bands = SMA(close, channel length) ± nearest-rank percentile of absolute(close − SMA(close, channel length)), over the channel length
Calculation: DZA = nearest-rank 85th percentile over 10 bars of (DMI difference + 20-bar SMA of RSI) / 4; DMI difference = plus DI − minus DI, where each DI is 3 × 100 × RMA(10, corresponding directional movement) / RMA(10, true range)
Long: Bollinger %B < 0 AND RSI < oversold threshold OR DZA < 0 AND Bollinger %B < its 200-bar SMA AND RSI < oversold threshold OR LinReg-smoothed close > LinReg-smoothed open AND NOT Doji
Short: Bollinger %B > 1 AND RSI > overbought threshold OR LinReg-smoothed close ≤ LinReg-smoothed open AND NOT Doji