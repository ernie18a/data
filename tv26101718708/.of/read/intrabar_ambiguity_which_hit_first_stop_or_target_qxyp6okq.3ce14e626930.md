Calculation: Entry price = close of the entry bar.
Calculation: Entry ATR = ATR on the entry bar, held constant for the trade.
Calculation: Long stop = entry price − stop-distance multiplier × entry ATR; long target = entry price + target-distance multiplier × entry ATR.
Calculation: Short stop = entry price + stop-distance multiplier × entry ATR; short target = entry price − target-distance multiplier × entry ATR.
Long: Configured direction = long AND position side = flat at the close, including immediately after an exit on that bar AND ATR > 0.
Short: Configured direction = short AND position side = flat at the close, including immediately after an exit on that bar AND ATR > 0.
Exit: long, bars since entry > 0 AND (low <= long stop OR high >= long target OR bars since entry >= time-exit threshold).
Exit: short, bars since entry > 0 AND (high >= short stop OR low <= short target OR bars since entry >= time-exit threshold).