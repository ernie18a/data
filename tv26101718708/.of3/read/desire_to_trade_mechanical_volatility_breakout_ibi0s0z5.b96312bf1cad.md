Calculation: Range high = Highest(high one bar ago, range lookback)
Calculation: Range low = Lowest(low one bar ago, range lookback)
Calculation: Long stop = Range low captured at long entry and held while long
Calculation: Short stop = Range high captured at short entry and held while short
Calculation: Long risk = max(entry price - long stop, minimum tick)
Calculation: Short risk = max(short stop - entry price, minimum tick)
Calculation: Long raw trail = selected EMA(close, runner EMA lookback), EMA(close, separate trail EMA lookback), or close - ATR(ATR lookback) * trail multiple
Calculation: Short raw trail = selected EMA(close, runner EMA lookback), EMA(close, separate trail EMA lookback), or close + ATR(ATR lookback) * trail multiple
Calculation: Long runner stop = running maximum since entry of max(long stop, long raw trail)
Calculation: Short runner stop = running minimum since entry of min(short stop, short raw trail)
Long: longs enabled AND (date filter disabled OR datetime within configured date bounds) AND range high - range low >= minimum range ATR parameter * ATR(ATR lookback) AND range high - range low <= maximum range ATR parameter * ATR(ATR lookback) AND (stock trend filter disabled OR close > EMA(close, stock trend lookback)) AND (market filter disabled OR benchmark close > EMA(benchmark close, market trend lookback)) AND (ATR expansion filter disabled OR ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR average lookback)) AND (volume filter disabled OR (SMA(volume, volume lookback) > 0 AND volume >= minimum relative volume parameter * SMA(volume, volume lookback))) AND (close > range high OR (stop-entry mode selected AND high >= range high))
Short: shorts enabled AND (date filter disabled OR datetime within configured date bounds) AND range high - range low >= minimum range ATR parameter * ATR(ATR lookback) AND range high - range low <= maximum range ATR parameter * ATR(ATR lookback) AND (stock trend filter disabled OR close < EMA(close, stock trend lookback)) AND (market filter disabled OR benchmark close < EMA(benchmark close, market trend lookback)) AND (ATR expansion filter disabled OR ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR average lookback)) AND (volume filter disabled OR (SMA(volume, volume lookback) > 0 AND volume >= minimum relative volume parameter * SMA(volume, volume lookback))) AND (close < range low OR (stop-entry mode selected AND low <= range low))
Exit: Long, low <= long stop
Exit: Short, high >= short stop
Exit: Long, full-target mode selected AND high >= entry price + full reward-risk parameter * long risk
Exit: Short, full-target mode selected AND low <= entry price - full reward-risk parameter * short risk
Exit: Long, partial-target mode selected AND high >= entry price + partial reward-risk parameter * long risk
Exit: Short, partial-target mode selected AND low <= entry price - partial reward-risk parameter * short risk
Exit: Long, runner trail enabled AND low <= long runner stop
Exit: Short, runner trail enabled AND high >= short runner stop
Exit: Long, close < EMA(close, stock trend lookback)
Exit: Short, close > EMA(close, stock trend lookback)