Calculation: Mean absolute close change = SMA(abs(close - close[1]), lookback)
Calculation: Compression = abs(close[1] - close[2]) < Mean absolute close change * compression multiplier AND abs(close - close[1]) < Mean absolute close change * compression multiplier
Calculation: Signal state = direction of the most recent Long or Short signal, initially neutral; update to long on a Long signal, to short on a Short signal, and otherwise persist
Long: close[1] > close[2] AND close > close[1] AND volume > SMA(volume, lookback) * volume multiplier AND NOT Compression AND Signal state != long
Short: close[1] < close[2] AND close < close[1] AND volume > SMA(volume, lookback) * volume multiplier AND NOT Compression AND Signal state != short