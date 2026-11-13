Calculation: spread = high-low; body = |close-open|; upW = high-max(open,close); loW = min(open,close)-low; bull = close>open; bear = close<open
Calculation: volAvg = SMA(volume, n1); spreadAvg = SMA(spread, n2); trend = EMA(close, n3)
Calculation: highVol = volume > kH*volAvg; ultraVol = volume > kU*volAvg (kU > kH > 1); lowVol = volume < kL*volAvg (kL < 1); wide = spread > kW*spreadAvg (kW >= 1); narrow = spread < kN*spreadAvg (kN < 1); trendBull = close>trend; trendBear = close<trend
Calculation: noDemand = bull AND lowVol AND narrow; noSupply = bear AND lowVol AND narrow
Calculation: stopVol = bear AND ultraVol AND loW>body AND loW>upW; upthrust = bull AND highVol AND upW > c1*body (c1>1) AND close < high - c2*spread (0<c2<1)
Calculation: absBuy = highVol AND bear AND loW>body AND close > low + c3*spread; absSell = highVol AND bull AND upW>body AND close < high - c3*spread (0<c3<1)
Calculation: buyerScore = sum of positive weights for each true item: bull (w1), trendBull (w2), highVol (w3), wide (w4), stopVol (w5), noSupply (w6), absBuy (w7); sellerScore = same weights for: bear (w1), trendBear (w2), highVol (w3), wide (w4), upthrust (w5), noDemand (w6), absSell (w7)
Calculation: buyPct = 100*buyerScore/(buyerScore+sellerScore), sellPct = 100*sellerScore/(buyerScore+sellerScore); both = 50 if the sum is 0
Long: (( bull AND highVol AND wide AND trendBull) OR stopVol OR noSupply OR absBuy) AND buyPct > sellPct AND buyPct >= T (T > 50), evaluated on the last completed chart-timeframe bar
Short: ((bear AND highVol AND wide AND trendBear) OR upthrust OR noDemand OR absSell) AND sellPct > buyPct AND sellPct >= T, evaluated on the last completed chart-timeframe bar
Long: the same Long condition computed on bars aggregated to each of several other timeframes (some lower, some higher than the chart timeframe), using the still-forming bar of that timeframe
Short: the same Short condition computed on bars aggregated to each of several other timeframes (some lower, some higher than the chart timeframe), using the still-forming bar of that timeframe