Calculation: Session open = open of the first lower-timeframe bar in the current session.
Calculation: Previous session close = close of the last completed lower-timeframe bar in the most recent preceding session with data within the source's search window.
Calculation: Gap = session open / previous session close - 1.
Calculation: Opening-range high and low = highest high and lowest low of the completed lower-timeframe bars in the opening-range interval.
Calculation: Session VWAP = sum of lower-timeframe typical price multiplied by volume since session open / sum of that volume, including the bar still forming; replace nonpositive volume with 1.
Calculation: Session high and low = highest high and lowest low of lower-timeframe bars since session open, including the bar still forming.
Calculation: Half-gap level = (session open + previous session close) / 2.
Calculation: Initial long stop = opening-range low minus the stop buffer, subject to the broker minimum stop distance at entry.
Calculation: Initial short stop = opening-range high plus the stop buffer, subject to the broker minimum stop distance at entry.
Calculation: Initial risk = absolute difference between entry price and initial stop.
Calculation: Exact reproduction is unavailable from the specified bars: entries and exits use live bid and ask, spread filters use their difference, and initial stops also depend on broker minimum stop distance. The comparisons below use bar price as a proxy for bid or ask.
Long: Gap >= bullish minimum gap AND session low > half-gap level AND bar price > opening-range high AND bar price > session VWAP AND datetime >= opening-range end AND datetime <= entry deadline AND datetime < forced-exit time AND entries today = 0 AND open positions = 0.
Short: Gap <= -bearish minimum gap AND session high < half-gap level AND bar price < opening-range low AND bar price < session VWAP AND datetime >= opening-range end AND datetime <= entry deadline AND datetime < forced-exit time AND entries today = 0 AND open positions = 0.
Exit: long, bar price >= entry price + partial-target multiple * initial risk AND partial exit count = 0; close the configured fraction.
Exit: short, bar price <= entry price - partial-target multiple * initial risk AND partial exit count = 0; close the configured fraction.
Exit: long, bar price >= entry price + final-target multiple * initial risk OR bar price <= initial long stop OR (break-even stop enabled AND partial exit count > 0 AND bar price <= entry price) OR datetime < session open OR datetime >= forced-exit time.
Exit: short, bar price <= entry price - final-target multiple * initial risk OR bar price >= initial short stop OR (break-even stop enabled AND partial exit count > 0 AND bar price >= entry price) OR datetime < session open OR datetime >= forced-exit time.