Calculation: Body = ABS(close - open)
Calculation: Upper shadow = high - MAX(open, close)
Calculation: Lower shadow = MIN(open, close) - low
Calculation: Candle range = MAX(high - low, minimum range)
Calculation: Buy volume = IF(close > open, volume, volume * (close - low) / Candle range)
Calculation: Volume delta = 2 * Buy volume - volume
Calculation: Bull momentum candle = close > open AND Body >= SMA(Body, momentum period) * momentum multiplier
Calculation: Bear momentum candle = close < open AND Body >= SMA(Body, momentum period) * momentum multiplier
Calculation: Volume spike = volume >= SMA(volume, volume period) * volume spike multiplier
Calculation: Smart bull = Bull momentum candle AND Volume spike AND Volume delta > 0
Calculation: Smart bear = Bear momentum candle AND Volume spike AND Volume delta < 0
Calculation: Confirmed bull = Smart bull AND RSI(close, RSI period) < RSI overbought level AND close(T1, last completed bar) > EMA(close, HTF EMA period, T1, last completed bar)
Calculation: Confirmed bear = Smart bear AND RSI(close, RSI period) > RSI oversold level AND close(T1, last completed bar) < EMA(close, HTF EMA period, T1, last completed bar)
Calculation: Stop distance = ATR(ATR period) at entry * stop multiplier
Long: Confirmed bull
Long: Smart bull AND NOT Confirmed bull
Long: Smart bull
Long: Confirmed bull AND close[1] < open[1]
Long: Confirmed bull AND NOT Confirmed bull[1]
Long: Lower shadow > Body * shadow-to-body ratio AND Lower shadow > Upper shadow
Long: low > high[2]
Long: Bull momentum candle
Short: Confirmed bear
Short: Smart bear AND NOT Confirmed bear
Short: Smart bear
Short: Confirmed bear AND close[1] > open[1]
Short: Confirmed bear AND NOT Confirmed bear[1]
Short: Upper shadow > Body * shadow-to-body ratio AND Upper shadow > Lower shadow
Short: high < low[2]
Short: Bear momentum candle
Exit: long, low <= entry price - Stop distance
Exit: long, high >= entry price + Stop distance * reward-to-risk ratio
Exit: short, high >= entry price + Stop distance
Exit: short, low <= entry price - Stop distance * reward-to-risk ratio