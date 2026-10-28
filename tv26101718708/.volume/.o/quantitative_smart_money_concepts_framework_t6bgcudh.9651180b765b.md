Calculation: Confirmed major swing high/low = alternating swing pivots; track the running high or low until price retraces by at least ATR × a configurable threshold, then confirm the extreme as a pivot.
Calculation: Confirmed minor swing high/low = a local high or low confirmed after a configurable number of bars on both sides; use a shorter lookback than for major structure.
Calculation: Pending major/minor high/low = the latest confirmed swing high/low of that type, retained until price closes across it.
Long: Close crosses above the pending major swing high
Short: Close crosses below the pending major swing low
Long: Close crosses above the pending minor swing high
Short: Close crosses below the pending minor swing low
Long: Low pierces the nearest recent confirmed minor swing low (older than the pivot confirmation delay) AND close is above that pivot AND lower wick is at least a configurable ATR multiple AND lower wick is at least a configurable fraction of the bar range AND more than a configurable cooldown has elapsed since the prior long sweep
Short: High pierces the nearest recent confirmed minor swing high (older than the pivot confirmation delay) AND close is below that pivot AND upper wick is at least a configurable ATR multiple AND upper wick is at least a configurable fraction of the bar range AND more than a configurable cooldown has elapsed since the prior short sweep