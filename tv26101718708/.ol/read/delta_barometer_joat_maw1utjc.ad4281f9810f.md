Calculation: ATR regime ratio = current ATR divided by its moving average over a longer lookback
Calculation: Volatility regime = low if ATR regime ratio is below the low threshold, high if above the high threshold, otherwise medium
Calculation: ATR trailing stop = use ATR multiplied by the regime-specific multiplier; ratchet the stop upward while bullish and downward while bearish, flipping bearish when close falls below the stop and bullish when close rises above it
Calculation: Trend strength score = weighted sum of capped RSI slope magnitude, volume relative to its moving average, and longer-period ATR expansion relative to a shorter-period ATR, scaled to 0–100
Calculation: Cumulative delta = running sum of volume positive when close is at or above open and negative otherwise
Calculation: Pressure score = weighted sum of absolute signed-volume ratio, volume relative to its moving average, and candle body size relative to candle range, scaled to 0–100
Calculation: Long target = entry price + ATR at entry × target multiple
Calculation: Long stop = lower of the trailing stop and entry price minus an ATR-based stop distance; if the trailing stop is unavailable, use a percentage below entry
Calculation: Short target = entry price − ATR at entry × target multiple
Calculation: Short stop = higher of the trailing stop and entry price plus an ATR-based stop distance; if the trailing stop is unavailable, use a percentage above entry
Long: on a confirmed bar outside the cooldown, an enabled and regime-armed bullish ATR trail flip with trend strength score at or above its minimum, and/or an enabled and regime-armed cumulative delta crossover above its moving average with pressure score at or above its minimum and RSI below its overbought gate, as required by the selected hybrid mode (both engines, priority A, priority B, or either engine)
Short: on a confirmed bar outside the cooldown, an enabled and regime-armed bearish ATR trail flip with trend strength score at or above its minimum, and/or an enabled and regime-armed cumulative delta crossunder below its moving average with pressure score at or above its minimum and RSI above its oversold gate, as required by the selected hybrid mode (both engines, priority A, priority B, or either engine)
Exit: long, high reaches or exceeds the long target OR low reaches or falls below the long stop
Exit: short, low reaches or falls below the short target OR high reaches or exceeds the short stop