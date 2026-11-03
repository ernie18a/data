Calculation: ATR = Average True Range
Calculation: Buy basis = moving average of high when the high/low envelope is enabled; otherwise the moving average of the selected applied price
Calculation: Sell basis = moving average of low when the high/low envelope is enabled; otherwise the moving average of the selected applied price
Calculation: Raw upper band = Buy basis + volatility multiplier × ATR
Calculation: Raw lower band = Sell basis − volatility multiplier × ATR
Calculation: Upper threshold = Raw upper band, except during a bearish trend when it is the lower of the Raw upper band and the previous Upper threshold
Calculation: Lower threshold = Raw lower band, except during a bullish trend when it is the higher of the Raw lower band and the previous Lower threshold
Calculation: Trend = bearish if low is below the previous Lower threshold; otherwise bullish if high is above the previous Upper threshold; otherwise the previous Trend
Long: Previous Trend is bearish AND current Trend is bullish
Short: Previous Trend is bullish AND current Trend is bearish