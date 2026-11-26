Calculation: UpVolume = sum of volume for T1 bars with close > open within each chart bar, using completed T1 bars
Calculation: DownVolume = sum of volume for T1 bars with close < open within each chart bar, using completed T1 bars
Calculation: BarBalance = UpVolume - DownVolume
Calculation: AverageBalance = EMA(UpVolume, average lookback) - EMA(DownVolume, average lookback)
Calculation: MomentumBalance = RSI((EMA(UpVolume, average lookback) - SMA(UpVolume, twice the average lookback)) - (EMA(DownVolume, average lookback) - SMA(DownVolume, twice the average lookback)), momentum lookback) - RSI center
Calculation: RelativeBalance = ALMA(max(UpVolume - EMA(UpVolume, average lookback), 0) - max(DownVolume - EMA(DownVolume, average lookback), 0), relative lookback, common ALMA offset, common ALMA sigma)
Calculation: PercentBalance = ALMA(percent scale * BarBalance / volume, percent lookback, common ALMA offset, common ALMA sigma)
Calculation: CombinedBalance = sign(BarBalance) + sign(AverageBalance) + sign(MomentumBalance) + sign(RelativeBalance) + sign(PercentBalance)
Calculation: BumpUpCount = 1 when close > open AND close > close[1] AND BarBalance > 0 AND UpVolume > EMA(UpVolume, average lookback) AND UpVolume > UpVolume[1], otherwise 0
Calculation: BumpDownCount = 1 when close < open AND close < close[1] AND BarBalance < 0 AND DownVolume > EMA(DownVolume, average lookback) AND DownVolume > DownVolume[1], otherwise 0
Calculation: DoubleBumpUpCount = 1 when BumpUpCount = 1 AND BumpUpCount[1] = 1, otherwise 0
Calculation: DoubleBumpDownCount = 1 when BumpDownCount = 1 AND BumpDownCount[1] = 1, otherwise 0
Calculation: DivergenceConfirmationUpCount = 1 when sign(selected marker-3 balance[1]) != sign(close[1] - open[1]) AND close > open AND sign(selected marker-3 balance) = sign(close - open), otherwise 0
Calculation: DivergenceConfirmationDownCount = 1 when sign(selected marker-3 balance[1]) != sign(close[1] - open[1]) AND close < open AND sign(selected marker-3 balance) = sign(close - open), otherwise 0
Calculation: BalanceShiftUpCount = 1 when selected marker-4 balance crosses above zero, otherwise 0
Calculation: BalanceShiftDownCount = 1 when selected marker-4 balance crosses below zero, otherwise 0
Calculation: MarkerBias = sum(BumpUpCount + DoubleBumpUpCount + DivergenceConfirmationUpCount + BalanceShiftUpCount - BumpDownCount - DoubleBumpDownCount - DivergenceConfirmationDownCount - BalanceShiftDownCount, bias lookback)
Long: BumpUpCount = 1 OR DivergenceConfirmationUpCount = 1 OR BalanceShiftUpCount = 1 OR MarkerBias crosses above zero OR all five balances are positive
Short: BumpDownCount = 1 OR DivergenceConfirmationDownCount = 1 OR BalanceShiftDownCount = 1 OR MarkerBias crosses below zero OR all five balances are negative