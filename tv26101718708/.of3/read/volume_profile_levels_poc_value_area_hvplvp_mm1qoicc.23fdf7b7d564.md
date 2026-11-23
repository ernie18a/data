Calculation: POC = point of control of VolumeProfile(T1, lookback, row count, last completed T1 bar)
Calculation: VAH = value area high of VolumeProfile(T1, lookback, row count, value area percent, last completed T1 bar)
Calculation: VAL = value area low of VolumeProfile(T1, lookback, row count, value area percent, last completed T1 bar)
Calculation: HVN levels = midpoint prices of up to max levels rows with the greatest volume, among rows other than the first and last of VolumeProfile(T1, lookback, row count, last completed T1 bar) whose volume is greater than the volume of the row below, at least the volume of the row above, and greater than mean row volume times HVN threshold
Calculation: LVN levels = midpoint prices of up to max levels rows with the least volume, among rows other than the first and last of VolumeProfile(T1, lookback, row count, last completed T1 bar) whose volume is less than the volume of the row below, at most the volume of the row above, and less than mean row volume times LVN threshold
Calculation: Armed(L, W, D) = the latest bar s before this bar at which L is crossed (up: close > L AND close[1] <= L; down: close < L AND close[1] >= L) is a cross in direction D, lies 1 to W bars before this bar, and no bar strictly between s and this bar has low <= L <= high AND (up: close > L; down: close < L)
Long: close > POC AND close[1] <= POC
Long: close > VAH AND close[1] <= VAH
Long: close > VAL AND close[1] <= VAL
Short: close < POC AND close[1] >= POC
Short: close < VAH AND close[1] >= VAH
Short: close < VAL AND close[1] >= VAL
Long: close > h AND close[1] <= h, for some h in HVN levels
Short: close < h AND close[1] >= h, for some h in HVN levels
Long: close > h AND close[1] <= h, for some h in LVN levels
Short: close < h AND close[1] >= h, for some h in LVN levels
Long: Armed(POC, flip window, up) AND low <= POC <= high AND close > POC
Long: Armed(VAH, flip window, up) AND low <= VAH <= high AND close > VAH
Long: Armed(VAL, flip window, up) AND low <= VAL <= high AND close > VAL
Short: Armed(POC, flip window, down) AND low <= POC <= high AND close < POC
Short: Armed(VAH, flip window, down) AND low <= VAH <= high AND close < VAH
Short: Armed(VAL, flip window, down) AND low <= VAL <= high AND close < VAL