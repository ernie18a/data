Calculation: SwingHigh = high of the most recent confirmed pivot high (a bar whose high is the highest among an equal number of bars on each side; confirmed only after the right-side bars complete)
Calculation: SwingLow = low of the most recent confirmed pivot low (a bar whose low is the lowest among an equal number of bars on each side; confirmed only after the right-side bars complete)
Calculation: BullBOS = close > SwingHigh AND previous close <= SwingHigh
Calculation: BearBOS = close < SwingLow AND previous close >= SwingLow
Calculation: BullBreakLevel = SwingHigh value at the most recent bar where BullBOS was true
Calculation: BearBreakLevel = SwingLow value at the most recent bar where BearBOS was true
Calculation: BullSweep = low < SwingLow AND close > SwingLow
Calculation: BearSweep = high > SwingHigh AND close < SwingHigh
Long: BullBOS
Long: BullSweep
Long: fast EMA(close) > slow EMA(close) (fast has shorter length) AND Supertrend is in uptrend AND RSI > upper RSI threshold AND RSI > previous bar RSI AND on a higher timeframe (bar still forming, using its close so far) fast EMA(close) > slow EMA(close) (same lengths) AND higher-timeframe Supertrend is in uptrend AND ADX >= minimum ADX AND ATR >= minimum ATR (absolute price units) AND (BullSweep is true on the current bar OR was true within the last few bars) AND bars since most recent BullBOS <= max retest window (0 allowed) AND low <= BullBreakLevel * (1 + small tolerance %) AND close > BullBreakLevel AND bar time is inside the trading session
Short: BearBOS
Short: BearSweep
Short: fast EMA(close) < slow EMA(close) (fast has shorter length) AND Supertrend is in downtrend AND RSI < lower RSI threshold (lower than the long RSI threshold) AND RSI < previous bar RSI AND on a higher timeframe (bar still forming, using its close so far) fast EMA(close) < slow EMA(close) (same lengths) AND higher-timeframe Supertrend is in downtrend AND ADX >= minimum ADX AND ATR >= minimum ATR (absolute price units) AND (BearSweep is true on the current bar OR was true within the last few bars) AND bars since most recent BearBOS <= max retest window (0 allowed) AND high >= BearBreakLevel * (1 - small tolerance %) AND close < BearBreakLevel AND bar time is inside the trading session