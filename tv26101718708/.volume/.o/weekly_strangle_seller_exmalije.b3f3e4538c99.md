Calculation: Upper strike = round the center plus ATR times a multiplier up to the configured strike increment
Calculation: Lower strike = round the center minus ATR times a multiplier down to the configured strike increment
Calculation: Center = configured VWAP or 20-period EMA of close
Calculation: Width percentage = (upper strike − lower strike) / close × 100
Calculation: Upper stop = upper strike + (upper strike − center) × (stop multiplier − 1)
Calculation: Lower stop = lower strike − (center − lower strike) × (stop multiplier − 1)
Short: configured entry weekday AND within configured entry time window AND no trade has been taken this week AND width percentage >= configured minimum AND (Supertrend is neutral OR width percentage >= 4%) AND RSI is between its configured oversold and overbought thresholds AND no position is open
Long: configured entry weekday AND within configured entry time window AND no trade has been taken this week AND width percentage >= configured minimum AND (Supertrend is neutral OR width percentage >= 4%) AND RSI is between its configured oversold and overbought thresholds AND no position is open
Exit: short, high >= upper stop OR configured expiry weekday and within configured expiry exit time OR Friday and within the safety exit time window
Exit: long, low <= lower stop OR configured expiry weekday and within configured expiry exit time OR Friday and within the safety exit time window