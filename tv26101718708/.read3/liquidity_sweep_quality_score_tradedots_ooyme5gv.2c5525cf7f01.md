Calculation: LastSwingLow = last non-NA value of PivotLow(low, pivot lookback, pivot lookback) through the current bar
Calculation: LastSwingHigh = last non-NA value of PivotHigh(high, pivot lookback, pivot lookback) through the current bar
Calculation: WickToBody = IF ABS(close - open) = 0 THEN 0 ELSE IF low < LastSwingLow AND close > LastSwingLow THEN (MIN(open, close) - low) / ABS(close - open) ELSE IF high > LastSwingHigh AND close < LastSwingHigh THEN (high - MAX(open, close)) / ABS(close - open) ELSE 0
Calculation: BullSweep = low < LastSwingLow AND close > LastSwingLow AND WickToBody >= minimum wick to body ratio
Calculation: BearSweep = high > LastSwingHigh AND close < LastSwingHigh AND WickToBody >= minimum wick to body ratio
Calculation: SweepWeightedSum = wick weight * MIN(100, wick score scale * WickToBody / minimum wick to body ratio) + volume weight * NZ(PercentRank(volume, volume rank lookback), neutral volume score) + failed-break weight * (IF BullSweep THEN MIN(100, failed-break score scale * ((close - LastSwingLow) / ATR(ATR lookback))) ELSE MIN(100, failed-break score scale * ((LastSwingHigh - close) / ATR(ATR lookback)))) + HTF weight * NZ(MAX(0, 100 - HTF distance score scale * (MIN(ABS(close - High(T1, last completed bar, chart bars)), ABS(close - Low(T1, last completed bar, chart bars))) / ATR(ATR lookback))), 0)
Calculation: BullFollowThrough = BullSweep[1] AND NOT BearSweep[1] AND NOT BullSweep AND NOT BearSweep
Calculation: BearFollowThrough = BearSweep[1] AND NOT BullSweep AND NOT BearSweep
Calculation: LongQuality = MAX(0, (SweepWeightedSum[1] + follow-through weight * (IF close > open THEN 100 ELSE 0)) / MAX(sum of five weights, epsilon) - (IF regime penalty enabled AND EMA(close, shorter EMA lookback)[1] < EMA(close, longer EMA lookback)[1] AND ADX(regime ADX lookback)[1] >= trend ADX threshold THEN regime penalty points ELSE 0))
Calculation: ShortQuality = MAX(0, (SweepWeightedSum[1] + follow-through weight * (IF close < open THEN 100 ELSE 0)) / MAX(sum of five weights, epsilon) - (IF regime penalty enabled AND EMA(close, shorter EMA lookback)[1] > EMA(close, longer EMA lookback)[1] AND ADX(regime ADX lookback)[1] >= trend ADX threshold THEN regime penalty points ELSE 0))
Long: BullSweep
Short: BearSweep
Long: BullFollowThrough
Short: BearFollowThrough
Long: BullFollowThrough AND LongQuality >= lower quality threshold
Long: BullFollowThrough AND LongQuality >= higher quality threshold
Short: BearFollowThrough AND ShortQuality >= lower quality threshold
Short: BearFollowThrough AND ShortQuality >= higher quality threshold