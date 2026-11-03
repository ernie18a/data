Calculation: Lowest-volume range = high and low of the lowest-volume completed bar during the configured range window
Calculation: Confirmed swing high = a bar high greater than the highs of the configured number of preceding and following chart bars; available after the following bars complete
Calculation: Confirmed swing low = a bar low lower than the lows of the configured number of preceding and following chart bars; available after the following bars complete
Long: At the configured breakout evaluation bar, close > lowest-volume range high AND a confirmed swing low exists below close AND no trade has been taken that day
Long: After the first short trade exits at its stop, on a confirmed bar, a confirmed swing low exists below close AND the daily trade limit has not been reached
Short: At the configured breakout evaluation bar, close < lowest-volume range low AND a confirmed swing high exists above close AND no trade has been taken that day
Short: After the first long trade exits at its stop, on a confirmed bar, a confirmed swing high exists above close AND the daily trade limit has not been reached
Exit: Long, low <= entry stop at the latest confirmed swing low when entering OR high >= entry price + (entry price - entry stop) × configured reward/risk multiple
Exit: Short, high >= entry stop at the latest confirmed swing high when entering OR low <= entry price - (entry stop - entry price) × configured reward/risk multiple