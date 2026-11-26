Calculation: upper level = highest(high, UpTrailPeriods bars starting UpTrailShift bars ago)
Calculation: lower level = lowest(low, DnTrailPeriods bars starting DnTrailShift bars ago)
Long: chart bar close > upper level
Short: chart bar close < lower level
Long: On each new T1 bar, long-entry permission enabled AND last completed T1 bar close > upper level for that bar AND T1 bar still forming close <= upper level for that bar
Short: On each new T1 bar, short-entry permission enabled AND last completed T1 bar close < lower level for that bar AND T1 bar still forming close >= lower level for that bar
Exit: short, short-closing permission enabled AND last completed T1 bar close > upper level for that bar
Exit: long, long-closing permission enabled AND last completed T1 bar close < lower level for that bar
Exit: long, time-based exit enabled AND elapsed position time > holding-duration parameter
Exit: short, time-based exit enabled AND elapsed position time > holding-duration parameter