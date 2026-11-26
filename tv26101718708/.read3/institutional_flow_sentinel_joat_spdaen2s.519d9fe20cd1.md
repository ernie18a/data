Calculation: BandFactor = SMA(base factor + ATR(atr length) / close * volatility weight + abs(close - close[1]) / close[1] * price change weight, factor smoothing length)
Calculation: SuperTrendLine = if close > SuperTrendLine[1] then max((high + low) / 2 - BandFactor * ATR(atr length), SuperTrendLine[1]) else min((high + low) / 2 + BandFactor * ATR(atr length), SuperTrendLine[1])
Calculation: SuperTrendDirection = if close > SuperTrendLine[1] then 1 else -1
Calculation: SellSideSweep = for some level L among the most recent stored pivot level count PivotLow(low, swing length, swing length) values that has not been swept on an earlier bar: low < L AND close > L
Calculation: BuySideSweep = for some level L among the most recent stored pivot level count PivotHigh(high, swing length, swing length) values that has not been swept on an earlier bar: high > L AND close < L
Long: SuperTrendDirection = 1
Short: SuperTrendDirection = -1
Long: low > high[2]
Short: high < low[2]
Long: SellSideSweep = true
Short: BuySideSweep = true
Long: SuperTrendDirection = 1 AND SuperTrendDirection[1] = -1 AND SuperTrendDirection(T1, last completed bar) = 1 AND ADX(ADX length) > ADX minimum threshold AND volume > SMA(volume, volume MA length) * volume multiplier AND RSI(close, RSI length) > RSI midline AND abs(close - open) >= ATR(atr length) * minimum body ATR ratio AND SellSideSweep[k] = true for some k from 0 to sweep memory
Short: SuperTrendDirection = -1 AND SuperTrendDirection[1] = 1 AND SuperTrendDirection(T1, last completed bar) = -1 AND ADX(ADX length) > ADX minimum threshold AND volume > SMA(volume, volume MA length) * volume multiplier AND RSI(close, RSI length) < RSI midline AND abs(close - open) >= ATR(atr length) * minimum body ATR ratio AND BuySideSweep[k] = true for some k from 0 to sweep memory