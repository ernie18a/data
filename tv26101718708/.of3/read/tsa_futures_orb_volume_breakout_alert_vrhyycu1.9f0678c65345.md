Calculation: InOpeningRange = bar time is within opening range length from the start of the trade window
Calculation: OpeningRangeHigh = highest high of bars with InOpeningRange in the current trade session
Calculation: OpeningRangeLow = lowest low of bars with InOpeningRange in the current trade session
Calculation: ActiveBar = bar time is in the trade window AND NOT InOpeningRange
Calculation: RelativeVolume = volume / SMA(volume[1], volume average length)
Calculation: LongBreakout = ActiveBar AND RelativeVolume >= volume multiplier AND close > OpeningRangeHigh
Calculation: ShortBreakout = ActiveBar AND RelativeVolume >= volume multiplier AND close < OpeningRangeLow
Calculation: Reentry = ActiveBar AND close >= OpeningRangeLow AND close <= OpeningRangeHigh
Calculation: LongAlerted = LongBreakout occurred on an earlier bar of the current trade session with no ShortBreakout or Reentry bar between that bar and this bar
Calculation: ShortAlerted = ShortBreakout occurred on an earlier bar of the current trade session with no LongBreakout or Reentry bar between that bar and this bar
Long: LongBreakout AND NOT LongAlerted
Short: ShortBreakout AND NOT ShortAlerted