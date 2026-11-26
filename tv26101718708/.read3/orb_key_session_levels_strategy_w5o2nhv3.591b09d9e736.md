Calculation: ORB high = maximum high of chart bars during the configured opening-range session in America/New_York
Calculation: ORB low = minimum low of chart bars during the configured opening-range session in America/New_York
Calculation: ORB midpoint = (ORB high + ORB low) / 2
Calculation: Retest level = the broken ORB boundary in retest-zone mode or ORB midpoint in retest-midpoint mode
Calculation: Long stop price = ORB midpoint, ORB low, or entry price minus the fixed stop-distance parameter, as selected by the stop method
Calculation: Short stop price = ORB midpoint, ORB high, or entry price plus the fixed stop-distance parameter, as selected by the stop method
Calculation: Risk = absolute value of entry price minus stop price
Calculation: Target 1 = entry price plus risk × target-1 risk/reward parameter for long positions, or minus it for short positions
Calculation: Target 2 = entry price plus risk × target-2 risk/reward parameter for long positions, or minus it for short positions
Calculation: Target 3 = entry price plus risk × target-3 risk/reward parameter for long positions, or minus it for short positions
Calculation: T swing pivots = PivotHigh(T high, swing lookback, swing lookback) and PivotLow(T low, swing lookback, swing lookback), computed on chart bars using T values requested with lookahead off (last completed T bar historically and the still-forming T bar in realtime)
Long: For T1 or T2, the latest T swing high is higher than the preceding T swing high AND the latest T swing low is higher than the preceding T swing low
Short: For T1 or T2, the latest T swing high is lower than the preceding T swing high AND the latest T swing low is lower than the preceding T swing low
Long: Trade signals are enabled AND the current ORB is complete AND no signal has fired for it AND (the configured entry mode selects breakout and a confirmed chart-bar close crosses above ORB high OR the configured entry mode selects retest and a prior chart-bar close crossed above ORB high no more than the retest-timeout parameter bars ago with no intervening close at or below ORB high, and the current low is at or below the retest level and close is above ORB high)
Short: Trade signals are enabled AND the current ORB is complete AND no signal has fired for it AND (the configured entry mode selects breakout and a confirmed chart-bar close crosses below ORB low OR the configured entry mode selects retest and a prior chart-bar close crossed below ORB low no more than the retest-timeout parameter bars ago with no intervening close at or above ORB low, and the current high is at or above the retest level and close is below ORB low)
Exit: Long, low <= long stop price OR high >= target 1 OR high >= target 2 OR high >= target 3
Exit: Short, high >= short stop price OR low <= target 1 OR low <= target 2 OR low <= target 3