Long: On chart bars taking values from the forming bars of shorter source timeframe T1 and longer source timeframe T2, HMA(close, shared lookback, T1) crosses above HMA(close, shared lookback, T2)
Short: On chart bars taking values from the forming bars of shorter source timeframe T1 and longer source timeframe T2, HMA(close, shared lookback, T1) crosses below HMA(close, shared lookback, T2)
Calculation: Long stop = entry × (1 − stop-loss percentage), changing permanently to entry after any bar since entry has high >= entry × (1 + first take-profit percentage)
Calculation: Short stop = entry × (1 + stop-loss percentage), changing permanently to entry after any bar since entry has low <= entry × (1 − first take-profit percentage)
Exit: Long, high >= entry × (1 + second take-profit percentage) OR low <= long stop
Exit: Short, low <= entry × (1 − second take-profit percentage) OR high >= short stop