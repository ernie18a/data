Calculation: Ranging = EMA(ATR/close, shorter length) < EMA(ATR/close, longer length)
Calculation: LongTrend = OBV > EMA(OBV) AND NOT Ranging
Calculation: UpAligned = VWMA(close) > SMA(close) AND close >= VWMA(close)
Calculation: MFIHigherLow = on the bar where an MFI pivot low is confirmed (more left bars than right bars), that pivot's MFI value > the previous MFI pivot low's value
Calculation: PriceLevel = a stored low price; it is set to the current bar's low when (low*(1+tol) < PriceLevel) OR (a price pivot low with equal left/right bars is confirmed on this bar AND low*(1-tol) > PriceLevel)
Calculation: PriceHigherLow = a price pivot low is confirmed on this bar AND PriceLevel was raised on this bar
Calculation: Support = the current bar's low, recorded when a pivot low (equal left/right bars, longer than the price pivot above) is confirmed; also reset to the current low when low*(1+tol) < Support
Long: Stochastic %K >= 50 AND MFI crosses above 50 AND UpAligned AND LongTrend AND NOT Ranging
Long: position is flat AND, on the current bar or any of the previous few bars (small fixed count), all of the following held on the same bar: MFIHigherLow AND PriceHigherLow AND UpAligned AND Stochastic %K >= 50 AND Ranging
Long: VWMA(close) crosses above SMA(close)
Short: VWMA(close) crosses below SMA(close)
Exit: long, high >= entry price * (1 + take-profit fraction)
Exit: long, close <= Support as recorded on the entry bar