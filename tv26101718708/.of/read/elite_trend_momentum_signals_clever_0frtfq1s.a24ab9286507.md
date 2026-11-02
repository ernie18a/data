Calculation: Source series = chart-timeframe close, high, low, volume, ATR, long-term close EMA, RSI, and shorter-term close EMA; alternatively use those calculations from a selected higher timeframe, using its last completed bar on historical chart bars and its still-forming bar on realtime chart bars. Carry the latest available values forward on chart bars.
Calculation: Trailing stop = initialize to zero; on each chart bar, compare the previous chart bar's source close with the previous stop, replacing an unavailable previous stop with zero. If greater, take the maximum of the previous stop and previous source close minus the current source ATR multiplied by a sensitivity parameter; if less, take the minimum of the previous stop and previous source close plus that ATR multiple; if equal, use previous source close plus that ATR multiple.
Calculation: Trailing direction = bullish when the previous source close is above the current trailing stop, bearish when below, and otherwise retain the previous direction, initially neutral.
Calculation: Cloud direction = bullish when source close is above the chart-bar SMA of source high, bearish when source close is below the chart-bar SMA of source low, and otherwise retain the previous direction; initialize to neutral and replace an unavailable previous direction with bullish.
Calculation: Pulse = linear-regression endpoint of source close minus its chart-bar SMA, using the same lookback for the SMA and regression.
Calculation: Power = clamp the average of RSI and the percentage position of chart close within the reference-period high-low range to the RSI scale. The reference period can be higher or lower than the chart timeframe; use the last completed reference bar on historical chart bars and the still-forming reference bar on realtime chart bars. Replace unavailable reference high or low with chart high or low, and floor the range denominator at a small positive parameter.
Long: Source close crosses above the trailing stop AND source close > long-term EMA AND (ADX filter disabled OR chart-timeframe ADX > threshold) AND (volume filter disabled OR source volume > chart-bar SMA of source volume) AND (RSI filter disabled OR RSI > its scale midpoint) AND (fast EMA filter disabled OR source close > shorter-term EMA) AND bars since the most recent filtered long or short signal > cooldown; optionally evaluate all conditions preceding the cooldown on the previous chart bar.
Short: Source close crosses below the trailing stop AND source close < long-term EMA AND (ADX filter disabled OR chart-timeframe ADX > threshold) AND (volume filter disabled OR source volume > chart-bar SMA of source volume) AND (RSI filter disabled OR RSI < its scale midpoint) AND (fast EMA filter disabled OR source close < shorter-term EMA) AND bars since the most recent filtered long or short signal > cooldown; optionally evaluate all conditions preceding the cooldown on the previous chart bar.
Long: Trailing direction = bullish.
Short: Trailing direction != bullish.
Long: Cloud direction changes to bullish.
Short: Cloud direction changes to bearish.
Long: Cloud direction = bullish.
Short: Cloud direction = bearish.
Long: Pulse > zero.
Short: Pulse <= zero.
Long: Fast EMA filter enabled AND source close > shorter-term EMA.
Short: Fast EMA filter enabled AND source close <= shorter-term EMA.
Long: Power >= RSI scale midpoint.
Short: Power < RSI scale midpoint.
Long: A source-low pivot is confirmed using equal numbers of chart bars on both sides AND its low < the immediately preceding source-low pivot's low AND Pulse at this pivot > Pulse at the preceding pivot AND chart bars from the preceding pivot to the current confirmation bar <= maximum divergence bars.
Short: A source-high pivot is confirmed using equal numbers of chart bars on both sides AND its high > the immediately preceding source-high pivot's high AND Pulse at this pivot < Pulse at the preceding pivot AND chart bars from the preceding pivot to the current confirmation bar <= maximum divergence bars.