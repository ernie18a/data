Calculation: stochastic = SMA over stochastic smoothing length of raw stochastic, where raw stochastic = 100 * (close - lowest low over stochastic length) / (highest high over stochastic length - lowest low over stochastic length)
Calculation: relative strength = RSI of close over RSI length with Wilder smoothing
Calculation: typical price = (high + low + close) / 3
Calculation: upper flow = sum over MFI length bars of volume * typical price on bars where typical price is above its prior-bar value, else 0
Calculation: lower flow = sum over MFI length bars of volume * typical price on bars where typical price is below its prior-bar value, else 0
Calculation: money flow index = 100 - 100 / (1 + upper flow / lower flow)
Calculation: flow line = min((money flow index / relative strength) * ((relative strength + money flow index) / 2), 100)
Calculation: flow inverse = UNKNOWN, definition is in READ lines 57-60 which are skipped
Calculation: flow average = min((flow line + flow inverse) / 2, 100)
Calculation: smoothed flow average = min(SMA over flow smoothing length of flow average, 100)
Calculation: smoothed flow line = min(SMA over flow smoothing length of flow line, 100)
Calculation: ATR = Wilder average over ATR length of true range, where true range = max(high - low, |high - previous close|, |low - previous close|)
Calculation: long stop level = low - ATR, both taken on the bar where the Long condition was most recently true
Calculation: long target level = close * long target multiplier, taken on the bar where the Long condition was most recently true
Calculation: short stop level = high + ATR, both taken on the bar where the Short condition was most recently true
Calculation: short target level = close * short target multiplier, taken on the bar where the Short condition was most recently true
Calculation: stochastic crosses above smoothed flow average = stochastic > smoothed flow average on this bar AND stochastic <= smoothed flow average on previous bar
Calculation: stochastic crosses below smoothed flow average = stochastic < smoothed flow average on this bar AND stochastic >= smoothed flow average on previous bar
Long: stochastic crosses above smoothed flow average OR (stochastic <= long entry stochastic threshold AND smoothed flow line < long entry flow threshold)
Short: stochastic crosses below smoothed flow average OR (stochastic >= short entry stochastic threshold AND smoothed flow line > short entry flow threshold)
Exit: long, smoothed flow line > long exit flow threshold AND stochastic > long exit stochastic threshold
Exit: short, (smoothed flow line < short exit flow threshold AND stochastic < short exit stochastic threshold) OR stochastic <= short exit extreme stochastic threshold
Exit: long, low <= long stop level OR high >= long target level
Exit: short, high >= short stop level OR low <= short target level