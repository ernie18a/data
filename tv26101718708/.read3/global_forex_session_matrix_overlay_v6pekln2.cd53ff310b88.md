Long: Confirmed Pivot Low(low, longer pivot lookback, longer pivot lookback)
Short: Confirmed Pivot High(high, longer pivot lookback, longer pivot lookback)
Long: Temporary Pivot Low(low, shorter pivot lookback, shorter pivot lookback) < previous temporary Pivot Low
Short: Temporary Pivot High(high, shorter pivot lookback, shorter pivot lookback) > previous temporary Pivot High
Long: close > the latest confirmed Pivot High(high, longer pivot lookback, longer pivot lookback), if that pivot has not previously been broken
Short: close < the latest confirmed Pivot Low(low, longer pivot lookback, longer pivot lookback), if that pivot has not previously been broken
Long: MA(source 1, shorter lookback, method 1) crosses above MA(source 2, longer lookback, method 2)
Short: MA(source 1, shorter lookback, method 1) crosses below MA(source 2, longer lookback, method 2)
Long: close crosses above MA(source 2, longer lookback, method 2)
Short: close crosses below MA(source 2, longer lookback, method 2)
Long: MA(source 1, shorter lookback, method 1) > MA(source 2, longer lookback, method 2)
Short: MA(source 1, shorter lookback, method 1) < MA(source 2, longer lookback, method 2)
Long: close >= current, still-forming T1 open sampled on chart bars at T1 changes AND MA(source 1, shorter lookback, method 1) > MA(source 2, longer lookback, method 2)
Short: close < current, still-forming T1 open sampled on chart bars at T1 changes AND MA(source 1, shorter lookback, method 1) < MA(source 2, longer lookback, method 2)
Long: volume >= high-volume threshold × SMA(volume, volume lookback) AND close >= open
Short: volume >= high-volume threshold × SMA(volume, volume lookback) AND close < open
Long: close > open
Short: close <= open
Long: enhanced candle coloring selects volume mode AND abs(close - open) > micro-body threshold AND volume >= high-volume threshold × SMA(volume, volume lookback) AND close > open
Short: enhanced candle coloring selects volume mode AND abs(close - open) > micro-body threshold AND volume >= high-volume threshold × SMA(volume, volume lookback) AND close <= open
Long: enhanced candle coloring selects trend mode AND (MA(source 1, shorter lookback, method 1) >= MA(source 2, longer lookback, method 2) OR moving averages unavailable AND close >= open)
Short: enhanced candle coloring selects trend mode AND (MA(source 1, shorter lookback, method 1) < MA(source 2, longer lookback, method 2) OR moving averages unavailable AND close < open)
Long: enhanced candle coloring selects volume-and-trend mode AND abs(close - open) > micro-body threshold AND close >= open
Short: enhanced candle coloring selects volume-and-trend mode AND abs(close - open) > micro-body threshold AND close < open
Long: enhanced candle coloring is disabled AND (volume >= high-volume threshold × SMA(volume, volume lookback) OR volume <= low-volume threshold × SMA(volume, volume lookback)) AND open < close
Short: enhanced candle coloring is disabled AND (volume >= high-volume threshold × SMA(volume, volume lookback) OR volume <= low-volume threshold × SMA(volume, volume lookback)) AND open >= close