Calculation: Consecutive bullish Heikin Ashi count = number of consecutive completed Heikin Ashi bars with close > open, ending on the current bar
Calculation: Consecutive bearish Heikin Ashi count = number of consecutive completed Heikin Ashi bars with close < open, ending on the current bar
Calculation: Take-profit level = entry price × (1 − take-profit percentage)
Calculation: Stop-loss level = entry price × (1 + stop-loss percentage)
Short: RSI over the configured lookback satisfies the configured comparison against its threshold AND the Heikin Ashi streak in the configured direction is at least the required streak length AND no short position is open
Exit: Short, close <= take-profit level OR close >= stop-loss level