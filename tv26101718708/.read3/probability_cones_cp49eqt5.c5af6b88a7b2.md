Calculation: AnchorLag = bars back + anchor offset
Calculation: LogReturn = LN(close / close[1])
Calculation: LogMean = SMA(LogReturn, lookback)
Calculation: LogStdev = STDEV(LogReturn, lookback)
Calculation: UpperCone2 = close[AnchorLag] * EXP(AnchorLag * LogMean[AnchorLag] + second deviation multiplier * LogStdev[AnchorLag] * SQRT(AnchorLag))
Calculation: LowerCone2 = close[AnchorLag] * EXP(AnchorLag * LogMean[AnchorLag] - second deviation multiplier * LogStdev[AnchorLag] * SQRT(AnchorLag))
Exit: long, close < entry price AND (close > UpperCone2 OR close < LowerCone2)
Exit: short, close > entry price AND (close > UpperCone2 OR close < LowerCone2)