Calculation: Confirmed swing high/low = a local high/low with equal lookback on both sides, confirmed after the following lookback bars
Calculation: Long entry limit = the lower of open and close on the swing-low bar
Calculation: Short entry limit = the higher of open and close on the swing-high bar
Calculation: Long target/stop = long entry limit plus/minus the configured target/stop distance
Calculation: Short target/stop = short entry limit minus/plus the configured target/stop distance
Long: confirmed swing low AND swing low > previous confirmed swing low
Long: confirmed swing low AND swing low < previous confirmed swing low
Long: confirmed swing low AND bar confirmed AND no open position AND (trend filter disabled OR close > moving average) AND high >= long entry limit
Short: confirmed swing high AND swing high > previous confirmed swing high
Short: confirmed swing high AND swing high < previous confirmed swing high
Short: confirmed swing high AND bar confirmed AND no open position AND (trend filter disabled OR close < moving average) AND low <= short entry limit
Exit: long position, high >= long target OR low <= long stop; if doubled entry is enabled, the second portion exits when high reaches the second target or low reaches the initial stop, with its stop moved to entry price plus the configured adjustment after the first target is reached
Exit: short position, low <= short target OR high >= short stop; if doubled entry is enabled, the second portion exits when low reaches the second target or high reaches the initial stop, with its stop moved to entry price minus the configured adjustment after the first target is reached