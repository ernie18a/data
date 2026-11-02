Calculation: Alternate moving averages = the same selectable moving-average type and period applied separately to open and close on a higher timeframe or the chart timeframe; use either the still-forming bar, the last completed higher-timeframe bar, or the still-forming value delayed by one chart bar.
Calculation: Screener moving averages = the same selectable moving-average type and period applied separately to open and close on the higher timeframe or chart timeframe, using the previous bar of that timeframe.
Calculation: Long trailing stop = the highest chart close since the long position opened, multiplied by one minus the trailing percentage.
Calculation: Short trailing stop = the lowest chart close since the short position opened, multiplied by one plus the trailing percentage.
Long: Within the enabled date range AND the alternate close moving average crosses above the alternate open moving average plus a multiplier times chart-timeframe ATR.
Short: Within the enabled date range AND the alternate close moving average crosses below the alternate open moving average minus the same multiplier times chart-timeframe ATR.
Long: Within the enabled date range AND the alternate close moving average > the alternate open moving average.
Short: Within the enabled date range AND the alternate close moving average <= the alternate open moving average.
Long: Within the enabled date range AND the alternate close moving average > the alternate open moving average plus the multiplier times chart-timeframe ATR.
Short: Within the enabled date range AND the alternate close moving average < the alternate open moving average minus the multiplier times chart-timeframe ATR.
Long: Screener close moving average > screener open moving average plus the multiplier times ATR calculated on the same timeframe as the screener moving averages, using the current bar of that timeframe; use the last completed higher-timeframe result on historical chart bars and the still-forming result in real time.
Short: Screener close moving average < screener open moving average minus the multiplier times ATR calculated on the same timeframe as the screener moving averages, using the current bar of that timeframe; use the last completed higher-timeframe result on historical chart bars and the still-forming result in real time.
Exit: long, within the enabled date range AND the alternate close moving average crosses below the alternate open moving average minus the multiplier times chart-timeframe ATR.
Exit: short, within the enabled date range AND the alternate close moving average crosses above the alternate open moving average plus the multiplier times chart-timeframe ATR.
Exit: long, trailing percentage > 0 AND low <= the long trailing stop calculated through the previous chart bar, while that stop order is active.
Exit: short, trailing percentage > 0 AND high >= the short trailing stop calculated through the previous chart bar, while that stop order is active.