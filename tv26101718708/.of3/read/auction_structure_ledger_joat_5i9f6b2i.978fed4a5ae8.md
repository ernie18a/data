Calculation: LowClusterCount = count of k from 0 to cluster window where PivotLow(low, pivot length, pivot length)[k] is not na and abs(PivotLow(low, pivot length, pivot length)[k] - PivotLow(low, pivot length, pivot length)) <= ATR(high, low, close, atr length) * cluster tolerance
Calculation: HighClusterCount = count of k from 0 to cluster window where PivotHigh(high, pivot length, pivot length)[k] is not na and abs(PivotHigh(high, pivot length, pivot length)[k] - PivotHigh(high, pivot length, pivot length)) <= ATR(high, low, close, atr length) * cluster tolerance
Calculation: VolumeProfileScore = 100 * (sum of volume[k] over k from 0 to volume window - 1 where close[k] lies in the same bin as close) / (largest such bin sum over all bins), where the bins are equal-width bins, their number being volume bins, spanning the lowest low to the highest high over the same k
Calculation: SupportZoneTally = count of support zones counted on the current bar, where each bar with PivotLow(low, pivot length, pivot length) not na and LowClusterCount >= 2 stores a support zone at that pivot low, and a stored zone is counted from its storage bar through the first later bar where close < zone bottom and more than removal buffer bars have passed since storage, zone bottom = stored pivot low - shelf ATR width * ATR(high, low, close, atr length) at storage
Calculation: ResistanceZoneTally = count of resistance zones counted on the current bar, where each bar with PivotHigh(high, pivot length, pivot length) not na and HighClusterCount >= 2 stores a resistance zone at that pivot high, and a stored zone is counted from its storage bar through the first later bar where close > zone top and more than removal buffer bars have passed since storage, zone top = stored pivot high + shelf ATR width * ATR(high, low, close, atr length) at storage
Long: bar is confirmed AND SupportZoneTally > ResistanceZoneTally AND VolumeProfileScore >= volume score threshold
Long: bar is confirmed AND PivotLow(low, pivot length, pivot length) is not na AND LowClusterCount >= 2
Long: SupportZoneTally > ResistanceZoneTally
Long: SupportZoneTally >= ResistanceZoneTally
Long: SupportZoneTally > 0
Short: bar is confirmed AND ResistanceZoneTally > SupportZoneTally AND VolumeProfileScore < volume score threshold
Short: bar is confirmed AND PivotHigh(high, pivot length, pivot length) is not na AND HighClusterCount >= 2
Short: ResistanceZoneTally > SupportZoneTally
Short: ResistanceZoneTally > 0