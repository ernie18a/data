Calculation: Sweep(side, B) = for bull: low(B) < low(P) AND close(B) >= low(P); for bear: high(B) > high(P) AND close(B) <= high(P); B is a T1 bar with its values as of the current chart bar, and P is the T1 bar before B
Calculation: SweepX(side, B) = for bull: low(S) < low(P) AND close(S) < low(P) AND close(B) > high(S) AND close(B) > open(S); for bear: high(S) > high(P) AND close(S) > high(P) AND close(B) < low(S) AND close(B) < open(S); B is a T1 bar with its values as of the current chart bar, S is the T1 bar before B, and P is the T1 bar before S
Calculation: Setup(side, B) = Sweep(side, B) OR SweepX(side, B)
Calculation: SweepBar(side, B) = B if Sweep(side, B), otherwise the T1 bar before B
Calculation: WindowOpen(B) = the current chart bar lies within the first (confirmation window - 1) T1 bars that open after the completed T1 bar B
Calculation: RunOrigin(side, X) = for bull: the open of the oldest bar in the run of consecutive bearish chart bars (close < open) that begins at the newest bearish chart bar among X and the run start tolerance chart bars older than X and extends back while bars stay bearish; for bear: the same with bullish chart bars (close > open); searched no further back than origin lookback chart bars from the current bar, and the run has at most run length limit bars
Calculation: Gap(side, X, O) = for bull: low(j+2) of the most recent chart bar j, scanning back from X toward O, such that high(j) < low(j+2) and j+2 is not older than O; for bear: high(j+2) of the most recent chart bar j such that low(j) > high(j+2); absent if no such j lies within gap lookback chart bars of the current bar
Calculation: Confirmed(side) = for some completed T1 bar B with WindowOpen(B) AND Setup(side, B), let SB = SweepBar(side, B), X = the chart bar printing the low (bull) or high (bear) of SB, and O = RunOrigin(side, X): for bull, low has stayed at or above low(SB) on every chart bar since B completed, some close of SB or of a chart bar since B completed is above O, and Gap(bull, X, O) is absent or some such close is above it; for bear, high has stayed at or below high(SB), some such close is below O, and Gap(bear, X, O) is absent or some such close is below it
Long: Setup(bull, B), where B is the T1 bar completing on this chart bar
Long: Setup(bull, B), where B is the still-forming T1 bar
Long: Confirmed(bull) AND NOT Confirmed(bull)[1]
Short: Setup(bear, B), where B is the T1 bar completing on this chart bar
Short: Setup(bear, B), where B is the still-forming T1 bar
Short: Confirmed(bear) AND NOT Confirmed(bear)[1]
Exit: long, low < low(SweepBar(bull, B)) for some completed T1 bar B with WindowOpen(B) AND Setup(bull, B)
Exit: short, high > high(SweepBar(bear, B)) for some completed T1 bar B with WindowOpen(B) AND Setup(bear, B)