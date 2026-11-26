Calculation: T1 polarity = up if T1 close > T1 open; down if T1 close < T1 open; else up if T1 close > T1 close[1]; else down if T1 close < T1 close[1]; else the last known polarity
Calculation: Delta volume = sum over the completed T1 bars within the chart bar of volume * (+1 if T1 polarity is up, -1 if down)
Calculation: Intrabar volume = sum over the completed T1 bars within the chart bar of volume
Calculation: DV% = 100 * Delta volume / Intrabar volume
Calculation: Relative volume weight = PercentRank(Intrabar volume, R) / 100 if relative-volume weighting is enabled, else 1
Calculation: Weighted source = source + sign(DV%) * MIN(source * abs(DV%) / 100 * Relative volume weight, K * STDEV(source, L))
Calculation: Reference = MA(source, L, type)
Calculation: DV-weighted MA = MA(Weighted source, L, type)
Calculation: DV bull = DV-weighted MA > Reference
Calculation: DV bear = NOT DV bull
Calculation: DV strong bull = DV bull AND close > Reference AND Reference > Reference[1] AND DV-weighted MA > DV-weighted MA[1]
Calculation: DV strong bear = DV bear AND close < Reference AND Reference < Reference[1] AND DV-weighted MA < DV-weighted MA[1]
Calculation: Divergence = Delta volume != 0 AND sign(Reference - Reference[1]) != sign(DV-weighted MA - DV-weighted MA[1])
Calculation: Enters(X) = X AND NOT X[1]
Calculation: New channel = Divergence AND (Div-channel bull OR Div-channel bear)[1]
Calculation: Div-channel top = Level-high if New channel; else MAX(Div-channel top[1], Level-high) if Divergence; else Div-channel top[1]; Level-high = high, or MAX(open, close), per the level-source parameter
Calculation: Div-channel bottom = Level-low if New channel; else MIN(Div-channel bottom[1], Level-low) if Divergence; else Div-channel bottom[1]; Level-low = low, or MIN(open, close), per the level-source parameter
Calculation: Div-channel bull = NOT New channel AND (Up-breach price > Div-channel top[1] OR (Div-channel bull[1] AND NOT Down-breach price < Div-channel bottom[1])); Up-breach price and Down-breach price are the bar prices selected by the breach-source parameter for the top and bottom
Calculation: Div-channel bear = NOT New channel AND (Down-breach price < Div-channel bottom[1] OR (Div-channel bear[1] AND NOT Up-breach price > Div-channel top[1]))
Calculation: Div-channel strong bull = Div-channel bull AND DV strong bull
Calculation: Div-channel strong bear = Div-channel bear AND DV strong bear
Calculation: Top changes = 0 if New channel; else Top changes[1] + 1 if Div-channel top > Div-channel top[1]; else Top changes[1]
Calculation: Bottom changes = 0 if New channel; else Bottom changes[1] + 1 if Div-channel bottom < Div-channel bottom[1]; else Bottom changes[1]
Long: (Enters(DV bull) AND up-trigger(DV bull) OR Enters(DV strong bull) AND up-trigger(DV strong bull) OR Enters(Div-channel bull) AND up-trigger(Div-channel bull) OR Enters(Div-channel strong bull) AND up-trigger(Div-channel strong bull)) AND (NOT bar-polarity filter OR close > open) AND (NOT close-to-close filter OR close > close[1]) AND (NOT CCI filter OR CCI(close, L) > 0) AND (NOT rising-volume filter OR volume > volume[1]) AND (NOT divergence filter OR BarsSince(Divergence) <= N) AND (NOT Efficient-Work filter OR EfficientWork(L) > 0)
Short: (Enters(DV bear) AND down-trigger(DV bear) OR Enters(DV strong bear) AND down-trigger(DV strong bear) OR Enters(Div-channel bear) AND down-trigger(Div-channel bear) OR Enters(Div-channel strong bear) AND down-trigger(Div-channel strong bear)) AND (NOT bar-polarity filter OR close < open) AND (NOT close-to-close filter OR close < close[1]) AND (NOT CCI filter OR CCI(close, L) < 0) AND (NOT rising-volume filter OR volume > volume[1]) AND (NOT divergence filter OR BarsSince(Divergence) <= N) AND (NOT Efficient-Work filter OR EfficientWork(L) < 0)
Long: DV bull
Short: DV bear
Long: Div-channel bull
Short: Div-channel bear
Long: NOT Divergence AND (uses-DV OR uses-Div) AND (DV bull OR NOT uses-DV) AND (Div-channel bull OR NOT uses-Div) AND (NOT empty-on-falling-volume filter OR volume >= volume[1])
Short: NOT Divergence AND (uses-DV OR uses-Div) AND (DV bear OR NOT uses-DV) AND (Div-channel bear OR NOT uses-Div) AND (NOT empty-on-falling-volume filter OR volume >= volume[1])
Long: bias-estimate enabled AND NOT (Div-channel bull OR Div-channel bear) AND NOT New channel AND Top changes > Bottom changes
Short: bias-estimate enabled AND NOT (Div-channel bull OR Div-channel bear) AND NOT New channel AND Top changes < Bottom changes