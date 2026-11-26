Calculation: ATRDirection(Ti) = SuperTrend direction(source(Ti), ATR period(Ti), ATR multiplier(Ti)) on Ti bars, last completed Ti bar
Calculation: StochDirection(Ti) = up when K crosses above D, down when K crosses below D, otherwise StochDirection(Ti)[1]; K = SMA(StochRSI(close, length(Ti), length(Ti)), K smoothing(Ti)), D = SMA(K, D smoothing(Ti)); on Ti bars, last completed Ti bar
Calculation: MADirection(Ti) = up when close > SMA(close, MA period(Ti)), down when close < SMA(close, MA period(Ti)); on Ti bars, last completed Ti bar
Calculation: UpScore(Ti) = sum of ATR weight if ATRDirection(Ti) = up, StochRSI weight if StochDirection(Ti) = up, and MA weight if MADirection(Ti) = up
Calculation: DownScore(Ti) = sum of ATR weight if ATRDirection(Ti) = down, StochRSI weight if StochDirection(Ti) = down, and MA weight if MADirection(Ti) = down
Calculation: UpBias = (sum over Ti of weight(Ti) * UpScore(Ti)) / (sum over Ti of weight(Ti))
Calculation: DownBias = (sum over Ti of weight(Ti) * DownScore(Ti)) / (sum over Ti of weight(Ti))
Calculation: NetBias = UpBias - DownBias
Long: NetBias >= X threshold AND NetBias[1] < X threshold
Short: NetBias <= -X threshold AND NetBias[1] > -X threshold
Long: UpBias > neutral level + alert margin
Short: DownBias > neutral level + alert margin
Long: UpBias > DownBias
Short: DownBias > UpBias
Long: UpScore(Ti) > DownScore(Ti)
Short: DownScore(Ti) > UpScore(Ti)
Long: ATRDirection(Ti) = up
Short: ATRDirection(Ti) = down
Long: StochDirection(Ti) = up
Short: StochDirection(Ti) = down
Long: MADirection(Ti) = up
Short: MADirection(Ti) = down