Calculation: Oscillator = smooth the raw oscillator with a selectable moving-average method and smoothing parameters; for selected price P and lookback N, raw oscillator at bar t = (P[t] - SMA(P, N)[t]) / (0.015 * mean over i = 0 to N-1 of abs(P[t-i] - SMA(P, N)[t-i])); use zero when the denominator is zero.
Calculation: Higher-timeframe oscillator = the same oscillator calculated on higher-timeframe bars, using the bar still forming at the first chart bar of each higher-timeframe bar; hold that value and its previous-higher-timeframe-bar comparison until the next higher-timeframe bar.
Long: In level mode, oscillator > middle level.
Short: In level mode, oscillator < middle level.
Long: In direction mode, oscillator > previous oscillator AND oscillator != middle level.
Short: In direction mode, oscillator < previous oscillator AND oscillator != middle level.