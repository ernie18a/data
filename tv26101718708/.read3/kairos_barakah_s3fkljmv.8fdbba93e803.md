Calculation: reference levels = high and low of the chart bar whose timestamp matches the configured IST start time
Long: During the configured-duration trading window, close > reference high AND the most recent signal in the window is not long
Short: During the configured-duration trading window, close < reference low AND the most recent signal in the window is not short
Long: RSI(close, RSI lookback) <= lower RSI threshold
Short: RSI(close, RSI lookback) >= upper RSI threshold