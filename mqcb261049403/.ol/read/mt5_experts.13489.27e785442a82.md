Calculation: Schaff WPR Trend Cycle = Subtract the longer-lookback Williams %R from the shorter-lookback Williams %R; normalize that difference over a lookback to 0–100, then smooth with a 0.5 coefficient; normalize the smoothed values over the same lookback to −100–100, then smooth with a 0.5 coefficient. If either normalization range is zero, carry forward the previous value. Use bars on the configured indicator timeframe (which may be higher, lower, or equal to the chart timeframe); compare the last completed bar with the preceding completed bar.
Long: Schaff WPR Trend Cycle crosses above the upper threshold
Short: Schaff WPR Trend Cycle crosses below the lower threshold
Exit: long, Schaff WPR Trend Cycle < lower threshold
Exit: short, Schaff WPR Trend Cycle > upper threshold