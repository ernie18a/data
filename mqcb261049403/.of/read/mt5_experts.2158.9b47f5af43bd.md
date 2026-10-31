Calculation: Oscillator = Smooth the selected OHLC-derived price with a moving average; subtract its value a momentum lookback earlier; calculate Wilder-smoothed averages of the positive and absolute negative differences using the same period as the price average. Return 100 - 100 / (1 + positive average / negative average), or 0 when the negative average is zero.
Calculation: Signal line = moving average of the oscillator with an independently chosen smoothing method and period.
Calculation: Signal-bar oscillator = oscillator at a selectable bar offset on a selectable higher or lower timeframe; offset zero uses the bar still forming, and a positive offset uses a completed bar. Previous values are taken from preceding bars of that timeframe.
Long: Chart-timeframe oscillator > upper trend threshold.
Short: Chart-timeframe oscillator < lower trend threshold.
Long: Chart-timeframe oscillator < lower reversal threshold AND oscillator > previous oscillator.
Short: Chart-timeframe oscillator > upper reversal threshold AND oscillator < previous oscillator.
Long: Chart-timeframe oscillator > signal line.
Short: Chart-timeframe oscillator < signal line.
Long: Signal-bar oscillator > upper trend threshold AND previous signal-bar oscillator <= upper trend threshold.
Short: Signal-bar oscillator < lower trend threshold AND previous signal-bar oscillator >= lower trend threshold.
Long: Signal-bar oscillator > previous signal-bar oscillator AND previous signal-bar oscillator < oscillator two signal bars ago.
Short: Signal-bar oscillator < previous signal-bar oscillator AND previous signal-bar oscillator > oscillator two signal bars ago.
Long: Signal-bar oscillator < lower trend threshold AND previous signal-bar oscillator >= lower trend threshold.
Short: Signal-bar oscillator > upper trend threshold AND previous signal-bar oscillator <= upper trend threshold.
Exit: short, signal-bar oscillator > upper trend threshold OR signal-bar oscillator > previous signal-bar oscillator OR signal-bar oscillator < lower trend threshold.
Exit: long, signal-bar oscillator < lower trend threshold OR signal-bar oscillator < previous signal-bar oscillator OR signal-bar oscillator > upper trend threshold.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.