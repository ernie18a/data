Calculation: ATR = Wilder average true range (same length everywhere below)
Calculation: LowBase = lowest low over the last A bars including the current bar; HighBase = highest high over the last A bars including the current bar
Calculation: RangeHigh = highest high over the last B bars including the current bar; RangeLow = lowest low over the last B bars including the current bar; B is longer than A
Calculation: FirstHigh, FirstLow = high and low of the first chart bar of the current calendar day (used from that bar onward, held for the rest of the day)
Calculation: Flat = no open position (in the liquidity system, no open trade since its last entry and before its exit)
Calculation: LiqFilter = volume > simple moving average of volume AND bar hour-of-day within the session window (start hour to end hour inclusive)
Long: (((close > LowBase AND previous close <= previous LowBase) AND close > LowBase + k*ATR) OR (close > LowBase AND close < RangeHigh AND Flat)) AND LiqFilter
Long: close > FirstHigh AND previous close <= FirstHigh AND low <= FirstHigh AND close > EMA(close) AND Flat AND (optional filter: RSI < oversold level)
Short: (((close < HighBase AND previous close >= previous HighBase) AND close < HighBase - k*ATR) OR (close < HighBase AND close > RangeLow AND Flat AND no Long liquidity signal on the same bar)) AND LiqFilter
Short: close < FirstLow AND previous close >= FirstLow AND high >= FirstLow AND close < EMA(close) AND Flat AND (optional filter: RSI > overbought level)
Exit: long opened by a liquidity Long, close >= entry close + m1*ATR OR close <= LowBase - m2*ATR (m1 is the take-profit multiplier, smaller than the stop multiplier m2; ATR and LowBase are taken on the latest bar where a liquidity Long condition was true, including while already in the position)
Exit: short opened by a liquidity Short, close <= entry close - m1*ATR OR close >= HighBase + m2*ATR (ATR and HighBase are taken on the latest bar where a liquidity Short condition was true, including while already in the position)
Exit: long opened by a first-bar Long, high >= FirstHigh + R*(FirstHigh - FirstLow) OR low <= FirstLow - c*ATR (FirstHigh, FirstLow and ATR fixed at the entry bar)
Exit: short opened by a first-bar Short, low <= FirstLow - R*(FirstHigh - FirstLow) OR high >= FirstHigh + c*ATR (FirstHigh, FirstLow and ATR fixed at the entry bar)