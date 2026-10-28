Calculation: ATR gate bounds = slower EMA ± ATR × gate multiplier
Calculation: Entry price = close on the confirmed setup bar
Calculation: Long stop = min(rolling lowest low over swing lookback, entry price − ATR × stop-floor multiplier)
Calculation: Short stop = max(rolling highest high over swing lookback, entry price + ATR × stop-floor multiplier)
Calculation: Risk = max(abs(entry price − stop), minimum tick size × 10)
Calculation: Long targets = entry price + risk × each configured target multiple
Calculation: Short targets = entry price − risk × each configured target multiple
Long: confirmed bar AND fast EMA > slower EMA AND close > upper ATR gate AND close > VWAP AND fast EMA > its previous-bar value AND prior engine direction is not long
Short: confirmed bar AND fast EMA < slower EMA AND close < lower ATR gate AND close < VWAP AND fast EMA < its previous-bar value AND prior engine direction is not short
Exit: long, confirmed bar after setup bar AND (low ≤ stop OR high ≥ any configured target)
Exit: short, confirmed bar after setup bar AND (high ≥ stop OR low ≤ any configured target)