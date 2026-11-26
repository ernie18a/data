Calculation: NetPressure = volume × ((close − low) − (high − close)) / max(high − low, minimum price increment)
Long: close > close[1]
Short: close < close[1]
Long: sufficient prior history for the whale comparison lookback and its extra prior bar AND close > close[1] AND volume > max({0} ∪ {volume[i] : 1 ≤ i ≤ whale comparison lookback AND close[i] < close[i+1]})
Short: sufficient prior history for the whale comparison lookback and its extra prior bar AND close < close[1] AND volume > max({0} ∪ {volume[i] : 1 ≤ i ≤ whale comparison lookback AND close[i] > close[i+1]})
Long: NetPressure > EMA(NetPressure, CBP smoothing lookback)
Short: NetPressure < EMA(NetPressure, CBP smoothing lookback)
Long: NetPressure > EMA(NetPressure, CBP smoothing lookback) AND NetPressure > EMA(NetPressure, CBP smoothing lookback)[1] × pressure comparison multiplier (use 0 when the prior EMA is unavailable)
Short: NetPressure < EMA(NetPressure, CBP smoothing lookback) AND NetPressure < EMA(NetPressure, CBP smoothing lookback)[1] × pressure comparison multiplier (use 0 when the prior EMA is unavailable)