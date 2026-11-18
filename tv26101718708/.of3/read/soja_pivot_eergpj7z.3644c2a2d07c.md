Calculation: first target = target multiplier * HLC3[target lag] - high[target lag]
Calculation: second target = target multiplier * HLC3[target lag] - low[target lag]
Calculation: stop level = SMA(close, stop lookback) - stop multiplier * ATR(stop lookback)
Long: CMO(close, CMO lookback) > lower CMO threshold AND CMO(close, CMO lookback) < upper CMO threshold AND close > close[close lag] AND BBW(close, BBW lookback, BBW factor) < BBW threshold AND SUM(volume, volume lookback) > volume threshold AND OBV[OBV lag] > OBV threshold
Exit: long, close > first target
Exit: long, close > second target
Exit: long, close < stop level