Calculation: VAH = ValueAreaHigh(high, low, volume, lookback, bin count)
Calculation: VAL = ValueAreaLow(high, low, volume, lookback, bin count)
Calculation: AboveRun = AboveRun[1] + 1 if close > VAH, else 0
Calculation: BelowRun = BelowRun[1] + 1 if close < VAL, else 0
Calculation: MarketPressure = volume scale * (SMA(volume, shorter volume lookback) / SMA(volume, longer volume lookback) - 1) + trend scale * (EMA(close, shorter trend lookback) - EMA(close, longer trend lookback)) / ATR(distance ATR lookback) + distance scale * (close - PointOfControl(high, low, volume, lookback, bin count)) / (distance multiplier * ATR(distance ATR lookback))
Long: bar index >= lookback AND AboveRun == acceptance count
Long: bar index >= lookback AND close > VAH
Long: bar index >= lookback AND MarketPressure >= state threshold
Long: EMA(close, shorter trend lookback) >= EMA(close, longer trend lookback)
Short: bar index >= lookback AND BelowRun == acceptance count
Short: bar index >= lookback AND close < VAL
Short: bar index >= lookback AND MarketPressure <= -state threshold
Short: EMA(close, shorter trend lookback) < EMA(close, longer trend lookback)