Calculation: SwingHigh = most recent PivotHigh(high, swing length, swing length), cleared when close crosses above it
Calculation: SwingLow = most recent PivotLow(low, swing length, swing length), cleared when close crosses below it
Calculation: MinorHigh = most recent PivotHigh(high, swing length, swing length), cleared when a short sweep fires on it
Calculation: MinorLow = most recent PivotLow(low, swing length, swing length), cleared when a long sweep fires on it
Calculation: MarketBias = bullish initially, bullish after close crosses above SwingHigh, bearish after close crosses below SwingLow
Long: close crosses above SwingHigh
Short: close crosses below SwingLow
Long: low crosses below MinorLow AND close above MinorLow AND no sweep since last structure break AND (intraday toggle off OR chart timeframe is intraday)
Short: high crosses above MinorHigh AND close below MinorHigh AND no sweep since last structure break, including a long sweep on this bar AND (intraday toggle off OR chart timeframe is intraday)
Long: low > high[2] AND close[1] > high[2] AND last structure break was bullish AND no bullish breakaway gap since last structure break AND breakaway toggle on
Long: low > high[2] AND close[1] > high[2] AND last structure break was bullish AND no standard bullish FVG since last structure break AND (bullish breakaway gap since last structure break OR breakaway toggle off)
Short: high < low[2] AND close[1] < low[2] AND last structure break was bearish AND no bearish breakaway gap since last structure break AND breakaway toggle on
Short: high < low[2] AND close[1] < low[2] AND last structure break was bearish AND no standard bearish FVG since last structure break AND (bearish breakaway gap since last structure break OR breakaway toggle off)
Long: low crosses below the bottom of a bullish OB AND close has not been below that bottom since the bullish structure break that formed it, where OB bottom = min(open[swing length], close[swing length]) on that break bar
Short: high crosses above the top of a bearish OB AND close has not been above that top since the bearish structure break that formed it, where OB top = max(open[swing length], close[swing length]) on that break bar
Long: MarketBias is bullish
Short: MarketBias is bearish