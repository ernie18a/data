Calculation: BullTFCount = count over i in 1..5 of (close(Ti, last completed bar) > EMA(close, EMA length, Ti, last completed bar) AND RSI(close, RSI length, Ti, last completed bar) > neutral RSI level)
Calculation: BearTFCount = count over i in 1..5 of (close(Ti, last completed bar) <= EMA(close, EMA length, Ti, last completed bar) AND RSI(close, RSI length, Ti, last completed bar) <= neutral RSI level)
Long: BullTFCount >= min confluence
Short: BearTFCount >= min confluence