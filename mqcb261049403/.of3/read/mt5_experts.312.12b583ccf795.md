Calculation: average candle body = SMA(abs(close-open), lookback)
Long: close[1] > open[1] AND open[2]-close[2] > average candle body[1] AND close[1] < open[2] AND open[1] > close[2] AND (high[2]+low[2])/2 < SMA(close, lookback)[2] AND MFI(lookback)[1] < long-entry threshold
Short: close[1] < open[1] AND close[2]-open[2] > average candle body[1] AND close[1] > open[2] AND open[1] < close[2] AND (high[2]+low[2])/2 > SMA(close, lookback)[2] AND MFI(lookback)[1] > short-entry threshold
Exit: long, MFI(lookback)[1] crosses above upper critical threshold OR MFI(lookback)[1] crosses below lower critical threshold
Exit: short, MFI(lookback)[1] crosses above lower critical threshold OR MFI(lookback)[1] crosses above upper critical threshold