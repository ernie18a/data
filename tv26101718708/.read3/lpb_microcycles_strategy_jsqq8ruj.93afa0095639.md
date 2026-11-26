Calculation: HPVWAP = session VWAP(HP filter(close, filter length), volume), calculated on chart bars and reset at the start of each current T1 bar
Long: HPVWAP[2] > HPVWAP[1]
Short: HPVWAP[2] < HPVWAP[1]
Long: close > HPVWAP
Short: close <= HPVWAP
Long: crossover(HPVWAP, (open + high + low + close) / 4) AND position is flat AND chart time is within the configured date range AND chart bar is confirmed
Short: crossunder(HPVWAP, (open + high + low + close) / 4) AND position is flat AND chart time is within the configured date range AND chart bar is confirmed
Exit: long, low <= (if entry-bar low < prior-bar low then entry-bar low else prior-bar low) - ATR(lookback) * stop multiplier OR high >= entry price + (entry price - stop price) * risk-reward parameter