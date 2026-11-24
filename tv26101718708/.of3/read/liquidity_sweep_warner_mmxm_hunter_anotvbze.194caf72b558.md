Calculation: bullSetup = close[1] < open[1] AND basis(close, high) > high[1]
Calculation: bearSetup = close[1] > open[1] AND basis(close, low) < low[1]
Calculation: bullPending = (bullPending[1] OR bullSetup) AND low <= high[2]
Calculation: bearPending = (bearPending[1] OR bearSetup) AND high >= low[2]
Long: confirm(bullSetup, low > high[2] AND (bullPending[1] OR bullSetup))
Short: confirm(bearSetup, high < low[2] AND (bearPending[1] OR bearSetup))
Long: on T1 bars, chart timeframe <= T1 AND confirm(bullSetup, low > high[2] AND (bullPending[1] OR bullSetup))
Short: on T1 bars, chart timeframe <= T1 AND confirm(bearSetup, high < low[2] AND (bearPending[1] OR bearSetup))
Long: on T2 bars, chart timeframe <= T2 AND confirm(bullSetup, low > high[2] AND (bullPending[1] OR bullSetup))
Short: on T2 bars, chart timeframe <= T2 AND confirm(bearSetup, high < low[2] AND (bearPending[1] OR bearSetup))