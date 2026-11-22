Calculation: Down-volume share = down-volume close / (up-volume close + down-volume close), using the current T1 values on chart bars (the T1 bar may still be forming); available only when down-volume time is on the current calendar day and the volume sum is positive
Long: down-volume share <= buying threshold AND chart bar is confirmed AND (RTH filter is disabled OR bar time is during regular trading hours)
Short: down-volume share >= selling threshold AND chart bar is confirmed AND (RTH filter is disabled OR bar time is during regular trading hours)
Calculation: Down Volume Ratio = Down Volume at T1 / (Up Volume at T1 + Down Volume at T1), when Down Volume data is from the current T2 period and total volume is positive
Long: Down Volume Ratio >= P1 AND during regular trading hours AND chart bar is confirmed
Short: Down Volume Ratio <= P2 AND during regular trading hours AND chart bar is confirmed