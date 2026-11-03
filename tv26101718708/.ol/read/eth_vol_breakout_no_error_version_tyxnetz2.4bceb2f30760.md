Calculation: Prior 3-bar high = highest high of the three preceding completed chart bars
Calculation: Prior 3-bar low = lowest low of the three preceding completed chart bars
Calculation: Daily volatility close = ETHDVOL close from the daily timeframe, higher than the chart timeframe, using the bar still forming
Long: Daily volatility close <= 60 AND position is flat AND price reaches or exceeds the prior 3-bar high
Short: Daily volatility close <= 60 AND position is flat AND price reaches or falls below the prior 3-bar low
Exit: Long, price falls to the trailing stop, activated after price rises by 10% of the close at order calculation and then trailing 10% of that close
Exit: Short, price rises to the trailing stop, activated after price falls by 10% of the close at order calculation and then trailing 10% of that close