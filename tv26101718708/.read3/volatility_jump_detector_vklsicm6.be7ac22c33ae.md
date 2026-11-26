Calculation: LogReturn = LN(close / close[1])
Calculation: RobustVariance = IF(estimator is MedRV, MedRV(LogReturn, local window)[1], BipowerVariation(LogReturn, local window)[1])
Calculation: LeeMyklandStat = IF(RobustVariance > 0, ABS(LogReturn) / SQRT(RobustVariance), 0)
Calculation: Threshold = IF(threshold mode is fixed, fixed multiple, LeeMykland critical value(scan window, false-positive level))
Calculation: SuppressedBar = gap suppression AND intraday AND first regular-session bar
Long: LeeMyklandStat > Threshold AND LogReturn > 0 AND NOT SuppressedBar
Short: LeeMyklandStat > Threshold AND LogReturn < 0 AND NOT SuppressedBar