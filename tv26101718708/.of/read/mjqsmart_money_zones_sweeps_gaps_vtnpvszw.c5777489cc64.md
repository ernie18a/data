Calculation: ATR = average true range over a configurable lookback.
Calculation: Confirmed swing high/low = a bar whose high/low is respectively greater/lower than the highs/lows of the configured number of bars on both sides; confirmed after the right-side bars complete. Chart, sweep, and higher-timeframe structure pivots use independently configured lookbacks.
Calculation: Bullish/bearish engulfing = a bullish/bearish candle whose close is at or beyond the previous candle's open, after the previous candle closed bearish/bullish.
Calculation: Bullish/bearish pin bar = lower/upper wick at least the configured multiple of the candle body; use one minimum tick as body when body is zero.
Calculation: Higher-timeframe bias = bullish when the higher-timeframe close crosses above its latest confirmed swing high, bearish when it crosses below its latest confirmed swing low; until a break sets bias, initialize bullish if the latest two confirmed swing highs and lows are both rising, or bearish if both are falling; otherwise retain the current bias. Uses the selected higher-timeframe bar, which may still be forming.
Calculation: Base = the candle immediately before a departure plus up to the configured maximum number of consecutive earlier candles whose ranges are no greater than the configured base-range multiple of ATR; the anchor candle must also be no greater than the configured anchor-size multiple of ATR. The departure candle must have range at least the configured impulse multiple of ATR.
Calculation: Demand zone = base high to the lower of base low and bullish departure low; supply zone = the higher of base high and bearish departure high to base low. If enabled, cap zone width at the configured ATR multiple while retaining the proximal edge. Ignore a new zone that overlaps an existing zone on the same side. Zones are detected on the chart timeframe and selected higher timeframes; higher-timeframe requests use lookahead off and may reflect a still-forming bar.
Long: Current low < latest confirmed chart-timeframe swing low AND current close > that swing low AND swing-low minus current low >= configured minimum ATR multiple AND (bullish pin bar OR bullish engulfing) AND (alignment filter disabled OR higher-timeframe bias is bullish).
Short: Current high > latest confirmed chart-timeframe swing high AND current close < that swing high AND current high minus swing high >= configured minimum ATR multiple AND (bearish pin bar OR bearish engulfing) AND (alignment filter disabled OR higher-timeframe bias is bearish).
Long: Current close crosses above the latest confirmed chart-timeframe swing high.
Short: Current close crosses below the latest confirmed chart-timeframe swing low.
Long: Higher-timeframe close crosses above its latest confirmed swing high.
Short: Higher-timeframe close crosses below its latest confirmed swing low.
Long: Current low > high two chart-timeframe bars earlier AND (alignment filter disabled OR higher-timeframe bias is not bearish).
Short: Current high < low two chart-timeframe bars earlier AND (alignment filter disabled OR higher-timeframe bias is not bullish).
Long: Bullish departure candle has range at least the configured impulse multiple of ATR, closes above its open, and its high exceeds the base high.
Short: Bearish departure candle has range at least the configured impulse multiple of ATR, closes below its open, and its low is below the base low.
Long: Chart-timeframe open > previous chart-timeframe high.
Short: Chart-timeframe open < previous chart-timeframe low.
Long: Higher-timeframe open > previous higher-timeframe high.
Short: Higher-timeframe open < previous higher-timeframe low.
Exit: