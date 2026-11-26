Calculation: Last Pivot Low = most recent confirmed Pivot Low(low, left lookback, right lookback)
Long: Last Pivot Low > Last Pivot Low[1] AND close > Last Pivot Low
Long: EMA(close, EMA lookback) crosses above Kernel Regression(close, kernel lookback)
Short: EMA(close, EMA lookback) crosses below Kernel Regression(close, kernel lookback)
Long: Heikin-Ashi close crosses above max(EMA(close, EMA lookback), Kernel Regression(close, kernel lookback)) AND Heikin-Ashi close > Heikin-Ashi open AND bar is closed
Long: TD Buy Setup count(close, setup lag) equals setup count
Short: TD Sell Setup count(close, setup lag) equals setup count
Long: close crosses above the most recent Pivot High(high, swing lookback, swing lookback) for the first time after that pivot is confirmed AND (FVG requirement off OR low[k] > high[k+2] for some k from 0 to FVG lookback)
Short: close crosses below the most recent Pivot Low(low, swing lookback, swing lookback) for the first time after that pivot is confirmed AND (FVG requirement off OR high[k] < low[k+2] for some k from 0 to FVG lookback)