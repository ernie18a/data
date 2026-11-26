Calculation: Body = abs(close - open)
Calculation: BodyOK = Body[k] > M * SMA(Body, L)[k] for all k from 0 to N-1
Calculation: UpSetup = close[N] < open[N] AND close[k] > open[k] for all k from 0 to N-1 AND BodyOK
Calculation: DownSetup = close[N] > open[N] AND close[k] < open[k] for all k from 0 to N-1 AND BodyOK
Calculation: LastSetupDir = 1 if UpSetup, -1 if DownSetup, otherwise LastSetupDir[1]
Calculation: LastSetupLevel = Lowest(low, N) + F * (Highest(high, N) - Lowest(low, N)) if UpSetup or DownSetup, otherwise LastSetupLevel[1]
Calculation: HighPivot = PivotHigh(high, P, P) if not NA, otherwise HighPivot[1]
Calculation: LowPivot = PivotLow(low, P, P) if not NA, otherwise LowPivot[1]
Calculation: BreakUp = (close if B, otherwise high) > HighPivot for the first time since the latest pivot high was confirmed
Calculation: BreakDown = (close if B, otherwise low) < LowPivot for the first time since the latest pivot low was confirmed
Calculation: StructureDir = -1 if BreakDown, 1 if BreakUp, otherwise StructureDir[1]
Long: UpSetup
Long: LastSetupDir = -1 AND close > LastSetupLevel for the first time since the most recent UpSetup or DownSetup
Long: BreakUp
Long: StructureDir = 1
Long: close > Open(T1, forming, chart bars)
Long: RSI(close, R) < LT
Long: PlusDI(DL) > MinusDI(DL)
Long: ROC(close, K) > 0
Short: DownSetup
Short: LastSetupDir = 1 AND close < LastSetupLevel for the first time since the most recent UpSetup or DownSetup
Short: BreakDown
Short: StructureDir = -1
Short: close <= Open(T1, forming, chart bars)
Short: RSI(close, R) > UT
Short: PlusDI(DL) <= MinusDI(DL)
Short: ROC(close, K) < 0