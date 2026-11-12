Calculation: Delta = sign(close-open) * volume * c, with c a fixed fraction between 0 and 1 (zero when close equals open); bars use the chart timeframe only
Calculation: Rapid = (high-low) / ATR(L) > sensitivity
Calculation: LowVol = volume < SMA(volume, L) * low-volume factor, with the same lookback L as the ATR in Rapid and the factor below 1
Calculation: Imbal = abs(Delta) / volume > delta-imbalance threshold
Calculation: VacBar = Rapid AND LowVol AND NOT Imbal
Calculation: FlowBar = Rapid AND Imbal AND NOT LowVol
Calculation: Run = maximal sequence of consecutive bars that are all VacBar or all FlowBar, with length >= minimum run length (either kind or both may be enabled); RunDelta = sum of Delta over the Run
Long: the previous bar was the last bar of a Run AND the current bar is not a bar of the same kind as that Run AND RunDelta >= 0
Short: the previous bar was the last bar of a Run AND the current bar is not a bar of the same kind as that Run AND RunDelta < 0