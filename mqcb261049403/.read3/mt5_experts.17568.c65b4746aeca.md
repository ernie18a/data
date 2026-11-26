Calculation: support level = lowest low over the level lookback of completed T1 bars, read on chart bars
Calculation: resistance level = highest high over the level lookback of completed T1 bars, read on chart bars
Long: open of the still-forming T1 bar > EMA(close, EMA lookback, T1, still-forming bar), evaluated on chart bars
Short: open of the still-forming T1 bar < EMA(close, EMA lookback, T1, still-forming bar), evaluated on chart bars
Long: close > resistance level AND open of the still-forming T1 bar > EMA(close, EMA lookback, T1, still-forming bar), evaluated on chart bars
Short: close < support level AND open of the still-forming T1 bar < EMA(close, EMA lookback, T1, still-forming bar), evaluated on chart bars
Exit: long, close < support level AND close >= entry price
Exit: short, close > resistance level AND close <= entry price