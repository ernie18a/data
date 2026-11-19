Calculation: bullish volume = if close > open then volume else volume × (high − open) / (high − low)
Calculation: bearish volume = if open > close then volume else volume × (open − low) / (high − low)
Calculation: smoothed bullish volume = VWMA(bullish volume, shared lookback)
Calculation: smoothed bearish volume = VWMA(bearish volume, shared lookback)
Calculation: flatness measure = ABS(smoothed bullish volume + smoothed bearish volume) / 2
Calculation: bullish zone = smoothed bullish volume > smoothed bearish volume AND flatness measure / smoothed bullish volume < 1 − flatness percentage / 100
Calculation: bearish zone = smoothed bullish volume < smoothed bearish volume AND flatness measure / smoothed bearish volume < 1 − flatness percentage / 100
Long: direction permits long AND bullish zone AND bullish zone was false on the prior chart bar
Short: direction permits short AND bearish zone AND bearish zone was false on the prior chart bar
Exit: long, bearish zone AND bearish zone was false on the prior chart bar AND direction forbids short entries
Exit: short, bullish zone AND bullish zone was false on the prior chart bar AND direction forbids long entries