Calculation: Entry risk distance = ATR on the entry bar multiplied by a stop-distance multiplier, fixed at entry.
Calculation: Final target distance = entry risk distance multiplied by a reward-to-risk multiplier and the configured number of target levels.
Long: On the previous chart bar, the shorter-period EMA of close crossed above the longer-period EMA of close.
Short: On the previous chart bar, the shorter-period EMA of close crossed below the longer-period EMA of close.
Long: On the current chart bar, the shorter-period EMA of close crossed above the longer-period EMA of close.
Short: On the current chart bar, the shorter-period EMA of close crossed below the longer-period EMA of close.
Long: The shorter-period EMA of close is greater than the longer-period EMA of close.
Short: The shorter-period EMA of close is less than or equal to the longer-period EMA of close.
Long: On a selected dashboard timeframe, the shorter-period EMA of close is greater than the longer-period EMA of close. For a higher timeframe, use the last completed bar historically and the forming bar in real time; for a lower timeframe, use the last intrabar within the chart bar.
Short: On a selected dashboard timeframe, the shorter-period EMA of close is less than or equal to the longer-period EMA of close. For a higher timeframe, use the last completed bar historically and the forming bar in real time; for a lower timeframe, use the last intrabar within the chart bar.
Long: A majority of the selected dashboard timeframes have the shorter-period EMA of close greater than the longer-period EMA of close, using the same bar selection as the individual dashboard decisions.
Short: A majority of the selected dashboard timeframes have the shorter-period EMA of close less than or equal to the longer-period EMA of close, using the same bar selection as the individual dashboard decisions.
Exit: long, low <= entry price - entry risk distance OR high >= entry price + final target distance.
Exit: short, high >= entry price + entry risk distance OR low <= entry price - final target distance.