Calculation: Range = high - low of the last completed bar of a higher timeframe (the day); PDH = that bar's high; PDL = that bar's low
Calculation: DayOpen = open of the bar still forming on that same higher timeframe
Calculation: LongEntry = PDH - a*Range; LongStop = PDH - b*Range, with 0 < a < b; LongTarget_k = LongEntry + m_k*Range for k=1..3, with m_1 < m_2 < m_3
Calculation: ShortEntry = PDL + a*Range; ShortStop = PDL + b*Range; ShortTarget_k = ShortEntry - m_k*Range for k=1..3 (same a, b, m_k as the long side)
Long: close > DayOpen AND low <= LongEntry (entry price = LongEntry)
Short: close < DayOpen AND high >= ShortEntry (entry price = ShortEntry)
Exit: long, low <= LongStop OR high >= LongTarget_k (the three targets are successive take-profit levels)
Exit: short, high >= ShortStop OR low <= ShortTarget_k (the three targets are successive take-profit levels)