Calculation: Series = IF(mode is single, Source, IF(spread is log, LN(Source) - IF(beta is auto, SLOPE(LN(Source), LN(paired close), BetaLookback), ManualBeta) * LN(paired close), Source / paired close))
Calculation: ZScore = (Series - SMA(Series, Lookback)) / STDEV_pop(Series, Lookback)
Calculation: MeanRevGate = SLOPE(Series - Series[1], Series[1], Lookback) < -LN(2) / Lookback
Calculation: LongReady = position is flat AND NOT(ZScore > 0) AND (LongReady[1] OR (MeanRevGate AND ZScore < -EntryBand))
Calculation: LongNearReady = position is flat AND NOT(ZScore > 0) AND (LongNearReady[1] OR (MeanRevGate AND ZScore < -NearBand))
Calculation: ShortReady = position is flat AND NOT(ZScore < 0) AND (ShortReady[1] OR (MeanRevGate AND ZScore > EntryBand))
Calculation: ShortNearReady = position is flat AND NOT(ZScore < 0) AND (ShortNearReady[1] OR (MeanRevGate AND ZScore > NearBand))
Long: position is flat AND MeanRevGate AND ZScore crosses below -EntryBand
Long: position is flat AND LongReady[1] AND MeanRevGate AND ZScore crosses above -EntryBand
Long: position is flat AND LongNearReady[1] AND MeanRevGate AND ZScore crosses above -NearBand
Short: position is flat AND MeanRevGate AND ZScore crosses above EntryBand
Short: position is flat AND ShortReady[1] AND MeanRevGate AND ZScore crosses below EntryBand
Short: position is flat AND ShortNearReady[1] AND MeanRevGate AND ZScore crosses below NearBand
Exit: long, ZScore crosses above -ExitBand
Exit: long, ZScore crosses below -EntryBand
Exit: long, close < low at entry bar
Exit: long, ZScore crosses below -StopBand
Exit: short, ZScore crosses below ExitBand
Exit: short, ZScore crosses above EntryBand
Exit: short, close > high at entry bar
Exit: short, ZScore crosses above StopBand