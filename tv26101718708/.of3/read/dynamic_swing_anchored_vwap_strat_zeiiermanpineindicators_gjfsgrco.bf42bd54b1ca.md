Calculation: latest swing high bar index = current bar index when highestbars(high, lookback) = 0, otherwise its previous value; initially the current bar index
Calculation: latest swing low bar index = current bar index when lowestbars(low, lookback) = 0, otherwise its previous value; initially the current bar index
Long: latest swing high bar index > latest swing low bar index
Exit: long, latest swing high bar index <= latest swing low bar index