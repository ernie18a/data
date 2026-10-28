Calculation: Adaptive MACD = MACD of the price source, optionally volume-weighted; fast, slow, and signal lengths adapt using the configured cycle or volatility driver, with slow longer than fast and signal shorter than fast
Calculation: Normalized MACD histogram = rolling z-score of MACD minus its signal line
Calculation: Trend regime = ADX above its threshold AND efficiency ratio above its threshold; direction is close above or below the regime EMA
Calculation: Volatility veto = exponentially decayed absolute log returns, normalized by a rolling z-score, exceed the configured threshold while not trending
Calculation: Higher-timeframe MACD direction = sign of the 12/26/9 MACD histogram on each of four configured higher timeframes, using the last completed bar
Calculation: Conviction = absolute value of the weighted average of available signed components, scaled to 0–100; components are normalized MACD histogram (clamped to −1…1 after dividing by 2), higher-timeframe net agreement, signed volume delta, open-interest score, basis z-score (clamped after dividing by 2), regime score, cross-asset momentum, and active band-fade direction
Calculation: Entry vetoes = opposing trend regime OR insufficient higher-timeframe agreement OR opposing signed volume delta OR opposing open-interest buildup OR volatility-index z-score above threshold OR absolute normalized MACD histogram below threshold OR opposing configured higher-timeframe bias
Calculation: Volume-weighted price bands = rolling volume-weighted mean and standard deviation of the price source; if volume is unavailable or nonpositive, use unit weights
Calculation: ATR stop distance = ATR; first target = entry price ± stop distance and second target = entry price ± twice stop distance, adding for long and subtracting for short
Long: normalized conviction direction is positive AND conviction meets its threshold AND no entry veto applies AND no long position is open AND the bar is confirmed
Short: normalized conviction direction is negative AND conviction meets its threshold AND no entry veto applies AND no short position is open AND the bar is confirmed
Long: MACD line crosses above its signal line
Short: MACD line crosses below its signal line
Long: a confirmed price pivot low is below the preceding pivot low AND the normalized MACD histogram at the newer pivot is above that at the preceding pivot
Short: a confirmed price pivot high is above the preceding pivot high AND the normalized MACD histogram at the newer pivot is below that at the preceding pivot
Long: low is at or below the lower outer volume-weighted band AND close is above that band AND regime is not bearish trend AND the bar is confirmed
Short: high is at or above the upper outer volume-weighted band AND close is below that band AND regime is not bullish trend AND the bar is confirmed
Exit: long, high reaches the second target OR low reaches the current stop; after high reaches the first target, move the stop to entry price
Exit: short, low reaches the second target OR high reaches the current stop; after low reaches the first target, move the stop to entry price