Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3, reset each day and including the current, still-forming bar
Calculation: Session VWAP ± 1 standard deviation = Session VWAP ± the square root of the volume-weighted variance of (high + low + close) / 3, using current-day bars through the current, still-forming bar
Calculation: Doji = abs(close − open) ≤ (high − low) × doji body percentage, with high > low
Calculation: Hammer = abs(close − open) ≤ (high − low) × body percentage AND low-side wick ≥ abs(close − open) × lower-wick multiple AND high-side wick ≤ abs(close − open), with high > low
Calculation: Shooting star = abs(close − open) ≤ (high − low) × body percentage AND high-side wick ≥ abs(close − open) × upper-wick multiple AND low-side wick ≤ abs(close − open), with high > low
Calculation: Long stop = signal-bar low − ATR × ATR buffer percentage
Calculation: Short stop = signal-bar high + ATR × ATR buffer percentage
Calculation: Long target = long signal-bar entry reference + max(long signal-bar entry reference − long stop, ATR × stop ATR multiple) × take-profit risk multiple
Calculation: Short target = short signal-bar entry reference − max(short stop − short signal-bar entry reference, ATR × stop ATR multiple) × take-profit risk multiple
Long: (previous bar is a hammer or doji AND its low is at or below the lowest low over the lookback ending on that bar) AND current close is in the top close-position percentage of its range AND current high − low ≤ current ATR × maximum candle-size multiple AND (current bullish engulfing OR current low > previous low AND current close > previous high) AND previous close < current Session VWAP − 1 standard deviation
Short: (previous bar is a shooting star or doji AND its high is at or above the highest high over the lookback ending on that bar) AND current close is in the bottom close-position percentage of its range AND current high − low ≤ current ATR × maximum candle-size multiple AND (current bearish engulfing OR current high < previous high AND current close < previous low) AND previous close > current Session VWAP + 1 standard deviation
Exit: Long, low ≤ long stop − spread OR high ≥ long target − spread
Exit: Short, high ≥ short stop + spread OR low ≤ short target + spread