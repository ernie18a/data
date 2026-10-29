Calculation: Support/resistance levels = confirmed pivot lows/highs; retain separated levels, with support below price and resistance above price.
Calculation: Signal candle strength = (close - low) / (high - low) for long signals; (high - close) / (high - low) for short signals.
Calculation: Long stop = signal low (or tested support) minus the smaller of half the signal-bar range and the maximum stop distance as a percentage of entry; short stop = signal high (or tested resistance) plus that distance.
Calculation: Long target 1 = entry + ATR × target-1 multiplier; short target 1 = entry − ATR × target-1 multiplier.
Calculation: Long target 2 = nearest resistance above target 1, or entry + ATR × fallback multiplier if none; short target 2 = nearest support below target 1, or entry − ATR × fallback multiplier if none.
Calculation: Long target 3 = entry + ATR × target-3 multiplier, unless this is at or below target 2, then target 2 + half the distance from entry to target 2; short target 3 = entry − ATR × target-3 multiplier, unless this is at or above target 2, then target 2 − half the distance from entry to target 2.
Calculation: Higher-timeframe trend = close above/below EMA200 on the last completed bar of a higher timeframe.
Long: (EMA20 > EMA50 AND close > EMA200 AND low <= EMA20 AND close > EMA20 AND signal candle strength >= 0.55 AND RSI between 35 and 65) OR (support < close AND low between support − 2 × tolerance and support + tolerance AND signal candle strength >= 0.55 AND RSI < 60) OR (close > highest high of the previous N bars AND signal candle strength >= 0.5 AND RSI < 70); AND higher-timeframe close > its EMA200; AND no active long; AND cooldown elapsed; AND outside the configured scheduled-release window.
Short: (EMA20 < EMA50 AND close < EMA200 AND high >= EMA20 AND close < EMA20 AND signal candle strength >= 0.55 AND RSI between 35 and 65) OR (resistance > close AND high between resistance − tolerance and resistance + 2 × tolerance AND signal candle strength >= 0.55 AND RSI > 40) OR (close < lowest low of the previous N bars AND signal candle strength >= 0.5 AND RSI > 30); AND higher-timeframe close < its EMA200; AND no active short; AND cooldown elapsed; AND outside the configured scheduled-release window.
Exit: Long, low <= current stop
Exit: Long, high >= target 1
Exit: Long, high >= target 2
Exit: Long, high >= target 3
Exit: Long, bars since entry >= expiry limit
Exit: Short, high >= current stop
Exit: Short, low <= target 1
Exit: Short, low <= target 2
Exit: Short, low <= target 3
Exit: Short, bars since entry >= expiry limit