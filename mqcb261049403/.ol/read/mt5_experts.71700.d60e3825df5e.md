Calculation: RSI = relative strength index of close on the configured higher timeframe, using its last completed bar
Calculation: Grid step = the base step capped at the maximum step; when there are more than one open positions on that side and the step multiplier exceeds 1, use the lesser of the maximum step and (position count − 1) × step multiplier × base step
Calculation: Position break-even price = volume-weighted average entry price of open positions on that side
Long: Within configured trading hours AND no long position is open AND RSI ≤ lower threshold
Long: Within configured trading hours AND at least one long position is open AND ask ≤ most recent long entry price − grid step
Short: Within configured trading hours AND no short position is open AND RSI ≥ upper threshold
Short: Within configured trading hours AND at least one short position is open AND bid ≥ most recent short entry price + grid step
Exit: long, bid ≥ position break-even price + take-profit distance OR bid ≤ position break-even price − stop-loss distance OR an active breakeven stop is reached on a downward price move OR an active trailing stop is reached on a downward price move
Exit: short, ask ≤ position break-even price − take-profit distance OR ask ≥ position break-even price + stop-loss distance OR an active breakeven stop is reached on an upward price move OR an active trailing stop is reached on an upward price move