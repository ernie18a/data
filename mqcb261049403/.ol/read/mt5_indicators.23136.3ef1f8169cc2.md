Calculation: Prior-range high = highest high of the longer lookback over completed bars before the current bar
Calculation: Prior-range low = lowest low of the same lookback over completed bars before the current bar
Calculation: Short stop level = prior-range high plus three times the current bar's spread
Calculation: Long stop level = prior-range low minus twice the current bar's spread
Calculation: Short-term TEMA = triple exponential moving average of median price with a one-bar lookback
Calculation: Long-term TEMA = triple exponential moving average of median price with a longer lookback than the short-term TEMA
Long: Current position is flat or short AND ((current high >= prior-range high AND current close > short-term TEMA AND current close > long-term TEMA AND current high > long-term TEMA AND current MFI >= upper threshold) OR (current close >= previous bar's short stop level AND current high > prior-range high))
Short: Current position is flat or long AND ((current low <= prior-range low AND current close < short-term TEMA AND current close < long-term TEMA AND current low < long-term TEMA AND current MFI <= lower threshold) OR (current close <= previous bar's long stop level AND current low < prior-range low))