Calculation: CentralPivot = central pivot of PivotPoints(method, high, low, close of last completed T1 bar)
Calculation: R2Level = R2 level of PivotPoints(method, high, low, close of last completed T1 bar)
Calculation: S2Level = S2 level of PivotPoints(method, high, low, close of last completed T1 bar)
Calculation: CrossCount = number of chart bars from the second chart bar of the current T1 bar through the current chart bar where close crosses above or below CentralPivot
Calculation: R2ReachCount = number of chart bars from the second chart bar of the current T1 bar through the current chart bar where close >= R2Level
Calculation: S2ReachCount = number of chart bars from the second chart bar of the current T1 bar through the current chart bar where close <= S2Level
Long: close crosses above CentralPivot AND CrossCount = 1
Short: close crosses below CentralPivot AND CrossCount = 1
Short: close >= R2Level AND R2ReachCount = 1
Long: close <= S2Level AND S2ReachCount = 1