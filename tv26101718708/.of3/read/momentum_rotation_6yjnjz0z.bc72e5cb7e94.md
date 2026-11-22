Calculation: candidate trend = candidate T1 close > SMA(candidate T1 close, trend lookback); SMA runs on chart bars sampling T1 values, and the current T1 value may be from the still-forming bar
Calculation: candidate score = ROC(candidate T1 close, momentum lookback) + (candidate trend ? trend bonus : -trend bonus); ROC runs on chart bars sampling T1 values, and the current T1 value may be from the still-forming bar
Long: day-of-month differs from the prior chart bar AND current day-of-month <= rebalance cutoff AND candidate 1 score equals the maximum score among the three candidates AND candidate 1 trend
Long: day-of-month differs from the prior chart bar AND current day-of-month <= rebalance cutoff AND candidate 2 score equals the maximum score among the three candidates AND candidate 2 trend AND NOT (candidate 1 score equals the maximum score among the three candidates AND candidate 1 trend)
Long: day-of-month differs from the prior chart bar AND current day-of-month <= rebalance cutoff AND candidate 3 score equals the maximum score among the three candidates AND candidate 3 trend AND NOT (candidate 1 score equals the maximum score among the three candidates AND candidate 1 trend) AND NOT (candidate 2 score equals the maximum score among the three candidates AND candidate 2 trend)
Exit: long, day-of-month differs from the prior chart bar AND current day-of-month <= rebalance cutoff AND no candidate's score equals the maximum score among the three candidates while that candidate's trend is true
Calculation: Trend-adjusted momentum score(asset close at T1) = Rate of Change(asset close at T1, P1) + (asset close at T1 > Simple Moving Average(asset close at T1, P2) ? P3 : -P3)
Calculation: Selected instrument = first in SPY, QQQ, IWM order whose close at T1 is above its Simple Moving Average(close at T1, P2) and whose trend-adjusted momentum score equals the maximum score among SPY, QQQ, and IWM; cash if none
Calculation: Rebalance = calendar day of month differs from the previous chart bar AND calendar day of month <= P4
Long: Rebalance AND selected instrument = SPY
Long: Rebalance AND selected instrument = QQQ
Long: Rebalance AND selected instrument = IWM
Exit: Long, Rebalance AND selected instrument = cash