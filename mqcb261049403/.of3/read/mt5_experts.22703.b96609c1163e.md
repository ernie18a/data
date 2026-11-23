Long: MA(close, longer lookback)[1] > MA(close, longer lookback)[2] AND MA(close, shorter lookback)[0] > MA(close, shorter lookback)[1] AND CCI(lookback)[0] < down threshold
Short: MA(close, longer lookback)[1] < MA(close, longer lookback)[2] AND MA(close, shorter lookback)[0] < MA(close, shorter lookback)[1] AND CCI(lookback)[0] > up threshold
Exit: long, MA(close, longer lookback)[1] <= MA(close, longer lookback)[2]
Exit: short, MA(close, longer lookback)[1] >= MA(close, longer lookback)[2]