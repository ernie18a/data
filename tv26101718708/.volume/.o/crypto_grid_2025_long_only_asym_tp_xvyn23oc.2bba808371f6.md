Calculation: Range high = highest high over the rolling range lookback, including the current bar
Calculation: Range low = lowest low over the rolling range lookback, including the current bar
Calculation: Grid step = (range high − range low) / number of grid intervals
Calculation: Grid level i = range low + i × grid step, for i from 0 through the number of grid intervals
Calculation: Range midpoint = (range high + range low) / 2
Calculation: Main target for an entry at grid level i = the lower of grid level min(i + target-level offset, highest grid index) and range high × (1 + global take-profit percentage)
Long: Previous close > grid level i AND current close <= grid level i AND range high > range low AND (lower-half restriction is disabled OR grid level i <= range midpoint) AND (volume filter is disabled OR current volume > its moving average)
Exit: Long, current high >= the grid level immediately above the entry level
Exit: Long, current high >= main target for the entry level
Exit: Long, current low < range low × (1 − global stop percentage)
Exit: Long, current high > range high × (1 + global take-profit percentage)