Calculation: Selected moving average = a moving average of close using the selected method (SMA, EMA, WMA, Hull, VWMA, RMA, or TEMA)
Long: selected moving average >= the same moving average `smoothe` bars earlier
Short: selected moving average < the same moving average `smoothe` bars earlier
Exit: Long, selected moving average < the same moving average `smoothe` bars earlier OR trailing stop is active and low <= the highest high since activation minus the trailing offset
Exit: Short, selected moving average >= the same moving average `smoothe` bars earlier OR trailing stop is active and high >= the lowest low since activation plus the trailing offset