Long: high[1] > high[2] AND high[2] > high[3] AND high[3] > high[4] AND open[1] > open[2] AND open[2] > open[3] AND open[3] > open[4]
Short: high[1] < high[2] AND high[2] < high[3] AND high[3] < high[4] AND open[1] < open[2] AND open[2] < open[3] AND open[3] < open[4]
Exit: long, current price - entry price > trailing distance AND (partial closing is enabled OR current price <= highest prior price since entry)
Exit: short, entry price - current price > trailing distance AND current price < lowest prior price since entry