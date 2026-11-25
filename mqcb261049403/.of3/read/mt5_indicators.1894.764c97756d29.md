Calculation: DeMarker = DeMarker(high, low, lookback)
Calculation: CCI = CCI((high + low + close) / 3, lookback)
Calculation: MFI = MFI((high + low + close) / 3, volume, lookback)
Calculation: Williams %R = Williams %R(high, low, close, lookback)
Calculation: Momentum = Momentum(close, lookback)
Calculation: Accelerator Oscillator = Accelerator Oscillator(high, low)
Long: DeMarker[0] < lower DeMarker threshold
Short: DeMarker[0] > upper DeMarker threshold
Short: CCI[0] > upper CCI threshold
Long: CCI[0] < lower CCI threshold
Short: MFI[0] > upper MFI threshold
Long: MFI[0] < lower MFI threshold
Long: Williams %R[0] < lower Williams %R threshold
Short: Williams %R[0] > upper Williams %R threshold
Long: Stochastic %K(high, low, close, %K lookback, slowing)[0] > Stochastic %D(high, low, close, %K lookback, %D lookback, slowing)[0]
Short: Stochastic %K(high, low, close, %K lookback, slowing)[0] < Stochastic %D(high, low, close, %K lookback, %D lookback, slowing)[0]
Long: Momentum[0] < Momentum reference level AND Momentum[1] > Momentum reference level
Short: Momentum[0] > Momentum reference level AND Momentum[1] < Momentum reference level
Short: (Accelerator Oscillator[0] < Accelerator Oscillator[1] AND Accelerator Oscillator[1] < Accelerator Oscillator[2] AND Accelerator Oscillator[2] < Accelerator Oscillator[3] AND Accelerator Oscillator[0] > Accelerator Oscillator sign threshold AND Accelerator Oscillator[1] > Accelerator Oscillator sign threshold AND Accelerator Oscillator[2] > Accelerator Oscillator sign threshold) OR (Accelerator Oscillator[0] <= Accelerator Oscillator[1] AND Accelerator Oscillator[1] <= Accelerator Oscillator[2])
Long: (Accelerator Oscillator[0] > Accelerator Oscillator[1] AND Accelerator Oscillator[1] > Accelerator Oscillator[2] AND Accelerator Oscillator[2] > Accelerator Oscillator[3] AND Accelerator Oscillator[0] < Accelerator Oscillator sign threshold AND Accelerator Oscillator[1] < Accelerator Oscillator sign threshold AND Accelerator Oscillator[2] < Accelerator Oscillator sign threshold) OR (Accelerator Oscillator[0] >= Accelerator Oscillator[1] AND Accelerator Oscillator[1] >= Accelerator Oscillator[2] AND Accelerator Oscillator[2] >= Accelerator Oscillator[3])