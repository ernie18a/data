Calculation: Dynamic grid step = (highest high − lowest low over the longer lookback of completed chart bars) ÷ scaling factor, bounded by lower and upper multiples of the default step
Calculation: RSI(14) = relative strength index on a higher timeframe's last completed bar
Calculation: CCI(55) = commodity channel index on a lower timeframe's currently forming bar
Long: position side = flat AND (previous completed chart bar close ≤ most recent completed chart bar close AND RSI(14) < upper RSI threshold OR position side = long AND last long entry price − current price ≥ grid step)
Short: position side = flat AND (previous completed chart bar close > most recent completed chart bar close AND RSI(14) > lower RSI threshold OR position side = short AND current price − last short entry price ≥ grid step)
Exit: long, current price ≥ volume-weighted average entry price + profit target OR CCI(55) < negative exit threshold
Exit: short, current price ≤ volume-weighted average entry price − profit target OR CCI(55) > exit threshold