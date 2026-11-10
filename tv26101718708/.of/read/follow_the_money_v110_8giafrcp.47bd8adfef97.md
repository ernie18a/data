Calculation: Shorter moving average = SMA or EMA of close; longer moving average = SMA of close, with a longer period than the shorter moving average.
Calculation: Volume expansion = 100 * (volume - SMA(volume)) / SMA(volume), or 0 when SMA(volume) = 0.
Calculation: Moving-average slope = 100 * (shorter moving average - shorter moving average a lookback ago) / shorter moving average a lookback ago.
Long: OBV > SMA(OBV).
Long: Accumulation/distribution line > SMA(accumulation/distribution line).
Exit: long, close <= shorter moving average for at least a confirmation number of consecutive bars AND volume expansion >= threshold on at least one bar in the current consecutive run of closes <= shorter moving average.
Exit: long, close < shorter moving average * (1 - stop percentage / 100).
Exit: long, 50% of the position, absolute moving-average slope <= flattening threshold AND close > shorter moving average AND no prior trim in the current position.