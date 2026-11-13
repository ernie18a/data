Calculation: ATR = Wilder average true range
Calculation: TrendEMA = EMA of close, long lookback
Calculation: RangeHigh = highest high of the previous N bars, excluding the current bar
Calculation: RangeLow = lowest low of the previous N bars, excluding the current bar
Calculation: RangeSize = RangeHigh - RangeLow
Calculation: Stop = for a long, RangeLow frozen at entry; for a short, RangeHigh frozen at entry
Calculation: R = absolute value of (entry price - Stop)
Calculation: RunnerStop = long: running maximum since entry of max(Stop, trail); short: running minimum since entry of min(Stop, trail); trail is either EMA of close with a lookback shorter than TrendEMA (same value for long and short), or close - k*ATR for a long / close + k*ATR for a short
Long: close > RangeHigh AND RangeSize >= a*ATR AND RangeSize <= b*ATR (a < b) AND close > TrendEMA AND ATR > SMA of ATR (lookback longer than the ATR length) AND volume / SMA(volume) >= c (c > 1)
Short: close < RangeLow AND RangeSize >= a*ATR AND RangeSize <= b*ATR (a < b) AND close < TrendEMA AND ATR > SMA of ATR (lookback longer than the ATR length) AND volume / SMA(volume) >= c (c > 1)
Exit: long, low <= Stop OR close < TrendEMA OR (close < RangeLow AND the Short conditions' filters all hold)
Exit: short, high >= Stop OR close > TrendEMA OR (close > RangeHigh AND the Long conditions' filters all hold)
Exit: long, high >= entry price + m*R (m = 1 for partial profit-taking or m = 2 for full exit)
Exit: short, low <= entry price - m*R (m = 1 for partial profit-taking or m = 2 for full exit)
Exit: long, low <= RunnerStop
Exit: short, high >= RunnerStop