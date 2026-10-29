Calculation: Rounded trend line = round the Jurik moving average of the Fast Adaptive Trend Line of a selected OHLC-derived price to the nearest configured price increment; use independently configurable inputs and smoothing parameters for long and short decisions.
Calculation: Direction = sign of the change in the rounded trend line from the preceding bar; if the change is zero, retain the preceding direction.
Long: Chart-timeframe direction > 0.
Short: Chart-timeframe direction < 0.
Long: On a new higher-timeframe bar, the long-system direction on the last completed higher-timeframe bar > 0 AND its direction on the preceding higher-timeframe bar <= 0.
Short: On a new higher-timeframe bar, the short-system direction on the last completed higher-timeframe bar < 0 AND its direction on the preceding higher-timeframe bar >= 0.
Exit: long, long-system direction on the last completed higher-timeframe bar < 0 OR low <= entry price minus the configured stop distance OR high >= entry price plus the configured profit distance.
Exit: short, short-system direction on the last completed higher-timeframe bar > 0 OR high >= entry price plus the configured stop distance OR low <= entry price minus the configured profit distance.