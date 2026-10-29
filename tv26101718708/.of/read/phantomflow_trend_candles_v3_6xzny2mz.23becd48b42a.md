Calculation: Fast and slow EMA = exponential moving averages of close, with the fast EMA using the shorter lookback
Calculation: ATR = average true range
Calculation: Confirmed swing high/low = pivot high/low confirmed after the configured number of bars to its right; track the latest and preceding confirmed swing highs and lows
Calculation: Bullish structure = latest swing high > preceding swing high AND latest swing low > preceding swing low
Calculation: Bearish structure = latest swing high < preceding swing high AND latest swing low < preceding swing low
Calculation: Bullish trend = (fast EMA > slow EMA AND both EMAs are rising OR close > latest swing high + ATR × structure-break buffer) AND (higher-timeframe fast EMA > higher-timeframe slow EMA when the higher-timeframe filter is enabled)
Calculation: Bearish trend = (fast EMA < slow EMA AND both EMAs are falling OR close < latest swing low − ATR × structure-break buffer) AND (higher-timeframe fast EMA < higher-timeframe slow EMA when the higher-timeframe filter is enabled)
Calculation: Higher-timeframe EMAs = fast and slow EMAs of close on a timeframe higher than the chart timeframe, using the last completed higher-timeframe bar
Calculation: Bullish value zone = price at or below the greater of the fast and slow EMAs plus ATR × pullback-zone size, and close at or above the slow EMA
Calculation: Bearish value zone = price at or above the lesser of the fast and slow EMAs minus ATR × pullback-zone size, and close at or below the slow EMA
Calculation: Bullish momentum = close > fast EMA AND close > prior bar high AND close > open AND (close − open) / max(high − low, minimum tick) ≥ minimum body fraction
Calculation: Bearish momentum = close < fast EMA AND close < prior bar low AND open > close AND (open − close) / max(high − low, minimum tick) ≥ minimum body fraction
Long: prior bar was in the bullish value zone AND current bar has bullish momentum AND session filter is disabled or current bar is in the configured session AND (first-entry-only is disabled or no long entry has occurred since the current bullish trend began)
Short: prior bar was in the bearish value zone AND current bar has bearish momentum AND session filter is disabled or current bar is in the configured session AND (first-entry-only is disabled or no short entry has occurred since the current bearish trend began)