Calculation: spread = first instrument's close on T1 (current bar while forming, otherwise last completed bar), minus second instrument's close on T1 (current bar while forming, otherwise last completed bar), sampled on chart bars
Long: price spread mode AND highest(spread, lookback) on chart bars [1] is available AND spread > highest(spread, lookback) on chart bars [1]
Short: price spread mode AND lowest(spread, lookback) on chart bars [1] is available AND spread < lowest(spread, lookback) on chart bars [1]
Calculation: Stock price difference = Stock 1 closing price on T1 − Stock 2 closing price on T1
Long: Price Spread comparison mode selected AND (high/low markers enabled OR high/low alerts enabled) AND stock price difference > highest stock price difference over the preceding P1 bars
Short: Price Spread comparison mode selected AND (high/low markers enabled OR high/low alerts enabled) AND stock price difference < lowest stock price difference over the preceding P1 bars