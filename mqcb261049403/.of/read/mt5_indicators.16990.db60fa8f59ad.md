Calculation: Selected price = a chosen OHLC price, median (high + low)/2, typical (high + low + close)/3, weighted (high + low + 2 × close)/4, average (open + high + low + close)/4, body midpoint (open + close)/2, trend-biased price, or the corresponding price calculated from Heikin-Ashi OHLC. Trend-biased price is (high + close)/2 when close > open and (low + close)/2 otherwise; its extreme variant is high when close > open, low when close < open, and close otherwise.
Calculation: Up value = selected price − moving average of selected price, using a chosen simple, exponential, smoothed, or linear weighted moving average.
Calculation: Down value = 2 × moving average of selected price − high − low.
Calculation: Trend level = a factor × the highest of the up value and down value over a lookback including the current bar.
Calculation: Trend state = up when up value > trend level; otherwise down when down value > trend level; otherwise the previous trend state. The initial state is neutral. Calculate these values on the chart timeframe or on a higher timeframe using its still-forming bar.
Long: Trend state = up
Short: Trend state = down