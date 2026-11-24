Calculation: Swing direction(lookback) = 0 if high[lookback] > HIGHEST(high, lookback); 1 if low[lookback] < LOWEST(low, lookback); otherwise Swing direction(lookback)[1]
Calculation: Pivot high(lookback) = high[lookback] on bars where Swing direction(lookback) = 0 and Swing direction(lookback)[1] = 1; otherwise Pivot high(lookback)[1]
Calculation: Pivot low(lookback) = low[lookback] on bars where Swing direction(lookback) = 1 and Swing direction(lookback)[1] = 0; otherwise Pivot low(lookback)[1]
Calculation: Structure break(lookback) = 1 if close crosses above Pivot high(lookback) and no earlier 1 of Structure break(lookback) since Pivot high(lookback) was last updated; -1 if close crosses below Pivot low(lookback) and no earlier -1 of Structure break(lookback) since Pivot low(lookback) was last updated; otherwise 0; for lookback = shorter lookback, a 1 also requires Pivot high(shorter lookback) != Pivot high(longer lookback) and, if confluence filter switch is on, high - MAX(close, open) > MIN(close, open - low), and a -1 also requires Pivot low(shorter lookback) != Pivot low(longer lookback) and, if confluence filter switch is on, high - MAX(close, open) < MIN(close, open - low)
Calculation: Last internal break direction = Structure break(shorter lookback) if nonzero, otherwise its previous value, starting at 0
Calculation: Range high(lookback) = Pivot high(lookback) on bars where Swing direction(lookback) = 0 and Swing direction(lookback)[1] = 1; otherwise MAX(high, Range high(lookback)[1])
Calculation: Range low(lookback) = Pivot low(lookback) on bars where Swing direction(lookback) = 1 and Swing direction(lookback)[1] = 0; otherwise MIN(low, Range low(lookback)[1])
Calculation: Zone(f) = f * Range high(longer lookback) + (1 - f) * Range low(longer lookback)
Calculation: Volatility = ATR(volatility ATR lookback) if volatility measure setting is ATR, otherwise cumulative mean of true range over all bars so far
Calculation: Adjusted high = low if high - low >= range multiple * Volatility, otherwise high
Calculation: Adjusted low = high if high - low >= range multiple * Volatility, otherwise low
Calculation: Bullish OB low(lookback) = lowest Adjusted low from the bar of the latest Pivot high(lookback) through the current bar, on bars where Structure break(lookback) = 1
Calculation: Bearish OB high(lookback) = highest Adjusted high from the bar of the latest Pivot low(lookback) through the current bar, on bars where Structure break(lookback) = -1
Calculation: Bullish mitigation price = close if mitigation setting is close, otherwise low
Calculation: Bearish mitigation price = close if mitigation setting is close, otherwise high
Calculation: T1 change = (T1 close[1] - T1 open[1]) / (T1 open[1] * 100), with T1 values read on chart bars and index 0 = the forming T1 bar
Calculation: Gap threshold = threshold fraction * sum of abs(T1 change) over chart bars where T1 bar start != T1 bar start[1], through the current bar, divided by the number of bars through the current bar, if auto threshold switch is on, otherwise 0
Long: Structure break(longer lookback) = 1
Long: Structure break(shorter lookback) = 1
Short: Structure break(longer lookback) = -1
Short: Structure break(shorter lookback) = -1
Long: Swing direction(longer lookback) = 0 AND Swing direction(longer lookback)[1] = 1 AND Pivot high(longer lookback) > Pivot high(longer lookback)[1]
Short: Swing direction(longer lookback) = 0 AND Swing direction(longer lookback)[1] = 1 AND Pivot high(longer lookback) <= Pivot high(longer lookback)[1]
Long: Swing direction(longer lookback) = 1 AND Swing direction(longer lookback)[1] = 0 AND Pivot low(longer lookback) >= Pivot low(longer lookback)[1]
Short: Swing direction(longer lookback) = 1 AND Swing direction(longer lookback)[1] = 0 AND Pivot low(longer lookback) < Pivot low(longer lookback)[1]
Short: Bullish mitigation price < Bullish OB low(longer lookback) of an unmitigated order block
Short: Bullish mitigation price < Bullish OB low(shorter lookback) of an unmitigated order block
Long: Bearish mitigation price > Bearish OB high(longer lookback) of an unmitigated order block
Long: Bearish mitigation price > Bearish OB high(shorter lookback) of an unmitigated order block
Long: Last internal break direction = 1
Short: Last internal break direction != 1
Long: T1 bar start != T1 bar start[1] AND T1 low[0] > T1 high[2] AND T1 close[1] > T1 high[2] AND T1 change > Gap threshold
Short: T1 bar start != T1 bar start[1] AND T1 high[0] < T1 low[2] AND T1 close[1] < T1 low[2] AND T1 change < -Gap threshold
Long: low - high[2] > ATR(void ATR lookback) * void threshold AND close[1] > high[2]
Short: low[2] - high > ATR(void ATR lookback) * void threshold AND close[1] < low[2]
Long: close <= Zone(1 - premium fraction)
Short: close >= Zone(premium fraction)