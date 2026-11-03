Calculation: Typical price = (high + low + close) / 3
Calculation: Intrabar volatility = standard deviation of log(high / low) over a lookback
Calculation: Interbar volatility = standard deviation of log(current typical price / previous typical price) over the same lookback
Calculation: Volatility threshold = intrabar coefficient * intrabar volatility + interbar coefficient * interbar volatility
Calculation: Money flow = close - (high + low) / 2 + current typical price - previous typical price
Long: (reversal setting = false AND money flow > volatility threshold * close) OR (reversal setting = true AND money flow < -volatility threshold * close)
Short: (reversal setting = false AND money flow < -volatility threshold * close) OR (reversal setting = true AND money flow > volatility threshold * close)
Exit: Long, (reversal setting = false AND money flow < -volatility threshold * close) OR (reversal setting = true AND money flow > volatility threshold * close)
Exit: Short, (reversal setting = false AND money flow > volatility threshold * close) OR (reversal setting = true AND money flow < -volatility threshold * close)