Calculation: CloseLocation = (close - low) / (high - low), or 0.5 if high equals low
Calculation: VolumeOutlierScore = (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback)
Calculation: SmoothedDelta = EMA(normalized delta, delta smoothing length), where normalized delta = (2 * CloseLocation - 1) * volume / SMA(volume, volume lookback), or 0 if that SMA is 0
Calculation: BullPrint = VolumeOutlierScore >= z-score threshold AND CloseLocation >= 1 - close-in-range fraction
Calculation: BearPrint = VolumeOutlierScore >= z-score threshold AND CloseLocation <= close-in-range fraction
Calculation: BarsSinceEntry = bars since the last earlier bar on which LongEntry or ShortEntry was true, or infinity if none
Calculation: LongEntry = BullPrint AND SmoothedDelta > 0 AND close >= EMA(close, trend lookback) AND BarsSinceEntry >= minimum entry spacing
Calculation: ShortEntry = BearPrint AND SmoothedDelta < 0 AND close < EMA(close, trend lookback) AND BarsSinceEntry >= minimum entry spacing
Calculation: StopDistance = ATR(ATR lookback) * stop ATR multiple, evaluated on the bar of the most recent LongEntry or ShortEntry
Long: LongEntry
Long: BullPrint
Short: ShortEntry
Short: BearPrint
Exit: Long, high >= entry price + first target R multiple * StopDistance OR low <= entry price - StopDistance OR LongEntry
Exit: Short, low <= entry price - first target R multiple * StopDistance OR high >= entry price + StopDistance OR ShortEntry