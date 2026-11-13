Calculation: ORB High / ORB Low = highest high / lowest low of the bars inside the opening-range time window of the current day; defined only after that window has ended
Calculation: Fast EMA, Slow EMA = EMA of close, with the fast length shorter than the slow length
Calculation: Mid SMA = SMA of close, with a length longer than both EMAs
Calculation: VWAP = daily-reset volume-weighted average of (high+low+close)/3
Calculation: dev = volume-weighted standard deviation of (high+low+close)/3 around VWAP, accumulated from the start of the day
Calculation: ATR_entry = ATR (chart timeframe) on the entry bar
Calculation: risk = ORB High - ORB Low
Long: (Breakout mode) flat AND opening range completed AND current bar inside the daily trading-hours window (which starts no earlier than the opening-range window) AND entries today < daily cap AND close crosses above ORB High (close > ORB High AND previous close <= ORB High) AND Fast EMA > Slow EMA AND close > Mid SMA
Long: (MeanReversion mode, alternative to the above) flat AND opening range completed AND inside trading-hours window AND entries today < daily cap AND close < VWAP - 2*dev AND close crosses above the previous bar's low (close > low[1] AND close[1] <= low[2]) AND close > Mid SMA
Short: (Breakout mode) flat AND opening range completed AND inside trading-hours window AND entries today < daily cap AND close crosses below ORB Low (close < ORB Low AND previous close >= ORB Low) AND Fast EMA < Slow EMA AND close < Mid SMA
Short: (MeanReversion mode, alternative to the above) flat AND opening range completed AND inside trading-hours window AND entries today < daily cap AND close > VWAP + 2*dev AND close crosses below the previous bar's high (close < high[1] AND close[1] >= high[2]) AND close < Mid SMA
Exit: long, (TP1 not yet reached AND low <= initial stop, where initial stop = ORB Low in Breakout mode or entry price - risk in MeanReversion mode) OR (TP1 reached AND low <= entry price)
Exit: long, high >= entry price + TP1 multiplier*ATR_entry (partial scale-out; afterwards the stop becomes the entry price)
Exit: long, TP1 reached AND high >= entry price + TP2 multiplier*ATR_entry, with TP2 multiplier > TP1 multiplier (closes the remainder)
Exit: short, (TP1 not yet reached AND high >= initial stop, where initial stop = ORB High in Breakout mode or entry price + risk in MeanReversion mode) OR (TP1 reached AND high >= entry price)
Exit: short, low <= entry price - TP1 multiplier*ATR_entry (partial scale-out; afterwards the stop becomes the entry price)
Exit: short, TP1 reached AND low <= entry price - TP2 multiplier*ATR_entry, with TP2 multiplier > TP1 multiplier (closes the remainder)
Exit: long or short, a new trading day begins (flatten)
Notes: entry price = close of the signal bar; exit conditions are evaluated starting on the entry bar itself; the stop check on a bar includes a bar that also reaches TP1.