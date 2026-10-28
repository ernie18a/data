Calculation: Current session TPO value area = the band containing the configured share of TPOs, grown from the highest-count row toward the adjacent row with more TPOs; it includes the forming bar. Previous-session TPO value area = the same calculation for the last completed session.
Calculation: Initial balance = the high and low of the first configured number of bars in the current session; it updates while those bars form.
Calculation: Current session range = the highest and lowest occupied TPO rows, including the forming bar.
Calculation: Bull-bias score = +1 if close > current VAH, −1 if close < current VAL, otherwise 0; plus +1 if current VAL > previous VAH, −1 if current VAH < previous VAL, otherwise 0; plus +1 if session high > IB high and session low ≥ IB low, −1 if session low < IB low and session high ≤ IB high, otherwise 0.
Calculation: Upper/lower TPO counts = sums of TPO counts above/below the current session TPO POC, excluding rows with exactly one TPO.
Calculation: Current session profile shape = double if the row range is at least 6, an interior row has at most 30% of the POC count, and each side of that row contains at least 30% of total TPOs; otherwise P if the POC is at or above 62% of the row range from its low, b if at or below 38%, and normal otherwise.
Long: close > current session VAH AND previous close ≤ previous bar's current session VAH
Long: the current session has traded below the previous session VAL AND close > previous session VAL
Long: the current session has traded below the previous session VAL AND close > previous session VAL AND previous close ≤ previous session VAL
Long: bull-bias score ≥ 2 OR bull-bias score = 1
Long: upper TPO count > 1.2 × lower TPO count
Long: rotation factor > 2
Long: current session profile shape = P
Long: |close − session open| ≥ IB width AND minimum of the session's high and low excursions from the open ≤ 0.4 × IB width AND close > session open
Long: close is inside the previous session value area for at least two bracket durations AND the first close inside followed a close below the previous session VAL
Long: after price first reaches the previous session VAL from above, price reaches the previous session POC before reaching previous VAL − configured ATR distance or exceeding the configured bar horizon
Short: close < current session VAL AND previous close ≥ previous bar's current session VAL
Short: the current session has traded above the previous session VAH AND close < previous session VAH
Short: the current session has traded above the previous session VAH AND close < previous session VAH AND previous close ≥ previous session VAH
Short: bull-bias score ≤ −2 OR bull-bias score = −1
Short: lower TPO count > 1.2 × upper TPO count
Short: rotation factor < −2
Short: current session profile shape = b
Short: |close − session open| ≥ IB width AND minimum of the session's high and low excursions from the open ≤ 0.4 × IB width AND close < session open
Short: close is inside the previous session value area for at least two bracket durations AND the first close inside followed a close above the previous session VAH
Short: after price first reaches the previous session VAH from below, price reaches the previous session POC before reaching previous VAH + configured ATR distance or exceeding the configured bar horizon
Exit: long, close < entry price
Exit: short, close > entry price