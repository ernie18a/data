Calculation: Level = a price from a high source or a low source, where high sources are the high of the last completed T1 bar, the high of the last completed session of session window A, B, or C, and PivotHigh(high, pivot length, pivot length), and low sources are the low of the last completed T1 bar, the low of the last completed session of session window A, B, or C, and PivotLow(low, pivot length, pivot length); a new price within ATR(atr length) * tolerance factor of an unresolved level from the same source (no earlier Resolution) is merged into that level as a touch-weighted average instead of creating a new level; a level ceases max age bars after it is formed
Calculation: PierceBar = the first bar since the level was formed at which high > Level for a high-source level, or low < Level for a low-source level
Calculation: ClosesBeyond = the number of bars from PierceBar through the current bar whose close is beyond Level, where beyond means above Level for a high-source level and below Level for a low-source level
Calculation: Resolution = true on the first bar since PierceBar at which ClosesBeyond >= 2 or at which at least confirmation count bars have passed since PierceBar and close is not beyond Level; otherwise false
Long: high-source level AND Resolution AND ClosesBeyond >= 2
Short: high-source level AND Resolution AND ClosesBeyond < 2
Short: low-source level AND Resolution AND ClosesBeyond >= 2
Long: low-source level AND Resolution AND ClosesBeyond < 2
Long: close > open(T1, bar still forming)
Short: close <= open(T1, bar still forming)