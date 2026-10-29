Calculation: Volume-weighted vigor = for each bar, sum over a longer lookback of (lookback length - lag + 1) times the four-bar weighted sum of volume × (close - open), divided by the equivalent sum of volume × (high - low); the four-bar weights from newest to oldest are 1, 8, 8, 1. If the denominator is zero, use the numerator.
Calculation: Oscillator = short-lookback Relative Vigor Index main line minus the four-bar weighted average of volume-weighted vigor, with weights 4, 3, 2, 1 from newest to oldest.
Calculation: Signal = a selected moving average of the oscillator. For the trading decisions, calculate the oscillator and signal on a selectable higher or lower timeframe, using either the last completed bar or the forming bar, and earlier bars relative to that bar. For indicator markings and alerts, calculate them on the chart timeframe.
Long: Chart-timeframe oscillator > previous oscillator.
Short: Chart-timeframe oscillator < previous oscillator.
Long: Chart-timeframe oscillator > previous signal.
Short: Chart-timeframe oscillator < previous signal.
Long: Last completed chart bar oscillator < its previous signal AND preceding chart bar oscillator > its previous signal.
Short: Last completed chart bar oscillator > its previous signal AND preceding chart bar oscillator < its previous signal.
Long: Oscillator > 0 AND previous oscillator <= 0.
Short: Oscillator < 0 AND previous oscillator >= 0.
Long: Oscillator > previous oscillator AND previous oscillator < oscillator two bars ago.
Short: Oscillator < previous oscillator AND previous oscillator > oscillator two bars ago.
Long: Signal > previous signal AND previous signal < signal two bars ago.
Short: Signal < previous signal AND previous signal > signal two bars ago.
Long: Oscillator > signal AND previous oscillator <= previous signal.
Short: Oscillator < signal AND previous oscillator >= previous signal.
Exit: long, oscillator < 0.
Exit: short, oscillator > 0.
Exit: long, oscillator < previous oscillator.
Exit: short, oscillator > previous oscillator.
Exit: long, signal < previous signal.
Exit: short, signal > previous signal.
Exit: long, oscillator < signal.
Exit: short, oscillator > signal.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.