Calculation: Range high = highest high over the range lookback
Calculation: Range low = lowest low over the range lookback
Calculation: Grid level = range low + (range high − range low) × level index / number of grid intervals
Calculation: Range midpoint = (range high + range low) / 2
Calculation: Volume average = simple moving average of volume
Calculation: First target = grid level one level above the entry level
Calculation: Main target = the lower of the grid level tpLevels above the entry level (clamped to the highest grid level) and the global target above range high
Long: previous close > grid level AND current close <= grid level AND grid level <= range midpoint AND current volume > volume average
Exit: long, current high >= first target
Exit: long, current high >= main target
Exit: long, current low < range low × (1 − stop percentage)
Exit: long, current high > range high × (1 + global take-profit percentage)