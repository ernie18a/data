Calculation: Prior T1 VAH = high(T1, last completed bar) - (high(T1, last completed bar) - low(T1, last completed bar)) * prior-day range fraction, sampled on chart bars
Calculation: Prior T1 VAL = low(T1, last completed bar) + (high(T1, last completed bar) - low(T1, last completed bar)) * prior-day range fraction, sampled on chart bars
Calculation: Composite VAH = maximum profile price over the longer lookback T1 - (maximum profile price - minimum profile price) * profile fraction, calculated on chart bars using the forming T1 profile
Calculation: Composite VAL = minimum profile price over the longer lookback T1 + (maximum profile price - minimum profile price) * profile fraction, calculated on chart bars using the forming T1 profile
Long: close > Composite VAH AND close > Prior T1 VAH
Short: close < Composite VAL AND close < Prior T1 VAL