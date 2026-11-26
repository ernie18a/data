Calculation: Break count(level, direction) = consecutive chart-bar closes strictly beyond an unchanged level in the specified direction; reset to zero when the close does not satisfy the comparison or the level changes, and do not count the bar on which the level changes
Calculation: Midpoint = (high + low) / 2 of the last completed T1 bar
Long: On a confirmed chart bar, the break count above the high of the last completed T1 bar reaches N, where N is the shared confirmation parameter
Long: On a confirmed chart bar, the break count above the midpoint of the last completed T1 bar reaches N, where N is the shared confirmation parameter
Short: On a confirmed chart bar, the break count below the low of the last completed T1 bar reaches N, where N is the shared confirmation parameter
Short: On a confirmed chart bar, the break count below the midpoint of the last completed T1 bar reaches N, where N is the shared confirmation parameter
Long: On a projected T1 bar, including the bar still forming, low > high[2] AND close >= open
Short: On a projected T1 bar, including the bar still forming, high < low[2] AND close < open