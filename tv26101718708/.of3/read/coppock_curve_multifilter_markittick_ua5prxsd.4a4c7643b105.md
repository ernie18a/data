Calculation: Smoothed = PreFilter(price source, pre-filter length), where PreFilter returns price source when no pre-filter type is selected
Calculation: CoppockCurve = WMA(ROC(Smoothed, longer ROC lookback) + ROC(Smoothed, shorter ROC lookback), WMA length)
Calculation: EntryRisk = SL ATR multiple * ATR(ATR length) at the entry bar
Calculation: BearishDivergence = most recent confirmed PivotHigh(high, divergence pivot lookback) is above the previous confirmed PivotHigh AND CoppockCurve at the bar of the most recent PivotHigh is below CoppockCurve at the bar of the previous PivotHigh
Calculation: BullishDivergence = most recent confirmed PivotLow(low, divergence pivot lookback) is below the previous confirmed PivotLow AND CoppockCurve at the bar of the most recent PivotLow is above CoppockCurve at the bar of the previous PivotLow
Calculation: RiseStreak = number of consecutive bars ending at the current bar where CoppockCurve > CoppockCurve[1]
Calculation: FallStreak = number of consecutive bars ending at the current bar where CoppockCurve < CoppockCurve[1]
Calculation: HTFRising = CoppockCurve computed on T1 bars at the last completed T1 bar > CoppockCurve computed on T1 bars at the T1 bar before it
Long: CoppockCurve crosses above CoppockCurve[1] AND (not ADX filter enabled OR ADX(ADX length) >= ADX threshold) AND (not divergence filter enabled OR not BearishDivergence) AND (not acceleration filter enabled OR CoppockCurve - CoppockCurve[1] > CoppockCurve[1] - CoppockCurve[2]) AND (not volume filter enabled OR volume > SMA(volume, volume MA length)) AND (not HTF filter enabled OR HTFRising) AND (not persistence filter enabled OR FallStreak[1] >= persistence bars)
Long: CoppockCurve crosses above 0 AND (not ADX filter enabled OR ADX(ADX length) >= ADX threshold) AND (not volatility zero filter enabled OR ABS(CoppockCurve) > StDev(CoppockCurve, volatility band length) * volatility band multiple)
Long: CoppockCurve > CoppockCurve[1] AND (not ADX filter enabled OR ADX(ADX length) >= ADX threshold)
Long: CoppockCurve >= 0
Short: CoppockCurve crosses below CoppockCurve[1] AND (not ADX filter enabled OR ADX(ADX length) >= ADX threshold) AND (not divergence filter enabled OR not BullishDivergence) AND (not acceleration filter enabled OR CoppockCurve - CoppockCurve[1] < CoppockCurve[1] - CoppockCurve[2]) AND (not volume filter enabled OR volume > SMA(volume, volume MA length)) AND (not HTF filter enabled OR not HTFRising) AND (not persistence filter enabled OR RiseStreak[1] >= persistence bars)
Short: CoppockCurve crosses below 0 AND (not ADX filter enabled OR ADX(ADX length) >= ADX threshold) AND (not volatility zero filter enabled OR ABS(CoppockCurve) > StDev(CoppockCurve, volatility band length) * volatility band multiple)
Short: CoppockCurve < CoppockCurve[1] AND (not ADX filter enabled OR ADX(ADX length) >= ADX threshold)
Short: CoppockCurve < 0
Exit: long, bars since entry >= 1 AND low <= entry price - EntryRisk
Exit: long, bars since entry >= 1 AND high >= entry price + TP1 R-multiple * EntryRisk AND low > entry price - EntryRisk
Exit: long, bars since entry >= 1 AND high >= entry price + TP2 R-multiple * EntryRisk AND low > entry price - EntryRisk
Exit: long, bars since entry >= 1 AND high >= entry price + TP3 R-multiple * EntryRisk AND low > entry price - EntryRisk
Exit: short, bars since entry >= 1 AND high >= entry price + EntryRisk
Exit: short, bars since entry >= 1 AND low <= entry price - TP1 R-multiple * EntryRisk AND high < entry price + EntryRisk
Exit: short, bars since entry >= 1 AND low <= entry price - TP2 R-multiple * EntryRisk AND high < entry price + EntryRisk
Exit: short, bars since entry >= 1 AND low <= entry price - TP3 R-multiple * EntryRisk AND high < entry price + EntryRisk