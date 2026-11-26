Calculation: SwingHighLevel = most recent confirmed Pivot High(high, pivot left, pivot right) value
Calculation: SwingLowLevel = most recent confirmed Pivot Low(low, pivot left, pivot right) value
Calculation: HigherHigh = SwingHighLevel > previous confirmed Pivot High value
Calculation: LowerHigh = SwingHighLevel <= previous confirmed Pivot High value
Calculation: HigherLow = SwingLowLevel > previous confirmed Pivot Low value
Calculation: LowerLow = SwingLowLevel <= previous confirmed Pivot Low value
Calculation: ExpansionVolume = volume / SMA(volume, volume average length) >= volume expansion multiplier
Calculation: ClosePosition = (close - low) / (high - low)
Calculation: BodyShare = abs(close - open) / (high - low)
Calculation: BullBreak = close > SwingHighLevel AND close[1] <= SwingHighLevel
Calculation: BearBreak = close < SwingLowLevel AND close[1] >= SwingLowLevel
Calculation: BullRetest = low <= SwingHighLevel AND close > SwingHighLevel AND close[1] > SwingHighLevel
Calculation: BearRetest = high >= SwingLowLevel AND close < SwingLowLevel AND close[1] < SwingLowLevel
Calculation: BullSweep = low < SwingLowLevel AND close > SwingLowLevel AND min(open, close) - low > wick ratio parameter * abs(close - open)
Calculation: BearSweep = high > SwingHighLevel AND close < SwingHighLevel AND high - max(open, close) > wick ratio parameter * abs(close - open)
Calculation: BullCandle = close > open AND ClosePosition >= bull candle close-position parameter AND BodyShare >= body ratio parameter
Calculation: BearCandle = close < open AND ClosePosition <= bear candle close-position parameter AND BodyShare >= body ratio parameter
Calculation: SwingLegVolumeRising = a Pivot High or Pivot Low is confirmed on this bar AND the volume of the swing leg ending on this bar > the volume of the swing leg ending at the previous pivot confirmation, where a swing leg spans the bars after one pivot confirmation through the next
Calculation: BullBreakScore = break base parameter + break weight * BullBreak + retest weight * BullRetest + break expansion weight * ExpansionVolume + candle weight * BullCandle + structure weight * HigherLow + swing weight * SwingLegVolumeRising
Calculation: BearBreakScore = break base parameter + break weight * BearBreak + retest weight * BearRetest + break expansion weight * ExpansionVolume + candle weight * BearCandle + structure weight * LowerHigh + swing weight * SwingLegVolumeRising
Calculation: BullSweepScore = sweep base parameter + sweep weight * BullSweep + sweep expansion weight * ExpansionVolume + sweep close weight * (ClosePosition > bull sweep close-position parameter)
Calculation: BearSweepScore = sweep base parameter + sweep weight * BearSweep + sweep expansion weight * ExpansionVolume + sweep close weight * (ClosePosition < bear sweep close-position parameter)
Calculation: SignalCooldownPassed = no earlier bar on which a break or sweep Long or Short rule was true, or bars since the latest such bar > cooldown parameter
Long: SignalCooldownPassed AND (BullBreak OR BullRetest) AND BullBreakScore >= minimum score parameter
Long: SignalCooldownPassed AND BullSweep AND BullSweepScore >= minimum score parameter
Short: SignalCooldownPassed AND (BearBreak OR BearRetest) AND BearBreakScore >= minimum score parameter
Short: SignalCooldownPassed AND BearSweep AND BearSweepScore >= minimum score parameter
Long: HigherHigh AND HigherLow
Short: LowerHigh AND LowerLow