Calculation: RSI = RSI of close on the chart timeframe
Calculation: MFI = Money Flow Index on the chart timeframe, using typical price (high+low+close)/3 and volume
Calculation: PivotLow = a bar whose low is the lowest low among the same number N of bars on each side; it is confirmed N bars after the pivot bar. PrevPivotLow is the confirmed PivotLow immediately before the latest one.
Calculation: PivotHigh = a bar whose high is the highest high among the same number N of bars on each side; it is confirmed N bars after the pivot bar. PrevPivotHigh is the confirmed PivotHigh immediately before the latest one.
Long: RSI < RSI oversold level AND MFI < MFI oversold level (the MFI oversold level is lower than the RSI oversold level)
Long: on the bar where a new PivotLow is confirmed, the new PivotLow low < PrevPivotLow low AND (RSI at the new pivot bar > RSI at the PrevPivotLow bar OR MFI at the new pivot bar > MFI at the PrevPivotLow bar)
Short: RSI > RSI overbought level AND MFI > MFI overbought level (the MFI overbought level is higher than the RSI overbought level)
Short: on the bar where a new PivotHigh is confirmed, the new PivotHigh high > PrevPivotHigh high AND (RSI at the new pivot bar < RSI at the PrevPivotHigh bar OR MFI at the new pivot bar < MFI at the PrevPivotHigh bar)