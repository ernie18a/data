Calculation: High Low Index = moving average of the percentage of the 40 constituents making a new N-bar high, among constituents making either a new N-bar high or low; compare each bar’s high/low (or close, according to the source setting) with the preceding N bars.
Calculation: Linear regression slope = change in the current linear regression value from the prior bar; smoothed slope is its moving average, its signal is a longer-lookback moving average of the smoothed slope, and raw slope acceleration is raw slope above (below) that signal while raw slope is positive (negative).
Calculation: ATR = Wilder-smoothed true range; risk distance is the initial stop’s distance from entry, adjusted by the stop-reduction percentage.
Long: linear regression trend changes from not trending to trending and smoothed linear regression slope > 0
Short: linear regression trend changes from not trending to trending and smoothed linear regression slope < 0
Long: MACD histogram > prior-bar MACD histogram AND High Low Index > prior-bar High Low Index AND absolute smoothed linear regression slope × 100 > trend threshold AND raw linear regression slope > its signal AND raw linear regression slope > 0 AND High Low Index < 96 AND entry time is within the trading window AND entry time is outside the configured pause window
Short: MACD histogram < prior-bar MACD histogram AND High Low Index < prior-bar High Low Index AND absolute smoothed linear regression slope × 100 > trend threshold AND raw linear regression slope < its signal AND raw linear regression slope < 0 AND High Low Index > 4 AND entry time is within the trading window AND entry time is outside the configured pause window
Exit: long, High Low Index crosses below 99 after prior-bar High Low Index > 99 AND position is profitable AND early-exit setting is enabled
Exit: short, High Low Index crosses above 1 after prior-bar High Low Index < 1 AND position is profitable AND early-exit setting is enabled
Exit: long, short-entry condition is true AND position is profitable AND early-exit setting is enabled
Exit: short, long-entry condition is true AND position is profitable AND early-exit setting is enabled
Exit: long, bar low <= long stop OR (trailing disabled AND bar high >= long profit target)
Exit: short, bar high >= short stop OR (trailing disabled AND bar low <= short profit target)
Exit: long, after bar high exceeds long profit target, bar low <= trailing stop; trailing stop ratchets upward to the greater of its prior value and bar low minus ATR distance
Exit: short, after bar low falls below short profit target, bar high >= trailing stop; trailing stop ratchets downward to the lesser of its prior value and bar high plus ATR distance
Exit: long, datetime is in the configured end-of-day close window on Monday, Wednesday, or Friday; or datetime is in the configured Tuesday/Thursday window (close half)
Exit: short, datetime is in the configured end-of-day close window on Monday, Wednesday, or Friday; or datetime is in the configured Tuesday/Thursday window (close half)