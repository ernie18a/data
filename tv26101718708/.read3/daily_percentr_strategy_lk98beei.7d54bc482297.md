Long: Williams %R(source, lookback) > lower threshold AND Williams %R(source, lookback) < upper threshold, at the open
Long: (Williams %R(source, lookback) < low marker OR Williams %R(source, lookback)[1] < low marker) AND (low-high-low filter disabled OR (low > LOWEST(low, lookback)[1] AND low < close - filter tick-offset parameter)) AND datetime > cutoff date parameter AND (long-lookback SMA filter disabled OR high > SMA(close, longer lookback)) AND (short-lookback SMA bypass enabled OR high > SMA(close, shorter lookback))
Exit: long, datetime reaches the trading-day close
Exit: long, two-bar mode disabled AND low <= low[1]
Exit: long, two-bar mode enabled AND low <= low[1] - stop tick-distance parameter
Exit: long, two-bar mode enabled AND (open > high[1] OR (open <= close[1] AND close >= open[1] AND close[1] > open[1]) OR (open > close[1] AND close < open[1] AND close[1] <= open[1])