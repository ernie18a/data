Calculation: bearish bar count = number of the most recent lookback T1 bars with open > close, including the bar still forming
Calculation: bullish bar count = number of the most recent lookback T1 bars with open < close, including the bar still forming
Long: bearish bar count > bullish bar count AND (current hour = base-hour parameter 1 + hour-shift parameter OR current hour = base-hour parameter 2 + hour-shift parameter) AND current minute < minute-cutoff parameter
Short: bullish bar count > bearish bar count AND (current hour = base-hour parameter 1 + hour-shift parameter OR current hour = base-hour parameter 2 + hour-shift parameter) AND current minute < minute-cutoff parameter
Exit: long, current price - entry price >= take-profit-2 distance
Exit: short, entry price - current price >= take-profit-2 distance