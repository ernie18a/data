Calculation: Smoothed close = the selected moving average of close, using the same method and parameters as the smoothed open.
Calculation: Smoothed candle open = the previous bar's smoothed close when the absolute difference between the current raw open and close is at most the gap threshold; otherwise, the selected moving average of open.
Calculation: Evaluation bars = chart-timeframe bars or higher-timeframe bars. For the higher-timeframe version, the value is copied at the first chart bar of each higher-timeframe bar and carried forward until the next one. In historical calculation it uses that higher-timeframe bar's final value; in live calculation it uses the bar still forming when copied.
Long: Smoothed close > smoothed candle open.
Short: Smoothed close < smoothed candle open.