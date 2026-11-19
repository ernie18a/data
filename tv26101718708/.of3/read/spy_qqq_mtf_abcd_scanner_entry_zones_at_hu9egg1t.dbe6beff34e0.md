Calculation: A, B, C = on bars of each scan timeframe T1–T4, the latest three alternating confirmed pivot highs/lows; a same-type pivot replaces C only when more extreme, and an alternating pivot shifts A←B, B←C, and sets C to the new pivot. Pivot High/Low use separate left and right pivot-lookback parameters. Calculations use the last completed scan-timeframe bar historically and the still-forming scan-timeframe bar in real time; values map to chart bars with lookahead off.
Calculation: AB = abs(B - A)
Calculation: BC retracement = abs(C - B) / AB
Calculation: Valid bullish ABCD = A is a pivot high AND B is a pivot low AND C is a pivot high AND C < A AND AB > 0 AND AB >= ATR(ATR lookback) * minimum AB/ATR ratio AND BC retracement >= minimum retracement AND BC retracement <= maximum retracement
Calculation: Valid bearish ABCD = A is a pivot low AND B is a pivot high AND C is a pivot low AND C > A AND AB > 0 AND AB >= ATR(ATR lookback) * minimum AB/ATR ratio AND BC retracement >= minimum retracement AND BC retracement <= maximum retracement
Calculation: D = C - AB for a valid bullish ABCD; C + AB for a valid bearish ABCD
Calculation: D zone lower bound = D - ATR(ATR lookback) * D-zone width; D zone upper bound = D + ATR(ATR lookback) * D-zone width
Long: valid bullish ABCD
Short: valid bearish ABCD
Long: valid bullish ABCD AND high >= D zone lower bound AND low <= D zone upper bound
Short: valid bearish ABCD AND high >= D zone lower bound AND low <= D zone upper bound
Long: valid bullish ABCD AND high >= D zone lower bound AND low <= D zone upper bound AND close > open
Short: valid bearish ABCD AND high >= D zone lower bound AND low <= D zone upper bound AND close < open
Exit: long, low <= D zone lower bound
Exit: long, high >= C
Exit: long, high >= A
Exit: short, high >= D zone upper bound
Exit: short, low <= C
Exit: short, low <= A