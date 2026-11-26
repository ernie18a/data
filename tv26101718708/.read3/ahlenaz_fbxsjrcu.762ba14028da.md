Calculation: shorter EMA = EMA(close, shorter lookback)
Calculation: longer EMA = EMA(close, longer lookback)
Calculation: volume average = SMA(volume, volume lookback)
Calculation: ATR stop distance = ATR(lookback) * stop multiplier
Long: shorter EMA > longer EMA AND close > highest(high, resistance lookback)[1] AND close > open AND volume > volume average * volume multiplier
Short: shorter EMA < longer EMA AND close < lowest(low, support lookback)[1] AND close < open AND volume > volume average * volume multiplier
Exit: long, low <= close - ATR stop distance
Exit: short, high >= close + ATR stop distance