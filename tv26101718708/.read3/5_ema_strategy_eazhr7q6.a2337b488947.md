Calculation: Long alert high = current high when high < EMA(source, lookback); otherwise retain the prior value, and clear when current high exceeds its prior value
Calculation: Short alert low = current low when low > EMA(source, lookback); otherwise retain the prior value, and clear when current low falls below its prior value
Long: long direction enabled AND position flat AND entries in the current T1 period < maximum entries per T1 period AND high > prior-bar long alert high
Short: short direction enabled AND position flat AND entries in the current T1 period < maximum entries per T1 period AND low < prior-bar short alert low
Exit: Long, low <= lowest low over the stop lookback ending at entry OR high >= entry price + (entry price - that lowest low) × target multiple
Exit: Short, high >= highest high over the stop lookback ending at entry OR low <= entry price - (that highest high - entry price) × target multiple