Long: RSI(close, lookback) > 50 AND RSI(close, lookback)[1] < 50
Long: RSI(close, lookback) >= 60 AND RSI(close, lookback)[1] < 60 AND the stored RSI value for the latest such signal since the latest cross above 50 is <= 60; initialize that value to 0 at a cross above 50 and update it to current RSI on this signal
Short: RSI(close, lookback) < 50 AND RSI(close, lookback)[1] > 50
Short: RSI(close, lookback) < 40 AND RSI(close, lookback)[1] > 40 AND the stored RSI value is >= 40; initialize it to 0, set it to current RSI at a cross below 50, and update it to current RSI on this signal
Exit: long, RSI(close, lookback) < 70 AND RSI(close, lookback)[1] >= 70 AND RSI(close, lookback) >= 50 AND no earlier such exit has occurred since the latest cross above 50
Exit: short, RSI(close, lookback) > 30 AND RSI(close, lookback)[1] <= 30 AND RSI(close, lookback) < 50 AND no earlier such exit has occurred since the latest cross below 50