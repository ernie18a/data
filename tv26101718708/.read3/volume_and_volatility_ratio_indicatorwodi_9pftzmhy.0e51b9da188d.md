Calculation: volatility index = volume * (high - low) / close * 100
Calculation: bullish-pattern condition = volatility index[1] > volatility index[2] AND (volatility index[1] > volatility index OR volume[1] > volume) AND close[n+1] > close[n] for every n from 1 through the pattern lookback AND close[1] < close AND volume > SMA(volume, volume lookback) AND volatility index > SMA(volatility index, long index lookback) * threshold percentage / 100 AND ((open[1] - close[1] < close[1] - low[1]) OR (open - close < close - low))
Calculation: bearish-pattern condition = volatility index[1] > volatility index[2] AND (volatility index[1] > volatility index OR volume[1] > volume) AND close[n+1] < close[n] for every n from 1 through the pattern lookback AND close[1] > close AND volume > SMA(volume, volume lookback) AND volatility index > SMA(volatility index, long index lookback) * threshold percentage / 100 AND ((close[1] - open[1] < high[1] - close[1]) OR (close - open < high - close))
Calculation: bullish-pattern low = min(low[1], low)
Calculation: bullish-pattern high = max(high[pattern lookback], high)
Calculation: bullish-pattern range = bullish-pattern high - bullish-pattern low
Calculation: bearish-pattern low = min(low[pattern lookback], low)
Calculation: bearish-pattern high = max(high[1], high)
Calculation: bearish-pattern range = bearish-pattern high - bearish-pattern low
Calculation: long stop level, set at entry = bullish-pattern low - bullish-pattern range * stop ratio when reversal mode is disabled; otherwise bearish-pattern low - bearish-pattern range * stop ratio
Calculation: long take-profit level, set at entry = bullish-pattern low + bullish-pattern range * take-profit ratio when reversal mode is disabled; otherwise bearish-pattern low + bearish-pattern range * take-profit ratio
Calculation: short stop level, set at entry = bearish-pattern high + bearish-pattern range * stop ratio when reversal mode is disabled; otherwise bullish-pattern high + bullish-pattern range * stop ratio
Calculation: short take-profit level, set at entry = bearish-pattern high - bearish-pattern range * take-profit ratio when reversal mode is disabled; otherwise bullish-pattern high - bullish-pattern range * take-profit ratio
Long: (reversal mode disabled AND bullish-pattern condition AND position is flat or short) OR (reversal mode enabled AND bearish-pattern condition AND position is flat or short)
Short: (reversal mode disabled AND bearish-pattern condition AND position is flat or long) OR (reversal mode enabled AND bullish-pattern condition AND position is flat or long)
Exit: long, low < long stop level OR high > long take-profit level
Exit: short, high > short stop level OR low < short take-profit level