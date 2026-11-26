Calculation: Chart EMA = EMA(close, median lookback, chart timeframe, bar still forming)
Calculation: MTF score = number of T1 through T7 still-forming closes above their EMA(close, median lookback, Ti, still-forming bar) minus number not above; evaluated on chart bars using values from T1 through T7
Calculation: Deviation (%) = 100 * ABS(close - Chart EMA) / Chart EMA
Calculation: Recent swing high = Highest(high, swing lookback) over completed chart bars immediately before the still-forming bar
Calculation: Prior swing high = Highest(high, same swing lookback) over the adjacent older completed chart bars
Calculation: Recent swing low = Lowest(low, swing lookback) over completed chart bars immediately before the still-forming bar
Calculation: Prior swing low = Lowest(low, same swing lookback) over the adjacent older completed chart bars
Calculation: Up structure = Recent swing high > Prior swing high AND Recent swing low > Prior swing low
Calculation: Down structure = Recent swing high <= Prior swing high AND Recent swing low <= Prior swing low
Long: close > Chart EMA
Short: close <= Chart EMA
Long: MTF score > 0
Short: MTF score < 0
Long: Up structure
Short: Down structure
Long: MTF score >= strong-consensus threshold AND close > Chart EMA AND Up structure
Short: MTF score <= -strong-consensus threshold AND close <= Chart EMA AND Down structure
Long: MTF score >= strong-consensus threshold AND close < Chart EMA AND Deviation (%) >= lower-band threshold
Long: MTF score = 0 AND ADX(lookback, chart timeframe, bar still forming) < weak-ADX threshold AND close < Chart EMA AND Deviation (%) >= higher extreme-deviation threshold
Short: MTF score = 0 AND ADX(lookback, chart timeframe, bar still forming) < weak-ADX threshold AND close > Chart EMA AND Deviation (%) >= higher extreme-deviation threshold
Exit: long, MTF score >= strong-consensus threshold AND close > Chart EMA AND Deviation (%) >= higher extreme-deviation threshold