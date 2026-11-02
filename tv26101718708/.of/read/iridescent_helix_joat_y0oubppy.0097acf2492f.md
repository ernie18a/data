Calculation: Volume-weighted median = sort closes in the rolling window in ascending order and select the first close whose cumulative volume is at least half the window's total volume; unavailable if total volume is not positive.
Calculation: Signed streak = consecutive rising closes counted positively or consecutive falling closes counted negatively; reset to zero on an unchanged close and to positive or negative one on a direction change.
Calculation: Connors-style RSI = average of RSI of close, RSI of signed streak, and the rolling percentile rank of one-bar close rate of change; replace each unavailable component with its neutral midpoint. The streak RSI uses a shorter lookback than the close RSI, and the percentile rank uses a longer lookback than either RSI.
Calculation: Composite = clamp a scaled Hull moving average of the weighted sum of (close minus volume-weighted median) divided by EMA of high minus low with a positive denominator floor, normalized Connors-style RSI, and clamped normalized volume Z-score. Use zero for the median-distance component when the median is unavailable; use positive weights ordered median distance greater than Connors-style RSI greater than volume Z-score. Volume Z-score is volume minus its rolling SMA, divided by its rolling standard deviation with a positive denominator floor.
Calculation: Confirmed composite pivot = a composite high or low identified using equal numbers of bars on each side; evaluate on the confirmation bar, compare with the immediately preceding confirmed pivot of the same kind, and use the high or low on each pivot bar as its corresponding price.
Long: Composite crosses above zero.
Long: Composite crosses above the oversold threshold.
Long: Composite minus its previous value is greater than the positive acceleration threshold.
Long: A composite low pivot is confirmed AND its distance from the preceding composite low pivot is at most the divergence lookback AND ((its composite value is higher AND its corresponding low is lower) OR (its composite value is lower AND its corresponding low is higher)).
Long: Composite is greater than or equal to zero.
Long: Composite is greater than or equal to its EMA signal line.
Long: Composite is greater than the positive regime threshold.
Long: Composite is greater than the lower positive dashboard regime threshold.
Long: Composite is less than or equal to the oversold threshold.
Long: Composite EMA signal line is greater than zero.
Long: Volume Z-score is greater than zero.
Short: Composite crosses below zero.
Short: Composite crosses below the overbought threshold.
Short: Composite minus its previous value is less than the negative acceleration threshold.
Short: A composite high pivot is confirmed AND its distance from the preceding composite high pivot is at most the divergence lookback AND ((its composite value is lower AND its corresponding high is higher) OR (its composite value is higher AND its corresponding high is lower)).
Short: Composite is less than zero.
Short: Composite is less than its EMA signal line.
Short: Composite is less than the negative regime threshold.
Short: Composite is less than the higher negative dashboard regime threshold.
Short: Composite is greater than or equal to the overbought threshold.
Short: Composite EMA signal line is less than zero.
Short: Volume Z-score is less than zero.