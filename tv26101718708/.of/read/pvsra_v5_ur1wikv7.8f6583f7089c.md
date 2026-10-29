Calculation: Daily upper band = daily VWMA of close over a long lookback + a multiplier × daily standard deviation of close over the same lookback; both use the higher timeframe’s latest bar with lookahead off.
Calculation: Daily lower band = daily VWMA of close over a long lookback − a multiplier × daily standard deviation of close over the same lookback; both use the higher timeframe’s latest bar with lookahead off.
Calculation: Abnormal-volume threshold = max(minimum threshold, (intercept + slope × ln(long-term EMA of daily volume)) × long-term EMA of daily volume ÷ bars per day at the chart timeframe); daily volume uses the higher timeframe’s latest bar with lookahead off.
Calculation: PVSRA volume class = highest class if volume is at least a multiple of the short-term average volume or volume × (high − low) is the highest over a short lookback; otherwise the lower nonzero class if volume is at least a smaller multiple of that average; otherwise zero.
Calculation: Red trigger = chart-timeframe bar at the configured core lag has volume above its abnormal-volume threshold and close below open.
Calculation: Green trigger = chart-timeframe bar at the configured core lag has volume above its abnormal-volume threshold and close above open.
Calculation: Red count and green count = number of respective triggers in the configured reversal lookback, including the current bar.
Calculation: Normal long stop and target = low and high, respectively, of the bar at the configured core lag, adjusted by configured stop and target buffers.
Calculation: Normal short stop and target = high and low, respectively, of the bar at the configured core lag, adjusted by configured stop and target buffers.
Calculation: Reversal long stop and target = entry price adjusted down and up, respectively, by configured buffers.
Calculation: Reversal short stop and target = entry price adjusted up and down, respectively, by configured buffers.
Long: position is flat AND (bearish candle AND PVSRA volume class > 0 OR red trigger AND daily close > daily upper band OR at least two red triggers in the reversal lookback AND daily close < daily lower band)
Short: position is flat AND (bullish candle AND PVSRA volume class > 0 OR green trigger AND daily close < daily lower band OR at least two green triggers in the reversal lookback AND daily close > daily upper band)
Exit: long, low <= applicable stop OR high >= applicable target
Exit: short, high >= applicable stop OR low <= applicable target