Calculation: Range high = maximum(high) during the range period
Calculation: Range low = minimum(low) during the range period
Long: close of the last completed T1 bar > Range high AND datetime of that bar != range end time
Short: close of the last completed T1 bar < Range low AND datetime of that bar != range end time
Exit: long, current datetime > trading end time
Exit: short, current datetime > trading end time