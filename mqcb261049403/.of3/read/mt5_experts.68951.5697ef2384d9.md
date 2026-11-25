Calculation: T1 swing high = high of the T1 bar lookback bars ago is greater than or equal to the highs of the T1 bars lookback minus i and lookback plus i bars ago for every i from 1 to lookback minus 1, using completed T1 bars and evaluated on chart bars
Calculation: T1 swing low = low of the T1 bar lookback bars ago is less than or equal to the lows of the T1 bars lookback minus i and lookback plus i bars ago for every i from 1 to lookback minus 1, using completed T1 bars and evaluated on chart bars
Calculation: Active T1 swing high = a T1 swing high not previously swept by a chart bar with high above it and close below it, or invalidated by a chart bar closing above it
Calculation: Active T1 swing low = a T1 swing low not previously swept by a chart bar with low below it and close above it, or invalidated by a chart bar closing below it
Long: low[1] < an active T1 swing low AND close[1] > that swing low
Short: high[1] > an active T1 swing high AND close[1] < that swing high