Calculation: Bull count = number of moving averages of Money Flow Index that are greater than their own previous-bar values; the averages use a series of progressively longer lookbacks and the same selectable averaging method.
Calculation: Bear count = number of those moving averages that are less than or equal to their own previous-bar values.
Calculation: Bull line and bear line = bull count and bear count, respectively, each smoothed with the same selectable moving-average method and parameters. Calculate the lines either on the chart timeframe or on a higher timeframe using its still-forming bar and volume from the backtest data.
Long: Bull line > bear line.
Short: Bull line < bear line.