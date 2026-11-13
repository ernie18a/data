Calculation: AVWAP = running sum(typical price (high+low+close)/3 * volume) / running sum(volume), both sums reset at the first bar of each new calendar period that is higher than the chart timeframe; if the cumulative volume is 0, use typical price
Calculation: MACD = EMA(AVWAP, short lookback) - EMA(AVWAP, long lookback)
Calculation: Signal = EMA(MACD, signal lookback)
Calculation: Hist = MACD - Signal
Calculation: RelVol = volume / SMA(volume, lookback)
Calculation: PivotLow = a bar whose low is the lowest among L bars to its left and R bars to its right; it is confirmed on the bar R bars later. PivotHigh = a bar whose high is the highest over the same window, confirmed on the bar R bars later
Long: (MACD crosses above Signal on this bar (MACD > Signal now and MACD <= Signal on the previous bar) AND RelVol >= 1.0) OR (a PivotLow is confirmed on this bar AND its low < the low of the previous confirmed PivotLow AND Hist at the pivot bar > Hist at the previous confirmed PivotLow bar)
Short: (MACD crosses below Signal on this bar (MACD < Signal now and MACD >= Signal on the previous bar) AND RelVol >= 1.0) OR (a PivotHigh is confirmed on this bar AND its high > the high of the previous confirmed PivotHigh AND Hist at the pivot bar < Hist at the previous confirmed PivotHigh bar)