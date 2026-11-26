Calculation: Fast MA = selected MA(close, shorter-lookback parameter; MA type parameter selects EMA, SMA, or WMA)
Calculation: Slow MA = selected MA(close, longer-lookback parameter; same MA type parameter)
Calculation: RSI = RSI(close, RSI lookback parameter)
Calculation: Relative strength = EMA(close / benchmark close for the current chart bar, RS smoothing parameter)
Calculation: Volume filter = volume filter disabled OR volume >= SMA(volume, volume-average lookback parameter) × minimum-volume multiplier
Long: Fast MA > Slow MA
Short: Fast MA <= Slow MA
Long: rising(Relative strength, RS trend-confirmation parameter)
Short: falling(Relative strength, RS trend-confirmation parameter)
Long: Fast MA crosses above Slow MA AND rising(Relative strength, RS trend-confirmation parameter) AND RSI > RSI oversold threshold AND RSI < RSI overbought threshold AND Volume filter
Long: Fast MA > Slow MA AND close > Fast MA AND close[1] < Fast MA[1] AND rising(Relative strength, RS trend-confirmation parameter) AND RSI < bounce RSI threshold AND Volume filter
Long: rising(Relative strength, RS trend-confirmation parameter) AND Fast MA > Slow MA AND RSI < RSI overbought threshold
Short: falling(Relative strength, RS trend-confirmation parameter) AND Fast MA < Slow MA AND RSI > (100 - RSI overbought threshold)
Short: Fast MA crosses below Slow MA AND falling(Relative strength, RS trend-confirmation parameter) AND RSI < (100 - RSI oversold threshold) AND Volume filter
Exit: long, Fast MA crosses below Slow MA OR (falling(Relative strength, RS trend-confirmation parameter) AND RSI > RSI overbought threshold)
Exit: short, Fast MA crosses above Slow MA OR rising(Relative strength, RS trend-confirmation parameter)
Calculation: relative strength = EMA(traded instrument closing price / benchmark closing price, P1)
Long: fast selected moving average crosses above slow selected moving average AND relative strength is higher than each of its preceding P2 values AND RSI(traded instrument closing price, P6) > P7 AND RSI(traded instrument closing price, P6) < P8 AND (volume filter is disabled by P9 OR volume >= SMA(volume, P11) × P10)
Long: fast selected moving average > slow selected moving average AND traded instrument closing price > fast selected moving average AND previous bar's closing price < previous bar's fast selected moving average AND relative strength is higher than each of its preceding P2 values AND RSI(traded instrument closing price, P6) < P12 AND (volume filter is disabled by P9 OR volume >= SMA(volume, P11) × P10)
Long: relative strength is higher than each of its preceding P2 values AND fast selected moving average > slow selected moving average AND RSI(traded instrument closing price, P6) < P8
Exit: long, fast selected moving average crosses below slow selected moving average OR (relative strength is lower than each of its preceding P2 values AND RSI(traded instrument closing price, P6) > P8)
Short: fast selected moving average crosses below slow selected moving average AND relative strength is lower than each of its preceding P2 values AND RSI(traded instrument closing price, P6) < 100 − P7 AND (volume filter is disabled by P9 OR volume >= SMA(volume, P11) × P10)
Short: relative strength is lower than each of its preceding P2 values AND fast selected moving average < slow selected moving average AND RSI(traded instrument closing price, P6) > 100 − P8
Exit: short, fast selected moving average crosses above slow selected moving average OR relative strength is higher than each of its preceding P2 values