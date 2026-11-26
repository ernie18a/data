Calculation: prior high level = Highest(high(T1, last completed bar), lookback), evaluated on chart bars using T1 values
Calculation: prior low level = Lowest(low(T1, last completed bar), lookback), evaluated on chart bars using T1 values
Short: high(T1, bar still forming) > prior high level AND close(T1, bar still forming) < prior high level
Long: low(T1, bar still forming) < prior low level AND close(T1, bar still forming) > prior low level