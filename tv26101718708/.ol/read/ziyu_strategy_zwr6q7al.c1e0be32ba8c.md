Calculation: Opening Range High = highest high during the configured opening session, valid after that session ends and until the exchange day ends
Calculation: Previous-day high, low, and close = values from the last completed daily bar (daily timeframe is higher than the chart timeframe)
Calculation: Pivot = (previous-day high + previous-day low + previous-day close) / 3
Calculation: R1 = 2 × Pivot − previous-day low; R2 = Pivot + previous-day high − previous-day low; R3 = 2 × Pivot + previous-day high − 2 × previous-day low; R4 = 3 × Pivot + previous-day high − 3 × previous-day low; R5 = 4 × Pivot + previous-day high − 4 × previous-day low
Calculation: Midpoint levels = midpoint of Opening Range High and R1, and midpoints of each successive pair R1–R2, R2–R3, R3–R4, and R4–R5
Calculation: Initial long stop = the selected mode: entry price × (1 − stop percentage) or the low of the bar preceding the breakout setup; cap at entry price
Calculation: Long trailing stop = start at 0; when a bar's high exceeds a level in this descending order—R5, midpoint R4–R5, R4, midpoint R3–R4, R3, midpoint R2–R3, R2, midpoint R1–R2, R1, midpoint Opening Range High–R1, Opening Range High—raise the trailing stop to the next lower level in that ladder, only if that level is above the prior trailing stop
Long: Opening Range session has ended AND position is flat AND daily trade limit has not been reached AND cooldown is inactive AND current time is within the configured backtest window AND bar open < Opening Range High; place a long stop entry at Opening Range High
Exit: long, bar low ≤ max(Initial long stop, Long trailing stop)
Exit: long, exchange day has ended