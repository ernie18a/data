Calculation: Recent range = highest high minus lowest low over a lookback
Calculation: Bullish candle body = max(close − open, 0)
Calculation: Bullish rebound speed = bullish candle body ÷ recent range × 100, or 0 when recent range is 0
Calculation: Rebound event score = rebound speed plus a tiered point addition at each of three increasing speed thresholds, using only the addition for the highest threshold met; 0 below the lowest threshold
Calculation: Accumulated rebound pressure = max(0, previous bar's pressure × decay factor + rebound event score × weight)
Long: accumulated rebound pressure ≥ early-warning level AND its simple moving average is ≥ its previous-bar value OR accumulated rebound pressure's simple moving average ≥ main-warning level AND that average is > its previous-bar value