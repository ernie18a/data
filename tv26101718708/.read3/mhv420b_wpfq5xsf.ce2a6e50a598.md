Calculation: direction state = on each chart bar, true if (T1 close of the bar still forming - T1 close of the last completed bar) / T1 close of the last completed bar > direction threshold, false if it is < -direction threshold, otherwise the previous chart-bar direction state
Long: direction state from post-signal delay chart bars ago AND HMA(close, HMA lookback) > HMA(close, same HMA lookback)[2 bars ago] AND position is flat
Short: NOT direction state from post-signal delay chart bars ago AND HMA(close, HMA lookback)[2 bars ago] > HMA(close, same HMA lookback) AND position is flat
Exit: Short, direction state AND close < low[close-position delay chart bars ago]
Exit: Long, NOT direction state AND close > high[close-position delay chart bars ago]