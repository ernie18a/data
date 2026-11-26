Calculation: AdjReturn = IF(earnings-announcement flag OR earnings-announcement flag[1], 0, LN((close + dividend amount) / close[1]))
Calculation: DriftT = SMA(AdjReturn, drift lookback) * SQRT(drift lookback) / STDEV(AdjReturn, drift lookback)
Option: sell put, DriftT > drift threshold
Option: sell call, DriftT < -drift threshold