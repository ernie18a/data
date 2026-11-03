Calculation: Structural center = EMA of the average of the latest confirmed pivot high and pivot low; until each exists, substitute the current high or low respectively. A pivot is confirmed after the same number of bars on each side.
Calculation: Upper and lower rails = separate EMAs of the structural center plus and minus ATR multiplied by a band-width parameter, using the same rail-smoothing period.
Calculation: Higher-timeframe bullish bias = last completed higher-timeframe close > its shorter-period EMA AND shorter-period EMA > longer-period EMA. Higher-timeframe bearish bias = last completed higher-timeframe close < its shorter-period EMA AND shorter-period EMA < longer-period EMA.
Calculation: Regime = initially bullish if close >= structural center, otherwise bearish; thereafter change to bullish when close crosses above the upper rail AND the optional higher-timeframe filter is disabled OR the bullish bias is true; change to bearish when close crosses below the lower rail AND the optional higher-timeframe filter is disabled OR the bearish bias is true. Retain the previous regime otherwise. Apply each OR within its respective filter condition.
Long: Regime is bullish.
Short: Regime is bearish.
Long: Close crosses above the structural center.
Short: Close crosses below the structural center.
Long: Higher-timeframe bullish bias is true.
Short: Higher-timeframe bearish bias is true.
Long: A pivot low is confirmed.
Short: A pivot high is confirmed.
Long: Regime is bullish AND volume / EMA of volume >= volume threshold.
Short: Regime is bearish AND volume / EMA of volume >= volume threshold.
Long: Regime is bullish AND close > structural center + ATR multiplied by the projection-width parameter.
Short: Regime is bearish AND close < structural center - ATR multiplied by the projection-width parameter.
Long: Regime has remained bullish for at least the confirmation number of bars.
Short: Regime has remained bearish for at least the confirmation number of bars.