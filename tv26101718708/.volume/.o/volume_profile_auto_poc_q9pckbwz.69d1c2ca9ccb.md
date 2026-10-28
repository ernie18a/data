Calculation: POC = center price of the price bin with the greatest summed volume, using each bar’s close and volume across a rolling lookback; divide the range from the lowest low to highest high across that lookback into equal-width bins.
Long: previous close <= previous POC + 0.5 × ATR AND current close > current POC + 0.5 × ATR AND current volume > average volume
Short: previous close >= previous POC - 0.5 × ATR AND current close < current POC - 0.5 × ATR AND current volume > average volume
Exit: Long, close is within POC ± 0.5 × ATR OR low <= close - 2 × ATR
Exit: Short, close is within POC ± 0.5 × ATR OR high >= close + 2 × ATR