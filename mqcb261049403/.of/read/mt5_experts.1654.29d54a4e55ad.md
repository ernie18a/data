Calculation: Weighted price = (5 × close + 2 × open + high + low) / 9, on completed chart-timeframe bars
Calculation: AO spread = EMA of weighted price with the shorter fast lookback − EMA of weighted price with the longer slow lookback
Calculation: Filter = EMA of weighted price with a lookback shorter than both AO-spread EMA lookbacks
Long: AO spread > its previous value AND its previous value ≤ its value two bars earlier AND Filter ≥ its previous value AND the most recent earlier signal is not bullish (or no earlier signal exists) AND the completed higher-timeframe trend candle close > open
Short: AO spread < its previous value AND its previous value ≥ its value two bars earlier AND Filter ≤ its previous value AND the most recent earlier signal is not bearish (or no earlier signal exists) AND the completed higher-timeframe trend candle close < open
Exit: long, a bearish signal occurs OR low ≤ entry price − stop-loss distance OR high ≥ entry price + take-profit distance
Exit: short, a bullish signal occurs OR high ≥ entry price + stop-loss distance OR low ≤ entry price − take-profit distance