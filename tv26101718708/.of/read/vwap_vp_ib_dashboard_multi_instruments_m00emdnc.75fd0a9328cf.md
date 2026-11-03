Calculation: Daily VWAP = volume-weighted mean of (open + high + low + close) / 4, reset at each instrument daily boundary.
Calculation: Session VWAP = volume-weighted mean of (open + high + low + close) / 4, reset whenever any configured session opens and accumulated while at least one session is active.
Calculation: VWAP bands = VWAP plus or minus a multiplier times the volume-weighted standard deviation of (open + high + low + close) / 4 over the same bars as that VWAP.
Calculation: Volume-profile value area = at each profile reset, divide a fixed range centered on the first bar's high-low midpoint into equal price rows; the range extends in each direction by a multiplier times the larger of the first bar's high-low range and a minimum price increment threshold. Allocate each positive-volume bar's volume to intersected rows in proportion to their overlap with the bar's high-low range divided by the larger of that range and the minimum price increment. Choose the lowest row with maximum volume as the point of control. Expand the value area by at least one adjacent row when more than one row exists, then continue until the accumulated volume reaches the target proportion or no rows remain; at each step choose the adjacent row with greater volume, choosing the upper row on a tie. The lower and upper edges of the included rows are the value-area low and high. The daily profile resets at a fixed UTC daily anchor and includes all bars; the session profile resets whenever any configured session opens and includes bars while at least one session is active.
Calculation: Initial balance = highest high and lowest low accumulated during the configured initial-balance window, reset at the window's opening and retained after it closes until the next opening.
Long: close >= daily VWAP
Short: close < daily VWAP
Long: at least one configured session is active AND close >= session VWAP
Short: at least one configured session is active AND close < session VWAP
Long: close > daily VWAP upper band
Short: close < daily VWAP lower band
Long: at least one configured session is active AND close > session VWAP upper band
Short: at least one configured session is active AND close < session VWAP lower band
Long: close > daily volume-profile value-area high
Short: close < daily volume-profile value-area low
Long: at least one configured session is active AND close > session volume-profile value-area high
Short: at least one configured session is active AND close < session volume-profile value-area low
Long: initial-balance window is closed AND close > initial-balance high
Short: initial-balance window is closed AND close < initial-balance low