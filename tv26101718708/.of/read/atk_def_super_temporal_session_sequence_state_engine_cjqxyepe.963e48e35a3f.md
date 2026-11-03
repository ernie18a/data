Calculation: Session range = the highest high and lowest low of chart bars in a session so far, including the current bar; reset at each new trading day. Session open is the first session bar's open, and session close is the latest session bar's close. Evaluate each of the three overlapping sessions separately in exchange time.
Calculation: Average price position = the mean of available (chart close − last completed period low) / (last completed period high − last completed period low), omitting zero-range periods, across five progressively longer timeframes. Each timeframe may be higher or lower than the chart timeframe; for a lower timeframe use its last completed bar within the chart bar.
Long: A session has at least one bar AND its close > its open.
Short: A session has at least one bar AND its close < its open.
Long: A session has a nonzero range AND its close > (its high + its low) / 2.
Short: A session has a nonzero range AND its close < (its high + its low) / 2.
Long: Average price position > an upper threshold AND volume / SMA(volume) < a volume threshold.
Short: Average price position < a lower threshold AND volume / SMA(volume) < a volume threshold.
Long: The current bar is in a session AND no earlier bullish break has been confirmed for that session on the current trading day AND close > that session's high including the current bar.
Short: The current bar is in a session AND no earlier bearish break has been confirmed for that session on the current trading day AND close < that session's low including the current bar.