Calculation: Major swing high/low = latest confirmed pivot high/low, each requiring equal left and right lookbacks; the lookback is longer than for internal swings.
Calculation: Internal swing high/low = latest confirmed pivot high/low, each requiring equal left and right lookbacks; the lookback is shorter than for major swings.
Long: low < latest major swing low AND close > latest major swing low AND (latest major swing low - low) >= ATR * minimum sweep-size multiplier AND (volume filter disabled OR volume > volume moving average)
Long: low > high from two bars ago AND (low - high from two bars ago) >= ATR * minimum gap-size multiplier
Long: After a bullish sweep and until a bullish CSD or bearish sweep, close > latest internal swing high
Short: high > latest major swing high AND close < latest major swing high AND (high - latest major swing high) >= ATR * minimum sweep-size multiplier AND (volume filter disabled OR volume > volume moving average)
Short: high < low from two bars ago AND (low from two bars ago - high) >= ATR * minimum gap-size multiplier
Short: After a bearish sweep and until a bearish CSD or bullish sweep, close < latest internal swing low