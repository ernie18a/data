Calculation: Confirmed swing high/low = the most recently confirmed pivot high/low using independently configurable left and right lookbacks; update it on the bar that completes the right lookback.
Calculation: Net delta = sum of volume of completed lower-timeframe bars within the chart bar whose close >= open minus sum of volume of those whose close < open.
Calculation: Close position = (close - low) / (high - low) if high > low, otherwise 0.5.
Calculation: Bullish absorption = low < confirmed swing low AND close > confirmed swing low AND close position >= threshold AND (volume filter disabled OR volume > volume SMA including current bar × multiplier) AND (delta filter disabled OR net delta >= minimum delta).
Calculation: Bearish absorption = high > confirmed swing high AND close < confirmed swing high AND close position <= 1 - threshold AND (volume filter disabled OR volume > volume SMA including current bar × multiplier) AND (delta filter disabled OR net delta <= -minimum delta).
Calculation: Raw long = bullish absorption AND (trend filter disabled OR close > close EMA) AND (session filter disabled OR bar opens within configured session in configured timezone) AND long trades enabled.
Calculation: Raw short = bearish absorption AND (trend filter disabled OR close < close EMA) AND (session filter disabled OR bar opens within configured session in configured timezone) AND short trades enabled.
Calculation: Pending long/short = on a raw signal set the corresponding pending state true and save that bar's low/high; then, if that state was true on the preceding bar, set it false. Saved lows/highs persist and are overwritten by subsequent corresponding raw signals.
Calculation: Long stop = most recently saved raw-long low minus current ATR × stop multiplier; short stop = most recently saved raw-short high plus current ATR × stop multiplier. Fix the stop and target at the entry signal bar; long target = signal-bar close + (signal-bar close - long stop) × reward-to-risk ratio; short target = signal-bar close - (short stop - signal-bar close) × reward-to-risk ratio.
Long: Bullish absorption.
Short: Bearish absorption.
Long: Raw long.
Short: Raw short.
Long: (confirmation disabled AND raw long OR confirmation enabled AND preceding bar's pending long state is true AND close > open) AND position is flat AND (daily trade limit disabled OR entries since start of current exchange day < daily trade limit) AND saved raw-long low exists AND close > long stop.
Short: (confirmation disabled AND raw short OR confirmation enabled AND preceding bar's pending short state is true AND close < open) AND position is flat AND (daily trade limit disabled OR entries since start of current exchange day < daily trade limit) AND saved raw-short high exists AND close < short stop.
Exit: long, low <= fixed long stop OR high >= fixed long target.
Exit: short, high >= fixed short stop OR low <= fixed short target.