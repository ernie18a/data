Calculation: Trend direction = 1 when high = Highest(high, lookback) on T1 bars; otherwise -1 when low = Lowest(low, lookback) on T1 bars; otherwise the previous T1-bar value (initially 0). Calculate on T1 bars using the last completed T1 bar historically and the still-forming T1 bar in real time; map values to chart bars.
Long: Trend direction = 1
Short: Trend direction = -1