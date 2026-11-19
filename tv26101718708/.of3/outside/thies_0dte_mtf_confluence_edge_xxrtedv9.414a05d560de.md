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