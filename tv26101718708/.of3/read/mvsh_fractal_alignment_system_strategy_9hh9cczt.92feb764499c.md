Calculation: T1 bias = on each chart bar, initialize neutral; using completed T1 bars, set bullish if the low of the middle of the three most recent completed T1 bars is below the older bar's low and the newest bar's low is above the middle bar's low; otherwise set bearish if the middle bar's high is above the older bar's high and the newest bar's high is below the middle bar's high; otherwise retain the prior bias
Calculation: long stop = low[1] at entry - stop-buffer parameter * pip-size parameter
Calculation: long risk = entry price - long stop
Calculation: long TP1 = entry price + long risk * TP1 risk-reward parameter
Calculation: long TP2 = entry price + long risk * TP2 risk-reward parameter
Calculation: short stop = high[1] at entry + stop-buffer parameter * pip-size parameter
Calculation: short risk = short stop - entry price
Calculation: short TP1 = entry price - short risk * TP1 risk-reward parameter
Calculation: short TP2 = entry price - short risk * TP2 risk-reward parameter
Calculation: trailing distance = trailing-stop parameter * pip-size parameter
Calculation: long TP1-hit state = false on long entry; true when high >= long TP1; reset when the position closes
Calculation: long TP2-hit state = false on long entry; true when long TP1-hit state is true and high >= long TP2; reset when the position closes
Calculation: short TP1-hit state = false on short entry; true when low <= short TP1; reset when the position closes
Calculation: short TP2-hit state = false on short entry; true when short TP1-hit state is true and low <= short TP2; reset when the position closes
Long: low[1] < low[2] AND low > low[1] AND (session filter disabled OR hour(datetime) >= session-start parameter AND hour(datetime) < session-end parameter) AND (bias filter disabled OR T1 bias is bullish) AND long entries opened today < daily trade-limit parameter AND no position is open
Short: high[1] > high[2] AND high < high[1] AND (session filter disabled OR hour(datetime) >= session-start parameter AND hour(datetime) < session-end parameter) AND (bias filter disabled OR T1 bias is bearish) AND short entries opened today < daily trade-limit parameter AND no position is open
Exit: long, (long TP1-hit state is false AND (low <= long stop OR high >= long TP1)) OR (long TP1-hit state is true AND long TP2-hit state is false AND (low <= entry price OR high >= long TP2)) OR (long TP2-hit state is true AND low <= max(entry price, highest(high since long TP2 was hit) - trailing distance))
Exit: short, (short TP1-hit state is false AND (high >= short stop OR low <= short TP1)) OR (short TP1-hit state is true AND short TP2-hit state is false AND (high >= entry price OR low <= short TP2)) OR (short TP2-hit state is true AND high >= min(entry price, lowest(low since short TP2 was hit) + trailing distance))