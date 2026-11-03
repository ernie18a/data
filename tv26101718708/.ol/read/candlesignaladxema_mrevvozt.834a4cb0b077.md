Calculation: C1 = a confirmed reference bar; if the next confirmed bar is not a valid C2, that bar replaces C1. After a valid C2, wait for a later bar to break C1; if no qualifying signal occurs, the current confirmed bar becomes the new C1.
Calculation: Bullish C2 = the bar immediately after C1 has low < C1 low, high <= C1 high, and close between C1 low and C1 high, inclusive.
Calculation: Bearish C2 = the bar immediately after C1 has high > C1 high, low >= C1 low, and close between C1 low and C1 high, inclusive.
Calculation: Selected trend average = EMA with a shorter lookback, or SMA with a longer lookback.
Calculation: Stop = beyond the opposite C1 extreme by the configured ATR distance: for a long, C1 low minus ATR; for a short, C1 high plus ATR.
Calculation: Target = entry price plus (long) or minus (short) the distance from entry to stop multiplied by the configured risk/reward ratio.
Long: bullish C2 exists AND high >= C1 high + ATR × configured breakout buffer AND (MA filter disabled OR close > selected trend average) AND (ADX filter disabled OR ADX >= configured minimum) AND (session filter disabled OR time is within the configured session) AND no open trade
Short: bearish C2 exists AND low <= C1 low - ATR × configured breakout buffer AND (MA filter disabled OR close < selected trend average) AND (ADX filter disabled OR ADX >= configured minimum) AND (session filter disabled OR time is within the configured session) AND no open trade
Exit: long, low <= stop OR high >= target; exit at the first level touched, resolving order with lower-timeframe bars within the chart bar
Exit: short, high >= stop OR low <= target; exit at the first level touched, resolving order with lower-timeframe bars within the chart bar