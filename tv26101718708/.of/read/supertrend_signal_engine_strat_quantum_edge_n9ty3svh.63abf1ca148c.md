Calculation: ATR = selected volatility measure: Wilder average of true range or simple moving average of true range, using the selected lookback
Calculation: Lower band = source − multiplier × ATR; if the previous close is above the prior lower band, use the greater of this value and the prior lower band, otherwise use this value
Calculation: Upper band = source + multiplier × ATR; if the previous close is below the prior upper band, use the lesser of this value and the prior upper band, otherwise use this value
Calculation: Trend state = initialize bullish; switch from bearish to bullish when close > prior upper band, switch from bullish to bearish when close < prior lower band, otherwise retain the prior state
Long: prior trend state is bearish AND current trend state is bullish AND datetime is within the configured date window
Short: prior trend state is bullish AND current trend state is bearish AND datetime is within the configured date window