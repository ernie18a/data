Calculation: Normalized distance = (close - rolling VWAP) / ATR(ATR lookback) when ATR > 0, otherwise zero; rolling VWAP = VWMA(close, VWAP lookback) or close when SUM(volume, VWAP lookback) = 0
Calculation: Acceptance count = min(acceptance cap, previous count + acceptance step) when close > rolling VWAP, otherwise max(-acceptance cap, previous count - acceptance step); initialize previous count to zero
Calculation: Flow = distance weight * normalized distance + velocity weight * EMA(normalized distance - normalized distance[1], velocity lookback) + acceptance weight * acceptance count / acceptance scale + slope weight * (rolling VWAP - rolling VWAP[slope lookback]) / ATR(ATR lookback) when ATR > 0, otherwise zero for the slope term
Calculation: Chart Flow = EMA(Flow, chart lookback); chart lookback < X5 lookback < X15 lookback
Calculation: X5 Flow = EMA(Flow, X5 lookback)
Calculation: X15 Flow = EMA(Flow, X15 lookback)
Calculation: Trigger = EMA(Chart Flow, trigger lookback)
Long: X15 Flow > 0 AND X5 Flow > 0 AND Chart Flow < 0
Long: Chart Flow crosses above X5 Flow
Long: X15 Flow > 0 AND X5 Flow > 0 AND Chart Flow crosses above Trigger AND Chart Flow > Chart Flow[1]
Short: X15 Flow < 0 AND X5 Flow < 0 AND Chart Flow > 0
Short: Chart Flow crosses below X5 Flow
Short: X15 Flow < 0 AND X5 Flow < 0 AND Chart Flow crosses below Trigger AND Chart Flow < Chart Flow[1]