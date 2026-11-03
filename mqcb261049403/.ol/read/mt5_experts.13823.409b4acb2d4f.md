Calculation: Instantaneous trendline = initialize each of the first four bars to close; thereafter, for each bar t, (α−α²/4)×close_t + (α²/2)×close_(t−1) − (α−3α²/4)×close_(t−2) + 2(1−α)×trendline_(t−1) − (1−α)²×trendline_(t−2)
Calculation: Trigger line = 2×instantaneous trendline − instantaneous trendline from two bars earlier
Long: On the higher-timeframe last completed bar, trigger line crosses above instantaneous trendline
Short: On the higher-timeframe last completed bar, trigger line crosses below instantaneous trendline
Exit: Long, trigger line crosses below instantaneous trendline on the higher-timeframe last completed bar
Exit: Short, trigger line crosses above instantaneous trendline on the higher-timeframe last completed bar