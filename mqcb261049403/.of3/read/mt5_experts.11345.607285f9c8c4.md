Calculation: First line = moving average(applied price, first smoothing method, first lookback, first phase) on T1 bars
Calculation: Second line = moving average(First line, second smoothing method, second lookback, second phase) on T1 bars
Long: First line crosses above Second line on the last completed T1 bar
Short: First line crosses below Second line on the last completed T1 bar
Exit: long, First line < Second line on the last completed T1 bar
Exit: short, First line > Second line on the last completed T1 bar