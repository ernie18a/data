Calculation: Opening-range high/low = highest high / lowest low during the configured daily session, usable after that session ends
Calculation: Swing high/low = high/low at the center bar of a window with equal lookback on each side, when it is the highest high / lowest low in that window
Calculation: Raw delta = volume when close > open, −volume when close < open, otherwise 0
Calculation: Smoothed delta = EMA of raw delta
Calculation: Cumulative delta = daily cumulative sum of raw delta, reset at the start of each day
Calculation: Initial stop = entry price minus (long) or plus (short) ATR times a risk multiplier; target 1, 2, and 3 = entry price plus (long) or minus (short) initial risk times respective reward multiples; after target 1, move stop to entry price plus (long) or minus (short) current ATR times a buffer
Long: close crosses above the locked opening-range high OR close crosses above the latest confirmed swing high OR (fast EMA > middle EMA > slow EMA AND RSI > bullish threshold AND smoothed delta > minimum delta AND cumulative delta > its prior value AND (VWAP filter disabled OR close > VWAP) AND (higher-timeframe filter disabled OR close > the EMA on the configured higher timeframe from its last completed bar))
Short: close crosses below the locked opening-range low OR close crosses below the latest confirmed swing low OR (fast EMA < middle EMA < slow EMA AND RSI < bearish threshold AND smoothed delta < negative minimum delta AND cumulative delta < its prior value AND (VWAP filter disabled OR close < VWAP) AND (higher-timeframe filter disabled OR close < the EMA on the configured higher timeframe from its last completed bar))
Exit: long, high >= target 3 OR low <= current stop
Exit: short, low <= target 3 OR high >= current stop