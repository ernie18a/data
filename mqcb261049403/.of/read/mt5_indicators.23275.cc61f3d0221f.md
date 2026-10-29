Calculation: Applied price = the configured price derived from each bar’s OHLC fields.
Calculation: Smoothed price, high, and low = each respective series smoothed with the same method and lookback on the indicator timeframe.
Calculation: Raw lower level = (3 × pivot − maximum smoothed high over the extrema lookback) / 2; raw upper level = (3 × pivot − minimum smoothed low over that same lookback) / 2; pivot = (maximum smoothed high + minimum smoothed low + smoothed price) / 3.
Calculation: Lower threshold = the maximum raw lower level over the current and previous 13 indicator-timeframe bars. Upper threshold = the minimum raw upper level over the current and previous 13 indicator-timeframe bars. In the higher-timeframe wrapper, use the still-forming higher-timeframe bar; otherwise use chart-timeframe bars.
Long: Applied price > lower threshold AND applied price >= upper threshold
Short: Applied price < upper threshold