Calculation: Smoothed open and smoothed close = apply the same selected moving-average method and parameters separately to open and close. For the trading system, calculate them on a configurable higher or lower timeframe, using either its still-forming bar or a completed bar at a configurable lag; previous means the immediately preceding bar of that timeframe.
Long: Chart-timeframe smoothed close > chart-timeframe smoothed open
Short: Chart-timeframe smoothed close <= chart-timeframe smoothed open
Long: Selected-timeframe smoothed close > smoothed open AND previous smoothed close <= previous smoothed open
Short: Selected-timeframe smoothed close <= smoothed open AND previous smoothed close > previous smoothed open
Exit: long, selected-timeframe smoothed close <= smoothed open OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, selected-timeframe smoothed close > smoothed open OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance