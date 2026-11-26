Calculation: Regime = bullish when ADX(ADX lookback) >= trend-strength threshold and EMA(close, fast lookback) > EMA(close, slow lookback); bearish when ADX(ADX lookback) >= trend-strength threshold and EMA(close, fast lookback) < EMA(close, slow lookback); otherwise neutral
Calculation: Trap pressure = on each confirmed chart bar, accumulate volume by price bin for completed T1 bars within that chart bar (or chart bars when the source timeframe is the chart timeframe), using the configured session and timezone and resetting at session start; assign each source bar's volume to buy volume = volume * (close - low) / (high - low) when high > low, otherwise volume / 2, and sell volume = volume - buy volume, at the nearest price bin to (high + low + close) / 3; on chart bars, using the current chart close, bull pain = sum of buy volume * (bin price - close) for bins above close, bear pain = sum of sell volume * (close - bin price) for bins below close, and pressure = 100 * (bull pain - bear pain) / (bull pain + bear pain), or 0 when the denominator is 0; comparisons run on chart bars using the accumulated T1 data
Long: Regime is bullish
Short: Regime is bearish
Long: Regime is bullish AND Regime[1] is not bullish
Short: Regime is bearish AND Regime[1] is not bearish
Long: Regime is bullish AND ADX(ADX lookback) >= trend-strength threshold + 2 * ADX tier increment AND NOT (Regime[1] is bullish AND ADX(ADX lookback)[1] >= trend-strength threshold + 2 * ADX tier increment)
Short: Regime is bearish AND ADX(ADX lookback) >= trend-strength threshold + 2 * ADX tier increment AND NOT (Regime[1] is bearish AND ADX(ADX lookback)[1] >= trend-strength threshold + 2 * ADX tier increment)
Long: Trap pressure < -pressure arrow threshold
Short: Trap pressure > pressure arrow threshold
Long: during the configured session, Trap pressure <= -trap pressure threshold AND Trap pressure[1] > -trap pressure threshold
Short: during the configured session, Trap pressure >= trap pressure threshold AND Trap pressure[1] < trap pressure threshold