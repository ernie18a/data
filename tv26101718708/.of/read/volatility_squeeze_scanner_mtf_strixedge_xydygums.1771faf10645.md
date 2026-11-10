Calculation: Momentum = linear regression endpoint of source minus the average of the Donchian channel midpoint and SMA of source, using the Keltner channel lookback for the Donchian channel, SMA, and regression; source is a selectable OHLC price or OHLC average.
Long: Chart-timeframe momentum >= 0.
Short: Chart-timeframe momentum < 0.
Long: Momentum > 0 on any configured timeframe.
Short: Momentum <= 0 on any configured timeframe.
Long: More than half of the configured timeframes have momentum > 0.
Short: Fewer than half of the configured timeframes have momentum > 0.
Calculation: Configured-timeframe momentum = momentum calculated independently on each configured timeframe, which may be higher than, lower than, or equal to the chart timeframe; use the last completed bar for a higher timeframe, the last available intrabar for a lower timeframe, and the current bar for the chart timeframe. A higher-timeframe bar still forming is used in real time.