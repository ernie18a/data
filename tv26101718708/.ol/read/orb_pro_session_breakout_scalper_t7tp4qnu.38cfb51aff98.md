Calculation: Opening range high = highest high from session start through the opening-range period
Calculation: Opening range low = lowest low from session start through the opening-range period
Calculation: Session VWAP = cumulative (high + low + close) / 3 × volume since session start, divided by cumulative volume since session start
Calculation: Range size = opening range high − opening range low
Calculation: Average volume = simple moving average of volume over the volume lookback
Calculation: Long stop = opening range low in range-stop mode; otherwise close − ATR × stop multiplier
Calculation: Short stop = opening range high in range-stop mode; otherwise close + ATR × stop multiplier
Calculation: Long risk = close − long stop
Calculation: Short risk = short stop − close
Calculation: Long target = close + long risk × target risk multiple
Calculation: Short target = close − short risk × target risk multiple
Calculation: Long partial target = close + long risk × partial-exit multiple
Calculation: Short partial target = close − short risk × partial-exit multiple
Long: opening range is locked AND range size is between the minimum and maximum ATR multiples AND volume ≥ average volume × volume multiple AND close > session VWAP AND bars since close ≤ opening range high ≥ confirmation-bar count AND within session AND trades today < daily trade limit AND close > opening range high
Short: opening range is locked AND range size is between the minimum and maximum ATR multiples AND volume ≥ average volume × volume multiple AND close < session VWAP AND bars since close ≥ opening range low ≥ confirmation-bar count AND within session AND trades today < daily trade limit AND close < opening range low AND trades today ≥ daily trade limit
Exit: long, high ≥ long partial target while partial exit is not done
Exit: short, low ≤ short partial target while partial exit is not done
Exit: long, low ≤ active stop OR high ≥ long target
Exit: short, high ≥ active stop OR low ≤ short target
Exit: long, session has ended
Exit: short, session has ended