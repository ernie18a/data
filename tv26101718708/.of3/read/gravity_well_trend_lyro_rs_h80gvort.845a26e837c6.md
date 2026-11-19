Calculation: volume-weighted center = VWMA(selected price field, center lookback)
Calculation: normalized distance = (selected price field - volume-weighted center) / ATR(ATR lookback)
Long: signal mode is Trend AND normalized distance > escape distance AND volume-weighted center > volume-weighted center[1] AND position side is not long
Short: signal mode is Trend AND normalized distance < -escape distance AND volume-weighted center < volume-weighted center[1] AND position side is not short
Long: signal mode is Midline AND selected price field > volume-weighted center AND position side is not long
Short: signal mode is Midline AND selected price field < volume-weighted center AND position side is not short
Long: signal mode is Bands AND selected price field crosses above volume-weighted center - band width * ATR(ATR lookback) AND position side is not long
Short: signal mode is Bands AND selected price field crosses below volume-weighted center + band width * ATR(ATR lookback) AND position side is not short