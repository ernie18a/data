Calculation: Z(x) = (ROC(x, momentum length) - SMA(ROC(x, momentum length), rank length)) / STDEV(ROC(x, momentum length), rank length)
Calculation: Pressure(x, s) = s * clamp(pressure scale * Z(x), -pressure cap, pressure cap)
Calculation: Signed = [Pressure(dollar index close, -1), Pressure(10-year yield close, -1), Pressure(volatility index close, -1), Pressure(credit appetite close, +1)], on chart bars with each close taken from T1 last completed bar
Calculation: Composite = average(Signed)
Calculation: Shock = max(abs(Signed))
Long: Composite crosses above agreement threshold
Long: Composite > agreement threshold
Long: Composite > agreement threshold AND Shock < shock threshold
Long: Composite > agreement threshold AND Shock < shock threshold AND count(Signed < 0) < divergence count
Short: Composite crosses below -agreement threshold
Short: Composite < -agreement threshold
Short: Composite < -agreement threshold AND Shock < shock threshold
Short: Composite < -agreement threshold AND Shock < shock threshold AND count(Signed > 0) < divergence count