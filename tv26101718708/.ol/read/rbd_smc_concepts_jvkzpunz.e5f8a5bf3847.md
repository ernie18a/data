Calculation: Confirmed swing high/low = a bar whose high/low is higher/lower than the configured number of bars on each side; use the most recently confirmed level.
Calculation: Higher-timeframe bias = Bullish when the latest confirmed swing high and low are both higher than their respective preceding swings; Bearish when both are lower; otherwise Neutral. Use completed bars from a timeframe higher than the chart timeframe.
Calculation: ATR = average true range over a configurable lookback.
Long: Higher-timeframe bias is Bullish
Long: Close crosses above the latest confirmed chart-timeframe swing high
Long: Low is below the latest confirmed chart-timeframe swing low AND close is above that swing low AND penetration is at least a configurable multiple of ATR AND (lower wick is at least a configurable multiple of the body OR the current bullish body engulfs the prior bearish body) AND (alignment filtering is disabled OR higher-timeframe bias is Bullish)
Long: Current low > high from two chart-timeframe bars earlier AND (alignment filtering is disabled OR higher-timeframe bias is not Bearish)
Long: Close crosses above the latest confirmed chart-timeframe swing high AND a down candle occurs within the prior 30 bars
Long: Previous bar range ≤ a configurable multiple of ATR AND current candle is bullish with body ≥ a configurable multiple of ATR
Long: Close is above the top of a bearish order-block zone
Short: Higher-timeframe bias is Bearish
Short: Close crosses below the latest confirmed chart-timeframe swing low
Short: High is above the latest confirmed chart-timeframe swing high AND close is below that swing high AND penetration is at least a configurable multiple of ATR AND (upper wick is at least a configurable multiple of the body OR the current bearish body engulfs the prior bullish body) AND (alignment filtering is disabled OR higher-timeframe bias is Bearish)
Short: Current high < low from two chart-timeframe bars earlier AND (alignment filtering is disabled OR higher-timeframe bias is not Bullish)
Short: Close crosses below the latest confirmed chart-timeframe swing low AND an up candle occurs within the prior 30 bars
Short: Previous bar range ≤ a configurable multiple of ATR AND current candle is bearish with body ≥ a configurable multiple of ATR
Short: Close is below the bottom of a bullish order-block zone
Exit: