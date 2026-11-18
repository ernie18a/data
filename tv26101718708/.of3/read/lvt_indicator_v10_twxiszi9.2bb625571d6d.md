Calculation: Short EMA = EMA(close, shorter lookback)
Calculation: Long EMA = EMA(close, longer lookback)
Calculation: ADX = ADX(high, low, close, ADX lookback)
Calculation: RSI = RSI(close, RSI lookback)
Calculation: Prior swing low = lowest(low, swing lookback)[1]
Calculation: Prior swing high = highest(high, swing lookback)[1]
Calculation: High volume = volume > SMA(volume, volume lookback) * volume multiplier
Long: close > Long EMA AND Short EMA > Long EMA AND ADX > ADX threshold AND low < Prior swing low AND close > Prior swing low AND High volume AND RSI > upper RSI threshold
Short: close < Long EMA AND Short EMA < Long EMA AND ADX > ADX threshold AND high > Prior swing high AND close < Prior swing high AND High volume AND RSI < lower RSI threshold