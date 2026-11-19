Calculation: Opening range high = highest(high) from session open through opening-range end
Calculation: Opening range low = lowest(low) from session open through opening-range end
Calculation: Opening range size = opening range high - opening range low
Calculation: Daily P&L = current strategy equity - strategy equity at session start
Long: after opening-range end AND before end-of-day cutoff AND opening range size >= ATR(ATR lookback) × minimum range multiplier AND opening range size <= ATR(ATR lookback) × maximum range multiplier AND ((close-confirmation required AND close > opening range high) OR (close-confirmation not required AND high > opening range high)) AND volume > SMA(volume, volume lookback) × volume multiplier AND no long breakout earlier this session AND position is flat AND Daily P&L > -daily-loss limit
Short: after opening-range end AND before end-of-day cutoff AND opening range size >= ATR(ATR lookback) × minimum range multiplier AND opening range size <= ATR(ATR lookback) × maximum range multiplier AND ((close-confirmation required AND close < opening range low) OR (close-confirmation not required AND low < opening range low)) AND volume > SMA(volume, volume lookback) × volume multiplier AND no short breakout earlier this session AND position is flat AND Daily P&L > -daily-loss limit
Exit: Long, (ORB-edge stop mode AND low <= opening range low) OR (ATR stop mode AND low <= entry-signal close - ATR(entry-signal bar, ATR lookback) × stop multiplier)
Exit: Long, high >= opening range high + opening range size × TP1 extension percentage
Exit: Long, since entry high has reached the TP1 level AND high >= opening range high + opening range size × TP2 extension percentage
Exit: Long, datetime reaches end-of-day cutoff
Exit: Long, Daily P&L <= -daily-loss limit
Exit: Short, (ORB-edge stop mode AND high >= opening range high) OR (ATR stop mode AND high >= entry-signal close + ATR(entry-signal bar, ATR lookback) × stop multiplier)
Exit: Short, low <= opening range low - opening range size × TP1 extension percentage
Exit: Short, since entry low has reached the TP1 level AND low <= opening range low - opening range size × TP2 extension percentage
Exit: Short, datetime reaches end-of-day cutoff
Exit: Short, Daily P&L <= -daily-loss limit