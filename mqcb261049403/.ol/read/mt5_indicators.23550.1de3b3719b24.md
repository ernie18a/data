Calculation: Smoothed residual open = apply the second-stage smoother, with a shorter lookback, to each bar’s open minus the first-stage smoother, with a longer lookback, of open.
Calculation: Smoothed residual close = apply the second-stage smoother, with a shorter lookback, to each bar’s close minus the first-stage smoother, with a longer lookback, of close.
Calculation: Gap-adjusted residual open = previous bar’s smoothed residual close if |bar open − bar close| ≤ the gap threshold; otherwise smoothed residual open.
Calculation: When the selected calculation timeframe is higher than the chart timeframe, calculate from its still-forming bar at the start of that bar and carry that value forward across chart bars until the next higher-timeframe bar starts.
Long: Gap-adjusted residual open < smoothed residual close
Short: Gap-adjusted residual open > smoothed residual close