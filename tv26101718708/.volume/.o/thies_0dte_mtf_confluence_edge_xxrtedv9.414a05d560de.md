Calculation: Relative volume = volume / its moving average
Calculation: Signed pressure = EMA(relative volume × (2 × (close − low) / (high − low) − 1))
Calculation: Timeframe score = +1 when the mean relative volume of both confirmation series exceeds its threshold, their combined signed pressure is positive, and both close above open; −1 when the same volume condition holds, combined signed pressure is negative, and both close below open; otherwise 0. Use four configurable timeframe bars, using the current bar or the last completed bar in confirmed mode.
Calculation: Total score = sum of the four timeframe scores, set to 0 outside the enabled regular-hours session.
Long: Total score > 0
Short: Total score < 0
Long: Total score ≥ its strong-signal threshold for the configured number of chart bars, and was not so on the preceding bar
Short: Total score ≤ the negative strong-signal threshold for the configured number of chart bars, and was not so on the preceding bar