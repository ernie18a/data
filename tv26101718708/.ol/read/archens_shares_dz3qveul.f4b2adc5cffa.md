Calculation: Session high = high of the most recent higher-timeframe bar within the configured session; use the last completed bar historically and the still-forming bar in real time
Calculation: Session low = low of the most recent higher-timeframe bar within the configured session; use the last completed bar historically and the still-forming bar in real time
Long: Close crosses above the session high AND the day of week is unchanged from the previous bar
Short: Close crosses below the session low AND the day of week is unchanged from the previous bar
Exit: Long, the current and previous Heikin-Ashi candles are both red (close < open)
Exit: Short, the current and previous Heikin-Ashi candles are both green (close > open)