Calculation: Relative volume = volume / SMA(volume[1], volume lookback), when SMA(volume[1], volume lookback) > 0
Calculation: Range expansion = True Range / ATR(ATR lookback)
Long: close > open AND Relative volume >= elevated relative volume threshold
Short: close < open AND Relative volume >= elevated relative volume threshold
Long: close > open AND Relative volume >= strong relative volume threshold
Short: close < open AND Relative volume >= strong relative volume threshold
Long: close > open AND Relative volume >= strong relative volume threshold AND Range expansion >= ATR expansion threshold
Short: close < open AND Relative volume >= strong relative volume threshold AND Range expansion >= ATR expansion threshold