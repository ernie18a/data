Calculation: Polarity = for each T1 bar: up if T1 close > T1 open; down if T1 close < T1 open; otherwise up if T1 close > previous T1 close; down if T1 close < previous T1 close; otherwise the previous T1 bar's Polarity
Calculation: UpVolume = sum of volume of the completed T1 bars within the chart bar whose Polarity is up
Calculation: DownVolume = sum of volume of the completed T1 bars within the chart bar whose Polarity is down
Calculation: BarBalance = UpVolume - DownVolume
Calculation: AverageBalance = EMA(UpVolume, average lookback) - EMA(DownVolume, average lookback)
Calculation: MomentumBalance = RSI((EMA(UpVolume, average lookback) - SMA(UpVolume, 2 * average lookback)) - (EMA(DownVolume, average lookback) - SMA(DownVolume, 2 * average lookback)), momentum lookback) - 50
Calculation: RelativeBalance = ALMA(max(0, UpVolume - EMA(UpVolume, average lookback)) - max(0, DownVolume - EMA(DownVolume, average lookback)), relative lookback, ALMA offset, ALMA sigma)
Calculation: PercentBalance = ALMA(BarBalance / volume, percent lookback, ALMA offset, ALMA sigma)
Calculation: CombinedBalance = sign(BarBalance) + sign(AverageBalance) + sign(MomentumBalance) + sign(RelativeBalance) + sign(PercentBalance)
Calculation: SelectedBalance(s) = BarBalance if s is on-bar; AverageBalance if s is average; MomentumBalance if s is momentum; RelativeBalance if s is relative; PercentBalance if s is percent; CombinedBalance if s is combined
Calculation: DivergenceUp(s) = SelectedBalance(s) > SelectedBalance(s)[1] AND close < close[1]
Calculation: DivergenceDown(s) = SelectedBalance(s) < SelectedBalance(s)[1] AND close > close[1]
Calculation: UpBump = close > close[1] AND BarBalance > 0 AND UpVolume > EMA(UpVolume, average lookback) AND UpVolume > UpVolume[1]
Calculation: DownBump = close < close[1] AND BarBalance < 0 AND DownVolume > EMA(DownVolume, average lookback) AND DownVolume > DownVolume[1]
Calculation: Marker1Up = CombinedBalance == 5
Calculation: Marker1Down = CombinedBalance == -5
Calculation: Marker2Up = UpBump[1] AND UpBump[2]
Calculation: Marker2Down = DownBump[1] AND DownBump[2]
Calculation: Marker3Up = DivergenceUp(marker 3 balance)[2] AND close[1] > close[2] AND NOT DivergenceDown(marker 3 balance)[1]
Calculation: Marker3Down = DivergenceDown(marker 3 balance)[2] AND close[1] < close[2] AND NOT DivergenceUp(marker 3 balance)[1]
Calculation: Marker4Up = SelectedBalance(marker 4 balance)[1] > 0 AND SelectedBalance(marker 4 balance)[2] <= 0
Calculation: Marker4Down = SelectedBalance(marker 4 balance)[1] < 0 AND SelectedBalance(marker 4 balance)[2] >= 0
Calculation: MarkerBias = SUM(Marker1Up + Marker2Up + Marker3Up + Marker4Up - Marker1Down - Marker2Down - Marker3Down - Marker4Down, bias lookback)
Long: Marker1Up
Short: Marker1Down
Long: Marker2Up
Short: Marker2Down
Long: Marker3Up
Short: Marker3Down
Long: Marker4Up
Short: Marker4Down
Long: MarkerBias[1] > 0 AND MarkerBias[2] <= 0
Short: MarkerBias[1] < 0 AND MarkerBias[2] >= 0