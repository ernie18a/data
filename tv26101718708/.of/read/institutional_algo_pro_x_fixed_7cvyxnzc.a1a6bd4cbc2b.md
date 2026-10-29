Calculation: Fast, middle, and slow EMA = exponential moving averages of close, with shorter, medium, and longer lookbacks, respectively
Calculation: Swing high/low = a high/low that is the maximum/minimum over a centered window of 2 × swing lookback + 1 chart bars, confirmed after swing lookback subsequent bars; retain the latest confirmed level
Calculation: Bullish/bearish structure break = close crosses above the latest swing high / below the latest swing low, respectively, and that level has not already been broken
Calculation: Bullish/bearish ORB breakout = after the opening range session has ended, close crosses above the session high / below the session low, respectively; reset the range each day
Calculation: Raw delta = volume × sign(close − open), where sign is 1, 0, or −1 for positive, zero, or negative input
Calculation: CVD = cumulative raw delta, reset at the start of each day
Calculation: Smoothed delta = EMA of raw delta
Calculation: Long entry stop = entry price − ATR × stop multiplier; short entry stop = entry price + ATR × stop multiplier
Calculation: Long TP1/TP3 = entry price + initial risk × TP1/TP3 reward-to-risk multiple; short TP1/TP3 = entry price − initial risk × TP1/TP3 reward-to-risk multiple
Long: bullish structure break OR (bullish ORB breakout AND fast EMA > middle EMA AND middle EMA > slow EMA AND RSI > bullish threshold AND smoothed delta > minimum delta AND CVD > prior bar CVD AND (VWAP filter disabled OR close > VWAP) AND (higher-timeframe filter disabled OR close > slow EMA of the higher timeframe's last completed bar))
Short: bearish structure break OR (bearish ORB breakout AND fast EMA < middle EMA AND middle EMA < slow EMA AND RSI < bearish threshold AND smoothed delta < −minimum delta AND CVD < prior bar CVD AND (VWAP filter disabled OR close < VWAP) AND (higher-timeframe filter disabled OR close < slow EMA of the higher timeframe's last completed bar))
Exit: Long, high >= long TP3 OR low <= current stop loss; after high >= long TP1, move stop loss to entry price plus ATR × breakeven buffer
Exit: Short, low <= short TP3 OR high >= current stop loss; after low <= short TP1, move stop loss to entry price minus ATR × breakeven buffer