Calculation: Bollinger width percentile rank = percentile rank over its longer lookback of Bollinger Band width, where width = (upper band − lower band) / basis × 100, basis is a shorter-lookback SMA of close, and the bands are basis ± a standard-deviation multiple.
Calculation: Recent squeeze = Bollinger width percentile rank is below the configured threshold on at least one bar in the configured recent-bar window, including the current bar.
Calculation: Breakout level = highest high over the configured lookback, excluding the current bar.
Calculation: Long stop level = the higher of the entry price minus the initial-stop multiple times ATR on the entry bar, and the highest close since entry minus the trail multiple times current ATR.
Long: position is flat AND bar date is within the configured backtest window AND a recent squeeze occurred AND close > breakout level AND volume > its short-term average AND close > its long-term SMA
Exit: long, close < long stop level