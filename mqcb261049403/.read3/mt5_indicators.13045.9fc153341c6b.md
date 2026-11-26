Calculation: Chandelier Stops(high, low, close, lookback, multiplier) = trend turns bullish when close > the previous bearish stop, turns bearish when close < the previous bullish stop, and otherwise retains its previous direction; bullish stop = Highest(high, lookback) - multiplier × ATR(lookback), ratcheted upward while bullish; bearish stop = Lowest(low, lookback) + multiplier × ATR(lookback), ratcheted downward while bearish
Long: Chandelier Stops trend is bullish on the chart bar
Short: Chandelier Stops trend is bearish on the chart bar
Long: Chandelier Stops trend changes from bearish to bullish on the chart bar
Short: Chandelier Stops trend changes from bullish to bearish on the chart bar
Long: Chandelier Stops trend is bullish using values calculated on T1 bars and copied to chart bars at bar shift SignalBar (shift 0 is still forming; positive shifts are completed)
Short: Chandelier Stops trend is bearish using values calculated on T1 bars and copied to chart bars at bar shift SignalBar (shift 0 is still forming; positive shifts are completed)
Long: Chandelier Stops trend changes from bearish to bullish using values calculated on T1 bars and copied to chart bars at bar shift SignalBar (shift 0 is still forming; positive shifts are completed)
Short: Chandelier Stops trend changes from bullish to bearish using values calculated on T1 bars and copied to chart bars at bar shift SignalBar (shift 0 is still forming; positive shifts are completed)