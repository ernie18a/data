Long: low > high[2]
Short: high < low[2]
Long: chart timeframe is intraday AND low < low(T1, last completed bar) AND close > low(T1, last completed bar)
Short: chart timeframe is intraday AND high > high(T1, last completed bar) AND close < high(T1, last completed bar)
Short: on confirmation of a new chart-symbol pivot high, its last two confirmed pivot highs are rising AND the correlated symbol’s last two confirmed pivot highs on chart bars are falling AND its latest confirmed pivot high is no more than the maximum pivot age bars old; pivot highs use the pivot lookback bars on each side
Long: on confirmation of a new chart-symbol pivot low, its last two confirmed pivot lows are falling AND the correlated symbol’s last two confirmed pivot lows on chart bars are rising AND its latest confirmed pivot low is no more than the maximum pivot age bars old; pivot lows use the pivot lookback bars on each side
Long: a tracked, un-inverted bearish FVG zone formed where high < low[2] and low[2] - high is at least the minimum gap size, AND close > that zone’s upper boundary
Short: a tracked, un-inverted bullish FVG zone formed where low > high[2] and low - high[2] is at least the minimum gap size, AND close < that zone’s lower boundary
Long: low < previous T1 candle low AND close > previous T1 candle low
Short: high > previous T1 candle high AND close < previous T1 candle high
Long: latest chart-instrument pivot low (P1 bars each side) < preceding chart-instrument pivot low (P1 bars each side) AND latest correlated-instrument pivot low (P1 bars each side) > preceding correlated-instrument pivot low (P1 bars each side) AND bars since latest correlated-instrument pivot low <= P2
Short: latest chart-instrument pivot high (P1 bars each side) > preceding chart-instrument pivot high (P1 bars each side) AND latest correlated-instrument pivot high (P1 bars each side) < preceding correlated-instrument pivot high (P1 bars each side) AND bars since latest correlated-instrument pivot high <= P2