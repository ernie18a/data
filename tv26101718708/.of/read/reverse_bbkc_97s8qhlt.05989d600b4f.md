Calculation: BB = SMA(close) +/- k1*stdev(close)
Calculation: KC = EMA(close) +/- k2*ATR
Calculation: Squeeze = BB upper < KC upper AND BB lower > KC lower, on the chart timeframe
Calculation: RecentSqueeze = Squeeze is true on the current bar or on any of the last N bars
Calculation: Risk = |entry price - signal bar extreme|, where the signal bar extreme is the signal bar high for a short and the signal bar low for a long. Entry is at the signal bar close.
Long: flat AND close < KC lower AND close < open AND RecentSqueeze AND no winning trade has closed since the latest Squeeze start (Squeeze true now, false on previous bar) AND this is not the first qualifying signal after a losing trade (that signal is skipped; the skip resets at each new Squeeze start)
Short: flat AND close > KC upper AND close > open AND RecentSqueeze AND no winning trade has closed since the latest Squeeze start AND this is not the first qualifying signal after a losing trade (that signal is skipped; the skip resets at each new Squeeze start)
Exit: long, low <= stop OR high >= entry + RR*Risk, where stop = signal bar low, and stop becomes entry price once high >= entry + B*Risk (B < RR)
Exit: short, high >= stop OR low <= entry - RR*Risk, where stop = signal bar high, and stop becomes entry price once low <= entry - B*Risk (B < RR)