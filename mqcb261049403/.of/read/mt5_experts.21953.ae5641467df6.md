Calculation: Volume-weighted oscillator = moving average of (RSI of selected price - 50) × volume; use the same smoothing method and length for the oscillator and the moving average of volume. Calculate on the chart timeframe for indicator markings, or on a selectable higher or lower timeframe for trading decisions, using the last completed bar or the still-forming bar according to the selected signal-bar setting.
Calculation: Inner and outer upper and lower thresholds = their respective levels × the moving average of volume; outer upper > inner upper and outer lower < inner lower.
Long: Oscillator > inner upper threshold.
Long: Oscillator > inner upper threshold AND oscillator <= outer upper threshold AND previous oscillator <= previous inner upper threshold.
Long: Oscillator > outer upper threshold AND previous oscillator <= previous outer upper threshold.
Short: Oscillator < inner lower threshold.
Short: Oscillator < inner lower threshold AND oscillator >= outer lower threshold AND previous oscillator >= previous inner lower threshold.
Short: Oscillator < outer lower threshold AND previous oscillator >= previous outer lower threshold.
Exit: long, oscillator < inner lower threshold OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, oscillator > inner upper threshold OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.