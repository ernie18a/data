Calculation: Short line = shorter-lookback SMA of the higher-timeframe open from the last completed bar + half of a longer-lookback SMA of that open
Calculation: Middle line = medium-lookback SMA of the higher-timeframe open from the last completed bar + half of a longer-lookback SMA of that open
Calculation: Long line = longer-lookback SMA of the higher-timeframe open from the last completed bar + half of a still-longer-lookback SMA of that open
Long: Short line > Long line AND previous Short line <= previous Long line AND Short line > Middle line
Short: Short line < Long line AND previous Short line >= previous Long line AND Short line < Middle line
Exit: Long, high >= entry price + configured profit-target distance
Exit: Short, low <= entry price - configured profit-target distance