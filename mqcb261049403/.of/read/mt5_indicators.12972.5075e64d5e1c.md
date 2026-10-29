Calculation: Bulls raw = let range = high - low, body = open - close, tick size = range / volume (replace zero tick size with 1), and swing = (range + abs(body)) / (2 * tick size); if open > close, body / tick size + swing, otherwise swing
Calculation: Bears raw = let range = high - low, body = open - close, tick size = range / volume (replace zero tick size with 1), and swing = (range + abs(body)) / (2 * tick size); if open < close, -body / tick size + swing, otherwise swing
Calculation: Smoothed Bulls = apply a configurable smoothing method and lookback to Bulls raw on chart-timeframe bars
Calculation: Smoothed Bears = apply the same smoothing method and lookback as Smoothed Bulls to Bears raw on chart-timeframe bars
Long: previous Smoothed Bulls >= previous Smoothed Bears AND current Smoothed Bulls < current Smoothed Bears
Short: previous Smoothed Bulls <= previous Smoothed Bears AND current Smoothed Bulls > current Smoothed Bears