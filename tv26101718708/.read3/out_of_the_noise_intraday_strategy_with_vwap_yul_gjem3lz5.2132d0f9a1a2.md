Calculation: upper threshold = max(open, prior close) × (1 + average recent move)
Calculation: lower threshold = min(open, prior close) × (1 − average recent move)
Long: position is flat or short AND close > upper threshold AND (not the first bar of the session OR end-of-session exit is disabled)
Short: position is flat or long AND close < lower threshold AND (not the first bar of the session OR end-of-session exit is disabled)
Exit: long, close < max(VWAP(close), upper threshold)
Exit: short, close > min(VWAP(close), lower threshold)
Exit: long, last bar of the session AND end-of-session exit is enabled
Exit: short, last bar of the session AND end-of-session exit is enabled