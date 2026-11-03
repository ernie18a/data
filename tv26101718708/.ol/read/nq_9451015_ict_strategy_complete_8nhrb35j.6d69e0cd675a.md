Calculation: Daily EMA = EMA of daily closes; use the higher-timeframe daily bar still forming.
Calculation: Previous-day high/low and close = high, low, and close of the last completed higher-timeframe daily bar.
Calculation: Swing high/low = chart-timeframe fractal pivot whose high/low is more extreme than the configured number of neighboring bars on each side; use only after right-side bars complete.
Calculation: Bullish/bearish MSS = close crosses above the latest swing high / below the latest swing low; retain the latest direction until an opposite MSS or a new day.
Calculation: Bullish/bearish order block = refined range of the most recent bearish/bullish candle within the configured lookback before a bullish/bearish MSS; refinement may use the full candle range or an ATR-based defensive range, according to the configured mode.
Calculation: Bullish/bearish sweep = low below previous-day low and close above it / high above previous-day high and close below it; retain each sweep through the day.
Long: Close crosses above the latest swing high AND close > daily EMA (or previous-day close > daily EMA, according to the configured bias mode)
Short: Close crosses below the latest swing low AND close <= daily EMA (or previous-day close <= daily EMA, according to the configured bias mode)
Long: Bullish MSS occurs AND bullish bias
Short: Bearish MSS occurs AND bearish bias
Long: Bullish MSS is active AND bullish bias AND a bullish sweep has occurred today AND price is within the configured entry window AND a bullish order block exists AND low <= order-block high AND close >= order-block low AND no trade has been taken today AND position is flat
Short: Bearish MSS is active AND bearish bias AND a bearish sweep has occurred today AND price is within the configured entry window AND a bearish order block exists AND high >= order-block low AND close <= order-block high AND no trade has been taken today AND position is flat
Exit: long, low <= bullish order-block low at entry OR high >= entry price + (entry price - bullish order-block low at entry) × configured risk/reward
Exit: short, high >= bearish order-block high at entry OR low <= entry price - (bearish order-block high at entry - entry price) × configured risk/reward