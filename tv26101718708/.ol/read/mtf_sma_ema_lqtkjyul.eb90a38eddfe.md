Calculation: Moving average = SMA or EMA of close over a lookback period; use the configured averages on the chart timeframe and any enabled timeframe no higher than the chart timeframe, using the last completed bar by default or the forming bar in live mode
Calculation: Nearest support = closest distinct rounded moving-average level below rounded current price
Calculation: Nearest resistance = closest distinct rounded moving-average level above rounded current price
Long: rounded current price >= rounded moving average
Long: nearest support and nearest resistance exist AND (rounded current price - nearest support) <= (nearest resistance - rounded current price)
Short: rounded current price < rounded moving average
Short: nearest support and nearest resistance exist AND (rounded current price - nearest support) > (nearest resistance - rounded current price)