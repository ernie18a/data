Calculation: Range in points = (highest(high[1], range lookback) - lowest(low[1], range lookback)) / point size
Long: Range in points <= maximum range in points AND current bid >= highest(high[1], range lookback) AND no open long or short positions
Short: Range in points <= maximum range in points AND current bid < lowest(low[1], range lookback) AND no open long or short positions
Exit: long, position profit <= -stop-loss amount OR position profit >= take-profit amount
Exit: short, position profit <= -stop-loss amount OR position profit >= take-profit amount