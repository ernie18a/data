Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Relative volume = current volume / simple moving average of volume over a lookback
Calculation: Long swing stop = lowest low over a lookback ending on the entry bar − ATR × buffer
Calculation: Short swing stop = highest high over a lookback ending on the entry bar + ATR × buffer
Calculation: Long risk = max(entry price − selected initial stop, minimum price increment)
Calculation: Short risk = max(selected initial stop − entry price, minimum price increment)
Calculation: Long target = entry price + long risk × target multiple
Calculation: Short target = entry price − short risk × target multiple
Calculation: Long active stop = swing stop or current VWAP, as selected; after the first target is reached, if trailing is enabled, max(entry price, fast EMA, long active stop)
Calculation: Short active stop = swing stop or current VWAP, as selected; after the first target is reached, if trailing is enabled, min(entry price, fast EMA, short active stop)
Long: within the configured session AND long entries enabled AND flat AND cooldown elapsed AND bias-timeframe close > bias-timeframe VWAP AND bias-timeframe fast EMA > bias-timeframe slow EMA AND (HTF EMA filter disabled OR HTF close > HTF long-period EMA) AND (entry-timeframe VWAP filter disabled OR close > entry-timeframe VWAP) AND (relative-volume filter disabled OR relative volume ≥ threshold) AND low ≤ selected pullback EMA (slow EMA if selected, otherwise fast EMA) AND close > fast EMA AND previous close ≤ current fast EMA
Short: within the configured session AND short entries enabled AND flat AND cooldown elapsed AND bias-timeframe close < bias-timeframe VWAP AND bias-timeframe fast EMA < bias-timeframe slow EMA AND (HTF EMA filter disabled OR HTF close < HTF long-period EMA) AND (entry-timeframe VWAP filter disabled OR close < entry-timeframe VWAP) AND (relative-volume filter disabled OR relative volume ≥ threshold) AND high ≥ selected pullback EMA (slow EMA if selected, otherwise fast EMA) AND close < fast EMA AND previous close ≥ current fast EMA
Exit: long, low ≤ long active stop OR high ≥ long target OR (time stop enabled AND bars in position ≥ time-stop length AND first target not reached AND close ≤ entry price)
Exit: short, high ≥ short active stop OR low ≤ short target OR (time stop enabled AND bars in position ≥ time-stop length AND first target not reached AND close ≥ entry price)
Bias-timeframe and optional HTF calculations use the last completed bar in a backtest; entry calculations use the current chart bar. Fast EMA lookback is shorter than slow EMA lookback.