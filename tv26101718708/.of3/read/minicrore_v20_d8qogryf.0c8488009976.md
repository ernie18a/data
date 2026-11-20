Calculation: candle body = abs(close - open)
Calculation: zone range = max(Highest(high, zone lookback) - Lowest(low, zone lookback), minimum zone range)
Calculation: supply zone = high > Highest(high[1], zone lookback - 1)
Calculation: demand zone = low < Lowest(low[1], zone lookback - 1)
Calculation: average volume = SMA(volume, volume lookback)
Calculation: volume spike = volume > average volume * volume multiplier
Calculation: fast moving average = SMA(close, shorter MA lookback)
Calculation: slow moving average = SMA(close, longer MA lookback)
Calculation: long signal = demand zone AND close > open AND volume spike AND close > fast moving average AND fast moving average >= slow moving average
Calculation: short signal = supply zone AND close < open AND volume spike AND close < fast moving average AND fast moving average <= slow moving average
Long: demand zone AND volume spike AND close > open AND candle body > zone range * entry body factor
Short: supply zone AND volume spike AND close < open AND candle body > zone range * entry body factor
Long: long signal AND NOT long signal[1]
Short: short signal AND NOT short signal[1]
Long: low < low[1] AND close > open AND candle body > zone range * trap body factor AND volume > average volume
Short: high > high[1] AND close < open AND candle body > zone range * trap body factor AND volume > average volume
Exit: long, low <= entry price - stop distance OR high reaches the next supply zone
Exit: short, high >= entry price + stop distance OR low reaches the next demand zone