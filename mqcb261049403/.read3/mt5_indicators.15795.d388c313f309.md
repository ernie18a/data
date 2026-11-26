Long: MFI(lookback) crosses above the lower threshold on chart bars
Short: MFI(lookback) crosses below the upper threshold on chart bars
Calculation: LatestMFIThresholdCross(T1, selected bar) = direction of the most recent MFI(lookback) cross above the lower threshold or below the upper threshold on T1 bars, read on chart bars at the selected T1 bar (forming if current, otherwise completed)
Long: LatestMFIThresholdCross(T1, selected bar) = long
Short: LatestMFIThresholdCross(T1, selected bar) = short