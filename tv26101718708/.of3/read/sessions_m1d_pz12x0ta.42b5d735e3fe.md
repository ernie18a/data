Calculation: MidnightOpen = open of the most recent bar where the calendar day in the session time zone differs from the prior bar's calendar day and the hour is below cutoff hour
Calculation: DealingMid = (high(T1, last completed bar) + low(T1, last completed bar)) / 2
Calculation: RangePosition = (close - DealingMid) / (high(T1, last completed bar) - low(T1, last completed bar))
Long: RangePosition <= -neutral band
Long: close > MidnightOpen
Long: close >= low(T1, last completed bar) AND close < DealingMid
Short: RangePosition >= neutral band
Short: close < MidnightOpen
Short: close <= high(T1, last completed bar) AND close >= DealingMid