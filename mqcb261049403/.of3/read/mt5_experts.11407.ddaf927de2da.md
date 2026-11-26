Calculation: unit = (high - low) / selected volume, using 1 when selected volume is zero
Calculation: wick = 0 when open = close, otherwise ((high - low) - abs(open - close)) / (2 * unit)
Calculation: bull line = smooth(wick + (open > close ? (open - close) / unit : 0), selected method, phase, length) on T1 bars
Calculation: bear line = smooth(wick + (open < close ? (close - open) / unit : 0), selected method, phase, length) on T1 bars
Long: long entry enabled AND on chart bars using T1 values, bull line[1, last completed] > bear line[1, last completed] AND bull line[0, forming] <= bear line[0, forming]
Short: short entry enabled AND on chart bars using T1 values, bull line[1, last completed] < bear line[1, last completed] AND bull line[0, forming] >= bear line[0, forming]
Exit: long, long exit enabled AND on chart bars using T1 values, bull line[1, last completed] < bear line[1, last completed]
Exit: short, short exit enabled AND on chart bars using T1 values, bull line[1, last completed] > bear line[1, last completed]