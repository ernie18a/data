Calculation: in session = time of day >= session start time AND time of day <= session start time + session length
Calculation: session start = in session AND NOT in session[1]
Calculation: first candle high = IF session start THEN high ELSE first candle high[1]
Calculation: first candle low = IF session start THEN low ELSE first candle low[1]
Calculation: high break = NOT session start AND (high break[1] OR (in session AND high > first candle high + ATR(ATR lookback) * minimum break size))
Calculation: low break = NOT session start AND (low break[1] OR (in session AND low < first candle low - ATR(ATR lookback) * minimum break size))
Calculation: high break event = high break AND NOT high break[1]
Calculation: low break event = low break AND NOT low break[1]
Calculation: high retest zone = high break AND BarsSince(high break event) >= minimum bars after break AND BarsSince(high break event) <= maximum bars after break AND low >= first candle high - ATR(ATR lookback) * retest threshold AND low <= first candle high + ATR(ATR lookback) * retest threshold
Calculation: low retest zone = low break AND BarsSince(low break event) >= minimum bars after break AND BarsSince(low break event) <= maximum bars after break AND high >= first candle low - ATR(ATR lookback) * retest threshold AND high <= first candle low + ATR(ATR lookback) * retest threshold
Long: in session AND high retest zone AND close > first candle high AND close > EMA(close, EMA lookback) AND close > VWAP(close) AND volume > SMA(volume, volume average lookback) * volume threshold
Long: high break event
Long: high retest zone
Short: in session AND low retest zone AND close < first candle low AND close < EMA(close, EMA lookback) AND close < VWAP(close) AND volume > SMA(volume, volume average lookback) * volume threshold
Short: low break event
Short: low retest zone
Exit: long, NOT in session AND in session[1]
Exit: short, NOT in session AND in session[1]