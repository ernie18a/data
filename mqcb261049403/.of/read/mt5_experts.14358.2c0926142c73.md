Calculation: Bull line = EMA of the sum of current high minus the highest high over each of three lookbacks (short, medium, and long), on completed bars of the configured indicator timeframe (which may be higher, lower, or equal to the chart timeframe)
Calculation: Bear line = EMA of the sum of the lowest low over each of three lookbacks (short, medium, and long) minus current low, on completed bars of the configured indicator timeframe (which may be higher, lower, or equal to the chart timeframe)
Long: Previous completed bar Bull line <= Bear line AND current completed bar Bull line > Bear line
Short: Previous completed bar Bull line >= Bear line AND current completed bar Bull line < Bear line
Exit: long, Bull line < Bear line
Exit: short, Bull line > Bear line