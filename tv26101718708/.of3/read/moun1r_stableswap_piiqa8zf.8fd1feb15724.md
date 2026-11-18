Calculation: Renko close = close of Renko bars built from open with ATR brick sizing and a lookback parameter, sampled on chart bars at the chart timeframe
Long: crosses below(LinReg(SMA(Renko close, SMA lookback), regression lookback, regression offset), VWAP(close)) AND close > Renko close OR Renko close[1] < Renko close AND close > Renko close
Exit: long, crosses below(close, VWAP(close))