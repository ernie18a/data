Long: long side enabled AND fast MA crosses above slow MA AND (trend filter disabled OR trend filter set above and close > SMA(close, trend lookback) OR trend filter set below and close < SMA(close, trend lookback)); fast and slow MA types are selected independently from SMA, EMA, WMA, and VWMA, with shorter and longer lookbacks respectively
Short: short side enabled AND fast MA crosses below slow MA AND (both sides enabled OR trend filter disabled OR trend filter set above and close > SMA(close, trend lookback) OR trend filter set below and close < SMA(close, trend lookback)); fast and slow MA types are selected independently from SMA, EMA, WMA, and VWMA, with shorter and longer lookbacks respectively
Exit: long, short side disabled AND fast MA crosses below slow MA
Exit: short, long side disabled AND fast MA crosses above slow MA
Exit: long, profit target enabled AND high >= entry price + close × profit-target percentage / 100
Exit: long, stop loss enabled AND low <= entry price − close × stop-loss percentage / 100
Exit: short, profit target enabled AND low <= entry price − close × profit-target percentage / 100
Exit: short, stop loss enabled AND high >= entry price + close × stop-loss percentage / 100