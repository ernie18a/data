Calculation: Range-sweep bias(T) = on chart bars, using T's last two completed bars ([1] and [2]): -1 if high[1] > high[2] and low[2] < close[1] < high[2]; otherwise +1 if low[1] < low[2] and low[2] < close[1] < high[2]; otherwise +1 if close[1] > high[2]; otherwise -1 if close[1] < low[2]; otherwise 0
Calculation: Structure bias(T, pivot-left, pivot-right) = on T bars, update the stored levels from confirmed Pivot High/Low(pivot-left, pivot-right); become bullish when close crosses above the stored pivot high (close > level and close[1] <= level), become bearish when close crosses below the stored pivot low (close < level and close[1] >= level), and otherwise retain the prior bias (initially neutral); chart bars receive the latest completed T-bar value historically and the still-forming T-bar value in real time, with lookahead off
Long: Range-sweep bias(T1) == 1
Short: Range-sweep bias(T1) == -1
Long: Range-sweep bias(T2) == 1
Short: Range-sweep bias(T2) == -1
Long: Structure bias(T3, pivot-left, pivot-right) == 1
Short: Structure bias(T3, pivot-left, pivot-right) == -1
Long: Structure bias(T4, pivot-left, pivot-right) == 1
Short: Structure bias(T4, pivot-left, pivot-right) == -1
Long: Structure bias(T5, pivot-left, pivot-right) == 1
Short: Structure bias(T5, pivot-left, pivot-right) == -1