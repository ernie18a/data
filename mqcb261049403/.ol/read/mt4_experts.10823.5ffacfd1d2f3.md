Calculation: Weighted-price RSI = RSI of (high + low + 2 × close) / 4, using the same lookback on three successively higher lower-than-chart timeframes; compare the still-forming bar with the completed bar seven bars earlier.
Calculation: Weighted-price EMA = exponential moving average of (high + low + 2 × close) / 4 on the intermediate lower-than-chart timeframe; use a shorter and a longer lookback, both on the still-forming bar.
Long: weighted-price RSI on each of the three lower-than-chart timeframes > 55 AND each corresponding RSI seven bars earlier < 50 AND the longer-lookback EMA > the shorter-lookback EMA
Short: weighted-price RSI on each of the three lower-than-chart timeframes < 55 AND each corresponding RSI seven bars earlier > 50 AND the longer-lookback EMA < the shorter-lookback EMA
Long: previous completed bar on the intermediate lower-than-chart timeframe is not bullish AND its range is at least the previous bar's range plus a volatility threshold
Short: previous completed bar on the intermediate lower-than-chart timeframe is bullish AND its range is at least the previous bar's range plus a volatility threshold
Exit: Long, elapsed time since entry >= maximum holding duration AND close < entry price
Exit: Short, elapsed time since entry >= maximum holding duration AND close > entry price