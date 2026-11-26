Calculation: Dot signal = RSI(RSI source, RSI lookback) when raw RSI is selected, otherwise the configured moving average of that RSI over the separate smoothing lookback (SMA when smoothing type is None)
Long: Supertrend(ATR lookback, factor) is in an uptrend
Long: Supertrend(ATR lookback, factor) is in an uptrend AND was not in an uptrend on the previous bar
Long: Supertrend(ATR lookback, factor) is in an uptrend AND Dot signal crosses above the middle level
Long: RSI(RSI source, RSI lookback) forms a pivot low using separate left and right lookbacks AND RSI at the pivot bar is higher than at the previous confirmed pivot low AND low at the pivot bar is lower than at the previous confirmed pivot low AND bars since the bar immediately after the previous pivot confirmation is within the minimum and maximum range parameters
Short: Supertrend(ATR lookback, factor) is in a downtrend
Short: Supertrend(ATR lookback, factor) is in a downtrend AND was not in a downtrend on the previous bar
Short: Supertrend(ATR lookback, factor) is in a downtrend AND Dot signal crosses below the middle level
Short: RSI(RSI source, RSI lookback) forms a pivot high using separate left and right lookbacks AND RSI at the pivot bar is lower than at the previous confirmed pivot high AND high at the pivot bar is higher than at the previous confirmed pivot high AND bars since the bar immediately after the previous pivot confirmation is within the minimum and maximum range parameters