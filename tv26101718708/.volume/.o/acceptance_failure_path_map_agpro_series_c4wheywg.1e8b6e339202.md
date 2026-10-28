Calculation: Upper boundary = highest high of the previous completed lookback bars + ATR buffer
Calculation: Lower boundary = lowest low of the previous completed lookback bars − ATR buffer
Calculation: Upside acceptance = closes above the upper boundary for the required consecutive bars, newly reaching that count
Calculation: Downside acceptance = closes below the lower boundary for the required consecutive bars, newly reaching that count
Calculation: Active acceptance = the latest upside or downside acceptance, with its side, boundary, and bar retained
Calculation: Early failure = within the failure window after active acceptance, close crosses back through its retained boundary
Calculation: Late failure = after the failure window, close is across the retained boundary against the active acceptance side
Calculation: Reclaim = after an early failure, close crosses back through the retained boundary in the original acceptance direction
Calculation: Held acceptance = after the failure window, close remains beyond the retained boundary in the original acceptance direction
Calculation: Failure risk = clamp to 0–100 of (distance across the retained boundary against the active acceptance side / ATR × risk scale + base risk); pressure begins when it newly reaches the risk threshold
Long: Upside acceptance OR downside early failure OR downside late failure OR reclaim after downside failure OR held upside acceptance OR failure pressure during downside acceptance
Short: Downside acceptance OR upside early failure OR upside late failure OR reclaim after upside failure OR held downside acceptance OR failure pressure during upside acceptance