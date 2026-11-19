Calculation: Equilibrium midpoint = (highest(high, range lookback) + lowest(low, range lookback)) / 2
Calculation: Latest confirmed swing high = most recent non-null pivot high(high, swing length, swing length)
Calculation: Latest confirmed swing low = most recent non-null pivot low(low, swing length, swing length)
Calculation: Structure bias = bullish initially; becomes bullish when close crosses above the latest confirmed swing high and bearish when close crosses below the latest confirmed swing low
Long: structure bias = bullish
Short: structure bias = bearish
Long: close <= equilibrium midpoint
Short: close > equilibrium midpoint
Long: close crosses above the latest confirmed swing high
Short: close crosses below the latest confirmed swing low
Long: close[1] < open[1] AND close > open AND close - open > ATR(ATR lookback)
Short: close[1] > open[1] AND close < open AND open - close > ATR(ATR lookback)
Long: low > high[2]
Short: high < low[2]
Short: high >= highest(high, liquidity lookback)[1] AND high[1] < highest(high, liquidity lookback)[1]
Long: low <= lowest(low, liquidity lookback)[1] AND low[1] > lowest(low, liquidity lookback)[1]
Long: on chart bars where the sampled T1 time changes, using lookahead_off T1 values with the current T1 bar still forming in real time, the previous chart bar's sampled T1 close < open AND the current T1 close > open AND the current T1 close - open > ATR(ATR lookback, T1 bars, current T1 bar)
Short: on chart bars where the sampled T1 time changes, using lookahead_off T1 values with the current T1 bar still forming in real time, the previous chart bar's sampled T1 close > open AND the current T1 close < open AND the current T1 open - close > ATR(ATR lookback, T1 bars, current T1 bar)
Long: on chart bars where the sampled T1 time changes, using lookahead_off T1 values with the current T1 bar still forming in real time, current T1 low > T1 high sampled two chart bars ago
Short: on chart bars where the sampled T1 time changes, using lookahead_off T1 values with the current T1 bar still forming in real time, current T1 high < T1 low sampled two chart bars ago