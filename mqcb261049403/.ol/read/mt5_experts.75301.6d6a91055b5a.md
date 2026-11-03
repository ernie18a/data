Calculation: Opening gap = (current session's first bar open / previous cash session's last bar close − 1) × 100%.
Calculation: Opening range high/low = highest high / lowest low across lower-timeframe bars from session open through the opening-range end; use completed bars.
Calculation: Session VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume from session open through the current time, using lower-timeframe bars including the bar still forming.
Calculation: Gap midpoint = previous cash-session close + 0.5 × (current session open − previous cash-session close).
Calculation: Initial risk = absolute difference between entry price and initial stop price.
Long: Opening gap > 0 AND absolute opening gap ≥ minimum bullish gap AND current price > opening range high AND current price > session VWAP AND session low > gap midpoint AND current time is after the opening range ends and no later than the entry deadline AND no strategy entry has occurred that day.
Short: Opening gap < 0 AND absolute opening gap ≥ minimum bearish gap AND current price < opening range low AND current price < session VWAP AND session high < gap midpoint AND current time is after the opening range ends and no later than the entry deadline AND no strategy entry has occurred that day.
Exit: Long, price ≤ initial stop price OR price ≥ entry price + 2 × initial risk OR current time reaches the session's forced-exit time.
Exit: Long, price ≥ entry price + 1 × initial risk.
Exit: Short, price ≥ initial stop price OR price ≤ entry price − 2 × initial risk OR current time reaches the session's forced-exit time.
Exit: Short, price ≤ entry price − 1 × initial risk.