Calculation: spread ratio = (high - low) / ATR(ATR lookback)
Calculation: relative volume = volume / SMA(volume, volume lookback)
Long: on T1 or T2 bars, relative volume >= high-volume threshold AND spread ratio <= narrow-spread threshold AND price is at support
Short: on T1 or T2 bars, relative volume >= high-volume threshold AND spread ratio <= narrow-spread threshold AND price is at resistance
Long: on T1 or T2 bars, relative volume >= high-volume threshold AND spread ratio >= wide-spread threshold AND price crosses above the Creek
Short: on T1 or T2 bars, relative volume >= high-volume threshold AND spread ratio >= wide-spread threshold AND price crosses below the Ice