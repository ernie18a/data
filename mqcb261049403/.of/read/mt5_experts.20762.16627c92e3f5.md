Calculation: Moving average = configured moving average of the configured applied price, using the configured lookback, method, and shift on the current forming bar of a higher timeframe than the chart timeframe.
Long: At the start of a new higher-timeframe bar, current bar open > moving average + configured distance
Short: At the start of a new higher-timeframe bar, current bar open < moving average − configured distance
Exit: long, low <= entry price − configured stop-loss distance OR high >= entry price + configured take-profit distance
Exit: short, high >= entry price + configured stop-loss distance OR low <= entry price − configured take-profit distance