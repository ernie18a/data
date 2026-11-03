Calculation: Normalized close = (close - lowest low over normalization lookback) / (highest high over the same lookback - lowest low over the same lookback)
Calculation: Normalized volatility = standard deviation of normalized close over the volatility lookback
Calculation: Channel bounds = when the volatility peak score crosses above its trough score and the duration since the trough score crossed above the peak score exceeds a minimum, highest high and lowest low over that duration; remove the channel when close is more than a configured tolerance outside either bound
Calculation: Long entry zone = channel bottom + channel range × configured edge percentage
Calculation: Short entry zone = channel top - channel range × configured edge percentage
Calculation: ATR filter = ATR over the configured timeframe (higher, lower, or equal to the chart timeframe), using the latest available bar, including a still-forming bar when applicable
Calculation: Long stop = channel bottom - configured stop offset; long target = entry price + configured fixed target distance or channel range × configured target percentage
Calculation: Short stop = channel top + configured stop offset; short target = entry price - configured fixed target distance or channel range × configured target percentage
Long: low <= long entry zone AND close <= channel top + configured tolerance AND close >= channel bottom - configured tolerance AND (cooldown disabled OR bars since previous long signal >= cooldown) AND (ATR filter disabled OR ATR >= minimum) AND position is flat
Short: high >= short entry zone AND close <= channel top + configured tolerance AND close >= channel bottom - configured tolerance AND (cooldown disabled OR bars since previous short signal >= cooldown) AND (ATR filter disabled OR ATR >= minimum) AND position is flat
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target