Calculation: efficiency = (volume / SMA(volume, lookback)) / ((high - low) / ATR(atr length))
Calculation: impulse = high - low >= ATR(atr length) * range expansion multiplier AND high - low >= ATR(atr length) * min void height multiplier AND efficiency <= efficiency cap AND abs(close - open) >= (high - low) * body share
Calculation: bull void = (NOT gap confirmation AND impulse AND close > open) OR (gap confirmation AND impulse[1] AND close[1] > open[1] AND low > close[1] * bull gap factor)
Calculation: bear void = (NOT gap confirmation AND impulse AND close < open) OR (gap confirmation AND impulse[1] AND close[1] < open[1] AND high < close[1] * bear gap factor)
Calculation: mitigation level = open if full fill mitigation else (open + close) / 2
Calculation: bull mitigation price = low if wick mitigation else close
Calculation: bear mitigation price = high if wick mitigation else close
Calculation: inside bull void = for some n in [0, fill window - 1]: bull void[n] AND open[n] <= close AND close <= close[n] AND bull mitigation price[j] > mitigation level[n] for all j in [0, n - 1]
Calculation: inside bear void = for some n in [0, fill window - 1]: bear void[n] AND close[n] <= close AND close <= open[n] AND bear mitigation price[j] < mitigation level[n] for all j in [0, n - 1]
Long: bull void
Short: bear void
Long: for some n in [1, fill window]: bull void[n] AND bull mitigation price <= mitigation level[n] AND bull mitigation price[j] > mitigation level[n] for all j in [1, n - 1]
Short: for some n in [1, fill window]: bear void[n] AND bear mitigation price >= mitigation level[n] AND bear mitigation price[j] < mitigation level[n] for all j in [1, n - 1]
Long: inside bull void AND NOT inside bear void
Short: inside bear void