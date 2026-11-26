Calculation: Weighted oscillator = (RSI(close, RSI lookback) × RSI weight + MFI(high, low, close, volume, MFI lookback) × MFI weight + (Williams %R(high, low, close, Williams %R lookback) + 100) × Williams %R weight + 100 × DeMarker(high, low, DeMarker lookback) × DeMarker weight) / sum of the four weights
Long: On each T1 bar close, in reversal-following mode, weighted oscillator[1] < weighted oscillator[2] AND weighted oscillator[0] > weighted oscillator[1], OR in reversal-opposing mode, weighted oscillator[1] > weighted oscillator[2] AND weighted oscillator[0] < weighted oscillator[1]
Short: On each T1 bar close, in reversal-following mode, weighted oscillator[1] > weighted oscillator[2] AND weighted oscillator[0] < weighted oscillator[1], OR in reversal-opposing mode, weighted oscillator[1] < weighted oscillator[2] AND weighted oscillator[0] > weighted oscillator[1]
Long: On each chart bar, weighted oscillator > its midpoint
Short: On each chart bar, weighted oscillator < its midpoint
Exit: long, low ≤ entry price − stop-loss distance OR high ≥ entry price + take-profit distance
Exit: short, high ≥ entry price + stop-loss distance OR low ≤ entry price − take-profit distance