Calculation: center = VWAP(hlc3) when VWAP is selected, otherwise EMA(close, lookback)
Calculation: upper level = ceil((center + ATR(high, low, close, lookback) * multiplier) / strike increment) * strike increment
Calculation: lower level = floor((center - ATR(high, low, close, lookback) * multiplier) / strike increment) * strike increment
Short: high >= upper level AND (RSI filter disabled OR RSI(close, lookback) > oversold threshold) AND (session filter disabled OR datetime is within the entry session in Asia/Kolkata) AND entries taken today < daily maximum
Long: low <= lower level AND (RSI filter disabled OR RSI(close, lookback) < overbought threshold) AND (session filter disabled OR datetime is within the entry session in Asia/Kolkata) AND entries taken today < daily maximum
Exit: short, high >= upper level * (1 + stop percentage) OR low <= upper level * (1 - target percentage) OR datetime is within the end-of-day exit session in Asia/Kolkata
Exit: long, low <= lower level * (1 - stop percentage) OR high >= lower level * (1 + target percentage) OR datetime is within the end-of-day exit session in Asia/Kolkata
Calculation: Center = VWAP(hlc3) when VWAP mode is enabled, otherwise EMA(close, EMA length)
Calculation: Call strike level = ceil((Center + ATR(ATR length) * ATR multiplier) / strike increment) * strike increment
Calculation: Put strike level = floor((Center - ATR(ATR length) * ATR multiplier) / strike increment) * strike increment
Option: sell call, high >= Call strike level AND (session filter is disabled OR during entry session in Asia/Kolkata) AND daily option entries < daily trade limit AND (RSI filter is disabled OR RSI(close, RSI length) > RSI oversold threshold)
Option: sell put, low <= Put strike level AND (session filter is disabled OR during entry session in Asia/Kolkata) AND daily option entries < daily trade limit AND (RSI filter is disabled OR RSI(close, RSI length) < RSI overbought threshold)
Exit: short call, high >= Call strike level * (1 + stop loss percent / 100) OR low <= Call strike level * (1 - target percent / 100) OR during closeout session in Asia/Kolkata
Exit: short put, low <= Put strike level * (1 - stop loss percent / 100) OR high >= Put strike level * (1 + target percent / 100) OR during closeout session in Asia/Kolkata