Calculation: long alignment = EMA(source 1, lookback 1) >= EMA(VWAP, MVWAP lookback) AND EMA(source 2, lookback 2) >= EMA(VWAP, MVWAP lookback) AND EMA(VWAP, VWAP lookback) >= EMA(VWAP, MVWAP lookback)
Calculation: short alignment = EMA(source 1, lookback 1) <= EMA(VWAP, MVWAP lookback) AND EMA(source 2, lookback 2) <= EMA(VWAP, MVWAP lookback) AND EMA(VWAP, VWAP lookback) <= EMA(VWAP, MVWAP lookback)
Long: flat AND long alignment AND NOT long alignment[1]
Short: flat AND short alignment AND NOT short alignment[1]
Exit: long, low <= entry price - stop-loss OR high >= entry price + take-profit OR (close-on-opposite enabled AND short alignment AND NOT short alignment[1])
Exit: short, high >= entry price + stop-loss OR low <= entry price - take-profit OR (close-on-opposite enabled AND long alignment AND NOT long alignment[1])