Calculation: Histogram = a configurable moving average of (selected OHLC-derived price minus a separate configurable moving average of that price); calculate on a configurable timeframe that may be higher or lower than the chart timeframe, using the last completed bar or, if configured, the still-forming bar. Index 0 is the selected bar and larger indices are earlier bars.
Long: Histogram[0] > Histogram[1] AND Histogram[2] > Histogram[1]
Short: Histogram[0] < Histogram[1] AND Histogram[2] < Histogram[1]
Exit: long, Histogram[0] < Histogram[1] OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, Histogram[0] > Histogram[1] OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance