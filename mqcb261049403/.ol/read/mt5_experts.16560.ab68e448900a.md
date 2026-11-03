Calculation: Williams %R = Williams %R on the configured indicator timeframe (which may be lower than, equal to, or higher than the chart timeframe), evaluated on the last completed bar
Calculation: WPR slowdown = absolute difference between Williams %R on the last completed indicator-timeframe bar and the preceding completed indicator-timeframe bar is < 1
Long: Williams %R >= the upper signal threshold AND (slowdown filtering is disabled OR WPR slowdown)
Short: Williams %R <= the lower signal threshold AND (slowdown filtering is disabled OR WPR slowdown)
Exit: Short, the most recent buy or sell signal on the indicator timeframe is a buy signal
Exit: Long, the most recent buy or sell signal on the indicator timeframe is a sell signal