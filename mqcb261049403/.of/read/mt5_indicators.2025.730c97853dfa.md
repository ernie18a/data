Calculation: Oscillator = shorter-period moving average of the selected bar price minus the longer-period moving average of the same price, using the same smoothing method.
Calculation: Signal = moving average of the oscillator, using a separately selected smoothing method and period.
Calculation: Oscillator and signal are calculated either on the chart timeframe or on a higher timeframe using the bar still forming; oscillator changes compare consecutive bars of the selected timeframe.
Long: Oscillator > signal.
Long: Oscillator > 0 AND oscillator > previous oscillator OR oscillator < 0 AND oscillator > previous oscillator.
Short: Oscillator < signal.
Short: Oscillator > 0 AND oscillator < previous oscillator OR oscillator < 0 AND oscillator < previous oscillator.