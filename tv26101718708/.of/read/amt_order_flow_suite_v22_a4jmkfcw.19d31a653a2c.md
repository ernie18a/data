Calculation: Per-bar delta = volume × abs(close − open) / (high − low) if close ≥ open, otherwise its negative; use 0.5 for the body ratio when high = low
Calculation: Session CVD = sum of per-bar delta since the daily session reset
Calculation: CVD signal = EMA of session CVD
Calculation: Session VWAP = sum of (typical price × volume) / sum of volume since the daily session reset, where typical price = (high + low + close) / 3
Calculation: Session volume-weighted standard deviation = sqrt(sum of (typical price² × volume) / sum of volume − session VWAP²) since the daily session reset
Calculation: Upper and lower value boundaries = session VWAP ± session volume-weighted standard deviation
Long: low ≤ lowest low over the divergence lookback AND session CVD > the configured fraction of the lowest session CVD over the same lookback AND session CVD > 0
Long: lowest low over the failed-auction lookback < lower value boundary − proximity threshold AND close > lower value boundary − proximity threshold AND close < lower value boundary + 2 × proximity threshold AND per-bar delta > 0 AND session CVD > CVD signal
Short: high ≥ highest high over the divergence lookback AND session CVD < the configured fraction of the highest session CVD over the same lookback AND session CVD < 0
Short: highest high over the failed-auction lookback > upper value boundary + proximity threshold AND close < upper value boundary + proximity threshold AND close > upper value boundary − 2 × proximity threshold AND per-bar delta < 0 AND session CVD < CVD signal