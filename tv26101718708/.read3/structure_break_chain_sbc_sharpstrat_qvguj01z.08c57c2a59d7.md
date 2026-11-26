Calculation: swing high = most recent confirmed pivot high(high, pivot length, pivot length), or none if a bullish break occurred from that pivot's confirmation bar through the previous bar
Calculation: swing low = most recent confirmed pivot low(low, pivot length, pivot length), or none if a bearish break occurred from that pivot's confirmation bar through the previous bar
Calculation: bullish break = (high or close, per break confirmation parameter) > swing high
Calculation: bearish break = (low or close, per break confirmation parameter) < swing low AND NOT bullish break
Calculation: last break direction = 1 on a bullish break bar, -1 on a bearish break bar, otherwise last break direction[1]
Calculation: failed break = this bar is the first bar after the latest break at which close is back below the broken level (after a bullish break) or above the broken level (after a bearish break), and this bar is at most failed break window bars after that break
Long: bullish break
Short: bearish break
Exit: long, last break direction = 1 AND failed break
Exit: short, last break direction = -1 AND failed break
Long: first chart bar of a new T1 bar AND (on T1 bars at the last completed T1 bar: bullish break AND last break direction[1] != -1)
Short: first chart bar of a new T1 bar AND (on T1 bars at the last completed T1 bar: bearish break AND last break direction[1] != 1)