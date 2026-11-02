Calculation: Normalized Williams %R = 100 + Williams %R.
Calculation: Selected oscillator = normalized Williams %R using a shorter lookback if, for any bar in a recent lookback including the current bar, the absolute difference between its close and the close a fixed number of bars earlier is at least a threshold multiple of the current bar's average high-low range over a separate lookback; otherwise use normalized Williams %R with a longer lookback.
Calculation: Previous extreme = the first normalized Williams %R value before the current bar, calculated with the current bar's selected oscillator lookback, that is outside the inclusive lower-to-upper threshold band.
Calculation: Trend = initially neutral; set to long when the selected oscillator is above the upper threshold and the previous extreme is below the lower threshold; set to short when the selected oscillator is below the lower threshold and the previous extreme is above the upper threshold; otherwise retain the previous trend. The lower and upper thresholds are symmetric around the oscillator midpoint.
Long: Trend is long.
Short: Trend is short.
Long: The selected oscillator is above the upper threshold AND the previous extreme is below the lower threshold.
Short: The selected oscillator is below the lower threshold AND the previous extreme is above the upper threshold.
Long: On the first chart bar of a higher-timeframe bar, the same trend calculated on the still-forming higher-timeframe bar is long, OR the most recently sampled higher-timeframe trend is long.
Short: On the first chart bar of a higher-timeframe bar, the same trend calculated on the still-forming higher-timeframe bar is short, OR the most recently sampled higher-timeframe trend is short.
Long: The current chart bar is the first chart bar of a higher-timeframe bar AND the still-forming higher-timeframe bar's selected oscillator is above the upper threshold AND its previous extreme is below the lower threshold.
Short: The current chart bar is the first chart bar of a higher-timeframe bar AND the still-forming higher-timeframe bar's selected oscillator is below the lower threshold AND its previous extreme is above the upper threshold.