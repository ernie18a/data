Calculation: fast EMA = EMA(close, shorter lookback)
Calculation: slow EMA = EMA(close, longer lookback)
Calculation: RSI value = RSI(close, lookback)
Calculation: volume average = SMA(volume, lookback)
Calculation: ATR value = ATR(lookback)
Long: fast EMA crosses above slow EMA AND RSI value > threshold AND volume > volume average * volume factor
Short: fast EMA crosses below slow EMA AND RSI value < threshold AND volume > volume average * volume factor
Exit: long, low <= entry price - ATR value * stop loss multiplier OR high >= entry price + ATR value * take profit multiplier
Exit: short, high >= entry price + ATR value * stop loss multiplier OR low <= entry price - ATR value * take profit multiplier