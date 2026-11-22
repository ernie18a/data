Calculation: Relative log price = log(risk-asset close / safe-haven close)
Calculation: Intermarket flow = SuperSmoother((Relative log price - SMA(Relative log price, P1)) / StDev(Relative log price, P1), P2)
Calculation: Intermarket flow velocity = Intermarket flow - previous Intermarket flow
Long: Intermarket flow > 0
Short: Intermarket flow < 0
Long: Intermarket flow crosses above 0
Short: Intermarket flow crosses below 0
Long: Intermarket flow < -P3 AND Intermarket flow velocity crosses above 0
Short: Intermarket flow > P3 AND Intermarket flow velocity crosses below 0