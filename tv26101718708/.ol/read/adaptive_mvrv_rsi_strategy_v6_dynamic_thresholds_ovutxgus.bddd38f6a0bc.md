Calculation: Weekly RSI = RSI of close over a shorter lookback on higher-timeframe bars, using the last completed bar
Calculation: MVRV buy threshold = long-lookback average of MVRV on higher-timeframe bars minus its long-lookback standard deviation multiplied by a lower-zone multiplier; use the last completed bar
Calculation: MVRV sell threshold = long-lookback average of MVRV on higher-timeframe bars plus its long-lookback standard deviation multiplied by an upper-zone multiplier; use the last completed bar
Calculation: RSI buy threshold = long-lookback average of Weekly RSI minus its long-lookback standard deviation multiplied by a lower-zone multiplier; use the last completed higher-timeframe bar
Calculation: RSI sell threshold = long-lookback average of Weekly RSI plus its long-lookback standard deviation multiplied by an upper-zone multiplier; use the last completed higher-timeframe bar
Long: MVRV is below its buy threshold OR Weekly RSI is below its buy threshold
Exit: long, MVRV is above its sell threshold OR Weekly RSI is above its sell threshold