Calculation: Tick size = (high - low) / selected volume source (tick volume or volume), or 1 if the result is 0
Calculation: Swing = ((high - low) + abs(open - close)) / (2 * Tick size)
Calculation: Bull line = moving average(method, lookback, phase, if open > close then (open - close) / Tick size + Swing else Swing), calculated on each T1 bar
Calculation: Bear line = moving average(the same method, lookback, and phase as Bull line, if open < close then (close - open) / Tick size + Swing else Swing), calculated on each T1 bar
Long: long-entry permission enabled AND Bull line > Bear line on the latest completed T1 bar AND Bull line <= Bear line on the preceding completed T1 bar
Short: short-entry permission enabled AND Bear line > Bull line on the latest completed T1 bar AND Bear line <= Bull line on the preceding completed T1 bar
Exit: long, long-exit permission enabled AND Bear line > Bull line on the latest completed T1 bar
Exit: short, short-exit permission enabled AND Bull line > Bear line on the latest completed T1 bar