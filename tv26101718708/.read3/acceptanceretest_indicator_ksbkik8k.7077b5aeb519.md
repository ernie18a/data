Calculation: PriorSessionHigh = highest high of the most recent completed regular-session bars
Calculation: PriorSessionLow = lowest low of the most recent completed regular-session bars
Calculation: OvernightHigh = highest high of non-regular-session bars since the last regular-session close, frozen during the regular session
Calculation: OvernightLow = lowest low of non-regular-session bars since the last regular-session close, frozen during the regular session
Calculation: Level = PriorSessionHigh, PriorSessionLow, OvernightHigh, or OvernightLow, each evaluated as a separate level
Calculation: RangeOfLevel = PriorSessionHigh - PriorSessionLow if Level is a prior-session level, else OvernightHigh - OvernightLow
Calculation: LevelActive = NOT (ABS(Level - PairedLevel) <= close x cluster percent / 100 AND Level is inside PairedLevel), where PairedLevel is the other level on the same side (high or low) and inside means lower high or higher low
Calculation: InWindow = bar time is inside a trading window
Calculation: LongAttemptAge = bars since the most recent bar where close[1] <= Level AND close > Level AND InWindow AND LevelActive
Calculation: ShortAttemptAge = bars since the most recent bar where close[1] >= Level AND close < Level AND InWindow AND LevelActive
Calculation: LongBaseHigh = highest high over the last (LongAttemptAge - no-reclaim bars) bars through the prior bar
Calculation: LongBaseLow = lowest low over the last (LongAttemptAge - no-reclaim bars) bars through the prior bar
Calculation: LongRecoveryHigh = highest high from the bar holding the lowest low through the prior bar, over the same bars
Calculation: LongTrigger = close > LongRecoveryHigh OR (LongBaseHigh - LongBaseLow <= base range multiple x ATR(atr length) AND LongAttemptAge - no-reclaim bars >= minimum base bars AND close > LongBaseHigh)
Calculation: ShortBaseHigh = highest high over the last (ShortAttemptAge - no-reclaim bars) bars through the prior bar
Calculation: ShortBaseLow = lowest low over the last (ShortAttemptAge - no-reclaim bars) bars through the prior bar
Calculation: ShortRecoveryLow = lowest low from the bar holding the highest high through the prior bar, over the same bars
Calculation: ShortTrigger = close < ShortRecoveryLow OR (ShortBaseHigh - ShortBaseLow <= base range multiple x ATR(atr length) AND ShortAttemptAge - no-reclaim bars >= minimum base bars AND close < ShortBaseLow)
Calculation: LongStop = LongBaseLow - close x stop buffer percent / 100, evaluated at the entry bar
Calculation: ShortStop = ShortBaseHigh + close x stop buffer percent / 100, evaluated at the entry bar
Calculation: LongTarget = lowest of Level + RangeOfLevel and every other active level price strictly between Level and Level + RangeOfLevel, evaluated at the entry bar
Calculation: ShortTarget = highest of Level - RangeOfLevel and every other active level price strictly between Level - RangeOfLevel and Level, evaluated at the entry bar
Calculation: RiskCap = MAX(RangeOfLevel, ATR(atr length) x ATR cap multiple) / stop cap divisor
Long: LevelActive AND InWindow AND LongAttemptAge >= no-reclaim bars + 1 AND LongAttemptAge <= no-reclaim bars + maximum watch bars AND lowest close from the attempt bar through the current bar > Level AND LongTrigger AND LongTrigger false on every earlier bar after the no-reclaim pass AND close - LongStop <= RiskCap AND ABS(LongTarget - close) >= minimum reward-to-risk x (close - LongStop)
Short: LevelActive AND InWindow AND ShortAttemptAge >= no-reclaim bars + 1 AND ShortAttemptAge <= no-reclaim bars + maximum watch bars AND highest close from the attempt bar through the current bar < Level AND ShortTrigger AND ShortTrigger false on every earlier bar after the no-reclaim pass AND ShortStop - close <= RiskCap AND ABS(ShortTarget - close) >= minimum reward-to-risk x (ShortStop - close)
Exit: long, low <= LongStop OR high >= LongTarget OR bar time at or after time-stop time
Exit: short, high >= ShortStop OR low <= ShortTarget OR bar time at or after time-stop time