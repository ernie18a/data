Calculation: Entry-candle low = low of the bar on which the long position opened
Calculation: Entry-candle high = high of the bar on which the short position opened
Calculation: Long favorable extreme = highest high since long entry
Calculation: Short favorable extreme = lowest low since short entry
Long: position is flat AND previous completed bar on a higher timeframe has close > open AND close crosses above the chart-timeframe EMA
Short: position is flat AND previous completed bar on a higher timeframe has close < open AND close crosses below the chart-timeframe EMA
Exit: long, low <= entry-candle low while long favorable extreme < entry price + activation distance OR high >= entry price + any enabled profit-target distance OR long favorable extreme >= entry price + activation distance AND close crosses below the chart-timeframe EMA
Exit: short, high >= entry-candle high while short favorable extreme > entry price - activation distance OR low <= entry price - any enabled profit-target distance OR short favorable extreme <= entry price - activation distance AND close crosses above the chart-timeframe EMA