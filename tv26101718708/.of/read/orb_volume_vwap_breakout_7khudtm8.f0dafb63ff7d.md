Calculation: Opening range high = highest high from the start of the regular session until the opening-range window ends; lock the value once the window has elapsed.
Calculation: Volume average = simple moving average of volume over a lookback.
Calculation: Session VWAP = volume-weighted average price for the current session, using typical price (high + low + close) / 3.
Long: Opening range is locked AND close > opening range high AND volume > volume multiplier × volume average AND close > session VWAP AND the full breakout condition was false on the previous chart bar.