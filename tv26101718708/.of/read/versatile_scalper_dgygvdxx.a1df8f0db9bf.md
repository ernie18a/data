Calculation: LinRegSignal = simple moving average of the end-point value of a rolling least-squares linear regression line fitted to close, where the SMA window is a different, independent lookback from the regression lookback
Calculation: PivotHigh = a high that is the highest high of the bars within N bars on each side (same N left and right); it is confirmed and usable only N bars after the pivot bar, and its value is the pivot bar's high
Calculation: PivotLow = a low that is the lowest low of the bars within N bars on each side (same N left and right); it is confirmed and usable only N bars after the pivot bar, and its value is the pivot bar's low
Long: Supertrend direction flips from bearish to bullish on this bar AND the number of bars since the last Long Supertrend signal was issued is greater than a cooldown count (or no previous Long Supertrend signal exists)
Short: Supertrend direction flips from bullish to bearish on this bar AND the number of bars since the last Short Supertrend signal was issued is greater than a cooldown count (or no previous Short Supertrend signal exists); the Long and Short cooldowns are tracked independently
Long: LinRegSignal > LinRegSignal one bar earlier
Short: LinRegSignal <= LinRegSignal one bar earlier
Long: the most recent cross between RSI and the SMA of RSI was RSI crossing above its SMA (state persists until the opposite cross)
Short: the most recent cross between RSI and the SMA of RSI was RSI crossing below its SMA, or no cross has occurred yet (state persists until the opposite cross); RSI's lookback and the SMA's lookback are separate parameters
Long: a newly confirmed PivotHigh > the previous confirmed PivotHigh
Short: a newly confirmed PivotHigh < the previous confirmed PivotHigh
Long: a newly confirmed PivotLow > the previous confirmed PivotLow
Short: a newly confirmed PivotLow < the previous confirmed PivotLow