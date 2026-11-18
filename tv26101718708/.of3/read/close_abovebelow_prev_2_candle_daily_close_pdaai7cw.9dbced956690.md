Long: On chart bars using the last completed T1 bar, its close > its high[1] AND its close > its high[2]
Short: On chart bars using the last completed T1 bar, its close < its low[1] AND its close < its low[2]
Calculation: Long stop = T1 close - (T1 high[1] - T1 high[2]) on the long-entry signal bar
Calculation: Long target = T1 close + (T1 close - Long stop) * risk/reward ratio on the long-entry signal bar
Calculation: Short stop = T1 close + (T1 low[1] - T1 low[2]) on the short-entry signal bar
Calculation: Short target = T1 close - (Short stop - T1 close) * risk/reward ratio on the short-entry signal bar
Exit: Long, chart-bar low <= Long stop OR chart-bar high >= Long target
Exit: Short, chart-bar high >= Short stop OR chart-bar low <= Short target