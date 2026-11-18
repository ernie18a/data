Calculation: center = VWAP(hlc3) when VWAP is selected, otherwise EMA(close, lookback)
Calculation: upper level = ceil((center + ATR(high, low, close, lookback) * multiplier) / strike increment) * strike increment
Calculation: lower level = floor((center - ATR(high, low, close, lookback) * multiplier) / strike increment) * strike increment
Short: high >= upper level AND (RSI filter disabled OR RSI(close, lookback) > oversold threshold) AND (session filter disabled OR datetime is within the entry session in Asia/Kolkata) AND entries taken today < daily maximum
Long: low <= lower level AND (RSI filter disabled OR RSI(close, lookback) < overbought threshold) AND (session filter disabled OR datetime is within the entry session in Asia/Kolkata) AND entries taken today < daily maximum
Exit: short, high >= upper level * (1 + stop percentage) OR low <= upper level * (1 - target percentage) OR datetime is within the end-of-day exit session in Asia/Kolkata
Exit: long, low <= lower level * (1 - stop percentage) OR high >= lower level * (1 + target percentage) OR datetime is within the end-of-day exit session in Asia/Kolkata