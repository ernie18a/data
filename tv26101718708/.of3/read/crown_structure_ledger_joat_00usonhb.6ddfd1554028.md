Calculation: SwingHigh(length) = most recent non-na PivotHigh(high, length, length)
Calculation: SwingLow(length) = most recent non-na PivotLow(low, length, length)
Calculation: Band = ATR(atr length) * band multiplier * (max(depth floor, EMA(ATR(atr length) / SMA(ATR(atr length), atr length), depth length)) if adaptive flag, else 1)
Calculation: BullBreak(length, allowance) = bar completed AND close > SwingHigh(length) + Band * allowance
Calculation: BearBreak(length, allowance) = bar completed AND close < SwingLow(length) - Band * allowance
Calculation: State(length, allowance) = Bearish if BearBreak(length, allowance), else Bullish if BullBreak(length, allowance), else State(length, allowance)[1]
Calculation: VolumePressure(length) = (sum of volume over last length bars where close >= open - sum of volume over those bars where close < open) / max(sum of volume over those bars, 1)
Calculation: ReferenceHigh = SwingHigh(long-term length) if non-na, else SwingHigh(intermediate-term length) if non-na, else SwingHigh(short-term length)
Calculation: ReferenceLow = SwingLow(long-term length) if non-na, else SwingLow(intermediate-term length) if non-na, else SwingLow(short-term length)
Calculation: RangePosition = 0 if ReferenceHigh or ReferenceLow is na, else (close - (ReferenceHigh + ReferenceLow) / 2) / (ReferenceHigh - ReferenceLow)
Calculation: FastEmaSlope = LinReg(EMA(close, fast EMA length), slope length, 0) - LinReg(EMA(close, fast EMA length), slope length, 1)
Calculation: Bias = (trend weight if EMA(close, fast EMA length) > EMA(close, slow EMA length), else -trend weight) + pressure weight * VolumePressure(pressure length) + location weight * RangePosition + slope weight * FastEmaSlope / ATR(atr length)
Long: BullBreak(long-term length, long-term allowance)
Short: BearBreak(long-term length, long-term allowance)
Long: BullBreak(short-term length, short-term allowance) OR BullBreak(intermediate-term length, intermediate-term allowance)
Short: BearBreak(short-term length, short-term allowance) OR BearBreak(intermediate-term length, intermediate-term allowance)
Long: BullBreak(short-term length, short-term allowance) AND State(short-term length, short-term allowance)[1] != Bullish
Long: BullBreak(intermediate-term length, intermediate-term allowance) AND State(intermediate-term length, intermediate-term allowance)[1] != Bullish
Long: BullBreak(long-term length, long-term allowance) AND State(long-term length, long-term allowance)[1] != Bullish
Short: BearBreak(short-term length, short-term allowance) AND State(short-term length, short-term allowance)[1] != Bearish
Short: BearBreak(intermediate-term length, intermediate-term allowance) AND State(intermediate-term length, intermediate-term allowance)[1] != Bearish
Short: BearBreak(long-term length, long-term allowance) AND State(long-term length, long-term allowance)[1] != Bearish
Long: Bias >= 0
Short: Bias < 0