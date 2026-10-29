Calculation: Double-weighted average = a linearly weighted moving average of a selected OHLC-derived price, followed by another linearly weighted moving average with the same lookback.
Calculation: Smoothed candle = apply a selected moving average to open and close separately, then apply a second selected moving average to each result. If the absolute difference between the raw open and raw close is at most a gap threshold, replace the smoothed open with the previous bar's smoothed close.
Long: Double-weighted average > its previous-bar value.
Short: Double-weighted average < its previous-bar value.
Long: Smoothed candle close > smoothed candle open.
Short: Smoothed candle close < smoothed candle open.
Long: On the last completed higher-timeframe bar, double-weighted average > its previous-bar value AND on the preceding higher-timeframe bar, double-weighted average <= its previous-bar value.
Short: On the last completed higher-timeframe bar, double-weighted average < its previous-bar value AND on the preceding higher-timeframe bar, double-weighted average >= its previous-bar value.
Long: On the last completed higher-timeframe bar, smoothed candle close > smoothed candle open AND on the preceding higher-timeframe bar, smoothed candle close <= smoothed candle open.
Short: On the last completed higher-timeframe bar, smoothed candle close < smoothed candle open AND on the preceding higher-timeframe bar, smoothed candle close >= smoothed candle open.
Exit: long, on the last completed higher-timeframe bar, double-weighted average < its previous-bar value OR smoothed candle close < smoothed candle open.
Exit: short, on the last completed higher-timeframe bar, double-weighted average > its previous-bar value OR smoothed candle close > smoothed candle open.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.