Calculation: benchmark log return = log(benchmark closing price / benchmark closing price (momentum lookback in months × chart bars per month) chart bars ago)
Long: benchmark log return > 0
Short: benchmark log return < 0 AND shorts enabled
Exit: long, benchmark log return = 0 OR (benchmark log return < 0 AND shorts disabled)
Exit: short, benchmark log return = 0