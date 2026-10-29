Calculation: StochasticDiff = the stochastic %K line minus its signal line, smoothed by a moving-average method, on the configured indicator timeframe (which may be higher or lower than the chart timeframe); use completed bars.
Long: the middle StochasticDiff value is less than the latest value AND the oldest value is greater than or equal to the middle value
Short: the middle StochasticDiff value is greater than the latest value AND the oldest value is less than or equal to the middle value
Exit: long, the middle StochasticDiff value is greater than the latest value
Exit: short, the middle StochasticDiff value is less than the latest value