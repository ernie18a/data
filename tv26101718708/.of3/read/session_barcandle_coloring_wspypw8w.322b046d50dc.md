Calculation: SessionTime(t) = time-of-day of t in session time zone is from session start to session end AND weekday of t is a selected weekday
Calculation: InSession = (portion option is open) ? SessionTime(chart bar open time) : (portion option is close) ? SessionTime(open time of last T1 bar within chart bar) : (portion option is entire) ? all T1 bars within chart bar satisfy SessionTime(their open time) : SessionTime(chart bar open time) OR any T1 bar within chart bar satisfies SessionTime(its open time)
Calculation: RefPrice = (previous-close flag) ? nz(close[1], open) : open
Long: close > RefPrice AND InSession AND chart timeframe is intraday
Short: close < RefPrice AND InSession AND chart timeframe is intraday