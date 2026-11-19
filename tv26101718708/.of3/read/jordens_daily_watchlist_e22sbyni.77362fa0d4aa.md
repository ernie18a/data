Calculation: Premarket high = Highest(if a T1 bar is in the configured premarket session then high else na, lookback) on T1 bars including the still-forming bar; sample onto chart bars
Calculation: Premarket low = Lowest(if a T1 bar is in the configured premarket session then low else na, lookback) on T1 bars including the still-forming bar; sample onto chart bars
Calculation: Previous T2 high = high[1] on T2 bars, using the last completed bar; sample into T1 and onto chart bars
Calculation: Previous T2 low = low[1] on T2 bars, using the last completed bar; sample into T1 and onto chart bars
Long: On chart bars, T1 close from the still-forming bar > Premarket high AND T1 close from the still-forming bar > Previous T2 high AND all four reference levels are available
Short: On chart bars, T1 close from the still-forming bar < Premarket low AND T1 close from the still-forming bar < Previous T2 low AND all four reference levels are available