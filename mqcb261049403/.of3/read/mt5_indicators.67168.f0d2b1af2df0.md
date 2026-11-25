Calculation: long stop level = low[1](T1, last completed bar) + (high[1](T1, last completed bar) - low[1](T1, last completed bar)) * long stop parameter
Calculation: long take-profit level = low[1](T1, last completed bar) + (high[1](T1, last completed bar) - low[1](T1, last completed bar)) * long take-profit parameter
Calculation: short stop level = low[1](T1, last completed bar) + (high[1](T1, last completed bar) - low[1](T1, last completed bar)) * short stop parameter
Calculation: short take-profit level = low[1](T1, last completed bar) - (high[1](T1, last completed bar) - low[1](T1, last completed bar)) * absolute value of short take-profit parameter
Long: on chart bars, close > high[1](T1, last completed bar)
Short: on chart bars, close < low[1](T1, last completed bar)
Exit: long, on chart bars, low <= long stop level OR high >= long take-profit level
Exit: short, on chart bars, high >= short stop level OR low <= short take-profit level