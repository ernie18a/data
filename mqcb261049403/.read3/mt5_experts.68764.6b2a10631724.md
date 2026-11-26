Calculation: range high = highest(high on completed T1 bars during the range period)
Calculation: range low = lowest(low on completed T1 bars during the range period)
Long: close of the last completed T1 bar > range high AND datetime of that bar != range end time
Short: close of the last completed T1 bar < range low AND datetime of that bar != range end time
Exit: long, current datetime > trading end time
Exit: short, current datetime > trading end time