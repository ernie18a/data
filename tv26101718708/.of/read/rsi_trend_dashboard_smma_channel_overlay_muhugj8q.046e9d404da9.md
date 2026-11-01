Calculation: Adaptive oscillator = Let the short-channel high and low be Wilder averages of high and low with the same lookback; let their midpoint be their average and their half-range be half their difference. Calculate RSI with the same lookback as the chart RSI separately on (high − midpoint) / half-range and (low − midpoint) / half-range. If both RSI values are above the RSI midpoint, select the higher; if both are below it, select the lower; otherwise select the value closer to the midpoint, choosing the lower on a tie. The oscillator is undefined when the half-range is zero or unavailable.
Calculation: Adaptive upper and lower levels = A confirmed pivot high is an adaptive oscillator value at a past pivot bar that is at least the highest oscillator value in a window spanning that bar, more preceding bars than following bars, and the current confirmation bar. A pivot low is defined symmetrically using the lowest value. Update the upper level only on confirmed pivot highs above the upper RSI neutral threshold, and the lower level only on confirmed pivot lows below the lower RSI neutral threshold. Each level is an EMA updated only on its qualifying pivots, initialized to its first qualifying pivot and held unchanged between updates; a level is unavailable until initialized and whenever it is not positive.
Long: RSI of close >= upper RSI neutral threshold
Short: RSI of close <= lower RSI neutral threshold AND RSI of close < RSI midpoint
Long: RSI of close > RSI of close on the last completed higher-timeframe bar, using the same RSI lookback
Short: RSI of close < RSI of close on the last completed higher-timeframe bar, using the same RSI lookback
Long: RSI of close > shorter-lookback SMA or EMA of RSI
Short: RSI of close < shorter-lookback SMA or EMA of RSI
Long: RSI of close > longer-lookback SMA or EMA of RSI
Short: RSI of close < longer-lookback SMA or EMA of RSI
Long: shorter-lookback SMA or EMA of RSI > longer-lookback average of RSI using the same average type
Short: shorter-lookback SMA or EMA of RSI < longer-lookback average of RSI using the same average type
Long: SMA, EMA, or Wilder average of OHLC4 > Wilder average of high using the longer channel lookback
Short: SMA, EMA, or Wilder average of OHLC4 < Wilder average of low using the longer channel lookback
Long: Adaptive oscillator > adaptive upper level
Short: Adaptive oscillator < adaptive lower level