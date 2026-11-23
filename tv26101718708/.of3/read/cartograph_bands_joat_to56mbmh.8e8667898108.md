Calculation: Slope component = clamp(LinRegSlope(close, slope length) / max(ATR(ATR length) * slope scale, minimum step), -1, 1)
Calculation: Momentum = clamp(EMA(RSI weight * clamp((RSI(close, RSI length) - 50) / 50, -1, 1) + CMO weight * clamp(CMO(close, CMO length) / 100, -1, 1) + ROC weight * clamp(((ROC(close, ROC length) - SMA(ROC(close, ROC length), stdev length)) / STDEV(ROC(close, ROC length), stdev length)) / ROC scale, -1, 1) + slope weight * Slope component, momentum smoothing length), -1, 1)
Calculation: Regime = clamp(EMA(momentum driver weight * Momentum + slope driver weight * EMA(Slope component, momentum smoothing length), regime smoothing length), -1, 1), where regime smoothing length > momentum smoothing length
Calculation: Step = max(max(max(ATR(ATR length), STDEV(close, stdev length) * stdev scale), minimum step) * base multiplier * (1 + abs(Momentum) * momentum expansion weight) * (1 + abs(Regime) * regime expansion weight), minimum step)
Calculation: Center = EMA(close, basis length) + Regime * Step * center shift multiplier
Calculation: Upper band(multiplier) = Center + Step * multiplier, where outer multiplier > inner multiplier
Calculation: Lower band(multiplier) = Center - Step * multiplier
Long: Regime crosses above bull threshold AND chart bar is confirmed
Short: Regime crosses below bear threshold AND chart bar is confirmed
Long: close[1] < Lower band(outer multiplier)[1] AND close >= Lower band(outer multiplier) AND close <= Lower band(inner multiplier) AND chart bar is confirmed
Short: close[1] > Upper band(outer multiplier)[1] AND close <= Upper band(outer multiplier) AND close >= Upper band(inner multiplier) AND chart bar is confirmed