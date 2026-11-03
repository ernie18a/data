Calculation: Confirmed swing high = the high of a bar higher than the highs of the equal-length lookback bars before and after it; available after the following bars complete
Calculation: Confirmed swing low = the low of a bar lower than the lows of the equal-length lookback bars before and after it; available after the following bars complete
Calculation: Long stop = entry price × (1 − configured stop-loss percentage)
Calculation: Long target = entry price × (1 + configured take-profit percentage)
Calculation: Short stop = entry price × (1 + configured stop-loss percentage)
Calculation: Short target = entry price × (1 − configured take-profit percentage)
Long: current high > most recent confirmed swing high
Short: current low < most recent confirmed swing low
Exit: long, current low ≤ long stop OR current high ≥ long target
Exit: short, current high ≥ short stop OR current low ≤ short target