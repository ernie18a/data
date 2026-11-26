Calculation: Composite oscillator = (TCI(hlc3, master lookback, first smoothing lookback) + MFI(hlc3, volume, third lookback) + RSI(hlc3, third lookback)) / 3
Long: Composite oscillator crosses above SMA(Composite oscillator, signal smoothing lookback) and LSMA(Composite oscillator, LSMA lookback), after Composite oscillator[1] < lower threshold
Short: Composite oscillator crosses below SMA(Composite oscillator, signal smoothing lookback) and LSMA(Composite oscillator, LSMA lookback), after Composite oscillator[1] > upper threshold
Long: SMA(Composite oscillator, signal smoothing lookback) < lower threshold
Short: SMA(Composite oscillator, signal smoothing lookback) > upper threshold