Calculation: LastSwingHigh(length) = most recent non-empty value of Pivot High(high, length, length)
Calculation: LastSwingLow(length) = most recent non-empty value of Pivot Low(low, length, length)
Calculation: StructureTrend(length) = -1 if close crosses below LastSwingLow(length); else +1 if close crosses above LastSwingHigh(length); else StructureTrend(length)[1]; 0 before the first such bar
Calculation: BullStructureBreak = close crosses above LastSwingHigh(pivot length) AND StructureTrend(pivot length)[1] != +1
Calculation: BearStructureBreak = close crosses below LastSwingLow(pivot length) AND StructureTrend(pivot length)[1] != -1
Calculation: BullLiquiditySweep = low < LastSwingLow(reversal swing length) AND close > LastSwingLow(reversal swing length)
Calculation: BearLiquiditySweep = high > LastSwingHigh(reversal swing length) AND close < LastSwingHigh(reversal swing length)
Calculation: BullSweepInDowntrend = BullLiquiditySweep AND close < EMA(close, trend EMA length)
Calculation: BearSweepInUptrend = BearLiquiditySweep AND close > EMA(close, trend EMA length)
Calculation: BullBandReclaim = low < EMA(close, band EMA length) - ATR(ATR length) * rejection ATR multiplier AND close > EMA(close, band EMA length) - ATR(ATR length) * band ATR multiplier
Calculation: BearBandReject = high > EMA(close, band EMA length) + ATR(ATR length) * rejection ATR multiplier AND close < EMA(close, band EMA length) + ATR(ATR length) * band ATR multiplier
Calculation: BullBreakdownRecovery = low < low[1] AND close > low[1] AND close > open
Calculation: BearBreakoutRejection = high > high[1] AND close < high[1] AND close < open
Calculation: BullTrigger = BullLiquiditySweep OR BullBandReclaim OR BullBreakdownRecovery
Calculation: BearTrigger = BearLiquiditySweep OR BearBandReject OR BearBreakoutRejection
Calculation: BullRsiDivergence = most recent non-empty Pivot Low(low, reversal swing length) < second most recent non-empty Pivot Low(low, reversal swing length) AND RSI(close, RSI length) at the more recent pivot bar > RSI(close, RSI length) at the second most recent pivot bar
Calculation: BearRsiDivergence = most recent non-empty Pivot High(high, reversal swing length) > second most recent non-empty Pivot High(high, reversal swing length) AND RSI(close, RSI length) at the more recent pivot bar < RSI(close, RSI length) at the second most recent pivot bar
Calculation: RelativeVolumeSpike = volume / SMA(volume, volume MA length) >= climax multiplier
Calculation: HighVolumeBar = volume > SMA(volume, volume MA length) * volume multiplier
Calculation: AnnualVolumeRecordBar = chart timeframe is T3, T4, or T5 AND (volume = highest volume of all bars so far OR (volume = highest volume over one-year lookback AND volume < highest volume of all bars so far))
Calculation: UpDownVolumeRatio = Sum of volume over up-down window where close > close[1] / Sum of volume over up-down window where close < close[1]; 1 if the denominator is 0
Calculation: PriceNearSwingLow = low <= LastSwingLow(reversal swing length) + ATR(proximity ATR length) * proximity multiplier
Calculation: PriceNearSwingHigh = high >= LastSwingHigh(reversal swing length) - ATR(proximity ATR length) * proximity multiplier
Calculation: BullRejectionWick = (min(open, close) - low) > body * wick body ratio AND (min(open, close) - low) > ATR(ATR length) * wick ATR fraction; body = |close - open|, or minimum tick size if that is 0
Calculation: BearRejectionWick = (high - max(open, close)) > body * wick body ratio AND (high - max(open, close)) > ATR(ATR length) * wick ATR fraction; body = |close - open|, or minimum tick size if that is 0
Calculation: StrongUptrend = close > EMA(close, short EMA length) AND EMA(close, short EMA length) > EMA(close, mid EMA length) AND EMA(close, mid EMA length) > EMA(close, long EMA length) AND ADX(ADX length) > ADX threshold
Calculation: StrongDowntrend = close < EMA(close, short EMA length) AND EMA(close, short EMA length) < EMA(close, mid EMA length) AND EMA(close, mid EMA length) < EMA(close, long EMA length) AND ADX(ADX length) > ADX threshold
Calculation: BullPoints = (BullSweepInDowntrend ? sweep-in-trend weight : BullLiquiditySweep ? sweep weight : 0) + (BullRsiDivergence ? divergence weight : 0) + (BullRejectionWick ? wick weight : 0) + (RelativeVolumeSpike ? climax weight : 0) + (BullBandReclaim ? band weight : 0) + (close > high[1] OR BullBreakdownRecovery ? micro weight : 0) + (Williams %R[1] <= Williams %R oversold level AND Williams %R > Williams %R[1] ? Williams hook weight : 0) + (number of T1, T2, T3 where StructureTrend(pivot length), computed on that timeframe's bars using the last completed bar, is >= 0 is at least MTF strictness ? MTF weight : 0) + (PriceNearSwingLow ? proximity weight : 0) + (RSI(close, RSI length) < bull fade RSI level AND RSI(close, RSI length) > RSI(close, RSI length)[1] ? fade weight : 0) + (UpDownVolumeRatio < bull up-down threshold ? up-down weight : 0) + (AnnualVolumeRecordBar AND close < EMA(close, trend EMA length) ? annual weight : 0)
Calculation: BearPoints = (BearSweepInUptrend ? sweep-in-trend weight : BearLiquiditySweep ? sweep weight : 0) + (BearRsiDivergence ? divergence weight : 0) + (BearRejectionWick ? wick weight : 0) + (RelativeVolumeSpike ? climax weight : 0) + (BearBandReject ? band weight : 0) + (close < low[1] OR BearBreakoutRejection ? micro weight : 0) + (Williams %R[1] >= Williams %R overbought level AND Williams %R < Williams %R[1] ? Williams hook weight : 0) + (number of T1, T2, T3 where StructureTrend(pivot length), computed on that timeframe's bars using the last completed bar, is <= 0 is at least MTF strictness ? MTF weight : 0) + (PriceNearSwingHigh ? proximity weight : 0) + (RSI(close, RSI length) > bear fade RSI level AND RSI(close, RSI length) < RSI(close, RSI length)[1] ? fade weight : 0) + (UpDownVolumeRatio > bear up-down threshold ? up-down weight : 0) + (AnnualVolumeRecordBar AND close > EMA(close, trend EMA length) ? annual weight : 0)
Calculation: BullEarlySignal = BullTrigger AND (ADX filter disabled OR NOT StrongDowntrend OR BullSweepInDowntrend OR BullBandReclaim) AND BullPoints >= reversal score minimum AND no BullEarlySignal on any bar from the most recent swing-low confirmation bar (reversal swing length) to the previous bar AND (no earlier BullEarlySignal OR bars since previous BullEarlySignal > reversal cooldown) AND (CHoCH cooldown = 0 OR no BearStructureBreak yet OR bars since last BearStructureBreak > CHoCH cooldown OR BullSweepInDowntrend) AND (extension requirement disabled OR close < EMA(close, trend EMA length) OR BullBandReclaim)
Calculation: BearEarlySignal = BearTrigger AND (ADX filter disabled OR NOT StrongUptrend OR BearSweepInUptrend OR BearBandReject) AND BearPoints >= reversal score minimum AND no BearEarlySignal on any bar from the most recent swing-high confirmation bar (reversal swing length) to the previous bar AND (no earlier BearEarlySignal OR bars since previous BearEarlySignal > reversal cooldown) AND (CHoCH cooldown = 0 OR no BullStructureBreak yet OR bars since last BullStructureBreak > CHoCH cooldown OR BearSweepInUptrend) AND (extension requirement disabled OR close > EMA(close, trend EMA length) OR BearBandReject)
Long: BullStructureBreak
Long: BullEarlySignal
Long: BullEarlySignal AND BullPoints >= strong reversal score minimum
Long: BullTrigger AND BullPoints >= setup score minimum AND NOT BullEarlySignal
Long: HighVolumeBar AND close >= open
Long: RSI(close, RSI length) > RSI midline
Short: BearStructureBreak
Short: BearEarlySignal
Short: BearEarlySignal AND BearPoints >= strong reversal score minimum
Short: BearTrigger AND BearPoints >= setup score minimum AND NOT BearEarlySignal
Short: HighVolumeBar AND close < open
Short: RSI(close, RSI length) <= RSI midline