Calculation: POC, VAH, VAL = From the last completed selected daily, weekly, or monthly profile, divide its high-low range into equal price rows. Allocate each source bar’s volume equally across rows touched by its high-low range. Split row volume bullish when close > open, bearish when close < open, and equally when equal. POC is the highest-total-volume row; expand from it toward the adjacent row with greater volume until the configured value-area fraction is reached; VAH and VAL are the resulting upper and lower boundaries.
Calculation: Bullish and bearish row shares = For each row in the last completed selected profile, bullish or bearish allocated volume divided by total row volume.
Long: close > VAH
Long: The lowest close over the configured acceptance lookback > VAH AND the close immediately before that lookback <= VAH
Long: low < VAL AND close > VAL AND previous close >= VAL
Long: low < VAL AND close > VAH
Long: close > POC AND previous close <= POC
Long: low <= VAL AND close > VAL
Long: Any profile row’s bullish share >= the configured imbalance threshold
Short: close < VAL
Short: The highest close over the configured acceptance lookback < VAL AND the close immediately before that lookback >= VAL
Short: high > VAH AND close < VAH AND previous close <= VAH
Short: high > VAH AND close < VAL
Short: close < POC AND previous close >= POC
Short: Any profile row’s bearish share >= the configured imbalance threshold