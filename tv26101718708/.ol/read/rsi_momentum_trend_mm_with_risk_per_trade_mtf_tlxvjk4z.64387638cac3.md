Calculation: Higher-timeframe RSI = RSI of close on a higher timeframe, using completed bars
Calculation: Higher-timeframe EMA change = current minus previous value of the close EMA on a higher timeframe, using completed bars
Calculation: Bullish state = turns true when higher-timeframe RSI crosses above the positive threshold and higher-timeframe EMA change is positive; turns false when higher-timeframe RSI is below the negative threshold and higher-timeframe EMA change is negative; otherwise retains its prior value
Calculation: Bearish state = turns true when higher-timeframe RSI is below the negative threshold and higher-timeframe EMA change is negative; turns false when higher-timeframe RSI crosses above the positive threshold and higher-timeframe EMA change is positive; otherwise retains its prior value
Long: Bullish state is true and was false on the prior chart bar AND position is flat AND datetime is within the configured backtest range AND trade direction permits long
Short: Bearish state is true and was false on the prior chart bar AND position is flat AND datetime is within the configured backtest range AND trade direction permits short
Exit: long, Percentage mode is selected AND (low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage))
Exit: short, Percentage mode is selected AND (high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage))
Exit: long, ATR mode is selected AND (low <= entry price - ATR * stop-loss multiplier OR high >= entry price + ATR * take-profit multiplier)
Exit: short, ATR mode is selected AND (high >= entry price + ATR * stop-loss multiplier OR low <= entry price - ATR * take-profit multiplier)
Exit: long, Trend Reversal mode is selected AND Bearish state is true and was false on the prior chart bar
Exit: short, Trend Reversal mode is selected AND Bullish state is true and was false on the prior chart bar