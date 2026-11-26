Calculation: VolBaseline = SMA(volume[baselineLag], baselineBars)
Calculation: SelCount = Count(volume >= selectedMultiple * VolBaseline, windowBars)
Calculation: UpSurges = Count(volume >= selectedMultiple * VolBaseline AND close > open, windowBars)
Calculation: DownSurges = Count(volume >= selectedMultiple * VolBaseline AND close < open, windowBars)
Calculation: NetVote = sign(close - nz(close[windowBars], close)) + sign(UpSurges - DownSurges)
Calculation: RisingBias = SelCount >= minCount AND NetVote > 0
Calculation: FallingBias = SelCount >= minCount AND NetVote < 0
Calculation: AlertState = Count(volume >= alertMultiple * VolBaseline, windowBars) >= alertCount AND (NOT requireRising OR RisingBias) AND (NOT requireFalling OR FallingBias)
Long: RisingBias
Long: RisingBias AND NOT RisingBias[1]
Long: AlertState AND NOT AlertState[1] AND RisingBias
Short: FallingBias
Short: FallingBias AND NOT FallingBias[1]
Short: AlertState AND NOT AlertState[1] AND FallingBias