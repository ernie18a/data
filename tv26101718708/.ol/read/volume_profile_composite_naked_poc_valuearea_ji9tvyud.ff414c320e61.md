Calculation: Prior-session POC, VAH, and VAL = levels from the volume-at-price profile built from the last completed higher-timeframe session, using chart bars; distribute each bar’s volume across its high-low price range, take the highest-volume bin as POC, then expand from POC toward the adjacent bin with greater volume until the value-area volume target is reached.
Calculation: Cumulative volume delta = cumulative volume × (2 × buy fraction − 1); buy fraction = standard-normal CDF of close change divided by volume-weighted RMS close change over a lookback, falling back to the standard deviation of close changes when needed.
Calculation: ATR = average true range over a lookback.
Long: close ≤ close[lookback] AND cumulative volume delta > cumulative volume delta[lookback]
Long: close < prior-session VAL AND close[1] ≥ prior-session VAL
Long: close > prior-session VAH AND close[1] ≤ prior-session VAH
Long: close < prior-session POC AND absolute(close − prior-session POC) ≥ stretch threshold × ATR AND absolute(close[1] − prior-session POC) < stretch threshold × ATR
Short: close > close[lookback] AND cumulative volume delta ≤ cumulative volume delta[lookback]
Short: close > prior-session VAH AND close[1] ≤ prior-session VAH
Short: close < prior-session VAL AND close[1] ≥ prior-session VAL
Short: close > prior-session POC AND absolute(close − prior-session POC) ≥ stretch threshold × ATR AND absolute(close[1] − prior-session POC) < stretch threshold × ATR