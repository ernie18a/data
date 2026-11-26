Calculation: Model = among L from shortest window to longest window in steps of window step with R-squared >= minimum R-squared, the linear regression of close over the last L bars that maximizes R-squared * LN(L) + slope weight * ABS(slope) / ATR(ATR lookback) - sigma weight * sigma / ATR(ATR lookback), where sigma = SQRT(sum of squared residuals / (L - 2))
Calculation: Center = intercept(Model) + slope(Model) * (length(Model) - 1)
Calculation: Upper(m) = Center + m * sigma(Model)
Calculation: Lower(m) = Center - m * sigma(Model)
Calculation: Z = (close - Center) / sigma(Model)
Long: slope(Model) > 0 AND close crosses above Lower(core multiplier) AND close >= EMA(close, bias lookback) AND RSI(close, momentum lookback) >= momentum midline AND volume > SMA(volume, volume lookback) * volume threshold
Long: slope(Model) > 0 AND close crosses above Center AND Z <= acceptance limit AND close >= EMA(close, bias lookback) AND volume > SMA(volume, volume lookback) * volume threshold
Short: slope(Model) < 0 AND close crosses below Upper(core multiplier) AND close <= EMA(close, bias lookback) AND RSI(close, momentum lookback) <= momentum midline AND volume > SMA(volume, volume lookback) * volume threshold
Short: slope(Model) < 0 AND close crosses below Center AND Z >= -acceptance limit AND close <= EMA(close, bias lookback) AND volume > SMA(volume, volume lookback) * volume threshold
Exit: long, slope(Model) > 0 AND close < Upper(outer multiplier) AND close[1] > Upper(outer multiplier)[1]
Exit: short, slope(Model) < 0 AND close > Lower(outer multiplier) AND close[1] < Lower(outer multiplier)[1]
Short: close > Upper(stress multiplier)
Long: close < Lower(stress multiplier)