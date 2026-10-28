Calculation: +DI = 100 × EMA(positive directional movement, lookback) / EMA(true range, lookback), where positive directional movement is high − previous high if that exceeds previous low − low and is positive, otherwise 0
Calculation: −DI = 100 × EMA(negative directional movement, lookback) / EMA(true range, lookback), where negative directional movement is previous low − low if that exceeds high − previous high and is positive, otherwise 0
Calculation: ADX = EMA(100 × |+DI − −DI| / (+DI + −DI), same lookback as the +DI and −DI calculations)
Long: +DI crosses above −DI AND CCI(close) > 100 AND ADX > threshold AND close > selected moving average
Short: −DI crosses above +DI AND CCI(close) < −100 AND ADX > threshold AND close < selected moving average
Exit: long, close <= entry price × (1 − stop-loss percentage) OR close >= entry price × (1 + take-profit percentage) OR the last N closes are each below the current selected moving average
Exit: short, close >= entry price × (1 + stop-loss percentage) OR close <= entry price × (1 − take-profit percentage) OR the last N closes are each above the current selected moving average