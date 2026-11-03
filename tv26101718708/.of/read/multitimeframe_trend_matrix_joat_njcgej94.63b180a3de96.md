Calculation: Trend vote = for each configured timeframe, sign(sign(shorter-period close EMA − longer-period close EMA) + sign(close − shorter-period close EMA)); use the last completed bar for a higher timeframe and the last available intrabar for a lower timeframe; replace unavailable votes with zero.
Calculation: Chart votes = four votes: (1) +1 if the short EMA > medium EMA > long EMA, −1 if short EMA < medium EMA < long EMA, otherwise +1 if short EMA > long EMA and −1 otherwise; (2) +1 for an upward Supertrend and −1 otherwise; (3) +1 if RSI >= 50 and −1 otherwise; (4) +1 if MACD histogram >= 0 and −1 otherwise. All use chart bars.
Calculation: Alignment = EMA of 100 times the sum of the six trend votes and four chart votes divided by ten.
Calculation: Signal state = initially 0; set to +1 after a Long alignment signal and −1 after a Short alignment signal; retain it otherwise.
Calculation: Entry risk = ATR on the signal bar multiplied by the stop multiplier; if the product <= 0, use that ATR instead. Fix it at entry.
Long: Alignment >= positive threshold AND (momentum confirmation disabled OR (chart MACD histogram > 0 AND chart RSI > 50)) AND signal state <= 0.
Short: Alignment <= negative threshold AND (momentum confirmation disabled OR (chart MACD histogram < 0 AND chart RSI < 50)) AND signal state >= 0.
Long: Any trend vote > 0 OR any chart vote > 0 OR alignment >= 0.
Short: Any trend vote < 0 OR any chart vote < 0 OR alignment < 0.
Exit: long, high >= entry price + entry risk multiplied by first target multiple OR low <= entry price − entry risk OR a Short alignment signal occurs.
Exit: short, low <= entry price − entry risk multiplied by first target multiple OR high >= entry price + entry risk OR a Long alignment signal occurs.