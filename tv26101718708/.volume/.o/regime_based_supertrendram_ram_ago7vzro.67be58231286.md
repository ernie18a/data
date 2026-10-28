Calculation: Regime score = count of these true conditions: RSI > its threshold, close > EMA, SuperTrend bullish, volume > volume moving average, weekly SuperTrend bullish using the still-forming weekly bar
Calculation: EMA stretch (%) = abs((close - EMA) / EMA) * 100
Long: regime score >= 4 AND EMA stretch <= maximum stretch AND previous bar (regime score < 4 OR EMA stretch > maximum stretch)
Short: SuperTrend bearish AND close < EMA AND RSI < 50 AND previous bar (SuperTrend bullish OR close >= EMA OR RSI >= 50)