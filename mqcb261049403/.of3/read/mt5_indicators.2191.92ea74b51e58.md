Calculation: Color state = 1 when x > upper level; 2 when x < lower level; when middle level < x <= upper level, 2 if x[1] > upper level, otherwise state[1] if middle level < x[1] <= upper level, otherwise 1; when lower level <= x <= middle level, 2 if x[1] > middle level, otherwise state[1] if lower level <= x[1] <= middle level, otherwise 1, where x = Laguerre RSI(close, gamma) and upper, middle, and lower levels are separate parameters
Long: Color state = 1 on chart bars
Short: Color state = 2 on chart bars
Long: Color state calculated on T1 bars using the bar still forming = 1, sampled on chart bars
Short: Color state calculated on T1 bars using the bar still forming = 2, sampled on chart bars