Calculation: R = high of the last completed higher-timeframe bar (previous day) - low of the same bar; DayOpen = open of the higher-timeframe bar still forming (current day)
Calculation: LongEntry = PrevHigh - r1*R; LongStop = PrevHigh - r2*R, with r2 > r1 (LongStop below LongEntry); LongTarget_k = LongEntry + m_k*R for k=1..3, with m1 < m2 < m3
Calculation: ShortEntry = PrevLow + r1*R; ShortStop = PrevLow + r2*R (above ShortEntry); ShortTarget_k = ShortEntry - m_k*R for k=1..3, same r1, r2, m_k as long, where PrevHigh and PrevLow are the high and low of the last completed higher-timeframe bar
Long: close > DayOpen AND low <= LongEntry
Short: close < DayOpen AND high >= ShortEntry
Exit: long, low <= LongStop OR high >= LongTarget_k (staged targets, k=1..3)
Exit: short, high >= ShortStop OR low <= ShortTarget_k (staged targets, k=1..3)