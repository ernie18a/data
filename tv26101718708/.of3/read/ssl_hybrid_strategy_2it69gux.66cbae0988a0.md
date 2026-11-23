Calculation: ATR = ATR(ATR length)
Calculation: smoothed ATR = MA(TR, smoothed ATR length, smoothing type)
Calculation: SSL band(MA type, length) = MA(high, length, MA type) if trend state < 0, else MA(low, length, MA type); trend state = +1 if close > MA(high, length, MA type), -1 if close < MA(low, length, MA type), else previous trend state
Calculation: entry band = SSL band(entry MA type, entry length)
Calculation: continuation band = SSL band(continuation MA type, continuation length)
Calculation: exit band = SSL band(exit MA type, exit length)
Calculation: baseline = MA(close, entry length, entry MA type)
Calculation: channel center = MA(source, entry length, entry MA type)
Calculation: channel half-width = EMA(range, entry length) * channel multiplier; range = TR if true-range switch on, else high - low
Calculation: MA1 = MA(close, MA1 length, MA1 type) on T1 bars, last completed T1 bar, taken on chart bars
Calculation: MA2 = MA(close, MA2 length, MA2 type) on T1 bars, last completed T1 bar, taken on chart bars
Calculation: entry side (updated only on date-range bars; otherwise unchanged): if prior entry side is unset, long if close crosses above entry band, short if close crosses below entry band, else unset; if prior entry side is long or short, long if close > entry band, short if close < entry band, else unset
Calculation: last entry direction = long on bars where a long entry fires, short on bars where a short entry fires, else unchanged; initially unset
Long: entry side = long AND (MA filter switch off OR MA1 >= MA1[rise lag]) AND datetime in date range AND last entry direction != long
Short: entry side = short AND (MA filter switch off OR MA1 < MA1[rise lag]) AND datetime in date range AND last entry direction != short
Long: close > entry band
Long: close > channel center + channel half-width
Long: MA1 >= MA1[rise lag]
Long: close - smoothed ATR * continuation ATR factor < continuation band AND close > baseline AND close > continuation band
Long: open < MA1 AND close > MA1
Long: open < MA2 AND close > MA2
Short: close < entry band
Short: close < channel center - channel half-width
Short: MA1 < MA1[rise lag]
Short: close + smoothed ATR * continuation ATR factor > continuation band AND close < baseline AND close < continuation band
Short: open > MA1 AND close < MA1
Short: open > MA2 AND close < MA2
Exit: long, close crosses below exit band
Exit: short, close crosses above exit band
Exit: long, TP/SL switch on AND (low <= entry price - ATR at entry * SL multiplier OR high >= entry price + ATR at entry * TP1 multiplier OR high >= entry price + ATR at entry * TP2 multiplier OR high >= entry price + ATR at entry * TP3 multiplier OR high >= entry price + ATR at entry * TP4 multiplier OR high >= entry price + ATR at entry * TP5 multiplier)
Exit: long, TP/SL switch on AND break-even switch on AND highest high since entry >= entry price + ATR at entry * TP1 multiplier AND low <= entry price
Exit: short, TP/SL switch on AND (high >= entry price + ATR at entry * SL multiplier OR low <= entry price - ATR at entry * TP1 multiplier OR low <= entry price - ATR at entry * TP2 multiplier OR low <= entry price - ATR at entry * TP3 multiplier OR low <= entry price - ATR at entry * TP4 multiplier OR low <= entry price - ATR at entry * TP5 multiplier)
Exit: short, TP/SL switch on AND break-even switch on AND lowest low since entry <= entry price - ATR at entry * TP1 multiplier AND high >= entry price