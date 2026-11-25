Calculation: Weighted average entry price = sum(entry price × lot size) / sum(lot size)
Calculation: Adaptive gap = round((highest high over range lookback prior chart bars - lowest low over range lookback prior chart bars) / range divisor / point size) × point size
Long: Flat AND close[2] <= close[1] AND RSI(close, lookback, T1, last completed bar, sampled on chart bars) < upper RSI threshold
Short: Flat AND close[2] > close[1] AND RSI(close, lookback, T1, last completed bar, sampled on chart bars) > lower RSI threshold
Long: Long position AND low <= most recent long entry price - fixed spacing parameter × point size
Short: Short position AND high >= most recent short entry price + fixed spacing parameter × point size
Long: Long position AND low <= most recent long entry price - adaptive gap
Short: Short position AND high >= most recent short entry price + adaptive gap
Exit: long, high >= weighted average entry price + target distance parameter × point size
Exit: short, low <= weighted average entry price - target distance parameter × point size
Exit: short, CCI(close, lookback, T2, bar still forming, sampled on chart bars) > CCI threshold
Exit: long, CCI(close, lookback, T2, bar still forming, sampled on chart bars) < -CCI threshold