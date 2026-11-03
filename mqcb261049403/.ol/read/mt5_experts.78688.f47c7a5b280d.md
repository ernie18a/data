Calculation: Session high/low = highest high and lowest low of completed lower-timeframe bars from the session start up to, but not including, the session end
Calculation: Range width = session high − session low
Calculation: Long stop-entry level = session high + entry offset + spread at order placement
Calculation: Short stop-entry level = session low − entry offset
Calculation: Long stop-loss level = session low − stop offset
Calculation: Short stop-loss level = session high + stop offset + spread at order placement
Calculation: Long take-profit level = entry price + reward/risk multiple × (entry price − long stop-loss level)
Calculation: Short take-profit level = entry price − reward/risk multiple × (short stop-loss level − entry price)
Long: After the session ends and before the daily order-cancel time AND trading day is enabled AND maximum spread is disabled or current spread ≤ maximum spread AND minimum range width is disabled or range width ≥ minimum range width AND maximum range width is disabled or range width ≤ maximum range width AND long stop-entry level − current ask > broker minimum stop distance
Short: After the session ends and before the daily order-cancel time AND trading day is enabled AND maximum spread is disabled or current spread ≤ maximum spread AND minimum range width is disabled or range width ≥ minimum range width AND maximum range width is disabled or range width ≤ maximum range width AND current bid − short stop-entry level > broker minimum stop distance
Exit: Long, current price ≤ long stop-loss level OR current price ≥ long take-profit level OR current time ≥ enabled daily position-close time
Exit: Short, current price ≥ short stop-loss level OR current price ≤ short take-profit level OR current time ≥ enabled daily position-close time