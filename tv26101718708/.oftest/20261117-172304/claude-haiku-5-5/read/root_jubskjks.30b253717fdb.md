Calculation: VWAP = running sum of (hlc3 × volume) / running sum of volume, restarted at the start of each session, where hlc3 = (high + low + close) / 3
Long: SMA(close, N) crosses over VWAP
Short: SMA(close, N) crosses under VWAP
Exit: long, SMA(close, N) crosses under VWAP
Exit: short, SMA(close, N) crosses over VWAP