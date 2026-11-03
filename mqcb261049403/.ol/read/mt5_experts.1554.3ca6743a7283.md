Calculation: Oscillator = (multiplier × (shorter-lookback moving average − longer-lookback moving average))³, using current-bar values on the chart timeframe
Calculation: Upper and lower thresholds = initialize both to zero; when the oscillator exceeds the upper threshold, set the upper threshold to the oscillator and the lower threshold to oscillator − delta; when the oscillator falls below the lower threshold, set the lower threshold to the oscillator and the upper threshold to oscillator + delta
Long: flat AND oscillator > upper threshold
Short: flat AND oscillator < lower threshold
Exit: long, oscillator < lower threshold
Exit: short, oscillator > upper threshold