Calculation: SessionHigh = highest(high during a configured session), active until high > SessionHigh or the configured cutoff
Calculation: SessionLow = lowest(low during a configured session), active until low < SessionLow or the configured cutoff
Long: close > EMA(close, shorter EMA lookback) AND close > EMA(close, longer EMA lookback) AND chart timeframe is within the configured band-display limit
Short: close < EMA(close, shorter EMA lookback) AND close < EMA(close, longer EMA lookback) AND chart timeframe is within the configured band-display limit
Long: broken-pivot alerts are enabled AND high > the latest completed SessionHigh for an enabled session while that pivot is active
Short: broken-pivot alerts are enabled AND low < the latest completed SessionLow for an enabled session while that pivot is active