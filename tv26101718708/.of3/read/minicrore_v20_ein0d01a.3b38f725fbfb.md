Calculation: volume average = SMA(volume, volume average lookback)
Calculation: candle body = abs(close - open)
Calculation: trap range = max(Highest(high, channel lookback) - Lowest(low, channel lookback), ATR(ATR lookback))
Calculation: long setup = low = Lowest(low, demand swing lookback) AND low > low[1] AND low > low[2] AND volume > volume average * volume multiplier AND close > open AND EMA(close, fast MA lookback) > EMA(close, mid MA lookback) AND EMA(close, mid MA lookback) > SMA(close, slow MA lookback)
Long: long setup AND NOT long setup[1]
Calculation: short setup = high = Highest(high, supply swing lookback) AND high > high[1] AND high > high[2] AND volume > volume average * volume multiplier AND close < open AND EMA(close, fast MA lookback) < EMA(close, mid MA lookback) AND EMA(close, mid MA lookback) < SMA(close, slow MA lookback)
Short: short setup AND NOT short setup[1]
Long: low < low[1] AND close > open AND candle body > trap range * trap body fraction AND volume > volume average
Short: high > high[1] AND close < open AND candle body > trap range * trap body fraction AND volume > volume average