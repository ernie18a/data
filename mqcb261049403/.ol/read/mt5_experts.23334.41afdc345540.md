Calculation: Range high = highest high of prior completed chart-timeframe bars in the sliding window
Calculation: Range low = lowest low of prior completed chart-timeframe bars in the sliding window
Calculation: Daily range = either Range high − Range low, or the arithmetic mean of close[i] − close[i+1] across the sliding window
Long: current price ≥ Range high + Daily range × offset coefficient
Short: current price ≤ Range low − Daily range × offset coefficient
Exit: long, price ≤ entry price − Daily range × stop-loss coefficient OR price ≥ entry price + Daily range × take-profit coefficient
Exit: short, price ≥ entry price + Daily range × stop-loss coefficient OR price ≤ entry price − Daily range × take-profit coefficient