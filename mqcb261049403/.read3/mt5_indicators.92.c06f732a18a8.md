Calculation: CCI run count on T1 bars = 1 on the first bar or when CCI(typical price, CCI lookback, T1, bar still forming) × CCI(typical price, CCI lookback, T1, previous bar) < 0; otherwise previous CCI run count + 1
Long: CCI(typical price, CCI lookback, T1, bar still forming) > 0 AND CCI run count on T1 bars >= signal-bar parameter
Short: CCI(typical price, CCI lookback, T1, bar still forming) < 0 AND CCI run count on T1 bars >= signal-bar parameter
Long: On T1 bars, close(T1, bar still forming) > LSMA(close, LSMA lookback, T1, bar still forming)
Short: On T1 bars, close(T1, bar still forming) < LSMA(close, LSMA lookback, T1, bar still forming)