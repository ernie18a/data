Calculation: Anchor period = a higher timeframe period; use chart bars in the current, still-forming period and reset the calculations at each period boundary.
Calculation: Cumulative volume delta (CVD) = sum since the anchor reset of volume × (2 × close − high − low) / (high − low), using zero delta when high = low.
Calculation: Relative volume = current volume / simple moving average of volume including the current bar; use 1 when the average is not positive.
Calculation: Volume profile = divide the high-to-low range of a rolling lookback including the current bar into equal price buckets and assign each bar's volume to the bucket containing its high-low midpoint. Point of control is the center of the highest-volume bucket, choosing the lowest bucket on a tie. Starting there, add the larger-volume adjacent bucket until a specified fraction of total volume is included; choose the upper neighbor on a tie. Value area high and low are the upper and lower boundaries of the included buckets.
Calculation: Previous-period point of control = point of control calculated from all chart bars in the last completed higher anchor period, using the volume-profile bucket method.
Calculation: Developing point of control = point of control calculated with the volume-profile bucket method from the first chart bar of the current higher anchor period through the current bar.
Calculation: Initial balance high and low = highest high and lowest low of chart bars whose opening times are no later than a specified duration after the current higher anchor period begins; the balance is complete on the first bar opening after that duration.
Calculation: Confluence score = sum of: positive weight if close > anchored VWAP, otherwise negative weight; positive weight if close > value area high, negative weight if close < value area low, otherwise zero; cumulative volume delta divided by cumulative volume since the anchor reset, scaled and capped symmetrically; positive weight if CVD > its exponential moving average, otherwise negative weight; and positive weight if relative volume > its upper threshold, negative weight if relative volume < its lower threshold, otherwise zero. The discrete positive and negative weights have equal magnitude.
Long: A confirmed pivot low is lower than the preceding confirmed pivot low AND CVD at that pivot is higher than CVD at the preceding pivot low AND the difference between the two pivot lows > a multiplier × current ATR; confirm pivots with the same number of chart bars on each side and evaluate on the confirmation bar.
Short: A confirmed pivot high is higher than the preceding confirmed pivot high AND CVD at that pivot is lower than CVD at the preceding pivot high AND the difference between the two pivot highs > a multiplier × current ATR; confirm pivots with the same number of chart bars on each side and evaluate on the confirmation bar.
Long: low < lowest low of a lookback ending on the previous bar AND close > that lowest low AND relative volume >= a threshold AND close > open.
Short: high > highest high of a lookback ending on the previous bar AND close < that highest high AND relative volume >= a threshold AND close < open.
Long: volume moving average > 0 AND volume >= a multiplier × that average AND close > open.
Short: volume moving average > 0 AND volume >= a multiplier × that average AND close < open.
Long: Initial balance is complete AND close > initial balance high AND no earlier bar in the current anchor period has closed above the completed initial balance high.
Short: Initial balance is complete AND close < initial balance low AND no earlier bar in the current anchor period has closed below the completed initial balance low.
Long: Confluence score >= 0.
Short: Confluence score < 0.
Long: CVD >= 0.
Short: CVD < 0.
Long: Relative volume >= an upper threshold.
Short: Relative volume <= a lower threshold.
Long: close >= anchored VWAP.
Short: close < anchored VWAP.
Long: close >= value area high.
Short: close < value area high.
Long: close >= value area low.
Short: close < value area low.
Long: close >= developing point of control.
Short: close < developing point of control.
Long: close >= previous-period point of control.
Short: close < previous-period point of control.
Long: Maximum profile bucket volume / mean bucket volume >= a concentration threshold AND point-of-control bucket index / (number of buckets − 1) > an upper position threshold.
Short: Maximum profile bucket volume / mean bucket volume >= a concentration threshold AND point-of-control bucket index / (number of buckets − 1) < a lower position threshold.