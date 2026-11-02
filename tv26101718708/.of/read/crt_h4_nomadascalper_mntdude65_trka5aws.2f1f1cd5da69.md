Calculation: Timed range = high and low aggregated from chart bars in each configured New York clock window; use the last completed window for that slot. Monitor it from the first chart bar outside the window through a configured projection period, ending early when, after a first purge, a later bar reaches the opposite range extreme. A new window for the same slot replaces the monitored range when it completes.
Calculation: First purge = the first monitored chart bar with high >= timed-range high OR low <= timed-range low. If both occur on that bar, classify it as a high purge when close >= the range midpoint and otherwise as a low purge.
Calculation: Higher-timeframe sweep state = for each of several distinct, ordered higher timeframes, separately latch a high sweep when a completed chart bar has high > the last completed higher-timeframe bar's high AND close < that high, and latch a low sweep when low < the last completed higher-timeframe bar's low AND close > that low. Reset both latches at the start of each new bar of that higher timeframe.
Long: The completed timed candle's close >= its open.
Short: The completed timed candle's close < its open.
Long: The current bar is the first low purge of a monitored timed range.
Short: The current bar is the first high purge of a monitored timed range.
Long: The timed range is being monitored AND low < its low AND high <= its high AND close >= its low AND close <= its high.
Short: The timed range is being monitored AND high > its high AND close >= its low AND close <= its high.
Long: A higher-timeframe low sweep first latches in its current higher-timeframe period.
Short: A higher-timeframe high sweep first latches in its current higher-timeframe period.
Long: The count of latched higher-timeframe low sweeps >= a threshold AND the count of latched higher-timeframe high sweeps < the same threshold.
Short: The count of latched higher-timeframe high sweeps >= a threshold AND the count of latched higher-timeframe low sweeps < the same threshold.