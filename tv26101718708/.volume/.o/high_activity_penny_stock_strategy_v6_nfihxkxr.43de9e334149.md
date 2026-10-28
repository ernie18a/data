Calculation: average volume = simple moving average of volume over a shorter lookback than the trend filter
Calculation: trend filter = simple moving average of close
Long: Supertrend direction changes from nonbullish to bullish AND (volume exceeds average volume multiplied by the volume threshold OR volume filter is disabled) AND (close > trend filter OR trend filter is disabled)
Short: Supertrend direction changes from nonbearish to bearish AND (volume exceeds average volume multiplied by the volume threshold OR volume filter is disabled) AND (close < trend filter OR trend filter is disabled)
Exit: long, high >= entry price × (1 + take-profit percentage) OR low <= entry price × (1 − stop-loss percentage) OR Supertrend direction is bearish
Exit: short, low <= entry price × (1 − take-profit percentage) OR high >= entry price × (1 + stop-loss percentage) OR Supertrend direction is bullish