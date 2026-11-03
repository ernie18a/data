Calculation: Candle body = absolute value of close minus open
Calculation: Average candle body = simple moving average of candle body over a lookback
Calculation: Previous candle body high = maximum of the previous candle's open and close
Calculation: Previous candle body low = minimum of the previous candle's open and close
Calculation: Average volume = simple moving average of volume over the same lookback as average candle body
Long: close > open AND close > previous candle body high AND candle body >= average candle body * minimum body multiple AND (minimum volume multiple <= 0 OR volume >= average volume * minimum volume multiple) AND position side is not long
Short: close < open AND close < previous candle body low AND candle body >= average candle body * minimum body multiple AND (minimum volume multiple <= 0 OR volume >= average volume * minimum volume multiple) AND position side is not short
Exit: long, low <= stop price OR high >= target price OR a short signal occurs
Exit: short, high >= stop price OR low <= target price OR a long signal occurs