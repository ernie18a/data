Calculation: VolumeProfile(bin) = sum over the last history length bars of volume * 0.5^(bars ago / decay length) * fraction of that bar's high-low range lying in bin, where bin count equal bins span from the lowest low to the highest high of those bars
Calculation: NormProfile(bin) = (VolumeProfile(bin) - min over bins of VolumeProfile) / (max over bins of VolumeProfile - min over bins of VolumeProfile) * 100
Calculation: ThinAbove = center of the lowest bin whose center is above close and whose NormProfile <= thin percentile, or undefined if no such bin
Calculation: ThinBelow = center of the highest bin whose center is at or below close and whose NormProfile <= thin percentile, or undefined if no such bin
Calculation: AnchoredVWAP = AVWAP(hlc3, volume, anchor, T1, last completed bar)
Long: CMF(high, low, close, volume, imbalance length, T1, last completed bar) > pressure threshold
Short: CMF(high, low, close, volume, imbalance length, T1, last completed bar) < -pressure threshold
Long: close >= AnchoredVWAP
Short: close < AnchoredVWAP
Long: close >= AnchoredVWAP AND AnchoredVWAP >= AnchoredVWAP[1]
Short: close < AnchoredVWAP AND AnchoredVWAP < AnchoredVWAP[1]
Long: ThinAbove exists AND (ThinBelow does not exist OR ThinAbove - close < close - ThinBelow)
Short: ThinBelow exists AND (ThinAbove does not exist OR close - ThinBelow <= ThinAbove - close)