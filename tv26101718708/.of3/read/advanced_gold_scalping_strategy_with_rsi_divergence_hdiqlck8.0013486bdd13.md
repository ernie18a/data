Calculation: Bullish divergence = RSI(OHLC4, RSI lookback) has a pivot low confirmed using separate left and right pivot lookbacks AND RSI at that pivot is greater than at the previous RSI pivot low AND low at that pivot is less than at the previous RSI pivot low AND bars since a preceding-bar RSI pivot-low detection is between the lower and upper pivot-gap parameters
Calculation: Bearish divergence = RSI(OHLC4, RSI lookback) has a pivot high confirmed using separate left and right pivot lookbacks AND RSI at that pivot is less than at the previous RSI pivot high AND high at that pivot is greater than at the previous RSI pivot high AND bars since a preceding-bar RSI pivot-high detection is between the lower and upper pivot-gap parameters
Long: Bullish divergence
Long: Bullish divergence AND current RSI(OHLC4, RSI lookback) is below the long RSI threshold
Short: Bearish divergence
Short: Bearish divergence AND current RSI(OHLC4, RSI lookback) is above the short RSI threshold
Exit: long, low <= entry price - stop-loss parameter × pip-to-price conversion factor OR high >= entry price + take-profit parameter × pip-to-price conversion factor
Exit: short, high >= entry price + stop-loss parameter × pip-to-price conversion factor OR low <= entry price - take-profit parameter × pip-to-price conversion factor