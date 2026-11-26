Calculation: Directional breakout probability at each SuperTrend flip = append the current relative volume (volume / SMA(volume, relative-volume lookback)) to the flipped side’s sample list and retain its latest sample-cap values; for each side, calculate density as sum(exp(-0.5 × ((current relative volume − sample) / bandwidth)^2)) / (sample count × bandwidth × sqrt(2π)), update that side’s running maximum density across all flips, and set its probability to 100 × density / running maximum density (or zero when the maximum is zero)
Long: SuperTrend(ATR multiplier, ATR lookback) is bullish
Short: SuperTrend(ATR multiplier, ATR lookback) is bearish
Long: SuperTrend direction changes from bearish to bullish
Short: SuperTrend direction changes from bullish to bearish
Long: SuperTrend direction changes from bearish to bullish AND directional breakout probability >= probability threshold
Short: SuperTrend direction changes from bullish to bearish AND directional breakout probability >= probability threshold
Long: In single-HMA mode, HMA(source, single-mode lookback) >= HMA(source, single-mode lookback)[1]
Short: In single-HMA mode, HMA(source, single-mode lookback) < HMA(source, single-mode lookback)[1]
Long: In three-HMA mode, HMA(source, fast lookback) > HMA(source, medium lookback) > HMA(source, slow lookback), where fast lookback < medium lookback < slow lookback
Short: In three-HMA mode, HMA(source, slow lookback) > HMA(source, medium lookback) > HMA(source, fast lookback), where fast lookback < medium lookback < slow lookback
Long: Linear Regression(source, lookback, current-bar endpoint) >= Linear Regression(source, lookback, current-bar endpoint)[1]
Short: Linear Regression(source, lookback, current-bar endpoint) < Linear Regression(source, lookback, current-bar endpoint)[1]
Long: Close crosses above Linear Regression(source, lookback, current-bar endpoint)
Short: Close crosses below Linear Regression(source, lookback, current-bar endpoint)
Long: EMA(source, lookback) crosses above Linear Regression(source, lookback, current-bar endpoint)
Short: EMA(source, lookback) crosses below Linear Regression(source, lookback, current-bar endpoint)