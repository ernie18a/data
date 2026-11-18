Calculation: RSI of VWAP = RSI(VWAP(hlc3), VWAP RSI lookback)
Calculation: RSI of volume-weighted regressed close = RSI(VWMA(LinReg(close, close regression/VWMA lookback), close regression/VWMA lookback), volume-weighted RSI lookback)
Long: RSI of VWAP > RSI of VWAP[1] AND RSI(LinReg(hlc3, hlc3 regression lookback), hlc3 RSI lookback) > RSI(LinReg(hlc3, hlc3 regression lookback), hlc3 RSI lookback)[1] AND RSI of VWAP < long-entry threshold AND during configured session AND on or after configured start date
Short: RSI of volume-weighted regressed close > short-entry threshold AND RSI of volume-weighted regressed close < RSI of volume-weighted regressed close[1] AND RSI of volume-weighted regressed close[2] < RSI of volume-weighted regressed close[1] AND during configured session AND on or after configured start date
Exit: long, RSI of VWAP crosses above long-exit threshold AND on or after configured start date
Exit: short, RSI of volume-weighted regressed close > RSI of volume-weighted regressed close[1] AND RSI of volume-weighted regressed close[2] > RSI of volume-weighted regressed close[1] AND on or after configured start date
Exit: long, high >= entry price × (1 + long profit target) AND on or after configured start date
Exit: short, low <= entry price × (1 - short profit target) AND on or after configured start date