Calculation: Volume delta and total split volume = Choose either the lower-timeframe intrabar method or the chart-bar proxy method. For the intrabar method, use all completed lower-timeframe bars within the completed chart bar: allocate each up bar's volume to buying, each down bar's volume to selling, and split each doji's volume equally. If their total volume is zero, use the proxy. For the proxy, let close fraction be (close - low) / (high - low), or 0.5 when high equals low; let body fraction be 1 for close > open, 0 for close < open, and 0.5 otherwise. Buying volume is chart volume times the weighted average of close fraction and body fraction, clamped to [0, 1]; selling volume is chart volume minus buying volume. Volume delta is buying volume minus selling volume; total split volume is their sum.
Calculation: Pressure = Choose either the z-score of the EMA of volume delta using a rolling mean and standard deviation, with zero when the standard deviation is zero, or volume delta divided by total split volume, with zero when total split volume is zero.
Calculation: Cumulative volume delta = Running sum of volume delta, optionally reset before adding the current bar's delta at each new session/day, week, or month.
Calculation: Bullish divergence = A confirmed price pivot low is lower than the preceding confirmed price pivot low AND cumulative volume delta at that pivot is higher than at the preceding pivot. A pivot has the same number of bars on each side and is evaluated on its confirmation bar.
Calculation: Bearish divergence = A confirmed price pivot high is higher than the preceding confirmed price pivot high AND cumulative volume delta at that pivot is lower than at the preceding pivot. A pivot has the same number of bars on each side and is evaluated on its confirmation bar.
Long: Pressure crosses above zero on the completed chart bar AND absolute volume delta is at least a multiplier times its moving average AND that moving average is greater than zero AND positive chart volume has occurred at least once AND, if price confirmation is enabled, close > previous close AND, if divergence confirmation is enabled, bars since the most recent bullish divergence confirmation <= divergence recency AND bars since the previous long pressure-flip signal >= cooldown, or no previous long pressure-flip signal exists.
Short: Pressure crosses below zero on the completed chart bar AND absolute volume delta is at least a multiplier times its moving average AND that moving average is greater than zero AND positive chart volume has occurred at least once AND, if price confirmation is enabled, close < previous close AND, if divergence confirmation is enabled, bars since the most recent bearish divergence confirmation <= divergence recency AND bars since the previous short pressure-flip signal >= cooldown, or no previous short pressure-flip signal exists.
Long: Bullish divergence is confirmed AND positive chart volume has occurred at least once.
Short: Bearish divergence is confirmed AND positive chart volume has occurred at least once.
Long: Bars since the most recent bullish divergence confirmation <= divergence recency.
Short: Bars since the most recent bearish divergence confirmation <= divergence recency AND bars since the most recent bullish divergence confirmation > divergence recency, or no bullish divergence has been confirmed.
Long: Pressure > zero AND positive chart volume has occurred at least once.
Short: Pressure < zero AND positive chart volume has occurred at least once.
Long: Pressure >= nonnegative accumulation threshold.
Short: Pressure < accumulation threshold AND pressure <= nonpositive distribution threshold.
Long: Volume delta > zero.
Short: Volume delta < zero.
Long: Cumulative volume delta > zero.
Short: Cumulative volume delta < zero.
Long: Cumulative volume delta > cumulative volume delta at a prior chart bar.
Short: Cumulative volume delta < cumulative volume delta at the same prior chart bar.
Long: Close > anchored VWAP.
Short: Close < anchored VWAP.