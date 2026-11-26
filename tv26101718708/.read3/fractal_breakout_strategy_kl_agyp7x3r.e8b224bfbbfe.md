Calculation: bullish fractal support = the latest low[3] satisfying low[3] < low[4] < low[5] AND low[3] < low[2] < low[1] AND volume[3] > SMA(volume, relative-volume lookback)[3], carried forward until the next qualifying pivot
Calculation: ATR test statistic = (ATR(fast lookback) - ATR(slow lookback)) / (standard deviation(TrueRange, fast lookback) / sqrt(fast lookback))
Calculation: ATR stop distance = ATR(trailing-stop lookback) * trailing-stop multiplier
Calculation: initial risk = ATR stop distance on the entry bar
Calculation: long trailing stop = low - ATR stop distance while flat; while long, the maximum of the previous long trailing stop and low - ATR stop distance
Calculation: next profit multiple = first profit-level parameter until its exit condition is met, then the second profit-level parameter until its exit condition is met, then the third profit-level parameter until its exit condition is met, then none
Long: position is flat AND datetime >= backtest-start parameter AND close >= bullish fractal support AND ATR test statistic < negative critical value selected by confidence-level parameter
Exit: Long, low <= long trailing stop
Exit: Long, take-profit mode enabled AND close > entry price AND a profit target is next AND close >= entry price + next profit multiple * initial risk