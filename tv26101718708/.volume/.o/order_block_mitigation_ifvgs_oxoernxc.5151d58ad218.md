Calculation: Momentum z-score = (current close change − rolling mean of close changes) / rolling standard deviation of close changes; use the same lookback for both.
Calculation: Confirmed pivot high = a high greater than the highs in the same number of bars immediately before and after it; use the latest confirmed pivot high.
Calculation: Confirmed pivot low = a low lower than the lows in the same number of bars immediately before and after it; use the latest confirmed pivot low.
Calculation: Volume percentile rank = current volume’s percentile rank within its rolling lookback.
Long: Close > latest confirmed pivot high AND previous close ≤ that pivot high AND momentum z-score > threshold
Short: Close < latest confirmed pivot low AND previous close ≥ that pivot low AND momentum z-score < −threshold
Long: For any un-inverted bearish fair value gap formed when current high < low two bars earlier and the prior bar’s volume percentile rank meets the threshold, close > the gap’s upper boundary
Short: For any un-inverted bullish fair value gap formed when current low > high two bars earlier and the prior bar’s volume percentile rank meets the threshold, close < the gap’s lower boundary