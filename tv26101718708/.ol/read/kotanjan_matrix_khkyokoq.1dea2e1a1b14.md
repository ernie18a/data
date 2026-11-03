Calculation: Signal state = 0 initially; set to 1 after Long and -1 after Short; otherwise retain its prior value
Calculation: Volume spike = volume > its simple moving average over a lookback * a multiplier
Calculation: Compression = abs(close - close[1]) and abs(close[1] - close[2]) are each < the simple moving average of abs(close - close[1]) over the same lookback * a sensitivity multiplier
Long: close > close[1] AND close[1] > close[2] AND volume spike AND NOT compression AND signal state != 1
Short: close < close[1] AND close[1] < close[2] AND volume spike AND NOT compression AND signal state != -1