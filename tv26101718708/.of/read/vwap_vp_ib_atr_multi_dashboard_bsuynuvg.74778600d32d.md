Calculation: Daily VWAP = volume-weighted average of (open + high + low + close) / 4 since the instrument's daily boundary, including the current bar.
Calculation: Session VWAP = volume-weighted average of (open + high + low + close) / 4, reset at the opening of any configured session and accumulated while any session is active, including the current bar.
Calculation: Profile value area = divide a fixed range into a configured number of equal price rows. At each reset, center the range on the first bar's high-low midpoint and extend it on each side by a multiple of the greater of that bar's range and a configured minimum price range. For each included bar, add its volume to each row in proportion to the overlap of the bar's high-low range with the row, divided by the greater of the bar's range and a configured minimum price increment. Starting at the first row with maximum volume, repeatedly add the adjacent row with greater volume, choosing the upper row on a tie, until the configured fraction of total profile volume is reached or no rows remain. Add at least one adjacent row when available. The value-area low and high are the outer boundaries of the selected rows. For the daily profile, reset at the configured daily anchor and include every bar; for the session profile, reset at the opening of any configured session and include bars while any session is active. Both include the current bar.
Calculation: Initial balance high and low = highest high and lowest low during the configured initial balance window; retain them after the window closes until the next window opens.
Long: close >= daily VWAP
Short: close < daily VWAP
Long: any configured session is active AND close >= session VWAP
Short: any configured session is active AND close < session VWAP
Long: close > daily profile value-area high
Short: close < daily profile value-area low
Long: any configured session is active AND close > session profile value-area high
Short: any configured session is active AND close < session profile value-area low
Long: initial balance window has closed AND close > initial balance high
Short: initial balance window has closed AND close < initial balance low