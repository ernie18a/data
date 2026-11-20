Calculation: Session gap = open - close[1]
Calculation: T1 ATR = ATR(ATR lookback, T1, last completed bar on historical chart bars or still-forming bar in realtime), sampled on chart bars
Calculation: Gap threshold = gap multiplier × T1 ATR
Long: On the first chart bar of each T1 period AND T1 ATR is positive AND Session gap > 0 AND Session gap >= Gap threshold AND Session gap > minimum price increment
Short: On the first chart bar of each T1 period AND T1 ATR is positive AND Session gap < 0 AND -Session gap >= Gap threshold AND -Session gap > minimum price increment