Calculation: Higher-timeframe EMA = exponential moving average of higher-timeframe closes, using the last completed higher-timeframe bar
Calculation: Entry EMA = exponential moving average of closes from a timeframe higher than the chart timeframe, using its last completed bar
Long: Flat AND within the configured trading session AND outside the enabled news lockout AND higher-timeframe close > higher-timeframe EMA AND previous close <= previous entry EMA AND close > entry EMA
Short: Flat AND within the configured trading session AND outside the enabled news lockout AND higher-timeframe close < higher-timeframe EMA AND previous close >= previous entry EMA AND close < entry EMA
Exit: Long, previous close >= previous chart-timeframe EMA AND close < chart-timeframe EMA
Exit: Short, previous close <= previous chart-timeframe EMA AND close > chart-timeframe EMA