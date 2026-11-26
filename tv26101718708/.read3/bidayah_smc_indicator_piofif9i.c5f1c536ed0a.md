Calculation: Phase(n) = bearish if high[n] > highest(high, n), else bullish if low[n] < lowest(low, n), else Phase(n)[1]
Calculation: NewHighPivot(n) = Phase(n) = bearish AND Phase(n)[1] = bullish
Calculation: NewLowPivot(n) = Phase(n) = bullish AND Phase(n)[1] = bearish
Calculation: HighPivot(n) = high[n] if NewHighPivot(n), else HighPivot(n)[1]
Calculation: LowPivot(n) = low[n] if NewLowPivot(n), else LowPivot(n)[1]
Calculation: BullEvent(n) = close crosses above HighPivot(n) AND (n = long lookback OR (HighPivot(short lookback) != HighPivot(long lookback) AND (confluence filter off OR high - max(close, open) > min(close, open - low))))
Calculation: BearEvent(n) = close crosses below LowPivot(n) AND (n = long lookback OR (LowPivot(short lookback) != LowPivot(long lookback) AND (confluence filter off OR high - max(close, open) < min(close, open - low))))
Calculation: BullArmed(n) = NewHighPivot(n) OR (BullArmed(n)[1] AND NOT BullEvent(n)[1])
Calculation: BearArmed(n) = NewLowPivot(n) OR (BearArmed(n)[1] AND NOT BearEvent(n)[1])
Long: BullEvent(long lookback) AND BullArmed(long lookback)
Long: BullEvent(short lookback) AND BullArmed(short lookback)
Short: BearEvent(long lookback) AND BearArmed(long lookback)
Short: BearEvent(short lookback) AND BearArmed(short lookback)
Calculation: AdjHigh = low if (high - low) >= volatility multiplier * ATR(atr length), else high
Calculation: AdjLow = high if (high - low) >= volatility multiplier * ATR(atr length), else low
Calculation: BullOBs(n) = BullOBs(n)[1] without each v where low[1] < v, plus the minimum AdjLow from the HighPivot(n) bar through the prior bar if BullEvent(n) AND BullArmed(n)
Calculation: BearOBs(n) = BearOBs(n)[1] without each v where high[1] > v, plus the maximum AdjHigh from the LowPivot(n) bar through the prior bar if BearEvent(n) AND BearArmed(n)
Short: low < v for any v in BullOBs(long lookback)
Short: low < v for any v in BullOBs(short lookback)
Long: high > v for any v in BearOBs(long lookback)
Long: high > v for any v in BearOBs(short lookback)
Calculation: RangeHigh = HighPivot(long lookback) if NewHighPivot(long lookback), else max(high, RangeHigh[1])
Calculation: RangeLow = LowPivot(long lookback) if NewLowPivot(long lookback), else min(low, RangeLow[1])
Short: close >= (1 - zone fraction) * RangeHigh + zone fraction * RangeLow
Long: close <= (1 - zone fraction) * RangeLow + zone fraction * RangeHigh
Calculation: NewT1Bar = first chart bar of a new T1 bar
Calculation: T1Return = (close_T1[1] - open_T1[1]) / (open_T1[1] * 100)
Calculation: GapThreshold = threshold factor * cumulative sum of abs(T1Return) over NewT1Bar bars / bar index, if auto threshold on, else 0
Long: NewT1Bar AND low_T1[0] > high_T1[2] AND close_T1[1] > high_T1[2] AND T1Return > GapThreshold
Short: NewT1Bar AND high_T1[0] < low_T1[2] AND close_T1[1] < low_T1[2] AND -T1Return > GapThreshold
Short: NewHighPivot(equal lookback) AND abs(HighPivot(equal lookback) - HighPivot(equal lookback)[1]) < equal threshold * ATR(atr length)
Long: NewLowPivot(equal lookback) AND abs(LowPivot(equal lookback) - LowPivot(equal lookback)[1]) < equal threshold * ATR(atr length)
Calculation: ShortBias = bearish if BearEvent(short lookback) AND BearArmed(short lookback), else bullish if BullEvent(short lookback) AND BullArmed(short lookback), else ShortBias[1]
Long: ShortBias = bullish
Short: ShortBias != bullish