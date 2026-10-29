Calculation: TSI = 100 × smooth(smooth(DeMarker(current bar) − DeMarker(bar N ago), short smoothing length), longer smoothing length) ÷ smooth(smooth(abs(DeMarker(current bar) − DeMarker(bar N ago)), short smoothing length), longer smoothing length), using the same configured moving-average method for each smoothing; use 0 when the denominator is 0
Calculation: Signal = smooth(TSI, configurable signal smoothing length, using the same configured moving-average method)
Long: TSI > Signal
Short: TSI < Signal