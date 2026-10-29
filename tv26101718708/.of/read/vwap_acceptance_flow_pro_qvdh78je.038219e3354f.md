Calculation: Rolling VWAP = rolling volume-weighted average of close
Calculation: Acceptance Flow = weighted combination of normalized close distance from Rolling VWAP, smoothed change in that distance, capped cumulative acceptance duration (increment while close is above Rolling VWAP, decrement otherwise), and normalized Rolling VWAP slope
Calculation: Chart Flow = EMA of Acceptance Flow with the shortest smoothing lookback
Calculation: X5 Flow = EMA of Acceptance Flow with a longer smoothing lookback than Chart Flow
Calculation: X15 Flow = EMA of Acceptance Flow with a longer smoothing lookback than X5 Flow
Calculation: Flow Trigger = EMA of Chart Flow
Long: Chart Flow crosses above X5 Flow OR X15 Flow > 0 AND X5 Flow > 0 AND Chart Flow < 0 OR X15 Flow > 0 AND X5 Flow > 0 AND Chart Flow crosses above Flow Trigger AND Chart Flow > its prior-bar value
Short: Chart Flow crosses below X5 Flow OR X15 Flow < 0 AND X5 Flow < 0 AND Chart Flow > 0 OR X15 Flow < 0 AND X5 Flow < 0 AND Chart Flow crosses below Flow Trigger AND Chart Flow < its prior-bar value