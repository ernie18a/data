Calculation: VWAP = session volume-weighted average price of (high+low+close)/3
Calculation: Fast EMA and Slow EMA = EMA of close, fast has a shorter length than slow
Calculation: RSI = RSI of close; ADX = Wilder ADX (DMI) of the same bars; ADX threshold = fixed strong-trend level
Calculation: BullCount = number of true among (close > VWAP, Fast EMA > Slow EMA, RSI > 50)
Calculation: BearCount = number of true among (close <= VWAP, Fast EMA <= Slow EMA, RSI <= 50)
Long: BullCount >= 2
Long: close > open AND previous close < previous open AND close > previous open AND open < previous close AND ADX >= ADX threshold AND RSI > lower RSI bound AND RSI < upper RSI bound (bounds symmetric around 50, lower < 50 < upper) AND Fast EMA > Slow EMA
Long: close crosses above VWAP
Long: Fast EMA crosses above Slow EMA
Short: BearCount >= 2
Short: close < open AND previous close > previous open AND close < previous open AND open > previous close AND ADX >= ADX threshold AND RSI > lower RSI bound AND RSI < upper RSI bound AND Fast EMA < Slow EMA
Short: close crosses below VWAP
Short: Fast EMA crosses below Slow EMA
Exit: long, high >= entry price + profit target distance OR low <= entry price - stop distance
Exit: short, low <= entry price - profit target distance OR high >= entry price + stop distance