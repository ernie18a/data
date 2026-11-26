Calculation: CVD = EMA(volume * (close - open) / (high - low), CVD length)
Calculation: RSI = RSI(close, RSI length)
Calculation: Stoch = SMA(Stochastic(close, high, low, K length), smoothing length)
Calculation: BearDiv(x, lookback) = close < open AND close[1] > open[1] AND high[1] >= max(high[2..lookback]) AND max(x[2..lookback]) > x[1]
Calculation: BullDiv(x, lookback) = close > open AND close[1] < open[1] AND low[1] <= min(low[2..lookback]) AND min(x[2..lookback]) < x[1]
Calculation: BearRSI(lookback) = BearDiv(RSI, lookback) AND RSI >= RSI OB level
Calculation: BullRSI(lookback) = BullDiv(RSI, lookback) AND RSI <= RSI OS level
Calculation: BearSto(lookback) = BearDiv(Stoch, lookback) AND Stoch >= Stoch OB level
Calculation: BullSto(lookback) = BullDiv(Stoch, lookback) AND Stoch <= Stoch OS level
Short: BearRSI(shorter lookback) OR BearRSI(longer lookback)
Short: BearSto(shorter lookback) OR BearSto(longer lookback)
Short: BearDiv(CVD, shorter lookback) OR BearDiv(CVD, longer lookback)
Short: BearDiv(CVD, shorter lookback) AND BearRSI(shorter lookback) AND BearSto(shorter lookback) OR BearDiv(CVD, longer lookback) AND BearRSI(longer lookback) AND BearSto(longer lookback)
Short: BearRSI(shorter lookback) AND BearSto(shorter lookback) AND NOT BearDiv(CVD, shorter lookback) OR BearRSI(longer lookback) AND BearSto(longer lookback) AND NOT BearDiv(CVD, longer lookback)
Short: BearDiv(CVD, shorter lookback) AND BearSto(shorter lookback) AND NOT BearRSI(shorter lookback) OR BearDiv(CVD, longer lookback) AND BearSto(longer lookback) AND NOT BearRSI(longer lookback)
Short: BearDiv(CVD, shorter lookback) AND BearRSI(shorter lookback) AND NOT BearSto(shorter lookback) OR BearDiv(CVD, longer lookback) AND BearRSI(longer lookback) AND NOT BearSto(longer lookback)
Long: BullRSI(shorter lookback) OR BullRSI(longer lookback)
Long: BullSto(shorter lookback) OR BullSto(longer lookback)
Long: BullDiv(CVD, shorter lookback) OR BullDiv(CVD, longer lookback)
Long: BullDiv(CVD, shorter lookback) AND BullRSI(shorter lookback) AND BullSto(shorter lookback) OR BullDiv(CVD, longer lookback) AND BullRSI(longer lookback) AND BullSto(longer lookback)
Long: BullRSI(shorter lookback) AND BullSto(shorter lookback) AND NOT BullDiv(CVD, shorter lookback) OR BullRSI(longer lookback) AND BullSto(longer lookback) AND NOT BullDiv(CVD, longer lookback)
Long: BullDiv(CVD, shorter lookback) AND BullSto(shorter lookback) AND NOT BullRSI(shorter lookback) OR BullDiv(CVD, longer lookback) AND BullSto(longer lookback) AND NOT BullRSI(longer lookback)
Long: BullDiv(CVD, shorter lookback) AND BullRSI(shorter lookback) AND NOT BullSto(shorter lookback) OR BullDiv(CVD, longer lookback) AND BullRSI(longer lookback) AND NOT BullSto(longer lookback)