Calculation: ATR = average true range over a fixed lookback
Calculation: Bands = per bar, upper = (high+low)/2 + mult*ATR, lower = (high+low)/2 - mult*ATR; using the previous bar's final bands and this bar's trend: if trend = 1 and lower < previous lower then lower = previous lower; if trend = -1 and upper > previous upper then upper = previous upper (final bands)
Calculation: Trend = per bar: 1 if close > previous bar's final upper; -1 if close < previous bar's final lower; otherwise the previous bar's trend (initial trend = 1)
Long: Trend = 1 (opens on the bar where Trend changes from -1 to 1; entry price = that bar's close; position held while Trend = 1)
Short: Trend = -1 (opens on the bar where Trend changes from 1 to -1; entry price = that bar's close; position held while Trend = -1)
Exit: long, Trend = -1 (close < previous bar's final lower) OR low <= final lower band (stop) OR high >= entry + reward_multiple*(entry - final lower band) (target)
Exit: short, Trend = 1 (close > previous bar's final upper) OR high >= final upper band (stop) OR low <= entry - reward_multiple*(final upper band - entry) (target)