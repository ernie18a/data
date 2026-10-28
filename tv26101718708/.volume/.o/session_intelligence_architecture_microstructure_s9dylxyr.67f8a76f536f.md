Calculation: Asia high/low = running high/low of the current Asia session, frozen when it ends
Calculation: Session VWAP = cumulative sum of (typical price × volume) divided by cumulative volume from that session's start through the current bar
Calculation: Session relative volume = current cumulative session volume divided by the mean volume of the most recent completed sessions of the same type
Calculation: Candle body ratio = absolute close minus open divided by high minus low
Calculation: Confirmed swing high/low = pivot high/low confirmed using equal lookbacks on each side
Long: During Europe or US outside Asia, low < Asia low AND close > Asia low
Long: During Europe or US outside Asia, close > Asia high AND candle body ratio ≥ the configured minimum
Long: Close crosses above the latest confirmed swing high AND prior structure bias is bearish
Long: Session close > that session's VWAP
Long: Session close > session open AND session close minus session open > current ATR × expansion multiplier AND session relative volume > volume threshold
Short: During Europe or US outside Asia, high > Asia high AND close < Asia high
Short: During Europe or US outside Asia, close < Asia low AND candle body ratio ≥ the configured minimum
Short: Close crosses below the latest confirmed swing low AND prior structure bias is bullish
Short: Session close ≤ that session's VWAP
Short: Session close < session open AND absolute(session close minus session open) > current ATR × expansion multiplier AND session relative volume > volume threshold