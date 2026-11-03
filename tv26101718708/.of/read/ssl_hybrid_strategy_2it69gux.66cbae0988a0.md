Calculation: SSL line = apply the selected moving average, with the same type and length, separately to high and low; set the persistent state to +1 when close is above the high average, otherwise to -1 when close is below the low average, otherwise retain its prior value; use the high average when the state is negative and the low average otherwise.
Calculation: Baseline channel = selected moving average of the selected price source plus or minus a multiplier of the EMA of true range or high minus low, using the baseline moving average length.
Calculation: Continuation ATR = true range smoothed by the selected RMA, SMA, EMA, or WMA.
Calculation: Higher-timeframe moving average = selected moving average of higher-timeframe close, using the last completed higher-timeframe bar historically and the still-forming bar in real time; when the selected timeframe is lower, use the last lower-timeframe bar within each chart bar.
Long: Within the selected date range AND the previous accepted SSL entry was not long AND (if both prior SSL entry conditions were false, close crosses above the baseline-length SSL line; otherwise close is above it) AND (the moving-average filter is disabled OR the selected chart-timeframe or other-timeframe moving average is greater than or equal to its value a selected number of chart bars ago).
Short: Within the selected date range AND the previous accepted SSL entry was not short AND (if both prior SSL entry conditions were false, close crosses below the baseline-length SSL line; otherwise close is below it) AND (the moving-average filter is disabled OR the selected chart-timeframe or other-timeframe moving average is less than its value a selected number of chart bars ago).
Long: Close crosses above the exit-length SSL line.
Short: Close crosses below the exit-length SSL line.
Long: Close is above the baseline-length SSL line.
Short: Close is below the baseline-length SSL line.
Long: Close is above the upper baseline channel.
Short: Close is below the lower baseline channel.
Long: Close is above the baseline moving average of close AND close is above the continuation-length SSL line AND close minus a multiplier of continuation ATR is below the continuation-length SSL line.
Short: Close is below the baseline moving average of close AND close is below the continuation-length SSL line AND close plus a multiplier of continuation ATR is above the continuation-length SSL line.
Long: The selected chart-timeframe or other-timeframe moving average is greater than or equal to its value a selected number of chart bars ago.
Short: The selected chart-timeframe or other-timeframe moving average is less than its value a selected number of chart bars ago.
Exit: long, an accepted short entry occurs.
Exit: short, an accepted long entry occurs.
Exit: long, take-profit and stop-loss are enabled AND low reaches the signal-bar close minus a stop multiplier of signal-bar ATR, or, for remaining take-profit tranches after the first target has been reached with stop movement enabled, low reaches the position's average entry price.
Exit: short, take-profit and stop-loss are enabled AND high reaches the signal-bar close plus a stop multiplier of signal-bar ATR, or, for remaining take-profit tranches after the first target has been reached with stop movement enabled, high reaches the position's average entry price.
Exit: long, take-profit and stop-loss are enabled AND high reaches a target equal to the signal-bar close plus that target's ATR multiplier times signal-bar ATR; exit the corresponding configured fraction of the original position, capped by the unallocated fraction, for each of up to five targets.
Exit: short, take-profit and stop-loss are enabled AND low reaches a target equal to the signal-bar close minus that target's ATR multiplier times signal-bar ATR; exit the corresponding configured fraction of the original position, capped by the unallocated fraction, for each of up to five targets.