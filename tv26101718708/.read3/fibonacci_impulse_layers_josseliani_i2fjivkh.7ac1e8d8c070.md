Calculation: Structure(D, M) = trend, high, high time, low, low time, updated each bar from pivot high = PivotHigh(high, D, D) and pivot low = PivotLow(low, D, D), each stored value carrying the time of its source bar: 1) if no high is set yet, high = pivot high when confirmed; if no low is set yet, low = pivot low when confirmed; 2) candidate low = lowest pivot low and candidate high = highest pivot high since the last break, including this bar's pivots; 3) up-break when (close if M is Close, else high) > high; down-break when (close if M is Close, else low) < low; 4) on up-break: if trend was 1 and a candidate low exists, low = candidate low; then high = up-break price and trend = 1; 5) otherwise on down-break: if trend was -1 and a candidate high exists, high = candidate high; then low = down-break price and trend = -1; 6) on any break, clear both candidates; trend starts at 0
Calculation: Local structure = Structure(local pivot depth, break mode) on chart bars
Calculation: Macro structure = Structure(macro pivot depth, break mode) on chart bars
Calculation: Bias structure = Structure(bias pivot depth, break mode) on T1 bars (T1 at or above chart timeframe), using for each chart bar the last completed T1 bar
Calculation: Changed(S) = trend, high time, or low time of S differs from its value on the previous chart bar
Calculation: Valid(S) = S.trend != 0 AND S.high and S.low exist AND S.high > S.low
Calculation: Zone(S) = low and high of the range between Fib(S, zone ratio 1) and Fib(S, zone ratio 2), where Fib(S, r) = S.high - (S.high - S.low) * r if S.trend = 1, else S.low + (S.high - S.low) * r (zone ratio 2 > zone ratio 1)
Calculation: Entry consumed(S) = a Long or Short entry using S occurred on an earlier bar and Changed(S) was false on every bar since that entry
Calculation: Full bullish alignment = Valid(Local structure) AND Valid(Macro structure) AND Valid(Bias structure) AND Local structure.trend = 1 AND Macro structure.trend = 1 AND Bias structure.trend = 1 (macro pivot depth longer than local pivot depth)
Calculation: Full bearish alignment = Valid(Local structure) AND Valid(Macro structure) AND Valid(Bias structure) AND Local structure.trend = -1 AND Macro structure.trend = -1 AND Bias structure.trend = -1 (macro pivot depth longer than local pivot depth)
Long: Local structure.trend = 1
Short: Local structure.trend = -1
Long: Macro structure.trend = 1
Short: Macro structure.trend = -1
Long: Bias structure.trend = 1
Short: Bias structure.trend = -1
Long: Valid(Local structure) AND NOT Changed(Local structure) AND NOT Entry consumed(Local structure) AND Local structure.trend = 1 AND close[1] > Zone(Local structure).high[1] AND high >= Zone(Local structure).low AND low <= Zone(Local structure).high
Short: Valid(Local structure) AND NOT Changed(Local structure) AND NOT Entry consumed(Local structure) AND Local structure.trend = -1 AND close[1] < Zone(Local structure).low[1] AND high >= Zone(Local structure).low AND low <= Zone(Local structure).high
Long: Valid(Macro structure) AND NOT Changed(Macro structure) AND NOT Entry consumed(Macro structure) AND Macro structure.trend = 1 AND close[1] > Zone(Macro structure).high[1] AND high >= Zone(Macro structure).low AND low <= Zone(Macro structure).high
Short: Valid(Macro structure) AND NOT Changed(Macro structure) AND NOT Entry consumed(Macro structure) AND Macro structure.trend = -1 AND close[1] < Zone(Macro structure).low[1] AND high >= Zone(Macro structure).low AND low <= Zone(Macro structure).high
Long: Valid(Bias structure) AND NOT Changed(Bias structure) AND NOT Entry consumed(Bias structure) AND Bias structure.trend = 1 AND close[1] > Zone(Bias structure).high[1] AND high >= Zone(Bias structure).low AND low <= Zone(Bias structure).high
Short: Valid(Bias structure) AND NOT Changed(Bias structure) AND NOT Entry consumed(Bias structure) AND Bias structure.trend = -1 AND close[1] < Zone(Bias structure).low[1] AND high >= Zone(Bias structure).low AND low <= Zone(Bias structure).high
Long: bar is confirmed AND Full bullish alignment AND NOT Full bullish alignment[1]
Short: bar is confirmed AND Full bearish alignment AND NOT Full bearish alignment[1]