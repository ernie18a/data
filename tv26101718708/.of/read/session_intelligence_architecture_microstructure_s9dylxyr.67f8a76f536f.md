Calculation: Asia High/Low = running high/low of the Asia session, retained after it ends
Calculation: Session RVOL = current cumulative session volume divided by the average volume of the previous same-type sessions
Calculation: Session VWAP = cumulative sum of (hlc3 × volume) divided by cumulative volume since the session opened
Calculation: Confirmed swing high/low = pivot high/low with equal left and right lookbacks; retain the latest confirmed pivot
Calculation: Structure bias = bullish after a close crosses above the latest swing high; bearish after a close crosses below the latest swing low; initially neutral
Long: During a Europe or US session outside Asia, close > Asia High AND abs(close - open) / (high - low) >= breakout body ratio
Long: During a Europe or US session outside Asia, low < Asia Low AND close > Asia Low
Long: Close crosses above the latest confirmed swing high AND prior structure bias is bearish
Long: Session close > session open AND session move > ATR × expansion multiplier AND Session RVOL > volume threshold
Long: Session close > Session VWAP
Short: During a Europe or US session outside Asia, close < Asia Low AND abs(close - open) / (high - low) >= breakout body ratio
Short: During a Europe or US session outside Asia, high > Asia High AND close < Asia High
Short: Close crosses below the latest confirmed swing low AND prior structure bias is bullish
Short: Session close < session open AND abs(session close - session open) > ATR × expansion multiplier AND Session RVOL > volume threshold
Short: Session close <= Session VWAP