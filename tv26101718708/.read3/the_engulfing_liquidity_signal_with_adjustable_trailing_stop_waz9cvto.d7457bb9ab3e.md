Calculation: net volume = if high = low then 0 else volume * (2 * close - high - low) / (high - low)
Calculation: buy threshold = buy multiplier × SMA(max(net volume, 0), buy lookback)
Calculation: sell threshold = sell multiplier × SMA(min(net volume, 0), sell lookback)
Long: close > open AND close[1] < open[1] AND close > high[1] AND net volume > buy threshold AND net volume > -net volume[1] AND net volume[1] < 0
Short: close < open AND close[1] > open[1] AND close < low[1] AND net volume < sell threshold AND net volume < -net volume[1] AND net volume[1] > 0
Exit: long, Short condition
Exit: long, low ≤ entry-bar high − trailing percentage × (entry-bar close − lowest(low, trailing lookback) on the entry bar)