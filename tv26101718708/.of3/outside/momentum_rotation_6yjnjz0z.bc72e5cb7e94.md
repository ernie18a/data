Calculation: Trend-adjusted momentum score(asset close at T1) = Rate of Change(asset close at T1, P1) + (asset close at T1 > Simple Moving Average(asset close at T1, P2) ? P3 : -P3)
Calculation: Selected instrument = first in SPY, QQQ, IWM order whose close at T1 is above its Simple Moving Average(close at T1, P2) and whose trend-adjusted momentum score equals the maximum score among SPY, QQQ, and IWM; cash if none
Calculation: Rebalance = calendar day of month differs from the previous chart bar AND calendar day of month <= P4
Long: Rebalance AND selected instrument = SPY
Long: Rebalance AND selected instrument = QQQ
Long: Rebalance AND selected instrument = IWM
Exit: Long, Rebalance AND selected instrument = cash