Calculation: RelativeVolume(instrument, T) = volume / SMA(volume, volume lookback), or 0 when the SMA is not positive; calculate on T bars and read on chart bars from T's forming bar, or its last completed bar when confirmed mode is enabled.
Calculation: DeltaPressure(instrument, T) = EMA(RelativeVolume(instrument, T) * (high > low ? 2 * (close - low) / (high - low) - 1 : 0), delta lookback); calculate on T bars and read on chart bars from T's forming bar, or its last completed bar when confirmed mode is enabled.
Calculation: TimeframeScore(T) = 0 when the session filter is enabled and the chart bar is outside the configured America/New_York session; otherwise +1 when the mean RelativeVolume(T) across both source instruments exceeds the relative volume threshold, their DeltaPressure(T) values sum to more than 0, and both close above open; -1 when the mean RelativeVolume(T) exceeds the relative volume threshold, their DeltaPressure(T) values sum to less than 0, and both close below open; otherwise 0. Evaluate on chart bars using T values from the selected T bar. T1, T2, T3, and T4 are separate timeframe parameters; the volume lookback, delta lookback, relative volume threshold, session setting, and confirmed mode are shared.
Calculation: TotalScore = TimeframeScore(T1) + TimeframeScore(T2) + TimeframeScore(T3) + TimeframeScore(T4), evaluated on chart bars.
Long: TimeframeScore(T1) > 0 OR TimeframeScore(T2) > 0 OR TimeframeScore(T3) > 0 OR TimeframeScore(T4) > 0
Short: TimeframeScore(T1) < 0 OR TimeframeScore(T2) < 0 OR TimeframeScore(T3) < 0 OR TimeframeScore(T4) < 0
Long: TotalScore > 0
Short: TotalScore < 0
Long: TotalScore >= strong signal threshold
Short: TotalScore <= -strong signal threshold
Long: TotalScore >= strong signal threshold for the configured persistence length of consecutive chart bars AND that condition was not met for the same length ending on the previous chart bar
Short: TotalScore <= -strong signal threshold for the configured persistence length of consecutive chart bars AND that condition was not met for the same length ending on the previous chart bar
Calculation: relative volume = volume / SMA(volume, volume-average length), or zero when the average is not positive
Calculation: normalized pressure = EMA(relative volume × candle range position, pressure EMA length), where candle range position = 2 × (close − low) / (high − low) − 1, or zero when high equals low
Calculation: timeframe score = 1 when the average relative volume of the configured SPY and ES instruments exceeds the relative-volume threshold, their normalized pressures sum to more than zero, both closes exceed their opens, and the session filter is disabled or the chart bar is within the configured session; −1 when the average relative volume exceeds the threshold, their normalized pressures sum to less than zero, both closes are below their opens, and the session filter is disabled or the chart bar is within the configured session; otherwise 0. Use current timeframe values unless confirmed-bar mode selects the previous completed bar.
Long: timeframe score(T1) = 1 OR timeframe score(T2) = 1 OR timeframe score(T3) = 1 OR timeframe score(T4) = 1
Short: timeframe score(T1) = −1 OR timeframe score(T2) = −1 OR timeframe score(T3) = −1 OR timeframe score(T4) = −1
Long: sum of timeframe scores(T1, T2, T3, T4) > 0
Short: sum of timeframe scores(T1, T2, T3, T4) < 0
Long: sum of timeframe scores(T1, T2, T3, T4) ≥ strong-score threshold
Short: sum of timeframe scores(T1, T2, T3, T4) ≤ −strong-score threshold
Long: sum of timeframe scores(T1, T2, T3, T4) is at least the strong-score threshold on each of the configured number of consecutive chart bars, and the preceding chart bar did not have such a qualifying run
Short: sum of timeframe scores(T1, T2, T3, T4) is at most the negative strong-score threshold on each of the configured number of consecutive chart bars, and the preceding chart bar did not have such a qualifying run