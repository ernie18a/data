Calculation: Scan bars = bars from the primary scan timeframe; it may equal, be higher than, or be lower than the chart timeframe. With a higher timeframe, use its last completed bar and its third most recent completed bar, mapped to each chart bar. With a lower timeframe, use the first lower-timeframe bar within each chart bar and its preceding bars; with the chart timeframe, use preceding chart bars.
Calculation: Down-candle absorption = volume / (open - close) / close when close < open, otherwise 0.
Calculation: Up-candle absorption = volume / (close - open) / close when close > open, otherwise 0.
Long: The low of the third most recent completed scan bar > the high of the last completed scan bar AND the high of the third most recent completed scan bar differs from its value on the previous chart bar.
Short: The high of the third most recent completed scan bar < the low of the last completed scan bar AND the low of the third most recent completed scan bar differs from its value on the previous chart bar.
Long: Current low > high two chart bars ago AND high two chart bars ago >= previous open AND current low <= previous close.
Short: Current high < low two chart bars ago AND low two chart bars ago <= previous open AND current high >= previous close.
Long: Close > the highest high over a lookback ending on the previous chart bar.
Short: Close < the lowest low over a lookback ending on the previous chart bar.
Long: Close < open AND down-candle absorption / its rolling population standard deviation >= absorption threshold.
Short: Close > open AND up-candle absorption / its rolling population standard deviation >= absorption threshold.