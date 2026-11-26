Calculation: High ALMA = ALMA(high, longest moving-average lookback, T1, last completed bar), calculated on chart bars
Calculation: Close RMA = RMA(close, middle moving-average lookback, T1, last completed bar), calculated on chart bars
Calculation: Close Super3 = Super3 moving average(close, shortest moving-average lookback, T1, last completed bar), calculated on chart bars
Calculation: RMA oscillator = SWMA(Stochastic(Close RMA, Close RMA, Close RMA, separate stochastic lookback) / 50 - 1), calculated on chart bars
Calculation: Super3 oscillator = SWMA(Stochastic(Close Super3, Close Super3, Close Super3, separate stochastic lookback) / 50 - 1), calculated on chart bars
Long: datetime is within the configured test interval AND RMA oscillator crosses above Super3 oscillator AND RMA oscillator < oversold threshold AND High ALMA < low(T1, last completed bar)
Short: datetime is within the configured test interval AND RMA oscillator crosses below Super3 oscillator AND RMA oscillator > overbought threshold AND High ALMA > high(T1, last completed bar)