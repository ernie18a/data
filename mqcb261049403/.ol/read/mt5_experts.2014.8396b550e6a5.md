Calculation: Oscillator = 100 times the three-stage smoothed value of selected bar price minus the midpoint of the rolling highest high and lowest low, divided by the identically three-stage smoothed half-range of that high and low; use zero if the denominator is zero. Each stage uses the same selected smoothing method with its own period; the first period is longer than the second, and the third is shorter than the second.
Calculation: Signal = the selected smoothing method applied to the oscillator with its own period.
Calculation: EA oscillator and signal = the oscillator and signal calculated on the selected indicator timeframe, which may be higher or lower than the chart timeframe, using either the last completed bar or the still-forming bar according to the selected signal-bar setting; previous values refer to preceding indicator-timeframe bars.
Long: Chart-timeframe oscillator > previous oscillator OR chart-timeframe oscillator > signal
Short: Chart-timeframe oscillator < previous oscillator OR chart-timeframe oscillator < signal
Long: EA oscillator > 0 AND previous EA oscillator <= 0
Short: EA oscillator < 0 AND previous EA oscillator >= 0
Long: EA oscillator > previous EA oscillator AND previous EA oscillator < oscillator two indicator bars ago
Short: EA oscillator < previous EA oscillator AND previous EA oscillator > oscillator two indicator bars ago
Long: EA oscillator > EA signal AND previous EA oscillator <= previous EA signal
Short: EA oscillator < EA signal AND previous EA oscillator >= previous EA signal
Exit: long, EA oscillator < 0 OR EA oscillator < previous EA oscillator OR EA oscillator < EA signal
Exit: short, EA oscillator > 0 OR EA oscillator > previous EA oscillator OR EA oscillator > EA signal
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance