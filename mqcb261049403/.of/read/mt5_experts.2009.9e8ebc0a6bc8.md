Calculation: Oscillator = 100 × triple-smoothed (selected price − lowest low over the lookback) / triple-smoothed (highest high − lowest low over the same lookback) − 50; use 0 when the smoothed range is 0. Smooth numerator and denominator separately using the same selected moving-average method and three successive, independently parameterized smoothing periods. Highest high and lowest low include the current calculation bar.
Calculation: Signal oscillator = oscillator on a selectable higher or lower timeframe, evaluated on the last completed bar or, if configured, the still-forming bar; previous values are from successive earlier bars of that timeframe.
Long: Chart-timeframe oscillator > 0 AND oscillator > previous oscillator OR chart-timeframe oscillator < 0 AND oscillator > previous oscillator
Short: Chart-timeframe oscillator > 0 AND oscillator < previous oscillator OR chart-timeframe oscillator < 0 AND oscillator < previous oscillator
Long: Signal oscillator > 0 AND previous signal oscillator <= 0
Short: Signal oscillator < 0 AND previous signal oscillator >= 0
Long: Signal oscillator > previous signal oscillator AND previous signal oscillator <= signal oscillator two bars ago
Short: Signal oscillator < previous signal oscillator AND previous signal oscillator >= signal oscillator two bars ago
Exit: long, signal oscillator < 0
Exit: short, signal oscillator > 0
Exit: long, signal oscillator < previous signal oscillator
Exit: short, signal oscillator > previous signal oscillator
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance