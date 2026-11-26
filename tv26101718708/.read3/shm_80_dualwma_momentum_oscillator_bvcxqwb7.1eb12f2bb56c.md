Calculation: Oscillator = 100 * (WMA(price source, shorter lookback) - WMA(price source, longer lookback)) / WMA(price source, longer lookback); calculate on T1 bars using the bar still forming and project values onto chart bars
Calculation: Gap = Oscillator - EMA(Oscillator, signal smoothing lookback); calculate on T1 bars using the bar still forming and project values onto chart bars
Long: Oscillator > 0 OR Oscillator crosses above EMA(Oscillator, signal smoothing lookback) OR Gap >= 0
Short: Oscillator < 0 OR Oscillator crosses below EMA(Oscillator, signal smoothing lookback) OR Gap < 0