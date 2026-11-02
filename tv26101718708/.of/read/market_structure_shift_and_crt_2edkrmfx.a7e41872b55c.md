Calculation: Structure pivots = confirmed pivot highs and lows of either candle body tops and bottoms or highs and lows, respectively, using independent left and right lookbacks. Calculate separately on the chart timeframe or a higher timeframe; for a higher timeframe use the last completed bar and process a newly confirmed pivot at the start of the next higher-timeframe bar.
Calculation: Structure bias = initially neutral; set bullish when the selected break source exceeds the latest confirmed pivot high and bearish when it falls below the latest confirmed pivot low. Each pivot can be broken only once, and a new pivot replaces the previous level. Evaluate each structure timeframe independently. The break source is either chart-bar close or high/low, or the last completed structure-timeframe bar's close or high/low. If both levels break on one chart bar, process the high first and the low second.
Calculation: Sweep = for each higher sweep timeframe, compare either its still-forming bar on every chart bar or its last completed bar at the start of a new higher-timeframe bar with each earlier bar retained in a rolling window that includes the forming bar. A prior bar's high and low can each be swept only once while that bar remains in the window. A swept high remains active until chart-bar min(open, close) > its level; a swept low remains active until chart-bar max(open, close) < its level.
Long: A newly confirmed structure pivot high > the preceding confirmed pivot high OR a newly confirmed structure pivot low >= the preceding confirmed pivot low.
Short: A newly confirmed structure pivot high <= the preceding confirmed pivot high OR a newly confirmed structure pivot low < the preceding confirmed pivot low.
Long: The selected break source > the latest unbroken confirmed structure pivot high.
Short: The selected break source < the latest unbroken confirmed structure pivot low.
Long: Structure bias of both timeframes is bullish.
Short: Structure bias of both timeframes is bearish.
Long: A higher-timeframe sweep bar's low < an unswept prior low AND min(sweep bar open, sweep bar close) > that prior low.
Short: A higher-timeframe sweep bar's high > an unswept prior high AND max(sweep bar open, sweep bar close) < that prior high.
Long: The number of active swept lows > 0.
Short: The number of active swept highs > 0.