Calculation: Trend state = positive if Fisher Transform((high + low) / 2, lookback) > threshold, negative if < threshold, otherwise previous trend state, on each completed chart bar
Long: long-entry-enabled AND previous trend state is positive AND current trend state is negative
Short: short-entry-enabled AND previous trend state is negative AND current trend state is positive
Exit: Long, long-exit-enabled AND previous trend state is negative AND (current trend state is negative OR short-entry-disabled)
Exit: Short, short-exit-enabled AND previous trend state is positive AND (current trend state is positive OR long-entry-disabled)