Calculation: Prior high = highest high over the lookback bars before the current bar
Calculation: Prior low = lowest low over the lookback bars before the current bar
Calculation: Higher-timeframe close = close of a bar on a timeframe higher than the chart timeframe, using the bar still forming
Calculation: Higher-timeframe EMA = EMA of close on that higher timeframe, using the bar still forming
Calculation: Swing-timeframe close = close of a bar on a timeframe higher than the chart timeframe, using the bar still forming
Calculation: Swing-timeframe EMA = EMA of close on that higher timeframe, using the bar still forming
Long: (scalp mode enabled AND close > prior high AND fast EMA > slow EMA AND higher-timeframe close > higher-timeframe EMA) OR (swing mode enabled AND close > prior high AND swing-timeframe close > swing-timeframe EMA) OR (counter-trend mode enabled AND close < fast EMA − ATR × an overextension multiple AND close > prior high)
Short: (scalp mode enabled AND close < prior low AND fast EMA < slow EMA AND higher-timeframe close < higher-timeframe EMA) OR (swing mode enabled AND close < prior low AND swing-timeframe close < swing-timeframe EMA) OR (counter-trend mode enabled AND close > fast EMA + ATR × an overextension multiple AND close < prior low)