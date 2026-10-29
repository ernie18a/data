Calculation: Composite momentum = mean of RSI on close changes and MFI on hlc3, using the same lookback length
Calculation: Selected weighted average = apply the selected SMA, EMA, or WMA separately to higher-timeframe close × chart-bar volume and chart-bar volume, then divide the former by the latter; higher-timeframe close uses the latest available higher-timeframe bar
Long: Previous composite momentum < positive threshold AND current composite momentum > positive threshold AND current composite momentum > negative threshold AND current 5-bar EMA change > 0 AND previous bar had negative momentum
Short: Current composite momentum < negative threshold AND current 5-bar EMA change < 0 AND previous bar had positive momentum
Exit: Long, short condition OR low <= selected weighted average
Exit: Short, long condition OR high >= selected weighted average + 2 × factor × higher-timeframe ATR