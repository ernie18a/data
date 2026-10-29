Calculation: Upper EMA cloud = EMA(close, lookback) + standard deviation of close over the same lookback divided by 4
Calculation: Red-vector count = count of PVSRA red-vector bars whose close is below the EMA, accumulated since the last long signal
Calculation: Green-vector count = count of PVSRA green-vector bars whose open and close are above the EMA, accumulated since the last sell signal
Long: On a completed bar, a PVSRA green-vector bar has open above the EMA and close above the upper EMA cloud, a prior PVSRA red-vector bar had open and close below the EMA, and the red-vector count meets or exceeds the long-signal accuracy threshold
Short: On a completed bar, the previous bar was a PVSRA green-vector bar and the current bar is a PVSRA red or violet vector, the current bar has open above the EMA and close above the upper EMA cloud, a prior PVSRA green-vector bar had open and close above the EMA, and the green-vector count meets or exceeds the sell-signal accuracy threshold
Exit: long, the Short condition
Exit: short, the Long condition