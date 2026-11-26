Calculation: OpeningRangeHigh = highest high of chart bars in the opening-range window of the still-forming current T1 bar, defined only after that window has ended
Calculation: OpeningRangeLow = lowest low of chart bars in the opening-range window of the still-forming current T1 bar, defined only after that window has ended
Calculation: Buffer = ATR(atr length) * buffer multiplier
Calculation: LongBreakouts = count of earlier chart bars of the still-forming current T1 bar where close crosses above OpeningRangeHigh + Buffer AND bar time within trade session
Calculation: ShortBreakouts = count of earlier chart bars of the still-forming current T1 bar where close crosses below OpeningRangeLow - Buffer AND bar time within trade session
Calculation: LongStop = value at entry bar of (stop-from-ATR switch is on ? entry price - ATR(atr length) * stop multiplier : OpeningRangeLow)
Calculation: ShortStop = value at entry bar of (stop-from-ATR switch is on ? entry price + ATR(atr length) * stop multiplier : OpeningRangeHigh)
Long: close crosses above OpeningRangeHigh + Buffer AND bar time within trade session AND LongBreakouts < max trades per side per day
Short: close crosses below OpeningRangeLow - Buffer AND bar time within trade session AND ShortBreakouts < max trades per side per day
Long: close > OpeningRangeHigh
Short: close < OpeningRangeLow
Exit: long, low <= LongStop OR high >= entry price + (entry price - LongStop) * first target R multiple
Exit: short, high >= ShortStop OR low <= entry price - (ShortStop - entry price) * first target R multiple
Exit: long, close crosses above OpeningRangeHigh + Buffer AND bar time within trade session AND LongBreakouts < max trades per side per day
Exit: short, close crosses below OpeningRangeLow - Buffer AND bar time within trade session AND ShortBreakouts < max trades per side per day